--[[
杀戮属性 工具类
2015年3月18日17:07:22
haohu
]]
_G.classlist['KillValueUtils'] = 'KillValueUtils'
_G.KillValueUtils = {};
KillValueUtils.objName = 'KillValueUtils'

function KillValueUtils:GetLevel(killValue)
	local level = 0;
	for id, cfg in pairs(t_killtask) do
		if killValue >= id then --killtask中id即为杀戮等级临界杀戮值
			level = math.max( cfg.level, level );
		end
	end
	return level;
end

function KillValueUtils:GetKillValueMaximum(level)
	if level == KillValueConsts:GetMaxLevel() then
		return KillValueConsts:GetMaxKillValue();
	end
	for id, cfg in pairs(t_killtask) do
		if level + 1 == cfg.level then
			return id;
		end
	end
end

function KillValueUtils:GetCfg(killValue)
	local currentId = 0;
	for id, cfg in pairs(t_killtask) do
		if killValue >= id then --killtask中id即为杀戮等级临界杀戮值
			currentId = math.max( id, currentId );
		end
	end
	return t_killtask[currentId];
end

-- 将属性表{ {type=x, val=x}, {...}, ... }解析成html形式
-- space : 水平间隔
function KillValueUtils:ParseAttrMap(attrMap, color, space)
	if not space then space = 104 end
	local htmlStr = "";
	local num = 0;
	for attrTypeStr, attrValue in pairs(attrMap) do
		num = num + 1;
		local attrType = AttrParseUtil.AttMap[attrTypeStr];
		local attrName = enAttrTypeName[ attrType ];
		local str = self:GetHtmlText( attrName.."  +"..attrValue, color );
		local margin = (num - 1) * space;
		local leading = -14;
		htmlStr = htmlStr .. self:SetTextformat( str, margin, leading );
	end
	return htmlStr;
end

function KillValueUtils:GetHtmlText( text, color )
	return string.format( "<font color='%s'>%s</font>", color, text );
end

function KillValueUtils:SetTextformat(text, margin, leading)
	return string.format( "<textformat leftmargin='%s' leading='%s'><p>%s</p></textformat>", margin, leading, text );
end

function KillValueUtils:GetHistoryAttrMap()
	local historyAttrMap = {};
	local killHistory = KillValueModel:GetKillHistory();
	if getTableLen(killHistory) ~= 0 then
		for level, num in pairs(killHistory) do
			local attrStr = self:GetAttrStr(level);
			local attrMap = AttrParseUtil:ParseAttrToMap(attrStr);
			for attrStr, attrValue in pairs(attrMap) do
				if not historyAttrMap[attrStr] then
					historyAttrMap[attrStr] = attrValue;
				else
					historyAttrMap[attrStr] = historyAttrMap[attrStr] + attrValue;
				end
			end
		end
	else
		local attrStr = self:GetAttrStr(1);
		local attrMap = AttrParseUtil:ParseAttrToMap(attrStr);
		for attrStr, _ in pairs(attrMap) do
			historyAttrMap[attrStr] = 0;
		end
	end
	return historyAttrMap;
end

function KillValueUtils:GetAttrStr(level)
	for id, cfg in pairs(t_killtask) do
		if cfg.level == level then
			return cfg.addition_props;
		end
	end
end