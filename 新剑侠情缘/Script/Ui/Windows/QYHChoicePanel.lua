local tbUi = Ui:CreateClass("QYHChoicePanel");
local nMaxFaction = 8
function tbUi:OnOpen(tbFaction, nUpdateTime, nType, szKinName)
	self.nChooseFaction = nil
	QunYingHuiCross:ClearChooseFaction()
	self:RefreshUi(tbFaction)
	if nUpdateTime and nUpdateTime > 0 then
		self.nUpdateTime = nUpdateTime
		self.nUpdateTimer = Timer:Register(Env.GAME_FPS, self.OnUpdate, self);
	end
end

function tbUi:OnOpenEnd(tbFaction, nUpdateTime, nType, szKinName)
	self:OpenChatLarge(nType, szKinName)
end

function tbUi:OpenChatLarge(nType, szKinName)
	if nType then
		if nType == QunYingHuiCross.TYPE_SINGLE then
			if szKinName then
				Ui:OpenWindow("ChatLargePanel", ChatMgr.ChannelType.Kin)
			else
				Ui:OpenWindow("ChatLargePanel", ChatMgr.ChannelType.Friend)
			end
		elseif nType == QunYingHuiCross.TYPE_TEAM then
			Ui:OpenWindow("ChatLargePanel", ChatMgr.ChannelType.Team)
		end
	end
end

function tbUi:OnUpdate()
	self.nUpdateTime = self.nUpdateTime - 1
	self.pPanel:Label_SetText("TitleTxt", string.format("请选择你在群英会中的门派（[FFFE0D]%s[-]）", Lib:TimeDesc3(self.nUpdateTime)))
	if self.nUpdateTime <= 0 then
		self.nUpdateTimer = nil
		return false
	end
	return true
end

function tbUi:OnClose()
	self:CloseUpdateTimer()
end

function tbUi:CloseUpdateTimer()
	if self.nUpdateTimer then
		Timer:Close(self.nUpdateTimer)
		self.nUpdateTimer = nil
	end
end

function tbUi:RefreshUi(tbFaction)
	self.pPanel:SetActive("Btn", false)
	self.pPanel:Label_SetText("TitleTxt", "请选择你在群英会中的门派");
	if self.nUpdateTime then
		self.pPanel:Label_SetText("TitleTxt", string.format("请选择你在群英会中的门派（[FFFE0D]%s[-]）", Lib:TimeDesc3(self.nUpdateTime)));
	end
	self.pPanel:Label_SetText("Tip", string.format("*若未选定门派，群英会开始后将自动为侠士选定一个门派\n*所有侠士[FFFE0D]等级相同，不携带同伴，拥有完全相同的对战实力[-]\n*胜负奖励及排行奖励会[FFFE0D]在活动结算后统一通过邮件[-]发放给各位侠士\n*单人参赛的侠士若遇到心仪的队友，可[FFFE0D]申请继续组队一同匹配[-]"));
	self.tbFaction = tbFaction or self.tbFaction
	local tbChooseFaction = QunYingHuiCross:GetChooseFaction()
	for nFactionItem = 1, nMaxFaction do
		local tbFactionInfo = self.tbFaction[nFactionItem]
		local szFactionItem = "Faction" .. nFactionItem
		local szNameItem = "Name" .. nFactionItem
		self.pPanel:Label_SetText(szNameItem, "");
		if tbFactionInfo then
			local szBigIcon = Faction:GetBigIcon(tbFactionInfo.nFaction)
			if not Lib:IsEmptyStr(szBigIcon) then
				self.pPanel:Button_SetSprite(szFactionItem, szBigIcon);
				local szName = tbChooseFaction[tbFactionInfo.nFaction]
				if szName then
					self.pPanel:Sprite_SetSprite(szFactionItem, szBigIcon);
					self.pPanel:Label_SetText(szNameItem, szName);
				else
					self.pPanel:Sprite_SetSpriteGray(szFactionItem, szBigIcon)
					self.pPanel:Label_SetText(szNameItem, "");
				end
			end
			self.pPanel:SetActive(szFactionItem, true)
		else
			self.pPanel:SetActive(szFactionItem, false)
		end	
	end
end

tbUi.tbOnClick = {
	Btn = function (self)
		-- if not self.nChooseFaction then
		-- 	me.CenterMsg("请选择门派", true)
		-- 	return 
		-- end
		-- RemoteServer.QYHCrossClientCall("ChooseFaction", self.nChooseFaction)
	end;
}

for nFaction = 1, nMaxFaction do
	tbUi.tbOnClick["Faction" ..nFaction] = function (self)
		local nChooseFaction = self.tbFaction[nFaction] and self.tbFaction[nFaction].nFaction
		local tbChooseFaction = QunYingHuiCross:GetChooseFaction()
		local szName = tbChooseFaction[nChooseFaction]
		if szName then
			if szName ~= me.szName then
				me.CenterMsg("此门派已经被选")
			end
			return
		end
		self.nChooseFaction = nChooseFaction
		RemoteServer.QYHCrossClientCall("ChooseFactionChange", self.nChooseFaction)
	end
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{

		{ UiNotify.emNOTIFY_QYHCROSS_CHOOSE_FACTION,		self.RefreshUi , self},

	};

	return tbRegEvent;
end