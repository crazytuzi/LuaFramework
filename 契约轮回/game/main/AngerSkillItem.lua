AngerSkillItem = AngerSkillItem or class("AngerSkillItem",BaseItem)

function AngerSkillItem:ctor(parent_node, layer)
    self.abName = "main"
    self.assetName = "AngerSkillItem"
    self.layer = layer

    self.main_model = MainModel.GetInstance()
    self.main_model_events = {}
    self.global_events = {}
    self.buff_event_id = nil

    self.data = nil
    self.need_update_view = false  --是否需要刷新UI
   
    self.start_pos = { x = 0, y = 0 }
    self.hide_pos = { x = 0, y = 0 }

    self.skill_id = nil  --怒气技能id

    self.cur_anger_value = 0 --当前怒气值

    self.is_unlock = false --是否已解锁怒气技能

    self.max_anger_value_effect = nil  --满怒气时的特效
    self.not_max_anger_value_effect = nil  --未满怒气时的特效

    self.visibleWithLoaded = true  --加载后是否显示

    AngerSkillItem.super.Load(self)
end

function AngerSkillItem:dctor()
    if table.nums(self.main_model_events) > 0 then
        self.main_model:RemoveTabListener(self.main_model_events)
        self.main_model_events = nil
    end
    if table.nums(self.global_events) > 0 then
        GlobalEvent:RemoveTabListener(self.global_events)
       self.global_events = nil
    end

    if self.max_anger_value_effect then
        self.max_anger_value_effect:destroy()
        self.max_anger_value_effect=  nil
    end

    if self.not_max_anger_value_effect then
        self.not_max_anger_value_effect:destroy()
        self.not_max_anger_value_effect=  nil
    end

   RoleInfoModel:GetInstance():GetMainRoleData():RemoveListener(self.buff_event_id)
end

function AngerSkillItem:LoadCallBack(  )
    self.nodes = {
        "unlock/img_electric","unlock/img_anger","lock","unlock","lock/txt_unlock_lv",
        "effect_container",
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()
    
    if self.need_update_view then
       self:UpdateView()
    end

    SetVisible(self.transform,self.visibleWithLoaded)
end

function AngerSkillItem:InitUI(  )
    self.img_anger = GetImage(self.img_anger)
    self.txt_unlock_lv = GetText(self.txt_unlock_lv)
end

function AngerSkillItem:AddEvent(  )

    --释放怒气技能
    local function call_back()
        if self.cur_anger_value == 100 then
            GlobalEvent:Brocast(MainEvent.ReleaseSkill, self.skill_id)
        end
    end
    AddClickEvent(self.img_anger.gameObject,call_back)

    --技能列表刷新
    local function call_back()
         if not self.is_unlock then
             self:UpdateView()
         end
    end
    self.global_events[#self.global_events + 1] = GlobalEvent:AddListener(SkillUIEvent.UpdateSkillSlots, call_back)

    --buff变化监听
    local function call_back(  )
        self:UpdateCurAngerValue()
    end
    self.buff_event_id = RoleInfoModel.GetInstance():GetMainRoleData():BindData("buffs", call_back)


end


function AngerSkillItem:SetData()
    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function AngerSkillItem:UpdateView()
    self.need_update_view = false
    
    --根据是否解锁怒气技能来进行后续处理
    self:CheckAngerSkillUnlock()
    self:SetLock(self.is_unlock)
end

function AngerSkillItem:SetStartPos(x, y)
    self.start_pos.x = x
    self.start_pos.y = y
end

function AngerSkillItem:SetHidePos(x, y)
    self.hide_pos.x = x
    self.hide_pos.y = y
end

function AngerSkillItem:StartAction(delay_time, time, pos, visible)
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

function AngerSkillItem:StopAction()
    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.transform)
end

--获取当前怒气值
function AngerSkillItem:GetCurAngerValue(  )
    local add_anger_buff_id = RoleInfoModel:GetInstance():GetMainRoleData():IsHaveBuffEffectType(enum.BUFF_EFFECT.BUFF_EFFECT_ADD_ANGER)
    local del_anger_buff_id = RoleInfoModel:GetInstance():GetMainRoleData():IsHaveBuffEffectType(enum.BUFF_EFFECT.BUFF_EFFECT_DEL_ANGER)
    local p_buff = nil
    if add_anger_buff_id then
        p_buff = RoleInfoModel:GetInstance():GetMainRoleData():GetBuffByID(add_anger_buff_id)
    elseif del_anger_buff_id then
        p_buff = RoleInfoModel:GetInstance():GetMainRoleData():GetBuffByID(del_anger_buff_id)
    end

    if p_buff then
        return p_buff.value
    else
        return nil
    end

   
end

--刷新怒气值
function AngerSkillItem:UpdateCurAngerValue()

    local value =  self:GetCurAngerValue()

    if not value then
        --logError("未获取到当前怒气值")
        return
    end

    self.cur_anger_value = value

    --logError("刷新怒气值："..self.cur_anger_value)
    local num = self.cur_anger_value / 100
    self.img_anger.fillAmount = num

    if self.cur_anger_value >= 100 then
        self:SetMaxAngerValueEffect(true)
    else
        self:SetMaxAngerValueEffect(false)
    end

end

--检查怒气技能是否已解锁
function AngerSkillItem:CheckAngerSkillUnlock( )

    local skill = SkillUIModel.GetInstance():GetSkillByIndex(enum.SKILL_POS.SKILL_POS_ANGER)
    if skill then
        self.skill_id = skill.id
        self.is_unlock = true    
    else
        self.is_unlock = false
    end



end

--设置怒气值满时的特效显示
function AngerSkillItem:SetMaxAngerValueEffect(is_max_anger_value)
    SetVisible(self.img_electric,is_max_anger_value)

    --处理UI特效
    if is_max_anger_value then
        if not self.max_anger_value_effect then
            self.max_anger_value_effect = UIEffect(self.effect_container,30017,false,self.layer)  --满怒气时的特效
            self.max_anger_value_effect:SetConfig({ is_loop = true,orderOffset = 100})
        else
            SetVisible(self.max_anger_value_effect.transform,true)
        end

        if self.not_max_anger_value_effect then
            SetVisible(self.not_max_anger_value_effect.transform,false)
        end
    else
        if not self.not_max_anger_value_effect then
            self.not_max_anger_value_effect = UIEffect(self.effect_container,30018,false,self.layer)  --未满怒气时的特效
            self.not_max_anger_value_effect:SetConfig({ is_loop = true,orderOffset = 100})
        else
            SetVisible(self.not_max_anger_value_effect.transform,true)
        end

        if self.max_anger_value_effect then
            SetVisible(self.max_anger_value_effect.transform,false)
        end
        
    end
end

function AngerSkillItem:SetIndex(index)
    
end

--设置锁定状态
function AngerSkillItem:SetLock(is_unlock)
    SetVisible(self.lock,not is_unlock)
    SetVisible(self.unlock,is_unlock)

    if self.is_unlock then
        --已解锁
        self:UpdateCurAngerValue()
    else
        --未解锁
        local skill_pos_cf = Config.db_skill_pos[enum.SKILL_POS.SKILL_POS_ANGER]
        if not skill_pos_cf then
            return
        end
        local wake_tbl = String2Table(skill_pos_cf.wake)
        local str = ""
        if wake_tbl[1] == "level" then
            str = GetLevelShow(wake_tbl[2])
            self.txt_unlock_lv.text = str .. "\nunlocks"
        elseif wake_tbl[1] == "wake" then
            str = DungeonModel.NumToChinese[wake_tbl[2]]
            self.txt_unlock_lv.text = "Awaken" .. str .. "Open"
        end
    end
end

function AngerSkillItem:SetVisibleWithLoaded(flag)
    self.visibleWithLoaded = flag
end


