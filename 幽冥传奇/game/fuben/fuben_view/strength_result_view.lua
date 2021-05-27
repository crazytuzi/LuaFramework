-- 勇者闯关 结算
StrengthResultView = StrengthResultView or BaseClass(XuiBaseView)

function StrengthResultView:__init()
	self:SetModal(true)
	self:SetIsAnyClickClose(true)
	self.texture_path_list[1] = 'res/xui/fuben.png'
	self.config_tab = {
		{"fuben_child_view_ui_cfg", 2, {0}, false},
		{"fuben_child_view_ui_cfg", 4, {0}, false},
		{"fuben_child_view_ui_cfg", 5, {0}, false},
		{"fuben_child_view_ui_cfg", 6, {0}, false},
		{"fuben_child_view_ui_cfg", 7, {0}},
	}
	self.cell_list = {}
end

function StrengthResultView:__delete()
end

function StrengthResultView:OpenCallBack()
end

function StrengthResultView:CloseCallBack()
	self.view_data = nil
end

function StrengthResultView:ReleaseCallBack()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function StrengthResultView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		for i = 1, 3 do
			local ph = self.ph_list["ph_cell_" .. i]
			local cell = BaseCell.New()
			cell:SetCellBg(ResPath.GetCommon("cell_106"))
			cell:GetView():setAnchorPoint(0.5, 0.5)
			cell:SetPosition(ph.x, ph.y)
			self.node_t_list.layout_common_succ.node:addChild(cell:GetView(), 10)
			self.cell_list[#self.cell_list + 1] = cell
		end

		self.number_bar = NumberBar.New()
		self.number_bar:SetRootPath(ResPath.GetFuben("fuben_num_"))
		self.number_bar:SetSpace(-2)
		self.number_bar:SetPosition(380, 5)
		self.node_t_list.layout_strength_chongtian_title.node:addChild(self.number_bar:GetView(), 50)

		XUI.AddClickEventListener(self.node_t_list.btn_ok_succ.node, function() self:Close() end)
	end
end

function StrengthResultView:ShowIndexCallBack(index)
	self:Flush()
end

function StrengthResultView:OnFlush(param_t, index)
	for k,v in pairs(param_t) do
		if k == "all" then
			if v.view_data then
				self:SetViewData(v.view_data)
			end
			if self.view_data == nil or next(self.view_data) == nil then
				self.view_data = { result = 1, level_num = 0, award = {{item_id = StrenfthFbData.GetAwardItemId(), num = 0, is_bind = 1}}, cur_level = 0 }
			end
			-- 背景
			self.node_t_list.layout_common_reward_bg.node:setVisible(self.view_data.result == STRENFTH_FB_STATE.ONE_SUCCESS or self.view_data.result == STRENFTH_FB_STATE.ALL_SUCCESS)
			self.node_t_list.layout_strength_failed.node:setVisible(self.view_data.result == STRENFTH_FB_STATE.DEATH_FAIL or self.view_data.result == STRENFTH_FB_STATE.OVERTIME_FAIL)
			-- 闯关结果标题
			-- self.node_t_list.layout_common_succ.node:setVisible(self.view_data.result == STRENFTH_FB_STATE.ONE_SUCCESS or self.view_data.result == STRENFTH_FB_STATE.ALL_SUCCESS)
			self.node_t_list.layout_succ_all.node:setVisible(self.view_data.result == STRENFTH_FB_STATE.ALL_SUCCESS and self.view_data.cur_level >= StrenfthFbData.GetTotalLevel())
			self.node_t_list.layout_strength_chongtian_title.node:setVisible(self.view_data.result == STRENFTH_FB_STATE.ALL_SUCCESS and self.view_data.cur_level < StrenfthFbData.GetTotalLevel())
			-- 累计关数
			self.node_t_list.lbl_level_num.node:setString(self.view_data.level_num .. Language.Fuben.LevelStr)
			self.number_bar:SetNumber(math.floor(self.view_data.cur_level / 10))
			-- 累计奖励
			for k, v in pairs(self.cell_list) do
				local award = self.view_data.award and self.view_data.award[k]
				if award then
					v:GetCell():setVisible(true)
					v:SetData(award)
					if award.num > 10000 then
						local num = math.floor(award.num / 100)
						if num % 100 ~= 0 then
							v:SetRightBottomText(string.format("%.2f", num / 100) .. Language.Common.Wan)
						end
					end
					if award.num <= 0 then
						v:SetRightBottomText("0")
					end
				else
					v:SetData()
					v:GetCell():setVisible(false)
				end
			end
		end
	end
end

function StrengthResultView:SetViewData(data)
	self.view_data = data
end
