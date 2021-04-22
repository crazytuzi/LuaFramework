-- @Author: liaoxianbo
-- @Date:   2020-05-07 16:34:14
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-05-18 10:43:59
local QUIWidgetActivityItem = import("..widgets.QUIWidgetActivityItem")
local QUIWidgetActivitySevenRushBuy = class("QUIWidgetActivitySevenRushBuy", QUIWidgetActivityItem)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QActivity = import("...utils.QActivity")

function QUIWidgetActivitySevenRushBuy:ctor(options)
	local ccbFile = "ccb/Widget_SevenDayAcitivity_rushbuy_cell.ccbi"
	if options == nil then
		options = {}
	end
	options.ccbFile = ccbFile
    QUIWidgetActivitySevenRushBuy.super.ctor(self, options)


    self._isSelectPreviewDay = false
end

function QUIWidgetActivitySevenRushBuy:onEnter( ... )
    self._activityProxy = cc.EventProxy.new(remote.activity)
   	self._activityProxy:addEventListener(QActivity.EVENT_128RECHARGE_UPDATE, handler(self, self.updateDialog))
end

function QUIWidgetActivitySevenRushBuy:onExit()
	self._activityProxy:removeAllEventListeners()
end

function QUIWidgetActivitySevenRushBuy:updateDialog( )
	if self._topTipsDialog then
		self._topTipsDialog:popSelf()
		self._topTipsDialog = nil
	end
end
function QUIWidgetActivitySevenRushBuy:setInfo(id, info, activityPanel)
	self._awardsFreeType = info.is_free
	local activityType = activityPanel:getCurActivityType()
	local isShowLock = false
	if self._awardsFreeType == 2 and not remote.user.calnivalPrizeIsActive and activityType == 1 then
		isShowLock = true
	elseif self._awardsFreeType == 2 and not remote.user.celebrationPrizeIsActive and activityType == 2 then
		isShowLock = true
	end

	info.isShowLock = isShowLock

    QUIWidgetActivitySevenRushBuy.super.setInfo(self, id, info, activityPanel)

    self._ccbOwner.tf_num:setVisible(false)
    self._ccbOwner.node_btn2:setVisible(false)
    self._ccbOwner.node_btn_go:setVisible(false)
    self._ccbOwner.alreadyTouch:setVisible(false)
    self._ccbOwner.notTouch:setVisible(false)
    self._ccbOwner.sp_time_out:setVisible(false)
    self._ccbOwner.node_btn:setVisible(false)
    if q.isEmpty(info) then return end
    self._ccbOwner.tf_discount:setString(info.value2 or "")
    self._ccbOwner.tf_price:setString(info.value3 or "")

    
    if self._awardsFreeType == 2 then
    	self._ccbOwner.node_btn_go:setVisible(true)
    	self._ccbOwner.tf_btn3:setString("特权购买")
    else
    	self._ccbOwner.node_btn:setVisible(true)
		self._ccbOwner.tf_btn:setString("购  买")
    end
    if info.completeNum == 3 then
    	self._ccbOwner.node_btn:setVisible(false)
    	self._ccbOwner.node_btn_go:setVisible(false)
    end
end

function QUIWidgetActivitySevenRushBuy:setPreviewStated(stated)
	if stated == nil then stated = false end

    self._isSelectPreviewDay = stated
    -- print("----QUIWidgetActivitySevenRushBuy--self._isSelectPreviewDay------", self._isSelectPreviewDay)
	if stated then
		self._ccbOwner.tf_btn:setString("明日开启")
		self._ccbOwner.tf_btn3:setString("明日开启")
	end
	
	if stated then
		if self._awardsFreeType == 2 then
			self._ccbOwner.node_btn_go:setVisible(true)
		else
			self._ccbOwner.node_btn:setVisible(true)
		end
		self._ccbOwner.sp_ishave:setVisible(false)
	end
end

function QUIWidgetActivitySevenRushBuy:_onTriggerConfirm(x , y, touchNodeNode, list)
	print("QUIWidgetActivitySevenRushBuy:_onTriggerConfirm")
    app.sound:playSound("common_small")
    if self._isSelectPreviewDay then
		app.tip:floatTip("活动明日才开启哟！")
		return
   	end
	if self.info.completeNum == 3 then
		return
	end
	if self.info.completeNum ~= 2 then
		if not remote.activity:checkIsActivity(self.info.activityId) then
			app.tip:floatTip("不在活动时间段内!")
			return
		else
			local shortcutID = remote.activity:getLinkActivity(self.info.type)
			local linkId = self.info.link or shortcutID
			if linkId ~= nil then
				local params = nil
				if linkId == "89013" or linkId == "90022" then
					params = self.info.value2
				end
				QQuickWay:clickGoto(db:getShortcutByID(linkId), params)
			else
				app.tip:floatTip("活动目标未达成！")
			end
			return
		end
	end
	if remote.activity:checkIsActivityAward(self.info.activityId) == false then
		app.tip:floatTip("活动领奖时间已过！下次请早！")
		return
	end

	if self._activityPanel then
		self._activityPanel:getOptions().curActivityTargetId  = self.info.activityTargetId
		self._activityPanel:getOptions().curActivityTargetOffset  = list:getItemPosToTopDistance(list:getCurTouchIndex())
	end
	local activityType = self._activityPanel:getCurActivityType()
	local tipsCallback = function(curtentPoints)
		local allSpecialItems = {}
		local availableItems = {}
		local scoreInfo = db:getStaticByName("activity_carnival_new_reward") or {}
		for _,value in pairs(scoreInfo) do
			if value.type == activityType then
				if value.special_reward then
					local rewardTbl = string.split(value.special_reward, "^")
					table.insert(allSpecialItems,{id=rewardTbl[1],typeName = remote.items:getItemType(rewardTbl[1]) or ITEM_TYPE.ITEM, count= tonumber(rewardTbl[2])})
					if curtentPoints >= value.condition then
						table.insert(availableItems,{id=rewardTbl[1],typeName = remote.items:getItemType(rewardTbl[1]) or ITEM_TYPE.ITEM, count= tonumber(rewardTbl[2])})
					end
				end			
			end
		end

		self._topTipsDialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSpecialAwards",
			options = {bigTitle = "特权购买", curActivityType = activityType,allSpecialItems = allSpecialItems,availableItems = availableItems,
			title1 = "购买128后获得以下额外奖励",title2 = "现在购买立即获得以下奖励",closeCallback = function()
				self._topTipsDialog = nil
			end}})
	end

	if self._awardsFreeType == 2 and not remote.user.calnivalPrizeIsActive and activityType == 1 then
		-- app.tip:floatTip("请先激活嘉年华特权")
		tipsCallback(remote.user.calnivalPoints or 0)
		return
	end

	if self._awardsFreeType == 2 and not remote.user.celebrationPrizeIsActive and activityType == 2 then
		-- app.tip:floatTip("请先激活半月庆典特权")
		tipsCallback(remote.user.celebration_points)
		return
	end

	local activityTargetId = self.info.activityTargetId
	local activityId = self.id
	local awards = {} --self.awards
	for _,award in pairs(self.awards) do
		if award.count > 0 then
			table.insert(awards,award)
		end
	end
	if self._isChooseOne then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogXuanzejiangli", 
                        options = {awards = awards,confirmText = "领  取", 
                            okCallback = function ( chooseIndexs )
								if not chooseIndexs then
									chooseIndexs = {}
								end
								local chooseIndex = chooseIndexs[1]
								
                            	if not chooseIndex or chooseIndex == 0 then
                            		app.tip:floatTip("请选择")
                            		return false
                            	end
                            
                            	local chooseAward = awards[chooseIndex]
                            	if type(chooseAward) == "table" then
	                            	local chooseAwardStr = chooseAward.id.."^"..chooseAward.count
	                            	local chooseAwards = {}
	                            	table.insert(chooseAwards, chooseAward)
	                            	return QUIWidgetActivityItem.getRewards(activityId, activityTargetId, chooseAwards,chooseAwardStr)
	                            end
	                            return true
                            end}}, {isPopCurrentDialog = false})
	else
		QUIWidgetActivityItem.getRewards(activityId, activityTargetId,awards)
	end
end

return QUIWidgetActivitySevenRushBuy