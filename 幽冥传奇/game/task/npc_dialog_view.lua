NpcDialogView = NpcDialogView or BaseClass(BaseView)
NpcDialogView.GuideLevel = 30

function NpcDialogView:__init()
	self.is_any_click_close = true

	self.root_node_off_pos = {x = -400, y = 0}
	self.texture_path_list[1] = 'res/xui/npc_dialog.png'
	self.config_tab = {
		{"npc_dialog_ui_cfg", 1, {0}},
	}

	self.npc_obj_id = 0
	self.rich_content = nil
	self.reward_list = {}
	self.btn_list = {}
	self.arrow_root = nil
	self.timer = nil
end

function NpcDialogView:__delete()
end

function NpcDialogView:LoadCallBack()
	self.rich_content = self.node_t_list.rich_content.node
	self.rich_content:setVerticalSpace(10)
	XUI.AddClickEventListener(self.node_t_list.layout_npc_dialog.node, BindTool.Bind(self.OnClickView, self))
end

function NpcDialogView:CloseCallBack()
	self:CancelTimer()
end

function NpcDialogView:ReleaseCallBack()
	self.rich_content = nil
	for k,v in pairs(self.reward_list) do
		v:DeleteMe()
	end
	self.reward_list = {}
	self.btn_list = {}
	self.arrow_root = nil
	self.btn_eff = nil
	self.remind_img = nil

	self:CancelTimer()
end

function NpcDialogView:ShowIndexCallBack()
	self:Flush()
end

function NpcDialogView:OnFlush(param_list, index)
	local view_data = self:GetViewDef().view_data
	if nil == view_data then return end

	self.npc_obj_id = view_data.obj_id
	local npc = Scene.Instance:GetObjectByObjId(self.npc_obj_id)
	if nil ~= npc then
		self.node_t_list.text_title.node:setString(npc:GetName())
	end

	self.rich_content:removeAllElements()

	local content1, content2
	local s, e = string.find(view_data.talk_str, "<")
	if nil ~= s then
		content1 = string.sub(view_data.talk_str, 1, s - 1)
		local s2, e2 = string.find(content1, "%s")
		content1 = s2 and string.sub(content1, s2 + 1, -1) or ""
		content2 = string.sub(view_data.talk_str, s, -1)
	else
		content1 = view_data.talk_str
	end

	local font_size = 20			-- 对话内容字体大小
	local color = COLOR3B.WHITE		-- 对话内容字体颜色
	if IS_AUDIT_VERSION then
		color = COLOR3B.PINK
	end
	RichTextUtil.ParseRichText(self.rich_content, content1, font_size, color)

	for k, v in pairs(self.btn_list) do
		v.btn:removeFromParent()
	end
	self.btn_list = {}

	for k, v in pairs(self.reward_list) do
		v:SetVisible(false)
	end

	if self.btn_eff then
		self.btn_eff:setVisible(false)
	end
	if self.arrow_root then
		self.arrow_root:setVisible(false)
	end

	local is_task = false
	if nil ~= content2 then
		local i, j = 0, 0
		local last_pos = 1

		for _ = 1, 10 do
			i, j = string.find(content2, "(<.->)", j + 1)
			if nil == i or nil == j then
				break
			end

			local str = string.sub(content2, i, j)
			if string.find(str, "<@QuestAwardDesc") then
				is_task = true	-- 发现任务奖励就当成是任务对话
				local s, e = string.find(str, "(,.->)")
				if nil ~= s and nil ~= e then
					self:AddReward(tonumber(string.sub(str, s + 1, e - 1)))
				end
			elseif string.find(str, "<#BN") then
				local text, func_name, msg_id
				local s, e = string.find(str, "/")
				if nil ~= s and nil ~= e then
					text = string.sub(str, 5, e - 1) or ""
				end
				s, e = string.find(str, "(@.->)")
				if nil ~= s and nil ~= e then
					func_name = string.sub(str, s + 1, e - 1) or ""
				end

				self:AddBtn(text, func_name)
			end
			last_pos = j + 1
		end
	end

	self.node_t_list.layout_task.node:setVisible(is_task)
end

function NpcDialogView:AddReward(task_id)
	if nil == task_id then
		return
	end

	local task_info = TaskData.Instance:GetTaskInfo(task_id)
	if nil == task_info or task_info.reward_count <= 0 then
		return
	end

	for i, v in ipairs(task_info.reward_list) do
		if nil == self.reward_list[i] then
			self.reward_list[i] = NpcRewardRender.New()
			self.reward_list[i]:SetPosition(i * 110 - 100, -120)
			self.node_t_list.layout_task.node:addChild(self.reward_list[i]:GetView(), 100)
		end
		self.reward_list[i]:SetVisible(true)
		self.reward_list[i]:SetData(v)
	end
end

function NpcDialogView:AddBtn(text, func_name)
	local btn = XUI.CreateButton(240, 60 + 60 * #self.btn_list, 0, 0, false, ResPath.GetCommon("btn_146"), "", "", true)
	btn:setTitleText(text)
	btn:setTitleFontSize(22)
	local color = COLOR3B.WHITE
	if IS_AUDIT_VERSION then
		color = COLOR3B.PINK
	end
	btn:setTitleColor(color)		-- 按钮文字颜色
	self.node_t_list.layout_npc_dialog.node:addChild(btn, 100)
	if "CloseNpcDialog" ~= func_name then
		if nil == self.btn_eff then
			self.btn_eff = RenderUnit.CreateEffect(23, self.node_t_list.layout_npc_dialog.node, 200, nil, nil, 240, 60 + 60 * #self.btn_list)
		else
			self.btn_eff:setVisible(true)
			self.btn_eff:setPosition(240, 60 + 60 * #self.btn_list)
		end
	end
	XUI.AddClickEventListener(btn, function()
		AudioManager.Instance:PlayEffect(ResPath.GetAudioEffectResPath(AudioEffect.NPCBtn))
		if "CloseNpcDialog" == func_name then
			self:CloseHelper()
		else
			TaskCtrl.SendNpcTalkReq(self.npc_obj_id, func_name)
		end
	end, false)

	table.insert(self.btn_list, {btn = btn, func_name = func_name})

	if "CloseNpcDialog" ~= func_name and self.timer == nil then
		local times = CLIENT_GAME_GLOBAL_CFG.atuo_complete_task or 5
		local old_text = text
		local callback = function()
			if self:IsOpen() and self.btn_list[1] then
				local text = old_text .. string.format("(%ds)", times)
				self.btn_list[1].btn:setTitleText(text)
			end

			times = times - 1
			if times < 0 then
				TaskCtrl.SendNpcTalkReq(self.npc_obj_id, func_name)
				self:CancelTimer()
			end
		end

		callback()
		self.timer = GlobalTimerQuest:AddTimesTimer(callback, 1, times + 2)
	end

	if RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) <= NpcDialogView.GuideLevel then
		self:FlushArrow(btn)
		self:ShowRemindImg(btn, true)
	end
end

function NpcDialogView:CancelTimer()
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

function NpcDialogView:OnClickView()
	if #self.btn_list == 1 then
		local func_name = self.btn_list[1].func_name
		if "CloseNpcDialog" == func_name then
			self:CloseHelper()
		else
			TaskCtrl.SendNpcTalkReq(self.npc_obj_id, func_name)
		end
	end
end
function NpcDialogView:FlushArrow(btn)
	if nil == self.arrow_root then
		self.arrow_root = cc.Node:create()
		self.node_t_list.layout_npc_dialog.node:addChild(self.arrow_root, 200)
		self.arrow_node = cc.Node:create()
		self.arrow_root:addChild(self.arrow_node)
		self.arrow_frame = XButton:create(ResPath.GetGuide("arrow_frame"), "", "")
		self.arrow_frame:setTitleFontSize(25)
		self.arrow_frame:setTouchEnabled(false)
		self.arrow_frame:setTitleText(Language.Task.GuideText)
		self.arrow_node:addChild(self.arrow_frame)
		self.arrow_frame:setTitleFontName(COMMON_CONSTS.FONT)
		local label = self.arrow_frame:getTitleLabel()
		if label then
			local color = COLOR3B.G_Y
			if IS_AUDIT_VERSION then
				color = COLOR3B.PINK
			end
			label:setColor(color)	-- 指标文字颜色
			label:enableOutline(cc.c4b(0, 0, 0, 100), 1.5)
		end
		self.arrow_point = XUI.CreateImageView(84, -26, ResPath.GetGuide("arrow_point"))
		self.arrow_point:setAnchorPoint(1, 0.5)
		self.arrow_node:addChild(self.arrow_point)
	else
		self.arrow_root:setVisible(true)
	end

	self.arrow_point:setRotation(180)
	self.arrow_frame:setAnchorPoint(0.5, 0)
	self.arrow_frame:setPosition(204, -56)
	local move1 = cc.MoveTo:create(0.5, cc.p(10, 0))
	local move2 = cc.MoveTo:create(0.5, cc.p(0, 0))
	local action = cc.RepeatForever:create(cc.Sequence:create(move1, move2))
	self.arrow_node:stopAllActions()
	self.arrow_node:runAction(action)

	local x, y = btn:getPosition()
	local size = btn:getContentSize()
	self.arrow_root:setPosition(x, y + size.height / 2)
end

function NpcDialogView:ShowRemindImg(btn, vis)
	if not self:IsOpen() then
		return
	end

	local x, y = btn:getPosition()
	local size = cc.size(0, 0)

	if nil == self.remind_img then
		local img = XUI.CreateImageView(x + size.width / 2, y + size.height / 2, ResPath.GetCommon("common_exterior_effect"))
		self.node_t_list.layout_npc_dialog.node:addChild(img, 999)
		-- self.root_node:addChild(img, 999)
		self.remind_img = img

		local scale_to = cc.ScaleTo:create(0.4, 0.5)
		local fade_out = cc.FadeOut:create(0.3)
		local init_func = cc.CallFunc:create(function()
			img:setScale(1)
			img:setOpacity(255)
		end)
		local act_seq = cc.Sequence:create(init_func, cc.Spawn:create(scale_to, fade_out), cc.DelayTime:create(0.3))
		img:runAction(cc.RepeatForever:create(act_seq))
	end

	self.remind_img:setVisible(vis)
	self.remind_img:setPosition(x + size.width / 2, y + size.height / 2)
end

------------------------------------------------------------------------
NpcRewardRender = NpcRewardRender or BaseClass(BaseRender)
function NpcRewardRender:__init()
	self.view:setContentWH(110, 110)
	self.item_cell = nil
	-- self.view:setBackGroundColor(COLOR3B.BLUE)
end

function NpcRewardRender:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function NpcRewardRender:CreateChild()
	BaseRender.CreateChild(self)

	self.item_cell =  BaseCell.New()
	self.item_cell:SetPosition(55, 65)
	self.item_cell:GetView():setAnchorPoint(0.5, 0.5)
	self.view:addChild(self.item_cell:GetView())

	self.text_count = XUI.CreateText(55, 15, 100, 20, cc.TEXT_ALIGNMENT_CENTER, "", nil, 20, COLOR3B.GREEN)
	self.view:addChild(self.text_count)
end

function NpcRewardRender:OnFlush()
	if nil == self.data then
		return
	end

	if self.data.is_show_lv then
		local item = ItemData.Instance:GetItemConfig(self.data.id)
		self.text_count:setString(item.orderType and item.orderType .. "阶" or "")
	else
		self.text_count:setString("x"..self.data.count)
	end

	if self.data.reward_type == tagAwardType.qatEquipment then
		self.item_cell:SetData({["item_id"] = self.data.id, ["num"] = 0, ["is_bind"] = self.data.is_bind or 1})
	else
		local virtual_item_id = ItemData.GetVirtualItemId(self.data.reward_type)
		if virtual_item_id then
			self.item_cell:SetData({["item_id"] = virtual_item_id, ["num"] = 0, is_bind = 0})
		end
	end
end

SpecialNpcRewardRender = SpecialNpcRewardRender or BaseClass(NpcRewardRender)
function SpecialNpcRewardRender:__init()
	self.view:setContentWH(88, 90)
	self.item_cell = nil
	-- self.view:setBackGroundColor(COLOR3B.BLUE)
end

function SpecialNpcRewardRender:__delete()
end

function SpecialNpcRewardRender:CreateChild()
	SpecialNpcRewardRender.super.CreateChild(self)

	self.item_cell:SetPosition(55, 45)
	self.text_count:setVisible(false)
end
