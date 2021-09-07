-- 作者:jia
-- 5/30/2017 3:03:51 PM
-- 功能:活动排行榜界面

CampaignRankPanel = CampaignRankPanel or BaseClass(BasePanel)
function CampaignRankPanel:__init(parent, rankType, campaignId, mainWin,isInitTime)
    self.isInitTime = isInitTime or false
    self.mainWin = mainWin or nil
    self.parent = parent
    self.rankType = rankType
    self.campaignId = campaignId
    self.resList = {
        { file = AssetConfig.intimacypanel, type = AssetType.Main }
        ,{ file = AssetConfig.may_textures, type = AssetType.Dep }
        , {file = AssetConfig.bible_textures, type = AssetType.Dep}
        ,{ file = AssetConfig.zone_textures, type = AssetType.Dep }
        ,{ file = AssetConfig.bg_campaignrankbg, type = AssetType.Main }
    }
    self.OnOpenEvent:Add( function() self:OnOpen() end)
    self.OnHideEvent:Add( function() self:OnHide() end)
    self.hasInit = false
    self.rankItemlist = { }
    self.rewardItemlist = { }
    self.BeginTime = 0
    self.EndTime = 0
    self.CampaignData = nil
    self.UpdateRankFun =
    function(rankType)
        if self.rankType ~= rankType then
            return
        end
        self:UpdateRank()
        self:UpdateMyRank()
    end
    self.UpdateMyRankFun = function(rankType)
        if self.rankType ~= rankType then
            return
        end
        self:UpdateMyRank()
        self:UpdateMyReward()
    end
    self.UpdateMyRewardFun = function(rankType)
        if self.rankType ~= rankType then
            return
        end
        self:UpdateMyReward()
    end
    self.UpdataTimeHandler = function(data)
        self:OnCampaignTimeHandler(data)
    end
    self:InitHandler()
end

function CampaignRankPanel:__delete()
    self.OnHideEvent:Fire()
    self:RemoveHandler()
    if self.timer ~= nil then
        LuaTimer.Delete(self.timer)
        self.timer = nil
    end
    if self.rewardItemlist ~= nil then
        for _, rankItem in pairs(self.rewardItemlist) do
            rankItem:DeleteMe()
            rankItem = nil
        end
        self.rewardItemlis = nil
    end

    if self.rankItemlist ~= nil then
        for _, item in pairs(self.rankItemlist) do
            item:DeleteMe()
            item = nil
        end
        self.rankItemlist = nil
    end

    if WorldLevManager.Instance.model.rankPanel ~= nil then
        WorldLevManager.Instance.model.rankPanel:DeleteMe()
        WorldLevManager.Instance.model.rankPanel = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function CampaignRankPanel:OnHide()
    if WorldLevManager.Instance.model.rankPanel ~= nil then
        WorldLevManager.Instance.model.rankPanel:Hiden()
    end
end

function CampaignRankPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function CampaignRankPanel:OnOpen()
    self.CampaignData = DataCampaign.data_list[self.campaignId]
    if self.CampaignData == nil then
        return
    end
    if self.isInitTime == true then
        self:InitTime()
    end
    WorldLevManager.Instance.CurRankType = self.rankType
    WorldLevManager.Instance:Send17868(self.campaignId)
    self.TxtCampTime.text = ""
    self:UpdateRewards()
end

function CampaignRankPanel:OnCampaignTimeHandler(data)
    if self.isInitTime ~= true then
        if data.id == self.campaignId then
            self.BeginTime = data.start_time
            self.EndTime = data.end_time
            if self.timer ~= nil then
                LuaTimer.Delete(self.timer)
            end
            self.timer = LuaTimer.Add(0, 1000, function() self:ShowTime() end)
        end
    end

end

function CampaignRankPanel:InitTime()
    local timeData = DataCampaign.data_list[self.campaignId].cli_start_time
    self.BeginTime = tonumber(os.time{year = timeData[1][1], month = timeData[1][2], day = timeData[1][3], hour = timeData[1][4], min = timeData[1][5], sec = timeData[1][6]})
    timeData =  DataCampaign.data_list[self.campaignId].cli_end_time
    self.EndTime = tonumber(os.time{year = timeData[1][1], month = timeData[1][2], day = timeData[1][3], hour = timeData[1][4], min = timeData[1][5], sec = timeData[1][6]})
    if self.timer ~= nil then
        LuaTimer.Delete(self.timer)
    end
    self.timer = LuaTimer.Add(0, 1000, function() self:ShowTime() end)
end

function CampaignRankPanel:InitHandler()
    EventMgr.Instance:AddListener(event_name.campaign_rank_update, self.UpdateRankFun)
    EventMgr.Instance:AddListener(event_name.campaign_rank_my_data_update, self.UpdateMyRankFun)
    EventMgr.Instance:AddListener(event_name.campaign_rank_reward_data_update, self.UpdateMyRewardFun)
    EventMgr.Instance:AddListener(event_name.campaign_rank_time_update, self.UpdataTimeHandler)
end

function CampaignRankPanel:RemoveHandler()
    EventMgr.Instance:RemoveListener(event_name.campaign_rank_update, self.UpdateRankFun)
    EventMgr.Instance:RemoveListener(event_name.campaign_rank_my_data_update, self.UpdateMyRankFun)
    EventMgr.Instance:RemoveListener(event_name.campaign_rank_reward_data_update, self.UpdateMyRewardFun)
    EventMgr.Instance:RemoveListener(event_name.campaign_rank_time_update, self.UpdataTimeHandler)
end

function CampaignRankPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.intimacypanel))
    self.gameObject.name = "CampaignRankPanel"

    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero
    self.BigBg = self.transform:Find("BigBg")

    self:SetBigBg()

    self.TxtCampTime = self.transform:Find("Top/TxtCampTime"):GetComponent(Text)
    self.TxtCampTime.text = ""
    self.BaseRank = self.transform:Find("Top/RankItem").gameObject
    self.BaseRank:SetActive(false)
    self.rankItemlist = { }
    for index = 1, 3 do
        local item = IntimacyRankItem.New(self.BaseRank, index, self.rankType)
        item.ImgRankIndex.sprite = self.assetWrapper:GetSprite(AssetConfig.may_textures, "intimacy_rank_index" .. index)
        if self.rankType ~= CampaignEumn.CampaignRankType.Intimacy then
            item.ImgRankBg.sprite = self.assetWrapper:GetSprite(AssetConfig.may_textures, "campaignrankindexbg")
        else
            item.ImgRankBg.sprite = self.assetWrapper:GetSprite(AssetConfig.may_textures, "intimacy_rank_bg")
        end
        table.insert(self.rankItemlist, item)
    end
    self.Center = self.transform:Find("Center")
    self.TxtMyIntimacy = self.transform:Find("Center/BtnLook/TxtMyIntimacy"):GetComponent(Text)
    self.BtnLook = self.transform:Find("Center/BtnLook"):GetComponent(Button)
    local myIntimacy = WorldLevManager.Instance:GetMyValueByType(self.rankType)
    local txt, txt2, txt3 = self:GetTextDesc(myIntimacy);
    self.BtnLook.onClick:AddListener(
    function()
        local myRankData = WorldLevManager.Instance.MyRankData[self.rankType];
        if myRankData == nil then
            return
        end
        local TipsData = { txt2 };
        TipsManager.Instance:ShowText( { gameObject = self.BtnLook.gameObject, itemData = TipsData })
    end )

    self.TxtMyRank = self.transform:Find("Center/TxtMyRank"):GetComponent(Text)
    self.BtnRank = self.transform:Find("Center/BtnRank"):GetComponent(Button)
    self.BtnRank.onClick:AddListener(
    function()
        WorldLevManager.Instance:Send17858(self.rankType)
        if self.mainWin ~= nil then
                self.mainWin.rankPanel = ClosenessRank.New(self.mainWin.gameObject)
                self.mainWin.rankPanel:Show(self.rankType)
        else
            if WorldLevManager.Instance.model.rankPanel == nil then
                WorldLevManager.Instance.model.rankPanel = ClosenessRank.New(WorldLevManager.Instance.model.mainWin.gameObject)
            end
            WorldLevManager.Instance.model.rankPanel:Show()
        end



    end )

    self.ItemCon = self.transform:Find("Bottom/ItemMaskCon/ScrollLayer/ItemCon")
    self.transform:Find("Bottom/ItemMaskCon/ScrollLayer"):GetComponent(ScrollRect).onValueChanged:AddListener( function() self:OnValueChange() end)

    self.BaseItem = self.transform:Find("Bottom/ItemMaskCon/ScrollLayer/ItemCon/RewardItem").gameObject

    self.TxtTips = self.transform:Find("Bottom/TxtTips"):GetComponent(Text)
    self.ImgIntimacy = self.transform:Find("Center/ImgIntimacy"):GetComponent(Image)
    self.TxtTips.text = txt3
    self.hasInit = true
    self:UpdateIcon()
    self:UpdateRewards()
    self:UpdateRank()
    self:UpdateMyRank()
    self:OnValueChange()
end

function CampaignRankPanel:SetBigBg()
    if self.rankType == CampaignEumn.CampaignRankType.ConSume then
        self.bg = AssetConfig.bg_campaignrankbg_consume
    else
        self.bg = AssetConfig.bg_campaignrankbg
    end

    local bigbg = GameObject.Instantiate(self:GetPrefab(self.bg))
    bigbg.gameObject.transform.localPosition = Vector3(1, -2, 0)
    bigbg.gameObject.transform.localScale = Vector3(1, 1, 1)
    UIUtils.AddBigbg(self.BigBg, bigbg)
end

function CampaignRankPanel:UpdateIcon()
    local iconname = "campaignrankicon"
    if self.rankType == CampaignEumn.CampaignRankType.ConSume then
        self.ImgIntimacy.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets90002")
    else
        self.ImgIntimacy.sprite = self.assetWrapper:GetSprite(AssetConfig.may_textures, "campaignrankicon")
    end
    
end

function CampaignRankPanel:UpdateRewards()
    if not self.hasInit then
        return
    end
    self.CampaignData = DataCampaign.data_list[self.campaignId]
    local rankRewardData = WorldLevManager.Instance:GetRankTmpByType(self.rankType)
    local index = 0
    for _, rankData in ipairs(rankRewardData) do
        index = index + 1
        local item = self.rewardItemlist[index]
        if item == nil then
            item = CampaignRankRewardItem.New(self.BaseItem, index, true, self.rankType)
            table.insert(self.rewardItemlist, item)
        end
        item.CampaignData = self.CampaignData
        item:SetData(rankData)
    end
    local rewardIndex = 0;
    local myIntimacy = WorldLevManager.Instance:GetMyValueByType(self.rankType)
    local personalData = WorldLevManager.Instance:GetPersonalTmpByType(self.rankType)
    for _, personal in ipairs(personalData) do
        index = index + 1
        local item = self.rewardItemlist[index]
        if item == nil then
            item = CampaignRankRewardItem.New(self.BaseItem, index, false, self.rankType)
            item.CampaignData = self.CampaignData
            table.insert(self.rewardItemlist, item)
        end
        if rewardIndex == 0 and myIntimacy > 0 then
            if myIntimacy >= personal.num then
                local isGet = WorldLevManager.Instance:CheckIsGetRewardByType(self.rankType, personal.num);
                if not isGet then
                    rewardIndex = index
                end
            end
        end
        item:SetData(personal)
    end
    local newH = 85 * index - 5
    local rect = self.ItemCon.transform:GetComponent(RectTransform)
    rect.sizeDelta = Vector2(557, newH)
    rect.anchoredPosition = Vector2(0, 85 *(rewardIndex - 1))
    self:OnValueChange();
end

function CampaignRankPanel:UpdateRank()
    if not self.hasInit then
        return
    end
    local rankData = WorldLevManager.Instance:GetLenRankDataByType(self.rankType, 3)
    if rankData == nil then
        return
    end
    for index = 1, 3 do
        local rankItem = self.rankItemlist[index]
        rankItem:SetData(rankData[index])
        if self.rankType ~= CampaignEumn.CampaignRankType.Intimacy then
            rankItem.ImgRankBg.sprite = self.assetWrapper:GetSprite(AssetConfig.may_textures, "campaignrankindexbg")
        else
            rankItem.ImgRankBg.sprite = self.assetWrapper:GetSprite(AssetConfig.may_textures, "intimacy_rank_bg")
        end
    end
    self:UpdateMyRank()
end

function CampaignRankPanel:UpdateMyRank()
    if not self.hasInit then
        return
    end
    local myIntimacy = WorldLevManager.Instance:GetMyValueByType(self.rankType)
    local txt, txt2, txt3 = self:GetTextDesc(myIntimacy);
    self.TxtMyIntimacy.text = txt
    local myRank = WorldLevManager.Instance:GetMyRankIndexByType(self.rankType);
    if myRank > 0 then
        self.TxtMyRank.text = string.format(TI18N("我的排行：<color='#2fc823'>%s</color>"), myRank)
    else
        self.TxtMyRank.text = string.format(TI18N("我的排行：<color='#2fc823'>未上榜</color>"))
    end
end
function CampaignRankPanel:UpdateMyReward()
    for _, item in ipairs(self.rewardItemlist) do
        item:UpdatePersonalData()
    end
end

function CampaignRankPanel:ShowTime()
    local timeStr = ""
    local baseTime = BaseUtils.BASE_TIME
    local endTime = 0
    if self.BeginTime < baseTime and baseTime < self.EndTime then
        timeStr = BaseUtils.formate_time_gap(self.EndTime - baseTime, "", 1, BaseUtils.time_formate.DAY)
        self.TxtCampTime.text = string.format(TI18N("活动剩余时间：<color='#e8faff'>%s</color>"), timeStr)
    else
        self.TxtCampTime.text = TI18N("活动已结束")
        LuaTimer.Delete(self.timer)
        self.timer = nil
    end
end

function CampaignRankPanel:GetTextDesc(myVaue)
    local str, str2, str3 = nil
    if self.rankType == CampaignEumn.CampaignRankType.Constellation then
        str = string.format(TI18N("我的积分：%s"), myVaue)
    elseif self.rankType == CampaignEumn.CampaignRankType.Intimacy then
        str = string.format(TI18N("我的亲密度：%s"), myVaue)
    elseif self.rankType == CampaignEumn.CampaignRankType.Pet then
        str = string.format(TI18N("我的评分：%s"), myVaue)
    elseif self.rankType == CampaignEumn.CampaignRankType.PlayerKill then
        if myVaue <= 0 then
            myVaue = 1
        end
        local baseData = DataRencounter.data_info[myVaue]
        local stars = WorldLevManager.Instance:GetMyPlayerStarts(self.rankType);
        str = string.format(TI18N("我的战绩：%s%s★"), baseData.title, stars)
    elseif self.rankType == CampaignEumn.CampaignRankType.Weapon then
        str = string.format(TI18N("我的评分：%s"), myVaue)
    elseif self.rankType == CampaignEumn.CampaignRankType.Weapon2 then
        str = string.format(TI18N("我的评分：%s"), myVaue)
    elseif self.rankType == CampaignEumn.CampaignRankType.WorldChampion then
        if myVaue <= 0 then
            myVaue = 1
        end
        local baseData = DataTournament.data_list[myVaue]
        str = string.format(TI18N("我的战绩：%s"), baseData.name)
    elseif self.rankType == CampaignEumn.CampaignRankType.Wing then
        str = string.format(TI18N("我的评分：%s"), myVaue)
    elseif self.rankType == CampaignEumn.CampaignRankType.Treasure then
        str = string.format(TI18N("我的积分：%s"), myVaue)
    elseif self.rankType == CampaignEumn.CampaignRankType.ConSume then
        str = string.format(TI18N("我的消费额：%s"), myVaue)
    else
        str = string.format(TI18N("我的评分：%s"), myVaue)
    end
    -- str =  DataCampaignRank.data_rank_list[self.rankType].title_tips
    str2 = DataCampaignRank.data_rank_list[self.rankType].show_tips
    str3 = DataCampaignRank.data_rank_list[self.rankType].panel_tips
    str = string.format(str, myVaue);
    return str, str2, str3
end

function CampaignRankPanel:OnValueChange()
    local w = self.ItemCon.sizeDelta.y
    local y = self.ItemCon.anchoredPosition.y
    for _, tab in ipairs(self.rewardItemlist) do
        local tr = tab.transform
        if (- y + 1 > tr.anchoredPosition.y) and(tr.anchoredPosition.y > - y - 200 + 70) then
            tab:ShowEffect(true)
        else
            tab:ShowEffect(false)
        end
    end
end