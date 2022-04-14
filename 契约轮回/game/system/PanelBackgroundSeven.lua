-- 
-- @Author: LaoY
-- @Date:   2018-09-12 15:04:06
-- 
PanelBackgroundSeven = PanelBackgroundSeven or class("PanelBackgroundSeven", BaseWidget)
local this = PanelBackgroundSeven

function PanelBackgroundSeven:ctor(parent_node, builtin_layer)
    self.abName = "system"
    self.assetName = "PanelBackgroundSeven"
    -- 场景对象才需要修改
    -- self.builtin_layer = builtin_layer

    PanelBackgroundSeven.super.Load(self)
end

function PanelBackgroundSeven:dctor()
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

function PanelBackgroundSeven:LoadCallBack()
    self.nodes = {
        "content", "windowCloseBtn", "img_title", "money_con",
        "more_btn", "Title_Bg",
    }
    self:GetChildren(self.nodes)
    self.transform:SetAsFirstSibling()
    self.img_title_component = self.img_title:GetComponent('Image')
    self.img_title_trans = self.img_title:GetComponent('RectTransform')
    self.img_btn_close_component = self.windowCloseBtn:GetComponent('Image');
    self.more_btn = GetButton(self.more_btn);
    SetGameObjectActive(self.more_btn.gameObject, false);
    local height = GetSizeDeltaY(self.money_con)
    local y = ScreenHeight * 0.5 - height * 0.5
    SetLocalPositionY(self.money_con, y)

    if self.is_need_settitle_visible then
        self:SetTitleVisible(self.title_visible)
    end

    self:AddEvent()
end

function PanelBackgroundSeven:AddEvent()
    local function call_back(target, x, y)
        if self.close_call_back then
            self.close_call_back()
        end
    end
    AddButtonEvent(self.windowCloseBtn.gameObject, call_back)
end

--设置标题位置
function PanelBackgroundSeven:SetTitleImgPos(x, y)
    SetAnchoredPosition(self.img_title_trans, x, y)
end

--设置按钮图片
function PanelBackgroundSeven:SetBtnCloseImg(abName, assetName)
    lua_resMgr:SetImageTexture(self, self.img_btn_close_component, abName, assetName, true)
end

--
-- function PanelBackgroundSeven:SetCameraBlur(panel_cls)
--  self.panel_cls = panel_cls or self.panel_cls
--  if self.is_loaded then
--      lua_panelMgr:CameraBlur(self.panel_cls,self.bg)
--  else
--      self.need_set_camerablur = true
--  end
-- end

function PanelBackgroundSeven:SetCallBack(close_call_back, switch_call_back)
    self.close_call_back = close_call_back
    self.switch_call_back = switch_call_back
end

function PanelBackgroundSeven:IsShowSidebar(flag)
    flag = toBool(flag)
    self.show_sidebar = flag
end

function PanelBackgroundSeven:SetData(data)
    if not self.show_sidebar then
        return
    end
    data = data or {}
    self.data = data
    self.tab_item_list = self.tab_item_list or {}
    local function callback(index, show_toggle)
        self:SetTabIndex(index, show_toggle)
    end
    local height = GetSizeDeltaY(self.content) + 32
    local offy = 110
    for i = 1, #data do
        local item = self.tab_item_list[i]
        if not item then
            item = PanelTabButtonTwo(self.content, self.layer)
            self.tab_item_list[i] = item
            item:SetPosition(95, -(i - 0.5) * offy + height)
            item:SetCallBack(callback)
        end
        item:SetData(data[i])
        item:SetSideBarRes()
    end
    if #data > 5 then
        SetGameObjectActive(self.more_btn.gameObject, true);
    else
        SetGameObjectActive(self.more_btn.gameObject, false);
    end
    -- callback(self.default_table_index)

    local height = #data * offy + 60
end

function PanelBackgroundSeven:SetMoney(list)
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

function PanelBackgroundSeven:SetTabIndex(index, show_toggle)
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
    --  self:SetTileText(data.text)
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
        if not show_toggle then
            show_toggle = data and data.show_toggle
        end
        self.switch_call_back(index, show_toggle)
    end
end

function PanelBackgroundSeven:SetTileText()
end

function PanelBackgroundSeven:SetTileTextImage(abName, assetName, fix_size)
    fix_size = fix_size == nil and false or fix_size
    fix_size = toBool(fix_size);
    lua_resMgr:SetImageTexture(self, self.img_title_component, abName, assetName, fix_size)
end

function PanelBackgroundSeven:SetTitleIcon(abName, assetName, fix_size)
    fix_size = fix_size == nil and false or fix_size
    fix_size = toBool(fix_size);
end

function PanelBackgroundSeven:SetTitleVisible(flag)
    self.title_visible = flag
    if self.is_loaded then
        SetVisible(self.img_title, flag)
        self.is_need_settitle_visible = false
    else
        self.is_need_settitle_visible = true
    end
end

function PanelBackgroundSeven:GetItem(id)
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

function PanelBackgroundSeven:SetRedDotParam(id, param)
    local item = self:GetItem(id)
    if item then
        item:SetRedDotParam(param)
    end
end

function PanelBackgroundSeven:SetRedDotType(id, red_dot_type)
    local item = self:GetItem(id)
    if item then
        item:SetRedDotType(red_dot_type)
    end
end

function PanelBackgroundSeven:SetPanelSize(width, height)
    print2(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    print2("PanelBackgroundSeven 不支持SetPanelSize");
    print2("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
end

function PanelBackgroundSeven:SetMoneyConLast(parent)
    if self.money_con then
        SetParent(self.money_con.transform, parent);
        SetAsLastSibling(self.money_con);
    end
end

function PanelBackgroundSeven:ShowIndependenceTitleBg()
    SetVisible(self.Title_Bg, true)
end