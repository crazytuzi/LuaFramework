
------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/network/channel/i3k_channel")
local TIMER = require("i3k_timer");
i3k_game_faction_slow_timer = i3k_class("i3k_game_timer", TIMER.i3k_timer);

-- 搜索帮派信息响应协议
function i3k_sbean.sect_searchbyname_res.handler(bean,res)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	local data = bean.overview
	if not data or  not data.sectId then
		g_i3k_ui_mgr:PopupTipMessage("您搜索的帮派不存在，请确认是否输入错误")
		return
	end
	g_i3k_game_context:SearchFactionList(data)
end

-- 搜索帮派信息响应协议
function i3k_sbean.sect_searchbyid_res.handler(bean, res)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	local data = bean.overview
	if not data or not data.sectId then
		g_i3k_ui_mgr:PopupTipMessage("您搜索的帮派不存在，请确认是否输入错误")
		return
	end
	g_i3k_game_context:SearchFactionList(data)
end

-- 刷新帮派列表响应协议
function i3k_sbean.sect_list_res.handler(bean,res)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	local data = bean.list
	if not data or  not next(data) then
		g_i3k_ui_mgr:PopupTipMessage("暂无帮派信息")
		--return
	end
	local tmp_select = g_i3k_game_context:GetFactionSelectData()
	local tmp = {}
	for k,v in pairs(tmp_select) do
		table.insert(tmp,k)
	end
	i3k_sbean.is_faction_apply(tmp,data,res.layer or 0)
	--g_i3k_game_context:FactionPartList(data)
end

-- 批量查询帮派是否被申请响应协议
function i3k_sbean.is_faction_apply(data,listData,layer)
	local data = i3k_sbean.sect_queryapplied_req.new()
	data.sects = data
	data.listData = listData
	data.layer = layer
	i3k_game_send_str_cmd(data,i3k_sbean.sect_queryapplied_res.getName())
end

function i3k_sbean.sect_queryapplied_res.handler(res,req)
	local applied = res.applied
	g_i3k_game_context:SetFactionSelectData({})
	g_i3k_game_context:AddFactionSelectId(applied)
	g_i3k_game_context:FactionPartList(req.listData,req.layer)
end

--帮派创建成功
function i3k_sbean.sect_create_res.handler(bean,res)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	local is_ok = bean.ok
	if is_ok > 0 then
		--扣钱
		g_i3k_game_context:RemoveFactionCreateMoney(res.useStone)
		local data = i3k_sbean.sect_sync_req.new()
		data.create = 1
		i3k_game_send_str_cmd(data,i3k_sbean.sect_sync_res.getName())
		g_i3k_ui_mgr:CloseUI(eUIID_Bangpai)
		g_i3k_ui_mgr:CloseUI(eUIID_CreateFaction)

		DCEvent.onEvent("创建帮派", { ["帮派ID"] = tostring(bean.ok) } )
	end
end

--帮派成员查询返回
function i3k_sbean.sect_members_res.handler(bean,res)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	if not bean or not bean.members then
		return
	end
	if res.state and res.state == 1 then
		g_i3k_ui_mgr:OpenUI(eUIID_FactionLayer)
		g_i3k_ui_mgr:RefreshUI(eUIID_FactionLayer)
	end
	g_i3k_game_context:FactionMemebersData(bean.members.chief,bean.members.deputy ,bean.members.elder,bean.members.elite,bean.members.members,res.fun)
	if res.callBack then
		res.callBack()
	end
end

--帮派申请列表查询返回
function i3k_sbean.sect_applications_res.handler(bean,res)
	if not bean then
		return
	end
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	g_i3k_game_context:FactionApplyList(bean.applications)
end

--帮派事件查询返回
function i3k_sbean.sect_history_res.handler(bean,res)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end

	g_i3k_game_context:FactionThingList(bean.history)
end

--申请或取消加入帮派返回
function i3k_sbean.sect_apply_res.handler(bean,res)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	local is_ok = bean.ok
	if is_ok > 0 then
		--TODO此处或许该有提示
		g_i3k_game_context:FactionApplyRes(res.sectId)
	end
end


--打开帮派同步帮派信息
function i3k_sbean.sect_sync_res.handler(bean,res)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	if res.create and res.create == 1 then
		DCEvent.onEvent("帮派创建成功")
		g_i3k_ui_mgr:PopupTipMessage("帮派创建成功，祝帮主千秋万载，一统江湖")
	end
	g_i3k_game_context:setDragonCrystal(bean.info.dragonCrystal)
	local doNotOpenUI = res.doNotOpenUI
	g_i3k_game_context:setlastjointime(bean.info.data.lastJoinTime)
	g_i3k_game_context:FactionSyncRes(bean.info,res.callBack,res.isSchedule, doNotOpenUI)
	if res.fun then
		res.fun()
	end
end

--帮派技能查询
function i3k_sbean.sect_aurasync_res.handler(bean,res)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	local auras = bean.auras
	if not auras then
		return
	end
	g_i3k_ui_mgr:CloseUI(eUIID_FactionResearch)
	g_i3k_game_context:FactionSkillRes(auras)
end


function i3k_sbean.sect_renming_pos(id,pos)
	local data = i3k_sbean.sect_appoint_req.new()
	data.roleId = id
	data.position = pos
	i3k_game_send_str_cmd(data,i3k_sbean.sect_appoint_res.getName())
end

--帮派任命
function i3k_sbean.sect_appoint_res.handler(bean,res)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	local is_ok = bean.ok
	if is_ok > 0 then
		local data = i3k_sbean.sect_members_req.new()
		i3k_game_send_str_cmd(data,i3k_sbean.sect_members_res.getName())
		if res.position ~= 1 then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionControlLayer,"updateMemberJob",res.position)
		else
			g_i3k_ui_mgr:CloseUI(eUIID_FactionControlLayer)
		end
	end

end

--踢出帮派
function i3k_sbean.sect_kick_res.handler(bean,res)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	local is_ok = bean.ok
	if is_ok > 0 then
		g_i3k_game_context:RemoveFactionCurrentMemberCount(1)
		local data = i3k_sbean.sect_members_req.new()
		if res.fun then
			data.fun = res.fun
		end
		i3k_game_send_str_cmd(data,i3k_sbean.sect_members_res.getName())
		g_i3k_game_context:AddFactionKickTimes(1)
	end
end

--离开帮派
function i3k_sbean.sect_leave_res.handler(bean,res)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		if bean.ok == -18 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3099))
		else
			g_i3k_ui_mgr:PopupTipMessage(tips)
		end
		return
	end
	local is_ok = bean.ok
	if is_ok > 0 then
		g_i3k_ui_mgr:CloseUI(eUIID_FactionMain)
		g_i3k_ui_mgr:CloseUI(eUIID_FactionLayer)
		--TODO 理论上要清除数据
		g_i3k_game_context:ClearFactionData()
	end
	g_i3k_game_context:ChangPKMode();
end

--升级帮派
function i3k_sbean.sect_upgrade_res.handler(bean,res)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	local is_ok = bean.timestamp
	if is_ok > 0 then
		g_i3k_game_context:FactionUpGrade(is_ok)
	end
	g_i3k_game_context:LeadCheck()
end

--帮派升级加速
function i3k_sbean.sect_accelerate_res.handler(bean,res)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	local is_ok = bean.timestamp
	if is_ok > 0 then
		local faction_lvl = g_i3k_game_context:GetFactionLevel()

		local needTime = res.accTime

		local needIngot = i3k_db_faction_uplvl[faction_lvl + 1].consumeIngot

		local _money = math.ceil(needTime * needIngot/10000)
		--扣钱
		g_i3k_game_context:UseDiamond(_money ,true,AT_ACCELERATE_UPGRADE_COOLING)
		g_i3k_game_context:SetFactionUpGradeTime(is_ok)

		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionMain,"updateBaseData",g_i3k_game_context:GetFactionLevel(),g_i3k_game_context:GetFactionSectId(),g_i3k_game_context:GetFactionCurrentMemberCount(),
			g_i3k_game_context:GetFactionUpGradeTime())
	end
end

--帮派技能捐献技能书
function i3k_sbean.sect_auraexpadd_res.handler(bean,res)
	if bean.ok == -17 then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(841,res.level))
	end
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	local is_ok = bean.ok
	if is_ok > 0 then
		g_i3k_game_context:FactionContributionBookRes(res.auraId, res.itemId, res.level, is_ok)

		DCEvent.onEvent("帮派技能捐献" , { itemId = tostring(res.itemId)})
	else
		g_i3k_ui_mgr:PopupTipMessage("请先提升帮派等级")
	end
end

--帮派膜拜
function i3k_sbean.sect_worship_res.handler(bean,res)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	local is_ok = bean.ok
	if is_ok > 0 then
		g_i3k_game_context:FactionWorshipRes(res.type)
	else
		g_i3k_ui_mgr:PopupTipMessage("膜拜失败")
	end
end

--开启宴席
function i3k_sbean.sect_openbanquet_res.handler(bean,res)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	local is_ok = bean.ok
	if is_ok > 0 then
		local _type = res.type
		g_i3k_game_context:FactionOpenBanquet(res.type)

		DCEvent.onEvent("帮派宴席开启", { ["宴席类型"] = tostring(res.type)})
	else
		g_i3k_ui_mgr:PopupTipMessage("开启宴席次数已满")
	end
end

--宴席列表
function i3k_sbean.sect_listbanquet_res.handler(bean,res)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	if not bean or not bean.banquets then
		return
	end
	local banquets = bean.banquets
	if next(banquets) then
		g_i3k_game_context:FactionBanquetList(banquets)
	else
		g_i3k_ui_mgr:PopupTipMessage("当前没有已开启宴席，参与失败")

	end
end

--参加宴席
function i3k_sbean.sect_joinbanquet_res.handler(bean,res)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	g_i3k_game_context:FactionJoinBanquet(bean.ok,res.bid)

	DCEvent.onEvent("帮派宴席参与：", { ["宴席ID"] = tostring(res.bid)})
end

--帮派商店
function i3k_sbean.sect_shopsync_res.handler(bean,res)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	local info = bean.info
	if not info then
		return
	end
	g_i3k_game_context:SetSectContribution(bean.currency)
	g_i3k_game_context:setSectHonor(bean.currency2)
	g_i3k_game_context:setDefenceWarCurrentCityState(bean.OwnedCity)
	g_i3k_ui_mgr:OpenUI(eUIID_PersonShop)
	g_i3k_ui_mgr:RefreshUI(eUIID_PersonShop, info, g_SHOP_TYPE_FACTION, bean.discount)
end

--帮派货物刷新
function i3k_sbean.sect_shoprefresh_res.handler(bean,req)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	local info = bean.info
	if not info then
		return
	end
	--TODO扣钱
	--[[local goods = info.goods
	g_i3k_game_context:FactionStoreRefreshRes(goods, req.isSecondType, req.coinCnt)--]]
	local moneytype = 0
	if req.isSecondType > 0 then
		moneytype = g_BASE_ITEM_DIAMOND
	else
		moneytype = g_BASE_ITEM_SECT_MONEY
	end
	g_i3k_game_context:UseCommonItem(moneytype, req.coinCnt, AT_USER_REFRESH_SHOP)
	g_i3k_ui_mgr:RefreshUI(eUIID_PersonShop, info, g_SHOP_TYPE_FACTION, req.discount)
end

--帮派商店购买道具
function i3k_sbean.sect_shopbuy(index, info, discount, discountCfg)
	local bean = i3k_sbean.sect_shopbuy_req.new()
	bean.seq = index
	bean.info = info
	bean.discount = discount
	bean.discountCfg = discountCfg
	i3k_game_send_str_cmd(bean, "sect_shopbuy_res")
end

function i3k_sbean.sect_shopbuy_res.handler(bean, req)
	local is_ok = bean.ok
	if is_ok > 0 then
		local info = req.info
		local index = req.seq
		local shopItem = i3k_db_faction_store.item_data[info.goods[index].id]
		local tips = i3k_get_string(189, shopItem.itemName.."*"..shopItem.itemCount)
		info.goods[index].buyTimes = 1
		local count1 = req.discount > 0 and (shopItem.moneyCount * req.discount / 10) or shopItem.moneyCount
		local count2 = req.discount > 0 and (shopItem.moneyCount2 * req.discount / 10) or shopItem.moneyCount2
		g_i3k_game_context:UseBaseItem(g_BASE_ITEM_SECT_MONEY, math.ceil(count1), AT_BUY_SHOP_GOOGS)
		g_i3k_game_context:UseBaseItem(g_BASE_ITEM_SECT_HONOR, math.ceil(count2), AT_BUY_SHOP_GOOGS)
		g_i3k_ui_mgr:RefreshUI(eUIID_PersonShop, info, g_SHOP_TYPE_FACTION, req.discountCfg)
		g_i3k_ui_mgr:PopupTipMessage(tips)
		DCItem.buy(shopItem.itemId, g_i3k_db.i3k_db_get_common_item_is_free_type(shopItem.itemId), shopItem.itemCount, math.ceil(count1), shopItem.moneyType, AT_BUY_SHOP_GOOGS)
	elseif is_ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(50065))
	end
end


--帮派副本结束
function i3k_sbean.role_sectmap_result.handler(bean,res)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	g_i3k_game_context:FactionDungeonResult(bean.mapId,bean.progress,bean.damage,bean.accDamageRank,
	bean.maxDamageRank,bean.extraReward,bean.items,bean.goldReward)

	local tmp_dungeon = {}
		for k, v in pairs(i3k_db_faction_dungeon) do
			table.insert(tmp_dungeon,v)
		end
		table.sort(tmp_dungeon,function (a,b)
			return a.enterLevel < b.enterLevel
		end)
	local fun = function ()
			local data = i3k_sbean.sectmap_query_req.new()
			local state = g_i3k_game_context:getFacionDungeonState();
			local special = g_i3k_game_context:getSpecialDungeonID();
			local specialDungeon = i3k_db_faction_dungeon[bean.mapId].specialDungeon;
			data.mapId = bean.mapId
			if specialDungeon and specialDungeon > 0 then
				if state and state.open[specialDungeon] == 1 then
					data.mapId = specialDungeon
				else
				end
			elseif specialDungeon == -1 and state and state.open[bean.mapId] ~= 1 then
				data.mapId = special[bean.mapId]
			end
			i3k_game_send_str_cmd(data,i3k_sbean.sectmap_query_res.getName())
		end

	local fun1 = function ()
			local data = i3k_sbean.sectmap_status_req.new()
			data.fun = fun
			i3k_game_send_str_cmd(data,i3k_sbean.sectmap_status_res.getName())
		end
		local fun2 = function ()
			local data = i3k_sbean.sect_sync_req.new()
			data.callBack = fun1
			i3k_game_send_str_cmd(data,i3k_sbean.sect_sync_res.getName())
		end
	g_i3k_game_context:SetMapLoadCallBack(fun2)

end
--帮派副本结束
function i3k_sbean.role_sectmap_end.handler(res)
	local mapId = res.mapId
	local progress = res.progress
	if progress >= 10000 then
		i3k_engine_set_frame_interval_scale(i3k_db_faction_dungeon[mapId].fuben_frame);
		-------------------------------------------

		local Etime = i3k_db_faction_dungeon[mapId].slowtime
		Etime = Etime * 1000
		local logic = i3k_game_get_logic()
		if logic then
			logic:RegisterTimer(i3k_game_faction_slow_timer.new(Etime,true));
		end
		local world = i3k_game_get_world()
			if world then
			for k,v in pairs(world._entities[eGroupType_O]) do
				v._behavior:Set(eEBPrepareFight)
			end
		end
		-------------------------------------------
	end

end

function i3k_game_faction_slow_timer:Do(args)
	--i3k_log("i3k_game_timer");
	i3k_engine_set_frame_interval_scale(1);
	return true;
end

--帮派副本开始
function i3k_sbean.role_sectmap_start.handler(res)
	local mapId = res.mapId
	g_i3k_game_context:ClearFindWayStatus()
	g_i3k_game_context:addDungeonEnterTimes(mapId)
	g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_SECTDUNG, g_SCHEDULE_COMMON_MAPID)
end

--教义
function i3k_sbean.sect_changecreed_res.handler(bean,res)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	local is_ok = bean.ok
	if is_ok > 0 then
		g_i3k_game_context:FactionChangeCreed(res.creed)
		g_i3k_ui_mgr:CloseUI(eUIID_FactionCreed)
	end
end

--副本重置
function i3k_sbean.sectmap_open_res.handler(bean,res)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	local is_ok = bean.ok
	if is_ok > 0 then
		g_i3k_ui_mgr:OpenUI(res.isOpen and eUIID_FactionDungeonOpenAni or eUIID_FactionDungeonResetAni)
		g_i3k_game_context:FactionDungeonReset(res.mapId)
	end
end

--进入副本
function i3k_sbean.sectmap_start_res.handler(bean,res)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	local is_ok  = bean.ok
	if is_ok > 0 then
		local map = {}
		local mapID = res.mapId
		local cfg = i3k_db_dungeon_base[mapID]
		local eventId = "进入帮派副本"
		map["副本ID"] = tostring(mapID)
		DCEvent.onEvent(eventId, map)
		g_i3k_game_context:UseVit(i3k_db_faction_dungeon[mapID].physicalCount,AT_SECT_MAPCOYP_ONSTART)
	else
		g_i3k_ui_mgr:PopupTipMessage("进入帮派副本失败")
	end
end

--奖励分配记录
function i3k_sbean.sectmap_rewards_res.handler(bean,res)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	local logs = bean.logs or {}
	if next(logs) then
		g_i3k_game_context:SetFactionDungeonAwardRecord(logs)
		g_i3k_ui_mgr:OpenUI(eUIID_FactionDungeonFenpei)
		g_i3k_ui_mgr:RefreshUI(eUIID_FactionDungeonFenpei,logs)
	else
		g_i3k_ui_mgr:PopupTipMessage("目前没有奖励记录")
	end
end

--当前副本奖励分配信息
function i3k_sbean.sectmap_allocation_res.handler(bean,res)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	g_i3k_game_context:FactionDungeonAllocationRes(bean.allocation,res.mapId)
end

--申请帮派副本奖励
function i3k_sbean.sectmap_apply_res.handler(res,req)
	if res.ok > 0 then
		g_i3k_game_context:FactionApplyDungeonItemRes(req.rewardId,req.mapId)
	end
end

--伤害记录
function i3k_sbean.sectmap_damage_res.handler(bean,res)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	local damage = bean.damage

	g_i3k_game_context:SetFactionDungeonDamage(damage)


	g_i3k_ui_mgr:OpenUI(eUIID_FactionDamageRank)
	g_i3k_ui_mgr:RefreshUI(eUIID_FactionDamageRank)
end

--副本总体进度
function i3k_sbean.sectmap_query_res.handler(bean,res)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	if not bean then
		return
	end
	g_i3k_ui_mgr:OpenUI(eUIID_FactionDungeon)
	g_i3k_ui_mgr:RefreshUI(eUIID_FactionDungeon,1,res.mapId)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionDungeon,"updateDungeonList",g_i3k_game_context:getFacionDungeonState(),g_i3k_game_context:GetFactionVitality(),
	g_i3k_game_context:GetFactionDayVitality(), res.mapId)
	g_i3k_game_context:FactionDungeonProgress(bean.status.bossLostHp,bean.status.dayResetTimes,res.mapId)

end


--同步副本详细进度
function i3k_sbean.sectmap_sync_res.handler(bean,res)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	local info = bean.info
	if not info then
		return
	end
	g_i3k_game_context:FactionDungeonDetailProgress(info.progress,info.curAttacker,res.mapId)
end




--同意申请
function i3k_sbean.sect_appliedby_res.handler(bean,res)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		local roleID = res.roleId
		--删除数据
		g_i3k_game_context:RemoveFactionOneApply(roleID)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionLayer,"updateApplyData",g_i3k_game_context:GetFactionApplyData())
		return
	end
	g_i3k_game_context:FactionAgreeApply(bean.ok,res.roleId,res.accept)

	if res.accept == 1 then
		DCEvent.onEvent("加入帮派", { ["帮派ID"] = tostring(g_i3k_game_context:GetFactionSectId()) } )
	end
end

--全部拒绝申请
function i3k_sbean.sect_appliedbyall_res.handler(bean,res)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	local is_ok = bean.ok
	if is_ok > 0 then
		--删除数据
		g_i3k_game_context:FactionRefuseAllApply()
	end
end
--有人申请的同步协议
function i3k_sbean.sect_notice_application.handler(bean,res)
	g_i3k_game_context:FactionNoticeApply()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_XB,"updateFactionRed",true)
end

--同步当前申请人数
function i3k_sbean.sect_applications_number.handler(res)
	if i3k_game_get_map_type() == g_FIELD then
		local num = res.num
		if num >= i3k_db_common.faction.appliy_push_count then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase,"updateFactionApplyTips",true)
		end
	end
end

--帮派推送是否开启
function i3k_sbean.open_notice(ok)
	local data = i3k_sbean.sect_push_application_req.new()
	data.ok = ok
	i3k_game_send_str_cmd(data,i3k_sbean.sect_push_application_res.getName())
end

function i3k_sbean.sect_push_application_res.handler(res,req)
	if res.ok > 0 then
		g_i3k_game_context:SetFactionIsOpenNoticeState(req.ok)
	end
end



--帮派个人任务详细信息
function i3k_sbean.sect_task_sync_res.handler(bean,res)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	if not bean or not bean.sectTask then
		return
	end
	local sectTask = bean.sectTask
	g_i3k_ui_mgr:OpenUI(eUIID_FactionTask)
	g_i3k_ui_mgr:RefreshUI(eUIID_FactionTask)
	g_i3k_game_context:FactionTaskDetail(sectTask.dayRefreshCount,sectTask.dayFinishedCount,sectTask.tasks,res.callBack)
end

--共享任务开始
function i3k_sbean.sect_share_task_sync_start.handler(bean,res)
	--
	local stCancelTime = bean.stCancelTime
	g_i3k_game_context:setShareTaskPunishTime(stCancelTime)
	g_i3k_game_context:cleanFactionShareTask()
end

--详细信息
function i3k_sbean.sect_share_task_sync_info.handler(bean,res)
	local tasks = bean.tasks

	for k,v in pairs(tasks) do

		g_i3k_game_context:addFactionShareTaskData(v)
	end

end

--信息结束
function i3k_sbean.sect_share_task_sync_end.handler(bean,res)

end

--消息同步完毕
function i3k_sbean.sect_share_task_sync_res.handler(bean,res)
	local is_ok = bean.ok
	if is_ok > 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_FactionTask)
		g_i3k_ui_mgr:RefreshUI(eUIID_FactionTask)
		local currentTaskID,currentTaskValue,receiveTime,roleName = g_i3k_game_context:getFactionTaskIdValueTime()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionTask,"updateTaskShareData",g_i3k_game_context:getFactionShareTaskData(),g_i3k_game_context:GetRoleId(),g_i3k_game_context:getFactionTaskRoleId(),
		g_i3k_game_context:getFactionTaskGuid(),currentTaskID,currentTaskValue,receiveTime,roleName)

	end
end


--完成的任务
function i3k_sbean.sect_finish_task_sync_res.handler(bean,res)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	g_i3k_game_context:FactionFinishTask(bean.tasks.sectTask,bean.tasks.shareCount)

end

--接取帮派任务
function i3k_sbean.sect_task_receive_res.handler(bean,res)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.receiveTime)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		local data = i3k_sbean.sect_share_task_sync_req.new()
		i3k_game_send_str_cmd(data,i3k_sbean.sect_share_task_sync_res.getName())
		return
	end
	g_i3k_game_context:FactionTaskReceive(res.sid,res.taskID ,res.ownerId,res.roleName, bean.receiveTime)
	g_i3k_game_context:RefreshMissionEffect()
	--DCAccount.removeTag("帮派任务", "")
	--DCAccount.addTag("帮派任务", res.taskID)
	DCEvent.onEvent("帮派任务", {["任务ID"] = tostring(res.taskID)})
	DCTask.begin(res.taskID,DC_Other)

end

--放弃帮派任务
function i3k_sbean.sect_task_cancel_res.handler(bean,res)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	local is_ok = bean.ok
	local stCancelTime = bean.stCancelTime
	if is_ok > 0 then

		g_i3k_game_context:FactionTaskGiveUp(stCancelTime,res.ownerId)
		g_i3k_game_context:RefreshMissionEffect()
		DCAccount.removeTag("帮派任务", "")
		DCTask.fail(res.taskId,"")

		DCEvent.onEvent("帮派任务放弃", { ["任务ID"] = tostring(res.taskId)})
	end
end

--帮派任务完成
function i3k_sbean.sect_task_finish_res.handler(bean,res)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	local is_ok = bean.ok
	if is_ok > 0 then
		g_i3k_game_context:FactionTaskFinish(res.sid,res.ownerId,res.taskID)
		--g_i3k_game_context:RefreshMissionEffect()
		DCAccount.removeTag("帮派任务", "")
		local map = {}
		map["任务ID"] = res.taskID
		DCEvent.onEvent("帮派任务完成",map)
		DCTask.complete("帮派任务"..res.taskID)
		g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_SECTTASK, g_SCHEDULE_COMMON_MAPID)
	end
end

--帮派任务快速完成
function i3k_sbean.sect_quick_finish_task_res.handler(bean,res)
	if bean.ok > 0 then
		local cfg = g_i3k_db.i3k_db_get_quick_finish_task_cfg(g_QUICK_FINISH_TASK_TYPE_FACTION)
		g_i3k_game_context:UseCommonItem(cfg.needItemId, cfg.needItemCount, AT_SECT_TASK_QUICK_FINISH_CB)
		i3k_sbean.sect_task_finish_res.handler(bean,res)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16372))
	end
end

--共享任务返回
function i3k_sbean.sect_task_issuance_res.handler(bean,res)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	local is_ok = bean.ok
	if is_ok > 0 then
		g_i3k_game_context:FactionShareTaskres(res.sid,res.updateInfo)
	end
end

--帮派任务重置
function i3k_sbean.sect_task_reset_res.handler(bean,res)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	if not bean.tasks then
		g_i3k_ui_mgr:PopupTipMessage("刷新失败")
		return
	end
	g_i3k_game_context:FactionTaskReset( bean.tasks)
end

--领取收益
function i3k_sbean.sect_task_done_rewards_res.handler(bean,res)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	local is_ok = bean.ok
	if is_ok > 0 then
		g_i3k_game_context:FactionGetTaskAward(bean.taskRewards)
	end
end

function i3k_sbean.sect_disband_res.handler(bean,res)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	local is_ok = bean.ok
	if is_ok > 0 then
		g_i3k_ui_mgr:CloseUI(eUIID_FactionLayer)
		g_i3k_ui_mgr:CloseUI(eUIID_FactionMain)
		g_i3k_game_context:ClearFactionData()
		g_i3k_game_context:ChangPKMode();
	end
end

--帮派副本状态
function i3k_sbean.sectmap_status_res.handler(res,req)
	local is_ok = res.ok
	if is_ok == 1 then
		g_i3k_game_context:FactionDungeonState(res.finsihed,req.fun)
	end
end

--修改帮派名字
function i3k_sbean.sect_changename_res.handler(res,req)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(res.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	local is_ok = res.ok
	if is_ok == 1 then
		local useItem = req.useItem == 1
		g_i3k_game_context:FactionChangeName(req.name, useItem)
		g_i3k_ui_mgr:CloseUI(eUIID_FactionChangeName)
	end
end

--修改进入等级
function i3k_sbean.sect_joinlvl_res.handler(res, req)
	local is_ok = res.ok
	if is_ok == 1 then
		g_i3k_game_context:FactionChangeEnterLevel(req.level)
		if req.callback then
			req.callback()
		end
	end
end

--修改帮派图标
function i3k_sbean.sect_changeicon_res.handler(res,req)
	local is_ok = res.ok
	if is_ok == 1 then
		g_i3k_game_context:FactionChangeIconAndFrame( req.icon,req.frame)
		g_i3k_ui_mgr:PopupTipMessage("更改帮派图示成功")
	end
end

--同步膜拜奖励
function i3k_sbean.sect_syncworshipreward_res.handler(res,req)
	local ok = res.ok
	if ok == 1 then
		local data = res.data
		g_i3k_game_context:FactionWorshiprewardRes(data.dayWorshipedTimes,data.worshipReward)
	end
end


--领取膜拜奖励
function i3k_sbean.sect_takeworshipreward_res.handler(res,req)
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(10070,req.value))
	local tmp_items = {}
	local t = {id = g_BASE_ITEM_SECT_MONEY,count = req.value }
	table.insert(tmp_items,t)
	g_i3k_ui_mgr:ShowGainItemInfo(tmp_items)
	g_i3k_ui_mgr:CloseUI(eUIID_FactionGetWorshipAward)
end

--膜拜红点
function i3k_sbean.sect_notice_worship.handler(res)
	g_i3k_game_context:FactionWorshipNotice()
end

--帮派中有宴席开放并且自己没有参加过的通知协议
function i3k_sbean.sect_notice_banquet.handler(bean)
	g_i3k_game_context:FactionDineNotice(bean.banquet)
	g_i3k_game_context:SetRedEnvelopePoint(bean.redPack)
end

--帮派共享任务有奖励可以领取的红点
function i3k_sbean.sect_notice_sharedtaskreward.handler()
	g_i3k_game_context:FactionShareTaskNotice(true)
end

--
function i3k_sbean.sect_notice_tasks.handler()
	g_i3k_game_context:SetFactionResetTaskPoint(true)
end

--帮派邮件
function i3k_sbean.sect_faction_email(content)
	local data = i3k_sbean.sect_sendemail_req.new()
	data.content = content
	i3k_game_send_str_cmd(data,i3k_sbean.sect_sendemail_res.getName())
end

function i3k_sbean.sect_sendemail_res.handler(res)
	if res.ok == 2 then
		g_i3k_ui_mgr:PopupTipMessage("帮派信件发送成功")
		local common_cfg = g_i3k_db.i3k_db_get_common_cfg()
		g_i3k_game_context:UseDiamond(common_cfg.faction_email.infot_count,false,AT_SECT_SEND_MAIL_CB)
	elseif res.ok == 1 then
		g_i3k_ui_mgr:PopupTipMessage("帮派信件发送成功")
	elseif res.ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage("元宝不足，消息发放失败")
	elseif res.ok == -50 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3048))
	elseif res.ok == 0 then
		g_i3k_ui_mgr:PopupTipMessage("消息发放失败")
	else
		g_i3k_ui_mgr:PopupTipMessage("邮件发送失败")
	end
	g_i3k_ui_mgr:CloseUI(eUIID_FactionEmail)
end


--帮派运镖数据同步
function i3k_sbean.sect_escort_data()
	local data = i3k_sbean.sect_deliver_sync_req.new()
	i3k_game_send_str_cmd(data,i3k_sbean.sect_deliver_sync_res.getName())
end

function i3k_sbean.sect_deliver_sync_res.handler(res)
	if res.ok > 0 then
		local isProtect = res.isProtect
		local wishTimes = res.wishTimes
		local data = res.data
		local wishData = res.wishData
		g_i3k_game_context:SetFactionEscortSkin(res.skin)
		g_i3k_game_context:SetFactionEscortTimes(wishTimes)
		g_i3k_game_context:FactionEscortSync(data,wishTimes,wishData)
		g_i3k_game_context:SetFactionEscortData(wishData)
	end
end

--帮派运镖刷新
function i3k_sbean.refresh_escort()
	local data = i3k_sbean.sect_deliver_refresh_req.new()
	i3k_game_send_str_cmd(data,i3k_sbean.sect_deliver_refresh_res.getName())
end

function i3k_sbean.sect_deliver_refresh_res.handler(res)
	if res.ok > 0 then
		local refreshTimes = g_i3k_game_context:GetFactionEscortRefreshTimes()
		local need_ingot = 0
		if i3k_db_escort.escort_args.refresh_escort[refreshTimes + 1] then
			need_ingot = i3k_db_escort.escort_args.refresh_escort[refreshTimes + 1]
		else
			need_ingot = i3k_db_escort.escort_args.refresh_escort[#i3k_db_escort.escort_args.refresh_escort]
		end
		g_i3k_game_context:UseDiamond(need_ingot,false,AT_REFRESH_SECT_DELIVER)
		local data = res.data
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionEscort,"updateEscortData",data)
		g_i3k_game_context:AddFactionEscortRefreshTimes(1)
	end
end

--帮派运镖投镖
function i3k_sbean.escort_protect()
	local data = i3k_sbean.sect_deliver_protect_req.new()
	i3k_game_send_str_cmd(data,i3k_sbean.sect_deliver_protect_res.getName())
end

function i3k_sbean.sect_deliver_protect_res.handler(res)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("投保成功")
		g_i3k_game_context:UseDiamond(i3k_db_escort.escort_args.ensure_count,false,AT_SECT_DELIVER_PROTECT)
		g_i3k_game_context:SetEsortIsProtect(1)
	else
		local desc = i3k_get_string(564)
		g_i3k_ui_mgr:PopupTipMessage(desc)
	end
end

--帮派运镖开始
function i3k_sbean.escort_begin(routeId,vehicleId)
	local data = i3k_sbean.sect_deliver_begin_req.new()
	data.routeId = routeId
	data.vehicleId = vehicleId
	i3k_game_send_str_cmd(data,i3k_sbean.sect_deliver_begin_res.getName())
end

function i3k_sbean.sect_deliver_begin_res.handler(res,req)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(res.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	if res.ok > 0 then
		g_i3k_game_context:AddTaskToDataList(TASK_CATEGORY_ESCORT)
		g_i3k_game_context:SetFactionEscortPathId(req.routeId)
		g_i3k_game_context:SetFactionEscortTaskId(req.vehicleId)
		--g_i3k_logic:OpenBattleUI()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"updateFactionEscort")
		g_i3k_game_context:SetTransportState(1)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleMiniMap,"updateMapInfo")
		g_i3k_game_context:UseVit(i3k_db_escort.escort_args.vit_count,AT_SECT_DELIVER_BEGIN)
--		g_i3k_logic:OpenEscortAction()

		DCEvent.onEvent("帮派镖局运镖", { ["任务ID"] = tostring(req.vehicleId)})
	end
end

--帮派运镖求援
function i3k_sbean.escort_for_help()
	local data = i3k_sbean.sect_deliver_search_help_req.new()
	i3k_game_send_str_cmd(data,i3k_sbean.sect_deliver_search_help_res.getName())
end

function i3k_sbean.sect_deliver_search_help_res.handler(res)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("求援信已发出")
	elseif res.ok == -12 then
		g_i3k_ui_mgr:PopupTipMessage("帮派暂时没有可以前来救援的大侠")
	else
		local tmp_str = i3k_get_string(565)
		g_i3k_ui_mgr:PopupTipMessage(tmp_str)
	end
	g_i3k_game_context:SetEscortForHelpTime(i3k_integer(i3k_game_get_time()))
end

--帮派运镖求援响应
function i3k_sbean.escort_on_help(roleId,targetLocation,line)
	local data = i3k_sbean.sect_deliver_on_help_req.new()
	data.roleId = roleId
	data.targetLocation = targetLocation
	data.line = line
	i3k_game_send_str_cmd(data,i3k_sbean.sect_deliver_on_help_res.getName())
end

function i3k_sbean.sect_deliver_on_help_res.handler(res,req)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(res.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	if res.ok > 0 then

		g_i3k_ui_mgr:InvokeUIFunction(eUIID_EscortForHelp,"onClose")
	end
end

--取消帮派运镖
function i3k_sbean.cancel_escort()
	local data = i3k_sbean.sect_deliver_cancel_req.new()
	i3k_game_send_str_cmd(data,i3k_sbean.sect_deliver_cancel_res.getName())
end

function i3k_sbean.sect_deliver_cancel_res.handler(res)
	if res.ok > 0 then
		g_i3k_game_context:CancelEscortRes()
		g_i3k_game_context:AddFactionEscortAccTimes(1)
		g_i3k_game_context:SetEsortIsProtect(0)
		g_i3k_ui_mgr:CloseUI(eUIID_EscortAction)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "updateBattleTreasure")
		g_i3k_game_context:setBeRobbedTimes(0)
	end
end

--帮派运镖完成
function i3k_sbean.escort_finish()
	local data = i3k_sbean.sect_deliver_finish_req.new()
	i3k_game_send_str_cmd(data,i3k_sbean.sect_deliver_finish_res.getName())
end

function i3k_sbean.sect_deliver_finish_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:setBeRobbedTimes(0)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_EscortAction,"hideAllLayer")
		g_i3k_ui_mgr:OpenUI(eUIID_EscortAward)
		g_i3k_ui_mgr:RefreshUI(eUIID_EscortAward,res.rewardExp,res.rewardGold,res.timeBouns,res.robPercent,res.expBouns,res.goldBouns,res.skinExpBouns)
		g_i3k_game_context:SetFactionEscortTaskId(0)
		g_i3k_game_context:SetFactionEscortPathId(0)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"RemoveFactionEscortTaskItem")
		g_i3k_game_context:removeTaskData(TASK_CATEGORY_ESCORT)
		g_i3k_game_context:ClearFindWayStatus()
		g_i3k_game_context:SetTransportState(0)
		g_i3k_game_context:AddFactionEscortAccTimes(1)
		g_i3k_game_context:SetEsortIsProtect(0)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleMiniMap,"updateMapInfo")
		g_i3k_game_context:EscortCarMoveSync()
		g_i3k_ui_mgr:CloseUI(eUIID_EscortAction)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "updateBattleTreasure")
		g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_SECTDART, g_SCHEDULE_COMMON_MAPID)
		-- 刷新头顶文字颜色
		local logic = i3k_game_get_logic();
		if logic then
			local world = logic:GetWorld()
			local player = logic:GetPlayer();
			if player and player:GetHero() then
				local hero = player:GetHero();
				if hero then
					hero:TitleColorTest()
				end
			end
		end
		g_i3k_game_context:AddFactionEscortLuckTimes() -- 添加运镖次数
		local cardNum = g_i3k_game_context:GetEscortQuickCard()
		g_i3k_game_context:SetEscortQuickCard(cardNum + i3k_db_escort.escort_args.get_card_num)
	end
end
function i3k_sbean.escort_quick_finish(taskId)
	local data = i3k_sbean.sect_deliver_quick_finish_req.new()
	data.taskId = taskId
	data.routeId = 1
	i3k_game_send_str_cmd(data, i3k_sbean.sect_deliver_quick_finish_res.getName())
end
function i3k_sbean.sect_deliver_quick_finish_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_EscortAction,"hideAllLayer")
		g_i3k_ui_mgr:CloseUI(eUIID_EscortAction)
		g_i3k_ui_mgr:OpenUI(eUIID_EscortAward)
		g_i3k_ui_mgr:RefreshUI(eUIID_EscortAward,res.rewardExp,res.rewardGold,res.timeBouns,res.robPercent,res.expBouns,res.goldBouns,res.skinExpBouns)
		g_i3k_game_context:SetFactionEscortTaskId(0)
		g_i3k_game_context:SetFactionEscortPathId(0)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleTask,"RemoveFactionEscortTaskItem")
		g_i3k_game_context:removeTaskData(TASK_CATEGORY_ESCORT)
		g_i3k_game_context:ClearFindWayStatus()
		g_i3k_game_context:SetTransportState(0)
		g_i3k_game_context:AddFactionEscortAccTimes(1)
		g_i3k_game_context:SetEsortIsProtect(0)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleMiniMap,"updateMapInfo")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "updateBattleTreasure")
		g_i3k_game_context:ChangeScheduleActivity(g_SCHEDULE_TYPE_SECTDART, g_SCHEDULE_COMMON_MAPID)
		-- 刷新头顶文字颜色
		local logic = i3k_game_get_logic();
		if logic then
			local world = logic:GetWorld()
			local player = logic:GetPlayer();
			if player and player:GetHero() then
				local hero = player:GetHero();
				if hero then
					hero:TitleColorTest()
				end
			end
		end
		g_i3k_game_context:AddFactionEscortLuckTimes() -- 添加运镖次数
		local quickCardNum = g_i3k_game_context:GetEscortQuickCard()
		g_i3k_game_context:SetEscortQuickCard(quickCardNum - i3k_db_escort.escort_args.need_card_num)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionEscort, "refreshEscortData")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionEscort, "onEscort")
		g_i3k_ui_mgr:CloseUI(eUIID_FactionEscortPath)
	end
end
--运镖抽奖信息同步
function i3k_sbean.sect_deliver_lottery_sync.handler(bean)
	g_i3k_game_context:SetFactionEscortLuckInfo(bean.deliverLottery)
end

--帮派祝福同步
function i3k_sbean.escort_wish_sync()
	local data = i3k_sbean.sect_deliver_sync_wish_req.new()
	i3k_game_send_str_cmd(data,i3k_sbean.sect_deliver_sync_wish_res.getName())
end

function i3k_sbean.sect_deliver_sync_wish_res.handler(res)
	if res.ok > 0 then
		local wishTimes = res.wishTimes
		local data = res.data
		local rankList = res.rankList
		g_i3k_game_context:SetFactionEscortTimes(wishTimes)
		g_i3k_game_context:SetFactionEscortData(data)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionEscort,"updateWishData",data)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionEscort,"updateRank",rankList)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionEscort,"updateWishMoney",wishTimes)

		DCEvent.onEvent("帮派镖局祝福")
	end
end

--帮派祝福
function i3k_sbean.escort_wish()
	local data = i3k_sbean.sect_deliver_add_wish_req.new()
	i3k_game_send_str_cmd(data,i3k_sbean.sect_deliver_add_wish_res.getName())
end

function i3k_sbean.sect_deliver_add_wish_res.handler(res)
	if res.ok == -13 then
		local tmp_str = i3k_get_string(15160)
		g_i3k_ui_mgr:PopupTipMessage(tmp_str)
		return
	end
	if res.ok > 0 then
		i3k_sbean.escort_wish_sync()
		g_i3k_game_context:FactionEscortWish(res.data)
	end
end

--帮派祝福保存
function i3k_sbean.escort_wish_save()
	local data = i3k_sbean.sect_deliver_save_wish_req.new()
	i3k_game_send_str_cmd(data,i3k_sbean.sect_deliver_save_wish_res.getName())
end

function i3k_sbean.sect_deliver_save_wish_res.handler(res)
	if res.ok > 0 then
		i3k_sbean.escort_wish_sync()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionEscort,"updateSaveBtn",false)
	end
end

--劫镖协议
function i3k_sbean.rob_escort()
	local data = i3k_sbean.sect_rob_task_take_req.new()
	i3k_game_send_str_cmd(data,i3k_sbean.sect_rob_task_take_res.getName())
end

function i3k_sbean.sect_rob_task_take_res.handler(res)
	if res.ok > 0 then
		g_i3k_game_context:SetRobState(1)
		g_i3k_game_context:SetEscortRobState(1)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionEscortRobStore,"updateCancelRobBtn")
		local tmp_str = i3k_get_string(566)
		g_i3k_ui_mgr:PopupTipMessage(tmp_str)
		g_i3k_game_context:ChangPKMode();
		g_i3k_ui_mgr:CloseUI(eUIID_FactionEscortRobStore)
		DCEvent.onEvent("帮派镖局劫镖")
	end
end

--放弃劫镖
function i3k_sbean.cancel_rob_escort()
	local data = i3k_sbean.sect_rob_task_cancel_req.new()
	i3k_game_send_str_cmd(data,i3k_sbean.sect_rob_task_cancel_res.getName())
end

function i3k_sbean.sect_rob_task_cancel_res.handler(res)
	if res.ok > 0 then
		g_i3k_game_context:SetRobState(0)
		g_i3k_game_context:SetEscortRobState(0)
		g_i3k_game_context:AddFactionEscortRobTimes(1)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionEscortRobStore,"updateRobBtn")
		local tmp_str = i3k_get_string(567)
		g_i3k_ui_mgr:PopupTipMessage(tmp_str)
	end
end

--劫镖完成
function i3k_sbean.sect_rob_finish.handler(res)
	local tmp_items = {}
	g_i3k_ui_mgr:OpenUI(eUIID_RobEscortAnimation)
	g_i3k_ui_mgr:OpenUI(eUIID_RobEscortShowCoin)
	g_i3k_ui_mgr:RefreshUI(eUIID_RobEscortShowCoin,res.rewardnum)
	g_i3k_game_context:SetRobState(0)
	g_i3k_game_context:SetEscortRobState(0)
	g_i3k_game_context:AddFactionEscortRobTimes(1)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionEscortRobStore,"updateRobBtn")
	g_i3k_game_context:ChangPKMode();
	-- 刷新头顶文字颜色
	local logic = i3k_game_get_logic();
	if logic then
		local world = logic:GetWorld()
		local player = logic:GetPlayer();
		if player and player:GetHero() then
			local hero = player:GetHero();
			if hero then
				hero:TitleColorTest()
			end
		end
	end
end

function i3k_sbean.be_robbed_times.handler(bean)
	if bean.time then
		g_i3k_game_context:setBeRobbedTimes(bean.time)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_EscortAction, "updateGoods")
		g_i3k_ui_mgr:PopupTipMessage("<c=hlred>您已被劫镖</c>")
	end
end

--有人求援
function i3k_sbean.sect_deliver_help_push.handler(res)
	local name = res.name
	local location = res.location
	local id = res.id
	local line = res.line
	local title = "帮派救援"
	local mapName = i3k_db_dungeon_base[location.mapID].name
	local tmp_str = i3k_get_string(569,name,mapName)
	if not res.hide then
		local yes_name = i3k_get_string(51002)
		local no_name = "忽略"
		local acceptFunc = function()
			if i3k_game_get_map_type() ~= g_FIELD then
				g_i3k_ui_mgr:PopupTipMessage("先切到大地图")
				return
			end
			if i3k_check_resources_downloaded(location.mapID) then
				local function func()
					i3k_sbean.escort_on_help(id, location, line)
					g_i3k_game_context:RemoveEscortForHelpById(id)
					g_i3k_game_context:removeInviteItem(id, g_INVITE_TYPE_FACTION_HELP)
				end
				g_i3k_game_context:CheckMulHorse(func)
			end
		end
		local refuseFunc = function()
			g_i3k_game_context:removeInviteItem(id, g_INVITE_TYPE_FACTION_HELP)
		end
		g_i3k_game_context:addInviteItem(g_INVITE_TYPE_FACTION_HELP, res, acceptFunc, refuseFunc, nil, id, tmp_str, yes_name, no_name)
	else
	g_i3k_game_context:ShowSysMessage(tmp_str,title,2)
	g_i3k_game_context:AddEscortForHelpStr(name,location,id,line)
	g_i3k_logic:OpenEscortHelpTips()
	end
end


--运镖商城同步协议
function i3k_sbean.sect_escort_store_sync()
	local data = i3k_sbean.sect_deliver_shopsync_req.new()
	i3k_game_send_str_cmd(data,i3k_sbean.sect_deliver_shopsync_res.getName())
end

function i3k_sbean.sect_deliver_shopsync_res.handler(res)
	local info = res.info
	g_i3k_game_context:SetEscortStoreMoney(res.currency)
	g_i3k_ui_mgr:OpenUI(eUIID_PersonShop)
	g_i3k_ui_mgr:RefreshUI(eUIID_PersonShop, info, g_SHOP_TYPE_ESCORT, res.discount)
end

--运镖商城刷新协议
function i3k_sbean.escort_store_refresh(moneyCount,times,isSecondType, discount)
	local data = i3k_sbean.sect_deliver_shoprefresh_req.new()
	data.moneyCount = moneyCount
	data.times = times
	data.isSecondType = isSecondType
	data.discount = discount
	i3k_game_send_str_cmd(data,i3k_sbean.sect_deliver_shoprefresh_res.getName())
end

function i3k_sbean.sect_deliver_shoprefresh_res.handler(res,req)
	local info = res.info
	--g_i3k_game_context:UseEscortStoreMoney(req.moneyCount,reason)
	local moneytype
	if req.isSecondType > 0 then
		moneytype = g_BASE_ITEM_DIAMOND
	else
		moneytype = g_BASE_ITEM_ESCORTT_MONEY
	end
	g_i3k_game_context:UseCommonItem(moneytype, req.moneyCount, AT_USER_REFRESH_SHOP)
	g_i3k_ui_mgr:OpenUI(eUIID_PersonShop)
	g_i3k_ui_mgr:RefreshUI(eUIID_PersonShop, info, g_SHOP_TYPE_ESCORT, req.discount)
end

--运镖商城购买
function i3k_sbean.escort_store_buy(index, info, discount, discountCfg)
	local data = i3k_sbean.sect_deliver_shopbuy_req.new()
	data.seq = index
	data.info = info
	data.discount = discount
	data.discountCfg = discountCfg
	i3k_game_send_str_cmd(data,i3k_sbean.sect_deliver_shopbuy_res.getName())
end

function i3k_sbean.sect_deliver_shopbuy_res.handler(res, req)
	if res.ok > 0 then
		local info = req.info
		local index = req.seq
		local shopItem = i3k_db_escort_store.item_data[info.goods[index].id]
		local tips = i3k_get_string(189, shopItem.itemName.."*"..shopItem.itemCount)
		info.goods[index].buyTimes = 1
		local count = req.discount > 0 and (shopItem.moneyCount * req.discount / 10) or shopItem.moneyCount
		g_i3k_game_context:UseBaseItem(g_BASE_ITEM_ESCORTT_MONEY, math.ceil(count), AT_BUY_SHOP_GOOGS)
		g_i3k_ui_mgr:RefreshUI(eUIID_PersonShop, info, g_SHOP_TYPE_ESCORT, req.discountCfg)
		g_i3k_ui_mgr:PopupTipMessage(tips)
		DCItem.buy(shopItem.itemId,g_i3k_db.i3k_db_get_common_item_is_free_type(shopItem.itemId),shopItem.itemCount, shopItem.moneyCount, shopItem.moneyType, AT_BUY_SHOP_GOOGS)
	elseif res.ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(50065))
	end
end
--运镖抽奖
function i3k_sbean.escort_luck_draw(lotteryID, times)
	local data =  i3k_sbean.sect_deliver_lottery_req.new()
	data.lotteryID = lotteryID
	data.times = times
	i3k_game_send_str_cmd(data,i3k_sbean.sect_deliver_lottery_res.getName())
end
function i3k_sbean.sect_deliver_lottery_res.handler(res, req)
	if res.ok >0 then
		g_i3k_game_context:ReduceFactionEscortLuckTimes()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionEscortLuckDraw,"showResult",res.drops)
	else	
		if g_i3k_game_context:GetBagIsFull() then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5500))
			return
		end
		g_i3k_ui_mgr:PopupTipMessage("失败")
	end
end

--帮派邀请(主动邀请的协议)
function i3k_sbean.invite_faction(roleId)
	local data = i3k_sbean.sect_invite_req.new()
	data.roleId = roleId
	i3k_game_send_str_cmd(data,i3k_sbean.sect_invite_res.getName())
end

function i3k_sbean.sect_invite_res.handler(res,req)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(res.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	if res.ok > 0 then
		--
	end
end

--邀请响应协议（响应主动邀请的协议）
function i3k_sbean.invite_response(inviteId,response)
	local data = i3k_sbean.sect_invite_response_req.new()
	data.inviteId = inviteId
	data.response = response
	i3k_game_send_str_cmd(data,i3k_sbean.sect_invite_response_res.getName())
end

function i3k_sbean.sect_invite_response_res.handler(res,req)
	if req.response == -1 then--正忙的时候不做任何事
	else
		g_i3k_game_context:removeInviteItem(req.inviteId, g_INVITE_TYPE_FACTION)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(res.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	if res.ok > 0 then

		end
	end
end

--接到被邀请的协议（接到被邀请的协议）
function i3k_sbean.role_sect_invite.handler(res)
	local inviteId = res.inviteId
	local inviteName = res.inviteName
	local sectName = res.sectName
	local tmp_str =i3k_get_string(18583,inviteName,sectName)
	if not res.hide then
		local yes_name = i3k_get_string(1815)
		local no_name = i3k_get_string(1816)
		local acceptFunc = function ()
			i3k_sbean.invite_response(inviteId,1)
		end
		local refuseFunc = function()
			i3k_sbean.invite_response(inviteId,2)
		end
		local busyFunc = function()
			i3k_sbean.invite_response(inviteId,-1)
		end
		g_i3k_game_context:addInviteItem(g_INVITE_TYPE_FACTION, res, acceptFunc, refuseFunc, busyFunc, inviteId, tmp_str, yes_name, no_name)
		return
	end
	local fun = (function(ok)
		if ok then
			i3k_sbean.invite_response(inviteId,1)
		else
			i3k_sbean.invite_response(inviteId,2)
		end
	end)

	if not g_i3k_ui_mgr:ShowCustomMessageBox2("同意", "拒绝", tmp_str, fun) then
		i3k_sbean.invite_response(inviteId,-1)
	end
end

--拒绝邀请协议（接收到主动邀请被决绝的协议）
function i3k_sbean.role_refuse_sect_invite.handler(res)
	local beinviteName = res.beinviteName
	local tmp_str = string.format("%s拒绝了您的邀请",beinviteName)
	g_i3k_ui_mgr:PopupTipMessage(tmp_str)
end

--邀请繁忙推送（）
function i3k_sbean.sect_invite_busy.handler(res)
	local beinviteName = res.beinviteName
	local tmp_str = string.format("%s现在繁忙",beinviteName)
	g_i3k_ui_mgr:PopupTipMessage(tmp_str)
end


---帮派团队本

function i3k_sbean.team_dungeon_info(state)
	local data = i3k_sbean.sect_group_map_sync_req.new()
	data.state = state
	i3k_game_send_str_cmd(data,i3k_sbean.sect_group_map_sync_res.getName())
end

function i3k_sbean.sect_group_map_sync_res.handler(res,req)
	local sectGroupMapInfo = res.sectGroupMapInfo
	local sectMemberLevel = res.sectMemberLevel
	g_i3k_game_context:SetFactionTeamDungeonDetailData(sectGroupMapInfo)
	g_i3k_game_context:SetFactionTeamDungeonMemberLvl(sectMemberLevel)
	--if not state then
		g_i3k_ui_mgr:OpenUI(eUIID_FactionDungeon)
		g_i3k_ui_mgr:RefreshUI(eUIID_FactionDungeon,2,req.state)
	--end
end


function i3k_sbean.open_team_dungeon(mapId)  --开启帮派团队本
	local data = i3k_sbean.sect_group_map_open_req.new()
	data.mapId = mapId
	i3k_game_send_str_cmd(data,i3k_sbean.sect_group_map_open_res.getName())
end

function i3k_sbean.sect_group_map_open_res.handler(res,req)
	if res.ok > 0 then
		i3k_sbean.team_dungeon_info(req.mapId)
		local resetConsumeCount = i3k_db_faction_team_dungeon[req.mapId].resetConsumeCount
		local resetConsumeId = i3k_db_faction_team_dungeon[req.mapId].resetConsumeId
		g_i3k_game_context:UseCommonItem(resetConsumeId,resetConsumeCount,AT_RARE_BOOK_PUSH)
		--g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionDungeon,"updateTeamDropItems",i3k_db_faction_team_dungeon[req.mapId].dropItems,true)
		--g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionDungeon,"updateTeamPassItems",i3k_db_faction_team_dungeon[req.mapId].passItems,true)
	elseif res.ok == -38 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3063))
	elseif res.ok == -32 then
		local cfg = i3k_db_faction_team_dungeon[req.mapId]
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3064, cfg.dungeonOpenRoleCount, cfg.dungeonOpenRoleLvl))
		i3k_sbean.team_dungeon_info(req.mapId)
	end
end

--进入帮派团队本
function i3k_sbean.enter_team_dungeon(mapId)
	if i3k_check_resources_downloaded(mapId) then
	local data = i3k_sbean.sect_group_map_enter_req.new()
	data.mapId = mapId
	i3k_game_send_str_cmd(data,i3k_sbean.sect_group_map_enter_res.getName())
	end
end

function i3k_sbean.sect_group_map_enter_res.handler(res,req)
	if res.ok > 0 then
		local map = {}
		local mapID = req.mapId
		local cfg = i3k_db_dungeon_base[mapID]
		local eventId = "进入帮派团队副本"
		map["副本ID"] = tostring(mapID)
		DCEvent.onEvent(eventId, map)
	elseif res.ok == -39 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18111, math.floor(i3k_db_common.faction.team_dungeon_limit/3600)))
	end
end

--帮派副本结束
function i3k_sbean.sect_group_map_end.handler(res)
	if i3k_game_get_map_type() == g_FACTION_TEAM_DUNGEON then
		local mapId = res.mapId
		local finishTime = res.finishTime
		local progress = res.progress
		local rank = res.rank
		g_i3k_game_context:FactionTeamDungeonOver(mapId,finishTime,progress,rank)
	end
end


-- 5s请求刷新一次
function i3k_sbean.syncSectGroupMapInfo()
	local data = i3k_sbean.query_sect_map_cur_info.new()
	i3k_game_send_str_cmd(data)
end

-- 怪物击杀和伤害排行合并到一个协议，由客户端请求
function i3k_sbean.sect_group_map_sync_info.handler(res)
	local killNum = res.killNum
	g_i3k_game_context:SetFactionTeamKillData(killNum)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionDungeonSchedule,"updateSchedule",killNum)

	local damageRank = res.damageRank
	g_i3k_game_context:SetFactionTeamRankData(damageRank)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionDungeonSchedule,"updateIntegral",damageRank)
end

--进入帮派团队本同步协议
function i3k_sbean.enter_sect_group_map.handler(res)
	local mapId = res.mapId
	local killNum = res.killNum
	local damageRank = res.damageRank

	g_i3k_game_context:SetFactionTeamKillData(killNum)
	g_i3k_game_context:SetFactionTeamRankData(damageRank)
	g_i3k_game_context:SetFactionTeamDungeonId(mapId)
	g_i3k_ui_mgr:OpenUI(eUIID_FactionTeamDungeonBtn)

end

-- 同步地图怪物数量（通用，异步）
function i3k_sbean.query_map_monster_nums()
	local data = i3k_sbean.query_map_monster_num.new()
	i3k_game_send_str_cmd(data)
end
function i3k_sbean.point_monster_num.handler(res, req)
	local monsters = res.monsters -- key:spawn_point_id  value:nums
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionTeamDungeonMap, "updateMonsterNums", monsters)
end


----------------帮派夺旗协议--------------------
--请求地图旗帜信息
function i3k_sbean.req_big_map_flag_info(fun)
	local data = i3k_sbean.sync_big_map_flag_info_req.new()
	data.fun = fun
	data.mapId = g_i3k_game_context:GetWorldMapID()
	i3k_game_send_str_cmd(data,i3k_sbean.sync_big_map_flag_info_res.getName())
end

function i3k_sbean.sync_big_map_flag_info_res.handler(res,req)

	g_i3k_game_context:SetFactionFlagData(res.flags)
	local mapId = g_i3k_game_context:GetWorldMapID()

	-- 打开小地图前后地图类型相同
	if req.fun and mapId == req.mapId then
		req.fun()
	end
end

--同步当前地图旗帜信息
function i3k_sbean.map_flag_info.handler(res)
	local sectId = res.sect.sectId
	local sectName = res.sect.sectName
	g_i3k_game_context:SetCurrentMapFlagId(sectId)
	g_i3k_game_context:SetCurrentMapFlagName(sectName)
	if sectId == 0  then
		g_i3k_game_context:ChangeFactionFlagModle(438)
	elseif sectId == g_i3k_game_context:GetSectId() then
		g_i3k_game_context:ChangeFactionFlagModle(440)
	else
		g_i3k_game_context:ChangeFactionFlagModle(439)
	end
end

--当前地图占领旗帜改变
function i3k_sbean.map_flag_sect_change.handler(res)
	local sectId = res.sect.sectId
	local sectName = res.sect.sectName
	g_i3k_game_context:SetCurrentMapFlagId(sectId)
	g_i3k_game_context:SetCurrentMapFlagName(sectName)
	if sectId == 0 then
		g_i3k_game_context:ChangeFactionFlagModle(438)
	elseif sectId == g_i3k_game_context:GetSectId() then
		g_i3k_game_context:ChangeFactionFlagModle(440)
	else
		g_i3k_game_context:ChangeFactionFlagModle(439)
	end
end


--设置帮派qq
function i3k_sbean.set_faction_qq(qqgroup)
	local data = i3k_sbean.set_sect_qqgroup_req.new()
	data.qqgroup = qqgroup
	i3k_game_send_str_cmd(data,i3k_sbean.set_sect_qqgroup_res.getName())
end

function i3k_sbean.set_sect_qqgroup_res.handler(res,req)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(res.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	if res.ok > 0 then
		g_i3k_game_context:SetFactionQq(req.qqgroup)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionMain,"updateFationQq",req.qqgroup)
		g_i3k_ui_mgr:PopupTipMessage("设置成功")
	end
end

function i3k_sbean.sect_history_broadcast.handler(bean)
	local histMsg = bean.historyDetial
	local message = {}
	message.time = histMsg.time
	message.type = global_sect
	message.fromName = "帮派事件"
	message.factionThing = true
	message.iconId = 2426
	message.fromId = 3
	message.bwType = 0
	message.msgType = 0
	local name
	if i3k_db_faction_skill[histMsg.arg2] then
		name = i3k_db_faction_skill[histMsg.arg2][0].name
	end
	message.msg = i3k_GetFactionThingDesc(histMsg.eid, histMsg.operatorName, histMsg.memberName, histMsg.arg, name, histMsg.arg2)
	g_i3k_game_context:SetChatData(message,global_sect)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Chat, "receiveNewMsg", message)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "receiveNewMsg", message)
end

----------------------------------------------------------------------------------------
--分堂相关
--同步
function i3k_sbean.request_sect_fight_group_sync_req(callback)
	local syncTemp = i3k_sbean.sect_fight_group_sync_req.new()
	syncTemp.callback = callback
	i3k_game_send_str_cmd(syncTemp, "sect_fight_group_sync_res")
end

function i3k_sbean.sect_fight_group_sync_res.handler(bean, req)
	if bean and bean.fightGroups then
		g_i3k_game_context:setFactionFightGroupData(bean.fightGroups)
	end
	if req.callback then
		req.callback()
	end
end
--创建
function i3k_sbean.request_sect_fight_group_create_req(name,index,callback)
	local syncTemp = i3k_sbean.sect_fight_group_create_req.new()
	syncTemp.name = name;
	syncTemp.index = index;
	syncTemp.callback = callback
	i3k_game_send_str_cmd(syncTemp, "sect_fight_group_create_res")
end

function i3k_sbean.sect_fight_group_create_res.handler(bean, req)
	if bean.ok == 1 then
		req.callback()
	elseif bean.ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3098))
	elseif bean.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3089))
	elseif bean.ok == -3 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3095))
	elseif bean.ok == -4 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3109))
	elseif bean.ok == -5 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3101))
	elseif bean.ok == -6 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3097))
	elseif bean.ok == -7 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3094))
	elseif bean.ok == -8 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3112, math.floor(i3k_db_faction_fightgroup.common.time/3600).."小时"))
	elseif bean.ok == -14 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3082))
	else
		g_i3k_ui_mgr:PopupTipMessage("创建失败")
	end

	if bean.ok ~= 1 then
		--创建失败时同步下数据
		i3k_sbean.request_sect_fight_group_sync_req(function ()
			g_i3k_ui_mgr:RefreshUI(eUIID_FactionFightGroup)
		end)
	end
end
--申请
function i3k_sbean.request_sect_fight_group_apply_req(id)
	local syncTemp = i3k_sbean.sect_fight_group_apply_req.new()
	syncTemp.id = id;
	i3k_game_send_str_cmd(syncTemp, "sect_fight_group_apply_res")
end

function i3k_sbean.sect_fight_group_apply_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_ui_mgr:PopupTipMessage("申请成功")
		--g_i3k_game_context:setFightGroupApplyDataByRole(req.id)
	elseif bean.ok == -15 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3084))
	elseif bean.ok == -6 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3097))
	elseif bean.ok == -7 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3094))
	else
		g_i3k_ui_mgr:PopupTipMessage("申请失败")
	end
end
--同意
function i3k_sbean.request_sect_fight_group_accept_req(id, roleId)
	local syncTemp = i3k_sbean.sect_fight_group_accept_req.new()
	syncTemp.id = id;
	syncTemp.roleId = roleId;
	i3k_game_send_str_cmd(syncTemp, "sect_fight_group_accept_res")
end

function i3k_sbean.sect_fight_group_accept_res.handler(bean, req)
	--刷新申请信息
	if bean.ok == 1 then
		--g_i3k_ui_mgr:PopupTipMessage("操作成功")
		g_i3k_game_context:agreeFightGroupApply(req.id, req.roleId)
		g_i3k_ui_mgr:RefreshUI(eUIID_FactionFightGroup)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3106))
		--操作失败时同步下数据
		i3k_sbean.request_sect_fight_group_sync_req(function ()
			g_i3k_ui_mgr:RefreshUI(eUIID_FactionFightGroup)
		end)
	end
end
--拒绝
function i3k_sbean.request_sect_fight_group_refuse_req(id, roleIds)
	local syncTemp = i3k_sbean.sect_fight_group_refuse_req.new()
	syncTemp.id = id;
	syncTemp.roleIds = roleIds;
	i3k_game_send_str_cmd(syncTemp, "sect_fight_group_refuse_res")
end

function i3k_sbean.sect_fight_group_refuse_res.handler(bean, req)
	if bean.ok == 1 then
		--g_i3k_ui_mgr:PopupTipMessage("操作成功")
		g_i3k_game_context:agreeFightGroupApply(req.id, req.roleIds)
		g_i3k_ui_mgr:RefreshUI(eUIID_FactionFightGroup, data)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3106))
	end
end
--退出
function i3k_sbean.request_sect_fight_group_exit_req(id)
	local syncTemp = i3k_sbean.sect_fight_group_exit_req.new()
	syncTemp.id = id;
	i3k_game_send_str_cmd(syncTemp, "sect_fight_group_exit_res")
end

function i3k_sbean.sect_fight_group_exit_res.handler(bean, req)
	if bean.ok == 1 then
		--g_i3k_ui_mgr:PopupTipMessage("操作成功")
		g_i3k_game_context:kickFromFightGroup(req.id, g_i3k_game_context:GetRoleId())
		g_i3k_ui_mgr:RefreshUI(eUIID_FactionFightGroup)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3091))
	end
end
--解散
function i3k_sbean.request_sect_fight_group_dismiss_req(id)
	local syncTemp = i3k_sbean.sect_fight_group_dismiss_req.new()
	syncTemp.id = id;
	i3k_game_send_str_cmd(syncTemp, "sect_fight_group_dismiss_res")
end

function i3k_sbean.sect_fight_group_dismiss_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:dismissFightGroup(req.id)
		local fightGroup = g_i3k_game_context:getFactionFightGroupData()
		if table.nums(fightGroup) > 0 then
			g_i3k_ui_mgr:RefreshUI(eUIID_FactionFightGroup, true)
			g_i3k_game_context:setFightGroupApplyStatus(false)
		else
			g_i3k_ui_mgr:CloseUI(eUIID_FactionFightGroup)
		end
	elseif bean.ok == -7 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3094))
	else
	end
end

--修改堂主
function i3k_sbean.request_sect_fight_group_change_leader_req(id,roleId)
	local syncTemp = i3k_sbean.sect_fight_group_change_leader_req.new()
	syncTemp.id = id;
	syncTemp.roleId = roleId
	i3k_game_send_str_cmd(syncTemp, "sect_fight_group_change_leader_res")
end

function i3k_sbean.sect_fight_group_change_leader_res.handler(bean, req)
	if bean.ok == 1 then
		--g_i3k_ui_mgr:PopupTipMessage("操作成功")
		g_i3k_ui_mgr:CloseUI(eUIID_FactionMemberDetail)
		g_i3k_game_context:changeLeaderFightGroup(req.id, req.roleId)
		g_i3k_ui_mgr:RefreshUI(eUIID_FactionFightGroup, data)
	elseif bean.ok == -13 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3110))
		i3k_sbean.request_sect_fight_group_sync_req(function ()
			g_i3k_ui_mgr:RefreshUI(eUIID_FactionFightGroup)
		end)
	elseif bean.ok == -14 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3082))
		i3k_sbean.request_sect_fight_group_sync_req(function ()
			g_i3k_ui_mgr:RefreshUI(eUIID_FactionFightGroup)
		end)
	end
end

--踢出分堂
function i3k_sbean.request_sect_fight_group_kick_req(id,roleId)
	local syncTemp = i3k_sbean.sect_fight_group_kick_req.new()
	syncTemp.id = id;
	syncTemp.roleId = roleId
	i3k_game_send_str_cmd(syncTemp, "sect_fight_group_kick_res")
end

function i3k_sbean.sect_fight_group_kick_res.handler(bean, req)
	if bean.ok == 1 then
		--g_i3k_ui_mgr:PopupTipMessage("操作成功")
		g_i3k_ui_mgr:CloseUI(eUIID_FactionMemberDetail)
		g_i3k_game_context:kickFromFightGroup(req.id, req.roleId)
		g_i3k_ui_mgr:RefreshUI(eUIID_FactionFightGroup)
	elseif bean.ok == -13 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3110))
		i3k_sbean.request_sect_fight_group_sync_req(function ()
			g_i3k_ui_mgr:RefreshUI(eUIID_FactionFightGroup)
		end)
	elseif bean.ok == -14 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3082))
		i3k_sbean.request_sect_fight_group_sync_req(function ()
			g_i3k_ui_mgr:RefreshUI(eUIID_FactionFightGroup)
		end)
	end
end

--分堂改名
function i3k_sbean.request_sect_fight_group_change_name_req(id,name,callback)
	local syncTemp = i3k_sbean.sect_fight_group_change_name_req.new()
	syncTemp.id = id;
	syncTemp.name = name
	syncTemp.callback = callback
	i3k_game_send_str_cmd(syncTemp, "sect_fight_group_change_name_res")
end

function i3k_sbean.sect_fight_group_change_name_res.handler(bean, req)
	if bean.ok == 1 then
		--g_i3k_ui_mgr:PopupTipMessage("操作成功")
		if req.callback then
			req.callback()
		end
		g_i3k_ui_mgr:CloseUI(eUIID_FactionFightGroupRename)
		g_i3k_game_context:renameFightGroupById(req.id, req.name)
		g_i3k_ui_mgr:RefreshUI(eUIID_FactionFightGroup)
	elseif bean.ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3098))
	elseif bean.ok == -3 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3095))
	else
		--g_i3k_ui_mgr:PopupTipMessage("操作失败")
	end
end

--邀请入堂
function i3k_sbean.request_sect_fight_group_invite_req(id,roleId)
	local syncTemp = i3k_sbean.sect_fight_group_invite_req.new()
	syncTemp.id = id;
	syncTemp.roleId = roleId
	i3k_game_send_str_cmd(syncTemp, "sect_fight_group_invite_res")
end

function i3k_sbean.sect_fight_group_invite_res.handler(bean, req)
	if bean.ok == 1 then
		--g_i3k_ui_mgr:PopupTipMessage("操作成功")
		g_i3k_ui_mgr:CloseUI(eUIID_FactionFightGroupRename)
	elseif bean.ok == -4 then
		g_i3k_ui_mgr:PopupTipMessage("分堂数量变更")
	elseif bean.ok == -6 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3105))
	elseif bean.ok == -7 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3094))
	elseif bean.ok == -8 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3104, tostring(i3k_db_faction_fightgroup.common.time/3600).."小时"))
	elseif bean.ok == -9 then
		g_i3k_ui_mgr:PopupTipMessage("角色已加入其它分堂")
	elseif bean.ok == -10 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3106))
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3106))
	end
end

--分堂邀请推送
function i3k_sbean.sect_fight_group_invited_forward.handler(bean)
	local roleId = bean.roleId
	local roleName = bean.roleName
	local groupId = bean.groupId
	local groupName = bean.groupName

	local tmp_str = string.format("%s邀请您加入%s分堂",roleName,groupName)
	local fun = (function(ok)
		if ok then
			i3k_sbean.request_sect_fight_group_invitedby_req(groupId, roleId, 1)
		else
			i3k_sbean.request_sect_fight_group_invitedby_req(groupId, roleId, 0)
		end
	end)

	if not g_i3k_ui_mgr:ShowCustomMessageBox2("同意", "拒绝", tmp_str, fun) then
		i3k_sbean.request_sect_fight_group_invitedby_req(groupId, roleId, -1)
	end
end
--邀请答复
function i3k_sbean.request_sect_fight_group_invitedby_req(id,roleId,accept)
	local data = i3k_sbean.sect_fight_group_invitedby_req.new()
	data.id = id
	data.roleId = roleId
	data.accept = accept
	i3k_game_send_str_cmd(data,i3k_sbean.sect_fight_group_invitedby_res.getName())
end

function i3k_sbean.sect_fight_group_invitedby_res.handler(bean, req)
	if bean.ok == 1 then
		--g_i3k_ui_mgr:PopupTipMessage("操作成功")
	else
		g_i3k_ui_mgr:PopupTipMessage("操作失败")
	end
end


--邀请繁忙推送
function i3k_sbean.sect_fight_group_invite_busy.handler(res)
	local roleName = res.roleName
	local tmp_str = string.format("%s现在繁忙",roleName)
	g_i3k_ui_mgr:PopupTipMessage(tmp_str)
end

--拒绝邀请协议
function i3k_sbean.sect_fight_group_invite_refuse.handler(res)
	local roleName = res.roleName
	local tmp_str = string.format("%s拒绝了您的邀请",roleName)
	g_i3k_ui_mgr:PopupTipMessage(tmp_str)
end


--申请加入分堂推送
function i3k_sbean.sect_fight_group_apply_push.handler(res)
	i3k_sbean.request_sect_fight_group_sync_req(function()
		local groupId = g_i3k_game_context:isInFactionFightGroupLeader()
		if groupId then
			--i3k_sbean.request_sect_fight_group_apply_sync_req(groupId)
			g_i3k_game_context:setFightGroupApplyStatus(true)
		end
	end)
end

--刷新某分堂的申请列表
function i3k_sbean.request_sect_fight_group_apply_sync_req(groupId,callback)
	local syncTemp = i3k_sbean.sect_fight_group_apply_sync_req.new()
	syncTemp.id = groupId;
	syncTemp.callback = callback
	i3k_game_send_str_cmd(syncTemp, "sect_fight_group_apply_sync_res")
end

function i3k_sbean.sect_fight_group_apply_sync_res.handler(bean,req)
	if bean and bean.applys then
		if req.callback then
			req.callback()
		end
		g_i3k_game_context:setFightGroupApplyData(req.id,bean.applys)
		if table.nums(bean.applys) == 0 then
			g_i3k_game_context:setFightGroupApplyStatus(false)
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionFightGroup,"showMsgInfo")
	end
end

--帮派战报名
function i3k_sbean.sect_war_sign(groupId, callback)
	local data = i3k_sbean.sect_war_sign_req.new()
	data.id = groupId
	data.callback = callback
	i3k_game_send_str_cmd(data, "sect_war_sign_res")
end

function i3k_sbean.sect_war_sign_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_ui_mgr:PopupTipMessage("报名成功")
		if req.callback then
			req.callback()
		end
	elseif bean.ok == -16 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3124))
	else
		g_i3k_ui_mgr:PopupTipMessage("报名失败")
	end
end

--帮派战取消报名
function i3k_sbean.sect_war_quit(groupId, callback)
	local data = i3k_sbean.sect_war_quit_req.new()
	data.id = groupId
	data.callback = callback
	i3k_game_send_str_cmd(data, "sect_war_quit_res")
end

function i3k_sbean.sect_war_quit_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_ui_mgr:PopupTipMessage("取消报名成功")
		if req.callback then
			req.callback()
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("取消报名失败")
	end
end


--进入战场
function i3k_sbean.enter_sectwar(groupId)
	local data = i3k_sbean.enter_sectwar_req.new()
	data.groupId = groupId
	i3k_game_send_str_cmd(data, "enter_sectwar_res")
end

function i3k_sbean.enter_sectwar_res.handler(bean, req)
	g_i3k_game_context:ClearFindWayStatus()
	if bean.status then
		if bean.status.curStatus ~= 2 then
			g_i3k_ui_mgr:PopupTipMessage("进入失败")
		end
	end
end

--同步帮派战状态
function i3k_sbean.sect_fight_group_cur_status(callback)
	local data = i3k_sbean.sect_fight_group_cur_status_req.new()
	data.id = g_i3k_game_context:getFightGroupId()
	data.callback = callback
	i3k_game_send_str_cmd(data, "sect_fight_group_cur_status_res")
end

function i3k_sbean.sect_fight_group_cur_status_res.handler(bean, req)
	if req.callback then
		req.callback(bean)
	end
end

function i3k_sbean.queryFactionWarMemberPos()
	local data = i3k_sbean.query_sectwar_members_pos.new()
	i3k_game_send_str_cmd(data)
end

-- 异步
function i3k_sbean.sectwar_members_position.handler(bean)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionFightMap, "updateTeammatePos", bean.members)
end

-- 异步，请求旗子状态
function i3k_sbean.querySectWarFlagStatus()
	local data = i3k_sbean.query_sect_war_flag_status.new()
	i3k_game_send_str_cmd(data)
end
function i3k_sbean.sectwar_flag_status.handler(bean)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionFightMap, "updateFlagStatus", bean.status)
end

--帮派战得分
function i3k_sbean.nearby_sectwar_campscore.handler(bean)
	local forceType = g_i3k_game_context:GetForceType()
	if forceType ~= 0 then
		local whiteScore = bean.whiteScore
		local blackScore = bean.blackScore
		g_i3k_game_context:setFactionFightScore(whiteScore, blackScore)

		local myScore = forceType == 1 and whiteScore or blackScore
		local defScore = forceType == 1 and blackScore or whiteScore
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionFightGroupScore,"updateScore",myScore,defScore)
	end
end

--帮派战战报
function i3k_sbean.roles_sectwaroverview.handler(bean)
	local forceType = g_i3k_game_context:GetForceType()
	if forceType ~= 0 then
		local white = bean.white
		local black = bean.black
		local myData = forceType == 1 and white or black
		local defData = forceType == 1 and black or white

		local myGroup = forceType == 1 and bean.whiteGroup or bean.blackGroup
		local defGroup = forceType == 1 and bean.blackGroup or bean.whiteGroup

		g_i3k_ui_mgr:OpenUI(eUIID_FactionFightGroupResult)
		g_i3k_ui_mgr:RefreshUI(eUIID_FactionFightGroupResult, myData, defData, myGroup, defGroup, bean.winForceType)
	end
end
--帮派结束弹框
function i3k_sbean.role_sectwar_result.handler(bean)
	local forceType = g_i3k_game_context:GetForceType()
	if forceType ~= 0 then
		local white = bean.white
		local black = bean.black
		local myData = forceType == 1 and white or black
		local defData = forceType == 1 and black or white

		local myGroup = forceType == 1 and bean.whiteGroup or bean.blackGroup
		local defGroup = forceType == 1 and bean.blackGroup or bean.whiteGroup

		g_i3k_ui_mgr:OpenUI(eUIID_FactionFightGroupResult)
		g_i3k_ui_mgr:RefreshUI(eUIID_FactionFightGroupResult, myData, defData, myGroup, defGroup, bean.winForceType)
		g_i3k_game_context:setWinForce(bean.winForceType)
	end
end
--帮战结束
function i3k_sbean.role_sectwar_end.handler(bean)
	--帮战结束设置玩家为和平模式
	g_i3k_game_context:SetPKMode(0)
	local world = i3k_game_get_world()
	if world then
		world:setMaxTime(g_i3k_game_context:getFactionWarBoxMaxTime())
	end
end
--进地图时通知协议
function i3k_sbean.role_sectwar_fightend.handler(bean)
	if bean.winForceType ~= -1 then
		local world = i3k_game_get_world()
		if world then
			world:setMaxTime(g_i3k_game_context:getFactionWarBoxMaxTime())
		end
	end
	g_i3k_game_context:setWinForce(bean.winForceType)
end
-- 帮战首杀
function i3k_sbean.sectwar_first_blood.handler(bean, res)
	local killerName = bean.killer
	local deadName = bean.deader
	local hero = i3k_game_get_player_hero()
	if hero._name == killerName then
		g_i3k_ui_mgr:OpenUI(eUIID_ShouSha)
	end
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(557,killerName,deadName))
end


-- 帮战连杀、或者终结连杀
function i3k_sbean.nearby_sectwar_kill.handler(bean, res)
	local killerName = bean.killer
	local deadName = bean.deader
	local killerKills = bean.killerKills
	local deaderKills = bean.deaderKills
	---需要判断播哪条广播
	local  killStreaks = i3k_db_faction_fight_cfg.other.combokilllimit
	local  finalkillStreaks = i3k_db_faction_fight_cfg.other.stopComboKxill
	if deaderKills>=finalkillStreaks then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(560,killerName,deadName,deaderKills))--终结连杀
	elseif killerKills>=killStreaks then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(561,killerName,deadName,killerKills))--连杀
	end
end

--------查询帮战战报
function i3k_sbean.request_query_sectwar_result()
	local bean = i3k_sbean.query_sectwar_result.new()
	i3k_game_send_str_cmd(bean)
end

-- 帮战推送
function i3k_sbean.sect_war_start_push.handler(bean)
	local mapType = i3k_game_get_map_type()
	if mapType == g_FIELD then
		i3k_sbean.sect_fight_group_cur_status(function(data)
			g_i3k_ui_mgr:OpenUI(eUIID_FactionFightPush)
			g_i3k_ui_mgr:RefreshUI(eUIID_FactionFightPush,data)
		end)
	end
end

--旗子状态改变
function i3k_sbean.nearby_mineral_updateowntype.handler(bean)
	local world = i3k_game_get_world()
	if world then
		local id = bean.id;
		local ownType = bean.winType;
		world:ChangeFactionWarFlag(id, ownType)
	end
end

--------------------------帮派驻地相关 start-------------------------------------
-- 帮派驻地建造同步
function i3k_sbean.sect_zone_sync_build(isRefresh)
	local data = i3k_sbean.sect_zone_sync_build_req.new()
	data.isRefresh = isRefresh
	i3k_game_send_str_cmd(data, "sect_zone_sync_build_res")
end

function i3k_sbean.sect_zone_sync_build_res.handler(bean, req)
	local donateCount = bean.process
	local isOpen = bean.open == 1
	if not req.isRefresh then
		g_i3k_ui_mgr:OpenUI(eUIID_FactionGarrison)
	end
	g_i3k_ui_mgr:RefreshUI(eUIID_FactionGarrison, donateCount, isOpen)
end

-- 帮派驻地建造
function i3k_sbean.sect_zone_build(count)
	local data = i3k_sbean.sect_zone_build_req.new()
	data.times = count
	i3k_game_send_str_cmd(data, "sect_zone_build_res")
end

function i3k_sbean.sect_zone_build_res.handler(bean, req)
	if bean.ok > 0 then
		local id = i3k_db_faction_garrison.openCondition.donationItemID
		g_i3k_game_context:UseCommonItem(id, req.times)
	else
		g_i3k_ui_mgr:PopupTipMessage("帮派驻地捐献失败")
	end
	g_i3k_ui_mgr:CloseUI(eUIID_FactionGarrisonDonate)
	i3k_sbean.sect_zone_sync_build(1) -- 是否捐献成功，都需要重新刷新
end

-- 帮派驻地建造排行同步
function i3k_sbean.sect_zone_build_rank()
	local data = i3k_sbean.sect_zone_build_rank_req.new()
	i3k_game_send_str_cmd(data, "sect_zone_build_rank_res")
end

function i3k_sbean.sect_zone_build_rank_res.handler(bean, req)
	if bean.ranks then
		g_i3k_ui_mgr:OpenUI(eUIID_GarrisonDonateRanks)
		g_i3k_ui_mgr:RefreshUI(eUIID_GarrisonDonateRanks, bean.ranks)
	end
end

-- 可进入帮派驻地同步
function i3k_sbean.sect_zone_list()
	local data = i3k_sbean.sect_zone_list_req.new()
	i3k_game_send_str_cmd(data, "sect_zone_list_res")
end

function i3k_sbean.sect_zone_list_res.handler(bean, req)
	if bean.sects then
		g_i3k_ui_mgr:OpenUI(eUIID_FactionFateRanks)
		g_i3k_ui_mgr:RefreshUI(eUIID_FactionFateRanks, bean.sects)
	end
end

-- 帮派驻地进入
function i3k_sbean.sect_zone_enter(sectId)
	local data = i3k_sbean.sect_zone_enter_req.new()
	data.sectId = sectId
	i3k_game_send_str_cmd(data, "sect_zone_enter_res")
end

function i3k_sbean.sect_zone_enter_res.handler(bean, req)
	local errorCode = {
		[-70] = i3k_get_string(16618),
		[-72] = i3k_get_string(16751, i3k_db_faction_dragon.dragonCfg.enterMaxNum),
		[-73] = i3k_get_string(16752, i3k_db_faction_dragon.dragonCfg.factionMaxNum),
		[-74] = i3k_get_string(16753, i3k_db_faction_garrison.factionBoss.needTime),
	}
	if errorCode[bean.ok] then
		return g_i3k_ui_mgr:PopupTipMessage(errorCode[bean.ok])
	end
	local is_ok, tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
end

-- 帮派驻地开启
function i3k_sbean.sect_zone_open()
	local data = i3k_sbean.sect_zone_open_req.new()
	i3k_game_send_str_cmd(data, "sect_zone_open_res")
end

function i3k_sbean.sect_zone_open_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_game_context:UseFactionVitality(i3k_db_faction_garrison.openCondition.needActivity)
		g_i3k_game_context:SetFactionGarrisonIsOpen(1)
		g_i3k_ui_mgr:PopupTipMessage("帮派驻地开启成功，赶快召集小伙伴们吧~")
		g_i3k_ui_mgr:CloseUI(eUIID_FactionGarrison)
	end
end

--驻地boss同步
function i3k_sbean.request_sect_zone_sync_boss_req (isRefresh)
	local data = i3k_sbean.sect_zone_sync_boss_req.new()
	data.isRefresh = isRefresh
	i3k_game_send_str_cmd(data, "sect_zone_sync_boss_res")
end

function i3k_sbean.sect_zone_sync_boss_res.handler (bean,req)
	if not req.isRefresh then
		g_i3k_ui_mgr:OpenUI(eUIID_FactionBoss)
	end
	g_i3k_ui_mgr:RefreshUI(eUIID_FactionBoss,bean)
end

--驻地boss捐献
function i3k_sbean.request_sect_zone_boss_item_req (bossId,itemId,itemNum)
	local data = i3k_sbean.sect_zone_boss_item_req.new()
	data.bossId = bossId
	data.itemId = itemId
	data.itemNum = itemNum
	i3k_game_send_str_cmd(data, "sect_zone_boss_item_res")
end

function i3k_sbean.sect_zone_boss_item_res.handler (bean,req)
	if bean.ok > 0 then
		g_i3k_game_context:UseCommonItem(req.itemId, req.itemNum)
		g_i3k_ui_mgr:CloseUI(eUIID_FactionGarrisonDonate)
	else
		g_i3k_ui_mgr:PopupTipMessage("捐献失败")
	end

	i3k_sbean.request_sect_zone_sync_boss_req(true)
end

--驻地boss召唤
function i3k_sbean.request_sect_zone_boss_open_req (bossId,useDiamond)
	local data = i3k_sbean.sect_zone_boss_open_req.new()
	data.useDiamond = useDiamond
	data.bossId = bossId
	i3k_game_send_str_cmd(data, "sect_zone_boss_open_res")
end

function i3k_sbean.sect_zone_boss_open_res.handler (bean,req)
	local is_ok,tips = g_i3k_game_context:JudgeFactionErrorCode(bean.ok)
	if not is_ok then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		i3k_sbean.request_sect_zone_sync_boss_req(true)
		return
	end
	g_i3k_ui_mgr:CloseUI(eUIID_NpcDialogue)
	g_i3k_ui_mgr:CloseUI(eUIID_FactionBoss)
	g_i3k_game_context:UseDiamond(req.useDiamond, true, AT_CALL_BOSS)
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16657))
end

-- 通知客户端强制切换PK模式
function i3k_sbean.role_force_change_pk_state.handler(bean)
	g_i3k_game_context:SetPKMode(bean.pkState)
end

-- 帮派驻地开始
function i3k_sbean.sect_zone_map_sync.handler(bean)
	g_i3k_game_context:SetFactionZoneInfo(bean.sectId, bean.sectName)
end

-- 龙运同步
function i3k_sbean.request_sect_destiny_sync_req()
	local data = i3k_sbean.sect_destiny_sync_req.new()
	data.sectId = g_i3k_game_context:GetFactionZoneSectID()
	i3k_game_send_str_cmd(data, "sect_destiny_sync_res")
end

function i3k_sbean.sect_destiny_sync_res.handler(bean)
	if bean.destinys then
		g_i3k_game_context:setSectDestiny(bean.destinys)
	end
	g_i3k_logic:OpenGarrisonTeam()
end

function i3k_sbean.sect_destiny_rob_push.handler(bean)
	if bean.ok == 1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16755))
	elseif bean.ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16758))
	elseif bean.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16757))
	elseif bean.ok == -3 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16756))
	end
end

function i3k_sbean.sect_msg_push.handler(bean)
	local text = ""
	if bean.type == 1 then
		local bossId = i3k_db_faction_garrsion_boss[bean.iArg1].monsterId
		local name = i3k_db_monsters[bossId].name
		if bean.iArg2 == 0 then
			text = i3k_get_string(16660, bean.vArg, name)
		else
			text = i3k_get_string(16659, bean.vArg, bean.iArg2, name)
		end
		g_i3k_game_context:ShowSectMessage(text, bean.iArg1)
		return
	elseif bean.type == 2 then
		text = i3k_get_string(16717, bean.vArg, bean.iArg1)
		if g_i3k_ui_mgr:GetUI(eUIID_RedEnvelope) then
			i3k_sbean.sect_red_pack_sync()
		end
	elseif bean.type == 3 then
		text = i3k_get_string(16615)
	elseif bean.type == 4 then
		text = i3k_get_string(16759, bean.vArg, bean.iArg1)
	elseif bean.type == 5 then
		text = i3k_get_string(16760, bean.vArg, bean.iArg1, bean.iArg2)
	elseif bean.type == 6 then
		text = i3k_get_string(16664)
	elseif bean.type == 7 then
		local pilarName = {"金", "木", "水", "火", "土"}
		text = i3k_get_string(16767, string.format("龙运之柱·%s", pilarName[bean.iArg1 + 1]), bean.iArg2)
	elseif bean.type == 8 then
		text = i3k_get_string(17460)
	elseif bean.type == 9 then
		local addIndex, addCfg = g_i3k_db.i3k_db_get_faction_spirit_get_addexp(bean.iArg1)
		local count = g_i3k_db.i3k_db_get_faction_spirit_get_min_count()
		text = addIndex > 0 and i3k_get_string(17473, bean.iArg1, addCfg.expCount / 100) or i3k_get_string(17472, count)
	end
	g_i3k_game_context:ShowSectMessage(text)
end
--------------------------帮派驻地相关 end---------------------------------------

--------------------------武林声望商店相关--------------------------------

---同步
function i3k_sbean.fame_shopsync_res.handler(res,req)
	local info = res.info
	g_i3k_ui_mgr:OpenUI(eUIID_PersonShop)
	g_i3k_ui_mgr:RefreshUI(eUIID_PersonShop, info, g_SHOP_TYPE_FAME, res.discount)
end

--刷新
function i3k_sbean.fame_shoprefresh_res.handler(res, req)
	local info = res.info
	if info then
		if req.isSecondType > 0 then
			moneytype = g_BASE_ITEM_DIAMOND
		else
			moneytype = g_BASE_ITEM_FAME
		end
		g_i3k_game_context:UseCommonItem(moneytype, req.coinCnt, AT_USER_REFRESH_SHOP)

		g_i3k_ui_mgr:RefreshUI(eUIID_PersonShop, info, g_SHOP_TYPE_FAME, req.discount)
	else
		local tips = string.format("%s", "刷新失败，请重试")
		g_i3k_ui_mgr:PopupTipMessage(tips)
	end
end

--购买
function i3k_sbean.fame_shopbuy(index, info, discount, discountCfg)
	local bean = i3k_sbean.fame_shopbuy_req.new()
	bean.seq = index
	bean.info = info
	bean.discount = discount
	bean.discountCfg = discountCfg
	i3k_game_send_str_cmd(bean, "fame_shopbuy_res")
end

function i3k_sbean.fame_shopbuy_res.handler(res,req)
	if res.ok > 0 then
		local info = req.info
		local index = req.seq
		local shopItem = i3k_db_fameShop[info.goods[index].id]
		local tips = i3k_get_string(189, shopItem.itemName.."*"..shopItem.itemCount)
		info.goods[index].buyTimes = 1
		if shopItem.moneyType ~= 0 then
			local count = req.discount > 0 and (shopItem.moneyCount * req.discount / 10) or shopItem.moneyCount
			g_i3k_game_context:UseBaseItem(shopItem.moneyType, math.ceil(count), AT_BUY_SHOP_GOOGS)
		end
		if shopItem.moneyType2 ~= 0 then
			local count = req.discount > 0 and (shopItem.moneyCount2 * req.discount / 10) or shopItem.moneyCount2
			g_i3k_game_context:UseBaseItem(shopItem.moneyType2, math.ceil(count), AT_BUY_SHOP_GOOGS)
		end
		g_i3k_ui_mgr:RefreshUI(eUIID_PersonShop, info, g_SHOP_TYPE_FAME, req.discountCfg)
		g_i3k_ui_mgr:PopupTipMessage(tips)
		DCItem.buy(shopItem.itemId,g_i3k_db.i3k_db_get_common_item_is_free_type(shopItem.itemId),shopItem.itemCount, shopItem.moneyType, shopItem.totalPrice, AT_BUY_SHOP_GOOGS)
	elseif res.ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(50065))
	else
		g_i3k_ui_mgr:PopupTipMessage("购买失败")
	end
end

--帮派招募令同步
function i3k_sbean.sect_msg_info(message)
	local bean = i3k_sbean.sect_msg_info_req.new()
	bean.sectId = message.sectId
	bean.name = message.sectName
	bean.desc = message.sectDesc
	i3k_game_send_str_cmd(bean, "sect_msg_info_res")
end

function i3k_sbean.sect_msg_info_res.handler(bean, req)
	if bean and bean.memberNum ~= 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_FactionRecruitment)
		g_i3k_ui_mgr:RefreshUI(eUIID_FactionRecruitment, bean, req.sectId, req.name, req.desc)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16912))
	end
end

--运镖皮肤

function i3k_sbean.sect_deliver_skin_unlock(id,callback)
	local bean = i3k_sbean.sect_deliver_skin_unlock_req.new()
	bean.skinId = id
	bean.callback = callback
	i3k_game_send_str_cmd(bean, "sect_deliver_skin_unlock_res")
end

function i3k_sbean.sect_deliver_skin_unlock_res.handler(bean, req)
	if bean.ok == 1 then
		req.callback()
	else
		g_i3k_ui_mgr:PopupTipMessage("操作失败")
	end
end

function i3k_sbean.sect_deliver_skin_select(id)
	local bean = i3k_sbean.sect_deliver_skin_select_req.new()
	bean.skinId = id
	i3k_game_send_str_cmd(bean, "sect_deliver_skin_select_res")
end

function i3k_sbean.sect_deliver_skin_select_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:SetFactionEscortSelectSkin(req.skinId)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionEscort,"onUpdateSkin",req.skinId)
	else
		g_i3k_ui_mgr:PopupTipMessage("操作失败")
	end
end

function i3k_sbean.request_sect_popmsg_sync_req()
	local bean = i3k_sbean.sect_popmsg_sync_req.new()
	i3k_game_send_str_cmd(bean)
end

function i3k_sbean.sect_popmsg_sync_res.handler(bean)
	for i,v in ipairs(bean.msgs) do
		g_i3k_game_context:updateShootMsg(v.roleId,v.msg)
	end
end

function i3k_sbean.request_sect_popmsg_add_req(msg)
	local bean = i3k_sbean.sect_popmsg_add_req.new()
	bean.msg = msg
	i3k_game_send_str_cmd(bean, "sect_popmsg_add_res")
end

function i3k_sbean.sect_popmsg_add_res.handler(bean,req)
	if bean.ok == 1 then
		g_i3k_ui_mgr:CloseUI(eUIID_ShootMsg)
		i3k_sbean.request_sect_popmsg_sync_req()
		g_i3k_game_context:setShootMsgSendTime()
	end
end

function i3k_sbean.sectmap_reward_self_take(mapId, rewardId)
	local bean = i3k_sbean.sectmap_reward_self_take_req.new()
	bean.mapId = mapId
	bean.rewardId = rewardId
	i3k_game_send_str_cmd(bean, "sectmap_reward_self_take_res")
end

function i3k_sbean.sectmap_reward_self_take_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17096))
		g_i3k_game_context:SetFactionTakeRewardCnt(g_i3k_game_context:GetFactionTakeRewardCnt() + 1)
		local data = i3k_sbean.sectmap_allocation_req.new()
		data.mapId = req.mapId
		i3k_game_send_str_cmd(data,i3k_sbean.sectmap_allocation_res.getName())
	else
		g_i3k_ui_mgr:PopupTipMessage("自取失败")
	end
end

-----------帮派仓库start----------------
function i3k_sbean.sectshare_sync()
	local data = i3k_sbean.sectshare_sync_req.new()
	i3k_game_send_str_cmd(data, "sectshare_sync_res")
end

function i3k_sbean.sectshare_sync_res.handler(bean, req)
	-- g_i3k_ui_mgr:OpenUI(eUIID_FactionWareHouse)
	g_i3k_ui_mgr:RefreshUI(eUIID_FactionWareHouse, bean.items, bean.item2price, bean.score)
end

-- 记录
function i3k_sbean.sectshare_event_sync_request(showType)
	local data = i3k_sbean.sectshare_event_sync_req.new()
	data.showType = showType
	i3k_game_send_str_cmd(data, "sectshare_event_sync_res")
end

function i3k_sbean.sectshare_event_start.handler(bean)
	g_i3k_game_context:ResetFactionWareHouseShareEvent()
end

function i3k_sbean.sectshare_event_batch.handler(bean)
	if bean.batch then
		for _, e in ipairs(bean.batch) do
			g_i3k_game_context:addFactionWareHouseShareEvent(e)
		end
	end
end

function i3k_sbean.sectshare_event_end.handler(bean)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionWareHouse, "updateShwoType")
end

function i3k_sbean.sectshare_event_sync_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionWareHouse, "updateShwoType", req.showType)
	end
end

-- 申请记录
function i3k_sbean.sectshare_apply_sync_reqest(showType)
	local data = i3k_sbean.sectshare_apply_sync_req.new()
	data.showType = showType
	i3k_game_send_str_cmd(data, "sectshare_apply_sync_res")
end

function i3k_sbean.sectshare_apply_start.handler(bean)
	g_i3k_game_context:ResetFactionWareHouseShareApply()
end

function i3k_sbean.sectshare_apply_batch.handler(bean)
	if bean.batch then
		for _, e in ipairs(bean.batch) do
			g_i3k_game_context:addFactionWareHouseShareApply(e)
		end
	end
end

function i3k_sbean.sectshare_apply_end.handler(bean)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionWareHouse, "updateShwoType")
end

function i3k_sbean.sectshare_apply_sync_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionWareHouse, "updateShwoType", req.showType)
	end
end

function i3k_sbean.sectshare_event_add.handler(bean)
	if bean.event then
		local desc = g_i3k_db.i3k_db_get_faction_warehouse_event_desc(bean.event)
		g_i3k_game_context:ShowSectMessage(desc)
	end
end

-- 通知加帮派仓库共享积分
function i3k_sbean.sectshare_score_add.handler(bean)
	local str = i3k_get_string(1355, bean.score)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionWareHouse, "laodShareScore", bean.score, true)
	g_i3k_ui_mgr:PopupTipMessage(str)
	g_i3k_game_context:ShowSectMessage(str)
end

--设置共享物品所需积分
function i3k_sbean.globalpve_changeSharePrice(itemID, price)
	local data = i3k_sbean.sectshare_setprice_req.new()
	data.itemID = itemID
	data.price = price
	i3k_game_send_str_cmd(data, "sectshare_setprice_res")
end

function i3k_sbean.sectshare_setprice_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:CloseUI(eUIID_SetWareHouseItemPrice)
		i3k_sbean.sectshare_sync()
	end
end

--申请兑换物品
function i3k_sbean.globalpve_applyItems(itemID, price)
	local data = i3k_sbean.sectshare_apply_req.new()
	data.itemID = itemID
	data.price = price
	i3k_game_send_str_cmd(data, "sectshare_apply_res")
end

function i3k_sbean.sectshare_apply_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:CloseUI(eUIID_ApplyWareHouseItem)
		g_i3k_ui_mgr:PopupTipMessage("成功发送兑换申请，等待分配")
		i3k_sbean.sectshare_sync()
	elseif res.ok == -101 then
		g_i3k_ui_mgr:PopupTipMessage("兑换所需积分已发生变动，请关闭帮派仓库介面重新打开")
	elseif res.ok == -103 then
		g_i3k_ui_mgr:PopupTipMessage("今日申请次数已用完")
	elseif res.ok == -104 then
		g_i3k_ui_mgr:PopupTipMessage("道具数量已变动，不足您所需兑换数量")
	elseif res.ok == -105 then
		g_i3k_ui_mgr:PopupTipMessage("加入帮派"..i3k_db_crossRealmPVE_shareCfg.needStayTime/(24 * 60 * 60).."天后才能提交申请")
	end
end

-----------帮派仓库end----------------

-----------帮派助战start----------------
-- 同步帮派助战信息
function i3k_sbean.sect_assist_sync(refreshType)
	local data = i3k_sbean.sect_assist_sync_req.new()
	data.refreshType = refreshType
	i3k_game_send_str_cmd(data, "sect_assist_sync_res")
end

function i3k_sbean.sect_assist_sync_res.handler(bean, req)
	-- 同步帮派助战信息(members 没有帮派时为null)
	if bean.members then
		if req.refreshType == g_FACTION_ASSIST then
			g_i3k_ui_mgr:OpenUI(eUIID_FactionAssist)
			g_i3k_ui_mgr:RefreshUI(eUIID_FactionAssist, bean.members)
		else
			g_i3k_game_context:SetAssistRoleData(bean.members)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("没有帮派")
	end
end

-- 登记帮派助战
function i3k_sbean.sect_assist_join()
	local data = i3k_sbean.sect_assist_join_req.new()
	i3k_game_send_str_cmd(data, "sect_assist_join_res")
end

function i3k_sbean.sect_assist_join_res.handler(bean, req)
	if bean.ok > 0 then
		i3k_sbean.sect_assist_sync(g_FACTION_ASSIST)
	end
end

-- 解除帮派助战登记
function i3k_sbean.sect_assist_quit()
	local data = i3k_sbean.sect_assist_quit_req.new()
	i3k_game_send_str_cmd(data, "sect_assist_quit_res")
end

function i3k_sbean.sect_assist_quit_res.handler(bean, req)
	if bean.ok > 0 then
		i3k_sbean.sect_assist_sync(g_FACTION_ASSIST)
	end
end

-- 邀请帮派助战
function i3k_sbean.sect_assist_apply(roleID, roleName)
	local data = i3k_sbean.sect_assist_apply_req.new()
	data.roleID = roleID
	data.roleName = roleName
	i3k_game_send_str_cmd(data, "sect_assist_apply_res")
end

function i3k_sbean.sect_assist_apply_res.handler(bean, req)
	if bean.ok > 0 then
		i3k_sbean.mroom_self()
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1401, req.roleName))
	elseif bean.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1395))
	elseif bean.ok == -13 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1400))
	elseif bean.ok == -14 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1399))
	else
		g_i3k_ui_mgr:PopupTipMessage("邀请失败")
	end
end

-- 移除帮派助战
function i3k_sbean.sect_assist_kick(roleID)
	local data = i3k_sbean.sect_assist_kick_req.new()
	data.roleID = roleID
	i3k_game_send_str_cmd(data, "sect_assist_kick_res")
end

function i3k_sbean.sect_assist_kick_res.handler(bean, req)
	if bean.ok > 0 then
		i3k_sbean.mroom_self()
	elseif bean.ok == -13 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1400))
	elseif bean.ok == -14 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1399))
	else
		g_i3k_ui_mgr:PopupTipMessage("移除失败")
	end
end

-----------帮派助战end----------------

-----------帮派互助start----------------
function i3k_sbean.sect_family_donate()
	local data = i3k_sbean.sect_donation_sync_req.new()
	i3k_game_send_str_cmd(data, "sect_donation_sync_res")
end

function i3k_sbean.sect_donation_sync_res.handler(bean, req)
	local date = {}
	date.sectInfo = bean.sectInfo
	date.roleInfo = bean.roleInfo
	g_i3k_game_context:setFactionData(date)
	g_i3k_ui_mgr:OpenUI(eUIID_FamilyDonate)
	g_i3k_ui_mgr:RefreshUI(eUIID_FamilyDonate, bean.sectInfo, bean.roleInfo)
end

function i3k_sbean.sect_donate_help(info)
	local data = i3k_sbean.sect_donation_req.new()
	data.info = info
	data.id = info.iteminfo.id
	i3k_game_send_str_cmd(data, "sect_donation_res")
end

function i3k_sbean.sect_donation_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("捐献成功")
		local info = req.info.iteminfo
		local reward = {}

		for k, v in ipairs(info.donatereward) do
			if v.id ~= 0 then
				reward[k] = v
			end
		end

		g_i3k_ui_mgr:ShowGainItemInfo(reward)

	else
		g_i3k_ui_mgr:PopupTipMessage("捐献失败")
	end

	i3k_sbean.sect_family_donate()
end

function i3k_sbean.sect_donate_roles(id)
	local data = i3k_sbean.sect_donation_roles_req.new()
	data.id = id
	i3k_game_send_str_cmd(data, "sect_donation_roles_res")
end

function i3k_sbean.sect_donation_roles_res.handler(bean, req)
	if bean.roles then
		g_i3k_ui_mgr:OpenUI(eUIID_FamilyDonateRoles)
		g_i3k_ui_mgr:RefreshUI(eUIID_FamilyDonateRoles, bean.roles)
	end
end

-----------帮派互助end----------------

------------------------ 城战 -------------------------
-- 同步城战基本信息
function i3k_sbean.defenceWarInfo(callback)
	local data = i3k_sbean.city_war_info_sync_req.new()
	data.callback = callback
	i3k_game_send_str_cmd(data, "city_war_info_sync_res")
end

function i3k_sbean.city_war_info_sync_res.handler(res, req)
	local citySign = res.citySign
	local cityBid = res.cityBid
	local cityPve = res.cityPve
	local cityPvp = res.cityPvp
	local delayInfo = res.delayInfo
	local kings = res.kings
	local pveKings = res.pveKings

	local cityID = g_i3k_game_context:getDefenceWarOnwerCityID(kings)
	g_i3k_game_context:setDefenceWarCurrentCityState(cityID)

	local cityID = g_i3k_game_context:getDefenceWarOnwerCityID(pveKings)
	g_i3k_game_context:setDefenceWarPveCity(cityID)

	g_i3k_game_context:setDelayInfo(delayInfo)
	g_i3k_game_context:setCitySign(citySign)
	g_i3k_game_context:setCityBid(cityBid)
	g_i3k_game_context:setDefenceWarKings(kings)

	g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "syncDefenceWarInfo", citySign, cityBid, cityPve, cityPvp, kings)
	if req.callback then
		req.callback()
	end
end

-- 获取城池报名信息
function i3k_sbean.defenceWarSignInfo()
	local data = i3k_sbean.city_war_sign_info_req.new()
	i3k_game_send_str_cmd(data, "city_war_sign_info_res")
end

-- citySign：表示每个城是否有帮派报名，0没有，1有，2本帮已报
function i3k_sbean.city_war_sign_info_res.handler(res, req)
	local citySign = res.citySign
	local dragonCrystal = res.dragonCrystal -- 龙晶
	local delayInfo = res.delayInfo

	g_i3k_game_context:setDragonCrystal(dragonCrystal)
	g_i3k_logic:OpenDefenceWarSignInUI(citySign)
end

-- 帮派报名(id表示城的序号)
function i3k_sbean.defenceWarSign(id)
	local data = i3k_sbean.city_war_sect_sign_req.new()
	data.id = id
	i3k_game_send_str_cmd(data, "city_war_sect_sign_res")
end

function i3k_sbean.city_war_sect_sign_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("报名成功")
		g_i3k_ui_mgr:CloseUI(eUIID_DefenceWarSignIn)
		g_i3k_ui_mgr:CloseUI(eUIID_DefenceWarSure)
		local cfg = i3k_db_defenceWar_city[req.id]
		g_i3k_game_context:useDragonCrystal(cfg.signCost)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArenaList, "defenceWarSignInSuccess", req.id)
	elseif res.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage("帮派不存在")
	elseif res.ok == -6 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5165)) -- "报名没有权限")
	elseif res.ok == -74 then
		local seconds = i3k_db_defenceWar_cfg.needJoinSectTime
		local text = i3k_get_time_show_text_simple(seconds)
		g_i3k_ui_mgr:PopupTipMessage("入帮时长不足"..text)
	elseif res.ok == -100 then
		g_i3k_ui_mgr:PopupTipMessage("报名超时")
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5184))-- "报名失败:"..res.ok)
	end
end

-- 进入城战
function i3k_sbean.defenceWarEnter(cityId)
	local data = i3k_sbean.city_war_enter_req.new()
	data.cityId = cityId
	i3k_game_send_str_cmd(data, "city_war_enter_res")
end

function i3k_sbean.city_war_enter_res.handler(bean)
	if bean.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("进入成功")
	elseif bean.ok == -10001 then
		g_i3k_ui_mgr:PopupTipMessage("城战未开始")
	elseif bean.ok == -10002 then
		g_i3k_ui_mgr:PopupTipMessage("未报名无法进入")
	elseif bean.ok == -10003 then
		g_i3k_ui_mgr:PopupTipMessage("未在战场中")
	elseif bean.ok == -10004 then
		g_i3k_ui_mgr:PopupTipMessage("在匹配中")
	elseif bean.ok == -10006 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5330))  --您的帮派进入人数已达到本帮进入上限，无法进入
	else
		g_i3k_ui_mgr:PopupTipMessage("进入失败")
	end
end

-- 城战开始
function i3k_sbean.city_war_start.handler(bean)
	local firstClearInfo = g_i3k_game_context:getFirstClearInfo(FIRST_CLEAR_REWARD_CITY)
	if not firstClearInfo or not firstClearInfo.enter then
		g_i3k_game_context:refreshFirstClearInfo(FIRST_CLEAR_REWARD_CITY)
	end
	g_i3k_game_context:ClearFindWayStatus()
end

-- 城战结束
function i3k_sbean.city_war_end.handler(bean)

end

-- 城战结果
function i3k_sbean.city_war_result.handler(bean)
	g_i3k_ui_mgr:OpenUI(eUIID_DefenceWarResult)
	g_i3k_ui_mgr:RefreshUI(eUIID_DefenceWarResult, bean)
end

-- 进城战地图同步信息(reviveTime 毫秒的时间戳)
function i3k_sbean.citywar_map_info.handler(bean)
	g_i3k_game_context:setDefenceWarInfo(bean.score, bean.killMonsters, bean.totalMonsters, bean.reviveTime)
	g_i3k_ui_mgr:RefreshUI(eUIID_DefenceWarBattle)
end

-- 城战击杀信息更新
function i3k_sbean.citywar_update_kill.handler(bean)
	if bean then
		g_i3k_game_context:setDefenceWarMonsterCount(bean.monsterType, bean.killCount)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_DefenceWarBattle, "updateKillInfo", g_i3k_game_context:getDefenceWarKillInfo())
	end
end

-- 城战复活点旗子信息更新
function i3k_sbean.citywar_update_reviveflag.handler(bean)
	--[[
	<field name="id" type="int32"/>
	<field name="ownType" type="int32"/>
	]]
end

-- 城战积分更新
function i3k_sbean.citywar_update_score.handler(bean)
	if bean then
		g_i3k_game_context:setDefenceWarScore(bean.score)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_DefenceWarBattle, "updateScoreInfo", g_i3k_game_context:getDefenceWarScore())
	end
end

-- 城战小地图信息
function i3k_sbean.citywar_entities_info_query(mapID)
	local data = i3k_sbean.citywar_entities_query.new()
	data.mapID = mapID
	i3k_game_send_str_cmd(data, "citywar_entities_info")
end

-- 城战小地图信息(citywar_entities_query的异步回应)
function i3k_sbean.citywar_entities_info.handler(res, req)
	--[[
	<field name="reviveFlag" type="vector[ForceTypeInfo]"/>
	<field name="arrayTower" type="vector[ForceTypeInfo]"/>
	]]
	local reviveFlag = res.reviveFlag -- 复活点旗子（都是活着的）
	local arrayTower = res.arrayTower -- 箭塔
	g_i3k_ui_mgr:OpenUI(eUIID_DefenceWarMap)
	g_i3k_ui_mgr:RefreshUI(eUIID_DefenceWarMap, req.mapID, reviveFlag, arrayTower)

end

-- 开启城主之光
function i3k_sbean.city_light_open(cityId)
	local data = i3k_sbean.city_light_open_req.new()
	data.cityId = cityId
	i3k_game_send_str_cmd(data, "city_light_open_res")
end

function i3k_sbean.city_light_open_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("成功开启城主之光")
		local endTime =  i3k_game_get_time() + i3k_db_defenceWar_cfg.bless.blessSecond
		local id = req.cityId
		local rate = i3k_db_defenceWar_city[id].blessAddition	
		local dayCityLight = g_i3k_game_context:getDefenceWarDayCityLight()
		dayCityLight[id] = true
		g_i3k_game_context:setDefenceWarCityLight(endTime, id, rate, dayCityLight)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase, "updateRoleBuff", g_i3k_game_context:GetRolebuff())
	elseif bean.ok == -10007 then
		g_i3k_ui_mgr:PopupTipMessage("当日城主之光开启次数已达上限")
	elseif bean.ok == -10008 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5456))
	else
		g_i3k_ui_mgr:PopupTipMessage("开启城主之光失败")
	end
end

-- 同步城主之光
function i3k_sbean.city_light_login_sync.handler(bean)
	local info = bean.info
	g_i3k_game_context:setDefenceWarCityLight(info.endTime, info.lastCity, info.addRate, info.dayCityLight)
end

-- 城战竞标相关
function i3k_sbean.syncDefenceWarBid()
	local data = i3k_sbean.city_war_bid_info_req.new()
	i3k_game_send_str_cmd(data, "city_war_bid_info_res")
end
function i3k_sbean.city_war_bid_info_res.handler(res, req)
	-- 获取帮派竞标信息（cityBid：0无主城池，1没有帮派竞标，2有帮派竞标， 3本帮派已竞标； price：上次竞标出价； bidTimes：已出价次数）
	--self.cityBid:		map[int32, int32]
	--self.price:		int32
	--self.bidTimes:		int32
	--self.dragonCrystal:		int32
	g_i3k_game_context:setDragonCrystal(res.dragonCrystal)
	g_i3k_ui_mgr:OpenUI(eUIID_DefenceWarBid)
	g_i3k_ui_mgr:RefreshUI(eUIID_DefenceWarBid, res.cityBid, res.kings, res.price, res.bidTimes)
end

-- 竞标
function i3k_sbean.defenceWarBid(cityID, price)
	local data = i3k_sbean.city_war_sect_bid_req.new()
	data.cityID = cityID
	data.price = price
	i3k_game_send_str_cmd(data, "city_war_sect_bid_res")
end
function i3k_sbean.city_war_sect_bid_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:CloseUI(eUIID_DefenceWarBidSure)
		g_i3k_ui_mgr:CloseUI(eUIID_DefenceWarBid)
		g_i3k_ui_mgr:PopupTipMessage("竞标成功")
	elseif res.ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5187)) -- 你的帮派没有报名，无法参加
	elseif res.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5289)) -- 我帮派已经有城池了，此轮需要守城
	elseif res.ok == -6 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5249))
	elseif res.ok == -100 then
		g_i3k_ui_mgr:PopupTipMessage("竞标超时")
	-- elseif res.ok == then
	-- 	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5232)) -- 竞标次数用完了
	else
		g_i3k_ui_mgr:PopupTipMessage("竞标失败"..res.ok)
	end
end

function i3k_sbean.city_war_Buy_Car()
	local data = i3k_sbean.city_war_use_car_req.new()
	i3k_game_send_str_cmd(data, "city_war_use_car_res")
end

function i3k_sbean.city_war_use_car_res.handler(res)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("变身成功")
		g_i3k_ui_mgr:CloseUI(eUIID_NpcDialogue)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_DefenceWarBattle, "updataUnrideCarBtState", true)
	elseif res.ok == 0 then
		g_i3k_ui_mgr:PopupTipMessage("已处在变身中")
	elseif res.ok == -6 then
		g_i3k_ui_mgr:PopupTipMessage("没有许可权")
	elseif res.ok == -80 then
		g_i3k_ui_mgr:PopupTipMessage("龙晶不足")
	elseif res.ok == -10005 then
		g_i3k_ui_mgr:PopupTipMessage("变身CD中")
	end
end

function i3k_sbean.city_war_cancle_use_car()
	local data = i3k_sbean.city_war_cancel_car_req.new()
	i3k_game_send_str_cmd(data, "city_war_cancel_car_res")
end

function i3k_sbean.city_war_cancel_car_res.handler(res)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("取消变身成功")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_DefenceWarBattle, "updataUnrideCarBtState", false)
	else
		g_i3k_ui_mgr:PopupTipMessage("取消变身失败")
	end
end

-- 城战传送
function i3k_sbean.defenceWarTrans(transformId)
	local data = i3k_sbean.city_war_transform_req.new()
	data.transformId = transformId
	i3k_game_send_str_cmd(data, "city_war_transform_res")
end
function i3k_sbean.city_war_transform_res.handler(res, req)
	if res.ok > 0 then
		-- g_i3k_ui_mgr:PopupTipMessage("传送成功")
	else
		g_i3k_ui_mgr:PopupTipMessage("gs传送失败")
	end
end

function i3k_sbean.citywar_teleport.handler(res)
	--self.teleportID:		int32
	--self.errorCode:		int32
	if res.errorCode > 0 then
		g_i3k_ui_mgr:PopupTipMessage("传送成功")
	elseif res.errorCode == -201 then
		g_i3k_ui_mgr:PopupTipMessage("阵营非法")
	elseif res.errorCode == -202 then
		g_i3k_ui_mgr:PopupTipMessage("传送ID非法")
	elseif res.errorCode == -203 then
		g_i3k_ui_mgr:PopupTipMessage("关联城门未破")
	else
		g_i3k_ui_mgr:PopupTipMessage("ms传送失败:"..res.errorCode)
	end
end

function i3k_sbean.syncDefenceWarBidResult()
	local data = i3k_sbean.city_war_bid_result_req.new()
	i3k_game_send_str_cmd(data, "city_war_bid_result_res")
end
function i3k_sbean.city_war_bid_result_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_DefenceWarBidRes)
		g_i3k_ui_mgr:RefreshUI(eUIID_DefenceWarBidRes, res.result, res.cityInfo)
	elseif res.ok == -100 then
		g_i3k_ui_mgr:PopupTipMessage("查询超时")
	else
		g_i3k_ui_mgr:PopupTipMessage("同步失败")
	end
end

-- 城战奖励界面，同步下当前城池归属情况(暂不使用)
function i3k_sbean.syncDefenceWarCurCity()
	local data = i3k_sbean.city_war_current_kings_req.new()
	i3k_game_send_str_cmd(data, "city_war_current_kings_res")
end
function i3k_sbean.city_war_current_kings_res.handler(res, req)
	local map = res.kings
	--[[
	g_i3k_ui_mgr:OpenUI(eUIID_DefenceWarReward)
	g_i3k_ui_mgr:RefreshUI(eUIID_DefenceWarReward, map)
	]]
end

function i3k_sbean.defenceWarRepairTower(instanceID)
	local data = i3k_sbean.city_war_tower_fix_req.new()
	data.towerId = instanceID
	i3k_game_send_str_cmd(data, "city_war_tower_fix_res")
end

function i3k_sbean.city_war_tower_fix_res.handler(res, req)
	if res.ok > 0 then

	else
		g_i3k_ui_mgr:PopupTipMessage("修理失败")
	end
end

function i3k_sbean.citywar_arrowtower_fix.handler(res, req)
	if res.errorCode > 0 then
		g_i3k_ui_mgr:PopupTipMessage("修复成功")
		g_i3k_ui_mgr:CloseUI(eUIID_NpcDialogue)
	elseif res.errorCode == -6 then
		g_i3k_ui_mgr:PopupTipMessage("没有许可权")
	elseif res.errorCode == -80 then
		g_i3k_ui_mgr:PopupTipMessage("龙晶不足")
	elseif res.errorCode == -101 then
		g_i3k_ui_mgr:PopupTipMessage("只有占城方才能修复箭塔")
	elseif res.errorCode == -102 then
		g_i3k_ui_mgr:PopupTipMessage("箭塔不存在")
	elseif res.errorCode == -103 then
		g_i3k_ui_mgr:PopupTipMessage("箭塔未死亡")
	elseif res.errorCode == -104 then
		g_i3k_ui_mgr:PopupTipMessage("箭塔全部死亡")
	elseif res.errorCode == -105 then
		g_i3k_ui_mgr:PopupTipMessage("修复箭塔CD")
	else
		g_i3k_ui_mgr:PopupTipMessage("fs修复失败:" .. res.errorCode)
	end
end

--同步大将军血量
function i3k_sbean.citywar_boss_state.handler(res)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_DefenceWarBattle, "updateBossBlood", res.curHP, res.maxHP)
end

--城战进入人员同步
function i3k_sbean.citywar_enter_member()
	local data = i3k_sbean.city_war_sect_roles_sync_req.new()
	i3k_game_send_str_cmd(data, "city_war_sect_roles_sync_res")
end

function i3k_sbean.city_war_sect_roles_sync_res.handler(res)
	g_i3k_logic:OpenDefenceWarMemberUI(res.roles)
end
function i3k_sbean.citywar_req_exp(cityID)
	local data = i3k_sbean.city_light_sync_req.new()
	data.cityID = cityID
	i3k_game_send_str_cmd(data, "city_light_sync_res")
end
function i3k_sbean.city_light_sync_res.handler(res, req)
	local info = res.info
	g_i3k_game_context:setDefenceWarCityLight(info.endTime, info.lastCity, info.addRate, info.dayCityLight)
	--是不是本服	
	if not res.localCitys[req.cityID] then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5505))
		return
	end
	local callback = function(ok) 
		if ok then
			local ui = g_i3k_ui_mgr:GetUI(eUIID_CityWarExp)
			if ui and ui._refreshFlag then
				return
			end
			i3k_sbean.city_light_open(req.cityID)
		end	
	end
	g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(5509), callback)
end
---------------城战 end------------------

---------------驻地精灵------------------
-- 同步驻地精灵祝福信息
function i3k_sbean.sync_sect_zone_spirit_bless(callBack)
	local data = i3k_sbean.sync_sect_zone_spirit_bless_req.new()
	data.callBack = callBack
	i3k_game_send_str_cmd(data, "sync_sect_zone_spirit_bless_res")
end

function i3k_sbean.sync_sect_zone_spirit_bless_res.handler(bean, req)
	if req and req.callback then
		req.callback()
	end
	g_i3k_ui_mgr:OpenUI(eUIID_SpiritBlessing)
	g_i3k_ui_mgr:RefreshUI(eUIID_SpiritBlessing, bean.blessInfo)
	g_i3k_game_context:SetFactionBlessingData(bean.blessInfo)
end

-- 驻地精灵 同步找到精灵的数量
function i3k_sbean.sect_zone_spirit_find_count.handler(bean)
	g_i3k_game_context:SetFactionSpiritKillData(bean.sectFind, bean.selfFind)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionGarrisonSpirit, "updateScroll")
end


-- 使用驻地精灵祝福（order：祝福档位）
function i3k_sbean.use_sect_zone_spirit_bless(order)
	local data = i3k_sbean.use_sect_zone_spirit_bless_req.new()
	data.order = order
	i3k_game_send_str_cmd(data, "use_sect_zone_spirit_bless_res")
end

function i3k_sbean.use_sect_zone_spirit_bless_res.handler(bean, req)
	if bean.ok == 1 then
		-- TODO
		local addExp = i3k_db_faction_spirit.blessingRewards[req.order].expCount
		local blessingValue = addExp/100
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17465, blessingValue))
		g_i3k_game_context:SetFactionBlessing(req.order)
	else
		g_i3k_ui_mgr:PopupTipMessage("使用失败")
	end
end
--[[<packet name="sync_sect_zone_spirit_last_bless">
	登录同步上次祝福信息
            <field name="lastOrder" type="int32"/>
            <field name="lastUseTime" type="int32"/>
 </packet>--]]
function i3k_sbean.sync_sect_zone_spirit_last_bless.handler(bean)
	g_i3k_game_context:SetFactionBufTimes(bean.lastUseTime, bean.lastOrder, bean.lastJoinTime)
end


--是否打开精灵
function i3k_sbean.open_sect_zone_spirit_req(callBackOpen, callBackEnd)
	local data = i3k_sbean.sect_zone_spirit_exist_req.new()
	data.callBackOpen = callBackOpen
	data.callBackEnd = callBackEnd
	i3k_game_send_str_cmd(data, "sect_zone_spirit_exist_res")
	
end

--是否打开驻地精灵
function i3k_sbean.sect_zone_spirit_exist_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:SetSpiritIsEnd(1)
		if req.callBackOpen then
			req.callBackOpen()
		end
	else
		g_i3k_game_context:SetSpiritIsEnd(0)
		if req.callBackEnd then
			req.callBackEnd()
		end
	end
	
end

---------------驻地精灵 end -------------
--帮派个人本伤害请求
function i3k_sbean.sectmap_damage(mapId)
	local data = i3k_sbean.sectmap_damage_query.new()
	data.mapId = mapId
	i3k_game_send_str_cmd(data)
end
--帮派个人本伤害
function i3k_sbean.sectmap_damage_query_sync.handler(bean)
	--bean.damage
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleFuben, "showFactionDamage", bean.damage)
end
----------------
--帮派合照--------------------------------------------------
function i3k_sbean.sect_photo_roles_sync(info, mapInfo)
	local data = i3k_sbean.sect_photo_roles_sync_req.new()
	data.roles = info
	data.mapInfo = mapInfo
	i3k_game_send_str_cmd(data, "sect_photo_roles_sync_res")
end
function i3k_sbean.sect_photo_roles_sync_res.handler(res, req)
	local info =  g_i3k_db.i3k_db_get_faction_photo_sort(res.roles)
	i3k_game_take_photo_faction(info, req.mapInfo)
end
function i3k_sbean.role_sectwar_start.handler(res, req)
	local firstClearInfo = g_i3k_game_context:getFirstClearInfo(FIRST_CLEAR_REWARD_SECT)
	if not firstClearInfo or not firstClearInfo.enter then
		g_i3k_game_context:refreshFirstClearInfo(FIRST_CLEAR_REWARD_SECT)
	end
end
