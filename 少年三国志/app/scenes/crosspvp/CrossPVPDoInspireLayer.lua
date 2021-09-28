local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")
local CrossPVPConst = require("app.const.CrossPVPConst")
local FlyText = require("app.scenes.common.FlyText")
local CrossPVPCommon = require("app.scenes.crosspvp.CrossPVPCommon")

local CrossPVPDoInspireLayer = class("CrossPVPDoInspireLayer", UFCCSModelLayer)


function CrossPVPDoInspireLayer.create(...)
	return CrossPVPDoInspireLayer.new("ui_layout/crosspvp_DoInspireLayer.json", Colors.modelColor, ...)
end

function CrossPVPDoInspireLayer:ctor(json, param, ...)
	self.super.ctor(self, json, param, ...)

	self:_initWidgets()
end

function CrossPVPDoInspireLayer:onLayerEnter()
	self:showAtCenter(true)
	self:closeAtReturn(true)
    self:setClickClose(true)

    -- 状态切换后，关掉自己
    uf_eventManager:addEventListener(CrossPVPConst.EVENT_STAGE_CHANGED, self._onCloseSelf, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_PVP_INSPIRE_SUCC, self._onInspireSucc, self)

	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("ImageView_BkgPanel"), "smoving_bounce")
end

function CrossPVPDoInspireLayer:onLayerExit()
	uf_eventManager:removeListenerWithTarget(self)
end

function CrossPVPDoInspireLayer:_initWidgets( ... )
	-- 伤害加成
	local tBuffTmplAdd = crosspvp_buff_info.get(1)
	-- 伤害减免
	local tBuffTmplReduce = crosspvp_buff_info.get(2)

	local tPassiveSkillTmpl1 = passive_skill_info.get(tBuffTmplAdd.buff_id)
	local tPassiveSkillTmpl2 = passive_skill_info.get(tBuffTmplReduce.buff_id)
	assert(tPassiveSkillTmpl1)
	assert(tPassiveSkillTmpl2)
    
    local nAddCount = G_Me.crossPVPData:getNumInspireAtk()
    local nReduceCount = G_Me.crossPVPData:getNumInspireDef()
    local nHarmAdd = nAddCount * tPassiveSkillTmpl1.affect_value / 10
    local nHarmReduce = nReduceCount * tPassiveSkillTmpl2.affect_value / 10
    CommonFunc._updateLabel(self, "Label_HarmAdd_Value", {text=G_lang:get("LANG_CROSS_PVP_ONCE_INSPIRE_ATTR_CHANGE", {num=nHarmAdd})})
    CommonFunc._updateLabel(self, "Label_HarmReduce_Value", {text=G_lang:get("LANG_CROSS_PVP_ONCE_INSPIRE_ATTR_CHANGE", {num=nHarmReduce})})
    CommonFunc._updateLabel(self, "Label_AddTime_Value", {text=nAddCount.."/"..tBuffTmplAdd.buff_num})
    CommonFunc._updateLabel(self, "Label_ReduceTime_Value", {text=nReduceCount.."/"..tBuffTmplReduce.buff_num})

    -- 鼓舞单价
	CommonFunc._updateLabel(self, "Label_GoldNum_Add", {text=CrossPVPCommon.getInspireCost(tBuffTmplAdd.price, nAddCount), stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_GoldNum_Reduce", {text=CrossPVPCommon.getInspireCost(tBuffTmplReduce.price, nReduceCount), stroke=Colors.strokeBrown})

    local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
        self:getImageViewByName('Image_Gold_Add'),
        self:getLabelByName('Label_GoldNum_Add'),
    }, "C")
    self:getImageViewByName('Image_Gold_Add'):setPositionXY(alignFunc(1))
    self:getLabelByName('Label_GoldNum_Add'):setPositionXY(alignFunc(2))

    local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
        self:getImageViewByName('Image_Gold_Reduce'),
        self:getLabelByName('Label_GoldNum_Reduce'),
    }, "C")
    self:getImageViewByName('Image_Gold_Reduce'):setPositionXY(alignFunc(1))
    self:getLabelByName('Label_GoldNum_Reduce'):setPositionXY(alignFunc(2))

	self:registerBtnClickEvent("Button_InspireAdd", function()
		self:_doInspire(CrossPVPConst.INSPIRE_TYPE.HARM_ADD)
	end)
	self:registerBtnClickEvent("Button_InspireReduce", function()
		self:_doInspire(CrossPVPConst.INSPIRE_TYPE.HARM_REDUCE)
	end)
end

function CrossPVPDoInspireLayer:_doInspire(nType)
	if type(nType) ~= "number" then
		return
	end

	local nCount = 9999
	if nType == CrossPVPConst.INSPIRE_TYPE.HARM_ADD then
		-- 从data中拿到当前鼓舞次数
		nCount = G_Me.crossPVPData:getNumInspireAtk()
	elseif nType == CrossPVPConst.INSPIRE_TYPE.HARM_REDUCE then
		-- 从data中拿到当前鼓舞次数
		nCount = G_Me.crossPVPData:getNumInspireDef()
	end

	local tBuffTmpl = crosspvp_buff_info.get(nType)
	local nPrice = CrossPVPCommon.getInspireCost(tBuffTmpl.price, nCount)
	if G_Me.userData.gold < tBuffTmpl.price then
		require("app.scenes.shop.GoldNotEnoughDialog").show()
		return
	end

	if nCount < tBuffTmpl.buff_num then
		G_HandlersManager.crossPVPHandler:sendApplyAtcAndDefCrossPvp(nType)
	else
		G_MovingTip:showMovingTip(G_lang:get("LANG_CROSS_PVP_INSPIRE_MAX"))
	end
end

function CrossPVPDoInspireLayer:_onInspireSucc(tData)
--[[
message S2C_ApplyAtcAndDefCrossPvp
	required uint32 ret = 1;
	required uint32 apply_type = 2;//1 2 根据策划配置
	optional uint32 count = 3;//预留字段 默认每次就+1
	optional uint32 current = 4;//返回当前鼓舞次数
}
]]

		assert(tData.apply_type)
		local nInspireCount = tData.current or 0
		local tBuffTmpl = crosspvp_buff_info.get(tData.apply_type)
		local nBuffId = tBuffTmpl.buff_id
		local tPassiveSkillTmpl = passive_skill_info.get(nBuffId)
		local nBuff = nInspireCount * tPassiveSkillTmpl.affect_value / 10

		if tData.apply_type == CrossPVPConst.INSPIRE_TYPE.HARM_ADD then
	    	CommonFunc._updateLabel(self, "Label_AddTime_Value", {text=nInspireCount.."/"..tBuffTmpl.buff_num})
	    	local function onUpdate()
	    		CommonFunc._updateLabel(self, "Label_HarmAdd_Value", {text=G_lang:get("LANG_CROSS_PVP_ONCE_INSPIRE_ATTR_CHANGE", {num=nBuff})})
	    	end

	    	local flyText = FlyText.new(onUpdate, 0.4) 
			local szAttackAttr = G_lang:get("LANG_CROSS_PVP_INSPIRE_SUCC_1", {num=nBuff})
			flyText:addRichtext(szAttackAttr, 30, nil, Colors.strokeBrown, self:getLabelByName("Label_HarmAdd_Value"), nil, nil)
			flyText:play()
			self:addChild(flyText)

			CommonFunc._updateLabel(self, "Label_GoldNum_Add", {text=CrossPVPCommon.getInspireCost(tBuffTmpl.price, nInspireCount)})

		elseif tData.apply_type == CrossPVPConst.INSPIRE_TYPE.HARM_REDUCE then
			
			CommonFunc._updateLabel(self, "Label_ReduceTime_Value", {text=nInspireCount.."/"..tBuffTmpl.buff_num})
			local function onUpdate()
				CommonFunc._updateLabel(self, "Label_HarmReduce_Value", {text=G_lang:get("LANG_CROSS_PVP_ONCE_INSPIRE_ATTR_CHANGE", {num=nBuff})})
			end

			local flyText = FlyText.new(onUpdate, 0.4) 
			local szAttackAttr = G_lang:get("LANG_CROSS_PVP_INSPIRE_SUCC_2", {num=nBuff})
			flyText:addRichtext(szAttackAttr, 30, nil, Colors.strokeBrown, self:getLabelByName("Label_HarmReduce_Value"), nil, nil)
			flyText:play()
			self:addChild(flyText)

			CommonFunc._updateLabel(self, "Label_GoldNum_Reduce", {text=CrossPVPCommon.getInspireCost(tBuffTmpl.price, nInspireCount)})
		end


		local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
	        self:getImageViewByName('Image_Gold_Add'),
	        self:getLabelByName('Label_GoldNum_Add'),
	    }, "C")
	    self:getImageViewByName('Image_Gold_Add'):setPositionXY(alignFunc(1))
	    self:getLabelByName('Label_GoldNum_Add'):setPositionXY(alignFunc(2))

	    local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
	        self:getImageViewByName('Image_Gold_Reduce'),
	        self:getLabelByName('Label_GoldNum_Reduce'),
	    }, "C")
	    self:getImageViewByName('Image_Gold_Reduce'):setPositionXY(alignFunc(1))
	    self:getLabelByName('Label_GoldNum_Reduce'):setPositionXY(alignFunc(2))
end

function CrossPVPDoInspireLayer:_onCloseSelf()
	self:close()
end

return CrossPVPDoInspireLayer