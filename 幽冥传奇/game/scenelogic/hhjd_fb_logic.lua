-- 行会禁地逻辑
HhjdFbLogic = HhjdFbLogic or BaseClass(FbSceneLogic)

function HhjdFbLogic:__init()
	self.hhjd_fb_cfg = FubenData.FubenCfg[FubenType.Hhjd][1]
	self.monster_speak_last_time = 0
	self.change_scene_cfg = nil
	self.hhjd_area_state = HHJD_AREA_STATE.WAIT

	self.all_enable_area_pos = {}
	for k, v in pairs(self.hhjd_fb_cfg.TemporaryObstacle) do
		local enable_area_pos = {}
		local start_pos = {v[1], v[2]}
		local end_pos = {v[3], v[4]}
		local block_pos = {start_pos[1] - 3, start_pos[2] + 3}
		for i = end_pos[2] - 3, block_pos[2] do
			-- 生成两层障碍区
			table.insert(enable_area_pos, {block_pos[1], block_pos[2]})
			table.insert(enable_area_pos, {block_pos[1], block_pos[2] + 1})
			block_pos[1] = block_pos[1] + 1
			block_pos[2] = block_pos[2] - 1
		end
		self.all_enable_area_pos[#self.all_enable_area_pos + 1] = {area_id = k, enable_area_pos = enable_area_pos}
	end
	-- 场景变化监听
	GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER, BindTool.Bind(self.OnSceneChange, self))
	-- 行会禁地完成监听
	EventProxy.New(FubenData.Instance, self):AddEventListener(FubenData.HhjdFinishedEvent, BindTool.Bind(self.OnFinishedFuben, self))
end

function HhjdFbLogic:__delete()
	self.quit_eff = nil
end

function HhjdFbLogic:Enter(old_scene_type, new_scene_type)
	HhjdFbLogic.super.Enter(self, old_scene_type, new_scene_type)
	
	self:CreateEnableAreaEffect()
	-- 队伍信息改变监听
	EventProxy.New(TeamData.Instance, self):AddEventListener(TeamData.TEAM_INFO_CHANGE, BindTool.Bind(self.CreateAwardShow, self))
end

function HhjdFbLogic:Out(old_scene_type, new_scene_type)
	HhjdFbLogic.super.Out(self, old_scene_type, new_scene_type)

	self:ClearEnableAreaEffect()
end

function HhjdFbLogic:Update(now_time, elapse_time)
	self:UpdateMonsterSpeak(now_time, elapse_time)
	self:SetHhjdAreaState(FubenData.Instance:GetHhjdFbAreaState())
end

-- 行会禁地完成监听回调
function HhjdFbLogic:OnFinishedFuben()
	if FubenData.Instance:HhjdIsFinished() then
		self.quit_eff = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.CreateQuitEffect, self), 50)
	end
end

-- 行会禁地退出倒计时
function HhjdFbLogic:CreateQuitEffect()
	GlobalTimerQuest:CancelQuest(self.quit_eff)
	local scene_id = Scene.Instance:GetSceneId()
	if FubenData.FubenCfg[FubenType.Hhjd2][1].MapId == scene_id then
		-- 背景
		local bg = XUI.CreateImageView(0, 0, ResPath.GetScene("fb_bg_101"), true)
		local bg_size = bg:getContentSize()
		bg:setPosition(bg_size.width * 0.5, bg_size.height * 0.5)

		-- 文字
		local word = XUI.CreateImageView(bg_size.width * 0.5 + 50, bg_size.height * 0.5, ResPath.GetScene("word_hhjd_time_out"), true)

		-- 图片数字节点
		local offset_x, offset_y = 100, 0
		local rich_num = CommonDataManager.CreateLabelAtlasImage(0)
		rich_num:setPosition(offset_x, bg_size.height * 0.5 + offset_y)

		local layout_t = {x = HandleRenderUnit:GetWidth() * 0.5, y = HandleRenderUnit:GetHeight() - 200, anchor_point = cc.p(0.5, 0.5), content_size = bg_size}
		local num_t = {num_node = rich_num, num_type = "zdl_y_", folder_name = "scene"}
		local img_t = {bg, word}
		self.quit_Hhjd = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.QuitHhjd, self), 10)
		self.countdown_view = UiInstanceMgr.Instance:CreateOneCountdownView(10, layout_t, num_t, img_t)
	end
end

-- 退出行会禁地
function HhjdFbLogic:QuitHhjd()
	GlobalTimerQuest:CancelQuest(self.quit_Hhjd)
	scene_id = Scene.Instance:GetSceneId()
	if scene_id == FubenData.FubenCfg[FubenType.Hhjd2][1].MapId then
		self.countdown_view = nil
		local fuben_id = FubenData.Instance:GetFubenId()
		FubenCtrl.OutFubenReq(fuben_id)
	end
end

-- 创建顶部奖励显示
function HhjdFbLogic:CreateAwardShow()
	-- 判断不是行会禁地就退出
	local fuben_id = FubenData.Instance:GetFubenId()
	if FubenData.FubenCfg[FubenType.Hhjd][1].fubenId ~= fuben_id and FubenData.FubenCfg[FubenType.Hhjd2][1].FbId ~= fuben_id then return end
	
	-- 更新行会禁地开启按钮
	local left_top = MainuiCtrl.Instance:GetView():GetPartLayout(MainuiView.LAYOUT_PART.LEFT_TOP)
	local layout_fuben_bar = left_top:TextureLayout():getChildByTag(88)
	-- 是否是第二层
	local is_second_scene = FubenData.Instance:HhjdIsSecond()
	if is_second_scene then
		layout_fuben_bar:getChildByTag(20):setVisible(false)
		self:ClearAwardShow()
		return
	end
	if layout_fuben_bar:getChildByTag(20):getChildByTag(10):isVisible() then
		local is_open = is_second_scene and true or (FubenData.Instance:GetHhjdFbAreaState() ~= HHJD_AREA_STATE.WAIT)
		local team_id = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_TEAM_ID)
		local is_leader = FubenTeamData.Instance:IsLeaderForMe(FubenMutilType.Hhjd, FubenMutilLayer.Hhjd1, team_id)
		if not is_open and not is_leader then
			layout_fuben_bar:getChildByTag(20):getChildByTag(10):loadTexture(ResPath.GetMainui("bar_22_word"))
		end
		if is_open then
			layout_fuben_bar:getChildByTag(20):getChildByTag(10):loadTexture(ResPath.GetMainui("bar_22_word"))
		end
		if not is_open and is_leader then
			layout_fuben_bar:getChildByTag(20):getChildByTag(10):loadTexture(ResPath.GetMainui("bar_12_word"))
		end
		if FubenData.Instance:GetHhjdTeamMemberCount() == 1 then
			layout_fuben_bar:getChildByTag(20):getChildByTag(10):loadTexture(ResPath.GetMainui("bar_12_word"))
		end
	end

	-- 删除奖励显示
	if nil ~= self.layout_AwardShow  then self:ClearAwardShow() end
	-- 隐藏右上角图标
	GlobalEventSystem:Fire(OtherEventType.TARGET_HEAD_CHANGE, true)
	local scene_id = Scene.Instance:GetSceneId()
	local center_top = MainuiCtrl.Instance:GetView():GetPartLayout(MainuiView.LAYOUT_PART.CENTER_TOP)
	local screen_width, screen_height = HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight()
	self.layout_AwardShow = XUI.CreateLayout(screen_width / 2, screen_height - 100, 0, 0)
	local award_bg = XUI.CreateImageView(0, 0, ResPath.GetMainui("scene_tip_bg"))
	local size = award_bg:getContentSize()
	local online_team_content = string.format(Language.Fuben.OnlineTeam, FubenData.Instance:GetHhjdTeamMemberCount(), FubenData.Instance:GetHhjdFbMaxNumber())
	local monster_drops_content = is_second_scene and Language.Activity.MonsterDrops or Language.Fuben.RewadDisplay
	local online_team_text = XUI.CreateText(0, 45, 200, 50, cc.TEXT_ALIGNMENT_LEFT, online_team_content, nil, 25)
	local monster_drops_text = XUI.CreateText(0, 20, 200, 50, cc.TEXT_ALIGNMENT_LEFT, monster_drops_content, nil, 25)
	self.layout_AwardShow:addChild(award_bg)
	self.layout_AwardShow:addChild(online_team_text)
	self.layout_AwardShow:addChild(monster_drops_text)

	-- 奖励物品显示
	local show_award_list = FubenData.Instance:GetHhjdShowAwards()
	local total_len = #show_award_list * 62
	for k, v in pairs(show_award_list) do
		local x = -(total_len / 2) + (k - 1) * 62
		local y = -50
		local cell = BaseCell.New()
		cell:SetScale(0.8)
		cell:SetData(ItemData.FormatItemData(v))
		cell:SetPosition(x, y)
		self.layout_AwardShow:addChild(cell:GetView(), 10)
		local cfg = FubenData.FubenCfg[FubenType.Hhjd][1]
		local show_num = cfg.Awards[FubenData.Instance:GetHhjdTeamMemberCount()][k].count
		local show_text = ""
		if k == 1 then
			show_text = show_num / 10000 .. "万"
		else
			show_text = show_num
		end
		local award_num_text = XUI.CreateText(x + 31, y - 25, 200, 50, cc.TEXT_ALIGNMENT_CENTER, show_text, nil, 17)
		self.layout_AwardShow:addChild(award_num_text)
	end
	center_top:TextureLayout():addChild(self.layout_AwardShow, 100)
end

function HhjdFbLogic:OnSceneChange(scene_id, scene_type, fuben_id)
	if FubenData.FubenCfg[FubenType.Hhjd][1].fubenId ~= fuben_id and FubenData.FubenCfg[FubenType.Hhjd2][1].FbId ~= fuben_id then
		self:ClearAwardShow()
	elseif nil == self.layout_AwardShow then
		self:CreateAwardShow()
	end
end

function HhjdFbLogic:ClearAwardShow()
	if self.layout_AwardShow then
		self.layout_AwardShow:removeFromParent()
		self.layout_AwardShow = nil
	end
end

function HhjdFbLogic:OnFlushAwardShow()
	
end

function HhjdFbLogic:SetHhjdAreaState(state)
	if self.hhjd_area_state ~= state then
		self.hhjd_area_state = state

		self:SetEnableArea()
		self:UpdateEnableAreaEffect()
		-- self:AutoMoveFight()
		Scene.Instance:GetMainRole():StopMove()
		GlobalTimerQuest:AddDelayTimer(function()
			-- if Scene.Instance:GetMainRole():IsMove() then
			-- 	return
			-- end
			local scene_logic = Scene.Instance:GetSceneLogic()
			if scene_logic.AutoMoveFight then scene_logic:AutoMoveFight() end
		end, 1)
	end
end

-- 设置不可走区域
function HhjdFbLogic:SetEnableArea()
	if nil == HandleGameMapHandler:GetGameMap() then
		return
	end

	for k, v in pairs(self.all_enable_area_pos) do
		if v.area_id <= self.hhjd_area_state then
			for _, pos in pairs(v.enable_area_pos) do
				HandleGameMapHandler:GetGameMap():resetZoneInfo(pos[1], pos[2])
			end
		else
			for _, pos in pairs(v.enable_area_pos) do
				HandleGameMapHandler:GetGameMap():setZoneInfo(pos[1], pos[2], ZONE_TYPE_BLOCK)
			end
		end
	end
end

function HhjdFbLogic:ClearEnableAreaEffect()
	if self.change_scene_cfg then
		for k, v in pairs(self.change_scene_cfg.decorations) do
			if v.hhji_decorations_area_id then
				self.change_scene_cfg.decorations[k] = nil
				Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.Decoration, k)
			end
		end
	end
end

-- 更新不可走区域特效
function HhjdFbLogic:UpdateEnableAreaEffect()
	if self.change_scene_cfg then
		for k, v in pairs(self.change_scene_cfg.decorations) do
			if v.hhji_decorations_area_id and self.hhjd_area_state >= v.hhji_decorations_area_id then
				self.change_scene_cfg.decorations[k] = nil
				Scene.Instance:DeleteObjByTypeAndKey(SceneObjType.Decoration, k)
			end
		end
	end
end

-- 创建不可走区域特效
function HhjdFbLogic:CreateEnableAreaEffect()
	self.change_scene_cfg = Scene.Instance:GetSceneConfig()
	for k, v in pairs(self.hhjd_fb_cfg.decorations) do
		for _, v1 in pairs(v) do
			table.insert(self.change_scene_cfg.decorations, {id = 1, name = "", x = v1[1], y = v1[2], hhji_decorations_area_id = k})
		end
	end
end

-- 怪物说话
function HhjdFbLogic:UpdateMonsterSpeak(now_time, elapse_time)
	if now_time - self.monster_speak_last_time < 4 then
		return
	end
	self.monster_speak_last_time = now_time

	for _, v in pairs(Scene.Instance:GetMonsterList()) do
		for __, v2 in pairs(self.hhjd_fb_cfg.MonsterId) do
			if v:GetMonsterId() == v2[1] then
				v:CreateTalkData({content = v2.word})
				break
			end
		end
	end

	self:SetEnableArea()
end
