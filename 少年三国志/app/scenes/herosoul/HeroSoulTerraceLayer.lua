local EffectNode = require("app.common.effects.EffectNode")
local HeroSoulConst = require("app.const.HeroSoulConst")
local CrossWarCommon = require("app.scenes.crosswar.CrossWarCommon")

local HeroSoulTerraceLayer = class("HeroSoulTerraceLayer", UFCCSNormalLayer)


HeroSoulTerraceLayer.TOTAL_SCHEDULE = 200

function HeroSoulTerraceLayer.create(...)
	return HeroSoulTerraceLayer.new("ui_layout/herosoul_TerraceLayer.json", nil, ...)
end

function HeroSoulTerraceLayer:ctor(json, param, ...)
	
	self._barEffect = nil
	self._tClaimButtonEffect = nil
	self._tRichText = nil

	self._tIconList = {}
	self._isOnAction = false
	self._tTimer = nil
	self._nCurIndex = 0
	
	self._tShowIdList = {}  -- 镜子上显示的将灵的id
	self._nCurSoulId = 0	-- 当前镜子上显示的将灵的id
	self._nMaxSoulId = 0    -- ksoul_info表里，最大的将灵的id

	self._tMirrorEffect = nil
	self._tReadyEffect = nil 

	self._nPreQiyuValue = G_Me.userData.qiyu_point
	self._bShowQiyuWithAct = false
	self._tNumberChanger = nil

	self._tShieldLayer = nil

	-- if tostring(G_PlatformProxy:getLoginServer().id) == "3" then
	-- 	self:showWidgetByName("Button_Test500", true)
	-- else
	-- 	self:showWidgetByName("Button_Test500", false)
	-- end
 
	self.super.ctor(self, json, param, ...)

	self._tShieldLayer = self:getPanelByName("Panel_Shield")
end

function HeroSoulTerraceLayer:onLayerLoad()
	self:_initView()
	self:_initWidgets()
	self:_updateQiyuValue()
	self:_setCost()
	self:_onUpdateSendDesc()
	self:_updateChartTips()
end

function HeroSoulTerraceLayer:onLayerEnter()
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_HERO_SOUL_EXTRACT_SUCC, self._onTerraceSucc, self)

	self:_showReadyEffect(true)
end

function HeroSoulTerraceLayer:onLayerExit()
	self:_clearNumberChanger()

	uf_eventManager:removeListenerWithTarget(self)
end

function HeroSoulTerraceLayer:_initView()
	G_GlobalFunc.updateLabel(self, "Label_Qiyu", {stroke=Colors.strokeBrown})
	G_GlobalFunc.updateLabel(self, "Label_Qiyu_Value", {stroke=Colors.strokeBrown})
	G_GlobalFunc.updateLabel(self, "Label_Chart", {stroke=Colors.strokeBrown})
	G_GlobalFunc.updateLabel(self, "Label_Chart_Value", {stroke=Colors.strokeBrown, text=G_Me.heroSoulData:getActivatedChartsNum()})
	G_GlobalFunc.updateLabel(self, "Label_BuySilver", {stroke=Colors.strokeBrown})
end

function HeroSoulTerraceLayer:_initWidgets()
	-- 背包
	self:registerBtnClickEvent("Button_Bag", function()
		uf_sceneManager:getCurScene():goToLayer("HeroSoulBagLayer", true)
	end)
	-- 返回
	self:registerBtnClickEvent("Button_Back", function()
		uf_sceneManager:getCurScene():goBack()
	end)
	-- 点将
	self:registerBtnClickEvent("Button_Once", function()
		local nFreeTimes = G_Me.heroSoulData:getFreeExtractCount()
		if nFreeTimes > 0 then
			G_HandlersManager.heroSoulHandler:sendSummonKsoul(HeroSoulConst.SUMMOM_TYPE.FREE)
		else
			-- 判断钱够不够
			if self:_isGoldEnough(HeroSoulConst.EXTRACT_TYPE.ONCE) then
				G_HandlersManager.heroSoulHandler:sendSummonKsoul(HeroSoulConst.SUMMOM_TYPE.ONCE)
			end
		end
	end)
	-- 点将5次
	self:registerBtnClickEvent("Button_Five", function()
		-- 判断钱够不够
		if self:_isGoldEnough(HeroSoulConst.EXTRACT_TYPE.FIVE) then
			G_HandlersManager.heroSoulHandler:sendSummonKsoul(HeroSoulConst.SUMMOM_TYPE.FIVE)
		end
	end)
	-- 打开积分商店
	self:registerBtnClickEvent("Button_QiyuShop", function()
		uf_sceneManager:pushScene(require("app.scenes.shop.score.ShopScoreScene").new(SCORE_TYPE.HERO_SOUL,nil,nil,nil,
              GlobalFunc.sceneToPack("app.scenes.herosoul.HeroSoulScene", {nil, nil, nil, require("app.const.HeroSoulConst").TERRACE})))
	end)
	-- 点将预览
	self:registerBtnClickEvent("Button_Review", function()
		local tLayer = require("app.scenes.herosoul.HeroSoulReviewLayer").create()
		if tLayer then
			uf_sceneManager:getCurScene():addChild(tLayer)
		end
	end)
	-- 去阵图
	self:registerBtnClickEvent("Button_Chart", function()
		uf_sceneManager:getCurScene():goToLayer("HeroSoulChartLayer", true)
	end)

	-- if tostring(G_PlatformProxy:getLoginServer().id) == "3" then
	-- 	self:registerBtnClickEvent("Button_Test500", function()
	-- 		if not self._test500Layer then
	-- 			self._test500Layer = require("app.scenes.herosoul.Test500Layer").create(1, function()
	-- 				self._test500Layer:close()
	-- 				self._test500Layer = nil
	-- 			end)
	-- 			uf_sceneManager:getCurScene():addChild(self._test500Layer)
	-- 		end
	-- 	end)
	-- end
end

function HeroSoulTerraceLayer:_setCost()
	local nFreeTimes = G_Me.heroSoulData:getFreeExtractCount()
	if nFreeTimes > 0 then
		G_GlobalFunc.updateLabel(self, "Label_Free", {stroke=Colors.strokeBrown, visible=true})
		G_GlobalFunc.updateLabel(self, "Label_GoldCostValue1", {visible=false})
		G_GlobalFunc.updateImageView(self, "Image_GoldCost1", {visible=false})
	else
		G_GlobalFunc.updateLabel(self, "Label_Free", {visible=false})
		G_GlobalFunc.updateLabel(self, "Label_GoldCostValue1", {text=HeroSoulConst.ONCE_COST, stroke=Colors.strokeBrown, visible=true})
		G_GlobalFunc.updateImageView(self, "Image_GoldCost1", {visible=true})

		local alignFunc = G_GlobalFunc.autoAlign(ccp(0, 0), {
            self:getImageViewByName("Image_GoldCost1"),
            self:getLabelByName("Label_GoldCostValue1"),
        }, "C")
    	self:getImageViewByName("Image_GoldCost1"):setPositionXY(alignFunc(1))
        self:getLabelByName("Label_GoldCostValue1"):setPositionXY(alignFunc(2))
	end

	G_GlobalFunc.updateLabel(self, "Label_GoldCostValue2", {text=HeroSoulConst.FIVE_COST, stroke=Colors.strokeBrown})
	local alignFunc = G_GlobalFunc.autoAlign(ccp(0, 0), {
        self:getImageViewByName("Image_GoldCost2"),
        self:getLabelByName("Label_GoldCostValue2"),
    }, "C")
	self:getImageViewByName("Image_GoldCost2"):setPositionXY(alignFunc(1))
    self:getLabelByName("Label_GoldCostValue2"):setPositionXY(alignFunc(2))
end

function HeroSoulTerraceLayer:_isGoldEnough(nType)
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

function HeroSoulTerraceLayer:_updateQiyuValue()
	local NumberScaleChanger = require("app.scenes.common.NumberScaleChanger")
	if not self._bShowQiyuWithAct then
		G_GlobalFunc.updateLabel(self, "Label_Qiyu_Value", {text=G_Me.userData.qiyu_point})
	else
		self._bShowQiyuWithAct = false

		self:_clearNumberChanger()
		if not self._tNumberChanger then
			local label = self:getLabelByName("Label_Qiyu_Value")
			self._tNumberChanger = NumberScaleChanger.new(label, self._nPreQiyuValue, G_Me.userData.qiyu_point, function()
				G_GlobalFunc.updateLabel(self, "Label_Qiyu_Value", {text=G_Me.userData.qiyu_point})
			end)
		end
	end
end

-- 再购买X次，必赠送橙色将灵
function HeroSoulTerraceLayer:_onUpdateSendDesc()
	if not self._tRichText then
		self._tRichText = G_GlobalFunc.createRichTextSingleRow(self:getLabelByName("Label_SendDesc"))
	end
	local szContent = ""
	local nCircleCount = 5-G_Me.heroSoulData:getCircleExtractCount()
	if nCircleCount ~= 1 then
		szContent = G_lang:get("LANG_HERO_SOUL_SEND_DESC", {num=nCircleCount})
	else
		szContent = G_lang:get("LANG_HERO_SOUL_SURE_SEND_DESC")
	end
	
	self._tRichText:clearRichElement()
	self._tRichText:appendContent(szContent, ccc3(255, 255, 255))
	self._tRichText:reloadData()
end

-- 占将成功
function HeroSoulTerraceLayer:_onTerraceSucc(tData)
	-- if tostring(G_PlatformProxy:getLoginServer().id) == "3" then
	-- 	return
	-- end

	local tAwardList = {}
	local tQiyuValueList = {}
	local nMoney = 0 -- 银两
	for i, v in ipairs(tData.awards) do
		local tAward = v 
		if tAward.type ~= 1 then  -- 不是银两
			table.insert(tAwardList, #tAwardList + 1, tAward)
		else
			nMoney = tAward.size
		end
	end

	for i, v in ipairs(tData.scores) do
		local tAward = v
		local nQiyuValue = tAward.size
		table.insert(tQiyuValueList, #tQiyuValueList + 1, nQiyuValue)
	end

	local function openSuccLayer()
		local tLayer = require("app.scenes.herosoul.HeroSoulTerraceSuccLayer").create(tAwardList, tQiyuValueList, nMoney)
		if tLayer then
			uf_sceneManager:getCurScene():addChild(tLayer)
		end
	end

	self._bShowQiyuWithAct = true
	self:_setCost()
	self:_updateQiyuValue()
	self:_onUpdateSendDesc()
	self:_updateChartTips()

	self:_openShieldLayer()
	self:_palyExtractEffect(openSuccLayer)
	self:_showReadyEffect(false)
end

-- 
function HeroSoulTerraceLayer:_addSoulToMirror()
	local HeroSoulIconItem = require("app.scenes.herosoul.HeroSoulIconItem")

	local tOffset = ccp(-50, -105)
	local nScale = 0.8
	for i=1, 3 do
		local panel = self:getPanelByName("Panel_Pos"..i)
  		local tIcon = HeroSoulIconItem.new(1, true, false)
  		tIcon:setScale(nScale)
  		table.insert(self._tIconList, #self._tIconList + 1, tIcon)
  		panel:addChild(tIcon)

    	self:getPanelByName("Panel_Pos"..i):setVisible(false)
	end
end

function HeroSoulTerraceLayer:_collectShowSoulIds()
	for i=1, ksoul_summon_info.getLength() do
		local tTmpl = ksoul_summon_info.indexOf(i)
		if tTmpl and tTmpl.ksoul_type == 1 then
			table.insert(self._tShowIdList, #self._tShowIdList, tTmpl.ksoul_id)
		end
	end

	for i=1, ksoul_info.getLength() do
		local tTmpl = ksoul_info.indexOf(i)
		if tTmpl then
			self._nMaxSoulId = math.max(self._nMaxSoulId, tTmpl.id)
		end
	end
end

-- 将灵id列表中是否包含了传入的id值
function HeroSoulTerraceLayer:_isContained(nId)
	for i=1, #self._tShowIdList do
		local nSoulId = self._tShowIdList[i]
		if nSoulId == nId then
			return true
		end
	end
	return false
end

-- 
function HeroSoulTerraceLayer:blickAction(nIndex, nSoulId)
	if type(nIndex) ~= "number" then
		return
	end
	if nIndex <= 0 or nIndex >3 then
		assert(false, "error nIndex value = %d", nIndex)
	end
	if self._isOnAction then
		return
	end

	self._isOnAction = true
	self._nCurIndex = nIndex
	self._nCurSoulId = nSoulId

	for i=1, 3 do
		self:getPanelByName("Panel_Pos"..i):setVisible(self._nCurIndex == i)
	end

	local tIcon = self._tIconList[nIndex]
	-- 更新icon
	self:_updateIcon(tIcon, nSoulId)

	tIcon:setCascadeOpacityEnabled(true)
	tIcon:setOpacity(0)
	tIcon:stopAllActions()

	local actDelay = CCDelayTime:create(0.1)
	local actFadeIn  = CCFadeIn:create(2)
	local actFadeOut = CCFadeOut:create(2)
	local actCallback = CCCallFunc:create(function()
		self._isOnAction = false
	end)

	local tArray = CCArray:create()
	tArray:addObject(actDelay)
	tArray:addObject(actFadeIn)
	tArray:addObject(actFadeOut)
	tArray:addObject(actCallback)
	local actSeq = CCSequence:create(tArray)
	tIcon:runAction(actSeq)
end


function HeroSoulTerraceLayer:_updateIcon(tIcon, nSoulId)
	tIcon:update(nSoulId, true, false)
end

function HeroSoulTerraceLayer:_palyExtractEffect(fnCallback)
	if not self._tMirrorEffect then
		self._tMirrorEffect = EffectNode.new("effect_dianjiang_hit", function(event, frameIndex)
			if event == "finish" then
				if fnCallback then
					fnCallback()
				end
				self._tMirrorEffect:removeFromParentAndCleanup(true)
				self._tMirrorEffect = nil

				self:_closeShieldLayer()
				self:_showReadyEffect(true)
			end
		end)
		local tParent = self:getPanelByName("Panel_Effect_Panel_Hit")
		if tParent then
			tParent:addNode(self._tMirrorEffect)
			self._tMirrorEffect:play()
		end
	end
end

function HeroSoulTerraceLayer:_clearNumberChanger()
	if self._tNumberChanger then
		self._tNumberChanger:stop()
		self._tNumberChanger = nil
	end
end

function HeroSoulTerraceLayer:_openShieldLayer()
	self._tShieldLayer:setVisible(true)
end

function HeroSoulTerraceLayer:_closeShieldLayer()
	self._tShieldLayer:setVisible(false)
end

function HeroSoulTerraceLayer:_showReadyEffect(isShow)
	isShow = isShow or false
	local tParent = self:getPanelByName("Panel_Effect_Panel_Ready")
	
	if isShow then
		if not self._tReadyEffect then
			self._tReadyEffect = EffectNode.new("effect_dianjiang_ready")
			self._tReadyEffect:play()
			tParent:addNode(self._tReadyEffect)
		end
		tParent:setVisible(true)
	else
		if self._tReadyEffect then
			tParent:setVisible(false)
		end
	end
end

-- 若有将灵可以激活阵图，直接跳入到阵图界面
function HeroSoulTerraceLayer:_updateChartTips()
	self:showWidgetByName("Image_ChartTips", G_Me.heroSoulData:hasChartToActivate())
end

return HeroSoulTerraceLayer