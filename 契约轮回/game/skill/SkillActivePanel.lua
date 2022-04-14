--
-- @Author: lwj
-- @Date:   2018-10-16 16:55:30
--

SkillActivePanel = SkillActivePanel or class("SkillActivePanel", BaseItem)
local SkillActivePanel = SkillActivePanel

function SkillActivePanel:ctor(parent_node, layer)
    self.abName = "skill"
    self.assetName = "SkillActivePanel"
    self.layer = layer

    self.slotFrameList = {}
    self.isUpdateSlotDone = false
    self.model = SkillUIModel.GetInstance()

    SkillActivePanel.super.Load(self)
end

function SkillActivePanel:dctor()
    self.slotFrameList = nil

    if self.globalEvents then
        for i, v in pairs(self.globalEvents) do
            GlobalEvent:RemoveListener(v)
        end
        self.globalEvents = {}
    end

    if self.role_update_list then
        for k, event_id in pairs(self.role_update_list) do
            RoleInfoModel.GetInstance():GetMainRoleData():RemoveListener(event_id)
        end
        self.role_update_list = nil
    end
    self:CleanActiveItemList()

    for k, v in pairs(self.slotList) do
        if v ~= nil then
            v:destroy()
        end
    end
    self.slotList = {}

    for i, v in pairs(self.model_event) do
        if v then
            self.model:RemoveListener(v)
        end
    end
    self.model_event = {}
end

function SkillActivePanel:LoadCallBack()
    self.nodes = {
        "SkillListPanel/SkillScroll/Viewport/Content",
        "SkillListPanel/SkillScroll/Viewport/Content/SkillListItem",

        "SkillDesPanel/iconFrame/icon",
        "SkillDesPanel/skillName",
        "SkillDesPanel/cd",
        --"SkillDesPanel/des",
        "SkillDesPanel/Scroll View/Viewport/des",

        "SkillSlotPanel/slotContainer/slotFrame_8",
        "SkillSlotPanel/slotContainer/slotFrame_7",
        "SkillSlotPanel/slotContainer/slotFrame_6",
        "SkillSlotPanel/slotContainer/slotFrame_5",
        "SkillSlotPanel/slotContainer/slotFrame_4",
        "SkillSlotPanel/slotContainer/slotFrame_3",
        "SkillSlotPanel/slotContainer/slotFrame_2",
        "SkillSlotPanel/slotContainer/slotFrame_1",

        "RecomContainer",
        "ExampleContainer",
        "SkillSlotPanel/btnContainer/btnRecommend",
        "SkillSlotPanel/btnContainer/btnExample",
    }
    self:GetChildren(self.nodes)
    self.cd_Text = self.cd:GetComponent('Text')
    self.des_Text = self.des:GetComponent('Text')
    self.icon_img = self.icon:GetComponent('Image')
    self.list_item_obj = self.SkillListItem.gameObject

    self:AddSlotFrame()

    self:AddEvent()
    self:Init()
end

function SkillActivePanel:AddSlotFrame()
    self.slotFrameList[1] = self.slotFrame_1
    self.slotFrameList[2] = self.slotFrame_2
    self.slotFrameList[3] = self.slotFrame_3
    self.slotFrameList[4] = self.slotFrame_4
    self.slotFrameList[5] = self.slotFrame_5
    self.slotFrameList[6] = self.slotFrame_6
    self.slotFrameList[7] = self.slotFrame_7
    self.slotFrameList[8] = self.slotFrame_8
end

function SkillActivePanel:AddEvent()
    self.globalEvents = self.globalEvents or {}
    self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(SkillUIEvent.UpdateSkillSlots, handler(self, self.HandleSkillGet))
    self.globalEvents[#self.globalEvents + 1] = GlobalEvent:AddListener(SkillUIEvent.UpdateListAutoUse, handler(self, self.UpdateAutoUse))

    self.model_event = self.model_event or {}
    self.model_event[#self.model_event + 1] = self.model:AddListener(SkillUIEvent.UpdateActiveDesShow, handler(self, self.UpdateDesShow))

    local function call_back()
        local cur_lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
        if cur_lv < 371 then
            --if cur_lv < 3 then
            local tips = string.format(ConfigLanguage.Skill.HaveNotUnlock, 371)
            Notify.ShowText(tips)
        else
            lua_panelMgr:GetPanelOrCreate(SkillRecommendPanel):Open()
        end
    end
    AddClickEvent(self.btnRecommend.gameObject, call_back)

    local function call_back()
        lua_panelMgr:GetPanelOrCreate(SkillExamplePanel):Open()
    end
    AddClickEvent(self.btnExample.gameObject, call_back)
end

function SkillActivePanel:Init()
    self:BindRoleUpdate()
    self:HandleSkillGet()
end


--绑定升级事件
function SkillActivePanel:BindRoleUpdate(data)
    self.role_update_list = self.role_update_list or {}
    local function call_back()
        --self:ChangeSkillLock(self.actSkillList, true)
        --self:ChangeSkillLock(self.slotList, true)
        self:HandleSkillGet()
    end
    self.role_update_list[#self.role_update_list + 1] = RoleInfoModel.GetInstance():GetMainRoleData():BindData("level", call_back)
end

function SkillActivePanel:HandleSkillGet()
    self:LoadSkillSlot()
    self:LoadListItems()
end

--加载主动技能列表
function SkillActivePanel:LoadListItems()
    --self:CleanActiveItemList()
    self.skill_ids = {}
    local idTemp = nil
    local normalAtkTemp = {}
    local isCan = true
    local left_slot_list = {}
    local already_get_list = {}

    for i, v in pairs(Config.db_skill_show) do
        idTemp = nil
        --主动技能、职业匹配
        if v.type == 1 then
            if v.career == RoleInfoModel.GetInstance():GetMainRoleData().gender or v.career == 3 then
                isCan = true
                idTemp = v.id .. "@1"
                if Config.db_skill[v.id].is_hew == 0 then
                    --技能
                    --是否获得
                    local id = self.model:GetAutoUseInfoById(v.id)
                    if id then
                        --获得
                        local data = already_get_list[v.pos]
                        --同一槽位是否有以获得的技能
                        if data then
                            if v.index > data.index then
                                already_get_list[v.pos] = v
                                table.removebykey(self.skill_ids, data.pos)
                            else
                                isCan = false
                            end
                        else
                            --没有已获得的技能
                            local list_data = self.skill_ids[v.pos]
                            --看看列表中是否已经加入了 未获得的技能
                            if list_data then
                                table.removebykey(self.skill_ids, v.pos)
                            end
                            already_get_list[v.pos] = v
                        end
                    else
                        --未获得
                        --检查左侧槽位
                        local alre_data = already_get_list[v.pos]
                        if alre_data then
                            isCan = false
                        else
                            local data = left_slot_list[v.pos]
                            if not data then
                                left_slot_list[v.pos] = v
                            else
                                if data.index > v.index then
                                    isCan = false
                                else
                                    if v.id == 202001 then
                                        print()
                                    end
                                    left_slot_list[v.pos] = v
                                    table.removebykey(self.skill_ids, data.pos)
                                end
                            end
                        end
                    end
                else
                    isCan = false
                end

                if isCan then
                    if (not v) or (not v.id) then
                        print()
                    end
                    self.skill_ids[v.pos] = v.id
                end
            end
        end
    end

    local list = self.skill_ids
    -------------------找出普攻
    local nor_skill_id
    --dump(self.model.skill_List, "<color=#6ce19b>SKILL_LIST   SKILL_LIST  SKILL_LIST  SKILL_LIST</color>")
    for i, v in pairs(self.model.skill_List) do
        if Config.db_skill[v.id].is_hew == 1 then
            --普攻
            local v_wake = Config.db_skill[v.id].wake
            if normalAtkTemp.id == nil then
                normalAtkTemp.id = v.id
                nor_skill_id = normalAtkTemp.id
            elseif v_wake > Config.db_skill[normalAtkTemp.id].wake then
                normalAtkTemp.id = v.id
                --table.removebyindex(self.skill_ids, 1)
                nor_skill_id = normalAtkTemp.id
            elseif v_wake == Config.db_skill[normalAtkTemp.id].wake and v.id < normalAtkTemp.id then
                normalAtkTemp.id = v.id
                --table.removebyindex(self.skill_ids, 1)
                nor_skill_id = normalAtkTemp.id
            end
        end
    end

    self.actSkillList = self.actSkillList or {}
    local len = #list
    for i = 1, len do
        local item = self.actSkillList[i]
        if not item then
            item = SkillListItem(self.list_item_obj, self.Content)
            self.actSkillList[i] = item
        else
            item:SetVisible(true)
        end
        local v
        if i == 1 then
            v = nor_skill_id
        else
            v = list[i]
        end
        local curId = v .. '@1'
        local reqs = Config.db_skill_level[curId].reqs      --获取等级需求
        local iconName = Config.db_skill[v].icon
        item:SetData(Config.db_skill[v], reqs, i, iconName)
    end
    for i = len + 1, #self.actSkillList do
        local item = self.actSkillList[i]
        item:SetVisible(false)
    end
end

function SkillActivePanel:CheckExsit(list, id)
    local isGet = false
    for i, v in pairs(list) do
        if v.id == id then
            isGet = true
            break
        end
    end
    return isGet
end

function SkillActivePanel:InitDesShow()
    local data = self.actSkillList[2].data
    --self.model.currentSelectId=data.id
    self.model.curShowDesId = data.id
    self:UpdateDesShow(data, false, false)
    self.actSkillList[2]:UpdateAutoUseShow()
end


--加载技能槽
function SkillActivePanel:LoadSkillSlot()
    local list = self.model:GetSlotsList()
    local can_show_list = self.model:GetCanShowSlotsList()
    local len = #can_show_list
    self.slotList = self.slotList or {}
    for i = 1, len do
        local iSkillPos = can_show_list[i].pos
        --技能类型 主动被动共用
        local skill_type = can_show_list[i].career
        local skillInfo = list[iSkillPos]
        local item = self.slotList[iSkillPos]
        local is_new = false
        if not item then
            is_new = true
            item = SkillSlotItem(self.slotFrameList[iSkillPos], self.layer)
            self.slotList[iSkillPos] = item
        else
            item:SetVisible(true)
        end
        item:SetData(skillInfo)
        if skillInfo then
            local curId = skillInfo.id .. '@1'
            local reqs = Config.db_skill_level[curId].reqs      --获取等级需求
            local iconName = tostring(Config.db_skill[skillInfo.id].icon)
            item:SetDetail(Config.db_skill[skillInfo.id], reqs, iconName, iSkillPos,skill_type)
        else
            item:SetIdx(iSkillPos)
        end
        if not is_new then
            item:UpdateShow()
        end
    end
    self.model.currentSelectId = nil
end

--更新Toggle显示
function SkillActivePanel:UpdateAutoUse()
    if not self.actSkillList then
        return
    end
    for i, v in ipairs(self.actSkillList) do
        v:UpdateAutoUseShow()
    end
end

--更新技能信息显示事件
function SkillActivePanel:UpdateDesShow(data, isAtList, isChangeSkill)
    if not isChangeSkill then
        self.skillName:GetComponent('Text').text = data.name
        local curId = data.id .. "@1"
        local finalCd = Config.db_skill_level[curId].cd / 1000
        self.cd_Text.text = finalCd .. "sec"
        self.des_Text.text = data.desc
        lua_resMgr:SetImageTexture(self, self.icon_img, "iconasset/icon_skill", data.iconName or data.icon, true, nil, false)
    end
    if isAtList then
        --logError("Skill Act Panel 318  and not at list")
        self.model:SetCurrentSkillId(data.id)
    end
end

function SkillActivePanel:CleanActiveItemList()

    if self.actSkillList then
        for i, v in pairs(self.actSkillList) do
            if v ~= nil then
                v:destroy()
            end
        end
        self.actSkillList = nil
    end


end