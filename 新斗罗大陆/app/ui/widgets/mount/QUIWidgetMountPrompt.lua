
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetMountPrompt = class("QUIWidgetMountPrompt", QUIWidget)

local QStaticDatabase = import("....controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("...widgets.QUIWidgetItemsBox")
local QColorLabel = import("....utils.QColorLabel")
local QMountProp = import("....models.QMountProp")

function QUIWidgetMountPrompt:ctor(options)
  	local ccbFile = "ccb/Dialog_mount_tips.ccbi"
  	local callBacks = {}
  	QUIWidgetMountPrompt.super.ctor(self, ccbFile, callBacks, options)

  	if options then
  		self._itemId = options.itemId
  		self._itemType = options.itemType
  	end

  	self._width = 350
  	self._lineHeight = 22
  	self._size = self._ccbOwner.node_bg:getContentSize()

  	self:setItemInfo()
  	self:setMountProp()
  	self:setSkillInfo()
end

function QUIWidgetMountPrompt:setItemInfo()
  	local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(self._itemId)
  	local itemType = ITEM_TYPE.ITEM
	local contentName = "拥有："
	local content = ""
  	if self._itemType == ITEM_TYPE.ITEM then
	    local mountId = QStaticDatabase:sharedDatabase():getActorIdBySoulId(self._itemId, 0) or 0
    	self._mountId = tonumber(mountId)

    	local gradeLevel = 0
    	local mountInfo = remote.mount:getMountById(mountId)
    	if mountInfo ~= nil then
			gradeLevel = mountInfo.grade+1 or 0
		end

	    local info = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(mountId, gradeLevel) or {}
	  	local needNum = info.soul_gem_count or 0
	  	local currentNum = remote.items:getItemsNumByID(self._itemId) or 0
	  	if needNum > 0 then
			content = currentNum.."/"..needNum
		else
			content = currentNum
		end
	else
	  	itemConfig = QStaticDatabase:sharedDatabase():getCharacterByID(self._itemId)
	  	itemType = ITEM_TYPE.ZUOQI
	  	contentName = ""
	  	content = ""
	  	self._mountId = tonumber(self._itemId)
  	end

	local icon = QUIWidgetItemsBox.new()
	self._ccbOwner.node_icon:addChild(icon)
	icon:setGoodsInfo(self._itemId, itemType)
	if self._itemType == ITEM_TYPE.ZUOQI then
		local sabcInfo = QStaticDatabase:sharedDatabase():getSABCByQuality(itemConfig.aptitude)
		icon:showSabc(sabcInfo.lower)
	end

	self._ccbOwner.tf_name:setString(itemConfig.name)
	-- self._ccbOwner.tf_name:setPositionY(self._ccbOwner.tf_name:getPositionY()-10)
	local color = remote.mount:getColorByMountId(self._mountId)
	color = QIDEA_QUALITY_COLOR[color]
	if color ~= nil then
		self._ccbOwner.tf_name:setColor(color)
	else
		self._ccbOwner.tf_name:setColor(ccc3(255,255, 255))
	end

	self._ccbOwner.tf_content_name:setString(contentName or "")
	self._ccbOwner.tf_type:setString(content or "")
end

function QUIWidgetMountPrompt:setMountProp()
	local mountInfo = remote.mount:getMountById(self._mountId)
	if not mountInfo then
		mountInfo = {zuoqiId = self._mountId, grade = 0, enhanceLevel = 1}
	end
	local mountProp = QMountProp.new(mountInfo)
	local prop = mountProp:getTotalProp()
	prop = self:setPropInfo(prop)
	local index = 1
	for i = 1, 4 do
		self._ccbOwner["tf_prop_"..i]:setVisible(true)
		if prop[i] ~= nil then
			self._ccbOwner["tf_prop_"..i]:setString(prop[i].name.." +"..prop[i].value)
			index = index + 1
		else
			self._ccbOwner["tf_prop_"..i]:setVisible(false)
		end
	end
end

function QUIWidgetMountPrompt:setSkillInfo()
	local grade = 0
	local mountInfo = remote.mount:getMountById(self._mountId)
	if mountInfo ~= nil and self._itemType ~= ITEM_TYPE.ITEM then
		grade = mountInfo.grade or 0
	end


	local itemConfig = QStaticDatabase:sharedDatabase():getCharacterByID(self._mountId)

	local height1 , height2 =0,0
	if itemConfig.zuoqi_pj then   --配件暗器不显示技能
		local skillDesc1 = "配件暗器不能装备于魂师上，无主力和援助效果，只能用于SS或SS+暗器的配件"
		self._ccbOwner.tf_skill_name1:setString("配件暗器")
		self._ccbOwner.tf_skill_content1:setString(skillDesc1)
		self._ccbOwner.node_content2:setVisible(false)
		local skillLength1 = q.wordLen(skillDesc1, 20, 20)
	    local count = math.ceil(skillLength1/self._width)
	    height1 = count*self._lineHeight
	else

		local info = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(self._mountId, grade) or {}
		local skills = string.split(info.zuoqi_skill_ms, ";")
	    local skillInfo1 = QStaticDatabase:sharedDatabase():getSkillByID(tonumber(skills[1]))
	    local skillInfo2 = QStaticDatabase:sharedDatabase():getSkillByID(tonumber(skills[2]))

		if skillInfo1 == nil then 
			app.tip:floatTip("skill 表还没配 "..skills[1].." 这个魂技的相关信息~~")
			return 
		end

		local skillDesc1 = QColorLabel.removeColorSign(skillInfo1.description or "")
		local skillDesc2 = QColorLabel.removeColorSign(skillInfo2.description or "")
		self._ccbOwner.tf_skill_name1:setString(skillInfo1.name or "")
		self._ccbOwner.tf_skill_name2:setString(skillInfo2.name or "")
		self._ccbOwner.tf_skill_content1:setString(skillDesc1 or "")
		self._ccbOwner.tf_skill_content2:setString(skillDesc2 or "")

		local posY = self._ccbOwner.node_content1:getPositionY()
		local skillLength1 = q.wordLen(skillDesc1, 20, 20)
	    local count = math.ceil(skillLength1/self._width) + 1
	    height1 = count*self._lineHeight
	    self._ccbOwner.node_content2:setPositionY(posY-50-height1)

	    local skillLength2 = q.wordLen(skillDesc2, 20, 20)
	    local count = math.ceil(skillLength2/self._width)
	    height2 = count*self._lineHeight
	end

    local height = height1+height2-6*self._lineHeight+10
    if height < 0 then
    	height = 0
    end
    self._ccbOwner.node_bg:setContentSize(CCSize(self._size.width, self._size.height+height))
end

function QUIWidgetMountPrompt:setPropInfo(mountInfo)
	local prop = {}
	local index = 1
	if mountInfo.attack_value and mountInfo.attack_value > 0 then
		prop[index] = {}
		prop[index].value = mountInfo.attack_value
		prop[index].name = "攻击"
		index = index + 1
	end
	if mountInfo.hp_value and mountInfo.hp_value > 0 then
		prop[index] = {}
		prop[index].value = mountInfo.hp_value
		prop[index].name = "生命"
		index = index + 1
	end
	if mountInfo.armor_physical and mountInfo.armor_physical > 0 then
		prop[index] = {}
		prop[index].value = mountInfo.armor_physical
		prop[index].name = "物防"
		index = index + 1
	end
	if mountInfo.armor_magic and mountInfo.armor_magic > 0 then
		prop[index] = {}
		prop[index].value = mountInfo.armor_magic
		prop[index].name = "法防"
		index = index + 1
	end

	return prop 
end 

return QUIWidgetMountPrompt