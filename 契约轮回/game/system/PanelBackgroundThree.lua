-- 
-- @Author: LaoY
-- @Date:   2018-09-12 15:04:06
-- 
PanelBackgroundThree = PanelBackgroundThree or class("PanelBackgroundThree", BaseWidget)
local this = PanelBackgroundThree

function PanelBackgroundThree:ctor(parent_node, builtin_layer)
    self.abName = "system"
    self.assetName = "PanelBackgroundThree"
    -- 场景对象才需要修改
    -- self.builtin_layer = builtin_layer

    PanelBackgroundThree.super.Load(self)
end

function PanelBackgroundThree:dctor()
    if self.tab_item_list then
        for k, item in pairs(self.tab_item_list) do
            item:destroy()
        end
        self.tab_item_list = {}
    end
end

function PanelBackgroundThree:LoadCallBack()
    self.nodes = {
        "content", "windowCloseBtn", "img_bg_1", "ui_decorate_4_1/img_title","ui_decorate_4_1/icon",--"text_title",
        "ui_decorate_4_1", "tiele_bg", "fram", "ui_decorate_2_1", "ui_decorate_1_1","ui_decorate_4_1/title_icon",
        "static",
    }
    self:GetChildren(self.nodes)
    self.transform:SetAsFirstSibling()

    --self.text_title_component = self.text_title:GetComponent('Text')
    --SetVisible(self.text_title,false)
    self.img_bg_component = self.img_bg_1:GetComponent('Image')
    self.img_title_component = self.img_title:GetComponent('Image')
    self.img_title_icon = self.title_icon:GetComponent('Image')

    if self.is_need_settitle_visible then
        self:SetTitleVisible(self.title_visible)
    end
    self:AddEvent()
end

function PanelBackgroundThree:AddEvent()
    local function call_back(target, x, y)
        if self.close_call_back then
            self.close_call_back()
        end
    end
    AddButtonEvent(self.windowCloseBtn.gameObject, call_back)
end

function PanelBackgroundThree:SetBackgroundImage(abName, assetName)
    lua_resMgr:SetImageTexture(self, self.img_bg_component, abName, assetName, true)
end

-- function PanelBackgroundThree:SetCameraBlur(panel_cls)
-- 	self.panel_cls = panel_cls or self.panel_cls
-- 	if self.is_loaded then
-- 		lua_panelMgr:CameraBlur(self.panel_cls,self.bg)
-- 	else
-- 		self.need_set_camerablur = true
-- 	end
-- end

function PanelBackgroundThree:SetCallBack(close_call_back, switch_call_back)
    self.close_call_back = close_call_back
    self.switch_call_back = switch_call_back
end

function PanelBackgroundThree:SetTitleIcon(abName,assetName,fix_size)
    fix_size = fix_size == nil and false or fix_size
    fix_size = toBool(fix_size);
    lua_resMgr:SetImageTexture(self, self.img_title_icon, abName, assetName, fix_size,nil,false)
end

function PanelBackgroundThree:IsShowSidebar(flag)
    flag = toBool(flag)
    self.show_sidebar = flag
end

function PanelBackgroundThree:SetData(data)
    if not self.show_sidebar then
        return
    end
    data = data or {}
    self.data = data
    self.tab_item_list = self.tab_item_list or {}
    local function callback(index)
        self:SetTabIndex(index)
    end
    local height = GetSizeDeltaY(self.content)
    local offy = 87
    for i = 1, #data do
        local item = self.tab_item_list[i]
        if not item then
            item = PanelTabButtonTwo(self.content, self.layer)
            self.tab_item_list[i] = item
            item:SetPosition(110, -(i - 0.5) * 100 + height)
            item:SetCallBack(callback)
        end
        item:SetData(data[i])
    end
    -- callback(self.default_table_index)

    local height = #data * offy + 60
end

function PanelBackgroundThree:SetTabIndex(index)
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

    if data and data.title_icon then
        local image_res = string.split(data.title_icon, ":")
        local abName = image_res[1] and image_res[1] .. "_image"
        local assetName = image_res[2]
        if abName and assetName then
            self:SetTitleIcon(abName, assetName)
        end
    end

    if self.switch_call_back then
        self.switch_call_back(index)
    end
end

function PanelBackgroundThree:SetTileText(text)
    -- if text then
    -- 	self.text_title_component.text = text
    -- end
end

function PanelBackgroundThree:SetTileIcon()
end

function PanelBackgroundThree:SetTileTextImage(abName, assetName)
    lua_resMgr:SetImageTexture(self, self.img_title_component, abName, assetName, false)
end

function PanelBackgroundThree:SetTitleVisible(flag)
    self.title_visible = flag
    if self.is_loaded then
        SetVisible(self.img_title, flag)
        self.is_need_settitle_visible = false
    else
        self.is_need_settitle_visible = true
    end
end

function PanelBackgroundThree:SetPanelSize(width, height)
    width = tonumber(width);
    height = tonumber(height);
    width = width > 100 and width or 100;
    height = height > 330 and height or 330;
    SetSizeDelta(self.img_bg_1.transform, width, height);
    --SetSizeDelta(self.img_bg_2.transform, width - 16, height * 0.93);
    --SetAnchoredPosition(self.img_bg_2.transform, -5.6, -19);
    SetSizeDelta(self.tiele_bg.transform, width - 8, GetSizeDeltaY(self.tiele_bg.transform));

    SetAnchoredPosition(self.ui_decorate_4_1, (-width / 2 + 120), (height / 2 * 0.90));
    --SetAnchoredPosition(self.icon, (-width / 2 + 17), (height / 2 * 0.95));
    SetAnchoredPosition(self.ui_decorate_1_1, (width / 2 - 21), -(height / 2 * 0.903));
    SetAnchoredPosition(self.ui_decorate_2_1, (-width / 2 + 21), -(height / 2 * 0.903));
    --local x,y = GetAnchoredPosition(self.tiele_bg.transform)
    SetAnchoredPosition(self.tiele_bg.transform, 0, (height / 2 * 0.935));

    SetAnchoredPosition(self.windowCloseBtn.transform, width / 2 - 20, (height / 2 * 0.885));

    SetAnchoredPosition(self.fram.transform, 0, (height / 2 * 0.96));
    --SetAnchoredPosition(self.img_title.transform, -width / 2 + 100, (height / 2 * 0.93));
end

function PanelBackgroundThree:GetItem(id)
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

function PanelBackgroundThree:SetRedDotParam(id,param)
    local item = self:GetItem(id)
    if item then
        item:SetRedDotParam(param)
    end
end

function PanelBackgroundThree:SetRedDotType(id,red_dot_type)
    local item = self:GetItem(id)
    if item then
        item:SetRedDotType(red_dot_type)
    end
end

function PanelBackgroundThree:SetTitleImgPos(x, y)
    SetLocalPositionXY(self.img_title_component.transform, x, y)
end

function PanelBackgroundThree:SetDecoShow(is_show)
    SetVisible(self.static,is_show)
end

function PanelBackgroundThree:SetBgLocalPos(x,y,z)
    SetLocalPosition(self.img_bg_1.transform,x,y,z)
end