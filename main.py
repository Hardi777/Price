import json
import requests
from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import Updater, CommandHandler, MessageHandler, Filters, CallbackContext, CallbackQueryHandler

# Замените 'YOUR_TOKEN' на токен вашего бота
TOKEN = 'YOUR_TOKEN'

# ID чата для проверки
ADMIN_CHAT_ID = 1111

# URL файлов в репозитории GitHub
PRICE_AB_URL = 'https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/priceAB.json'
PRICE_CR_URL = 'https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/priceCR.json'

# Храним данные из файлов в словарях
price_ab = {}
price_cr = {}
current_mode = None
pending_addition = {}

# Загрузка данных из JSON файлов с GitHub
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
    context.bot.send_message(update.effective_chat.id, "Центральный Рынок")

def auto_market(update: Update, context: CallbackContext):
    global current_mode
    current_mode = 'ab'
    context.bot.send_message(update.effective_chat.id, "Авторынок")

def handle_message(update: Update, context: CallbackContext):
    global current_mode
    message = update.message.text
    
    if current_mode == 'cr':
        response = search_in_price_cr(message)
    elif current_mode == 'ab':
        response = search_in_price_ab(message)
    else:
        response = "Выберите режим с помощью /cr или /ab."

    context.bot.send_message(update.effective_chat.id, response)

def search_in_price_cr(query):
    results = []
    for item, details in price_cr.items():
        if query.lower() in item.lower():  # Поиск по названию объекта
            price = details['sa']['price']
            results.append(f"Результат: {item} - цена {price}$")
    return "\n".join(results) if results else "Совпадений не найдено."

def search_in_price_ab(query):
    results = []
    for item, price in price_ab.items():
        if query.lower() in item.lower():  # Поиск по названию автомобиля
            results.append(f"Результат: {item} - цена {price}$")
    return "\n".join(results) if results else "Совпадений не найдено."

def add_item(update: Update, context: CallbackContext):
    context.bot.send_message(update.effective_chat.id, "Введите название:")
    return "WAITING_FOR_NAME"

def receive_name(update: Update, context: CallbackContext):
    name = update.message.text
    pending_addition['name'] = name
    context.bot.send_message(update.effective_chat.id, "Введите цену (числом, без пробелов, точек и сокращений):")
    return "WAITING_FOR_PRICE"

def receive_price(update: Update, context: CallbackContext):
    price = update.message.text
    if price.isdigit():
        pending_addition['price'] = int(price)
        context.bot.send_message(update.effective_chat.id, "Выберите тип:", reply_markup=type_menu())
    else:
        context.bot.send_message(update.effective_chat.id, "Неверный ввод. Пожалуйста, введите цену числом, без пробелов, точек и сокращений:")
        return "WAITING_FOR_PRICE"

def type_menu():
    keyboard = [
        [InlineKeyboardButton("Предмет", callback_data='item'),
         InlineKeyboardButton("Транспорт", callback_data='vehicle')]
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
    
    # Уведомление модератора
    context.bot.send_message(ADMIN_CHAT_ID, f"Запрос на добавление:\nНазвание: {name}\nЦена: {price}$\nТип: {'Предмет' if item_type == 'item' else 'Транспорт'}", reply_markup=approval_menu(name, price, item_type))

    query.edit_message_text(text="Ваше предложение получило статус модерации и ждет проверки.")

def approval_menu(name, price, item_type):
    keyboard = [
        [InlineKeyboardButton("Принять", callback_data=f'approve_{name}_{price}_{item_type}'),
         InlineKeyboardButton("Отклонить", callback_data=f'decline_{name}_{price}_{item_type}')]
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
        context.bot.send_message(ADMIN_CHAT_ID, f"Запрос на добавление принят: {name} - {price}$")
        context.bot.send_message(ADMIN_CHAT_ID, "Добавлено!")
    elif action == 'decline':
        context.bot.send_message(ADMIN_CHAT_ID, f"Запрос на добавление отклонен: {name} - {price}$")
        context.bot.send_message(ADMIN_CHAT_ID, "Отклонено!")

def main():
    updater = Updater(TOKEN, use_context=True)

    # Обработчики команд
    updater.dispatcher.add_handler(CommandHandler('start', start))
    updater.dispatcher.add_handler(CommandHandler('cr', central_market))
    updater.dispatcher.add_handler(CommandHandler('ab', auto_market))
    updater.dispatcher.add_handler(CommandHandler('add', add_item))
    updater.dispatcher.add_handler(MessageHandler(Filters.text & ~Filters.command, handle_message))
    
    # Обработчики состояний
    updater.dispatcher.add_handler(MessageHandler(Filters.regex('^Введите название:$'), receive_name))
    updater.dispatcher.add_handler(MessageHandler(Filters.regex('^Введите цену $$числом, без пробелов, точек и сокращений$$:$'), receive_price))
    
    # Обработчик для кнопок
    updater.dispatcher.add_handler(CallbackQueryHandler(button_handler, pattern='^(item|vehicle)$'))
    updater.dispatcher.add_handler(CallbackQueryHandler(moderator_response, pattern='^(approve|decline)_'))

    # Запуск бота
    updater.start_polling()

    # Ожидаем завершения работы
    updater.idle()

if __name__ == '__main__':
    main()
