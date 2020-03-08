
local tbItem = Item:GetClass("LoveToken");

tbItem.nTimeout = 3 * 24 * 3600;
tbItem.LOVER_NAME_STR_INDEX1 = 1;
tbItem.LOVER_NAME_STR_INDEX2 = 2;
tbItem.LOVER_ID_INT_INDEX = 1;
tbItem.LOVER_TYPE_INT_INDEX = 2;

function tbItem:OnUseLoveTokenItem(pPlayer, it, szTitle1, szTitle2)
	local bCanUse, szMsg, pOther = self:CheckCanUseItem(pPlayer, it, szTitle1, szTitle2);
	if not bCanUse then
		pPlayer.CenterMsg(szMsg);
		return;
	end

	pOther.MsgBox(string.format("侠士[FFFE0D]%s[-]想要与您结成情缘，并设定您的情缘称号为[FFFE0D]%s[-]，同意吗？", pPlayer.szName, szTitle2),
			{
				{"确认", function () self:ConfirmUseItem(pPlayer.dwID, pOther.dwID, it.dwId, szTitle1, szTitle2, true) end},
				{"拒绝", function () self:ConfirmUseItem(pPlayer.dwID, pOther.dwID, it.dwId, szTitle1, szTitle2, false) end},
			});
end

function tbItem:ConfirmUseItem(nPlayerId, nOtherPlayerId, nItemId, szTitle1, szTitle2, bResult)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end

	if not bResult then
		pPlayer.CenterMsg("对方拒绝与您结成情缘关系！");
		return;
	end

	local it = pPlayer.GetItemInBag(nItemId);
	if not it then
		pPlayer.CenterMsg("道具不存在！");
		return;
	end

	local bCanUse, szMsg, pOther = self:CheckCanUseItem(pPlayer, it, szTitle1, szTitle2);
	if not bCanUse then
		pPlayer.CenterMsg(szMsg);
		return;
	end

	local nType = it.GetIntValue(self.LOVER_TYPE_INT_INDEX);
	if pPlayer.ConsumeItem(it, 1, Env.LogWay_BiWuZhaoQin) ~= 1 then
		pPlayer.CenterMsg("使用道具失败！");
		return;
	end

	BiWuZhaoQin:AddLover(pPlayer, pOther);
	pPlayer.AddTitle(BiWuZhaoQin.nTitleId, -1, true, false, szTitle1);
	pOther.AddTitle(BiWuZhaoQin.nTitleId, -1, true, false, szTitle2);
	pPlayer.SendBlackBoardMsg(string.format("恭喜您与侠士[FFFE0D]%s[-]结成了情缘关系！", pOther.szName));
	pOther.SendBlackBoardMsg(string.format("恭喜您与侠士[FFFE0D]%s[-]结成了情缘关系！", pPlayer.szName));

	if nType == BiWuZhaoQin.TYPE_GLOBAL then
		KPlayer.SendWorldNotify(0, 999, string.format("恭喜侠士[FFFE0D]%s[-]与[FFFE0D]%s[-]结成了情缘关系，从此仗剑江湖，风雨同行！", pPlayer.szName, pOther.szName), 0, 1);
	elseif nType == BiWuZhaoQin.TYPE_KIN then
		if pPlayer.dwKinId > 0 then
			ChatMgr:SendSystemMsg(ChatMgr.SystemMsgType.Kin, string.format("恭喜家族成员[FFFE0D]%s[-]与[FFFE0D]%s[-]结成了情缘关系，从此仗剑江湖，风雨同行！", pPlayer.szName, pOther.szName), pPlayer.dwKinId);
		end
	end
	Log("[BiWuZhaoQin] ConfirmUseItem", nPlayerId, nOtherPlayerId, nItemId, szTitle1, szTitle2);
end

function tbItem:CheckCanUseItem(pPlayer, pItem, szTitle1, szTitle2)
	local tbTitle = {szTitle1, szTitle2};
	for _, szTitle in pairs(tbTitle) do
		if version_vn then
			local nVNLen = string.len(szTitle);
			if nVNLen > BiWuZhaoQin.nVNTitleNameMax or nVNLen < BiWuZhaoQin.nVNTitleNameMin then
				return false, string.format("自定义称号需在%d~%d字之间", BiWuZhaoQin.nVNTitleNameMin, BiWuZhaoQin.nVNTitleNameMax);
			end
		elseif version_th then
			local nNameLen = Lib:Utf8Len(szTitle);
			if nNameLen > BiWuZhaoQin.nTHTitleNameMax or nNameLen < BiWuZhaoQin.nTHTitleNameMin then
				return false, string.format("自定义称号需在%d~%d字之间", BiWuZhaoQin.nTHTitleNameMin, BiWuZhaoQin.nTHTitleNameMax);
			end
		else
			local nNameLen = Lib:Utf8Len(szTitle);
			if nNameLen > BiWuZhaoQin.nTitleNameMax or nNameLen < BiWuZhaoQin.nTitleNameMin then
				return false, string.format("自定义称号需在%d~%d字之间", BiWuZhaoQin.nTitleNameMin, BiWuZhaoQin.nTitleNameMax);
			end
		end

		if not CheckNameAvailable(szTitle) then
			return false, "不允许的自定义称号！";
		end
	end


	if BiWuZhaoQin:GetLover(pPlayer.dwID) then
		return false, "已有情缘关系，不能使用此物品！";
	end

	local nLoverId = pItem.GetIntValue(self.LOVER_ID_INT_INDEX);
	if nLoverId <= 0 then
		return false, "未知道具";
	end

	local tbTeam = TeamMgr:GetTeamById(pPlayer.dwTeamID);
	if not tbTeam then
		return false, "与情缘结成对象一起组队才可以使用！";
	end
	local tbMember = tbTeam:GetMembers();
	local nTeamCount = Lib:CountTB(tbMember);
	if nTeamCount ~= 2 then
		return false, "与情缘结成对象一起组队才可以使用！";
	end

	local pOther;
	for _, nPlayerID in pairs(tbMember) do
		if nPlayerID ~= pPlayer.dwID and nPlayerID ~= nLoverId then
			return false, "此信物只能送给指定的情缘！";
		end

		if BiWuZhaoQin:GetLover(nPlayerID) then
			return false, "对方已有情缘关系，不能使用！";
		end

		local pMember = KPlayer.GetPlayerObjById(nPlayerID);
		if not pMember then
			return false, "对方不在线，无法使用！"
		end
		if nPlayerID == nLoverId then
			pOther = pMember;
		end
	end

	return true, "", pOther;
end

function tbItem:AddLoveToken(pPlayer, nOtherPlayerId, nItemTemplateId, nType)
	if not pPlayer then
		Log("[LoveToken] AddLoveToken Fail !! pPlayer is nil !!", nOtherPlayerId, nItemTemplateId);
		return;
	end

	local tbOtherInfo = KPlayer.GetRoleStayInfo(nOtherPlayerId);
	if not tbOtherInfo then
		Log("[LoveToken] AddLoveToken Fail !! tbOtherInfo is nil !!", pPlayer.dwID, nOtherPlayerId, nItemTemplateId);
		return;
	end

	local tbBaseInfo = KItem.GetItemBaseProp(nItemTemplateId or 0);
	if not tbBaseInfo or tbBaseInfo.szClass ~= "LoveToken" then
		Log("[LoveToken] AddLoveToken Fail !! tbBaseInfo is error !!", pPlayer.dwID, nOtherPlayerId, nItemTemplateId, (tbBaseInfo or {szClass = "nil"}).szClass);
		return;
	end
	local pItem = pPlayer.AddItem(nItemTemplateId, 1, GetTime() + self.nTimeout, Env.LogWay_BiWuZhaoQin, 0);
	if not pItem then
		Log("[LoveToken] AddLoveToken Fail !! pItem is nil !!", pPlayer.dwID, nOtherPlayerId, nItemTemplateId);
		return;
	end

	pItem.SetStrValue(self.LOVER_NAME_STR_INDEX1, pPlayer.szName);
	pItem.SetStrValue(self.LOVER_NAME_STR_INDEX2, tbOtherInfo.szName);
	pItem.SetIntValue(self.LOVER_ID_INT_INDEX, nOtherPlayerId);
	pItem.SetIntValue(self.LOVER_TYPE_INT_INDEX, nType);
	return true;
end

function tbItem:GetTip(it)
	local szTips  ="";

	if not it or not it.dwId then
		szTips = "上面似乎模糊地刻着一些小字！";
	else
		local szPlayerName = it.GetStrValue(self.LOVER_NAME_STR_INDEX1);
		local szOther = it.GetStrValue(self.LOVER_NAME_STR_INDEX2);
		szTips = string.format([[[FFFE0D]%s[-]与[FFFE0D]%s[-]的定情信物！]], szPlayerName, szOther);
	end

	return szTips;
end

function tbItem:CheckCanUseItemInClient(pItem)
	local nLoverId = pItem.GetIntValue(self.LOVER_ID_INT_INDEX);
	if nLoverId <= 0 then
		return false, "未知道具";
	end

	local tbTeamMember =  TeamMgr:GetTeamMember()
	if #tbTeamMember ~= 1 then
		return false, "与情缘结成对象一起组队才可以使用！";
	end

	for _, tbInfo in pairs(tbTeamMember) do
		if tbInfo.nPlayerID ~= nLoverId then
			return false, "此信物只能送给指定的情缘！";
		end
	end

	return true;
end

function tbItem:GetUseSetting(nItemTemplateId, nItemId)
	if nItemId and nItemId > 0 then
		local pItem = me.GetItemInBag(nItemId);
		if not pItem then
			return {};
		end

		local nLoverId = pItem.GetIntValue(self.LOVER_ID_INT_INDEX);
		if not nLoverId then
			return {};
		end

		local tbShowInfo = {szFirstName = "使用", fnFirst = function ()
									local bRet, szInfo = self:CheckCanUseItemInClient(pItem);
									if not bRet then
										me.CenterMsg(szInfo);
										return;
									end

									Ui:OpenWindow("TextSelectPanel2", {"情缘称号", "请在下面输入双方的情缘称号：", "你的称号：", "对方的称号："}, function (szText1, szText2)
										if string.len(szText1) >= 100 or string.len(szText1) <= 0 or string.len(szText2) >= 100 or string.len(szText2) <= 0 then
											me.CenterMsg("称号长度不符合要求");
											return true;
										end

										RemoteServer.BiWuZhaoQinUseItem(nItemId, szText1, szText2);
									end, true);
									Ui:CloseWindow("ItemTips");
								end};

		if not FriendShip:IsFriend(me.dwID, nLoverId) then
			tbShowInfo.szFirstName, tbShowInfo.szSecondName = "添加好友", tbShowInfo.szFirstName;
			tbShowInfo.fnFirst, tbShowInfo.fnSecond = function () FriendShip:RequetAddFriend(nLoverId); end, tbShowInfo.fnFirst;
		end
		return tbShowInfo;
	else
		return {};
	end
end
