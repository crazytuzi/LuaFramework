------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")

----------------------------------------------------
local ErrorCode = {
	[-1] = "等级不满足", 	-- 等级不满足
	[-2] = i3k_get_string(17368, i3k_db_spirit_boss.common.daylyTimes), 		-- 没有次数
	[-3] = "不在开放时间", 	-- 不在开放时间
	[-4] = "没有参加活动", 	-- 没有参加活动
}

--相关错误码提示
local function SpiritBossErrorCode(result)
	if ErrorCode[result] then
		g_i3k_ui_mgr:PopupTipMessage(ErrorCode[result])
	else
		if result then
			g_i3k_ui_mgr:PopupTipMessage("无效错误码："..result)
		end
	end
end

-- 玩家登陆信息同步
function i3k_sbean.role_gaintboss_sync.handler(bean)
	--TODO
end

-- 巨灵信息同步
function i3k_sbean.gaintboss_sync()
	local bean = i3k_sbean.gaintboss_sync_req.new()
	i3k_game_send_str_cmd(bean, "gaintboss_sync_res")
end

function i3k_sbean.gaintboss_sync_res.handler(bean, req)
	--self.openDays:		set[int32]
	local openDays = {}
	for k, v in pairs(bean.openDays) do
		openDays[#openDays+1] = k
	end
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "loadSpiritUI", openDays)
end

-- 参加巨灵攻城
function i3k_sbean.gaintboss_join()
	local bean = i3k_sbean.gaintboss_join_req.new()
	i3k_game_send_str_cmd(bean, "gaintboss_join_res")
end

function i3k_sbean.gaintboss_join_res.handler(bean, req)
	--self.ok:		int32	
	if bean.ok == 1 then
		g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_SPIRIT_BOSS, g_SCHEDULE_COMMON_MAPID)
	else
		SpiritBossErrorCode(bean.ok)
	end
end

-- 抽奖
function i3k_sbean.gaintboss_reward(index, bossID)
	local bean = i3k_sbean.gaintboss_reward_req.new()
	bean.index = index
	bean.bossID = bossID
	i3k_game_send_str_cmd(bean, "gaintboss_reward_res")
end

function i3k_sbean.gaintboss_reward_res.handler(bean, req)
	if bean.ok > 0 then
	else
		SpiritBossErrorCode(bean.ok)
	end
end

-- 神秘buff
function i3k_sbean.gaintboss_takebuff()
	local bean = i3k_sbean.gaintboss_takebuff_req.new()
	i3k_game_send_str_cmd(bean, "gaintboss_takebuff_res")
end

function i3k_sbean.gaintboss_takebuff_res.handler(bean, req)
	--self.ok:		int32
	if bean.ok == 1 then
	else
		SpiritBossErrorCode(bean.ok)
	end
end

-- 即将刷新boss(抽奖 rewards key index, value rate)
function i3k_sbean.gaintboss_map_info.handler(bean)
	-- <field name="rewards" type="map[int32, int32]"/>
	-- <field name="nextCanTakeBuffTime" type="int32"/>
	-- <field name="curBossID" type="int32"/>
	-- <field name="curBossHP" type="int32"/>
	g_i3k_game_context:setSpiritBossData(bean.rewards, bean.nextCanTakeBuffTime, bean.curBossID, bean.curBossHP, bean.curBossIndex)
	g_i3k_ui_mgr:RefreshUI(eUIID_SpiritBossFight)
end

-- 即将刷新bos
function i3k_sbean.gaintboss_welcome.handler(bean)
	--self.bossID:		int32	
	--倒计时动画
	g_i3k_game_context:StartSpiritCoolTime()
	local bossData = g_i3k_game_context:getSpiritBossData()
	g_i3k_game_context:setSpiritBossData(bossData.rewards, bossData.nextBuffTime, bean.bossID, i3k_db_monsters[bean.bossID].hpOrg, bossData.curBossIndex + 1)
	g_i3k_ui_mgr:RefreshUI(eUIID_SpiritBossFight)
	--[[local bossData = g_i3k_game_context:getSpiritBossData()
	g_i3k_game_context:setSpiritBossData({}, bossData.nextBuffTime, bean.bossID, 0)
	g_i3k_ui_mgr:RefreshUI(eUIID_SpiritBossFight)--]]
end

-- 同步伤害排行榜
function i3k_sbean.gaintboss_rank_query_handler()
	local bean = i3k_sbean.gaintboss_rank_query.new()
	i3k_game_send_str_cmd(bean)
end


-- 同步伤害排行榜(gaintboss_rank_query异步回应)
function i3k_sbean.gaintboss_rank.handler(bean)
	--self.bossID:		int32	
	--self.selfDamage:		int32	
	--self.rank:		vector[DamageInfo]	
		-- DamageInfo
		--self.roleID:		int32	
		--self.roleName:		string	
		--self.damage:		int32
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_SpiritBossFight, "updateDamageRank", bean.rank, bean.selfDamage)
end

-- boss死亡结算信息
function i3k_sbean.gaintboss_result.handler(bean)
	g_i3k_ui_mgr:OpenUI(eUIID_SpiritBossResult)
	g_i3k_ui_mgr:RefreshUI(eUIID_SpiritBossResult, bean)
	local bossData = g_i3k_game_context:getSpiritBossData()
	g_i3k_game_context:setSpiritBossData({}, bossData.nextBuffTime, 0, 0, bossData.curBossIndex)
	g_i3k_ui_mgr:RefreshUI(eUIID_SpiritBossFight)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_SpiritBossFight, "setBossVisible", false)
end

-- 通知客户端巨灵攻城结束
function i3k_sbean.role_gaintboss_end.handler(bean)
	g_i3k_ui_mgr:ShowCustomMessageBox1("退出活动", "本次活动已经结束", function( )
		i3k_sbean.mapcopy_leave()
	end)
end

-- 抽奖(map结果)
function i3k_sbean.gaintboss_map_reward.handler(bean)
	-- <field name="bossID" type="int32"/>
	-- <field name="index" type="int32"/>
	-- <field name="rate" type="int32"/>
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_SpiritBossFight, "updateLottoReward", bean.index, bean.rate)
end

-- 	神秘buff(map结果)
function i3k_sbean.gaintboss_map_takebuff.handler(bean)
	-- <field name="buffID" type="int32"/>
	-- <field name="nextCanTakeBuffTime" type="int32"/>
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_SpiritBossFight, "updateBuffInfo", bean.buffID, bean.nextCanTakeBuffTime)
end

