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

utils.ClassIDs = {
    Warrior = 1,
    Cleric = 2,
    Paladin = 3,
    Ranger = 4,
    ShadowKnight = 5,
    Druid = 6,
    Monk = 7,
    Bard = 8,
    Rogue = 9,
    Shaman = 10,
    Necromancer = 11,
    Wizard = 12,
    Magician = 13,
    Enchanter = 14,
    Beastlord = 15,
    Berserker = 16
}
utils.RaceIds = {
    Human = 1,
    Barbarian = 2,
    Erudite = 3,
    WoodElf = 4,
    HighElf = 5,
    DarkElf = 6,
    HalfElf = 7,
    Dwarf = 8,
    Troll = 9,
    Ogre = 10,
    Halfling = 11,
    Gnome = 12,
    Iksar = 128,
    VahShir = 130,
    Froglok = 330,
    Drakkin = 522
}


utils.ClassTextures = {
    Bard = mq.FindTextureAnimation("BardIcon"),
    Beastlord = mq.FindTextureAnimation("BeastlordIcon"),
    Berserker = mq.FindTextureAnimation("BerserkerIcon"),
    Cleric = mq.FindTextureAnimation("ClericIcon"),
    Druid = mq.FindTextureAnimation("DruidIcon"),
    Enchanter = mq.FindTextureAnimation("EnchanterIcon"),
    Magician = mq.FindTextureAnimation("MagicianIcon"),
    Monk = mq.FindTextureAnimation("MonkIcon"),
    Necromancer = mq.FindTextureAnimation("NecromancerIcon"),
    Paladin = mq.FindTextureAnimation("PaladinIcon"),
    Ranger = mq.FindTextureAnimation("RangerIcon"),
    Rogue = mq.FindTextureAnimation("RogueIcon"),
    ShadowKnight = mq.FindTextureAnimation("Shadow KnightIcon"),
    Shaman = mq.FindTextureAnimation("ShamanIcon"),
    Warrior = mq.FindTextureAnimation("WarriorIcon"),
    Wizard = mq.FindTextureAnimation("WizardIcon")
}

utils.RaceTextures = {
    -- Female Icons
    FBarbarian = mq.FindTextureAnimation("BarbarianIcon"),
    FDarkElf = mq.FindTextureAnimation("Dark ElfIcon"),
    FDrakkin = mq.FindTextureAnimation("DrakkinIcon"),
    FDwarf = mq.FindTextureAnimation("DwarfIcon"),
    FErudite = mq.FindTextureAnimation("EruditeIcon"),
    FFroglok = mq.FindTextureAnimation("FroglokIcon"),
    FGnome = mq.FindTextureAnimation("GnomeIcon"),
    FHalfElf = mq.FindTextureAnimation("Half ElfIcon"),
    FHalfling = mq.FindTextureAnimation("HalflingIcon"),
    FHighElf = mq.FindTextureAnimation("High ElfIcon"),
    FHuman = mq.FindTextureAnimation("HumanIcon"),
    FIksar = mq.FindTextureAnimation("IksarIcon"),
    FOgre = mq.FindTextureAnimation("OgreIcon"),
    FTroll = mq.FindTextureAnimation("TrollIcon"),
    FVahShir = mq.FindTextureAnimation("Vah ShirIcon"),
    FWoodElf = mq.FindTextureAnimation("Wood ElfIcon"),
    -- Male Icons
    MBarbarian = mq.FindTextureAnimation("BarbarianMaleIcon"),
    MDarkElf = mq.FindTextureAnimation("Dark ElfMaleIcon"),
    MDrakkin = mq.FindTextureAnimation("DrakkinMaleIcon"),
    MDwarf = mq.FindTextureAnimation("DwarfMaleIcon"),
    MErudite = mq.FindTextureAnimation("EruditeMaleIcon"),
    MFroglok = mq.FindTextureAnimation("FroglokMaleIcon"),
    MGnome = mq.FindTextureAnimation("GnomeMaleIcon"),
    MHalfElf = mq.FindTextureAnimation("Half ElfMaleIcon"),
    MHalfling = mq.FindTextureAnimation("HalflingMaleIcon"),
    MHighElf = mq.FindTextureAnimation("High ElfMaleIcon"),
    MHuman = mq.FindTextureAnimation("HumanMaleIcon"),
    MIksar = mq.FindTextureAnimation("IksarMaleIcon"),
    MOgre = mq.FindTextureAnimation("OgreMaleIcon"),
    MTroll = mq.FindTextureAnimation("TrollMaleIcon"),
    MVahShir = mq.FindTextureAnimation("Vah ShirMaleIcon"),
    MWoodElf = mq.FindTextureAnimation("Wood ElfMaleIcon")
}

utils.EquipmentSlotTextures = {
    mq.FindTextureAnimation("A_InvEar"),
    mq.FindTextureAnimation("A_InvHead"),
    mq.FindTextureAnimation("A_InvFace"),
    mq.FindTextureAnimation("A_InvEar"),
    mq.FindTextureAnimation("A_InvChest"),
    mq.FindTextureAnimation("A_InvArms"),
    mq.FindTextureAnimation("A_InvWaist"),
    mq.FindTextureAnimation("A_InvWrist"),
    mq.FindTextureAnimation("A_InvLegs"),
    mq.FindTextureAnimation("A_InvHands"),
    mq.FindTextureAnimation("A_InvCharm"),
    mq.FindTextureAnimation("A_InvFeet"),
    mq.FindTextureAnimation("A_InvWrist"),
    mq.FindTextureAnimation("A_InvShoulders"),
    mq.FindTextureAnimation("A_InvAboutBody"),
    mq.FindTextureAnimation("A_InvNeck"),
    mq.FindTextureAnimation("A_InvNeck"),
    mq.FindTextureAnimation("A_InvNeck"),
    mq.FindTextureAnimation("A_InvNeck"),
    mq.FindTextureAnimation("A_InvNeck"),
    mq.FindTextureAnimation("A_InvNeck"),
    mq.FindTextureAnimation("A_InvNeck")



}

function utils.getMaxButtonTextSize(textTable)
    local maxTextSize = 0
    for index, value in pairs(textTable) do
        if ImGui.CalcTextSize(value) > maxTextSize then
            maxTextSize = ImGui.CalcTextSize(value)
        end
    end
    return maxTextSize + 6
end

function utils.IsValidRaceClassCombo(race, class)
    if race == '' then return false end
    for index, value in ipairs(utils.RaceClassCombinations[race]) do
        if value == class then return true end
    end
    return false
end

function utils.findMatchInTable(line, table)
    local trimmedLine = line:gsub("%s+", ""):lower()
    for _, value in ipairs(table) do
        local trimmedValue = value:gsub("%s+", ""):lower()
        if string.find(trimmedLine, trimmedValue, 1, true) then
            return value
        end
    end
    return nil
end

function utils.CenterText(line, ...)
    local formattedLine = string.format(line, ...)
    local lastCursorPos = ImGui.GetCursorPosVec()
    local screenCenterX = ImGui.GetWindowSizeVec().x / 2
    local textWidth = ImGui.CalcTextSize(formattedLine) / 2
    ImGui.SetCursorPosX(screenCenterX - textWidth)
    ImGui.Text(formattedLine)
end

function utils.CenterItem(width)
    if width == nil then
        ImGui.SetCursorPosX((ImGui.GetWindowSizeVec().x / 2) - (ImGui.CalcItemWidth() / 2))
    else
        ImGui.SetCursorPosX((ImGui.GetWindowSizeVec().x / 2) - (width / 2))
    end
end

function utils.BetterNewLine(spacing)
    ImGui.SetCursorPosY(ImGui.GetCursorPosY() + spacing)
end

function utils.GatherSpellInfo(spells)
    local spellInfoTable = {}
    for index, value in ipairs(spells) do
        for i, v in ipairs(value.spellIDs) do
            local spellName = string.format('%s (%s)', mq.TLO.Spell(v).Name(), value.Name)
            local spellCategory = mq.TLO.Spell(v).Category()
            local spellSubcategory = mq.TLO.Spell(v).Subcategory()
            local spellLevel = mq.TLO.Spell(v).Level()
            local spellTargetType = mq.TLO.Spell(v).TargetType()
            table.insert(spellInfoTable,
                {
                    Name = spellName,
                    Category = spellCategory,
                    SpellSubcategory = spellSubcategory,
                    SpellLevel =
                        spellLevel,
                    SpellTargetType = spellTargetType
                })
        end
    end
    return spellInfoTable
end

function utils.GetSpellInfo(botName, spellID)
    local spellInfoTable = {}
    local spellName = string.format('%s (%s)', mq.TLO.Spell(spellID).Name(), botName)
    local spellCategory = mq.TLO.Spell(spellID).Category()
    local spellSubcategory = mq.TLO.Spell(spellID).Subcategory()
    local spellLevel = mq.TLO.Spell(spellID).Level()
    local spellTargetType = mq.TLO.Spell(spellID).TargetType()
   spellInfoTable =
        {
            Name = spellName,
            Category = spellCategory,
            SpellSubcategory = spellSubcategory,
            SpellLevel =
                spellLevel,
            SpellTargetType = spellTargetType
        }
    return spellInfoTable
end

return utils
