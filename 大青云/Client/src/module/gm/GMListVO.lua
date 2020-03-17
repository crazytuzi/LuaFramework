--[[
GM列表VO
lizhuangzhuang
2015年10月14日21:09:38
]]

_G.GMListVO = {};

function GMListVO:new(data,listType)
	local obj = {};
	obj.type = listType;
	obj.roleId = data.roleId;
	obj.name = data.name;
	obj.prof = data.prof;
	obj.level = data.level;
	obj.vipLevel = data.vipLevel;
	obj.charge = data.charge;
	obj.guildName = data.guildName;
	obj.guildUid = data.guildUid;
	obj.mac = data.mac;
	obj.time = data.time;
	--
	for k,v in pairs(GMListVO) do
		if type(v) == "function" then
			obj[k] = v;
		end
	end
	return obj;
end

function GMListVO:GetUIData()
	local data = {};
	data.id = self.roleId;
	data.guildUid = self.guildUid;
	data.tf1 = self.name;
	data.tf2 = PlayerConsts:GetProfName(self.prof);
	data.tf3 = "Lv." .. self.level;
	local vipStr = "";
	if VipController:GetVipTypeStateByFlag(self.vipLevel, VipConsts.TYPE_DIAMOND) == 1 then
		vipStr = StrConfig["gm027"];
	elseif VipController:GetVipTypeStateByFlag(self.vipLevel, VipConsts.TYPE_GOLD) == 1 then
		vipStr = StrConfig["gm028"];
	elseif VipController:GetVipTypeStateByFlag(self.vipLevel, VipConsts.TYPE_SUPREME) == 1 then
		vipStr = StrConfig["gm029"];
	end
	local vipLevel = VipController:GetVipLevelByFlag(self.vipLevel);
	vipStr = vipStr .. "Lv." .. vipLevel;
	data.tf4 = vipStr;
	data.tf5 = self.charge;
	if self.type == GMConsts.T_UnMac then
		data.tf6 = "-";
	else
		local now = GetServerTime();
		if self.time <= now then
			data.tf6 = StrConfig["gm031"];
		else
			local day,hour,min,sec = CTimeFormat:sec2formatEx(self.time-now);
			if day > 0 then
				data.tf6 = day..StrConfig["gm032"];
			elseif hour > 0 then
				data.tf6 = hour..StrConfig["gm033"];
			elseif min > 0 then
				data.tf6 = min..StrConfig["gm034"];
			else
				data.tf6 = sec..StrConfig["gm035"];
			end
		end
	end
	data.tf7 = self.guildName;
	if self.guildUid~="" and self.guildUid~="0_0" then
		data.btnText = StrConfig["gm030"];
	end
	return UIData.encode(data);
end