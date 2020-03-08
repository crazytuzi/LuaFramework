FriendShip.tbDataType = {  -- 和C里类型值需要报纸一致 --这里可以不要了，如果别的地方没有用到的话
	["emFriendData_Type"] 				= 1;
	["emFriendData_Imity"] 				= 2;
	["emFriendData_Enemy_Left"] 		= 3;
	["emFriendData_Enemy_Right"] 		= 4;
	["emFriendData_BlackOrRequest"] 	= 5; --现在 只存申请了,黑名单单独存
	["emFriendData_Temp_Refuse"] 		= 6;
	["emFriendData_WeddingState"] 		= 7;
	["emFriendData_WeddingTime"] 		= 8;
}

FriendShip.tbDataVal = {  -- 和C里类型值需要报纸一致
	["emFriend_Type_Invalid"] 		= 0;
	["emFriend_Type_Friend"] 		= 1;

	["emFriend_Type_Request_Left"] 	= 2;
	["emFriend_Type_Request_Right"] = 3;
}

local emFriendData_Type = FriendShip.tbDataType.emFriendData_Type
local emFriendData_Imity = FriendShip.tbDataType.emFriendData_Imity
local emFriendData_Enemy_Left = FriendShip.tbDataType.emFriendData_Enemy_Left
local emFriendData_Enemy_Right = FriendShip.tbDataType.emFriendData_Enemy_Right
local emFriendData_BlackOrRequest = FriendShip.tbDataType.emFriendData_BlackOrRequest
local emFriendData_Temp_Refuse = FriendShip.tbDataType.emFriendData_Temp_Refuse
local emFriendData_WeddingState = FriendShip.tbDataType.emFriendData_WeddingState
local emFriendData_WeddingTime = FriendShip.tbDataType.emFriendData_WeddingTime

local emFriend_Type_Invalid = FriendShip.tbDataVal.emFriend_Type_Invalid
local emFriend_Type_Friend = FriendShip.tbDataVal.emFriend_Type_Friend
local emFriend_Type_Request_Left = FriendShip.tbDataVal.emFriend_Type_Request_Left
local emFriend_Type_Request_Right = FriendShip.tbDataVal.emFriend_Type_Request_Right

FriendShip.SHOW_LEVEL = 10; --XX级才显示好友系统

FriendShip.nEnemyLevelLimit = 20 --对方等级比自己小于此值则不会成为自己的仇人 和C里一致

FriendShip.nMaxEnemyNum  = 20 --最大仇人数 和C里需定义一样
FriendShip.tbFriendNumLimit = --最大好友数
{
	{1 , 50,}, --等级，数量
	{11, 60,}, 
	{21, 70,}, 
	{31, 80,}, 
	{41, 90,},
	{51, 100,}, 
}


FriendShip.nMaxPrivateMessages = 1000 --内存中最多保存的数 

FriendShip.nTempRefuseTime = 15 --点击一键清空后xx 秒内不会收到指定玩家的好友申请请求

--通缉
FriendShip.nWantedTimeShort = 3600 * 2 --普通通缉时间
FriendShip.nWantedTimeLong = 3600 * 24 --长通缉时间
FriendShip.nWantedLongCost = 200  --长效通缉的话费

FriendShip.nRequsetWantedCdTime = 10; --TODO 请求通缉的时间间隔 测试所以短点

--被复仇者增加的仇恨值
FriendShip.nRevengeAddHate = 20000; --
	
--被碎片抢夺增加的仇恨
FriendShip.nRobDebrisAddHate = 10000;

--通缉击杀增加的仇恨
FriendShip.nCatchAddHate = 0;

--地图探索遇敌击杀增加的仇恨
FriendShip.nMapExploreAddHate = 20000;
FriendShip.nMapExploreFailAddHate = 10000; --探索PK失败

FriendShip.FIGHT_MAP = 1018 --复仇通缉异步战斗地图
FriendShip.ENTER_POINT = {1970, 2291} --复仇通缉异步地图点

--头衔胜率
FriendShip.tbHonorProb = {
	{-3,  1},
	{-2,  1},
	{-1,  0.75}, 
	{ 0,  0.5}, 
	{ 1,  0.25},
	{ 2,  0},
	{ 3,  0},
}

FriendShip.tbImityAchivementLevel = { 5, 10,20,30, 40 }

FriendShip.nTeamHelpBuffId = 2308;--显示队友加成的buff

FriendShip.nViewRelationInterval = 600; --客户端缓存更新Cd
FriendShip.nViewRelationServerInterval = 7200; --服务端缓存的数据重登时更新Cd
FriendShip.SAVE_GROUP = 144;
FriendShip.SAVE_KEY_VIEW_FRIEND = 1;
FriendShip.SAVE_KEY_VIEW_STRANGE = 2;
FriendShip.SAVE_KEY_LOGIN_DAY = 3;


FriendShip.nViewRelationImityMin = 1801

FriendShip.FIVE_ELEMENTS_TASK_ID = 3507 --五行好友任务ID



local fnGetFriendData;
if MODULE_GAMESERVER then
	fnGetFriendData = function (dwRoleId1, dwRoleId2)
		return KFriendShip.GetFriendShipValSet(dwRoleId1, dwRoleId2)
	end
else
	fnGetFriendData = function (dwRoleId1, dwRoleId2)
		local nMyId = me.nLocalServerPlayerId or me.dwID
		local dwRoleId = nMyId == dwRoleId1 and dwRoleId2 or dwRoleId1
		return FriendShip.tbAllData[dwRoleId]
	end
end
FriendShip.fnGetFriendData = fnGetFriendData

--com 
function FriendShip:Init()
	local tbFile	= Lib:LoadTabFile("Setting/FriendShip/IntimacyLevel.tab", {Level = 1, MinIntimacy = 1, MaxIntimacy = 1, AddExpP = 1});
	if not tbFile then
		Log(debug.traceback())
		return
	end

	for nRow, tbInfo in ipairs(tbFile) do
		assert(nRow == tbInfo.Level, "IntimacyLevel : " .. tbInfo.Level);
	end

	FriendShip.tbIntimacyLevel = tbFile
	FriendShip.nMaxImitiy = tbFile[#tbFile].MaxIntimacy
end

function FriendShip:GetMaxFriendNum(nLevel, nVipLevel)
	local nMaxNum = 0;
	for i,v in ipairs(self.tbFriendNumLimit) do
		if nLevel >= v[1] then
			nMaxNum = v[2]
		else
			break;
		end
	end
	for i,v in ipairs(Recharge.tbVipExtSetting.ExFriendNum) do
		if nVipLevel < v[1] then
			break;
		else
			nMaxNum = nMaxNum + v[2] 	
		end
	end
	
	return nMaxNum
end

--两者是不是好友 ， 客户端也能判断 --com
function FriendShip:IsFriend(dwRoleId1, dwRoleId2, tbFriendData)
	if not tbFriendData then
		tbFriendData = fnGetFriendData(dwRoleId1, dwRoleId2);
	end
	return tbFriendData and tbFriendData[emFriendData_Type] == emFriend_Type_Friend
end

--是不是在他的暂时拒绝列表中
function FriendShip:IsInHisTempRefuse(dwRoleId1, dwRoleId2, tbFriendData)
	if not tbFriendData then
		tbFriendData = fnGetFriendData(dwRoleId1, dwRoleId2);
	end
	if not tbFriendData then
		return false
	end
	local nDataVal = tbFriendData[emFriendData_Temp_Refuse] 
	if not nDataVal then
		return false
	end
	local nNow = GetTime()
 	if dwRoleId1 < dwRoleId2 then
 		if nNow < - nDataVal then
 			return true
 		end
	else
		if nNow < nDataVal then
			return true
		end
 	end
end

function FriendShip:IsHeIsMyEnemy(dwRoleId1, dwRoleId2, tbFriendData)
 	if not tbFriendData then
		tbFriendData = fnGetFriendData(dwRoleId1, dwRoleId2);
	end
	if not tbFriendData then
		return false, 0
	end
	

	if	dwRoleId1 < dwRoleId2 then
		if tbFriendData[emFriendData_Enemy_Left] and tbFriendData[emFriendData_Enemy_Left] > 0 then
			return true, tbFriendData[emFriendData_Enemy_Left]
		end
	else
		if tbFriendData[emFriendData_Enemy_Right] and tbFriendData[emFriendData_Enemy_Right] > 0 then
			return true, tbFriendData[emFriendData_Enemy_Right]
		end
	end
	return false, 0
 end 

--已经对别人提交申请了
function FriendShip:IsRequestedAdd(dwRoleId1, dwRoleId2, tbFriendData)
	if not tbFriendData then
		tbFriendData = fnGetFriendData(dwRoleId1, dwRoleId2);
	end
	if not tbFriendData then
		return false
	end
	if dwRoleId1 < dwRoleId2 then
		if  tbFriendData[emFriendData_BlackOrRequest] == emFriend_Type_Request_Left then
			return true
		end
	else
		if  tbFriendData[emFriendData_BlackOrRequest] == emFriend_Type_Request_Right then
			return true
		end
	end
end

--自己被别人申请了
function FriendShip:IsMeRequested(dwRoleId1, dwRoleId2, tbFriendData)
	if not tbFriendData then
		tbFriendData = fnGetFriendData(dwRoleId1, dwRoleId2);
	end
	if not tbFriendData then
		return false
	end
	if dwRoleId1 < dwRoleId2 then
		if  tbFriendData[emFriendData_BlackOrRequest] == emFriend_Type_Request_Right then
			return true
		end
	else
		if  tbFriendData[emFriendData_BlackOrRequest] == emFriend_Type_Request_Left then
			return true
		end
	end
end

--获取亲密度值当前的等级和最大值
function FriendShip:GetImityLevel(nImity)
	if not nImity or nImity == 0 then
		return
	end
	
	local tbIntimacyLevel = self.tbIntimacyLevel
	--4个等级做为一个大的检查步长
	local nFindMax = #tbIntimacyLevel
	for i = 1, nFindMax, 4 do
		local v = tbIntimacyLevel[i]
		if v.MaxIntimacy >= nImity then
			if nImity >= v.MinIntimacy then
				return v.Level, v.MaxIntimacy
			end
			nFindMax = i;
			break;
		end
	end

	for i = nFindMax - 3, nFindMax do --i - 4已经查过的
		local v = tbIntimacyLevel[i]
		if v.MaxIntimacy >= nImity then
			return v.Level, v.MaxIntimacy
		end
	end
end

--获取亲密度
function FriendShip:GetImity(dwRoleId1, dwRoleId2, tbFriendData)
	if not tbFriendData then
		tbFriendData = fnGetFriendData(dwRoleId1, dwRoleId2);
	end
	if not tbFriendData or tbFriendData[emFriendData_Type] ~= emFriend_Type_Friend then
		return
	end
	return tbFriendData[emFriendData_Imity]
end

function FriendShip:GetFriendImityLevel(dwRoleId1, dwRoleId2)
    local nImity = FriendShip:GetImity(dwRoleId1, dwRoleId2);
    if not nImity then
    	return;
    end

	return FriendShip:GetImityLevel(nImity);
end

function FriendShip:GetFriendImityExpP(nImityLevel)
    if not nImityLevel then
    	return 0;
    end

    local tbInfo = self.tbIntimacyLevel[nImityLevel];
    if not tbInfo then
    	return 0;
    end

    return tbInfo.AddExpP or 0;
end

function FriendShip:GetNextRevengeTime()
	return me.GetUserValue(5, 3)
end

function FriendShip:GetRevengeCDTiem(nNow)
	local nNextTime = self:GetNextRevengeTime()
	if nNextTime == 0 then
		return 0
	end
	nNow = nNow or GetTime()
	local nCd = nNextTime - nNow
	return nCd < 0 and 0 or nCd
end

function FriendShip:GetRevengeCDMoney(nCdTime)
	return math.floor(nCdTime / 60 / 30) * 20 * 10
end


--对别人的仇恨增加时，别人对你的仇恨减少的值
function FriendShip:GetMinusHate(nAddHate, nHisHate)
	return math.min(math.floor(nAddHate * 0.8), nHisHate)
end

function FriendShip:GetRevengetRobCoin(nHisCoin)
	return math.min(MathRandom(20000, 100000), math.floor(nHisCoin))
end

function FriendShip:WeddingStateType()
	return emFriendData_WeddingState
end

function FriendShip:WeddingTimeType()
	return emFriendData_WeddingTime
end