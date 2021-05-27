
--#include "..\..\language\LangCode.txt" once
GemGlobalConfig=
{
expAddInterval=300,
endureConsInterval=5,
maxWishVal=1000,
wishValUpRate=500,
getWishValWhenFail=10,
actorExp2GemExpRate=100,
upGradeReqItemId=1916,
upGradeProtectItemId=1917,
openHoleItemId=1922,
openHoleConsumeItemCnt=1,
openSuitHoleReqItemId=1007,
openSuitHoleReqItemCnt=0,
maxSmithCount=1000,
gemSmithLevel={5,10,15,20},
gemMinLvlOfUpLvl=40,
gemMinGradeOfUpQuality = 4,
gemMinLvOfSmith = 20,
maxGemSuitXPVal=200,
killActorAddXPVal=2,
killMonsterAddXPVal={
	{ xpVal=1, effectNumMin=1, effectNumMax=3},
	{ xpVal=1, effectNumMin=1, effectNumMax=3},
	{ xpVal=2, effectNumMin=3, effectNumMax=5},
	{ xpVal=2, effectNumMin=3, effectNumMax=5},
},
gemSmithPropMax = {
{21,393},
{31,393},
{23,373},
{33,373},
{39,156},
{37,156},
{35,156},
{17,2073},
{19,2073},
{84,249},
{85,249},
{86,79},
{80,-118},
{79,-118},
{78,-0.04},
{77,-0.04},
{87,0.067},
{88,0.134},
{59,0.117},
{22,0.06},
{32,0.06},
{24,0.06},
{34,0.06},
},
--#include "GemUpLevelExp.lua" once
--#include "GemUpSpriteChar.lua" once
--#include "GemUpQuality.lua" once
--#include "GemSuit.lua" once
--#include "GemSmithConfig\SmithConfig.lua" once
--#include "GemUpGrade.lua" once
--#include "GemDesc.lua" once
--#include "GemSmithConsume.lua" once
--#include "GemCompose.lua" once
}
