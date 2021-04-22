local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogHighTeaReward = class("QUIDialogHighTeaReward", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetHighTeaReward = import("..widgets.QUIWidgetHighTeaReward")
local QListView = import("...views.QListView")
local QUIViewController = import("..QUIViewController")

QUIDialogHighTeaReward.TAB_REWARD = "TAB_REWARD"
QUIDialogHighTeaReward.TAB_REWARD_END = "TAB_REWARD_END"



function QUIDialogHighTeaReward:ctor(options)
    local ccbFile = "ccb/Dialog_HighTea_Reward.ccbi"
    local callBacks = {
    	{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }

    QUIDialogHighTeaReward.super.ctor(self, ccbFile, callBacks, options)

	self._selectTab = QUIDialogHighTeaReward.TAB_REWARD
	self.isAnimation = true
    -- self:_initListView() 
   	self._highTeaHandler = remote.activityRounds:getHighTea()
	self._myLevel = self._highTeaHandler:getHighTeaLevel() 
	if options.callBack ~= nil then 
		self._callback = options.callBack
	end
    self._data = {}
    self._rewardData = nil
    self._rewardEndData = nil
end


function QUIDialogHighTeaReward:viewDidAppear()
    QUIDialogHighTeaReward.super.viewDidAppear(self)
    self:setInfo()
end


function QUIDialogHighTeaReward:viewAnimationInHandler()
    QUIDialogHighTeaReward.super.viewAnimationInHandler(self)
    self:setInfo()
end

function QUIDialogHighTeaReward:viewWillDisappear()
    QUIDialogHighTeaReward.super.viewWillDisappear(self)
end

function QUIDialogHighTeaReward:setInfo()
	self._ccbOwner.frame_tf_title:setString("奖 励")
	self:updateInfo()
end


function QUIDialogHighTeaReward:updateInfo()
	self:_handleData()
	self:_initListView()
end

function QUIDialogHighTeaReward:_handleData()
	self._data = {}
	local rewards = {}
	local configs = remote.activity:getHighTeaRewardConfig()

	for k,v in pairs(configs or {}) do
		local canGet = v.level <= self._myLevel
		local lock = false
		local isGetten = self._highTeaHandler:checkGettenProjectRewardByLevel(v.level)

		if v.level == 1 then
			local luckId = v.lvup_reward
			local awardList = db:getLuckyDrawAwardTable(luckId)	
			table.insert(rewards,{ level = v.level , awardList =awardList , canGet = false ,isGetten = false
				,reward_id = luckId , showbtn = 0 })
		end

		if v.project_reward  then
			local luckId = v.project_reward
			local awardList = db:getLuckyDrawAwardTable(luckId)
			table.insert(rewards,{ level = v.level , awardList =awardList , canGet = canGet ,isGetten = isGetten,reward_id = luckId , showbtn = 1 })
		end
	end
	table.sort(rewards, function (target1, target2)
		if target1.showbtn ~= target2.showbtn then
			return target1.showbtn < target2.showbtn
		elseif target1.isGetten ~= target2.isGetten then
			return (target1.isGetten and 1 or 0) < (target2.isGetten and 1 or 0)
		elseif target1.canGet ~= target2.canGet then
			return (target1.canGet and 1 or 0) > (target2.canGet and 1 or 0)
		else
			return target1.level < target2.level
		end
	end)	

	self._data = rewards
end


function QUIDialogHighTeaReward:_initListView()
	if self._listView then
		self._listView:setContentSize(self._ccbOwner.sheet_layout:getContentSize())
		self._listView:resetTouchRect()
	end

    if self._listView == nil then
		local cfg = {
			renderItemCallBack = handler(self, self.renderItemCallBack),
            isVertical = true,
            enableShadow = false,
            contentOffsetX = -3,
	        spaceY = 0,
	        spaceX = 10,
            totalNumber = #self._data
		}
        self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
    else
        self._listView:reload({totalNumber = #self._data})
    end
end

function QUIDialogHighTeaReward:renderItemCallBack(list, index, info)
    local isCacheNode = true
    local data = self._data[index]
    local item = list:getItemFromCache()
    if not item then            
        item = QUIWidgetHighTeaReward.new()
        isCacheNode = false
    end
    item:setInfo(data,self._myLevel )
    info.item = item
    info.size = item:getContentSize()

    list:registerTouchHandler(index, "onTouchListView")
	list:registerBtnHandler(index,"btn_done", handler(self, self.clickGetHandler), nil, true)
    return isCacheNode
end


function QUIDialogHighTeaReward:clickGetHandler(x, y, touchNode, listView)
	local index = listView:getCurTouchIndex()
    local info = self._data[index]
    if info.isGetten == true or info.canGet == false then
    	return
    end
	app.sound:playSound("common_small")

	self._highTeaHandler:weekGameHighTeaProjectRewardRequest({info.level}, function (data)
		if data.items then remote.items:setItems(data.items) end
        local awards = data.prizes or {}
        local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG , uiClass = "QUIDialogAwardsAlert" ,
            options = {awards = awards, callBack = self:safeHandler(function () 
					self:updateInfo()
				end)
            }}, {isPopCurrentDialog = false} )
	end)

end


function QUIDialogHighTeaReward:_backClickHandler()
	if self._callback then
		self._callback()
	end		
    self:playEffectOut()
end

function QUIDialogHighTeaReward:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
	--代码
	app.sound:playSound("common_close")
	if self._callback then
		self._callback()
	end	
	self:playEffectOut()

end

function QUIDialogHighTeaReward:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end


return QUIDialogHighTeaReward