Require("CommonScript/Item/Class/Unidentify.lua")
local tbUnidentify = Item:NewClass("UnidentifySeriesStone", "Unidentify");
tbUnidentify.szCostMoneyType = "Contrib"


local tbUnidentify2 = Item:NewClass("UnidentifyRefineStone", "Unidentify");
tbUnidentify2.szCostMoneyType = "Coin"


local tbUnidentify3 = Item:NewClass("UnidentifyJuexue", "Unidentify");
tbUnidentify3.szCostMoneyType = "SkillExp"