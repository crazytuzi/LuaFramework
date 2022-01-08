--[[
******帮派副本-章节列表*******

	-- by quanhuan
	-- 2015/12/28
]]

local HoushanChapterRank = class("HoushanChapterRank",BaseLayer)

function HoushanChapterRank:ctor(data)

	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.faction.HoushanChapterRank")
end

function HoushanChapterRank:initUI( ui )

	self.super.initUI(self, ui)


    self.btn_close = TFDirector:getChildByPath(ui, 'btn_close')

    local firstNode = TFDirector:getChildByPath(ui, 'bg_1')
    local firstNameNode1 = TFDirector:getChildByPath(firstNode, 'txt_name1')
    local firstNameNode2 = TFDirector:getChildByPath(firstNode, 'txt_name2')
    
    self.firstNode = TFDirector:getChildByPath(ui, 'bg_1')
    self.firstGuildName = TFDirector:getChildByPath(firstNode, 'txt_name1')
    self.firstGuildLevel = TFDirector:getChildByPath(firstNameNode1, 'txt_level')
    self.firstGuildPower = TFDirector:getChildByPath(firstNameNode1, 'txt_num')
    self.firstPlayerName = TFDirector:getChildByPath(firstNameNode2, 'txt_level')
    self.firstPassTime = TFDirector:getChildByPath(firstNameNode2, 'txt_num')

    self.rankNode = {}
    local bgNodeTbl = {'bg_2','bg_3','bg_4'}
    for i=1,3 do
        self.rankNode[i] = {}
        local bgNode = TFDirector:getChildByPath(ui, bgNodeTbl[i])
        self.rankNode[i].node = TFDirector:getChildByPath(ui, bgNodeTbl[i])
        local guildNameNode = TFDirector:getChildByPath(bgNode, 'txt_name1')
        self.rankNode[i].guildName = TFDirector:getChildByPath(bgNode, 'txt_name1')
        self.rankNode[i].guildlevel = TFDirector:getChildByPath(guildNameNode, 'txt_level')
        local powerNode = TFDirector:getChildByPath(bgNode, 'txt_power')
        self.rankNode[i].guildPower = TFDirector:getChildByPath(powerNode, 'txt_num')
        local playerNameNode = TFDirector:getChildByPath(bgNode, 'txt_name2')
        self.rankNode[i].playerName = TFDirector:getChildByPath(playerNameNode, 'txt_level')
        local passTimeNode = TFDirector:getChildByPath(bgNode, 'txt_time')
        self.rankNode[i].passTime = TFDirector:getChildByPath(passTimeNode, 'txt_time2')
    end

    local myRankNode = TFDirector:getChildByPath(ui, 'txt_name1')
    self.myRank = TFDirector:getChildByPath(ui, 'txt_myRank')
    local myPowerNode = TFDirector:getChildByPath(ui, 'txt_myPower')
    self.myPower = TFDirector:getChildByPath(myPowerNode, 'txt_level')
    local myTimeNode = TFDirector:getChildByPath(ui, 'txt_myTime')
    self.myTime = TFDirector:getChildByPath(myTimeNode, 'txt_level')    
end


function HoushanChapterRank:removeUI()
	self.super.removeUI(self)
end

function HoushanChapterRank:onShow()
    self.super.onShow(self)
end

function HoushanChapterRank:registerEvents()

    if self.registerEventCallFlag then
        return
    end
	self.super.registerEvents(self)
    ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)
    
    self.guildZonePassRankCallBack = function (event)
        print('guildZonePassRankCallBack = ',event.data[1])
        local data = event.data[1][1]
        if data.rankInfos == nil or data.firstPass == nil then
            --toastMessage('虚席以待')
            toastMessage(localizable.common_wait)
            return
        end
        self:showDetails(data.firstPass, data.rankInfos, data.myRank)
    end
    TFDirector:addMEGlobalListener(FactionManager.guildZonePassRank, self.guildZonePassRankCallBack)

    self.registerEventCallFlag = true
end

function HoushanChapterRank:removeEvents()

    self.super.removeEvents(self)

	
    TFDirector:removeMEGlobalListener(FactionManager.guildZonePassRank, self.guildZonePassRankCallBack)
    self.guildZonePassRankCallBack = nil

    self.registerEventCallFlag = nil  
end

function HoushanChapterRank:dispose()
	self.super.dispose(self)    
end

function HoushanChapterRank:loadData(zone_id)
    self.currZoneId = zone_id
    self.firstNode:setVisible(false)
    for i=1,3 do
        self.rankNode[i].node:setVisible(false)
    end
    --self.myRank:setText('无')
    self.myRank:setText(localizable.common_no)
    self.myPower:setText(0)
    self.myTime:setText(0)

    FactionManager:requestGuildZonePassRank(zone_id, 0)
end

function HoushanChapterRank:getTimeStr( times )
    local oneDay = 24*60*60
    local onehour = 60*60

    local day = math.floor(times/oneDay)
    local newTime = times - day*oneDay
    local hour = math.floor(newTime/onehour)
    newTime = newTime - hour*onehour
    local min = math.floor(newTime/60)
    local sec = newTime - min*60

    --local templete = '%d天%02d时%02d分'
    local templete = localizable.common_time_3
    str = stringUtils.format(templete, day, hour, min)
    return str
end

function HoushanChapterRank:showDetails( firstPass, rankInfos, myRank )
    self.firstNode:setVisible(true)
    self.firstGuildName:setText(firstPass.name)
    self.firstGuildLevel:setText('LV '..firstPass.level)
    self.firstGuildPower:setText(firstPass.power)
    self.firstPlayerName:setText(firstPass.presidentName)
    local currDate = os.date("*t", math.floor(firstPass.passTime/1000))
    self.firstPassTime:setText(currDate.year..'-'..currDate.month..'-'..currDate.day)

    for i=1,#rankInfos do
        self.rankNode[i].node:setVisible(true)
        self.rankNode[i].guildName:setText(rankInfos[i].name)
        self.rankNode[i].guildlevel:setText('LV '..rankInfos[i].level)
        self.rankNode[i].guildPower:setText(rankInfos[i].power)
        self.rankNode[i].playerName:setText(rankInfos[i].presidentName)
        self.rankNode[i].passTime:setText(self:getTimeStr(math.floor(rankInfos[i].passTime/1000)))
    end   

    local info = FactionManager:getFactionInfo()
    self.myPower:setText(info.power)
    if myRank == 0 then
        self.myRank:setText(localizable.houshanRank_rank)
        self.myTime:setText(0)
    else
        local passTime = FactionManager:getMyGuildPassTime( self.currZoneId )
        self.myRank:setText(myRank)
        self.myTime:setText(self:getTimeStr(math.floor(passTime/1000)))
    end
end

return HoushanChapterRank