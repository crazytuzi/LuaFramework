
------------------------------------------------------
module(..., package.seeall)

local require = require

local BASE = require("logic/network/channel/i3k_channel");

local arrayStoneError = 
{
	--[[[-1] = "等级不足", -- 等级不足
	[-2] = "消耗道具不足", -- 消耗道具不足
	[-3] = "真言等级不足", -- 真言等级不足
	[-4] = "背包密文数量不足", -- 背包密文数量不足
	[-5] = "装备密文重复", -- 装备密文重复
	[-6] = "已达到最大装备数量", -- 已达到最大装备数量
	[-7] = "未装备此密文", -- 未装备此密文
	[-8] = "高等级密文回收数量非法", -- 高等级密文回收数量非法
	[-9] = "免费次数已刷新", -- 免费次数已刷新
	[-10] = "无效密文", -- 无效密文--]]
}

-- 阵法石同步
function i3k_sbean.role_arraystone_info.handler(bean)
	--self.info:		DBArrayStone
	g_i3k_game_context:setArrayStoneData(bean.info)
end

-- 祈言
function i3k_sbean.array_stone_prayer(freeTimes, cost)
	local data = i3k_sbean.array_stone_prayer_req.new()
	data.freeTimes = freeTimes
	data.cost = cost
	i3k_game_send_str_cmd(data, "array_stone_prayer_res")
end

function i3k_sbean.array_stone_prayer_res.handler(bean, req)
	--self.ok:		int32	
	--self.ciphertexts:		vector[int32]
	if bean.ok > 0 then
		g_i3k_game_context:arrayStonesPraySuccess(bean.ciphertexts)
		if req and req.cost then
			for k, v in ipairs(req.cost) do
				g_i3k_game_context:SetUseItemData(v.id, v.count, {}, AT_USE_ITEM_FORGE_ENERGY)
			end
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArrayStone, "updateStonePray", bean.ciphertexts)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArrayStone, "updatePrayRedPoint")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_XB, "updateArrayStoneRed")
	end
end

-- 设置密文直接转换能量
function i3k_sbean.array_stone_set_conversion(conversion)
	local data = i3k_sbean.array_stone_set_conversion_req.new()
	data.conversion = conversion
	i3k_game_send_str_cmd(data, "array_stone_set_conversion_res")
end

function i3k_sbean.array_stone_set_conversion_res.handler(bean, req)
	--self.ok:		int32
	if bean.ok > 0 then
		g_i3k_game_context:changeArrayStoneTransform(req.conversion == 1)
	end
end

-- 解锁祈言孔位
function i3k_sbean.array_stone_unlock_hole(holeId, useItems)
	local data = i3k_sbean.array_stone_unlock_hole_req.new()
	data.holeId = holeId
	data.useItems = useItems
	i3k_game_send_str_cmd(data, "array_stone_unlock_hole_res")
end

function i3k_sbean.array_stone_unlock_hole_res.handler(bean, req)
	--self.ok:		int32
	if bean.ok > 0 then
		g_i3k_game_context:addArrayStoneUnlockHole(req.holeId)
		for k, v in ipairs(req.useItems) do
			if v.id ~= 0 then
				g_i3k_game_context:UseCommonItem(v.id, v.count, AT_ARRAY_STONE_UNLOCK_HOLE)
			end
		end
		g_i3k_ui_mgr:CloseUI(eUIID_ArrayStoneUnlockHole)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArrayStone, "updatePrayNode")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArrayStone, "playUnlockPrayAni", req.holeId)
	else
		g_i3k_ui_mgr:PopupTipMessage("")
	end
end

-- 密文上阵
function i3k_sbean.array_stone_ciphertext_equip(ciphertextID)
	local data = i3k_sbean.array_stone_ciphertext_equip_req.new()
	data.ciphertextID = ciphertextID
	i3k_game_send_str_cmd(data, "array_stone_ciphertext_equip_res")
end

function i3k_sbean.array_stone_ciphertext_equip_res.handler(bean, req)
	--self.ok:		int32
	if bean.ok > 0 then
		g_i3k_game_context:equipArrayStone(req.ciphertextID)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18411))
		g_i3k_ui_mgr:CloseUI(eUIID_ArrayStoneMWInfo)
		g_i3k_ui_mgr:CloseUI(eUIID_ArrayStoneMWEquipConfirm)
	else
		g_i3k_ui_mgr:PopupTipMessage(arrayStoneError[bean.ok] or i3k_get_string(18412))
	end
end

-- 密文下阵
function i3k_sbean.array_stone_ciphertext_unequip(ciphertextID)
	local data = i3k_sbean.array_stone_ciphertext_unequip_req.new()
	data.ciphertextID = ciphertextID
	i3k_game_send_str_cmd(data, "array_stone_ciphertext_unequip_res")
end

function i3k_sbean.array_stone_ciphertext_unequip_res.handler(bean, req)
	--self.ok:		int32
	if bean.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18413))
		g_i3k_game_context:unEquipArrayStone(req.ciphertextID)
		g_i3k_ui_mgr:CloseUI(eUIID_ArrayStoneMWInfo)
	else
		g_i3k_ui_mgr:PopupTipMessage(arrayStoneError[bean.ok] or i3k_get_string(18414))
	end
end

-- 密文回收
function i3k_sbean.array_stone_ciphertext_destroy(ciphertexts)
	--self.ciphertexts:		map[int32, int32]	
	local data = i3k_sbean.array_stone_ciphertext_destroy_req.new()
	data.ciphertexts = ciphertexts
	i3k_game_send_str_cmd(data, "array_stone_ciphertext_destroy_res")
end

function i3k_sbean.array_stone_ciphertext_destroy_res.handler(bean, req)
	--self.ok:		int32
	if req then
		if bean.ok > 0 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18415))
			local info = g_i3k_game_context:getArrayStoneData()
			local record = {add = {}, sub = {}}
			for k, v in pairs(req.ciphertexts) do
				table.insert(record.sub, {id = k, count = v})
				if info.bag[k] then
					info.bag[k] = info.bag[k] - v
					if info.bag[k] <= 0 then
						info.bag[k] = nil
					end
				end
				-- info.energy = info.energy + i3k_db_array_stone_cfg[k].recycleEnergy * v
				local getId = i3k_db_array_stone_cfg[k].recycleStoneId
				if getId ~= 0 then
					if not info.bag[getId] then
						info.bag[getId] = 0
					end
					table.insert(record.add, {id = getId, count = i3k_db_array_stone_cfg[k].recycleStoneCount * v})
					info.bag[getId] = info.bag[getId] + i3k_db_array_stone_cfg[k].recycleStoneCount * v
				end
			end
			g_i3k_game_context:setArrayStoneData(info)
			g_i3k_ui_mgr:RefreshUI(eUIID_ArrayStoneBatchRecycle)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArrayStone, "updateStonesUncover", record.add, record.sub)
			g_i3k_ui_mgr:CloseUI(eUIID_ArrayStoneMWInfo)
			g_i3k_ui_mgr:CloseUI(eUIID_ArrayStoneMWRecovery)
			g_i3k_ui_mgr:CloseUI(eUIID_ArrayStoneMWRecoveryConfirm)
		else
			g_i3k_ui_mgr:PopupTipMessage(arrayStoneError[bean.ok] or i3k_get_string(18416))
		end
	end
end

-- 密文合成
function i3k_sbean.array_stone_ciphertext_uplvl(ciphertextID, equip)
	local data = i3k_sbean.array_stone_ciphertext_uplvl_req.new()
	data.ciphertextID = ciphertextID
	data.equip = equip
	i3k_game_send_str_cmd(data, "array_stone_ciphertext_uplvl_res")
end

function i3k_sbean.array_stone_ciphertext_uplvl_res.handler(bean, req)
	--self.ok:		int32
	if bean.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18417))
		g_i3k_game_context:synthetiseArrayStone(req.ciphertextID, req.equip == 1)
		local compoundId = i3k_db_array_stone_cfg[req.ciphertextID].compoundId
		if compoundId ~= 0 then
			g_i3k_ui_mgr:RefreshUI(eUIID_ArrayStoneMWInfo, compoundId)
			g_i3k_ui_mgr:RefreshUI(eUIID_ArrayStoneMWSynthetise, compoundId)
		else
			g_i3k_ui_mgr:CloseUI(eUIID_ArrayStoneMWInfo)
			g_i3k_ui_mgr:CloseUI(eUIID_ArrayStoneMWSynthetise)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(arrayStoneError[bean.ok] or i3k_get_string(18418))
	end
end

-- 密文置换
function i3k_sbean.array_stone_ciphertext_change(ciphertextID, targetID)
	local data = i3k_sbean.array_stone_ciphertext_change_req.new()
	data.ciphertextID = ciphertextID
	data.targetID = targetID
	i3k_game_send_str_cmd(data, "array_stone_ciphertext_change_res")
end

function i3k_sbean.array_stone_ciphertext_change_res.handler(bean, req)
	--self.ok:		int32
	if bean.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18419))
		g_i3k_game_context:displaceArrayStone(req.ciphertextID, req.targetID)
		g_i3k_ui_mgr:CloseUI(eUIID_ArrayStoneMWDisplace)
		g_i3k_ui_mgr:CloseUI(eUIID_ArrayStoneMWInfo)
		local cfg = i3k_db_array_stone_cfg[req.targetID]
		for i,v in ipairs(cfg.transformCost) do
			if v.count ~= 0 then
				g_i3k_game_context:UseCommonItem(v.id, v.count)
			end
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(arrayStoneError[bean.ok] or i3k_get_string(18420))
	end
end

-- 密文锁定
function i3k_sbean.array_stone_ciphertext_lock(ciphertexts)
	--self.ciphertexts:		set[int32]	
	local data = i3k_sbean.array_stone_ciphertext_lock_req.new()
	data.ciphertexts = ciphertexts
	i3k_game_send_str_cmd(data, "array_stone_ciphertext_lock_res")
end

function i3k_sbean.array_stone_ciphertext_lock_res.handler(bean, req)
	--self.ok:		int32
	if bean.ok > 0 then
		g_i3k_game_context:setArrayStoneLock(req.ciphertexts)
		g_i3k_ui_mgr:CloseUI(eUIID_ArrayStoneLock)
	end
end

-- 使用密文能量道具
function i3k_sbean.bag_useitemciphertextenergy(id, count)
	local data = i3k_sbean.bag_useitemciphertextenergy_req.new()
	data.id = id
	data.count = count
	i3k_game_send_str_cmd(data, "bag_useitemciphertextenergy_res")
end

function i3k_sbean.bag_useitemciphertextenergy_res.handler(bean, req)
	--self.ok:		int32
	if bean.ok > 0 then
		g_i3k_game_context:UseCommonItem(req.id, req.count)
		local cfg = g_i3k_db.i3k_db_get_other_item_cfg(req.id)
		g_i3k_ui_mgr:ShowGainItemInfo({{id = g_BASE_ITEM_STONE_ENERGY, count = cfg.args1 * req.count}})
	end
end

-- 使用真言熟练度道具
function i3k_sbean.array_stone_mantra_uplvl(items)
	--self.items:		map[int32, int32]	
	local data = i3k_sbean.array_stone_mantra_uplvl_req.new()
	data.items = items
	i3k_game_send_str_cmd(data, "array_stone_mantra_uplvl_res")
end

function i3k_sbean.array_stone_mantra_uplvl_res.handler(bean, req)
	--self.ok:		int32
	if bean.ok > 0 then
		local info = g_i3k_game_context:getArrayStoneData()
		local oldLvl = g_i3k_db.i3k_db_get_array_stone_level(info.exp)
		local getExps = 0
		for k,v in pairs(req.items) do
			getExps = getExps + g_i3k_db.i3k_db_get_other_item_cfg(k).args1 * v
			g_i3k_game_context:UseCommonItem(k, v)
		end
		g_i3k_game_context:addArrayStoneExperience(getExps)
		local newLvl = g_i3k_db.i3k_db_get_array_stone_level(info.exp)
		if newLvl > oldLvl then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18421))
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArrayStoneUpLevel, "updatePrayLevel")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArrayStoneUpLevel, "updateUseItemScroll")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ArrayStone, "updatePrayRootData")
	end
end

--密文能量添加
function i3k_sbean.role_add_ciphertext_energy.handler(bean)
	--self.amount:		int32	
	--self.reason:		int32	
	g_i3k_game_context:addArrayStoneEnergy(bean.amount, bean.reason)
end

--排行榜查看其他玩家
function i3k_sbean.query_arraystoneoverviews(rid)
	local data = i3k_sbean.query_arraystoneoverviews_req.new()
	data.rid = rid
	i3k_game_send_str_cmd(data, "query_arraystoneoverviews_res")
end

function i3k_sbean.query_arraystoneoverviews_res.handler(bean, req)
	if bean.overview then
		for k, v in ipairs(bean.overview.equips) do
			if v ~= 0 then
				g_i3k_ui_mgr:OpenUI(eUIID_ArrayStoneRanking)
				g_i3k_ui_mgr:RefreshUI(eUIID_ArrayStoneRanking, bean.overview)
				return
			end
		end
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18422))
	end
end
