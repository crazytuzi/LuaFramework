-- 公会副本
-- ljh 20170301
GuildDungeonWindow = GuildDungeonWindow or BaseClass(BaseWindow)

function GuildDungeonWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.guilddungeonwindow
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.winLinkType = WinLinkType.Link

    self.resList = {
        {file = AssetConfig.guilddungeonwindow, type = AssetType.Main}
        ,{file = AssetConfig.guilddungeon_textures, type = AssetType.Dep}
        ,{file = AssetConfig.rank_textures, type = AssetType.Dep}
        ,{file = string.format(AssetConfig.effect, 10096), type = AssetType.Main}
        ,{file = string.format("prefabs/ui/bigatlas/guilddungeon%s.unity3d", 1), type = AssetType.Main}
    }

    -----------------------------------------------
    self.timerId = nil

    self.mapIndex = 1
    self.strongPointList = {}

    self.descTips = {TI18N("1.每<color='#ffff00'>周一至周六</color>可挑战，<color='#ffff00'>周一0:00</color>自动重置副本")
                , TI18N("2.同一怪物同时只能由1名勇士挑战")
                , TI18N("3.小怪只能单人挑战")
                , TI18N("4.挑战妖魔可获得<color='#ffff00'>兄弟币</color>奖励，击杀妖魔公会可获得<color='#ffff00'>宝物</color>奖励")
                , TI18N("5.各妖魔据点评分<color='#ffff00'>前三名</color>会成为公会英雄，可额外<color='#ffff00'>兄弟币</color>奖励")
            }
    -----------------------------------------------

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end

    self._Update = function() self:Update() end

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)
end

function GuildDungeonWindow:__delete()
    self.OnHideEvent:Fire()

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end

    if self.mapAssetWrapper ~= nil then
        self.mapAssetWrapper:DeleteMe()
        self.mapAssetWrapper = nil
    end

    for key, value in ipairs(self.strongPointList) do
    	value:DeleteMe()
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function GuildDungeonWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guilddungeonwindow))
    self.gameObject.name = "GuildDungeonWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")

    self.mainTransform:FindChild("Close"):GetComponent(Button).onClick:AddListener(function() self:OnClickClose() end)

    self.titleText = self.mainTransform:FindChild("Panel/Title/Text"):GetComponent(Text)

    self.mapTransform = self.mainTransform:Find("Panel/Map")

    self.mapItemPanel = self.mainTransform:Find("Panel/MapItemPanel")
    self.mapItemPanelCloner = self.mapItemPanel:Find("Cloner").gameObject
    self.mapItemPanelCloner.transform:FindChild("Icon"):GetComponent(RectTransform).sizeDelta = Vector2(120,120)
    self.mapItemPanelCloner:SetActive(false)

    self.mainTransform:FindChild("Panel/RankButton"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guilddungeonherorank) end)
    self.mainTransform:FindChild("Panel/EquipButton"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:OpenWindowById(19700) end)
    self.equipButtonText = self.mainTransform:FindChild("Panel/EquipButton/Text"):GetComponent(Text)

    self.nextButton = self.mainTransform:FindChild("Panel/NextButton").gameObject
    self.nextButton:GetComponent(Button).onClick:AddListener(function() self:OnNextButtonClick() end)
    self.preButton = self.mainTransform:FindChild("Panel/PreButton").gameObject
    self.preButton:GetComponent(Button).onClick:AddListener(function() self:OnPreButtonClick() end)

    self.mainTransform:FindChild("Panel/DescButton"):GetComponent(Button).onClick:AddListener(function()
            TipsManager.Instance:ShowText({gameObject = self.mainTransform:FindChild("Panel/DescButton").gameObject, itemData = self.descTips})
        end)
    self.timeItem = self.mainTransform:FindChild("Panel/TimeItem").gameObject
    self.timeText = self.mainTransform:FindChild("Panel/TimeItem/TimeText"):GetComponent(Text)
    self.timeItem2 = self.mainTransform:FindChild("Panel/TimeItem2").gameObject
    self.timeText2 = self.mainTransform:FindChild("Panel/TimeItem2/TimeText"):GetComponent(Text)

    self.preButton:SetActive(false)
    self.nextButton:SetActive(false)
    -- BaseUtils.SetGrey(self.nextButton:GetComponent(Image), true)
end

function GuildDungeonWindow:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function GuildDungeonWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GuildDungeonWindow:OnOpen()
    self:Update()

    GuildDungeonManager.Instance.OnUpdate:Add(self._Update)
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    self.timerId = LuaTimer.Add(0, 5000, function() GuildDungeonManager.Instance:Send19500() end)
end

function GuildDungeonWindow:OnHide()
	for i=1, #self.strongPointList do
		self.strongPointList[i]:Hide()
	end

	GuildDungeonManager.Instance.OnUpdate:Remove(self._Update)
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function GuildDungeonWindow:Update()
	self:UpdateMap(self.mapIndex)
	self:UpdateStrongPoint()
    self:UpdateTimes()
end

function GuildDungeonWindow:UpdateMap(index)
    if self.lastMapIndex ~= index then
        if self.mapAssetWrapper ~= nil then
            self.mapAssetWrapper:DeleteMe()
            self.mapAssetWrapper = nil
        end
    	if self.map ~= nil then
    		GameObject.DestroyImmediate(self.map)
    		self.map = nil
    	end

        self.mapAssetWrapper = AssetBatchWrapper.New()
        self.mapAssetWrapper:LoadAssetBundle({{file = string.format("prefabs/ui/bigatlas/guilddungeon%s.unity3d", index), type = AssetType.Main}}, function() self:OnMapChange(index) end)
        self.lastMapIndex = index
    end


    self.titleText.text = DataGuildDungeon.data_strongpoint[string.format("%s_%s", index, 1)].chapter_name
end

function GuildDungeonWindow:OnMapChange(index)
    self.map = GameObject.Instantiate(self.mapAssetWrapper:GetMainAsset(string.format("prefabs/ui/bigatlas/guilddungeon%s.unity3d", index)))
    UIUtils.AddBigbg(self.mapTransform, self.map)
    self.mapAssetWrapper:ClearMainAsset()
end

function GuildDungeonWindow:UpdateStrongPoint()
    if self.model.guild_dungeon_chapter == nil or self.model.guild_dungeon_chapter.chapters == nil or self.model.guild_dungeon_chapter.chapters[self.mapIndex] == nil then
        return
    end

    self.equipButtonText.text = tostring(self.model.guild_dungeon_chapter.num)

	local data = self.model.guild_dungeon_chapter.chapters[self.mapIndex].strongpoints
	for index, value in ipairs(data) do
		local strongPoint = self.strongPointList[index]
		if strongPoint == nil then
			local transform = GameObject.Instantiate(self.mapItemPanelCloner).transform
			transform:SetParent(self.mapItemPanel)
            transform.localScale = Vector3(1, 1, 1)
            transform.gameObject.name = tostring(index)

            strongPoint = GuildDungeonStrongPoint.New(transform, self.assetWrapper)
            self.strongPointList[index] = strongPoint
		end

		strongPoint:Show()
		strongPoint:Update(value, self.mapIndex)
	end
	for i=#data+1, #self.strongPointList do
		self.strongPointList[i]:Hide()
	end
end

function GuildDungeonWindow:UpdateTimes()
    local color = "#00ff00"
    if self.model.guild_dungeon_chapter.times == 0 then
        color = "#ff0000"
    end
    self.timeText.text = string.format(TI18N("小怪可挑战次数：<color='%s'>%s/%s</color>"), color, self.model.guild_dungeon_chapter.times, 2)

    if self.model.guild_dungeon_chapter.chapters == nil then
        return
    end
    
    local mark = false
    local data = self.model.guild_dungeon_chapter.chapters[self.mapIndex].strongpoints
    for strongpointsIndex, strongpointData in ipairs(data) do
        for monsterIndex, monsterData in ipairs(strongpointData.monsters) do
            if monsterData.challenge ~= 2 then
                local data_unit = DataGuildDungeon.data_unit[string.format("%s_%s_%s", self.mapIndex, strongpointData.strongpoint_id, monsterData.unique)]
                if data_unit ~= nil and data_unit.type == 1 then
                    mark = true
                    break
                end
            end
        end
    end

    if mark then
        local color = "#00ff00"
        if self.model.guild_dungeon_chapter.boss_times == 0 then
            color = "#ff0000"
        end
        self.timeText2.text = string.format(TI18N("BOSS挑战次数：<color='%s'>%s/%s</color>"), color, self.model.guild_dungeon_chapter.boss_times, 1)

        self.timeItem2:SetActive(true)
    else
        self.timeItem2:SetActive(false)
    end
end

function GuildDungeonWindow:OnNextButtonClick()
	NoticeManager.Instance:FloatTipsByString(TI18N("尚未开放"))
end

function GuildDungeonWindow:OnPreButtonClick()

end