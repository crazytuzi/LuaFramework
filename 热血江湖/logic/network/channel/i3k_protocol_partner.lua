------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")

----------------------------------------------------
local ErrorCode = {
	[-1] = i3k_get_string(17375), -- "不是同一个大区",
	[-2] = i3k_get_string(17376), -- "不能填写自己的召唤码",
	[-3] = i3k_get_string(17359), -- "伙伴码输出错误，请输入正确的伙伴码", 
	[-4] = i3k_get_string(17377), -- "绑定达到最大数量",
	[-5] = i3k_get_string(17378), -- "不能绑定同一个账号下得角色",
	[-6] = i3k_get_string(17365), -- 互帮提示
	[-7] = i3k_get_string(17888), -- 未绑定
	[-8] = i3k_get_string(17889), -- 领取奖励未达到目标
}

--相关错误码提示
local function PartnerErrorCode(result)
	if ErrorCode[result] then
		g_i3k_ui_mgr:PopupTipMessage(ErrorCode[result])
	else
		if result then
			g_i3k_ui_mgr:PopupTipMessage("无效错误码"..result)
		end
	end
end

-- 登录同步 是否绑定了伙伴码
function i3k_sbean.role_is_bind_partner.handler(bean)
	g_i3k_game_context:SetPartnerBindTime(bean.bindTime)
end

--self.code:		string	-- 自己的伙伴码
--self.partnerInfo:		DBPartner
--self.fightPower:		int32 -- 自己最大战力
	-- DBPartner
	--self.regressionTime:		int32	-- > 0 老玩家
	--self.bindTime:		int32	-- > 0 是否绑定了伙伴码
	--self.upperRoleId:		int32	-- 上线roleID
	--self.diamond:		int32	--累计消费元宝数
	--self.dividend:		int32	--红利
	--self.score:		int32	--自己积分
	--self.honorReward:		int32	-- 是否领取过荣耀礼 == 0
	--self.parterReward:		map[int32, DBPartnerReward]	-- k awType
	--self.underRoleIds:		map[int32, DBBindRoleInfo] -- k roleID
	--self.unBindCdTime:		int32	--最近解绑时间
	--self.padding2:		int32
		-- DBPartnerReward
		--self.lastRewardTime:		int32	--上次领取时间
		--self.lastRewardId:		int32 	--上次领取ID

		-- DBBindRoleInfo
		--self.name:		string	
		--self.level:		int32	
		--self.maxFightPower:		int32	--战力
		--self.isRegression:		int32	-- > 0 老玩家
		--self.activity:		int32	
		--self.dividend:		int32	
		--self.score:		int32	
		--self.lastLoginTime:		int32 --最后登录时间
-- 同步伙伴系统信息
function i3k_sbean.sync_partner_info(openTabId)
	local bean = i3k_sbean.sync_partner_info_req.new()
	bean.openTabId = openTabId --打开界面
	i3k_game_send_str_cmd(bean, "sync_partner_info_res")
end

function i3k_sbean.sync_partner_info_res.handler(bean, req)
	if bean.code then
		g_i3k_game_context:SetPartnerBindTime(bean.partnerInfo.bindTime)
		g_i3k_game_context:SetPartnerUnBindTime(bean.partnerInfo.unBindUnderCdTime, bean.partnerInfo.unBindUpperCdTime)
		g_i3k_ui_mgr:OpenUI(eUIID_HuoBan)
		g_i3k_ui_mgr:RefreshUI(eUIID_HuoBan, bean.code, bean.partnerInfo, bean.fightPower, req.openTabId, bean.bindCode)
		g_i3k_ui_mgr:CloseUI(eUIID_HuoBanUnbind)
	end
end

-- 填写伙伴码
function i3k_sbean.add_partner_code(code)
	local bean = i3k_sbean.add_partner_code_req.new()
	bean.code = code
	i3k_game_send_str_cmd(bean, "add_partner_code_res")
end

function i3k_sbean.add_partner_code_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_ui_mgr:CloseUI(eUIID_HuoBanCode)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17379))
		i3k_sbean.sync_partner_info()
	else
		PartnerErrorCode(bean.ok)
	end
end

--领取奖励
function i3k_sbean.receive_partner_reward(awardType, awardId, awardItems)
	local items = g_i3k_db.i3k_db_cfg_items_to_BagEnougMap(awardItems)
	if not g_i3k_game_context:IsBagEnough(items) then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1481))
	end

	local bean = i3k_sbean.receive_partner_reward_req.new()
	bean.type  = awardType
	bean.actId = awardId
	bean.awardItems = awardItems
	i3k_game_send_str_cmd(bean, "receive_partner_reward_res")
end

function i3k_sbean.receive_partner_reward_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_ui_mgr:ShowGainItemInfoByCfg_safe(req.awardItems)
		i3k_sbean.sync_partner_info()
	else
		PartnerErrorCode(bean.ok)
	end
end

--荣耀归来
function i3k_sbean.receive_partner_honour_reward(awardItems)
	local items = g_i3k_db.i3k_db_cfg_items_to_BagEnougMap(awardItems)
	if not g_i3k_game_context:IsBagEnough(items) then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1481))
	end
	
	local bean = i3k_sbean.receive_partner_honour_reward_req.new()
	bean.awardItems = awardItems
	i3k_game_send_str_cmd(bean, "receive_partner_honour_reward_res")
end

function i3k_sbean.receive_partner_honour_reward_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_ui_mgr:ShowGainItemInfoByCfg_safe(req.awardItems)
		i3k_sbean.sync_partner_info()
	else
		PartnerErrorCode(bean.ok)
	end
end

function i3k_sbean.unbind_partner(id)
	local bean = i3k_sbean.unbind_partner_req.new()
	bean.roleId = id
	i3k_game_send_str_cmd(bean, "unbind_partner_res")
end

function i3k_sbean.unbind_partner_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_HuoBanBonus, "onUnBindSuccess", req.roleId)
	else
		PartnerErrorCode(bean.ok)
	end
end
function i3k_sbean.unbind_upper_partner()
	local bean = i3k_sbean.unbind_upper_partner_req.new()
	i3k_game_send_str_cmd(bean, "unbind_upper_partner_res")
end
function i3k_sbean.unbind_upper_partner_res.handler(bean)
	if bean.ok > 0 then
		i3k_sbean.sync_partner_info()
	end
end
