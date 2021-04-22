--
-- Author: wkwang
-- Date: 2014-10-29 11:06:39
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetBackPackInfo = class("QUIWidgetBackPackInfo", QUIWidget)

local QUIWidgetItemsBox =  import("..widgets.QUIWidgetItemsBox")
local QUIWidgetMagicHerbBox = import("..widgets.QUIWidgetMagicHerbBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QQuickWay = import("...utils.QQuickWay")
local QActorProp = import("...models.QActorProp")
local QScrollContain = import("...ui.QScrollContain")
local QRichText = import("...utils.QRichText")

function QUIWidgetBackPackInfo:ctor(options)
	local ccbFile = "ccb/Widget_Packsack.ccbi"
	local callbacks = {
       {ccbCallbackName = "onTriggerSell", callback = handler(self, QUIWidgetBackPackInfo._onTriggerSell)},
       {ccbCallbackName = "onTriggerOpen", callback = handler(self, QUIWidgetBackPackInfo._onTriggerOpen)},
       {ccbCallbackName = "onTriggerGenre", callback = handler(self, QUIWidgetBackPackInfo._onTriggerGenre)},
       {ccbCallbackName = "onTriggerLock", callback = handler(self, QUIWidgetBackPackInfo._onTriggerLock)},
	}
	QUIWidgetBackPackInfo.super.ctor(self, ccbFile, callbacks, options)

	self:resetAll()
	
	self:initScrollView() 
end

function QUIWidgetBackPackInfo:resetAll()
	if self._icon ~= nil then
	    self._icon:resetAll() 
	end
	self.isOpen = false

	self._ccbOwner.tf_name:setString("")
	self._ccbOwner.tf_num:setString("")
	self._ccbOwner.tf_introduce:setString("")
	self._ccbOwner.tf_money:setString("")
	self._ccbOwner.open_tips:setVisible(false)
	self._ccbOwner.node_normal_info:setVisible(true)
	self._ccbOwner.node_magicHerb_info:setVisible(false)
end

function QUIWidgetBackPackInfo:onEnter()
    QUIWidgetBackPackInfo.super.onEnter(self)
end

function QUIWidgetBackPackInfo:onExit()
    QUIWidgetBackPackInfo.super.onExit(self)
    if self._scrollContain ~= nil then
        self._scrollContain:disappear()
        self._scrollContain = nil
    end
end

function QUIWidgetBackPackInfo:refreshInfo()
	return self:setItemId(self._itemId, true)
end

function QUIWidgetBackPackInfo:resetAll()
	self._ccbOwner.tf_num_title:setString("拥有：")
end

function QUIWidgetBackPackInfo:setItemId(itemId, isForce)
	if isForce ~= true and itemId == self._itemId then
		return true
	end
	self._itemId = itemId
	self._magicHerbSid = nil
	self._itemNum = remote.items:getItemsNumByID(itemId)
	self:resetAll()
	if self._itemNum == 0 then
		self:setVisible(false)
		return false
	end

	self._ccbOwner.node_normal_info:setVisible(true)
	self._ccbOwner.node_magicHerb_info:setVisible(false)

	local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(itemId)
	self._itemConfig = itemConfig
	if itemConfig.type == ITEM_CONFIG_TYPE.MAGICHERB_WILD then
		-- 破碎仙品
		if self._icon == nil or self._icon:getClassName() == "QUIWidgetItemsBox" then
			self._ccbOwner.node_icon:removeAllChildren()
			self._icon = QUIWidgetMagicHerbBox.new()
			self._ccbOwner.node_icon:addChild(self._icon)
		else
			self._icon:resetAll()
		end
		self._icon:setSketchByItemId(itemId)
	else
		if self._icon == nil or self._icon:getClassName() == "QUIWidgetMagicHerbBox" then
			self._ccbOwner.node_icon:removeAllChildren()
			self._icon = QUIWidgetItemsBox.new()
			self._ccbOwner.node_icon:addChild(self._icon)
		else
			self._icon:resetAll()
		end
		self._icon:setGoodsInfo(itemId, ITEM_TYPE.ITEM, 0)
	end

	self._ccbOwner.tf_name:setString(itemConfig.name)
	local nameWidth = self._ccbOwner.tf_name:getContentSize().width
	if nameWidth > 260 then
		self._ccbOwner.tf_name:setFontSize(22)
	else
		self._ccbOwner.tf_name:setFontSize(24)
	end
	if EQUIPMENT_COLOR[itemConfig.colour] then
		local fontColor = EQUIPMENT_COLOR[itemConfig.colour]
		self._ccbOwner.tf_name:setColor(fontColor)
		self._ccbOwner.tf_name = setShadowByFontColor(self._ccbOwner.tf_name, fontColor)
	else
		setShadow5(self._ccbOwner.tf_name)
	end
	
	self._ccbOwner.tf_num:setString(self._itemNum)
	self._ccbOwner.tf_num_end:setPositionX(self._ccbOwner.tf_num:getPositionX() + self._ccbOwner.tf_num:getContentSize().width)

	--[[
        by Kumo
        显示流派信息
        Fri Mar  4 19:23:11 2016
    ]]
    local genreText = self:_getHeroGenre()
    if genreText then
        self._ccbOwner.tf_genre:setString(genreText)
        self._ccbOwner.tf_genre_title:setVisible(true)
        self._ccbOwner.tf_genre_title:setString("类型：")
        self._ccbOwner.tf_genre:setVisible(true)
        self._ccbOwner.btn_genre:setVisible(true)
    else
		if itemConfig.type == ITEM_CONFIG_TYPE.SOUL then
        	self._ccbOwner.tf_genre:setString("无")
        	self._ccbOwner.tf_genre_title:setVisible(true)
        	self._ccbOwner.tf_genre_title:setString("类型：")
	        self._ccbOwner.tf_genre:setVisible(true)
	        self._ccbOwner.btn_genre:setVisible(false)
	    elseif itemConfig.type == ITEM_CONFIG_TYPE.SOULSPIRIT_CONSUM then
	    	self._ccbOwner.tf_genre_title:setVisible(true)
	        self._ccbOwner.tf_genre_title:setString("经验：")
	        self._ccbOwner.tf_genre:setVisible(true)
	        self._ccbOwner.tf_genre:setString(itemConfig.exp)
	        self._ccbOwner.tf_genre:setColor(COLORS.k)

	        self._ccbOwner.tf_num_title:setVisible(true)
	        self._ccbOwner.tf_num_title:setString("暴击：")
	        if itemConfig.crit then
	        	self._ccbOwner.tf_num:setString(itemConfig.crit.."%")
	        	self._ccbOwner.tf_num:setColor(COLORS.k)
	        end
	        self._ccbOwner.btn_genre:setVisible(false)
	    elseif itemConfig.type == ITEM_CONFIG_TYPE.SOULSPIRITOCCULT_PIECE or itemConfig.type == ITEM_CONFIG_TYPE.SOULSPIRITINHERIT_PIECE  then
        	self._ccbOwner.tf_genre_title:setVisible(false)
	        self._ccbOwner.tf_genre:setVisible(false)
	        self._ccbOwner.btn_genre:setVisible(false)
	        self._ccbOwner.tf_num_title:setVisible(true)
	        self._ccbOwner.tf_num_title:setString("拥有：")	        

	    elseif itemConfig.type == ITEM_CONFIG_TYPE.SOULSPIRIT_PIECE then
	    	self._ccbOwner.tf_num_title:setVisible(true)
	        self._ccbOwner.tf_num_title:setString("拥有：")
	    	self._ccbOwner.tf_genre_title:setVisible(false)
	        self._ccbOwner.tf_genre:setVisible(false)
        	self._ccbOwner.btn_genre:setVisible(false)
        elseif itemConfig.type == ITEM_CONFIG_TYPE.GODARM_PIECE then
        	self._ccbOwner.tf_genre_title:setVisible(false)
        	self._ccbOwner.tf_genre:setVisible(false)
        	self._ccbOwner.btn_genre:setVisible(true)
        	self._ccbOwner.btn_genre:setPositionY(172)
		else
        	self._ccbOwner.tf_genre_title:setVisible(false)
	        self._ccbOwner.tf_genre:setVisible(false)
	        self._ccbOwner.btn_genre:setVisible(false)
		end
    end

    -- 倒计时
    local itemInfo = remote.items:getItemByID(itemId)
    if itemInfo.expireTime and itemInfo.expireTime > 0 then
	    local date = q.date("*t", itemInfo.expireTime/1000)
    	local dateStr = string.format("%s年%s月%s日0点", date.year, date.month, date.day)
    	self._ccbOwner.tf_genre_title:setVisible(true)
    	self._ccbOwner.tf_genre_title:setString("过期：")
	    self._ccbOwner.tf_genre:setVisible(true)
    	self._ccbOwner.tf_genre:setString(dateStr)
	    self._ccbOwner.btn_genre:setVisible(false)
	end

	self.detailStr = ""
	self._index = 1
	self:setTFValue("生    命", math.floor(itemConfig.hp or 0))
  	self:setTFValue("攻    击", math.floor(itemConfig.attack or 0))
  	self:setTFValue("命    中", math.floor(itemConfig.hit_rating or 0))
  	self:setTFValue("闪    避", math.floor(itemConfig.dodge_rating or 0))
  	self:setTFValue("暴    击", math.floor(itemConfig.critical_rating or 0))
  	self:setTFValue("格    挡", math.floor(itemConfig.block_rating or 0))
  	self:setTFValue("急    速", math.floor(itemConfig.haste_rating or 0))
  	self:setTFValue("物理防御", math.floor(itemConfig.armor_physical or 0))
  	self:setTFValue("法术防御", math.floor(itemConfig.armor_magic or 0))
	
	if self.detailStr == "" then
		self._ccbOwner.tf_introduce:setString(itemConfig.description or "")
	else
		self._ccbOwner.tf_introduce:setString(self.detailStr)
	end

	self:effectIn(self._ccbOwner.tf_name)
	self:effectIn(self._ccbOwner.tf_num)
	self:effectIn(self._ccbOwner.tf_introduce)
	self:effectIn(self._ccbOwner.tf_money)
	
	self._openUseType = 0
	self._sellUseType = 0
	self._ccbOwner.node_btn_sell:setVisible(true)
	local useTypes = string.split(itemConfig.use_type, ";")
	if #useTypes > 1 then
		self._openUseType = tonumber(useTypes[1])
		self._sellUseType = tonumber(useTypes[2])
		self:setButtonByType(self._ccbOwner.node_btn_open, self._ccbOwner.tf_btn_open, tonumber(useTypes[1]), -110)
		self:setButtonByType(self._ccbOwner.node_btn_sell, self._ccbOwner.tf_btn_sell, tonumber(useTypes[2]), 90)
	elseif useTypes[1] then
		self._openUseType = tonumber(useTypes[1])
		self:setButtonByType(self._ccbOwner.node_btn_open, self._ccbOwner.tf_btn_open, tonumber(useTypes[1]), 0)
		self._ccbOwner.node_btn_sell:setVisible(false)
	end
	self._ccbOwner.open_tips:setVisible(false)
	if itemConfig.red_dot then 
		self._ccbOwner.open_tips:setVisible(true)
	end

	self._ccbOwner.tf_money:setString(self._itemConfig.selling_price or 0)
	self._ccbOwner.node_sell_client:setVisible(true)
	self._ccbOwner.node_no_sell_client:setVisible(false)
	
	makeNodeFromGrayToNormal(self._ccbOwner.btn_sell)
	self._ccbOwner.tf_btn_sell:enableOutline()
	makeNodeFromGrayToNormal(self._ccbOwner.btn_open)
	self._ccbOwner.tf_btn_open:enableOutline()
	self._ccbOwner.btn_sell:setEnabled(true)
	self._ccbOwner.btn_open:setEnabled(true)
	if  self._itemConfig.selling_price == nil or self._itemConfig.selling_price == 0 then
		self._ccbOwner.node_sell_client:setVisible(false)
		self._ccbOwner.node_no_sell_client:setVisible(true)
		if self._sellUseType == ITEM_USE_TYPE.SELL then
			makeNodeFromNormalToGray(self._ccbOwner.btn_sell)
			self._ccbOwner.tf_btn_sell:disableOutline()
			self._ccbOwner.btn_sell:setEnabled(false)
		elseif self._openUseType == ITEM_USE_TYPE.SELL then
			makeNodeFromNormalToGray(self._ccbOwner.btn_open)
			self._ccbOwner.tf_btn_open:disableOutline()
			self._ccbOwner.btn_open:setEnabled(false)
		end
	end
end

function QUIWidgetBackPackInfo:initScrollView()
    self._scrollContain = QScrollContain.new({sheet = self._ccbOwner.sheet, sheet_layout = self._ccbOwner.sheet_layout, direction = QScrollContain.directionY , endRate = 0.1})
    self._ccbOwner.node_content:retain()
    self._ccbOwner.node_content:removeFromParent()
    self._scrollContain:addChild(self._ccbOwner.node_content)
    self._ccbOwner.node_content:release()
    local size = self._ccbOwner.node_content:getContentSize()
    self._scrollContain:setContentSize(size.width, size.height)
end

function QUIWidgetBackPackInfo:resetTouchRect()
	if self._scrollContain then
		self._scrollContain:resetTouchRect()
	end
end

function QUIWidgetBackPackInfo:setMagicHerbItemId(itemId, isForce, sId)
	if isForce ~= true and sId == self._magicHerbSid then
		return true
	end
	self._itemId = itemId
	self._magicHerbSid = sId
	self._itemNum = 1

	self._ccbOwner.node_normal_info:setVisible(false)
	self._ccbOwner.node_magicHerb_info:setVisible(true)
	self._ccbOwner.node_sell_client:setVisible(false)
	self._ccbOwner.node_no_sell_client:setVisible(false)

	local index = 1
	while true do
		local node = self._ccbOwner["tf_prop_"..index]
		if node then
			node:setString("")
			node:setVisible(false)
			index = index + 1
		else
			break
		end
	end

	if self._icon == nil or self._icon:getClassName() == "QUIWidgetItemsBox" then
		self._ccbOwner.node_icon:removeAllChildren()
		-- self._icon = QUIWidgetItemsBox.new()
		self._icon = QUIWidgetMagicHerbBox.new()
		self._ccbOwner.node_icon:addChild(self._icon)
	else
		self._icon:resetAll()
	end
	self._icon:setInfo(self._magicHerbSid)
	self._icon:hideName()
   
	local maigcHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(self._magicHerbSid)
	local magicHerbConfig = remote.magicHerb:getMagicHerbConfigByid(maigcHerbItemInfo.itemId)
	local maigcHerbItemConfig = db:getItemByID(maigcHerbItemInfo.itemId)

	if not maigcHerbItemInfo or not magicHerbConfig or not maigcHerbItemConfig then
		return
	end
	-- self._itemConfig = maigcHerbItemInfo
	-- self._icon:setGoodsInfo(itemId, ITEM_TYPE.MAGICHERB, 0)
	
	self._ccbOwner.tf_maigcHerb_name:setString(maigcHerbItemConfig.name)
	if EQUIPMENT_COLOR[maigcHerbItemConfig.colour] then
		local fontColor = EQUIPMENT_COLOR[maigcHerbItemConfig.colour]
		self._ccbOwner.tf_maigcHerb_name:setColor(fontColor)
		self._ccbOwner.tf_maigcHerb_name = setShadowByFontColor(self._ccbOwner.tf_maigcHerb_name, fontColor)
	else
		setShadow5(self._ccbOwner.tf_maigcHerb_name)
	end
	if magicHerbConfig then
		self._ccbOwner.tf_maigcHerb_type:setString(magicHerbConfig.type_name.."类" or "")
		self._ccbOwner.tf_suit_name:setString("百草集："..magicHerbConfig.type_name)
		local suitType = magicHerbConfig.type
		local suitMagicHerbSketchItemList = remote.magicHerb:getMaigcHerbSketchItemByType(suitType, 20)
		local secondKeyName = ""
		local tbl = {}
		for _, magicHerbSketchItem in ipairs(suitMagicHerbSketchItemList) do
			if magicHerbConfig
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

        local suitConfigList = remote.magicHerb:getMagicHerbSuitConfigsByType(suitType)

        if self._suitTF == nil then
            self._suitTF = QRichText.new(nil, 345, {lineSpacing=10, stringType = 1})
            self._suitTF:setAnchorPoint(ccp(0, 1))
            self._ccbOwner.node_suit:addChild(self._suitTF)
            self._suitTF:setPosition(-175, -185)
        end
        local propConfig = {}
        local activateColor = COLORS.j
        local unactivateColor = COLORS.n
        for _, config in ipairs(suitConfigList) do
            local color = activateColor
            local aptitude = config.aptitude
            local add = ""
			if config.breed >= remote.magicHerb.BREED_LV_MAX then
                aptitude = APTITUDE.SS
            elseif config.breed > 0 then
                add = "+"..config.breed
            end

            local skillConfig = QStaticDatabase.sharedDatabase():getSkillByID(config.skill)
            local aptitudeInfo = QStaticDatabase:sharedDatabase():getSABCByQuality(aptitude)
            table.insert(propConfig, {oType = "font", content = "【"..aptitudeInfo.qc..add.."级".."】"..skillConfig.name.."："..skillConfig.description, size = 18, color = color})
            table.insert(propConfig, {oType = "wrap"})
        end
        self._suitTF:setString(propConfig)
        local suitTFHeight = self._suitTF:getContentSize().height
        local totalHeight = self._suitTF:getPositionY() - suitTFHeight + self._ccbOwner.node_suit:getPositionY()
        print(self._scrollContain, totalHeight)
        if self._scrollContain then
            local size = self._scrollContain:getContentSize()
            size.height = math.abs(totalHeight)
            self._scrollContain:setContentSize(size.width, size.height)
        end
	end
	
	if maigcHerbItemInfo then
		if maigcHerbItemInfo.actorId and maigcHerbItemInfo.actorId ~= 0 then
			self._ccbOwner.tf_maigcHerb_state:setString("携带中")
		else
			self._ccbOwner.tf_maigcHerb_state:setString("未携带")
		end
	end
	
	local tbl = {}
	local basicPropList = {}
	local magicHerbGradeConfig = remote.magicHerb:getMagicHerbGradeConfigByIdAndGrade(maigcHerbItemInfo.itemId,maigcHerbItemInfo.grade or 1)
	if magicHerbGradeConfig then
		for key, value in pairs(magicHerbGradeConfig) do
			if QActorProp._field[key] then
				local name = QActorProp._field[key].uiName or QActorProp._field[key].name
				local num = value
                if tbl[key] then
                    tbl[key] = {name = name, num = tbl[key].num + num, isPercent = QActorProp._field[key].isPercent}
                else
                    tbl[key] = {name = name, num = num, isPercent = QActorProp._field[key].isPercent}
                end
			end
		end
	end
	local magicHerbUpLevelConfig = remote.magicHerb:getMagicHerbUpLevelConfigByIdAndLevel(maigcHerbItemInfo.itemId, maigcHerbItemInfo.level or 1)
	if magicHerbUpLevelConfig then
		for key, value in pairs(magicHerbUpLevelConfig) do
			if QActorProp._field[key] then
				local name = QActorProp._field[key].uiName or QActorProp._field[key].name
				local num = value
	            if tbl[key] then
	                tbl[key] = {name = name, num = tbl[key].num + num, isPercent = QActorProp._field[key].isPercent}
	            else
	                tbl[key] = {name = name, num = num, isPercent = QActorProp._field[key].isPercent}
	            end
			end
		end
	end
	local tmpTbl1 = {}
    local tmpTbl2 = {}
    for key, value in pairs(tbl) do
        if key == "armor_physical" or key == "armor_magic" then
            table.insert(tmpTbl1, value)
        elseif key == "armor_physical_percent" or key == "armor_magic_percent" then
            table.insert(tmpTbl2, value)
        else
            table.insert(basicPropList, value)
        end
    end
    if #tmpTbl1 == 2 then
        table.insert(basicPropList, {name = "双防", num = tmpTbl1[1].num, isPercent = tmpTbl1[1].isPercent})
    elseif #tmpTbl1 == 1 then
        table.insert(basicPropList, {name = tmpTbl1[1].name, num = tmpTbl1[1].num, isPercent = tmpTbl1[1].isPercent})
    end
    if #tmpTbl2 == 2 then
        table.insert(basicPropList, {name = "双防", num = tmpTbl2[1].num, isPercent = tmpTbl2[1].isPercent})
    elseif #tmpTbl2 == 1 then
        table.insert(basicPropList, {name = tmpTbl2[1].name, num = tmpTbl2[1].num, isPercent = tmpTbl2[1].isPercent})
    end
    -- QPrintTable(basicPropList)
    local index = 1
    for _, value in ipairs(basicPropList) do
        local tf = self._ccbOwner["tf_prop_"..index]
        if tf then
            local num = value.num
            num = q.getFilteredNumberToString(num, value.isPercent, 2)     
            tf:setString(value.name..":"..num)
            tf:setVisible(true)
            index = index + 1
        end
    end

	if maigcHerbItemInfo.attributes then
		local index = 3
		for _, value in ipairs(maigcHerbItemInfo.attributes) do
			if value.attribute and QActorProp._field[value.attribute] then
				local tf = self._ccbOwner["tf_prop_"..index]
				if tf then
					local name = QActorProp._field[value.attribute].uiName or QActorProp._field[value.attribute].name
					local num = value.refineValue
					num = q.getFilteredNumberToString(num, QActorProp._field[value.attribute].isPercent, 2)     
					tf:setString(name..":"..num)
					tf:setVisible(true)
					index = index + 1
				end
			end
		end
	end
	self._openUseType = 0
	self._sellUseType = 0
	self._ccbOwner.node_btn_sell:setVisible(true)
	local useTypes = string.split(maigcHerbItemConfig.use_type, ";")
	if #useTypes > 1 then
		self._openUseType = tonumber(useTypes[1])
		self._sellUseType = tonumber(useTypes[2])
		self:setButtonByType(self._ccbOwner.node_btn_open, self._ccbOwner.tf_btn_open, tonumber(useTypes[1]), -110)
		self:setButtonByType(self._ccbOwner.node_btn_sell, self._ccbOwner.tf_btn_sell, tonumber(useTypes[2]), 90)
	elseif useTypes[1] then
		self._openUseType = tonumber(useTypes[1])
		self:setButtonByType(self._ccbOwner.node_btn_open, self._ccbOwner.tf_btn_open, tonumber(useTypes[1]), 0)
		self._ccbOwner.node_btn_sell:setVisible(false)
	end
	
	makeNodeFromGrayToNormal(self._ccbOwner.btn_sell)
	makeNodeFromGrayToNormal(self._ccbOwner.btn_open)
	self._ccbOwner.btn_sell:setEnabled(true)
	self._ccbOwner.btn_open:setEnabled(true)
	if  maigcHerbItemConfig.selling_price == nil or maigcHerbItemConfig.selling_price == 0 then
		if self._sellUseType == ITEM_USE_TYPE.SELL then
			makeNodeFromNormalToGray(self._ccbOwner.btn_sell)
			self._ccbOwner.btn_sell:setEnabled(false)
		elseif self._openUseType == ITEM_USE_TYPE.SELL then
			makeNodeFromNormalToGray(self._ccbOwner.btn_open)
			self._ccbOwner.btn_open:setEnabled(false)
		end
	end

	self:_updateLock()

	self:effectIn(self._ccbOwner.tf_maigcHerb_name)
	self:effectIn(self._ccbOwner.tf_maigcHerb_state)
	self:effectIn(self._ccbOwner.tf_maigcHerb_type)
	if magicHerbGradeConfig then
		self:effectIn(self._ccbOwner.tf_prop_1)
		self:effectIn(self._ccbOwner.tf_prop_2)
	end
	if maigcHerbItemInfo.attributes then
		self:effectIn(self._ccbOwner.tf_prop_3)
		self:effectIn(self._ccbOwner.tf_prop_4)
	end
end

function QUIWidgetBackPackInfo:_updateLock()
	if not self._magicHerbSid then 
		self._ccbOwner.btn_lock:setHighlighted(false)
		return
	end

	local maigcHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(self._magicHerbSid)
	if maigcHerbItemInfo  then
		self._ccbOwner.btn_lock:setHighlighted(maigcHerbItemInfo.isLock)
	else
		self._ccbOwner.btn_lock:setHighlighted(false)
	end
	self._ccbOwner.btn_lock:setVisible(true)

	print("self._openUseType = ", self._openUseType, "self._sellUseType = ", self._sellUseType)
	if self._openUseType == 5 and maigcHerbItemInfo.isLock then
		self._ccbOwner.node_btn_open:setVisible(false)
		self._ccbOwner.node_btn_sell:setPositionX(0)
	elseif self._sellUseType == 5 and maigcHerbItemInfo.isLock then
		self._ccbOwner.node_btn_sell:setVisible(false)
		self._ccbOwner.node_btn_open:setPositionX(0)
	elseif self._sellUseType and self._openUseType then
		self._ccbOwner.node_btn_open:setVisible(true)
		self._ccbOwner.node_btn_sell:setVisible(true)
		self._ccbOwner.node_btn_open:setPositionX(-110)
		self._ccbOwner.node_btn_sell:setPositionX(90)
	end
end

function QUIWidgetBackPackInfo:setTFValue(name, value)
	if self._index > 4 then return end
	if value ~= nil then
		if type(value) ~= "number" or value > 0 then
			self.detailStr = self.detailStr .. name.."          ＋"..value.."\n"
			-- self._ccbOwner["tf_name"..self._index]:setString(name)
			-- self._ccbOwner["tf_value"..self._index]:setString("＋"..value)
			self._index = self._index + 1
		end
	end
end

function QUIWidgetBackPackInfo:setButtonByType(node, ttf, useType, positionX)
	local word = self:getNameByUseType(useType)
	ttf:setString(word)

	node:setPositionX(positionX)
end

function QUIWidgetBackPackInfo:getNameByUseType(useType)
	local word = ""
	if useType == ITEM_USE_TYPE.OPEN or useType == ITEM_USE_TYPE.SELECT_OPEN then
		word = "打 开" 
	elseif useType == ITEM_USE_TYPE.USE_LINK then
		word = "使 用" 
	elseif useType == ITEM_USE_TYPE.SELL then
		word = "出 售" 
	elseif useType == ITEM_USE_TYPE.RECYCLE then
		word = "分 解" 
	elseif useType == ITEM_USE_TYPE.COMPOSITE then
		word = "合 成"
	elseif useType == ITEM_USE_TYPE.OPEN_USE then
		word = "打开并穿戴"
	elseif useType == ITEM_USE_TYPE.EQUIP then
		word = "装 备" 
	end

	return word
end

function QUIWidgetBackPackInfo:effectIn(node)
	node:setOpacity(0)
	node:runAction(CCFadeIn:create(0.3))
end

function QUIWidgetBackPackInfo:openPackageSucceed()
	local awards = {}

	local info = QStaticDatabase:sharedDatabase():getItemByID(self._itemId)
	local itemInfos = string.split(info.content, ";")
	for i = 1, #itemInfos, 1 do
		local itemInfo = string.split(itemInfos[i], "^")

		local itemType = "item"
		local itemId = itemInfo[1]
		if itemInfo[1] == "train_money" then
			itemType = "trainMoney"
		end

		table.insert(awards, {id = itemId, typeName = itemType, count = tonumber(itemInfo[2])})
	end

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
		options = {awards = awards}},{isPopCurrentDialog = true} )
end

function QUIWidgetBackPackInfo:_onTriggerSell(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_sell) == false then return end
	app.sound:playSound("common_small")
	if self:checkItemCategory(self._itemId) == false then
		return 
	end
	if self._sellUseType ~= nil then
		self:requestItemInfoByUseType(self._sellUseType)
	end
end

function QUIWidgetBackPackInfo:_onTriggerOpen(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_open) == false then return end
	app.sound:playSound("common_small")
	if self:checkItemCategory(self._itemId) == false then
		return 
	end
	if self._itemNum > 0 then
		--打开的以后都用use_type
		if self._openUseType ~= nil then
			self:requestItemInfoByUseType(self._openUseType)
		end
	end
end

function QUIWidgetBackPackInfo:requestItemInfoByUseType(useType)
	if useType ~= nil then
		if useType == ITEM_USE_TYPE.OPEN then
			local info = QStaticDatabase:sharedDatabase():getItemByID(self._itemId)
			if self._itemNum >= 2 and info.type ~= ITEM_CONFIG_TYPE.SKIN_ITEM 
				and info.type ~= ITEM_CONFIG_TYPE.RECHARGE_YUEKA and info.type ~= ITEM_CONFIG_TYPE.RECHARGE_All and info.type ~= ITEM_CONFIG_TYPE.RECHARGE_LEICHONG then
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPacksackMultipleOpen", 
					options = {itemId = self._itemId}} )
			else
				self:_openItem()
			end
		elseif useType == ITEM_USE_TYPE.SELECT_OPEN then
			self._itemChoose = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogXuanzejiangli", 
				options = {awardsId = self._itemId, isQuickWay = true, isMultiple = true}}, {isPopCurrentDialog = false} )
		elseif useType == ITEM_USE_TYPE.RECYCLE then
			local tab = self:getRecycleTabByInfo(self._itemId)
			if tab then
				app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroReborn", 
						options = {tab = tab, itemId = tonumber(self._itemId)}})
			end
			return
		elseif useType == ITEM_USE_TYPE.SELL then
			if self._itemNum > 0 then
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBackpackSell", options = {itemId=self._itemId}})
			end
		elseif useType == ITEM_USE_TYPE.USE_LINK then
			local itemConfig = QStaticDatabase.sharedDatabase():getItemByID(self._itemId)
			local itemUseLink = itemConfig.item_use_link
			if itemUseLink then
				local tbl = db:getItemUseLinkByID(itemUseLink)
				tbl.itemId = self._itemId
				QQuickWay:clickGoto(tbl)
			else
				app.tip:floatTip("噢，魂师大人，该物品并没有快速跳转, 请在游戏中自行摸索。")
			end
		elseif useType == ITEM_USE_TYPE.COMPOSITE then
			local itemInfo = remote.gemstone:getStoneCraftInfoByPieceId(self._itemId)
			if itemInfo == nil then return end
			
			local index = 1
			while itemInfo["component_id_"..index] do
				local haveNum = remote.items:getItemsNumByID(itemInfo["component_id_"..index])
				if itemInfo["component_num_"..index] > haveNum then
					app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogItemDropInfo",
			    		options = {id = itemInfo.item_id, count = remote.items:getItemsNumByID(itemInfo.item_id)}}, {isPopCurrentDialog = false})
					return 
				end
				index = index + 1
			end

			app:getClient():itemCraftRequest(itemInfo.item_id, function (data)
						local awards = {}
						table.insert(awards, {id = itemInfo.item_id, typeName = ITEM_TYPE.ITEM, count = 1})
						
						app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
							options = {awards = awards}},{isPopCurrentDialog = true} )
				end, function (...)

			end)
		elseif useType == ITEM_USE_TYPE.OPEN_USE then
			local info = db:getItemByID(self._itemId)
			if info.type == ITEM_CONFIG_TYPE.SKIN_ITEM then
				self:_openItem(true)
			end
		elseif useType == ITEM_USE_TYPE.EQUIP then
			if remote.magicHerb:checkMagicHerbUnlock(true) then
				local heroId = remote.magicHerb:getActorIdWithoutMagicHerb()
				if heroId == nil then
					app.tip:floatTip("当前没有魂师可以装备仙品")
					return
				end
				local heros = remote.herosUtil:getHaveHero()
				local pos = 1
				for i = 1, #heros do
					if heros[i] == heroId then
						pos = i
						break
					end
				end
				app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogHeroInformation",
					options = {hero = heros, pos = pos, isQuickWay = true, detailType = "HERO_MAGICHERB"}})
			end
		end
	end
end

function QUIWidgetBackPackInfo:getRecycleTabByInfo(itemId)
	local tab = "enchant"
	if itemId == 14000000 then
		tab = "artifactRecycle"
	    if app.unlock:checkLock("UNLOCK_ARTIFACT", true) == false then
	        return nil
	    end
	else
		local itemConfig = QStaticDatabase.sharedDatabase():getItemByID(itemId)
		if itemConfig.type == ITEM_CONFIG_TYPE.MAGICHERB then
			if remote.magicHerb:checkMagicHerbUnlock(true) then
				tab = "magicHerbPiece"
			else
				return nil
			end
		end
	end

	return tab
end


function QUIWidgetBackPackInfo:checkItemAndTips(item_id)
	local headStatus,_type = remote.headProp:checkItemTitleOrFrameByItem(item_id)
	if headStatus == remote.headProp.ITEM_HEAD_ACTIVATED then
		if _type == remote.headProp.TITLE_TYPE then
			app.tip:floatTip("该称号已经激活")
		elseif _type == remote.headProp.FRAME_TYPE then
			app.tip:floatTip("该头像框已经激活")
		end
		return false
	end
	return true
end

function QUIWidgetBackPackInfo:_openItem(isUse)

	if not self:checkItemAndTips(self._itemId) then
		return
	end	
	app:getClient():openItemPackage(self._itemId, 1, function(data)
			local luckyDrawAwards = data.luckyDrawItemReward
			if data.heroSkins then
				remote.heroSkin:openRecivedSkinDialog(data.heroSkins)
				if isUse and remote.herosUtil:getHeroByID(data.heroSkins[1].actorId) then
					remote.heroSkin:changeHeroSkinRequest(data.heroSkins[1].actorId, data.heroSkins[1].skinId)
				end
			elseif luckyDrawAwards ~= nil then
				local awards = {}
				for _,value in ipairs(luckyDrawAwards) do
					table.insert(awards, {id = value.id, typeName = value.type, count = value.count})
				end
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
					options = {awards = awards}},{isPopCurrentDialog = true} )
			end
			--充值额度类型 充值活动支持
			if self._itemType == 12 then
				local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(self._itemId)
        		remote.activity:updateRechargeData(itemConfig.content)
			end
			if self._itemType == 12 or self._itemType == 13 then
				app.tip:floatTip("使用成功")
			end
		end)	
end

function QUIWidgetBackPackInfo:_getHeroGenre()
	local actorId = QStaticDatabase:sharedDatabase():getActorIdBySoulId(self._itemId)
    local text, index = QStaticDatabase:sharedDatabase():getHeroGenreById(actorId)
    self._genreIndex = index
    return text
end

function QUIWidgetBackPackInfo:_onTriggerGenre(event)
	if q.buttonEventShadow(event,self._ccbOwner.btn_genre) == false then return end
	app.sound:playSound("common_small")
	if self._itemConfig.type == ITEM_CONFIG_TYPE.SOULSPIRIT_PIECE then
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSoulSpiritOverView"})
	elseif self._itemConfig.type == ITEM_CONFIG_TYPE.GODARM_PIECE then
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogGodarmOverView"})
	else
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPreview", 
			options = {genreType = self._genreIndex}})
	end
end

function QUIWidgetBackPackInfo:_onTriggerLock()
	app.sound:playSound("common_small")
	local maigcHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(self._magicHerbSid)
	remote.magicHerb:magicHerbLockRequest(maigcHerbItemInfo.sid, not maigcHerbItemInfo.isLock, function()
			if self._ccbView then
            	self:_updateLock()
            end
        end)
end

function QUIWidgetBackPackInfo:checkItemCategory(itemId)
	if itemId == nil then return false end
	local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(itemId)
	if itemInfo.unlock ~= nil then
		return app.unlock:checkLock(itemInfo.unlock, true)
	end
	if itemInfo.category == ITEM_CONFIG_CATEGORY.GEMSTONE_MATERIAL then
		return app.unlock:getUnlockGemStone(true)
	elseif itemInfo.category == ITEM_CONFIG_CATEGORY.MOUNT_MATERIAL then
		return app.unlock:getUnlockMount(true)
	elseif itemInfo.category == ITEM_CONFIG_CATEGORY.GODARM_CONSUM or itemInfo.category == ITEM_CONFIG_CATEGORY.GODARM_PIECE then
		return app.unlock:getUnlockGodarm(true)
	end
end

return QUIWidgetBackPackInfo