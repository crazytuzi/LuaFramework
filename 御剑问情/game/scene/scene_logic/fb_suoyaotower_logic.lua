SuoYaoTowerLogic = SuoYaoTowerLogic or BaseClass(BaseFbLogic)

function SuoYaoTowerLogic:__init()

end

function SuoYaoTowerLogic:__delete()

end

function SuoYaoTowerLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Open(ViewName.SuoYaoTowerFightView)
	MainUICtrl.Instance:SetViewState(false)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
	LianhunCtrl.Instance:CloseView()
end

-- 是否可以拉取移动对象信息
function SuoYaoTowerLogic:CanGetMoveObj()
	return true
end

-- 是否可以屏蔽怪物
function SuoYaoTowerLogic:CanShieldMonster()
	return false
end

-- 是否自动设置挂机
function SuoYaoTowerLogic:IsSetAutoGuaji()
	return true
end

function SuoYaoTowerLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.SuoYaoTowerFightView)
	FuBenData.Instance:ClearFBSceneLogicInfo()
	GuajiCtrl.Instance:StopGuaji()
end

function SuoYaoTowerLogic:DelayOut(old_scene_type, new_scene_type)
	BaseFbLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
	ViewManager.Instance:Open(ViewName.LianhunView, TabIndex.suoyao_tower)
end
