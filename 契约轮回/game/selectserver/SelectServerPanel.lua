---
--- Created by  Administrator
--- DateTime: 2019/2/20 16:25
---
SelectServerPanel = SelectServerPanel or class("SelectServerPanel", WindowPanel)
local this = SelectServerPanel

function SelectServerPanel:ctor()
    self.abName = "selectserver"
    self.assetName = "SelectServerPanel"
    self.image_ab = "selectserver_image";
    self.layer = "UI"
    self.events = {}
    self.global_events = {}
    self.use_background = true
    self.show_sidebar = false
    self.panel_type = 3
    self.model = SelectServerModel:GetInstance()
    self.leftItems = {}
    self.rightItems = {}
    self.pageIndex = -1

end

function SelectServerPanel:dctor()
    self.model:RemoveTabListener(self.events)
    GlobalEvent:RemoveTabListener(self.global_events)
    for i, v in pairs(self.leftItems) do
        v:destroy()
        v = nil
    end
    for i, v in pairs(self.rightItems) do
        v:destroy()
        v = nil
    end
    self.rightItems = {}
    self.leftItems = {}
end

function SelectServerPanel:LoadCallBack()
    self.nodes = {
        "leftScrollView/Viewport/leftItemContent","SelectServerLeftItem","SelectServerRightItem","rightScrollView/Viewport/rightItemContent","rightScrollView"
    }
    self:GetChildren(self.nodes)
    self.rightScrollView = GetScrollRect(self.rightScrollView)
    self:InitUI()
    self:AddEvent()
    self:SetTileTextImage("selectserver_image","selectSer_title")
    self:SetPanelSize(872,524)
 --  SelectServerController:GetInstance():RequsetServerList()
    self:SelectServerList()

    -- NoticeController:GetInstance():RequestOnlineNotice()
end

function SelectServerPanel:Open(isDevChannelLogin)
    WindowPanel.Open(self)
    self.model.isDevChannelLogin = isDevChannelLogin
end

function SelectServerPanel:InitUI()

end

function SelectServerPanel:AddEvent()
   -- self.events[#self.events + 1 ] = self.model:AddListener(SelectServerEvent.SelectServerList,handler(self,self.SelectServerList))
    self.events[#self.events + 1 ] = self.model:AddListener(SelectServerEvent.SelectServerLeftClick,handler(self,self.SelectServerLeftClick))
    self.global_events[#self.global_events + 1 ] = GlobalEvent:AddListener(SelectServerEvent.SelectServerRightClick,handler(self,self.SelectServerRightClick))


end

function SelectServerPanel:InitLeftItems()
    for i = 1, 2 do
        self.leftItems[i] = SelectServerLeftItem(self.SelectServerLeftItem.gameObject,self.leftItemContent,"UI")
        self.leftItems[i]:SetData(self.model.sortServers[i],i)
    end
    for i = #self.model.sortServers ,3,-1 do
        self.leftItems[i] = SelectServerLeftItem(self.SelectServerLeftItem.gameObject,self.leftItemContent,"UI")
        self.leftItems[i]:SetData(self.model.sortServers[i],i)
    end
end


function SelectServerPanel:SelectServerList()
    self:InitLeftItems()

    if table.isempty(self.model.recent) then
        self:SelectServerLeftClick(self.model.sortServers[1],1)
    else
        self:SelectServerLeftClick(self.model.sortServers[2],2)
    end

end

function SelectServerPanel:SelectServerLeftClick(list,index)
    if self.pageIndex == index then
        return
    end
    self.pageIndex = index
    self:UpdateRightItems(list)
    self:SetSelectLeftItems()
    self.rightScrollView.verticalNormalizedPosition = 1
end

function SelectServerPanel:UpdateRightItems(list)
    local tab = list
    self.rightItems = self.rightItems or {}
    for i = 1,#tab do
        local item = self.rightItems[i]
        if not item then
            item = SelectServerRightItem(self.SelectServerRightItem.gameObject,self.rightItemContent,"UI")
            self.rightItems[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(tab[i])
    end
    for i = #tab + 1,#self.rightItems do
        local item = self.rightItems[i]
        item:SetVisible(false)
    end

end

function SelectServerPanel:SetSelectLeftItems()
    for i, v in pairs(self.leftItems) do
        if i == self.pageIndex then
            v:Select(true)
        else
            v:Select(false)
        end
    end
end

function SelectServerPanel:SelectServerRightClick()
    self:Close()
end

