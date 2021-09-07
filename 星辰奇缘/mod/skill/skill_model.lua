SkillModel = SkillModel or BaseClass(BaseModel)

function SkillModel:__init()
    self.window = nil
    self.life_produce_win = nil
    self.newMarrySkillWindow = nil
    self.marrySkillWindow = nil

    self.role_skill = {}
    self.talent_3 = {}
    self.prac_skill = {}
    self.marry_skill = {}

    self.newTalent = {}

    self.prac_skill_learning = 0
    self.prac_skill_upgrade_id = nil
    self.prac_skill_lowlevel = nil
    self.prac_skill_gen_upgrade = false

    self.life_skills = nil
    self.life_produce_data = nil

    self.skill_prac_redpoint = true

    self.diaowen_id = 10007

    self.chest_box_data = nil

    self.newskillid = 0
    self.note_times = 0

    self.in10804 = false

    self.skillpracIndex = 1     -- 冒险技能学习选项

    self.finalSkill = nil
end

function SkillModel:__delete()
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
    end
end

function SkillModel:OpenSkillWindow(args)
    if self.window == nil then
        self.window = SkillView.New(self)
    end
    self.window:Open(args)
end

function SkillModel:CloseExerciseQuickBuyWindow()
    if self.exerciseQuickBuywindow ~= nil then
        self.exerciseQuickBuywindow:DeleteMe()
        self.exerciseQuickBuywindow = nil
    end
end

function SkillModel:OpenExerciseQuickBuyWindow(args)

    if self.exerciseQuickBuywindow == nil then
        print("23333333333333333")
        self.exerciseQuickBuywindow = ExerciseQuickBuyWindow.New(self)
    end
    self.exerciseQuickBuywindow:Open(args)
end

function SkillModel:CloseSkillWindow()
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
    end
end


--打开生活技能产出面板
function SkillModel:OpenSkillLifeProduceWindow()
    if self.life_produce_win == nil then
        self.life_produce_win = SkillLifeProduceWindow.New(self)
    end
    self.life_produce_win:Show()
end

--关闭生活技能产出面板
function SkillModel:CloseSkillLifeProduceWindow()
    if self.life_produce_win ~= nil then
        self.life_produce_win:DeleteMe()
        self.life_produce_win = nil
    end
    -- if self.life_produce_win ~= nil then
    --     WindowManager.Instance:CloseWindow(self.life_produce_win)
    -- end
end

--打开冒险保箱
function SkillModel:OpenPracSkillChestbox()
    if self.prac_skill_chestbox == nil then
        self.prac_skill_chestbox = PracSkillChestboxView.New(self)
        self.prac_skill_chestbox:Open()
    end
end

--关闭冒险保箱
function SkillModel:ClosePracSkillChestbox()
    if self.prac_skill_chestbox ~= nil then
        self.prac_skill_chestbox:DeleteMe()
        self.prac_skill_chestbox = nil
    end
end

--打开使用活力
function SkillModel:OpenUseEnergy()
    if self.use_energy == nil then
        self.use_energy = UseEnergyView.New(self)
        self.use_energy:Open()
    end
end

--关闭使用活力
function SkillModel:CloseUseEnergy()
    if self.use_energy ~= nil then
        self.use_energy:DeleteMe()
        self.use_energy = nil
    end
end

--打开使用活力
function SkillModel:OpenSkillTalentWindow()
    if self.skillTalentWindow == nil then
        self.skillTalentWindow = SkillTalentView.New(self)
        self.skillTalentWindow:Show()
    end
end

--关闭使用活力
function SkillModel:CloseSkillTalentWindow()
    if self.skillTalentWindow ~= nil then
        self.skillTalentWindow:DeleteMe()
        self.skillTalentWindow = nil
    end
end

--打开激活伴侣技能
function SkillModel:OpenMarrySkillWindow()
    if self.marrySkillWindow == nil then
        self.marrySkillWindow = MarrySkillWindow.New(self)
        self.marrySkillWindow:Open()
    end
end

--关闭激活伴侣技能
function SkillModel:CloseMarrySkillWindow()
    if self.marrySkillWindow ~= nil then
        self.marrySkillWindow:DeleteMe()
        self.marrySkillWindow = nil
    end
end

--打开获得伴侣技能通知
function SkillModel:OpenNewMarrySkillWindow(args)
    if self.newMarrySkillWindow == nil then
        self.newMarrySkillWindow = NewMarrySkillWindow.New(self)
        self.newMarrySkillWindow:Show(args)
    end
end

--关闭获得伴侣技能通知
function SkillModel:CloseNewMarrySkillWindow()
    if self.newMarrySkillWindow ~= nil then
        self.newMarrySkillWindow:DeleteMe()
        self.newMarrySkillWindow = nil
    end
end

-- function SkillModel:OpenFinalSkillStudyPanel(parent)
--     if self.finalSkillStudyPanel == nil then
--         self.finalSkillStudyPanel = SkillFinalStudyPanel.New(self,parent)
--     end
--     self.finalSkillStudyPanel:Show()
-- end

-- function SkillModel:OpenFinalSkillPanel(parent)
--     if self.finalSkillPanel == nil then
--         self.finalSkillPanel = SkillFinalPanel.New(self,parent)
--     end
--     self.finalSkillPanel:Show()
-- end

function SkillModel:OpenFinalSkillGet()
    if self.finalSkillGet == nil then
        self.finalSkillGet = SkillFinalGetWindow.New(self)
    end
    self.finalSkillGet:Open()
end


function SkillModel:OpenExerciseWindow(args)
    if self.exerciseWindow == nil then
        self.exerciseWindow = ExerciseWindow.New(self)
    end
    self.exerciseWindow:Open(args)
end

function SkillModel:OpenExerciseDouble()
    if self.exerciseDouble == nil then
        self.exerciseDouble = ExerciseDoubleWindow.New(self)
    end
    self.exerciseDouble:Show()
end

function SkillModel:CloseExerciseDouble()
    if self.exerciseDouble ~= nil then
        self.exerciseDouble:DeleteMe()
        self.exerciseDouble = nil
    end
end

function SkillModel:On10800(data)
    self.role_skill = data.skill_data
    self.no_speed_list = data.speed
    for i = 1, #self.role_skill do
        self.role_skill[i] = self:updateroleskillbasedata(self.role_skill[i])
    end
    self:skillSrot()
    self:updateroleskill()
end

function SkillModel:On10802(data)
    local skilldata = self:getroleskill(data.id)
    if skilldata ~= nil then
        local talent
        local lev
        talent, lev = self:checknewskilltalent(skilldata, data)
        if talent ~= nil then
            self.newTalent[talent.id] = { data = talent, lev = lev }
            -- BaseUtils.dump(self.newTalent, "self.newTalent")
            self:OpenSkillTalentWindow()
        end

        skilldata.lev = data.lev
        local has = false
        for i = 1, #self.role_skill do
            if self.role_skill[i].id == data.id then
                self.role_skill[i].lev = data.lev
                self.role_skill[i] = self:updateroleskillbasedata(self.role_skill[i])
                has = true
            end
        end
        if not has then
            local sdata = self:updateroleskillbasedata(data)
            table.insert(self.role_skill, sdata)
            self:skillSrot()
        end
        -- local msg = string.format("<color='#ffff00'>%s</color>技能升级到%s级"
        --     , data_skill.data_skill_role[string.format("%s_%s", skilldata.id, skilldata.lev)].name, skilldata.lev)
        -- NoticeManager.Instance:FloatTipsByString(TI18N(msg))
    end
    self:updateroleskill()
end

function SkillModel:On10804(data)
    if self.in10804 then
        local talent
        local lev
        talent, lev = self:checknewtalent(self.talent_3, data.tips_args)
        if talent ~= nil then
            self.newTalent[talent.id] = { data = talent, lev = lev }
            self:OpenSkillTalentWindow()
        end
    else
        self.in10804 = true
    end

    self.talent_3 = {}
    for i = 1, #data.tips_args do
        self.talent_3[data.tips_args[i].id] = true
    end
    self:updateroleskill()
end

function SkillModel:On10805(data)
    self.prac_skill_learning = data.selected_id

    local function sortfun(a,b)
        return a.id < b.id
    end

    table.sort(data.skl_prac, sortfun)

    for i = 1, #data.skl_prac do
        -- data.skl_prac[i].lev = data.skl_prac[i].lev-- - self:getpracskillenhancelevel(data.skl_prac[i])
        data.skl_prac[i].times = 0
        for _,v in pairs(data.skl_prac_times) do
            if v.id == data.skl_prac[i].id then
                data.skl_prac[i].times = v.times
                break
            end
        end
    end

    local prac_skill_upgrade_id = nil
    local prac_skill_lowlevel = nil

    prac_skill_upgrade_id, prac_skill_lowlevel = self:check_prac_skill_upgrade(data.skl_prac)

    if prac_skill_upgrade_id ~=nil then
        self.prac_skill_upgrade_id = prac_skill_upgrade_id
        -- sound_player:PlayOption(230)
    end

    if prac_skill_lowlevel ~=nil then
        if self.prac_skill_lowlevel ~= nil
            and self.prac_skill_lowlevel < prac_skill_lowlevel then
            self.prac_skill_gen_upgrade = true
            -- sound_player:PlayOption(229)
        end
    end

    self.prac_skill = data.skl_prac
    self.prac_skill_lowlevel = prac_skill_lowlevel

    SkillManager.Instance.OnUpdatePracSkill:Fire()

    self.prac_skill_upgrade_id = nil
end

function SkillModel:On10806(data)
    self.prac_skill_learning = data.id
    SkillManager.Instance.OnUpdatePracSkill:Fire()
    if data.flag == 1 then
        NoticeManager.Instance:FloatTipsByString(TI18N("设置冒险技能成功"))
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("设置冒险技能失败"))
    end
end

function SkillModel:On10807(data)
    local skl_prac = BaseUtils.copytab(self.prac_skill)
    local msg = ""
    for k,v in pairs(skl_prac) do
        if v.id == data.id then
            -- if v.lev == data.lev then
            --     msg = string.format("<color='#ffff00'>%s</color>技能增加%s经验"
            --         , data_skill_prac.data_skill[data.id].name, data.exp - v.exp)
            -- else
            --     msg = string.format("<color='#ffff00'>%s</color>技能增加%s经验"
            --         , data_skill_prac.data_skill[data.id].name, data.exp)

            --     msg = string.format("%s，<color='#ffff00'>%s</color>技能升级到%s级"
            --         , msg, data_skill_prac.data_skill[data.id].name, data.lev)
            -- end

            -- -- if ui_chest_box_win.is_open == true then
            -- --     ui_chest_box_win.notify_scroll_msg = msg
            -- -- else
            --     mod_notify.append_scroll_win(msg)
            -- -- end


            v.lev = data.lev
            v.exp = data.exp
            v.times = data.prac_times
            break
        end
    end

    local function sortfun(a,b)
        return a.id < b.id
    end

    table.sort(skl_prac, sortfun)

    local prac_skill_upgrade_id = nil
    local prac_skill_lowlevel = nil

    prac_skill_upgrade_id, prac_skill_lowlevel = self:check_prac_skill_upgrade(skl_prac)

    if prac_skill_upgrade_id ~=nil then
        self.prac_skill_upgrade_id = prac_skill_upgrade_id
        -- sound_player:PlayOption(230)
    end

    if prac_skill_lowlevel ~=nil then
        if self.prac_skill_lowlevel ~= nil
            and self.prac_skill_lowlevel < prac_skill_lowlevel then
            self.prac_skill_gen_upgrade = true
            -- sound_player:PlayOption(229)
        end
    end

    self.prac_skill = skl_prac
    self.prac_skill_lowlevel = prac_skill_lowlevel

    SoundManager.Instance:Play(241)
    SkillManager.Instance.OnUpdatePracSkill:Fire()

    self.prac_skill_upgrade_id = nil
end


function SkillModel:On10808(data)
    self.life_skills = {}
    for i=1,#data.skills do
        local s = data.skills[i]
        local key = string.format("%s_%s", s.id, s.lev)
        local cfg_data = nil
        if s.id == self.diaowen_id then
            cfg_data = BaseUtils.copytab(DataSkillLife.data_diao_wen[key])
        else
            cfg_data = BaseUtils.copytab(DataSkillLife.data_data[key])
        end
        if cfg_data ~= nil then
            cfg_data.exp = s.exp
            table.insert(self.life_skills, cfg_data)
        end
    end

    if self.window ~= nil then
        self.window:UpdateSkillLife()
    end
    EventMgr.Instance:Fire(event_name.life_skill_update)
end

function SkillModel:On10812(data)
    self.chest_box_data = data
    if data ~= nil then 
        if next(data.exps) ~= nil then 
            self:OpenPracSkillChestbox()
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("来迟一步，宝箱已被别人拾取{face_1,2}"))
        end
    end

end

function SkillModel:On10813(data)
    local result_index = nil
    if data.flag == 0 then --失败
        NoticeManager.Instance:FloatTipsByString(data.msg)
        return
    else --成功

        local index = 1
        if self.chest_box_data ~= nil then
            for i=1,#self.chest_box_data.exps do
                if data.exp == self.chest_box_data.exps[i].exp then
                    index = i
                end
            end
        end
        -- ui_chest_box_win.result_back(result_index)
        result_index = index
    end

    local notify_scroll_msg = nil
    if data.exp < data.gain_exp then
        local msg_str = TI18N("每天前10个可额外获得<color='#ffff00'>30%冒险经验</color>奖励")
        notify_scroll_msg = msg_str
    end

    SkillManager.Instance.OnUpdatePracSkillChestBox:Fire(result_index, notify_scroll_msg)
end

function SkillModel:On10817(data)
    self.note_times = data.note_times
    SkillManager.Instance.OnUpdatePracSkill:Fire()
end

function SkillModel:On10818(data)
    for i = 1, #data.skl_prac do
        local skillData = self:getpracskill(data.skl_prac[i].id)
        if skillData ~= nil then
            skillData = data.skl_prac[i]
            skillData.lev = skillData.lev-- - self:getpracskillenhancelevel(skillData)

            for j=1, #self.prac_skill do
                if self.prac_skill[j].id == skillData.id then
                    self.prac_skill[j] = skillData
                end
            end

            for _,v in pairs(data.skl_prac_times) do
                if v.id == skillData.id then
                    skillData.times = v.times
                    break
                end
            end
        end
    end

    SkillManager.Instance.OnUpdatePracSkill:Fire()
end

function SkillModel:On10820(data)
    for k, v in pairs(self.marry_skill) do
        if v.id == data.id then
            if v.lev == 0 and data.lev ~= 0 then
                SkillManager.Instance.model:OpenNewMarrySkillWindow({ data.id, data.lev })
            end
            self.marry_skill[k] = data
            SkillManager.Instance.OnUpdateMarrySkill:Fire()
        end
    end
end

function SkillModel:On10822(data)
    local list = {}
    for k, v in pairs(DataSkill.data_marry_skill) do
        list[v.id] = { id = v.id, lev = 0 }
    end
    for k, v in pairs(data.skill_data) do
        list[v.id] = v
    end
    local oldData = self.marry_skill
    self.marry_skill = {}
    for k, v in pairs(list) do
        table.insert(self.marry_skill, v)
    end

    if not BaseUtils.sametab(self.marry_skill, oldData) then
        SkillManager.Instance.OnUpdateMarrySkill:Fire()
    end
end

function SkillModel:On10823(data)
    for i=1,#data.skill_data do
        local s = data.skill_data[i]
        local key = string.format("%s_%s", s.id, s.lev)
        local cfg_data = nil
        if s.id == self.diaowen_id then
            cfg_data = BaseUtils.copytab(DataSkillLife.data_diao_wen[key])
        else
            cfg_data = BaseUtils.copytab(DataSkillLife.data_data[key])
        end
        cfg_data.exp = s.exp

        local index = 0
        for key, value in ipairs(self.life_skills) do
            if value.id == s.id then
                index = key
                break
            end
        end
        if index == 0 then
            table.insert(self.life_skills, cfg_data)
        else
            self.life_skills[index] = cfg_data
        end
    end

    EventMgr.Instance:Fire(event_name.life_skill_update)
end

--------------------------------------------

function SkillModel:getroleskilldata(id,level)
    return BaseUtils.copytab(DataSkill.data_skill_role[id.."_"..level])
end

function SkillModel:getroleskill(id)
    id = tonumber(id)
    for i=1, #self.role_skill do
        if self.role_skill[i].id == id then
            return self.role_skill[i]
        end
    end
    return nil
end

function SkillModel:getmarryskilldata(id,level)
    return BaseUtils.copytab(DataSkill.data_marry_skill[id.."_"..level])
end

function SkillModel:getmarryskill(id)
    id = tonumber(id)
    for i=1, #self.marry_skill do
        if self.marry_skill[i].id == id then
            return self.marry_skill[i]
        end
    end
    return nil
end

function SkillModel:getroleskill_talent(id)
    return BaseUtils.copytab(DataSkillTalent.data_skill_talent[id])
end

function SkillModel:getpracskill(id)
    id = tonumber(id)
    for i=1, #self.prac_skill do
        if self.prac_skill[i].id == id then
            return self.prac_skill[i]
        end
    end
    return nil
end

function SkillModel:getpracskillenhancelevel(data)
    local enhancelevel = 0
    if data.enhance == nil then return enhancelevel end
    for i = 1, #data.enhance do
        enhancelevel = enhancelevel + data.enhance[i].lev
    end
    return enhancelevel
end

function SkillModel:getpracskillenhancesource(source)
    if source == 1 then
        return TI18N("爵位挑战")
    elseif source == 2 then
        return TI18N("全身强化")
    elseif source == 3 then
        return TI18N("坐骑技能")
    elseif source == 4 then
        return TI18N("公会祈福")
    elseif source == 5 then
        return TI18N("宝物境界")
    end
end

function SkillModel:getpracskill_top_lev(id, role_lev)
    id = tonumber(id)
    local top_lev = 0
    for k,v in pairs(DataSkillPrac.data_skill_level) do
        if v.id == id and v.role_lev <= role_lev and top_lev < v.skill_lev and v.lev_break_times <= RoleManager.Instance.RoleData.lev_break_times then
            top_lev = v.skill_lev
        end
    end
    return top_lev
end

function SkillModel:getpracskilldata(id,level)
    return BaseUtils.copytab(DataSkillPrac.data_skill_level[id.."_"..level])
end

function SkillModel:updateroleskillbasedata(data)
    local basedata = DataSkill.data_skill_role[data.id.."_"..data.lev]
    if basedata ~= nil then
        data.base = basedata
    end
    return data
end

--------------------------------------------------------------------
function SkillModel:updateroleskill()
    local state = self:check_show_redpoint()
    MainUIManager.Instance.OnUpdateIcon:Fire(3, state)
    SkillManager.Instance.OnUpdateRoleSkill:Fire()
    EventMgr.Instance:Fire(event_name.skill_update)
end


--更新生活技能产出界面
function SkillModel:UpdateSkillLifeProduce()
    if self.life_produce_win ~= nil then
        self.life_produce_win:socket_back_update()
    end
end

-- 人物技能排序
function SkillModel:skillSrot()
    local list = {}
    local sort_list = DataSkill.data_skill_role_init[RoleManager.Instance.RoleData.classes]
    for i,v in ipairs(sort_list.skills) do
        local skillData = self:getroleskill(v)
        if skillData ~= nil then
            table.insert(list, skillData)
        end
    end
    self.role_skill = list
end

--检查是否出现红点
function SkillModel:check_show_redpoint()
    local state_1 = self:checknewskill()
    local state_2 = self:checkupgradeskill()
    local state_3 = self:check_huoli_val()
    local state_4 = self:checkfinalskilltaskguide()
    local state_5 = self:checkfinalskilllearnguide()
    local state_6 = self:checkfinalskillcanstudy()
    local state_7 = self:checkfinalskillcanbreak()
    local state_8 = self:checkfinalskillcanup()
    self.finalskillred = state_4 or state_5 or state_6 or state_7 or state_8
    return (state_1 or state_2 or state_3 or state_4 or state_5 or state_6 or state_7 or state_8)
end

--检查下活力值是否瞒住
function SkillModel:check_huoli_val()
    return false
    -- local d = DataAgenda.data_energy_max[RoleManager.Instance.RoleData.lev]
    -- local state = false
    -- if d ~= nil then
    --     state = (RoleManager.Instance.RoleData.energy/d.max_energy) >= 0.5
    -- end
    -- return state
end

-- 检查有没有人物能学的新技能
function SkillModel:checknewskill()
    self.newskillid = 0
    local data = nil
    local newdata = nil
    local roleData = RoleManager.Instance.RoleData
    for i = 1, #self.role_skill do
        data = self.role_skill[i]
        if data.lev == 0 then
            newdata = self:getroleskilldata(data.id, 1)
            if newdata ~= nil and newdata.study_lev <= roleData.lev then
                self.newskillid =data.id
                -- MainUIManager.Instance.OnUpdateIcon:Fire(3, true)
                return true
            end
        end
    end
    return false
    -- MainUIManager.Instance.OnUpdateIcon:Fire(3, false)
end

-- 检查有没有人物能升级的技能
function SkillModel:checkupgradeskill()
    local data = nil
    local newdata = nil
    local roleData = RoleManager.Instance.RoleData
    for i = 1, #self.role_skill do
        data = self.role_skill[i]
        newdata = self:getroleskilldata(data.id, 1)

        if newdata ~= nil and (data.lev + 1) <= roleData.lev and newdata.study_lev <= roleData.lev then
            MainUIManager.Instance.OnUpdateIcon:Fire(3, true)
            return true
        end
    end
    -- MainUIManager.Instance.OnUpdateIcon:Fire(3, false)
    return false
end

-- 检查冒险技能技能
function SkillModel:check_prac_skill_upgrade(list)
    local id = nil
    local lowlevel = 10000
    for k, v in pairs(self.prac_skill) do
        if list[k] ~= nil and list[k].lev > v.lev then
            id = v.id
        end
    end

    for k, v in pairs(list) do
        if lowlevel > v.lev then
            lowlevel = v.lev
        end
    end

    return id, lowlevel
end

-- 检查冒险技能是否经验全满
function SkillModel:check_prac_skill_fullexp()
    for k, v in pairs(self.prac_skill) do
        if self:getpracskilldata(v.id, v.lev).exp > v.exp then
            return false
        end
    end

    return true
end

-- 检查技能升级是否激活新天赋
function SkillModel:checknewskilltalent(data, newdata)
    local talent = self:getroleskill_talent(data.id)
    if talent ~= nil then
        if data.lev < talent.talent1_lev and newdata.lev >= talent.talent1_lev then
            return talent, 1
        end
        if data.lev < talent.talent2_lev and newdata.lev >= talent.talent2_lev then
            return talent, 2
        end
    end
end

-- 检查装备洗炼是否激活新天赋
function SkillModel:checknewtalent(list, newlist)
    for k,v in pairs(newlist) do
        if list[v.id] ~= true then
            local talent = self:getroleskill_talent(v.id)
            if talent ~= nil then
                return talent, 3
            end
        end
    end
end

-- 检查是否终极技能任务引导
function SkillModel:checkfinalskilltaskguide()
    local data = DataQuest.data_get[44500]
    local questData = QuestManager.Instance:GetQuest(data.id)
    local roledata = RoleManager.Instance.RoleData
    local key = BaseUtils.Key(roledata.id, roledata.platform, roledata.zone_id,"finalSkillGuide1")
    local str = PlayerPrefs.GetString(key,"never")
    local t = false
    if str == "clicked" then
        t = false
    else
        t = true
    end
    if questData ~= nil and t then
        return true
    end
    return false
end

-- 检查是否终极技能领悟引导
function SkillModel:checkfinalskilllearnguide()
    local roledata = RoleManager.Instance.RoleData
    local key = BaseUtils.Key(roledata.id, roledata.platform, roledata.zone_id,"finalSkillGuide2")
    local str = PlayerPrefs.GetString(key,"never")
    local t = false
    if str == "clicked" then
        t = false
    else
        t = true
    end
    if self.finalSkill ~= nil and self.finalSkill.flag == 1 and #self.finalSkill.skill_unique == 0 and t then
        return true
    end
    return false
end


-- 检查终极技能是否可以领悟
function SkillModel:checkfinalskillcanstudy()
    if self.finalSkill ~= nil and self.finalSkill.flag == 1 and #self.finalSkill.skill_unique == 0 then
        local cost = DataSkillUnique.data_skill_unique[RoleManager.Instance.RoleData.classes.."_1"].learn_cost[1]
        if BackpackManager.Instance:GetItemCount(cost[1]) >= cost[2] then
            return true
        end
    end
    return false
end


-- 检查终极技能是否可以突破
function SkillModel:checkfinalskillcanbreak()
    if self.finalSkill ~= nil and self.finalSkill.flag == 1 and #self.finalSkill.skill_unique > 0 then
        local lev = self.finalSkill.skill_unique[1].lev
        local unique_skill = DataSkillUnique.data_skill_unique[RoleManager.Instance.RoleData.classes.."_"..lev]
        if unique_skill.is_break == 1 then
            local unique_skill = DataSkillUnique.data_skill_unique[RoleManager.Instance.RoleData.classes.."_"..(lev + 1)]
            if lev < (RoleManager.Instance.RoleData.lev - 60) and BackpackManager.Instance:GetItemCount(unique_skill.up_cost[1][1]) >= unique_skill.up_cost[1][2] then
                return true
            end
        end
    end
    return false
end

-- 检查终极技能是否可以升级（非突破）
function SkillModel:checkfinalskillcanup()
    if self.finalSkill ~= nil and self.finalSkill.flag == 1 and #self.finalSkill.skill_unique > 0 then
        local lev = self.finalSkill.skill_unique[1].lev
        local unique_skill = DataSkillUnique.data_skill_unique[RoleManager.Instance.RoleData.classes.."_"..lev]
        if unique_skill.is_break == 0 then
            local unique_skill = DataSkillUnique.data_skill_unique[RoleManager.Instance.RoleData.classes.."_"..(lev + 1)]
            if unique_skill ~= nil and lev < (RoleManager.Instance.RoleData.lev - 60) and RoleManager.Instance.RoleData.skl_unique_exp >= unique_skill.up_cost[1][2] and not SkillManager.Instance.finalSkillUp then
                return true
            end
        end
    end
    return false
end

--获取当前雕文技能等级对应职业能产出的道具
function SkillModel:get_diaowen_classes_produce()
    if self.life_skills == nil then
        return nil
    end

    for i=1,#self.life_skills do
        local d = self.life_skills[i]
        if d.id == self.diaowen_id then
            for j=1,#d.product do
                local d2 = d.product[j]
                if d2.classes == RoleManager.Instance.RoleData.classes then
                    return d2.key
                end
            end
        end
    end
    return nil
end

--获取当前雕文技能能够产出的东西
function SkillModel:get_diaowen_producing_cost()
    for i=1,#self.life_skills do
        local d = self.life_skills[i]
        if d.id == self.diaowen_id then
            return d.producing_cost
        end
    end
    return nil
end

-- 获取冒险技能中间宝石特效id
function SkillModel:get_gen_effect()
    if self.prac_skill_lowlevel <= 5 then
        return 20026
    elseif self.prac_skill_lowlevel <= 9 then
        return 20027
    elseif self.prac_skill_lowlevel <= 14 then
        return 20028
    elseif self.prac_skill_lowlevel ~= 10000 then
        return 20029
    end
    return 0
end

function SkillModel:SavePracSelect()
    local roleData = RoleManager.Instance.RoleData
    local key = BaseUtils.Key(roleData.id, roleData.platform, roleData.zone_id, "skillpracIndex")
    PlayerPrefs.SetInt(key, self.skillpracIndex)
end

function SkillModel:ReadPracSelect()
    local roleData = RoleManager.Instance.RoleData
    local key = BaseUtils.Key(roleData.id, roleData.platform, roleData.zone_id, "skillpracIndex")
    self.skillpracIndex = PlayerPrefs.GetInt(key)
    if self.skillpracIndex == 0 then
        self.skillpracIndex = 1
    end
end

