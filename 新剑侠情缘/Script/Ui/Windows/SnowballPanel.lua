
Require("CommonScript/Activity/DaXueZhangDef.lua");

local tbDaXueZhang = Activity.tbDaXueZhang;
local tbDef = tbDaXueZhang.tbDef;

local tbUi = Ui:CreateClass("SnowballPanel");
tbUi.tbOnClick = {};
tbUi.nActivityID = 43; --活动的ID

function tbUi.tbOnClick:BtnClose()
    Ui:CloseWindow("SnowballPanel");
end

function tbUi.tbOnClick:BtnTip()
    Ui:OnHelpClicked("DaXueZhang");
end

function tbUi.tbOnClick:BtnTeam()
    if not TeamMgr:HasTeam() then
        me.CenterMsg("请组队报名");
        return;
    end

    RemoteServer.ApplyDaXueZhang();
end

function tbUi.tbOnClick:BtnSingle()
    if TeamMgr:HasTeam() then
        me.CenterMsg("请单人报名");
        return;
    end

    RemoteServer.ApplyDaXueZhang();
end

function tbUi:OnOpen()
    self:UpdateInfo();
end

function tbUi:UpdateInfo()
    self.pPanel:SetActive("BtnTeam", not tbDef.bSingleJoin)
    self.pPanel:Label_SetText("TipTxtDesc", tbDef.szPanelContent);
    local nJoinCount = tbDaXueZhang:GetDXZJoinCount(me);
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
    Ui:CloseWindow("SnowballPanel");
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        {UiNotify.emNOTIFY_MAP_LEAVE,           self.OnLeaveMap},
    };

    return tbRegEvent;
end    