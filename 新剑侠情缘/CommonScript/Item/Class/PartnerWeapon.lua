local tbItem = Item:GetClass("PartnerWeapon");

function tbItem:OnUse(pItem)
	local nPartnerTemplateId = Partner.tbWeaponInfo[pItem.dwTemplateId];
	if not nPartnerTemplateId then
		return;
	end

	local nPartnerId;
	local tbPartner;
	local tbPosInfo = me.GetPartnerPosInfo();
	for i = 1, Partner.MAX_PARTNER_POS_COUNT do
		local nPId = tbPosInfo[i];
		if nPId and nPId > 0 then
			tbPartner = me.GetPartnerInfo(nPId);
			if tbPartner and tbPartner.nTemplateId == nPartnerTemplateId then
				nPartnerId = nPId;
				break;
			end
		end
	end

	if not nPartnerId then
		local szPName = GetOnePartnerBaseInfo(nPartnerTemplateId);
		me.CenterMsg(string.format("请先上阵同伴【%s】", szPName));
		return;
	end

	if tbPartner.nWeaponState ~= 0 then
		me.CenterMsg(string.format("上阵的【%s】已经拥有此武器", tbPartner.szName));
		return;
	end

	local szItemName = pItem.szName;
	if string.find(szItemName, tbPartner.szName) then
		local nLen = Lib:Utf8Len(tbPartner.szName) + 1;
		local tbChar = Lib:GetUft8Chars(szItemName);

		szItemName = table.concat(tbChar, nil, nLen + 1, #tbChar);
	end

	me.MsgBox(string.format("确定装备 [FFFE0D]%s[-] 本命武器 [FFFE0D]%s[-] ？\n[FFFE0D]（装备后不可取下，遣散后将会返还）[-]", tbPartner.szName, szItemName),
		{
			{"确定", self.UseWeapon, self, me.dwID, nPartnerId, pItem.dwId},
			{"取消"}
		});
	return;
end

function tbItem:GetUseSetting(nItemTemplateId, nItemId)
	local function fnSell()
		Shop:ConfirmSell(nItemId);
	end

	if Shop:CanSellWare(me, nItemId or 0, 1) then
		return {szFirstName = "出售", fnFirst = fnSell, szSecondName = "使用", fnSecond = "UseItem"};
	end

	return {szFirstName = "使用", fnFirst = "UseItem"};
end

function tbItem:UseWeapon(nPlayerId, nPartnerId, nItemId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local pItem = KItem.GetItemObj(nItemId);
	if not pPlayer or not pItem then
		return;
	end

	local nCount = pPlayer.ConsumeItem(pItem, 1, Env.LogWay_PartnerUseWeapon);
	if nCount <= 0 then
		pPlayer.CenterMsg("扣除道具失败！");
		return;
	end

	local bResult = pPlayer.SetPartnerWeaponState(nPartnerId, 1);
	if not bResult then
		Log("[PartnerWeapon] SetPartnerWeaponState Fail !!", pPlayer.szName, pPlayer.szAccount, pPlayer.dwID, nPartnerId);
		return;
	end

	local pPartner = pPlayer.GetPartnerObj(nPartnerId);
	pPartner.TLog(Partner.TLOG_DEF_PARTNER_USE_WEAPON, Env.LogWay_PartnerUseWeapon);

	pPlayer.CallClientScript("Ui:CloseWindow", "ItemTips");
	pPlayer.CallClientScript("Ui:OpenWindow", "Partner", "PartnerMainPanel", string.format("PId=%s;", nPartnerId));
	pPlayer.SyncPartner(nPartnerId);
	Partner:CheckWeaponAchi(pPlayer)
	Log("[PartnerWeapon] UseWeapon", pPlayer.szName, pPlayer.szAccount, pPlayer.dwID, nPartnerId);
end

function tbItem:GetTip(pItem)
	local nPartnerId = Partner.tbWeaponInfo[pItem.dwTemplateId];
	if not nPartnerId then
		return "";
	end

	local tbEquipInfo = GetPartnerWeaponInfo(nPartnerId);
	local szTips = "[ECE82B]";
	szTips = szTips .. string.format("战斗力  +%s\n", math.floor(tbEquipInfo.nValue * Partner.nValueToFightPower * Partner.nWeaponValue2RealValue));
	local function fnCmp(tb1, tb2)
		return tb1.szAttribName > tb2.szAttribName;
	end
	table.sort(tbEquipInfo.tbAttrib, fnCmp);

	for _, tbAttrib in ipairs(tbEquipInfo.tbAttrib) do
		szTips = szTips .. FightSkill:GetMagicDesc(tbAttrib.szAttribName, tbAttrib.tbValue) .. "\n";
	end
	szTips = szTips .. "[-]";
	return szTips;
end
