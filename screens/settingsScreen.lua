local mq             = require('mq')
local imgui          = require('ImGui')
local utils          = require('utils')
local data           = require('data')
local settingsScreen = {}


local autoDash
function settingsScreen.drawSettingsScreen(gui)
    if ImGui.Button("<", ImVec2(24, 24)) then
        gui.SetActiveScreen("Welcome")
    end
    ImGui.SameLine()
    utils.CenterText("Puppeteer Settings")
    ImGui.NewLine()
    for index, value in pairs(data.GetSettingValue()) do
        if type(value) == 'boolean' then
            ImGui.Text(index)
            ImGui.SameLine()
            local settingValue, clicked = ImGui.Checkbox(index, value)
            if clicked then
                data.UpdateSettingValue(index, not value)
            end
        end
    end
end

return settingsScreen
