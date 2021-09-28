local HeroSoulConst = require("app.const.HeroSoulConst")
local EffectNode = require("app.common.effects.EffectNode")

local HeroSoulTerraceSuccLayer = class("HeroSoulTerraceSuccLayer", UFCCSModelLayer)


function HeroSoulTerraceSuccLayer.create(tAwardList, tQiyuValueList, nMoney, ...)
	return HeroSoulTerraceSuccLayer.new("ui_layout/herosoul_TerraceSuccLayer.json", Colors.modelColor, tAwardList, tQiyuValueList, nMoney, ...)
end

function HeroSoulTerraceSuccLayer:ctor(json, param, tAwardList, tQiyuValueList, nMoney, ...)
	self:adapterWithScreen()

	self._tAwardList = tAwardList
	self._tQiyuValueList = tQiyuValueList
	self._nMoney = nMoney

	self._nExtractType = #self._tAwardList == 1 and HeroSoulConst.EXTRACT_TYPE.ONCE or HeroSoulConst.EXTRACT_TYPE.FIVE

	self.super.ctor(self, json, param, ...)
end

function HeroSoulTerraceSuccLayer:onLayerLoad()
	self:_initView()
	self:_initWidgets()
	self:_initBtns()
end

function HeroSoulTerraceSuccLayer:onLayerEnter()
	self:closeAtReturn(true)
	self:showAtCenter(true)

	self._tOffset = ccp(-50, -105)
	self._tStartPos = self:getPanelByName("Panel_Start1"):getPositionInCCPoint()
	self._tStartPos.x = self._tStartPos.x + self._tOffset.x
	self._tStartPos.y = self._tStartPos.y + self._tOffset.y
	self._tEndPosList = {}

	if self._nExtractType == HeroSoulConst.EXTRACT_TYPE.ONCE then
		local endPos = self:getPanelByName("Panel_End_Once"):getPositionInCCPoint()
		endPos.x = endPos.x + self._tOffset.x
		endPos.y = endPos.y + self._tOffset.y
		table.insert(self._tEndPosList, #self._tEndPosList + 1, endPos)
	else
		for i=1, 5 do
			local endPos = self:getPanelByName("Panel_End"..i):getPositionInCCPoint()
			endPos.x = endPos.x + self._tOffset.x
			endPos.y = endPos.y + self._tOffset.y
			table.insert(self._tEndPosList, #self._tEndPosList + 1, endPos)
		end
	end

	self:_startShowing()
end

function HeroSoulTerraceSuccLayer:onLayerExit()
	
end

function HeroSoulTerraceSuccLayer:onLayerUnload()
	
end

function HeroSoulTerraceSuccLayer:_initView()
	self:showWidgetByName("Panel_Btn", false)
end

function HeroSoulTerraceSuccLayer:_initWidgets()
	G_GlobalFunc.updateLabel(self, "Label_Desc", {text=G_lang:get("LANG_HERO_SOUL_GET_MONEY", {num=self._nMoney}), stroke=Colors.strokeBrown})

	-- 点将
	self:registerBtnClickEvent("Button_Once", function()
		local nFreeTimes = G_Me.heroSoulData:getFreeExtractCount()
		if nFreeTimes > 0 then
			G_HandlersManager.heroSoulHandler:sendSummonKsoul(HeroSoulConst.SUMMOM_TYPE.FREE)
			self:close()
		else
			-- 判断钱够不够
			if self:_isGoldEnough(HeroSoulConst.EXTRACT_TYPE.ONCE) then
				G_HandlersManager.heroSoulHandler:sendSummonKsoul(HeroSoulConst.SUMMOM_TYPE.ONCE)
				self:close()
			end
		end
	end)
	-- 点将5次
	self:registerBtnClickEvent("Button_Five", function()
		-- 判断钱够不够
		if self:_isGoldEnough(HeroSoulConst.EXTRACT_TYPE.FIVE) then
			G_HandlersManager.heroSoulHandler:sendSummonKsoul(HeroSoulConst.SUMMOM_TYPE.FIVE)
			self:close()
		end
	end)
	self:registerBtnClickEvent("Button_Close", function()
		self:_onCloseWindow()
	end)
end

function HeroSoulTerraceSuccLayer:_isGoldEnough(nType)
	local isEnough = false
	if nType == HeroSoulConst.EXTRACT_TYPE.ONCE then
		isEnough = G_Me.userData.gold >= HeroSoulConst.ONCE_COST
	elseif nType == HeroSoulConst.EXTRACT_TYPE.FIVE then
		isEnough = G_Me.userData.gold >= HeroSoulConst.FIVE_COST
	end

	if not isEnough then
		require("app.scenes.shop.GoldNotEnoughDialog").show()
	end
	return isEnough
end

function HeroSoulTerraceSuccLayer:_startShowing()
	for i=1, #self._tAwardList do
		self:awardAppear(i)
	end
end

function HeroSoulTerraceSuccLayer:_showContinueBtn()
	local nOffsetY = 100
	self:getImageViewByName("Image_Continue"):setOpacity(0)

	local function blink()
        local actSeq = CCSequence:createWithTwoActions(CCFadeIn:create(0.5), CCFadeOut:create(0.5))
        local actFor = CCRepeatForever:create(actSeq)
        self:getImageViewByName("Image_Continue"):runAction(actFor)
    end

	local panelBtn = self:getPanelByName("Panel_Btn")
	if panelBtn then
		panelBtn:setVisible(true)
		local nPosX = panelBtn:getPositionX()
		local nPosY = panelBtn:getPositionY()
		panelBtn:setPositionY(nPosY - nOffsetY)

		local actMoveTo = CCMoveTo:create(0.08, ccp(nPosX, nPosY))
		local actCallback = CCCallFunc:create(blink)
		panelBtn:runAction(CCSequence:createWithTwoActions(actMoveTo, actCallback))
	end
end

function HeroSoulTerraceSuccLayer:_initBtns()
	self:showWidgetByName("Button_Once", self._nExtractType == HeroSoulConst.EXTRACT_TYPE.ONCE)
	self:showWidgetByName("Button_Five", self._nExtractType == HeroSoulConst.EXTRACT_TYPE.FIVE)


	G_GlobalFunc.updateLabel(self, "Label_Free", {visible=false})
	G_GlobalFunc.updateLabel(self, "Label_GoldCostValue1", {text=HeroSoulConst.ONCE_COST, stroke=Colors.strokeBrown, visible=true})
	G_GlobalFunc.updateImageView(self, "Image_GoldCost1", {visible=true})
	local alignFunc = G_GlobalFunc.autoAlign(ccp(0, 0), {
        self:getImageViewByName("Image_GoldCost1"),
        self:getLabelByName("Label_GoldCostValue1"),
    }, "C")
	self:getImageViewByName("Image_GoldCost1"):setPositionXY(alignFunc(1))
    self:getLabelByName("Label_GoldCostValue1"):setPositionXY(alignFunc(2))
	

	G_GlobalFunc.updateLabel(self, "Label_GoldCostValue2", {text=HeroSoulConst.FIVE_COST, stroke=Colors.strokeBrown})
	local alignFunc = G_GlobalFunc.autoAlign(ccp(0, 0), {
        self:getImageViewByName("Image_GoldCost2"),
        self:getLabelByName("Label_GoldCostValue2"),
    }, "C")
	self:getImageViewByName("Image_GoldCost2"):setPositionXY(alignFunc(1))
    self:getLabelByName("Label_GoldCostValue2"):setPositionXY(alignFunc(2))
end

function HeroSoulTerraceSuccLayer:awardAppear(index)
	if not self._itemList then
		self._itemList = {}
	end

    local time = 0.5
    local delayTime = (index-1)*0.3
    local item = nil
   
   	local tAward = self._tAwardList[index]
    item = GlobalFunc.createIcon({type=tAward.type,value=tAward.value,size=tAward.size,click=true, labelsize=true})
    item:setAnchorPoint(ccp(0.5, 0.5))

    local labelTmpl = item:getLabelByName("Label_NameAutoSize")
    local fontSize = labelTmpl:getFontSize()

    local nQiyuValue = self._tQiyuValueList[index] or 0
    local label = G_GlobalFunc.createGameLabel(G_lang:get("LANG_HERO_SOUL_QIYU_VALUE_ADD", {num=nQiyuValue}), fontSize, Colors.darkColors.ATTRIBUTE, Colors.strokeBrown)
    --labelTmpl:addChild(label)
    --label:setPositionY(-30)
    labelTmpl:setVisible(false)
    local labelParent = labelTmpl:getParent()
    labelParent:addChild(label)
    local x, y = labelTmpl:getPosition()
    label:setPositionXY(x,y-30)
    label:setVisible(false)

    self._itemList[index] = item
    local startpos = self._tStartPos
    local endpos = self._tEndPosList[index]

    item:setPosition(startpos)
    item:setVisible(false)
    item:setScale(1)
    local move = CCMoveTo:create(time,endpos)
    local scale = CCScaleTo:create(time,1)
    self:getPanelByName("Panel_Five"):addChild(item)
    local delayAction = CCDelayTime:create(delayTime)
    local arr = CCArray:create()
    arr:addObject(delayAction)
    arr:addObject(CCCallFunc:create(function()
        self._itemList[index]:setVisible(true)
        self._itemList[index]:getImageViewByName("Image_board"):runAction(CCRotateTo:create(time,3600))
    end))
    arr:addObject(CCSpawn:createWithTwoActions(move,scale))

    arr:addObject(CCCallFunc:create(function()
        local effect = EffectNode.new("effect_lp_jl", 
                function(event, frameIndex)
                    if event == "finish" then
                        if index == #self._tAwardList then
                        	self:_showContinueBtn()
                        end
                        if effect then
                        	effect:removeFromParentAndCleanup(true)
                        	effect = nil
                        end
                    end
                end)
        effect:setPosition(ccp(62,96))
        effect:play()
        self._itemList[index]:addNode(effect)

        labelTmpl:setVisible(true)
        label:setVisible(true)
    end))
    item:runAction(CCSequence:create(arr))
end

function HeroSoulTerraceSuccLayer:_onCloseWindow()
	self:close()
end

return HeroSoulTerraceSuccLayer