OpenActivityBuy = OpenActivityBuy or BaseClass(XuiBaseView)

function OpenActivityBuy:__init()
	if OpenActivityBuy.Instance then
		ErrorLog("[OpenActivityBuy] Attemp to create a singleton twice !")
	end
	OpenActivityBuy.Instance = self

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

function OpenActivityBuy:__delete()
	OpenActivityBuy.Instance = nil
end

function OpenActivityBuy:ReleaseCallBack()
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

function OpenActivityBuy:OpenCallBack()
	
end

function OpenActivityBuy:CloseCallBack()
	self.item_count = 1
end

function OpenActivityBuy:LoadCallBack()
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

function OpenActivityBuy:ShowIndexCallBack()
	self:Flush()
end

function OpenActivityBuy:OnFlush(param_t, index)
	if param_t.param then
		self.data = param_t.param[1]
		-- if self.data.dayLimitCount ~= 0 then
		-- 	self.max_cnt = self.data.dayLimitCount - self.data.bought_time
		-- else
		-- 	self.max_cnt = Language.Common.NoLimit
		-- end
		self.item_id = tonumber(self.data.item.item_id)
	end

	-- PrintTable(self.data)

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

	-- local award_type = 3--self.data.consumes[1].type
	-- if RoleData.GetMoneyTypeIconByAwarType(award_type) then
	self.node_t_list.img_cost_type.node:loadTexture(ResPath.GetCommon("gold"))
	self.node_t_list.img_maxyb_type.node:loadTexture(ResPath.GetCommon("gold"))
	-- end

	local item_data = {item_id = self.item_id, num = 0, is_bind = 0}
	self.item_cell:SetData(item_data)

	self.node_t_list.lbl_item_name.node:setString(item_config.name)
	self.node_t_list.lbl_item_name.node:setColor(Str2C3b(string.sub(string.format("%06x", item_config.color), 1, 6)))

	if item_config.dup ~= 0 then
		self.node_t_list.txt_dup.node:setString(item_config.dup)
	else
		self.node_t_list.txt_dup.node:setString(1)
	end
	self.node_t_list.label_cost.node:setString(self.data.now_price)
	self:RefreshPurchaseView(self.item_count)

end

function OpenActivityBuy:SetItemId(item_id)
	self.item_id = item_id
	self:Flush()
end

--创建物品格子
function OpenActivityBuy:CreateItemCell()
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
function OpenActivityBuy:CreateKeyBoard()
	if self.num_keyboard then return end

	self.num_keyboard = NumKeypad.New()
	self.num_keyboard:SetOkCallBack(BindTool.Bind1(self.OnClickEnterNumber, self))
end

function OpenActivityBuy:GetMaxBuyNum()
	if self.data == nil then
		return 1
	end
	local enough_num = 0
	-- if "string" == type(self.max_cnt) then
		local item_price = self.data.now_price
		local award_type = 3--self.data.consumes[1].type
		local obj_attr_index = RoleData.Instance:GetAttrKey(tagAwardType.qatYuanbao)
		local role_money = RoleData.Instance:GetAttr(obj_attr_index)
		enough_num = math.floor(role_money / item_price)
		-- print(self.data.rest_buy_time, enough_num)
	-- end

	return self.data.rest_buy_time > (enough_num > 0 and enough_num or 1) and (enough_num > 0 and enough_num or 1)  or self.data.rest_buy_time
end

function OpenActivityBuy:OnOpenPopNum()
	if nil ~= self.num_keyboard then
		self.num_keyboard:Open()
		self.num_keyboard:SetText(self.item_count)
		self.num_keyboard:SetMaxValue(self:GetMaxBuyNum())
	end
end

function OpenActivityBuy:OnClickChangeNum(change_num)
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
function OpenActivityBuy:RefreshPurchaseView(item_count)
	if self.data == nil then
		return
	end

	local item_price = self.data.now_price
	self.node_t_list.lbl_num.node:setString(item_count)
	self.node_t_list.txt_money.node:setString(item_count * item_price)
	self.item_count = item_count
end

--输入数字
function OpenActivityBuy:OnClickEnterNumber(num)
	self:RefreshPurchaseView(num)
end

--点击购买
function OpenActivityBuy:OnClickBuy()
	if self.data == nil then
		return
	end
	OpenServiceAcitivityCtrl.Instance:OpenServerSuperGPurOperate(self.data.idx, 1, self.item_count)
	self:Close()
end

function OpenActivityBuy:OnClickCancel()
	self:Close()
end

function OpenActivityBuy:OnClose()
	self:Close()
end

function OpenActivityBuy:ItemConfigCallBack(item_config_t)
	for k,v in pairs(item_config_t) do
		if v.item_id == self.item_id then
			self:Flush()
			ItemData.Instance:UnNotifyItemConfigCallBack(self.item_config_bind)
			self.on_cfg_listen = false
			break
		end
	end
end