--[[
任务断档推荐简单工厂
2015年6月10日17:33:42
haohu
]]

_G.QuestRecommendFactory = {}
function QuestRecommendFactory:AutoCreateRecommend()
	--任务断档推荐类型
	local recommendTypes = {
		RecommendDaily,				-- 日环
		RecommendLieMo,				-- 猎魔
		RecommendHone,				-- 历练
		RecommendAgora,				-- 悬赏
		RecommendWaterDungeon,		-- 流水副本  经验副本
		--RecommendTeamExp,			-- 组队经验
		--RecommendTeam,				-- 组队挑战
		RecommendXianYuanCave,		-- 打宝地宫
		RecommendBabel,				-- 封神试炼
		--RecommendGodDynasty,		-- 诛仙阵
		--RecommendBXDG,				-- 变形地宫
		--RecommendSGZC,				-- 上古战场
	}
	--哪个符合条件用哪个
	for k, v in pairs(recommendTypes) do
		local recommend = v:new()
		if recommend:IsAvailable() then
			return recommend
		end
	end
end
function QuestRecommendFactory:CreateRecommend( recommendStr )
	--都没的话再根据配表
	if not recommendStr then return; end
	local param = split( recommendStr, "," )
	local recommendType = tonumber( param[1] )
	local class
	if recommendType == QuestConsts.RecommendType_Hang then
		class = RecommendHang
	elseif recommendType == QuestConsts.RecommendType_Dungeon then
		class = RecommendDungeon
	elseif recommendType == QuestConsts.RecommendType_TimeDugeon then
		class = RecommendTimeDungeon
	elseif recommendType == QuestConsts.RecommendType_WaterDungeon then
		class = RecommendWaterDungeon
	elseif recommendType == QuestConsts.RecommendType_Cave then
		class = RecommendCave
	elseif recommendType == QuestConsts.RecommendType_RandomQuest then
		class = RecommendRandomQuest
	elseif recommendType == QuestConsts.RecommendType_Wabao then
		class = RecommendWabao
	elseif recommendType == QuestConsts.RecommendType_Fengyao then
		class = RecommendFengyao
	elseif recommendType == QuestConsts.RecommendType_HuoYueDu then
		class = RecommendHuoYueDu
	elseif recommendType == QuestConsts.RecommendType_XianYuanCave then
		class = RecommendXianYuanCave
	elseif recommendType == QuestConsts.RecommendType_TaoFa then
		class = RecommendTaoFa
	elseif recommendType == QuestConsts.RecommendType_Daily then
		class = RecommendDaily
	else
		Debug( string.format( "quest break recommend config error, recommendType:%s", recommendType ) )
		return
	end
	local recommend = class:new()
	recommend:Init( param )
	return recommend
end