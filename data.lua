local mq = require('mq')


local data = {}

data.BotNameList = {}
data.CharacterBots = {}

data.Compositions = {
    Groups = {},
    Raids = {}
}

function data.loadBotGroupConfigurations()
    local configData, err = loadfile(mq.configDir..'/puppeteer-groups.lua')
    if err then
        -- failed to read the config file, create it using pickle
        mq.pickle('puppeteer-groups.lua', data.Compositions.Groups)
    elseif configData then
        -- file loaded, put content into your config table
        data.Compositions.Groups = configData()
        for k,v in pairs(data.Compositions.Groups) do print(k,v) end
    end
end



function data.initBotData(key, botData)
    if botData == nil then
        printf("Nill bot data")
    else
        print(botData.Name)
        print(botData.Class)
        data.CharacterBots[key] = botData
        data.BotNameList[key] = botData.Name
    end
end

function data.GetBotData(index)
    if index then
        return data.CharacterBots[index]
    else
        return data.CharacterBots
    end
end

function data.GetBotDataByName(name)
    for index, value in ipairs(data.CharacterBots) do
        if value.Name == name then
            return data.CharacterBots[index]
        end
    end
    return false
end

function data.GetBotTitle(index)
    if data.CharacterBots[index].Title == '' and mq.TLO.Spawn(data.CharacterBots[index].Name)() then
        data.CharacterBots[index].Title = mq.TLO.Spawn(data.CharacterBots[index].Name).Title()
    end
    return data.CharacterBots[index].Title
end

function data.GetBotLastName(index)
    if data.CharacterBots[index].Surname == '' and mq.TLO.Spawn(data.CharacterBots[index].Name)() then
        data.CharacterBots[index].Surname = mq.TLO.Spawn(data.CharacterBots[index].Name).Surname()
    end
    return data.CharacterBots[index].Surname
end

function data.GetBotSuffix(index)
    if data.CharacterBots[index].Suffix == '' and mq.TLO.Spawn(data.CharacterBots[index].Name)() then
        data.CharacterBots[index].Suffix = mq.TLO.Spawn(data.CharacterBots[index].Name).Suffix()
    end
    return data.CharacterBots[index].Suffix
end

function data.GetGroupComposition(groupName)
    if groupName then
        if not data.Compositions.Groups[groupName] then
            printf("Group: %s is missing.", groupName) 
        else
            return data.Compositions.Groups[groupName]
        end
    else
        return data.Compositions.Groups
    end

end

function data.GetGroupCompositionList()
    local GroupList = {}
    for index, value in pairs(data.Compositions.Groups) do
        table.insert(GroupList, index)
    end
    return GroupList
end

function data.SetGroupComposition(groupName, groupData)
    if data.Compositions.Groups[groupName] == nil then
        data.Compositions.Groups[groupName] = {}
        data.Compositions.Groups[groupName] = groupData
    else
        data.Compositions.Groups[groupName] = groupData
    end
end

function data.RefreshData(index)
    data.GetBotTitle(index)
    data.GetBotLastName(index)
    data.GetBotSuffix(index)
    return data.CharacterBots[index]
end

function data.GetBotNameList()
    return data.BotNameList
end

function data.refreshBotListButton()
    data.BotNameList = {}
    data.CharacterBots = {}
    mq.cmd('/say ^botlist')
    mq.delay(500)
    mq.doevents()
end

return data
