-- @author zyh
PetEvaluationManager = PetEvaluationManager or BaseClass(BaseManager)

function PetEvaluationManager:__init(args)

    if PetEvaluationManager.Instance then
        Log.Error("不可重复实例化")
        return
    end

    PetEvaluationManager.Instance = self
    self.model = PetEvaluationModel.New(args)
    self:InitHandler()

    self.PetEvaluationData = {}       --宠物评论列表
    self.waitingCacheTab = {}
    self.noRefresh = false
end

function PetEvaluationManager:__delete()
      if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end

function PetEvaluationManager:InitHandler()
    --获取最新的列表
    self:AddNetHandler(19400,self.On19400)
    --评论回调
    self:AddNetHandler(19401,self.On19401)
    --点赞回调
    self:AddNetHandler(19402,self.On19402)
    --点踩回调
    self:AddNetHandler(19403,self.On19403)
    --点踩回调
    self:AddNetHandler(19405,self.On19405)
    -- 请求宠物缓存回调
    self:AddNetHandler(19406,self.On19406)
    -- 请求守护缓存回调
    self:AddNetHandler(19407,self.On19407)
end

-- 最开始通过协议初始化数据
function PetEvaluationManager:RequestInitData()
    self.hasThumbDic = {}

    self:Send19405()
end

-- ---------------------
-- 发送协议
-- ---------------------

function PetEvaluationManager:Send19400(data)
       self:Send(19400,data)
end

-- 发送评论的回复
function PetEvaluationManager:Send19401(data)
       BaseUtils.dump(data,"协议发送19401")
       self:Send(19401,data)
end

function PetEvaluationManager:Send19402(data)
       self:Send(19402,data)
end

function PetEvaluationManager:Send19403(data)
       self:Send(19403,data)
end

function PetEvaluationManager:Send19405(data)
       self:Send(19405,data)
end

function PetEvaluationManager:Send10410(platform, zone_id, cacheId)
    self:Send(10410, {platform = platform, zone_id = zone_id, query_id = cacheId})
end

function PetEvaluationManager:Send19406(data)
    BaseUtils.dump(data,"发送19406协议")
    self:Send(19406,data)
end

function PetEvaluationManager:Send19407(data)
    self:Send(19407,data)
end

-- ------------------------
-- 协议接收
---------------------------

function PetEvaluationManager:On19400(data)
    self.PetEvaluationData = data

    local totalTable = {}
    table.sort(self.PetEvaluationData.review,function (a,b)
        return  a.pro > b.pro
    end )


    for i=1,2 do
      table.insert(totalTable,self.PetEvaluationData.review[i])
    end

    for i=1,2 do
      table.remove(self.PetEvaluationData.review,1)
    end

    table.sort(self.PetEvaluationData.review,function (a,b)
         return a.ctime > b.ctime
    end)


    for i=1,#self.PetEvaluationData.review do
      table.insert(totalTable,self.PetEvaluationData.review[i])
    end

    if self.model.mainWin ~= nil then
        if data.page == 0 then
          self.model.mainWin:RefreshPanelFirstReply(totalTable)
        elseif data.page == 1 then
          self.model.mainWin:RefreshPanelContinueReply(totalTable)
        end
    end
end

-- 接收评论
function PetEvaluationManager:On19401(data)
       if data.result == 0 then
           NoticeManager.Instance:FloatTipsByString(data.msg)
       elseif data.result == 1 then
           NoticeManager.Instance:FloatTipsByString(TI18N("评论成功"))
           self.model.mainWin:RefreshEvaluationReply(data)
       end
end

function PetEvaluationManager:On19402(data)
     if data.flag == 0 then
        NoticeManager.Instance:FloatTipsByString(data.msg)
     elseif data.flag == 1 then
        NoticeManager.Instance:FloatTipsByString(TI18N("点赞成功"))
        self.model.mainWin:RefreshThumbsUpReply(data)
     end
end

function PetEvaluationManager:On19403(data)
    if data.flag == 0 then
        NoticeManager.Instance:FloatTipsByString(data.msg)
    elseif data.flag == 1 then
        NoticeManager.Instance:FloatTipsByString(TI18N("点踩成功"))
        self.model.mainWin:RefreshThumbsDownReply(data)
    end
end

function PetEvaluationManager:On19405(data)
     self.hasThumbAllData = data
     for i,v in ipairs(data.voted) do
         self.hasThumbDic[i] = v
     end
end


function PetEvaluationManager:On19406(data)
    BaseUtils.dump(data,"接收19406协议")
    local info = self.waitingCacheTab[string.format("%s_%s_%s_%s", data.m_platform, data.m_zone_id, MsgEumn.CacheType.Pet,data.m_id)]
    BaseUtils.dump(info,"打印info数据")
    if info ~= nil then
        self.noRefresh = true
        info.result = PetManager.Instance.model:updatepetbasedata(data)
        PetManager.Instance.model.quickshow_petdata = info.result
        PetManager.Instance.model:OpenPetQuickShowWindow()
    end
end

function PetEvaluationManager:On19407(data)
    local info = self.waitingCacheTab[string.format("%s_%s_%s_%s", data.m_platform, data.m_zone_id, MsgEumn.CacheType.Guard, data.m_id)]
    if info ~= nil then
        info.result = data
        local result_data = ShouhuManager.Instance.model:build_look_win_data(info.result, info.data.lev)
        result_data.owner_name = info.data.name
        ShouhuManager.Instance.model.shouhu_look_dat = result_data
        ShouhuManager.Instance.model:OpenShouhuLookUI()
    end
end
-------------------------------------------------


-- function PetEvaluationManager:On10410(dat)
--     local info = self.waitingCacheTab[string.format("%s_%s_%s_%s", dat.platform, dat.zone_id, MsgEumn.CacheType.Guard, dat.query_id)]
--     if info ~= nil then
--         info.result = dat
--         local result_data = ShouhuManager.Instance.model:build_look_win_data(info.result, info.data.lev)
--         result_data.owner_name = info.data.name
--         ShouhuManager.Instance.model.shouhu_look_dat = result_data
--         ShouhuManager.Instance.model:OpenShouhuLookUI()
--     end
-- end


function PetEvaluationManager:ShowCacheData(gameObject,type,msg,data,myId)
    if data == nil then
        return
    end
    local info = self.waitingCacheTab[string.format("%s_%s_%s_%s", msg.platform, msg.zoneId, type, msg.cacheId)]
    if info ~= nil and info.result ~= nil then
        info.gameObject = gameObject

        if type == MsgEumn.CacheType.Pet then
            PetManager.Instance.model.quickshow_petdata = info.result
            PetManager.Instance.model:OpenPetQuickShowWindow()
        elseif type == MsgEumn.CacheType.Guard then
            local result_data = ShouhuManager.Instance.model:build_look_win_data(info.result, data.lev)
            result_data.owner_name = data.name
            ShouhuManager.Instance.model.shouhu_look_dat = result_data
            ShouhuManager.Instance.model:OpenShouhuLookUI()
        end
        return
    else
        if type == MsgEumn.CacheType.Pet then
            self:Send19406({m_id = data.m_id,platform = data.m_platform,zone_id = data.m_zone_id,id = myId})
        elseif type == MsgEumn.CacheType.Guard then
            self:Send19407({id = data.m_id,platform = data.m_platform,zone_id = data.m_zone_id})
        end
    end
    self.waitingCacheTab[string.format("%s_%s_%s_%s", msg.platform, msg.zoneId, type, data.m_id)] = {gameObject = gameObject, type = type, data = data, msg = msg}
end



function PetEvaluationManager:OpenWindow(args)
    self.model:OpenWindow(args)
end

function PetEvaluationManager:GetPetEvaluationData()


    return self.PetEvaluationData
end

function PetEvaluationManager:GetHasThumbDic()
    return self.hasThumbDic
end

function PetEvaluationManager:SendMsg(myType,baseId,myIds,msg,isGsub)
    if msg == "" then
        return false
    end


    if isGsub == nil then
        msg = string.gsub(msg, "<.->", "")
    end
    local send_msg = MessageParser.ConvertToTag_Face(msg)
    -- send_msg = MessageParser.ReplaceSpace(send_msg)

    if ctx.PlatformChanleId == 110 then
        -- 暂时只有乐视渠道处理过滤
        send_msg = MessageFilter.Parse(send_msg)
    end

    -- if channel == MsgEumn.ChatChannel.World then
    --     NationalDayManager.Instance.model:CheckCanAnswerNationalDay(send_msg)
    -- end


    self.model.mainWin:SetCurrentEvaluation(send_msg)
    local data = { type = myType,base_id = baseId,content = send_msg,ids = myIds}
    self:Send19401(data)
    -- RedBagManager.Instance.model:CheckRedBagPassword(channel, send_msg)

    -- self.itemCache = {}
    -- self.petCache = {}
    -- self.equipCache = {}
    -- self.guardCache = {}
    -- self.wingCache = {}
    -- self.rideCache = {}
    -- self.childCache = {}
    return true
end



-- function PetEvaluationManager:On?????(dat)
--     if self:NeedFilter() and dat.channel == MsgEumn.ChatChannel.World then
--         if Time.time - self.lastReviceTime <= 0.1 then
--             -- print(Time.time - self.lastReviceTime)
--             return
--         end
--     end
--     self.lastReviceTime = Time.time

--     if self:IsSheild(dat.rid, dat.platform, dat.zone_id) then
--         print(string.format("已屏蔽此人发言 %s_%s_%s", dat.rid, dat.platform, dat.zone_id))
--         return
--     end

--     -- BaseUtils.dump(dat, "聊天内容")
--     local msgData = MessageParser.GetMsgData(dat.msg)
--     local chatData = ChatData.New()
--     chatData:Update(dat)
--     chatData.showType = MsgEumn.ChatShowType.Normal
--     chatData.msgData = msgData
--     if dat.channel == MsgEumn.ChatChannel.Bubble then
--         chatData.channel = MsgEumn.ChatChannel.Scene
--         --公会宣读
--         SceneTalk.Instance:ShowTalk_Player(dat.rid,dat.zone_id,dat.platform,dat.msg,6)--msgData.showString,6)
--         -- if dat.rid == RoleManager.Instance.RoleData.id then --自己宣读，显示读条
--         --     GuildManager.Instance:ShowPublicityCollection(5000,function ()
--         --         SceneTalk.Instance:HideTalk_Player(dat.rid,dat.zone_id,dat.platform)
--         --     end)
--         -- end
--     end
--     chatData.prefix = chatData.channel
--     self.model:ShowMsg(chatData)
-- end

