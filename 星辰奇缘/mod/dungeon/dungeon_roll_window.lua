DungeonRollWindow = DungeonRollWindow or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject

function DungeonRollWindow:__init(model)
    self.model = model
    self.name = "RollWindow"
    self.dunMgr = self.model.dunMgr
    self.windowId = WindowConfig.WinID.fubenrollwin
    self.rolled = false
    self.player_item = {}
    self.resList = {
        {file = AssetConfig.dungeonroll, type = AssetType.Main}
        ,{file = AssetConfig.heads, type = AssetConfig.Dep}
    }
    self.lastTime = Time.time
    self.slotList = {}
end

function DungeonRollWindow:__delete()
    for i,v in ipairs(self.slotList) do
        if v ~= nil then
            v:DeleteMe()
        end
    end
    self.slotList = nil

    self:StopCountDown()
    self:ClearDepAsset()
end

function DungeonRollWindow:InitPanel()
    local rollData = self.dunMgr.rollData
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.dungeonroll))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas, self.gameObject)
    self.transform = self.gameObject.transform
    self.transform:SetSiblingIndex(1)
    self.timeTxt = self.transform:Find("Main/RollStatus/Time"):GetComponent(Text)
    self.timebar = self.transform:Find("Main/RollStatus/Bar")

    local text = self.transform.transform:FindChild("Main/ExtText"):GetComponent(Text)
    self.textExt = MsgItemExt.New(text, 190, 16, 26)

    self.initdata = self.dunMgr.rollData
    self.rollID = self.initdata.roll_id
    self.playerData = self.initdata.roll_item[1].roles
    --self.startTime = os.time() - self.initdata.end_tick
    self.startTime = self.initdata.end_tick - BaseUtils.BASE_TIME
    -- -- print("---------------开始--------------------")
    -- print(self.initdata.end_tick)
    -- print(BaseUtils.BASE_TIME)
    -- print(self.startTime)
    self.currTime = self.startTime

    self:StarCountDown(self.startTime)
    self.transform:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function () self:OnClose() end)
    self.button = self.transform:Find("Main/Button"):GetComponent(Button)
    self.button.onClick:AddListener(function () self:OnRoll() end)
    self:InitRollItem(self.initdata.roll_item[1].base_id, self.initdata.key)
    for i,v in ipairs(self.playerData) do
        self:InitPlayer(v,i)
    end
end

function DungeonRollWindow:OnClose()
    self.model:CloseRollWin()
end

function DungeonRollWindow:InitRollItem(base_id, id)
    local base = DataItem.data_get[base_id]
    local slot = ItemSlot.New()
    local info = ItemData.New()
    info:SetBase(base)
    local extra = {inbag = false, nobutton = true}
    slot:SetAll(info, extra)
    table.insert(self.slotList, slot)
    local parent = self.transform:Find("Main/RollStatus/Item")
    UIUtils.AddUIChild(parent.gameObject,slot.gameObject)
    if self.initdata.roll_item[1].num > 1 then
        self.transform:Find("Main/RollStatus/Name"):GetComponent(Text).text = string.format("%s x %s", base.name, tostring(self.initdata.roll_item[1].num))
    else
        self.transform:Find("Main/RollStatus/Name"):GetComponent(Text).text = base.name
    end

    local crystalData = DataFairy.data_crystal[string.format("%s_%s", id, base_id)]
    if crystalData == nil or crystalData.crystal == 0 then
        self.textExt.contentTxt.gameObject:SetActive(false)
        self.button.gameObject.transform.localPosition = Vector3(153.7, -70.9, 0)
    else
        self.textExt.contentTxt.gameObject:SetActive(true)
        local showMsg = string.format(TI18N("未抽中可得：{assets_1,90035,%s}"), crystalData.crystal)
        self.textExt:SetData(showMsg)
        self.button.gameObject.transform.localPosition = Vector3(153.7, -85, 0)
    end
end

function DungeonRollWindow:InitPlayer(data, index)
    local uid = string.format("%s_%s_%s", tostring(data.r_id), tostring(data.r_zone), tostring(data.r_platform))
    local item = self.transform:Find(string.format("Main/PlayerGroup/Player%s", tostring(index)))
    local name = data.classes .. "_" .. data.sex
    local sprite = self.assetWrapper:GetSprite(AssetConfig.heads, name)
    item:Find("HeadBg/head"):GetComponent(Image).sprite = sprite
    item:Find("Name"):GetComponent(Text).text = data.name
    item:Find("Name").gameObject:SetActive(true)
    self.player_item[uid] = item
end

function DungeonRollWindow:PraseUpdateData(data)
    if data.roll_id == self.rollID then
        for i,v in ipairs(data.roles) do
            self:UpdatePlayer(v)
        end
    end
end

function DungeonRollWindow:UpdatePlayer(data)
    local uid = string.format("%s_%s_%s", tostring(data.r_id), tostring(data.r_zone), tostring(data.r_platform))
    local selfuid = string.format("%s_%s_%s", tostring(RoleManager.Instance.RoleData.id), tostring(RoleManager.Instance.RoleData.zone_id), tostring(RoleManager.Instance.RoleData.platform))
    if selfuid == uid then
        self.rolled = true
        self.transform:Find("Main/Button/Image").gameObject:SetActive(false)
        self.transform:Find("Main/Button/Text"):GetComponent(Text).text = TI18N("已投掷")
        UIUtils.AddUIChild(self.transform:Find("Main/Button").gameObject, self.transform:Find("Main/Button/Text").gameObject)
    end
    local item = self.player_item[uid]
    if data.choice == 1 then
        item:Find("RollIcon").gameObject:SetActive(true)
        item:Find("Text"):GetComponent(Text).text = tostring(data.rand_num)
        item:Find("Text").gameObject:SetActive(true)
    end
    if data.reward == 1 then
        -- LuaTimer.Add(3000, function() self:OnClose() end)
        self:StopCountDown()
    end
            -- reward = 1,
            -- rand_num = 96,
            -- choice = 1,
end

function DungeonRollWindow:StarCountDown()
    if self.timer ~= nil then
        LuaTimer.Delete(self.timer)
        self.timer = nil
    end
    self.lastTime = Time.time
    self.timer = LuaTimer.Add(0, 50, function () self:SetTime() end)
end

function DungeonRollWindow:StopCountDown()
    if self.timeTxt ~= nil then
        self.timeTxt.text = "0"
    end
    if self.timebar ~= nil then
        self.timebar.sizeDelta = Vector2( 0, self.timebar.sizeDelta.y)
    end
    if self.timer ~= nil then
        LuaTimer.Delete(self.timer)
        self.timer = nil
    end
end

function DungeonRollWindow:SetTime()
    self.timeTxt.text = tostring(math.floor(self.currTime))
    self.currTime = self.currTime - (Time.time - self.lastTime)
    self.lastTime = Time.time
    self.timebar.sizeDelta = Vector2( self.currTime/self.startTime * 150, self.timebar.sizeDelta.y)
    if self.currTime < 0 then
        self:StopCountDown()
        if self.rolled == false then
            self.dunMgr:Require12302(self.rollID, self.initdata.roll_item[1].id)
        end
    end
end

function DungeonRollWindow:OnRoll()
    self.dunMgr:Require12302(self.rollID, self.initdata.roll_item[1].id)
end

-- roll数据 = {
--     roll_id = 1,
--     roll_item = {
--         [1] = {
--             num = 1,
--             has_reward = 0,
--             base_id = 23523,
--             roles = {
--                 [1] = {
--                     r_id = 5,
--                     sex = 0,
--                     classes = 1,
--                     choice = 0,
--                     r_platform = "dev",
--                     r_zone = 2,
--                     rand_num = 1,
--                     name = "克林维恩",
--                     reward = 0,
--                 },
--             },
--             id = 1,
--         },
--     },
--     end_tick = 1448456824,
-- }

-- roll点结果 = {
--     id = 1,
--     roll_id = 7,
--     roles = {
--         [1] = {
--             r_platform = "dev",
--             r_id = 2,
--             reward = 1,
--             rand_num = 96,
--             choice = 1,
--             r_zone = 2,
--         },
--     },
--     end_tick = 1448464861,
-- }
