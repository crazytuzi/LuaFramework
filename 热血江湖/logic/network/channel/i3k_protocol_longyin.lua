------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")

--------------------------------------------------------
function i3k_sbean.role_sealinfo.handler(bean, res)
	if bean.seal then
		--self.grade:		int32
		--self.skills:		map[int32, int32]
		--self.enhanceCount:		int32
		g_i3k_game_context:SetLongYinInfo(bean.seal.grade, bean.seal.skills, bean.seal.enhanceCount, bean.seal.tempSkills)
		--g_i3k_game_context:SetLongYinSkills(bean.seal.skills)
	end
end
--龙印合成
function i3k_sbean.goto_seal_make(Type, callback)
	local data = i3k_sbean.seal_make_req.new()
	data.makeType = Type
	data.callback = callback
	i3k_game_send_str_cmd(data,"seal_make_res")
end

function i3k_sbean.seal_make_res.handler(bean,req)
	if bean.ok ~= 0 then
		if req.callback then
			req.callback()
		end
		local argData = g_i3k_db.i3k_db_LongYin_arg
		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:SetIsHeChengLongYin(1)
		g_i3k_game_context:RefreshLongyinProps()
		g_i3k_ui_mgr:CloseUI(eUIID_EquipSevenTips2)
		g_i3k_ui_mgr:OpenUI(eUIID_LongYin)
		g_i3k_ui_mgr:RefreshUI(eUIID_LongYin)
		g_i3k_game_context:ShowPowerChange()
		local iconShow, redShow = g_i3k_game_context:TestBagShowState()
		g_i3k_game_context:OnBagShowStateChangedHandler(iconShow, redShow)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bag, "updateWearEquipsData", g_i3k_game_context:GetRoleDetail())
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_RoleLy, "updateWearEquipsData", g_i3k_game_context:GetRoleDetail())
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_RoleLy2, "updateWearEquipsData", g_i3k_game_context:GetRoleDetail())


		local map = {}
		map["龙印"] = 1
		DCEvent.onEvent("龙印合成", map)
	end
end

--龙印升级
function i3k_sbean.goto_seal_upgrade(callback, lvl)
	local data = i3k_sbean.seal_upgrade_req.new()
	if callback then
		data.callback = callback
	end
	if lvl then
		data.lvl = lvl
	end
	i3k_game_send_str_cmd(data,"seal_upgrade_res")
end

function i3k_sbean.seal_upgrade_res.handler(bean,req)
	if bean.ok ~= 0 then
		if req.callback then
			req.callback()
		end
		if req.lvl then
			local level = req.lvl
			g_i3k_game_context:SetIsHeChengLongYin(level)
			local map = {}
			map["龙印"] = tostring(level)
			DCEvent.onEvent("龙印升级", map)
		end
		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:RefreshLongyinProps()
		g_i3k_game_context:refreshAwakenBanProp()
		g_i3k_game_context:ShowPowerChange()
		local iconShow, redShow = g_i3k_game_context:TestBagShowState()
		g_i3k_game_context:OnBagShowStateChangedHandler(iconShow, redShow)
		local UpLvlcfg = g_i3k_db.i3k_db_LongYin_UpLvl
		local lvlNow = g_i3k_game_context:GetIsHeChengLongYin()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_LongYin, "LongYinUpLevel", lvlNow)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_LongYin, "showPower")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bag, "updateWearEquipsData", g_i3k_game_context:GetRoleDetail())
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_RoleLy, "updateWearEquipsData", g_i3k_game_context:GetRoleDetail())
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_RoleLy2, "updateWearEquipsData", g_i3k_game_context:GetRoleDetail())
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FashionDress, "updateWearEquipsData", g_i3k_game_context:GetRoleDetail())
	end
end

--龙印洗练
function i3k_sbean.goto_seal_enhance(callback)
	local data = i3k_sbean.seal_enhance_req.new()
	data.callback = callback
	i3k_game_send_str_cmd(data,"seal_enhance_res")
end

function i3k_sbean.seal_enhance_res.handler(bean,req)
	if req and req.callback then
		g_i3k_game_context:SetNewLongYinSkills(bean.skills)
		if req.callback then
			req.callback()
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_LongYin, "chooseSkills", req.callback)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(406))
		g_i3k_game_context:SetPrePower()
		local skills = bean.skills
		g_i3k_game_context:SetLongYinSkills(skills)
		g_i3k_game_context:ShowPowerChange()
		local iconShow, redShow = g_i3k_game_context:TestBagShowState()
		g_i3k_game_context:OnBagShowStateChangedHandler(iconShow, redShow)
		local argData = g_i3k_db.i3k_db_LongYin_arg
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_LongYin, "LongYinUpSkill", skills, argData)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_LongYin, "showPower")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bag, "updateWearEquipsData", g_i3k_game_context:GetRoleDetail())
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_RoleLy, "updateWearEquipsData", g_i3k_game_context:GetRoleDetail())
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_RoleLy2, "updateWearEquipsData", g_i3k_game_context:GetRoleDetail())
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FashionDress, "updateWearEquipsData", g_i3k_game_context:GetRoleDetail())
	end
end

-- 龙印储存
function i3k_sbean.seal_save_enhance(isSave)
	local data = i3k_sbean.seal_save_enhance_req.new()
	data.isSave = isSave or 0
	i3k_game_send_str_cmd(data,"seal_save_enhance_res")
end

function i3k_sbean.seal_save_enhance_res.handler(bean, req)
	if bean.ok ~= 0 then
		if not req then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(406))
		end
		g_i3k_game_context:SetPrePower()
		local skills = bean.skills
		g_i3k_game_context:SetLongYinSkills(g_i3k_game_context:GetNewLongYinSkills())
		local tmp = {}
		g_i3k_game_context:SetNewLongYinSkills(tmp)
		g_i3k_game_context:ShowPowerChange()
		local iconShow, redShow = g_i3k_game_context:TestBagShowState()
		g_i3k_game_context:OnBagShowStateChangedHandler(iconShow, redShow)
		local argData = g_i3k_db.i3k_db_LongYin_arg
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_LongYin, "LongYinUpSkill", skills, argData)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_LongYin, "showPower")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Bag, "updateWearEquipsData", g_i3k_game_context:GetRoleDetail())
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_RoleLy, "updateWearEquipsData", g_i3k_game_context:GetRoleDetail())
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_RoleLy2, "updateWearEquipsData", g_i3k_game_context:GetRoleDetail())
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FashionDress, "updateWearEquipsData", g_i3k_game_context:GetRoleDetail())
		DCEvent.onEvent("龙印洗练", map)
	end
end

--------魂玉二期解封需求----------
-- 登陆同步魂玉解封信息
function i3k_sbean.role_seal_awaken.handler(bean)
	if bean.info then
		g_i3k_game_context:setRoleSealAwaken(bean.info)
		g_i3k_game_context:refreshAwakenBanProp()
	end
end
-- 魂玉解封
function i3k_sbean.seal_dispelling(index, gift, useItems)
	local data = i3k_sbean.seal_dispelling_req.new()
	data.index = index
	data.gift = gift
	data.useItems = useItems
	i3k_game_send_str_cmd(data,"seal_dispelling_res")
end
function i3k_sbean.seal_dispelling_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:addRoleSealAwakenId(req.index)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_LongYin, "updateLongyinRightView")
		g_i3k_ui_mgr:PopupTipMessage("解封成功")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_UnlockHunyu, "unlockCallback", req.useItems)
		g_i3k_ui_mgr:ShowGainItemInfo(req.gift)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_LongYin, "checkAllUnlock")
		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:refreshAwakenBanProp()
		g_i3k_game_context:ShowPowerChange()
		g_i3k_ui_mgr:CloseUI(eUIID_UnlockHunyu)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_LongYin, "showPower")
	end
end
-- 魂玉解封晋级
function i3k_sbean.seal_awaken()
	local data = i3k_sbean.seal_awaken_req.new()
	i3k_game_send_str_cmd(data,"seal_awaken_res")
end
function i3k_sbean.seal_awaken_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("精修成功")
		g_i3k_game_context:clearRoleSealAwaken()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_LongYin, "updateJinZhiUI")
		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:refreshAwakenBanProp()
		g_i3k_game_context:ShowPowerChange()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_LongYin, "showPower")
	end
end
-- 魂玉解封晋级加速
function i3k_sbean.seal_awaken_accelerate(itemNum)
	local data = i3k_sbean.seal_awaken_accelerate_req.new()
	data.itemNum = itemNum
	i3k_game_send_str_cmd(data,"seal_awaken_accelerate_res")
end
function i3k_sbean.seal_awaken_accelerate_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("加速成功")
		local needItemID = i3k_db_LongYin_arg.hunyuWenyang.needItemID
		g_i3k_game_context:UseCommonItem(needItemID, req.itemNum, AT_REST_ACCELERATE)--UseBagItem
		local deltTime = req.itemNum * i3k_db_LongYin_arg.hunyuWenyang.time
		g_i3k_game_context:speedUpAwaken(deltTime)
		g_i3k_ui_mgr:CloseUI(eUIID_longyinSpeedup)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_LongYin, "updateTimeLabel")
	else
		g_i3k_ui_mgr:PopupTipMessage("加速失败"..req.itemNum)
	end
end


--------------魂玉附灵---------------------
-- 登陆同步
function i3k_sbean.seal_given_spirit_sync.handler(res, req)
	local data = res.roleSealGivenSpirit
	g_i3k_game_context:setFulingInfo(data)
end

-- 附灵升阶
function i3k_sbean.fulingUplvl(nextLevel)
	local data = i3k_sbean.seal_given_spirit_uplvl_req.new()
	data.nextLvl = nextLevel
	i3k_game_send_str_cmd(data, "seal_given_spirit_uplvl_res")
end
function i3k_sbean.seal_given_spirit_uplvl_res.handler(res, req)
	if res.ok > 0 then
		if res.ok == 1 then -- 失败（概率）
			g_i3k_ui_mgr:PopupTipMessage("附灵失败")
			local level = req.nextLvl
			local consumes = g_i3k_db.i3k_db_get_fuling_consumes(level)
			for k, v in ipairs(consumes) do
				g_i3k_game_context:UseCommonItem(v.id, v.count, AT_SGS_UP_LVL)
			end
			g_i3k_game_context:addFulingUpTimes()
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_LongYin, "initFuling")

		elseif res.ok == 2 then -- 成功
			g_i3k_ui_mgr:PopupTipMessage("附灵成功")
			local level = req.nextLvl
			local consumes = g_i3k_db.i3k_db_get_fuling_consumes(level)
			for k, v in ipairs(consumes) do
				g_i3k_game_context:UseCommonItem(v.id, v.count, AT_SGS_UP_LVL)
			end
			g_i3k_game_context:fulingUpLevel()
			g_i3k_game_context:resetFulingUpTimes()
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_LongYin, "initFuling")
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_LongYin, "starAnimation")
			-- 刷新属性战力
			g_i3k_game_context:SetPrePower()
			g_i3k_game_context:RefreshLongyinProps()
			g_i3k_game_context:ShowPowerChange()
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("未知问题")
	end
end

-- 附灵加点
function i3k_sbean.fulingAddPoint(group, value)
	local data = i3k_sbean.seal_given_spirit_addpoint_req.new()
	data.group = group
	data.value = value
	i3k_game_send_str_cmd(data, "seal_given_spirit_addpoint_res")
end
function i3k_sbean.seal_given_spirit_addpoint_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("加点成功")
		g_i3k_game_context:addWuxingPoint(req.group, req.value)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FulingAddPoint, "refreshWithoutID")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_LongYin, "initFuling")
		-- 刷新属性战力
		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:RefreshLongyinProps()
		g_i3k_game_context:ShowPowerChange()
	else
		g_i3k_ui_mgr:PopupTipMessage("加点失败")
	end
end

-- 附灵五星相生 升级
function i3k_sbean.fulingWuxingUplvl(group, lvl, consumes)
	local data = i3k_sbean.seal_given_spirit_upeachotheruplvl_req.new()
	data.group = group
	data.lvl = lvl
	data.consumes = consumes
	i3k_game_send_str_cmd(data, "seal_given_spirit_upeachotheruplvl_res")
end
function i3k_sbean.seal_given_spirit_upeachotheruplvl_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("升级成功")
		g_i3k_game_context:addXiangshengPoint(req.group, 1)
		local consumes = req.consumes
		for k, v in ipairs(consumes) do
			g_i3k_game_context:UseCommonItem(v.id, v.count, AT_SGS_UP_EACH_OHER)
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FulingUpLevel, "refreshWithoutArgs")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_LongYin, "initFuling")
		-- 刷新属性战力
		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:RefreshLongyinProps()
		g_i3k_game_context:ShowPowerChange()

	else
		g_i3k_ui_mgr:PopupTipMessage("升级失败")
	end
end

-- 附灵重置加点
function i3k_sbean.fulingResetPoint(consumes, gets)
	local data = i3k_sbean.seal_given_spirit_resetPoint_req.new()
	data.consumes = consumes
	data.gets = gets
	i3k_game_send_str_cmd(data, "seal_given_spirit_resetPoint_res")
end
function i3k_sbean.seal_given_spirit_resetPoint_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("重置成功")
		g_i3k_ui_mgr:CloseUI(eUIID_FulingReset)
		g_i3k_game_context:addFulingResetTimes()
		g_i3k_game_context:resetFulingAll()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_LongYin, "initFuling")
		local consumes = req.consumes
		for k, v in ipairs(consumes) do
			g_i3k_game_context:UseCommonItem(v.id, v.count, AT_SGS_RESET_ADDPOINT)
		end
		if #req.gets ~= 0 then
			g_i3k_ui_mgr:ShowGainItemInfo(req.gets)
		end
		-- 刷新属性战力
		g_i3k_game_context:SetPrePower()
		i3k_game_context:RefreshLongyinProps()
		g_i3k_game_context:ShowPowerChange()

	else
		g_i3k_ui_mgr:PopupTipMessage("重置失败")
	end
end
-- 购买附灵加点
function i3k_sbean.seal_given_spirit_buy_point(consumes)
	local data = i3k_sbean.seal_given_spirit_buy_point_req.new()
	data.consumes = consumes
	i3k_game_send_str_cmd(data, "seal_given_spirit_buy_point_res")
end
function i3k_sbean.seal_given_spirit_buy_point_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17735))
		local consumes = req.consumes
		for k, v in ipairs(consumes) do
			g_i3k_game_context:UseCommonItem(v.id, v.count, "")
		end
		g_i3k_game_context:AddFulingBuyPointsCnt()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_LongYin, "initFuling")
		local curBuyPointsCnt = g_i3k_game_context:GetFulingBuyPointsCnt()
		if curBuyPointsCnt < #i3k_db_longyin_sprite_buy_point then
			g_i3k_ui_mgr:RefreshUI(eUIID_BuyFulingPoint)
		else
			g_i3k_ui_mgr:CloseUI(eUIID_BuyFulingPoint)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17736))
	end
end
-----------------------------------
