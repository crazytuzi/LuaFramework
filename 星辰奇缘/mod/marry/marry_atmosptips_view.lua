Marry_AtmospTipsView = Marry_AtmospTipsView or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject

function Marry_AtmospTipsView:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.marry_atmosp_tips
    self.name = "Marry_AtmospTipsView"
    self.resList = {
        {file = AssetConfig.marry_atmosp_tips, type = AssetType.Main}
        , {file = AssetConfig.marry_textures, type = AssetType.Dep}
    }

    -----------------------------------------
    self.tabGroupObj = nil

    self.itemText = nil
    self.container = nil
    self.itemList = {}
    self.act_logs_length = 0
    self.itemLength = 20
    -----------------------------------------
end

function Marry_AtmospTipsView:__delete()
    if self.itemSolt1 ~= nil then
        self.itemSolt1:DeleteMe()
        self.itemSolt1 = nil
    end
    if self.itemSolt2 ~= nil then
        self.itemSolt2:DeleteMe()
        self.itemSolt2 = nil
    end
    if self.itemSolt3 ~= nil then
        self.itemSolt3:DeleteMe()
        self.itemSolt3 = nil
    end
    if self.itemSolt4 ~= nil then
        self.itemSolt4:DeleteMe()
        self.itemSolt4 = nil
    end
    if self.itemSolt5 ~= nil then
        self.itemSolt5:DeleteMe()
        self.itemSolt5 = nil
    end
    if self.itemSolt6 ~= nil then
        self.itemSolt6:DeleteMe()
        self.itemSolt6 = nil
    end
    self:ClearDepAsset()

    if self.tabGroup ~= nil then
        self.tabGroup:DeleteMe()
        self.tabGroup = nil
    end
end

function Marry_AtmospTipsView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.marry_atmosp_tips))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self:InitItems()
    self:InitActions()

    self.tabGroupObj = self.transform:FindChild("Main/TabButtonGroup")

    local tabGroupSetting = {
        perWidth = 62,
        perHeight = 118,
        isVertical = true
    }
    self.tabGroup = TabGroup.New(self.tabGroupObj, function(index) self:ChangeTab(index) end, tabGroupSetting)
end

function Marry_AtmospTipsView:Close()
    MarryManager.Instance.model:CloseAtmospTipsWindow()
end

function Marry_AtmospTipsView:InitItems()
    local atmosp_reward
    local itembase
    local itemData

    atmosp_reward = self:GetAtmospReward(399)

    self.itemSolt1 = ItemSlot.New()
    UIUtils.AddUIChild(self.transform:FindChild("Main/AtmospPanel/Reward1/Item1").gameObject, self.itemSolt1.gameObject)
    itembase = BackpackManager.Instance:GetItemBase(atmosp_reward[1][1])
    itemData = ItemData.New()
    itemData:SetBase(itembase)
    itemData.quantity = atmosp_reward[1][2]
    self.itemSolt1:SetAll(itemData)

    self.itemSolt2 = ItemSlot.New()
    UIUtils.AddUIChild(self.transform:FindChild("Main/AtmospPanel/Reward1/Item2").gameObject, self.itemSolt2.gameObject)
    itembase = BackpackManager.Instance:GetItemBase(atmosp_reward[2][1])
    itemData = ItemData.New()
    itemData:SetBase(itembase)
    itemData.quantity = atmosp_reward[2][2]
    self.itemSolt2:SetAll(itemData)

    atmosp_reward = self:GetAtmospReward(699)

    self.itemSolt3 = ItemSlot.New()
    UIUtils.AddUIChild(self.transform:FindChild("Main/AtmospPanel/Reward2/Item1").gameObject, self.itemSolt3.gameObject)
    itembase = BackpackManager.Instance:GetItemBase(atmosp_reward[1][1])
    itemData = ItemData.New()
    itemData:SetBase(itembase)
    itemData.quantity = atmosp_reward[1][2]
    self.itemSolt3:SetAll(itemData)

    self.itemSolt4 = ItemSlot.New()
    UIUtils.AddUIChild(self.transform:FindChild("Main/AtmospPanel/Reward2/Item2").gameObject, self.itemSolt4.gameObject)
    itembase = BackpackManager.Instance:GetItemBase(atmosp_reward[2][1])
    itemData = ItemData.New()
    itemData:SetBase(itembase)
    itemData.quantity = atmosp_reward[2][2]
    self.itemSolt4:SetAll(itemData)

    atmosp_reward = self:GetAtmospReward(999)

    self.itemSolt5 = ItemSlot.New()
    UIUtils.AddUIChild(self.transform:FindChild("Main/AtmospPanel/Reward3/Item1").gameObject, self.itemSolt5.gameObject)
    itembase = BackpackManager.Instance:GetItemBase(atmosp_reward[1][1])
    itemData = ItemData.New()
    itemData:SetBase(itembase)
    itemData.quantity = atmosp_reward[1][2]
    self.itemSolt5:SetAll(itemData)

    self.itemSolt6 = ItemSlot.New()
    UIUtils.AddUIChild(self.transform:FindChild("Main/AtmospPanel/Reward3/Item2").gameObject, self.itemSolt6.gameObject)
    itembase = BackpackManager.Instance:GetItemBase(atmosp_reward[2][1])
    itemData = ItemData.New()
    itemData:SetBase(itembase)
    itemData.quantity = atmosp_reward[2][2]
    self.itemSolt6:SetAll(itemData)
end

function Marry_AtmospTipsView:GetAtmospReward(value)
    local data = DataWedding.data_atmosp_reward[string.format("%s_%s", self.model.type, value)]
    if RoleManager.Instance.RoleData.sex == 1 then
        return data.male_reward
    else
        return data.famale_reward
    end
end

---------------------------------------------

function Marry_AtmospTipsView:InitActions()
    self.itemText = self.transform:FindChild("Main/ActionPanel/Mask/Text").gameObject
    self.container = self.transform:FindChild("Main/ActionPanel/Mask/Container").gameObject

    self.itemList = {}
    for i = 1, self.itemLength do
        local item = GameObject.Instantiate(self.itemText)
        UIUtils.AddUIChild(self.container, item)
        item:GetComponent(Text).text = ""
        table.insert(self.itemList, MsgItemExt.New(item:GetComponent(Text), 240, 18, 23))
    end
end

function Marry_AtmospTipsView:UpdateActions()
    -- self.model.act_logs = { { msg = "兑换宝图({assets_1,90002,111}兑111张)" }
    --     , { msg = "兑换宝图({assets_1,90002,111}兑111张)" }
    --     , { msg = "兑换宝图({assets_1,90002,111}兑111张)" }}
    if self.act_logs_length ~= #self.model.act_logs then -- 长度有改变时才更新
        self.act_logs_length = #self.model.act_logs
        local index = self.act_logs_length
        for i = 1, self.itemLength do
            local act_logs_data = self.model.act_logs[index]
            if act_logs_data ~= nil then
                -- self.itemList[i]:GetComponent(Text).text = MessageParser.GetMsgData(act_logs_data.msg).showString
                self.itemList[i]:SetData(act_logs_data.msg)
            else
                self.itemList[i]:SetData("")
            end
            index = index - 1
        end
    end
end

---------------------------------------------

function Marry_AtmospTipsView:ChangeTab(index)
    if index == 1 then
        self.transform:FindChild("Main/AtmospPanel").gameObject:SetActive(true)
        self.transform:FindChild("Main/ActionPanel").gameObject:SetActive(false)
    elseif index == 2 then
        self.transform:FindChild("Main/AtmospPanel").gameObject:SetActive(false)
        self.transform:FindChild("Main/ActionPanel").gameObject:SetActive(true)
        self:UpdateActions()
    end
end