--------------------------------------------------------------------------------------
-- 文件名:	ChargeIncreaseBase.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	付费累增
-- 应  用:  
---------------------------------------------------------------------------------------
ChargeIncreaseBase = class("ChargeIncreaseBase")
ChargeIncreaseBase.__index = ChargeIncreaseBase

local maxBuyNum = 30

function ChargeIncreaseBase:cotr()
	

end

function ChargeIncreaseBase:getCsvChargeIncrease()
	return g_DataMgr:getCsvConfig("ChargeIncrease") 
end

-- 
function ChargeIncreaseBase:getChargeIncreasePrice(index, typeName)
	local key = index > maxBuyNum and maxBuyNum or index
	return  self:getCsvChargeIncrease()[key][typeName]
end

--------------------------------------------------------

g_ChargeIncreaseBase = ChargeIncreaseBase.new()
