StoryFbLogic = StoryFbLogic or BaseClass(BaseFbLogic)

function StoryFbLogic:__init()

end

function StoryFbLogic:__delete()

end

function StoryFbLogic:Enter(old_scene_type, new_scene_type)
	BaseFbLogic.Enter(self, old_scene_type, new_scene_type)
	-- ViewManager.Instance:Open(ViewName.FuBenStoryInfoView)
	GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
	-- local fb_cfg = Scene.Instance:GetCurFbSceneCfg()
	-- if fb_cfg ~= nil and fb_cfg.fb_desc ~= nil and fb_cfg.fb_desc ~= "" and PlayerData.Instance.role_vo.level < 50 then
	-- 	DescTip.Instance:Open()
	-- 	DescTip.Instance:SetTitle(Language.Dungeon.HowToPlay)
	-- 	DescTip.Instance:SetContent(fb_cfg.fb_desc)
	-- end
end

-- 是否可以拉取移动对象信息
function StoryFbLogic:CanGetMoveObj()
	return true
end

-- 是否可以屏蔽怪物
function StoryFbLogic:CanShieldMonster()
	return false
end

-- 是否自动设置挂机
function StoryFbLogic:IsSetAutoGuaji()
	return true
end

function StoryFbLogic:Out(old_scene_type, new_scene_type)
	BaseFbLogic.Out(self, old_scene_type, new_scene_type)
	-- ViewManager.Instance:Close(ViewName.FuBenStoryInfoView)
	if ViewManager.Instance:IsOpen(ViewName.FBVictoryFinishView) then
		ViewManager.Instance:Close(ViewName.FBVictoryFinishView)
	end

	local fb_scene_info = FuBenData.Instance:GetFBSceneLogicInfo()

	if not ViewManager.Instance:IsOpen(ViewName.FBFailFinishView) then
		if fb_scene_info and fb_scene_info.is_pass == 1 then
			ViewManager.Instance:Open(ViewName.FuBen, TabIndex.fb_story)
		end
	else
		GlobalEventSystem:Fire(OtherEventType.CLOSE_FUBEN_FAIL_VIEW)
		-- ViewManager.Instance:Close(ViewName.FBFailFinishView)
	end
	UnityEngine.PlayerPrefs.DeleteKey("storyindex")

	GuajiCtrl.Instance:StopGuaji()

	FuBenData.Instance:ClearFBSceneLogicInfo()
end

function StoryFbLogic:DelayOut(old_scene_type, new_scene_type)
	BaseFbLogic.DelayOut(self, old_scene_type, new_scene_type)
	MainUICtrl.Instance:SetViewState(true)
end
