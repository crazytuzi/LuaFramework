local DungeonCailiaoView = BaseClass(SubView)

function DungeonCailiaoView:__init()
    self.texture_path_list = {
		'res/xui/fuben_cl.png',
		'res/xui/fuben.png',
	}
	self.config_tab = {
		{"fuben_cl_and_jy_ui_cfg", 1, {0}},
	}
	self.list_data = {}
end

function DungeonCailiaoView:__delete()
	self:UnBindAllGlobalEvent()
end

function DungeonCailiaoView:ReleaseCallBack()
    if self.cailiao_fuben_list then
		self.cailiao_fuben_list:DeleteMe()
		self.cailiao_fuben_list = nil
	end

	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	if self.progress then
		self.progress:DeleteMe()
		self.progress = nil
	end

	CountDown.Instance:RemoveCountDown(self.countdown)
end

function DungeonCailiaoView:LoadCallBack()
	self:CreateGridList()
	self:CreateRewardCells()

	self:BindGlobalEvent(OtherEventType.CAILIAO_INFO_CHANGE, BindTool.Bind(self.OnFlush, self))

	XUI.AddClickEventListener(self.node_t_list.btn_go.node, BindTool.Bind(self.OnClickEnterBtn, self))
	XUI.AddClickEventListener(self.node_t_list.btn_go2.node, BindTool.Bind(self.OnClickEnterBtn2, self))
	XUI.AddClickEventListener(self.node_t_list.btn_lucky_reward.node, BindTool.Bind(self.OpenLuckyDrawView, self))
	self.node_t_list.btn_lucky_reward.node:setVisible(false)
	XUI.AddRemingTip(self.node_t_list.btn_lucky_reward.node, function ()
		return DungeonData.Instance:GetLuckTurnbleDrawNum(self.list_data.static_id) > 0
	end, nil, 70, 65)

	self.progress = ProgressBar.New()
	self.progress:SetView(self.node_t_list.layout_prog.prog9_120.node)
	self.progress:SetTotalTime(3)

	-- 进入消耗
	local ph_txt = self.ph_list.ph_enter_txt
	self.txt_enter_pre = RichTextUtil.CreateLinkText("", 17, COLOR3B.GREEN)
	self.txt_enter_pre:setPosition(ph_txt.x-65, ph_txt.y)
	XUI.AddClickEventListener(self.txt_enter_pre, BindTool.Bind(self.OnOpenEnter, self), true)
	self.node_t_list.layout_fuben_cl.node:addChild(self.txt_enter_pre, 100)
	self.txt_enter_pre:setAnchorPoint(0, 0.5)

	-- 扫荡消耗
	self.txt_sweep_pre = RichTextUtil.CreateLinkText("", 17, COLOR3B.GREEN)
	self.txt_sweep_pre:setPosition(ph_txt.x-65, ph_txt.y)
	XUI.AddClickEventListener(self.txt_sweep_pre, BindTool.Bind(self.OnOpenSweep, self), true)
	self.node_t_list.layout_fuben_cl.node:addChild(self.txt_sweep_pre, 100)
	self.txt_sweep_pre:setAnchorPoint(0, 0.5)

	-- 副本奖励
	ph_txt = self.ph_list.ph_reward_txt
	self.reward_txt_pre = RichTextUtil.CreateLinkText("", 17, COLOR3B.GREEN)
	self.reward_txt_pre:setPosition(ph_txt.x-65, ph_txt.y)
	XUI.AddClickEventListener(self.reward_txt_pre, BindTool.Bind(self.OnOpenRward, self), true)
	self.node_t_list.layout_fuben_cl.node:addChild(self.reward_txt_pre, 100)
	self.reward_txt_pre:setAnchorPoint(0, 0.5)

	-- 增加扫荡次数
	ph_txt = self.ph_list.ph_add_num
	self.add_num_txt = RichTextUtil.CreateLinkText("提升VIP增加扫荡次数", 16, COLOR3B.GREEN)
	self.add_num_txt:setPosition(ph_txt.x, ph_txt.y)
	XUI.AddClickEventListener(self.add_num_txt, BindTool.Bind(self.OnOpenAddNum, self), true)
	self.node_t_list.layout_fuben_cl.node:addChild(self.add_num_txt, 100)
	-- self.add_num_txt:setAnchorPoint(0, 0.5)
end

function DungeonCailiaoView:CloseCallBack()
	self:UnBindAllGlobalEvent()
end

function DungeonCailiaoView:OpenCallBack()
end

function DungeonCailiaoView:ShowIndexCallBack()
	self:OnFlush()
	self.cailiao_fuben_list:SelectIndex(1)
end

function DungeonCailiaoView:CreateRewardCells()
	self.cell_list = {}
	for i = 1, 4 do
		local ph = self.ph_list["ph_cell_" .. i]
		local cell = BaseCell.New()
		cell:SetPosition(ph.x, ph.y)
		cell:SetAnchorPoint(0.5, 0.5)
		self.node_t_list.layout_fuben_cl.node:addChild(cell:GetView(), 103)
		table.insert(self.cell_list, cell)
	end
end

--创建item列表
function DungeonCailiaoView:CreateGridList()
	if self.cailiao_fuben_list then return end
	local cfg = FubenZongGuanCfg.fubens
	if nil == cfg then return end
	local ph = self.ph_list.ph_list
	self.cailiao_fuben_list = ListView.New()
	self.cailiao_fuben_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, DungeonItemRender, nil, nil, self.ph_list.ph_fuben_cell)
	self.cailiao_fuben_list:SelectIndex(1)
	self.cailiao_fuben_list:SetSelectCallBack(BindTool.Bind(self.OnSelectCailiaoCallback, self))
	self.cailiao_fuben_list:SetJumpDirection(ListView.Top)
	self.node_t_list.layout_fuben_cl.node:addChild(self.cailiao_fuben_list:GetView(), 100)
	self.list_data = cfg[1]
end

function DungeonCailiaoView:OnOpenEnter()
	local data = ItemData.Instance:GetItemConfig(self.list_data.consume[1][1].id)
	TipCtrl.Instance:OpenItem(data, EquipTip.FROME_BROWSE_ROLE)
end

function DungeonCailiaoView:OnOpenSweep()
	local data = ItemData.Instance:GetItemConfig(self.list_data.consume[2][1].id)
	TipCtrl.Instance:OpenItem(data, EquipTip.FROME_BROWSE_ROLE)
end

function DungeonCailiaoView:OnOpenRward()
	local data = ItemData.Instance:GetItemConfig(self.list_data.award[1].id)
	TipCtrl.Instance:OpenItem(data, EquipTip.FROME_BROWSE_ROLE)
end

function DungeonCailiaoView:OnOpenAddNum()
	ViewManager.Instance:OpenViewByDef(ViewDef.Vip)
end

function DungeonCailiaoView:OnSelectCailiaoCallback(item, index)
	if not item then return end
	local data = item:GetData()
	-- if data == nil then return end

	self.list_data = data
	self:OnFlush()
end

function DungeonCailiaoView:OnFlush()
	self.cailiao_fuben_list:SetDataList(DungeonData.Instance:GetFubenCLList())
	-- self.cailiao_fuben_list:JumpToTop()

	if nil == self.list_data or nil == self.list_data.static_id then
		CountDown.Instance:RemoveCountDown(self.countdown)
		return
	end

	local award = self.list_data.show_award
	if award.type == tagAwardType.qatEquipment then
		self.cell_list[1]:SetData({["item_id"] = award.id, ["num"] = award.count, is_bind = award.bind, effectId = award.effectId})
	else
		local virtual_item_id = ItemData.GetVirtualItemId(award.type)
		if virtual_item_id then
			self.cell_list[1]:SetData({["item_id"] = virtual_item_id, ["num"] = 1, is_bind = 0, effectId = self.list_data.effectId})
		end
	end
	
	self:BtnFlushShow()
	self:CounsunmeText()

	self.node_t_list.btn_lucky_reward.node:UpdateReimd()
end

function DungeonCailiaoView:CounsunmeText()
	local item = self.list_data.consume
	local data = ItemData.Instance:GetItemConfig(item[1][1].id)
	self.txt_enter_pre:setString(data.name .. " × " .. item[1][1].count)
	self.txt_enter_pre:setColor(Str2C3b(string.sub(string.format("%06x", data.color), 1, 6)))

	data = ItemData.Instance:GetItemConfig(item[2][1].id)
	self.txt_sweep_pre:setString(data.name .. " × " .. item[2][1].count)
	self.txt_sweep_pre:setColor(Str2C3b(string.sub(string.format("%06x", data.color), 1, 6)))

	data = ItemData.Instance:GetItemConfig(self.list_data.award[1].id)
	self.reward_txt_pre:setString(data.name .. " × " .. self.list_data.award[1].count)
	self.reward_txt_pre:setColor(Str2C3b(string.sub(string.format("%06x", data.color), 1, 6)))
end

-- 按钮显示刷新
function DungeonCailiaoView:BtnFlushShow()
	local act_info = DungeonData.Instance:GetFubenInfo(self.list_data.static_id)
	if not act_info then return end
	self.node_t_list.layout_prog.node:setVisible(false)

	--挑战、扫荡次数显示  challge_count 
	local challge_count = act_info.challge_count
	local sweep_count = act_info.sweep_count
	local is_lqu = act_info.is_lingqu

	local color = challge_count == 0 and "ff0000" or "55ff00"
	RichTextUtil.ParseRichText(self.node_t_list.rich_time.node, string.format(Language.Dungeon.DescNum, color, challge_count, self.list_data.free_count), 18, COLOR3B.OLIVE)

	local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)		-- 自身的等级
	color = role_level < self.list_data.lv and "ff0000" or "55ff00"
	RichTextUtil.ParseRichText(self.node_t_list.rich_level.node, string.format(Language.Dungeon.DescLevel, color, self.list_data.lv), 18, COLOR3B.OLIVE)

	RichTextUtil.ParseRichText(self.node_t_list.rich_limit.node, string.format(Language.Dungeon.DescTime, math.floor(FubenZongGuanCfg.time/60)), 18, COLOR3B.OLIVE)

	-- 开服2天时,开放显示额外的"一键挑战"按钮
	local open_server_days = OtherData.Instance:GetOpenServerDays()
	local x = 747
	local vis = false
	if PrivilegeData.Instance:CanOneKeyFnish() and challge_count > 0 then  --一键挑战
		self.node_t_list.btn_go.node:setTitleText(Language.Dungeon.MaterialBtnText[3])
	elseif challge_count > 0 then  --挑战
		self.node_t_list.btn_go.node:setTitleText(Language.Dungeon.MaterialBtnText[1])
		if open_server_days >= 2 then
			x = 830
			vis = true
		end
	else
		self.node_t_list.btn_go.node:setTitleText(Language.Dungeon.MaterialBtnText[2])
		self.node_t_list.btn_go.node:setEnabled(sweep_count <= 0)
		-- self.node_t_list.layout_gold_num.node:setVisible(sweep_count > 0)
	end
	self.node_t_list.btn_go.node:setEnabled(sweep_count > 0)
	self.node_t_list.btn_go.node:setPositionX(x)
	self.node_t_list.btn_go2.node:setVisible(vis)

	self.node_t_list.lbl_enter.node:setVisible(challge_count > 0)
	self.txt_enter_pre:setVisible(challge_count > 0)
	self.node_t_list.lbl_sd.node:setVisible(not (challge_count > 0))
	self.txt_sweep_pre:setVisible(not (challge_count > 0))
	self.add_num_txt:setVisible(sweep_count == 0)

	local num = DungeonData.Instance:GetLuckTurnbleDrawNum(self.list_data.static_id)
	color = num == 0 and "ff0000" or "55ff00"
	XUI.RichTextSetCenter(self.node_t_list.rich_luck_num.node)
	-- RichTextUtil.ParseRichText(self.node_t_list.rich_luck_num.node, string.format(Language.Dungeon.LuckNum, color, num), 18, COLOR3B.OLIVE)
end

function DungeonCailiaoView:OpenLuckyDrawView()
	DungeonCtrl.Instance:ShowLuckTurnble(self.list_data.static_id)
	-- ViewManager.Instance:OpenViewByDef(ViewDef.LuckyDraw)
end

function DungeonCailiaoView:OnClickEnterBtn()
	-- 背包格子少于20格时弹出提示
	if BagData.Instance:GetBagGridNum() - BagData.Instance:GetBagItemCount() < 20 then
		local start_alert = Alert.New()
		start_alert:SetLableString(string.format(Language.Fuben.NoEnoughGrid, 20))
		start_alert:SetOkFunc(function()
			ViewManager.Instance:OpenViewByDef(ViewDef.Recycle)
		end)
		-- self.start_alert:SetShowCheckBox(false)
		start_alert:SetOkString(Language.Fuben.GotoRecycle)
		start_alert:Open()
	else
		local item = self.list_data.consume
		local fuben_info = DungeonData.Instance:GetFubenInfo(self.list_data.static_id)
		local cfg = self.list_data

		if fuben_info then
			if fuben_info.is_lingqu == 1 then
				DungeonCtrl.Instance:SweepResultOpen(cfg.award, cfg.senceid)
			elseif fuben_info.challge_count > 0 then
				local n = BagData.Instance:GetItemNumInBagById(item[1][1].id, nil)
				if n >= item[1][1].count then
					DungeonCtrl.Instance.EnterFubenReq(1, cfg.static_id, 0)
				else
					TipCtrl.Instance:OpenQuickBuyItem({item[1][1].id})
				end
			elseif fuben_info.sweep_count > 0 then
				local playergold = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)
				if playergold < cfg.sweeps_yb then
					SysMsgCtrl.Instance:ErrorRemind(Language.Common.NoEnoughGold)
					return
				end

				local n = BagData.Instance:GetItemNumInBagById(item[2][1].id, nil)
				if n >= item[2][1].count then
					--扫荡进度条
					local pro_act_time = 0.6
					self.progress:SetPercent(0,false)
					self.countdown = CountDown.Instance:AddCountDown(pro_act_time,1,function(elapse_time, total_time) 
						if elapse_time >= total_time then
							CountDown.Instance:RemoveCountDown(self.countdown)
							self.node_t_list.layout_prog.node:setVisible(false)
							-- self.node_t_list.layout_gold_num.node:setVisible(true)
							DungeonCtrl.EnterFubenReq(2, cfg.static_id, 0)
						end
					end)
					self.node_t_list.layout_prog.node:setVisible(true)
					-- self.node_t_list.layout_gold_num.node:setVisible(false)

					self.progress:SetTotalTime(pro_act_time)
					self.progress:SetPercent(100,true)
				else
					TipCtrl.Instance:OpenQuickBuyItem({item[2][1].id})
					return
				end

			end
		end
	end
end

function DungeonCailiaoView:OnClickEnterBtn2()
	-- 背包格子少于20格时弹出提示
	if BagData.Instance:GetBagGridNum() - BagData.Instance:GetBagItemCount() < 20 then
		local start_alert = Alert.New()
		start_alert:SetLableString(string.format(Language.Fuben.NoEnoughGrid, 20))
		start_alert:SetOkFunc(function()
			ViewManager.Instance:OpenViewByDef(ViewDef.Recycle)
		end)
		-- self.start_alert:SetShowCheckBox(false)
		start_alert:SetOkString(Language.Fuben.GotoRecycle)
		start_alert:Open()
	else
		local item = self.list_data.consume
		local fuben_info = DungeonData.Instance:GetFubenInfo(self.list_data.static_id)
		local cfg = self.list_data

		if fuben_info then
			if fuben_info.is_lingqu == 1 then
				DungeonCtrl.Instance:SweepResultOpen(cfg.award, cfg.senceid)
			else
				local playergold = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)
				if playergold < cfg.sweeps_yb then
					SysMsgCtrl.Instance:ErrorRemind(Language.Common.NoEnoughGold)
					return
				end

				local n = BagData.Instance:GetItemNumInBagById(item[2][1].id, nil)
				if n >= item[2][1].count then
					--扫荡进度条
					local pro_act_time = 0.6
					self.progress:SetPercent(0,false)
					self.countdown = CountDown.Instance:AddCountDown(pro_act_time,1,function(elapse_time, total_time) 
						if elapse_time >= total_time then
							CountDown.Instance:RemoveCountDown(self.countdown)
							self.node_t_list.layout_prog.node:setVisible(false)
							-- self.node_t_list.layout_gold_num.node:setVisible(true)
							DungeonCtrl.EnterFubenReq(2, cfg.static_id, 0)
						end
					end)
					self.node_t_list.layout_prog.node:setVisible(true)
					-- self.node_t_list.layout_gold_num.node:setVisible(false)

					self.progress:SetTotalTime(pro_act_time)
					self.progress:SetPercent(100,true)
				else
					TipCtrl.Instance:OpenQuickBuyItem({item[2][1].id})
				end
			end
		end
	end
end

function DungeonCailiaoView:OnGetUiNode(node_name)
	-- 宝石、龙魂、羽毛、铸魂
	local list_index = string.match(node_name, "^CailiaoFuben(%d+)$")
	list_index = tonumber(list_index)
	if list_index ~= nil then
		if self.cailiao_fuben_list and self.cailiao_fuben_list:GetItemAt(list_index) and self.cailiao_fuben_list:GetItemAt(list_index).node_tree.btn_go then
			return self.cailiao_fuben_list:GetItemAt(list_index).node_tree.btn_go.node, true
		end
	end

	return DungeonCailiaoView.super.OnGetUiNode(self, node_name)
end

---------------------------
--FubenItemRender 入口render
---------------------------
DungeonItemRender = DungeonItemRender or BaseClass(BaseRender)

function DungeonItemRender:__init()
	self:AddClickEventListener()
end

function DungeonItemRender:__delete()

end

function DungeonItemRender:CreateChildCallBack()
	
	self.node_tree.img_bg.node:loadTexture(ResPath.GetBigPainting("fuben_cailiao_" .. self.data.static_id, false))
end

function DungeonItemRender:OnFlush()
	

	local fuben_info = DungeonData.Instance:GetFubenInfo(self.data.static_id)
	if fuben_info then
		self.node_tree.fuben_icon.node:loadTexture(ResPath.GetFubenCL(string.format("fuben_text_0%d", self.data.static_id)))
		

		--挑战、扫荡次数显示  challge_count 
		local challge_count = fuben_info.challge_count
		local vip_count = fuben_info.vip_count
		local sweep_count = fuben_info.sweep_count
		local num_color = COLOR3B.GREEN

		local text = string.format(Language.Dungeon.TipsCanPlayerNum, challge_count)
		if PrivilegeData.Instance:CanOneKeyFnish() and challge_count > 0 then  --一键挑战
			self.node_tree.lbl_can_pay_num.node:setString(text)
			num_color = COLOR3B.GREEN
			-- RichTextUtil.ParseRichText(self.node_tree.lbl_can_pay_num.node, text,20)
		elseif challge_count > 0 then  --挑战
			self.node_tree.lbl_can_pay_num.node:setString(text)
			num_color = COLOR3B.GREEN
			-- RichTextUtil.ParseRichText(self.node_tree.lbl_can_pay_num.node, text,20)
		else
			text = string.format(Language.Dungeon.TipSweepNum, sweep_count)
			num_color = COLOR3B.ORANGE
			-- RichTextUtil.ParseRichText(self.node_tree.lbl_can_pay_num.node, text,20)
			self.node_tree.lbl_can_pay_num.node:setString(text)
		end
		self.node_tree.lbl_can_pay_num.node:setColor(num_color)
	end
end

function DungeonItemRender:ShowEffect(show)
	
end

function DungeonItemRender:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetCommon("img9_285"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.view:addChild(self.select_effect, 999)
end


------------------------------
--可移动至下一个item的list
------------------------------

FubenListView = FubenListView or BaseClass(ListView)

-- 移动至下一项或上一项
FubenListView.MOVE_TYPE = {
	LEFT = 1,
	RIGHT = 2,
}

function FubenListView:SetMoveToNextItem(move_type)
	if nil == self.list_view or #self.items <= 0 or nil == self.ui_config then
		return
	end
	local width = self.ui_config.w
	local inner_pos = self.list_view:getInnerPosition()
	local next_index = math.floor(-1 * (inner_pos.x - 100) / width) + 4
	local last_index = math.floor(-1 * (inner_pos.x + 20) / width) + 1

	local index = move_type == FubenListView.MOVE_TYPE.LEFT and last_index or next_index

	local item_node = self.list_view:getItem(index - 1)
	if nil == item_node then
		return
	end

	local move_right_x = - (item_node:getPositionX() - self.list_view:getContentSize().width + 150)
	local move_left_x = -width * (index - 1)
	inner_pos.x = move_type == FubenListView.MOVE_TYPE.LEFT and move_left_x or move_right_x

	self.list_view:scrollToPositionX(inner_pos.x, 0.5 , true)
end


return DungeonCailiaoView