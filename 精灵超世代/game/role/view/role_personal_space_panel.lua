-- --------------------------------------------------------------------
-- @author: lwc(必填, 创建模块的人员)
-- @editor: lwc(必填, 后续维护以及修改的人员)
-- @description:
--      个人空间
-- <br/>Create: 2019年5月21日
-- --------------------------------------------------------------------
RolePersonalSpacePanel = RolePersonalSpacePanel or BaseClass(BaseView)

local controller = RoleController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_sort = table.sort
local table_insert = table.insert

function RolePersonalSpacePanel:__init(ctrl)
    self.is_full_screen = true
    self.view_tag = ViewMgrTag.DIALOGUE_TAG  
    self.win_type = WinType.Big
    self.layout_name = "roleinfo/role_personal_space_panel" 
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("rolepersonalspace","rolepersonalspace"), type = ResourcesType.plist },
        --以下三个需要弄玩命加载的 先放这里
        -- { path = PathTool.getPlistImgForDownLoad("rolehonorwall","rolehonorwall"), type = ResourcesType.plist },
        -- { path = PathTool.getPlistImgForDownLoad("rolegrowthway","rolegrowthway"), type = ResourcesType.plist },
        -- { path = PathTool.getPlistImgForDownLoad("rolemessageboard","rolemessageboard"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("bigbg/rolepersonalspace", "role_personal_space_bg", false), type = ResourcesType.single}
    }
    --显示的角色类型
    self.role_type = RoleConst.role_type.eMySelf

    self.view_list = {}
    self.tab_list = {}

    self.role_vo = RoleController:getInstance():getRoleVo()
end

function RolePersonalSpacePanel:open_callback(  )
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    
    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 1)

    self.win_title = self.main_container:getChildByName("win_title")
    self.win_title:setString(TI18N("个人空间"))

    --背景
    --self.panel_bg = self.main_container:getChildByName("panel_bg")
    --loadSpriteTexture(self.panel_bg, PathTool.getPlistImgForDownLoad("bigbg/rolepersonalspace", "role_personal_space_bg", false), LOADTEXT_TYPE)
    self.close_btn = self.main_container:getChildByName("close_btn")

    self.container = self.main_container:getChildByName("container")
    local tab_name_list = {
        [1] = TI18N("个人信息"),
        [2] = TI18N("荣誉墙"),
        [3] = TI18N("成长之路"),
        [4] = TI18N("留言板")
    }
    local tab_btn_obj = self.main_container:getChildByName("tab_btn")
    for i=1,4 do
        local tab_btn = {}
        local item = tab_btn_obj:getChildByName("tab_btn_"..i)
        tab_btn.btn = item
        tab_btn.index = i
        tab_btn.select_bg = item:getChildByName("select_img")
        tab_btn.select_bg:setVisible(false)
        tab_btn.title = item:getChildByName("label")
        
        if tab_name_list[i] then
            tab_btn.title:setString(tab_name_list[i])
            tab_btn.title:setFontSize(20)
        end
        if i == RoleConst.Tab_type.eGrowthWay or 
            i == RoleConst.Tab_type.eMessageBoard then
            --成长之路有红点
            tab_btn.redpoint = self.main_container:getChildByName("red_point_"..i)
            if tab_btn.redpoint then
                tab_btn.redpoint:setVisible(false)
            end
        end 
        self.tab_list[i] = tab_btn
    end
    self:checkTabUnlockInfo()
end

function RolePersonalSpacePanel:register_event()
    registerButtonEventListener(self.background, function() self:onClosedBtn()  end, false, 2)
    registerButtonEventListener(self.close_btn, function() self:onClosedBtn()  end, true, 2)

    for index, tab_btn in pairs(self.tab_list) do
       registerButtonEventListener(tab_btn.btn, function() self:changeTabType(index, true) end ,false, 1) 
    end

    if self.role_vo ~= nil then
        if self.role_assets_event == nil then
            self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
                if key == "lev" then
                    self:checkTabUnlockInfo(value)
                end
            end)
        end
    end

     self:addGlobalEvent(RoleEvent.ROLE_MYSELF_GROWTH_WAY_EVENT, function(data)
        if not data then return end
        if data.num == 1 and 
            data.is_redpoint and 
            self.role_type == RoleConst.role_type.eMySelf and 
            self.cur_tab_index ~= RoleConst.Tab_type.eGrowthWay and 
            self.tab_list[RoleConst.Tab_type.eGrowthWay] and 
            not self.tab_list[RoleConst.Tab_type.eGrowthWay].is_lock then
            self:setBtnRedpoint(true, RoleConst.Tab_type.eGrowthWay)
        end
    end)

    self:addGlobalEvent(RoleEvent.ROLE_PS_CHANGE_PANEL_EVENT, function()
        if not self.cur_tab_index then return end
        for i,v in pairs(self.view_list) do
            if i ~= self.cur_tab_index then
                v:setVisibleStatus(false)
            end
        end
    end)
end

function RolePersonalSpacePanel:onClosedBtn()
    if self.role_type == RoleConst.role_type.eOther then
        controller:openOtherRolePersonalSpacePanel(false)
    else
        controller:openRolePersonalSpacePanel(false)
    end
end

function RolePersonalSpacePanel:setBtnRedpoint(status, index)
    if self.tab_list and self.tab_list[index] and self.tab_list[index].redpoint then
        self.tab_list[index].redpoint:setVisible(status)
    end
end

-- @_type 参考 RoleConst.Tab_type 定义
--@check_repeat_click 是否检查重复点击
function RolePersonalSpacePanel:changeTabType(index, check_repeat_click)
    if check_repeat_click and self.cur_tab_index == index then return end

    if self.tab_list[index] and self.tab_list[index].is_lock then
        message(self.tab_list[index].is_lock_des)
        if self.cur_tab_index == nil then
            --说明是初始化的
            self:changeTabType(RoleConst.Tab_type.eRoleInfo)
        end
        return
    end

    if self.cur_tab ~= nil then
        self.cur_tab.title:setTextColor(Config.ColorData.data_new_color4[6])
        self.cur_tab.title:disableEffect(cc.LabelEffect.SHADOW)
        self.cur_tab.select_bg:setVisible(false)
    end
    self.cur_tab_index = index
    self.cur_tab = self.tab_list[self.cur_tab_index]

    if self.cur_tab ~= nil then
        self.cur_tab.title:setTextColor(Config.ColorData.data_new_color4[1])
        self.cur_tab.title:enableShadow(Config.ColorData.data_new_color4[2],cc.size(0, -2),2)
        self.cur_tab.select_bg:setVisible(true)
    end
    --RoleEvent.ROLE_PS_CHANGE_PANEL_EVENT 事件回调隐藏了
    -- if self.pre_panel ~= nil then
    --     if self.pre_panel.setVisibleStatus then
    --         self.pre_panel:setVisibleStatus(false)
    --     end
    -- end
    self.pre_panel = self:createSubPanel(self.cur_tab_index)
    if self.pre_panel ~= nil then
        if self.pre_panel.setVisibleStatus then
            self.pre_panel:setVisibleStatus(true)
        end
    end

    if self.cur_tab_index == RoleConst.Tab_type.eGrowthWay or
       self.cur_tab_index == RoleConst.Tab_type.eMessageBoard then
        self:setBtnRedpoint(false, self.cur_tab_index)
    end
end

function RolePersonalSpacePanel:createSubPanel(index)
    local panel = self.view_list[index]
    if panel == nil then
        if index == RoleConst.Tab_type.eRoleInfo then --个人信息
            panel = RolePersonalSpaceTabInfoPanel.new(self) 
        elseif index == RoleConst.Tab_type.eHonorWall then --荣誉墙
            panel = RolePersonalSpaceTabHonorWallPanel.new(self)
        elseif index == RoleConst.Tab_type.eGrowthWay then --成长之路
            panel = RolePersonalSpaceTabGrowthWayPanel.new(self)
        elseif index == RoleConst.Tab_type.eMessageBoard then --留言板
            panel = RolePersonalSpaceTabMessageBoardPanel.new(self)
        end
        local size = self.container:getContentSize()
        panel:setPosition(cc.p(size.width * 0.5 , size.height * 0.5))
        self.container:addChild(panel,20)
        self.view_list[index] = panel
    end
    return panel
end

function RolePersonalSpacePanel:closeSetNameAlert()
    if self.view_list and self.view_list[1] then
        self.view_list[1]:closeSetNameAlert()
    end
end

function RolePersonalSpacePanel:openRootWnd(setting)
    local setting = setting or {}
    --打开索引
    local index = setting.index or RoleConst.Tab_type.eRoleInfo
    self.role_type = setting.role_type or RoleConst.role_type.eMySelf
    --如果是他人的.表示他人的数据 参考 协议 10315
    self.other_data = setting.other_data 

    --留言板显示bbs_id的 跳转过来的才有
    self.bbs_id = setting.bbs_id
    
    self:changeTabType(index)

    if self.role_type == RoleConst.role_type.eMySelf then
        local is_show1 = PromptController:getInstance():getModel():checkPromptDataByTpye(PromptTypeConst.BBS_message)
        local is_show2 = PromptController:getInstance():getModel():checkPromptDataByTpye(PromptTypeConst.BBS_message_reply_self)
        if is_show1 or is_show2 then
            self:setBtnRedpoint(true, RoleConst.Tab_type.eMessageBoard)
        end
    end

    if self.role_type == RoleConst.role_type.eMySelf then
        controller:send25830(0, 1)
    end
end

function RolePersonalSpacePanel:checkTabUnlockInfo(lev)
    if not self.role_vo then return end
    for k,v in ipairs(self.tab_list) do
        if v.index == RoleConst.Tab_type.eHonorWall then
            local config = Config.RoomFeatData.data_const.badge_open_limit
            if config then
                local lev = lev or self.role_vo.lev
                if lev < config.val then
                    v.is_lock = true
                    v.is_lock_des = config.desc
                    setChildUnEnabled(true, v.btn,Config.ColorData.data_new_color4[18])
                    -- v.title:enableOutline(Config.ColorData.data_color4[1], 2)
                else
                    v.is_lock = false
                    setChildUnEnabled(false, v.btn,Config.ColorData.data_new_color4[6])
                    -- v.title:enableOutline(cc.c4b(0x56,0x2a,0x17,0xff), 2)
                end 
            end
        elseif v.index == RoleConst.Tab_type.eGrowthWay then
            local config = Config.RoomGrowData.data_const.open_lev_limit
            if config then
                local lev = lev or self.role_vo.lev
                if lev < config.val then
                    v.is_lock = true
                    v.is_lock_des = config.desc
                    setChildUnEnabled(true, v.btn,Config.ColorData.data_new_color4[18])
                    -- v.title:disableEffect(cc.LabelEffect.OUTLINE)
                else
                    v.is_lock = false
                    setChildUnEnabled(false, v.btn,Config.ColorData.data_new_color4[6])
                    -- v.title:enableOutline(cc.c4b(0x56,0x2a,0x17,0xff), 2)
                end 
            end
        elseif v.index == RoleConst.Tab_type.eMessageBoard then
            local config = Config.RoomGrowData.data_const.bbs_open_limit
            if config then
                local lev = lev or self.role_vo.lev
                if lev < config.val then
                    v.is_lock = true
                    v.is_lock_des = config.desc
                    setChildUnEnabled(true, v.btn,Config.ColorData.data_new_color4[18])
                    -- v.title:disableEffect(cc.LabelEffect.OUTLINE)
                else
                    v.is_lock = false
                    setChildUnEnabled(false, v.btn,Config.ColorData.data_new_color4[6])
                    -- v.title:enableOutline(cc.c4b(0x56,0x2a,0x17,0xff), 2)
                end 
            end
        end
    end
end

function RolePersonalSpacePanel:close_callback()
    if self.role_vo ~= nil then
        if self.role_assets_event ~= nil then
            self.role_vo:UnBind(self.role_assets_event)
            self.role_assets_event = nil
        end
        self.role_vo = nil
    end

    for i,v in pairs(self.view_list) do 
        v:DeleteMe()
    end
    self.view_list = nil
    
    if self.role_type == RoleConst.role_type.eOther then
        controller:openOtherRolePersonalSpacePanel(false)
    else
        controller:openRolePersonalSpacePanel(false)
    end
end
