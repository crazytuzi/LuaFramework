PrivilegeData = PrivilegeData or BaseClass()

PrivilegeData.TEQUAN_CHANGE = "tequan_change"

function PrivilegeData:__init()
	if PrivilegeData.Instance then
		ErrorLog("[PrivilegeData] Attemp to create a singleton twice !")
	end
	PrivilegeData.Instance = self

	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()
end

function PrivilegeData:__delete()
	PrivilegeData.Instance = nil
end

function PrivilegeData:SetPrivilegeInfo(protocol)
	self.v1_sign = protocol.v1_sign
	self.v2_sign = protocol.v2_sign
	self.v3_sign = protocol.v3_sign
	self.v1_time = protocol.v1_time + Status.NowTime
	self.v2_time = protocol.v2_time + Status.NowTime
	self.v3_time = protocol.v3_time + Status.NowTime
	self.price = protocol.price 
	self.sale_price = protocol.sale_price
	
	self:DispatchEvent(PrivilegeData.TEQUAN_CHANGE)
end

function PrivilegeData:PrasePrivilegeInfo(sign)
	--1现是否贵族  2是否曾经激活贵族 3是否可以购买 4是否续费 5是否不可领取 6掉落次数控制
	local list = {
		[1] = false,
		[2] = false,
		[3] = false,
		[4] = false,
		[5] = false,
		[6] = false,
	}
	
	if nil == sign then return list end
	for i = 1, 6 do
		local _sign = bit:_and(1, bit:_rshift(sign, i - 1))
		if _sign == 1 then list[i] = true end
	end

	return list
end

function PrivilegeData:CanOneKeyFnish()
	for i = 1, 3 do
		if self:IsTeQuan(i) then
			if PrivilegeCardCfg.Pros[i].isOneKeyFinishCLFB == 1 then return true end
		end
	end
	return false
end

function PrivilegeData:IsTeQuan(index)
	local list = self:PrasePrivilegeInfo(self["v" .. index .. "_sign"])
	return list[1] or false
end

function PrivilegeData:GetPrivilegeTimeByIdx(index)
	if nil == index then return 0 end
	return self["v" .. index .. "_time"]
end

function PrivilegeData:GetPrivilegePrice()
	return {self.price, self.sale_price}
end

function PrivilegeData:GetPrivilegeInfo()
	local list = {}
	list[1] = self:PrasePrivilegeInfo(self.v1_sign)
	list[2] = self:PrasePrivilegeInfo(self.v2_sign)
	list[3] = self:PrasePrivilegeInfo(self.v3_sign)

	--奖励过期
	for k, v in pairs (list) do
		if v[2] == true and self["v" .. k .. "_time"] - Status.NowTime <= 0 then
			v[5] = true
		end
	end

	list[0] = table.remove(list, 1)
	return list
end


function PrivilegeData:GetRemindNum()
	local list = self:GetPrivilegeInfo()
	for k,v in pairs(list) do
		if v[1] and not v[5] then return 1 end
	end
	return 0
end

function PrivilegeData.GetPrivilegeCfg()
	return PrivilegeCardCfg
end
