------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")
local Errorfun = function (errorID, str)
	local divorcTime = 0
	if str then
		divorcTime = string.split(str, "|")
		str = divorcTime[1] == g_i3k_game_context:GetRoleName() and "您" or divorcTime[1]
		divorcTime = divorcTime[2]
	end
	local Error = {
	[-1] = i3k_get_string(863, str or "", i3k_db_marry_rules.marryLevel),
	[-2] = i3k_get_string(864, str or "", i3k_db_marry_rules.marryFriends),
	[-3] = i3k_get_string(867, str or "", i3k_db_marry_rules.evilValue),
	[-4] = i3k_get_string(868, str or ""),
	[-5] = i3k_get_string(866, str or "", g_i3k_db.i3k_db_get_DivorcTime(divorcTime)),
	[-6] = "结婚所需道具不足",
	[-7] = "求婚已失效",
	[-8] = "结婚资料存储失效",
	[-9] = "结婚步骤错误",
	[-10] = "结婚流程时间已过",
	[-11] = "技能已达到最大等级",
	[-12] = "升级所需的姻缘等级不足",
	[-13] = "配偶不线上或不在大地图",
	[-14] = "传送正在冷却中",
	[-15] = i3k_get_string(870, str or ""),
	[-16] = "婚礼档次不足",
	[-17] = "双方不是互为好友",
	[-18] = i3k_get_string(3032),
	[-19] = i3k_get_string(3034),
	[-20] = i3k_get_string(3037),
	[-21] = "不在预约线内",
	[-22] = "当前未结婚，无法预约",
	[-23] = i3k_get_string(3035),
	[-24] = i3k_get_string(3033),
	[-25] = i3k_get_string(3036),
	[-27] = i3k_get_string(3050),
	[-28] = "正处于多人骑乘或相依相偎状态",
	}
	return Error[errorID]
end


---------------------------------结婚系统----------------------------------------------
-----同步结婚信息--
--同步步骤消息
function i3k_sbean.login_marriage_info.handler(bean)
	--g_i3k_game_context:setMarryEveryData("marriageStep",bean.marriageStep)
	--self.marriageLevel:		int32
	--self.marriageSkill:		map[int32, MarriageSkillInfo]
	--self.marriageTime:		int32
	--self.marriageStep:		int32
	g_i3k_game_context:setRecordSteps(bean.marriageStep)
	g_i3k_game_context:setRecordMarryTime(bean.marriageTime)
	g_i3k_game_context:setMarryRoleId(bean.marriageRoleId)						--记录对象id
	g_i3k_game_context:setMarryEveryData("marriageLevel",bean.marriageLevel)	--记录姻缘等级
	g_i3k_game_context:setMarryType(bean.marriageType)
	local hero = i3k_game_get_player_hero()
	if hero then
		hero:UpdateMarryProps()
	end
end


--求婚请求
function i3k_sbean.marryPropose(grade)
	local bean = i3k_sbean.propose_req.new()
	bean.grade = grade --级别
	i3k_game_send_str_cmd(bean, i3k_sbean.propose_res.getName())
end

function i3k_sbean.propose_res.handler(res, req)
	if res.ok >0 then
		g_i3k_game_context:setMarryType(req.grade)
		g_i3k_ui_mgr:PopupTipMessage("求婚请求发送成功")
	else
		if res.ok ~= 0 then
			g_i3k_ui_mgr:PopupTipMessage(Errorfun(res.ok, res.errorName))
		end
	end
end

--求婚请求若满足条件推送给被求婚的对象，包含参数婚礼的级别
function i3k_sbean.propose_push.handler(bean)
	g_i3k_game_context:setMarryEveryData("marriageType",bean.grade)
	--调用被求婚界面
	g_i3k_logic:OpenMarryProposing(bean.grade)
end

--被求婚者反应 --同意 不同意   （求婚响应请求）
--暂定-1为正忙，1为接受，2为拒绝，并将婚礼级别带过来
function i3k_sbean.toMarryResponse(grade,response, name, id)
	local bean = i3k_sbean.propose_response_req.new()
	bean.grade = grade --级别
	bean.response = response --响应
	bean.name = name
	bean.id = id
	i3k_game_send_str_cmd(bean, i3k_sbean.propose_response_res.getName())
end

function i3k_sbean.propose_response_res.handler(res, req)
	if res.ok >0 then
		g_i3k_ui_mgr:PopupTipMessage("发送成功")
		--刷新结婚状态
		if req.response ==1 then
			g_i3k_game_context:setMarryRoleId(req.id)
			g_i3k_game_context:setMarryRoleName(req.name)
			g_i3k_game_context:setRecordSteps(req.grade == 1 and 0 or 1)
			--记录结婚等级默认为1级
			g_i3k_game_context:setMarryEveryData("marriageLevel",1)	--记录姻缘等级
			--记录当前时间（当结婚时间戳）
			local curtime = math.modf(i3k_game_get_time())
			g_i3k_game_context:setRecordMarryTime(curtime)
			g_i3k_game_context:AddTaskToDataList(i3k_get_MrgTaskCategory())
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateMrgTask")
		end
	else
		if res.ok ~= 0 then
			g_i3k_ui_mgr:PopupTipMessage(Errorfun(res.ok, res.errorName))
		end
	end
end


--将响应推送给求婚者，求婚者对应响应（-1,1,2）做出对应动作  求婚响应推送
function i3k_sbean.role_propose_response.handler(bean)
	if  bean.ok ==-1 then
		g_i3k_ui_mgr:PopupTipMessage("对方正忙")
	elseif bean.ok ==1 then
		local data = i3k_db_marry_grade[g_i3k_game_context:getMarryType()]
		local isDiscount = g_i3k_db.i3k_db_get_is_weeding_discount()
		local percents = g_i3k_db.i3k_db_get_weeding_discount()
		local per = percents[g_i3k_game_context:getMarryType()] or 10000
		if not isDiscount then
			per = 10000
		end
		if data.marryUsedMoney~=0 then
			g_i3k_game_context:UseCommonItem(-g_BASE_ITEM_COIN, data.marryUsedMoney)
		end
		if data.marryUsedWing ~= 0 then
			g_i3k_game_context:UseCommonItem(-g_BASE_ITEM_DIAMOND, data.marryUsedWing * per / 10000)
		end
		if data.marryUsedPorpId~=0 then
			g_i3k_game_context:UseCommonItem(data.marryUsedPorpId, data.marryUsedPorpNum)
		end
		local other = g_i3k_game_context:GetTeamOtherMembersProfile()
		local name = other[1].overview.name
		local id = other[1].overview.id
		g_i3k_game_context:setMarryRoleId(id)
		g_i3k_game_context:setMarryRoleName(name)
		g_i3k_ui_mgr:PopupTipMessage("求婚成功")
		--刷新结婚状态

		g_i3k_game_context:setRecordSteps(g_i3k_game_context:getMarryType() == 1 and 0 or 1)
		--记录结婚等级默认为1级
		g_i3k_game_context:setMarryEveryData("marriageLevel",1)	--记录姻缘等级
		--记录当前时间（当结婚时间戳）
		local curtime = math.modf(i3k_game_get_time())
		g_i3k_game_context:setRecordMarryTime(curtime)
		g_i3k_game_context:AddTaskToDataList(i3k_get_MrgTaskCategory())
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateMrgTask")
		local fun = function (isOk)
			if isOk then
				i3k_sbean.sync_marriage_bespeak()
			end
		end
		local str = string.format("恭喜您与%s喜结连理，是否即刻预约花车游街、新婚喜宴？",name)
		g_i3k_ui_mgr:ShowCustomMessageBox2("立刻预约", "暂不预约", str, fun)
	elseif bean.ok ==2 then
		g_i3k_ui_mgr:PopupTipMessage("求婚失败")
	else
		if res.ok ~= 0 then
			g_i3k_ui_mgr:PopupTipMessage(Errorfun(res.ok, res.errorName))
		end
	end
end

--同步婚姻信息的请求
function i3k_sbean.marryInfo(index, callback)
	local bean = i3k_sbean.marriage_sync_req.new()
	bean.index = index
	bean.callback = callback
	i3k_game_send_str_cmd(bean, i3k_sbean.marriage_sync_res.getName())
end

function i3k_sbean.marriage_sync_res.handler(res, req)
	if res.marriage and next(res.marriage) then
		if req then
		g_i3k_game_context:setMarryData(res.marriage, res.lastTransformTime)
		g_i3k_ui_mgr:CloseUI(eUIID_Marry_Marryed_Yinyuan)
		g_i3k_ui_mgr:CloseUI(eUIID_Marry_Marryed_skills)
		g_i3k_ui_mgr:CloseUI(eUIID_Marry_Marryed_lihun)
		if req.index == 1 then
			g_i3k_ui_mgr:CloseUI(eUIID_MarryAchievement)
			g_i3k_ui_mgr:OpenUI(eUIID_Marry_Marryed_Yinyuan)
			g_i3k_ui_mgr:RefreshUI(eUIID_Marry_Marryed_Yinyuan)
		elseif req.index == 2 then
			g_i3k_ui_mgr:CloseUI(eUIID_MarryAchievement)
			g_i3k_ui_mgr:OpenUI(eUIID_Marry_Marryed_skills)
			g_i3k_ui_mgr:RefreshUI(eUIID_Marry_Marryed_skills)
		elseif req.index == 3 then
			g_i3k_ui_mgr:CloseUI(eUIID_MarryAchievement)
			g_i3k_ui_mgr:OpenUI(eUIID_Marry_Marryed_lihun)
			g_i3k_ui_mgr:RefreshUI(eUIID_Marry_Marryed_lihun)
		elseif req.index == 4 then
			g_i3k_ui_mgr:OpenUI(eUIID_MarryAchievement)
			g_i3k_ui_mgr:RefreshUI(eUIID_MarryAchievement)
		end
		if req.callback then
			req.callback()
			end
		end
	else
		g_i3k_ui_mgr:OpenUI(eUIID_Marry_Unmarried)
		g_i3k_ui_mgr:RefreshUI(eUIID_Marry_Unmarried)
	end
end

function i3k_sbean.role_marriage_step.handler(bean)
	g_i3k_game_context:setRecordSteps(bean.step)
end

--离婚请求
function i3k_sbean.marry_liHun()
	local bean = i3k_sbean.divorce_req.new()
	i3k_game_send_str_cmd(bean, i3k_sbean.divorce_res.getName())
end

function i3k_sbean.divorce_res.handler(res, req)
	if res.ok>0 then
		g_i3k_game_context:UseCommonItem(-g_BASE_ITEM_COIN, i3k_db_marry_rules.divorceCost)
		--步骤为-1
		g_i3k_game_context:setRecordSteps(-1)
		g_i3k_game_context:setMarryRoleId(0)
		g_i3k_game_context:removeTaskData(i3k_get_MrgTaskCategory())
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"removeMrgTask")
		g_i3k_ui_mgr:CloseUI(eUIID_Marry_Marryed_lihun)
		g_i3k_ui_mgr:PopupTipMessage("离婚成功")
	else
		if res.ok ~= 0 then
			g_i3k_ui_mgr:PopupTipMessage(Errorfun(res.ok, res.errorName))
		end
	end
end

--结婚技能升级
function i3k_sbean.skillsLevelup(skillId,skillLevel,times)
	local bean = i3k_sbean.marriage_skill_levelup_req.new()
	bean.skillId = skillId
	bean.skillLevel = skillLevel
	bean.levelupTimes = times
	i3k_game_send_str_cmd(bean, i3k_sbean.marriage_skill_levelup_res.getName())
end

function i3k_sbean.marriage_skill_levelup_res.handler(res, req)
	if res.ok>0 then
		g_i3k_game_context:setMarrySkillsUpgradeData(req.skillId,req.skillLevel,req.levelupTimes)
	else
		g_i3k_ui_mgr:PopupTipMessage(Errorfun(res.ok))	--"结婚技能升级失败:"
	end
end

--传送至配偶请求
function i3k_sbean.sendToLover()
	local bean = i3k_sbean.transform_to_partner_req.new()
	i3k_game_send_str_cmd(bean, i3k_sbean.transform_to_partner_res.getName())
end

function i3k_sbean.transform_to_partner_res.handler(res, req)
	if res.ok>0 then
		local nowServerTime = i3k_integer(i3k_game_get_time())
		g_i3k_game_context:setMarryTransFromTime(nowServerTime)
	else
		if res.ok == 0 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(853))
		else
			g_i3k_ui_mgr:PopupTipMessage(Errorfun(res.ok, res.errorName))
		end
	end
end

--开始游街
function i3k_sbean.beginToParade()
	local bean = i3k_sbean.marriage_start_parade_req.new()
	i3k_game_send_str_cmd(bean, i3k_sbean.marriage_start_parade_res.getName())
end

function i3k_sbean.marriage_start_parade_res.handler(res, req)
	if res.ok>0 then
		g_i3k_ui_mgr:PopupTipMessage("开始游街")
		--刷新结婚状态
		g_i3k_game_context:setRecordSteps(2) --记录开始游街的状态值（npc按钮不可点击） --游街结束以后变为2
	else
		if res.ok ~= 0 then
			g_i3k_ui_mgr:PopupTipMessage(Errorfun(res.ok, res.errorName))
		end
	end
end

--开始宴席请求
function i3k_sbean.sendToBanquet()
	local bean = i3k_sbean.marriage_start_banquet_req.new()
	i3k_game_send_str_cmd(bean, i3k_sbean.marriage_start_banquet_res.getName())
end

function i3k_sbean.marriage_start_banquet_res.handler(res, req)
	if res.ok>0 then
		--刷新结婚状态
		g_i3k_ui_mgr:PopupTipMessage("开始宴席")
		g_i3k_game_context:setRecordSteps(0)
	else
		if res.ok ~= 0 then
			g_i3k_ui_mgr:PopupTipMessage(Errorfun(res.ok, res.errorName))
		end
	end
end

--同步是否在预约状态
function i3k_sbean.role_marriage_bespeak_time.handler(bean)
	if bean.timeIndex then
		g_i3k_game_context:setMarryTimeIndex(bean.timeIndex)
	end
end

--同步预约婚礼数据
function i3k_sbean.sync_marriage_bespeak(isShow)
	local data = i3k_sbean.sync_marriage_bespeak_req.new()
	data.isShow = isShow
	i3k_game_send_str_cmd(data, "sync_marriage_bespeak_res")
end

function i3k_sbean.sync_marriage_bespeak_res.handler(bean, req)
	if bean.bespeaks then
		g_i3k_game_context:cleanMarryReserveData()
		for _,e in ipairs(bean.bespeaks) do
			g_i3k_game_context:setMarryReserveData(e)
		end
		if not req.isShow then
			g_i3k_ui_mgr:OpenUI(eUIID_Marry_reserve)
			g_i3k_ui_mgr:RefreshUI(eUIID_Marry_reserve)
			g_i3k_game_context:SetMarryReserveCueState(false)
		end
	end
end

--添加预约婚礼
function i3k_sbean.add_marriage_bespeak(line, timeIndex,callback)
	local data = i3k_sbean.add_marriage_bespeak_req.new()
	data.line = line
	data.timeIndex = timeIndex
	data.callback = callback
	i3k_game_send_str_cmd(data, "add_marriage_bespeak_res")
end

function i3k_sbean.add_marriage_bespeak_res.handler(bean, req)
	if bean.ok == 1 then
		if req.callback then
			req.callback()
		end
		local tmp = {line = req.line, timeIndex = req.timeIndex,manId = g_i3k_game_context:GetRoleId(),
							ladyId = g_i3k_game_context:getMarryRoleId(),
							manName = g_i3k_game_context:GetRoleName(),
							ladyName = g_i3k_game_context:getMarryRoleName(),
							}
		g_i3k_game_context:setMarryReserveData(tmp)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Marry_reserve, "refreshAllSprite")
		g_i3k_ui_mgr:PopupTipMessage("预约成功")
		g_i3k_game_context:setMarryTimeIndex(req.timeIndex)
	else
		if g_i3k_game_context:getMarryTimeIndex()~=0 then
			g_i3k_ui_mgr:PopupTipMessage("一天只能预约一次，请明天再来~")
		else
			if bean.ok ~= 0 then
				g_i3k_ui_mgr:PopupTipMessage(Errorfun(bean.ok, bean.errorName))
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16367))
			end
		end

	end
end

function i3k_sbean.role_marriage_here.handler(bean)
	if bean.mapId == g_i3k_game_context:GetWorldMapID() and g_i3k_game_context:GetCurrentLine() == bean.line then
		g_i3k_ui_mgr:OpenUI(eUIID_Marry_effects)
		g_i3k_ui_mgr:RefreshUI(eUIID_Marry_effects, bean.grade)
	end
end

--登入or改名
function i3k_sbean.role_marriage_partner_name.handler(bean)
	if bean then
		g_i3k_game_context:setMarryRoleName(bean.name)
	end
end

function i3k_sbean.take_marriage_titleReq(title)
	local data = i3k_sbean.take_marriage_title_req.new()
	data.title = title
	i3k_game_send_str_cmd(data, "take_marriage_title_res")
end

function i3k_sbean.take_marriage_title_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_logic:openRoleTitleUI(req.title)
		g_i3k_ui_mgr:RefreshUI(eUIID_MarriageTitle)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Marry_Marryed_Yinyuan, "updateTitleRed")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_XB, "updateYinyuanRed")
	end
end

function i3k_sbean.marriage_card_signReq(marriageId)
	local data = i3k_sbean.marriage_card_sign_req.new()
	data.marriageId = marriageId
	i3k_game_send_str_cmd(data, "marriage_card_sign_res")
end

function i3k_sbean.marriage_card_sign_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16908))
		g_i3k_game_context:UseCommonItem(i3k_db_common.marriageCardBlessingItemId, 1, AT_SIGN_MARRIAGE_CARD)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_MarriageCertificate,"updateBlessingNum")
	end
end

function i3k_sbean.marriage_card_syncReq(marriageId)
	local data = i3k_sbean.marriage_card_sync_req.new()
	data.marriageId = marriageId
	i3k_game_send_str_cmd(data, "marriage_card_sync_res")
end

function i3k_sbean.marriage_card_sync_res.handler(res, req)
	if res.info then
		g_i3k_ui_mgr:OpenUI(eUIID_MarriageCertificate)
		g_i3k_ui_mgr:RefreshUI(eUIID_MarriageCertificate, res.info, req.marriageId)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16913))
	end
end

--领取姻缘成就奖励
function i3k_sbean.marriage_achieve_receive_reward(gid, seq)
	local data = i3k_sbean.marriage_achieve_receive_reward_req.new()
	data.type = gid
	data.seq = seq
	i3k_game_send_str_cmd(data, "marriage_achieve_receive_reward_res")
end

function i3k_sbean.marriage_achieve_receive_reward_res.handler(res, req)
	if res.ok > 0 then
		local achievementCfg = g_i3k_game_context:getMarryAchievementTask()
		if achievementCfg.taskReward[req.type] and req.seq <= achievementCfg.taskReward[req.type].historyRewardLog then
		else
			local item = {}
			for _, v in ipairs(i3k_db_marry_achievement[req.type][req.seq].rewards) do
				if v.id > 0 and v.count > 0 then
					table.insert(item, v)
				end
			end
			g_i3k_ui_mgr:ShowGainItemInfo(item)
		end
		g_i3k_logic:OpenMarried_achievement()
	else
		g_i3k_ui_mgr:PopupTipMessage("领取失败")
	end
end

--领取姻缘成就累积奖励
function i3k_sbean.marriage_achieve_accumulative_reward(index)
	local data = i3k_sbean.marriage_achieve_accumulative_reward_req.new()
	data.index = index
	i3k_game_send_str_cmd(data, "marriage_achieve_accumulative_reward_res")
end

function i3k_sbean.marriage_achieve_accumulative_reward_res.handler(res, req)
	if res.ok > 0 then
		local item = {}
		if g_i3k_game_context:IsFemaleRole() then
			table.insert(item, {id = i3k_db_marry_achieveRewards[req.index].femaleId, count = i3k_db_marry_achieveRewards[req.index].femaleCount})
		else
			table.insert(item, {id = i3k_db_marry_achieveRewards[req.index].maleId, count = i3k_db_marry_achieveRewards[req.index].maleCount})
		end
		g_i3k_ui_mgr:ShowGainItemInfo(item)
		g_i3k_logic:OpenMarried_achievement()
	else
		g_i3k_ui_mgr:PopupTipMessage("领取失败")
	end
end
-- 姻缘档次提升
function i3k_sbean.marriage_upgrade(grade, costDiamond)
	local data = i3k_sbean.marriage_upgrade_req.new()
	data.grade = grade
	data.costDiamond = costDiamond
	i3k_game_send_str_cmd(data, "marriage_upgrade_res")
end
function i3k_sbean.marriage_upgrade_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:UseDiamond(req.costDiamond, true)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17897))
		g_i3k_ui_mgr:CloseUI(eUIID_MarryUpStage)
	end
end
-- 姻缘档次变化
function i3k_sbean.marriage_grade_sync.handler(bean)
	g_i3k_game_context:setMarryEveryData("marriageType", bean.grade)
end
