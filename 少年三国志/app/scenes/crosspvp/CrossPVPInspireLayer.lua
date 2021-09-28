-- 鼓舞界面，有4种状态
-- 1. 没有投注阶段, 未参与
-- 2. 没有投注阶段,  参加
-- 3. 有投注阶段, 未参与
-- 4. 有投注阶段,  参加

local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")
local CrossPVPConst = require("app.const.CrossPVPConst")
local CrossPVPCommon = require("app.scenes.crosspvp.CrossPVPCommon")

local CrossPVPInspireLayer = class("CrossPVPInspireLayer", UFCCSNormalLayer)

function CrossPVPInspireLayer.create(...)
	return CrossPVPInspireLayer.new("ui_layout/crosspvp_CrossPVPInspireLayer.json", nil, ...)
end

function CrossPVPInspireLayer:ctor(json, param, ...)
	-- 有没有投注阶段
	self._hasBet = G_Me.crossPVPData:hasBetStage()
	-- 有没有参加
	self._isJoin = G_Me.crossPVPData:isApplied()
	-- 定时器
	self._tTimer = nil

	self:_initView()

	local nCourse = G_Me.crossPVPData:getCourse()

	self.super.ctor(self, json, param, ...)
end

function CrossPVPInspireLayer:onLayerEnter()
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_PVP_INSPIRE_SUCC, self._onInspireSucc, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_PVP_GET_BET_INFO, self._onUpdateWithData, self)

	self:_initLayer()

	self:_addTimer()

	-- 本轮有投注阶段的情况下，请求一下押注信息
	if self._hasBet then
		if self._isJoin then
			-- 自己参赛的情况下，进入界面立即请求
			G_HandlersManager.crossPVPHandler:sendGetBetInfo()
		else
			-- 自己未参赛情况下，等投注阶段结束3秒后才请求（因为鲜花榜可能不会立即结算出）
			local _, betEndTime = G_Me.crossPVPData:getStageTime(CrossPVPConst.STAGE_BET)
			local curTime = G_ServerTime:getTime()
			local passedTime = curTime - betEndTime

			if passedTime >= CrossPVPConst.REQUEST_DELAY then
				G_HandlersManager.crossPVPHandler:sendGetBetInfo()
			else
				for i = 1, 4 do
					CommonFunc._updateLabel(self, string.format("Label_PlayerName_%d", i), {text=G_lang:get("LANG_CROSS_PVP_CALCULATING")})
				end

				local delay = CrossPVPConst.REQUEST_DELAY - passedTime
				uf_funcCallHelper:callAfterDelayTime(delay, nil, 
					function() G_HandlersManager.crossPVPHandler:sendGetBetInfo() 
				end, nil)
			end
		end
	end

	--[[if self._hasBet and self._isJoin then
		G_HandlersManager.crossPVPHandler:sendGetBetInfo()
	elseif self._hasBet and not self._isJoin then
		-- 拉区鲜花排行榜
		G_HandlersManager.crossPVPHandler:sendGetBetInfo()
	end]]
end
 
function CrossPVPInspireLayer:onLayerExit()
	self:_removeTimer()
	uf_eventManager:removeListenerWithTarget(self)
end

function CrossPVPInspireLayer:_addTimer()
	if not self._tTimer then
		self._tTimer = G_GlobalFunc.addTimer(1, function()
			self:_updateCountDown()
		end)
	end
end

function CrossPVPInspireLayer:_removeTimer()
	if self._tTimer then
		G_GlobalFunc.removeTimer(self._tTimer)
		self._tTimer = nil
	end
end

function CrossPVPInspireLayer:_initView()
	if not self._hasBet and not self._isJoin then
		CommonFunc._updateLabel(self, "Label_StartFight_NJ", {stroke=Colors.strokeBrown, visible=false})
		CommonFunc._updateLabel(self, "Label_StartFight_NJ_Time", {text="", stroke=Colors.strokeBrown})
	elseif not self._hasBet and self._isJoin then
		CommonFunc._updateLabel(self, "Label_StartFight", {stroke=Colors.strokeBrown, visible=false})
		CommonFunc._updateLabel(self, "Label_StartFight_Time", {text="", stroke=Colors.strokeBrown})
	elseif self._hasBet and not self._isJoin then
		self:showWidgetByName("Panel_TopField", false)
		CommonFunc._updateLabel(self, "Label_CouldNotInspireTips", {stroke=Colors.strokeBrown})
	elseif self._hasBet and self._isJoin then
		CommonFunc._updateLabel(self, "Label_Time_BI", {stroke=Colors.strokeBrown, visible=false})
		CommonFunc._updateLabel(self, "Label_Time_Value_BI", {text="", stroke=Colors.strokeBrown})
	end
end

function CrossPVPInspireLayer:_initLayer()
	self:_showCurPanel()
	if not self._hasBet and not self._isJoin then
		-- 这个阶段的显示，由另一个界面代替
		assert(false, "this situation is not exist")
	elseif not self._hasBet and self._isJoin then
		self:_updateWithNoBetAndJoin()
	elseif self._hasBet and not self._isJoin then
		local tFieldColorList = {
			[1] = Colors.qualityColors[2],
	    	[2] = Colors.qualityColors[3],
	    	[3] = Colors.qualityColors[4],
	    	[4] = Colors.qualityColors[7],
		}

		for i=1, 4 do
			CommonFunc._updateLabel(self, string.format("Label_Field_%d", i), {color=tFieldColorList[i], stroke=Colors.strokeBrown, size=2})
		end
	elseif self._hasBet and self._isJoin then
		-- 需要拉协议后，才显示
	end
end

-- 2. 没有投注阶段,  参加
function CrossPVPInspireLayer:_updateWithNoBetAndJoin()
	self:_initTopLeftInfo()

	-- 标题
	CommonFunc._updateLabel(self, "Label_FlowName_NBJ", {stroke=Colors.strokeBrown})
	-- 距离开战
	CommonFunc._updateLabel(self, "Label_StartFight", {stroke=Colors.strokeBrown, visible=false})
	CommonFunc._updateLabel(self, "Label_StartFight_Time", {text="", stroke=Colors.strokeBrown})

	-- 比赛各阶段时间，通用组件
	local CrossPVPStageFlow = require("app.scenes.crosspvp.CrossPVPStageFlow")
	local stageLayer = CrossPVPStageFlow.create()
	local tParent = self:getImageViewByName("Image_Gray_NoBet_Join")
	if tParent and stageLayer then
		tParent:addNode(stageLayer)
		local tSize = tParent:getSize()
		stageLayer:setPositionX(stageLayer:getPositionX() + tSize.width/2)
		stageLayer:setPositionY(stageLayer:getPositionY() + tSize.height)
	end

	self:_onUpdateInspireInfoNoBet()

	-- 鼓舞按钮
	self:registerBtnClickEvent("Button_Inspire_NoBetJoin", function()
		local tLayer = require("app.scenes.crosspvp.CrossPVPDoInspireLayer").create()
		assert(tLayer)
		if tLayer then
			uf_sceneManager:getCurScene():addChild(tLayer)
		end
	end)
end

function CrossPVPInspireLayer:_onUpdateInspireInfoNoBet()
	-- 自己鼓舞的次数，分为伤害加成和伤害减免
	local nAddCount = G_Me.crossPVPData:getNumInspireAtk()
	local nReduceCount = G_Me.crossPVPData:getNumInspireDef()
	-- 伤害加成
	local tBuffTmplAdd = crosspvp_buff_info.get(1)
	-- 伤害减免
	local tBuffTmplReduce = crosspvp_buff_info.get(2)

	local tPassiveSkillTmpl1 = passive_skill_info.get(tBuffTmplAdd.buff_id)
	local tPassiveSkillTmpl2 = passive_skill_info.get(tBuffTmplReduce.buff_id)

	local szHarmAdd = string.format("+%.1f%%", nAddCount * tPassiveSkillTmpl1.affect_value / 10)
	local szHarmReduce = string.format("+%.1f%%", nReduceCount * tPassiveSkillTmpl2.affect_value / 10)
	CommonFunc._updateLabel(self, "Label_InspireCountAdd_Value_NBJ", {text=nAddCount})
	CommonFunc._updateLabel(self, "Label_InspireCountReduce_Value_NBJ", {text=nReduceCount})
	CommonFunc._updateLabel(self, "Label_HarmAdd_Value_NBJ", {text=szHarmAdd})
	CommonFunc._updateLabel(self, "Label_HarmReduce_Value_NBJ", {text=szHarmReduce})
end

-- 3. 有投注阶段, 未参与
function CrossPVPInspireLayer:_updateWithBetAndNotJoin(tData)
	-- 标题
	CommonFunc._updateLabel(self, "Label_FlowerRank", {stroke=Colors.strokeBrown})

	-- 比赛各阶段时间，通用组件
	local CrossPVPStageFlow = require("app.scenes.crosspvp.CrossPVPStageFlow")
	local stageLayer = CrossPVPStageFlow.create()
	local tParent = self:getImageViewByName("Image_Gray_Bet_NotJoin")
	if tParent and stageLayer then
		tParent:addNode(stageLayer)
		local tSize = tParent:getSize()
		stageLayer:setPositionX(stageLayer:getPositionX() + tSize.width/2)
		stageLayer:setPositionY(stageLayer:getPositionY() + tSize.height - 10)
	end

	local tPlayerNameList = {}
	local tFlowerCountList = {}
	for i, v in ipairs(tData.ranks) do
	--	dump(v)
		local nField = v.sp1 or 1
		tPlayerNameList[nField] = v.name or ""
		tFlowerCountList[nField] = v.sp2 or 0 -- 鲜花数量
	end

	-- 显示4个战场鲜花榜第1的那个家伙
	for i=1, 4 do
		local szPlayerName = ""
		local tColor = nil
        if tPlayerNameList[i] then
        	szPlayerName = tPlayerNameList[i]
        	tColor = Colors.lightColors.DESCRIPTION
        else
        	szPlayerName = G_lang:get("LANG_REBEL_BOSS_WAITING_FOR_YOU")
        	tColor = Colors.lightColors.TIPS_02

        	self:showWidgetByName(string.format("Label_Flower_%d", i), false)
			self:showWidgetByName(string.format("Image_Flower_%d", i), false)
			self:showWidgetByName(string.format("Label_FlowerCount_%d", i), false)
        end

		CommonFunc._updateLabel(self, string.format("Label_PlayerName_%d", i), {text=szPlayerName, color=tColor})
		CommonFunc._updateLabel(self, string.format("Label_FlowerCount_%d", i), {text=tFlowerCountList[i] or 0})
	end
end

-- 4. 有投注阶段,  参加
function CrossPVPInspireLayer:_updateWithBetAndJoin()
	self:_initTopLeftInfo()

	-- 标题
	CommonFunc._updateLabel(self, "Label_Bet_Title", {stroke=Colors.strokeBrown})
	-- 属性加成文字提示
	CommonFunc._updateLabel(self, "Label_AttrAddtionTips", {stroke=Colors.strokeBrown})
	-- “战前鼓舞”
	CommonFunc._updateLabel(self, "Label_Inspire_Bet_Join", {stroke=Colors.strokeBrown})

	-- 比赛各阶段时间，通用组件
	local CrossPVPStageFlow = require("app.scenes.crosspvp.CrossPVPStageFlow")
	local stageLayer = CrossPVPStageFlow.create()
	local tParent = self:getImageViewByName("Image_Gray_Bet_Join")
	if tParent and stageLayer then
		tParent:addNode(stageLayer)
		local tSize = tParent:getSize()
		stageLayer:setPositionX(stageLayer:getPositionX() + tSize.width/2)
		stageLayer:setPositionY(stageLayer:getPositionY() + tSize.height)
	end

	-- 获得鲜花鸡蛋，属性加成减免信息
	local nFlowerCount = G_Me.crossPVPData:getNumGetFlower()
	local nEggCount = G_Me.crossPVPData:getNumGetEgg()
	local szHarmAdd = CrossPVPCommon.getFlowerBuffAddition(nFlowerCount)
	local szHarmReduce = CrossPVPCommon.getEggBuffAddition(nEggCount)

	CommonFunc._updateLabel(self, "Label_Flower", {stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_Flower_Count", {text=nFlowerCount, stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_Egg", {stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_Egg_Count", {text=nEggCount, stroke=Colors.strokeBrown})
	-- 鲜花加成的属性
	CommonFunc._updateLabel(self, "Label_Bet_HarmAdd", {stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_Bet_HarmAdd_Value", {text=szHarmAdd, stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_Bet_HarmReduce", {stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_Bet_HarmReduce_Value", {text=szHarmReduce, stroke=Colors.strokeBrown})


	self:_onUpdateInspireInfoHasBet()

	-- 鼓舞按钮
	self:registerBtnClickEvent("Button_Inspire_BetJoin", function()
		local tLayer = require("app.scenes.crosspvp.CrossPVPDoInspireLayer").create()
		assert(tLayer)
		if tLayer then
			uf_sceneManager:getCurScene():addChild(tLayer)
		end
	end)
end

function CrossPVPInspireLayer:_onUpdateInspireInfoHasBet()
	-- 自己鼓舞的次数，分为伤害加成和伤害减免
	local nAddCount = G_Me.crossPVPData:getNumInspireAtk()
	local nReduceCount = G_Me.crossPVPData:getNumInspireDef()
	-- 伤害加成
	local tBuffTmplAdd = crosspvp_buff_info.get(1)
	-- 伤害减免
	local tBuffTmplReduce = crosspvp_buff_info.get(2)

	local tPassiveSkillTmpl1 = passive_skill_info.get(tBuffTmplAdd.buff_id)
	local tPassiveSkillTmpl2 = passive_skill_info.get(tBuffTmplReduce.buff_id)

	szHarmAdd = string.format("+%.1f%%", nAddCount * tPassiveSkillTmpl1.affect_value / 10)
	szHarmReduce = string.format("+%.1f%%", nReduceCount * tPassiveSkillTmpl2.affect_value / 10)
	CommonFunc._updateLabel(self, "Label_InspireCountAdd_Value", {text=nAddCount})
	CommonFunc._updateLabel(self, "Label_InspireCountReduce_Value", {text=nReduceCount})
	CommonFunc._updateLabel(self, "Label_HarmAdd_Value", {text=szHarmAdd})
	CommonFunc._updateLabel(self, "Label_HarmReduce_Value", {text=szHarmReduce})
end

function CrossPVPInspireLayer:_onInspireSucc()
	if not self._hasBet and self._isJoin then
		self:_onUpdateInspireInfoNoBet()
	elseif self._hasBet and self._isJoin then
		self:_onUpdateInspireInfoHasBet()
	end
end

function CrossPVPInspireLayer:_showCurPanel()
	self:showWidgetByName("Panel_NoBet_NotJoin", not self._hasBet and not self._isJoin)
	self:showWidgetByName("Panel_NoBet_Join",    not self._hasBet and self._isJoin)
	self:showWidgetByName("Panel_Bet_NotJoin",   self._hasBet and not self._isJoin)
	self:showWidgetByName("Panel_Bet_Join", 	 self._hasBet and self._isJoin)

	self:showWidgetByName("Panel_TopField", self._isJoin)
end

-- 1. 没有投注，有鼓舞，要显示到开战的倒计时
-- 2. 没有投注，没有鼓舞，要显示到开战的倒计时
function CrossPVPInspireLayer:_updateCountDown()
	if not self._hasBet then
		local begin, close = G_Me.crossPVPData:getStageTime(CrossPVPConst.STAGE_ENCOURAGE)
		local leftTime = CrossPVPCommon.getFormatLeftTime(close )

		local szTime = leftTime
		CommonFunc._updateLabel(self, "Label_StartFight", {visible=true})
		CommonFunc._updateLabel(self, "Label_StartFight_Time", {text=szTime})

	    local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
	        self:getLabelByName('Label_StartFight'),
	        self:getLabelByName('Label_StartFight_Time'),
	    }, "C")
	    self:getLabelByName('Label_StartFight'):setPositionXY(alignFunc(1))
	    self:getLabelByName('Label_StartFight_Time'):setPositionXY(alignFunc(2))

	    if leftTime == "" then
	    	self:showWidgetByName("Label_StartFight", false)
	    	self:_removeTimer()
	    end
	elseif self._hasBet and self._isJoin then
		local begin, close = G_Me.crossPVPData:getStageTime(CrossPVPConst.STAGE_ENCOURAGE)
		local leftTime = CrossPVPCommon.getFormatLeftTime(close )

		local szTime = leftTime
		CommonFunc._updateLabel(self, "Label_Time_BI", {visible=true})
		CommonFunc._updateLabel(self, "Label_Time_Value_BI", {text=szTime})

	    local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
	        self:getLabelByName('Label_Time_BI'),
	        self:getLabelByName('Label_Time_Value_BI'),
	    }, "C")
	    self:getLabelByName('Label_Time_BI'):setPositionXY(alignFunc(1))
	    self:getLabelByName('Label_Time_Value_BI'):setPositionXY(alignFunc(2))

	    if leftTime == "" then
	    	self:showWidgetByName("Label_Time_BI", false)
	    	self:_removeTimer()
	    end
	end
end

function CrossPVPInspireLayer:_initTopLeftInfo()
	CommonFunc._updateLabel(self, "Label_BattleField", {stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_CurScore", {stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_CurRank", {stroke=Colors.strokeBrown})

	CommonFunc._updateLabel(self, "Label_BattleField_Value", {text=CrossPVPCommon.getBattleFieldName(G_Me.crossPVPData:getBattlefield() or 1), stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_CurScore_Value", {text=0, stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_CurRank_Value", {text=G_Me.crossPVPData:getFieldRank(), stroke=Colors.strokeBrown})
end

function CrossPVPInspireLayer:_onUpdateWithData(tData)
	if self._hasBet and self._isJoin then
		self:_updateWithBetAndJoin()
	elseif self._hasBet and not self._isJoin then
		-- 拉取鲜花排行榜
		self:_updateWithBetAndNotJoin(tData)
	end
end

return CrossPVPInspireLayer