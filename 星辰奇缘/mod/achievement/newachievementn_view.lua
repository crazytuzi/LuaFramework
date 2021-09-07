-- ----------------------------------------------------------
-- UI - 成就窗口 主窗口
-- ----------------------------------------------------------
NewAchievementView = NewAchievementView or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function NewAchievementView:__init(model)
	self.model = model
    self.name = "NewAchievementView"
    self.windowId = WindowConfig.WinID.newAchievement

    self.resList = {
        {file = AssetConfig.achievementnotice, type = AssetType.Main}
        , {file = AssetConfig.rank_textures, type = AssetType.Dep}
        , {file = AssetConfig.attr_icon, type = AssetType.Dep}
        , {file = AssetConfig.half_length, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil

    self.timerId = nil
	------------------------------------------------

    self._update = function(id) self:Update(id) end
end


function NewAchievementView:__delete()
    self.is_open = false
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end

    self:AssetClearAll()
end

function NewAchievementView:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.achievementnotice))
    self.gameObject.name = "NewAchievementView"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    -- self.transform:FindChild("Panel"):GetComponent(Button).onClick:AddListener(function() self.model:CloseNewAchievementWindow() end)

    self.closeBtn = self.transform:FindChild("Main/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self.model:CloseNewAchievementWindow() end)

    self.mainBtn = self.transform:FindChild("Main"):GetComponent(Button)
    self.mainBtn.onClick:AddListener(function() self:MainBtnClick() end)

    local btn = self.transform:FindChild("Main/Reward/RewardText"):GetComponent(Button)
    btn.onClick:RemoveAllListeners()
    btn.onClick:AddListener(function() self:RewardClick() end)

    self.is_open = true

    if self.openArgs ~= nil and #self.openArgs > 0 then
        self:update(self.openArgs[1])
    end
end

function NewAchievementView:update(data)
    self.transform:FindChild("Main/NameText"):GetComponent(Text).text = data.name
    self.transform:FindChild("Main/DescText"):GetComponent(Text).text = data.desc

    self.transform:FindChild("Main/StarItem/DescText"):GetComponent(Text).text = data.ach_num

    local star = data.star
    if data.finish ~= 1 and data.finish ~= 2 then
        star = star - 1
    end
    if star == 0 then star = 3 end
    if star < 0 then star = 0 end
    if star == 0 then
        self.transform:FindChild("Main/StarPanel/Star1/Image").gameObject:SetActive(false)
        self.transform:FindChild("Main/StarPanel/Star2/Image").gameObject:SetActive(false)
        self.transform:FindChild("Main/StarPanel/Star3/Image").gameObject:SetActive(false)
    elseif star == 1 then
        self.transform:FindChild("Main/StarPanel/Star1/Image").gameObject:SetActive(true)
        self.transform:FindChild("Main/StarPanel/Star2/Image").gameObject:SetActive(false)
        self.transform:FindChild("Main/StarPanel/Star3/Image").gameObject:SetActive(false)
    elseif star == 2 then
        self.transform:FindChild("Main/StarPanel/Star1/Image").gameObject:SetActive(true)
        self.transform:FindChild("Main/StarPanel/Star2/Image").gameObject:SetActive(true)
        self.transform:FindChild("Main/StarPanel/Star3/Image").gameObject:SetActive(false)
    elseif star == 3 then
        self.transform:FindChild("Main/StarPanel/Star1/Image").gameObject:SetActive(true)
        self.transform:FindChild("Main/StarPanel/Star2/Image").gameObject:SetActive(true)
        self.transform:FindChild("Main/StarPanel/Star3/Image").gameObject:SetActive(true)
    end

    if data.honor ~= 0 or #data.rewards_commit > 0 then
        self.transform:FindChild("Main/Reward").gameObject:SetActive(true)

        if data.honor ~= 0 then
            local honorData = DataHonor.data_get_honor_list[data.honor]
            if honorData == nil then
                self.transform:FindChild("Main/Reward/RewardText"):GetComponent(Text).text = ""
            else
                self.transform:FindChild("Main/Reward/RewardText"):GetComponent(Text).text = string.format(TI18N("称号<color='#225ee7'>[%s]</color>"), honorData.name)
            end
        elseif DataAchievement.data_attr[data.id] ~= nil then
            local attr = DataAchievement.data_attr[data.id].attr
            local attrText = ""
            for i, v in ipairs(attr) do
                attrText = string.format("%s %s", attrText, KvData.GetAttrString(v.key, v.val))
            end
            self.transform:FindChild("Main/Reward/RewardText"):GetComponent(Text).text = attrText
        elseif #data.rewards_commit > 0 then
            local rewardData = data.rewards_commit[1]
            local itemBaseData = BackpackManager:GetItemBase(rewardData[1])
            if rewardData[3] > 0 then
                self.transform:FindChild("Main/Reward/RewardText"):GetComponent(Text).text = string.format("%s×%s", ColorHelper.color_item_name(itemBaseData.quality , string.format("[%s]", itemBaseData.name)), rewardData[3])
            else
                self.transform:FindChild("Main/Reward/RewardText"):GetComponent(Text).text = ColorHelper.color_item_name(itemBaseData.quality , string.format("[%s]", itemBaseData.name))
            end
        end
    else
        self.transform:FindChild("Main/Reward").gameObject:SetActive(false)
    end

    self.timerId = LuaTimer.Add(3000, self._update)

    if self.effect ~= nil then
        self.effect:DeleteMe()
    end
    self.effect = BaseUtils.ShowEffect(20123, self.transform:FindChild("Main/Effect"), Vector3.one, Vector3(0, 0, -1000))
end

function NewAchievementView:Update(id)
    self.timerId = id

    if self.is_open then
        self.model:CloseNewAchievementWindow()
    end
end

function NewAchievementView:MainBtnClick()
    if self.openArgs ~= nil and #self.openArgs > 0 then
        local data = self.openArgs[1]
        local pageIndexData = self.model:getAchievementPageIndex(data.sec_type)
        if pageIndexData ~= nil then
            self.model:CloseNewAchievementWindow()
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ui_rank, { 2, pageIndexData.main, pageIndexData.sub })
        end
    end
end

function NewAchievementView:RewardClick()
    if self.openArgs ~= nil and #self.openArgs > 0 then
        local data = self.openArgs[1]

        if data.honor ~= 0 then
            local honorData = DataHonor.data_get_honor_list[data.honor]
            HonorManager.Instance.model.current_data = honorData
            HonorManager.Instance.model:InitMainUI()
        elseif #data.rewards_commit > 0 then
            local itemdata = ItemData.New()
            itemdata:SetBase(BackpackManager.Instance:GetItemBase(data.rewards_commit[1][1]))
            TipsManager.Instance:ShowItem({["gameObject"] = self.transform:FindChild("Main/Reward").gameObject, ["itemData"] = itemdata, extra = { nobutton = true } })
        end
    end
end
