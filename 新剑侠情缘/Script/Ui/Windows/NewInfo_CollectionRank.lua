local function UpdateRank(pPanel, nCollectionId, tbData)
    for i = 1, 10 do
        local tbRankInfo = tbData[i]
        pPanel:SetActive("CardCollectionInfo" .. i, tbRankInfo or false)
        if tbRankInfo then
            pPanel:Label_SetText("CardCollectionRanking" .. i, i)
            pPanel:Label_SetText("CardCollectionName" .. i, tbRankInfo.szName)
            pPanel:Label_SetText("CardCollectionFamily" .. i, tbRankInfo.szKin or "-")
            pPanel:Label_SetText("CardCollectionRare" .. i, tbRankInfo.nRare or "-")
            pPanel:Label_SetText("CardCollectionCompletion" .. i, tbRankInfo.nCompletion)
        end
    end
end

local tbUi = Ui:CreateClass("NewInfo_CollectionRank")
function tbUi:OnOpen(tbData)
    local nMonth = os.date("%m", GetTime())
    if nMonth == 1 then
        nMonth = 12
    else
        nMonth = nMonth - 1
    end
    local szTitle = string.format("%d月凌绝峰收集活动优秀榜\n凌绝峰卡片收集活动结束了，以下玩家表现很好，排在前10名：", nMonth)
    self.pPanel:Label_SetText("Content", szTitle)

    tbData = tbData or {}
    table.sort(tbData, function (a, b) return a.nRank < b.nRank end)
    UpdateRank(self.pPanel, CollectionSystem.RANDOMFUBEN_ID, tbData)
end

local tbUi = Ui:CreateClass("NewInfo_JXSHRank")
function tbUi:OnOpen(tbData)
    self.pPanel:Label_SetText("Content", "国庆“锦绣山河”收集活动结束了，以下玩家表现很好，排在前10名：")

    tbData = tbData or {}
    table.sort(tbData, function (a, b) return a.nRank < b.nRank end)
    UpdateRank(self.pPanel, CollectionSystem.JINXIUSHANHE, tbData)
end