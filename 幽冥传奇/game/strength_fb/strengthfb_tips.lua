-----------------------------------
-- 勇者闯关 宝箱tips
-----------------------------------
StrengthfbEnterTips = StrengthfbEnterTips or BaseClass(XuiBaseView)

function StrengthfbEnterTips:__init()
	self.is_modal = true
	self.is_any_click_close = true
	self.config_tab  = {
							{"strengthfb_ui_cfg", 3, {0},}
						}
	self.page = nil 
	self.level = nil 
	self.my_data = nil
	self.star_list = nil 
	self.reward_cell = {}
	self.donate_times = 0
	--self.roledata_change_callback = BindTool.Bind1(self.RoleDataChangeCallback,self)			--监听人物属性数据变化
end

function StrengthfbEnterTips:__delete()
	
end

function StrengthfbEnterTips:ReleaseCallBack()
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

	if self.sucess_tip ~= nil then
		self.sucess_tip:DeleteMe()
		self.sucess_tip = nil 
	end
end

function StrengthfbEnterTips:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		--self:CreateStar()
		self:CreateCell()
		self.node_t_list.btn_enter_fuben.node:addClickEventListener(BindTool.Bind(self.OnEnterFuben, self))
		self.node_t_list.btn_sweep.node:addClickEventListener(BindTool.Bind(self.OnSweepFuben, self))
		self.pop_num_view = NumKeypad.New()
		self.pop_num_view:SetOkCallBack(BindTool.Bind1(self.OnOKCallBack, self))
		--XUI.AddClickEventListener(self.node_t_list.btn_sweep_time.node, BindTool.Bind1(self.OnOpenPopNum, self))
		XUI.AddClickEventListener(self.node_t_list.questBtn.node, BindTool.Bind1(self.OnHelp, self))
	end
end

function StrengthfbEnterTips:OnOpenPopNum()
	if nil ~= self.pop_num_view then
		self.pop_num_view:Open()
		self.pop_num_view:SetText(self.donate_times)
		local max_val = self.my_data.my_time - self.my_data.time
		self.pop_num_view:SetMaxValue(1)
	end
end

function StrengthfbEnterTips:OnOKCallBack(num)
	self.donate_times = num 
	self:FlushText()
end

function StrengthfbEnterTips:OnHelp()
	DescTip.Instance:SetContent(Language.StrenfthFb.Titel_Saodang_content, Language.StrenfthFb.Titel_Saodang)
end

function StrengthfbEnterTips:FlushText()
	self.node_t_list.txt_donate.node:setString(self.donate_times)
	self.node_t_list.txt_donate.node:setColor(COLOR3B.WHITE)
end

function StrengthfbEnterTips:SetData(page, level, data)
	self.page = page
	self.level = level 
	self.my_data = data
	self:Flush()
end

function StrengthfbEnterTips:OnFlush()
	HtmlTextUtil.SetString(self.node_t_list.rich_fuben_name.node, self.my_data.name)
	RichTextUtil.ParseRichText(self.node_t_list.rich_content.node, Language.StrenfthFb.Content, 18, COLOR3B.WHITE)
	XUI.RichTextSetCenter(self.node_t_list.rich_fuben_name.node)
	local item_cfg = ItemData.Instance:GetItemConfig(self.my_data.consumeid)
	if item_cfg == nil then
		return 
	end 
	local txt = string.format(Language.StrenfthFb.Consume, item_cfg.name, self.my_data.consume_num)
	self.node_t_list.txt_consuem_item.node:setString(txt)
	local cur_data = {} 
	for i, v in ipairs(self.my_data.awrad) do
		if v.id == 0 then
			local virtual_item_id = ItemData.Instance:GetVirtualItemId(v.type)
			if virtual_item_id then
				cur_data[i] = {["item_id"] = virtual_item_id, ["num"] = v.count, is_bind = 0}
			end
		else
			cur_data[i] = {item_id = v.id, num = v.count, is_bind = 0}
		end
	end
	for i, v in ipairs(cur_data) do
		self.reward_cell[i]:SetData(v)
	end
	for i, v in ipairs(self.reward_cell) do
		if #cur_data >= i then
			v:GetView():setVisible(true)
		else
			v:GetView():setVisible(false)
		end
	end
	self.node_t_list.txt_donate.node:setString(self.donate_times)
end

function StrengthfbEnterTips:OnEnterFuben()
	StrenfthFbCtrl.Instance:ReqEnterFuben(self.page, self.level)
	if ItemData.Instance:GetItemNumInBagById(self.my_data.consumeid, nil) >= self.my_data.consume_num then
		self:Close()
	end
end

function StrengthfbEnterTips:OnSweepFuben()
	StrenfthFbCtrl.Instance:ReqSweepFuben(self.page, self.level, self.donate_times)
	if ItemData.Instance:GetItemNumInBagById(self.my_data.consumeid, nil) >= (self.my_data.consume_num*self.donate_times) then
		self:Close()
	end
end

function StrengthfbEnterTips:CreateCell()
	self.reward_cell = {}
	for i = 1, 3 do
		local ph = self.ph_list.ph_fb_cell
		local cell = BaseCell.New()
		cell:SetPosition(ph.x + 100*(i - 1), ph.y)
		cell:GetView():setAnchorPoint(0, 0)
		self.node_t_list.layout_tips.node:addChild(cell:GetView(), 103)
		table.insert(self.reward_cell, cell)
	end
end

function StrengthfbEnterTips:OpenCallBack()
	self.donate_times = 1
end

function StrengthfbEnterTips:CloseCallBack()
	self.donate_times = 1
end