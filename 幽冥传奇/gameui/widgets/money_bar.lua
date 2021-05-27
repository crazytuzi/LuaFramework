-------------------------------------------------
-- Money控件，用于快速实现各个地方的金钱显示以及变化
-------------------------------------------------
MoneyBar = MoneyBar or BaseClass()

function MoneyBar:__init()
	self.coin_list = {}
	self.bindcoin_list = {}
	self.gold_list = {}
	self.bindgold_list = {}

	self.change_callback = BindTool.Bind1(self.RoleDataAttrChangeCallBack, self)
	RoleData.Instance:NotifyAttrChange(self.change_callback)
end

function MoneyBar:__delete()
	if nil ~= RoleData.Instance then
		RoleData.Instance:UnNotifyAttrChange(self.change_callback)
	end
	self.change_callback = nil
end

function MoneyBar:SetView(view_t)
	if view_t.coin_txt then
		self:AddCoinText(view_t.coin_txt.node)
	end
	if view_t.bindcoin_txt then
		self:AddBindCoinText(view_t.bindcoin_txt.node)
	end
	if view_t.gold_txt then
		self:AddGlodText(view_t.gold_txt.node)
	end
	if view_t.bindgold_txt then
		self:AddBindGoldText(view_t.bindgold_txt.node)
	end
end

function MoneyBar:AddCoinText(node)
	node:setString(RoleData.Instance:GetRoleInfo().coin)
	table.insert(self.coin_list, node)
end

function MoneyBar:AddBindCoinText(node)
	node:setString(RoleData.Instance:GetRoleInfo().bind_coin)
	table.insert(self.bindcoin_list, node)
end

function MoneyBar:AddGlodText(node)
	node:setString(RoleData.Instance:GetRoleInfo().gold)
	table.insert(self.gold_list, node)
end

function MoneyBar:AddBindGoldText(node)
	node:setString(RoleData.Instance:GetRoleInfo().bind_gold)
	table.insert(self.bindgold_list, node)
end

function MoneyBar:CleanList()
	self.coin_list = {}
	self.bindcoin_list = {}
	self.gold_list = {}
	self.bindgold_list = {}
end

function MoneyBar:RoleDataAttrChangeCallBack(attr_name, value)
	if attr_name == "coin" then
		self:FlushCoin(value)
	elseif attr_name == "bind_coin" then
		self:FlushBindCoin(value)
	elseif attr_name == "gold" then
		self:FlushGold(value)
	elseif attr_name == "bind_gold" then
		self:FlushBindGold(value)
	end
end

function MoneyBar:OnFlush()
	local role_info = RoleData.Instance:GetRoleInfo()
	self:FlushCoin(role_info.coin)
	self:FlushBindCoin(role_info.bind_coin)
	self:FlushGold(role_info.gold)
	self:FlushBindGold(role_info.bind_gold)
end

function MoneyBar:FlushCoin(value)
	for k, v in pairs(self.coin_list) do
		v:setString(value)
	end
end

function MoneyBar:FlushBindCoin(value)
	for k, v in pairs(self.bindcoin_list) do
		v:setString(value)
	end
end

function MoneyBar:FlushGold(value)
	for k, v in pairs(self.gold_list) do
		v:setString(value)
	end
end

function MoneyBar:FlushBindGold(value)
	for k, v in pairs(self.bindgold_list) do
		v:setString(value)
	end
end
