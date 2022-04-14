---
--- Created by  Administrator
--- DateTime: 2019/9/9 19:54
---
GodOrderJumpItem = GodOrderJumpItem or class("GodOrderJumpItem", BaseCloneItem)
local this = GodOrderJumpItem

function GodOrderJumpItem:ctor(obj, parent_node, parent_panel)
    GodOrderJumpItem.super.Load(self)
    self.events = {}
end

function GodOrderJumpItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function GodOrderJumpItem:LoadCallBack()
    self.nodes = {
        "icon"
    }
    self:GetChildren(self.nodes)
    self.icon = GetImage(self.icon)
    self:InitUI()
    self:AddEvent()
end

function GodOrderJumpItem:InitUI()

end

function GodOrderJumpItem:AddEvent()

end

function GodOrderJumpItem:ShowJumpInfo(jump_tbl)
    local abName, assetName = GetLinkAbAssetName(jump_tbl[1], jump_tbl[2])
    if abName ~= nil and assetName ~= nil then
        lua_resMgr:SetImageTexture(self, self.icon, abName, assetName)
    end

    local function call_back()
        --UnpackLinkConfig(jpTbl[1] .. "@" .. jpTbl[2] .. '@' .. jpTbl[3] .. '@' .. jpTbl[4])
        OpenLink(unpack(jump_tbl))
    end

    AddClickEvent(self.icon.gameObject, call_back)

    self.need_loaded_end = false
end