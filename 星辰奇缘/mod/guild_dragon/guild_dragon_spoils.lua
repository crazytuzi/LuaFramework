GuildDragonSpoils = GuildDragonSpoils or BaseClass(BasePanel)

function GuildDragonSpoils:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "GuildDragonSpoils"

    self.resList = {
        {file = AssetConfig.guilddragon_spoils, type = AssetType.Main}
    }

    self.slotList = {}
    self.updateListener = function() self:Update() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function GuildDragonSpoils:__delete()
    self.OnHideEvent:Fire()
    if self.slotList ~= nil then
        for _,slot in pairs(self.slotList) do
            slot:DeleteMe()
        end
        self.slotList = nil
    end
    if self.grid ~= nil then
        self.grid:DeleteMe()
        self.grid = nil
    end
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
end

function GuildDragonSpoils:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guilddragon_spoils))
    self.gameObject.name = self.name
    NumberpadPanel.AddUIChild(self.parent, self.gameObject)

    local t = self.gameObject.transform
    self.transform = t

    self.layout = LuaBoxLayout.New(t:Find("Scroll/Container"), {axis = BoxLayoutAxis.Y, cspacing = 10})
    self.grid = LuaGridLayout.New(t:Find("Scroll/Container/Grid"), {column = 6, cellSizeX = 60, cellSizeY = 60, cspacing = 12, rspacing = 12, borderleft = 3})
    self.descObj = t:Find("Scroll/Container/Desc").gameObject
    self.nothingObj = t:Find("Nothing").gameObject
end

function GuildDragonSpoils:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GuildDragonSpoils:OnOpen()
    self:RemoveListeners()
    GuildDragonManager.Instance.rewardEvent:AddListener(self.updateListener)

    local guildData = GuildManager.Instance.model.my_guild_data
    if guildData.GuildId ~= 0 then
        GuildDragonManager.Instance:send20511(2, guildData.GuildId, guildData.PlatForm, guildData.ZoneId)
    end

    self:Update()
end

function GuildDragonSpoils:OnHide()
    self:RemoveListeners()
end

function GuildDragonSpoils:RemoveListeners()
    GuildDragonManager.Instance.rewardEvent:RemoveListener(self.updateListener)
end

function GuildDragonSpoils:Update()
    local guildData = GuildManager.Instance.model.my_guild_data
    local list = nil
    if guildData.GuildId == 0 then
        list = {}
    else
        list = self.model.rewardList[2][BaseUtils.Key(guildData.GuildId, guildData.PlatForm, guildData.ZoneId)] or {}
    end

    local length = #list
    self.layout:ReSet()
    self.grid:ReSet()
    for i,dat in ipairs(list) do
        local slot = self.slotList[i]
        if slot == nil then
            slot = ItemSlot.New()
            self.slotList[i] = slot
        end
        slot:SetAll(DataItem.data_get[dat.base_id], {inbag = false, nobutton = true})
        slot:SetNum(dat.num)
        self.grid:AddCell(slot.gameObject)
    end
    for i=length + 1,#self.slotList do
        self.slotList[i].gameObject:SetActive(false)
    end

    self.layout:AddCell(self.grid.panel.gameObject)
    self.layout:AddCell(self.descObj)

    self.layout.panel.gameObject:SetActive(length ~= 0)
    self.nothingObj:SetActive(length == 0)
end
