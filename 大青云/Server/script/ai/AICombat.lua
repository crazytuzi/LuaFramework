----------------------------------------------------------
-- 战斗AI实现
----------------------------------------------------------

g_ai_cls_combat = {}
g_ai_cls_combat_evt = {}
g_ai_cls_combat_fsm = {}

g_ai_cls_combat.event = g_ai_cls_combat_evt
g_ai_cls_combat.state = g_ai_cls_combat_fsm

-- ******************************************************
-- ai事件
-- ******************************************************
-- 被杀死
-- 切换到死亡状态
function g_ai_cls_combat_evt:OnDead(env,killerid)
	env:Switch("killed")
	env:Break()
end

-- 仇恨列表不为空
-- 切换到攻击状态
function g_ai_cls_combat_evt:OnThreatAdded(env,firstid)
	env:Switch("attack_auto")
	env:Break()
end

-- 敌人列表为空
-- 切换到返回状态
function g_ai_cls_combat_evt:OnThreatEmpty(env,lastid)
	if env.ai_state == "back" then
        return
    end
    env:Switch("back")
	env:Break()
end

-- 受控攻击
function g_ai_cls_combat_evt:OnManuAttacked(env)
	if env.ai_state == "attack_manu" then
        return
    end
    env:Switch("attack_manu")
	env:Break()
end

-- 目标改变
function g_ai_cls_combat_evt:OnTargetChanged(context,oid,nid)
	
end

-- 追击超时
-- 切换到返回状态
function g_ai_cls_combat_evt:OnChaseTimeout(env)
	env:Switch("back")
	env:Break()
end

-- 超出领地范围
-- 切换到返回领地状态
function g_ai_cls_combat_evt:OnExceedBackPos(env)
	env:Switch("back")
	env:Break()
end

-- 受到攻击
-- 切换到攻击状态
function g_ai_cls_combat_evt:OnMagicHited(env,caster,skillid)
    if env.ai_state == "back" or env.ai_state == "attack_auto" then
        return
    end
	env:Switch("attack_auto")
	env:Break()
end

-- 移动到后使用技能
function g_ai_cls_combat_evt:MoveAndCastMagic(env,skillid,speedrate)
	local code,data = env:MoveToCastPos(speedrate)
	if env:IsBreak() == true then
		return code,data
	end
	-- 移动失败或者被打断，返回
	if code ~= AICode.Successful then
		return code,data
	end

	-- 施放技能
	return env:CastMagic(skillid,1)
end

-- 追击到后使用技能
function g_ai_cls_combat_evt:ChaseAndCastMagic(env,skillid,speedrate)
	local code,data = env:ChaseTarget(skillid,speedrate)
	if env:IsBreak() == true then
		return code,data
	end
	
	-- 已经在追击范围内
	if code == AICode.ChaseReached then
		return env:CastMagic(skillid,0)
	end
	
	-- 追击失败或者被打断，返回
	if code ~= AICode.Successful then
		return code,data
	end
	
	-- 追击到达后，检测是否重叠
	local dist = env:GetMagicCastDist(skillid)
	 if dist <= 0 then
        dist = 1.5
    else
        dist = math.min(dist,1.5)
    end

	if env:IsOverlap(0.5) == true then
		code,data = env:MoveToTarget(dist)
		if env:IsBreak() == true then
			return code,data
		end
	end

	-- 施放技能
	return env:CastMagic(skillid,0)
end

function g_ai_cls_combat_evt:CastMagicToObj(env,skillid,speedrate)
	-- 启动行动超时计时器
	env:StartupActionTimer()

	local code,data = g_ai_cls_combat_evt:ChaseAndCastMagic(env,skillid,speedrate)
	if env:IsBreak() == true then
		env:CleanupActionTimer()
		return
	end

	-- 追击被打断，休息一段时间，重新选择技能
	if code == AICode.MotionCleanup then
		env:CleanupActionTimer()
		env:Sleep(1000)
		return
	end
	
	-- 追击失败，目的不可达，返回领地
	if code == AICode.MotionUnreachable or code == AICode.TargetInvalid then
		env:CleanupActionTimer()
		env:Switch("back")
		return
	end
	env:CleanupActionTimer()
	env:Switch("wait")
end

function g_ai_cls_combat_evt:CastMagicToPos(env,skillid,speedrate)
	-- 启动行动超时计时器
	env:StartupActionTimer()

	local code,data = g_ai_cls_combat_evt:MoveAndCastMagic(env,skillid,speedrate)
	if env:IsBreak() == true then
		env:CleanupActionTimer()
		return
	end
	
	-- 追击失败，目的不可达，返回领地
	if code == AICode.MotionUnreachable or code == AICode.TargetInvalid then
		env:CleanupActionTimer()
		env:Switch("back")
		return
	end

	env:CleanupActionTimer()
	env:Switch("idle")
end

-- 施放技能超时
function g_ai_cls_combat_evt:OnActionTimeout(env)
	env:Switch("attack_auto")
	env:Break()
end

-- 行动等待超时
function g_ai_cls_combat_evt:OnActionWaitTimeout(env)
	env:Switch("attack_auto")
	env:Break()
end

-- ******************************************************
-- AI状态
-- ******************************************************

-- 空闲状态
function g_ai_cls_combat_fsm:idle(env)
	env:Sleep(3000)
end

-- 死亡状态
function g_ai_cls_combat_fsm:killed(env)
	env:Exit()
end

-- 手动攻击状态
function g_ai_cls_combat_fsm:attack_manu(env)
	local skillid = env:SelectManuSkillID()

	local casttype = env:GetCastType()
	if casttype == AICastType.CastOnPos then
		g_ai_cls_combat_evt:CastMagicToPos(env,skillid,10)
	else
		g_ai_cls_combat_evt:CastMagicToObj(env,skillid,10)
	end
end

-- 自动攻击状态
function g_ai_cls_combat_fsm:attack_auto(env)
	local skillid = env:SelectSkillID()
	g_ai_cls_combat_evt:CastMagicToObj(env,skillid,1)
end

-- 等待状态
function g_ai_cls_combat_fsm:wait(env)
	env:StartupActionWaitTimer()

	while true do
		env:ChaseTarget(0,1)
		if env:IsBreak() == true then		
			break
		end
		env:Sleep(500)
		if env:IsBreak() == true then	
			break
		end
	end

	env:CleanupActionWaitTimer()
end

-- 返回领地状态
function g_ai_cls_combat_fsm:back(env)
	env:Back()
	env:Switch("idle")
end
