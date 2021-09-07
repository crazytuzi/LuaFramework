require("game/scene/optimize/base_shield_optimize")
require("game/scene/optimize/role_shield_optimize")
require("game/scene/optimize/monster_shield_optimize")
require("game/scene/optimize/goddess_shield_optimize")
require("game/scene/optimize/sprite_shield_optimize")
require("game/scene/optimize/skilleffect_shield_optimize")

SceneOptimize = SceneOptimize or BaseClass()

function SceneOptimize:__init()
	if SceneOptimize.Instance then
		print_error("[SceneOptimize] Attempt to create singleton twice!")
		return
	end
	SceneOptimize.Instance = self

	self.optimize_list = {
		RoleShieldOptimize.New(),
		MonsterShieldOptimize.New(),
		GoddessShieldOptimize.New(),
		SpiriteShieldOptimize.New(),
		SkillEffectShieldOptimize.New(),
	}

	self.fps_sampe_result = GlobalEventSystem:Bind(OtherEventType.FPS_SAMPLE_RESULT, BindTool.Bind(self.OnFpsSampleCallback, self))
end

function SceneOptimize:__delete()
	GlobalEventSystem:UnBind(self.fps_sampe_result)

	SceneOptimize.Instance = nil
end

function SceneOptimize:OnFpsSampleCallback(fps)
	for k, v in pairs(self.optimize_list) do
		GlobalTimerQuest:AddDelayTimer(function ()
			v:OnFpsSampleCallback(fps)
		end, k * 0.001)
	end
end

