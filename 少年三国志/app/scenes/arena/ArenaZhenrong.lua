local ArenaZhenrong = class("ArenaZhenrong",UFCCSModelLayer)
require("app.cfg.knight_info")
require("app.cfg.equipment_info")
require("app.cfg.treasure_info")
require("app.cfg.association_info")
local ArenaKnightIcon = require("app.scenes.arena.ArenaKnightIcon")
local ArenaPetIcon = require("app.scenes.arena.ArenaPetIcon")
local FunctionLevelConst = require "app.const.FunctionLevelConst"
local EquipmentConst = require("app.const.EquipmentConst")
local HeroGodCommon = require "app.scenes.herofoster.god.HeroGodCommon"

function ArenaZhenrong.create(...)
	return ArenaZhenrong.new("ui_layout/arena_ArenaZhenRong.json",Colors.modelColor,...)
end

function ArenaZhenrong:ctor(json,color,data,...)
	self._data = data
	self._dress_slot = 0
	if rawget(self._data,"dress_slot") then
		self._dress_slot = self._data.dress_slot
		if data.dresses and #data.dresses > 0 then
			for i,v in ipairs(data.dresses) do
				if v.id == self._dress_slot then
					self._dress_slot = v.base_id
					break
				end
			end
		end
	end
	self.super.ctor(self,...)

	self._pet = nil
	if rawget(data, "fpet") then
		self._pet = data.fpet
	end

	self:_initHashData()
	self:_initWidgets()
	self:_initScrollView()
	self:_initPageView()
	self:_setWidgets()
	self:_createStroke()
	self:_initEvents()
	self:showAtCenter(true)
end

--整理成一个hash,方便查询组合
function ArenaZhenrong:_initHashData()
	if self._data == nil then
		return
	end
	self._dataList = {}
	self._knightHash = {}
	self._equipmentHash = {}
	self._treasurehash = {}
	self._equipmentBaseIdHash = {}
	self._treasureBaseIdHash = {}
	for i,v in ipairs(self._data.equipments) do
		self._equipmentHash[v.id] = v
	end
	for i,v in ipairs(self._data.treasures) do
		self._treasurehash[v.id] = v
	end
	for i,v in ipairs(self._data.knights) do
		local knight = knight_info.get(v.base_id)
		if knight ~= nil then
			self._knightHash[knight.advance_code] = v
		end

		local _equipments = {}
		for i,v in pairs(self._data.fight_equipments[i])do
			if v > 0 then
				--建立一个hash
				local base_id = self._equipmentHash[v].base_id
				_equipments[base_id] = v
			end
		end
		local _treasures = {}
		for i,v in pairs(self._data.fight_treasures[i])do
			if v > 0 then
				--建立一个hash
				local base_id = self._treasurehash[v].base_id
				_treasures[base_id] = v
			end
		end

		local t = {
			knight = v,
			equipments = _equipments,
			treasures = _treasures,
		}
		self._dataList[v.id] = t
		-- table.insert(self._dataList,t)
	end
end

function ArenaZhenrong:_initWidgets(...)
	self._playerName = self:getLabelByName("Label_playerName")  --玩家名字
	self._playerName:enableStrokeEx(Colors.strokeBrown,1)
	self._mScrollView = self:getScrollViewByName("ScrollView_knight")
	if self._mPageView == nil then
		local panel = self:getPanelByName("Panel_HeroPanel")
		self._mPageView = CCSNewPageViewEx:createWithLayout(panel)
		self._mPageView:setClippingEnabled(false)
	end
	--主角头像
	self._mainKnightImage = self:getImageViewByName("ImageView_MainHero")

	--控件集合
	self._widgetsList = {}
	for i=1,6 do
		local list = {
			itemBg = self:getImageViewByName("Image_back_" .. i),    --背景图
			itemImage = self:getImageViewByName("ImageView_equip_" .. i),   --item icon
			nameLabel = self:getLabelByName("Label_equip_name_" .. i),  --名称
			qualityIcon = self:getButtonByName("Button_icon_" .. i),	--品级
			equipmentLevel = self:getLabelByName("Label_" .. i),                 --等级
			levelBg = self:getImageViewByName("ImageView_color_" .. i), 	--等级背景
		}
		table.insert(self._widgetsList,list)
	end

end


function ArenaZhenrong:_initScrollView(...)
	--这货只有一个主角
	if #self._data.knights <= 1 and not self._pet then
		self._mScrollView:setVisible(false)
		return
	end
	self._scrollViewButtons = {}
	local knightIconWidth = 0
	local size = self._mScrollView:getContentSize()

	--剔除主角
	for i=1,#self._data.knights-1 do
		local v = self._data.knights[i+1]
		local icon = ArenaKnightIcon.new(v.base_id)
		self._scrollViewButtons[i] = icon
		knightIconWidth = icon:getWidth()
		self._scrollViewButtons[i]:setPosition(ccp(knightIconWidth*(i-1),(size.height-knightIconWidth)/2))
		self._mScrollView:addChild(self._scrollViewButtons[i])
		self:registerBtnClickEvent(self._scrollViewButtons[i]:getButtonName(),function(widget) 
		    -- 点击事件
		    self:_showScrollViewSelected(i)
		    self._mPageView:scrollToPage(i)
		end )
	end

	-- 如果有上阵战宠
	if self._pet then
		local idx = #self._scrollViewButtons + 1
		local icon = ArenaPetIcon.new(self._pet.base_id)
		self._scrollViewButtons[idx] = icon
		knightIconWidth = icon:getWidth()
		self._scrollViewButtons[idx]:setPosition(ccp(knightIconWidth*(idx-1),(size.height-knightIconWidth)/2))
		self._mScrollView:addChild(self._scrollViewButtons[idx])
		self:registerBtnClickEvent(self._scrollViewButtons[idx]:getButtonName(),function(widget) 
		    -- 点击事件
		    self:_showScrollViewSelected(idx)
		    self._mPageView:scrollToPage(idx)
		end )
	end

	self:_showScrollViewSelected(0)
	--减去主角的
	local _scrollViewWidth = knightIconWidth*(#self._data.knights-1)
	if self._pet then
		_scrollViewWidth = _scrollViewWidth + knightIconWidth
	end

	self._mScrollView:setInnerContainerSize(CCSizeMake(_scrollViewWidth,size.height))
	if self._isFirstTimeEnter == true then
	    GlobalFunc.flyIntoScreenLR({self._mScrollView}, false, 0.2, 2, 100)
	end
end


--显示选中的背景 

--[[
	index从0开始
	index == 0表示主角
]]
function ArenaZhenrong:_showScrollViewSelected(index)
	--刷新数据
    self:_onRefreshIcons(index+1)
	--主角背景
	self:showWidgetByName("Image_select_back",index == 0)
	if self._scrollViewButtons == nil or #self._scrollViewButtons == 0 then
		return
	end
    for i,v in ipairs(self._scrollViewButtons) do
        self._scrollViewButtons[i]:showBackgroundImage(index == i)
    end
    --[[
    	#self._data.knights == 1  只有主角。
    	index == 0 点了主角头像
    ]]
    if self._mScrollView == nil or #self._data.knights == 1 or index == 0 then 
        return
    end

    local buttonWidth = self._scrollViewButtons[index]:getContentSize().width
    local innerContainer = self._mScrollView:getInnerContainer()
    --计算选中按钮的位置是否超出了
    local position = innerContainer:convertToWorldSpace(ccp(self._scrollViewButtons[index]:getPosition()))
    --滑动区域宽度
    local scrollAreaWidth = innerContainer:getContentSize().width- self._mScrollView:getContentSize().width
    if position.x < self._mScrollView:getPositionX() then
        --需要位移
        local percent = self._scrollViewButtons[index]:getPositionX()/scrollAreaWidth
        self._mScrollView:scrollToPercentHorizontal(percent*100,0.3,false)
        --因为position是世界坐标
    elseif math.abs(position.x) > self._mScrollView:getContentSize().width + self._mScrollView:getPositionX() - buttonWidth then
        --需要位移
        local percent = (math.abs(self._scrollViewButtons[index]:getPositionX())-self._mScrollView:getContentSize().width + buttonWidth)/scrollAreaWidth
        self._mScrollView:scrollToPercentHorizontal(100*percent,0.3,false)
    end
end

function ArenaZhenrong:_initPageView()
	self._mPageView:setPageCreateHandler(function ( page, index )
		local cell = require("app.scenes.arena.ArenaPageViewItem").new(self)
		cell:setTouchEnabled(true)
		return cell
	end)
	self._mPageView:setPageTurnHandler(function ( page, index, cell )
		local knight = self._data.knights[index+1]
		self:_showScrollViewSelected(index)
		-- cell:update(knight)
	end)
	self._mPageView:setPageUpdateHandler(function ( page, index, cell )
		local knight = self._data.knights[index+1]
		if self._pet and index == #self._scrollViewButtons then
			self:_onAddPetLayer(cell)
			cell:hideHero()
			__Log("self._mPageView:setPageUpdateHandler")
		elseif index == 0 then 
			if self._petLayer then
				self._petLayer:setVisible(false)
			end
			cell:update(index,knight,self._dress_slot,rawget(self._data,"clid"),rawget(self._data,"cltm"),rawget(self._data,"clop"))
		else
			if self._petLayer then
				self._petLayer:setVisible(false)
			end
			cell:update(index,knight)
		end
	end)
	self._mPageView:setClickCellHandler(function ( pageView, index, cell)
		cell:onClick()
	end)
	if self._pet then
		self._mPageView:showPageWithCount(#self._data.knights + 1)
	else
		self._mPageView:showPageWithCount(#self._data.knights)
	end
end

function ArenaZhenrong:_initEvents(...)
	-- self:enableAudioEffectByName("Button_close", false)
	-- self:registerBtnClickEvent("Button_close",function()
	-- 	self:animationToClose()
	-- 	local soundConst = require("app.const.SoundConst")
	--    	G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
	-- 	end)
	self:registerBtnClickEvent("Button_hero_back",function()
		self:_showScrollViewSelected(0)
		self._mPageView:scrollToPage(0)
		end)
end

--是否是机器人,根据Id
function ArenaZhenrong:_isRobot()
	return self._data.id < 10000
end

function ArenaZhenrong:_setWidgets(...)
	self._playerName:setText(self._data.name)
	local knightInfo = knight_info.get(self._data.knights[1].base_id)
	if knightInfo ~= nil then
		--主角品级框
		local mainKnightPinjiButton = self:getButtonByName("Button_hero_back")
	    if mainKnightPinjiButton then
	    	mainKnightPinjiButton:loadTextureNormal(G_Path.getEquipColorImage(knightInfo.quality,G_Goods.TYPE_KNIGHT))
	    	mainKnightPinjiButton:loadTexturePressed(G_Path.getEquipColorImage(knightInfo.quality,G_Goods.TYPE_KNIGHT))
	    end
    	local res_id = G_Me.dressData:getDressedResidWithClidAndCltm(knightInfo.id,self._dress_slot,
    		rawget(self._data,"clid"),rawget(self._data,"cltm"),rawget(self._data,"clop"))
    	self._mainKnightImage:loadTexture(G_Path.getKnightIcon(res_id))
	end
end

function ArenaZhenrong:_onAddPetLayer( cell )
    if not cell then 
        return 
    end
     
    if not self._petLayer then 
        self._petLayer = require("app.scenes.arena.ArenaZhenrongPetLayer").create()
        self._petLayer:retain()

        self._petLayer:updateView(self._pet)
    end 
    self._petLayer:removeFromParentAndCleanup(false)
    cell:getRootWidget():addNode(self._petLayer, 2000, 2000)

    local pos0 = ccp(self:getPanelByName("Panel_knights"):getPosition())
    local pos1 = ccp(self:getPanelByName("Panel_baseinfo"):getPosition())
    pos0 = self:getPanelByName("Root"):convertToWorldSpace(pos0)
    pos1 = self:getPanelByName("Root"):convertToWorldSpace(pos1)
    pos0 = self:getPanelByName("Panel_HeroPanel"):convertToNodeSpace(pos0)
    pos1 = self:getPanelByName("Panel_HeroPanel"):convertToNodeSpace(pos1)
    local cellSize = cell:getSize()
    local maxHeight = pos0.y - pos1.y
    self._petLayer:adapterWithSize(CCSize(640 ,maxHeight))
    self._petLayer:setPosition(ccp(0,pos1.y + 100))
    self._petLayer:setVisible(true)

end

--传过来的index必须不能超过装备和武将的长度
function ArenaZhenrong:_onRefreshIcons(index)

	-- 如果是宠物则不做处理
	if self._pet and index == #self._scrollViewButtons + 1 then
		self:showWidgetByName("equip", false)
		self:showWidgetByName("Panel_stars", false)
		return
	else
		self:showWidgetByName("equip", true)
		self:showWidgetByName("Panel_stars", true)
	end

	local equipmentList = self._data.fight_equipments[index]
	if equipmentList == nil then
		__LogTag("wkj","ERROR------------")
		return
	end
	local treasureList = self._data.fight_treasures[index]
	if treasureList == nil then
		return
	end
	--每个武将身上4件装备 --2个宝物
	for i=1,6 do
		local widgetSet = self._widgetsList[i]
		local slotId = (i <= 4) and equipmentList["slot_" .. i] or treasureList["slot_" .. (i-4)]
		widgetSet["itemBg"]:setVisible(slotId ~= 0)
		widgetSet["nameLabel"]:setVisible(slotId ~= 0)
		widgetSet["qualityIcon"]:setVisible(slotId ~= 0)
		widgetSet["equipmentLevel"]:setVisible(slotId ~= 0)

		if i <= 4 then
			self:getPanelByName("Panel_stars_equip_" .. i):setVisible(slotId ~= 0)
		end

		if slotId ~= 0 then
			local baseData = (i <= 4) and self._equipmentHash[slotId] or self._treasurehash[slotId]
			if baseData then
				local baseInfo = (i <= 4) and equipment_info.get(baseData.base_id) or treasure_info.get(baseData.base_id)
				if baseInfo then
					--装备Icon
					if i<=4 then
						widgetSet["itemImage"]:loadTexture(G_Path.getEquipmentIcon(baseInfo.res_id),UI_TEX_TYPE_LOCAL)
					else
						widgetSet["itemImage"]:loadTexture(G_Path.getTreasureIcon(baseInfo.res_id),UI_TEX_TYPE_LOCAL)
					end
					widgetSet["levelBg"]:setVisible(true)
					widgetSet["levelBg"]:loadTexture(Colors.levelImages[baseInfo.quality],UI_TEX_TYPE_PLIST)
					widgetSet["equipmentLevel"]:setText(baseData.level)
					local _type = i<=4 and G_Goods.TYPE_EQUIPMENT or G_Goods.TYPE_TREASURE
					widgetSet["itemBg"]:loadTexture(G_Path.getEquipIconBack(baseInfo.quality))
					widgetSet["qualityIcon"]:loadTextureNormal(G_Path.getEquipColorImage(baseInfo.quality,_type))
					widgetSet["qualityIcon"]:loadTexturePressed(G_Path.getEquipColorImage(baseInfo.quality,_type))
					widgetSet["nameLabel"]:setColor(Colors.qualityColors[baseInfo.quality])
					widgetSet["nameLabel"]:setText(baseInfo.name)

					if i <= 4 then

						local panel = self:getPanelByName("Panel_stars_equip_" .. i)

						-- 升星等级
		                local starLevel = baseData.star
		                if starLevel and starLevel > 0 then
		                    panel:setVisible(true)
		                    for j = 1, EquipmentConst.Star_MAX_LEVEL do
		                        self:showWidgetByName(string.format("Image_start_%d_%d_full", i , j), j <= starLevel)

		                    end

		                    local start_pos = {x = -47, y = -60}
		                    panel:setPositionXY(start_pos.x + 9 * (EquipmentConst.Star_MAX_LEVEL - starLevel), start_pos.y)

		                else
		                    panel:setVisible(false)
		                end
					end
				end
			end
		end
	end

	local protectPetId
	local pet
	if self._data.has_ppet[index] then
		local petIndex = 0
		for i =1, index do
			if self._data.has_ppet[i] then
				petIndex = petIndex + 1
			end
		end

		pet = self._data.ppet[petIndex]
	end
	if pet then
		protectPetId = pet.base_id
    end
    local baseInfo
    if protectPetId then
    	baseInfo = pet_info.get(protectPetId)
    	self:showWidgetByName("Panel_button_7", true)
    else
    	self:showWidgetByName("Panel_button_7", false)
    end

    local button = self:getButtonByName("Button_7")
    button:setEnabled(false)

    if baseInfo then
    	local uiIndex = 7

    	local pingji = self:getImageViewByName("ImageView_icon_"..uiIndex)
	    local iconImage = self:getImageViewByName("ImageView_equip_"..uiIndex)
	    local iconBack = self:getImageViewByName("Image_back_"..uiIndex)

	    pingji:setVisible(true)
	    iconImage:setVisible(true)
	    iconBack:setVisible(true)

        if iconImage then
            local imgPath = G_Path.getPetIcon(baseInfo.res_id)
            iconImage:loadTexture(imgPath, UI_TEX_TYPE_LOCAL)
        end

        if pingji then
            pingji:loadTexture(G_Path.getEquipColorImage(baseInfo.quality))
        end

        local pingjiPiece = self:getImageViewByName("ImageView_color_"..uiIndex)
        if pingjiPiece then
            pingjiPiece:loadTexture(G_Path.getAddtionKnightColorPieceImage(baseInfo.quality))
        end

        if iconBack then 
            iconBack:loadTexture(G_Path.getEquipIconBack(baseInfo.quality))
        end

        local label = self:getLabelByName("Label_pet_name_"..uiIndex)
        if label then
            label:setVisible(true)
            label:setColor(Colors.getColor(baseInfo.quality))
            label:setText(baseInfo.name)
            label:createStroke(Colors.strokeBrown, 1)
        end
        local numLabel = self:getLabelByName("Label_"..uiIndex)
        numLabel:setText(""..pet["level"])
        numLabel:setVisible(true)
        numLabel:createStroke(Colors.strokeBrown, 1)

    end

	--刷新基础信息
	self:_onRefreshBasicInfo(index)
	--刷新武将技能
	self:_updateKnightSkillList(index)
end


--刷新底部基础信息 --index从1开始
function ArenaZhenrong:_onRefreshBasicInfo(index)
	local kni = self._data.knights[index]
	local knight = knight_info.get(kni.base_id)
	self:getLabelByName("Label_knightName"):setColor(Colors.qualityColors[knight.quality])
	if index == 1 then
		self:getLabelByName("Label_knightName"):setText(self._data.name)
	else
		self:getLabelByName("Label_knightName"):setText(knight.name)
	end

	local godImage = self:getImageViewByName("Image_God_Level")
	local godLabel = self:getLabelByName("Label_God_Level")
	HeroGodCommon.setGodShuiYin(godImage, godLabel, kni)

	local advanceLevel = knight.advanced_level
	if knight.advanced_level <= 0 then
		self:showWidgetByName("Label_jinjieLevel",false)
	else
		self:showWidgetByName("Label_jinjieLevel",true)
		self:getLabelByName("Label_jinjieLevel"):setColor(Colors.qualityColors[knight.quality])
		self:getLabelByName("Label_jinjieLevel"):setText("+" .. knight.advanced_level)
	end
	--第一个为主角
	--判断是否为机器人,根据userId < 10000
	local mainKnight = self._data.knights[1]
	if self:_isRobot() ~= true then
		self:getLabelByName("Label_level_value"):setText(string.format("%d/%d",kni.level,mainKnight.level))
	else
		local kniLevel = math.pow(self._data.fight_value,0.33)
		kniLevel = kniLevel - kniLevel%1
		local mainLevel = math.pow(self._data.fight_value,0.33)
		mainLevel = mainLevel - mainLevel%1
		self:getLabelByName("Label_level_value"):setText(string.format("%d/%d",kniLevel,mainLevel))
	end

	 local curKnightAttri = nil
		if kni.id > 0 then
			curKnightAttri = G_Me.bagData.knightsData:getKnightAttr1ByKnight(kni)
		end
	if curKnightAttri == nil then
		__LogTag("wkj","ERROR")
		return
	end
	--攻击
	self:getLabelByName("Label_attack_value"):setText(curKnightAttri.attack)
	--HP
	self:getLabelByName("Label_hp_value"):setText(curKnightAttri.hp)
	--物理防
	self:getLabelByName("Label_def_wuli_value"):setText(curKnightAttri.phyDefense)
	--法防
	self:getLabelByName("Label_def_mofa_value"):setText(curKnightAttri.magicDefense)


	--国家
	local image = self:getImageViewByName("ImageView_country")
	if knight.group == 0 then
		--主角
		image:setVisible(false)

	else
		image:setVisible(true)
		image:loadTexture(G_Path.getKnightGroupIcon(knight.group))
	end

	--武将类型 防御或者进攻
	local image = self:getImageViewByName("ImageView_type")
	if image then
		if knight.character_tips then
			image:loadTexture(G_Path.getJobTipsIcon(knight and knight.character_tips or 0))
			image:setVisible(true)
		else
			image:setVisible(false)
		end
	end
        
        local awaken_star = math.floor(kni.awaken_level / 10)
        if (knight.potential < 20 and knight.group ~= 0)  -- 武将品质不是橙色及以上且不是主角（主角阵营为0）
            or kni.level < G_moduleUnlock:getModuleUnlockLevel(FunctionLevelConst.AWAKEN) -- 当前武将的等级没有到觉醒开启等级
            then
            awaken_star = -1
        end
        
        self:showWidgetByName("Panel_stars", not (awaken_star == -1))
        for i=1, 6 do
            self:showWidgetByName("Image_star"..i, i <= awaken_star)
        end
        
end

function ArenaZhenrong:_updateKnightSkillList(index)
	local kni = self._data.knights[index]
	local knight = knight_info.get(kni.base_id)
	local getSkillList = function(knight)
		local _t = {}
		for i=1,6 do
			if knight["association_" .. i] > 0 then
				local association = association_info.get(knight["association_" .. i])
				if association then
					table.insert(_t,association)
				end
			end
		end
		return _t
	end
	local skillNames = {
		"Label_skill_1","Label_skill_2",			--技能
		"Label_skill_3","Label_skill_4",			
		"Label_skill_5","Label_skill_6",	
	}
	--技能list
	local skillList = getSkillList(knight)
	for i=1,6 do
		local associtation = skillList[i]
		self:showWidgetByName(skillNames[i],i<=#skillList)
		self:showWidgetByName("ImageView_dot_" .. i,i<=#skillList)
		if i<=#skillList then
			local image = self:getImageViewByName("ImageView_dot_" .. i)
			local skillLabel = self:getLabelByName(skillNames[i])
			local isActive = false
			self:getLabelByName("Label_skill_" .. i):setText(associtation.name)
			--武将组合
			if associtation.info_type == 1 then
				isActive = self:checkKnightAssociation(associtation)
			--技能组合
			elseif associtation.info_type == 2 then
				isActive = self:checkEquipmentAssocition(kni,associtation)
			--宝物组合
			else
				isActive = self:checkTreasureAssocition(kni,associtation)
			end
			image:loadTexture(isActive and "ui/zhengrong/dot_dianliang.png" or "ui/zhengrong/dot_weidianliang.png", UI_TEX_TYPE_LOCAL)
			skillLabel:setColor(isActive and Colors.activeSkill or Colors.inActiveSkill)
			skillLabel:setText(skillLabel:getStringValue())
		end
	end
end

function ArenaZhenrong:checkKnightAssociation(association)
	if association == nil then
		return false
	end
	local i = 1
	while association["info_value_" .. i] > 0 do
		local knightId = association["info_value_" .. i]
		if self._knightHash[knightId] == nil then
			return false
		end
		i = i + 1 
	end
	return true
end

function ArenaZhenrong:checkEquipmentAssocition(knight,association)
	if association == nil then
		return false
	end
	local i = 1
	while association["info_value_" .. i] > 0 do
		local equipId = association["info_value_" .. i]
		if self._dataList[knight.id].equipments[equipId] == nil then
			return false
		end
		i = i + 1 
	end
	return true 
end

function ArenaZhenrong:checkTreasureAssocition(knight,association)
	if association == nil then
		return false
	end
	if association == nil then
		return false
	end
	local i = 1
	while association["info_value_" .. i] > 0 do
		local treasureId = association["info_value_" .. i]
		if self._dataList[knight.id].treasures[treasureId] == nil then
			return false
		end
		i = i + 1 
	end
	return true 
end

function ArenaZhenrong:_createStroke()
	local createStoke = function ( nameList,color )
			if nameList == nil or type(nameList) ~= "table" then
				return
			end
			for i,v in ipairs(nameList) do
		        local label = self:getLabelByName(v)
		        if label then 
		        	if color then
		        		label:createStroke(color, 1)
		            else
		            	label:createStroke(Colors.strokeBrown, 1)
		        	end
		        end
			end
	    end

	local nameList = {
					"Label_level_name","Label_level_value",   	--等级
					"Label_attack","Label_attack_value",		--攻击
					"Label_hp","Label_hp_value",				--生命
					"Label_def_wuli","Label_def_wuli_value",	--物防
					"Label_def_mofa","Label_def_mofa_value",	--魔防
					"Label_skill_1","Label_skill_2",			--技能
					"Label_skill_3","Label_skill_4",			
					"Label_skill_5","Label_skill_6",			
					"Label_zuhe","Label_basic",					--基础信息和组合
					"Label_equip_name_1","Label_equip_name_2",	--装备名
					"Label_equip_name_3","Label_equip_name_4",
					"Label_equip_name_5","Label_equip_name_6",
					"Label_knightName",							--武将名
					"Label_jinjieLevel",							--突破level
					}
	createStoke(nameList)
	local list = {
		"Label_1","Label_2","Label_3","Label_4","Label_5","Label_6",
		}
	createStoke(list,Colors.strokeBlack)

end

function ArenaZhenrong:onLayerEnter()
	require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_Continue"), "smoving_wait", nil , {position = true} )
	self:closeAtReturn(true)
	self:setClickClose(true)
	self:callAfterFrameCount(1, function ( ... )
	GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Button_1"), 
	    self:getWidgetByName("Button_4"), 
	    self:getWidgetByName("Button_5")}, true, 0.2, 5, 50)

	GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Button_3"), 
	    self:getWidgetByName("Button_2"), 
	    self:getWidgetByName("Button_6"),
	    self:getWidgetByName("Button_7")}, false, 0.2, 5, 50)
	GlobalFunc.flyIntoScreenLR({self:getWidgetByName("ScrollView_knight")}, false, 0.2, 2, nil)
	    GlobalFunc.flyIntoScreenLR({self:getWidgetByName("ImageView_back_main")}, true, 0.2, 2, nil)
	    GlobalFunc.flyFromMiddleToSize(self:getWidgetByName("Image_paper"), 0.3, 0.1, function ( ... )
	    end)
	    GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Image_baseinfo"), 
	            self:getWidgetByName("Panel_left")}, true, 0.2, 2, 50)
	        GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Image_skill"), 
	            self:getWidgetByName("Panel_right")}, false, 0.2, 1, 50)
	end)
end

function ArenaZhenrong:onLayerUnload(  )
	if self._petLayer then
		self._petLayer:release()
	end
end

return ArenaZhenrong