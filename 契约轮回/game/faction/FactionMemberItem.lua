--
-- @Author: chk
-- @Date:   2018-12-24 14:36:02
--
FactionMemberItem = FactionMemberItem or class("FactionMemberItem", BaseItem)
local FactionMemberItem = FactionMemberItem

function FactionMemberItem:ctor(parent_node, layer)
    self.abName = "faction"
    self.assetName = "FactionMemberItem"
    self.layer = layer
    self.events = {}
    self.model = FactionModel:GetInstance()
    FactionMemberItem.super.Load(self)
end

function FactionMemberItem:dctor()
    self.model:RemoveTabListener(self.events)
    if self.lv_item then
        self.lv_item:destroy()
        self.lv_item = nil
    end
end

function FactionMemberItem:LoadCallBack()
    self.nodes = {
        "bg_1",
        "bg_0",
        "name",
        "career",
        "lv_con",
        "totalContribute",
        "power",
        "offTime",
        "touch",
    }
    self:GetChildren(self.nodes)
    self:AddEvent()

    self:UpdateItem()
end

function FactionMemberItem:AddEvent()

    local function call_back()
        local roleData = RoleInfoModel.GetInstance():GetMainRoleData()
        if roleData.id == self.data.base.id then
            Notify.ShowText("You selected yourself")
            return
        end
        local panel = lua_panelMgr:GetPanelOrCreate(RoleMenuPanel, self.totalContribute)
        panel:Open(self.data.base)
    end
    AddClickEvent(self.touch.gameObject, call_back)
    --AddClickEvent(self.bg_1.gameObject,call_back)

    local function call_back()
        local roleData = RoleInfoModel.Instance:GetMainRoleData()
        if self.data.base.id ~= roleData.id and self.model:GetIsPresidentSelf() then
            local message = string.format(ConfigLanguage.Faction.DemisTo, self.data.base.name)

            local function call_back()
                FactionController.Instance:RequestDemis(self.data.base.id)
            end

            Dialog.ShowTwo(ConfigLanguage.Faction.Demis, message, ConfigLanguage.Mix.Confirm, call_back)
        end
    end
    --AddClickEvent(self.touch.gameObject,call_back)

    self.events[#self.events + 1] = self.model:AddListener(FactionEvent.Demise, handler(self, self.Demise))
end

function FactionMemberItem:SetData(data, index)
    self.index = index
    self.data = data
end

function FactionMemberItem:UpdateItem()
    if self.index % 2 == 0 then
        SetVisible(self.bg_0.gameObject, true)
        SetVisible(self.bg_1.gameObject, false)
    else
        SetVisible(self.bg_0.gameObject, false)
        SetVisible(self.bg_1.gameObject, true)
    end

    local name_color = "604C3D"
    local name = "<color=#D42621>" .. self.data.base.name .. "</color>"
    local career = "<color=#604C3D>" .. enumName.GUILD_POST[self.data.post] .. "</color>"
    local lv = self.data.base.level
    local contribute = "<color=#604C3D>" .. self.data.ctrb .. "</color>"
    local power = "<color=#604C3D>" .. self.data.base.power .. "</color>"
    local offTime = ""
    if self.data.online then
        offTime = "<color=#604C3D>" .. ConfigLanguage.Mix.Online .. "</color>"
    elseif self.data.logout == 0 then
        name = "<color=#878787>" .. self.data.base.name .. "</color>"
        career = "<color=#878787>" .. enumName.GUILD_POST[self.data.post] .. "</color>"
        name_color = "878787"
        contribute = "<color=#878787>" .. self.data.ctrb .. "</color>"
        power = "<color=#878787>" .. self.data.base.power .. "</color>"
        offTime = "<color=#878787>" .. ConfigLanguage.Mix.Just .. "</color>"
    else
        name = "<color=#878787>" .. self.data.base.name .. "</color>"
        career = "<color=#878787>" .. enumName.GUILD_POST[self.data.post] .. "</color>"
        name_color = "878787"
        contribute = "<color=#878787>" .. self.data.ctrb .. "</color>"
        power = "<color=#878787>" .. self.data.base.power .. "</color>"
        offTime = "<color=#878787>" .. TimeManager.Instance:GetDifTime(self.data.logout, os.time()) .. "</color>"
    end

    if not self.lv_item then
        self.lv_item = LevelShowItem(self.lv_con, "UI")
    end
    self.lv_item:SetData(20, lv, name_color)

    self.name:GetComponent('Text').text = name
    self.career:GetComponent('Text').text = career
    self.totalContribute:GetComponent('Text').text = contribute
    self.power:GetComponent('Text').text = power
    self.offTime:GetComponent('Text').text = offTime
end

function FactionMemberItem:Demise(data)
    local from = data.from
    local to = data.to

    if self.data.base.id == from then
        local career = "<color=#604C3D>" .. "Member" .. "</color>"
        if self.data.online then

        elseif self.data.logout == 0 then
            career = "<color=#878787>" .. "Member" .. "</color>"
        else
            career = "<color=#878787>" .. "Member" .. "</color>"
        end
        self.career:GetComponent('Text').text = career
    end
    if self.data.base.id == to then
        local career = "<color=#604C3D>" .. "Guild Leader" .. "</color>"
        if self.data.online then

        elseif self.data.logout == 0 then
            career = "<color=#878787>" .. "Guild Leader" .. "</color>"
        else
            career = "<color=#878787>" .. "Guild Leader" .. "</color>"
        end
        self.career:GetComponent('Text').text = career

    end
end