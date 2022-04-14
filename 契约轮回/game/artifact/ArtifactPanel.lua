---
--- Created by  Administrator
--- DateTime: 2020/6/17 14:57
---
ArtifactPanel = ArtifactPanel or class("ArtifactPanel", WindowPanel)
local this = ArtifactPanel

function ArtifactPanel:ctor(parent_node, parent_panel)
    self.abName = "artifact"
    self.assetName = "ArtifactPanel"
    self.layer = "UI"
    self.events = {}
    self.gevents = {}
    self.win_type = 1 --窗体样式  1 1280*720
    self.show_sidebar = true --是否显示侧边栏
    self.sidebar_style = 2
    self.panels = {}
    self.pageItems = {}
    self.moneyItems = {}
    self.model = ArtifactModel:GetInstance()    self.sidebar_data =
    {
        { text = ArtifactModel.desTab.artielem, id = 1, show_lv = GetSysOpenDataById("1460@1"), open_lv = GetSysOpenDataById("1460@1"), show_task = GetSysOpenTaskById("1460@1"), open_task = GetSysOpenTaskById("1460@1"),icon = "bag:bag_icon_ware_s", dark_icon = "bag:bag_icon_ware_n" },
        { text = ArtifactModel.desTab.equip,id = 2,show_lv = GetSysOpenDataById("1460@1"), open_lv = GetSysOpenDataById("1460@1"), show_task = GetSysOpenTaskById("1460@1"), open_task = GetSysOpenTaskById("1460@1"),icon = "bag:bag_icon_ware_s", dark_icon = "bag:bag_icon_ware_n" },
        { text = ArtifactModel.desTab.upGrade, id = 3 , icon = "bag:bag_icon_ware_s", dark_icon = "bag:bag_icon_ware_n"},
        { text = ArtifactModel.desTab.enchant, id = 4 , icon = "bag:bag_icon_ware_s", dark_icon = "bag:bag_icon_ware_n"},
    }
end

function ArtifactPanel:dctor()
    self.model:RemoveTabListener(self.events)
    GlobalEvent:RemoveTabListener(self.gevents)
    if not table.isempty(self.pageItems) then
        for i, v in pairs(self.pageItems) do
            v:destroy()
        end
        self.pageItems = nil
    end
    for _, item in pairs(self.panels) do
        item:destroy()
    end
    self.panels = {}
    if self.currentView then
        --self.currentView:SetVisible(false)
        self.currentView = nil
    end
     if self.left_menu then
         self.left_menu:destroy()
     end
     self.left_menu = nil
    
    if not table.isempty(self.moneyItems) then
        for i, v in pairs(self.moneyItems) do
            v:destroy()
        end
        self.moneyItems = nil
    end

end

function ArtifactPanel:LoadCallBack()
    self.nodes = {
        "leftObj/LeftMenu","leftObj/ScrollView","leftObj/ScrollView/Viewport/Content","ArtifactPageItem",
        "leftObj","ArtifactMoneyItem","MoneyParent","wenhao","title",
    }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()
    self:SetBackgroundImage("iconasset/icon_big_bg_Artifact_bigBg", "Artifact_bigBg", false)
    self:HideMoney()
    self:HideTitleBarAndMoney()
    self:SetColseImg("artifact_image","artifact_")
    self:SetCloseBtnPos(-95,-30,0);
    SetAlignType(self.leftObj.transform, bit.bor(AlignType.Left, AlignType.Null))
    SetAlignType(self.title.transform, bit.bor(AlignType.Left, AlignType.Null))

    --self:InitFold()
   -- ArtifactController:GetInstance():RequstArtifactListInfo()
    --self:InitFold()
end

function ArtifactPanel:Open(default_tag)
    self.default_table_index = default_tag or 1
    ArtifactPanel.super.Open(self)
end

function ArtifactPanel:InitUI()
    local tab = ArtifactModel.money
    for i = 1, #tab do
        local item  = self.moneyItems[i]
        if not item then
            item = ArtifactMoneyItem(self.ArtifactMoneyItem.gameObject,self.MoneyParent,"UI")
            self.moneyItems[i] = item
        end
        item:SetData(tab[i])
    end
end

function ArtifactPanel:AddEvent()
    local function call_back()
        ShowHelpTip(self.model.Help,true)
    end
    AddButtonEvent(self.wenhao.gameObject,call_back)
    --RoleInfoModel:GetInstance():GetMainRoleData():BindData(Constant.GoldType.GodScore, call_back)
    self.events[#self.events + 1] = self.model:AddListener(ArtifactEvent.UpdateRedPoint, handler(self, self.UpdateRedPoint))
    self.events[#self.events + 1] = self.model:AddListener(ArtifactEvent.ArtifactListInfo, handler(self, self.ArtifactListInfo))
    self.events[#self.events + 1] = self.model:AddListener(ArtifactEvent.PageItemClick, handler(self, self.PageItemClick))
    GlobalEvent.AddEventListenerInTab(CombineEvent.LeftSecondMenuClick .. self.__cname, handler(self, self.HandleLeftSecItemClick), self.gevents);
    GlobalEvent.AddEventListenerInTab(CombineEvent.LeftFirstMenuClick .. self.__cname, handler(self, self.HandleLeftFirstClick), self.gevents);
end

function ArtifactPanel:UpdateRedPoint()
    --self.curType
    for i, v in pairs( self.pageItems) do
        local isRed = false
        local redTab = self.model.typeRedPoints[v.data]
        for i, v in pairs(redTab) do
            if v == true then
                isRed = true
                break
            end
        end
        v:SetRedPoint(isRed)
    end
    if self.left_menu then
        self.left_menu:UpdateRedPoint()
    end
    self:SetIndexRedDotParam(1,self.model.redPoints[1])
    self:SetIndexRedDotParam(2,self.model.redPoints[2])
    self:SetIndexRedDotParam(3,self.model.redPoints[3])
    self:SetIndexRedDotParam(4,self.model.redPoints[4])
end


function ArtifactPanel:SwitchCallBack(index, toggle_id, update_toggle)
    if (self.currentIndex == index) then
        return
    else
        self:SwitchView(index)
    end
end

function ArtifactPanel:SwitchView(index)
    --if not self.isNeedSetData then
    --    return
    --end
    self.currentIndex = index
    if self.currentView then
        --self.currentView:SetVisible(false)
        self.currentView = nil
    end

    if self.panels[self.currentIndex] then
        self.currentView = self.panels[self.currentIndex]
    else
        local p
        if self.currentIndex == 1 then
            p = ArtifactArtielemPanel(self.transform)
        elseif self.currentIndex == 2 then
            p = ArtifactEquipPanel(self.transform)
        elseif self.currentIndex == 3 then
            p = ArtifactUpGradeMainPanel(self.transform)
        elseif self.currentIndex == 4 then
            p = ArtifactEnchantPanel(self.transform)
        end
        self.panels[self.currentIndex] = p
        self.currentView = p
    end
    if self.currentIndex ~= 1 then
        ArtifactController:GetInstance():RequstArtifactListInfo()
    end
    self:SetItemsState()
    --if self.currentView then
    --    if self.curArtId and self.currentIndex ~= 1 then
    --        self.currentView:SetData(self.curArtId)
    --    end
    --end
    self:PopUpChild(self.currentView)
end


function ArtifactPanel:HandleLeftSecItemClick(menuId, subId)
    --self:UpdateGodInfo(subId)
    --logError(menuId, subId)
    --self.curArtId = subId
    self.model.curArtId = subId
    self.curType = menuId
    if self.currentIndex ~= 1 then
        self.currentView:SetData(self.model.curArtId ,self.curType)
    end
    --ArtifactController:GetInstance():RequstArtifactListInfo()
end

function ArtifactPanel:HandleLeftFirstClick(index,isHide)
    if not isHide then
        self.model.curArtId = self.sub_menu[index][1][1]
        self.curType = index
        if self.currentIndex ~= 1 then
            self.currentView:SetData(self.model.curArtId ,self.curType)
        end
    end

    --if not isHide then  --显示
    --    self:UpdateGodInfo(self.sub_menu[index+3][1][1])
    --end
    --if not isHide then  --显示
    --    self:UpdateGodInfo(self.sub_menu[index+3][1][1])
    --end
end

function ArtifactPanel:PageItemClick(data)
    for i, v in pairs(self.pageItems) do
        if v.data == data then
            if self.currentView then
                self.currentView:SetData(data)
                ArtifactController:GetInstance():RequstArtielemListInfo(data)
            end
            v:SetSelect(true);
        else
            v:SetSelect(false);
        end
    end
end

function ArtifactPanel:InitPageItems()
    local tab = self.model.FoldData
    for i, gods in table.pairsByKey(tab) do
        local item = self.pageItems[i]
        if not item then
            item = ArtifactPageItem(self.ArtifactPageItem.gameObject,self.Content,"UI")
            self.pageItems[i] = item
        end
        item:SetData(i);
    end
    self:UpdateRedPoint()
end


function ArtifactPanel:InitFold()
   -- dump(self.model.FoldData)
   -- if self.left_menu then
   --     self.left_menu:destroy()
   -- end
   -- self.left_menu = nil
    self.left_menu = ArtifactFoldMenu(self.LeftMenu, nil, self, ArtifactMenuItem, ArtifactMenuSubItem)
    self.left_menu:SetStickXAxis(8.5)
    local tab =  self.model.FoldData
    self.menu = {}
    self.sub_menu = {}
    for i, gods in table.pairsByKey(tab) do
        local groupID = i
        local list = {}
        for k, v in  table.pairsByKey(gods) do
            local tab1 = {k,self.model:GetArtifactName(k)}
            table.insert(list,tab1)
        end
        self.sub_menu[i] = list
        local tab = {groupID,self.model:GetTypeName(i)}
        table.insert(self.menu,tab)
    end

    self.left_menu:SetData(self.menu,self.sub_menu,1,2,2)

   -- self.left_menu:SetDefaultSelected(1, 1)
    --self.left_menu:SetDefaultSelected(1, 1)
end

function ArtifactPanel:SetItemsState()
    if self.currentIndex ~= 1 then
        --if not self.left_menu then
        --    self:InitFold()
        --    self.left_menu:SetDefaultSelected(1, 1)
        --end
        SetVisible(self.LeftMenu,true)
        SetVisible(self.ScrollView,false)
    else
        if table.isempty(self.pageItems) then
            self:InitPageItems()
            self:PageItemClick(1)
        end
        SetVisible(self.LeftMenu,false)
        SetVisible(self.ScrollView,true)
    end

end


function ArtifactPanel:ArtifactListInfo(data)
    --self.isNeedSetData = true
    --self:SwitchView(self.default_table_index or 1)
    if not self.left_menu then
        self:InitFold()
        self.left_menu:SetDefaultSelected(1, 1)
        self:UpdateRedPoint()
    else
        self.left_menu:UpdateArtInfo()
    end

    if self.currentView then
        if self.model.curArtId and self.currentIndex ~= 1 then
            self.currentView:SetData(self.model.curArtId,self.curType)
        end
    end
end