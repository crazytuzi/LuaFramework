-- 万圣节活动排行面板
-- ljh  20161021

HalloweenRankWindow = HalloweenRankWindow or BaseClass(BaseWindow)

function HalloweenRankWindow:__init(model)
    self.model = model
    self.name = "HalloweenRankWindow"
    self.windowId = WindowConfig.WinID.mid_autumn_window

    self.resList = {
        {file = AssetConfig.halloweenrank, type = AssetType.Main},
        {file = AssetConfig.halloween_textures, type = AssetType.Dep},
        {file = AssetConfig.no1inworld_textures, type = AssetType.Dep},
        {file = AssetConfig.guildleague_texture, type = AssetType.Dep},
    }

    --------------------------------------
    self.result = nil
    self.mvp = nil
    self.scoreText1 = nil
    self.scoreText2 = nil

    self.blue_headSlot = {}
    self.red_headSlot = {}
    self.blue_name = {}
    self.red_name = {}
    self.blue_times1 = {}
    self.red_times1 = {}
    self.blue_times2 = {}
    self.red_times2 = {}
    self.blue_score = {}
    self.red_score = {}

    self.my_data = nil
    --------------------------------------
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function HalloweenRankWindow:__delete()
    self.OnHideEvent:Fire()

    if self.rewardLoader ~= nil then
        self.rewardLoader:DeleteMe()
        self.rewardLoader = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function HalloweenRankWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.halloweenrank))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local transform = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = transform

    transform:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function() self:OnClose() end)

    self.result = transform:Find("Main/result")
    self.mvp = transform:Find("Main/Panel/Mvp")
    self.rewardLoader = SingleIconLoader.New(transform:Find("Main/Panel/Reward").gameObject)
    self.scoreText1 = transform:Find("Main/ScoreText1"):GetComponent(Text)
    self.scoreText2 = transform:Find("Main/ScoreText2"):GetComponent(Text)
    self.buleTeamText = transform:Find("Main/Title/BuleTeamText"):GetComponent(Text)
    self.redTeamText = transform:Find("Main/Title/RedTeamText"):GetComponent(Text)

    self.blue_headSlot = {}
    self.red_headSlot = {}
    self.blue_name = {}
    self.red_name = {}
    self.blue_times1 = {}
    self.red_times1 = {}
    self.blue_times2 = {}
    self.red_times2 = {}
    self.blue_score = {}
    self.red_score = {}

    local panel = transform:Find("Main/Panel")
    for i = 1, 5 do
        local item = panel:Find(string.format("Item%s", i))
        table.insert(self.blue_name, item:Find("NameText1"):GetComponent(Text))
        table.insert(self.red_name, item:Find("NameText2"):GetComponent(Text))
        table.insert(self.blue_times1, item:Find("Times1Text1"):GetComponent(Text))
        table.insert(self.red_times1, item:Find("Times1Text2"):GetComponent(Text))
        table.insert(self.blue_times2, item:Find("Times2Text1"):GetComponent(Text))
        table.insert(self.red_times2, item:Find("Times2Text2"):GetComponent(Text))
        table.insert(self.blue_score, item:Find("ScoreText1"):GetComponent(Text))
        table.insert(self.red_score, item:Find("ScoreText2"):GetComponent(Text))

        local head = item:Find("Head1/Image")
        local headSlot = HeadSlot.New()
        headSlot:SetRectParent(head)
        table.insert(self.blue_headSlot, headSlot)

        head = item:Find("Head2/Image")
        headSlot = HeadSlot.New()
        headSlot:SetRectParent(head)
        table.insert(self.red_headSlot, headSlot)
    end

    self.container = self.transform:FindChild("Main/Reward").gameObject
    self.itemObject = self.transform:FindChild("Main/Item").gameObject
    self.itemObject:SetActive(false)

    self.button = self.transform:FindChild("Main/OkButton").gameObject
    self.button:GetComponent(Button).onClick:AddListener(function() self:OnClose() end)

    self.tipsButton = self.transform:FindChild("Main/TipsButton").gameObject
    self.tipsButton:GetComponent(Button).onClick:AddListener(function()
        TipsManager.Instance:ShowText({gameObject = self.tipsButton
            , itemData = { TI18N("1、如果结束时双方得分一样，则以<color='#ffff00'>速度更快</color>达到当前分数的一方获胜")
                        , TI18N("2、获胜方的第一名获得MVP奖励，多名同分则先达到该分数的玩家成为MVP")
                        }}) end)

    self.rewardLoader:SetSprite(SingleIconType.Item, 22505)
end

function HalloweenRankWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function HalloweenRankWindow:OnOpen()
    self:AddListeners()

    self:Update()
end

function HalloweenRankWindow:OnHide()
    self:RemoveListeners()

end

function HalloweenRankWindow:AddListeners()
end

function HalloweenRankWindow:RemoveListeners()
end

function HalloweenRankWindow:OnClose()
    WindowManager.Instance:CloseWindow(self)
    LuaTimer.Add(500, function() self:ShowRewardWindow() end)
end

function HalloweenRankWindow:Update()
    local roleData = RoleManager.Instance.RoleData
    local mvp_data = nil
    local myCamp_Mark = 2
    for i = 1, #self.model.red_list do
        local data = self.model.red_list[i]
        if roleData.id == data.rid and roleData.platform == data.platform and roleData.zone_id == data.r_zone_id then
            myCamp_Mark = 1
            break
        end
    end

    self.scoreText1.text = string.format("%s", self.model.blue_score)
    self.scoreText2.text = string.format("%s", self.model.red_score)
    if myCamp_Mark == 2 then
        self.buleTeamText.text = TI18N("我方阵营")
        self.redTeamText.text = TI18N("敌方阵营")
    else
        self.buleTeamText.text = TI18N("敌方阵营")
        self.redTeamText.text = TI18N("我方阵营")
    end

    if self.model.win_camp == 2 then
        self.transform:Find("Main/Win1").gameObject:SetActive(true)
        self.transform:Find("Main/Win2").gameObject:SetActive(false)
        mvp_data = { index = 1, camp = 2 }
    else
        self.transform:Find("Main/Win1").gameObject:SetActive(false)
        self.transform:Find("Main/Win2").gameObject:SetActive(true)
        mvp_data = { index = 1, camp = 1 }
    end

    for i = 1, #self.model.blue_list do
        local blue_data = self.model.blue_list[i]
        local red_data = self.model.red_list[i]

        self.blue_name[i].text = blue_data.name
        self.blue_times1[i].text = tostring(blue_data.win)
        self.blue_times2[i].text = tostring(blue_data.die)
        self.blue_score[i].text = string.format("<color='#ffff00'>%s</color>", blue_data.score)

        self.red_name[i].text = red_data.name
        self.red_times1[i].text = tostring(red_data.win)
        self.red_times2[i].text = tostring(red_data.die)
        self.red_score[i].text = string.format("<color='#ffff00'>%s</color>", red_data.score)

        local head_data = {id = blue_data.rid, platform = blue_data.platform, zone_id = blue_data.r_zone_id, classes = blue_data.classes, sex = blue_data.sex}
        self.blue_headSlot[i]:HideSlotBg(true, 0)
        self.blue_headSlot[i]:SetAll(head_data, { small = true })

        head_data = {id = red_data.rid, platform = red_data.platform, zone_id = red_data.r_zone_id, classes = red_data.classes, sex = red_data.sex}
        self.red_headSlot[i]:HideSlotBg(true, 0)
        self.red_headSlot[i]:SetAll(head_data, { small = true })

        -- if mvp_data == nil then
        --     mvp_data = { score = blue_data.score, index = 1, camp = blue_data.camp }
        -- end
        -- if mvp_data.score < blue_data.score then
        --     mvp_data = { score = blue_data.score, index = 1, camp = blue_data.camp }
        -- end
        -- if mvp_data.score < red_data.score then
        --     mvp_data = { score = red_data.score, index = 1, camp = red_data.camp }
        -- end

        if roleData.id == blue_data.rid and roleData.platform == blue_data.platform and roleData.zone_id == blue_data.r_zone_id then
            self.my_data = blue_data
        elseif roleData.id == red_data.rid and roleData.platform == red_data.platform and roleData.zone_id == red_data.r_zone_id then
            self.my_data = red_data
        end
    end

    if mvp_data.camp == 2 then
        self.mvp.position = self.blue_headSlot[mvp_data.index].gameObject.transform.position
        local pos = self.mvp.localPosition
        self.mvp.localPosition = Vector2(pos.x - 40, pos.y + 12)
        self.rewardLoader.gameObject.transform.anchoredPosition = Vector2(pos.x - 40, pos.y - 12)
    else
        self.mvp.position = self.red_headSlot[mvp_data.index].gameObject.transform.position
        local pos = self.mvp.localPosition
        self.mvp.localPosition = Vector2(pos.x + 40, pos.y + 12)
        self.rewardLoader.gameObject.transform.anchoredPosition = Vector2(pos.x + 40, pos.y - 12)
    end

    -- for i=1, #self.model.reward do
    --     local data = self.model.reward[i]
    --     local item = GameObject.Instantiate(self.itemObject)
    --     UIUtils.AddUIChild(self.container, item.gameObject)
    --     local slot = ItemSlot.New()
    --     UIUtils.AddUIChild(item, slot.gameObject)

    --     local itembase = BackpackManager.Instance:GetItemBase(data.base_id)
    --     local itemData = ItemData.New()
    --     itemData:SetBase(itembase)
    --     itemData.quantity = data.num
    --     slot:SetAll(itemData)
    -- end
end

function HalloweenRankWindow:ShowRewardWindow()
    local reward_list = {}

    local my_rank = 1
    local list = self.model.red_list
    if self.my_data.camp == 2 then
        list = self.model.blue_list
    end

    local isMvp = false
    local roleData = RoleManager.Instance.RoleData
    if #list == 0 or roleData == nil then
        return
    end
    if roleData.id == list[1].rid and roleData.platform == list[1].platform and roleData.zone_id == list[1].r_zone_id then
        isMvp = true
    end

    -- for i = 1, #list do
    --     if list[i].score > self.my_data.score then
    --         my_rank = my_rank + 1
    --     end
    -- end

    -- for i = 1, #DataCampHalloween.data_rank do
    --     local data_rank = DataCampHalloween.data_rank[i]
    --     if data_rank.win == 1 and self.model.is_win and data_rank.min >= my_rank and data_rank.max <= my_rank then
    --         for k,v in ipairs(data_rank.reward) do
    --             table.insert(reward_list, { id = v[1], num = v[2] })
    --         end
    --     end
    -- end

    for i=1, #self.model.reward do
        local data = self.model.reward[i]
        table.insert(reward_list, { id = data.base_id, num = data.num })
    end

    local val_str1 = TI18N("获得胜利")
    local val_str2 = TI18N("恭喜您获得本场比赛胜利，这是您的奖励，游戏愉快哟")

    if self.model.win_camp == self.my_data.camp then
        if isMvp then
            val_str1 = TI18N("完美胜利")
            val_str2 = TI18N("恭喜您成为本场比赛MVP，并率领大家走向胜利，游戏愉快")
        end
    else
        val_str1 = TI18N("遗憾败北")
        val_str2 = TI18N("本场比赛精彩纷呈，您虽败犹荣，游戏愉快")
    end

    FinishCountManager.Instance.model.reward_win_data = {
                        titleTop = TI18N("淘气南瓜")
                        -- , val = string.format("目前排名：<color='#ffff00'>%s</color>", self.rank)
                        , val1 = val_str2
                        , val2 = val_str1
                        , title = TI18N("获得奖励")
                        , confirm_str = TI18N("确定")
                        , reward_list = reward_list
                        -- , confirm_callback = function() ClassesChallengeManager.Instance:Send14805() end
                    }
    FinishCountManager.Instance.model:InitRewardWin_Common()
end