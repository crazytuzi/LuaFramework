if not MODULE_GAMESERVER then
    Activity.NewYearChris = Activity.NewYearChris or {}
end
local tbAct = MODULE_GAMESERVER and Activity:GetClass("NewYearChris") or Activity.NewYearChris

tbAct.nWishGiftSaveGrp = 147

tbAct.nWishesLeft = 7	--剩余许愿次数
