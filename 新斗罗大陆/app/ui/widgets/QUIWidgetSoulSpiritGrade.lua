--
-- Kumo.Wang
-- 魂靈升星界面
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSoulSpiritGrade = class("QUIWidgetSoulSpiritGrade", QUIWidget)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIViewController = import("..QUIViewController")
local QRichText = import("...utils.QRichText")
local QColorLabel = import("...utils.QColorLabel")
local QUIWidgetSoulSpiritEffectBox = import(".QUIWidgetSoulSpiritEffectBox")
local QQuickWay = import("...utils.QQuickWay")
local QScrollView = import("...views.QScrollView")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QActorProp = import("...models.QActorProp")

function QUIWidgetSoulSpiritGrade:ctor(options)
	local ccbFile = "ccb/Widget_SoulSpirit_GradeUp.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerPlus", callback = handler(self, self._onTriggerPlus)},
		{ccbCallbackName = "onTriggerEvolution", callback = handler(self, self._onTriggerEvolution)},
		{ccbCallbackName = "onTriggerInfo", callback = handler(self, self._onTriggerInfo)},
	}
	QUIWidgetSoulSpiritGrade.super.ctor(self,ccbFile,callBacks,options)
end

function QUIWidgetSoulSpiritGrade:onEnter()
	QUIWidgetSoulSpiritGrade.super.onEnter(self)

	self:_initScrollView()
end

function QUIWidgetSoulSpiritGrade:onExit()
	QUIWidgetSoulSpiritGrade.super.onExit(self)
end

function QUIWidgetSoulSpiritGrade:_initScrollView()
	-- By Kumo：把scrollView的初始化放在構造函數完成，因為戰鬥界面的跳轉會先執行setinfo，放在構造之外的地方初始化，可能導致bug
	if not self._scrollView then
		local itemContentSize = self._ccbOwner.sheet_layout:getContentSize()
		self._scrollView = QScrollView.new(self._ccbOwner.sheet, itemContentSize, {bufferMode = 1})
    	self._scrollView:setVerticalBounce(true)
	end
    
	if not self._scrollView1 then
	    local itemContentSize1 = self._ccbOwner.sheet_layout1:getContentSize()
	    self._scrollView1 = QScrollView.new(self._ccbOwner.sheet1, itemContentSize1, {bufferMode = 1})
	    self._scrollView1:setVerticalBounce(true)
   	end
end

function QUIWidgetSoulSpiritGrade:setInfo(id, heroId)
	self:_initScrollView()
	
	if not id and not heroId then
        return
    elseif id and heroId then
        self._id = id
        self._heroId = heroId
    elseif id then
        self._id = id
        local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(self._id)
        self._heroId = soulSpiritInfo and soulSpiritInfo.heroId or 0
    elseif heroId then
        self._heroId = heroId
        local heroInfo = remote.herosUtil:getHeroByID(self._heroId)
        local soulSpiritInfo = heroInfo.soulSpirit
        self._id = soulSpiritInfo and soulSpiritInfo.id or 0
    end

	self._soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(self._id)
    self._characterConfig = QStaticDatabase.sharedDatabase():getCharacterByID(self._id)
    local maxGrade = QStaticDatabase.sharedDatabase():getMaxGradeByHeroActor(self._id)

	local isMax = self._soulSpiritInfo.grade >= maxGrade
	if isMax then
		self:showMaxInfo()
	else
		self:showInfo()
	end
	self._ccbOwner.node_normal:setVisible(not isMax)
	self._ccbOwner.node_max:setVisible(isMax)

	self:checkRedTips()
end

function QUIWidgetSoulSpiritGrade:showInfo()
	local color = remote.soulSpirit:getColorByCharacherId(self._id)
	color = QIDEA_QUALITY_COLOR[color]
	if color ~= nil then
		self._ccbOwner.tf_cur_name:setColor(color)
		self._ccbOwner.tf_next_name:setColor(color)
	else
		self._ccbOwner.tf_cur_name:setColor(QIDEA_QUALITY_COLOR.WHITE)
		self._ccbOwner.tf_next_name:setColor(QIDEA_QUALITY_COLOR.WHITE)
	end

	self._ccbOwner.tf_cur_name:setString(self._characterConfig.name)
	self._ccbOwner.tf_next_name:setString(self._characterConfig.name)
	self._ccbOwner.node_cur_avatar:removeAllChildren()
	self._ccbOwner.node_next_avatar:removeAllChildren()

	local curItemAvatar = QUIWidgetSoulSpiritEffectBox.new()
	self._ccbOwner.node_cur_avatar:addChild(curItemAvatar)
	curItemAvatar:setInfo(self._id)
	curItemAvatar:setStarNum(self._soulSpiritInfo.grade)

	local curGradeConfig = QStaticDatabase.sharedDatabase():getGradeByHeroActorLevel(self._id, self._soulSpiritInfo.grade)
	local uiPropList = remote.soulSpirit:getUiPropListByConfig(curGradeConfig, true, false, true)
	local index = 1
	while true do
		local tfName = self._ccbOwner["tf_cur_name"..index]
		if tfName then
			tfName:setString("")
		end
		local tfValue = self._ccbOwner["tf_cur_value"..index]
		if tfValue then
			tfValue:setString("")
		end
		if tfName or tfValue then
			index = index + 1
		else
			break
		end
	end
	index = 1
	for _, tbl in ipairs(uiPropList) do
		local tfName = self._ccbOwner["tf_cur_name"..index]
		local tfValue = self._ccbOwner["tf_cur_value"..index]

		local isPercent = QActorProp._field[tbl.keys[1]].isPercent
        local str = q.getFilteredNumberToString(tonumber(tbl.num), isPercent, 2) 

		if tfName then
			local name = ""
			if tbl.nameStr then
				name = tbl.nameStr
			else
				for i, key in ipairs(tbl.keys) do
					if name == "" then
						name = QActorProp._field[key].uiName or QActorProp._field[key].name
					else
						name = name.."、"..(QActorProp._field[key].uiName or QActorProp._field[key].name)
					end
				end
			end
			tfName:setString(name.."：")
		end
		if tfValue then
			tfValue:setString("+"..str)
		end
		if tfName or tfValue then
			index = index + 1
		else
			break
		end
	end


	local nextItemAvatar = QUIWidgetSoulSpiritEffectBox.new()
	self._ccbOwner.node_next_avatar:addChild(nextItemAvatar)
	nextItemAvatar:setInfo(self._id)
	nextItemAvatar:setStarNum(self._soulSpiritInfo.grade + 1)

	local nextGradeConfig = QStaticDatabase.sharedDatabase():getGradeByHeroActorLevel(self._id, self._soulSpiritInfo.grade + 1)
	if nextGradeConfig then
		local uiPropList = remote.soulSpirit:getUiPropListByConfig(nextGradeConfig, true, false, true)
		local index = 1
		while true do
			local tfName = self._ccbOwner["tf_next_name"..index]
			if tfName then
				tfName:setString("")
			end
			local tfValue = self._ccbOwner["tf_next_value"..index]
			if tfValue then
				tfValue:setString("")
			end
			if tfName or tfValue then
				index = index + 1
			else
				break
			end
		end
		index = 1
		for _, tbl in ipairs(uiPropList) do
			local tfName = self._ccbOwner["tf_next_name"..index]
			local tfValue = self._ccbOwner["tf_next_value"..index]

			local isPercent = QActorProp._field[tbl.keys[1]].isPercent
	        local str = q.getFilteredNumberToString(tonumber(tbl.num), isPercent, 2) 

			if tfName then
				local name = ""
				if tbl.nameStr then
					name = tbl.nameStr
				else
					for i, key in ipairs(tbl.keys) do
						if name == "" then
							name = QActorProp._field[key].uiName or QActorProp._field[key].name
						else
							name = name.."、"..(QActorProp._field[key].uiName or QActorProp._field[key].name)
						end
					end
				end
				tfName:setString(name.."：")
			end
			if tfValue then
				tfValue:setString("+"..str)
			end
			if tfName or tfValue then
				index = index + 1
			else
				break
			end
		end

		local soulCount = remote.items:getItemsNumByID(nextGradeConfig.soul_gem)
		self._ccbOwner.tf_progress:setString(soulCount.."/"..nextGradeConfig.soul_gem_count)
		self._ccbOwner.sp_progress:setScaleX(math.min(soulCount/nextGradeConfig.soul_gem_count, 1))
	else
		self._ccbOwner.tf_progress:setString("已到顶级")
		self._ccbOwner.sp_progress:setScaleX(1)
	end

	--设置技能
	self._scrollView:clear()
	local totalHeight = 0
	-- 由于配表原因，这里用星级来显示技能等级
    local rnumSkillLevel = q.getRomanNumberalsByInt(self._soulSpiritInfo.grade + 1)

	local skillId1 = string.split(curGradeConfig.soulspirit_pg, ":")
    local skillConfig1 = QStaticDatabase.sharedDatabase():getSkillByID(tonumber(skillId1[1]))
    local describe
    if skillConfig1 ~= nil then
        describe = "##e"..skillConfig1.name..rnumSkillLevel.."：##n"..skillConfig1.description
    end

    local skillId2 = string.split(curGradeConfig.soulspirit_dz, ":")
    local skillConfig2 = QStaticDatabase.sharedDatabase():getSkillByID(tonumber(skillId2[1]))
    if skillConfig2 ~= nil then
        describe = describe.."\n##e"..skillConfig2.name..rnumSkillLevel.."：##n"..skillConfig2.description
        
    end
    -- local _notice = "\n##x注：魂灵战斗属性=上阵主力英雄属性x"..remote.soulSpirit:getFightCoefficientByAptitude(self._characterConfig.aptitude).."\n##n注：魂灵战斗属性影响魂灵的普攻和魂技，魂灵技能只有上阵时有效"
    -- describe = describe.._notice
    local addCoefficientGrade = remote.soulSpirit:getFightAddCoefficientGradeByData(self._soulSpiritInfo)
    if addCoefficientGrade > 0 then
    	local addCoefficientAptitude = remote.soulSpirit:getFightAddCoefficientAptitudeByData(self._soulSpiritInfo)

    	local _notice = "\n##e觉醒-魂力同化：##n出战属性+"..q.PropPercentHanderFun(addCoefficientAptitude + addCoefficientGrade ).."(初始出战属性为上阵魂师的"..q.PropPercentHanderFun(addCoefficientAptitude)..")"
    	describe = describe.._notice
    end
    
    local strArr  = string.split(describe,"\n") or {}
    for i, v in pairs(strArr) do
        local describe = QColorLabel.replaceColorSign(v or "", false)
        local richText = QRichText.new(describe, 510, {stringType = 1, defaultColor = GAME_COLOR_LIGHT.normal, defaultSize = 20, fontName = global.font_default})
        richText:setAnchorPoint(ccp(0, 1))
        richText:setPositionY(-totalHeight)
		self._scrollView:addItemBox(richText)
        totalHeight = totalHeight + richText:getContentSize().height
    end

	self._scrollView:setRect(0, -totalHeight, 0, 0)

	self._ccbOwner.node_item:removeAllChildren()
	local itemBox = QUIWidgetItemsBox.new()
	self._ccbOwner.node_item:addChild(itemBox)
	itemBox:setGoodsInfo(curGradeConfig.soul_gem, ITEM_TYPE.ITEM)
	itemBox:hideSabc()
end

function QUIWidgetSoulSpiritGrade:showMaxInfo()
	self._ccbOwner.node_avatar:removeAllChildren()
	local itemAvatar = QUIWidgetSoulSpiritEffectBox.new()
	self._ccbOwner.node_avatar:addChild(itemAvatar)
	itemAvatar:setInfo(self._id)
	itemAvatar:setStarNum(self._soulSpiritInfo.grade)

	local gradeConfig = QStaticDatabase.sharedDatabase():getGradeByHeroActorLevel(self._id, self._soulSpiritInfo.grade)
	-- QPrintTable(gradeConfig)
	local uiPropList = remote.soulSpirit:getUiPropListByConfig(gradeConfig, true, false, true)
	local index = 1
	while true do
		local tfName = self._ccbOwner["tf_prop_name"..index]
		if tfName then
			tfName:setString("")
		end
		local tfValue = self._ccbOwner["tf_prop_value"..index]
		if tfValue then
			tfValue:setString("")
		end
		if tfName or tfValue then
			index = index + 1
		else
			break
		end
	end
	index = 1
	for _, tbl in ipairs(uiPropList) do
		local tfName = self._ccbOwner["tf_prop_name"..index]
		local tfValue = self._ccbOwner["tf_prop_value"..index]

		local isPercent = QActorProp._field[tbl.keys[1]].isPercent
        local str = q.getFilteredNumberToString(tonumber(tbl.num), isPercent, 2) 

		if tfName then
			local name = ""
			if tbl.nameStr then
				name = tbl.nameStr
			else
				for i, key in ipairs(tbl.keys) do
					if name == "" then
						name = QActorProp._field[key].uiName or QActorProp._field[key].name
					else
						name = name.."、"..(QActorProp._field[key].uiName or QActorProp._field[key].name)
					end
				end
			end
			tfName:setString(name.."：")
		end
		if tfValue then
			tfValue:setString("+"..str)
		end
		if tfName or tfValue then
			index = index + 1
		else
			break
		end
	end

	--设置技能
	self._scrollView1:clear()
	local totalHeight = 0
	-- 由于配表原因，这里用星级来显示技能等级
    local rnumSkillLevel = q.getRomanNumberalsByInt(self._soulSpiritInfo.grade + 1)
	local skillId1 = string.split(gradeConfig.soulspirit_pg, ":")
    local skillConfig1 = QStaticDatabase.sharedDatabase():getSkillByID(tonumber(skillId1[1]))
    local describe
    if skillConfig1 ~= nil then
        describe = "##e"..skillConfig1.name..rnumSkillLevel.."：##n"..skillConfig1.description
    end

    local skillId2 = string.split(gradeConfig.soulspirit_dz, ":")
    local skillConfig2 = QStaticDatabase.sharedDatabase():getSkillByID(tonumber(skillId2[1]))
    if skillConfig2 ~= nil then
        describe = describe.."\n##e"..skillConfig2.name..rnumSkillLevel.."：##n"..skillConfig2.description
        
    end
    local addCoefficientGrade = remote.soulSpirit:getFightAddCoefficientGradeByData(self._soulSpiritInfo)
    if addCoefficientGrade > 0 then
    	local addCoefficientAptitude = remote.soulSpirit:getFightAddCoefficientAptitudeByData(self._soulSpiritInfo)

    	local _notice = "\n##e觉醒-魂力同化：##n出战属性+"..q.PropPercentHanderFun(addCoefficientAptitude + addCoefficientGrade ).."(初始出战属性为上阵魂师的"..q.PropPercentHanderFun(addCoefficientAptitude)..")"
    	describe = describe.._notice
    end
    
    -- local _notice = "\n##x注：魂灵战斗属性=上阵主力英雄属性x"..remote.soulSpirit:getFightCoefficientByAptitude(self._characterConfig.aptitude).."\n##n注：魂灵战斗属性影响魂灵的普攻和魂技，魂灵技能只有上阵时有效"
    -- describe = describe.._notice
    local strArr  = string.split(describe,"\n") or {}
    for i, v in pairs(strArr) do
        local describe = QColorLabel.replaceColorSign(v or "", false)
        local richText = QRichText.new(describe, 510, {stringType = 1, defaultColor = GAME_COLOR_LIGHT.normal, defaultSize = 22, fontName = global.font_default})
        richText:setAnchorPoint(ccp(0, 1))
        richText:setPositionY(-totalHeight)
		self._scrollView1:addItemBox(richText)
        totalHeight = totalHeight + richText:getContentSize().height
    end

	self._scrollView1:setRect(0, -totalHeight, 0, 0)
end

function QUIWidgetSoulSpiritGrade:checkRedTips()
	self._ccbOwner.node_grade_tips:setVisible(remote.soulSpirit:isGradeRedTipsById(self._id))
end

function QUIWidgetSoulSpiritGrade:_onTriggerPlus(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_plus) == false then return end
	local newGradeConfig = QStaticDatabase.sharedDatabase():getGradeByHeroActorLevel(self._id, self._soulSpiritInfo.grade+1)
	if newGradeConfig ~= nil then
		local dropType = QQuickWay.ITEM_DROP_WAY
		QQuickWay:addQuickWay(dropType, newGradeConfig.soul_gem, nil, nil, false)
	end
end

function QUIWidgetSoulSpiritGrade:_onTriggerEvolution(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_evolution) == false then return end
	local newGradeConfig = QStaticDatabase.sharedDatabase():getGradeByHeroActorLevel(self._id, self._soulSpiritInfo.grade+1)
	if newGradeConfig == nil then
		app.tip:floatTip("已经到顶级")
		return
	end

	local soulCount = remote.items:getItemsNumByID(newGradeConfig.soul_gem)
	if soulCount >= newGradeConfig.soul_gem_count then
		remote.soulSpirit:soulSpiritGradeUpdateRequest(self._id, function()
			self:setInfo(self._id, self._heroId)
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulSpiritGradeSuccess",
				options = {id = self._id, callback = function ()
					remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
				end}},{isPopCurrentDialog = false})
		end)
	else
		QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, newGradeConfig.soul_gem)
	end
end

function QUIWidgetSoulSpiritGrade:_onTriggerInfo(e, target)
	if q.buttonEventShadow(e, target) == false then return end
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulSpiritSkillInfo", 
        options = {id = self._id}})
end

return QUIWidgetSoulSpiritGrade