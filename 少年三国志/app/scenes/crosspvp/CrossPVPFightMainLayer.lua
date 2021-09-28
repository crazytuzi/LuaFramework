-- 战斗阶段参与的玩家看到的界面， 未参与但能观战的玩家， 也显示该界面

local CrossPVPConst = require("app.const.CrossPVPConst")
local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")
local KnightPic = require("app.scenes.common.KnightPic")
local CrossPVPCommon = require("app.scenes.crosspvp.CrossPVPCommon")
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
local NumberScaleChanger = require("app.scenes.common.NumberScaleChanger")
local FlyText = require("app.scenes.common.FlyText")


local CrossPVPFightMainLayer = class("CrossPVPFightMainLayer", UFCCSNormalLayer)

local ARENA_MAX = 6

-- 占领坑位后，自动T人时间
local ENGAGED_TIME_MAX = 60
-- 玩家2次攻击之间的CD时间
local PLAYER_ATTACK_CD = 40
-- 坑位保护时间
local ARENA_PROTECT_CD = 10
-- 每隔X秒拉取房间排行榜
local GET_RANK_TIME_MAX = 5

function CrossPVPFightMainLayer.create(...)
	return CrossPVPFightMainLayer.new("ui_layout/crosspvp_CrossPVPFightMainLayer.json", nil, ...)
end

function CrossPVPFightMainLayer:ctor(json, param, ...)
    -- 成员变量
    -- 战场
    self._nStage = 0
    -- 房间
    self._nRoom = 0
    -- 数据在界面缓存就可以了, 使用index做key
    self._tArenaDataList = {}
    -- flag list
    self._tFlagList = {}
    -- 玩家的攻打CD是否到时
    self._bAttackCDFinished = true
    -- 自己的flag
    self._nSelfFlag = 0
    -- 每隔几秒拉一次房间排行榜
    self._nGetRoomRankTime = GET_RANK_TIME_MAX
    -- 6个坑位的玩家头像
    self._tHeadList = {}
    -- 呼吸动作
    self._tBreathList = {}
    -- 对手的信息
    self._tEnemyInfo = {}
    -- T人的动作
    self._tKickAniList = {}
    -- 计时器
   	self._tEngagedTimer = nil
   	-- 玩家T人前的积分，T人成功
   	self._nPreScore = 0
   	-- 自己是否占领了坑位（空坑或T人）, 要播放分数增加动画
   	self._bEngagedArena = false
   	self._nEngagedScore = 0
   	-- 是否开启了弹幕
   	self._isOpenBS = G_Me.crossPVPData:getCourse() >= CrossPVPConst.COURSE_PROMOTE_16 and true or false
   	self._tBSLayer = nil
   	self._isBSOnCD = false --弹幕在冷却
   	self._tBSTmpl = bullet_screen_info.get(1)


    -- 自己的房间排名
    self._nSelfRank = 0
    self._nSelfScore = 0
    self._tScheduleTmpl = crosspvp_schedule_info.get(G_Me.crossPVPData:getCourse() - 1)
    assert(self._tScheduleTmpl)
    
    -- 是否是观众
    self._isAudience = false
    if G_Me.crossPVPData:isApplied() then
    	self._isAudience = false
    else
    	self._isAudience = G_Me.crossPVPData:hasObRight()
    end  

	self.super.ctor(self, json, param, ...)
end

function CrossPVPFightMainLayer:onLayerLoad()
	-- 函数调用
	self:_loadMap()
	self:_addMapEffect()
	self:_initView()
	self:_registerBtnEvents()
	self:_updateBSCD()

	-- 监听事件
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_PVP_ENTER_FIGHT_MAIN_LAYER, self._initLayer, self)
	-- 更新坑位，一个一个的进行更新
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_PVP_UPDATE_ARENA, self._onUpdateArena, self)
	-- 更新坑位(坑位被占或人被T)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_PVP_UPDATE_ARENA_SPECIAL, self._onUpdateArenaSpecial, self)
	-- 更新自己的积分
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_PVP_UPDATE_SELF_SCORE, self._onUpdateSelfInfo, self)
	-- 和某人打架，或直接占一个坑
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_PVP_FIGHT_SOMEONE_SUCC, self._onEnagedArenaOrOpenBattleScene, self)
	-- 获取当前战场，战前房间的排行榜
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_PVP_GET_SCORE_RANK_SUCC, self._onUpdateTopSix, self)
	-- 发送弹幕成功
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_PVP_SEND_BULLET_SCREEN_SUCC, self._onSendBulletScreenSucc, self)

	if not self._isAudience then
		self._nStage = G_Me.crossPVPData:getBattlefield()
		self._nRoom  = G_Me.crossPVPData:getRoomID()
		self._nSelfScore = G_Me.crossPVPData:getScore()

		if self._nStage > 0 and self._nRoom > 0 then
			CommonFunc._updateLabel(self, "Label_BattleField_Value", {text=CrossPVPCommon.getBattleFieldName(self._nStage)})
			CommonFunc._updateLabel(self, "Label_CurScore_Value", {text=self._nSelfScore})
		
			G_HandlersManager.crossPVPHandler:sendGetCrossPvpArena(self._nStage, self._nRoom)
		end
	else
		local nStage = G_Me.crossPVPData:getObStage()
		local nRoom = G_Me.crossPVPData:getObRoom()
		self._nStage = nStage
		self._nRoom = nRoom
	--	__Log("-- 我是ob, 我拉这条协议, nStage = %d, nRoom = %d", nStage, nRoom)
		G_HandlersManager.crossPVPHandler:sendGetCrossPvpArena(nStage, nRoom)

		CommonFunc._updateLabel(self, "Label_BattleField_Value", {text=CrossPVPCommon.getBattleFieldName(self._nStage)})
	end

	self:_addBulletScreen()
end

function CrossPVPFightMainLayer:_playAddScoreAction(nPreScore, nCurScore)
	nPreScore = nPreScore or 0
	nCurScore = nCurScore or 0

	local label = self:getLabelByName("Label_CurScore_Value")
	label:stopAllActions()
	label:setScale(1)
    local actSacleTo1 = CCScaleTo:create(0.25, 2)
    local actSacleTo2 = CCScaleTo:create(0.15, 1)
    local actCallback = CCCallFunc:create(function()
    	CommonFunc._updateLabel(self, "Label_CurScore_Value", {text=nCurScore})
    end)
    local arr = CCArray:create()
    arr:addObject(actSacleTo1)
    arr:addObject(actSacleTo2)
    arr:addObject(actCallback)
    local actSeq = CCSequence:create(arr)
    label:runAction(actSeq)
end

function CrossPVPFightMainLayer:clearTimerAndEvents()
	self:_removeTimer()
	uf_eventManager:removeListenerWithTarget(self)

	if self._tBSLayer then
		self._tBSLayer:closeBulletScreen()
		self._tBSLayer:removeFromParentAndCleanup(true)
		self._tBSLayer = nil
	end
end


function CrossPVPFightMainLayer:onLayerUnload( ... )
	self:clearTimerAndEvents()
end


function CrossPVPFightMainLayer:adapterLayer()
	
end

function CrossPVPFightMainLayer:onLayerEnter()
	self:adapterWidgetHeight("Panel_82", "", "Panel_Bottom", 0, 0)

	self:_updateSelfRoomRank()

	self:_handlerFlyEngagedScore()
end

function CrossPVPFightMainLayer:onLayerExit()

end

-- 初始化界面，等待协议回来数据进行填充
function CrossPVPFightMainLayer:_initView()
	-- 倒计时
	CommonFunc._updateLabel(self, "Label_EndTime", {stroke=Colors.strokeBrown, visible=false})
	CommonFunc._updateLabel(self, "Label_Time", {text="", stroke=Colors.strokeBrown})
	-- 玩家的攻击CD
	local nLastTime = G_Me.crossPVPData:getLastAttackArenaTime()
	local nLeftCD = math.max(0, nLastTime + PLAYER_ATTACK_CD - G_ServerTime:getTime()) 
	CommonFunc._updateLabel(self, "Label_AttackCD", {stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_AttackCD_Time", {text=G_lang:get("LANG_CROSS_PVP_ENGAGED_TIME_COUNT_DOWN", {num=nLeftCD}), stroke=Colors.strokeBrown})
	local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
        self:getLabelByName('Label_AttackCD'),
        self:getLabelByName('Label_AttackCD_Time'),
    }, "C")
    self:getLabelByName('Label_AttackCD'):setPositionXY(alignFunc(1))
    self:getLabelByName('Label_AttackCD_Time'):setPositionXY(alignFunc(2))  
    self:showWidgetByName("Image_TimeBg2", false)

	-- 
	CommonFunc._updateLabel(self, "Label_BattleField", {stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_BattleField_Value", {text="", stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_CurScore", {stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_CurScore_Value", {text="", stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_CurRank", {stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_CurRank_Value", {text="", stroke=Colors.strokeBrown})

	-- 前6名的玩家名字和积分
	for i=1, ARENA_MAX do
		CommonFunc._updateLabel(self, string.format("Label_Rank%d_Rank", i), {text=""})
		CommonFunc._updateLabel(self, string.format("Label_Rank%d_PlayerName", i), {text="", stroke=Colors.strokeBrown})
		CommonFunc._updateLabel(self, string.format("Label_Rank%d_Score", i), {text=""})
	end
	-- 6个坑的玩家名字描边
	for i=1, ARENA_MAX do
		CommonFunc._updateLabel(self, string.format("Label_Stage%d_PlayerName", i), {text="", stroke=Colors.strokeBrown})
	end

	-- 开启弹幕
	CommonFunc._updateLabel(self, "Label_Barrage", {stroke=Colors.strokeBrown})

	self:_clearTotalArenas()

	if self._isAudience then
		CommonFunc._updateLabel(self, "Label_BattleField", {text=G_lang:get("LANG_CROSS_PVP_OB_FIELD")})
		local panelEndTime = self:getPanelByName("Panel_EndTime")
		local panelTopScore = self:getPanelByName("Panel_TopScore")
		if panelEndTime and panelTopScore then
			panelEndTime:setPositionY(panelTopScore:getPositionY())
		end
	end

	-- 是否开启弹幕
	self:showWidgetByName("CheckBox_Barrage", self._isOpenBS)
	self:showWidgetByName("Button_Barrage", self._isOpenBS)
	CommonFunc._updateLabel(self, "Label_SendBSCD", {stroke=Colors.strokeBrown})
end

--[[
message C2S_GetCrossPvpRole {
}
 
message S2C_GetCrossPvpRole {
    required uint32 ret = 1;
    optional uint32 round = 2;//哪轮 海选 OR 1024...
    optional uint32 stage = 3;//哪个赛场
    optional uint32 room = 4;//房间ID
    optional uint32 score = 5;
}
]]

-- 进界面后的协议返回，调用这个函数来填充界面
function CrossPVPFightMainLayer:_initLayer(tFlagList)
	self._tFlagList = tFlagList or {}
	self:_addTimer()
end

function CrossPVPFightMainLayer:_registerBtnEvents()
	-- 排行榜
	self:registerBtnClickEvent("Button_Rank", function()
		local tLayer = require("app.scenes.crosspvp.CrossPVPRoomRankLayer").create(self._nStage, self._nRoom, self._isAudience, self._nSelfScore, self._nSelfRank)
		if tLayer then
			uf_sceneManager:getCurScene():addChild(tLayer)
		end
	end)

	-- 开关弹幕
	self:registerCheckboxEvent("CheckBox_Barrage", function ( checkBox, type, isCheck )
		local selectedState = checkBox:getSelectedState()
		if selectedState then
			-- 开弹幕
			if self._tBSLayer then
				self._tBSLayer:setVisible(true)
				self:showWidgetByName("Button_Barrage", true)
			end
		else
			-- 关弹幕
			if self._tBSLayer then
				self._tBSLayer:setVisible(false)
				self:showWidgetByName("Button_Barrage", false)
			end
		end
	end)
	-- self:setCheckStatus(1, "CheckBox_Barrage")
	self:getCheckBoxByName("CheckBox_Barrage"):setSelectedState(true)

	self:registerBtnClickEvent("Button_Barrage", function()
		if self._isBSOnCD then
			G_MovingTip:showMovingTip(G_lang:get("LANG_CROSS_PVP_BULLET_SCREENT_ON_CD"))
			return
		end
		local CrossPVPSendBulletScreenLayer = require("app.scenes.crosspvp.CrossPVPSendBulletScreenLayer")
		CrossPVPSendBulletScreenLayer.create(self._nStage)
	end)

	self:_handlerClickArena()

	-- 布阵
	self:registerBtnClickEvent("Button_Lineup", function()
		require("app.scenes.hero.HerobuZhengLayer").showBuZhengLayer()
	end)
end

function CrossPVPFightMainLayer:_addBulletScreen()
	if not self._isOpenBS then
		return
	end

	local CrossPVPShowBulletScreenLayer = require("app.scenes.crosspvp.CrossPVPShowBulletScreenLayer")
	if not self._tBSLayer then
		self._tBSLayer = CrossPVPShowBulletScreenLayer.create(self._nStage)
		self:addChild(self._tBSLayer)
	end
end

function CrossPVPFightMainLayer:_updateBSCD()
	local nCDTime = G_ServerTime:getTime() - G_Me.crossPVPData:getLastSendBSTime()
--	__Log("-- G_Me.crossPVPData:getLastSendBSTime() = %d", G_Me.crossPVPData:getLastSendBSTime())
	local nLeftCD = math.max(0, self._tBSTmpl.cold_time - nCDTime)
	if nLeftCD > 0 then
		-- 显示CD时间
		self:showWidgetByName("Image_SendBS", false)
		self:showWidgetByName("Label_SendBSCD", true)
		local _, _, nMin, nSec = self:_formatTime(nLeftCD)
		CommonFunc._updateLabel(self, "Label_SendBSCD", {text=string.format("%02d:%02d", nMin, nSec)})
		self._isBSOnCD = true
	else
		self:showWidgetByName("Image_SendBS", true)
		self:showWidgetByName("Label_SendBSCD", false)
		self._isBSOnCD = false
	end
end

function CrossPVPFightMainLayer:_onSendBulletScreenSucc()
	self:_updateBSCD()
end

-- 将秒转化为时、分、秒
function CrossPVPFightMainLayer:_formatTime(nTotalSecond)
	local nDay = math.floor(nTotalSecond / 24 / 3600)
	local nHour = math.floor((nTotalSecond - nDay*24*3600) / 3600)
	local nMinute = math.floor((nTotalSecond - nDay*24*3600 - nHour*3600) / 60)
	local nSeceod = (nTotalSecond - nDay*24*3600 - nHour*3600) % 60
	return nDay, nHour, nMinute, nSeceod
end

function CrossPVPFightMainLayer:_handlerClickArena()
	-- 点击6个坑位
	for i=1, ARENA_MAX do
		self:registerBtnClickEvent(string.format("Button_Stage%d", i), function()
			if self._isAudience then
				G_MovingTip:showMovingTip(G_lang:get("LANG_CROSS_PVP_YOU_ARE_AN_AUDIENCE"))
				return
			end

			local tArenaData = self._tArenaDataList[i]
			if tArenaData then
				-- 先判断自己的攻击CD是否到了
				if self:_playerAttackCDFinished() then
					-- 再判断坑位的保护时间是否到了
					if self:_arenaProtectCDFinished(i) then
					--	__Log("-- 坑位有人，2个CD时间都到了, 并且自己不在坑上")
						if self._nSelfFlag == 0 then
					--		__Log("-- self._nSelfFlag = %d, tArenaData._nFlag = %d", self._nSelfFlag, tArenaData._nFlag)
							G_HandlersManager.crossPVPHandler:sendCrossPvpBattle(self._nStage, self._nRoom, tArenaData._nFlag)
							-- 记录对手的信息
							local tEnemyInfo = {}
							tEnemyInfo._szName = tArenaData._szName or ""
							tEnemyInfo._nBaseId = tArenaData._nBaseId or 1
							self._tEnemyInfo = tEnemyInfo
						else
							if self:_isSelfInThisArena(tArenaData._nSId, tArenaData._nUId) then
								G_MovingTip:showMovingTip(G_lang:get("LANG_CROSS_PVP_DONOT_FIGHT_SELF"))
							else
								G_MovingTip:showMovingTip(G_lang:get("LANG_CROSS_PVP_COULD_NOT_CHANGE_ARENA"))
							end
						end
					else
						G_MovingTip:showMovingTip(G_lang:get("LANG_CROSS_PVP_PROTECT_CD_NOT_FINISHED"))
					end
				else
					-- 提示玩家攻击CD未到时
					G_MovingTip:showMovingTip(G_lang:get("LANG_CROSS_PVP_ATTACK_CD_NOT_FINISHED"))
				end
			else
				-- 现在坑位没人，只要判断自己攻击CD是否到了
				if self:_playerAttackCDFinished() then
				--	__Log("-- 坑位没人, 我的攻击CD到了, 还有自己不能在坑上")
				--	__Log("-- self._nStage = %s, self._nRoom = %s, self._tFlagList[%s] = %s", tostring(self._nStage), tostring(self._nRoom), tostring(i), tostring(self._tFlagList[i]))
					if self._nSelfFlag == 0 then
						G_HandlersManager.crossPVPHandler:sendCrossPvpBattle(self._nStage, self._nRoom, self._tFlagList[i])
					else
						G_MovingTip:showMovingTip(G_lang:get("LANG_CROSS_PVP_COULD_NOT_CHANGE_ARENA"))
					end
				else
					-- 提示玩家攻击CD未到时
					G_MovingTip:showMovingTip(G_lang:get("LANG_CROSS_PVP_ATTACK_CD_NOT_FINISHED"))
				end
			end
		end)
	end
end

function CrossPVPFightMainLayer:_loadMap()
	local tMapLayer = CCSGUIReaderEx:shareReaderEx():widgetFromJsonFile("ui_layout/crosspvp_CrossPVPFightMapLayer.json")
    self:addWidget(tMapLayer)
    self._tScrollView = self:getScrollViewByName("ScrollView_Knight")
    self._tInnerContainer = self._tScrollView:getInnerContainer()
    self._tMapLayer = tMapLayer 	
end

function CrossPVPFightMainLayer:_addTimer()
	if not self._tEngagedTimer then
		self._tEngagedTimer = G_GlobalFunc.addTimer(1, function(dt)
			self:_roundEndCountDown()
			self:_updateArenaCDTime()
			self:_updateAttackCDTime()
			self:_sendToGetRoomRank(dt)
			self:_updateBSCD()
		end)
	end
end

function CrossPVPFightMainLayer:_removeTimer()
	if self._tEngagedTimer then
		G_GlobalFunc.removeTimer(self._tEngagedTimer)
		self._tEngagedTimer = nil
	end
end

-- sp1 坑位
-- sp2 占坑时间
function CrossPVPFightMainLayer:_packArenaData(tData)
	assert(tData)

	local tArenaData = {}
	tArenaData._nFlag = tData.sp1
	tArenaData._nSId = tData.sid
	tArenaData._nUId = tData.id
	tArenaData._szName = ""
	tArenaData._nEngagedTime = 0
	tArenaData._nBaseId = 0
	tArenaData._nDressId = 0

	if rawget(tData, "name") then
		tArenaData._szName = tData.name
	end
	-- 占坑时间
	if rawget(tData, "sp2") then
		tArenaData._nEngagedTime = tData.sp2
	end
	if rawget(tData, "main_role") then
		tArenaData._nBaseId = tData.main_role
	end
	if rawget(tData, "dress_id") then
		tArenaData._nDressId = tData.dress_id
	end

	return tArenaData
end

function CrossPVPFightMainLayer:_onUpdateArena(tData)
	if tData.stage ~= self._nStage and tData.room ~= self._nRoom then
		return
	end

	assert(tData and tData.arena and tData.arena.sp1)

	-- 被系统T和被人T或占空坑
	local nIndex = self:_getArenaIndexByFlag(tData.arena.sp1)

	-- 判断玩家自己的情况
	if self._nSelfFlag == 0 then
		if self:_isSelfInThisArena(tData.arena.sid, tData.arena.id) then
		--	__Log("-- 哈哈哈，我在坑上, ServerId = %d, UserId = %d", G_PlatformProxy:getLoginServer().id, G_Me.userData.id)
			self._nSelfFlag = tData.arena.sp1
		end
	else
		-- 这个数据是这个坑位的，若sid和uid有一个不同，则表示我被T下坑位了
		if self._nSelfFlag == tData.arena.sp1 then
			if not self:_isSelfInThisArena(tData.arena.sid, tData.arena.id) then
		--		__Log("-- 妈蛋，我被T下坑了")
				self._nSelfFlag = 0
			end
		end
	end

	if tData.type == 0 then --初始化状态,可能有人，也可能没人
		local tArenaData = self:_packArenaData(tData.arena)
		if tArenaData._nSId == 0 and tArenaData._nUId == 0 then
			-- 坑位没人
			self._tArenaDataList[nIndex] = nil
			self:_onUpdateArenaWithIndex(nIndex)
		else
			self._tArenaDataList[nIndex] = tArenaData
			self:_onUpdateArenaWithIndex(nIndex, tArenaData)
		--	__Log("-- 1.占坑时间 = %d, 现在的系统时间 = %d, 差值是 = %d", tArenaData._nEngagedTime, G_ServerTime:getTime(), tArenaData._nEngagedTime - G_ServerTime:getTime())
		end
	elseif tData.type == 1 then -- 被系统T
		self._tArenaDataList[nIndex] = nil
		self:_onUpdateArenaWithIndex(nIndex)
	elseif tData.type == 2 then -- 占了空坑或被人T
		local tOld = self._tArenaDataList[nIndex]

		local tArenaData = self:_packArenaData(tData.arena)
		self._tArenaDataList[nIndex] = tArenaData
		self:_onUpdateArenaWithIndex(nIndex, tArenaData)
	--	__Log("-- 1.占坑时间 = %d, 现在的系统时间 = %d, 差值是 = %d", tArenaData._nEngagedTime, G_ServerTime:getTime(), tArenaData._nEngagedTime - G_ServerTime:getTime())
		if tOld then
			local tUserOld = {}
			tUserOld.base_id = tOld._nBaseId
			tUserOld.dress_base = tOld._nDressId

			local tUserNew = {}
			tUserNew.base_id = tArenaData._nBaseId
			tUserNew.dress_base = tArenaData._nDressId
			self:playDefierAnimation(nIndex, tUserNew, tUserOld, true, nil)
		else
			self:_handlerFlyEngagedScore()
		end
	end
end

-- 坑位时间到自动被T，和被别人T,2种情况的更新, 下坑的人才会收到这条flush
function CrossPVPFightMainLayer:_onUpdateArenaSpecial(tData)
	if tData.stage ~= self._nStage and tData.room ~= self._nRoom then
		return
	end

	if not rawget(tData, "arena") then
		assert(false, "S2C_FlushCrossPvpSpecific arena is needed")
	end

	-- 判断玩家自己的情况
	if self._nSelfFlag == 0 then
		if self:_isSelfInThisArena(tData.arena.sid, tData.arena.id) then
	--		__Log("-- 哈哈哈，我在坑上, ServerId = %d, UserId = %d", G_PlatformProxy:getLoginServer().id, G_Me.userData.id)
			self._nSelfFlag = tData.arena.sp1
		end
	else
		-- 这个数据是这个坑位的，若sid和uid有一个不同，则表示我被T下坑位了
		if self._nSelfFlag == tData.arena.sp1 then
			if not self:_isSelfInThisArena(tData.arena.sid, tData.arena.id) then
	--			__Log("-- 妈蛋，我被T下坑了")
				self._nSelfFlag = 0
			end
		end 
	end

	-- 0是不应该存在的值
	assert(tData.type ~= 0, "0是不应该存在的值")

	local nIndex = self:_getArenaIndexByFlag(tData.arena.sp1)
	assert(nIndex)
	if tData.type == 1 then     -- 被系统T
		-- 清空坑位
		self:_onUpdateArenaWithIndex(nIndex)
		-- 清理坑位数据缓存
		self._tArenaDataList[nIndex] = nil
	elseif tData.type == 2 then -- 被玩家T
		-- 坑位数据被替换更新
		local tOld = self._tArenaDataList[nIndex]

		local tArenaData = self:_packArenaData(tData.arena)
		self._tArenaDataList[nIndex] = tArenaData

		self:_onUpdateArenaWithIndex(nIndex, tArenaData)
	--	__Log("-- 2.占坑时间 = %d, 现在的系统时间 = %d, 差值是 = %d", tArenaData._nEngagedTime, G_ServerTime:getTime(), tArenaData._nEngagedTime - G_ServerTime:getTime())
		if tOld then
			local tUserOld = {}
			tUserOld.base_id = tOld._nBaseId
			tUserOld.dress_base = tOld._nDressId

			local tUserNew = {}
			tUserNew.base_id = tArenaData._nBaseId
			tUserNew.dress_base = tArenaData._nDressId
			self:playDefierAnimation(nIndex, tUserNew, tUserOld, true, nil)
		else
		--	self:_handlerFlyEngagedScore()
		end
	end
end

-- 更新一个arena, 也可以恢复到无人占领状态
function CrossPVPFightMainLayer:_onUpdateArenaWithIndex(nIndex, tArenaData)
	if type(nIndex) ~= "number" then
        assert(false, "nIndex should be a number")
        return
	end
	if type(nIndex) == "number" and (nIndex < 0 or nIndex > ARENA_MAX) then
        assert(false, "nIndex should be a number between [1, 6]")
        return
	end
	
	-- 如果tArenaData为nil, 则为清理坑位操作
	local panelPlayerHead = self:getPanelByName(string.format("Panel_%d_Player", nIndex))
	assert(panelPlayerHead)
	if not tArenaData then
		self:showWidgetByName(string.format("Image_di%d", nIndex), false)
		self:showWidgetByName(string.format("Image_di%d_NotEngaged", nIndex), true)

		-- 玩家名字显示“无人占领”
		CommonFunc._updateLabel(self, string.format("Label_Stage%d_NotEngaged", nIndex), {text=G_lang:get("LANG_CROSS_PVP_ARENA_NOT_ENGAGED"), color=Colors.darkColors.TIPS_02, stroke=Colors.strokeBrown})
		-- 每个坑位占领后，占领时间倒计时
		CommonFunc._updateLabel(self, string.format("Label_Stage%d_Desc", nIndex), {text="", stroke=Colors.strokeBrown})
		-- 删掉头像
		if self._tHeadList[nIndex] then
			if self._tBreathList[nIndex] then
				self._tBreathList[nIndex]:stop()
				self._tBreathList[nIndex] = nil
			end
			self._tHeadList[nIndex]:removeFromParentAndCleanup(true)
			self._tHeadList[nIndex] = nil
		end
		return
	end

	-- 坑位有人占领
	self:showWidgetByName(string.format("Image_di%d", nIndex), true)
	self:showWidgetByName(string.format("Image_di%d_NotEngaged", nIndex), false)

	local nQuality = 1
	local nResId = 10011
	local tKnightTmpl = knight_info.get(tArenaData._nBaseId)
	if tKnightTmpl then
		nQuality = tKnightTmpl.quality
	--	nResId = tKnightTmpl.res_id 
		nResId = G_Me.dressData:getDressedResidWithDress(tArenaData._nBaseId, tArenaData._nDressId) --10011
	end

	-- 更新新上垒的玩家的名字
	CommonFunc._updateLabel(self, string.format("Label_Stage%d_PlayerName", nIndex), {text=""..tArenaData._szName, color=Colors.qualityColors[nQuality]})

	-- 玩家形象
	local bNeedPlayerHead = true
	if panelPlayerHead then
		panelPlayerHead:setScale(0.35)
		if bNeedPlayerHead then
			-- 如果有，就先删掉，方便显示新的头像
			if self._tHeadList[nIndex] then
				if self._tBreathList[nIndex] then
					self._tBreathList[nIndex]:stop()
					self._tBreathList[nIndex] = nil
				end
				self._tHeadList[nIndex]:removeFromParentAndCleanup(true)
				self._tHeadList[nIndex] = nil
			end
			if not self._tHeadList[nIndex] and not self._tBreathList[nIndex] then
				self._tHeadList[nIndex] = KnightPic.createKnightPic(nResId, panelPlayerHead, "head", true)
				self._tBreathList[nIndex] = EffectSingleMoving.run(panelPlayerHead, "smoving_idle", nil, {position=true}, 1+ math.floor(math.random()*20))
			end
		else
			if self._tHeadList[nIndex] then
				if self._tBreathList[nIndex] then
					self._tBreathList[nIndex]:stop()
					self._tBreathList[nIndex] = nil
				end
				self._tHeadList[nIndex]:removeFromParentAndCleanup(true)
				self._tHeadList[nIndex] = nil
			end
		end
	end
end

-- 将所有坑位置为“无人占领”状态
function CrossPVPFightMainLayer:_clearTotalArenas()
	for i=1, ARENA_MAX do
		self:_onUpdateArenaWithIndex(i)
	end
end

-- 一轮干架结束时间倒计时
function CrossPVPFightMainLayer:_roundEndCountDown()
	local begin, close = G_Me.crossPVPData:getStageTime(CrossPVPConst.STAGE_FIGHT)
	local szTime = CrossPVPCommon.getFormatLeftTime(close)

	CommonFunc._updateLabel(self, "Label_EndTime", {visible=true})
	CommonFunc._updateLabel(self, "Label_Time", {text=szTime})
    local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
        self:getLabelByName('Label_EndTime'),
        self:getLabelByName('Label_Time'),
    }, "L")
    self:getLabelByName('Label_EndTime'):setPositionXY(alignFunc(1))
    self:getLabelByName('Label_Time'):setPositionXY(alignFunc(2))   
end

-- 每x秒拉一次房间排行榜
function CrossPVPFightMainLayer:_sendToGetRoomRank(dt)
	if self._nGetRoomRankTime < GET_RANK_TIME_MAX then
		self._nGetRoomRankTime = self._nGetRoomRankTime + dt
	else
		self._nGetRoomRankTime = 0
		if G_NetworkManager:isConnected() then
            G_HandlersManager.crossPVPHandler:sendGetCrossPvpRank(self._nStage, self._nRoom)
        end
	end
end

-- 更新房间前6名的分数
function CrossPVPFightMainLayer:_onUpdateTopSix(tData)
	local tRankList = {}
	for i, v in ipairs(tData.ranks) do
		local tRank = {}
		tRank._szName = v.name
		tRank._nScore = v.sp1
		tRank._nQuality = 7
		tRank._nSId = v.sid
		tRank._nUId = v.id
		local tKnightTmpl = knight_info.get(v.main_role)
		if tKnightTmpl then
			tRank._nQuality = tKnightTmpl.quality
		end
		table.insert(tRankList, #tRankList + 1, tRank)
	end
	local function sortFunc(tRank1, tRank2)
		return tRank1._nScore > tRank2._nScore
	end
	table.sort(tRankList, sortFunc)

	for i=1, ARENA_MAX do
		local tRank = tRankList[i]
		if tRank then
			CommonFunc._updateLabel(self, string.format("Label_Rank%d_Rank", i), {text=i.."."})
			CommonFunc._updateLabel(self, string.format("Label_Rank%d_PlayerName", i), {text=tRank._szName, color=Colors.qualityColors[tRank._nQuality]})
			CommonFunc._updateLabel(self, string.format("Label_Rank%d_Score", i), {text=G_lang:get("LANG_CROSS_PVP_SCORE_NUM", {num=tRank._nScore})})
		else
			CommonFunc._updateLabel(self, string.format("Label_Rank%d_Rank", i), {text=""})
			CommonFunc._updateLabel(self, string.format("Label_Rank%d_PlayerName", i), {text=""})
			CommonFunc._updateLabel(self, string.format("Label_Rank%d_Score", i), {text=""})
		end
	end

	local hasMyRank = false
	for i=1, #tRankList do
		local tRank = tRankList[i]
		if tostring(G_PlatformProxy:getLoginServer().id) == tostring(tRank._nSId) and tostring(G_Me.userData.id) == tostring(tRank._nUId) then 
			hasMyRank = true
			self._nSelfRank = i
		--	self._nSelfScore = tRank._nScore
			self:_updateSelfRoomRank()
		end
	end
	if not hasMyRank then
		self._nSelfRank = 0
		self:_updateSelfRoomRank()
	end
end

-- 因为后端传来的坑位号是唯一的，所以要算一下坑位的index
function CrossPVPFightMainLayer:_getArenaIndexByFlag(nFlag)
	if type(nFlag) ~= "number" then
		assert(false, "nFlag must be a number type")
		return 1
	end
	local nIndex = nFlag % ARENA_MAX
	nIndex = nIndex ~= 0 and nIndex or ARENA_MAX
	return nIndex
end

function CrossPVPFightMainLayer:_onEnagedArenaOrOpenBattleScene(tData)
	if rawget(tData, "method") then
		if tData.method == 0 then	--自己被坑位上的对手击败了
			if rawget(tData, "report") then
				self:_onOpenBattleScene(tData)
			end
		elseif tData.method == 1 then  -- 1代表自己击败别人
			if rawget(tData, "report") then
				self:_onOpenBattleScene(tData)
			end
		elseif tData.method == 2 then -- 2代表自己占领了一个空的坑

		end
	end

	-- 玩家有攻打操作了，要记下这个时间
	G_Me.crossPVPData:setLastAttackArenaTime(G_ServerTime:getTime())
end

-- 打开战斗场景
function CrossPVPFightMainLayer:_onOpenBattleScene(msg)
	local couldSkip = true
    local scene = nil
    local function showFunction( ... )
    	scene = require("app.scenes.crosspvp.CrossPVPBattleScene").new(msg, couldSkip, self._tEnemyInfo)
        uf_sceneManager:pushScene(scene)
        self._tEnemyInfo = {}
    end
    local function finishFunction( ... )
    	if scene ~= nil then
    		scene:play()
    	end
    end
    G_Loading:showLoading(showFunction, finishFunction)
end

-- 更新坑位CD时间，时间到，服务器会主动推协议，让玩家下坑
function CrossPVPFightMainLayer:_updateArenaCDTime()
	for i=1, ARENA_MAX do
		local tArenaData = self._tArenaDataList[i]
		if tArenaData then
			-- 下坑剩余时间
			local nLeftTime = math.max(0, tArenaData._nEngagedTime + ENGAGED_TIME_MAX - G_ServerTime:getTime())
			local nIndex = i
			local tCurColor = nil
			local szText = ""
			-- 若坑位处在保护时间，要用红色显示（坑位换人）
			if self:_arenaProtectCDFinished(i) then
				tCurColor = Colors.darkColors.TIPS_01
				szText = G_lang:get("LANG_CROSS_PVP_ENGAGED_TIME_COUNT_DOWN", {num=nLeftTime})
			else
				-- 保护中
				tCurColor = Colors.qualityColors[6]
				szText = G_lang:get("LANG_CROSS_PVP_ENGAGED_TIME_COUNT_DOWN_PROTECTED", {num=nLeftTime - 50})
			end
			CommonFunc._updateLabel(self, string.format("Label_Stage%d_Desc", nIndex), {text=szText, color=tCurColor})
		end
	end
end

-- 判断自己的攻打
function CrossPVPFightMainLayer:_playerAttackCDFinished()
	local nLastTime = G_Me.crossPVPData:getLastAttackArenaTime()
	local isFinish = false
	if G_ServerTime:getTime() - nLastTime >= PLAYER_ATTACK_CD then
        isFinish = true
	end
	return isFinish
end

-- 坑位是否出了保护时间
function CrossPVPFightMainLayer:_arenaProtectCDFinished(nIndex)
	local tArenaData = self._tArenaDataList[nIndex]
	if not tArenaData then
		return true
	end
	if G_ServerTime:getTime() - tArenaData._nEngagedTime >= ARENA_PROTECT_CD then
		return true
	else
		return false
	end
	return false
end

-- 更新自己的攻打时间
function CrossPVPFightMainLayer:_updateAttackCDTime()
	if self._isAudience then
		return
	end

	local nLastTime = G_Me.crossPVPData:getLastAttackArenaTime()
	local nLeftCD = math.max(0, nLastTime + PLAYER_ATTACK_CD - G_ServerTime:getTime()) 

	if not self._bAttackCDFinished then
		CommonFunc._updateLabel(self, "Label_AttackCD", {})
		CommonFunc._updateLabel(self, "Label_AttackCD_Time", {text=G_lang:get("LANG_CROSS_PVP_ENGAGED_TIME_COUNT_DOWN", {num=nLeftCD})})
		local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
	        self:getLabelByName('Label_AttackCD'),
	        self:getLabelByName('Label_AttackCD_Time'),
	    }, "C")
	    self:getLabelByName('Label_AttackCD'):setPositionXY(alignFunc(1))
	    self:getLabelByName('Label_AttackCD_Time'):setPositionXY(alignFunc(2))   
	    self:showWidgetByName("Image_TimeBg2", true)
	else
		self:showWidgetByName("Image_TimeBg2", false)
	end
	self._bAttackCDFinished = (nLeftCD == 0) and true or false
end

-- 更新玩家的积分，后端会主动推
function CrossPVPFightMainLayer:_onUpdateSelfInfo(tData)
	nPreScore = self._nSelfScore or 0
	local nScore = 0
	if rawget(tData, "score") then
		nScore = tData.score
		self._nSelfScore = nScore
	end

--	CommonFunc._updateLabel(self, "Label_CurScore_Value", {text=nScore})
	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_CROSS_PVP_UPDATE_SELF_ROOM_SCORE, nil, false, self._nSelfScore)

	self:_flyScore(math.max(0, nScore - nPreScore), nPreScore, nScore)

	self:_getEngagedScore(math.max(0, nScore - nPreScore))
end

function CrossPVPFightMainLayer:_flyScore(nAddScore, nPreScore, nCurScore)
	local function onUpdate()
		self:_playAddScoreAction(nPreScore, nCurScore)
	end

	if not self._labelAddScore then
		local label = G_GlobalFunc.createGameLabel("+"..nAddScore, 22, Colors.qualityColors[2], nil)
		label:setAnchorPoint(ccp(0, 0.5))
		label:setPositionXY(110, 15)
		local tParent = self:getLabelByName("Label_CurScore")
		tParent:addChild(label)
		self._labelAddScore = label
	end
	self._labelAddScore:stopAllActions()
	self._labelAddScore:setOpacity(255)
	self._labelAddScore:setText("+"..nAddScore)

	local actDelay = CCDelayTime:create(1)
	local actHide = CCFadeOut:create(0.2)

	local tArray = CCArray:create()
	tArray:addObject(actDelay)
	tArray:addObject(actHide)

	local actSeq = CCSequence:create(tArray)
	self._labelAddScore:runAction(actSeq)

	self:_playAddScoreAction(nPreScore, nCurScore)
end

-- 从坑位上飞积分
function CrossPVPFightMainLayer:_getEngagedScore(nAddScore)
	-- 如果nAddScore大于50分，则是上坑所得的积分
	if nAddScore >= 50 then
		self._bEngagedArena = true
		self._nEngagedScore = nAddScore
	else
		self:_flyScoreFromArena(nAddScore)
	end
end

function CrossPVPFightMainLayer:_flyScoreFromArena(nAddScore)
	if self._nSelfFlag == 0 then
		return
	end
	local nIndex = self:_getArenaIndexByFlag(self._nSelfFlag)
	local tParent =  self:getPanelByName(string.format("Panel_%d", nIndex))
	if not tParent then
		return
	end

	local flyText = nil
	local function removeSelf()
		-- if flyText then
		-- 	flyText:removeFromParentAndCleanup(true)
		-- 	flyText = nil
		-- end
	end

	flyText = FlyText.new(removeSelf, 0.6) 
	local szFlyText = "+"..nAddScore
	flyText:addNormalText(szFlyText, Colors.darkColors.ATTRIBUTE, nil, nil, ccp(40, -25), 50)
	flyText:play()
	flyText:setZOrder(120)
	tParent:addNode(flyText)

	--addNormalText( desc, clr, destCtrl, offset, startPos, fontSize)
end

function CrossPVPFightMainLayer:_handlerFlyEngagedScore()
	if self._bEngagedArena and self._nEngagedScore ~= 0 then
		self:_flyScoreFromArena(self._nEngagedScore)
		self._bEngagedArena = false
		self._nEngagedScore = 0
	end
end

-- 自己在不在sid, uid对应的这个坑上
function CrossPVPFightMainLayer:_isSelfInThisArena(nSId, nUId)
	if tostring(G_PlatformProxy:getLoginServer().id) == tostring(nSId) and tostring(G_Me.userData.id) == tostring(nUId) then
		return true
	else
		return false
	end
end

-- 更新自己的房间排名
function CrossPVPFightMainLayer:_updateSelfRoomRank()
	if self._isAudience then
	--	self:showWidgetByName("Panel_TopField", false)
		self:showWidgetByName("Panel_TopScore", false)
		self:showWidgetByName("Panel_TopRank", false)
		return
	end
	local szShow = ""
	if self._nSelfRank == 0 then
		szShow = G_lang:get("LANG_REBEL_BOSS_NOT_ON_RANK_1")
		CommonFunc._updateLabel(self, "Label_CurRank_Value", {text=szShow})
		CommonFunc._updateLabel(self, "Label_CurScore_Value", {text=self._nSelfScore})
		return
	end
	local nRoomNum = self._tScheduleTmpl.rank_num
	if self._nSelfRank <= nRoomNum then
		szShow = G_lang:get("LANG_CROSS_PVP_COULD_PROMOTED", {num=self._nSelfRank})
	else
		szShow = G_lang:get("LANG_CROSS_PVP_COULD_NOT_PROMOTED", {num=self._nSelfRank})
	end
	
	-- 决赛的时候要特殊处理一下
	if G_Me.crossPVPData:getCourse() == CrossPVPConst.COURSE_FINAL then
		szShow = ""..self._nSelfRank
	end
	
	CommonFunc._updateLabel(self, "Label_CurRank_Value", {text=szShow})
end

function CrossPVPFightMainLayer:_addMapEffect()
	local bgImg = tolua.cast(UIHelper:seekWidgetByName(self._tMapLayer, "ImageView_BG"), "ImageView")
	assert(bgImg)
	local tParent = bgImg
	local EffectNode = require "app.common.effects.EffectNode"
	local eff = tParent:getNodeByTag(33)
	if not eff and require("app.scenes.mainscene.SettingLayer").showEffectEnable() then
		eff = EffectNode.new("effect_chibi", function(event, frameIndex)
			if event == "finish" then
	
			end
		end)
		eff:play()
		local tSize = tParent:getContentSize()
		eff:setPosition(ccp(tSize.width / 2, tSize.height / 2))
		eff:setScale(1/tParent:getScale())
		tParent:addNode(eff, 0, 33)
	end
end

function CrossPVPFightMainLayer:playDefierAnimation(nIndex, user01, user02, isLeft, callback)
	if type(nIndex) ~= "number" then
		return
	end

	local effectPanel = self:getPanelByName(string.format("Panel_%d_Player_0", nIndex))
	assert(effectPanel)

    if self._tKickAniList[nIndex] == nil then
        local isLeftString = (isLeft == true) and "left" or "right"
        local res01 = 0
        local res02 = 0
        local kni01 = knight_info.get(user01.base_id)
        if not kni01 then
            return
        end
        if user01.dress_base == 0 then
            res01 = kni01.res_id
        else  --时装
            res01 = G_Me.dressData:getDressedResidWithDress(user01.base_id,user01.dress_base)
        end

        local kni02 = knight_info.get(user02.base_id)
        if not kni02 then
            return
        end
        if user02.dress_base == 0 then
            res02 = kni02.res_id
        else  --时装
            res02 = G_Me.dressData:getDressedResidWithDress(user02.base_id,user02.dress_base)
        end


        local kni01 = knight_info.get(id01)
        local kni02 = knight_info.get(id02)
        self._tKickAniList[nIndex] = require("app.scenes.crosspvp.CrossPVPKickAnimation").create(res01, res02, isLeftString, function() 
        	self:showWidgetByName(string.format("Panel_%d_Player", nIndex), true)
            if callback ~= nil then 
                callback() 
            end
            self._tKickAniList[nIndex]:removeFromParentAndCleanup(true)
            self._tKickAniList[nIndex] = nil
        end)
        self:showWidgetByName(string.format("Panel_%d_Player", nIndex), false)
        effectPanel:addNode(self._tKickAniList[nIndex])
    end

end

return CrossPVPFightMainLayer