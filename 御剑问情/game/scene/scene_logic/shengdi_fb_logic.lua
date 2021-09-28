ShengDiFbLogic = ShengDiFbLogic or BaseClass(BaseFbLogic)

function ShengDiFbLogic:__init()
	-- 监听系统事件
	self.guaji_change = GlobalEventSystem:Bind(OtherEventType.GUAJI_TYPE_CHANGE,
		BindTool.Bind(self.OnGuajiTypeChange, self))
end

function ShengDiFbLogic:__delete()
	if self.guaji_change then
		GlobalEventSystem:UnBind(self.guaji_change)
		self.guaji_change = nil
	end
end

function ShengDiFbLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.Marriage)
	MainUICtrl.Instance:SetViewState(false)
	ViewManager.Instance:Open(ViewName.FuBenShengDiInfoView)
end

function ShengDiFbLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.FuBenShengDiInfoView)
	ViewManager.Instance:CloseAll()
	MainUICtrl.Instance:SetViewState(true)
end

function ShengDiFbLogic:CanGetMoveObj()
	return true
end

function ShengDiFbLogic:GetMoveObjAllInfoFrequency()
	return 3
end

function ShengDiFbLogic:OnGuajiTypeChange(guaji_type)
	if nil ~= ShengDiFuBenAutoGatherEvent.func and guaji_type == GuajiType.Auto then
		ShengDiFuBenAutoGatherEvent.func()
	end
end

function ShengDiFbLogic:IsRoleEnemy()
	return false
end