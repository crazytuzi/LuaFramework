YiZhanDaoDiSceneLogic = YiZhanDaoDiSceneLogic or BaseClass(BaseFbLogic)

function YiZhanDaoDiSceneLogic:__init()
	self.is_show_auto_effect = true
	self.main_ui_auto_change = GlobalEventSystem:Bind(MainUIEventType.CLICK_AUTO_BUTTON, BindTool.Bind(self.OnAutoChange, self))
end

function YiZhanDaoDiSceneLogic:__delete()
	if self.main_ui_auto_change then
		GlobalEventSystem:UnBind(self.main_ui_auto_change)
		self.main_ui_auto_change = nil
	end
end

function YiZhanDaoDiSceneLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(false)
	ViewManager.Instance:Open(ViewName.YiZhanDaoDiView)

	MainUICtrl.Instance:FlushView("auto_effect")
end

function YiZhanDaoDiSceneLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.YiZhanDaoDiView)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)

	self.is_show_auto_effect = false
	MainUICtrl.Instance:FlushView("auto_effect")
end

function YiZhanDaoDiSceneLogic:OnAutoChange()
	if not self.is_show_auto_effect then return end

	self.is_show_auto_effect = false
	MainUICtrl.Instance:FlushView("auto_effect")
end

function YiZhanDaoDiSceneLogic:DelayOut(old_scene_type, new_scene_type)
	CrossServerSceneLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
	GlobalEventSystem:Fire(ObjectEventType.FIGHT_EFFECT_CHANGE)
end

function YiZhanDaoDiSceneLogic:IsRoleEnemy()
	return true
end