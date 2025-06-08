-- автор наложил говнеца

script_name('fishHelper')
script_version('1.0')
script_author('Theopka')
local echoId = nil
local useId = nil
allfish = 0
local ffi = require 'ffi'
local gta = ffi.load("GTASA")
local sampev = require('lib.samp.events')
local badge = {
    init = false,
    id = 0,
    
    
}
local imgui = require('mimgui')
local widgets = require 'widgets'
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8
local faicons = require('fAwesome6')
local fa = require('fAwesome6_solid')

local MDS = MONET_DPI_SCALE
local AI_TOGGLE = {}
local ToU32 = imgui.ColorConvertFloat4ToU32
local filter = imgui.ImGuiTextFilter() 
local UI = { version = 1, font = {}, tab = 1 }
local tab = 1
local activeButton = 1

local FishTable = {}
local Window = imgui.new.bool()
local echoWindow = imgui.new.bool(true)
local echotext = ''
local waiting = 1500
local bot = false
local active = false
local cmd = "/fishrod"
local did = 25286 

local ltn12 = require("ltn12")
local http = require("socket.http")
local lmPath = "fishhelper.lua"
local lmUrl = "https://raw.githubusercontent.com/Theopochka/fishhelper_update/main/fishhelper.lua"
local echo = {
    init = false,
    id = 0,
    use = false,
    useid = 0
    
    
}
local inicfg = require 'inicfg'
local directIni = 'fishHelper.ini'
local ini = inicfg.load(inicfg.load({
    autocaptcha = {
        delay = 1000,
        enabled = false,
    },
    button = {
        knopka = false,
        fishbot = false,
    },
    stats = {
        salary = 0,
        fishsalary = 0,
        fishrodall = 0,
        larecall = 0,
        larecsalary = 0,
        artefaktall = 0,
        artefaktsalary = 0,
    },
    oknostats = {
        okno = false,
    },
    price = {
        larecprice = 0,
        artefaktprice = 0,
    },
}, directIni))
inicfg.save(ini, directIni)

local save = function()
    inicfg.save(ini, directIni)
end

local found_update = imgui.new.bool()
local WindowStats = imgui.new.bool(ini.oknostats.okno)

local delay = imgui.new.int(ini.autocaptcha.delay)
local autocaptcha = imgui.new.bool(ini.autocaptcha.enabled)

local knopka = imgui.new.bool(ini.button.knopka)
local fishbotknopka = imgui.new.bool(ini.button.fishbot)

local buffer = {
    larecprice = imgui.new.int(ini.price.larecprice),
    artefaktprice = imgui.new.int(ini.price.artefaktprice)
}

local fishvalue = {            -- таблица рыб, второй пункт это стоимость
    ['Kарп']              = 38996,
    ['Сазан']             = 44300,
    ['Щука']              = 38588,
    ['Скумбрия']          = 42689,
    ['Форель']            = 43176,
    ['Сиг']               = 40328,
    ['Линь']              = 43921,
    ['Карась']            = 38419,
    ['Окунь']             = 41916,
    ['Амур']              = 40235,
    ['Тостолоб']          = 42314,
    ['Стерлядь']          = 39458,
    ['Судак']             = 42954,
    ['Семга']             = 40601,
    ['Треска']            = 40242,
    ['Палтус']            = 44052,
    ['Навага']            = 39481,
    ['Минтай']            = 38419,
    ['Хек']               = 39026,
    ['Путасс']            = 40531,
    ['Налим']             = 42397,
    ['Чир']               = 42510,
    ['Осётр']             = 41096,
    ['Таймень']           = 42078,
    ['Лосось']            = 41008,
    ['Кижуч']             = 38659,
    ['Пикша']             = 39749,
    ['Шип']               = 39682,
    ['Севрюга']           = 39110,
    ['Бегула']            = 39916,
    ['Полосатая зубатка'] = 43706,
    ['Плотва']            = 39911,
    ['Пескарь']           = 39907,
    ['Берш']              = 38759,
    ['Жерех']             = 38892,
    ['Вырезуб']           = 42012,
    ['Язь']               = 44022,
    ['Сом']               = 40352,
    ['Морской окунь']     = 40447,
    ['Зубан']             = 42134,
    ['Испанская макрель'] = 40244,
    ['Пеламида']          = 39857,
    ['Барракуда']         = 40466,
    ['Корифена']          = 40603,
    ['Скат']              = 40368,
    ['Павлиний басс']     = 39818,
    ['Полосатый лаврак']  = 39104,
    ['Щука глубинная']    = 43642,
    ['Веслонос']          = 42811,
    ['Угорь']             = 42274,
    ['Химера']            = 40153,
    ['Хариус']            = 40332,
    ['Нерка']             = 43859,
    ['Тунец']             = 42478,
    ['Красный луциан']    = 44102,
}

local artefakt = {             -- таблица артефактов, второй пункт это рыбные монеты
    ['Лечебные водоросли ']   = 1,
    ['Кожаный сапог']         = 1,
    ['Серебряная цепь']       = 1,
    ['Брошь']                 = 1,
    ['Кулон']                 = 1,
    ['Череп']                 = 1,
    ['Шляпа рыбака']          = 1,
    ['Древнее копьё ']        = 1,
    ['Амулет']                = 1,
    ['Маска шамана']          = 1,
    ['Старый нож']            = 1,
    ['Сломанный телефон']     = 1,
    ['Наручные часы']         = 2,
    ['Пустая бутылка']        = 2,
    ['Ржавый револьвер']      = 2,
    ['Золотое кольцо']        = 2,
    ['Ритуальная чаша']       = 2,
    ['Неизвестная статуэтка'] = 2,
}
function imgui.GetMiddleButtonX(count)
    local width = imgui.GetWindowContentRegionWidth() -- ширины контекста окно
    local space = imgui.GetStyle().ItemSpacing.x
    return count == 1 and width or width/count - ((space * (count-1)) / count) -- вернется средние ширины по количеству
end
function downloadFile(url, path)
    local response = {}
    local _, status_code, _ = http.request{
    url = url,
    method = "GET",
    sink = ltn12.sink.file(io.open(path, "w")),
        headers = {
            ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0;Win64) AppleWebkit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.82 Safari/537.36",
        },
    }
    if status_code == 200 then
        return true
    else
        return false
    end
end

function check_update()
    msg('Проверка наличия обновлений...')
    local currentVersionFile = io.open(lmPath, "r")
    local currentVersion = currentVersionFile:read("*a")
    currentVersionFile:close()
    local response = http.request(lmUrl)
    if response and response ~= currentVersion then
        msg("Найдено новое обновление! Вывожу окно для загрузки...")
        found_update[0] = not found_update[0]
    else
        msg("У вас актуальная версия скрипта.")
    end
end

function updateScript(scriptUrl, scriptPath)
    msg("Проверка наличия обновлений...")
    local response = http.request(scriptUrl)
    if response and response ~= currentVersion then
        msg("Обновление...")
        local success = downloadFile(scriptUrl, scriptPath)
        if success then
            msg("Скрипт успешно обновлен. Перезагрузка..")
            thisScript():reload()
        else
            msg("Неизвестная ошибка, не удалось обновить скрипт.")
        end
    else
        msg("Скрипт уже является последней версией.")
    end
end

function sampev.onServerMessage(color, text)
    if text:match(' стало больше на (%d+) ед.') then allfish =
    tonumber(text:match(" стало больше на (%d+) ед.")) bot = true active = true
    end
    if text:match('оснастка оборвалась') then active = true end
    local fish_name = text:match("поймал%(а%) рыбу '(.-)'")
    if fish_name then
     allfish = allfish-1
        for k, v in pairs(FishTable) do
            fishecho = v.name
            if fishecho:find(fish_name) then
                v.value = v.value-1
            end
        end
       if allfish == 0 then lua_thread.create(echolot) end
        local value = fishvalue[fish_name]
        if value then
            ini.stats.fishrodall = ini.stats.fishrodall + 1
            ini.stats.fishsalary = ini.stats.fishsalary + value
            save() 
        end
    end

    local art_name = text:match("поймал%(а%) '(.-)'")
    if art_name then
        local art_value = artefakt[art_name]
        if art_value then
            ini.stats.artefaktall = ini.stats.artefaktall + art_value
            ini.stats.artefaktsalary = ini.stats.artefaktall * ini.price.artefaktprice
            save() 
        end
    end

    if text:find("Вам был добавлен предмет 'Ларец рыболова") then
        ini.stats.larecall = ini.stats.larecall + 1
        ini.stats.larecsalary = ini.stats.larecall * ini.price.larecprice
        save()
    end
    if text:match('(.+) Вы забросили удочку.') then
        return false
    end
    if text:match('поймал%(а%)') and bot then
        if allfish == 0 then msg('В данном месте закончилась рыба') bot = false
        active = false 
        else
            active = true
        end
    end
end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
    if text:find('обитает') then
           FishTable = {}
           allfish = 0
           
        for line in text:gmatch('[^\r\n]+') do
            if line:find('клюёт') then
                

local name = line:match("%{[^}]-%}[^}]-%s*(.+)%s*%(")
    name = string.gsub(name,'{cccccc}','')
local number = line:match("%(%s*(%d+)%s*шт%)")
value = tonumber(number)
allfish = allfish+value


                 
                 table.insert(FishTable,{name = name,value = value})
                
                
     
                
                
            end
        end
   
    --  
        sampSendDialogResponse(dialogId,0,65535,nil)
        bot = true
        active = true
        msg('Данные Эхолота обновлены')
        return false
    end
    if text:find('В данном секторе отсутствует рыба')  then
        lua_thread.create(Badge)
    sampSendDialogResponse(dialogId,1,65535,nil) 
    return false 
    end
    if text:find('Проверить наличие рыбы в секторе') then
        sampSendDialogResponse(dialogId,1,0, 'Проверить наличие рыбы в секторе')
        return false
        end
    
    
    
        if dialogId == 25286 then
            sampSendDialogResponse(dialogId, 1, 5, nil)
            
            return false
            
        end
    
end

function imgui.CenterText(text)
    imgui.SetCursorPosX(imgui.GetWindowSize().x / 2 - imgui.CalcTextSize(text).x / 2)
    imgui.Text(text)
end

function sep(n)
    if not n or type(n) ~= "number" then 
        return "0"  
    end
    
    local left, num, right = string.match(tostring(n), '^([^%d]*%d)(%d*)(.-)$')
    if not left then
        return tostring(n)
    end

    return left .. (num:reverse():gsub('(%d%d%d)', '%1,'):reverse()) .. right
end

function imgui.Hint(text)
    imgui.SameLine()
    imgui.TextDisabled("(?)")
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.TextUnformatted(u8(text))
        imgui.EndTooltip()
    end
end
---- мимгуи
local StateFrame = imgui.OnFrame(
    function() return Window[0] end, 
    function(self)
        local resX, resY = getScreenResolution()
        local sizeX, sizeY = 540 * MDS, 340 * MDS
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY), imgui.Cond.FirstUseEver)

        imgui.Begin('dlc', Window, imgui.WindowFlags.NoDecoration)
        
        imgui.SetCursorPos(imgui.ImVec2(4 * MDS, 4 * MDS))
        if imgui.Button(fa.XMARK..'', imgui.ImVec2(50, 50)) then
            Window[0] = false
        end
        if imgui.IsItemHovered() then
            imgui.BeginTooltip()
            imgui.Text(u8'Закрыть меню')
            imgui.EndTooltip()
        end
        imgui.SetCursorPos(imgui.ImVec2(20 * MDS, 30 * MDS))
        imgui.PushFont(big)
        imgui.Text(faicons('fish')..' Fish helper')
        imgui.PopFont()

        imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(1.0, 1.0, 1.0, 0.0))
        imgui.SetCursorPos(imgui.ImVec2(115 * MDS, 10 * MDS)) 
    if imgui.BeginChild('Name##'..tab, imgui.ImVec2(415 * MDS, 320 * MDS), true) then -- меню
        
        if tab == 1 then 
            imgui.CenterText(u8'Итоговый заработок: '..sep(ini.stats.salary + ini.stats.artefaktsalary + ini.stats.fishsalary + ini.stats.larecsalary)..'$') 
            imgui.Text('')
            imgui.CenterText(u8'Заработок ларцов: '..sep(ini.stats.larecsalary)..'$')
            imgui.CenterText(u8'Заработок на рыбе: '..sep(ini.stats.fishsalary)..'$')
            imgui.CenterText(u8'Заработок на рыбных монет: '..sep(ini.stats.artefaktsalary)..'$')
            imgui.Text('')
            imgui.CenterText(u8'Количество рыбных монет: '..sep(ini.stats.artefaktall))
            imgui.Hint('Это рыбные монеты, я просто конвертировал с артефактов в рыбные монеты')
            imgui.CenterText(u8'Количество рыбы: '..sep(ini.stats.fishrodall))
            imgui.CenterText(u8'Количество ларцов: '..sep(ini.stats.larecall))
            imgui.SetCursorPosY(imgui.GetWindowSize().y - (30*2) * MDS - imgui.GetStyle().FramePadding.y * 2)
            if imgui.Button(fa.TRASH..u8' Сбросить всё', imgui.ImVec2(imgui.GetMiddleButtonX(1), 30 * MDS)) then
                imgui.OpenPopup(fa.CIRCLE_EXCLAMATION..u8' Предупреждения! ')
            end
            imgui.SetNextWindowSize(imgui.ImVec2(200* MDS, 72 * MDS), imgui.Cond.FirstUseEver)
            if imgui.BeginPopupModal(fa.CIRCLE_EXCLAMATION..u8' Предупреждения! ', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize) then
                imgui.CenterText(u8'Вы уверены?')
                if imgui.Button(fa.CHECK..u8'Да', imgui.ImVec2(imgui.GetMiddleButtonX(2), 30 * MDS)) then
                    ini.stats.larecsalary = 0
                    ini.stats.fishsalary = 0
                    ini.stats.artefaktsalary = 0
                    ini.stats.artefaktall = 0
                    ini.stats.fishrodall = 0
                    ini.stats.larecall = 0
                    save()
                    imgui.CloseCurrentPopup()
                end
                imgui.SameLine()
                if imgui.Button(fa.XMARK..u8' Нет', imgui.ImVec2(imgui.GetMiddleButtonX(2), 30 * MDS)) then
                    imgui.CloseCurrentPopup()
                end
                
                imgui.EndPopup()
            end

            if imgui.Button(fa.DELETE_LEFT..u8' Сбросить заработок', imgui.ImVec2(imgui.GetMiddleButtonX(2), 30 * MDS)) then
                imgui.OpenPopup(fa.CIRCLE_EXCLAMATION..u8' Предупреждения!  ')
            end
            imgui.SetNextWindowSize(imgui.ImVec2(200* MDS, 72 * MDS), imgui.Cond.FirstUseEver)
            if imgui.BeginPopupModal(fa.CIRCLE_EXCLAMATION..u8' Предупреждения!  ', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize) then
                imgui.CenterText(u8'Вы уверены?')
                if imgui.Button(fa.CHECK..u8'Да', imgui.ImVec2(imgui.GetMiddleButtonX(2), 30 * MDS)) then
                    ini.stats.larecsalary = 0
                    ini.stats.fishsalary = 0
                    ini.stats.artefaktsalary = 0
                    save()
                    imgui.CloseCurrentPopup()
                end
                imgui.SameLine()
                if imgui.Button(fa.XMARK..u8' Нет', imgui.ImVec2(imgui.GetMiddleButtonX(2), 30 * MDS)) then
                    imgui.CloseCurrentPopup()
                end
                
                imgui.EndPopup()
            end
            imgui.SameLine()
            if imgui.Button(fa.DELETE_LEFT..u8' Сбросить количество', imgui.ImVec2(imgui.GetMiddleButtonX(2), 30 * MDS)) then
                imgui.OpenPopup(fa.CIRCLE_EXCLAMATION..u8' Предупреждения!   ')
            end
            imgui.SetNextWindowSize(imgui.ImVec2(200* MDS, 72 * MDS), imgui.Cond.FirstUseEver)
            if imgui.BeginPopupModal(fa.CIRCLE_EXCLAMATION..u8' Предупреждения!   ', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize) then
                imgui.CenterText(u8'Вы уверены?')
                if imgui.Button(fa.CHECK..u8'Да', imgui.ImVec2(imgui.GetMiddleButtonX(2), 30 * MDS)) then
                    ini.stats.artefaktall = 0
                    ini.stats.fishrodall = 0
                    ini.stats.larecall = 0
                    save()
                    imgui.CloseCurrentPopup()
                end
                imgui.SameLine()
                if imgui.Button(fa.XMARK..u8' Нет', imgui.ImVec2(imgui.GetMiddleButtonX(2), 30 * MDS)) then
                    imgui.CloseCurrentPopup()
                end
                
                imgui.EndPopup()
            end
        end

        if tab == 2 then 

            if imgui.Button(fa.TAG..u8' Установить цены', imgui.ImVec2(imgui.GetMiddleButtonX(2), 30 * MDS)) then
                imgui.OpenPopup(fa.MONEY_CHECK_DOLLAR..u8' Цены')
            end
            if imgui.BeginPopupModal(fa.MONEY_CHECK_DOLLAR..u8' Цены', _, imgui.WindowFlags.AlwaysAutoResize) then
                if imgui.InputInt(u8' Цена ларца рыбалова', buffer.larecprice, 0, 0) then
                    ini.price.larecprice = buffer.larecprice[0]
                    save()
                end
                if imgui.InputInt(u8' Цена рыбной монеты', buffer.artefaktprice, 0, 0) then
                    ini.price.artefaktprice = buffer.artefaktprice[0]
                    save()
                end
                if imgui.Button(fa.XMARK..u8' Закрыть', imgui.ImVec2(-1, 20 * MDS)) then
                    imgui.CloseCurrentPopup()
                end
                imgui.EndPopup()
            end

            imgui.SameLine()

            if imgui.Button(fa.FISH..u8' fishingBot', imgui.ImVec2(imgui.GetMiddleButtonX(2), 30 * MDS)) then
                imgui.OpenPopup(fa.GEAR..u8' Настроить бота')
            end
            if imgui.BeginPopupModal(fa.GEAR..u8' Настроить бота', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize) then
                if imgui.ToggleButton(u8' Включить кнопку', u8'Выключить кнопку', knopka) then
                    ini.button.knopka = knopka[0]
                    ini.button.fishbot = fishbotknopka[0]
                    save()
                end
                if imgui.Button(fa.XMARK..u8' Закрыть', imgui.ImVec2(160 * MDS, 20 * MDS)) then
                    imgui.CloseCurrentPopup()
                end
                imgui.EndPopup()
            end

            if imgui.Button(fa.WINDOW_RESTORE..u8' Меню статистика', imgui.ImVec2(imgui.GetMiddleButtonX(1), 30 * MDS)) then
                imgui.OpenPopup(fa.GEAR..u8' Настроить меню')
            end
            if imgui.BeginPopupModal(fa.GEAR..u8' Настроить меню', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize) then
                if imgui.ToggleButton(u8' Включить статистику', u8'Выключить статистику', WindowStats) then
                    ini.oknostats.okno = WindowStats[0]
                    save()
                end
                if imgui.Button(fa.XMARK..u8' Закрыть', imgui.ImVec2(180 * MDS, 20 * MDS)) then
                    imgui.CloseCurrentPopup()
                end
                imgui.EndPopup()
            end

            if imgui.Button(fa.BOLT..u8' AutoCaptcha by ospx', imgui.ImVec2(imgui.GetMiddleButtonX(1), 30 * MDS)) then
                imgui.OpenPopup(fa.GEAR..u8' Настроить каптчу')
            end
            if imgui.BeginPopupModal(fa.GEAR..u8' Настроить каптчу', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize) then
                if imgui.ToggleButton(u8' Включить AutoCaptcha', u8'Выключить AutoCaptcha', autocaptcha) then
                    ini.autocaptcha.enabled = autocaptcha[0]
                    save()
                end
                if imgui.InputInt(u8' Введите кд автокаптчи', delay, 0, 0) then
                    ini.autocaptcha.delay = delay[0]
                    save()
                end
                imgui.Text(u8'в мс, 1000мс = 1с')
                if imgui.Button(fa.XMARK..u8' Закрыть', imgui.ImVec2(440 * MDS, 20 * MDS)) then
                    imgui.CloseCurrentPopup()
                end
                imgui.EndPopup()
            end


        end
        if tab == 3 then 
            imgui.CenterText(fa.USER..u8' Author: Theopka')
            imgui.CenterText(fa.FIRE..u8' Version: '..thisScript().version)
            imgui.CenterText('')
            if imgui.Button(fa.PAPER_PLANE..u8" Перейти в ТГК", imgui.ImVec2(imgui.GetMiddleButtonX(1), 25 * MDS)) then 
                openLink("https://t.me/TheopkaStudio") 
            end
            if imgui.CollapsingHeader(fa.FIRE..u8' Список обновленний') then
                if imgui.CollapsingHeader(u8'1.0(04.01.2025)') then
                    imgui.CenterText(u8'Релиз скрипта')
                end
            end
        end
        imgui.EndChild()
       end

       
imgui.SetCursorPos(imgui.ImVec2(10 * MDS, 70 * MDS))
if imgui.BeginChild('Buttons##', imgui.ImVec2(100 * MDS, 260 * MDS), true) then -- TAB 
    imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1.0, 1.0, 1.0, 0.0))
    if activeButton == 1 then
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.0, 0.0, 1.0))
    end
    imgui.SetCursorPos(imgui.ImVec2(2, imgui.GetCursorPosY())) 
        imgui.PushFont(texte)
    if imgui.Button(faicons('circle_info')..u8" Статистика", imgui.ImVec2(95 * MDS, 83 * MDS)) then
        tab = 1
        activeButton = 1
    end
    if activeButton == 1 then
        imgui.PopStyleColor()
        local drawlist = imgui.GetForegroundDrawList()
        local buttonPos = imgui.GetItemRectMax() 
        drawlist:AddLine(buttonPos, buttonPos - imgui.ImVec2(0, 83 * MDS), imgui.ColorConvertFloat4ToU32(imgui.ImVec4(1.0, 0.0, 0.0, 1.0)), 4.0)
    end

    if activeButton == 2 then
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.0, 0.0, 1.0)) 
    end
    imgui.SetCursorPos(imgui.ImVec2(2, imgui.GetCursorPosY()))  
    if imgui.Button(faicons('gear')..u8" Настройки", imgui.ImVec2(95 * MDS, 83 * MDS)) then
        tab = 2
        activeButton = 2
    end
    if activeButton == 2 then
        imgui.PopStyleColor()
        local drawlist = imgui.GetForegroundDrawList()
        local buttonPos = imgui.GetItemRectMax() 
        drawlist:AddLine(buttonPos, buttonPos - imgui.ImVec2(0, 83 * MDS), imgui.ColorConvertFloat4ToU32(imgui.ImVec4(1.0, 0.0, 0.0, 1.0)), 4.0)
    end

    if activeButton == 3 then
        imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 0.0, 0.0, 1.0)) 
    end
    imgui.SetCursorPos(imgui.ImVec2(2, imgui.GetCursorPosY())) 
    if imgui.Button(faicons('user')..u8" Информация", imgui.ImVec2(95 * MDS, 83 * MDS)) then
        tab = 3
        activeButton = 3
    end
    if activeButton == 3 then
        imgui.PopStyleColor()
        local drawlist = imgui.GetForegroundDrawList()
        local buttonPos = imgui.GetItemRectMax()
        drawlist:AddLine(buttonPos, buttonPos - imgui.ImVec2(0, 83 * MDS), imgui.ColorConvertFloat4ToU32(imgui.ImVec4(1.0, 0.0, 0.0, 1.0)), 4.0) 
    end
imgui.PopFont()

    imgui.EndChild()
end

        imgui.PopStyleColor()
        imgui.End()
    end
)
imgui.OnFrame(
    function() return knopka[0] end,
    function(player)
        local sizeX, sizeY = 60 * MDS, 60 * MDS
        imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY), imgui.Cond.FirstUseEver)
        imgui.Begin('Main Window', knopka, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
            if imgui.Button(fa.FISH..u8'', imgui.ImVec2(50 * MDS, 50 * MDS)) then
                bot = not bot
                active = true
                cmd = cmd
                msg(bot and'Бот запущен!' or 'Бот выключен!')
            end
        imgui.End()
    end
)
imgui.OnFrame(
    function() return WindowStats[0] end,
    function(player)
        imgui.Begin('stats_window', WindowStats, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.AlwaysAutoResize)

            imgui.CenterText(fa.MONEY_CHECK..u8' Итоговый заработок: '..sep(ini.stats.salary + ini.stats.artefaktsalary + ini.stats.fishsalary + ini.stats.larecsalary)..'$') 
            imgui.Text('')
            imgui.CenterText(u8'Заработок ларцов: '..sep(ini.stats.larecsalary)..'$')
            imgui.CenterText(u8'Заработок на рыбе: '..sep(ini.stats.fishsalary)..'$')
            imgui.CenterText(u8'Заработок на рыбных монет: '..sep(ini.stats.artefaktsalary)..'$')
            imgui.Text('')
            imgui.CenterText(fa.COINS..u8' Количество рыбных монет: '..sep(ini.stats.artefaktall))
            imgui.CenterText(fa.FISH..u8' Количество рыбы: '..sep(ini.stats.fishrodall))
            imgui.CenterText(fa.BOXES_STACKED..u8 ' Количество ларцов: '..sep(ini.stats.larecall))

        imgui.End()
    end
)
-- спиздил меню у MikuProjectReborn, автор разрешил
imgui.OnFrame(function() return found_update[0] end, function(player)
    local scrx, scry = getScreenResolution()
    imgui.SetNextWindowPos(imgui.ImVec2(scrx / 2, scry / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.Begin(u8'', found_update, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove)
    imgui.CenterText('')
    imgui.CenterText('Fish helper')
    imgui.CenterText('Credits:  sTheopka | TheopkaStudio')
    imgui.CenterText('')
    imgui.CenterText(u8'Найдено новое обновление!')
    imgui.CenterText('')
    imgui.CenterText(u8'Было найдено новое обновление скрипта.')
    imgui.CenterText(u8'Для продолжения работы')
    imgui.CenterText(u8'Вам необходимо выбрать одну из двух кнопок ниже')
    imgui.CenterText('')
    imgui.CenterText(u8'О новых изменениях почитайте в пункте "Информация"')
    imgui.CenterText('')
    if imgui.Button(faicons("DOWNLOAD") .. u8' ОБНОВИТЬ', imgui.ImVec2(imgui.GetMiddleButtonX(1), 30 * MDS)) then
        updateScript(lmUrl, lmPath)
    end
    if imgui.Button(faicons("FORWARD") .. u8' ПРОПУСТИТЬ', imgui.ImVec2(imgui.GetMiddleButtonX(1), 30 * MDS)) then
        found_update[0] = not found_update[0]
        msg('Обновление скрипта пропущено')
    end
    imgui.End()
end
)
-- тех часть
ffi.cdef[[
    void _Z12AND_OpenLinkPKc(const char* link);
]]
function openLink(link)
    gta._Z12AND_OpenLinkPKc(link)
end

function main()
    while not isSampAvailable() do wait(0) end
    sampRegisterChatCommand('fish', function()
        Window[0] = not Window[0]
    end)
    
  
    while true do
        wait(0)
        if bot then
        if active then
            wait(waiting)
            sampProcessChatInput(cmd)
            active = false
        end
        end
    end
end

function msg(message)
    sampAddChatMessage('[fishHelper]: {FFFFFF}'..message, 0x2568BE)
end
function sendFrontendClick(interfaceid, id, subid, json)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt8(bs, 220)
    raknetBitStreamWriteInt8(bs, 63)
    raknetBitStreamWriteInt8(bs, interfaceid)
    raknetBitStreamWriteInt32(bs, id)
    raknetBitStreamWriteInt32(bs, subid)
    raknetBitStreamWriteInt32(bs, #json)
    raknetBitStreamWriteString(bs, json)
    raknetSendBitStreamEx(bs, 1, 10, 1)
    raknetDeleteBitStream(bs)
end

function sendInterfaceLoaded(interfaceid, bool)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt8(bs, 220)
    raknetBitStreamWriteInt8(bs, 66)
    raknetBitStreamWriteInt8(bs, interfaceid)
    raknetBitStreamWriteBool(bs, bool)
    raknetSendBitStreamEx(bs, 1, 10, 1)
    raknetDeleteBitStream(bs)
end

addEventHandler('onReceivePacket', function(id, bs)
    if not ini.autocaptcha.enabled then return end

    if id == 220 then
        raknetBitStreamIgnoreBits(bs, 8)
        local type = raknetBitStreamReadInt8(bs)
        
        if type == 84 then
            local interfaceid = raknetBitStreamReadInt8(bs)
            local subid = raknetBitStreamReadInt8(bs)
            --local len = raknetBitStreamReadInt32(bs)
            --local json = raknetBitStreamReadString(bs, len)
            
            if interfaceid == 81 then
                lua_thread.create(function()
                    math.randomseed(os.clock())
                    wait(math.random(2000,4000))
                    sendFrontendClick(81, 0, 0, "")
                end)
                return false
            end
            
        elseif type == 62 then
            local interfaceid = raknetBitStreamReadInt8(bs)
            local toggle = raknetBitStreamReadBool(bs)
            
            if interfaceid == 81 then
                sendInterfaceLoaded(81, toggle)
                return false
            end
        end
    end
end)
--- декор
function DarkTheme()
    imgui.SwitchContext()
    --==[ STYLE ]==--
    imgui.GetStyle().WindowPadding = imgui.ImVec2(5, 5)
    imgui.GetStyle().FramePadding = imgui.ImVec2(5, 5)
    imgui.GetStyle().ItemSpacing = imgui.ImVec2(5, 5)
    imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(2, 2)
    imgui.GetStyle().TouchExtraPadding = imgui.ImVec2(0, 0)
    imgui.GetStyle().IndentSpacing = 0
    imgui.GetStyle().ScrollbarSize = 10
    imgui.GetStyle().GrabMinSize = 10

    --==[ BORDER ]==--
    imgui.GetStyle().WindowBorderSize = 1
    imgui.GetStyle().ChildBorderSize = 1
    imgui.GetStyle().PopupBorderSize = 1
    imgui.GetStyle().FrameBorderSize = 1
    imgui.GetStyle().TabBorderSize = 1

    --==[ ROUNDING ]==--
    imgui.GetStyle().WindowRounding = 15
    imgui.GetStyle().ChildRounding = 9
    imgui.GetStyle().FrameRounding = 5
    imgui.GetStyle().PopupRounding = 5
    imgui.GetStyle().ScrollbarRounding = 5
    imgui.GetStyle().GrabRounding = 5
    imgui.GetStyle().TabRounding = 5

    --==[ ALIGN ]==--
    imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().SelectableTextAlign = imgui.ImVec2(0.5, 0.5)
    
    --==[ COLORS ]==--
    imgui.GetStyle().Colors[imgui.Col.Text]                   = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
    imgui.GetStyle().Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.13, 0.13, 0.13, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Border]                 = imgui.ImVec4(0.25, 0.25, 0.26, 0.54)
    imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(1, 1, 1, 0.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.51, 0.51, 0.51, 1.00)
    imgui.GetStyle().Colors[imgui.Col.CheckMark]              = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Button]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Header]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.47, 0.47, 0.47, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Separator]              = imgui.ImVec4(0.13, 0.13, 0.13, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(1.00, 1.00, 1.00, 0.25)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(1.00, 1.00, 1.00, 0.67)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(1.00, 1.00, 1.00, 0.95)
    imgui.GetStyle().Colors[imgui.Col.Tab]                    = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.28, 0.28, 0.28, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabActive]              = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocused]           = imgui.ImVec4(0.07, 0.10, 0.15, 0.97)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocusedActive]     = imgui.ImVec4(0.14, 0.26, 0.42, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.61, 0.61, 0.61, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(1.00, 0.43, 0.35, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.90, 0.70, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(1.00, 0.60, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(1.00, 0.00, 0.00, 0.35)
    imgui.GetStyle().Colors[imgui.Col.DragDropTarget]         = imgui.ImVec4(1.00, 1.00, 0.00, 0.90)
    imgui.GetStyle().Colors[imgui.Col.NavHighlight]           = imgui.ImVec4(0.26, 0.59, 0.98, 1.00)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingHighlight]  = imgui.ImVec4(1.00, 1.00, 1.00, 0.70)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingDimBg]      = imgui.ImVec4(0.80, 0.80, 0.80, 0.20)
    imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.00, 0.00, 0.00, 0.70)
end

--[[
label      - Текст при значении переменной false (Опционально)
label_true - Текст при значении переменной true (Опционально)
bool       - Переменная, которую будет менять кнопка (Требуется)
a_speed    - Скорость анимации (Опционально)
--]]
function imgui.ToggleButton(label, label_true, bool, a_speed)
    local p  = imgui.GetCursorScreenPos()
    local dl = imgui.GetWindowDrawList()
 
    local bebrochka = false

    local label      = label or ""                          -- Текст false
    local label_true = label_true or ""                     -- Текст true
    local h          = imgui.GetTextLineHeightWithSpacing() -- Высота кнопки
    local w          = h * 1.7                              -- Ширина кнопки
    local r          = h / 2                                -- Радиус кружка
    local s          = a_speed or 0.2                       -- Скорость анимации
 
    local function ImSaturate(f)
        return f < 0.0 and 0.0 or (f > 1.0 and 1.0 or f)
    end
 
    local x_begin = bool[0] and 1.0 or 0.0
    local t_begin = bool[0] and 0.0 or 1.0
 
    if LastTime == nil then
        LastTime = {}
    end
    if LastActive == nil then
        LastActive = {}
    end
 
    if imgui.InvisibleButton(label, imgui.ImVec2(w, h)) then
        bool[0] = not bool[0]
        LastTime[label] = os.clock()
        LastActive[label] = true
        bebrochka = true
    end

    if LastActive[label] then
        local time = os.clock() - LastTime[label]
        if time <= s then
            local anim = ImSaturate(time / s)
            x_begin = bool[0] and anim or 1.0 - anim
            t_begin = bool[0] and 1.0 - anim or anim
        else
            LastActive[label] = false
        end
    end
 
    local bg_color = imgui.ImVec4(x_begin * 0.13, x_begin * 0.9, x_begin * 0.13, imgui.IsItemHovered(0) and 0.7 or 0.9) -- Цвет прямоугольника
    local t_color  = imgui.ImVec4(1, 1, 1, x_begin) -- Цвет текста при false
    local t2_color = imgui.ImVec4(1, 1, 1, t_begin) -- Цвет текста при true
 
    dl:AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + w, p.y + h), imgui.GetColorU32Vec4(bg_color), r)
    dl:AddCircleFilled(imgui.ImVec2(p.x + r + x_begin * (w - r * 2), p.y + r), t_begin < 0.5 and x_begin * r or t_begin * r, imgui.GetColorU32Vec4(imgui.ImVec4(0.9, 0.9, 0.9, 1.0)), r + 5)
    dl:AddText(imgui.ImVec2(p.x + w + r, p.y + r - (r / 2) - (imgui.CalcTextSize(label).y / 4)), imgui.GetColorU32Vec4(t_color), label_true)
    dl:AddText(imgui.ImVec2(p.x + w + r, p.y + r - (r / 2) - (imgui.CalcTextSize(label).y / 4)), imgui.GetColorU32Vec4(t2_color), label)
    return bebrochka
end
function UI.Init()
    local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
    imgui.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory(0x14) .. '\\lib\\mimgui\\trebucbd.ttf', 16.0, nil, glyph_ranges)
    big = imgui.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory(0x14) .. '\\lib\\mimgui\\trebucbd.ttf', 29.0, _, glyph_ranges)
    texte = imgui.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory(0x14) .. '\\lib\\mimgui\\trebucbd.ttf', 19.0, _, glyph_ranges)
end

function imgui.ColSeparator(hex,trans)
    local r,g,b = tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
    if tonumber(trans) ~= nil and tonumber(trans) < 101 and tonumber(trans) > 0 then a = trans else a = 100 end
    imgui.PushStyleColor(imgui.Col.Separator, imgui.ImVec4(r/255, g/255, b/255, a/10))
    local colsep = imgui.Separator()
    imgui.PopStyleColor(1)
    return colsep
end
 
function imgui.TextColoredRGB(text)
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4
    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end
    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImVec4(r/255, g/255, b/255, a/255)
    end
    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else imgui.Text(u8(w)) end
        end
    end
    render_text(text)
end

imgui.OnInitialize(function()
    DarkTheme()
    local config = imgui.ImFontConfig()
    config.MergeMode = true
    config.PixelSnapH = true
    iconRanges = imgui.new.ImWchar[3](faicons.min_range, faicons.max_range, 0)
    imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(faicons.get_font_data_base85('solid'), 30, config, iconRanges)
    fa.Init()
    UI.Init()
end)


function sampev.onTextDrawSetString(id, text)
    
    if text:find('PRESS') then
        sampSendClickTextdraw(2069)
        sampSendClickTextdraw(65535)
        
        
    end
end


function sampev.onShowTextDraw(tdid, data) 
        if  data.modelId == 2663 and data.text == 'LD_SPAC:white' then
            badge.init = true
            badge.id = tdid
            msg('Приманка обнаружена')
        end
        if  data.modelId == 18875 and data.text == 'LD_SPAC:white' then
            echo.init = true
            echo.id = tdid
            msg('Эхолот обнаружен')
        end
 ---   if not echo.use] then
  ---      if data[flags] == sss and data.letterWidth == sss and data.letterHeight == sss and data.letterColor == sss and data.lineWidth == sss and data.lineHeight == sss and data.boxColor == sss and data.shadow == sss and data.outline == sss and data.backgroundColor == sss and data.style == sss and data.selectable == sss and data.modelId == sss and data.zoom == sss and data.color1 == sss and data.color2 == sss and data.text == sss then
       ---     echo.use] = true
          ---  echo.useid] = tdid
        ---    msg('Можно пользоваться')
       --- end
---    end
end
imgui.OnFrame(function() 
    return echoWindow[0] 
end,
function(player)
    local sw, sh = getScreenResolution()
    -- Установка позиции окна по центру экрана
    imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    
    -- Начало окна
    imgui.Begin(
        u8("Эхолокатор"),
        echoWindow, -- исправлено с echoWindo на echoWindow
        imgui.WindowFlags.NoResize +  imgui.WindowFlags.AlwaysAutoResize +
        imgui.WindowFlags.NoTitleBar
    )
    
    -- Кнопка "Обновить"
    if imgui.Button(u8('Обновить')) then
        lua_thread.create(echolot)
    end
    
    imgui.SameLine()
    -- Кнопка "Приманка"
    if imgui.Button(u8('Приманка')) then
        lua_thread.create(Badge)
    end
    
    imgui.SameLine()
    -- Кнопка "Сброс"
    if imgui.Button(u8('Сброс')) then
        FishTable = {}
        allfish = 0
    end
    
    imgui.Separator()
    -- Текст с количеством рыбы
    imgui.Text(u8('Рыба в зоне эхолота: ') .. tostring(allfish) .. u8(' ед.'))
    
    imgui.End()
end)


-------------
--


function echolot()
    sampProcessChatInput('/invent')
    wait(500)
    sampSendClickTextdraw(echo.id)
    wait(500)
    sampSendClickTextdraw(2302)
    wait(500)
    sampSendClickTextdraw(65535)  
end


function Badge()
    wait(800)
    sampProcessChatInput('/invent')
    wait(500)
    sampSendClickTextdraw(badge.id)
    wait(500)
    sampSendClickTextdraw(2302)
    wait(500)
    sampSendClickTextdraw(65535)  
end