local mq = require('mq')
local imgui = require('ImGui')
local utils = require('utils')
local data = require('data')
local botManagementScreen = {}


function botManagementScreen.DrawBotManagementScreen(gui)
    if ImGui.Button("<", ImVec2(24, 24)) then
        gui.botConfigSelectedBotIndex = 0
        if gui.GetActiveSubscreen() == 'SelectBot' then
            gui.SetActiveScreen("Welcome")
            return
        end

        if gui.GetActiveSubscreen() == 'BotConfiguration' then
            gui.SetActiveSubscreen("SelectBot")
        end
    end
    if gui.botConfigSelectedBotIndex == 0 and gui.GetActiveScreen("BotManagement") then
        ImGui.SameLine()
        gui.SetActiveSubscreen("SelectBot")
    else
        ImGui.NewLine()
        gui.SetActiveSubscreen("BotConfiguration")
    end
end

return botManagementScreen
