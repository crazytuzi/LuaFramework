-- 副本逻辑
FbSceneLogic = FbSceneLogic or BaseClass(BaseFbLogic)

function FbSceneLogic:__init()
end

function FbSceneLogic:__delete()
end

function FbSceneLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)

	if FubenType.Hhjd2 == self:GetFubenType() then
		FubenData.Instance:SetHhjd2FbInfo()
	end

	ViewManager.Instance:CloseAllView()
	FubenCtrl.Instance:SetTaskFollow()
	FubenCtrl.GetFubenEnterInfo()			-- 副本进入次数刷新
	-- ViewManager.Instance:FlushView(ViewDef.MainUi, 0, "act_skillbar_auto_fight_effect")

	if FubenData.FB_GUIDE_SHOW_TYPE[self:GetFubenType()] then
		GlobalEventSystem:Fire(MainUIEventType.TASK_SHOW_TYPE_CHANGE, FubenData.FB_GUIDE_SHOW_TYPE[self:GetFubenType()]["enter"])
	end
	RemindManager.Instance:DoRemind(RemindName.DailyActivity)
end

function FbSceneLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	-- ViewManager.Instance:FlushView(ViewDef.MainUi, 0, "cancel_skillbar_auto_fight_effect")

	-- 判断当前的导航是否于副本导航中,如果不已经不是副本导航则跳过
	-- local cur_task_guide_name = MainuiCtrl.Instance:GetTaskGuideName()
	-- if nil ~= MainuiTask.GUIDE_NAME_TYPE[cur_task_guide_name] and 1 == MainuiTask.GUIDE_NAME_TYPE[cur_task_guide_name] then
	-- 	FubenCtrl.Instance:CloseTaskFollow()
	-- 	if FubenData.FB_GUIDE_SHOW_TYPE[self:GetFubenType()] then
	-- 		GlobalEventSystem:Fire(MainUIEventType.TASK_SHOW_TYPE_CHANGE, FubenData.FB_GUIDE_SHOW_TYPE[self:GetFubenType()]["out"])
	-- 	else
	-- 		GlobalEventSystem:Fire(MainUIEventType.TASK_SHOW_TYPE_CHANGE, MainuiTask.SHOW_TYPE.LEFT)
	-- 	end
	-- end

	-- if FubenType.Tafang == self:GetFubenType() then
	-- 	FubenCtrl.Instance:CloseTfResultView()
	-- end

	self:SetFubenType(0)
	RemindManager.Instance:DoRemind(RemindName.DailyActivity)
end

function FbSceneLogic:AutoMoveFight()
	if FubenType.Hhjd == self:GetFubenType() or FubenType.Hhjd2 == self:GetFubenType() then
		-- 行会禁地自动打怪、对话
		Scene.Instance:GetMainRole():StopMove()
		local monster_info = FubenData.Instance:GetHhjdCurMonsterInfo()
		if monster_info then
			MoveCache.param1 = 0
			MoveCache.end_type = MoveEndType.FightByMonsterId
			GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), monster_info.x, monster_info.y, 1)
		else
			local next_scene_cfg = GuildForbiddenAreaNpcCfg
			MoveCache.param1 = next_scene_cfg.NpcId
			MoveCache.end_type = MoveEndType.NpcTask
			GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), next_scene_cfg.npcPos.x, next_scene_cfg.npcPos.y, 1)
		end
	end
end
