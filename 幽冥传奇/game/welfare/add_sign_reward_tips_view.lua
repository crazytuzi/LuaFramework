AddSignRewardTipsView = AddSignRewardTipsView or BaseClass(XuiBaseView)

function AddSignRewardTipsView:__init()
	-- self.background_opacity = 0
	self.is_any_click_close = true
	self:SetModal(true)

	self.config_tab = {
		{"welfare_ui_cfg", 10, {0}},
	}
	self:InitData()
end

function AddSignRewardTipsView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateCells()
	end
end

function AddSignRewardTipsView:ShowIndexCallBack(index)
	self:Flush()
end

function AddSignRewardTipsView:ReleaseCallBack()
	self:InitData()
end

function AddSignRewardTipsView:SetViewData(data)
	self.data = data
	self:Open()
end

function AddSignRewardTipsView:InitData()
	self.data = {desc = "", item_data = {}}
	if self.cell_list then
		for i,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
	end
	self.cell_list = {}
end

function AddSignRewardTipsView:OnFlush(param_t, index)
	if self.data.desc ~= nil then
		RichTextUtil.ParseRichText(self.node_t_list.rich_dec.node, self.data.desc, 22, COLOR3B.OLIVE)
	end
	if self.data.item_data ~= nil then
		for i,v in ipairs(self.data.item_data) do
			if self.cell_list[i] then
				self.cell_list[i]:SetData({item_id = v.id, num = v.count, is_bind = v.bind})
			end
		end
	end
	for k, v in pairs(self.cell_list) do
		if v:GetData() then
			v:GetView():setVisible(true)
		else
			v:GetView():setVisible(false)
		end
	end
end

function AddSignRewardTipsView:CreateCells()
	for i=1, 8 do
		local ph = self.ph_list["ph_cell_" .. i]
		if self.cell_list[i] == nil and ph then
			local cell = BaseCell.New()
			cell:GetCell():setAnchorPoint(cc.p(0.5, 0.5))
			cell:GetCell():setPosition(ph.x, ph.y)
			self.node_t_list.layout_add_sign_tips.node:addChild(cell:GetCell(), 10)

			self.cell_list[i] = cell
		end
	end
end