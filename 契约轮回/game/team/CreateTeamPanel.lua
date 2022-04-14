CreateTeamPanel = CreateTeamPanel or class("CreateTeamPanel", WindowPanel)
local CreateTeamPanel = CreateTeamPanel

function CreateTeamPanel:ctor()
    self.abName = "team"
    self.assetName = "CreateTeamPanel"
    self.layer = "UI"

    -- self.change_scene_close = true 				--切换场景关闭
    -- self.default_table_index = 1					--默认选择的标签
    -- self.is_show_money = {Constant.GoldType.Coin,Constant.GoldType.BGold,Constant.GoldType.Gold}	--是否显示钱，不显示为false,默认显示金币、钻石、宝石，可配置

    self.menu = {}
    self.sub_menu = {}
    self.globalEvents = {}
    self.minNum = 0
    self.maxNum = 0
    self.panel_type = 3
    --self.win_type = 2							--窗体样式  1 1280*720  2 850*545
    self.show_sidebar = false        --是否显示侧边栏
    --if self.show_sidebar then		-- 侧边栏配置
    --	self.sidebar_data = {
    --		{text = ConfigLanguage.Custom.Message,id = 1,icon = "roleinfo:img_message_icon_1",dark_icon ="roleinfo:img_message_icon_2",},
    --	}
    --end
    self.table_index = nil

    self.select_type_id = 0
    self.left_menu = nil
    self.model = TeamModel:GetInstance()
    --CreateTeamPanel.super.Load(self)
end

function CreateTeamPanel:dctor()

    if self.left_menu then
        self.left_menu:destroy()
    end
    

    if self.leftsecondmenuclick_event_id then
        GlobalEvent:RemoveListener(self.leftsecondmenuclick_event_id)
        self.leftsecondmenuclick_event_id = nil
    end

    for i, v in pairs(self.globalEvents) do
        GlobalEvent:RemoveListener(v)
    end

    self.globalEvents = {}
end

function CreateTeamPanel:Open(changeTarget, select_type_id, limit_type)
    self.changeTarget = changeTarget
    self.select_type_id = select_type_id or 0
    self.limit_type = limit_type
    CreateTeamPanel.super.Open(self)
end

function CreateTeamPanel:LoadCallBack()
    self.nodes = {
        "LeftMenu",
        "RightContent/minlevel/minSlider",
        "RightContent/maxlevel/maxSlider",
        "btn_ok",
        "btn_ok/ok_Text",
        "btn_cancle",
        "Toggle",
        "RightContent/minlevel/minValue",
        "RightContent/minlevel/minValue_min",
        "RightContent/minlevel/minValue_max",
        "RightContent/maxlevel/maxValue",
        "RightContent/maxlevel/maxValue_min",
        "RightContent/maxlevel/maxValue_max",
        "RightContent/minlevel/minMinusBtn",
        "RightContent/minlevel/minPlusBtn",
        "RightContent/maxlevel/maxMinusBtn",
        "RightContent/maxlevel/maxPlusBtn",
    }
    self:GetChildren(self.nodes)
    self.ToggleTgl = self.Toggle:GetComponent('Toggle')
    self.minSliderSldr = self.minSlider:GetComponent('Slider')
    self.maxSliderSldr = self.maxSlider:GetComponent('Slider')
    self.minValueTxt = self.minValue:GetComponent('Text')
    self.minValue_minTxt = self.minValue_min:GetComponent('Text')
    self.minValue_maxTxt = self.minValue_max:GetComponent('Text')
    self.maxValueTxt = self.maxValue:GetComponent('Text')
    self.maxValue_minTxt = self.maxValue_min:GetComponent('Text')
    self.maxValue_maxTxt = self.maxValue_max:GetComponent('Text')
    self:AddEvent()
    --self:UpdateView()
    self:SetPanelSize(644, 486)
    self:SetTileTextImage("team_image", "team_crt_f")
end

function CreateTeamPanel:AddEvent()
    local function call_back(target, x, y)
        if self.select_type_id <= 0 then
            return Notify.ShowText(ConfigLanguage.Team.TargetEmpty)
        end
        local min_level = self.minSlider:GetComponent('Slider').value
        local max_level = self.maxSlider:GetComponent('Slider').value
        local is_auto_accept = self.Toggle:GetComponent('Toggle').isOn and 1 or 0
        local team_info = self.model:GetTeamInfo()

        if team_info then
            TeamController:GetInstance():RequestChangeTarget(self.select_type_id, min_level, max_level, is_auto_accept)
        else
            TeamController:GetInstance():RequestCreateTeam(self.select_type_id, min_level, max_level, is_auto_accept)
        end

        lua_panelMgr:GetInstance():ClosePanel(CreateTeamPanel)
    end
    AddClickEvent(self.btn_ok.gameObject, call_back)

    local function call_back(target, value)
        self.minNum = value
        local lv = GetLevelShow(value)
        self.minValueTxt.text = lv
    end
    AddValueChange(self.minSlider.gameObject, call_back)

    local function call_back(target, value)
        self.maxNum = value
        local lv = GetLevelShow(value)
        self.maxValueTxt.text = lv
    end
    AddValueChange(self.maxSlider.gameObject, call_back)

    function leftsecondmenuclick_call_back(menu_id, TypeId)
        self.select_type_id = TypeId
        self:UpdateEnterLVInfo(TypeId)
    end
    self.leftsecondmenuclick_event_id = GlobalEvent:AddListener(CombineEvent.LeftSecondMenuClick .. self.__cname, leftsecondmenuclick_call_back)

    local function ClosePanel()
        self:Close()
    end
    AddClickEvent(self.btn_cancle.gameObject, ClosePanel)

    local function call_back()
        if self.minNum > self.minSliderSldr.minValue then
            self.minNum = self.minNum - 1
            self.minSliderSldr.value = self.minNum
            local lv = self.minNum
            self.minValueTxt.text = lv .. ""
        end
    end

    AddClickEvent(self.minMinusBtn.gameObject, call_back)

    local function call_back()
        if self.minNum < self.minSliderSldr.maxValue then
            self.minNum = self.minNum + 1
            self.minSliderSldr.value = self.minNum
            local lv = GetLevelShow(self.minNum)
            self.minValueTxt.text = lv .. ""
        end
    end

    AddClickEvent(self.minPlusBtn.gameObject, call_back)

    local function call_back()
        if self.maxNum > self.maxSliderSldr.minValue then
            self.maxNum = self.maxNum - 1
            self.maxSliderSldr.value = self.maxNum
            local lv = GetLevelShow(self.maxNum)
            self.maxValueTxt.text = lv .. ""
        end
    end

    AddClickEvent(self.maxMinusBtn.gameObject, call_back)

    local function call_back()
        if self.maxNum < self.maxSliderSldr.maxValue then
            self.maxNum = self.maxNum + 1
            self.maxSliderSldr.value = self.maxNum
            local lv = GetLevelShow(self.maxNum)
            self.maxValueTxt.text = lv .. ""
        end
    end

    AddClickEvent(self.maxPlusBtn.gameObject, call_back)

    local function leftfirstmenuclick_call_back(ClickIndex, is_Show)
        if is_Show then
            --self:CleanSlotItems()
        else
            local s_menu = nil
            local s_index = nil
            local s_count = 1
            for i, v in pairs(self.sub_menu) do
                if s_count >= ClickIndex then
                    s_index = i
                    break
                else
                    s_count = s_count + 1
                end
            end
            GlobalEvent:Brocast(CombineEvent.SelectSecMenuDefault .. self.__cname, self.sub_menu[s_index][1][1])
        end
    end

    self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(CombineEvent.LeftFirstMenuClick .. self.__cname, leftfirstmenuclick_call_back)
    self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(MainEvent.ClickSkiilItem, handler(self, self.Close))
    self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(EventName.OpenPanel, handler(self, self.DealOpenPanel))
	
	
	local function call_back(target, bool)
		local team_info = TeamModel.GetInstance():GetTeamInfo()
		if (team_info.is_auto_accept == 1 and bool) or (team_info.is_auto_accept == 0 and not bool) then
			return
		end
		is_auto_accept = bool and 1 or 0
		TeamController.GetInstance():RequestChangeTarget(nil, nil, nil, is_auto_accept)
		self.model:Brocast(TeamEvent.UpdateApply)	
	end
	AddValueChange(self.ToggleTgl.gameObject, call_back)
end

function CreateTeamPanel:OpenCallBack()
    self:UpdateView()
end

function CreateTeamPanel:DealOpenPanel(_name, _layer, _panel_type)
    if _layer == LayerManager.LayerNameList.UI then
        self:Close()
    end
end

function CreateTeamPanel:DelaySelectFirstMenuDefault()
    GlobalEvent:Brocast(CombineEvent.SelectFstMenuDefault .. self.__cname, 1)
end

function CreateTeamPanel:SelectTreeMenuDefault(SecTypeId)
    --self:Topbuttonclick_call_back(SecTypeId)
    if self.select_default_fst_menu ~= nil then
        GlobalSchedule:Stop(self.select_default_fst_menu)
    end
    self.select_default_fst_menu = GlobalSchedule:StartOnce(handler(self, self.DelaySelectFirstMenuDefault), 0.09)
end

function CreateTeamPanel:UpdateEnterLVInfo(type_id)
    local teamSubCfg = Config.db_team_target_sub[type_id]
    local minLVTbl = String2Table(teamSubCfg.min_lv)
    local maxLVTbl = String2Table(teamSubCfg.max_lv)
    self.minSliderSldr.minValue = minLVTbl[1][1]
    self.minSliderSldr.maxValue = minLVTbl[1][2]
    self.minSliderSldr.value = minLVTbl[1][3]
    self.maxSliderSldr.minValue = maxLVTbl[1][1]
    self.maxSliderSldr.maxValue = maxLVTbl[1][2]
    self.maxSliderSldr.value = maxLVTbl[1][3]
    local lv = GetLevelShow(self.minSliderSldr.value)
    self.minValueTxt.text = lv .. ""
    --local min_lv=
    local level_1 = GetLevelShow(minLVTbl[1][1])
    self.minValue_minTxt.text = level_1 .. ""
    local level_2 = GetLevelShow(minLVTbl[1][2])
    self.minValue_maxTxt.text = level_2 .. ""
    local level_3 = GetLevelShow(self.maxSliderSldr.value)
    self.maxValueTxt.text = level_3 .. ""
    local level_4 = GetLevelShow(maxLVTbl[1][1])
    self.maxValue_minTxt.text = level_4 .. ""
    local level_5 = GetLevelShow(maxLVTbl[1][2])
    self.maxValue_maxTxt.text = level_5 .. ""
    self.minNum = self.minSliderSldr.value
    self.maxNum = self.maxSliderSldr.value
end

function CreateTeamPanel:UpdateView()
    local team_info = self.model:GetTeamInfo()
    local type_id = (self.select_type_id == 0 and (team_info and team_info.type_id or -1) or self.select_type_id)
    self.left_menu = TreeMenu(self.LeftMenu, nil, self)
    self.menuTran = self.left_menu.transform:GetComponent('RectTransform')
    self.menuTran.sizeDelta = Vector2(166, 398)
    self.left_menu:SetViewSize(166, 398)
    self.left_menu.first_item_height = 65
    self.menu, self.sub_menu = {}, {}
    local level = RoleInfoModel:GetInstance():GetMainRoleLevel()
    for i = 1, #Config.db_team_target do
        local item = Config.db_team_target[i]
        local sub_ids = String2Table(item.sub_types)
        local subs = {}
        local need_show = false
        for i = 1, #sub_ids do
            local sub_id = sub_ids[i][1]
            local name = sub_ids[i][2]
            local sub_target = Config.db_team_target_sub[sub_id]
            local min_level = String2Table(sub_target.min_lv)[1][1]
            if level >= min_level then
                subs[#subs + 1] = { sub_id, name }
            end
            if self.limit_type and sub_id == type_id then
                need_show = true
            end
        end
        if (need_show or not self.limit_type) and not table.isempty(subs) then
            local data = { item.id, item.name }
            table.insert(self.menu, data)
            self.sub_menu[item.id] = subs
        end
    end
    self.left_menu:SetData(self.menu, self.sub_menu, type_id, 2, 2)
    self:UpdateByTeam()

    if self.changeTarget then
        self.ok_Text:GetComponent('Text').text = ConfigLanguage.Team.ConfigChange
    else
        --self:SelectTreeMenuDefault()
    end
end

function CreateTeamPanel:CloseCallBack()
    if self.leftsecondmenuclick_event_id then
        GlobalEvent:RemoveListener(self.leftsecondmenuclick_event_id)
        self.leftsecondmenuclick_event_id = nil
    end
end
function CreateTeamPanel:SwitchCallBack(index)
    if self.table_index == index then
        return
    end
    if self.child_node then
        self.child_node:SetVisible(false)
    end
    self.table_index = index
    --if self.table_index == 1 then
    -- if not self.show_panel then
    -- 	self.show_panel = ChildPanel(self.transform)
    -- end
    -- self:PopUpChild(self.show_panel)
    --end
end

function CreateTeamPanel:UpdateByTeam()
    local team_info = self.model:GetTeamInfo()
    if team_info then
        self.select_type_id = team_info.type_id
        self:UpdateEnterLVInfo(self.select_type_id)
        self.minSliderSldr.value = team_info.min_level
        self.maxSliderSldr.value = team_info.max_level  
		self.Toggle:GetComponent('Toggle').isOn = (team_info.is_auto_accept == 1)
        local lv_1 = GetLevelShow(team_info.min_level)
        self.minValueTxt.text = lv_1
        local lv_2 = GetLevelShow(team_info.max_level)
        self.maxValueTxt.text = lv_2
    elseif self.select_type_id > 0 then
        self:UpdateEnterLVInfo(self.select_type_id)
    else
        self:SelectTreeMenuDefault()
    end
end
