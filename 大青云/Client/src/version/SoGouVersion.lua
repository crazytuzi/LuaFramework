--[[
联运：搜狗
lizhuangzhuang
2015年12月7日11:12:12
]]

_G.SoGouVersion = LianYunVersion:new(VersionConsts.SoGou);

function SoGouVersion:IsSoGouShowVipBtn()
	return true;
end;

function SoGouVersion:IsSoGouSkinLogin()
	if _sys:getGlobal('gtype') and _sys:getGlobal('gtype')=="skin" then
		return true;
	end
	return false;
end

function SoGouVersion:IsSoGouGameBoxLogin()
	if _sys:getGlobal('gtype') and _sys:getGlobal('gtype')=="mini" then
		return true;
	end
	return false;
end

function SoGouVersion:SouGouDownGameBox()
	local cfg = LianYunCfg[self.name];
	if not cfg then return; end
	local url = cfg.downGameBox;
	if not url then return; end
	_sys:browse(url);
end;

function SoGouVersion:SougouDownSkin()
	local cfg = LianYunCfg[self.name];
	if not cfg then return; end
	local url = cfg.downSkin;
	if not url then return; end
	_sys:browse(url);
end;