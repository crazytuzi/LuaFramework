--------------------------------------------------------------------------------------
-- 文件名:	VIPBase.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用: vip 
---------------------------------------------------------------------------------------
VIPBase = class("VIPBase")
VIPBase.__index = VIPBase
--[[
	保存服务器下发的vip等级
]]
local vipLevel_ = 0 	

local encryptid_ = 0
local pageId_ = 0
local pageIndex_ = 0

local vipLevelData_ = g_DataMgr:getCsvConfig("VipLevel") 
local tbVipInfo = {}

--vip购买操作类型  VipBuyOpType 客户端自己的定义 在使用
VipType =
{
	VipBuyOpType_TurnTableTimes = 0,				--转盘购买次数
	VipBuyOpType_TurnTableCD = 1,					--清除转盘CD
	VipBuyOpType_ArenaChallegeCD = 2,				--清除竞技场CD	
	VipBuyOpType_ArenaChallegeTimes = 3,			--竞技场次数
	VipBuyOpType_HuntJiangziyaTimes = 4,			--猎命姜子牙的购买次数
	VipBuyOpType_WorldBossGuwuTimes = 5,			--世界boss鼓舞购买次数
	VipBuyOpType_WorldBossDeadCD = 6,				--清除打世界boss死后的CD
	VipBuyOpType_WorldBossTimes = 7,				--购买世界boss额外次数
	VipBuyOpType_SceneBossDeadCD = 8,				--清除打场景bossCD
	VipBuyOpType_DragonPrayTimes = 9,				--购买神龙上供额外次数
    VipBuyOpType_RobTimes = 10;						--购买打劫额外次数

	VipBuyOpType_ActivityExpTimes = 11,				--活动 卧龙潭 购买次数
	VipBuyOpType_ActivityMoneyTimes = 12,			--活动 财神岛 购买次数
	VipBuyOpType_ActivityKnowledgeTimes = 13,		--活动 藏经阁 购买次数
	
	VipBuyOpType_BaxianRobCD = 14,					--八仙清楚cd元宝数
	VipBuyOpType_GuildWorldBossCD = 15,				--清除打guild world boss CD
	VipBuyOpType_GuildSceneBossCD = 16,				--清除打guild scene boss CD

	VipBuyOpType_BuyEnergy = 17,					--购买体力价格
	VipBuyOpType_DragonChangeCost = 18,				--神龙改运价格
	VipBuyOpType_FarmRefresh = 19,					--农场刷新价格
	VipBuyOpType_RefreshNpcCost = 20,				--八仙过海护送刷新价格
	
	VipBuyOpType_GanWuCnt = 21,						--感悟额外购买次数
	
	VipBuyOpType_CrossArenaChallegeCD = 22,			--清除跨服竞技场CD
	VipBuyOpType_CrossArenaChallegeTimes = 23,		--竞技跨服场次数
	
	VIP_TYPE_COMMON_ENCRYPT = 100, 					--普通副本次数购买
	VIP_TYPE_JY_ENCRYPT = 101, 						--精英副本购买次数

    VIP_TYPE_REFRESH_SECRETSHOP = 102,              --刷新神秘商店
}
--------------------VipLevel 表中的配置 字段 表里修改这里也需要修改，添加-------------------

--"G"活动副本 标识 卧龙潭 财神岛 藏经阁
local cvsCnt = {
	-- [11,12,13] = "ActivityEctypeCnt", --活动副本次数	
	["G"] = "ActivityEctypeCnt", 										--活动副本次数	
	[VipType.VIP_TYPE_JY_ENCRYPT] = "JingyingEctypeCnt", 				--精英副本次数	
	[VipType.VIP_TYPE_COMMON_ENCRYPT] = "NormalEctypeCnt", 				--普通副本次数	
	[VipType.VipBuyOpType_ArenaChallegeTimes] = "ArenaCnt", 			--竞技场次数	
	[VipType.VipBuyOpType_WorldBossTimes] = "WorldBossCnt", 			--WorldBoss额外次数	
	[VipType.VipBuyOpType_TurnTableTimes] = "TurnTableCnt", 			--转盘额外次数	
	[VipType.VipBuyOpType_HuntJiangziyaTimes] = "JzyhuntFateCnt", 		--召唤姜子牙次数
	[VipType.VipBuyOpType_DragonPrayTimes] = "DragonPrayExCnt", 		--神龙上供额外次数
    [VipType.VipBuyOpType_RobTimes] = "RobExCnt",						-- 购买打劫额外次数
    [VipType.VipBuyOpType_GanWuCnt] = "InspireExCnt",					-- 感悟额外购买次数
    [VipType.VipBuyOpType_CrossArenaChallegeTimes] = "ArenaKuaFuCnt",							-- 跨服天榜次数
    [VipType.VIP_TYPE_REFRESH_SECRETSHOP] = "SecretRefreshCnt",							-- 神秘商店刷新次数
}

--消耗元宝 
local cvsCntCostGold = {
	-- [11,12,13] = "ActivityEctypeCntCost", --活动副本次数元宝	
	["G"] = "ActivityEctypeCntCost", --活动副本次数元宝	
	[VipType.VIP_TYPE_JY_ENCRYPT] = "JingyignEctypeCntCost", --精英副本次数元宝	
	[VipType.VIP_TYPE_COMMON_ENCRYPT] = "NormalEctypeCntCost", --普通副本次数元宝	
	[VipType.VipBuyOpType_ArenaChallegeTimes] = "ArenaCntCost", --竞技场次数元宝	
	[VipType.VipBuyOpType_WorldBossTimes] = "WorldBossCntCost", --WorldBoss额外次数元宝	
	[VipType.VipBuyOpType_TurnTableTimes] = "TurnTableCntCost", --转盘额外次数元宝	
	[VipType.VipBuyOpType_HuntJiangziyaTimes] = "JzyHuntFateCost", --召唤姜子牙元宝
	[VipType.VipBuyOpType_DragonPrayTimes] = "DragonPrayExCost", --神龙上供额外次数元宝
    [VipType.VipBuyOpType_RobTimes] = "RobExCost",				-- 打劫次数元宝
    [VipType.VipBuyOpType_BaxianRobCD] = "RobCDCost",				-- 打劫清除元宝
	[VipType.VipBuyOpType_BuyEnergy] = "BuyEnergy";			--购买体力价格
	[VipType.VipBuyOpType_DragonChangeCost] = "DragonChangeCost";		--神龙改运价格
	[VipType.VipBuyOpType_FarmRefresh] = "FarmRefresh";			--农场刷新价格
	[VipType.VipBuyOpType_RefreshNpcCost] = "RefreshNpcCost";		--	八仙过海护送刷新价格
	[VipType.VipBuyOpType_GanWuCnt] = "GanWuExCost",				-- 感悟额外价格
	[VipType.VipBuyOpType_CrossArenaChallegeTimes] = "ArenaKuaFuCntCost",				-- 跨服天榜购买价格
}

local cvsCD = {
	[VipType.VipBuyOpType_ArenaChallegeTimes] = "ArenaCD", --竞技场CD秒	
	[VipType.VipBuyOpType_WorldBossDeadCD] = "WorldBossCD", --WorldBoss CD秒
	[VipType.VipBuyOpType_SceneBossDeadCD] = "SceneBossCD", --WorldBoss2 CD秒	
	[VipType.VipBuyOpType_TurnTableCD] = "TurnTableCD", --转盘CD秒	
	[VipType.VipBuyOpType_CrossArenaChallegeCD] = "ArenaKuaCD",						--跨服天榜CD秒
}
local cvsCDGold = {
	[VipType.VipBuyOpType_ArenaChallegeTimes] = "ArenaCDCost", --竞技场CD元宝	
	[VipType.VipBuyOpType_WorldBossDeadCD] = "WorldBossCDCost", --WorldBossCd元宝
	[VipType.VipBuyOpType_SceneBossDeadCD] = "SceneBossCDCost", --WorldBoss2 CD秒	
	[VipType.VipBuyOpType_TurnTableCD] = "TurnTableCDCost", --清转盘CD元宝
	[VipType.VipBuyOpType_CrossArenaChallegeCD] = "ArenaKuaCDCost",						--跨服天榜CD元宝
}
-------------------------------------------
-------------------^^^--------配置表数据-^^^^^-------------------
function VIPBase:setVipLevel(nLevel)
	vipLevel_ = nLevel
end

function VIPBase:getCvsVipLevel()
	return vipLevel_ + 1
end

function VIPBase:getVIPLevelId()
	local vLevel = self:getCvsVipLevel()
	return vipLevelData_[vLevel].Id
end
-- 
function VIPBase:getVipLevelData(types)
	local vipLevel = self:getCvsVipLevel() 
	return vipLevelData_[vipLevel][types]
end
--获取Vip 配置数据
function VIPBase:getVipValue(types)
	local data = self:getVipLevelData(types)
	return data
end

--获取Vip 总次数
function VIPBase:getVipMaxTimes(nAssistantCsvId)
	local vipLevel = self:getCvsVipLevel()
	local nNum = g_DataMgr:getCsvConfigByOneKey("ActivityAssistant", nAssistantCsvId).EventMaxNum
	if nAssistantCsvId == common_pb.AssistantType_ZhaoCaiShenFu then 
		return vipLevelData_[vipLevel]["ZhaoCaiMaxNum"]
    elseif nAssistantCsvId == common_pb.AssistantType_AmBoss then 
    	return nNum + self:getAddTableByNum(VipType.VipBuyOpType_WorldBossTimes)
    elseif nAssistantCsvId == common_pb.AssistantType_ArenaCnt then 
    	return nNum + self:getAddTableByNum(VipType.VipBuyOpType_ArenaChallegeTimes)
    elseif nAssistantCsvId == common_pb.AssistantType_TurnTable then 
    	return nNum + self:getAddTableByNum(VipType.VipBuyOpType_TurnTableTimes)
    elseif nAssistantCsvId == common_pb.AssistantType_CaiShenDao then 
    	return nNum + self:getAddTableByNum(VipType.VipBuyOpType_ActivityMoneyTimes)
    elseif nAssistantCsvId == common_pb.AssistantType_CangJinGe then 
    	return nNum + self:getAddTableByNum(VipType.VipBuyOpType_ActivityKnowledgeTimes)
    elseif nAssistantCsvId == common_pb.AssistantType_WoLongTan then 
    	return nNum + self:getAddTableByNum(VipType.VipBuyOpType_ActivityExpTimes)
    elseif nAssistantCsvId == common_pb.AssistantType_BuyEnergy then 
    	return vipLevelData_[vipLevel]["BuyMaxNum"]
    elseif nAssistantCsvId == common_pb.AssistantType_BuyArenaTimes then 
    	return vipLevelData_[vipLevel]["ArenaCnt"]
    elseif nAssistantCsvId == common_pb.AssistantType_BaiXianRob then 
    	return nNum + self:getAddTableByNum(VipType.VipBuyOpType_RobTimes)
    elseif nAssistantCsvId == common_pb.AssistantType_DragonPray then 
    	return nNum + self:getAddTableByNum(VipType.VipBuyOpType_DragonPrayTimes)
    elseif nAssistantCsvId == common_pb.AssistantType_YaoYuanZhongZhi then
		return math.max(g_GetOpenFarmNum(), getFarmNums(g_Hero:getMasterCardLevel()))
	elseif nAssistantCsvId == common_pb.AssistantType_HurtFateJZY then 
    	return vipLevelData_[vipLevel]["JzyhuntFateCnt"]
    else
    	return nNum
    end
end

		
function VIPBase:getActivitiesType(types)		
	if types == VipType.VipBuyOpType_ActivityExpTimes 	
		or types == VipType.VipBuyOpType_ActivityMoneyTimes 
		or types == VipType.VipBuyOpType_ActivityKnowledgeTimes then 
		return "G"
	end	
	return types	
end		

--购买的次数
function VIPBase:getVipLevelCntNum(types)
	local vipLevel = self:getCvsVipLevel() 
	local key = self:getActivitiesType(types)
	if not cvsCnt and not cvsCnt[key] then return 0 end 
	local typeName = cvsCnt[key]
	return vipLevelData_[vipLevel][""..typeName..""]
end

--购买的次数消耗的元宝
function VIPBase:getVipLevelCntGold(types)

	local key = self:getActivitiesType(types)
	
	if not cvsCntCostGold and not cvsCntCostGold[key] then return 0 end 
	local typeName = cvsCntCostGold[key]
	
	local index = self:getAddTableByNum(types) + 1
	echoj("=======第"..index.."次消耗元宝购买================", typeName)
	return g_ChargeIncreaseBase:getChargeIncreasePrice(index, typeName) 
end

--冷却CD
function VIPBase:getVipLevelCD(types)
	--处理帮派BOSS
	if types == VipType.VipBuyOpType_GuildWorldBossCD then
		types = VipType.VipBuyOpType_WorldBossDeadCD
	elseif types == VipType.VipBuyOpType_GuildSceneBossCD then
		types = VipType.VipBuyOpType_SceneBossDeadCD
	end
	local vipLevel = self:getCvsVipLevel() 
	if not cvsCD and not cvsCD[types] then return 0 end 
	local typeName = cvsCD[types]
	return vipLevelData_[vipLevel][typeName]
end

--冷却CD消耗的元宝
function VIPBase:getVipLevelCDGold(types)
	--处理帮派BOSS
	if types == VipType.VipBuyOpType_GuildWorldBossCD then
		types = VipType.VipBuyOpType_WorldBossDeadCD
	elseif types == VipType.VipBuyOpType_GuildSceneBossCD then
		types = VipType.VipBuyOpType_SceneBossDeadCD
	end
	local vipLevel = self:getCvsVipLevel() 
	if not cvsCDGold and not cvsCDGold[types] then 
		cclog("cvsCDGold 属性名为空")
		return 0 
	end 
	local typeName = cvsCDGold[types]
	return vipLevelData_[vipLevel][typeName]
end


--------------------------------------------------
--登录的时候保存的数据
function VIPBase:setVipData(tbMsg)
	if not tbMsg then return end 
	cclog(tostring(tbMsg).."VIP信息")	
	tbVipInfo[VipType.VipBuyOpType_TurnTableTimes] =tbMsg.turn_table_times--转盘购买次数
	tbVipInfo[VipType.VipBuyOpType_WorldBossGuwuTimes] = tbMsg.gu_wu_times--鼓舞次数购买
	tbVipInfo[VipType.VipBuyOpType_ArenaChallegeTimes] = tbMsg.arena_times--竞技场购买次数
	tbVipInfo[VipType.VipBuyOpType_HuntJiangziyaTimes] = tbMsg.hunt_jiangziya_times--猎命姜子牙的购买次数
	tbVipInfo[VipType.VipBuyOpType_WorldBossTimes] = tbMsg.world_boss_times--世界boss购买次数
	tbVipInfo[VipType.VipBuyOpType_DragonPrayTimes] = tbMsg.dragon_pray_times--神龙上供购买次数
	tbVipInfo[VipType.VipBuyOpType_ActivityExpTimes] = tbMsg.activity_exp_times-- 卧龙潭 经验
	
	tbVipInfo[VipType.VipBuyOpType_ActivityMoneyTimes] = tbMsg.activity_money_times--财神岛 铜钱
	tbVipInfo[VipType.VipBuyOpType_ActivityKnowledgeTimes] = tbMsg.activity_Knowledge_times--藏经阁 阅历
    tbVipInfo[VipType.VipBuyOpType_RobTimes] = tbMsg.rob_times--八仙打劫次
    tbVipInfo[VipType.VIP_TYPE_REFRESH_SECRETSHOP] = tbMsg.shop_refresh_times--神秘商店刷新次数
	-- 普通副本次数购买
	tbVipInfo[VipType.VIP_TYPE_COMMON_ENCRYPT] = {}
	local commonEncrypt = tbMsg.common_encrypt
	for i = 1, #commonEncrypt do
		local t = {}
		t.times = commonEncrypt[i].times
		t.encryptid = commonEncrypt[i].encryptid
		table.insert(tbVipInfo[VipType.VIP_TYPE_COMMON_ENCRYPT],t)
	end

	--精英副本购买次数
	tbVipInfo[VipType.VIP_TYPE_JY_ENCRYPT] = {}
	local jingyingEncrypt = tbMsg.jingying_encrypt 
	for i = 1, #jingyingEncrypt do
		local t = {}
		t.times = jingyingEncrypt[i].times
		t.page_id = jingyingEncrypt[i].pageId
		t.page_index = jingyingEncrypt[i].pageIndex
		table.insert(tbVipInfo[VipType.VIP_TYPE_JY_ENCRYPT],t)
	end

	tbVipInfo[VipType.VipBuyOpType_DragonChangeCost] = tbMsg.dragon_change_times --神龙改运
	tbVipInfo[VipType.VipBuyOpType_RefreshNpcCost] = tbMsg.refresh_npc_times --八仙过海护送刷新

	-- 农场刷新次数
	tbVipInfo[VipType.VipBuyOpType_FarmRefresh] = {}
	local farmTimes = tbMsg.farm_times
	for i = 1, #farmTimes do
		local t = {}
		t.times = farmTimes[i].times
		t.farm_idx = farmTimes[i].farm_idx
		table.insert(tbVipInfo[VipType.VipBuyOpType_FarmRefresh],t)
	end

	tbVipInfo[VipType.VipBuyOpType_GanWuCnt] = tbMsg.ganwu_times --神灵感悟购买次数
		
	tbVipInfo[VipType.VipBuyOpType_CrossArenaChallegeTimes] = tbMsg.cross_arena_times --跨服挑战次数购买
	
end

--普通副本次数购买
--@param encryptid 副本ID
--@param times 今天累计购买的次数
function VIPBase:setCommonEncryptByNum(encryptid,times)
	local commonEncrypt = tbVipInfo[VipType.VIP_TYPE_COMMON_ENCRYPT]
	for i = 1,#commonEncrypt do 
		if commonEncrypt[i].encryptid == encryptid then 
			tbVipInfo[VipType.VIP_TYPE_COMMON_ENCRYPT][i].times = times
			return 
		end
	end
	local t = {}
	t.times = times
	t.encryptid = encryptid
	table.insert(tbVipInfo[VipType.VIP_TYPE_COMMON_ENCRYPT],t)
end

function VIPBase:getCommonEncryptByNum(encryptid)
	local commonEncrypt = tbVipInfo[VipType.VIP_TYPE_COMMON_ENCRYPT]
	if not commonEncrypt and type(commonEncrypt) ~= "table" then  return 0 end
	for i = 1,#commonEncrypt do 
		if commonEncrypt[i].encryptid == encryptid then 
			return commonEncrypt[i].times 
		end
	end
	return 0
end

-- 精英副本购买次数
-- @param pageId --精英副本页号
-- @param pageIndex -- 在页中的位置编号
-- @param times --今天累计购买的次数
function VIPBase:setJYEncryptByNum(pageId,pageIndex,times)
	local jingyingEncrypt = tbVipInfo[VipType.VIP_TYPE_JY_ENCRYPT]
	for i = 1,#jingyingEncrypt do
		if jingyingEncrypt[i].page_id == pageId and jingyingEncrypt[i].page_index == pageIndex then 
			tbVipInfo[VipType.VIP_TYPE_JY_ENCRYPT][i].times = times
			return 
		end
	end	
	
	local t = {}
	t.times = times
	t.page_id = pageId
	t.page_index = pageIndex
	table.insert(tbVipInfo[VipType.VIP_TYPE_JY_ENCRYPT],t)
end

function VIPBase:getJYEncryptByNum(pageId,pageIndex)
	local jingyingEncrypt = tbVipInfo[VipType.VIP_TYPE_JY_ENCRYPT]
	for i = 1,#jingyingEncrypt do
		if jingyingEncrypt[i].page_id == pageId 
			and jingyingEncrypt[i].page_index == pageIndex then 
			return jingyingEncrypt[i].times 
		end
	end	
	return 0
end

--农田刷新奖励次数（需消耗元宝）农场田索引 收获前累计刷新次数
function VIPBase:setFarmAwardUpdateIdxTimes(farmIdx, times)
	local farmAwardUpdate = tbVipInfo[VipType.VipBuyOpType_FarmRefresh]	
	for i = 1,#farmAwardUpdate do
		if farmAwardUpdate[i].farm_idx == farmIdx then 
			tbVipInfo[VipType.VipBuyOpType_FarmRefresh][i].times = times
			return 
		end
	end	
	local t = {}
	t.times = times
	t.farm_idx = farmIdx
	table.insert(tbVipInfo[VipType.VipBuyOpType_FarmRefresh],t)
end

function VIPBase:getFarmAwardUpdateIdxTimes(farmIdx)
	local farmAwardUpdate = tbVipInfo[VipType.VipBuyOpType_FarmRefresh]
	for i = 1,#farmAwardUpdate do
		if farmAwardUpdate[i].farm_idx == farmIdx then 
			return farmAwardUpdate[i].times 
		end
	end	
	return 0
end

function VIPBase:getcurFarmIdx()
	return self.curFarmIdx_ or 1
end

function VIPBase:setcurFarmIdx(farmIdx)
	self.curFarmIdx_ = farmIdx
end

--增加的次数，上限 
-- @param return 0 暂定为 清除冷却时间
-- @param return nil type 没有定义 
function VIPBase:getAddTableByNum(types)	

	if tonumber(types) == VipType.VIP_TYPE_COMMON_ENCRYPT then  -- 普通副本次数购买
		local id = self:getCommonEncryptId()
		return self:getCommonEncryptByNum(id)
		
	elseif tonumber(types) == VipType.VIP_TYPE_JY_ENCRYPT then --精英副本购买次数	
		
		local pageId, index = self:getJYPageIdPageIndex()
		return self:getJYEncryptByNum(pageId,index)
		
	elseif tonumber(types) == VipType.VipBuyOpType_FarmRefresh then --农场刷新次数
		local farmIdx = self:getcurFarmIdx()
		return self:getFarmAwardUpdateIdxTimes(farmIdx)
		
	else
		if not tbVipInfo[types] then  return 0 end
		return tbVipInfo[types]
	end
	
end

--更新 当前增加的次数上限 不包括 普通副本 和精英副本
function VIPBase:setAddTableByNum(types,nNum)
	if  tonumber(types) == VipType.VIP_TYPE_COMMON_ENCRYPT 
		or tonumber(types) == VipType.VIP_TYPE_JY_ENCRYPT 
		or tonumber(types) == VipType.VipBuyOpType_FarmRefresh then  
	else
		tbVipInfo[types] = nNum
	end	
end

--------------------------------以下是 协议-----------

-- 购买次数，清除CD请求
function VIPBase:requestVipBuyTimesRequest(buyType)
	local msg = zone_pb.VipBuyTimesRequest()
	msg.buy_type = buyType
	g_MsgMgr:sendMsg(msgid_pb.MSGID_VIP_BUY_REQUEST, msg)
end

-- 购买次数，清除CD响应
function VIPBase:requestVipBuyTimesResponse(tbMsg)
	cclog("---------requestVipBuyTimesResponse--- 购买次数，清除CD响应----------")
	local msgDetail = zone_pb.VipBuyTimesResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	local buyType = msgDetail.buy_type 		--请求的类型，原样返回给客户端
	local buyTimes = msgDetail.buy_times 	--今天已经购买成功的次数
	local cdTimeat = msgDetail.cd_timeat 	--剩余的CD时间点
	local updateGold = msgDetail.update_gold 	--剩余的元宝
		
	self:setAddTableByNum(buyType, buyTimes)
	g_Hero:setYuanBao(updateGold)
	
	if self.responseVipFunc then 
		self.responseVipFunc(buyTimes)
		self.responseVipFunc = nil
	end
end

--普通副本使用
function VIPBase:setCommonEncryptid(encryptid)
	encryptid_ = encryptid
end
function VIPBase:getCommonEncryptId()
	return encryptid_
end

-- 普通副本的够买请求
function VIPBase:requestCommonEncryptBuyRequest(encryptid)
	cclog("普通副本的够买请求")
	local msg = zone_pb.CommonEncryptBuyRequest()
	msg.encryptid = encryptid;	--普通副本ID
	g_MsgMgr:sendMsg(msgid_pb.MSGID_VIP_BUY_COMMON_ENCRYPT_REQUEST, msg)

end

-- 普通副本的够买响应
function VIPBase:requestCommonEncryptBuyResponse(tbMsg)
	cclog("---------requestCommonEncryptBuyResponse--- 普通副本的够买响应----------")
	local msgDetail = zone_pb.CommonEncryptBuyResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)	
	local encryptid = msgDetail.encryptid -- 普通副本ID
	local times = msgDetail.times --此副本的今天的购买次数
	local upGold = msgDetail.update_gold --剩余的元宝
	
	self:setCommonEncryptByNum(encryptid,times)
	g_Hero:setYuanBao(upGold)
	
	if self.responseVipFunc then 
		self.responseVipFunc(times)
		self.responseVipFunc = nil
	end
end


--精英副本使用 
function VIPBase:setJYPageIdPageIndex(pageId,pageIndex) 
	pageId_ = pageId
	pageIndex_ = pageIndex
end

function VIPBase:getJYPageIdPageIndex()
	return pageId_,pageIndex_
end

-- 精英副本的够买请求 
function VIPBase:requestJingYingEncryptBuyRequest(pageId,pageIndex)
	local msg = zone_pb.JingYingEncryptBuyRequest()
	msg.page_id = pageId--精英副本页号
	msg.page_index = pageIndex--在页中的位置编号
	g_MsgMgr:sendMsg(msgid_pb.MSGID_VIP_BUY_JINGYING_ENCRYPT_REQUEST, msg)
end

-- 精英副本的够买响应
function VIPBase:requestJingYingEncryptBuyResponse(tbMsg)
	cclog("---------requestJingYingEncryptBuyResponse--- 精英副本的够买响应----------")
	local msgDetail = zone_pb.JingYingEncryptBuyResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)	
	local pageId = msgDetail.page_id --精英副本页号
	local pageIndex = msgDetail.page_index --在页中的位置编号
	local times = msgDetail.times -- 此副本的今天的购买次数
	local upGold = msgDetail.update_gold -- 剩余的元宝
	
	self:setJYEncryptByNum(pageId, pageIndex, times)
	g_Hero:setYuanBao(upGold)
	
	if self.responseVipFunc then 
		self.responseVipFunc(times)
		self.responseVipFunc = nil
	end
end

---------------------以上 协议----------------
function VIPBase:init()
	-- 购买次数，清除CD请求
	local order = msgid_pb.MSGID_VIP_BUY_RESPONSE	
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestVipBuyTimesResponse))	
	
	-- 普通副本的够买响应
	local order = msgid_pb.MSGID_VIP_BUY_COMMON_ENCRYPT_RESPONSE	
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestCommonEncryptBuyResponse))
	
	-- 精英副本的够买响应
	local order = msgid_pb.MSGID_VIP_BUY_JINGYING_ENCRYPT_RESPONSE	
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestJingYingEncryptBuyResponse))
	
	self.responseVipFunc = nil
	self.curFarmIdx_ = 1
end
---------------------------------------
--[[
	调用在 协议请求前
	return 在协议返回后 执行函数 f 带参数 今天的购买次数
]]
function VIPBase:responseFunc(vipUpdataFunc)
	self.responseVipFunc = vipUpdataFunc
end



g_VIPBase= VIPBase.new()
g_VIPBase:init()