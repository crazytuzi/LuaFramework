----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local equip = 
{
	[60032004] = {	id = 60032004, name = '命门之精铜护腕', desc = '全系  0转  不分派别  护手  4级\n<c=purple>基础属性：</c>\n    攻击  +45\n    气血  +218\n<c=purple>附加属性</c>：\n    获得后随机生成', icon = 10011200, skin_M_ID = { -1,  }, partID = 2, rank  = 3, levelReq = 4, sellItem = 40, canSale = 0, roleType = 0, properties = { { type = 1002, value = 45, rankFactor = 1 }, { type = 1001, value = 218, rankFactor = 1 }, { type = 0, value = 0, rankFactor = 0 }, { type = 0, value = 0, rankFactor = 0 }, } , ext_properties = { { type = 1, args = 1003, minVal = 17, maxVal = 17 }, { type = 1, args = 1004, minVal = 9, maxVal = 9 }, { type = 0, args = 0, minVal = 0, maxVal = 0 }, { type = 0, args = 0, minVal = 0, maxVal = 0 }, { type = 0, args = 0, minVal = 0, maxVal = 0 }, } , slot1Type = 0, slot2Type = 0, slot3Type = 0, slot4Type = 0, get_way = '主线任务获得', C_require = 0, M_require = 0, model = 210, sortid = 4674.0, skin_F_ID = { -1,  }, CanSeparation = 0, SeparationCost = 0, SeparationItem = { { ItemID = 0 , ItemCount = 0}, { ItemID = 0 , ItemCount = 0}, { ItemID = 0 , ItemCount = 0} } , skin_ZM_ID = { -1,  }, skin_ZF_ID = { -1,  }, skin_XM_ID = { -1,  }, skin_XF_ID = { -1,  }, warehouseType = 1, refineItemId = 11, refineItemCount = 200, refineAllItems = { 66210, 66211, 66212,  }, RecommendPrice = 1000, iconFemale = 10011201, MinPrice = 0, MaxPrice = 0, resolveTips = 0, legendsTips = 0, flyingLevel = 0, legendsProp = {}},

};
function get_db_table()
	return equip;
end
