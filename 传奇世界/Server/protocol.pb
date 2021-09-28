
…∞
protocol.proto"P
LoginWorldUpdateRet
rank (
loginUserNum (
queuiWaitTime ("[
LoginChooseWorldReq
openID (	
	sessionID (	
serverID (
worldID ("G
LoginCreateUserReq
userName (	
userPwd (	
create ("!
LoginCreateUserRet
ret ("á
LoginCreatePlayer
userName (	
sex (
userID (	
worldID (
school (
modelID (
	worldName (	"z
RoleBaseInfo
roleID (	
name (	
level (
	worldName (	
school (
sex (
mapID ("a
LoginCreatePlayerRet
userID (	
roleID (	
roles (2.RoleBaseInfo
ret ("L
LoginDeletePlayerReq
userID (	
roleID (	
sessionToken (	"6
LoginDeletePlayerRet
roleID (	
result ("ÿ
LoginGatewayInfoRet
userID (	
loginIpAddr (	
port (
	startTick (
	sessionID (
roles (2.RoleBaseInfo
lockdate (

lockreason (	
sessionToken	 (	
result
 ("≤
LoginLoadPlayerInfoReq
userID (	
dbID (	
worldID (
realID (
	startTick (
mapID (
	sessionID (
platID (
openid	 (	
clientVersion
 (	
systemSoftware (	
systemHardware (	
telecomOper (	
network (	
screenWidth (
screenHight (
density (
loginChannel (
cpuHardware (	
memory (
gLRender (	
	gLVersion (	
deviceId (	
	pay_token (	

pf (	
pfkey (	
sessionToken (	
roleName (	
appStartType ("
LoginUnloadPlayerReq"'
LoginLoadPlayerRet
	starttick ("!
LoginTickoutRet
reason ("
LoginExit2RoleChooseReq"0
LoginRandNameReq
worldID (
sex ("1
LoginRandNameRet
name (	
worldID ("o
MsdkLoginChooseWorldReq
flatform (	
openid (	
openkey (	
worldID (
serverID (">
LoginRoleLockStatusRet

lockReason (	
lockDate ("8
LoginActiveUserReq
openID (	

activeCode (	""
LoginActiveUserRet
code (";
LoginVerifySessionTokenReq
userID (	
token (	"
LoginClientExitLoginReq"
EnvoyJoinReq
model ("
EnvoyJoinRet"
EnvoyOutReq"
EnvoyOutRet"
EnvoyAgainReq" 
EnvoyAgainRet
endTime ("#
EnvoyEnterNextReq
option ("
EnvoyEnterNextRet"
EnvoyGetInfoReq"G
EnvoyGetInfoRet
floor (
endTime (
isExperience ("/
CreateFaction
facName (	
cType ("o
CreateFactionRet
result (
facName (	

playername (	
factionRank (
	factionID ("
AchieveGetCount"|
AchieveGetCountRet
achieveCount (

titleCount (
achieveLevel (
achievePoint (
attrData (	"
AchieveGetAchieveData"4
AchieveData
	achieveID (

finishTime ("6
AchieveProgress
	eventType (
progress ("h
AchieveGetAchieveDataRet!
achieveData (2.AchieveData)
achieveProgress (2.AchieveProgress"
AchieveGetTieleData"J
AchieveTitile
titleID (

finishTime (
isValidTitle ("F
AchieveTitleProgress
titleID (
total (
finish ("Ö
AchieveGetTieleDataRet
attrData (	$
achieveTitle (2.AchieveTitile3
achieveTitleProgress (2.AchieveTitleProgress""
AchieveSetTitle
titleID ("%
AchieveSetTitleRet
titleID ("
AchieveRemoveTitle"(
AchieveRemoveTitleRet
titleID ("%
AchieveLoadTitleID
titleID (":
AchieveGetNewAchieve
	achieveID (
titleID ("O
ActivityReq
modelID (

activityID (
flag (
index ("b
ActivityReward
itemID (
count (
bind (
strength (
	timeLimit ("è
ActivityModel1
status (
arg1 (
progress (
reward (2.ActivityReward
cycleStartTime (
cycleEndTime ("∫
ActivityModel2
index (
status (
	groupName (	
oldType (
oldPrice (
disType (
disPrice (
disDesc (	
reward	 (2.ActivityReward"o
ActivityModel5
index (
status (
need (2.ActivityReward
reward (2.ActivityReward"a
ActivityModel6
status (
arg1 (
progress (
reward (2.ActivityReward"b
ActivityModel8
status (
index (
progress (
reward (2.ActivityReward"O
ActivityLevel
level (
status (
reward (2.ActivityReward"U
ActivityMonthCard
surplus (
status (
reward (2.ActivityReward"`
ActivityOnline
time (
endTime (
status (
reward (2.ActivityReward"e
ActivitySevenFestival
index (
status (
prog (
reward (2.ActivityReward"ô
ActivitySign
month (
day (#

signInData (2.ActivityReward
signDay (
isToday (
	reSignDay (
reSignCount ("º
ActivityRet
modelID (

activityID (
desc (	
	startTick (
endTick (
model1 (2.ActivityModel1
model2 (2.ActivityModel2
model5 (2.ActivityModel5
model6	 (2.ActivityModel6
model8
 (2.ActivityModel8
sign (2.ActivitySign
level (2.ActivityLevel
online (2.ActivityOnline-
sevenFestival (2.ActivitySevenFestival%
	monthCard (2.ActivityMonthCard"º
ActivityListData
modelID (

activityID (
activityName (	
redDot (
index (
order (
	lableType (
	leftLabel (
link	 (	
pic
 ("<
ActivityList
tab (
data (2.ActivityListData".
ActivityListRet
list (2.ActivityList"
ActivitySignIn"2
ActivitySignInRet
itemID (
count ("!
ActivityReSignIn
times ("6
ActivityReSignInRet
reward (2.ActivityReward"/
ActivityActCode
gameID (
code ("%
ActivityActCodeRet
errCode ("m
ActivitySevenFestivalBoxInfo
index (
point (
status (
reward (2.ActivityReward"ñ
ActivitySevenFestivalInfo
point (

totalPoint (
	countdown (

countdown2 (+
info (2.ActivitySevenFestivalBoxInfo
day (
redDot1 (
redDot2 (
redDot3	 (
redDot4
 (
redDot5 (
redDot6 (
redDot7 ("N
ActivityChargeRet
monthCardSurplus (
monthCardSurplus_luxury ("(
ActivityUseItemProtocol
nSolt ("
ActivityUseItemRetProtocol"&
ActivityPushOnlineTime
time ("
DigMineOpen"F
DigMineOpenRet
canExchange (
reward (2.ActivityReward"
DigMineExchange"
DigMineJoin"
DigMineQuit",
DigMineStart
flag (
mineID ("?
DigOffMineReward
itemID (
count (
type ("`
DigOffMineRet
logout (
digTime (
exp (!
reward (2.DigOffMineReward"

DigOffMine
quality (	"
DigOffMineRew"
DigMineMaxReward"d
DigMineSimulationSync
totalProgress (
progress (
	mineCount (
timeout ("
DigMineSimulationFinish"
DigMineSimulationQuit"w
InvadePushData
surplusTime (
integral (
nextIntegral (
monsterNum1 (
monsterNum2 (" 
InvadeHasReward
state ("
InvadeReward"2
InvadeRewardRet
reward (2.ActivityReward"
UndefinedJoin"
UndefinedKillInfo"+
UndefinedInfo
tick (
name (	"4
UndefinedKillInfoRet
info (2.UndefinedInfo"7
RankReq
tab (
page (
	factionID ("V
RankData
rank (
roleSID (	
name (	
school (
value ("_
RankFactionData
rank (
	factionID (
name (	
level (
battle ("ô

RankReqRet
tab (
size (
selfRank (
rankData (2	.RankData%
factionData (2.RankFactionData
glamour (2	.RankData"
RankNo1Protocol"
RankGetNo1Protocol"%
RankGetNo1RetProtocol
name (	"
RankGlamour"/
RankGlamourRet
name (	
glamour ("
ApprenticeReq
name (	"*
	MasterRet
name (	
roleSID (	"
MasterRefuse
roleSID (	"
MasterAgree
roleSID (	"
	MasterReq
name (	".
ApprenticeRet
name (	
roleSID (	"#
ApprenticeRefuse
roleSID (	""
ApprenticeAgree
roleSID (	"
ApprenticeRecommend"o
MasterRecommend
roleSID (	
name (	
level (
school (
isOnline (
flag ("D
ApprenticeRecommendRet

cd (
list (2.MasterRecommend"]
ApprenticeApply
flag (
roleSID (	
name (	
school (
level ("3
ApprenticeApplyRet
roleSID (	
flag ("
MasterInformation"Ä

MasterInfo
roleSID (	
name (	
school (
level (
battle (
isOnline (

finishTask ("V
MasterInformationRet

initiative (
list (2.MasterInfo
hasTask ("
ApprenticeReward"
ApprenticeBetray"4
ApprenticePushFinish
who (
roleSID (	"
ApprenticeFinish"
MasterApplyList"4
MasterApplyListRet
list (2.MasterRecommend"&
MasterInitiative

initiative ("$
MasterDeleteApply
roleSID (	"$
MasterGetPosition
roleSID (	";
MasterGetPositionRet
mapID (	
x (	
y ("
MasterFinish
roleSID (	"
MasterExpel
roleSID (	"
MasterSetWord
word (	"
MasterGetExperience"¿
MasterGetExperienceRet
totalApprentice (

totalExpel (
totalFlower (
totalFinish (
totalBetray (
finalMaster (
	finalName (	

finishTime ("
ApprenticeInformation"ö
ApprenticeInformationRet
roleSID (	
name (	
level (
school (
isOnline (
	taskState (
taskID (
now ("
MasterProfession",
MasterProfessionRet
nowProfession ("
MasterOfflinePunish"(
MasterOfflinePunishRet
punish ("*
ApprenticeOfflinePunish
roleSID (	",
ApprenticeOfflinePunishRet
punish (" 
ApprenticeSearch
name (	"a
ApprenticeSearchRet
flag (
roleSID (	
name (	
school (
level (" 
MasterGetWord
roleSID (	" 
MasterGetWordRet
word (	"?
MasterAddExperience
flag (
time (
name (	"
MasterIssueTask"$
MasterIssueTaskRet
taskID ("
MasterIssueTask2""
MasterTaskFinish
taskID ("
MasterReqSuccess"[
SatusChangeProtocol
taskType (
taskID (
chapter (
	taskState ("Q
TargetSatusChangeProtocol
taskID (
chapter (
targetState ("V
AddTaskProtocol
taskID (
isNew (
chapter (
targetState ("6
CurMainTaskProtocol
taskID (
chapter ("
PickUpProtocol
matID ("´
AddDailyTaskProtocol
taskID (
isNew (
curloop (
rewardId (
targetState (
needFinishIngot (
needAllIngot (
etrXp (":
FinishDailyTaskProtocol
taskID (
curloop ("E
DailyTargetStateChangeProtocol
taskID (
targetState ("4
YuanbaoFinishDailyTaskProtocol

finishType ("
UpRewardStarProtocol"+
UpRewardStarRetProtocol
rewardId ("
FinishStoryProtocol"8
AddBranchProtocol
taskID (
targetState ("&
FinishBranchProtocol
taskID ("
GetFinishBranchProtocol",
GetFinishBranchRetProtocol
taskID ("F
BranchTargetStateChangeProtocol
taskID (
targetState ("%
DealLoadingProtocol
taskID ("N
SendLastTaskInfoProtocol
taskType (
taskID (
rewardID ("*
PickDailyRewardProtocol
curLoop ("
YanhuoJoinProtocol"
YanhuoJoinRetProtocol"
YanhuoOutProtocol"
YanhuoOutRetProtocol"1
YanhuoMonsterUpdateProtocol

remianTime ("
YanhuoGetSceneDataProtocol"
YanhuoRenewProtocol"
YanhuoRenewRetProtocol"
YanhuoGetCanJoinLevelProtocol"1
 YanhuoGetCanJoinLevelRetProtocol
level ("
LuoxiaJoinProtocol")
LuoxiaJoinRetProtocol
lastTime ("
LuoxiaOutProtocol"
LuoxiaOutRetProtocol"è
LuoBoxInfoProtocol

hasBossDie (
hasBeGet (
isHold (
name (	
facName (	
holdTime (

isSameTeam ("?
LuoBoxPosProtocol
isBoss (
mapX (
mapY (""
LuoBoxOverProtocol
name (	"
LuoxiaGetRmainTimeProtocol"1
LuoxiaGetRmainTimeRetProtocol
lastTime ("%
WingPromoteProtocol
onceUp (":
WingPromoteRetProtocol
ret (
promoteTime ("n
WingLoadDataProtocol
	curWingID (
	wingState (
promoteTime (
skill (2.PbWingSkill";
PbWingSkill
pos (
level (
strength (")
WingChangeStateProtocol
opType (",
WingChangeStateRetProtocol
opType (")
WingFirstActiveProtocol
wingID (""
 WingPromoteConditionFailProtocol"
WingGetWingPriceProtocol",
WingGetWingPriceRetProtocol
price ("%
WingLearnSkillProtocol
pos ("I
WingLearnSkillRetProtocol
pos (
level (
strength ("G
EnterCopyProtocol
copyId (
friendId (	
isInCopy ("^
EnterCopyRetProtocol
msgType (
copyId (
	curCircle (

remainTime ("
ExitCopyProtocol"O
DoNextCircleProtocol
copyType (
	curCircle (

remainTime ("+
StartProgressCopyProtocol
copyId ("+
ProgressAllCopyProtocol
copyType ("W
CopyRewardInfo
rewardId (
rewardCount (
bind (
strength ("q
CopyRewardProtocol

copyResult (
copyUseTime (
rewardCount (
info (2.CopyRewardInfo"
GetProRewardListProtocol"S
RewardListByCopy
copyID (
prizeNum (
info (2.CopyRewardInfo"c
CopyProRewardList

rewardTime (
rewardCount (%

rewardList (2.RewardListByCopy"Z
GetProRewardListRetProtocol
rewardCount (&

rewardList (2.CopyProRewardList"I
GetProRewardProtocol
getTime (
copyID (
copyType ("
NotityProRewardProtocol"Û
CallFriendRetProtocol
friendId (
	friendSid (	

friendName (	
friendWeapon (
friendCloth (

friendRide (

friendWing (
friendWoman (
friendSchool	 (
friendHp
 (
	friendSex ("
CopyGetFriendDataProtocol"¬
CopyFriendInfo
	friendSid (	
friendSchool (

friendName (	
friendLevel (
friendBattle (
	friendSex (
remainCD (
	needIngot (
isOnline	 ("P
CopyGetFriendDataRetProtocol
	friendNum (
info (2.CopyFriendInfo":
GetProRewardretProtocol
getTime (
copyId ("<
StartProgressRetProtocol
copyId (
fastTime ("-
SyncActiveCopyIdProtocol
	curCopyId (")
CopyGetTeamDataProtocol
copyId ("ö
CopyMemberInfo
memberId (	

memberName (	
memberBattle (
memberStatus (
memberSchool (
	memberSex (
level ("
CopyGetTeamDataRetProtocol
teamId (
copyId (

createTime (
memNum (
info (2.CopyMemberInfo"o
CopyTeamInfo
teamId (

leaderName (	

createTime (
	memberCnt (
leaderBattle ("Z
CopyGetAllTeamDataProtocol
copyId (
teamNum (
info (2.CopyTeamInfo"(
CopyCreateTeamProtocol
copyId ("&
CopyJoinTeamProtocol
teamId ("
CopyLeaveTeamProtocol"0
CopyRemoveTeamMemberProtocol
targetId ("*
CopyAutoJoinTeamProtocol
copyId ("&
CopyTeamReadyProtocol
ready (".
CopyNotifyStatueHpProtocol
statueHp ("(
CopyOpenMultiWinProtocol
flag ("8
killedMonsters

monsterSid (	

monsterNum ("b
CopyOnMonsterKillProtocol

monsterSid (	
copyId (!
monsters (2.killedMonsters"0
CopyClearFriendTimeProtocol
	friendSid (	"
CopyGetTowerDataProtocol"ç
CopyGetTowerDataRetProtocol
copyNum (
info (2.TowerCopyInfo
starPrizeNum (%
starPrizeInfo (2.StarPrizeInfo
maxLayer (
curLayer (
resetNum (
nowProgress (
nowProgressLeftTime	 (
maxCanProgressCopy
 ("3
StarPrizeInfo
	starIndex (
starNum ("B
TowerCopyFastInfo
useTime (
name (	
battle ("f
TowerCopyInfo
copyId (
useTime ( 
info (2.TowerCopyFastInfo

getStarNum (".
CopyGetStarPrizeProtocol

prizeIndex ("A
CopyGetStarPrizeRetProtocol
roleId (

prizeIndex ("◊
CopyTowerResultProtocol
roleId (
result (
useTime ( 
info (2.TowerCopyFastInfo
bestStar (
newTime (
newStar (
prizeNum (#

rewardInfo	 (2.CopyRewardInfo"
CopyOpenNewSingleCopyProtocol"/
CopyDailyCount
copyID (
count (".
CopyRatingTime
copyID (
time ("k
CopyDailyDataProtocol(
copyDailyCounts (2.CopyDailyCount(
copyRatingTimes (2.CopyRatingTime",
CopySingleCopyBossProtocol
bossid ("
CopyResetTowerCopyProtocol"?
CopyResetTowerCopyRetProtocol
roleId (
result ("-
CopyProgressCopyRetProtocol
copyId ("V
FrameScMessageProtocol
eventId (
eCode (
mesId (
param (	"
CopyOpenWinRetProtocol" 
ActivityNormalReq
tab ("M
ActivityNormalInfo

id (
times (
errCode (
arg ("6
ActivityNormalRet!
info (2.ActivityNormalInfo"O

Activeness
integral (
status (
reward (2.ActivityReward"î
ActivityNormalActiveness
nowIntegral (

activeness (2.Activeness
redDot1 (
redDot2 (
redDot3 (
redDot4 ("2
ActivityNormalActivenessReward
integral ("3
!ActivityNormalActivenessRewardRet
status ("
ActivityNormalFindRewardList"+
findRewardItem

id (
times ("@
ActivityNormalFindRewardListRet
list (2.findRewardItem"7
ActivityNormalGetFindReward

id (
type ("J
ActivityNormalGetFindRewardRet

id (
type (
result (".
ActivityNormalGetAllFindReward
type ("A
!ActivityNormalGetAllFindRewardRet
type (
result ("+
ActivityNormalCanJoin

activityID ("+
ActivityNormalCanJoinRet
canJoin ("
ActivityNormalCalendar"u
ActivityNormalCalendarRet
show1 (
show2 (
show3 (
week1 (
week2 (
week3 ("
ActivityNormalActivenessReq"8
ActivityNormalStateChange
flag (
level ("ç
SendChatProtocol
channel (
message (	

targetName (	
fileid (	
voicelen (
MsgType (
MsgParam ("à
ReceiveMsgProtocol
channel (
message (	
roleSID (	
roleName (	
showname (
vip (
	curBattle (
title (

targetName	 (	
callType
 (
paramNum (

callParams (	
fileid (	
voicelen ("'
ShellCommandProtocol
cmdText (	"M
SendRecentMsgProtocol
recentMsgSize (
	recentMsg (2
.RecentMsg"[
	RecentMsg
roleSID (	
roleName (	
message (	
vip (
title ("n
ClickAnchorProtocol
targetRoleSID (	
itemID (
slot (
bagIndex (
timeTick ("*
ClickAnchorRetProtocol
itemInfo (	",
GetStrangerMsgProtocol

targetName (	"ª
SendStrangerMsgProtocol
online (
targetRoleSID (	

targetName (	
	targetSex (
targetSchool (
targetLevel (
	targetVip (
targetBattle ("
GetHorseMsgProtocol"5
GetHorseMsgRetProtocol
horseMsg (2	.HorseMsg"Z
HorseMsg
msgID (	
message (	
interval (
times (
delay ("Y
UpdateHorseMsgProtocol
msgID (	
message (	
interval (
times ("è
CallMsgProtocol
channel (
message (	
area (
callType (
paramNum (

callParams (	
targetRoleId (	"á
SystemMsgProtocol
type (
message (	
timeTick (
eventID (
tipsID (
paramNUm (
params (	"I
ShareItemProtocol

shareCount ( 
itemInfo (2.ShareItemInfo"Q
ShareItemInfo
itemID (
slot (
bagIndex (
timeTick ("9
CallMsgRetProtocol

callMsgRet (
channel ("2
SetPhraseProtocol
index (
phrase (	"
GetPhraseProtocol"?
GetPhraseRetProtocol
phraseCount (

phraseInfo (	"I
PopAllWindowProtocol
timeTick (

windowInfo (2.WindowInfo"Ä

WindowInfo

windowType (
	startTime (
title (	
content (	
link (	
	btContent (	

id (	"9
ClearChatMsgProtocol
roleSID (	
roleName (	" 
PopOneMsgProtocol
msg (	"r
PrivateOtherInfo
roleSID (	

roleSchool (
	roleLevel (
roleRelation (
roleName (	"
VoiceListReqProtocol"f
	VoiceInfo
weekDay (
openTime (
	closeTime (
nickName (	
	otherInfo (	"9
VoiceListInfoRetProtocol
	voiceList (2
.VoiceInfo"
VoiceRoomInfoReqProtocol"*
VoiceRoomInfoRetProtocol
roomId (	"
GetWineProtocol"&
DrinkWineProtocol
	slotIndex ("
GetWineNumReqProtocol"(
GetWineNumRetProtocol
wineNum ("I
ItemCompoundProtocol
compoundAll (
slot1 (
slot2 (")
ItemCompoundRetProtocol
result ("T
EquipCompoundProtocol
itemID (
compoundType (
compoundParam ("t
MonattackRankProtocol
myScore (
myRank (
RankNum ()
scoreRankInfo (2.MonattackRankInfo"0
MonattackRankInfo
Score (
name (	"6
SinpvpOpenProtocol
single (
openType ("<
SinpvpFightProtocol
	targetSID (

targetRank ("
SinpvpBuyCountProtocol"[
SinpvpOpenRetProtocol
curRank (
	targetNum (

targetInfo (2
.PvpTarget"Î
	PvpTarget

targetRank (
	targetSID (

targetName (	
targetSchool (
	targetSex (
targetbattle (
targetWeapon (
targetCloth (

targetWing	 (
targetHP
 (
targetLevel ("<
SinpvpRankWrongProtocol!
targetNewInfo (2
.PvpTarget"n
SinpvpInfoRetProtocol
fightCnt (
buyCnt (
coolTime (
isCDing (
fightLog (	")
SinpvpGetRankProtocol
rankPage ("O
SinpvpGetRankRetProtocol
rankNum ("
rankTargetInfo (2
.PvpTarget"\
SinpvpFightRetProtocol
result (
rewardID (
curRank (
history ("
SinpvpExitPvpProtocol"x
GiveFlowerNoticeProtocol
sourceID (

sourceName (	
	targetSID (

targetName (	
message (	"+
CallFactionMemProtocol
	slotIndex ("a
NoticeFactionMemProtocol
roleSID (	
roleName (	
	roleMapID (
rolePos (	"S
SendFactionMemProtocol
	targetSID (	
targetMapID (
	targetPos (	"^
GiveFlowerProtocol
	targetSID (	

targetName (	
giveType (
giveNum ("=
GiveFlowerRetProtocol
giveType (

getGlamour ("
GetFlowerRecordProtocol"X
GetFlowerRecordRetProtocol
recordCount (%

recordInfo (2.FlowerRecordInfo"n
FlowerRecordInfo
timeTick (
sendName (	
receiveName (	
giveType (
giveNum ("
GetTotalFlowerProtocol"-
TotalFlowerRetProtocol
totalFlower ("
GetRemainFlowerProtocol"~
GetRemainFlowerRetProtocol
firstFlowerNum (
secondFlowerNum (
thirdFlowerNum (
fourthFlowerNum ("
CheckTargetRewardProtocol"6
CheckTargetRewardRetProtocol
targetRewardID ("1
GetTargetRewardProtocol
targetRewardID ("K
GetTargetRewardRetProtocol
	getResult (
nextTargetRewardID ("$
TradeAReqProtocol
bRoleID ("f
TradeARetProtocol
bRoleID (
tradeID (
tradeRet (
bName (	
bLevel ("\
TradeBReqProtocol
tradeID (
aRoleID (
	aRoleName (	

aRoleLevel ("F
TradeBRetProtocol
aRoleID (
tradeID (
bAnswer ("ä
TradeRetProtocol
tradeID (
tradeRet (
tradeVersion (
targetRoleID (
targetLevel (

targetName (	"\
TradeItemReqProtocol
tradeID (
bagSlot (
itemNum (
	operation ("q
TradeItemRetProtocol
roleID (
tradeItemSlot (
itemNum (
version (
itemInfo (	"$
TradeLockProtocol
tradeID ("7
TradeLockRetProtocol
tradeID (
roleID ("D
TradeDoProtocol
tradeID (
isTrade (
version ("F
TradeDoRetProtocol
tradeID (
roleID (
isTrade ("%
TradeBlockProtocol
isBlock ("(
TradeBlockRetProtocol
isBlock ("1
TradeSellProtocol
bagSlot (
num ("5
TradeBackSellProtocol
bagSlot (
num ("3
TradeMallProtocol
	itemBuyID (
num ("(
TradeMallReqProtocol
shopType ("c
TradeMallReqRetProtocol
shopType (
shopItemCount (
itemInfo (2.ShopItemInfo"ﬁ
ShopItemInfo
	itemBuyID (
itemID (
	sellState (
	sellPrice (
sourcePrice (
	allLimite (
allLimiteLeft (

roleLimite (
roleBuy	 (

effectTime
 (
label ("_
TradeaMallRetProtocol
shopType (
mallRet (
allLimit (
	roleLimit ("*
MysteryShopReqProtocol
shopType ("p
MysteryShopReqRetProtocol
mallID (
itemNum ("
itemInfo (2.MysteryItemInfo
param1 ("«
MysteryItemInfo
	moneyType (

arrayIndex (
itemID (
price (
itemLeft (
souceNum (
serverLimit (
	roleLimit (

roleCurBuy	 (
isBind
 ("q
MysteryShopBuyProtocol
shopType (
	moneyType (

arrayIndex (
itemID (
buyNum ("X
MysteryShopBuyRetProtocol
buyRet (
needMoreIngot (
buyCountLeft (".
MysteryShopRefreshProtocol
shopType ("(
AllLimitReqProtocol
	itemBuyID ("g
AllLimitRetProtocol
allLimit (
allLimitLeft (
	roleLimit (
roleLimitLeft ("F
TradeByItemIDProtocol
shopType (
itemID (
num ("6
SpeTradeProtocol
buyParam (
addParam (	"<
UnlockCheckProtocol
shopType (
unlockIndex ("Q
UnlockCheckRetProtocol
curUnlockIndex (
	moneyType (
cost ("7
UnlockProtocol
shopType (
unlockIndex (";
UnlockRetProtocol
	unlockRet (
unlockIndex ("0
MysteryShopOpenProtocol
shopOpenState ("r
MysteryBlackMallRetProtocol
mallID (
itemNum ("
itemInfo (2.MysteryItemInfo
param1 ("b
MysteryLimitReqProtocol
shopType (
	moneyType (

arrayIndex (
itemID ("M
MysteryLimitRetProtocol
mallID ("
itemInfo (2.MysteryItemInfo"1
MallCheckNew
mallType (
isClose ("2
MallCheckNewRet
mallType (
isNew ("
MallSpeItem
slot ("
WorldBossReqProtocol"L
WorldBossReqRetProtocol
bossNum ( 
bossInfo (2.WorldBossInfo"[
WorldBossInfo
bossID (
bossLive (
nextLiveTime (	

isTomorrow ("ñ
WorldBossRewardProtocol
bossID (
bossLive (
rankNum ($
hurtInfo (2.WorldBossHurtRank

myHurtRank (
myHurt ("7
WorldBossHurtRank
roleName (	
roleHurt ("+
WorldBossGetOwnerProtocol
bossID ("@
WorldBossOwnerRetProtocol
ownerSID (	
	ownerName (	"
CompetitionPickRewardProtocol"à
CompetitionPlayerData
roleName (	
school (
sex (
weaponID (
clothID (
wingID (
value ("3
 CompetitionPickRewardRetProtocol
isInBag ("π
CompetitionNotifyStarProtocol
isFriend (

remainTime (
isFirst (
	rewardNum (
tReward (
	playerNum (*

playerData (2.CompetitionPlayerData"A
CompetitionNotifyRewardProtocol
rewardId (
rank ("
CompetitionAcceptProtocol"
CompetitionGetDataProtocol"^
CompetitionGetDataRetProtocol
	playerNum (*

playerData (2.CompetitionPlayerData"
CompetitionSynTimeProtocol"-
CompetitionSynTimeRetProtocol
time ("%
AdoreKingProtocol
useIngot ("
AdoreKingRetProtocol"
AdoreGetDataProtocol"H
AdoreGetDataRetProtocol
remainTimes (
remainIngotTimes ("M
DartTeamData
teamID (
maxCnt (
realCnt (
name (	"ô
DartClickRetProtocol
state (

rewardType (
level (
teamID (
count (
teamNum (
teamData (2.DartTeamData":
DartJoinTeamProtocol
teamID (

rewardType ("M
DartCreatTeamProtocol

rewardType (
maxCnt (
teamType ("K
DartCreatTeamRetProtocol
result (
realCnt (
maxCnt ("
DartPositionProtocol"?
DartPositionRetProtocol	
x (	
y (
dartID ("
DartStatusProtocol"'
DartStatusRetProtocol
status ("O
DartCurStateRetProtocol
state (

rewardTpye (
	hasReward ("M
DartQueryTeamDartProtocol
teamID (
count (
	dartTimes ("P
DartAnswerTeamDartProtocol
teamID (

rewardType (
answer ("-
DartInviteTeamDartProtocol
roleSID (	"
ConvoyPositionProtocol"C
ConvoyPositionRetProtocol	
x (	
y (
targetID ("C
RewardTaskReq

actionType (
param1 (
param2 ("
AnnRewardTask
taskGUID (

expireTime (

taskStatus (
taskRank (
taskID (

receiveNum ("â
OwnerRewardTaskRet
remainAnnRewardTaskNum (
taskNum (
tasks (2.AnnRewardTask#
remainAnnSuperRewardTaskNum ("í
AccRewardTaskInfo
taskGUID (
	ownerName (	

expireTime (
taskRank (
taskID (

receiveNum (
newTag ("‡
SelectRewardTaskRet"
remainAccBlueRewardTaskNum ($
RemainAccPurpleRewardTaskNum (
taskNum ('
rewardTasks (2.AccRewardTaskInfo#
remainAccSuperRewardTaskNum (
taskRank (
status ("Ü
AddRewardTaskRet
taskID (
isNew (
taskGUID (
guardExpiredTime (
	targetNum (
targetStates (")
FinishRewardTaskRet

actionType ("T
RewardTaskStateChange
taskID (
	targetNum (
targetStateDatas ("'
PBAttr
propId (
value ("˝
PBItem
slot (
protoId (
count (
tlimit (
bind (
strength (
luck (

stallprice (
	stalltime	 (
attrs
 (2.PBAttr
guid (	
upStallTime (
specialPropValue (
blessNum (
emblazonry1 (
emblazonry2 (
emblazonry3 (
level (
exp (
skinid (
active ("C
PBItemGroup

id (
capacity (
items (2.PBItem",
ItemProtocol
groups (2.PBItemGroup"Q
ItemIncUpdate
bag (
slot (
items (2.PBItem
isTip ("$
ItemSortProtocol
bagIndex ("
ItemUpgradeProtocol"b
ItemBaptizeProtocol
bagIndex (
	itemIndex (
bindPropNum (
	indexData ("0
ItemBaptizeRetProtocol
attrs (2.PBAttr"P
ItemSureBaptizeProtocol
bagIndex (
	itemIndex (
dealType ("c
ItemSureBaptizeRetProtocol
bagIndex (
	itemIndex (
dealType (
isSame ("8
ItemBlessProtocol
bagIndex (
	itemIndex ("M
ItemBlessRetProtocol
bagIndex (
	itemIndex (
retValue ("7
ItemNotEnoughProtocol
matType (
matID ("?
ItemResetSpecialProtocol
bagIndex (
	itemIndex ("T
ItemResetSpecialRetProtocol
bagIndex (
	itemIndex (
retValue ("7
SmelterReqProtocol
itemNum (
slotList ("d
SmelterRetProtocol

newEquipID (

smelterRet (
getMoney (
getSoulscore ("Z
EmblazonryProtocol

id (
emblazonryType (
opType (
posIndex ("?
EmblazonryRetProtocol
emblazonryType (
optype ("<
ItemExtendBagProtocol
bagIndex (
	slotIndex ("<
ItemExtendRetProtocol
bagIndex (
	slotIndex ("X
ItemSwapProtocol
srcIndex (
srcGrid (
dstIndex (
dstGrid ("[
ItemInstallProtocol
srcIndex (
srcGrid (
dstGrid (
dstIndex (":
ItemUnInstallProtocol
srcGrid (
srcIndex ("T
ItemStrengthProtocol
srcIndex (
srcGrid (
matData (2.MatData"&
MatData
bagPos (
num ("L
ItemStrengthRetProtocol
srcIndex (
srcGrid (
result ("Ñ
ItemInheritProtocol
srcIndex (
srcGrid (
dstIndex (
dstGrid (
	freeStyle (
autoUseIngot ("^
ItemInheritRetProtocol
srcIndex (
srcGrid (
dstIndex (
dstGrid ("&
ItemPromoteProtocol
srcGrid (")
ItemPromoteRetProtocol
srcGrid ("V
ItemUseProtocol
srcIndex (
srcGrid (
targetID (
useCnt ("[
	EmailItem
itemId (
count (
strength (
timeout (
bind ("Ô
EmailProtocol
title (	
desc (	
sender (	
	startDate (
endDate (
descId (
emailId (	
params	 (	
items
 (2
.EmailItem
insItems (2.PBItem
	hyperlink (	
linkContent (	"3
ItemEmailProtocol
emails (2.EmailProtocol"(
ItemPickEmailProtocol
emailId (	"+
ItemPickEmailRetProtocol
emailId (	"
ItemPickAllEmailProtocol"@
	PBHoldMat
itemID (
itemNum (

remainTime ("+
HoldMatProtocol
mats (2
.PBHoldMat"4
ItemMountMoveToMountBagProtocol
	dwBagSlot ("$
"ItemMountMoveToMountBagRetProtocol"O
ItemMountAddExpProtocol
dwBagId (
	dwBagSlot (
dwItemId ("/
ItemMountAddExpRetProtocol
	isUpgrade ("*
ItemMountFreeProtocol
	dwBagSlot (".
ItemMountFreeRetProtocol

strRetItem (	"B
ItemMountChnageSkinProtocol
	dwBagSlot (
dwSkinId (" 
ItemMountChnageSkinRetProtocol"ä
ItemMountInheritProtocol

dwSrcBagId (
dwSrcBagSlot (

dwDesBagId (
dwDesBagSlot (
dwRandPropertyFlag ("
ItemMountInheritRetProtocol"@
ItemMountSacrificeProtocol
dwBagId (
	dwBagSlot ("<
ItemMountSacrificeRetProtocol

vecRetItem (2.PBAttr"5
ItemUseRetProtocol
itemID (
itemNum ("?
AddRelationProtocol
relationKind (

targetName (	";
AddRelationRetProtocol
errId (

targetName (	"A
RemoveRelationProtocol
	targetSid (	
relationKind ("D
RemoveRelationRetProtocol
relationKind (
	targetSid (	"/
GetRelationDataProtocol
relationKind ("Y
GetRelationDataRetProtocol
relationKind (%
roleData (2.RelationPlayerData"´
RelationPlayerData
roleSid (	
name (	
level (
sex (
school (
fightAbility (
isOnLine (
killNum (
	beKillNum	 ("
RecommendFriendProtocol"D
RecommendFriendRetProtocol&
roleData (2.RecommendPlayerData"O
RecommendPlayerData
name (	
sex (
level (
school ("+
QueryEnemyPosProtocol

targetName (	"+
QueryEnemyPosRetProtocol
mapName (	";
GotoPosProtocol

targetName (	
relationType ("N
FightNotifyProtocol

notifyType (

targetName (	
mapName (	"7
BeFriendProtocol
roleSID (	

targetName (	",
GetEnemyNameProtocol
relationType ("=
GetEnemyNameRetProtocol
name (	
relationType ("'
GetRealFirendProtocol
openid (	"G
GetRealFirendRetProtocol+

friendInfo (2.RelationRealFriendData"≈
RelationRealFriendData
roleSid (	
name (	
level (
sex (
school (
fightAbility (
openid (	
canGift (
canPickGift	 (
appStartType
 ("5
DealgiftProtocol
dealType (
roleSID (	"8
DealgiftRetProtocol
dealType (
roleSID (	"'
ChangeEnemyWordProtocol
word (	"
ChangeEnemyWordRetProtocol"
GetEnemyWordProtocol"'
GetEnemyWordRetProtocol
word (	"e
RoleInfo
roleSID (	
name (	
sex (
school (
level (
battle (",
AcceptSharedTaskProtocol
taskRank ("%
ShareTaskProtocol
taskRank ("K
ConfirmShareTaskProtocol
taskId (
sRoleId (
result ("
LetoutMonsterProtocol"
GetSharedTaskPrizeProtocol"
DeleteSharedTaskProtocol"
GetSharedTaskTimesProtocol"D
ShareTaskRetProtocol
roleId (
taskId (
name (	"q
GetSharedTaskPrizeRetProtocol
roleId (
errCode (
sharedTaskPrizeNum (
allPrizeNum ("u
AddSharedTaskProtocol
taskId (
	taskOwner (
taskNum (
	taskState (
taskTargetPos (	"*
FinishSharedTaskProtocol
taskId ("V
SharedTargetStateChangeProtocol
taskId (
taskNum (

taskStates (",
AfterGetSharedTaskProtocol
roleId ("B
GetSharedTaskTimesRetProtocol
	remainNum (
allNum ("
GetSharedTaskListProtocol">
GetSharedTaskListRetProtocol
infos (2.SharedTaskInfo"d
SharedTaskInfo
name (	
roleSid (
level (
taskRank (

taskStatus ("G
"RequestAddToSharedTaskTeamProtocol
roleSid (
taskRank ("!
RequestFreshMonsterTaskProtocol"-
RtnFreshMonsterTaskProtocol
result ("-
RequestUseGotTaskProtocol
taskType ("&
TaskStartPickProtocol
matID ("C
TaskNotifyPickActionProtocol
actionRoleID (
matID ("
StallOpenProtocol",
StallSellProtocol
stalls (2.PBItem",
StallBackProtocol
stalls (2.PBItem"M
StallUpProtocol
upType (
price (
slot (
count ("&
StallDownProtocol
	stallGuid (	"%
StallBuyProtocol
	stallGuid (	"%
StallGotProtocol
	stallGuid (	"(
StallGotRetProtocol
	stallGuid (	"I
StallRequestProtocol
	queryType (
queryIdx (
bAsc ("V
StallFindProtocol
	queryType (	
queryIdx (
bAsc (
idList ("f
StallQueryProtocol
allStallCnt (
	stallSize (
queryIdx (
items (2.PBItem"@
StallDownRetProtocol
	stallGuid (	
item (2.PBItem"@
StallSellRetProtocol
	stallGuid (	
item (2.PBItem"?
StallBuyRetProtocol
	stallGuid (	
item (2.PBItem"(
EnterManorWarProtocol
manorID ("'
PickUpBannerProtocol
manorID ("(
SimpleWarInfoProtocol
manorID ("∂
SimpleWarInfoRetProtocol
manorID (
isOver (
	beginTime (
isNear (
siAid (
bannerOwner (
owner (	
facName (	

bannerTime	 ("R
NotifyOccupyFactionProtocol
	factionID (
manorID (
facName (	"@
BannerPosProtocol
manorID (
posX (
posy ("&
EndManorWarProtocol
manorID ("
GetOwnFactionProtocol"C
GetOwnFactionRetProtocol'
ownFactionInfo (2.OwnFactionInfo"0
OwnFactionInfo
manorID (
facId ("+
GetAllRewardInfoProtocol
manorID ("µ
GetAllRewardInfoRetProtocol
manorID (
isOpen (
	remainDay (
curTime (

hasFaction (
facName (	

leaderName (	
sex (
school	 (
weapon
 (
cloth (
wing (
assleaderName (	
	canReward ($
zzFacId (2.JoinZhongZhouFacId"Y
JoinZhongZhouFacId
manorID (
facId (
facName (	

leaderName (	"*
PickManorRewardProtocol
manorID ("-
PickManorRewardRetProtocol
manorID ("9
ManorNotifyAllProtocol
manorID (
isOpen ("
ManorSendOutProtocol"-
ManorGetLeaderInfoProtocol
manorID ("J
ManorGetLeaderInfoRetProtocol
sex (
school (
name (	"
GotoShaProtocol"D
ShaNotifyAllProtocol
isOpen (
facInfo (2.ShaFacInof"*

ShaFacInof
facId (
isSha ("#
StartCountProtocol
times ("
GetShaInfoProtocol"à
GetShaInfoRetProtocol
isOpen (
remainDayNum (
curTiem (
beOccupy (
facName (	
	leaderSex (
	Leadersch (

leadername (	
weapon	 (
	upperbody
 (
wingID (
assleaderName (	
	canReward ("
ShaPickRewardProtocol"
ShaPickRewardRetProtocol">
UpdateHoldStateProtocol#

holderInfo (2.HoldPlayerInof"s
HoldPlayerInof
holdSID (	
holdID (
name (	
facId (
facName (	

unionFacId ("7
DealHoldProtocol
	holeIndex (
dealType ("K
DealHoldRetProtocol
	holeIndex (
dealType (
dealRet ("`
ShaReliveInfoProtocol
sourname (	
facName (	
remain (
needStoneNum ("
ShaGetRecordProtocol"7
ShaGetRecordRetProtocol
info (2.ShaRecordInfo"Z
ShaRecordInfo
rdStyle (
time (
factionName1 (	
factionName2 (	"#
ShaCountDownProtocol
num (",
GetShaMasterProtocol
shafactionID ("$
ShaKillNotifyProtocol
num ("
ShaGetLeaderProtocol"D
ShaGetLeaderRetProtocol
name (	
sex (
school ("
ShaNeedReliveProtocol"%
ApplyJoinFaction
	factionID ("P
ApplyJoinFactionRet

joinResult (
	factionID (

resultCode ("+
CancelApplyJoinFaction
	factionID ("B
CancelApplyJoinFactionRet
	factionID (

resultCode ("#
GetFactionInfo
	factionID ("æ
FactionInfo1

id (

lv (
bannerlv (
storelv (
name (	

leaderName (	
rank (
allMemberCnt (
money	 (
Comment
 (	
facXp ("û
FactionInfo2

id (
name (	

lv (
allMemberCnt (
maxMemberCnt (
totalAbility (
leaderOnline (
autoJoin ("X
GetFactionInfoRet
info (2.FactionInfo1
contribution (
position ("M
GetAllFactionInfoRet
infos (2.FactionInfo2
applyedFactions ("I
GetFactionMsgRecord
	factionID (
lowNum (
highNum ("0
FactionMsgRecordLink

id (
name (	"b
FactionMsgRecord
time (

id (
params (	$
links (2.FactionMsgRecordLink"<
GetFactionMsgRecordRet"
records (2.FactionMsgRecord"E
UpLevelFaction
	factionID (
upType (
curLevel ("D
UpLevelFactionRet
curLevel (
upType (
facXp ("8
AgreeJoinFaction
	factionID (
	opRoleSID (	"(
AgreeJoinFactionRet
	opRoleSID (	"9
RefuseJoinFaction
	factionID (
	opRoleSID (	")
RefuseJoinFactionRet
	opRoleSID (	"(
GetApplyFactionInfo
	factionID ("S
	ApplyInfo
roleSID (	

lv (
name (	
job (
battle ("E
GetApplyFactionInfoRet
autoJoin (
infos (2
.ApplyInfo",
GetAllFactionMemberInfo
	factionID ("ò
FactionMemberInfo
memSID (	

lv (
name (	
job (
position (
ability (
activeState (
contribution ("A
GetAllFactionMemberInfoRet#
members (2.FactionMemberInfo"&
PreUpLevelFaction
	factionID ("E
PreUpLevelFactionRet

lv (
storeLv (
bannerLv ("L
AppointPosition
	factionID (

opRolesSID (	

opPosition ("`
AppointPositionRet
rolesSID (	
position (

opRolesSID (	

opPosition ("/
LeaveFaction
	factionID (
name (	"!
LeaveFactionRet
result (";
RemoveFactionMember
	factionID (
	opRoleSID (	"?
RemoveFactionMemberRet
	opRoleSID (	

opRoleName (	"!
GetStroeInfo
	factionID (",
	StroeInfo
itemID (
soldCnt ("?
GetStroeInfoRet
	factionlv (
infos (2
.StroeInfo"1
EditComment
	factionID (
comment (	"!
EditCommentRet
comment (	"
ApplyCntNotify
count ("<
ChangeFactionAutoJoin
	factionID (
autoJoin ("%
GetMyFactionData
	factionID ("<
GetMyFactionDataRet
storeLv (
contribution ("!
FactionFreshUI
roleSID (	")
GetFactionSocialInfo
	factionID ("m
FactionSocialInfo

aFactionID (

bFactionID (
state (
opFactionID (
time ("u
GetFactionSocialInfoRet
	factionID ("
allFactions (2.FactionInfo2#
socials (2.FactionSocialInfo"S
FactionSocialOperator
opType (
srcFactionID (
dstFactionID ("g
FactionSocialOperatorRet
retCode (
opType (
srcFactionID (
dstFactionID ("Ü
FactionSocialOperatorSuc
opType (
srcFactionName (	
dstFactionName (	
srcFactionID (
dstFactionID ("
FactionSocialApplyUnionNotify"
FactionSocialReturnItem"'
GetFactionPrayInfo
	factionID ("9
FactionPrayInfo
prayType (
dayLeftCount ("8
GetFactionPrayInfoRet
infos (2.FactionPrayInfo"
FactionPray
prayType ("3
FactionPrayRet
retCode (
prayType ("L
FactionContributeRet
roleSID (	
contribution (
facXp ("F
FactionPrayNotify
prayType (
roleName (	
facXp (	"
FactionPrayReturnItem".
FactionUnionSocialNotify

factionIDs ("2
FactionHostilitySocialNotify

factionIDs (""
FactionInfoNotify
money ("
FactionEnterArea"
FactionOutArea"'
GetFactionTaskInfo
	factionID ("2
FactionTaskInfo
taskID (
targets ("^
GetFactionTaskInfoRet
	factionID (
tasks (2.FactionTaskInfo
	joinCount ("<
FactionTaskDoneNotify
factionName (	
taskID ("S
FactionInviteNotify
position (
dwHasVoiceRoom (

nCommandId (	"'
FactionInviteJoin

opRoleName (	"
FactionInviteJoinRet"p
FactionInviteJoinNotify
inviteRoleSID (	
inviteRoleName (	
	factionID (
factionName (	"S
FactionInviteJoinChoose
choose (
inviteRoleSID (	
	factionID ("
FactionInviteJoinChooseRet"C
FactionInviteJoinChooseNotify

playerName (	
choose (""
FactionAddStatue
addNum ("%
FactionAddStatueRet
addNum ("
FactionGetStatueRank"¬
FactionGetStatueRankRet
shaFacId (

shaFacName (	
shaFacLeaderName (	
zhongzhouFacId (
zhongFacName (	
zhongFacLeaderName (	
rdData (2.StatueRdData"|
FactionVoiceRoomInfo
gid (	
roomid (	
roomkey (	
user_openid (
uuid (	
business_id ("5
FactionVoiceCreateRoomProtocol
dwFactionId ("#
!FactionVoiceCreateRoomRetProtocol"3
FactionVoiceJoinRoomProtocol
dwFactionId ("√
FactionVoiceJoinRoomRetProtocol
gid (	
roomid (	
roomkey (	
memberid (
user_openid (
user_ip (	
user_access (	
roletype (
business_id	 ("3
FactionVoiceExitRoomProtocol
dwFactionId ("!
FactionVoiceExitRoomRetProtocol"4
FactionVoiceCloseRoomProtocol
dwFactionId (""
 FactionVoiceCloseRoomRetProtocol"#
!FactionVoiceCreateRoomNtfProtocol""
 FactionVoiceCloseRoomNtfProtocol"
FactionGetEventRd">
FactionEventRecord
time (

id (
params (	"<
FactionGetEventRdRet$
records (2.FactionEventRecord"1
EnterSwornSceneRes
result (
sid (	"
StartSwornCeremony"$
StartSwornCeremonyRet
ret ("0
AgreeSwornAction
roleId (	
done (" 
RequestSwornInfo
type ("ÿ
SwornBasicInfoRet
sworn_id (
relation (
online_hint ()
bros (2.SwornBasicInfoRet.bro_info_
bro_info
name (	

profession (
level (
	is_leader (
role_id (	"3
SwornSkillInfoRet
points (
skills ("0
SwornDoAction
type (
	target_id (	"F
SwornDoActionRet
type (
	target_id (	
	leader_id (	"?
NotifySwornRelationLvl
relation_lvl (
upgrade ("6
OperateSwornPsvSkill
type (
skill_id ("I
OperateSwornPsvSkillRet
type (
skill_id (
points ("
ReqSwornAtvSkillInfo"å
SwornAtvSkillInfoRet+
bros (2.SwornAtvSkillInfoRet.BroInfoG
BroInfo
sid (	
name (	
map (	
x (	
y ("7
OperateSwornAtvSkill
type (
	target_id (	"=
SwornSkillGatherBro
sid (	
name (	
map ("2
SwornBroOnlieStatus
sid (	
online ("X
StatueRdData
facID (
facName (	
facLeaderName (	
	statueNum ("
FactionCopyJoin"
FactionCopyJoinRet"#
FactionCopyOut
	factionID ("&
FactionCopyOutRet
	factionID (":
FactionCopyOpenNotify
copyID (
	startTime ("2
FactionCopyFreshRank
rank (
hurt ("-
FactionCopyReliveInfo
relivePeriod ("
FactionCopyGetPassTime"Q
FactionCopyGetPassTimeRet
	secToOpen (
copyID (
	openTimes ("
FactionCopyAllRank"k
FactionCopyHurtRank
name (	

lv (
viplv (
job (
position (
hurt ("<
FactionCopyAllRankRet#
infos (2.FactionCopyHurtRank"1
FactionCopyOver
outTime (
prize ("I
FactionCopySetOpenTime
copyID (
strtime (	
timeId ("b
FactionCopySetOpenTimeRet
copyID (
strtime (	
	secToOpen (
	openTimes ("<
FactionCopySetOpenNotify
copyID (
openTime (	"O
FactionCopyAutoOpenFailNotify
copyID (
errcode (
param ("(
CreateTeamProtocol

teamTarget ("`
TeamCreateTeamRetProtocol
teamId (

teamTarget (

leaderInfo (2.SimpleInfo"E
InviteTeamProtocol
tName (	
isApply (
iTeamID ("L
TeamAnswerInviteProtocol
tRoleId (	
teamId (
bAnswer ("K
TeamAnswerApplyProtocol
tRoleId (	
teamId (
bAnswer ("+
TeamRemoveMemberProtocol
tRoleId (	"y
TeamRemoveMemberRetProtocol
bLeave (
roleSid (	
eCode (
memberCount1 (
memberCount2 ("+
TeamChangeLeaderProtocol
tRoleId (	"O
ChangeLeaderRetProtocol
	leaderSid (	
eCodeId (
hasApply ("
TeamGetTeamInfoProtocol"£
TeamGetTeamInfoRetProtocol
hasTeam (
teamId (
memCnt (
infos (2.SimpleInfo
	memCount1 (
	memCount2 (

teamTarget ("√

SimpleInfo
roleSid (	
name (	
	roleLevel (
sex (
school (
actived (
wingId (
weapon (
	upperBody	 (
curHP
 (
factionName (	"F
TeamGetAroundPlayerProtocol

aroundType (
aroundValue ("§
TeamGetArroundPlayerRetProtocol
	noTeamCnt (!
noTeaminfos (2.SpeRoleInfo
withTeamCnt ("
	teamInfos (2.AroundTeamInfo

aroundType ("í
TeamMemberInfo
roleId (	
name (	
level (
factionName (	
school (
curNum (
maxNum (
teamId ("á
AroundTeamInfo
teamID (

leaderName (	
leaderFaction (	

teamTarget (

teamMaxNum (

teamCurNum ("
TeamLeaveTeamProtocol"g
TeamAddNewMemberProtocol
sTeamId (
info (2.SimpleInfo
hurtAdd (
expAdd ("õ
TeamJoinTeamRetProtocol
teamId (
hasTeam (
memCnt (
infos (2.SimpleInfo
hurtAdd (
expAdd (

teamTarget ("G
TeamChangeAutoInviteProtocol
inviteValue (

inviteType ("[
TeamInviteTeamRetProtocol
roleId (	
teamId (
isInvite (
name (	".
TeamChangePosMapIdProtocol
curMapId ("T
TeamGetTeamPosInfoProtocol
bTag (
num (
infos (2.TeamMapInfo"F
TeamMapInfo
posX (
posY (
mapId (
name (	"*
TeamGetTeamApplyProtocol
teamId ("q
TeamGetTeamApplyRetProtocol
hasApply (
teamId (
applyCnt (
infos (2.RoleSimpleInfo"^
RoleSimpleInfo
roleSid (	
battle (
name (	
school (
level ("9
TeamApplyIsNullProtocol
teamId (
isNull ("M
TeamAutoAddProtocol
teamId (
	leaderSid (	
autoInvited ("6
TeamFastEnter
	enterType (

enterParam ("
TeamFastRecruit"!
TeamGetSpeRole
speType ("C
TeamGetSpeRoleRet
speType (
speInfo (2.SpeRoleInfo"ç
SpeRoleInfo
roleSID (	
sex (
school (
level (
battle (
name (	
factionName (	
teamID ("^
TeamNoticeInfo
teamID (
infoType (
infoData (
memHP (2	.MemberHP"*
MemberHP
roleSID (	
curHP ("
TeamGetMemHP"
FrameHeartBeatReq"$
FrameHeartBeatRet
nowtick ("'
FrameChangeModeProtocol
mode ("'
FrameSwitchLineProtocol
line ("&
FrameChargeReqProtocol
type ("9
FrameChargeRetProtocol
worldID (
charNo (	"*
FrameChargeRepProtocol
ingotGot ("#
FrameReliveProtocol
flag ("$
FramePickUpProtocol
mpwID ("B
FramePickUpRetProtocol
type (
value (
num (":
FrameSendToProtocol
mapID (	
x (	
y ("3
FrameLookUpProtocol
name (	
notice (""
RideClientProtocol
ride ("E
WingClientDataProtocol
wingID (
skill (2.PbWingSkill"Æ
FrameLookUpRetProtocol
delete (

id (
name (	

hp (

mp (
sex (
school (
level (
atmin	 (
atmax
 (
mtmin (
mtmax (
dtmin (
dtmax (
dfmin (
dfmax (
mfmin (
mfmax (
hpmax (
mpmax (
exp (
nextxp (
battle (
luck (
hit (
dodge (

pk (
glamour (
crit (
tenacity (
	moveSpeed (
project  (

projectDef! (
rideId" (
wingId# (
weaponId$ (
clothId% (

serverName& (	
factionName' (	
rides) (	
wings* (	
groups+ (2.PBItemGroup"$
MoveStep
dir (
len ("8
FrameMoveToProtocol	
x (	
y (
dir ("G
FrameMoveToRetProtocol

id (	
x (	
y (
dir ("2
FrameWorshipProtocol

id (
target ("&
FrameEntityExitProtocol
ids ("=
PBProp
propId (
propInt (

propString (	"É
FrameEntityEnterProtocol
isMe (
roleID (
mapID (	
x (	
y (
type (
props (2.PBProp"A
FramePropUpdateProtocol
roleID (
props (2.PBProp"F
FrameForbidRole
roleSID (

forbidTime (
reason (	"5
FrameMoveFailedProtocol
curX (
curY ("(
SkillOpenFireProtocol
skillId ("%
SkillDelteProtocol
skillId ("J
SkillCrashProtocol
skillId (
count (	
x (	
y ("S
SkillShortcutKeyProtocol
shortcutKey (
	protoType (
protoID ("S
SkillShortcutRetProtocol
shortcutKey (
	protoType (
protoID ("=
SkillUpgradeProtocol
skillId (
quickUpgrade ("W
SkillUseProtocol
skillId (
targetId (
targetX (
targetY ("ê
SkillSingProtocol
roleId (
targetId (
skillId (
targetX (
targetY (

skillLevel (

skillColor ("y
PBHurt

id (
now (
crit (
hurt (
hurtResistType (

clearbuffs (
buffID (";
SkillHurtProtocol
roleId (
hurts (2.PBHurt"N
PBSkill

id (
level (
exp (
key (
cdTime ("E
PBShortCutKey
ptotokey (
	prototype (
protoid ("P
SkillSyncProtocol
skills (2.PBSkill!
	shortKeys (2.PBShortCutKey"=
SkillUpdateProtocol

id (
level (
key ("K
PBCrash
targetId (

sx (

sy (

dx (

dy ("h
SkillCrashRetProtocol
roleId (	
x (	
y (
skillId (
crashs (2.PBCrash"W
SkillUpgradeRetProtocol
skillId (
level (
shutKey (
exp ("D
SkillFreshXpProtocol
skillId (
exp (
expAdd ("@
PBBuff

id (
hurt (
tick (
itemId ("&
BuffProtocol
buffs (2.PBBuff"7
SkillSwornProtocol
skillId (
targetId (	")
SkillClearCoolProtocol
skillId ("d
	SkillMove
entityId (	
x (	
y (
dir (
effectId (
targetId (">
SkillSpeedCheckStart
svrStartTime (
lastTime ("Ç
SkillSpeedCheckEnd
svrStartTime (
clientStartTime (
clientEndTime (

skillTotal (

skillCdMin ("Ω
SkillPkTestHurt

id (	
avoid (
skill_id (
	real_hurt (

skill_hurt (
add_hurt (
	def_avoid (

spec_avoid (
buff_id	 (
crit
 ("&
SkillPlayerDie
needStoneNum ("$
DialogClickProtocol
npcId ("c
DialogOptionProtocol
npcId (

dialogType (
dialogValue (
dialogParam ("a
PBOption
text (	
type (
value (
icon (
param (
op_id ("m
DialogClickRetProtocol
npcId (
txtId (
type (
txt (	
options (2	.PBOption">
PushActivityStart

id (
open (
canJoin ("T
PushSendRedBag

id (
name (	
num (
type (
param (	"!
PushGetRedBag
redBagID ("
PushRedBagMark
mark ("F
RideRetLoadDataProtocol
num (
rideIDs (
state ("9
RideChangeStateProtocol
opType (
rideID (",
RideChangeStateRetProtocol
opType ("l
RideFreshRideRetProtocol
isActive (
num (
rideIDs (
state (
	newRideID ("0
FactionAreaOpenFireProtocol
	factionID ("/
FactionAreaAddWoodProtocol
	factionID ("
FactionAreaGetWoodNumProtocol"S
 FactionAreaGetWoodNumRetProtocol
count (
isTime (
isLeader ("2
FactionAreaFireStatusPtotocol
	factionID ("r
 FactionAreaFireStatusRetProcotol
status (
addExp (
	totalWood (
time (
state ("&
P3V3StartMatchProtocol
type ("%
P3V3ExitMatchProtocol
type ("
P3V3StartMatchRetProtocol"4
P3V3Info

id (
battle (
name (	"m
P3V3MatchOpenProtocol
teamIdA (
teamIdB (
teamA (2	.P3V3Info
teamB (2	.P3V3Info"w
P3V3FightUpdateProtocol

id (
killA (
killB (
killNum (
	killOther (
status (")
P3V3FightResultProtocol
winner (")
	PBP3v3Key
key (
skillId ("r
P3V3RoleUpdateProtocol
count (
energy (
winCnt (
shutKey (
keys (2
.PBP3v3Key"
P3V3OverMatchRetProtocol"#
P3V3UseFlagProtocol
type ("6
P3V3SetShutkeyProtocol
skillId (
key ("2
P3V3PickFlagProtocol

id (
energy ("<
AISpeakProtocol

id (
type (
content (	"
FightTeam3v3GetInGameProtocol"\
FightTeam3v3MemberState
roleSID (	
state (
fightTeamID (
name (	"V
%FightTeam3v3MemberStateNotifyProtocol-
memberState (2.FightTeam3v3MemberState"ã
P3v3FightTeamMemberInfo
roleSID (	
roleName (	
battle (
kill (
level (
school (
isLeader ("ì
P3v3FightTeamInfo
fightTeamID (
fightTeamName (	
win (
lose ()
members (2.P3v3FightTeamMemberInfo
rank ("ã
!FightTeam3v3GameEndNotifyProtocol'
myFightTeam (2.P3v3FightTeamInfo*
enemyFightTeam (2.P3v3FightTeamInfo
	winTeamID ("+
FightTeam3v3WatchProtocol
teamID ("
FightTeam3v3QuitWatchProtocol"Y
#FightTeam3v3GameStateNotifyProtocol
state (
	countDown (
overTime ("
FightTeam3v3QuitGameProtocol"
FightTeam3v3ReliveProtocol"
FightTeam3v3GetRankProtocol"t
FightTeam3v3GetRankInfo
rank (
teamID (
teamName (	
battle (
win (
lose ("I
FightTeam3v3GetRankRetProtocol'
ranks (2.FightTeam3v3GetRankInfo"$
"FightTeam3vGetAuditionDataProtocol"î
%FightTeam3vGetAuditionDataRetProtocol
season (
	startDate (
endDate (
battleCount (
reward (

seasonName (	"%
#FightTeam3GetRegulationDataProtocol"?
FightTeam3vAuditionTeamInfo
teamID (
teamName (	"ª
(FightTeam3vGettRegulationDataRetProtocol
season (
stage (
date (
time (.
teamData (2.FightTeam3vAuditionTeamInfo
teamRank (

seasonName (	"#
!FightTeam3GetTeamDataDataProtocol"£
$FightTeam3GetTeamDataDataRetProtocol
season (
stage (
	startDate (
endDate ($
teamData (2.P3v3FightTeamInfo

seasonName (	"3
FightTeam3CountDownTimeProtocol
leftTime ("
GetMainObjectProtocol"L
GetMainObjectRetProtocol
doneObjectID (
takeRewardObjectID ("/
GetMainObjectRewardProtocol
objectID ("2
GetMainObjectRewardRetProtocol
objectID ("*
DoneMainObjectProtocol
objectID ("
VitrualEscrotTimeProtocol"0
VitrualEscrotTimeRetProtocol
leftTime ("
VitrualEscrotExitProtocol"-
VitrualEscrotResultProtocol
result ("C
GameConfigChangeProtocol
	gameSetID (
gameSetValue ("(

GameConfig
key (
value ("T
GameConfigLoadDataRetProtocol

gameSetNum (

gameConfig (2.GameConfig"B
GameConfigChangGuardProtocol
gameGuardID (
state ("3
GameConfigLoadGuardRetProtocol
	guardStep (	"
GameConfigGetGuardProtocol"-

GameSwitch
funID (
isActive (">
GameConfigSwitchRetProtocol

gameSwitch (2.GameSwitch"
ApolloAuthKeyProtocol"Ò
ApolloAuthKeyRetProtocol
dwErrno (
dwMainSvrId (
dwMainSvrUrl1 (	
dwMainSvrUrl2 (	
dwSlaveSvrId (
dwSlaveSvrUrl1 (	
dwSlaveSvrUrl2 (	
dwAuthkeyLen (
	szAuthKey	 (	

dwExpireIn
 (";
TssdkRecvAntiDataProtocol
dataSize (
data (	";
TssdkSendAntiDataProtocol
dataSize (
data (	"1
CopyTowerProgressCtrlProtocol
ctrlType ("k
"CopyTowerFinishProgressOneProtocol
copyType (
copyId (#

rewardInfo (2.CopyRewardInfo"W
!CopyTowerStartProgressOneProtocol
copyType (
copyId (
leftTime ("
TPayNotifyParamsError"P
TPayUpdateParams
openKey (	
payToken (	

pf (	
pfKey (	"[
TPayCZSucess
openKey (	
payToken (	

pf (	
pfKey (	
money (" 
TPayCZSucessRet
money ("*
MultiCopyUpLvProtocol
	currentLv (">
MultiCopyLvProtocol
	currentLv (
todayPassLvs ("õ
MultiCopyFlushRoadProtocol

currCircle (

flushRoad1 (

flushRoad2 (

flushRoad3 (

flushRoad4 (
currentPrizeStage ("
ReqMultiCopyLevelProtocol"1
ReqMultiCopyAllTeamDataProtocol
copyId ("=
MultiCopyOperResProtocol
	operation (
result ("3
MultiCopyTeamChallengeProtocol
	copyLevel ("É
"MultiCopyTeamChanllengeResProtocol
result (
	memberIds ((
errorMemberInfo (2.CopyMemberInfo
errorNum ("4
"MultiCopyLeaderQuestAttendProtocol
copyId ("/
MultiCopyAnswerAttendProtocol
answer ("B
MultiCopyAnswerToLeaderProtocol
roleSid (	
answer ("
SingleInstanceDataProtocol"_
SingleInstanceDataRetProtocol
passed_insts (

daily_inst (
daily_passed (";
EnterSingleInstProtocol
instID (
isInCopy ("*
SingleInstErrorCodeProtocol
err ("*
FinishSingleInstProtocol
instID ("
RequestRandomDailySingleInst"@
SingleInstIncDataProtocol
new_inst (
	new_daily ("
CancelEnterCopyProtocol"
FactionInvadeGetFactionReq"o
FactionInvadeData
facID (
facName (	
facLeaderName (	
facLevel (
	facBattle ("B
FactionInvadeGetFactionRet$
facInfos (2.FactionInvadeData"&
FactionInvadeEnterReq
facID ("#
!FactionInvadeGetCurFactionInfoReq"@
FactionInvadeCurFactionInfoRet
facID (
facName (	"3
FactionCommandSetUserIdProtocol
memberid (	"6
"FactionCommandSetUserIdRetProtocol
memberid (	"6
"FactionCommandSetUserIdNtfProtocol
memberid (	")
FactionDisbandNotify
	factionID ("6
FactionOpenIdBind
	factionID (
openId (	"
FactionOpenIdGet"%
FactionOpenIdNotify
openId (	"/
SecondPassSetPasswordPrtocol
strPass (	"!
SecondPassSetPasswordRetPrtocol"J
 SecondPassChangePasswordProtocol

strOldPass (	

strNewPass (	"%
#SecondPassChangePasswordRetProtocol"!
SecondPassResetPasswordProtocol">
"SecondPassResetPasswordRetProtocol
dwInvalidSeconds ("2
SecondPassCheckPasswordProtocol
strPass (	"$
"SecondPassCheckPasswordRetProtocol"%
#SecondPassGetInvalidSecondsProtocol"X
&SecondPassGetInvalidSecondsRetProtocol
dwPassStatus (
dwInvalidSeconds ("'
FightTeamCreateProtocol
name (	"1
FightTeamCreateRetProtocol
fightTeamID ("0
FightTeamAddProtocol
targetPlayerName (	"[
FightTeamBeInviteProtocol
fightTeamID (
fightTeamName (	

LeaderName (	"C
FightTeamReplyInviteProtocol
fightTeamID (
result (",
FightTeamRemoveProtocol
	targetSID (	"
FightTeamLeaveProtocol"
FightTeamLeaveRetProtocol"
FightTeamGetInfoProtocol"ó
FightTeamGetInfoRetProtocol
fightTeamID (
fightTeamName (	
winNum (
loseNum (+
fightTeamMemInfo (2.FightTeamMemInfo"r
FightTeamMemInfo
roleSID (	
name (	
level (
school (
battle (
position (")
ShaWarMoniWarStageUpdate
stage ("0
ShaWarRequestUpdateMoniWarStage
stage ("9
QueryQQVipInfoReqeust
accessToken (	
vip ("S
VipInfo
flag (
isvip (
year (
level (
luxury ("9
QQVipInfoResult
ret (
vipList (2.VipInfo"`
QueryQQFriendsVipInfoRequest
accessToken (	
fopenids (	
flags (	

pf (	"v
QQFriendVipInfo
openid (	
	is_qq_vip (
qq_vip_level (
is_qq_year_vip (

is_qq_svip ("`
QQFriendsVipInfoResult
ret ((
friendsVipInfo (2.QQFriendVipInfo
is_lost (")
MountArrestProtocol

dwEntityId (",
MountArrestRetProtocol

dwEntityId ("
MountSkinlistProtocol"-
MountSkinlistRetProtocol
	vecSkinId ("*
MountUseMountProtocol
	dwBagSlot ("-
MountUseMountRetProtocol
	dwBagSlot ("&
IdCount
nId (
nCount (" 
MountSacrificeBaseInfoProtocol"R
!MountSacrificeBaseInfoRetProtocol
dwFlag (
vecProperty (2.IdCount"K
MountArrestNtfProtocol
dwRoleEntityId (
dwMonsterEntityId (",
MountArrestEndProtocol

dwEntityId ("
MountArrestEndRetProtocol".
QQVipRewardBag
type (
status ("
QQVipRewardInfoRequest"6
QQVipRewardInfoResult
info (2.QQVipRewardBag"%
QQVipGetRewardRequest
type ("#
QQVipGetRewardResult
ret ("=
QQVipChargeFinishRequest
type (
accessToken (	"
TreasureJoinProtocol"
TreasureJoinRetProtocol"
TreasureOutProtocol"
TreasureOutRetProtocol"
TreasureReaminTimeProtocol"3
TreasureReaminTimeRetProtocol

remainTime ("
MarriageTourReq"+
MarriageError
res (
param (	""
MarriageTourAsk
maleSID (	"2
MarriageTourAnswer
res (
maleSID (	"!
MarriageTourResult
res ("
MarriageTourTaskGiveUpReq"
MarriageTourTaskGiveUp"4
MarriageSCTask
taskType (
taskStep ("^
MarriageSCFinishTask
taskType (
taskStep (
nextType (
nextStep ("
MarriageCSRecvTask"
MarriageReqTourTimeout"
MarriageRtnTourTimeout"/
MarriageTourOpt
taskId (
step ("
MarriageTourTaskFinish"D
MarriageTourOptBroadCast
taskId (
step (

id ("
MarriageCSCurTask"G
MarriageSCCurTask
taskType (
taskStep (
status ("*
MarriageTourGiveUpReq
	femaleSID (	"
MarriageTourGiveUp"
MarriageTourRtn"-
MarriageTourTaskUpdateStatus
count (">
TourInfo
taskType (
taskStep (
status ("∞
MarriageInfo
maleSID (	
	femaleSID (	
status (
tourinfo (2	.TourInfo
weddingStatus (

marriageID (	
maleName (	

femaleName (	"
MarriageSCTourTaskFinish"&
MarriageCSEnterCeremony
res ("&
MarriageSCEnterCeremony
res ("
MarriageCSEnterCeremonyCancel"
MarriageSCEnterCeremonyWait" 
MarriageSCArriaveCeremonyPoint"#
!MarriageCSQuitCeremonyBeforePoint"
MarriageCSCeremonyFini")
MarriageCSReqStartWedding
type ("
MarriageSCStartWeddingSucc"C
MarriageSCWeddingCarStart	
x (	
y (
targetID ("B
MarriageSCWeddingCarStop	
x (	
y (
targetID ("B
MarriageSCWeddingCarFini	
x (	
y (
targetID ("1
MarriageCSWeddingInvitation

marriageID (	"
MarriageCSEnterWeddingVenue"0
MarriageCSWeddingVenueInfo

marriageID (	"∏
MarriageSCWeddingVenueInfo>
ambienceInfo (2(.MarriageSCWeddingVenueInfo.AmbienceInfo6
playInfo (2$.MarriageSCWeddingVenueInfo.PlayInfo
maleSID (	
	femaleSID (	

marriageID (	∂
AmbienceInfoK
ambienceItem (25.MarriageSCWeddingVenueInfo.AmbienceInfo.AmbienceItemY
AmbienceItem
ambience (
status (
endTime (
endCoolingTime (∞
PlayInfo?
playItem (2-.MarriageSCWeddingVenueInfo.PlayInfo.PlayItemc
PlayItem
play (
status (
endTime (
endCoolingTime (
ownerSID (	"1
MarriageCSWeddingInvitationInfo
roleID (	"k
MarriageSCWeddingInvitationInfo
roleID (	

marriageID (	
maleName (	

femaleName (	"
MarriageCSWeddingGuestList"í
WeddingGuestInfo
roleName (	
sex (
school (
level (
bonus1 (
bonus2 (
bonus3 (
reoleSID (	"A
MarriageSCWeddingGuestList#
infoList (2.WeddingGuestInfo"?
MarriageCSWeddingSendBonus
bonus (

marriageID (	"/
MarriageSCWeddingSendBonusSucc
bonus ("+
MarriageCSWeddingKickOut
roleSID (	"=
MarriageSCWeddingKickOut
roleSID (	
roleName (	"-
MarriageCSWeddingAmbience
ambience ("U
MarriageSCWeddingAmbienceSucc
ambience (
	startTime (
endTime ("
MarriageCSWeddingOnTheCar"
MarriageCSWeddingUnderTheCar"%
MarriageCSWeddingPlay
play ("e
MarriageSCWeddingPlaySucc
play (
	startTime (
endTime (
endCoolingTime ("/
 MarriageSCWeddingHydrangeaRandom
SID (	")
MarriageSCWeddingPlayFini
play ("0
MarriageCSWeddingBonusInfo

marriageID (	"L
MarriageSCWeddingBonusInfo
bonus1 (
bonus2 (
bonus3 ("ï
MarriageSCWeddingDrinkFailed
type (B
drinkPlayInfo (2+.MarriageSCWeddingDrinkFailed.DrinkPlayInfoF
drinkMemberInfo (2-.MarriageSCWeddingDrinkFailed.DrinkMemberInfo'
DrinkPlayInfo
endCoolingTime (2
DrinkMemberInfo
status (
endTime ("K
MarriageSCWeddingDrinkSucc
cups (
status (
endTime ("|
MarriageSCWeddingDrinkRank6
rankList (2$.MarriageSCWeddingDrinkRank.rankItem&
rankItem
name (	
cups ("4
MarriageCSWeddingVenueTimeInfo

marriageID (	"D
MarriageSCWeddingVenueTimeInfo
	startTime (
endTime ("
EnterMazeReq"
EnterMazeRet
reCode ("
ResetMazeReq"
ResetMazeRet
reCode ("
MazeEnterNextReq
dir (""
MazeEnterNextRet
reCode ("
ExitMazeReq"
ExitMazeRet
reCode ("
NotifyMazeReq"f
MazeNodeInfo
index (
mapId (
	openState (
	eventType (

eventState ("…
NotifyMazeRet
curIndex ( 
	mazeNodes (2.MazeNodeInfo
endIndex (
prizeIndexs (#
curPathNodes (2.MazeNodeInfo%
rightPathNodes (2.MazeNodeInfo
	completed ("H
MazeNodeNotify
mazeNode (2.MazeNodeInfo
curPathIndexs ("
MazeNodeGameStartReq"&
MazeNodeGameStartRet
reCode ("
MazeNodeGamePrizeReq"&
MazeNodeGamePrizeRet
reCode ("5
MazeNodeRewardNotify
info (2.CopyRewardInfo"*
MazeNodeRewardIndexNotify
param ("(
MazeNodeCountDownNotify
param ("(
MazeNodeKillCountNotify
param ("(
MazeNodeHurtCountNotify
param ("
MazeDataReq"4
MazeDataRet
canReset (
dailyPrized ("!
MazeJumpOtherReq
index (""
MazeJumpOtherRet
reCode ("
MazeComplete"
MazeUseQLYFSucess