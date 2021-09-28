--------------------------------------------------------------------------------------
-- 文件名:	CSkillMgr..lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2014-9-13 15:24
-- 版  本:	1.0
-- 描  述:	技能管理类
-- 应  用:   技能使用
---------------------------------------------------------------------------------------

--创建CSkillMgr类
CSkillMgr = class("CSkillMgr")
CSkillMgr.__index = CSkillMgr

enum_fly_effect_type = {
	fly_no_need = 0,
	fly_to_default = 1,
	fly_to_pos_5 = 2,
	fly_to_nearest_row = 3,
	fly_from_fixed_to_outside_screen = 4,
	fly_from_fixed_to_target = 5,
}

--逆时针是正数 --cococs旋转的时候 正数顺时针转
local function getRate(tbEnd, tbBegin)
    local tbDist = ccpSub(tbEnd, tbBegin)
    local nLenth = ccpLength(tbDist)
    local angel = tbDist.x/nLenth
    angel = math.deg(math.acos(angel)) --返回的是正数，y正半轴都是正数
    --调整一下角度
    if(tbDist.y < 0)then
        angel = -angel
    end
	
    return angel, nLenth
end

local function setRotation(armature, angel)
    local textureSprite = CCSprite:createWithTexture(armature:getTexture())
    local texturesize = textureSprite:getContentSize()
    local renderTex = CCRenderTexture:create(texturesize.width, texturesize.height,0);
	--  renderTex:beginWithClear(1.0, 1.0, 1.0, 1.0)
    renderTex:begin()
    textureSprite:setAnchorPoint(ccp(0.5,0.5))
	textureSprite:setRotation(angel)
    textureSprite:setPositionXY(texturesize.width/2, texturesize.height/2)
	textureSprite:visit()
	renderTex:endToLua()
	local newTex = renderTex:getSprite():getTexture()
	armature:setTexture(newTex)
end


function CSkillMgr:setAttackSkillData(GameFighter_Attacker, tbSkill, tbBattleTurnData)
	self.GameFighter_Attacker = GameFighter_Attacker
    self.tbSkillData = tbSkill
    self.tbBattleTurnData = tbBattleTurnData
end

function CSkillMgr:getCurrentSkillDetail()
    if self.tbBattleTurnData and self.GameFighter_Attacker then 
        return string.format("[当前轮数:%d,玩家Pos:%d] ", self.tbBattleTurnData.turnno, self.GameFighter_Attacker.nPos)
    end
    return ""
end

function CSkillMgr:getPlayerSrcPos()
    return self.GameFighter_Attacker.nPos
end

function CSkillMgr:resetAllTargetHurtDamage(tbBattleTurnData)
    local tbTargetDamageInfoList = tbBattleTurnData.actioncardlist
	local nTargetDamageInfoListCount = #tbTargetDamageInfoList
	
	--设置被攻击数据
	for nDamageSequence = 1, nTargetDamageInfoListCount do
        local tbTargetDamageInfo = tbTargetDamageInfoList[nDamageSequence]
		local nPos = tbTargetDamageInfo.affectinfo
		if TbBattleReport and TbBattleReport.tbGameFighters_OnWnd then
			if TbBattleReport.tbGameFighters_OnWnd[nPos] then
				TbBattleReport.tbGameFighters_OnWnd[nPos]:resetSkillDamageList_Hurt()
			end
		end
	end
end

--第一阶段 释放阶段
--开始攻击动作 首先播放的是攻击动作，同时播放攻击声音。
--攻击动作开始播放后的一段延迟时间AttackDelay后，开始播放攻击特效。
function CSkillMgr:excuteSkillAttackProcess()
	local tbBattleTurnData = self.tbBattleTurnData
    if tbBattleTurnData.sp and self.GameFighter_Attacker.nSkillIndex ~= eumn_skill_index.normal_skill then--设置释放者的气势值
        self.GameFighter_Attacker:setCurSp(tbBattleTurnData.sp)
    end

    self.nFighterAttackCount = 1
	self.tbSelfDamageInfoList = {}
  
	local tbBleedDamageInfoList_Temp = tbBattleTurnData.be_damage	

	if tbBleedDamageInfoList_Temp and #tbBleedDamageInfoList_Temp > 0 then --自身伤害表现,正数减血,负数加血
		for nBleedDamageInfoIndex = 1, #tbBleedDamageInfoList_Temp do
			local tbBleedDamageInfo = tbBleedDamageInfoList_Temp[nBleedDamageInfoIndex]
            local nBleedDamageType = tbBleedDamageInfo.be_damage_type

			if nBleedDamageType == macro_pb.Battle_Effect_Bleed then --流血可以多个
				self.tbSelfDamageInfoList[nBleedDamageType] = self.tbSelfDamageInfoList[nBleedDamageType] or {}
				table.insert(self.tbSelfDamageInfoList[nBleedDamageType], tbBleedDamageInfo.be_damage_data)
			else
				self.tbSelfDamageInfoList[nBleedDamageType] = tbBleedDamageInfo.be_damage_data
			end
		end
	end
	
    local nTargetDamageInfoListCount = 0
	if tbBattleTurnData.actioncardlist then
		nTargetDamageInfoListCount = #tbBattleTurnData.actioncardlist
	end

   	--當前卡牌是否被標記了 
    if self.GameFighter_Attacker and self.GameFighter_Attacker.showPlayerEffectStatus then
        local function showPlayerEffectStatusEndCall()
            local function funcSelfSuicideEndCall()
                 self:setCurrentAttackOver()
            end
             self:selfSuicide(funcSelfSuicideEndCall)
        end
	   if not self.GameFighter_Attacker:showPlayerEffectStatus(showPlayerEffectStatusEndCall) then 
            --卡牌掛了
            return 
       end
	end 

	if nTargetDamageInfoListCount <= 0 or self.tbSelfDamageInfoList[macro_pb.Battle_Effect_Skip] then --说明是略过这一回，直接下一轮
        --攻击开始时 旧状态减去1，如果有新状态则顶替旧状态，为了简单客户端目前只留一个状态表现
	    local nSelfStatusId = tbBattleTurnData.self_status
	    local nSelfStatusLevel = tbBattleTurnData.self_statusLv
	    if self.GameFighter_Attacker and self.GameFighter_Attacker.executeStatusProcess then
	    	 self.GameFighter_Attacker:executeStatusProcess(nSelfStatusId, nSelfStatusLevel)
	    end

        local function delayToShowSkip()
		    self:showSkipBeDamage()  
        end
        
        g_Timer:pushTimer(0.5*g_TimeSpeed,  delayToShowSkip)    
		return
	end
	
    self:resetAllTargetHurtDamage(tbBattleTurnData)
  
    if tbBattleTurnData.aursue_atk == 1 then--追击表现
        self:startPursueAttackProcess()
        self.GameFighter_Attacker:showEffectOnGroundByID(
			Enum_SkillLightEffect._PersueAttack, nil, self.GameFighter_Attacker.nPos > 10, nil, Enum_MeshLayer.DamageEffectWord
		)--光效层级设置
    else
        self:executeSkilFireProcess(tbBattleTurnData)
    end
	
	--判断是否是释放绝技，如果是的话就要放技能名字的动画飘字
    if self.GameFighter_Attacker.nSkillIndex > eumn_skill_index.normal_skill and self.GameFighter_Attacker.nSkillIndex < eumn_skill_index.restrike_skill then
	    --技能飘字的动画
        local armatureSkillName = nil
		local skinSkillName = nil
        if self.GameFighter_Attacker.tbFighterBase.Profession == 4 then
            armatureSkillName = self.GameFighter_Attacker:showEffectOnGroundByID(
				Enum_SkillLightEffect._SkillNameAnimation_Blue, nil, self.GameFighter_Attacker.nPos > 10, nil, Enum_MeshLayer.SkillName
			)--光效层级设置
			skinSkillName = CCSkin:create(self:getSkillNameBlue())
        else
            armatureSkillName = self.GameFighter_Attacker:showEffectOnGroundByID(
				Enum_SkillLightEffect._SkillNameAnimation, nil, self.GameFighter_Attacker.nPos > 10, nil, Enum_MeshLayer.SkillName
			)--光效层级设置
			skinSkillName = CCSkin:create(self:getSkillNameRed())
        end

        local animationSkillName = armatureSkillName:getAnimation()
        local boneSkillName = armatureSkillName:getBone("SkillName");  	
	    boneSkillName:addDisplay(skinSkillName, 0)
        boneSkillName:changeDisplayWithIndex(0, true)
    end
	
	--放技能的鬼叫
	if not (eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer()) then
		if g_BattleTeachSystem and g_BattleTeachSystem:IsTeaching() then
			local strBattleSound = self.GameFighter_Attacker.tbFighterBase.BattleSound
			if strBattleSound and strBattleSound ~= "" then
				local tbSoundFileSuffix = string.split(strBattleSound, "|")
				local nMax = #tbSoundFileSuffix
				local nSoundIndex = math.random(1, nMax)
				local strSoundName = self.GameFighter_Attacker.tbFighterBase.SpineAnimation.."_"..tbSoundFileSuffix[nSoundIndex]
				if not TbBattleReport.tbBattleSoundName[strSoundName] then
					TbBattleReport.tbBattleSoundName[strSoundName] = true
					g_playSoundEffect("Sound/Dialogue/"..strSoundName..".mp3")
				end
			end
		else
			local nBattleType = g_BattleData:getEctypeType()
			if (nBattleType == macro_pb.Battle_Atk_Type_normal_pass
				or nBattleType == macro_pb.Battle_Atk_Type_advanced_pass
				or nBattleType == macro_pb.Battle_Atk_Type_master_pass
			) then
				local nEctypeSubID = g_BattleData:getEctypeID()
				local CSV_MapEctypeSub = g_DataMgr:getMapEctypeSubCsv(nEctypeSubID)
				-- if self.GameFighter_Attacker.bLeader or CSV_MapEctypeSub.EctypeID < 4001 then
					local strBattleSound = self.GameFighter_Attacker.tbFighterBase.BattleSound
					if strBattleSound and strBattleSound ~= "" then
						local tbSoundFileSuffix = string.split(strBattleSound, "|")
						local nMax = #tbSoundFileSuffix
						local nSoundIndex = math.random(1, nMax)
						local strSoundName = self.GameFighter_Attacker.tbFighterBase.SpineAnimation.."_"..tbSoundFileSuffix[nSoundIndex]
						if not TbBattleReport.tbBattleSoundName[strSoundName] then
							TbBattleReport.tbBattleSoundName[strSoundName] = true
							g_playSoundEffect("Sound/Dialogue/"..strSoundName..".mp3")
						end
					end
				-- end
			end
		end
	end
end

--追击
function CSkillMgr:startPursueAttackProcess()
    local nCurIndex = 1
    local tbTargetDamageInfoList = self.tbBattleTurnData.actioncardlist
    local tbBattleTurnData = self.tbBattleTurnData
    TbBattleReport.nRepeatAttackNum = TbBattleReport.nRepeatAttackNum + #tbTargetDamageInfoList - 1
    local function executePursueAttackProcess()
        local tbTargetDamageInfo = tbTargetDamageInfoList[nCurIndex]
        if tbTargetDamageInfo then
            nCurIndex = nCurIndex +  1
            tbBattleTurnData.actioncardlist = {}
            table.insert(tbBattleTurnData.actioncardlist, tbTargetDamageInfo)
            self.GameFighter_Attacker:showEffectOnGroundByID(16, nil, self.GameFighter_Attacker.nPos > 10, nil, Enum_MeshLayer.DamageEffectWord)--光效层级设置
            self:executeSkilFireProcess(tbBattleTurnData, executePursueAttackProcess)
        end      
    end

    executePursueAttackProcess()
end

--非追击（普通攻击或者连击）
function CSkillMgr:executeSkilFireProcess(tbBattleTurnData, funcSkilFireProcessEndCall)
	local function executeFireSelfStatusProcess(sender)
		self:executeFlyAttackPorcess()
        --攻击开始时,旧状态减去1,如果有新状态则顶替旧状态,为了简单客户端目前只留一个状态表现
	    local nSelfStatusId = self.tbBattleTurnData.self_status
	    local nSelfStatusLevel = self.tbBattleTurnData.self_statusLv
	    if self.GameFighter_Attacker and self.GameFighter_Attacker.executeStatusProcess then
	    	self.GameFighter_Attacker:executeStatusProcess(nSelfStatusId, nSelfStatusLevel)
	    end 
	end

	local funcAttackSpineEventCall = nil
	--施法特效即攻击特效
	local nFireEffectID = self:getFireEffectID()
	if nFireEffectID > 0 then
		local function executeFireEffectProcess()
			self.GameFighter_Attacker:showEffectOnPlayerByID(nFireEffectID, executeFireSelfStatusProcess, nil, Enum_PosLayer.FireEffect) --光效层级设置
		end
		funcAttackSpineEventCall = executeFireEffectProcess
	else
		funcAttackSpineEventCall = executeFireSelfStatusProcess
	end

    self.tbRepeatedDamageInfoList = tbBattleTurnData.actioncardlist[1].tbRepeatedDamage
    if self.tbRepeatedDamageInfoList then--连击
        self:startMutipleAttackProcess(funcAttackSpineEventCall, tbBattleTurnData, funcSkilFireProcessEndCall)
    else--普通攻击
        self:startSingleAttackProcess(funcAttackSpineEventCall, tbBattleTurnData, funcSkilFireProcessEndCall)
    end
end

function CSkillMgr:startMutipleAttackProcess(funcMutipleAttackSpineEventCall, tbBattleTurnData, funcMutipleAttackSpineEndCall)
    local nFireActionID = self:getCurFireActionID()
    local function excuteMoveBackAction()
		if not TbBattleReport or not self.GameFighter_Attacker or not self.GameFighter_Attacker.isExsit_Layout or self.GameFighter_Attacker:isExsit_Layout() == false then return end
        if nFireActionID == Enum_Action._Action_MeleeAttack then
            local tbPos = g_tbCardPos[self.GameFighter_Attacker.nPos].tbPos
            --飞回来
			local fFlyTime = self.GameFighter_Attacker.fFlyTime or 0
	        local actionFlyBack = CCMoveTo:create(fFlyTime*g_TimeSpeed*1.2, tbPos)
			local actionFlyBackEase = CCEaseOut:create(actionFlyBack, 1.5)
            local arrAct = CCArray:create()
			arrAct:addObject(CCDelayTime:create(0.2*g_TimeSpeed))
            arrAct:addObject(actionFlyBackEase)
			local function executeMoveBackOverEvent()
				self.GameFighter_Attacker:setZOrder(g_tbCardPos[self.GameFighter_Attacker.nPos].nBattleLayer)
				self.GameFighter_Attacker:removeFootAnimation()
				if funcMutipleAttackSpineEndCall then
					funcMutipleAttackSpineEndCall()
				end
			end
			arrAct:addObject(CCCallFuncN:create(executeMoveBackOverEvent))
            local action = CCSequence:create(arrAct)	
	        self.GameFighter_Attacker:runAction(action)
        end
    end

    local nCurrentAttackCount = 1
    local nRepeatedDamageInfoListCount = #self.tbRepeatedDamageInfoList
    TbBattleReport.nRepeatAttackNum = TbBattleReport.nRepeatAttackNum + nRepeatedDamageInfoListCount

    local function funcSpineAnimationEventCall()
        --计算施法者气势
        if tbBattleTurnData.sp and self.GameFighter_Attacker.nSkillIndex == eumn_skill_index.normal_skill then--设置释放者的气势值
            self.GameFighter_Attacker:setCurSp(tbBattleTurnData.sp - (nRepeatedDamageInfoListCount+1) + nCurrentAttackCount)
        end

    	--施法声音
    	if self:getFireSound() ~= 0 then
    		g_playSoundEffectBattle("Sound/Skill/"..self:getFireSound())
    	end
	    
        if nCurrentAttackCount == 1 then
			--
        else
            tbBattleTurnData.self_status = nil
			tbBattleTurnData.self_statusLv = nil
            tbBattleTurnData.actioncardlist[1].def_sp = nil
            tbBattleTurnData.actioncardlist[1].target_status = nil
            tbBattleTurnData.actioncardlist[1].damage = self.tbRepeatedDamageInfoList[nCurrentAttackCount-1]
            tbBattleTurnData.actioncardlist[1].damagetype = nil --状态暂时滞空
            self.GameFighter_Attacker:showEffectOnGroundByID(8, nil, self.GameFighter_Attacker.nPos > 10, nil, Enum_MeshLayer.DamageEffectWord)--光效层级设置
        end

        --回调本轮的下一个流程
        funcMutipleAttackSpineEventCall()
        nCurrentAttackCount = nCurrentAttackCount + 1
    end

    local function funcSpineAnimationEndCall()
        if nCurrentAttackCount > nRepeatedDamageInfoListCount + 1 then
            excuteMoveBackAction() --攻击玩家返回
            if self.GameFighter_Attacker and self.GameFighter_Attacker.isExsit_Layout and self.GameFighter_Attacker:isExsit_Layout() then
            	self.GameFighter_Attacker:runSpineIdle()
            end
        elseif nCurrentAttackCount == nRepeatedDamageInfoListCount + 1 then
        	if self.GameFighter_Attacker and  self.GameFighter_Attacker.isExsit_Layout and self.GameFighter_Attacker:isExsit_Layout() then
        		local szName1 = self:getAttackSpineAction(nCurrentAttackCount)
           	 	self.GameFighter_Attacker:runMutipleAttackSpineAction(szName1, "idle", funcSpineAnimationEventCall, funcSpineAnimationEndCall)
        	end
        else
        	if self.GameFighter_Attacker and self.GameFighter_Attacker.isExsit_Layout and self.GameFighter_Attacker:isExsit_Layout() then
        		local szName1 = self:getAttackSpineAction(nCurrentAttackCount)
				local szName2 = self:getAttackSpineAction(nCurrentAttackCount + 1)
	            self.GameFighter_Attacker:runMutipleAttackSpineAction(szName1, szName2, funcSpineAnimationEventCall, funcSpineAnimationEndCall)
        	end
        end
    end

    local function startMutipleAttackActionCallBack()
    	if self.GameFighter_Attacker and self.GameFighter_Attacker.isExsit_Layout and self.GameFighter_Attacker:isExsit_Layout() then
    		self.GameFighter_Attacker:runMutipleAttackSpineAction("attack1", "attack2", funcSpineAnimationEventCall, funcSpineAnimationEndCall)
    	end
    end

	--施法动作, 远程攻击的在连击的时候不需要等待
    if nFireActionID == Enum_Action._Action_MissileAttack then
        self.GameFighter_Attacker:showActionByID(nFireActionID, nil, nil)
        startMutipleAttackActionCallBack()
    else
	    self.GameFighter_Attacker:showActionByID(nFireActionID, nil, startMutipleAttackActionCallBack)
    end
end

function CSkillMgr:startSingleAttackProcess(funcSingleAttackSpineEventCall, tbBattleTurnData, funcAttackMoveBack)
    local function funcSpineAnimationEventCall()
         --计算施法者气势
        if tbBattleTurnData.sp and self.GameFighter_Attacker.nSkillIndex == eumn_skill_index.normal_skill then--设置释放者的气势值
            self.GameFighter_Attacker:setCurSp(tbBattleTurnData.sp )
        end
    	--施法声音
    	if self:getFireSound() ~= 0 then
    		g_playSoundEffectBattle("Sound/Skill/"..self:getFireSound())
    	end
	    
        --回调本轮的下一个流程
        funcSingleAttackSpineEventCall()
    end
    
    local nFireActionID = self:getCurFireActionID()
    local function funcSpineAnimationEndCall()
		if not TbBattleReport then return end
        if nFireActionID == Enum_Action._Action_MeleeAttack then
        	--防止崩溃 但是此时的 战斗对象的最标 都错了
        	self.GameFighter_Attacker.nPos = self.GameFighter_Attacker.nPos or 3
            local CardPoint = g_tbCardPos[self.GameFighter_Attacker.nPos].tbPos
            --飞回来
			local fFlyTime = self.GameFighter_Attacker.fFlyTime or 0
	        local actionFlyBack = CCMoveTo:create(fFlyTime*g_TimeSpeed*1.2,CardPoint)
			local actionFlyBackEase = CCEaseOut:create(actionFlyBack,2)
            local arrAct = CCArray:create()
			arrAct:addObject(CCDelayTime:create(0.2*g_TimeSpeed))
            arrAct:addObject(actionFlyBackEase)
			local function executeAttackOverEvent()
				self.GameFighter_Attacker:setZOrder(g_tbCardPos[self.GameFighter_Attacker.nPos].nBattleLayer)
				self.GameFighter_Attacker:removeFootAnimation()
				if(funcAttackMoveBack)then
					funcAttackMoveBack()
				end
			end
			arrAct:addObject(CCCallFuncN:create(executeAttackOverEvent))
            local action = CCSequence:create(arrAct)

            if self.GameFighter_Attacker and self.GameFighter_Attacker.isExsit_Layout and self.GameFighter_Attacker:isExsit_Layout() then
            	 self.GameFighter_Attacker:runAction(action)
            end
	       
        else
              if funcAttackMoveBack then
                funcAttackMoveBack()
              end
         end
    end

    local function startAttackActionCallBack()
        self.GameFighter_Attacker:runAttackSpineAction(funcSpineAnimationEventCall, funcSpineAnimationEndCall)
    end

	self.GameFighter_Attacker:showActionByID(nFireActionID, nil, startAttackActionCallBack)  



end

--跳过该回合的计算
function CSkillMgr:showSkipBeDamage()
	local nMax = 0
	local nCurCount = 0
	local function showSkipBeDamageCallBack()
		nCurCount = nCurCount + 1
		if(nCurCount == nMax)then
            self:setCurrentAttackOver()
		end
	end
	
	local funcSkipBeDamageEndCall = showSkipBeDamageCallBack
	--血祭不会导致玩家死亡
	local nSacrifice = self.tbSelfDamageInfoList[macro_pb.Battle_Effect_BloodSacrifice] --血祭
	if(nSacrifice)then
		self.GameFighter_Attacker:showDamage(nSacrifice, funcSkipBeDamageEndCall)
		nMax = nMax + 1
	end
	
	-- 吸血 略过该回合的时候可能有吸血操作
	local nSuckBlood = self.tbSelfDamageInfoList[macro_pb.Battle_Effect_SuckBlood]
	if(nSuckBlood)then
		self.GameFighter_Attacker:showHealing(nSuckBlood, funcSkipBeDamageEndCall) 
		self.tbSelfDamageInfoList[macro_pb.Battle_Effect_SuckBlood] = nil
		nMax = nMax + 1
	end
	
	local tbBleed = self.tbSelfDamageInfoList[macro_pb.Battle_Effect_Bleed] --流血
	if(tbBleed)then
		nMax = nMax + 1
		local function showBleedDamage(nBleedCount, nBleed)
			local function showBleedDamageEffect()
				self.GameFighter_Attacker:showDamage(nBleed)
				if(nBleedCount == #tbBleed)then
                    self:selfSuicide(funcSkipBeDamageEndCall)
				end
			end
			g_Timer:pushTimer(0.4*(nBleedCount - 1), showBleedDamageEffect)
		end

		for i=1, #tbBleed do
			showBleedDamage(i, tbBleed[i])
		end
	end
	
	--防止略过该回合不流血血祭 纯粹加一个状态 不至于流程走不下去
	nMax = nMax + 1
	funcSkipBeDamageEndCall()
end

--第二阶段,飞行阶段,只有飞行结束之后才开始下一个
function CSkillMgr:executeFlyAttackPorcess()
	if g_IsExitBattleProcess then
	    exitBattleProcess()
		return
	end
	
	local tbBattleTurnData = self.tbBattleTurnData
	--血祭不会导致玩家死亡
	local nSacrificeDamage = self.tbSelfDamageInfoList[macro_pb.Battle_Effect_BloodSacrifice] --血祭
	if nSacrificeDamage then
		self.GameFighter_Attacker:showDamage(nSacrificeDamage)
	end
	
	local tbTargetDamageInfoList = tbBattleTurnData.actioncardlist
	local nTargetDamageInfoListCount = #tbTargetDamageInfoList
	local tbGameFighters_OnWnd = TbBattleReport.tbGameFighters_OnWnd
	
    --清空或者初始化一个空表
    gEffectData:setTargetAttackToNil()

	--设置受击列表每个受击单位的数据
	for nDamageSequence = 1, nTargetDamageInfoListCount do
		local nPos = tbTargetDamageInfoList[nDamageSequence].affectinfo
		local GameFighter_Defencer = tbGameFighters_OnWnd[nPos]
		if GameFighter_Defencer ~= nil then
			GameFighter_Defencer:setCurrentTurnDamageInfo(self.GameFighter_Attacker, tbTargetDamageInfoList[nDamageSequence], nDamageSequence) --设置被攻击的伤害包
		end
	end
	
	local nEnumFlyEffectType = self:getFlyEffectType()
	if nEnumFlyEffectType == enum_fly_effect_type.fly_no_need then --类型0，无飞行特效
		self:showAreaAttackEffect()
		return
	end

	local function funcFlyEndCall()
		if g_IsExitBattleProcess then
	        exitBattleProcess()
		    return
	    end
		self:showAreaAttackEffect()
	end
		
	local nFlyEffectID = self:getFlyEffectID()
	if nEnumFlyEffectType == enum_fly_effect_type.fly_to_default and nFlyEffectID > 0 then -- 类型1,飞行到当前默认受击的目标,受击点为卡牌Box的中心点
		local function funcMultipleFlyAttackAllEndCall()		
            local function funcBleedDamageEndCall()
                self:setCurrentAttackOver()
            end
            self:showBeDamage(funcBleedDamageEndCall)
		end
		
		-- 王家麒加入保护机制
		local nCanBeAttackMaxCount = 0
		for nDamageSequence = 1, nTargetDamageInfoListCount do
			local nPos = tbTargetDamageInfoList[nDamageSequence].affectinfo
			local GameFighter_Defencer = tbGameFighters_OnWnd[nPos]
			if GameFighter_Defencer ~= nil then
				nCanBeAttackMaxCount = nCanBeAttackMaxCount + 1
			end
		end
		
		local funcMultipleFlyEffectEndCall = calcCountCallBack(nCanBeAttackMaxCount,  funcMultipleFlyAttackAllEndCall)
		for nDamageSequence = 1, nTargetDamageInfoListCount do
			local nPos =  tbTargetDamageInfoList[nDamageSequence].affectinfo
			local GameFighter_Defencer = tbGameFighters_OnWnd[nPos]
			if GameFighter_Defencer ~= nil then
				local armatureFlyEffect =  self.GameFighter_Attacker:showEffectOnGroundByID(nFlyEffectID, nil, nPos < 10, nil, Enum_MeshLayer.FlyEffect)--默认层级最高
				if not armatureFlyEffect then --错误 没有飞行特效数据 则执行区域特效
					self:showAreaAttackEffect()
					return
				end
				self:showMultipleFlyEffect(armatureFlyEffect, GameFighter_Defencer, funcMultipleFlyEffectEndCall)
			else
				SendError("类型1，飞行到敌方目标，则以技能受击者的中心点为目标位置 位置不存在 "..nPos)
			end
		end
	elseif(nEnumFlyEffectType == enum_fly_effect_type.fly_to_pos_5 and nFlyEffectID > 0)then --类型2,飞到敌方的5号格子,受击点就是5号格子的位置
		local bIsOnRightSide = tbTargetDamageInfoList[1].affectinfo > 10
		local armatureFlyEffect =  self.GameFighter_Attacker:showEffectOnGroundByID(nFlyEffectID, nil, bIsOnRightSide, nil, Enum_MeshLayer.FlyEffect) --默认层级最高
		local nPos = 5
		if not bIsOnRightSide then
			nPos = nPos + 10
		end
		self:showFlyToTargetPos(armatureFlyEffect, funcFlyEndCall, nPos)
	elseif(nEnumFlyEffectType == enum_fly_effect_type.fly_to_nearest_row and nFlyEffectID > 0) then --类型3,飞行到敌方最近一排的中心格子6、5、或4号格子,受击点就是格子的位置
		--[[
		如果是第一排3、6、9号被攻击，则往6号格子的Pos点飞
		如果是第二排2、5、8号被攻击，则往5号格子的Pos点飞
		如果是第三排1、4、7号被攻击，则往4号格子的Pos点飞
		]]--
		local nFlyToPos = 4
		for nDamageSequence = 1, nTargetDamageInfoListCount do
			local nPos = math.mod(tbTargetDamageInfoList[nDamageSequence].affectinfo, 10)
			if(nPos == 3 or nPos == 6 or nPos == 9)then
				nFlyToPos = 6
				break
			elseif(nPos == 2 or nPos == 5 or nPos == 8)then
				nFlyToPos = 5
			end
		end

		local bIsOnRightSide = tbTargetDamageInfoList[1].affectinfo < 10
		local armatureFlyEffect =  self.GameFighter_Attacker:showEffectOnGroundByID(nFlyEffectID, nil, bIsOnRightSide, nil, Enum_MeshLayer.FlyEffect)--默认层级最高
		local nPos = nFlyToPos
		if bIsOnRightSide then
			nPos = nFlyToPos + 10
		end
		self:showFlyToTargetPos(armatureFlyEffect, funcFlyEndCall, nPos)
	elseif(nEnumFlyEffectType == enum_fly_effect_type.fly_from_fixed_to_outside_screen and nFlyEffectID > 0) then --类型4，特效根据受击目标所在的列，同一列多个只一个表现
		self:showFlyToTargets(nFlyEffectID)
	elseif(nEnumFlyEffectType == enum_fly_effect_type.fly_from_fixed_to_target and nFlyEffectID > 0)then --类似5，固定坐标点开始，飞行到目标不穿透，并且同一列可以多个目标光效
		self:showFlyToTargetsMultipleEffect(nFlyEffectID)
	end
end

function CSkillMgr:showFlyToTargetPos(userAction, funcFlyToTargetPosEndCall, nPos)
	local tbTargetPos = g_tbCardPos[nPos]
	local tbTargetPlayer = TbBattleReport.tbGameFighters_OnWnd[nPos]
    local tbPos_CardCenter = tbTargetPlayer:getPlayerCenterPos()
	tbTargetPos = ccpAdd(tbTargetPos, ccp(0, tbPos_CardCenter.y))
	local array = CCArray:create()
	local tbDist = ccpSub(tbTargetPos, userAction:getPosition())
	local nFlyTime = ccpLength(tbDist)/math.max(0, g_nFlyEffectSpeed + userAction.tbEffect.SpeedParam)
	local moveto = CCMoveTo:create(nFlyTime*g_TimeSpeed, tbTargetPos)
	array:addObject(moveto)	
	local function showFlyToTargetPosCallBack(sender)
		sender:removeFromParentAndCleanup(true)
		if funcFlyToTargetPosEndCall then
			funcFlyToTargetPosEndCall()
		end
	end
	array:addObject(CCCallFuncN:create(showFlyToTargetPosCallBack))
	local action = CCSequence:create(array) 		
	userAction:runAction(action)
end

--第三阶段 Area阶段
function CSkillMgr:showAreaAttackEffect()
	if g_IsExitBattleProcess then
	    exitBattleProcess()
		return
	end
	
	--[[
		0，没有AOE光效
		1，全屏AOE，以对方5号格子为中心AOE
		2，每排中心点AOE，以对方6、5、或4号格子为中心，根据敌方所有目标所在的排数，在每排中心点播放1个光效，最多播放3个。
		3，每列中心点AOE，以对方2、5、或8号格子为中心，根据敌方所有目标所在的列数，在每列中心点播放1个光效，最多播放3个。
		4，全屏AOE，以已方5号格子为中心AOE，区域特效为定点播放的特效，且最多只有1个特效被播放，根据描点与
	]]--
	
	local nAreaType = self:getAttackAreaType()
	if nAreaType <= 0 then
		self:executeHitProcess()
		return
	end

	local nAreaEffectID = self:getAttackAreaEffectID()
	if nAreaEffectID <= 0 then
		self:executeHitProcess()
		return
	end	
	
	local nEffectOnGroundMaxCount = 0
	local nEffectOnGroundPlayCount = 0
	local function funcEffectOnGroundEndCall()
		nEffectOnGroundPlayCount = nEffectOnGroundPlayCount + 1
		if nEffectOnGroundMaxCount == nEffectOnGroundPlayCount then
			self:executeHitProcess()
		end
	end 
	
	local tbTargetDamageInfoList = self.tbBattleTurnData.actioncardlist
	local nPos = 0
	if nAreaType == 1 then --全屏AOE，以对方5号格子为中心AOE  --受击方的5号格子 一次攻击只能攻击一方
		if(tbTargetDamageInfoList[1].affectinfo > 10)then
			nPos = 15
		else
			nPos = 5
		end
		self.GameFighter_Attacker:showEffectOnGroundByID(nAreaEffectID, funcEffectOnGroundEndCall, self.GameFighter_Attacker.nPos > 10, nPos, Enum_MeshLayer.AreaEffect)--默认层级最高
		nEffectOnGroundMaxCount = 1
	elseif nAreaType == 2 then --横向, 每排中心点AOE，以对方6、5、或4号格子为中心
		local tbAreaPosList = {}
		local nBasePos = 0
		
		if(tbTargetDamageInfoList[1].affectinfo > 10)then
			nPos = 10
			nBasePos = 10
		else
			nPos = 0
			nBasePos = 0
		end
		
		for nDamageSequence = 1, #tbTargetDamageInfoList do
			local nTargetPos = tbTargetDamageInfoList[nDamageSequence].affectinfo - nBasePos
			if nTargetPos == 3 or nTargetPos == 6 or nTargetPos == 9 then
				tbAreaPosList[1] = 6
			elseif nTargetPos == 2 or nTargetPos == 5 or nTargetPos == 8 then
				tbAreaPosList[2] = 5
			else
				tbAreaPosList[3] = 4
			end
		end
		
		for k, v in pairs(tbAreaPosList)do
			local nTargetPos = v  + nPos
			nEffectOnGroundMaxCount = nEffectOnGroundMaxCount + 1
			self.GameFighter_Attacker:showEffectOnGroundByID(nAreaEffectID, funcEffectOnGroundEndCall , self.GameFighter_Attacker.nPos > 10, nTargetPos, g_tbCardPos[self.GameFighter_Attacker.nPos].nBattleLayer+Enum_EffectLayer.AreaEffect)--光效层级设置
		end
	elseif nAreaType == 3 then --每列中心点AOE，以对方2、5、或8号格子为中心
		local tbAreaPosList = {}
		local nBasePos = 0
		if tbTargetDamageInfoList[1].affectinfo > 10 then
			nPos = 10
			nBasePos = 10
		else
			nPos = 0
			nBasePos = 0
		end
		
		for nDamageSequence = 1, #tbTargetDamageInfoList do
			local nTargetPos = tbTargetDamageInfoList[nDamageSequence].affectinfo - nBasePos
			if nTargetPos == 1 or nTargetPos == 2 or nTargetPos == 3 then
				tbAreaPosList[1] = 2
			elseif nTargetPos == 4 or nTargetPos == 5 or nTargetPos == 6 then
				tbAreaPosList[2] = 5
			else
				tbAreaPosList[3] = 8
			end
		end
		for k, v in pairs(tbAreaPosList)do
			local nTargetPos = v  + nPos
			nEffectOnGroundMaxCount = nEffectOnGroundMaxCount + 1
			self.GameFighter_Attacker:showEffectOnGroundByID(nAreaEffectID, funcEffectOnGroundEndCall , self.GameFighter_Attacker.nPos > 10,  nTargetPos, g_tbCardPos[nTargetPos].nBattleLayer+Enum_EffectLayer.AreaEffect)--光效层级设置
		end
	elseif nAreaType == 4 then --全屏AOE，以已方5号格子为中心AOE
		if tbTargetDamageInfoList[1].affectinfo < 10 then
			nPos = 5
		else
			nPos = 15
		end
		self.GameFighter_Attacker:showEffectOnGroundByID(nAreaEffectID, funcEffectOnGroundEndCall , self.GameFighter_Attacker.nPos > 10, nPos, Enum_MeshLayer.AreaEffect)--光效层级设置
		nEffectOnGroundMaxCount = 1
	elseif nAreaType == 5 then --横排AOE复制单体，在当前的可被攻击的一排，不管九宫格POS上面有没有目标，都播放光效。
        local nPos = tbTargetDamageInfoList[1].affectinfo
		local bIsOnRightSide =  false
		if nPos > 10 then
			nPos = nPos - 10
			bIsOnRightSide = true
		end
		
        nPos = math.mod(nPos-1, 3) + 1
        nEffectOnGroundMaxCount = 3
		self:showMultipleColEffect(nPos, nAreaEffectID, bIsOnRightSide, funcEffectOnGroundEndCall)
	elseif nAreaType ==6 then --纵向AOE复制单体，在当前的可被攻击的一列，不管九宫格POS上面有没有目标，都播放光效。
		--第1~3排光效播放依次有延迟，都为0.2秒
		local nTargetPos = tbTargetDamageInfoList[1].affectinfo
        local bIsOnRightSide =  false
		if nTargetPos > 10 then
			nTargetPos = nTargetPos - 10
			bIsOnRightSide = true
		end
		
		nTargetPos = nTargetPos - 1
		local nRow = (math.floor(nTargetPos/3) + 1)*3  	-- 3 6 9行
        nEffectOnGroundMaxCount = 3
		self:showMultipleRowEffect(nRow, nAreaEffectID, bIsOnRightSide, funcEffectOnGroundEndCall)
	elseif nAreaType ==7 then --全屏AOE复制单体，复制9个目标，在所有九宫格Pos上面播放光效。
		local bIsOnRightSide = tbTargetDamageInfoList[1].affectinfo > 10
        nEffectOnGroundMaxCount = 9
        local nTargetPos = 4
	    local function showEffect()
	    	nTargetPos = nTargetPos - 1
            self:showMultipleColEffect(nTargetPos, nAreaEffectID, bIsOnRightSide, funcEffectOnGroundEndCall)
	    end
        showEffect()
	    g_Timer:pushTimer(0.2, showEffect)
	    g_Timer:pushTimer(0.4, showEffect)
	end
end

--列即排 则从上到下依次对应AreaEffectScale1~AreaEffectScale3参数
function CSkillMgr:showMultipleColEffect(nCol, nEffectID, bRight, funcEffectOnGroundEndCall)
    if(bRight)then nCol = nCol + 10 end
    local index  = nCol
	for i = 0, 2 do--播放无需Delay
		local armature = self.GameFighter_Attacker:showEffectOnGroundByID(nEffectID, funcEffectOnGroundEndCall , index>10, index, g_tbCardPos[index].nBattleLayer+Enum_EffectLayer.AreaEffect)--光效层级设置
        local tbEffect =  armature.tbEffect
		local tbScale = {tbEffect.AreaEffectScale1, tbEffect.AreaEffectScale2, tbEffect.AreaEffectScale3}
        armature:setScale(tbEffect.Scale*tbScale[i+1]/10000)
        index = index + 3
	end
end

--行即纵 则从左到右依次对应AreaEffectScale1~AreaEffectScale3参数
function CSkillMgr:showMultipleRowEffect(nRow, nEffectID, bRight, funcEffectOnGroundEndCall)
    if(bRight)then nRow = nRow + 10 end
    local i = 0
	local function showEffect()
        local index = nRow -i
		local armature = self.GameFighter_Attacker:showEffectOnGroundByID(nEffectID, funcEffectOnGroundEndCall , index>10, index, g_tbCardPos[index].nBattleLayer+Enum_EffectLayer.AreaEffect)--光效层级设置
		local tbEffect =  armature.tbEffect
        local tbScale = {tbEffect.AreaEffectScale3, tbEffect.AreaEffectScale2, tbEffect.AreaEffectScale1}
        armature:setScale(tbEffect.Scale*tbScale[i+1]/10000)
        i = i + 1
	end
	showEffect()
	g_Timer:pushTimer(0.2, showEffect)
	g_Timer:pushTimer(0.4, showEffect)
end

function CSkillMgr:showFlyToTargetsMultipleEffect(nFlyEffectID)
	local tbTargetDamageInfoList = self.tbBattleTurnData.actioncardlist
	local nTargetDamageInfoListCount = #tbTargetDamageInfoList
	
	local nMaxDamageTargetCount = nTargetDamageInfoListCount
	local nDamageTargetCount = 0
	
	local function funcHitEffectProcessEndCall()
		nDamageTargetCount = nDamageTargetCount + 1
		if nDamageTargetCount == nMaxDamageTargetCount then
			self:setCurrentAttackOver()
		end
	end
	
	local function funcFlyToOthersEndCall(nPos)
		local GameFighter_Defencer = TbBattleReport.tbGameFighters_OnWnd[nPos]
		return function(armatureFlyEffect)
			if armatureFlyEffect then --说明是循环特效
				armatureFlyEffect:removeFromParentAndCleanup(true)
			end
			GameFighter_Defencer:executeHitEffectProcess(funcHitEffectProcessEndCall)
		end
	end
	
	for nDamageSequence = 1, nTargetDamageInfoListCount do
		local nPos = tbTargetDamageInfoList[nDamageSequence].affectinfo
			
		local nPosType = 1	
		if nPos < 4 then --1、2、3
			nPosType = 1
		elseif nPos < 7 then --4、5、6
			nPosType = 2
		elseif nPos < 10 then --7、8、9
			nPosType = 3
		elseif nPos < 14 then --11、12、13
			nPosType = 11
		elseif nPos < 17 then --14、15、16
			nPosType = 12
		else --17、18、19
			nPosType = 13
		end
	
		local tbEffectPos = g_tbEffectPos[nPosType]
		tbEffectPos.nBattleLayer = tbEffectPos.nBattleLayer + Enum_EffectLayer.AreaEffect --光效层级设置
		local armatureFlyEffect =  self.GameFighter_Attacker:showFixedPosEffectOnGroundByID(nFlyEffectID, attackFlyTargetCallBack, nPos < 10, tbEffectPos)
		local tbDistPos = ccpSub(armatureFlyEffect:getPosition(), g_tbCardPos[nPos].tbPos)
		local fFlyTime = ccpLength(tbDistPos)/math.max(0, g_nFlyEffectSpeed + armatureFlyEffect.tbEffect.SpeedParam)
		local actionMoveTo = CCMoveTo:create(fFlyTime*g_TimeSpeed, g_tbCardPos[nPos].tbPos)
		local actionArray = CCArray:create()
		actionArray:addObject(actionMoveTo)	
		actionArray:addObject(CCCallFuncN:create(funcFlyToOthersEndCall(nPos)))
		local actionSequence = CCSequence:create(actionArray) 		
		armatureFlyEffect:runAction(actionSequence)
	end
end

function CSkillMgr:showFlyToTargets(nFlyEffectID)
	--目标位置类型是4，特效根据受击目标所在的列，进行如下处理
	local function attackFlyTargetCallBack(pSender)
		if pSender then --说明是循环特效
			pSender:removeFromParentAndCleanup(true)
		end
	end
	
	local tbTargetDamageInfoList = self.tbBattleTurnData.actioncardlist
	local nTargetDamageInfoListCount = #tbTargetDamageInfoList
	local nPosition = nil
	local nOutScreenX = nil
	if tbTargetDamageInfoList[1].affectinfo >  10 then -- 右边位置
		nPosition = 10
		nOutScreenX = 350
	else
		nPosition = 0
		nOutScreenX = -350
	end
		
	local tbPosListInType = {}
	local nMaxEffectCount = 0
	local nPlayEffectCount = 0
	local function funcHitEffectProcessEndCall()
		nPlayEffectCount = nPlayEffectCount + 1
		if nPlayEffectCount == nMaxEffectCount then --说明是循环特效
			self:setCurrentAttackOver()
			tbPosListInType = nil
		end
	end
	
	local function attackFlyTargetShowHit(nPos)
		return function()
			TbBattleReport.tbGameFighters_OnWnd[nPos]:executeHitEffectProcess(funcHitEffectProcessEndCall)
		end
	end
	
	for nDamageSequence = 1, nTargetDamageInfoListCount do
		local nPos = tbTargetDamageInfoList[nDamageSequence].affectinfo - nPosition
		local nPosType = 1
		if(nPos < 4)then -- 1 2 3
			nPosType = 1
		elseif(nPos < 7)then -- 4 5 6 
			nPosType = 2
		else -- 7 8 9 
			nPosType = 3
		end
		
		tbPosListInType[nPosType] = tbPosListInType[nPosType]  or {}
		table.insert(tbPosListInType[nPosType], tbTargetDamageInfoList[nDamageSequence].affectinfo)
	end

	
	--必须从大到小搜索 服务端
	for k, v in pairs (tbPosListInType) do
		local nPosType = nPosition + k
		local tbEffectData = g_tbEffectPos[nPosType]
		tbEffectData.nBattleLayer = tbEffectData.nBattleLayer + Enum_EffectLayer.AreaEffect --光效层级设置
		local userAction =  self.GameFighter_Attacker:showFixedPosEffectOnGroundByID(nFlyEffectID, attackFlyTargetCallBack,nPosition < 10, tbEffectData)
		local array = CCArray:create()
		
		local tbBegin = tbEffectData.tbPos
		local fFlyTime = 0
		for nPosIndex = 1, #v do
			nMaxEffectCount =  nMaxEffectCount + 1
			local nPos = v[nPosIndex]
			local tbToPos =  g_tbCardPos[nPos].tbPos
			local tbDist = ccpSub(tbToPos, tbBegin)
			fFlyTime = ccpLength(tbDist)/math.max(0, g_nFlyEffectSpeed + userAction.tbEffect.SpeedParam)
			local moveto = CCMoveTo:create(fFlyTime*g_TimeSpeed, tbToPos)
			array:addObject(moveto)		
			array:addObject(CCCallFuncN:create(attackFlyTargetShowHit(v[nPosIndex])) )
			tbBegin = tbToPos
		end
		
		local tbByPos = ccp(nOutScreenX, 0)
		fFlyTime = ccpLength(tbByPos)/math.max(0, g_nFlyEffectSpeed + userAction.tbEffect.SpeedParam)
		local moveby = CCMoveBy:create(fFlyTime*g_TimeSpeed, tbByPos)
		array:addObject(moveby)
		array:addObject(CCCallFuncN:create(attackFlyTargetCallBack) )
		local action = CCSequence:create(array) 		
		userAction:runAction(action)
	end
end

--显示飞行特效
function CSkillMgr:showMultipleFlyEffect(armatureFlyEffect, GameFighter_Defencer, funcMultipleFlyEffectEndCall)
	local tbTargetPos = GameFighter_Defencer:getPosition()
    local nPosX,  nPosY = self.GameFighter_Attacker:getPositionXY()
	local fDelayTime = CCDelayTime:create(0.1*g_TimeSpeed)
    local tbPos_CardCenter = GameFighter_Defencer:getPlayerCenterPos()
	local tbToPos = ccp(tbTargetPos.x, tbTargetPos.y + tbPos_CardCenter.y)
    local angel, tbDist = getRate(tbToPos, armatureFlyEffect:getPosition())
    --调整一下角度
    if( armatureFlyEffect.tbEffect.Rotate ~= 0)then
        setRotation(armatureFlyEffect,angel)
    end
    
	local nFlyTime = tbDist/math.max(0, g_nFlyEffectSpeed + armatureFlyEffect.tbEffect.SpeedParam)
	local moveto = CCMoveTo:create(nFlyTime*g_TimeSpeed, tbToPos)

	local function funcHitEffectProcessEndCall()
		if funcMultipleFlyEffectEndCall then
			funcMultipleFlyEffectEndCall()
		end
	end
	
	local function attackFlyToTargetCallBack(armatureFlyEffect)
		if armatureFlyEffect then --说明是循环特效
			armatureFlyEffect:setVisible(false)
		end
		GameFighter_Defencer:executeHitEffectProcess(funcHitEffectProcessEndCall)

		if armatureFlyEffect then --说明是循环特效
			armatureFlyEffect:removeFromParentAndCleanup(true)
			armatureFlyEffect = nil
		end
	end

	local arr1 = CCArray:create()
	arr1:addObject(fDelayTime)
	arr1:addObject(moveto)				
	arr1:addObject(CCCallFuncN:create(attackFlyToTargetCallBack))
	--表现
	local action = CCSequence:create(arr1) 		
	armatureFlyEffect:runAction(action)

	--事件处理
	--g_Timer:pushTimer(nFlyTime*g_TimeSpeed+0.1*g_TimeSpeed, attackFlyToTargetCallBack)
	--attackFlyToTargetCallBack(armatureFlyEffect)

	-- 吸血
	local nSuckBlood = self.tbSelfDamageInfoList[macro_pb.Battle_Effect_SuckBlood]
	if(nSuckBlood)then
		self.GameFighter_Attacker:showHealing(nSuckBlood)
		self.tbSelfDamageInfoList[macro_pb.Battle_Effect_SuckBlood] = nil
	end

end

function CSkillMgr:executeHitProcess()
	if(g_IsExitBattleProcess) then
	    exitBattleProcess()
		return
	end
	self:AttackMultipleHit()
end

--第三阶段 hit阶段
function CSkillMgr:AttackMultipleHit()
	local tbBattleTurnData = self.tbBattleTurnData
	--更新hit的状态

	local tbTargetDamageInfoList = tbBattleTurnData.actioncardlist
	local nTargetDamageInfoListCount = #tbTargetDamageInfoList
	local function funcAllHitEffectProcessEnd()
		local function beDamageCallBack()
			self:setCurrentAttackOver()
		end
		self:showBeDamage(beDamageCallBack)
	end
	
	local funcHitEffectProcessEndCall = calcCountCallBack(nTargetDamageInfoListCount, funcAllHitEffectProcessEnd)
	for nDamageSequence = 1, nTargetDamageInfoListCount do
		local nPos = tbTargetDamageInfoList[nDamageSequence].affectinfo
		local GameFighter_Defencer = TbBattleReport.tbGameFighters_OnWnd[nPos]
		if GameFighter_Defencer then
			GameFighter_Defencer:executeHitEffectProcess(funcHitEffectProcessEndCall)
		else
			self:setCurrentAttackOver()
			return 
		end
	end
	
	-- 吸血
	-- local nSuckBlood = self.tbSelfDamageInfoList[macro_pb.Battle_Effect_SuckBlood]
	-- if(nSuckBlood)then
		-- self.GameFighter_Attacker:showHealing(nSuckBlood)
		-- self.tbSelfDamageInfoList[macro_pb.Battle_Effect_SuckBlood] = nil
	-- end

end

function CSkillMgr:selfSuicide(funcSelfSuicideEndCall)
	--不能完全根据数据层的血量去判断死亡，数据层有可能会先死，比如连击，数据层是直接先连击死亡的
	--if g_BattleMgr:checkFighterIsDeadByPos(self.GameFighter_Attacker.nPos, self.GameFighter_Attacker.nUniqueId) == true then
	if self.GameFighter_Attacker:checkIsDead() == true then
        local GameObj_SkillDamage = CSkillDamge:new()
		--这里有问题额
        GameObj_SkillDamage:setUnderAttackDamageData(self.GameFighter_Attacker, self.GameFighter_Attacker.GameObj_SkillMgr, self)
		GameObj_SkillDamage:killDefencer(funcSelfSuicideEndCall)
	else
		funcSelfSuicideEndCall()
	end
end

--处理伤害 
function CSkillMgr:showBeDamage(funcBleedDamageEndCall)
    --流血 流血 攻击方
	local tbBleedDamageInfoList = self.tbSelfDamageInfoList[macro_pb.Battle_Effect_Bleed] 

    if not tbBleedDamageInfoList then 
        if funcBleedDamageEndCall then
			funcBleedDamageEndCall()
		end
        return 
    end

    local nBleedDamageInfoCount = #tbBleedDamageInfoList
	for nBleedDamageInfoIndex = 1, nBleedDamageInfoCount do
        --减血伤害
        local function showBleedDamageEffect()
            local nBleedDamage = tbBleedDamageInfoList[nBleedDamageInfoIndex]
            local playerSrc = gEffectData:getTargetAttack(nBleedDamageInfoIndex)
            if nBleedDamage < 0 then
                --治疗
                if playerSrc and playerSrc.showHealing then 
                    playerSrc:showHealing(nBleedDamage)
                end
            else
                --伙伴还没有死亡--伤害
                if playerSrc and playerSrc.showDamage then 
                    playerSrc:showDamage(nBleedDamage)
                end
            end

			if nBleedDamageInfoIndex == nBleedDamageInfoCount then
                gEffectData:setTargetAttackToNil()
                self:selfSuicide(funcBleedDamageEndCall)
			end
		end
		g_Timer:pushTimer(0.4*(nBleedDamageInfoIndex - 1), showBleedDamageEffect)
	end
end


function CSkillMgr:setCurrentAttackOver()
	-- 说明这次有反击 设置反击数据 客户端模拟开启下一轮攻击
	local nRestirkeDamage = self.tbSelfDamageInfoList[macro_pb.Battle_Effect_Hit_Back]
	if nRestirkeDamage and self.GameFighter_Attacker:checkIsDead() == false then --群攻技能没有反击情况出现
		local tbBattleTurnData = self.tbBattleTurnData
		local tbBattleTurn_Restrike = {} --自己变成攻击方

		if tbBattleTurnData.actioncardlist[1].def_sp then
			tbBattleTurn_Restrike.sp = tbBattleTurnData.actioncardlist[1].def_sp 
		end
		tbBattleTurn_Restrike.turnno = TbBattleReport.nCurTurn
		tbBattleTurn_Restrike.actioninfo = 500 + tbBattleTurnData.actioncardlist[1].affectinfo --攻击方是受击方
		
		local actioncardlist = {}
		actioncardlist.damage = nRestirkeDamage
		actioncardlist.affectinfo = math.mod(tbBattleTurnData.actioninfo, 100)
		if(tbBattleTurnData.die_sub_apos )then
			actioncardlist.die_sub_apos = tbBattleTurnData.die_sub_apos --反击死亡复活
		else
			if(tbBattleTurnData.die_sub_apos and tbBattleTurnData.die_sub_apos > 0 )then
				actioncardlist.die_sub_apos = tbBattleTurnData.die_sub_apos --反击死亡复活
			end
		end
		
		tbBattleTurn_Restrike.die_drop_info = tbBattleTurnData.die_drop_info 
        tbBattleTurn_Restrike.actioncardlist = {}
        table.insert(tbBattleTurn_Restrike.actioncardlist, actioncardlist)
        --先存起来
        TbBattleReport.tbBattleTurn_Restrike = tbBattleTurn_Restrike
	end

    updateFighterManaBar(self.GameFighter_Attacker.nPos)
    
    if self.tbBattleTurnData.turnno == TbBattleReport.nCurTurn then
		if TbBattleReport and TbBattleReport.GameObj_BattleProcess then
			TbBattleReport.GameObj_BattleProcess:executeNextTurnAttack()
		end
    else
        cclog(TbBattleReport.nCurTurn.."=======error executeNextTurnAttack======="..self.tbBattleTurnData.turnno)
    end  
end

--取攻击动作ID
function CSkillMgr:getCurFireActionID()
	return self.tbSkillData.FireActionID
end

--取受击动作ID
function CSkillMgr:getCurHitActionID()
    return self.tbSkillData.HitActionID
end

--取施法声音
function CSkillMgr:getFireSound()
    return self.tbSkillData.FireSound
end

--取施法特效
function CSkillMgr:getFireEffectID()
    return self.tbSkillData.FireEffect
end

--取施法声音
function CSkillMgr:getHitSound()
    return self.tbSkillData.HitSound
end

--取飞行特效
function CSkillMgr:getFlyEffectID()
    return self.tbSkillData.FlyEffect
end

function CSkillMgr:getFlyEffectType()
    return self.tbSkillData.FlyEffectType
end 

--取受击特效ID
function CSkillMgr:getHitEffectID()
    return self.tbSkillData.HitEffect
end

--取攻击区域类型
function CSkillMgr:getAttackAreaEffectID()
    return self.tbSkillData.AreaEffect
end

--[[左  右
1 2 3  	3 2 1	
4 5 6	6 5 4		
7 8 9	9 8 7]]
function CSkillMgr:getAttackArea()
    return self.tbSkillData.AttackArea
end

--取攻击区域类型
function CSkillMgr:getAttackAreaType()
    return self.tbSkillData.AreaEffectType
end

function CSkillMgr:getAttackSpineAction(nIndex)
	if nIndex == 1 then
		return self.tbSkillData.AttackSpineAction1
	elseif nIndex == 2 then
		return self.tbSkillData.AttackSpineAction2
	elseif nIndex == 3 then
		return self.tbSkillData.AttackSpineAction3
	end
	
    return self.tbSkillData.AttackSpineAction1
end

function CSkillMgr:getAttackSpineAction2()
    return self.tbSkillData.AttackSpineAction2
end

function CSkillMgr:getAttackSpineAction3()
    return self.tbSkillData.AttackSpineAction3
end

function CSkillMgr:getSpineActionSpeed()
    return self.tbSkillData.SpineAccelaration
end

function CSkillMgr:getSkillNameRed()
    return "CocoAnimation/SkillName/Red/"..self.tbSkillData.SkillNameIcon..".png"
end

function CSkillMgr:getSkillNameBlue()
    return "CocoAnimation/SkillName/Blue/"..self.tbSkillData.SkillNameIcon..".png"
end

