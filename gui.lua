local mq                                         = require('mq')
local imgui                                      = require('ImGui')
local data                                       = require('data')
local utils                                      = require('utils')
local globalDashbar                              = require('globalDashbar')

-- Screens
local welcomeScreen                              = require('screens/welcomeScreen')
local botManagementScreen                        = require('screens/botManagementScreen')
local dashboardScreen                            = require('screens/dashboardScreen')
local CreateBotScreen                            = require('screens/CreateBotScreen')
local GroupManagementScreen                      = require('screens/GroupManagementScreen')

-- Subscreens
local selectBotSubscreen                         = require('subscreens/selectBotSubscreen')
local botConfigurationSubscreen                  = require('subscreens/botConfigurationSubscreen')
local selectGroupSubscreen                       = require('subscreens/selectGroupSubscreen')
local createGroupSubscreen                       = require('subscreens/createGroupSubscreen')

local gui                                        = {}

local openPuppeteer, showPuppeteer               = true, true
local openGlobalDashbar, showGlobalDashbar       = false, true
local openPossibleUpgrades, showPossibleUpgrades = false, true
gui.botConfigSelectedBotIndex                    = 0
gui.selectedGroupIndex                           = 0
gui.selectedGroupName                            = nil

local FLT_MIN, FLT_MAX                           = mq.NumericLimits_Float()

gui.windowSize                                   = ImVec2(512, 768)

gui.previousSubscreen                            = ''


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
            GroupManagementScreen
                .drawGroupManagementScreen(gui)
        end
    }
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

function gui.drawItemUpgradesPopup()
    local buttonWidth = 96
    local buttonSizeY = 48
    local wndSize = ImVec2(512, 512)
    local viewport = ImGui.GetMainViewport()
    local center = viewport.Pos + (viewport.Size * 0.5) - (wndSize / 2)

    ImGui.SetNextWindowPos(center, ImGuiCond.Appearing, ImVec2(0.5, 0.5)) -- Centered
    --ImGui.SetNextWindowSizeConstraints(ImVec2(200, 0), ImVec2(FLT_MAX, FLT_MAX))
    openPossibleUpgrades, showPossibleUpgrades = ImGui.Begin("Possible Upgrades", openPossibleUpgrades,
        bit32.bor(ImGuiWindowFlags.NoResize))
    if showPossibleUpgrades then
        ImGui.SetWindowPos((viewport.Size / 2) - wndSize / 2, ImGuiCond.Once)
        ImGui.SetWindowSize(512, 512, ImGuiCond.Once)
        utils.CenterText("Potential Gear Upgrades")
        utils.BetterNewLine(10)
        if imgui.BeginTable('##potentialUpgrades', 5, ImGuiTableFlags.Borders) then
            imgui.TableSetupColumn('Bot')
            imgui.TableSetupColumn('Slot')
            imgui.TableSetupColumn('Current Item')
            imgui.TableSetupColumn('Projected Item')
            imgui.TableSetupColumn("Swap Item")
            imgui.TableSetupScrollFreeze(0, 1) -- Make row always visible

            -- Display data
            imgui.TableHeadersRow()
            local botData = data.GetBotData()
            for index, value in ipairs(data.GetPotentialBotItemUpgrades()) do
                imgui.TableNextRow()
                imgui.TableNextColumn()
                imgui.Text(value.botName)
                imgui.TableNextColumn()
                imgui.Text(value.itemSlot)
                imgui.TableNextColumn()
                if imgui.SmallButton('Inspect##Current' .. index) then
                    local links = mq.ExtractLinks(value.line)
                    mq.ExecuteTextLink(links[2])
                end
                imgui.TableNextColumn()
                if imgui.SmallButton('Inspect##Projected' .. index) then
                    --  local projectedItem = mq.TLO.FindItem(value.upgradeItem).ItemLink('CLICKABLE')()
                    --if projectedItem then
                    --local projectedItemLink = mq.ExtractLinks(projectedItem)
                    --mq.ExecuteTextLink(projectedItemLink[1])
                    mq.TLO.FindItem(value.upgradeItem).Inspect()
                    --end
                end
                ImGui.TableNextColumn()
                if ImGui.SmallButton('Swap##' .. index) then
                    if not mq.TLO.Cursor() then
                        local packSlot = mq.TLO.FindItem(value.upgradeItem).ItemSlot()
                        local subSlot = mq.TLO.FindItem(value.upgradeItem).ItemSlot2()
                        print(packSlot)
                        print(subSlot)
                        mq.cmdf('/itemnotify in pack%i %i leftmouseup', (packSlot-22), (subSlot + 1))
                    end
                    mq.cmdf('/say ^ig byname %s', value.botName)
                end
            end
            imgui.EndTable()
        end
        ImGui.NewLine()
        ImGui.SetCursorPosX((ImGui.GetWindowSizeVec().x / 2) - (buttonWidth / 2))
        if ImGui.Button("All Done!##closeupgradepopup", ImVec2(buttonWidth, buttonSizeY)) then
            data.ClearPotentialBotItemUpgrades()
            ImGui.CloseCurrentPopup()
        end

        ImGui.End()
    end
end

function gui.ToggleWindowShow()
    openPuppeteer = not openPuppeteer
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
    if openPuppeteer then -- Only try to render if the window should be shown
        openPuppeteer, showPuppeteer = ImGui.Begin("Puppeteer", openPuppeteer)
        local potentialUpgrades = data.GetPotentialBotItemUpgrades()
        local doShowUpgradePopup = #potentialUpgrades > 0

        if showPuppeteer then
            ImGui.SetWindowSize("Puppeteer", ImVec2(512, 768), ImGuiCond.Always)
            gui.ScreenManager()
        end
        if doShowUpgradePopup then
            gui.drawItemUpgradesPopup()
        end
        ImGui.End()
    end

    gui.DrawGlobalDashbarWindow()
end

return gui
