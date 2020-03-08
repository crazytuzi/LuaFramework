Require("CommonScript/Item/Define.lua")

Player.Stronger = Player.Stronger or {}
local Stronger = Player.Stronger

Stronger.RECOMMEND_TIMEFRAME = "OpenLevel49"
Stronger.MAX_RECOMMEND_STONE_COUNT = 7

Stronger.Type =
{
	Strengthen = 1,
	Stone = 2,
	Refine = 3,
	Horse = 4,
	Partner = 5,
	PartnerCard = 6,
	ZhenYuan = 7,
	JingMai = 8,
	ZhenFa = 9,
	SkillBook = 10,
	JueXue = 11,
	SkillPoint = 12,
}

--根据战力排行划分档次
Stronger.tbRankList =
{
	[1] = {1,3},
	[2] = {4,10},
	[3] = {11,20},
	[4] = {21,30},
	[5] = {31,40},
	[6] = {41,50},
	[7] = {51,70},
	[8] = {71,90},
	[9] = {91,110},
	[10] = {111,130},
	[11] = {131,150},
	[12] = {151,200},
	[13] = {201,250},
	[14] = {251,300},
	[15] = {301,350},
	[16] = {351,400},
	[17] = {401,450},
	[18] = {451,500},
}

Stronger.tbRecommendEquipPos =
{
	Item.EQUIPPOS_HEAD,
	Item.EQUIPPOS_BODY,
	Item.EQUIPPOS_BELT,
	Item.EQUIPPOS_WEAPON,
	Item.EQUIPPOS_FOOT,
	Item.EQUIPPOS_CUFF,
	Item.EQUIPPOS_AMULET,
	Item.EQUIPPOS_RING,
	Item.EQUIPPOS_NECKLACE,
	Item.EQUIPPOS_PENDANT,
}

Stronger.tbHorseEquipPos =
{
	Item.EQUIPPOS_HORSE,
	Item.EQUIPPOS_REIN,
	Item.EQUIPPOS_SADDLE,
	Item.EQUIPPOS_PEDAL,
}

--根据排名获取推荐的档次
function Stronger:GetRecommendRank(nFightPowerRank)
	local nRank = -1;
	for nRecommendRank, tbRange in ipairs( self.tbRankList ) do
		if tbRange[1] <= nFightPowerRank and nFightPowerRank <= tbRange[2] then
			nRank = nRecommendRank;
			break;
		end
	end
	return nRank;
end
