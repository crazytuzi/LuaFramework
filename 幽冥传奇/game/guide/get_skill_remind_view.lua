-- 获得技能
GetSkillRemindView = GetSkillRemindView or BaseClass(BaseView)

function GetSkillRemindView:__init()
	self.zorder = COMMON_CONSTS.PANEL_MAX_ZORDER
	self.root_x, self.root_y = 0, 0
	self.new_skill_data = nil
	self:SetIsAnyClickClose(true)
end

function GetSkillRemindView:__delete()
end

function GetSkillRemindView:ReleaseCallBack()
	self.skill_icon = nil
end

function GetSkillRemindView:OpenCallBack()
end

function GetSkillRemindView:CloseCallBack(is_all)
	if self.delay_set_timer then
		GlobalTimerQuest:CancelQuest(self.delay_set_timer)
		self.delay_set_timer = nil
	end
end

local layout_w, layout_h = 605, 251
function GetSkillRemindView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		local screen_w, screen_h = HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight()

		self.root_x, self.root_y = screen_w * 0.5, screen_h * 0.5
		self.root_node:setPosition(self.root_x, self.root_y)
		self.root_node:setContentWH(layout_w, layout_h)

		self.bg = XUI.CreateImageViewScale9(layout_w / 2, layout_h / 2, layout_w, layout_h, ResPath.GetBigPainting("get_skill_bg"), true)
		self.root_node:addChild(self.bg, 9)

		local img_text = XUI.CreateImageView(layout_w / 2, layout_h / 2 - 15, ResPath.GetSkillIcon("get_skill_text"), true)
		self.root_node:addChild(img_text, 9)

		-- local skill_icon_bg = XUI.CreateImageView(65 + 220, layout_h / 2 + 60, ResPath.GetSkillIcon("skill_bg"), true)
		-- skill_icon_bg:setScale(0.8)
		-- self.root_node:addChild(skill_icon_bg, 10)

		local btn = XUI.CreateButton(layout_w / 2 - 18, 50, w, h, false, ResPath.GetCommon("btn_103"), nil, nil, XUI.IS_PLIST)
		btn:setTitleFontSize(24)
		btn:setTitleText(Language.Common.IKnow)
		XUI.AddClickEventListener(btn, function()
			self:Close()
		end)
		self.root_node:addChild(btn, 10)

		XUI.AddClickEventListener(self.bg, BindTool.Bind(self.OnClickBg, self))
	end
end

function GetSkillRemindView:ShowIndexCallBack()
	self.root_node:setPosition(HandleRenderUnit:GetWidth() / 2, HandleRenderUnit:GetHeight() / 2 - 100)
	self.root_node:setOpacity(0)
	
	self:SetViewTouchEnabled(false)
	local move_to = cc.MoveTo:create(0.2, cc.p(HandleRenderUnit:GetWidth() / 2, HandleRenderUnit:GetHeight() / 2))
	local fade_in = cc.FadeIn:create(0.2)
	local spawn = cc.Spawn:create(move_to, fade_in)
	local sequence = cc.Sequence:create(spawn, cc.CallFunc:create(function()
		self:SetViewTouchEnabled(true)
	end))
	self.root_node:runAction(sequence)
	-- self.root_node:setVisible(true)

	if self.delay_set_timer then
		GlobalTimerQuest:CancelQuest(self.delay_set_timer)
	end
	self.delay_set_timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.OnAutoSetSkillToBar,self), 3)

	self:Flush()
end

function GetSkillRemindView:OnFlush(param_t, index)
	if nil == self.new_skill_data then
		return
	end

	local skill_id = self.new_skill_data.skill_id
	local skill_cfg = SkillData.GetSkillCfg(skill_id)
	if nil == skill_cfg then
		return
	end

	-- self.equip_name:setString(skill_cfg.name)
	-- self.equip_desc:setString(skill_cfg.desc)

	if nil == self.skill_icon then
		self.skill_icon = XUI.CreateImageView(65 + 218, layout_h / 2 + 60, ResPath.GetSkillIcon(SkillData.Instance:GetSkillIconId(skill_id)), true)
		self.skill_icon:setScale(0.8)
		self.root_node:addChild(self.skill_icon, 20)
	else
		self.skill_icon:loadTexture(ResPath.GetSkillIcon(SkillData.Instance:GetSkillIconId(skill_id)))
	end
end

function GetSkillRemindView:AutoOpen()
	if self.new_skill_data and self:IsOpen() then
		return
	end

	local new_list = SkillData.Instance:GetNewSkillList()
	self.new_skill_data = table.remove(new_list)
	if nil == self.new_skill_data then
		XuiBaseView.Close(self)
		return
	end

	self:Open()
end

function GetSkillRemindView:OnClickBg()
	self:OnAutoSetSkillToBar()
end

function GetSkillRemindView:SetViewTouchEnabled(enabled)
	if self.bg then
		self.bg:setTouchEnabled(enabled)
	end
end

function GetSkillRemindView:OnAutoSetSkillToBar()
	self:Close()
end

function GetSkillRemindView:Close()
	if self.delay_set_timer then
		GlobalTimerQuest:CancelQuest(self.delay_set_timer)
		self.delay_set_timer = nil
	end
	if not self:IsOpen() then
		return
	end

	self:IconFlyToSkillBar()

	self:SetViewTouchEnabled(false)
	local move_to = cc.MoveTo:create(0.2, cc.p(HandleRenderUnit:GetWidth() / 2, HandleRenderUnit:GetHeight() / 2))
	local fade_out = cc.FadeOut:create(0.2)
	local spawn = cc.Spawn:create(move_to, fade_out)
	local callback = cc.CallFunc:create(function()
		self.new_skill_data = nil
		XuiBaseView.Close(self)
		self:AutoOpen()
	end)
	local action = cc.Sequence:create(spawn, callback)
	self.root_node:runAction(action)
	-- self.root_node:setVisible(true)
end

function GetSkillRemindView:IconFlyToSkillBar()
	if nil == self.skill_icon or nil == self.new_skill_data or nil == self.new_skill_data.bar_index then
		return
	end

	local bar_index = self.new_skill_data.bar_index
	local target = ViewManager.Instance:GetUiNode("MainUi", "skill_cell" .. bar_index)
	if nil == target then
		return
	end

	local node_x, node_y = self.skill_icon:getPosition()
	local node_world_pos = self.root_node:convertToWorldSpace(cc.p(node_x, node_y))
	local skill_id = self.new_skill_data.skill_id

	local fly_skill_icon = XUI.CreateImageView(node_world_pos.x, node_world_pos.y, ResPath.GetSkillIcon(SkillData.Instance:GetSkillIconId(skill_id)), true)
	fly_skill_icon:setScale(0.8)
	HandleRenderUnit:AddUi(fly_skill_icon, layer or COMMON_CONSTS.ZORDER_SYSTEM_EFFECT)

	local target_view_node = target:GetMtView()
	local target_size = target_view_node:getContentSize()
	local target_world_pos = target_view_node:AnyLayout():convertToWorldSpace(cc.p(target_size.width / 2, target_size.height / 2))

	local move_to = cc.MoveTo:create(1, cc.p(target_world_pos.x, target_world_pos.y))
	local fade_out = cc.FadeOut:create(0.2)
	local callback2 = cc.CallFunc:create(function()
		if fly_skill_icon.removeFromParent then
			fly_skill_icon:removeFromParent()
		end
	end)
	local callback1 = cc.CallFunc:create(function()
		if skill_id == 122 or skill_id == 123 or skill_id == 124 then
			
		else
			SettingCtrl.Instance:SetOneShowSkill({type = SKILL_BAR_TYPE.SKILL, id = skill_id}, HOT_KEY["SKILL_BAR_" .. bar_index])
		end
	end)
	local action = cc.Sequence:create(move_to, callback1, fade_out, callback2)
	fly_skill_icon:runAction(action)
end
