KfGuildBattleSceneLogic = KfGuildBattleSceneLogic or BaseClass(CrossServerSceneLogic)

function KfGuildBattleSceneLogic:__init()
	self.open_view = false
end

function KfGuildBattleSceneLogic:__delete()

end

function KfGuildBattleSceneLogic:Enter(old_scene_type, new_scene_type)
	CrossServerSceneLogic.Enter(self, old_scene_type, new_scene_type)
	-- ViewManager.Instance:CloseAllView()
	KuafuGuildBattleCtrl.Instance:OpenScenePanle()
	
	if Scene.Instance:GetSceneId() == 3156 then
		ViewManager.Instance:Open(ViewName.LianFuDailyView)
	else
		KuafuGuildBattleCtrl.Instance:OpenRankPanle()
	end

	MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_CAMP)
	MainUICtrl.Instance:SetViewState(false)

	local mian_view = MainUICtrl.Instance:GetView()
	if mian_view.hide_show_view and mian_view.hide_show_view.HideShowKfLiuJie then
		mian_view.hide_show_view:HideShowKfLiuJie(true)
	end
end

function KfGuildBattleSceneLogic:Update(now_time, elapse_time)
	BaseFbLogic.Update(self, now_time, elapse_time)
	
end

function KfGuildBattleSceneLogic:Out(old_scene_type, new_scene_type)
	CrossServerSceneLogic.Out(self, old_scene_type, new_scene_type)
	KuafuGuildBattleCtrl.Instance:CloseScenePanle()
	KuafuGuildBattleCtrl.Instance:CloseRankPanle()
	ViewManager.Instance:Close(ViewName.LianFuDailyView)

	MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_PEACE)
	MainUICtrl.Instance:SetViewState(true)
	GlobalEventSystem:Fire(ObjectEventType.STOP_GATHER, Scene.Instance:GetMainRole():GetObjId())

	local mian_view = MainUICtrl.Instance:GetView()
	if mian_view.hide_show_view and mian_view.hide_show_view.HideShowKfLiuJie then
		mian_view.hide_show_view:HideShowKfLiuJie(false)
	end
end


-- 怪物是否是敌人
function KfGuildBattleSceneLogic:IsMonsterEnemy(target_obj, main_role)
	if target_obj and target_obj:GetVo() then
		local monster_id = target_obj:GetVo().monster_id or 0
		local main_role = GameVoManager.Instance:GetMainRoleVo()
		local flag_list = KuafuGuildBattleData.Instance:GetRankInfo().flag_list or {}
		for k,v in pairs(flag_list) do
			if monster_id == v.monster_id and main_role.origin_merge_server_id == v.server_id and main_role.camp == NAME_TYPE_TO_CAMP[v.guild_name] then
				return false
			end
		end
	end
	return true
end

function KfGuildBattleSceneLogic:IsRoleEnemy(target_obj, main_role)
	if main_role:GetVo().origin_merge_server_id == target_obj:GetVo().origin_merge_server_id and main_role:GetVo().camp == target_obj:GetVo().camp then			-- 同一边
		return false, Language.Fight.Side
	end
	if Scene.Instance:GetSceneId() == 3156 then
		return main_role.vo.server_group ~= target_obj.vo.server_group
	end
	return true
end

function KfGuildBattleSceneLogic:ChangeCampName()
	return true
end