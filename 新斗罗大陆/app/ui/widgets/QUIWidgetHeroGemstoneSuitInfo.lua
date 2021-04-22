



local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroGemstoneSuitInfo = class("QUIWidgetHeroGemstoneSuitInfo", QUIWidget)
local QUIWidgetGemstonesBox = import("..widgets.QUIWidgetGemstonesBox")
local QQuickWay = import("...utils.QQuickWay")
local QColorLabel = import("...utils.QColorLabel")
local QRichText = import("...utils.QRichText")

function QUIWidgetHeroGemstoneSuitInfo:ctor(options)
    local ccbFile = "ccb/Widget_Baoshi_SuitInfo.ccbi"
    local callBacks = {}
    QUIWidgetHeroGemstoneSuitInfo.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
    self._gemstoneBoxs = {}
	self._colorfulTextTbl = {}

    self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetHeroGemstoneSuitInfo:setInfo(info)

	local itemId = info.itemId
	local gemstoneQuality = info.gemstoneQuality
	local curGemstoneQuality = info.curGemstoneQuality

	local gemstoneSuits = remote.gemstone:getSuitByItemId(itemId)
	local itemConfig = db:getItemByID(itemId)

	local qualityType = ""


	self._totalHeight = 220

	local descTbl = {}

	if gemstoneQuality <= APTITUDE.S then	--普通的a与s级魂骨
		qualityType = ""
		local suitInfos = db:getGemstoneSuitEffectBySuitId(itemConfig.gemstone_set_index)
		for index,suitInfo in ipairs(suitInfos) do
			table.insert(descTbl , index , {forceText = "" , normalText = suitInfo.set_desc })
		end
	elseif gemstoneQuality == APTITUDE.SS then	--只化神的SS魂骨
		qualityType = "SS"
		local gemstoneInfo_ss = db:getGemstoneEvolutionBygodLevel(itemId, GEMSTONE_MAXADVANCED_LEVEL)
		if gemstoneInfo_ss and gemstoneInfo_ss.gem_evolution_new_set then
			local suitInfos = db:getGemstoneSuitEffectBySuitId(gemstoneInfo_ss.gem_evolution_new_set)
			for index,suitInfo in ipairs(suitInfos) do
				table.insert(descTbl , index , {forceText = "【SS】" , normalText = suitInfo.set_desc })
			end
		end
	elseif gemstoneQuality == APTITUDE.SSR then	-- SS+魂骨
		qualityType = "SS+"
		local mixConfig = remote.gemstone:getGemstoneMixConfigByIdAndLv(itemId, 1)
		if mixConfig and mixConfig.gem_suit then
			for index=1,3 do
				local suitConfig = remote.gemstone:getGemstoneMixSuitConfigByData(mixConfig.gem_suit, index + 1,1)
				if suitConfig then
					table.insert(descTbl , index , {forceText = "【SS+】" , normalText = suitConfig.set_desc  })
				else
					table.insert(descTbl , index , {forceText = "【SS+】" , normalText = ""})
				end
			end
		end
	end



	self._ccbOwner.title_1:setString(qualityType.."魂骨套装预览")
	self._ccbOwner.title_2:setString(qualityType.."套装属性预览")



   --魂骨套装与属性
	local suitCount = 0

	table.sort(gemstoneSuits, function (gemstoneConfig1, gemstoneConfig2)
		return gemstoneConfig1.gemstone_type <gemstoneConfig2.gemstone_type
	end)	
  
	
	for index,gemstoneConfig in ipairs(gemstoneSuits) do
		if index > 4 then
			break
		end
		if self._gemstoneBoxs[index] == nil then
			self._gemstoneBoxs[index] = QUIWidgetGemstonesBox.new()
			self._ccbOwner["node_ss_suit"..index]:addChild(self._gemstoneBoxs[index])
        	self._gemstoneBoxs[index]:setState(remote.gemstone.GEMSTONE_ICON)
        	self._gemstoneBoxs[index]:addEventListener(QUIWidgetGemstonesBox.EVENT_CLICK, handler(self, self.godGemstoneBoxClickHandler))
			local nameNode = self._gemstoneBoxs[index]:getName()
			nameNode:setPositionY(nameNode:getPositionY() + 20)
			self._gemstoneBoxs[index]:setIconScale(0.86)
        	self._gemstoneBoxs[index]:setNameVisible(true)
        	
			self._gemstoneBoxs[index]:setNameColor(GAME_COLOR_LIGHT.normal)
			self._gemstoneBoxs[index]:setGray(false)

		end


		local name = gemstoneConfig.name
		local frontName = q.SubStringUTF8(name,1,2)
		local backName = q.SubStringUTF8(name,3)
	

		self._gemstoneBoxs[index]:setName(qualityType..frontName.."\n"..backName)
		self._gemstoneBoxs[index]:setItemIdByData(gemstoneConfig.id , 0 , 1)

		if gemstoneQuality == APTITUDE.SSR then	-- SS+魂骨
			self._gemstoneBoxs[index]:setName(qualityType..frontName.."\n"..backName)
			self._gemstoneBoxs[index]:setItemIdByData(gemstoneConfig.id , 0 , 5)
		elseif gemstoneQuality == APTITUDE.SS then
			self._gemstoneBoxs[index]:setItemIdByData(gemstoneConfig.id , GEMSTONE_MAXADVANCED_LEVEL , 0)
		else
			self._gemstoneBoxs[index]:setItemIdByData(gemstoneConfig.id , 0 , 0)
		end
		-- if curGemstoneQuality >= gemstoneQuality then
		-- 	self._gemstoneBoxs[index]:setNameColor(GAME_COLOR_LIGHT.normal)
		-- 	self._gemstoneBoxs[index]:setGray(false)
		-- else
		-- 	self._gemstoneBoxs[index]:setNameColor(GAME_COLOR_LIGHT.notactive)
		-- 	self._gemstoneBoxs[index]:setGray(false)
		-- end

	end



	for i=1,3 do
		self._ccbOwner["node_suit_desc_"..i]:setVisible(false)
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
			self._colorfulTextTbl[i]:setString({
							{oType = "font", content = v.forceText,size = 20,color = ccc3(87,47,0)},
			            	{oType = "font", content = v.normalText, size = 20,color = ccc3(131, 88, 50)},
				    	})

			-- if curGemstoneQuality >= gemstoneQuality then
			-- 	self._colorfulTextTbl[i]:setString({
			-- 				{oType = "font", content = v.forceText,size = 20,color = ccc3(87,47,0)},
			--             	{oType = "font", content = v.normalText, size = 20,color = ccc3(131, 88, 50)},
			-- 	    	})
			-- else
			-- 	self._colorfulTextTbl[i]:setString({
			-- 				{oType = "font", content = v.forceText,size = 20,color = GAME_COLOR_LIGHT.notactive},
			--             	{oType = "font", content = v.normalText, size = 20,color = GAME_COLOR_LIGHT.notactive},
			-- 	    	})
			-- end
		end
	end

	--文字适配方案
	local height_y = 0
	local heightContent = 0
	for i = 1,3 do

		local suitNode = self._ccbOwner["node_suit_"..i]
		if suitNode then
			suitNode:setPositionY( height_y - 27 )
		end

		local height = 0
		local descNode = self._ccbOwner["node_suit_desc_"..i]

		if self._colorfulTextTbl[i] then
			descNode:setPositionY(12)
			height = self._colorfulTextTbl[i]:getCascadeBoundingBox().size.height + height
			heightContent = heightContent + self._colorfulTextTbl[i]:getCascadeBoundingBox().size.height
		end
		height_y = height_y - height - 6
	end

	self._totalHeight = self._totalHeight + heightContent + 10


end

function QUIWidgetHeroGemstoneSuitInfo:getContentSize()
    return CCSize(554, self._totalHeight)
end


function QUIWidgetHeroGemstoneSuitInfo:godGemstoneBoxClickHandler(e)
	if e ~= nil then
		app.sound:playSound("common_small")
	end
	QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, e.itemID)
end

return QUIWidgetHeroGemstoneSuitInfo
