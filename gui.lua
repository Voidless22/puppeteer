local mq    = require('mq')
local imgui = require('ImGui')
local data  = require('data')
local utils = require('utils')
local gui   = {}


local function drawBotInfo()
end
local function createBotButton()

end
local function deleteBotButton()
end


gui.buttonStates = {
    refreshBotList = { activated = false, guiButton = false, callback = data.refreshBotListButton },
    createBot = { activated = false, guiButton = true, callback = createBotButton },
    deleteBot = { activated = false, guiButton = false, callback = deleteBotButton },
}

function gui.GetButtonState(button)
    if button ~= nil then
        return gui.buttonStates[button]
    else
        return gui.buttonStates
    end
end

function gui.SetButtonState(button, state)
    if button == nil then
        printf('invalid button supplied to set state of.')
        return
    end
    if state ~= true and state ~= false then
        printf("Invalid state toggle")
        return
    end
    gui.buttonStates[button].activated = state
end

local openPuppeteer, showPuppeteer = true, true
local showWelcomeScreen = true
local selectedBotIndex = 0
local selectBotComboWidth = 350



local function drawWelcomeScreen()
    utils.CenterText("Welcome to Puppeteer.")
    utils.CenterText("Select or Create a Bot...")
    ImGui.PushItemWidth(selectBotComboWidth)
    utils.CenterItem()
    selectedBotIndex = ImGui.Combo("##BotList", selectedBotIndex, data.GetBotNameList())
    ImGui.PopItemWidth()

    local buttonPadding = 4
    local buttonSizeY = 24
    local startPoint = (ImGui.GetWindowSizeVec().x - selectBotComboWidth) / 2
    local buttonWidth = (selectBotComboWidth / 3) - buttonPadding

    ImGui.SetCursorPosX(startPoint - (buttonPadding / 2))
    if ImGui.Button("Create a Bot", ImVec2(buttonWidth, buttonSizeY)) then gui.buttonStates.createBot.activated = true end
    ImGui.SameLine()
    if ImGui.Button("Refresh Bot List", ImVec2(buttonWidth, buttonSizeY)) then gui.buttonStates.refreshBotList.activated = true end
    ImGui.SameLine()
    if ImGui.Button("Delete a Bot", ImVec2(buttonWidth, buttonSizeY)) then gui.buttonStates.deleteBot.activated = true end

    if selectedBotIndex ~= 0 then
        drawBotInfo()
    end
end

function gui.guiLoop()
    showPuppeteer, openPuppeteer = ImGui.Begin("Puppeteer", openPuppeteer)
    if showPuppeteer then
        ImGui.SetWindowSize("Puppeteer", ImVec2(512, 768), ImGuiCond.Always)
        if showWelcomeScreen then
            drawWelcomeScreen()
        end
        ImGui.Separator()

        for index, value in pairs(gui.GetButtonState()) do
            if value ~= nil then
                if value.activated and value.guiButton then
                    value.callback()
                    gui.buttonStates[index].activated = false
                end
            end
        end
    end
    ImGui.End()
end

return gui
