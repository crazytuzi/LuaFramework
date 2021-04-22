-- @Author: xurui
-- @Date:   2017-04-06 16:36:44
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-10-29 10:59:52
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetHeroSparDetailClient = class("QUIWidgetHeroSparDetailClient", QUIWidget)

local QNavigationController = import("....controllers.QNavigationController")
local QUIViewController = import("...QUIViewController")
local QStaticDatabase = import("....controllers.QStaticDatabase")
local QUIWidgetHeroSparDetailSuitClient = import(".QUIWidgetHeroSparDetailSuitClient")
local QUIWidgetEquipmentAvatar = import("...widgets.QUIWidgetEquipmentAvatar")

function QUIWidgetHeroSparDetailClient:ctor(options)
	local ccbFile = "ccb/Widget_spar_info2.ccbi"
	local callBack = {
		-- {ccbCallbackName = "", callback = handler(self, self._)},
	}
	QUIWidgetHeroSparDetailClient.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self._posY = self._ccbOwner.node_suit:getPositionY()
	self._iconPos = ccp(self._ccbOwner.sp_spar_icon:getPositionX(),self._ccbOwner.sp_spar_icon:getPositionY())

	self._suitClient = {}
end

function QUIWidgetHeroSparDetailClient:onEnter()
	self:initAction() 

end

function QUIWidgetHeroSparDetailClient:onExit()
end

function QUIWidgetHeroSparDetailClient:initAction()
	local arr = CCArray:create()
	arr:addObject(CCMoveTo:create(1, ccp(self._iconPos.x,self._iconPos.y + 10)))
	arr:addObject(CCMoveTo:create(1, self._iconPos))
	self._ccbOwner.sp_spar_icon:runAction(CCRepeatForever:create(CCSequence:create(arr)))
end 

function QUIWidgetHeroSparDetailClient:setDetailInfo(actorId, sparId)
	self._width = 0
	self._height = 200

	self._actorId = actorId
	self._sparInfo = remote.spar:getSparsBySparId(sparId)

	local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(self._sparInfo.itemId)
	q.setAptitudeShow(self._ccbOwner, nil , itemConfig.gemstone_quality)

	-- local props = self:setPropInfo(self._sparInfo.prop or {})
	local props = remote.spar:setPropInfo(self._sparInfo.prop or {})


	self._ccbOwner.node_ss_detail:setVisible(itemConfig.gemstone_quality == APTITUDE.SS)
	self._ccbOwner.node_s_detail:setVisible(itemConfig.gemstone_quality ~= APTITUDE.SS)
	local itemNameNode = nil
	if itemConfig.gemstone_quality == APTITUDE.SS then
		self._height = 410
		local visibleNum = #props / 2
		self._height = self._height - (4 - visibleNum) * 30
		self._ccbOwner.node_suit:setPositionY(self._posY + (4 - visibleNum) * 30 )
		itemNameNode = self._ccbOwner.tf_ss_item_name
		for i = 1, 8 do
			self._ccbOwner["tf_ss_value"..i]:setVisible(props[i] ~= nil)
			self._ccbOwner["tf_ss_name"..i]:setVisible(props[i] ~= nil)
			if props[i] ~= nil then
				self._ccbOwner["tf_ss_value"..i]:setString(" +"..props[i].value)
				self._ccbOwner["tf_ss_name"..i]:setString(props[i].name.."：")
			end
		end

   	 	local frame =QSpriteFrameByPath(QResPath("ss_spar_icon")[tostring(self._sparInfo.itemId)])
	    if frame then
	    	self._ccbOwner.sp_spar_icon:setVisible(true)
	        self._ccbOwner.sp_spar_icon:setDisplayFrame(frame)
	    end
	    local grade = self._sparInfo.grade or 0
	    grade = grade / 5
		if grade == 0 then
			self._ccbOwner.node_hero_empty_star:setVisible(true)
			self._ccbOwner.node_hero_star:setVisible(false)
		else
			self._ccbOwner.node_hero_empty_star:setVisible(false)
			self._ccbOwner.node_hero_star:setVisible(true)
			for i=1,5 do
				self._ccbOwner["star"..i]:setVisible(i<=grade)
			end
		end
	else
		self._ccbOwner.node_suit:setPositionY(-340)

		if self._itemAvatar == nil then
			self._itemAvatar = QUIWidgetEquipmentAvatar.new()
			self._ccbOwner.equ_node:addChild(self._itemAvatar)
		end
		self._itemAvatar:setSparInfo(itemConfig, 19, 1.0)

		itemNameNode = self._ccbOwner.tf_item_name
		for i = 1, 4 do
			self._ccbOwner["tf_value"..i]:setVisible(props[i] ~= nil)
			self._ccbOwner["tf_name"..i]:setVisible(props[i] ~= nil)
			if props[i] ~= nil then
				self._ccbOwner["tf_value"..i]:setString(" +"..props[i].value)
				self._ccbOwner["tf_name"..i]:setString(props[i].name.."：")
			end
		end
	end

	itemNameNode:setString("LV."..self._sparInfo.level.."  "..itemConfig.name)
	local fontColor = UNITY_COLOR_LIGHT[EQUIPMENT_QUALITY[itemConfig.colour]]
	itemNameNode:setColor(fontColor)
	itemNameNode = setShadowByFontColor(itemNameNode, fontColor)


	local UIHeroModle = remote.herosUtil:getUIHeroByID(self._actorId)
	local itemInfo1 = UIHeroModle:getSparInfoByPos(1).info or {}
	local itemInfo2 = UIHeroModle:getSparInfoByPos(2).info or {}
	local minGrade = UIHeroModle:getHeroSparMinGrade()
	local suitInfo = remote.spar:getSuitInfoById(sparId, actorId)
	local height = 0
	for i = 1, #suitInfo do
		if self._suitClient[i] == nil then
			self._suitClient[i] = QUIWidgetHeroSparDetailSuitClient.new()
			self._ccbOwner.node_suit:addChild(self._suitClient[i])
		end
		self._suitClient[i]:setSuitInfo(suitInfo[i], minGrade, itemInfo1.itemId, itemInfo2.itemId)
		local contentSize = self._suitClient[i]:getContentSize()
		self._suitClient[i]:setPositionY(height)
		height = height - contentSize.height
		self._height = self._height + contentSize.height
		self._width = contentSize.width

	end
end

function QUIWidgetHeroSparDetailClient:getSuitClient()
	return self._suitClient or {}
end

-- function QUIWidgetHeroSparDetailClient:setPropInfo(itemInfo)
-- 	local prop = {}
-- 	local index = 1
-- 	if itemInfo.hp_value and itemInfo.hp_value > 0 then
-- 		prop[index] = {}
-- 		prop[index].value = itemInfo.hp_value
-- 		prop[index].name = "生    命："
-- 		index = index + 1
-- 	end
-- 	if itemInfo.attack_value and itemInfo.attack_value > 0 then
-- 		prop[index] = {}
-- 		prop[index].value = itemInfo.attack_value
-- 		prop[index].name = "攻    击："
-- 		index = index + 1
-- 	end
-- 	if itemInfo.armor_physical and itemInfo.armor_physical > 0 then
-- 		prop[index] = {}
-- 		prop[index].value = itemInfo.armor_physical
-- 		prop[index].name = "物理防御："
-- 		index = index + 1
-- 	end
-- 	if itemInfo.armor_magic and itemInfo.armor_magic > 0 then
-- 		prop[index] = {}
-- 		prop[index].value = itemInfo.armor_magic
-- 		prop[index].name = "法术防御："
-- 		index = index + 1
-- 	end
-- 	if itemInfo.hp_percent and itemInfo.hp_percent > 0 then
-- 		prop[index] = {}
-- 		prop[index].value = (itemInfo.hp_percent * 100).."%"
-- 		prop[index].name = "生命百分比："
-- 		index = index + 1
-- 	end
-- 	if itemInfo.attack_percent and itemInfo.attack_percent > 0 then
-- 		prop[index] = {}
-- 		prop[index].value = (itemInfo.attack_percent * 100).."%"
-- 		prop[index].name = "攻击百分比："
-- 		index = index + 1
-- 	end
-- 	if itemInfo.armor_physical_percent and itemInfo.armor_physical_percent > 0 then
-- 		prop[index] = {}
-- 		prop[index].value = (itemInfo.armor_physical_percent * 100).."%"
-- 		prop[index].name = "物防百分比："
-- 		index = index + 1
-- 	end
-- 	if itemInfo.armor_magic_percent and itemInfo.armor_magic_percent > 0 then
-- 		prop[index] = {}
-- 		prop[index].value = (itemInfo.armor_magic_percent * 100).."%"
-- 		prop[index].name = "法防百分比："
-- 		index = index + 1
-- 	end

-- 	--全队属性
-- 	if itemInfo.team_hp_value and itemInfo.team_hp_value > 0 then
-- 		prop[index] = {}
-- 		prop[index].key = "team_hp_value"
-- 		prop[index].value = itemInfo.team_hp_value
-- 		prop[index].name = "全队生命："
-- 		index = index + 1
-- 	end
-- 	if itemInfo.team_hp_percent and itemInfo.team_hp_percent > 0 then
-- 		prop[index] = {}
-- 		prop[index].key = "team_hp_percent"
-- 		prop[index].value = (itemInfo.team_hp_percent * 100).."%"
-- 		prop[index].name = "全队生命："
-- 		index = index + 1
-- 	end
-- 	if itemInfo.team_attack_value and itemInfo.team_attack_value > 0 then
-- 		prop[index] = {}
-- 		prop[index].key = "team_attack_value"
-- 		prop[index].value =itemInfo.team_attack_value
-- 		prop[index].name = "全队攻击："
-- 		index = index + 1
-- 	end
-- 	if itemInfo.team_attack_percent and itemInfo.team_attack_percent > 0 then
-- 		prop[index] = {}
-- 		prop[index].key = "team_attack_percent"
-- 		prop[index].value = (itemInfo.team_attack_percent * 100).."%"
-- 		prop[index].name = "全队攻击："
-- 		index = index + 1
-- 	end


-- 	if itemInfo.team_armor_physical and itemInfo.team_armor_physical > 0 then
-- 		prop[index] = {}
-- 		prop[index].key = "team_armor_physical"
-- 		prop[index].value = itemInfo.team_armor_physical
-- 		prop[index].name = "全队物防："
-- 		index = index + 1
-- 	end
-- 	if itemInfo.team_armor_physical_percent and itemInfo.team_armor_physical_percent > 0 then
-- 		prop[index] = {}
-- 		prop[index].key = "team_armor_physical_percent"
-- 		prop[index].value = (itemInfo.team_armor_physical_percent * 100).."%"
-- 		prop[index].name = "全队物防："
-- 		index = index + 1
-- 	end
-- 	if itemInfo.team_armor_magic and itemInfo.team_armor_magic > 0 then
-- 		prop[index] = {}
-- 		prop[index].key = "team_armor_magic"
-- 		prop[index].value =itemInfo.team_armor_magic
-- 		prop[index].name = "全队法防："
-- 		index = index + 1
-- 	end
-- 	if itemInfo.team_armor_magic_percent and itemInfo.team_armor_magic_percent > 0 then
-- 		prop[index] = {}
-- 		prop[index].key = "team_armor_magic_percent"
-- 		prop[index].value = (itemInfo.team_armor_magic_percent * 100).."%"
-- 		prop[index].name = "全队法防："
-- 		index = index + 1
-- 	end


-- 	return prop 
-- end 

function QUIWidgetHeroSparDetailClient:getContentSize()
	return CCSize(self._width, self._height)
end

return QUIWidgetHeroSparDetailClient