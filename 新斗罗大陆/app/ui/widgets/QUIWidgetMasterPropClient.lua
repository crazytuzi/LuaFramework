--
-- Author: Your Name
-- Date: 2015-12-19 16:33:41
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMasterPropClient = class("QUIWidgetMasterPropClient", QUIWidget)

local QUIHeroModel = import("...models.QUIHeroModel")
local QActorProp = import("...models.QActorProp")
local QRichText = import("...utils.QRichText")

function QUIWidgetMasterPropClient:ctor(options)
	local ccbFile = "ccb/effects/HeroMaster_HuadongClient.ccbi"
	local callBacks = {}
	QUIWidgetMasterPropClient.super.ctor(self, ccbFile, callBacks, options)
end

function QUIWidgetMasterPropClient:setClientInfo(masterLevel, isMax, currMasterInfo, nextMasterInfo, masterType,isOneStrength)
	print("QUIWidgetMasterPropClient:setClientInfo  : ", masterLevel, isMax, currMasterInfo, nextMasterInfo, masterType)
	local word = "饰品强化大师"
	if masterType == QUIHeroModel.EQUIPMENT_MASTER then
		word = "装备强化大师"
	elseif masterType == QUIHeroModel.EQUIPMENT_ENCHANT_MASTER then
		word = "装备觉醒大师"
	elseif masterType == QUIHeroModel.JEWELRY_ENCHANT_MASTER then
		word = "饰品觉醒大师"
	elseif masterType == QUIHeroModel.JEWELRY_BREAK_MASTER then
		word = "饰品突破大师"
	elseif masterType == QUIHeroModel.HERO_TRAIN_MASTER then
		word = "培养大师"
	elseif masterType == QUIHeroModel.GEMSTONE_MASTER then
		word = "魂骨强化大师"
	elseif masterType == QUIHeroModel.GEMSTONE_BREAK_MASTER then
		word = "魂骨突破大师"
	elseif masterType == QUIHeroModel.MAGICHERB_UPLEVEL_MASTER then
		word = "仙品升级大师"
	end
    local iconPath = QResPath(masterType.."icon")
    local wordPath = QResPath(masterType.."word")
    if masterType == QUIHeroModel.SPAR_STRENGTHEN_MASTER then
        iconPath = iconPath[1]
        wordPath = wordPath[1]

		self:setMasterIcon(self._ccbOwner.old_master_icon, iconPath)
		self:setMasterIcon(self._ccbOwner.new_master_icon, iconPath)
		self:setMasterIcon(self._ccbOwner.old_master_word, wordPath)
		self:setMasterIcon(self._ccbOwner.new_master_word, wordPath)
    else
        iconPath = QSpriteFrameByPath(iconPath[1])
        wordPath = QSpriteFrameByPath(wordPath[1])

		self:setMasterFrameIcon(self._ccbOwner.old_master_icon, iconPath)
		self:setMasterFrameIcon(self._ccbOwner.new_master_icon, iconPath)
		self:setMasterFrameIcon(self._ccbOwner.old_master_word, wordPath)
		self:setMasterFrameIcon(self._ccbOwner.new_master_word, wordPath)
    end

	self:showAllLabel()
	if masterLevel == 0 then
		self._ccbOwner.old_title:setVisible(false)
		self._ccbOwner.old_prop1:setVisible(false)
		self._ccbOwner.old_prop2:setVisible(false)
		self._ccbOwner.old_prop3:setVisible(false)
		self._ccbOwner.old_prop4:setVisible(false)
		self._ccbOwner.old_level:setString("")
		self._ccbOwner.node_no:setVisible(true)

		if isOneStrength then
			self._ccbOwner.new_title:setString(nextMasterInfo.master_level.."级效果")
			self._ccbOwner.new_level:setString("LV"..(nextMasterInfo.master_level))
		else
			self._ccbOwner.new_title:setString((masterLevel+1).."级效果")
			self._ccbOwner.new_level:setString("LV"..(masterLevel+1))
		end
		
		if masterType == QUIHeroModel.MAGICHERB_UPLEVEL_MASTER then
			self:_setProp("next_prop", nextMasterInfo)
		else
			self._ccbOwner.next_prop1:removeAllChildren()
			local richText1 = QRichText.new({
		            {oType = "font", content = "攻击",size = 20, color = COLORS.j},
		            {oType = "font", content = "+"..math.floor(nextMasterInfo.attack_value or 0),size = 20, color = COLORS.l},
		        },nil,{autoCenter = true})
		    if richText1 then
		    	richText1:setAnchorPoint(ccp(0, 0.5))
		        self._ccbOwner.next_prop1:addChild(richText1)
		    end
		    self._ccbOwner.next_prop2:removeAllChildren()
		    local richText2 = QRichText.new({
		            {oType = "font", content = "生命",size = 20, color = COLORS.j},
		            {oType = "font", content = "+"..math.floor(nextMasterInfo.hp_value or 0),size = 20, color = COLORS.l},
		        },nil,{autoCenter = true})
		    if richText2 then
		    	richText2:setAnchorPoint(ccp(0, 0.5))
		        self._ccbOwner.next_prop2:addChild(richText2)
		    end
		    self._ccbOwner.next_prop3:removeAllChildren()
		    local richText3 = QRichText.new({
		            {oType = "font", content = "物防",size = 20, color = COLORS.j},
		            {oType = "font", content = "+"..math.floor(nextMasterInfo.armor_physical or 0),size = 20, color = COLORS.l},
		        },nil,{autoCenter = true})
		    if richText3 then
		    	richText3:setAnchorPoint(ccp(0, 0.5))
		        self._ccbOwner.next_prop3:addChild(richText3)
		    end
		    self._ccbOwner.next_prop4:removeAllChildren()
		    local richText4 = QRichText.new({
		            {oType = "font", content = "法防",size = 20, color = COLORS.j},
		            {oType = "font", content = "+"..math.floor(nextMasterInfo.armor_magic or 0),size = 20, color = COLORS.l},
		        },nil,{autoCenter = true})
		    if richText4 then
		    	richText4:setAnchorPoint(ccp(0, 0.5))
		        self._ccbOwner.next_prop4:addChild(richText4)
		    end
			-- self._ccbOwner.next_prop1:setString("攻击+"..math.floor(nextMasterInfo.attack_value or 0))
			-- self._ccbOwner.next_prop2:setString("生命+"..math.floor(nextMasterInfo.hp_value or 0))
			-- self._ccbOwner.next_prop3:setString("物防+"..math.floor(nextMasterInfo.armor_physical or 0))
			-- self._ccbOwner.next_prop4:setString("法防+"..math.floor(nextMasterInfo.armor_magic or 0))
		end
	elseif isMax then
		self._ccbOwner.old_title:setString(masterLevel.."级效果")
		self._ccbOwner.old_level:setString("LV"..masterLevel)
		if masterType == QUIHeroModel.MAGICHERB_UPLEVEL_MASTER then
			self:_setProp("old_prop", currMasterInfo)
		else
			self._ccbOwner.old_prop1:setString("攻击+"..math.floor(currMasterInfo.attack_value or 0))
			self._ccbOwner.old_prop2:setString("生命+"..math.floor(currMasterInfo.hp_value or 0))
			self._ccbOwner.old_prop3:setString("物防+"..math.floor(currMasterInfo.armor_physical or 0))
			self._ccbOwner.old_prop4:setString("法防+"..math.floor(currMasterInfo.armor_magic or 0))
		end

		self._ccbOwner.next_prop1:setVisible(false)
		self._ccbOwner.next_prop2:setVisible(true)
		self._ccbOwner.next_prop3:setVisible(false)
		self._ccbOwner.next_prop4:setVisible(false)
		self._ccbOwner.node_no:setVisible(false)
		self._ccbOwner.new_title:setString("大师已满级")

		self._ccbOwner.next_prop2:removeAllChildren()
	    local richText2 = QRichText.new({
	            {oType = "font", content = "加成已全满",size = 20, color = COLORS.j},
	        },nil,{autoCenter = true})
	    if richText2 then
	    	richText2:setAnchorPoint(ccp(0, 0.5))
	        self._ccbOwner.next_prop2:addChild(richText2)
	    end
		-- self._ccbOwner.next_prop2:setString("加成已全满")
		self._ccbOwner.new_level:setString("")
	else
		self._ccbOwner.node_no:setVisible(false)
		self._ccbOwner.old_title:setString(masterLevel.."级效果")
		self._ccbOwner.old_level:setString("LV"..masterLevel)

		if isOneStrength then
			self._ccbOwner.new_title:setString(nextMasterInfo.master_level.."级效果")
			self._ccbOwner.new_level:setString("LV"..(nextMasterInfo.master_level))
		else
			self._ccbOwner.new_title:setString((masterLevel+1).."级效果")
			self._ccbOwner.new_level:setString("LV"..(masterLevel+1))
		end

		-- self._ccbOwner.new_title:setString((masterLevel+1).."级效果")
		-- self._ccbOwner.new_level:setString("LV"..masterLevel+1)

		if masterType == QUIHeroModel.MAGICHERB_UPLEVEL_MASTER then
			self:_setProp("old_prop", currMasterInfo)
			self:_setProp("next_prop", nextMasterInfo)
		else
			self._ccbOwner.old_prop1:setString("攻击+"..math.floor(currMasterInfo.attack_value or 0))
			self._ccbOwner.old_prop2:setString("生命+"..math.floor(currMasterInfo.hp_value or 0))
			self._ccbOwner.old_prop3:setString("物防+"..math.floor(currMasterInfo.armor_physical or 0))
			self._ccbOwner.old_prop4:setString("法防+"..math.floor(currMasterInfo.armor_magic or 0))


			self._ccbOwner.next_prop1:removeAllChildren()
			local richText1 = QRichText.new({
		            {oType = "font", content = "攻击",size = 20, color = COLORS.j},
		            {oType = "font", content = "+"..math.floor(nextMasterInfo.attack_value or 0),size = 20, color = COLORS.l},
		        },nil,{autoCenter = true})
		    if richText1 then
		    	richText1:setAnchorPoint(ccp(0, 0.5))
		        self._ccbOwner.next_prop1:addChild(richText1)
		    end
		    self._ccbOwner.next_prop2:removeAllChildren()
		    local richText2 = QRichText.new({
		            {oType = "font", content = "生命",size = 20, color = COLORS.j},
		            {oType = "font", content = "+"..math.floor(nextMasterInfo.hp_value or 0),size = 20, color = COLORS.l},
		        },nil,{autoCenter = true})
		    if richText2 then
		    	richText2:setAnchorPoint(ccp(0, 0.5))
		        self._ccbOwner.next_prop2:addChild(richText2)
		    end
		    self._ccbOwner.next_prop3:removeAllChildren()
		    local richText3 = QRichText.new({
		            {oType = "font", content = "物防",size = 20, color = COLORS.j},
		            {oType = "font", content = "+"..math.floor(nextMasterInfo.armor_physical or 0),size = 20, color = COLORS.l},
		        },nil,{autoCenter = true})
		    if richText3 then
		    	richText3:setAnchorPoint(ccp(0, 0.5))
		        self._ccbOwner.next_prop3:addChild(richText3)
		    end
		    self._ccbOwner.next_prop4:removeAllChildren()
		    local richText4 = QRichText.new({
		            {oType = "font", content = "法防",size = 20, color = COLORS.j},
		            {oType = "font", content = "+"..math.floor(nextMasterInfo.armor_magic or 0),size = 20, color = COLORS.l},
		        },nil,{autoCenter = true})
		    if richText4 then
		    	richText4:setAnchorPoint(ccp(0, 0.5))
		        self._ccbOwner.next_prop4:addChild(richText4)
		    end
			-- self._ccbOwner.next_prop1:setString("攻击+"..math.floor(nextMasterInfo.attack_value or 0))
			-- self._ccbOwner.next_prop2:setString("生命+"..math.floor(nextMasterInfo.hp_value or 0))
			-- self._ccbOwner.next_prop3:setString("物防+"..math.floor(nextMasterInfo.armor_physical or 0))
			-- self._ccbOwner.next_prop4:setString("法防+"..math.floor(nextMasterInfo.armor_magic or 0))
		end
	end
	-- self._ccbOwner.master_title:setString(word..masterLevel.."级")
end 

function QUIWidgetMasterPropClient:_setProp(keyStr, config)
	local index = 1

	while self._ccbOwner[keyStr..index] ~= nil do
		self._ccbOwner[keyStr..index]:setVisible(false)
		index = index + 1
	end

	index = 1
	for key, value in pairs(config) do
		if QActorProp._field[key] then
			local tfNode = self._ccbOwner[keyStr..index]
			if tfNode then
				local name = QActorProp._field[key].uiName or QActorProp._field[key].name
				local num = q.getFilteredNumberToString(value, QActorProp._field[key].isPercent, 2)
				if keyStr == "next_prop" then
					tfNode:removeAllChildren()
					local richText = QRichText.new({
				            {oType = "font", content = name,size = 20, color = COLORS.j},
				            {oType = "font", content = "+"..num,size = 20, color = COLORS.l},
				        },nil,{autoCenter = true})
				    if richText then
				    	richText:setAnchorPoint(ccp(0, 0.5))
				        tfNode:addChild(richText)
				    end
				else
					tfNode:setString(name.."+"..num)	
			    end
				tfNode:setVisible(true)
				index = index + 1
			else
				return
			end
		end
	end
end

function QUIWidgetMasterPropClient:setMasterFrameIcon(node, iconPath)
	node:removeAllChildren()
	local ccsprite1 = CCSprite:createWithSpriteFrame(iconPath)
	node:addChild(ccsprite1)
end

function QUIWidgetMasterPropClient:setMasterIcon(node, iconPath)
	node:removeAllChildren()
	local ccsprite1 = CCSprite:create(iconPath)
	node:addChild(ccsprite1)
end

function QUIWidgetMasterPropClient:showAllLabel()
	self._ccbOwner.old_title:setVisible(true)
	self._ccbOwner.old_prop1:setVisible(true)
	self._ccbOwner.old_prop2:setVisible(true)
	self._ccbOwner.old_prop3:setVisible(true)
	self._ccbOwner.old_prop4:setVisible(true)
	
	self._ccbOwner.new_title:setVisible(true)
	self._ccbOwner.next_prop1:setVisible(true)
	self._ccbOwner.next_prop2:setVisible(true)
	self._ccbOwner.next_prop3:setVisible(true)
	self._ccbOwner.next_prop4:setVisible(true)
	self._ccbOwner.next_prop1:removeAllChildren()
	self._ccbOwner.next_prop2:removeAllChildren()
	self._ccbOwner.next_prop3:removeAllChildren()
	self._ccbOwner.next_prop4:removeAllChildren()
end

return QUIWidgetMasterPropClient