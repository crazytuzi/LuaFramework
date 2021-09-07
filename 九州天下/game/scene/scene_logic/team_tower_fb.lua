TeamTowerSceneLogic = TeamTowerSceneLogic or BaseClass(BaseFbLogic)

function TeamTowerSceneLogic:__init()
end

function TeamTowerSceneLogic:__delete()

end

function TeamTowerSceneLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(false)
	ViewManager.Instance:Open(ViewName.TeamFuBenInfoView)
	ViewManager.Instance:Close(ViewName.TipsEnterFbView)
	ViewManager.Instance:Close(ViewName.FuBen)
	ViewManager.Instance:Open(ViewName.TowerSkillView)
	TeamFbData.Instance:ClearTeamTowerDefendAttrType()
	FuBenData.Instance:SetTowerIsWarning(false)
	
	if ViewManager.Instance:IsOpen(ViewName.FBVictoryFinishView) then
		ViewManager.Instance:Close(ViewName.FBVictoryFinishView)
	end
end

function TeamTowerSceneLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
	ViewManager.Instance:Close(ViewName.TeamFuBenInfoView)
	ViewManager.Instance:Close(ViewName.TowerSkillView)
end

-- 获得捡取掉物品的最大距离
function TeamTowerSceneLogic:GetPickItemMaxDic(item_id)
	return 0
end

function TeamTowerSceneLogic:IsRoleEnemy()
	return false
end

function TeamTowerSceneLogic:GetGuajiPos()
	local pos_x, pos_y = TeamFbData.Instance:GetGuaJiPos()
	return pos_x, pos_y
end

function TeamTowerSceneLogic:GetSpecialGuajiPos()
	local function start_call_back()
		FuBenData.Instance:SetTowerIsWarning(false)
	end
	if FuBenData.Instance:GetTowerIsWarning() then
		local pos_x, pos_y = self:GetGuajiPos()
		return pos_x, pos_y, start_call_back
	end
	return nil, nil, nil
end