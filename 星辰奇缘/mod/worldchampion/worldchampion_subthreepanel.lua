WorldChampionSubthreePanel = WorldChampionSubthreePanel or BaseClass(BasePanel)

function WorldChampionSubthreePanel:__init(parent, Main)
    self.model = model
    self.Mgr = WorldChampionManager.Instance
    self.parent = parent
    self.Main = Main
    self.name = "WorldChampionSubthreePanel"
    self.Titletimer = nil
    self.currpage = 1
    self.resList = {
        {file = AssetConfig.worldchampionmainsub3, type = AssetType.Main},
        {file = AssetConfig.classcardgroup_textures, type = AssetType.Dep},
        {file = AssetConfig.worldchampion_LevIcon, type = AssetType.Dep},
        {file = AssetConfig.heads, type = AssetType.Dep},
        {file = AssetConfig.no1inworld_textures, type = AssetType.Dep},

    }
-- PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "sexIcon_" ..  tostring(shouhuData.classes))
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
    self.page2X = {
        [1] = 6,
        [2] = -144
    }
    self.page2LX = {
        [1] = -335,
        [2] = -487
    }
end

function WorldChampionSubthreePanel:OnOpen()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(true)
    end
end

function WorldChampionSubthreePanel:OnHide()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(false)
    end
end

function WorldChampionSubthreePanel:__delete()

    self.OnHideEvent:Fire()
    if self.Ext ~= nil then
        self.Ext:DeleteMe()
    end
    if self.GiftPreview ~= nil then
        self.GiftPreview:DeleteMe()
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function WorldChampionSubthreePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.worldchampionmainsub3))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent.gameObject, self.gameObject)
    self.transform = t

    local rewardList = {}
    for i,v in ipairs(DataTournament.data_list) do
        if i == 1 then
            table.insert(rewardList, DataTournament.data_list[2].advance_reward)
        else
            table.insert(rewardList, v.advance_reward)
        end
    end
    self.GiftPreview = GiftPreview.New(self.Main.gameObject, rewardList, function(index) return self:ChangeRewadrTitle(index) end, true)
    self.LevImage = t:Find("Mylev/LevImage"):GetComponent(Image)
    self.LevText = t:Find("Mylev/LevText"):GetComponent(Text)
    self.LvGroup = t:Find("Mask/LvGroup")
    self.groupItem = {}
    for i=1,11 do
        self.groupItem[i] = {}
        self.groupItem[i].btn = self.LvGroup:Find(tostring(i)):GetComponent(Button)
        self.groupItem[i].Select = self.groupItem[i].btn.gameObject.transform:Find("Select").gameObject
        self.groupItem[i].Name = self.groupItem[i].btn.gameObject.transform:Find("Name"):GetComponent(Text)
    end
    self.Lbtn = self.transform:Find("L"):GetComponent(Button)
    self.Rbtn = self.transform:Find("R"):GetComponent(Button)
    self.Lbtn.onClick:AddListener(function()
        self:ChangePage(1, 0)
    end)
    self.Rbtn.onClick:AddListener(function()
        self:ChangePage(2, 1)
    end)
    if self.Mgr.rankData.rank_lev ~= nil and self.Mgr.rankData.rank_lev >= 3 then
        self:ChangePage(2)
    else
        self:ChangePage(1)
    end
    self.Content = t:Find("Desc/Content"):GetComponent(Text)
    self.Ext = MsgItemExt.New(self.Content, 685, 17, 26)
    self.Ext:SetData(self.Mgr.OtherDesc)
    self:SetData()
end

function WorldChampionSubthreePanel:SetData()
    if self.Mgr.rankData.rank_lev == nil then
        self.Mgr.rankData.rank_lev = 1
    end
    local LvData = DataTournament.data_list[self.Mgr.rankData.rank_lev]
    self.LevImage.sprite = self.assetWrapper:GetSprite(AssetConfig.worldchampion_LevIcon, self.Mgr.rankData.rank_lev)
    self.LevText.text = LvData.name
    for i=1,11 do
        local data = nil
        -- for ii,v in ipairs(DataTournament.data_list) do
        --     if v.rank_lev == i then
        --         data = DataTournament.data_list[i]
        --         break
        --     end
        -- end
        data = DataTournament.data_list[i]
        self.groupItem[i].btn.onClick:AddListener(function() self:ShowReward(data.rank_lev) end)
        if LvData.rank_lev == i then
            self.groupItem[i].Select:SetActive(true)
        end
        self.groupItem[i].Name.text = data.boxname
    end
end

function WorldChampionSubthreePanel:ShowReward(index)
    local LvData = DataTournament.data_list[index]
    if index == 1 then
        LvData = DataTournament.data_list[2]
    end
    local reward = LvData.advance_reward
    self.GiftPreview:Show({pageindex = index, reward = reward, text = string.format(TI18N("首次晋级<color='#00ff00'>%s</color>奖励"), LvData.name), autoMain = true})
end

function WorldChampionSubthreePanel:ChangeRewadrTitle(index)
    local LvData = DataTournament.data_list[index]
    if index == 1 then
        LvData = DataTournament.data_list[2]
    end
    return string.format(TI18N("首次晋级<color='#00ff00'>%s</color>奖励"), LvData.name)
end

--dir = 0 左翻页 1右翻页
function WorldChampionSubthreePanel:ChangePage(page, dir)
    if dir ~= nil then
        if dir == 0 then
            if self.currpage > 1 then
                self.currpage = self.currpage - 1
                Tween.Instance:MoveLocalX(self.LvGroup.gameObject, self.page2LX[self.currpage], 0.4, function()end, LeanTweenType.linear)
                -- self.LvGroup.anchoredPosition = Vector2(self.page2X[self.currpage], 0)
            end
        elseif dir == 1 then
            if self.currpage < 2 then
                self.currpage = self.currpage + 1
                Tween.Instance:MoveLocalX(self.LvGroup.gameObject, self.page2LX[self.currpage], 0.4, function()end, LeanTweenType.linear)
                -- self.LvGroup.anchoredPosition = Vector2(self.page2X[self.currpage], 0)
            end
        end
    else
        self.currpage = page
        self.LvGroup.anchoredPosition = Vector2(self.page2X[self.currpage], 0)
    end
    self.Lbtn.gameObject:SetActive(self.currpage ~= 1)
    self.Rbtn.gameObject:SetActive(self.currpage ~= 2)
end