-- Custom Chat v2.0
-- Кастомный чат без цензуры с защитой от ошибок HTTP

local Players = game:GetService("Players")
local ChatService = game:GetService("Chat")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui.CustomChat.Frame")

local player = Players.LocalPlayer

-- Проверка HttpService
if not HttpService:IsHttpEnabled() then
    warn("HttpService отключён. Включите в настройках игры.")
    return
end

-- Создание GUI
local chatGui = Instance.new("ScreenGui")
chatGui.Name = "CustomChat"
chatGui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Parent = chatGui
frame.Position = UDim2.new(0.02, 0, 0.7, 0)
frame.Size = UDim2.new(0.3, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(60, 60, 60)
frame.CornerRadius = UDim.new(0, 8)
frame.Visible = true

-- Заголовок
local title = Instance.new("TextLabel")
title.Parent = frame
title.Position = UDim2.new(0, 0, 0, -30)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Custom Chat [No Censor]"
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.BorderSizePixel = 0
title.TextSize = 16

-- Область сообщений
local messages = Instance.new("TextBox")
messages.Parent = frame
messages.Position = UDim2.new(0.02, 0, 0.1, 0)
messages.Size = UDim2.new(0.96, 0, 0.75, 0)
messages.MultiLine = true
messages.ReadOnly = true
messages.Text = ""
messages.Font = Enum.Font.Code
messages.TextColor3 = Color3.fromRGB(220, 220, 220)
messages.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
messages.TextSize = 14
messages.BorderSizePixel = 0
messages.ClearTextOnFocus = false

-- Поле ввода
local input = Instance.new("TextBox")
input.Parent = frame
input.Position = UDim2.new(0.02, 0, 0.87, 0)
input.Size = UDim2.new(0.96, 0, 0.12, 0)
input.PlaceholderText = "Напишите сообщение..."
input.Font = Enum.Font.Code
input.TextColor3 = Color3.fromRGB(255, 255, 255)
input.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
input.TextSize = 14
input.BorderSizePixel = 1
input.BorderColor3 = Color3.fromRGB(70, 70, 70)

-- Кнопка отправки
local sendBtn = Instance.new("TextButton")
sendBtn.Parent = frame
sendBtn.Position = UDim2.new(0.02, 0, 0.98, 0)
sendBtn.Size = UDim2.new(0.96, 0, 0.04, 0)
sendBtn.Text = "Send"
sendBtn.Font = Enum.Font.GothamSemibold
sendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
sendBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 220)
sendBtn.BorderSizePixel = 0
sendBtn.TextSize = 14

-- Буфер сообщений
local messageBuffer = {}

-- Функция добавления сообщения
local function addMessage(author, text)
    local line = string.format("[%s] %s", author, text)
    table.insert(messageBuffer, line)
    messages.Text = table.concat(messageBuffer, "\n") .. "\n"
    
    -- Ограничение до 100 сообщений
    if #messageBuffer > 100 then
        table.remove(messageBuffer, 1)
    end
end

-- Перехват входящих сообщений
ChatService.OnMessageReceived:Connect(function(text, fromSpeaker)
    local speaker = Players:FindFirstChild(fromSpeaker)
    if speaker then
        addMessage(speaker.Name, text)
    else
        addMessage("Unknown", text)
    end
end)

-- Отправка сообщения
sendBtn.MouseButton1Click:Connect(function()
    local text = input.Text:trim()
    if text ~= "" then
        ChatService:Chat(player, text)
        addMessage(player.Name, text)
        input.Text = ""
    end
end)

-- Отправка по Enter
input:GetPropertyChangedSignal("Text"):Connect(function()
    if input.Text:sub(-1) == "\n" then
        sendBtn.MouseButton1Click:Fire()
        input.Text = input.Text:sub(1, -2)  -- Удаляем \n
    end
end)

-- Загрузка истории чата
for _, msg in ipairs(ChatService:GetMessageHistory()) do
    addMessage(msg.SpeakerName, msg.Message)
end

-- Приветственное сообщение
addMessage("SYSTEM", "Custom Chat активирован. Пишите без цензуры!")

-- Дополнительная защита от ошибок
local function safeHttpGet(url)
    local success, response = pcall(function()
        return HttpService:GetAsync(url, false, {
            ["User-Agent"] = "Roblox"
        })
    end)
    
    if success then
        return response
    else
        warn("HTTP-ошибка:", response)
        return nil
    end
end

-- Пример использования (если нужно загружать скрипты извне)
-- local scriptCode = safeHttpGet("https://raw.githubusercontent.com/YourUsername/Custom-Chat-Script/main/script.lua")
-- if scriptCode then
--     loadstring(scriptCode)()
-- end
