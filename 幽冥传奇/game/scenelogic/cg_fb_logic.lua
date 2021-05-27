-- 闯关副本逻辑
CgFbLogic = CgFbLogic or BaseClass(FbSceneLogic)

function CgFbLogic:__init()
	self.fb_start_level = 0
end

function CgFbLogic:__delete()
end

function CgFbLogic:Enter(old_scene_type, new_scene_type)
	FbSceneLogic.Enter(self, old_scene_type, new_scene_type)

	-- self.fb_start_level = StrenfthFbData.Instance:GetCheckPointCount()
end

function CgFbLogic:Out()
	FbSceneLogic.Out(self)

	FubenCtrl.Instance:OpenStrengthRV()
	UiInstanceMgr.Instance:DelOneCountDownView("tafang_right_top")
	UiInstanceMgr.Instance:DelOneCountDownView("tafang_middle")
end

function CgFbLogic:GetCgStartLevel()
	return self.fb_start_level
end