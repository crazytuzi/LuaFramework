local tbUi = Ui:CreateClass("UseItemPop")

--[[
tbParam = {
    nTempId = 123,
    nCD = 123,  --default nil
    szAtlas = "", --default nil
    szSprite = "", --default  nil
}
]]
function tbUi:OnOpen(tbParam)
    local nItemTemplateId = tbParam.nTempId
    self.nItemTemplateId = nItemTemplateId
    self.nCD = tbParam.nCD

    self.BgSprite.pPanel:SetActive("SpFaction", false)
    self.BgSprite.pPanel:SetActive("CD", false)
    self.BgSprite.pPanel:SetActive("CDTime", false)
    self:RefreshCount()

    local szAtlas, szSprite = tbParam.szAtlas, tbParam.szSprite
    if not szAtlas or not szSprite then
        local _, nIcon = Item:GetItemTemplateShowInfo(nItemTemplateId, me.nFaction, me.nSex)
        szAtlas, szSprite = Item:GetIcon(nIcon)
    end
    self.BgSprite.pPanel:Sprite_SetSprite("SpRoleHead", szSprite, szAtlas)
    self.BgSprite.pPanel.OnTouchEvent = function()
        self:UseItem(nItemTemplateId)
    end
end

local nLastTryUse = 0
local nDelta = 1
function tbUi:UseItem(nItemTemplateId)
    local nNow = GetTime()
    if nNow-nLastTryUse<nDelta then
        return
    else
        nLastTryUse = nNow
    end
    
    local nCount, tbItems = me.GetItemCountInBags(nItemTemplateId)
    local pItem = tbItems[1]
    if nCount<=0 or not pItem then
        me.CenterMsg(self:GetErrorNone(nItemTemplateId))
        return
    end

    if self.BgSprite.pPanel:IsActive("CD") then
        return
    end

    if me.GetNpc().nShapeShiftNpcTID > 0 then
        return
    end 

    local nResult = me.GetNpc().CanChangeDoing(Npc.Doing.skill)
    if nResult==0 then
        AutoFight:Stop()
        return
    end

    RemoteServer.UseItem(pItem.dwId)
end

function tbUi:GetErrorNone(nItemTemplateId)
    if nItemTemplateId==Kin.MonsterNianDef.nFireworkId then
        return "背包中没有烟花！"
    end
    return "没有此道具"
end

function tbUi:RefreshCount()
    local nCount = me.GetItemCountInBags(self.nItemTemplateId)
    self.BgSprite.pPanel:Label_SetText("lbLevel", nCount)
end

function tbUi:OnItemCountChange()
    self:RefreshCount()
end

function tbUi:OnUseItem(nTemplateId, nId)
    if nTemplateId~=self.nItemTemplateId then
        return
    end

    local nCD = self.nCD
    if not nCD or nCD<=0 then
        return
    end

    self.BgSprite.pPanel:Sprite_SetCDControl("CD", nCD, nCD)
    self.BgSprite.pPanel:SetActive("CD", true)
end

function tbUi:RegisterEvent()
    local tbRegEvent = {
        {UiNotify.emNOTIFY_SYNC_ITEM, self.OnItemCountChange, self},
        {UiNotify.emNOTIFY_DEL_ITEM, self.OnItemCountChange, self},
        {UiNotify.emNOTIFY_ON_USE_ITEM, self.OnUseItem, self},
    }
    return tbRegEvent
end