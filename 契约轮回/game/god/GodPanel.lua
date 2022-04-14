---
--- Created by  Administrator
--- DateTime: 2019/9/6 15:20
---
GodPanel = GodPanel or class("GodPanel", WindowPanel)
local this = GodPanel

function GodPanel:ctor(parent_node, parent_panel)
    self.abName = "god"
    self.assetName = "GodPanel"
    self.image_ab = "god_image";
    self.layer = "UI"
    self.panel_type = 2
    self.events = {}
    self.model = GodModel:GetInstance()
    self.show_sidebar = true        --是否显示侧边栏
    --self.is_show_money=true
    --if self.show_sidebar then
    --    -- 侧边栏配置
    --    self.sidebar_data = {
    --        { text = ConfigLanguage.god.god, id = 1 },
    --        { text = ConfigLanguage.god.figure, id = 2 },
    --    }
    --end
end

function GodPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    if self.currentView then
        self.currentView:destroy();
    end
end

function GodPanel:Open(page)
    WindowPanel.Open(self)
    self.model.isOpenBaby = true
    self.index = page or 1
    if self.index then
        self:SetTabIndex(self.index)
    end
end


function GodPanel:LoadCallBack()
    self.nodes = {

    }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()
    --baby_titile_tex
    self:SetTileTextImage("god_image", "god_title_tex");
    self:CheckRedPoint()
end


function GodPanel:SetTabIndex()
    if self.bg_win and  self.index then
        self.bg_win:SetTabIndex(self.index)
    end
    if self.bg_win and not self.index then
        self.bg_win:SetTabIndex(1)
    end
end


function GodPanel:InitUI()

end

function GodPanel:AddEvent()
    self.events[#self.events + 1]  = GlobalEvent:AddListener(GodEvent.CheckRedPoint,handler(self,self.CheckRedPoint))
end

function GodPanel:CheckRedPoint()
    if self.model.godRedPoints[1] == true or self.model.godRedPoints[2] == true then
        self:SetIndexRedDotParam(1,true)
    else
        self:SetIndexRedDotParam(1,false)
    end
    self:SetIndexRedDotParam(2,self.model.godRedPoints[3])
    self:SetIndexRedDotParam(3,self.model.godRedPoints[4])

end

function GodPanel:SwitchCallBack(index)
    if self.currentView then
        self.currentView:destroy();
    end

    self.currentView = nil
    if index == 1 then
        self.currentView = GodMainPanel(self.transform, "UI");
        self:PopUpChild(self.currentView)

    elseif index == 2 then
        self.currentView = GodFigurePanel(self.transform, "UI",self.babyId);
        self:PopUpChild(self.currentView)
    elseif index == 3 then
        self.currentView = GodEquipPanel(self.transform, "UI",self.babyId);
        self:PopUpChild(self.currentView)
    end
    self.selectedIndex = index

end