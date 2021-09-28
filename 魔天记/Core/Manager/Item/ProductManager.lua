require "Core.Info.ProductInfo";

ProductManager = {};
ProductManager._productConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_PRODUCT)
ProductManager._productAttrConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_PRODUCT_ATTR)
local iconAtlasConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_PRODUCT_ATLAS)
local iconAtlas = {}
-- logTrace(#iconAtlasConfig .. "______" .. table.maxn(iconAtlasConfig))
-- for k,v in pairs(iconAtlasConfig) do log(k .. "___" .. v) end
local _sortfunc = table.sort

ProductManager.COMMONITEMSTARTID = 1000
SpecialProductId =
{
	-- 灵石
	Money = 1,
	-- 元宝
	Gold = 2,
	-- 绑定元宝
	BGold = 3,
	-- 经验
	Exp = 4,
	-- 竞技积分
	PVPScore = 5,
	-- 真气
	Vp = 6,
	-- 法宝碎片
	TrumpCoin = 7,
	-- 命星道具 
	TrumpCoin = 8,
	
	GongXunCoin = 9,-- 功勋
	-- 战场积分
	ZhanChangJiFen = 10,
	-- 帮贡
	BangGong = 11,
}

SpecialProductDes =
{
	[1] = LanguageMgr.Get("SpecialProductDes/label1"),
	[2] = LanguageMgr.Get("SpecialProductDes/label2"),
	[3] = LanguageMgr.Get("SpecialProductDes/label3"),
	[4] = LanguageMgr.Get("SpecialProductDes/label4"),
	[5] = LanguageMgr.Get("SpecialProductDes/label5"),
	[6] = LanguageMgr.Get("SpecialProductDes/label6"),
}

ProductManager.ST_TYPE_IN_BACKPACK = 1; -- 在背包
ProductManager.ST_TYPE_IN_EQUIPBAG = 2; -- 装备栏
ProductManager.ST_TYPE_IN_TRUMPBAG = 3; -- 法宝背包
ProductManager.ST_TYPE_IN_TRUMPEQUIPBAG = 4; -- 法宝装备
ProductManager.ST_TYPE_IN_PLANT_BAG = 5; -- 种子仓库
ProductManager.ST_TYPE_IN_EXT_EQUIP = 6; -- 额外装备栏

--装备品质白色,绿色,蓝色,紫色,金色,橙色,红色
EquipQuality = { White = 0,Green = 1,Blue = 2,Purple = 3,Gold = 4,Orange = 5,Red = 6}



ProductManager.ST_TYPE_IN_OTHER = 7; -- 其他地方

-- 	0:资源	1:装备	2:宝石	3:材料	4:药品	5:基础道具	6:灵药	7:碎片	8:法宝	9:宠物	10:宠物技能书	11:坐骑	12:翅膀	13:灵药种子
ProductManager.type_0 = 0; -- 资源
ProductManager.type_1 = 1; -- 装备
ProductManager.type_2 = 2; -- 宝石
ProductManager.type_3 = 3; -- 材料
ProductManager.type_4 = 4; -- 药品
ProductManager.type_5 = 5; -- 基础道具
ProductManager.type_6 = 6; -- 丹药

ProductManager.MAXQUALITY = 4
local productItem = {}
function ProductManager.GetProductById(id)
	local _id = tonumber(id)
	if(productItem[_id] == nil) then
		productItem[_id] = ConfigManager.Clone(ProductManager._productConfig[_id])
	end
	
	if(productItem[_id] == nil) then
		log("找不到物品" .. id)
	end
	return productItem[_id]
end

function ProductManager.GetProductInfoById(id, am)
	local info = nil
	local data = ConfigManager.Clone(ProductManager._productConfig[tonumber(id)]);
	if(data) then
		data.spId = id;
		data.am = tonumber(am);
		info = ProductInfo:New();
		info:Init(data);
	end 
	return info;
end

function ProductManager.GetProductKindName(kind, t)
	local t = t or 1
	local res = LanguageMgr.Get("ProductInfo/name_kind_" .. t .. "_" .. kind);
	if(res == "") then
		res = LanguageMgr.Get("common/unKnow")
	end
	return res;
end

function ProductManager.GetPTypeName(t)
	local res = LanguageMgr.Get("ProductInfo/type_name_" .. t);
	if(res == "") then
		res = LanguageMgr.Get("common/unKnow")
	end
	return res;
end

function ProductManager.GetProductsList(type, kind)
	
	local res = {};
	local res_index = 1;
	
	for key, value in pairs(ProductManager._productConfig) do
		
		if value.type == type and value.kind == kind then
			res[res_index] = ConfigManager.Clone(value);
			res_index = res_index + 1;
		end
	end
	
	if res_index >= 2 then
		
		_sortfunc(res, function(a, b) return a.id < b.id end)
		
	end
	
	return res;
	
end


function ProductManager.GetProductAttrByIdAndLevel(id, level)
	level = level or 1
	local key = id .. "_" .. level
	return ConfigManager.Clone(ProductManager._productAttrConfig[key])
end

-- 获取方形品质框的SpriteName
function ProductManager.GetQulitySpriteName(qc)
	return "quality_rect" .. qc
end

-- 获取圆形品质框的SpriteName
function ProductManager.GetSphQulitySpriteName(qc)
	return "quality_circle" .. qc
end

-- 根据id设置icon的uiSprite资源
function ProductManager.SetIconSprite(uiSprite, id)
	--[[    if not id then
        for k,v in pairs(iconAtlasConfig) do
            id = k
            if math.random(0,50) == 1 then  break  end
        end
    end
    logTrace(tostring(id).."__"..tostring(iconAtlasConfig[id]))
    --]]
	local ids = tostring(id);
	local atlasName = iconAtlasConfig[ids];
	local atlas = iconAtlas[atlasName];
	if atlas == nil then
		local atlasGo = Resourcer.GetPrefab("Prefabs/IconAtlas", atlasName);
		if atlasGo then
			atlas = atlasGo:GetComponent("UIAtlas");
			iconAtlas[atlasName] = atlas;
		else
			atlas = nil;
			ids = "";
			
			Error("product not found : id =" .. id)
		end
	end
	uiSprite.atlas = atlas;
	uiSprite.spriteName = ids;
	-- logTrace(tostring(atlas).."__"..tostring(uiSprite.atlas))
end 