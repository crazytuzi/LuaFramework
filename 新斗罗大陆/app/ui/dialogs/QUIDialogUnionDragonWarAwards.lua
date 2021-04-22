local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogUnionDragonWarAwards = class("QUIDialogUnionDragonWarAwards", QUIDialog)
local QListView = import("...views.QListView")
local QUIWidgetUnionDragonWarAwardsSheet = import("..widgets.dragon.QUIWidgetUnionDragonWarAwardsSheet")
local QUIViewController = import("...ui.QUIViewController")

function QUIDialogUnionDragonWarAwards:ctor(options)
	local ccbFile = "ccb/Dialog_SunWall_xingji.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogUnionDragonWarAwards._onTriggerClose)},
        {ccbCallbackName = "onTriggerOneGet", callback = handler(self, QUIDialogUnionDragonWarAwards._onTriggerConfirm)},
	}
	QUIDialogUnionDragonWarAwards.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true

	self._data = {}
	local configs = db:getDragonFightAwardsByLevel(remote.user.dailyTeamLevel)
	for _,config in ipairs(configs) do
		table.insert(self._data,{config = config})
	end

	self._ccbOwner.frame_tf_title:setString("积分奖励")

	self:myInfoUpdateHandler()
end
 
function QUIDialogUnionDragonWarAwards:viewDidAppear()
	QUIDialogUnionDragonWarAwards.super.viewDidAppear(self)
    self._unionDragonWarPeoxy = cc.EventProxy.new(remote.unionDragonWar)
    self._unionDragonWarPeoxy:addEventListener(remote.unionDragonWar.EVENT_UPDATE_MYINFO, handler(self, self.myInfoUpdateHandler))
end

function QUIDialogUnionDragonWarAwards:viewWillDisappear()
	QUIDialogUnionDragonWarAwards.super.viewWillDisappear(self)
	if self._unionDragonWarPeoxy ~= nil then
		self._unionDragonWarPeoxy:removeAllEventListeners()
		self._unionDragonWarPeoxy = nil
	end
end

--初始化滑动区域
function QUIDialogUnionDragonWarAwards:initScrollPage()
	if self._scrollView == nil then
		local cfg = {
			renderItemCallBack = handler(self, self.renderItemCallBack),
	     	ignoreCanDrag = false,
	        curOffset = 0,
	        spaceY = -2,
	        curOriginOffset = 0,
	        enableShadow = false,
	        totalNumber = #self._data
		}
		self._scrollView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._scrollView:reload({totalNumber = #self._data})
	end
end

function QUIDialogUnionDragonWarAwards:getAwardsById(rewardIds)
	local awards = {}
	for _,rewardId in ipairs(rewardIds) do
		local awardConfig = db:getLuckyDraw(rewardId)
		if awardConfig ~= nil then
			local index = 1
			while true do
				local typeName = awardConfig["type_"..index]
				local id = awardConfig["id_"..index]
				local count = awardConfig["num_"..index]
				if typeName ~= nil then
					table.insert(awards, {id = id, typeName = typeName, count = count})
				else
					break
				end
				index = index + 1
			end
		end
	end
	return awards
end

function QUIDialogUnionDragonWarAwards:renderItemCallBack(list, index, info)
    -- body
    local isCacheNode = true
  	local data = self._data[index]

    local item = list:getItemFromCache()
    if not item then	    
    	item = QUIWidgetUnionDragonWarAwardsSheet.new()
        isCacheNode = false
    end
    item:setInfo(data)
    info.item = item
    info.size = item:getContentSize()
    item:registerItemBoxPrompt(index,list)
    --注册事件
	list:registerBtnHandler(index,"btn_done", handler(self, self.clickGetHandler), nil, true)
    return isCacheNode
end

function QUIDialogUnionDragonWarAwards:clickGetHandler(x, y, touchNode, listView)
	local index = listView:getCurTouchIndex()
    local info = self._data[index]
    if info.isGet == true or info.isComplete == false then
    	return
    end
	app.sound:playSound("common_small")
	remote.unionDragonWar:dragonWarGetTodayHurtRewardRequest({info.config.ID}, function (data)
        local awards = self:getAwardsById({info.config.reward_id})
		app.tip:awardsTip(awards,"恭喜您获得奖励")
	end)
end

function QUIDialogUnionDragonWarAwards:myInfoUpdateHandler()
	local myInfo = remote.unionDragonWar:getMyInfo()
	local dragonInfo = remote.unionDragonWar:getEnemyDragonFighterInfo()
	local hurt = myInfo.todayHurt
	for _,v in ipairs(self._data) do
		v.isGet = false
		v.isComplete = hurt >= v.config.condition
	end
	
	if myInfo.todayAwardedHurtIds then
		for _,id in ipairs(myInfo.todayAwardedHurtIds) do
			for _,v in ipairs(self._data) do
				if v.config.ID == id then
					v.isGet = true
				end
			end
		end	
	end
	table.sort(self._data, function (a,b)
		if a.isGet ~= b.isGet then
			return b.isGet
		end
		if a.isComplete ~= b.isComplete then
			return a.isComplete
		end
		return a.config.ID < b.config.ID
	end)
	self:initScrollPage()
end

function QUIDialogUnionDragonWarAwards:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
    app.sound:playSound("common_close")
    self:_close()
end

function QUIDialogUnionDragonWarAwards:_onTriggerConfirm(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_oneget) == false then return end
    app.sound:playSound("common_close")
    local rewardIds = {}
    local awardIds = {}
	for _,v in ipairs(self._data) do
		if v.isGet == false and v.isComplete == true then
			table.insert(rewardIds, v.config.ID)
			table.insert(awardIds, v.config.reward_id)
		end
	end
	if #rewardIds == 0 then
		app.tip:floatTip("没有奖励可领取")
		return
	end
	remote.unionDragonWar:dragonWarGetTodayHurtRewardRequest(rewardIds, function (data)
        local awards = self:getAwardsById(awardIds)
        local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
            options = {awards = awards, callBack = function ()
                remote.user:checkTeamUp()
            end}}, {isPopCurrentDialog = false} )
	end)
end

function QUIDialogUnionDragonWarAwards:_backClickHandler()
    app.sound:playSound("common_close")
    self:_close()
end

function QUIDialogUnionDragonWarAwards:_close()
	self:playEffectOut()
end

return QUIDialogUnionDragonWarAwards