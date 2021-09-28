----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local equip = 
{
	[820037001] = {	id = 820037001, name = '4级火系灵符', desc = '全系  0转  不分派别  灵符  79级\n<c=purple>基础属性：</c>\n    火系伤害  +744\n    火系抗性  +496\n<c=purple>附加属性</c>：\n    获得后随机生成', icon = 5266, skin_M_ID = { -1,  }, partID = 7, rank  = 3, levelReq = 79, sellItem = 150, canSale = 0, roleType = 0, properties = { { type = 1086, value = 744, rankFactor = 1 }, { type = 1087, value = 496, rankFactor = 1 }, { type = 0, value = 0, rankFactor = 0 }, { type = 0, value = 0, rankFactor = 0 }, } , ext_properties = { { type = 1, args = 1004, minVal = 71, maxVal = 87 }, { type = 1, args = 1005, minVal = 71, maxVal = 87 }, { type = 1, args = 1006, minVal = 71, maxVal = 87 }, { type = 1, args = 1007, minVal = 71, maxVal = 87 }, { type = 0, args = 0, minVal = 0, maxVal = 0 }, } , slot1Type = 0, slot2Type = 0, slot3Type = 0, slot4Type = 0, get_way = '在【花亭平原·谭雨轩】处祭炼获得', C_require = 0, M_require = 0, model = 210, sortid = 4674.0, skin_F_ID = { -1,  }, CanSeparation = 0, SeparationCost = 0, SeparationItem = { { ItemID = 0 , ItemCount = 0}, { ItemID = 0 , ItemCount = 0}, { ItemID = 0 , ItemCount = 0} } , skin_ZM_ID = { -1,  }, skin_ZF_ID = { -1,  }, skin_XM_ID = { -1,  }, skin_XF_ID = { -1,  }, warehouseType = 1, refineItemId = 11, refineItemCount = 1, refineAllItems = {  }, RecommendPrice = 1000, iconFemale = 5266, MinPrice = 0, MaxPrice = 0, resolveTips = 0, legendsTips = 0, flyingLevel = 0, legendsProp = {}},
	[820037002] = {	id = 820037002, name = '4级水系灵符', desc = '全系  0转  不分派别  灵符  79级\n<c=purple>基础属性：</c>\n    水系伤害  +744\n    水系抗性  +496\n<c=purple>附加属性</c>：\n    获得后随机生成', icon = 5262, skin_M_ID = { -1,  }, partID = 7, rank  = 3, levelReq = 79, sellItem = 150, canSale = 0, roleType = 0, properties = { { type = 1084, value = 744, rankFactor = 1 }, { type = 1085, value = 496, rankFactor = 1 }, { type = 0, value = 0, rankFactor = 0 }, { type = 0, value = 0, rankFactor = 0 }, } , ext_properties = { { type = 1, args = 1004, minVal = 71, maxVal = 87 }, { type = 1, args = 1005, minVal = 71, maxVal = 87 }, { type = 1, args = 1006, minVal = 71, maxVal = 87 }, { type = 1, args = 1007, minVal = 71, maxVal = 87 }, { type = 0, args = 0, minVal = 0, maxVal = 0 }, } , slot1Type = 0, slot2Type = 0, slot3Type = 0, slot4Type = 0, get_way = '在【花亭平原·谭雨轩】处祭炼获得', C_require = 0, M_require = 0, model = 210, sortid = 4674.0, skin_F_ID = { -1,  }, CanSeparation = 0, SeparationCost = 0, SeparationItem = { { ItemID = 0 , ItemCount = 0}, { ItemID = 0 , ItemCount = 0}, { ItemID = 0 , ItemCount = 0} } , skin_ZM_ID = { -1,  }, skin_ZF_ID = { -1,  }, skin_XM_ID = { -1,  }, skin_XF_ID = { -1,  }, warehouseType = 1, refineItemId = 11, refineItemCount = 1, refineAllItems = {  }, RecommendPrice = 1000, iconFemale = 5262, MinPrice = 0, MaxPrice = 0, resolveTips = 0, legendsTips = 0, flyingLevel = 0, legendsProp = {}},
	[820037003] = {	id = 820037003, name = '4级土系灵符', desc = '全系  0转  不分派别  灵符  79级\n<c=purple>基础属性：</c>\n    土系伤害  +744\n    土系抗性  +496\n<c=purple>附加属性</c>：\n    获得后随机生成', icon = 5270, skin_M_ID = { -1,  }, partID = 7, rank  = 3, levelReq = 79, sellItem = 150, canSale = 0, roleType = 0, properties = { { type = 1088, value = 744, rankFactor = 1 }, { type = 1089, value = 496, rankFactor = 1 }, { type = 0, value = 0, rankFactor = 0 }, { type = 0, value = 0, rankFactor = 0 }, } , ext_properties = { { type = 1, args = 1004, minVal = 71, maxVal = 87 }, { type = 1, args = 1005, minVal = 71, maxVal = 87 }, { type = 1, args = 1006, minVal = 71, maxVal = 87 }, { type = 1, args = 1007, minVal = 71, maxVal = 87 }, { type = 0, args = 0, minVal = 0, maxVal = 0 }, } , slot1Type = 0, slot2Type = 0, slot3Type = 0, slot4Type = 0, get_way = '在【花亭平原·谭雨轩】处祭炼获得', C_require = 0, M_require = 0, model = 210, sortid = 4674.0, skin_F_ID = { -1,  }, CanSeparation = 0, SeparationCost = 0, SeparationItem = { { ItemID = 0 , ItemCount = 0}, { ItemID = 0 , ItemCount = 0}, { ItemID = 0 , ItemCount = 0} } , skin_ZM_ID = { -1,  }, skin_ZF_ID = { -1,  }, skin_XM_ID = { -1,  }, skin_XF_ID = { -1,  }, warehouseType = 1, refineItemId = 11, refineItemCount = 1, refineAllItems = {  }, RecommendPrice = 1000, iconFemale = 5270, MinPrice = 0, MaxPrice = 0, resolveTips = 0, legendsTips = 0, flyingLevel = 0, legendsProp = {}},
	[820037004] = {	id = 820037004, name = '4级木系灵符', desc = '全系  0转  不分派别  灵符  79级\n<c=purple>基础属性：</c>\n    木系伤害  +744\n    木系抗性  +496\n<c=purple>附加属性</c>：\n    获得后随机生成', icon = 5274, skin_M_ID = { -1,  }, partID = 7, rank  = 3, levelReq = 79, sellItem = 150, canSale = 0, roleType = 0, properties = { { type = 1090, value = 744, rankFactor = 1 }, { type = 1091, value = 496, rankFactor = 1 }, { type = 0, value = 0, rankFactor = 0 }, { type = 0, value = 0, rankFactor = 0 }, } , ext_properties = { { type = 1, args = 1004, minVal = 71, maxVal = 87 }, { type = 1, args = 1005, minVal = 71, maxVal = 87 }, { type = 1, args = 1006, minVal = 71, maxVal = 87 }, { type = 1, args = 1007, minVal = 71, maxVal = 87 }, { type = 0, args = 0, minVal = 0, maxVal = 0 }, } , slot1Type = 0, slot2Type = 0, slot3Type = 0, slot4Type = 0, get_way = '在【花亭平原·谭雨轩】处祭炼获得', C_require = 0, M_require = 0, model = 210, sortid = 4674.0, skin_F_ID = { -1,  }, CanSeparation = 0, SeparationCost = 0, SeparationItem = { { ItemID = 0 , ItemCount = 0}, { ItemID = 0 , ItemCount = 0}, { ItemID = 0 , ItemCount = 0} } , skin_ZM_ID = { -1,  }, skin_ZF_ID = { -1,  }, skin_XM_ID = { -1,  }, skin_XF_ID = { -1,  }, warehouseType = 1, refineItemId = 11, refineItemCount = 1, refineAllItems = {  }, RecommendPrice = 1000, iconFemale = 5274, MinPrice = 0, MaxPrice = 0, resolveTips = 0, legendsTips = 0, flyingLevel = 0, legendsProp = {}},

};
function get_db_table()
	return equip;
end
