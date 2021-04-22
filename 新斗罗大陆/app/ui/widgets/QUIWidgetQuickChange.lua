
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetQuickChange = class("QUIWidgetQuickChange", QUIWidget)
local QBaseArrangementWithDataHandle = import("...arrangement.QBaseArrangementWithDataHandle")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetQuickChangeTeamHead = import("..widgets.QUIWidgetQuickChangeTeamHead")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QScrollView = import("...views.QScrollView")

QUIWidgetQuickChange.EVENT_CLICK_DETAIL = "EVENT_CLICK_DETAIL"
QUIWidgetQuickChange.EVENT_CLICK_TEAM_CHANGE = "EVENT_CLICK_TEAM_CHANGE"
QUIWidgetQuickChange.EVENT_CLICK_HERO_HEAD = "EVENT_CLICK_HERO_HEAD"


function QUIWidgetQuickChange:ctor(options)
	local ccbFile = "ccb/Widget_TeamArena_yijian.ccbi"
    local callBacks = { 
		{ccbCallbackName = "onTriggerDetail", callback = handler(self, self._onTriggerDetail)},
		{ccbCallbackName = "onTriggerChange", callback = handler(self, self._onTriggerChange)},
		{ccbCallbackName = "onTriggerDevelop", callback = handler(self, self._onTriggerDevelop)},
    }
    QUIWidgetQuickChange.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self._fighterInfo = nil
	self._headIconTbl = {}
end

function QUIWidgetQuickChange:onEnter()
end

function QUIWidgetQuickChange:onExit()
end

function QUIWidgetQuickChange:setInfo(teams , trialNum ,_fighterInfo)
	self._ccbOwner.ndoe_pvp:setVisible(false)
	self._ccbOwner.btn_detail:setPositionX(0)
	self._ccbOwner.btn_detail:setVisible(false)
	self._fighterInfo = _fighterInfo
	
	if self._fighterInfo then
		self._ccbOwner.ndoe_pvp:setVisible(true)
		self._ccbOwner.btn_detail:setVisible(true)
		self._ccbOwner.tf_team1:setString("敌方"..q.numToWord(trialNum))
		local force = _fighterInfo.force
	    local num, unit = q.convertLargerNumber(force or 0)
		self._ccbOwner.tf_force1:setString(num..unit)
		self._ccbOwner.btn_detail:setPositionX(self._ccbOwner.tf_force1:getPositionX() + self._ccbOwner.tf_force1:getContentSize().width + 20)
	end
	self._ccbOwner.tf_team:setString("队伍"..q.numToWord(trialNum))
	self:updateHeroHead(teams)
	self._trialNum = trialNum
	self:setChangeButton(false, false)


end

function QUIWidgetQuickChange:updateHeroHead(teams)

	if not self._scrollView then
		self._scrollView = QScrollView.new(self._ccbOwner.sheet, self._ccbOwner.sheet_layout:getContentSize(), {bufferMode = 1, nodeAR = ccp(0.5, 0.5), sensitiveDistance = 10})
    	self._scrollView:setHorizontalBounce(true)
	end
	self._teams = teams
	local totalWidth = 0
    local teamIndex = 0
    local scale = 0.6
    local offsetX = 0
	local force = 0
	for i,info in ipairs(self._teams) do
		local headIcon = self._headIconTbl[i]
		if headIcon == nil then
			headIcon = QUIWidgetQuickChangeTeamHead.new()
			headIcon:addEventListener(QUIWidgetQuickChangeTeamHead.EVENT_HERO_HEAD_CLICK, handler(self, self._clickHeroHead))
			headIcon:setScale(scale)
			self._scrollView:addItemBox(headIcon)
       		table.insert(self._headIconTbl,headIcon)
		end
		headIcon:setFormationInfo(info)
		headIcon:setHeadIndex(i)

 	 	local width = headIcon:getContentSize().width*scale+5
 	 	local height = headIcon:getContentSize().height*scale
        headIcon:setPosition(ccp(teamIndex*width+offsetX+width/2, -height/2-12))
        teamIndex = teamIndex + 1
        totalWidth = totalWidth + width
       	force = force + (info.force or 0)
	end

	self._scrollView:setRect(0, -50, 0, totalWidth+5)
	local num, unit = q.convertLargerNumber(force)
	self._ccbOwner.tf_force:setString(num..unit)
	self._scrollView:setPosition(ccp(0, 0))
	
end

function QUIWidgetQuickChange:setChangeButton(stated, isSelect)
	if stated then
		self._ccbOwner.node_btn_develop:setVisible(not stated)
		self._ccbOwner.node_btn_change:setVisible(not stated)
	else
		self._ccbOwner.node_btn_develop:setVisible(not isSelect)
		self._ccbOwner.node_btn_change:setVisible(isSelect)
	end
end

function QUIWidgetQuickChange:showAllHeroHeadEffect()
	if self._changeEffect == nil then
		self._changeEffect = {}
	end
	
	for idx,headIcon in ipairs(self._headIconTbl) do
		-- local effect = QUIWidgetAnimationPlayer.new()
		-- headIcon:addChild(effect)
		-- effect:setScale(1.5)
		-- effect:playAnimation("effects/jiaohuan_tx_yjhd.ccbi")
		-- -- effect:playAnimation("effects/jiaohuan_tx_yjhd.ccbi",function(ccbOwner)
		-- -- 	effect:removeFromParentAndCleanup(true)
		-- -- 	end)
		if self._changeEffect[idx] == nil then
			self._changeEffect[idx] = QUIWidgetAnimationPlayer.new()
			headIcon:addChild(self._changeEffect[idx])
		end
		self._changeEffect[idx]:setVisible(true)
		self._changeEffect[idx]:setScale(1.5)
		self._changeEffect[idx]:playAnimation("effects/jiaohuan_tx_yjhd.ccbi")
		
	end
end

function QUIWidgetQuickChange:showChangeEffect(idx)
	local headIcon = self._headIconTbl[idx]

	if self._changeEffect == nil then
		self._changeEffect = {}
	end

	if headIcon then
		-- local effect = QUIWidgetAnimationPlayer.new()
		-- headIcon:addChild(effect)
		-- effect:setScale(1.5)
		-- effect:playAnimation("effects/jiaohuan_tx_yjhd.ccbi")
		-- -- effect:playAnimation("effects/jiaohuan_tx_yjhd.ccbi",function(ccbOwner)
		-- -- 	effect:removeFromParentAndCleanup(true)
		-- -- 	end)

		if self._changeEffect[idx] == nil then
			self._changeEffect[idx] = QUIWidgetAnimationPlayer.new()
			headIcon:addChild(self._changeEffect[idx])
		end
		self._changeEffect[idx]:setVisible(true)
		self._changeEffect[idx]:setScale(1.5)
		self._changeEffect[idx]:playAnimation("effects/jiaohuan_tx_yjhd.ccbi")

	end
end


function QUIWidgetQuickChange:showSelectEffect(idx)

	local headIcon = self._headIconTbl[idx]
	
	if self._selectEffect == nil then
		self._selectEffect = {}
	end

	if headIcon then
		if self._selectEffect[idx] == nil then
			self._selectEffect[idx] = QUIWidgetAnimationPlayer.new()
			headIcon:addChild(self._selectEffect[idx])
		end
		self._selectEffect[idx]:setVisible(true)
		self._selectEffect[idx]:setScale(1.5)
		self._selectEffect[idx]:playAnimation("effects/xuanzhong_tx_yjhd.ccbi", nil, nil, false)
	end
end

function QUIWidgetQuickChange:hideSelectEffect()
	for k,v in pairs(self._selectEffect or {}) do
		v:setVisible(false)
	end
end


function QUIWidgetQuickChange:_onTriggerDetail(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_detail) == false then return end
	app.sound:playSound("common_small")

	self:dispatchEvent({name = QUIWidgetQuickChange.EVENT_CLICK_DETAIL, trialNum = self._trialNum})
end

function QUIWidgetQuickChange:_clickHeroHead(event)
	if event == nil then return end

	local idx = event.target:getHeadIndex()
	self:dispatchEvent({name = QUIWidgetQuickChange.EVENT_CLICK_HERO_HEAD, trialNum = self._trialNum , idx = idx})
end

function QUIWidgetQuickChange:_onTriggerChange(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_change) == false then return end
	app.sound:playSound("common_small")

	self:dispatchEvent({name = QUIWidgetQuickChange.EVENT_CLICK_TEAM_CHANGE, trialNum = self._trialNum})
end

function QUIWidgetQuickChange:_onTriggerDevelop(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_develop) == false then return end
	app.sound:playSound("common_small")

	self:dispatchEvent({name = QUIWidgetQuickChange.EVENT_CLICK_TEAM_CHANGE, trialNum = self._trialNum})
end

function QUIWidgetQuickChange:getContentSize()
	return self._ccbOwner.sp_bg:getContentSize()
end


return QUIWidgetQuickChange