local mq                  = require('mq')
local imgui               = require('ImGui')
local utils               = require('utils')
local data                = require('data')
local events              = require('events')
local selectBotSubscreen  = {}
local selectBotComboWidth = 350
local FLT_MIN, FLT_MAX    = mq.NumericLimits_Float()

function selectBotSubscreen.drawSelectBotSubscreen(gui)
    ImGui.SetCursorPosY((ImGui.GetWindowSizeVec().y / 2) - 24 - ((26 * imgui.GetTextLineHeightWithSpacing()) / 2))
    utils.CenterText("Select or Create a Bot...")
    ImGui.PushItemWidth(selectBotComboWidth)
    utils.CenterItem()

    gui.botConfigSelectedBotIndex = ImGui.ListBox("##BotList", gui.botConfigSelectedBotIndex, data.GetBotNameList(), nil,
        25)
    ImGui.PopItemWidth()

    local buttonPadding = 4
    local buttonSizeY = 24
    local startPoint = (ImGui.GetWindowSizeVec().x - selectBotComboWidth) / 2
    local buttonWidth = (selectBotComboWidth / 3) - buttonPadding

    ImGui.SetCursorPosX(startPoint - (buttonPadding / 2))
    if ImGui.Button("Modify Bot", ImVec2(buttonWidth, buttonSizeY)) then
        if gui.botConfigSelectedBotIndex ~= 0 then
            gui.SetActiveSubscreen("BotConfiguration")
        end
    end
    ImGui.SameLine()
    if ImGui.Button("Refresh Bot List", ImVec2(buttonWidth, buttonSizeY)) then 
        mq.cmd('/say ^botlist')
     end
    ImGui.SameLine()
    if ImGui.Button("Delete a Bot", ImVec2(buttonWidth, buttonSizeY)) then
        if gui.selectedBotIndex ~= 0 then
            if not ImGui.IsPopupOpen("Delete Bot?") then
                ImGui.OpenPopup("Delete Bot?")
            end
        end
    end

    local viewport = ImGui.GetMainViewport()
    local center = viewport.Pos + (viewport.Size * 0.5)

    ImGui.SetNextWindowPos(center, ImGuiCond.Appearing, ImVec2(0.5, 0.5)) -- Centered
    ImGui.SetNextWindowSizeConstraints(ImVec2(200, 0), ImVec2(FLT_MAX, FLT_MAX))
    if ImGui.BeginPopupModal("Delete Bot?", nil, bit32.bor(ImGuiWindowFlags.NoResize, ImGuiWindowFlags.NoMove)) then
        utils.CenterText("Are you sure you want to delete this bot?")
        utils.CenterText(data.GetBotNameList()[gui.botConfigSelectedBotIndex])
        local startPoint = (ImGui.GetWindowSizeVec().x  / 2) - (buttonWidth + 2 * 2)
        ImGui.SetCursorPosX(startPoint - (buttonPadding / 2))

        if ImGui.Button("Yes##deletebot", ImVec2(buttonWidth, buttonSizeY)) then
            events.SetButtonState("DeleteBot", true, function () return { data.GetBotNameList()[gui.botConfigSelectedBotIndex] } end)
            ImGui.CloseCurrentPopup()
        end
        ImGui.SameLine()
        if ImGui.Button("No##deletebot", ImVec2(buttonWidth, buttonSizeY)) then
            ImGui.CloseCurrentPopup()
        end

        ImGui.EndPopup()
    end
end

return selectBotSubscreen
