-- ----------------------------------------------------------
-- UI - 成就徽章
-- @ljh 20160621
-- ----------------------------------------------------------
AchievementBadgeTips = AchievementBadgeTips or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function AchievementBadgeTips:__init(model)
	self.model = model
    self.name = "AchievementBadgeTips"
    -- self.windowId = WindowConfig.WinID.newAchievement

    self.resList = {
        {file = AssetConfig.achievementBadgeTips, type = AssetType.Main}
        , {file = AssetConfig.badge_icon, type = AssetType.Dep}
        , {file = AssetConfig.stongbg, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil

    self.mainTransform = nil
	self.subTransform = nil
	------------------------------------------------
end


function AchievementBadgeTips:__delete()
    self.is_open = false
    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end

    self:AssetClearAll()
end

function AchievementBadgeTips:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.achievementBadgeTips))
    self.gameObject.name = "AchievementBadgeTips"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.transform:FindChild("Panel"):GetComponent(Button).onClick:AddListener(function() self.model:CloseAchievementBadgeTips() end)

    self.mainTransform = self.transform:FindChild("Main")
    self.subTransform = self.transform:FindChild("Sub")
    self.mainInfoPanel = self.mainTransform:FindChild("InfoPanel").gameObject
    self.subInfoPanel = self.subTransform:FindChild("InfoPanel").gameObject

    -- 大图 hosr
    self.mainTransform:Find("StoneBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.stongbg, "StoneBg")
    self.subTransform:Find("StoneBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.stongbg, "StoneBg")

    self.mainTransform:FindChild("ShowBtn"):GetComponent(Button).onClick:AddListener(function() self:ShowBtnClick() end)
    self.subTransform:FindChild("Button"):GetComponent(Button).onClick:AddListener(function() self:ShowBtnClick() end)

    self.mainTransform:FindChild("Button"):GetComponent(Button).onClick:AddListener(function()
                self.model:CloseAchievementBadgeTips()
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.ui_rank, {2,1,1,0})
            end)
    self.mainTransform:FindChild("Button2"):GetComponent(Button).onClick:AddListener(function()
                self.model:CloseAchievementBadgeTips()
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.achievementshopwindow, {1,1})
            end)
    self.mainTransform:FindChild("Icon"):GetComponent(Button).onClick:AddListener(function()
            self:showTips()
        end)

    self.is_open = true

    if self.openArgs ~= nil and #self.openArgs > 0 then
        self:update(self.openArgs[1])
    else
        self:update()
    end

    -- self.transform:SetAsLastSibling()

    -- LuaTimer.Add(100, function() self.transform:SetAsLastSibling() end)
end

function AchievementBadgeTips:update(data)
    if data == nil then
        self:update_main()
    else
        self:update_main()
        self:update_sub(data)

        self.mainTransform:FindChild("Label").gameObject:SetActive(true)

        self.mainTransform.localPosition = Vector3(92, 50, 0)
        self.subTransform.gameObject:SetActive(true)
    end

    if PlayerPrefs.GetInt("ShowBadgeTipsInfo") == 1 then
        self:showInfo(true)
    end
end

function AchievementBadgeTips:update_main()
    self.mainTransform:FindChild("NameText"):GetComponent(Text).text = TI18N("成就徽章")
	self.mainTransform:FindChild("NumBg/Text"):GetComponent(Text).text = tostring(self.model.achNum)
    local source_id = self.model:getBadgeSourceId(self.model.achNum)
    self.mainTransform:FindChild("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.badge_icon,tostring(source_id))

    self.mainTransform:FindChild("DescText"):GetComponent(Text).text = self.model:getBadgeDesc(self.model.achNum)

    self.mainInfoPanel.transform:FindChild("TotalText"):GetComponent(Text).text = string.format(TI18N("总成就进度：%.1f%%"), self.model.achNum / self.model.achNumMax * 100)
    local list = { 2, 3, 4, 5, 6, 7 }
    local nameList = { TI18N("人物") , TI18N("宠物") , TI18N("守护") , TI18N("装备") , TI18N("社交") , TI18N("活动")}
    for i = 1, #list do
        local typeAchNum = self.model.mainTypeAchNumList[list[i]]
        local typeAchNumMax = self.model.mainTypeAchNumMaxList[list[i]]
        if typeAchNum ~= nil and typeAchNumMax ~= nil then
            self.mainInfoPanel.transform:FindChild(string.format("Text%s", i)):GetComponent(Text).text = string.format("%s：%.1f%%", nameList[i], typeAchNum / typeAchNumMax * 100)
        end
    end

    local index = 1
    for key,value in ipairs(DataAchievement.data_badge) do
        if self.model.achNum >= value.num then
            index = key
        end
    end
    local badge_data = DataAchievement.data_badge[index]
    if badge_data ~= nil then
        if badge_data.star == 0 then
            self.mainTransform:FindChild("Star").gameObject:SetActive(false)
        else
            self.mainTransform:FindChild("Star").gameObject:SetActive(true)
            local star = badge_data.star + 1
            if star < 4 then
                for i=star,3 do
                    self.mainTransform:FindChild("Star/"..i).gameObject:SetActive(false)
                end
            end
        end
    end
end

function AchievementBadgeTips:update_sub(data)
    local name = data.name
    if name == "" then name = self.model.Send10233Name end
	self.subTransform:FindChild("NameText"):GetComponent(Text).text = name

    self.subTransform:FindChild("NumBg/Text"):GetComponent(Text).text = tostring(data.num)
    local source_id = self.model:getBadgeSourceId(data.num)
    self.subTransform:FindChild("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.badge_icon,tostring(source_id))

    self.subTransform:FindChild("DescText"):GetComponent(Text).text = self.model:getBadgeDesc(data.num)

    self.subInfoPanel.transform:FindChild("TotalText"):GetComponent(Text).text = string.format(TI18N("总成就进度：%.1f%%"), data.num / self.model.achNumMax * 100)

    local list = { 2, 3, 4, 5, 6, 7 }
    local nameList = { TI18N("人物") , TI18N("宠物") , TI18N("守护") , TI18N("装备") , TI18N("社交") , TI18N("活动")}

    local dataList = {}
    for i = 1, #list do
        dataList[list[i]] = 0
    end
    for _,value in ipairs(data.list) do
        dataList[value.type] = value.finish
    end

    for i = 1, #list do
        -- typeAchNum = self.model.mainTypeAchNumList[list[i]]
        local typeAchNum = dataList[list[i]]
        local typeAchNumMax = self.model.mainTypeAchNumMaxList[list[i]]
        if typeAchNum ~= nil and typeAchNumMax ~= nil then
            self.subInfoPanel.transform:FindChild(string.format("Text%s", i)):GetComponent(Text).text = string.format("%s：%.1f%%", nameList[i], typeAchNum / typeAchNumMax * 100)
        end
    end

    local index = 1
    for key,value in ipairs(DataAchievement.data_badge) do
        if data.num >= value.num then
            index = key
        end
    end
    local badge_data = DataAchievement.data_badge[index]
    if badge_data ~= nil then
        if badge_data.star == 0 then
            self.subTransform:FindChild("Star").gameObject:SetActive(false)
        else
            self.subTransform:FindChild("Star").gameObject:SetActive(true)
            local star = badge_data.star + 1
            if star < 4 then
                for i=star,3 do
                    self.subTransform:FindChild("Star/"..i).gameObject:SetActive(false)
                end
            end
        end
    end
end

function AchievementBadgeTips:showInfo(show)
    self.mainInfoPanel:SetActive(show)
    self.subInfoPanel:SetActive(show)
end

function AchievementBadgeTips:ShowBtnClick()
    local show = PlayerPrefs.GetInt("ShowBadgeTipsInfo")

    if show == 1 then
        self:showInfo(false)
        PlayerPrefs.SetInt("ShowBadgeTipsInfo", 0)
    else
        self:showInfo(true)
        PlayerPrefs.SetInt("ShowBadgeTipsInfo", 1)
    end
end

function AchievementBadgeTips:showTips()
    local index = 1
    for key,value in ipairs(DataAchievement.data_badge) do
        if self.model.achNum >= value.num then
            index = key
        end
    end

    local tipsText = {}
    if DataAchievement.data_badge[index + 1] == nil then
        tipsText = { string.format("<color='#ffff00'>%s</color>", DataAchievement.data_badge[index].name), string.format(TI18N("成就点：<color='#ffff00'>%s</color>"), self.model.achNum), TI18N("已到最高级别徽章") }
    else
        tipsText = { string.format("<color='#ffff00'>%s</color>", DataAchievement.data_badge[index].name), string.format(TI18N("成就点：<color='#ffff00'>%s</color>"), self.model.achNum), string.format(TI18N("下级徽章还需：<color='#ffff00'>%s</color>"), DataAchievement.data_badge[index+1].num - self.model.achNum) }
    end

    TipsManager.Instance:ShowText({gameObject = self.mainTransform:FindChild("Icon").gameObject, itemData = tipsText})
end
