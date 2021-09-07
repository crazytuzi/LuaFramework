FriendGroupManager = FriendGroupManager or BaseClass(BaseManager)

function FriendGroupManager:__init()
    if FriendGroupManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
        return
    end
    FriendGroupManager.Instance = self
    self.model = FriendGroupModule.New()
    self.groupList = {}
    self.groupData = {}
    self.groupinviteData = {}
    self.tempMsgList = {}
    self.chatData = {}
    self.currHasMsg = {}
    self.noticeList = {}
    self.noReadInvite = 0
    self.noReadMsg = 0
    self.hasCreateNewGroup = false
    self.newGroupData = nil
    self.OnGroupDataUpdate = EventLib.New() -- 群组数据更新
    self.OnGroupListUpdate = EventLib.New() -- 群组列表更新
    self.OnInviteDataUpdate = EventLib.New() -- 群组邀请更新
    self:InitHandler()
end

function FriendGroupManager:InitHandler()
    self:AddNetHandler(19000, self.On19000)
    self:AddNetHandler(19001, self.On19001)
    self:AddNetHandler(19002, self.On19002)
    self:AddNetHandler(19003, self.On19003)
    self:AddNetHandler(19004, self.On19004)
    self:AddNetHandler(19005, self.On19005)
    self:AddNetHandler(19006, self.On19006)
    self:AddNetHandler(19007, self.On19007)
    self:AddNetHandler(19008, self.On19008)
    self:AddNetHandler(19009, self.On19009)
    self:AddNetHandler(19010, self.On19010)
    self:AddNetHandler(19011, self.On19011)
    self:AddNetHandler(19012, self.On19012)
    self:AddNetHandler(19013, self.On19013)
    self:AddNetHandler(19014, self.On19014)
    -------------------------------------------------

end

function FriendGroupManager:RequestInitData()
    self:Require19001()
    self:Require19009()
    self:LoadChatLog()
end

function FriendGroupManager:InitData()
    self.groupList = {}
    self:InsertDefaultData(self.groupList)
end

function FriendGroupManager:InsertDefaultData(mytable)
    if self.data19001 ~= nil and self.data19001.create < 2 then
        local temp = {}
        temp.owner_sex = 0
        temp.owner_classes = 0
        temp.group_name = ""
        temp.group_zone_id = 0
        temp.owner_name = TI18N("新建群组")
        temp.group_content = ""
        temp.role_rid = 0
        temp.role_platform = ""
        temp.time = -1
        temp.role_zone_id = 0
        temp.group_rid = 0
        temp.group_platform = ""
        table.insert(mytable, temp)
    end
    if #self.groupinviteData > 0 then
        local temp2 = {}
        temp2.owner_sex = 0
        temp2.owner_classes = 0
        temp2.group_name = ""
        temp2.group_zone_id = 0
        temp2.owner_name = TI18N("群组邀请")
        temp2.group_content = ""
        temp2.role_rid = 0
        temp2.role_platform = ""
        temp2.time = math.huge
        temp2.role_zone_id = 0
        temp2.group_rid = 0
        temp2.group_platform = ""
        table.insert(mytable, temp2)
    end
    return mytable
end

-------群组协议-----------
--查看自身群组数据
function FriendGroupManager:Require19000(group_rid, group_platform, group_zone_id)
    Connection.Instance:send(19000, {group_rid = group_rid, group_platform = group_platform, group_zone_id = group_zone_id})
end

function FriendGroupManager:On19000(data)
    -- BaseUtils.dump(data, "On19000")
    local key = BaseUtils.Key(data.group_id, data.group_platform, data.group_zone_id)
    self.groupData[key] = data


    for k,v in pairs(data.members) do
        if v.post == 1 then
            self.groupData[key].owner_id = v.role_rid
            self.groupData[key].owner_platform = v.role_platform
            self.groupData[key].owner_zone_id = v.role_zone_id
        end
    end
    self.OnGroupDataUpdate:Fire()
    if self.model.foropeninfo then
        self.model:OpenInfoPanel({data.group_id, data.group_platform, data.group_zone_id})
    end
    local roleData = RoleManager.Instance.RoleData
    for k,v in pairs(data.members) do
        if v.role_rid == roleData.id and v.role_platform == roleData.platform and v.role_zone_id == roleData.zone_id then
            self.noticeList[key] = v.notice == 1
        end
    end
    if self.tempMsgList[key] ~= nil then
        local temp = BaseUtils.copytab(self.tempMsgList[key])
        self.tempMsgList[key] = nil
        for i,v in ipairs(temp) do
            self:ReceiveMsg(v)
        end
    end
end

-- 群组列表
function FriendGroupManager:Require19001()
    Connection.Instance:send(19001, {})
end

function FriendGroupManager:On19001(data)
    -- BaseUtils.dump(data, "On19001")
    local newkey = nil
    if self.hasCreateNewGroup then
        for i,v in ipairs(data.groups) do
            local key = BaseUtils.Key(v.group_rid, v.group_platform, v.group_zone_id)
            local old = false
            for k,vv in pairs(self.data19001.groups) do
                local key2 = BaseUtils.Key(vv.group_rid, vv.group_platform, vv.group_zone_id)
                if key == key2 then
                    old = true
                    break
                end
            end
            if not old then
                newkey = key
                self.newGroupData = v
                break
            end
        end
    end
    local removeGroup = {}
    if self.data19001 ~= nil then
        for i,v in ipairs(self.data19001.groups) do
            local key = BaseUtils.Key(v.group_rid, v.group_platform, v.group_zone_id)
            local has = false
            for k,vv in pairs(data.groups) do
                local key2 = BaseUtils.Key(vv.group_rid, vv.group_platform, vv.group_zone_id)
                if key == key2 then
                    has = true
                    break
                end
            end
            if not has then
                table.insert(removeGroup, key)
                break
            end
        end
    end
    for i,v in ipairs(removeGroup) do
        self.groupData[v] = nil
        local gkey = BaseUtils.Key("_G", v)
        self.currHasMsg[gkey] = nil
        if key ~= nil then
            FriendManager.Instance.currchat_List[key] = nil
        end
    end
    self.data19001 = data
    for k,v in pairs(self.data19001.groups) do
        local key = BaseUtils.Key(v.group_rid, v.group_platform, v.group_zone_id)
        if self.groupData[key] == nil then
            self:Require19000(v.group_rid, v.group_platform, v.group_zone_id)
        end
    end
    if self.hasCreateNewGroup then
        self.model:OpenInfoPanel({self.newGroupData.group_rid, self.newGroupData.group_platform, self.newGroupData.group_zone_id})
        self.hasCreateNewGroup = false
    end
    self.OnGroupListUpdate:Fire()
end

-- 群组创建
function FriendGroupManager:Require19002(name)
    Connection.Instance:send(19002, {name = name})
end

function FriendGroupManager:On19002(data)
    -- BaseUtils.dump(data, "On19002")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        self.hasCreateNewGroup = true
        if self.newGroupData ~= nil then
            print(self.newGroupData, "数据")
            self.model:OpenInfoPanel({self.newGroupData.group_rid, self.newGroupData.group_platform, self.newGroupData.group_zone_id})
            self.hasCreateNewGroup = false
            self.newGroupData = nil
        end
        self.model:CloseCreatePanel()
    end
end

-- 发起邀请
function FriendGroupManager:Require19003(id, platform, zone_id, role_id, role_platform, role_zone_id)
    Connection.Instance:send(19003, {id = id, platform = platform, zone_id = zone_id, role_id = role_id, role_platform = role_platform, role_zone_id = role_zone_id})
end

function FriendGroupManager:On19003(data)
    -- BaseUtils.dump(data, "On19003")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 退出
function FriendGroupManager:Require19004(id, platform, zone_id)
    Connection.Instance:send(19004, {id = id, platform = platform, zone_id = zone_id})
end

function FriendGroupManager:On19004(data)
    -- BaseUtils.dump(data, "On19004")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        self.model:CloseInfoPanel()
    end
end

-- 群组解散
function FriendGroupManager:Require19005(id, platform, zone_id)
    Connection.Instance:send(19005, {id = id, platform = platform, zone_id = zone_id})
end

function FriendGroupManager:On19005(data)
    -- BaseUtils.dump(data, "On19005")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        self.model:CloseInfoPanel()
    end
end

-- 群组列表
function FriendGroupManager:Require19006(name, id, platform, zone_id)
    Connection.Instance:send(19006, {name = name, id = id, platform = platform, zone_id = zone_id})
end

function FriendGroupManager:On19006(data)
    -- BaseUtils.dump(data, "On19006")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 修改群组公告
function FriendGroupManager:Require19007(content, id, platform, zone_id)
    Connection.Instance:send(19007, {content = content, id = id, platform = platform, zone_id = zone_id})
end

function FriendGroupManager:On19007(data)
    -- BaseUtils.dump(data, "On19007")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 踢出成员
function FriendGroupManager:Require19008(id, platform, zone_id, role_id, role_platform, role_zone_id)
    Connection.Instance:send(19008, {id = id, platform = platform, zone_id = zone_id, role_id = role_id, role_platform = role_platform, role_zone_id = role_zone_id})
end

function FriendGroupManager:On19008(data)
    -- BaseUtils.dump(data, "On19008")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 收到邀请
function FriendGroupManager:Require19009()
    Connection.Instance:send(19009, {})
end

function FriendGroupManager:On19009(data)
    --BaseUtils.dump(data, "<color='#f99023'>On19009</color>")
    data.reqs = {
        [1] = {
            group_name = "sa哈哈哒d",
            role_classes = 1,
            group_platform = "dev",
            role_sex = 0,
            role_lev = 100,
            time = 1492423022,
            role_rid = 1,
            role_platform = "dev",
            role_name = "布里伊雪",
            role_zone_id = 1,
            group_zone_id = 1,
            group_rid = 76,
            isapply = true
        },
        [2] = {
            group_name = "哈哈哒d",
            role_classes = 1,
            group_platform = "dev",
            role_sex = 0,
            role_lev = 100,
            time = 1492423082,
            role_rid = 1,
            role_platform = "dev",
            role_name = "布里伊雪",
            role_zone_id = 1,
            group_zone_id = 1,
            group_rid = 76,
        },
    }

    self.groupinviteData = {}
    -- for k,v in pairs(data.reqs) do
    --     table.insert(self.groupinviteData, v)
    -- end
    for k,v in pairs(data.inviteds) do
        table.insert(self.groupinviteData, v)
    end
    for k,v in pairs(data.applys) do
        v.isapply = true
        table.insert(self.groupinviteData, v)
    end
    self.noReadInvite = self.noReadInvite + #data.inviteds
    if MainUIManager.Instance.noticeView ~= nil then
        MainUIManager.Instance.noticeView:set_friendnotice_num(FriendManager.Instance.noReadReq + #FriendGroupManager.Instance.groupinviteData)
    end
    FriendManager.Instance.model:CheckRedPoint()
    self.OnInviteDataUpdate:Fire()
    self.OnGroupListUpdate:Fire()
end

-- 回应邀请
function FriendGroupManager:Require19010(id, platform, zone_id, role_rid, role_platform, role_zone_id, flag)
    if flag == 1 and self:GetOtherGroupNum() >= 3 then
        NoticeManager.Instance:FloatTipsByString(TI18N("最多只能加入3个其他玩家的群组"))
        return false
    end
    local key = nil
    for k,v in pairs(self.groupinviteData) do
        if v.role_rid == role_rid and v.role_platform == role_platform and v.role_zone_id == role_zone_id and id == v.group_rid and platform == v.group_platform and zone_id == v.group_zone_id then
            key = k
            break
        end
    end
    table.remove(self.groupinviteData, k)
    FriendManager.Instance.model:CheckRedPoint()
    Connection.Instance:send(19010, {id = id, platform = platform, zone_id = zone_id, role_rid = role_rid, role_platform = role_platform, role_zone_id = role_zone_id, flag = flag})
    return true
end

function FriendGroupManager:On19010(data)
    -- BaseUtils.dump(data, "On19010")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 提醒设置
function FriendGroupManager:Require19011(id, platform, zone_id, flag)
    Connection.Instance:send(19011, {id = id, platform = platform, zone_id = zone_id, flag = flag})
end

function FriendGroupManager:On19011(data)
    -- BaseUtils.dump(data, "On19011")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 好友邀请进组提示
-- function FriendGroupManager:Require19012(id, platform, zone_id, flag)
--     Connection.Instance:send(19012, {id = id, platform = platform, zone_id = zone_id, flag = flag})
-- end

function FriendGroupManager:On19012(recdata)
    BaseUtils.dump(recdata, "On19012")
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = string.format(TI18N("%s邀请你进入群组<color='#ffff00'>%s</color>"), recdata.name, recdata.group_name)
    data.sureLabel = TI18N("接受")
    data.cancelLabel = TI18N("取消")
    data.sureCallback = function()
            self:Require19013(recdata.group_rid, recdata.group_platform, recdata.group_zone_id, 1)
        end
    data.cancelCallback = function()
            self:Require19013(recdata.group_rid, recdata.group_platform, recdata.group_zone_id, 0)
        end
    NoticeManager.Instance:ConfirmTips(data)
end

-- 申请进组
function FriendGroupManager:Require19013(id, platform, zone_id, flag)
    BaseUtils.dump({id = id, platform = platform, zone_id = zone_id, flag = flag})
    Connection.Instance:send(19013, {id = id, platform = platform, zone_id = zone_id, flag = flag})
end

function FriendGroupManager:On19013(data)
    -- BaseUtils.dump(data, "On19013")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 群主审批申请
function FriendGroupManager:Require19014(id, platform, zone_id, role_rid, role_platform, role_zone_id, flag)
    local key = BaseUtils.Key(id, platform, zone_id)
    if flag == 1 and self.groupData[key] ~= nil then
        if #self.groupData[key].members >= 10 then
            return false
        else
            local key = nil
            for k,v in pairs(self.groupinviteData) do
                if v.role_rid == role_rid and v.role_platform == role_platform and v.role_zone_id == role_zone_id and id == v.id and platform == v.platform and zone_id == v.zone_id then
                    key = k
                    break
                end
            end
            table.remove(self.groupinviteData, k)
            FriendManager.Instance.model:CheckRedPoint()
            Connection.Instance:send(19014, {id = id, platform = platform, zone_id = zone_id, role_rid = role_rid, role_platform = role_platform, role_zone_id = role_zone_id, flag = flag})
            return true
        end
    else
        local key = nil
        for k,v in pairs(self.groupinviteData) do
            if v.role_rid == role_rid and v.role_platform == role_platform and v.role_zone_id == role_zone_id and id == v.id and platform == v.platform and zone_id == v.zone_id then
                key = k
                break
            end
        end
        table.remove(self.groupinviteData, k)
        FriendManager.Instance.model:CheckRedPoint()
        Connection.Instance:send(19014, {id = id, platform = platform, zone_id = zone_id, role_rid = role_rid, role_platform = role_platform, role_zone_id = role_zone_id, flag = flag})
        return true
    end
end

function FriendGroupManager:On19014(data)
    -- BaseUtils.dump(data, "On19014")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

---------------------------------------------------------------------------------------------------------------------
function FriendGroupManager:GetSortList()
    local temp = {}
    if self.data19001 ~= nil then
        for k,v in pairs(self.data19001.groups) do
            table.insert(temp, v)
        end
    end
    self:InsertDefaultData(temp)
    table.sort(temp, function(a, b)
        local ahas, anum = self:IsHasNewMsg(a.group_rid, a.group_platform, a.group_zone_id)
        local bhas, bnum = self:IsHasNewMsg(b.group_rid, b.group_platform, b.group_zone_id)
        if a.time ~= -1 and a.time ~= math.huge and b.time ~= -1 and b.time ~= math.huge then
            if ahas ~= bhas then
                return ahas
            elseif ahas == true then
                return anum > bnum
            else
                return a.time > b.time
            end
        elseif a.time ~= b.time then
            return a.time > b.time
        else
            return a.group_rid < b.group_rid
        end
    end)
    return temp
end

function FriendGroupManager:GetGroupNum()
    if self.data19001 ~= nil then
        return #self.data19001.groups
    else
        return 0
    end
end

function FriendGroupManager:GetGroupData(group_id, group_platform, group_zone_id)
    local key = BaseUtils.Key(group_id, group_platform, group_zone_id)
    return self.groupData[key]
end

function FriendGroupManager:GetReqList()
    return self.groupinviteData
end

function FriendGroupManager:GetOtherGroupNum()
    local num = 0
    local roleData = RoleManager.Instance.RoleData
    if self.data19001 ~= nil then
        for k,v in pairs(self.data19001.groups) do
            if v.role_rid == roleData.id and v.role_platform == roleData.platform and v.role_zone_id == roleData.zone_id then
            else
                num = num + 1
            end
        end
    end
    return num
end

function FriendGroupManager:GetSelfGroupNum()
    local num = 0
    local roleData = RoleManager.Instance.RoleData
    if self.data19001 ~= nil then
        for k,v in pairs(self.data19001.groups) do
            if v.role_rid == roleData.id and v.role_platform == roleData.platform and v.role_zone_id == roleData.zone_id then
                num = num + 1
            else
            end
        end
    end
    return num
end

function FriendGroupManager:GetInviteNum()
    return #self.groupinviteData
end

function FriendGroupManager:IsHasNewMsg(group_id, group_platform, group_zone_id)
    local targetuid = BaseUtils.Key("_G", group_id, group_platform, group_zone_id)
    if self.currHasMsg[targetuid] ~= nil then
        return self.currHasMsg[targetuid] > 0, self.currHasMsg[targetuid]
    else
        return false, 0
    end
end

function FriendGroupManager:CheckCreate()
    local lev = RoleManager.Instance.RoleData.lev
    local freenum = 0
    for i,v in ipairs(DataFriendGroup.data_get) do
        if lev >= v.lev and v.num > freenum then
            freenum = v.num
        end
    end
    if freenum - self.data19001.create > 0 then
        return freenum - self.data19001.create
    else
        local nextdata = nil
        for i,v in ipairs(DataFriendGroup.data_get) do
            if lev > v.lev and nextdata == nil then
                nextdata = v
            end
        end
        if self.data19001.unlock + self.data19001.extra - self.data19001.create > 0 then
            return self.data19001.unlock + self.data19001.extra - self.data19001.create
        else
            return 0, nextdata
        end
    end
end

function FriendGroupManager:ReceiveMsg(data)
    local selfuid = BaseUtils.Key("_G",RoleManager.Instance.RoleData.id, RoleManager.Instance.RoleData.platform, RoleManager.Instance.RoleData.zone_id)
    local targetuid = BaseUtils.Key("_G", data.group_id, data.group_platform, data.group_zone_id)
    local senderuid = BaseUtils.Key("_G",data.rid, data.platform, data.zone_id)
    local key = BaseUtils.Key(data.group_id, data.group_platform, data.group_zone_id)
    if selfuid == senderuid then
        data.isself = true
    else
        SoundManager.Instance:Play(257)
        -- targetuid = BaseUtils.Key(data.id, data.platform, data.zone_id)
    end
    -- if self.currchat_List[targetuid] == nil then
        -- self.currchat_List[targetuid] = self.friend_List[targetuid]
    -- end
    -- self.currchat_List[targetuid].recvTime = BaseUtils.BASE_TIME
    data.recvTime = BaseUtils.BASE_TIME
    if self.groupData[key] ~= nil then
        self.groupData[key].recvTime = data.recvTime
        if FriendManager.Instance.currchat_List[key] == nil then
            FriendManager.Instance.currchat_List[key] = self.groupData[key]
        end
    else
        if self.tempMsgList[key] == nil then
            self.tempMsgList[key] = {}
        end
        table.insert( self.tempMsgList[key], data)
    end


    if self.chatData[targetuid] == nil then
        self.chatData[targetuid] = {}
        table.insert( self.chatData[targetuid], data )
    else
        if #self.chatData[targetuid] >30 then
            local length = #self.chatData[targetuid]
            local temp = {}
            for i = length - 24, length do
                table.insert( temp, self.chatData[targetuid][i] )
            end
            table.insert( temp, data )
            self.chatData[targetuid] = temp
        else
            table.insert( self.chatData[targetuid], data )
        end
    end
    if not data.isself then
        self.currHasMsg[targetuid] = self.currHasMsg[targetuid] == nil and 1 or self.currHasMsg[targetuid]+1
    end
    if (FriendManager.Instance.model.friendWin ~= nil and FriendManager.Instance.model.friendWin.isshow and FriendManager.Instance.model.friendWin.groupchatPanel.currChatTarget == key) then
        print("判断要更新")
        FriendManager.Instance.model:UpdateChatMsg(true)
    end
    self.noReadMsg = self:GetNoReadMsgNum()
    FriendManager.Instance.model:CheckRedPoint()
    if (FriendManager.Instance.model.friendWin == nil or FriendManager.Instance.model.friendWin.isshow == false) then
        self:CheckMainUIIconRedPoint()
    end
    if self.noticeList[key] and data.isself ~= true and(FriendManager.Instance.model.friendWin == nil or FriendManager.Instance.model.friendWin.isshow == false) then
        print(string.format("Friend:%s,Group:%s", tostring(FriendManager.Instance.noReadMsg), tostring(self.noReadMsg)))
        MainUIManager.Instance.noticeView:set_chatnotice_num(self.noReadMsg + FriendManager.Instance.noReadMsg)
    end
    self:SaveChatLog()
end

--获取聊天记录
function FriendGroupManager:GetChatLog(uid)
    local key = BaseUtils.Key("_G", uid)
    self.currHasMsg[key] = nil
    self.noReadMsg = self:GetNoReadMsgNum()
    if self.chatData[key] == nil then
        return {}
    else
        return self.chatData[key]
    end
end

--删除聊天记录
function FriendGroupManager:ClearChatLog(uid)

    self.chatData[uid] = nil
end


function FriendGroupManager:SaveChatLog()
    -- BaseUtils.dump(self.chatData, "啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊")
    self.selfuid = BaseUtils.Key("_G",RoleManager.Instance.RoleData.id, RoleManager.Instance.RoleData.platform, RoleManager.Instance.RoleData.zone_id)
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


function FriendGroupManager:LoadChatLog()
    self.selfuid = BaseUtils.Key("_G", RoleManager.Instance.RoleData.id, RoleManager.Instance.RoleData.platform, RoleManager.Instance.RoleData.zone_id)
    self.chatData = LocalSaveManager.Instance:getFile(self.selfuid)
    if self.chatData == nil then
        self.chatData = {}
    end
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

--判断主UI红点
function FriendGroupManager:CheckMainUIIconRedPoint()
    -- local reqnum = #self:GetReqList()
    -- local noreadnum = self:GetNoReadMsgNum()
    FriendManager.Instance:CheckMainUIIconRedPoint()
    -- if MainUIManager.Instance.MainUIIconView ~= nil then
    --     MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(25, reqnum>0 or guildnoreadnum >0 or noreadnum>0 or announceNum > 0 or next(self.currHasMsg) ~= nil)
    -- end
end

function FriendGroupManager:SendMsg(group_rid, group_platform, group_zone_id, msg)
    msg = string.gsub(msg, "<.->", "")
    -- local targetuid = BaseUtils.Key(id, platform, zone_id)
    local send_msg = MessageParser.ConvertToTag_Face(msg)
    ChatManager.Instance:Send10424(9, group_rid, group_platform, group_zone_id, send_msg)
end

function FriendGroupManager:GetNoReadMsgNum()
    local num = 0
    for k,v in pairs(self.currHasMsg) do
        num = num + v
    end
    return num
end