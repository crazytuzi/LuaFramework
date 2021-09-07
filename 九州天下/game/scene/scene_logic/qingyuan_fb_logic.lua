QingYuanFbLogic = QingYuanFbLogic or BaseClass(BaseFbLogic)

function QingYuanFbLogic:__init()

end

function QingYuanFbLogic:__delete()

end

function QingYuanFbLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_PEACE)
	ViewManager.Instance:Close(ViewName.Marriage)
	MainUICtrl.Instance:SetViewState(false)
	ViewManager.Instance:Open(ViewName.FuBenQingYuanInfoView)
end

function QingYuanFbLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.FuBenQingYuanInfoView)
	ViewManager.Instance:CloseAll()
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
end

function QingYuanFbLogic:DelayOut(old_scene_type, new_scene_type)
	BaseFbLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
end

-- 是否可以拉取移动对象信息
function QingYuanFbLogic:CanGetMoveObj()
	return true
end
-- 是否自动设置挂机
function QingYuanFbLogic:IsSetAutoGuaji()
	return true
end
-- 拉取移动对象信息间隔
function QingYuanFbLogic:GetMoveObjAllInfoFrequency()
	return 2
end