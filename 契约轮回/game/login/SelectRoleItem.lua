--
-- Author: LaoY
-- Date: 2018-07-12 15:48:38
--
SelectRoleItem = SelectRoleItem or class("SelectRoleItem", Node)
local SelectRoleItem = SelectRoleItem

function SelectRoleItem:ctor(obj, parent, tab)
    if not obj then
        return
    end
    self.transform = obj.transform
    self.data = tab

    self.transform:SetParent(parent)
    SetLocalScale(self.transform, 1, 1, 1)
    SetLocalRotation(self.transform, 0, 0, 0)

    self.gameObject = self.transform.gameObject;
    self.transform_find = self.transform.Find;

    self.abName = "login"
    self.img_abName = "login_image"
    self.model = LoginModel:GetInstance()

    self:InitUI();
end

function SelectRoleItem:dctor()
    if self.role_icon then
        self.role_icon:destroy()
    end
end

function SelectRoleItem:InitUI()
    self.is_loaded = true

    self.nodes = {
        "img_Bg", "img_select_bg", "Text",
        "img_head", "add_img",
        "LvInfo", "LvInfo/Icon", "LvInfo/LvTitle", "LvInfo/Level",
        "Title",
    }
    self:GetChildren(self.nodes)
    self.bgImage = GetImage(self.img_Bg)
    self.selectImage = GetImage(self.img_select_bg)
    self.add_img = GetImage(self.add_img)
    self.info_text = self.Text:GetComponent("Text")

    self.lvInfoTitle_text = self.LvTitle:GetComponent("Text")
    self.lvInfoIcon_image = self.Icon:GetComponent("Image")
    self.lvInfoLevel_text = self.Level:GetComponent("Text")
    local icon_rect = GetRectTransform(self.Icon)
    self.icon_width = icon_rect.sizeDelta.x
    self.img_head_component = self.img_head:GetComponent('Image')

    self:AddEvent()

    if self.is_need_SetSelectState then
        self:SetSelectState(self.select_state)
    end

    if self.is_need_UpdateInfo then
        self:UpdateInfo()
    end
end

function SelectRoleItem:AddEvent()
    local function call_back()
        --if self.select_state then
        --	return
        --end
        if not self.data then
            GlobalEvent:Brocast(LoginEvent.OpenCreateRolePanel)
            return
        end
        if self.call_back then
            self.call_back(self.index)
        end
    end
    AddClickEvent(self.img_head.gameObject, call_back)
    AddClickEvent(self.img_Bg.gameObject, call_back)
    AddClickEvent(self.add_img.gameObject, call_back)
end

function SelectRoleItem:SetCallBack(call_back)
    self.call_back = call_back
end

function SelectRoleItem:SetSelectState(flag)
    if not self.data then
        return
    end
    self.select_state = flag
    if self.is_loaded then
        self.selectImage.enabled = flag
        self.bgImage.enabled = not flag
    else
        self.is_need_SetSelectState = true
    end
end

function SelectRoleItem:SetData(index, data)
    self.index = index
    self.data = data
    self:UpdateInfo()
end

function SelectRoleItem:UpdateInfo()
    if self.is_loaded then
        if self.data then
            self:NormalStyle()
        else
            self:EmptyStyle()
        end

        if self.is_need_SetSelectState then
            self:SetSelectState(self.select_state)
        end
    else
        self.is_need_UpdateInfo = true
    end
end

function SelectRoleItem:NormalStyle()
    self.bgImage.enabled = true
    self.img_head_component.enabled = false
    self.selectImage.enabled = false
    SetVisible(self.LvInfo, true)

    local config = LoginConst.CareerConfig[self.data.gender]
    --local str = string.format("%s%s等级%s", self.data.name, "\n", self.data.level)
    self.info_text.text = self.data.name
    self:RefreshLevelInfo(self.data.level)

    local function call_back()
        if self.call_back then
            self.call_back(self.index)
        end
    end
    local param = {}
    param['is_can_click'] = true
    param['click_fun'] = call_back
    param["is_squared"] = false
    param["is_hide_frame"] = true
    param["size"] = 75
    param["role_data"] = self.data
    self.role_icon = RoleIcon(self.img_head)
    self.role_icon:SetData(param)
end

function SelectRoleItem:RefreshLevelInfo(l)
    local normalLv, is_under, upLv = GetLevelShow(l)
    self.lvInfoLevel_text.text = is_under and normalLv or upLv
    --local w1 = self.lvInfoLevel_text.preferredWidth
    --SetSizeDeltaX(self.Level, w1)
    --if is_under then
    --    self.lvInfoIcon_image.enabled = false
    --    SetAnchoredPosition(self.LvTitle, -w1 - 3, 0)
    --else
    --    self.lvInfoIcon_image.enabled = true
    --    SetAnchoredPosition(self.Icon, -w1 - 3, 0)
    --    SetAnchoredPosition(self.LvTitle, -w1 - self.Icon.sizeDelta.x - 6, 0)
    --end

    SetVisible(self.Icon, not is_under)
    local up_lv_x = self.Icon.transform.localPosition.x + self.icon_width
    --巅峰等级时，等级数字的x
    local x = is_under and self.Icon.transform.localPosition.x or up_lv_x
    SetLocalPositionX(self.Level, x)
end

function SelectRoleItem:EmptyStyle()
    self.bgImage.enabled = false
    self.selectImage.enabled = false
    self.add_img.enabled = true
    self.img_head_component.enabled = false
    self.info_text.text = ""
    SetVisible(self.LvInfo, false)
end