--------------------------------------------------------------------------------------
-- 文件名:	Game_EctypeListSystem.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	lixu
-- 日  期:	2015-5-6
-- 版  本:	1.0
-- 描  述:	
--[[
			mapid
			/ / \ \
		   / /   \  \
		 Obj_EctypeSub ...
		/ / \
	三个难度
--]]
-- 应  用:   
---------------------------------------------------------------------------------------
EctypeBoxReward =
{
	_Left 	= 1,
	_Middle = 2,
	_Right 	= 3
}

EctypeActivation =
{
	_UnActivation	= 0, --未激活
	_Activation 	= 1
}

RewardBoxStatus=
{
	_CanObtainNotObtain		= 1,	--可领取, 未领取
	_CanObtainHasObtain		= 2,	--可领取, 已领取
	_CanNotObtain			= 3,	--不可领取
}

RewardBoxServerStatus=
{
	_HasNotObtain		= false,	--未领取
	_HasObtain			= true,	--已领取
}

EctypeSubLevelType=
{
	_PuTong					= 1,	--普通
	_GaoShou			= 2,	--高手
	_ZongShi		= 3,	--宗师
}

EctypeStarString=
{
	[1] = {
		[0] = "2",
		[1] = "1",
	},
	[2] = {
		[0] = "22",
		[1] = "12",
		[2] = "11",
	},
	[3] = {
		[0] = "222",
		[1] = "122",
		[2] = "112",
		[3] = "111",
	},
}

---------------每个副本数据结构------------------
EctypeSub = class("EctypeSub")
EctypeSub.__index = EctypeSub

function EctypeSub:ctor()
	self.iPassed_id = nil 		--关卡id

	self.CsvInfo 	= nil		--表格数据

	self.attack_num = 0			--攻击次数

	self.iStar_num 	= {0,0,0}	--星星数	索引为 难度等级(子副本索引) 每个难度的星星1，2，3

	self.tbReward 	= {}  		--掉落组

	self.iIsActivate = EctypeActivation._UnActivation
end

function EctypeSub:initDropRewardItems()
	--构造掉落数据
	--副本配置表有三个固定的掉落项
	self.tbReward = {
		All = {},
		[EctypeSubLevelType._PuTong] = {},
		[EctypeSubLevelType._GaoShou] = {},
		[EctypeSubLevelType._ZongShi] = {},
	}
	
	local nMapCsvID = self.csvInfo.MapID
	if self.csvInfo ~= nil then
		for nPreViewDropPackType = 1, 6 do
			local nDropSubPackClientID = self.csvInfo["ShowDropPackID"..nPreViewDropPackType]
			if nDropSubPackClientID > 0 then
				local CSV_DropSubPackClient = g_DataMgr:getCsvConfig_SecondKeyTableData("DropSubPackClient", nDropSubPackClientID)
				if CSV_DropSubPackClient then
					for k, v in pairs (CSV_DropSubPackClient) do
						if v.DropItemID > 0 then
							if nPreViewDropPackType == 1 then
								if nMapCsvID == 1 then
									table.insert(self.tbReward[EctypeSubLevelType._PuTong], v)
								elseif nMapCsvID == 2 then
									table.insert(self.tbReward[EctypeSubLevelType._GaoShou], v)
								else
									table.insert(self.tbReward[EctypeSubLevelType._ZongShi], v)
								end
								table.insert(self.tbReward.All, v)
							elseif nPreViewDropPackType == 2 then
								-- if nMapCsvID == 1 then
									-- table.insert(self.tbReward[EctypeSubLevelType._PuTong], v)
								-- elseif nMapCsvID == 2 then
									-- table.insert(self.tbReward[EctypeSubLevelType._GaoShou], v)
								-- else
									-- table.insert(self.tbReward[EctypeSubLevelType._GaoShou], v)
									-- table.insert(self.tbReward[EctypeSubLevelType._ZongShi], v)
								-- end
								-- table.insert(self.tbReward.All, v)
							elseif nPreViewDropPackType == 3 then
								table.insert(self.tbReward[EctypeSubLevelType._PuTong], v)
								table.insert(self.tbReward[EctypeSubLevelType._GaoShou], v)
								table.insert(self.tbReward[EctypeSubLevelType._ZongShi], v)
								table.insert(self.tbReward.All, v)
							elseif nPreViewDropPackType == 4 then
								table.insert(self.tbReward[EctypeSubLevelType._PuTong], v)
								table.insert(self.tbReward[EctypeSubLevelType._GaoShou], 
									{
										DropItemType = v.DropItemType,
										DropItemID = v.DropItemID,
										DropItemStarLevel = v.DropItemStarLevel + 1,
										DropItemNum = v.DropItemNum,
										DropItemEvoluteLevel = v.DropItemEvoluteLevel,
									}
								)
								table.insert(self.tbReward[EctypeSubLevelType._ZongShi], 
									{
										DropItemType = v.DropItemType,
										DropItemID = v.DropItemID,
										DropItemStarLevel = v.DropItemStarLevel + 2,
										DropItemNum = v.DropItemNum,
										DropItemEvoluteLevel = v.DropItemEvoluteLevel,
									}
								)
								table.insert(self.tbReward.All, v)
							elseif nPreViewDropPackType == 5 then
								table.insert(self.tbReward[EctypeSubLevelType._PuTong], v)
								table.insert(self.tbReward[EctypeSubLevelType._GaoShou], v)
								table.insert(self.tbReward[EctypeSubLevelType._ZongShi], v)
								table.insert(self.tbReward.All, v)
							elseif nPreViewDropPackType == 6 then
								table.insert(self.tbReward[EctypeSubLevelType._PuTong], v)
								table.insert(self.tbReward[EctypeSubLevelType._GaoShou], v)
								table.insert(self.tbReward[EctypeSubLevelType._ZongShi], v)
								table.insert(self.tbReward.All, v)
							end
						end
					end
				end
			end
		end
	end
end

function EctypeSub:SetEctypeBaseInfo(passid, tbstar, iatknum)

	self.iPassed_id = passid

	self.attack_num = iatknum

	self.csvInfo = g_DataMgr:getMapEctypeCsv(passid)

	--服务器的数据 是 ｛0，3，3，3｝额 所以要转一下
	local nIndex = 1
	if tbstar ~= nil then
		for i=1, #tbstar do
			if tbstar[i] ~= 0 then
				self.iStar_num[i] = tbstar[i]
				nIndex = nIndex + 1
			end
		end
	end
end

function EctypeSub:GetActivation()
	return self.iIsActivate
end

function EctypeSub:SetActivation(_activation)
	self.iIsActivate = _activation
end

--获取奖励总数量
function EctypeSub:GetRewardCountAll()
	cclog("===========#self.tbReward.All========="..#self.tbReward.All)
	return #self.tbReward.All
end

--通过下标获取掉落奖励物品
function EctypeSub:GetRewardItemByIndex(nIndex)
	return self.tbReward.All[nIndex]
end

--获取奖励总数量
function EctypeSub:GetRewardCountByType(nEctypeSubLevelType)
	return #self.tbReward[nEctypeSubLevelType]
end

--通过下标获取掉落奖励物品
function EctypeSub:GetRewardItemByType(nEctypeSubLevelType, nIndex)
	return self.tbReward[nEctypeSubLevelType][nIndex]
end

function EctypeSub:getEctypeCsvID()
	return self.iPassed_id
end

--动画文件
function EctypeSub:GetSpineFile()
	return (self.csvInfo == nil and " ") or self.csvInfo.BossPotrait
end

--动画文件X坐标
function EctypeSub:GetSpinFilePosX()
	return (self.csvInfo == nil and " ") or self.csvInfo.Pos_X
end

--动画文件Y坐标
function EctypeSub:GetSpinFilePosY()
	return (self.csvInfo == nil and " ") or self.csvInfo.Pos_Y
end

--动画文件X坐标
function EctypeSub:GetSpinFileWidth()
	return (self.csvInfo == nil and " ") or self.csvInfo.CardWidth
end

--动画文件Y坐标
function EctypeSub:GetSpinFileHeight()
	return (self.csvInfo == nil and " ") or self.csvInfo.CardHeight
end

--副本名称
function EctypeSub:GetEctypeName()
	return (self.csvInfo == nil and " ") or self.csvInfo.EctypeName
end

--难度系数
function EctypeSub:GetDegree()
	return (self.csvInfo == nil and 0) or self.csvInfo.MonsterStarLevel
end

--最大攻击次数
function EctypeSub:GetMaxAttackCount()
	return (self.csvInfo == nil and 0) or self.csvInfo.MaxFightNums
end

--当前攻击次数
function EctypeSub:GetCurAttackCount()
	return self.attack_num
end

--当前副本星星个数
function EctypeSub:GetStarNum()
	local iStar_num = 0
	for k, v in pairs(self.iStar_num)do
		iStar_num = iStar_num + v
	end
	return iStar_num
end

function EctypeSub:GetStarStringValue()
	if self.csvInfo.MapID == 1 then
		return EctypeStarString[1][self:GetStarNum()]
	elseif self.csvInfo.MapID == 2 then
		return EctypeStarString[2][self:GetStarNum()]
	else
		return EctypeStarString[3][self:GetStarNum()]
	end
end


--获取当前难度的星星个素
function EctypeSub:GetDegreeStarCount(nIndex)
	return (self.iStar_num[nIndex] == nil and 0) or self.iStar_num[nIndex]
end

--当前副本最多星星个数
function EctypeSub:GetMaxStarNum()
	return 9 --一个副本 有3个难度  每个难度中 最多有 3颗星
end

--是否是boss副本 1为boss
function EctypeSub:GetIsBossSub()
	return (self.csvInfo == nil and 0) or self.csvInfo.IsBoss
end

--放回难度副本 三个难度子副本 顺序  子副本1 2 3
function EctypeSub:GetDegreeSub()
	if self.csvInfo == nil then
		return 0 ,0 ,0
	end
	return self.csvInfo.ShowDropPackID1, self.csvInfo.ShowDropPackID2, self.csvInfo.ShowDropPackID3
end

---------------------------------------------------------------------------------------外部接口类
Game_EctypeListSystem = class("Game_EctypeListSystem")
Game_EctypeListSystem.__index = Game_EctypeListSystem

function Game_EctypeListSystem:ctor()
	self.tbMapEctypeList		= {}	--副本列表
	self.nCurrentMapCsvID		= 0		--当前地图id

	self.tbRewardBoxStatus		= {}	--当前地图星星宝箱--0表示未操作过的 标记服务器状态
	--当前地图礼包id
	self.tbRewardBoxID			= {}
	self.tbRewardBoxDropList	= {}
end

function Game_EctypeListSystem:Init()
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_MAP_STAR_BOX_NOTIFY, handler(self, self.RespondUpdataStarRewardBox))
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_MAP_STAR_REWARD_RESPONSE, handler(self, self.RespondGetStarRewardBox))
end

--获取当前地图的星星个数
function Game_EctypeListSystem:GetCurEctypeStarNum(nMapCsvID)
	local nStarNum = 0
	for k , v in ipairs(self.tbMapEctypeList[nMapCsvID]) do
		nStarNum = nStarNum + v:GetStarNum()
	end
	return nStarNum
end

--获取当前地图的最大星星个素
function Game_EctypeListSystem:GetEctypMaxStarNum(nMapCsvID)
	return self:GetNeedStarRecord(nMapCsvID, 3)
end

--获取当前地图的副本数量
function Game_EctypeListSystem:GetEctypeNum(nMapCsvID)
	return GetTableLen(self.tbMapEctypeList[nMapCsvID])
end

--通过下标获取当前副本
function Game_EctypeListSystem:GetEctypeSubByIndex(nMapCsvID, nIndex)
	if not nMapCsvID or 
	   not self.tbMapEctypeList or 
	   not self.tbMapEctypeList[nMapCsvID] then
		return nil 
	end

	for k, v in ipairs(self.tbMapEctypeList[nMapCsvID]) do
		if k == nIndex then
			return v
		end
	end
	return nil
end

--通过副本id获取当前副本
function Game_EctypeListSystem:GetEctypeSuyBySubID(nMapCsvID, nEctypeCsvID)
	local Obj_EctypeSub = nil

	if self.tbMapEctypeList == nil or self.tbMapEctypeList[nMapCsvID] == nil then return nil end

	for k, v in pairs(self.tbMapEctypeList[nMapCsvID])do
		if v.iPassed_id == nEctypeCsvID then
			Obj_EctypeSub = v
			break
		end
	end

	return Obj_EctypeSub
end

--获取宝箱礼包ID 内部函数
function Game_EctypeListSystem:GetRewardBoxID(nMapCsvID, nIndex)
	-- return (nIndex > 3 and 0) or self.tbRewardBoxID[nMapCsvID][nIndex]
	if not nMapCsvID or not nIndex or nIndex > 3 then return 0 end

	if not self.tbRewardBoxID or
	   not self.tbRewardBoxID[nMapCsvID] or
	   not	self.tbRewardBoxID[nMapCsvID][nIndex] then

		return 0 
	end

	return self.tbRewardBoxID[nMapCsvID][nIndex]
end

--获取当前宝箱对应的星星数
function Game_EctypeListSystem:GetNeedStarRecord(nMapCsvID, nIndex)
	-- cclog("=============检查副本=========2=== "..nMapCsvID.." nIndex="..nIndex)
	local nRewardCsvID = self:GetRewardBoxID(nMapCsvID, nIndex)
	--取标头就默认的取1的值 －－ CSV_MapStarReward.NeedStarRecord
	local CSV_MapStarReward = g_DataMgr:getCsvConfig_FirstKeyData("MapStarReward", nRewardCsvID)
	-- cclog("=============检查副本=========3=== "..CSV_MapStarReward.NeedStarRecord)
	return CSV_MapStarReward.NeedStarRecord
end

--通过下标获取当前星星宝箱状态
function Game_EctypeListSystem:GetBoxRewardStatusByIndex(nMapCsvID, nIndex)
	if self:GetCurEctypeStarNum(self.nCurrentMapCsvID) >= self:GetNeedStarRecord(nMapCsvID, nIndex) then	-- 宝箱可以领
		if self.tbRewardBoxStatus[nMapCsvID][nIndex] == RewardBoxServerStatus._HasNotObtain then	-- 宝箱未领
			return RewardBoxStatus._CanObtainNotObtain
		elseif self.tbRewardBoxStatus[nMapCsvID][nIndex] == RewardBoxServerStatus._HasObtain then	-- 宝箱已领
			return RewardBoxStatus._CanObtainHasObtain
		end
	else
		return RewardBoxStatus._CanNotObtain
	end
end

--通过下标获取当前星级宝箱的掉落预览
function Game_EctypeListSystem:GetBoxRewardBoxDropListByIndex(nMapCsvID, nIndex)
	return self.tbRewardBoxDropList[nMapCsvID][nIndex]
end

--获取当前地图下面开放的右边Index
function Game_EctypeListSystem:GetEctypeCursorIndex(nMapCsvID)
	if not self.tbMapEctypeList[nMapCsvID] then
		return 1
	end

	for nIndex = 1, #self.tbMapEctypeList[nMapCsvID] do
		if not self.tbMapEctypeList[nMapCsvID] or
		   not self.tbMapEctypeList[nMapCsvID][nIndex] or
		   self.tbMapEctypeList[nMapCsvID][nIndex]:GetActivation() == EctypeActivation._UnActivation then
			return nIndex - 1
		end
	end
	return #self.tbMapEctypeList[nMapCsvID]
end

--获取副本数据是否存在
function Game_EctypeListSystem:GetEctypeDataIsExist(MapID)
	return (self.tbRewardBoxStatus[MapID] ~= nil)
end

--构造副本是否激活的数据
function Game_EctypeListSystem:InitEctypeActivateInfo(nMapCsvID)
	local tbEctypeList = g_DataMgr:getEctypeListByMapBaseID(nMapCsvID)
	if not tbEctypeList then return end
	--获取当前最大的已通关副本ID
	local nFinalClearEctypeID = g_Hero:getFinalClearEctypeID()
	local CSV_MapEctype = g_DataMgr:getMapEctypeCsv(nFinalClearEctypeID)
	if nFinalClearEctypeID == 0 then	--完全是新号一个地图都没打
		for nIndex = 1, #tbEctypeList do
			if nIndex == 1 then
				self.tbMapEctypeList[nMapCsvID][nIndex]:SetActivation(EctypeActivation._Activation)
			else
				self.tbMapEctypeList[nMapCsvID][nIndex]:SetActivation(EctypeActivation._UnActivation)
			end
		end
	else
		if nMapCsvID == CSV_MapEctype.MapID then --
			for nIndex = 1, #tbEctypeList do
				local nEctypeID = tbEctypeList[nIndex]
				if nEctypeID <= nFinalClearEctypeID then	--说明是已通关了副本
					self.tbMapEctypeList[nMapCsvID][nIndex]:SetActivation(EctypeActivation._Activation)
				else	--后面就是未通关了的副本
					if nEctypeID == nFinalClearEctypeID + 1 then	--第一个未通关副本是已激活的
						self.tbMapEctypeList[nMapCsvID][nIndex]:SetActivation(EctypeActivation._Activation)
					else
						self.tbMapEctypeList[nMapCsvID][nIndex]:SetActivation(EctypeActivation._UnActivation)
					end
				end
			end
		elseif nMapCsvID > CSV_MapEctype.MapID then
			if nMapCsvID == CSV_MapEctype.MapID + 1 then --新开放的地图
				for nIndex = 1, #tbEctypeList do
					if nIndex == 1 then
						self.tbMapEctypeList[nMapCsvID][nIndex]:SetActivation(EctypeActivation._Activation)
					else
						self.tbMapEctypeList[nMapCsvID][nIndex]:SetActivation(EctypeActivation._UnActivation)
					end
				end
			else --UI错误
				for nIndex = 1, #tbEctypeList do
					self.tbMapEctypeList[nMapCsvID][nIndex]:SetActivation(EctypeActivation._UnActivation)
				end
			end
		elseif nMapCsvID < CSV_MapEctype.MapID then	--当前打开的是已经通关了的老地图
			for nIndex = 1, #tbEctypeList do
				self.tbMapEctypeList[nMapCsvID][nIndex]:SetActivation(EctypeActivation._Activation)
			end
		end
	end

end

--内部函数 通过大地图ID 构造所在地图上的 副本数据
function Game_EctypeListSystem:InitEctypeInfo(nMapCsvID)
	cclog("================构造地图副本数据啊=============")
	if not nMapCsvID then return end
	
	if self.tbRewardBoxStatus == nil then self.tbRewardBoxStatus = {} end
	
	if self.tbRewardBoxStatus[nMapCsvID] == nil then
		self.tbRewardBoxStatus[nMapCsvID] = {}
		for nIndex = 1, 3 do
			self.tbRewardBoxStatus[nMapCsvID][nIndex] = false
		end
	end
	
	
	self.nCurrentMapCsvID = nMapCsvID
	
	if not self.tbRewardBoxID[nMapCsvID] then
		self.tbRewardBoxID[nMapCsvID] = {}
		self.tbRewardBoxID[nMapCsvID][EctypeBoxReward._Left] 	= self.nCurrentMapCsvID*10 + EctypeBoxReward._Left
		self.tbRewardBoxID[nMapCsvID][EctypeBoxReward._Middle] = self.nCurrentMapCsvID*10 + EctypeBoxReward._Middle
		self.tbRewardBoxID[nMapCsvID][EctypeBoxReward._Right] 	= self.nCurrentMapCsvID*10 + EctypeBoxReward._Right
	end
	
	if not self.tbMapEctypeList[nMapCsvID] then
		self.tbMapEctypeList[nMapCsvID] = {}
		--根据地图ID获取副本列表
		local tbEctypeList = g_DataMgr:getEctypeListByMapBaseID(nMapCsvID) or {}
		for k, v in ipairs(tbEctypeList)do
			local Obj_EctypeSub = EctypeSub.new()
			Obj_EctypeSub:SetEctypeBaseInfo(v, nil, 0)
			Obj_EctypeSub:initDropRewardItems()
			table.insert(self.tbMapEctypeList[nMapCsvID], Obj_EctypeSub)
		end
		self:InitEctypeActivateInfo(nMapCsvID)
	end
	
	if not self.tbRewardBoxDropList[nMapCsvID] then
		self.tbRewardBoxDropList[nMapCsvID] = {}
		--取标头就默认的取1的值 －－ CSV_MapStarReward.NeedStarRecord
		
		for nIndex = 1, 3 do
			self.tbRewardBoxDropList[nMapCsvID][nIndex] = {}
			local nRewardCsvID = self:GetRewardBoxID(self.nCurrentMapCsvID, nIndex)
			local CSV_MapStarReward = g_DataMgr:getCsvConfig_SecondKeyTableData("MapStarReward", nRewardCsvID)
			for nRewardIndex = 1, #CSV_MapStarReward do
				-- 创建角色的时候生成魂魄，防止引导数据没有，因此掉落包不会配魂魄奖励，但是客户端预览要有，作假
				if g_Hero:getMasterSex() == 1 then
					self.tbRewardBoxDropList[nMapCsvID][nIndex][nRewardIndex] = {
						DropItemType = CSV_MapStarReward[nRewardIndex].DropItemType,
						DropItemID = CSV_MapStarReward[nRewardIndex].DropItemID,
						DropItemStarLevel = CSV_MapStarReward[nRewardIndex].DropItemStarLevel,
						DropItemNum = CSV_MapStarReward[nRewardIndex].DropItemNum,
						--DropItemEvoluteLevel = CSV_MapStarReward[nRewardIndex].DropItemEvoluteLevel,
					}
				else
					self.tbRewardBoxDropList[nMapCsvID][nIndex][nRewardIndex] = {
						DropItemType = CSV_MapStarReward[nRewardIndex].DropItemType,
						DropItemID = CSV_MapStarReward[nRewardIndex].DropItemID_Female,
						DropItemStarLevel = CSV_MapStarReward[nRewardIndex].DropItemStarLevel,
						DropItemNum = CSV_MapStarReward[nRewardIndex].DropItemNum,
						--DropItemEvoluteLevel = CSV_MapStarReward[nRewardIndex].DropItemEvoluteLevel,
					}
				end
			end
		end
	end
end

------------------------------------网络消息处理--------------------------------------------

--[[ 						common
message EctypeStarInfo
{
	option (stFMsgOptions) = {bGenFixed : true };
	optional uint32 passed_id = 1;	// 关卡id
	optional uint32 attack_num = 2;	// 攻击次数
	optional uint32 star = 3;		// 星级  这个是难度等级（子副本索引） 小心被误导
	repeated uint32 star_num = 4;	//星星数	索引为 难度等级(子副本索引)
}
]]

--MSGID_MAP_POINT_INFO_RESPONSE = 130; MapPointInfoResponse()//某地图副本信息请求 因为一个网络ID职能绑定一个回调 这个就要在 这个响应里面处理
--[[
//副本信息响应
message MapPointInfoResponse
{
	optional uint32 big_passid = 1; //大关卡id   没意义，和客户端协调，能否删掉？
	repeated EctypeStarInfo ectype_star_info = 2; // 副本的星级信息
	optional uint32 dialog_opened_id = 3; // 对话id
}
]]
function Game_EctypeListSystem:SetMapEctypeInfo(tbMsg)
	local nFinalClearEctypeID = g_Hero:getFinalClearEctypeID()
	local CSV_MapEctype = g_DataMgr:getMapEctypeCsv(nFinalClearEctypeID)
	if tbMsg.big_passid <= CSV_MapEctype.MapID then
		self:InitEctypeInfo(tbMsg.big_passid)
		for k, v in ipairs(tbMsg.ectype_star_info)do
			local Obj_EctypeSub = self:GetEctypeSuyBySubID(self.nCurrentMapCsvID, v.passed_id)
			Obj_EctypeSub:SetEctypeBaseInfo(v.passed_id, v.star_num, v.attack_num)
		end
	end
end


--MSGID_ATTACK_SMALLPASS_RESPONSE = 132; AttackSmallPassResponse()//攻打某个副本响应 原因同上
--[[
//攻打某个副本响应
message AttackSmallPassResponse
{
	optional uint32 dialog_opened_id = 1;	// 已对话的最大关卡id 
	optional EctypeStarInfo ectype_star_info = 2; // 副本的星级信息
	optional uint32 remain_energy = 3;  
}
]]
function Game_EctypeListSystem:SetSingleEctypeInfo(tbMsg)

	local nEctypeCsvID = (tbMsg.ectype_star_info == 0 and 0) or tbMsg.ectype_star_info.passed_id
	local Obj_EctypeSub = self:GetEctypeSuyBySubID(self.nCurrentMapCsvID, nEctypeCsvID)
	if Obj_EctypeSub ~= nil then
		Obj_EctypeSub:SetEctypeBaseInfo(tbMsg.ectype_star_info.passed_id, tbMsg.ectype_star_info.star_num, tbMsg.ectype_star_info.attack_num)
	else
		cclog("Game_EctypeListSystem:SetSingleEctypeInfo")
	end
	self:InitEctypeActivateInfo(self.nCurrentMapCsvID)
end


--MSGID_MAP_STAR_REWARD_REQUEST = 720;			//地图星级宝箱领取请求	MapStarRewardReq
--[[
	message MapStarRewardReq
	{
	optional uint32 map_id = 1;
	optional uint32 box_idx = 2;  //宝箱索引，0开始
	}
]]
function Game_EctypeListSystem:RequestGetStarRewardBox(nMapCsvID, nIndex)
	local msg = zone_pb.MapStarRewardReq() 
	msg.map_id = nMapCsvID
	msg.box_idx = nIndex - 1
	
	g_MsgMgr:sendMsg(msgid_pb.MSGID_MAP_STAR_REWARD_REQUEST, msg)

	-- add by zgj
	self.nCurMapCsvID = nMapCsvID
	self.nCurIndex = nIndex

	g_MsgNetWorkWarning:showWarningText()

	g_ErrorMsg:ListenMsg(msgid_pb.MSGID_MAP_STAR_REWARD_REQUEST)
end

--MSGID_MAP_STAR_BOX_NOTIFY = 760;				//通知副本星星箱子状态 HaveGetMapStarBox 
--更新星级宝箱的数据
--[[
	// 领过的地图星星奖励箱子
	message HaveGetMapStarBox
	{
		option (stFMsgOptions) = {bGenFixed : true };
		optional uint32 map_id = 1; 
		repeated bool is_get = 2;  // true==is_get[0] 表示最低星星数箱子已领
	}
]]
function Game_EctypeListSystem:ClientRespondStarBox(buf)
	if buf.is_get ~= nil then
		for i=1, #buf.is_get do
			if self.tbRewardBoxStatus ~= nil then
				if self.tbRewardBoxStatus[self.nCurrentMapCsvID] == nil then
					self.tbRewardBoxStatus[self.nCurrentMapCsvID] = {}
					for nIndex = 1, 3 do
						self.tbRewardBoxStatus[self.nCurrentMapCsvID][nIndex] = false
					end
				end
				self.tbRewardBoxStatus[self.nCurrentMapCsvID][i] = buf.is_get[i]
			end
		end
	end

	g_FormMsgSystem:SendFormMsg(FormMsg_EctypeForm_UpdateEctypeStarNum, nil)
	g_MsgNetWorkWarning:closeNetWorkWarning()
end

function Game_EctypeListSystem:RespondUpdataStarRewardBox(tbMsg)
	local msgDetail = common_pb.HaveGetMapStarBox()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)

	if msgDetail.is_get ~= nil then
		for i=1, #msgDetail.is_get do
			if self.tbRewardBoxStatus ~= nil then
				if self.tbRewardBoxStatus[self.nCurrentMapCsvID] == nil then
					self.tbRewardBoxStatus[self.nCurrentMapCsvID] = {}
					for nIndex = 1, 3 do
						self.tbRewardBoxStatus[self.nCurrentMapCsvID][nIndex] = false
					end
				end
				self.tbRewardBoxStatus[self.nCurrentMapCsvID][i] = msgDetail.is_get[i]
			end
		end
	end


	g_FormMsgSystem:SendFormMsg(FormMsg_EctypeForm_UpdateEctypeStarNum, nil)
	
	g_MsgNetWorkWarning:closeNetWorkWarning()

	g_ErrorMsg:RelieveListenMsg(msgid_pb.MSGID_MAP_POINT_INFO_REQUEST, msgid_pb.MSGID_MAP_STAR_BOX_NOTIFY)

	g_ErrorMsg:RelieveListenMsg(msgid_pb.MSGID_MAP_STAR_REWARD_REQUEST, msgid_pb.MSGID_MAP_STAR_BOX_NOTIFY)

end

--MSGID_MAP_STAR_REWARD_RESPONSE = 721;			//地图星级宝箱领取响应	none
function Game_EctypeListSystem:RespondGetStarRewardBox(tbMsg)
	g_FormMsgSystem:SendFormMsg(FormMsg_EctypeForm_GetStarRewardBox_SUC, nil)
	
	if self.tbRewardBoxStatus ~= nil then
		if self.tbRewardBoxStatus[self.nCurMapCsvID] == nil then
			self.tbRewardBoxStatus[self.nCurMapCsvID] = {}
			for nIndex = 1, 3 do
				self.tbRewardBoxStatus[self.nCurMapCsvID][nIndex] = false
			end
		end
		self.tbRewardBoxStatus[self.nCurMapCsvID][self.nCurIndex] = RewardBoxStatus_CanObtainHasObtain	--可领取, 已领取
	end

	g_MsgNetWorkWarning:closeNetWorkWarning()

	g_ErrorMsg:RelieveListenMsg(msgid_pb.MSGID_MAP_STAR_REWARD_REQUEST, msgid_pb.MSGID_MAP_STAR_REWARD_RESPONSE)
end

function Game_EctypeListSystem:refreshAttackNum()
	g_Hero.tbEctypeStars = g_Hero.tbEctypeStars or {}
	for k,v in pairs(g_Hero.tbEctypeStars) do
		v.attack_num = 0
	end
end



-------------------------------------------------------------定义全局对象
g_EctypeListSystem = Game_EctypeListSystem.new()
g_EctypeListSystem:Init()