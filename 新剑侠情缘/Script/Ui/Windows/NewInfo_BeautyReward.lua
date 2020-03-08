local tbUi = Ui:CreateClass("NewInfo_BeautyReward")
-- 好声音评选和美女评选活动共用最新消息奖励界面
tbUi.szContent = [[
[FFFE0D]「武林第一美女评选」[-]评选期间（%s~%s），累计赠送[FF69B4][url=openwnd:红粉佳人, ItemTips, "Item", nil, 4692][-]达到以下数量可以领取奖励：
                                                [FF69B4]剑侠多佳人，美者颜如玉。
                                                一笑倾人城，再笑倾人国。[-] ]]
if version_vn then
	tbUi.szContent = [[
[FFFE0D]「武林第一美女评选」[-]评选期间（%s~%s），累计赠送[FF69B4][url=openwnd:红粉佳人, ItemTips, "Item", nil, 4692][-]达到以下数量可以领取奖励，此投票奖励将会在决赛开始时再进行重置，也就是玩家在决赛开始时再投票可以领取到第二份奖励哦：
                                                [FF69B4]剑侠多佳人，美者颜如玉。
                                                一笑倾人城，再笑倾人国。[-] ]]
end

tbUi.szGoodVoiceContent = [[
[FFFE0D]「剑侠好声音」[-]评选期间（%s~%s），累计赠送[FF69B4][url=openwnd:桃花笺, ItemTips, "Item", nil, 7537][-]达到以下数量可以领取奖励：
                                           ]]
local tbBeautyPageantAct = Activity.BeautyPageant;
local tbGoodVoiceAct = Activity.GoodVoice
function tbUi:OnOpen(tbData)
	local tbAct = self:GetRunningAct()
	local bGoodVoiceRunning = tbGoodVoiceAct:IsInProcess()
	local szActKey = bGoodVoiceRunning and "GoodVoice" or "BeautyPageant"
	local _, tbActData = Activity:GetActUiSetting(szActKey)
	local szStartTime = Lib:TimeDesc17(tbAct.STATE_TIME[tbAct.STATE_TYPE.LOCAL][1])
	local szEndTime = Lib:TimeDesc17(tbActData.nEndTime)
	local tbFinalTime = tbAct.STATE_TIME[tbAct.STATE_TYPE.FINAL]
	local szContentTxt = bGoodVoiceRunning and self.szGoodVoiceContent or self.szContent
	local szContent = string.format(szContentTxt, szStartTime, Lib:TimeDesc17(tbFinalTime[2]))

	self.DetailsBeauty:SetLinkText(szContent);

	self:UpdateAwardInfo();
end

function tbUi:GetRunningAct()
	local tbAct = tbBeautyPageantAct
	local bGoodVoiceRunning = tbGoodVoiceAct:IsInProcess()
	if bGoodVoiceRunning then
		tbAct = tbGoodVoiceAct
	end
	return tbAct
end

function tbUi:OnSubPanelNotify(nEvent, pParent, bHaveAward)
	if UiNotify.emNOTIFY_BEAUTY_VOTE_AWARD == nEvent then
		if not bHaveAward then
			pParent:Update();
			Activity:CheckRedPoint();
		else
			self:UpdateAwardInfo()
		end
	end
end

function tbUi:UpdateAwardInfo()
	local tbAct = self:GetRunningAct();
	self.tbAwardList = {}
	for nIndex,tbAwardInfo in ipairs(tbAct.tbVotedAward) do
		local tbAward, nCanGet, nGotCount, bIsShow = tbAct:GetVotedAward(me, nIndex);
		if bIsShow then
			table.insert(self.tbAwardList, 
				{
					tbAward = tbAward,
					nCanGet = nCanGet,
					nGotCount = nGotCount,
					tbInfo = tbAwardInfo,
					nIndex = nIndex,
				})
		end
	end

	local function fnSort(a,b)
		if a.tbInfo.nMaxCount < 0 or b.tbInfo.nMaxCount < 0 then
			return a.tbInfo.nMaxCount < b.tbInfo.nMaxCount 
		elseif a.nCanGet > 0 and b.nCanGet > 0 then
			return a.tbInfo.nNeedCount < b.tbInfo.nNeedCount
		elseif a.nCanGet <= 0 and b.nCanGet <= 0 then
			if (a.nGotCount <= 0 and b.nGotCount <= 0) or (a.nGotCount > 0 and b.nGotCount > 0) then
				return a.tbInfo.nNeedCount < b.tbInfo.nNeedCount
			else
				return a.nGotCount < b.nGotCount
			end
		else
			return a.nCanGet > b.nCanGet
		end
	end

	table.sort(self.tbAwardList, fnSort)

	local nVotedCount = tbAct:GetVotedCount(me)

	local fnSetItem = function (itemObj, index)
		local bGoodVoiceRunning = tbGoodVoiceAct:IsInProcess()
		local szContent = bGoodVoiceRunning and "累计赠送%d张" or "累计赠送%d朵"
		local szContent2 = bGoodVoiceRunning and "每赠送1张获得%d元气" or "每赠送1朵获得%d元气"
		local tbAwardInfo = self.tbAwardList[index]
		local szCondition = ""
		if tbAwardInfo.tbInfo.nMaxCount > 0 then
			szCondition = string.format(szContent, tbAwardInfo.tbInfo.nNeedCount)
		else
			szCondition = string.format(szContent2,  tbAwardInfo.tbInfo.tbAward[2])
		end

		itemObj.pPanel:Label_SetText("MarkTxt", szCondition);
		itemObj.itemframe:SetGenericItem(tbAwardInfo.tbAward);
		itemObj.itemframe.fnClick = itemObj.itemframe.DefaultClick;

		if tbAwardInfo.nCanGet <= 0 then
			if tbAwardInfo.tbInfo.nMaxCount > 0 then
				itemObj.pPanel:SetActive("BtnGet", false);
				if tbAwardInfo.nGotCount <= 0 then
					itemObj.pPanel:SetActive("Bar", true);
					itemObj.pPanel:SetActive("AlreadyGet", false);
					itemObj.pPanel:Label_SetText("BarTxt", string.format("%d/%d", nVotedCount, tbAwardInfo.tbInfo.nNeedCount));
					itemObj.pPanel:Sprite_SetFillPercent("Bar", math.min(1, nVotedCount/tbAwardInfo.tbInfo.nNeedCount))
				else
					itemObj.pPanel:SetActive("Bar", false);
					itemObj.pPanel:SetActive("AlreadyGet", true);
				end
			else
				itemObj.pPanel:SetActive("Bar", false);
				itemObj.pPanel:SetActive("AlreadyGet", false);
				itemObj.pPanel:SetActive("BtnGet", true);
				itemObj.pPanel:Button_SetEnabled("BtnGet", false);
			end
		else
			itemObj.pPanel:SetActive("BtnGet", true);
			itemObj.pPanel:Button_SetEnabled("BtnGet", true);
			itemObj.pPanel:SetActive("Bar", false);
			itemObj.pPanel:SetActive("AlreadyGet", false);

			itemObj.BtnGet.pPanel.OnTouchEvent = function ()
				local bGoodVoiceRunning = tbGoodVoiceAct:IsInProcess()
				if bGoodVoiceRunning then
					RemoteServer.GoodVoiceVotedAwardReq(tbAwardInfo.nIndex);
				else
					RemoteServer.BeautyPageantVotedAwardReq(tbAwardInfo.nIndex);
				end
			end
		end
	end

	self.ScrollViewBeautyReward:Update(self.tbAwardList, fnSetItem);
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

tbUi.tbOnClick.BtnGive = function (self)
	local tbAct = self:GetRunningAct();
	local nCompetitionType = Ui:GetClass("BeautyCompetitionPanel").TYPE_BEAUTY_COMPETITION
	local bGoodVoiceRunning = tbGoodVoiceAct:IsInProcess()
	if bGoodVoiceRunning then
		nCompetitionType = Ui:GetClass("BeautyCompetitionPanel").TYPE_GOODVOICE_COMPETITION
	end
	local nCount, _ = me.GetItemCountInAllPos(tbAct.VOTE_ITEM);
	if nCount <= 0 then
		local szItemName = Item:GetItemTemplateShowInfo(tbAct.VOTE_ITEM, me.nFaction, me.nSex) or ""
		local szMsg = string.format("%s数量不足，可通过充值任意金额获得", szItemName);
		me.Msg(szMsg);
		me.CenterMsg(szMsg);
		Ui:OpenWindow('CommonShop','Recharge')
	else
		Ui:OpenWindow("BeautyCompetitionPanel", nCompetitionType)
	end
end