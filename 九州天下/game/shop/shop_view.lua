require("game/shop/shop_content_view")
ShopView = ShopView or BaseClass(BaseView)

ShopView.CoverList = {0, 0, 1, 1, 0}
function ShopView:__init()
	self.ui_config = {"uis/views/shopview","ShopView"}
	self.full_screen = false
	self.play_audio = true
	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].OpenShop)
	end
	self:SetMaskBg()
end

function ShopView:__delete()
end

function ShopView:ReleaseCallBack()
	if self.shop_content_view ~= nil then
		self.shop_content_view:DeleteMe()
		self.shop_content_view = nil
	end

	if self.money_bar ~= nil then
		self.money_bar:DeleteMe()
		self.money_bar = nil
	end

	-- 清理变量和对象
	self.toggle_list = nil
end

function ShopView:LoadCallBack()
	self:ListenEvent("close_view", BindTool.Bind(self.OnCloseBtnClick, self))
	self.shop_content_view = ShopContentView.New(self:FindObj("shop_content_view"))
	for i = 1, 5 do
		self:ListenEvent("toggle_" .. i, BindTool.Bind2(self.OnToggleClick, self, i))
	end
	self.money_bar = MoneyBar.New()
	self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))
	self:InitToggle()
end

function ShopView:InitToggle()
	self.toggle_list = {}
	for i = 1, 5 do
		self.toggle_list[i] = {}
		self.toggle_list[i].toggle_content = self:FindObj("toggle_content_" .. i)
		self.toggle_list[i].toggle_text = self:FindVariable("toggle_text_" .. i)
		if i == 1 then
			self.toggle_list[i].toggle_text:SetValue(Language.Shop.ShopBindGold)
		elseif i == 2 then
			self.toggle_list[i].toggle_text:SetValue(Language.Shop.ShopGold)
		elseif i == 3 then
			self.toggle_list[i].toggle_text:SetValue(Language.Shop.ShopBinding)
		elseif i == 5 then
			self.toggle_list[i].toggle_text:SetValue(Language.Shop.ShopLimit)
		end
		if 1 == ShopView.CoverList[i] then
			self.toggle_list[i].toggle_content:SetActive(false)
		end
	end
end

function ShopView:OpenCallBack()
	ShopCtrl.Instance:SendShopBuy()
end

function ShopView:CloseCallBack()
	ShopCtrl.Instance:SendShopBuy()
	ShopContentView.Instance:SetJumpItem(nil)
end

function ShopView:ShowIndexCallBack(index)
	index = index > 0 and index or 1
	if self.toggle_list[index] then
		self.toggle_list[index].toggle_content.toggle.isOn = true
	end
end

function ShopView:OnCloseBtnClick()
	ViewManager.Instance:Close(ViewName.Shop)
end

function ShopView:OnToggleClick(i, is_click, is_ignore)
	if is_click then
		ShopContentView.Instance:ClearCurIndex()
		ShopContentView.Instance:SetShowInfoView(false)
		ShopContentView.Instance:SetCurrentShopType(i)
		ShopContentView.Instance:OnFlushListReload()
	end
end

function ShopView:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if k == "from_duanzao" then
			self.toggle_list[2].toggle_content.toggle.isOn = true
		elseif k == "flush_buy_limit" then
			ShopContentView.Instance:OnFlushListView()
			ShopContentView.Instance:OnFlushShopInfoView()
		elseif k == "flush_buy_limit_zero" then
			local shop_info_view = ShopContentView.Instance:GetShopInfoView()
			if shop_info_view ~= nil then
				shop_info_view:OnFlushLimitZero()
			end
		elseif k == "all" then
			if v.item_id ~= nil and ShopContentView ~= nil then
				local data = ShopData.Instance:GetAllFenquShopItemCfg()
				local shop_type = nil
				for i,j in pairs(data) do
					if j.item_id == v.item_id then
						shop_type = j.shop_type
						break
					end
				end
				if shop_type ~= nil then
					ShopContentView.Instance:SetJumpItem(v.item_id)
					if v.item_id ~= nil then
						if self.toggle_list[shop_type] ~= nil then
							if self.toggle_list[shop_type].toggle_content.toggle.isOn then
								ShopContentView.Instance:OnFlushListReload()
							else
								self.toggle_list[shop_type].toggle_content.toggle.isOn = true
							end
						end
					end
				end
			end
		end
	end
end