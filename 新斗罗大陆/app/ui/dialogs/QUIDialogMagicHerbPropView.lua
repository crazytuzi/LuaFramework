local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMagicHerbPropView = class("QUIDialogMagicHerbPropView", QUIDialog)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QActorProp = import("...models.QActorProp")
local QScrollContain = import("...ui.QScrollContain")

function QUIDialogMagicHerbPropView:ctor(options)
	local ccbFile = "ccb/Dialog_magicHerb_propView.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", 				callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogMagicHerbPropView.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true
	self._ccbOwner.tf_title:setString("仙品属性")
	self._ccbOwner.tf_desc:setVisible(false)

	local wearInfoList = options.wearInfoList or {}

	local basicPropList = {}
	local attachPropList = {}
	local isSuitNum = 0
	local suitSkill = 0
	local suitSkillTypeName = ""
	local suitType = 0
	local minAptitude = 999
	local minBreedLv = 999
	local magicHerbType = 0
	local basicPropDic = {}
	local attachPropDic = {}
	local breedPropDic = {}
	local magicHerbSuitConfig = nil
	for _, wearInfo in ipairs(wearInfoList) do
		local magicHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid( wearInfo.sid )
		local magicHerbGradeConfig = remote.magicHerb:getMagicHerbGradeConfigByIdAndGrade(magicHerbItemInfo.itemId, magicHerbItemInfo.grade or 1)
		if magicHerbGradeConfig then
			-- QPrintTable(magicHerbGradeConfig)
			for key, value in pairs(magicHerbGradeConfig) do
				if QActorProp._field[key] then
					local name = QActorProp._field[key].uiName or QActorProp._field[key].name
					local num = value
					if basicPropDic[key] then
						basicPropDic[key] = {name = name, value = basicPropDic[key].value + num, isPercent = QActorProp._field[key].isPercent}
					else
						basicPropDic[key] = {name = name, value = num, isPercent = QActorProp._field[key].isPercent}
					end
				end
			end
		end

		local magicHerbUpLevelConfig = remote.magicHerb:getMagicHerbUpLevelConfigByIdAndLevel(magicHerbItemInfo.itemId, magicHerbItemInfo.level or 1)
		local upLevelExtraConfig = db:getMagicHerbEnhanceExtraConfigByBreedLvAndId(magicHerbItemInfo.level , magicHerbItemInfo.breedLevel or 0)
		if magicHerbUpLevelConfig then
			-- QPrintTable(magicHerbUpLevelConfig)
			for key, value in pairs(magicHerbUpLevelConfig) do
				if QActorProp._field[key] then
					local name = QActorProp._field[key].uiName or QActorProp._field[key].name
					local num = value
					if upLevelExtraConfig and upLevelExtraConfig[key] then
						num = num + upLevelExtraConfig[key]
					end
					if basicPropDic[key] then
						basicPropDic[key] = {name = name, value = basicPropDic[key].value + num, isPercent = QActorProp._field[key].isPercent}
					else
						basicPropDic[key] = {name = name, value = num, isPercent = QActorProp._field[key].isPercent}
					end
				end
			end
		end

		local magicHerbInfo = magicHerbItemInfo
		if magicHerbInfo then 
			local breedLv = magicHerbInfo.breedLevel or 0
			if breedLv < minBreedLv then
				minBreedLv = breedLv
			end
			local breedConfig = db:getMagicHerbBreedConfigByBreedLvAndId(magicHerbInfo.itemId, magicHerbInfo.breedLevel or 0)
			if breedConfig then
				for key, value in pairs(breedConfig) do
					if QActorProp._field[key] then
						local name = QActorProp._field[key].uiName or QActorProp._field[key].name
						local num = value
						if breedPropDic[key] then
							breedPropDic[key] = {name = name, value = breedPropDic[key].value + num, isPercent = QActorProp._field[key].isPercent}
						else
							breedPropDic[key] = {name = name, value = num, isPercent = QActorProp._field[key].isPercent}
						end
					end
				end
			end

			-- QPrintTable(magicHerbInfo)
			if magicHerbInfo.attributes then
				for _, value in ipairs(magicHerbInfo.attributes) do
					local key = value.attribute
					if key and QActorProp._field[key] then
						local name = QActorProp._field[key].uiName or QActorProp._field[key].name
						local num = value.refineValue or 0
						if attachPropDic[key] then
							attachPropDic[key] = {name = name, value = attachPropDic[key].value + num, isPercent = QActorProp._field[key].isPercent}
						else
							attachPropDic[key] = {name = name, value = num, isPercent = QActorProp._field[key].isPercent}
						end
					end
				end
			end
		end

		local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(magicHerbItemInfo.itemId)
		if magicHerbConfig then
			if suitType == 0 then
				suitType = magicHerbConfig.type
				minAptitude = magicHerbConfig.aptitude
				magicHerbType = magicHerbConfig.type
				suitSkillTypeName = magicHerbConfig.type_name
			end
			
			if magicHerbConfig.type == suitType then
				isSuitNum = isSuitNum + 1
				if magicHerbConfig.aptitude < minAptitude then
					minAptitude = magicHerbConfig.aptitude
					magicHerbType = magicHerbConfig.type
					suitSkillTypeName = magicHerbConfig.type_name
				end
			end
		end
	end

	if isSuitNum == 3 and magicHerbType > 0 and minAptitude ~= 9999 and minBreedLv ~=999 then
		magicHerbSuitConfig = remote.magicHerb:getMagicHerbSuitConfigByTypeAndAptitude(magicHerbType, minAptitude , minBreedLv)
		if magicHerbSuitConfig then
			suitSkill = magicHerbSuitConfig.skill
		end
	end

	local offsetY = -50
	local offsetX = 0
	local titleColor = COLORS.b
	local nameColor = COLORS.a
	local valueColor = COLORS.c

	local tf = CCLabelTTF:create("基本属性：", global.font_default, 20)
	tf:setAnchorPoint(0,1)
	tf:setColor(titleColor)
	tf:setPosition(ccp(20, offsetY))
	self._ccbOwner.node_prop:addChild(tf)
	offsetY = offsetY - 40

	--基本属性
	local index = 0
	offsetX = 20
	local createTTFFunc = function(v)
		if q.isEmpty(v) then return end

		if index > 0 and index%2 == 0 then
			offsetX = 20
			offsetY = offsetY - 35
		end
		local tf1 = CCLabelTTF:create(v.name.."：", global.font_default, 20)
		tf1:setAnchorPoint(0,1)
		tf1:setColor(nameColor)
		tf1:setPosition(ccp(offsetX, offsetY))
		self._ccbOwner.node_prop:addChild(tf1)
		offsetX = offsetX + 120

		v.value = q.getFilteredNumberToString(v.value, v.isPercent, 2)		
		local tf2 = CCLabelTTF:create("+"..v.value, global.font_default, 20)
		tf2:setAnchorPoint(0,1)
		tf2:setColor(valueColor)
		tf2:setPosition(ccp(offsetX, offsetY))
		self._ccbOwner.node_prop:addChild(tf2)
		offsetX = offsetX + 247
		index = index + 1			
	end

	createTTFFunc(basicPropDic["attack_value"])
	createTTFFunc(basicPropDic["attack_percent"])
	createTTFFunc(basicPropDic["hp_value"])
	createTTFFunc(basicPropDic["hp_percent"])
	createTTFFunc(basicPropDic["armor_physical"])
	createTTFFunc(basicPropDic["armor_physical_percent"])
	createTTFFunc(basicPropDic["armor_magic"])
	createTTFFunc(basicPropDic["armor_magic_percent"])

	offsetY = offsetY - 54

	-- 附加属性
	local tf = CCLabelTTF:create("转生属性：", global.font_default, 20)
	tf:setAnchorPoint(0,1)
	tf:setColor(titleColor)
	tf:setPosition(ccp(20, offsetY))
	self._ccbOwner.node_prop:addChild(tf)
	offsetY = offsetY - 40

	index = 0
	offsetX = 20
	
	createTTFFunc(attachPropDic["attack_value"])
	createTTFFunc(attachPropDic["attack_percent"])
	createTTFFunc(attachPropDic["hp_value"])
	createTTFFunc(attachPropDic["hp_percent"])
	createTTFFunc(attachPropDic["armor_physical"])
	createTTFFunc(attachPropDic["armor_physical_percent"])
	createTTFFunc(attachPropDic["armor_magic"])
	createTTFFunc(attachPropDic["armor_magic_percent"])
	createTTFFunc(attachPropDic["physical_damage_percent_attack"])
	createTTFFunc(attachPropDic["magic_damage_percent_attack"])
	createTTFFunc(attachPropDic["physical_damage_percent_beattack_reduce"])
	createTTFFunc(attachPropDic["magic_damage_percent_beattack_reduce"])
	createTTFFunc(attachPropDic["magic_treat_percent_beattack"])
	createTTFFunc(attachPropDic["wreck_rating"])
	createTTFFunc(attachPropDic["hit_rating"])
	createTTFFunc(attachPropDic["haste_rating"])
	createTTFFunc(attachPropDic["critical_rating"])
	offsetY = offsetY - 54

	-- 培育属性
	if not q.isEmpty(breedPropDic) then
		local tf = CCLabelTTF:create("培育属性：", global.font_default, 20)
		tf:setAnchorPoint(0,1)
		tf:setColor(titleColor)
		tf:setPosition(ccp(20, offsetY))
		self._ccbOwner.node_prop:addChild(tf)
		offsetY = offsetY - 40
		index = 0
		offsetX = 20
		createTTFFunc(breedPropDic["team_attack_value"])
		createTTFFunc(breedPropDic["team_attack_percent"])
		createTTFFunc(breedPropDic["team_hp_value"])
		createTTFFunc(breedPropDic["team_hp_percent"])
		createTTFFunc(breedPropDic["team_armor_physical"])
		createTTFFunc(breedPropDic["team_armor_magic"])
		createTTFFunc(breedPropDic["team_armor_physical_percent"])
		createTTFFunc(breedPropDic["team_armor_magic_percent"])
		offsetY = offsetY - 54
	end


  	local skillConfig = db:getSkillByID(suitSkill)

  	if skillConfig and magicHerbSuitConfig then
	  	local aptitude = magicHerbSuitConfig.aptitude
	  	minBreedLv = magicHerbSuitConfig.breed
	  	if minBreedLv == remote.magicHerb.BREED_LV_MAX then
	  		aptitude = APTITUDE.SS
	  	end
	  	local aptitudeInfo = db:getSABCByQuality(aptitude) 
		local add = ""
		if minBreedLv > 0 and minBreedLv < remote.magicHerb.BREED_LV_MAX then
			add= "+"..minBreedLv
		end

  		offsetX = 20
		local tf1 = CCLabelTTF:create("【"..aptitudeInfo.qc..add.."级"..suitSkillTypeName.."】"..(skillConfig.name or "").."：", global.font_default, 20)
		tf1:setAnchorPoint(0,1)
		tf1:setColor(titleColor)
		tf1:setPosition(ccp(offsetX, offsetY))
		self._ccbOwner.node_prop:addChild(tf1)

		
		local diff = 0
		if 230 < tf1:getContentSize().width then
			diff = tf1:getContentSize().width - 230
			offsetX = offsetX + 230 + diff
		else
			offsetX = offsetX + 230

		end


		local tf2 = CCLabelTTF:create(skillConfig.description or "", global.font_default, 20, CCSize(360 - diff, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
		tf2:setAnchorPoint(0, 1)
		tf2:setColor(titleColor)
		tf2:setPosition(ccp(offsetX, offsetY))
		self._ccbOwner.node_prop:addChild(tf2)
		offsetY = offsetY - tf2:getContentSize().height
	end

    self._scroll = QScrollContain.new({sheet = self._ccbOwner.sheet, sheet_layout = self._ccbOwner.sheet_layout, direction = QScrollContain.directionY})
    self._scroll:setIsCheckAtMove(true)
    self._ccbOwner.node_prop:retain()
    self._ccbOwner.node_prop:setPosition(ccp(0,0))
    self._ccbOwner.node_prop:removeFromParent()
    self._scroll:addChild(self._ccbOwner.node_prop)
    self._ccbOwner.node_prop:release()
    self._scroll:setContentSize(0, math.abs(offsetY -10))
end

function QUIDialogMagicHerbPropView:viewWillDisappear()
    QUIDialogMagicHerbPropView.super.viewWillDisappear(self)
  
    if self._scroll ~= nil then
    	self._scroll:disappear()
    	self._scroll = nil
    end
end

function QUIDialogMagicHerbPropView:_onTriggerClose()
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

function QUIDialogMagicHerbPropView:_backClickHandler()
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

return QUIDialogMagicHerbPropView