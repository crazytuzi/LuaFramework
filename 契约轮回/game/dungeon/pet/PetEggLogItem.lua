---
--- Created by R2D2.
--- DateTime: 2019/6/15 11:16
---
PetEggLogItem = PetEggLogItem or class("PetEggLogItem", Node)
local this = PetEggLogItem

function PetEggLogItem:ctor(obj, data)
    self.transform = obj.transform
    self.gameObject = self.transform.gameObject
    self.transform_find = self.transform.Find

    self.data = data
    self.events = {}

    self:InitUI()
    self:AddEvent()
    self:RefreshView()
end

function PetEggLogItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function PetEggLogItem:InitUI()
    self.is_loaded = true
    self.nodes = {
        "time", "Bg", "log",
    }
    self:GetChildren(self.nodes)

    self.bgImage = GetImage(self.Bg)
    self.logText = GetLinkText(self.log)
    self.timeText = GetText(self.time)

    self.logText:AddClickListener(handler(self, self.HandleLogClick))
end

function PetEggLogItem:AddEvent()
    AddEventListenerInTab(RoleInfoEvent.QUERY_OTHER_ROLE, handler(self, self.HandleRoleInfoQuery), self.events)
end

function PetEggLogItem:RefreshView()
    if (self.data) then

        local playerId = self.data.role_id
        local playerName = self.data.role_name

        local itemId = self.data.item_id
        local itemName = ""
        local itemCfg = Config.db_item[itemId]
        local itemColor = tostring(ColorUtil.GetColor(1))
        if itemCfg then
            itemName = itemCfg.name
            itemColor = tostring(ColorUtil.GetColor(itemCfg.color))
        end

        local petsText = ""

        for k, v in pairs(self.data.pets) do
            if type(v) == "number" then
                local petColor = ColorUtil.GetColor(self.data.Config.quality)
                petsText = petsText .. string.format("<color=#%s><a href=pet_%s>[%s]</a></color>", petColor, k, self.data.Config.name)
            else
                petsText = petsText .. string.format("<color=#%s><a href=pet_%s>[%s]</a></color>", itemColor, k, v)
            end
        end

        self.timeText.text = self:FormatTime(self.data.time)
        self.logText.text = string.format("<color=#268FDA><a href=player_%s>%s</a></color> Opened <color=#%s><a href=item_%s>[%s]</a></color>.Obtained",
                playerId, playerName, itemColor, itemId, itemName, itemColor) .. petsText
    end
end

function PetEggLogItem:SetData(data)
    self.data = data
    self:RefreshView()
end

function PetEggLogItem:SetCallBack(callback)
    self.ItemCallBack = callback
end

function PetEggLogItem:HandleRoleInfoQuery(data)
    if data and data.role and data.role.base and data.role.base.id == self.roleid then
        local panel = lua_panelMgr:GetPanelOrCreate(RoleMenuPanel)
        if not panel.isShow then
            panel:Open(data.role.base)
        end
    end
end

function PetEggLogItem:HandleLogClick(str)
    local strTab = string.split(str, "_")
    if strTab and #strTab > 1 then
        if strTab[1] == "player" then
            self.roleid = strTab[2]
            RoleInfoController:GetInstance():RequestRoleQuery(strTab[2])
        elseif strTab[1] == "item" then
            local itemId = tonumber(strTab[2])
            BagModel:GetInstance():ShowTip(itemId, self.parent or self.transform)
        elseif strTab[1] == "pet" then
            if (self.ItemCallBack) then
                local cache_id = tonumber(strTab[2])
                self.ItemCallBack(self, cache_id)
            end
        end
    end
end

function PetEggLogItem:ShowBg(flag)
    flag = toBool(flag)
    self.bgImage.enabled = flag
end

function PetEggLogItem:FormatTime(time)

    local timeTab = TimeManager:GetTimeDate(time)
    local timeStr = ""
    if timeTab.month then
        timeStr = timeStr .. string.format("%02d", timeTab.month) .. "-"
    end
    if timeTab.day then
        timeStr = timeStr .. string.format("%02d", timeTab.day) .. "    "
    end
    if timeTab.hour then
        timeStr = timeStr .. string.format("%02d", timeTab.hour) .. ":"
    end
    if timeTab.min then
        timeStr = timeStr .. string.format("%02d", timeTab.min) .. ":"
    end
    if timeTab.sec then
        timeStr = timeStr .. string.format("%02d", timeTab.sec)
    end

    return timeStr
end