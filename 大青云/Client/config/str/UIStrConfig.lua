--[[
UI上使用到的文本
lizhuangzhuang
2014年8月19日13:51:12
]]

_G.UIStrConfig = {};

-- local metaTable = {};
-- metaTable.__index = function(table,key)
	-- return '@'..key;
-- end
-- setmetatable(UIStrConfig,metaTable);

function UIStrConfig:Add(table)
	for k,v in pairs(table) do
		UIStrConfig[k] = v;
	end
end
