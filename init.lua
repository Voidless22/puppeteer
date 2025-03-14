local mq      = require('mq')
local imgui   = require('ImGui')
local utils   = require('utils')
local events  = require('events')
local data    = require('data')
local gui     = require('gui')
local buttonState = require('buttonState')
local Running = true


local function main()
    while Running do
        mq.doevents()
        mq.delay(10)
       -- events.ButtonStateManager()
       buttonState.StateManager()
    end
end

local function initEvents()
    mq.event("GetBotList", "Bot #1# #*# #2# is a Level #3# #4# #5# owned by You.", events.getBotList)
    mq.event("itemUpgradeMessage", "#1# says, 'I can use that for my #2# instead of my #3#! Would you like to #*#?'",
        events.ItemUpgradeMsgEvent, { keepLinks = true })
    mq.event("StanceInfo", "#1# says, 'My current stance is #2# (#3#).'", events.GetStanceInfo)
    mq.cmd('/say ^botlist')
    mq.delay(500)
    mq.doevents()
    mq.delay(100)
end


initEvents()
data.loadPuppeteerSettings()
data.loadBotGroupConfigurations()
data.loadPlayerGlobalDashbar()
buttonState.InitDashbarButtons()
buttonState.ConnectDashbarCallbacks()
mq.bind("/puppeteer", gui.ToggleWindowShow)
mq.bind('/defaultglobaldash', data.ResetGlobalDashbar)
mq.imgui.init("Puppeteer", gui.guiLoop)
main()
