--[[
联运：迅雷版本
lizhuangzhuang
2015年11月19日15:46:55
]]

_G.XunLeiVersion = LianYunVersion:new(VersionConsts.XunLei);

-- 是否显示vip
function XunLeiVersion:IsShowXunleiTQ()
	return true;
end

--是否显示手机绑定
function XunLeiVersion:IsShowXunleiPhone()
	return true;
end


function XunLeiVersion:GetAutoCreateTime()
	return 30000;
end

--迅雷微端下载改成下载迅雷盒子
function XunLeiVersion:DownloadMClient()
	local cfg = LianYunCfg[self.name];
	if not cfg then return; end
	local url = cfg.boxUrl;
	if not url then return; end
	_sys:browse(url);
end

---打开迅雷qq客服
function XunLeiVersion:OpenXunleiQQWeb()
	local cfg = LianYunCfg[self.name];
	if not cfg then return; end
	local url = cfg.webQQUrl;
	if not url then return; end
	_sys:browse(url);
end;

---打开迅雷手机绑定
function XunLeiVersion:OpenXunleiPhoneBind()
	local cfg = LianYunCfg[self.name];
	if not cfg then return; end
	local url = cfg.phoneBind;
	if not url then return; end
	_sys:browse(url);
end;