--------------------------------------------------------------------------------------
-- 文件名:	WB_UI_BaXianGuoHai.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	八仙过海系统逻辑
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------

----------------Npc简要信息类------------------------
BXGH_NpcInfo_brief = class("BXGH_NpcInfo_brief")
BXGH_NpcInfo_brief.__index = BXGH_NpcInfo_brief

function BXGH_NpcInfo_brief:ctor()
    self.playerID = 0           -- 玩家ID  
    self.NpcID = 0              -- NpcID
    self.RemainTime = 0         -- 已护送时间  
    self.Total_Time = 0         -- 护送总时间
    self.bEnemyFlag = 0         -- 师傅是仇人

    --消除定时器误差，所以存储起始时间
    self.startTime, self.endTime = 0,0
end 
----------------Npc详细信息类------------------------
BXGH_NpcInfo_detailed = class("BXGH_NpcInfo_detailed")
BXGH_NpcInfo_detailed.__index = BXGH_NpcInfo_detailed

function BXGH_NpcInfo_detailed:ctor()
    self.playerID = 0           -- 玩家ID  
    self.PlayerName = ""        -- 玩家名字  
    self.PlayerLv = 0           --玩家等级
    self.PlayerBreakLv = 0      -- 玩家突破等级 
    self.PlayerStarLv = 0       -- 玩家星级  

    self.NpcID = 0              -- NpcID  
    self.NpcLv = 0              -- Npc级别
    self.OnlyBeRobTimes = 0     -- 剩余被打劫打劫次数  
    self.RobMoney = 0           -- 打劫可获得铜钱数量  
    self.RobPrestige = 0        -- 打劫可获得声望数量  
    self.RemainTime = 0         -- 已护送时间  
    self.Total_Time = 0         -- 护送总时间
    self.bEnemyFlag = 0         -- 师傅是仇人 0不是，1是

    --消除定时器误差，所以存储起始时间
    self.startTime, self.endTime = 0,0
end


----------------八仙过海系统------------------------
Class_BaXianGuoHaiSystem = class("Class_BaXianGuoHaiSystem")
Class_BaXianGuoHaiSystem.__index = Class_BaXianGuoHaiSystem

function Class_BaXianGuoHaiSystem:ctor()

    --八仙过海系统状态定义
    self.enumState = 
    {
        BXGH_NONE = 1, -- 空闲状态
        BXGH_HS   = 2  -- 护送状态
    }

    self.State = self.enumState.BXGH_NONE -- 当前护送状态
    self.MAX_RobTimes = 4 -- 每日最多打劫次数
    self.MAX_EscortTimes = 4 -- 每日最多护送次数
    self.BuyRobTimes = 0 -- 打劫已购买次数

    self.RobTimes = 0 -- 可打劫次数
    self.EscortTimes = 0 --可护送次数
    self.RemainTime = 0 -- 已护送时间  
    self.Total_Time = 0 --护送总时间

    --消除定时器误差，所以存储起始时间
    self.startTime, self.endTime = 0,0

    self.NpcListEnemy = {} --仇人列表
    self.NpcListbrief ={} --护送npc列表(简要信息)
    self.NpcListdetailed ={} --护送npc列表(详细信息，动态从服务器下载)
    -- 我的8个npc的等级和护送界面显示状态
    self.MyNpcAryLv = {[1]={lv = 1, bShow = 1, lvExp = 0},
                        [2]={lv = 1, bShow = 1, lvExp = 0},
                        [3]={lv = 1, bShow = 1, lvExp = 0},
                        [4]={lv = 1, bShow = 1, lvExp = 0},
                        [5]={lv = 1, bShow = 1, lvExp = 0},
                        [6]={lv = 1, bShow = 1, lvExp = 0},
                        [7]={lv = 1, bShow = 1, lvExp = 0},
                        [8]={lv = 1, bShow = 1, lvExp = 0}} 

    -- 当前Npc刷信息
    self.RefreshNpcInfo = {
        curNpcId = 0,    --当前刷新的npcid
        RemainFreeRefresh = 1 --剩余的免费帅新次数
    }

    --当前八仙过海的阵容
    self.BXGH_BuZhen = {	
        zhen_fa_id = 1,		-- 阵型ID
	    card_list = {}      -- 上阵卡牌的格子信息，（ZhenXinInfo_Cell）
    }

    --缓存打劫胜利的奖励，等胜利界面结束后显示
    self.WinAward = {gain_gold = 0,  gain_prestige= 0}

    --打劫失败后的冷却cd相关
    self.DaJieCD = 0 --打劫cd解除时间，，0为当前可以打劫

    self.bFirstShow = true--是否第一次打开界面
end

--收到玩家基础信息的时候调用
function Class_BaXianGuoHaiSystem:Init(baxian_info)
    cclog(tostring(baxian_info).."护送信息")
    self:ResponseBaXianSelfInfo(baxian_info)
    self.timerID = g_Timer:pushLoopTimer(1, handler(self, self.OnTimer))
    self.BuyRobTimes = g_VIPBase:getAddTableByNum(VipType.VipBuyOpType_RobTimes) -- 打劫已购买次数

end

--从新计算大家的剩余护送时间(清楚定时器误差)
function Class_BaXianGuoHaiSystem:ResetRemainTime()
    --重新计算自己的剩余时间
    if self.State == self.enumState.BXGH_HS then
        self.RemainTime = g_GetServerTime() - self.startTime          -- 已护送时间 
    end

    --重新计算网格npc
    for k, v in pairs(self.NpcListbrief) do
        v.RemainTime = g_GetServerTime() - v.startTime 
    end

    --重新计算npc详细信息剩余时间
    for k, v in pairs(self.NpcListdetailed) do
        v.RemainTime = g_GetServerTime() - v.startTime
    end    
end

function Class_BaXianGuoHaiSystem:OnTimer()

    --更新自己的剩余时间
    if self.State == self.enumState.BXGH_HS then
        self.RemainTime = self.RemainTime + 1
        if self.RemainTime > self.Total_Time then -- 护送结束
            self:ResponseSelfConvoyEnd(nil)
        end
    end
    --更新网格npc
    local endTable = {}
    for k, v in pairs(self.NpcListbrief) do
        v.RemainTime = v.RemainTime + 1
        if v.RemainTime > v.Total_Time then -- 护送结束
            table.insert(endTable, v.playerID)
        end
    end
    self:ResponseOtherConvoyEnd(endTable)


    --更新npc详细信息剩余时间
    for k, v in pairs(self.NpcListdetailed) do
        v.RemainTime = v.RemainTime + 1
        if v.RemainTime > v.RemainTime then
            v.RemainTime = v.Total_Time
        end
    end
end

--从网络协议的BaXianSingleRobElem中初始化BXGH_NpcInfo_detailed    (就是赋值函数)
function Class_BaXianGuoHaiSystem:GetNpcInfodetailed( SingleRobElem )
    local NpcInfo_detailed = BXGH_NpcInfo_detailed.new()

    NpcInfo_detailed.playerID = SingleRobElem.convoy_info.convoy_uin          -- 玩家ID  
    NpcInfo_detailed.PlayerName = SingleRobElem.convoy_info.name         -- 玩家名字  
    NpcInfo_detailed.PlayerLv = SingleRobElem.convoy_info.level            --玩家等级
    NpcInfo_detailed.PlayerBreakLv = SingleRobElem.convoy_info.breach_level       -- 玩家突破等级 
    NpcInfo_detailed.PlayerStarLv = SingleRobElem.convoy_info.star_level        -- 玩家星级  
    NpcInfo_detailed.NpcID = SingleRobElem.convoy_info.convoy_info.npc_id             -- NpcID  
    NpcInfo_detailed.OnlyBeRobTimes = self.MAX_RobTimes - SingleRobElem.convoy_info.convoy_info.robed_times      -- 剩余被打劫打劫次数  

    local tbCsvlv = g_DataMgr:getBXGH_NpcLvCsv(NpcInfo_detailed.NpcID,SingleRobElem.convoy_info.convoy_info.npc_level)
    local CoinsTotal = tbCsvlv.CoinsRewardBase + tbCsvlv.CoinsRewardGrow*(SingleRobElem.convoy_info.level-1)
    NpcInfo_detailed.RobMoney =  math.ceil(CoinsTotal*1250/10000)-1          -- 打劫可获得铜钱数量  

    NpcInfo_detailed.RobPrestige = math.ceil(tbCsvlv.PrestigeReward*1250/10000)-1           -- 打劫可获得声望数量  
    NpcInfo_detailed.RemainTime = g_GetServerTime() - SingleRobElem.convoy_info.convoy_info.start_time          -- 已护送时间 
    NpcInfo_detailed.Total_Time =  SingleRobElem.convoy_info.convoy_info.end_time - SingleRobElem.convoy_info.convoy_info.start_time        -- 护送总时间
    NpcInfo_detailed.startTime = SingleRobElem.convoy_info.convoy_info.start_time
    NpcInfo_detailed.endTime = SingleRobElem.convoy_info.convoy_info.end_time

    if SingleRobElem.enemy then  NpcInfo_detailed.bEnemyFlag =1 else NpcInfo_detailed.bEnemyFlag = 0 end

    return NpcInfo_detailed
end

------------------------------------------------------------------------------------
--数据接口
------------------------------------------------------------------------------------
function Class_BaXianGuoHaiSystem:GetActivityBaXianNpc(nNpcId)
   return g_DataMgr:getBXGH_NpcLvCsv(nNpcId, self.MyNpcAryLv[nNpcId].lv)
end

function Class_BaXianGuoHaiSystem:GetRefreshNPCLevel(nNpcId)
   return self.MyNpcAryLv[nNpcId].lv
end

function Class_BaXianGuoHaiSystem:GetRefreshNPCCurLevelExp(nNpcId)
	local CSV_ActivityBaXianNpcLast = g_DataMgr:getBXGH_NpcLvCsv(nNpcId, self.MyNpcAryLv[nNpcId].lv-1)
	return g_BaXianGuoHaiSystem.MyNpcAryLv[nNpcId].lvExp - CSV_ActivityBaXianNpcLast.TotalExpMax
end

function Class_BaXianGuoHaiSystem:GetRefreshNPCCurLevelExpMax(nNpcId)
	local CSV_ActivityBaXianNpc = g_DataMgr:getBXGH_NpcLvCsv(nNpcId, self.MyNpcAryLv[nNpcId].lv)
	local CSV_ActivityBaXianNpcLast = g_DataMgr:getBXGH_NpcLvCsv(nNpcId, self.MyNpcAryLv[nNpcId].lv-1)
	return CSV_ActivityBaXianNpc.TotalExpMax - CSV_ActivityBaXianNpcLast.TotalExpMax
end

function Class_BaXianGuoHaiSystem:GetRefreshNPCRewardAndTime(nNpcId)
	--神像增益
	local nGodLevel = g_BaXianPary:getGodLevel()
	local CSV_ActivityBaXianLevel = g_DataMgr:getCsvConfigByOneKey("ActivityBaXianLevel", nGodLevel)
	local nIncenseOptionIndex = g_BaXianPary:getBaXianlogType()

	local nIncenseOptionReward = 0
	if nIncenseOptionIndex > 0 then
		nIncenseOptionReward = CSV_ActivityBaXianLevel["IncenseOption"..nIncenseOptionIndex.."_Reward"]
	end
	
	--计算奖励和护送时间
	local CSV_ActivityBaXianNpc = g_DataMgr:getBXGH_NpcLvCsv(nNpcId, self.MyNpcAryLv[nNpcId].lv)
	local nCoinsReward = (CSV_ActivityBaXianNpc.CoinsRewardBase + CSV_ActivityBaXianNpc.CoinsRewardGrow*(g_Hero:getMasterCardLevel()-1))*(1+nIncenseOptionReward/10000)
	local nPrestigeReward = math.ceil( CSV_ActivityBaXianNpc.PrestigeReward*(1+nIncenseOptionReward/10000) )
	local nConvoyTime = CSV_ActivityBaXianNpc.ConvoyTime
	
	if nIncenseOptionIndex > 0 then
		nConvoyTime = CSV_ActivityBaXianLevel["IncenseOption"..nIncenseOptionIndex.."_ConvoyTime"]
	end
	
	return nCoinsReward, nPrestigeReward, nConvoyTime
end

function Class_BaXianGuoHaiSystem:GetDaJieCD()
    if self.DaJieCD == 0 then return 0 end

    local ret = self.DaJieCD - g_GetServerTime()
    if ret <= 0 then
        self.DaJieCD = 0
    end

    return ret
end

------------------------------------------------------------------------------------
--网络消息请求函数
------------------------------------------------------------------------------------
--请求打劫玩家
function Class_BaXianGuoHaiSystem:RequestBaXianStartRob(playerID)
    if self.RobTimes ==0 then
        g_ShowSysTips({text=_T("今日挑战次数已经用完，请购买！")})
        return
    end
    
    local msg = zone_pb.BaXianStartRobRequest()
    msg.to_rob_uin = playerID
	g_MsgNetWorkWarning:showWarningText()
    g_MsgMgr:sendMsg(msgid_pb.MSGID_BAXIAN_START_ROB_REQUEST,msg)
end


--请求所有护送玩家的简要信息，打开八仙过海界面时调用
function Class_BaXianGuoHaiSystem:InitOnOpenWnd()

    g_MsgNetWorkWarning:showWarningText(true)

    for k,v in pairs(self.MyNpcAryLv)do
        v.bShow = 1
    end

    if self.bFirstShow then    
        --g_MsgMgr:sendMsg(msgid_pb.MSGID_BAXIAN_SELF_INFO_REQUEST)
    end

    g_MsgMgr:sendMsg(msgid_pb.MSGID_BAXIAN_VIEW_BRIEF_LIST_REQUEST)
end

--请求Npc详细信息
function Class_BaXianGuoHaiSystem:ReqNpcInfo(nPlayerID)

    g_MsgNetWorkWarning:showWarningText(true)

    local msg = zone_pb.BaXianConvoyNpcDetailRequest()
    msg.convoy_uin = nPlayerID
    g_MsgMgr:sendMsg(msgid_pb.MSGID_BAXIAN_VIEW_CONVOY_DETAIL_REQUEST,msg)
end

--请求Npc打劫列表
function Class_BaXianGuoHaiSystem:ReqNpcInfoList(bclear)
    g_MsgNetWorkWarning:showWarningText(true)

    if bclear then self.NpcListdetailed = {} end

    local msg = zone_pb.BaXianViewRobListRequest()
    local count = 0
    for k,v in pairs(self.NpcListdetailed) do count = count + 1 end
    msg.pos_idx = count
    g_MsgMgr:sendMsg(msgid_pb.MSGID_BAXIAN_VIEW_ROB_LIST_REQUEST,msg)
end

--请求刷新Npc
function Class_BaXianGuoHaiSystem:ReqRefreshNpc()
    g_MsgNetWorkWarning:showWarningText(true)

    local msg = zone_pb.BaXianRefreshNpcRequest()
    g_MsgMgr:sendMsg(msgid_pb.MSGID_BAXIAN_REFRESH_NPC_REQUEST,msg)
end

--请求开始护送NPC
function Class_BaXianGuoHaiSystem:ReqConvoyNpc()
    g_MsgNetWorkWarning:showWarningText(true)
	--开始护送NPC后的次数重置
	g_VIPBase:setAddTableByNum(VipType.VipBuyOpType_RefreshNpcCost, 0)
	
    local msg = zone_pb.BaXianConvoyNpcRequest()
    msg.npc_id = self.RefreshNpcInfo.curNpcId
    g_MsgMgr:sendMsg(msgid_pb.MSGID_BAXIAN_START_CONVOY_REQUEST,msg)
end

--请求购买打劫次数
function Class_BaXianGuoHaiSystem:ReqBuyRobTimes()
    g_MsgNetWorkWarning:showWarningText(true)

    g_VIPBase:responseFunc(handler(self, self.ResponseBuyRobTimes))
    g_VIPBase:requestVipBuyTimesRequest(VipType.VipBuyOpType_RobTimes)
end

--清除打劫cd请求
function Class_BaXianGuoHaiSystem:ReqClearRobCD()
    g_MsgNetWorkWarning:showWarningText(true)

    g_VIPBase:responseFunc(handler(self, self.ResponseClearRobCD))
    g_VIPBase:requestVipBuyTimesRequest(VipType.VipBuyOpType_BaxianRobCD)
end
------------------------------------------------------------------------------------
--网络消息响应函数
------------------------------------------------------------------------------------

--清除打劫cd返回
function Class_BaXianGuoHaiSystem:ResponseClearRobCD()
    g_MsgNetWorkWarning:closeNetWorkWarning(true)
    self.DaJieCD = 0
    g_FormMsgSystem:SendFormMsg(FormMsg_BXGH_Updata_DaJieCD, nil )--通知更新打劫cd
end

--购买打劫次数返回
function Class_BaXianGuoHaiSystem:ResponseBuyRobTimes(times)
    g_MsgNetWorkWarning:closeNetWorkWarning()

    self.BuyRobTimes = self.BuyRobTimes +1 -- 打劫已购买次数
    self.RobTimes = self.RobTimes + 1 -- 可打劫次数

    local alltimes = g_VIPBase:getVipLevelCntNum(VipType.VipBuyOpType_RobTimes)
    g_ShowSysTips({text=_T("成功购买1次八仙过海挑战次数。").._T("您还可购买")..alltimes-times.._T("次。")})

	local CostYB = g_VIPBase:getVipLevelCntGold(VipType.VipBuyOpType_RobTimes)
	gTalkingData:onPurchase(TDPurchase_Type.TDP_BA_XIAN_GUO_HAI_NUM, 1, CostYB)
    --更新UI
    g_FormMsgSystem:SendFormMsg(FormMsg_BXGH_UpdataRobTimes)
end
			

--打劫返回
function Class_BaXianGuoHaiSystem:ResponseStartRob(tbMsg)
    --self.RobTimes = self.RobTimes - 1 -- 可打劫次数
    
end

--打劫返回(只有胜利了才会到这里)
function Class_BaXianGuoHaiSystem:ResponseRobResult()
    g_ShowSysTipsWord({text = _T("挑战获得")..self.WinAward.gain_gold.._T("铜钱\n").. _T("挑战获得").. self.WinAward.gain_prestige.._T("声望"), y = 450, ccsColor = g_TbColorType[4],})
   -- g_ShowSysTipsWord({text = "挑战获得".. self.WinAward.gain_prestige.."声望", y = 400, ccsColor = g_TbColorType[4],})

    -- self.RobTimes = self.RobTimes - 1 -- 可打劫次数
    g_FormMsgSystem:SendFormMsg(FormMsg_BXGH_UpdataRobTimes)
end

--请求单个Npc信息返回
function Class_BaXianGuoHaiSystem:ResponseBaXianConvoyNpcDetail(tbMsg)
    g_MsgNetWorkWarning:closeNetWorkWarning()

	cclog("Class_BaXianGuoHaiSystem:ResponseBaXianConvoyNpcDetail ---beg")
	local msgDetail = zone_pb.BaXianConvoyNpcDetailResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

    local NpcInfo_detailed  = self:GetNpcInfodetailed(msgDetail.detail)
    --更新UI
    g_WndMgr:showWnd("Game_TipBaXianView")
    g_FormMsgSystem:SendFormMsg(FormMsg_BXGH_showNpcInfoView, NpcInfo_detailed)
end

--请求打劫列表返回
function Class_BaXianGuoHaiSystem:ResponseBaXianViewRobList(tbMsg)
    g_MsgNetWorkWarning:closeNetWorkWarning()

	cclog("Class_BaXianGuoHaiSystem:ResponseBaXianViewRobList ---beg")
	local msgDetail = zone_pb.BaXianViewRobListResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
    if #msgDetail.rob_elem_list == 0 then return end


     for i=1, #msgDetail.rob_elem_list  do
        if msgDetail.rob_elem_list[i].convoy_info.convoy_uin ~= g_MsgMgr:getUin() then
            local NpcInfo_detailed  = self:GetNpcInfodetailed(msgDetail.rob_elem_list[i])
            self.NpcListdetailed[NpcInfo_detailed.playerID ] = NpcInfo_detailed
        end
    end

    --更新UI
    g_FormMsgSystem:SendFormMsg(FormMsg_BXGH_UpdataNpcList, self.NpcListdetailed)

end

--开始护送Npc返回
function Class_BaXianGuoHaiSystem:ResponseConvoyNpc(tbMsg)
    g_MsgNetWorkWarning:closeNetWorkWarning()

	cclog("Class_BaXianGuoHaiSystem:ResponseConvoyNpc ---beg")
	local msgDetail = zone_pb.BaXianConvoyNpcResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
    --更新自己的护送状态
    self.State = self.enumState.BXGH_HS -- 当前护送状态
    self.RemainTime = g_GetServerTime()  - msgDetail.start_time -- 已护送时间  
    self.Total_Time = msgDetail.end_time - msgDetail.start_time --护送总时间
    self.startTime = msgDetail.start_time
    self.endTime = msgDetail.end_time
    self.EscortTimes = self.EscortTimes - 1 --可护送次数
    --self.RefreshNpcInfo.curNpcId = 1
    --self.RefreshNpcInfo.RemainFreeRefresh = 1
    self.RefreshNpcInfo.curNpcId = gWeekNpc[g_GetServerWday()][1]
    self.RefreshNpcInfo.RemainFreeRefresh = 1
    --将自己添加到护送的简要信息列表
    local    npcinfo = BXGH_NpcInfo_brief.new()
    npcinfo.playerID = g_MsgMgr:getUin()
    npcinfo.NpcID = msgDetail.npc_id
    npcinfo.RemainTime = self.RemainTime
    npcinfo.Total_Time = self.Total_Time
    npcinfo.startTime = self.startTime
    npcinfo.endTime = self.endTime
    npcinfo.bEnemyFlag = 0
    self.NpcListbrief[npcinfo.playerID] = npcinfo

    --更新UI
    g_FormMsgSystem:SendFormMsg(FormMsg_BXGH_AddNpc, npcinfo)
end

--Npc简要信息列表返回（打开护送界面时）
function Class_BaXianGuoHaiSystem:ResponseViewBriefList(tbMsg)
    g_MsgNetWorkWarning:closeNetWorkWarning()

	cclog("Class_BaXianGuoHaiSystem:ResponseViewBriefList ---beg")
	local msgDetail = zone_pb.BaXianConvoyNpcBriefResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

    --玩家简要信息列表
    self.NpcListbrief = {}
    for i = 1, #msgDetail.brief_list do
        npcinfo = BXGH_NpcInfo_brief.new()
        npcinfo.playerID = msgDetail.brief_list[i].convoy_uin
        npcinfo.NpcID = msgDetail.brief_list[i].npc_id
        npcinfo.RemainTime = g_GetServerTime()  - msgDetail.brief_list[i].start_time
        npcinfo.Total_Time = msgDetail.brief_list[i].end_time - msgDetail.brief_list[i].start_time
        npcinfo.startTime = msgDetail.brief_list[i].start_time
        npcinfo.endTime = msgDetail.brief_list[i].end_time

        if msgDetail.brief_list[i].enemy then  npcinfo.bEnemyFlag =1 else npcinfo.bEnemyFlag = 0 end
        self.NpcListbrief[npcinfo.playerID] = npcinfo
    end
    --仇人列表
    for k, v in pairs(self.NpcListbrief) do
        if v.bEnemyFlag == 1 then
            self.NpcListEnemy[v.playerID] = v
        end
    end   

    --清理打劫列表
    self.NpcListdetailed = {}

    --通知UI刷新界面
    g_WndMgr:openWnd("Game_BaXuanGuoHai")
    g_FormMsgSystem:SendFormMsg(FormMsg_BXGH_UpdataView, nil)
end

--刷新Npc返回
function Class_BaXianGuoHaiSystem:ResponseRefreshNpc(tbMsg)
    --g_MsgNetWorkWarning:closeNetWorkWarning()

	cclog("Class_BaXianGuoHaiSystem:ResponseRefreshNpc ---beg")
	local msgDetail = zone_pb.BaXianRefreshNpcResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
	if self.RefreshNpcInfo.RemainFreeRefresh  <= 0 then 
		local costYB = g_VIPBase:getVipLevelData("RefreshNpcCost")
		gTalkingData:onPurchase(TDPurchase_Type.TDP_BA_XIAN_GUO_HAI_ROLE, 1, CostYB)
	end
   self.RefreshNpcInfo.curNpcId = msgDetail.refresh_npc.refreshed_npc_id
   self.RefreshNpcInfo.RemainFreeRefresh = msgDetail.refresh_npc.free_refresh_times
   g_Hero:setYuanBao(msgDetail.coupons)
   
	--保存刷新npc后的次数
	g_VIPBase:setAddTableByNum(VipType.VipBuyOpType_RefreshNpcCost, msgDetail.refresh_npc.times)
   --更新UI
   g_FormMsgSystem:SendFormMsg(FormMsg_BXGH_RefreshNpc, self.RefreshNpcInfo.curNpcId)
   
end

--自己的信息返回（登录时）
function Class_BaXianGuoHaiSystem:ResponseBaXianSelfInfo(msgDetail)

	--[[cclog("Class_BaXianGuoHaiSystem:ResponseBaXianSelfInfo")
	local msgDetail = zone_pb.BaXianSelfInfoResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))]]

    if msgDetail.convoy_info.npc_id ~= 0 then
        self.State = self.enumState.BXGH_HS -- 当前护送状态
    else
        self.State = self.enumState.BXGH_NONE -- 当前护送状态
    end

    self.RobTimes = self.MAX_RobTimes + g_VIPBase:getAddTableByNum(VipType.VipBuyOpType_RobTimes) - msgDetail.my_rob_times -- 可打劫次数
    self.EscortTimes = self.MAX_EscortTimes - msgDetail.convoy_times --可护送次数
    if self.State == self.enumState.BXGH_HS then
        self.RemainTime = g_GetServerTime()  - msgDetail.convoy_info.start_time -- 已护送时间  
        self.Total_Time = msgDetail.convoy_info.end_time - msgDetail.convoy_info.start_time --护送总时间
        self.startTime = msgDetail.convoy_info.start_time
        self.endTime = msgDetail.convoy_info.end_time

    else
        self.RemainTime = 0 -- 已护送时间  
        self.Total_Time = 0 --护送总时间
        self.startTime = 0
        self.endTime = 0
    end

    -- 我的8个npc的等级和护送界面显示状态
    for i = 1, #msgDetail.npc_list  do
        self.MyNpcAryLv[msgDetail.npc_list[i].npc_id].lv = msgDetail.npc_list[i].level
        self.MyNpcAryLv[msgDetail.npc_list[i].npc_id].lvExp = msgDetail.npc_list[i].exp
        self.MyNpcAryLv[msgDetail.npc_list[i].npc_id].bShow = 1
    end
    
    -- 当前Npc刷信息
    if msgDetail.refresh_info.refreshed_npc_id == 0 then
        self.RefreshNpcInfo.curNpcId = gWeekNpc[g_GetServerWday()][1]
    else
        self.RefreshNpcInfo.curNpcId = msgDetail.refresh_info.refreshed_npc_id
    end
    self.RefreshNpcInfo.RemainFreeRefresh = msgDetail.refresh_info.free_refresh_times

    --当前八仙过海的阵容
    self.BXGH_BuZhen.zhen_fa_id = msgDetail.buzhen_info.zhen_fa_id
    self.BXGH_BuZhen.card_list = {}
    for i = 1, #msgDetail.buzhen_info.card_list  do
        table.insert(self.BXGH_BuZhen.card_list, 
        {Cell_index = msgDetail.buzhen_info.card_list[i].zhenxin_id, 
         Card_index = msgDetail.buzhen_info.card_list[i].card_index+1})
    end
	
	--上香类型
	echoj("msgDetail.today_insence================登录时",msgDetail.today_insence)
	g_BaXianPary:setTodayInsence(msgDetail.today_insence)

    if g_GetServerTime() -  msgDetail.rob_cold_time_at < 0 then
        self.DaJieCD = msgDetail.rob_cold_time_at
    else
        self.DaJieCD = 0
    end
	
    self.bFirstShow = false--是否第一次打开界面
end

--打劫结果奖励返回
function Class_BaXianGuoHaiSystem:BaXianNotifyRobResult(tbMsg)
	cclog("Class_BaXianGuoHaiSystem:BaXianNotifyRobResult")
	local msgDetail = zone_pb.BaXianNotifyRobResult()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

    self.WinAward.gain_gold =msgDetail.gain_gold
    self.WinAward.gain_prestige = msgDetail.gain_prestige
    self.RobTimes = msgDetail.left_rob_times
    g_Hero:setCoins(msgDetail.update_gold)
    g_Hero:setPrestige(msgDetail.update_prestige)
end

--布阵信息的返回
function Class_BaXianGuoHaiSystem:ResponseBuZhen(tbMsg)
    g_MsgNetWorkWarning:closeNetWorkWarning()
	cclog("Class_BaXianGuoHaiSystem:ResponseBuZhen")
	local msgDetail = zone_pb.BaXianBuZhenResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

    self.BXGH_BuZhen.zhen_fa_id = msgDetail.buzhen_info.zhen_fa_id
    self.BXGH_BuZhen.card_list = {}
    for i = 1, #msgDetail.buzhen_info.card_list  do
        table.insert(self.BXGH_BuZhen.card_list, 
        {Cell_index = msgDetail.buzhen_info.card_list[i].zhenxin_id, 
         Card_index = msgDetail.buzhen_info.card_list[i].card_index+1})
    end

    g_WndMgr:closeWnd("Game_PublicBuZhen")
end 

function Class_BaXianGuoHaiSystem:ResponseSelfConvoyEnd(tbMsg)
    self.RemainTime = 0
    self.Total_Time = 0
    self.startTime = 0
    self.endTime = 0
    self.RefreshNpcInfo.curNpcId = gWeekNpc[g_GetServerWday()][1]
    self.RefreshNpcInfo.RemainFreeRefresh = 1
    self.State = self.enumState.BXGH_NONE -- 当前护送状态
end

function Class_BaXianGuoHaiSystem:ResponseOtherConvoyEnd(other)
    for i=1, #other do
        g_FormMsgSystem:SendFormMsg(FormMsg_BXGH_DecNpc, other[i])--通知八仙过海界面
        g_FormMsgSystem:SendFormMsg(FormMsg_BXGH_DecNpc_DaJie, other[i])--通知打劫列表界面
        self.NpcListEnemy[other[i]] = nil
        self.NpcListdetailed[other[i]] = nil
        self.NpcListbrief[other[i]] = nil
    end
end

--通知打劫解除时间
function Class_BaXianGuoHaiSystem:Notify_rob_cold_Time(tbMsg)
	cclog("Class_BaXianGuoHaiSystem:Notify_rob_cold_Time")
	local msgDetail = zone_pb.BaXianNotifyRobColdCD()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

    if g_GetServerTime() -  msgDetail.cold_time_at < 0 then
        self.DaJieCD = msgDetail.cold_time_at
    else
        self.DaJieCD = 0
    end
    g_FormMsgSystem:SendFormMsg(FormMsg_BXGH_Updata_DaJieCD, nil )--通知更新打劫cd
end

--零点更新
function Class_BaXianGuoHaiSystem:ZeroOClockUpdate(tbMsg)
    self.BuyRobTimes = 0
    self.RobTimes = self.MAX_RobTimes
    self.EscortTimes = self.MAX_EscortTimes

    g_FormMsgSystem:SendFormMsg(FormMsg_BXGH_UpdataView, nil)
end
-----------------------------------------------------------------------
g_BaXianGuoHaiSystem = Class_BaXianGuoHaiSystem.new()
--注册网络消息响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_BAXIAN_VIEW_BRIEF_LIST_RESPONSE, handler(g_BaXianGuoHaiSystem,g_BaXianGuoHaiSystem.ResponseViewBriefList)) --Npc简要信息列表返回
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_BAXIAN_REFRESH_NPC_RESPONSE, handler(g_BaXianGuoHaiSystem,g_BaXianGuoHaiSystem.ResponseRefreshNpc)) --Npc简要信息列表返回
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_BAXIAN_START_CONVOY_RESPONSE, handler(g_BaXianGuoHaiSystem,g_BaXianGuoHaiSystem.ResponseConvoyNpc)) --开始护送表返回
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_BAXIAN_VIEW_ROB_LIST_RESPONSE, handler(g_BaXianGuoHaiSystem,g_BaXianGuoHaiSystem.ResponseBaXianViewRobList)) --打劫列表返回
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_BAXIAN_VIEW_CONVOY_DETAIL_RESPONSE, handler(g_BaXianGuoHaiSystem,g_BaXianGuoHaiSystem.ResponseBaXianConvoyNpcDetail)) --单个npc信息返回
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_BAXIAN_NOTIFY_ROB_COLD_TIME, handler(g_BaXianGuoHaiSystem,g_BaXianGuoHaiSystem.Notify_rob_cold_Time)) --打劫cd解除时间
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_BAXIAN_START_ROB_RESPONSE, handler(g_BaXianGuoHaiSystem,g_BaXianGuoHaiSystem.ResponseStartRob)) --开始打劫返回
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_BAXIAN_NOTIFY_ROB_RESULT, handler(g_BaXianGuoHaiSystem,g_BaXianGuoHaiSystem.BaXianNotifyRobResult)) --打劫奖励返回
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_BAXIAN_BUZHEN_RESPONSE, handler(g_BaXianGuoHaiSystem,g_BaXianGuoHaiSystem.ResponseBuZhen)) --布阵返回


----------------八仙过海阵形------------------------
Class_BXGH_ZhenXing = class("Class_BXGH_ZhenXing")
Class_BXGH_ZhenXing.__index = Class_BXGH_ZhenXing

function Class_BXGH_ZhenXing:ctor()

end

local function onClick_Button_Confirm(pSender, nTag)
    if gUI_PublicBuzhen == nil then return end
    g_MsgNetWorkWarning:showWarningText(true)
    local msg = zone_pb.BaXianBuZhenRequest()

    msg.buzhen_info.zhen_fa_id = gUI_PublicBuzhen.ZF_info.zhen_fa_id
    for i = 1, #gUI_PublicBuzhen.ZF_info.card_list  do
    	local tmpInfo = common_pb.GeneralZhenXinInfo()
		tmpInfo.zhenxin_id = gUI_PublicBuzhen.ZF_info.card_list[i].Cell_index
		tmpInfo.card_index = gUI_PublicBuzhen.ZF_info.card_list[i].Card_index -1

        table.insert(msg.buzhen_info.card_list, tmpInfo)
    end
    g_MsgMgr:sendMsg(msgid_pb.MSGID_BAXIAN_BUZHEN_REQUEST,msg)
end

--布阵界面打开是的回调
function Class_BXGH_ZhenXing:OnShowWndCallBack(rootWidget)
    local Button_Confirm = tolua.cast(rootWidget:getChildAllByName("Button_StartBattle"), "Button") 
    Button_Confirm:setVisible(false)--借用Button_Confirm变量设置Button_StartBattle不可见
    Button_Confirm = tolua.cast(rootWidget:getChildAllByName("Button_Confirm"), "Button") 
    Button_Confirm:setVisible(true)

    g_SetBtnWithEvent(Button_Confirm, 1, onClick_Button_Confirm, true)
    self:InitZhenxin()
end

function Class_BXGH_ZhenXing:InitZhenxin()
    gUI_PublicBuzhen:UpdataBuZhenView(g_BaXianGuoHaiSystem.BXGH_BuZhen)
end
----------------------------------------------------
g_BXGH_ZhenXing = Class_BXGH_ZhenXing.new()

----------------Tmp代码
function Class_BaXianGuoHaiSystem:Tmp_InitData()

    self.State = self.enumState.BXGH_NONE
    self.MAX_RobTimes = 4 -- 每日最多打劫次数
    self.MAX_EscortTimes = 4 -- 每日最多护送次数

    self.RobTimes = 4 -- 可打劫次数
    self.EscortTimes = 4 --可护送次数
    self.RemainTime = 0 -- 已护送时间  
    self.Total_Time = 7200 --护送总时间

    -- 我的8个npc的等级和护送界面显示状态
    self.MyNpcAryLv = {[1]={lv = 1, bShow = 1},
                        [2]={lv = 1, bShow = 1},
                        [3]={lv = 1, bShow = 1},
                        [4]={lv = 1, bShow = 1},
                        [5]={lv = 1, bShow = 1},
                        [6]={lv = 1, bShow = 1},
                        [7]={lv = 1, bShow = 1},
                        [8]={lv = 1, bShow = 1}} 


    self.NpcListbrief = {}
    for i = 1,100 do
        npcinfo = BXGH_NpcInfo_brief.new()
        npcinfo.playerID = i
        npcinfo.NpcID = (i%5)+1
        npcinfo.RemainTime = math.random(1,7200)
        npcinfo.Total_Time = 7200
        npcinfo.bEnemyFlag = math.random(0,1)

        self.NpcListbrief[npcinfo.playerID] = npcinfo
    end

    for k, v in pairs(self.NpcListbrief) do
        if v.bEnemyFlag == 1 then
            self.NpcListEnemy[v.playerID] = v
        end
    end

    self.NpcListdetailed = {}

    --通知UI刷新界面
    g_WndMgr:openWnd("Game_BaXuanGuoHai")
    g_FormMsgSystem:SendFormMsg(FormMsg_BXGH_UpdataView, nil)
end

function Class_BaXianGuoHaiSystem:Tmp_GetNpcInfo()

    local NpcInfo_detailed = BXGH_NpcInfo_detailed.new()
  
    NpcInfo_detailed.playerID = 0           -- 玩家ID  
    NpcInfo_detailed.PlayerName = "麒麒"        -- 玩家名字  
    NpcInfo_detailed.PlayerLv = 88           --玩家等级
    NpcInfo_detailed.PlayerBreakLv = 9      -- 玩家突破等级 
    NpcInfo_detailed.PlayerStarLv = 5       -- 玩家星级  
    NpcInfo_detailed.NpcID = 2              -- NpcID  
    NpcInfo_detailed.OnlyBeRobTimes = 0     -- 剩余被打劫打劫次数  
    NpcInfo_detailed.RobMoney = 1000           -- 打劫可获得铜钱数量  
    NpcInfo_detailed.RobPrestige = 200        -- 打劫可获得声望数量  
    NpcInfo_detailed.RemainTime = 300         -- 已护送时间  
    NpcInfo_detailed.Total_Time = 7200         -- 护送总时间
    NpcInfo_detailed.bEnemyFlag = 0         -- 师傅是仇人

    g_FormMsgSystem:SendFormMsg(FormMsg_BXGH_showNpcInfoView, NpcInfo_detailed)

end

tmpCnt = 1
function  Class_BaXianGuoHaiSystem:Tmp_GetNpcInfoList()
    --self.NpcListdetailed = {}

    for i = 1, 20  do
        local NpcInfo_detailed = BXGH_NpcInfo_detailed.new()

        NpcInfo_detailed.playerID = tmpCnt           -- 玩家ID  
        NpcInfo_detailed.PlayerName = "麒麒"        -- 玩家名字  
        NpcInfo_detailed.PlayerLv = tmpCnt           --玩家等级
        NpcInfo_detailed.PlayerBreakLv = 9      -- 玩家突破等级 
        NpcInfo_detailed.PlayerStarLv = 5       -- 玩家星级  
        NpcInfo_detailed.NpcID = (i%8)+1              -- NpcID  
        NpcInfo_detailed.OnlyBeRobTimes = 0     -- 剩余被打劫打劫次数  
        NpcInfo_detailed.RobMoney = 1000           -- 打劫可获得铜钱数量  
        NpcInfo_detailed.RobPrestige = 200        -- 打劫可获得声望数量  
        NpcInfo_detailed.RemainTime = 300         -- 已护送时间  
        NpcInfo_detailed.Total_Time = 7200         -- 护送总时间
        NpcInfo_detailed.bEnemyFlag = 0         -- 师傅是仇人

        self.NpcListdetailed[NpcInfo_detailed.playerID ] = NpcInfo_detailed

        tmpCnt = tmpCnt +1
    end

    g_FormMsgSystem:SendFormMsg(FormMsg_BXGH_UpdataNpcList, self.NpcListdetailed)
end

function  Class_BaXianGuoHaiSystem:Tmp_GetRefreshNpc()
    local Wday = g_GetServerWday()
    local tmpNpc= gWeekNpc[Wday][math.random(1,5)]
    g_FormMsgSystem:SendFormMsg(FormMsg_BXGH_RefreshNpc, tmpNpc)
end