local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroGemstoneDetail = class("QUIWidgetHeroGemstoneDetail", QUIWidget)
local QScrollContain = import("..QScrollContain")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetGemstonesBox = import("..widgets.QUIWidgetGemstonesBox")
local QUIViewController = import("..QUIViewController")
local QUIWidgetEquipmentAvatar = import("..widgets.QUIWidgetEquipmentAvatar")
local QQuickWay = import("...utils.QQuickWay")
local QActorProp = import("...models.QActorProp")
local QUIWidgetQualitySmall = import("..widgets.QUIWidgetQualitySmall")
local QColorLabel = import("...utils.QColorLabel")
local QRichText = import("...utils.QRichText")

function QUIWidgetHeroGemstoneDetail:ctor(options)
	local ccbFile = "ccb/Widget_Baoshi_info.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerWear", callback = handler(self, self._onTriggerWear)},
		{ccbCallbackName = "onTriggerUnwear", callback = handler(self, self._onTriggerUnwear)},
		{ccbCallbackName = "onTriggerHelp", callback = handler(self, self._onTriggerHelp)},
		{ccbCallbackName = "onTriggerHelpPartOne", callback = handler(self, self._onTriggerHelpPartOne)},
		{ccbCallbackName = "onTriggerHelpPartTwo", callback = handler(self, self._onTriggerHelpPartTwo)},
		}
	QUIWidgetHeroGemstoneDetail.super.ctor(self,ccbFile,callBacks,options)

	if options.callback then
		self._callback = options.callback
	end
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._ccbOwner.change_tip:setVisible(false)
    q.setButtonEnableShadow(self._ccbOwner.btn_help_1)
    q.setButtonEnableShadow(self._ccbOwner.btn_help_2)
    self:initBasicSetting()

	self._gemstoneBoxs = {}
	self._colorfulTextTbl = {}
	self._colorfulOtherTextTbl = {}
	self._god_gemstoneBoxs = {}

end

function QUIWidgetHeroGemstoneDetail:onEnter( ... )
	QUIWidgetHeroGemstoneDetail.super.onEnter(self)
    self:initScrollView()
end

function QUIWidgetHeroGemstoneDetail:onExit(  )
	QUIWidgetHeroGemstoneDetail.super.onExit(self)
    if self._scrollContain ~= nil then
    	self._scrollContain:disappear()
    	self._scrollContain = nil
    end
end


function QUIWidgetHeroGemstoneDetail:initBasicSetting()
	-- body
	self._ccbOwner.title_3:setString("魂骨套装")
	self._ccbOwner.title_4:setString("套装属性")
	self._ccbOwner.title_5:setString("进阶属性")
	self._ccbOwner.title_6:setString("化神属性")
	self._ccbOwner.title_7:setString("化神套装")
	self._ccbOwner.title_8:setString("化神套装属性")

end

function QUIWidgetHeroGemstoneDetail:setSABC(node)
    local nodeOwner = {}
    local pingzhiNode = CCBuilderReaderLoad("ccb/Widget_Hero_pingzhi.ccbi", CCBProxy:create(), nodeOwner)
    node:addChild(pingzhiNode)

    q.setAptitudeShow(nodeOwner, "ss")
end

function QUIWidgetHeroGemstoneDetail:runAni(to_top,callBack)
    local size = self._scrollContain:getContentSize()

	local move_offside = -size.height
	if  not to_top then
		move_offside = size.height
	end

	self._scrollContain:moveTo(0, move_offside , true ,callBack)

end	

function QUIWidgetHeroGemstoneDetail:initScrollView()
	self._scrollContain = QScrollContain.new({sheet = self._ccbOwner.sheet, sheet_layout = self._ccbOwner.sheet_layout, direction = QScrollContain.directionY , endRate = 0.1})
	self._ccbOwner.node_content:retain()
	self._ccbOwner.node_content:removeFromParent()
	self._scrollContain:addChild(self._ccbOwner.node_content)
	self._ccbOwner.node_content:release()
	local size = self._scrollContain:getContentSize()
	size.height = 635
    self._scrollContain:setContentSize(size.width, size.height)
end

function QUIWidgetHeroGemstoneDetail:changeScrollViewSize(godLevel,gemstoneQuality,godskills , start_pos )
    local size = self._scrollContain:getContentSize()

    if not app.unlock:checkLock("GEMSTONE_EVOLUTION",false) or gemstoneQuality < APTITUDE.S  then
    	size.height = 635
    	self._ccbOwner.node_client5:setVisible(false)
    	self._ccbOwner.node_client6:setVisible(false)
		self._ccbOwner.node_client7:setVisible(false)
    	self._ccbOwner.node_client8:setVisible(false)
    	self._ccbOwner.node_ssp_skill_suit:setVisible(false)
    	self._scrollContain:setContentSize(size.width, size.height)
    	return
    end


    if gemstoneQuality >= APTITUDE.S then
		local dis_8 = (5 - godskills ) * -50
		local dis_4 = - 255 - start_pos
    	size.height = 635 + dis_4
    	self._ccbOwner.node_client5:setVisible(godLevel > 0)
    	self._ccbOwner.node_client6:setVisible(godLevel > 25)
    	self._ccbOwner.node_client7:setVisible(godLevel >= 25)
    	self._ccbOwner.node_client8:setVisible(godLevel >= 25)
    	self._ccbOwner.node_client5:setPosition(ccp(146,start_pos))
		self._ccbOwner.lg_left8:setContentSize(240, 295 +  dis_8)
		self._ccbOwner.lg_right8:setContentSize(240, 295 + dis_8)


		local height_dis = 0
		local node_table = {self._ccbOwner.node_client7,self._ccbOwner.node_client8,self._ccbOwner.node_client5,self._ccbOwner.node_client6}
		local node_h_table = {180 ,335 + dis_8,150,150}

		for i,v in ipairs(node_table) do
			if v:isVisible() then

				v:setPositionY(start_pos - height_dis)
				height_dis = height_dis + node_h_table[i]
			end
		end
		size.height = size.height + height_dis 



	  --   if godLevel > 0 and godLevel <= 25 then  
   --  		size.height = size.height + 150
		 --   	self._ccbOwner.node_client5:setVisible(true)
			-- self._ccbOwner.node_client6:setVisible(false)	
		 --   	if  godLevel == 25 then

		 --   		size.height =  size.height + 180 + 335 - dis_
			-- 	self._ccbOwner.node_client7:setVisible(true)
   --  			self._ccbOwner.node_client8:setVisible(true)
			-- 	self._ccbOwner.node_client7:setPosition(ccp(146,-255))
	  --   		self._ccbOwner.node_client8:setPosition(ccp(146,-435))	

	  --   		self._ccbOwner.node_client5:setPosition(ccp(146,-770 + dis_))
		 --   	end
	   	
	  --   elseif godLevel > 25 then
	  --   	local dis_ = (5 - godskills ) * 50
	  --   	size.height =  size.height + 180  + 335 - dis_+ 150 + 150
	  --   	self._ccbOwner.node_client5:setVisible(true)
	  --   	self._ccbOwner.node_client6:setVisible(true)
			-- self._ccbOwner.node_client7:setVisible(true)
   --  		self._ccbOwner.node_client8:setVisible(true)	    
	  --   	self._ccbOwner.node_client7:setPosition(ccp(146,-255))
	  --   	self._ccbOwner.node_client8:setPosition(ccp(146,-435))
	  --   	self._ccbOwner.node_client5:setPosition(ccp(146,-770 + dis_))
	  --   	self._ccbOwner.node_client6:setPosition(ccp(146,-920 + dis_)) 	   
			-- self._ccbOwner.lg_left:setContentSize(240, 295 -  dis_)
			-- self._ccbOwner.lg_right:setContentSize(240, 295 - dis_)

	  --   end
	end
	self._scrollContain:setContentSize(size.width, size.height)


end
function QUIWidgetHeroGemstoneDetail:setInfo(actorId, gemstoneSid, gemstonePos)
	self._actorId = actorId
	self._gemstoneSid = gemstoneSid
	self._gemstonePos = gemstonePos
	local heroInfo = remote.herosUtil:getHeroByID(self._actorId)
	local gemstone = remote.gemstone:getGemstoneById(self._gemstoneSid)
	self._gemstone = gemstone
	local itemConfig = db:getItemByID(gemstone.itemId)
    local level,color = remote.herosUtil:getBreakThrough(gemstone.craftLevel) 
    local advancedLevel = gemstone.godLevel or remote.gemstone.GEMSTONE_GODLEVLE_TEST
	local mixLevel = gemstone.mix_level or 0

    if not self._scrollContain then
    	self:initScrollView()
    end

    --changeScrollViewSize 
    local name = itemConfig.name
	name = remote.gemstone:getGemstoneNameByData(name,advancedLevel,mixLevel)

    if level > 0 then
    	name = name .. "＋".. level
    end
	local typeStr = ""
    if mixLevel <= 0 then
    	typeStr = " 【"..remote.gemstone:getTypeDesc(itemConfig.gemstone_type).."】"
    end  	
	self._ccbOwner.tf_item_name:setString("LV."..gemstone.level.."  "..name..typeStr)

	local fontColor = BREAKTHROUGH_COLOR_LIGHT[color]
	self._ccbOwner.tf_item_name:setColor(fontColor)
	self._ccbOwner.tf_item_name = setShadowByFontColor(self._ccbOwner.tf_item_name, fontColor)
	

	if self._itemAvatar == nil then
		self._itemAvatar = QUIWidgetEquipmentAvatar.new()
		self._ccbOwner.equ_node:addChild(self._itemAvatar)
	end
	self._itemAvatar:setGemstonInfo(itemConfig, gemstone.craftLevel, 1.0 , advancedLevel , gemstone.mix_level)
	
	local UIHeroModel = remote.herosUtil:getUIHeroByID(self._actorId)
	local gemstoneInfo = UIHeroModel:getGemstoneInfoByPos(self._gemstonePos)
    self._ccbOwner.change_tip:setVisible(gemstoneInfo.isBetter)

	for i=1,6 do
		self._ccbOwner["tf_prop"..i]:setVisible(false)
	end
	self._index = 1
	if gemstone.prop ~= nil then
		self:setProp(gemstone.prop.attack_value, "攻    击：＋%d")
		self:setProp(gemstone.prop.hp_value, "生    命：＋%d")
		self:setProp(gemstone.prop.armor_physical, "物    防：＋%d")
		self:setProp(gemstone.prop.armor_magic, "法    防：＋%d")
		self:setProp(gemstone.prop.attack_percent, "攻击增加：＋%.1f%%", true)
		self:setProp(gemstone.prop.hp_percent, "生命增加：＋%.1f%%", true)
		self:setProp(gemstone.prop.armor_physical_percent, "物防增加：＋%.1f%%", true)
		self:setProp(gemstone.prop.armor_magic_percent, "法防增加：＋%.1f%%", true)
	end
   --魂骨套装与属性
	local gemstoneSuits = remote.gemstone:getSuitByItemId(gemstone.itemId)
	local suitCount = 0
	local suitOtherCount = 0

	table.sort(gemstoneSuits, function (gemstoneConfig1, gemstoneConfig2)
		return gemstoneConfig1.gemstone_type <gemstoneConfig2.gemstone_type
	end)	
	local gemstoneQuality = itemConfig.gemstone_quality

	if gemstoneQuality == APTITUDE.S then
		if gemstone.mix_level and gemstone.mix_level > 0 then
			gemstoneQuality =  APTITUDE.SSR
		elseif advancedLevel >= GEMSTONE_MAXADVANCED_LEVEL then
			gemstoneQuality =  APTITUDE.SS
		end
	end
	local gemstoneSuitTbl = {}	--data index - {isWear,isNormal,isSsGem,isSsrGem,beyondGodLv}
	local mixLevelTbl = {}
	self._gemstoneQuality = gemstoneQuality

	local suitCountTbl = {}
	suitCountTbl[1] = 0	
	suitCountTbl[2] = 0
	suitCountTbl[3] = 0

	for index,gemstoneConfig in ipairs(gemstoneSuits) do
		if index > 4 then
			break
		end
		if self._gemstoneBoxs[index] == nil then
			self._gemstoneBoxs[index] = QUIWidgetGemstonesBox.new()
			self._ccbOwner["node_suit"..index]:addChild(self._gemstoneBoxs[index])
        	self._gemstoneBoxs[index]:setState(remote.gemstone.GEMSTONE_ICON)

			local nameNode = self._gemstoneBoxs[index]:getName()
			nameNode:setPositionY(nameNode:getPositionY() + 20)
			self._gemstoneBoxs[index]:setIconScale(0.86)
        	self._gemstoneBoxs[index]:setNameVisible(true)
			self._gemstoneBoxs[index]:addEventListener(QUIWidgetGemstonesBox.EVENT_CLICK, handler(self, self.gemstoneBoxClickHandler))
		end


		local name = gemstoneConfig.name
		local frontName = q.SubStringUTF8(name,1,2)
		local backName = q.SubStringUTF8(name,3)
		local isWear = false
		local isNormal = false
		local isSsGem = false
		local isSsrGem = false
		local beyondGodLv = 0


        if heroInfo.gemstones ~= nil then
        	for _,v in ipairs(heroInfo.gemstones) do
        		if v.itemId == gemstoneConfig.id then
        			printTable(v)
        			printTable(gemstoneConfig)
        			isNormal = true
        			if v.mix_level and v.mix_level > 0 then
        				isSsrGem = true
        				isSsGem = true
        				table.insert(mixLevelTbl , tonumber(v.mix_level))
        			elseif v.godLevel and  v.godLevel >= GEMSTONE_MAXADVANCED_LEVEL then
        				isSsGem = true
        			end
        			if v.godLevel and v.godLevel > GEMSTONE_MAXADVANCED_LEVEL then
        				beyondGodLv = v.godLevel - GEMSTONE_MAXADVANCED_LEVEL
        			end
        			break
        		end
        	end
        end
        
		if isSsrGem then	-- SS+魂骨
			self._gemstoneBoxs[index]:setName("SS+"..frontName.."\n"..backName)
			self._gemstoneBoxs[index]:setItemIdByData(gemstoneConfig.id , 0 , 1)
			isWear = isSsrGem
			if isSsGem then
				suitOtherCount = suitOtherCount + 1
			end
			suitCountTbl[1] = suitCountTbl[1] + 1
			suitCountTbl[2] = suitCountTbl[2] + 1
			suitCountTbl[3] = suitCountTbl[3] + 1
		elseif isSsGem then	--只化神的SS魂骨
			self._gemstoneBoxs[index]:setName("SS"..frontName.."\n"..backName)
			self._gemstoneBoxs[index]:setItemIdByData(gemstoneConfig.id , GEMSTONE_MAXADVANCED_LEVEL , 0)
			isWear = isSsGem
			suitCountTbl[2] = suitCountTbl[2] + 1
			suitCountTbl[3] = suitCountTbl[3] + 1
		else
			self._gemstoneBoxs[index]:setItemIdByData(gemstoneConfig.id , 0 , 0)
			self._gemstoneBoxs[index]:setName(frontName.."\n"..backName)
			isWear = isNormal
			suitCountTbl[3] = suitCountTbl[3] + 1
		end
        if isWear == true then
        	suitCount = suitCount + 1
        	self._gemstoneBoxs[index]:setNameColor(GAME_COLOR_LIGHT.normal)
        	self._gemstoneBoxs[index]:setGray(false)
        else
        	self._gemstoneBoxs[index]:setNameColor(GAME_COLOR_LIGHT.notactive)
        	self._gemstoneBoxs[index]:setGray(true)
        end	

        table.insert(gemstoneSuitTbl , index , {isWear = isWear ,isNormal = isNormal ,isSsGem = isSsGem ,isSsrGem = isSsrGem , beyondGodLv = beyondGodLv})
	end

	local descTbl = {}
	local mixConfig = remote.gemstone:getGemstoneMixConfigByIdAndLv(gemstone.itemId, 1)

	local descOtherTbl = {}
	for i=1,3 do
		local count = i + 1
		if suitCountTbl[1] >= count then
			if mixConfig and mixConfig.gem_suit then
				local suitConfig = remote.gemstone:getGemstoneMixSuitConfigByData(mixConfig.gem_suit, count,1)
				if suitConfig then
					table.insert(descTbl , i , {forceText = "【SS+】" , normalText = suitConfig.set_desc , isActive = true })
				else
					table.insert(descTbl , i , {forceText = "【SS+】" , normalText = "", isActive = true })
				end
			end
		elseif suitCountTbl[2] >= count then
			local gemstoneInfo_ss = db:getGemstoneEvolutionBygodLevel(gemstone.itemId, GEMSTONE_MAXADVANCED_LEVEL)
			if gemstoneInfo_ss and gemstoneInfo_ss.gem_evolution_new_set then
				local suitInfos = db:getGemstoneSuitEffectBySuitId(gemstoneInfo_ss.gem_evolution_new_set)
				for index,suitInfo in ipairs(suitInfos) do
					if index == i then
						table.insert(descTbl , index , {forceText = "【SS】" , normalText = suitInfo.set_desc, isActive = true })
					end
				end
			end
		else
			local suitInfos = db:getGemstoneSuitEffectBySuitId(itemConfig.gemstone_set_index)
			for index,suitInfo in ipairs(suitInfos) do
				if index == i then
					table.insert(descTbl , index , {forceText = "" , normalText = suitInfo.set_desc, isActive = suitCountTbl[3] > index })
				end
			end

		end
	end

	-- if gemstoneQuality <= APTITUDE.S then	--普通的a与s级魂骨
	-- 	local suitInfos = db:getGemstoneSuitEffectBySuitId(itemConfig.gemstone_set_index)
	-- 	for index,suitInfo in ipairs(suitInfos) do
	-- 		table.insert(descTbl , index , {forceText = "" , normalText = suitInfo.set_desc, isActive = suitCount > index })
	-- 	end
	-- elseif gemstoneQuality == APTITUDE.SS then	--只化神的SS魂骨
	-- 	local gemstoneInfo_ss = db:getGemstoneEvolutionBygodLevel(gemstone.itemId, GEMSTONE_MAXADVANCED_LEVEL)
	-- 	if gemstoneInfo_ss and gemstoneInfo_ss.gem_evolution_new_set then
	-- 		local suitInfos = db:getGemstoneSuitEffectBySuitId(gemstoneInfo_ss.gem_evolution_new_set)
	-- 		for index,suitInfo in ipairs(suitInfos) do
	-- 			table.insert(descTbl , index , {forceText = "【SS】" , normalText = suitInfo.set_desc, isActive = suitCount > index })
	-- 		end
	-- 	end
	-- elseif gemstoneQuality == APTITUDE.SSR then	-- SS+魂骨
	-- 	mixConfig = remote.gemstone:getGemstoneMixConfigByIdAndLv(gemstone.itemId, 1)
	-- 	if mixConfig and mixConfig.gem_suit then
	-- 		for index=1,3 do
	-- 			local suitConfig = remote.gemstone:getGemstoneMixSuitConfigByData(mixConfig.gem_suit, index + 1,1)
	-- 			if suitConfig then
	-- 				table.insert(descTbl , index , {forceText = "【SS+】" , normalText = suitConfig.set_desc , isActive = suitCount > index })
	-- 			else
	-- 				table.insert(descTbl , index , {forceText = "【SS+】" , normalText = ""})
	-- 			end
	-- 		end
	-- 	end
	-- 	-- local haveSuitNum = #descTbl
	-- 	-- if suitOtherCount > suitCount then
	-- 	-- 	local gemstoneInfo_ss = db:getGemstoneEvolutionBygodLevel(gemstone.itemId, GEMSTONE_MAXADVANCED_LEVEL)
	-- 	-- 	if gemstoneInfo_ss and gemstoneInfo_ss.gem_evolution_new_set then
	-- 	-- 		local suitInfos = db:getGemstoneSuitEffectBySuitId(gemstoneInfo_ss.gem_evolution_new_set)
	-- 	-- 		for index,suitInfo in ipairs(suitInfos) do
	-- 	-- 			if index <= suitOtherCount and index > suitCount then
	-- 	-- 				descTbl[index] =  {forceText = "【SS】" , normalText = suitInfo.set_desc , isActive = suitOtherCount > index  }

	-- 	-- 				-- table.insert(descTbl , index , {forceText = "【SS】" , normalText = suitInfo.set_desc , isActive = suitOtherCount > index  })
	-- 	-- 			end
	-- 	-- 		end
	-- 	-- 	end
	-- 	-- end
	-- end

	for i=1,3 do
		self._ccbOwner["node_suit_desc_"..i]:setVisible(false)
		self._ccbOwner["node_other_suit_desc_"..i]:setVisible(false)
	end


	for i,v in ipairs(descTbl) do
		local descNode = self._ccbOwner["node_suit_desc_"..i]
		if descNode then
			descNode:setVisible(true)
			if self._colorfulTextTbl[i] == nil then
			    self._colorfulTextTbl[i] = QRichText.new(nil, 400, {})
			    self._colorfulTextTbl[i]:setAnchorPoint(0, 1)
			    descNode:addChild(self._colorfulTextTbl[i])
			end
			if not v.isActive then
				self._colorfulTextTbl[i]:setString({
			            	{oType = "font", content = v.forceText or "" , size = 20 ,color = GAME_COLOR_LIGHT.notactive},
			            	{oType = "font", content = v.normalText or "" , size = 20 ,color = GAME_COLOR_LIGHT.notactive},
				    	})
			else
				self._colorfulTextTbl[i]:setString({
			            	{oType = "font", content = v.forceText or "" , size = 20 , color = ccc3(87,47,0)},
			            	{oType = "font", content = v.normalText or "" , size = 20 , color = ccc3(131, 88, 50)},
				    	})
			end
		end
	end

	-- for i,v in ipairs(descOtherTbl) do
	-- 	local descNode = self._ccbOwner["node_other_suit_desc_"..i]
	-- 	if descNode then
	-- 		descNode:setVisible(true)
	-- 		if self._colorfulOtherTextTbl[i] == nil then
	-- 		    self._colorfulOtherTextTbl[i] = QRichText.new(nil, 400, {})
	-- 		    self._colorfulOtherTextTbl[i]:setAnchorPoint(0, 1)
	-- 		    descNode:addChild(self._colorfulOtherTextTbl[i])
	-- 		end
	-- 		if suitOtherCount < i then
	-- 			self._colorfulOtherTextTbl[i]:setString({
	-- 		            	{oType = "font", content = v.forceText or "" , size = 20,color = GAME_COLOR_LIGHT.notactive},
	-- 		            	{oType = "font", content = v.normalText or "" , size = 20,color = GAME_COLOR_LIGHT.notactive},
	-- 			    	})
	-- 		else
	-- 			self._colorfulOtherTextTbl[i]:setString({
	-- 		             	{oType = "font", content = v.forceText or "" , size = 20,color = ccc3(87,47,0)},
	-- 		            	{oType = "font", content = v.normalText or "" , size = 20,color = ccc3(131, 88, 50)},
	-- 			    	})
	-- 		end
	-- 	end
	-- end


	--文字适配方案
	local height_y = 0
	local heightContent = 0
	for i = 1,3 do

		local suitNode = self._ccbOwner["node_suit_"..i]
		if suitNode then
			suitNode:setPositionY( height_y - 42 )
		end

		local height = 0
		local descNode = self._ccbOwner["node_suit_desc_"..i]

		if self._colorfulTextTbl[i] then
			descNode:setPositionY(12)
			local heightS = self._colorfulTextTbl[i]:getCascadeBoundingBox().size.height
			height = heightS + height
			heightContent = heightContent + heightS
		end

		-- descNode = self._ccbOwner["node_other_suit_desc_"..i]
		-- if descNode:isVisible() and self._colorfulOtherTextTbl[i] then
		-- 	descNode:setPositionY(- height + 12)
		-- 	height = self._colorfulOtherTextTbl[i]:getCascadeBoundingBox().size.height + height
		-- 	heightContent = heightContent + self._colorfulOtherTextTbl[i]:getCascadeBoundingBox().size.height
		-- end
		height_y = height_y - height - 6
	end
	heightContent = heightContent + 40
	self._ccbOwner.lg_left4:setContentSize(240, heightContent)
	self._ccbOwner.lg_right4:setContentSize(240, heightContent)
	height_y = height_y - 85

	--融合套装技能
	local height_y_Ssp = 0
	if gemstoneQuality ==  APTITUDE.SSR and mixConfig then
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

		self._ccbOwner.sp_graL_ssp1:setVisible(false)
		self._ccbOwner.sp_graR_ssp1:setVisible(false)
		self._ccbOwner.sp_graL_ssp2:setVisible(false)
		self._ccbOwner.sp_graR_ssp2:setVisible(false)
	    local suitSkill = remote.gemstone:getGemstoneMixSuitConfigByData(mixConfig.gem_suit, 2 ,showLevel)
	    if suitSkill then
	    	local skillIdTbl = string.split(suitSkill.suit_skill , ";")
	    	if not q.isEmpty(skillIdTbl) then
	    		local skillId = skillIdTbl[1]
	    		local skillConfig = db:getSkillByID(skillId)
			
				self._ccbOwner.node_suitskill_desc_1:removeAllChildren()
		        local describe = skillConfig.description
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
			    self._ccbOwner.sp_graL_ssp1:setContentSize(CCSize(240, tfHeight))
			    self._ccbOwner.sp_graR_ssp1:setContentSize(CCSize(240, tfHeight))
				self._ccbOwner.sp_graL_ssp1:setVisible(true)
				self._ccbOwner.sp_graR_ssp1:setVisible(true)
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
				self._ccbOwner.sp_graL_ssp2:setContentSize(CCSize(240, tfHeight+ 30 ))
			    self._ccbOwner.sp_graR_ssp2:setContentSize(CCSize(240, tfHeight + 30))    
			    self._ccbOwner.sp_graL_ssp2:setVisible(true)
				self._ccbOwner.sp_graR_ssp2:setVisible(true)
	    	end
	    else
	    	self._ccbOwner.node_suit_skill_2:setVisible(false)
	    end
		self._ccbOwner.node_ssp_skill_suit:setVisible(true)
		self._ccbOwner.node_ssp_skill_suit:setPositionY( 220 + height_y)
	 	height_y = height_y - height - 20
	 else
		self._ccbOwner.node_ssp_skill_suit:setVisible(false)

	end

   --化神套装与属性

	local god_skills = 0
    if advancedLevel >= GEMSTONE_MAXADVANCED_LEVEL and gemstoneQuality >= APTITUDE.S  then

    	local mark_low_god_level = 99
		local gemstoneInfo_ss = db:getGemstoneEvolutionBygodLevel(gemstone.itemId,GEMSTONE_MAXADVANCED_LEVEL)
		local gemstoneSuits_ss = remote.gemstone:getSuitByItemId(gemstoneInfo_ss.gem_evolution_new_id)
		table.sort(gemstoneSuits_ss, function (gemstoneConfig1, gemstoneConfig2)
				return gemstoneConfig1.gemstone_type <gemstoneConfig2.gemstone_type
			end)	
    	for index,gemstoneConfig in ipairs(gemstoneSuits_ss) do
			if index > 4 then
				break
			end
			if self._god_gemstoneBoxs[index] == nil then
		        self._god_gemstoneBoxs[index] = QUIWidgetGemstonesBox.new()
		        self._ccbOwner["node_godsuit"..index]:addChild(self._god_gemstoneBoxs[index])
		        self._god_gemstoneBoxs[index]:setState(remote.gemstone.GEMSTONE_ICON)
	        	self._god_gemstoneBoxs[index]:setIconScale(0.86)
				self._god_gemstoneBoxs[index]:addEventListener(QUIWidgetGemstonesBox.EVENT_CLICK, handler(self, self.godGemstoneBoxClickHandler))
				self._god_gemstoneBoxs[index]:setQuality(gemstoneQuality,GEMSTONE_MAXADVANCED_LEVEL)
				local nameNode = self._god_gemstoneBoxs[index]:getName()
        		nameNode:setPositionY(nameNode:getPositionY() + 20)
			end

		self._god_gemstoneBoxs[index]:setItemId(gemstoneConfig.id)



	        local name = gemstoneConfig.name
	        name = string.gsub(name, "SS", "")
	        self._god_gemstoneBoxs[index]:setNameVisible(true)
	        self._god_gemstoneBoxs[index]:setName("神·"..name,true)


	        if gemstoneSuitTbl[index] and gemstoneSuitTbl[index].isSsGem and gemstoneSuitTbl[index].beyondGodLv > 0 then
        		self._god_gemstoneBoxs[index]:setGray(false)
        		mark_low_god_level = math.min(mark_low_god_level , gemstoneSuitTbl[index].beyondGodLv)
				self._god_gemstoneBoxs[index]:setGodLevel(GEMSTONE_MAXADVANCED_LEVEL + gemstoneSuitTbl[index].beyondGodLv )
	        	self._god_gemstoneBoxs[index]:setNameColor(GAME_COLOR_LIGHT.normal)
				self._god_gemstoneBoxs[index]:setStateQualityVisible(true)
	        else
        		self._god_gemstoneBoxs[index]:setNameColor(GAME_COLOR_LIGHT.notactive)
				self._god_gemstoneBoxs[index]:setGodLevel(GEMSTONE_MAXADVANCED_LEVEL + 1 )
        		self._god_gemstoneBoxs[index]:setGray(true)
				self._god_gemstoneBoxs[index]:setStateQualityVisible(false)
        		mark_low_god_level = 0
	        end
		end

		local god_suitskill_id = 0

		for i= 1,5 do
			local gemstoneInfo_ss = db:getGemstoneEvolutionBygodLevel(gemstone.itemId,GEMSTONE_MAXADVANCED_LEVEL + i)
			if gemstoneInfo_ss.gem_god_skill ~= god_suitskill_id then
				god_suitskill_id = gemstoneInfo_ss.gem_god_skill
				local skillInfo = db:getSkillByID(god_suitskill_id)
				if skillInfo then
					god_skills = god_skills + 1
					self._ccbOwner["tf_godsuit_skill"..god_skills]:setString("【神"..i.."效果】"..skillInfo.description)
					if mark_low_god_level >= i then
        				self._ccbOwner["tf_godsuit_skill"..god_skills]:setColor(GAME_COLOR_LIGHT.normal)
					else
        				self._ccbOwner["tf_godsuit_skill"..god_skills]:setColor(GAME_COLOR_LIGHT.notactive)
					end
				end
			end
		end
		for i= 1,5 do
			self._ccbOwner["tf_godsuit_skill"..i]:setVisible(i <= god_skills )
		end
    end

    self:changeScrollViewSize(advancedLevel,itemConfig.gemstone_quality,god_skills,height_y )
	self._scrollContain:resetPos()


	for i = 1,2 do
		self._ccbOwner["tf_suit_advanced"..i]:setString("")
	end
	for i = 1,2 do
		self._ccbOwner["tf_suit_god"..i]:setString("")
	end

	local goldLevel = gemstone.godLevel or remote.gemstone.GEMSTONE_GODLEVLE_TEST
	advancedLevel = goldLevel
    if goldLevel > GEMSTONE_MAXADVANCED_LEVEL then
    	advancedLevel = GEMSTONE_MAXADVANCED_LEVEL
    	--显示化神属性
		-- local godInfos = db:getGemstoneEvolutionBygodLevel(gemstone.itemId,goldLevel)

	    local godPropVlue = remote.gemstone:getAllAdvancedProp(gemstone.itemId,GEMSTONE_MAXADVANCED_LEVEL+1,goldLevel)

		if next(godPropVlue) ~= nil then
			self:setAdvancedProp(self._ccbOwner.tf_suit_god1, godPropVlue.attack_value, "攻    击：＋%d")
			self:setAdvancedProp(self._ccbOwner.tf_suit_god1, godPropVlue.hp_value, "生    命：＋%d")
			self:setAdvancedProp(self._ccbOwner.tf_suit_god1, godPropVlue.armor_physical, "物    防：＋%d")
			self:setAdvancedProp(self._ccbOwner.tf_suit_god1, godPropVlue.armor_magic, "法    防：＋%d")	
		end

    end

    local advancedPropVlue = remote.gemstone:getAllAdvancedProp(gemstone.itemId,1,advancedLevel)

    --显示进阶属性
	-- local advanceInfos = db:getGemstoneEvolutionBygodLevel(gemstone.itemId,advancedLevel)
	if next(advancedPropVlue) ~= nil then
		self:setAdvancedProp(self._ccbOwner.tf_suit_advanced1, advancedPropVlue.attack_value, "攻    击：＋%d")
		self:setAdvancedProp(self._ccbOwner.tf_suit_advanced1, advancedPropVlue.hp_value, "生    命：＋%d")
		self:setAdvancedProp(self._ccbOwner.tf_suit_advanced1, advancedPropVlue.armor_physical, "物    防：＋%d")
		self:setAdvancedProp(self._ccbOwner.tf_suit_advanced1, advancedPropVlue.armor_magic, "法    防：＋%d")
	end

	local advancedSkillId, godSkillId = db:getGemstoneEvolutionSkillIdBygodLevel(gemstone.itemId,goldLevel)

	self._ccbOwner.node_suit_advanced:removeAllChildren()
	if advancedSkillId then
		local skillInfo = db:getSkillByID(advancedSkillId)
		-- self._ccbOwner.tf_suit_advanced2:setString(skillInfo.name.."："..skillInfo.description)	
		local text = QColorLabel:create("##e"..skillInfo.name.."：##n"..skillInfo.description or "", 500, nil, nil, 22, GAME_COLOR_LIGHT.normal)
		text:setAnchorPoint(ccp(0, 1))
		self._ccbOwner.node_suit_advanced:addChild(text)

		self:getSkillPropDesc(advancedSkillId,true)
    
	end

	self._ccbOwner.node_suit_god:removeAllChildren()
	if godSkillId then
		local skillInfo = db:getSkillByID(godSkillId)
		-- self._ccbOwner.tf_suit_god2:setString(skillInfo.name.."："..skillInfo.description)		
		local text = QColorLabel:create("##e"..skillInfo.name.."：##n"..skillInfo.description or "", 500, nil, nil, 22, GAME_COLOR_LIGHT.normal)
		text:setAnchorPoint(ccp(0, 1))
		self._ccbOwner.node_suit_god:addChild(text)		
		
		self:getSkillPropDesc(godSkillId,false)
	end

	local mixConfig = remote.gemstone:getGemstoneMixConfigByIdAndLv(gemstone.itemId, gemstone.mix_level or 0)
	if mixConfig then
		local propDesc =remote.gemstone:setPropInfo(mixConfig ,true,true,true)
		for i,v in ipairs(propDesc) do
			self:setPropSkillDesc(v.name.."：＋"..v.value)
		end
	end

end

function QUIWidgetHeroGemstoneDetail:getSkillPropDesc(skill, isAdvance)

	local skillData = db:getSkillDataByIdAndLevel(skill,1)
	local prop_type = skillData["addition_type_1"]
	local prop_value = skillData["addition_value_1"]

	local desc_ = "化神"
	if isAdvance then
		desc_ = "进阶"
	end

	if prop_type== nil then
		desc_ = desc_..":+%.1f%%"

	elseif prop_type == "hp_percent" then
		desc_ = desc_.."生命：＋%.1f%%"

	elseif prop_type == "attack_percent" then
		desc_ = desc_.."攻击：＋%.1f%%"

	elseif prop_type == "armor_physical_percent" then
		desc_ = desc_.."物防：＋%.1f%%"

	elseif prop_type == "armor_magic_percent" then
		desc_ = desc_.."法防：＋%.1f%%"
	else
		desc_ = desc_..":+%.1f%%"
	end

	self:setProp(prop_value ,desc_,true)

	return desc_
end


function QUIWidgetHeroGemstoneDetail:setProp(prop,value,ispercent)
	if self._index > 6 then return end
	if prop ~= nil and prop > 0 then
		if ispercent == true then
			prop = prop * 100
		end
		self._ccbOwner["tf_prop"..self._index]:setString(string.format(value, prop))
		self._ccbOwner["tf_prop"..self._index]:setVisible(true)
		self._index = self._index + 1
	end
end
--把进阶和化神的技能效果添加到前面显示
function QUIWidgetHeroGemstoneDetail:setPropSkillDesc(_Str)
	if self._index > 6 then return end
	self._ccbOwner["tf_prop"..self._index]:setString(_Str)
	self._ccbOwner["tf_prop"..self._index]:setVisible(true)
	self._index = self._index + 1
end

function QUIWidgetHeroGemstoneDetail:setAdvancedProp(node,prop,value,ispercent)
	if node == nil then return end
	if prop ~= nil and prop > 0 then
		if ispercent == true then
			prop = prop * 100
		end
		node:setString(string.format(value, prop))
	end
end

function QUIWidgetHeroGemstoneDetail:_onTriggerWear(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_wear) == false then return end
	if self._callback and self._callback() then return end
	
	if e ~= nil then
		app.sound:playSound("common_small")
	end
	local UIHeroModel = remote.herosUtil:getUIHeroByID(self._actorId)
	local gemstoneInfo = UIHeroModel:getGemstoneInfoByPos(self._gemstonePos)
	local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(gemstoneInfo.info.itemId)
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGemstoneFastBag", 
        options = {canType = gemstoneInfo.canType, actorId = self._actorId, pos = self._gemstonePos, selfType = itemConfig.gemstone_type, quality = itemConfig.gemstone_quality}})
end

function QUIWidgetHeroGemstoneDetail:gemstoneBoxClickHandler(e)
	if self._callback and self._callback() then return end

	if e ~= nil then
		app.sound:playSound("common_small")
	end
	if self._scrollContain:getMoveState() then return end

	local itemConfig = db:getItemByID(e.itemID)

	if itemConfig and self._gemstoneQuality == APTITUDE.S then
		QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, e.itemID,nil,nil,false,nil)
	else
		local itemCraft = db:getItemCraftByItemId(e.itemID)
		if itemCraft then
			QQuickWay:addQuickWay(QQuickWay.SYNTHETIC_DROP_WAY, e.itemID,nil,nil,false,nil)
		else
			QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, e.itemID,nil,nil,false,nil)
		end
	end
end

function QUIWidgetHeroGemstoneDetail:godGemstoneBoxClickHandler(e)
	if self._callback and self._callback() then return end
	
	if e ~= nil then
		app.sound:playSound("common_small")
	end
	if self._scrollContain:getMoveState() then return end
	QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, e.itemID,nil,nil,false,nil)
end
function QUIWidgetHeroGemstoneDetail:_onTriggerUnwear(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_unwear) == false then return end
	if self._callback and self._callback() then return end

	if e ~= nil then
		app.sound:playSound("common_small")
	end
    remote.gemstone:gemstoneLoadRequest(self._gemstoneSid, 2, nil, nil, function (data)
        -- app.tip:floatTip("卸载魂骨成功！") 
    	remote.gemstone:dispatchEvent({name = remote.gemstone.EVENT_UNWEAR, sid = self._gemstoneSid})
    end)
end

function QUIWidgetHeroGemstoneDetail:_onTriggerHelp(e)
	
	if q.buttonEventShadow(e, self._ccbOwner.btn_help) == false then return end
	if self._callback and self._callback() then return end
	

	if e ~= nil then
		app.sound:playSound("common_small")
	end
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroGemstoneSuitInfo", options = {_gemstoneSid = self._gemstoneSid}})
   
end

function QUIWidgetHeroGemstoneDetail:_onTriggerHelpPartOne(e)
    app.sound:playSound("common_menu")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGemstoneSkillInfo", 
        options={gemstone = self._gemstone , gemAdvancedType = remote.gemstone.GEMSTONE_MIX_SUIT_SKILL 
        , activateMixLevel = self._mix2SuitLevel or 0 , suitNum = 2 }}, {isPopCurrentDialog = false})
end

function QUIWidgetHeroGemstoneDetail:_onTriggerHelpPartTwo(e)
   app.sound:playSound("common_menu")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGemstoneSkillInfo", 
        options={gemstone = self._gemstone , gemAdvancedType = remote.gemstone.GEMSTONE_MIX_SUIT_SKILL 
        , activateMixLevel = self._mix4SuitLevel or 0 , suitNum = 4 }}, {isPopCurrentDialog = false})
end


return QUIWidgetHeroGemstoneDetail