TipsCommonBuyView = TipsCommonBuyView or BaseClass(BaseView)
TipsCommonBuyView.AUTO_LIST = {}
function TipsCommonBuyView:__init()
	self.ui_config = {"uis/views/tips/commontips", "CommonBuyTip"}
	self:SetMaskBg(true)
	self.view_layer = UiLayer.Pop
	self.ok_func = nil
	self.item_id = nil
	self.need_sprice = 0
	self.play_audio = true
	self.cell_list = {}
	self.init_quick = true
	self.is_first = false
end

function TipsCommonBuyView:LoadCallBack()
	self:ListenEvent("OnClickCloseButton",
		BindTool.Bind(self.OnClickCloseButton, self))
	self:ListenEvent("OnClickBuyButton",
		BindTool.Bind(self.OnClickBuyButton, self))
	self:ListenEvent("OnClickGold",
		BindTool.Bind(self.OnClickGold, self))
	self:ListenEvent("OnClickBindGold",
		BindTool.Bind(self.OnClickBindGold, self))
	self:ListenEvent("OnClickPlus",
		BindTool.Bind(self.OnClickPlus, self))
	self:ListenEvent("OnClickReduce",
		BindTool.Bind(self.OnClickReduce, self))
	self:ListenEvent("OnClickInputField",
		BindTool.Bind(self.OnClickInputField, self))

	self.pro_desc = self:FindVariable("PropDesc")
	self.pro_name = self:FindVariable("PropName")
	self.have_pro_num = self:FindVariable("HaveProNum")
	self.buy_num = self:FindVariable("BuyNum")
	self.sum_price = self:FindVariable("BuySumPrice")
	self.pro_name_color = self:FindVariable("ProNameColor")
	self.diamon_image = self:FindVariable("Diamon")
	self.show_right = self:FindVariable("ShowRight")

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.use_gold = self:FindObj("UseGold")
	self.use_bind = self:FindObj("UseBind")
	self.input_text = self:FindObj("InputText")

	self.cur_num = 1
	self.max_num = 1
	self.input_text.input_field.text = 0
	self:Flush()
end

function TipsCommonBuyView:ReleaseCallBack()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	-- 清理变量和对象
	self.pro_desc = nil
	self.pro_name = nil
	self.have_pro_num = nil
	self.buy_num = nil
	self.sum_price = nil
	self.pro_name_color = nil
	self.use_gold = nil
	self.use_bind = nil
	self.input_text = nil
	self.diamon_image = nil
	self.show_right = nil
	self.discount_list = nil
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	self.init_quick = true
end

function TipsCommonBuyView:CloseCallBack()
	self.ok_func = nil
	self.item_id = nil
	self.no_func = nil
	self.max_num = nil
	self.init_quick = true
end

function TipsCommonBuyView:OnClickCloseButton()
	if self.no_func ~= nil then
		self.no_func()
	end
	self:Close()
end

function TipsCommonBuyView:SetInputText(str)
	self.input_text.input_field.text = str
	self.cur_num = str
	self:Flush()
end

function TipsCommonBuyView:OnClickGold()
	self:Flush()
end

function TipsCommonBuyView:OnClickBindGold()
	self:Flush()
end

function TipsCommonBuyView:OnClickInputField()
	local ok_func = function (cur_str)
		self:SetCommonBuyViewText(cur_str)
	end
	local cancle_func = function ()
		self:SetCommonBuyViewText(self.cur_num)
	end
	TipsCtrl.Instance:OpenCommonInputView(self.cur_num, ok_func, cancle_func, self.max_num)
end

function TipsCommonBuyView:SetCommonBuyViewText(cur_str)
	self.input_text.input_field.text = tonumber(cur_str)
	self.cur_num = tonumber(cur_str)
	if self.need_num then
		self.need_num = tonumber(cur_str)
	end
	self:Flush()
end

function TipsCommonBuyView:OnClickPlus()
	local shop_item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[self.item_id]
	if shop_item_cfg == nil then
		--print("商店配置中没有该物品", self.item_id)
		return
	end
	if tonumber(self.input_text.input_field.text) >= self.max_num then
		return
	end
	self.cur_num = tonumber(self.input_text.input_field.text) + 1
	self.buy_num:SetValue(self.cur_num)
	if self.need_num then
		self.need_num = self.need_num + 1
	end
	self:Flush()
end

function TipsCommonBuyView:OnClickReduce()
	if self.input_text.input_field.text <= tostring(0) or self.input_text.input_field.text == "" then
		return
	end
	local num = tonumber(self.input_text.input_field.text)
	if (num - 1) <= 0 then
		return
	end
	self.cur_num = tonumber(self.input_text.input_field.text) - 1
	self.buy_num:SetValue(self.cur_num)
	if self.need_num then
		self.need_num = self.need_num - 1
	end
	self:Flush()
end

function TipsCommonBuyView:OnClickBuyButton()
	local is_bind = 0
	local item_cfg = ItemData.Instance:GetItemConfig(self.item_id)
	if self.ok_func ~= nil then
		--print_log("点击购买按钮，执行购买", self.cur_num)
		if self.need_sprice <= PlayerData.Instance.role_vo.bind_gold then
			local shop_cfg = ShopData:GetShopItemCfg(self.item_id)
			if shop_cfg.bind_gold > 0 then
				is_bind = 1
			end
		end
		local is_buy_quick = false
		if self.use_bind.toggle.isOn and self.init_quick then
			is_buy_quick = true   --绑定参数用于是否自动购买（无论是否绑定，服务端都优先使用绑钻）
		end
		self.ok_func(self.item_id, self.cur_num, is_bind, item_cfg.is_tip_use, is_buy_quick )
	end
	if self.item_id and self.item_id > 0 then
		TipsCommonBuyView.AUTO_LIST[self.item_id] = self.use_bind.toggle.isOn
	end
	self:Close()
end

function TipsCommonBuyView:SetCallBack(callback, item_id, no_func, need_num, init_quick)
	local shop_item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[item_id]
	if shop_item_cfg == nil then
		--print("商店配置中没有该物品",item_id)
		TipsCtrl.Instance:ShowItemGetWayView(item_id)
		return
	end
	self.ok_func = callback
	self.item_id = item_id
	self.no_func = no_func
	self.need_num = need_num
	self.init_quick = not init_quick
	self:Open()
	self:Flush()
end

function TipsCommonBuyView:OnFlush(param_t)
	local item_cfg = ItemData.Instance:GetItemConfig(self.item_id)
	local shop_item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[self.item_id]
	if shop_item_cfg == nil then
		--print("商店配置中没有该物品", self.item_id)
		return
	end

	local money = GameVoManager.Instance:GetMainRoleVo().bind_gold
	local shop_price = 0
	if shop_item_cfg.bind_gold and 0 ~= shop_item_cfg.bind_gold then
		shop_price = shop_item_cfg.bind_gold
		self.diamon_image:SetAsset(ResPath.GetYuanBaoIcon(1))
	elseif shop_item_cfg.vip_gold and 0 ~= shop_item_cfg.vip_gold then
		shop_price = shop_item_cfg.vip_gold
		self.diamon_image:SetAsset(ResPath.GetYuanBaoIcon(0))
	elseif shop_item_cfg.gold and 0 ~= shop_item_cfg.gold then
		shop_price = shop_item_cfg.gold
		self.diamon_image:SetAsset(ResPath.GetYuanBaoIcon(0))
	end

	self.use_bind:SetActive(true)
	-- if shop_item_cfg.bind_gold == 0 then
	-- 	self.use_gold.toggle.isOn = true
	-- 	self.use_bind.toggle.isOn = false
	-- 	self.use_bind:SetActive(false)
	-- end

	-- if self.use_gold.toggle.isOn then
	-- if money < shop_price or (shop_item_cfg.bind_gold == 0 and shop_item_cfg.vip_gold == 0) then
	-- 	money = GameVoManager.Instance:GetMainRoleVo().gold
	-- 	bundle, asset = ResPath.GetYuanBaoIcon(0)
	-- 	shop_price = shop_item_cfg.gold
	-- end

	if item_cfg ~= nil then
		self.pro_name_color:SetValue(Language.Common.QualityRGBColor[item_cfg.color])
		self.pro_name:SetValue(item_cfg.name)
		self.pro_desc:SetValue(item_cfg.description)
		self.have_pro_num:SetValue(ItemData.Instance:GetItemNumInBagById(self.item_id))
	end

	local data = ItemData.Instance:GetItem(self.item_id) or {item_id = self.item_id}
	self.item_cell:SetData(data)
	self.input_text.input_field.text = self.cur_num or 0
	if money < shop_price then
		self.cur_num = 1
		self.max_num = 1
	else
		if item_cfg ~= nil then
			if item_cfg.pile_limit then
				if item_cfg.pile_limit <= tonumber(self.cur_num) then
					self.cur_num = item_cfg.pile_limit
				end
				if item_cfg.pile_limit <= math.floor(money / shop_price) and item_cfg.pile_limit <= tonumber(self.cur_num) then
					self.cur_num = item_cfg.pile_limit
				end
				if item_cfg.pile_limit <= math.floor(money / shop_price) then
					self.max_num = item_cfg.pile_limit
				else
					self.max_num = math.floor(money / shop_price)
				end
			end
		else
			if math.floor(money / shop_price) >= 999 then
				self.max_num = 999
			end
		end
	end
	if self.need_num then
		if self.need_num > self.max_num then
			self.cur_num = self.max_num
			self.need_num = self.max_num
		else
			self.cur_num = self.need_num
		end
	end
	self.need_sprice = shop_price * self.cur_num
	self.sum_price:SetValue(self.need_sprice)
	self.buy_num:SetValue(self.cur_num)
	self.input_text.input_field.text = self.cur_num

	local discount_list = KaifuActivityData.Instance:GetPersonalActivityCfgBuyItem(self.item_id)
	self.show_right:SetValue(#discount_list > 0)
	if #discount_list > 0 then
		self:FlushList(discount_list)
	end

	self.use_bind:SetActive(self.init_quick)
end

function TipsCommonBuyView:FlushList(data_list)
	if self.discount_list == nil then
		self.discount_list = self:FindObj("DiscountList")
		local scroller_delegate = self.discount_list.list_simple_delegate
		--生成数量
		scroller_delegate.NumberOfCellsDel = function()
			return #data_list or 0
		end
		--刷新函数
		scroller_delegate.CellRefreshDel = function(cell, data_index, cell_index)
			data_index = data_index + 1

			local detail_cell = self.cell_list[cell]
			if detail_cell == nil then
				detail_cell = TipsCommonBuyDiscountItem.New(cell.gameObject)
				detail_cell.list_detail_view = self
				self.cell_list[cell] = detail_cell
			end

			detail_cell:SetIndex(data_index)
			detail_cell:SetData(data_list[data_index])
		end
	else
		self.discount_list.scroller:ReloadData(0)
	end
end



----------------------------------------------------------------------------
--TipsCommonBuyDiscountItem 		列表滚动条格子
----------------------------------------------------------------------------

TipsCommonBuyDiscountItem = TipsCommonBuyDiscountItem or BaseClass(BaseCell)

function TipsCommonBuyDiscountItem:__init()
	self.cost = self:FindVariable("Cost")
	self.normal_cost = self:FindVariable("NormalCost")
	self.name = self:FindVariable("Name")
	self.gray = self:FindVariable("Gray")
	self.discount = self:FindVariable("Discount")
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self:FindObj("Item"))
	self.list_detail_view = nil
	self:ListenEvent("Buy",BindTool.Bind(self.OnButtonClick, self))
end

function TipsCommonBuyDiscountItem:__delete()
	self.list_detail_view = nil
	self.item:DeleteMe()
end

function TipsCommonBuyDiscountItem:OnFlush()
	if not self.data or not next(self.data) then return end
	self.cost:SetValue(self.data.gold_price)
	self.normal_cost:SetValue(self.data.show_price)
	self.discount:SetValue(CommonDataManager.GetDaXie(self.data.discount))
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.reward_item.item_id)
	if item_cfg then
		local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..item_cfg.name.."</color>"
		self.name:SetValue(name_str)
	end
	self.item:SetData(self.data.reward_item)
	local buy_info = KaifuActivityData.Instance:GetPersonalBuyInfo()
	local buy_num = buy_info[self.data.seq + 1] or 0
	self.gray:SetValue(buy_num >= self.data.limit_buy_count)
end

function TipsCommonBuyDiscountItem:OnButtonClick()
	if not self.data or not next(self.data) then return end
	local func = function()
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(self.data.activity_type, RA_PERSONAL_PANIC_BUY_OPERA_TYPE.RA_PERSONAL_PANIC_BUY_OPERA_TYPE_BUY_ITEM, self.data.seq)
	end
	local str = string.format(Language.Activity.BuyGiftTip, self.data.gold_price)
	TipsCtrl.Instance:ShowCommonAutoView("personal_auto_buy", str, func)
end