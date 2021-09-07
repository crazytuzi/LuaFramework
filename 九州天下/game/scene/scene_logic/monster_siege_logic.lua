MonsterSiegeFbLogic = MonsterSiegeFbLogic or BaseClass(BaseFbLogic)

function MonsterSiegeFbLogic:__init()

end

function MonsterSiegeFbLogic:__delete()

end

function MonsterSiegeFbLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Open(ViewName.MonsterSiegeInfoView)
	MainUICtrl.Instance:SetViewState(false)
	--GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
	FuBenCtrl.Instance:CloseView()
	CampCtrl.Instance:CloseView()
	ActivityCtrl.Instance:CloseDetailView()
	MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_CAMP)
end

-- 是否可以拉取移动对象信息
function MonsterSiegeFbLogic:CanGetMoveObj()
	return false
end

-- 是否可以屏蔽怪物
function MonsterSiegeFbLogic:CanShieldMonster()
	return false
end

-- 是否自动设置挂机
function MonsterSiegeFbLogic:IsSetAutoGuaji()
	return true
end

function MonsterSiegeFbLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	GuajiCtrl.Instance:StopGuaji()
	FuBenData.Instance:ClearFBSceneLogicInfo()
	CampCtrl.Instance:CloseMonsterSiegeInfo()
	MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_PEACE)
end

function MonsterSiegeFbLogic:DelayOut(old_scene_type, new_scene_type)
	BaseFbLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
end
