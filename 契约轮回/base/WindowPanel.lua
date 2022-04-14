-- 
-- @Author: LaoY
-- @Date:   2018-07-20 11:38:14
-- 默认是要用通用底窗

WindowPanel = WindowPanel or class("WindowPanel", BasePanel)
local this = WindowPanel
function WindowPanel:ctor()
    self.bg_win = nil

    --[[
            @des 窗体样式
                 1 1280*720
                 2 850*545
        --]]
    self.panel_type = 1                                --界面类型，根据大小排序， 1全屏大界面 2非全屏大界面 3二级界面 4小界面
    self.show_sidebar = true                        -- 是否显示侧边标签栏
    self.sidebar_data = nil
    --[[
        ps: 在SidebarConfig 配置
        panel_type == 1
        self.sidebar_data = {
            {text = ConfigLanguage.Bag.Bag,id = 1,img_title = "system:ui_img_text_title",icon = "bag:bag_icon_bag_s",dark_icon = "bag:bag_icon_bag_n"},
        }

        panel_type == 2
        self.sidebar_data = {
            {text = ConfigLanguage.Bag.Bag,id = 1,img_title = "system:ui_img_text_title"},
        }
    ]]
    self.is_click_bg_close = false                    -- 点击是否关闭界面，这里是全屏界面，不需要
    self.use_background = true                        -- 是否显示黑色背景。这里不需要，自带背景
    self.use_camerablur = true                        -- 使用高斯模糊 如果只继承 BasePanel,默认会use_background=true
    self.change_scene_close = true                    -- 切换场景关闭
    self.is_hide_other_panel = false                  -- 打开改界面，隐藏底部的其他界面
    self.is_show_toggle = false                       -- 是否显示切换栏
    self.is_show_light_decorate = false               --是否显示顶部灯光装饰
    self.is_show_indepen_title_bg = false               --是否显示一块独立的标题背景

    self.is_hide_bottom_panel = true
    self.default_table_index = 1                    --默认选择的标签
    self.default_toggle_index = nil                --默认toggle id
    self.is_show_money = { Constant.GoldType.Gold, Constant.GoldType.BGold, Constant.GoldType.Coin }    --是否显示钱

    self.__role_event_list = {}

    self.toggle_red_dot_list = {}
    self.red_dot_list = {}
    self.red_dot_type_list = {}
end

function WindowPanel:dctor()
    self.toggle_red_dot_list = {}
    self.red_dot_list = {}
    self.red_dot_type_list = {}

    if self.__role_event_list then
        for k, event_id in pairs(self.__role_event_list) do
            RoleInfoModel:GetInstance():GetMainRoleData():RemoveListener(event_id)
        end
        self.__role_event_list = nil
    end

    if self.bg_win then
        self.bg_win:destroy()
        self.bg_win = nil
    end
    if self.toggle_group then
        self.toggle_group:destroy()
        self.toggle_group = nil
    end

end

function WindowPanel:Open()

    WindowPanel.super.Open(self)
end

function WindowPanel:Close()
    WindowPanel.super.Close(self)
end

function WindowPanel:AfterCreate()
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
        if self.is_show_indepen_title_bg then
            self.bg_win:ShowIndependenceTitleBg()
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
-- 生成 toggle __cname  名字
    if self.show_sidebar and not self.sidebar_data then
        self.sidebar_data = SidebarConfig[self.__cname]
    end

    self:LoadCallBack()

    self:SetSidebarData()

    self:UpdateRedDot()

    self:SetTabIndex(self.default_table_index, self.default_toggle_index)

    if (self.panel_type == 1 or self.panel_type == 2 or self.panel_type == 7) and self.is_show_money then
        self.bg_win:SetMoney(self.is_show_money)
    end

    if self.is_show_light_decorate then
        if self.bg_win then
            self.bg_win:ShowLightDecorate()
        end
    end
    self:SetTitleLast()


    -- 绑定事件
    local function call_back()
        self:SetSidebarData()
        self:SetToggleGroup(self.switch_index, self.toggle_id)
    end
    self.__role_event_list[#self.__role_event_list + 1] = RoleInfoModel:GetInstance():GetMainRoleData():BindData("level", call_back)
end

function WindowPanel:GetOpenPanelActionConfig()
    local config = WindowPanel.super.GetOpenPanelActionConfig(self)
    local t

    t = {
        action_name = "CallFunc",
        param = function()
            if self.bg_win and self.bg_win.money_con then
                SetVisible(self.bg_win.money_con, false)
            end
        end,
    }
    table.insert(config, 1, t)

    t = {
        action_name = "CallFunc",
        param = function()
            if self.bg_win and self.bg_win.money_con then
                SetVisible(self.bg_win.money_con, true)
            end
        end,
    }
    table.insert(config, t)
    return config
end

function WindowPanel:SetTitleLast()
    if self.panel_type ~= 1 then
        return
    end
    if not self.title_con then
        self.title_con = GameObject("title_con")
        self.title_con_transform = self.title_con.transform
        self.title_con_transform:SetParent(self.transform)
        SetLocalPosition(self.title_con_transform, 0, 0, 0)
        SetLocalScale(self.title_con_transform)
        self.title_con_transform:SetAsLastSibling()
    end
    self.bg_win.windowTitleCon:SetParent(self.title_con_transform)
end

--[[
    @author LaoY
    @des    把侧边按钮放在最上层
--]]
function WindowPanel:SetSidebarLast()
    if self.panel_type ~= 1 and self.panel_type ~= 2 and self.panel_type ~= 7 then
        return
    end

    if not self.sidebar_gameObject then
        self.sidebar_gameObject = GameObject("sidebar_con")
        self.sidebar_transform = self.sidebar_gameObject.transform
        self.sidebar_transform:SetParent(self.transform)
        SetLocalPosition(self.sidebar_transform, 0, 0, 0)
        SetLocalScale(self.sidebar_transform)
        self.sidebar_transform:SetAsLastSibling()
    end
    if self.panel_type == 2 or self.panel_type == 7 then
        self.bg_win.content:SetParent(self.sidebar_transform)
    end
end

function WindowPanel:MenuCallBack(index, toggle_id, is_update)
    if (not index or self.switch_index == index) and (not toggle_id or self.toggle_id == toggle_id) then
        return
    end
    self.switch_index = index

    if toggle_id then
        self:CreateToggleGroup()
        self.toggle_group.select_id = nil
        self.toggle_group:SetVisible(true)
        if is_update then
            self:SetToggleGroup(index, toggle_id)
            toggle_id = self.toggle_group:GetToggleID(toggle_id)
            self:SwitchCallBack(index, toggle_id)
            self:UpdateToggleRedDot()
        else
            self:SwitchCallBack(index, toggle_id)
        end
        self.toggle_id = toggle_id

        -- self.toggle_group:SetSiblingIndex(1000)
    else
        if self.toggle_group then
            self.toggle_group:SetVisible(false)
        end
        self:SwitchCallBack(index)
    end
end

function WindowPanel:GetSidebarDataByID(switch_index)
    if self.show_sidebar_list and self.show_sidebar_list.id == switch_index then
        return self.show_sidebar_list
    end

    if table.isempty(self.sidebar_data) then
        return nil
    end

    for k, v in pairs(self.sidebar_data) do
        if v.id == switch_index then
            return v
        end
    end
    return nil
end

function WindowPanel:GetToggleDataByID(switch_index)
    local sidebar_data = self:GetSidebarDataByID(switch_index)
    if not sidebar_data or not sidebar_data.toggle_data then
        return
    end
    local toggle_data = sidebar_data.toggle_data
    local data = {}
    local len = #toggle_data
    for i = 1, len do
        local info = toggle_data[i]
        if info.show_func then
            if not info.show_func() then
                data[#data + 1] = info
            end
        elseif IsOpenModular(info.show_lv, info.show_task) then
            data[#data + 1] = info
        end
    end
    return data
end

function WindowPanel:CreateToggleGroup()
    if not self.toggle_group then
        self.toggle_group = ToggleGroup(self.transform)
        if self.panel_type == 1 then
            self:SetToggleGroupPosition(0, 0)
        elseif self.panel_type == 2 then
            self:SetToggleGroupPosition(-18, 215)
        else
            self:SetToggleGroupPosition(-18, 206)
        end
        local function call_back(id)
            self:MenuCallBack(self.switch_index, id)
        end
        self.toggle_group:SetCallBack(call_back)
        self.toggle_group.transform:SetAsLastSibling()
    end
end

--[[
    @author LaoY
    @des    
    @param1 id                  id
    @param2 text                toggle显示文本
    
    /*以下参数可不填，需要不可点击才填*/
    /*二选一*/
    @param3 is_cannot_click     不可点击。true 不可点击，false可点击。不填默认是可以点击
    @param3 check_func          检查是否可以点击方法，带返回值。返回true可点击,false不可点击

    @param4 is_cannot_click_tip 不可点击语言提示，可不填。
--]]
function WindowPanel:SetToggleGroup(switch_index, toggle_id)
    if self.panel_type ~= 1 and self.panel_type ~= 2 and self.panel_type ~= 7 then
        return
    end
    local data = self:GetToggleDataByID(switch_index)
    if not data then
        return
    end
    self:CreateToggleGroup()
    if self.toggle_group then
        self.toggle_group:SetData(data, toggle_id)
    end
end

function WindowPanel:SetToggleGroupPosition(x, y)
    if self.toggle_group then
        self.toggle_group:SetPosition(x, y)
    end
end

--[[
    @author LaoY
    @des    设置底图
--]]
function WindowPanel:SetBackgroundImage(abName, assetName, isFixSize)
    if self.bg_win then
        assetName = assetName or abName
        self.bg_win:SetBackgroundImage(abName, assetName, isFixSize)
    end
end

--设置界面背景图
function WindowPanel:SetPanelBgImage(abName, assetName)
    if self.bg_win then
        assetName = assetName or abName
        self.bg_win:SetPanelBgImage(abName, assetName)
    end
end

--设置顶部条形背景
function WindowPanel:SetTitleBgImage(abName, assetName)
    if self.bg_win then
        assetName = assetName or abName
        self.bg_win:SetTitleBgImage(abName, assetName)
    end
end

--设置标题背景
function WindowPanel:SetTopCenterBg(abName, assetName)
    if self.bg_win then
        assetName = assetName or abName
        self.bg_win:SetTopCenterBg(abName, assetName)
    end
end

--设置关闭按钮图片
function WindowPanel:SetBtnCloseImg(abName, assetName, isBecomeCandyStyle)
    if self.bg_win then
        assetName = assetName or abName
        self.bg_win:SetBtnCloseImg(abName, assetName, isBecomeCandyStyle)
    end
end

--设置面板左上角的icon
function WindowPanel:SetTitleIcon(abName, assetName, fix_size)
    if self.bg_win then
        assetName = assetName or abName
        self.bg_win:SetTitleIcon(abName, assetName, fix_size)
    end
end
-- function WindowPanel:SetCameraBlur()
--  if self.bg_win then
--      self.bg_win:SetCameraBlur(self)
--  end
-- end

--[[
    @author LaoY
    @des    
    @param1 index           右侧标签
    @param2 show_toggle     界面上方toggle，可不填
    @param3 force           强制刷新
--]]
function WindowPanel:SetTabIndex(index, show_toggle, force)
    if self.bg_win then
        self.bg_win:SetTabIndex(index, show_toggle, force)
    end
end

--[[
    @author LaoY
    @des    设置标题
--]]
function WindowPanel:SetTileText(text)
    if self.bg_win then
        self.bg_win:SetTileText(text)
    end
end

--[[
    @author LaoY
    @des    设置标题图标 只有 panel_type == 1 才有效果
--]]
function WindowPanel:SetTileIcon(abName, assetName)
    if self.bg_win then
        self.bg_win:SetTileIcon(abName, assetName)
    end
end

--[[
    @author LaoY
    @des    设置标题艺术字
--]]
function WindowPanel:SetTileTextImage(abName, assetName, fix_size)
    if self.bg_win then
        self.bg_win:SetTileTextImage(abName, assetName, fix_size)
    end
end

--设置背景的位置 (3号背景已添加)
function WindowPanel:SetBgLocalPos(x, y, z)
    -- body
    if self.bg_win then
        self.bg_win:SetBgLocalPos(x, y, z)
    end
end

--设置标题艺术字的位置
function WindowPanel:SetTitleImgPos(x, y)
    if self.bg_win then
        self.bg_win:SetTitleImgPos(x, y)
    end
end

function WindowPanel:SetTitleVisible(flag)
    if self.bg_win then
        self.bg_win:SetTitleVisible(flag)
    end
end

--[[
    @author LaoY
    @des    设置标签信息
--]]
function WindowPanel:SetSidebarData()
    if not self.show_sidebar or not self.sidebar_data then
        return
    end
    local data = {}
    local len = #self.sidebar_data
    for i = 1, len do
        local info = self.sidebar_data[i]
        local level = info.show_lv or 0
        local task = info.show_task or 0
        if info.show_func then
            if not info.show_func() then
                data[#data + 1] = info
            end
        elseif IsOpenModular(level, task) then
            data[#data + 1] = info
        end
    end
    self.default_table_index = self.default_table_index or 1
    local default_table_index = data[1] and data[1].id or self.default_table_index
    for i = 1, #data do
        if self.default_table_index == data[i].id then
            default_table_index = data[i].id
            break
        end
    end
    self.default_table_index = default_table_index
    
    self.bg_win:SetData(data)
    self.show_sidebar_list = data
    if self.switch_index then
        self:SetTabIndex(self.switch_index, self.toggle_id, true)
    end
end

function WindowPanel:AfterOpen()
    self:OpenCallBack()
end

function WindowPanel:SetTabData(data)

end


-- 红点相关
function WindowPanel:UpdateRedDot()
    if not table.isempty(self.red_dot_type_list) then
        for index, red_dot_type in pairs(self.red_dot_type_list) do
            self:SetIndexSetRedDotType(index, red_dot_type)
        end
    end

    if not table.isempty(self.red_dot_list) then
        for index, param in pairs(self.red_dot_list) do
            self:SetIndexRedDotParam(index, param)
        end
    end
end

--[[
    @author LaoY
    @des    设置右边栏红点类型；默认都是普通红点（不带数字红点），需要数字红点额外设置;
    @param1 index           右边栏 id
    @param2 red_dot_type    红点类型 RedDot.RedDotType.Nor(普通)  RedDot.RedDotType.Num(数字)
--]]
function WindowPanel:SetIndexSetRedDotType(index, red_dot_type)
    self.red_dot_type_list[index] = red_dot_type
    if self.bg_win then
        self.bg_win:SetRedDotType(index, red_dot_type)
    end
end

--[[
    @author LaoY
    @des
    @param1 index   右边栏 id
    @param2 param   如果是普通红点，填bool；如果是数字红点，填number
--]]
function WindowPanel:SetIndexRedDotParam(index, param)
    self.red_dot_list[index] = param
    if self.bg_win then
        self.bg_win:SetRedDotParam(index, param)
    end
end

function WindowPanel:UpdateToggleRedDot()
    if not self.switch_index then
        return
    end
    if table.isempty(self.toggle_red_dot_list[self.switch_index]) then
        return
    end
    self.toggle_group:ResetRedDot()
    for toggle_id, param in pairs(self.toggle_red_dot_list[self.switch_index]) do
        self.toggle_group:SetRedDotParam(toggle_id, param)
    end
end

--[[
    @author LaoY
    @des    设置toggle红点
    @param1 index       右边栏 id
    @param2 toggle_id   toggle_id
    @param3 param       如果是普通红点，填bool；如果是数字红点，填number
--]]
function WindowPanel:SetToggleRedDotParam(index, toggle_id, param)
    self.toggle_red_dot_list[index] = self.toggle_red_dot_list[index] or {}
    self.toggle_red_dot_list[index][toggle_id] = param
    if index ~= self.switch_index then
        return
    end
    if self.toggle_group then
        self.toggle_group:SetRedDotParam(toggle_id, param)
    end
end

function WindowPanel:HideTitleBarAndMoney()
    if self.panel_type == 1 then
        self.bg_win:HideTitleBarAndMoney();
        --self.title_con = true;
    end
end

function WindowPanel:HideMoney()
    if self.panel_type == 1 then
        self.bg_win:HideMoney();
        --self.title_con = true;
    end
end

function WindowPanel:SetColseImg(abName,assetName)
    if self.panel_type == 1 then
        self.bg_win:SetColseImg(abName,assetName)
        --self.title_con = true;
    end
end

function WindowPanel:SetCloseBtnPos(x,y,z)
    if self.panel_type == 1 then
        self.bg_win:SetCloseBtnPos(x,y,z)
    end
end

function WindowPanel:RemoveSidebarConfigById(id)
    if not self.sidebar_data then
        self.sidebar_data = SidebarConfig[self.__cname]
    end
    
end


-- 红点相关

-- overwrite
function WindowPanel:SwitchCallBack(index)
    logWarn(string.format("%s 界面要重写 SwitchCallBack方法", self.assetName))
end

function WindowPanel:SetPanelSize(width, height)
    if self.bg_win then
        self.bg_win:SetPanelSize(width, height);
    end
end

function WindowPanel:SetMoneyConLast(parent)
    if self.bg_win and self.bg_win.SetMoneyConLast then
        self.bg_win:SetMoneyConLast(parent);
    end
end

function WindowPanel:SetTitleBgVisible(flag)    
    if self.bg_win and self.panel_type == 6 then
        self.bg_win:SetTitleBgVisible(flag)
    end
end