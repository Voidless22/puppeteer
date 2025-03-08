local mq = require('mq')
local imgui = require('ImGui')
local utils = require('utils')
--local gui = require('gui')
local welcomeScreen = {}

local welcomeButtons = {
    { text = 'Group/Raid Management',    callback = function(gui) gui.SetActiveScreen("PartyManagement") end },
    { text = 'Dashboard',                callback = function(gui) gui.SetActiveScreen("Dashboard") end },
    { text = 'Modify Bot Settings',      callback = function(gui) gui.SetActiveScreen("BotManagement") end },
    { text = 'Create A Bot',             callback = function(gui) gui.SetActiveScreen("CreateBot") end },
    { text = 'Customize Bot Appearance', screen = 'CustomizeBot' },
    { text = 'Puppeteer Settings',       screen = 'PuppeteerSettings' },

}

local function getMaxButtonTextSize(textTable)
    local maxTextSize = 0
    for index, value in ipairs(textTable) do
        if ImGui.CalcTextSize(value.text) > maxTextSize then
            maxTextSize = ImGui.CalcTextSize(value.text)
        end
    end
    return maxTextSize + 6
end

local function CreateButtonGrid(gui, buttonSize, buttonPadding, buttonTable)
    local windowWidth = ImGui.GetWindowSizeVec().x
    local columnCount = math.floor((windowWidth - (buttonPadding * 2)) / (buttonSize.x + buttonPadding))
    ImGui.SetCursorPosX(windowWidth / #buttonTable - buttonPadding )
    local StartCursorPos = ImGui.GetCursorPosVec()

    local currentColumn = 1
    local currentRow = 1
    
    for _, value in ipairs(buttonTable) do
        local lastCursorPos = ImGui.GetCursorPosVec()
        if ImGui.Button(value.text, ImVec2(buttonSize.x, buttonSize.y)) then
            printf("Button: %s Selected", value.text)
            value.callback(gui)
        end
        if currentColumn < columnCount then
            ImGui.SetCursorPos(ImVec2((lastCursorPos.x + buttonSize.x + buttonPadding), lastCursorPos.y))
            currentColumn = currentColumn + 1
        elseif currentColumn >= columnCount then
            ImGui.SetCursorPos(ImVec2(StartCursorPos.x, (lastCursorPos.y + buttonSize.y + buttonPadding)))
            currentRow = currentRow + 1
            currentColumn = 1
        end
    end
end


function welcomeScreen.DrawWelcomeScreen(gui)
    utils.CenterText("Welcome to Puppeteer.")
    local maxTextSize = getMaxButtonTextSize(welcomeButtons)
    ImGui.SetCursorPosX(16)
    CreateButtonGrid(gui,ImVec2(maxTextSize, 42), 4, welcomeButtons)
end

return welcomeScreen
