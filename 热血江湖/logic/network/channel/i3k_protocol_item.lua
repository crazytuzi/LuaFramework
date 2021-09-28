------------------------------------------------------
module(..., package.seeall)

local require = require
require("i3k_sbean")
------------------------------------------------------
--买金币
function i3k_sbean.buy_coins(times,number,temp)
	local data = i3k_sbean.buy_coin_req.new()
	data.times = times
	data.number = number
	data.temp = temp
	i3k_game_send_str_cmd(data,"buy_coin_res")
end

function i3k_sbean.buy_coin_res.handler(bean, req)
	local result = bean.result
	local temp = req.temp
	if result then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BuyCoin, "updateBinding", true)
		g_i3k_ui_mgr:CloseUI(eUIID_BuyCoinBat)
		g_i3k_game_context:BuyCoins(req, result)
	end
end
--购买体力
function i3k_sbean.buy_vit(number)
	local data = i3k_sbean.buy_vit_req.new()
	data.number = number
	i3k_game_send_str_cmd(data, "buy_vit_res")
end

function i3k_sbean.buy_vit_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:SetBuyVitData(req.number)
	end
end

--背包扩展
function i3k_sbean.bag_expand(times, useItem, info)
	local data = i3k_sbean.bag_expand_req.new()
	data.times = times
	data.useItem = useItem
	data.info = info
	i3k_game_send_str_cmd(data,"bag_expand_res")
end

function i3k_sbean.bag_expand_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:ExpandBagSize(i3k_db_common.bag.expandCount, req.times)
		if req then
			if req.useItem == 0 then
				g_i3k_game_context:UseDiamond(req.info.costCount, false, AT_EXPAND_BAG_CELLS)
				g_i3k_ui_mgr:CloseUI(eUIID_Bag_extend)
			else
				g_i3k_game_context:UseCommonItem(req.info.itemId, req.info.itemCount, AT_EXPAND_BAG_CELLS)
				g_i3k_ui_mgr:CloseUI(eUIID_Bag_extend)
			end
		end
	end
end
---------------------------------------------------------------------
--装备售出
function i3k_sbean.bag_sellequip(id, guid)
	local data = i3k_sbean.bag_sellequip_req.new()
	data.id = id
	data.guid = guid
	i3k_game_send_str_cmd(data, "bag_sellequip_res")
end

function i3k_sbean.bag_sellequip_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:DelBagEquip(req.id, req.guid,AT_SELL_BAG_EQUIP)
	end
end
----------------------------------------------------------------------
--道具物品出售
function i3k_sbean.bag_sellitem(id, count)
	local data = i3k_sbean.bag_sellitem_req.new()
	data.id = id
	data.count = count
	i3k_game_send_str_cmd(data, "bag_sellitem_res")
end

function i3k_sbean.bag_sellitem_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:UseBagMiscellaneous(req.id, tonumber(req.count))
	end
end
---------------------------------------------------------------------
--宝石出售
function i3k_sbean.bag_sellgem(id, count)
	local data = i3k_sbean.bag_sellgem_req.new()
	data.id = id
	data.count = count
	i3k_game_send_str_cmd(data, "bag_sellgem_res")
end

function i3k_sbean.bag_sellgem_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:UseBagMiscellaneous(req.id, req.count)
	end
end
--------------------------------------------------------------------
--心法书出售
function i3k_sbean.bag_sellbook(id, count)
	local data = i3k_sbean.bag_sellbook_req.new()
	data.id = id
	data.count = count
	i3k_game_send_str_cmd(data, i3k_sbean.bag_sellbook_res.getName())
end

function i3k_sbean.bag_sellbook_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:UseBagMiscellaneous(req.id, req.count)
	end
end
-----------------------------------------------------------------
--装备的批量出售
function i3k_sbean.bag_batchsellequips(equips)
	local data = i3k_sbean.bag_batchsellequips_req.new()
	data.equips = equips
	i3k_game_send_str_cmd(data, "bag_batchsellequips_res")
end

function i3k_sbean.bag_batchsellequips_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:SetBatchSellEquipsData(req.equips)
	end
end
------------------------------------------------------------------
--道具物品批量出售
function i3k_sbean.bag_batchsellitems(items)
	local data = i3k_sbean.bag_batchsellitems_req.new()
	data.items = items
	i3k_game_send_str_cmd(data, "bag_batchsellitems_res")
end

function i3k_sbean.bag_batchsellitems_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:SetBatchSellItem(req.items)
	end
end


function i3k_sbean.bag_destroyItems(items)
	local data = i3k_sbean.bag_destoryitems_req.new()
	local dum
	local newItems = {}
	for i,v in ipairs(items) do
		if newItems[i-1] and newItems[i-1].id == v.id then
			newItems[i-1].count = v.count + newItems[i-1].count
		else
			dum = i3k_sbean.DummyGoods.new()
			dum.id = v.id
			dum.count = v.count
			newItems[#newItems+1] = dum
		end

	end
	data.items = newItems
	i3k_game_send_str_cmd(data, "bag_destoryitems_res")
end

function i3k_sbean.bag_destoryitems_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:SetDestroyItem(req.items)
	end
end
----------------------------------------------------------------
--宝石批量出售
function i3k_sbean.bag_batchsellgems(gems)
	local data = i3k_sbean.bag_batchsellgems_req.new()
	data.gems  = gems
	i3k_game_send_str_cmd(data, "bag_batchsellgems_res")
end

function i3k_sbean.bag_batchsellgems_res.handler(bean,req)
	if bean.ok == 1 then
		g_i3k_game_context:SetBatchSellItem(req.gems)
	end
end
----------------------------------------------------------------
--心法书批量出售
function i3k_sbean.bag_batchsellbooks(books)
	local data = i3k_sbean.bag_batchsellbooks_req.new()
	data.books = books
	i3k_game_send_str_cmd(data, "bag_batchsellbooks_res")
end

function i3k_sbean.bag_batchsellbooks_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:SetBatchSellItem(req.books)
	end
end
-----------------------------------------------------------------
--使用道具礼包
function i3k_sbean.bag_useitemgift(id, count)
	local data = i3k_sbean.bag_useitemgift_req.new()
	data.id  = id
	data.count = count
	i3k_game_send_str_cmd(data, "bag_useitemgift_res")
end

function i3k_sbean.bag_useitemgift_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:SetUseItemData(req.id, req.count,nil,AT_USE_ITEM_GIFT_BOX)
	elseif bean.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(2001))
	end
end
---------------------------------------------------------------
--使用金币包
function i3k_sbean.bag_useitemcoin(id, count)
	local data = i3k_sbean.bag_useitemcoin_req.new()
	data.id = id
	data.count = count
	i3k_game_send_str_cmd(data, "bag_useitemcoin_res")
end

function i3k_sbean.bag_useitemcoin_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:SetUseItemData(req.id, req.count,nil,AT_USE_ITEM_COIN_BAG)
	elseif bean.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(2001))
	end
end
-------------------------------------------------------------
--使用钻石礼包
function i3k_sbean.bag_useitemdiamond(id, count)
	local data = i3k_sbean.bag_useitemdiamond_req.new()
	data.id = id
	data.count = count
	i3k_game_send_str_cmd(data, "bag_useitemdiamond_res")
end

function i3k_sbean.bag_useitemdiamond_res.handler(bean,req)
	if bean.ok == 1 then
		g_i3k_game_context:SetUseItemData(req.id, req.count,nil,AT_USE_ITEM_DIAMOND_BAG)

	elseif bean.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(2001))
	end
end
------------------------------------------------------
--使用道具经验丹
function i3k_sbean.bag_useitemexp(id, count)
	local data = i3k_sbean.bag_useitemexp_req.new()
	data.id = id
	data.count = count
	i3k_game_send_str_cmd(data, "bag_useitemexp_res")
end

function i3k_sbean.bag_useitemexp_res.handler(bean,req)
	if bean.ok == 1 then
		g_i3k_game_context:SetUseItemData(req.id, req.count,nil,AT_USE_ITEM_EXP)
		g_i3k_ui_mgr:CloseUI(eUIID_UseItems) --使用成功时关闭当前使用的界面
		g_i3k_ui_mgr:CloseUI(eUIID_UseLimitConsumeItems)
		g_i3k_ui_mgr:CloseUI(eUIID_UseLimitItems)
	elseif bean.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(2001))
	end
end
------------------------------------------------------
--使用道具普通恢复hp
function i3k_sbean.bag_useitemhp(id,count,lastusetime)
	local data = i3k_sbean.bag_useitemhp_req.new()
	data.id = id
	data.count = count
	data.lastusetime = lastusetime
	i3k_game_send_str_cmd(data, "bag_useitemhp_res")
end

function i3k_sbean.bag_useitemhp_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:UseBagMiscellaneous(req.id, req.count)
		g_i3k_game_context:SetUseDrugTime(i3k_integer(i3k_game_get_time()))
	elseif bean.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(2001))
	else
		g_i3k_game_context:SetUseDrugTime(req.lastusetime)
	end
end
-------------------------------------------------------
--使用道具vip普通恢复hp
function i3k_sbean.bag_useitemhppool(id, count)
	local data = i3k_sbean.bag_useitemhppool_req.new()
	data.id = id
	data.count = count
	local hppool = g_i3k_game_context:GetVipBloodPool()
	local hppoolmax = i3k_db_common.drug.viplimited
	local itemhp = g_i3k_db.i3k_db_get_other_item_cfg(id).args1
	local hero = i3k_game_get_player_hero()
	if hero then
		hppoolmax = hppoolmax + hero:GetPropertyValue(ePropID_MeridianHPUpper)
		itemhp = itemhp + itemhp* hero:GetPropertyValue(ePropID_MeridianHPIncrease)
	end
	if hppool + itemhp * count > hppoolmax then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(209))
		return
	end
	i3k_game_send_str_cmd(data, "bag_useitemhppool_res")
end

function i3k_sbean.bag_useitemhppool_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:SetVipBloodPoolData(req.id, req.count)
	elseif bean.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(2001))
	end
end
--------------------------------------------------------
--使用道具宝箱
function i3k_sbean.bag_useitemchest(id, count)
	local data = i3k_sbean.bag_useitemchest_req.new()
	data.id = id
	data.count = count
	i3k_game_send_str_cmd(data, "bag_useitemchest_res")
end

function i3k_sbean.bag_useitemchest_res.handler(bean, req)
	if bean.ok > 0 then
		local itemData = {}
		for i, e in pairs(bean.items) do
			for k, v in pairs(e.items) do
				table.insert(itemData, {id = k, count = v})
			end
		end
		g_i3k_game_context:SetUseItemData(req.id, req.count, itemData,AT_USE_ITEM_CHEST_IMPL)
	elseif bean.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(2001))
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(123))
	end
end
--------------------------------------------------------------------
--使用道具装备能量丹
function i3k_sbean.bag_useitemequipenergy(id,count)
	local data = i3k_sbean.bag_useitemequipenergy_req.new()
	data.id = id
	data.count = count
	i3k_game_send_str_cmd(data, "bag_useitemequipenergy_res")
end

function i3k_sbean.bag_useitemequipenergy_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:SetUseItemData(req.id, req.count,nil,AT_USE_ITEM_EQUIP_ENERGY)
	elseif bean.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(2001))
	end
end
----------------------------------------------------------------
--使用道具宝石能量丹
function i3k_sbean.bag_useitemgemenergy(id,count)
	local data = i3k_sbean.bag_useitemgemenergy_req.new()
	data.id = id
	data.count = count
	i3k_game_send_str_cmd(data, "bag_useitemgemenergy_res")
end

function i3k_sbean.bag_useitemgemenergy_res.handler(bean,req)
	if bean.ok == 1 then
		g_i3k_game_context:SetUseItemData(req.id, req.count,nil,AT_USE_ITEM_GEM_ENERGY)
	elseif bean.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(2001))
	end
end
---------------------------------------------------------------
--使用道具心法悟性丹
function i3k_sbean.bag_useiteminspiration(id, count)
	local data = i3k_sbean.bag_useiteminspiration_req.new()
	data.id = id
	data.count = count
	i3k_game_send_str_cmd(data, "bag_useiteminspiration_res")
end

function i3k_sbean.bag_useiteminspiration_res.handler(bean,req)
	if bean.ok == 1 then
		g_i3k_game_context:SetUseItemData(req.id, req.count,nil,AT_USE_ITEM_SPIRIT_INSPIRATION)
	elseif bean.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(2001))
	end
end
---------------------------------------------------------------
--使用道具体力包
function i3k_sbean.bag_useitemvit(id, count)
	local data = i3k_sbean.bag_useitemvit_req.new()
	data.id = id
	data.count = count
	i3k_game_send_str_cmd(data, "bag_useitemvit_res")
end

function i3k_sbean.bag_useitemvit_res.handler(bean,req)
	if bean.ok == 1 then
		g_i3k_game_context:SetUseItemData(req.id, req.count,nil,AT_USE_ITEM_AS_VIT)
		g_i3k_ui_mgr:RefreshUI(eUIID_UseVit, true)
	elseif bean.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(2001))
	end
end
------------------------------------------------------------
--使用信件道具jxw
function i3k_sbean.bag_useitemletter(id)
	local data = i3k_sbean.bag_useitemletter_req.new()
	data.itemId = id
	i3k_game_send_str_cmd(data, "bag_useitemletter_res")
end

function i3k_sbean.bag_useitemletter_res.handler(bean,req)
	if bean.ok > 0 then
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ItemMailUI, "setData",req.itemId)
	elseif  bean.ok ==-101 then
		g_i3k_ui_mgr:PopupTipMessage("信件无法使用")
	elseif   bean.ok ==-102 then
		g_i3k_ui_mgr:PopupTipMessage("物件到达最大使用次数")
	elseif   bean.ok ==-103 then
		g_i3k_ui_mgr:PopupTipMessage("已经拥有或完成该信件任务")
	elseif   bean.ok ==-104 then
		g_i3k_ui_mgr:PopupTipMessage("无法接取任务")
	end
end

-------------------------------------------------------------
--合成碎片
function i3k_sbean.bag_piececompose(info)
	local data = i3k_sbean.bag_piececompose_req.new()
	data.composeId = info.id
	data.count = info.count
	data.needItemId = info.needItemId
	data.needItemConunt = info.needItemConunt
	i3k_game_send_str_cmd(data, "bag_piececompose_res")
end

function i3k_sbean.bag_piececompose_res.handler(bean, req)
	if bean.ok == 1 then
		if next(req.needItemId) then
			for i=1, #req.needItemId do
				if req.needItemId[i] ~= 0 then
					g_i3k_game_context:UseCommonItem(req.needItemId[i], req.needItemConunt[i] * req.count, AT_PIECE_COMPOSE)
				end
			end
		end
		local getItemID = i3k_db_compound[req.composeId].getItemID
		local getItemCount = i3k_db_compound[req.composeId].getItemCount
		g_i3k_ui_mgr:CloseUI(eUIID_Compound)
		g_i3k_ui_mgr:CloseUI(eUIID_CompoundItems)
		local getItemID = i3k_db_compound[req.composeId].getItemID
		local getItemCount = i3k_db_compound[req.composeId].getItemCount
		local tmp_items = {}
		local t = {id = getItemID,count = getItemCount * req.count}
		table.insert(tmp_items,t)
		g_i3k_ui_mgr:ShowGainItemInfo(tmp_items)
	end
end

--------------------------------------------------------------
--使用扣除罪恶点道具
function i3k_sbean.bag_useitemevil(itemId, count)
	local data = i3k_sbean.bag_useitemevil_req.new()
	data.itemId = itemId
	data.count = count
	data.nowPKvalue = g_i3k_game_context:GetCurrentPKValue()
	if data.nowPKvalue <= 0 then
		g_i3k_ui_mgr:PopupTipMessage("当前没有罪恶值，无法使用")
		return
	end
	i3k_game_send_str_cmd(data, "bag_useitemevil_res")
end

function i3k_sbean.bag_useitemevil_res.handler(bean, req)
	if bean.ok == 1 then
		local data = g_i3k_db.i3k_db_get_other_item_cfg(req.itemId)
		if data then
			g_i3k_game_context:UseCommonItem(req.itemId, req.count,AT_USE_ITEM_EVIL_VALUE)
			local subPKvalue = data.args1 * req.count
			local PKvalue = req.nowPKvalue - subPKvalue <= 0 and 0 or req.nowPKvalue - subPKvalue
			g_i3k_ui_mgr:PopupTipMessage(string.format("成功扣除%s罪恶值", req.nowPKvalue - PKvalue))
		end
	elseif bean.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(2001))
	end
end
--------------------------------------------------------------
--使用时装道具
function i3k_sbean.bag_useitemfashion(id)
	local data = i3k_sbean.bag_useitemfashion_req.new()
	data.id = id
	i3k_game_send_str_cmd(data, "bag_useitemfashion_res")
end

function i3k_sbean.bag_useitemfashion_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:SetUseFashionData(req.id)
	end
end
--------------------------------------------------------------
--使用装备升级卷轴道具
function i3k_sbean.bag_useitem_equip_up_to_level(pos, id)
	local data = i3k_sbean.bag_useitem_equip_up_to_level_req.new()
	data.pos = pos
	data.itemId = id
	i3k_game_send_str_cmd(data, "bag_useitem_equip_up_to_level_res")
end
function i3k_sbean.bag_useitem_equip_up_to_level_res.handler(bean, req)
	if bean.ok > 0 then
		local item =  g_i3k_db.i3k_db_get_other_item_cfg(req.itemId)
		local equipID = g_i3k_game_context:GetWearEquips()[req.pos].equip.equip_id
		g_i3k_game_context:UseCommonItem(req.itemId, 1, AT_USE_ITEM_EVIL_VALUE)
		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:SetEquipStrengLevel(req.pos, g_i3k_db.i3k_db_get_other_item_cfg(req.itemId).args1, equipID)
		g_i3k_game_context:ShowPowerChange()
	end
end

----------------------------------------------------------
--合并非绑定道具道具
function i3k_sbean.bag_merge(id)
	local data = i3k_sbean.bag_merge_req.new()
	data.itemId = id
	local haveCount = g_i3k_game_context:GetCommonItemCanUseCount(-id)
	if haveCount == 0 then
		local item_cfg = g_i3k_db.i3k_db_get_other_item_cfg(id)
		local str = item_cfg and item_cfg.name or nil
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(530, str))
	end
	i3k_game_send_str_cmd(data, "bag_merge_res")
end

function i3k_sbean.bag_merge_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:combineItemFromID(req.itemId)
	end
end

----------------------------------------------------------
--批量合并非绑定道具道具
function i3k_sbean.bag_merge_all(ids)
	local data = i3k_sbean.bag_merge_all_req.new()
	data.itemIds = ids
	i3k_game_send_str_cmd(data, "bag_merge_all_res")
end

function i3k_sbean.bag_merge_all_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:combineItemFromIDs(req.itemIds)
		g_i3k_ui_mgr:CloseUI(eUIID_Quick_Combine)
	end
end

------------------------------------------------------------
--穿戴时装
function i3k_sbean.fashion_upwear(fashionID)
	local data = i3k_sbean.fashion_upwear_req.new()
	data.fashionID = fashionID
	i3k_game_send_str_cmd(data, "fashion_upwear_res")
end

function i3k_sbean.fashion_upwear_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:SetWearFashionData(req.fashionID)
		g_i3k_game_context:ShowPowerChange()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FashionDress, "updateRolePower")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FashionDress, "updateIsShowFashion")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FashionDress, "setSkinShowTypeScroll")
		DCEvent.onEvent("穿戴时装", { ["时装ID"] = tostring(req.fashionID)})
	end
end
------------------------------------------------------------
-- 显示/隐藏时装
function i3k_sbean.fashion_setshow(showType)
	local data = i3k_sbean.weapondisplay_select_req.new()
	data.type = showType
	data.partType = g_FashionType_Dress
	i3k_game_send_str_cmd(data, "weapondisplay_select_res")
	end

------------------------------------------------------------
--穿装备
function i3k_sbean.equip_upwear(id, guid, pos)
	local data = i3k_sbean.equip_upwear_req.new()
	data.id = id
	data.guid = guid
	data.pos = pos
	i3k_game_send_str_cmd(data, "equip_upwear_res")
end


function i3k_sbean.equip_upwear_res.handler(bean,req)
	if bean.ok  == 1 then


		g_i3k_game_context:wearEquipHandler(req.id, req.guid, req.pos, nil)

	end
end
-----------------------------------------------------------
--自动穿装备
function i3k_sbean.equip_autoupwear(best_equip, temp_pos)
	local data = i3k_sbean.equip_autoupwear_req.new()
	data.equips = best_equip
	data.posTable = temp_pos
	i3k_game_send_str_cmd(data, "equip_autoupwear_res")
end

function i3k_sbean.equip_autoupwear_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:SetAutoWearEquips(req.equips, req.posTable)
		g_i3k_game_context:ShowPowerChange()
		g_i3k_game_context:LeadCheck()
		g_i3k_game_context:updatePlayerHeirloomShow()
	end
end
-------------------------------------------------------------
--脱装备
function i3k_sbean.equip_downwear(guid, pos)
	local data = i3k_sbean.equip_downwear_req.new()
	data.guid = guid
	data.pos = pos
	i3k_game_send_str_cmd(data, "equip_downwear_res")
end

function i3k_sbean.equip_downwear_res.handler(bean, req)
	if bean.ok == 1 then
		--如果脱下的装备有锤炼技能 武器祝福 把武器祝福值清空
		local partID = req.pos
		local hammerSkill = g_i3k_game_context:GetWearEquips()[partID].equip.hammerSkill
		if hammerSkill and next(hammerSkill) then
			local hero = i3k_game_get_player_hero()
			for k, v in pairs(hammerSkill) do
				local skillCfg = i3k_db_equip_temper_skill[k][v]
				if skillCfg.skillType == g_EQUIP_SKILL_TYPE_WEAPON_BLESS then
					hero:ClearWeaponBlessState()
				elseif skillCfg.skillType == g_EQUIP_SKILL_TYPE_REVISE_WEAPON_BLESS_ARGUMENT then
					hero:UpdateWeaponBlessProp()
				end
			end
		end

		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:SetDownWearEquip(req.pos)
		g_i3k_game_context:ShowPowerChange()
		g_i3k_game_context:updatePlayerHeirloomShow()

		local partID = g_i3k_game_context:GetDefaultTemperSelectEquip()
		if partID ~= 0 and partID == req.pos then --如果脱掉了未保存锤炼的装备 清空临时数据
			g_i3k_game_context:ClearTempEquipProps()
			g_i3k_game_context:ResetDefaultTemperSelectEquip()
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase,"updateRoleWeaponBless", g_i3k_game_context:GetActiveWeaponBlessID())
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase,"updateRoleWeaponBlessEnergy", g_i3k_game_context:GetRoleWeaponBlessEnergy())
	end
end
----------------------------------------------------------
--装备强化
function i3k_sbean.equip_levelup(pos, level)
	local data = i3k_sbean.equip_levelup_req.new()
	data.pos = pos
	data.level = level
	i3k_game_send_str_cmd(data, "equip_levelup_res")
end

function i3k_sbean.equip_levelup_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:SetEquipStrengData(req.pos, req.level)
		g_i3k_game_context:ShowPowerChange()
		g_i3k_game_context:LeadCheck()
		if g_i3k_ui_mgr:GetUI(eUIID_ChooseAutoStreng) then
			g_i3k_ui_mgr:CloseUI(eUIID_ChooseAutoStreng)
		end
	end
end
--------------------------------------------------------------
--装备突破
function i3k_sbean.equip_levelup_break(pos)
	local bean = i3k_sbean.equip_levelup_break_req.new()
	bean.pos = pos
	i3k_game_send_str_cmd(bean, "equip_levelup_break_res")
end

function i3k_sbean.equip_levelup_break_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:SetEquipStrengBreak(req.pos)
		g_i3k_game_context:LeadCheck()
	else
		g_i3k_ui_mgr:PopupTipMessage("突破失败,ErrorCode="..bean.ok)
	end
end
----------------------------------------------------------------
--装备批量强化
function i3k_sbean.equip_batchlevelup(posLevels, pos)
	local data = i3k_sbean.equip_batchlevelup_req.new()
	data.posLevels = posLevels
	data.pos = pos
	i3k_game_send_str_cmd(data, "equip_batchlevelup_res")
end

function i3k_sbean.equip_batchlevelup_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:SetAutoEquipStrengData(req.posLevels, req.pos)
		g_i3k_game_context:ShowPowerChange()
		g_i3k_game_context:LeadCheck()
		g_i3k_ui_mgr:CloseUI(eUIID_ChooseAutoStreng)
	end
end

------------------------------------------------------------------
--装备升星
function i3k_sbean.equip_starup(pos, level)
	local data = i3k_sbean.equip_starup_req.new()
	data.pos = pos
	data.level = level
	i3k_game_send_str_cmd(data, "equip_starup_res")
end

function i3k_sbean.equip_starup_res.handler(bean,req)
	if bean.ok == 1 then
		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:SetEquipUpStarData(req.pos, req.level)
		g_i3k_game_context:ShowPowerChange()
		g_i3k_game_context:LeadCheck()
	elseif  bean.ok ==-1 then
	    g_i3k_game_context:DelEquipUpStarItem(req.pos, req.level)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(636))
	end
end
----------------------------------------------------------
--水晶装备修复
function i3k_sbean.equip_repair(pos)
	local data = i3k_sbean.equip_repair_req.new()
	data.pos = pos
	i3k_game_send_str_cmd(data, "equip_repair_res")
end

function i3k_sbean.equip_repair_res.handler(bean, req)
	g_i3k_game_context:SetPrePower()
	g_i3k_game_context:SetEquipRepairData(req.pos, bean.ok)
	g_i3k_game_context:ShowPowerChange()
end

----------------------------------------------------------
--装备部位宝石镶嵌
function i3k_sbean.gem_inlay(pos, seq, gemId)
	local data = i3k_sbean.gem_inlay_req.new()
	data.pos = pos
	data.seq = seq
	data.gemId = gemId
	i3k_game_send_str_cmd(data, "gem_inlay_res")
end

function i3k_sbean.gem_inlay_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:SetGemInlayData(req.pos, req.seq, req.gemId)
		g_i3k_game_context:ShowPowerChange()
	end
end

-----------------------------Unlay---------------------------------
--装备部位宝石拆除
function i3k_sbean.gem_unlay(pos,seq,gemId)
	local data = i3k_sbean.gem_unlay_req.new()
	data.pos = pos
	data.seq = seq
	data.gemId = gemId
	i3k_game_send_str_cmd(data, "gem_unlay_res")
end

function i3k_sbean.gem_unlay_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:SetGemUnlayData(req.pos, req.seq, req.gemId)
		g_i3k_game_context:ShowPowerChange()
	end
end

---------------------------------------------------------------------------
--装备部位宝石升级
function i3k_sbean.gem_levelup(pos, seq, toId, needItem)
	local data = i3k_sbean.gem_levelup_req.new()
	data.pos = pos
	data.seq = seq
	data.toId = toId
	data.needItem = needItem
	i3k_game_send_str_cmd(data, "gem_levelup_res")
end

function i3k_sbean.gem_levelup_res.handler(bean,req)
	if bean.ok == 1 then
		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:SetGemUpLevelData(req.pos, req.seq, req.toId, req.needItem)
		g_i3k_game_context:ShowPowerChange()
	end
end

--宝石祝福开启
function i3k_sbean.equip_gem_bless(pos, seq, gemId, level)
	local data = i3k_sbean.equip_gem_bless_req.new()
	data.pos = pos
	data.seq = seq
	data.gemId = gemId
	if not level then
		data.level = 1
	else
		data.level = level + 1
	end
	i3k_game_send_str_cmd(data, "equip_gem_bless_res")
end

function i3k_sbean.equip_gem_bless_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:SetGemBlessData(req.pos, req.seq, req.gemId, req.level)
	end
end

--------------------------------杂货购买-----------------------------------------
-- 买物品
--Packet:store_buy_req
function i3k_sbean.store_buy(id,count,finalcount,gid)
	local store_buy = i3k_sbean.store_buy_req.new()
	store_buy.gid=gid
	store_buy.id = id
	store_buy.count = count
	store_buy.finalcount = finalcount
	i3k_game_send_str_cmd(store_buy, i3k_sbean.store_buy_res.getName())
end
-- 买物品
--Packet:store_buy_res
function i3k_sbean.store_buy_res.handler(bean, res)
	local flag = bean.ok
	local pkpunish = g_i3k_game_context:GetPKPunish()--pk惩罚
	if flag > 0 then
		local id = res.id
		local item = nil
		for i,v in ipairs(i3k_db_drugshop[res.gid]) do
			if v.id == res.id then
				item = v
				break
			end
		end

		local itemcount = res.count
		--local price = item.itemprice * itemcount*(1+pkpunish)
		local finalcount = res.finalcount
		g_i3k_game_context:UseCommonItem(item.buytype,bean.ok,AT_STROE_BUY)--price
		if finalcount > 1 then--
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(189,i3k_db.i3k_db_get_common_item_name(item.linkitemid).."*"..finalcount))
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(189,i3k_db.i3k_db_get_common_item_name(item.linkitemid)))
		end
		DCItem.buy(item.linkitemid,g_i3k_db.i3k_db_get_common_item_is_free_type(item.linkitemid),finalcount, bean.ok, item.buytype, AT_STROE_BUY)
	else
		g_i3k_ui_mgr:PopupTipMessage("购买失败")
	end
end

--------------------------------赠花相关-----------------------------------------
function i3k_sbean.give_flower(rid, count, name)
	local data = i3k_sbean.give_flower_req.new()
	data.rid = rid
	data.count = count
	data.name = name
	i3k_game_send_str_cmd(data, "give_flower_res")
end

function i3k_sbean.give_flower_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:SetGiveFlowerData(req.count, req.name)
	end
end

-------------------------------套装相关——------------------------------------
function i3k_sbean.buy_suite(suiteId, equipId)
	local data = i3k_sbean.suite_buy_req.new()
	data.suiteId = suiteId
	data.equipId = equipId
	i3k_game_send_str_cmd(data, "suite_buy_res")
end

function i3k_sbean.suite_buy_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:SetBuySuitData(req.suiteId, req.equipId)
	end
end

---------------------------月卡体验卡----------------------------------------------
function i3k_sbean.goto_bag_usemonthlycard(id, endTime)
	local data = i3k_sbean.bag_usemonthlycard_req.new()
	data.id = id
	data.endTime = endTime
	i3k_game_send_str_cmd(data, "bag_usemonthlycard_res")
end

function i3k_sbean.bag_usemonthlycard_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:SetUseMonthCard(req.id, req.endTime)
	elseif bean.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(2001))
	end
end

------------------------vip体验卡------------------------------------------
function i3k_sbean.goto_bag_usevipcard(id, vipLevel)
	local data = i3k_sbean.bag_usevipcard_req.new()
	data.id = id
	data.vipLevel = vipLevel
	i3k_game_send_str_cmd(data, "bag_usevipcard_res")
end

function i3k_sbean.bag_usevipcard_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:SetUseVipCard(req.id, req.vipLevel)
		local str = string.format("正在体验贵族%s级",req.vipLevel)
		g_i3k_ui_mgr:PopupTipMessage(str)
	elseif bean.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(2001))
	end
end

--------------------登入给到vip的信息----------------------------------

function i3k_sbean.role_tempvip.handler(bean)
	if bean then
		g_i3k_game_context:SetVipExperienceLevel(bean.tempVipLvl, bean.tempVipEndTime)
	end
end


----------------------------称号相关--------------------------------------

--登入同步的称号信息
function i3k_sbean.role_titles.handler(bean)
	if bean then
		g_i3k_game_context:SetRoleTitlesInfo(bean.titles,bean.curPermanent,bean.equipedtitles, bean.permanent_pos)
		g_i3k_game_context:RefreshTitleProps()
		g_i3k_game_context:setTitlesUnlockPlace(bean.slotsize)
	end
end

--通知客户端更新称号
function i3k_sbean.role_title_update.handler(bean)
	if bean then
		g_i3k_game_context:SetPrePower()
		if bean.endTime == 0 then
			--删除称号
			g_i3k_game_context:DeleteRoleTitle(bean.id)
		elseif bean.endTime == -1 then
			--增加永久称号
			g_i3k_game_context:AddTitles(bean.id, bean.endTime)
		elseif bean.endTime > 0 then
			--增加时效称号
			g_i3k_game_context:AddTitles(bean.id, bean.endTime)
		end
		--g_i3k_game_context:RefreshTitleProps()
		g_i3k_game_context:ShowPowerChange()
		if g_i3k_ui_mgr:GetUI(eUIID_RoleTitles) then
			g_i3k_ui_mgr:RefreshUI(eUIID_RoleTitles)
		end
	end
end

--设置当前永久称号
function i3k_sbean.goto_permanenttitle_set(id, state, infoID, titleType)
	local data = i3k_sbean.permanenttitle_set_req.new()
	data.id = id
	data.infoID = infoID
	data.state = state
	if titleType then
		data.titleType = titleType
	end
	if state == 1 and not g_i3k_game_context:getRoleTitleCanEquip(id) then
		local allEquipTitle = g_i3k_game_context:GetAllEquipTitles()
		if #allEquipTitle >= i3k_db_common.roleTitles.titleMaxCount then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(517))
			return
		end
		g_i3k_ui_mgr:PopupTipMessage("未解锁更多槽位，装备失败")
		return
	end
	i3k_game_send_str_cmd(data, "permanenttitle_set_res")
end

function i3k_sbean.permanenttitle_set_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_game_context:SetAllEquipTitles(req.infoID, req.state)
		if req.titleType then
			g_i3k_game_context:SetNowEquipTitle(-1)
		else
			g_i3k_game_context:SetNowEquipTitle(req.id)
		end
		g_i3k_game_context:ChangeRoleTitle()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_RoleTitles, "updateTitlePlace")
		if req.id > 0 then
			DCEvent.onEvent("使用称号", { ["称号ID"] = tostring(req.id)})
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("永久称号服务器报错")
	end
end

--设置当前时效称号
function i3k_sbean.goto_timedtitle_set(id, state, titleType)
	local data = i3k_sbean.timedtitle_set_req.new()
	data.id = id
	data.state = state
	data.titleType = titleType
	if state == 1 then
		local allEquipTitle = g_i3k_game_context:GetAllEquipTitles()
		if #allEquipTitle >= i3k_db_common.roleTitles.titleMaxCount then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(517))
			return
		end
	end
	if state ~= 0 and not g_i3k_game_context:getRoleTitleCanEquip(id) then
		g_i3k_ui_mgr:PopupTipMessage("未解锁更多槽位，装备失败")
		return
	end
	i3k_game_send_str_cmd(data, "timedtitle_set_res")
end

function i3k_sbean.timedtitle_set_res.handler(bean, req)
	if bean.ok ~= 0 then
		g_i3k_game_context:SetAllEquipTitles(req.id, req.state)
		g_i3k_game_context:ChangeRoleTitle()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_RoleTitles, "updateTitlePlace")
		if req.id > 0 then
			DCEvent.onEvent("使用称号", { ["称号ID"] = tostring(req.id)})
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("时效称号服务器报错")
	end
end

function i3k_sbean.titleslot_unlock(index)
	local data = i3k_sbean.titleslot_unlock_req.new()
	data.slotnum = index
	i3k_game_send_str_cmd(data, "titleslot_unlock_res")
end

function i3k_sbean.titleslot_unlock_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:setTitlesUnlockPlace(req.slotnum)
		g_i3k_game_context:UseDiamond(i3k_db_common.roleTitles.clearPrice[req.slotnum-1], true, AT_TITLE_UNLOCKSLOT)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_RoleTitles, "updateTitlePlace")
	end
end

------------------------使用增加武勋道具------------------------------------------
function i3k_sbean.goto_bag_useitemfeat(id, count)
	local data = i3k_sbean.bag_useitemfeat_req.new()
	data.id = id
	data.count = count
	i3k_game_send_str_cmd(data, "bag_useitemfeat_res")
end

function i3k_sbean.bag_useitemfeat_res.handler(bean, req)
	if bean.ok ==1 then
		local cfg = g_i3k_db.i3k_db_get_other_item_cfg(req.id)
		g_i3k_game_context:SetUseItemData(req.id, req.count,nil,AT_USE_ITEM_FEAT_ADDER)
		local str = string.format("武勋成功增加了%s点",cfg.args1*req.count)
		g_i3k_ui_mgr:PopupTipMessage(str)
	elseif bean.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(2001))
	end
end

---------------------------购买基础物品道具--------------------------------------
function i3k_sbean.base_dummygoods_quick_buy(buyItemId, times)
	local data = i3k_sbean.base_dummygoods_quick_buy_req.new()
	data.buyItemId = buyItemId
	data.times = times
	i3k_game_send_str_cmd(data, "base_dummygoods_quick_buy_res")
end

function i3k_sbean.base_dummygoods_quick_buy_res.handler(bean, req)
	if bean.ok > 0 then
		local cfg = g_i3k_db.i3k_db_get_base_item_cfg(req.buyItemId)
		g_i3k_game_context:UseCommonItem(cfg.isCanbuy, req.times*cfg.price)
		g_i3k_ui_mgr:RefreshUI(eUIID_DB)
		g_i3k_ui_mgr:RefreshUI(eUIID_DBF)
		g_i3k_ui_mgr:PopupTipMessage(string.format("成功购买%s%s", cfg.name, req.times*cfg.addCount))
	end
end

------------------------仓库-----------------------------------------------
--解锁私人仓库
function i3k_sbean.unlock_private_warehouse(needMoney)
	local data = i3k_sbean.unlock_private_warehouse_req.new()
	data.needMoney = needMoney
	i3k_game_send_str_cmd(data, "unlock_private_warehouse_res")
end

function i3k_sbean.unlock_private_warehouse_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_ui_mgr:CloseUI(eUIID_IsBuyWareHouse)
		g_i3k_game_context:UseDiamond(req.needMoney, true, AT_UNLOCK_PRIVATE_WAREHOUSE)
		i3k_sbean.private_warehouse(eUIID_BuyPrivateWareHouse);
		g_i3k_ui_mgr:PopupTipMessage(string.format("成功购买"))
	else
		g_i3k_ui_mgr:CloseUI(eUIID_IsBuyWareHouse)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3062))
	end
end

-- 同步角色私人仓库信息
function i3k_sbean.private_warehouse(uiid)
	local data = i3k_sbean.sync_private_warehouse_req.new()
	data.uiid = uiid
	data.warehouseType = g_PERSONAL_WAREHOUSE
	i3k_game_send_str_cmd(data, "sync_private_warehouse_res")
end

function i3k_sbean.sync_private_warehouse_res.handler(bean, req)
	if bean.warehouse then
		if bean.warehouse.cellSize == 0 then
			g_i3k_ui_mgr:OpenUI(eUIID_BuyPrivateWareHouse)
			g_i3k_ui_mgr:RefreshUI(eUIID_BuyPrivateWareHouse)
		else
			g_i3k_game_context:SetWarehouseData(bean.warehouse, req.warehouseType)
			if req.uiid then
				g_i3k_ui_mgr:CloseUI(req.uiid)
			end
			g_i3k_ui_mgr:OpenUI(eUIID_Warehouse)
			local daibis = {}
			g_i3k_ui_mgr:RefreshUI(eUIID_Warehouse, req.warehouseType, daibis)
			g_i3k_logic:OpenImportantNoticeUI(req.warehouseType, daibis)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("私人仓库资料错误，请重试")
	end
end

-- 同步角色结婚仓库信息
function i3k_sbean.public_warehouse(uiid)
	local data = i3k_sbean.sync_public_warehouse_req.new()
	data.uiid = uiid
	data.warehouseType = g_PUBLIC_WAREHOUSE
	i3k_game_send_str_cmd(data, "sync_public_warehouse_res")
end

function i3k_sbean.sync_public_warehouse_res.handler(bean, req)
	if bean.warehouse then
		g_i3k_game_context:SetWarehouseData(bean.warehouse, req.warehouseType)
		if req.uiid then
			g_i3k_ui_mgr:CloseUI(req.uiid)
		end
		g_i3k_ui_mgr:OpenUI(eUIID_Warehouse)
		local daibis = {}
		g_i3k_ui_mgr:RefreshUI(eUIID_Warehouse, req.warehouseType, daibis)
		g_i3k_logic:OpenImportantNoticeUI(req.warehouseType, daibis)
	else
		g_i3k_ui_mgr:PopupTipMessage("结婚仓库资料错误，请重试")
	end
end

function i3k_sbean.expand_warehouse(times, warehouseType, useItem, info)
	local data = i3k_sbean.expand_warehouse_req.new()
	data.warehouseType = warehouseType
	data.times = times
	data.useItem = useItem
	data.info = info
	i3k_game_send_str_cmd(data, "expand_warehouse_res")
end

function i3k_sbean.expand_warehouse_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:ExpandWarehouseSize(i3k_db_common.bag.expandCount, req.times, req.warehouseType)
		if req then
			if req.useItem == 0 then
				g_i3k_game_context:UseDiamond(req.info.costCount, false, AT_EXPAND_BAG_CELLS)
				g_i3k_ui_mgr:CloseUI(eUIID_Bag_extend)
			else
				g_i3k_game_context:UseCommonItem(req.info.itemId, req.info.itemCount, AT_EXPAND_BAG_CELLS)
				g_i3k_ui_mgr:CloseUI(eUIID_Bag_extend)
			end
		end
	end
end

function i3k_sbean.goto_put_in_warehouse(id, count, warehouseType, guid)
	local data = i3k_sbean.put_in_warehouse_req.new()
	data.itemId = id
	data.itemCount = count
	data.warehouseType = warehouseType
	data.guid = guid or 0
	i3k_game_send_str_cmd(data, "put_in_warehouse_res")
end

-- 存入仓库请求
function i3k_sbean.put_in_warehouse_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:SetWarehouseItemsForType(req.itemId, req.itemCount, req.warehouseType, 1, req.guid)
	elseif bean.ok == -5 then
		g_i3k_ui_mgr:PopupTipMessage("公共仓库只能存入非绑定道具")
	elseif bean.ok == -4 then
		g_i3k_ui_mgr:PopupTipMessage("该仓库空间不足")
	elseif bean.ok == -6 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3053))
	end
end

-- 取出物品请求
function i3k_sbean.goto_take_out_warehouse(id, count, warehouseType, guid)
	local data = i3k_sbean.take_out_warehouse_req.new()
	data.itemId = id
	data.itemCount = count
	data.warehouseType = warehouseType
	data.guid = guid or 0
	i3k_game_send_str_cmd(data, "take_out_warehouse_res")
end

function i3k_sbean.take_out_warehouse_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:SetWarehouseItemsForType(req.itemId, req.itemCount, req.warehouseType, 2, req.guid)
	elseif bean.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage("背包空间不足")
	elseif bean.ok == -3 then
		i3k_sbean.public_warehouse()
		g_i3k_ui_mgr:PopupTipMessage("该物品已被对方取走，已重新刷新")
	end
end

function i3k_sbean.goto_take_out_warehouse_piece(items, warehouseType)
	local data = i3k_sbean.take_out_warehouse_piece_req.new()
	data.items = items
	data.warehouseType = warehouseType
	i3k_game_send_str_cmd(data, "take_out_warehouse_piece_res")
end

function i3k_sbean.take_out_warehouse_piece_res.handler(bean, req)
	if bean.ok == 1 then
		for k, v in pairs(req.items) do
		    g_i3k_game_context:SetWarehouseItemsForType(k, v, req.warehouseType, 2, 0)
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ImportantNotice, "takeOutSucceed")
	else
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ImportantNotice, "takeOutFailed")
	end
end

--赠送
function i3k_sbean.send_gift(id, count, roleId, name)
	local data = i3k_sbean.send_gift_req.new()
	data.itemId = id
	data.itemNum = count
	data.roleId = roleId
	data.name = name
	i3k_game_send_str_cmd(data, "send_gift_res")
end

function i3k_sbean.send_gift_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:UseBagItem(req.itemId, req.itemNum,AT_SEND_GIFT)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_GiveItem, "refresh", req.roleId, req.name)
		g_i3k_ui_mgr:PopupTipMessage("赠送成功")
	elseif bean.ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage("该物品无法赠送")
	elseif bean.ok == -3 then
		g_i3k_ui_mgr:PopupTipMessage("对方背包空间已满，无法赠送")
	elseif bean.ok == -4 then
		g_i3k_ui_mgr:PopupTipMessage("对方已下线，赠送失败")
	end
end



--限制使用道具
function i3k_sbean.bag_useitempropstrength(itemId, count)
	local data = i3k_sbean.bag_useitempropstrength_req.new()
	data.itemId = itemId
	data.count = count
	local cfg = g_i3k_db.i3k_db_get_other_item_cfg(itemId)
	local isCan = g_i3k_game_context:getOneTimesItemLvlForId(itemId)
	if not isCan then
		g_i3k_ui_mgr:PopupTipMessage("未达到该物品使用阶数，使用失败")
		return true
	end
	local canUseCount = g_i3k_game_context:getOneTimesItemAllCountDataForId(itemId)
	if canUseCount == 0 or canUseCount == -1 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(2001))
		return
	end
	i3k_game_send_str_cmd(data, "bag_useitempropstrength_res")
end

function i3k_sbean.bag_useitempropstrength_res.handler(bean, req)
	if bean.ok == 1 then
		local txtFormat = function(propId, value)
			if propId == 0 then return '' end
			return i3k_db_prop_id[propId].txtFormat == 1 and string.format(value - math.floor(value) > 0 and "%.2f" or "%d", value)..'%' or value
		end
		local cfg = g_i3k_db.i3k_db_get_other_item_cfg(req.itemId)
		local hero = i3k_game_get_player_hero()
		local value = hero:GetPropertyValue(cfg.args1)
		local value2 = cfg.args3 == 0 and 0 or hero:GetPropertyValue(cfg.args3)
		g_i3k_game_context:SetPrePower()
		g_i3k_game_context:UseBagItem(req.itemId, req.count,AT_USE_ITEM_PROP_STRENGTH)
		local tab = {}
		tab[req.itemId] = req.count
		g_i3k_game_context:setOneTimesItemAllCountData(tab)
		g_i3k_game_context:setOneTimesItemData(cfg.args1, cfg.args2 * req.count)
		if cfg.args3 ~= 0 then
			g_i3k_game_context:setOneTimesItemData(cfg.args3, cfg.args4 * req.count)
		end
		g_i3k_game_context:ShowPowerChange()
		local name = string.format("%s:",g_i3k_db.i3k_db_get_property_name(cfg.args1))
		local newValue = hero:GetPropertyValue(cfg.args1)
		local txt1 = i3k_get_string(766, name, txtFormat(cfg.args1,value), txtFormat(cfg.args1,newValue))
		if cfg.args3 == 0 then
			g_i3k_ui_mgr:PopupTipMessage(txt1)
		else
			local name2 = cfg.args3 == 0 and '' or string.format("%s:",g_i3k_db.i3k_db_get_property_name(cfg.args3))
			local newValue2 = cfg.args3 == 0 and 0 or hero:GetPropertyValue(cfg.args3)
			g_i3k_ui_mgr:PopupTipMessage(txt1..' '..i3k_get_string(766, name2, txtFormat(cfg.args3,value2), txtFormat(cfg.args3,newValue2)))			
		end
	elseif bean.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(2001))
	end
end

-- 购买挂机精灵点
function i3k_sbean.buy_offline_func_point(times, needDiamond)
	local data = i3k_sbean.buy_offline_func_point_req.new()
	data.seq = times
	data.needDiamond = needDiamond
	i3k_game_send_str_cmd(data, "buy_offline_func_point_res")
end

function i3k_sbean.buy_offline_func_point_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:SetBuyOfflineWizardPintData(req.seq, req.needDiamond)
	end
end

--使用精灵点道具
function i3k_sbean.bag_useitemofflinefuncpoint(id, count)
	local data = i3k_sbean.bag_useitemofflinefuncpoint_req.new()
	data.itemId = id
	data.count = count
	i3k_game_send_str_cmd(data, "bag_useitemofflinefuncpoint_res")
end

function i3k_sbean.bag_useitemofflinefuncpoint_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:SetUseItemData(req.itemId, req.count)
	end
end

--使用称号剩余时间重置道具
function i3k_sbean.bag_useitemtitle(id)
	local data = i3k_sbean.bag_useitemtitle_req.new()
	data.itemId = id
	i3k_game_send_str_cmd(data, "bag_useitemtitle_res")
end

function i3k_sbean.bag_useitemtitle_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:UseCommonItem(req.itemId, 1)
		local item_cfg = g_i3k_db.i3k_db_get_other_item_cfg(req.itemId)
		g_i3k_logic:openRoleTitleUI(item_cfg.args1)
	end
end

-- 使用绝技道具
function i3k_sbean.bag_useitemuskill(itemId, skillId, sortId)
	local data = i3k_sbean.bag_useitemuskill_req.new()
	data.itemId = itemId
	data.skillId = skillId
	data.sortId = sortId
	i3k_game_send_str_cmd(data, "bag_useitemuskill_res")
end

function i3k_sbean.bag_useitemuskill_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:UseCommonItem(req.itemId, 1)
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(515))
		g_i3k_game_context:SetCurRoleUniqueSkills(req.skillId, 1, 0, req.sortId)--设置绝技
		g_i3k_ui_mgr:CloseUI(eUIID_UniqueskillPreview)
	else
		g_i3k_ui_mgr:PopupTipMessage("服务器返回绝技道具使用失败")
	end
end

-- 使用道具激活头像
function i3k_sbean.unlock_head(headId)
	local data = i3k_sbean.unlock_head_req.new()
	data.headId = headId
	i3k_game_send_str_cmd(data, "unlock_head_res")
end

function i3k_sbean.unlock_head_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_ui_mgr:CloseUI(eUIID_UnlockHead)
		g_i3k_game_context:UseCommonItem(i3k_db_personal_icon[req.headId].needItemId, i3k_db_personal_icon[req.headId].needItemCount)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Friends, "updateActiveHeadIcon", req.headId)
	else
		g_i3k_ui_mgr:PopupTipMessage("启动头像失败")
	end
end

-- 同步当前已解锁头像
function i3k_sbean.item_unlock_head()
	local data = i3k_sbean.sync_item_unlock_head_req.new()
	i3k_game_send_str_cmd(data, "sync_item_unlock_head_res")
end

function i3k_sbean.sync_item_unlock_head_res.handler(bean, req)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Friends, "updateMyselfData", bean.unlockHeads)
end
----------------------------------------------------------------
--使用增加vip经验道具
function i3k_sbean.bag_useitemvipexp(id,count)
	local data = i3k_sbean.bag_useitemaddvipexp_req.new()
	data.itemId = id
	data.count = count
	i3k_game_send_str_cmd(data, "bag_useitemaddvipexp_res")
end

function i3k_sbean.bag_useitemaddvipexp_res.handler(bean,req)
	if bean.ok > 0 then
		g_i3k_game_context:SetUseItemData(req.itemId, req.count,nil,AT_USE_ADD_VIPEXP_ITEM)
		local cfg = g_i3k_db.i3k_db_get_other_item_cfg(req.itemId)
		if cfg then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15466,req.count*cfg.args2))
		end
	elseif bean.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(2001))
	else
		g_i3k_ui_mgr:PopupTipMessage("使用失败")
	end
end

----------------------------------------------------------------
--使用增加生产能量道具
function i3k_sbean.bag_useitemaddproducesplitsp(id,count)
	local data = i3k_sbean.bag_useitemaddproducesplitsp_req.new()
	data.itemId = id
	data.count = count
	i3k_game_send_str_cmd(data, "bag_useitemaddproducesplitsp_res")
end

function i3k_sbean.bag_useitemaddproducesplitsp_res.handler(bean,req)
	if bean.ok > 0 then
		g_i3k_game_context:SetUseItemData(req.itemId, req.count,nil,AT_USE_ADD_PRODUCE_SPLITSP_ITEM)
		local cfg = g_i3k_db.i3k_db_get_other_item_cfg(req.itemId)
		if cfg then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15467,req.count*cfg.args1))
		end
	elseif bean.ok == -2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(2001))
	else
		g_i3k_ui_mgr:PopupTipMessage("使用失败")
	end
end

--漂流瓶交换
function i3k_sbean.bottle_exchange(item, msg)
	local data = i3k_sbean.bottle_exchange_req.new()
	data.item = item
	data.cnt = 1
	data.msg = msg
	i3k_game_send_str_cmd(data, "bottle_exchange_res")
end

function i3k_sbean.bottle_exchange_res.handler(bean, req)
	if bean.ok > 0 then
		local callback = function ()
			g_i3k_ui_mgr:CloseUI(eUIID_DriftBottleGift)
			if next(bean.extraReward) then
				g_i3k_ui_mgr:OpenUI(eUIID_DriftBottleExtra)
				g_i3k_ui_mgr:RefreshUI(eUIID_DriftBottleExtra, bean.extraReward)
			end
		end
		g_i3k_game_context:UseCommonItem(req.item, req.cnt, AT_DRIFT_BOTTLE)
		g_i3k_ui_mgr:CloseUI(eUIID_DriftBottle)
		g_i3k_ui_mgr:OpenUI(eUIID_DriftBottleGift)
		g_i3k_ui_mgr:RefreshUI(eUIID_DriftBottleGift, bean, callback)
	elseif bean.ok == -9 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5030))
	else
		g_i3k_ui_mgr:PopupTipMessage("兑换失败")
	end
end

--同步漂流瓶交换次数
function i3k_sbean.bottle_exchange_sync(callback)
	local data = i3k_sbean.bottle_exchange_sync_req.new()
	data.callback = callback
	i3k_game_send_str_cmd(data, "bottle_exchange_sync_res")
end

function i3k_sbean.bottle_exchange_sync_res.handler(bean, req)
	if bean.ok > 0 then
		if bean.times then
			g_i3k_game_context:setDriftBottleTimes(bean.times)
		end
		if req.callback then
			req.callback()
		end
	end
end

----------------------------------------------------------------
--使用buff药道具
function i3k_sbean.bag_useitembuffdrug(id, count)
	local data = i3k_sbean.bag_useitembuffdrug_req.new()
	data.itemID = id
	data.count = count
	i3k_game_send_str_cmd(data, "bag_useitembuffdrug_res")
end

function i3k_sbean.bag_useitembuffdrug_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:SetUseItemData(req.itemID, req.count, nil, AT_USE_ITEM_BUFF_DRUG)
		local cfg = g_i3k_db.i3k_db_get_other_item_cfg(req.itemID)
		if cfg then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16143))
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("使用失败")
	end
end

--使用表情包道具
function i3k_sbean.bag_useitemiconpackage(itemID, count, callback)
	local data = i3k_sbean.bag_useitemiconpackage_req.new()
	data.itemID = itemID
	data.count = count
	data.callback = callback
	i3k_game_send_str_cmd(data, "bag_useitemiconpackage_res")
end

function i3k_sbean.bag_useitemiconpackage_res.handler(bean, req)
	if bean.ok > 0 then
		local item_cfg = g_i3k_db.i3k_db_get_other_item_cfg(req.itemID)
		g_i3k_game_context:UseCommonItem(req.itemID, req.count, AT_UNLOCK_EMOJI)
		g_i3k_game_context:addEmojiData(item_cfg.args1, req.count * item_cfg.args2)
		if req.callback then
			req.callback()
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("使用失败")
	end
end

-- 使用武运道具
function i3k_sbean.bag_useweaponsoulcoinadder(itemID, count)
	local data = i3k_sbean.bag_useweaponsoulcoinadder_req.new()
	data.itemID = itemID
	data.count = count
	i3k_game_send_str_cmd(data, "bag_useweaponsoulcoinadder_res")
end

function i3k_sbean.bag_useweaponsoulcoinadder_res.handler(bean, req)
	if bean.ok == 1 then
		g_i3k_game_context:SetUseItemData(req.itemID, req.count, nil, AT_USE_ITEM_WEAPON_COIN_ADDER)
	else
		g_i3k_ui_mgr:PopupTipMessage("使用失败")
	end
end

--神木鼎同步
function i3k_sbean.woodenTripodOpen()
	local data = i3k_sbean.tripod_times_sync_req.new()
	i3k_game_send_str_cmd(data, "tripod_times_sync_res")
end

function i3k_sbean.tripod_times_sync_res.handler(res, req)
	g_i3k_ui_mgr:OpenUI(eUIID_WoodenTripod)
	g_i3k_ui_mgr:RefreshUI(eUIID_WoodenTripod, res.dayUsedTimes, res.dayBuyTimes)
end

--神木鼎炼化
function i3k_sbean.woodenTripodRefine(itemId, count)
	local data = i3k_sbean.tripod_merge_req.new()
	data.itemId = itemId
	data.count = count
	i3k_game_send_str_cmd(data, "tripod_merge_res")
end

function i3k_sbean.tripod_merge_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:UseCommonItem(req.itemId, req.count, AT_TRIPOD_MERGE)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_WoodenTripod, "updateLeftTimes", 1)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_WoodenTripod, "refreshUI")
		if res.ok == 1 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3208))
		elseif res.ok == 2 then
		    g_i3k_ui_mgr:ShowGainItemInfo({{id = i3k_db_woodenTripod[req.itemId].getId, count = 1}})
		end
	else
	    g_i3k_ui_mgr:PopupTipMessage("炼化出错")
	end
end

--神木鼎次数购买
function i3k_sbean.woodenTripodBuyTimes(count, cost)
	local data = i3k_sbean.tripod_buy_times_req.new()
	data.count = count
	data.cost = cost
	i3k_game_send_str_cmd(data, "tripod_buy_times_res")
end

function i3k_sbean.tripod_buy_times_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:UseCommonItem(g_BASE_ITEM_DIAMOND, req.cost, AT_TRIPOD_BUY_TIMES)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_WoodenTripod, "updateLeftTimes", -req.count)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_WoodenTripod, "updateLeftBuyTimes", req.count)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_WoodenTripodBuyTimes, "onCloseUI")
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_WoodenTripod, "refreshUI")
	else
	    g_i3k_ui_mgr:PopupTipMessage("购买出错")
	end
end

--装备转化
function i3k_sbean.equip_trans(equipID, guid, items, groupID)
	local data = i3k_sbean.equip_trans_req.new()
	data.equipID = equipID
	data.guid = guid
	data.items = items
	data.groupID = groupID
	i3k_game_send_str_cmd(data, "equip_trans_res")
end

function i3k_sbean.equip_trans_res.handler(bean, req)
	if bean.ok > 0 and req.groupID ~= i3k_db_feisheng_misc.jingduanTransGroup then
		for k, v in ipairs(req.items) do
			g_i3k_game_context:UseCommonItem(v.id, v.count, AT_EQUIP_TRANSFER)
		end
		g_i3k_game_context:DelBagEquip(req.equipID, req.guid, AT_EQUIP_TRANSFER)
		g_i3k_ui_mgr:CloseUI(eUIID_EquipTransformCompare)
		g_i3k_ui_mgr:OpenUI(eUIID_EquipTransformEnd)
		g_i3k_ui_mgr:RefreshUI(eUIID_EquipTransformEnd, req.equipID, bean.guid, req.groupID)
		--g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1248, i3k_db_equips[newEquipId].name))
	elseif bean.ok > 0 and req.groupID == i3k_db_feisheng_misc.jingduanTransGroup then
		for k, v in ipairs(req.items) do
			g_i3k_game_context:UseCommonItem(v.id, v.count, AT_EQUIP_TRANSFER)
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FlyingEquipTrans, "transCallBack")
	else
		g_i3k_ui_mgr:PopupTipMessage("转化失败")
	end
end

--使用N选n礼包
function i3k_sbean.bag_useitemchosegift(id, count, choseIds, choseItems)
	local data = i3k_sbean.bag_useitemchosegift_req.new()
	data.id = id
	data.count = count
	data.choseIds = choseIds
	data.choseItems = choseItems
	i3k_game_send_str_cmd(data, "bag_useitemchosegift_res")
end

function i3k_sbean.bag_useitemchosegift_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:SetUseItemData(req.id, req.count, req.choseItems, AT_USE_ITEM_GIFT_BOX)
		g_i3k_ui_mgr:CloseUI(eUIID_GiftBagSelect)
	else
		g_i3k_ui_mgr:PopupTipMessage("使用失败")
	end
end

--购买挂机精灵经验
function i3k_sbean.buyOffineWizardExp(buyCnt)
	local data = i3k_sbean.buy_offline_wizard_exp_req.new()
	data.buyCnt = buyCnt
	i3k_game_send_str_cmd(data, "buy_offline_wizard_exp_res")
end

function i3k_sbean.buy_offline_wizard_exp_res.handler(res, req)
	if res.ok > 0 then
		local cfg = i3k_db_offline_exp.buyExp
		g_i3k_game_context:UseCommonItem(cfg.consumeId, cfg.consumeCount * req.buyCnt,AT_BUY_OFFLINE_WIZARD_EXP)
		g_i3k_game_context:refreshOfflineWizardData(res.lvl, res.exp)
		g_i3k_ui_mgr:CloseUI(eUIID_BuyOffineWizardExp)
		--g_i3k_ui_mgr:CloseUI(eUIID_OfflineExpReceive)
		--g_i3k_ui_mgr:OpenUI(eUIID_OfflineExpReceive)
		--g_i3k_ui_mgr:RefreshUI(eUIID_OfflineExpReceive, false)
		g_i3k_ui_mgr:RefreshUI(eUIID_OfflineExpReceive, true)
		g_i3k_ui_mgr:PopupTipMessage("成功购买挂机精灵经验" .. cfg.gainExp * req.buyCnt.."点")
	end
end

function i3k_sbean.role_add_adventure.handler(res)
	g_i3k_game_context:addQiyun(res.adventure)
end

--使用神装礼包
function i3k_sbean.bag_useitemgiftnew(id, count)
	local data = i3k_sbean.bag_useitemgiftnew_req.new()
	data.id = id
	data.count = count
	i3k_game_send_str_cmd(data, "bag_useitemgiftnew_res")
end

function i3k_sbean.bag_useitemgiftnew_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:SetUseItemData(req.id, req.count,nil,AT_USE_ITEM_GIFT_BOX)
	else
		g_i3k_ui_mgr:PopupTipMessage("打开失败")
	end
end

function i3k_sbean.bag_useitemchosegiftnew(id, count, choseIds, choseItems)
	local data = i3k_sbean.bag_useitemchosegiftnew_req.new()
	data.id = id
	data.count = count
	data.choseIds = choseIds
	data.choseItems = choseItems
	i3k_game_send_str_cmd(data, "bag_useitemchosegiftnew_res")
end

function i3k_sbean.bag_useitemchosegiftnew_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:SetUseItemData(req.id, req.count, req.choseItems, AT_USE_ITEM_GIFT_BOX)
		g_i3k_ui_mgr:CloseUI(eUIID_GiftBagSelect)
	else
		g_i3k_ui_mgr:PopupTipMessage("领取失败")
	end
end

function i3k_sbean.bag_batchuseitemvit(itemTable)
	local data = i3k_sbean.bag_batchuseitemvit_req.new()
	data.items = itemTable
	i3k_game_send_str_cmd(data, "bag_batchuseitemvit_res")
end

function i3k_sbean.bag_batchuseitemvit_res.handler(res, req)
	if res.ok > 0 then
		--刷新
		for id, count in pairs(req.items) do 
			g_i3k_game_context:SetUseItemData(id, count, nil, AT_BATCH_USE_ITEM_AS_VIT)
		end
		g_i3k_ui_mgr:RefreshUI(eUIID_UseVit, true)
	else
		g_i3k_ui_mgr:PopupTipMessage("批量使用失败")
	end
end

-- 使用家园装备的道具
function i3k_sbean.bag_useitemhomelandequip(itemId, count)
	local data = i3k_sbean.bag_useitemhomelandequip_req.new()
	data.itemId = itemId
	data.count = count
	i3k_game_send_str_cmd(data, "bag_useitemhomelandequip_res")
end

function i3k_sbean.bag_useitemhomelandequip_res.handler(bean, req)
	if bean.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("道具使用成功")
		g_i3k_game_context:UseCommonItem(req.itemId, req.count, AT_USE_ITEM_HOMELAND_EQUIP) --TODO add reason
	end
end

-- 同步角色家园仓库信息
function i3k_sbean.sync_homeland_warehouse()
	local data = i3k_sbean.sync_homeland_warehouse_req.new()
	data.warehouseType = g_HOMELAND_WAREHOUSE
	i3k_game_send_str_cmd(data, "sync_homeland_warehouse_res")
end

function i3k_sbean.sync_homeland_warehouse_res.handler(bean, req)
	if bean.warehouse then
		g_i3k_game_context:SetWarehouseData(bean.warehouse, req.warehouseType)
		g_i3k_ui_mgr:OpenUI(eUIID_Warehouse)
		local daibis = {}
		g_i3k_ui_mgr:RefreshUI(eUIID_Warehouse, req.warehouseType, daibis)
		g_i3k_logic:OpenImportantNoticeUI(req.warehouseType, daibis)
	else
		g_i3k_ui_mgr:PopupTipMessage("家园仓库数据错误，请重试")
	end
end

--使用正义徽章道具
function i3k_sbean.bag_useitemgbcoin(id, count)
	local data = i3k_sbean.bag_useitemgbcoin_req.new()
	data.id = id
	data.count = count
	i3k_game_send_str_cmd(data, "bag_useitemgbcoin_res")
end

function i3k_sbean.bag_useitemgbcoin_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:SetUseItemData(req.id, req.count, nil, AT_USE_ITEM_GBCOIN_BAG)
	else
		g_i3k_ui_mgr:PopupTipMessage("使用道具错误")
	end
end

--使用骑战装备 熔炼精华道具
function i3k_sbean.bag_useItemSteedStove(id, count)
	local data = i3k_sbean.bag_useitemforgeenergy_req.new()
	data.id = id
	data.count = count
	i3k_game_send_str_cmd(data, "bag_useitemforgeenergy_res")
end
function i3k_sbean.bag_useitemforgeenergy_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:SetUseItemData(req.id, req.count, nil, AT_USE_ITEM_FORGE_ENERGY)
		local cfg = g_i3k_db.i3k_db_get_other_item_cfg(req.id)
		g_i3k_ui_mgr:ShowGainItemInfo({{id = g_BASE_ITEM_STEED_EQUIP_SPIRIT, count = cfg.args1 * req.count}})
	else
		g_i3k_ui_mgr:PopupTipMessage("使用道具错误")
	end
end
function i3k_sbean.bag_useItemForceFame(id, count)
	local data = i3k_sbean.bag_useitem_forcefame_req.new()
	data.itemID = id
	data.count = count
	i3k_game_send_str_cmd(data, "bag_useitem_forcefame_res")
end
function i3k_sbean.bag_useitem_forcefame_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:SetUseItemData(req.itemID, req.count, nil, nil)
		local cfg = g_i3k_db.i3k_db_get_other_item_cfg(req.itemID)
		g_i3k_game_context:addPowerRep(cfg.args1, req.count * cfg.args2)
	else
		g_i3k_ui_mgr:PopupTipMessage("使用道具错误")
	end
end
--放生家园道具
function i3k_sbean.release_homeland_items(item, totalCount)
	local data = i3k_sbean.conduct_release_item_req.new()
	data.item = item
	data.totalCount = totalCount
	i3k_game_send_str_cmd(data, "conduct_release_item_res")
end

function i3k_sbean.conduct_release_item_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_ui_mgr:PopupTipMessage("放生成功")
		g_i3k_game_context:sethomelandReleaseValue(req.totalCount)
		local items = req.item
		
		for k, v in pairs(items) do
			g_i3k_game_context:UseBagMiscellaneous(k, v)
		end		
		
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_HomeLandRelease, "refreshSaleScoll")
	else
		g_i3k_ui_mgr:PopupTipMessage("放生失败")
	end
end

--使用道具解锁房屋皮肤
function i3k_sbean.bag_use_house_skin_item(itemId)
	local data = i3k_sbean.bag_use_house_skin_item_req.new()
	data.itemId = itemId
	i3k_game_send_str_cmd(data, "bag_use_house_skin_item_res")
end

function i3k_sbean.bag_use_house_skin_item_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:SetUseItemData(req.itemId, 1, nil, AT_HOUSE_SKIN_UNLOCK)
		g_i3k_game_context:unlockHouseSkin(i3k_db_new_item[req.itemId].args1)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_HouseSkin, "setSkinScroll")
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17730))
	elseif res.ok == -1 then
		g_i3k_ui_mgr:PopupTipMessage("已解锁该房屋皮肤，使用失败")
	else
		g_i3k_ui_mgr:PopupTipMessage("使用失败")
	end
end

--使用道具增加结拜金兰值
function i3k_sbean.use_sworn_gift_item(id, count, tarId)
	local data = i3k_sbean.use_sworn_gift_item_req.new()
	data.id = id
	data.count = count
	data.tarId = tarId
	i3k_game_send_str_cmd(data, "use_sworn_gift_item_res")
end

function i3k_sbean.use_sworn_gift_item_res.handler(res, req)
	if res.ok > 0 then
		g_i3k_game_context:SetUseItemData(req.id, req.count, nil, AT_USE_SWORN_GIFT_ITEM)
		g_i3k_ui_mgr:PopupTipMessage("使用成功")
		g_i3k_game_context:syncData()
	elseif res.ok == -16 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5446))
	else
		g_i3k_ui_mgr:PopupTipMessage("使用失败")
	end
end
function i3k_sbean.use_flying_item(items)
	local data = i3k_sbean.soaring_use_exp_item_req.new()
	data.items = items
	i3k_game_send_str_cmd(data, "soaring_use_exp_item_res")
end
function i3k_sbean.soaring_use_exp_item_res.handler(res, req)
	if res.ok > 0 then
		for k, v in pairs(req.items) do
			g_i3k_game_context:SetUseItemData(k, v, nil, AT_USE_SOARING_EXP_ITEMS)
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FeiSheng, "updateFlyingExp", req.items)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FlyingExpItem, "updateExpItemNum", req.items)
	end
end
