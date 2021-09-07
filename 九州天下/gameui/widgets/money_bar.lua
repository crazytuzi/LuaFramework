MoneyBar = MoneyBar or BaseClass(BaseCell)

local MONNEY_TYPE = {
	[GameEnum.MONEY_BAR.BIND_GOLD] = "bind_gold",
	[GameEnum.MONEY_BAR.GOLD] = "gold",
	[GameEnum.MONEY_BAR.BIND_COIN] = "bind_coin",
	[GameEnum.MONEY_BAR.COIN] = "coin",
	[GameEnum.MONEY_BAR.OTHER] = "other",
}

local MONEY_BAR_VARIABLE_NAME = {
	[GameEnum.MONEY_BAR.BIND_GOLD] = "BindGold",
	[GameEnum.MONEY_BAR.GOLD] = "Gold",
	[GameEnum.MONEY_BAR.BIND_COIN] = "BindCoin",
	[GameEnum.MONEY_BAR.COIN] = "Coin",
	[GameEnum.MONEY_BAR.OTHER] = "Other",
}

local MONEY_BAR_ACTIVE_NAME = {
	[GameEnum.MONEY_BAR.BIND_GOLD] = "ShowBindGold",
	[GameEnum.MONEY_BAR.GOLD] = "ShowGold",
	[GameEnum.MONEY_BAR.BIND_COIN] = "ShowBindCoin",
	[GameEnum.MONEY_BAR.COIN] = "ShowCoin",
	[GameEnum.MONEY_BAR.OTHER] = "ShowOther",
}
function MoneyBar:__init()
	self.is_use_objpool = false
	self.other_name = ""
	if nil == self.root_node then
		local bundle, asset = ResPath.GetWidgets("MoneyBar")
		local prefab = PreloadManager.Instance:GetPrefab(bundle, asset)
		local u3dobj = U3DObject(GameObjectPool.Instance:Spawn(prefab, nil))
		self:SetInstance(u3dobj)
		self.is_use_objpool = true
	end
end

function MoneyBar:__delete()
	self.money_list = {}
	if self.change_callback then
		if PlayerData.Instance then
			PlayerData.Instance:UnlistenerAttrChange(self.change_callback)
		end
		self.change_callback = nil
	end
	if self.is_use_objpool then
		GameObjectPool.Instance:Free(self.root_node.gameObject)
	end
	self.other_name = ""
end

function MoneyBar:LoadCallBack()
	self.money_list = {}
	for i = 1, GameEnum.MONEY_BAR.MAX_TYPE do
		local data = {}
		data.need_change = true
		data.value = self:FindVariable(MONEY_BAR_VARIABLE_NAME[i])
		data.active = self:FindVariable(MONEY_BAR_ACTIVE_NAME[i])
		self.money_list[MONNEY_TYPE[i]] = data
	end

	self:ListenEvent("AddGold", BindTool.Bind(self.OnClickAddGold, self))
	self:ListenEvent("OnClickShop", BindTool.Bind(self.OnClickShop, self))

	self.show_other_add = self:FindVariable("ShowOtherAdd")
	self.other_icon = self:FindVariable("OtherIcon")
	self.show_shop = self:FindVariable("ShowShop")

	if not self.change_callback then
		self.change_callback = BindTool.Bind(self.PlayerDataChangeCallback, self)
		PlayerData.Instance:ListenerAttrChange(self.change_callback)
	end
	self:Flush()
end

function MoneyBar:PlayerDataChangeCallback(attr_name, value)
	if self.money_list[attr_name] and self.money_list[attr_name].need_change then
		local change_value = CommonDataManager.ConverMoney(value)
		self.money_list[attr_name].value:SetValue(change_value)
	end
	if self.other_name == attr_name and self.money_list["other"].need_change then
		local change_value = CommonDataManager.ConverMoney(value)
		self.money_list.other.value:SetValue(change_value)
	end
end

function MoneyBar:OnFlush()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	for k,v in pairs(self.money_list) do
		if main_role_vo[k] and v.need_change then
			local change_value = CommonDataManager.ConverMoney(main_role_vo[k])
			v.value:SetValue(change_value)
		elseif main_role_vo[self.other_name] and v.need_change then
			local change_value = CommonDataManager.ConverMoney(main_role_vo[self.other_name])
			v.value:SetValue(change_value)
		end
	end
	
	self.show_shop:SetValue(not ExchangeCtrl.Instance.view:IsOpen())
end

function MoneyBar:OnClickAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function MoneyBar:OnClickShop()
	ViewManager.Instance:Open(ViewName.Exchange, TabIndex.exchange_mojing)
end

function MoneyBar:SetMoneyBarShow(type, bool)
	if self.money_list[MONNEY_TYPE[type]] then
		self.money_list[MONNEY_TYPE[type]].need_change = bool
		self.money_list[MONNEY_TYPE[type]].active:SetValue(bool)
	end
end

--[[
	is_show  是否显示其他种类金钱
	attr_name 属性名字（role身上的）
	bundle, asset 图标资源路径名字
	show_add 是否显示加号
	callback 加号点击回调
]]
function MoneyBar:SetOther(is_show, attr_name, bundle, asset, show_add, callback)
	self.money_list["other"].need_change = is_show
	self.money_list["other"].active:SetValue(is_show)
	if not is_show then return end
	self.other_name = attr_name
	self.other_icon:SetAsset(bundle, asset)
	self.show_other_add:SetValue(show_add)
	if show_add and callback then
		self:ClearEvent("OnClickOther")
		self:ListenEvent("OnClickOther", callback)
	end
	self:Flush()
end