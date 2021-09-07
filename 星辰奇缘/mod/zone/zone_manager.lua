ZoneManager = ZoneManager or BaseClass(BaseManager)


function ZoneManager:__init()
    if ZoneManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
        return
    end
    ZoneManager.Instance = self
    -- 百度定位APi的AK
    self.Api_ak = "0ZbXwz0kncu23oMZLWKB04HZDRLEfq3Q"
    self.roleinfo = RoleManager.Instance.RoleData
    self.model = ZoneModel.New()
    self.listener = function () self:OnConnect()  end
    -- self.friend_List = {}
    self.openself = true
    self.openselfargs = nil
    self.myvisit_list = {}
    self.mytrends_list = {}
    self.mygift_list = {}

    self.othervisit_list = {}
    self.othertrends_list = {}
    self.othergift_list = {}
    self.NoReadTrend = 0

    self.friendzone_List = {}
    self.hotzone_List = {}

    self.reward_list = {}

    self.photoRequireQueue = {}
    self.webcam = nil

    self.firstInitMark = true
    self.theme = 0
    self.badges = {}
    self.momentsList = {}
    self.newmomentList = {}
    self.citymomentList = {} -- 同城朋友圈列表
    self.personmomentsData = {}
    self.othermomentsData = {}
    self.TopicmomentsData = {}
    self.TopicSystemParseList = {}
    self.Frame = 0
    self.BigBadge = 0
    self.newmomentFlag = false
    self.OnMomentsUpdate = EventLib.New()  -- 单条动态更新
    self.OnAnniMomentsUpdate = EventLib.New()  -- 寄语动态更新
    self.OnMomentsChange = EventLib.New()   -- 动态内容改变
    self.OnCommentsChange = EventLib.New()  -- 评论改变
    self.OnNewMomentUpdate = EventLib.New()  -- 有新的未读消息
    self.OnLikeChange = EventLib.New() -- 点赞改变
    self.OnNewmentions = EventLib.New() -- 新@
    self.OnSendMsg = EventLib.New()

    self.updataMyZone = EventLib.New()
    self:InitHandler()
    self.momentfirst = true
    self.citymomentfirst = true

    self.luckyDogData = nil   --幸运儿数据

    self.myDataAchieveShop ={
    [201] = {id = 201, sort_id = 17, name = "霜狼:1星", type_name = "徽章", desc = "累计获得<color='#ffff00'>100</color>成就点", source_id = 20001, goods_type = 3, assets_type = "achieve_score", price = 0, condition = "<color='#ffff00'>累计获得100成就点！</color>", selling = 1},
    [202] = {id = 202, sort_id = 18, name = "霜狼:2星", type_name = "徽章", desc = "累计获得<color='#ffff00'>300</color>成就点", source_id = 20001, goods_type = 3, assets_type = "achieve_score", price = 0, condition = "<color='#ffff00'>累计获得300成就点！</color>", selling = 1},
    [203] = {id = 203, sort_id = 19, name = "雄狮:1星", type_name = "徽章", desc = "累计获得<color='#ffff00'>600</color>成就点", source_id = 20002, goods_type = 3, assets_type = "achieve_score", price = 0, condition = "<color='#ffff00'>累计获得600成就点！</color>", selling = 1},
    [204] = {id = 204, sort_id = 20, name = "雄狮:2星", type_name = "徽章", desc = "累计获得<color='#ffff00'>800</color>成就点", source_id = 20002, goods_type = 3, assets_type = "achieve_score", price = 0, condition = "<color='#ffff00'>累计获得800成就点！</color>", selling = 1},
    [205] = {id = 205, sort_id = 21, name = "天马:1星", type_name = "徽章", desc = "累计获得<color='#ffff00'>1100</color>成就点", source_id = 20003, goods_type = 3, assets_type = "achieve_score", price = 0, condition = "<color='#ffff00'>累计获得1100成就点！</color>", selling = 1},
    [206] = {id = 206, sort_id = 22, name = "天马:2星", type_name = "徽章", desc = "累计获得<color='#ffff00'>1500</color>成就点", source_id = 20003, goods_type = 3, assets_type = "achieve_score", price = 0, condition = "<color='#ffff00'>累计获得1500成就点！</color>", selling = 1},
    [207] = {id = 207, sort_id = 23, name = "红龙:1星", type_name = "徽章", desc = "累计获得<color='#ffff00'>2000</color>成就点", source_id = 20004, goods_type = 3, assets_type = "achieve_score", price = 0, condition = "<color='#ffff00'>累计获得2000成就点！</color>", selling = 1},
    [208] = {id = 208, sort_id = 24, name = "红龙:2星", type_name = "徽章", desc = "累计获得<color='#ffff00'>2600</color>成就点", source_id = 20004, goods_type = 3, assets_type = "achieve_score", price = 0, condition = "<color='#ffff00'>累计获得2600成就点！</color>", selling = 1},
    }
end

function ZoneManager:InitHandler()

    self:AddNetHandler(11820, self.On11820)
    self:AddNetHandler(11821, self.On11821)
    self:AddNetHandler(11822, self.On11822)
    self:AddNetHandler(11823, self.On11823)
    self:AddNetHandler(11824, self.On11824)
    self:AddNetHandler(11825, self.On11825)
    self:AddNetHandler(11826, self.On11826)
    self:AddNetHandler(11827, self.On11827)
    self:AddNetHandler(11828, self.On11828)
    self:AddNetHandler(11829, self.On11829)
    self:AddNetHandler(11830, self.On11830)
    self:AddNetHandler(11831, self.On11831)
    self:AddNetHandler(11832, self.On11832)
    self:AddNetHandler(11833, self.On11833)
    self:AddNetHandler(11834, self.On11834)
    self:AddNetHandler(11835, self.On11835)
    self:AddNetHandler(11836, self.On11836)
    self:AddNetHandler(11837, self.On11837)
    self:AddNetHandler(11838, self.On11838)
    self:AddNetHandler(11839, self.On11839)
    self:AddNetHandler(11840, self.On11840)
    self:AddNetHandler(11845, self.On11845)
    self:AddNetHandler(11846, self.On11846)
    self:AddNetHandler(11847, self.On11847)
    self:AddNetHandler(11848, self.On11848)
    self:AddNetHandler(11849, self.On11849)
    self:AddNetHandler(11850, self.On11850)
    self:AddNetHandler(11851, self.On11851)
    self:AddNetHandler(11852, self.On11852)
    self:AddNetHandler(11853, self.On11853)
    self:AddNetHandler(11854, self.On11854)
    -------------------------------------------------
    self:AddNetHandler(11856, self.On11856)
    self:AddNetHandler(11857, self.On11857)
    self:AddNetHandler(11858, self.On11858)
    self:AddNetHandler(11859, self.On11859)
    self:AddNetHandler(11860, self.On11860)
    self:AddNetHandler(11861, self.On11861)
    self:AddNetHandler(11862, self.On11862)
    self:AddNetHandler(11863, self.On11863)
    self:AddNetHandler(11864, self.On11864)
    self:AddNetHandler(11865, self.On11865)
    self:AddNetHandler(11866, self.On11866)
    self:AddNetHandler(11867, self.On11867)
    self:AddNetHandler(11868, self.On11868)
    self:AddNetHandler(11869, self.On11869)
    self:AddNetHandler(11870, self.On11870)
    self:AddNetHandler(11871, self.On11871)
    self:AddNetHandler(11872, self.On11872)
    self:AddNetHandler(11873, self.On11873)
    self:AddNetHandler(11874, self.On11874)
    self:AddNetHandler(11875, self.On11875)
    self:AddNetHandler(11876, self.On11876)
    self:AddNetHandler(11877, self.On11877)

    self:AddNetHandler(11892, self.On11892)
    self:AddNetHandler(11893, self.On11893)

    self:AddNetHandler(11897, self.On11897)
    self:AddNetHandler(11898, self.On11898)
    self:AddNetHandler(11899, self.On11899)
end


function ZoneManager:OnConnect()
    self.momentfirst = true
    self.citymomentfirst = true
    self:ReqMyTrendsData()
    self:Require11847()
    self:Require11820(true)
    -- self:Require11856(0)
    self:Require11857(RoleManager.Instance.RoleData.id, RoleManager.Instance.RoleData.platform, RoleManager.Instance.RoleData.zone_id, 0)
    --self:Require11875(0)
    self:Require11873(0)
    self:Require11876()
    self:Require11877()
    self:Require11897()
end

-------好友协议-----------
--查看自身空间数据
function ZoneManager:Require11820(noopen)
    -- print("发送协议11820====================================================")
    if noopen then
        self.firstInitMark = true
    end
    self.targetInfo = {id =  RoleManager.Instance.RoleData.id, platform = RoleManager.Instance.RoleData.platform, zone_id = RoleManager.Instance.RoleData.zone_id}
    Connection.Instance:send(11820, {})
end

function ZoneManager:On11820(data)
    -- BaseUtils.dump(data, "On11820=================================================================")
    self.openself = true
    self.myzoneData = data
    if self.firstInitMark then
        self.firstInitMark = false
        return
    end
    self.theme = data.theme
    self.badges = data.badges
    self.Frame = data.photo_frame
    self.BigBadge = data.show_honor
    self.model:OpenMyWindow(self.openselfargs)
    self.updataMyZone:Fire()

    -- self.openselfargs = nil

end

function ZoneManager:Require11822(id, platform, zone_id)
    self.othervisit_list = {}
    self.othertrends_list = {}
    Connection.Instance:send(11822, {id = id, platform = platform, zone_id = zone_id})
    self.targetInfo = {id = id, platform = platform, zone_id = zone_id}
    -- self:Require11829(id, platform, zone_id)
end

function ZoneManager:On11822(data)
    -- BaseUtils.dump(data, "On11822")
    self.openself = false
    self.myzoneData = data
    self.model:OpenMyWindow(self.openselfargs)
end

function ZoneManager:Require11823(type, content, id, platform, zone_id)
    print("11823")
    -- print(string.format("%s_%s_%s_%s_%s", tostring(type), tostring(content), tostring(id), tostring(platform), tostring(zone_id)))
    local send_msg = MessageParser.ConvertToTag_Face(content)
    Connection.Instance:send(11823, {type = type, content = send_msg, id = id, platform = platform, zone_id = zone_id})
    if self.openself == false then
        self:Require11829(id, platform, zone_id)
    end
end

function ZoneManager:On11823(data)
    -- BaseUtils.dump(data, "On11823==================================================================")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 and self.openself == false then
        LuaTimer.Add(500, function() self:Require11829(self.otherUid.id, self.otherUid.platform, self.otherUid.zone_id) end)
    end
end






--修改动态
function ZoneManager:Require11824(id, content)
    Connection.Instance:send(11824, {id = id, content = content})
end

function ZoneManager:On11824(data)
    -- BaseUtils.dump(data, "On11824")
end


--删除动态
function ZoneManager:Require11825(type)
    self.delete_id = type
    Connection.Instance:send(11825, {type = type})
end

function ZoneManager:On11825(data)
    -- BaseUtils.dump(data, "On11825")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if self.delete_id ~= nil and data.flag == 1 then
        local index = nil
        for i,v in ipairs(self.mytrends_list) do
            if v.id == self.delete_id then
                index = i
            end
        end
        if index ~= nil then
            table.remove(self.mytrends_list, index)
        end
        self.delete_id = nil
    else
        self.delete_id = nil
    end
end


--赞一个
function ZoneManager:Require11826(id, rid, platform, zone_id)
    Connection.Instance:send(11826, {id = id, rid = rid, platform = platform, zone_id = zone_id})
end

function ZoneManager:On11826(data)
    -- BaseUtils.dump(data, "On11826")
end


--关注空间
function ZoneManager:Require11827(id, platform, zone_id)
    Connection.Instance:send(11827, {id = id, platform = platform, zone_id = zone_id})
end

function ZoneManager:On11827(data)
    -- BaseUtils.dump(data, "On11827")
    self.model:UpdateOtherBtn()
    NoticeManager.Instance:FloatTipsByString(data.msg)
end



--取消关注空间
function ZoneManager:Require11828(id, platform, zone_id)
    Connection.Instance:send(11828, {id = id, platform = platform, zone_id = zone_id})
end

function ZoneManager:On11828(data)
    -- BaseUtils.dump(data, "On11828")
    self.model:UpdateOtherBtn()
end


--查看指定空间动态
function ZoneManager:Require11829(id, platform, zone_id)
    if id == self.roleinfo.id and platform == self.roleinfo.platform and zone_id == self.roleinfo.zone_id then
        self.selftrends = true
    else
        self.selftrends = false
    end
    Connection.Instance:send(11829, {id = id, platform = platform, zone_id = zone_id})
end

function ZoneManager:On11829(data)
    -- BaseUtils.dump(data, "On11829查看指定空间动态")
    if self.selftrends == true then
        -- self.selftrends = false
        self.mytrends_list = {}
        self.mygift_list = {}
        local temp = {}
        for i,v in ipairs(data.trends) do
            local key = tostring(v.id)..tostring(v.ctime)
            temp[key] = v
        end
        for k,v in pairs(temp) do
            table.insert(self.mytrends_list, v)
            if v.type == 3 then
                table.insert(self.mygift_list, v)
            end
        end
        table.sort(self.mytrends_list, function(a,b) return a.ctime>b.ctime end)
        table.sort(self.mygift_list, function(a,b) return a.ctime>b.ctime end)
    else
        self.othertrends_list = {}
        self.othergift_list = {}
        local temp = {}
        for i,v in ipairs(data.trends) do
            local key = tostring(v.id)..tostring(v.ctime)
            temp[key] = v
        end
        for i,v in pairs(temp) do
            table.insert(self.othertrends_list, v)
            if v.type == 3 then
                table.insert(self.othergift_list, v)
            end
        end
        table.sort(self.othertrends_list, function(a,b) return a.ctime>b.ctime end)
        table.sort(self.othergift_list, function(a,b) return a.ctime>b.ctime end)
    end
    if self.openself == self.selftrends then
        self.model:UpdateMyTrend()
    end

    -- BaseUtils.dump(self.othertrends_list, "动态刷新推送")
    -- BaseUtils.dump(self.othervisit_list, "猜猜猜词啊慈爱次啊慈爱次啊慈爱次啊次")
end


--动态刷新推送
-- function ZoneManager:Require11830(id, platform, zone_id)
--     Connection.Instance:send(11830, {id = id, platform = platform, zone_id = zone_id})
-- end
--只是更新自己的
function ZoneManager:On11830(data)
    --BaseUtils.dump(data, "On11830")
    -- print(self.openself)
    local isnew = true
    for i,v in ipairs(self.mytrends_list) do
        if v.id == data.id and v.ctime == data.ctime then
            self.mytrends_list[i] = data
        end
    end
    if isnew then
        table.insert( self.mytrends_list, data )
        if data.type == 3 then
            table.insert(self.mygift_list, data)
        end
    end
    table.sort(self.mytrends_list, function(a,b) return a.ctime>b.ctime end)
    table.sort(self.mygift_list, function(a,b) return a.ctime>b.ctime end)
    if self.openself then
        self.model:UpdateMyTrend()
    end
    if self.model.zone_myWin == nil then
        self.NoReadTrend = self.NoReadTrend + 1
        MainUIManager.Instance.noticeView:set_zonenotice_num(self.NoReadTrend)
    end
end

--增加标签
function ZoneManager:Require11831(tag)
    Connection.Instance:send(11831, {tag = tag})
end

function ZoneManager:On11831(data)
    -- BaseUtils.dump(data, "On11831")
end

--删除标签
function ZoneManager:Require11832(id)
    Connection.Instance:send(11832, {id = id})
end

function ZoneManager:On11832(data)
    -- BaseUtils.dump(data, "On11832")
end

--修改个人资料
function ZoneManager:Require11833(birth, constellation, abo, signature, region, sex)
    Connection.Instance:send(11833, {birth = birth, constellation = constellation, abo = abo, signature = signature, region = region, sex = sex})
    self.myzoneData.birth = birth
    self.myzoneData.constellation = constellation
    self.myzoneData.abo = abo
    self.myzoneData.signature = signature
    self.myzoneData.region = region
end

function ZoneManager:On11833(data)
    -- BaseUtils.dump(data, "On11833")
    if data.result == 1 then
        self.model:UpdareInfo()
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--上传自定义头像
function ZoneManager:Require11834(id, photo)
    Connection.Instance:send(11834, {id = id, photo = photo})
end

function ZoneManager:On11834(data)
    BaseUtils.dump(data, "On11834")

    if data.result == 1 then
        local msg = data.msg
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Sure
        data.content = msg
        data.sureLabel = TI18N("确定")
        NoticeManager.Instance:ConfirmTips(data)

        self.model:ShowCachePhoto()
    else
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
end

--修改隐私权限
function ZoneManager:Require11835(privacy)
    self.myzoneData.privacy = privacy
    Connection.Instance:send(11835, {privacy = privacy})
end

function ZoneManager:On11835(data)
    if data.result == 1 then
        self.model:UpdareInfo()
    end
    -- BaseUtils.dump(data, "On11835")
end

--踩空间
function ZoneManager:Require11836(role_id, platform, zone_id)
    Connection.Instance:send(11836, {role_id = role_id, platform = platform, zone_id = zone_id})
end

function ZoneManager:On11836(data)
    if data.result == 1 then
        self.myzoneData.liked = self.myzoneData.liked +1
        self:Require11840(self.targetInfo.id, self.targetInfo.platform, self.targetInfo.zone_id)
    end
    if data.item_base_id ~= 0 then
        self.myzoneData.prize_num = self.myzoneData.prize_num -1
        self.model:UpdareInfo()
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self.model:UpdateOtherBtn()
end

--空间增加礼品
function ZoneManager:Require11837(num)
    Connection.Instance:send(11837, {num = num})
    self.lastAddNum = num
end

function ZoneManager:On11837(data)
    -- BaseUtils.dump(data, "On11837")
    if data.result == 1 then
        self.myzoneData.prize_num = self.lastAddNum + self.myzoneData.prize_num
        self.model:UpdareInfo()
    end
    self.lastAddNum = 0
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--查看好友空间榜
function ZoneManager:Require11838()
    Connection.Instance:send(11838, {})
end

function ZoneManager:On11838(data)
    self.friendzone_List = data.list
    table.sort( self.friendzone_List, function(a,b) return (a.liked>b.liked) or (a.liked==b.liked and a.id>b.id) end )
    -- BaseUtils.dump(data, "On11838")
    self.model:InitFirendList()
end

--查看最热空间榜
function ZoneManager:Require11839()
    Connection.Instance:send(11839, {})
end

function ZoneManager:On11839(data)
    self.hotzone_List = data.list
    table.sort( self.hotzone_List, function(a,b) return (a.liked>b.liked) or (a.liked==b.liked and a.id>b.id) end )
    -- BaseUtils.dump(data, "On11839")
    self.model:InitHotList()

end

function ZoneManager:Require11840(id, platform, zone_id)
    print("请求自己足迹")
    Connection.Instance:send(11840, {id = id, platform = platform, zone_id = zone_id})
end

function ZoneManager:On11840(data)
    -- BaseUtils.dump(data, "On11840")
    if self.openself then
        self.myvisit_list = {}
        self.myvisit_list = data.list
    else
        self.othervisit_list = {}
        self.othervisit_list = data.list
    end
    self.model:UpdateCai()
end

function ZoneManager:Require11845(id, platform, zone_id)
    Connection.Instance:send(11845, {id = id, platform = platform, zone_id = zone_id})
end

function ZoneManager:On11845(data)
    -- self.model:UpdatePhoto(data.photo)
    --BaseUtils.dump(data,"11845照片列表")
    if self.photoRequireQueue ~= nil and next(self.photoRequireQueue) ~= nil then
        local cb = self.photoRequireQueue[1].callback
        for i,v in ipairs(data.photo) do
            self.model:SaveLocalPhoto(v.photo_bin, self.photoRequireQueue[1].id, self.photoRequireQueue[1].platform, self.photoRequireQueue[1].zone_id, v.id, v.uploaded)
        end
        table.remove(self.photoRequireQueue, 1)
        cb(data.photo)
        self:PhotoQueuenext()
    end
end

function ZoneManager:Require11846(id)
    Connection.Instance:send(11846, {id = id})
end

function ZoneManager:On11846(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.result == 1 then
        -- self.myzoneData.photo = 0
        -- self.myzoneData.photo_auditing = 1
        self.model:UpdareInfo()
    end
end

function ZoneManager:Require11847()
    Connection.Instance:send(11847, {})
end

function ZoneManager:On11847(data)
    self.reward_list = {}
    for k,v in pairs(data.rewarded) do
        -- if BaseUtils.isTheSameDay(v.time, BaseUtils.BASE_TIME) then
            self.reward_list[v.id] = v.time
        -- end
    end
    self.model:UpdateCai()
end

function ZoneManager:Require11848(id)
    Connection.Instance:send(11848, {id =id})
end

function ZoneManager:On11848(data)

end

function ZoneManager:Require11849(id, msg, role_id, platform, zone_id)
    local send_msg = MessageParser.ConvertToTag_Face(msg)
    Connection.Instance:send(11849, {id =id, content = send_msg, role_id = role_id, platform = platform , zone_id = zone_id})
end

function ZoneManager:On11849(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    -- BaseUtils.dump(data, "11849")
    if data.flag == 1 and self.openself == false then
        LuaTimer.Add(500, function() self:Require11829(self.otherUid.id, self.otherUid.platform, self.otherUid.zone_id) end)
    end
end


function ZoneManager:Require11850(id)
    if id == nil then
        return
    end
    self.temptheme = id
    Connection.Instance:send(11850, {id =id})
end

function ZoneManager:On11850(data)
    -- BaseUtils.dump(data, "11850")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        EventMgr.Instance:Fire(event_name.zone_theme_update, self.temptheme)
        self.theme = self.temptheme
        self.temptheme = nil
    end
end

function ZoneManager:Require11851(id)
    -- print("11851发送:".. tostring(id))
    if id == nil then
        return
    end
    self.tempframe = id
    Connection.Instance:send(11851, {id =id})
end

function ZoneManager:On11851(data)
    -- BaseUtils.dump(data, "11851")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        EventMgr.Instance:Fire(event_name.zone_frame_update, self.tempframe)
        self.Frame = self.tempframe
        self.tempframe = nil
    end
end

function ZoneManager:Require11852(list)
    -- print("11852发送:".. tostring(list))
    -- BaseUtils.dump(list,"发送协议11851======================")
    local temp = {}
    for i,v in ipairs(list) do
        temp[i] = {badge_id = v}
    end
    self.tempbadge = temp
    Connection.Instance:send(11852, {badges = self.tempbadge})
end

function ZoneManager:On11852(data)
    -- BaseUtils.dump(data, "11852????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        EventMgr.Instance:Fire(event_name.zone_badge_update, self.tempbadge)
        self.badges = self.tempbadge
        self.tempbadge = nil
    end

end
function ZoneManager:Require11853(id, platform, zone_id)
    -- print("11853发送:".. tostring(list))
    Connection.Instance:send(11853, {id = id, platform = platform, zone_id = zone_id})
end

function ZoneManager:On11853(data)
    -- BaseUtils.dump(data, "11853")
    if self.photoRequireQueue ~= nil and next(self.photoRequireQueue) ~= nil then
        local cb = self.photoRequireQueue[1].callback
        for i,v in ipairs(data.photo) do
            self.model:SaveLocalPhoto(v.photo_bin, self.photoRequireQueue[1].id, self.photoRequireQueue[1].platform, self.photoRequireQueue[1].zone_id, v.id, v.uploaded)
        end
        table.remove(self.photoRequireQueue, 1)
        cb(data.photo)
        self:PhotoQueuenext()
    end
end
function ZoneManager:Require11854(id)
    -- print("11854发送:".. tostring(id))

    Connection.Instance:send(11854, {id = id})
end

function ZoneManager:On11854(data)
    --BaseUtils.dump(data, "11854")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        self.model:ShowCachePhoto()
    end
end
---------------========================================================================

function ZoneManager:OpenSelfZone(args)
    -- print("开自己空间")
    if self.newmomentFlag then
        self:Require11856(0)
        self.newmomentFlag = false
    end
    self.openselfargs = args
    BaseUtils.dump(self.openselfargs,"self.openselfargs")
    self:Require11820()
    self.NoReadTrend = 0
    MainUIManager.Instance.noticeView:set_zonenotice_num(0)
end

function ZoneManager:OpenOtherZone(id, platform, zone_id, args)
    self.openselfargs = args
    -- if not BaseUtils.IsTheSamePlatform(platform, zone_id) then
    --     NoticeManager.Instance:FloatTipsByString("非同服务器玩家跨服状态无法查看空间")
    --     return
    -- end
    if id == RoleManager.Instance.RoleData.id and platform == RoleManager.Instance.RoleData.platform and zone_id == RoleManager.Instance.RoleData.zone_id then
        self:OpenSelfZone()
        return
    end
    self.otherUid = {id = id, platform = platform, zone_id = zone_id}
    self:Require11857(id, platform, zone_id, 0)
    self:Require11822(id, platform, zone_id)
end

function ZoneManager:ReqMyTrendsData()
    self:Require11829(RoleManager.Instance.RoleData.id, RoleManager.Instance.RoleData.platform, RoleManager.Instance.RoleData.zone_id)
end

function ZoneManager:InitWebcam()
    if Webcam ~= nil and self.webcam == nil then
        self.webcam = Webcam.Init(ctx.MainCamera.gameObject.transform, function(photoSavePath, photoSaveName) self:webcamCallBack(photoSavePath, photoSaveName) end)
    end
end

function ZoneManager:webcamCallBack(photoSavePath, photoSaveName)
    self.model:WebcamCallBack(photoSavePath, photoSaveName)
end

function ZoneManager:RequirePhotoQueue(id, platform, zone_id, callback, type, exid)
    local beginReq = #self.photoRequireQueue < 1
    table.insert(self.photoRequireQueue, {id = id, platform = platform, zone_id = zone_id, callback = callback, type = type, exid = exid})
    -- BaseUtils.dump({id = id, platform = platform, zone_id = zone_id, callback = callback, type = type, exid = exid}, "插入队列")
    if beginReq then
        if type == 1 then
            self:Require11845(id, platform, zone_id)
        elseif type == 2 then --类型2 缩略图
            self:Require11872(id, platform, zone_id, exid)
        elseif type == 3 then --类型3 大图
            self:Require11868(id, platform, zone_id, exid)
        else
            self:Require11853(id, platform, zone_id)
        end
    end
end

function ZoneManager:PhotoQueuenext()
    local donext = #self.photoRequireQueue ~= 0
    if not donext then
        return
    end
    local type = self.photoRequireQueue[1].type
    local id = self.photoRequireQueue[1].id
    local platform = self.photoRequireQueue[1].platform
    local zone_id = self.photoRequireQueue[1].zone_id
    local exid = self.photoRequireQueue[1].exid
    if donext then
        if type == 1 then
            self:Require11845(id, platform, zone_id)
        elseif type == 2 then --类型2 缩略图
            self:Require11872(id, platform, zone_id, exid)
        elseif type == 3 then --类型3 大图
            self:Require11868(id, platform, zone_id, exid)
        else
            self:Require11853(id, platform, zone_id)
        end
    end
end

function ZoneManager:GetResId(id)
    --  if id ~= nil then
    --         if id >=201 and id<= 209 then
    --                 local str = string.sub(tostring(id),-2,-1)
    --                 return tonumber("200" .. str)
    --         end
    -- end
    -- print("基础id："..tostring(id))
    for k,v in pairs(DataAchieveShop.data_list) do
        if id == v.id then
            return v.source_id
        end
    end
end

function ZoneManager:ResIdToId(resid)
    if resid == 0  then return 0 end
    -- print(debug.traceback())

    -- print("资源id："..tostring(resid))
    for k,v in pairs(DataAchieveShop.data_list) do
        if resid == v.source_id then
            return v.id
        end
    end
end

--资源列表格式{id1,id2,id3}
--id列表格式{{badge_id = id1},{badge_id = id2},{badge_id = id3}}
function ZoneManager:ConvertToBadgeId(list)
    local temp = {}
    for i,v in ipairs(list) do
        local id = self:ResIdToId(v)
        temp[i] = {badge_id = id}
    end
    table.sort(temp, function(a,b) return a.badge_id<b.badge_id end)
    return temp
end

function ZoneManager:ConvertToBadgeResId(list)
    local temp = {}
    for i,v in ipairs(list) do
        local id = self:GetResId(v.badge_id)
        temp[i] = id
    end
    table.sort(temp, function(a,b) return a<b end)
    return temp
end

function ZoneManager:IsHas(resid)
    if resid == 0 then return true end
    local haslist = AchievementManager.Instance.model.shop_buylist
    -- BaseUtils.dump(haslist,"商店列表==============================================================")
    local id = self:ResIdToId(resid)
    if id == nil or haslist[id] == nil or haslist[id][1] ~= 1 then
        return false
    else
        return true
    end

end

function ZoneManager:IsHasNew(baseId)
    if baseId == 0 then return true end
    local haslist = AchievementManager.Instance.model.shop_buylist
    local data = DataAchieveShop.data_list[baseId]

    if data == nil or haslist[baseId] == nil or haslist[baseId][1] ~= 1 then
        return false
    else
        return true
    end
end

function ZoneManager:GetTimestamp(resid)
    if resid == 0 then return 0 end
    local haslist = AchievementManager.Instance.model.shop_buylist
    local id = self:ResIdToId(resid)
    if id == nil or haslist[id] == nil or haslist[id][1] ~= 1 then
        return 0
    else
        return haslist[id][2]
    end

end

----------------------朋友圈------------------------------
function ZoneManager:Require11856(page)
    Connection.Instance:send(11856, {page = page})
end

function ZoneManager:On11856(data)
    --BaseUtils.dump(data, "on11856")
    if data.page == 0 then
        self.momentsList = data.moments
        if (#data.moments == 0 or (self.momentsList ~= nil and self.momentsList[1].ctime == data.moments[1].ctime)) and not self.momentfirst then
            -- NoticeManager.Instance:FloatTipsByString("暂时没有新内容，请稍后刷新吧{face_1,9}")
        end
    else
        for i,v in ipairs(data.moments) do
            table.insert(self.momentsList, v)
        end
        if #data.moments == 0 then
            NoticeManager.Instance:FloatTipsByString(TI18N("没有更多内容了，去好友空间拜访下吧{face_1,22}"))
        end
    end
    self.momentfirst = false
    self.OnMomentsUpdate:Fire()
    NoticeManager.Instance:FloatTipsByString(data.msg)
end
-- 查看指定角色动态
function ZoneManager:Require11857(role_id, platform, zone_id, page)
    Connection.Instance:send(11857, {role_id = role_id, platform = platform, zone_id = zone_id, page = page})
end

function ZoneManager:On11857(data)
    --BaseUtils.dump(data, "11857", true)
    if data.page == 0 then
        if RoleManager.Instance.RoleData.id == data.circle_id and RoleManager.Instance.RoleData.platform == data.circle_platform and RoleManager.Instance.RoleData.zone_id == data.circle_zone_id then
            self.personmomentsData = data
        else
            self.othermomentsData = data
        end
    else
        if #data.moments == 0 then
            -- NoticeManager.Instance:FloatTipsByString("没有更多内容了，去好友空间拜访下吧{face_1,22}")
        end
        if RoleManager.Instance.RoleData.id == data.circle_id and RoleManager.Instance.RoleData.platform == data.circle_platform and RoleManager.Instance.RoleData.zone_id == data.circle_zone_id then
            for i,v in ipairs(data.moments) do
                local has = false
                if self.personmomentsData.moments == nil then self.personmomentsData.moments = {} end
                for ii,vv in ipairs(self.personmomentsData.moments) do
                    if v.m_id == vv.m_id and v.m_platform == vv.m_platform and v.zone_id == v.m_zone_id then
                        has = true
                        break
                    end
                end
                if not has then
                    table.insert(self.personmomentsData.moments, v)
                end
            end
        else
            for i,v in ipairs(data.moments) do
                local has = false
                if self.othermomentsData.moments == nil then self.othermomentsData.moments = {} end
                for ii,vv in ipairs(self.othermomentsData.moments) do
                    if v.m_id == vv.m_id and v.m_platform == vv.m_platform and v.zone_id == v.m_zone_id then
                        has = true
                        self.othermomentsData.moments[ii] = vv
                        break
                    end
                end
                if not has then
                    table.insert(self.othermomentsData.moments, v)
                end
            end
        end
    end
    self.OnMomentsUpdate:Fire()
    NoticeManager.Instance:FloatTipsByString(data.msg)
end
-- 发朋友圈
function ZoneManager:Require11858(content, type, photos, mentions, thumbs)
    local temp = {}
    for i,v in ipairs(photos) do
        table.insert(temp, {photo = v})
    end
    local thumbstemp = {}
    for i,v in ipairs(thumbs) do
        table.insert(thumbstemp, {thumb = v})
    end
    -- BaseUtils.dump({content = content, photos = temp, thumbs = thumbstemp, mentions = mentions }, "发朋友圈------------------------")
    print(type.."type")
    Connection.Instance:send(11858, {content = content, type = type, photos = temp, thumbs = thumbstemp, mentions = mentions })
end

function ZoneManager:On11858(data)
    --BaseUtils.dump(data, "11858", true)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end
-- 删除指定动态
function ZoneManager:Require11859(id, platform, zone_id)
    print("send11859")
    Connection.Instance:send(11859, {id = id, platform = platform, zone_id = zone_id})
end

function ZoneManager:On11859(data)
    --BaseUtils.dump(data, "11859", true)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end
-- 点赞
function ZoneManager:Require11860(id, platform, zone_id)
    Connection.Instance:send(11860, {id = id, platform = platform, zone_id = zone_id})
end

function ZoneManager:On11860(data)
    --BaseUtils.dump(data, "11860", true)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end
-- 取消点赞
function ZoneManager:Require11861(id, platform, zone_id)
    Connection.Instance:send(11861, {id = id, platform = platform, zone_id = zone_id})
end

function ZoneManager:On11861(data)
    --BaseUtils.dump(data, "11861", true)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end
--评论
function ZoneManager:Require11862(id, platform, zone_id, content, mentions)
    if id == nil or platform == nil or zone_id == nil or content == nil or mentions == nil then
        Log.Error("评论出错："..debug.traceback())
    end
    Connection.Instance:send(11862, {id = id, platform = platform, zone_id = zone_id, content = content, mentions = mentions})
end

function ZoneManager:On11862(data)
    --BaseUtils.dump(data, "11862", true)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end
-- 删除指定评论
function ZoneManager:Require11863(moment_id, platform, zone_id, comment_id)
    -- BaseUtils.dump({moment_id = moment_id, platform = platform, zone_id = zone_id, comment_id = comment_id}, "删除的")
    Connection.Instance:send(11863, {moment_id = moment_id, platform = platform, zone_id = zone_id, comment_id = comment_id})
end

function ZoneManager:On11863(data)
    --BaseUtils.dump(data, "11863", true)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end
-- 删除指定图片
function ZoneManager:Require11864()
    Connection.Instance:send(11864, { })
end

function ZoneManager:On11864(data)
    --BaseUtils.dump(data, "11864", true)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end
--动态推送
function ZoneManager:Require11865()
    Connection.Instance:send(11865, { })
end

function ZoneManager:On11865(data)
    BaseUtils.dump(data,"On11865")
    self.OnMomentsChange:Fire(data)
    local oldindex = nil
    for i,v in ipairs(self.momentsList) do
        if oldindex == nil and v.m_id == data.m_id then
            oldindex = i
        end
    end
    if data.up_type == 0 then
        if oldindex ~= nil then
            self.momentsList[oldindex] = data
        else
            table.insert(self.momentsList, data)
        end

        if data.role_id == RoleManager.Instance.RoleData.id and data.platform == RoleManager.Instance.RoleData.platform and data.zone_id == RoleManager.Instance.RoleData.zone_id then
        else
            self:AddTempMoment(data)
        end
    else
        if oldindex ~= nil then
            table.remove(self.momentsList, oldindex)
        end
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--评论推送
function ZoneManager:Require11866()
    Connection.Instance:send(11866, { })
end

function ZoneManager:On11866(data)
    --BaseUtils.dump(data, "11866")
    local oldindex = nil
    for i,v in ipairs(self.momentsList) do
        if oldindex == nil and v.m_id == data.m_id and v.m_platform == data.m_platform and v.m_zone_id == data.m_zone_id then
            oldindex = i
            break
        end
    end
    local subindex = nil
    local momentdata = 1
    if oldindex ~= nil then
        if self.momentsList[oldindex].friend_comment ~= nil then
            for i,v in ipairs(self.momentsList[oldindex].friend_comment) do
                if v.id == data.id then
                    subindex = i
                    break
                end
            end
        end
        if subindex ~= nil then
            if not (self.model.zone_myWin ~= nil and self.openself) then
                table.remove(self.momentsList[oldindex].friend_comment, subindex)
            end
        else
            if not (self.model.zone_myWin ~= nil and self.openself) then
                table.insert(self.momentsList[oldindex].friend_comment, data)
            end
            if data.role_id == RoleManager.Instance.RoleData.id and data.platform == RoleManager.Instance.RoleData.platform and data.zone_id == RoleManager.Instance.RoleData.zone_id then
            else
                self:AddTempMoment(self.momentsList[oldindex])
            end
        end
    end

    --BaseUtils.dump(self.newmomentList, "新消息列表")
    self.OnCommentsChange:Fire(data)
    if data.role_id == RoleManager.Instance.RoleData.id and data.platform == RoleManager.Instance.RoleData.platform and data.zone_id == RoleManager.Instance.RoleData.zone_id then
    else
        NoticeManager.Instance:FloatTipsByString(string.format("%s评论了你的朋友圈{face_1,1}",data.name))
    end
end

-- 点赞推送
function ZoneManager:Require11867()
    Connection.Instance:send(11867, { })
end

function ZoneManager:On11867(data)
    --BaseUtils.dump(data, "11867", true)
    local oldindex = nil
    for i,v in ipairs(self.momentsList) do
        if oldindex == nil and v.m_id == data.m_id and v.m_platform == data.m_platform and v.m_zone_id == data.m_zone_id then
            oldindex = i
            break
        end
    end
    local subindex = nil
    if oldindex ~= nil then
        for i,v in ipairs(self.momentsList[oldindex].likes) do
            if v.id == data.id then
                subindex = i
                break
            end
        end
        if subindex ~= nil then
            if not (self.model.zone_myWin ~= nil and self.openself) then
                table.remove(self.momentsList[oldindex].likes, subindex)
            end
            -- table.remove(self.momentsList[oldindex].likes, subindex)
        else
            if not (self.model.zone_myWin ~= nil and self.openself) then
                table.insert(self.momentsList[oldindex].likes, data)
            end
            if data.role_id == RoleManager.Instance.RoleData.id and data.platform == RoleManager.Instance.RoleData.platform and data.zone_id == RoleManager.Instance.RoleData.zone_id then
            else
                self:AddTempMoment(self.momentsList[oldindex])
            end
        end
    end
    self.OnLikeChange:Fire(data)
    if data.role_id == RoleManager.Instance.RoleData.id and data.platform == RoleManager.Instance.RoleData.platform and data.zone_id == RoleManager.Instance.RoleData.zone_id then
    else
        NoticeManager.Instance:FloatTipsByString(string.format("%s给你的朋友圈点赞{face_1,3}",data.name))
    end
    --NoticeManager.Instance:FloatTipsByString(data.msg)

end

--获取指定图片
function ZoneManager:Require11868(moment_id, platform, zone_id, photo_id)
    -- BaseUtils.dump({moment_id = moment_id, platform = platform, zone_id = zone_id, photo_id = photo_id}, "请求了什么？？？？/")
    Connection.Instance:send(11868, {moment_id = moment_id, platform = platform, zone_id = zone_id, photo_id = photo_id})
end

function ZoneManager:On11868(data)
    -- BaseUtils.dump(data, "11868", true)
    if self.photoRequireQueue ~= nil and next(self.photoRequireQueue) ~= nil then
        local cb = self.photoRequireQueue[1].callback
        for i,v in ipairs(data.photo) do
            self.model:SaveMomentPhoto(v.photo_bin, v.m_id, v.m_platform, v.m_zone_id, v.id, v.uploaded)
        end
        table.remove(self.photoRequireQueue, 1)
        cb(data.photo)
        self:PhotoQueuenext()
    end
end

--举报指定内容
function ZoneManager:Require11869(moment_id, platform, zone_id, type, spec_id)
    Connection.Instance:send(11869, {moment_id  = moment_id, platform = platform, zone_id = zone_id, type = type, spec_id = spec_id})
end

function ZoneManager:On11869(data)
    --BaseUtils.dump(data, "11869", true)
    local noticdata = NoticeConfirmData.New()
    noticdata.type = ConfirmData.Style.Sure
    noticdata.content = data.msg
    noticdata.sureLabel = TI18N("确定")
    -- data.cancelLabel = "取消"
    -- data.blueSure = true
    -- data.greenCancel = true
    -- data.sureCallback = function()ZoneManager.Instance:Require11869(self.data.m_id, self.data.m_platform, self.data.m_zone_id, 0, self.data.m_id) end
    NoticeManager.Instance:ConfirmTips(noticdata)
    -- NoticeManager.Instance:FloatTipsByString(data.msg)
end

--屏蔽指定角色所有动态
function ZoneManager:Require11870(rid, platform, zone_id)
    Connection.Instance:send(11870, {rid = rid, platform = platform, zone_id = zone_id})
end

function ZoneManager:On11870(data)
    --BaseUtils.dump(data, "11870", true)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--取消屏蔽指定角色
function ZoneManager:Require11871()
    Connection.Instance:send(11871, { })
end

function ZoneManager:On11871(data)
    --BaseUtils.dump(data, "11871", true)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--请求缩略图
function ZoneManager:Require11872(moment_id, platform, zone_id, photo_id)
    -- BaseUtils.dump({moment_id = moment_id, platform = platform, zone_id = zone_id, photo_id = photo_id}, "请求缩略图")
    Connection.Instance:send(11872, {moment_id = moment_id, platform = platform, zone_id = zone_id, photo_id = photo_id})
end

function ZoneManager:On11872(data)
    -- BaseUtils.dump(data, "11872", true)
    if self.photoRequireQueue ~= nil and next(self.photoRequireQueue) ~= nil then
        local cb = self.photoRequireQueue[1].callback
        for i,v in ipairs(data.thumb) do
            self.model:SaveThumb(v.thumb_bin, v.m_id, v.m_platform, v.m_zone_id, v.id, v.uploaded)
        end
        table.remove(self.photoRequireQueue, 1)
        cb(data.thumb)
        self:PhotoQueuenext()
    end
end


--同城动态
function ZoneManager:Require11873(page)
    Connection.Instance:send(11873, {page = page})
end

function ZoneManager:On11873(data)
    -- BaseUtils.dump(data, "<color='#00ff00'>11873&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&</color>", true)
    if data.page == 0 then
        if (#data.moments == 0 or (next(self.citymomentList) ~= nil and self.citymomentList[1].ctime == data.moments[1].ctime)) and not self.citymomentfirst  then
            -- NoticeManager.Instance:FloatTipsByString("暂时没有新内容，请稍后刷新吧{face_1,9}")
        end
        for i,v in ipairs(data.moments) do
            local index, val
            for ii,vv in ipairs(self.citymomentList) do
                if vv.m_id == v.m_id and vv.m_platform == v.m_platform and vv.m_zone_id == v.m_zone_id then
                    index = ii
                    val = vv
                    break
                end
            end
            if index ~= nil then
                self.citymomentList[index] = v
            else
                table.insert(self.citymomentList , v)
            end
        end
    else
        for i,v in ipairs(data.moments) do
            local index, val
            for ii,vv in ipairs(self.citymomentList) do
                if vv.m_id == v.m_id and vv.m_platform == v.m_platform and vv.m_zone_id == v.m_zone_id then
                    index = ii
                    val = vv
                    break
                end
            end
            if index ~= nil then
                self.citymomentList[index] = v
            else
                table.insert(self.citymomentList , v)
            end
        end
        -- for i,v in ipairs(data.moments) do
        --     table.insert(self.citymomentList, v)
        -- end
        if #data.moments == 0 then
            NoticeManager.Instance:FloatTipsByString(TI18N("没有更多内容了，去好友空间拜访下吧{face_1,22}"))
        end
    end
    self.citymomentfirst = false
    self.OnMomentsUpdate:Fire()
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--取消屏蔽指定角色
function ZoneManager:Require11874(region, city, is_shared_region)
    self.myzoneData.region = region
    self.myzoneData.city = city
    self.myzoneData.is_shared_region = is_shared_region
    Connection.Instance:send(11874, {region = region, city = city, is_shared_region = is_shared_region})
end

function ZoneManager:On11874(data)
    --BaseUtils.dump(data, "11874", true)
    -- NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.result == 1 then
        self.model:UpdareInfo()
    end
end

function ZoneManager:AddTempMoment(data)
    local key = string.format("%s_%s_%s", data.m_id, data.m_platform, data.m_zone_id)
    self.newmomentList[key] = data
    local num = 0
    for k,v in pairs(self.newmomentList) do
        num = num + 1
    end
    MainUIManager.Instance.noticeView:set_momentnotice_num(num)
    self.OnNewmentions:Fire()
end

function ZoneManager:ClearTempMoment()
    self.newmomentList = {}
    MainUIManager.Instance.noticeView:set_momentnotice_num(0)
end

function ZoneManager:Require11875(page)
    Connection.Instance:send(11875, {page = page})
end

function ZoneManager:On11875(data)
    --BaseUtils.dump(data, "11875", true)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    for i,v in ipairs(data.moments) do
        local key = string.format("%s_%s_%s", v.m_id, v.m_platform, v.m_zone_id)
        self.newmomentList[key] = v
    end
    self.OnMomentsUpdate:Fire()
    -- MainUIManager.Instance.noticeView:set_momentnotice_num(#data.moments)
end

function ZoneManager:Require11876()
    Connection.Instance:send(11876, {})
end

function ZoneManager:On11876(data, old)
    self.newmentionnum = data.notifications_num
    if MainUIManager.Instance.noticeView ~= nil then
        MainUIManager.Instance.noticeView:set_momentnotice_num(self.newmentionnum)
    elseif not old then
        LuaTimer.Add(3000, function()
            self:On11876(data, true)
        end)
    end
end


function ZoneManager:Require11877()
    Connection.Instance:send(11877, {})
end

function ZoneManager:On11877(data)
    self.newmomentFlag = data.unread_num > 0
    self.OnNewMomentUpdate:Fire()
end

function ZoneManager:Require11892(id)
    if id == nil then
        return
    end
    self.tempBigBadge = id
    Connection.Instance:send(11892, { honor_id = id })
end

function ZoneManager:On11892(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        EventMgr.Instance:Fire(event_name.zone_bigbadge_update, self.tempBigBadge)
        self.BigBadge = self.tempBigBadge
        self.BigBadge = nil
    end
end

--查看寄语列表
function ZoneManager:Require11893(campId,id)
    Connection.Instance:send(11893, {camp_id = campId, req_type = id})
end

function ZoneManager:On11893(data)
    --print("收到11893协议")
    --BaseUtils.dump(data,"On11893")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.req_type == 1 then
        self.TopicmomentsData[data.camp_id] = {}
        self.TopicmomentsData[data.camp_id] = data.moments
        if (#data.moments == 0 or (self.TopicmomentsData[data.camp_id] ~= nil and self.TopicmomentsData[data.camp_id][1].ctime == data.moments[1].ctime)) then
            -- NoticeManager.Instance:FloatTipsByString("暂时没有新内容，请稍后刷新吧{face_1,9}")
        end
    else
        if next(self.TopicmomentsData[data.camp_id]) ~= nil then
            for i,v in ipairs(data.moments) do
                table.insert(self.TopicmomentsData[data.camp_id], v)
            end
        end
        local len = #self.TopicmomentsData[data.camp_id] - 20
        if len > 0 then
            for i = 1,len do
                table.remove(self.TopicmomentsData[data.camp_id], i)
            end
        end

        if #data.moments == 0 then
            NoticeManager.Instance:FloatTipsByString(TI18N("没有更多内容了{face_1,22}"))
        end
    end
    self.luckyDogData = data.lucky_list

    self.OnAnniMomentsUpdate:Fire(data.camp_id)
end

--查看系统点赞数
function ZoneManager:Require11897()
    --print("发送11897")
    Connection.Instance:send(11897, {})
end

function ZoneManager:On11897(data)
    --print("收到11897协议")
    --BaseUtils.dump(data,"On11897")
    if data.camp_wish ~= nil and next(data.camp_wish) ~= nil then
        for i,v in pairs(data.camp_wish) do
            table.insert(self.TopicSystemParseList,v)
        end
    end
end

function ZoneManager:Require11898(privacy_zone)
    self.myzoneData.privacy_zone = privacy_zone
    Connection.Instance:send(11898, {privacy_zone = privacy_zone})
end

function ZoneManager:On11898(data)
    -- BaseUtils.dump(data, "On11898")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function ZoneManager:Require11899(privacy_moments)
    self.myzoneData.privacy_moments = privacy_moments
    Connection.Instance:send(11899, {privacy_moments = privacy_moments})
end

function ZoneManager:On11899(data)
    -- BaseUtils.dump(data, "On11899")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end
    

function ZoneManager:GetLocation(callback)
    local url = string.format("http://api.map.baidu.com/location/ip?ak=%s&ip=&coor=bd09ll", self.Api_ak)
    --回调参数（www， str）
    ctx:GetRemoteTxt(url, callback, 3)
end

-- function ZoneManager:GetMyDataAchieveShopResourcesId(id)
--         id = tonumber(id)
--         if id >= 201 and id<=208 then
--                 return self.myDataAchieveShop[id].source_id
--         end
-- end

