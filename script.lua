local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ScrollingFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local TextBox = Instance.new("TextBox")

-- Настройка GUI (минимализм)
ScreenGui.Parent = game:GetService("CoreGui")
MainFrame.Name = "CustomChat"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Position = UDim2.new(0.05, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0.3, 0, 0.4, 0)
MainFrame.Active = true
MainFrame.Draggable = true

ScrollingFrame.Parent = MainFrame
ScrollingFrame.Size = UDim2.new(1, 0, 0.85, 0)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 10, 0)
ScrollingFrame.ScrollBarThickness = 4

UIListLayout.Parent = ScrollingFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

TextBox.Parent = MainFrame
TextBox.Position = UDim2.new(0, 0, 0.85, 0)
TextBox.Size = UDim2.new(1, 0, 0.15, 0)
TextBox.PlaceholderText = "Пиши сюда (без цензуры для своих)..."

-- Функция добавления сообщения в GUI
local function addMessage(sender, text)
    local label = Instance.new("TextLabel")
    label.Parent = ScrollingFrame
    label.Size = UDim2.new(1, 0, 0.05, 0)
    label.Text = "[" .. sender .. "]: " .. text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    ScrollingFrame.CanvasPosition = Vector2.new(0, ScrollingFrame.CanvasSize.Y.Offset)
end

-- Отправка сообщения
TextBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local msg = TextBox.Text
        -- Отправляем в обычный чат (тут будет цензура для всех остальных)
        game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
        TextBox.Text = ""
    end
end)

-- Перехват сообщений сервера (включая обычных игроков)
game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.OnMessageDoneFiltering.OnClientEvent:Connect(function(data)
    -- data.FromSpeaker - кто отправил, data.Message - текст
    addMessage(tostring(data.FromSpeaker), tostring(data.Message))
end)

addMessage("SYSTEM", "Кастомный чат загружен!")
