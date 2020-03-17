--[[
地图元素：传送点
2015年4月12日11:08:04
haohu
]]

_G.MapPortalVO = MapElementVO:new();


function MapPortalVO:GetClass()
	return MapPortalVO;
end

function MapPortalVO:IsInteractive()
	return true;
end

function MapPortalVO:GetType()
	return MapConsts.Type_Portal;
end

function MapPortalVO:GetLabelInfo()
	local labels = {};
	local cfg = t_portal[self.id];
	if cfg then
		table.push( labels, cfg.name );
		table.push( labels, cfg.description );
	end
	return labels;
end

function MapPortalVO:GetUIData()
	local vo = {};
	vo.x = self.x;
	vo.y = self.y;
	local labels = self:GetLabelInfo();
	for i = 1, #labels do
		vo["label"..i] = labels[i];
	end
	vo.labelColor = 0xffffff;
	vo.uid = self:ToString();
	return UIData.encode(vo);
end

-- 获取地图图标label
function MapPortalVO:GetLabel()
	local cfg = t_portal[self.id];
	return cfg and cfg.name or "portal id error"
end

function MapPortalVO:GetTipsTxt()
	local cfg = t_portal[self.id];
	if cfg then
		return string.format( StrConfig["map110"], cfg.name, cfg.description );
	end
	return "tool tip config missing";
end

function MapPortalVO:GetAsLinkage()
	local cfg = t_portal[self.id]
	if cfg then
		if cfg.type == 2 or cfg.type == 6 then -- 秘境传送门
			return "portal_fairyland"
		end
	end
	return "portal_normal" -- 普通传送门
end
