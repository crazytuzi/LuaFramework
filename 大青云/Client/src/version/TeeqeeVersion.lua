--[[
联运:快玩
lizhuangzhuang
2015年11月27日16:10:15
]]

_G.TeeqeeVersion = LianYunVersion:new(VersionConsts.KuaiWan);

function TeeqeeVersion:Charge(amount)
	local cfg = LianYunCfg[self.name];
	if not cfg then 
		print("未找到版本配置",self.name);
		return;
	end
	local url = cfg.chargeUrl;
	if not url then
		print("未找到充值链接",self.name);
		return;
	end
	local startId = 9197000;
	local sid = toint(_G.loginInfo.skey);
	sid = sid + startId;
	url = url .. sid;
	_sys:browse(url);
end
