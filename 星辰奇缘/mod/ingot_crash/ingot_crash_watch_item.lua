IngotCrashWatchItem = IngotCrashWatchItem or BaseClass()

function IngotCrashWatchItem:__init(model, gameObject)
    self.model = model
    self.gameObject = gameObject

    self.transform = gameObject.transform
    self.bgImage = gameObject:GetComponent(Image)

    self.playerList = {}
    for i=1,2 do
        local tab = {}
        tab.nameText = self.transform:Find(string.format(string.format("Name%s", i))):GetComponent(Text)
        tab.headSlot = HeadSlot.New()
        NumberpadPanel.AddUIChild(self.transform:Find(string.format(string.format("Head%s", i))), tab.headSlot.gameObject)
        self.playerList[i] = tab
    end

    self.watchBtn = self.transform:Find("Watch"):GetComponent(Button)
    self.watchBtn.onClick:AddListener(function() self:OnWatch() end)
end

function IngotCrashWatchItem:__delete()
    for _,v in ipairs(self.playerList) do
        v.headSlot:DeleteMe()
    end
    self.model = nil
    self.gameObject = nil
end

function IngotCrashWatchItem:update_my_self(data, index)
    self.data = data
    self.playerList[1].nameText.text = data.first_name
    self.playerList[1].headSlot:SetAll({id = data.rid1, platform = data.platform1, zone_id = data.zone_id1, classes = data.first_classes, sex = data.first_sex}, {isSmall = true})
    self.playerList[2].nameText.text = data.second_name
    self.playerList[2].headSlot:SetAll({id = data.rid2, platform = data.platform2, zone_id = data.zone_id2, classes = data.second_classes, sex = data.second_sex}, {isSmall = true})
    if index % 2 == 1 then
        self.bgImage.color = ColorHelper.ListItem1
    else
        self.bgImage.color = ColorHelper.ListItem2
    end
end

function IngotCrashWatchItem:SetData(data, index)
    self.update_my_self(data, index)
end

function IngotCrashWatchItem:OnWatch()
    if self.data ~= nil then
        IngotCrashManager.Instance:send20010(self.data.rid1, self.data.platform1, self.data.zone_id1)
    end
    if self.watchCallback ~= nil then
        self.watchCallback()
    end
end

