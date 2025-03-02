local mq = require('mq')
local imgui = require('ImGui')


local utils = {}

utils.Races = {
    "Barbarian", "Dark Elf", "Drakkin", "Dwarf", "Erudite", "Froglok", "Gnome", "Half Elf", "Halfling", "High Elf",
    "Human", "Iksar", "Ogre", "Troll", "Vah Shir", "Wood Elf"
}
utils.Classes = {
    "Bard", "Beastlord", "Berserker", "Cleric", "Druid", "Enchanter", "Magician", "Monk", "Necromancer", "Paladin",
    "Ranger", "Rogue", "Shadow Knight", "Shaman", "Warrior", "Wizard"
}

function utils.findMatchInTable(line, table)
    for _, value in ipairs(table) do
        if string.find(line, value, 1, true) then
            return value
        end
    end
    return nil
end

function utils.CenterText(line)
    local lastCursorPos = ImGui.GetCursorPosVec()
    local screenCenterX = ImGui.GetWindowSizeVec().x / 2
    local textWidth = ImGui.CalcTextSize(line) / 2
    ImGui.SetCursorPosX(screenCenterX - textWidth)
    ImGui.Text(line)
end

function utils.CenterItem()
    ImGui.SetCursorPosX((ImGui.GetWindowSizeVec().x / 2) - (ImGui.CalcItemWidth() / 2))
end

return utils
