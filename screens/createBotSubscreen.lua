local mq = require('mq')
local imgui = require('ImGui')
local utils = require('utils')
local createBotSubscreen = {}

local botCreateSelectedRace = ''
local botCreateSelectedClass = ''
local botCreateSelectedGender = 1
local createBotName = ''
local ClassRaceIconPadding = 4
local ClassRaceIconSize = 48
local function drawRaceGrid()
    local drawlist = ImGui.GetWindowDrawList()
    -- Grid Values
    local windowWidth = ImGui.GetWindowSizeVec().x
    local columnCount = math.floor(windowWidth / (ClassRaceIconSize + ClassRaceIconPadding))
    local currentColumn = 1
    local currentRow = 1

    for index, value in ipairs(utils.Races) do
        local prevCursorPos = ImGui.GetCursorPosVec()
        local prevScreenCursorPos = ImGui.GetCursorScreenPosVec()
        local raceTexture
        if botCreateSelectedGender == 1 then
            raceTexture = utils.RaceTextures['M' .. value:gsub("%s+", "")]
        else
            raceTexture = utils.RaceTextures['F' .. value:gsub("%s+", "")]
        end
        ImGui.DrawTextureAnimation(raceTexture, ClassRaceIconSize, ClassRaceIconSize)
        ImGui.SetCursorPos(prevCursorPos)
        if ImGui.InvisibleButton("##RaceBtn" .. index, ImVec2(ClassRaceIconSize, ClassRaceIconSize)) then
            printf("Button: %s Selected", value)
            botCreateSelectedRace = value
            botCreateSelectedClass = ''
        end
        if botCreateSelectedRace == value then
            ImGui.SetCursorPos(prevCursorPos)
            ImGui.SetCursorScreenPos(prevScreenCursorPos)
            local x = prevScreenCursorPos.x + ClassRaceIconSize
            local y = prevScreenCursorPos.y + ClassRaceIconSize
            local color = ImGui.GetColorU32(0, 1, 0, 0.25)
            drawlist:AddRectFilled(prevScreenCursorPos, ImVec2(x, y), color)
        end

        if currentColumn < columnCount then
            ImGui.SameLine(0, ClassRaceIconPadding)
            currentColumn = currentColumn + 1
        elseif currentColumn >= columnCount then
            ImGui.NewLine()
            ImGui.SetCursorPosY(prevCursorPos.y + (ClassRaceIconPadding + ClassRaceIconSize))
            currentRow = currentRow + 1
            currentColumn = 1
        end
    end
end
local function drawClassGrid()
    local drawlist = ImGui.GetWindowDrawList()
    -- Grid Values
    local windowWidth = ImGui.GetWindowSizeVec().x
    local columnCount = math.floor(windowWidth / (ClassRaceIconSize + ClassRaceIconPadding))
    local currentColumn = 1
    local currentRow = 1

    for index, value in ipairs(utils.Classes) do
        local prevCursorPos = ImGui.GetCursorPosVec()
        local prevScreenCursorPos = ImGui.GetCursorScreenPosVec()
        local classTexture = utils.ClassTextures[value:gsub("%s+", "")]
        ImGui.DrawTextureAnimation(classTexture, ClassRaceIconSize, ClassRaceIconSize)
        ImGui.SetCursorPos(prevCursorPos)
        if utils.IsValidRaceClassCombo(botCreateSelectedRace, value) then
            if ImGui.InvisibleButton("##ClassBtn" .. index, ImVec2(ClassRaceIconSize, ClassRaceIconSize)) then
                printf("Button: %s Selected", value)
                botCreateSelectedClass = value
            end
        end
        if botCreateSelectedClass == value then
            ImGui.SetCursorPos(prevCursorPos)
            ImGui.SetCursorScreenPos(prevScreenCursorPos)
            local x = prevScreenCursorPos.x + ClassRaceIconSize
            local y = prevScreenCursorPos.y + ClassRaceIconSize
            local color = ImGui.GetColorU32(0, 1, 0, 0.25)
            drawlist:AddRectFilled(prevScreenCursorPos, ImVec2(x, y), color)
        end
        if not utils.IsValidRaceClassCombo(botCreateSelectedRace, value) then
            ImGui.SetCursorPos(prevCursorPos)
            ImGui.SetCursorScreenPos(prevScreenCursorPos)
            local x = prevScreenCursorPos.x + ClassRaceIconSize
            local y = prevScreenCursorPos.y + ClassRaceIconSize
            local color = ImGui.GetColorU32(1, 0, 0, 0.25)
            drawlist:AddRectFilled(prevScreenCursorPos, ImVec2(x, y), color)
        end

        if currentColumn < columnCount then
            ImGui.SameLine(0, ClassRaceIconPadding)
            currentColumn = currentColumn + 1
        elseif currentColumn >= columnCount then
            ImGui.NewLine()
            ImGui.SetCursorPosY(prevCursorPos.y + (ClassRaceIconPadding + ClassRaceIconSize))
            currentRow = currentRow + 1
            currentColumn = 1
        end
    end
end
local function drawGenderSelectSection()
    ImGui.SetCursorPosX((ImGui.GetWindowSizeVec().x / 3))
    botCreateSelectedGender = ImGui.RadioButton("Male", botCreateSelectedGender, 1)
    ImGui.SameLine()
    botCreateSelectedGender = ImGui.RadioButton("Female", botCreateSelectedGender, 2)
end
local function drawNameAndDetailsSection()
    local firstCursorPos = ImGui.GetCursorPosVec()
    local CenterY = (ImGui.GetWindowSizeVec().y - ImGui.GetCursorPosY()) / 2
    local CenterX = (ImGui.GetWindowSizeVec().x - ImGui.GetCursorPosX()) / 2
    ImGui.SetCursorPosY((ImGui.GetCursorPosY() + CenterY) - 16)
    ImGui.SetNextItemWidth(CenterX)
    createBotName = ImGui.InputTextWithHint("##BotName", "Enter a Bot Name...", createBotName)
    ImGui.SetCursorPos(ImVec2(CenterX + 16, firstCursorPos.y))
    ImGui.Text("Bot Name: %s", createBotName)
    ImGui.SetCursorPosX(CenterX + 16)
    ImGui.Text("Race: %s", botCreateSelectedRace)
    ImGui.SetCursorPosX(CenterX + 16)
    ImGui.Text("Class: %s", botCreateSelectedClass)
    ImGui.SetCursorPosX(CenterX + 16)
    if botCreateSelectedGender == 1 then
        ImGui.Text("Gender/Sex: Male")
    elseif botCreateSelectedGender == 2 then
        ImGui.Text("Gender/Sex: Female")
    end
    ImGui.SetCursorPosX(CenterX + 16)
    if ImGui.Button("Create Bot", ImVec2(96, 32)) then
        if botCreateSelectedClass and botCreateSelectedGender and botCreateSelectedRace and createBotName then
            local createCmd = '^botcreate ' .. createBotName
            createCmd = createCmd .. ' ' .. utils.ClassIDs[botCreateSelectedClass:gsub("%s+", "")]
            createCmd = createCmd .. ' ' .. utils.RaceIds[botCreateSelectedRace:gsub("%s+", "")]
            if botCreateSelectedGender == 1 then
                createCmd = createCmd .. ' 0'
            elseif botCreateSelectedGender == 2 then
                createCmd = createCmd .. ' 1'
            end
            mq.cmdf("/say %s", createCmd)
            mq.cmdf("/say ^botspawn %s", createBotName)
        else
            printf("Invalid or Missing Options Selected")
        end
    end
end

function createBotSubscreen.drawCreateBotSubscreen()
    ImGui.SetCursorPosX(16)
    if ImGui.BeginChild("CreateBot", ImVec2(480, 512), ImGuiChildFlags.Border) then
        utils.CenterText("Create A Bot")
        ImGui.SeparatorText("Races")
        drawRaceGrid()
        ImGui.NewLine()
        ImGui.SeparatorText("Classes")
        drawClassGrid()
        ImGui.NewLine()
        ImGui.SeparatorText("Gender/Sex")
        drawGenderSelectSection()
        ImGui.NewLine()
        ImGui.SeparatorText("Name and Details")
        drawNameAndDetailsSection()
        ImGui.EndChild()
    end
end



return createBotSubscreen

