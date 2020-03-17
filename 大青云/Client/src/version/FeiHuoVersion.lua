--[[
联运:飞火平台
lizhuangzhuang
2015年11月12日14:30:10
]]

_G.FeiHuoVersion = LianYunVersion:new(VersionConsts.FeiHuo);

function FeiHuoVersion:IsShowFeiHuoTQ()
	return true;
end

function FeiHuoVersion:IsHideMClient()
	return true;
end

function FeiHuoVersion:IsShowFeihuoPhoneBind()
	return true;
end

function FeiHuoVersion:FeihuoPhoneBind()
	local cfg = LianYunCfg[self.name];
	if not cfg then return; end
	local url = cfg.phoneBind;
	if not url then return; end
	local skey = _sys:getGlobal("skey");
	local uid = _sys:getGlobal("uid");
	url = string.gsub(url,"{skey}",skey);
	url = string.gsub(url,"{uid}",uid);
	_sys:browse(url);
end


--http://plat.feihuo.com/url/index?type=tel_url&slug=dzz&user=(:username)&sid=(:server_id)
