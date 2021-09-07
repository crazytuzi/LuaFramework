-- ------------------------------------
-- 阵法
-- hosr
-- ------------------------------------
FormationManager = FormationManager or BaseClass(BaseManager)

function FormationManager:__init()
    if FormationManager.Instance then
        return
    end
    FormationManager.Instance = self

    self:InitHandler()

    self.model = FormationModel.New()

    -- 当前阵法id
    self.formationId = 0
    -- 当前阵法等级
    self.formationLev = 1
    -- 当前已学习阵法列表
    self.formationList = {}
    -- 当前上阵守护列表
    self.guardList = {}
    -- 队伍守护列表，组队队长请求
    self.teamGuardList = {}

    self.listener = function() self:Check() end

    self.enoughList = {}
    self.formationCanUp = false

    self.isInitListener = false
end

function FormationManager:__delete()
end

function FormationManager:RequestInitData()
    ShouhuManager.Instance.needGuide = false
    self:Send12900()
    self:Send12902()
    self:Send12908()

    if not self.isInitListener then
        self.isInitListener = true
        EventMgr.Instance:AddListener(event_name.backpack_item_change, self.listener)
    end
end

function FormationManager:InitHandler()
    self:AddNetHandler(12900, self.On12900)
    self:AddNetHandler(12901, self.On12901)
    self:AddNetHandler(12902, self.On12902)
    self:AddNetHandler(12903, self.On12903)
    self:AddNetHandler(12904, self.On12904)
    self:AddNetHandler(12905, self.On12905)
    self:AddNetHandler(12906, self.On12906)
    self:AddNetHandler(12907, self.On12907)
    self:AddNetHandler(12908, self.On12908)

end

-- ---------------------------------
-- 协议处理
-- ---------------------------------
-- 请求自身阵法
function FormationManager:Send12900()
    self:Send(12900, {})
end

function FormationManager:On12900(dat)
    -- BaseUtils.dump(dat, "请求自身阵法")
    self.formationId = dat.id
    self.formationLev = dat.lev
    self.formationList = dat.formation_list
    table.sort(self.formationList, function(a,b)
            if a.lev == b.lev then
                if a.exp == b.exp then
                    return a.id < b.id
                else
                    return a.exp > b.exp
                end
            else
                return a.lev > b.lev
            end
        end)
    EventMgr.Instance:Fire(event_name.formation_update)
end

-- 更换自身阵法(在队伍中则会同步更新队伍)
function FormationManager:Send12901(id)
    self:Send(12901, {id = id})
end

function FormationManager:On12901(dat)
    -- BaseUtils.dump(dat, "更换自身阵法")
    local isChange = false
    if dat.id ~= self.formationId then
        isChange = true
    end
    self.formationId = dat.id
    self.formationLev = dat.lev

    if isChange then
        EventMgr.Instance:Fire(event_name.formation_update)
    end
end

-- 请求自身守护布阵
function FormationManager:Send12902()
    self:Send(12902, {})
end

function FormationManager:On12902(dat)
    self.guardList = dat.guards
    table.sort(self.guardList, function(a,b) return a.number < b.number end)
    EventMgr.Instance:Fire(event_name.guard_position_change, {dat.guards})
end

-- 改变队伍中队员的编号(队长操作/队伍信息广播)"
function FormationManager:Send12903(rid1, pf1, zid1, rid2, pf2, zid2)
    self:Send(12903, {role_id1 = rid1, platform1 = pf1, zone_id1 = zid1, role_id2 = rid2, platform2 = pf2, zone_id2 = zid2})
end

function FormationManager:On12903(dat)
end

-- 改变队伍中守护的编号(队长操作/队伍信息广播)
function FormationManager:Send12904(guard_id1, guard_id2)
    self:Send(12904, {guard_id1 = guard_id1, guard_id2 = guard_id2})
end

function FormationManager:On12904(dat)
    NoticeManager.Instance:FloatTipsByString(dat.msg)
end

-- 改变自身守护的编号
function FormationManager:Send12905(guard_id1, flag, guard_id2)
    self:Send(12905, {guard_id1 = guard_id1, flag = flag, guard_id2 = guard_id2})

    if guard_id1 == 1020 and flag == 1 then
        ShouhuManager.Instance.needGuide = false
    end
end

function FormationManager:On12905(dat)
    if dat.flag == 1 then--成功

    else
        ---失败
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.team)
    end
    NoticeManager.Instance:FloatTipsByString(dat.msg)
end

-- 阵法改变
function FormationManager:On12906(dat)
    self:Send12900()
    EventMgr.Instance:Fire(event_name.formation_levelup, dat)
    NoticeManager.Instance:FloatTipsByString(dat.msg)
end

-- 阵法道具
function FormationManager:Send12907(id, itemid, num)
    self:Send(12907, {id = id, item_id = itemid, num = num})
end

function FormationManager:On12907(dat)
    if dat.msg ~= "" then
        NoticeManager.Instance:FloatTipsByString(dat.msg)
    end
end

-- 请求自身队伍布阵
function FormationManager:Send12908()
    self:Send(12908, {})
end

function FormationManager:On12908(dat)
    --print("!")print("!")print("!")print("!")
    --BaseUtils.dump(dat, "On12908")
    self.teamGuardList = dat.guards
    EventMgr.Instance:Fire(event_name.guard_position_change)
end

-- ------------------------------------------
-- 外部调用接口
-- ------------------------------------------
function FormationManager:GetData(id)
    for i,v in ipairs(self.formationList) do
        if v.id == id then
            return v
        end
    end
    return nil
end

function FormationManager:OpenMain(args)
    self.model:OpenMain(args)
end

-- 守护上下阵接口
function FormationManager:UpDown(guard_id)
    for i,guard in ipairs(self.guardList) do
        if guard.guard_id == guard_id then
            if guard.status == FormationEumn.GuardStatus.Idle then
                -- 空闲变上阵
                self:Send12905(guard.guard_id, 1, 0)
            elseif guard.status == FormationEumn.GuardStatus.Fight then
                -- 上阵变空闲
                self:Send12905(guard.guard_id, 0, 0)
            end
            break
        end
    end
end

function FormationManager:GetFightGuardList()
    local list = {}
    for i,guard in ipairs(self.guardList) do
        if guard.number ~= 0 then
            table.insert(list, guard)
        end
    end
    table.sort(list, function(a,b) return a.number < b.number end)
    return list
end

-- 检查是否材料足够
-- 已学习的判断所有材料，未学习的不判断残卷
function FormationManager:EnoughBook(formationId)
    local has = false
    local lev = 1
    local hasNext = true
    for i,v in ipairs(self.formationList) do
        if v.id == formationId then
            has = true
            lev = v.lev
            break
        end
    end

    local data = DataFormation.data_list[string.format("%s_%s", formationId, lev)]
    if data.next_exp == 0 then
        -- 没有下一个了，,经验满了,无法提升，不需要红点
        return
    end

    for i,v in ipairs(data.need_item) do
        if has or (not has and v.item_id ~= 20060) then
            local count = BackpackManager.Instance:GetItemCount(v.item_id)
            if count > 0 then
                self.formationCanUp = true
                self.enoughList[formationId] = true
            end
        end
    end
end

function FormationManager:Check()
    self.formationCanUp = false
    self.enoughList = {}
    for i = 1, 8 do
        self:EnoughBook(i)
    end
    return self.formationCanUp
end

function FormationManager:GetRestrain(atk)
    if atk == 0 then
        atk = 1
    end
    local atk_data = DataFormation.data_list[string.format("%s_1", tostring(atk))]
    local str = ""
    for i,v in ipairs(atk_data.strong_restrain) do
        if v ~= 1 then
            local fdata = DataFormation.data_list[string.format("%s_1", tostring(v))]
            if fdata ~= nil then
                if str == "" then
                    str = string.format("<color='#ffff00'>%s</color>", fdata.name)
                else
                    str = string.format("%s、<color='#ffff00'>%s</color>", str, fdata.name)
                end
            end
        end
    end
    for i,v in ipairs(atk_data.weak_restrain) do
        if v ~= 1 then
            local fdata = DataFormation.data_list[string.format("%s_1", tostring(v))]
            if fdata ~= nil then
                if str == "" then
                    str = string.format("<color='#00ff00'>%s</color>", fdata.name)
                else
                    str = string.format("%s、<color='#00ff00'>%s</color>", str, fdata.name)
                end
            end
        end
    end
    return str == "" and TI18N("无") or str
end
