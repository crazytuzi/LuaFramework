
local tbPkMode = Ui:CreateClass("PkMode");
local tbPkModeGuide = Ui:CreateClass("PkModeGuide");

local tbMode = 
{
	[0] = "Mode_peace",
	[1] = "Mode_family",
	[2] = "Mode_kill",
	[3] = "Mode_family",
	[4] = "Mode_Camp",
}

local __tbGuideAction = 
{
	{"DialogContainer", "Sprite1", "Sprite2", "Sprite3", "Sprite4"},
	{"Container1", "Sprite2", "Sprite3", "Sprite4"},
	{"Container2", "Sprite1", "Sprite3", "Sprite4"},
	{"Container3", "Sprite1", "Sprite2", "Sprite4"},
	--{"Container4", "Sprite1", "Sprite2", "Sprite3"},
}
local tbAllWnd = {}
local tbGuideAction = {}
for i, tbWndList in ipairs(__tbGuideAction) do
	tbGuideAction[i] = {};
	for _, szWndName in ipairs(tbWndList) do
		tbGuideAction[i][szWndName] = true;
		tbAllWnd[szWndName] = 1;
	end
end


function tbPkModeGuide:OnOpen()
	self.nStep = 0;
	self:OnNextAction();
	local tbUserSet = Ui:GetPlayerSetting();
	self.pPanel:Label_SetText("Name", Guide.ZHAOLIYING_NAME);
	self.pPanel:Button_SetCheck("BtnVoice", tbUserSet.bMuteGuideVoice);
end

function tbPkModeGuide:OnNextAction()
	self.nStep = self.nStep + 1;
	if not tbGuideAction[self.nStep] then
		Ui:CloseWindow(self.UI_NAME);
		return;
	end
	for szWndName, _ in pairs(tbAllWnd) do
		self.pPanel:SetActive(szWndName, tbGuideAction[self.nStep][szWndName])
	end
end

tbPkModeGuide.tbOnClick = 
{
	BackGround = tbPkModeGuide.OnNextAction;
	BtnVoice = function (self)
		ChatMgr:OnSwitchNpcGuideVoice()
	end,
}


function tbPkMode:OnCreate()
	self.tbModeState = { Player.MODE_PEACE, Player.MODE_PK, Player.MODE_KILLER}
end

function tbPkMode:OnOpen()
	
	if Map:GetClassDesc(me.nMapTemplateId) ~= "fight" and not Ui:IsFightOpenBoxPk(me.nMapTemplateId) then
		return 0;
	end
	
	self.bShowSelect = false;
	self:Update()
end


function tbPkMode:Update(nPkMode)
	local nCurTime = GetTime()
	nPkMode = nPkMode or me.nPkMode
	for i, nState in ipairs(self.tbModeState) do
		if nState == nPkMode then
			if i ~= 1 then
				self.tbModeState[1], self.tbModeState[i] = self.tbModeState[i], self.tbModeState[1];
			end
			break;
		end
	end
	
	self.pPanel:SetActive("BtnMode2", self.bShowSelect);
	self.pPanel:SetActive("BtnMode3", self.bShowSelect);
	self.pPanel:SetActive("BtnTip", self.bShowSelect);

	for i, nState in pairs(self.tbModeState) do
		self.pPanel:Button_SetSprite("BtnMode"..i, tbMode[nState], 0)
		if nState == Player.MODE_PEACE and me.nPeaceCD then
			self.pPanel:Sprite_SetCDControl("Sprite"..i, (me.nPeaceCD - nCurTime), Player.CHANGE_PEACE_CD)
		else
			self.pPanel:Sprite_SetCDControl("Sprite"..i, 0, 0)
		end
	end
end

function tbPkMode:OnClickMode(szWnd)
	self.bShowSelect = not self.bShowSelect
	if not self.bShowSelect then
		local _, _, szIdx = string.find(szWnd, "BtnMode(%d)")
		local nIdx = tonumber(szIdx);
		if nIdx then
			local nMode = self.tbModeState[nIdx]
			if nMode == Player.MODE_PEACE and me.nPeaceCD and me.nPeaceCD > GetTime() then
				nMode = me.nMode;
			elseif nMode ~= me.nMode then
				RemoteServer.ApplyChangeMode(nMode);
			end
			self:Update(nMode);
			
		end
	else
		if Ui:GetRedPointState("NG_PkMode") then
			Ui:OpenWindow("PkModeGuide");
			Guide.tbNotifyGuide:ClearNotifyGuide("PkMode");
		end
		self:Update();
	end
end

tbPkMode.tbOnClick = {
	BtnMode1 = tbPkMode.OnClickMode,
	BtnMode2 = tbPkMode.OnClickMode,
	BtnMode3 = tbPkMode.OnClickMode,
	BtnMode4 = tbPkMode.OnClickMode,
	BtnTip = function (self)
		Ui:OpenWindow("PkModeGuide");
	end,
}

function tbPkMode:RegisterEvent()
	local tbRegEvent =
	{
		{	UiNotify.emNOTIFY_CHANGE_PK_MODE, 		self.Update, self},
	};

	return tbRegEvent;
end


