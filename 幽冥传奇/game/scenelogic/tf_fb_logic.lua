TafangFbLogic = TafangFbLogic or BaseClass(FbSceneLogic)

function TafangFbLogic:__init()
	self.auto_place_pos_t = {}
	self.guide_t = {}
end

function TafangFbLogic:__delete()
end

function TafangFbLogic:Enter(old_scene_type, new_scene_type)
	FbSceneLogic.Enter(self, old_scene_type, new_scene_type)

	self.auto_place_pos_t = TableCopy(TafangFubenCfg.placePosT)
	self.guide_t = TableCopy(TafangFubenCfg.guide)

	ViewManager.Instance:FlushView(ViewDef.MainUi, 0, "passive_change_iconbar", {is_show = true})
	ViewManager.Instance:FlushView(ViewDef.MainUi, 0, "skillbar_visible", {visible = false})
	FubenCtrl.Instance:OpenTfOptView()
end

function TafangFbLogic:Out()
	FbSceneLogic.Out(self)
	
	self.auto_place_pos_t = {}
	self.guide_t = {}

	ViewManager.Instance:FlushView(ViewDef.MainUi, 0, "passive_change_iconbar", {is_show = false})
	ViewManager.Instance:FlushView(ViewDef.MainUi, 0, "skillbar_visible", {visible = true})
	FubenCtrl.Instance:CloseTfOptView()
end

function TafangFbLogic:GetAutoPlacePosT()
	return self.auto_place_pos_t
end

function TafangFbLogic:GetGuideT()
	return self.guide_t
end
