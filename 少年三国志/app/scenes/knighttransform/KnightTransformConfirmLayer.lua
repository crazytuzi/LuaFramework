
local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")
local KnightTransformConfirmLayer = class("KnightTransformConfirmLayer", UFCCSModelLayer)

function KnightTransformConfirmLayer.create(nSourceKnightId, nTargetKnightBaseId, ...)
	return KnightTransformConfirmLayer.new("ui_layout/KnightTransform_ConfirmLayer.json", Colors.modelColor, nSourceKnightId, nTargetKnightBaseId, ...)
end

function KnightTransformConfirmLayer:ctor(json, param, nSourceKnightId, nTargetKnightBaseId, ...)
	self.super.ctor(self, json, param, ...)

	self._nSourceKnightId = nSourceKnightId
	self._nTargetKnightBaseId = nTargetKnightBaseId

	self:_initWidgets()
end

function KnightTransformConfirmLayer:onLayerEnter()
	self:showAtCenter(true)
	self:closeAtReturn(true)

	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_Bg"), "smoving_bounce")
end

function KnightTransformConfirmLayer:onLayerExit()
	
end

function KnightTransformConfirmLayer:_initWidgets()
	-- 源武将头像，名字
	local tSourceKnight = G_Me.bagData.knightsData:getKnightByKnightId(self._nSourceKnightId)
	if not tSourceKnight then
		return
	end

	local nBaseId = tSourceKnight["base_id"]
	local tSourceKnightTmpl = knight_info.get(nBaseId)
	if not tSourceKnightTmpl then
		return
	end
	local nResId = tSourceKnightTmpl.res_id

	CommonFunc._updateImageView(self, "ImageView_hero_head1", {texture=G_Path.getKnightIcon(nResId), texType=UI_TEX_TYPE_LOCAL})
	CommonFunc._updateImageView(self, "ImageView_pingji1", {texture=G_Path.getAddtionKnightColorImage(tSourceKnightTmpl.quality), texType=UI_TEX_TYPE_PLIST})
	CommonFunc._updateLabel(self, "Label_KnightName1", {text=tSourceKnightTmpl.name, stroke=Colors.strokeBrown, color=Colors.qualityColors[tSourceKnightTmpl.quality]})

	-- 目标武将头像，名字
	local nBaseId = self._nTargetKnightBaseId
	local tTargetKnightTmpl = knight_info.get(nBaseId)
	if not tTargetKnightTmpl then
		return
	end
	local nResId = tTargetKnightTmpl.res_id

	CommonFunc._updateImageView(self, "ImageView_hero_head2", {texture=G_Path.getKnightIcon(nResId), texType=UI_TEX_TYPE_LOCAL})
	CommonFunc._updateImageView(self, "ImageView_pingji2", {texture=G_Path.getAddtionKnightColorImage(tTargetKnightTmpl.quality), texType=UI_TEX_TYPE_PLIST})
	CommonFunc._updateLabel(self, "Label_KnightName2", {text=tTargetKnightTmpl.name, stroke=Colors.strokeBrown, color=Colors.qualityColors[tTargetKnightTmpl.quality]})

	-- 确认进行此次变身吗？
	CommonFunc._updateLabel(self, "Label_Sure", {text=G_lang:get("LANG_KNIGHT_TRANSFORM_SURE_TO_TRANSFORM")})

	-- 花费
	local nCost, nJingHua = G_GlobalFunc.getKnightTransformCost(self._nSourceKnightId, self._nTargetKnightBaseId)
	local nJiangHunCost = nCost
	CommonFunc._updateLabel(self, "Label_CostDesc", {text=G_lang:get("LANG_KNIGHT_TRANSFORM_CUR_COST")})
	CommonFunc._updateLabel(self, "Label_GoldNum", {text=nCost, stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_Cost_JiangHun", {text=nJiangHunCost, stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_Cost_JingHua", {text=nJingHua, stroke=Colors.strokeBrown})

	self:_alignCost(nJingHua)


	self:registerBtnClickEvent("Button_Close", handler(self, self._onCloseWindow))
	self:registerBtnClickEvent("Button_Confirm", handler(self, self._onConfirm))
	self:registerBtnClickEvent("Button_Cancel", handler(self, self._onCloseWindow))
end

function KnightTransformConfirmLayer:_alignCost(nJingHua)
	nJingHua = nJingHua or 0
	if nJingHua > 0 then
		local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
	        self:getLabelByName('Label_CostDesc'),
	        self:getImageViewByName('Image_Gold'),
	        self:getLabelByName('Label_GoldNum'),
	        self:getLabelByName('Label_Space'),
	        self:getImageViewByName('Image_JiangHun'),
	        self:getLabelByName('Label_Cost_JiangHun'),
	        self:getLabelByName('Label_Space_1'),
	        self:getImageViewByName('Image_JingHua'),
	        self:getLabelByName('Label_Cost_JingHua'),
	    }, "C")
	    self:getLabelByName('Label_CostDesc'):setPositionXY(alignFunc(1))
	    self:getImageViewByName('Image_Gold'):setPositionXY(alignFunc(2))
	    self:getLabelByName('Label_GoldNum'):setPositionXY(alignFunc(3))
	    self:getLabelByName('Label_Space'):setPositionXY(alignFunc(4))
	    self:getImageViewByName('Image_JiangHun'):setPositionXY(alignFunc(5))
	    self:getLabelByName('Label_Cost_JiangHun'):setPositionXY(alignFunc(6))
	    self:getLabelByName('Label_Space_1'):setPositionXY(alignFunc(7))
	    self:getImageViewByName('Image_JingHua'):setPositionXY(alignFunc(8))
	    self:getLabelByName('Label_Cost_JingHua'):setPositionXY(alignFunc(9))

	    self:showWidgetByName('Label_Space_1', true)
	    self:showWidgetByName('Image_JingHua', true)
	    self:showWidgetByName('Label_Cost_JingHua', true)
	else
		local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
	        self:getLabelByName('Label_CostDesc'),
	        self:getImageViewByName('Image_Gold'),
	        self:getLabelByName('Label_GoldNum'),
	        self:getLabelByName('Label_Space'),
	        self:getImageViewByName('Image_JiangHun'),
	        self:getLabelByName('Label_Cost_JiangHun'),
	    }, "C")
	    self:getLabelByName('Label_CostDesc'):setPositionXY(alignFunc(1))
	    self:getImageViewByName('Image_Gold'):setPositionXY(alignFunc(2))
	    self:getLabelByName('Label_GoldNum'):setPositionXY(alignFunc(3))
	    self:getLabelByName('Label_Space'):setPositionXY(alignFunc(4))
	    self:getImageViewByName('Image_JiangHun'):setPositionXY(alignFunc(5))
	    self:getLabelByName('Label_Cost_JiangHun'):setPositionXY(alignFunc(6))

	    self:showWidgetByName('Label_Space_1', false)
	    self:showWidgetByName('Image_JingHua', false)
	    self:showWidgetByName('Label_Cost_JingHua', false)
	end
end

function KnightTransformConfirmLayer:_onCloseWindow()
	self:animationToClose()
end

function KnightTransformConfirmLayer:_onConfirm()
	-- 判断钱钱够不够
	local nCost, nJingHua = G_GlobalFunc.getKnightTransformCost(self._nSourceKnightId, self._nTargetKnightBaseId)
	if G_Me.userData.gold >= nCost then
		local nKinghtId = self._nSourceKnightId
		local tTargetKnightTmpl = knight_info.get(self._nTargetKnightBaseId)
		assert(tTargetKnightTmpl)
		local nAdvancedCode = tTargetKnightTmpl.advance_code
		G_HandlersManager.knightTransformHandler:sendKnightTransform(nKinghtId, nAdvancedCode)

		--[[
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_KNIGHT_TRANSFORM_TRANSFORM_SUCC, nil, false, nil)
		]]
	else
		require("app.scenes.shop.GoldNotEnoughDialog").show()
	end
	self:animationToClose()
end

return KnightTransformConfirmLayer