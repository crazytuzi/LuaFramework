--[[
任务简单工厂
2015年5月15日10:04:01
haohu
]]

_G.QuestFactory = {}

--@param showRefresh: 本次添加任务是否播放刷新特效 -- 可选, 默认播放
function QuestFactory:CreateQuest( questId, flag, state, goals, showRefresh )

	-- WriteLog(LogType.Normal,true,'----CreateQuest',questId,QuestConsts.HuoYueDuQuestPrefix);

	local class;
	if t_quest[questId] ~= nil then
		class = QuestTrunkVO
	elseif t_dailyquest[questId] ~= nil then
		class = QuestDailyVO
	elseif t_questlevel[questId] ~= nil then
		class = QuestLevelVO
	elseif t_achievement[questId] ~= nil then
		class = QuestAchievementVO
	elseif t_transferquest[questId] ~= nil then
		class = QuestZhuanZhiVO
	elseif t_questrandom[questId] ~= nil then
		class = QuestRandomVO
	elseif t_todayquest[questId] ~= nil then
		class = QuestLieMoVO
	elseif type(questId) == "string" then
		if questId:lead( QuestConsts.RandomQuestPrefix ) then
			class = QuestRandomVO
		elseif questId:lead( QuestConsts.WaBaoQuestPrefix ) then
			class = QuestWaBaoVO
		elseif questId:lead( QuestConsts.FengYaoQuestPrefix ) then
			class = QuestFengYaoVO;
		elseif questId:lead( QuestConsts.SuperQuestPrefix ) then
			class = QuestSuperVO;
		elseif questId:lead( QuestConsts.HuoYueDuQuestPrefix ) then
			class = QuestHuoYueDuVO;
		elseif questId:lead( QuestConsts.ExpDungeonQuestPrefix ) then
			class = QuestExpDungeonVO;
		elseif questId:lead( QuestConsts.SingleDungeonQuestPrefix ) then
			class = QuestSingleDungeonVO;
		elseif questId:lead( QuestConsts.TeamDungeonQuestPrefix ) then
			class = QuestTeamDungeonVO;
		elseif questId:lead( QuestConsts.TeamExpDungeonQuestPrefix ) then
			class = QuestTeamExpDungeonVO;
		elseif questId:lead( QuestConsts.TaoFaQuestPrefix ) then
			class = QuestTaoFaVO;
		elseif questId:lead( QuestConsts.AgoraQuestPrefix ) then
			class = QuestAgoraVO;
		elseif questId:lead( QuestConsts.XianYuanCaveQuestPrefix ) then
			class = QuestXianYuanCaveVO;
		elseif questId:lead( QuestConsts.BabelQuestPrefix ) then
			class = QuestBabelVO;
		elseif questId:lead( QuestConsts.GodDynastyQuestPrefix ) then
--			class = QuestGodDynastyVO;
			return nil;--关闭这个任务显示
		elseif questId:lead( QuestConsts.BXDGQuestPrefix ) then
--			class = QuestBXDGVO;
			return nil;--关闭这个任务显示
		elseif questId:lead( QuestConsts.SGZCQuestPrefix ) then
--			class = QuestSGZCVO;
			return nil;--关闭这个任务显示
		elseif questId:lead( QuestConsts.UnionJoinQuestPrefix ) then
			class = QuestUnionJoinVO;
		elseif questId:lead( QuestConsts.ArenaQuestPrefix ) then
			class = QuestArenaVO;
		elseif questId:lead( QuestConsts.HangQuestPrefix ) then
			class = QuestHangVO;
		end
	else
		_debug:throwException( string.format( "quest id:%s not found in quest configs", questId ) );
		return
	end
	local quest = class:new( questId, flag );
	if quest then
		quest:SetState( state, showRefresh );
		local goalInfo = goals[1]
		if goalInfo then
			local count = goalInfo.current_count
			quest:SetGoalInfo(goalInfo);
			quest:SetGoalCount( count )
		end
	end
	return quest
end