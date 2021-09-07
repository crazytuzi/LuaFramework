-- @author 黄耀聪
-- @date 2017年6月21日, 星期三

SummerQuest = SummerQuest or BaseClass(BasePanel)

function SummerQuest:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "SummerQuest"

    self.resList = {
        { file = AssetConfig.summer_quest, type = AssetType.Main }
        ,{ file = AssetConfig.summer_quest_big_bg, type = AssetType.Main }
        ,{ file = AssetConfig.summer_quest_big_bg2, type = AssetType.Main }
        ,{ file = AssetConfig.textures_campaign, type = AssetType.Dep }
        ,{ file = AssetConfig.wingsbookbg, type = AssetType.Dep }
        ,{ file = AssetConfig.rolebgnew, type = AssetType.Dep }
        ,{ file = AssetConfig.dailyicon, type = AssetType.Dep }
        ,{ file = AssetConfig.summer_res, type = AssetType.Dep }
        ,{ file = AssetConfig.agenda_textures, type = AssetType.Dep }
        ,{ file = string.format(AssetConfig.effect, 20053), type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime() }
    }
    self.RewardItems = { }
    self.RewardNumTxts = { }
    self.QuestItems = { }
    self.questCheckRedList = { }
    self.updateQuestHandler =
    function()
        self:UpdateQuest()
        self:UpdateProgress()
        self:UpdateBoxReward()
    end

    self.OnOpenEvent:AddListener( function() self:OnOpen() end)
    self.OnHideEvent:AddListener( function() self:OnHide() end)
end

function SummerQuest:__delete()
    self.OnHideEvent:Fire()
    if self.questCheckRedList ~= nil then
        self.questCheckRedList = nil
    end
    if self.RewardItems ~= nil then
        for _, item in pairs(self.RewardItems) do
            item:DeleteMe()
            item = nil
        end
        self.RewardItems = nil
    end
    if self.QuestItems ~= nil then
        for _, item in pairs(self.QuestItems) do
            item:DeleteMe()
            item = nil
        end
        self.QuestItems = nil
    end
    if self.iconLoader ~= nil then
        self.iconLoader:DeleteMe()
        self.iconLoader = nil
    end
    self:AssetClearAll()
end

function SummerQuest:InitPanel()
    if self.parent == nil then
        self:AssetClearAll()
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.summer_quest))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.BigBg = self.transform:Find("Bg")
    local bigbg = GameObject.Instantiate(self:GetPrefab(AssetConfig.summer_quest_big_bg2))
    bigbg.gameObject.transform.localPosition = Vector3(0, 0, 0)
    bigbg.gameObject.transform.localScale = Vector3(1, 1, 1)
    UIUtils.AddBigbg(self.BigBg, bigbg)

    for index = 1, 4 do
        local itemObj = self.transform:Find("Reward/Reward" .. index).gameObject;
        local item = SummerQuestRewardItem.New(itemObj, self.model, self)
        table.insert(self.RewardItems, item)

        local txt = self.transform:Find("Slider/TextList/Text" .. index):GetComponent(Text);
        table.insert(self.RewardNumTxts, txt)
    end
    self.Scroll = self.transform:Find("Scroll"):GetComponent(ScrollRect)
    self.Scroll.onValueChanged:AddListener( function() self:OnValueChanged() end)
    self.Cloner = self.transform:Find("Scroll/Container/Cloner").gameObject
    self.Cloner:SetActive(false)
    self.Container = self.transform:Find("Scroll/Container")
    self.Toggle = self.transform:Find("Slider/Toggle");
    self.TxtPoint = self.transform:Find("Slider/Toggle/Text"):GetComponent(Text);
    self.ProgressBar = self.transform:Find("Slider/Value")
    self.TxtDesc = self.transform:Find("TxtDesc"):GetComponent(Text)
    --self.TxtDesc.text = TI18N("6月29日至7月1日达成目标即可领取好礼");
    self.transform:Find("TxtDesc").localPosition = Vector3(26,162,0)
    --print(self.TxtDesc.transform.localPosition)
    --print(self.TxtDesc.transform.anchoredPosition)
    self.TxtDesc.text = string.format(TI18N("<color='#7FFF00'>%s月%s日至%s月%s日</color>达成目标即可领取好礼"),DataCampaign.data_list[self.campId].cli_start_time[1][2],DataCampaign.data_list[self.campId].cli_start_time[1][3],DataCampaign.data_list[self.campId].cli_end_time[1][2],DataCampaign.data_list[self.campId].cli_end_time[1][3])
    --self.TxtDesc.text = string.format(TI18N("12月1日至12月7日达成目标即可领取好礼"))

    self.ImgIcon = self.transform:Find("ImgIcon"):GetComponent(Image);
    self.iconLoader = SingleIconLoader.New(self.ImgIcon.gameObject)
    self.iconLoader:SetSprite(SingleIconType.Item, KvData.assets.sum_point)
end

function SummerQuest:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function SummerQuest:OnOpen()
    self:RemoveListeners()
    CampBoxManager.Instance.OnUpdateRedPoint:AddListener(self.updateQuestHandler)
    CampBoxManager.Instance:Send10253()
    self:UpdateQuest()
    self:UpdateBoxReward()
    self:UpdateProgress()
end

function SummerQuest:OnHide()
    self:RemoveListeners()
    if self.RewardItems ~= nil then
        for _, item in pairs(self.RewardItems) do
            item:OnHide()
        end
    end
end

function SummerQuest:RemoveListeners()
    CampBoxManager.Instance.OnUpdateRedPoint:RemoveListener(self.updateQuestHandler)
end

function SummerQuest:UpdateBoxReward()
    local tmpList = DataQuestSummer.data_reward_list
    local sortFun =
    function(a, b)
        return a.id < b.id
    end;
    table.sort(tmpList, sortFun)
    CampBoxManager.Instance.isShowShake = false
    for index = 1, 4 do
        local tmp = tmpList[index];
        self.RewardNumTxts[index].text = tmp.need_score
        self.RewardItems[index]:SetData(tmp)
    end
end

-- 更新任务
function SummerQuest:UpdateQuest()
    local finishList = CampBoxManager.Instance.FinishedList or { }
    local doingList = CampBoxManager.Instance.DoingList or { }
    --BaseUtils.dump(finishList,"self.FinishedList列表")
    --BaseUtils.dump(doingList,"self.doingList列表")
    local questList = { }
    local sortFun =
    function(a, b)
        local asort = DataQuestSummer.data_quest_point_list[a.quest_id]
        local bsort = DataQuestSummer.data_quest_point_list[b.quest_id]
        return asort.sort < bsort.sort
    end;
    table.sort(finishList, sortFun)
    table.sort(doingList, sortFun)

    local questList1 = { }
    local questList2 = { }
    if #doingList > 0 then
        for _, value in pairs(doingList) do
            local tmp = DataQuestSummer.data_quest_point_list[value.quest_id]
            local questData = QuestManager.Instance:GetQuest(tmp.id)
            if questData ~= nil then
                questData.sum_icon = tmp.icon
                questData.sum_point = tmp.score
                if questData.finish == QuestEumn.TaskStatus.Finish then
                    table.insert(questList1, questData)
                else
                    table.insert(questList2, questData)
                end
            end
        end
    end
    if #questList2 > 0 then
        for _, quest in pairs(questList2) do
            table.insert(questList1, quest)
        end
    end
    questList = questList1
    if #finishList > 0 then
        for _, value in pairs(finishList) do
            local tmp = DataQuestSummer.data_quest_point_list[value.quest_id]
            local questData = BaseUtils.copytab(DataQuest.data_get[tmp.id])
            if questData ~= nil then
                questData.finish = QuestEumn.TaskStatus.End
                questData.sum_icon = tmp.icon
                questData.sum_point = tmp.score
                table.insert(questList, questData)
            end
        end
    end
    --BaseUtils.dump(questList,"questList是什么")
    self.questCheckRedList = questList
    local index = 1
    for id, quest in pairs(questList) do
        local item = self.QuestItems[index]
        if item == nil then
            item = SummerQuestQuestItem.New(self.Cloner, self.model, index, self.assetWrapper)
            item.ImgBack.sprite = self.assetWrapper:GetSprite(AssetConfig.rolebgnew, "RoleBgNew")
            table.insert(self.QuestItems, item)
        end
        item:SetData(quest)
        item.gameObject:SetActive(true)
        index = index + 1
    end

    local newW = 165 * index - 165
    local rect = self.Container.transform:GetComponent(RectTransform)
    rect.sizeDelta = Vector2(newW, 0)

    self:OnValueChanged()
end
-- 更新进度条
function SummerQuest:UpdateProgress()
    local curPoint = CampBoxManager.Instance.SumPoint;
    self.TxtPoint.text = curPoint;
    local BarW = 14;
    local boxRewardList = DataQuestSummer.data_reward_list;
    if curPoint <= boxRewardList[1].need_score then
        BarW =(curPoint / boxRewardList[1].need_score) * 130
    elseif curPoint <= boxRewardList[2].need_score then
        BarW = 130 +((curPoint) / boxRewardList[2].need_score) *(255 - 130)
    elseif curPoint <= boxRewardList[3].need_score then
        BarW = 255 +((curPoint) / boxRewardList[3].need_score) *(378 - 255)
    elseif curPoint <= boxRewardList[4].need_score then
        BarW = 378 +((curPoint) / boxRewardList[4].need_score) *(500 - 378)
    else
        BarW = 526
    end

    self.ProgressBar.sizeDelta = Vector2(BarW, 19)
    self.Toggle.anchoredPosition = Vector2(BarW, 0)
    self.Toggle.gameObject:SetActive(curPoint > 0)
end

function SummerQuest:OnValueChanged()
    local containerX = self.Container.anchoredPosition.x
    for index, item in ipairs(self.QuestItems) do
        local bool = false
        local itemX = item.transform.anchoredPosition.x
        bool = containerX + itemX >= -25 and containerX + itemX <= 405
        item:ShowBtnEffect(bool)
    end
end