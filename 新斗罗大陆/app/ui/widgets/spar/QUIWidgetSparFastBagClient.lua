-- @Author: xurui
-- @Date:   2017-04-05 11:14:08
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-06-23 14:53:38
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetSparFastBagClient = class("QUIWidgetSparFastBagClient", QUIWidget)

local QNavigationController = import("....controllers.QNavigationController")
local QUIViewController = import("...QUIViewController")
local QStaticDatabase = import("....controllers.QStaticDatabase")
local QUIWidgetSparBox = import(".QUIWidgetSparBox")
local QListView = import("....views.QListView")

function QUIWidgetSparFastBagClient:ctor(options)
	local ccbFile = "ccb/Widget_Baoshi_kehuishou.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerWear", callback = handler(self, self._onTriggerWear)},
		{ccbCallbackName = "onTriggerInfo", callback = handler(self, self._onTriggerInfo)},
	}
	QUIWidgetSparFastBagClient.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetSparFastBagClient:onEnter()
end

function QUIWidgetSparFastBagClient:onExit()
end

function QUIWidgetSparFastBagClient:resetAll()
	self._ccbOwner.sp_tuijian:setVisible(false)
	self._ccbOwner.tf_desc:setVisible(true)
	for i = 1, 4 do
		self._ccbOwner["tf_prop"..i]:setVisible(false)
	end

	self._ccbOwner.btn_icon:setVisible(false)
	self._ccbOwner.sp_suit:setVisible(false)
	self._ccbOwner.tf_active_suit:setVisible(false)
	self._ccbOwner.tf_count:setVisible(false)
	self._ccbOwner.tf_cost:setVisible(false)
	self._ccbOwner.sp_cost:setVisible(false)
end

function QUIWidgetSparFastBagClient:setInfo(param)
	self:resetAll()

	self._sparInfo = param.info
	self._sparType = param.sparType
	self._callback = param.callback
	self._otherSparInfo = param.otherSparInfo
	self._sparPos = param.sparPos

	if param.recycleType == 1 then
		self._ccbOwner.buttonText:setString("放入分解")
	elseif param.recycleType == 2 then
		self._ccbOwner.buttonText:setString("放入重生")
	else
		self._ccbOwner.buttonText:setString("装 备")
	end

	if self._icon == nil then
		self._icon = QUIWidgetSparBox.new()
		self._ccbOwner.node_icon:addChild(self._icon)
		self._icon:setPromptIsOpen(true)
	end
	self._icon:setGemstoneInfo(self._sparInfo, self._sparPos)
	self._icon:setName("")

	local itemConfig = db:getItemByID(self._sparInfo.itemId)
	self._ccbOwner.tf_name:setString(itemConfig.name)

	local fontColor = UNITY_COLOR_LIGHT[EQUIPMENT_QUALITY[itemConfig.colour]]
	self._ccbOwner.tf_name:setColor(fontColor)
	self._ccbOwner.tf_name = setShadowByFontColor(self._ccbOwner.tf_name, fontColor)

	self._ccbOwner.tf_type:setString("")
	if self._sparInfo.count > 1 then
		self._ccbOwner.tf_type:setString("拥有："..self._sparInfo.count)
		self._ccbOwner.tf_type:setPositionX(-25)
		self._ccbOwner.tf_type:setColor(ccc3(76, 32, 0))
	end

	if itemConfig and itemConfig.gemstone_quality and itemConfig.gemstone_quality >= APTITUDE.SS then
		self._ccbOwner.btn_info:setVisible(true)
	else
		self._ccbOwner.btn_info:setVisible(false)
	end


	self._propIndex = 1
	if self._sparInfo.prop ~= nil then

		local propDesc = remote.spar:setPropInfo(self._sparInfo.prop,true ,true)
		for i,v in ipairs(propDesc or {}) do
			self:setPropText(v.value or "0" ,v.name or "")
		end
		-- self:setProp(self._sparInfo.prop.hp_value, "生命＋%d")
		-- self:setProp(self._sparInfo.prop.attack_value, "攻击＋%d")
		-- self:setProp(self._sparInfo.prop.armor_physical, "物防＋%d")
		-- self:setProp(self._sparInfo.prop.armor_magic, "法防＋%d")
		-- self:setProp((self._sparInfo.prop.hp_percent or 0)*100, "生命＋%d%%")
		-- self:setProp((self._sparInfo.prop.attack_percent or 0)*100, "攻击＋%d%%")
		-- self:setProp((self._sparInfo.prop.armor_physical_percent or 0)*100, "物防＋%d%%")
		-- self:setProp((self._sparInfo.prop.armor_magic_percent or 0)*100, "法防＋%d%%")
	end

	if self._otherSparInfo ~= nil and next(self._otherSparInfo) ~= nil then
		local itemId1 = self._sparPos == 1 and self._sparInfo.itemId or self._otherSparInfo.itemId
		local itemId2 = self._sparPos == 1 and self._otherSparInfo.itemId or self._sparInfo.itemId
		local minGrade = math.min(self._sparInfo.grade, self._otherSparInfo.grade)
		self._activeSuit = db:getActiveSparSuitInfoBySparId(itemId1, itemId2, minGrade+1)
		if q.isEmpty(self._activeSuit) == false then
			local gardeName, level = remote.herosUtil:getGradeNameByGradeLevel(self._activeSuit.star_num)
			self._ccbOwner.tf_active_suit:setString(string.format("可激活%s%s%s效果", self._activeSuit.suit_name, level, gardeName))
			self._ccbOwner.tf_active_suit:setVisible(true)
		end
	end

	if self._sparInfo.actorId ~= nil and self._sparInfo.actorId > 0 then
		local charactConfig = db:getCharacterByID(self._sparInfo.actorId)
		local desc = ""
		if charactConfig ~= nil and charactConfig.name ~= nil then
			desc = charactConfig.name.."装备中"
		end
		self._ccbOwner.tf_desc:setString(desc) 
		self._ccbOwner.node_btn:retain()
		self._ccbOwner.node_btn:removeFromParent()
		self._ccbOwner.node_wear:addChild(self._ccbOwner.node_btn)
		self._ccbOwner.node_btn:release()
		self._ccbOwner.tf_active_suit:setVisible(false)
	elseif self._activeSuit ~= nil and next(self._activeSuit) ~= nil then
		self._ccbOwner.node_btn:retain()
		self._ccbOwner.node_btn:removeFromParent()
		self._ccbOwner.node_wear:addChild(self._ccbOwner.node_btn)
		self._ccbOwner.node_btn:release()
		self._ccbOwner.tf_desc:setString("")
	else
		self._ccbOwner.tf_desc:setString("")
		self._ccbOwner.node_btn:retain()
		self._ccbOwner.node_btn:removeFromParent()
		self._ccbOwner.node_nowear:addChild(self._ccbOwner.node_btn)
		self._ccbOwner.node_btn:release()
	end

end

function QUIWidgetSparFastBagClient:setProp(prop, value)
	if self._propIndex > 4 then return end
	if prop ~= nil and prop > 0 then
		self._ccbOwner["tf_prop"..self._propIndex]:setString(string.format(value, prop))
		self._ccbOwner["tf_prop"..self._propIndex]:setVisible(true)
		self._propIndex = self._propIndex + 1
	else
		self._ccbOwner["tf_prop"..self._propIndex]:setVisible(false)
	end
end


function QUIWidgetSparFastBagClient:setPropText(value , prop)
	if self._propIndex > 4 then return end
	if prop ~= nil then
		self._ccbOwner["tf_prop"..self._propIndex]:setString(prop.."+"..value)
		self._ccbOwner["tf_prop"..self._propIndex]:setVisible(true)
		self._propIndex = self._propIndex + 1
	else
		self._ccbOwner["tf_prop"..self._propIndex]:setVisible(false)
	end
end

function QUIWidgetSparFastBagClient:getContentSize()
	return self._ccbOwner.normal_banner:getContentSize()
end

function QUIWidgetSparFastBagClient:_onTriggerWear()
	if e ~= nil then
		app.sound:playSound("common_small")
	end
	if self._callback then
		self._callback({info = self._sparInfo})
	end
end


function QUIWidgetSparFastBagClient:_onTriggerInfo()
	app.sound:playSound("common_small")
  	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSparAttrInfo"
  		,options = {actor_prop = self._sparInfo.prop, subtitle = "属性详情"}}, {isPopCurrentDialog = false})
end


function QUIWidgetSparFastBagClient:registerItemBoxPrompt( index, list )
    list:registerClickHandler(index, "sparBox"..index, function(x, y)
    		if QListView.isTouchInside(self._icon, x, y) then
    			return true
    		else
    			return false
    		end
    	end, nil, function()
    		self._icon:_onTriggerTouch(CCControlEventTouchDown)
    	end, nil, nil, self._icon)
end

return QUIWidgetSparFastBagClient