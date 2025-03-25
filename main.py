import json
import requests
from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import Updater, CommandHandler, MessageHandler, Filters, CallbackContext, CallbackQueryHandler

# Çàìåíèòå 'YOUR_TOKEN' íà òîêåí âàøåãî áîòà
TOKEN = 'YOUR_TOKEN'

# ID ÷àòà äëÿ ïðîâåðêè
ADMIN_CHAT_ID = 1111

# URL ôàéëîâ â ðåïîçèòîðèè GitHub
PRICE_AB_URL = 'https://github.com/Hardi777/Price/blob/d4d9de5c43d29a08f705fc761507398556a7e613/pricesAB.json'
PRICE_CR_URL = 'https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/priceCR.json'

# Õðàíèì äàííûå èç ôàéëîâ â ñëîâàðÿõ
price_ab = {}
price_cr = {}
current_mode = None
pending_addition = {}

# Çàãðóçêà äàííûõ èç JSON ôàéëîâ ñ GitHub
def load_data():
    global price_ab, price_cr
    price_ab = requests.get(PRICE_AB_URL).json()
    price_cr = requests.get(PRICE_CR_URL).json()['list']

load_data()

def start(update: Update, context: CallbackContext):
    chat_id = update.effective_chat.id
    if chat_id == ADMIN_CHAT_ID:
        context.bot.send_message(chat_id, "admin")
    else:
        context.bot.send_message(chat_id, "hello")

def central_market(update: Update, context: CallbackContext):
    global current_mode
    current_mode = 'cr'
    context.bot.send_message(update.effective_chat.id, "Öåíòðàëüíûé Ðûíîê")

def auto_market(update: Update, context: CallbackContext):
    global current_mode
    current_mode = 'ab'
    context.bot.send_message(update.effective_chat.id, "Àâòîðûíîê")

def handle_message(update: Update, context: CallbackContext):
    global current_mode
    message = update.message.text
    
    if current_mode == 'cr':
        response = search_in_price_cr(message)
    elif current_mode == 'ab':
        response = search_in_price_ab(message)
    else:
        response = "Âûáåðèòå ðåæèì ñ ïîìîùüþ /cr èëè /ab."

    context.bot.send_message(update.effective_chat.id, response)

def search_in_price_cr(query):
    results = []
    for item, details in price_cr.items():
        if query.lower() in item.lower():  # Ïîèñê ïî íàçâàíèþ îáúåêòà
            price = details['sa']['price']
            results.append(f"Ðåçóëüòàò: {item} - öåíà {price}$")
    return "\n".join(results) if results else "Ñîâïàäåíèé íå íàéäåíî."

def search_in_price_ab(query):
    results = []
    for item, price in price_ab.items():
        if query.lower() in item.lower():  # Ïîèñê ïî íàçâàíèþ àâòîìîáèëÿ
            results.append(f"Ðåçóëüòàò: {item} - öåíà {price}$")
    return "\n".join(results) if results else "Ñîâïàäåíèé íå íàéäåíî."

def add_item(update: Update, context: CallbackContext):
    context.bot.send_message(update.effective_chat.id, "Ââåäèòå íàçâàíèå:")
    return "WAITING_FOR_NAME"

def receive_name(update: Update, context: CallbackContext):
    name = update.message.text
    pending_addition['name'] = name
    context.bot.send_message(update.effective_chat.id, "Ââåäèòå öåíó (÷èñëîì, áåç ïðîáåëîâ, òî÷åê è ñîêðàùåíèé):")
    return "WAITING_FOR_PRICE"

def receive_price(update: Update, context: CallbackContext):
    price = update.message.text
    if price.isdigit():
        pending_addition['price'] = int(price)
        context.bot.send_message(update.effective_chat.id, "Âûáåðèòå òèï:", reply_markup=type_menu())
    else:
        context.bot.send_message(update.effective_chat.id, "Íåâåðíûé ââîä. Ïîæàëóéñòà, ââåäèòå öåíó ÷èñëîì, áåç ïðîáåëîâ, òî÷åê è ñîêðàùåíèé:")
        return "WAITING_FOR_PRICE"

def type_menu():
    keyboard = [
        [InlineKeyboardButton("Ïðåäìåò", callback_data='item'),
         InlineKeyboardButton("Òðàíñïîðò", callback_data='vehicle')]
    ]
    return InlineKeyboardMarkup(keyboard)

def button_handler(update: Update, context: CallbackContext):
    query = update.callback_query
    query.answer()
    
    item_type = query.data
    name = pending_addition.get('name')
    price = pending_addition.get('price')
    
    if item_type == 'item':
        price_cr[name] = {'vc': {}, 'sa': {'price': price, 'updated': 1742116184}}
    elif item_type == 'vehicle':
        price_ab[name] = price
    
    # Óâåäîìëåíèå ìîäåðàòîðà
    context.bot.send_message(ADMIN_CHAT_ID, f"Çàïðîñ íà äîáàâëåíèå:\nÍàçâàíèå: {name}\nÖåíà: {price}$\nÒèï: {'Ïðåäìåò' if item_type == 'item' else 'Òðàíñïîðò'}", reply_markup=approval_menu(name, price, item_type))

    query.edit_message_text(text="Âàøå ïðåäëîæåíèå ïîëó÷èëî ñòàòóñ ìîäåðàöèè è æäåò ïðîâåðêè.")

def approval_menu(name, price, item_type):
    keyboard = [
        [InlineKeyboardButton("Ïðèíÿòü", callback_data=f'approve_{name}_{price}_{item_type}'),
         InlineKeyboardButton("Îòêëîíèòü", callback_data=f'decline_{name}_{price}_{item_type}')]
    ]
    return InlineKeyboardMarkup(keyboard)

def moderator_response(update: Update, context: CallbackContext):
    query = update.callback_query
    query.answer()

    data = query.data.split('_')
    action = data[0]
    name = data[1]
    price = data[2]
    item_type = data[3]

    if action == 'approve':
        context.bot.send_message(ADMIN_CHAT_ID, f"Çàïðîñ íà äîáàâëåíèå ïðèíÿò: {name} - {price}$")
        context.bot.send_message(ADMIN_CHAT_ID, "Äîáàâëåíî!")
    elif action == 'decline':
        context.bot.send_message(ADMIN_CHAT_ID, f"Çàïðîñ íà äîáàâëåíèå îòêëîíåí: {name} - {price}$")
        context.bot.send_message(ADMIN_CHAT_ID, "Îòêëîíåíî!")

def main():
    updater = Updater(TOKEN, use_context=True)

    # Îáðàáîò÷èêè êîìàíä
    updater.dispatcher.add_handler(CommandHandler('start', start))
    updater.dispatcher.add_handler(CommandHandler('cr', central_market))
    updater.dispatcher.add_handler(CommandHandler('ab', auto_market))
    updater.dispatcher.add_handler(CommandHandler('add', add_item))
    updater.dispatcher.add_handler(MessageHandler(Filters.text & ~Filters.command, handle_message))
    
    # Îáðàáîò÷èêè ñîñòîÿíèé
    updater.dispatcher.add_handler(MessageHandler(Filters.regex('^Ââåäèòå íàçâàíèå:$'), receive_name))
    updater.dispatcher.add_handler(MessageHandler(Filters.regex('^Ââåäèòå öåíó $$÷èñëîì, áåç ïðîáåëîâ, òî÷åê è ñîêðàùåíèé$$:$'), receive_price))
    
    # Îáðàáîò÷èê äëÿ êíîïîê
    updater.dispatcher.add_handler(CallbackQueryHandler(button_handler, pattern='^(item|vehicle)$'))
    updater.dispatcher.add_handler(CallbackQueryHandler(moderator_response, pattern='^(approve|decline)_'))

    # Çàïóñê áîòà
    updater.start_polling()

    # Îæèäàåì çàâåðøåíèÿ ðàáîòû
    updater.idle()

if __name__ == '__main__':
    main()
