--
-- @Author: lwj
-- @Date:   2018-10-16 16:02:17
--
SkillPassivePanel = SkillPassivePanel or class("SkillPassivePanel", BaseItem)
local SkillPassivePanel = SkillPassivePanel

function SkillPassivePanel:ctor(parent_node, layer)
    self.abName = "skill"
    self.assetName = "SkillPassivePanel"
    self.layer = layer

    self.model = SkillUIModel.GetInstance()
    SkillPassivePanel.super.Load(self)
end

function SkillPassivePanel:dctor()
    SkillPassivePanel.super.dctor()
    if self.click_event_id then
        self.model:RemoveListener(self.click_event_id)
        self.click_event_id = nil
    end

    if self.role_update_list then
        for k, event_id in pairs(self.role_update_list) do
            self.role_data:RemoveListener(event_id)
        end
        self.role_update_list = nil
    end

    if self.passSkillList then
        for i, v in pairs(self.passSkillList) do
            if v then
                v:destroy()
            end
        end
        self.passSkillList = {}
    end


end

function SkillPassivePanel:LoadCallBack()
    self.nodes = {
        "SkillPassivePanel/SkillScroll/Viewport/Content",
        "SkillPassiveDes/iconFrame/icon",
        "SkillPassiveDes/skillName",
        "SkillPassiveDes/des", "SkillPassiveDes/link", "SkillPassiveDes/way",
        "SkillPassivePanel/SkillScroll/Viewport/Content/SkillPassItem",
    }
    self:GetChildren(self.nodes)
    self.des_Text = self.des:GetComponent('Text')
    self.skillName_Text = self.skillName:GetComponent('Text')
    self.icon_Img = self.icon:GetComponent('Image')
    self.way = GetText(self.way)
    self.link = GetLinkText(self.link)
    self.pass_item_obj = self.SkillPassItem.gameObject

    self:AddEvent()
    self:Init()
end

function SkillPassivePanel:AddEvent()
    self.click_event_id = self.model:AddListener(SkillUIEvent.UpdatePassiveDesShow, handler(self, self.UpdateDes))
    self.link:AddClickListener(handler(self, self.HandleLinkClick));
end

function SkillPassivePanel:Init()
    self:BindRoleUpdate()
    self:LoadPasiItem()
end


--绑定升级事件
function SkillPassivePanel:BindRoleUpdate(data)
    self.role_data = RoleInfoModel.GetInstance():GetMainRoleData()
    self.role_update_list = self.role_update_list or {}

    local function call_back()
        self:LoadPasiItem()
    end
    self.role_update_list[#self.role_update_list + 1] = self.role_data:BindData("level", call_back)
end

function SkillPassivePanel:LoadPasiItem()
    self.skill_ids = {}
    local data = {}
    local count = 1
    for i, v in pairs(Config.db_skill_show) do
        if v.type == 2 then
            data = {}
            data.id = v.id
            data.index = count
            self.skill_ids[v.sort] = data
            count = count + 1
        end
    end
    local intera = table.pairsByKey(self.skill_ids)
    local list = {}
    for i, v in intera do
        list[#list + 1] = v
    end

    self.passSkillList = self.passSkillList or {}
    local len = #list
    for i = 1, len do
        local item = self.passSkillList[i]
        if not item then
            item = SkillPassItem(self.pass_item_obj, self.Content)
            self.passSkillList[i] = item
        else
            item:SetVisible(true)
        end
        local curId = list[i].id .. '@1'
        local reqs = Config.db_skill_level[curId].reqs      --获取等级需求
        local iconName = tostring(Config.db_skill[list[i].id])
        item:SetData(Config.db_skill[list[i].id], reqs, i, iconName)
    end
    for i = len + 1, #self.passSkillList do
        local item = self.passSkillList[i]
        item:SetVisible(false)
    end
end

function SkillPassivePanel:UpdateDes(data, flag1, flag2, is_lock)
    self.skillName_Text.text = data.name
    self.des_Text.text = data.desc
    lua_resMgr:SetImageTexture(self, self.icon_Img, "iconasset/icon_skill", data.icon, true, nil, false)

    SetVisible(self.way, is_lock)
    SetVisible(self.link, is_lock)

    --未解锁技能才显示获取途径
    if is_lock then
        local show_cf = Config.db_skill_show[data.id]
        local tip = "Go Now"
        if not show_cf.con then
            tip = ""
        end
        self.way.text = string.format(ConfigLanguage.Skill.PlayInSomethingToFetch, show_cf.con)
        self.link.text = "<a href=" .. show_cf.jump .. ">" .. tip .. '</a>'
    end


end

function SkillPassivePanel:HandleLinkClick(str)
    local tbl = String2Table(str)
    OpenLink(unpack(tbl))
end

