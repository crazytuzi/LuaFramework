WingsManager = WingsManager or BaseClass(BaseManager)

function WingsManager:__init()
    if WingsManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
        return
    end

    WingsManager.Instance = self

    self.mainModel = BackpackManager.Instance.mainModel
    self.model = WingsModel.New()
    self:InitHandler()

    self.noticeLevelOneString = TI18N("恭喜！成功合成了1阶翅膀，翅膀进至<color=#FFFF00>2阶</color>后将可激活<color=#00FF00>飞行</color>功能！")
    self.noticeFlyString = TI18N("翅膀已进至2阶，可点击主界面<color=#00FF00>\"飞行\"</color>按钮激活飞行状态了哦！")
    self.sureString = TI18N("确 定")
    -- 各个阶段翅膀对应的道具id
    self.stageid = {21105, 21106, 21107, 21108, 21109, 21110, 21111, 21112, 21113, 21114, 21115, 21116, 21117, 21118, 21119, 21121, 21122}
    self.stageid[999] = 21120

    self.awaken_grade = 15
    self.top_grade = 17
    self.top_star = 5
    self.top_growth = 5
    self.top_status = {self.top_grade, self.top_star}

    self.WingInfo = {}
    self.grade = 0
    self.wing_id = 0
    self.growth = 0
    self.enhance = 0
    self.star = 0
    self.exp = 0
    self.reset_times = 0
    self.mainModel.temp_reset_id = 0
    self.mainModel.tmp_grade = 0
    self.mainModel.tmp_growth = 0
    self.wing_power = 0

    self.status = 0     -- 获取翅膀信息:0，进阶完毕:1，重置完毕:2

    self.onUpdateReset = EventLib.New()
    self.onUpdateWing = EventLib.New()
    self.onUpdateProperty = EventLib.New()
    self.onStarEffect = EventLib.New()
    self.onSkillEffect = EventLib.New()
    self.onUpdateRed = EventLib.New()
    self.onUpdateAwakenSkill = EventLib.New()
    self.onLottory = EventLib.New()
    self.onGetReward = EventLib.New()

    self.redPointDic = {}
    self.illusionTab = {}

    self.wingaWakenWindow = nil -- 翅膀觉醒技能窗口
    self.break_skills = {}
    self.hasClickRedPoint = false

    EventMgr.Instance:AddListener(event_name.role_level_change, function()
        self.onUpdateRed:Fire()
    end)

    self.wingsIdByGrade = {}
    for k,v in pairs(DataWing.data_base) do
        if self.wingsIdByGrade[v.grade] == nil then
            self.wingsIdByGrade[v.grade] = {}
        end
        table.insert(self.wingsIdByGrade[v.grade], v.wing_id)
    end
    for _,v in pairs(self.wingsIdByGrade) do
        table.sort(v)
    end

    self.isCheckSkillPanel = false
    self.isCheckSkillReset = false
end

function WingsManager:GetItemByGrade(grade)
    for _,v in pairs(DataWing.data_base) do
        if v.grade == grade then
            return v.item_id
        end
    end
    if grade < 999 then
        return self.stageid[grade]
    else
        return self.stageid[999]
    end
end

function WingsManager:InitHandler()
    self:AddNetHandler(11600, self.On11600)
    self:AddNetHandler(11601, self.On11601)
    self:AddNetHandler(11602, self.On11602)
    self:AddNetHandler(11603, self.On11603)
    self:AddNetHandler(11604, self.On11604)
    self:AddNetHandler(11605, self.On11605)
    self:AddNetHandler(11606, self.On11606)
    self:AddNetHandler(11607, self.On11607)
    self:AddNetHandler(11608, self.On11608)

    self:AddNetHandler(11609, self.On11609)
    self:AddNetHandler(11610, self.On11610)
    self:AddNetHandler(11611, self.On11611)
    self:AddNetHandler(11613, self.On11613)
    self:AddNetHandler(11614, self.On11614)
    self:AddNetHandler(11615, self.On11615)
    self:AddNetHandler(11616, self.On11616)
    self:AddNetHandler(11617, self.On11617)
    self:AddNetHandler(11618, self.On11618)
end

function WingsManager:RequestInitData()
    self.WingInfo = {}
    self.grade = nil
    self.wing_id = 0
    self.growth = 0
    self.enhance = 0
    self.star = 0
    self.exp = 0
    self.wing_power = 0
    self.lastStar = nil
    self.mainModel.temp_reset_id = 0
    self.mainModel.tmp_grade = 0
    self.mainModel.tmp_growth = 0
    self.hasClickRedPoint = false
    self.isCheckSkillReset = false
    self.isCheckSkillPanel = false

    self:Send11600()
end

-- 请求当前翅膀
function WingsManager:Send11600(data)
    self:Send(11600)
end

function WingsManager:On11600(data)
    -- BaseUtils.dump(data, "------------------------------收到11600")

    if self.grade ~= 0 and self.grade ~= nil then
        for _,v in pairs(data.appearance) do
            if self.illusionTab[v.id] == nil or (self.illusionTab[v.id].timeout ~= 0 and self.illusionTab[v.id].timeout < BaseUtils.BASE_TIME) then
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.model_show_window, {v.id})
                break
            end
        end
    end

    if WindowManager.Instance.currentWin ~= nil and WindowManager.Instance.currentWin.windowId == WindowConfig.WinID.wing_book then
        if self.hasGetIds ~= nil then
            for _,v in pairs(data.wing_ids) do
                if self.hasGetIds[v.elem_wing_id] == nil then
                    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.model_show_window, {v.elem_wing_id})
                    break
                end
            end
        end
    end

    -- if self.grade ~= nil and self.grade < data.grade then
    --     for _,info in pairs(DataWing.data_group_info) do
    --         for _,grade in pairs(info.grades) do
    --             if grade == data.grade then
    --                 WindowManager.Instance:OpenWindowById(WindowConfig.WinID.wings_turnplant, {group_id = info.group_id, data = self.data_on11615, rotate = true})
    --                 self.data_on11615 = nil
    --             end
    --         end
    --     end
    -- end

    self.WingInfo = data
    self.grade = data.grade
    self.wing_id = data.wing_id
    self.growth = data.growth
    self.enhance = data.enhance
    self.exp = data.exp

    self.temp_reset_id = data.tmp_wing_id
    self.tmp_growth = data.tmp_growth
    self.tmp_grade = data.tmp_grade

    self.star = data.star

    self.reset_times = data.reset_times
    self.change_times = data.change_times

    self.valid_plan = data.valid_plan
    self.plan_data = data.plan_data
    self.break_skills = data.break_skills

    self.hasGetGrades = {}
    self.hasGetIds = {}
    for _,v in ipairs(data.wing_ids) do
        self.hasGetGrades[DataWing.data_base[v.elem_wing_id].grade] = 1
        self.hasGetIds[v.elem_wing_id] = 1
    end

    for i=1,#self.plan_data do
        if self.plan_data[i].index == self.valid_plan then
            self.skill_data = self.plan_data[i].skills
            self.tmp_skill_data = self.plan_data[i].tmp_skills
            -- self.tmp_skill_data 已经没用了, 但是plan_data里面的tmp_skills还有用
            break
        end
    end

    self.skill_data = self.skill_data or {}

    if self.status == 1 then
        if self.grade == 1 and self.star == 0 then
            local confirmData = NoticeConfirmData.New()
            confirmData.type = ConfirmData.Style.Sure
            confirmData.content = string.format(self.noticeLevelOneString, tostring(self.theMoney), name)
            confirmData.sureLabel = self.sureString
            NoticeManager.Instance:ConfirmTips(confirmData)
        elseif self.grade == 2 and self.star == 0 then
            local confirmData = NoticeConfirmData.New()
            confirmData.type = ConfirmData.Style.Sure
            confirmData.content = string.format(self.noticeFlyString, tostring(self.theMoney), name)
            confirmData.sureLabel = self.sureString
            NoticeManager.Instance:ConfirmTips(confirmData)
        end
    end

    if self.lastStar ~= nil and self.star > self.lastStar then
        self.onStarEffect:Fire(self.star)
    end

    self.status = 0
    self.lastStar = self.star


    local idList = {}
    for id,v in pairs(self.illusionTab) do
        if v ~= nil then
            table.insert(idList, id)
        end
    end
    for _,id in ipairs(idList) do
        self.illusionTab[id] = nil
    end
    for _,v in ipairs(data.appearance) do
        self.illusionTab[v.id] = {timeout = v.timeout}
    end

    self.is_no_speed = (data.speed == 0)

    -- for i=1,#self.plan_data do
    --     for j=1,#self.break_skills do
    --         table.insert(self.plan_data[i].skills, self.break_skills[j])
    --     end
    -- end

    self.wing_power = data.wing_power
    self.wing_groups = {}
    for _,v in ipairs(data.wing_groups) do
         self.wing_groups[v.group_id] = v
        if #self.wing_groups[v.group_id].wing_ids == #DataWing.data_group_info[v.group_id].wing_ids then
            self.wing_groups[v.group_id].fullCollected = true
        else
            self.wing_groups[v.group_id].fullCollected = false
        end
    end




    if self.mainModel.wingModel ~= nil then
        self.mainModel.wingModel:GetData()
    end
    EventMgr.Instance:Fire(event_name.role_wings_change)
    self.onUpdateReset:Fire()
    self.onUpdateRed:Fire()
end

-- 合成翅膀
function WingsManager:Send11601(data)
    self:Send(11601)
end

function WingsManager:On11601(data)
    -- print("接收11601")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.result == 1 then
        if self.mainModel.wingModel.wingPanel ~= nil then
            self.mainModel.wingModel.wingPanel:PlayUpgradeSucc()
        end
    end
    self.status = 0

    if self.mainModel.wingModel.wingPanel ~= nil then
        -- self.mainModel.wingModel.wingPanel.upgradeButton:ReleaseFrozon()
        self.mainModel.wingModel.wingPanel.panelList[4].mergeButton:ReleaseFrozon()
    end
end

-- 重置翅膀
function WingsManager:Send11602(data)
    self:Send(11602)
end

function WingsManager:On11602(data)
    -- print("接收11602")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.result == 1 then
        if self.mainModel.wingModel.wingPanel ~= nil then
            self.mainModel.wingModel.wingPanel:PlayResetSucc()
        end
    end

    if self.mainModel.wingModel.wingPanel ~= nil then
        self.mainModel.wingModel.wingPanel.panelList[3].resetButton:ReleaseFrozon()
    end
end

-- 进阶翅膀
function WingsManager:Send11603(data)
  -- print("发送11603")
    if self.grade < 2 then
        self.status = 1
    else
        self.status = 0
    end
    self:Send(11603, {})
end

function WingsManager:On11603(data)
    BaseUtils.dump(data, "接收11603")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.result == 1 then
        if self.mainModel.wingModel.wingPanel ~= nil then
            -- self.mainModel.wingModel.wingPanel:PlayMergeSucc()
            self.mainModel.wingModel.lastIndex = 1
            self.mainModel.wingModel.wingPanel:ReloadPanel()
        end
        self.onUpdateWing:Fire(data.crit)
    end
    self.status = 0
end

-- 重置临时翅膀
function WingsManager:Send11604(data)
    self:Send(11604)
end

function WingsManager:On11604(data)
    -- print("接收11604")
    self.onUpdateReset:Fire()
    NoticeManager.Instance:FloatTipsByString(data.msg)

    if self.mainModel.wingModel.wingPanel ~= nil then
        self.mainModel.wingModel.wingPanel.panelList[3].resetButton:ReleaseFrozon()
    end
    if data.result == 1 then
        if self.mainModel.wingModel.wingPanel ~= nil then
            self.mainModel.wingModel.wingPanel:PlayResetSucc()
        end
    end
end

-- 保存临时翅膀
function WingsManager:Send11605(data)
    self:Send(11605)
    self.status = 2
end

function WingsManager:On11605(data)
    -- print("接收11605")
    self.status = 0
    self.onUpdateReset:Fire()
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function WingsManager:Synthesizable()
    local noWings = true
    if RoleManager.Instance.RoleData.lev >= 12 then
        if DataWing.data_base[self.wing_id] ~= nil then     -- 由翅膀
            return false
        end
    else
        noWings = false
    end
    return noWings
end

function WingsManager:Upgradable()
    local next_grade = nil
    local next_lev = nil

    -- inserted by 嘉俊 ：当历练环宝箱未领取时，会显示红点
    if QuestManager.Instance.model.hasTreasureOfChain100 == 1 or QuestManager.Instance.model.hasTreasureOfChain200 == 1 then
        return true
    end
    -- end by 嘉俊

    next_grade,next_lev = self:GetNext(self.grade or 0, self.star)
    if next_grade ~= nil then
        local upgradeData = DataWing.data_upgrade[string.format("%s_%s", next_grade, next_lev)]
        if RoleManager.Instance.RoleData.lev < upgradeData.lev then
            return false
        end
        for _,v in ipairs(upgradeData.need_item) do
            if v[1] < 90000 then
                if BackpackManager.Instance:GetItemCount(v[1]) < v[2] then
                    return false
                end
            else
                if RoleManager.Instance.RoleData:GetMyAssetById(v[1]) < v[2] then
                    return false
                end
            end
        end

        return true
    else
        -- 满级了
        return false
    end
end

function WingsManager:OpenBook(args)
    self.mainModel.wingModel:OpenBook(args)
end

function WingsManager:Send11606()
    self:Send(11606, {})
end

function WingsManager:On11606(data)
    --BaseUtils.dump(data, "接收11606")
    NoticeManager.Instance:FloatTipsByString(data.msg)

    if self.mainModel.wingModel.skillPanel ~= nil then
        -- self.mainModel.wingModel.wingPanel.upgradeButton:ReleaseFrozon()
        self.mainModel.wingModel.skillPanel.resetButton:ReleaseFrozon()
    end
end

function WingsManager:Send11607()
    self:Send(11607, {})
end

function WingsManager:On11607(data)
    -- BaseUtils.dump(data, "接收11607")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function WingsManager:Send11608(data)
    self:Send(11608, {})
end

function WingsManager:On11608(data)
    self.tips_args = data.skills
    self:OpenSkillNotice()
end


--请求翅膀技能方案切换
function WingsManager:Send11609(_valid_plan)
    self:Send(11609, {valid_plan = _valid_plan})
end

--翅膀技能方案切换
function WingsManager:On11609(data)
    -- print('-----------------------收到11609')
    --BaseUtils.dump(data)
    if data.result == 1 then --成功
        if self.model ~= nil then
            self.model:CloseOptionConfirmPanel()
        end
    elseif data.result == 0 then --失败

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function WingsManager:Send11610(_skill, _lev)
    self:Send(11610, {skill = _skill, lev = _lev})
end

--翅膀技能锁定切换
function WingsManager:On11610(data)
    --BaseUtils.dump(data)
    if data.result == 1 then --成功
        if self.mainModel ~= nil and self.mainModel.wingModel ~= nil then
            self.onUpdateReset:Fire()
        end
    elseif data.result == 0 then --失败

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function WingsManager:Send11611(_grade, _skill)
    -- print("Send11611")
    self:Send(11611, {grade = _grade, skill = _skill})
end

function WingsManager:On11611(data)
    -- print("On11611")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.result == 1 then
        local changeValue = 0
        for i=1, #self.break_skills do
            local skill = self.break_skills[i]
            if skill.skill_grade == data.skill_grade and skill.skill_id == data.skill_id then
                changeValue = data.skill_val - skill.skill_val
                skill.skill_lev = data.skill_lev
                skill.skill_val = data.skill_val
            end
        end
        self.onUpdateAwakenSkill:Fire(changeValue)
    end
end

function WingsManager:OpenSkillNotice()
    if self.skillNoticePanel == nil then
        self.skillNoticePanel = WingSkillNoticePanel.New()
    end
    self.skillNoticePanel:Show()
end

function WingsManager:CloseSkillNotice()
    if self.skillNoticePanel ~= nil then
        self.skillNoticePanel:DeleteMe()
        self.skillNoticePanel = nil
    end
end

function WingsManager:OpenSkillPreview()
    if self.skillPreviewPanel == nil then
        self.skillPreviewPanel = WingSkillPreviewPanel.New()
    end
    self.skillPreviewPanel:Show()
end

function WingsManager:CloseSkillPreview()
    if self.skillPreviewPanel ~= nil then
        self.skillPreviewPanel:DeleteMe()
        self.skillPreviewPanel = nil
    end
end

function WingsManager:GetSkillList(grade)
    if self.skillList ~= nil then
        return self.skillList[grade] or {}
    else
        self.skillList = {}
        for k,v in pairs(DataWing.data_skill) do
            if self.skillList[v.need_grade] == nil then
                self.skillList[v.need_grade] = {}
            end
            table.insert(self.skillList[v.need_grade], k)
            -- for i=v.need_grade, self.top_grade do
            -- end
        end
        for k,v in pairs(self.skillList) do
            table.sort(v, function(a,b) return a<b end)
        end
        return self.skillList[grade] or {}
    end
end


function WingsManager:OpenWingInfoWindow(args)
    if self.winginfowindow == nil then
        self.winginfowindow = WingInfoWindow.New(self)
    end
    self.winginfowindow:Open(args)
end

function WingsManager:CloseWingInfoWindow()
    if self.winginfowindow ~= nil then
        WindowManager.Instance:CloseWindow(self.winginfowindow)
        -- self.winginfowindow:DeleteMe()
        -- self.winginfowindow = nil
    end
end

function WingsManager:OpenWingaWakenWindow(args)
    if self.wingaWakenWindow == nil then
        self.wingaWakenWindow = WingaWakenWindow.New(self)
    end
    self.wingaWakenWindow:Show(args)
end

function WingsManager:CloseWingaWakenWindow()
    if self.wingaWakenWindow ~= nil then
        -- WindowManager.Instance:CloseWindow(self.wingaWakenWindow)
        self.wingaWakenWindow:DeleteMe()
        self.wingaWakenWindow = nil
    end
end

function WingsManager:CheckRedPointDic1()
    if self:CheckWakenSkillRedPoint() then
        self.redPointDic[1] = true
    else
        self.redPointDic[1] = false
    end

    if DataWing.data_base[self.wing_id] ~= nil and #self.skill_data < DataWing.data_base[self.wing_id].skill_count then
        self.redPointDic[1] = true
    end

    if self.grade == 0 then
        if BackpackManager.Instance:GetItemCount(21100) > 0 then
            self.redPointDic[4] = true
        else
            self.redPointDic[4] = false
        end
    end
end

function WingsManager:CheckWakenSkillRedPoint()
    local showRedPoint = false
    local break_skill_data = self.break_skills[1]
    if break_skill_data ~= nil then
        if break_skill_data.skill_lev == 0 then
            if not self.hasClickRedPoint then
                showRedPoint = true
            end
        else
            -- print(string.format("%s_%s_%s", self.grade, break_skill_data.skill_id, break_skill_data.skill_lev))
            local data_get_action_break = DataWing.data_get_action_break[string.format("%s_%s_%s", self.grade, break_skill_data.skill_id, break_skill_data.skill_lev)]
            if data_get_action_break == nil then
                return false
            end
            local own = BackpackManager.Instance:GetItemCount(data_get_action_break.uplev_loss[1][1])
            local need = data_get_action_break.uplev_loss[1][2]
            if own >= need then
                showRedPoint = true
            end
        end
    end
    return showRedPoint
end

function WingsManager:CheckSkillRed()
    return self:GetMaxSkillCount(WingsManager.Instance.grade) > #self:GetCurrSkillList()
end

function WingsManager:CheckCollectRed()
    for i=1,#self.wing_groups do
        if self.wing_groups[i] ~= nil and self.wing_groups[i].fullCollected == true and self.wing_groups[i].rewarded == 0 then
            return true
        end
    end
    return false
end

function WingsManager:OpenWindow(args)
    self.model:OpenWindow(args)
end

function WingsManager:GetNext(grade, star)
    if DataWing.data_upgrade[string.format("%s_%s", grade, star + 1)] ~= nil then
        return grade, star + 1
    elseif DataWing.data_upgrade[string.format("%s_%s", grade + 1, 1)] ~= nil then
        return grade + 1, 1
    else
        return nil, nil
    end
end

function WingsManager:GetLevel(grade, star)
    return 0
end

function WingsManager:GetCurrSkillList()
    for _,plan in pairs(self.plan_data or {}) do
        if plan.index == self.valid_plan then
            return plan.skills
        end
    end
    return {}
end


function WingsManager:Send11613(wing_id)
    self:Send(11613, {wing_id = wing_id})
end

function WingsManager:On11613(data)
    BaseUtils.dump(data, "On11613")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function WingsManager:GetMaxSkillCount(grade)
    for _,v in pairs(DataWing.data_base) do
        if v.grade == grade then
            return v.skill_count
        end
    end
    return 0
end


function WingsManager:OpenShow(args)
    self.model:OpenShow(args)
end

function WingsManager:Send11614(speed)
    self:Send(11614, {speed = speed})
end

function WingsManager:On11614(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


function WingsManager:IllusionGroup(ids)
    local bool = false
    for _,id in pairs(ids) do
        bool = bool or self.illusionTab[id] ~= nil and (self.illusionTab[id].timeout == 0 or self.illusionTab[id].timeout >= BaseUtils.BASE_TIME)
    end
    return bool
end

function WingsManager:ActivateGroup(ids)
    local bool = false
    for _,id in pairs(ids) do
        bool = bool or (self.hasGetIds[id] == 1)
    end
    return bool
end

function WingsManager:Send11615(group_id, type)
    self:Send(11615, {group_id = group_id, type = type})
end

function WingsManager:On11615(data)
    BaseUtils.dump(data, "On11615")
    if data.result == 0 then
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
    self.data_on11615 = data
    self.onLottory:Fire(data)
end

function WingsManager:Send11616(group_id, wing_id)
    self:Send(11616, {group_id = group_id, wing_id = wing_id})
end

function WingsManager:On11616(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function WingsManager:OpenTurnplant(args)
    self.model:OpenTurnplant(args)
end

function WingsManager:Send11617()
    self:Send(11617, {})
end

function WingsManager:On11617(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function WingsManager:Send11618(group_id)
    self:Send(11618, {group_id = group_id})
end

function WingsManager:On11618(data)
    if data.result == 1 then
        self.wing_groups[data.group_id].rewarded = 1
        self.onGetReward:Fire(data.group_id)
    end
end




function WingsManager:IsNeedEnergy()
    local bool = false
    for _,skill in pairs(self.skill_data or {}) do
        bool = bool or (DataWing.data_skill_energy[skill.id] ~= nil)
    end
    return bool
end

function WingsManager:ImproveEnergy()
    return self.wing_power < 25
end

function WingsManager:CanLottory()
    for _,group in pairs(self.wing_groups or {}) do
        if group.wing_times > 0 then
            return true
        end
    end
    return false
end

function WingsManager:AutoLottory()
    if self.model.turnplant == nil or self.model.turnplant.isRotating == false then
        for _,group in pairs(self.wing_groups or {}) do
            if group.wing_times > 0 then
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.wings_turnplant, {group_id = group.group_id, rotate = true})
                WingsManager.Instance:Send11615(group.group_id, 1)
                return
            end
        end
    end
end