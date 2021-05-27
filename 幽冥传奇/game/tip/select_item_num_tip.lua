
SelectItemNumTip = SelectItemNumTip or BaseClass(BaseView)

function SelectItemNumTip:__init()
	if SelectItemNumTip.Instance then
		ErrorLog("[SelectItemNumTip] Attemp to create a singleton twice !")
	end
	SelectItemNumTip.Instance = self
	self.texture_path_list = {
		 'res/xui/zhuansheng.png',
	}
	self.config_tab = {
		{"itemtip_ui_cfg", 23, {0}},
	}

	self:SetIsAnyClickClose(false)
	self:SetModal(true)

	self.select_num = 1
end

function SelectItemNumTip:__delete()
	SelectItemNumTip.Instance = nil
end

function SelectItemNumTip:LoadCallBack()
	self:CreateSlider()
	self.item_cell = BaseCell.New()
	self.item_cell:SetPosition(self.ph_list.ph_cell.x, self.ph_list.ph_cell.y)
	self.item_cell:GetView():setAnchorPoint(cc.p(0.5, 0.5))
	self.node_t_list.layout_num_choice.node:addChild(self.item_cell:GetView(), 7)



	XUI.RichTextSetCenter(self.node_t_list.rich_item_num.node)
	local use_item = nil
	use_item = function (num)
		if num == 0 then
			self:Close()
		else
			BagCtrl.SendSelectItemReq(self.data.parent_id, self.data.pro, self.data.index, 1)
			num = num - 1
			use_item(num)
		end
	end

	XUI.AddClickEventListener(self.node_t_list.btn_use.node, function ()
		use_item(self.select_num)
	end)

	XUI.AddClickEventListener(self.node_t_list.btn_cancel.node, function ()
		self:Close()
	end)
end

function SelectItemNumTip:ReleaseCallBack()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	self.slider_add_point = nil
	self.tip_num = nil
end

function SelectItemNumTip:ShowIndexCallBack()
	self:Flush()
end

function SelectItemNumTip:CloseCallBack()
	self.select_num = 1
	self.data = nil
end

function SelectItemNumTip:SetData(data)
	self.data = data
end

function SelectItemNumTip:OnFlush()
	RichTextUtil.ParseRichText(self.node_t_list.rich_item_num.node, string.format("将批量使用 {wordcolor;1eff00;%s}/%s 个物品", self.select_num, self.data.num), 22)
	self.slider_add_point:setPercent((self.select_num / self.data.num) * 100)
	
	self.item_cell:SetData({item_id = self.data.item_id, num = 1 , is_bind = 0})

	local item_config = ItemData.Instance:GetItemConfig(self.data.item_id)
	self.node_t_list.lbl_item_name.node:setString(item_config.name)
	self.node_t_list.lbl_item_name.node:setColor(Str2C3b(string.sub(string.format("%06x", item_config.color), 1, 6)))
end

function SelectItemNumTip:CreateSlider()
	local path_ball = ResPath.GetZhuanSheng("bg_3")
	local path_progress = ResPath.GetZhuanSheng("prog")
	local path_progress_bg = ResPath.GetZhuanSheng("prog_progress_1")

	local ph = self.ph_list.ph_slider

	self.slider_add_point = XUI.CreateSlider(ph.x, ph.y, path_ball, path_progress_bg, path_progress, true)
	local ball = self.slider_add_point:getBallImage()
	self.tip_num = XUI.CreateText(16, 62, 40, 20, cc.TEXT_ALIGNMENT_CENTER, self.select_num, nil, 18, COLOR3B.GREEN)
	ball:addChild(self.tip_num)

	self.slider_add_point:setMaxPercent(100)
	self.slider_add_point:setMinPercent((1 / self.data.num) * 100)
	self.node_t_list.layout_num_choice.node:addChild(self.slider_add_point, 100)
	self.slider_add_point:addSliderEventListener(BindTool.Bind(self.OnSliderEvent, self))
	self.slider_add_point:getBallImage():addClickEventListener(BindTool.Bind(self.OnClick, self))

	XUI.AddClickEventListener(self.node_t_list.btn_subtract.node, BindTool.Bind(self.OnSubtract, self))
	XUI.AddClickEventListener(self.node_t_list.btn_add.node, BindTool.Bind(self.OnAdd, self))
end


function SelectItemNumTip:OnClick()
end

function SelectItemNumTip:OnSliderEvent(sender, percent, ...)
	self.select_num = math.ceil(self.data.num * (percent / 100))
	self.tip_num:setString(self.select_num)
	RichTextUtil.ParseRichText(self.node_t_list.rich_item_num.node, string.format("将批量使用 {wordcolor;1eff00;%s}/%s 个物品", self.select_num, self.data.num), 22)
end

function SelectItemNumTip:OnSubtract()
	if 1 >= self.select_num then return end
	self.select_num = self.select_num - 1
	self.slider_add_point:setPercent((self.select_num / self.data.num) * 100)
end

function SelectItemNumTip:OnAdd()
	if self.select_num >= self.data.num then return end
	self.select_num = self.select_num + 1
	self.slider_add_point:setPercent((self.select_num / self.data.num) * 100)
end