--
-- @Author: chk
-- @Date:   2018-12-16 15:11:18
--
PanelBackgroundSix = PanelBackgroundSix or class("PanelBackgroundSix", BaseWidget)
local PanelBackgroundSix = PanelBackgroundSix

function PanelBackgroundSix:ctor(parent_node, builtin_layer)
    self.abName = "system"
    self.assetName = "PanelBackgroundSix"
    -- 场景对象才需要修改
    -- self.builtin_layer = builtin_layer

    -- self.model = 2222222222222end:GetInstance()
    PanelBackgroundSix.super.Load(self)
end

function PanelBackgroundSix:dctor()
    if self.tab_item_list then
        for k, item in pairs(self.tab_item_list) do
            item:destroy()
        end
        self.tab_item_list = {}
    end
end

function PanelBackgroundSix:LoadCallBack()
    self.nodes = {
        "content", "windowCloseBtn", "text_title", "img_bg_1", "img_title", "tiele_bg", "fram", "title_icon", "img_title_bg",
    }
    self:GetChildren(self.nodes)
    self.transform:SetAsFirstSibling()

    self.text_title_component = self.text_title:GetComponent('Text')
    SetVisible(self.text_title, false)
    self.img_bg_component = self.img_bg_1:GetComponent('Image')
    self.img_title_component = self.img_title:GetComponent('Image')
    self.img_title_bg_component = self.tiele_bg:GetComponent('Image')
    self.img_title_center_bg_component = self.fram:GetComponent('Image')
    self.img_title_trans = self.img_title:GetComponent('RectTransform')
    self.img_btn_close_component = self.windowCloseBtn:GetComponent('Image')
    self.img_title_icon = self.title_icon:GetComponent('Image')
    self.icon_bg = GetImage(self.img_title_bg)

    if self.is_need_settitle_visible then
        self:SetTitleVisible(self.title_visible)
    end

    self:AddEvent()
end

function PanelBackgroundSix:AddEvent()
    local function call_back(target, x, y)
        if self.close_call_back then
            self.close_call_back()
        end
    end
    AddButtonEvent(self.windowCloseBtn.gameObject, call_back)
end

function PanelBackgroundSix:SetBackgroundImage(abName, assetName)
    lua_resMgr:SetImageTexture(self, self.img_bg_component, abName, assetName, true)
end

-- function PanelBackgroundTwo:SetCameraBlur(panel_cls)
-- 	self.panel_cls = panel_cls or self.panel_cls
-- 	if self.is_loaded then
-- 		lua_panelMgr:CameraBlur(self.panel_cls,self.bg)
-- 	else
-- 		self.need_set_camerablur = true
-- 	end
-- end

function PanelBackgroundSix:SetCallBack(close_call_back, switch_call_back)
    self.close_call_back = close_call_back
    self.switch_call_back = switch_call_back
end

function PanelBackgroundSix:IsShowSidebar(flag)
    flag = toBool(flag)
    self.show_sidebar = flag
end

function PanelBackgroundSix:SetData(data)
    if not self.show_sidebar then
        return
    end
    data = data or {}
    self.data = data
    self.tab_item_list = self.tab_item_list or {}
    local function callback(index, show_toggle)
        self:SetTabIndex(index, show_toggle)
    end
    local height = GetSizeDeltaY(self.content)
    local offy = 87
    for i = 1, #data do
        local item = self.tab_item_list[i]
        if not item then
            item = PanelTabButtonTwo(self.content, self.layer)
            self.tab_item_list[i] = item
            item:SetPosition(110, -(i - 0.5) * offy + height)
            item:SetCallBack(callback)
        end
        item:SetData(data[i])
    end
    -- callback(self.default_table_index)

    local height = #data * offy + 60
end

function PanelBackgroundSix:SetMoney(list)
    if table.isempty(list) then
        return
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

function PanelBackgroundSix:SetTabIndex(index, show_toggle)
    if self.tab_index == index then
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

function PanelBackgroundSix:SetTileText(text)
    -- if text then
    -- 	self.text_title_component.text = text
    -- end
end

function PanelBackgroundSix:SetTileTextImage(abName, assetName, fix_size)
    fix_size = fix_size == nil and false or fix_size
    fix_size = toBool(fix_size);
    lua_resMgr:SetImageTexture(self, self.img_title_component, abName, assetName, fix_size)
end

function PanelBackgroundSix:SetTitleIcon(abName, assetName, fix_size)
    fix_size = fix_size == nil and false or fix_size
    fix_size = toBool(fix_size);
    lua_resMgr:SetImageTexture(self, self.img_title_icon, abName, assetName, fix_size)
end

function PanelBackgroundSix:SetTitleVisible(flag)
    self.title_visible = flag
    if self.is_loaded then
        SetVisible(self.img_title, flag)
        self.is_need_settitle_visible = false
    else
        self.is_need_settitle_visible = true
    end
end

--顶部条形背景
function PanelBackgroundSix:SetTitleBgImage(abName, assetName)
    lua_resMgr:SetImageTexture(self, self.img_title_bg_component, abName, assetName, true)
end

--标题背景
function PanelBackgroundSix:SetTopCenterBg(abName, assetName)
    lua_resMgr:SetImageTexture(self, self.img_title_center_bg_component, abName, assetName, false)
end

--设置标题位置
function PanelBackgroundSix:SetTitleImgPos(x, y)
    SetAnchoredPosition(self.img_title_trans, x, y)
end

--设置按钮图片
function PanelBackgroundSix:SetBtnCloseImg(abName, assetName, isBecomeCandyStyle)
    lua_resMgr:SetImageTexture(self, self.img_btn_close_component, abName, assetName, true)
    if not isBecomeCandyStyle then
        return
    end
    SetVisible(self.img_title_icon, false)
    SetVisible(self.icon_bg, false)
end

function PanelBackgroundSix:GetItem(id)
    if not self.tab_item_list then
        return nil
    end
    for k,item in pairs(self.tab_item_list) do
        if item.id == id then
            return item
        end
    end
    return nil
end

function PanelBackgroundSix:SetRedDotParam(id,param)
    local item = self:GetItem(id)
    if item then
        item:SetRedDotParam(param)
    end
end

function PanelBackgroundSix:SetRedDotType(id,red_dot_type)
    local item = self:GetItem(id)
    if item then
        item:SetRedDotType(red_dot_type)
    end
end