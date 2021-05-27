SpecialNpcDialogView = SpecialNpcDialogView or BaseClass(BaseView)

local radio_height = 40

function SpecialNpcDialogView:__init()
	self.is_any_click_close = true
	self.root_node_off_pos = {x = -400, y = 0}
	self.texture_path_list[1] = 'res/xui/npc_dialog.png'
	self.config_tab = {
		{"npc_dialog_ui_cfg", 2, {0}},
	}

	self.npc_obj_id = 0
	self.bottom_size = cc.size(0, 0)
	self.rich_content = nil
	self.scroll_view = nil
	self.radio_list = {}
	self.reward_list = {}
	self.rich_bottom = nil
	self.btn_list = {}
	self.btn_desc_list = {}
end

function SpecialNpcDialogView:__delete()

end

function SpecialNpcDialogView:LoadCallBack(index, loaded_time)
	if loaded_time <= 1 then
		self.remind_event = GlobalEventSystem:Bind(OtherEventType.REMIND_CAHANGE, BindTool.Bind(self.OfficeUpRemindChange, self))
	end
	self.rich_content = self.node_t_list.rich_content.node
	self.rich_content:setVerticalSpace(0)

	self.scroll_view = self.node_t_list.scroll_bottom.node
	self.scroll_view:setAnchorPoint(0.5, 0.5)

	self.rich_bottom = XUI.CreateRichText(0, 20, self.scroll_view:getContentSize().width, 22)
	self.rich_bottom:setAnchorPoint(0, 1)
	self.rich_bottom:setVerticalSpace(4)
	self.scroll_view:addChild(self.rich_bottom)

end

function SpecialNpcDialogView:ReleaseCallBack()
	self.rich_content = nil
	self.scroll_view = nil

	for k, v in pairs(self.radio_list) do
		v:DeleteMe()
	end
	self.radio_list = {}

	for k, v in pairs(self.reward_list) do
		v:DeleteMe()
	end
	self.reward_list = {}

	self.rich_bottom = nil

	self.btn_list = {}
	self.btn_desc_list = {}
	if self.remind_event then
		GlobalEventSystem:UnBind(self.remind_event)
		self.remind_event = nil
	end

	if self.click_radio_callback then
		self.click_radio_callback = nil
	end
end

function SpecialNpcDialogView:ShowIndexCallBack()
	self:Flush()
end

function SpecialNpcDialogView:OnFlush(param_list, index)
	local view_data = self:GetViewDef().view_data
	if nil == view_data then return end

	if view_data.dialog_type == NPC_DIALOG_TYPE.ZBT_NPCDLG then
		self.node_t_list.text_title_1.node:setString(Language.Task.TitleList[5])
		self.node_t_list.text_title_2.node:setString(Language.Task.TitleList[6])
	else 
		self.node_t_list.text_title_1.node:setString(Language.Task.TitleList[1])
		self.node_t_list.text_title_2.node:setString(Language.Task.TitleList[2])
	end

	self.npc_obj_id = view_data.obj_id
	self.dialog_type = view_data.dialog_type
	self.param = view_data.param
	self.msg_list = view_data.msg_list
	local npc = Scene.Instance:GetObjectByObjId(self.npc_obj_id)
	if nil ~= npc then
		self.node_t_list.text_title.node:setString(npc:GetName())
	end

	self.cond = view_data.cond
	RichTextUtil.ParseRichText(self.rich_content, view_data.cond)
	self.has_star = string.find(view_data.cond, "{star;")

	self:ParseBottom(view_data.bottom)
	self:ParseBtn(view_data.btn_list)

	self.node_t_list.layout_money.node:setVisible(false)
	if view_data.money_type == EMONEYTYPE.MTBINDCOIN then
		self.node_t_list.img_money_icon.node:loadTexture(ResPath.GetCommon("bind_coin"))
		self.node_t_list.text_money.node:setString(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BIND_COIN))
	elseif view_data.money_type == EMONEYTYPE.MTCOIN then
		self.node_t_list.img_money_icon.node:loadTexture(ResPath.GetCommon("coin"))
		self.node_t_list.text_money.node:setString(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_COIN))
	elseif view_data.money_type == EMONEYTYPE.MTBINDYUANBAO then
		self.node_t_list.img_money_icon.node:loadTexture(ResPath.GetCommon("bind_gold"))
		self.node_t_list.text_money.node:setString(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BIND_GOLD))
	elseif view_data.money_type == EMONEYTYPE.MTYUANBAO then
		self.node_t_list.img_money_icon.node:loadTexture(ResPath.GetCommon("gold"))
		self.node_t_list.text_money.node:setString(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD))
	else
		self.node_t_list.layout_money.node:setVisible(false)
	end
	
	if self.dialog_type == NPC_DIALOG_TYPE.CLFB_NPCDLG then
		self:SetCLFBSpecialTreatment()
	end

	if self.dialog_type == NPC_DIALOG_TYPE.SSG_NPCDLG then
		self:SetSSGSpecialTreatment()
	end

	self:AddRadioRectEffect()
end

function SpecialNpcDialogView:FlushSSGReward(idx)
	local list = TaskData.Instance:GetSSGRewardLis(idx or 1)
	for k,v in pairs(self.reward_list) do
		if nil ~= list[k] then
			local data = {
				item_id = list[k].item_id,
				num = list[k].count,
				is_bind = list[k].bind,
			}
			v:SetData(data)
		else
			v:SetData(nil)
		end
		v:SetVisible(nil ~= list[k])
	end
end

function SpecialNpcDialogView:AddSSGReward()
	local list = TaskData.Instance:GetSSGRewardLis(1)
	for index = 1, 8 do
		if nil == self.reward_list[index] then
			self.reward_list[index] = BaseCell.New()
			self.reward_list[index]:GetView():setContentSize(cc.size(95, 90))
			self.scroll_view:addChild(self.reward_list[index]:GetView())
		end
	end
	self:FlushSSGReward(1)
end

function SpecialNpcDialogView:ParseBottom(bottom_str)
	for k, v in pairs(self.radio_list) do
		v:SetVisible(false)
	end
	for k, v in pairs(self.reward_list) do
		v:SetVisible(false)
	end

	self.rich_bottom:removeAllElements()
	local bottom_t = RichTextUtil.Parse2Table(bottom_str)
	local radio_index, reward_index = 1, 1
	local order_t = {inserted = {}} -- 类型 1：rich 2:radio 3:reward_cell, 解析过程中通过table.insert对应类型得到解析的顺序(inserted用于记录已插入过的类型)，如有特殊需求可写死
	for i, v in ipairs(bottom_t) do
		if type(v) == "table" then
			if v[1] == "radio" then
				self:AddRadio(radio_index, v)
				radio_index = radio_index + 1
				if not order_t.inserted[2] then
					order_t.inserted[2] = true
					table.insert(order_t, 2)
				end
			elseif v[1] == "reward" then
				self:AddReward(reward_index, v)
				reward_index = reward_index + 1
				if not order_t.inserted[3] then
					order_t.inserted[3] = true
					table.insert(order_t, 3)
				end
			else
				RichTextUtil.ParseMark(self.rich_bottom, v, 20, COLOR3B.WHITE)
				if not order_t.inserted[1] then
					order_t.inserted[1] = true
					table.insert(order_t, 1)
				end
			end
		else
			XUI.RichTextAddText(self.rich_bottom, v, nil, 20, COLOR3B.WHITE)
			if not order_t.inserted[1] then
				order_t.inserted[1] = true
				table.insert(order_t, 1)
			end
		end
	end

	--圣兽宫奖励，由前端添加
	if self.dialog_type == NPC_DIALOG_TYPE.SSG_NPCDLG then
		self:AddSSGReward()
		order_t = {2, 3}
	end

	-- 排版
	local scroll_size = self.scroll_view:getContentSize()
	self.rich_bottom:refreshView()
	local rich_height = self.rich_bottom:getInnerContainerSize().height

	local x_offset, y_offset = 0, 0
	local function set_pos(order_t, height)	-- order_t：节点顺序，height：预计高度(实际内容可能超出)
		-- 按顺序设置节点坐标，并统计好内容所需高度
		for _, parse_type in ipairs(order_t) do
			if parse_type == 1 then
				self.rich_bottom:setPosition(0, height - y_offset - 5)
				y_offset = y_offset + rich_height + 10
			elseif parse_type == 2 then
				y_offset = self:FormatPosition(scroll_size.width, height, 0, y_offset, self.radio_list)
			elseif parse_type == 3 then
				y_offset = self:FormatPosition(scroll_size.width + 20, height, -12, y_offset, self.reward_list)
			end
		end
	end

	set_pos(order_t, scroll_size.height)
	local height = math.max(y_offset, scroll_size.height)
	if height > scroll_size.height then
		-- 内容超出预计高度，用所需高度重新排版
		x_offset, y_offset = 0, 0
		set_pos(order_t, height)
	end

	self.scroll_view:setInnerContainerSize(cc.size(scroll_size.width, height))
	self.scroll_view:jumpToTop()
end

function SpecialNpcDialogView:FormatPosition(width, height, x_offset, y_offset, render_list)
	local render_size = nil
	local x_pos = x_offset
	for k, v in pairs(render_list) do
		if v:GetView():isVisible() then
			render_size = v:GetView():getContentSize()
			if x_offset + render_size.width >= width then
				x_offset = x_pos
				y_offset = y_offset + render_size.height
			end

			v:GetView():setAnchorPoint(0, 1)
			v:SetPosition(x_offset, height - y_offset)

			x_offset = x_offset + render_size.width 
		end
	end

	if nil ~= render_size then
		y_offset = y_offset + render_size.height
	end

	return y_offset
end

function SpecialNpcDialogView:AddRadio(index, param)
	if nil == self.radio_list[index] then
		self.radio_list[index] = NpcRadioRender.New()
		self.scroll_view:addChild(self.radio_list[index]:GetView())
		self.radio_list[index]:SetIndex(index)
		self.radio_list[index]:AddClickEventListener(BindTool.Bind(self.OnClickRadio, self, self.radio_list[index]), false)
	end
	self.radio_list[index]:SetData(param)
	self.radio_list[index]:SetVisible(true)
end

function SpecialNpcDialogView:OnClickRadio(radio)
	for k, v in pairs(self.radio_list) do
		v:SetSelect(v == radio)
		if v == radio and self.click_radio_callback then
			self.click_radio_callback(k, v)
		end
	end
end

function SpecialNpcDialogView:SetClickRadioCallback(callback)
	if callback then self.click_radio_callback = callback end
end

function SpecialNpcDialogView:CloseCallBack()
	if self.click_radio_callback then
		self.click_radio_callback = nil
	end
end

function SpecialNpcDialogView:GetSelectIndex()
	for k, v in pairs(self.radio_list) do
		if v:IsSelect() then
			return tonumber(v:GetData()[3])
		end
	end
	return 0
end

function SpecialNpcDialogView:ParseBtn(btn_str)
	for k, v in pairs(self.btn_list) do
		v:removeFromParent()
	end
	self.btn_list = {}

	for k, v in pairs(self.btn_desc_list) do
		v:removeFromParent()
	end
	self.btn_desc_list = {}

	local btn_t = RichTextUtil.Parse2Table(btn_str)
	--linktxt test
	-- table.insert(btn_t, {"linkTxt", "", "购买次数", "ok", "花费50砖石"})
	for i, v in ipairs(btn_t) do
		if type(v) == "table" and v[1] == "btn" then
			if #btn_t > 1 then
				self:AddBtn(v[3], v[4], v[5], false)
			else
				self:AddBtn(v[3], v[4], v[5], true)
			end
			-- self:AddBtn(v[3], v[4], v[5])
		elseif type(v) == "table" and  v[1] == "linkTxt" then
			self:AddLinkTxt(v[3], v[4], v[5])
		end
	end
end

function SpecialNpcDialogView:AddLinkTxt(text, func_name, desc)
	if nil == text or nil == func_name then
		return
	end
	
	local x, y = 127+100*#self.btn_list, 20
	local btn = RichTextUtil.CreateLinkText(text, 20, COLOR3B.GREEN)
	btn:setPosition(x, y)

	self.node_t_list.layout_special_npc_dialog.node:addChild(btn, 100)

	XUI.AddClickEventListener(btn, function()
		AudioManager.Instance:PlayEffect(ResPath.GetAudioEffectResPath(AudioEffect.NPCBtn))
		if self.tip_alert == nil then
			self.tip_alert = Alert.New()
		end
		-- self.tip_alert:SetShowCheckBox(true)
		self.tip_alert:SetLableString(desc)
		self.tip_alert:SetOkFunc(function ()
			TaskCtrl.SendNpcTalkReq(self.npc_obj_id, func_name)
			-- self:Close()
	  	end)
		self.tip_alert:Open()
	end, false)

	table.insert(self.btn_list, btn)

	if self:CheckShowBtnEff(#self.btn_list, text) then
		RenderUnit.CreateEffect(23, btn, 7)
	end
end

function SpecialNpcDialogView:AddBtn(text, func_name, desc, is_cent)
	if nil == text or nil == func_name then
		return
	end
	
	local x, y = 0, 0
	if is_cent == true then 
		x, y = 230, -40
	else
		if self.dialog_type == NPC_DIALOG_TYPE.WingEquipMapNpcDlg then
			x, y = 230, -40
		else
			x, y = 160 + 140* #self.btn_list, -40
		end
	end
	local btn = XUI.CreateButton(x, y, 0, 0, false, ResPath.GetCommon("btn_151"), "", "", true)
	btn:setTitleText(text)
	btn:setTitleFontSize(22)
	self.node_t_list.layout_special_npc_dialog.node:addChild(btn, 100)
	XUI.AddClickEventListener(btn, function()
		AudioManager.Instance:PlayEffect(ResPath.GetAudioEffectResPath(AudioEffect.NPCBtn))
		if "CloseNpcDialog" == func_name then
			self:Close()
		elseif string.sub(func_name, 1, 9) == "OpenView," then
			local param = Split(string.sub(func_name, 10, -1), ",")
			ViewManager.Instance:OpenViewByStr(param[1])
			if nil ~= param[2] then
				local def = ViewManager.Instance:GetViewByStr(param[1])
				ViewManager.Instance:FlushViewByDef(def, 0, "param", {param[2]})
			end
		elseif string.sub(func_name, 1, 7) == "moveto," then
			self:Close()
			local param = Split(string.sub(func_name, 8, -1), ",")
			if param[1] then
				MoveCache.end_type = MoveEndType.Normal
				GuajiCtrl.Instance:FlyByIndex(param[1])
			end
		else
			if string.find(func_name, "%%d") then
				if NPC_POPUPTIPS[self.dialog_type] then
					local n = BagData.Instance:GetItemNumInBagById(NPC_POPUPTIPS[self.dialog_type].EnterItem.id, nil)
					if n >= NPC_POPUPTIPS[self.dialog_type].EnterItem.count then
						TaskCtrl.SendNpcTalkReq(self.npc_obj_id, string.format(func_name, self:GetSelectIndex()))
					else
						TipCtrl.Instance:OpenQuickBuyItem({NPC_POPUPTIPS[self.dialog_type].EnterItem.id})
					end
				else
					TaskCtrl.SendNpcTalkReq(self.npc_obj_id, string.format(func_name, self:GetSelectIndex()))
				end
			else
				TaskCtrl.SendNpcTalkReq(self.npc_obj_id, func_name)
				self:Close()
			end
		end
	end, false)

	table.insert(self.btn_list, btn)

	if self:CheckShowBtnEff(#self.btn_list, text) then
		RenderUnit.CreateEffect(23, btn, 7)
	end

	if nil ~= desc and "" ~= desc then
		local text_desc = XUI.CreateText(x - btn:getContentSize().width / 2 - 5, y, 160, 20, cc.TEXT_ALIGNMENT_RIGHT, desc, nil, 20, COLOR3B.YELLOW)
		text_desc:setAnchorPoint(1, 0.5)
		self.node_t_list.layout_special_npc_dialog.node:addChild(text_desc, 100)
		table.insert(self.btn_desc_list, text_desc)
	end
end

function SpecialNpcDialogView:CheckShowBtnEff(index, text)
	if self.dialog_type == NPC_DIALOG_TYPE.XYCM_NPCDLG then
		local params = RichTextUtil.GetParseStarLastParams()
		local free_count = string.match(self.cond, Language.Task.FreeCountPattern)
		local buy_count = string.match(self.cond, Language.Task.BuyCountPattern)

		if Language.Task.FlushStarStr == text then
			if type(params) == "table" and tonumber(params[2]) < 10 then
				return true
			end
		elseif Language.Task.BuyTimeStr == text then
			if free_count ~= nil and tonumber(free_count) <= 0 and buy_count ~= nil and tonumber(buy_count) > 0 then
				return true--免费次数用完，有可购买次数时
			end	
		elseif Language.Task.AcceptTaskStr == text then
			if type(params) == "table" and tonumber(params[2]) == 10 then
				if nil ~= free_count and tonumber(free_count) > 0 then
					return true--10星接受任务
				end
			end
		elseif Language.Task.UpOfficeStr == text then
			local office_remind = RemindManager.Instance:GetRemind(RemindName.OfficePost)
			return office_remind > 0
		elseif Language.Task.TimesRewardStr == text then
			return true
		end
	elseif self.dialog_type == NPC_DIALOG_TYPE.WLZB_NPCDLG then
		if index == 2 and self.param and self.param == 1 then
			return true
		end
	elseif self.dialog_type == NPC_DIALOG_TYPE.ZYZ_NpcDlg then
		if index == 1 and self.param and self.param == 1 then
			return true
		end
	end
	return false
end

function SpecialNpcDialogView:AddReward(index, param)
	local render = NpcRewardRender
	if self.dialog_type == NPC_DIALOG_TYPE.HHJD_NPCDLG then
		render = SpecialNpcRewardRender
	end
	if nil == self.reward_list[index] then
		self.reward_list[index] = render.New()
		self.scroll_view:addChild(self.reward_list[index]:GetView())
	end
	self.reward_list[index]:SetVisible(true)
	local data = {
		reward_type = tonumber(param[2]),
		id = tonumber(param[3]),
		count = tonumber(param[4]),
		is_bind = 0,
		is_show_lv = true,
	}
	self.reward_list[index]:SetData(data)
end

function SpecialNpcDialogView:OfficeUpRemindChange(remind_name, num)
	if remind_name == RemindName.OfficePost and num < 1 then
		for _, v in pairs(self.btn_list) do
			if v:getTitleText() == Language.Task.UpOfficeStr then
				v:removeChildByTag(7, true)
				break
			end
		end
	end
end


----------------------------
-- 材料副本npc特殊处理
function SpecialNpcDialogView:SetCLFBSpecialTreatment()
	if not self.msg_list or #self.msg_list <= 0 then return end
	self:SetCLFBRadioGray()
	if not self.click_radio_callback then
		self:SetClickRadioCallback(BindTool.Bind(self.OnClickCLFBRadioCallback, self))
	end

	self:OnClickCLFBRadioCallback()
end

----------------------------
-- 圣兽宫npc特殊处理
function SpecialNpcDialogView:SetSSGSpecialTreatment()
	for k,v in pairs(self.radio_list) do
		v.text_count:setColor(COLOR3B.WHITE)
	end
	if not self.click_radio_callback then
		self:SetClickRadioCallback(BindTool.Bind(self.OnClickSSGRadioCallback, self))
	end

	self:OnClickSSGRadioCallback()
end

--封魔塔防领取奖励面板10倍奖励引导特效
function SpecialNpcDialogView:AddRadioRectEffect()
	if self.dialog_type == NPC_DIALOG_TYPE.TFF_MNPCAWARDDLG then
		if next(self.radio_list) then
			if self.radio_list[8] then
				UiInstanceMgr.AddRectEffect({node = self.radio_list[8]:GetView(), init_size_scale = 1.05, act_size_scale = 1.1, offset_w = - 15, offset_h = 8, color = COLOR3B.GREEN})
			end
		end
	end
end

-- 0=btn 1=radio
function SpecialNpcDialogView:GetCLFBItemIsMakeGray(index, i_type)
	if not index or not self.msg_list or #self.msg_list <= 0 or not self.msg_list[index] then return false end
	i_type = i_type or 0
	local t = self.msg_list[index]
	if i_type == 0 then
		if t.can_buy_time and t.can_buy_time <= 0 then return true end
	elseif i_type == 1 then
		if t.can_buy_time and t.can_play_time
			and t.can_buy_time <= 0 and t.can_play_time <= 0 then
			return true
		end
	end

	return false
end

function SpecialNpcDialogView:SetCLFBRadioGray()
	if not self.radio_list then return end
	for k,v in pairs(self.radio_list) do
		local is_gray = self:GetCLFBItemIsMakeGray(k, 1)
		v:SetNormalColor(is_gray and COLOR3B.GRAY)
		v:Flush()
	end
end

function SpecialNpcDialogView:OnClickSSGRadioCallback(index, radio)
	self:FlushSSGReward(index)
end

function SpecialNpcDialogView:OnClickCLFBRadioCallback(index, radio)
	local make_gray_btn_index = 3
	if not self.btn_list or not self.btn_list[make_gray_btn_index] then return end
	index = index or self:GetSelectIndex()
	if not index then return end
	local is_gray = self:GetCLFBItemIsMakeGray(index, 0)
	self.btn_list[make_gray_btn_index]:setEnabled(not is_gray)
end

------------------------------------------------------------------------
NpcRadioRender = NpcRadioRender or BaseClass(BaseRender)
function NpcRadioRender:__init()
end

function NpcRadioRender:__delete()
end

function NpcRadioRender:SetData(data)
	BaseRender.SetData(self, data)

	if nil ~= data then
		if tonumber(data[2]) == 0 then
			self.view:setContentWH(400, radio_height+20)
		else
			self.view:setContentWH(320, radio_height)
		end
	end
end

function NpcRadioRender:CreateChild()
	BaseRender.CreateChild(self)

	self.is_select = false
	self.is_need_color = false
	self.img_check_bg = XUI.CreateImageView(15, radio_height / 2, ResPath.GetCommon("check_1_bg"), true)
	self.view:addChild(self.img_check_bg)
	self.img_check_cross = XUI.CreateImageView(15, radio_height / 2, ResPath.GetCommon("check_1_cross"), true)
	self.view:addChild(self.img_check_cross)

	self.text_count = XUI.CreateRichText(220, radio_height-30, 380, 40)
	self.view:addChild(self.text_count)

	self:SetSelect(self.index == 1)

	self:SetNormalColor()
end

function NpcRadioRender:OnFlush()
	if nil == self.data then return end
	local content = ""
	self.is_need_color = (nil ~= self.data[5] and nil ~= self.data[6])
	if not self.is_need_color then
		content = self.data[4]
	else
		content = string.format(Language.Task.HolyBeastTip, self.data[4], self.data[5], self.data[6])
	end
	
	RichTextUtil.ParseRichText(self.text_count, content)
	self.text_count:refreshView()
end

function NpcRadioRender:IsSelect()
	return self.img_check_cross:isVisible()
end

function NpcRadioRender:SetSelect(is_select)
	self.is_select = is_select
	self.img_check_cross:setVisible(is_select)
	if not self.is_need_color then
		self.text_count:setColor(is_select and COLOR3B.GREEN or (self.normal_color or COLOR3B.WHITE))
	end
end

function NpcRadioRender:SetNormalColor(color)
	self.normal_color = color or COLOR3B.WHITE
	if not self.is_need_color then
		self.text_count:setColor(self.is_select and COLOR3B.GREEN or (self.normal_color or COLOR3B.WHITE))
	end
end
