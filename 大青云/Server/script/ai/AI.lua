----------------------------------------------------------
-- AI脚本框架
----------------------------------------------------------

g_ai = {}
g_ai[1] = g_ai_cls_combat

g_ai_envs = {}
g_ai_env = {}

-- ******************************************************
-- AI环境
-- ******************************************************
-- 初始化
function g_ai_env:Initial(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end

-- 休息（单位ms）
function g_ai_env:Sleep(time)
	_AISleep(self.owner,time)
end

-- 切换状态
function g_ai_env:Switch(state)
    if self.ai_state == state then
        return
    end
	self.ai_state = state
end

-- 打断正在执行的操作
function g_ai_env:Break()
	self.ai_break = true
	_AIBreak(self.owner,0,0)
end

-- 测试当前状态的执行流程是否被打断
function g_ai_env:IsBreak()
	return self.ai_break
end

-- AI退出
function g_ai_env:Exit()
	self.ai_break = true
	self.ai_exit = true
end

-- 移动到某点
function g_ai_env:MoveToPos(pos,speed)
	return _AIMoveToPos(self.owner,pos,speed)
end

-- 移动到目标处
function g_ai_env:MoveToTarget(radius)
	return _AIMoveToTarget(self.owner,radius)
end

-- 移动到施法位置
function g_ai_env:MoveToCastPos(speedrate)
	return _AIMoveToCastPos(self.owner,speedrate)
end

-- 追击到施法目标
function g_ai_env:ChaseTarget(skill,speedrate)
	return _AIChaseTarget(self.owner,skill,speedrate)
end

-- 使用技能
function g_ai_env:CastMagic(skill,flags)
	return _AICastMagic(self.owner,skill,flags)
end

-- 锁定当前目标
function g_ai_env:LockTarget()
    return _AILockTarget(self.owner)
end

-- 解锁当前目标
function g_ai_env:UnlockTarget()
    return _AIUnlockTarget(self.owner)
end

-- 返回领地
function g_ai_env:Back()
	return _AIBack(self.owner)
end

function g_ai_env:StartupActionTimer()
	return _AIStartupActionTimer(self.owner)
end

function g_ai_env:CleanupActionTimer()
	return _AICleanupActionTimer(self.owner)
end

function g_ai_env:StartupActionWaitTimer()
	return _AIStartupActionWaitTimer(self.owner)
end

function g_ai_env:CleanupActionWaitTimer()
	return _AICleanupActionWaitTimer(self.owner)
end

function g_ai_env:IsOverlap(dist)
	return _AIIsOverlap(self.owner,dist)
end

function g_ai_env:GetMagicCastDist(skillid)
	return _AIGetMagicCastDist(self.owner,skillid)
end

function g_ai_env:SelectSkillID()
	return _AISelectSkillID(self.owner)
end

function g_ai_env:SelectManuSkillID()
	return _AISelectManuSkillID(self.owner)
end

function g_ai_env:GetCastType()
	return _AIGetCastType(self.owner)
end

function g_ai_env:GetChaseType()
	return _AIGetChaseType(self.owner)
end

function g_ai_env:IsPaused()
	return _AIPaused(self.owner)
end

-- ******************************************************
-- AI接口
-- ******************************************************
function AIInitial(id,ptr,cls)
	if g_ai[cls] == nil then
		return nil
	end
	
	local cfg = 
	{
		owner = ptr,
		owner_id = id,	
		ai_cls = g_ai[cls],
		ai_cid = coroutine.create(AIWrapper),
		ai_break = false,
		ai_exit = false,
		ai_state = "idle",
	}
	local env = g_ai_env:Initial(cfg)
	g_ai_envs[id] = env

	return env.ai_cid
end

function AIStartup(id)
	local env = g_ai_envs[id]
	if env ~= nil then
		coroutine.resume(env.ai_cid,env)
	end
end

function AICleanup(id)
	local env = g_ai_envs[id]
	if env ~= nil then
		env.ai_exit = true
		env.ai_break = true
		coroutine.resume(env.ai_cid,-1,-1)
		g_ai_envs[id] = nil
	end
end

function AIWrapper(env)
	while not env.ai_exit do
		local action = env.ai_cls.state[env.ai_state]

		if env:IsPaused() then
			env:Sleep(100)
		elseif action ~= nil then
			action(env.ai_cls.state,env)
		else
			break
		end

		env.ai_break = false
	end
	env.ai_exit = true
end

function AIExecute(id,name,...)
	local env = g_ai_envs[id]
	if env == nil then
		return 
	end
	local action = env.ai_cls.event[name]
	if action ~= nil then
		action(env.ai_cls.event,env,...)
	end
end
