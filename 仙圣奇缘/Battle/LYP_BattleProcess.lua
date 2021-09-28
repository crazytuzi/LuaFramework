--------------------------------------------------------------------------------------
-- 文件名:	LYP_BattleProcess.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2013-12-28 17:01
-- 版  本:	1.0
-- 描  述:	战斗过程
-- 应  用:
---------------------------------------------------------------------------------------

CBattleProcess = class("CBattleProcess")
CBattleProcess.__index = CBattleProcess

function CBattleProcess:ctor()
	self.nAttackCount = 1
end

local nBattleCount = 1
local TbResouceRemove = {}
local nAnimationMaxRound = nil
local nTimeTurnEscape = 0.3


local function preLoadResouceByEffectID(nEffectID)
	if(nEffectID > 0)then
		local CSV_SkillLightEffect = g_DataMgr:getSkillLightEffectCsv(nEffectID )
		if(not CSV_SkillLightEffect or CSV_SkillLightEffect.Type == 2)then --不知道他以前为什么这样写，是不是粒子特效没有进行管理
			return
		end

		if(CSV_SkillLightEffect.Type == 1)then	--Effect_IOS\Skill路径下的cocos动画
			g_BattleResouce:LoadAnimationFile(getEffectSkillJson(CSV_SkillLightEffect.File))
		elseif(CSV_SkillLightEffect.Type == 2)then --Effect_IOS\Particle路径下的粒子动画
			--g_BattleResouce:LoadAnimationFile(getEffectSkillPlist(CSV_SkillLightEffect.File))
			--粒子特效暂时不加入缓存，因为没办法管理
		elseif(CSV_SkillLightEffect.Type == 3)then --CocoAnimation路径下的cocos动画
			g_BattleResouce:LoadAnimationFile(getCocoAnimationJson(CSV_SkillLightEffect.File))
		elseif(CSV_SkillLightEffect.Type == 4)then --Effect_IOS\SkillSpine路径下的cocos动画
			g_BattleResouce:LoadSpineFile(CSV_SkillLightEffect.File)
		end
	end
end

local function  preLoadResouceBySkill(CSV_SkillBase)
	preLoadResouceByEffectID(CSV_SkillBase.FireEffect)
	preLoadResouceByEffectID(CSV_SkillBase.FlyEffect)
	preLoadResouceByEffectID(CSV_SkillBase.AreaEffect)
	preLoadResouceByEffectID(CSV_SkillBase.HitEffect)
	
	if CSV_SkillBase.SelfStatusID > 0 and CSV_SkillBase.SelfStatusLevel > 0 then
		local CSV_SkillStatus = g_DataMgr:getSkillStatusCsv(CSV_SkillBase.SelfStatusID, CSV_SkillBase.SelfStatusLevel)
		preLoadResouceByEffectID(CSV_SkillStatus.LightEffect)
	end
	
	if CSV_SkillBase.TargetStatusID > 0 and CSV_SkillBase.SelfStatusLevel > 0 then
		local CSV_SkillStatus = g_DataMgr:getSkillStatusCsv(CSV_SkillBase.TargetStatusID, CSV_SkillBase.TargetStatusLevel)
		preLoadResouceByEffectID(CSV_SkillStatus.LightEffect)
	end
end

function preLoadResouce(GameFighter_Card)
	local nPos = GameFighter_Card.nPos
	TbBattleReport.tbSkillData[nPos] = {}

	local CSV_CardBase = GameFighter_Card.tbFighterBase
	local CSV_SkillBase = g_DataMgr:getSkillBaseCsv(CSV_CardBase.NormalSkillID)
	preLoadResouceBySkill(CSV_SkillBase)
	table.insert(TbBattleReport.tbSkillData[nPos], CSV_SkillBase)
	for i = 1, 3 do
		CSV_SkillBase = g_DataMgr:getSkillBaseCsv(CSV_CardBase["PowerfulSkillID"..i])
		preLoadResouceBySkill(CSV_SkillBase)
		table.insert(TbBattleReport.tbSkillData[nPos], CSV_SkillBase)
	end
	
	CSV_SkillBase = g_DataMgr:getSkillBaseCsv(CSV_CardBase.RestrikeSkillID)
	if CSV_CardBase.RestrikeSkillID ~= CSV_CardBase.NormalSkillID then
		preLoadResouceBySkill(CSV_SkillBase)
	end
	
	table.insert(TbBattleReport.tbSkillData[nPos], CSV_SkillBase)
end

function preLoadCommonSkillLightEffect()
	--Enum_SkillLightEffect枚举配置了战斗中要用到的通用动画
	for k, v in pairs (Enum_SkillLightEffect) do
		local CSV_SkillLightEffect = g_DataMgr:getSkillLightEffectCsv(v)
		if(CSV_SkillLightEffect.Type == 1)then	--Effect_IOS\Skill路径下的cocos动画
			g_BattleResouce:LoadAnimationFile(getEffectSkillJson(CSV_SkillLightEffect.File))
		elseif(CSV_SkillLightEffect.Type == 2)then --Effect_IOS\Particle路径下的粒子动画
			--g_BattleResouce:LoadAnimationFile(getEffectSkillPlist(CSV_SkillLightEffect.File))
			--粒子特效暂时不加入缓存，因为没办法管理
		elseif(CSV_SkillLightEffect.Type == 3)then --CocoAnimation路径下的cocos动画
			g_BattleResouce:LoadAnimationFile(getCocoAnimationJson(CSV_SkillLightEffect.File))
		elseif(CSV_SkillLightEffect.Type == 4)then --Effect_IOS\SkillSpine路径下的cocos动画
			g_BattleResouce:LoadSpineFile(CSV_SkillLightEffect.File)
		end
	end
end

function preLoadCommonBattleAni()
	--预加载战斗要用到的动画
	g_BattleResouce:LoadAnimationFile(getCocoAnimationJson("GOGOGO"))
	g_BattleResouce:LoadAnimationFile(getCocoAnimationJson("BattleStartKaiZhan"))
	g_BattleResouce:LoadAnimationFile(getCocoAnimationJson("BattleStartWord"))
	g_BattleResouce:LoadAnimationFile(getCocoAnimationJson("BattleStartRound"))
	g_BattleResouce:LoadAnimationFile(getCocoAnimationJson("BattleStartLetter"))
	g_BattleResouce:LoadAnimationFile(getCocoAnimationJson("BattleStart"))
	g_BattleResouce:LoadAnimationFile(getCocoAnimationJson("SkillPressEffect"))
	
	g_BattleResouce:LoadAnimationFile(getCocoAnimationJson("BattleFighterCursor"))
	g_BattleResouce:LoadAnimationFile(getCocoAnimationJson("BattleCurrentFighterA"))
	g_BattleResouce:LoadAnimationFile(getCocoAnimationJson("BattleCurrentFighterArrow"))
	g_BattleResouce:LoadAnimationFile(getCocoAnimationJson("EnergyNormal"))
	g_BattleResouce:LoadAnimationFile(getCocoAnimationJson("IconEffectCircle"))
	g_BattleResouce:LoadAnimationFile(getCocoAnimationJson("IconEffectCircleA"))
	g_BattleResouce:LoadAnimationFile(getCocoAnimationJson("EnergyRecover"))
end

function CBattleProcess:setLoadResouceCallBack(func)
	funcLoadResouce = func
end

function CBattleProcess:loadBattleBGMusic()
	TbBattleReport.msgBattleRounds = {}
	--背景图片
	TbBattleReport.TbBattleWnd.Scene:loadTexture(g_BattleData:getBackgroundPic(1))

	--背景音乐
	g_playSoundMusicBattle(g_BattleData:getBGMusic(), true)
end

function CBattleProcess:startSkillBattle(tbItem)

end

function CBattleProcess:startBattleProcess()
	nAnimationMaxRound = g_BattleData:getClientMaxRound()
	self.bIsRoundBegin = true
	self:processBattleRound()
end

function CBattleProcess:playFootStepSound(nSoudType)
	self.bIsStopStepSound = nil
	self.nSoundEffectID = nil
	if nSoudType == 1 then
		local function playSound()
			if self.bIsStopStepSound or not TbBattleReport then
				return true
			else
				self.nSoundEffectID = g_playSoundEffectBattle("Sound/Battle_FootStep.mp3")
			end
		end
		playSound()
		g_Timer:pushTimer(1.3, playSound)
		g_Timer:pushTimer(2.6, playSound)
	elseif nSoudType == 2 then
		local function playSoundSeveralTimes()
			local function playSoundOneTime()
				if self.bIsStopStepSound or not TbBattleReport then
					return true
				else
					self.nSoundEffectID = g_playSoundEffectBattle("Sound/Battle_FootStep.mp3")
				end
			end
			g_Timer:pushLimtCountTimer(5, 0.4, playSoundOneTime)
		end
		playSoundSeveralTimes()
		g_Timer:pushTimer(0.3, playSoundSeveralTimes)
	end
end

function CBattleProcess:createDefencerAndNpcFighter()
    local tbGameFighters_OnWnd = TbBattleReport.tbGameFighters_OnWnd
	for nPos, GameFighter_Defencer in pairs(tbGameFighters_OnWnd) do
		if nPos > 9 then
			if GameFighter_Defencer and GameFighter_Defencer ~= {} then
				GameFighter_Defencer:removeFromParentAndCleanup(true)
			end
			
			if TbBattleReport.tbGameFighters_OnWnd[nPos] and TbBattleReport.tbGameFighters_OnWnd[nPos]~= {} then
				TbBattleReport.tbGameFighters_OnWnd[nPos]:release()
				TbBattleReport.tbGameFighters_OnWnd[nPos] = nil
			end
		else
			if not self.bIsRoundBegin then
				GameFighter_Defencer:resetNewRoundInfo()
			end
		end
	end
    
    local tbFighterInfoList_Npc = g_BattleMgr:initNpcFightersNextRound()--防御方即怪物方
    local tbFighterInfoList_Def = g_BattleMgr:initDefenceFighterNextRound()--防御方即怪物方
    if tbFighterInfoList_Def then
	    local nCreateCount = 0
	    local function createDefencerAndNpcAttacker()
		    nCreateCount = nCreateCount + 1
		    local tbFighterInfo_Def = tbFighterInfoList_Def[nCreateCount]
		    if tbFighterInfo_Def == nil then
		    	return true
		    end
		    local nPosInBattleMgr = tbFighterInfo_Def.arraypos
		    if nPosInBattleMgr < 10 then
			    --加载怪物的
				local nUniqueId = nPosInBattleMgr
			    if tbFighterInfo_Def.is_card then
				    local GameFighter_Defencer = CCardPlayer.new()
				    GameFighter_Defencer:initData(tbFighterInfo_Def, 2, nil)
                    if TbBattleReport.tbGameFighters_OnWnd[nPosInBattleMgr + 10] then TbBattleReport.tbGameFighters_OnWnd[nPosInBattleMgr + 10]:release() end
				    TbBattleReport.tbGameFighters_OnWnd[nPosInBattleMgr + 10] = GameFighter_Defencer
			    else
				    local GameFighter_Defencer = CMonsterPlayer.new()
				    GameFighter_Defencer:initData(tbFighterInfo_Def, 2, nil)
                    if TbBattleReport.tbGameFighters_OnWnd[nPosInBattleMgr + 10] then TbBattleReport.tbGameFighters_OnWnd[nPosInBattleMgr + 10]:release() end
				    TbBattleReport.tbGameFighters_OnWnd[nPosInBattleMgr + 10] = GameFighter_Defencer
			    end
		    end

		    if nCreateCount == #tbFighterInfoList_Def then
                self:createNpcFighter(tbFighterInfoList_Npc)
			    self:initGameDefencerBornAction(tbFighterInfoList_Def)
			    return true
		    end
	    end

	    g_Timer:pushLoopTimer(0.05, createDefencerAndNpcAttacker)
    end
end

function CBattleProcess:createNpcFighter(tbFighterInfoList_Npc)
    for nNpcFighterIndex = 1, #tbFighterInfoList_Npc do
        local tbFighterInfo_Npc = tbFighterInfoList_Npc[nNpcFighterIndex]
        local nPosInBattleMgr = tbFighterInfo_Npc.arraypos
		local nUniqueId = nPosInBattleMgr
        if tbFighterInfo_Npc.is_card then --伙伴
	        local GameFighter_Attacker = CCardPlayer.new()
			GameFighter_Attacker:initData(tbFighterInfo_Npc, 1, true)
            if TbBattleReport.tbGameFighters_OnWnd[nPosInBattleMgr] then TbBattleReport.tbGameFighters_OnWnd[nPosInBattleMgr]:release() end
			TbBattleReport.tbGameFighters_OnWnd[nPosInBattleMgr] = GameFighter_Attacker
			TbBattleReport.tbGameFighters_OnWnd[nPosInBattleMgr].isNpc = false
        else
	       	local GameFighter_Attacker = CMonsterPlayer.new()
			GameFighter_Attacker:initData(tbFighterInfo_Npc, 1, true)
            if TbBattleReport.tbGameFighters_OnWnd[nPosInBattleMgr] then TbBattleReport.tbGameFighters_OnWnd[nPosInBattleMgr]:release() end
			TbBattleReport.tbGameFighters_OnWnd[nPosInBattleMgr] = GameFighter_Attacker
			TbBattleReport.tbGameFighters_OnWnd[nPosInBattleMgr].isNpc = true
        end
    end
end

function CBattleProcess:processBattleRound()
	if g_IsExitBattleProcess then
		exitBattleProcess()
		return
	end

	if self.bIsRoundBegin then
        local tbFighterInfoList_Def = g_BattleMgr:initDefenceFighterNextRound()--防御方即怪物方
		self:initGameDefencerBornAction(tbFighterInfoList_Def)
	else
        g_BattleMgr:addNpcFighters()
		self:resetBuZhenInBattleProcess()
	end
end

function CBattleProcess:setBuZhenData(Button_Pos, index)
	if (Button_Pos and index) then
		local nPos = tbClientToServerPosConvert[index]
		local tbCheckPos = g_Hero:getCurZhenFaIndex(nPos)
		local imageClick = getBattleImg("Btn_BattlePos"..index)
		local imageClickCheck = getBattleImg("Btn_BattlePos"..index.."_Check")
		local imageDisabled = getBattleImg("Btn_BattlePos"..index.."_Disabled")
		if tbCheckPos then
			Button_Pos:loadTextures(imageClick,imageClickCheck,imageDisabled)
			Button_Pos:setTouchEnabled(true)

			Button_Pos:setTag(nPos)
			Button_Pos:addTouchEventListener(onClickResetBuZhen)
		else
			Button_Pos:loadTextures(imageDisabled,imageClickCheck,imageDisabled)--imageDisabled都是透明图
			Button_Pos:setTouchEnabled(false)
		end
	end
end

function CBattleProcess:setImageCardLayoutEnabled(bAnble)
	for key, value in pairs(TbBattleReport.tbGameFighters_OnWnd) do
	   if key < 10 then
		   value.Layout_CardClickArea:setTouchEnabled(bAnble)
		end
	end
end

function CBattleProcess:showAllFightersNextRound()
    local nRunInScreenCount = 0
    local function funcRunInScreenEndCall(GameFighter_Attacker)
		local function executeFighterIdleAni()
			nRunInScreenCount = nRunInScreenCount - 1
            if nRunInScreenCount == 0 then
               self:executeShowAllFightersProcess()
            end
            GameFighter_Attacker:runSpineIdle()
		end
        return executeFighterIdleAni
    end

    for nPos, GameFighter_Attacker in pairs(TbBattleReport.tbGameFighters_OnWnd) do
	   if nPos < 10 then
           nRunInScreenCount = nRunInScreenCount + 1
           local tbCardPos = g_tbCardPos[GameFighter_Attacker.nPos]
           GameFighter_Attacker:setPosition(tbCardPos.tbPos)
		   GameFighter_Attacker:startRunInScreen(funcRunInScreenEndCall(GameFighter_Attacker), g_RunInScreenDelay[1])
		end
	end 
    self:createDefencerAndNpcFighter()
end

function CBattleProcess:executeShowAllFightersProcess()
	if not TbBattleReport then return false end

	self.nShowAtkAndDefSideCount = self.nShowAtkAndDefSideCount or 0
    self.nShowAtkAndDefSideCount = self.nShowAtkAndDefSideCount + 1
    if self.nShowAtkAndDefSideCount == 2 then
		--暂时先隐藏
        for nIconIndex = 1, 5 do
            local tbFightersIamgeIconList_Atk = TbBattleReport.TbBattleWnd.tbFightersIamgeIconList[eumn_battle_side_wnd.attack]
			tbFightersIamgeIconList_Atk[nIconIndex]:setVisible(false)
			tbFightersIamgeIconList_Atk.Image_Fighter_Cursor:setVisible(false)
        end
		
        initFighterImageIconList(eumn_battle_side_wnd.attack)
	
        self:showBattleStartAnimation()
        if TbBattleReport then
        	TbBattleReport.bResetBuZhen = nil
        	TbBattleReport.bOnClickGoGoGo = nil
        end
    end
    return true
end

function CBattleProcess:runToNextBattleRound()
    self.nShowAtkAndDefSideCount = 0
    local nRunOutScreenCount = 0
    local function funcRunOutScreen()
        nRunOutScreenCount = nRunOutScreenCount - 1
        if nRunOutScreenCount == 0 then
            self:showAllFightersNextRound()
        end
    end

    for nPos, GameFighter_Attacker in pairs(TbBattleReport.tbGameFighters_OnWnd) do
	   if nPos < 10 then
           nRunOutScreenCount = nRunOutScreenCount + 1
		   GameFighter_Attacker:actionRunOutScreen(funcRunOutScreen)
		end
	end 

    local Image_BuZhen = TbBattleReport.TbBattleWnd.Image_BuZhen
    if Image_BuZhen then
        Image_BuZhen:setVisible(false)
    end
end

function CBattleProcess:resetBuZhenInBattleProcess()
	if not TbBattleReport then return end
	if TbBattleReport == {} then return end
	if not TbBattleReport.TbBattleWnd then return end
	if TbBattleReport.TbBattleWnd == {} then return end
	
	local Button_NormalSkill = TbBattleReport.TbBattleWnd.tbWidgetSkillIcon[1]
	local Panel_Stencil = tolua.cast(Button_NormalSkill:getChildByName("Panel_Stencil"), "Layout")
	local Panel_Pos = tolua.cast(Panel_Stencil:getChildByName("Panel_Pos"), "Layout")
	local Image_Card = tolua.cast(Panel_Pos:getChildByName("Image_Card"), "ImageView")
	Image_Card:setVisible(false)
	
	TbBattleReport.TbBattleWnd.Panel_Energy:setSize(CCSize(160,0))
    if self.bIsRoundBegin then      
	    self:showBattleStartAnimation()--没有对话直接开战
        self.bIsRoundBegin = nil
        return
    end

	if not TbBattleReport.IsAutoFight then
	    local Image_BuZhen = TbBattleReport.TbBattleWnd.Image_BuZhen
	    local function repeatFadeInOutAction()
		    local arryAct  = CCArray:create()
		    local actionFadeOut = CCFadeTo:create(0.75*g_TimeSpeed, 120)
		    local actionFadeIn = CCFadeTo:create(0.75*g_TimeSpeed, 255)
		    arryAct:addObject(actionFadeOut)
		    arryAct:addObject(actionFadeIn)
		    arryAct:addObject(CCDelayTime:create(0.3*g_TimeSpeed))
		    local actionSequence = CCSequence:create(arryAct)
		    local actionForever = CCRepeatForever:create(actionSequence)
		    Image_BuZhen:runAction(actionForever)
	    end

	    local arrAct = CCArray:create()
	    local actionFadeIn = CCFadeIn:create(1.2*g_TimeSpeed)
	    arrAct:addObject(actionFadeIn)
	    arrAct:addObject(CCCallFuncN:create(repeatFadeInOutAction))
	    local actionSequence = CCSequence:create(arrAct)
	    Image_BuZhen:setVisible(true)
	    Image_BuZhen:setOpacity(0)
	    Image_BuZhen:runAction(actionSequence)
	    TbBattleReport.bResetBuZhen = true
	    self:setImageCardLayoutEnabled(false)

	    --布阵的格子
	    for nClientPos = 1, 9 do
		    local Button_Pos = tolua.cast(Image_BuZhen:getChildByName("Button_BattlePos"..nClientPos), "Button")
		    self:setBuZhenData(Button_Pos, nClientPos)
	    end

		TbBattleReport.TbBattleWnd.Image_GoGoGo:setVisible(true)
		TbBattleReport.TbBattleWnd.Image_GoGoGo:removeAllNodes()
		local armature_GOGOGO, animation_GOGOGO = g_CreateCoCosAnimationWithCallBacks("GOGOGO", nil, nil, 2, nil, true)
		armature_GOGOGO:setPositionXY(0, 0)
		armature_GOGOGO:setTag(999)
		TbBattleReport.TbBattleWnd.Image_GoGoGo:addNode(armature_GOGOGO, 100, 1)
		animation_GOGOGO:playWithIndex(0)
	    
        local function onClick_Image_GoGoGo(pSender, eventType)
            if eventType == ccs.TouchEventType.ended then
                TbBattleReport.bOnClickGoGoGo = true
				pSender:setVisible(false)
				
                local tbGameFighterIdListInPos = {}
                for nPos, GameFighter in pairs(TbBattleReport.tbGameFighters_OnWnd) do
                    if nPos < 10 then
                        tbGameFighterIdListInPos[nPos] = GameFighter.cardid
                        GameFighter.Layout_CardClickArea:setTouchEnabled(true)
                    end
                end

                g_BattleMgr:resetArrayPos(tbGameFighterIdListInPos)             
                self:runToNextBattleRound()
            end
        end
        
        TbBattleReport.TbBattleWnd.Image_GoGoGo:setTouchEnabled(true)
        TbBattleReport.TbBattleWnd.Image_GoGoGo:addTouchEventListener(onClick_Image_GoGoGo)
    else
        self:runToNextBattleRound()
    end
end

function CBattleProcess:showCelebrateSpineAni(func)
	local tbGameFighters_OnWnd = TbBattleReport.tbGameFighters_OnWnd
	local nMaxCout = 0
	local nCurCount = 0
	local function spineActionCB()
		nCurCount = nCurCount + 1
		if nCurCount == nMaxCout then
		   func()
		end
	end

	for nPos, GameFighter in pairs(tbGameFighters_OnWnd) do
		GameFighter:runSpineCelebrate(spineActionCB)
		nMaxCout = nMaxCout + 1
	end
end

function CBattleProcess:showBattleUI()
	local wndInstance = g_WndMgr:getWnd("Game_Battle")
	if TbBattleReport.bHaveTalk then
		local func = calcCountCallBack(2, handler(self, self.resetBuZhenInBattleProcess))
		if wndInstance then
			wndInstance:showBattleUIConverOutWithTalk(func)
		end
		self:showCelebrateSpineAni(func)
	else
		local function showBattleUIWithoutTalkCallBack()
			self:resetBuZhenInBattleProcess()
			if wndInstance then
				wndInstance:showBattleUIWithoutTalkMoveSkillIcon()
			end
		end
		self:showCelebrateSpineAni(showBattleUIWithoutTalkCallBack)
	end
	
	if g_PlayerGuide:checkCurrentGuideSequenceNode("ShowBattleUI", "Game_Battle") then
		g_PlayerGuide:showCurrentGuideSequenceNode()
	end
end

function CBattleProcess:initGameDefencerBornAction(tbFighterInfoList_Def)
	local nBornFighterCount  = 0
	local nBornFighterMaxCount  = 0
	local function executeFighterIdleAniCount()
		nBornFighterCount = nBornFighterCount + 1
		if nBornFighterMaxCount == nBornFighterCount then --怪物初始化完成后 播放开场动画
			 if g_BattleMgr:getCurrentRound() == 1  then
				local nTalkID = 0
				local nAlpha = 0
				if g_BattleTeachSystem and g_BattleTeachSystem:IsTeaching() then
					nTalkID = 1110002
					nAlpha = 100
				else
					nTalkID = g_Hero:getDialogTalkID()
					nAlpha = 0
				end
				if nTalkID and nTalkID > 0 and g_BattleMgr:getIsFirstInThisBattle() then
					local function funDialogueEndCall()
						self:showBattleUI()
					end
					g_DialogueData:showDialogueSequence(nTalkID, g_DialogueData.statusType.comeOnTheStage, funDialogueEndCall, nAlpha)
				else
					self:showBattleUI()
				end
			else
			   self:executeShowAllFightersProcess()
			end
		end
	end
	
	if g_BattleMgr:getCurrentRound() > 1  then
		TbBattleReport.TbBattleWnd.Scene:loadTexture(g_BattleData:getBackgroundPic(g_BattleMgr:getCurrentRound()))
	end

	local function funcRunInScreenEndCall(GameFighter)
		local function executeFighterIdleAni()
			GameFighter:addSPAnimation()
			GameFighter:runSpineIdle()
			executeFighterIdleAniCount()
		end
		return executeFighterIdleAni
	end

	TbBattleReport.tbSubsitutionFighterList_Def =  {}
	local nFighterList_Def_Count = #tbFighterInfoList_Def
	
	--根据策划的布阵序列化重新排序怪物
	local function sortTbFighterInfoList_Def(tbFighterInfo_DefA, tbFighterInfo_DefB)
		local nPosA = tbFighterInfo_DefA.arraypos
		local nPosB = tbFighterInfo_DefB.arraypos
		local nClientPosA = tbServerToClientPosConvert[nPosA]
		local nClientPosB = tbServerToClientPosConvert[nPosB]
		if nClientPosA > nClientPosB then
			return false
		else
			return true
		end
	end
	table.sort(tbFighterInfoList_Def, sortTbFighterInfoList_Def)

	local nAccelerateSpeed = TbBattleReport.nAccelerateSpeed or 1
	nAccelerateSpeed = math.max(nAccelerateSpeed, 1)
	nAccelerateSpeed = math.min(nAccelerateSpeed, 7)
	local fDelayTime = g_RunInScreenDelay[nAccelerateSpeed]
	
	for nFighterIndex = 1, nFighterList_Def_Count do
		local tbFighterInfo_Def = tbFighterInfoList_Def[nFighterIndex]
		local nPosInBattleMgr = tbFighterInfo_Def.arraypos
		local nClientPos = tbServerToClientPosConvert[nPosInBattleMgr]

		if nPosInBattleMgr < 10 then
			nBornFighterMaxCount = nBornFighterMaxCount + 1
			if tbFighterInfo_Def.is_card then --伙伴
				local GameFighter_Defencer =  TbBattleReport.tbGameFighters_OnWnd[nPosInBattleMgr + 10]
				local tbCardPos = g_tbCardPos[nPosInBattleMgr]
				TbBattleReport.Mesh:addChild(GameFighter_Defencer, tbCardPos.nBattleLayer)
				GameFighter_Defencer:resetSp(tbFighterInfo_Def.init_sp)
				if g_BattleMgr:getCurrentRound() == 1  then
					GameFighter_Defencer:startRunInScreen(funcRunInScreenEndCall(GameFighter_Defencer), fDelayTime)
				else
					GameFighter_Defencer:startRunInScreen(funcRunInScreenEndCall(GameFighter_Defencer), g_RunInScreenDelay[1])
				end
				GameFighter_Defencer.CCNode_Skeleton:setScaleX(-1)
			else --怪物
				local GameFighter_Defencer = TbBattleReport.tbGameFighters_OnWnd[nPosInBattleMgr + 10]
				local tbCardPos = g_tbCardPos[nPosInBattleMgr]
				TbBattleReport.Mesh:addChild(GameFighter_Defencer, tbCardPos.nBattleLayer)
				GameFighter_Defencer:resetSp(tbFighterInfo_Def.init_sp)
				if g_BattleMgr:getCurrentRound() == 1  then
					GameFighter_Defencer:startRunInScreen(funcRunInScreenEndCall(GameFighter_Defencer), fDelayTime)
				else
					GameFighter_Defencer:startRunInScreen(funcRunInScreenEndCall(GameFighter_Defencer), g_RunInScreenDelay[1])
				end
				GameFighter_Defencer.CCNode_Skeleton:setScaleX(-1)
			end
		else
			--说明到了替补了
			TbBattleReport.tbSubsitutionFighterList_Def[nPosInBattleMgr] = tbFighterInfo_Def
			TbBattleReport.tbSubsitutionFighterList_Def[nPosInBattleMgr +100] = tbFighterInfo_Def
		end
	end

	self:playFootStepSound(1)
	if TbBattleReport.TbBattleWnd.BitmapLabel_RoundIndex then
		TbBattleReport.TbBattleWnd.BitmapLabel_RoundIndex:setText("01/30")
	end

	initFighterImageIconList(eumn_battle_side_wnd.defence)

	local TbBattleWnd = TbBattleReport.TbBattleWnd
	local Button_NormalSkill = TbBattleWnd.tbWidgetSkillIcon[1]
	local Panel_Stencil = tolua.cast(Button_NormalSkill:getChildByName("Panel_Stencil"), "Layout")
	local Panel_Pos = tolua.cast(Panel_Stencil:getChildByName("Panel_Pos"), "Layout")
	if Panel_Pos then
		 local Image_Card = Panel_Pos:getChildByName("Image_Card")
		 Image_Card:removeAllNodes()
	end
end

local function showWordsAnimation(armature, userAnimation)
	local function ShowBattleStartWord(nType, nAnimationIndex)
		--开战、天梯、切磋动画
		if nType == 1 then
			local armatureWord,userAnimationWord = g_CreateCoCosAnimationWithCallBacks("BattleStartKaiZhan", nil, nil, 2, nil, true)
			armatureWord:setPosition(VisibleRect:center())
			mainWnd:addChild(armatureWord, 11)
			userAnimationWord:setSpeedScale(g_nBaseSpeed+g_nProcessJsonAniAccelaration+(TbBattleReport.nAccelerateSpeed-1)*g_nAnimationSpeed)
			userAnimationWord:playWithIndex(nAnimationIndex)
		--渡劫、摘仙桃、招财进宝、神仙试炼动画
		elseif nType == 2 then
			local armatureWord,userAnimationWord = g_CreateCoCosAnimationWithCallBacks("BattleStartWord", nil, nil, 2, nil, true)
			armatureWord:setPosition(VisibleRect:center())
			mainWnd:addChild(armatureWord, 11)
			userAnimationWord:setSpeedScale(g_nBaseSpeed+g_nProcessJsonAniAccelaration+(TbBattleReport.nAccelerateSpeed-1)*g_nAnimationSpeed)
			userAnimationWord:playWithIndex(nAnimationIndex)
		end
	end

	--显示x/n动画
	local function ShowBattleStartRound()
		local armatureRound,userAnimationRound = g_CreateCoCosAnimationWithCallBacks("BattleStartRound", nil, nil, 2, nil, true)
		armatureRound:setPosition(VisibleRect:center())

		local boneCurrentRound = armatureRound:getBone("CurrentRound")
		local szCurrentRound = "BattleStart_Num"..g_BattleMgr:getCurrentRound()..".png"
		local skinCurrentRound = CCSkin:createWithSpriteFrameName(szCurrentRound)
		boneCurrentRound:addDisplay(skinCurrentRound,0)
		boneCurrentRound:changeDisplayWithIndex(0, true)

		local boneTotaRounds = armatureRound:getBone("TotaRounds")
		 local szTotaRounds = "BattleStart_Num"..nAnimationMaxRound..".png"
--		local szTotaRounds = "BattleStart_Num"..g_BattleData:getClientMaxRound()..".png"
		local skinTotaRounds = CCSkin:createWithSpriteFrameName(szTotaRounds)
		boneTotaRounds:addDisplay(skinTotaRounds,0)
		boneTotaRounds:changeDisplayWithIndex(0, true)

		mainWnd:addChild(armatureRound, 12)
		userAnimationRound:setSpeedScale(g_nBaseSpeed+g_nProcessJsonAniAccelaration+(TbBattleReport.nAccelerateSpeed-1)*g_nAnimationSpeed)
		userAnimationRound:playWithIndex(0)
	end

	if g_BattleMgr:getCurrentRound() == 1 then
		local nBattleType = g_BattleData:getEctypeType()
		if (nBattleType == macro_pb.Battle_Atk_Type_normal_pass
			or nBattleType == macro_pb.Battle_Atk_Type_advanced_pass
			or nBattleType == macro_pb.Battle_Atk_Type_master_pass
		) then
			ShowBattleStartWord(1,0)
		elseif (nBattleType == macro_pb.Battle_Atk_Type_Money 
			or nBattleType == macro_pb.Battle_Atk_Type_Exp
			or nBattleType == macro_pb.Battle_Atk_Type_Tribute
			or nBattleType == macro_pb.Battle_Atk_Type_Aura
			or nBattleType == macro_pb.Battle_Atk_Type_Knowledge
		) then
			ShowBattleStartWord(2,1)
		elseif nBattleType == macro_pb.Battle_Atk_Type_dujie then
			ShowBattleStartWord(2,0)
		elseif nBattleType == macro_pb.Battle_Atk_Type_WorldBoss or  nBattleType == macro_pb.Battle_Atk_Type_GuildWorldBoss then
			ShowBattleStartWord(1,0)
		elseif (
			nBattleType == macro_pb.Battle_Atk_Type_ArenaPlayer
			or nBattleType == macro_pb.Battle_Atk_Type_ArenaRobot
			or nBattleType == Battle_Atk_Type_CrossArenaPlayer
		) then
			ShowBattleStartWord(1,1)
		elseif nBattleType == macro_pb.Battle_Atk_Type_Player then
			ShowBattleStartWord(1,2)
		else
			ShowBattleStartWord(1,0)
		end
	else
		ShowBattleStartRound()
	end
end

local function showRoundsAnimation(armature, userAnimation)
	local function ShowBattleStartRound(nType)
		--显示x/n的动画 战斗开始
		if nType == 1 then
            --SimpleAudioEngine:sharedEngine():stopEffect(self.nSoundEffectID)
            --SimpleAudioEngine:sharedEngine():pauseBackgroundMusic()
			local armatureRound,userAnimationRound = g_CreateCoCosAnimationWithCallBacks("BattleStartRound", nil, nil, 2, nil, true)
			armatureRound:setPosition(VisibleRect:center())

			local boneCurrentRound = armatureRound:getBone("CurrentRound")
			local szCurrentRound = "BattleStart_Num"..g_BattleMgr:getCurrentRound()..".png"
			local skinCurrentRound = CCSkin:createWithSpriteFrameName(szCurrentRound)
			boneCurrentRound:addDisplay(skinCurrentRound,0)
			boneCurrentRound:changeDisplayWithIndex(0, true)

			local boneTotaRounds = armatureRound:getBone("TotaRounds")
			local szTotaRounds = "BattleStart_Num"..nAnimationMaxRound..".png"
			local skinTotaRounds = CCSkin:createWithSpriteFrameName(szTotaRounds)
			boneTotaRounds:addDisplay(skinTotaRounds,0)
			boneTotaRounds:changeDisplayWithIndex(0, true)

			mainWnd:addChild(armatureRound, 12)
			userAnimationRound:setSpeedScale(g_nBaseSpeed+g_nProcessJsonAniAccelaration+(TbBattleReport.nAccelerateSpeed-1)*g_nAnimationSpeed)
			userAnimationRound:playWithIndex(0)
		--显示BOSS动画
		elseif nType == 2 then
			local armatureBoss,userAnimationBoss = g_CreateCoCosAnimationWithCallBacks("BattleStartLetter", nil, battleStartRoundEndCallBack, 2, nil, true)
			armatureBoss:setPosition(VisibleRect:center())
			mainWnd:addChild(armatureBoss, 12)
			userAnimationBoss:setSpeedScale(g_nBaseSpeed+g_nProcessJsonAniAccelaration+(TbBattleReport.nAccelerateSpeed-1)*g_nAnimationSpeed)
			userAnimationBoss:playWithIndex(0)
		--显示VS动画
		elseif nType == 3 then
			local armatureVS,userAnimationVS = g_CreateCoCosAnimationWithCallBacks("BattleStartLetter", nil, battleStartRoundEndCallBack, 2, nil, true)
			armatureVS:setPosition(VisibleRect:center())
			mainWnd:addChild(armatureVS, 12)
			userAnimationVS:setSpeedScale(g_nBaseSpeed+g_nProcessJsonAniAccelaration+(TbBattleReport.nAccelerateSpeed-1)*g_nAnimationSpeed)
			userAnimationVS:playWithIndex(1)
		end
	end

	if not TbBattleReport then return false end


	local nBattleType = g_BattleData:getEctypeType()
	if (nBattleType == macro_pb.Battle_Atk_Type_normal_pass
		or nBattleType == macro_pb.Battle_Atk_Type_advanced_pass
		or nBattleType == macro_pb.Battle_Atk_Type_master_pass
	) then
		if g_BattleMgr:getCurrentRound() == 1 then
			local nEctypeID = g_BattleData:getEctypeID()
			local tbSubEctype = g_DataMgr:getMapEctypeSubCsv(nEctypeID)
			local tbEctypeInfo = g_DataMgr:getMapEctypeCsv(tbSubEctype.EctypeID)
			if tbEctypeInfo.IsBoss  == 1 then
				ShowBattleStartRound(2)
			else
				ShowBattleStartRound(1)
			end
		end
	elseif (nBattleType == macro_pb.Battle_Atk_Type_RichGod
		or nBattleType == macro_pb.Battle_Atk_Type_GodTrial
		or nBattleType == macro_pb.Battle_Atk_Type_PickPeach
		or nBattleType == macro_pb.Battle_Atk_Type_dujie
	) then
		if g_BattleMgr:getCurrentRound() == 1 then
			ShowBattleStartRound(1)
		end
	elseif (nBattleType == macro_pb.Battle_Atk_Type_ArenaPlayer
		or nBattleType == macro_pb.Battle_Atk_Type_ArenaRobot
		or nBattleType == macro_pb.Battle_Atk_Type_Player
		or nBattleType == macro_pb.Battle_Atk_Type_CrossArenaPlayer
	) then
		if g_BattleMgr:getCurrentRound() == 1 then
			ShowBattleStartRound(3)
		end
	elseif nBattleType == macro_pb.Battle_Atk_Type_WorldBoss or  nBattleType == macro_pb.Battle_Atk_Type_GuildWorldBoss then
		if g_BattleMgr:getCurrentRound() == 1 then
			ShowBattleStartRound(2)
		end
	end

	return true
end

local tbBattleStartFrameCallBack = {
	ShowWordsAnimation = showWordsAnimation,
	ShowRoundsAnimation = showRoundsAnimation
}

--战斗开始动画
function CBattleProcess:showBattleStartAnimation()
	if g_IsExitBattleProcess then
		exitBattleProcess()
		return
	end

	self.bIsStopStepSound = true
	local function stopFootStepSound()
		if self.nSoundEffectID then
			SimpleAudioEngine:sharedEngine():stopEffect(self.nSoundEffectID)
		end
	end
	stopFootStepSound()

	local function battleStartEndCallBack()
		self:executeBattleStartProcess()--正式释放技能 攻击开火过程
		if g_PlayerGuide:checkCurrentGuideSequenceNode("BattleStart", "Game_Battle") then
			g_PlayerGuide:showCurrentGuideSequenceNode()
		end
		
		if not TbBattleReport then return end
		
		local nBattleType = TbBattleReport.tbBattleScenceInfo.battle_type
		if nBattleType == macro_pb.Battle_Atk_Type_normal_pass then --普通关卡
			local nEctypeSubID = TbBattleReport.tbBattleScenceInfo.mapid
			local CSV_MapEctypeSub = g_DataMgr:getMapEctypeSubCsv(nEctypeSubID)
			if CSV_MapEctypeSub.EctypeID == 1002 then
				if g_BattleMgr:getIsFirstInThisBattle() then
					local wndInstance = g_WndMgr:getWnd("Game_Battle")
					if wndInstance then
						local armature, userAnimation = g_CreateCoCosAnimation("OnTouchGuide", nil, 2)
						if armature then
							wndInstance.Button_Accelerate:addNode(armature, 99)	
							userAnimation:playWithIndex(0)
						end
					end
				end
			end
		end
	end

	local animation, userAnimation = g_CreateCoCosAnimationWithCallBacks("BattleStart", tbBattleStartFrameCallBack, battleStartEndCallBack, 2, nil, true)
	mainWnd:addChild(animation, 10)
	animation:setPosition(VisibleRect:center())
	userAnimation:setSpeedScale(g_nBaseSpeed+g_nProcessJsonAniAccelaration+(TbBattleReport.nAccelerateSpeed-1)*g_nAnimationSpeed)
	if g_BattleMgr:getCurrentRound() == 1 then
		userAnimation:playWithIndex(1)
	else
		userAnimation:playWithIndex(0)
	end
end

function CBattleProcess:showCurrentBattleTurn(tbBattleTurnData)
	if g_IsExitBattleProcess then
		exitBattleProcess()
		return
	end

	self.tbCurBattleTurnData = tbBattleTurnData
	if TbBattleReport.TbBattleWnd.BitmapLabel_RoundIndex then
		if tbBattleTurnData.new_round_num then
			TbBattleReport.TbBattleWnd.BitmapLabel_RoundIndex:setText(string.format("%02d/%d", tbBattleTurnData.new_round_num, 30))
		end
	end
	
	if tbBattleTurnData ~= nil and tbBattleTurnData ~={} then
		if TbBattleReport ~= nil and TbBattleReport ~= {} then
			if TbBattleReport.tbGameFighters_OnWnd ~= nil and TbBattleReport.tbGameFighters_OnWnd ~= {} then
				local nPos = math.mod(tbBattleTurnData.actioninfo, 100)
				local GameObj_Figther = TbBattleReport.tbGameFighters_OnWnd[nPos]
				if GameObj_Figther ~= nil and GameObj_Figther ~= {} then
					GameObj_Figther:setCurrentTurnAttackData(tbBattleTurnData)
				else
					error("CBattleProcess:showCurrentBattleTurn TbBattleReport.tbGameFighters_OnWnd[nPos] is nil or empty====="..nPos)
				end
			else
				error("CBattleProcess:showCurrentBattleTurn TbBattleReport.tbGameFighters_OnWnd is nil or empty")
			end
		else
			error("CBattleProcess:showCurrentBattleTurn TbBattleReport is nil or empty")
		end
	else
		error("CBattleProcess:showCurrentBattleTurn tbBattleTurnData is nil or empty")
	end
end

function CBattleProcess:getCurBattleTurnData()
	return self.tbCurBattleTurnData
end

function CBattleProcess:getCurTurn()
	return self.nCurTurn
end

function CBattleProcess:showDropItemEffect(szAniName, pszSpriteFrameName, nPos, func )
	local armature, userAnimation = g_CreateBattleJsonAnimation(szAniName, func )
	local bone = armature:getBone("Layer3");
	local numSkin1 = CCSkin:createWithSpriteFrameName(pszSpriteFrameName)
	bone:addDisplay(numSkin1,0)

	local bone2 = armature:getBone("Layer4");
	local numSkin2 = CCSkin:createWithSpriteFrameName(pszSpriteFrameName)
	bone2:addDisplay(numSkin2, 0)

	--居中
	armature:setPosition(nPos)
	userAnimation:playWithIndex(0)
	mainWnd:addChild(armature)
end

--下一个攻击动作
function CBattleProcess:executeNextTurnAttack()
	if g_IsExitBattleProcess then
		exitBattleProcess()
		return
	end

	if TbBattleReport.nRepeatAttackNum and TbBattleReport.nRepeatAttackNum > 1 then
		TbBattleReport.nRepeatAttackNum = TbBattleReport.nRepeatAttackNum - 1
		return
	end

	TbBattleReport.tbMutileAttack = nil
	TbBattleReport.bReset = nil
	TbBattleReport.nCurrentAddManaPos = nil
	
	if TbBattleReport.tbBattleTurn_Restrike then
		local tbBattleTurn_Restrike = TbBattleReport.tbBattleTurn_Restrike
		local nPos = math.floor(math.mod(tbBattleTurn_Restrike.actioninfo, 100))
		local GameFighter = TbBattleReport.tbGameFighters_OnWnd[nPos]
		GameFighter:setCurrentTurnAttackData(tbBattleTurn_Restrike)
		GameFighter:showEffectOnGroundByID(Enum_SkillLightEffect._ReStrike, nil, GameFighter.nPos > 10, nil, Enum_MeshLayer.DamageEffectWord)--光效层级设置
		return
	end

	local nBattleState = g_BattleMgr:getBattleState()
	if nBattleState == enum_battle_state.current_round_end then
		-- by kakiwang
		-- local function delayToShowBattleRound()
			-- self:processBattleRound()
		-- end
		-- g_Timer:pushTimer(0.01*g_TimeSpeed, delayToShowBattleRound)
		self:processBattleRound()
	elseif nBattleState == enum_battle_state.battle_end then
		TbBattleReport.bOver = true
		self:endBattleProcess()
	else
		local ka2 = CListenFunction:new("待机测试 卡顿 2")
		self:executeBattleStartProcess()
		ka2:delete();
	end
end

function CBattleProcess:startBattleTurnProcess(nCurrentAttackPos)
	if g_IsExitBattleProcess then
		exitBattleProcess()
		return
	end

	local tbBattleTurnData = g_BattleMgr:calcBattleTurn()
	TbBattleReport.nCurTurn = tbBattleTurnData.turnno
	TbBattleReport.nRepeatAttackNum = 1

	local tbUnionDamageInfoList = tbBattleTurnData.tbFitDamage
	if tbUnionDamageInfoList then --合击
		local function continueToAttack(tbBattleTurnData)
			return function()
				self:showCurrentBattleTurn(tbBattleTurnData)
			end
		end
		local nMax = #tbUnionDamageInfoList
		TbBattleReport.nRepeatAttackNum =  TbBattleReport.nRepeatAttackNum + nMax
		TbBattleReport.tbMutileAttack = {} --特殊处理一下合击
		TbBattleReport.tbMutileAttack.die_sub_apos = tbBattleTurnData.actioncardlist[1].die_sub_apos
		TbBattleReport.tbMutileAttack.die_drop_info = tbBattleTurnData.actioncardlist[1].die_drop_info
		TbBattleReport.tbMutileAttack.Num = nMax + 1

		for nDamageSequence = 1, nMax do
			local tbBattleTurnData = {}
			tbBattleTurnData.turnno = TbBattleReport.nCurTurn --0表示反击 -1表示合击
			tbBattleTurnData.actioninfo = tbUnionDamageInfoList[nDamageSequence].apos

			local actioncardlist = {}
			actioncardlist.damage = tbUnionDamageInfoList[nDamageSequence].damage
			actioncardlist.affectinfo = tbBattleTurnData.actioncardlist[1].affectinfo

			tbBattleTurnData.actioncardlist = {}
			table.insert(tbBattleTurnData.actioncardlist, actioncardlist)

			g_Timer:pushTimer(nDamageSequence*nTimeTurnEscape*g_TimeSpeed, continueToAttack(tbBattleTurnData))
		end
	end

	self:showCurrentBattleTurn(tbBattleTurnData)
end


function CBattleProcess:executeBattleStartProcess()
	if not TbBattleReport or TbBattleReport.bEscape then
	   return
	end

	local tbFighterSequenceList = g_BattleMgr:getFighterSequenceList()
	local GameFighter = tbFighterSequenceList[1]
	local nCurrentAttackPos = GameFighter.atkno*10 + GameFighter.apos
	TbBattleReport.nCurrentAddManaPos = nCurrentAttackPos

	adjustFighterImageIconCursor(nCurrentAttackPos)

	local function executeBattleTurnProcess()
		TbBattleReport.nCurrentAttackPos = nil
		if nCurrentAttackPos < 10 then
			if g_BattleMgr:isCurCardChooseSkill() then
				self:startBattleTurnProcess(nCurrentAttackPos)
			elseif TbBattleReport.IsAutoFight then
				autoUseSkill(GameFighter.atkno, GameFighter.apos)
			else
				TbBattleReport.nCurrentAttackPos = nCurrentAttackPos
				showPlayerSkillIcon()
				return
			end
		else --怪物1-3 依次释放
			autoUseSkill(GameFighter.atkno, GameFighter.apos)
		end
		self:startBattleTurnProcess(nCurrentAttackPos)
	end

	if g_BattleTeachSystem and g_BattleTeachSystem:IsTeaching() then
		g_BattleTeachSystem:SkillActtckCall(self.nAttackCount, executeBattleTurnProcess, nCurrentAttackPos)
	else
		executeBattleTurnProcess()
	end
    --战斗教学, 记录攻击次数
	self.nAttackCount = self.nAttackCount + 1
end

function CBattleProcess:removePlistResouce()
	-- for key, value in pairs(TbResouceRemove) do
	-- 	CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo(key)
	-- 	TbResouceRemove[key] = nil
	-- end
	-- TbResouceRemove = {}
end

function CBattleProcess:startToExitBattleProcess(executeClearUpAction)
	if g_IsExitBattleProcess == nil then
		executeClearUpAction()
		return
	end

	g_IsExitBattleProcess = true
	self.exitBattleCallBack = executeClearUpAction
	local function delayToExit()
		self.nExitTimerID = nil
		exitBattleProcess()
	end
	self.nExitTimerID = g_Timer:pushTimer(3, delayToExit)
end

function showBattleProcessEndResult(tbBattleResult, nStarScore)
	SimpleAudioEngine:sharedEngine():stopAllEffects()

	local function showBattleResult()
		g_BattleResult:showBattleResult(tbBattleResult, nStarScore)
	end

	local function delayToShowBattleResult()
		local nSpineCelebrateCount = 0
		local nSpineCelebrateMaxCount = 0
		local function showCelebrateSpineAni()
			nSpineCelebrateCount = nSpineCelebrateCount + 1
			if nSpineCelebrateCount == nSpineCelebrateMaxCount then
				showBattleResult()
			end
		end

		if TbBattleReport and TbBattleReport.tbGameFighters_OnWnd then
			for key, value in pairs(TbBattleReport.tbGameFighters_OnWnd) do
				if key < 10 then
					 nSpineCelebrateMaxCount = nSpineCelebrateMaxCount + 1
					 value:runSpineCelebrate(showCelebrateSpineAni)
				end
			end
		end

		if nSpineCelebrateMaxCount == 0 then
			showBattleResult()
		end
	end

	if tbBattleResult["iswin"] then
		delayToShowBattleResult()
	else
		showBattleResult()
	end
end

function waitForBattleResultCall(tbBattleResult, nStarScore)
	g_MsgNetWorkWarning:registerFunc()

	local nTalkID = 0
	local nAlpha = 0
	if g_BattleTeachSystem and g_BattleTeachSystem:IsTeaching() then
		nTalkID = 1110002
		nAlpha = 100
	else
		nTalkID = g_Hero:getDialogTalkID()
		nAlpha = 0
	end
	if nTalkID and nTalkID > 0 and tbBattleResult["iswin"] and g_BattleMgr:getIsFirstInThisBattle() then
		local function showDialogTalkCallBack4()
			g_Hero:setDialogTalkID(nil)
			showBattleProcessEndResult(tbBattleResult, nStarScore)
		end
		g_DialogueData:showDialogueSequence(nTalkID, g_DialogueData.statusType.ended, function() showDialogTalkCallBack4() end, nAlpha)
	else
		showBattleProcessEndResult(tbBattleResult, nStarScore)
	end
end

--副本结束
function CBattleProcess:endBattleProcess()

    if g_BattleTeachSystem:IsTeaching() then
        g_BattleTeachSystem:End()
        return
    end

	g_BattleMgr:sendBattleResult(waitForBattleResultCall)

	nBattleCount = nBattleCount + 1
	nAnimationMaxRound = nil
end

function g_CreateBattleJsonAnimation(szAniName, funcCallBack, tbEffect, nAnimationSpeed, bIsPiaoZi)
	local nAnimationSpeed = nAnimationSpeed or g_nCocosJsonAniAccelaration

	local pathFile = nil
	if not tbEffect or tbEffect.Type == 3 then
		pathFile = getCocoAnimationJson(szAniName)
	else
		pathFile = getEffectSkillJson(szAniName)
	end
	
	-- 慎重
	-- if(not TbResouceRemove[pathFile])then
		-- CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(pathFile)
	-- end
	-- TbResouceRemove[pathFile]  = nBattleCount
	
	-- local armature =  CCArmature:create(szAniName)
	local armature = g_BattleResouce:LoadAnimationFile(pathFile, szAniName)
	if not armature then
		return nil
	end

	local userAnimation = armature:getAnimation()
	if bIsPiaoZi then
		userAnimation:setSpeedScale(g_nBaseSpeed+nAnimationSpeed+(TbBattleReport.nAccelerateSpeed-1)*g_nAnimationSpeed*0.5)
	else
		userAnimation:setSpeedScale(g_nBaseSpeed+nAnimationSpeed+(TbBattleReport.nAccelerateSpeed-1)*g_nAnimationSpeed)
	end

	if userAnimation == nil then
		return nil
	end

	local function AnimationEndCallBack(armatureBack,movementType,movementID)
		if movementType == ccs.MovementEventType.COMPLETE then --完成
			armatureBack:stopAllActions()
			armatureBack:removeFromParentAndCleanup(true)
			if funcCallBack then
				funcCallBack()
				funcCallBack = nil
			end
		elseif(movementType == ccs.MovementEventType.LOOP_COMPLETE)then
			--
		end
	end
	userAnimation:setMovementEventCallFunc(AnimationEndCallBack)

	local function AnimationFrameCallBack(armatureBack, strFrameEvent, nOriginFrameIndex, nCurrentFrameIndex)
		local strPrefix = string.sub(strFrameEvent,1,10)
		if strPrefix == "PlaySound_" then
			local nStrLen = string.len(strFrameEvent)
			--这里未来要判断平台
			local strSound = "Sound/Skill/"..string.sub(strFrameEvent,11,nStrLen)..".mp3"
			g_playSoundEffectBattle(strSound)
		else
			if(funcCallBack)then
				funcCallBack()
				funcCallBack = nil
			end
		end
	end
	
	userAnimation:setFrameEventCallFunc(AnimationFrameCallBack)
	return armature, userAnimation
end

function g_CreateSpineAnimation(szAniName, funcCallBack, tbEffect)
	local CCNode_Skeleton = g_BattleResouce:LoadSpineFile(szAniName)

    local function addEvnetListner(pSender, eventType, nLoopCout, strEvent)
        if eventType == ccs.spEventType.SP_ANIMATION_EVENT then
         	local strPrefix = string.sub(strEvent,1,10)
			if strPrefix == "PlaySound_" then
				local nStrLen = string.len(strEvent)
				local strSound = "Sound/Skill/"..string.sub(strEvent,11,nStrLen)..".mp3"
				g_playSoundEffectBattle(strSound)
			else
				CCNode_Skeleton:cancelEventListener()
				if funcCallBack then
					funcCallBack()
					funcCallBack = nil
				end
			end
        end
        if eventType == ccs.spEventType.SP_ANIMATION_COMPLETE then
			CCNode_Skeleton:cancelEventListener()
        end
    end
	
    CCNode_Skeleton:addEventListener(addEvnetListner)
	if tbEffect.SpineAnimationSpeed > 0 then
		CCNode_Skeleton:setSpeed((tbEffect.SpineAnimationSpeed/100)*g_nBaseSpeed+g_nSpineJsonAniAccelaration+(TbBattleReport.nAccelerateSpeed-1)*g_nAnimationSpeed)
		CCNode_Skeleton:setAnimation(0, "Animation1", false)
	else
		CCNode_Skeleton:setSpeed(g_nBaseSpeed+g_nSpineJsonAniAccelaration+(TbBattleReport.nAccelerateSpeed-1)*g_nAnimationSpeed)
		CCNode_Skeleton:setAnimation(0, "Animation1", false)
	end
	
	return CCNode_Skeleton
end

function exitBattleProcess()
	if not TbBattleReport then return false end

	g_IsExitBattleProcess = nil
	local GameObj_BattleProcess = TbBattleReport.GameObj_BattleProcess
	if not GameObj_BattleProcess then return false end

	if GameObj_BattleProcess.nExitTimerID then
		g_Timer:destroyTimerByID(GameObj_BattleProcess.nExitTimerID)
		GameObj_BattleProcess.nExitTimerID = nil
	end

	GameObj_BattleProcess:removePlistResouce()
	if GameObj_BattleProcess.exitBattleCallBack then
		GameObj_BattleProcess.exitBattleCallBack()
	end

	return true
end

function g_RemoveAllBattlePlistResource()
	-- for key, value in pairs(TbResouceRemove) do
		-- CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo(key)
	-- end
	-- TbResouceRemove = {}
end
