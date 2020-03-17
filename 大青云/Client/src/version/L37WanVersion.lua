--[[
联运：37wan
lizhuangzhuang
2015年11月19日16:52:10
]]

_G.L37WanVersion = LianYunVersion:new(VersionConsts["37wan"]);

function L37WanVersion:IsShowBindPhone()
	return true;
end;

function L37WanVersion:L37wanBindPhone()
	local cfg = LianYunCfg[self.name];
	if not cfg then return; end
	local url = cfg.phoneBind;
	if not url then return; end
	
	local skey = _sys:getGlobal("skey");
	local username = _sys:getGlobal("uid");
	local actor = printguid(MainPlayerController:GetRoleID())
	local time = GetServerTime();
	local sign = string.md5(skey..username..actor..time..cfg.key)

	url = string.gsub(url,"{skey}",skey);
	url = string.gsub(url,"{uid}",username);
	url = string.gsub(url,"{roleId}",actor);
	url = string.gsub(url,"{curTime}",time);
	url = string.gsub(url,"{sign}",sign);

	_sys:browse(url);
end