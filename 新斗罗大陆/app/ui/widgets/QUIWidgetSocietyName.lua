--[[	
	文件名称：QUIWidgetSocietyName.lua
	创建时间：2016-04-18 15:24:58
	作者：nieming
	描述：QUIWidgetSocietyName
]]

local QUIWidget = import(".QUIWidget")
local QUIWidgetSocietyName = class("QUIWidgetSocietyName", QUIWidget)
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QTextFiledScrollUtils = import("...utils.QTextFiledScrollUtils")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUnionAvatar = import("...utils.QUnionAvatar")
local QUIWidgetFloorIcon = import("..widgets.QUIWidgetFloorIcon")

--初始化
function QUIWidgetSocietyName:ctor(options)
	local ccbFile = "Widget_society_dragontrain_head.ccbi"
	local callBacks = {
	}
	QUIWidgetSocietyName.super.ctor(self,ccbFile,callBacks,options)
	--代码
	self:setInfo()
	
    self._textUpdate = QTextFiledScrollUtils.new()
    self._exit = true
end

--describe：onEnter 
function QUIWidgetSocietyName:onEnter()
	--代码
	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.UNION_WIDGET_NAME_UPDATE, QUIWidgetSocietyName.setInfo, self)
	if (not remote.user.userConsortia.consortiaId or remote.user.userConsortia.consortiaId == "") then	return end
	-- add by Kumo for update exp
	self._exit = true
	self:setInfo()
end

--describe：onExit 
function QUIWidgetSocietyName:onExit()
	--代码
	self._exit = nil
	self._textUpdate:stopUpdate()
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.UNION_WIDGET_NAME_UPDATE, QUIWidgetSocietyName.setInfo, self)

end

--describe：setInfo 
function QUIWidgetSocietyName:setInfo()
	--代码
	-- print("[Kumo] QUIWidgetSocietyName:setInfo()", self._oldExp, remote.union.consortia.exp, self._oldLevel, remote.union.consortia.level)
	-- self._ccbOwner.unionLevel:setString(string.format(remote.union.consortia.level and "LV"..20 or ""))
	if self._oldExp and self._oldExp ~= remote.union.consortia.exp and self._oldLevel == remote.union.consortia.level then
		local change = remote.union.consortia.exp - self._oldExp
		local effectName
		if change > 0 then
			effectName = "effects/Tips_add.ccbi"
		elseif change < 0 then 
			effectName = "effects/Tips_Decrease.ccbi"
		end

		if self._numEffect ~= nil then
			self._numEffect:disappear()
			self._numEffect = nil
		end
		self._numEffect = QUIWidgetAnimationPlayer.new()
		self._ccbOwner.effectNode:addChild(self._numEffect)
		self._numEffect:playAnimation(effectName, function(ccbOwner)

			if change < 0 then
				ccbOwner.content:setString(" -" .. math.floor(-change))
			else
				ccbOwner.content:setString(" +" .. math.floor(change))
			end
		end)
		self._textUpdate:addUpdate(self._oldExp, remote.union.consortia.exp, handler(self, self.setExpNum), 1)
	else
		-- if not self._expMask then
		-- 	self._expMask = self:_addMaskLayer(self._ccbOwner.expBar, self._ccbOwner.exp_mask)
		-- end
		local maxExp = QStaticDatabase:sharedDatabase():getSocietyLevel(remote.union.consortia.level).sociaty_exp
		-- self._expMask:setScaleX(remote.union.consortia.exp/maxExp)
		if not self._expBarClippingNode then
	        self._expBarClippingNode = q.newPercentBarClippingNode(self._ccbOwner.expBar)
	    end
	    local stencil = self._expBarClippingNode:getStencil()
	    if not self._totalStencilWidth and stencil then
	    	self._totalStencilWidth = stencil:getContentSize().width * stencil:getScaleX()
	    end
	    local expRatio = remote.union.consortia.exp/maxExp
	    stencil:setPositionX(-self._totalStencilWidth + expRatio*self._totalStencilWidth)

	    self._ccbOwner.expLabel:setString(string.format("%d/%d", remote.union.consortia.exp, maxExp))
	end
	local unionName = remote.union.consortia.name or ""
	unionName = ("LV "..(remote.union.consortia.level or "")).." "..unionName
	self._ccbOwner.unionName:setString(unionName)
	self._oldExp = remote.union.consortia.exp
	self._oldLevel = remote.union.consortia.level

	local unionAvatar = QUnionAvatar.new(remote.union.consortia.icon, false, false)
	unionAvatar:setConsortiaWarFloor(remote.union.consortia.consortiaWarFloor)
	self._ccbOwner.node_icon:removeAllChildren()
	self._ccbOwner.node_icon:addChild(unionAvatar)

	self:checkUnionFloor()
end

function QUIWidgetSocietyName:checkUnionFloor()
	local info = remote.unionDragonWar:getMyDragonFighterInfo()
	if info == nil or next(info) == nil then return end

	-- 段位icon
	if self._floorIcon == nil then
		self._floorIcon = QUIWidgetFloorIcon.new({isLarge = true})
		self._ccbOwner.node_floor:removeAllChildren()
 		self._ccbOwner.node_floor:addChild(self._floorIcon)
 	end
	self._floorIcon:setInfo(info.floor, "unionDragonWar")
	self._floorIcon:setShowName(false)
	self._ccbOwner.unionName:setPositionX(10)
end


function QUIWidgetSocietyName:setExpNum(num)
	-- print("[Kumo] QUIWidgetSocietyName:setExpNum()", num, self._exit, self._expMask)
	if self._exit then
		local maxExp = QStaticDatabase:sharedDatabase():getSocietyLevel(remote.union.consortia.level).sociaty_exp
		local stencil = self._expBarClippingNode:getStencil()
	    if not self._totalStencilWidth and stencil then
	    	self._totalStencilWidth = stencil:getContentSize().width * stencil:getScaleX()
	    end
	    local expRatio = num/maxExp
	    stencil:setPositionX(-self._totalStencilWidth + expRatio*self._totalStencilWidth)
		self._ccbOwner.expLabel:setString(string.format("%d/%d", remote.union.consortia.exp, maxExp))
	end
end

function QUIWidgetSocietyName:_addMaskLayer(ccb, mask)
    local width = ccb:getContentSize().width*ccb:getScaleX()
    local height = ccb:getContentSize().height*ccb:getScaleX()

    local maskLayer = CCLayerColor:create(ccc4(0,0,0,150), width, height)
    maskLayer:setAnchorPoint(ccp(0, 0))
    maskLayer:setPosition(ccp(0,0))
    local ccclippingNode = CCClippingNode:create()
    ccclippingNode:setStencil(maskLayer)
    ccb:retain()
    ccb:removeFromParent()
    ccclippingNode:addChild(ccb)
    ccb:setPosition(ccp(0,0))
    ccb:release()
    ccclippingNode:setPosition(ccp(0,0))

    mask:addChild(ccclippingNode)
    return maskLayer
end


--describe：getContentSize 
--function QUIWidgetSocietyName:getContentSize()
	----代码
--end

return QUIWidgetSocietyName
