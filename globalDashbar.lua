local mq = require('mq')
local imgui = require('ImGui')
local globalDashbar = {}

local buttonOuterPadding = 8
local minButtonSize = 48
local buttonSpacing = 8
local totalButtonsPerPage = 24

local function defaultButtonPressed(buttonName)
    printf("Button Pressed")
end

--[[
default global buttons - default to spawned unless valid target for actionables
- attack spawned
- hold attacks (need to setup as toggle, on disable call release spawned)
- botsummon target or spawned
- follow target or self (need to setup as toggle, on disable call follow off or whatever)

]] 


local defaultButtonTable = {}
for i = 1, totalButtonsPerPage do
    defaultButtonTable[i] = { Name = string.format("%s", i), callback = defaultButtonPressed, args = { string.format("%s", i) } }
end

local buttonTable = defaultButtonTable

function globalDashbar.ButtonStateManager()
    for index, value in pairs(buttonTable) do
        if value ~= nil then
            if value.activated and value.guiButton then
                if value.args ~= nil then
                    value.callback(unpack(value.args))
                end
                value.callback()
            end
        end
    end
end

local function drawButtonGrid()
    local windowWidth = ImGui.GetWindowSizeVec().x
    local columnCount = math.floor((windowWidth - (buttonOuterPadding * 2)) / (minButtonSize + buttonSpacing))
    local rowCount = math.ceil(totalButtonsPerPage / columnCount)  -- Calculate the number of rows correctly
    local totalRowSize = (buttonOuterPadding * 4) + ((minButtonSize + buttonSpacing) * rowCount)  -- Total height of all rows
    local currentColumn = 1
    
    -- Set the window size to fit the total height needed for the grid
    if ImGui.GetWindowSizeVec().y > totalRowSize then
        ImGui.SetWindowSize(ImGui.GetWindowSizeVec().x, totalRowSize)
    end
    
    for index, value in ipairs(buttonTable) do
        local prevCursorPos = ImGui.GetCursorPosVec()
        
        if ImGui.Button(value.Name, ImVec2(minButtonSize, minButtonSize)) then
            printf("Button: %s Selected", value.Name)
        end

        if currentColumn < columnCount then
            ImGui.SameLine(0, buttonSpacing)
            currentColumn = currentColumn + 1
        else
            ImGui.NewLine()
            ImGui.SetCursorPosY(prevCursorPos.y + (minButtonSize + buttonSpacing))
            currentColumn = 1
        end
    end
end
function globalDashbar.DrawGlobalDashbar(gui)
    drawButtonGrid()
    globalDashbar.ButtonStateManager()
end

return globalDashbar
