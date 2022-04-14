RankPanel = RankPanel or class("RankPanel", WindowPanel)

function RankPanel:ctor()
    self.abName = "rank"
    self.assetName = "RankPanel"
    self.image_ab = "rank_image";
    self.layer = "UI"

    self.panel_type = 7
    self.title = "title"
    self.model = RankModel:GetInstance()
    self.show_sidebar = false        --是否显示侧边栏

    self.is_show_open_action = true
    
    self.rankType = -1
    self.lastRankType = -2
    self.nowPage = 1
    self.Events = {}
    self.cacheRankItems = {}
    self.topItems = {}
    self:Reset()
    self.main_role_data = RoleInfoModel.GetInstance():GetMainRoleData()
   -- print2(TimeManager:GetStampByHMS(10,30,0))
end

function RankPanel:Reset()

end

function RankPanel:dctor()
    --if self.currentView then
    --    self.currentView:destroy();
    --end
  --  GlobalEvent:Brocast(MainEvent.ChangeRightIcon,FactionEscortNpcPanel,true,2250)
	if self.lvItem then
		self.lvItem:destroy()
		self.lvItem = nil
	end
end

function RankPanel:Open()
    WindowPanel.Open(self)
end

function RankPanel:LoadCallBack()
    self.nodes =
    {
        "menuContent",
        "RankRightItem",
        "RankTopItem",
        "rankObj/topMenuContent",
        "rankObj",
        "rankObj/ScrollView",
        "rankObj/ScrollView/Viewport/itemContent",
        "noRank",
        "myRank/myRankObj",
        "myRank/myRankObj/unionTex",
        "myRank/myRankObj/rankTex",
        "myRank/myNoRank",
        "myRank/myRankObj/levelTex",
        "myRank/myRankObj/vipTex",
        "myRank/myRankObj/nameObj/name",
        "myRank/myRankObj/nameObj/nameTitle",
        "title/titleText/titleLevel",
        "title/titleText/guildTex",
		"myRank/myRankObj/myLevelParent",
    }
    self:GetChildren(self.nodes)
    SetLocalPosition(self.transform, 0, 0, 0)
    self.ScrollView = GetScrollRect(self.ScrollView)
    self.unionTex = GetText(self.unionTex)
    self.rankTex = GetText(self.rankTex)
    self.levelTex = GetText(self.levelTex)
    self.nameTex = GetText(self.name)
    self.nameTitleTex = GetText(self.nameTitle)
    self.titleLevel = GetText(self.titleLevel)
    self.vipTex = GetText(self.vipTex)
    self.guildTex = GetText(self.guildTex)
    self.text_title_1_outline = self.nameTitle:GetComponent('Outline')
    self:AddEvent()
  --  self:InitWinPanel()
    self:InitUI()

 --   self:SetTileTextImage("market_image", "market_title_1");
end

function RankPanel:InitWinPanel()
    self:SetPanelBgImage("iconasset/icon_big_bg_img_book_bg", "img_book_bg")
    self:SetTitleBgImage("system_image", "ui_title_bg_5")
    self:SetTopCenterBg("system_image", "ui_title_bg_6")
    self:SetTileTextImage("rank_image", "rank_title")
    self:SetTitleImgPos(528, 279)
    self:SetBtnCloseImg("system_image", "ui_close_btn_3")
end


function RankPanel:OpenCallBack()
    self:SetTitleImgPos(-307,274.9)
end

function RankPanel:CloseCallBack()
    self.model = nil
    GlobalEvent:RemoveTabListener(self.Events)
    if self.leftMenu then
        self.leftMenu:destroy()
    end
    self.leftMenu = nil
end

function RankPanel:InitUI()
    self:InitMenuList()
    --self.schedule = GlobalSchedule.StartFun(handler(self, self.StartCountDown), 1, -1)
end



function RankPanel:AddEvent()
    function DragEnd_Call_Back()
        if self.ScrollView.verticalNormalizedPosition <= 0 then
            self.nowPage = self.nowPage + 1
            RankController:GetInstance():RequestRankListInfo(self.rankType,self.nowPage)
        end
    end
    AddDragEndEvent(self.ScrollView.gameObject,DragEnd_Call_Back)


    GlobalEvent.AddEventListenerInTab(CombineEvent.LeftSecondMenuClick .. self.__cname, handler(self, self.HandleLeftSecItemClick), self.Events);
    GlobalEvent.AddEventListenerInTab(CombineEvent.LeftFirstMenuClick .. self.__cname, handler(self, self.HandleLeftFirstClick), self.Events);
    self.Events[#self.Events + 1] = GlobalEvent:AddListener(RankEvent.RankReturnList, handler(self, self.RankReturnList))

end


function RankPanel:HandleLeftSecItemClick(menuId, subId)
    if subId ==  self.rankType then
        return
    end
    self.lastRankType = self.rankType
   -- self.rankType = self.menu[index][1]
    self.rankType = subId
    self.nowPage = 1
    self.ScrollView.verticalNormalizedPosition = 1
   -- self.SetRankType()
    RankController:GetInstance():RequestRankListInfo(subId,self.nowPage)
    self:SetRankType()
end

function RankPanel:HandleLeftFirstClick(index)
    --print2(index)
    local id = self.menu[index][1]
    if id ==  self.rankType then
        return
    end
    self.lastRankType = self.rankType
    --self.rankType = id
    if #self.sub_menu[id] == 0 then
        self.nowPage = 1
        self.rankType = id
       -- self:SetRankType()
        RankController:GetInstance():RequestRankListInfo(id,self.nowPage)
        self.ScrollView.verticalNormalizedPosition = 1
    else
        local menuId = self.menu[index][1]
        local rankId = self.sub_menu[menuId][1][1]
        self.rankType = rankId
        self.nowPage = 1
      --  self:SetRankType()
        RankController:GetInstance():RequestRankListInfo(rankId,self.nowPage)
        self.ScrollView.verticalNormalizedPosition = 1
    end
    self:SetRankType()
    --print2(id)
end
function RankPanel:SetRankType()
    if self.rankType == 1001 then --等级榜
        self.titleLevel.text = "Level"
        self.guildTex.text = "Guild name"

    elseif self.rankType == 1002 then --战力榜
        self.titleLevel.text = "Character CP"
        self.guildTex.text = "Awaken"
    elseif self.rankType == 1003 then
        self.titleLevel.text = "Mount Tier"
        self.guildTex.text = "Guild name"
    elseif self.rankType == 1004 then
        self.titleLevel.text = "Off hand Tier"
        self.guildTex.text = "Guild name"
    elseif self.rankType == 1005 then
        self.titleLevel.text = "Soulcard Rating"
        self.guildTex.text = "Guild name"
    elseif self.rankType == 1006 then
        self.titleLevel.text = "Total Pet CP"
        self.guildTex.text = "Guild name"
    elseif self.rankType == 1007 then
        self.titleLevel.text = "Total Avatar CP"
        self.guildTex.text = "Guild name"
    elseif self.rankType == 1008 then
        self.titleLevel.text = "Auto Efficiency"
        self.guildTex.text = "Guild name"
    end
end

function RankPanel:InitMenuList()
    self.leftMenu = RankTreeMenu(self.menuContent, nil, self, RankOneMenu, RankTwoMenu,false)
    self.menuTran = self.leftMenu.transform:GetComponent('RectTransform')
    self.menuTran.sizeDelta = Vector2(250, 514)
    self.leftMenu.LeftScrollView:GetComponent('RectTransform').sizeDelta = Vector2(0, 0)
    self.menu = {}
    self.sub_menu = {}
    local groupCfg = Config.db_rank_group
    local itemCfg = Config.db_rank
    table.sort(itemCfg, function(a,b)
       return a.num < b.num
    end)
    for i = 1, #itemCfg do
        if itemCfg[i].ranktype == 1 then
            local item = itemCfg[i]
            if item.group == 0 then
                local tab = {item.id,item.name}
                table.insert(self.menu,tab)
                self.sub_menu[item.id] = {}
            end
        end
    end
    for _, item in pairs(groupCfg) do
        local list = {}
        for i = 1, #itemCfg do
            if itemCfg[i].ranktype == 1 then
                local sub = itemCfg[i]
                if sub.group == item.id then
                    local tab1 = {sub.id,sub.name}
                    table.insert(list,tab1)
                end
            end
        end

        self.sub_menu[item.id] = list

        local tab = {item.id,item.name}
        table.insert(self.menu,tab)
    end
    self.leftMenu:SetData(self.menu, self.sub_menu, 1, 2, 2)
    self.leftMenu:SetDefaultSelected(1, 1)
   -- self.rankType = 1001         --要修改
    --self.lastRankType = 1001     --要修改
    --dump(self.sub_menu)
    --dump(self.menu)
end

---设置自己的信息
function RankPanel:SetOwnInfo(data)
    local rank  = data.mine.rank
    local sort = data.mine.sort
	if self.lvItem then
		self.lvItem:destroy()
		self.lvItem = nil
	end
    if rank == 0 then   --没有排名
        SetVisible(self.myNoRank,true)
        SetVisible(self.myRankObj,false)
    else
        SetVisible(self.myNoRank,false)
        SetVisible(self.myRankObj,true)
        self.rankTex.text = rank
        self.nameTex.text = self.main_role_data.name
        self.vipTex.text = "V"..self.main_role_data.viplv
        if self.rankType == 1001 then --等级榜

            self.levelTex.text = ""
            self.lvItem = LevelShowItem(self.myLevelParent)
            self.lvItem:SetData(19,self.main_role_data.level,"CF4526")

            self:SetMyGuild()

        elseif self.rankType == 1002 then --战力榜
            self.levelTex.text = self.main_role_data.power
            local career = self.main_role_data.career
            local wake = self.main_role_data.wake
            local db = Config.db_wake[career.."@"..wake]
            local des = wake..ConfigLanguage.Wake.Wake.."·"..db.name
            self.unionTex.text = des
            -- self.unionTex.text = string.format("%s次觉醒",self.main_role_data.wake)
        elseif self.rankType == 1003 then
            if sort ~= 0  then
                local cfg = self.model:GetMountNumByID(sort)
                self.levelTex.text = string.format("T%sS%s",cfg.order,cfg.level)
            else
                self.levelTex.text = string.format("T%sS%s",0,0)
            end
            self:SetMyGuild()
        elseif self.rankType == 1004 then
            if sort ~= 0  then
                local cfg = self.model:GetOffhandNumByID(sort)
                self.levelTex.text = string.format("T%sS%s",cfg.order,cfg.level)
            else
                self.levelTex.text = string.format("T%sS%s",0,0)
            end
            self:SetMyGuild()
        elseif self.rankType == 1005 then
            self.levelTex.text = sort
            self:SetMyGuild()
        elseif self.rankType == 1008 then
            -- self.levelTex.text = sort
            self.levelTex.text = string.format("%s/min",GetShowNumber(sort))
            self:SetMyGuild()
        else
            self.levelTex.text = sort
            self:SetMyGuild()
        end
       -- self:SetMyGuild()
        self:SetMyTitle()
    end
end
function RankPanel:SetMyTitle()
    local title_id = self.main_role_data.figure.jobtitle and self.main_role_data.figure.jobtitle.model
    title_id = title_id or 0
    local cur_config = Config.db_jobtitle[title_id]
    if not cur_config then
        self.nameTitleTex.text = ""
        return
    end
    self.nameTitleTex.text = cur_config.name
    local r,g,b,a = HtmlColorStringToColor(cur_config.color)
    SetOutLineColor(self.text_title_1_outline, r,g,b,a)
    self:UpdateTitelPos()
end

function RankPanel:SetMyGuild()
   -- print2(self.main_role_data.gname)
    if self.main_role_data.guild == nil or self.main_role_data.guild == "" or self.main_role_data.guild == "0" then
        self.unionTex.text = "No guild yet"
    else
        self.unionTex.text = self.main_role_data.gname
    end
end
function RankPanel:UpdateTitelPos()
    local name_width = self.nameTex.preferredWidth
    local job_title_width = self.nameTitleTex.preferredWidth
    local total_width = name_width + job_title_width
    local name_x = job_title_width + 10
    local job_title_x = -name_width * 0.5
    SetLocalPositionX(self.name, name_x)
   -- SetLocalPositionX(self.nameTitle, job_title_x)
end


function RankPanel:SwitchCallBack(index)

end

function RankPanel:UpdataRankItems(list)
    self.cacheRankItems = self.cacheRankItems or {}
    --self.topItems = self.topItems or {}
   -- dump(list)
   -- if self.topItems then
   --     for i = 1, #self.topItems do
   --         self.topItems[i]:destroy()
   --     end
   --     self.topItems = {}
   -- end
    for i = 1, #list do
        if list[i].rank > 3  then
            break
        end
        local item = self.topItems[i]
        if not item then
            item = RankTopItem(self.RankTopItem.gameObject,self.topMenuContent,"UI")
            self.topItems[i] = item
        else
            item:SetVisible(true)
        end
        if list[i].rank  == 1 then
            item:SetData(self.rankType,list[i + 1] or list[1])
        elseif list[i].rank == 2 then
            item:SetData(self.rankType,list[i - 1])
        else
            item:SetData(self.rankType,list[i])
        end
    end
    for i = #list + 1,#self.topItems do
        local Item = self.topItems[i]
        Item:SetVisible(false)
    end
    for i = 1, #list do
        local item = self.cacheRankItems[(self.nowPage - 1) * 30 + i]
        if not item then
            item = RankRightItem(self.RankRightItem.gameObject,self.itemContent,"UI")
            --if list[i].rank > 3 then
            --    item = RankRightItem(self.RankRightItem.gameObject,self.itemContent,"UI")
            --else
            --    item = RankTopItem(self.RankTopItem.gameObject,self.topMenuContent,"UI")
            --end

            self.cacheRankItems[(self.nowPage - 1)* 30 + i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(self.rankType,list[i])
    end


    if self.lastRankType ~= self.rankType and self.nowPage == 1 then
        if #self.cacheRankItems > #list then
            for i = #list+ 1, #self.cacheRankItems do
                local item = self.cacheRankItems[i]
                item:SetVisible(false)
            end
        end
    end
end
-----------------------------------------------------
function RankPanel:RankReturnList(data)
    if self.rankType ~= data.id then
        return
    end
    if self.nowPage == 1 then
        self:SetOwnInfo(data)
    end
    if #data.list == 0 and self.nowPage == 1 then ---暂时没人上榜
        Notify.ShowText("Empty")
        --self.nowPage = 1
        SetVisible(self.noRank,true)
        SetVisible(self.rankObj,false)
        return
    else
        SetVisible(self.noRank,false)
        SetVisible(self.rankObj,true)
    end

    if #data.list == 0  and self.nowPage ~= 1  then --下一页没有数据
        Notify.ShowText("You reached the bottom! No data")
        return
    end
    
    self:UpdataRankItems(data.list)
end