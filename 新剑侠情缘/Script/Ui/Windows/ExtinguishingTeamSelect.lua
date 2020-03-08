local tbUi = Ui:CreateClass("ExtinguishingTeamSelect");
local tbWarOfIceAndFire = Activity.tbWarOfIceAndFire;

tbUi.tbOnClick = {};
function tbUi.tbOnClick:FireBTN()
    self.pPanel:SetActive("Water2", false);
    self.pPanel:SetActive("Water", true);
    self.pPanel:SetActive("Fire", false);
    self.pPanel:SetActive("Fire2", true);
    if self.nMyChoose ~= 1 then
    	RemoteServer.WarOfIceAndFireRequestInst("ChooseRole", 1);
    	self.nMyChoose = 1;
    end
end

function tbUi.tbOnClick:WaterBTN()
    self.pPanel:SetActive("Fire2", false);
    self.pPanel:SetActive("Fire", true);
    self.pPanel:SetActive("Water", false);
    self.pPanel:SetActive("Water2", true);
    if self.nMyChoose ~= 2 then
    	RemoteServer.WarOfIceAndFireRequestInst("ChooseRole", 2);
    	self.nMyChoose = 2;
    end
end

function tbUi:OnOpen()
	self:Update();
	self.nLeftTime = tbWarOfIceAndFire.nSelectWaitTime - 1;
	self.nTimer = Timer:Register(Env.GAME_FPS , self.TimerUpdate, self)
	self.nMyChoose = 2;
end

function tbUi:TimerUpdate()
	if not self or not self.nLeftTime then 
		return false 
	end;
	if not self.pPanel then 
		return false 
	end;
	local szTips = string.format("请选择你在灭火大作战中的阵营：%d秒", self.nLeftTime or 0);
	self.pPanel:Label_SetText("Time", szTips);
	if self.nLeftTime < 1 then
		self.nLeftTime = nil;
		Ui:CloseWindow(self.UI_NAME)
		return true;
	end
	self.nLeftTime = self.nLeftTime - 1;
	return true
end

function tbUi:Update()
	local szTips = string.format("请选择你在灭火大作战中的阵营：%d秒", tbWarOfIceAndFire.nSelectWaitTime or 0);
	self.pPanel:Label_SetText("Time", szTips);

	local szTextIce = string.format("%d人", tbWarOfIceAndFire.nGameMemberCount or 0);
	local szTextFire = "0人";
	self.pPanel:Label_SetText("Member1", szTextIce);
	self.pPanel:Label_SetText("Member2", szTextFire);

    self.pPanel:SetActive("Fire2", false);
    self.pPanel:SetActive("Fire", true);
    self.pPanel:SetActive("Water", false);
    self.pPanel:SetActive("Water2", true);
end

function tbUi:OnUpdateChooseRoleNum()
	local nIceChooseNum, nFireChooseNum = tbWarOfIceAndFire:GetChooseRoleNum();
	local szTextIce = string.format("%d人", nIceChooseNum or 0);
	local szTextFire = string.format("%d人", nFireChooseNum or 0);
	self.pPanel:Label_SetText("Member1", szTextIce);
	self.pPanel:Label_SetText("Member2", szTextFire);
end

function tbUi:OnClose()
	self.nLeftTime = nil;
	if self.nTimer then
		Timer:Close(self.nTimer)
		self.nTimer = nil;
	end
end

function tbUi:OnLeaveMap()
    Ui:CloseWindow("ExtinguishingPanel");
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        {UiNotify.emNOTIFY_MAP_LEAVE,           self.OnLeaveMap},
        {UiNotify.emNOTIFY_SYNC_WAROFFIREANDICE_CHOOSE_ROLE_NUM, self.OnUpdateChooseRoleNum},
    };

    return tbRegEvent;
end    
