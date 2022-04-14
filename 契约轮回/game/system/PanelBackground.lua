-- 
-- @Author: LaoY
-- @Date:   2018-07-20 11:16:32
-- 
PanelBackground = PanelBackground or class("PanelBackground", BaseWidget)
local PanelBackground = PanelBackground

function PanelBackground:ctor(parent_node, builtin_layer)
    self.abName = "system"
    self.assetName = "PanelBackground"

    self.sidebar_config = {
        {
            ["class"] = PanelTabButton,
            ["Bg_W"] = 119,
            ["ScrollView_W"] = 135,
            ["Split_X"] = -51,
            ["Split_Y"] = 9,
            ["Item_StartX"] = 74,
            ["Item_StartY"] = -46,
            ["Item_YSpacing"] = 84,
            ["Item_Position_Method"] = "SetPosition",
            ["topLine_visible"] = true,
        }, {
            ["class"] = PanelTabButtonThree,
            ["Bg_W"] = 58,
            ["ScrollView_W"] = 72,
            ["Split_X"] = 6,
            ["Split_Y"] = 9,
            ["Item_StartX"] = 0,
            ["Item_StartY"] = 246,
            ["Item_YSpacing"] = 119,
            ["Item_Position_Method"] = "SetAnchoredPosition",
            ["topLine_visible"] = false,
        }
    }

    PanelBackground.super.Load(self)
end

function PanelBackground:dctor()
    if self.tab_item_list then
        for k, item in pairs(self.tab_item_list) do
            item:destroy()
        end
        self.tab_item_list = {}
    end
    if self.money_list then
        for k, item in pairs(self.money_list) do
            item:destroy()
        end
        self.money_list = {}
    end

end

function PanelBackground:LoadCallBack()
    self.nodes = {
        "windowTitleCon", "windowTabCon", "windowTitleCon1",  "windowCloseBtn", "windowTitleImg", "money_con",
        "windowTabCon/SideBg", "windowTabCon/img_line_3_1",
        "windowTabCon/scroll/viewport/content", "windowTabCon/scroll/viewport/content/line_bg", "bg",
        "windowTabCon/scroll/viewport", "windowTabCon/scroll", "img_icon", "text_title", "img_bg", "windowTitleCon/img_title", "ui_title_bg_2_1"
    }
    self:GetChildren(self.nodes)

    SetSizeDelta(self.transform, ScreenWidth, ScreenHeight)
    self.transform:SetAsFirstSibling()
    self.scroll_component = self.scroll:GetComponent('ScrollRect')
    self.scroll_component.vertical = false

    self.sidebar_scrollview = self.scroll
    self.sidebar_content = self.content
    self.sidebar_bg = self.SideBg
    self.sidebar_split = self.img_line_3_1
    self.sidebar_topLine = self.line_bg

    self.icon_component = self.img_icon:GetComponent('Image')
    self.text_title_component = self.text_title:GetComponent('Text')
    SetVisible(self.text_title, false)
    self.img_bg_component = self.img_bg:GetComponent('Image')
    self.img_title_component = self.img_title:GetComponent('Image')
    self.windowCloseBtnImg = GetImage(self.windowCloseBtn)
    SetVisible(self.windowTabCon, false)

    self.money_con_defaultPos = self.money_con.anchoredPosition

    if self.need_set_camerablur then
        self:SetCameraBlur()
    end

    if self.is_need_settitle_visible then
        self:SetTitleVisible(self.title_visible)
    end
    self:AddEvent()
end

function PanelBackground:AddEvent()
    local function call_back(target, x, y)
        -- print('--LaoY PanelBackground.lua,line 30--=')
        if self.close_call_back then
            self.close_call_back()
        end
    end
    AddButtonEvent(self.windowCloseBtn.gameObject, call_back)

    local function call_back(target, x, y)
        if not self.is_click_bg_close then
            return
        end
        if self.close_call_back then
            self.close_call_back()
        end
    end
    -- AddClickEvent(self.bg.gameObject,call_back)
end

function PanelBackground:SetBackgroundImage(abName, assetName, isFixedSize)
    if(isFixedSize == nil or type(isFixedSize) ~= "boolean") then
        isFixedSize = true
    end
    lua_resMgr:SetImageTexture(self, self.img_bg_component, abName, assetName, isFixedSize)
end

-- function PanelBackground:SetCameraBlur(panel_cls)
-- 	self.panel_cls = panel_cls or self.panel_cls
-- 	if self.is_loaded then
-- 		lua_panelMgr:CameraBlur(self.panel_cls,self.bg)
-- 	else
-- 		self.need_set_camerablur = true
-- 	end
-- end

function PanelBackground:SetCallBack(close_call_back, switch_call_back)
    self.close_call_back = close_call_back
    self.switch_call_back = switch_call_back
end

function PanelBackground:SetMoney(list)
    if table.isempty(list) then
        return
    end

    if(#list > 3) then
        SetAnchoredPosition(self.money_con, 350, self.money_con_defaultPos.y )
    end

    self.money_list = {}
    local offx = 220
    for i = 1, #list do
        local item = MoneyItem(self.money_con, nil, list[i])
        local x = (i - #list) * offx
        local y = 0
        item:SetPosition(x, y)
        self.money_list[i] = item
    end
end

function PanelBackground:IsShowSidebar(flag, style)
    flag = toBool(flag)
    self.show_sidebar = flag
    self.sidebar_style = style
end

function PanelBackground:ChangeStyle(config)
    SetSizeDeltaX(self.sidebar_bg, config.Bg_W)
    SetSizeDeltaX(self.sidebar_scrollview, config.ScrollView_W)
    SetAnchoredPosition(self.sidebar_split, config.Split_X, config.Split_Y)
    SetVisible(self.sidebar_topLine, config.topLine_visible)
end

function PanelBackground:SetData(data)
    if not self.show_sidebar then
        return
    end
    data = data or {}
    SetVisible(self.windowTabCon, not table.isempty(data))

    ---更改相关UI的Pos及Size
    local config = self.sidebar_config[self.sidebar_style or 1]
    self:ChangeStyle(config)

    self.data = data
    self.tab_item_list = self.tab_item_list or {}

    local function callback(index)
        self:SetTabIndex(index)
    end
    for i = 1, #data do
        local item = self.tab_item_list[i]
        if not item then
            item = config.class(self.content, self.layer)
            self.tab_item_list[i] = item
            ---SideBar的Item可能是RectTransform或Transform,暂时通过保存方法名来处理
            item[config.Item_Position_Method](item, config.Item_StartX, config.Item_StartY - (i - 1) * config.Item_YSpacing)
            item:SetCallBack(callback)
        end
        item:SetData(data[i])
    end
end

function PanelBackground:SetTabIndex(index, show_toggle, force)
    if not force and self.tab_index == index then
        return
    end
    self.tab_index = index
    local data
    if self.tab_item_list then
        for k, item in pairs(self.tab_item_list) do
            item:SetSelectState(item.id == index)
            if item.id == index then
                data = item.data
            end
        end
    end

    if data and data.icon and self.icon_component then
        local image_res = string.split(data.icon, ":")
        local abName = image_res[1] and image_res[1] .. "_image"
        local assetName = image_res[2]
        if abName and assetName then
            -- lua_resMgr:SetImageTexture(self,self.icon_component,abName,assetName,true)
            self:SetTileIcon(abName, assetName)
        end
    end

    -- if data and data.text then
    -- 	self:SetTileText(data.text)
    -- end

    if data and data.img_title then
        local image_res = string.split(data.img_title, ":")
        local abName = image_res[1] and image_res[1] .. "_image"
        local assetName = image_res[2]
        if abName and assetName then
            self:SetTileTextImage(abName, assetName)
        end
    end

    if self.switch_call_back then
        if not show_toggle then
            show_toggle = data and data.show_toggle
        end
        self.switch_call_back(index, show_toggle)
    end
end

function PanelBackground:SetTileText(text)
    -- if text then
    -- 	self.text_title_component.text = text
    -- end
end

function PanelBackground:SetTileIcon(abName, assetName)
    --lua_resMgr:SetImageTexture(self,self.icon_component,abName,assetName,false)
end

function PanelBackground:SetTileTextImage(abName, assetName)
    lua_resMgr:SetImageTexture(self, self.img_title_component, abName, assetName, false)
end

function PanelBackground:SetTitleVisible(flag)
    self.title_visible = flag
    if self.is_loaded then
        SetVisible(self.img_title, flag)
        self.is_need_settitle_visible = false
    else
        self.is_need_settitle_visible = true
    end
end

function PanelBackground:GetItem(id)
    if not self.tab_item_list then
        return nil
    end
    for k, item in pairs(self.tab_item_list) do
        if item.id == id then
            return item
        end
    end
    return nil
end

function PanelBackground:SetRedDotParam(id, param)
    local item = self:GetItem(id)
    if item then
        item:SetRedDotParam(param)
    end
end

function PanelBackground:SetRedDotType(id, red_dot_type)
    local item = self:GetItem(id)
    if item then
        item:SetRedDotType(red_dot_type)
    end
end

function PanelBackground:HideTitleBarAndMoney()
    SetVisible(self.windowTitleCon, false);
    SetVisible(self.ui_title_bg_2_1, false);
    SetVisible(self.bg, false);
    SetGameObjectActive(self.windowTitleCon1, false);
end

function PanelBackground:HideMoney()
    SetVisible(self.money_con,false)
end

function PanelBackground:SetColseImg(abName,assetName)
    lua_resMgr:SetImageTexture(self,self.windowCloseBtnImg, abName, assetName,false)
end

function PanelBackground:SetCloseBtnPos(x,y,z)
    SetAnchoredPosition(self.windowCloseBtn,x,y,z)
end


function PanelBackground:SetPanelSize(width, height)
    print2(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    print2("PanelBackground 不支持SetPanelSize");
    print2("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
end