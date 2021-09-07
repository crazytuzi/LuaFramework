-- ----------------------------------------------------------
-- 逻辑模块 - 跨服擂台
-- ----------------------------------------------------------
CrossArenaManager = CrossArenaManager or BaseClass(BaseManager)

function CrossArenaManager:__init()
    if CrossArenaManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end

    CrossArenaManager.Instance = self

    self.model = CrossArenaModel.New()

    self:InitHandler()

    self.OnUpdateRoomList = EventLib.New()
    self.OnUpdateRoomInfo = EventLib.New()
    self.OnUpdateMyLog = EventLib.New()
    self.OnUpdateFriendList = EventLib.New()

    EventMgr.Instance:AddListener(event_name.role_event_change, function(event, old_event) self:UpdateEvent(event, old_event) end)
end

function CrossArenaManager:__delete()
end

function CrossArenaManager:InitHandler()
    -- 最好是把所有的回调函数在连接之前全部添加
    -- 除非你很确定那些协议不会在连接后立即发送过来
    self:AddNetHandler(20700, self.On20700)
    self:AddNetHandler(20701, self.On20701)
    self:AddNetHandler(20702, self.On20702)
    self:AddNetHandler(20703, self.On20703)
    self:AddNetHandler(20704, self.On20704)
    self:AddNetHandler(20705, self.On20705)
    self:AddNetHandler(20706, self.On20706)
    self:AddNetHandler(20707, self.On20707)
    self:AddNetHandler(20708, self.On20708)
    self:AddNetHandler(20709, self.On20709)
    self:AddNetHandler(20710, self.On20710)
    self:AddNetHandler(20711, self.On20711)
    self:AddNetHandler(20712, self.On20712)
    self:AddNetHandler(20713, self.On20713)
    self:AddNetHandler(20714, self.On20714)
    self:AddNetHandler(20715, self.On20715)
    self:AddNetHandler(20716, self.On20716)
    self:AddNetHandler(20717, self.On20717)
    self:AddNetHandler(20718, self.On20718)
    self:AddNetHandler(20719, self.On20719)
    self:AddNetHandler(20720, self.On20720)
    self:AddNetHandler(20721, self.On20721)
    self:AddNetHandler(20722, self.On20722)
    self:AddNetHandler(20723, self.On20723)
    self:AddNetHandler(20724, self.On20724)
    self:AddNetHandler(20725, self.On20725)
    self:AddNetHandler(20726, self.On20726)
    self:AddNetHandler(20727, self.On20727)
    self:AddNetHandler(20728, self.On20728)
    self:AddNetHandler(20729, self.On20729)
    self:AddNetHandler(20730, self.On20730)
    self:AddNetHandler(20732, self.On20732)
    self:AddNetHandler(20733, self.On20733)
    self:AddNetHandler(20734, self.On20734)
end

function CrossArenaManager:RequestInitData()
    self.model:InitData()
end

-------------------------------------------
-------------------------------------------
------------- 协议处理 -----------------
-------------------------------------------
-------------------------------------------

function CrossArenaManager:Send20700(init_flag)
    -- print("Send20700")
    Connection.Instance:send(20700, { init_flag = init_flag })
end

function CrossArenaManager:On20700(data)
    -- BaseUtils.dump(data, "On20700")
    self.model.roomList = data.provocation_room
    self.OnUpdateRoomList:Fire()
end

function CrossArenaManager:Send20701()
    -- print("Send20701")
    Connection.Instance:send(20701, { })
end

function CrossArenaManager:On20701(data)
    -- BaseUtils.dump(data, "On20701")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.err_code == 1 then
        NoticeManager.Instance:FloatTipsByString(TI18N("欢迎来到跨服擂台{face_1,25}"))
    end
end

function CrossArenaManager:Send20702()
    -- print("Send20701")
    Connection.Instance:send(20702, { })
end

function CrossArenaManager:On20702(data)
    -- BaseUtils.dump(data, "On20702")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function CrossArenaManager:Send20703(room_name, room_mode, room_lev_min, min_lev_break, room_lev_max, max_lev_break, room_password, provocation_type)
    -- print("Send20703")
    Connection.Instance:send(20703, { room_name = room_name, room_mode = room_mode, room_lev_min = room_lev_min, min_lev_break = min_lev_break, room_lev_max = room_lev_max, max_lev_break = max_lev_break, room_password = room_password, provocation_type = provocation_type })
end

function CrossArenaManager:On20703(data)
    -- BaseUtils.dump(data, "On20703")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.err_code == 1 then
        LuaTimer.Add(500, function()
            if self.model.myRoomData ~= nil then
                if self.model.invitationAndCreateRoomType == 1 then
                    self.model:SendInvitationFriend({self.model.invitationAndCreateRoomData})
                elseif self.model.invitationAndCreateRoomType == 2 then
                    self.model:SendInvitation({self.model.invitationAndCreateRoomData})
                end
                self.model.invitationAndCreateRoomData = nil
                self.model.invitationAndCreateRoomType = nil
            end
        end)
    end
end

function CrossArenaManager:Send20704()
    -- print("Send20704")
    Connection.Instance:send(20704, { })
end

function CrossArenaManager:On20704(data)
    BaseUtils.dump(data, "On20704")
    self.model.myRoomData = data
    self.OnUpdateRoomInfo:Fire()

    if self.model.myRoomData.status == 3 then
        self.model:OpenCrossArenaRoomWindow()
    end
end

function CrossArenaManager:Send20705(room_id, password)
    -- print("Send20705")
    Connection.Instance:send(20705, { room_id = room_id, password = password })
end

function CrossArenaManager:On20705(data)
    -- BaseUtils.dump(data, "On20705")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function CrossArenaManager:Send20706(room_id, name, mode, room_lev_min, min_lev_break, room_lev_max, max_lev_break, password, provocation_type)
    -- print("Send20706")
    -- print(string.format("%s, %s, %s, %s, %s, %s, %s, %s", room_id, name, mode, room_lev_min, min_lev_break, room_lev_max, max_lev_break, password))
    Connection.Instance:send(20706, { room_id = room_id, name = name, mode = mode, room_lev_min = room_lev_min, min_lev_break = min_lev_break, room_lev_max = room_lev_max, max_lev_break = max_lev_break, password = password, provocation_type = provocation_type })
end

function CrossArenaManager:On20706(data)
    -- BaseUtils.dump(data, "On20706")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function CrossArenaManager:Send20707()
    -- print("Send20707")
    Connection.Instance:send(20707, { })
end

function CrossArenaManager:On20707(data)
    -- BaseUtils.dump(data, "On20707")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function CrossArenaManager:Send20708(rid, platform, zone_id)
    -- print("Send20708")
    Connection.Instance:send(20708, { rid = rid, platform = platform, zone_id = zone_id })
end

function CrossArenaManager:On20708(data)
    -- BaseUtils.dump(data, "On20708")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function CrossArenaManager:Send20709(channel, flag)
    -- print("Send20709")
    Connection.Instance:send(20709, { channel = channel, flag = flag })
end

function CrossArenaManager:On20709(data)
    -- BaseUtils.dump(data, "On20709")
end

function CrossArenaManager:Send20710()
    -- print("Send20710")
    Connection.Instance:send(20710, { })
end

function CrossArenaManager:On20710(data)
    -- BaseUtils.dump(data, "On20710")
    NoticeManager.Instance:FloatTipsByString(data.msg)

    if data.err_code == 1 then
        ChatManager.Instance:Send10400(MsgEumn.ChatChannel.Scene, TI18N("我方准备完毕，随时可开战{face_1,25}"))
    end
end

function CrossArenaManager:Send20711()
    -- print("Send20711")
    Connection.Instance:send(20711, { })
end

function CrossArenaManager:On20711(data)
    -- BaseUtils.dump(data, "On20711")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function CrossArenaManager:Send20712()
    -- print("Send20712")
    Connection.Instance:send(20712, { })
end

function CrossArenaManager:On20712(data)
    -- BaseUtils.dump(data, "On20712")
    self.model.room_check = data.room_check -- 旗鼓相当 0: 不检查，1：检查，2：检查但是为空自动重置为0
    self.model.book_check = data.book_check -- 战书等级相符
    self.model.video_check = data.video_check -- 录像等级相符

    if self.model.room_check == 2 then
        self.model.room_check = 0
        -- NoticeManager.Instance:FloatTipsByString(TI18N("暂时没有旗鼓相当的对手"))
    end
    self.OnUpdateRoomList:Fire()
end

function CrossArenaManager:Send20713()
    -- print("Send20713")
    Connection.Instance:send(20713, { })
end

function CrossArenaManager:On20713(data)
    -- BaseUtils.dump(data, "On20713")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function CrossArenaManager:Send20714()
    -- print("Send20714")
    Connection.Instance:send(20714, { })
end

function CrossArenaManager:On20714(data)
    -- BaseUtils.dump(data, "On20714")
    data.type = 1
    data.playback = 1
    self.model:OpenCountInfowindow(data)
end

function CrossArenaManager:Send20715(rid, platform, zone_id)
    -- print("Send20715")
    Connection.Instance:send(20715, { rid = rid, platform = platform, zone_id = zone_id })
end

function CrossArenaManager:On20715(data)
    -- BaseUtils.dump(data, "On20715")
    self.model.myLogData = data.last_recent
    self.OnUpdateMyLog:Fire()
end

function CrossArenaManager:Send20716(id, platform, zone_id)
    -- print("Send20716")
    Connection.Instance:send(20716, { id = id, platform = platform, zone_id = zone_id })
end
               
function CrossArenaManager:On20716(data)
    -- BaseUtils.dump(data, "On20716")
    data.type = 1
    data.playback = 2
    self.model:OpenCountInfowindow(data)
end

function CrossArenaManager:Send20717(id, platform, zone_id)
    -- print("Send20717")
    Connection.Instance:send(20717, { id = id, platform = platform, zone_id = zone_id })
end

function CrossArenaManager:On20717(data)
    -- BaseUtils.dump(data, "On20717")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function CrossArenaManager:Send20718(room_check, book_check, video_check)
    -- print("Send20718")
    Connection.Instance:send(20718, { room_check = room_check, book_check = book_check, video_check = video_check })
end

function CrossArenaManager:On20718(data)
    -- BaseUtils.dump(data, "On20718")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function CrossArenaManager:Send20719()
    -- print("Send20719")
    Connection.Instance:send(20719, { })
end

function CrossArenaManager:On20719(data)
    -- BaseUtils.dump(data, "On20719")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function CrossArenaManager:Send20720(rid, platform, zone_id, type)
    -- print("Send20720")
    Connection.Instance:send(20720, { rid = rid, platform = platform, zone_id = zone_id, type = type })
end

function CrossArenaManager:On20720(data)
    -- BaseUtils.dump(data, "On20720")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function CrossArenaManager:Send20721()
    -- print("Send20721")
    Connection.Instance:send(20721, { })
end

function CrossArenaManager:On20721(data)
    -- BaseUtils.dump(data, "On20721")
    self.model:AcceptInvitation(data)
end

function CrossArenaManager:Send20722(rid, platform, zone_id, flag, type)
    -- print("Send20722")
    -- -- BaseUtils.dump({ rid = rid, platform = platform, zone_id = zone_id, flag = flag, type = type })
    Connection.Instance:send(20722, { rid = rid, platform = platform, zone_id = zone_id, flag = flag, type = type })
end

function CrossArenaManager:On20722(data)
    -- BaseUtils.dump(data, "On20722")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function CrossArenaManager:Send20723()
    -- print("Send20723")
    Connection.Instance:send(20723, { })
end

function CrossArenaManager:On20723(data)
    -- BaseUtils.dump(data, "On20723")
    self.model.battleFriendList = data.list
    self.OnUpdateFriendList:Fire(1)
end

function CrossArenaManager:Send20724()
    -- print("Send20724")
    Connection.Instance:send(20724, { })
end

function CrossArenaManager:On20724(data)
    -- BaseUtils.dump(data, "On20724")
    self.model.fcFriendList = data.list
    self.OnUpdateFriendList:Fire(2)
end

function CrossArenaManager:Send20725(init_flag)
    -- print("Send20725")
    Connection.Instance:send(20725, { init_flag = init_flag })
end

function CrossArenaManager:On20725(data)
    -- BaseUtils.dump(data, "On20725")
    self.model.letterOfWarList = data.provocation_book
    self.OnUpdateRoomList:Fire()
end

function CrossArenaManager:Send20726( book_name, book_mode, book_lev_min, min_lev_break, book_lev_max, max_lev_break, is_send_book, provocation_type)
    -- print("Send20726")
    Connection.Instance:send(20726, { book_name = book_name, book_mode = book_mode, book_lev_min = book_lev_min, min_lev_break = min_lev_break, book_lev_max = book_lev_max, max_lev_break = max_lev_break, is_send_book = is_send_book, provocation_type = provocation_type })
end

function CrossArenaManager:On20726(data)
    -- BaseUtils.dump(data, "On20726")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function CrossArenaManager:Send20727(id, book_name, book_mode, book_lev_min, min_lev_break, book_lev_max, max_lev_break, is_send_book, provocation_type)
    -- print("Send20727")
    Connection.Instance:send(20727, { id = id, book_name = book_name, book_mode = book_mode, book_lev_min = book_lev_min, min_lev_break = min_lev_break, book_lev_max = book_lev_max, max_lev_break = max_lev_break, is_send_book = is_send_book, provocation_type = provocation_type })
end

function CrossArenaManager:On20727(data)
    -- BaseUtils.dump(data, "On20727")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function CrossArenaManager:Send20728()
    -- print("Send20728")
    Connection.Instance:send(20728, { })
end

function CrossArenaManager:On20728(data)
    -- BaseUtils.dump(data, "On20728")
end

function CrossArenaManager:Send20729(room_id)
    -- print("Send20729")
    Connection.Instance:send(20729, { room_id = room_id })
end

function CrossArenaManager:On20729(data)
    -- BaseUtils.dump(data, "On20729")
    self.model.invitationRoomData = data
    if data.id == 0 and data.m_rid == 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("房间已关闭"))
    else
        self.model:OpenCrossArenaInvitationWindow()
    end
end

function CrossArenaManager:Send20730(init_flag)
    -- print("Send20730")
    Connection.Instance:send(20730, { init_flag = init_flag })
end

function CrossArenaManager:On20730(data)
    -- BaseUtils.dump(data, "On20730")
    self.model.battleRoomList = data.provocation_room
    self.OnUpdateRoomList:Fire()
end

function CrossArenaManager:Send20732(room_id, flag, password, r_id, r_platform, r_zone_id)
    -- print("Send20732")
    Connection.Instance:send(20732, { room_id = room_id, flag = flag, password = password, r_id = r_id, r_platform = r_platform, r_zone_id = r_zone_id })
end

function CrossArenaManager:On20732(data)
    -- BaseUtils.dump(data, "On20732")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function CrossArenaManager:Send20733(id, platform, zone_id)
    -- print("Send20733")
    Connection.Instance:send(20733, { id = id, platform = platform, zone_id = zone_id })
end

function CrossArenaManager:On20733(data)
    -- BaseUtils.dump(data, "On20733")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function CrossArenaManager:Send20734(name)
    -- print("Send20732")
    Connection.Instance:send(20734, { name = name })
end

function CrossArenaManager:On20734(data)
    -- BaseUtils.dump(data, "On20734")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function CrossArenaManager:UpdateEvent(event, old_event)
    if (event == RoleEumn.Event.Provocation and old_event ~= RoleEumn.Event.Provocation) or (event == RoleEumn.Event.ProvocationRoom and old_event ~= RoleEumn.Event.ProvocationRoom) then
        self.model:OpenCrossArenaIcon()
        if MainUIManager.Instance.MainUIIconView ~= nil then
            MainUIManager.Instance.MainUIIconView:hide_icon_by_idlist(303, true)
            MainUIManager.Instance.MainUIIconView:Set_ShowTop(false, {17})
        end
    elseif (old_event == RoleEumn.Event.Provocation and event ~= RoleEumn.Event.Provocation) or (old_event == RoleEumn.Event.ProvocationRoom and event ~= RoleEumn.Event.ProvocationRoom) then
        self.model:CloseCrossArenaIcon()
        if MainUIManager.Instance.MainUIIconView ~= nil then
            MainUIManager.Instance.MainUIIconView:hide_icon_by_idlist(303, false)
            MainUIManager.Instance.MainUIIconView:Set_ShowTop(true)
        end
    end

    if event == RoleEumn.Event.Provocation and old_event ~= RoleEumn.Event.Provocation then
        self:Send20700(1)
        self:Send20725(1)
        self:Send20730(1)
        self:Send20712()
    elseif event ~= RoleEumn.Event.Provocation and old_event == RoleEumn.Event.Provocation then
    end

    if event == RoleEumn.Event.ProvocationRoom and old_event ~= RoleEumn.Event.ProvocationRoom then
        self:Send20704()
        WindowManager.Instance:CloseCurrentWindow()
        self.model:OpenCrossArenaRoomWindow()
    elseif event ~= RoleEumn.Event.ProvocationRoom and old_event == RoleEumn.Event.ProvocationRoom then
        self.model:CloseCrossArenaRoomWindow()
        self.model.myRoomData = nil
    end
end

function CrossArenaManager:EnterScene()
    self:Send20701()
end

function CrossArenaManager:ExitScene()
    local confirmData = NoticeConfirmData.New()
    confirmData.type = ConfirmData.Style.Normal
    confirmData.sureLabel = TI18N("确定退出")
    confirmData.cancelLabel = TI18N("取消")

    if RoleManager.Instance.RoleData.event == RoleEumn.Event.ProvocationRoom then
        confirmData.content = TI18N("当前正在约战房间内，是否确认退出？")
        confirmData.sureCallback = function()
            if TeamManager.Instance:HasTeam() and not TeamManager.Instance:IsSelfCaptin() then
                TeamManager.Instance:Send11708()
            else
                self:Send20707()
            end
            self:Send20702()
        end
    else
        confirmData.content = TI18N("你是否要退出跨服擂台？")
        confirmData.sureCallback = function()
            self:Send20702()
        end
    end

    NoticeManager.Instance:ConfirmTips(confirmData)
end

function CrossArenaManager:GetLevelString(lev, lev_break_times, type)
    if type == nil or type == 1 then
        if lev_break_times == 0 then
            return tostring(lev)
        else
            return string.format("突破%s", lev)
        end
    elseif type == 2 then

    end
end