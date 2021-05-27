RedEnvelopesData = RedEnvelopesData or BaseClass()
function RedEnvelopesData:__init()
	if RedEnvelopesData.Instance then
		ErrorLog("[RedEnvelopesData] attempt to create singleton twice!")
		return
	end
	RedEnvelopesData.Instance = self
end

function RedEnvelopesData:__delete()
end

function RedEnvelopesData:GetRedEnvelopesRemindNum()
	local count = 0
	local item_list = self:GetRedEnvelopesItemList()
	local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	if nil == item_list then 
		return
	 end
	for i = 1, #item_list do
		if item_list[i].level <= role_level and 0 == item_list[i].sign then
			count = count + 1
		end
	end
	return count
end

function RedEnvelopesData:GetRedEnvelopesSign()
	return self.redenvelopessign
end

function RedEnvelopesData:IsRedAllPickUp()
	local award_length = #RedEnvelopes.awardcfg
	local sign = self.redenvelopessign
	local is_lingqu = 0
	if nil ~= sign then
		is_lingqu = bit:_and(1, bit:_rshift(sign, award_length - 1)) 
	end
	return is_lingqu > 0
end

function RedEnvelopesData:GetRedEnvelopesItemList()
	local item_list = {}
	local cfg = RedEnvelopes.awardcfg
	if nil == cfg then return end
	for i = 1, #cfg do
		if nil == cfg[i] then return end
		local item = cfg[i].award
		item.level = cfg[i].level
		item.consume = cfg[i].consume.count
		item.index = i
		table.insert(item_list, item)
	end

	item_list = self:GetRedEnvelopesSignlist(item_list)
	table.sort(item_list, function (a,b)
		if a.sign ~= b.sign then
			return a.sign < b.sign
		else
			return a.level < b.level
		end
	end)

	return item_list
end

function RedEnvelopesData:GetRedEnvelopesSignlist(reward_list)
	if nil == reward_list then return {} end
	local sign = self.redenvelopessign
	for i = 1, #reward_list do
		if nil == sign then break end
		local is_lingqu = bit:_and(1, bit:_rshift(sign, i - 1)) 
		reward_list[i].sign = is_lingqu
		if 1 == i then 
			reward_list[i].show_btn = true
		else
			reward_list[i].show_btn = reward_list[i - 1].sign > 0
		end
	end
	return reward_list
end
-------------------------------------------------------
--共同调用部分
-------------------------------------------------------
function RedEnvelopesData:SetSign(protocol)
	if protocol.view_type == 1 then                --天降红包
		self.redenvelopessign = protocol.sign
	elseif protocol.view_type == 2 then            --屌丝逆袭
		self.losersign = protocol.sign
	end
end

function RedEnvelopesData:SetActIndex(index)
	if nil ~= index then 
		self.act_index = index
	end
end

function RedEnvelopesData:GetActIndex()
	return self.act_index
end

function RedEnvelopesData:GetConsumLevel(view_name)
	local consum_level = nil
	if view_name == ViewName.RedEnvelopes then
		consum_level = RedEnvelopes.consumLvl
	elseif view_name == ViewName.Loser then
		consum_level = loserCounterattack.consumLvl
	end
	return consum_level
end

function RedEnvelopesData:GetOpenLevel(view_name)
	local open_level = nil
	if view_name == ViewName.RedEnvelopes then
		open_level = RedEnvelopes.openlevel
	elseif view_name == ViewName.Loser then
		open_level = loserCounterattack.openlevel
	end
	return open_level
end
------------------------------------------------------------
--屌丝逆天
------------------------------------------------------------
function RedEnvelopesData:GetLoserSign()
	return self.losersign
end

function RedEnvelopesData:IsLoserAllPickUp()
	local award_length = #loserCounterattack.awardcfg
	local sign = self.losersign
	local is_lingqu = 0
	if nil ~= sign then
		is_lingqu = bit:_and(1, bit:_rshift(sign, award_length - 1)) 
	end
	return is_lingqu > 0
end

function RedEnvelopesData:GetLoserRemindNum()
	local count = 0
	local cfg = self:GetLoserItemList()
	local role_power = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BATTLE_POWER)
	if nil == cfg then return end
	for i = 1, #cfg do
		if cfg[i].power <= role_power and 0 == cfg[i].sign then
			count = count + 1
		end
	end
	return count
end

function RedEnvelopesData:GetLoserItemList()
	local item_list = {}
	local cfg = loserCounterattack.awardcfg
	if nil == cfg then return end
	for i = 1, #cfg do
		if nil == cfg[i] then return end
		local item = cfg[i].award
		item.power = cfg[i].power
		item.consume = cfg[i].consume.count
		item.index = i
		table.insert(item_list, item)
	end
	item_list = self:GetLoserSignlist(item_list)
	table.sort(item_list, function (a,b)
		if a.sign ~= b.sign then
			return a.sign < b.sign
		else
			return a.power < b.power
		end
	end)

	return item_list
end

function RedEnvelopesData:GetLoserSignlist(reward_list)
	if nil == reward_list then return {} end
	local sign = self.losersign
	for i = 1, #reward_list do
		if nil == sign then break end
		local is_lingqu = bit:_and(1, bit:_rshift(sign, i - 1)) 
		reward_list[i].sign = is_lingqu
		if 1 == i then 
			reward_list[i].show_btn = true
		else
			reward_list[i].show_btn = reward_list[i - 1].sign > 0
		end
	end
	return reward_list
end