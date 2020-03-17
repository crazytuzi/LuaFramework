--[[
常量
冰魂
zhangshuhui
2015年9月24日11:09:16
]]

_G.BingHunConsts = {};
BingHunConsts.BingHunMax = BingHunUtil:GetBingHunMax();
--属性总数量
BingHunConsts.AttrsCount = 6;
-- 冰魂属性
function BingHunConsts:GetAttrs(order)
	if order == 1 then
		return {"att", "def", "hp"};
	elseif order == 2 then
		return {"att", "def", "hp"};
	elseif order == 3 then
		return {"att", "def", "hp"};
	elseif order == 4 then
		return {"att", "def", "hp"};
	elseif order == 5 then
		return {"att", "def", "hp"};
	elseif order == 6 then
		return {"att", "def", "hp"};
	elseif order == 7 then
		return {"att", "def", "hp"};
	elseif order == 8 then
		return {"att", "def", "hp"};
	end
end
-- 得到冰魂属性名称
function BingHunConsts:GetAttrName(attr)
	if attr == "att" then
		return StrConfig["lianti1000"];
	elseif attr == "def" then
		return StrConfig["lianti1001"];
	elseif attr == "hp" then
		return StrConfig["lianti1002"];
	elseif attr == "cri" then
		return StrConfig["lianti1003"];
	elseif attr == "defcri" then
		return StrConfig["lianti1004"];
	elseif attr == "dodge" then
		return StrConfig["lianti1005"];
	elseif attr == "hit" then
		return StrConfig["lianti1006"];
	elseif attr == "absatt" then
		return StrConfig["lianti1007"];
	elseif attr == "defparry" then
		return StrConfig["lianti1008"];
	elseif attr == "parryvalue" then
		return StrConfig["lianti1009"];
	elseif attr == "subdef" then
		return StrConfig["lianti1010"];
	end
	return "";
end