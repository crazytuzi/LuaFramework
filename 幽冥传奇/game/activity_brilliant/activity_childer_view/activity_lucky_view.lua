LuckGiftView = LuckGiftView or BaseClass(ActTurnbleBaseView)

function LuckGiftView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function LuckGiftView:__delete()
	self:DeleteLuckyGiftMoveTimer()

	if self.next_lk_flush_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.next_lk_flush_timer)
		self.next_lk_flush_timer = nil
	end

	if self.lc_cell_list then
		for k,v in pairs(self.lc_cell_list) do
			v:DeleteMe()
		end
		self.lc_cell_list = {}
	end

	if self.cell_list then
		self.cell_list:DeleteMe()
		self.cell_list = nil
	end
end

function LuckGiftView:InitView()
	self:CreateGride()
	self:CreateLuckyFlushTimer()
	self.node_t_list.btn_draw.node:addClickEventListener(BindTool.Bind2(self.OnClickTurntableHandler, self))
	self.node_t_list.btn_lucky_buy.node:addClickEventListener(BindTool.Bind2(self.OnClickLuckyHandler, self,1))
	self.node_t_list.btn_lucky_flush.node:addClickEventListener(BindTool.Bind2(self.OnClickLuckyHandler, self,0))
	
	self.luck_cell_effect = nil

	local eff_pos = self.ph_list["ph_lc_1"]
	self.luck_cell_effect = RenderUnit.CreateEffect(920, self.node_t_list.layout_luky_gift.node, 999, nil, nil, eff_pos.x, eff_pos.y)
	self.luck_cell_effect:setVisible(false)

	self.luck_move_index = 1
	self.luck_loop_num = 0
	self.luck_can_click = true

	-- self.node_t_list.img_charge_reward_state.node:setVisible(false)
	self:CreateCellList()
	self.node_t_list["img9_line"].node:setAnchorPoint(0, 0.5)
end


local turn_count = 0
function LuckGiftView:RefreshView(param_list)
	local data = ActivityBrilliantData.Instance
	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.LKGIFT) or {}
	local config = act_cfg.config or {}

	local item_index = data.item_index
	local cur_item = config.items and config.items[item_index] or {}
	local awards = cur_item.award or {}
	local data_list = {}
	for i,v in ipairs(awards) do
		data_list[#data_list + 1] = ItemData.InitItemDataByCfg(v)
	end
	self.cell_list:SetDataList(data_list)

	-- 居中处理
	self.cell_list:SetCenter()

	for k,v in pairs(param_list) do
		if k == "flush_view" and v.act_id == self.act_id then
			local vis = self.node_t_list["layout_act_auto_hook"]["img_hook"].node:isVisible()
			if v.result and v.result > 2 and (not vis) then
				self.luck_cell_effect:setVisible(true)
				self:CreateLuckyGiftMoveTimer(v.result - 2)
			else
				BagData.Instance:SetDaley(not self.node_t_list.btn_draw.node:isEnabled())
			end
		end
	end

	-- self.node_t_list.img_charge_reward_state.node:setVisible(data.sign[act_cfg.act_id] == 0)
	-- self.node_t_list.img_charge_reward_state.node:setLocalZOrder(999)
	self.node_t_list.btn_lucky_buy.node:setEnabled(data.sign[act_cfg.act_id] ~= 0)
	self.node_t_list.layout_luky_gift.lbl_draw_num.node:setString(data.draw_num)
	self.node_t_list.layout_luky_gift.lbl_gold_num.node:setString(act_cfg.config.items[item_index].money)
	self.node_t_list.layout_luky_gift.lbl_buy_num.node:setString(string.format(Language.ActivityBrilliant.Text5,data.buy_num))
	self.node_t_list.layout_luky_gift.lbl_flush_gold.node:setString(string.format(Language.ActivityBrilliant.Text6,act_cfg.config.params[3]))

	local original_price = cur_item.original_price or 0
	self.node_t_list["lbl_old_gold_num"].node:setString(original_price)
	self.node_t_list["img9_line"].node:setContentWH(80 + string.len(original_price)*10, 7)

	-- 金钱类型图标
	local path = ActivityBrilliantData.GetMoneyTypeIcon(cur_item.money_type)
	self.node_t_list["img_money_type_1"].node:loadTexture(path)
	self.node_t_list["img_money_type_2"].node:loadTexture(path)
end

function  LuckGiftView:CreateGride()
	self.lc_cell_list = {}
	for i = 1, 8 do 
		local cell = ActBaseCell.New()
		local ph = self.ph_list["ph_lc_" .. i]
		cell:SetPosition(ph.x, ph.y)
		cell:SetIndex(i)
		cell:SetAnchorPoint(0.5, 0.5)
		self.node_t_list.layout_luky_gift.node:addChild(cell:GetView(), 300)
		table.insert(self.lc_cell_list, cell)
	end

	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.LKGIFT)
	if act_cfg and act_cfg.config.gifts then	
		for i,v in ipairs(self.lc_cell_list) do
			local data = act_cfg.config.gifts[i]
			v:SetData(ItemData.InitItemDataByCfg(data))
		end
	end
end

function LuckGiftView:CreateCellList()
	local ph = self.ph_list["ph_cell_list"]
	local ph_item = {x = 0, y = 0, w = BaseCell.SIZE, h = BaseCell.SIZE}
	local parent = self.node_t_list["layout_luky_gift"].node
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, ph_item.w + 10, ActBaseCell, ScrollDir.Horizontal, false, ph_item)
	parent:addChild(grid_scroll:GetView(), 99)
	self.cell_list = grid_scroll
end

function LuckGiftView:UpdateNextLuckyFlushTime()
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.LKGIFT)
	if nil == cfg then return end
	local server_time = TimeCtrl.Instance:GetServerTime()
	local flush_time = ActivityBrilliantData.Instance.lucky_flush_time + cfg.config.params[1]
	local next_flush_time = math.floor(flush_time - server_time)
 	local act_id = ACT_ID.LKGIFT
	if next_flush_time <= 0 then
			ActivityBrilliantCtrl.Instance.ActivityReq(3, act_id)
	end
	self.node_t_list.layout_luky_gift.lbl_flush_time.node:setString(TimeUtil.FormatSecond2Str(next_flush_time))
	self.node_t_list.layout_luky_gift.lbl_flush_time.node:setColor(COLOR3B.GREEN)
end

function LuckGiftView:CreateLuckyFlushTimer()
	self.next_lk_flush_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateNextLuckyFlushTime, self), 1)
end

function LuckGiftView:OnClickTurntableHandler()
	local can_draw = ActivityBrilliantData.Instance.draw_num > 0
	self:UpdateAutoDrawTimer(3, can_draw) --每隔1秒抽一次

	if self:TryDrawIgnoreAction(2) then
		self.node_t_list.btn_draw.node:setEnabled(true)
		ItemData.Instance:SetDaley(false)
		return
	end --成功则跳过动画

	self:OnClickLuckyHandler(2)
end

function LuckGiftView:OnClickLuckyHandler(tag)
	ItemData.Instance:SetDaley(true)
	local act_id = ACT_ID.LKGIFT
	if tag == 2 and self.luck_can_click then
		self.luck_cell_effect:setVisible(false)
		if self.node_t_list.btn_draw.node:isEnabled() then
			self:CreateLuckyGiftMoveTimer(1)
		end
   		ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, tag)
		self.luck_can_click = false
	else
		ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, tag)
	end
end

function LuckGiftView:UpdateLuckyGiftTimer(item_index)
	turn_count = turn_count + 1
	if turn_count < self.luck_move_index * self.luck_move_index / 16 then
		return
	end
	self.luck_move_index = self.luck_move_index + 1
	local index = self.luck_move_index % 8
	if index == 0 then
		index = 8
	end
	local ph = self.ph_list["ph_lc_" .. index]
	self.luck_cell_effect:setPosition(ph.x, ph.y)
	if index == item_index and self.luck_move_index > 40 then
		self:DeleteLuckyGiftMoveTimer()
		ItemData.Instance:SetDaley(false)
		local draw_num = ActivityBrilliantData.Instance.draw_num
	end
end


function LuckGiftView:CreateLuckyGiftMoveTimer(item_index)
	if self.luck_move_timer then
		self:DeleteLuckyGiftMoveTimer()
	end
	local num =  ActivityBrilliantData.Instance.draw_num
	self.node_t_list.btn_draw.node:setEnabled(num <= 0)
	turn_count = 0
	self.luck_move_index = 1
	self.luck_loop_num = 0
	self.luck_move_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateLuckyGiftTimer, self, item_index), 0.01)
end


function LuckGiftView:DeleteLuckyGiftMoveTimer()
	if self.luck_move_timer ~= nil then
		GlobalTimerQuest:CancelQuest(self.luck_move_timer)
		self.luck_move_timer = nil
	end

	if self.node_t_list.btn_draw then
		self.node_t_list.btn_draw.node:setEnabled(true)
	end
	
	self.luck_can_click = true
end