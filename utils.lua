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
utils.RaceClassCombinations = {
    ["Barbarian"] = { "Beastlord", "Berserker", "Rogue", "Shaman", "Warrior" },
    ["Dark Elf"] = { "Cleric", "Enchanter", "Magician", "Necromancer", "Rogue", "Shadow Knight", "Warrior", "Wizard" },
    ["Drakkin"] = { "Bard", "Cleric", "Druid", "Enchanter", "Magician", "Monk", "Necromancer", "Paladin", "Ranger", "Rogue", "Shadow Knight", "Warrior", "Wizard" },
    ["Dwarf"] = { "Berserker", "Cleric", "Paladin", "Rogue", "Warrior" },
    ["Erudite"] = { "Cleric", "Enchanter", "Magician", "Necromancer", "Paladin", "Shadow Knight", "Wizard" },
    ["Froglok"] = { "Cleric", "Monk", "Necromancer", "Paladin", "Rogue", "Shadow Knight", "Shaman", "Warrior", "Wizard" },
    ["Gnome"] = { "Cleric", "Enchanter", "Magician", "Necromancer", "Paladin", "Rogue", "Shadow Knight", "Warrior", "Wizard" },
    ["Half Elf"] = { "Bard", "Druid", "Paladin", "Ranger", "Rogue", "Warrior" },
    ["Halfling"] = { "Cleric", "Druid", "Paladin", "Ranger", "Rogue", "Warrior" },
    ["High Elf"] = { "Cleric", "Enchanter", "Magician", "Paladin", "Wizard" },
    ["Human"] = { "Bard", "Cleric", "Druid", "Enchanter", "Magician", "Monk", "Necromancer", "Paladin", "Ranger", "Rogue", "Shadow Knight", "Warrior", "Wizard" },
    ["Iksar"] = { "Beastlord", "Monk", "Necromancer", "Shadow Knight", "Shaman", "Warrior" },
    ["Ogre"] = { "Beastlord", "Berserker", "Shadow Knight", "Shaman", "Warrior" },
    ["Troll"] = { "Beastlord", "Berserker", "Shadow Knight", "Shaman", "Warrior" },
    ["Vah Shir"] = { "Bard", "Beastlord", "Berserker", "Rogue", "Shaman", "Warrior" },
    ["Wood Elf"] = { "Bard", "Beastlord", "Druid", "Ranger", "Rogue", "Warrior" }
}

function utils.IsValidRaceClassCombo(race, class)
    if race == '' then return false end
    for index, value in ipairs(utils.RaceClassCombinations[race]) do
        if value == class then return true end
    end
    return false
end

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
