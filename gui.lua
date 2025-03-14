local mq                                   = require('mq')
local imgui                                = require('ImGui')
local data                                 = require('data')
local utils                                = require('utils')
local globalDashbar                        = require('globalDashbar')

-- Screens
local welcomeScreen                        = require('screens/welcomeScreen')
local botManagementScreen                  = require('screens/botManagementScreen')
local dashboardScreen                      = require('screens/dashboardScreen')
local CreateBotScreen                      = require('screens/CreateBotScreen')
local GroupManagementScreen                = require('screens/GroupManagementScreen')
local itemUpgradeWindow                    = require('screens/itemUpgradeWindow')
local settingsScreen                       = require('screens/settingsScreen')
local stanceSelectWindow                   = require('screens/stanceSelectWindow')

-- Subscreens
local selectBotSubscreen                   = require('subscreens/selectBotSubscreen')
local botConfigurationSubscreen            = require('subscreens/botConfigurationSubscreen')
local selectGroupSubscreen                 = require('subscreens/selectGroupSubscreen')
local createGroupSubscreen                 = require('subscreens/createGroupSubscreen')

local buttonState                          = require('buttonState')
local gui                                  = {}

gui.openPuppeteer, gui.showPuppeteer         = false, false
local openGlobalDashbar, showGlobalDashbar = true, true
gui.botConfigSelectedBotIndex              = 0
gui.selectedGroupIndex                     = 0
gui.selectedGroupName                      = nil

local FLT_MIN, FLT_MAX                     = mq.NumericLimits_Float()

gui.windowSize                             = ImVec2(512, 768)

gui.previousSubscreen                      = ''


gui.Screens = {
    Welcome = { showWelcomeScreen = true, drawFunction = function() welcomeScreen.DrawWelcomeScreen(gui) end },
    BotManagement = {
        showBotManagementScreen = false,
        drawFunction = function()
            botManagementScreen
                .DrawBotManagementScreen(gui)
        end
    },
    Dashboard = { showDashboardScreen = false, drawFunction = function() dashboardScreen.DrawDashboardScreen(gui) end },
    CreateBot = { showCreateBotScreen = false, drawFunction = function() CreateBotScreen.drawCreateBotScreen(gui) end },
    GroupManagement = {
        showGroupManagementScreen = false,
        drawFunction = function()
            GroupManagementScreen.drawGroupManagementScreen(gui)
        end
    },
    Settings = { showSettingsScreen = false, drawFunction = function() settingsScreen.drawSettingsScreen(gui) end }
}
gui.Subscreens = {
    SelectBot = {
        parent = "BotManagement",
        showSelectBotSubscreen = false,
        drawFunction = function()
            selectBotSubscreen.drawSelectBotSubscreen(gui)
        end
    },
    SelectGroup = {
        parent = "GroupManagement",
        showSelectGroupSubscreen = false,
        drawFunction = function() selectGroupSubscreen.drawSelectGroupSubscreen(gui) end
    },
    CreateGroup = {
        parent = "GroupManagement",
        showCreateGroupSubscreen = false,
        drawFunction = function() createGroupSubscreen.drawCreateGroupSubscreen(gui, gui.selectedGroupName) end
    },
    BotConfiguration = {
        parent = "BotManagement",
        showBotConfigurationSubscreen = false,
        drawFunction = function()
            botConfigurationSubscreen.drawBotConfigurationSubscreen(gui.botConfigSelectedBotIndex, gui)
        end
    },
}

function gui.clearGroupManagementSelections()
    gui.selectedGroupIndex = 0
    gui.selectedGroupName  = nil
end

function gui.ToggleShowGlobalDashbar()
    openGlobalDashbar = not openGlobalDashbar
end

function gui.DrawGlobalDashbarWindow()
    if openGlobalDashbar then -- Only try to render if the window should be shown
        openGlobalDashbar, showGlobalDashbar = ImGui.Begin("Global Dashbar", openGlobalDashbar)
        if showGlobalDashbar then
            globalDashbar.DrawGlobalDashbar(gui)
        end
        ImGui.End()
    end
end

function gui.ToggleWindowShow()
    gui.openPuppeteer = not gui.openPuppeteer
end

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

function gui.GetActiveScreen()
    for name, screen in pairs(gui.Screens) do
        for key, value in pairs(screen) do
            if type(value) == "boolean" and key:match("^show") and value then
                return name, screen -- Return the active screen name and its table
            end
        end
    end
    return nil -- No active screen found
end

function gui.SetActiveScreen(screenName)
    -- step one is clear the subscreens.
    for name, subscreen in pairs(gui.Subscreens) do
        for key, value in pairs(subscreen) do
            if type(value) == "boolean" and key:match("^show") then
                subscreen[key] = false
            end
        end
    end
    gui.previousSubscreen = ''

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

function gui.SetSelectedBot(botIndex)
    gui.botConfigSelectedBotIndex = botIndex
end

function gui.guiLoop()
    local potentialUpgrades = data.GetPotentialBotItemUpgrades()
    local doShowUpgradePopup = #potentialUpgrades > 0

    if gui.openPuppeteer then -- Only try to render if the window should be shown
        gui.openPuppeteer, gui.showPuppeteer = ImGui.Begin("Puppeteer", gui.openPuppeteer)

        if gui.showPuppeteer then
            ImGui.SetWindowSize("Puppeteer", ImVec2(512, 768), ImGuiCond.Appearing)
            gui.ScreenManager()
        end

        ImGui.End()
    end
    if doShowUpgradePopup then
        itemUpgradeWindow.drawItemUpgradeWindow()
    end
    if data.GetShouldOpenStanceSelect() then
        stanceSelectWindow.DrawStanceSelectWindow()
    end

    gui.DrawGlobalDashbarWindow()
end

return gui
