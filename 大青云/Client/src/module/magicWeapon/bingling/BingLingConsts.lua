--



_G.BingLingConsts = {};

-- 兵灵属性
function BingLingConsts:GetAttrs(id)
	if id == 1 then
		return {"att", "def", "hp", "cri"};
	elseif id == 2 then
		return {"att", "def", "hp", "hit"};
	elseif id == 3 then
		return {"att", "def", "hp", "crivalue"};
	elseif id == 4 then
		return {"att", "def", "hp", "subdef"};
	elseif id == 5 then
		return {"att", "def", "hp", "absatt"};
	end
end

-- 得到兵灵属性名称
function BingLingConsts:GetAttrName(attr)
	if attr == "att" then
		return StrConfig["magicWeapon036"];
	elseif attr == "def" then
		return StrConfig["magicWeapon037"];
	elseif attr == "hp" then
		return StrConfig["magicWeapon038"];
	elseif attr == "cri" then
		return StrConfig["magicWeapon039"];
	elseif attr == "hit" then
		return StrConfig["magicWeapon040"];
	elseif attr == "crivalue" then
		return StrConfig["magicWeapon041"];
	elseif attr == "subdef" then
		return StrConfig["magicWeapon042"];
	elseif attr == "absatt" then
		return StrConfig["magicWeapon043"];
	end
	return "";
end

-- 得到兵灵名称
function BingLingConsts:GetBingLingName(id)
	if id == 1 then
		return StrConfig["magicWeapon047"];
	elseif id == 2 then
		return StrConfig["magicWeapon044"];
	elseif id == 3 then
		return StrConfig["magicWeapon045"];
	elseif id == 4 then
		return StrConfig["magicWeapon048"];
	elseif id == 5 then
		return StrConfig["magicWeapon046"];
	end
	return "";
end

-- 兵灵最高阶
BingLingConsts.MaxLevel = 10;