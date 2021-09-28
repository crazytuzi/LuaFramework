--------------------------------------------------------------------------------------
-- 文件名:	Card.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2013-12-27 15:24
-- 版  本:	1.0
-- 描  述:	怪物
-- 应  用:
---------------------------------------------------------------------------------------

-- 创建CPlayer类继承UILayout
CPlayer = class("CPlayer", function() return Layout:create() end)
CPlayer.__index = CPlayer

-- 计数回调函数
function calcCountCallBack(nMaxCount, funcCallBack)
    local nCurCount = 0
    if (not funcCallBack) then
        return nil
    end

    return function()
        nCurCount = nCurCount + 1
        if (nCurCount == nMaxCount) then
            -- 最后一个了
            funcCallBack()
        end
    end
end	

function CPlayer:ctor()
	
	self.nUniqueId = 0

    self.initMaxHp = 0
    -- 初始最大血量上限
    self.nMaxHp = 0
    self.nCurHp = 0

    -- 常量 初始最大怒气上限 这个值不修改用于恢复到最初的怒气上限
    self.initMaxSp = 0
    self.nMaxSp = 0
    self.nCurSp = 0
    self.nInitSp = 0

    self.nPos = 0
    -- 卡牌阵形位置  取数组使用时大于9需减10
    self.fCardScale = 0
    self.fPosScale = 0

    self.nStarLevel = 0
    -- 星级
    self.nLevel = 0
    -- 等级
    self.nEvoluteLevel = 0
    -- 突破等级
    self.tbFighterBase = nil
    self.tbPos_HP = ccp(0, 0)
    self.tbPos_CardCenter = ccp(0, 0)

    self.Label_Name = nil
    -- 战斗中的伙伴名称--Label:create()

    self.LoadingBar_HP = nil
    -- 血量进度条--LoadingBar:create()
    self.Image_HP = nil
    -- 血量背景图	

    self.LoadingBar_Mana = nil
    -- 怒气进度条--LoadingBar:create()
    self.Image_Mana = nil
    -- 怒气背景图

    self.CCNode_Skeleton = nil
    -- 骨骼动画
    self.Image_Card = nil
    --
    self.Image_Shadow = nil
    -- 影子

    self.Layout_CardClickArea = nil
	
	self.nFighterAttackCount = 0
	
	self.bIsDead = false
end

--[[
	@param tbBattleInfo
	@param cvsBase
	@param paramPos = {
		nPos,nPosHpY,nPosHpX,nPosX,nPosY
	}
]]
function CPlayer:creationCard(tbBattleInfo, cvsBase, paramPos, nCardScale, bAddLayout)

    local nPos = paramPos.nPos
    local nPosHpY = paramPos.nPosHpY
    local nPosHpX = paramPos.nPosHpX
    local nPosX = paramPos.nPosX
    local nPosY = paramPos.nPosY

    self.tbFighterBase = cvsBase

    local cardCenterPosX = cvsBase.CardWidth * nCardScale * 0.5
    local cardCenterPosY =(cvsBase.CardHeight * nCardScale - nPosY) * 0.5
    self.tbPos_CardCenter = ccp(cardCenterPosX, cardCenterPosY)

    self.nStarLevel = tbBattleInfo.star_lv
    self.nLevel = tbBattleInfo.card_lv
    -- self.nEvoluteLevel = tbBattleInfo.breachlv

    self.initMaxHp = tbBattleInfo.max_hp
    self.nMaxHp = tbBattleInfo.max_hp
    self.nCurHp = tbBattleInfo.hp or self.nMaxHp

    -- 常量 初始最大怒气上限 这个值不修改用于恢复到最初的怒气上限
    self.initMaxSp = tbBattleInfo.max_sp
    self.nMaxSp = tbBattleInfo.max_sp
    self.nCurSp = tbBattleInfo.init_sp or tbBattleInfo.sp
    self.nInitSp = self.nCurSp

    self.fCardScale = nCardScale
    self.fPosScale = g_tbCardPos[nPos].Scale


    self.LoadingBar_HP = LoadingBar:create()
    self.LoadingBar_HP:loadTexture(getBattleImg("Bat_BarHP"))
    self.LoadingBar_HP:setPercent(100)

    self.Image_HP = self:createUIImageVeiw(getBattleImg("Bat_Bar"), nPosHpX, nPosHpY + g_nManaOffset)
    self.Image_HP:addChild(self.LoadingBar_HP)
    self:addChild(self.Image_HP, 3)

    self.LoadingBar_Mana = LoadingBar:create()
    self.LoadingBar_Mana:loadTexture(getBattleImg("Bat_Mana"))
    self.LoadingBar_Mana:setPercent(100)

    self.Image_Mana = self:createUIImageVeiw(getBattleImg("Bat_Mana_Base"), nPosHpX, nPosHpY - 4)
    self.Image_Mana:addChild(self.LoadingBar_Mana)
    self:addChild(self.Image_Mana, 3)

    self.CCNode_Skeleton = g_CocosSpineAnimation(cvsBase.SpineAnimation, 1)
    self.Image_Card = ImageView:create()
    self.Image_Card:loadTexture(getUIImg("Blank"))
    self.Image_Card:setAnchorPoint(ccp(0.5, 0.0))
    self.Image_Card:setScale(nCardScale)
    self.Image_Card:setPositionXY(nPosX, nPosY)
    self.Image_Card:addNode(self.CCNode_Skeleton)
    self:addChild(self.Image_Card, 2)

    self:setPosition(g_tbCardPos[nPos].tbPos)
    self:setScale(g_tbCardPos[nPos].Scale)

    self:runSpineIdle()

    self:setCascadeColorEnabled(true)
    self:setCascadeOpacityEnabled(true)

    local cardClicAreaX = nPosX - cvsBase.CardWidth * nCardScale / 2
    local cardClicAreaY = nPosY
    local areaWidth = cvsBase.CardWidth * nCardScale
    local areaHeight = cvsBase.CardHeight * nCardScale
    self.Layout_CardClickArea = Layout:create()
    self.Layout_CardClickArea:setPositionXY(cardClicAreaX, cardClicAreaY)
    self.Layout_CardClickArea:setSize(CCSize(areaWidth, areaHeight))
    self:addChild(self.Layout_CardClickArea)

    local function onPressing_Image_Card(pSender, nTag)
        local nBattleType = TbBattleReport.tbBattleScenceInfo.battle_type
        if nBattleType == macro_pb.Battle_Atk_Type_normal_pass then
            -- 普通关卡
            local nEctypeSubID = TbBattleReport.tbBattleScenceInfo.mapid
            local CSV_MapEctypeSub = g_DataMgr:getMapEctypeSubCsv(nEctypeSubID)
            if CSV_MapEctypeSub.EctypeID == 1001 then
                return
            end
        end

        if not g_BattleTeachSystem:IsTeaching() then
			g_WndMgr:showWnd("Game_BattleFighterInfo", self)
        end
    end
    local function onCleanUpEvent(pSender, nTag)
        if g_WndMgr:getWnd("Game_BattleFighterInfo") and g_WndMgr:isVisible("Game_BattleFighterInfo") then
            g_WndMgr:closeWnd("Game_BattleFighterInfo")
        end
    end
    g_SetBtnWithPressingEvent(self.Layout_CardClickArea, nPos, onPressing_Image_Card, nil, onCleanUpEvent, true, 0.0)

    preLoadResouce(self)

    if bAddLayout then
        TbBattleReport.Mesh:addChild(self, g_tbCardPos[nPos].nBattleLayer)
    else
        self:retain()
    end

    self:setLoadingBarSp(false)
    self:hideHeadInfoHurtAction(true)
	
	self.bIsDead = false
end


function CPlayer:getSkeleton()
    return self.CCNode_Skeleton:clone()
end



function CPlayer:startRunInScreen(funcCallBack, fDelayTime)
    self:actionRunInScreen(funcCallBack, fDelayTime)
end

function CPlayer:startBornAction(funcCallBack)
    local function bornCallBack()
        if funcCallBack then funcCallBack() end
        if self.runSpineIdle then
            self:runSpineIdle()
        end
    end
    self:showTiBuAppearAction(bornCallBack)
end

function CPlayer:excuteFighterAttackProcess()
    if not TbBattleReport.tbBattleTurn_Restrike then
        if TbBattleReport.nLastAttackPos and TbBattleReport.nLastAttackPos == self.nPos then
            -- 显示连击动画
            self:showEffectOnGroundByID(Enum_SkillLightEffect._DoubleHit, nil, self.nPos > 10, nil, Enum_MeshLayer.DamageEffectWord)
        end
        TbBattleReport.nLastAttackPos = TbBattleReport.nCurrentAttackPos
    else
        TbBattleReport.tbBattleTurn_Restrike = nil
    end

    self.GameObj_SkillMgr:excuteSkillAttackProcess()
end

function CPlayer:setCurSp(nSp)
    if self.nPos < 10 and self.nCurSp <= nSp then
        self.bAddSp = true
    else
        self.bAddSp = nil
    end

    self.nCurSp = math.min(self.nMaxSp, nSp)
    updateFighterManaBar(self.nPos)
end

-- nMaxSp  怒气上限值
function CPlayer:setMaxSp(maxSp)

    self.nMaxSp = maxSp < 0 and 2 or maxSp;
    updateFighterManaBar(self.nPos)
end

function CPlayer:resetSp(nSp)
    self.nCurSp = nSp
    self.nMaxSp = nSp
end

-- 血量上限值
function CPlayer:setMaxHp(maxHp)

    self.nMaxHp = maxHp < 0 and 2 or maxHp
    self.LoadingBar_HP:setPercent(math.floor(100 * self.nCurHp / self.nMaxHp))

end

function CPlayer:checkUseSkill(nIndex)
    local nNeedEnergy = TbBattleReport.tbSkillData[self.nPos][nIndex].NeedEnergy
    return self.nCurSp >= nNeedEnergy, nNeedEnergy
end

-- 攻击开始时 旧状态减去1，如果有新状态则顶替旧状态，为了简单客户端目前只留一个状态表现
function CPlayer:executeStatusProcess(nStatusID, nStatusLevel)
    -- 攻击一次算一回合
    if nStatusID and nStatusID > 0 then
        if not self.nStatusCount then
            self:showStatusEffect(nStatusID, nStatusLevel)
        end
    end

    if self.nStatusCount then
        -- 有怒气效果的时候
        self:manaEffectStatus()
        if self.nStatusCount < 1 then
            self:removeStatus()
            self.nStatusCount = nil
        else
            self.nStatusCount = self.nStatusCount - 1
        end
    end
end

-- 計算傷害 和 傷害數字向上飄動畫
function CPlayer:showDamage(nDamage, funcCallBack)
    self:setCurrentHp(nDamage)
    self:showPiaoZiAnimation("Bat_Num", "Damage", nDamage, 25, funcCallBack)
end

function CPlayer:showCriticalDamage(nDamage, funcCallBack)
    self:setCurrentHp(nDamage)
    self:showPiaoZiAnimation("Bat_NumCritical", "Damage", nDamage, 30, funcCallBack)
end

-- 治療
function CPlayer:showHealing(nDamage, funcCallBack)
    self:setCurrentHp(nDamage)
    self:showPiaoZiAnimation("Bat_Heal", "Healing", -nDamage, 25, funcCallBack)
end

function CPlayer:showCriticalHealing(nDamage, funcCallBack)
    self:setCurrentHp(nDamage)
    self:showPiaoZiAnimation("Bat_HealCritical", "Healing", -nDamage, 30, funcCallBack)
end

-- 复杂的函数啊
function CPlayer:showPiaoZiAnimation(szName, szAniName, nDamage, nWidth, funcCallBack)
    local batchNode = self.batchNode
    if (not batchNode) then
        batchNode = CCBatchNode:create()
        self.batchNode = batchNode
        if TbBattleReport and TbBattleReport.Mesh and TbBattleReport.Mesh:isExsit() then
            TbBattleReport.Mesh:addNode(self.batchNode, Enum_MeshLayer.Damage)
        else
            return false
        end
    end
  
    local leng = tostring(nDamage)
    local tbDamage = { }
    for i = 1, string.len(leng) do 
        local nNum = math.mod(nDamage, 10)
        nNum = math.abs(nNum)
        nDamage = math.floor(nDamage / 10)
        table.insert(tbDamage, math.floor(nNum))
    end

--    while true do
--        local nNum = math.mod(nDamage, 10)
--        nNum = math.abs(nNum)
--        nDamage = math.floor(nDamage / 10)
--        table.insert(tbDamage, math.floor(nNum))
--        if (nDamage == 0) then
--            break
--        end
--    end
    table.insert(tbDamage, 10)

    local nMax = #tbDamage
    local nPosX = 0
    local showDamageCallBack = calcCountCallBack(nMax, funcCallBack)
    local tbEffect = g_DataMgr:getSkillLightEffectCsv(Enum_SkillLightEffect._Damage)

    for index = #tbDamage, 1, -1 do
        local armature, userAnimation = g_CreateBattleJsonAnimation(tbEffect.File, showDamageCallBack, tbEffect)
        if armature then
            local userAnimation = armature:getAnimation()
            userAnimation:setSpeedScale(g_nBaseSpeed + g_nPiaoZiAccelaration +(TbBattleReport.nAccelerateSpeed - 1) * g_nAnimationSpeed)
            armature:setScale(tbEffect.Scale / 100)

            local bone = armature:getBone("Layer1");
            local numbername = szName .. tbDamage[index] .. ".png"
            local numSkin = CCSkin:createWithSpriteFrameName(numbername)
            bone:addDisplay(numSkin, 0)
            bone:changeDisplayWithIndex(0, true)
            local size = numSkin:getContentSize()
            -- 居中
            armature:setPositionX(nPosX)
            userAnimation:play("Damage")
            nPosX = nPosX + size.width + 2
            batchNode:addChild(armature, 10, index)

            g_SetBlendFuncSprite(armature, 0)
        end
    end
    batchNode:setPositionXY(self:getPosition().x + self.tbPos_HP.x - nPosX / 2, self:getPosition().y + self.tbPos_HP.y + 25)

    self:addSPAnimation()
    return true
end

function CPlayer:showWorldBossDrop(index)
    if g_BattleData:checkWorldBoss() then
        local tbDamageInfo = self.tbSkillDamageList_Hurt[index]
        if tbDamageInfo then
            local tbDropItems = tbDamageInfo.die_drop_info
            self:addDeadDropItemsDetail(tbDropItems)
        end
    end
end

-- 设置本轮玩家攻击数据
function CPlayer:setCurrentTurnAttackData(tbBattleTurnData)
    --行动信息百位数表示技能Index,十位数表示攻方还是守方,个位数表示行动的阵位
    self:setSkillIndex(math.floor(tbBattleTurnData.actioninfo/100))
	cclog("==释放技能者=="..self:getName().."==setSkillIndex=="..math.floor(tbBattleTurnData.actioninfo/100))
    self.GameObj_SkillMgr = CSkillMgr:new()
    self.GameObj_SkillMgr:setAttackSkillData(self, TbBattleReport.tbSkillData[self.nPos][self.nSkillIndex], tbBattleTurnData)
    self.tbBattleTurnData = tbBattleTurnData

    if tbBattleTurnData.die_sub_apos then
    end

    if tbBattleTurnData.die_drop_info then
    end

    self:excuteFighterAttackProcess()
end

function CPlayer:showAddSpAniton()
    if self.nPos < 10 and TbBattleReport.nCurrentAddManaPos and TbBattleReport.nCurrentAddManaPos == self.nPos then
        local TbBattleWnd = TbBattleReport.TbBattleWnd
        local function showAnimationEnd()
            local EnergyFull = TbBattleWnd.EnergyNormal:getBone("EnergyFull")
            local tempSp = 1
            local tempMaxSp = 1
            if self.nCurSp and
                self.nMaxSp and
                self.nCurSp >= self.nMaxSp then

                EnergyFull:setOpacity(255)
                tempSp = self.nCurSp
                tempMaxSp = self.nMaxSp
            else
                EnergyFull:setOpacity(0)
            end
            TbBattleWnd.Panel_Energy:setSize(CCSize(160, 160 * tempSp / tempMaxSp))
        end

        if self.bAddSp then
            local armature, userAnimation = g_CreateCoCosAnimation("EnergyRecover", showAnimationEnd, 6)
            local widget = TbBattleWnd.tbWidgetSkillIcon[1]
            widget:addNode(armature, 100)
            userAnimation:playWithIndex(0)
            armature:setPositionXY(26, -7)
            armature:setScaleX(1.3)
            armature:setScaleY(1.28)
            armature:setRotation(-2)
            self.bAddSp = nil
        else
            showAnimationEnd()
        end
    end
end

function CPlayer:addSPAnimation()
    if (self.nCurSp >= g_nMaxSp) then
        local nEffectID = nil
        if (self.tbFighterBase.Profession == 4) then
            nEffectID = 12
        else
            nEffectID = 11
        end
        --        if(not self.armatureSp)then
        -- 去掉满怒气特效
        --        end

        updateFighterManaBar(self.nPos)
    end
    self:showAddSpAniton()
end

function CPlayer:delSPAnimation()
    if (self.nCurSp < g_nMaxSp) then
        local nEffectID = nil
        if (self.tbFighterBase.Profession == 4) then
            nEffectID = 11
        else
            nEffectID = 12
        end
        if (self.armatureSp) then
            self.armatureSp:removeFromParentAndCleanup(true)
            self.armatureSp = nil
        end

        updateFighterManaBar(self.nPos)
    end
end

-- 设置本轮玩家受击数据
function CPlayer:setCurrentTurnDamageInfo(GameFighter_Attacker, tbDamageInfo_Hurt, nDamageSequence)
    local nPos_Atk = GameFighter_Attacker.nPos
    
    local GameObj_SkillDamge = CSkillDamge:new()
    GameObj_SkillDamge:setUnderAttackDamageData(self, tbDamageInfo_Hurt, GameFighter_Attacker.GameObj_SkillMgr, nPos_Atk)
	if self.tbSkillDamageList_Hurt then
		table.insert(self.tbSkillDamageList_Hurt, GameObj_SkillDamge)
	end
    --保存被攻击的对象 每次攻击前数据清空 现在只在技能特效第一回合起效果
    gEffectData:setTargetAttack(nDamageSequence, self)

    --累计伤害值 计算对怪物造成的伤害
    if self.nPos > 9 then
        g_BattleDamage:TotalDamage(tbDamageInfo_Hurt.damage)
    end

    if tbDamageInfo_Hurt.def_sp then
        self:setCurSp(tbDamageInfo_Hurt.def_sp)
    end

    -- 怒气上限改变
    if tbDamageInfo_Hurt.maxSp then
        self:setMaxSp(tbDamageInfo_Hurt.maxSp)
    end

    if tbDamageInfo_Hurt.maxHp then
        self:setMaxHp(tbDamageInfo_Hurt.maxHp)
    end

    self.tbTestHp = self.tbTestHp or { }
    table.insert(self.tbTestHp, {tbDamageInfo_Hurt.damage, GameFighter_Attacker.tbBattleTurnData.turnno})
end

--重置自己对所有目标的伤害列表
function CPlayer:resetSkillDamageList_Hurt()
    if TbBattleReport.tbMutileAttack then
        if TbBattleReport.bReset then
            return
        else
            TbBattleReport.bReset = true
        end
    end

    self.nFighterAttackCount = 0
    self.tbSkillDamageList_Hurt = {}
end

--[[
	受击特效如果是Plist，特效，声音，动作一起播，伤害飘字在动作回调里播
	受击如果是cocos，在cocos动画回调里同时播声音，动作，伤害飘字在动作回调里播
]]--
function CPlayer:executeHitEffectProcess(funcHitEffectProcessEndCall)
    self.nFighterAttackCount = self.nFighterAttackCount + 1
    local GameObj_SkillDamge = self.tbSkillDamageList_Hurt[self.nFighterAttackCount]
    GameObj_SkillDamge:executeHitEffectProcess(funcHitEffectProcessEndCall, self.nFighterAttackCount)
end

function CPlayer:changeCardByDead(func, tbReliveData)

    local function createCard(reliveData, side, nUniqueId)
        local object = nil
        if reliveData.is_card then
            -- 伙伴
            object = CCardPlayer.new()
        else
            -- 怪物
            object = CMonsterPlayer.new()
        end
        object:retain()
        object:initData(reliveData, side, true, nUniqueId)
        return object
    end

    if (self.nPos < 10) then
		local nUniqueId = tbReliveData.arraypos
        tbReliveData.arraypos = self.nPos

        if TbBattleReport.tbGameFighters_OnWnd[self.nPos] then
            TbBattleReport.tbGameFighters_OnWnd[self.nPos]:release()
        end

        local object = createCard(tbReliveData, 1, nUniqueId)
        if tbReliveData.is_card then
            -- 伙伴
            TbBattleReport.tbGameFighters_OnWnd[self.nPos].cardid = tbReliveData.cardid
            TbBattleReport.tbGameFighters_OnWnd[self.nPos].arraypos = self.nPos
        end

        object:startBornAction(func)

        TbBattleReport.tbGameFighters_OnWnd[self.nPos] = object

        preLoadResouce(TbBattleReport.tbGameFighters_OnWnd[self.nPos])
    else
		local nUniqueId = 100 + tbReliveData.arraypos
        tbReliveData.arraypos = self.nPos - 10
        local object = createCard(tbReliveData, 2, nUniqueId)
        object:startBornAction(func)
        object.CCNode_Skeleton:setScaleX(-1)

        if TbBattleReport.tbGameFighters_OnWnd[self.nPos] then
            TbBattleReport.tbGameFighters_OnWnd[self.nPos]:release()
        end
        TbBattleReport.tbGameFighters_OnWnd[self.nPos] = object


        -- 怪物的位置本来就是11-19 而替补是从10-12 所有有11和12号位置冲突\
        local nCurPos = self.nPos - 10
        if (not TbBattleReport.tbSubsitutionFighterList_Def[nCurPos]) then
            TbBattleReport.tbSubsitutionFighterList_Def[nCurPos] = 1
        else
            TbBattleReport.tbSubsitutionFighterList_Def[nCurPos] = TbBattleReport.tbSubsitutionFighterList_Def[nCurPos] + 1
        end

        preLoadResouce(TbBattleReport.tbGameFighters_OnWnd[self.nPos])
    end

    TbBattleReport.tbGameFighters_OnWnd[self.nPos]:showEffectOnGroundByID(Enum_SkillLightEffect._TiBuChuChang, nil, nil, nil, Enum_MeshLayer.DamageEffectWord)
    -- 光效层级设置
    TbBattleReport.tbGameFighters_OnWnd[self.nPos]:showEffectOnGroundByID(Enum_SkillLightEffect._SummonTiBu, nil, nil, nil, g_tbCardPos[self.nPos].nBattleLayer + Enum_EffectLayer.TiBuEffect)
    -- 光效层级设置
    updateSkillPlayerList(2, self.nPos)

    local tbPlayerOlder = self
    tbPlayerOlder:removeFromParentAndCleanup(true)
    tbPlayerOlder = nil
end

--
function CPlayer:removeStatus()
    if (self.AniStatusLightEffect) then
        self.AniStatusLightEffect:removeFromParentAndCleanup(true)
        self.AniStatusLightEffect = nil
    end
end

-- 重置血量
function CPlayer:resetNewRoundInfo()
    self:removeStatus()

    -- 每轮战斗开始 回满血
    self:setCurrentHp(- self.nMaxHp)
    self:setCurSp(self.nInitSp)
    self:setMaxSp(self.initMaxSp)
	self:setIsDead(false)
    self.nAutoSkillIndex = 1
    self.tbTestHp = {}
end

-- 设置目前的技能释放类型  1是普通攻击 2是第一个技能 3是第二个技能 
function CPlayer:setSkillIndex(nSkillIndex)
    self.nSkillIndex = nSkillIndex
end

-- 计算血量
function CPlayer:setCurrentHp(nDamage)

	self.nCurHp = self.nCurHp - nDamage
	self.nCurHp = math.max(self.nCurHp, 0)
	self.nCurHp = math.min(self.nCurHp, self.nMaxHp)
	
	if self.nCurHp <= 0 then
		--检测数据层的是否真的已死亡，两边数据要同步
		if g_BattleMgr:checkFighterIsDeadByPos(self.nPos, self.nUniqueId) == true then
			self.bIsDead = true
		else
			self.nCurHp = 1
			self.bIsDead = false
		end
	end
	
    self.LoadingBar_HP:setPercent(math.floor(100 * self.nCurHp / self.nMaxHp))
end


function CPlayer:checkIsDead()
	return self.bIsDead
end

function CPlayer:setIsDead(bIsDead)
	self.bIsDead = bIsDead
end

function CPlayer:createUIImageVeiw(szPic, posX, posY, plist)
    plist = plist or UI_TEX_TYPE_PLIST
    local imageView = ImageView:create()
    imageView:loadTexture(szPic, plist)
    imageView:setPositionXY(posX, posY)

    return imageView
end

function CPlayer:listerEventToChangeToIdle(func)
    local function addEvnetLister(pSender, eventType, nLoopCout, szName)
        if eventType == ccs.spEventType.SP_ANIMATION_COMPLETE then
			if self.CCNode_Skeleton then
				self.CCNode_Skeleton:cancelEventListener()
			end
            self:runSpineIdle()
            if func then func() end
        end
    end
    self.CCNode_Skeleton:cancelEventListener()
    self.CCNode_Skeleton:addEventListener(addEvnetLister)
end

function CPlayer:runSpineCelebrate(func)
    if not TbBattleReport then return false end

    self.CCNode_Skeleton:setSpeed(g_nBaseSpeed + g_nSpineCelebrateAccelaration +(TbBattleReport.nAccelerateSpeed - 1) * g_nAnimationSpeed * g_nSpineCelebrateSpeedParam)
    local animationName = self.CCNode_Skeleton:checkAnimationName("celebrate", "attack1")
    self.CCNode_Skeleton:setAnimation(0, animationName, false)
    local function celebrateEndCall()
        if func then
            func()
            func = nil
        end
    end
    self:listerEventToChangeToIdle(celebrateEndCall)

    return true
end

function CPlayer:runSpineIdle()
    if not TbBattleReport then return false end

    self.CCNode_Skeleton:setSpeed(g_nBaseSpeed + g_nSpineIdleAccelaration +(TbBattleReport.nAccelerateSpeed - 1) * g_nAnimationSpeed * g_nIdleSpeedParam)
    self.CCNode_Skeleton:setAnimation(0, "idle", true)
    self.bIsInIdleStatus = true

    return true
end

function CPlayer:runSpineHurt(func)
    if not TbBattleReport then return false end

    local function addEvnetLister(pSender, eventType, nLoopCout, szName)
        if eventType == ccs.spEventType.SP_ANIMATION_EVENT or fDuration == 0 then
            self:hideHeadInfoHurtAction(true)
            if func then
                func()
                func = nil
            end
        elseif eventType == ccs.spEventType.SP_ANIMATION_COMPLETE then
            self:hideHeadInfoHurtAction(false)
			if self.CCNode_Skeleton then
				self.CCNode_Skeleton:cancelEventListener()
			end
            self:runSpineIdle()
        end
    end
    self.CCNode_Skeleton:addEventListener(addEvnetLister)
    self.CCNode_Skeleton:setSpeed(g_nBaseSpeed + g_nSpineHurtAccelaration +(TbBattleReport.nAccelerateSpeed - 1) * g_nAnimationSpeed * g_nSpineHurtSpeedParam)
    self.CCNode_Skeleton:setAnimation(0, "hurt", false)

    return true
end

function CPlayer:runSpineWalk(func)
    if not TbBattleReport then return false end

    local animationName = "walk"
    self.CCNode_Skeleton:setSpeed(g_nBaseSpeed + g_nSpineWalkAccelaration +(TbBattleReport.nAccelerateSpeed - 1) * g_nAnimationSpeed * g_nSpineWalkSpeedParam)
    self.CCNode_Skeleton:setMix(animationName, "celebrate", 0.1)
    self.CCNode_Skeleton:setMix("celebrate", "idle", 0.1)
    self.CCNode_Skeleton:setAnimation(0, animationName, true)

    return true
end

local nTimeScaleSingle = 0

-- 攻击动作
function CPlayer:runAttackSpineAction(funcEvent, funcEnd)
    self.bIsInIdleStatus = false

    local szName = self.GameObj_SkillMgr:getAttackSpineAction(1)
    local nSpeed = self.GameObj_SkillMgr:getSpineActionSpeed()
    if szName ~= "" then
        szName = self.CCNode_Skeleton:checkAnimationName(szName, "attack1")
        if not szName then
        end
        local fDuration = self.CCNode_Skeleton:getAnimationDuration(szName)
        local fMixTime = fDuration * nTimeScaleSingle / nSpeed
        local function addEvnetLister(pSender, eventType, nLoopCout, szName)
            if eventType == ccs.spEventType.SP_ANIMATION_EVENT or fDuration == 0 then
                if funcEvent then
                    funcEvent()
                    funcEvent = nil
                end
            end
            if eventType == ccs.spEventType.SP_ANIMATION_COMPLETE then
				if self.CCNode_Skeleton then
					self.CCNode_Skeleton:cancelEventListener()
				end
                self:runSpineIdle()
                g_Timer:pushTimer(fMixTime, funcEnd)
            end
        end
        self.CCNode_Skeleton:addEventListener(addEvnetLister)

        self.CCNode_Skeleton:setMix(szName, "idle", fMixTime)
        self.CCNode_Skeleton:setSpeed(
			(
				g_nBaseSpeed
				+ g_nSpineAttackAccelaration
				+ (TbBattleReport.nAccelerateSpeed - 1)
				* g_nAnimationSpeed
				* g_nSpineAttackSpeedParam
			) * nSpeed / 100
		)
        self.CCNode_Skeleton:setAnimation(0, szName, false)
    end
end

local nTimeScaleMutiple = 0
function CPlayer:runMutipleAttackSpineAction(szName, szMixName, funcEvent, funcEnd)
    self.bIsInIdleStatus = false

    szName = self.CCNode_Skeleton:checkAnimationName(szName, "attack1")
    local fDuration = self.CCNode_Skeleton:getAnimationDuration(szName)
    local nSpeed = self.GameObj_SkillMgr:getSpineActionSpeed()
    local fMixTime = fDuration * nTimeScaleMutiple / nSpeed
    local function addEvnetLister(pSender, eventType, nLoopCout, szName)
        if eventType == ccs.spEventType.SP_ANIMATION_EVENT or fDuration == 0 then
            if funcEvent then
                funcEvent()
                funcEvent = nil
            end
        end
        if eventType == ccs.spEventType.SP_ANIMATION_COMPLETE then
			if self.CCNode_Skeleton then
				self.CCNode_Skeleton:cancelEventListener()
			end
            g_Timer:pushTimer(fMixTime, funcEnd)
        end
    end
    self.CCNode_Skeleton:addEventListener(addEvnetLister)
    self.CCNode_Skeleton:setSpeed(
		(
			g_nBaseSpeed
			+ g_nSpineMutipleAttackAccelaration
			+ (TbBattleReport.nAccelerateSpeed - 1)
			* g_nAnimationSpeed
			* g_nSpineMutipleAttackSpeedParam
		) * nSpeed / 100
	)
    self.CCNode_Skeleton:setMix(szName, szMixName, fMixTime)
    self.CCNode_Skeleton:setAnimation(0, szName, false)
end

function CPlayer:getPlayerCenterPos()
    return self.tbPos_CardCenter
end

function CPlayer:setTestBackGroundColor(layoutPlayer)
    layoutPlayer:setBackGroundColorType(2)
    -- 1 无颜色 2 单色 3渐变
    layoutPlayer:setBackGroundColor(ccc3(255, 0, 0))
    layoutPlayer:setBackGroundColorOpacity(128)
end

local function fadeOut(widget)
    local function remove()
        widget:removeFromParentAndCleanup(true)
    end

    local arrAct = CCArray:create()
    local fadeout = CCFadeOut:create(0.5 * g_TimeSpeed)
    arrAct:addObject(fadeout)
    arrAct:addObject(CCCallFuncN:create(remove))
    local action = CCSequence:create(arrAct)

    widget:runAction(action)
end

function CPlayer:removeFootAnimation(bEnd)
    if self.nPos > 10 then return end
    local animation1 = self.Image_Shadow:getNodeByTag(1)
    local animation2 = self.Image_Shadow:getNodeByTag(2)
    if not animation1 then return end
    if not animation2 then return end

    if bEnd then
        fadeOut(animation1)
        fadeOut(animation2)
    else
        local bFireActionID = self.GameObj_SkillMgr:getCurFireActionID()
        local bFarAttack = nFireActionID == 3 or nFireActionID == 4
        if not bFarAttack then
            fadeOut(animation1)
            fadeOut(animation2)
        end
    end
end

function CPlayer:getSkillLevel(i)
    local nPos = self.nPos
    local nEumnBattleSide = eumn_battle_side.attack

    if nPos > 10 then
        nEumnBattleSide = eumn_battle_side.defence
        nPos = nEumnBattleSide - 10
    end
    return g_BattleMgr:getFighterUseSkillLevel(nEumnBattleSide, nPos, i - 1)
end

function CPlayer:setLoadingBarSp(bShowAddSpAni)
    self.LoadingBar_Mana:setPercent(self.nCurSp * 100 / self.nMaxSp)
	if bShowAddSpAni == true then
		self:showAddSpAniton()
	end
end

local function moveSpineIcon(widget, toPosition, funcCallBack)
    if widget then
        local move_ease_in = CCMoveTo:create(0.6 * g_TimeSpeed, toPosition)
        local arrAct = CCArray:create()
        arrAct:addObject(move_ease_in)
        if (funcCallBack) then
            arrAct:addObject(CCCallFuncN:create(funcCallBack))
        end
        local action = CCSequence:create(arrAct)
        widget:runAction(action)
    end
end

function CPlayer:setAttackSkillIconSpine()
    if self.nPos > 10 then return end

    local TbBattleWnd = TbBattleReport.TbBattleWnd
	if not TbBattleWnd then return end
	if TbBattleWnd == {} then return end
	
    local Button_NormalSkill = TbBattleWnd.tbWidgetSkillIcon[1]
    local Panel_Stencil = Button_NormalSkill:getChildByName("Panel_Stencil")
    local Panel_Pos = Panel_Stencil:getChildByName("Panel_Pos")
    local Image_Card = tolua.cast(Panel_Pos:getChildByName("Image_Card"), "ImageView")
    Image_Card:loadTexture(getUIImg("Blank"))
    Image_Card:setPositionXY(self.tbFighterBase.PotraitX, self.tbFighterBase.PotraitY)
    Image_Card:setVisible(true)
    Panel_Pos:setScale(self.tbFighterBase.PotraitScale / 100)
    local function removeNode()
        Panel_Pos:removeFromParentAndCleanup(true)
    end

    if Panel_Pos then
        moveSpineIcon(Panel_Pos, ccp(-67, 0), removeNode)
    end

    local Panel_PosNew = Panel_Pos:clone()
    Panel_PosNew:setName("Panel_Pos")
    Panel_Stencil:addChild(Panel_PosNew)

    local Image_Card = tolua.cast(Panel_PosNew:getChildByName("Image_Card"), "ImageView")
    local CCNode_Skeleton = self:getSkeleton()
    Image_Card:loadTexture(getUIImg("Blank"))
    Image_Card:removeAllNodes()
    Image_Card:addNode(CCNode_Skeleton)
    g_runSpineAnimation(CCNode_Skeleton, "idle", true)
    Panel_PosNew:setPositionXY(201, 0)
    moveSpineIcon(Panel_PosNew, ccp(67, 0))

    local EnergyFull = TbBattleWnd.EnergyNormal:getBone("EnergyFull")
    if self.nCurSp >= self.nMaxSp then
        EnergyFull:setOpacity(255)
    else
        EnergyFull:setOpacity(0)
    end
    TbBattleWnd.Panel_Energy:setSize(CCSize(160, 160 * self.nCurSp / self.nMaxSp))
end

function CPlayer:hideHeadInfoHurtAction(bShow)
    if bShow == true then
        -- 为True, 出现受击效果，隐藏血条
        self.Label_Name:setVisible(false)
        self.Image_HP:setVisible(false)
        self.Image_Mana:setVisible(false)
    else
        -- 为False, 显示血条
        if not self.nPos then return true end
        self.Label_Name:setVisible(true)
        self.Image_HP:setVisible(true)
        self.Image_Mana:setVisible(true)
    end
end

function CPlayer:isExsit_Layout()
    if g_OnExitGame then
        return self:isExsit()
    end
    return true
end

--血量
function CPlayer:showPlayerEffectStatus(showPlayerEffectStatusEndCall)
    local nStatusCount = self.nStatusCount
    if nStatusCount and nStatusCount > 0 then
		local nEumnBattleSide, nPosInBattleMgr = g_BattleMgr:getBattleSideAndPosInBattleMgr(self.nPos)
        local nBleedDamage = gEffectData:getHpEffectBleed(nPosInBattleMgr)
        if not nBleedDamage then 
            return true
        end
        local effectCardObj = gEffectData:getEffectCardObj(nPosInBattleMgr)
        if effectCardObj and effectCardObj.setLostHp then
            effectCardObj:setLostHp(nBleedDamage)
        end

        if nBleedDamage < 0 then
            self:showHealing(nBleedDamage)
            -- 治疗
        else
            -- 伤害
            self:showDamage(nBleedDamage)
        end
		
		--不能完全根据数据层的血量去判断死亡，数据层有可能会先死，比如连击，数据层是直接先连击死亡的
        --if g_BattleMgr:checkFighterIsDeadByPos(self.nPos, self.nUniqueId) == true and funcDeadCall then
		if self:checkIsDead() == true then
			if showPlayerEffectStatusEndCall then
				showPlayerEffectStatusEndCall()
				return false
			end
        end
    end
    return true
end

-- effect 怒气状态
function CPlayer:manaEffectStatus(nEffectType, nEffectLv)
    local StatusCon = self.nStatusCount
    if StatusCon and StatusCon > 0 then
        local pos = self.nPos > 10 and self.nPos - 10 or self.nPo

        local effectType = gEffectData:getEffectType(pos)
        if effectType == macro_pb.Skill_Effect_Add_Mana-- 每回合增加气势
            or effectType == macro_pb.Skill_Effect_Reduce_Mana-- 每回合减少气势
            or effectType == macro_pb.Skill_Effect_ModifyMana--[[ 立即减少怒气 ]] then

            local manaValue = gEffectData:getManaEffectValue(pos)
            if not manaValue then return end
            local mana = self.nCurSp + manaValue
            mana = math.min(mana, self.nMaxSp)
            self.nCurSp = math.max(0, mana)


        end
    end

end