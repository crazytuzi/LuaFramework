BabelFubenLogic = BabelFubenLogic or BaseClass(BaseFbLogic)

function BabelFubenLogic:__init()
end

function BabelFubenLogic:__delete()
end

function BabelFubenLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	ViewManager.Instance:OpenViewByDef(ViewDef.BabelInfo)
	
	ViewManager.Instance:CloseViewByDef(ViewDef.Experiment)
end

function BabelFubenLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:CloseViewByDef(ViewDef.BabelInfo)
	-- if FubenData.Instance:GetCurFightLevel() > 0 then
	-- 	ViewManager.Instance:OpenViewByDef(ViewDef.ShowRewardExp)
	-- end
end