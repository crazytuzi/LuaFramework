DungeonEndWindow = DungeonEndWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject

function DungeonEndWindow:__init(model)
    self.model = model
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.name = "DungeonEndWindow"
    self.dunMgr = self.model.dunMgr
    self.player_item = {}
    self.resList = {
        {file = AssetConfig.dungeonend, type = AssetType.Main}
    }

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
    self.slotList = {}
end


function DungeonEndWindow:OnShow()
    -- ShouhuManager.Instance:request10901()
end

function DungeonEndWindow:OnHide()

end

function DungeonEndWindow:__delete()
    for i,v in ipairs(self.slotList) do
        if v ~= nil then
            v:DeleteMe()
        end
    end
    self.slotList = nil

    self:StopRotateLight()
    self:ClearDepAsset()
end

function DungeonEndWindow:InitPanel()
    local endData = self.dunMgr.endData
    self.gain_list = endData.gain
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.dungeonend))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.transform:Find("Main/Button"):GetComponent(Button).onClick:AddListener(function () self:OnClose() end)
    self.light = self.transform:Find("Main/Light")
    self:StarRotateLight()
    self:InitItem()
end

function DungeonEndWindow:OnClose()
    self.model:CloseEndWin()
    self.dunMgr:ExitDungeon()
end

function DungeonEndWindow:InitItem()
    local Con = self.transform:Find("Main/Con")
    for i,v in ipairs(self.gain_list) do
        if i<5 then
            local parent = Con:Find(string.format("ItemSolt%s", tostring(i)))
            self:AddSlot(v.id, parent)
            parent:Find("Num"):GetComponent(Text).text = tostring(v.value)
        end
    end
end

function DungeonEndWindow:AddSlot(base_id, parent)
    local base = DataItem.data_get[base_id]
    local slot = ItemSlot.New()
    local info = ItemData.New()
    info:SetBase(base)
    local extra = {inbag = false, nobutton = true}
    slot:SetAll(info, extra)
    UIUtils.AddUIChild(parent.gameObject,slot.gameObject)
    table.insert(self.slotList, slot)
end

function DungeonEndWindow:StarRotateLight()
    if self.timer == nil then
        self.timer = LuaTimer.Add(0, 50, function () self:Rota() end)
    else
        LuaTimer.Delete(self.timer)
        self.timer = LuaTimer.Add(0, 50, function () self:Rota() end)
    end
end

function DungeonEndWindow:Rota()
    self.light:RotateAround (self.light.position, self.light.forward, 20 * 0.05)
end

function DungeonEndWindow:StopRotateLight()
    LuaTimer.Delete(self.timer)
end