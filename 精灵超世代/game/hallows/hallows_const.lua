-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      圣器系统的一些常量配置
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
HallowsConst = HallowsConst or {}

--[[HallowsConst.red_type = {
	advance = 1,
	rewards = 2,
	trace = 3,
	skill = 4,
	equip = 5
}--]]

HallowsConst.Tab_Index = {
	uplv = 1,  -- 升级
	skill = 2, -- 技能
	refine = 3,-- 精炼
}

-- 神器开启状态
HallowsConst.Status = {
	close = 1, 		-- 未开启
	underway = 2, 	-- 进行中
	open = 3 		-- 已获得
}

-- 神器红点类型
HallowsConst.Red_Index = {
	task_award = 1,   -- 神器任务奖励可领
	hallows_lvup = 2, -- 神器可升级
	skill_lvup = 3,   -- 神器技能可升级
	stone_use = 4, 	  -- 有圣印石可使用
	magic_task = 5,   -- 幻化任务奖励可领
	refine_lvup = 6,  -- 精炼升级
}

-- 神器幻化界面状态
HallowsConst.Magic_View_Status = {
	Task = 1,  -- 任务解锁中
	Item = 2,  -- 道具解锁中
	Open = 3,  -- 已幻化
}

-- 神器幻化状态
HallowsConst.Magic_status = {
	Have = 1,    -- 已获得
	CanHave = 2, -- 可获得
	Lock = 3, 	 -- 暂不可获得
}

-- 神器激活类型
HallowsConst.Activity_Type = {
	Hallows = 1,  -- 神器激活
	Magic = 2,    -- 幻化激活
}