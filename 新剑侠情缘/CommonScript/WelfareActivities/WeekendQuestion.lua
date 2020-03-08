if not MODULE_GAMESERVER then
    Activity.WeekendQuestion = Activity.WeekendQuestion or {}
end
local tbAct = MODULE_GAMESERVER and Activity:GetClass("WeekendQuestion") or Activity.WeekendQuestion

tbAct.DATA_GROUP = 66
tbAct.DATA_DAY   = 1
tbAct.RIGHT      = 2
tbAct.ANSWERD    = 3
tbAct.AWARD_FLAG = 4
tbAct.NPC_FLAG   = 5
tbAct.START_TIME = 6
tbAct.ALL_RIGHT  = 7

tbAct.MAX_COUNT  = 8
tbAct.TIME_OUT   = 30
tbAct.JOIN_LEVEL = 30
tbAct.MIN_DISTANCE = 1000

tbAct.RIGHT_AWARD = {{"BasicExp", 30}, {"Item", 4521, 1}}
tbAct.WRONG_AWARD = {{"BasicExp", 10}, {"Item", 4522, 1}}

tbAct.ALL_RIGHT_AWARD = 
{
	[10] = {{"AddTimeTitle", 5030, 10*24*60*60}},
	[16] = {{"AddTimeTitle", 5031, 10*24*60*60}},
}

tbAct.END_AWARD = {}

function tbAct:GetComplete(pPlayer)
	local pP = pPlayer or me
    return pP.GetUserValue(self.DATA_GROUP, self.ANSWERD)
end

function tbAct:GetRightNum()
    return me.GetUserValue(self.DATA_GROUP, self.RIGHT)
end

function tbAct:FormatReward(tbAllReward)
	tbAllReward = tbAllReward and Lib:CopyTB(tbAllReward) or {}

	local tbFormatReward = {}
	for _,tbReward in ipairs(tbAllReward) do
		if tbReward[1] == "AddTimeTitle" then
			tbReward[3] = tbReward[3] + GetTime()
		end
		table.insert(tbFormatReward,tbReward)
	end

	return tbFormatReward
end