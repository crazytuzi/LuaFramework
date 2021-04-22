-- 
--  zxs
--	搏击俱乐部晋级界面
--

local QUIDialog = import(".QUIDialog")
local QUIDialogSotoTeamSeasonAward = class("QUIDialogSotoTeamSeasonAward", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QScrollView = import("...views.QScrollView")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIDialogSotoTeamSeasonAward:ctor(options)
	local ccbFile = "ccb/Dialog_Soto_Season.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
	}
	QUIDialogSotoTeamSeasonAward.super.ctor(self, ccbFile, callBacks, options)
    q.setButtonEnableShadow(self._ccbOwner.btn_ok)
   
    self.isAnimation = true --是否动画显示
    self._season_ID = -1
    self:resetAll()
    self:setInfo(options.info)
    self:setAwardInfo(options.info)
end

function QUIDialogSotoTeamSeasonAward:resetAll()
    self._ccbOwner.frame_tf_title:setString("赛季结算")
    self._ccbOwner.tf_title_tips:setString("上赛季云顶之战的比赛已经结束，新的赛季已经开始")
    self._ccbOwner.tf_top_desc:setString("上赛季历史最高排名：")
    self._ccbOwner.tf_cur_desc:setString("本服排名：")
    self._ccbOwner.tf_all_desc:setString("全服排名：")
    self._ccbOwner.tf_ok:setString("领 取")
end

function QUIDialogSotoTeamSeasonAward:setInfo(info)
    --info.oldMaxRank 
    --info.oldEnvRank 
    --info.oldRank 
    self._ccbOwner.tf_top_num:setString(info.oldMaxRank or "无")
    self._ccbOwner.tf_cur_num:setString(info.oldEnvRank or "无")
    self._ccbOwner.tf_all_num:setString(info.oldRank or "无")
    self._ccbOwner.tf_top_num:setPositionX(self._ccbOwner.tf_top_desc:getPositionX() + self._ccbOwner.tf_top_desc:getContentSize().width * 0.5 + 10)
    self._season_ID = info.seasonNo

end

function QUIDialogSotoTeamSeasonAward:setAwardInfo(info)
    local scrollSize = self._ccbOwner.sheet_layout:getContentSize()
    self._scrollView = QScrollView.new(self._ccbOwner.sheet, scrollSize, {bufferMode = 1, sensitiveDistance = 10})
    self._scrollView:setHorizontalBounce(true)

    if info.oldEnvRank  == nil then
        self._awards = nil
        return 
    end
    local cur_rank = info.oldEnvRank 

    local awardConfigs = db:getRewardConfigByLevel(remote.user.level)
    table.sort(awardConfigs, function(a, b)
        return a.ID < b.ID
    end)
    
    local curConfig = nil
    for i, awardConfig in pairs(awardConfigs) do
        if awardConfig.rank >= cur_rank then
            curConfig = awardConfig
            break
        end
    end

    if curConfig == nil then
        self._awards = nil
        return 
    end

    local awards = {}
    local rankItemInfo = db:getSotoTeamSeasonRewardById(curConfig.ID)
    local index_ = 1
    while rankItemInfo["num_"..index_] do
        table.insert(awards, {id = rankItemInfo["id_"..index_] or rankItemInfo["type_"..index_] , typeName = rankItemInfo["type_"..index_] or ITEM_TYPE.ITEM, count = rankItemInfo["num_"..index_]})
        index_ = index_ + 1
    end

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

function QUIDialogSotoTeamSeasonAward:_onTriggerClose()
    self:_close()
end

function QUIDialogSotoTeamSeasonAward:_close()
    app.sound:playSound("common_cancel")
    self:playEffectOut()
end

function QUIDialogSotoTeamSeasonAward:_onTriggerOK(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_ok) == false then return end

    if self._season_ID  == -1 then return end

    --新赛季开始清空云顶之战进攻阵容
    remote.teamManager:clearLocalTeam(remote.teamManager.SOTO_TEAM_ATTACK_TEAM)
    remote.teamManager:clearCacheTeam(remote.teamManager.SOTO_TEAM_ATTACK_TEAM)


    if self._awards == nil or  self._awards == {}  then
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSotoTeamIntroDialog", options = {}}, {isPopCurrentDialog = true})
        return 
    end

    local success_ = function(data) 
        if self:safeCheck() then
            self:viewAnimationOutHandler()
            remote.sotoTeam:setSotoTeamSeasonReward({})
            if self._awards and #self._awards > 0 then
                local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert", 
                    options = {awards = self._awards,
                    callBack = function()
                        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSotoTeamIntroDialog", options = {}}, {isPopCurrentDialog = true})
                    end}},{isPopCurrentDialog = false})
                dialog:setTitle("恭喜获得上赛季奖励")
            end
        end
    end


    local fail_ = function(data) 
        if self:safeCheck() then
            app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSotoTeamIntroDialog", options = {}}, {isPopCurrentDialog = true})
        end
    end

    remote.sotoTeam:sotoTeamGetSeasonRewardRequest(self._season_ID,success_,fail_)
end

return QUIDialogSotoTeamSeasonAward