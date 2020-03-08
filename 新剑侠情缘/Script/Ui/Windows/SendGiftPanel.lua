local tbUi = Ui:CreateClass("SendGiftPanel")

function tbUi:RegisterEvent()
    return {{ UiNotify.emNOTIFY_LEVELUP_ASK4HELP_RSP, self.OnAsk4HelpRsp, self }}
end

local fnUpdateFriendItem = function (itemObj, tbPlayerInfo)
    local nImityLv = FriendShip:GetFriendImityLevel(tbPlayerInfo.dwID, me.dwID) or 0
    itemObj.pPanel:Label_SetText("Level", "亲密度等级：" .. nImityLv)
    itemObj.pPanel:Label_SetText("lbRoleName", tbPlayerInfo.szName)

    local bCon = TeacherStudent:_IsConnected(me, tbPlayerInfo)
    itemObj.pPanel:SetActive("Relationship", bCon or false)

    local szHead, szAtlas = PlayerPortrait:GetSmallIcon(tbPlayerInfo.nPortrait)
    itemObj.pPanel:Sprite_SetSprite("SpRoleHead", szHead, szAtlas)
    itemObj.pPanel:Label_SetText("lbLevel", tbPlayerInfo.nLevel)
    itemObj.pPanel:Sprite_SetSprite("SpFaction", Faction:GetIcon(tbPlayerInfo.nFaction))
end

tbUi.tbUpdate = {
    Ask4Help = function (self)
        self.pPanel:Label_SetText("Title", "求助好友")
        self.pPanel:SetActive("Label", false)
        local tbCanHelp = DirectLevelUp:GetCanHelpMeList() or {}
        local fnSetItem = function(itemObj, nIdx)
            local tbPlayerInfo = tbCanHelp[nIdx]
            fnUpdateFriendItem(itemObj, tbPlayerInfo)

            local bHadApply = DirectLevelUp:GetApplyFlag(tbPlayerInfo.dwID)
            itemObj.pPanel:SetActive("BtnGive", not bHadApply)
            itemObj.pPanel:Label_SetText("Label", bHadApply and "已求助" or "求助")
            itemObj.BtnGive.pPanel.OnTouchEvent = function ()
                RemoteServer.TryCallDirectLevelUpFunc("Ask4Help", tbPlayerInfo.dwID)
            end
        end
        self.ScrollView:Update(#tbCanHelp, fnSetItem)
        self.pPanel:SetActive("Tip", #tbCanHelp == 0)
    end,

    HelpFriend = function (self)
	--[[
        self.pPanel:Label_SetText("Title", "赠直升丹")
        self.pPanel:SetActive("Label", true)
        local nLastHelp = DirectLevelUp:GetLastHelpTimes()
        self.pPanel:Label_SetText("Label", "剩余赠送次数:" .. nLastHelp)
        local tbAsk4Help = DirectLevelUp:GetAsk4HelpList()
        local fnSetItem = function(itemObj, nIdx)
            local tbPlayerInfo = tbAsk4Help[nIdx]
            fnUpdateFriendItem(itemObj, tbPlayerInfo)

            itemObj.pPanel:Label_SetText("Label", "协助")
            itemObj.pPanel:SetActive("BtnGive", true)
            itemObj.BtnGive.pPanel.OnTouchEvent = function ()
                local fnHelp = function ()
                    RemoteServer.TryCallDirectLevelUpFunc("TrySendGift", tbPlayerInfo.dwID)
                end

                me.MsgBox(string.format("只能赠送给一名好友，是否确定赠送给[FFFE0D]%s[-]？", tbPlayerInfo.szName), {{"确定", fnHelp}, {"取消"}})
            end
        end
        self.ScrollView:Update(#tbAsk4Help, fnSetItem)
        self.pPanel:SetActive("Tip", #tbAsk4Help == 0)
        Ui:ClearRedPointNotify("Activity_BuyLevelUp")
		]]
    end,
}

function tbUi:OnOpenEnd(szType, tbData)
    self.szType = szType
    self.tbData = tbData
    local fnUpdate = self.tbUpdate[szType]
    if not fnUpdate then
        return
    end

    fnUpdate(self)
end

function tbUi:Update()
    local fnUpdate = self.tbUpdate[self.szType]
    if not fnUpdate then
        return
    end

    fnUpdate(self)
end

function tbUi:OnAsk4HelpRsp()
    self:Update()
end

tbUi.tbOnClick = {
    BtnClose = function (self)
        Ui:CloseWindow(self.UI_NAME)
    end,
}