local mq = require('mq')
local imgui = require('ImGui')

local GroupManagementScreen = {}


function GroupManagementScreen.drawGroupManagementScreen(gui)
    if ImGui.Button("<", ImVec2(24, 24)) then
        if gui.GetActiveSubscreen() == 'SelectGroup' then
            gui.previousSubscreen = ''
            gui.SetActiveScreen("Welcome")
            return
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
