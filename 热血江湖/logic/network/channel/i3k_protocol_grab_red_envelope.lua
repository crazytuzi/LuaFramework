------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")
local Error = {
[-1] = "哎呀，运气不好，没抢到",
[-2] = "红包已经过期啦",
[-3] = "很遗憾，红包刚刚被抢光了",
}

---------------------------------抢红包系统----------------------------------------------
--红包通知协议
function i3k_sbean.redenvelope_notice.handler(bean)
	--startTime --开始时间--id--id --payLevel --红包开启等级
	--打开界面
	local userCfg = i3k_get_load_cfg()
	if not userCfg:GetRedEnvelope() then
		g_i3k_ui_mgr:OpenUI(eUIID_Grab_Red_Envelope)
		g_i3k_ui_mgr:RefreshUI(eUIID_Grab_Red_Envelope,bean.startTime,bean.id,bean.payLevel)
	end
end

--抢红包请求协议
function i3k_sbean.grab_red_envelope(startTime,id)
	local bean = i3k_sbean.redenvelope_snatch_req.new()
	bean.startTime = startTime --开始时间
	bean.id = id
	i3k_game_send_str_cmd(bean, i3k_sbean.redenvelope_snatch_res.getName())
end

function i3k_sbean.redenvelope_snatch_res.handler(res, req)
	if res.ok >0 then
		--弹出奖励界面
		--增加元宝展示  count = res.ok
		g_i3k_ui_mgr:OpenUI(eUIID_Grab_Red_Bag_Reward)
		g_i3k_ui_mgr:RefreshUI(eUIID_Grab_Red_Bag_Reward,res.ok)
	elseif res.ok == -100 then
		-- TODO 红包保底
		local times = res.dayGetGiftTimes
		g_i3k_ui_mgr:OpenUI(eUIID_Grab_Red_Bag_other)
		g_i3k_ui_mgr:RefreshUI(eUIID_Grab_Red_Bag_other, times)
	else
		local text = Error[res.ok] and Error[res.ok] or Error[-1]
		g_i3k_ui_mgr:OpenUI(eUIID_Grab_Red_Bag_Not_HaveReward)
		g_i3k_ui_mgr:RefreshUI(eUIID_Grab_Red_Bag_Not_HaveReward,text)
	end
	--关闭界面
	g_i3k_ui_mgr:CloseUI(eUIID_Grab_Red_Envelope)
end
------------------------------------------------------------------------

--帮派红包同步
function i3k_sbean.sect_red_pack_sync()
	local bean = i3k_sbean.sect_red_pack_sync_req.new()
	i3k_game_send_str_cmd(bean, "sect_red_pack_sync_res")
end

function i3k_sbean.sect_red_pack_sync_res.handler(bean)
	--g_i3k_game_context:setRedEnvelopeList(bean.packs)
	g_i3k_game_context:setRedEnvelopeSend(bean.sendTime)
	g_i3k_game_context:setRedEnvelopeReward(bean.recvTime)
	g_i3k_ui_mgr:CloseUI(eUIID_RedEnvelope)
	if bean.packs and table.nums(bean.packs) > 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_RedEnvelope)
		g_i3k_ui_mgr:RefreshUI(eUIID_RedEnvelope, bean.packs)
	else
		local callback = function (isOk)
			if isOk then
				g_i3k_ui_mgr:OpenUI(eUIID_RedEnvelopeSend)
				g_i3k_ui_mgr:RefreshUI(eUIID_RedEnvelopeSend)
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2("现在没有红包，确定跳转到发送红包介面吗？", callback)
	end
	
	g_i3k_game_context:SetRedEnvelopePoint(0)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionMain,"updateDinePoint")
end

--帮派红包发送
function i3k_sbean.sect_red_pack_send(info)
	local bean = i3k_sbean.sect_red_pack_send_req.new()
	bean.diamond = info.diamond
	bean.num = info.num
	bean.msg = info.msg
	i3k_game_send_str_cmd(bean, "sect_red_pack_send_res")
end

function i3k_sbean.sect_red_pack_send_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16724))
		g_i3k_game_context:addRedEnvelopeSend(req.diamond)
		g_i3k_ui_mgr:CloseUI(eUIID_RedEnvelopeSend)
		g_i3k_game_context:UseBaseItem(-1, req.diamond, AT_SEND_SECT_RED_PACK)
		i3k_sbean.sect_red_pack_sync()
	elseif bean.ok == -1 then
		
	else
		g_i3k_ui_mgr:PopupTipMessage("发送失败")
	end
end

--帮派红包领取
function i3k_sbean.sect_red_pack_take(id, index)
	local bean = i3k_sbean.sect_red_pack_take_req.new()
	bean.id = id
	bean.index = index
	i3k_game_send_str_cmd(bean, "sect_red_pack_take_res")
end

function i3k_sbean.sect_red_pack_take_res.handler(bean, req)
	if bean.diamond > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_RedEnvelope, "replaceWidget", req.index, bean.diamond)
		g_i3k_game_context:addRedEnvelopeReward(1)
	elseif bean.diamond == -75 then
		g_i3k_ui_mgr:PopupTipMessage("红包已被领完")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_RedEnvelope, "replaceWidget", req.index, 0)
		g_i3k_game_context:addRedEnvelopeReward(1)
	else
		g_i3k_ui_mgr:PopupTipMessage("已经不在帮派中")
	end
end

--龙运同步
function i3k_sbean.sect_destiny_reward_sync()
	local bean = i3k_sbean.sect_destiny_reward_sync_req.new()
	i3k_game_send_str_cmd(bean, "sect_destiny_reward_sync_res")
end

function i3k_sbean.sect_destiny_reward_sync_res.handler(bean)
	g_i3k_ui_mgr:OpenUI(eUIID_DragonLucky)
	g_i3k_ui_mgr:RefreshUI(eUIID_DragonLucky, bean.canUseDestiny, bean.dayGiftTimes)
end


--龙运发奖
function i3k_sbean.send_destiny_reward(isHigh)
	local bean = i3k_sbean.send_destiny_reward_req.new()
	bean.isHigh = isHigh
	i3k_game_send_str_cmd(bean, "send_destiny_reward_res")
end

function i3k_sbean.send_destiny_reward_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16804))
		i3k_sbean.sect_destiny_reward_sync()
	else
		g_i3k_ui_mgr:PopupTipMessage("发奖失败")
	end
end

--帮派红包记录
function i3k_sbean.sect_red_pack_history(packId)
	local bean = i3k_sbean.sect_red_pack_history_req.new()
	bean.packId = packId
	i3k_game_send_str_cmd(bean, "sect_red_pack_history_res")
end

function i3k_sbean.sect_red_pack_history_res.handler(bean, req)
	if #bean.history > 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_RedEnvelopeDetail)
		g_i3k_ui_mgr:RefreshUI(eUIID_RedEnvelopeDetail, bean.history, bean.packNum)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16725))
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_RedEnvelope, "deleteOverdue", req.packId)
		--i3k_sbean.sect_red_pack_sync()
	end
end
