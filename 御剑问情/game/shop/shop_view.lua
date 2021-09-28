require("game/shop/shop_content_view")
require("game/shop/shenmi_content_view")
ShopView = ShopView or BaseClass(BaseView)

function ShopView:__init()
	self.ui_config = {"uis/views/exchangeview_prefab","ExchangeView"}
	self.full_screen = true
	self.play_audio = true
	self.item_info = {}
	self.buy_num_value = 0
	self.consume_type = 0
	self.my_coin = 0
	self.my_coin_bind = 0
	self.item_index = nil
	self.isClickDonw = false
	self.isReduceDown = false
	self.nowtime = 3

	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].OpenShop)
	end
end

function ShopView:__delete()
end

function ShopView:ReleaseCallBack()
	if self.shop_content_view ~= nil then
		self.shop_content_view:DeleteMe()
		self.shop_content_view = nil
	end

	if self.shenmi_content_view ~= nil then
		self.shenmi_content_view:DeleteMe()
		self.shenmi_content_view = nil
	end

	if self.item_cell ~= nil then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	self:RemoveCountDown()

	self.item_index = nil
	self.title_name = nil
	self.item_name = nil
	self.use_level = nil
	self.level_color = nil
	self.buy_num = nil
	self.buy_price = nil
	self.buy_all_price = nil
	self.item_icon = nil
	self.btn_text = nil
	self.coin_icon_1 = nil
	self.coin_icon_2 = nil
	self.desc_text = nil
	self.my_coin_text = nil
	self.item_goumai = nil
	self.shenmishop = nil
	-- self.text_1 = nil
	-- self.text_2 = nil
	-- self.text_3 = nil
	self.buy_a = nil
	self.my_jifen = nil
	self.flushtime_hour = nil
	self.flushtime_min = nil
	self.flushtime_sec = nil
	self.meinv = nil
	self.shop_buy = nil
	-- self.red_point = nil
	self.flushprice = nil
	self.splite_bg = nil

	-- 清理变量和对象
	self.toggle_list = nil
end

function ShopView:LoadCallBack()
	self:ListenEvent("close_view", BindTool.Bind(self.OnCloseBtnClick, self))
	self.shop_content_view = ShopContentView.New(self:FindObj("exchange_content_view"))
	self.shenmi_content_view = ShenMiContentView.New(self:FindObj("shenmi_content_view"))
	for i=1,5 do
		self:ListenEvent("toggle_" .. i, BindTool.Bind2(self.OnToggleClick, self, i))
	end
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("item_cell"))
	self.item_cell:ShowHighLight(false)

	self.title_name = self:FindVariable("title_name")
	self.item_name = self:FindVariable("item_name")
	self.use_level = self:FindVariable("use_level")
	self.level_color = self:FindVariable("level_color")
	self.buy_num = self:FindVariable("buy_num")
	self.buy_price = self:FindVariable("buy_price")
	self.buy_all_price = self:FindVariable("buy_all_price")
	self.item_icon = self:FindVariable("item_icon")
	self.btn_text = self:FindVariable("btn_text")
	self.coin_icon_1 = self:FindVariable("coin_icon_1")
	self.coin_icon_2 = self:FindVariable("coin_icon_2")
	self.desc_text = self:FindVariable("desc")
	self.my_coin_text = self:FindVariable("my_coin_text")
	self.item_goumai = self:FindVariable("Item_GouMai")
	self.shenmishop = self:FindVariable("shenmishop")
	self.buy_a = self:FindVariable("buy_a")
	-- self.text_3 = self:FindVariable("text_3")
	self.my_jifen = self:FindVariable("my_jifen")
	self.flushtime_hour = self:FindVariable("flushtime_hour")
	self.flushtime_min = self:FindVariable("flushtime_min")
	self.flushtime_sec = self:FindVariable("flushtime_sec")
	self.meinv = self:FindVariable("meinv")
	self.shop_buy = self:FindVariable("shop_buy")
	-- self.red_point = self:FindVariable("RedPoint")
	self.flushprice = self:FindVariable("flushprice")
	self.splite_bg = self:FindVariable("split_bg")

	self:ListenEvent("btn_Reduce",BindTool.Bind(self.btn_Reduce, self))
	self:ListenEvent("btn_ReduceUp",BindTool.Bind(self.btn_ReduceUp, self))
	self:ListenEvent("btn_Add",BindTool.Bind(self.btn_Add, self))
	self:ListenEvent("btn_AddUp",BindTool.Bind(self.btn_AddUp, self))

	self:ListenEvent("minus_click",BindTool.Bind(self.OnMinusClick, self))
	self:ListenEvent("plus_click",BindTool.Bind(self.OnPlusClick, self))
	self:ListenEvent("max_click",BindTool.Bind(self.OnMaxClick, self))
	self:ListenEvent("buy_click",BindTool.Bind(self.OnBuyClick, self))
	--self:ListenEvent("close_click",BindTool.Bind(self.OnCloseClick, self))
	self:ListenEvent("input_click",BindTool.Bind(self.OnTextClick, self))
	self:ListenEvent("jifenshop_click",BindTool.Bind(self.JiFenShopClick, self))
	self:ListenEvent("flush_click",BindTool.Bind(self.FlushShopClick, self))
	-- self:ListenEvent("Yes",BindTool.Bind(self.ItemYes, self))
	-- self:ListenEvent("No",BindTool.Bind(self.ItemNo, self))
	-- self:ListenEvent("CloseButton",BindTool.Bind(self.ItemNo, self))
	self:ListenEvent("chongzhi",BindTool.Bind(self.ChongZhi, self))

    self.btn_text:SetValue(Language.Common.CanPurchase)
	self.title_name:SetValue(Language.Common.Shop)
	self.item_goumai:SetValue(false)
	self.shenmishop:SetValue(false)
	self.meinv:SetValue(true)


	local shenmi_flushprice = ShopData.Instance:GetFlushPrice()
	if shenmi_flushprice then
		self.flushprice:SetValue(shenmi_flushprice[1].consume_diamond)
	end
	self:InitToggle()
end

function ShopView:InitToggle()
	self.toggle_list = {}
	for i=1,5 do
		self.toggle_list[i] = {}
		self.toggle_list[i].toggle_content = self:FindObj("toggle_content_" .. i)
		self.toggle_list[i].toggle_text = self:FindVariable("toggle_text_" .. i)
		if i == 1 then
			self.toggle_list[i].toggle_text:SetValue(Language.Shop.ShopGrowUp)
		elseif i == 2 then
			self.toggle_list[i].toggle_text:SetValue(Language.Shop.ShopGem)
		elseif i == 3 then
			self.toggle_list[i].toggle_text:SetValue(Language.Shop.ShopBinding)
		elseif i == 5 then
			self.toggle_list[i].toggle_text:SetValue(Language.Shop.SpritSkill)
		end
		if i == 4 then
			self.toggle_list[i].toggle_text:SetValue(Language.Shop.ShopYouHui)
			self.toggle_list[i].toggle_content:SetActive(ShopData.Instance:GetShenMiShop() ~= nil)
		end
	end
end

function ShopView:OpenCallBack()

end

function ShopView:ShowIndexCallBack(index)
	-- index = index > 0 and index or 1
	-- if self.toggle_list[index] then
	-- 	self.toggle_list[index].toggle_content.toggle.isOn = true
	-- end
	if index == TabIndex.shop_chengzhang then
		self.toggle_list[1].toggle_content.toggle.isOn = true
	elseif index == TabIndex.shop_baoshi then
		self.toggle_list[2].toggle_content.toggle.isOn = true
	elseif index == TabIndex.shop_bind then
		self.toggle_list[3].toggle_content.toggle.isOn = true
	elseif index == TabIndex.shop_youhui then
		self.toggle_list[4].toggle_content.toggle.isOn = true
		RemindManager.Instance:SetRemindToday(RemindName.ShenmiShop)
	elseif index == TabIndex.shop_sprits_skill then
		self.toggle_list[5].toggle_content.toggle.isOn = true
	else
		self:ShowIndex(TabIndex.shop_youhui)
	end
end

function ShopView:OnCloseBtnClick()
	ViewManager.Instance:Close(ViewName.Shop)
end

function ShopView:OnToggleClick(i,is_click)
	if is_click then
		if i == 4 then
			self.shop_buy:SetValue(false)
			self.shenmishop:SetValue(true)
			self.meinv:SetValue(false)
			-- self.red_point:SetValue(false)
			self.shop_content_view:SetCurrentShopType(i)
			RemindManager.Instance:Fire(RemindName.ShenmiShop)
			self.splite_bg:SetValue(false)
		else
			self.meinv:SetValue(true)
			self.shop_buy:SetValue(true)
			self.shenmishop:SetValue(false)
			self.splite_bg:SetValue(true)
			self.shop_content_view:SetCurrentShopType(i)
		end

		if i == 3 then
			local bundle, asset = ResPath.GetDiamonIcon(3)
			self.coin_icon_1:SetAsset(bundle, asset)
			self.coin_icon_2:SetAsset(bundle, asset)
			self.my_coin_text:SetValue(self.my_coin_bind)
		else
			local bundle, asset = ResPath.GetDiamonIcon(2)
			self.coin_icon_1:SetAsset(bundle, asset)
			self.coin_icon_2:SetAsset(bundle, asset)
			self.my_coin_text:SetValue(self.my_coin)
		end
		self:FlushJiFenItem()
		self.buy_num_value = 0

		self.item_goumai:SetValue(false)
		ShopContentView.Instance.cellitem_id = 0
	 	self.use_level:SetValue("")
	 	self.item_name:SetValue("")
	 	self.desc_text:SetValue("")
		self.buy_num:SetValue(0)
		self.buy_price:SetValue(0)
		self.buy_all_price:SetValue(0)
		self.shop_content_view:OnFlushListView()
	end
end

-- function ShopView:ItemYes()
-- 	if nil ~= self.item_index then
-- 		ShopCtrl.Instance:SendMysteriosshopinMallOperate(MYSTERIOUSSHOP_IN_MALL_OPERATE_TYPE.OPERATE_TYPE_MONEY, self.item_index - 1)
-- 	end
-- 	self.item_index = nil
-- 	-- self.buy_a:SetValue(false)
-- 	ViewManager.Instance:Close(ViewName.ExchangeViewBuyTips)
-- end

-- function ShopView:ItemNo()
-- 	self.item_index = nil
-- 	-- self.buy_a:SetValue(false)
-- 	ViewManager.Instance:Close(ViewName.ExchangeViewBuyTips)
-- end

function ShopView:ShenMiItem()
	if self.shenmi_content_view == nil then
		return
	end
	self.shenmi_content_view:FlushView()
end

function ShopView:ChongZhi()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function ShopView:AddMoneyClick()
	-- VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	-- ViewManager.Instance:Open(ViewName.VipView)
end

function ShopView:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if k == "from_duanzao" then
			self.toggle_list[2].toggle_content.toggle.isOn = true
		elseif k == "xin_xi" then
			self:ItemXinXi(v[1], v[2])
		elseif k == "shenmishop_view" then
			self:ShopItemBuy(v[1], v[2], v[3], v[4])
		end
	end
	self:FlushJiFenItem()
	self.my_coin = GameVoManager.Instance:GetMainRoleVo().gold
	self.my_coin_bind = GameVoManager.Instance:GetMainRoleVo().bind_gold
	-- local flag = ShopData.Instance:GetShopShenMiFlag()
	-- if flag == 1 then
	-- 	self.red_point:SetValue(true)
	-- else
	-- 	self.red_point:SetValue(false)
	-- end
	self:FlushCoin()
	self.shop_content_view:FlushCoin()
end

function ShopView:ShopItemBuy(item_cfg, price, index, num)
	if nil == item_cfg then
		return
	end

	local shenmi_shop_info = ShopData.Instance:GetShenMiShop()

	if shenmi_shop_info.seq_list[index].state == 0 then
		-- print_error("shenmi_shop_info.seq_list[index]",shenmi_shop_info.seq_list[index].state)
		ViewManager.Instance:Open(ViewName.ExchangeViewBuyTips)
	 	-- self.buy_a:SetValue(true)
	else
		ViewManager.Instance:Close(ViewName.ExchangeViewBuyTips)
	 	-- self.buy_a:SetValue(false)
	end
	local item_num = "*" .. num
	if num == 1 then
		item_num = ""
	end
	-- self.text_1:SetValue(price)
	-- self.text_2:SetValue(ToColorStr(item_cfg.name .. item_num, ITEM_COLOR[item_cfg.color]))
	-- self.text_3:SetValue(num)
	self.item_index = index

	ViewManager.Instance:FlushView(ViewName.ExchangeViewBuyTips, "flush_index", {index,price,ToColorStr(item_cfg.name .. item_num, ITEM_COLOR[item_cfg.color])})
end

function ShopView:ItemXinXi(item_id, consume_type)
    local data = TableCopy(ItemData.Instance:GetItemConfig(item_id))
    self.consume_type = consume_type
	if self.consume_type == SHOP_BIND_TYPE.BIND then
		data.is_bind = 1
	elseif self.consume_type == SHOP_BIND_TYPE.NO_BIND then
		data.is_bind = 0
	end
	self.item_info = data
	local shop_item_cfg = ShopData.Instance:GetShopItemCfg(self.item_info.id)
	local res_id = 2
	local price = 0
	data.item_id = item_id


	self.item_cell:SetData(data)
	self.is_use = is_use
	if shop_item_cfg ~= nil then
		if self.consume_type == SHOP_BIND_TYPE.BIND then
			res_id = 3
			price = shop_item_cfg.bind_gold
		elseif self.consume_type == SHOP_BIND_TYPE.NO_BIND then
			res_id = 2
			if nil ~= shop_item_cfg then
				price = shop_item_cfg.gold
		    end
		end
	end

	self.item_price = price

	if next(self.item_info) ~= nil then
		if 1 == self.item_info.color then
			self.item_name:SetValue(ToColorStr(self.item_info.name, TEXT_COLOR.GREEN_SPECIAL))
		else
			self.item_name:SetValue(ToColorStr(self.item_info.name, ITEM_COLOR[self.item_info.color]))
		end
		self.buy_price:SetValue(price)
		self.buy_num_value = 1
		self.buy_num:SetValue(self.buy_num_value)
		self.buy_price:SetValue(price)
		self:SetAllPrice()

		self.use_level:SetValue(PlayerData.GetLevelLimitString(self.item_info.limit_level))
		local role_level = GameVoManager.Instance:GetMainRoleVo().level or 0
		self.level_color:SetValue(role_level < self.item_info.limit_level and "#ff0000" or "#0000f1")
	end

	local bundle, asset = ResPath.GetDiamonIcon(res_id)
	self.coin_icon_1:SetAsset(bundle, asset)
	self.coin_icon_2:SetAsset(bundle, asset)
	self.desc_text:SetValue(self.item_info.description)
	self.item_goumai:SetValue(true)
	self.meinv:SetValue(false)

	self:FlushCoin()
end

function ShopView:FlushCoin()
	local count = 0
	if self.consume_type == SHOP_BIND_TYPE.BIND then
		count = GameVoManager.Instance:GetMainRoleVo().bind_gold
	elseif self.consume_type == SHOP_BIND_TYPE.NO_BIND then
		count = GameVoManager.Instance:GetMainRoleVo().gold
	end

	if count > 99999 and count <= 99999999 then
		count = count / 10000
		count = math.floor(count)
		count = count .. "万"
	elseif count > 99999999 then
		count = count / 100000000
		count = math.floor(count)
		count = count .. "亿"
	end
	self.my_coin_text:SetValue(count)
end

function ShopView:btn_Add()
	self.isClickDonw = true
	self.nowtime = 3
end

function ShopView:btn_AddUp()
	self.isClickDonw = false
	if self.nowtime == 3 then
		self:NumberAdd()
	end
	self.nowtime = 3
end

function ShopView:NumberAdd()
	local role_info = GameVoManager.Instance:GetMainRoleVo()
	local item_cfg = ShopData.Instance:GetShopItemCfg(self.item_info.id)
	if nil == item_cfg then
		return
	end

	if self.consume_type == 1 then
		if role_info.bind_gold < item_cfg.bind_gold * (self.buy_num_value + 1) then
			return
		end
	else
		if role_info.gold < item_cfg.gold * (self.buy_num_value + 1) then
			return
		end
	end

	if self.nowtime > 0 then
		self.buy_num_value = self.buy_num_value + 1
	else
		if self.consume_type == 1 then
			if role_info.bind_gold < item_cfg.bind_gold * (self.buy_num_value + 10) then
				self.buy_num_value = math.floor(role_info.bind_gold / item_cfg.bind_gold)
			else
				self.buy_num_value = self.buy_num_value + 10
			end
		else
			if role_info.gold < item_cfg.gold * (self.buy_num_value + 10) then
				self.buy_num_value = math.floor(role_info.gold / item_cfg.gold)
			else
				self.buy_num_value = self.buy_num_value + 10
			end
		end

	end
	if self:GetCanBuyNum() == 1 then
		self.buy_num_value = 1
	end
	self.buy_num:SetValue(self.buy_num_value)
	self:SetAllPrice()
end

function ShopView:NumberReduce()
	if self.nowtime > 0 then
		self.buy_num_value = self.buy_num_value - 1
	else
		self.buy_num_value = self.buy_num_value - 10
	end
	if self.buy_num_value > 0 then
		self.buy_num:SetValue(self.buy_num_value)
	else
		self.buy_num_value = 1
		self.buy_num:SetValue(self.buy_num_value)
	end
	if self:GetCanBuyNum() == 1 then
		self.buy_num_value = 1
		self.buy_num:SetValue(self.buy_num_value)
	end
	self:SetAllPrice()
end


function ShopView:btn_Reduce()
	self.isReduceDown = true
	self.nowtime = 3
end

function ShopView:btn_ReduceUp()
	self.isReduceDown = false
	if self.nowtime == 3 then
		self:NumberReduce()
	end
	self.nowtime = 3
end


function ShopView:OnMinusClick()
	if self.buy_num_value == 1 then
		return
	end
	if self.buy_num_value > 1 then
		self.buy_num_value = self.buy_num_value - 1
		self.buy_num:SetValue(self.buy_num_value)
		self:SetAllPrice()
    end
end

function ShopView:OnPlusClick()
	local can_buy_num = self:GetCanBuyNum()
	if can_buy_num > self.buy_num_value then
		self.buy_num_value = self.buy_num_value + 1
		if self.buy_num_value > 999 then
			self.buy_num_value = 999
		end
		self.buy_num:SetValue(self.buy_num_value)
		self:SetAllPrice()
	end
end

function ShopView:OnMaxClick()
	self.buy_num_value = self:GetCanBuyNum()
	if self.buy_num_value > 999 then
		self.buy_num_value = 999
	elseif self.buy_num_value == 0 then
		self.buy_num_value = 1
	end
	self.buy_num:SetValue(self.buy_num_value)
	self:SetAllPrice()
end

function ShopView:OnBuyClick()
	if self.buy_num_value == 0 then
		return
	end
	local sure_func = function()
		TipsCtrl.Instance:GetRenameView():Close()
		--self:Close()
	end
	if self.buy_num_value > self:GetCanBuyNum() then
		if self.consume_type == 1 then
			TipsCtrl.Instance:ShowSystemMsg(Language.Common.NoBindGold)
		else
			TipsCtrl.Instance:ShowLackDiamondView(sure_func)
		end
	else
		if self.consume_type == 1 then
			ExchangeCtrl.Instance:SendCSShopBuy(self.item_info.id, self.buy_num_value, 1, self.is_use or self.item_info.is_diruse, 0, 0) --使用绑钻
		else
			ExchangeCtrl.Instance:SendCSShopBuy(self.item_info.id, self.buy_num_value, 0, self.is_use or self.item_info.is_diruse, 0, 0) --使用钻石
		end
		self.buy_num_value = 1
		self.buy_num:SetValue(self.buy_num_value)

		local item_cfg = ShopData.Instance:GetShopItemCfg(self.item_info.id)
		if self.consume_type == 1 then
			self.buy_all_price:SetValue(item_cfg.bind_gold * self.buy_num_value)
		else
			self.buy_all_price:SetValue(item_cfg.gold * self.buy_num_value)
		end
		--self:Close()
	end
end

function ShopView:OnTextClick()
	local open_func = function(buy_num)
		local can_buy_num = self:GetCanBuyNum()
		if buy_num + 0 == 0 then
			self.buy_num_value = 1
			return
		end

		if buy_num + 0 <= can_buy_num then
			self.buy_num_value = buy_num + 0
		else
			if can_buy_num == 0 then
				self.buy_num_value = 1
			else
				self.buy_num_value = can_buy_num
			end
		end
		self.buy_num:SetValue(self.buy_num_value)
	end

	local close_func = function()
		self:SetAllPrice()
	end

	local max = 0
	if self:GetCanBuyNum() == 0 then
		max = 1
	else
		max = self:GetCanBuyNum()
	end
	TipsCtrl.Instance:OpenCommonInputView(0,open_func,close_func,max)
end

function ShopView:JiFenShopClick()
	ShopCtrl.Instance:OpenJifenShop()
end

function ShopView:FlushShopClick()
	ShopCtrl.Instance:SendMysteriosshopinMallOperate(MYSTERIOUSSHOP_IN_MALL_OPERATE_TYPE.OPERATE_TYPE_REFRESH, -1)
	SpiritCtrl.Instance:SendGetSpiritScore()
	ExchangeCtrl.Instance:SendGetSocreInfoReq()
end

function ShopView:FlushJiFenItem()
	local data = ShopData.Instance:GetShenMiShop()
	if nil == data then return end

	local severtime = TimeCtrl.Instance:GetServerTime()
	local diff_time = data.next_shop_item_refresh_time - severtime
	self.my_jifen:SetValue(ExchangeData.Instance:GetCurrentScore(EXCHANGE_PRICE_TYPE.JIFEN))
	local function diff_time_func (elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0.5 then
				self:RemoveCountDown()
				return
			end
			local left_hour = math.floor(left_time / 3600)
			local left_min = math.floor((left_time - left_hour * 3600) / 60)
			local left_sec = math.floor(left_time - left_hour * 3600 - left_min * 60)

			self.flushtime_hour:SetValue(left_hour < 10 and "0"..left_hour or left_hour)
			self.flushtime_min:SetValue(left_min < 10 and "0"..left_min or left_min)
			self.flushtime_sec:SetValue(left_sec < 10 and "0"..left_sec or left_sec)
			if self.isClickDonw then
				self.nowtime = self.nowtime - 1
				self:NumberAdd()
			elseif self.isReduceDown then
				self.nowtime = self.nowtime - 1
				self:NumberReduce()
			end
	end
	diff_time_func(0, diff_time)
	self:RemoveCountDown()
	self.montser_count_down_list = CountDown.Instance:AddCountDown(diff_time, 0.5, diff_time_func)

end

function ShopView:RemoveCountDown()
	if self.montser_count_down_list ~= nil then
		CountDown.Instance:RemoveCountDown(self.montser_count_down_list)
	 	self.montser_count_down_list = nil
	end
end

function ShopView:SetAllPrice()
	local item_cfg = ShopData.Instance:GetShopItemCfg(self.item_info.id)
	if nil == item_cfg then
		return
	end

	if self.consume_type == 1 then
		self.buy_all_price:SetValue(item_cfg.bind_gold * self.buy_num_value)
	else
		self.buy_all_price:SetValue(item_cfg.gold * self.buy_num_value)
	end
end

function ShopView:GetCanBuyNum()
	local item_cfg = ShopData.Instance:GetShopItemCfg(self.item_info.id)
	if nil == item_cfg then
		return 0
	end

	local can_buy_num = 0
	local money_can_buy = 0
	if self.consume_type == 1 and item_cfg.bind_gold > 0 then
		money_can_buy = math.floor(GameVoManager.Instance:GetMainRoleVo().bind_gold / item_cfg.bind_gold)
	elseif item_cfg.gold > 0 then
		money_can_buy = math.floor(GameVoManager.Instance:GetMainRoleVo().gold / item_cfg.gold)
	end

	local pile_limit = self.item_info.pile_limit
	if pile_limit >= money_can_buy then
		can_buy_num = money_can_buy
	else
		can_buy_num = pile_limit
	end

	return can_buy_num
end




----------------------------------------------------------------------------------------
--弹出tips
----------------------------------------------------------------------------------------

BuyTipsView = BuyTipsView or BaseClass(BaseView)

function BuyTipsView:__init()
	self.ui_config = {"uis/views/exchangeview_prefab","BuyTipsView"}
	self.full_screen = false
	self.play_audio = true
	self.item_index = nil
end


function BuyTipsView:LoadCallBack()
	self:ListenEvent("YesBtn",BindTool.Bind(self.OnYesClick, self))
	self:ListenEvent("NoBtn",BindTool.Bind(self.OnNoClick, self))
	self:ListenEvent("CloseBtn",BindTool.Bind(self.CloseBtn, self))


	self.text_1 = self:FindVariable("text_1")
	self.text_2 = self:FindVariable("text_2")
end

function BuyTipsView:__delete()

end

function BuyTipsView:ReleaseCallBack()
	self.text_1 = nil
	self.text_2 = nil
end
function BuyTipsView:OnYesClick()
	ShopCtrl.Instance:SendMysteriosshopinMallOperate(MYSTERIOUSSHOP_IN_MALL_OPERATE_TYPE.OPERATE_TYPE_MONEY, self.item_index - 1)
	self:Close()
end


function BuyTipsView:OnNoClick()
	self:Close()
end


function BuyTipsView:SetIndex(index,price,item_name)
	self.item_index = index
	self.text_1:SetValue(price)
	self.text_2:SetValue(item_name)
end


function BuyTipsView:CloseBtn()
	self:Close()
end

function BuyTipsView:OnFlush(params)
	for k,v in pairs(params) do
		if k == "flush_index" then
			self:SetIndex(v[1],v[2],v[3])
		end
	end

end