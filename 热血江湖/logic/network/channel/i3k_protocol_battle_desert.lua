module(..., package.seeall)

local require = require

require("i3k_sbean")
local map_unicast = require("logic/network/channel/i3k_protocol_map_uicast");

----------------------------------------------

function i3k_sbean.sync_battle_desert()
	local bean = i3k_sbean.survive_sync_req.new()
	i3k_game_send_str_cmd(bean, "survive_sync_res")
end

-- 同步决战荒漠界面信息
--[[
DBRoleSurvive
    ├──curHero (int32)
    ├──score (int32)
    ├──champion (int32)
    ├──punishTime (int32)
    └──log SurviveArenaLog(struct)
        ├──dayEnterTimes (int32)
        ├──enterTimes (int32)
        └──winTimes (int32)
]]
function i3k_sbean.survive_sync_res.handler(bean)
	--self.info:		DBRoleSurvive	
	if bean.info then
		g_i3k_game_context:setBattleDesertRoleInfo(bean.info)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "loadbattledesert")
	else
		g_i3k_ui_mgr:PopupTipMessage("未知错误")
	end
end

-- 选择出战英雄
function i3k_sbean.selectBattleHero(id)
	--self.hero:		int32	
	local bean = i3k_sbean.survive_sethero_req.new()
	bean.hero = id
	i3k_game_send_str_cmd(bean, "survive_sethero_res")
end

function i3k_sbean.survive_sethero_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_game_context:setBattleDesertCurHero(req.hero)
		g_i3k_ui_mgr:RefreshUI(eUIID_BattleDesertHero, req.hero, req.hero)
	else
		g_i3k_ui_mgr:PopupTipMessage("出战失败")
	end
end

-- 穿装备
function i3k_sbean.survive_equip_upwear(equips)
	--self.equips:		map[int32, int32]	
	local bean = i3k_sbean.survive_equip_upwear_req.new()
	bean.equips = equips
	i3k_game_send_str_cmd(bean, "survive_equip_upwear_res")
end

function i3k_sbean.survive_equip_upwear_res.handler(res, req)
	if res.ok > 0 then
		local prePower = g_i3k_game_context:GetDesertRoleFightPower()
		g_i3k_game_context:WearDesertBattleEquip(req.equips)
		g_i3k_game_context:ShowDesertPowerChange(prePower)

		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleDesertBag, "updateEquipUI")
		g_i3k_ui_mgr:CloseUI(eUIID_BattleDesertEquipTips)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1495))
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1104))
	end
end

-- 脱装备
function i3k_sbean.survive_equip_downwear(pos)
	--self.pos:		int32	
	local bean = i3k_sbean.survive_equip_downwear_req.new()
	bean.pos = pos
	i3k_game_send_str_cmd(bean, "survive_equip_downwear_res")
end

function i3k_sbean.survive_equip_downwear_res.handler(res, req)
	if res.ok > 0 then
		local prePower = g_i3k_game_context:GetDesertRoleFightPower()
		g_i3k_game_context:UnwearDesertBattleEquip(req.pos)
		g_i3k_game_context:ShowDesertPowerChange(prePower)

		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleDesertBag, "updateEquipUI")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleDesertBag, "updateBagScroll")	
		g_i3k_ui_mgr:CloseUI(eUIID_BattleDesertEquipTips)
	else
		g_i3k_ui_mgr:PopupTipMessage("卸下失败")
	end
end

-- 销毁道具请求
function i3k_sbean.survive_destoryitems(items)
	--self.items:		vector[DummyGoods]	
	local bean = i3k_sbean.survive_destoryitems_req.new()
	bean.items = items
	i3k_game_send_str_cmd(bean, "survive_destoryitems_res")
end

function i3k_sbean.survive_destoryitems_res.handler(res, req)
	if res.ok > 0 then
		for i, v in ipairs(req.items) do
			g_i3k_game_context:UseDesertBattleItem(v.id, v.count)
		end
		g_i3k_ui_mgr:CloseUI(eUIID_BattleDesertEquipTips)
		g_i3k_ui_mgr:CloseUI(eUIID_BattleDesertItemTips)
		g_i3k_ui_mgr:PopupTipMessage("销毁成功")
	else
		g_i3k_ui_mgr:PopupTipMessage("销毁失败")
	end
end

-- 使用药品
function i3k_sbean.survive_usedrug(itemID)
	--self.itemID:		int32
	local bean = i3k_sbean.survive_usedrug_req.new()
	bean.itemID = itemID
	i3k_game_send_str_cmd(bean, "survive_usedrug_res")
end

function i3k_sbean.survive_usedrug_res.handler(res, req)
	if res.ok > 0 then
		local hero = i3k_game_get_player_hero()
		if hero then
			hero:PlayHitEffect(i3k_db_desert_battle_base.drugEffectID)
		end
		g_i3k_game_context:SetDesertLastUseDrugTime(i3k_game_get_time())
		g_i3k_game_context:UseDesertBattleItem(req.itemID, 1)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17168))
	else
		g_i3k_ui_mgr:PopupTipMessage("使用失败")
	end
end

-- 通知客户端向背包添加副本道具
function i3k_sbean.role_add_survive_items.handler(res)
	--self.gis:		vector[GameItem]	
	--如果当前不处于观战状态
	if not g_i3k_game_context:getdesertBattleViewEntity()  then
			for _, v in ipairs(res.gis) do
			g_i3k_game_context:AddDesertBattleItem(v.id, v.count)
		end
		g_i3k_game_context:InitDesertBetterEquipState()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "onUpdateDesertBetterEquipShow")
	end
end

-- 通知客户端移除身上装备(淘汰，死亡掉落)
function i3k_sbean.role_del_survive_equips.handler(res)
	--self.gis:		set[int32]
	for partID in pairs(res.gis) do
		g_i3k_game_context:UnwearDesertBattleEquip(partID)
	end
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleDesertBag, "updateEquipUI")
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleDesertBag, "updateBagScroll")
end

-- 通知客户端副本背包减少道具(淘汰，死亡掉落)
function i3k_sbean.role_del_survive_items.handler(res)
	--self.gis:		vector[GameItem]	
	for _, v in ipairs(res.gis) do
		g_i3k_game_context:UseDesertBattleItem(v.id, v.count)
	end
end

-- 暂时弃用
-- 添加副本道具
function i3k_sbean.survive_add_item.handler(res)
	--self.id:		int32	
	--self.count:		int32	
end

-- 同步个人积分排行榜
--[[
	local bean = i3k_sbean.survive_score_rank_query.new()
	i3k_game_send_str_cmd(bean, "survive_score_rank")
]]

-- 同步个人积分排行榜(survive_score_rank_query 的异步回应)
--[[
RankSurvive
	├──roleID (int32)
	├──roleName (string)
	└──rankKey (int32)
]]
function i3k_sbean.survive_score_rank.handler(res)
	--self.ranks:		vector[RankSurvive]	
	--self.selfRank:		int32
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleFubenDesert,'updateRank',res)
end

-- map进入地图同步信息(lifes: 队友命数包括自己)
function i3k_sbean.survive_map_info.handler(res)
	--self.lifes:		map[int32, int32]	
	--self.leftRoles:		int32	
	--self.score:		int32	
	g_i3k_game_context:setDesertBattleMapinfo(res)
	g_i3k_game_context:refreshDesertBattleScoreTitle()
	if g_i3k_ui_mgr:GetUI(eUIID_BattleFubenDesert) then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleFubenDesert,'updateMapInfo')
	end
end

-- 个人积分变化通知
function i3k_sbean.survive_score_update.handler(res)
	if res then
		g_i3k_game_context:setDesertBattleMapScore(res.score)
		g_i3k_game_context:refreshDesertBattleScoreTitle()
	end
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleFubenDesert,'updatePersonScore', res.score)
end

-- 剩余玩家变化通知
function i3k_sbean.survive_leftrole_update.handler(res)
	--self.left:		int32	
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleFubenDesert,'updateLeftPersonCount', res.left)	
end

--同步玩家观战信息
function i3k_sbean.role_view_info.handler(res)	
	if res.viewer then
		local view = res.viewer.overview
		local world = i3k_game_get_world();
		local entityPlayer = world:GetEntity(eET_Player, view.id);
				
		if entityPlayer then
			if g_i3k_ui_mgr:GetUI(eUIID_DesertBattleWatchWar) then
				g_i3k_ui_mgr:RefreshUI(eUIID_DesertBattleWatchWar, view.name)
			else
				g_i3k_logic:OpenDesertBattleWatchWarUI(view.name)
			end		
			
			g_i3k_game_context:desertBattleWatchWar(entityPlayer)
		else
			local rotation = res.rotation
			local position = res.position
			local viewer = res.viewer
			local overview = viewer.overview			
			local model = viewer.model
			local title = viewer.title
			local state = viewer.state
			local appearance = viewer.appearance
			local mulRoleType = appearance.mulRoleType
			local buffDrugs = viewer.buffdrugs
			local petAlter = viewer.petAlter
			local combatType = viewer.combatType
			local args = map_unicast.getArgsFromBean(overview, model, title, state, appearance, buffDrugs, petAlter, combatType)
			local r_x = rotation.x;
			local r_y = rotation.y;
			local r_z = rotation.z;
			local StartPos = {x = position.x, y = position.y, z = position.z}
			local r = i3k_vec3_angle2(i3k_vec3(r_x, r_y, r_z), i3k_vec3(1, 0, 0));
			local Dir_p = {x = 0 ,y = r ,z = 0 }
			world:CreateOnlyPlayerModelFromCfg(view.id, StartPos, Dir_p, args, g_i3k_game_context:GetForceType())
			local entityPlayer = world:GetEntity(eET_Player, view.id);
			
			if entityPlayer then											
				if g_i3k_ui_mgr:GetUI(eUIID_DesertBattleWatchWar) then
					g_i3k_ui_mgr:RefreshUI(eUIID_DesertBattleWatchWar, view.name)
				else
					g_i3k_logic:OpenDesertBattleWatchWarUI(view.name)				
				end
				
				g_i3k_game_context:desertBattleWatchWar(entityPlayer)
			end			
		end
	else
		--结束
		g_i3k_game_context:setdesertBattleViewEntity(nil)
	end
end

function i3k_sbean.requireOtherView(roleID)
	local bean = i3k_sbean.role_set_view.new()
	bean.roleID = roleID
	i3k_game_send_str_cmd(bean)
end

--self.curHero:		int32	
	--self.score:		int32	
	--self.champion:		int32	
	--self.punishTime:		int32	
	--self.log:		SurviveArenaLog	
--同步玩家吃鸡和总积分信息
function i3k_sbean.sync_role_survive_info.handler(bean)
	local roleInfo = bean.roleSurvive
	g_i3k_game_context:SetDesertBattleTotalScore(roleInfo.score, roleInfo.champion)
end

-- gs 进入地图同步信息
function i3k_sbean.survive_map_sync.handler(bean)
	--self.curHero:		int32	
	--self.wearEquips:		map[int32, int32]	
	--self.bag:		map[int32, int32]	
	--self.lastUseDrugTime:		int32
	local world = i3k_game_get_world();
	local player = i3k_game_get_player()
	local hero = i3k_game_get_player_hero()

	g_i3k_game_context:setBattleDesertCurHero(bean.curHero)
	g_i3k_game_context:SetDesertBattleBagItems(bean.bag)
	g_i3k_game_context:SetDesertBattleEquipData(bean.wearEquips)

	if player and not hero._inDesertBattle then
		world:OnPlayerEnterWorld(nil);
		player:SetDesertBattleEntity(bean.curHero)
		world:OnPlayerEnterWorld(player);
	end
	
	g_i3k_game_context:SetDesertLastUseDrugTime(bean.lastUseDrugTime)
	g_i3k_game_context:InitDesertBetterEquipState()
end
-- 决战荒漠副本开始通知
function i3k_sbean.survive_map_start.handler(bean)
	g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_DESERT, g_SCHEDULE_COMMON_MAPID) --添加活跃度
end

-- 个人最终积分结果
function i3k_sbean.survive_final_score_result()
	local bean = i3k_sbean.survive_final_score_result_req.new()
	i3k_game_send_str_cmd(bean)
end

function i3k_sbean.survive_final_score_result_res.handler(bean)
	g_i3k_ui_mgr:OpenUI(eUIID_DesertPersonalResult)
	g_i3k_ui_mgr:RefreshUI(eUIID_DesertPersonalResult, bean.result, bean.rewards)
end

-- 所在队伍最终结果
function i3k_sbean.survive_final_team_result.handler(bean)
	g_i3k_ui_mgr:OpenUI(eUIID_DesertTeamResult)
	g_i3k_ui_mgr:RefreshUI(eUIID_DesertTeamResult, bean.result, bean.selfRewards, bean.teamRewards)
end

--self.round:		int32	
--self.refreshTime:		int32	
--self.gatheredIDs:		vector[int32]
--决战补给点信息
function i3k_sbean.survive_supply_infos.handler(bean)
	
	g_i3k_game_context:SetDesertBattleResInfo(bean)
	local world = i3k_game_get_world()
	if world  then		
		world:ChangeDesertBattleRes()		
	end
end

--队友命数变化通知 包括自己
	--self.rid: int32
	--self.lifes: int 32
function i3k_sbean.survive_member_life_update.handler(bean)
	g_i3k_game_context:refreshDesertBattleMemberLifes(bean.rid, bean.lifes)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleFubenDesert, 'setMembersLife', bean.rid, bean.lifes)
end

--毒圈信息
--self.round:		int32	
--self.safeOrigin:		Vector3	
--self.poisonOrigin:		Vector3	
--self.roundEndTime:		int32	
function i3k_sbean.survive_safe_area_infos.handler(bean)
	g_i3k_game_context:setPoisonCircleInfo(bean)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_DesertBattleMiniMap, "updatePoisonFog")
	local world = i3k_game_get_world()
	if world then
		local safeInfo, poisonInfo, time, sleepTime = g_i3k_db.i3k_db_get_desert_battle_poisonCircle()
		world:UpdateDesertPoisonInfo()
		local cfg = i3k_db_desert_battle_base
		local modelID = cfg.poisonModelID
		local poisonEntity = world:GetEntity(eET_Common, modelID)
		if not poisonEntity then --创建毒圈
			if poisonInfo then
				-- g_i3k_ui_mgr:PopupTipMessage("~~~场景毒圈~~~")
				local common = require("logic/entity/i3k_entity_common")
				local poisonEntity = common.i3k_entity_common.new(world:CreateOnlyGuid(1, eET_Common, modelID))
				poisonEntity:Create(modelID);
				poisonEntity:SetHittable(false);
				poisonEntity:Show(true);
				poisonEntity:Play("stand", -1);
				poisonEntity:NeedUpdateAlives(false);
				poisonEntity:ShowTitleNode(true);
				poisonEntity:SetPos(poisonInfo.pos)
				poisonEntity:SetScale(poisonInfo.radius / cfg.poisonEffectRadius)
				world:AddEntity(poisonEntity)
			end
		end
	end
end


function i3k_sbean.nearby_survive_kill.handler(bean)
	g_i3k_game_context:onSyncBroadcast({
		id= -i3k_game_get_time(),
		type = bean.out + 46,
		sendTime = i3k_game_get_time(),
		lifeTime = 60,
		freq = 0,
		content = bean.killer.name.."|"..bean.deader.name,
	})
end
