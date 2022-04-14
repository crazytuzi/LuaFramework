QuickBuyModel = QuickBuyModel or class('QuickBuyModel', BaseModel)
local QuickBuyModel = QuickBuyModel

function QuickBuyModel:ctor()
    QuickBuyModel.Instance = self

    self:Reset()
    self.ATTR = {

		[1] = "Current HP",

		[2] = "HP",

		[3] = "Speed (pixel/s), multiplier of 20",

		[4] = "ATK",

		[5] = "DEF",

		[6] = "Penetration",

		[7] = "Accuracy",

		[8] = "Dodge",

		[9] = "Crit",

		[10] = "TEN",

		[11] = "M. ATK",

		[12] = "M. DEF",

		[13] = "Attack Boost",

		[14] = "Damage Reduction",

		[15] = "Hit Chance",

		[16] = "Dodge Rate",

		[17] = "Armor",

		[18] = "Armor Penetration",

		[19] = "Block Rate",

		[20] = "Pierce",

		[21] = "Crit Rate",

		[22] = "Crit Resistance",

		[23] = "Concentrated Strike Rate",

		[24] = "Concentrated Strike Resistance",

		[25] = "Crit Damage",

		[26] = "Concentrated Strike Damage",

		[27] = "Increased Skill Damage",

		[28] = "Skill Damage Reduction",

		[29] = "Strike Rate",

		[30] = "Chance of Weakening",

		[31] = "Crit Damage Reduction",

		[32] = "Normal attack damage increase",

		[33] = "Block damage",

		[34] = "PVP Damage Resistance",

		[35] = "PVP Armor",

		[36] = "PVP Armor Penetration",

		[37] = "Boss Damage Boost",

		[38] = "Monster damage bonus",

		[39] = "Offensive skill CP",

		[40] = "Defensive skill CP",

		[41] = "Damage Reduction",

		[42] = "PVP Damage Resistance",

		[43] = "Concentrated skill damage reduction",

		[44] = "CP",

		[45] = "Absolute attack",

		[46] = "Absolute Evasion",

		[1100] = "Total Attribute Percentage (Overall)",

		[1102] = "HP Bonus",

		[1103] = "Speed bonus",

		[1104] = "Attack bonus",

		[1105] = "Defense Bonus",

		[1106] = "Penetration Bonus",

		[1107] = "Accuracy Bonus",

		[1108] = "Dodge Bonus",

		[1109] = "Crit Bonus",

		[1110] = "Tenacity Bonus",

		[1111] = "Spell damage bonus",

		[1112] = "Spell Defense Bonus",

		[1200] = "Total Attribute Percentage (Partial)",

		[1202] = "HP",

		[1204] = "ATK",

		[1205] = "DEF",

		[1206] = "Penetration",

		[1207] = "Accuracy",

		[1208] = "Dodge",

		[1209] = "Crit",

		[1210] = "TEN",

		[1211] = "M. ATK",

		[1212] = "M. DEF",

		[1302] = "Basic HP",

		[1304] = "Basic Attack",

		[1305] = "Basic Defense",

		[1306] = "Basic Penetration",

		[1404] = "Weapon Attack",

		[1406] = "Weapon Penetration",

		[1502] = "Armor HP",

		[1505] = "Armor Defense",

		[1604] = "Accessory Attack",

		[2000] = "EXP Bonus",

		[2001] = "Gold Drop Rate",

		[2002] = "Drop rate",

		[2003] = "Increase defense every 3 levels",

		[2004] = "Increase HP every 3 levels",

		[2005] = "Increase attack every 3 levels",

		[2006] = "Increase ATK by 10",

		[2007] = "Increase damage by 2% done to bosses every 50 levels",

		[2009] = "Reduce skill cd by",

		[2010] = "Enhancement Bonus",

    }
end

function QuickBuyModel:Reset()

end

function QuickBuyModel.GetInstance()
    if QuickBuyModel.Instance == nil then
        QuickBuyModel.new()
    end
    return QuickBuyModel.Instance
end

function QuickBuyModel:GetAttrNameByIndex(index)
    return self.ATTR[index]
end



