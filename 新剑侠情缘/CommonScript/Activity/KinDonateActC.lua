if not MODULE_GAMESERVER then
	Activity.KinDonateAct = Activity.KinDonateAct or {}
end
local tbAct = MODULE_GAMESERVER and Activity:GetClass("KinDonateAct") or Activity.KinDonateAct

-- 捐献满x次获得奖励
tbAct.tbRewards = {
	[10] = {{"Contrib", 1000}, },
	[50] = {{"Contrib", 1500}, },
}