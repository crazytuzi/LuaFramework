-- @Author: DELL
-- @Date:   2020-04-15 11:36:44
-- @Last Modified by:   DELL
-- @Last Modified time: 2020-04-20 18:52:59
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSoulTowerRoundSeanAwards = class("QUIDialogSoulTowerRoundSeanAwards", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QScrollView = import("...views.QScrollView")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIDialogSoulTowerRoundSeanAwards:ctor(options)
	local ccbFile = "ccb/Dialog_SoulTower_Season.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
    }
    QUIDialogSoulTowerRoundSeanAwards.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true
    
    q.setButtonEnableShadow(self._ccbOwner.btn_ok)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._round = -1
    self:resetAll()
    self:setInfo(options.info)
    local myRank = options.info and options.info.envRank or 0
    local historyFloor = options.info and options.info.dungeonId or 0
    local historyWave = options.info and options.info.wave or 0

    local awardTbl = remote.soultower:getAwardsByfloorWave(historyFloor,historyWave)
    local rankAwards = remote.soultower:getMySoultowerRankAward(myRank)
    local awardInfo = {}
    if rankAwards.local_rank_reward then
        local rankAwardInfo= db:getluckyDrawById(rankAwards.local_rank_reward)
        awardInfo = rankAwardInfo
    end    

    if awardTbl.floor_reward then
        local floorAwardInfo = db:getluckyDrawById(awardTbl.floor_reward)
        for _,v in pairs(floorAwardInfo) do
            table.insert(awardInfo, v )
        end
    end
    if awardTbl.wave_reward then
        local waveAwardInfo = db:getluckyDrawById(awardTbl.wave_reward)
        for _,v in pairs(waveAwardInfo) do
            table.insert(awardInfo, v )
        end        
    end

    self:sortSameAwrads(awardInfo)
end

function QUIDialogSoulTowerRoundSeanAwards:sortSameAwrads(awards)
    --合并相同的道具
    local tempAwards = {}
    local tempAwards2 = {}
    for _, v in pairs(awards) do
        if v.typeName ~= ITEM_TYPE.HERO then
            if tonumber(v.id) ~= nil and tonumber(v.id) > 0 then
                if tempAwards[v.id] then
                    tempAwards[v.id].count = tempAwards[v.id].count + v.count
                else
                    tempAwards[v.id] = v
                end
            else
                if tempAwards[v.typeName] then
                    tempAwards[v.typeName].count = tempAwards[v.typeName].count + v.count
                else
                    tempAwards[v.typeName] = v
                end
            end
        else
            table.insert(tempAwards2, v)
        end
    end
    awards = tempAwards2
    for k,v in pairs(tempAwards) do
        if tonumber(v.id) ~= nil and tonumber(v.id) > 0 then
            local int = math.ceil(v.count/9999)
            for i= 1,int do
                local temp = clone(v)
                local tempCount = v.count - 9999
                if tempCount < 0 then
                    temp.count = v.count
                else
                    v.count = v.count - 9999
                    temp.count = 9999
                end 
                table.insert(awards,temp)
            end
        else
            table.insert(awards,v)
        end
    end 
    self:setAwardInfo(awards)
end

function QUIDialogSoulTowerRoundSeanAwards:viewDidAppear()
	QUIDialogSoulTowerRoundSeanAwards.super.viewDidAppear(self)

	self:addBackEvent(true)
end

function QUIDialogSoulTowerRoundSeanAwards:viewWillDisappear()
  	QUIDialogSoulTowerRoundSeanAwards.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDialogSoulTowerRoundSeanAwards:resetAll()
    self._ccbOwner.frame_tf_title:setString("赛季结算")
    self._ccbOwner.tf_title_tips:setString("上一次的升灵台暴动期已经过去，为了鼓励您在暴动期内击退的魂兽和魂灵，表彰您在众多魂师中的排名，给您发放以下奖励：")
    self._ccbOwner.tf_top_desc:setString("最高击退：")
    self._ccbOwner.tf_top_time_desc:setString("最佳时间：")
    self._ccbOwner.tf_cur_desc:setString("本服排名：")
    self._ccbOwner.tf_all_desc:setString("全服排名：")
    self._ccbOwner.tf_ok:setString("领 取")
end
-- /**
--  * 升灵台--轮次结算信息
--  */
-- message SoulTowerRoundEndRewardInfo {
--     optional int32 roundId = 1;     //轮次
--     optional int32 dungeonId = 2;   //层数
--     optional int32 wave = 3;        //波次
--     optional int64 passTime = 4;    //通关时间 毫秒
--     optional string reward = 5;     //奖励
--     optional int32 rank = 6;        //全服排名
--     optional int32 envRank = 7;     //区服排名
-- }
function QUIDialogSoulTowerRoundSeanAwards:setInfo(info)
    if info.dungeonId and info.wave then
        self._ccbOwner.tf_top_num:setString(info.dungeonId.."-"..info.wave)
    else
        self._ccbOwner.tf_top_num:setString("无")
    end
    if info.passTime then
        local timeDesc = string.format("%0.2f秒", tonumber(info.passTime or 0) / 1000.0 )
        self._ccbOwner.tf_top_time_num:setString(timeDesc)
    else
        self._ccbOwner.tf_top_time_num:setString("无")
    end
    self._ccbOwner.tf_cur_num:setString(info.envRank or "无")
    self._ccbOwner.tf_all_num:setString(info.rank or "无")
    self._ccbOwner.tf_top_num:setPositionX(self._ccbOwner.tf_top_desc:getPositionX() + self._ccbOwner.tf_top_desc:getContentSize().width * 0.5 + 10)
    self._ccbOwner.tf_top_time_num:setPositionX(self._ccbOwner.tf_top_time_desc:getPositionX() + self._ccbOwner.tf_top_time_desc:getContentSize().width * 0.5 + 10)
    self._round = info.roundId
end

function QUIDialogSoulTowerRoundSeanAwards:setAwardInfo(info)
    local scrollSize = self._ccbOwner.sheet_layout:getContentSize()
    self._scrollView = QScrollView.new(self._ccbOwner.sheet, scrollSize, {bufferMode = 1, sensitiveDistance = 10})
    self._scrollView:setHorizontalBounce(true)

    
    local awards = info or {}

    local itemCount = #awards
	for i = 1, itemCount do
        local itemBox = QUIWidgetItemsBox.new()
        itemBox:setPromptIsOpen(true)
        itemBox:setGoodsInfo(awards[i].id, awards[i].typeName, awards[i].count)
        itemBox:setPosition(ccp(60+(i-1)*130, -55))
        itemBox:setScale(0.8)
        self._scrollView:addItemBox(itemBox)
	end
    self._scrollView:setRect(0, scrollSize.height, 0, 130*itemCount-10)
    self._scrollView:moveTo(0, 0, false)

    self._awards = awards
end

function QUIDialogSoulTowerRoundSeanAwards:_onTriggerOK(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_ok) == false then return end

    if self._round == -1 then return end
    if self._awards == nil or  self._awards == {}  then
        return 
    end

    local success_ = function(data) 
        if self:safeCheck() then
            self:viewAnimationOutHandler()
            remote.soultower:setSoulTowerRoundEndAward({})
            if self._awards and #self._awards > 0 then
                local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert", 
                    options = {awards = self._awards}},{isPopCurrentDialog = false})
                dialog:setTitle("恭喜获得上轮次奖励")
            end
        end
    end
    local fail_ = function(data) 
        if self:safeCheck() then
            self:viewAnimationOutHandler()
        end
    end
    remote.soultower:soulTowerGetRoundAwardsRequest(self._round,success_,fail_)
end

function QUIDialogSoulTowerRoundSeanAwards:_onTriggerClose()
    self:_close()
end

function QUIDialogSoulTowerRoundSeanAwards:_close()
    app.sound:playSound("common_cancel")
    self:playEffectOut()
end

return QUIDialogSoulTowerRoundSeanAwards
