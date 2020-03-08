Require("CommonScript/Activity/WarOfIceAndFire.lua");

local tbWarOfIceAndFire = Activity.tbWarOfIceAndFire;

local tbUi = Ui:CreateClass("ExtinguishingPanel");
tbUi.tbOnClick = {};
tbUi.nActivityID = 60; --活动的ID

function tbUi.tbOnClick:BtnClose()
    Ui:CloseWindow("ExtinguishingPanel");
end

function tbUi.tbOnClick:BtnTip()
    Ui:OnHelpClicked("WarOfIceAndFire");
end

function tbUi.tbOnClick:BtnSolo()
    if TeamMgr:HasTeam() then
        me.CenterMsg("请单人报名");
        return;
    end
    RemoteServer.ApplyWarOfIceAndFire();
end

function tbUi:OnOpen()
    self:UpdateInfo();
end

function tbUi:UpdateInfo()
    self.pPanel:SetActive("BtnTeamChallenge", false)
    self.pPanel:Label_SetText("IntroducesTxt", tbWarOfIceAndFire.szPanelContent);
    local nJoinCount = tbWarOfIceAndFire:GetJoinCount(me);
    self.pPanel:Label_SetText("RemainTime", string.format("%s", nJoinCount));
    self:UpdateAward();
end

function tbUi:UpdateAward()
    local tbRewards = Calendar:GetActivityReward(tbUi.nActivityID);
    for nI = 1, 6 do
        local tbReward = tbRewards[nI];
        self.pPanel:SetActive("itemframe"..nI, tbReward ~= nil);
        if tbReward then
            self["itemframe" .. nI]:SetGenericItem(tbReward)
            self["itemframe"..nI].fnClick = self["itemframe"..nI].DefaultClick
        end
    end        
end

function tbUi:OnLeaveMap()
    Ui:CloseWindow("ExtinguishingPanel");
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        {UiNotify.emNOTIFY_MAP_LEAVE,           self.OnLeaveMap},
    };

    return tbRegEvent;
end    