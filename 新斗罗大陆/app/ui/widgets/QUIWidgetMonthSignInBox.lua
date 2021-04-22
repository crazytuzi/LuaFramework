-- 
-- zxs
-- 月度签到box
-- 

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMonthSignInBox = class("QUIWidgetMonthSignInBox", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

QUIWidgetMonthSignInBox.EVENT_CLICK = "EVENT_CLICK"

function QUIWidgetMonthSignInBox:ctor(options)
	local ccbFile = "ccb/Widget_DailySignln_award.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
    }
    QUIWidgetMonthSignInBox.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._ccbOwner.sp_is_done:setShaderProgram(qShader.Q_ProgramColorLayer)
    self._ccbOwner.sp_is_done:setColor(ccc3(0, 0, 0))
    self._ccbOwner.sp_is_done:setOpacity(0.5 * 255)
    
	self._posX = self._ccbOwner.tf_num:getPositionX()
end

function QUIWidgetMonthSignInBox:initGLLayer(glLayerIndex)
    self._glLayerIndex = glLayerIndex or 1
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_normal, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_is_ready, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_check_vip, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_item, self._glLayerIndex)
    if self._itemBox then
        self._glLayerIndex = self._itemBox:initGLLayer(self._glLayerIndex)
    end
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_num, self._glLayerIndex) -- 55
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_effect, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_vip_bg, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_vip_level, self._glLayerIndex) 
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_double , self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_is_done, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_choose, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.btn_click, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_buqian, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_get, self._glLayerIndex)

    return self._glLayerIndex
end

function QUIWidgetMonthSignInBox:setInfo(awardInfo)
	self._awardInfo = awardInfo

	if self._itemBox == nil then
    	self._itemBox = QUIWidgetItemsBox.new()
    	self._ccbOwner.node_item:addChild(self._itemBox)
	end
	self:initGLLayer()
	self._itemBox:setGoodsInfo(awardInfo.id, awardInfo.itemType, 0)
	self._ccbOwner.tf_num:setString("x"..awardInfo.count)
	self._ccbOwner.tf_num:setPositionX(self._posX+0)--待确定

	self:setAwardStated(awardInfo.stated)
	self:showVipStated(awardInfo.vipLevel)
end

function QUIWidgetMonthSignInBox:setAwardStated(stated)
	self._ccbOwner.sp_buqian:setVisible(false)
	self._ccbOwner.sp_choose:setVisible(false)
	self._ccbOwner.sp_normal:setVisible(true)
	self._ccbOwner.sp_is_done:setVisible(false)
    self._ccbOwner.node_effect:setVisible(false)
	self._ccbOwner.sp_is_ready:setVisible(false)
    self._ccbOwner.sp_check_vip:setVisible(false)
    self._ccbOwner.sp_get:setVisible(false)

	if self._awardInfo.effect then
   	 	self._ccbOwner.node_effect:setVisible(true)
	end

	if stated == remote.monthSignIn.MONTH_SINGIN_IS_DONE then
		self._ccbOwner.sp_choose:setVisible(true)
		self._ccbOwner.sp_is_done:setVisible(true)
		self._ccbOwner.node_effect:setVisible(false)

	elseif stated == remote.monthSignIn.MONTH_SINGIN_IS_READY then
		self._ccbOwner.sp_is_ready:setVisible(true)
    	self._ccbOwner.sp_get:setVisible(true)

	elseif stated == remote.monthSignIn.MONTH_SINGIN_IS_READY_VIP then
		self._ccbOwner.sp_check_vip:setVisible(true)

	elseif stated == remote.monthSignIn.MONTH_SINGIN_IS_PATCH then
		self._ccbOwner.sp_buqian:setVisible(true)
		local currentNum = remote.monthSignIn:getCurrentPatchNum()
		if currentNum > 0 then
			self._ccbOwner.sp_is_ready:setVisible(true)
	    else
			self._ccbOwner.sp_is_done:setVisible(true)
	    end
	end
end

function QUIWidgetMonthSignInBox:showVipStated(vipLevel)
	self._ccbOwner.node_vip:setVisible(vipLevel ~= nil)
	self._ccbOwner.tf_vip_level:setString("V"..(vipLevel or 0))
end

function QUIWidgetMonthSignInBox:registerItemBoxPrompt( index, list )
	if self._itemBox then
		list:registerItemBoxPrompt(index, 1, self._itemBox)
	end
end

function QUIWidgetMonthSignInBox:getContentSize()
	local size = self._ccbOwner.sp_normal:getContentSize()
	size.width = size.width+4	
	size.height = size.height+4	
	return size
end

function QUIWidgetMonthSignInBox:_onTriggerClick()
	self:dispatchEvent({name = QUIWidgetMonthSignInBox.EVENT_CLICK, info = self._awardInfo})
end

return QUIWidgetMonthSignInBox
