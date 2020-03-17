--[[
游戏中用到的文本
lizhuangzhuang
2014年8月19日13:46:59
]]

_G.StrConfig = {};

-- local metaTable = {};
-- metaTable.__index = function(table,key)
	-- return '@'..key;
-- end
-- setmetatable(StrConfig,metaTable);

function StrConfig:Add(table)
	for k,v in pairs(table) do
		StrConfig[k] = v;
	end
end