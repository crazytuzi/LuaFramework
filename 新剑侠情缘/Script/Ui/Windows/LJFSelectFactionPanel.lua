local tbUi = Ui:CreateClass("LJFSelectFactionPanel");
Fuben.LingJueFengWeek = Fuben.LingJueFengWeek or {};
local LingJueFengWeek = Fuben.LingJueFengWeek;

LingJueFengWeek.nState = 0;
function tbUi:OnOpen(bIsZoneCall , bNotTime)
	Ui:CloseWindow("MessageBox");
	LingJueFengWeek.nState = 1;
	LingJueFengWeek.tbTeamFaction = {};
	LingJueFengWeek.tbFactionChoose = {};
	self.nLeftTime = LingJueFengWeek.RANDOM_FACTION_TIME;
	local szTips =  string.format("请选择你在%s中的门派：-", Fuben.TianJiMiZhen:IsOpen() and "天机迷阵" or "凌绝峰");
	self.pPanel:Label_SetText("TitleTxt", szTips);
	if not bNotTime then
		self.nTimer = Timer:Register(Env.GAME_FPS , self.TimerUpdate, self)
	end
	self.pPanel:Label_SetText("Description" , LingJueFengWeek.szFactionDescription);
	self:UpdateMain();
	if bIsZoneCall then
		LingJueFengWeek:TrySelectFaction(me.nFaction);
	end
	-- 设置3秒继续挑战CD
	self.nClickCD = GetTime();
end

function tbUi:OnOpenEnd()
	Ui:OpenWindow("ChatLargePanel", ChatMgr.ChannelType.Team)
	LingJueFengWeek:FlushFactionPanel();
end

function tbUi:OnClose()
	Fuben.LingJueFengWeek.nState = 0;
	self.nClickCD = nil;
	self.nChoose = nil;
	self.nLeftTime = nil;
	if self.nTimer then
		Timer:Close(self.nTimer)
		self.nTimer = nil;
	end
end

function tbUi:RegisterEvent()
	local tbRegEvent = 
	{
		{UiNotify.emNoTIFY_LJF_WEEK_UPDATE, self.OnNotify, self},
	};
	return tbRegEvent;
end

function tbUi:OnNotify(...)
	self:_OnNotify(...)
end

function tbUi:_OnNotify(...)
	self:UpdateMain();
end

function tbUi:TimerUpdate()
	if not self or not self.nLeftTime then return false end ;
	if not self.pPanel then return false end;
	local szTips = string.format("请选择你在%s中的门派：", Fuben.TianJiMiZhen:IsOpen() and "天机迷阵" or "凌绝峰");
	szTips = szTips..tostring(self.nLeftTime);
	self.pPanel:Label_SetText("TitleTxt", szTips);
	if self.nLeftTime < 1 then
		self.nLeftTime = nil;
		Ui:CloseWindow(self.UI_NAME)
		return true;
	end
	self.nLeftTime = self.nLeftTime - 1;
	return true
end

tbUi.nFacRows = nil;
function tbUi:UpdateMain()
	self.nFacRows = math.ceil((#Faction.tbFactionInfo)/4);
	local fnSetItem = function(itemObj, i)
		for j = 1 ,4 do
			local nIndex = i * 4 + j - 4;
			local fnChooseFaction = function()
				LingJueFengWeek:TrySelectFaction(nIndex);
			end
			local szBigIcon,szAtlas = Faction:GetBigIcon(nIndex)
			local szButton = "FactionIcon"..j;
			if not Lib:IsEmptyStr(szBigIcon) then
				itemObj.pPanel:SetActive(szButton,true);
				itemObj.pPanel:Button_SetSprite(szButton, szBigIcon)
				local szName = LingJueFengWeek.tbFactionChoose[nIndex];
				if szName then
					itemObj.pPanel:Sprite_SetSprite(szButton, szBigIcon,szAtlas);
					if szName ~= me.szName then
						itemObj["FactionIcon"..j].pPanel:Label_SetText("Name" .. j, szName);
					else
						szName = string.format("[FFFE0D]%s[-]",szName);
						itemObj["FactionIcon"..j].pPanel:Label_SetText("Name" .. j, szName);
						self.nChoose = nIndex;
					end
				else
					itemObj["FactionIcon"..j].pPanel:Label_SetText("Name" .. j, "");
					itemObj.pPanel:Sprite_SetSpriteGray(szButton, szBigIcon,szAtlas)
				end
				itemObj["FactionIcon"..j].pPanel.OnTouchEvent = fnChooseFaction;
			else
				itemObj.pPanel:SetActive(szButton,false);
			end
		end
	end
	self.View:Update(self.nFacRows,fnSetItem);
end

tbUi.tbOnClick = {};
tbUi.tbOnClick["BtnSelect"] = function(self)
	if TeamMgr:IsCaptain(me.dwID) then
		self.nClickCD = self.nClickCD or GetTime();
		if GetTime() > self.nClickCD + 3 then
			LingJueFengWeek:TeamCompleteFaction();
		else
			me.CenterMsg("请等待队友确认");
		end
	else
		if self.nChoose then
			ChatMgr:SendMsg(ChatMgr.ChannelType.Team,string.format("已确定职业「%s」，可以进入秘境",Faction.tbFactionInfo[self.nChoose].szName));
		else
			me.CenterMsg("请先选择门派");
		end
	end
end

tbUi.tbOnClick.Bg = function (self)
	if Ui:WindowVisible("ChatLargePanel") then
		return
	end

	Ui:OpenWindow("ChatLargePanel", ChatMgr.ChannelType.Team)
end
