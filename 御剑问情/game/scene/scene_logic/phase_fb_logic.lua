PhaseFbLogic = PhaseFbLogic or BaseClass(BaseFbLogic)

function PhaseFbLogic:__init()
	self.story = nil
end

function PhaseFbLogic:__delete()
	if nil ~= self.story then
		self.story:DeleteMe()
		self.story = nil
	end
end

function PhaseFbLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Open(ViewName.FuBenPhaseInfoView)
	self.story = XinShouStorys.New(Scene.Instance:GetSceneId())
end

-- 是否可以拉取移动对象信息
function PhaseFbLogic:CanGetMoveObj()
	return true
end

function PhaseFbLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.FuBenPhaseInfoView)

	GuajiCtrl.Instance:StopGuaji()

	if ViewManager.Instance:IsOpen(ViewName.FBVictoryFinishView) then
		ViewManager.Instance:Close(ViewName.FBVictoryFinishView)
	end
	if ViewManager.Instance:IsOpen(ViewName.Exchange) then
		ViewManager.Instance:Close(ViewName.Exchange)
	end
	local fb_scene_info = FuBenData.Instance:GetFBSceneLogicInfo()
	if not ViewManager.Instance:IsOpen(ViewName.FBFailFinishView) then
		if fb_scene_info and fb_scene_info.is_pass == 1 and PlayerData.Instance:GetRoleVo().level >= 131 then
			ViewManager.Instance:Open(ViewName.FuBen, TabIndex.fb_phase)
		end
	else
		GlobalEventSystem:Fire(OtherEventType.CLOSE_FUBEN_FAIL_VIEW)
		-- ViewManager.Instance:Close(ViewName.FBFailFinishView)
	end
	UnityEngine.PlayerPrefs.DeleteKey("phaseindex")
	FuBenData.Instance:ClearFBSceneLogicInfo()
end

function PhaseFbLogic:DelayOut(old_scene_type, new_scene_type)
	BaseFbLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
end

function PhaseFbLogic:CanShieldMonster()
	return false
end

-- 是否自动设置挂机
function PhaseFbLogic:IsSetAutoGuaji()
	return true
end