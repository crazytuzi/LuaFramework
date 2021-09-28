require( "Common/RenderMgr" )
require( "Common/EffectMgr" )
-- require( "Common/MotionMgr" )
-- require( "Common/SoulMgr" )

BehaviourMgr = {}
local this=BehaviourMgr
function BehaviourMgr.Init()
	if this.isInited then return end
	this.isInited = true -- 设置为初始化过的
	this.lockAction = true -- 锁定动作(对一些动作时段时行触发锁定)【如果是主角可以要锁定一些操作UI等等】
	this.uiMap = {} -- ui 对象中有一个SetLock(bool)接口
	this.ConfigAction()
	this.InitEvent()
	this.ConfigMgr()
end

function BehaviourMgr.ConfigMgr()
	RenderMgr.Init()
	RenderMgr.Start()
	EffectMgr.Init()
	-- MotionMgr.Init()
	-- SoulMgr.Init()
end

-- 动作数据
	function BehaviourMgr.ConfigAction()
		this.actionNameDic = {}
		this.cfg = GetLocalData("Map/SceneCfg/CfgAction") -- 动作名表
		this.actionEmnu = this.cfg.ActionEmnu -- 技能名统称
		this.actionPriority = this.cfg.ActionPriority
		for id,v in pairs(this.actionEmnu) do
			this.actionNameDic[v] = id
		end
		this.loopMap = this.cfg.Loop -- ?
		for id,v in pairs(this.actionEmnu) do
			this.loopMap[v] = this.loopMap[id] == true
		end
	end
	function BehaviourMgr.GetActionName( actId )

		return this.actionEmnu[actId]
	end
	function BehaviourMgr.GetActionId( act )

		return this.actionNameDic[act]
	end
	function BehaviourMgr.GetActionPriority( act )
		local actionId = tonumber( this.GetActionId( tostring(act) ) )
		return this.actionPriority[actionId] or -1
	end
	function BehaviourMgr.GetRoleDefaultNormalSkill( career )
		local vo = this.GetRoleDefaultSkillVo(career)
		return (vo==nil and 0 or vo.normalSkill)
	end
	function BehaviourMgr.GetRoleDefaultSkill( career )
		local vo = this.GetRoleDefaultSkillVo(career)
		return (vo==nil and 0 or vo.skill)
	end
	function BehaviourMgr.GetRoleDefaultSkillVo( career )

		return GetCfgData("newroleDefaultvalue"):Get(career)
	end
	function BehaviourMgr.GetMonsterDefaultSkill( id, state )
		id = tonumber(id)
		local data = GetCfgData("monster"):Get(id)["defaultSkill"..state]
		local defaultSkillId = {}
		for i=1, #data  do
			defaultSkillId[i] = data[i][1]
		end
		return defaultSkillId
	end

	function BehaviourMgr.IsLoop( actIdOrAction )
		if not this.loopMap then return false end
		return this.loopMap[actIdOrAction] == true
	end

-- 初始事件
	function BehaviourMgr.InitEvent()
		
	end

-- 锁定指定UI 注意：ui对象中有 SetLock(bool)接口
	function BehaviourMgr.LockUI(ui, bool)
		if ui and ui.SetLock then
			ui:SetLock(bool)
		end
	end

-- 执行技能
	function BehaviourMgr.DoSkill(key, skillId)
		
	end

