-- 运营活动-秘钥宝藏
OperateActSecretKeyTreasure = OperateActSecretKeyTreasure or BaseClass()

function OperateActSecretKeyTreasure:__init()
	self.view = nil
end

function OperateActSecretKeyTreasure:__delete()
	self:RemoveEvent()

	if self.secret_key_dlg then
		self.secret_key_dlg:DeleteMe()
		self.secret_key_dlg = nil
	end

	if self.grid_scroll then
		self.grid_scroll:DeleteMe()
		self.grid_scroll = nil
	end

	if self.line_awards_list then
		for k, v in pairs(self.line_awards_list) do
			v:DeleteMe()
		end
		self.line_awards_list = nil
	end

	if self.evt_list then
		self.evt_list:DeleteMe()
		self.evt_list = nil
	end

	if self.secret_award_list then
		self.secret_award_list:DeleteMe()
		self.secret_award_list = nil
	end

	if self.num_key_pad then
		self.num_key_pad:DeleteMe()
		self.num_key_pad = nil
	end
	self.chose_num = 0
	self.view = nil
end


function OperateActSecretKeyTreasure:InitPage(view)
	self.view = view
	self.chose_num = 0

	self.big_award_wnd = self.view.node_t_list.layout_secret_key_big_award.node
	self.big_award_wnd:setLocalZOrder(300)
	self.big_award_wnd:setTouchEnabled(true)
	self.big_award_wnd:setVisible(false)
	self.evt_wnd = self.view.node_t_list.layout_secret_key_evt.node
	self.evt_wnd:setVisible(false)
	self.evt_wnd:setLocalZOrder(300)
	self.evt_wnd:setTouchEnabled(true)

	self.modal_layout = self.view.node_t_list.layout_secret_modal.node
	self.modal_layout:setBackGroundColor(COLOR3B.BLACK)
	self.modal_layout:setBackGroundColorOpacity(0)
	self:CreateChildControls()

	self:InitEvent()
end

--初始化事件
function OperateActSecretKeyTreasure:InitEvent()
	-- self.view.node_t_list.btn_secret_key_tip.node:setVisible(false)
	XUI.AddClickEventListener(self.modal_layout, BindTool.Bind(self.OnModalLayoutClick, self))
	XUI.AddClickEventListener(self.view.node_t_list.btn_secret_key_dinchou.node, BindTool.Bind(self.OnDinChouNum, self), true)
	XUI.AddClickEventListener(self.view.node_t_list.btn_secret_key_chouqu.node, BindTool.Bind(self.OnChouQuNum, self), true)
	XUI.AddClickEventListener(self.view.node_t_list.btn_secret_key_input_num.node, BindTool.Bind(self.OnInputNumDinChou, self), false)

	XUI.AddClickEventListener(self.view.node_t_list.btn_secret_key_check_event.node, BindTool.Bind(self.OnOpenSmallWndByType, self, 1), true)
	XUI.AddClickEventListener(self.view.node_t_list.btn_secret_key_secret_awar.node, BindTool.Bind(self.OnOpenSmallWndByType, self, 2), true)

	XUI.AddClickEventListener(self.view.node_t_list.btn_big_award_close_window.node, BindTool.Bind(self.OnBigAwardClose, self), true)
	XUI.AddClickEventListener(self.view.node_t_list.btn_secret_evt_close_window.node, BindTool.Bind(self.OnSecretEvtClose, self), true)

	XUI.AddClickEventListener(self.view.node_t_list.btn_secret_key_tip.node,BindTool.Bind(self.OnHelp,self),true)

	self.secret_key_data_change_evt = GlobalEventSystem:Bind(OperateActivityEventType.SECRET_KEY_TREASURE_DATA, BindTool.Bind(self.OnSecretKeyDataChange, self))
	self.chouqu_handler = BindTool.Bind(self.ReqChouQu, self)
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushTime, self), 1)
end

--移除事件
function OperateActSecretKeyTreasure:RemoveEvent()
	if self.secret_key_data_change_evt then
		GlobalEventSystem:UnBind(self.secret_key_data_change_evt)
		self.secret_key_data_change_evt = nil
	end

	self.chouqu_handler = nil

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end

end

-- 刷新
function OperateActSecretKeyTreasure:UpdateData(param_t)
	self:FlushTime()
	self:SetSmallWndsVisible(false)
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.SECRET_KEY_TREASURE)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActData(cmd_id, OPERATE_ACTIVITY_ID.SECRET_KEY_TREASURE)
	end
	-- self:OnSecretKeyDataChange()
	self.view.node_t_list.txt_secret_key_chose_num.node:setString(Language.OperateActivity.SecretKeyTreasureInput)
end

function OperateActSecretKeyTreasure:CreateChildControls()
	if not self.grid_scroll then
		local ph = self.view.ph_list.ph_secret_key_grid
		self.grid_scroll = GridScroll.New()
		self.grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 7, 58, OperateActSecretKeyNumRender, ScrollDir.Vertical, false, self.view.ph_list.ph_secret_key_num_item)
		self.view.node_t_list.layout_serect_key_treasure.node:addChild(self.grid_scroll:GetView(), 10)
	end

	self.line_awards_list = {}
	local ui_config = self.view.ph_list.ph_line_awar_item_1
	for i = 1, 16 do
		local ph = self.view.ph_list["ph_line_awar_item_" .. i]
		local item = OperateActSecretKeyLineAwardRender.New()
		item:SetUiConfig(ui_config, true)
		item:SetIndex(i)
		item:SetPosition(ph.x, ph.y)
		self.view.node_t_list.layout_serect_key_treasure.node:addChild(item:GetView(), 10)
		self.line_awards_list[i] = item
	end

	self.num_key_pad = NumKeypad.New(2, 49)
	self.key_pad_ok_func = BindTool.Bind(self.OnKeyPadOkCallback, self)
	self.num_key_pad:SetOkCallBack(self.key_pad_ok_func)

	if self.evt_list == nil then
		self.evt_list = ListView.New()
		local ph = self.view.ph_list.ph_secret_key_evt_list
		self.evt_list:Create(ph.x, ph.y, ph.w, ph.h, direction, SecretKeyEvtRender, gravity, is_bounce, self.view.ph_list.ph_secret_evt_item)
		self.evt_list:SetMargin(2)
		self.evt_list:SetItemsInterval(5)
		self.evt_wnd:addChild(self.evt_list:GetView(), 10)
	end

	if self.secret_award_list == nil then
		self.secret_award_list = ListView.New()
		local ph = self.view.ph_list.ph_secret_key_big_award_list
		self.secret_award_list:Create(ph.x, ph.y, ph.w, ph.h, direction, SecretKeySecretAwardRender, gravity, is_bounce, self.view.ph_list.ph_secret_big_award_item)
		self.secret_award_list:SetMargin(2)
		self.secret_award_list:SetItemsInterval(5)
		self.big_award_wnd:addChild(self.secret_award_list:GetView(), 10)
	end

end

function OperateActSecretKeyTreasure:SetShowInfo()
	-- self.chose_num = 0
	-- self.view.node_t_list.txt_secret_key_chose_num.node:setString(self.chose_num)
	local cur_num = OperateActivityData.Instance:GetSecretKeyCurNum()
	self.view.node_t_list.txt_secret_key_cur_num.node:setString(cur_num)
	local score = OperateActivityData.Instance:GetSecretkeyScore()
	self.view.node_t_list.txt_secret_key_score.node:setString(score)
	local use_cnt = OperateActivityData.Instance:GetSecretkeyUsedCnt()
	local get_cnt = OperateActivityData.Instance:GetSecretkeyGetCnt()
	-- local buy_cnt = OperateActivityData.Instance:GetSecretkeyBuyCnt()
	-- get_cnt = get_cnt + buy_cnt
	local use_str = use_cnt .. "/" .. get_cnt
	self.view.node_t_list.txt_secret_key_use_time.node:setString(use_str)

	local data = OperateActivityData.Instance:GetSerectKeyNumPoolData()
	self.grid_scroll:SetDataList(data)

	local line_award_data = OperateActivityData.Instance:GetSecretKeyLineAwardData()
	for k, v in ipairs(line_award_data) do
		if self.line_awards_list[k] then
			self.line_awards_list[k]:SetData(v)
		end
	end

	local evt_data = OperateActivityData.Instance:GetSecretKeyEventData()
	-- PrintTable(evt_data)
	self.evt_list:SetData(evt_data)
	local secret_awar_data = OperateActivityData.Instance:GetSecretKeyLineAchieveData()
	-- PrintTable(secret_awar_data)
	self.secret_award_list:SetData(secret_awar_data)

end

function OperateActSecretKeyTreasure:FlushTime()
	local time_str = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.SECRET_KEY_TREASURE)
	if time_str == "" then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
		return
	end

	if self.view.node_t_list.txt_secret_key_rest_time then
		self.view.node_t_list.txt_secret_key_rest_time.node:setString(time_str)
	end

end

function OperateActSecretKeyTreasure:OnKeyPadOkCallback(input_num)
	self.chose_num = input_num
	self.view.node_t_list.txt_secret_key_chose_num.node:setString(self.chose_num)

	-- local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.SECRET_KEY_TREASURE)
	-- if cmd_id then
	-- 	if self.chose_num > 0 then
	-- 		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.SECRET_KEY_TREASURE, self.chose_num, 2, 0)
	-- 	else
	-- 		SystemHint.Instance:FloatingTopRightText(Language.OperateActivity.SecretKeyTreasureInputError)
	-- 	end
	-- end
end

function OperateActSecretKeyTreasure:OnSecretKeyDataChange()
	self:SetShowInfo()
end

-- 定抽
function OperateActSecretKeyTreasure:OnDinChouNum()
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.SECRET_KEY_TREASURE)
	if cmd_id then
		-- if self.chose_num > 0 then
			OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.SECRET_KEY_TREASURE, self.chose_num, 2, 0)
		-- else
		-- 	SystemHint.Instance:FloatingTopRightText(Language.OperateActivity.SecretKeyTreasureInputError)
		-- end
	end
end

-- 抽取数字
function OperateActSecretKeyTreasure:OnChouQuNum()
	local can_buy = OperateActivityData.Instance:GetSecretkeyCanBuy()
	if can_buy == 1 then
		local get_cnt = OperateActivityData.Instance:GetSecretkeyGetCnt()
		local buy_cnt = OperateActivityData.Instance:GetSecretkeyBuyCnt()
		local used_cnt = OperateActivityData.Instance:GetSecretkeyUsedCnt()
		if used_cnt >= get_cnt then
			if self.secret_key_dlg == nil then
				self.secret_key_dlg = Alert.New()
				self.secret_key_dlg:SetOkFunc(self.chouqu_handler)
			end
			local cfg = OperateActivityData.Instance:GetSecretKeyTreasureCfg()
			local first_buy = cfg.first_buy_cost
			local per_add_cost = cfg.per_buy_add_cost
			local buy_cnt = OperateActivityData.Instance:GetSecretkeyBuyCnt()
			local money = first_buy + buy_cnt * per_add_cost
			local str = string.format(Language.OperateActivity.SecretKeyTreasureCostMoney, money)
			self.secret_key_dlg:SetLableString(str)
			self.secret_key_dlg:Open()
			return
		end
	end

	self:ReqChouQu()
	
end

function OperateActSecretKeyTreasure:ReqChouQu()
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.SECRET_KEY_TREASURE)
	if cmd_id then
		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.SECRET_KEY_TREASURE, self.index, 1, 0)
	end
end

-- 输入数字定抽
function OperateActSecretKeyTreasure:OnInputNumDinChou()
	-- local cost_score = OperateActivityData.Instance:GetSecretKeyTreasureCfg().chose_num_cost
	-- local own_score = OperateActivityData.Instance:GetSecretkeyScore()
	-- if own_score >= cost_score then
		self.num_key_pad:Open()	
	-- else
	-- 	SystemHint.Instance:FloatingTopRightText(Language.OperateActivity.SecretKeyTreasureLackScore)
	-- end
end

function OperateActSecretKeyTreasure:SetSmallWndsVisible(visible, open_type)
	self.modal_layout:setTouchEnabled(visible)
	if visible then
		if open_type then
			self.evt_wnd:setVisible(open_type == 1)
			self.big_award_wnd:setVisible(open_type == 2)
		end
		self.modal_layout:setBackGroundColorOpacity(100)
	else
		self.evt_wnd:setVisible(false)
		self.big_award_wnd:setVisible(false)
		self.modal_layout:setBackGroundColorOpacity(0)
	end
end

-- 查看事件或秘钥奖励(open_type: 1事件 2秘钥奖励)
function OperateActSecretKeyTreasure:OnOpenSmallWndByType(open_type)
	self:SetSmallWndsVisible(true, open_type)
end

-- 隐藏秘钥大奖面版
function OperateActSecretKeyTreasure:OnBigAwardClose()
	self:SetSmallWndsVisible(false)
end

-- 隐藏事件面板
function OperateActSecretKeyTreasure:OnSecretEvtClose()
	self:SetSmallWndsVisible(false)
end

function OperateActSecretKeyTreasure:OnModalLayoutClick()
	self:SetSmallWndsVisible(false)
end

--帮助点击
function OperateActSecretKeyTreasure:OnHelp()
	DescTip.Instance:SetContent(Language.OperateActivity.Content[3] or Language.OperateActivity.Content[1], Language.OperateActivity.Title[1])
end	