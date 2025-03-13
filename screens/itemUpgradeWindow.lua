local mq = require('mq')
local imgui = require('ImGui')
local utils = require('utils')
local data = require('data')

local itemUpgradeWindow = {}

local openPossibleUpgrades, showPossibleUpgrades = false, true

function itemUpgradeWindow.drawItemUpgradeWindow()
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
        local upgradeData = data.GetPotentialBotItemUpgrades()
        local upgradeItem = mq.TLO.FindItem(upgradeData[1].upgradeItem)
        ImGui.SetWindowPos((viewport.Size / 2) - wndSize / 2, ImGuiCond.Once)
        ImGui.SetWindowSize(512, 512, ImGuiCond.Once)
        utils.CenterText("Potential Gear to Upgrade To")
        --        utils.CenterItem()
        ImGui.SetCursorPosX((ImGui.GetWindowSizeVec().x / 2) - (ImGui.CalcTextSizeVec(upgradeItem.Name()).x / 2))
        if ImGui.Button(upgradeItem.Name() .. '##ugpradeItem') then
            upgradeItem.Inspect()
        end
        utils.BetterNewLine(10)
        if imgui.BeginTable('##potentialUpgrades', 5, bit32.bor(ImGuiTableFlags.Borders, ImGuiTableFlags.Resizable)) then
            imgui.TableSetupColumn('Bot',ImGuiTableColumnFlags.WidthAlwaysAutoResize)
            imgui.TableSetupColumn('Slot',ImGuiTableColumnFlags.WidthAlwaysAutoResize)
            imgui.TableSetupColumn('Current Item',ImGuiTableColumnFlags.WidthAlwaysAutoResize)
            imgui.TableSetupColumn('Projected Item',ImGuiTableColumnFlags.WidthAlwaysAutoResize)
            imgui.TableSetupColumn("Swap Item",ImGuiTableColumnFlags.WidthAlwaysAutoResize)
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
                local links = mq.ExtractLinks(value.line)
                if imgui.SmallButton(links[2].text .. '##Current' .. index) then
                    mq.ExecuteTextLink(links[2])
                end
                imgui.TableNextColumn()
                if imgui.SmallButton("Stat Diff##" .. index) then

                end
                ImGui.TableNextColumn()
                if ImGui.SmallButton('Swap##' .. index) then
                    if not mq.TLO.Cursor() then
                        local packSlot = mq.TLO.FindItem(value.upgradeItem).ItemSlot()
                        local subSlot = mq.TLO.FindItem(value.upgradeItem).ItemSlot2()
                        mq.cmdf('/itemnotify in pack%i %i leftmouseup', (packSlot - 22), (subSlot + 1))
                    end
                    mq.cmdf('/say ^ig byname %s', value.botName)
                    data.ClearPotentialBotItemUpgrades()
                    ImGui.CloseCurrentPopup()
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

return itemUpgradeWindow
