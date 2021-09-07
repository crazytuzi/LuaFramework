FuBenInFoView = FuBenInFoView or BaseClass(BaseView)

function FuBenInFoView:__init()
	self.ui_config = {"uis/views/fubenview", "FuBenInFoView"}
	self.fb_type = nil
	-- self.scene_load_quit = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_QUIT,
	-- BindTool.Bind1(self.OnSceneLoaded, self))
	self.scene_load_enter = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER,
		BindTool.Bind(self.OnChangeScene, self))
end

function FuBenInFoView:LoadCallBack()
	self.phase_info_content = self:FindObj("PhaseInfoContent")
	self.phase_info_view = FuBenInfoPhaseView.New(self.phase_info_content)

	self.exp_info_content = self:FindObj("ExpInfoContent2")
	self.exp_info_view = FuBenInfoExpView.New(self.exp_info_content)

	self.story_info_view = FuBenInfoStoryView.New(self.phase_info_content)

	self.tower_info_content = self:FindObj("TowerInfoContent")
	self.tower_info_view = FuBenInfoTowerView.New(self.tower_info_content)

	self.vip_info_content = self:FindObj("VipInfoContent")
	self.vip_info_view = FuBenInfoVipView.New(self.vip_info_content)

	self.leave_fb_content = self:FindObj("LeaveFBContent")

	self:Flush()
end

function FuBenInFoView:ReleaseCallBack()
	-- if self.scene_load_quit ~= nil then
	-- 	GlobalEventSystem:UnBind(self.scene_load_quit)
	-- 	self.scene_load_quit = nil
	-- end

	if self.scene_load_enter ~= nil then
		GlobalEventSystem:UnBind(self.scene_load_enter)
		self.scene_load_enter = nil
	end
end

function FuBenInFoView:CloseCallBack()
	if Scene.Instance:GetSceneType() == SceneType.PhaseFb then
		self.phase_info_view:CloseCallBack()
	elseif Scene.Instance:GetSceneType() == SceneType.ExpFb then
		self.exp_info_view:CloseCallBack()
	elseif Scene.Instance:GetSceneType() == SceneType.StoryFB then
		self.story_info_view:CloseCallBack()
	elseif Scene.Instance:GetSceneType() == SceneType.VipFB then
		self.vip_info_view:CloseCallBack()
	elseif Scene.Instance:GetSceneType() == SceneType.ChallengeFB then
		self.tower_info_view:CloseCallBack()
	end
end

function FuBenInFoView:OnChangeScene()
	print("执行了 FuBenInFoView:OnChangeScene  ####", Scene.Instance:GetSceneType())
	FuBenCtrl.Instance:SendGetPhaseFBInfoReq()
	if Scene.Instance:GetSceneType() == SceneType.ExpFb then
		FuBenCtrl.Instance:SendGetExpFBInfoReq()
	elseif Scene.Instance:GetSceneType() == SceneType.StoryFB then
		FuBenCtrl.Instance:SendGetStoryFBGetInfo()
	elseif Scene.Instance:GetSceneType() == SceneType.VipFB then
		FuBenCtrl.Instance:SendGetVipFBGetInfo()
	elseif Scene.Instance:GetSceneType() == SceneType.PataFB then
		FuBenCtrl.Instance:SendGetTowerFBGetInfo()
	end
end

-- function FuBenInFoView:OnSceneLoaded(old_scene, new_scene)
-- 	print("执行了 FuBenInFoView:OnSceneLoaded  @@@@@")
-- 	FuBenCtrl.Instance:SendGetPhaseFBInfoReq()
-- 	FuBenCtrl.Instance:SendGetExpFBInfoReq()
-- end

function FuBenInFoView:ShowContent(index)
	self.phase_info_content:SetActive(index == TabIndex.fb_phase or index == TabIndex.fb_story)
	self.exp_info_content:SetActive(index == TabIndex.fb_exp)
	self.tower_info_content:SetActive(index == TabIndex.fb_tower)
	self.vip_info_content:SetActive(index == TabIndex.fb_vip)
end

function FuBenInFoView:OnFlush(param_t)
	local cur_index = self:GetShowIndex()
	self:ShowContent(cur_index)
	for k, v in pairs(param_t) do
		if k == "phase" or cur_index == TabIndex.fb_phase then
			print("阶段副本")
			if FuBenData.Instance:GetPhaseFBInfo() then
				self.phase_info_view:Flush(self.leave_fb_content)
			end
		elseif k == "exp" or cur_index == TabIndex.fb_exp then
			print("经验副本")
			if FuBenData.Instance:GetExpFBInfo() then
				self.exp_info_view:Flush(self.leave_fb_content)
			end
		elseif k == "vip" or cur_index == TabIndex.fb_vip then
			if FuBenData.Instance:GetVipFBInfo() then
				self.vip_info_view:Flush(self.leave_fb_content)
			end
			print("VIP副本")
		elseif k == "story" or cur_index == TabIndex.fb_story then
			print("剧情副本")
			if FuBenData.Instance:GetStoryFBInfo() then
				self.story_info_view:Flush(self.leave_fb_content)
			end
		elseif k == "tower" or cur_index == TabIndex.fb_tower then
			if FuBenData.Instance:GetTowerFBInfo() then
				self.tower_info_view:Flush(self.leave_fb_content)
			end
			print("勇者之塔副本")
		end
	end
end
