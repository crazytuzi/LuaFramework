local tbUi = Ui:CreateClass("NewYearTxtPanel");

function tbUi:OnOpen(tbRoleInfo, bUseGold)
    self.tbRoleInfo = tbRoleInfo
    self.pPanel:Toggle_SetChecked("Toggle1", bUseGold or false)

end

tbUi.tbOnClick = {};

tbUi.tbOnClick.BtnClose = function (self)
    Ui:CloseWindow(self.UI_NAME)
end

tbUi.tbOnClick.BtnCancel = function (self)
    Ui:CloseWindow(self.UI_NAME)
end

tbUi.tbOnClick.BtnConfirm = function (self)
    local szWord = self.pPanel:Label_GetText("WishTxt")
    if Lib:Utf8Len(szWord) > SendBless.szWordMaxLen then
        me.CenterMsg(string.format("输入内容最大%d字", SendBless.szWordMaxLen));
        return;
    end
    if ReplaceLimitWords(szWord) then
        me.CenterMsg("内容中含有敏感字符，请修改后重试");
        return;
    end

    local bUseGold = self.pPanel:Toggle_GetChecked("Toggle1")
    local fnYes = function ()
        SendBless:DoSendBless(self.tbRoleInfo.dwID, bUseGold, szWord)
    end
    if bUseGold then
        Ui:OpenWindow("MessageBox",
          string.format("消耗%d元宝进行特殊祝福，确定祝福吗？元宝祝福时，不消耗祝福次数。", SendBless.COST_GOLD),
         { {fnYes},{} },
         {"确定", "取消"});
    else
        fnYes();
    end
end

