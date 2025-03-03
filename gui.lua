local mq                 = require('mq')
local imgui              = require('ImGui')
local data               = require('data')
local utils              = require('utils')
local createBotSubscreen = require('screens/createBotSubscreen')
local gui                = {}



local openPuppeteer, showPuppeteer = true, true
local selectedBotIndex = 0
local selectBotComboWidth = 350

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

local function drawWelcomeScreen()
    utils.CenterText("Welcome to Puppeteer.")
    local buttonWidth = 256
    ImGui.SetCursorPosX((ImGui.GetWindowSizeVec().x / 2) - buttonWidth)
    if ImGui.Button("Bot Management", ImVec2(buttonWidth, 24)) then
        gui.SetActiveScreen("BotManagement")
    end
    ImGui.SameLine()
    if ImGui.Button("Global Dashboard", ImVec2(buttonWidth, 24)) then
        selectedBotIndex = 0
        gui.SetActiveScreen("GlobalDashboard")
    end
end

local function drawBotManagementScreen()
    if ImGui.Button("<", ImVec2(32, 32)) then
        selectedBotIndex = 0
        gui.SetActiveScreen("Welcome")
    end
    ImGui.SameLine()
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
    if ImGui.Button("Create a Bot", ImVec2(buttonWidth, buttonSizeY)) then
        selectedBotIndex = 0
        gui.SetActiveSubscreen("CreateBot")
    end
    ImGui.SameLine()
    if ImGui.Button("Refresh Bot List", ImVec2(buttonWidth, buttonSizeY)) then gui.buttonStates.refreshBotList.activated = true end
    ImGui.SameLine()
    if ImGui.Button("Delete a Bot", ImVec2(buttonWidth, buttonSizeY)) then
        selectedBotIndex = 0
        gui.SetActiveScreen("DeleteBot")
    end
    if selectedBotIndex ~= 0 then
        gui.SetActiveSubscreen("BotDetails")
    end
end

local function drawGlobalDashboardScreen()

end

local function drawDeleteBotSubscreen()
end

local function drawBotDetailsSubscreen()
    local raceTexture = mq.FindTextureAnimation(data.CharacterBots[selectedBotIndex].Race .. 'Icon')
    ImGui.DrawTextureAnimation(raceTexture, 48, 48)
end


function gui.SetActiveScreen(screenName)
    -- Only one screen should be active, so starting by disabling all of them.
    for name, screen in pairs(gui.Screens) do
        for key, value in pairs(screen) do
            if type(value) == "boolean" and key:match("^show") then
                screen[key] = false
            end
        end
    end

    -- Now let's enable the screen we want.
    local selectedScreen = gui.Screens[screenName]
    if selectedScreen then
        for key in pairs(selectedScreen) do
            if key:match("^show") then
                selectedScreen[key] = true
                break
            end
        end
    else
        printf("Missing Screen: %s", screenName)
    end

    -- now we need to make sure all the subscreens are disabled.
    gui.SetActiveSubscreen(nil)
end

function gui.SetActiveSubscreen(subscreenName)
    -- same deal as screens, clear the slate and disable all of them.
    for name, subscreen in pairs(gui.Subscreens) do
        for key, value in pairs(subscreen) do
            if type(value) == "boolean" and key:match("^show") then
                subscreen[key] = false
            end
        end
    end
    -- now let's make sure this subscreen exists and matches it's parent
    if subscreenName then
        local selectedSubscreen = gui.Subscreens[subscreenName]
        if selectedSubscreen then
            local parentScreen = selectedSubscreen.parent
            if gui.Screens[parentScreen] and gui.Screens[parentScreen]["show" .. parentScreen .. "Screen"] then
                -- Activate subscreen only if its parent screen is active
                for key in pairs(selectedSubscreen) do
                    if key:match("^show") then
                        selectedSubscreen[key] = true
                        break
                    end
                end
            else
                print("Error: Parent Screen does not match subscreen parent.")
            end
        else
            printf("Missing Subscreen: %s", subscreenName)
        end
    end
end

function gui.ScreenManager()
    -- Find and draw the active screen
    for name, screen in pairs(gui.Screens) do
        for key, value in pairs(screen) do
            if type(value) == "boolean" and value and key:match("^show") then
                if screen.drawFunction then
                    screen.drawFunction()
                end
                break -- Only one active screen at a time
            end
        end
    end

    -- Find and draw the active subscreen (only if its parent screen is active)
    for name, subscreen in pairs(gui.Subscreens) do
        local parentScreen = subscreen.parent
        if gui.Screens[parentScreen] and gui.Screens[parentScreen]["show" .. parentScreen .. "Screen"] then
            for key, value in pairs(subscreen) do
                if type(value) == "boolean" and value and key:match("^show") then
                    if subscreen.drawFunction then
                        subscreen.drawFunction()
                    end
                    break -- Only one active subscreen at a time
                end
            end
        end
    end
end

function gui.ButtonStateManager()
    for index, value in pairs(gui.GetButtonState()) do
        if value ~= nil then
            if value.activated and value.guiButton then
                value.callback()
                gui.buttonStates[index].activated = false
            end
        end
    end
end

function gui.guiLoop()
    showPuppeteer, openPuppeteer = ImGui.Begin("Puppeteer", openPuppeteer)
    if showPuppeteer then
        ImGui.SetWindowSize("Puppeteer", ImVec2(512, 768), ImGuiCond.Always)

        gui.ScreenManager()

        gui.ButtonStateManager()
    end
    ImGui.End()
end

gui.Screens = {
    Welcome = { showWelcomeScreen = true, drawFunction = drawWelcomeScreen },
    BotManagement = { showBotManagementScreen = false, drawFunction = drawBotManagementScreen },
    GlobalDashboard = { showGlobalDashboardScreen = false, drawFunction = drawGlobalDashboardScreen }
}
gui.Subscreens = {
    CreateBot = { parent = "BotManagement", showCreateBotSubscreen = false, drawFunction = createBotSubscreen.drawCreateBotSubscreen },
    DeleteBot = { parent = "BotManagement", showDeleteBotSubscreen = false, drawFunction = drawDeleteBotSubscreen },
    BotDetails = { parent = "BotManagement", showBotDetailsSubscreen = false, drawFunction = drawBotDetailsSubscreen },
}

gui.buttonStates = {
    refreshBotList = { activated = false, guiButton = false, callback = data.refreshBotListButton },
}




return gui
