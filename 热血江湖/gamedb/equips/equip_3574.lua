----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local equip = 
{
	[357421000] = {	id = 357421000, name = '【灵符】罡灵护腕', desc = '符师  1转  不分派别  护手  42级\n<c=purple>基础属性：</c>\n    攻击  +262\n    气血  +1712\n<c=purple>附加属性</c>：\n    获得后随机生成', icon = 10407210, skin_M_ID = { -1,  }, partID = 2, rank  = 4, levelReq = 42, sellItem = 90, canSale = 0, roleType = 7, properties = { { type = 1002, value = 262, rankFactor = 1 }, { type = 1001, value = 1712, rankFactor = 1 }, { type = 0, value = 0, rankFactor = 0 }, { type = 0, value = 0, rankFactor = 0 }, } , ext_properties = { { type = 1, args = 1003, minVal = 65, maxVal = 79 }, { type = 1, args = 1004, minVal = 42, maxVal = 51 }, { type = 1, args = 1007, minVal = 41, maxVal = 50 }, { type = 0, args = 0, minVal = 0, maxVal = 0 }, { type = 0, args = 0, minVal = 0, maxVal = 0 }, } , slot1Type = 0, slot2Type = 0, slot3Type = 0, slot4Type = 0, get_way = '副本<c=purple>虎穴别院(困难、组队）</c>、[魔王]全东熙、洪钧掉落获得', C_require = 1, M_require = 0, model = 210, sortid = 5024.0, skin_F_ID = { -1,  }, CanSeparation = 0, SeparationCost = 0, SeparationItem = { { ItemID = 0 , ItemCount = 0}, { ItemID = 0 , ItemCount = 0}, { ItemID = 0 , ItemCount = 0} } , skin_ZM_ID = { -1,  }, skin_ZF_ID = { -1,  }, skin_XM_ID = { -1,  }, skin_XF_ID = { -1,  }, warehouseType = 1, refineItemId = 11, refineItemCount = 450, refineAllItems = { 66210, 66211, 66212,  }, RecommendPrice = 1000, iconFemale = 10407211, MinPrice = 0, MaxPrice = 0, resolveTips = 0, legendsTips = 0, flyingLevel = 0, legendsProp = {}},
	[357451000] = {	id = 357451000, name = '【灵符】震气指环', desc = '符师  1转  不分派别  项链  42级\n<c=purple>基础属性：</c>\n    防御  +130\n    气血  +2889\n<c=purple>附加属性</c>：\n    获得后随机生成', icon = 10407500, skin_M_ID = { -1,  }, partID = 5, rank  = 4, levelReq = 42, sellItem = 90, canSale = 0, roleType = 7, properties = { { type = 1003, value = 130, rankFactor = 1 }, { type = 1001, value = 2889, rankFactor = 1 }, { type = 0, value = 0, rankFactor = 0 }, { type = 0, value = 0, rankFactor = 0 }, } , ext_properties = { { type = 1, args = 1001, minVal = 2140, maxVal = 2616 }, { type = 1, args = 1004, minVal = 42, maxVal = 51 }, { type = 1, args = 1006, minVal = 58, maxVal = 71 }, { type = 0, args = 0, minVal = 0, maxVal = 0 }, { type = 0, args = 0, minVal = 0, maxVal = 0 }, } , slot1Type = 0, slot2Type = 0, slot3Type = 0, slot4Type = 0, get_way = '副本<c=purple>虎穴别院(困难、组队）</c>、[魔王]全东熙、洪钧掉落获得', C_require = 1, M_require = 0, model = 210, sortid = 5059.0, skin_F_ID = { -1,  }, CanSeparation = 0, SeparationCost = 0, SeparationItem = { { ItemID = 0 , ItemCount = 0}, { ItemID = 0 , ItemCount = 0}, { ItemID = 0 , ItemCount = 0} } , skin_ZM_ID = { -1,  }, skin_ZF_ID = { -1,  }, skin_XM_ID = { -1,  }, skin_XF_ID = { -1,  }, warehouseType = 1, refineItemId = 11, refineItemCount = 450, refineAllItems = { 66116, 66117, 66118,  }, RecommendPrice = 1000, iconFemale = 10407500, MinPrice = 0, MaxPrice = 0, resolveTips = 0, legendsTips = 0, flyingLevel = 0, legendsProp = {}},

};
function get_db_table()
	return equip;
end
