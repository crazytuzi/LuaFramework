DefendFuben.JOIN_LEVEL = 30
DefendFuben.JOIN_MEMBER_COUNT = 2

DefendFuben.nFubenMapTemplateId = 1800

DefendFuben.szFubenClass = "DefendFubenBase"

DefendFuben.MIN_DISTANCE = 1000

DefendFuben.KICK_TIME = 5

DefendFuben.REVIVE_TIME = 5

DefendFuben.nMingXiaHitMsgInteval = 10

DefendFuben.tbReward = 
{
	[0] = {{"Item", 4523, 1}},
	[1] = {{"Item", 4524, 1}}, 		
	[2] = {{"Item", 4525, 1}},
	[3] = {{"Item", 4526, 1}},
	[4] = {{"Item", 4527, 1}},
	[5] = {{"Item", 4528, 1}}, 		
	[6] = {{"Item", 4529, 1}, {"AddTimeTitle", 5033, 10*24*60*60}},
}

DefendFuben.tbSeriesSetting = 
{
	["Dialog"] = {
		[1] = {FontSize = 18, NotShow = 0, XPos = 0, YPos = 0, Color = "FiveElement1", Index = "Series_Jin1",  Text = "天王"},
		[2] = {FontSize = 18, NotShow = 0, XPos = 0, YPos = 0, Color = "FiveElement2", Index = "Series_Mu1",   Text = "逍遥"},
		[3] = {FontSize = 18, NotShow = 0, XPos = 0, YPos = 0, Color = "FiveElement3", Index = "Series_Shui1", Text = "峨嵋"},
		[4] = {FontSize = 18, NotShow = 0, XPos = 0, YPos = 0, Color = "FiveElement4", Index = "Series_Huo1",  Text = "桃花"},
		[5] = {FontSize = 18, NotShow = 0, XPos = 0, YPos = 0, Color = "FiveElement5", Index = "Series_Tu1",   Text = "武当"},
	},
	["Monster"] = {
		[1] = {FontSize = 18, NotShow = 0, XPos = 0, YPos = 0, Color = "FiveElement1", Index = "Series_Jin2",  Text = "金"},
		[2] = {FontSize = 18, NotShow = 0, XPos = 0, YPos = 0, Color = "FiveElement2", Index = "Series_Mu2",   Text = "木"},
		[3] = {FontSize = 18, NotShow = 0, XPos = 0, YPos = 0, Color = "FiveElement3", Index = "Series_Shui2", Text = "水"},
		[4] = {FontSize = 18, NotShow = 0, XPos = 0, YPos = 0, Color = "FiveElement4", Index = "Series_Huo2",  Text = "火"},
		[5] = {FontSize = 18, NotShow = 0, XPos = 0, YPos = 0, Color = "FiveElement5", Index = "Series_Tu2",   Text = "土"},
	}, 
	
}

function DefendFuben:GetReward(nRound)
	return self.tbReward[nRound] and  self:FormatReward(self.tbReward[nRound]) 
end

function DefendFuben:FormatReward(tbAllReward)
	tbAllReward = Lib:CopyTB(tbAllReward)

	local tbFormatReward = {}
	for _,tbReward in ipairs(tbAllReward) do
		if tbReward[1] == "AddTimeTitle" then
			tbReward[3] = tbReward[3] + GetTime()
		end
		table.insert(tbFormatReward,tbReward)
	end

	return tbFormatReward
end

function DefendFuben:GetSeriesSetting(szKey,nSeries)
	local tbSetting = DefendFuben.tbSeriesSetting[szKey] and DefendFuben.tbSeriesSetting[szKey][nSeries]
	return tbSetting and Lib:CopyTB(tbSetting)
end