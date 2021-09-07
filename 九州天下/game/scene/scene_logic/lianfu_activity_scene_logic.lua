LianFuActivitySceneLogic = LianFuActivitySceneLogic or BaseClass(CrossServerSceneLogic)

function LianFuActivitySceneLogic:__init()
	
end

function LianFuActivitySceneLogic:__delete()
	
end

function LianFuActivitySceneLogic:Enter(old_scene_type, new_scene_type)
	CrossServerSceneLogic.Enter(self, old_scene_type, new_scene_type)
	ViewManager.Instance:CloseAll()
	ViewManager.Instance:Open(ViewName.LianFuDailyView)

	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	local scene_id = Scene.Instance:GetSceneId()
	if role_vo and role_vo.server_group and scene_id then
		local server_group = role_vo.server_group == 0 and 1 or 0
		local cfg = LianFuDailyData.Instance:GetXYCityGroupCfg(server_group)
		if cfg and cfg.scene_id and cfg.scene_id == scene_id then
			ViewManager.Instance:Open(ViewName.LianFuMiDaoBossView)
		end
	end
	MainUICtrl.Instance.view:SetViewState(false)
end

function LianFuActivitySceneLogic:Out(old_scene_type, new_scene_type)
	CrossServerSceneLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:CloseAll()
	ViewManager.Instance:Close(ViewName.LianFuDailyView)
	ViewManager.Instance:Close(ViewName.LianFuMiDaoBossView)
end

function LianFuActivitySceneLogic:DelayOut(old_scene_type, new_scene_type)
	CrossServerSceneLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
end

function LianFuActivitySceneLogic:IsRoleEnemy(target_obj, main_role)
	return main_role.vo.server_group ~= target_obj.vo.server_group
end

function LianFuActivitySceneLogic:ChangeCampName()
	return true
end