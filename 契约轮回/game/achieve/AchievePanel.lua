AchievePanel = AchievePanel or class("AchievePanel", WindowPanel)
local AchievePanel = AchievePanel

function AchievePanel:ctor()
    self.abName = "achieve"
    self.assetName = "AchievePanel"
    self.image_ab = "achieve_image";
    self.layer = "UI"

    self.panel_type = 2
    self.model = AchieveModel:GetInstance()
    self.show_sidebar = true        --是否显示侧边栏

    self.group = 1
    self.page = 1
    self.isFirst = true
    self.isFirstClick = true
    self.Events = {}
    self.modelEvents = {}
    self.oneItems = {}
    self.allTopItems = {}
    self.allDownItems = {}

    self.separate_frame_schedule_id = nil  --分帧实例化定时器id
end


function AchievePanel:dctor()
  --  self.model = nil
    self.isFirst = true
    self.group = 1
    self.page = 1
    if self.currentView then
        self.currentView:destroy();
    end
    GlobalEvent:RemoveTabListener(self.Events)
    self.model:RemoveTabListener(self.modelEvents)
    if self.left_menu then
        self.left_menu:destroy()
    end
    self.left_menu = nil
    for i, v in pairs(self.oneItems) do
        v:destroy()
    end
    self.oneItems = nil
    for i, v in pairs(self.allTopItems) do
        v:destroy()
    end
    self.allTopItems = nil
    for i, v in pairs(self.allDownItems) do
        v:destroy()
    end
    self.allDownItems = nil

    if self.separate_frame_schedule_id then
		GlobalSchedule:Stop(self.separate_frame_schedule_id)
		self.separate_frame_schedule_id = nil
	end
end

function AchievePanel:Open()
    WindowPanel.Open(self)
end

function AchievePanel:LoadCallBack()

    self.nodes = {
        "LeftMenu","AchieveAllDownItem","AchieveOneItem","OnePanel","AllPanel","AchieveAllTopItem","OnePanel/ontItemScrollView/Viewport/oneItemContent",
        "AllPanel/top/topItemParent","AllPanel/down/itemScrollView/Viewport/downItemContent","AllPanel/top/di/progNum","AllPanel/top/di/progress",
    }
    self:GetChildren(self.nodes)
    self.progNum= GetText(self.progNum)
    self.progress = GetImage(self.progress)
    self:SetTileTextImage("achieve_image", "achieve_title");
    self:AddEvent()
    self:InitMenuList()
    --AchieveController:GetInstance():RequestAchieveInfo()
end

function AchievePanel:OpenCallBack()
    
end

function AchievePanel:CloseCallBack()

end

function AchievePanel:AddEvent()
    self.modelEvents[#self.modelEvents+1] = self.model:AddListener(AchieveEvent.AchieveInfo, handler(self, self.AchieveInfo))

    GlobalEvent.AddEventListenerInTab(CombineEvent.LeftSecondMenuClick .. self.__cname, handler(self, self.HandleLeftSecItemClick), self.Events);
    GlobalEvent.AddEventListenerInTab(CombineEvent.LeftFirstMenuClick .. self.__cname, handler(self, self.HandleLeftFirstClick), self.Events);
end

function AchievePanel:SwitchCallBack(index)
    if self.currentView then
        self.currentView:destroy();
    end
end

function AchievePanel:HandleLeftSecItemClick(menuId, subId)
  --  print2(menuId, subId)
   -- logError("111")
    self:InitOntItem(menuId,subId)
end

function AchievePanel:HandleLeftFirstClick(index,isHide)
  --  print2(index)
   -- logError("22")
    if not isHide  then
        if index == 1 then
            SetVisible(self.AllPanel,true)
            SetVisible(self.OnePanel,false)
            self:InitAllPanel()
            self:InitOntItem(1,1)
        else
            SetVisible(self.AllPanel,false)
            SetVisible(self.OnePanel,true)
            --  if self.isFirst then
            -- print2("---1---")
           -- logError(index,self.page)
            if  self.isFirstClick then
                self:InitOntItem(index,self.page)
                self.isFirstClick = false
            else
                self:InitOntItem(index,1)
            end

            --else
            -- print2("---2---")
            --self:InitOntItem(index,1)
            -- end

        end
    else
        self.page = 1
    end

end

function AchievePanel:InitMenuList()
    --if not self.isFirst then
    --    self:HandleLeftSecItemClick(self.group, self.page)
    --    return
    --end
    --self.isFirst = false
    self.left_menu = AchieveFoldMenu(self.LeftMenu, nil, self, AchieveOneMenu, AchieveTwoMenu)
    self.left_menu:SetStickXAxis(8.5)
    self.menu = {}
    self.sub_menu = {}
    local groupCfg = Config.db_achieve_group
    local pageCfg = Config.db_achieve_page
    --for i = 1, #groupCfg do
    --
    --end
    for i = 1, #groupCfg do
        local item = groupCfg[i]
        local list = {}
        for i = 1, #pageCfg do
            local sub = pageCfg[i]
            if sub.group == item.id then
                local tab1 = {sub.id,sub.name}
                table.insert(list,tab1)
            end
        end
        self.sub_menu[item.id] = list

        local tab = {item.id,item.name}
        table.insert(self.menu,tab)
    end
    self.left_menu:SetData(self.menu, self.sub_menu, 1, 2, 2)
    --self.left_menu:SetDefaultSelected(1, 1)
    AchieveController:GetInstance():RequestAchieveInfo()
end

function AchievePanel:InitAllTopItem()
    
end
function AchievePanel:InitAllDownItem()

end
function AchievePanel:InitOntItem(group,page)
    self.group = group
    self.page = page

--[[     local itemList =  self.model:GetAchieveByGroupAndPage(group,page)
    self.oneItems = self.oneItems or {} ]]

--[[     for i = 1, #itemList do
        if group == 1 and page == 1 then
            local item = self.allDownItems[i]
            if not item then
                item = AchieveAllDownItem(self.AchieveAllDownItem.gameObject,self.downItemContent,"UI")
                self.allDownItems[i] = item
                self.allDownItems[i]:SetData(itemList[i])
            else
                item:SetData(itemList[i])
            end
        else
            local item = self.oneItems[i]
            if not item then
                item = AchieveOneItem(self.AchieveOneItem.gameObject,self.oneItemContent,"UI")
                self.oneItems[i] = item
            else
                item:SetVisible(true)
            end
            item:SetData(itemList[i])
        end
    end ]]


--[[     for i = #itemList+1, #self.oneItems do
        local item = self.oneItems[i]
        item:SetVisible(false)
    end ]]

    --分帧实例化
    self:SeparateFrameInstantia()
end

--分帧实例化
function AchievePanel:SeparateFrameInstantia()
    local itemList =  self.model:GetAchieveByGroupAndPage(self.group,self.page)
    self.oneItems = self.oneItems or {}
    local num = #itemList
    if num <= 0 then
		return
	end

    local schedule_id = nil

    local function op_call_back(cur_frame_count,cur_all_count)
        if not self.allDownItems or not self.oneItems then
            GlobalSchedule:Stop(schedule_id)
            return
        end

		if self.group == 1 and self.page == 1 then
            local item = self.allDownItems[cur_all_count]
            if not item then
                item = AchieveAllDownItem(self.AchieveAllDownItem.gameObject,self.downItemContent,"UI")
                self.allDownItems[cur_all_count] = item
                self.allDownItems[cur_all_count]:SetData(itemList[cur_all_count])
                --logError("分帧实例化AchieveAllDownItem，Count:"..cur_all_count)
            else
                item:SetData(itemList[cur_all_count])
            end
        else
            local item = self.oneItems[cur_all_count]
            if not item then
                item = AchieveOneItem(self.AchieveOneItem.gameObject,self.oneItemContent,"UI")
                self.oneItems[cur_all_count] = item
                --logError("分帧实例化AchieveOneItem，Count:"..cur_all_count)
            else
                item:SetVisible(true)
            end
            item:SetData(itemList[cur_all_count])
        end

      
	end
	local function all_frame_op_complete()
		self:SeparateFrameInstantiaComplete(num)
	end

	--一帧实例化一个 保证不卡

	self.separate_frame_schedule_id =  SeparateFrameUtil.SeparateFrameOperate(op_call_back,nil,1,num,nil,all_frame_op_complete)

    schedule_id = self.separate_frame_schedule_id
end

--分帧实例化完毕
function AchievePanel:SeparateFrameInstantiaComplete(num)
    self.separate_frame_schedule_id = nil

    for i = num+1, #self.oneItems do
        local item = self.oneItems[i]
        item:SetVisible(false)
    end
end

function AchievePanel:AchieveInfo(data)
    self:CheckRedPoint()
  --  dump(self.left_menu.leftmenu_list)
   -- dump(self.left_menu.leftmenu_list)
    if self.isFirst then

        local  group,page = self.model:GetGroupAndPage()
        if group == 1 and page == 1 then
            self:InitAllPanel()
        end
        self:HandleLeftSecItemClick(group,page)

        self.left_menu:SetDefaultSelected(group, page)
        self.isFirst = false
        return
    end
    self.isFirstClick = true
    --
    --local  group,page = self.model:GetGroupAndPage()
    --self.group = group
    --self.page = page
    --if self.group == 1 and self.page == 1 then
    --    self:InitAllPanel()
    --end
    --self:HandleLeftSecItemClick(self.group,self.page)
    --
    --self.left_menu:SetDefaultSelected(self.group, self.page)
    if not self.model:isRewardByGroupAndPage(self.group,self.page) then
        local  group,page = self.model:GetGroupAndPage()
        if group == 1 and page == 1 then
            self:InitAllPanel()
        end

        if self.group == group then
            self:HandleLeftSecItemClick(group,page)
            local data = self.left_menu.leftmenu_list[group].menuitem_list[page].data[1]
            for i = 1, #self.left_menu.leftmenu_list[group].menuitem_list do
                self.left_menu.leftmenu_list[group].menuitem_list[i]:Select(data)
            end
            --self.left_menu.leftmenu_list[group].menuitem_list[page]:Select(data)
        else
            self.group = group
            self.page = page
            self:HandleLeftSecItemClick(group,page)
            self.left_menu:SetDefaultSelected(group, page)
        end


    else
        if self.group == 1 and self.page == 1 then
            self:InitAllPanel()
        end
        self:HandleLeftSecItemClick(self.group,self.page)
        --dump(self.left_menu.leftmenu_list[self.group].menuitem_list[self.page])
      --  self.left_menu:SetDefaultSelected(self.group, self.page)
    end
    --local  group,page = self.model:GetGroupAndPage()
    --if self.group ~= group then
    --    --self.group =
    --end



end
function AchievePanel:CheckRedPoint()
  --  dump(self.menu)
    --dump(self.sub_menu)
    self.left_menu:CheckAchieveRedPoint()
end

function AchievePanel:InitAllPanel()
    self:UpdateAllTopItem()
   -- self:UpdateAllDownItem()
    self:SetAllPoint()
end

function AchievePanel:UpdateAllTopItem()
    local cfg = Config.db_achieve_group
    self.allTopItems = self.allTopItems or {}
    for i = 1, #cfg do
        if i ~= 1 then
            local item = self.allTopItems[i]
            if not item then
                item = AchieveAllTopItem(self.AchieveAllTopItem.gameObject,self.topItemParent,"UI")
                self.allTopItems[i] = item
                self.allTopItems[i]:SetData(cfg[i])
            else
                item:SetVisible(true)
                item:SetData(cfg[i])
            end
        end
    end
end



function AchievePanel:UpdateAllDownItem()

end
function AchievePanel:SetAllPoint()
    local allPoint = self.model:GetAllPoint()
    local curPoint = self.model:GetCurPoint()
    self.progNum.text = string.format("%s/%s",curPoint,allPoint)
    self.progress.fillAmount = tonumber(curPoint)/tonumber(allPoint)
    --fillAmount
end
