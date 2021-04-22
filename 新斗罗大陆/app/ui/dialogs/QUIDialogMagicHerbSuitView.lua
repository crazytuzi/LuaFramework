local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMagicHerbSuitView = class("QUIDialogMagicHerbSuitView", QUIDialog)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QActorProp = import("...models.QActorProp")
local QScrollContain = import("...ui.QScrollContain")
local QUIWidgetMagicHerbBox = import("..widgets.QUIWidgetMagicHerbBox")
local QScrollContain = import("...ui.QScrollContain")


function QUIDialogMagicHerbSuitView:ctor(options)
	local ccbFile = "ccb/Dialog_magicHerb_suitView.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogMagicHerbSuitView.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true

	if options then
		self._sid = options.sid
		self._itemId = options.itemId
		self._actorId = options.actorId
	end
	
	self._height = 430
end


function QUIDialogMagicHerbSuitView:viewDidAppear()
    QUIDialogMagicHerbSuitView.super.viewDidAppear(self)
    self:initScrollView()

	if self._sid then
		self:_initLongView()
	elseif self._itemId then
		self:_initLongViewForItemId()
	elseif self._actorId then
		self:_initShortView()
	end

	if self._height < 430 then
		self._height = 430
	end

	self._scrollContain:setContentSize(440, self._height)
end

function QUIDialogMagicHerbSuitView:viewAnimationInHandler()
	self._scrollContain:resetTouchRect()
end

function QUIDialogMagicHerbSuitView:viewWillDisappear()
    QUIDialogMagicHerbSuitView.super.viewWillDisappear(self)
    if self._scrollContain ~= nil then
        self._scrollContain:disappear()
        self._scrollContain = nil
    end
end

function QUIDialogMagicHerbSuitView:initScrollView()
    self._scrollContain = QScrollContain.new({sheet = self._ccbOwner.sheet, sheet_layout = self._ccbOwner.sheet_layout, direction = QScrollContain.directionY , endRate = 0.1})
    self._ccbOwner.node_content:retain()
    self._ccbOwner.node_content:removeFromParent()
    self._scrollContain:addChild(self._ccbOwner.node_content)
    self._ccbOwner.node_content:release()
    -- local size = self._scrollContain:getContentSize()
    local size = self._ccbOwner.node_content:getContentSize()
    self._scrollContain:setContentSize(size.width, size.height)
end

function QUIDialogMagicHerbSuitView:_initLongViewForItemId()
	self._ccbOwner.s9s_bg:setPreferredSize(CCSize(448, 450))
	self._ccbOwner.node_top_view:setVisible(true)

	local box = QUIWidgetMagicHerbBox.new()
	box:setSketchByItemId(self._itemId)
	box:hideName()
	self._ccbOwner.node_icon:removeAllChildren()
	self._ccbOwner.node_icon:addChild(box)

	local itemInfo = db:getItemByID(self._itemId)
	local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(self._itemId)
	if itemInfo then
		self._ccbOwner.tf_name:setString(itemInfo.name)
		self._ccbOwner.tf_type:setString(magicHerbConfig.type_name)
		self._ccbOwner.tf_suit_name:setString("百草集："..magicHerbConfig.type_name)
		local suitType = magicHerbConfig.type
		local suitMagicHerbSketchItemList = remote.magicHerb:getMaigcHerbSketchItemByType(suitType, 20)
		local secondKeyName = ""
		local tbl = {}
		for _, magicHerbSketchItem in ipairs(suitMagicHerbSketchItemList) do
			if magicHerbSketchItem 
				and magicHerbSketchItem.name ~= magicHerbConfig.name
				and magicHerbSketchItem.name ~= secondKeyName then
				if secondKeyName == "" then
					secondKeyName = magicHerbSketchItem.name
				end
				table.insert(tbl, magicHerbSketchItem)
			end
		end
		local index = 1
		while true do
			local node = self._ccbOwner["node_suit"..index]
			if node then
				local icon = QUIWidgetMagicHerbBox.new()
				if index == 1 then
					icon:setSketchByItemId(self._itemId) 
				else
					icon:setSketchByItemId(tbl[index - 1].id) 
				end
				icon:hideSabc()
				icon:hideLevel()
				icon:hideStar()
				icon:setItemFrame(20)
				node:removeAllChildren()
				node:addChild(icon)
				index = index + 1
			else
				break
			end
		end
		self._height = 300
		local suitConfigList = remote.magicHerb:getMagicHerbSuitConfigsByType(suitType)

		local offsetX = 20
		local offsetY = 0
		local titleColor = COLORS.b
		local nameColor = COLORS.a
		local valueColor = COLORS.c
		for _, config in ipairs(suitConfigList) do
			local skillConfig = QStaticDatabase.sharedDatabase():getSkillByID(config.skill)

            local aptitude = config.aptitude
            local add = ""
			if config.breed >= remote.magicHerb.BREED_LV_MAX then
                aptitude = APTITUDE.SS
            elseif config.breed > 0 then
                add = "+"..config.breed
            end

			local aptitudeInfo = db:getSABCByQuality(aptitude)
			-- local tf = CCLabelTTF:create("【"..aptitudeInfo.qc.."级"..suitSkillTypeName.."】"..skillConfig.name.."：", global.font_default, 20)
			local tf1 = CCLabelTTF:create("【"..aptitudeInfo.qc..add.."级".."】"..skillConfig.name.."："..skillConfig.description, global.font_default, 20, CCSize(400, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
			tf1:setAnchorPoint(0,1)
			tf1:setColor(nameColor)
			tf1:setPosition(ccp(offsetX, offsetY))
			self._ccbOwner.node_prop:addChild(tf1)
			-- offsetX = offsetX + 230

			-- local tf2 = CCLabelTTF:create(skillConfig.description, global.font_default, 20, CCSize(350, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
			-- tf2:setAnchorPoint(0, 1)
			-- tf2:setColor(valueColor)
			-- tf2:setPosition(ccp(offsetX, offsetY))
			-- self._ccbOwner.node_prop:addChild(tf2)
			offsetY = offsetY - tf1:getContentSize().height

			self._height = self._height +  tf1:getContentSize().height

		end
	end
	self._height = self._height + 20

end

function QUIDialogMagicHerbSuitView:_initLongView()
	self._ccbOwner.s9s_bg:setPreferredSize(CCSize(448, 450))
	self._ccbOwner.node_top_view:setVisible(true)

	local box = QUIWidgetMagicHerbBox.new()
	box:setInfo(self._sid)
	box:hideName()
	self._ccbOwner.node_icon:removeAllChildren()
	self._ccbOwner.node_icon:addChild(box)

	local magicHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(self._sid)
	local itemConfig = db:getItemByID(magicHerbItemInfo.itemId)
	local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(magicHerbItemInfo.itemId)

	if magicHerbItemInfo and itemConfig and magicHerbConfig then
		self._ccbOwner.tf_name:setString(itemConfig.name)
		self._ccbOwner.tf_type:setString(magicHerbConfig.type_name)
		self._ccbOwner.tf_suit_name:setString("百草集："..magicHerbConfig.type_name)
		local suitType = magicHerbConfig.type
		local suitMagicHerbSketchItemList = remote.magicHerb:getMaigcHerbSketchItemByType(suitType, 20)
		local secondKeyName = ""
		local tbl = {}
		for _, magicHerbSketchItem in ipairs(suitMagicHerbSketchItemList) do
			if magicHerbSketchItem
				and magicHerbSketchItem.name ~= magicHerbConfig.name
				and magicHerbSketchItem.name ~= secondKeyName then
				if secondKeyName == "" then
					secondKeyName = magicHerbSketchItem.name
				end
				table.insert(tbl, magicHerbSketchItem)
			end
		end
		local index = 1
		while true do
			local node = self._ccbOwner["node_suit"..index]
			if node then
				local icon = QUIWidgetMagicHerbBox.new()
				if index == 1 then
					icon:setInfo(self._sid) 
				else
					icon:setSketchByItemId(tbl[index - 1].id) 
				end
				icon:hideSabc()
				icon:hideLevel()
				icon:hideStar()
				icon:setItemFrame(20)
				node:removeAllChildren()
				node:addChild(icon)
				index = index + 1
			else
				break
			end
		end
		self._height = 300
		local suitConfigList = remote.magicHerb:getMagicHerbSuitConfigsByType(suitType)
		-- node_prop

		local offsetX = 20
		local offsetY = 0
		local titleColor = COLORS.b
		local nameColor = COLORS.a
		local valueColor = COLORS.c
		for _, config in ipairs(suitConfigList) do
			local skillConfig = db:getSkillByID(config.skill)

            local aptitude = config.aptitude
            local add = ""
     
			if config.breed >= remote.magicHerb.BREED_LV_MAX then
                aptitude = APTITUDE.SS
            elseif config.breed > 0 then
                add = "+"..config.breed
            end
            
			local aptitudeInfo = db:getSABCByQuality(aptitude)
			-- local tf = CCLabelTTF:create("【"..aptitudeInfo.qc.."级"..suitSkillTypeName.."】"..skillConfig.name.."：", global.font_default, 20)
			local tf1 = CCLabelTTF:create("【"..aptitudeInfo.qc..add.."级".."】"..skillConfig.name.."："..skillConfig.description, global.font_default, 20, CCSize(400, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
			tf1:setAnchorPoint(0,1)
			tf1:setColor(nameColor)
			tf1:setPosition(ccp(offsetX, offsetY))
			self._ccbOwner.node_prop:addChild(tf1)
			-- offsetX = offsetX + 230

			-- local tf2 = CCLabelTTF:create(skillConfig.description, global.font_default, 20, CCSize(350, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
			-- tf2:setAnchorPoint(0, 1)
			-- tf2:setColor(valueColor)
			-- tf2:setPosition(ccp(offsetX, offsetY))
			-- self._ccbOwner.node_prop:addChild(tf2)
			offsetY = offsetY - tf1:getContentSize().height
			self._height = self._height + tf1:getContentSize().height
		end
	end
	self._height = self._height + 20

end

function QUIDialogMagicHerbSuitView:_initShortView()
	self._ccbOwner.s9s_bg:setPreferredSize(CCSize(448, 300))
	self._ccbOwner.node_top_view:setVisible(false)
	
	local uiHeroModel = remote.herosUtil:getUIHeroByID(self._actorId)
	local index = 1
	local suitSkill, minAptitude ,minBreedLevel, magicHerbSuitConfig = uiHeroModel:getMagicHerbSuitSkill()
	minBreedLevel = magicHerbSuitConfig.breed
	
	while true do
		local node = self._ccbOwner["node_suit"..index]
		local wearInfo = uiHeroModel:getMagicHerbWearedInfoByPos(index)
		if node and wearInfo then
			local sid = wearInfo.sid
			local magicHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(sid)
			local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(magicHerbItemInfo.itemId)
			if magicHerbConfig then
				self._ccbOwner.tf_suit_name:setString("百草集："..magicHerbConfig.type_name)
			end
			local icon = QUIWidgetMagicHerbBox.new()
			icon:setInfo(sid) 
			node:removeAllChildren()
			node:addChild(icon)
			index = index + 1
		else
			break
		end
	end

	local offsetX = 20
	local offsetY = 0
	local titleColor = COLORS.b
	local nameColor = COLORS.a
	local valueColor = COLORS.c
	local skillConfig = db:getSkillByID(suitSkill)
	local aptitude = remote.magicHerb:getAptitudeByAptitudeAndBreedLv(minAptitude,minBreedLevel)
	local aptitudeInfo = db:getSABCByQuality(aptitude)
	local add = ""
	if minBreedLevel > 0 and minBreedLevel < remote.magicHerb.BREED_LV_MAX then
		add= "+"..minBreedLevel
	end

	-- local tf = CCLabelTTF:create("【"..aptitudeInfo.qc.."级"..suitSkillTypeName.."】"..skillConfig.name.."：", global.font_default, 20)
	local tf1 = CCLabelTTF:create("【"..aptitudeInfo.qc..add.."级".."】"..skillConfig.name.."："..skillConfig.description, global.font_default, 20, CCSize(400, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	tf1:setAnchorPoint(0,1)
	tf1:setColor(nameColor)
	tf1:setPosition(ccp(offsetX, offsetY))
	self._ccbOwner.node_prop:addChild(tf1)
	-- offsetX = offsetX + 230

	-- local tf2 = CCLabelTTF:create(skillConfig.description, global.font_default, 20, CCSize(350, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	-- tf2:setAnchorPoint(0, 1)
	-- tf2:setColor(valueColor)
	-- tf2:setPosition(ccp(offsetX, offsetY))
	-- self._ccbOwner.node_prop:addChild(tf2)
end

function QUIDialogMagicHerbSuitView:_onTriggerClose()
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

function QUIDialogMagicHerbSuitView:_backClickHandler()
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

return QUIDialogMagicHerbSuitView