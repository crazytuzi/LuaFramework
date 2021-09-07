FriendManager = FriendManager or BaseClass(BaseManager)

function FriendManager:__init()
    if FriendManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
        return
    end
    FriendManager.Instance = self
    self.model = FriendModule.New()
    self.listener = function () self:OnConnect()  end
    self.friend_List = {}
    self.blackfriend_List = {}
    self.crossfriend_List = {}
    self.currchat_List = {}
    self.online_friend_List = {}
    self.request_List = {}
    self.mail_List = {}
    self.guildmail_List = {}
    self.announce_list = {} -- 公告列表
    self.currHasMsg = {}
    self.chatData = {}
    self:InitHandler()
    self.noReadMsg = 0
    self.noReadReq = 0
    self.isTips = false
    self.help = nil

    self.reject = false
    self.lastUpdate = 0
    self.max_num = 60
    self.max_mix_num = 20
    self.offline_push = 0 -- 不接受离线推送
end

function FriendManager:InitHandler()
    self:AddNetHandler(11800, self.On11800)
    self:AddNetHandler(11801, self.On11801)
    self:AddNetHandler(11802, self.On11802)
    self:AddNetHandler(11803, self.On11803)
    self:AddNetHandler(11804, self.On11804)
    self:AddNetHandler(11805, self.On11805)
    self:AddNetHandler(11806, self.On11806)
    self:AddNetHandler(11807, self.On11807)
    self:AddNetHandler(11808, self.On11808)
    self:AddNetHandler(11809, self.On11809)
    self:AddNetHandler(11810, self.On11810)
    self:AddNetHandler(11811, self.On11811)
    self:AddNetHandler(11855, self.On11855)
    self:AddNetHandler(11888, self.On11888)

    self:AddNetHandler(11889, self.On11889)
    self:AddNetHandler(11890, self.On11890)
    self:AddNetHandler(11891, self.On11891)
    -------------------------------------------------

    self:AddNetHandler(13400, self.On13400)
    self:AddNetHandler(13401, self.On13401)
    self:AddNetHandler(13402, self.On13402)
    self:AddNetHandler(13403, self.On13403)
    self:AddNetHandler(13404, self.On13404)
    self:AddNetHandler(13405, self.On13405)
    -------------------------------------------------
    EventMgr.Instance:AddListener(event_name.mainui_btn_init, self.listener)
    EventMgr.Instance:AddListener(event_name.enter_guild_succ, function() self:OnGuildStatusChange() end)
    EventMgr.Instance:AddListener(event_name.leave_guild_succ, function() self:OnGuildStatusChange() end)
    -- 成功加入公会
-- event_name.enter_guild_succ = "enter_guild_succ"
-- 离开公会
-- event_name.leave_guild_succ = "leave_guild_succ"
end

-------好友协议-----------
--查看自身好友数据
function FriendManager:Require11800()
    Connection.Instance:send(11800, {})
end

function FriendManager:On11800(data)
    self.max_num = data.max_num
    self.offline_push = data.offline_push
end

--查看好友列表
function FriendManager:Require11801()
    Connection.Instance:send(11801, {})
end

function FriendManager:On11801(data)
    self.friend_List = {}
    self.blackfriend_List = {}
    for k,v in pairs(data.list) do
        local uid = BaseUtils.Key(v.id, v.platform, v.zone_id)
        if v.type == 0 then 
            self.friend_List[uid] = v
        elseif v.type == 1 then 
            self.blackfriend_List[uid] = v
        end
    end
    -- for i = 1,30 do
    --     local v = data.list[1]
    --     local uid = BaseUtils.Key(v.id, v.platform, i+1)
    --     self.friend_List[uid] = v
    -- end
    self:GetOnlineList()
    self:GetCrossSortFriendList()
    -- BaseUtils.dump(self.friend_List, "最新好友列表")
end
function FriendManager:Require11802()
    Connection.Instance:send(11802, {})
end

-- 好友信息更新
function FriendManager:On11802(data)
    -- BaseUtils.dump(data, "<color='#FF0000'>On11802</color>")
    local selfuid = BaseUtils.Key(RoleManager.Instance.RoleData.id, RoleManager.Instance.RoleData.platform, RoleManager.Instance.RoleData.zone_id)
    for k,v in pairs(data.list) do
        local uid = BaseUtils.Key(v.id, v.platform, v.zone_id)
        if data.type == 3 then
            if v.type == 0 then 
                self.friend_List[uid] = nil
            else
                self.blackfriend_List[uid] = nil
            end
        elseif uid ~= selfuid then
            if v.type == 0 then 
                self.friend_List[uid] = v
            elseif v.type == 1 then 
                self.blackfriend_List[uid] = v
            end
        end
        self.request_List[uid] = nil
    end
    self.model:UpdataFriendList()
    -- self.model:CheckReq()
    self.model:CheckRedPoint()
    self:GetOnlineList()
    ZoneManager.Instance.model:UpdateOtherBtn()
    GivepresentManager.Instance.model:RefreshFriendShip()
    local num = 0
    for k,v in pairs(self.request_List) do
        num = num + 1
    end

    self.noReadReq = num
    if MainUIManager.Instance.noticeView ~= nil then
        MainUIManager.Instance.noticeView:set_friendnotice_num(self.noReadReq + #FriendGroupManager.Instance.groupinviteData)
    end
    EventMgr.Instance:Fire(event_name.friend_update)
end
function FriendManager:Require11803(sig)
    Connection.Instance:send(11803, {signature = sig})
end

function FriendManager:On11803(data)
    -- BaseUtils.dump(data, "On11803")

end

--加好友
function FriendManager:Require11804(id, platform, zone_id)
    local max_num = self.max_num
    local cross = false
    if BaseUtils.IsTheSamePlatform(platform, zone_id) then
        max_num = self.max_num - 20
    else
        max_num = 20
        cross = true
    end
    if self:GetFriendNum(cross) >= max_num then
        NoticeManager.Instance:FloatTipsByString(TI18N("您的好友列表已满"))
        return
    end
    if BaseUtils.IsTheSamePlatform(platform, zone_id) or true then
        Connection.Instance:send(11804, {id = id, platform = platform, zone_id = zone_id})
        NoticeManager.Instance:FloatTipsByString(TI18N("已发送好友请求"))
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("跨服暂不支持添加好友"))
    end
end

function FriendManager:On11804(data)
    -- BaseUtils.dump(data, "On11804")
end

--加好友回应
function FriendManager:Require11805(flag, name, id, platform, zone_id)
    local max_num = self.max_num
    local cross = false
    if BaseUtils.IsTheSamePlatform(platform, zone_id) then
        max_num = self.max_num - 20
    else
        max_num = 20
        cross = true
    end
    if flag == 1 and self:GetFriendNum(cross) >= max_num then
        NoticeManager.Instance:FloatTipsByString(TI18N("您的好友列表已满"))
        return false
    end
    local uid = BaseUtils.Key(id, platform, zone_id)
    if flag == 0 then
        self.request_List[uid] = nil
    end
    self.model:CheckReq()
    self.model:CheckRedPoint()
    Connection.Instance:send(11805, {flag = flag, name = name, id = id, platform = platform, zone_id = zone_id})
    return true
end

function FriendManager:On11805(data)
    -- BaseUtils.dump(data, "On11805")

end

--拉黑
function FriendManager:Require11806(id,platform,zone_id)
    Connection.Instance:send(11806, {id = id, platform = platform, zone_id = zone_id})
end

function FriendManager:On11806(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--删除好友/取消拉黑
function FriendManager:Require11807(id, platform, zone_id)
    Connection.Instance:send(11807, {id = id, platform = platform, zone_id = zone_id})
    local uid = BaseUtils.Key( id,  platform, zone_id)
    self.model:DeleteFriend(uid)
end

function FriendManager:On11807(data)
    -- BaseUtils.dump(data, "On11807")
    if data.msg ~= nil then
        NoticeManager.Instance:FloatTipsByString(TI18N(data.msg))
    end
end

-- 查找玩家
function FriendManager:Require11808(name, isTips)
    if name == RoleManager.Instance.RoleData.name then
        NoticeManager.Instance:FloatTipsByString(TI18N("这是您自己"))
        return
    end
    self.isTips = isTips
    Connection.Instance:send(11808, {name = name})
end

function FriendManager:On11808(data)
    -- BaseUtils.dump(data, "On11808")
    if self.isTips == true then
        self.isTips = false
        TipsManager.Instance:ShowPlayer(data)
        return
    end
    if data.name == "" then
        NoticeManager.Instance:FloatTipsByString(TI18N("玩家不存在"))
    else
        if self:IsFriend(data.id, data.platform, data.zone_id) then
            NoticeManager.Instance:FloatTipsByString(TI18N("已经是好友"))
        else
            self:Require11804(data.id, data.platform, data.zone_id)
        end
    end
end

--收到申请好友推送
function FriendManager:Require11809()
    Connection.Instance:send(11809, {})
end

function FriendManager:On11809(data)
    -- BaseUtils.dump(data, "On11809,收到申请好友推送##################")
    local uid = BaseUtils.Key(data.id, data.platform,data.zone_id)
    if self.reject == true then
        self:Require11805(0, data.name, data.id, data.platform, data.zone_id)
        return
    end
    data.time = Time.time
    self.request_List[uid] = data
    local num = 0
    local lastuid = nil
    local lasttime = 9999999999
    for k,v in pairs(self.request_List) do
        num = num + 1
        if v.time <= lasttime then
            lastuid = k
            lasttime = v.time
        end
    end
    if num > 20 and lastuid ~= nil then
        self:Require11805(0, self.request_List[lastuid].name, self.request_List[lastuid].id, self.request_List[lastuid].platform, self.request_List[lastuid].zone_id)
        self.request_List[lastuid] = nil
    else
        self.noReadReq = self.noReadReq + 1
    end
    self.model:CheckReq()
    self.model:CheckRedPoint()
    self:CheckMainUIIconRedPoint()
    MainUIManager.Instance.noticeView:set_friendnotice_num(self.noReadReq + #FriendGroupManager.Instance.groupinviteData)
end

--推荐好友信息
function FriendManager:Require11810()
    Connection.Instance:send(11810, {})
end

function FriendManager:On11810(data)
    -- BaseUtils.dump(data, "On11810")
    self.pushList = data.list
    self.model:ShowPushPlayer()
end

--未处理的好友申请
function FriendManager:Require11811()
    Connection.Instance:send(11811, {})
end

function FriendManager:On11811(data)
    -- BaseUtils.dump(data, "On11811")
    self.request_List = {}
    for k,v in pairs(data.friend_request) do
        local uid = BaseUtils.Key(v.id, v.platform,v.zone_id)
        v.time = Time.time +0.1*k
        if self.reject == true or k>20 then
            self:Require11805(0, v.name, v.id, v.platform, v.zone_id)
        else
            self.request_List[uid] = v
        end
    end
    if self.reject == true then
        return
    end
    self.model:CheckReq()
    self.model:CheckRedPoint()
    self:CheckMainUIIconRedPoint()
end

--跨服好友状态更新
function FriendManager:Require11855()
    Connection.Instance:send(11855, {})
end

function FriendManager:On11855(data)
    -- BaseUtils.dump(data, "On11855")
    self.lastUpdate = Time.time
    for k,v in pairs(data.friend_role) do
        local uid = BaseUtils.Key(v.id, v.platform, v.zone_id)
        for kk,vv in pairs(v) do
            self.friend_List[uid][kk] = vv
        end
    end
    self.model:UpdataFriendList()
    self.model:CheckReq()
    self.model:CheckRedPoint()
    self:GetOnlineList()
    self:GetCrossSortFriendList()
end

-- 离线推送设置
function FriendManager:Require11888(offline_push)
    self:Send(11888, {offline_push = offline_push})
end

function FriendManager:Send11889(itemId)
    self:Send(11889, {item_id = itemId})
end

function FriendManager:Send11890(itemId,message)
    self:Send(11890, {id = itemId,msg = message})
end

function FriendManager:On11888(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function FriendManager:On11889(data)
    if data ~= nil then
        EventMgr.Instance:Fire(event_name.award_captain_back,data)
    end
end
function FriendManager:On11890(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end
function FriendManager:On11891(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end
--------------------邮件协议------------------------------

--邮件列表
function FriendManager:Require13400()
    Connection.Instance:send(13400, {})
end

function FriendManager:On13400(data)
    -- BaseUtils.dump(data, "On13400邮件信息")
    self.mail_List = {}
    for i,v in ipairs(data.mail_list) do
        local uid = BaseUtils.Key(v.sess_id, v.platform, v.zone_id)
        if v.type == 2 then
            self.guildmail_List[uid] = v
        elseif v.type == 1 then
            self.mail_List[uid] = v
        elseif v.type == 3 then
            self.announce_list[uid] = v
        end
    end

    self.model:CheckRedPoint()
    self:CheckMainUIIconRedPoint()
    if(self.model.friendWin == nil or self.model.friendWin.isshow == false) then
        local noreadnum = self:GetUnReadMailNum()
        MainUIManager.Instance.noticeView:set_mailnotice_num(noreadnum)
        if noreadnum > 0 then
            SoundManager.Instance:Play(257)
        end
    else
        MainUIManager.Instance.noticeView:set_mailnotice_num(0)
    end
end


--标记邮件为已读
function FriendManager:Require13401(sess_id, platform, zone_id)
    Connection.Instance:send(13401, {sess_id = sess_id, platform = platform, zone_id = zone_id})
end

function FriendManager:On13401(data)
    -- BaseUtils.dump(data, "On13401")
    local uid = BaseUtils.Key(data.sess_id, data.platform, data.zone_id)
    if self.mail_List[uid] == nil then
        return
    end
    self.mail_List[uid].status = 1
    self.model:CheckRedPoint()
    self:CheckMainUIIconRedPoint()
end


--收取邮件
function FriendManager:Require13402(sess_id, platform, zone_id, type)
    if type < 3 then
        Connection.Instance:send(13402, {sess_id = sess_id, platform = platform, zone_id = zone_id})
    else
        AnnounceManager.Instance:send9923(sess_id)
    end
end

function FriendManager:On13402(data)
    -- BaseUtils.dump(data, "On13402")
    if data.result == 1 then
        local uid = BaseUtils.Key(data.sess_id, data.platform, data.zone_id)
        if self.mail_List[uid] ~= nil then
            -- self.mail_List[uid].item_list = {}
            self.mail_List[uid].item_list.get = true
            if self.mail_List[uid].status ~= 1 then
                self:Require13401(self.mail_List[uid].sess_id, self.mail_List[uid].platform, self.mail_List[uid].zone_id)
            end
        elseif self.announce_list[uid] ~= nil then

            self.announce_list[uid].item_list = {}
            self.announce_list[uid].item_list.get = true
        end
        self.model:GetMailItemSucc(self.mail_List[uid])
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


--删除邮件
function FriendManager:Require13403(sess_id, platform, zone_id, type)
    if type < 3 then
        Connection.Instance:send(13403, {sess_id = sess_id, platform = platform, zone_id = zone_id})
    else
        Connection.Instance:send(9922, {id = sess_id})
    end
end

function FriendManager:On13403(data)
    -- BaseUtils.dump(data, "On13403")
    if data.result == 1 then
        local uid = BaseUtils.Key(data.sess_id, data.platform, data.zone_id)
        -- self.mail_List[uid] = nil
        if data.type == 1 then
            self.mail_List[uid] = nil
        elseif data.type == 2 then
            self.guildmail_List[uid] = nil
        elseif data.type == 3 then
            self.announce_list[uid] = nil
        end
    end
    self.model:CheckRedPoint()
    self:CheckMainUIIconRedPoint()
end


--新加列表
function FriendManager:Require13404()
    Connection.Instance:send(13404, {})
end

function FriendManager:On13404(data)
    -- BaseUtils.dump(data, "On13404")
    for i,v in ipairs(data.mail_list) do
        local uid = BaseUtils.Key(v.sess_id, v.platform, v.zone_id)
        if v.type == 1 then
            self.mail_List[uid] = v
        elseif v.type == 2 then
            self.guildmail_List[uid] = v
        elseif v.type == 3 then
            self.announce_list[uid] = v
        end
    end
    if(self.model.friendWin == nil or self.model.friendWin.isshow == false) and MainUIManager.Instance.noticeView ~= nil then
        local noreadnum = self:GetUnReadMailNum()
        MainUIManager.Instance.noticeView:set_mailnotice_num(noreadnum)
    elseif MainUIManager.Instance.noticeView ~= nil then
        MainUIManager.Instance.noticeView:set_mailnotice_num(0)
    end
    self.model:UpdateMailList()
    self.model:CheckRedPoint()
    self:CheckMainUIIconRedPoint()
end

--公会邮件标记已读
function FriendManager:Require13405(sess_id, platform, zone_id)
    Connection.Instance:send(13405,  {sess_id = sess_id, platform = platform, zone_id = zone_id})
end


function FriendManager:On13405(data)
    -- BaseUtils.dump(data, "On13405")
    local uid = BaseUtils.Key(data.sess_id, data.platform, data.zone_id)
    self.guildmail_List[uid].status = 1
    self.model:CheckRedPoint()
    self:CheckMainUIIconRedPoint()
end
------------数据处理

function FriendManager:OnConnect()
    if self.model.friendWin ~= nil then
        self.model.friendWin.cacheMode = CacheMode.Destroy
        self.model:CloseMain()
    end
    self.mail_List = {}
    self.guildmail_List = {}
    if self.announce_list == nil or next(self.announce_list) == nil then
        self.announce_list = {}
    end

    self:Require11800()
    self:Require11801()
    -- self:Require11802()
    self:Require11811()
    self:Require13400()
    ChatManager.Instance:Send10412()
    self:LoadChatLog()

end

function FriendManager:AddFriend(id, platform, zone_id)
    self:Require11804(id, platform, zone_id)
end

function FriendManager:DeleteFriend(id, platform, zone_id)
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = TI18N("你确定要删除该好友吗？")
    data.sureLabel = TI18N("删除")
    data.cancelLabel = TI18N("取消")
    data.sureCallback = function()
            if self:GetIntimacy(id, platform, zone_id) > 0 then
                local data2 = NoticeConfirmData.New()
                data2.type = ConfirmData.Style.Normal
                data2.content = string.format(TI18N("删除好友将清空与TA的亲密度（当前亲密度<color='#00ff00'>%s</color>）"), tostring(self:GetIntimacy(id, platform, zone_id)))
                data2.sureLabel = TI18N("确定")
                data2.cancelLabel = TI18N("取消")
                data2.blueSure = true
                data2.sureCallback = function()
                        self:Require11807(id, platform, zone_id)
                    end
                LuaTimer.Add(200, function() NoticeManager.Instance:ConfirmTips(data2) end)
            else
                self:Require11807(id, platform, zone_id)
            end
        end
    NoticeManager.Instance:ConfirmTips(data)
end

-- 查找该玩家是否为好友
function FriendManager:IsFriend(id, platform, zone_id)
    local uid = BaseUtils.Key(id, platform, zone_id)
    if self.friend_List[uid] ~= nil then
        return true
    else
        return false
    end
end

-- 排序的好友列表 type 1 :全部 2 ： 本服  3：跨服  4：黑名单
function FriendManager:GetSortFriendList(type)
    local temp = {}
    if type == FriendType.Black then 
        for k,v in pairs(self.blackfriend_List) do
            table.insert(temp, v)
        end
    else 
        for k,v in pairs(self.friend_List) do
            if type == nil or type == 1 then
                table.insert(temp, v)
            elseif type == 2 and BaseUtils.IsTheSamePlatform(v.platform, v.zone_id) then
                table.insert(temp, v)
            elseif type == 3 and not BaseUtils.IsTheSamePlatform(v.platform, v.zone_id) then
                table.insert(temp, v)
            end
        end
    end

    local teachermodel = TeacherManager.Instance.model
    local function sort(a,b)
        local a_teacher, a_status = teachermodel:IsMyTeacher(a)
        local b_teacher, b_status = teachermodel:IsMyTeacher(b)
        if a.online > b.online then
            return true
        elseif a.online < b.online then
            return false
        elseif a_teacher and a_status == 1 and not b_teacher then
            return true
        elseif b_teacher and b_status == 1 and not a_teacher then
            return false
        elseif a.intimacy > b.intimacy then
            return true
        elseif a.id > b.id and a.intimacy == b.intimacy then
            return true
        else
            return false
        end
    end
    table.sort( temp, sort)

    return temp
end

function FriendManager:GetCrossSortFriendList()
    local temp = {}
    for k,v in pairs(self.friend_List) do
        if not BaseUtils.IsTheSamePlatform(v.platform, v.zone_id) then
            table.insert(temp, v)
            self.crossfriend_List[k] = v
        end
    end
    table.sort( temp, function(a,b) return (a.online > b.online ) or (a.online == b.online and a.intimacy > b.intimacy) or (a.intimacy == b.intimacy and a.online == b.online and a.id > b.id) end )
    return temp
end
--获取请求列表
function FriendManager:GetReqList()
    for k,v in pairs(self.request_List) do
        if self:IsFriend(v.id, v.platform, v.zone_id) then
            self.request_List[k] = nil
        end
    end
    return self.request_List
end

--获取在线列表
function FriendManager:GetOnlineList()
    local temp = {}
    for k,v in pairs(self.friend_List) do
        if v.online == 1 and BaseUtils.IsTheSamePlatform(v.platform, v.zone_id) then
            table.insert(temp, v)
        end
    end
    self.online_friend_List = temp
    table.sort( self.online_friend_List, function(a,b) return a.intimacy>b.intimacy or (a.intimacy == b.intimacy and a.id > b.id) end )
    return self.online_friend_List
end

--获取在线列表(包括跨服好友)
function FriendManager:GetCrossOnlineList()
    local temp = {}
    for k,v in pairs(self.friend_List) do
        if v.online == 1 then
            table.insert(temp, v)
        end
    end
    table.sort( temp, function(a,b) return a.intimacy>b.intimacy or (a.intimacy == b.intimacy and a.id > b.id) end )
    return temp
end

--获取黑名单列表(排好序)
function FriendManager:GetBlackFriendList()
    local temp = {}
    for k,v in pairs(self.blackfriend_List) do
        table.insert(temp, v)
    end
    table.sort( temp, function(a,b) return a.online > b.online or (a.online == b.online and a.id > b.id) end )
    return temp
end

--获取好友数量
function FriendManager:GetFriendNum(isCross)
    local num = 0
    for k,v in pairs(self.friend_List) do
        if (isCross ~= BaseUtils.IsTheSamePlatform(v.platform, v.zone_id)) then
            num = num + 1
        end
    end
    return num
end

--好友请求数量
function FriendManager:GetReqNum()
    local num = 0
    for k,v in pairs(self.request_List) do
        if self:IsFriend(v.id, v.platform, v.zone_id) then
            self.request_List[k] = nil
        else
            num = num + 1
        end
    end
    return num
end

--未读邮件数量
function FriendManager:GetUnReadMailNum()
    local num = 0
    for k,v in pairs(self.mail_List) do
        if v.status == 0 then
            num = num + 1
        end
    end
    return num
end

function FriendManager:GetUnReadGuildMailNum()
    local num = 0
    for k,v in pairs(self.guildmail_List) do
        if v.status == 0 then
            num = num + 1
        end
    end
    return num
end

--判断主UI红点
function FriendManager:CheckMainUIIconRedPoint()
    local reqnum = self:GetReqNum()
    local noreadnum = self:GetUnReadMailNum()
    local guildnoreadnum = self:GetUnReadGuildMailNum()
    local announceNum = self:GetUnReadAnnounceMailNum()

    local group_reqnum = FriendGroupManager.Instance:GetInviteNum()
    local group_noreadnum = FriendGroupManager.Instance:GetNoReadMsgNum()

    if MainUIManager.Instance.MainUIIconView ~= nil then
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(25, group_reqnum > 0 or group_noreadnum > 0 or reqnum>0 or guildnoreadnum >0 or noreadnum>0 or announceNum > 0 or next(self.currHasMsg) ~= nil)
    end
end

--最近私聊非黑名单列表（非好友>好友，在线>离线）
function FriendManager:GetSecondSortChatlist()
    local temp = {}
    for k,v in pairs(self.currchat_List) do
        if not table.containKey(self.blackfriend_List,k) then 
            table.insert(temp, v)
        end
    end
    table.sort(temp, function(a,b) 
        if self:IsFriend(a.id, a.platform, a.zone_id) ~= self:IsFriend(b.id, b.platform, b.zone_id)  then 
            return not self:IsFriend(a.id, a.platform, a.zone_id)
        end

        --防报错 
        if a.online and b.online then 
            if a.online ~= b.online then 
                return a.online < b.online
            end
        end
        return a.recvTime > b.recvTime
    end)
    
    local temp2 = {}
    if #temp > 30 then
        for i = 1, 30 do
            table.insert(temp2, temp[i])
        end
        temp = temp2
    end
    return temp
end

--最近私聊的列表(接收消息先后排序)
function FriendManager:GetSortChatlist()
    local temp = {}
    for k,v in pairs(self.currchat_List) do
        table.insert(temp, v)
    end
    table.sort(temp, function(a,b) return a.recvTime > b.recvTime end)
    local temp2 = {}
    if #temp > 30 then
        for i = 1, 30 do
            table.insert(temp2, temp[i])
        end
        temp = temp2
    end
    return temp
end


function FriendManager:AddNewMsg(data)
    local selfuid = BaseUtils.Key("_",RoleManager.Instance.RoleData.id, RoleManager.Instance.RoleData.platform, RoleManager.Instance.RoleData.zone_id)
    local targetuid = BaseUtils.Key(data.t_id, data.t_platform, data.t_zone_id)
    local recvuid = BaseUtils.Key("_",data.id, data.platform, data.zone_id)
    -- print("UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU"..selfuid)
    -- print("OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO"..recvuid)
    -- print("qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq"..targetuid)

    if selfuid == recvuid then
        data.isself = true
    else
        SoundManager.Instance:Play(257)
        targetuid = BaseUtils.Key(data.id, data.platform, data.zone_id)
    end
    if self.currchat_List[targetuid] == nil then
        self.currchat_List[targetuid] = self.friend_List[targetuid]
    end
    if self.friend_List[targetuid] == nil and data.isself ~= true then
        data.online = 1 
        self.currchat_List[targetuid] = data
    end
    if self.currchat_List[targetuid] == nil then
        return
    end
    self.currchat_List[targetuid].recvTime = BaseUtils.BASE_TIME
    data.recvTime = BaseUtils.BASE_TIME
    local key = BaseUtils.Key(selfuid,targetuid)

    -- 20180414 仙侠线上服会出现多人聊天卡死的情况。可能是这种写法有问题。
    if self.chatData[key] == nil then
        self.chatData[key] = {}
        table.insert( self.chatData[key], data )
    else
        if #self.chatData[key] >30 then
            local length = #self.chatData[key]
            local temp = {}
            for i = length - 24, length do
                table.insert( temp, self.chatData[key][i] )
            end
            table.insert( temp, data )
            self.chatData[key] = temp
        else
            table.insert( self.chatData[key], data )
        end
    end
    -- if self.chatData[key] == nil then
    --     self.chatData[key] = {}
    -- else
    --     if #self.chatData[key] >20 then
    --         table.remove(self.chatData[key], 1)
    --     end
    -- end
    -- table.insert( self.chatData[key], data )

    if not data.isself then
        self.currHasMsg[targetuid] = self.currHasMsg[targetuid] == nil and 1 or self.currHasMsg[targetuid]+1
    end
    self.model:CheckRedPoint()
    self.model:UpdateChatMsg()
    if (self.model.friendWin == nil or self.model.friendWin.isshow == false) or self.model.chatTarget ~= targetuid then
        self:CheckMainUIIconRedPoint()
    end
    local num = 0
    for k,v in pairs(self.currHasMsg) do
        num = num + v
    end
    if data.isself ~= true and(self.model.friendWin == nil or self.model.friendWin.isshow == false) then
        self.noReadMsg = num
        print(string.format("Friend:%s,Group:%s", tostring(self.noReadMsg), tostring(FriendGroupManager.Instance.noReadMsg)))
        MainUIManager.Instance.noticeView:set_chatnotice_num(self.noReadMsg + FriendGroupManager.Instance.noReadMsg)
    end
    self:SaveChatLog()
end

--获取聊天记录
function FriendManager:GetChatLog(uid)
    local selfuid = BaseUtils.Key("_", RoleManager.Instance.RoleData.id, RoleManager.Instance.RoleData.platform, RoleManager.Instance.RoleData.zone_id)
    local key = BaseUtils.Key(selfuid,uid)
    if self.chatData[key] == nil then
        return {}
    else
        return self.chatData[key]
    end
end

--删除聊天记录
function FriendManager:ClearChatLog(uid)
    local selfuid = BaseUtils.Key("_",RoleManager.Instance.RoleData.id, RoleManager.Instance.RoleData.platform, RoleManager.Instance.RoleData.zone_id)
    local key = BaseUtils.Key(selfuid,uid)
    self.chatData[key] = nil
    self:SaveChatLog()
end

function FriendManager:RecMsg(data)
    self:AddNewMsg(data)
end

function FriendManager:SendMsg(id, platform, zone_id, msg)
    local key = string.format("%s_%s_%s", id, platform, zone_id)
    if ShieldManager.Instance:CheckIsSheild(key) then
        NoticeManager.Instance:FloatTipsByString(TI18N("你已将对方屏蔽，无法发送私聊，请先<color='#ffff00'>取消屏蔽</color>。"))
        return
    end

    if ctx.PlatformChanleId == 110 then
        -- 暂时只有乐视渠道处理过滤
        print("报警啦")
        msg = MessageFilter.Parse(msg)
    end

    msg = string.gsub(msg, "<.->", "")
    -- local targetuid = BaseUtils.Key(id, platform, zone_id)
    local send_msg = MessageParser.ConvertToTag_Face(msg)
    -- local data = ChatData.New()
    -- data.rid = id
    -- data.id = id
    -- data.platform = platform
    -- data.zone_id = zone_id
    -- data.msg = send_msg
    -- data.name = RoleManager.Instance.RoleData.name
    -- data.sex = RoleManager.Instance.RoleData.sex
    -- data.lev = RoleManager.Instance.RoleData.lev
    -- data.classes = RoleManager.Instance.RoleData.classes
    -- data.guild = RoleManager.Instance.RoleData.guild_nam
    -- data.channel = MsgEumn.ChatChannel.Private
    -- data.prefix = MsgEumn.ChatChannel.Private
    -- data.msgData = MessageParser.GetMsgData(send_msg)
    -- data.showType = MsgEumn.ChatShowType.Normal
    -- data.isself = true
    -- self:AddNewMsg(data)
    ChatManager.Instance:Send10402(id, platform, zone_id, send_msg)
end


function FriendManager:AddUnknowMan(data)
    local targetuid = BaseUtils.Key(data.id, data.platform, data.zone_id)
    if targetuid == nil then
        targetuid = BaseUtils.Key(data.rid, data.platform, data.zone_id)
    end
    data.recvTime = BaseUtils.BASE_TIME
    data.online = 1 
    self.currchat_List[targetuid] = data
end

function FriendManager:TalkToUnknowMan(data, type)
    local targetuid = BaseUtils.Key(data.id, data.platform, data.zone_id)
    if targetuid == nil then
        targetuid = BaseUtils.Key(data.rid, data.platform, data.zone_id)
    end
    self:AddUnknowMan(data)
    self.model.chatTarget = targetuid
    self.model.chatTargetInfo = {id = data.id, platform = data.platform, zone_id = data.zone_id}

    self.model.isAutoSend = type

    self.model:OpenWindow()
end

--好友消息数量
function FriendManager:GetFriendMsgNum()
    local num = 0
    for k,v in pairs(self.currHasMsg) do
        if k ~= self.model.chatTarget and self.friend_List[k] ~= nil then
            num = num +1
        end
    end
    return num
end


function FriendManager:GetCrossFriendMsgNum()
    local num = 0
    for k,v in pairs(self.currHasMsg) do
        if k ~= self.model.chatTarget and self.crossfriend_List[k] ~= nil then
            num = num +1
        end
    end
    return num
end

--非好友消息数量
function FriendManager:GetNotFriendMsgNum()
    local num = 0
    for k,v in pairs(self.currHasMsg) do
        if k ~= self.model.chatTarget and self.friend_List[k] == nil then
            num = num +1
        end
    end
    return num
end

function FriendManager:GetIntimacy(id, platform, zone_id)
    local uid = BaseUtils.Key(id, platform, zone_id)
    if self.friend_List[uid] ~= nil then
        return self.friend_List[uid].intimacy
    else
        return 0
    end
end

function FriendManager:OnGuildStatusChange()
    self.guildmail_List = {}
    self.model:CheckRedPoint()
    self:CheckMainUIIconRedPoint()
end

function FriendManager:GetUnReadAnnounceMailNum()
    local num = 0
    if self.announce_list ~= nil then
        for k,v in pairs(self.announce_list) do
            if v.status == 0 then
                num = num + 1
            end
        end
    end
    return num
end

function FriendManager:SaveChatLog()
    -- BaseUtils.dump(self.chatData, "啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊")
    local temp = BaseUtils.copytab(self.chatData)
    for i,v in pairs(self.chatData) do
        if #v > 20 then
            local stari = #v - 19
            local endi = #v
            temp[i] = {}
            for key = stari, endi do
                local data = BaseUtils.copytab(self.chatData[i][key])
                data._class_type = nil
                -- if data.msgData.showType == MsgEumn.ChatShowType.Voice then
                    local showString = data.msgData.showString

                    data.msgData = {}
                    data.msgData.showString = showString
                    data.msgData.pureString = showString
                    data.cacheId = 0
                -- else
                --     data.msgData = "nil"
                -- end
                data.DeleteMe = "nil"
                table.insert(temp[i], data)
            end
        end
    end

    LocalSaveManager.Instance:writeFile(self.selfuid, temp)
    if self.chatData == nil then
        self.chatData = {}
    end
end

function FriendManager:LoadChatLog()
    self.selfuid = BaseUtils.Key("_", RoleManager.Instance.RoleData.id, RoleManager.Instance.RoleData.platform, RoleManager.Instance.RoleData.zone_id)
    self.chatData = LocalSaveManager.Instance:getFile(self.selfuid)
    if self.chatData == nil then
        self.chatData = {}
    end
    -- BaseUtils.dump(self.chatData, "<color='#ff0000'>取出来</color>")
    local dirtyList = {}
    for i,v in pairs(self.chatData) do
        local dirty = false
        for ii,vv in ipairs(v) do
            if self.chatData[i][ii].msgData ~= nil then
                local showString = self.chatData[i][ii].msgData.showString
                self.chatData[i][ii].cacheId = 0
                local msgData = MessageParser.GetMsgData(self.chatData[i][ii].msg)
                for k,v in pairs(msgData.elements) do
                    msgData.elements[k].noRoll = true
                end
                self.chatData[i][ii].msgData = msgData
                self.chatData[i][ii].msgData.showString = showString
                self.chatData[i][ii].msgData.pureString = showString
                self.chatData[i][ii].msgData.sourceString = showString
                if showString == nil then
                    dirty = true
                    self.chatData[i][ii].msgData.showString = TI18N("消息记录发生错误,清手动清空消息")
                end
            else
                local msgData = MessageParser.GetMsgData(self.chatData[i][ii].msg)
                for k,v in pairs(msgData.elements) do
                    msgData.elements[k].noRoll = true
                end
                self.chatData[i][ii].msgData = msgData
                if self.chatData[i][ii].msgData.showString == nil then
                    dirty = true
                    self.chatData[i][ii].msgData.showString = TI18N("消息记录发生错误,清手动清空消息")
                end
            end
        end
        if dirty then
            table.insert(dirtyList, i)
        end
    end
    for i,v in ipairs(dirtyList) do
        self.chatData[v] = {}
    end
    -- BaseUtils.dump(self.chatData, "<color='#ff0000'>处理好</color>")
end

-- {uint32, id, "发送者角色ID"}
-- ,{string, platform, "平台标识"}
-- ,{uint16, zone_id, "区号"}
-- ,{string, name, "发送者名称"}
-- ,{uint32, face, "头像"}
-- ,{uint8, sex, "性别"}
-- ,{uint8, lev, "等级"}
-- ,{uint8, classes, "职业"}
-- ,{string, guild, "公会名称"}
-- ,{string, msg, "聊天内容"}
