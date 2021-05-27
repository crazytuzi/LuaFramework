
--#include "..\..\..\language\LangCode.txt"
SCENE_ANSWER_WAIT_TIME 	=  30
SceneAnswerConfig =
{
	activityTime	= 1800,
	enterLevelLimit	= {0, 70},
	beginTime		= 10,
	answerCd		= 10,
	waitCd			= SCENE_ANSWER_WAIT_TIME,
	answerBankId	= 1,
	answerNum 		= 30,
	sceneId			= 79,
	enterPos		= {28,35},
	answerAward =
	{
		rightAward =
		{
			addPoint	= 5,
		},
	},
	answerAutoToPos =
	{
		{ 29, 62, 35, 55 },
		{ 39, 48, 45, 40 },
		{ 18, 47, 24, 40 },
		{ 28, 33, 35, 27 },
	},
	monstersNum = 10,
	monsters =
	{
		{ monsterId=1157, sceneId=79, num=1, pos={21,58}, livetime=SCENE_ANSWER_WAIT_TIME, weight=1,},
		{ monsterId=1157, sceneId=79, num=1, pos={25,52}, livetime=SCENE_ANSWER_WAIT_TIME, weight=1,},
		{ monsterId=1157, sceneId=79, num=1, pos={28,46}, livetime=SCENE_ANSWER_WAIT_TIME, weight=1,},
		{ monsterId=1157, sceneId=79, num=1, pos={34,45}, livetime=SCENE_ANSWER_WAIT_TIME, weight=1,},
		{ monsterId=1157, sceneId=79, num=1, pos={38,47}, livetime=SCENE_ANSWER_WAIT_TIME, weight=1,},
		{ monsterId=1157, sceneId=79, num=1, pos={34,37}, livetime=SCENE_ANSWER_WAIT_TIME, weight=1,},
		{ monsterId=1157, sceneId=79, num=1, pos={43,33}, livetime=SCENE_ANSWER_WAIT_TIME, weight=1,},
		{ monsterId=1157, sceneId=79, num=1, pos={39,26}, livetime=SCENE_ANSWER_WAIT_TIME, weight=1,},
		{ monsterId=1157, sceneId=79, num=1, pos={26,36}, livetime=SCENE_ANSWER_WAIT_TIME, weight=1,},
		{ monsterId=1157, sceneId=79, num=1, pos={32,68}, livetime=SCENE_ANSWER_WAIT_TIME, weight=1,},
		{ monsterId=1157, sceneId=79, num=1, pos={34,66}, livetime=SCENE_ANSWER_WAIT_TIME, weight=1,},
		{ monsterId=1157, sceneId=79, num=1, pos={36,62}, livetime=SCENE_ANSWER_WAIT_TIME, weight=1,},
		{ monsterId=1157, sceneId=79, num=1, pos={38,61}, livetime=SCENE_ANSWER_WAIT_TIME, weight=1,},
		{ monsterId=1157, sceneId=79, num=1, pos={40,60}, livetime=SCENE_ANSWER_WAIT_TIME, weight=1,},
		{ monsterId=1157, sceneId=79, num=1, pos={42,54}, livetime=SCENE_ANSWER_WAIT_TIME, weight=1,},
		{ monsterId=1157, sceneId=79, num=1, pos={43,50}, livetime=SCENE_ANSWER_WAIT_TIME, weight=1,},
		{ monsterId=1157, sceneId=79, num=1, pos={45,48}, livetime=SCENE_ANSWER_WAIT_TIME, weight=1,},
		{ monsterId=1157, sceneId=79, num=1, pos={48,48}, livetime=SCENE_ANSWER_WAIT_TIME, weight=1,},
		{ monsterId=1157, sceneId=79, num=1, pos={12,44}, livetime=SCENE_ANSWER_WAIT_TIME, weight=1,},
		{ monsterId=1157, sceneId=79, num=1, pos={14,42}, livetime=SCENE_ANSWER_WAIT_TIME, weight=1,},
		{ monsterId=1157, sceneId=79, num=1, pos={17,40}, livetime=SCENE_ANSWER_WAIT_TIME, weight=1,},
		{ monsterId=1157, sceneId=79, num=1, pos={18,37}, livetime=SCENE_ANSWER_WAIT_TIME, weight=1,},
		{ monsterId=1157, sceneId=79, num=1, pos={23,32}, livetime=SCENE_ANSWER_WAIT_TIME, weight=1,},
		{ monsterId=1157, sceneId=79, num=1, pos={25,28}, livetime=SCENE_ANSWER_WAIT_TIME, weight=1,},
		{ monsterId=1157, sceneId=79, num=1, pos={28,25}, livetime=SCENE_ANSWER_WAIT_TIME, weight=1,},
		{ monsterId=1157, sceneId=79, num=1, pos={30,20}, livetime=SCENE_ANSWER_WAIT_TIME, weight=1,},
		{ monsterId=1157, sceneId=79, num=1, pos={32,17}, livetime=SCENE_ANSWER_WAIT_TIME, weight=1,},
	},
	answerBuff =
	{
		{ buffId=989, scoreRate=2, },
		{ buffId=990, scoreRate=0.5, },
	},
	monsterGatherEffext =
	{
		{ weight=1, buffId=989, msg=Lang.ScriptTips.SceneAnswer008, },
		{ weight=1, buffId=990, msg=Lang.ScriptTips.SceneAnswer009,},
		{ weight=1, removeBuff=true, msg=Lang.ScriptTips.SceneAnswer010, },
		{ weight=1, msg=Lang.ScriptTips.SceneAnswer011, },
	},
	sceneRank =
	{
		rankName  	= Lang.Rank.SceneAnswerRank,
		rankLimit 	= 10,
		displayCount = 50,
	},
}
