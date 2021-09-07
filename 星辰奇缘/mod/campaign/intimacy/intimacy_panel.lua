-- 作者:jia
-- 5/16/2017 2:03:51 PM
-- 功能:亲密度排行榜界面

IntiMacyPanel = IntiMacyPanel or BaseClass(BasePanel)
function IntiMacyPanel:__init(parent, model)
    self.model = model
    self.parent = parent
    self.resList = {
        { file = AssetConfig.intimacypanel, type = AssetType.Main }
        ,{ file = AssetConfig.intimacybg, type = AssetType.Main }
        ,{ file = AssetConfig.may_textures, type = AssetType.Dep }
         ,{ file = AssetConfig.zone_textures, type = AssetType.Dep }
         ,{ file = AssetConfig.bible_textures, type = AssetType.Dep }
    }
    self.OnOpenEvent:Add( function() self:OnOpen() end)
    self.OnHideEvent:Add( function() self:OnHide() end)
    self.hasInit = false
    self.rankItemlist = { }
    self.rewardItemlist = { }
    self.BeginTime = 0
    self.EndTime = 0
    self.UpdateRankFun =
    function()
        self:UpdateRank()
        self:UpdateMyRank()
    end
    self.UpdateMyRankFun = function()
        self:UpdateMyRank()
        self:UpdateMyReward()
    end
    self.UpdateMyRewardFun = function()
        self:UpdateMyReward()
    end
    self:InitHandler()
end

function IntiMacyPanel:__delete()
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

    if IntimacyManager.Instance.rankPanel ~= nil then
        IntimacyManager.Instance.rankPanel:DeleteMe()
        IntimacyManager.Instance.rankPanel = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function IntiMacyPanel:OnHide()
    if IntimacyManager.Instance.rankPanel ~= nil then
        IntimacyManager.Instance.rankPanel:Hiden()
    end
end

function IntiMacyPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function IntiMacyPanel:OnOpen()
    local beginTime = DataCampaign.data_list[self.campId].cli_start_time[1] or 0
    local endTime = DataCampaign.data_list[self.campId].cli_end_time[1] or 0

    self:InitCampaignTime(beginTime, endTime)
    self:UpdateRewards()
end

function IntiMacyPanel:InitCampaignTime(beginData, endData)
    self.BeginTime = tonumber(os.time { year = beginData[1], month = beginData[2], day = beginData[3], hour = beginData[4], min = beginData[5], sec = beginData[6] })
    self.EndTime = tonumber(os.time { year = endData[1], month = endData[2], day = endData[3], hour = endData[4], min = endData[5], sec = endData[6] })
    if self.timer ~= nil then
        LuaTimer.Delete(self.timer)
    end
    self.timer = LuaTimer.Add(0, 1000, function() self:ShowTime() end)
end

function IntiMacyPanel:InitHandler()
    EventMgr.Instance:AddListener(event_name.intimacy_update, self.UpdateRankFun)
    EventMgr.Instance:AddListener(event_name.intimacy_my_data_update, self.UpdateMyRankFun)
    EventMgr.Instance:AddListener(event_name.intimacy_reward_data_update, self.UpdateMyRewardFun)

end

function IntiMacyPanel:RemoveHandler()
    EventMgr.Instance:RemoveListener(event_name.intimacy_update, self.UpdateRankFun)
    EventMgr.Instance:RemoveListener(event_name.intimacy_my_data_update, self.UpdateMyRankFun)
    EventMgr.Instance:RemoveListener(event_name.intimacy_reward_data_update, self.UpdateMyRewardFun)
end

function IntiMacyPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.intimacypanel))
    self.gameObject.name = "IntiMacyPanel"

    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero
    self.BigBg = self.transform:Find("BigBg")

    local bigbg = GameObject.Instantiate(self:GetPrefab(AssetConfig.intimacybg))
    bigbg.gameObject.transform.localPosition = Vector3(1, -2, 0)
    bigbg.gameObject.transform.localScale = Vector3(1, 1, 1)
    UIUtils.AddBigbg(self.BigBg, bigbg)

    self.TxtCampTime = self.transform:Find("Top/TxtCampTime"):GetComponent(Text)
    self.BaseRank = self.transform:Find("Top/RankItem").gameObject
    self.BaseRank:SetActive(false)
    self.rankItemlist = { }
    for index = 1, 3 do
        local item = IntimacyRankItem.New(self.BaseRank, index)
        item.ImgRankIndex.sprite = self.assetWrapper:GetSprite(AssetConfig.may_textures, "intimacy_rank_index" .. index)
        table.insert(self.rankItemlist, item)
    end
    self.Center = self.transform:Find("Center")
    self.TxtMyIntimacy = self.transform:Find("Center/BtnLook/TxtMyIntimacy"):GetComponent(Text)
    self.BtnLook = self.transform:Find("Center/BtnLook"):GetComponent(Button)
    self.BtnLook.onClick:AddListener(
    function()
        local myRankData = IntimacyManager.Instance.MyRankData;
        if myRankData == nil then
            return
        end
        local myIntimacy = IntimacyManager.Instance:GetMyIntimacy();
        local TipsData = { string.format(TI18N("活动期间，我与<color='#24E8EE'>%s</color>的亲密度为%s"), myRankData.name2, myIntimacy) };

        if myIntimacy <= 0 then
            TipsData = { string.format(TI18N("活动期间，亲密度暂未增长，赶紧送花哦")) };
        end
        TipsManager.Instance:ShowText( { gameObject = self.BtnLook.gameObject, itemData = TipsData })
    end )

    self.TxtMyRank = self.transform:Find("Center/TxtMyRank"):GetComponent(Text)
    self.BtnRank = self.transform:Find("Center/BtnRank"):GetComponent(Button)
    self.BtnRank.onClick:AddListener(
    function()
        IntimacyManager.Instance:Send17858()
        if IntimacyManager.Instance.rankPanel == nil then
            IntimacyManager.Instance.rankPanel = ClosenessRank.New(self.model.mainWin.gameObject)
        end
        IntimacyManager.Instance.rankPanel:Show()
    end )

    self.ItemCon = self.transform:Find("Bottom/ItemMaskCon/ScrollLayer/ItemCon")
    self.BaseItem = self.transform:Find("Bottom/ItemMaskCon/ScrollLayer/ItemCon/RewardItem").gameObject
    self.ScrollLayer = self.transform:Find("Bottom/ItemMaskCon/ScrollLayer"):GetComponent(ScrollRect)
    self.ScrollLayer.onValueChanged:AddListener(function(value)
        self:OnRectScroll(value)
    end)

    self.TxtTips = self.transform:Find("Bottom/TxtTips"):GetComponent(Text)
    self.TxtTips.text = TI18N("活动期间累计亲密度达到要求即可领取<color='#2fc823'>丰厚大奖</color>")
    self.hasInit = true
    self:UpdateRewards()
    self:UpdateRank()
    self:UpdateMyRank()
end

function IntiMacyPanel:UpdateRewards()
    if not self.hasInit then
        return
    end

    local rankRewardData = IntimacyManager.Instance:GetIntimacyRankData();

    local index = 0
    for _, rankData in ipairs(rankRewardData) do
        index = index + 1
        local item = self.rewardItemlist[index]
        if item == nil then
            item = IntiMacyRewardItem.New(self.BaseItem, index, true)
            table.insert(self.rewardItemlist, item)
        end
        item:SetData(rankData)
    end
    local rewardIndex = 0;
    local myIntimacy = IntimacyManager.Instance:GetMyIntimacy();
    local personalData = IntimacyManager.Instance:GetIntimacyPersonalData();
    for _, personal in ipairs(personalData) do
        index = index + 1
        local item = self.rewardItemlist[index]
        if item == nil then
            item = IntiMacyRewardItem.New(self.BaseItem, index, false)
            table.insert(self.rewardItemlist, item)
        end
        if rewardIndex == 0 and myIntimacy > 0 then
            if myIntimacy >= personal.num then
              local isGet = IntimacyManager.Instance:CheckIsGetReward(personal.num);
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
    rect.anchoredPosition = Vector2(0,85 * (rewardIndex-1))
end

function IntiMacyPanel:UpdateRank()
    if not self.hasInit then
        return
    end
    local rankData = IntimacyManager.Instance:GetRankData(3)
    if rankData == nil then
        return
    end
    for index = 1, #rankData do
        local rankItem = self.rankItemlist[index]
        rankItem:SetData(rankData[index])
    end
    self:UpdateMyRank()
end

function IntiMacyPanel:UpdateMyRank()
    if not self.hasInit then
        return
    end
    local myIntimacy = IntimacyManager.Instance:GetMyIntimacy()
    self.TxtMyIntimacy.text = string.format(TI18N("我的亲密度：<color='#2fc823'>%s</color>"), myIntimacy)
    local myRank = IntimacyManager.Instance:GetMyRankIndex();
    if myRank > 0 then
        self.TxtMyRank.text = string.format(TI18N("我的排行：<color='#2fc823'>%s</color>"), myRank)
    else
        self.TxtMyRank.text = string.format(TI18N("我的排行：<color='#2fc823'>未上榜</color>"))
    end
end
function IntiMacyPanel:UpdateMyReward()
    for _, item in ipairs(self.rewardItemlist) do
        item:UpdatePersonalData()
    end
end

function IntiMacyPanel:ShowTime()
    local timeStr = ""
    local baseTime = BaseUtils.BASE_TIME
    local endTime = 0
    if self.BeginTime < baseTime and baseTime < self.EndTime then
        timeStr = BaseUtils.formate_time_gap(self.EndTime - BaseUtils.BASE_TIME, "", 1, BaseUtils.time_formate.DAY)
        self.TxtCampTime.text = string.format(TI18N("活动剩余时间：<color='#248813'>%s</color>"), timeStr)
    else
        self.TxtCampTime.text = TI18N("活动已结束")
        LuaTimer.Delete(self.timer)
        self.timer = nil
    end
end


function IntiMacyPanel:OnRectScroll(value)
  local Top = 13
  local Bot = -160

  for k,v in pairs(self.rewardItemlist) do
    local ax = v.gameObject.transform.anchoredPosition.y + self.ItemCon.anchoredPosition.y
    local state = nil
    if ax  < Bot or ax > Top then
        state = false
    else
        state = true
    end

    local temp = v.gameObject.transform:FindChild("BtnReward/Effect")
    if temp ~= nil then
        temp.gameObject:SetActive(state)
    end
  end
end
