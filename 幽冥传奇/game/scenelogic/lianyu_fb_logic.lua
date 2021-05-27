LianYuFubenLogic = LianYuFubenLogic or BaseClass(BaseFbLogic)

function LianYuFubenLogic:__init()
end

function LianYuFubenLogic:__delete()
end

function LianYuFubenLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	ViewManager.Instance:OpenViewByDef(ViewDef.LianyuGuide)
	ViewManager.Instance:CloseViewByDef(ViewDef.Dungeon)
	-- ViewManager.Instance:CloseViewByDef(ViewDef.Experiment)
end

function LianYuFubenLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:CloseViewByDef(ViewDef.LianyuGuide)
	if FubenData.Instance:GetRewardCanGet() > 0 then
		ViewManager.Instance:OpenViewByDef(ViewDef.LianyuReward)
	end
end