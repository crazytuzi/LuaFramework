-- @Author: lwj
-- @Last Modified by:   win 10
-- @Last Modified time: 2018-10-25 15:07:36


SkillSlotItem = SkillSlotItem or class("SkillSlotItem", BaseItem)
local SkillSlotItem = SkillSlotItem

function SkillSlotItem:ctor(parent_node, layer)
    self.abName = "skill"
    self.assetName = "SkillSlotItem"
    self.layer = layer

    self.isChangeSkill = false
    self.is_alrea_add_pet_event = false
    self.model = SkillUIModel.GetInstance()
    BaseItem.Load(self)
end

function SkillSlotItem:dctor()
    if self.sel_event_id then
        self.model:RemoveListener(self.sel_event_id)
        self.sel_event_id = nil
    end
    if self.pet_change_event_id then
        self.model:RemoveListener(self.pet_change_event_id)
        self.pet_change_event_id = nil
    end
end

function SkillSlotItem:LoadCallBack()
    self.nodes = {
        "lock",
        "image",
        "focus",
        "BottomRight/sub_script",
    }
    self:GetChildren(self.nodes)
    self.img = self.image:GetComponent('Image')
    self.idx_text = GetText(self.sub_script)

    self:AddEvent()
    self:UpdateShow()
end

function SkillSlotItem:AddEvent()
    local function call_back(target, x, y)
        local cf = Config.db_skill_show[self.model.currentSelectId]
        if not cf then
            return
        end
        local type = cf.career
        if self.model.currentSelectId and self.model.currentSelectId ~= self.skill_info.id and not self.model:JudgeIsNormalAtk() and self.idx < 7 and type ~= 3 then
            GlobalEvent:Brocast(SkillUIEvent.PutOnSkill, self.model.currentSelectId, self.skill_info.pos)
            self.model.currentSelectId = nil
            self.isChangeSkill = true
        end
        if self.model.curShowDesId ~= self.data.id and self.skill_type ~= 3 then
            if self.isChangeSkill then
                self.model:Brocast(SkillUIEvent.UpdateActiveDesShow, self.data, false, true)
            else
                self.model.curShowDesId = self.data.id
                self.model:Brocast(SkillUIEvent.UpdateActiveDesShow, self.data, false, false)
                self.model.currentSelectId = nil
            end
            self.isChangeSkill = false
        end

        -- lua_panelMgr:GetPanelOrCreate(TipsSkillPanel):Open()
        -- lua_panelMgr:GetPanelOrCreate(TipsSkillPanel):SetId(self.skill_info.id,self.image)
    end
    AddClickEvent(self.image.gameObject, call_back)

    local function callback()
        local tip
        local time = Config.db_skill_pos[self.idx].wake
        if self.idx <= 4 then
            tip = ConfigLanguage.Skill.LvLimit
            Notify.ShowText(string.format(tip, time))
        elseif self.idx == 8 then
            tip = ConfigLanguage.Skill.SendAPetFirst
            Notify.ShowText(tip)
        else
            tip = ConfigLanguage.Skill.TimeOfWakeForUnlock
            Notify.ShowText(string.format(tip, time))
        end
    end
    AddClickEvent(self.lock.gameObject, callback)

    self.sel_event_id = self.model:AddListener(SkillUIEvent.UpdateActiveDesShow, handler(self, self.SetShowOrHide))
end

function SkillSlotItem:SetData(data)
    self.skill_info = data
end

function SkillSlotItem:UpdateShow()
    local con
    if self.idx == 7 then
        con = "Morph"
    elseif self.idx == 8 then
        con = "Pet"
    else
        con = self.idx
    end
    self.idx_text.text = con
    if self.idx == 8 then
        self:ChangePetSlot()
    end
    if self.skill_info ~= nil then
        lua_resMgr:SetImageTexture(self, self.img, "iconasset/icon_skill", self.iconName, true, nil, false)
        SetVisible(self.lock, false)
    else
        SetVisible(self.lock, true)
    end
end

function SkillSlotItem:SetDetail(data, req, iconName, pos, skill_type)
    self.data = data
    self.data.req = req
    self.iconName = iconName
    self.idx = pos
    self.skill_type = skill_type
end

function SkillSlotItem:SetIdx(idx)
    self.idx = idx
end

function SkillSlotItem:SetShowOrHide(data)
    if self.data then
        SetVisible(self.focus, self.data.id == data.id)
    end
end

function SkillSlotItem:ChangePetSlot()
    local skill_id = self.model:GetCurPetSkill()
    if skill_id then
        self.skill_info = {}
        self.skill_info.id = skill_id
        self.skill_info.pos = 8
        local curId = skill_id .. '@1'
        local reqs = Config.db_skill_level[curId].reqs      --获取等级需求
        local iconName = Config.db_skill[skill_id].icon
        self:SetDetail(Config.db_skill[skill_id], reqs, iconName, 8, 1)
    end
end
