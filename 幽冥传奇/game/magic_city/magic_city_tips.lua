MagicCityTips = MagicCityTips or BaseClass(XuiBaseView)

function MagicCityTips:__init()
	self.is_modal = true
	self.is_any_click_close = true
	self.texture_path_list[1] = 'res/xui/magiccity.png'
	self.config_tab  = {
							{"magic_city_ui_cfg", 2, {0}},
						}
	
	self.reward_cell = {}
	self.donate_times = 1
	self.buy_items = 0
	self.data = {}
end

function MagicCityTips:__delete()
	
end

function MagicCityTips:ReleaseCallBack()
	if self.reward_cell ~= nil then
		for i,v in ipairs(self.reward_cell) do
			v:DeleteMe()
		end
		self.reward_cell = {}
	end

	if nil ~= self.pop_num_view then
		self.pop_num_view:DeleteMe()
		self.pop_num_view = nil
	end
	if self.first_cell ~= nil then
		for i,v in ipairs(self.first_cell) do
			v:DeleteMe()
		end
		self.first_cell = {}
	end
	if nil ~= self.buy_num_view then
		self.buy_num_view:DeleteMe()
		self.buy_num_view = nil 
	end
end

function MagicCityTips:SetData(data)
	self:Flush()
	self.data = data
end

function MagicCityTips:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateCell()
		self.node_t_list.btn_enter_fuben_magic.node:addClickEventListener(BindTool.Bind(self.OnEnterFubenMagic, self))
		self.node_t_list.btn_sweep_magic.node:addClickEventListener(BindTool.Bind(self.OnSweepFubenMagic, self))
		self.node_t_list.btn_add.node:addClickEventListener(BindTool.Bind(self.OnAddNum, self))
		self.pop_num_view = NumKeypad.New()
		self.pop_num_view:SetOkCallBack(BindTool.Bind1(self.OnOKCallBack, self))
		XUI.AddClickEventListener(self.node_t_list.btn_open_time.node, BindTool.Bind1(self.OnOpenNum, self))
		XUI.AddClickEventListener(self.node_t_list.questBtn.node, BindTool.Bind1(self.OnHelpTip, self))
	end
end

function MagicCityTips:OnOpenNum()
	if nil ~= self.pop_num_view then
		self.pop_num_view:Open()
		self.pop_num_view:SetText(self.donate_times)
		local max_val = self.data.my_max_num - self.data.my_enter_num
		self.pop_num_view:SetMaxValue(max_val)
	end
end

function MagicCityTips:OnOKCallBack(num)
	if num >= self.data.my_max_num - self.data.my_enter_num then
		num = self.data.my_max_num - self.data.my_enter_num
	end
	self.donate_times = num
	self:FlushMyText()
end

function MagicCityTips:FlushMyText()
	self.node_t_list.txt_donate.node:setString(self.donate_times)
	self.node_t_list.txt_donate.node:setColor(COLOR3B.WHITE)
end

function MagicCityTips:OnHelpTip()
	DescTip.Instance:SetContent(Language.MagicCity.TitleContent, Language.MagicCity.Title)
end

function MagicCityTips:OnEnterFubenMagic()
	MagicCityCtrl.Instance:SendOperateCheaterReq(self.data.chapter_id, 1, 0)
end

function MagicCityTips:OnSweepFubenMagic()
	if self.donate_times > 0 then
		MagicCityCtrl.Instance:SendOperateCheaterReq(self.data.chapter_id, 2, self.donate_times)
	else
		SysMsgCtrl.Instance:FloatingTopRightText(Language.MagicCity.RightTips)
	end
end

function MagicCityTips:OnFlush()
	RichTextUtil.ParseRichText(self.node_t_list.rich_fuben_name.node, self.data.fuben_name, 22, COLOR3B.YELLOW)
	XUI.RichTextSetCenter(self.node_t_list.rich_fuben_name.node)
	
	self.node_t_list.txt_remain_time.node:setString(string.format(Language.MagicCity.TodayNum, self.data.my_enter_num, self.data.my_max_num))
	local consume = MagicCityData.Instance:GetConsumeYuanbao(self.data.chapter_id, self.data.buy_num + 1)
	local txt = ""
	if consume ~= nil then
		txt = string.format(Language.MagicCity.Consume_Gold, consume.count or 0)
	else
		txt = Language.MagicCity.Consume_desc
	end
	self.node_t_list.txt_consume_yunbao.node:setString(txt)
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.enter_consumes[1].id)
	local count = self.data.enter_consumes[1].count
	if item_cfg == nil then return end 	
	local name = item_cfg.name 
	

	local txt  = string.format(Language.MagicCity.EnterConsume, name, count)
	RichTextUtil.ParseRichText(self.node_t_list.txt_consuem_item.node, txt, 20, COLOR3B.WHITE)

	local txt_1 = self.data.my_last_time == 0 and string.format(Language.MagicCity.LastTongGuangTime, Language.MagicCity.ZhanWu) or string.format(Language.MagicCity.LastTongGuangTime, TimeUtil.FormatSecond(self.data.my_last_time, 2))
	RichTextUtil.ParseRichText(self.node_t_list.txt_tongguang_name.node, txt_1, 20, COLOR3B.WHITE)

	local txt_2 = self.data.my_score == 0 and string.format(Language.MagicCity.LastTongGuangScore, Language.MagicCity.ZhanWu) or string.format(Language.MagicCity.LastTongGuangScore, self.data.my_score)
	RichTextUtil.ParseRichText(self.node_t_list.txt_my_score.node, txt_2, 20, COLOR3B.WHITE)

	local data = self.data.show_reward
	for k,v in pairs(self.reward_cell) do
		v:GetView():setVisible(false)
	end
	for k,v in pairs(self.reward_cell) do
		if #data >= k then
			v:GetView():setVisible(true)
		end
	end
	
	for i,v in ipairs(data) do
		self.reward_cell[i]:SetData({item_id = v.id, num = v.cond, is_bind = v.bind})
	end

	local first_data = self.data.first_star_reward or {}
	for k,v in pairs(self.first_cell) do
		v:GetView():setVisible(false)
	end
	for k,v in pairs(self.first_cell) do
		if #first_data >= k then
			v:GetView():setVisible(true)
		end
	end
	for i, v in ipairs(first_data) do
		if v.id == 0 then
			local virtual_item_id = ItemData.Instance:GetVirtualItemId(v.type)
			if virtual_item_id then
				self.first_cell[i]:SetData({["item_id"] = virtual_item_id, ["num"] = v.count, is_bind = 0})
			end
		else
			self.first_cell[i]:SetData({item_id = v.id, num = v.count, is_bind = v.bind})
		end
	end
	self:OnOKCallBack((self.data.my_max_num - self.data.my_enter_num) > 0 and 1 or 0)
end

function MagicCityTips:OnAddNum()
	MagicCityCtrl.Instance:SendOperateCheaterReq(self.data.chapter_id, 3, 0)
end

function MagicCityTips:OpenCallBack()
	self.donate_times = 1
end

function MagicCityTips:CloseCallBack()
	self.donate_times = 1
end

function MagicCityTips:CreateCell()
	self.first_cell = {}
	local ph = self.ph_list.ph_first_reward_cell
	for i = 1, 3 do
 		local cell = BaseCell.New()
		cell:SetPosition(ph.x + 90*(i - 1), ph.y)
		cell:GetView():setAnchorPoint(0, 0)
		self.node_t_list.layout_tips.node:addChild(cell:GetView(), 103)
		table.insert(self.first_cell, cell)
 	end

 	self.reward_cell = {}
 	local ph = self.ph_list.ph_tg_cell
 	for i = 1, 3 do
 		local cell = BaseCell.New()
		cell:SetPosition(ph.x + 90*(i - 1), ph.y)
		cell:GetView():setAnchorPoint(0, 0)
		self.node_t_list.layout_tips.node:addChild(cell:GetView(), 103)
		table.insert(self.reward_cell, cell)
 	end
end

