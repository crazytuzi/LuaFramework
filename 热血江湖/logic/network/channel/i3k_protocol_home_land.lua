------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")

----------------------------------------------------
local ErrorCode = {
	[-1] = i3k_get_string(5076), --家园访客进入数量已达最大
	[-2] = i3k_get_string(5077), --没有创建家园
	[-3] = i3k_get_string(5078), --刚刚被请离家园
	[-4] = i3k_get_string(5030), --名字非法
	[-5] = i3k_get_string(43), --背包不足
	[-6] = i3k_get_string(5146), --植物状态不符
	[-7] = i3k_get_string(5095), -- 不是互为好友
	[-8] = "房屋人数已达上限", --房屋上限
	[-9] = i3k_get_string(17411), --钓鱼上限提示
	[-10] = i3k_get_string(17412), -- 偷菜上限提示
}

--相关错误码提示
local function HomeLandErrorCode(result)
	if ErrorCode[result] then
		g_i3k_ui_mgr:PopupTipMessage(ErrorCode[result])
	else
		if result then
			g_i3k_ui_mgr:PopupTipMessage("无效错误码："..result)
		end
	end
end

-- 家园创建
function i3k_sbean.homeland_create(name, needItems)
	local bean = i3k_sbean.homeland_create_req.new()
	bean.name = name
	bean.needItems = needItems
	i3k_game_send_str_cmd(bean, "homeland_create_res")
end

function i3k_sbean.homeland_create_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:SetHomeLandLevel(1) --家园创建成功默认1级
		g_i3k_game_context:UseCommonItem(req.needItems.itemID, req.needItems.itemCount, AT_HOMELAND_CREATE)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5079))
		g_i3k_ui_mgr:CloseUI(eUIID_HomeLandCreate)
		i3k_sbean.homeland_sync(true)
	else
		HomeLandErrorCode(bean.ok)
	end
end

-- 登陆同步家园信息
function i3k_sbean.homeland_login_sync.handler(bean)
	g_i3k_game_context:SetHomeLandLevel(bean.level)
	g_i3k_game_context:SetHomeLandPlantLevel(bean.plantLevel)
	g_i3k_game_context:SetHomeLandCurEquip(bean.curEquips)
	-- 同步种植等级数据
end

-- 登陆同步钓鱼状态 
function i3k_sbean.role_homeland_fish_status.handler(bean)
	-- g_i3k_game_context:SetHomeLandFishStatus(true) --废弃 不做处理每次登陆都钓鱼重新开始
end

-- 同步家园信息
function i3k_sbean.homeland_sync(isOpenUI, callback)
	local data = i3k_sbean.homeland_sync_req.new()
	data.isOpenUI = isOpenUI
	data.callback = callback
	i3k_game_send_str_cmd(data, "homeland_sync_res")
end

function i3k_sbean.homeland_sync_res.handler(bean, req)
	g_i3k_game_context:updateMyHomeLandData(bean.homeland)
	if req.isOpenUI and g_i3k_game_context:hasHomeLand(true) then
		g_i3k_ui_mgr:CloseUI(eUIID_HomeLandEvent)
		g_i3k_ui_mgr:CloseUI(eUIID_HomeLandEquipBag)
		g_i3k_ui_mgr:CloseUI(eUIID_HomeLandStructure)
		g_i3k_ui_mgr:OpenUI(eUIID_HomeLandMain)
		g_i3k_ui_mgr:RefreshUI(eUIID_HomeLandMain, bean.homeland)
	end
	if req.callback then
		req.callback()
	end
end

-- 同步家园装备信息
function i3k_sbean.homeland_equip_sync(fishType, fishInit)
	local data = i3k_sbean.homeland_equip_sync_req.new()
	data.fishType = fishType
	data.fishInit = fishInit
	i3k_game_send_str_cmd(data, "homeland_equip_sync_res")
end

function i3k_sbean.homeland_equip_sync_res.handler(bean, req)
	g_i3k_ui_mgr:CloseUI(eUIID_HomeLandEvent)
	g_i3k_ui_mgr:CloseUI(eUIID_HomeLandMain)
	g_i3k_ui_mgr:CloseUI(eUIID_HomeLandStructure)
	g_i3k_game_context:SetHomeLandEquip(bean.homelandEquip)
	if req.fishInit then
		return
	end
	if req.fishType then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_HomeLandFish, "loadShortcutScroll", req.fishType)
	else
		g_i3k_ui_mgr:OpenUI(eUIID_HomeLandEquipBag)
		g_i3k_ui_mgr:RefreshUI(eUIID_HomeLandEquipBag, bean.homelandEquip)
	end
end

-- 同步家园历史信息
function i3k_sbean.homeland_history_sync(uiID)
	local data = i3k_sbean.homeland_history_sync_req.new()
	data.uiID = uiID
	i3k_game_send_str_cmd(data, "homeland_history_sync_res")
end

function i3k_sbean.homeland_history_sync_res.handler(bean, req)
	if bean.historys then
		if req.uiID then
			g_i3k_ui_mgr:CloseUI(req.uiID)
		end
		g_i3k_ui_mgr:OpenUI(eUIID_HomeLandEvent)
		g_i3k_ui_mgr:RefreshUI(eUIID_HomeLandEvent, bean.historys)
	end
end

-- 家园改名
function i3k_sbean.homeland_rename(name)
	local bean = i3k_sbean.homeland_rename_req.new()
	bean.name = name
	i3k_game_send_str_cmd(bean, "homeland_rename_res")
end

function i3k_sbean.homeland_rename_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:UseDiamond(i3k_db_home_land_base.baseCfg.changeNameItemCnt, false, AT_HOMELAND_RENAME)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_HomeLandMain, "updateHomeLandName", req.name)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5080))
		g_i3k_ui_mgr:CloseUI(eUIID_HomeLandChangeName)
	else
		HomeLandErrorCode(bean.ok)
	end
end

-- 家园升级
function i3k_sbean.homeland_uplevel(level, costItems, nodeData)
	if level and level > #i3k_db_home_land_lvl then 
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5081, #i3k_db_home_land_lvl))
		return
	end
	local bean = i3k_sbean.homeland_uplevel_req.new()
	bean.level = level
	bean.costItems = costItems 
	bean.nodeData = nodeData
	i3k_game_send_str_cmd(bean, "homeland_uplevel_res")
end

function i3k_sbean.homeland_uplevel_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5082, req.level))
		g_i3k_game_context:SetHomeLandLevel(req.level)
		g_i3k_game_context:UseCommonItems_safe(req.costItems, AT_HOMELAND_UPLEVEL)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_HomeLandStructure, "onHomelandLevelUp", req)
	else
		HomeLandErrorCode(bean.ok)
	end
end

-- 家园土地升级
function i3k_sbean.homeland_ground_uplevel(typeId, index, level, costItems, nodeData)
	local bean = i3k_sbean.homeland_ground_uplevel_req.new()
	bean.type = typeId
	bean.index = index
	bean.level = level 
	bean.costItems = costItems
	bean.nodeData = nodeData
	i3k_game_send_str_cmd(bean, "homeland_ground_uplevel_res")
end

function i3k_sbean.homeland_ground_uplevel_res.handler(bean, req)
	if bean.ok == 1 then
		req.nodeData.level = req.level
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5083, req.level))
		g_i3k_game_context:UseCommonItems_safe(req.costItems, AT_HOMELAND_GROUND_UPLEVEL)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_HomeLandStructure, "onGroundLevelUp", req)
	else
		HomeLandErrorCode(bean.ok)
	end
end

-- 家园池塘升级
function i3k_sbean.homeland_pool_uplevel(level, costItems, nodeData)
	local bean = i3k_sbean.homeland_pool_uplevel_req.new()
	bean.level = level
	bean.costItems = costItems
	bean.nodeData = nodeData
	i3k_game_send_str_cmd(bean, "homeland_pool_uplevel_res")
end

function i3k_sbean.homeland_pool_uplevel_res.handler(bean, req)
	if bean.ok == 1 then
		req.nodeData.poolLevel = req.level
		g_i3k_game_context:UseCommonItems_safe(req.costItems, AT_HOMELAND_POOL_UPLEVEL)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_HomeLandStructure, "onPoolLevelUp", req)
	else
		HomeLandErrorCode(bean.ok)
	end
end

-- 种植作物
function i3k_sbean.homeland_plant(plantType, index, plantId, costItems)
	local bean = i3k_sbean.homeland_plant_req.new()
	bean.type = plantType
	bean.index = index
	bean.plantId = plantId	
	bean.costItems = costItems
	i3k_game_send_str_cmd(bean, "homeland_plant_res")
end

function i3k_sbean.homeland_plant_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:UseHomeLandCurEquip(g_HOMELAND_WEAPON_EQUIP)
		g_i3k_game_context:UseCommonItems(req.costItems, AT_HOMELAND_PLANT)
	else
		HomeLandErrorCode(bean.ok)
	end
end

-- 铲除作物
function i3k_sbean.homeland_remove_plant(plantType, index)
	local bean = i3k_sbean.homeland_remove_req.new()
	bean.type = plantType
	bean.index = index
	i3k_game_send_str_cmd(bean, "homeland_remove_res")
end

function i3k_sbean.homeland_remove_res.handler(bean)
	if bean.ok == 1 then

	else
		HomeLandErrorCode(bean.ok)
	end
end

-- 偷窃作物
function i3k_sbean.homeland_steal(plantType, index, ground)
	local bean = i3k_sbean.homeland_steal_req.new()
	bean.type = plantType
	bean.index = index
	bean.ground = ground
	i3k_game_send_str_cmd(bean, "homeland_steal_res")
end

function i3k_sbean.homeland_steal_res.handler(bean, req)
	--self.num:		int32	
	--self.extGet:		DummyGoods
	if bean.num > 0 then
		local item = {id = req.ground._plantCfg.getItemID, count = bean.num}
		table.insert(bean.extGet, item)
		g_i3k_ui_mgr:ShowGainItemInfo_safe(bean.extGet)
		g_i3k_game_context:onHomelandSteal()
	else
		HomeLandErrorCode(bean.num)
	end
end

-- 收获作物
function i3k_sbean.homeland_harvest(plantType, index, ground, petId)
	local bean = i3k_sbean.homeland_harvest_req.new()
	bean.type = plantType
	bean.index = index
	bean.petId = petId
	bean.ground = ground
	i3k_game_send_str_cmd(bean, "homeland_harvest_res")
end

function i3k_sbean.homeland_harvest_res.handler(bean, req)
	-- self.num:		int32	
	-- self.extGet:		DummyGoods	
	-- self.lastTime 
	if bean.num > 0 then
		local item = {id = req.ground._plantCfg.getItemID, count = bean.num}
		table.insert(bean.extGet, item)
		g_i3k_ui_mgr:ShowGainItemInfo_safe(bean.extGet)
		if req.petId > 0 then
			g_i3k_game_context:AddExtraHarvestTimes(req.petId)
		end
	else
		HomeLandErrorCode(bean.num)
	end
	-- g_i3k_ui_mgr:PopupTipMessage(string.format("成熟剩余时间%s", bean.lastTime))
end

-- 进入家园
function i3k_sbean.homeland_enter(roleId)
	--	assert(roleID ~= nil, "error:function homeland_enter playerId is nil!")
	if i3k_check_resources_downloaded(i3k_db_home_land_base.baseCfg.sceneId) then
		local bean = i3k_sbean.homeland_enter_req.new()
		bean.roleId = roleId
		i3k_game_send_str_cmd(bean, "homeland_enter_res")
	end
end

function i3k_sbean.homeland_enter_res.handler(bean, req)
	if bean.ok > 0 then
		i3k_sbean.homeland_sync(false) -- 暂时写在这里，获取一次自己家园协议
	else
		local roleID = req.roleId
		if bean.ok == -2 then
			if not g_i3k_game_context:isRoleSelf(roleID) then 
				local str = ""
				if g_i3k_game_context:checkIsLover(roleID) then  
					str = i3k_get_string(5085)
				elseif g_i3k_game_context:CheckIsMaster(roleID) then 
					str = i3k_get_string(5086)
				elseif g_i3k_game_context:CheckIsStudent(roleID) then 
					str = "您的徒弟没有购置家园"
				else
					str = "对方没有购置家园"
				end
				if str then 
					g_i3k_ui_mgr:PopupTipMessage(str)
					return 
				end 
			end
		elseif bean.ok < 0 then
			HomeLandErrorCode(bean.ok)
		else 
			g_i3k_game_context:gotoPlayerHomeLandError(roleID)
		end
	end
end

function i3k_sbean.homeland_enter_res.errorTips()
	
end 

-- 作物浇水
function i3k_sbean.homeland_water(cropType, index)
	local bean = i3k_sbean.homeland_water_req.new()
	bean.type = cropType
	bean.index = index
	i3k_game_send_str_cmd(bean, "homeland_water_res")
end

function i3k_sbean.homeland_water_res.handler(bean)
	if bean.ok == 1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5087))
	else
		HomeLandErrorCode(bean.ok)
	end
end

-- 作物护理
function i3k_sbean.homeland_nurse(cropType, index, nurseTimes)
	local bean = i3k_sbean.homeland_nurse_req.new()
	bean.type = cropType 
	bean.index = index
	bean.nurseTimes = nurseTimes
	i3k_game_send_str_cmd(bean, "homeland_nurse_res")
end

function i3k_sbean.homeland_nurse_res.handler(bean, req)
	if bean.ok == 1 then
		local strCfg = {5088, 5089, 5090}
		if strCfg[req.nurseTimes] then 
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(strCfg[req.nurseTimes]))
		end
	else
		HomeLandErrorCode(bean.ok)
	end
end

-- 钓鱼状态改变
function i3k_sbean.homeland_fish_status_change(isFishing)
	local bean = i3k_sbean.homeland_fish_status_change_req.new()
	bean.isFishing = isFishing
	i3k_game_send_str_cmd(bean, "homeland_fish_status_change_res")
end

function i3k_sbean.homeland_fish_status_change_res.handler(bean, req)
	if bean.ok == 1 then
		i3k_sbean.homeland_equip_sync(nil, true) --初始化家园装备
		g_i3k_game_context:SetHomeLandFishStatus(req.isFishing, bean)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Chat,"checkActionBtnStatus")
		g_i3k_ui_mgr:CloseUI(eUIID_SocialAction)
	end
end

-- 开始钓鱼
function i3k_sbean.homeland_start_fish(rotation, heroPos, facePos)
	local data = i3k_sbean.homeland_start_fish_req.new()
	data.rotation = i3k_sbean.Vector3.new()
	data.rotation.x = rotation.x
	data.rotation.y = rotation.y
	data.rotation.z = rotation.z
	data.heroPos	= heroPos
	data.facePos 	= facePos
	i3k_game_send_str_cmd(data, "homeland_start_fish_res")
end

function i3k_sbean.homeland_start_fish_res.handler(bean, req)
	if bean.fishTime >= 0 then
		local hero = i3k_game_get_player_hero()
		local rot_y = i3k_vec3_angle1(req.facePos, req.heroPos, { x = 1, y = 0, z = 0 });
		if hero then
			hero:SetFaceDir(0, rot_y, 0);
			hero:PlayStartFishAct()
		end
		--记录鱼漂时间
		g_i3k_game_context:SetHomeLandFishTime(bean.fishTime + i3k_game_get_time())
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_HomeLandFish, "randomFishSlider")--开始钓鱼重新刷新随机滑块
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_HomeLandFish, "loadSliderWidget", true) 
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_HomeLandFish, "updateFishBtnImage", g_THROW_STATE)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_HomeLandFish, "loadFishTagetDesc", 5120)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_HomeLandFish, "updateFishBtnState", false)
		-- g_i3k_ui_mgr:PopupTipMessage("开始钓鱼啦")
	else
		HomeLandErrorCode(bean.fishTime)
	end
end

-- 中断钓鱼
function i3k_sbean.homeland_stop_fish()
	local bean = i3k_sbean.homeland_stop_fish_req.new()
	i3k_game_send_str_cmd(bean, "homeland_stop_fish_res")
end

function i3k_sbean.homeland_stop_fish_res.handler(bean)
	if bean.ok == 1 then
		g_i3k_game_context:SetHomeLandFishTime(0)
	end
end

-- 结束钓鱼
function i3k_sbean.homeland_finish_fish(index, isAuto)
	local data = i3k_sbean.homeland_finish_fish_req.new()
	data.index = index
	data.isAuto = isAuto
	i3k_game_send_str_cmd(data, "homeland_finish_fish_res")
end

function i3k_sbean.homeland_finish_fish_res.handler(bean, req)
	if bean.ok == 1 then
		-- 使用鱼钩 鱼饵
		g_i3k_game_context:UseHomeLandFishEquip()
		g_i3k_game_context:setHomeLandFishExpCount(g_i3k_game_context:getHomeLandFishExpCount() + 1)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_HomeLandFish, "refreshFishAndExpCount")
		if req.isAuto then
			local reward = ""
			for _, v in ipairs(bean.fishReward) do
				reward = reward..g_i3k_db.i3k_db_get_common_item_name(v.id).."*"..v.count.." "
			end
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5370, reward))
		else
			g_i3k_ui_mgr:ShowGainItemInfo_safe(bean.fishReward)
		end
		local hero = i3k_game_get_player_hero()
		if hero then
			hero:PlayEndFishAct()
		end
	end
end

function i3k_sbean.homeland_fish_end.handler()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_HomeLandFish, "playTipsAnis", false)
	g_i3k_game_context:UseHomeLandFishEquip()
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5123))
	local hero = i3k_game_get_player_hero()
	if hero then
		local alist = {}
		table.insert(alist, {actionName = i3k_db_home_land_base.fishActCfg.actUnhook, actloopTimes = 1})
		table.insert(alist, {actionName = i3k_db_home_land_base.fishActCfg.actStand, actloopTimes = -1})
		hero:PlayActionList(alist, 1)
		local net_log = i3k_get_net_log()
		net_log:Add("zh-endFish")
	end
end

-- 穿戴装备
function i3k_sbean.homeland_equip_wear(id, equip, isShortcut, callback)
	local bean = i3k_sbean.homeland_equip_wear_req.new()
	bean.id = id
	bean.equip = equip
	bean.isShortcut = isShortcut
	bean.callback = callback
	i3k_game_send_str_cmd(bean, "homeland_equip_wear_res")
end

function i3k_sbean.homeland_equip_wear_res.handler(bean, req)
	if bean.ok == 1 then
		if req then
			g_i3k_ui_mgr:CloseUI(eUIID_HomeLandEquipTips)
			local equipInfo = g_i3k_game_context:GetHomeLandCurEquip()
			local cfg = g_i3k_db.i3k_db_get_homeLandEquipCfg(req.equip.confId)
			local oldEquip = equipInfo[cfg.equipType]
			if oldEquip then --如果有装备替换
				g_i3k_game_context:AddHomeLandEquipBag(oldEquip.id, oldEquip)
			end
			g_i3k_game_context:RemoveHomeLandEquipBag(req.id)
			g_i3k_game_context:WearHomeLandCurEquip(cfg.equipType, req.equip) -- 设置当前正在装备的装备
			if g_i3k_game_context:GetIsInHomeLandZone() then
				local hero = i3k_game_get_player_hero()
				if hero then
					hero:DetachHomeLandEquip() --先卸载然后再穿上蒙皮
					hero:AttachHomeLandCurEquip(g_i3k_game_context:GetHomeLandCurEquip())
					if req.isShortcut then --快捷更换钓鱼装备模型 先移除再重新挂载
						hero:UnloadHomeLandFishModel() 
						hero:LinkHomeLandFishModel(g_i3k_game_context:GetHomeLandCurEquip(), g_i3k_game_context:GetRoleId())
					end
				end
			end
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_HomeLandEquipBag, "loadWearEquip")
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_HomeLandEquipBag, "loadEquipScroll")
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_HomeLandEquipBag, "updateRecover")
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_HomeLandFish, "isShowShortcutRoot", false)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_HomeLandFish, "resetShortcutState") --重置快捷使用状态
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_HomeLandFish, "loadFishEquipInfo")
			-- g_i3k_ui_mgr:PopupTipMessage("装备家园装备成功")
		end
		
	else
		HomeLandErrorCode(bean.ok)
		if req.callback and req.callback.fail then
			req.callback.fail()
		end
	end
end

-- 脱下装备
function i3k_sbean.homeland_equip_unwaer(equipType)
	local bean = i3k_sbean.homeland_equip_unwaer_req.new()
	bean.type = equipType
	i3k_game_send_str_cmd(bean, "homeland_equip_unwaer_res")
end

function i3k_sbean.homeland_equip_unwaer_res.handler(bean, req)
	if bean.ok == 1 then
		if req then
			g_i3k_ui_mgr:CloseUI(eUIID_HomeLandEquipTips)
			local equipInfo = g_i3k_game_context:GetHomeLandCurEquip()
			local info = equipInfo[req.type]
			if info then
				g_i3k_game_context:AddHomeLandEquipBag(info.id, info)
				g_i3k_game_context:DownWearHomeLandCurEquip(req.type)
				if g_i3k_game_context:GetIsInHomeLandZone() then
					local cfg = g_i3k_db.i3k_db_get_homeLandEquipCfg(info.confId)
					if cfg and cfg.skinID ~= 0 then
						local hero = i3k_game_get_player_hero()
						if hero then
							hero:DetachHomeLandEquip()
						end
					end
				end
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_HomeLandEquipBag, "loadWearEquip")
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_HomeLandEquipBag, "loadEquipScroll")
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_HomeLandEquipBag, "updateRecover")
			end
			-- g_i3k_ui_mgr:PopupTipMessage("成功脱下家园装备")
		end
	else
		HomeLandErrorCode(bean.ok)
	end
end

-- 销毁装备
function i3k_sbean.homeland_equip_remove(id)
	local data = i3k_sbean.homeland_equip_remove_req.new()
	data.id = id
	i3k_game_send_str_cmd(data, "homeland_equip_remove_res")
end

function i3k_sbean.homeland_equip_remove_res.handler(bean, req)
	if bean.ok == 1 then
		if req then
			g_i3k_ui_mgr:CloseUI(eUIID_HomeLandEquipTips)
			g_i3k_game_context:RemoveHomeLandEquipBag(req.id)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_HomeLandEquipBag, "loadEquipScroll")
			-- g_i3k_ui_mgr:PopupTipMessage("成功销毁家园装备")
		end
	else
		HomeLandErrorCode(bean.ok)
	end
end

-- 踢出角色
function i3k_sbean.homeland_kick_role(id)
	local data = i3k_sbean.homeland_kick_role_req.new()
	data.id = id
	i3k_game_send_str_cmd(data, "homeland_kick_role_res")
end

function i3k_sbean.homeland_kick_role_res.handler(bean, req)
	if bean.ok == 1 then
		-- g_i3k_ui_mgr:PopupTipMessage("成功请离")
	else
		HomeLandErrorCode(bean.ok)
	end
end

-- 家园玩家数据
function i3k_sbean.homeland_query_roles()
	local data = i3k_sbean.homeland_query_roles_req.new()
	data.id = g_i3k_game_context:GetRoleId()
	i3k_game_send_str_cmd(data, "homeland_query_roles_res")
end

function i3k_sbean.homeland_query_roles_res.handler(bean, req)
	g_i3k_game_context:setHomeLandPlayers(bean.roles)
	g_i3k_ui_mgr:RefreshUI(eUIID_HomelandCustomer)
end

-- 异步 --
-- 进入家园同步
function i3k_sbean.homeland_map_sync.handler(bean)
	--self.roleId:		int32	
	--self.homeland:		HomelandMapInfo
	i3k_sbean.homeland_sync(false) -- 暂时写在这里，获取一次自己家园协议
	g_i3k_game_context:updateHomelandMap(bean.homeland, bean.roleId)
	g_i3k_logic:OpenHomelandCustomersUI()
end
	
-- 地图内土地收到操作
function i3k_sbean.homeland_ground_operate.handler(bean)
	--self.type:		int32	
	--self.index:		int32	
	--self.operateType:		int32	1偷窃土地 2浇水 3护理 4种植 5土地升级 6收获 7移除
	--self.args:		int32 0错误 1幼苗 2健壮 3成熟 -- 土地升级的话就是土地等级
	--g_i3k_ui_mgr:PopupTipMessage(string.format("--debug--家园操作操作类型%s,植物状态%s", bean.operateType, bean.arg1))
	if g_i3k_game_context:GetIsInHomeLandZone() then
		local world = i3k_game_get_world()
		if world then
			world:onItemCropOperate(bean.type, bean.index, bean.operateType, bean.args[1], bean.args[2])
		end
	end
end

-- 被踢推送
function i3k_sbean.homeland_kick_role_push.handler(bean)
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5091))
end

--家具生产
function i3k_sbean.homeland_produce(produce)
	local data = i3k_sbean.homeland_produce_req.new()
	data.produceId = produce.id
	data.needItems = produce.need_items
	i3k_game_send_str_cmd(data, "homeland_produce_res")
end

function i3k_sbean.homeland_produce_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("生产成功")
		for k, v in ipairs(req.needItems) do
			if v.id > 0 then
				g_i3k_game_context:UseCommonItem(v.id, v.count)
			end
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_HomeLandProduce, "updateProduceData")
	else
		g_i3k_ui_mgr:PopupTipMessage("生产失败")
	end
end

--房屋升级
function i3k_sbean.homeland_house_uplevel(level, needItems)
	local data = i3k_sbean.homeland_house_uplevel_req.new()
	data.level = level
	data.needItems = needItems
	i3k_game_send_str_cmd(data, "homeland_house_uplevel_res")
end

function i3k_sbean.homeland_house_uplevel_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("升级成功")
		g_i3k_game_context:SetHomeLandHouseLevel(req.level)
		g_i3k_game_context:UseCommonItems_safe(req.needItems, AT_HOMELAND_UPLEVEL)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_HomeLandStructure, "updateHouseUpLevel", req.level)
	else
		g_i3k_ui_mgr:PopupTipMessage("升级失败")
	end
end

--家具存入背包
function i3k_sbean.furniture_bag_put(id, num, furnitureType, itemId)
	local data = i3k_sbean.furniture_bag_put_req.new()
	data.id = id
	data.num = num
	data.type = furnitureType
	data.itemId = itemId
	i3k_game_send_str_cmd(data, "furniture_bag_put_res")
end

function i3k_sbean.furniture_bag_put_res.handler(res, req)
	if res.ok > 0 then
		if g_i3k_game_context:GetIsInHomeLandHouse() then
			g_i3k_game_context:addFurniture(req.id, req.num, req.type)
		end
		g_i3k_game_context:UseCommonItem(req.itemId, req.num)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17729))
	else
		g_i3k_ui_mgr:PopupTipMessage("存入失败")
	end
end

--家具取出背包
function i3k_sbean.furniture_bag_get(id, num, furnitureType)
	local data = i3k_sbean.furniture_bag_get_req.new()
	data.id = id
	data.num = num
	data.type = furnitureType
	i3k_game_send_str_cmd(data, "furniture_bag_get_res")
end

function i3k_sbean.furniture_bag_get_res.handler(res, req)
	if res.ok > 0 then
		if g_i3k_game_context:GetIsInHomeLandHouse() then
			g_i3k_game_context:useFurniture(req.id, req.num, req.type)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_HouseFurniture, "updateFurnitureInfo")
		end
		g_i3k_ui_mgr:PopupTipMessage("提取成功")
	else
		g_i3k_ui_mgr:PopupTipMessage("提取失败")
	end
end

--地面家具放置
function i3k_sbean.land_furniture_put(info)
	local data = i3k_sbean.land_furniture_put_req.new()
	data.id = info.furnitureId
	data.positionX = info.positionX
	data.positionY = info.positionY
	data.direction = info.direction
	i3k_game_send_str_cmd(data, "land_furniture_put_res")
end

function i3k_sbean.land_furniture_put_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("放置成功")
		local logic = i3k_game_get_logic()
		if logic then
			local world = logic:GetWorld()
			if world then
				world:ReleaseChooseFurniture()
			end
		end
		g_i3k_ui_mgr:CloseUI(eUIID_HouseFurniture)
		g_i3k_ui_mgr:CloseUI(eUIID_HouseFurnitureSet)
	else
		g_i3k_ui_mgr:PopupTipMessage("放置失败")
	end
end

--地面家具取回
function i3k_sbean.land_furniture_remove(index)
	local data = i3k_sbean.land_furniture_remove_req.new()
	data.index = index
	i3k_game_send_str_cmd(data, "land_furniture_remove_res")
end

function i3k_sbean.land_furniture_remove_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("移除成功")
		g_i3k_ui_mgr:CloseUI(eUIID_HouseFurniture)
	else
		g_i3k_ui_mgr:PopupTipMessage("移除失败")
	end
end

--墙面家具放置
function i3k_sbean.wall_furniture_put(id, index, position)
	local data = i3k_sbean.wall_furniture_put_req.new()
	data.id = id
	data.wallIndex = index
	data.position = position
	i3k_game_send_str_cmd(data, "wall_furniture_put_res")
end

function i3k_sbean.wall_furniture_put_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("放置成功")
		g_i3k_ui_mgr:CloseUI(eUIID_HouseFurniture)
		g_i3k_ui_mgr:CloseUI(eUIID_HouseFurnitureSet)
	else
		g_i3k_ui_mgr:PopupTipMessage("服务器放置失败")
	end
end

--墙面家具取回
function i3k_sbean.wall_furniture_remove(index, callback)
	local data = i3k_sbean.wall_furniture_remove_req.new()
	data.index = index
	data.callback = callback
	i3k_game_send_str_cmd(data, "wall_furniture_remove_res")
end

function i3k_sbean.wall_furniture_remove_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("移除成功")
		--g_i3k_ui_mgr:InvokeUIFunction(eUIID_HouseFurnitureSet, "onLeaveBtn")
		g_i3k_ui_mgr:CloseUI(eUIID_HouseFurniture)
		if req.callback then
			req.callback()
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("服务器移除失败")
	end
end

--附加家具放置
function i3k_sbean.addition_furniture_put(id, index)
	local data = i3k_sbean.addition_furniture_put_req.new()
	data.id = id
	data.index = index
	i3k_game_send_str_cmd(data, "addition_furniture_put_res")
end

function i3k_sbean.addition_furniture_put_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("放置成功")
	else
		g_i3k_ui_mgr:PopupTipMessage("服务器放置失败")
	end
end

--附加家具取回
function i3k_sbean.addition_furniture_remove(index)
	local data = i3k_sbean.addition_furniture_remove_req.new()
	data.index = index
	i3k_game_send_str_cmd(data, "addition_furniture_remove_res")
end

function i3k_sbean.addition_furniture_remove_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("移除成功")
	else
		g_i3k_ui_mgr:PopupTipMessage("服务器移除失败")
	end
end

--地毯家具放置
function i3k_sbean.floor_furniture_put(info)
	local data = i3k_sbean.floor_furniture_put_req.new()
	data.id = info.furnitureId
	data.positionX = info.positionX
	data.positionY = info.positionY
	data.direction = info.direction
	i3k_game_send_str_cmd(data, "floor_furniture_put_res")
end

function i3k_sbean.floor_furniture_put_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("放置成功")
		local logic = i3k_game_get_logic()
		if logic then
			local world = logic:GetWorld()
			if world then
				world:ReleaseChooseFurniture()
			end
		end
		g_i3k_ui_mgr:CloseUI(eUIID_HouseFurniture)
		g_i3k_ui_mgr:CloseUI(eUIID_HouseFurnitureSet)
	else
		g_i3k_ui_mgr:PopupTipMessage("放置失败")
	end
end

--地毯家具取回
function i3k_sbean.floor_furniture_remove(index)
	local data = i3k_sbean.floor_furniture_remove_req.new()
	data.index = index
	i3k_game_send_str_cmd(data, "floor_furniture_remove_res")
end

function i3k_sbean.floor_furniture_remove_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("移除成功")
		g_i3k_ui_mgr:CloseUI(eUIID_HouseFurniture)
	else
		g_i3k_ui_mgr:PopupTipMessage("移除失败")
	end
end

--地面家具移动
function i3k_sbean.land_furniture_move(index, info)
	local data = i3k_sbean.land_furniture_move_req.new()
	data.index = index
	data.positionX = info.positionX
	data.positionY = info.positionY
	data.direction = info.direction
	i3k_game_send_str_cmd(data, "land_furniture_move_res")
end

function i3k_sbean.land_furniture_move_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("移动成功")
		g_i3k_ui_mgr:CloseUI(eUIID_HouseFurniture)
		g_i3k_ui_mgr:CloseUI(eUIID_HouseFurnitureSet)
	else
		g_i3k_ui_mgr:PopupTipMessage("服务器移动失败")
	end
end

--地毯家具移动
function i3k_sbean.floor_furniture_move(index, info)
	local data = i3k_sbean.floor_furniture_move_req.new()
	data.index = index
	data.positionX = info.positionX
	data.positionY = info.positionY
	data.direction = info.direction
	i3k_game_send_str_cmd(data, "floor_furniture_move_res")
end

function i3k_sbean.floor_furniture_move_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("移动成功")
		g_i3k_ui_mgr:CloseUI(eUIID_HouseFurniture)
		g_i3k_ui_mgr:CloseUI(eUIID_HouseFurnitureSet)
	else
		g_i3k_ui_mgr:PopupTipMessage("服务器移动失败")
	end
end

--进入房间
function i3k_sbean.house_enter()
	local data = i3k_sbean.house_enter_req.new()
	i3k_game_send_str_cmd(data, "house_enter_res")
end

function i3k_sbean.house_enter_res.handler(res, req)
	if res.ok > 0 then
		
	else
		g_i3k_ui_mgr:PopupTipMessage("进入失败")
	end
end

--请求家具背包数据
function i3k_sbean.house_bag_furniture_sync(callback)
	local data = i3k_sbean.house_bag_furniture_sync_req.new()
	data.callback = callback
	i3k_game_send_str_cmd(data, "house_bag_furniture_sync_res")
end

function i3k_sbean.house_bag_furniture_sync_res.handler(res, req)
	g_i3k_game_context:setCurHouseBag(res)
	if req.callback then
		req.callback()
	end
end

--进入房间同步
function i3k_sbean.house_map_sync.handler(res)
	if res.homeland.curSkin < 1 then
		res.homeland.curSkin = 1
	end
	g_i3k_game_context:setHomeLandHouseInfo(res)
	local logic = i3k_game_get_logic()
	if logic then
		local world = logic:GetWorld()
		if world then
			world:initHouseFloorModels()
			world:ChangeHouseSkin(res.homeland.curSkin)
		end
	end
	--g_i3k_ui_mgr:OpenUI(eUIID_HouseBase)
	g_i3k_ui_mgr:RefreshUI(eUIID_HouseBase)
end

--替换房屋皮肤
function i3k_sbean.house_skin_select(index)
	local data = i3k_sbean.house_skin_select_req.new()
	data.index = index
	i3k_game_send_str_cmd(data, "house_skin_select_res")
end

function i3k_sbean.house_skin_select_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("更换成功")
		g_i3k_ui_mgr:CloseUI(eUIID_HouseSkin)
	else
		g_i3k_ui_mgr:PopupTipMessage("更换失败")
	end
end

--同步房屋皮肤
function i3k_sbean.house_unlock_skin_sync()
	local data = i3k_sbean.house_unlock_skin_sync_req.new()
	i3k_game_send_str_cmd(data, "house_unlock_skin_sync_res")
end

function i3k_sbean.house_unlock_skin_sync_res.handler(res, req)
	g_i3k_game_context:setHouseSkinInfo(res.unlockSkin)
	g_i3k_ui_mgr:OpenUI(eUIID_HouseSkin)
	g_i3k_ui_mgr:RefreshUI(eUIID_HouseSkin)
end

--同步家园内玩家位置
function i3k_sbean.query_homeland_members()
	local bean = i3k_sbean.query_homeland_members_pos.new()
	i3k_game_send_str_cmd(bean)
end

function i3k_sbean.homeland_members_position.handler(res)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_HomeLandMap, "updateTeammatePos", res.members)
end

--家园宠物
--开启家园宠物位置
function i3k_sbean.homeland_pet_position_open(id)
	local bean = i3k_sbean.homeland_pet_position_open_req.new()
	bean.id = id
	i3k_game_send_str_cmd(bean, "homeland_pet_position_open_res")
end
function i3k_sbean.homeland_pet_position_open_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:updateHomePetData(req.id, {curPet = 0, daySelfActionTime = 0, lastOtherActionTime = 0, mood = 0})
		g_i3k_ui_mgr:RefreshUI(eUIID_HomePetOperate)
	end
end
--设置家园宠物
function i3k_sbean.homeland_pet_position_set(id, petId)
	local bean = i3k_sbean.homeland_pet_position_set_req.new()
	bean.id = id
	bean.petId = petId
	i3k_game_send_str_cmd(bean, "homeland_pet_position_set_res")
end
function i3k_sbean.homeland_pet_position_set_res.handler(res, req)
	if res.ok > 0 then
		local petData = g_i3k_game_context:getHomePetData()
		petData[req.id].curPet = req.petId
		petData[req.id].mood = 0
		g_i3k_game_context:updateHomePetData(req.id, petData[req.id])
		g_i3k_ui_mgr:CloseUI(eUIID_HomePetChoose)
		g_i3k_ui_mgr:OpenUI(eUIID_HomePetOperate)
		g_i3k_ui_mgr:RefreshUI(eUIID_HomePetOperate)
	end
end
--家园宠物互动
function i3k_sbean.homeland_pet_position_action(id, actionId, petId, petName)
	local bean = i3k_sbean.homeland_pet_position_action_req.new()
	bean.id = id
	bean.actionId = actionId
	bean.petId = petId
	bean.petName = petName
	i3k_game_send_str_cmd(bean, "homeland_pet_position_action_res")
end
function i3k_sbean.homeland_pet_position_action_res.handler(res, req)
	if res.ok > 0 then
		if g_i3k_game_context:isInMyHomeLand() then
			local petData = g_i3k_game_context:getHomePetData()
			if petData and petData[req.id] and petData[req.id].daySelfActionTime > 0 then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17884))
			end
		end
		if res.mood ~= 0 then
			if req.actionId == 1 then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17839, req.petName, res.mood))
			elseif req.actionId == 2 then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17843, req.petName, res.mood))
			end
		end
		g_i3k_ui_mgr:CloseUI(eUIID_HomePetDialogue)
		if next(res.rewards) then
			g_i3k_ui_mgr:ShowGainItemInfo(res.rewards)
		end
		g_i3k_game_context:addHomePetActTimes(req.id)
	end
end
--家园宠物一键互动
function i3k_sbean.homeland_pet_position_onekey_action()
	local bean = i3k_sbean.homeland_pet_position_onekey_action_req.new()
	i3k_game_send_str_cmd(bean, "homeland_pet_position_onekey_action_res")
end
function i3k_sbean.homeland_pet_position_onekey_action_res.handler(res, req)
	--self.ok:		int32	
	--self.rewards:		vector[DummyGoods]
	--self.moods
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17879))
		--g_i3k_ui_mgr:CloseUI(eUIID_HomePetDialogue)
		g_i3k_game_context:UseCommonItem(i3k_db_home_pet.patchPlay.id, i3k_db_home_pet.patchPlay.count, AT_HOUSE_SKIN_UNLOCK)
		if next(res.rewards) then
			g_i3k_ui_mgr:ShowGainItemInfo(res.rewards)
		end
		g_i3k_game_context:addAllHomePetActTimes()
		g_i3k_ui_mgr:RefreshUI(eUIID_HomePetOperate)
	end
end
--家园宠物领奖
function i3k_sbean.homeland_pet_position_reward(id, petName)
	local bean = i3k_sbean.homeland_pet_position_reward_req.new()
	bean.id = id
	bean.petName = petName
	i3k_game_send_str_cmd(bean, "homeland_pet_position_reward_res")
end
function i3k_sbean.homeland_pet_position_reward_res.handler(res, req)
	--self.ok:		int32	
	--self.rewards:		vector[DummyGoods]
	if res.ok > 0 then
		local petData = g_i3k_game_context:getHomePetData()
		petData[req.id].mood = 0
		g_i3k_game_context:updateHomePetData(req.id, petData[req.id])
		g_i3k_ui_mgr:CloseUI(eUIID_HomePetDialogue)
		if res.rewards then
			g_i3k_ui_mgr:ShowGainItemInfo(res.rewards)
		end
	end
end
--更新家园宠物
function i3k_sbean.homeland_pet_position_update.handler(res)
	--<field name="id" type="int32"/>
	--<field name="position" type="DBHomelandPetPosition"/>
	local petData = g_i3k_game_context:getCurHomePetData()
	if petData and petData[res.id] then
		petData[res.id].curPet = res.position.curPet
		petData[res.id].mood = res.position.mood
		petData[res.id].lastOtherActionTime = res.position.lastOtherActionTime
		g_i3k_game_context:updateHomePetData(res.id, petData[res.id])
	else
		g_i3k_game_context:updateHomePetData(res.id, res.position)
	end
	g_i3k_ui_mgr:RefreshUI(eUIID_HomePetOperate)
	local world = i3k_game_get_world()
	if world then
		world:ResetHomePetTitle(res.position.curPet)
	end
end
--请求他人家园宠物信息
function i3k_sbean.homeland_pet_position_ask()
	local bean = i3k_sbean.homeland_pet_position_query.new()
	i3k_game_send_str_cmd(bean)
end
--他人家园宠物信息
function i3k_sbean.homeland_pet_position_query_info.handler(res)
	--self.pets:		map[int32, EnterEntity]	
	if res.pets and next(res.pets) then
		g_i3k_ui_mgr:OpenUI(eUIID_HomePetOther)
		g_i3k_ui_mgr:RefreshUI(eUIID_HomePetOther, res.pets)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17887))
	end
end
