--[[
道具合成常量
zhangshuhui
2014年12月27日15:20:20
]]

_G.HeChengConsts = {};

--合成
HeChengConsts.TABHECHENG = "TABHECHENG";
--分解
HeChengConsts.TABFENJIE = "TABFENJIE";
--4层
HeChengConsts.CENGMAX = 4;

--翅膀合成提高概率的道具beginid
HeChengConsts.WINGRANTBEGINID = 140631201
--翅膀合成提高概率的道具endid
HeChengConsts.WINGRANTENDID = 140631204

-- 得到翅膀属性名称
function HeChengConsts:GetAttrName(attr)
	if attr == "att" then
		return StrConfig["hecheng23"];
	elseif attr == "def" then
		return StrConfig["hecheng24"];
	elseif attr == "hp" then
		return StrConfig["hecheng25"];
	elseif attr == "adddamage" then
		return StrConfig["hecheng26"];
	elseif attr == "subdamage" then
		return StrConfig["hecheng27"];
	end
	
	return "";
end