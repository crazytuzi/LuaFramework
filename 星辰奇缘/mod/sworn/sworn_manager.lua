-- @author 黄耀聪
-- @date 2016年10月22日

SwornManager = SwornManager or BaseClass(BaseManager)

function SwornManager:__init()
    if SwornManager.Instance ~= nil then
        Log.Error("不可重复实例化")
    end
    SwornManager.Instance = self

    self.model = SwornModel.New()

    self.showIcon = false

    self.statusEumn = {
        None = 0,       -- 未结拜
        Want = 1,       -- 开始结拜确定
        EndWant = 2,    -- 结拜确定结束
        Fight = 3,      -- 试炼结束
        Vote = 4,       -- 投票
        Honor = 5,      -- 称号
        SubHonor = 6,   -- 自定义称号
        Confirm = 7,    -- 确认
        Story = 8,      -- 剧情
        Sworn = 9,      -- 已结拜
    }

    self.trendType = {
        Invite = 1,     -- 邀请
        Remove = 2,     -- 请离
        Rename = 3,     -- 团体改名
        Leave = 4,      -- 自行离开
    }

    self.trendRedList = {}

    self.status = 0
    self.infoData = nil
    self:InitHandler()

    self.plot = nil
end

function SwornManager:__delete()
end

function SwornManager:InitHandler()
    self:AddNetHandler(17700, self.on17700)
    self:AddNetHandler(17701, self.on17701)
    self:AddNetHandler(17702, self.on17702)
    self:AddNetHandler(17703, self.on17703)
    self:AddNetHandler(17704, self.on17704)
    self:AddNetHandler(17705, self.on17705)
    self:AddNetHandler(17706, self.on17706)
    self:AddNetHandler(17707, self.on17707)
    self:AddNetHandler(17708, self.on17708)
    self:AddNetHandler(17709, self.on17709)
    self:AddNetHandler(17710, self.on17710)
    self:AddNetHandler(17711, self.on17711)
    self:AddNetHandler(17712, self.on17712)
    self:AddNetHandler(17713, self.on17713)
    self:AddNetHandler(17714, self.on17714)
    self:AddNetHandler(17715, self.on17715)
    self:AddNetHandler(17716, self.on17716)
    self:AddNetHandler(17717, self.on17717)
    self:AddNetHandler(17718, self.on17718)
    self:AddNetHandler(17719, self.on17719)
    self:AddNetHandler(17720, self.on17720)
    self:AddNetHandler(17721, self.on17721)
    self:AddNetHandler(17722, self.on17722)

    EventMgr.Instance:AddListener(event_name.end_fight, function(type, result) self:EndFight(type, result) end)
    EventMgr.Instance:AddListener(event_name.scene_load, function() self:ShowStatusIcon() end)
    EventMgr.Instance:AddListener(event_name.begin_fight, function(type) self:BeginFight(type) end)
end

function SwornManager:RequestInitData()
    self.model:InitData()
    self:send17700()
end

function SwornManager:OpenProgressWindow(args)
    self.model:OpenProgressWindow(args)
end

function SwornManager:OpenLeaveWindow(args)
    self.model:OpenLeaveWindow(args)
end

function SwornManager:SetIcon()
    TeacherManager.Instance:SetIcon()
end

-- 结拜信息
function SwornManager:send17700()
    Connection.Instance:send(17700, {})
end

function SwornManager:on17700(data)
    BaseUtils.dump(data, "<color=#00ff00>on17700</color>")

    self.infoData = data
    if data.status == 0 then self.model.voteUid = nil end

    local members = (self.model.swornData or {}).members or {}
    local lassVotePos = 0
    for i,v in ipairs(members) do
        if v.pos > lassVotePos then lassVotePos = v.pos end
    end

    self.model.swornData = BaseUtils.copytab(data)
    self.model.myPos = 0

    self.status = data.status

    self.showIcon = (self.status == self.statusEumn.Sworn)

    local roleData = RoleManager.Instance.RoleData
    for uid,_ in pairs(self.model.menberTab) do
        self.model.menberTab[uid] = nil
    end
    for index,_ in pairs(self.model.memberUidList) do
        self.model.memberUidList[index] = nil
    end
    self.model.votePos = 0
    for k,_ in pairs(self.model.swornData.members) do
        self.model.swornData.members[k] = nil
    end
    for i,v in ipairs(data.members) do
        if v.m_id == roleData.id and v.m_platform == roleData.platform and v.m_zone_id == roleData.zone_id then
            self.model.myPos = v.pos
        end
        if v.pos > 0 then
            self.model.swornData.members[v.pos] = BaseUtils.copytab(v)
            local uid = BaseUtils.Key(v.m_platform, v.m_zone_id, v.m_id)
            self.model.menberTab[uid] = v.pos
            self.model.memberUidList[v.pos] = uid
        end
        if v.pos > self.model.votePos then
            self.model.votePos = v.pos
        end
    end

    -- print("lassVotePos = " .. tostring(lassVotePos))
    -- print("self.model.votePos = " .. tostring(self.model.votePos))
    if lassVotePos < self.model.votePos then self.model.voteUid = nil end

    self.model.votePos = self.model.votePos + 1

    if self.status == self.statusEumn.EndWant
        or self.status == self.statusEumn.Vote
        or self.status == self.statusEumn.Honor
        or self.status == self.statusEumn.SubHonor
        or self.status == self.statusEumn.Confirm
        then
        if self.model.progressWin == nil and CombatManager.Instance.isFighting ~= true then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.sworn_progress_window)
        end
    end

    EventMgr.Instance:Fire(event_name.sworn_status_change, self.status)
    self:ShowStatusIcon()
    self:SetIcon()

    for k,_ in pairs(self.trendRedList) do
        self.trendRedList[k] = nil
    end
    local roleData = RoleManager.Instance.RoleData
    for i,trend in ipairs(data.trends) do
        if trend.type ~= 4 then
            self.trendRedList[i] = true
            for _,vote in ipairs(trend.votes) do
                if vote.rid == roleData.id and vote.platform == roleData.platform and vote.zone_id == roleData.zone_id then
                    self.trendRedList[i] = false
                    break
                end
            end
        end
    end

    if self.status == self.statusEumn.Story then
        -- 播放剧情
        self.model:PlayPlot()
    end
    self:CheckShowRedPoint()
end

--已结拜，有得投票：新人加入、改名、请离的投票
function SwornManager:CheckRedPointState()
    if self.status == self.statusEumn.Sworn then
        if self.infoData ~= nil then
            for k, v in pairs(self.infoData.trends) do
                if v.type == 2 or v.type == 1 or v.type == 3 then
                    for k1, v1 in pairs(v.votes) do
                        if v1.rid == RoleManager.Instance.RoleData.id and v1.platform == RoleManager.Instance.RoleData.platform and v1.zone_id == RoleManager.Instance.RoleData.zone_id then
                            return false
                        end
                    end
                    return true
                end
            end
        end
    end
    return false
end

--检查是否主ui图标是否显示红点
function SwornManager:CheckShowRedPoint()
    local state = self:CheckRedPointState()
    local cfg_data = DataSystem.data_daily_icon[302]
    if MainUIManager.Instance.MainUIIconView ~= nil then
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(cfg_data.id, state)
    end
end

-- 长幼有序投票
function SwornManager:send17701(rid, platform, zone_id, pos)
    local dat = {rid = rid, platform = platform, zone_id = zone_id, pos = pos}
    BaseUtils.dump(dat, "send17701")
    Connection.Instance:send(17701, dat)
end

function SwornManager:on17701(data)
    if data.flag ~= 1 then self.model.voteUid = nil end
    NoticeManager.Instance:FloatTipsByString(data.msg)
    EventMgr.Instance:Fire(event_name.sworn_status_change, self.status)
end

-- 老大设置称号前缀
function SwornManager:send17702(name_head, name_tail)
    local dat = {name_head = name_head, name_tail = name_tail}
    BaseUtils.dump(dat, "send17702")
    Connection.Instance:send(17702, dat)
end

function SwornManager:on17702(data)
    BaseUtils.dump(data, "on17702")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 自定义称号
function SwornManager:send17703(name)
    local dat = {name = name}
    BaseUtils.dump(dat, "send17703")
    Connection.Instance:send(17703, dat)
end

function SwornManager:on17703(data)
    BaseUtils.dump(data, "on17703")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 结拜契约确定
function SwornManager:send17704()
    Connection.Instance:send(17704, {})
end

function SwornManager:on17704(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 修改称号发起投票
function SwornManager:send17705(name_head, name_tail)
    Connection.Instance:send(17705, {name_head = name_head, name_tail = name_tail})
end

function SwornManager:on17705(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 修改称号投票
function SwornManager:send17706(flag)
    Connection.Instance:send(17706, {flag = flag})
end

function SwornManager:on17706(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 修改自己称号
function SwornManager:send17707(name)
    Connection.Instance:send(17707, {name = name})
end

function SwornManager:on17707(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 开始试炼
function SwornManager:send17708()
    Connection.Instance:send(17708, {})
end

function SwornManager:on17708(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 邀请结拜
function SwornManager:send17709(rid, platform, zone_id, name)
    local dat = {rid = rid, platform = platform, zone_id = zone_id, name = name}
    BaseUtils.dump(dat, "send17709")
    Connection.Instance:send(17709, dat)
end

function SwornManager:on17709(data)
    BaseUtils.dump(data, "on17709")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 请离操作
function SwornManager:send17710(rid, platform, zone_id, flag, msg)
    local dat = {rid = rid, platform = platform, zone_id = zone_id, flag = flag, msg = msg}
    BaseUtils.dump(dat, "send17710")
    Connection.Instance:send(17710, dat)
end

function SwornManager:on17710(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 上传结拜头像
function SwornManager:send17711(photo)
    Connection.Instance:send(17711, {photo = photo})
end

function SwornManager:on17711(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 查看结拜头像
function SwornManager:send17712()
    Connection.Instance:send(17712, {})
end

function SwornManager:on17712(data)
    self.model.photo_bin = data.photo_bin
    self.model.auditing = data.auditing
end

-- 打开NPC,弹出结拜界面
function SwornManager:send17713()
    print("send17713")
    Connection.Instance:send(17713, {})
end

function SwornManager:on17713()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.sworn_desc_window)
end

-- 队长发起结拜
function SwornManager:send17714()
    print("send17714")
    Connection.Instance:send(17714, {})
end

function SwornManager:on17714(data)
    local confirmData = NoticeConfirmData.New()
    confirmData.content = string.format(TI18N("<color='#01c0ff'>%s</color>发起了结拜，加入需要消耗\n<color='#ffff00'>1000000</color>{assets_2, 90000}，是否加入？"), TeamManager.Instance.memberTab[TeamManager.Instance.memberOrderList[1]].name)
    confirmData.sureLabel = TI18N("加入结拜")
    confirmData.cancelLabel = TI18N("拒绝")
    confirmData.cancelSecond = 30
    confirmData.sureCallback = function() self:send17715(1) end
    confirmData.cancelCallback = function() self:send17715(0) end
    NoticeManager.Instance:ConfirmTips(confirmData)
end

-- 确认结拜
function SwornManager:send17715(flag)
    print("send17715")
    Connection.Instance:send(17715, {flag = flag})
end

function SwornManager:on17715(data)
    if data.flag == 1 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.sworn_progress_window)
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function SwornManager:EndFight(type, result)
    if type == 49 and self.status ~= self.statusEumn.None and self.status ~= self.statusEumn.Sworn  then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.sworn_progress_window)
        self:ShowStatusIcon()

        if result == 1 then
            local npcBase = BaseUtils.copytab(DataUnit.data_unit[20097])
            npcBase.buttons = {}
            npcBase.plot_talk = TI18N("恭喜通过结拜试炼{face_1,6}接下来需要确定<color='#00ff00'>长幼排序</color>，投票决定谁当<color='#00ff00'>老大</color>吧{face_1,25}")
            MainUIManager.Instance:OpenDialog({baseid = 20097, name = npcBase.name}, {base = npcBase}, true, true)
        end
    end
end

function SwornManager:BeginFight(type)
    if type == 49 then
        if self.model.progressWin ~= nil then
            WindowManager.Instance:CloseWindowById(WindowConfig.WinID.sworn_progress_window)
        end
    end
    self.model:HideStatusIcon()
end

function SwornManager:ShowStatusIcon()
    if CombatManager.Instance.isFighting ~= true then
        if self.status == self.statusEumn.None
            or self.status == self.statusEumn.Want
            or self.status == self.statusEumn.Story
            or self.status == self.statusEumn.Sworn
            then
            self.model:HideStatusIcon()
        else
            self.model:ShowStatusIcon()
        end
    end
end

function SwornManager:OpenDescWindow()
    self.model:OpenDescWindow()
end

--
function SwornManager:send17716(type, rid, platform, zone_id, flag)
    print("send17716")
    Connection.Instance:send(17716, {type = type, rid = rid, platform = platform, zone_id = zone_id, flag = flag})
end

function SwornManager:on17716(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 被邀请人弹框提示
function SwornManager:send17717()
    Connection.Instance:send(17717, {})
end

function SwornManager:on17717(data)
    BaseUtils.dump(data, "on17717")
    local confirmData = NoticeConfirmData.New()
    confirmData.content = string.format(TI18N("<color='#23E4EB'>%s</color>邀请你加入结拜团体-<color='#00ff00'>%s</color>\n是否消耗<color='#00ff00'>1000000</color>{assets_2, 90000}加入？\n(需等待结拜成员投票通过)"), data.name, data.sworn_name)
    confirmData.sureLabel = TI18N("加入结拜")
    confirmData.cancelLabel = TI18N("拒绝")

    local dat = {rid = data.rid, platform = data.platform, zone_id = data.zone_id}
    confirmData.sureCallback = function() dat.flag = 1 self:send17718(dat) end
    confirmData.cancelCallback = function() dat.flag = 0 self:send17718(dat) end

    NoticeManager.Instance:ConfirmTips(confirmData)
end

-- 被邀请人回应邀请
function SwornManager:send17718(data)
    Connection.Instance:send(17718, data)
end

function SwornManager:on17718(data)
    BaseUtils.dump(data, "on17718")
end

function SwornManager:GetFullName(pos)
    local swornData = self.model.swornData
    return string.format(TI18N("%s之%s%s"), swornData.name, self.model.rankList[pos], swornData.members[pos].name_defined)
end
