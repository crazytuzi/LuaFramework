WakeHeadItem = WakeHeadItem or class("WakeHeadItem", BaseItem)
local WakeHeadItem = WakeHeadItem

function WakeHeadItem:ctor(parent_node, layer)
    self.abName = "wake"
    self.assetName = "WakeHeadItem"
    self.layer = layer

    self.model = WakeModel:GetInstance()
    WakeHeadItem.super.Load(self)
end

function WakeHeadItem:dctor()
end

function WakeHeadItem:LoadCallBack()
    self.nodes = {
        "mask/icon", "title",
    }
    self:GetChildren(self.nodes)
    self:AddEvent()

    self.icon = GetImage(self.icon)
    self.title = GetImage(self.title)

    self:UpdateView()
end

function WakeHeadItem:AddEvent()
end

--data:db_wake
function WakeHeadItem:SetData(data)
    self.data = data
    if self.is_loaded then
        self:UpdateView()
    end
end

function WakeHeadItem:UpdateView()
    lua_resMgr:SetImageTexture(self, self.title, 'wake_image', self.data.name_res .. "_2")
    lua_resMgr:SetImageTexture(self, self.icon, 'main_image', self.data.pic, true)
end