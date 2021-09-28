------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")

----------------------------------------------------

--约战npc错误码
local g_PROTOCOL_OP_FIGHT_NPC_ALREADY_WIN	= -1 --已经挑战过
local g_PROTOCOL_OP_FIGHT_NPC_ALL_WIN		= -2 --已经全部挑战
local g_PROTOCOL_OP_FIGHT_NPC_COND_REQ		= -3 --条件不满足
local g_PROTOCOL_OP_FIGHT_NPC_COOL_TIME		= -4 --还在挑战冷却时间
local g_PROTOCOL_OP_FIGHT_NPC_NOT_WIN		= -5 --挑战未成功不能领奖
local g_PROTOCOL_OP_FIGHT_NPC_BAG_FULL		= -6 --背包满

local ErrorCode = {
	[g_PROTOCOL_OP_FIGHT_NPC_ALREADY_WIN] 			= "已经挑战过",
	[g_PROTOCOL_OP_FIGHT_NPC_ALL_WIN]				= "已经全部挑战",
	[g_PROTOCOL_OP_FIGHT_NPC_COND_REQ]				= "条件不满足",
	[g_PROTOCOL_OP_FIGHT_NPC_COOL_TIME]				= "还在挑战冷却时间",
	[g_PROTOCOL_OP_FIGHT_NPC_NOT_WIN]				= "挑战未成功不能领奖",
	[g_PROTOCOL_OP_FIGHT_NPC_BAG_FULL]				= "背包满",
}

--错误码提示
local function FightNpcErrorCode(result)
	if ErrorCode[result] then
		g_i3k_ui_mgr:PopupTipMessage(ErrorCode[result])
	end
end

-- 登录时同步约战NPC信息
function i3k_sbean.role_fightnpc.handler(bean)
	g_i3k_game_context:SetFightNpcInfo(bean.info)
end

-- 开始挑战
function i3k_sbean.fightnpc_start()
	local bean = i3k_sbean.fightnpc_start_req.new()
	i3k_game_send_str_cmd(bean, "fightnpc_start_res")
end

function i3k_sbean.fightnpc_start_res.handler(bean, req)
	if bean.ok == 1 then
		
	else
		FightNpcErrorCode(bean.ok)
	end
end

-- 奖励领取
function i3k_sbean.fightnpc_reward(reward)
	local bean = i3k_sbean.fightnpc_reward_req.new()
	bean.reward = reward
	i3k_game_send_str_cmd(bean, "fightnpc_reward_res")
end

function i3k_sbean.fightnpc_reward_res.handler(bean, req)
	if bean.coolTime > 0 then
		g_i3k_game_context:ChangeFightNpcCurIndex(bean.coolTime)--领取奖励后，下一个约战NPC的冷却时间
		g_i3k_ui_mgr:CloseUI(eUIID_FightNpc)
		g_i3k_ui_mgr:ShowGainItemInfo(req.reward)
	else
		FightNpcErrorCode(bean.coolTime)
	end
end

-- 副本开始
function i3k_sbean.role_fightnpcmap_start.handler(bean)
	-- 暂时无操作
end

-- 副本结束
function i3k_sbean.role_fightnpcmap_end.handler(bean)
	-- 暂时无操作
end

-- 副本结果
function i3k_sbean.role_fightnpcmap_result.handler(bean)
	--self.win:		int32	--是否胜利
	g_i3k_game_context:SetFightNpcState(bean.win)
	if bean.win == 1 then
		local callbackfun = function()
			g_i3k_ui_mgr:OpenUI(eUIID_FightNpc)
			g_i3k_ui_mgr:RefreshUI(eUIID_FightNpc)
		end
		g_i3k_game_context:SetMapLoadCallBack(callbackfun)
	end
end
