local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetMountInfoGrade = class("QUIWidgetMountInfoGrade", QUIWidget)
local QUIWidgetItemsBox = import("...widgets.QUIWidgetItemsBox")
local QUIViewController = import("...QUIViewController")
local QRichText = import("....utils.QRichText")
local QColorLabel = import("....utils.QColorLabel")
local QUIWidgetActorDisplay = import("..actorDisplay.QUIWidgetActorDisplay")
local QUIWidgetEquipmentAvatar = import("...widgets.QUIWidgetEquipmentAvatar")
local QQuickWay = import("....utils.QQuickWay")
local QScrollView = import("....views.QScrollView")

function QUIWidgetMountInfoGrade:ctor(options)
	local ccbFile = "ccb/Widget_Weapon_shengxing_07.ccbi"
	local callBacks = {
		{ccbCallbackName = "onPlus", callback = handler(self, self._onPlus)},
		{ccbCallbackName = "onTriggerEvolution", callback = handler(self, self._onTriggerEvolution)},
		{ccbCallbackName = "onTriggerInfo", callback = handler(self, self._onTriggerInfo)},
		{ccbCallbackName = "onTriggerInfo1", callback = handler(self, self._onTriggerInfo1)},
	}
	QUIWidgetMountInfoGrade.super.ctor(self,ccbFile,callBacks,options)
end

function QUIWidgetMountInfoGrade:onEnter()
	QUIWidgetMountInfoGrade.super.onEnter(self)

	self:_initScrollView()
end

function QUIWidgetMountInfoGrade:onExit()
	QUIWidgetMountInfoGrade.super.onExit(self)
end

function QUIWidgetMountInfoGrade:_initScrollView()
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

function QUIWidgetMountInfoGrade:setInfo(actorId)
	self._actorId = actorId
	local mountInfo = remote.herosUtil:getHeroByID(self._actorId).zuoqi
	self:setMountId(mountInfo.zuoqiId)
end

function QUIWidgetMountInfoGrade:setMountId(mountId)
	self:_initScrollView()

	self._mountId = mountId
	self._mountConfig = db:getCharacterByID(self._mountId)
	self._mountInfo = remote.mount:getMountById(self._mountId)

	local maxGrade = db:getMaxGradeByHeroActor(self._mountId)

	local isMax = self._mountInfo.grade >= maxGrade
	if isMax then
		self:showMountMaxInfo()
	else
		self:showMountInfo()
	end
	self._ccbOwner.node_normal:setVisible(not isMax)
	self._ccbOwner.node_max:setVisible(isMax)

	self:checkRedTips()
end

function QUIWidgetMountInfoGrade:showMountInfo()
	local color = remote.mount:getColorByMountId(self._mountId)
	color = QIDEA_QUALITY_COLOR[color]
	if color ~= nil then
		self._ccbOwner.tf_name1:setColor(color)
		self._ccbOwner.tf_name2:setColor(color)
	else
		self._ccbOwner.tf_name1:setColor(QIDEA_QUALITY_COLOR.WHITE)
		self._ccbOwner.tf_name2:setColor(QIDEA_QUALITY_COLOR.WHITE)
	end

	self._ccbOwner.tf_name1:setString(self._mountConfig.name)
	self._ccbOwner.tf_name2:setString(self._mountConfig.name)
	self._ccbOwner.node_mount1:removeAllChildren()
	self._ccbOwner.node_mount2:removeAllChildren()

	local itemAvatar = QUIWidgetEquipmentAvatar.new()
	self._ccbOwner.node_mount1:addChild(itemAvatar)
	itemAvatar:setMountInfo(self._mountInfo, self._mountInfo.grade)

	local oldGradeConfig = db:getGradeByHeroActorLevel(self._mountId, self._mountInfo.grade)
	local props = remote.mount:getUIPropInfo(oldGradeConfig)

	local index = 1
	for i, prop in ipairs(props) do
		if self._ccbOwner["tf_cur_name"..index] then
			self._ccbOwner["tf_cur_name"..index]:setString(prop.name)
			self._ccbOwner["tf_cur_value"..index]:setString("+"..prop.value)
			local posX = self._ccbOwner["tf_cur_name"..index]:getPositionX()+self._ccbOwner["tf_cur_name"..index]:getContentSize().width
			self._ccbOwner["tf_cur_value"..index]:setPositionX(posX)			
		end
		
		index = index + 1
	end

	local itemAvatar = QUIWidgetEquipmentAvatar.new()
	self._ccbOwner.node_mount2:addChild(itemAvatar)
	itemAvatar:setMountInfo(self._mountInfo, self._mountInfo.grade+1)

	local newGradeConfig = db:getGradeByHeroActorLevel(self._mountId, self._mountInfo.grade+1)
	if newGradeConfig ~= nil then
		local props = remote.mount:getUIPropInfo(newGradeConfig)
		local index = 1
		for i, prop in ipairs(props) do
			if self._ccbOwner["tf_next_name"..index] then
				self._ccbOwner["tf_next_name"..index]:setString(prop.name)
				self._ccbOwner["tf_next_value"..index]:setString("+"..prop.value)
				local posX = self._ccbOwner["tf_next_name"..index]:getPositionX()+self._ccbOwner["tf_next_name"..index]:getContentSize().width
				self._ccbOwner["tf_next_value"..index]:setPositionX(posX)
			end
			index = index + 1
		end
		local soulCount = remote.items:getItemsNumByID(newGradeConfig.soul_gem)
		self._ccbOwner.tf_progress:setString(soulCount.."/"..newGradeConfig.soul_gem_count)
		self._ccbOwner.sp_progress:setScaleX(math.min(soulCount/newGradeConfig.soul_gem_count, 1))
	else
		self._ccbOwner.tf_progress:setString("已到顶级")
		self._ccbOwner.sp_progress:setScaleX(1)
	end

	--设置技能
	self._scrollView:clear()
	local totalHeight = 0

	local mountConfig = db:getCharacterByID(self._mountId)
	if mountConfig.zuoqi_pj then
        local strArr  = {"##e配件暗器：##dS配件暗器不能装备于魂师上，无主力和援助效果，只能用于SS或SS+暗器的配件"}
        for i, v in pairs(strArr) do
			local text = QRichText.new(v, 520, {defaultSize = 22, stringType = 1, fontName = global.font_default})
			text:setAnchorPoint(ccp(0, 1))
			text:setPosition(ccp(0, -totalHeight))
			self._scrollView:addItemBox(text)
			totalHeight = totalHeight + text:getContentSize().height
        end
		self._ccbOwner.btn_skill_info:setVisible(false)
	else

		self._ccbOwner.btn_skill_info:setVisible(true)
		local skills = {}
		local skillIds = string.split(oldGradeConfig.zuoqi_skill_ms, ";")
		for _, skillId in ipairs(skillIds) do
			local skillConfig = db:getSkillByID(tonumber(skillId))
			if skillConfig then
				local describe = "##e"..skillConfig.name.."：##d"..(skillConfig.description or "")
				describe = QColorLabel.replaceColorSign(describe)
	            local strArr  = string.split(describe,"\n") or {}
	            for i, v in pairs(strArr) do
					local text = QRichText.new(v, 520, {defaultSize = 22, stringType = 1, fontName = global.font_default})
					text:setAnchorPoint(ccp(0, 1))
					text:setPosition(ccp(0, -totalHeight))
					self._scrollView:addItemBox(text)
					totalHeight = totalHeight + text:getContentSize().height
	            end
			end
		end
	end
	self._scrollView:setRect(0, -totalHeight, 0, 0)

	self._ccbOwner.node_item:removeAllChildren()
	local itemBox = QUIWidgetItemsBox.new()
	self._ccbOwner.node_item:addChild(itemBox)
	itemBox:setGoodsInfo(oldGradeConfig.soul_gem, ITEM_TYPE.ITEM)
	itemBox:hideSabc()
end

function QUIWidgetMountInfoGrade:showMountMaxInfo()
	self._ccbOwner.node_mount:removeAllChildren()
	local itemAvatar = QUIWidgetEquipmentAvatar.new()
	self._ccbOwner.node_mount:addChild(itemAvatar)
	itemAvatar:setMountInfo(self._mountInfo, self._mountInfo.grade)

	self._ccbOwner.node_max_prop_richText:removeAllChildren()
	local gradeConfig = db:getGradeByHeroActorLevel(self._mountId, self._mountInfo.grade)
	local props = remote.mount:getUIPropInfo(gradeConfig)
	local index = 1

	for i, prop in ipairs(props) do
        local value = prop.value 
        local tfNode = q.createPropTextNode(prop.name , value,nil,22)
        self._ccbOwner.node_max_prop_richText:addChild(tfNode)
		tfNode:setPosition(ccp(-40,-index*30))	
		index = index + 1
	end

	--设置技能
	self._scrollView1:clear()
	local totalHeight = 0
	local mountConfig = db:getCharacterByID(self._mountId)
	if mountConfig.zuoqi_pj then
		self._ccbOwner.btn_skill_info1:setVisible(false)
        local strArr  =  {"##e配件暗器：##dS配件暗器不能装备于魂师上，无主力和援助效果，只能用于SS或SS+暗器的配件"}
        for i, v in pairs(strArr) do
			local text = QRichText.new(v, 520, {defaultSize = 22, stringType = 1, fontName = global.font_default})
			text:setAnchorPoint(ccp(0, 1))
			text:setPosition(ccp(0, -totalHeight))
			self._scrollView1:addItemBox(text)
			totalHeight = totalHeight + text:getContentSize().height
        end
	else
		self._ccbOwner.btn_skill_info1:setVisible(true)
		local skills = {}
		local skillIds = string.split(gradeConfig.zuoqi_skill_ms, ";")
		for _, skillId in ipairs(skillIds) do
			local skillConfig = db:getSkillByID(tonumber(skillId))
			if skillConfig then
				local describe = "##e"..skillConfig.name.."：##d"..skillConfig.description
				describe = QColorLabel.replaceColorSign(describe)
	            local strArr  = string.split(describe,"\n") or {}
	            for i, v in pairs(strArr) do
					local text = QRichText.new(v, 520, {defaultSize = 22, stringType = 1, fontName = global.font_default})
					text:setAnchorPoint(ccp(0, 1))
					text:setPosition(ccp(0, -totalHeight))
					self._scrollView1:addItemBox(text)
					totalHeight = totalHeight + text:getContentSize().height
				end
			end
		end

	end
	self._scrollView1:setRect(0, -totalHeight, 0, 0)
end

function QUIWidgetMountInfoGrade:checkRedTips()
	self._ccbOwner.node_grade_tips:setVisible(remote.mount:checkMountCanGrade(self._mountInfo))
end

function QUIWidgetMountInfoGrade:_onPlus(event) 
    if q.buttonEventShadow(event, self._ccbOwner.btn_plus) == false then return end
	local newGradeConfig = db:getGradeByHeroActorLevel(self._mountId, self._mountInfo.grade+1)
	if newGradeConfig ~= nil then
		local dropType = QQuickWay.ITEM_DROP_WAY
		QQuickWay:addQuickWay(dropType, newGradeConfig.soul_gem, nil, nil, false)
	end
end

function QUIWidgetMountInfoGrade:_onTriggerEvolution(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_break) == false then return end
	local newGradeConfig = db:getGradeByHeroActorLevel(self._mountId, self._mountInfo.grade+1)
	if newGradeConfig == nil then
		app.tip:floatTip("已经到顶级")
		return
	end

	local soulCount = remote.items:getItemsNumByID(newGradeConfig.soul_gem)
	if soulCount >= newGradeConfig.soul_gem_count then
		local mountId = self._mountId
		remote.mount:mountGradeRequest(mountId, function ()
			local mountConfig = db:getCharacterByID(mountId)
			if mountConfig.aptitude == APTITUDE.SS then
				local mountInfo = remote.mount:getMountById(mountId)
				local valueTbl = {}
	            valueTbl[mountId] = mountInfo.grade + 1
	            remote.activity:updateLocalDataByType(712, valueTbl)
	        end
	        if self._ccbView then
				self:setMountId(mountId)
			end
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMountGradeSuccess",
				options = { mountId = mountId, callback = function ()
					remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
				end}},{isPopCurrentDialog = false})
		end)
	else
		QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, newGradeConfig.soul_gem)
	end
end

function QUIWidgetMountInfoGrade:_onTriggerInfo(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_skill_info) == false then return end
	if event then
		app.sound:playSound("common_small")
	end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMountSkill", 
        options = {mountId = self._mountId}})
end

function QUIWidgetMountInfoGrade:_onTriggerInfo1(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_skill_info1) == false then return end
	app.sound:playSound("common_small")

	self:_onTriggerInfo()
end
return QUIWidgetMountInfoGrade