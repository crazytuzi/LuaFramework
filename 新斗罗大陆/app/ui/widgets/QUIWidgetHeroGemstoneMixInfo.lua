local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroGemstoneMixInfo = class("QUIWidgetHeroGemstoneMixInfo", QUIWidget)
local QUIWidgetEquipmentAvatar = import("..widgets.QUIWidgetEquipmentAvatar")
local QUIWidgetHeroEquipmentEvolutionItem = import("..widgets.QUIWidgetHeroEquipmentEvolutionItem")
local QUIWidgetGemstonesBox = import("..widgets.QUIWidgetGemstonesBox")
local QUIWidgetItemsBox = import("...widgets.QUIWidgetItemsBox")
local QRichText = import("...utils.QRichText")
local QColorLabel = import("....utils.QColorLabel")
local QUIViewController = import("..QUIViewController")

function QUIWidgetHeroGemstoneMixInfo:ctor(options)
	local ccbFile = "ccb/Widget_Baoshi_mixInfo.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerHelpPartOne", callback = handler(self, self._onTriggerHelpPartOne)},
		{ccbCallbackName = "onTriggerHelpPartTwo", callback = handler(self, self._onTriggerHelpPartTwo)},
	}
	QUIWidgetHeroGemstoneMixInfo.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
    q.setButtonEnableShadow(self._ccbOwner.btn_help_1)
    q.setButtonEnableShadow(self._ccbOwner.btn_help_2)
	self._width, self._height = 540,600
    self._iconTbl = {}
	self._gemstoneBoxs ={}

end

function QUIWidgetHeroGemstoneMixInfo:onEnter()
	QUIWidgetHeroGemstoneMixInfo.super.onEnter(self)

end

function QUIWidgetHeroGemstoneMixInfo:onExit()
	QUIWidgetHeroGemstoneMixInfo.super.onExit(self)

end

function QUIWidgetHeroGemstoneMixInfo:setDetailInfo(actorId, gemstoneSid, gemstonePos)
	self._actorId = actorId
	self._gemstoneSid = gemstoneSid
	self._gemstonePos = gemstonePos

	local heroInfo = remote.herosUtil:getHeroByID(self._actorId)
	local gemstone = remote.gemstone:getGemstoneById(self._gemstoneSid)
	self._gemstone = gemstone
	local itemId = gemstone.itemId
	local mixLevel = gemstone.mix_level or 0
	
	self._ccbOwner.node_client_infoMax:setVisible(false)
	self._ccbOwner.node_client_info:setVisible(false)
	local itemConfig = db:getItemByID(gemstone.itemId)

	local curMixConfig,nextMixConfig = remote.gemstone:getGemstoneMixConfigAndNextByIdAndLv(itemId,mixLevel)

	self:setGemstoneSuitInfo(itemId , heroInfo , gemstone, curMixConfig or nextMixConfig )

	if nextMixConfig == nil then
		--max
		self._ccbOwner.node_client_infoMax:setVisible(true)
		self:setGemstoneMixPropInfo("max",curMixConfig,false ,true)
		self:setGemstoneMixIcon("max",itemConfig,gemstone,mixLevel)
		return
	end
	self._ccbOwner.node_client_info:setVisible(true)
	if curMixConfig == nil then
		self:setGemstoneMixPropInfo("old",nextMixConfig,true ,false)
		self:setGemstoneMixIcon("old",itemConfig,gemstone , mixLevel)
	else
		self:setGemstoneMixPropInfo("old",curMixConfig,false ,false)
		self:setGemstoneMixIcon("old",itemConfig,gemstone, mixLevel)
	end
	self:setGemstoneMixPropInfo("new",nextMixConfig,false ,false)
	self:setGemstoneMixIcon("new",itemConfig,gemstone, mixLevel+1)


end


-- message Gemstone {
--     optional string sid = 1; // 序列号
--     required int32 itemId = 2; // 物品编号
--     optional int32 level = 3; // 强化等级
--     optional int32 craftLevel = 4; // 突破等级
--     optional int32 actorId = 5; // 穿戴英雄
--     optional int32 position = 6; // 穿戴位置
--     optional int64 enhanceMoneyConsume = 7; // 强化消耗宝石币
--     optional int32 enhanceStoneConsume = 8; // 强化能量石消耗
--     optional int32 godLevel = 9; //进阶等级 升阶化神
--     optional int32 mix_exp = 10; //融合消耗的经验道具（总消耗）
--     optional int32 mix_level = 11; //融合等级
--     optional string refine_consume = 12; //精炼消耗历史：item_id1^count1,item_id2^count2...
--     optional int32 refine_level = 13; //精炼等级
-- }


function QUIWidgetHeroGemstoneMixInfo:setGemstoneSuitInfo(itemId , heroInfo , gemstone , mixConfig)

	self._height = 450

	local gemstoneSuits = remote.gemstone:getSuitByItemId(itemId)
	table.sort(gemstoneSuits, function (gemstoneConfig1, gemstoneConfig2)
		return gemstoneConfig1.gemstone_type <gemstoneConfig2.gemstone_type
	end)
	local mixLevelTbl = {}
	for index,gemstoneConfig in ipairs(gemstoneSuits) do
		if index > 4 then
			break
		end
		if self._gemstoneBoxs[index] == nil then
        	self._gemstoneBoxs[index] = QUIWidgetGemstonesBox.new()
        	self._ccbOwner["node_suit"..index]:addChild(self._gemstoneBoxs[index])
        	self._gemstoneBoxs[index]:setState(remote.gemstone.GEMSTONE_ICON)
	        self._gemstoneBoxs[index]:setNameVisible(true)
			local nameNode = self._gemstoneBoxs[index]:getName()
        	nameNode:setPositionY(nameNode:getPositionY() + 20)
        	self._gemstoneBoxs[index]:setIconScale(0.86)
		end
		local name = gemstoneConfig.name
		local frontName = q.SubStringUTF8(name,1,2)
		local backName = q.SubStringUTF8(name,3)

		self._gemstoneBoxs[index]:setName("SS+"..frontName.."\n"..backName)
		self._gemstoneBoxs[index]:setItemIdByData(gemstoneConfig.id , 0 , 1)


        local isWear = false
        if heroInfo.gemstones ~= nil then
        	for _,v in ipairs(heroInfo.gemstones) do
        		if v.itemId == gemstoneConfig.id and v.mix_level and tonumber(v.mix_level) >= 1 then
        			isWear = true
        			table.insert(mixLevelTbl , tonumber(v.mix_level))
        			break
        		end
        	end
        end


        if isWear == true then
        	self._gemstoneBoxs[index]:setNameColor(GAME_COLOR_LIGHT.normal)
        	self._gemstoneBoxs[index]:setGray(false)
        else
        	self._gemstoneBoxs[index]:setNameColor(GAME_COLOR_LIGHT.notactive)
        	self._gemstoneBoxs[index]:setGray(true)
        end
	end

	local countMix = #mixLevelTbl
    local mix2SuitLevel = 0
    local mix4SuitLevel = 0    
    if countMix > 1 then
	    table.sort( mixLevelTbl , function (a,b)
	        return a > b
	    end)

		mix2SuitLevel = mixLevelTbl[2]

	    if countMix >=4 then
	    	mix4SuitLevel = mixLevelTbl[4]
	    end
    end
    self._mix2SuitLevel = mix2SuitLevel
    self._mix4SuitLevel = mix4SuitLevel

 	self._ccbOwner.node_suit_skill_1:setPositionY(- 200)
    local showLevel = mix2SuitLevel == 0 and 1 or mix2SuitLevel
    local height = 30

	self._ccbOwner.sp_graL1:setVisible(false)
	self._ccbOwner.sp_graR1:setVisible(false)
	self._ccbOwner.sp_graL2:setVisible(false)
	self._ccbOwner.sp_graR2:setVisible(false)
    local suitSkill = remote.gemstone:getGemstoneMixSuitConfigByData(mixConfig.gem_suit, 2 ,showLevel)
    if suitSkill then
    	local skillIdTbl = string.split(suitSkill.suit_skill , ";")
    	if not q.isEmpty(skillIdTbl) then
    		local skillId = skillIdTbl[1]
    		local skillConfig = db:getSkillByID(skillId)
			self._ccbOwner.node_suitskill_desc_1:removeAllChildren()
	        local describe = skillConfig.description
	        local color = GAME_COLOR_LIGHT.notactive
			if mix2SuitLevel ~= 0 then
	        	describe = "##e【"..(skillConfig.name or "").."】##n"..describe
	         	color = GAME_COLOR_LIGHT.normal
	        else
	        	describe = "【"..(skillConfig.name or "").."】"..describe
	        end
			local text = QColorLabel:create(describe, 480, nil, nil, 18, color)
			text:setAnchorPoint(ccp(0, 1))
			local tfHeight = text:getContentSize().height
			self._ccbOwner.node_suitskill_desc_1:addChild(text)
			if mix2SuitLevel ~= 0 then
				tfHeight = tfHeight + 35
				self._ccbOwner.tf_dress_skill_tip:setVisible(true)
				self._ccbOwner.tf_dress_skill_tip:setPositionY(- tfHeight - 20)
			else
				tfHeight = tfHeight + 15
				self._ccbOwner.tf_dress_skill_tip:setVisible(false)
			end
		    height = tfHeight + 5 + height
		    self._ccbOwner.sp_graL1:setContentSize(CCSize(240, tfHeight))
		    self._ccbOwner.sp_graR1:setContentSize(CCSize(240, tfHeight))
			self._ccbOwner.sp_graL1:setVisible(true)
			self._ccbOwner.sp_graR1:setVisible(true)
    	end
    end
    showLevel = mix4SuitLevel == 0 and 1 or mix4SuitLevel
    suitSkill = remote.gemstone:getGemstoneMixSuitConfigByData(mixConfig.gem_suit,4 ,showLevel)

    self._ccbOwner.node_suit_skill_2:setPositionY(- 200 - height)

    if suitSkill then
    	local skillIdTbl = string.split(suitSkill.suit_skill , ";")
    	if not q.isEmpty(skillIdTbl) then
    		local skillId = skillIdTbl[1]
    		local skillConfig = db:getSkillByID(skillId)
			self._ccbOwner.node_suitskill_desc_2:removeAllChildren()

	        local describe = skillConfig.description
	        describe = QColorLabel.removeColorSign(describe)
	        local color = GAME_COLOR_LIGHT.notactive
	        if mix4SuitLevel ~= 0 then
	        	describe = "##e【"..(skillConfig.name or "").."】##n"..describe
	         	color = GAME_COLOR_LIGHT.normal
	        else
	        	describe = "【"..(skillConfig.name or "").."】"..describe
	        end
			local text = QColorLabel:create(describe, 480, nil, nil, 18, color)
			text:setAnchorPoint(ccp(0, 1))
			local tfHeight = text:getContentSize().height
			self._ccbOwner.node_suitskill_desc_2:addChild(text)
		    height =  tfHeight + 45 + height
			self._ccbOwner.sp_graL2:setContentSize(CCSize(240, tfHeight + 50))
		    self._ccbOwner.sp_graR2:setContentSize(CCSize(240, tfHeight + 50))    
		    self._ccbOwner.sp_graL2:setVisible(true)
			self._ccbOwner.sp_graR2:setVisible(true)
    	end
    else
    	self._ccbOwner.node_suit_skill_2:setVisible(false)
    end

    self._height = self._height + height 

    if self._height < 600 then
    	self._height = 600
    end

end


function QUIWidgetHeroGemstoneMixInfo:setGemstoneMixIcon(typeStr , itemConfig , gemstoneData , mixLevel)
	local nodeIcon = self._ccbOwner["node_icon_"..typeStr]

	if not nodeIcon or not itemConfig or not gemstoneData then return end

	if self._iconTbl[typeStr] == nil then
		self._iconTbl[typeStr] = QUIWidgetEquipmentAvatar.new()
		nodeIcon:addChild(self._iconTbl[typeStr])
	end
	self._iconTbl[typeStr]:setGemstonInfo(itemConfig, gemstoneData.craftLevel , 1.0 , gemstoneData.godLevel , mixLevel)
	-- self._iconTbl[typeStr]:hideAllColor()
end


function QUIWidgetHeroGemstoneMixInfo:setGemstoneMixPropInfo(typeStr , config , isZero , isMax , nameStr , fontColor)
	--node_icon_old
	--tf_prop_new_1
	--tf_prop_desc_old_1
	local propDesc =remote.gemstone:setPropInfo(config ,true,true,true)	
	for i,v in ipairs(propDesc) do
		local descText = self._ccbOwner["tf_prop_desc_"..typeStr.."_"..i]
		local propText = self._ccbOwner["tf_prop_"..typeStr.."_"..i]
		if descText and propText then
			descText:setString(v.name..":")
			if isZero then
				propText:setString("+0")
			else
				propText:setString("+"..v.value)
			end
		end
	end

end

function QUIWidgetHeroGemstoneMixInfo:getContentSize()
	return CCSize(self._width, self._height)
end

function QUIWidgetHeroGemstoneMixInfo:_onTriggerHelpPartOne(e)
    app.sound:playSound("common_menu")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGemstoneSkillInfo", 
        options={gemstone = self._gemstone , gemAdvancedType = remote.gemstone.GEMSTONE_MIX_SUIT_SKILL 
        , activateMixLevel = self._mix2SuitLevel or 0 , suitNum = 2 }}, {isPopCurrentDialog = false})
end

function QUIWidgetHeroGemstoneMixInfo:_onTriggerHelpPartTwo(e)
   app.sound:playSound("common_menu")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGemstoneSkillInfo", 
        options={gemstone = self._gemstone , gemAdvancedType = remote.gemstone.GEMSTONE_MIX_SUIT_SKILL 
        , activateMixLevel = self._mix4SuitLevel or 0 , suitNum = 4 }}, {isPopCurrentDialog = false})
end


return QUIWidgetHeroGemstoneMixInfo