local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroInfoMax = class("QUIWidgetHeroInfoMax", QUIWidget)
local QActorProp = import("...models.QActorProp")
local QUIWidgetEquipmentAvatar = import("..widgets.QUIWidgetEquipmentAvatar")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetActorDisplay = import(".actorDisplay.QUIWidgetActorDisplay")

function QUIWidgetHeroInfoMax:ctor(options, callBacks)
	local ccbFile = "ccb/Widget_HeroEquipment_Evolution_full.ccbi"
	QUIWidgetHeroInfoMax.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self.posY = self._ccbOwner.tf_item_name:getPositionY()
	self._ccbOwner.tf_item_name:setPositionY(self.posY-35)
	self._ccbOwner.btn_reset:setVisible(false)
	self:resetAll()
end

--重置界面上的属性显示
function QUIWidgetHeroInfoMax:resetAll()
	for i=1,4 do
		local tf1 = self._ccbOwner["tf_name"..i]
		if tf1 ~= nil then
			tf1:setVisible(false)
		end
		local tf2 = self._ccbOwner["tf_value"..i]
		if tf2 ~= nil then
			tf2:setVisible(false)
		end
	end
	self._ccbOwner.equ_node:removeAllChildren()
end

--设置图片
function QUIWidgetHeroInfoMax:setMaxSpByPlist(plist, name)
	if plist then
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(plist)
	end
	self._ccbOwner.sp_max:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(name))
end

--设置装备avatar信息
function QUIWidgetHeroInfoMax:setEquipment(actorId, itemId)
	local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(itemId)
	local itemAvatar = QUIWidgetEquipmentAvatar.new()
	self._ccbOwner.equ_node:addChild(itemAvatar)
	itemAvatar:setEquipmentInfo(itemConfig, actorId)

	self._ccbOwner.tf_item_name:setString(itemConfig.name)
	local fontColor = COLORS.j
	local breaklevel = remote.herosUtil:getHeroEquipmentEvolutionByID(actorId, itemId)
	local level,color = remote.herosUtil:getBreakThrough(breaklevel)
	if color ~= nil then
		fontColor = BREAKTHROUGH_COLOR_LIGHT[color]
	end
	self._ccbOwner.tf_item_name:setColor(fontColor)
	self._ccbOwner.tf_item_name = setShadowByFontColor(self._ccbOwner.tf_item_name, fontColor)
end

--设置装备avatar信息
function QUIWidgetHeroInfoMax:setAvatar(charaterId)
	local avatar = QUIWidgetActorDisplay.new(charaterId)
	avatar:setScaleX(-1)
	avatar:setPositionY(-80)
	self._ccbOwner.equ_node:addChild(avatar)

	local mountConfig = QStaticDatabase:sharedDatabase():getCharacterByID(charaterId)
	self._ccbOwner.tf_item_name:setString(mountConfig.name)
	local color = remote.mount:getColorByMountId(charaterId)
	color = BREAKTHROUGH_COLOR_LIGHT[color]
	self._ccbOwner.tf_item_name:setColor(color)
end

--设置属性到界面上
function QUIWidgetHeroInfoMax:setProp(prop)
	local index = 1
	for _,field in ipairs(QActorProp._uiFields) do
		local propValue = prop[field.fieldName]
		if propValue ~= nil and propValue > 0 then
			if field.handlerFun ~= nil then
				propValue = field.handlerFun(propValue)
			end
			local tf1 = self._ccbOwner["tf_name"..index]
			if tf1 ~= nil then
				tf1:setString(field.name.."：")
				tf1:setVisible(true)
			end
			local tf2 = self._ccbOwner["tf_value"..index]
			if tf2 ~= nil then
				tf2:setString("+ "..propValue)
				tf2:setVisible(true)
			end
			index = index + 1
			if self._ccbOwner["tf_name"..index] == nil then
				return
			end
		end
	end
end

return QUIWidgetHeroInfoMax