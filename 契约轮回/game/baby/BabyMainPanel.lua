---
--- Created by  Administrator
--- DateTime: 2019/8/28 14:46
---
BabyMainPanel = BabyMainPanel or class("BabyMainPanel", WindowPanel)
local this = BabyMainPanel

function BabyMainPanel:ctor(parent_node, parent_panel)

    self.abName = "baby"
    self.assetName = "BabyMainPanel"
    self.image_ab = "baby_image";
    self.layer = "UI"
    self.panel_type = 2
    self.events = {}
    self.model = BabyModel:GetInstance()
    self.show_sidebar = true        --是否显示侧边栏
    --self.is_show_money=true
    if self.show_sidebar then
        -- 侧边栏配置
        --self.sidebar_data = {
        --    { text = ConfigLanguage.Baby.culture, id = 1 },
        --    { text = ConfigLanguage.Baby.order, id = 2 },
        --    { text = ConfigLanguage.Baby.toys, id = 3 },
        --}

        if self.model:IsBirth(1) or self.model:IsBirth(2)  then
            self.sidebar_data = {
                { text = ConfigLanguage.Baby.culture, id = 1 },
                { text = ConfigLanguage.Baby.order, id = 2 },
                { text = ConfigLanguage.Baby.toys, id = 3 },
				{ text = ConfigLanguage.Baby.child, id = 4 },
            }
        else
            self.sidebar_data = {
                { text = ConfigLanguage.Baby.culture, id = 1 },
                { text = ConfigLanguage.Baby.order, id = 2 },
               -- { text = ConfigLanguage.Baby.toys, id = 3 },
            }
        end
    end
end

function BabyMainPanel:dctor()
    self.model:RemoveTabListener(self.events)
    if self.currentView then
        self.currentView:destroy();
    end
    self.model.isOpenBaby = false
end

function BabyMainPanel:Open(page,babyId)
    WindowPanel.Open(self)
    self.model.isOpenBaby = true
    self.babyId = babyId
    self.index = page or 1
    if self.index then
        self:SetTabIndex(self.index)
    end
end

function BabyMainPanel:LoadCallBack()
    self.nodes = {

    }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()
    --baby_titile_tex
    self:SetTileTextImage("baby_image", "baby_titile_tex");
    self:UpdateRedPoint()
end

function BabyMainPanel:SetTabIndex()
    if self.bg_win and  self.index then
        self.bg_win:SetTabIndex(self.index)
    end
    if self.bg_win and not self.index then
        self.bg_win:SetTabIndex(1)
    end
end


function BabyMainPanel:InitUI()

end

function BabyMainPanel:AddEvent()
    self.events[#self.events + 1] = self.model:AddListener(BabyEvent.UpdateRedPoint, handler(self, self.UpdateRedPoint))
end

function BabyMainPanel:UpdateRedPoint()
    local isRed1 = false
    --培养界面红点
    for gender, reds in pairs(self.model.babyCulRedPoints) do
        for i, v in pairs(reds) do
            if v == true then
                isRed1 = true
                break
            end
        end
    end
    self:SetIndexRedDotParam(1,isRed1 or self.model.isRecordRedPoint or self.model.babyShowRed)

    local isRed2 = false
    for id, reds in pairs(self.model.babyOrderRedPoints) do
        for i, v in pairs(reds) do
            if v == true then
                isRed2 = true
                break
            end
        end
    end
    self:SetIndexRedDotParam(2,isRed2)

    local isRed3 = false
    for i, v in pairs(self.model.babyToysRedPoints) do
        if v == true then
            isRed3 = true
            break
        end
    end

    self:SetIndexRedDotParam(3,isRed3)

    local isRed4 = false
    for i, v in pairs(self.model.babyWingRedPoints) do
        if v == true then
            isRed4 = true
            break
        end
    end

    self:SetIndexRedDotParam(4,isRed4)
end



function BabyMainPanel:SwitchCallBack(index)
    if self.currentView then
        self.currentView:destroy();
    end

    self.currentView = nil
    if index == 1 then
        self.currentView = BabyCulturePanel(self.transform, "UI");
        self:PopUpChild(self.currentView)

    elseif index == 2 then
        self.currentView = BabyOrderPanel(self.transform, "UI",self.babyId);
        self:PopUpChild(self.currentView)

    elseif index == 3 then
        self.currentView = BabyToysPanel(self.transform, "UI");
        self:PopUpChild(self.currentView)

    elseif index == 4 then
        self.currentView = BabyChangePanel(self.transform, "UI");
        self:PopUpChild(self.currentView)

    --elseif index == 4 then
    --    self.currentView = MarketRecordPanel(self.transform, "UI");
    --    self:PopUpChild(self.currentView)
    end
    self.selectedIndex = index

end