TowerFbLogic = TowerFbLogic or BaseClass(BaseFbLogic)

function TowerFbLogic:__init()

end

function TowerFbLogic:__delete()

end

function TowerFbLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Open(ViewName.FuBenTowerInfoView)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
	local fb_cfg = Scene.Instance:GetCurFbSceneCfg()
	-- if fb_cfg ~= nil and fb_cfg.fb_desc ~= nil and fb_cfg.fb_desc ~= "" and PlayerData.Instance.role_vo.level < 50 then
	-- 	DescTip.Instance:Open()
	-- 	DescTip.Instance:SetTitle(Language.Dungeon.HowToPlay)
	-- 	DescTip.Instance:SetContent(fb_cfg.fb_desc)
	-- end
end

-- 是否可以拉取移动对象信息
function TowerFbLogic:CanGetMoveObj()
	return true
end

-- 是否可以屏蔽怪物
function TowerFbLogic:CanShieldMonster()
	return false
end

-- 是否自动设置挂机
function TowerFbLogic:IsSetAutoGuaji()
	return true
end

function TowerFbLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.FuBenTowerInfoView)
	if ViewManager.Instance:IsOpen(ViewName.FBVictoryFinishView) then
		ViewManager.Instance:Close(ViewName.FBVictoryFinishView)
	end
	if ViewManager.Instance:IsOpen(ViewName.FBFailFinishView) then
		GlobalEventSystem:Fire(OtherEventType.CLOSE_FUBEN_FAIL_VIEW)
		-- ViewManager.Instance:Close(ViewName.FBFailFinishView)
	end
	if ViewManager.Instance:IsOpen(ViewName.CommonTips) then
		ViewManager.Instance:Close(ViewName.CommonTips)
	end
	GuajiCtrl.Instance:StopGuaji()

	FuBenData.Instance:ClearFBSceneLogicInfo()
end

function TowerFbLogic:DelayOut(old_scene_type, new_scene_type)
	BaseFbLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
end