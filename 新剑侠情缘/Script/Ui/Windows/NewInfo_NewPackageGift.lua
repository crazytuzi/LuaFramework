local tbUi = Ui:CreateClass("NewInfo_NewPackageGift")

function tbUi:OnOpen(tbData)
    self.pPanel:Label_SetText("ActiveDetails", "活动内容\n    尊敬的侠士，恭喜你成功下载最新版本的游戏，希望它能给您带来更好的游戏体验，也希望您可以继续支持我们。武林，因你而精彩！\n    [FFFE0D]重要提示：每个账号下有且仅有一个角色能够领奖，且需≥20级[-]")
    local tbAward = NewPackageGift.tbAward or {}
    for i = 1, 3 do
        local tb = tbAward[i]
        self.pPanel:SetActive("Item" .. i, tb or false)
        self.pPanel:SetActive("ItemName" .. i, tb or false)
        if tb then
            self["Item" .. i]:SetGenericItem(tb)
            self["Item" .. i].fnClick = self["Item" .. i].DefaultClick

            local tbAwardDesc = Lib:GetAwardDesCount({tb}, me)
            local tbShowAward = tbAwardDesc[1]
            self.pPanel:Label_SetText("ItemName" .. i, tbShowAward.szName or "")
        end
    end

    self.pPanel:SetActive("BtnInfo", NewPackageGift:CheckCanGain())
end

function tbUi:TryGain()
    local nVersion = NewPackageGift:GetVersion()
    local nCurVersion = math.floor(GAME_VERSION / 100000)
    if nVersion and nVersion == nCurVersion then
        RemoteServer.TryGainNewPackageGift(nCurVersion)
        self.pPanel:SetActive("BtnInfo", false)
    end
end

tbUi.tbOnClick = {
    BtnInfo = function (self)
        me.MsgBox("每个账号下有且仅有一个角色能够领奖，是否确认用当前角色领取？", {{"领取", function () self:TryGain() end, bLight = true}, {"取消"}})
    end
}