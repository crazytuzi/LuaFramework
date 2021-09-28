------------------------------------------------------
module(..., package.seeall)

local require = require

require("i3k_sbean")

---------------------------------排行榜----------------------------------------------


---其他排行榜数据start----------------------------------------------------------------------
-----同步其他排行榜信息
function i3k_sbean.sync_OtherRankList_info(state)
	local bean = i3k_sbean.sectrank_sync_req.new()
	bean.state = state
	i3k_game_send_str_cmd(bean, i3k_sbean.sectrank_sync_res.getName())
end

function i3k_sbean.sectrank_sync_res.handler(res, req)
	if res.sectresult then--result(id,rankSize,createTime)
		g_i3k_ui_mgr:OpenUI(eUIID_RankList_Other)
		g_i3k_ui_mgr:RefreshUI(eUIID_RankList_Other, res.sectresult, req.state, res.fightgroupresult, res.fightteamresult)
		g_i3k_ui_mgr:CloseUI(eUIID_RankList)
	end
end

--获取其他排行榜列表
function i3k_sbean.get_OtherRankList(id,createTime,index,length,size)---index代表第几条
	local bean = i3k_sbean.sectrank_get_req.new()
	bean.id = id
	bean.createTime = createTime
	bean.index = index
	bean.length = length
	bean.size = size
	i3k_game_send_str_cmd(bean, i3k_sbean.sectrank_get_res.getName())
end

function i3k_sbean.sectrank_get_res.handler(res, req)
	if res.ok > 0 then
		-- local ranks =  -- 测试用数据
		-- {
		-- 	[1] = {sect  = { sectId = 1000001, name = "sectName", level = 2, chiefId = 1, chiefName = "chiefName"},
		-- 		rankKey = 459079680
		-- 	},
		-- 	[2] = {sect  = { sectId = 1000001, name = "sectName2", level = 2, chiefId = 1, chiefName = "chiefName2"},
		-- 		rankKey = 459079680
		-- 	},
		-- }

		print("收到资料")
		if type(res.ranks)=="table" then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_RankList_Other, "reloadRankList", res.ranks, req.id, req.size)
		end
		if req.index == 0 then
			local eventID = "其他排行榜" .. req.index
			DCEvent.onEvent("查看其他排行榜", { eventID = tostring(req.index)})
		end
	elseif res.ok == 0 then
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(520))
		--i3k_sbean.sync_rankList_info(req.id)全部都是选中状态
	end
end

-- 帮派分堂相关排行榜
function i3k_sbean.getFactionFentangRankList(id, createTime, index, length, size)
	local bean = i3k_sbean.fightgrouprank_get_req.new()
	bean.id = id
	bean.createTime = createTime
	bean.index = index
	bean.length = length
	bean.size = size
	i3k_game_send_str_cmd(bean, i3k_sbean.fightgrouprank_get_res.getName())
end
function i3k_sbean.fightgrouprank_get_res.handler(res, req)
	if res.ok > 0 then
		-- local ranks =   -- 测试结构数据
		-- {
		-- 	[1] = {
		-- 		group = {winTimes = 1, score = 459079680,
		-- 			group = {sectId = 1000001, groupId = 1000001, sectName = "fds", groupName = "da"},
		-- 			joinTimes = 1,
		-- 			leaderName = "aldalf",
		-- 		},
		-- 		rankKey = 459079680
		-- 	},
		-- 	[2] = {
		-- 		group = {winTimes = 1, score = 459079681,
		-- 			group = {sectId = 1000002, groupId = 1000002, sectName = "fds2", groupName = "da2"},
		-- 			joinTimes = 1,
		-- 			leaderName = "aldalf2",
		-- 		},
		-- 		rankKey = 459079681
		-- 	}
		-- }

		g_i3k_ui_mgr:InvokeUIFunction(eUIID_RankList_Other, "reloadFentangRankList", res.ranks, req.id, req.size)
	end
end

-- 获取战队排行榜列表
function i3k_sbean.getFightteamRankList(id,createTime,index,length,size)---index代表第几条
	local bean = i3k_sbean.fightteamrank_get_req.new()
	bean.id = id
	bean.createTime = createTime
	bean.index = index
	bean.length = length
	bean.size = size
	i3k_game_send_str_cmd(bean, i3k_sbean.fightteamrank_get_res.getName())
end

function i3k_sbean.fightteamrank_get_res.handler(res, req)
	--[[local ranks =  -- 测试用数据
		{
			[1] = {sect  = { sectId = 1000001, name = "sectName", level = 2, chiefId = 1, chiefName = "chiefName"},rankKey = 459079680
					},
			[2] = {sect  = { sectId = 1000001, name = "sectName2", level = 2, chiefId = 1, chiefName = "chiefName2"},rankKey = 459079680
				},
			[3] = {sect  = { sectId = 1000001, name = "sectName2", level = 2, chiefId = 1, chiefName = "chiefName2"},rankKey = 459079680
				},
			[4] = {sect  = { sectId = 1000001, name = "sectName2", level = 2, chiefId = 1, chiefName = "chiefName2"},rankKey = 459079680
				},
		}--]]
	if res.ok > 0 then
		if  type(res.ranks)=="table" then
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_RankList_Other, "reloadFightteamRankList", res.ranks,req.id,req.size)
		end

		if req.index == 0 then
			local eventID = "排行榜" .. req.index
			DCEvent.onEvent("查看排行榜", { eventID = tostring(req.index)})
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(520))
	end
end

---获取其他排行榜 自身排名(不在榜上返回0)
function i3k_sbean.get_otherSelfRank(id,callback)
	local bean = i3k_sbean.sectrank_self_req.new()
	bean.id = id
	bean.callback = callback
	i3k_game_send_str_cmd(bean, i3k_sbean.sectrank_self_res.getName())
end

function i3k_sbean.sectrank_self_res.handler(res, req)

	if res.sectRank  then--selfRank
		if req.callback then
			req.callback()
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_RankList_Other, "reloadselfRank", res.sectRank,req.id)
	end
end


-------其他排行榜数据end---------------------------------------------------------------------------------------------





-----同步排行榜信息
function i3k_sbean.sync_rankList_info(state)
	local bean = i3k_sbean.rank_sync_req.new()
	bean.state = state
	i3k_game_send_str_cmd(bean, i3k_sbean.rank_sync_res.getName())
end

function i3k_sbean.rank_sync_res.handler(res, req)
	if res.result then--result(id,rankSize,createTime)
		g_i3k_ui_mgr:OpenUI(eUIID_RankList)
		g_i3k_ui_mgr:RefreshUI(eUIID_RankList, res.result,req.state)
		g_i3k_ui_mgr:CloseUI(eUIID_RankList_Other)
	end
end

---获取排行榜列表
function i3k_sbean.get_rankList(id,createTime,index,length,size)---index代表第几条
	local bean = i3k_sbean.rank_get_req.new()
	bean.id = id
	bean.createTime = createTime
	bean.index = index
	bean.length = length
	bean.size = size
	i3k_game_send_str_cmd(bean, i3k_sbean.rank_get_res.getName())
end

function i3k_sbean.rank_get_res.handler(res, req)
	--i3k_log("rank_get_res = ",req.id,req.createTime,req.index,req.length,req.size)
	if res.ok > 0 then--ok,ranks(role (id,name,gender,headIcon,type,tLvl,bwType,level,fightPower),rankKey)
		if  type(res.ranks)=="table" then --add by jxw 16.9.10 报错，暂未定位到具体位置 so加拦截判断
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_RankList, "reloadRankList", res.ranks,req.id,req.size)
		end

		if req.index == 0 then
			local eventID = "排行榜" .. req.index
			DCEvent.onEvent("查看排行榜", { eventID = tostring(req.index)})
		end
	elseif res.ok == 0 then

	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(520))
		--i3k_sbean.sync_rankList_info(req.id)全部都是选中状态
	end


end
---获取自身排名(不在榜上返回0)
function i3k_sbean.get_selfRank(id,callback)
	local bean = i3k_sbean.rank_self_req.new()
	bean.id = id
	bean.callback = callback
	i3k_game_send_str_cmd(bean, i3k_sbean.rank_self_res.getName())
end

function i3k_sbean.rank_self_res.handler(res, req)

	if res.selfRank  then--selfRank
		if req.callback then
			req.callback()
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_RankList, "reloadselfRank", res.selfRank,req.id)
	end
end

---获取玩家所有已获得的佣兵信息
function i3k_sbean.get_petoverviews(id,callback)
	local bean = i3k_sbean.query_petoverviews_req.new()
	bean.rid = id
	bean.callback = callback
	i3k_game_send_str_cmd(bean, i3k_sbean.query_petoverviews_res.getName())
end

function i3k_sbean.query_petoverviews_res.handler(res, req)
	local function IsEnoughPetCnt(pets)
		local haveCount = 0
		for _, v in ipairs(pets) do
			if v.level >= i3k_db_pet_equips_cfg.needPetLvl then
				haveCount = haveCount + 1
			end
		end
		return haveCount >= i3k_db_pet_equips_cfg.needPetCnt
	end

	if next(res.pets) then--pets(id,level,star,fightPower)
		if IsEnoughPetCnt(res.pets) then
			g_i3k_ui_mgr:OpenUI(eUIID_PetEquipRankList)
			g_i3k_ui_mgr:RefreshUI(eUIID_PetEquipRankList, res.pets, res.equipParts, req.callback)
		else
			g_i3k_ui_mgr:OpenUI(eUIID_RankListRoleProperty)
			g_i3k_ui_mgr:RefreshUI(eUIID_RankListRoleProperty, res.pets, req.callback)
		end
	end
end

---获取玩家所有已获得的神兵信息
function i3k_sbean.get_weaponoverviews(id,callback)
	local bean = i3k_sbean.query_weaponoverviews_req.new()
	bean.rid = id
	bean.callback = callback
	i3k_game_send_str_cmd(bean, i3k_sbean.query_weaponoverviews_res.getName())
end

function i3k_sbean.query_weaponoverviews_res.handler(res, req)

	if res.weapons then--weapons(id,level,star,fightPower)
		g_i3k_ui_mgr:OpenUI(eUIID_RankListRoleProperty)
		g_i3k_ui_mgr:RefreshUI(eUIID_RankListRoleProperty, res.weapons,req.callback, res.spirits)
		
	end
end

--获取玩家所有已获得暗器的信息
function i3k_sbean.get_hideWeapon_overviews(id, callback)
	local bean = i3k_sbean.query_hideWeaponoverviews_req.new()
	bean.rid = id
	bean.callback = callback
	i3k_game_send_str_cmd(bean, i3k_sbean.query_hideWeaponoverviews_res.getName())
end

function i3k_sbean.query_hideWeaponoverviews_res.handler(res, req)
	if res.weapons then
		g_i3k_ui_mgr:OpenUI(eUIID_RankListRoleProperty)
		g_i3k_ui_mgr:RefreshUI(eUIID_RankListRoleProperty, res.weapons, req.callback)
	end
end

---获取玩家所有已获得内甲信息
function i3k_sbean.get_underwearoverviews(id,callback)
	local bean = i3k_sbean.query_armoroverviews_req.new()
	bean.rid = id
	bean.callback = callback
	i3k_game_send_str_cmd(bean, i3k_sbean.query_armoroverviews_res.getName())
end

function i3k_sbean.query_armoroverviews_res.handler(res, req)
	if res.armor then--armor(id,level,rank,fightPower)
		g_i3k_ui_mgr:OpenUI(eUIID_RankListRoleProperty)
		g_i3k_ui_mgr:RefreshUI(eUIID_RankListRoleProperty, res.armor, req.callback, res.feature)
	end
end

---获取玩家所有已获得坐骑信息
function i3k_sbean.get_steedoverviews(id,callback)
	local bean = i3k_sbean.query_horseoverviews_req.new()
	bean.rid = id
	bean.callback = callback
	i3k_game_send_str_cmd(bean, i3k_sbean.query_horseoverviews_res.getName())
end

function i3k_sbean.query_horseoverviews_res.handler(bean, req)
	if bean.horses then
		g_i3k_ui_mgr:OpenUI(eUIID_RankListRoleProperty)
		g_i3k_ui_mgr:RefreshUI(eUIID_RankListRoleProperty, bean.horses, req.callback, bean.showIDS, bean.masters, bean.spirit, bean.steedEquip, bean.roleOverview)
	end
end

-- 获取玩家武魂信息
function i3k_sbean.get_weaponsouloverview(id, callback)
	local bean = i3k_sbean.query_weaponsouloverview_req.new()
	bean.rid = id
	bean.callback = callback
	i3k_game_send_str_cmd(bean, "query_weaponsouloverview_res")
end

function i3k_sbean.query_weaponsouloverview_res.handler(bean, req)
	if bean.weaponSoul then
		g_i3k_ui_mgr:OpenUI(eUIID_RankListWeaponSoul)
		g_i3k_ui_mgr:RefreshUI(eUIID_RankListWeaponSoul, bean.weaponSoul, req.callback)
	end
end
--同步武诀排行榜
function i3k_sbean.sync_wujue_rank(roleId)
	local bean = i3k_sbean.skill_formula_sync_req.new()
	bean.rid = roleId
	i3k_game_send_str_cmd(bean, "skill_formula_sync_res")
end
function i3k_sbean.skill_formula_sync_res.handler(bean, req)
	local data = bean.data
	if data then
		g_i3k_ui_mgr:OpenUI(eUIID_WujueRank)
		g_i3k_ui_mgr:RefreshUI(eUIID_WujueRank, data)
	end
end
