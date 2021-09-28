WBSystem = class("WBSystem")
WBSystem.__index = WBSystem

COST = 
{
	YueLi = 1,
	YuanBao = 2,
}

local tbBossWnd = 
{
	"Game_WorldBoss1",
	"Game_WorldBoss2",
	"Game_WorldBossGuild",
	"Game_SceneBossGuild"
}

function WBSystem:isInit(nType)
	return self.tbInit[nType]
end

function WBSystem:reset()
	self.tbInit = {}
end

function WBSystem:getAutoReborn()
	return self.bAutoReborn
end

function WBSystem:setAutoReborn(bFlag)
	self.bAutoReborn = bFlag
end

-- 通知boss伤害排行 NotifyBossHurtRank 
function WBSystem:hurtRankResponse(tbMsg)
	local msg = zone_pb.NotifyBossHurtRank()
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))
	self.tbRank = {}
	for k,v in ipairs(msg.hurt_list) do
		table.insert(self.tbRank, {name = v.name, damage = v.hurtValue})
	end
	
	g_FormMsgSystem:PostFormMsg(FormMsg_WorldBoss2_Rank, {tbRank = self.tbRank, nBossHp = self.tbMonster.nMaxHp })
end

--通知boss副本3分钟后开启  MoveNotifyBossPre90sOpen
function WBSystem:preOpenResponse(tbMsg)
	local msg = zone_pb.MoveNotifyBossPre90sOpen()
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))
	g_FormMsgSystem:PostFormMsg(FormMsg_WorldBoss2_Block, true)
end

--通知boss副本开启
function WBSystem:openResponse(tbMsg)
	local msg = zone_pb.MoveNotifyBossOpen()
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))

	self.tbMonster.nHp = msg.monster_hp
	self.tbMonster.nMaxHp = msg.monster_hp
	local CSV_MonsterBase = g_DataMgr:getMonsterBaseCsv(msg.monster_config_id)
	local CSV_ActivityWorldBoss = g_DataMgr:getCsvConfigByOneKey("ActivityWorldBoss", msg.boss_id)
	self.tbMonster.szName = CSV_MonsterBase.Name
	self.tbMonster.nStarLevel = CSV_ActivityWorldBoss.StarLevel
	self.tbMonster.szPainting = CSV_MonsterBase.SpineAnimation
	self.tbMonster.monster_type = msg.boss_monster_type
	self.tbMonster.nWorldBossCfgId = msg.boss_id
	self.tbMonster.bInit = false
	g_FormMsgSystem:PostFormMsg(FormMsg_WorldBoss2_BossInfo, self.tbMonster)


	g_FormMsgSystem:PostFormMsg(FormMsg_WorldBoss2_Block, false)
end

-- 广播boss血量到场景中所有玩家 BroadcastBossHpToScene 
function WBSystem:updateBossHpResponse(tbMsg)
	local msg = zone_pb.BroadcastBossHpToScene()
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))
    if self.tbMonster ==nil then return end
	self.tbMonster.nHp = msg.hp
	g_FormMsgSystem:PostFormMsg(FormMsg_WorldBoss2_BossInfo, self.tbMonster)

	-- if 0 == msg.hp then
	-- 	g_ClientMsgTips:showMsgConfirm("世界BOSS已被击败",function ( ... )
	-- 		if(g_WndMgr:isVisible("Game_Battle") )then
	-- 			g_WndMgr:closeWnd("Game_Battle")
	-- 		end
	-- 	end)
	-- end
end

--boss信息
function WBSystem:requestBossInfoResponse(tbMsg)
	local msg = zone_pb.BossInfoResponse()
	msg:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msg)
	cclog(msgInfo)

	self.tbInit = {}
	if g_WndMgr:getWnd(tbBossWnd[msg.type]) then
		self.tbInit[msg.type] = true
	end

	if not self.tbGuWu then
		self.tbGuWu = {}
	end
	if not self.tbGuWu[msg.type] then
		self.tbGuWu[msg.type] = {}
	end

	self.tbGuWu[msg.type][COST.YueLi] = msg.knowlege_guwu_cnt
	self.tbGuWu[msg.type][COST.YuanBao] = msg.yuanbao_guwu_cnt

	self.tbMonster = {}
	if macro_pb.WORLD_BOSS_TYPE == msg.type or macro_pb.GUILD_WORLD_BOSS_TYPE == msg.type then
		g_FormMsgSystem:PostFormMsg(FormMsg_WorldBoss1_GuWu)
	    if(g_WndMgr:isVisible("Game_Battle") )then
			local wnd = g_WndMgr:getWnd(tbBossWnd[self.curType])
			if wnd then
				wnd:refreshWorldBossWnd(msg)
			end
	    else
		    g_WndMgr:openWnd(tbBossWnd[self.curType], msg)
	    end
	-- elseif macro_pb.GUILD_WORLD_BOSS_TYPE == msg.type then
	-- 	g_FormMsgSystem:PostFormMsg(FormMsg_WorldBoss1_Guild_GuWu)
	--     if(g_WndMgr:isVisible("Game_Battle") )then
	-- 		local wnd = g_WndMgr:getWnd("Game_WorldBossGuild")
	-- 		if wnd then
	-- 			wnd:refreshWorldBossWnd(msg)
	-- 		end
	--     else
	-- 	    g_WndMgr:openWnd("Game_WorldBossGuild", msg)
	--     end
	else
		g_FormMsgSystem:PostFormMsg(FormMsg_WorldBoss2_GuWu)
		self.tbMonster.nHp = msg.boss_left_hp

		if msg.boss_monster_type then
			local CSV_MonsterBase = g_DataMgr:getMonsterBaseCsv(msg.boss_monster_type)
			local CSV_ActivityWorldBoss = g_DataMgr:getCsvConfigByOneKey("ActivityWorldBoss", msg.boss_id)
			self.tbMonster.nMaxHp = msg.boss_max_hp
			self.tbMonster.szName = CSV_MonsterBase.Name
			self.tbMonster.nStarLevel = CSV_ActivityWorldBoss.StarLevel
			self.tbMonster.szPainting = CSV_MonsterBase.SpineAnimation
			self.tbMonster.monster_type = msg.boss_monster_type
			self.tbMonster.nWorldBossCfgId = msg.boss_id
			self.tbMonster.bInit = false
		end
		g_FormMsgSystem:PostFormMsg(FormMsg_WorldBoss2_BossInfo, self.tbMonster)

		self.nMaxRank = msg.max_rank
		if self.nMaxRank > 0 then
			self.tbRank = msg.sort_damage_lst
			g_FormMsgSystem:PostFormMsg(FormMsg_WorldBoss2_Rank, {tbRank = self.tbRank, nBossHp = self.tbMonster.nMaxHp, nMyDamege = msg.self_damage})
		end
		
		self.nLastAtkTime = msg.last_atk_time
		g_FormMsgSystem:PostFormMsg(FormMsg_WorldBoss2_CD, self.nLastAtkTime)
		
		if(not g_WndMgr:isVisible("Game_Battle") )then
			g_WndMgr:openWnd(tbBossWnd[self.curType])
		elseif self.bAutoReborn or g_RoleSystem:getAutoFight() then
			g_Timer:pushLoopTimer(1, function ()
					local szWnd = g_WndMgr:getTopWndName()
					if "Game_BatWin1" == szWnd then
						local wnd = g_WndMgr:getWnd(szWnd)
						local Button_Return = wnd.rootWidget:getChildAllByName("Button_Return")
						if Button_Return:isVisible() then
							wnd.rootWidget:guidReleaseUpEvent()
							local szWnd = g_WndMgr:getTopWndName()
							if "Game_RewardMsgConfirm" == szWnd then
								local wnd = g_WndMgr:getWnd(szWnd)
								wnd.bCanCloseWnd = true
								wnd.rootWidget:guidReleaseUpEvent()
								g_FormMsgSystem:PostFormMsg(FormMsg_WorldBoss2_ClearCD)
							end
							return true
						end
					else
                        return true
                    end
				end)
		end
	end
end

--请求boss消息
function WBSystem:requestEnterWB(nType)
	self.curType = nType
    local msg = zone_pb.BossInfoRequest()
    msg.type = nType
    g_MsgMgr:sendMsg(msgid_pb.MSGID_BOSS_INFO_REQUEST, msg)
end

function WBSystem:requestGuWu(nActivityType, bYuanBao)
	local csv = g_DataMgr:getCsvConfig("ActivityWorldBossGuWu")
	if self.tbGuWu[nActivityType][COST.YueLi] + self.tbGuWu[nActivityType][COST.YuanBao] < #csv then
		local msg = zone_pb.GuwuRequest()
		msg.type = nActivityType
		msg.is_coupous = bYuanBao
		g_MsgMgr:sendMsg(msgid_pb.MSGID_BOSS_GUWU_REQUEST, msg)
	else
		g_ShowSysTips({text = _T("鼓舞次数已达上限")})
	end
end

function WBSystem:requestAttack()
    g_MsgNetWorkWarning:showWarningText(true)
	local msg = zone_pb.AttackBossReq()
	msg.type = self.curType
	g_MsgMgr:sendMsg(msgid_pb.MSGID_ATTACK_BOSS_REQUEST, msg)
   
end

function WBSystem:showRankList(msg)
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_BOSS_RANKLIST_RESPONSE, handler(self, self.rankInfoResponse) )--排名信息
	self:requestRankInfo(1, math.min(self.nMaxRank, 10))
end

--请求排名信息
function WBSystem:requestRankInfo(nStart, nEnd)
    if self.curType == nil then return end
	local msg = zone_pb.BossRankListRequest()
	msg.type = self.curType
	msg.start_rank = nStart
    msg.end_rank = nEnd
	g_MsgMgr:sendMsg(msgid_pb.MSGID_BOSS_RANKLIST_REQUEST, msg)
end

--排名信息响应, 世界BOSS2中第一次打开用这个
function WBSystem:rankInfoResponse(tbMsg)
	local msg = zone_pb.BossRankListResponse()
	msg:ParseFromString(tbMsg.buffer)
    cclog(tostring(msg))

    local tbData = {}
    tbData.tbBossRankInfo = {}
    tbData.nMax = self.nMaxRank
    tbData.nWorldBossCfgId = self.tbMonster.nWorldBossCfgId
    tbData.nBossMaxHp = self.tbMonster.nMaxHp
    local tbBossDamage = msg.rank_list
    for i=1, #tbBossDamage do
        table.insert(tbData.tbBossRankInfo, tbBossDamage[i])
    end

	g_WndMgr:showWnd("Game_WorldBossRank", tbData)
end


function WBSystem:guWuResponse(tbMsg)
	local msg = zone_pb.GuwuResponse()
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))
	if msg.is_success then
		if msg.is_coupous then
			self.tbGuWu[msg.type][COST.YuanBao] = msg.cur_guwu_cnt
			local cost = g_Hero:getYuanBao() - msg.cur_cost_remain
			g_Hero:setYuanBao(msg.cur_cost_remain)
			g_ShowSysTips({text = _T("消耗")..cost.._T("元宝鼓舞成功，攻击力提升10%"), ccsColor = ccs.COLOR.BRIGHT_GREEN})
			
			gTalkingData:onPurchase(TDPurchase_Type.TDP_WORLD_BOSS_GUWU,1,cost)	
		else
			self.tbGuWu[msg.type][COST.YueLi] = msg.cur_guwu_cnt
			local cost = g_Hero:getKnowledge() - msg.cur_cost_remain
			g_Hero:setKnowledge(msg.cur_cost_remain)
			g_ShowSysTips({text = _T("消耗")..cost.._T("阅历鼓舞成功，攻击力提升10%"), ccsColor = ccs.COLOR.BRIGHT_GREEN})
		end
		if macro_pb.WORLD_BOSS_TYPE == msg.type or macro_pb.GUILD_WORLD_BOSS_TYPE == msg.type then
			g_FormMsgSystem:PostFormMsg(FormMsg_WorldBoss1_GuWu)
		else
			g_FormMsgSystem:PostFormMsg(FormMsg_WorldBoss2_GuWu)
		end
	else
		local cost = g_Hero:getKnowledge() - msg.cur_cost_remain
		g_Hero:setKnowledge(msg.cur_cost_remain)
		g_ShowSysTips({text = _T("消耗")..cost.._T("阅历鼓舞失败，攻击力不变"), ccsColor = ccs.COLOR.RED})
	end
		
end

function WBSystem:getGuWu(nType, nCostType)
	return self.tbGuWu[nType][nCostType] or 0
end

function WBSystem:getGuWuCost(nActivityType, nCostType)
	local nTotal = self.tbGuWu[nActivityType][COST.YueLi] + self.tbGuWu[nActivityType][COST.YuanBao] + 1
	if COST.YueLi == nCostType then
		return g_DataMgr:getCsvConfigByTwoKey("ActivityWorldBossGuWu", nTotal, "NeedKnowledge") or 0
	else
		return g_DataMgr:getCsvConfigByTwoKey("ActivityWorldBossGuWu", nTotal, "NeedYuanBao") or 0
	end
end

function WBSystem:ctor()
	self.tbInit = {}
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_MOVE_ACTIVITY_PRE_OPEN,handler(self,self.preOpenResponse))
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_MOVE_ACTIVITY_OPEN,handler(self,self.openResponse))
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_MOVE_BROADCAST_BOSS_HP,handler(self,self.updateBossHpResponse))
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_MOVE_NOTIFY_BOSS_HURT_RANK,handler(self,self.hurtRankResponse))

	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_BOSS_GUWU_RESPONSE,handler(self,self.guWuResponse))

	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_BOSS_INFO_RESPONSE, handler(self,self.requestBossInfoResponse)) --boss信息请求

end

g_WBSystem = WBSystem.new()