--
-- @Author: LaoY
-- @Date:   2018-12-03 20:10:42
--
RoleTitlePanel = RoleTitlePanel or class("RoleTitlePanel", WindowPanel)
local RoleTitlePanel = RoleTitlePanel

function RoleTitlePanel:ctor()
    self.abName = "roleinfo"
    self.assetName = "RoleTitlePanel"
    self.layer = "UI"

    -- self.change_scene_close = true 				--切换场景关闭
    -- self.default_table_index = 1					--默认选择的标签
    -- self.is_show_money = {Constant.GoldType.Coin,Constant.GoldType.BGold,Constant.GoldType.Gold}	--是否显示钱，不显示为false,默认显示金币、钻石、宝石，可配置

    self.main_role_data = RoleInfoModel:GetInstance():GetMainRoleData()

    self.panel_type = 3                                --窗体样式  1 1280*720  2 850*545
    self.show_sidebar = false        --是否显示侧边栏
    self.model = RoleInfoModel.GetInstance()
    self.global_event_list = {}
end

function RoleTitlePanel:dctor()
    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
    if self.goods_tip_panel then
        self.goods_tip_panel:destroy()
        self.goods_tip_panel = nil
    end
    if self.role_event_list then
        self.main_role_data:RemoveTabListener(self.role_event_list)
        self.role_event_list = {}
    end
    if self.global_event_list then
        GlobalEvent:RemoveTabListener(self.global_event_list)
        self.global_event_list = {}
    end
end

function RoleTitlePanel:Open()
    RoleTitlePanel.super.Open(self)
end

function RoleTitlePanel:LoadCallBack()
    self.nodes = {
        "group_1/text_power_1", "group_2/text_des_2", "group_1/text_des_1", "group_2/text_power_2",
        "group_1/text_1", "group_1", "group_2", "group_2/text_2", "condition", "condition/text_condition_2", "condition/text_condition_1",
        "btn_go", "group_2/text_title_2", "group_1/text_title_1", "img_text_max_title_1", "condition/img_icon_1_1",
        "btn_go/red_con",
    }
    self:GetChildren(self.nodes)
    SetVisible(self.img_text_max_title_1, false)
    self:SetTileTextImage(self.abName .. "_image", "RoleTitle_Title_img")
    self:SetPanelSize(650, 480)

    self.text_title_1_component = self.text_title_1:GetComponent('Text')
    self.text_power_1_component = self.text_power_1:GetComponent('Text')
    self.text_des_1_component = self.text_des_1:GetComponent('Text')

    self.text_title_2_component = self.text_title_2:GetComponent('Text')
    self.text_power_2_component = self.text_power_2:GetComponent('Text')
    self.text_des_2_component = self.text_des_2:GetComponent('Text')

    self.text_condition_1_component = self.text_condition_1:GetComponent('Text')
    self.text_condition_2_component = self.text_condition_2:GetComponent('LinkImageText')
    self.text_condition_2_x = GetLocalPositionX(self.text_condition_2)

    self.img_icon = self.img_icon_1_1:GetComponent('Image')

    self.text_title_1_outline = self.text_title_1:GetComponent('Outline')
    self.text_title_2_outline = self.text_title_2:GetComponent('Outline')

    self:AddEvent()
end

function RoleTitlePanel:AddEvent()
    local function call_back(target, x, y)
        -- Notify.ShowText("晋升")
        -- self.title_id = self.title_id + 1
        -- self:UpdateView()
        if self.need_power > self.cur_power and self.need_goods_count > self.cur_goods_count then
            Notify.ShowText("Not enough CP and items")
            return
        end
        if self.need_power > self.cur_power then
            Notify.ShowText("Insufficient CP")
            return
        end

        if self.need_goods_count > self.cur_goods_count then
            Notify.ShowText("Insufficient items")
            return
        end
        RoleInfoController:GetInstance():RequestJobTitle()
    end
    AddClickEvent(self.btn_go.gameObject, call_back)

    local function call_back(target, x, y)
        if self.goods_tip_panel then
            self.goods_tip_panel:destroy()
            self.goods_tip_panel = nil
        end
        self.goods_tip_panel = GoodsDetailView(self.transform)
        self.goods_tip_panel:SetVisible(true)
        self.goods_tip_panel:UpdateInfoByItemId(self.goods_id)
    end
    self.text_condition_2_component:AddClickListener(call_back);

    local function call_back()
        self:UpdateView()
    end
    self.role_event_list = self.role_event_list or {}
    self.role_event_list[#self.role_event_list + 1] = self.main_role_data:BindData("figure.jobtitle", call_back)
    self.role_event_list[#self.role_event_list + 1] = self.main_role_data:BindData("power", call_back)

    local function call_back()
        self:UpdateView()
    end
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(BagEvent.UpdateGoods, call_back)

    self.upadate_red_dot_event_id = self.model:AddListener(RoleInfoEvent.UpdateJobTitleRedDot, handler(self, self.UpdateBtnRedDot))
end

function RoleTitlePanel:OpenCallBack()
    self:UpdateView()
    self:UpdateBtnRedDot()
end

function RoleTitlePanel:UpdateBtnRedDot()
    self:SetRedDot(RoleInfoModel.GetInstance().is_show_jobtitle_rd)
end

function RoleTitlePanel:UpdateView()
    self.title_id = self.main_role_data.figure.jobtitle and self.main_role_data.figure.jobtitle.model
    self.title_id = self.title_id or 0
    local cur_config = Config.db_jobtitle[self.title_id]
    if not cur_config then
        return
    end
    self.cur_power = 0
    self.need_power = 0
    self.cur_goods_count = 0
    self.need_goods_count = 0

    self.text_title_1_component.text = cur_config.name
    local attr_str_1, cur_attr_power = self:GetAttrDesAndPower(cur_config.attr)
    self.text_des_1_component.text = attr_str_1
    self.text_power_1_component.text = cur_attr_power
    local r, g, b, a = HtmlColorStringToColor(cur_config.color)
    SetOutLineColor(self.text_title_1_outline, r, g, b, a)

    local next_config = cur_config.next_id ~= 0 and Config.db_jobtitle[cur_config.next_id]
    if not next_config then
        SetVisible(self.group_2, false)
        SetVisible(self.condition, false)
        SetLocalPositionX(self.group_1, 24)
        local button = self.btn_go:GetComponent('Button')
        button.interactable = false
        RemoveClickEvent(self.btn_go.gameObject)

        SetVisible(self.img_text_max_title_1, true)
        return
    end
    self.text_title_2_component.text = next_config.name

    local attr_str_2, next_attr_power = self:GetAttrDesAndPower(next_config.attr, "00be00")
    self.text_des_2_component.text = attr_str_2
    self.text_power_2_component.text = next_attr_power .. "u"
    local r, g, b, a = HtmlColorStringToColor(next_config.color)
    SetOutLineColor(self.text_title_2_outline, r, g, b, a)

    local cur_power = self.main_role_data.power or 0
    local con_power_color = cur_power >= cur_config.need_power and "00be00" or "f30404"
    local con_power_str = string.format("<color=#%s>%s</color>/%s", con_power_color, GetShowNumber(cur_power), GetShowNumber(cur_config.need_power))
    self.text_condition_1_component.text = con_power_str
    self.cur_power = cur_power
    self.need_power = cur_config.need_power

    local goods_info = String2Table(cur_config.cost)
    local goods_id = goods_info[1]
    self.goods_id = goods_id

    local config = Config.db_item[goods_id]
    if config then
        local param = {}
        local operate_param = {}
        param["cfg"] = Config.db_item[goods_id]
        param["model"] = RoleInfoModel.GetInstance()
        param["can_click"] = true
        param["operate_param"] = operate_param
        param["size"] = { x = 70, y = 70 }

        if self.item == nil then
            self.item = GoodsIconSettorTwo(self.img_icon_1_1)
        end

        self.item:SetIcon(param)
    end

    local cur_goods_count = BagModel:GetInstance():GetItemNumByItemID(goods_id)
    local need_goods_count = goods_info[2]
    local con_goods_color = cur_goods_count >= need_goods_count and "00be00" or "f30404"
    local con_goods_str = string.format("<color=#%s>%s</color>/%s", con_goods_color, cur_goods_count, need_goods_count)
   -- if cur_goods_count < need_goods_count then
   --     con_goods_str = string.format("<color=#%s>%s</color>/%s  <color=#%s><a href=%s>立即前往</a></color>", con_goods_color, cur_goods_count, need_goods_count, ColorUtil.GetColor(ColorUtil.ColorType.LinkGreen), goods_id)
   -- end
    self.text_condition_2_component.text = con_goods_str
    self.cur_goods_count = cur_goods_count
    self.need_goods_count = need_goods_count

    -- SetVisible(,cur_goods_count < need_goods_count)
end

function RoleTitlePanel:GetAttrDesAndPower(attr, html_color)
    attr = String2Table(attr)
    local str_list = {}
    local len = #attr
    for i = 1, len do
        local info = attr[i]
        if html_color then

            str_list[#str_list + 1] = string.format("%s：<color=#%s>+%s</color>", enumName.ATTR[info[1]], html_color, info[2])
        else
            str_list[#str_list + 1] = enumName.ATTR[info[1]] .. "：+" .. info[2]
        end
    end
    return table.concat(str_list, "\n"), GetPowerByConfigList(attr)
end

function RoleTitlePanel:CloseCallBack()
    if self.item then
        self.item:destroy()
        self.item = nil
    end
    if self.upadate_red_dot_event_id then
        self.model:RemoveListener(self.upadate_red_dot_event_id)
        self.upadate_red_dot_event_id = nil
    end
end
function RoleTitlePanel:SwitchCallBack(index)

end

function RoleTitlePanel:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetPosition(0, 0)
    self.red_dot:SetRedDotParam(isShow)
end