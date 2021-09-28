--LegionSacrificeBoxLayer.lua


local LegionSacrificeBoxLayer = class("LegionSacrificeBoxLayer", UFCCSModelLayer)


function LegionSacrificeBoxLayer.show( ... )
	local layer = LegionSacrificeBoxLayer.new("ui_layout/legion_LegionSacrificeBox.json", Colors.modelColor, ...)
	uf_sceneManager:getCurScene():addChild(layer)
end

function LegionSacrificeBoxLayer:ctor( ... )
	local winSize = CCDirector:sharedDirector():getWinSize()
	self._startPt = ccp(winSize.width/2, winSize.height/2)
	self.super.ctor(self, ...)

	self:enableLabelStroke("bounsnum_1", Colors.strokeBrown, 1 )
	self:enableLabelStroke("bounsname_1", Colors.strokeBrown, 1 )

	self:attachImageTextForBtn("getbounsbtn", "ImageView_Light")
end

function LegionSacrificeBoxLayer:onLayerLoad( _, _, awardLevel, awardIndex, startPt )
	self._startPt = startPt or self._startPt
	self:registerBtnClickEvent("closebtn", handler(self, self._onCancelClick))

	local corpsAwardInfo = corps_info.get(awardLevel)
	local awardType = 0
	local awardId = 0
	local awardCount = 0
	if corpsAwardInfo then 
		awardType = corpsAwardInfo["item_type_"..awardIndex]
		awardId = corpsAwardInfo["item_id_"..awardIndex]
		awardCount = corpsAwardInfo["item_size_"..awardIndex]

		local goodInfo = G_Goods.convert(awardType, awardId, awardCount)
		if goodInfo then 
			self:showTextWithLabel("bounsname_1", goodInfo.name)
		end

		self:showTextWithLabel("bounsnum_1", "x"..awardCount)
		
		local img = self:getImageViewByName("ico_1")
		if img then 
			img:loadTexture(goodInfo.icon, UI_TEX_TYPE_LOCAL)
		end

		img = self:getImageViewByName("bouns1")
		if img then 
			img:loadTexture(G_Path.getEquipColorImage(goodInfo.quality, goodInfo.type, goodInfo.value))
		end
	end

	GlobalFunc.replaceForAppVersion(self:getImageViewByName("Image_Girl"))

	self:showWidgetByName("ImageView_CopperBox", awardIndex == 1)
	self:showWidgetByName("ImageView_SilverBox", awardIndex == 2)
	self:showWidgetByName("ImageView_GoldBox", awardIndex == 3)
	self:showWidgetByName("ImageView_SuperBox", awardIndex == 4)

	self:showWidgetByName("ImageView_bouns2", false)
	self:showWidgetByName("ImageView_bouns3", false)
	self:showWidgetByName("ImageView_bouns4", false)

	local sacrificeData = G_Me.legionData:getWorshipData()
	local corpsAwardInfo = corps_info.get(awardLevel)
	if not corpsAwardInfo or not sacrificeData then 
		self:showWidgetByName("getbounsbtn", false)
		return 
	end


	local awardBoxFlags = {}
	for key, value in pairs(sacrificeData.worship_award) do
		if type(value) == "number"  then 
			awardBoxFlags[value] = true
		end
	end

	local curWorshipPoints = sacrificeData and sacrificeData.worship_point or 0
	self:showWidgetByName("ImageView_AleadyGet", awardBoxFlags[awardIndex])
	self:showWidgetByName("getbounsbtn", not awardBoxFlags[awardIndex])

	self:showTextWithLabel("Label_Desc", G_lang:get("LANG_LEGION_SACRIFICE_ACQUIRE_AWARD_BOX_TITLE", {expValue=corpsAwardInfo["worship_value_"..awardIndex]}))

	self:enableWidgetByName("getbounsbtn", corpsAwardInfo["worship_value_"..awardIndex] <= curWorshipPoints)
	
	self:registerWidgetClickEvent("getbounsbtn", function ( ... )
		if corpsAwardInfo["worship_value_"..awardIndex] > curWorshipPoints then 
			return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_SACRIFICE_ACQUIRE_AWARD_BOX_TIP", {expValue=corpsAwardInfo["worship_value_"..awardIndex]}))
		end

		if awardBoxFlags[awardIndex] then 
			return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_SACRIFICE_HAVE_ACQUIRE_AWARD_BOX"))
		end

		self:_onCancelClick()
		return G_HandlersManager.legionHandler:sendGetCorpContributeAward(awardIndex)
	end)
	--self:showWidgetByName("getbounsbtn", not awardBoxFlags[awardIndex] and (corpsAwardInfo["worship_value_"..awardIndex] <= curWorshipPoints))
end

function LegionSacrificeBoxLayer:onLayerEnter( ... )
	self:showAnimation(true)
	self:closeAtReturn(true)
end

function LegionSacrificeBoxLayer:_onCancelClick( ... )
	self:showAnimation(false)
end

function LegionSacrificeBoxLayer:onBackKeyEvent( ... )
	self:showAnimation(false)
	return true
end

function LegionSacrificeBoxLayer:showAnimation( show )
    show = show or false
    local startScale = 1
    local endScale = 1
    local startPos = ccp(0,0)
    local endPos = ccp(0,0)
    local _size = self:getContentSize()
    if show then
        startScale = 0.2
        endScale = 1
        startPos = self._startPt
        endPos = ccp(_size.width/2,_size.height/2)
    else
        startScale = 1
        endScale = 0.2
        startPos = ccp(_size.width/2,_size.height/2)
        endPos = self._startPt
    end
    local img = self:getImageViewByName("ImageView_762")
    img:setScale(startScale)
    img:setPosition(startPos)
    local array = CCArray:create()
    array:addObject(CCMoveTo:create(0.2,endPos))
    array:addObject(CCScaleTo:create(0.2,endScale))
    local sequence = transition.sequence({CCSpawn:create(array),
    CCCallFunc:create(
        function()
            if not show then
                self:close() 
            end
        end),
})
    img:runAction(sequence)
end

return LegionSacrificeBoxLayer

