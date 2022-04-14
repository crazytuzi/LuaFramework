-- @Author: lwj
-- @Date:   2019-05-13 14:30:47
-- @Last Modified time: 2019-05-13 14:30:50

FPacketItem = FPacketItem or class("FPacketItem", BaseCloneItem)
local FPacketItem = FPacketItem

function FPacketItem:ctor(parent_node, layer)
    FPacketItem.super.Load(self)
end

function FPacketItem:dctor()
end

function FPacketItem:LoadCallBack()
    self.model = FPacketModel.GetInstance()
    self.nodes = {
        "open/open_des", "unopen/unopen_bg", "open/open_name", "open/open_bg", "unopen", "open/btn_look", "unopen/unopen_name", "open/open_state_img", "unopen/state_txt", "open", "unopen/state_img", "unopen/unopen_des",
    }
    self:GetChildren(self.nodes)
    self.state_txt = GetText(self.state_txt)
    self.state_img = GetImage(self.state_img)
    self.uno_name = GetText(self.unopen_name)
    self.uno_des = GetText(self.unopen_des)

    self.open_state = GetText(self.open_state_img)
    self.open_name = GetText(self.open_name)
    self.open_des = GetText(self.open_des)

    self.btn_mode = 1           --1:自己未发  2：别人未发    3：已领    4：未领    5：已领完

    self:AddEvent()
end

function FPacketItem:AddEvent()
    local function callback()
        local mode = self.btn_mode
        if mode == 1 then
            lua_panelMgr:GetPanelOrCreate(FPSettlePanel):Open(true, self.cf, self.data)
        elseif mode == 4 then
            self.model.is_update_panel_when_reci_data = true
            self.model:Brocast(FPacketEvent.RushTheFP, self.data.uid)
        else
            return
        end
    end
    AddClickEvent(self.unopen_bg.gameObject, callback)

    local function callback()
        lua_panelMgr:GetPanelOrCreate(FPRecoPanel):Open(self.data, true)
    end
    AddButtonEvent(self.btn_look.gameObject, callback)
end

function FPacketItem:SetData(data)
    self.data = data
    self.cf = Config.db_guild_redenvelope[self.data.id]
    self:UpdateView()
end

function FPacketItem:UpdateView()
    local name_text = self.uno_name
    local des_text = self.uno_des
    if self.data.state == enum.RED_ENVELOPE_STATE.RED_ENVELOPE_STATE_NEW then
        --未发
        local my_id = RoleInfoModel.GetInstance():GetMainRoleId()
        if my_id == self.data.role.id then
            self:SetSelfUnSend()
            self.btn_mode = 1
        else
            self:SetOtherUnSend()
            self.btn_mode = 2
        end
    elseif self.data.state == enum.RED_ENVELOPE_STATE.RED_ENVELOPE_STATE_SEND then
        --已发
        if self.data.is_got then
            self:SetAlGet()
            name_text = self.open_name
            des_text = self.open_des
            self.btn_mode = 3
        else
            --未领
            self:SetUnGet()
            self.btn_mode = 4
        end
    elseif self.data.state == enum.RED_ENVELOPE_STATE.RED_ENVELOPE_STATE_DONE then
        --已领完
        self:SetNoRest()
        name_text = self.open_name
        des_text = self.open_des
        self.btn = 5
    end
    name_text.text = self.data.role.name
    if self.data.desc == "" then
        des_text.text = self.cf.desc
    else
        des_text.text = self.data.desc
    end
end

function FPacketItem:SetUnOpenStyle()
    SetVisible(self.open, false)
    SetVisible(self.unopen, true)
end
function FPacketItem:SetOpenStyle()
    SetVisible(self.open, true)
    SetVisible(self.unopen, false)
end

function FPacketItem:SetOtherUnSend()
    self:SetUnOpenStyle()
    SetVisible(self.state_txt, true)
    SetVisible(self.state_img, false)
end
function FPacketItem:SetSelfUnSend()
    self:SetUnOpenStyle()
    SetVisible(self.state_txt, false)
    SetVisible(self.state_img, true)
    lua_resMgr:SetImageTexture(self, self.state_img, "factionPacket_image", "state_1", false, nil, false)
end

function FPacketItem:SetAlGet()
    self:SetOpenStyle()
    self.open_state.text = ConfigLanguage.FPacket.AlreadyGot
end

function FPacketItem:SetUnGet()
    self:SetUnOpenStyle()
    SetVisible(self.state_txt, false)
    SetVisible(self.state_img, true)
    lua_resMgr:SetImageTexture(self, self.state_img, "factionPacket_image", "state_2", false, nil, false)
end

function FPacketItem:SetNoRest()
    self:SetOpenStyle()
    self.open_state.text = ConfigLanguage.FPacket.NoRest
end
