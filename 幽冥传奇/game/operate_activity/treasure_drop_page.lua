-- 运营活动-天降奇宝
OperateActTreasureDropPage = OperateActTreasureDropPage or BaseClass()

function OperateActTreasureDropPage:__init()
	self.view = nil
end

function OperateActTreasureDropPage:__delete()
	self:RemoveEvent()
	if self.del_effec then
		self.del_effec:removeFromParent()
		self.del_effec = nil
	end

	if self.chou_jiang_dlg then
		self.chou_jiang_dlg:DeleteMe()
		self.chou_jiang_dlg = nil
	end

	if self.refre_dlg then
		self.refre_dlg:DeleteMe()
		self.refre_dlg = nil
	end

	if self.award_pool_list then
		for k, v in pairs(self.award_pool_list) do
			for k2, v2 in pairs(v) do
				v2:DeleteMe()
			end
		end
		self.award_pool_list = nil
	end
	self.view = nil
end


function OperateActTreasureDropPage:InitPage(view)
	self.view = view
	self.end_pos_y = self.view.ph_list.ph_treasure_drop_cell_1.y
	self:CreateAwardPoolList()

	self:InitEvent()
end

--初始化事件
function OperateActTreasureDropPage:InitEvent()
	-- self.view.node_t_list.btn_treasure_drop_tip.node:setVisible(false)
	XUI.AddClickEventListener(self.view.node_t_list.btn_treasure_chou.node, BindTool.Bind(self.OnChouJiang, self), true)
	XUI.AddClickEventListener(self.view.node_t_list.btn_reset_treasure_pool.node, BindTool.Bind(self.OnResetTreasurePool, self), true)
	XUI.AddClickEventListener(self.view.node_t_list.btn_treasure_drop_tip.node,BindTool.Bind(self.OnHelp,self),true)

	self.treasure_drop_data_change_evt = GlobalEventSystem:Bind(OperateActivityEventType.TREASURE_DROP_CHOUJIANG_BACK, BindTool.Bind(self.OnTreasureDropBack, self))
	self.treasure_drop_award_pool_data_evt = GlobalEventSystem:Bind(OperateActivityEventType.TREASURE_DROP_AWARD_POOL_DATA, BindTool.Bind(self.SetAwardPoolListShow, self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushRemainTime, self), 1)
end

--移除事件
function OperateActTreasureDropPage:RemoveEvent()
	if self.treasure_drop_data_change_evt then
		GlobalEventSystem:UnBind(self.treasure_drop_data_change_evt)
		self.treasure_drop_data_change_evt = nil
	end

	if self.treasure_drop_award_pool_data_evt then
		GlobalEventSystem:UnBind(self.treasure_drop_award_pool_data_evt)
		self.treasure_drop_award_pool_data_evt = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end

end

function OperateActTreasureDropPage:CreateAwardPoolList()
	local cost_str = string.format(Language.OperateActivity.JvBaoYBNum, OperateActivityData.Instance:GetTreasureDropCostMoney())
	self.view.node_t_list.txt_treasure_drop_cost_yb.node:setString(cost_str)
	if not self.award_pool_list then
		self.award_pool_list = {}
		for i = 1, 4 do
			self.award_pool_list[i] = {}
			for j = 1, 6 do
				local ph_idx = (i - 1) * 6 + j
				local ph = self.view.ph_list["ph_treasure_drop_cell_" .. ph_idx]
				if ph then
					local render = OperateActTreasureDropRender.New()
					-- render:SetUiConfig(self.view.ph_list.ph_yb_award_render, true)
					render:SetPosition(ph.x, ph.y)
					render:SetAwardRowIndex(i)
					render:SetAwardColIndex(j)
					render:SetDefaultPosY(ph.y)
					-- render:AddClickEventListener(BindTool.Bind(self.OnYbPoolAwardRenderClicked, self, render, i))
					self.view.node_t_list.layout_treasure_drop.node:addChild(render:GetView(), 100)
					self.award_pool_list[i][j] = render
				end
			end
		end
	end
end

function OperateActTreasureDropPage:SetAwardPoolListShow()
	if self.del_effec then
		self.del_effec:removeFromParent()
		self.del_effec = nil
	end
	self.view.node_t_list.btn_treasure_chou.node:setEnabled(true)
	self.view.node_t_list.img_chou.node:setGrey(false)
	self:SetRestUseTime()
	local award_show_list = OperateActivityData.Instance:GetTreasureDropShowAwardList()
	for k, v in ipairs(award_show_list) do
		for k2, v2 in ipairs(v) do
			local item = self.award_pool_list[k][k2]
			if item then
				item:SetData(v2)
				item:SetFetchState(v2.state)
			end
		end
	end

	local per_col_awar_fetched_cnt_t = OperateActivityData.Instance:GetTreasureDropPerColFetchedInfo()
	for k, v in ipairs(self.award_pool_list) do
		for k2, v2 in ipairs(v) do
			item_data = v2:GetData()
			if item_data then
				local offset_y = -110 * per_col_awar_fetched_cnt_t[k2]
				local pos_y = v2:GetDefaultPosY()
				pos_y = pos_y + offset_y
				if pos_y < self.end_pos_y then
					pos_y = self.end_pos_y
				end
				v2:GetView():setPositionY(pos_y)
			end
		end
	end

end

function OperateActTreasureDropPage:SetRestUseTime()
	local rest_use_time = OperateActivityData.Instance:GetTreasureDropRestUseTime()
	self.view.node_t_list.text_treasure_drop_chou_time.node:setString(rest_use_time)
	self.view.node_t_list.txt_treasure_drop_cost_yb.node:setVisible(rest_use_time <= 0)
end

-- 刷新
function OperateActTreasureDropPage:UpdateData(param_t)
	self:FlushRemainTime()
	self:SetAwardPoolListShow()
end

function OperateActTreasureDropPage:OnTreasureDropBack(row_idx, col_idx, cur_col_del_cnt)
	self:SetRestUseTime()
	self.view.node_t_list.btn_treasure_chou.node:setEnabled(false)
	self.view.node_t_list.img_chou.node:setGrey(true)
	local cur_item = self.award_pool_list[row_idx][col_idx]
	if cur_item then
		local callback_func = function() 
								cur_item:SetFetchState(1)
								for i = 1, 4 do
									for k, v in ipairs(self.award_pool_list[i]) do
										if v:GetData().col == col_idx and v:GetData().state == 0 then
											local pos_y = v:GetDefaultPosY() - (cur_col_del_cnt * 110)
											if pos_y < self.end_pos_y then
												pos_y = self.end_pos_y
											end
											local target_pos = cc.p(v:GetView():getPositionX(), pos_y)
											v:RunDropAction(target_pos)
										end
									end
								end
								self.view.node_t_list.btn_treasure_chou.node:setEnabled(true)
								self.view.node_t_list.img_chou.node:setGrey(false)
							end
		
		local eff_x, eff_y = cur_item:GetView():getPositionX() + 40, cur_item:GetView():getPositionY() + 40
		if self.del_effec then
			self.del_effec:removeFromParent()
			self.del_effec = nil
		end
		self.del_effec = RenderUnit.CreateEffect(920, self.view.node_t_list.layout_treasure_drop.node, 200, 0.02, 1, eff_x, eff_y, callback_func)
	end
end

function OperateActTreasureDropPage:FlushRemainTime()
	local time = OperateActivityData.Instance:GetTreasureDropAddOneRestTime()
	if self.view.node_t_list.text_treasure_drop_add_time then
		if time then
			self.view.node_t_list.text_treasure_drop_add_time.node:setString(string.format(Language.OperateActivity.TreasureDropAddOneTime[1], time))
		else
			self.view.node_t_list.text_treasure_drop_add_time.node:setString(Language.OperateActivity.TreasureDropAddOneTime[2])
		end
	end
	
end

-- 抽奖
function OperateActTreasureDropPage:OnChouJiang()
	local rest_use_time = OperateActivityData.Instance:GetTreasureDropRestUseTime()
	-- self.view.node_t_list.btn_treasure_chou.node:setEnabled(false)
	if rest_use_time <= 0 then
		if self.chou_jiang_dlg == nil then
			self.chou_jiang_dlg = Alert.New()
			local str = string.format(Language.OperateActivity.TreasurDropCostYb[1], OperateActivityData.Instance:GetTreasureDropCostMoney())
			self.chou_jiang_dlg:SetLableString(str)
			local ok_func = function() 
							local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.TREASURE_DROP)
							if cmd_id then
								OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.TREASURE_DROP, self.index, 1, 0)
							end
						end
			-- local cancel_func = function()
			-- 	self.view.node_t_list.btn_treasure_chou.node:setEnabled(true)
			-- end
			self.chou_jiang_dlg:SetOkFunc(ok_func)
			self.chou_jiang_dlg:SetShowCheckBox(true)
			-- self.chou_jiang_dlg:SetCancelFunc(cancel_func)
			-- self.chou_jiang_dlg:SetCloseFunc(cancel_func)
		end
		self.chou_jiang_dlg:Open()
		return
	end
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.TREASURE_DROP)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.TREASURE_DROP, self.index, 1, 0)
	end
end

-- 重置奖励池
function OperateActTreasureDropPage:OnResetTreasurePool()
	if self.refre_dlg == nil then
		self.refre_dlg = Alert.New()
		local ok_func = function() 
						local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.TREASURE_DROP)
						if cmd_id then
							OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.TREASURE_DROP, self.index, 2, 0)
						end
					end
		self.refre_dlg:SetOkFunc(ok_func)
		-- self.refre_dlg:SetShowCheckBox(true)
	end
	local str = string.format(Language.OperateActivity.TreasurDropCostYb[2], OperateActivityData.Instance:GetTreasureDropRefrCost())
	self.refre_dlg:SetLableString(str)
	self.refre_dlg:Open()
end

--帮助点击
function OperateActTreasureDropPage:OnHelp()
	DescTip.Instance:SetContent(Language.OperateActivity.Content[2] or Language.OperateActivity.Content[1], Language.OperateActivity.Title[1])
end	