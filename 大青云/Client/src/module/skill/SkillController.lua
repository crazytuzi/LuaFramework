--
-- Created by IntelliJ IDEA.
-- User: stefan
-- Date: 2014/7/24
-- Time: 12:31
-- To change this template use File | Settings | File Templates.
--
_G.classlist['SkillController'] = 'SkillController'
_G.SkillController = setmetatable({},{__index = IController})
SkillController.name = "SkillController"
SkillController.objName = 'SkillController'
SkillController.targetMaxLength = 200
SkillController.targetType = nil
SkillController.targetCid = nil
SkillController.dwCurExecSkillID = nil
SkillController.tbExecSkillPoint = {};
SkillController.lockSkill = nil
SkillController.currPrepPos = {}
SkillController.keyDownCode = nil
SkillController.PrepState = false
SkillController.CurrPrepSkillId = nil
SkillController.CollectState = false
SkillController.CurrCollectSkillId = nil
SkillController.CurrSkillTargetPos = nil
SkillController.stiffTime = 0
SkillController.comboing = false
SkillController.currDownKey = nil;--当前按下的键
SkillController.CDList = {}
SkillController.CurrMouesPos = nil;

function SkillController:Create()
    CControlBase:RegControl(self, true)
    MsgManager:RegisterCallBack(MsgType.SC_SkillContainer, self, self.OnSkillShortcutList)
    MsgManager:RegisterCallBack(MsgType.SC_MagicCooldown, self, self.OnSkillCooldown)
    MsgManager:RegisterCallBack(MsgType.SC_CastEffect, self, self.OnCastEffect)
    MsgManager:RegisterCallBack(MsgType.SC_CastBegan, self, self.OnCastBegin)
    MsgManager:RegisterCallBack(MsgType.SC_CastEnded, self, self.OnCastEnd)
    MsgManager:RegisterCallBack(MsgType.SC_CastPrepBegan, self, self.OnCastPrepBegin)
    MsgManager:RegisterCallBack(MsgType.SC_CastPrepEnded, self, self.OnCastPrepEnd)
    MsgManager:RegisterCallBack(MsgType.SC_CastChanBegan, self, self.OnCastChanBegin)
    MsgManager:RegisterCallBack(MsgType.SC_CastChanEnded, self, self.OnCastChanEnd)
	MsgManager:RegisterCallBack(MsgType.SC_SkillListResult,self,self.OnSkillListResult);
    MsgManager:RegisterCallBack(MsgType.SC_SkillLearnResult,self,self.OnSkillLearnResult);
    MsgManager:RegisterCallBack(MsgType.SC_SkillAdd,self,self.OnSkillAddResult);
	MsgManager:RegisterCallBack(MsgType.SC_SkillRemove,self,self.OnSkillRemoveResult);
	MsgManager:RegisterCallBack(MsgType.SC_SkillLvlUpResult,self,self.OnSkillLvlUpResult);
	MsgManager:RegisterCallBack(MsgType.SC_SkillShortCut,self,self.OnSkillShortCut);
    MsgManager:RegisterCallBack(MsgType.SC_CastContBegan, self, self.OnCastComboBegin)
    MsgManager:RegisterCallBack(MsgType.SC_CastContEnded, self, self.OnCastComboEnd)
    MsgManager:RegisterCallBack(MsgType.SC_KnockBack, self, self.OnKnockBack)
    MsgManager:RegisterCallBack(MsgType.SC_CastMotionEffect, self, self.OnCastMotionEffect)
    MsgManager:RegisterCallBack(MsgType.SC_CastMagicResult, self, self.OnCastMagicResult)
    MsgManager:RegisterCallBack(MsgType.SC_RampageInfo, self, self.OnRampageInfo)
    MsgManager:RegisterCallBack(MsgType.SC_CastPassiveSkill, self, self.OnCastPassiveSkill)
	MsgManager:RegisterCallBack(MsgType.SC_ItemShortCut, self, self.OnItemShortCut);
	MsgManager:RegisterCallBack(MsgType.SC_SkillCDList, self, self.OnSkillCDList);
    MsgManager:RegisterCallBack(MsgType.SC_JueXueOperResult, self, self.JueXueOperResult);   ----服务器返回：绝学学习升级突破反馈
    MsgManager:RegisterCallBack(MsgType.SC_JueXueUpdate, self, self.JueXueUpdate);        ----服务器返回：绝学心法信息更新
    MsgManager:RegisterCallBack(MsgType.SC_SkillLvlUpOneKeyResult, self, self.SkillLvlUpOneKeyResult);  --返回一键升级技能
end

function SkillController:Destroy()

end

function SkillController:Update(interval)
    SkillController:AutoClearTarget()
	SkillModel:UpdateSkillCD(interval)
    SkillController:AutoCastSkill()   --if start just update forever
    SkillController:CastLastSkill()
end 

function SkillController:OnChangeSceneMap()
end

function SkillController:OnEnterGame()
	SkillGuideManager:OnEnterGame()
end

local lastEscTime = 0
function SkillController:OnKeyDown(keyCode)
 
	if sceneTest then
        if keyCode == _System.KeyZ then
            AutoBattleController:OpenAutoBattle()
        end
    end
 
    if not self:IsSkillKey(keyCode) then return; end

    MainPlayerController.laseOpTime = GetCurTime()
	if self.currDownKey then return; end
	self.currDownKey = keyCode;
    if keyCode == _System.KeyESC then
        SkillController:InterruptLingzhen()
        if GetCurTime() - lastEscTime < 500 then
            return
        end
        lastEscTime = GetCurTime()
        if SkillController.targetCid then
            SkillController:ClearTarget()
        end
    elseif keyCode == _System.KeyTab then
        AutoBattleController:TabClickChar()
    end
	--物品快捷键
	if keyCode == SkillConsts.ShortCutItemKey then
		UIMainSkill:ShowSCItemKeyDown(true);
		UIMainSkill:OnSCItemClick();
		return;
	end
   --天神附体
	if keyCode == SkillConsts.bianshenSkillKey then

        TianShenController:SendTianshenSkill();
        return;
    end
	if keyCode == SkillConsts.FabaoSkillKey  then
		FabaoController:SendFabaoSkill();
		return;
	end
	--技能快捷键
	for k,vo in pairs(SkillConsts.KeyMap) do
		if vo.keyCode == keyCode then
			UIMainSkill:ShowSkillKeyDown(k,true);
			local shortcutInfo = SkillModel:GetShortcutListByPos(k);
			if shortcutInfo then
				self:PlayCastSkill(shortcutInfo.skillId,false,true);
                self.keyDownCode = keyCode
			end
			return;
		end
	end
end

function SkillController:OnKeyUp(keyCode)
	if not self:IsSkillKey(keyCode) then return; end
	if self.currDownKey ~= keyCode then return; end
	self.currDownKey = nil;
	--
	if keyCode == SkillConsts.ShortCutItemKey then
		UIMainSkill:ShowSCItemKeyDown(false);
		return;
	end
	
	if keyCode ==SkillConsts.bianshenSkillKey then

       -- TianShenController:SendTianshenSkill();
        return;
    end
	if keyCode == SkillConsts.FabaoSkillKey then
		-- FabaoController:SendFabaoSkill();
		return;
	end
	
    for k, vo in pairs(SkillConsts.KeyMap) do
        if vo.keyCode == keyCode then
			UIMainSkill:ShowSkillKeyDown(k,false);
            local shortcutInfo = SkillModel:GetShortcutListByPos(k)
            if shortcutInfo then
                local skillId = shortcutInfo.skillId
                local skillConfig = t_skill[skillId]
                if not skillConfig then
                    return
                end
                self:TryInterruptCast()
            end
            return
        end
    end
end

function SkillController:OnMouseMove()
    SkillController:UpdateLingzhenPfxPos()
end

--是否属于技能模块的按键
function SkillController:IsSkillKey(keyCode)
	if keyCode == _System.KeyESC then
        return true;
	end
	if keyCode == _System.KeyX then
		return true;
	end
	if keyCode == _System.KeySpace then
		return true;
	end
    if keyCode == _System.KeyTab then
        return true
    end
	if keyCode == SkillConsts.ShortCutItemKey then
		return true;
	end
    if keyCode ==SkillConsts.bianshenSkillKey then
        return true;
    end
	for k,vo in pairs(SkillConsts.KeyMap) do
		if vo.keyCode == keyCode then
			return true;
		end
	end
	return false;
end

function SkillController:PlayCastSkill(skillId, isLingzhen,isClient)
    local skillConfig = t_skill[skillId]
    if not skillConfig then
        return false
    end

    if SkillController.lingzhenState then
        if skillConfig.oper_type ~= SKILL_OPER_TYPE.LINGQI then
            SkillController:InterruptLingzhen()
        else
            if not isLingzhen then
                return
            end
        end
    end
	
    --AutoBattleController:InterruptAutoCast()
    AutoBattleController:SetAutoCastSkillState(false)
    self.curSkill = skillId														--将要释放的技能
  	local char, charType = SkillController:GetCurrTarget()						--获取当前目标

    --自动选中目标
    SkillController:AutoCancelClickNpc()
    local need_select = skillConfig.b_selected
    if need_select and not self.comboing and not char then
        AutoBattleController:AutoClickLockChar()								--使目标锁定
    end

    if SkillController:StiffTimeInAfterTime(skillId) == true then				--处于僵直的状态（仅客户端）
        self.lastSkill = skillId
        self.lastTargetCid = self.targetCid
    else
        self.lastSkill = nil
        self.lastTargetCid = nil
    end

	if isClient then
		self.CurrMouesPos = nil;
		if skillConfig.move_limit then
			self.CurrMouesPos = GetMousePos();
		end
	end
	
	--判断是否符合施法条件
    -- 在释放技能之前取消选中状态(前提是对方必须是玩家)
    --[[
    if SkillController.targetCid then
            SkillController:ClearTarget()
    end
    --]]
    local ret = SkillController:CheckPkState(skillId)
    if ret and ret ~= 0 then
        if SkillController.targetCid then
            SkillController:ClearTarget()
        end
    end

    local result = SkillController:IsCanUseSkill(skillId)
    if result ~= 0 then
        self:ShowNotice(skillId, result)
        return false
    end
	
	if isClient then
		self.CurrMouesPos = nil;
	end
    SkillController.CurrSkillTargetPos = nil									--清除当前技能作用点

    if not AutoBattleController:GetAutoHang() then
        if skillConfig.oper_type == SKILL_OPER_TYPE.LINGQI then
            if not SkillController.lingzhenState then
                SkillController:CastLingzhen(skillId)
                return
            end
        end
    end

    local size = 0
    if charType == enEntType.eEntType_Monster then
        size = char:GetBoxWidth()
    end
    local targetCid = self.targetCid or "0_0"
    if skillConfig.oper_type == SKILL_OPER_TYPE.ROLL then												--翻滚技能
        local targetPos
        if AutoBattleController:GetAutoHang() then
            if self:GetCurrTarget() then
                targetPos = self:GetCurrTarget():GetPos()												--挂机状态下翻滚至目标点
            end
        else
            targetPos = GetMousePos()
        end
        if not targetPos then
            return false
        end
        local dis = SkillController:GetRollDis(skillId)
        local selfPos = MainPlayerController:GetPlayer():GetPos()
        local selfDis = math.sqrt((targetPos.x - selfPos.x)^2 + (targetPos.y - selfPos.y)^2)
        if AutoBattleController:GetAutoHang() and self:GetCurrTarget() then
            selfDis = selfDis - 15
        end
        if selfDis > dis then
            selfDis = dis
        elseif selfDis < 10 then
            selfDis = 10
        end
        local selfPlayer = MainPlayerController:GetPlayer()
        if selfPlayer
            and selfPlayer:GetStateInfoByType(PlayerState.UNIT_BIT_HOLD) == 1 then --定身中
            selfDis = 1
        end 
        local pos = SkillController:GetRollPos(selfDis, targetPos)
        if not pos then
            return false
        end
        self.targetPos = pos
    elseif skillConfig.oper_type == SKILL_OPER_TYPE.JUMP  then											 --跳跃技能
		local pos = nil;
		if not self:GetCurrTarget() then
            pos = GetMousePos()
		else
			pos = self:GetCurrTarget():GetPos()
        end
		
		if self.CurrMouesPos then
			pos = self.CurrMouesPos
		end
		
		if not pos then
			return false
		end
		
        local selfPos = MainPlayerController:GetPlayer():GetPos()
        local dis = math.sqrt((pos.x - selfPos.x)^2 + (pos.y - selfPos.y)^2)
        dis = dis - size
        local targetPos = nil
        if dis <= 50 then
            --targetPos = {x = selfPos.x, y = selfPos.y, z = selfPos.z}
            dis = 40
        end
        -- local selfPlayer = MainPlayerController:GetPlayer()
        -- if selfPlayer
        --     and selfPlayer:GetStateInfoByType(PlayerState.UNIT_BIT_HOLD) == 1 then --定身中
        --     dis = 1
        -- end 
        targetPos = SkillController:GetRollPos(dis, pos)
        self.targetPos = targetPos
        if self.targetPos == nil then
            -- self.targetPos = GetMousePos();   -- 这样太流弊了，哈哈~
            self.targetPos = MainPlayerController:GetPos();
        end
    elseif skillConfig.oper_type == SKILL_OPER_TYPE.COMBO then
        if not self.comboing then
			local pos = nil;
			if not self:GetCurrTarget() then
				pos = GetMousePos()
			else
				pos = self:GetCurrTarget():GetPos()
			end
			if not pos then
				return false
			end
            self.targetPos = pos
            targetCid = "0_0"
            self.comboPos = pos
        else
            self.targetPos = self.comboPos
            targetCid = "0_0"
        end
    elseif skillConfig.oper_type == SKILL_OPER_TYPE.LINGQI then
        local targetPos = SkillController:GetLingzhenPos(skillId)
        if not targetPos then
            if not AutoBattleController:GetAutoHang() then
                FloatManager:AddSkill(StrConfig['skill1011'])
            end
            return false
        end
        self.targetPos = targetPos
    else
		local pos = nil;		
        if AutoBattleController:GetAutoHang() then
            if self:GetCurrTarget() then
                pos = self:GetCurrTarget():GetPos()
            end
        else
			--几种对地释放的情况（配置表）
			pos = GetMousePos();
			if self.CurrMouesPos then
				pos = self.CurrMouesPos;
			end
            --[[if not pos then
                self.targetPos = SkillController:GetRollPos(1)
            else
                self.targetPos = GetMousePos()
            end--]]
        end
		self.targetPos = pos;
    end
    if not self.targetPos then
        return false
    end
    --正式施法
    local result = SkillController:TryUseSkill(skillId, targetCid, self.targetPos)

    SkillController:CancelAutoCastSkill()
    
    if skillConfig.oper_type == SKILL_OPER_TYPE.PREP then
        self.CurrPrepSkillId = skillId
    end
    return result
end

function SkillController:TryUseSkill(skillId, targetCid, targetPos)
    --[[选中目标 和 鼠标位置 告诉给服务器端]]--
    if not targetPos then assert(false, "fuck") end
    if not targetCid then assert(false, "fuck") end
    local targetX = targetPos.x
    local targetY = targetPos.y
    local targetZ = targetPos.z
    --自己正在移动时先停止移动
    if MainPlayerController:IsMoveState() then
        MainPlayerController:StopMove()
    end
    --先下马
    SkillController:RemoveRideMount(skillId)
    --告诉给服务器端
    self:SendTryCastSkill(skillId, targetCid, targetX, targetY)
    --客户端先做动作
    self:CastBegin(skillId, targetCid, {x = targetX, y = targetY, z = targetZ})
    --客户端做硬直时间
    self:SetStiffTime(skillId)
    --设置最近一次释放技能的时间
    AutoBattleController:SetLastUseSkillTime(skillId)
	self.CurrMouesPos = nil;
    return true
end

function SkillController:RemoveRideMount(skillId)
    local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    if not MallUtils:GetIsQiZhanActive() then
        MountController:RemoveRideMount()
    end
end

function SkillController:SetStiffTime(skillId)
    local skillConfig = t_skill[skillId]
    self.stiffTime = GetCurTime() + skillConfig.stiff_time
end

function SkillController:GetStiffTime()
    return self.stiffTime
end

function SkillController:StiffTimeInAfterTime(skillId)
    local stiffTime = SkillController:GetStiffTime()
    local skillConfig = t_skill[skillId]
    local nowTime = GetCurTime()
    if stiffTime - nowTime > 250 then
        return false
    end
    if SkillModel:GetSkillCD(skillId) > 250 then
        return false
    end
    if SkillController:CheckConsume(skillId) == 0 then
        return false
    end
    if skillConfig.oper_type == SKILL_OPER_TYPE.PREP then
        local selfPlayer = MainPlayerController:GetPlayer()
        if not selfPlayer then
            return false
        end
        if selfPlayer:IsPrepState() == true then
            return false
        end
    end
    return true
end

function SkillController:CastLastSkill()
    if not self.lastSkill then
        return
    end
    if SkillController.CurrSkillTargetPos then
        return
    end
    if self.lastTargetCid ~= self.targetCid then
        return
    end
    local skillConfig = t_skill[self.lastSkill]
    if not skillConfig then
        return
    end
    if skillConfig.oper_type == SKILL_OPER_TYPE.LINGQI then
        return
    end
    -- SkillController:OnKeyDown(keyCode)

    -- 在释放技能之前取消选中状态(前提是对方必须是玩家)
    local ret = SkillController:CheckPkState(self.lastSkill)
    if ret and ret ~= 0 then
        if SkillController.targetCid then
            SkillController:ClearTarget()
        end
    end
    local ret = SkillController:IsCanUseSkill(self.lastSkill)
    if ret == 0 then
        self:PlayCastSkill(self.lastSkill)
    end
end

--自动挂机状态下释放技能
function SkillController:AutoCastSkill()
    if not SkillController.CurrSkillTargetPos then
        return
    end
    if not self.curSkill then
        return
    end
    local skillConfig = t_skill[self.curSkill]
    if not skillConfig then
        return
    end
    local char, charType = SkillController:GetCurrTarget()
    local size = 0
    if charType == enEntType.eEntType_Monster then
        size = char:GetBoxWidth()
    end
    if skillConfig.oper_type == SKILL_OPER_TYPE.COMBO then
        size = 0
    end
    local cast_range = skillConfig.min_dis
    local selfPlayer = MainPlayerController:GetPlayer()
    local selfPos = selfPlayer:GetPos()
    local length = GetDistanceTwoPoint(selfPos, self.CurrSkillTargetPos)
    local skillId = MainPlayerController:GetNormalAttackSkillId()
    if self.curSkill ~= skillId then
        cast_range = cast_range * 0.95
    else
        cast_range = cast_range * 0.5
    end
    if length <= cast_range + size then

        --[[
        if SkillController.targetCid then
            SkillController:ClearTarget()
        end
        --]]
        local ret = SkillController:CheckPkState(skillId)
        if ret and ret ~= 0 then
            if SkillController.targetCid then
                SkillController:ClearTarget()
            end
         end

        local ret = SkillController:IsCanUseSkill(self.curSkill)
        if ret == 0 then
            self:PlayCastSkill(self.curSkill)
        end
    end
end

function SkillController:CancelAutoCastSkill()
    self.CurrSkillTargetPos = nil
    self.curSkill = nil
    self.lastSkill = nil
	self.CurrMouesPos = nil;
end

function SkillController:SetBattle(castChar)
    castChar:SetBattleState(true)
    if castChar.battleTimer then
        TimerManager:UnRegisterTimer(castChar.battleTimer)
    end
    castChar.battleTimer = TimerManager:RegisterTimer(function()
        if castChar:GetEatonChairState() then
            return
        end
        if castChar and castChar:GetAvatar() and castChar.battleTimer then
            castChar:SetBattleState(false)
            castChar.battleTimer = nil
        end
    end, 10000, 1)
end

function SkillController:IsNeedTurn(skillId, targetCid)
    local skillConfig = t_skill[skillId]
    if not skillConfig then
        return false
    end
    local char, _ = CharController:GetCharByCid(targetCid)
    if char then
        if skillConfig.target_cast == 1 or skillConfig.target_cast == 5 or skillConfig.target_cast == 6 then
            return true
        else
            return false
        end
    else
        --[[if skillConfig.no_target_cast == 1 then					--未知的转向需求
            return true
        else
            return false
        end--]]
		
		return true
		
    end
end

function SkillController:CharChangeDirToPos(cid, pos)
    local char, charType = CharController:GetCharByCid(cid)
    if not char then
        return
    end
    local pos1 = char:GetPos()
    if not pos1 then
        return
    end
    if pos1.x == pos.x and pos1.y == pos.y then
        return
    end
    local dir = GetDirTwoPoint(pos1, pos)
    CharController:OnPlayerChangeDir(cid, dir)
end

function SkillController:CheckNeedSelect(skillId)
    local skillConfig = t_skill[skillId]
    if not skillConfig then
        return false
    end
    if self.comboing then
        return true
    end
    local need_select = skillConfig.b_selected
	if need_select then
		local char, charType = SkillController:GetCurrTarget()
		if char then
			return charType == enEntType.eEntType_Monster or charType == enEntType.eEntType_Player
		else
			return false;
		end;
	end;
    return true
end

function SkillController:CheckPkState(skillId)
	local rollSkillId = MainPlayerController:GetRollSkillId()
	if skillId == rollSkillId then
		return
	end
	local char, charType = SkillController:GetCurrTarget()
	if not char then
		return
	end
    local cid = char:GetCid()
	local ret = 0
	if charType == enEntType.eEntType_Player then
        local skillConfig = t_skill[skillId]
        if skillConfig.faction_limit ~= 1 then
	       ret = MainPlayerController:PlayerIsAttack(cid)
        end
	elseif charType == enEntType.eEntType_Monster and MonsterController:MonsterIsAttack(cid) == false then
		ret = 104
	end
    return ret
end

--判断施法距离
function SkillController:CheckCastRange(skillId)
    local skillConfig = t_skill[skillId]
    if not skillConfig then
        return false
    end
    if self.comboing then
        return true
    end
    local need_select = skillConfig.b_selected
    local char, charType = SkillController:GetCurrTarget()
    if need_select and not char then
        return false
    end

    local targetPos = nil
    if char then
        targetPos = char:GetPos()
    end
	
	if not targetPos then
		targetPos = self.CurrMouesPos;
	end
	
    local size = 0
    if charType == enEntType.eEntType_Monster then
        size = char:GetBoxWidth()
    end
    if skillConfig.oper_type == SKILL_OPER_TYPE.COMBO then
        size = 0
    end
    if targetPos then
		
        --挂机时用一个施法距离min_dispk
        --非挂机时用一个施法距离min_dis
        local dis = skillConfig.min_dis
        if AutoBattleController:GetAutoHang() then
            dis = skillConfig.min_dispk
        end
        local cast_range = dis - 10 + size
        local selfPlayer = MainPlayerController:GetPlayer()
        local selfPos = selfPlayer:GetPos()
        local targetPosVector = _Vector3.new(targetPos.x, targetPos.y, targetPos.z)
        local length = GetDistanceTwoPoint(selfPos, targetPos)
		
        if length > cast_range then
            if SkillController.CurrSkillTargetPos == nil then
                CPlayerControl:AutoRun(targetPosVector, {func = function()					---Run
                    SkillController.CurrSkillTargetPos = nil
					-- SkillController.CurrMouesPos = nil
                end})
                SkillController.CurrSkillTargetPos = targetPosVector
            end
            return false
        end
    end
    return true
end

function SkillController:CastSkill(castCid, skillId, targetCid, targetPos)
    local castChar, charType = CharController:GetCharByCid(castCid)
    if not castChar then
        return
    end

    local skillConfig = t_skill[skillId]
    if not skillConfig then
        return false
    end

    if castCid == MainPlayerController:GetRoleID() then
        SkillController:ShowSkillNamePfx(skillId)
    end

    local skill_type = skillConfig.oper_type
    if skill_type == SKILL_OPER_TYPE.CHAN then
        return
    end

    if skill_type == SKILL_OPER_TYPE.PREP then
        if charType ~= enEntType.eEntType_Monster then
            return
        end
    end

    if skill_type ~= SKILL_OPER_TYPE.SHENBING then
        if castCid == MainPlayerController:GetRoleID() then
            return
        end
        if charType == enEntType.eEntType_Player then
            self:SetBattle(castChar)
        end
		
		if charType == enEntType.eEntType_LingShou then
            self:SetBattle(castChar)
		end
		
    end

    SkillController:SkillCastBegin(castCid, skillId, targetCid, targetPos)
end

function SkillController:CastSkillEnd(castCid, skillId)

end

function SkillController:CastPrepBegin(castCid, skillId, targetCid, targetPos, prepTime)
    local castChar, _ = CharController:GetCharByCid(castCid)
    
    if not castChar then
        return
    end

    local targetChar, _ = CharController:GetCharByCid(targetCid)
    local skillConfig = t_skill[skillId]
    if not skillConfig then
        return false
    end

    if targetChar then
        self.currPrepPos = targetChar:GetPos() 
    else
        self.currPrepPos = targetPos
    end

    local skill_type = skillConfig.oper_type
    if skill_type == SKILL_OPER_TYPE.PREP then
        --蓄力进度条UI
        if castCid == MainPlayerController:GetRoleID() then
			local cfg = t_skill[skillId]
			if cfg then
				UIMainXuLiProgress:Start(cfg.name,prepTime)
			end
            self.prepTime = prepTime + GetCurTime()
			self.PrepState = true
            self.CurrPrepSkillId = skillId
        else
            if SkillController:IsNeedTurn(skillId, targetCid) == true then
                SkillController:CharChangeDirToPos(castCid, self.currPrepPos)
            end
            SkillController:SkillCastBegin(castCid, skillId, targetCid, targetPos)
        end
    elseif skill_type == SKILL_OPER_TYPE.COLLECT then
        SkillController:SkillCastBegin(castCid, skillId, targetCid, targetPos)
        if castCid == MainPlayerController:GetRoleID() then
            self.CollectState = true
            self.CurrCollectSkillId = skillId
            local cfg = t_skill[skillId]
			if cfg then
				UIMainColletProgress:Open(cfg.name, prepTime)
			end
			QuestGuideManager:OnCollect();
		end
    end
end

function SkillController:CastPrepEnd(castCid, skillId, isend)
    local castChar, _ = CharController:GetCharByCid(castCid)
    if not castChar then
        return
    end

    local skillConfig = t_skill[skillId]
    if not skillConfig then
        return false
    end

    local skill_type = skillConfig.oper_type
    if skill_type == SKILL_OPER_TYPE.PREP then
        if castCid == MainPlayerController:GetRoleID() then
			UIMainXuLiProgress:End(isend);
            self.PrepState = false
            self.CurrPrepSkillId = nil
            local selfPlayer = MainPlayerController:GetPlayer()
            if selfPlayer.stateMachine and selfPlayer.stateMachine.currState.name == "prep" then
                selfPlayer.stateMachine:changeState(IdleState:new(selfPlayer))
            end
        else
            castChar:GetAvatar():SetPrepState(0)
            castChar:GetAvatar():StopCurrSkillAction()
        end
    elseif skill_type == SKILL_OPER_TYPE.COLLECT then
        castChar:GetAvatar():StopCurrSkillAction()
        if castCid == MainPlayerController:GetRoleID() then
            self.CollectState = false
            self.CurrCollectSkillId = nil
            UIMainColletProgress:Hide()
            castChar:GetAvatar():StopSkillSound(skillId)
			QuestGuideManager:OnCollectEnd();
        end
        if isend == 1 then
            castChar:GetAvatar():PlayCollectEnd(skillId)
        end
    end
end

function SkillController:CastChanBegin(castCid, skillId, targetCid, targetPos)
    if castCid == MainPlayerController:GetRoleID() then
        return
    end

    local castChar, _ = CharController:GetCharByCid(castCid)
    
    if not castChar then
        return
    end

    local skillConfig = t_skill[skillId]
    if not skillConfig then
        return false
    end
    local skill_type = skillConfig.oper_type
    if skill_type == SKILL_OPER_TYPE.CHAN then
        SkillController:SkillCastBegin(castCid, skillId, targetCid, targetPos)
    end
end

function SkillController:CastChanEnd(castCid, skillId)
    local castChar, _ = CharController:GetCharByCid(castCid)
    if not castChar then
        return
    end
    if castCid == MainPlayerController:GetRoleID() then
        local selfPlayer = MainPlayerController:GetPlayer()
        if selfPlayer.stateMachine and selfPlayer.stateMachine.currState.name == "chan" then
            selfPlayer.stateMachine:changeState(IdleState:new(selfPlayer))
        end
    else
        castChar:GetAvatar():StopCurrSkillAction()
    end
end

function SkillController:CastComboBegin(castCid, skillId, targetCid, targetPos, comboTime)
    local castChar, _ = CharController:GetCharByCid(castCid)
    if not castChar then
        return
    end
    local skillConfig = t_skill[skillId]
    if not skillConfig then
        return false
    end
    local skill_type = skillConfig.oper_type
    if skill_type == SKILL_OPER_TYPE.COMBO then
        if castCid == MainPlayerController:GetRoleID() then
            local cfg = t_skill[skillId]
            if cfg then
				UIMainLianXuDaJiProgress:Open(cfg.name,comboTime)
                local pos = SkillModel:GetShortcutPos(skillId)
                --UIMainSkill:ShowSkillQuickClick(pos)
            end
        end
    end
end

function SkillController:CastComboEnd(castCid, skillId)
    local castChar, _ = CharController:GetCharByCid(castCid)
    if not castChar then
        return
    end
    if castCid == MainPlayerController:GetRoleID() then
        local selfPlayer = MainPlayerController:GetPlayer()
        if selfPlayer.stateMachine and selfPlayer.stateMachine.currState and selfPlayer.stateMachine.currState.name == "combo" then
            selfPlayer.stateMachine:changeState(IdleState:new(selfPlayer))
        end
        UIMainLianXuDaJiProgress:Hide()
        UIMainSkill:HideSkillQuickClick()
    end
end

function SkillController:SkillCastBegin(castCid, skillId, targetCid, targetPos)
    local castChar, charType = CharController:GetCharByCid(castCid)
    if not castChar then
        return
    end
    --看是否需要转向
    if SkillController:IsNeedTurn(skillId, targetCid) == true then
        if charType == enEntType.eEntType_Monster then
            local targetChar, _ = CharController:GetCharByCid(targetCid)
            local pos = nil
            if targetChar then
                pos = targetChar:GetPos()
            else
                pos = targetPos
            end
            SkillController:CharChangeDirToPos(castCid, pos)
        else
            SkillController:CharChangeDirToPos(castCid, targetPos)
        end
    end
    local skillConfig = t_skill[skillId]
    if skillConfig.oper_type == SKILL_OPER_TYPE.ROLL or skillConfig.oper_type == SKILL_OPER_TYPE.JUMP then
        return
    end
    castChar:PlaySkill(skillId, targetCid, targetPos)
end

function SkillController:CastBegin(skillId, targetCid, targetPos)
    local selfPlayer = MainPlayerController:GetPlayer()
    local skillConfig = t_skill[skillId]

    AutoBattleController:SetAutoCastSkillState(true)
    AutoBattleController.lastSkillId = skillId
    AutoBattleController.currTarget = targetCid

    self:SetBattle(selfPlayer)

    local castCid = MainPlayerController:GetRoleID()
    local skill_type = skillConfig.oper_type

    if SkillController:IsNeedTurn(skillId, targetCid) == true and not self.comboing then					
        local targetChar = CharController:GetCharByCid(targetCid)
        if targetChar and skill_type ~= SKILL_OPER_TYPE.ROLL and skill_type ~= SKILL_OPER_TYPE.JUMP then
            local pos = targetChar:GetPos()
            SkillController:CharChangeDirToPos(castCid, pos)
        else
            SkillController:CharChangeDirToPos(castCid, targetPos)									--转向问题
        end
    end

    if skill_type == SKILL_OPER_TYPE.PREP then
        selfPlayer.stateMachine:changeState(PrepState:new(selfPlayer, skillId))
    elseif skill_type == SKILL_OPER_TYPE.CHAN then
        selfPlayer.stateMachine:changeState(ChanState:new(selfPlayer, skillId))
    elseif skill_type == SKILL_OPER_TYPE.COMBO then
        if self.comboing then
            selfPlayer:PlaySkill(skillId, targetCid, targetPos)
        else
            selfPlayer.stateMachine:changeState(ComboState:new(selfPlayer, skillId))
            selfPlayer:PlaySkill(skillId, targetCid, targetPos)
        end
        UILianxuSpPfx:OnStatec()
    elseif skill_type == SKILL_OPER_TYPE.ROLL then
        selfPlayer:PlaySkill(skillId, nil, targetPos)
    elseif skill_type == SKILL_OPER_TYPE.JUMP then
        selfPlayer:PlaySkill(skillId, nil, targetPos)
    elseif skill_type == SKILL_OPER_TYPE.MUlTI then
        selfPlayer:PlaySkill(skillId, targetCid, targetPos)
    else
        selfPlayer:PlaySkill(skillId, targetCid, targetPos)
    end
end

local noticeList = {
    [2] = StrConfig['skill1001'],
    [3] = StrConfig['skill1002'],
    [4] = StrConfig['skill1002'],
    [5] = StrConfig['skill1003'],
    [6] = StrConfig['skill1004'],
    [8] = StrConfig['skill1005'],
    [9] = StrConfig['skill1006'],
    [10] = StrConfig['skill1007'],
    [11] = StrConfig['skill1008'],
    [12] = StrConfig['skill1009'],
    [13] = StrConfig['skill1010'],
    [14] = StrConfig['skill1012'],
	[15] = StrConfig['skill1013'],
    [101] = StrConfig['skill1101'],
    [102] = StrConfig['skill1102'],
    [103] = StrConfig['skill1103'],
    [104] = StrConfig['skill1104'],
    [105] = StrConfig['skill1015'],
}

-- 施法失败提升
function SkillController:ShowNotice(skillId, noticeType)
    if AutoBattleController:GetAutoHang() then
        return
    end

    if noticeType == 7 then
        local skillConfig = t_skill[skillId]
        local consumeType = skillConfig.consume_type
        if consumeType == SKILL_CONSUM_TYPE.HP then
            noticeType = 9
        elseif consumeType == SKILL_CONSUM_TYPE.MP then
            noticeType = 10
        elseif consumeType == SKILL_CONSUM_TYPE.HPPER then
            noticeType = 9
        elseif consumeType == SKILL_CONSUM_TYPE.MPPER then
            noticeType = 10
        elseif consumeType == SKILL_CONSUM_TYPE.TILI then
            noticeType = 8
        elseif consumeType == SKILL_CONSUM_TYPE.NUQI then
            noticeType = 10
        elseif consumeType == SKILL_CONSUM_TYPE.MAXHP then
            noticeType = 9
        -- elseif consumeType == SKILL_CONSUM_TYPE.MAXMP then
        --     noticeType = 10
        elseif consumeType == SKILL_CONSUM_TYPE.WUHUN then
            noticeType = 11
		elseif consumeType == SKILL_CONSUM_TYPE.TIANSHEN then
			noticeType = 105
        end
    end
    -- 其实类型如果不是7的话,其实一下信息
    if noticeList[noticeType] then
        FloatManager:AddSkill(noticeList[noticeType])
    end
end

-- 检查能否满足释放条件  -- houxudong
function SkillController:IsCanUseSkill(skillId)
    local skillConfig = t_skill[skillId]
    if not skillConfig then
        return 1
    end
    --检查状态
    local selfPlayer = MainPlayerController:GetPlayer()
    if not selfPlayer then
        return
    end
    if selfPlayer:IsDead() == true then
        return
    end
    --检查CD
    if not self:CheckSkillCD(skillId) then
        return 2
    end
    --检查消耗
    if self:CheckConsume(skillId) == 0 then
        return 7
    end
	--不能移动
    if selfPlayer:IsPunish() == false then
        return 3
    end
    if selfPlayer:IsChanState() == true then
        return 3
    end
    if selfPlayer:IsPrepState() == true then
        return 3
    end
    
    if MountController.ridingState == true then
        return 12
    end
    if CPlayerMap.bChangeMaping then
        return 12
    end
    if CPlayerMap.changeLineState == true then
        return 12
    end
    if CPlayerMap.changePosState then
        return 12
    end
    if MainPlayerController.standInState then
        return 12
    end
    if selfPlayer:GetStateInfoByType(PlayerState.UNIT_BIT_STIFF) == 1 then
        return
    end 
    if selfPlayer:GetStateInfoByType(PlayerState.UNIT_BIT_CASTING) == 1 then
        return
    end    
    if selfPlayer:GetStateInfoByType(PlayerState.UNIT_BIT_STUN) == 1 then
        return
    end
    if self.comboing and skillConfig.oper_type ~= SKILL_OPER_TYPE.COMBO then
        return 3
    end
    if SkillController:CheckComboSkillCD(skillId) == false then
        return
    end
    --检查硬直
    if self:IsStiff() then
        return
    end
    --检查在挂机状态时的选中
    if not self:CheckNeedSelectOnHang() then
        return
    end
    --检查选中
    if not self:CheckNeedSelect(skillId) then
        return 5
    end
    --检查灵阵技能
    if SkillController:CheckLingzhen(skillId) == false then
        return 13
    end
    if SkillController:CheckRide(skillId) == false then
        return 14
    end
    --检查灵兽技能
    if SkillController:CheckLingshou(skillId) == false then
        return
    end
    --检查PK状态
    local ret = SkillController:CheckPkState(skillId)
    if ret and ret ~= 0 then
    	return ret
    end
    --检查距离
    if not self:CheckCastRange(skillId) then
        return ;
    end
    -- adder:houxudong date:2016/9/1 21:45:23
    -- 大摆筵席活动中不可以释放技能
    if ActivityController:GetCurrId() == ActivityConsts.Lunch then
        return 15
    end
    return 0
end

function SkillController:CheckRide(skillId)
    local skillConfig = t_skill[skillId]
    if not skillConfig then
        return false
    end
    if skillConfig.showtype == SkillConsts.ShowType_QiZhan then
        if not MountModel:isRideState() then
            return false
        end
    end
    return true
end

function SkillController:CheckLingzhen(skillId)
    local skillConfig = t_skill[skillId]
    if not skillConfig then
        return false
    end
    if skillConfig.showtype == SkillConsts.ShowType_Fabao then
        if not CPlayerMap:IsCanCastLingzhen() then
            return false
        end
    end
    return true
end

function SkillController:CheckLingshou(skillId)
    local skillConfig = t_skill[skillId]
    if not skillConfig then
        return false
    end
    if skillConfig.showtype == SkillConsts.ShowType_WuHun then
        if SpiritsModel:GetFushenWuhunId() == 0 then
            return false
        end
    end
    return true
end

function SkillController:CheckNeedSelectOnHang()
    if AutoBattleController:GetAutoHang() and not SkillController:GetCurrTarget() then
        return false
    end
    return true
end

function SkillController:IsStiff()
    if self.stiffTime > GetCurTime() then
        return true
    end
    return false
end

function SkillController:CastEffect(castCid, targetCid, skillId, damage, flags, drophp)
    local char, charType = CharController:GetCharByCid(targetCid)
    if not char then
       return
    end

    if charType ~= enEntType.eEntType_Player 
        and charType ~= enEntType.eEntType_Monster then
        return
    end

    damage = math.ceil(damage)
	
    if damage > 0 and targetCid == MainPlayerController:GetRoleID() then
        MainPlayerController:UnderAttack(castCid)
    end
	
	if castCid == MainPlayerController:GetRoleID() then
		if damage >= 0 then
			self:sendNotification(NotifyConsts.BabelSecondHarm,{harm = damage})
            MainPlayerController:AttackTarget(targetCid)
		end
	end

    local multiDamage = 1
        
    local skillConfig = t_skill[skillId]
    if skillConfig and skillConfig["multi_damage"] and skillConfig["multi_damage"] > 0 then
        multiDamage = skillConfig["multi_damage"]
    end
    local randomDamage = math.ceil(damage * 0.02 * (multiDamage - 1))
    local averageDamege = math.ceil((damage - randomDamage) / multiDamage)

    local QTE = false
    local noticeType = enBattleNoticeType.HP_DWON
    if bit.band(flags, DAMAGE.MISS) == DAMAGE.MISS then
        noticeType = enBattleNoticeType.DODGE
    end
    if bit.band(flags, DAMAGE.CRIT) == DAMAGE.CRIT then
        noticeType = enBattleNoticeType.HP_CRIT
    end
    if bit.band(flags, DAMAGE.RAMPAGE) == DAMAGE.RAMPAGE then
        QTE = true
    end
    if castCid == MainPlayerController:GetRoleID() then
        if skillConfig then
            if skillConfig.oper_type == SKILL_OPER_TYPE.COMBO then
                if noticeType == enBattleNoticeType.HP_DWON then
                    noticeType = enBattleNoticeType.COMBO_DWON
                elseif noticeType == enBattleNoticeType.HP_CRIT then
                    noticeType = enBattleNoticeType.COMBO_CRIT
                end
            end
            if skillConfig.showtype == SkillConsts.ShowType_WuHun then
                if noticeType == enBattleNoticeType.HP_DWON then
                    noticeType = enBattleNoticeType.WUHUN_DWON
                elseif noticeType == enBattleNoticeType.HP_CRIT then
                    noticeType = enBattleNoticeType.WUHUN_CRIT
                end
            elseif skillConfig.showtype == SkillConsts.ShowType_Horse then
                if noticeType == enBattleNoticeType.HP_DWON then
                    noticeType = enBattleNoticeType.ZUOQI_DWON
                elseif noticeType == enBattleNoticeType.HP_CRIT then
                    noticeType = enBattleNoticeType.ZUOQI_CRIT
				end
			elseif skillConfig.showtype == SkillConsts.ShowType_MagicWeapon then
				if noticeType == enBattleNoticeType.HP_DWON then
					noticeType = enBattleNoticeType.SHENBING_DOWN
				elseif noticeType == enBattleNoticeType.HP_CRIT then
					noticeType = enBattleNoticeType.SHENBING_CRIT
				end
			elseif skillConfig.showtype == SkillConsts.ShowType_LingQi then
				if noticeType == enBattleNoticeType.HP_DWON then
					noticeType = enBattleNoticeType.LINGQI_DOWN
				elseif noticeType == enBattleNoticeType.HP_CRIT then
					noticeType = enBattleNoticeType.LINGQI_CRIT
				end
			elseif skillConfig.showtype == SkillConsts.ShowType_MingYu then
				if noticeType == enBattleNoticeType.HP_DWON then
					noticeType = enBattleNoticeType.SHENBING_DWON
				elseif noticeType == enBattleNoticeType.HP_CRIT then
					noticeType = enBattleNoticeType.SHENBING_CRIT
				end
			elseif skillConfig.showtype == SkillConsts.ShowType_Armor then
				if noticeType == enBattleNoticeType.HP_DWON then
					noticeType = enBattleNoticeType.SHENBING_DWON
				elseif noticeType == enBattleNoticeType.HP_CRIT then
					noticeType = enBattleNoticeType.SHENBING_CRIT
				end
			elseif skillConfig.showtype == SkillConsts.ShowType_Tianshen then
				if noticeType == enBattleNoticeType.HP_DWON then
					noticeType = enBattleNoticeType.TIANSHEN_DWON;
				elseif noticeType == enBattleNoticeType.HP_CRIT then
					noticeType = enBattleNoticeType.TIANSHEN_CRIT;
				end
			end
        end
        if bit.band(flags, DAMAGE.SUPER) == DAMAGE.SUPER then
            noticeType = enBattleNoticeType.SUPER
        end
        if bit.band(flags, DAMAGE.IGDEF) == DAMAGE.IGDEF then
            noticeType = enBattleNoticeType.IGDEF
        end
		if bit.band(flags,DAMAGE.TIANSHEN) == DAMAGE.TIANSHEN then
			if noticeType == enBattleNoticeType.HP_DWON then
				noticeType = enBattleNoticeType.TIANSHEN_DWON;
			elseif noticeType == enBattleNoticeType.HP_CRIT then
				noticeType = enBattleNoticeType.TIANSHEN_CRIT;
			end
		end
		if bit.band(flags,DAMAGE.LINGQI) == DAMAGE.LINGQI then
			if noticeType == enBattleNoticeType.HP_DWON then
				noticeType = enBattleNoticeType.LINGQI_DOWN
			elseif noticeType == enBattleNoticeType.HP_CRIT then
				noticeType = enBattleNoticeType.LINGQI_CRIT
			end
		end
    end

    for i = 1, multiDamage do
        local currDamage = 0
        if i == multiDamage then
            currDamage = damage        
        else
            if randomDamage > 0 and damage > 0  and averageDamege > 0 then
                currDamage = averageDamege + math.random(1, randomDamage)
                damage = damage - currDamage
            end
        end
        if currDamage >0 or noticeType == enBattleNoticeType.DODGE then
			char:AddSkipNumber(noticeType, currDamage);
        end
    end

    if charType == enEntType.eEntType_Player then
        char:PlayHurtPfx(skillId)
		SoundManager:PlaySfx(2021);
    elseif charType == enEntType.eEntType_Monster then
        char:PlayHurtAction(skillId)
        char:PlayHurtPfx(skillId)
		SoundManager:PlaySfx(2058);
        if QTE then
            char:PlayQTEPfx()
		end
		local monsterCurHP = char:GetCurrHP() - drophp;
		if TargetManager:CheckIsTarget(char) then
			TargetModel:UpdateTargetAttr(enAttrType.eaHp, monsterCurHP);
		end
		char:UpdateHPInfo(monsterCurHP);
    end

end

local dist = _Vector3.new()
local scale_mat = _Matrix3D.new()
function SkillController:ClickLockChar(cid)  -- 选择的目标
    if cid == MainPlayerController:GetRoleID() then
        return
    end
    
    local lockState = TargetManager:IsLocked()
    if lockState then
        return
    end

    local char, charType = CharController:GetCharByCid(cid)
    if not char then
        return
    end

    if charType == enEntType.eEntType_Monster and (char:IsDead() or char:IsHide()) then
        return
    end
    if not (charType == enEntType.eEntType_Player or charType == enEntType.eEntType_Monster or charType == enEntType.eEntType_Npc) then
        return
    end
    if self.targetType == charType and self.targetCid == cid then
        return
    end
    local targetPos = char:GetAvatar():GetPos()
    if not targetPos then
        return
    end
    local vecSelfPos = MainPlayerController:GetPlayer():GetAvatar():GetPos()

    _Vector3.sub(targetPos, vecSelfPos, dist)

    local length = dist:magnitude()
    if length > self.targetMaxLength then
        return
    end
    self:ClearTarget()
    self.targetType = charType
    self.targetCid = cid

    local pfxId = LockRoundConfig.monster
    if charType == enEntType.eEntType_Player then
        pfxId = LockRoundConfig.difang_player
        if MainPlayerController:PlayerIsAttack(cid) ~= 0 then
            pfxId = LockRoundConfig.youfang_player
        end
        char:GetAvatar():PlayerPfx(pfxId)
    elseif charType == enEntType.eEntType_Npc then
        pfxId = LockRoundConfig.npc
    	char:GetAvatar():PlayerPfx(pfxId)
    elseif charType == enEntType.eEntType_Monster then
        if char:IsBoss() then
            pfxId = LockRoundConfig.boss
        end
        if char:IsHalo() then
            local width = char:GetWidth() / 10
            scale_mat:setScaling(width, width, width)
            char:GetAvatar():PlayerPfxByMat(pfxId, scale_mat)
        end
        char:SetHighLight()
        char:DeleteFootPfx()
    end
    --UI选中的目标显示 @charType 选中目标类型，@char 选中目标
    TargetManager:ShowTarget( charType, char );
end

function SkillController:GetChar(charType, cid)
    local char = nil
    if charType == enEntType.eEntType_Player then
        if cid == MainPlayerController:GetRoleID() then
            char = MainPlayerController:GetPlayer()
        else
            char = CPlayerMap:GetPlayer(cid)
        end
    elseif charType == enEntType.eEntType_Monster then
        MonsterController:GetMonster(cid)
    else
        char = MainPlayerController:GetPlayer()
    end
    return char
end

function SkillController:GetCurrTarget()
    return CharController:GetCharByCid(self.targetCid)
end

function SkillController:GetCurrTargetCid()
    return self.targetCid
end

function SkillController:AutoCancelClickNpc()
	local char, charType = CharController:GetCharByCid(self.targetCid)
	if char and charType == enEntType.eEntType_Npc then
		SkillController:ClearTarget()
	end
end

function SkillController:ClearTarget()
    local oldTargetChar, charType = CharController:GetCharByCid(self.targetCid)
    self.targetType = nil
    self.targetCid = nil
    if oldTargetChar then
        local avatar = oldTargetChar:GetAvatar()
        if avatar then
            avatar:StopPfx(LockRoundConfig.monster)
            avatar:StopPfx(LockRoundConfig.npc)
            avatar:StopPfx(LockRoundConfig.boss)
            avatar:StopPfx(LockRoundConfig.youfang_player)
            avatar:StopPfx(LockRoundConfig.difang_player)
            if charType == enEntType.eEntType_Monster then 
                oldTargetChar:DelHighLight()
                oldTargetChar:AddFootPfx()
            end
        end
    end
    --关闭UI 
    TargetManager:HideTarget();
end

--技能冷却
function SkillController:CoolDown(castCid, skillId, cdTime, cdGroup, cdGroupTime)
    for pos, skillInfo in pairs(SkillModel:GetShortcutList()) do
        if skillInfo.skillId ~= skillId then
            if t_skill[skillInfo.skillId] and t_skill[skillInfo.skillId].group_cd_id == cdGroup then
 				if SkillModel:GetSkillCD(skillInfo.skillId) <= 0 then--技能组cd不能顶掉原cd
					self:sendNotification(NotifyConsts.SkillPlayCD,{skillId=skillInfo.skillId, time=cdGroupTime})
				end
            end
        end
    end
    SkillModel:SetSkillGroupCD(skillId, cdGroupTime)
    SkillModel:SetSkillCD(skillId, cdTime)
	self:sendNotification(NotifyConsts.SkillPlayCD,{skillId=skillId,time=cdTime})
end

function SkillController:CheckSkillCD(skillId)
    if SkillModel:GetSkillCD(skillId) > 0 then
        return false
    end
    if SkillModel:GetGroupCD(skillId) > 0 then
        return false
    end
    return true
end

function SkillController:SetComboSkillCD(skillId)
    local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    if skillConfig.oper_type ~= SKILL_OPER_TYPE.COMBO then
        return
    end
    if SkillController.comboing then
        return
    end
    SkillController.CDList[skillId] = GetCurTime() + skillConfig.cd
end

function SkillController:CheckComboSkillCD(skillId)
    local skillConfig = t_skill[skillId]
    if not skillConfig then
        return false
    end
    if skillConfig.oper_type ~= SKILL_OPER_TYPE.COMBO then
        return true
    end
    if SkillController.comboing then
        return true
    end
    if not SkillController.CDList[skillId] then
        return true
    end
    if SkillController.CDList[skillId] <= GetCurTime() then
        return true
    end
    return false
end

function SkillController:IsNeedInterruptState()
    if SkillController.PrepState == true then
        return true
    end
    if SkillController.CollectState == true then
        return true
    end
    return false
end

function SkillController:TryInterruptCast(skillId)
    if self.CurrPrepSkillId then
       self:SendInterruptCast(self.CurrPrepSkillId)
       self.CurrPrepSkillId = nil
    end
    if self.CurrCollectSkillId then
       self:SendInterruptCast(self.CurrCollectSkillId)
       self.CurrCollectSkillId = nil
    end
end

function SkillController:CastKnockBack(cid, time, pos)
    local char, charType = CharController:GetCharByCid(cid)
    if charType == enEntType.eEntType_Monster then
        char:KnockBack(time, pos)
    end
end

function SkillController:CastMotionEffect(castCid, skillId, time, pos)
    if castCid == MainPlayerController:GetRoleID() then
        return
    end
    local castChar, charType = CharController:GetCharByCid(castCid)
    if not castChar then
        return false
    end
    local skillConfig = t_skill[skillId]
    if not skillConfig then
        return false
    end
    local skill_action = t_skill_action[tonumber(skillConfig.skill_action)] 
    if not skill_action then
        return false
    end

    pos.z = CPlayerMap:GetSceneMap():getSceneHeight(pos.x, pos.y)
    local skill_type = skillConfig.oper_type
    if skill_type == SKILL_OPER_TYPE.ROLL then
        castChar:PlaySkill(skillId, nil, pos)
    else
        SkillController:CharChangeDirToPos(castCid, pos)
        castChar:PlaySkill(skillId, nil, pos)
    end
end

function SkillController:MultiKill(kill_number)

    if kill_number <= 1 then
        return
    end
    UIMultiCutEffect.killNum = kill_number
	if UIMultiCutEffect:IsShow() then
		UIMultiCutEffect:UpdateEffect()
	else
		UIMultiCutEffect:Show()
	end

end

function SkillController:CastMagicResult(skillId, resultCode)
    Debug(">>>>>>>>>>>>>>>>", skillId, resultCode)
    if resultCode ~= 0 then
        AutoBattleController:WhenCastMagicFail(skillId)
    end
end

function SkillController:Rampage(kill, exp)
    --显示UI
    -- UIZhimingjishaPfx:SetInfo(kill,exp)
end

function SkillController:CheckConsume(skillId)
    local skillConfig = t_skill[skillId]
    if not skillConfig then
        return 0
    end
    local consumeType = skillConfig.consume_type
    local consumeNumber = skillConfig.consum_num
    if consumeNumber <= 0 then
        return 1
    end
	local playerInfo = MainPlayerModel.humanDetailInfo;
    if consumeType == SKILL_CONSUM_TYPE.HP then
        return playerInfo.eaHp < consumeNumber and 0 or 1
    -- elseif consumeType == SKILL_CONSUM_TYPE.MP then
    --     return playerInfo.eaMp < consumeNumber and 0 or 1
    elseif consumeType == SKILL_CONSUM_TYPE.HPPER then
        return playerInfo.eaHp < consumeNumber * playerInfo.eaHp * 0.01 and 0 or 1
    elseif consumeType == SKILL_CONSUM_TYPE.MPPER then
        return playerInfo.eaMp < consumeNumber * playerInfo.eaMp * 0.01 and 0 or 1
    elseif consumeType == SKILL_CONSUM_TYPE.TILI then
        return playerInfo.eaTiLi < consumeNumber and 0 or 1
    elseif consumeType == SKILL_CONSUM_TYPE.NUQI then
        return 1 --todo
    elseif consumeType == SKILL_CONSUM_TYPE.MAXHP then
        return playerInfo.eaHp < consumeNumber * playerInfo.eaMaxHp * 0.01 and 0 or 1
    -- elseif consumeType == SKILL_CONSUM_TYPE.MAXMP then
    --     return playerInfo.eaMp < consumeNumber * playerInfo.eaMaxMp * 0.01 and 0 or 1
    elseif consumeType == SKILL_CONSUM_TYPE.WUHUN then
        return playerInfo.eaWuHunSP < consumeNumber and 0 or 1
    elseif consumeType == SKILL_CONSUM_TYPE.KILLMONSTER then   --adder:houxudong date:2016/10/22 16:28:36
        return MakinoBattleDungeonModel:GetCurAllPointSocre() < consumeNumber and 0 or 1
    elseif consumeType == SKILL_CONSUM_TYPE.TIANSHEN then
		local temp = tostring(consumeNumber);tostring(consumeNumber);
		local mp = toint(string.sub(temp,0,2));
		local wuhun = toint(string.sub(temp,3));
		local can = true;
		if playerInfo.eaMp<mp then
			can = false;
		end
		if math.round(playerInfo.eaWuHunSP)<wuhun then
			can = false;
		end
		return can and 1 or 0;
	end
	
end

function SkillController:GetRollDis(skillId)
    local skillConfig = t_skill[skillId]
    for i = 1, 3 do
        local effectId = skillConfig["effect_" .. i]
        if effectId and effectId ~= 0 then
            local skillEffect = t_effect[effectId]
            if skillEffect and skillEffect.skill_param and skillEffect.skill_param ~= "" then
                local skillParamTable = GetCommaTable(skillEffect.skill_param)
                local dis = tonumber(skillParamTable[1])
                return dis
            end
        end
    end
end

function SkillController:GetSkillDelayTime(skillId)
    local skillConfig = t_skill[skillId]
    for i = 1, 3 do
        local effectId = skillConfig["effect_" .. i]
        if effectId and effectId ~= 0 then
            local skillEffect = t_effect[effectId]
            if skillEffect and skillEffect.percent and skillEffect.percent > 0 then
                return skillEffect.delay
            end
        end
    end
    return 0
end

function SkillController:GetRollTime(skillId)
    local skillConfig = t_skill[skillId]
    for i = 1, 3 do
        local effectId = skillConfig["effect_" .. i]
        if effectId and effectId ~= 0 then
            local skillEffect = t_effect[effectId]
            if skillEffect and skillEffect.skill_param and skillEffect.skill_param ~= "" then
                local skillParamTable = GetCommaTable(skillEffect.skill_param)
                local time = tonumber(skillParamTable[2])
                return time
            end
        end
    end
end

function SkillController:GetRollPos(rollDis, targetPos)
    local dir
    local pos1 = {}
    local pos = MainPlayerController:GetPlayer():GetPos()
    if not targetPos then
        dir = MainPlayerController:GetPlayer():GetAvatar():GetDirValue()
    else
        dir = GetDirTwoPoint(targetPos, pos)
    end
    pos1.x = pos.x - rollDis * math.sin(dir)
    pos1.y = pos.y + rollDis * math.cos(dir)
    pos1.z = CPlayerMap:GetSceneMap():getSceneHeight(pos1.x, pos1.y)
    if not pos1.z then
        return
    end
    local ret = CPlayerMap:GetSceneMap():CanMoveTo(pos, pos1)
    if not ret then
        return
    end
    return pos1
end

function SkillController:AutoClearTarget()
    if SkillController.targetCid then
        local char, charType = CharController:GetCharByCid(SkillController.targetCid)
        if not char then
            SkillController:ClearTarget()
            return
        end
        if not char:GetAvatar() then
            SkillController:ClearTarget()
            return
        end
        if charType == enEntType.eEntType_Monster and char:IsDead() then
            SkillController:ClearTarget()
            return
        end
        local targetPos = char:GetAvatar():GetPos()
        if not targetPos then
            SkillController:ClearTarget()
            return
        end
        local vecSelfPos = MainPlayerController:GetPlayer():GetAvatar():GetPos()
        _Vector3.sub(targetPos, vecSelfPos, dist)
        local length = dist:magnitude()
        if length > self.targetMaxLength then
            self:ClearTarget()
        end
    end
end

function SkillController:GetDamage(skillId)
    local skillConfig = t_skill[skillId]
    local percent = 0
    local ex_damage = 0
    for i = 1, 3 do
        local effectId = skillConfig["effect_" .. i]
        if effectId and effectId ~= 0 then
            local skillEffect = t_effect[effectId]
            if skillEffect then
                percent = percent + skillEffect.percent
                ex_damage = ex_damage + skillEffect.ex_damage
            end
        end
    end
    return percent*0.01, ex_damage
end

local lingzhenVector = _Vector3.new()
local lingzhenPfxMat = _Matrix3D.new()
function SkillController:PlayLingzhenPfx()
    local pos = GetMousePos()
    if not pos then
        return
    end
    lingzhenVector.x = pos.x
    lingzhenVector.y = pos.y
    lingzhenVector.z = pos.z
    local pfxId = 10029
    local selfPos = MainPlayerController:GetPlayer():GetPos()
    local ret = CPlayerMap:GetSceneMap():CanMoveTo(selfPos, pos)
    if ret then
        pfxId = 10028
    end
    if SkillController.lingzhenPfxLastState == ret then
        if SkillController.lingzhenPfx then
            lingzhenPfxMat:setTranslation(lingzhenVector)
            SkillController.lingzhenPfx.transform = lingzhenPfxMat
        else
            local pfx = CPlayerMap:GetSceneMap():PlayerPfx(pfxId, lingzhenVector)
            if pfx then
                SkillController.lingzhenPfx = pfx
            end
        end
    else
        if SkillController.lingzhenPfx then
            SkillController.lingzhenPfx:stop()
            SkillController.lingzhenPfx = nil
        else
            local pfx = CPlayerMap:GetSceneMap():PlayerPfx(pfxId, lingzhenVector)
            if pfx then
                SkillController.lingzhenPfx = pfx
            end
        end
    end
    SkillController.lingzhenPfxLastState = ret
    SkillController.lingzhenPos = pos
end

function SkillController:CastLingzhen(skillId)
    SkillController.lingzhenSkillId = skillId
    SkillController.lingzhenState = true
    SkillController:PlayLingzhenPfx()
end

function SkillController:UpdateLingzhenPfxPos()
    if not SkillController.lingzhenState then
        return
    end
    SkillController:PlayLingzhenPfx()
end

function SkillController:TryUseLingzhen()
    if SkillController.lingzhenState then
        local skillId = SkillController.lingzhenSkillId
        if skillId then
            SkillController:PlayCastSkill(skillId, true)
            SkillController:InterruptLingzhen()
        end
    end
end

function SkillController:InterruptLingzhen()
    if SkillController.lingzhenState then
        SkillController.lingzhenState = nil
        SkillController.lingzhenSkillId = nil
        SkillController.lingzhenPos = nil
        SkillController.lingzhenPfxLastState = nil
        if SkillController.lingzhenPfx then
            local pfx = SkillController.lingzhenPfx
            pfx:stop()
        end
    end
end

function SkillController:GetLingzhenPos(skillId)
    local targetPos = nil
    if SkillController.lingzhenPos then
        targetPos = SkillController.lingzhenPos
    else
        local skillConfig = t_skill[skillId]
        local dis = skillConfig.trap_seat
        targetPos = MainPlayerController:GetFrontPos(dis)
    end
    if targetPos then
        local pos = MainPlayerController:GetPos()
        local ret = CPlayerMap:GetSceneMap():CanMoveTo(pos, targetPos)
        if ret then
            return targetPos
        end
    end
end

---------------------------------------------------------------------

function SkillController:SendInterruptCast(skillId)
    local msg = ReqInterruptCastMsg:new()
    msg.skillID = skillId
    MsgManager:Send(msg)
end

function SkillController:SendTryCastSkill(skillId, targetCid, targetX, targetY)
    local msg = ReqCastMagicMsg:new()
    msg.skillID = skillId
    msg.targetID = targetCid
    msg.posX = targetX
    msg.posY = targetY
    MsgManager:Send(msg)
end

function SkillController:OnCastBegin(msg)
    local castCid = msg.casterID
    local skillId = msg.skillID
    local targetCid = msg.targetID
    local x = msg.posX / 1000
    local y = msg.posY / 1000
    self:CastSkill(castCid, skillId, targetCid, {x = x, y = y})
end

function SkillController:OnCastEnd(msg)
    local castCid = msg.casterID
    local skillId = msg.skillID
end

function SkillController:OnCastEffect(msg)
    local castCid = msg.casterID
    local skillId = msg.skillID
    local targetCid = msg.targetID
    local damage = msg.damage
    local flags = msg.flags
	local drophp = msg.drophp
    self:CastEffect(castCid, targetCid, skillId, damage, flags, drophp)
end

function SkillController:OnSkillCooldown(msg)
    local castCid = msg.casterID
    local skillId = msg.skillID
    local cdTime = msg.cdTime
    local cdGroup = msg.cdGroup
    local cdGroupTime = msg.cdGroupTime
    self:CoolDown(castCid, skillId, cdTime, cdGroup, cdGroupTime)
end

function SkillController:OnCastPrepBegin(msg)
    local castCid = msg.casterID
    local skillId = msg.skillID
    local prepTime = msg.prepTime
    local targetCid = msg.targetID
    local x = msg.posX
    local y = msg.posY
    self:CastPrepBegin(castCid, skillId, targetCid, {x = x, y = y}, prepTime)
end

function SkillController:OnCastPrepEnd(msg)
    local castCid = msg.casterID
    local skillId = msg.skillID
    self:CastPrepEnd(castCid, skillId, msg.isend)
end

function SkillController:OnCastChanBegin(msg)
    local castCid = msg.casterID
    local skillId = msg.skillID
    local targetCid = msg.targetID
    local x = msg.posX
    local y = msg.posY
    self:CastChanBegin(castCid, skillId, targetCid, {x = x, y = y})
end

function SkillController:OnCastChanEnd(msg)
    local castCid = msg.casterID
    local skillId = msg.skillID
    self:CastChanEnd(castCid, skillId)
end

function SkillController:OnKnockBack(msg)
    local castCid = msg.caster
    local targetCid = msg.target
    local speed = msg.speed
    local time = msg.time
    local posX = msg.posX
    local posY = msg.posY
    self:CastKnockBack(targetCid, time, {x = posX, y = posY})
end

function SkillController:OnCastComboBegin(msg)
    local castCid = msg.casterID
    local skillId = msg.skillID
    local comboTime = msg.contTime
    local targetCid = msg.targetID
    local x = msg.posX
    local y = msg.posY
    self:CastComboBegin(castCid, skillId, targetCid, {x = x, y = y}, comboTime)
end

function SkillController:OnCastComboEnd(msg)
    local castCid = msg.casterID
    local skillId = msg.skillID
    self:CastComboEnd(castCid, skillId)
end

function SkillController:OnCastMotionEffect(msg)
    local castCid = msg.casterID
    local targetCid = msg.targetID
    local skillId = msg.skillID
    local skillEffectId = msg.skillEffectID
    local time = msg.time
    local posX = msg.posX
    local posY = msg.posY
    self:CastMotionEffect(castCid, skillId, time, {x = posX, y = posY})
end

function SkillController:OnCastMagicResult(msg)
    local skillId = msg.skillId
    local resultCode = msg.resultCode
    self:CastMagicResult(skillId, resultCode)
end

function SkillController:OnRampageInfo(msg)
    local kill = msg.kill
    local exp = msg.exp
    self:Rampage(kill, exp)
end

function SkillController:OnCastPassiveSkill(msg)
    local skillId = msg.skillId
    SkillController:ShowSkillNamePfx(skillId)
    SkillController:ShowShenwuPfx(skillId)
	--被动技能客户端设置CD
	local cfg = t_passiveskill[msg.skillId];
	if not cfg then return; end
	SkillModel:SetSkillCD(msg.skillId, cfg.cd)
	self:sendNotification(NotifyConsts.SkillPlayCD,{skillId=msg.skillId,time=cfg.cd})
end

function SkillController:ShowShenwuPfx(skillId)
    local config = t_passiveskill[skillId]
    if not config then
        return
    end
    local player = MainPlayerController:GetPlayer()
    if not player then
        return
    end
    local avatar = player:GetAvatar()
    if not avatar then
        return
    end
    if config.effect_pfx and config.effect_pfx ~= "" then
        local list = GetPoundTable(config.effect_pfx)
        local prof = MainPlayerController:GetProfID()
        if prof and list[prof] and list[prof] ~= "" then
            avatar:PlayerPfxOnSkeleton(list[prof] .. ".pfx")
        end
    end
end

function SkillController:ShowSkillNamePfx(skillId)
    local skillConfig = t_passiveskill[skillId] or t_skill[skillId]
    if not skillConfig then
        return
    end
	
	UISkillNameEffect:ShowSkillNameEffect(skillId)
    -- local pfx = skillConfig.name_pfx
    -- if pfx and pfx ~= "" then
        -- local pfxTable = GetPoundTable(pfx)
        -- local pfxFile = pfxTable[1]
        -- local imgFile = pfxTable[2]
        -- if pfxFile and pfxFile ~= "" and imgFile and imgFile ~= "" then
            -- local selfPlayer = MainPlayerController:GetPlayer()
            -- if not selfPlayer then
                -- return
            -- end
            -- selfPlayer:GetAvatar():PlaySkillNamePfx(pfxFile, imgFile)
        -- end
    -- end
end
------------------------技能学习相关-------------------------

--请求学习绝学或者心法
function SkillController:LearnMagicSkill(skillType,operator,gid)
    local msg = ReqJueXueOperMsg:new();
    msg.type = skillType
    msg.oper = operator
    msg.gid = gid
    MsgManager:Send(msg);
end
--服务器返回绝学学习升级突破结果
local respGid;
function SkillController:JueXueOperResult( msg )
    if msg.result == 0 then   ----成功
        ----绝学
        if msg.type == MagicSkillConsts.magicSkillType_juexue then

            if msg.oper == MagicSkillConsts.magicSkillOper_xuexi then    --- 学习
                self:sendNotification( NotifyConsts.MagicSkillLearn);  
            end
            if msg.oper == MagicSkillConsts.magicSkillOper_shengji then  --- 升级
                self:sendNotification( NotifyConsts.MagicSkillUpgrade);
            end
            if msg.oper == MagicSkillConsts.magicSkillOper_tupo  then    --- 突破
                self:sendNotification( NotifyConsts.MagicSkillTupo);
            end
        end
        ----心法
        if msg.type == MagicSkillConsts.magicSkillType_xinfa then
            if msg.oper == MagicSkillConsts.magicSkillOper_xuexi then 
                self:sendNotification( NotifyConsts.XinfaSkillLearn);  
            end
            if msg.oper == MagicSkillConsts.magicSkillOper_shengji then  
                self:sendNotification( NotifyConsts.XinfaSkillUpgrade);  
            end
            if msg.oper == MagicSkillConsts.magicSkillOper_tupo  then 
                self:sendNotification( NotifyConsts.XinfaSkillTupo);  
            end
        end
    else
       
        if msg.oper == MagicSkillConsts.magicSkillOper_xuexi then
            FloatManager:AddNormal( StrConfig['magicskill8'] );
        end

        if msg.oper == MagicSkillConsts.magicSkillOper_shengji then
            FloatManager:AddNormal( StrConfig['magicskil20'] );
        end

        if msg.oper == MagicSkillConsts.magicSkillOper_tupo then
            FloatManager:AddNormal( StrConfig['magicskil22'] );
        end

    end
end
---服务器返回：绝学心法信息更新
function SkillController:JueXueUpdate( msg )
    for k,v in pairs(msg.jxlist) do
        -- print(v.id,v.lv)
    end
    --test juexue
    local juexueList ={};
     for k,v in pairs(msg.jxlist) do
        if v.id == 0 and v.lv == 0 then  
        else
            table.push(juexueList,v)
        end
    end
    local haveList ={};
     for k,v in pairs(msg.xflist) do
        if v.id == 0 and v.lv == 0 then  
        else
            table.push(haveList,v)
        end
    end
    local magicSkillList = msg.jxlist
    local xinfaSkillList = msg.xflist
    local gid
    for i,skillInfo in pairs(juexueList) do
        for k,v in pairs(t_juexue) do
            if v.spot == skillInfo.lv and v.id == skillInfo.id then
                gid = v.juexuezu
                break
            end
        end
        if not gid then return; end
        local skillVO = SkillVO:new(skillInfo.id, skillInfo.lv,gid);
        if not skillVO then return; end
        SkillModel:AddSkill(skillVO);
        AutoBattleController:OnSkillAddResult( skillInfo.id );
    end

    for i,skillInfo in pairs(haveList) do
        local gid
        for k,v in pairs(t_xinfa) do
            if v.spot == skillInfo.lv and v.id == skillInfo.id then
                gid = v.juexuezu
                break
            end
        end
        if not gid then return; end
        local skillVO = SkillVO:new(skillInfo.id, skillInfo.lv,gid);  --math.floor(skillInfo.id / 10000)
        if not skillVO then return; end
        SkillModel:AddSkill(skillVO); 
        AutoBattleController:OnSkillAddResult( skillInfo.id );  --skillId

    end
end


--请求学习技能
function SkillController:LearnSkill(skillId)
	local msg = ReqSkillLearnMsg:new();
	msg.skillId = skillId;
	MsgManager:Send(msg);
end

--请求升级技能
function SkillController:LvlUpSkill(skillId)

    print(LvlUpSkill,"LvlUpSkill")
	local msg = ReqSkillLvlUpMsg:new();
	msg.skillId = skillId;
	MsgManager:Send(msg);
end
--请求升级技能
function SkillController:QuicklyLvUpSkill()
    local msg = ReqSkillLvlUpOneKeyMsg:new()
    MsgManager:Send(msg);
end
--快速升级技能
function SkillController:SkillLvlUpOneKeyResult( msg )
    if msg.result == 0 then
        self:sendNotification( NotifyConsts.SkillQuicklyLvlUp );
    elseif msg.result == 2 then
        FloatManager:AddNormal(StrConfig["quicklyskill"])
    elseif msg.result == 4 then
        FloatManager:AddNormal(StrConfig["quicklyskil2"])
    elseif msg.result == 5 then
        FloatManager:AddNormal(StrConfig["quicklyskil3"])
    elseif msg.result == 9 then
        FloatManager:AddNormal(StrConfig["quicklyskil4"])
    elseif msg.result == 10 then
        FloatManager:AddNormal(StrConfig["quicklyskil5"])
    elseif msg.result == 11 then
        FloatManager:AddNormal(StrConfig["quicklyskil6"])
    elseif msg.result == 12 then
        FloatManager:AddNormal(StrConfig["quicklyskil7"])
    elseif msg.result == 13 then
        FloatManager:AddNormal(StrConfig["quicklyskil8"])
    elseif msg.result == 14 then
        FloatManager:AddNormal(StrConfig["quicklyskil9"])
    elseif msg.result == 15 then
        FloatManager:AddNormal(StrConfig["quicklyskil10"])
    else
        -- FloatManager:AddNormal(StrConfig["quicklyskil11"])
    end
end
--返回技能列表
function SkillController:OnSkillListResult(msg)
	for i,skillInfo in ipairs(msg.skills) do
		local skillVO = SkillVO:new(skillInfo.skillId);
		SkillModel:AddSkill(skillVO);
	end
    AutoBattleController:OnSkillListResult();
end
--返回学习技能
function SkillController:OnSkillLearnResult(msg)
    if msg.result == 0 then

        local skillId = msg.skillId;
        local cfg = t_skill[skillId];
        if cfg then 
            if cfg.showtype >= 5 and cfg.showtype <= 8 then
            return;
            end
        end

        if not cfg then 
            cfg = t_passiveskill[skillId]
            if not cfg then
                return
            end
            if cfg.showtype == SkillConsts.ShowType_JuxuePassive then
                return
            end
        end
		local skillVO = SkillVO:new(skillId);
		SkillModel:AddSkill(skillVO);
		self:sendNotification( NotifyConsts.SkillLearn, { skillId = skillId } );
		AutoBattleController:OnSkillAddResult( skillId );
		RemindFuncController:RemoveFailPreshow(); 
    end
end

--增加技能
function SkillController:OnSkillAddResult(msg)

    local skillId = msg.skillId;
    local skillVO = SkillVO:new( skillId );
    SkillModel:AddSkill(skillVO);
    self:sendNotification( NotifyConsts.SkillAdd, { skillId = skillId } ); 
    AutoBattleController:OnSkillAddResult( skillId );
end

--移除技能
function SkillController:OnSkillRemoveResult(msg)
    SkillModel:DeleteSkill(msg.skillId)
    self:sendNotification( NotifyConsts.SkillRemove, { skillId = msg.skillId } );
    AutoBattleController:OnSkillRemoveResult( msg.skillId );
end

--返回升级技能     -------------hxd--------------
function SkillController:OnSkillLvlUpResult(msg)
   -- print("收到服务器返回的消息: "..msg.result)
    -- debug.debug()
	if msg.result == 0 then
		--FloatManager:AddNormal(StrConfig["skill109"]);
		SkillModel:DeleteSkill(msg.oldSkillId);
		local skillVO = SkillVO:new(msg.skillId);
		SkillModel:AddSkill(skillVO);
		self:sendNotification(NotifyConsts.SkillLvlUp,{skillId=msg.skillId,oldSkillId=msg.oldSkillId});
        AutoBattleController:OnSkillLvlUpResult(msg.skillId, msg.oldSkillId);
		local skillFunc = FuncManager:GetFunc(FuncConsts.Skill);
		if skillFunc then
			skillFunc:RefreshLvlIcon();
		end
		RemindFuncController:RemoveFailPreshow();
	end
end

--返回技能栏
function SkillController:OnSkillShortcutList(msg)
	SkillModel:ClearShortCutList(not MainPlayerController:InTransform());

	for i,vo in ipairs(msg.data) do
		SkillModel:SetShortCut(vo.pos,vo.id);
		--按数字5 的法宝技能
		if vo.pos == SkillConsts.LingQiSkillKeyPos then
			AutoBattleController:OnSkillAddResult(vo.id)
		end
	end
	self:sendNotification(NotifyConsts.SkillShortCutRefresh);
end

--请求技能栏设置
function SkillController:SkillShortCutSet(pos,skillId)
	local msg = ReqSkillShortCutMsg:new();
	msg.skillId = skillId;
	msg.pos = pos;
	MsgManager:Send(msg);
end

--返回技能栏设置
function SkillController:OnSkillShortCut(msg)
    -- print("*********技能id:",msg.pos,msg.skillId)
    if not UISkillNewTips:IsShow() then
        SkillModel:SetShortCut(msg.pos,msg.skillId);
        AutoBattleModel:ResetSpecialSkill(msg.skillId)
    end
	self:sendNotification(NotifyConsts.SkillShortCutChange,{pos=msg.pos,skillId=msg.skillId});
end

--武魂技能改变
function SkillController:OnWuhunSkillChange()
	local wuhunSkills = SpiritsModel:GetWuhunActiveSkillList();
	if wuhunSkills[1] then
		SkillModel:SetShortCut(14,wuhunSkills[1]);
		self:sendNotification(NotifyConsts.SkillShortCutChange,{pos=14,skillId=wuhunSkills[1]});
	else
		SkillModel:SetShortCut(14,0);
		self:sendNotification(NotifyConsts.SkillShortCutChange,{pos=14,skillId=0});
	end
	if wuhunSkills[2] then
		SkillModel:SetShortCut(15,wuhunSkills[2]);
		self:sendNotification(NotifyConsts.SkillShortCutChange,{pos=15,wuhunSkills[2]});
	else
		SkillModel:SetShortCut(15,0);
		self:sendNotification(NotifyConsts.SkillShortCutChange,{pos=15,skillId=0});
	end
end

--法宝技能改变
function SkillController:OnFabaoSkillChange(skillId)
	if skillId > 0 then
		SkillModel:SetShortCut(17,skillId);
		self:sendNotification(NotifyConsts.SkillShortCutChange,{pos=17,skillId=skillId});
	else
		SkillModel:SetShortCut(17,0);
		self:sendNotification(NotifyConsts.SkillShortCutChange,{pos=17,skillId=0});
	end	
end

--法宝普通技能改变
function SkillController:OnFabaoNSkillChange(skillId)
	if skillId > 0 then
		SkillModel:SetShortCut(19,skillId);
		self:sendNotification(NotifyConsts.SkillShortCutChange,{pos=19,skillId=skillId});
	else
		SkillModel:SetShortCut(19,0);
		self:sendNotification(NotifyConsts.SkillShortCutChange,{pos=19,skillId=0});
	end	
end


--冰魂技能改变
function SkillController:OnBingHunSkillChange()
	local skillId = BingHunModel:GetBingHunSkill();
	if skillId > 0 then
		SkillModel:SetShortCut(18,skillId);
		self:sendNotification(NotifyConsts.SkillShortCutChange,{pos=18,skillId=skillId});
	else
		SkillModel:SetShortCut(18,0);
		self:sendNotification(NotifyConsts.SkillShortCutChange,{pos=18,skillId=0});
	end
end

--设置技能栏物品
function SkillController:ItemShortCut(itemId)
	local msg = ReqItemShortCutMsg:new();
	msg.itemId = itemId;
	MsgManager:Send(msg);
end

--返回设置技能栏物品
function SkillController:OnItemShortCut(msg)
	SkillModel.shortCutItem = msg.itemId;
	self:sendNotification(NotifyConsts.ItemShortCutRefresh);
end

--同步技能CD
function SkillController:OnSkillCDList(msg)
	for i,vo in ipairs(msg.list) do
        local skillId = vo.skillID
		SkillModel:SetSkillCD(skillId, vo.cdTime);
        local time = SkillController:GetSkillGroupCD(skillId);
        if time and time > 0 then
            SkillModel:SetSkillGroupCD(skillId, math.min(time, vo.cdTime));
        end
	end
end

function SkillController:GetSkillGroupCD(skillId)
    local skillConfig = t_skill[skillId]
    if not skillConfig then
        return 0
    end
    return skillConfig.group_cd
end