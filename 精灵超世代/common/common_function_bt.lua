-- --------------------------------------------------------------------
-- BT版本相关内容
-- --------------------------------------------------------------------
--属性倍数
local BT_Attr_Rate = 11
--战斗伤害、加血数值倍数
local BT_Battle_Rate = 11
--战斗力数值
local BT_Power_Rate = 11

-- 宝可梦属性数值转换
function changeBtValueForHeroAttr (value, attr_str)
	if type(value) ~= "number" then return value end

    if attr_str == "hp" or attr_str == "hp_max" or attr_str == "atk" or attr_str == "def" then
        print("BT属性：键：",attr_str," 值：",value)
        value = value * BT_Attr_Rate
        print("转换后：", value)
    else
    	print("BT属性未转换：键：",attr_str," 值：",value)
    end
    return value
end

--战斗伤害、加血数值倍数
function changeBtValueForBattle(value)
	if type(value) ~= "number" then return value end
	return value * BT_Battle_Rate
end

--战斗力数值
function changeBtValueForPower(value)
	if type(value) ~= "number" then return value end
	print("BT战斗力：",value, value * BT_Power_Rate)
	return value * BT_Power_Rate
end