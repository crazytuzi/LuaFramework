--[[
联运:酷狗版本
lizhuangzhuang
2015年11月23日22:47:06
]]

_G.KuGouVersion = LianYunVersion:new(VersionConsts.KuGou);

--酷狗微端下载改成下载盒子
function KuGouVersion:DownloadMClient()
	local cfg = LianYunCfg[self.name];
	if not cfg then return; end
	local url = cfg.boxUrl;
	if not url then return; end
	_sys:browse(url);
end

function KuGouVersion:IsShowKugouVip()
	return true;
end
