----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local equip = 
{
	[600054005] = {	id = 600054005, name = '超级千层底', desc = '全系  0转  不分派别  鞋子  60级\n<c=purple>基础属性：</c>\n    气血  +6385\n    躲闪  +370\n<c=purple>附加属性</c>：\n    获得后随机生成', icon = 3617, skin_M_ID = { -1,  }, partID = 4, rank  = 5, levelReq = 60, sellItem = 275, canSale = 1, roleType = 0, properties = { { type = 1001, value = 6385, rankFactor = 1 }, { type = 1005, value = 370, rankFactor = 0 }, { type = 0, value = 0, rankFactor = 0 }, { type = 0, value = 0, rankFactor = 0 }, } , ext_properties = { { type = 1, args = 1001, minVal = 4337, maxVal = 4337 }, { type = 1, args = 1003, minVal = 120, maxVal = 120 }, { type = 1, args = 1005, minVal = 68, maxVal = 68 }, { type = 1, args = 1005, minVal = 68, maxVal = 68 }, { type = 0, args = 0, minVal = 0, maxVal = 0 }, } , slot1Type = 0, slot2Type = 0, slot3Type = 0, slot4Type = 0, get_way = '活动获得', C_require = 0, M_require = 0, model = 210, sortid = 3447.0, skin_F_ID = { -1,  }, CanSeparation = 1, SeparationCost = 320, SeparationItem = { { ItemID = -65731 , ItemCount = 1}, { ItemID = 0 , ItemCount = 0}, { ItemID = 0 , ItemCount = 0} } , skin_ZM_ID = { -1,  }, skin_ZF_ID = { -1,  }, skin_XM_ID = { -1,  }, skin_XF_ID = { -1,  }, warehouseType = 1, refineItemId = 11, refineItemCount = 450, refineAllItems = { 66210, 66211, 66212,  }, RecommendPrice = 1000, iconFemale = 3617, MinPrice = 0, MaxPrice = 0, resolveTips = 0, legendsTips = 0, flyingLevel = 0, legendsProp = {}},

};
function get_db_table()
	return equip;
end
