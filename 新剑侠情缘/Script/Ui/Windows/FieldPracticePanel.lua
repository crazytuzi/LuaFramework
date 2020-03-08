
local tbUi = Ui:CreateClass("FieldPracticePanel");

tbUi.tbOnClick = {};

function tbUi.tbOnClick:BtnClose()
    Ui:CloseWindow(self.UI_NAME);
end

function tbUi.tbOnClick:BtnPractice()
    RemoteServer.OpenXiuLianTime();
end

function tbUi:OnOpen()
    self:UpdateInfo();
    self:CloseTimer();
    self.nUpdateTimer = Timer:Register(Env.GAME_FPS, self.UpdateInfo, self);
end

function tbUi:CloseTimer()
    if self.nUpdateTimer then
        Timer:Close(self.nUpdateTimer);
        self.nUpdateTimer = nil;
    end    
end

function tbUi:OnClose()
    self:CloseTimer();
end

function tbUi:UpdateInfo()
    local tbDef = XiuLian.tbDef;
    local nResidueTime = XiuLian:GetXiuLianResidueTime(me);
    self.pPanel:Label_SetText("RemainingTime", Lib:TimeDesc(nResidueTime));

    local nCurXiuLianTime = XiuLian:GetCurXiuLianTime(me);
    self.pPanel:Label_SetText("AlreadyUsedTime", Lib:TimeDesc(nCurXiuLianTime));

    local szMsg = "开启30分钟修炼时间";
    local bRet = XiuLian:CanBuyXiuLianDan(me);
    if bRet then
        szMsg = "购买修炼丹";
        local nCount = me.GetItemCountInBags(tbDef.nXiuLianDanID);
        if nCount > 0 then
            szMsg = "使用修炼丹";
        end
    end

    self.pPanel:Label_SetText("LabelPractice", szMsg);    
    return true;
end

