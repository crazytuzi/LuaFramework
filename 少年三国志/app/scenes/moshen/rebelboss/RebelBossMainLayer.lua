

local ALIGN_CENTER = "align_center"
local ALIGN_LEFT = "align_left"
local ALIGN_RIGHT = "align_right"

require ("app.cfg.basic_figure_info")
local VipConst = require("app.const.VipConst")
local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")
local MoShenConst = require("app.const.MoShenConst")
local RebelBossPurchaseLayer = require("app.scenes.moshen.rebelboss.RebelBossPurchaseLayer")
local EffectNode = require "app.common.effects.EffectNode"
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

local RebelBossMainLayer = class("RebelBossMainLayer", UFCCSNormalLayer)

local DESC_STAGE = {
	OPEN = 1,
	CLOSE = 2,
}

local LAYER_TAG = {
     HONOR_RANK_TAG = 1001,
     HARM_RANK_TAG = 1002,
     AWARD_LIST_TAG = 1003,
     BOSS_REPORT_TAG = 1004,
}

local KILL_EFFECT_TAG = 33

function RebelBossMainLayer.create(nStage, ...)
	return RebelBossMainLayer.new("ui_layout/moshen_RebelBossMainLayer.json", nil, nStage, ...)
end

function RebelBossMainLayer:ctor(json, param, nStage, ...)
	self.super.ctor(self, json, param, ...)

	self._nCurStage = nStage or MoShenConst.REBEL_BOSS_STAGE.START
	-- 总荣誉排行榜是不是正在moving
	self._isMoving = false
	self._nDescState = DESC_STAGE.OPEN
    self._tAttackBoss = nil -- 结束状态，这个值为nil
    self._tKnifeEffect = nil -- 结束状态，这个值为nil

    self._nSendTime = G_ServerTime:getTime()
    self._couldSend = true
    -- 提前1秒可以发战斗请求
    self._couldChallenge = false

    self:_init()
end

function RebelBossMainLayer:onLayerEnter()
    -- 第一次进入主界面
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_REBEL_BOSS_ENTER_MAIN_LAYER, self._initLayer, self)
    -- 打开战斗场景
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_REBEL_BOSS_OPEN_BATTLE_SCENE, self._playKillBossAnimation, self)
    -- 每隔5秒更新一下场景
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_REBEL_BOSS_UPDATE_MAIN_LAYER_EACH_5_SECONDS, self._refreshMainLayer, self)
    -- 购买挑战数成功
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_REBEL_BOSS_PURCHASE_CHALLENGE_TIME_SUCC, self._onBuyChallengeTimeSucc, self)
    -- 自己阵营荣誉top5
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_REBEL_BOSS_GET_HONOR_RANK, self._onGetHonorTop5Succ, self)
    -- 更新奖励按钮上的红点
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_REBEL_BOSS_SHOW_AWARD_TIPS, self._showAwardTips, self)
    -- 获取挑战次数恢复时间的时间戳
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_REBEL_BOSS_UPDATE_CHALLENGE_TIME_RECOVER, self._showChallengeTimerRecover, self)
    -- 打开排行榜后，更新自己的信息
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_REBEL_BOSS_UPDATE_MY_HONOR, self._onUpdateMyHonor, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_REBEL_BOSS_UPDATE_MY_MAXHARM, self._onUpdateMyMaxHarm, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_REBEL_BOSS_UPDATE_MY_LEGION_RANK, self._onUpdateMyLegionRank, self)
    -- 收到军团奖励信息后，回调
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_REBEL_BOSS_SHOW_QUICK_ENTER, self._onOpenAwardLayer, self)
    

    --[[
    EVENT_REBEL_BOSS_UPDATE_MY_HONOR = "event_rebel_boss_update_my_honor", --更新主界面自己的荣誉值及排行
    EVENT_REBEL_BOSS_UPDATE_MY_MAXHARM = "event_rebel_boss_update_my_maxharm", --更新主界面自己的最大伤害值及排行
    EVENT_REBEL_BOSS_UPDATE_MY_LEGION_RANK = "event_rebel_boss_update_my_legion_rank", --更新主界面自己的最大伤害值及排行
    ]]
	
    -- 进界面的时候请求一下数据
    G_HandlersManager.moshenHandler:sendEnterRebelBossUI()
    G_HandlersManager.moshenHandler:sendRebelBossAwardInfo(1)
    G_HandlersManager.moshenHandler:sendRebelBossAwardInfo(2)
    G_HandlersManager.moshenHandler:sendRebelBossCorpAwardInfo()
    -- 发送协议，拉取到下一个挑战次数恢复时间戳
    G_HandlersManager.moshenHandler:sendFlushBossACountTime()
end

function RebelBossMainLayer:onLayerExit()
    self:_clearAllTimers()
	uf_eventManager:removeListenerWithTarget(self)
    G_flyAttribute._clearFlyAttributes()

    if self._tRecoverChallengeTimeTimer then
        G_GlobalFunc.removeTimer(self._tRecoverChallengeTimeTimer)
        self._tRecoverChallengeTimeTimer = nil
    end
end

function RebelBossMainLayer:_clearAllTimers()
    if self._tTimer then
        G_GlobalFunc.removeTimer(self._tTimer)
        self._tTimer = nil
    end
    if self._tCountDownTimer then
        G_GlobalFunc.removeTimer(self._tCountDownTimer)
        self._tCountDownTimer = nil
    end
    if self._tReviveTimer then
        G_GlobalFunc.removeTimer(self._tReviveTimer)
        self._tReviveTimer = nil
    end
    if self._tReStartTimer then
        G_GlobalFunc.removeTimer(self._tReStartTimer)
        self._tReStartTimer = nil
    end
end

function RebelBossMainLayer:_init()
    -- 我的个人信息
    CommonFunc._updateLabel(self, "Label_Honor", {text=""})
    CommonFunc._updateLabel(self, "Label_Honor_Num", {text=""})
    CommonFunc._updateLabel(self, "Label_Hurt", {text=""})
    CommonFunc._updateLabel(self, "Label_Hurt_Num", {text=""})
    CommonFunc._updateLabel(self, "Label_LegionRank", {text=""})
    CommonFunc._updateLabel(self, "Label_LegionRank_Num", {text=""})

    -- 开始
    CommonFunc._updateLabel(self, "Label_BossName_Start", {text=""})
    CommonFunc._updateLabel(self, "Label_BossLevel_Start", {text=""})
    CommonFunc._updateLabel(self, "Label_Escape_Time", {text=""})
    CommonFunc._updateLabel(self, "Label_Escape", {text=""})
    CommonFunc._updateLabel(self, "Label_Break", {text=""})
    CommonFunc._updateLabel(self, "Label_Attack_Heigher", {text=""})
    CommonFunc._updateLabel(self, "Label_Life", {text=""})
    CommonFunc._updateLabel(self, "Label_Life_Num", {text=""})
    CommonFunc._updateLabel(self, "Label_Challenge", {text=""})
    CommonFunc._updateLabel(self, "Label_ChallengeCount", {text=""})
    CommonFunc._updateLabel(self, "Label_RenewTips", {text=""})

    -- 开始阶段，但是Boss处于死亡状态
    CommonFunc._updateLabel(self, "Label_By", {text=""})
    CommonFunc._updateLabel(self, "Label_PlayerName", {text=""})
    CommonFunc._updateLabel(self, "Label_BossKill", {text=""})
    CommonFunc._updateLabel(self, "Label_CountDownTime", {text=""})
    CommonFunc._updateLabel(self, "Label_BossCome", {text=""})

    -- 结束
    CommonFunc._updateLabel(self, "Label_BossName", {text=""})
    CommonFunc._updateLabel(self, "Label_BossLevel", {text=""})
    CommonFunc._updateLabel(self, "Label_ChampionName_1", {text=""})
    CommonFunc._updateLabel(self, "Label_ChampionHonor_1", {text=""})
    CommonFunc._updateLabel(self, "Label_ChampionName_2", {text=""})
    CommonFunc._updateLabel(self, "Label_ChampionHonor_2", {text=""})
    CommonFunc._updateLabel(self, "Label_ChampionName_3", {text=""})
    CommonFunc._updateLabel(self, "Label_ChampionHonor_3", {text=""})
    CommonFunc._updateLabel(self, "Label_ChampionName_4", {text=""})
    CommonFunc._updateLabel(self, "Label_ChampionHonor_4", {text=""})
    CommonFunc._updateLabel(self, "Label_TimeTips", {text=""})
  
    self:showWidgetByName("Panel_Finish", false)
    self:showWidgetByName("Panel_Start", false)
    self:showWidgetByName("Panel_Start", false)
    self:showWidgetByName("Panel_ChallengeCount", false)
    self:showWidgetByName("Panel_TotalHonorRank", false)

    -- 奖励按钮上的红点
    self:showWidgetByName("Image_AwardTips", false)
end

function RebelBossMainLayer:_initWidgets()
	local tInitInfo = G_Me.moshenData:getInitializeInfo()

    if tInitInfo then
        self._nCurStage = tInitInfo._nState
        self:_updateMyInfo()
        self:_initCommonPart()
        self:showWithStage(self._nCurStage)
        if not self._tTimer then
            self._tTimer = G_GlobalFunc.addTimer(1, handler(self, self._sendToRefreshView))
        end

        self:_showAwardTips()
    end
end

-- 荣誉排行榜
function RebelBossMainLayer:_onClickHonorRank()
	local tLayer = require("app.scenes.moshen.rebelboss.RebelBossRankListLayer").create(MoShenConst.REBEL_BOSS_RANK_MODE.HONOR)
	if tLayer then
		uf_sceneManager:getCurScene():addChild(tLayer)
        tLayer:setTag(LAYER_TAG.HONOR_RANK_TAG)
	end
end

-- 伤害排行榜
function RebelBossMainLayer:_onClickHurtRank()
	local tLayer = require("app.scenes.moshen.rebelboss.RebelBossRankListLayer").create(MoShenConst.REBEL_BOSS_RANK_MODE.MAX_HARM)
    if tLayer then
        uf_sceneManager:getCurScene():addChild(tLayer)
        tLayer:setTag(LAYER_TAG.HARM_RANK_TAG)
    end
end

-- 奖励
function RebelBossMainLayer:_onClickAwardList()
	local tLayer = require("app.scenes.moshen.rebelboss.RebelBossAwardListLayer").create()
	if tLayer then
		uf_sceneManager:getCurScene():addChild(tLayer)
        tLayer:setTag(LAYER_TAG.AWARD_LIST_TAG)
	end
end

function RebelBossMainLayer:_onClickHelp()
	require("app.scenes.common.CommonHelpLayer").show({
		{title=G_lang:get("LANG_REBEL_BOSS_HELP_TITLE1"), content=G_lang:get("LANG_REBEL_BOSS_HELP_CONTENT1")},
        {title=G_lang:get("LANG_REBEL_BOSS_HELP_TITLE2"), content=G_lang:get("LANG_REBEL_BOSS_HELP_CONTENT2")},
    } )
end

function RebelBossMainLayer:_onClickBack()
	uf_sceneManager:replaceScene(require("app.scenes.moshen.MoShenScene").new())
end

-- 
function RebelBossMainLayer:_initCommonPart()
    self:registerBtnClickEvent("Button_Help",  handler(self, self._onClickHelp))
	self:registerBtnClickEvent("Button_Back",  handler(self, self._onClickBack))
	self:registerBtnClickEvent("Button_HonorRank",  handler(self, self._onClickHonorRank))
	self:registerBtnClickEvent("Button_HurtRank",   handler(self, self._onClickHurtRank))
	self:registerBtnClickEvent("Button_Award", handler(self, self._onClickAwardList))
end

-- 显示玩家的个人信息
function RebelBossMainLayer:_updateMyInfo()
    local tInitInfo = G_Me.moshenData:getInitializeInfo()
    if tInitInfo then
        local nMyGroup = G_Me.moshenData:getMyGroup()
        if nMyGroup == 0 then
            self:showWidgetByName("Panel_MyInfo", false)
            return
        end

        local showMyInfo = not (tInitInfo._nTotalHonor == 0)
        if not showMyInfo then
            self:showWidgetByName("Panel_MyInfo", false)
            return
        else
            self:showWidgetByName("Panel_MyInfo", true)
        end
        
        local nHonor = tInitInfo._nTotalHonor
        local nMaxHurt = tInitInfo._nMaxHarm
        local nLegionRank = tInitInfo._nLegionRank

        -- 荣誉
        local szHonorRank = ""
        if tInitInfo._nGroupTotalHonorRank == 0 then
            szHonorRank = G_lang:get("LANG_REBEL_BOSS_NOT_ON_RANK")
        else
            szHonorRank = G_lang:get("LANG_REBEL_BOSS_RANK_NUMBER", {num=tInitInfo._nGroupTotalHonorRank})
        end
        CommonFunc._updateLabel(self, "Label_Honor", {text=G_lang:get("LANG_REBEL_BOSS_MY_HONOR"), stroke=Colors.strokeBrown})
        CommonFunc._updateLabel(self, "Label_Honor_Num", {text=G_GlobalFunc.ConvertNumToCharacter(nHonor) .. szHonorRank, stroke=Colors.strokeBrown})


        -- 最高伤害
        local szHarmRank = ""
        if tInitInfo._nGroupMaxHarmRank == 0 then
            szHarmRank = G_lang:get("LANG_REBEL_BOSS_NOT_ON_RANK")
        else
            szHarmRank = G_lang:get("LANG_REBEL_BOSS_RANK_NUMBER", {num=tInitInfo._nGroupMaxHarmRank})
        end
        CommonFunc._updateLabel(self, "Label_Hurt", {text=G_lang:get("LANG_REBEL_BOSS_MAX_HURT"), stroke=Colors.strokeBrown})
        CommonFunc._updateLabel(self, "Label_Hurt_Num", {text=G_GlobalFunc.ConvertNumToCharacter(nMaxHurt) .. szHarmRank, stroke=Colors.strokeBrown})

        -- 军团排行
        local szLegionaRank = ""
        if not G_Me.legionData:hasCorp() then
            szLegionaRank = G_lang:get("LANG_REBEL_BOSS_HAS_NO_LEGION")
        else
            if nLegionRank == 0 then
                szLegionaRank = G_lang:get("LANG_REBEL_BOSS_NOT_ON_RANK")
            else
                szLegionaRank = G_lang:get("LANG_REBEL_BOSS_RANK_NUMBER1", {num=nLegionRank})
            end
        end
        CommonFunc._updateLabel(self, "Label_LegionRank", {text=G_lang:get("LANG_REBEL_BOSS_LEGION_RANK"), stroke=Colors.strokeBrown})
        CommonFunc._updateLabel(self, "Label_LegionRank_Num", {text=szLegionaRank, stroke=Colors.strokeBrown})


        local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
            self:getLabelByName('Label_Honor'),
            self:getLabelByName('Label_Honor_Num'),
        }, "L")
        self:getLabelByName('Label_Honor'):setPositionXY(alignFunc(1))
        self:getLabelByName('Label_Honor_Num'):setPositionXY(alignFunc(2))    

        local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
            self:getLabelByName('Label_Hurt'),
            self:getLabelByName('Label_Hurt_Num'),
        }, "L")
        self:getLabelByName('Label_Hurt'):setPositionXY(alignFunc(1))
        self:getLabelByName('Label_Hurt_Num'):setPositionXY(alignFunc(2))

        local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
            self:getLabelByName('Label_LegionRank'),
            self:getLabelByName('Label_LegionRank_Num'),
        }, "L")
        self:getLabelByName('Label_LegionRank'):setPositionXY(alignFunc(1))
        self:getLabelByName('Label_LegionRank_Num'):setPositionXY(alignFunc(2))
    end
end

-- 更新自己的信息-荣誉值及排行
function RebelBossMainLayer:_onUpdateMyHonor(nHonorRank, nHonor)
    local nMyGroup = G_Me.moshenData:getMyGroup()
    if nMyGroup == 0 then
        return
    end

    local tInitInfo = G_Me.moshenData:getInitializeInfo()
    tInitInfo._nGroupTotalHonorRank = nHonorRank
    tInitInfo._nTotalHonor = nHonor

    -- 荣誉
    local szHonorRank = G_lang:get("LANG_REBEL_BOSS_NOT_ON_RANK")
    if nHonorRank ~= 0 then
        szHonorRank = G_lang:get("LANG_REBEL_BOSS_RANK_NUMBER", {num=nHonorRank})
    end
    CommonFunc._updateLabel(self, "Label_Honor", {text=G_lang:get("LANG_REBEL_BOSS_MY_HONOR"), stroke=Colors.strokeBrown})
    CommonFunc._updateLabel(self, "Label_Honor_Num", {text=G_GlobalFunc.ConvertNumToCharacter(nHonor) .. szHonorRank, stroke=Colors.strokeBrown})

    local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
        self:getLabelByName('Label_Honor'),
        self:getLabelByName('Label_Honor_Num'),
    }, "L")
    self:getLabelByName('Label_Honor'):setPositionXY(alignFunc(1))
    self:getLabelByName('Label_Honor_Num'):setPositionXY(alignFunc(2))   
end

-- 更新自己的信息-最大伤害值及排行
function RebelBossMainLayer:_onUpdateMyMaxHarm(nMaxHarmRank, nMaxHarm)
    local nMyGroup = G_Me.moshenData:getMyGroup()
    if nMyGroup == 0 then
        return
    end

    local tInitInfo = G_Me.moshenData:getInitializeInfo()
    tInitInfo._nGroupMaxHarmRank = nMaxHarmRank
    tInitInfo._nMaxHarm = nMaxHarm

    -- 最高伤害
    local szHarmRank = G_lang:get("LANG_REBEL_BOSS_NOT_ON_RANK")
    if nMaxHarmRank ~= 0 then
        szHarmRank = G_lang:get("LANG_REBEL_BOSS_RANK_NUMBER", {num=nMaxHarmRank})
    end
    CommonFunc._updateLabel(self, "Label_Hurt", {text=G_lang:get("LANG_REBEL_BOSS_MAX_HURT"), stroke=Colors.strokeBrown})
    CommonFunc._updateLabel(self, "Label_Hurt_Num", {text=G_GlobalFunc.ConvertNumToCharacter(nMaxHarm) .. szHarmRank, stroke=Colors.strokeBrown})

    local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
        self:getLabelByName('Label_Hurt'),
        self:getLabelByName('Label_Hurt_Num'),
    }, "L")
    self:getLabelByName('Label_Hurt'):setPositionXY(alignFunc(1))
    self:getLabelByName('Label_Hurt_Num'):setPositionXY(alignFunc(2))
end

-- 更新自己的信息-军团排行排行
function RebelBossMainLayer:_onUpdateMyLegionRank(nLegionRank)
    local nMyGroup = G_Me.moshenData:getMyGroup()
    if nMyGroup == 0 then
        return
    end

    local tInitInfo = G_Me.moshenData:getInitializeInfo()
    tInitInfo._nLegionRank = nLegionRank

    -- 军团排行
    local szLegionaRank = ""
    if not G_Me.legionData:hasCorp() then
        szLegionaRank = G_lang:get("LANG_REBEL_BOSS_HAS_NO_LEGION")
    else
        if nLegionRank == 0 then
            szLegionaRank = G_lang:get("LANG_REBEL_BOSS_NOT_ON_RANK")
        else
            szLegionaRank = G_lang:get("LANG_REBEL_BOSS_RANK_NUMBER1", {num=nLegionRank})
        end
    end
    CommonFunc._updateLabel(self, "Label_LegionRank", {text=G_lang:get("LANG_REBEL_BOSS_LEGION_RANK"), stroke=Colors.strokeBrown})
    CommonFunc._updateLabel(self, "Label_LegionRank_Num", {text=szLegionaRank, stroke=Colors.strokeBrown})

    local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
        self:getLabelByName('Label_LegionRank'),
        self:getLabelByName('Label_LegionRank_Num'),
    }, "L")
    self:getLabelByName('Label_LegionRank'):setPositionXY(alignFunc(1))
    self:getLabelByName('Label_LegionRank_Num'):setPositionXY(alignFunc(2))
end


function RebelBossMainLayer:showWithStage(nStage)
	if nStage == MoShenConst.REBEL_BOSS_STAGE.FINISH then
		self:showWidgetByName("Panel_Finish", true)
		self:showWidgetByName("Panel_Start", false)
        self:showWidgetByName("Panel_ChallengeCount", false)
		self:_updateFinishStage()
	elseif nStage == MoShenConst.REBEL_BOSS_STAGE.START then
		self:showWidgetByName("Panel_Finish", false)
		self:showWidgetByName("Panel_Start", true)
        self:showWidgetByName("Panel_ChallengeCount", true)
		self:_updateStartStage()
	end
end

-- 结束阶段
function RebelBossMainLayer:_updateFinishStage()
    self:showWidgetByName("Panel_Finish", true)
    local tInitInfo = G_Me.moshenData:getInitializeInfo()
    if tInitInfo then
        local tBossTmpl = rebel_boss_info.get(tInitInfo._tBoss._nId)
        local szBossName = tBossTmpl.name
        local szBossLevel = G_lang:get("LANG_REBEL_BOSS_BOSS_LEVEL", {num=tInitInfo._tBoss._nLevel})

        CommonFunc._updateLabel(self, "Label_BossName", {text=szBossName, stroke=Colors.strokeBrown})
        CommonFunc._updateLabel(self, "Label_BossLevel", {text=szBossLevel, stroke=Colors.strokeBrown})


        local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
            self:getLabelByName('Label_BossName'),
            self:getLabelByName('Label_BossLevel'),
        }, "C")
        self:getLabelByName('Label_BossName'):setPositionXY(alignFunc(1))
        self:getLabelByName('Label_BossLevel'):setPositionXY(alignFunc(2))

        -- 4个阵营荣誉第1的家伙
        for i=1, table.nums(MoShenConst.GROUP) do
            local nGroup = i
            local tRankItem = tInitInfo._tGroupFirstRankList[nGroup]
            if tRankItem then
                CommonFunc._updateLabel(self, "Label_ChampionName_" .. nGroup, {text=tRankItem._szName, visible=true})
                CommonFunc._updateLabel(self, "Label_ChampionHonor_" .. nGroup, {text=G_GlobalFunc.ConvertNumToCharacter(tRankItem._nValue) .. G_lang:get("LANG_REBEL_BOSS_WORLD_HONOR"), visible=true})
            else
                CommonFunc._updateLabel(self, "Label_ChampionName_" .. nGroup, {text=G_lang:get("LANG_REBEL_BOSS_WAITING_FOR_YOU")})
                CommonFunc._updateLabel(self, "Label_ChampionHonor_" .. nGroup, {text="", visible=false})
            end
        end

        -- 自己阵营荣誉前5
        self:_updateHonorTopFive()

        -- 开启时间提示
        CommonFunc._updateLabel(self, "Label_TimeTips", {text=G_lang:get("LANG_REBEL_BOSS_OPEN_TIME_TIPS"), stroke=Colors.strokeBrown})

        -- boss形象
        local nBaseId = rebel_boss_info.get(tInitInfo._tBoss._nId).res_id
        if self.imgHead then
            self.imgHead:removeFromParentAndCleanup(true)
            self.imgHead = nil 
        end
        if not self.imgHead then
            self.imgHead = require("app.scenes.common.KnightPic").createKnightPic(nBaseId, self:getPanelByName("Panel_Knight"), "head", true)
            self:getPanelByName("Panel_Knight"):setScale(0.72)
        end

        self:registerBtnClickEvent("Button_TotalHonorRank", handler(self, self._onClickTotalHonorRank))

        self:showWidgetByName("Panel_TotalHonorRank", false)

        -- 处于结束状态，到下一个开始的时间的倒计时
        if not self._tReStartTimer then
            self._tReStartTimer = G_GlobalFunc.addTimer(1, function()
                -- _nEndTime是下一个活动开启的时间
                local nLastTime = math.max(0, tInitInfo._nEndTime + 1 - G_ServerTime:getTime())
                if nLastTime == 0 then
                    if self._tReStartTimer then
                        G_GlobalFunc.removeTimer(self._tReStartTimer)
                        self._tReStartTimer = nil
                    end
                    G_Me.moshenData:clearAllRebelBossData()
                    self:_closeSubLayer()
                    G_HandlersManager.moshenHandler:sendEnterRebelBossUI()
                    -- 发送协议，拉取到下一个挑战次数恢复时间戳
                    G_HandlersManager.moshenHandler:sendFlushBossACountTime()
                end
            end)
        end

    end
end

-- 开始通用部分
function RebelBossMainLayer:_updateStartCommonPart()
    local tInitInfo = G_Me.moshenData:getInitializeInfo()
    local tBoss = tInitInfo._tBoss
    local tBossTmpl = rebel_boss_info.get(tBoss._nId)

	-- boss名字和等级
    local szBossName = ""
    local szBossLevel = G_lang:get("LANG_REBEL_BOSS_BOSS_LEVEL", {num=0})
    if tBoss then
       local tBossTmpl = rebel_boss_info.get(tBoss._nId)
	   szBossName = tBossTmpl.name
	   szBossLevel = G_lang:get("LANG_REBEL_BOSS_BOSS_LEVEL", {num=tBoss._nLevel})
    end

	CommonFunc._updateLabel(self, "Label_BossName_Start", {text=szBossName, color=Colors.darkColors.TITLE_01, stroke=Colors.strokeBrown, size=2})
	CommonFunc._updateLabel(self, "Label_BossLevel_Start", {text=szBossLevel, stroke=Colors.strokeBrown})

	local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
        self:getLabelByName('Label_BossName_Start'),
        self:getLabelByName('Label_BossLevel_Start'),
    }, "C")
    self:getLabelByName('Label_BossName_Start'):setPositionXY(alignFunc(1))
    self:getLabelByName('Label_BossLevel_Start'):setPositionXY(alignFunc(2))

    -- 自己阵营荣誉前5
    self:_updateHonorTopFive()

    if self._tAttackBoss then
        self._tAttackBoss:removeFromParentAndCleanup(true)
        self._tAttackBoss = nil
    end

	-- boss形象
    local panelKinghtStart = self:getPanelByName("Panel_Knight_Start")
	local nBaseId = tBossTmpl.res_id or 13025
    if not self._tAttackBoss then
        self._tAttackBoss = require("app.scenes.common.KnightPic").createKnightButton(nBaseId, panelKinghtStart, "head", self, handler(self, self._onClickKnight), true)
	    self:getPanelByName("Panel_Knight_Start"):setScale(0.8)

        -- 加呼吸效果
        self._tAttackBoss._tBreateEffect = breathEffect
        if not self._tAttackBoss._tBreateEffect then
            self._tAttackBoss._tBreateEffect = EffectSingleMoving.run(panelKinghtStart, "smoving_idle", nil, {position=true}, 1+ math.floor(math.random()*20))
        end  
    end
    -- 加小刀特效
    if not self._tKnifeEffect then
        self._tKnifeEffect = EffectNode.new("effect_knife", function(event, frameIndex) end)
        self._tKnifeEffect:setPositionY(150)
        self._tKnifeEffect:setScale(1 / panelKinghtStart:getScale())
        panelKinghtStart:addNode(self._tKnifeEffect, 1)
        self._tKnifeEffect:play()
    end

    self._tAttackBoss:showAsGray(false)
    self._tKnifeEffect:setVisible(true)
    self:getImageViewByName("Image_AlreadyKilled"):setVisible(false)

    
    self:registerBtnClickEvent("Button_Lineup", handler(self, self._onClickLineup))
    self:registerBtnClickEvent("Button_Report", handler(self, self._onClickReport))
end

function RebelBossMainLayer:_updateBossShake(dt)
    if self.shake:isDone() == false then
        self.shake:step(1)
    else
        self.shake:stop()
        self.shake = nil
        self:unscheduleUpdate()
    end
end

-- 正式开始阶段
function RebelBossMainLayer:_updateStartStage()
    local tInitInfo = G_Me.moshenData:getInitializeInfo()
    assert(tInitInfo)

    if tInitInfo then
    	self:_updateStartCommonPart()

        self:showWidgetByName("Panel_BossNotDead", false)
        self:showWidgetByName("Panel_BossDead", false)

    	-- boss生命值
    	local nCurHp = tInitInfo._tBoss._nCurHp
    	local nTotalHp = tInitInfo._tBoss._nMaxHp
    	CommonFunc._updateLabel(self, "Label_Life", {text=G_lang:get("LANG_REBEL_BOSS_LIFE"), stroke=Colors.strokeBrown})
    	CommonFunc._updateLabel(self, "Label_Life_Num", {text=G_GlobalFunc.ConvertNumToCharacter(nCurHp).."/"..G_GlobalFunc.ConvertNumToCharacter(nTotalHp), stroke=Colors.strokeBrown})
        --
        local hpBar = self:getLoadingBarByName("ProgressBar_Blood")
        if hpBar then
            hpBar:setPercent(nCurHp / nTotalHp * 100)
        end
     
        -- 挑战次数
        local nChallengeTime = G_Me.moshenData:getChallengeTime()
        CommonFunc._updateLabel(self, "Label_Challenge", {text=G_lang:get("LANG_REBEL_BOSS_CHALLENGE_TIME"), stroke=Colors.strokeBrown})
        CommonFunc._updateLabel(self, "Label_ChallengeCount", {text=nChallengeTime, stroke=Colors.strokeBrown})
        -- 每小时恢复1点
    --    CommonFunc._updateLabel(self, "Label_RenewTips", {text=G_lang:get("LANG_REBEL_BOSS_HOUR_RENEW"), stroke=Colors.strokeBrown})

        local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
            self:getLabelByName('Label_Life'),
            self:getLabelByName('Label_Life_Num'),
        }, "C")
        self:getLabelByName('Label_Life'):setPositionXY(alignFunc(1))
        self:getLabelByName('Label_Life_Num'):setPositionXY(alignFunc(2))

        local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
            self:getLabelByName('Label_Challenge'),
            self:getLabelByName('Label_ChallengeCount'),
        }, "C")
        self:getLabelByName('Label_Challenge'):setPositionXY(alignFunc(1))
        self:getLabelByName('Label_ChallengeCount'):setPositionXY(alignFunc(2))
    end
 

    -- 活动结束倒计时,切换到结束状态
    if not self._tCountDownTimer then
        self._tCountDownTimer = G_GlobalFunc.addTimer(1, function(dt)
            local nLeftTime = math.max(0, tInitInfo._nEndTime - G_ServerTime:getTime())
            if nLeftTime == 0 then
                -- 活动结束 
                if self._tCountDownTimer then
                    G_GlobalFunc.removeTimer(self._tCountDownTimer)
                    self._tCountDownTimer = nil
                end
                if self._tRecoverChallengeTimeTimer then
                    G_GlobalFunc.removeTimer(self._tRecoverChallengeTimeTimer)
                    self._tRecoverChallengeTimeTimer = nil
                end
                self:_closeSubLayer()
                G_HandlersManager.moshenHandler:sendEnterRebelBossUI()
                G_HandlersManager.moshenHandler:sendRebelBossAwardInfo(1)
                G_HandlersManager.moshenHandler:sendRebelBossAwardInfo(2)
                G_HandlersManager.moshenHandler:sendRebelBossCorpAwardInfo()
            end
        end)
    end

    self:_updateBossWithBossState()

    self:registerBtnClickEvent("Button_TotalHonorRank", handler(self, self._onClickTotalHonorRank))
    self:registerBtnClickEvent("Button_AddChallengeTimes", handler(self, self._onClickBuyChallengeTimes))
end


function RebelBossMainLayer:_addRecoverChallengeTimeTimer()
    local tInitInfo = G_Me.moshenData:getInitializeInfo()
    if tInitInfo._nState == MoShenConst.REBEL_BOSS_STAGE.FINISH then
        if self._tRecoverChallengeTimeTimer then
            G_GlobalFunc.removeTimer(self._tRecoverChallengeTimeTimer)
            self._tRecoverChallengeTimeTimer = nil
        end
        return 
    end

    -- 挑战次数恢复时间倒计时
    local tBasicFightInfo = basic_figure_info.get(6)
    local nMaxLimit = tBasicFightInfo.max_limit
    if G_Me.moshenData:getChallengeTime() < nMaxLimit then
        local nRecoverTime = G_Me.moshenData:getRecoverTimestamp()

        if not self._tRecoverChallengeTimeTimer then
            self._tRecoverChallengeTimeTimer = G_GlobalFunc.addTimer(1, function(dt)
 
                local function timeFormat(nTotalSecond)
                    local nDay = math.floor(nTotalSecond / 24 / 3600)
                    local nHour = math.floor((nTotalSecond - nDay*24*3600) / 3600)
                    local nMinute = math.floor((nTotalSecond - nDay*24*3600 - nHour*3600) / 60)
                    local nSeceod = (nTotalSecond - nDay*24*3600 - nHour*3600) % 60
                    return nDay, nHour, nMinute, nSeceod
                end

                local nLastTime = math.mod(nRecoverTime+1 - G_ServerTime:getTime(), tBasicFightInfo.unit_time)
                local nDay, nHour, nMin, nSec = timeFormat(nLastTime)
                if nMin ~= 0 then
                    CommonFunc._updateLabel(self, "Label_RenewTips", {text=G_lang:get("LANG_REBEL_BOSS_RECOVER_CHALLENGE_TIME1", {minute=nMin, second=nSec}), stroke=Colors.strokeBrown})
                else
                    CommonFunc._updateLabel(self, "Label_RenewTips", {text=G_lang:get("LANG_REBEL_BOSS_RECOVER_CHALLENGE_TIME2", {second=nSec}), stroke=Colors.strokeBrown})
                end
                local nLastTime = math.max(0, nLastTime)
                if nLastTime == 0 then
                    G_HandlersManager.moshenHandler:sendEnterRebelBossUI()
                    -- 发送协议，拉取到下一个挑战次数恢复时间戳
                    G_HandlersManager.moshenHandler:sendFlushBossACountTime()
                    if self._tRecoverChallengeTimeTimer then
                        G_GlobalFunc.removeTimer(self._tRecoverChallengeTimeTimer)
                        self._tRecoverChallengeTimeTimer = nil 
                    end
                end

            end)
        end
    else
        if self._tRecoverChallengeTimeTimer then
            G_GlobalFunc.removeTimer(self._tRecoverChallengeTimeTimer)
            self._tRecoverChallengeTimeTimer = nil
        end
        CommonFunc._updateLabel(self, "Label_RenewTips", {text=G_lang:get("LANG_REBEL_BOSS_CHALLENGE_TIME_IS_FULL"), stroke=Colors.strokeBrown})
    end
end


-- 自己阵营荣誉前5
function RebelBossMainLayer:_updateHonorTopFive()
    local nMode = MoShenConst.REBEL_BOSS_RANK_MODE.HONOR
    local nMyGroup = G_Me.moshenData:getMyGroup()
    local tRankList = G_Me.moshenData:getRankList(nMode, nMyGroup)
    if nMyGroup == 0 or table.nums(tRankList) == 0 then
        self:showWidgetByName("Panel_TotalHonorRank", false)
        return 
    else
        self:showWidgetByName("Panel_TotalHonorRank", true)
    end

    self:getImageViewByName("Image_110"):loadTexture(G_Path.getGroupHonorImage(nMyGroup))

    local tTopFive = {}
    for i=1, 5 do
        local tRankItem = tRankList[i]
        if tRankItem then
            table.insert(tTopFive, #tTopFive+1, tRankItem)
        end
    end

    for i=1, 5 do
        local nRank = 0
        local szName = ""
        local szHonor = ""
        local tRankItem = tTopFive[i]
        local panel = self:getPanelByName("Panel_111_" .. i)
        if tRankItem then
            panel:setVisible(true)
            nRank = tRankItem._nRank
            szName = tRankItem._szName
            szHonor = G_lang:get("LANG_REBEL_BOSS_HONOR_NUMBER", {num=G_GlobalFunc.ConvertNumToCharacter(tRankItem._nValue)})
        else
            nRank = i
            szName = G_lang:get("LANG_REBEL_BOSS_WAITING_FOR_YOU")
            szHonor = ""
        end

        CommonFunc._updateLabel(self, "Label_TotalHonorRank_"..nRank, {text=G_lang:get("LANG_REBEL_BOSS_RANK", {num=nRank}), stroke=Colors.strokeBrown})
        CommonFunc._updateLabel(self, "Label_PlayerName_"..nRank, {text=szName, stroke=Colors.strokeBrown})
        CommonFunc._updateLabel(self, "Label_TotalHonor_"..nRank, {text=szHonor, stroke=Colors.strokeBrown})

        local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
            self:getLabelByName("Label_PlayerName_"..nRank),
            }, "L")
        self:getLabelByName("Label_PlayerName_"..nRank):setPositionXY(alignFunc(1))
    end
end

function RebelBossMainLayer:_onClickLineup()
	G_SoundManager:playSound(require("app.const.SoundConst").GameSound.BUTTON_SHORT)
    require("app.scenes.hero.HerobuZhengLayer").showBuZhengLayer()
end

function RebelBossMainLayer:_onClickReport()
    local tLayer = require("app.scenes.moshen.rebelboss.RebelBossReportLayer").create()
    if tLayer then
        uf_sceneManager:getCurScene():addChild(tLayer)
        tLayer:setTag(LAYER_TAG.BOSS_REPORT_TAG)
    end
end

function RebelBossMainLayer:_onClickTotalHonorRank()
	self:_openAndCloseDesc()
end

function RebelBossMainLayer:_onClickBuyChallengeTimes()
    local nRemainPurTime = G_Me.moshenData:getRemainPurchaseTime()
    if nRemainPurTime == 0 then
        G_GlobalFunc.showVipNeedDialog(VipConst.REBELBOSS)
    else
        RebelBossPurchaseLayer.show()
    end
end

-- 确定购买挑战次数
function RebelBossMainLayer:_onConfirmBuyChallengeTimes()
    local nRemainPurTime = G_Me.moshenData:getRemainPurchaseTime()
    if nRemainPurTime > 0 then
        G_HandlersManager.moshenHandler:sendPurchaseAttackCount() 
    else
        G_MovingTip:showMovingTip(G_lang:get("LANG_REBEL_BOSS_CHALLENGE_PURCHASE_TIME_USEUP"))
    end
end

function RebelBossMainLayer:_onCancelBuyChallengeTimes()
 
end

-- 开始阶段，点击Boss,请求战斗
function RebelBossMainLayer:_onClickKnight(sender)
    -- 判断是否已经选择了阵营
    local tInitInfo = G_Me.moshenData:getInitializeInfo()
    local tBoss = tInitInfo._tBoss
    if tBoss._nCurHp > 0 then
        local nMyGroup = G_Me.moshenData:getMyGroup()
        if nMyGroup == 0 then
            self:_onOpenChooseGroupLayer()
        else
            -- 先判断有没有挑战次数了
            if G_Me.moshenData:getChallengeTime() > 0 then
                local nProduceTime = tBoss._nProduceTime
                G_HandlersManager.moshenHandler:sendChallengeRebelBoss(nProduceTime)
            else
                self:_onClickBuyChallengeTimes()
            end
        end
    else
        if self._couldChallenge then
            -- 先判断有没有挑战次数了
            if G_Me.moshenData:getChallengeTime() > 0 then
                local nProduceTime = tBoss._nProduceTime
                G_HandlersManager.moshenHandler:sendChallengeRebelBoss(nProduceTime)
            else
                self:_onClickBuyChallengeTimes()
            end
        else
            G_MovingTip:showMovingTip(G_lang:get("LANG_REBEL_BOSS_ALREADY_BE_KILLED"))
        end
    end
end


function RebelBossMainLayer:_openAndCloseDesc()
	if self._isMoving then
		return
	end
	self._isMoving = true
	local imgBg = self:getImageViewByName("Image_TotalHonorRankBG")
	local nWidth = imgBg:getSize().width
	local nPosY = imgBg:getPositionY()
	if self._nDescState == DESC_STAGE.OPEN then
		self._nDescState = DESC_STAGE.CLOSE

		-- 打开介绍
		local nMinX = imgBg:getPositionX()
		local nMaxX = nMinX + nWidth + 70

		local actMoveTo = CCMoveTo:create(0.2, ccp(nMaxX, nPosY))
		local actCallFunc = CCCallFunc:create(function()
			self._isMoving = false
		end)
		local arr = CCArray:create()
		arr:addObject(actMoveTo)
		arr:addObject(actCallFunc)
		local actSeq = CCSequence:create(arr)
		imgBg:runAction(actSeq)
	elseif self._nDescState == DESC_STAGE.CLOSE then
		self._nDescState = DESC_STAGE.OPEN

		-- 关闭介绍
		local nMaxX = imgBg:getPositionX()
		local nMinX = nMaxX - nWidth - 70

		local actMoveTo = CCMoveTo:create(0.2, ccp(nMinX, nPosY))
		local actCallFunc = CCCallFunc:create(function()
			self._isMoving = false
		end)
		local arr = CCArray:create()
		arr:addObject(actMoveTo)
		arr:addObject(actCallFunc)
		local actSeq = CCSequence:create(arr)
		imgBg:runAction(actSeq)
	end
end

function RebelBossMainLayer:_showDescOnEnter()
    local actCallFunc1 = CCCallFunc:create(function()
    	self:_openAndCloseDesc()
    end)
    local actDelay = CCDelayTime:create(3)
    local actCallFunc2 = CCCallFunc:create(function()
    	self:_openAndCloseDesc()
    	self._isFinishAutoShow = true
    end)

    local arr = CCArray:create()
    arr:addObject(actCallFunc1)
    arr:addObject(actDelay)
    arr:addObject(actCallFunc2)
    local actSeq = CCSequence:create(arr)
    self:runAction(actSeq)
end

-- 处理Boss死亡
function RebelBossMainLayer:_updateBossWithBossState()
    local tInitInfo = G_Me.moshenData:getInitializeInfo()
    local tBoss = tInitInfo._tBoss
    local nCurHp = tBoss._nCurHp

    self:showWidgetByName("Panel_BossNotDead", --[[nCurHp ~= 0]] false)
    self:showWidgetByName("Panel_BossDead", nCurHp == 0)

    if nCurHp ~= 0 then
        return
    end

    self._tAttackBoss:showAsGray(true)
    self._tKnifeEffect:setVisible(false)
    if self._tAttackBoss._tBreateEffect then
        self._tAttackBoss._tBreateEffect:stop()
        self._tAttackBoss._tBreateEffect = nil
    end
    self:getImageViewByName("Image_AlreadyKilled"):setVisible(true)


    -- Boss死了，Boss死亡时间戳后之后的第61秒，向服务器发请求
    local nReviveDis = 31
    if not self._tReviveTimer then
    --    __Log("开启一个复活计时器-----------------")
        self._tReviveTimer = G_GlobalFunc.addTimer(1, function()
            local nReviveTime = nReviveDis + tInitInfo._tBoss._nKillerTime
            local nDay, nHour, nMin, nSec = G_ServerTime:getLeftTimeParts(nReviveTime)
            CommonFunc._updateLabel(self, "Label_CountDownTime", {text=G_lang:get("LANG_REBEL_BOSS_SECOND_LATER", {num=nSec}), stroke=Colors.strokeBrown})
        
            local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
                self:getLabelByName('Label_CountDownTime'),
                self:getLabelByName('Label_BossCome'),
            }, "C")
            self:getLabelByName('Label_CountDownTime'):setPositionXY(alignFunc(1))
            self:getLabelByName('Label_BossCome'):setPositionXY(alignFunc(2))

            if math.max(0, nReviveTime - G_ServerTime:getTime()) <= 1 then
                self._couldChallenge = true
            else
                self._couldChallenge = false
            end

            if math.max(0, nReviveTime - G_ServerTime:getTime()) == 0  then
                if self._tReviveTimer then
                    G_GlobalFunc.removeTimer(self._tReviveTimer)
                    self._tReviveTimer = nil
                end
                G_HandlersManager.moshenHandler:sendEnterRebelBossUI()

                local nLastAttackIndex = G_Me.moshenData:getLastAttackIndex()
                G_HandlersManager.moshenHandler:sendRefreshRebelBoss(nLastAttackIndex)
            end
        end)
    end

    local nReviveTime = nReviveDis + tInitInfo._tBoss._nKillerTime
    local nDay, nHour, nMin, nSec = G_ServerTime:getLeftTimeParts(nReviveTime)

    -- 由XXX杀死
    CommonFunc._updateLabel(self, "Label_By", {text=G_lang:get("LANG_REBEL_BOSS_BY"), stroke=Colors.strokeBrown})
    CommonFunc._updateLabel(self, "Label_PlayerName", {text=tInitInfo._tBoss._szKillerName, stroke=Colors.strokeBrown})
    CommonFunc._updateLabel(self, "Label_BossKill", {text=G_lang:get("LANG_REBEL_BOSS_KILL"), stroke=Colors.strokeBrown})
    -- 60秒倒计时
    CommonFunc._updateLabel(self, "Label_CountDownTime", {text=G_lang:get("LANG_REBEL_BOSS_SECOND_LATER", {num=nSec}), stroke=Colors.strokeBrown})
    CommonFunc._updateLabel(self, "Label_BossCome", {text=G_lang:get("LANG_REBEL_BOSS_BOSS_COME"), stroke=Colors.strokeBrown})

    -- Boss死亡
    local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
        self:getLabelByName('Label_By'),
        self:getLabelByName('Label_PlayerName'),
        self:getLabelByName('Label_BossKill'),
    }, "C")
    self:getLabelByName('Label_By'):setPositionXY(alignFunc(1))
    self:getLabelByName('Label_PlayerName'):setPositionXY(alignFunc(2))
    self:getLabelByName('Label_BossKill'):setPositionXY(alignFunc(3))

    local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
        self:getLabelByName('Label_CountDownTime'),
        self:getLabelByName('Label_BossCome'),
    }, "C")
    self:getLabelByName('Label_CountDownTime'):setPositionXY(alignFunc(1))
    self:getLabelByName('Label_BossCome'):setPositionXY(alignFunc(2))

    self:_updateBossHp()
end

function RebelBossMainLayer:_updateBossHp()
    local tInitInfo = G_Me.moshenData:getInitializeInfo()
    if not tInitInfo then
        return
    end

    -- boss生命值
    local nCurHp = tInitInfo._tBoss._nCurHp
    local nTotalHp = tInitInfo._tBoss._nMaxHp
    CommonFunc._updateLabel(self, "Label_Life", {text=G_lang:get("LANG_REBEL_BOSS_LIFE"), stroke=Colors.strokeBrown})
    CommonFunc._updateLabel(self, "Label_Life_Num", {text=G_GlobalFunc.ConvertNumToCharacter(nCurHp).."/"..G_GlobalFunc.ConvertNumToCharacter(nTotalHp), stroke=Colors.strokeBrown})
    --
    local hpBar = self:getLoadingBarByName("ProgressBar_Blood")
    if hpBar then
        hpBar:setPercent(nCurHp / nTotalHp * 100)
    end

    local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
        self:getLabelByName('Label_Life'),
        self:getLabelByName('Label_Life_Num'),
    }, "C")
    self:getLabelByName('Label_Life'):setPositionXY(alignFunc(1))
    self:getLabelByName('Label_Life_Num'):setPositionXY(alignFunc(2))
end

function RebelBossMainLayer:_closeSubLayer()
    for key, val in pairs(LAYER_TAG) do
        local nTag = val
        local tLayer = uf_sceneManager:getCurScene():getChildByTag(nTag)
        if tLayer then
            tLayer:removeFromParentAndCleanup(true)
        end
    end
end

function RebelBossMainLayer:_showAwardTips()
    local hasAward = false
    for i=1, 3 do
        if G_Me.moshenData:hasRebelBossAward(i) then
            hasAward = true
            break
        end
    end
    self:showWidgetByName("Image_AwardTips", hasAward)
end

-----------------------------------------------------------------------------------
-- 事件回调

function RebelBossMainLayer:_initLayer()
    self:_clearAllTimers()
    -- 请求自己阵营的荣誉top5
    local nMyGroup = G_Me.moshenData:getMyGroup()
    if nMyGroup ~= 0 then
        G_HandlersManager.moshenHandler:sendRebelBossRank(MoShenConst.REBEL_BOSS_RANK_MODE.HONOR, nMyGroup)
    else
        self:_initWidgets()
    end
end

function RebelBossMainLayer:_onGetHonorTop5Succ()
    self:_initWidgets()
end

function RebelBossMainLayer:_onOpenChooseGroupLayer(sender)
    local tLayer = require("app.scenes.moshen.rebelboss.RebelBossChooseGroupLayer").create()
    if tLayer then
        uf_sceneManager:getCurScene():addChild(tLayer)
    end
end

-- 切换stage
function RebelBossMainLayer:_onChangeStage()
	self._nCurStage = (self._nCurStage == MoShenConst.REBEL_BOSS_STAGE.FINISH) and MoShenConst.REBEL_BOSS_STAGE.START or MoShenConst.REBEL_BOSS_STAGE.FINISH
end

function RebelBossMainLayer:_onUpdateWithEvent()
	if self._nCurStage == MoShenConst.REBEL_BOSS_STAGE.FINISH then

	elseif self._nCurStage == MoShenConst.REBEL_BOSS_STAGE.START then

	end
end

function RebelBossMainLayer:_playKillBossAnimation(msg)
    local EffectNode = require "app.common.effects.EffectNode"
    local eff = self._tAttackBoss:getNodeByTag(KILL_EFFECT_TAG)
    if not eff then
        eff = EffectNode.new("effect_killboss", function(event, frameIndex)
            if event == "finish" then
                self:_onOpenBattleScene(msg)
            end
        end)
        eff:setScale(1.5)
        eff:play()
        self._tAttackBoss:addNode(eff, 0, KILL_EFFECT_TAG)
    end

    if self.shake == nil then
        self.shake = require("app.common.action.Action").newShake(7, 15, 0)
        self.shake:startWithTarget(self._tAttackBoss)
        self:scheduleUpdate(handler(self, self._updateBossShake), 0)
    end
end

-- 打开战斗场景
function RebelBossMainLayer:_onOpenBattleScene(msg)
    local tInitInfo = G_Me.moshenData:getInitializeInfo()
    local nBossLevel = tInitInfo._tBoss._nLevel
    assert(nBossLevel)
    local couldSkip = true
    local scene = nil
    local function showFunction( ... )
        scene = require("app.scenes.moshen.rebelboss.RebelBossBattleScene").new(msg, couldSkip, nBossLevel)
        uf_sceneManager:replaceScene(scene)
    end
    local function finishFunction( ... )
        if scene ~= nil then
            scene:play()
        end
    end
    G_Loading:showLoading(showFunction, finishFunction)
end

function RebelBossMainLayer:_sendToRefreshView()
    if self._nCurStage == MoShenConst.REBEL_BOSS_STAGE.START then
        if not G_NetworkManager:isConnected() then
            return
        end
        local tInitInfo = G_Me.moshenData:getInitializeInfo()
        if tInitInfo and tInitInfo._tBoss._nCurHp == 0 then
            return
        end
        if not self._couldSend then
            return
        end

        if G_ServerTime:getTime() - self._nSendTime >= 6 then
            self._nSendTime = G_ServerTime:getTime()
            self._couldSend = false
            local nLastAttackIndex = G_Me.moshenData:getLastAttackIndex()
            G_HandlersManager.moshenHandler:sendRefreshRebelBoss(nLastAttackIndex)
        end
    end
end

-- 每5秒钟更新一下界面
function RebelBossMainLayer:_refreshMainLayer(data)
    self._nSendTime = G_ServerTime:getTime()
    self._couldSend = true
    local EffectNode = require "app.common.effects.EffectNode"

    if data.infos ~= nil and #data.infos ~= 0 then
        for i,v in ipairs(data.infos)do
            if v.name ~= G_Me.userData.name then
                local text = G_lang:get("LANG_REBEL_BOSS_HARM_VALUE",{name=v.name,value=v.harm})
                G_flyAttribute.doAddRichtext(text,22,Colors.uiColors.GREEN)
                -- Boss被打，播放一个特效
                if not self._tEff then
                    self._tEff = EffectNode.new("effect_killboss", function(event, frameIndex)
                        if event == "finish" then
                            self._tEff:removeFromParentAndCleanup(true)
                            self._tEff = nil
                        end
                    end)
                    self._tEff:setScale(1.5)
                    self._tEff:play()
                    self._tAttackBoss:addNode(self._tEff)
                end
            end
        end
        G_flyAttribute.play()
    end

    self:_updateBossHp()

    -- 更新Boss状态 
    self:_updateBossWithBossState()
end

function RebelBossMainLayer:_onBuyChallengeTimeSucc()
    local nChallengeTime = G_Me.moshenData:getChallengeTime()
    CommonFunc._updateLabel(self, "Label_ChallengeCount", {text=nChallengeTime, stroke=Colors.strokeBrown})

    local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
        self:getLabelByName('Label_Challenge'),
        self:getLabelByName('Label_ChallengeCount'),
    }, "C")
    self:getLabelByName('Label_Challenge'):setPositionXY(alignFunc(1))
    self:getLabelByName('Label_ChallengeCount'):setPositionXY(alignFunc(2))

    -- 发送协议，拉取到下一个挑战次数恢复时间戳
--    G_HandlersManager.moshenHandler:sendFlushBossACountTime()
end

function RebelBossMainLayer:_showChallengeTimerRecover() 
    self:_addRecoverChallengeTimeTimer()


    -- 更新现在的挑战次数
    local nChallengeTime = G_Me.moshenData:getChallengeTime()
    CommonFunc._updateLabel(self, "Label_ChallengeCount", {text=nChallengeTime, stroke=Colors.strokeBrown})

    local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
        self:getLabelByName('Label_Challenge'),
        self:getLabelByName('Label_ChallengeCount'),
    }, "C")
    self:getLabelByName('Label_Challenge'):setPositionXY(alignFunc(1))
    self:getLabelByName('Label_ChallengeCount'):setPositionXY(alignFunc(2))
end

function RebelBossMainLayer:_onOpenAwardLayer()
    local openAwardLayer = G_Me.moshenData:getEnterFromAwardShortcut()
    if openAwardLayer then
        local tLayer = uf_sceneManager:getCurScene():getChildByTag(LAYER_TAG.AWARD_LIST_TAG)
        if not tLayer then
            self:_onClickAwardList()
        end
    end
end

return RebelBossMainLayer