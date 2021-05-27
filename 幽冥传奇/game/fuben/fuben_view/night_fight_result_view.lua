-- 夜战皇城结算界面
NightFightResultView = NightFightResultView or BaseClass(XuiBaseView)

NightFightResultView = NightFightResultView or BaseClass(XuiBaseView)

function NightFightResultView:__init()
	self:SetModal(true)
	self:SetIsAnyClickClose(true)
	self.texture_path_list[1] = 'res/xui/fuben.png'
	self.texture_path_list[2] = 'res/xui/mainui.png'
	self.texture_path_list[3] = 'res/xui/charge.png'
	self.config_tab = {
		{"fuben_child_view_ui_cfg", 1, {0}},
		{"fuben_child_view_ui_cfg", 6, {0}},
	}
	self.cells_list = {}
	self.view_data = nil
end

function NightFightResultView:__delete()
end

function NightFightResultView:OpenCallBack()
end

function NightFightResultView:CloseCallBack()
	self.view_data = nil
end

function NightFightResultView:ReleaseCallBack()
	for k,v in pairs(self.cells_list) do
		v:DeleteMe()
	end
	self.cells_list = {}

end

function NightFightResultView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateAwardCells()
	end
end

function NightFightResultView:ShowIndexCallBack(index)
	self:Flush()
end

function NightFightResultView:OnFlush(param_t, index)
	if self.view_data then
		self.node_t_list.my_rank.node:setString(self.view_data.my_rank)
		self.node_t_list.my_score.node:setString(self.view_data.my_score)
		for i = 1, 3 do
			self.node_t_list["name_" .. i].node:setString("")
			self.node_t_list["score_" .. i].node:setString("")
			self.node_t_list["prof_" .. i].node:setString("")
			self.node_t_list["lv_" .. i].node:setString("")
		end
		if next(self.view_data.rank_data) then
			local rank_data = self.view_data.rank_data
			for i = 1, 3 do
				self.node_t_list["name_" .. i].node:setString(rank_data[i] and rank_data[i].name or "")
				self.node_t_list["score_" .. i].node:setString(rank_data[i] and rank_data[i].score or "")
				self.node_t_list["prof_" .. i].node:setString(rank_data[i] and RoleData.Instance:GetProfNameByType(rank_data[i].prof) or "")
				self.node_t_list["lv_" .. i].node:setString(rank_data[i] and rank_data[i].lv or "")
			end
		end

		if next(self.view_data.awards_t) then
			for k, v in pairs(self.cells_list) do
				v:GetCell():setVisible(false)
				v:SetData({})
			end
			for i, v in ipairs(self.view_data.awards_t) do
				if self.cells_list[i] then
					local is_vis = v and true or false
					self.cells_list[i]:GetCell():setVisible(is_vis)
					self.cells_list[i]:SetData({item_id = v.id, num = v.count, is_bind = v.is_bind})
				end
			end
		end
	end
end

function NightFightResultView:CreateAwardCells()
	if not next(self.cells_list) then
		for i = 1, 7 do
			local ph = self.ph_list["ph_cell_" .. i]
			local cell = BaseCell.New()
			cell:SetPosition(ph.x, ph.y)
			cell:GetCell():setVisible(false)
			self.node_t_list.layout_night_fight_result.node:addChild(cell:GetCell(), 90)
			self.cells_list[i] = cell
		end
	end
end

function NightFightResultView:SetViewData(data)
	self.view_data = data
end