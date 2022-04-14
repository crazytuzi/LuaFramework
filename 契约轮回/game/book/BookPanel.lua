-- @Author: lwj
-- @Date:   2019-01-03 10:48:49
-- @Last Modified time: 2019-01-03 10:48:53

BookPanel = BookPanel or class("BookPanel", WindowPanel)
local BookPanel = BookPanel

function BookPanel:ctor()
    self.abName = "book"
    self.assetName = "BookPanel"
    self.layer = "UI"

    self.panel_type = 7
    self.title = "title"
    self.model = BookModel.GetInstance()
    --self.show_sidebar = true        --是否显示侧边栏
    --self.is_show_light_decorate = true
    --if self.show_sidebar then
    --    侧边栏配置
    --self.sidebar_data = {
    --    { text = "开服", id = 1, icon = "bag:bag_icon_bag_s", dark_icon = "bag:bag_icon_bag_n", },
    --}
    --end

    self.is_show_open_action = true

    self.themeItemList = {}
    self.cutOffList = {}
    self.isFirstSetDeault = false
    self.modelEventList = {}
end

function BookPanel:dctor()
end

function BookPanel:Open()
    WindowPanel.Open(self)
    self.model.isOpenBookPanel = true
end

function BookPanel:LoadCallBack()
    self.nodes = {
        "TopScroll/TopView/TopContent",
        "TopScroll/TopView",
        "LeftContain/leftBg",
        "RightContain/taskScroll/task_Viewport/taskContent",
        "RightContain/taskScroll/task_Viewport",
        "LeftContain/CutOffContent/BookSliderCut",
        "LeftContain/CutOffContent",
        "LeftContain/slider/fill",
        "LeftContain/slider",
        "LeftContain/icon",
        "LeftContain/btn_Skill_Get",
        "LeftContain/btn_Skill_Get/gray_nor",
        "LeftContain/btn_Skill_Get/red_con",
        "LeftContain/slider/fill/word_con",
        "LeftContain/tag",
        "sundries/close",
    }
    self:GetChildren(self.nodes)
    --self.nameT = self.name:GetComponent('Text')
    self.leftBgI = self.leftBg:GetComponent('Image')
    self.cutOff_gameObject = self.BookSliderCut.gameObject
    self.fill = GetImage(self.fill)
    self.icon = GetImage(self.icon)
    self.word_rect = GetRectTransform(self.word_con)

    self:AddEvent()
    self:SetMask()
    self:SetRedDot(true)
    self:LoadThemeItem()
end

function BookPanel:AddEvent()
    local function call_back()
        self.model.isGettingReward = true
        self.model:Brocast(BookEvent.GetThemeSkill, self.model.curTheme)
    end
    AddButtonEvent(self.gray_nor.gameObject, call_back)

    local function call_back()
        self:HandleCloseBookPanel()
    end
    AddButtonEvent(self.close.gameObject, call_back)

    local function call_back()
        local tipsPanel = lua_panelMgr:GetPanelOrCreate(TipsSkillPanel)
        tipsPanel:Open();
        tipsPanel:SetId(self.model.curIconId, self.icon.transform)
        --local data = {}
        --data.cur_suit_lv = 2
        --data.isActivate = true
        --data.parentNode = self.icon.transform
        --local tipsPanel = lua_panelMgr:GetPanelOrCreate(TipsSkillTwo)
        --tipsPanel:Open()
        --tipsPanel:SetData(data)
    end
    AddButtonEvent(self.icon.gameObject, call_back)

    self.modelEventList[#self.modelEventList + 1] = self.model:AddListener(BookEvent.CloseBookPanel, handler(self, self.HandleCloseBookPanel))
    self.modelEventList[#self.modelEventList + 1] = self.model:AddListener(BookEvent.ThemeTopItemClick, handler(self, self.HandleTopClick))
    self.modelEventList[#self.modelEventList + 1] = self.model:AddListener(BookEvent.UpdateBookPanel, handler(self, self.LoadThemeItem))
    self.modelEventList[#self.modelEventList + 1] = self.model:AddListener(BookEvent.UpdateLeftShow, handler(self, self.UpdateLeft))
end

--移除升级绑定事件
function BookPanel:AfterCreate()
    if self.panel_type == 1 then
        self.bg_win = PanelBackground(self.transform, nil)
    elseif self.panel_type == 3 then
        self.bg_win = PanelBackgroundThree(self.transform, nil)
    elseif self.panel_type == 4 then
        self.bg_win = PanelBackgroundFour(self.transform, nil)
    elseif self.panel_type == 5 then
        self.bg_win = PanelBackgroundFive(self.transform, nil)
    elseif self.panel_type == 6 then
        self.bg_win = PanelBackgroundSix(self.transform, nil)
    elseif self.panel_type == 7 then
        self.bg_win = PanelBackgroundSeven(self.transform, nil)
        if self.title then
            self.bg_win:SetTileTextImage(self.abName .. "_image", self.title)
        end
    else
        self.bg_win = PanelBackgroundTwo(self.transform, nil)
    end
    self.bg_win:IsShowSidebar(self.show_sidebar, self.sidebar_style)

    if self.background_transform then
        self.background_transform:SetAsFirstSibling()
    end

    local function call_back(index, toggle_id)
        if not self.show_sidebar then
            return
        end
        self:MenuCallBack(index, toggle_id, true)
    end
    self.bg_win:SetCallBack(handler(self, self.Close), call_back)

    if self.show_sidebar and not self.sidebar_data then
        self.sidebar_data = SidebarConfig[self.__cname]
    end

    self:LoadCallBack()

    self:SetSidebarData()

    self:UpdateRedDot()

    self:SetTabIndex(self.default_table_index, self.default_toggle_index)

    if (self.panel_type == 1 or self.panel_type == 2) and self.is_show_money then
        self.bg_win:SetMoney(self.is_show_money)
    end

    if self.is_show_light_decorate then
        if self.bg_win then
            self.bg_win:ShowLightDecorate()
        end
    end
    self:SetTitleLast()
end

function BookPanel:HandleCloseBookPanel()
    self:Close()
end

function BookPanel:LoadThemeItem()
    local list = self.model:GetCurThemeList()
    if not self.isFirstSetDeault then
        self.model:SetDeaultTheme()
        self.isFirstSetDeault = true
    end
    self.themeItemList = self.themeItemList or {}
    local len = #list
    for i = 1, len do
        local item = self.themeItemList[i]
        if not item then
            item = BookTopItem(self.TopContent, 'UI')
            self.themeItemList[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(list[i])
    end
    for i = len + 1, #self.themeItemList do
        local item = self.themeItemList[i]
        item:SetVisible(false)
    end
    if self.model.isSetDefault then
        self.themeItemList[self.model.curDefaultTheme]:SetDefaultFlag()
        self.model.isSetDefault = false
    else
        self.themeItemList[self.model.curTheme]:SetDefaultFlag()
    end
    self.model.jump_theme = nil
    self:StopTime()
	local function call_back()
		for i = 1, len do
			if not self.themeItemList[i]:IsActive() then
				self.themeItemList[i]:SetText()
				break
			end
		end
	end
	self.time_id = GlobalSchedule:Start(call_back, 0.1) --如果不延时调用   item加载初始化未完成 造成报空
end

function BookPanel:OpenCallBack()
    self:SetTitleImgPos(-307,274.9)
end

function BookPanel:StopTime()
    if self.time_id then
        GlobalSchedule:Stop(self.time_id)
    end
end

function BookPanel:SwitchCallBack(index)
    if self.child_node then
        self.child_node:SetVisible(false)
    end
end

function BookPanel:HandleTopClick(conData, tasksInfo)
    self:UpdateLeft(conData, tasksInfo)
    self:UpdateRight(conData, tasksInfo)
end

function BookPanel:UpdateLeft(conData, tasksInfo)
    lua_resMgr:SetImageTexture(self, self.leftBgI, "book_image", ConfigLanguage.Book.LeftBgNameHead .. conData.skill, false, nil, false)
    self.model.curIconId = conData.skill

    self:DetroyCutOff()
    local cut = nil
    local num = #String2Table(conData.tasks)
    local curNum = self:GetCurTaskProgress(tasksInfo)
    if curNum == num then
        local state = self.model:GetThemeStateById(self.model.curTheme)
        if state == 1 then
            SetVisible(self.tag, false)
            SetVisible(self.btn_Skill_Get, true)
            SetVisible(self.slider, false)
        elseif state == 2 then
            SetVisible(self.tag, true)
            SetVisible(self.btn_Skill_Get, false)
            SetVisible(self.slider, false)
        else
            logError("任务全部完成，但是Target的状态是未完成")
        end
    else
        for i = 1, num do
            cut = BookSliderCut(self.cutOff_gameObject, self.CutOffContent)
            if i == 1 then
                cut:SetLucency()
            end
            table.insert(self.cutOffList, cut)
        end
        self.fill.fillAmount = curNum / num
        SetVisible(self.tag, false)
        SetVisible(self.btn_Skill_Get, false)
        SetVisible(self.slider, true)
    end
    if self.model.isGettingReward then
        self.model.isGettingReward = false
        self:CheckProChange(curNum, conData)
    end
end
function BookPanel:CheckProChange(cur_num, conData)
    local cur_pro = self.model:GetCurProgByThemeId(conData.id)
    if not cur_pro or cur_num > self.model.cur_prog then
        local x = 180 * self.fill.fillAmount
        SetAnchoredPosition(self.word_rect, x, 13)
        ShiftWord(self.word_con.transform, "top", '+1')
    end
    self.model.cur_prog = cur_num
end

function BookPanel:GetCurTaskProgress(tasksInfo)
    local num = 0
    for i = 1, #tasksInfo do
        if tasksInfo[i].status == 2 then
            num = num + 1
        end
    end
    return num
end

function BookPanel:UpdateRight(conData, tasksInfo)
    local temp = String2Table(Config.db_target[conData.id].tasks)
    local tasks = self.model:GetSequenceTasks(temp)
    self.taskItemList = self.taskItemList or {}
    local len = #tasks
    for i = 1, len do
        local item = self.taskItemList[i]
        if not item then
            item = BookTaskItem(self.taskContent, 'UI')
            self.taskItemList[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(tasks[i])
    end
    for i = len + 1, #self.taskItemList do
        local item = self.taskItemList[i]
        item:SetVisible(false)
    end
end

function BookPanel:DetroyCutOff()
    for i, v in pairs(self.cutOffList) do
        if v then
            v:destroy()
        end
    end
    self.cutOffList = {}
end

function BookPanel:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    if isShow == nil then
        isShow = false
    end
    self.red_dot:SetPosition(0, 0)
    self.red_dot:SetRedDotParam(isShow)
end

function BookPanel:CloseCallBack()
    self:StopTime()
    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
    self.model.isOpenBookPanel = false
    for i, v in pairs(self.modelEventList) do
        self.model:RemoveListener(v)
    end
    self.modelEventList = {}

    for i, v in pairs(self.themeItemList) do
        if v then
            v:destroy()
        end
    end
    self.themeItemList = {}

    for i, v in pairs(self.taskItemList) do
        if v then
            v:destroy()
        end
    end
    self.taskItemList = {}
    self:DetroyCutOff()
    if self.StencilMask then
        destroy(self.StencilMask)
        self.StencilMask = nil
    end
    if self.StencilMask2 then
        destroy(self.StencilMask2)
        self.StencilMask2 = nil
    end
end

function BookPanel:SetMask()
    self.StencilId = GetFreeStencilId()
    self.StencilMask = AddRectMask3D(self.TopView.gameObject)
    self.StencilMask.id = self.StencilId

    self.task_StencilId = GetFreeStencilId()
    self.StencilMask2 = AddRectMask3D(self.task_Viewport.gameObject)
    self.StencilMask2.id = self.task_StencilId
end