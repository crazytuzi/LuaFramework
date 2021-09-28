----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local equip = 
{
	[160036004] = {	id = 160036004, name = '暴烈之血玉戒指', desc = '全系  0转  不分派别  戒指  16级\n<c=purple>基础属性：</c>\n    攻击  +103\n    命中  +56\n<c=purple>附加属性</c>：\n    获得后随机生成', icon = 10201600, skin_M_ID = { -1,  }, partID = 6, rank  = 3, levelReq = 16, sellItem = 40, canSale = 0, roleType = 0, properties = { { type = 1002, value = 103, rankFactor = 1 }, { type = 1004, value = 56, rankFactor = 0 }, { type = 0, value = 0, rankFactor = 0 }, { type = 0, value = 0, rankFactor = 0 }, } , ext_properties = { { type = 1, args = 1002, minVal = 95, maxVal = 95 }, { type = 1, args = 1012, minVal = 95, maxVal = 95 }, { type = 0, args = 0, minVal = 0, maxVal = 0 }, { type = 0, args = 0, minVal = 0, maxVal = 0 }, { type = 0, args = 0, minVal = 0, maxVal = 0 }, } , slot1Type = 0, slot2Type = 0, slot3Type = 0, slot4Type = 0, get_way = '主线任务获得', C_require = 0, M_require = 0, model = 210, sortid = 4674.0, skin_F_ID = { -1,  }, CanSeparation = 0, SeparationCost = 0, SeparationItem = { { ItemID = 0 , ItemCount = 0}, { ItemID = 0 , ItemCount = 0}, { ItemID = 0 , ItemCount = 0} } , skin_ZM_ID = { -1,  }, skin_ZF_ID = { -1,  }, skin_XM_ID = { -1,  }, skin_XF_ID = { -1,  }, warehouseType = 1, refineItemId = 11, refineItemCount = 250, refineAllItems = { 66210, 66211, 66212,  }, RecommendPrice = 1000, iconFemale = 10201600, MinPrice = 0, MaxPrice = 0, resolveTips = 0, legendsTips = 0, flyingLevel = 0, legendsProp = {}},

};
function get_db_table()
	return equip;
end
