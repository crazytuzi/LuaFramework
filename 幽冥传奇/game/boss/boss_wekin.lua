WeKinView = WeKinView or BaseClass(XuiBaseView)

function WeKinView:__init()
	self.texture_path_list[1] = 'res/xui/strength_fb.png'
	self.config_tab = {
		{"welkin_ui_cfg", 1, {0}},
	}
	self.reward_cell = {}
end

function WeKinView:__delete()
end

function WeKinView:ReleaseCallBack()
	
end

function WeKinView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateCells()
	end
end

function WeKinView:OpenCallBack()
	self:AddMoveAutoClose()
end

function WeKinView:CloseCallBack()

end

function WeKinView:ShowIndexCallBack(index)
	self:Flush(index)
end

function WeKinView:OnFlush(param_t, index)
	for k,v in pairs(param_t) do
		if k == "OnOpenView" then
			if v[1] ~= "" and v[1] ~= nil then
				local count = tonumber(v[1])
				local txt = string.format(Language.Boss.Desc, count)
				self.node_t_list.txt_desc.node:setString(txt)
				local cur_data = BossData.Instance:GetWekinReward()
				local data = cur_data and cur_data[count]
				for i, v1 in ipairs(data) do
					if v1.item_id == 0 then
						local virtual_item_id = ItemData.Instance:GetVirtualItemId(v1.item_type)
						if virtual_item_id then
							self.reward_cell[i]:SetData({["item_id"] = virtual_item_id, ["num"] = v1.num, is_bind = 0})
						end
					else
						self.reward_cell[i]:SetData(v1)
					end
					self.node_t_list["txt_num_"..i].node:setString("")
				end
			end
		end
	end
	RichTextUtil.ParseRichText(self.node_t_list.rich_text_1.node, Language.Fuben.Content, 18, COLOR3B.YELLOW)
end

function WeKinView:CreateCells()
	self.reward_cell = {}
	for i = 1, 2 do
		local ph = self.ph_list["ph_cell_"..i]
		local cell = BaseCell.New()
		cell:SetPosition(ph.x, ph.y)
		self.node_t_list["layout_wekin"].node:addChild(cell:GetView(), 103)
		table.insert(self.reward_cell, cell)
	end
end