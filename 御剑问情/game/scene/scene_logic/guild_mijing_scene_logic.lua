GuildMiJingSceneLogic = GuildMiJingSceneLogic or BaseClass(CommonActivityLogic)

function GuildMiJingSceneLogic:__init()
end

function GuildMiJingSceneLogic:__delete()

end

function GuildMiJingSceneLogic:Enter(old_scene_type, new_scene_type)
	CommonActivityLogic.Enter(self, old_scene_type, new_scene_type)
	-- ViewManager.Instance:Open(ViewName.GuildMijingFightView)
	ViewManager.Instance:Close(ViewName.Guild)
	GlobalTimerQuest:AddDelayTimer(function()
		GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false)
		end, 0.1)
end

function GuildMiJingSceneLogic:Out(old_scene_type, new_scene_type)
	CommonActivityLogic.Out(self, old_scene_type, new_scene_type)
	-- ViewManager.Instance:Close(ViewName.GuildMijingFightView)
end

function GuildMiJingSceneLogic:CanGetMoveObj()
	return true
end

function GuildMiJingSceneLogic:GetMoveObjAllInfoFrequency()
	return 3
end

function GuildMiJingSceneLogic:IsRoleEnemy(target_obj, main_role)
	return false
end