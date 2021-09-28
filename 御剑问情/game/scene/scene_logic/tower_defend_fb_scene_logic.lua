TowerDefendFbSceneLogic = TowerDefendFbSceneLogic or BaseClass(BaseFbLogic)

function TowerDefendFbSceneLogic:__init()

end

function TowerDefendFbSceneLogic:__delete()

end

function TowerDefendFbSceneLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(false)
	ViewManager.Instance:Open(ViewName.FuBenGuardInfoView)
	FuBenData.Instance:SetTowerIsWarning(false)
end

function TowerDefendFbSceneLogic:Update(now_time, elapse_time)
	BaseFbLogic.Update(self, now_time, elapse_time)
end

function TowerDefendFbSceneLogic:Out()
	BaseFbLogic.Out(self)
	GuajiCtrl.Instance:StopGuaji()
	ViewManager.Instance:Close(ViewName.FuBenGuardInfoView)
end

function TowerDefendFbSceneLogic:DelayOut(old_scene_type, new_scene_type)
	BaseFbLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
end

function TowerDefendFbSceneLogic:GetGuajiPos()
	local pos = FuBenData.Instance:GetTowerGuajiPos(1)
	return pos.x, pos.y
end

function TowerDefendFbSceneLogic:GetSpecialGuajiPos()
	local function start_call_back()
		FuBenData.Instance:SetTowerIsWarning(false)
	end
	if FuBenData.Instance:GetTowerIsWarning() then
		local pos_x, pos_y = self:GetGuajiPos()
		return pos_x, pos_y, start_call_back
	end
	return nil, nil, nil
end