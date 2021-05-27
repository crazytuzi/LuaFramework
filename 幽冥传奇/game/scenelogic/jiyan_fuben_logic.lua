JIYanFubenLogic = JIYanFubenLogic or BaseClass(BaseFbLogic)

function JIYanFubenLogic:__init()
end

function JIYanFubenLogic:__delete()
end

function JIYanFubenLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	ViewManager.Instance:OpenViewByDef(ViewDef.ShowExpTip)
	ViewManager.Instance:CloseViewByDef(ViewDef.Dungeon)
end

function JIYanFubenLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:CloseViewByDef(ViewDef.ShowExpTip)
	if FubenData.Instance:GetCurFightLevel() > 0 then
		ViewManager.Instance:OpenViewByDef(ViewDef.ShowRewardExp)
	end
end