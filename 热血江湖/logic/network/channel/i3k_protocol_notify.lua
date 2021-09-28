------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")
require("ui/map_set_funcs")
function i3k_sbean.role_notice.handler(bean)
	local notice = bean.notice
	local noticeTbl = {}
	for i = g_NOTICE_TYPE_CAN_RECEIVE_NEW_MAIL, g_NOTICE_TYPE_LOTTERY do
		local shiftDiv = i-1 <= 0 and 1 or 2
		notice = math.floor(notice/shiftDiv)
		if notice%2 == 1 then
			table.insert(noticeTbl, i)
		end
	end
	g_i3k_game_context:SetNotices(noticeTbl)
end

------------------------------------------
-- 通知客户端切换地图
--Packet:role_change_map
function i3k_sbean.role_change_map.handler(bean)
	releaseSchedule()
	g_i3k_game_context:ClearBossDamageData()
	g_i3k_game_context:ShowBossDamageBtn(false)
	g_i3k_game_context:setWeaponShowNpcID(0)
	g_i3k_game_context:clearWeaponStatus()
	g_i3k_game_context:clearOnlineVoiceRoomId()
	g_i3k_game_context:clearWoodManDamage()
	local changemap = false;
	local logic = i3k_game_get_logic();
	local world = nil
	if logic then
		world = logic:GetWorld()
		local player = logic:GetPlayer();
		if player and player:GetHero() then
			player:ReleasePickItems()
			player:ResetCameraEntity()
			local hero = i3k_game_get_player_hero();
			if hero then
				hero._preautonormalattack = false;
				hero._autonormalattack = false;
				hero._target = nil;
				if hero:IsOnRide() then
					local entitys = hero:GetLinkEntitys()
					for _, e in pairs(entitys) do
						e:RemoveLinkChild()
						world._entities[eGroupType_O][e._guid] = e;
					end
					hero:ReleaseLinkChils()
					hero:OnRideMode(false);
				end
				if hero:IsOnHugMode() then
					hero:ClearHug()
					hero:LeaveHugMode()
				end
				if hero._superMode.valid then
					hero._superMode.valid = false;
					hero:SuperMode(false);
				end
				if g_i3k_game_context:IsInMissionMode() then
					hero:MissionMode(false)
				end
				hero:ResetAutoOfflineTime()
				local map = bean.location
				local mapID = map.mapID
				if mapID ~= 9999 and mapID ~= 25000 then
					g_i3k_game_context:setCameraAngle(0)
				end
				hero:ClearGameInstanceSkills()
				hero:ClsEnmities()
				hero:SetDigStatus(0)
				if hero._unifyMode.valid then
					hero:OnUnifyMode(false)
				end
				hero:DetachHomeLandEquip() --还原玩家蒙皮
				hero:UpdateProperty(ePropID_speed, 1, hero._cfg.speed, true, false, true);
				hero:SetGuardSatate(false)
				hero:RestoreModelFacade()
				hero:SetAutoFight(false)
				g_i3k_game_context:SetMulHorseCallbackFunc(nil)
				g_i3k_game_context:SetMonsterPosition(nil);
			end
		end
	end

	if g_i3k_game_context then
		local map = bean.location
		local mapID = map.mapID
		local location = map.location

		local position = location.position
		local rotation = location.rotation

		local x = position.x
		local y = position.y + 50
		local z = position.z

		local rx = rotation.x
		local ry = rotation.y
		local rz = rotation.z

		local r = i3k_vec3_angle2(i3k_vec3(rx, ry, rz), i3k_vec3(1, 0, 0));
		i3k_game_stop_scene_ani()
		
		if world then
			if world._cfg.id ~= mapID then
				world:Release();
				changemap = true
			else
				world:Release(true);
			end
		else
			changemap = true
		end
		local player = logic:GetPlayer();
		player:Restore()
		
		g_i3k_game_context:SetCurrentLine(bean.curLine)
		if changemap then
			local hero = i3k_game_get_player_hero();
			if player and hero then
				hero:TitleColorTest();
				local MercenaryCount = player:GetMercenaryCount();
				for i = tonumber(MercenaryCount) , 1 , -1 do
					local Mercenary = player:GetMercenary(i)
					if world then
						world:RmvEntity(Mercenary);
					end
					player:RmvMercenary(i);
				end
				local EscortCarCount = player:GetEscortCarCount();
				for i = tonumber(EscortCarCount) , 1 , -1 do
					local EscortCar = player:GetEscortCar(i)
					if world then
						world:RmvEntity(EscortCar);
					end
					player:RmvEscortCar(i);
				end
				if mapID == i3k_db_spring.common.mapId then
					hero:SpringSpecialShow();
				end
				if hero:isSpecial() then
					hero:changeSpecialWeap();
					hero:WearOldFashion();
				end
			end
			g_i3k_game_context:SetSuperOnHookValid(false)
		else
			g_i3k_ui_mgr:CloseAllOpenedUI()
			g_i3k_logic:OpenBattleUI()
		end
		g_i3k_game_context:ResetLeadMode()
		g_i3k_game_context:ChangeZone(mapID, i3k_vec3(x, y, z), r);
		g_i3k_game_context:SetMoveState(true)
	end
end

-------------------------------收到新消息时--------------------------------
function i3k_sbean.role_new_msg.handler(bean)
	local msg = bean.msg
	if g_i3k_game_context:isBlackFriend(math.abs(msg.srcId or 0)) then
		return
	end
	local message,recentData, recentContent = g_i3k_game_context:parseChatData(msg)
	---刷新红点
	if message then
		if message.fromId < 0 or message.fromId == g_i3k_game_context:GetRoleId() then               --自己发的
	
		else
			if (message.type == global_recent or message.type == global_cross) and g_i3k_game_context:GetPrivateChatUIOpenState() then --如果是私聊消息 并且私聊UI被打开，则不存储
	
			else
				g_i3k_game_context:addChatMsg(message)    --存储最新消息
			end
	
	
			if ((message.type == global_recent or message.type == global_cross) and not g_i3k_game_context:GetPrivateChatUIOpenState()) or not g_i3k_game_context:GetChatUIOpenState() then
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase,"onShowChatRedPoint", message.type)
			end
		end
	---------------------------------------------
		if (message.type == global_recent or message.type == global_cross) then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_PriviteChat, "receiveNewMsg",recentData,recentContent)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_Chat, "updateRecentBtn")
		end
		--赠花播放特效
		if message.msgType == 2 then
			local worldType = i3k_game_get_map_type()
			local count = message.sendFlowersData.count or 0
			if worldType == g_FIELD and (count >= i3k_db_common.give_flower.lessEffect) then
				g_i3k_ui_mgr:OpenUI(eUIID_GiveFlowerEffects)
				g_i3k_ui_mgr:RefreshUI(eUIID_GiveFlowerEffects, count)
			end
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Chat, "receiveNewMsg", message)
		--刷新battle页面
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "receiveNewMsg", message)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_AnswerQuestions, "receiveNewMsg", message)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SwornDate, "receiveNewMsg", message)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SetSwornPrefix, "receiveNewMsg", message)
	end
end
------------------------------------------------------
-- 通知客户端队友击杀
--Packet:role_team_kill
function i3k_sbean.role_team_kill.handler(bean,res)
	local killType = bean.type
	local id = bean.id
	local count = bean.count

	g_i3k_game_context:SetTaskDataByTaskType(id,g_TASK_KILL)
	g_i3k_game_context:setKillCount(g_i3k_game_context:getKillCount() + count);
	g_i3k_game_context:SetBuffKillMonsterCnt(count);
	--i3k_log("role_team_kill------", bean.count ,bean.type,bean.id)
	g_i3k_game_context:setTowerKillCount(g_i3k_game_context:getTowerKillCount() + count)---记录爬塔
	g_i3k_game_context:setWakenKillCount(g_i3k_game_context:getWakenKillCount() + count, bean.id)---宠物觉醒杀怪
end

function i3k_sbean.role_add_diamond.handler(bean)
	local amount = bean.amount
	local free = bean.free ~= 0
	g_i3k_game_context:AddDiamond(amount, free)
	local tmp_str = "绑定"
	if free then
		tmp_str = "非绑定"
	end
	if not i3k_dataeye_itemtype(bean.reason) then
		DCItem.get(g_BASE_ITEM_DIAMOND, tmp_str, amount, bean.reason)
	end
end

function i3k_sbean.role_add_coin.handler(bean)
	local amount = bean.amount
	local free = bean.free ~= 0
	g_i3k_game_context:AddMoney(amount, free)
	local tmp_str = "绑定"
	if free then
		tmp_str = "非绑定"
	end
	if not i3k_dataeye_itemtype(bean.reason) then
		DCItem.get(g_BASE_ITEM_COIN, tmp_str, amount, bean.reason)
	end
end

function i3k_sbean.role_add_bonus.handler(bean)
	local amount = bean.amount
	g_i3k_game_context:AddDividend(amount)
	if not i3k_dataeye_itemtype(bean.reason) then
		DCItem.get(g_BASE_ITEM_DIVIDEND, "红利", amount, bean.reason)
	end
end

function i3k_sbean.role_add_dragoncoin.handler(bean)
	local dragoncoin = bean.dragoncoin
	g_i3k_game_context:AddDragonCoin(dragoncoin)
	if not i3k_dataeye_itemtype(bean.reason) then
		DCItem.get(g_BASE_ITEM_DRAGON_COIN, "龙魂币", dragoncoin, bean.reason)
	end
end

function i3k_sbean.role_add_fame.handler(bean)
	local fame = bean.fame
	g_i3k_game_context:AddFameCount(fame)
	if not i3k_dataeye_itemtype(bean.reason) then
		DCItem.get(g_BASE_ITEM_FAME, "武林声望", fame, bean.reason)
	end
end

function i3k_sbean.role_add_sectcontribution.handler(bean)
	local amount = bean.amount
	g_i3k_game_context:AddSectContribution(amount)
end

function i3k_sbean.role_add_arenapoint.handler(bean)
	local amount = bean.amount
	g_i3k_game_context:AddArenaMoney(amount)
	if not i3k_dataeye_itemtype(bean.reason) then
		DCItem.get(g_BASE_ITEM_ARENA_MONEY, "武斗币", amount, bean.reason)
	end
end

function i3k_sbean.role_add_equipenergy.handler(bean)
	local amount = bean.amount
	--g_i3k_game_context:AddEquipEnergy(amount)
	g_i3k_game_context:AddCommonItem(g_BASE_ITEM_EQUIP_ENERGY, amount)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "addEquipPower", amount)
	if not i3k_dataeye_itemtype(bean.reason) then
		DCItem.get(g_BASE_ITEM_EQUIP_ENERGY, "装备能量", amount, bean.reason)
	end
end

function i3k_sbean.role_add_gemenergy.handler(bean)
	local amount = bean.amount
	--g_i3k_game_context:AddStoneEnergy(amount)
	g_i3k_game_context:AddCommonItem(g_BASE_ITEM_GEM_ENERGY, amount)
	if not i3k_dataeye_itemtype(bean.reason) then
		DCItem.get(g_BASE_ITEM_GEM_ENERGY, "宝石能量", bean.amount, bean.reason)
	end
end

function i3k_sbean.role_add_bookinspiration.handler(bean)
	local amount = bean.amount
	g_i3k_game_context:AddRuneEnergy(amount)
	if not i3k_dataeye_itemtype(bean.reason) then
		DCItem.get(g_BASE_ITEM_BOOK_ENERGY, "心法悟性", bean.amount, bean.reason)
	end
end

function i3k_sbean.role_add_eightdiagramenergy.handler(bean)
	local amount = bean.eightdiagramenergy
	g_i3k_game_context:AddBaguaEnergy(amount)
	if not i3k_dataeye_itemtype(bean.reason) then
		DCItem.get(g_BASE_ITEM_BAGUA_ENERGY, "八卦能量", amount, bean.reason)
	end
end

-- 宠物装备精华增加
function i3k_sbean.role_add_pet_equip_spirit.handler(bean)
	local amount = bean.petEquipSpirit
	g_i3k_game_context:AddPetEquipSpiritCount(amount)
	if not i3k_dataeye_itemtype(bean.reason) then
		DCItem.get(g_BASE_ITEM_PET_EQUIP_SPIRIT, "宠物装备精华", amount, bean.reason)
	end
end

function i3k_sbean.role_show_power.handler(bean)
	local power = bean.power
	if power then
		g_i3k_ui_mgr:PopupTipMessage(string.format("战斗力：前 %d/后 %d",i3k_game_get_player_hero():Appraise(),power))
		g_i3k_ui_mgr:RefreshUI(eUIID_GmBackstage, power)
	end
end

function i3k_sbean.role_show_timeoffset.handler(bean)
	local ofsetsecond = bean.ofsetsecond
	if ofsetsecond and bean.now then
		i3k_game_reset_time(bean.now)
		local curTime = os.date("%Y-%m-%d-%H:%M:%S周%w",g_i3k_get_GMTtime(i3k_game_get_time()))
		g_i3k_ui_mgr:PopupTipMessage(string.format("服务器时间偏移：%d秒",ofsetsecond))
		g_i3k_ui_mgr:PopupTipMessage(string.format("当前服务器时间：%s", curTime))
	end
end

function i3k_sbean.role_add_exp.handler(bean)
	local exp = bean.exp
	local offlineexp = bean.offlineexp
	local drugexp = bean.drugexp
	local wizardexp = bean.wizardexp
	local citylightexp = bean.citylightexp
	local sectZoneSpiritexp = bean.sectZoneSpiritexp
	local swornAdd = bean.swornAdd
	local globalWorldCardAdd = bean.globalWorldCardAdd
	g_i3k_game_context:AddExp(exp, offlineexp, drugexp, wizardexp, citylightexp, sectZoneSpiritexp, swornAdd, globalWorldCardAdd)
end

--特殊神兵技能加经验
function i3k_sbean.weapon_awake_exp_add.handler(bean)
	g_i3k_game_context:AddShenbingBinghunSkillExp(bean.add)
	local id = g_i3k_game_context:GetSelectWeapon()
	local name = g_i3k_db.i3k_db_get_cur_weapon_awake_skill_name(id)
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1601, name, bean.add))
end
function i3k_sbean.role_add_vit.handler(bean)
	local vit = bean.vit
	g_i3k_game_context:AddVit(vit, true)
	if not i3k_dataeye_itemtype(bean.reason) then
		DCItem.get(g_BASE_ITEM_VIT, "体力", bean.vit, bean.reason)
	end
end

function i3k_sbean.role_add_charm.handler(bean)
	local charm = bean.charm
	g_i3k_game_context:SetCharm(charm)
end

function i3k_sbean.role_add_item.handler(bean)
	local item = bean.item
	g_i3k_game_context:AddCommonItem(item.id, item.count, item.equips)
	g_i3k_game_context:AddSuit(item.id)
	DCItem.get(item.id,g_i3k_db.i3k_db_get_common_item_is_free_type(item.id),item.count,bean.reason)
end

function i3k_sbean.role_add_items.handler( bean )
	local items = bean.items
	for i, e in pairs(items) do
		g_i3k_game_context:AddCommonItem(e.id, e.count, e.equips)
		g_i3k_game_context:AddSuit(e.id)
		DCItem.get(e.id,g_i3k_db.i3k_db_get_common_item_is_free_type(e.id),e.count,bean.reason)
	end
end

-- 通知客户端删除道具
function i3k_sbean.role_del_item.handler(bean)
	local item = bean.item
	g_i3k_game_context:DeleteCommonItem(item.id, item.count, item.equips, bean.reason)
end

function i3k_sbean.role_del_items.handler(bean)
	local items = bean.items
	for i, e in ipairs(items) do
		g_i3k_game_context:DeleteCommonItem(e.id, e.count, e.equips, bean.reason)
	end
end

-- 通知客户端角色商誉值增加
function i3k_sbean.role_add_credit.handler(bean)
	g_i3k_game_context:AddCredit(bean.amount, bean.reason)
end

-- 通知客户端角色离线精灵修炼点增长
function i3k_sbean.role_add_offline_func_point.handler(bean)
	g_i3k_game_context:AddOfflineWizardPoint(bean.offlineFuncPoint, bean.reason)
end

function i3k_sbean.role_add_weaponsoulcoin.handler(bean)
	g_i3k_game_context:AddWeaponSoulCoin(bean.amount, bean.reason)
end

function i3k_sbean.role_hppool_used.handler(bean)
	local useHp = bean.useHp
	g_i3k_game_context:reduceVipBloodPool(useHp)
end

function i3k_sbean.role_day_refresh.handler(bean)
	g_i3k_game_context:RefreshDay()
end

--帮派技能更新

function i3k_sbean.sect_aura_update.handler(res)
	local id = res.id
	local level = res.level
	local skill_data = g_i3k_game_context:GetFactionSkillData()
	skill_data[id] = {}
	skill_data[id].level = level

	g_i3k_game_context:SetFactionSkillData(skill_data)

	local hero = i3k_game_get_player_hero()
	if hero then
		hero:UpdateFactionSkillProps()
	end
end

--添加宗门材料
--function i3k_sbean.role_add_ore.handler(res)
--	local _type = res.type
--	local value = res.value
--	if _type == CLAN_ORE_TYPE_IRON then
--		g_i3k_game_context:AddCLanIron(value)
--	elseif _type == CLAN_ORE_TYPE_HERB then
--		g_i3k_game_context:AddCLanHerb(value)
--	end
--
--	local bag_layer = g_i3k_ui_mgr:GetUI(eUIID_ClanMain)
--		if bag_layer then
--			bag_layer:setBaseData()
--		end
--end

--指引进度同步
--Packet:send_lead_info
function i3k_sbean.send_lead_info(id,finish)
	local bean = i3k_sbean.lead_info_set.new()
	bean.id = id
	bean.state = finish
	i3k_game_send_str_cmd(bean)
end

--引导信息同步
--Packet:role_leadinfo
function i3k_sbean.role_leadinfo.handler(bean, res)
	if g_i3k_game_context then
		g_i3k_game_context:InitLeadData(bean.info);
	end
end

--强制剧情指引
function i3k_sbean.role_leadplot.handler(bean, res)
	if g_i3k_game_context then
		g_i3k_game_context:InitPlotData(bean.plot);
	end
end

--指引进度同步
--Packet:lead_plot_set
function i3k_sbean.send_lead_plot_set(id,times)
	local bean = i3k_sbean.lead_plot_set.new()
	bean.id = id
	bean.count = times
	i3k_game_send_str_cmd(bean)
end

--提前开启预览同步
--Packet:func_preview_set
function i3k_sbean.send_func_preview_set(id)
	local bean = i3k_sbean.func_preview_set.new()
	bean.preview = id
	i3k_game_send_str_cmd(bean)
end

-- 同步宗门弟子属性
--function i3k_sbean.clan_changeownerattri.handler(bean, res)
--	if g_i3k_game_context then
--		g_i3k_game_context:SetClanAttrData(bean.attriAddition);
--	end
--end

--登入同步镖车重新登入的位置
function i3k_sbean.role_escortcar_location.handler(bean)
	if bean then
		local map = bean.mapLocation
		local mapID = map.mapID--args:pop_int();
		local location = map.location
		local curLine = bean.curLine
		local position = location.position
		local rotation = location.rotation

		local x = position.x
		local y = position.y
		local z = position.z

		local rx = rotation.x
		local ry = rotation.y
		local rz = rotation.z

		local r = i3k_vec3_angle2(i3k_vec3(rx, ry, rz), i3k_vec3(1, 0, 0));
		g_i3k_game_context:SetEscortCarLocation(mapID, i3k_vec3(x, y, z), r);
		g_i3k_game_context:SetEscortCarMapInstance(curLine)
	end
end

-- sync client assert ignore list
function i3k_sbean.assert_ignore_list.handler(bean)
	local words = Engine.StringVector();
	for k, v in pairs(bean.keywords) do
		words:push_back(k)
	end
	g_i3k_game_handler:ClsIgnoreAssertKeywords();
	g_i3k_game_handler:SetIgnoreAssertKeywords(words);
end

--头像框激活和失效的通知
function i3k_sbean.auto_unlock_headborder.handler(res)
	local border = res.border
	if border < 0 then  --失效
		local bwType = g_i3k_game_context:GetTransformBWtype()
		local frameId = 0
		for _, v in ipairs(i3k_db_head_frame) do
			if v.bwType == bwType and v.activate_type == 1 then  --获取默认头像框
				frameId = v.id
				break
			end
		end
		g_i3k_game_context:setRoleHeadFrameId(frameId)
	end
end

--对对碰兑换背包已满的通知
function i3k_sbean.happy_mstching_tip.handler(res)
	if res.error then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15576))
		g_i3k_ui_mgr:CloseUI(eUIID_ExchangeWords)
	end
end

--buff药的通知
function i3k_sbean.buff_drug_update.handler(res)
	if res.drug then
		g_i3k_game_context:UpdateBuffDrugData(res.drug, res.type)
	end
end

--同步服务器封印是否打破
function i3k_sbean.breaklevel_state.handler(res)
	g_i3k_game_context:setSealBreak(res.isBreak)
	if res.isBreak > 0 then
		if g_i3k_game_context:GetLevel() == i3k_db_server_limit.sealLevel and g_i3k_game_context:GetOutExp() > 0 then
			g_i3k_game_context:AddExp(0, 0, 0, 0, 0, 0, 0, 0, true)
		end
	end
end

--春节福袋登陆同步
function i3k_sbean.role_new_year_pack_id.handler(res)
	if res.batch and res.batch == i3k_db_lucky_pack_cfg.bagID then
		g_i3k_game_context:SetNowPackID(res.curId)
	end
end

--飞鸽传书消息
function i3k_sbean.role_kite_new_msg.handler(res)
	g_i3k_game_context:updatePigeonPost(res.kiteMsg)
	local world = i3k_game_get_world()
	if world then
		if world._mapType == g_FIELD then
			if g_i3k_ui_mgr:GetUI(eUIID_BattleBase) then
				g_i3k_ui_mgr:OpenUI(eUIID_PigeonPost)
				g_i3k_ui_mgr:RefreshUI(eUIID_PigeonPost)
			end
		end
	end
end
--驭灵碎片交换结果通知
function i3k_sbean.ghost_island_syn_exchange_result.handler(bean)
	if bean.ok > 0 then
		--[[local info = g_i3k_game_context:getGhostSkillInfo()
		if info.costId ~= 0 then
			g_i3k_game_context:addCatchSpiritFragment(info.targetId, 1)
			g_i3k_game_context:useCatchSpiritFragment(info.costId, i3k_db_catch_spirit_base.spiritFragment.exchangeConsume)
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SpriteFragmentExchange, "onAsyncNetCome")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_CatchSpiritTask, "updateCatchCount")--]]
		g_i3k_game_context:SetSpiritsDataOnExchangeComplete()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SpriteFragmentExchange,"refresh", {targetId = 0, costId = 0})
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SpriteFragmentBag, "showDataByIndex", 2)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_CatchSpiritTask, "updateCatchCount")
	else
		g_i3k_game_context:SetSpiritsIsExchangeComplete(g_SPIRIT_STATE_FAIL)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SpriteFragmentExchange,"SetExchangeDataDesc")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SpriteFragmentBag,"SetExchangeDataDesc")
	end
end
--驭灵碎片掉落
function i3k_sbean.role_drop_spirit.handler(bean)
	--self.spiritId:		int32	
	g_i3k_game_context:addCatchSpiritFragment(bean.spiritId, 1)
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18629, i3k_db_catch_spirit_fragment[bean.spiritId].name))
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_CatchSpiritTask, "updateCatchCount")
	local world = i3k_game_get_world()
	if world then
		world:createCatchSpiritFragment(bean.spiritId, bean.position)
	end
end
function i3k_sbean.summoned_result.handler(bean)
	if bean.ok > 0 then
		g_i3k_game_context:addCatchSpiritCall(1)
		local hero = i3k_game_get_player_hero()
		if hero then
			local curPos = hero._curPosE;
			local areaType, facePos = g_i3k_db.i3k_db_get_area_type_arg(curPos)
			hero:onAreaType(false, areaType, facePos)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18701))
	end
end
