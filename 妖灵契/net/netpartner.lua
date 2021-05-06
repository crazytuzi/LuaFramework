module(..., package.seeall)

--GS2C--

function GS2CPartnerPropChange(pbdata)
	local partnerid = pbdata.partnerid
	local partner_info = pbdata.partner_info
	--todo
	partner_info = g_NetCtrl:DecodeMaskData(partner_info, "partner")
	g_PartnerCtrl:UpdatePartner(partnerid, partner_info)
end

function GS2CAddPartner(pbdata)
	local partner_info = pbdata.partner_info
	--todo
	partner_info = g_NetCtrl:DecodeMaskData(partner_info, "partner")
	g_PartnerCtrl:AddPartner(partner_info)
end

function GS2CDelPartner(pbdata)
	local del_list = pbdata.del_list
	--todo
	g_PartnerCtrl:DelPartner(del_list)
end

function GS2CLoginPartner(pbdata)
	local fight_info = pbdata.fight_info
	local partner_chip_list = pbdata.partner_chip_list
	local awake_item_list = pbdata.awake_item_list --觉醒道具
	local owned_partner_list = pbdata.owned_partner_list --拥有过伙伴id列表
	local owned_equip_list = pbdata.owned_equip_list --拥有过伙伴符文id列表
	--todo
	g_PartnerCtrl:LoginInit(fight_info, partner_chip_list)
	g_PartnerCtrl:InitAwakeItems(awake_item_list)
	g_PartnerCtrl:InitPartnerGuide(owned_partner_list, owned_equip_list)
end

function GS2CLoginPartnerList(pbdata)
	local partner_list = pbdata.partner_list --伙伴列表
	--todo
	g_PartnerCtrl:LoginPartnerList(partner_list)
end

function GS2CRefreshFightPartner(pbdata)
	local fight_info = pbdata.fight_info
	--todo
	g_PartnerCtrl:SetFightInfo(fight_info)
end

function GS2CDrawCardUI(pbdata)
	local par_type = pbdata.par_type --获得伙伴sid
	local desc = pbdata.desc --描述
	local redraw_cost = pbdata.redraw_cost --0-新伙伴, 其他-重新招募钻石
	--todo
	local oPartner = g_PartnerCtrl:GetPartnerByType(par_type)
	if oPartner then
		g_ChoukaCtrl:SetResult(2, {oPartner.m_ID}, desc, redraw_cost)
	end
end

function GS2CDrawCardResult(pbdata)
	local type = pbdata.type --1.武灵,2:武魂
	local partner_list = pbdata.partner_list --伙伴id列表
	--todo
	g_ChoukaCtrl:SetResult(type, partner_list)
	--g_ChoukaCtrl:SetResult(2, {1})
end

function GS2CRefreshPartnerChip(pbdata)
	local partner_chip = pbdata.partner_chip
	--todo
	g_PartnerCtrl:RefreshPartnerChip(partner_chip)
end

function GS2CRefreshAwakeItem(pbdata)
	local awake_item = pbdata.awake_item
	--todo
	g_PartnerCtrl:RefreshAwakeItem(awake_item)
end

function GS2CPartnerCommentInfo(pbdata)
	local partner_type = pbdata.partner_type --伙伴导表id
	local list = pbdata.list --普通评论
	local hot_list = pbdata.hot_list --热评
	local is_comment = pbdata.is_comment --0-当天未评论,1-已评论
	--todo
	CPartnerCommentView:ShowView(function(oView)
		oView:RefreshData(partner_type, list, hot_list, is_comment)
	end)
end

function GS2CAwakePartner(pbdata)
	local partnerid = pbdata.partnerid
	--todo
	CAwakeResultView:ShowView(function (oView)
		oView:SetPartner(partnerid)
	end)
end

function GS2CPartnerPicturePosList(pbdata)
	local pos_list = pbdata.pos_list --所有位置的图鉴信息
	--todo
	g_PartnerCtrl:UpdatePartnerPhoto(pos_list)
end

function GS2CAddPartnerList(pbdata)
	local partner_list = pbdata.partner_list
	--todo
	g_PartnerCtrl:AddPartnerList(partner_list)
end

function GS2CShowPartnerSkin(pbdata)
	local itemid = pbdata.itemid --皮肤id
	--todo
	if CPartnerSkinView:IsHasSkinView(itemid) then
		CPartnerSkinView:ShowView(function (oView)
			oView:SetData(itemid)
		end)
	end
	g_ItemCtrl:OnEvent(define.Item.Event.RefreshPartnerSkin)
end

function GS2CShowNewPartnerUI(pbdata)
	local par_types = pbdata.par_types
	--todo
	CPartnerGainView2:ShowView(function (oView)
		oView:SetPartnerType(par_types[1])
	end)
end

function GS2CPartnerStarUpStar(pbdata)
	local parid = pbdata.parid --伙伴id
	local old_star = pbdata.old_star
	local new_star = pbdata.new_star
	local old_apply = pbdata.old_apply
	local new_apply = pbdata.new_apply
	local max_grade = pbdata.max_grade --升星后最大等级
	--todo
	local oView = CPartnerImproveView:GetView()
	if oView then
		oView:DoUpStarEffect()
	end
end

function GS2COpenPartnerSkillUI(pbdata)
	local parid = pbdata.parid --伙伴id
	local skills = pbdata.skills --技能
	--todo
	if #skills > 0 then
		local oView = CPartnerImproveView:GetView()
		if oView then
			oView:DoSkillEffect(skills)
		end
		CSkillUpGradeView:ShowView(function(oView)
			oView:UpdateData(parid, skills)
		end)

	end
end

function GS2CComposePartner(pbdata)
	local parid = pbdata.parid --合成伙伴id列表
	--todo
	local oView = CPartnerMainView:GetView()
	if oView then
		oView:ShowComposeResult(parid)
	end
end

function GS2CUpGradePartner(pbdata)
	local parid = pbdata.parid --伙伴id
	--todo
	local oView = CPartnerImproveView:GetView()
	if oView then
		oView:DoUpGradeEffect()
	end
end

function GS2COpenPartnerUI(pbdata)
	local parid = pbdata.parid
	local type = pbdata.type --1-升级界面，2-升星界面
	local md5 = pbdata.md5
	local applys = pbdata.applys
	--todo
	local oView = CPartnerImproveView:GetView()
	if oView then
		oView:UpdateAttrResult(parid, type, applys)
	end
end

function GS2CComposePartnerStone(pbdata)
	local stonesid = pbdata.stonesid --符石sid
	--todo
	local oView = CPartnerStoneComposeView:GetView()
	if oView then
		oView:SetResult(stonesid)
	end
end

function GS2CLoginParSoulPlan(pbdata)
	local plans = pbdata.plans --所有御灵方案
	--todo
	g_PartnerCtrl:InitSoulPlan(plans)
end

function GS2CAddParSoulPlan(pbdata)
	local plan = pbdata.plan --御灵方案
	--todo
	g_PartnerCtrl:AddSoulPlan(plan)
end

function GS2CDelParSoulPlan(pbdata)
	local idx = pbdata.idx --方案id
	--todo
	g_PartnerCtrl:DelSoulPlan(idx)
end

function GS2CUpdateParSoulPlan(pbdata)
	local plan = pbdata.plan --方案
	--todo
	g_PartnerCtrl:UpdateSoulPlan(plan)
end

function GS2CExchangePartnerChip(pbdata)
	local chip_sid = pbdata.chip_sid --消耗碎片导表id
	local amount = pbdata.amount --转换数量
	local target_sid = pbdata.target_sid --转换目标sid,目前是万能碎片sid
	--todo
	local oView = CItemPartnerChipExchangeView:GetView()
	if oView then
		g_NotifyCtrl:FloatMsg(string.format("转化成功，获得%d个万能碎片", amount))
		oView:RefreshChipGrid(chip_sid)
	end
end


--C2GS--

function C2GSPartnerFight(fight_info)
	local t = {
		fight_info = fight_info,
	}
	g_NetCtrl:Send("partner", "C2GSPartnerFight", t)
end

function C2GSPartnerSwitch(fight_info)
	local t = {
		fight_info = fight_info,
	}
	g_NetCtrl:Send("partner", "C2GSPartnerSwitch", t)
end

function C2GSDrawWuLingCard(card_cnt, dm_close)
	local t = {
		card_cnt = card_cnt,
		dm_close = dm_close,
	}
	g_NetCtrl:Send("partner", "C2GSDrawWuLingCard", t)
end

function C2GSDrawWuHunCard(up, dm_close, sp_item, card_cnt)
	local t = {
		up = up,
		dm_close = dm_close,
		sp_item = sp_item,
		card_cnt = card_cnt,
	}
	g_NetCtrl:Send("partner", "C2GSDrawWuHunCard", t)
end

function C2GSOpenDrawCardUI()
	local t = {
	}
	g_NetCtrl:Send("partner", "C2GSOpenDrawCardUI", t)
end

function C2GSCloseDrawCardUI()
	local t = {
	}
	g_NetCtrl:Send("partner", "C2GSCloseDrawCardUI", t)
end

function C2GSUpgradePartnerStar(partnerid)
	local t = {
		partnerid = partnerid,
	}
	g_NetCtrl:Send("partner", "C2GSUpgradePartnerStar", t)
end

function C2GSSetPartnerLock(partnerid, lock)
	local t = {
		partnerid = partnerid,
		lock = lock,
	}
	g_NetCtrl:Send("partner", "C2GSSetPartnerLock", t)
end

function C2GSRenamePartner(partnerid, name)
	local t = {
		partnerid = partnerid,
		name = name,
	}
	g_NetCtrl:Send("partner", "C2GSRenamePartner", t)
end

function C2GSComposePartner(partner_chip_type, compose_amount)
	local t = {
		partner_chip_type = partner_chip_type,
		compose_amount = compose_amount,
	}
	g_NetCtrl:Send("partner", "C2GSComposePartner", t)
end

function C2GSAwakePartner(partnerid)
	local t = {
		partnerid = partnerid,
	}
	g_NetCtrl:Send("partner", "C2GSAwakePartner", t)
end

function C2GSComposeAwakeItem(sid, compose_amount)
	local t = {
		sid = sid,
		compose_amount = compose_amount,
	}
	g_NetCtrl:Send("partner", "C2GSComposeAwakeItem", t)
end

function C2GSPartnerEquipPlanSave(partnerid, plan_id, equip_list)
	local t = {
		partnerid = partnerid,
		plan_id = plan_id,
		equip_list = equip_list,
	}
	g_NetCtrl:Send("partner", "C2GSPartnerEquipPlanSave", t)
end

function C2GSPartnerEquipPlanUse(partnerid, plan_id, equip_list)
	local t = {
		partnerid = partnerid,
		plan_id = plan_id,
		equip_list = equip_list,
	}
	g_NetCtrl:Send("partner", "C2GSPartnerEquipPlanUse", t)
end

function C2GSAddPartnerComment(partner_type, msg)
	local t = {
		partner_type = partner_type,
		msg = msg,
	}
	g_NetCtrl:Send("partner", "C2GSAddPartnerComment", t)
end

function C2GSPartnerCommentInfo(partner_type)
	local t = {
		partner_type = partner_type,
	}
	g_NetCtrl:Send("partner", "C2GSPartnerCommentInfo", t)
end

function C2GSUpVotePartnerComment(partner_type, comment_id, comment_type)
	local t = {
		partner_type = partner_type,
		comment_id = comment_id,
		comment_type = comment_type,
	}
	g_NetCtrl:Send("partner", "C2GSUpVotePartnerComment", t)
end

function C2GSGetOuQi(oid)
	local t = {
		oid = oid,
	}
	g_NetCtrl:Send("partner", "C2GSGetOuQi", t)
end

function C2GSPartnerPictureSwitchPos(picture_pos)
	local t = {
		picture_pos = picture_pos,
	}
	g_NetCtrl:Send("partner", "C2GSPartnerPictureSwitchPos", t)
end

function C2GSUsePartnerItem(itemid, target, amount)
	local t = {
		itemid = itemid,
		target = target,
		amount = amount,
	}
	g_NetCtrl:Send("partner", "C2GSUsePartnerItem", t)
end

function C2GSComposePartnerEquip(cost_list)
	local t = {
		cost_list = cost_list,
	}
	g_NetCtrl:Send("partner", "C2GSComposePartnerEquip", t)
end

function C2GSLockPartnerItem(itemid)
	local t = {
		itemid = itemid,
	}
	g_NetCtrl:Send("partner", "C2GSLockPartnerItem", t)
end

function C2GSSetFollowPartner(partnerid, tid)
	local t = {
		partnerid = partnerid,
		tid = tid,
	}
	g_NetCtrl:Send("partner", "C2GSSetFollowPartner", t)
end

function C2GSQuickWearPartnerEquip(partnerid, wear_list)
	local t = {
		partnerid = partnerid,
		wear_list = wear_list,
	}
	g_NetCtrl:Send("partner", "C2GSQuickWearPartnerEquip", t)
end

function C2GSUpGradePartner(partnerid, upgrade)
	local t = {
		partnerid = partnerid,
		upgrade = upgrade,
	}
	g_NetCtrl:Send("partner", "C2GSUpGradePartner", t)
end

function C2GSOpenPartnerUI(partnerid, type, md5)
	local t = {
		partnerid = partnerid,
		type = type,
		md5 = md5,
	}
	g_NetCtrl:Send("partner", "C2GSOpenPartnerUI", t)
end

function C2GSAddPartnerSkill(partnerid)
	local t = {
		partnerid = partnerid,
	}
	g_NetCtrl:Send("partner", "C2GSAddPartnerSkill", t)
end

function C2GSBuyPartnerBaseEquip(pos, parid)
	local t = {
		pos = pos,
		parid = parid,
	}
	g_NetCtrl:Send("partner", "C2GSBuyPartnerBaseEquip", t)
end

function C2GSRecyclePartnerEquipList(equipids)
	local t = {
		equipids = equipids,
	}
	g_NetCtrl:Send("partner", "C2GSRecyclePartnerEquipList", t)
end

function C2GSStrengthPartnerEquip(itemid, one_key)
	local t = {
		itemid = itemid,
		one_key = one_key,
	}
	g_NetCtrl:Send("partner", "C2GSStrengthPartnerEquip", t)
end

function C2GSUpstarPartnerEquip(itemid)
	local t = {
		itemid = itemid,
	}
	g_NetCtrl:Send("partner", "C2GSUpstarPartnerEquip", t)
end

function C2GSInlayPartnerStone(equipid, stoneid)
	local t = {
		equipid = equipid,
		stoneid = stoneid,
	}
	g_NetCtrl:Send("partner", "C2GSInlayPartnerStone", t)
end

function C2GSComposePartnerStone(stonesid, one_key)
	local t = {
		stonesid = stonesid,
		one_key = one_key,
	}
	g_NetCtrl:Send("partner", "C2GSComposePartnerStone", t)
end

function C2GSUsePartnerSoulType(soul_type, soul_pos, parid)
	local t = {
		soul_type = soul_type,
		soul_pos = soul_pos,
		parid = parid,
	}
	g_NetCtrl:Send("partner", "C2GSUsePartnerSoulType", t)
end

function C2GSUpgradePartnerSoul(soul_id, cost_ids)
	local t = {
		soul_id = soul_id,
		cost_ids = cost_ids,
	}
	g_NetCtrl:Send("partner", "C2GSUpgradePartnerSoul", t)
end

function C2GSUsePartnerSoul(parid, soul_id, pos)
	local t = {
		parid = parid,
		soul_id = soul_id,
		pos = pos,
	}
	g_NetCtrl:Send("partner", "C2GSUsePartnerSoul", t)
end

function C2GSSwapPartnerEquip(src_parid, des_parid)
	local t = {
		src_parid = src_parid,
		des_parid = des_parid,
	}
	g_NetCtrl:Send("partner", "C2GSSwapPartnerEquip", t)
end

function C2GSReceivePartnerChip()
	local t = {
	}
	g_NetCtrl:Send("partner", "C2GSReceivePartnerChip", t)
end

function C2GSReDrawPartner()
	local t = {
	}
	g_NetCtrl:Send("partner", "C2GSReDrawPartner", t)
end

function C2GSSwapPartnerEquipByPos(src_parid, des_parid, src_pos, des_pos)
	local t = {
		src_parid = src_parid,
		des_parid = des_parid,
		src_pos = src_pos,
		des_pos = des_pos,
	}
	g_NetCtrl:Send("partner", "C2GSSwapPartnerEquipByPos", t)
end

function C2GSAddParSoulPlan(name, soul_type, souls)
	local t = {
		name = name,
		soul_type = soul_type,
		souls = souls,
	}
	g_NetCtrl:Send("partner", "C2GSAddParSoulPlan", t)
end

function C2GSDelParSoulPlan(idx)
	local t = {
		idx = idx,
	}
	g_NetCtrl:Send("partner", "C2GSDelParSoulPlan", t)
end

function C2GSModifyParSoulPlan(idx, name, soul_type, souls)
	local t = {
		idx = idx,
		name = name,
		soul_type = soul_type,
		souls = souls,
	}
	g_NetCtrl:Send("partner", "C2GSModifyParSoulPlan", t)
end

function C2GSParSoulPlanUse(idx, parid)
	local t = {
		idx = idx,
		parid = parid,
	}
	g_NetCtrl:Send("partner", "C2GSParSoulPlanUse", t)
end

function C2GSExchangePartnerChip(chip_sid, amount)
	local t = {
		chip_sid = chip_sid,
		amount = amount,
	}
	g_NetCtrl:Send("partner", "C2GSExchangePartnerChip", t)
end

