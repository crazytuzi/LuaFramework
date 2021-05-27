
NewBuyTip = NewBuyTip or BaseClass(BaseView)

function NewBuyTip:__init()
	if NewBuyTip.Instance then
		ErrorLog("[NewBuyTip] Attemp to create a singleton twice !")
	end
	NewBuyTip.Instance = self

	self.is_async_load = false											-- 是否异步加载
	self.texture_path_list[1] = "res/xui/shangcheng.png"
	self.config_tab = {
		{"itemtip_ui_cfg", 9, {0}}
	}
	self.item_id = nil
	self.item_cell = nil
	self.num_keyboard = nil
	self.item_count = 1
	self.ctrl_str = nil

	self:SetIsAnyClickClose(true)
	self:SetModal(true)
end

function NewBuyTip:__delete()
	NewBuyTip.Instance = nil
end

function NewBuyTip:ReleaseCallBack()
	self.item_count = 1
	self.item_id = nil
	self.item_price_cfg = nil
	self.auto_use = nil
	self.ctrl_str = nil

	if nil ~= self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	if nil ~= self.num_keyboard then
		self.num_keyboard:DeleteMe()
		self.num_keyboard = nil
	end

	if self.way_plst then
		self.way_plst:DeleteMe()
		self.way_plst = nil
	end
end

function NewBuyTip:OpenCallBack()
	
end

function NewBuyTip:CloseCallBack()
	self.item_count = 1
end

function NewBuyTip:LoadCallBack()
	self.itemtips_bg = self.node_t_list.img9_tip_bg.node
	self.layout_content_top = self.node_t_list.layout_item.node
	self:CreateKeyBoard()

	XUI.AddClickEventListener(self.node_t_list.img9_buy_num_bg.node, BindTool.Bind1(self.OnOpenPopNum, self), false)
	XUI.AddClickEventListener(self.node_t_list.btn_minus.node, BindTool.Bind2(self.OnClickChangeNum, self, -1))
	XUI.AddClickEventListener(self.node_t_list.btn_plus.node, BindTool.Bind2(self.OnClickChangeNum, self, 1))
	XUI.AddClickEventListener(self.node_t_list.btn_OK.node, BindTool.Bind1(self.OnClickBuy, self))
	XUI.AddClickEventListener(self.node_t_list.btn_cancel.node, BindTool.Bind1(self.OnClickCancel, self))
	-- self.layout_content_top:setAnchorPoint(0.5, 0)
	self:CreateItemCell()
	self:CreateWayList()
end

function NewBuyTip:ShowIndexCallBack()
	self:Flush()
end

--创建数字键盘
function NewBuyTip:CreateKeyBoard()
	if self.num_keyboard then return end

	self.num_keyboard = NumKeypad.New()
	self.num_keyboard:SetOkCallBack(BindTool.Bind1(self.OnClickEnterNumber, self))
end

function NewBuyTip:OnOpenPopNum()
	if nil ~= self.num_keyboard then
		self.num_keyboard:Open()
		self.num_keyboard:SetText(self.item_count)
		self.num_keyboard:SetMaxValue(self:GetMaxBuyNum())
	end
end

-- 刷新
function NewBuyTip:OnFlush(param_t, index)
	if param_t and param_t.param then
		self.ctrl_str = param_t.param[1]
	end
	if not self.ctrl_str then return end


	local item_t = RichTextUtil.ParseRewardItemTable(self.ctrl_str)
	if item_t and item_t[1] and item_t[1].item_id and tonumber(item_t[1].item_type) then
		self.item_id = ItemData.GetVirtualItemId(tonumber(item_t[1].item_type)) or tonumber(item_t[1].item_id)
	end
	self.item_price_cfg = ShopData.GetItemPriceCfg(self.item_id)
	if nil == self.item_price_cfg then
		Log("商店里面找不到该物品ID")
		return
	end

	local price_type = self.item_price_cfg.price[1].type
	self.node_t_list.img_cost_type.node:loadTexture(ShopData.GetMoneyTypeIcon(price_type))

	if nil == self.item_id then
		Log("You need an item_id !!")
		return
	end

	if not self:ParseWays(self.ctrl_str) then
		Log("Parse ways error !!")
		return
	end
	local count = self.item_price_cfg.buyOnceCount or 1
	local item_config = ItemData.Instance:GetItemConfig(self.item_id)
	local item_data = {item_id = self.item_id, num = count, is_bind = 1}
	self.item_cell:SetData(item_data)

	self.node_t_list.lbl_item_name.node:setString(item_config.name)
	self.node_t_list.lbl_item_name.node:setColor(Str2C3b(string.sub(string.format("%06x", item_config.color), 1, 6)))

	self.item_count = item_t[1].num
	self:RefreshPurchaseView(self.item_count)
end

function NewBuyTip:GetMaxBuyNum()
	if self.item_price_cfg == nil then
		return 1
	end

	local item_price = self.item_price_cfg.price[1].price
	local price_type = self.item_price_cfg.price[1].type
	local obj_attr_index = ShopData.GetMoneyObjAttrIndex(price_type)
	local role_money = RoleData.Instance:GetAttr(obj_attr_index)
	local enough_num = math.floor(role_money / item_price)

	local num = enough_num > 0 and enough_num or 1
	num = num >= 60000 and 60000 or num

	return num
end

function NewBuyTip:OnClickChangeNum(change_num)
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
function NewBuyTip:RefreshPurchaseView(item_count)
	if self.item_price_cfg == nil then
		return
	end

	local item_price = self.item_price_cfg.price[1].price
	self.node_t_list.lbl_num.node:setString(item_count)
	self.node_t_list.label_cost.node:setString(item_count * item_price)
	self.item_count = item_count
	if self.item_id == SettingData.DELIVERY_T[1] or self.item_id == SettingData.DELIVERY_T[2] then
		self.item_cell:SetRightBottomText(item_count * 50)
	end
end

--输入数字
function NewBuyTip:OnClickEnterNumber(num)
	self:RefreshPurchaseView(num)
end

--点击购买
function NewBuyTip:OnClickBuy()
	if self.item_price_cfg == nil then
		return
	end

	--有些物品不需要使用
	local need_auto_use = not ItemData.Instance:GetItemConfig(self.item_id).openUi
	ShopCtrl.BuyItemFromStore(self.item_price_cfg.id, self.item_count, self.item_id, (self.auto_use and need_auto_use) and 1 or 0)
	self.auto_use = nil
	self:Close()
end

function NewBuyTip:OnClickCancel()
	self:Close()
end

-- 解析途径
function NewBuyTip:ParseWays(content)
	content = content or self.ctrl_str
	if not content then return false end

	local temp_t = {}
	local t = Split(content, "}")
	local is_insert = true
	local s
	for i,v in ipairs(t) do
		if i ~= 1 then
			if type(v) == "string" then
				local str = v .. "}"
				s = string.find(str, ";openDayMin#")
				local str_t = RichTextUtil.Parse2Table(str)
				if str_t and str_t[1] then
					is_insert = true
					if s then
						for _, v2 in ipairs(str_t[1]) do
							local day = string.match(v2, "openDayMin#(%d)")
							if day then
								is_insert = OtherData.Instance:GetOpenServerDays() >= tonumber(day)
								break
							end
						end
					end
					if is_insert then
						table.insert(temp_t,str_t[1])
					end
				end
			end
		end
	end

	if self.way_plst then 
		-- 列表高度不超过350
		local items_interval = self.way_plst:GetView():getItemsInterval()
		local item_num = #temp_t
		local way_hig = math.min(350, item_num * self.ph_list.ph_way_item.h + (item_num - 1) * items_interval)
		if item_num > 0 then
			self.way_plst:SetDataList(temp_t)
		end
		-- self.way_plst:GetView():setVisible(item_num > 0)
		-- self.way_plst:GetView():setContentWH(self.ph_list.ph_way_item.w, way_hig)
		-- self.way_plst:GetView():setPosition(self.ph_list.ph_way_item.w / 2 + 23, 25)

		-- -- 界面总高度 = 350 + 列表高度 + 列表上下空位
		-- local item_tips_h = 310 + way_hig + 20 * 2
		-- self.itemtips_bg:setContentWH(477, item_tips_h)
		-- self.itemtips_bg:setPositionY(item_tips_h / 2)
		-- self:GetRootNode():setContentWH(477, item_tips_h)

		-- self.layout_content_top:setAnchorPoint(0.5, 1)
		-- self.layout_content_top:setPositionY(item_tips_h + 80)
	end
	return true
end

function NewBuyTip:SetItemId(item_id)
	self.item_id = item_id
	self:Flush()
end

-- 创建途径列表
function NewBuyTip:CreateWayList()
	if not self.way_plst then
		self.way_plst = ListView.New()
		self.way_plst:Create(self.ph_list.ph_way_item.w / 2 +10, 30, self.ph_list.ph_way_item.w, 150, ScrollDir.Vertical, NewBuyTipWayRender, nil, nil, self.ph_list.ph_way_item)
		self.way_plst:SetItemsInterval(8)
		self.way_plst:SetJumpDirection(ListView.Top)
		self.way_plst:GetView():setAnchorPoint(0.5, 0)
		--self.way_plst:GetView():setClippingEnabled(false)
		self.node_t_list.layout_new_buytip.node:addChild(self.way_plst:GetView(), 100)
	end
end

--创建物品格子
function NewBuyTip:CreateItemCell()
	if self.item_cell then return end

	local item_cell = BaseCell.New()
	item_cell:SetPosition(self.ph_list.ph_cell.x, self.ph_list.ph_cell.y)
	item_cell:SetCellBg(ResPath.GetCommon("cell_100"))
	-- item_cell:GetCell():setAnchorPoint(0.5, 0.5)
	item_cell:SetIsShowTips(true)
	self.node_t_list.layout_item.node:addChild(item_cell:GetCell(), 200, 200)
	self.item_cell = item_cell
end

-- 设置一次购买并使用
function NewBuyTip:SetOnceAutoUse(auto_use)
	self.auto_use = auto_use and 1 or 0
end

------------------------------------------
-- NewBuyTipWayRender
------------------------------------------
NewBuyTipWayRender = NewBuyTipWayRender or BaseClass(BaseRender)
function NewBuyTipWayRender:__init()
	self:AddClickEventListener(BindTool.Bind(self.OnClickRender, self), true)
	self.view:setHittedScale(1.03)
	self.onclick_func = nil
end

function NewBuyTipWayRender:__delete()
	self.onclick_func = nil

	if self.moveto_alert then
		self.moveto_alert:DeleteMe()
		self.moveto_alert = nil
	end
end

function NewBuyTipWayRender:CreateChild()
	BaseRender.CreateChild(self)
	self.rich_text = self.node_tree.rich_way and self.node_tree.rich_way.node
	XUI.AddClickEventListener(self.node_tree.layout_move_to.node, BindTool.Bind(self.OnClickRender, self), true)
end

function NewBuyTipWayRender:OnFlush()
	if not self.data or not self.rich_text then return end
	self.rich_text:removeAllElements()
	if self.data[1] == "moveto" then
		self:ParseWayMoveTo()
	elseif self.data[1] == "viewLink" then
		self:ParseWayViewLink()
	else
	end
end

function NewBuyTipWayRender:SetOnClickFunc(func)
	self.onclick_func = func
end

function NewBuyTipWayRender:OnClickRender()
	if self.onclick_func then
		self.onclick_func()
	end
end

function NewBuyTipWayRender:ParseWayMoveTo(font_size, color, text_attr)
	font_size = font_size or 20
	color = color or COLOR3B.GREEN
	if #self.data < 3 or not self.rich_text then return end
	RichTextUtil.ParseRichText(self.rich_text, self.data[3], 20, COLOR3B.GREEN)
	if nil == self.moveto_alert then
		self.moveto_alert = self.moveto_alert or Alert.New()
		local ok_func = function()
			MoveCache.end_type = MoveEndType.Normal
			GuajiCtrl.Instance:FlyByIndex(tonumber(self.data[2]))
			ViewManager.Instance:CloseAllView()
		end

		self.moveto_alert:SetOkFunc(ok_func)
		self.moveto_alert:SetLableString(Language.Shop.BuyTipMoveTo)
		self.moveto_alert:SetCancelString(Language.Common.Cancel)
		self.moveto_alert:SetOkString(Language.Common.Confirm)
	end

	self:SetOnClickFunc(function()
		self.moveto_alert:Open()
	end)
end

function NewBuyTipWayRender:ParseWayViewLink(font_size, color, text_attr)
	font_size = font_size or 20
	color = color or COLOR3B.GREEN
	if #self.data < 3 or not self.rich_text then return end
	local view_param = self.data[2] or ""
	local link_name = self.data[3] or ""
	RichTextUtil.ParseRichText(self.rich_text, link_name, font_size, color, text_attr)

	self:SetOnClickFunc(function()
		ViewManager.Instance:CloseAllView()
		ViewManager.Instance:OpenViewByStr(view_param)
	end)
end

function NewBuyTipWayRender:CreateSelectEffect()
end