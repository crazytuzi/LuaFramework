
NPCBuy = NPCBuy or BaseClass(XuiBaseView)

function NPCBuy:__init()
	if NPCBuy.Instance then
		ErrorLog("[NPCBuy] Attemp to create a singleton twice !")
	end
	NPCBuy.Instance = self

	self.config_tab = {
		{"itemtip_ui_cfg", 7, {0}}
	}
	self.item_id = nil
	self.item_cell = nil
	self.num_keyboard = nil
	self.item_count = 1
	self.on_cfg_listen = false
	self.item_config_bind = BindTool.Bind(self.ItemConfigCallBack, self)
	self.data = nil
	self.max_cnt = 0
	self:SetIsAnyClickClose(true)
	self:SetModal(true)
end

function NPCBuy:__delete()
	NPCBuy.Instance = nil
end

function NPCBuy:ReleaseCallBack()
	self.item_count = 1
	self.item_id = nil
	self.data = nil
	self.on_cfg_listen = false

	if nil ~= self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	if nil ~= self.num_keyboard then
		self.num_keyboard:DeleteMe()
		self.num_keyboard = nil
	end

	if ItemData.Instance then
		ItemData.Instance:UnNotifyItemConfigCallBack(self.item_config_bind)
	end

	ClientCommonButtonDic[CommonButtonType.NPC_BUY_BUY_BTN] = nil
end

function NPCBuy:OpenCallBack()
	
end

function NPCBuy:CloseCallBack()
	self.item_count = 1
end

function NPCBuy:LoadCallBack()
	self:CreateItemCell()
	self:CreateKeyBoard()

	XUI.AddClickEventListener(self.node_t_list.img9_buy_num_bg.node, BindTool.Bind1(self.OnOpenPopNum, self), false)
	XUI.AddClickEventListener(self.node_t_list.btn_minus.node, BindTool.Bind2(self.OnClickChangeNum, self, -1))
	XUI.AddClickEventListener(self.node_t_list.btn_plus.node, BindTool.Bind2(self.OnClickChangeNum, self, 1))
	XUI.AddClickEventListener(self.node_t_list.btn_OK.node, BindTool.Bind1(self.OnClickBuy, self))
	XUI.AddClickEventListener(self.node_t_list.btn_cancel.node, BindTool.Bind1(self.OnClickCancel, self))
	XUI.AddClickEventListener(self.node_t_list.btn_close.node, BindTool.Bind1(self.OnClose, self))


	ClientCommonButtonDic[CommonButtonType.NPC_BUY_BUY_BTN] = self.node_t_list.btn_OK.node
end

function NPCBuy:ShowIndexCallBack()
	self:Flush()
end

function NPCBuy:OnFlush(param_t, index)
	if param_t.param then
		self.data = param_t.param[1]
		-- if self.data.dayLimitCount ~= 0 then
		-- 	self.max_cnt = self.data.dayLimitCount - self.data.bought_time
		-- else
		-- 	self.max_cnt = Language.Common.NoLimit
		-- end
		self.item_id = tonumber(self.data.itemId)
	end

	if nil == self.item_id then
		Log("You need an item_id !!")
		return
	end
	if not self.data then return end

	local item_config = ItemData.Instance:GetItemConfig(self.item_id)
	if nil == item_config then
		if self.on_cfg_listen == false then
			ItemData.Instance:NotifyItemConfigCallBack(self.item_config_bind)
			self.on_cfg_listen = true
		end
		return
	end

	local award_type = self.data.consumes[1].type
	if RoleData.GetMoneyTypeIconByAwarType(award_type) then
		self.node_t_list.img_cost_type.node:loadTexture(RoleData.GetMoneyTypeIconByAwarType(award_type))
		self.node_t_list.img_maxyb_type.node:loadTexture(RoleData.GetMoneyTypeIconByAwarType(award_type))
	end

	local item_data = {item_id = self.item_id, num = 0, is_bind = 0}
	self.item_cell:SetData(item_data)

	self.node_t_list.lbl_item_name.node:setString(item_config.name)
	self.node_t_list.lbl_item_name.node:setColor(Str2C3b(string.sub(string.format("%06x", item_config.color), 1, 6)))

	if item_config.dup ~= 0 then
		self.node_t_list.txt_dup.node:setString(item_config.dup)
	else
		self.node_t_list.txt_dup.node:setString(1)
	end
	self.node_t_list.label_cost.node:setString(self.data.consumes[1].count)
	self:RefreshPurchaseView(self.item_count)

end

function NPCBuy:SetItemId(item_id)
	self.item_id = item_id
	self:Flush()
end

--创建物品格子
function NPCBuy:CreateItemCell()
	if self.item_cell then return end

	local item_cell = BaseCell.New()
	item_cell:SetPosition(self.ph_list.ph_cell.x, self.ph_list.ph_cell.y)
	item_cell:SetCellBg(ResPath.GetCommon("cell_100"))
	--item_cell:GetCell():setAnchorPoint(0.5, 0.5)
	item_cell:SetIsShowTips(true)
	self.node_t_list.layout_quick_buy.node:addChild(item_cell:GetCell(), 200, 200)
	self.item_cell = item_cell
end

--创建数字键盘
function NPCBuy:CreateKeyBoard()
	if self.num_keyboard then return end

	self.num_keyboard = NumKeypad.New()
	self.num_keyboard:SetOkCallBack(BindTool.Bind1(self.OnClickEnterNumber, self))
end

function NPCBuy:GetMaxBuyNum()
	if self.data == nil then
		return 1
	end
	local enough_num = 0
	-- if "string" == type(self.max_cnt) then
		local item_price = self.data.consumes[1].count
		local award_type = self.data.consumes[1].type
		local obj_attr_index = RoleData:GetAttrKey(award_type)
		local role_money = RoleData.Instance:GetAttr(obj_attr_index)
		enough_num = math.floor(role_money / item_price)
	-- end

	return enough_num > 0 and enough_num or 1
end

function NPCBuy:OnOpenPopNum()
	if nil ~= self.num_keyboard then
		self.num_keyboard:Open()
		self.num_keyboard:SetText(self.item_count)
		self.num_keyboard:SetMaxValue(self:GetMaxBuyNum())
	end
end

function NPCBuy:OnClickChangeNum(change_num)
	local num = self.item_count + change_num

	if num < 1 then
		return
	end

	if num > self:GetMaxBuyNum() then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Common.MaxValue)
		return
	end

	self.item_count = num
	self:RefreshPurchaseView(self.item_count)
end

--刷新购买版界面
function NPCBuy:RefreshPurchaseView(item_count)
	if self.data == nil then
		return
	end

	local item_price = self.data.consumes[1].count
	self.node_t_list.lbl_num.node:setString(item_count)
	self.node_t_list.txt_money.node:setString(item_count * item_price)
	self.item_count = item_count
end

--输入数字
function NPCBuy:OnClickEnterNumber(num)
	self:RefreshPurchaseView(num)
end

--点击购买
function NPCBuy:OnClickBuy()
	if self.data == nil then
		return
	end
	local item_id = self.data.itemId
	BagCtrl.Instance:SendBuyItem(0, item_id, self.item_count)
	self:Close()

	if TaskCtrl.Instance.npc_obj_id and TaskCtrl.Instance.npc_obj_id ~= 0 then
		TaskCtrl.SendNpcTalkReq(TaskCtrl.Instance.npc_obj_id, "")
	end
end

function NPCBuy:OnClickCancel()
	self:Close()
end

function NPCBuy:OnClose()
	self:Close()
end

function NPCBuy:ItemConfigCallBack(item_config_t)
	for k,v in pairs(item_config_t) do
		if v.item_id == self.item_id then
			self:Flush()
			ItemData.Instance:UnNotifyItemConfigCallBack(self.item_config_bind)
			self.on_cfg_listen = false
			break
		end
	end
end