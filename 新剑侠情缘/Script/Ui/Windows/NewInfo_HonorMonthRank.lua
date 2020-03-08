Require("Script/Ui/Windows/AthleticsHonorPanel.lua")
local tbUi = Ui:CreateClass("NewInfo_HonorMonthRank")
local tbMainUi = Ui:CreateClass("AthleticsHonor")
tbUi.tbActPlatnumIcon = {}
for _, szAct in ipairs(tbMainUi.tbActList) do
    tbUi.tbActPlatnumIcon[szAct] = tbMainUi.tbAthleticsAct[szAct].tbDivisionIcon[#Calendar.tbDivisionKey]
end

function tbUi:OnOpen(tbData)
    local fn = function (itemObj, nIdx)
        local tbPlayerData = tbData.tbList[nIdx]
        itemObj.Button.pPanel:Label_SetText("Name", tbPlayerData.szName)
        itemObj.Button.pPanel:Label_SetText("FamilyName", tbData.tbKinName[tbPlayerData.nKinId] or "")
        local nHonorLevel = tbPlayerData.nHonorLevel
        itemObj.Button.pPanel:SetActive("PlayerTitle", nHonorLevel and nHonorLevel > 0)
        if nHonorLevel and nHonorLevel > 0 then
            local ImgPrefix, Atlas = Player:GetHonorImgPrefix(nHonorLevel)
            itemObj.Button.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas);
        end
        local tbPlatnumAct = {}
        local tbGetAct = Calendar:Act2Number(tbPlayerData.nPlatnumAct)
        for _, szAct in ipairs(tbGetAct) do
            table.insert(tbPlatnumAct, szAct)
        end
        for i = 1, #tbMainUi.tbActList do
            local szAct = tbPlatnumAct[i]
            itemObj.Button.pPanel:SetActive("NameIcon" .. i, szAct or false)
            if szAct then
                itemObj.Button.pPanel:Sprite_SetSprite("NameIcon" .. i, self.tbActPlatnumIcon[szAct])
            end
        end
        local fnOpenRightPopup = function ()
            Ui:OpenWindowAtPos("RightPopup", 160, -90, "RankView",
                        {dwRoleId = tbPlayerData.nPlayerId, szName = tbPlayerData.szName, dwKinId = 0})
        end
        itemObj.Button.pPanel.OnTouchEvent = fnOpenRightPopup
    end
    self.ScrollView:Update(#tbData.tbList, fn)
end