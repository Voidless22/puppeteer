local mq = require('mq')
local imgui = require('ImGui')
local utils = require('utils')
local events = require('events')
local data   = require('data')
local gui = require('gui')
local Running = true


local function main()
    while Running do
        mq.doevents()
        mq.delay(10)
        for index, value in pairs(gui.GetButtonState()) do
            if value ~= nil then
            if value.activated and not value.guiButton then
                value.callback()
                gui.SetButtonState(index, false)
            end
        end
        end
        events.EventStateManager()
    end
end

local function initEvents()
    mq.event("GetBotList", "Bot #1# #*# #2# is a Level #3# #4# #5# owned by You.", events.getBotList)
    mq.cmd('/say ^botlist')
    mq.delay(500)
    mq.doevents()
    mq.delay(100)
end


initEvents()

mq.imgui.init("Puppeteer", gui.guiLoop)
main()
