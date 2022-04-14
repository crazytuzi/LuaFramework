--
-- @Author: lwj
-- @Date:   2018-10-16 15:12:57
--

SkillListItem = SkillListItem or class("SkillListItem", BaseCloneItem)
local SkillListItem = SkillListItem

function SkillListItem:ctor(parent_node, layer)
    SkillListItem.super.Load(self)
end

function SkillListItem:dctor()
    if self.sel_event_id then
        self.model:RemoveListener(self.sel_event_id)
        self.sel_event_id = nil
    end
    if self.pas_sel_event_id then
        self.model:RemoveListener(self.pas_sel_event_id)
        self.pas_sel_event_id = nil
    end
end

function SkillListItem:LoadCallBack()
    self.model = SkillUIModel:GetInstance()
    self.nodes = {
        "skillName",
        "iconFrame/icon",
        "bg",
        "focus",
        "lockImage",
        "Toggle",
        "lockImage/Image",
    }
    self:GetChildren(self.nodes)
    self.autoUseToggle = self.Toggle:GetComponent('Toggle')
    self.hightLight = self.focus
    self.skillName_Text = self.skillName:GetComponent('Text')
    self.icon_Img = self.icon:GetComponent('Image')
    self.unlock_Text = self.lockImage:GetComponent('Text')
    self.lock_mask = GetImage(self.Image)

    self:AddEvent()
end

function SkillListItem:AddEvent()
    self.sel_event_id = self.model:AddListener(SkillUIEvent.UpdateActiveDesShow, handler(self, self.SetShowOrHide))
    self.pas_sel_event_id = self.model:AddListener(SkillUIEvent.UpdatePassiveDesShow, handler(self, self.SetShowOrHide))

    local function call_back(target, x, y)
        if self.model.curShowDesId ~= self.data.id then
            if self.locateIndex == 1 then
                self.model:Brocast(SkillUIEvent.UpdateActiveDesShow, self.data, true, false)
                self:UpdateAutoUseShow()
            else
                self.model:Brocast(SkillUIEvent.UpdatePassiveDesShow, self.data, true, false, self.is_lock)
                if self.is_lock then
                    if self.show_cf.con ~= "" then
                        Notify.ShowText(string.format(ConfigLanguage.Skill.PleaseFinishTask, self.show_cf.con))
                    end
                end
            end
        end
        self.model.currentSelectId = self.data.id
        self.model.curShowDesId = self.data.id
    end
    AddClickEvent(self.bg.gameObject, call_back)

    local function call_back(target, x, y)
        if self.show_cf.mode == 1 then
            --self.unlock_tips = string.format(ConfigLanguage.Skill.HaveNotUnlock, String2Table(self.data.reqs)[2])
            Notify.ShowText(self.unlock_tips)
        elseif self.show_cf.mode == 2 then
            --self.unlock_tips = string.format(ConfigLanguage.Skill.PleaseFinishTask)
            --Notify.ShowText(self.unlock_tips)
        end
    end
    AddClickEvent(self.lockImage.gameObject, call_back)

    local function call_back()
        local useId = 0
        if not self.autoUseToggle.isOn then
            useId = 1
        end
        GlobalEvent:Brocast(SkillUIEvent.SetSkillAutoUse, self.data.id, useId)
        -- if self.model.curShowDesId then
        -- end
    end
    AddClickEvent(self.autoUseToggle.gameObject, call_back)
end

function SkillListItem:InitItem()
    --初始化物品所在界面
    if not self.model.isOpenPassive then
        self.locateIndex = 1
    else
        self.locateIndex = 2
    end
    --技能Item加载出来的时候 初始化技能解锁情况
    self:SetListShow()

    --在被动技能面板中的时候
    if self.locateIndex == 2 then
        local rect = GetRectTransform(self.skillName)
        SetSizeDelta(rect, 102, 60)
        SetLocalPosition(rect, 51, 16)
        SetVisible(self.Toggle, false)
        if self.data.index == 1 then
            self.model:Brocast(SkillUIEvent.UpdatePassiveDesShow, self.data, true, false, self.is_lock)
        end
    elseif self.locateIndex == 1 then
        if self.data.index == 1 then
            SetVisible(self.Toggle, false)
        end
        if self.data.index == 2 then
            if self.model.is_need_set_default then
                self.model:Brocast(SkillUIEvent.UpdateActiveDesShow, self.data, true, false)
                self.model.is_need_set_default = false
            end
        end
        self:UpdateAutoUseShow()
    end
end


--设置物品在技能列表中的显示
function SkillListItem:SetListShow()
    local name = self.data.name
    local name_list = string.utf8list(name)
    if self.locateIndex == 2 and string.utf8len(name) > 4 then
        table.insert(name_list, 7, "\n")
        name = table.concat(name_list, "")
    end
    self.skillName_Text.text = name
    --if self.lockImage.gameObject.activeSelf then
    local wake_need = Config.db_skill[self.data.id].wake
    local wake = RoleInfoModel.GetInstance():GetMainRoleData().wake
    local is_lock = false
    self.show_cf = Config.db_skill_show[self.data.id]
    if not self.show_cf then
        logError("SkillListItem,Line137, " .. self.data.id .. "this skill_id doesnt exist in db_skill_show")
        return
    end
    if self.show_cf.mode == 1 then
        self.lock_mask.raycastTarget = true
        if wake_need > 0 then
            if wake < wake_need then
                self.unlock_tips = string.format(ConfigLanguage.Skill.UnLockBeforeWake, wake_need)
                is_lock = true
            end
        else
            local req = String2Table(self.data.reqs)[2]
            local my_lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
            if my_lv < req then
                self.unlock_tips = string.format(ConfigLanguage.Skill.HaveNotUnlock, String2Table(self.data.reqs)[2])
                is_lock = true
            end
        end
    elseif self.show_cf.mode == 2 then
        self.lock_mask.raycastTarget = false;
        if not self.model:IsGetSkill(self.data.id) then
            self.unlock_tips = self.show_cf.con2
            is_lock = true
        end
    end
    self.is_lock = is_lock
    if is_lock then
        self.unlock_Text.text = self.unlock_tips
        SetVisible(self.lockImage.gameObject, true)
        SetVisible(self.Toggle, false)
    else
        SetVisible(self.lockImage, false)
        SetVisible(self.Toggle, true)
    end
    lua_resMgr:SetImageTexture(self, self.icon_Img, "iconasset/icon_skill", tostring(Config.db_skill[self.data.id].icon), true, nil, false)
end

function SkillListItem:SetData(data, requireLevel, index, iconName)
    self.data = data
    self.data.reqs = requireLevel
    self.data.index = index
    self.data.iconName = iconName
    self:InitItem()
end

function SkillListItem:SetShowOrHide(data, is_at_list, is_change_skill)
    if not is_change_skill then
        SetVisible(self.focus, self.data.id == data.id)
    end
end

--更新自动使用显示
function SkillListItem:UpdateAutoUseShow()
    for id, useId in pairs(self.model.autoUseChangeList) do
        if self.data.id == id then
            if self.autoUseToggle ~= nil then
                if useId == 1 then
                    self.autoUseToggle.isOn = false
                else
                    self.autoUseToggle.isOn = true
                end
            end
            break
        end
    end
end