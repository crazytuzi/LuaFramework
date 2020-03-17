--[[
联运：顺网
lizhuangzhuang
2015年11月12日14:25:23
]]

_G.SwjoyVersion = LianYunVersion:new(VersionConsts.Swjoy);

function SwjoyVersion:IsShowSwjoyTQ()
	return true;
end

function SwjoyVersion:IsShowSwjoyVIP()
	return true;
end

function SwjoyVersion:LiaojieVip()
	local cfg = LianYunCfg[self.name];
	if not cfg then return; end
	local url = cfg.liaojieVip;
	if not url then return; end
	_sys:browse(url);
end;

function SwjoyVersion:UpViplvl()
	local cfg = LianYunCfg[self.name];
	if not cfg then return; end
	local url = cfg.upViplvl;
	if not url then return; end
	_sys:browse(url);
end;