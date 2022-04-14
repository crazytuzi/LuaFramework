---
--- Created by  Administrator
--- DateTime: 2019/6/11 11:19
---
MarryPropFriendPanel = MarryPropFriendPanel or class("MarryPropFriendPanel", BasePanel)
local this = MarryPropFriendPanel

function MarryPropFriendPanel:ctor(parent_node, parent_panel)
    self.abName = "marry";
    self.assetName = "MarryPropFriendPanel"
    self.layer = "UI"
    self.use_background = true
    self.model = MarryModel:GetInstance()
   -- self.panel_type = 4							--窗体样式  1 1280*720  2 850*545
    self.events = {} --事件
    self.roleItems = {}

  --  self.roleList = FriendModel:GetInstance():GetFriendList()
end
function MarryPropFriendPanel:Open()
    MarryPropFriendPanel.super.Open(self)
end

function MarryPropFriendPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    for i, v in pairs(self.roleItems) do
        v:destroy()
    end
    self.roleItems = {}
end

function MarryPropFriendPanel:LoadCallBack()
    self.nodes = {
        "itemScrollView/Viewport/itemContent","NoFriend","MarryPropFriendItem","closeBtn","bgObj/bg1",
    }
    self:GetChildren(self.nodes)

    --self:InitUI()
    self:AddEvent()
    FriendController:GetInstance():RequestFriendList()
end

function MarryPropFriendPanel:InitUI()
    --dump(self.roleList)
    local friendList = self.model:GetFriendList()
    if table.isempty(friendList) then
        SetVisible(self.NoFriend,true)
        SetVisible(self.bg1,false)
    else
        SetVisible(self.NoFriend,false)
        SetVisible(self.bg1,true)
        for i = 1, #friendList do
            local item = self.roleItems[i]
            if not item then
                item = MarryPropFriendItem(self.MarryPropFriendItem.gameObject,self.itemContent,"UI")
                self.roleItems[i] = item
            end
            item:SetData(friendList[i])
        end
    end
end

function MarryPropFriendPanel:AddEvent()
    
    local function call_back()
        self:Close()
    end
    AddClickEvent(self.closeBtn.gameObject,call_back)

    --FriendEvent.HandleFriendList
    self.events[#self.events] = GlobalEvent:AddListener(FriendEvent.HandleFriendList,handler(self,self.HandleFriendList))

end

function MarryPropFriendPanel:HandleFriendList()
    self:InitUI()
end