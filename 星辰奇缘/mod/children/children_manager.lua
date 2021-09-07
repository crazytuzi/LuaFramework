-------------------关于拖动 子女系统manager
-- hzf
-- 2017年01月04日15:23:46

ChildrenManager = ChildrenManager or BaseClass(BaseManager)


function ChildrenManager:__init()
    if ChildrenManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end

    ChildrenManager.Instance = self

    self.model = ChildrenModel.New()
    self.childData = {}
    self.childNoticeData = {}
    self.quickShowChildData = nil
    self.max_childNum = 0
    self:InitHandler()

    self.OnChildDataUpdate = EventLib.New() -- 孩子数据更新
    self.OnChildAttrUpdate = EventLib.New() -- 孩子属性更新
    self.OnChildSkillUpdate = EventLib.New() -- 孩子技能更新
    self.OnChildEquipUpdate = EventLib.New() -- 孩子装备更新
    self.OnChildPointUpdate = EventLib.New() -- 孩子加点更新
    self.OnChildTelentUpdate = EventLib.New() -- 孩子天赋更新
    self.OnChildStudyUpdate = EventLib.New() -- 孩子学习情况更新
    self.OnChildClassesUpdate = EventLib.New() -- 孩子职业更新
    self.OnChildEggUpdate = EventLib.New() -- 孩子孕育值途径更新
    self.OnChildNoviceUpdate = EventLib.New() -- 孩子孕育值途径更新
end

function ChildrenManager:__delete()
end

function ChildrenManager:Share(channel, childData)
    -- NoticeManager.Instance:FloatTipsByString(TI18N("暂未开放"))

    ChatManager.Instance:Send10420(childData.child_id, childData.platform, childData.zone_id)
    local roleData = RoleManager.Instance.RoleData
    local name = string.format(TI18N("%s的子女"), self:GetChildName(childData))

    if channel == MsgEumn.ChatChannel.World or channel == MsgEumn.ChatChannel.Guild then
        ChatManager.Instance.model:ShowChatWindow({channel})
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.pet)

        local element = {}
        element.type = MsgEumn.AppendElementType.Child
        element.id = childData.index
        element.base_id = childData.base_id
        element.child_id = childData.child_id
        element.cacheType = MsgEumn.CacheType.Child
        element.showString = string.format("[%s]", name)
        element.sendString = string.format("{child_2,%s}", childData.base_id)
        element.matchString = string.format("%%[%s%%]", name)

        LuaTimer.Add(500, function() ChatManager.Instance:AppendInputElement(element, MsgEumn.ExtPanelType.Chat) end)
    elseif channel == MsgEumn.ChatChannel.Private then
        local callBack = function(_, friendData)
            local sendData = string.format("{child_1, %s, %s, %s, %s, %s, %s}", roleData.platform, roleData.zone_id, ChatManager.Instance.childCache[0], childData.base_id, name, childData.growth_type)
            FriendManager.Instance:SendMsg(friendData.id, friendData.platform, friendData.zone_id, sendData)
            NoticeManager.Instance:FloatTipsByString(TI18N("分享成功"))
        end
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.friendselect, { callBack })
    end
end

function ChildrenManager:GetChildName(child)
    local name = RoleManager.Instance.RoleData.name
    if #child.parents > 1 then
        local parent = child.parents[1]
        local roleData = RoleManager.Instance.RoleData
        if parent.parent_id == roleData.lover_id and parent.p_platform == roleData.lover_platform and parent.p_zone_id == roleData.lover_zone_id then
            name = string.format(TI18N("%s和%s"), RoleManager.Instance.RoleData.name, roleData.lover_name)
        end

        parent = child.parents[2]
        if parent.parent_id == roleData.lover_id and parent.p_platform == roleData.lover_platform and parent.p_zone_id == roleData.lover_zone_id then
            name = string.format(TI18N("%s和%s"), RoleManager.Instance.RoleData.name, roleData.lover_name)
        end
    end

    return name
end

function ChildrenManager:GetFather(child)
    for i,v in ipairs(child.parents) do
        if v.sex == 1 then
            return v
        end
    end
    return nil
end

function ChildrenManager:GetMother(child)
    for i,v in ipairs(child.parents) do
        if v.sex == 0 then
            return v
        end
    end
    return nil
end

function ChildrenManager:GetFather(child)
    for i,v in ipairs(child.parents) do
        if v.sex == 1 then
            return v
        end
    end
    return nil
end

function ChildrenManager:GetMother(child)
    for i,v in ipairs(child.parents) do
        if v.sex == 0 then
            return v
        end
    end
    return nil
end

-- 获取某个孩子数据
-- platform和zone_id没用，因为可能是合服之后生的孩子
function ChildrenManager:GetChild(id, platform, zone_id)
    for i,v in ipairs(self.childData) do
        if v.child_id == id and BaseUtils.IsTheSamePlatform(v.platform, v.zone_id) then
            return v
        end
    end
    return nil
end

-- 获取胎儿数据
function ChildrenManager:GetFetus()
    for i,v in ipairs(self.childData) do
        if v.stage == ChildrenEumn.Stage.Fetus then
            return v
        end
    end
    return nil
end

-- 获取幼年期孩子数据
function ChildrenManager:GetChildhood()
    for i,v in ipairs(self.childData) do
        if v.stage == ChildrenEumn.Stage.Childhood then
            return v
        end
    end
    return nil
end

-- 获取成年期孩子数据
function ChildrenManager:GetChildAdult()
    local list = {}
    for i,v in ipairs(self.childData) do
        if v.stage == ChildrenEumn.Stage.Adult then
            table.insert(list, v)
        end
    end
    return list
end

-- 获取当前资质成长的比例
function ChildrenManager:GetAptRatio(step, val)
    for i,v in ipairs(DataChild.data_apt_ratio) do
        if step >= v.min_val and step <= v.max_val then
            local min = Mathf.Round(val * (v.ratio_min / 1000))
            local max = Mathf.Round(val * (v.ratio_max / 1000))
            return min, max
        end
    end
    return 0,0
end

-- 获取怀孕期期孩子数据
function ChildrenManager:GetChildFetus()
    for i,v in ipairs(self.childData) do
        if v.stage == ChildrenEumn.Stage.Fetus then
            return v
        end
    end
    return nil
end

-- 按类型格式技能数据
function ChildrenManager:FormatSkillType()
    self.lowSkills = {}
    self.highSkills = {}
    for i,v in ipairs(DataChild.data_allow_skills) do
        if v.skill_type == 2 then
            table.insert(self.highSkills, v)
        else
            table.insert(self.lowSkills, v)
        end
    end
end

function ChildrenManager:GetSkillLow()
    if self.lowSkills == nil then
        self:FormatSkillType()
    end
    return self.lowSkills or {}
end

function ChildrenManager:GetSkilHigh()
    if self.highSkills == nil then
        self:FormatSkillType()
    end
    return self.highSkills or {}
end

function ChildrenManager:InitHandler()
    -- 最好是把所有的回调函数在连接之前全部添加
    -- 除非你很确定那些协议不会在连接后立即发送过来
    self:AddNetHandler(18600, self.On18600)
    self:AddNetHandler(18601, self.On18601)
    self:AddNetHandler(18602, self.On18602)
    self:AddNetHandler(18603, self.On18603)
    self:AddNetHandler(18604, self.On18604)
    self:AddNetHandler(18605, self.On18605)
    self:AddNetHandler(18606, self.On18606)
    self:AddNetHandler(18607, self.On18607)
    self:AddNetHandler(18608, self.On18608)
    self:AddNetHandler(18609, self.On18609)
    self:AddNetHandler(18610, self.On18610)

    self:AddNetHandler(18611, self.On18611)
    self:AddNetHandler(18612, self.On18612)
    self:AddNetHandler(18613, self.On18613)
    self:AddNetHandler(18614, self.On18614)
    self:AddNetHandler(18615, self.On18615)
    self:AddNetHandler(18616, self.On18616)
    self:AddNetHandler(18617, self.On18617)
    self:AddNetHandler(18618, self.On18618)
    self:AddNetHandler(18619, self.On18619)
    self:AddNetHandler(18620, self.On18620)
    self:AddNetHandler(18621, self.On18621)
    self:AddNetHandler(18622, self.On18622)
    self:AddNetHandler(18623, self.On18623)
    self:AddNetHandler(18624, self.On18624)
    self:AddNetHandler(18625, self.On18625)
    self:AddNetHandler(18626, self.On18626)
    self:AddNetHandler(18627, self.On18627)
    self:AddNetHandler(18628, self.On18628)
    self:AddNetHandler(18629, self.On18629)
    self:AddNetHandler(18630, self.On18630)
    self:AddNetHandler(18631, self.On18631)
    self:AddNetHandler(18632, self.On18632)
    self:AddNetHandler(18635, self.On18635)
    self:AddNetHandler(18636, self.On18636)
    self:AddNetHandler(18639, self.On18639)
    self:AddNetHandler(18640, self.On18640)
    self:AddNetHandler(18641, self.On18641)
    self:AddNetHandler(10246, self.On10246)
    self:AddNetHandler(18642, self.On18642)
    self:AddNetHandler(18643, self.On18643)
end

function ChildrenManager:ReqOnReConnect()
    self:Require18600()
end

-- 请求所有孩子数据
function ChildrenManager:Require18600()
    self:Send(18600,{})
end

function ChildrenManager:On18600(data)
    -- BaseUtils.dump(data,"子女信息==============================================================================================================================")
    self.childData = {}
    self.childNoticeData = {}
    self.max_childNum = data.child_nums

    for i,v in ipairs(data.child_list) do
        local child_data = ChildrenData.New()
        child_data:SetProto(v)
        table.insert(self.childData, child_data)
        table.sort(child_data.talent_skills, function(a,b) return a.grade < b.grade end)

        if child_data.stage == ChildrenEumn.Stage.Adult
            and child_data.pre_str == 0
            and child_data.pre_con == 0
            and child_data.pre_mag == 0
            and child_data.pre_agi == 0
            and child_data.pre_end == 0
            then
            self:Require18612(child_data.child_id, child_data.platform, child_data.zone_id)
        end
        if child_data.stage == 2 and child_data.maturity == 100 then
            LuaTimer.Add(5000, function()
                self:Require18628(child_data.child_id, child_data.platform, child_data.zone_id)
            end)
        end
    end
    if data.hungry_notice_lev ~= nil and next(data.hungry_notice_lev) ~= nil then
         for _,v in pairs(data.hungry_notice_lev) do
            local childNoviceData = {};
            childNoviceData.lev = v.n_lev
            childNoviceData.child_id = v.n_child_id
            childNoviceData.platform = v.n_platform
            childNoviceData.zone_id = v.n_zone_id
            table.insert(self.childNoticeData, childNoviceData)
        end
    end
    self.OnChildDataUpdate:Fire()
end

-- 子女基础更新推送
function ChildrenManager:Require18601()
end

function ChildrenManager:On18601(data)
    -- BaseUtils.dump(data,"18601111111111111111111111111")
    for i,v in ipairs(data.child_list) do
        local child = self:GetChild(v.child_id, v.platform, v.zone_id)
        if child ~= nil then
            if child.stage == 1 and v.stage == 2 then
                local getbaby =  DramaGetBaby.New()
                local action = DramaAction.New()
                action.sex = v.sex
                getbaby:Show(action)
            -- elseif child.stage == 2 and v.stage == 3 then
                -- ChildrenManager.Instance.model:OpenGetBoyPanel({sex = child.sex, classes = child.classes})
            end
            child:SetProto(v)
            if child.maturity == 100 then
                self:Require18628(child.child_id, child.platform, child.zone_id)
            end
        else
            if v.stage == 2 then
                local getbaby =  DramaGetBaby.New()
                local action = DramaAction.New()
                action.sex = v.sex
                getbaby:Show(action)
            end
            local newchild = ChildrenData.New()
            newchild:SetProto(v)
            table.insert(self.childData, newchild)
        end
    end

    self.OnChildDataUpdate:Fire()
end

-- 子女删除推送
function ChildrenManager:Require18602()
end

function ChildrenManager:On18602(data)
    -- BaseUtils.dump(data,"18601eeeeeeeeeeeeeeeeeeeeeee1")
    local newList = {}
    for i,child in ipairs(self.childData) do
        local isDel = false
        for j,del in ipairs(data.abandons) do
            if child.child_id == del.id and child.platform == del.platform and child.zone_id == del.zone_id then
                isDel = true
            end
        end

        if not isDel then
            table.insert(newList, child)
        end
    end
    self.childData = newList

    self.OnChildDataUpdate:Fire()
end

-- 子女属性更新
function ChildrenManager:Require18603()
end

function ChildrenManager:On18603(data)
    -- BaseUtils.dump(data,"18601333333333333333333333333333333")
    for i,v in ipairs(data.child_list) do
        local child = self:GetChild(v.child_id, v.platform, v.zone_id)
        if child ~= nil then
            child:SetProto(v)
        end
    end

    self.OnChildAttrUpdate:Fire()
end

-- 子女技能更新
function ChildrenManager:Require18604()
end

function ChildrenManager:On18604(data)
-- BaseUtils.dump(data, "========================= 18604")
    for i,v in ipairs(data.child_list) do
        local child = self:GetChild(v.child_id, v.platform, v.zone_id)
        if child ~= nil then
            child.skills = v.skills
        end
    end

    self.OnChildSkillUpdate:Fire()
end

-- 子女装备更新
function ChildrenManager:Require18605()
end

function ChildrenManager:On18605(data)
    -- BaseUtils.dump(data, "========================= 18605")
    for i,v in ipairs(data.child_list) do
        local child = self:GetChild(v.child_id, v.platform, v.zone_id)
        if child ~= nil then
            child.stones = v.stones
        end
    end

    self.OnChildEquipUpdate:Fire()
end

-- 子女杂项更新
function ChildrenManager:Require18606()
end

function ChildrenManager:On18606(data)
    -- BaseUtils.dump(data, "========================= 18606")
    for i,v in ipairs(data.child_list) do
        local child = self:GetChild(v.child_id, v.platform, v.zone_id)
        if child ~= nil then
            child.hungry = v.hungry
            child.status = v.status
            child.follow_id = v.follow_id
            child.f_platform = v.f_platform
            child.f_zone_id = v.f_zone_id
            child.name = v.name
            child.lev = v.lev
            child.name_changed = v.name_changed
        end
    end

    self.OnChildDataUpdate:Fire()
end

-- 子女天赋技能更新
function ChildrenManager:Require18607()
end

function ChildrenManager:On18607(data)
    -- BaseUtils.dump(data, "========================= 18607")
    for i,v in ipairs(data.child_list) do
        local child = self:GetChild(v.child_id, v.platform, v.zone_id)
        if child ~= nil then
            child.talent_skills = v.talent_skills
            table.sort(child.talent_skills, function(a,b) return a.grade < b.grade end)
        end
    end
    self.OnChildTelentUpdate:Fire()
end

-- 子女属性更新(幼儿期)
function ChildrenManager:Require18608()
end

function ChildrenManager:On18608(data)
    -- BaseUtils.dump(data, "88888888888888888888")
    for i,v in ipairs(data.child_list) do
        local child = self:GetChild(v.child_id, v.platform, v.zone_id)
        if child ~= nil then
            child:UpdateStudy(v)
            if child.stage == 2 and child.maturity == 100 then
                self:Require18628(child.child_id, child.platform, child.zone_id)
            end
            -- if child.stage == 2 and child.maturity == 100 then
            --     WindowManager.Instance:CloseWindowById(WindowConfig.WinID.child_study_win)
            --     -- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.pet, {4})
            --     ChildrenManager.Instance.model:OpenGetBoyPanel({sex = child.sex, classes = child.classes, base_id = child.base_id, name = child.name, data = data, childData = child})
            -- end
        end
    end

    self.OnChildStudyUpdate:Fire()
end

-- 子女接生

function ChildrenManager:Require18609()
    self:Send(18609, {})
end

function ChildrenManager:On18609(data)
    if data.flag == 1 then

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 阶段变化
function ChildrenManager:Require18610()
end

function ChildrenManager:On18610(data)
    -- BaseUtils.dump(data, "========================= 18610")
    local child = self:GetChild(data.child_id, data.platform, data.zone_id)
    if child ~= nil then
        child.base_id = data.base_id
        child.classes = data.classes
        child.sex = data.sex
        child.stage = data.stage
    end

    if child.stage == 3 then
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.child_study_win)
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.pet)
        -- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.pet, {4})
        ChildrenManager.Instance.model:OpenGetBoyPanel({sex = child.sex, classes = child.classes, base_id = child.base_id, name = child.name, data = data, childData = child})
        self:Require18612(child.child_id, child.platform, child.zone_id)
    end
end

-- 设置加点方案
function ChildrenManager:Require18611(data)
    local aa = {id = data.id, platform = data.platform, zone_id = data.zone_id, strength = data.info[2], constitution = data.info[1], magic = data.info[3], agility = data.info[4], endurance = data.info[5]}
    -- BaseUtils.dump(aa, "186111111111")
    self:Send(18611, aa)
end

function ChildrenManager:On18611(data)
    -- BaseUtils.dump(data,"On18611")
    NoticeManager.Instance:FloatTipsByString(data.msg)

    if data.result == 1 then
        local child = self:GetChild(data.child_id, data.platform, data.zone_id)
        if child ~= nil then
            child:UpdataPointSetting(data)
        end
        self.OnChildPointUpdate:Fire()
    end
end

-- 请求加点方案
function ChildrenManager:Require18612(id, platform, zone_id)
    self:Send(18612, {id = id, platform = platform, zone_id = zone_id})
end

function ChildrenManager:On18612(data)
    -- BaseUtils.dump(data,"On18612")
    local child = self:GetChild(data.id, data.platform, data.zone_id)
    if child ~= nil then
        child:UpdataPointSetting(data)
    end
    self.OnChildPointUpdate:Fire()
end

-- 子女任务结果推送
function ChildrenManager:On10246(data)
    -- BaseUtils.dump(data,"On10246")
    -- self.model:OpenNoticePanel(data)
    if data.flag == 2 and data.mode == 2 then
        LuaTimer.Add(4000, function()
            self.model:OpenNoticeResultPanel(data)
        end)
    else
        self.model:OpenNoticeResultPanel(data)
    end
end

-- 孩子符石洗练
function ChildrenManager:Require18613(id, platform, zone_id, item_id)
    self:Send(18613, {id = id, platform = platform, zone_id = zone_id, item_id = item_id})
end

function ChildrenManager:On18613(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 孩子符石保存洗练
function ChildrenManager:Require18614(id, platform, zone_id, item_id)
    self:Send(18614, {id = id, platform = platform, zone_id = zone_id, item_id = item_id})
end

function ChildrenManager:On18614(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 孩子符石刻印
function ChildrenManager:Require18615(id, platform, zone_id, item_id, stone_id)
    self:Send(18615, {id = id, platform = platform, zone_id = zone_id, item_id = item_id, stone_id = stone_id})
end

function ChildrenManager:On18615(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 孩子使用符石
function ChildrenManager:Require18616(id, platform, zone_id, item_id, hole_id)
    local data = {id = id, platform = platform, zone_id = zone_id, item_id = item_id, hole_id = hole_id}
    -- BaseUtils.dump(data, "161616161616161616161")
    self:Send(18616, data)
end

function ChildrenManager:On18616(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 孩子进阶
function ChildrenManager:Require18617(id, platform, zone_id)
    local data = {id = id, platform = platform, zone_id = zone_id}
    -- BaseUtils.dump(data, "171717171717171717117")
    self:Send(18617, data)
end

function ChildrenManager:On18617(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        local child = self:GetChild(data.child_id, data.platform, data.zone_id)
        if child ~= nil then
            child.grade = data.grade
        end
        self.OnChildDataUpdate:Fire()
    end
end

-- 孩子快捷学习技能
function ChildrenManager:Require18618(id, platform, zone_id, base_id)
    self:Send(18618, {id = id, platform = platform, zone_id = zone_id, base_id = base_id})
end

function ChildrenManager:On18618(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 使用道具(技能书/资质上限/饱食度/成长/属性点)
function ChildrenManager:Require18619(id, platform, zone_id, item_id)
    local data = {id = id, platform = platform, zone_id = zone_id, item_id = item_id}
    -- BaseUtils.dump(data, "186191919191919191")
    self:Send(18619, data)
end

function ChildrenManager:On18619(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 孩子学习天赋技能
function ChildrenManager:Require18620(id, platform, zone_id, item_base_id, grade)
    local data = {id = id, platform = platform, zone_id = zone_id, item_base_id = item_base_id, grade = grade}
    -- BaseUtils.dump(data, "1862020202020202020220")
    self:Send(18620, data)
end

function ChildrenManager:On18620(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 孩子选择职业
function ChildrenManager:Require18621(id, platform, zone_id, classes)
    local data = {id = id, platform = platform, zone_id = zone_id, classes = classes}
    -- BaseUtils.dump(data, "212121212121")
    self:Send(18621, data)
end

function ChildrenManager:On18621(data)
    -- BaseUtils.dump(data, "18621")
    NoticeManager.Instance:FloatTipsByString(data.msg)

    local child = self:GetChild(data.child_id, data.platform, data.zone_id)
    if child ~= nil then
        child.classes = data.classes
        child.base_id = data.base_id
    end

    self.OnChildClassesUpdate:Fire()
end

-- 孩子切换职业类型
function ChildrenManager:Require18622(id, platform, zone_id, classes_type)
    local data = {id = id, platform = platform, zone_id = zone_id, classes_type = classes_type}
    -- BaseUtils.dump(data, "22222222222222222222")
    self:Send(18622, data)
end

function ChildrenManager:On18622(data)
    -- BaseUtils.dump(data, "18622")
    NoticeManager.Instance:FloatTipsByString(data.msg)

    if data.flag == 1 then
        local child = self:GetChild(data.child_id, data.platform, data.zone_id)
        if child ~= nil then
            child.classes_type = data.classes_type
        end

        if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.None or TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
            self.model:OpenChooseClasses()
        end
        self.OnChildClassesUpdate:Fire()
    end
end

-- 孩子学习课程
function ChildrenManager:Require18623(id, platform, zone_id, study_type, study_mode)
    local data = {id = id, platform = platform, zone_id = zone_id, study_type = study_type, study_mode = study_mode}
    -- BaseUtils.dump(data, "18623")
    self:Send(18623, data)
end

function ChildrenManager:On18623(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 孩子跟随/取消跟随  0:取消, 1:跟随
function ChildrenManager:Require18624(id, platform, zone_id, follow)
    local data = {id = id, platform = platform, zone_id = zone_id, follow = follow}
    -- BaseUtils.dump(data, "242424242424242424")
    self:Send(18624, data)
end

function ChildrenManager:On18624(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 孩子升级天赋技能
function ChildrenManager:Require18625(id, platform, zone_id, item_base_id)
    local data = {id = id, platform = platform, zone_id = zone_id, item_base_id = item_base_id}
    -- BaseUtils.dump(data, "185252525252525252")
    self:Send(18625, data)
end

function ChildrenManager:On18625(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 孕育值触发记录
function ChildrenManager:Require18626()
    self:Send(18626, {})
end

function ChildrenManager:On18626(data)
    -- BaseUtils.dump(data, "孕育值触发记录!!!!!!!!!!!!!!")
    self.eggData = data
    self.OnChildEggUpdate:Fire()
end

-- 请求所有孩子数据
function ChildrenManager:Require18627()
end

function ChildrenManager:On18627(data)
end

-- 确定进入成长期
function ChildrenManager:Require18628(id, platform, zone_id)
    self:Send(18628, {id = id, platform = platform, zone_id = zone_id})
end

function ChildrenManager:On18628(data)
    -- BaseUtils.dump(data, "孕育值触发记录!!!!!!!!!!!!!!")
    -- self.eggData = data
    -- self.OnChildEggUpdate:Fire()
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 子女改名
function ChildrenManager:Require18629(id, platform, zone_id, name)
    local data = {id = id, platform = platform, zone_id = zone_id, name = name}
    -- BaseUtils.dump(data, "dddddddddddddddddddddddddd")
    self:Send(18629, data)
end

function ChildrenManager:On18629(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


-- 子女抛弃
function ChildrenManager:Require18630(id, platform, zone_id)
    local data = {id = id, platform = platform, zone_id = zone_id}
    -- BaseUtils.dump(data, "dddddddddddddddddddddddddd")
    self:Send(18630, data)
end

function ChildrenManager:On18630(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


-- 子女抛弃通知
function ChildrenManager:Require18631(id, platform, zone_id, name)
    local data = {id = id, platform = platform, zone_id = zone_id, name = name}
    -- BaseUtils.dump(data, "dddddddddddddddddddddddddd")
    self:Send(18631, data)
end

function ChildrenManager:On18631(data)
    local childname = data.name
    if data.name == "" then
        childname = TI18N("胎儿")
    end
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = string.format(TI18N("是否同意<color='#ffff00'>托管</color>子女：%s？（托管后子女将被送往精灵乐园，<color='#ffff00'>无法找回</color>）"), childname)
    data.sureLabel = TI18N("同意")
    data.cancelLabel = TI18N("不同意")
    data.sureCallback = function()
            self:Require18632(1)
        end
    data.cancelCallback = function()
            self:Require18632(0)
        end
    NoticeManager.Instance:ConfirmTips(data)

end


-- 子女确认
function ChildrenManager:Require18632(decision)
    local data = {decision = decision}
    -- BaseUtils.dump(data, "dddddddddddddddddddddddddd")
    self:Send(18632, data)
end

function ChildrenManager:On18632(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 更改学习计划
function ChildrenManager:Require18635(child_id, platform, zone_id, info)
    local data = {child_id = child_id, platform = platform, zone_id = zone_id}
    data.study_str_plan_easy = info.study_str_plan_easy
    data.study_con_plan_easy = info.study_con_plan_easy
    data.study_agi_plan_easy = info.study_agi_plan_easy
    data.study_mag_plan_easy = info.study_mag_plan_easy
    data.study_end_plan_easy = info.study_end_plan_easy
    data.study_str_plan_hard = info.study_str_plan_hard
    data.study_con_plan_hard = info.study_con_plan_hard
    data.study_agi_plan_hard = info.study_agi_plan_hard
    data.study_mag_plan_hard = info.study_mag_plan_hard
    data.study_end_plan_hard = info.study_end_plan_hard
    -- BaseUtils.dump(data, "ssssssssssssss 35353353")
    self:Send(18635, data)
end

function ChildrenManager:On18635(data)
    NoticeManager.Instance:FloatTipsByString(data.reason)
end

-- 重置学习
function ChildrenManager:Require18636(child_id, platform, zone_id)
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = TI18N("<color='#ffff00'>重置</color>后将返还所有<color='#ffff00'>课程次数</color>，已学[基础课程]可免费学习，[高级课程]只返还<color='#ffff00'>50%</color>材料，是否重置？")
    data.sureLabel = TI18N("重置")
    data.cancelLabel = TI18N("取消")
    data.sureCallback = function() self:Send(18636, {child_id = child_id, platform = platform, zone_id = zone_id}) end
    NoticeManager.Instance:ConfirmTips(data)
end

function ChildrenManager:On18636(data)
    NoticeManager.Instance:FloatTipsByString(data.reason)
end

function ChildrenManager:CheckCanLearn()
    for i,v in pairs(self.childData) do
        if v.stage == ChildrenEumn.Stage.Childhood and (v.day_easy < 2 or os.date("%d", v.study_easy_time) ~= os.date("%d", BaseUtils.BASE_TIME)) and v.study_easy < 25 then
            for ii = 1,5 do
                local key = string.format("%s_%s", ii, "1")
                local studyData = DataChild.data_study[key]
                if studyData.study_time - (BaseUtils.BASE_TIME - v.study_easy_time) <= 0 then
                    return true
                end
            end
        end
    end
    return false
end

-- 获取某个孩子快乐值提醒数据
function ChildrenManager:GetChildNovice(id, platform, zone_id)
    if #self.childNoticeData == 0 then
      return nil
    end
    for i,v in pairs(self.childNoticeData) do
        if v.child_id == id and v.platform == platform and v.zone_id == zone_id then
            return v
        end
    end
    return nil
end

--根据快乐值获取子女快乐数据
function ChildrenManager:GetHappinessByHugry(hugry)
    local rec = nil
    if self.happyList == nil then
       self.happyList = DataChild.data_child_happiness
    end
    for key,val in pairs(self.happyList) do
        if hugry >= val.min_val and  hugry <= val.max_val then
            rec = val
            break
        end
    end
    return rec
end

function ChildrenManager:SendChangeRemind(child_id,platform,zone_id,index)
    local data = {id = child_id, platform = platform, zone_id = zone_id, lev = index}
    self:Send(18639, data)
end
function ChildrenManager:On18639(data)
     local msg = data.msg
     if data.flag == 1 then
        local noviceNum = ChildrenEumn.ChildrenHungryNovice[data.lev]
        if noviceNum > 0 then
          msg = string.format(TI18N("设置成功，子女心情<color='#ffff00'>低于%s</color>会自动提醒"),noviceNum)
        else
            msg = string.format(TI18N("设置成功"))
        end
        local child = self:GetChildNovice(data.id, data.platform, data.zone_id)
        if child ~= nil then
            child.lev = data.lev
        else
            child = {}
            child.lev = data.lev
            child.child_id = data.id
            child.platform = data.platform
            child.zone_id = data.zone_id
            table.insert(self.childNoticeData, child)
        end
        self.OnChildNoviceUpdate:Fire()
    end
      NoticeManager.Instance:FloatTipsByString(msg)
end

function ChildrenManager:Require18640(data)
    BaseUtils.dump(data,"传入的数据")
    Connection.Instance:send(18640,data)
end

function ChildrenManager:On18640(data)

    NoticeManager.Instance:FloatTipsByString(data.msg)

    if data.flag == 1 then
        local childData = {mainChildData = PetManager.Instance.model.tempSpirtMainChildData, spritPetData = PetManager.Instance.model.tempSpirtSubPetData }
        BaseUtils.dump(childData,"孩子模型数据协议回调===========================================================")
        PetManager.Instance.model:OpenChildSpiritSuccessPanel(childData)
    end
end

function ChildrenManager:Require18641(petId)

    local data = {attach_pet_id = petId}
    BaseUtils.dump(data,"发送协议==========================================================================")
    Connection.Instance:send(18641,data)
end

function ChildrenManager:On18641(data)
    BaseUtils.dump(data, "接收协议==========================================================================================")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        ChildrenManager.Instance.OnChildDataUpdate:Fire()
         PetManager.Instance.OnUpdatePetList:Fire()
        -- LuaTimer.Add(200, function()
        --         PetManager.Instance.OnUpdatePetList:Fire()
        --     end)
    end
end

function ChildrenManager:Send18642(id,platform,zone_id,skin_id)
    local data = {id = id ,platform = platform,zone_id = zone_id,skin_id = skin_id}
    Connection.Instance:send(18642,data)
end

function ChildrenManager:On18642(data)
    -- BaseUtils.dump(data,"On18642()")
    -- if data.flag == 1 or data.flag == 2 then
    NoticeManager.Instance:FloatTipsByString(data.msg)
    -- end
    if data.flag == 1 then
        if PetManager.Instance.model.childSkinWindow ~= nil and not BaseUtils.isnull(PetManager.Instance.model.childSkinWindow.gameObject) then
            PetManager.Instance.model.childSkinWindow:OpenGetChildWindow()
        end
    end
end

function ChildrenManager:Send18643(id,platform,zone_id,skin_id)
    local data = {id = id ,platform = platform,zone_id = zone_id,skin_id = skin_id}
    Connection.Instance:send(18643,data)
end

function ChildrenManager:On18643(data)
    -- BaseUtils.dump(data,"On18643()")
    if data.flag == 1 then
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
end

