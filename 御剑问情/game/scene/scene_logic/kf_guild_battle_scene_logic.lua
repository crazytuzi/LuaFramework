KfGuildBattleSceneLogic = KfGuildBattleSceneLogic or BaseClass(CrossServerSceneLogic)

function KfGuildBattleSceneLogic:__init()
	self.open_view = false
end

function KfGuildBattleSceneLogic:__delete()

end

function KfGuildBattleSceneLogic:Enter(old_scene_type, new_scene_type)
	CrossServerSceneLogic.Enter(self, old_scene_type, new_scene_type)
	KuafuGuildBattleCtrl.Instance:OpenScenePanle()
	KuafuGuildBattleCtrl.Instance:OpenRankPanle()
	MainUICtrl.Instance:SetViewState(false)
end

function KfGuildBattleSceneLogic:Update(now_time, elapse_time)
	BaseFbLogic.Update(self, now_time, elapse_time)

end

function KfGuildBattleSceneLogic:Out(old_scene_type, new_scene_type)
	CrossServerSceneLogic.Out(self, old_scene_type, new_scene_type)
	KuafuGuildBattleCtrl.Instance:CloseScenePanle()
	KuafuGuildBattleCtrl.Instance:CloseRankPanle()
	MainUICtrl.Instance:SetViewState(true)
end


-- 怪物是否是敌人
function KfGuildBattleSceneLogic:IsMonsterEnemy(target_obj, main_role)
	if target_obj and target_obj:GetVo() then
		local monster_id = target_obj:GetVo().monster_id or 0
		local my_guild_name = main_role:GetVo().guild_name or " "
		local flag_list = KuafuGuildBattleData.Instance:GetRankInfo().flag_list or {}
		for k,v in pairs(flag_list) do
			if monster_id == v.monster_id and my_guild_name == v.guild_name then
				return false
			end
		end
	end
	return true
end

function KfGuildBattleSceneLogic:IsRoleEnemy(target_obj, main_role)
	if main_role:GetVo().guild_id == target_obj:GetVo().guild_id then			-- 同一边
		return false, Language.Fight.Side
	end
	return true
end