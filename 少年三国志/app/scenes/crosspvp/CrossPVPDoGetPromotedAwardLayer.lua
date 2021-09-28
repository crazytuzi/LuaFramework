
require("app.cfg.crosspvp_rank_award_info")
local CrossPVPConst = require("app.const.CrossPVPConst")

local CrossPVPDoGetPromotedAwardLayer = class("CrossPVPDoGetPromotedAwardLayer", UFCCSModelLayer)

function CrossPVPDoGetPromotedAwardLayer.show()
	local layer = CrossPVPDoGetPromotedAwardLayer.new("ui_layout/crosspvp_DoGetPromotedAwardLayer.json", Colors.modelColor)
	layer:adapterWithScreen()
	uf_sceneManager:getCurScene():addChild(layer)
end

function CrossPVPDoGetPromotedAwardLayer:ctor(json, param)
	self._isPromoted = G_Me.crossPVPData:isApplied()

	self._nField = G_Me.crossPVPData:getBattlefield()

	-- 上一轮
    local nCourse = G_Me.crossPVPData:getCourse()
	if nCourse == CrossPVPConst.COURSE_PROMOTE_1024 then
		nCourse = CrossPVPConst.COURSE_PROMOTE_256
	end
	self._nPrevCourse = nCourse - 1

	self.super.ctor(self, json, param)
end

function CrossPVPDoGetPromotedAwardLayer:onLayerLoad()
	self:_initWidgets()
end

function CrossPVPDoGetPromotedAwardLayer:onLayerEnter()
	self:showAtCenter(true)
	self:closeAtReturn(true)
    self:setClickClose(true)

    -- 状态切换后，关掉自己
    uf_eventManager:addEventListener(CrossPVPConst.EVENT_STAGE_CHANGED, self.animationToClose, self)
    -- 领取奖励成功
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_PVP_GET_PROMOTED_AWARD_SUCC, self._onGetAwardSucc, self)

    require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_Bg"), "smoving_bounce")

    self:_initAwards()
end

function CrossPVPDoGetPromotedAwardLayer:onLayerExit()
	
end

function CrossPVPDoGetPromotedAwardLayer:_initWidgets()
	-- title
	local titleImg = G_Path.getTxt(self._isPromoted and "jinjijiangli.png" or "canyujiangli.png")
	self:getImageViewByName("Image_Title"):loadTexture(titleImg)

	-- desc
	local tScheduleTmpl = crosspvp_schedule_info.get(self._nPrevCourse - 1)
	if not tScheduleTmpl then
		return
	end

	local labelTips = self:getLabelByName("Label_Desc")
	if labelTips then
		if self._nPrevCourse == CrossPVPConst.COURSE_FINAL then
			local text = G_lang:get("LANG_CROSS_PVP_GONGXI_FINAL_AWARD", {num = G_Me.crossPVPData:getFieldRank()})
			labelTips:setText(text)
		else
			local lang = self._isPromoted and "LANG_CROSS_PVP_GONGXI_GET_AWARD" or "LANG_CROSS_PVP_ELIMINATED_AWARD"
			labelTips:setText(G_lang:get(lang, {name=tScheduleTmpl.name}))
		end
	end

	self:registerBtnClickEvent("Button_Get", function()
		G_HandlersManager.crossPVPHandler:sendCrossPvpGetAward()
	end)
end

function CrossPVPDoGetPromotedAwardLayer:_initAwards()
	local awardType = self._isPromoted and 1 or 2
	local awardInfo = nil
	for i=1, crosspvp_rank_award_info.getLength() do
		local tTmpl = crosspvp_rank_award_info.indexOf(i)
		if tTmpl and tTmpl.award_type == awardType and tTmpl.type == self._nField and tTmpl.scene == self._nPrevCourse then
			-- 如果是决赛，还要根据名次取一下奖励
			if self._nPrevCourse == CrossPVPConst.COURSE_FINAL then
				if G_Me.crossPVPData:getFieldRank() == tTmpl.rank_num then
					awardInfo = tTmpl
					break
				end
			else
				awardInfo = tTmpl
				break
			end
		end
	end

	assert(awardInfo)

	for i=1, 4 do
		local imgBg = self:getImageViewByName(string.format("Image_Award_Bg%d", i))

		local nType = awardInfo["award_type_"..i]
		local nValue = awardInfo["award_value_"..i]
		if not (nType == 0 and nValue == 0) then
			local tGoods = G_Goods.convert(nType, nValue)
			imgBg:setVisible(true)
			self:getImageViewByName("Image_Icon" .. i):loadTexture(tGoods.icon)
			self:getImageViewByName("Image_ColorBg"..i):loadTexture(G_Path.getEquipIconBack(tGoods.quality))
			self:getImageViewByName("Image_QualityFrame" .. i):loadTexture(G_Path.getEquipColorImage(tGoods.quality, tGoods.type), UI_TEX_TYPE_PLIST)

			local numLabel = self:getLabelByName("Label_Count" .. i)
			numLabel:setText("x" .. G_GlobalFunc.ConvertNumToCharacter3(awardInfo["award_size_" .. i]))
			numLabel:createStroke(Colors.strokeBrown, 1)

			self:registerWidgetClickEvent(string.format("Image_Award_Bg%d", i), function()
				require("app.scenes.common.dropinfo.DropInfo").show(nType, nValue) 
			end)
		else
			imgBg:setVisible(false)
		end
	end
end

function CrossPVPDoGetPromotedAwardLayer:_onGetAwardSucc(data)
	local tGoodsPopWindowsLayer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(data.awards)
    uf_notifyLayer:getModelNode():addChild(tGoodsPopWindowsLayer)

	self:animationToClose()
end

return CrossPVPDoGetPromotedAwardLayer