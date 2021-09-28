--[[动作响应管理器
	结束触发 0.9
	运行中触发 0.1--0.9
	这里触发的接口对应于 动作导出配置[_FBX/ActionCfg.csv]中的接口名，命名规则：小字母开头,驼峰式写法
]]
MotionMgr = {}
local this = MotionMgr
function MotionMgr.Init()
	this.ResetAtk() -- 初始化或者在打完动作后重置
end

-- 普攻连招处理
	function MotionMgr.ResetAtk()
		this.checkAtk = false -- 使用于在检测点时，是否触发下个普通连招
		this.atk2Open=false
		this.atk3Open=false
		this.atk4Open=false
		this.atk5Open=false
	end
	function MotionMgr.SetCheckAtk( bool ) -- 到达检测是否下一连招的设置开启检测
		this.checkAtk = bool
	end
	function MotionMgr.OpenAtk2() -- 2连
		if this.checkAtk then
			this.atk2Open=true
		end
	end
	function MotionMgr.OpenAtk3() -- 3连
		if this.checkAtk then
			this.atk3Open=true
		end
	end
	function MotionMgr.OpenAtk4() -- 4连
		if this.checkAtk then
			this.atk4Open=true
		end
	end
	function MotionMgr.OpenAtk5() -- 5连
		if this.checkAtk then
			this.atk5Open=true
		end
	end

function MotionMgr.onActionEnd(luaObject, transform, action)
	this.ResetAtk()

	print("--动作结束-->>OnActionEnd", action, luaObject, transform.name)

end
