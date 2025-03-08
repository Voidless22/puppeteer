local mq                        = require('mq')
local imgui                     = require('ImGui')
local data                      = require('data')
local utils                     = require('utils')
local welcomeScreen = require('screens/welcomeScreen')
local botManagementScreen = require('screens/botManagementScreen')
local dashboardScreen = require('screens/dashboardScreen')
local CreateBotScreen       = require('screens/CreateBotScreen')

local selectBotSubscreen    = require('subscreens/selectBotSubscreen')
local botConfigurationSubscreen = require('subscreens/botConfigurationSubscreen')

local gui                       = {}

local openPuppeteer, showPuppeteer = true, true

gui.selectedBotIndex = 0
gui.windowSize = ImVec2(512,768)
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

gui.Screens = {
    Welcome = { showWelcomeScreen = true, drawFunction = function() welcomeScreen.DrawWelcomeScreen(gui) end },
    BotManagement = { showBotManagementScreen = false, drawFunction = function() botManagementScreen.DrawBotManagementScreen(gui) end },
    Dashboard = { showDashboardScreen = false, drawFunction = function() dashboardScreen.DrawDashboardScreen(gui) end },
    CreateBot = { showCreateBotScreen = false, drawFunction = function() CreateBotScreen.drawCreateBotScreen(gui) end}
}
gui.Subscreens = {
    SelectBot = { parent = "BotManagement", showSelectBotSubscreen = false, drawFunction = function() selectBotSubscreen.drawSelectBotSubscreen(gui) end },

    BotConfiguration = { parent = "BotManagement", showBotConfigurationSubscreen = false, drawFunction = function() botConfigurationSubscreen.drawBotConfigurationSubscreen(gui.selectedBotIndex, gui) end},
}

gui.buttonStates = {
    refreshBotList = { activated = false, guiButton = false, callback = data.refreshBotListButton },
}

function gui.GetActiveSubscreen()
    for name, subscreen in pairs(gui.Subscreens) do
        for key, value in pairs(subscreen) do
            if type(value) == "boolean" and key:match("^show") and value then
                return name, subscreen -- Return the active subscreen name and its table
            end
        end
    end
    return nil -- No active subscreen found
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
                        if subscreen.args ~= nil then
                            subscreen.drawFunction(unpack(subscreen.args()))
                        else
                            subscreen.drawFunction()
                        end

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






return gui
