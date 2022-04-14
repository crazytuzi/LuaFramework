OtherRoleInfoPanel = OtherRoleInfoPanel or class("OtherRoleInfoPanel", WindowPanel)
local OtherRoleInfoPanel = OtherRoleInfoPanel

function OtherRoleInfoPanel:ctor()
    self.abName = "roleinfo"
    self.assetName = "OtherRoleInfoPanel"
    self.layer = "UI"

    -- self.change_scene_close = true 				--切换场景关闭
    -- self.default_table_index = 1					--默认选择的标签
    -- self.is_show_money = {Constant.GoldType.Coin,Constant.GoldType.BGold,Constant.GoldType.Gold}	--是否显示钱，不显示为false,默认显示金币、钻石、宝石，可配置

    self.panel_type = 2                                --窗体样式  1 1280*720  2 850*545
    self.show_sidebar = false        --是否显示侧边栏
    self.table_index = nil
    self.model = RoleInfoModel:GetInstance()
    self.global_events = {}
    self.slots2equip = {}
    self.equip_icons = {}
end

function OtherRoleInfoPanel:dctor()
end

function OtherRoleInfoPanel:Open(role_id)
    self.role_id = role_id
    OtherRoleInfoPanel.super.Open(self)
end

function OtherRoleInfoPanel:LoadCallBack()
    self.nodes = {
        "bg",
        "left_info/rolemodel", "left_info/name", "left_info/vip", "left_info/EquipContainer/Right/equip_1011",
        "left_info/EquipContainer/Right/equip_1001", "left_info/EquipContainer/Right/equip_1002",
        "left_info/EquipContainer/Right/equip_1003", "left_info/EquipContainer/Right/equip_1004",
        "left_info/EquipContainer/Right/equip_1005", "left_info/EquipContainer/Left/equip_1013",
        "left_info/EquipContainer/Left/equip_1006", "left_info/EquipContainer/Left/equip_1007",
        "left_info/EquipContainer/Left/equip_1008", "left_info/EquipContainer/Left/equip_1009",
        "left_info/EquipContainer/Left/equip_1010", "right_info/icon_bg/icon", "right_info/power_bg/power",
        "right_info/info/info_bg/info_name", "right_info/info1/info_bg/info_guild", "right_info/info2/info_bg/info_lover",
        "right_info/info3/info_bg/info_level", "right_info/info4/info_bg/info_career",
        "right_info/friendbtn", "right_info/chatbtn", "right_info/flowerbtn", "right_info/marriagebtn",
        "right_info/info5/info_bg/info_server",
        "left_info/EquipContainer/equip_1012",
    }
    self:GetChildren(self.nodes)

    self.name = GetText(self.name)
    self.vip = GetText(self.vip)
    self.power = GetText(self.power)
    self.info_name = GetText(self.info_name)
    self.info_guild = GetText(self.info_guild)
    self.info_lover = GetText(self.info_lover)
    self.info_career = GetText(self.info_career)
    self.info_server = GetText(self.info_server)
    --self.icon = GetImage(self.icon)
    self.bg = GetImage(self.bg)
    self:AddEvent()
    self:SetTileTextImage("roleinfo_image", "other_title_img")
    local res = "bag_big_bg"
    lua_resMgr:SetImageTexture(self, self.bg, "iconasset/icon_big_bg_" .. res, res)
    self:SetSlot2Equip()
    RoleInfoController:GetInstance():RequestRoleQuery(self.role_id)
    SetVisible(self.marriagebtn, false)
end

--设置部位对应装备
function OtherRoleInfoPanel:SetSlot2Equip()
    self.slots2equip[1001] = self.equip_1001
    self.slots2equip[1002] = self.equip_1002
    self.slots2equip[1003] = self.equip_1003
    self.slots2equip[1004] = self.equip_1004
    self.slots2equip[1005] = self.equip_1005
    self.slots2equip[1006] = self.equip_1006
    self.slots2equip[1007] = self.equip_1007
    self.slots2equip[1008] = self.equip_1008
    self.slots2equip[1009] = self.equip_1009
    self.slots2equip[1010] = self.equip_1010
    self.slots2equip[1011] = self.equip_1011
    self.slots2equip[1012] = self.equip_1012
    self.slots2equip[1013] = self.equip_1013
end

function OtherRoleInfoPanel:AddEvent()
    local function call_back(data)
        self.data = data
        self:UpdateView()
    end
    self.global_events[#self.global_events + 1] = AddModelEvent(RoleInfoEvent.QUERY_OTHER_ROLE, call_back)

    local function call_back(target, x, y)
        FriendController:GetInstance():RequestAddFriend(self.data.role.id)
    end
    AddButtonEvent(self.friendbtn.gameObject, call_back)

    local function call_back(target, x, y)
        FriendController:GetInstance():AddContact(self.data.role.id)
    end
    AddButtonEvent(self.chatbtn.gameObject, call_back)

    local function call_back(target, x, y)
        GlobalEvent:Brocast(FriendEvent.OpenSendGiftPanel, self.data.role)
    end
    AddButtonEvent(self.flowerbtn.gameObject, call_back)

    local function call_back(target, x, y)

    end
    AddButtonEvent(self.marriagebtn.gameObject, call_back)
end

function OtherRoleInfoPanel:OpenCallBack()
    self:UpdateView()
end

function OtherRoleInfoPanel:UpdateView()
    if self.data then
        local role_base = self.data.role
        local param = {}
        param['is_can_click'] = false
        param["is_squared"] = true
        param["is_hide_frame"] = true
        param["size"] = 122
        param["role_data"] = role_base
        self.role_icon = RoleIcon(self.icon)
        self.role_icon:SetData(param)
        self.name.text = role_base.name
        self.info_name.text = role_base.name
        self.vip.text = string.format(ConfigLanguage.Common.Vip, role_base.viplv)
        self.power.text = role_base.power
        self.info_guild.text = (role_base.gname ~= "" and role_base.gname or "No guild yet")
        self.info_lover.text = (role_base.mname ~= "" and role_base.mname or "No spouse" )
        self.info_server.text = string.format("s%s", role_base.zoneid)
        --self.info_level.text = role_base.level
        if not self.lv_item then
            self.lv_item = LevelShowItem(self.info_level, 'UI')
        end
        self.lv_item:SetData(20, role_base.level, "926E50")
        local wake_key = string.format("%s@%s", role_base.career, role_base.wake)
        self.info_career.text = Config.db_wake[wake_key].name
        self.role_model = UIRoleCamera(self.rolemodel, nil, role_base)
        if FriendModel:GetInstance():IsFriend(role_base.id) then
            SetVisible(self.friendbtn, false)
        else
            SetVisible(self.friendbtn, true)
        end
        local scene_id = SceneManager:GetInstance():GetSceneId()
        if SceneManager:GetInstance():IsCrossScene(scene_id) then
            SetVisible(self.friendbtn, false)
            SetVisible(self.chatbtn, false)
            SetVisible(self.flowerbtn, false)
            SetVisible(self.marriagebtn, false)
        end
        self:UpdateEquips()
    end
end

--显示装备
function OtherRoleInfoPanel:UpdateEquips()
    local equips = self.data.equips
    for i = 1, #equips do
        local pitem = equips[i]
        local item_id = pitem.id
        local ItemCfg = Config.db_equip[item_id]
        local slot = ItemCfg.slot
        local puticon = self.equip_icons[slot] or PutOnedIconSettor(GetChild(self.slots2equip[slot], "icon"), nil, "system", "PutOnedIcon")
        self.equip_icons[slot] = puticon
        local param = {}

        param["cfg"] = ItemCfg
        param["p_item"] = pitem
        param["model"] = self.model
        param["color_effect"] = 7
        param["can_click"] = true
        if slot == enum.ITEM_STYPE.ITEM_STYPE_LOCK then
            param["is_hide_quatily"] = true
            param["size"] = {x=60, y=60}
        end
        puticon:SetSlot(slot)
        puticon:SetIcon(param)
    end
end

function OtherRoleInfoPanel:CloseCallBack()
    if self.lv_item then
        self.lv_item:destroy()
        self.lv_item = nil
    end
    self.settle_items = {}
    if self.role_model then
        self.role_model:destroy()
    end
    for i = 1, #self.global_events do
        GlobalEvent:RemoveListener(self.global_events[i])
    end
    for _, v in pairs(self.equip_icons) do
        v:destroy()
    end
    if self.role_icon then
        self.role_icon:destroy()
    end
    self.slots2equip = nil
end
function OtherRoleInfoPanel:SwitchCallBack(index)
    if self.table_index == index then
        return
    end
    if self.child_node then
        self.child_node:SetVisible(false)
    end
    self.table_index = index
end