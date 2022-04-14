-- 
-- @Author: LaoY
-- @Date:   2018-08-17 16:55:57
-- 

MainSkillItem = MainSkillItem or class("MainSkillItem", BaseItem)
local string_format = string.format

MainSkillItem.SkillType = {
    Nor = 1, --普攻
    Skill = 2, --技能 包括宠物变身技能
    Aux = 3, --辅助技能
    Auto = 4, --自动挂机/手动 切换
    Jump = 5, --跳跃
}
function MainSkillItem:ctor(parent_node, layer)
    self.abName = "main"
    self.assetName = "MainSkillItem"
    self.layer = layer

    self.skill_type = MainSkillItem.SkillType.Skill
    self.start_pos = { x = 0, y = 0 }
    self.hide_pos = { x = 0, y = 0 }
    self.is_can_show = true
    self.model = MainModel:GetInstance()
    self.visibleWithLoaded = true;
    self.is_setted_size = false
    MainSkillItem.super.Load(self)
end

function MainSkillItem:dctor()
    self:StopAction()
    self:StopTime()
    self:ClearMachineArmorBuff()
    self:RemoveCanReleaseEffect()
    if self.event_id_1 then
        GlobalEvent:RemoveListener(self.event_id_1)
        self.event_id_1 = nil
    end
    if self.event_id_2 then
        GlobalEvent:RemoveListener(self.event_id_2)
        self.event_id_2 = nil
    end

    if self.event_id_3 then
        GlobalEvent:RemoveListener(self.event_id_3)
        self.event_id_3 = nil
    end
    if self.event_id_4 then
        SkillModel:GetInstance():RemoveListener(self.event_id_4)
        self.event_id_4 = nil
    end
end

function MainSkillItem:LoadCallBack()
    self.nodes = {
        "skill_bg", "skill_bg/skill", "img_lock", "img_lock/lv", "cd_con", "cd_con/cd", "cd_con/cd_time",
    }
    self:GetChildren(self.nodes)
    self.skill_bg_img = self.skill_bg:GetComponent('Image')
    self.cd_img = self.cd:GetComponent('Image')
    self.cd_time_component = self.cd_time:GetComponent('Text')
    self.skill_img = self.skill:GetComponent('Image')
    self.unlock_lv = GetText(self.lv)

    -- SetVisible(self.img_lock,false)
    SetVisible(self.skill, false)
    SetVisible(self.cd_con, false)

    self:SetType(self.skill_type)
    if self.is_need_setdata then
        self:SetData()
    end
    if self.skill_type == MainSkillItem.SkillType.Nor then
        self.transform:SetAsFirstSibling()
        self:SetSiblingIndex(1)
    end

    self:AddEvent()

    MainSkillItem.super.SetVisible(self, self.visibleWithLoaded and self.is_can_show)
end

function MainSkillItem:AddEvent()
    local function call_back(target, x, y)
        if self.skill_type == MainSkillItem.SkillType.Nor then
            Yzprint('--LaoY MainSkillItem.lua,line 85--',self.machine_armor_buff_flag,self.skill_index)
            if self.machine_armor_buff_flag then
                if self.skill_info then
                    GlobalEvent:Brocast(MainEvent.ReleaseSkill, self.skill_info.id)
                end
            else
                GlobalEvent:Brocast(MainEvent.Attack)
            end
        elseif self.skill_type == MainSkillItem.SkillType.Skill then
            if not self.skill_info then
                if self.skill_index == 8 then
                    lua_panelMgr:GetPanelOrCreate(AwakenPanel):Open()
                end
                --     tip = "请先出战一个宠物"
            else
                if self.skill_index == enum.SKILL_POS.SKILL_POS_PET_TRANSFORM then
                    SkillManager:GetInstance():ReleaseSkill(self.skill_info.id)
                    -- Notify.ShowText(self.skill_info.id)
                else
                    GlobalEvent:Brocast(MainEvent.ReleaseSkill, self.skill_info.id)
                end
            end
        elseif self.skill_type == MainSkillItem.SkillType.Aux then
            Notify.ShowText("The skill is not opened yet")
        elseif self.skill_type == MainSkillItem.SkillType.Auto then
            -- Notify.ShowText("自动挂机尚未开放")
            GlobalEvent:Brocast(FightEvent.AutoFight)
        elseif self.skill_type == MainSkillItem.SkillType.Jump then
            -- Notify.ShowText("跳跃技能尚未开放")
            local main_role = SceneManager:GetInstance():GetMainRole()
            if main_role and main_role.is_swing_block then
                Notify.ShowText("You can't actively jump in deep water area")
                return
            end
            if main_role then
                main_role:PlayJump()
            end
        end
        GlobalEvent:Brocast(MainEvent.ClickSkiilItem, self.skill_type)
    end

    AddClickEvent(self.skill_bg.gameObject, call_back)

    local function call_back()
        if self.skill_type ~= MainSkillItem.SkillType.Auto then
            return
        end
        self:SetAutoRes()
    end
    self.event_id_1 = GlobalEvent:AddListener(FightEvent.StartAutoFight, call_back)
    self.event_id_2 = GlobalEvent:AddListener(FightEvent.StopAutoFight, call_back)

    local function call_back()
        if self.skill_type ~= MainSkillItem.SkillType.Skill then
            return
        end
        self:SetSkillRes()
    end
    self.event_id_3 = GlobalEvent:AddListener(SkillUIEvent.UpdateSkillSlots, call_back)

    local function call_back(skill_id, cd, is_public_cd)
        if self.skill_type ~= MainSkillItem.SkillType.Skill then
            return
        end
        if not self.skill_info or self.skill_info.id ~= skill_id then
            return
        end
        self:SetCd(cd, is_public_cd)
    end
    self.event_id_4 = SkillModel:GetInstance():AddListener(SkillEvent.UPDATE_SKILL_CD, call_back)
end

function MainSkillItem:StartAction(delay_time, time, pos, visible)
    if not self.is_loaded then
        return
    end
    if visible then
        self:SetVisible(visible)
    end
    self:StopAction()
    local delay_action = cc.DelayTime(delay_time)
    local moveAction = cc.MoveTo(time, pos.x, pos.y, 0)
    local function end_call_back()
        self:SetVisible(visible)
    end
    local call_action = cc.CallFunc(end_call_back)
    local action = cc.Sequence(delay_action, moveAction, call_action)
    cc.ActionManager:GetInstance():addAction(action, self.transform)
end

function MainSkillItem:SetAutoRes()
    if not self.is_loaded then
        return
    end
    -- Yzprint('--LaoY MainSkillItem.lua,line 110-- data=',AutoFightManager:GetInstance():GetAutoFightState())
    if AutoFightManager:GetInstance():GetAutoFightState() then
        lua_resMgr:SetImageTexture(self, self.skill_bg_img, "main_image", "btn_cancel_auto", true)
    else
        lua_resMgr:SetImageTexture(self, self.skill_bg_img, "main_image", "btn_auto", true)
    end
end

function MainSkillItem:StopAction()
    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.transform)
end

function MainSkillItem:SetStartPos(x, y)
    self.start_pos.x = x
    self.start_pos.y = y
end

function MainSkillItem:SetHidePos(x, y)
    self.hide_pos.x = x
    self.hide_pos.y = y
end

function MainSkillItem:IsNorAttack()
    return self.skill_type == MainSkillItem.SkillType.Nor
end

function MainSkillItem:SetType(skill_type)
    self.skill_type = skill_type
    if not self.is_loaded then
        self.is_need_settype = true
        return
    end
    self.is_need_settype = false

    if self.skill_type == MainSkillItem.SkillType.Nor then
        lua_resMgr:SetImageTexture(self, self.skill_bg_img, "main_image", "img_attack_nor")
        -- lua_resMgr:SetImageTexture(self, self.cd_img, "system_image", "img_c_bg_3")
        -- SetLocalScale(self.img_lock, 2.0)
        SetVisible(self.img_lock, false)
        if self.machine_armor_buff_flag then
            SetLocalPositionX(self.skill,-3.5)
            self.skill_info = SkillUIModel:GetInstance():GetSkillByIndex(self.skill_index)
            lua_resMgr:SetImageTexture(self, self.skill_bg_img, "machinearmor_scene_image", "img_attack_time_bg")
            lua_resMgr:SetImageTexture(self, self.skill_img, "machinearmor_scene_image", "img_nor_skill")
            self.machine_armor_buff_time_img = PreloadManager:GetInstance():CreateWidget("system", "EmptyImage")
            local transform = self.machine_armor_buff_time_img.transform
            transform:SetParent(self.skill_bg)
            SetChildLayer(self.machine_armor_buff_time_img,LayerManager.BuiltinLayer.UI)
            SetLocalPosition(transform, 0, 0, 0)
            SetLocalScale(transform)
            self.machine_armor_buff_time_img_component = self.machine_armor_buff_time_img:GetComponent('Image')
            self.machine_armor_buff_time_img_component.type = UnityEngine.UI.Image.Type.Filled
            self:StartMachineArmorBuffUpdate()
            self:SetMachineArmorBuffInfo()
        else
            lua_resMgr:SetImageTexture(self, self.skill_bg_img, "main_image", "img_attack_nor")
        end
    elseif self.skill_type == MainSkillItem.SkillType.Skill then
        -- lua_resMgr:SetImageTexture(self, self.skill_bg_img, "system_image", "img_c_3")
        -- lua_resMgr:SetImageTexture(self, self.cd_img, "system_image", "img_c_bg_2")
        if self.machine_armor_buff_flag then
            lua_resMgr:SetImageTexture(self, self.skill_bg_img, "machinearmor_scene_image", "img_skill_bg")
            SetLocalPositionY(self.skill,-4)
        end
        self:SetSkillRes()
        -- elseif self.skill_type == MainSkillItem.SkillType.Aux then
        --     lua_resMgr:SetImageTexture(self, self.skill_bg_img, "system_image", "img_c_2")
        --     lua_resMgr:SetImageTexture(self, self.cd_img, "system_image", "img_c_bg_2")
        --     SetLocalScale(self.img_lock, 1.0)
        -- elseif self.skill_type == MainSkillItem.SkillType.Auto then
        --     lua_resMgr:SetImageTexture(self, self.skill_bg_img, "main_image", "btn_auto")
        --     lua_resMgr:SetImageTexture(self, self.cd_img, "system_image", "img_c_bg_1")
        --     SetLocalScale(self.img_lock, 1.0)
        --     SetVisible(self.img_lock, false)
        -- elseif self.skill_type == MainSkillItem.SkillType.Jump then
        --     lua_resMgr:SetImageTexture(self, self.skill_bg_img, "main_image", "btn_jump")
        --     lua_resMgr:SetImageTexture(self, self.cd_img, "system_image", "img_c_bg_1")
        --     SetLocalScale(self.img_lock, 1.0)
        --     SetVisible(self.img_lock, false)
    end
    -- self:SetCd(10)
end

function MainSkillItem:SetMachineArmorBuffInfo()
    -- self.cur_machine_armor_img_index
    -- self.cur_machine_armor_img_value
    local buff_id = RoleInfoModel:GetInstance():GetMainRoleData():IsHaveBuffEffectType(enum.BUFF_EFFECT.BUFF_EFFECT_MECHA_MORPH)
    if not buff_id then
        self:ClearMachineArmorBuff()
        return
    end
    local cf = Config.db_buff[buff_id]
    if not cf then
        self:ClearMachineArmorBuff()
        return
    end
    local p_buff = RoleInfoModel:GetInstance():GetMainRoleData():GetBuffByID(buff_id)
    local cur_time_ms = os.clock()
    local end_time_ms = p_buff.etime * 1000
    if cur_time_ms > end_time_ms then
        self:ClearMachineArmorBuff()
        return
    end
    local value = (end_time_ms - cur_time_ms)/cf.last
    local new_value = 0.01 + 0.719 * value
    if self.cur_machine_armor_img_value == new_value then
        return
    end
    self.cur_machine_armor_img_value = new_value
    self.machine_armor_buff_time_img_component.fillAmount = new_value
    local img_index = 1
    if value >= 0.6 then
        img_index = 1
    elseif value >= 0.3 then
        img_index = 2
    else
        img_index = 3
    end
    if self.cur_machine_armor_img_index == img_index then
        return
    end
    self.cur_machine_armor_img_index = img_index

    local function callBack(sprite)
        self.machine_armor_buff_time_img_component.sprite = sprite
        self.machine_armor_buff_time_img_component:SetNativeSize()
        -- self.machine_armor_buff_time_img_component.fillAmount = self.cur_machine_armor_img_value
    end
    lua_resMgr:SetImageTexture(self, self.machine_armor_buff_time_img_component, "machinearmor_scene_image", "img_skill_time_" .. img_index,true,callBack,false)
end

function MainSkillItem:StartMachineArmorBuffUpdate()
    self:StopMachineArmorBuffUpdate()
    local function step()
       self:SetMachineArmorBuffInfo() 
    end
    self.machine_armor_buff_update_time_id = GlobalSchedule:Start(step,0)
end

function MainSkillItem:StopMachineArmorBuffUpdate()
    if self.machine_armor_buff_update_time_id then
        GlobalSchedule:Stop(self.machine_armor_buff_update_time_id)
        self.machine_armor_buff_update_time_id = nil
    end
end

function MainSkillItem:ClearMachineArmorBuff()
    self:DestroyBuffImage()
    self:StopMachineArmorBuffUpdate()
end

function MainSkillItem:DestroyBuffImage()
    if self.machine_armor_buff_time_img then
        destroy(self.machine_armor_buff_time_img)
        self.machine_armor_buff_time_img = nil
    end
end

function MainSkillItem:SetSkillIndex(skill_index,machine_armor_buff_flag)
    self.machine_armor_buff_flag = machine_armor_buff_flag
    self.skill_index = self.machine_armor_buff_flag and (skill_index + enum.SKILL_POS.SKILL_POS_MACHINEARMOR_NOR) or skill_index
end

function MainSkillItem:SetSkillRes()
    self.skill_info = SkillUIModel:GetInstance():GetSkillByIndex(self.skill_index)
    SetVisible(self.skill, self.skill_info ~= nil)
    SetVisible(self.img_lock, self.skill_info == nil)
    if self.skill_info then
        ShaderManager:GetInstance():SetImageNormal(self.skill_img)
        self.is_can_show = true
        SetVisible(self.gameObject, true)
        local config = Config.db_skill[self.skill_info.id]
        local res = config and config.icon or tostring(self.skill_info.id)
        if self.last_res ~= res then
            self.last_res = res
            lua_resMgr:SetImageTexture(self, self.skill_img, "iconasset/icon_skill", res, true)
        end

        self:SetCd(tonumber(self.skill_info.cd))
        if not self.is_setted_size then
            self.is_setted_size = true
            if self.skill_index == 8 then
                SetLocalScale(self.transform, 0.77)
            else
                SetLocalScale(self.transform, 0.95)
            end
        end
    else
        if self.machine_armor_buff_flag then
            self:SetVisible(false)
            return
        end
        --觉醒技能
        SetLocalScale(self.transform, 0.95)
        local my_lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
        local wake = RoleInfoModel.GetInstance():GetRoleValue("wake")
        if not wake then
            logError("File:MainSkillIte Line:249，'wake' is nil")
            return
        end
        local skill_pos_cf = Config.db_skill_pos[self.skill_index]
        if not skill_pos_cf then
            return
        end
        local show_tbl = String2Table(skill_pos_cf.show_lv)
        local wake_tbl = String2Table(skill_pos_cf.wake)
        if show_tbl[1] == "level" then
            self.is_can_show = my_lv >= show_tbl[2]
        elseif show_tbl[1] == "wake" then
            self.is_can_show = wake >= show_tbl[2]
        end
        if self.is_can_show then
            self:GetLimitShow(wake_tbl)
        end
        SetVisible(self.unlock_lv, true)
        if self.skill_index == 8 then
            --宠物技能
            if not self.is_setted_size then
                self.is_setted_size = true
                SetLocalScale(self.transform, 0.77)
            end
            ShaderManager:GetInstance():SetImageGray(self.skill_img)
            self.is_can_show = true
            SetVisible(self.gameObject, true)
            local res_id = 701000
            lua_resMgr:SetImageTexture(self, self.skill_img, "iconasset/icon_skill", res_id, true)
            SetVisible(self.img_lock, false)
            return
        end
        SetVisible(self.gameObject, self.is_can_show)
    end
end

function MainSkillItem:GetLimitShow(wake_tbl)
    local str = ""
    if wake_tbl[1] == "level" then
        str = GetLevelShow(wake_tbl[2])
        self.unlock_lv.text = str .. "\nunlocks"
    elseif wake_tbl[1] == "wake" then
        str = wake_tbl[2]
        self.unlock_lv.text = "Awaken" .. str .. "Open"
    end
end

function MainSkillItem:SetIndex(index)
    self.index = index
end

function MainSkillItem:SetCd(end_cd_ms, is_public_cd)
    if is_public_cd and (self.skill_index == enum.SKILL_POS.SKILL_POS_PET_TRANSFORM or self.skill_index == enum.SKILL_POS.SKILL_POS_TRANSFORM) then
        return
    end
    self:StopTime()
    SetVisible(self.cd_con, true)
    self.is_public_cd = is_public_cd
    self.skill_info.cd = end_cd_ms
    self.max_cd = end_cd_ms - os.clock()
    self.end_cd = end_cd_ms
    self.time_id = GlobalSchedule:Start(handler(self, self.Update), 0)
    self:CheckCanReleaseEffect()
end

function MainSkillItem:StopTime()
    if self.time_id then
        GlobalSchedule:Stop(self.time_id)
        self.time_id = nil
    end
end

function MainSkillItem:CheckCanReleaseEffect()
    if self.skill_index ~= enum.SKILL_POS.SKILL_POS_TRANSFORM then
        return
    end
    if os.clock() >= self.end_cd then
        self:AddCanReleaseEffect()
    else
        self:RemoveCanReleaseEffect()
    end
end

function MainSkillItem:AddCanReleaseEffect()
    if not self.can_release_effect then
        self.can_release_effect = UIEffect(self.transform, 30019, false)
    end
end

function MainSkillItem:RemoveCanReleaseEffect()
    if self.can_release_effect then
        self.can_release_effect:destroy()
        self.can_release_effect = nil
    end
end

local math_ceil = math.ceil
function MainSkillItem:Update()
    if not self.end_cd then
        return
    end
    local last_cd = self.end_cd - os.clock()
    if last_cd <= 0 then
        SetVisible(self.cd_con, false)
        self:StopTime()
        self:CheckCanReleaseEffect()
        return
    end
    local percent = 1 - (self.max_cd - last_cd) / self.max_cd
    self.cd_img.fillAmount = percent
    local str
    if self.is_public_cd or last_cd > 1000 then
        str = string_format("%d", math_ceil(last_cd / 1000))
    else
        str = string_format("%0.1f", last_cd / 1000)
    end
    self.cd_time_component.text = str
end

function MainSkillItem:SetData()
    if not self.is_loaded then
        self.is_need_setdata = true
        return
    end
    if self.skill_type == MainSkillItem.SkillType.Nor then

    elseif self.skill_type == MainSkillItem.SkillType.Skill then

    elseif self.skill_type == MainSkillItem.SkillType.Aux then

    elseif self.skill_type == MainSkillItem.SkillType.Auto then
        self:SetAutoRes()
    elseif self.skill_type == MainSkillItem.SkillType.Jump then

    end
end

function MainSkillItem:SetVisible(flag)
    if not self.is_can_show then
        flag = false
    end
    MainSkillItem.super.SetVisible(self, flag)
end

function MainSkillItem:SetVisibleWithLoaded(flag)
    self.visibleWithLoaded = flag
end