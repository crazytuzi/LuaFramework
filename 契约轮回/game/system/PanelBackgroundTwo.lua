-- 
-- @Author: LaoY
-- @Date:   2018-09-12 15:04:06
-- 
PanelBackgroundTwo = PanelBackgroundTwo or class("PanelBackgroundTwo", BaseWidget)
local this = PanelBackgroundTwo

function PanelBackgroundTwo:ctor(parent_node, builtin_layer)
    self.abName = "system"
    self.assetName = "PanelBackgroundTwo"
    -- 场景对象才需要修改
    -- self.builtin_layer = builtin_layer

    PanelBackgroundTwo.super.Load(self)
end

function PanelBackgroundTwo:dctor()
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

function PanelBackgroundTwo:LoadCallBack()
    self.nodes = {
        "content", "windowCloseBtn", "text_title", "img_bg_1", "img_title", "money_con", "img_bg_2", "tiele_bg", "fram",
        "ui_decorate_5_1", "more_btn","title_icon","ui_decorate_4_1"
    }
    self:GetChildren(self.nodes)
    self.transform:SetAsFirstSibling()

    self.text_title_component = self.text_title:GetComponent('Text')
    SetVisible(self.text_title, false)
    self.img_bg_component = self.img_bg_1:GetComponent('Image')
    self.img_panel_component = self.img_bg_2:GetComponent('Image')
    self.img_title_component = self.img_title:GetComponent('Image')
    self.img_title_trans = self.img_title:GetComponent('RectTransform')
    self.img_title_bg_component = self.tiele_bg:GetComponent('Image')
    self.img_title_center_bg_component = self.fram:GetComponent('Image')
    self.img_btn_close_component = self.windowCloseBtn:GetComponent('Image');
    self.img_title_icon = self.title_icon:GetComponent('Image')
    self.more_btn = GetButton(self.more_btn);
    SetGameObjectActive(self.more_btn.gameObject , false);
    local height = GetSizeDeltaY(self.money_con)
    local y = ScreenHeight * 0.5 - height * 0.5
    SetLocalPositionY(self.money_con, y)

    if self.is_need_settitle_visible then
        self:SetTitleVisible(self.title_visible)
    end

    self.transform.name = "PanelBackgroundTwo(Clone)"

    self:AddEvent()
end

function PanelBackgroundTwo:AddEvent()
    local function call_back(target, x, y)
        if self.close_call_back then
            self.close_call_back()
        end
    end
    AddButtonEvent(self.windowCloseBtn.gameObject, call_back)
end

--边框
function PanelBackgroundTwo:SetBackgroundImage(abName, assetName)
    lua_resMgr:SetImageTexture(self, self.img_bg_component, abName, assetName, true)
end

--背景底
function PanelBackgroundTwo:SetPanelBgImage(abName, assetName)

    lua_resMgr:SetImageTexture(self, self.img_panel_component, abName, assetName, true)
end

--顶部条形背景
function PanelBackgroundTwo:SetTitleBgImage(abName, assetName)
  --  lua_resMgr:SetImageTexture(self, self.img_title_bg_component, abName, assetName, true)
end

--标题背景
function PanelBackgroundTwo:SetTopCenterBg(abName, assetName)
    lua_resMgr:SetImageTexture(self, self.img_title_center_bg_component, abName, assetName, false)
end

--设置标题位置
function PanelBackgroundTwo:SetTitleImgPos(x, y)
    SetAnchoredPosition(self.img_title_trans, x, y)
end

--设置顶部灯光装饰
function PanelBackgroundTwo:ShowLightDecorate()
   -- SetVisible(self.ui_decorate_5_1, true)
    SetVisible(self.ui_decorate_4_1, false)
end

--设置按钮图片
function PanelBackgroundTwo:SetBtnCloseImg(abName,assetName)
    lua_resMgr:SetImageTexture(self, self.img_btn_close_component, abName, assetName, true)
end

--
-- function PanelBackgroundTwo:SetCameraBlur(panel_cls)
-- 	self.panel_cls = panel_cls or self.panel_cls
-- 	if self.is_loaded then
-- 		lua_panelMgr:CameraBlur(self.panel_cls,self.bg)
-- 	else
-- 		self.need_set_camerablur = true
-- 	end
-- end

function PanelBackgroundTwo:SetCallBack(close_call_back, switch_call_back)
    self.close_call_back = close_call_back
    self.switch_call_back = switch_call_back
end

function PanelBackgroundTwo:IsShowSidebar(flag)
    flag = toBool(flag)
    self.show_sidebar = flag
end

function PanelBackgroundTwo:SetData(data)
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
    end
    if #data > 5 then
        SetGameObjectActive(self.more_btn.gameObject , true);
    else
        SetGameObjectActive(self.more_btn.gameObject , false);
    end
    -- callback(self.default_table_index)

    local height = #data * offy + 60
end

function PanelBackgroundTwo:SetMoney(list)
    if table.isempty(list) then
        return
    end

    if self.money_list then
        for k,v in pairs(self.money_list) do
            v:destroy()
        end
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

function PanelBackgroundTwo:SetTabIndex(index, show_toggle)
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
        if not show_toggle then
            show_toggle = data and data.show_toggle
        end
        self.switch_call_back(index, show_toggle)
    end
end

function PanelBackgroundTwo:SetTileText(text)
    -- if text then
    -- 	self.text_title_component.text = text
    -- end
end

function PanelBackgroundTwo:SetTileTextImage(abName, assetName, fix_size)
    fix_size = fix_size == nil and false or fix_size
    fix_size = toBool(fix_size);
    lua_resMgr:SetImageTexture(self, self.img_title_component, abName, assetName, fix_size)
end

function PanelBackgroundTwo:SetTitleIcon(abName,assetName,fix_size)
    fix_size = fix_size == nil and false or fix_size
    fix_size = toBool(fix_size);
    lua_resMgr:SetImageTexture(self, self.img_title_icon, abName, assetName, fix_size,nil,false)
end


function PanelBackgroundTwo:SetTitleVisible(flag)
    self.title_visible = flag
    if self.is_loaded then
        SetVisible(self.img_title, flag)
        self.is_need_settitle_visible = false
    else
        self.is_need_settitle_visible = true
    end
end

function PanelBackgroundTwo:GetItem(id)
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

function PanelBackgroundTwo:SetRedDotParam(id,param)
    local item = self:GetItem(id)
    if item then
        item:SetRedDotParam(param)
    end
end

function PanelBackgroundTwo:SetRedDotType(id,red_dot_type)
    local item = self:GetItem(id)
    if item then
        item:SetRedDotType(red_dot_type)
    end
end

function PanelBackgroundTwo:SetPanelSize(width, height)
    print2(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    print2("PanelBackgroundTwo 不支持SetPanelSize");
    print2("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
end

function PanelBackgroundTwo:SetMoneyConLast(parent)
    if self.money_con then
        SetParent(self.money_con.transform , parent);
        SetAsLastSibling(self.money_con);
    end
end