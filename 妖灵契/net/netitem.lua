module(..., package.seeall)

--GS2C--

function GS2CLoginItem(pbdata)
	local itemdata = pbdata.itemdata --背包道具信息
	local buffitem = pbdata.buffitem --正在使用buff道具
	--todo
	g_ItemCtrl:LoginItem(extsize, itemdata, buffitem)
end

function GS2CAddItem(pbdata)
	local itemdata = pbdata.itemdata
	--todo
	g_ItemCtrl:AddItem(itemdata)
end

function GS2CDelItem(pbdata)
	local id = pbdata.id --服务的道具id
	--todo
	g_ItemCtrl:DelItem(id)
end

function GS2CItemAmount(pbdata)
	local id = pbdata.id
	local amount = pbdata.amount
	local create_time = pbdata.create_time
	--todo
	g_ItemCtrl:SetItemAmount(id, amount, create_time)
end

function GS2CItemQuickUse(pbdata)
	local id = pbdata.id
	--todo
	g_ItemCtrl:QuickUseItem(id)
end

function GS2CItemExtendSize(pbdata)
	local extsize = pbdata.extsize --扩展格子数目
	--todo
end

function GS2CEquipLast(pbdata)
	local itemid = pbdata.itemid --装备ID
	local last = pbdata.last --耐久度
	--todo
end

function GS2CFuWenInfo(pbdata)
	local itemid = pbdata.itemid
	local cur_plan = pbdata.cur_plan --当前使用方案
	local fuwen = pbdata.fuwen --符文
	--todo
	g_ItemCtrl:UpdateResetFuwenCache(itemid, cur_plan, fuwen)
end

function GS2CItemPrice(pbdata)
	local item_info = pbdata.item_info
	--todo
	g_ItemCtrl:UpdateMaterailPriceCache(item_info)
end

function GS2CRefreshPartnerEquipInfo(pbdata)
	local itemid = pbdata.itemid
	local partner_equip_info = pbdata.partner_equip_info --伙伴装备信息
	--todo
	g_ItemCtrl:UpdatePartnerEquip(itemid, partner_equip_info)
end

function GS2CRefreshPartnerEquip(pbdata)
	local itemid = pbdata.itemid
	local partner_equip = pbdata.partner_equip --伙伴装备信息
	--todo
	g_ItemCtrl:UpdatePartnerEquip(itemid, partner_equip)
end

function GS2CComposePartnerEquip(pbdata)
	local itemid = pbdata.itemid --合成后id
	--todo
	g_ItemCtrl:ComposePartnerEquip(itemid)
end

function GS2CClientShowReward(pbdata)
	local type = pbdata.type --类型，1物品，2货币
	local sid = pbdata.sid
	local value = pbdata.value
	local bind = pbdata.bind
	--todo
	g_ItemCtrl:ClientShowReward(type, sid, value, bind)
end

function GS2CFuWenPlanName(pbdata)
	local fuwen_name = pbdata.fuwen_name
	--todo
	g_ItemCtrl:CtrlGS2CFuWenPlanName(fuwen_name)
end

function GS2CCompoundSuccess(pbdata)
	--todo
	g_ItemCtrl:CtrlGS2CCompoundSuccess()
end

function GS2CDeComposeSuccess(pbdata)
	--todo
	g_ItemCtrl:CtrlGS2CDeComposeSuccess()
end

function GS2CExchangeEquip(pbdata)
	local itemid = pbdata.itemid --道具id,弹窗用到，不存在不用弹
	--todo
	g_ItemCtrl:CtrlGS2CExchangeSuccess(itemid)
end

function GS2CRemoveBuffItem(pbdata)
	local itemid = pbdata.itemid --绑定的buff道具id
	--todo
	g_PlayerBuffCtrl:RemoveBuffItem(itemid)
end

function GS2CUpdateBuffItem(pbdata)
	local itemdata = pbdata.itemdata --道具信息
	--todo
	g_PlayerBuffCtrl:GS2CUpdateBuffItem(itemdata)
end

function GS2CAddBuffItem(pbdata)
	local itemdata = pbdata.itemdata --道具信息
	--todo
	g_PlayerBuffCtrl:AddBuffItem(itemdata)
end

function GS2CRefreshItemApply(pbdata)
	local itemid = pbdata.itemid --道具id
	local apply_info = pbdata.apply_info
	--todo
end

function GS2CRefreshPartnerSoul(pbdata)
	local itemid = pbdata.itemid
	local partner_soul = pbdata.partner_soul
	--todo
	g_ItemCtrl:UpdatePartnerSoul(itemid, partner_soul)
end

function GS2CLockItem(pbdata)
	local itemid = pbdata.itemid
	local lock = pbdata.lock --1-上锁，0-解锁
	--todo
	g_ItemCtrl:UpdateLock(itemid, lock)
end

function GS2CGemCompose(pbdata)
	local gem_sid = pbdata.gem_sid --合成宝石的sid
	local amount = pbdata.amount --合成数量
	--todo
	g_ItemCtrl:CtrlGS2CGemCompose(gem_sid, amount)
end


--C2GS--

function C2GSItemUse(itemid, target, amount)
	local t = {
		itemid = itemid,
		target = target,
		amount = amount,
	}
	g_NetCtrl:Send("item", "C2GSItemUse", t)
end

function C2GSItemInfo(itemid)
	local t = {
		itemid = itemid,
	}
	g_NetCtrl:Send("item", "C2GSItemInfo", t)
end

function C2GSAddItemExtendSize(size)
	local t = {
		size = size,
	}
	g_NetCtrl:Send("item", "C2GSAddItemExtendSize", t)
end

function C2GSDeComposeItem(id, amount)
	local t = {
		id = id,
		amount = amount,
	}
	g_NetCtrl:Send("item", "C2GSDeComposeItem", t)
end

function C2GSComposeItem(sid, amount, coin_type)
	local t = {
		sid = sid,
		amount = amount,
		coin_type = coin_type,
	}
	g_NetCtrl:Send("item", "C2GSComposeItem", t)
end

function C2GSRecycleItem(itemid, amount)
	local t = {
		itemid = itemid,
		amount = amount,
	}
	g_NetCtrl:Send("item", "C2GSRecycleItem", t)
end

function C2GSRecycleItemList(sale_list)
	local t = {
		sale_list = sale_list,
	}
	g_NetCtrl:Send("item", "C2GSRecycleItemList", t)
end

function C2GSArrangeItem()
	local t = {
	}
	g_NetCtrl:Send("item", "C2GSArrangeItem", t)
end

function C2GSFixEquip(pos)
	local t = {
		pos = pos,
	}
	g_NetCtrl:Send("item", "C2GSFixEquip", t)
end

function C2GSPromoteEquipLevel(pos, itemid)
	local t = {
		pos = pos,
		itemid = itemid,
	}
	g_NetCtrl:Send("item", "C2GSPromoteEquipLevel", t)
end

function C2GSItemPrice(sid_list)
	local t = {
		sid_list = sid_list,
	}
	g_NetCtrl:Send("item", "C2GSItemPrice", t)
end

function C2GSResetFuWen(pos, price)
	local t = {
		pos = pos,
		price = price,
	}
	g_NetCtrl:Send("item", "C2GSResetFuWen", t)
end

function C2GSSaveFuWen(pos)
	local t = {
		pos = pos,
	}
	g_NetCtrl:Send("item", "C2GSSaveFuWen", t)
end

function C2GSEquipStrength(pos, strength_info)
	local t = {
		pos = pos,
		strength_info = strength_info,
	}
	g_NetCtrl:Send("item", "C2GSEquipStrength", t)
end

function C2GSInlayGem(pos, gem_pos, itemid)
	local t = {
		pos = pos,
		gem_pos = gem_pos,
		itemid = itemid,
	}
	g_NetCtrl:Send("item", "C2GSInlayGem", t)
end

function C2GSInlayAllGem()
	local t = {
	}
	g_NetCtrl:Send("item", "C2GSInlayAllGem", t)
end

function C2GSComposeGem(sid, amount)
	local t = {
		sid = sid,
		amount = amount,
	}
	g_NetCtrl:Send("item", "C2GSComposeGem", t)
end

function C2GSAddGemExp(pos, gem_pos, gem_list)
	local t = {
		pos = pos,
		gem_pos = gem_pos,
		gem_list = gem_list,
	}
	g_NetCtrl:Send("item", "C2GSAddGemExp", t)
end

function C2GSFastAddGemExp()
	local t = {
	}
	g_NetCtrl:Send("item", "C2GSFastAddGemExp", t)
end

function C2GSFastStrength()
	local t = {
	}
	g_NetCtrl:Send("item", "C2GSFastStrength", t)
end

function C2GSUseFuWenPlan(pos)
	local t = {
		pos = pos,
	}
	g_NetCtrl:Send("item", "C2GSUseFuWenPlan", t)
end

function C2GSReNameFuWen(fuwen_name)
	local t = {
		fuwen_name = fuwen_name,
	}
	g_NetCtrl:Send("item", "C2GSReNameFuWen", t)
end

function C2GSCompoundItem(sid, upgrade)
	local t = {
		sid = sid,
		upgrade = upgrade,
	}
	g_NetCtrl:Send("item", "C2GSCompoundItem", t)
end

function C2GSComposeEquip(pos, level)
	local t = {
		pos = pos,
		level = level,
	}
	g_NetCtrl:Send("item", "C2GSComposeEquip", t)
end

function C2GSUpgradeEquip(pos, level, cost_id)
	local t = {
		pos = pos,
		level = level,
		cost_id = cost_id,
	}
	g_NetCtrl:Send("item", "C2GSUpgradeEquip", t)
end

function C2GSDeCompose(info)
	local t = {
		info = info,
	}
	g_NetCtrl:Send("item", "C2GSDeCompose", t)
end

function C2GSExChangeEquip(equipid)
	local t = {
		equipid = equipid,
	}
	g_NetCtrl:Send("item", "C2GSExChangeEquip", t)
end

function C2GSLockEquip(itemid, pos)
	local t = {
		itemid = itemid,
		pos = pos,
	}
	g_NetCtrl:Send("item", "C2GSLockEquip", t)
end

function C2GSChooseItem(itemid, itemsids, amount)
	local t = {
		itemid = itemid,
		itemsids = itemsids,
		amount = amount,
	}
	g_NetCtrl:Send("item", "C2GSChooseItem", t)
end

function C2GSBuffStoneOp(itemid, op)
	local t = {
		itemid = itemid,
		op = op,
	}
	g_NetCtrl:Send("item", "C2GSBuffStoneOp", t)
end

