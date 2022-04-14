---
--- Created by  Administrator
--- DateTime: 2019/6/3 10:04
---
MarryModel = MarryModel or class("MarryModel", BaseBagModel)
local MarryModel = MarryModel

function MarryModel:ctor()
    MarryModel.Instance = self
    self:Reset()
end

--- 初始化或重置
function MarryModel:Reset()
    self.mineInfo = nil
    self.selectTags = {}
    self.marriageStep = {}
    self.withMarry = nil
    self.appointmentInfos = {}
    self.myAppointment = {}
    self.guestList = {}
    self.weddingInfo = nil
    self.proposalInfo = {}
    self.has_marry = false
    self.hotReward = {}
    self.curHot = 0
    self.appointmentTimes = 0  --预约次数
    self.guestSouList = {}  --宾客索要列表
    self.has_request = false
    self.isShowMatchIcon = false
    self.isAppointment = false

    self.redPoints = {}
end

function MarryModel:GetInstance()
    if MarryModel.Instance == nil then
        MarryModel()
    end
    return MarryModel.Instance
end

function MarryModel:GetTagList()
    local cfg = Config.db_dating_tag
    local list = {}
    for i, v in pairs(cfg) do
        list[v.groupid] = list[v.groupid] or {}
        table.insert(list[v.groupid], v)
    end
    return list
end

function MarryModel:GetTagName(groupid)
    local cfg = Config.db_dating_tag
    local name = ""
    for i, v in pairs(cfg) do
        if groupid == v.groupid then
            name = v.group
            break
        end
    end
    return name
end

function MarryModel:isMyTagsShow(id)
    for i = 1, #self.selectTags do
        if self.selectTags[i] == id then
            return true
        end
    end
    return false
end

--结婚三步走是否开启
function MarryModel:IsOpenThreeAct()
    if #self.marriageStep < 3 then
        return true
    end
    local isOpend = false
    for i, v in pairs(self.marriageStep) do
        if v.state ~= 3 then
            isOpend = true
        end
    end

    return isOpend
end

--是否结婚
function MarryModel:IsMarry()
    local role = RoleInfoModel.GetInstance():GetMainRoleData()
    return role.marry ~= 0
end

--戒指功能是否开启
function MarryModel:IsRingAct()
    --local config = GetOpenLink(1200, 2)
    --if not config then
    --    return false
    --end
    --
    --local main_role_data = RoleInfoModel:GetInstance():GetMainRoleData()
    --
    --if config.level and main_role_data.level < config.level then
    --   -- local str = "该功能" .. config.level .. "级开启"
    --   -- Notify.ShowText(str)
    --    return false
    --end
    --if config.task and not TaskModel:GetInstance():IsFinishMainTask(config.task) then
    --    --local name = Config.db_task[config.task].name
    --   -- local str = "请先完成" .. name .. "任务"
    --  --  Notify.ShowText(str)
    --    return false
    --end
    --
    --return true
    if not OpenTipModel.GetInstance():IsOpenSystem(1200, 2) then
        --Notify.ShowText("该功能尚未开启")
        return false
    end

    return true
end

--获取结婚三不走的当前步骤
function MarryModel:GetCurThree()
    for i = 1, #self.marriageStep do
        if self.marriageStep[i].state == 1 then
            return self.marriageStep[i].id
        end
    end
    return 3
end

--
function MarryModel:GetThreeActState(id)
    --for i, v in pairs(self.marriageStep) do
    --    if v.id  == id then
    --        return v.state
    --    end
    --end
    --return 4
    for i = 1, #self.marriageStep do
        if i == id then
            if id ~= 1 then
                local lastId = id - 1
                if self.marriageStep[lastId].state == 1 then
                    return 4
                end

            end
            return self.marriageStep[i].state
        end
    end
    return 4
end

function MarryModel:GetFlowerNum(id)
    local tab = self.mineInfo.flowers
    local num = 0
    for i, v in pairs(tab) do
        if i == id then
            num = v
        end
    end
    return num
end

function MarryModel:IsMarryNpc(npcId)
    local id = self.GetNpc()
    local role = RoleInfoModel.GetInstance():GetMainRoleData()
    local cfg = String2Table(Config.db_marriage["level"].val)
    local nLv = cfg[1]
    if npcId == id and role.level >= nLv then
        lua_panelMgr:GetPanelOrCreate(MarryNpcPanel):Open(npcId)
        return true
    end
    return false
end

function MarryModel:GoNpc()
    local npcId = self:GetNpc()
    if npcId then
        SceneManager:GetInstance():FindNpc(npcId)
    end
end

function MarryModel:GetNpc()
    local cfg = String2Table(Config.db_marriage["npc"].val)
    if not cfg then
        return nil
    end
    return cfg[1]
end

--亲密度是否够
function MarryModel:IsCharm(charm)
    local cfg = String2Table(Config.db_marriage["intimacy"].val)
    local boo = false
    if not cfg then
        return false
    end
    local cha = cfg[1]
    if charm >= cha then
        boo = true
    end
    return boo
end

function MarryModel:GetMarryLevel()
    local cfg = String2Table(Config.db_marriage["level"].val)
    local nLv = cfg[1]
    return nLv
end

--亲密度满足的好友
function MarryModel:GetFriendList()
    local tab = {}
    local cfg = String2Table(Config.db_marriage["level"].val)
    local nLv = cfg[1]
    local roleList = FriendModel:GetInstance():GetFriendList()
    local role = RoleInfoModel.GetInstance():GetMainRoleData()
    for i, v in pairs(roleList) do
        local charm = v.intimacy
        local level = v.base.level
        local is_online = v.is_online
        local gender = v.base.gender
        local marry = v.base.marry
        if self:IsCharm(charm) and level >= nLv and is_online == true and role.gender ~= gender and marry == 0 then
            table.insert(tab, v)
        end
    end
    table.sort(tab, function(a, b)
        return a.base.charm < b.base.charm
    end)
    return tab
end

function MarryModel:GetRingCfg(grade, level)
    local key = grade .. "@" .. level
    local cfg = Config.db_marriage_ring[key]
    if not cfg then
        return nil
    end
    return cfg
end
--获取戒指升级材料Id
function MarryModel:GetUpRingMat()
    local cfg = String2Table(Config.db_marriage["ring_upitem"].val)
    if not cfg then
        return nil
    end
    return cfg[1]

end


--预约列表
function MarryModel:GetAppointmentList(data)
    --self.appointmentInfos = data
    local cfg = Config.db_marriage["appointment"]
    if not cfg then
        return
    end
    local tab = String2Table(cfg.val)
    local list = tab[1]

    for i = 1, #list do
        local item = list[i]
        local startHour = item[1][1]
        local startMin = item[1][2]
        local startSec = item[1][3]
        local endHour = item[2][1]
        local endMin = item[2][2]
        local endSec = item[2][3]
        local startHMS = TimeManager:GetStampByHMS(startHour, startMin, startSec)
        local endHMS = TimeManager:GetStampByHMS(endHour, endMin, endSec)

    end
end

--是否已经预约
function MarryModel:IsAppoint(startTime, endTime)
    local boo = false
    for i = 1, #self.appointmentInfos do
        if self.appointmentInfos[i].start_time == startTime and self.appointmentInfos[i].end_time == endTime then
            boo = true
            break
        end
    end
    return boo
end

--是否超过时间
function MarryModel:IsAppointOverTime(endTime)
    local boo = false
    local curTime = TimeManager:GetServerTime()
    if curTime > endTime then
        boo = true
    end
    return boo
end

--0 超时 1 被预约 2 可预约
function MarryModel:GetAppointmentState(data)
    -- local state
    local stime = data.start_time
    local etime = data.end_time
    local couple = data.couple
    local curTime = TimeManager:GetServerTime()
    if curTime > stime then
        --时间超过了
        return 0
    end

    if table.nums(couple) > 0 then
        return 1
    end

    return 2

    --for i = 1, #self.appointmentInfos  do
    --    if self.appointmentInfos[i].start_time == startTime and self.appointmentInfos[i].end_time == endTime  then
    --      return 1 , self.appointmentInfos[i]
    --    end
    --end
    --
    --return 2
end

function MarryModel:IsAppointment()
    local role = RoleInfoModel.GetInstance():GetMainRoleData()
    local boo = false
    dump(self.appointmentInfos)
    for i = 1, #self.appointmentInfos do
        local roles = self.appointmentInfos[i].couple
        for i = 1, #roles do
            if roles[i].id == role.id then
                boo = true
                break
            end
        end
    end
    return boo
end

--获取第一个可选择的
function MarryModel:GetAppointmentSelect()
    --self.model.appointmentInfos
    for i = 1, #self.appointmentInfos do
        local item = self.appointmentInfos[i]
        if self:GetAppointmentState(item) == 2 then
            --可预约
            return i
        end
    end

    for i = 1, #self.appointmentInfos do
        local item = self.appointmentInfos[i]
        if self:GetAppointmentState(item) == 1 then
            --可预约
            return i
        end
    end
    return 0
end


--宾客列表状态 0--未邀请 1--已邀请
function MarryModel:GetGuestState(roleId)
    for i, v in pairs(self.guestList) do
        if v.id == roleId then
            return 1
        end
    end
    return 0
end

--食物上限
function MarryModel:GetFoodLimit()
    local cfg = Config.db_marriage["food_limit"]
    if not cfg then
        return
    end
    local tab = String2Table(cfg.val)
    return tab[1]

end
--喜糖上限
function MarryModel:GetCandyLimit()
    local cfg = Config.db_marriage["candy_limit"]
    if not cfg then
        return
    end
    local tab = String2Table(cfg.val)
    return tab[1]
end
--热度上限
function MarryModel:GetHotLimit()
    local cfg = Config.db_marriage_hot
    local max = nil
    for i, v in pairs(cfg) do
        if max == nil then
            max = i
        end
        if max < i then
            max = i
        end
    end
    return max
end

--热度奖励是否领取
function MarryModel:IsHotReward(hot)
    local boo = false
    for i = 1, #self.hotReward do
        local num = self.hotReward[i]
        if hot == num then
            boo = true
            break
        end
    end
    return boo
end

function MarryModel:GetLowFireId()
    local cfg = Config.db_marriage["low_fire"]
    if not cfg then
        return
    end
    local tab = String2Table(cfg.val)
    return tab[1]
end

function MarryModel:GetHighFireId()
    local cfg = Config.db_marriage["high_fire"]
    if not cfg then
        return
    end
    local tab = String2Table(cfg.val)
    return tab[1]
end

function MarryModel:GetShopItems()
    local cfg = Config.db_mall
    local items = {}
    for i, v in pairs(cfg) do
        local type = String2Table(v.mall_type)[1]
        if type == 60 then
            table.insert(items, v)
        end
    end
    return items
end

function MarryModel:RemoveGuestSouList(id)
    local list = self.guestSouList
    for i, v in pairs(list) do
        if v.id == id then
            table.removebykey(self.guestSouList, i)
        end
    end
end

function MarryModel:AddGuestSouList(id)
    local list = self.guestSouList
    for i, v in pairs(list) do
        if v.id == id then
            table.removebykey(self.guestSouList, i)
        end
    end
end

function MarryModel:UpdateRedPoint()
    self.redPoints[1] = false
    self.redPoints[2] = false
    self.redPoints[5] = false
    if self:IsOpenThreeAct() then
        for i, v in pairs(self.marriageStep) do
            if v.state == 2 then
                self.redPoints[1] = true
                break
            end
        end
    end

    local ring = EquipModel.Instance.putOnedEquipList[enum.ITEM_STYPE.ITEM_STYPE_LOCK]
    if ring then
        local ringId = ring.id
        local cId = self:GetUpRingMat()
        if BagModel:GetInstance():GetItemNumByItemID(cId) > 0 then
            self.redPoints[2] = true
        end
        --BagModel:GetInstance():GetItemNumByItemID
    end

    --cp副本
    if OpenTipModel.GetInstance():IsOpenSystem(1200, 5) then
        local is_show = CoupleModel.GetInstance():CheckCPDungeonRD()
        self.redPoints[5] = is_show
    end

    local isRed = false
    for i, v in pairs(self.redPoints) do
        if v then
            isRed = true
            break
        end
    end
    GlobalEvent:Brocast(MainEvent.ChangeRedDot, "marry", isRed)
    self:Brocast(MarryEvent.MarryRedPoint)
    --dump(EquipModel.Instance.putOnedEquipList[enum.ITEM_STYPE.ITEM_STYPE_LOCK])
end

