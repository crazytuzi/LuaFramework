QuickBuy = QuickBuy or BaseClass(BaseView)

function QuickBuy:__init()
	if QuickBuy.Instance then
		print_error("[QuickBuy] Attemp to create a singleton twice !")
	end
	QuickBuy.Instance = self
	self.ui_config = {"uis/views/tips/unproptips_prefab", "UnPropTips"}
	self.item_id = nil
	self.item = nil
	self.num_keyboard = nil
	self.item_count = 1
	self.auto_buy_flag = false
	self.get_icon_list = {}
end

function QuickBuy:__delete()
	QuickBuy.Instance = nil

	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end
end

-----------------------------------
-- 回调逻辑
-----------------------------------
-- 创建完调用
function QuickBuy:LoadCallBack()
	local bg = self:FindObj("BGButton")
	bg.button:AddClickListener(
		BindTool.Bind(self.HandleClickClose, self))
	local close_btn = self:FindObj("UnPropTips/Button_Close")
	close_btn.button:AddClickListener(
		BindTool.Bind(self.HandleClickClose, self))

	local buy_btn = self:FindObj("BuyBtn")
	buy_btn.button:AddClickListener(
		BindTool.Bind(self.HandleClickBuy, self))
	local input_number_btn = self:FindObj("UnPropTips/Many/ManyBtn")
	input_number_btn.button:AddClickListener(
		BindTool.Bind(self.HandleClickInput, self))
	local input_number_btn2 = self:FindObj("UnPropTips/Many/PenBtn")
	input_number_btn2.button:AddClickListener(
		BindTool.Bind(self.HandleClickInput, self))

	self.desc_txt = self:FindObj("UnPropTips/Text1")
	self.desc_txt2 = self:FindObj("UnPropTips/Text2")
	self.item = ItemCell.New(self:FindObj("UnPropTips/item"))
	self.input_txt = self:FindObj("UnPropTips/Many/ManyBtn/ManyTx")
	self.currency_txt = self:FindObj("UnPropTips/Gold/Need_prop/Text_Number")
	self.currency_icon = self:FindObj("UnPropTips/Gold/Need_prop/Icon")
	self.auto_buy = self:FindObj("Toggle")
	self.auto_buy.toggle:AddValueChangedListener(BindTool.Bind(self.HandleToggle, self))

	self.pop_num = NumKeypad.New()
	self.pop_num:SetOkCallBack(BindTool.Bind1(self.OnOKCallBack, self))
end


-- 打开后调用
function QuickBuy:OpenCallBack()
    -- override
end

-- 切换标签调用
function QuickBuy:ShowIndexCallBack(index)
    -- override
end

-- 关闭前调用
function QuickBuy:CloseCallBack()
    -- override
end

-- 销毁前调用
function QuickBuy:ReleaseCallBack()
	self.get_icon_list = {}

	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end
end

-- 刷新
function QuickBuy:OnFlush(param_list)
	local item_config = ItemData.Instance:GetItemConfig(self.item_id)
	if nil == item_config then
		print_log("No such item !!")
		return
	end

	local item_data = {}
	item_data.item_id = self.item_id
	item_data.num = 0
	item_data.is_bind = 0
	self.item:SetData(item_data)
	self:RefreshPurchaseView(1)

	local desc = Language.Common.Your .. ToColorStr(item_config.name, ITEM_COLOR[item_config.color]) .. Language.Common.NotEnough
	self.desc_txt.text.text = desc

	local get_way = item_config.get_way or ""
	local way = Split(get_way, ",")

	if 0 == tonumber(way[1]) then
		self.desc_txt2:SetActive(true)
		if nil ~= item_config.id and 27584 == item_config.id then
			self.desc_txt2.text.text = string.format(Language.Common.GetInThis, Language.Common.IsBySynthesis)
		else
			self.desc_txt2.text.text = string.format(Language.Common.GetInThis, Language.Common.BuyInShop)
		end
	else
		self.desc_txt2:SetActive(false)
	end
	self.auto_buy.toggle.isOn = self.auto_buy_flag
end

-----------------------------------
-- 功能逻辑
-----------------------------------
--设置物品Id
function QuickBuy:SetItemId(item_id, count)
	self.item_id = item_id
end

function QuickBuy:SetAutoBuyFlag(flag)
	self.auto_buy_flag = flag
end

function QuickBuy:GetAutoBuyFlag()
	return self.auto_buy_flag
end

--输入数字
function QuickBuy:OnOKCallBack(num)
	self:RefreshPurchaseView(num)
end

--刷新购买版界面
function QuickBuy:RefreshPurchaseView(item_count)
	local item_price = ShopData.GetItemGold(self.item_id)
	self.input_txt.text.text = item_count
	self.currency_txt.text.text = item_count * item_price
	self.item_count = item_count
end

-----------------------------------
-- 事件逻辑
-----------------------------------
function QuickBuy:HandleClickClose()
	self:Close()
end

function QuickBuy:HandleToggle(is_on)
	self.auto_buy_flag = is_on
end

function QuickBuy:HandleClickBuy()
	ShopCtrl.Instance:SendShopBuy(self.item_id, self.item_count, 0)
	local has_currency_num = PlayerData.Instance:GetRoleVo().gold
	local total_currency_num = tonumber(self.currency_txt.text.text)
	if has_currency_num < total_currency_num then
		local alert = nil
		local function cancel_callback()
			if nil ~= alert then
				alert:DeleteMe()
				alert = nil
			end
		end
		local function chongzhi_callback()
			--跳转充值界面
			print("快速充值")
		end
		alert = Alert.New(nil, Language.StarsStateTitle.GoldNotEnough, cancel_callback, chongzhi_callback, cancel_callback)
		alert:SetOkString(Language.Common.Cancel)
		alert:SetCancelString(Language.StarsStateTitle.GoldGet)
		alert:Open()
	end

	self:Close()
end

function QuickBuy:HandleClickInput()
	self.pop_num:Open()
end

function QuickBuy:SetItemCount(item_count)
	if item_count then
		self:RefreshPurchaseView(item_count)
	end
end


