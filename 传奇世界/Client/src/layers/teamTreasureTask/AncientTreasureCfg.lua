--Author:		bishaoqing
--DateTime:		2016-05-16 15:49:02
--Region:		相关配置
local Arg = 
{
	BronzeTreasure = 1,--青铜
	SilverTreasure = 2,--白银
	GoldenTreasure = 3,--黄金

	MaxStatus = 4,--宝藏任务最大进度
}

--根据rank等级获取名字
function Arg.GetTaskRankName( nTaskRank )
	-- body
	-- game.getStrByKey("tip")
	local strName = ""
	if nTaskRank == Arg.BronzeTreasure then
		strName = "青铜宝藏"
	elseif nTaskRank == Arg.SilverTreasure then
		strName = "白银宝藏"
	elseif nTaskRank == Arg.GoldenTreasure then
		strName = "黄金宝藏"
	end
	return strName
end

return Arg