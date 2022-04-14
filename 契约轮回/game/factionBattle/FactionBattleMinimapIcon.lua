---
--- Author: R2D2
--- Date: 2019-02-18 16:58:12
---
FactionBattleMinimapIcon = FactionBattleMinimapIcon or class("FactionBattleMinimapIcon", BaseCloneItem)
local FactionBattleMinimapIcon = FactionBattleMinimapIcon

function FactionBattleMinimapIcon:ctor(obj, parent_node, layer)
    FactionBattleMinimapIcon.super.Load(self)
end

function FactionBattleMinimapIcon:dctor()
end

function FactionBattleMinimapIcon:LoadCallBack()
    self.nodes = {"click"}
    self:GetChildren(self.nodes)

    self.icon_component = GetImage(self) --:GetComponent("Image")
    self:AddEvent()
end

function FactionBattleMinimapIcon:AddEvent()
    local function call_back(target, x, y)
        if self.data.type == enum.ACTOR_TYPE.ACTOR_TYPE_ROLE then
            return
        end
        GlobalEvent:Brocast(MainEvent.MapTouchIcon, self.data.uid, self.data.coord, true)
    end
    AddClickEvent(self.click.gameObject, call_back)
end

function FactionBattleMinimapIcon:SetRes(res)
    if self.res == res then
        return
    end
    local abName = "factionbattle_image"
    self.res = res
    local function call_back(sprite)
        self.icon_component.sprite = sprite
        self.icon_component:SetNativeSize()
        --SetActive(self.gameObject)
    end
    lua_resMgr:SetImageTexture(self, self.icon_component, abName, res, false, call_back)
end

function FactionBattleMinimapIcon:SelectIcon(id)
    self.is_select = self.data.uid == id
    self:UpdateRes()
end

function FactionBattleMinimapIcon:UpdateRes()
    local data = self.data
    if not data then
        return
    end
    if data.type == enum.ACTOR_TYPE.ACTOR_TYPE_CREEP then
        if (self.state == 1) then
            res = "Sign_Blue"
        elseif self.state == 2 then
            res = "Sign_Red"
        else
            res = "Sign_Gray"
        end
    elseif data.type == enum.ACTOR_TYPE.ACTOR_TYPE_ROLE then
        res = "Sign_Self"
    elseif data.type == enum.ACTOR_TYPE.ACTOR_TYPE_BORN then
        if (data.state == 1) then
            res = "Sign_Blue_Home"
        elseif data.state == 2 then
            res = "Sign_Red_Home"
        end
    end
    self:SetRes(res)
end

function FactionBattleMinimapIcon:RefreshState(state)
    self.state = state
    self:UpdateRes()
end

function FactionBattleMinimapIcon:SetData(data, state)
    self.state = state
    self.data = data
    self.sceneType = sceneType
    self:UpdateRes()
end
