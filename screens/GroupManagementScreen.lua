local mq = require('mq')
local imgui = require('ImGui')
local data = require('data')
local GroupManagementScreen = {}


function GroupManagementScreen.drawGroupManagementScreen(gui)
    if ImGui.Button("<", ImVec2(24, 24)) then
        if gui.GetActiveSubscreen() == 'SelectGroup' then
            gui.previousSubscreen = ''
            gui.SetActiveScreen("Welcome")
            return
        elseif gui.GetActiveSubscreen() == 'CreateGroup' then
            gui.selectedGroupIndex = 0
            gui.SelectedGroupName = nil
            gui.SetActiveSubscreen(gui.previousSubscreen)
        else
            gui.SetActiveSubscreen(gui.previousSubscreen)
        end
    end
    -- default to SelectGroup since we're
    if gui.previousSubscreen == '' then
        gui.SetActiveSubscreen("SelectGroup")
        gui.previousSubscreen = "SelectGroup"
    end

end

return GroupManagementScreen
