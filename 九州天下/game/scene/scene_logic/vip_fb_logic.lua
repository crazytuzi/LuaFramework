VipFbLogic = VipFbLogic or BaseClass(BaseFbLogic)

function VipFbLogic:__init()
	self.story = nil
end

function VipFbLogic:__delete()
	if nil ~= self.story then
		self.story:DeleteMe()
		self.story = nil
	end
end

function VipFbLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Open(ViewName.FuBenVipInfoView)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
	-- local fb_cfg = Scene.Instance:GetCurFbSceneCfg()
	-- if fb_cfg ~= nil and fb_cfg.fb_desc ~= nil and fb_cfg.fb_desc ~= "" and PlayerData.Instance.role_vo.level < 50 then
	-- 	DescTip.Instance:Open()
	-- 	DescTip.Instance:SetTitle(Language.Dungeon.HowToPlay)
	-- 	DescTip.Instance:SetContent(fb_cfg.fb_desc)
	-- end
	self.story = XinShouStorys.New(Scene.Instance:GetSceneId())
end

-- 是否可以拉取移动对象信息
function VipFbLogic:CanGetMoveObj()
	return true
end

-- 是否可以屏蔽怪物
-- function VipFbLogic:CanShieldMonster()
-- 	return false
-- end

-- 是否自动设置挂机
function VipFbLogic:IsSetAutoGuaji()
	return true
end

function VipFbLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.FuBenVipInfoView)
	if ViewManager.Instance:IsOpen(ViewName.FBVictoryFinishView) then
		ViewManager.Instance:Close(ViewName.FBVictoryFinishView)
	end

	local fb_scene_info = FuBenData.Instance:GetFBSceneLogicInfo()
	if ViewManager.Instance:IsOpen(ViewName.FBFailFinishView) then
		GlobalEventSystem:Fire(OtherEventType.CLOSE_FUBEN_FAIL_VIEW)
		-- ViewManager.Instance:Close(ViewName.FBFailFinishView)
	else
		if fb_scene_info and fb_scene_info.is_pass == 1 then
			ViewManager.Instance:Open(ViewName.FuBen, TabIndex.fb_vip)
		end
	end
	UnityEngine.PlayerPrefs.DeleteKey("vipindex")
	GuajiCtrl.Instance:StopGuaji()

	FuBenData.Instance:ClearFBSceneLogicInfo()
end

function VipFbLogic:DelayOut(old_scene_type, new_scene_type)
	BaseFbLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
end
