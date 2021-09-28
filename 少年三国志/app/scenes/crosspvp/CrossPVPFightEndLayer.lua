-- 战斗结束阶段，玩家看到的界面
-- 只有参与这轮比赛的玩家可以看到

local KnightPic = require("app.scenes.common.KnightPic")
local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")
local CrossPVPCommon = require("app.scenes.crosspvp.CrossPVPCommon")
local CrossPVPConst = require("app.const.CrossPVPConst")

local CrossPVPFightEndLayer = class("CrossPVPFightEndLayer", UFCCSNormalLayer)

function CrossPVPFightEndLayer.create(...)
	return CrossPVPFightEndLayer.new("ui_layout/crosspvp_CrossPVPFightEndLayer.json", nil, ...)
end

function CrossPVPFightEndLayer:ctor(json, param, ...)
	-- 战场
	self._nBattleField = 1
	-- 当前积分
	self._nCurScore = 0
	-- 本轮排名
	self._nRoomRank = 0
	-- 战斗场数
	self._nBattleCount = 0
	-- 胜利场数
	self._nWinCount = 0
	-- 胜率
	self._szWinRate = ""

	self._tScheduleTmpl = nil
	-- 玩家的形象
	self._imgHead = nil
	-- 计时器
	self._tTimer = nil

	self.super.ctor(self, json, param, ...)
end

function CrossPVPFightEndLayer:onLayerLoad()
	self:_initView()
end

function CrossPVPFightEndLayer:onLayerEnter()
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_PVP_GET_REVIEW_INFO, self._initLayer, self)

	if not G_Me.crossPVPData:isWaitResult() then
		self:_initLayer()
	else
		-- 延迟2秒拉协议
		self:_addTimer()
		self:showWidgetByName("Panel_Info", false)
		self:showWidgetByName("Panel_Waiting", true)
		self:_showPlayerImage()
	end
end

function CrossPVPFightEndLayer:_addTimer()
	if not self._tTimer then
		self._tTimer = G_GlobalFunc.addTimer(CrossPVPConst.REQUEST_DELAY, function()
			G_HandlersManager.crossPVPHandler:sendGetReviewInfo()
			self:_removeTimer()
		end)
	end
end

function CrossPVPFightEndLayer:_removeTimer()
	if self._tTimer then
		G_GlobalFunc.removeTimer(self._tTimer)
		self._tTimer = nil
	end
end

function CrossPVPFightEndLayer:onLayerExit()
	self:_removeTimer()
	uf_eventManager:removeListenerWithTarget(self)
end

function CrossPVPFightEndLayer:adapterLayer()
	self:adapterWidgetHeight("Panel_Middle", "Panel_16", "Panel_Flow",  0, 0)

	self:_addFlowPart()
end

-- 对一些lable进度描边，置空操作
function CrossPVPFightEndLayer:_initView()
	-- 顶部的玩家个人信息
	CommonFunc._updateLabel(self, "Label_BattleField", {stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_BattleField_Value", {text="", stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_CurScore", {stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_CurScore_Value", {text="", stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_CurRank", {stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_CurRank_Value", {text="", stroke=Colors.strokeBrown})

	-- 赛程标题
	CommonFunc._updateLabel(self, "Label_Title", {text=G_lang:get("LANG_CROSS_PVP_FIGHT_END_TITLE"), stroke=Colors.strokeBrown, size=2})

	-- 玩家个人信息
	CommonFunc._updateLabel(self, "Label_Congratulation", {stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_NextRound", {text="", stroke=Colors.strokeBrown})

	CommonFunc._updateLabel(self, "Label_CurScore1", {stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_CurScore1_Value", {stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_CurRank1", {stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_CurRank1_Value", {stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_FightCount1", {stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_FightCount1_Value", {stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_WinRate1", {stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_WinRate1_Value", {stroke=Colors.strokeBrown})

	CommonFunc._updateLabel(self, "Label_Waiting", {stroke=Colors.strokeBrown})
end

function CrossPVPFightEndLayer:_addFlowPart()
	local CrossPVPCourseFlow = require("app.scenes.crosspvp.CrossPVPCourseFlow")

	local courseLayer = CrossPVPCourseFlow.create()
	courseLayer:setPositionY(courseLayer:getPositionY())
	local tParent = self:getRootWidget()
	if tParent then
		tParent:addNode(courseLayer)
	end
end

function CrossPVPFightEndLayer:_initLayer()
	self:showWidgetByName("Panel_Info", true)
	self:showWidgetByName("Panel_Waiting", false)

	self._nBattleField = G_Me.crossPVPData:getBattlefield()
	self._nCurScore = G_Me.crossPVPData:getScore()
	self._nRoomRank = G_Me.crossPVPData:getRoomRank()
	self._nBattleCount = G_Me.crossPVPData:getFightCount()
	self._nWinCount = G_Me.crossPVPData:getWinCount()
	if self._nBattleCount ~= 0 then
		self._szWinRate = string.format("%.1f%%", self._nWinCount / self._nBattleCount * 100)
	else
		self._szWinRate = string.format("%.1f%%", 0)
	end

	self:_updateTopLeftInfo()
--	self:_updateWithJoinState()
	self:_showInfo()
	self:_alignTopLeftInfo()
end


-- 参与了的玩家，包括淘汰的玩家
function CrossPVPFightEndLayer:_updateWithJoinState()
	local nCourse = G_Me.crossPVPData:getCourse()

	if nCourse == CrossPVPConst.COURSE_PROMOTE_1024 then
		nCourse = CrossPVPConst.COURSE_PROMOTE_256
	end

	-- 是否被淘汰
	self._tScheduleTmpl = crosspvp_schedule_info.get(nCourse - 2)
	if not self._tScheduleTmpl then
		return
	end

	local bWeedOut = false
	if self._nRoomRank > self._tScheduleTmpl.rank_num or self._nRoomRank == 0 then
		bWeedOut = true
	end
	-- 是决赛
	if self._tScheduleTmpl.id == 6 then
		bWeedOut = false
	end

	local szNext = ""
	if bWeedOut then
		-- 您未晋级...
		CommonFunc._updateLabel(self, "Label_Congratulation", {text=G_lang:get("LANG_CROSS_PVP_REGRET")})
		szNext = G_lang:get("LANG_CROSS_PVP_PROMOTED_NOT")
		-- 参与比赛（被淘汰）
		CommonFunc._updateLabel(self, "Label_CurScore", {text=G_lang:get("LANG_CROSS_PVP_JOIN_MATCH")})
		CommonFunc._updateLabel(self, "Label_CurScore_Value", {text=G_lang:get("LANG_CROSS_PVP_BE_WEEDOUT", {name=self._tScheduleTmpl.name})})
		self:_hideDetailInfo()
	else
        -- 恭喜晋级...
        -- 下一轮比赛
        local tScheduleTmpl = crosspvp_schedule_info.get(nCourse - 1)
        if tScheduleTmpl then
        	CommonFunc._updateLabel(self, "Label_Congratulation", {text=G_lang:get("LANG_CROSS_PVP_END_GONGXI")})
        	szNext = G_lang:get("LANG_CROSS_PVP_PROMOTION_TO", {next=tScheduleTmpl.name})
        else
        	-- 已经是决赛结束了，根据4强名次，做显示
        	if G_Me.crossPVPData:getFieldRank() == 1 then
        		CommonFunc._updateLabel(self, "Label_Congratulation", {text=G_lang:get("LANG_CROSS_PVP_END_GAIN")})
        		szNext = G_lang:get("LANG_CROSS_PVP_END_CHAMPION")
        	else
				CommonFunc._updateLabel(self, "Label_Congratulation", {text=G_lang:get("LANG_CROSS_PVP_REGRET")})
				szNext = G_lang:get("LANG_CROSS_PVP_NOT_GET_CHAMPION")
				-- 参与比赛（被淘汰）
				CommonFunc._updateLabel(self, "Label_CurScore", {text=G_lang:get("LANG_CROSS_PVP_JOIN_MATCH")})
				CommonFunc._updateLabel(self, "Label_CurScore_Value", {text=G_lang:get("LANG_CROSS_PVP_BE_WEEDOUT", {name=self._tScheduleTmpl.name})})
        		
        		self:_hideDetailInfo()
        	end
        end
	end

    local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
        self:getLabelByName('Label_Congratulation'),
        self:getLabelByName('Label_NextRound'),
    }, "L")
    self:getLabelByName('Label_Congratulation'):setPositionXY(alignFunc(1))
    self:getLabelByName('Label_NextRound'):setPositionXY(alignFunc(2))

	-- 标题“战斗结束”
	CommonFunc._updateLabel(self, "Label_Title", {text=G_lang:get("LANG_CROSS_PVP_FIGHT_END_TITLE")})
	CommonFunc._updateLabel(self, "Label_NextRound", {text=szNext})

	-- 玩家形象
	self:_showPlayerImage()

	-- 中间的玩家个人信息
	CommonFunc._updateLabel(self, "Label_CurScore1_Value", {text=self._nCurScore})
	CommonFunc._updateLabel(self, "Label_CurRank1_Value", {text=G_Me.crossPVPData:getRoomRank()})
	CommonFunc._updateLabel(self, "Label_FightCount1_Value", {text=self._nBattleCount})
	CommonFunc._updateLabel(self, "Label_WinRate1_Value", {text=self._szWinRate})
end

function CrossPVPFightEndLayer:_showInfo()
	local nCourse = G_Me.crossPVPData:getCourse()
	if nCourse == CrossPVPConst.COURSE_PROMOTE_1024 then
		nCourse = CrossPVPConst.COURSE_PROMOTE_256
	end

	-- 是否被淘汰
	self._tScheduleTmpl = crosspvp_schedule_info.get(nCourse - 2)
	if not self._tScheduleTmpl then
		return
	end

	local bWeedOut = false
	if self._nRoomRank > self._tScheduleTmpl.rank_num or self._nRoomRank == 0 then
		bWeedOut = true
	end

	local szDesc = ""
	local szNext = ""
	if self._tScheduleTmpl.id ~= 6 then
		-- 本轮不是决赛
		if not bWeedOut then
			-- 晋级
			local tScheduleTmpl = crosspvp_schedule_info.get(nCourse - 1)
			szDesc = G_lang:get("LANG_CROSS_PVP_END_GONGXI")
			szNext = G_lang:get("LANG_CROSS_PVP_PROMOTION_TO", {next=tScheduleTmpl.name})
		else
			szDesc = G_lang:get("LANG_CROSS_PVP_REGRET")
			szNext = G_lang:get("LANG_CROSS_PVP_PROMOTED_NOT")
			-- 参与比赛（被淘汰）
			CommonFunc._updateLabel(self, "Label_CurScore", {text=G_lang:get("LANG_CROSS_PVP_JOIN_MATCH")})
			CommonFunc._updateLabel(self, "Label_CurScore_Value", {text=G_lang:get("LANG_CROSS_PVP_BE_WEEDOUT", {name=self._tScheduleTmpl.name})})
			self:_hideDetailInfo()
		end
	else
		-- 本轮是决赛
		--[[
		if not bWeedOut then
			-- 获得冠军
			szDesc = G_lang:get("LANG_CROSS_PVP_END_GAIN")
			szNext = G_lang:get("LANG_CROSS_PVP_END_CHAMPION")
		else
			szDesc = G_lang:get("LANG_CROSS_PVP_REGRET")
			szNext = G_lang:get("LANG_CROSS_PVP_NOT_GET_CHAMPION")
			-- 参与比赛（被淘汰）
			CommonFunc._updateLabel(self, "Label_CurScore", {text=G_lang:get("LANG_CROSS_PVP_JOIN_MATCH")})
			CommonFunc._updateLabel(self, "Label_CurScore_Value", {text=G_lang:get("LANG_CROSS_PVP_BE_WEEDOUT", {name=self._tScheduleTmpl.name})})
			self:_hideDetailInfo()
		end
		]]

		local szRankDesc = CrossPVPCommon.getRankDescAtFinalEnd(self._nRoomRank)
		szDesc = G_lang:get("LANG_CROSS_PVP_END_GAIN")
		szNext = szRankDesc
	end
	CommonFunc._updateLabel(self, "Label_Congratulation", {text=szDesc})
	CommonFunc._updateLabel(self, "Label_NextRound", {text=szNext})

	local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
        self:getLabelByName('Label_Congratulation'),
        self:getLabelByName('Label_NextRound'),
    }, "L")
    self:getLabelByName('Label_Congratulation'):setPositionXY(alignFunc(1))
    self:getLabelByName('Label_NextRound'):setPositionXY(alignFunc(2))

	-- 玩家形象
	self:_showPlayerImage()

	-- 中间的玩家个人信息
	CommonFunc._updateLabel(self, "Label_CurScore1_Value", {text=self._nCurScore})
	CommonFunc._updateLabel(self, "Label_CurRank1_Value", {text=G_Me.crossPVPData:getRoomRank()})
	CommonFunc._updateLabel(self, "Label_FightCount1_Value", {text=self._nBattleCount})
	CommonFunc._updateLabel(self, "Label_WinRate1_Value", {text=self._szWinRate})
end

function CrossPVPFightEndLayer:_showPlayerImage()
	local bNeedPlayerHead = true
	local panelPlayerHead = self:getPanelByName("Panel_Player")
	local nResId = G_Me.dressData:getDressedPic()
	assert(panelPlayerHead)
	if panelPlayerHead then
		panelPlayerHead:setScale(0.65)
		if bNeedPlayerHead then
			if not self._imgHead then
				self._imgHead = KnightPic.createKnightPic(nResId, panelPlayerHead, "head", true)
			end
		else
			if self._imgHead then
				self._imgHead:removeFromParentAndCleanup(true)
				self._imgHead = nil
			end
		end
	end
end

function CrossPVPFightEndLayer:_updateTopLeftInfo()
	-- 顶部的玩家个人信息
	local nFieldType = G_Me.crossPVPData:getBattlefield() or 1
	local szFieldName = CrossPVPCommon.getBattleFieldName(nFieldType) 
	local nCurScore = self._nCurScore
	local nFieldRank = G_Me.crossPVPData:getFieldRank()

	CommonFunc._updateLabel(self, "Label_BattleField_Value", {text=szFieldName})
	CommonFunc._updateLabel(self, "Label_CurScore_Value", {text=nCurScore})
	CommonFunc._updateLabel(self, "Label_CurRank_Value", {text=nFieldRank ~= 0 and nFieldRank or G_lang:get("LANG_REBEL_BOSS_NOT_ON_RANK_1")})
end

function CrossPVPFightEndLayer:_hideDetailInfo()
	self:showWidgetByName("Panel_29", false)
	self:showWidgetByName("Panel_30", false)
	self:showWidgetByName("Panel_31", false)
	self:showWidgetByName("Panel_32", false)
end

function CrossPVPFightEndLayer:_alignTopLeftInfo()
	local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
        self:getLabelByName('Label_BattleField'),
        self:getLabelByName('Label_BattleField_Value'),
    }, "L")
    self:getLabelByName('Label_BattleField'):setPositionXY(alignFunc(1))
    self:getLabelByName('Label_BattleField_Value'):setPositionXY(alignFunc(2))

    local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
        self:getLabelByName('Label_CurScore'),
        self:getLabelByName('Label_CurScore_Value'),
    }, "L")
    self:getLabelByName('Label_CurScore'):setPositionXY(alignFunc(1))
    self:getLabelByName('Label_CurScore_Value'):setPositionXY(alignFunc(2))

    local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
        self:getLabelByName('Label_CurRank'),
        self:getLabelByName('Label_CurRank_Value'),
    }, "L")
    self:getLabelByName('Label_CurRank'):setPositionXY(alignFunc(1))
    self:getLabelByName('Label_CurRank_Value'):setPositionXY(alignFunc(2))
end

return CrossPVPFightEndLayer