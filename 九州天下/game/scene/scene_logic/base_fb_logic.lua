-------------------------------------------
--基础副本逻辑,统一处理一些副本活动类通用的逻辑
--@author bzw
--------------------------------------------
BaseFbLogic = BaseFbLogic or BaseClass(BaseSceneLogic)
function BaseFbLogic:__init()

end

function BaseFbLogic:__delete()

end

function BaseFbLogic:Enter(old_scene_type, new_scene_type)
	BaseSceneLogic.Enter(self, old_scene_type, new_scene_type)
	local fb_cfg = Scene.Instance:GetCurFbSceneCfg()
	ViewManager.Instance:Close(ViewName.TaskDialog)
end

--退出
function BaseFbLogic:Out(old_scene_type, new_scene_type)
	BaseSceneLogic.Out(self, old_scene_type, new_scene_type)
	GuajiCtrl.Instance:StopGuaji()
end

function BaseFbLogic:GetMoveObjAllInfoFrequency()
	return 3
end

--获得场景显标的副本图标列表
function BaseSceneLogic:GetFbSceneShowFbIconCfgList()

end

function BaseFbLogic:OnClickHeadHandler(is_show)
	-- override
end

function BaseFbLogic:IsShowVictoryView()
	return false
end