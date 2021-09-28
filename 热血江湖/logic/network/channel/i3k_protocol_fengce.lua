------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")

--function 有奖调研() end
function i3k_sbean.sync_survey(callback)
	local sync = i3k_sbean.usersurvey_sync_req.new()
	sync.callback = callback
	i3k_game_send_str_cmd(sync, "usersurvey_sync_res")
end

function i3k_sbean.usersurvey_sync_res.handler(bean, res)
	local seq = bean.seq
	local reward = bean.reward
	if seq and reward then
		if res.callback then
			res.callback()
		end
		g_i3k_logic:OpenRewardTestUI()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_RewardTest, "setSurveyRightData", seq, reward)
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("有奖调查服务器失败"))
	end
end

--答题
function i3k_sbean.answer_question(index, answer, callback)
	local submit = i3k_sbean.usersurvey_submit_req.new()
	submit.seq = index
	submit.answer = answer
	submit.callback = callback
	i3k_game_send_str_cmd(submit, "usersurvey_submit_res")
end

function i3k_sbean.usersurvey_submit_res.handler(bean, res)
	if bean.ok==1 then
		if res.callback then
			res.callback()
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("封测答题服务器错误资讯"))
	end
end

--领奖
function i3k_sbean.take_survey_gift(callback)
	local take = i3k_sbean.usersurvey_reward_req.new()
	take.callback = callback
	i3k_game_send_str_cmd(take, "usersurvey_reward_res")
end

function i3k_sbean.usersurvey_reward_res.handler(bean, res)
	if bean.ok==1 then
		if res.callback then
			res.callback()
		end
		g_i3k_game_context:setRewardTestRedPoint(false)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleEntrance, "RefreshAllItem")
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("封测答题领奖服务器错误资讯"))
	end
end

-- 有奖调研红点
function i3k_sbean.role_survey_notice.handler(bean, res)
	if bean.canOperate == 1 then
		g_i3k_game_context:setRewardTestRedPoint(true)
	else
		g_i3k_game_context:setRewardTestRedPoint(false)
	end
end





--function 登录送礼() end
function i3k_sbean.sync_login_gift(callback)
	local sync = i3k_sbean.cblogingift_sync_req.new()
	sync.callback = callback
	i3k_game_send_str_cmd(sync, "cblogingift_sync_res")
end

function i3k_sbean.cblogingift_sync_res.handler(bean, res)
	if bean.gifts then
		if res.callback then
			res.callback()
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fengce, "setLoginRightData", bean.gifts)
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("登入送礼服务器失败"))
	end
end


function i3k_sbean.take_login_gift(day, callback)
	local take = i3k_sbean.cblogingift_take_req.new()
	take.dayNum = day
	take.callback = callback
	i3k_game_send_str_cmd(take, "cblogingift_take_res")
end

function i3k_sbean.cblogingift_take_res.handler(bean, res)
	if bean.ok==1 then
		if res.callback then
			res.callback()
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("领取登入奖励服务器失败"))
	end
end






--function 升级送礼() end
function i3k_sbean.sync_level_up_gift(callback)
	local sync = i3k_sbean.cblvlupgift_sync_req.new()
	sync.callback = callback
	i3k_game_send_str_cmd(sync, "cblvlupgift_sync_res")
end

function i3k_sbean.cblvlupgift_sync_res.handler(bean, res)
	if bean.gifts then
		if res.callback then
			res.callback()
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fengce, "setVipRightData", bean.gifts)
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("升级送礼服务器失败"))
	end
end



function i3k_sbean.take_level_gift(index, callback)
	local take = i3k_sbean.cblvlupgift_take_req.new()
	take.seq = index
	take.callback = callback
	i3k_game_send_str_cmd(take, "cblvlupgift_take_res")
end

function i3k_sbean.cblvlupgift_take_res.handler(bean, res)
	if bean.ok==1 then
		if res.callback then
			res.callback()
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("领取升级礼品服务器失败"))
	end
end





--function 完善资料() end
function i3k_sbean.sync_userdata(callback)
	local sync = i3k_sbean.userdata_sync_req.new()
	sync.callback = callback
	i3k_game_send_str_cmd(sync, "userdata_sync_res")
end

function i3k_sbean.userdata_sync_res.handler(bean, res)
	local data = bean.data
	if data then
		if res.callback then
			res.callback()
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fengce, "setMaterialRightData", data.qq, data.cellphone, data.isOldUser, data.reward)
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("完善资料服务器失败"))
	end
end

--修改资料
function i3k_sbean.reset_userdata(qq, phone, isOld, callback)
	local reset = i3k_sbean.userdata_modify_req.new()
	reset.qq = qq
	reset.cellphone = phone
	reset.isOldUser = isOld
	reset.callback = callback
	i3k_game_send_str_cmd(reset, "userdata_modify_res")
end

function i3k_sbean.userdata_modify_res.handler(bean, res)
	if bean.ok==1 then
		if res.callback then
			res.callback()
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("修改资料服务器错误资讯"))
	end
end

--领奖
function i3k_sbean.take_userdata_gift(callback)
	local take = i3k_sbean.userdata_reward_req.new()
	take.callback = callback
	i3k_game_send_str_cmd(take, "userdata_reward_res")
end

function i3k_sbean.userdata_reward_res.handler(bean, res)
	if bean.ok==1 then
		if res.callback then
			res.callback()
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("领取晚上资料奖励服务器错误资讯"))
	end
end





--function 最后冲刺() end
function i3k_sbean.sync_sprint(callback)
	local sync = i3k_sbean.cbcountdowngift_sync_req.new()
	sync.callback = callback
	i3k_game_send_str_cmd(sync, "cbcountdowngift_sync_res")
end

function i3k_sbean.cbcountdowngift_sync_res.handler(bean, res)
	if bean.gifts then
		if res.callback then
			res.callback()
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fengce, "setSprintRightData", bean.gifts)
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("封测冲刺服务器失败"))
	end
end

--领奖
function i3k_sbean.take_sprint_gift(day, callback)
	local take = i3k_sbean.cbcountdowngift_take_req.new()
	take.seq = day
	take.callback = callback
	i3k_game_send_str_cmd(take, "cbcountdowngift_take_res")
end

function i3k_sbean.cbcountdowngift_take_res.handler(bean, res)
	if bean.ok==1 then
		if res.callback then
			res.callback()
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(string.format("领取倒计时奖励服务器失败"))
	end
end






--function 限时领奖() end
function i3k_sbean.sync_timeReward(callback)
	local sync = i3k_sbean.ontimegift_sync_req.new()
	sync.callback = callback;
	i3k_game_send_str_cmd(sync, "ontimegift_sync_res")
end

function i3k_sbean.ontimegift_sync_res.handler(bean, res)
	if bean.gifts then
		if res.callback then
			res.callback()
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fengce, "setTimeRewardRightData", bean.gifts)
	else

	end
end

function i3k_sbean.take_timeReward(seq, callback)
	local take = i3k_sbean.ontimegift_take_req.new()
	take.dayNum = seq
	take.callback = callback
	i3k_game_send_str_cmd(take, "ontimegift_take_res")
end

function i3k_sbean.ontimegift_take_res.handler(bean, res)
	if bean.ok==1 then
		if res.callback then
			res.callback()
		end
		g_i3k_game_context:stopFengceCoroutine()
	end
end


function i3k_sbean.sync_strengthengift(callback)
	local data = i3k_sbean.strengthengift_sync_req.new()
	data.callback = callback;
	i3k_game_send_str_cmd(data, "strengthengift_sync_res")
end

function i3k_sbean.strengthengift_sync_res.handler(bean, res)
	if bean.gifts then
		if res.callback then
			res.callback()
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fengce, "setStrengPVPRightData", bean.gifts)
	end
end

function i3k_sbean.take_strengthengift(strenglevel, callback)
	local data = i3k_sbean.strengthengift_take_req.new()
	data.strengthenNum = strenglevel
	data.callback = callback;
	i3k_game_send_str_cmd(data, "strengthengift_take_res")
end

function i3k_sbean.strengthengift_take_res.handler(bean, res)
	if bean.ok==1 then
		if res.callback then
			res.callback()
		end
	end
end

--登陆同步红点逻辑（和强化至所需等级时）
function i3k_sbean.role_betaactivity_notice.handler(bean)
	local notice = bean.notice
	local isFirst = bean.isFirstLogin==1
	local noticeTable = {}
	for i=1, #i3k_db_fengce_name do
		local shiftDiv = i-1 <= 0 and 1 or 2
		notice = math.floor(notice/shiftDiv)
		if notice%2 == 1 then
			noticeTable[i] = true
		end
	end
	g_i3k_game_context:setFengceRedCache(noticeTable[1], noticeTable[2], noticeTable[3], noticeTable[4], noticeTable[5], noticeTable[6], noticeTable[7])
	g_i3k_game_context:setIsFirstLogin(isFirst)
	g_i3k_game_context:setIsShowFengceWebLink(bean.showWebLink == 1)
	g_i3k_game_context:setIsShowFengceBtn(true)
	g_i3k_game_context:startFengceCoroutine(noticeTable[6])
end



--同步官网调研
function i3k_sbean.take_official_reward()
	local take = i3k_sbean.official_research_take_req.new()
	i3k_game_send_str_cmd(take, "official_research_take_res")
end

function i3k_sbean.official_research_take_res.handler(bean)
	if bean.ok==1 then
		local reward = {id = i3k_db_fengce.officialReward.rewardId, count = i3k_db_fengce.officialReward.rewardCount}
		g_i3k_ui_mgr:ShowGainItemInfo({reward})
	else

	end
end
