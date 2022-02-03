-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: gongjianjun@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--     好友协议和逻辑控制层
-- <br/>Create: 2017-02-28
-- --------------------------------------------------------------------
FriendController = FriendController or BaseClass(BaseController)

function FriendController:config()
    self.pri_list = {}            --私聊聊天条数
    self.model = FriendModel.New(self)
    self.dispather = GlobalEvent:getInstance()
    self.give_name = ""
end

function FriendController:getModel()
    return self.model
end

function FriendController:isFriend( srv_id,rid )
    if self.model == nil then
        return nil
    else
        return self.model:isFriend(srv_id,rid)
    end
end

function FriendController:registerEvents()
    if self.login_success == nil then
        self.login_success = self.dispather:Bind(EventId.ROLE_CREATE_SUCCESS, function ()
            self:friendList()
            -- self:getBlackList()
            
            GlobalTimeTicket:getInstance():add(function()
                self:updateFriendTishi()
            end, 1, 1) 
        end)
    end

    if not self.request_event then
        self.request_event = GlobalEvent:getInstance():Bind(FriendEvent.REQUEST_LIST,function()
            self:friendList()
            self:getBlackList()
        end)
    end

    if not self.add_event then
        self.add_event = GlobalEvent:getInstance():Bind(FriendEvent.FRIEND_ADD,function(srv_id,rid)
            self:addOther(srv_id,rid)
        end)
    end

    if not self.query_event then
        self.query_event = GlobalEvent:getInstance():Bind(FriendEvent.FRIEND_QUERY_FIND,function(value)
            self:queryFind(value)
        end)
    end

    if not self.recommend_event then
        self.recommend_event = GlobalEvent:getInstance():Bind(FriendEvent.FRIEND_RECOMMEND,function()
            self:recommend()
        end)
    end

    if not self.infom_event then  ---好友邮件界面
        self.infom_event = GlobalEvent:getInstance():Bind(FriendEvent.OPEN_FRIEND_INFOM,function(data,count,begin_pos,group_type)           
            self:openInfom(data,count,begin_pos,group_type)
        end)
    end

      --增加私聊数据
    if not self.private_msg then
        self.private_msg = GlobalEvent:getInstance():Bind(EventId.CHAT_UPDATE_SELF, function(chatVo)
            self:addPrivateMsg(chatVo)
        end)
    end

    if not self.update_chat_and_apply_event then
        self.update_chat_and_apply_event = GlobalEvent:getInstance():Bind(FriendEvent.UPDATE_COUNT, function(type,group,list)
            self:updateFriendTishi()
        end)
    end
end

function FriendController:registerProtocals()
    self:RegisterProtocal(13300, "friendListHandler")       --好友列表
    self:RegisterProtocal(13301, "onlineHandler")           --好友在线状态
    self:RegisterProtocal(13302, "friendStateHandler")      --单个好友一些状态改变
    self:RegisterProtocal(13303, "addOtherHandler")         --请求加好友;A向服务端请求想加B为好友;会返回消息告诉A这次请求是否成功
    self:RegisterProtocal(13304, "addMeHandler")            --被加好友，服务端告诉客户端;A想加B为好友
    self:RegisterProtocal(13305, "acceptHandler")           --B告诉服务端，加或不加A为好友;服务端会告诉B这次结果怎么样
    self:RegisterProtocal(13306, "batchAddHandler")         --批量加好友
    self:RegisterProtocal(13307, "delOtherHandler")         --主动删除好友;需要客户端把好友删除
    self:RegisterProtocal(13308, "delMeHandler")            --被动删除好友
    self:RegisterProtocal(13310, "addToListHandler")        --添加好友到列表（添加好友成功后服务端推送）
    self:RegisterProtocal(13311, "applyListHandler")        --好友申请列表
    self:RegisterProtocal(13312, "refuseApplyListHandler")        --全部拒绝申请列表
    self:RegisterProtocal(13314, "queryFindHandler")        --查询好友信息
    self:RegisterProtocal(13315, "queryFriendTeamHandler")  --查询好友是否有队伍
    self:RegisterProtocal(13316, "strengthHandler")         --好友体力赠送领取
    self:RegisterProtocal(13317, "batchStrengthHandler")    --好友体力一键赠送领取
    self:RegisterProtocal(13320, "recommendHandler")        --推荐好友
    self:RegisterProtocal(10388, "getRolesOnline")          -- 查询其它玩家是否在线

    --黑名单
    self:RegisterProtocal(13330, "handle13330") --获取黑名单列表信息
    self:RegisterProtocal(13331, "handle13331") --获取增加更新黑名单列表信息
    self:RegisterProtocal(13332, "handle13332") --拉黑
    self:RegisterProtocal(13333, "handle13333") --移除黑名

    self:RegisterProtocal(13334, "handle13334") --全部同意好友申请
end

function FriendController:updateFriendTishi()
    local award_num = self.model:getAwardNum() or 0
    local appl_num =  self.model:getApplyNum() or 0
    local list = {{bid=1, num = award_num},{bid=2, num = appl_num}}
    MainuiController:getInstance():setFunctionTipsStatus(MainuiConst.icon.friend, list)
end

--[[
@功能:好友列表
@参数:13300
]]
function FriendController:friendList()
    local protocal = {}
    self:SendProtocal(13300,protocal)
end

function FriendController:friendListHandler( data )
    --Debug.info(data)
    if self.model == nil then
        self.model = FriendModel.New(self)
    end
    self.model:setFriendPresentCount(data.present_count)
    self.model:setFriendDrawCount(data.draw_count)
    self.model:setFriendDrawTotalCount(data.draw_all )
    --print("=====13300===draw_count=======present_count======", data.draw_count,data.present_count)
    for k,v in pairs(data.friend_list) do
        local friend = nil
        if self.model:isFriend(v.srv_id,v.rid) then
            friend = self.model:getVo(v.srv_id,v.rid)
            friend:setData(v)
        else
            friend = FriendVo.New()
            friend:setData(v)
            
            self.model:add(friend)
        end
    end
    GlobalEvent:getInstance():Fire(FriendEvent.FRIEND_LIST, self.model:getArray())
    self:apply()

    self:updateFriendTishi()
end

--[[
@功能:好友是否上线
@参数:13301
@返回值:
]]
function FriendController:onlineHandler( data )
    local old_index = self.model:getIndex(data.srv_id,data.rid)
    local vo = self.model:updateVo(data.srv_id,data.rid,"is_online",data.is_online) --更新先后顺序 1
    local vo = self.model:updateVo(data.srv_id,data.rid,"login_out_time",data.login_out_time) --更新先后顺序 2
    local new_index = self.model:getIndex(data.srv_id,data.rid)
    
    if old_index and  new_index and vo then
        if vo then
            if data.is_online == 1 then
                GlobalEvent:getInstance():Fire(FriendEvent.FRIEND_UPDATE_ITEM, vo, 0)
                showRichMsg(string.format(TI18N("您的好友<div fontcolor=#00ff00>%s</div>上线了"), vo.name))
            end
        end
    end
end

--单个好友一些状态改变
function FriendController:friendStateHandler(data)
    if data.srv_id and data.rid then
        self.model:updateSingleFriendData(data.srv_id,data.rid,data)
        GlobalEvent:getInstance():Fire(FriendEvent.FRIEND_LIST, self.model:getArray() )
    end
    self:updateFriendTishi()
end

--[[
@功能:好友申请列表
@参数:
@返回值:
]]
function FriendController:apply( ... )
    local protocal = {}
    self:SendProtocal(13311,protocal)
end

function FriendController:applyListHandler( data )        
    --亲密度设置为-1(表示陌生人)
    --Debug.info(data)
    for _, v in pairs(data.friend_req_list) do
        v.intimacy = -1
    end
    self.model:setApplyList(data.friend_req_list)
    GlobalEvent:getInstance():Fire(FriendEvent.UPDATE_COUNT,2,#self.model.apply)--单个数据增加
    GlobalEvent:getInstance():Fire(FriendEvent.FRIEND_APPLY)
    GlobalEvent:getInstance():Fire(FriendEvent.Update_Red_Point)
    self:updateFriendTishi()
end

function FriendController:send_refuseApplyList()
    local protocal = {}
    self:SendProtocal(13312,protocal)
end

function FriendController:refuseApplyListHandler(data)
    --Debug.info(data)
    if data.code == 1 then
        GlobalEvent:getInstance():Fire(FriendEvent.UPDATE_APPLY_LIST)
        self.model.apply = {}
        self:updateFriendTishi()
    end
end

--全部同意好友申请
function FriendController:send_acceptApplyList(list)
    local protocal = {}
    protocal.role_ids = list
    self:SendProtocal(13334,protocal)
end

function FriendController:handle13334(data)
    --Debug.info(data)
    GlobalEvent:getInstance():Fire(FriendEvent.UPDATE_APPLY_LIST)
    self.model.apply = {}
    self:updateFriendTishi()
    GlobalEvent:getInstance():Fire(FriendEvent.Update_Red_Point)
end


-- 好友申请个数
function FriendController:appCount( ... )
    if self.model then
        return #self.model.apply
    end
    return 0
end

--[[
@功能:推荐好友
@参数:
@返回值:
]]
function FriendController:recommend( ... )
    local protocal ={}
    self:SendProtocal(13320,protocal)
end
function FriendController:recommendHandler(data)
--     Debug.info(data)
    local list = {}
    local srv_id = RoleController:getInstance():getRoleVo().srv_id
    local rid = RoleController:getInstance():getRoleVo().rid
    for _, v in pairs(data.recommend_list) do
        if not self:isFriend(v.srv_id, v.rid) and not(srv_id==v.srv_id and rid==v.rid) then
            v.intimacy = -1 --标记为陌生人
            table.insert(list, v)
        end
    end

    GlobalEvent:getInstance():Fire(FriendEvent.UD_COMMEND_LIST,list)
end

--[[
@功能:模糊查询
@参数:13314
@返回值:
]]
function FriendController:queryFind( name )
    local protocal ={}
    protocal.name = name
    self:SendProtocal(13314,protocal)
end
function FriendController:queryFindHandler( data )
    local t = {}
    if #data.role_list > 0 then
        local srv_id = RoleController:getInstance():getRoleVo().srv_id
        local rid = RoleController:getInstance():getRoleVo().rid
        local count = 0
       
        for k, v in pairs(data.role_list) do
            if not self:isFriend(v.srv_id, v.rid) and not(srv_id==v.srv_id and rid==v.rid) then
                v.intimacy = -1 --标记为陌生人
                table.insert(t, v)
                count = count + 1
            end
            if count > 25 then break end
        end
        table.sort(t, function(a,b)
            return a.lev > b.lev
        end)
        if not t or  next(t) ==nil then 
            message(TI18N("找不到玩家"))
        end
       
    else
        message(TI18N("找不到玩家"))
    end
    GlobalEvent:getInstance():Fire(FriendEvent.FRIEND_QUERY_RESULT, t)
end

function FriendController:queryFriendIsHasTeam( rid,srv_id )
    local protocal ={}
    protocal.rid = rid
    protocal.srv_id = srv_id
    self:SendProtocal(13315,protocal)
end

function FriendController:queryFriendTeamHandler( data )
    if data.code == 1 then--有队伍
        self:openFrinedInfo(1)
    elseif data.code == 0 then--没有队伍
        self:openFrinedInfo(0)
    end
end


--好友体力领取 赠送 code: 0 赠送 ，1领取
function FriendController:sender_13316(code, rid, srv_id)
    local protocal = {}
    protocal.rid = rid
    protocal.srv_id = srv_id
    protocal.code = code
    self:SendProtocal(13316, protocal)
   
end

function FriendController:strengthHandler(data)
    if data.code == 1 then
        self.model:setFriendPresentCount(data.present_count)
        self.model:setFriendDrawCount(data.draw_count)

        local vo = self.model:updateVo(data.srv_id,data.rid,"is_draw",data.is_draw)
        local vo = self.model:updateVo(data.srv_id,data.rid,"is_present",data.is_present)

       GlobalEvent:getInstance():Fire(FriendEvent.STRENGTH_UPDATE, {list={vo}})
       GlobalEvent:getInstance():Fire(FriendEvent.Update_Red_Point)
    end
    message(data.msg)
end

--好友体力领取 赠送 code: 0 赠送 ，1领取
function FriendController:sender_13317(code, list)
    local protocal = {}
    protocal.list = list
    protocal.code = code
    self:SendProtocal(13317, protocal)
end

function FriendController:batchStrengthHandler(data)
    --Debug.info(data)
    if data.code == 1 then
        -- GlobalEvent:getInstance():Fire(FriendEvent.STRENGTH_UPDATE, data)
        GlobalEvent:getInstance():Fire(FriendEvent.Update_Red_Point)
    end
    message(data.msg)
end

--[[
@功能:请求加好友;A向服务端请求想加B为好友;会返回消息告诉A这次请求是否成功
@参数:13303
@返回值:
]]
function FriendController:addOther(srv_id,rid)
    local protocal = {}
    protocal.srv_id = srv_id
    protocal.rid = rid
    self:SendProtocal(13303,protocal)
end
function FriendController:addOtherHandler( data )
    message(data.msg)
    if data.code==1 then
        self:closeInfo()
    end
  
end

--[[
@功能:被加好友，服务端告诉客户端;A想加B为好友
@参数:13304
@返回值:
]]
function FriendController:addMeHandler( data )
    if FriendController:getInstance():getModel():isBlack(data.rid, data.srv_id) then return end
    self:apply()
    -- self:accept(data.srv_id,data.rid,1)
end

--[[
@功能:B告诉服务端，加或不加A为好友;服务端会告诉B这次结果怎么样
@参数:13305
@返回值:
]]
function FriendController:accept( srv_id,rid,agreed )

    local protocal = {}
    protocal.srv_id = srv_id
    protocal.rid = rid
    protocal.agreed = agreed
    self:SendProtocal(13305,protocal)
end
function FriendController:acceptHandler( data )
--Debug.info(data)
    --删除客户端缓存的好友申请数据
    if data~= nil  then
        for k,v in pairs(self.model.apply) do
            if v.srv_id == data.srv_id and v.rid == data.rid then
                table.remove(self.model.apply,k)
            end
        end
        GlobalEvent:getInstance():Fire(FriendEvent.UPDATE_COUNT,2,#self.model.apply)--单个数据增加
        self:updateFriendTishi()
        if data.code == 1 then
            ChatController:getInstance().model:saveTalkTime(data.srv_id,data.rid)
            message(data.msg)
        else
            message(data.msg)
        end
      
    end
end

--[[
@功能:添加好友到列表（添加好友成功后服务端推送）
@参数:
@返回值:
]]
function FriendController:addToListHandler( data )
    -- print("=====addToListHandler==data.rid,data.srv_id,data.name======",data.rid,data.srv_id,data.name)
    if self.model then
        local friend = FriendVo.New()
        friend:setData(data)
        self.model:add(friend)
        if self.model.apply then
            for m, n in pairs(self.model.apply) do
                if data.srv_id==n.srv_id and data.rid==n.rid then
                    self.model.apply[m] = nil
                end
            end
        end
         GlobalEvent:getInstance():Fire(FriendEvent.UPDATE_APPLY)
         showRichMsg(string.format(TI18N("成功添加<div fontcolor=#00ff00>%s</div>为好友"), data.name))
    
    end
end

--[[
@功能:批量加好友
@参数:13306
@返回值:
]]
function FriendController:batchAdd( role_ids )

    local protocal = {}
    protocal.role_ids = role_ids
    self:SendProtocal(13306,protocal)
end
function FriendController:batchAddHandler( data )

    message(data.string)
end

--[[
@功能:主动删除好友;需要客户端把好友删除
@参数:13307
@返回值:
]]
function FriendController:delOther( srv_id, rid )
    local confirm_handler = function()
        local protocal = {}
        protocal.srv_id = srv_id
        protocal.rid = rid
        self:SendProtocal(13307,protocal)
        
    end
    CommonAlert.show(TI18N("好友删除后，将清空聊天记录，是否删除好友？"),TI18N("删除"),confirm_handler,TI18N("取消"))
end

function FriendController:delOtherHandler( data )
    --删除数据
    --删除视图
    -- print("====delOtherHandler====code======",data.code,data.rid,data.srv_id)
    if data.code == 1 then
        local old_data = self.model:getVo(data.srv_id,data.rid)
        if old_data then
            self.model:del(data.srv_id,data.rid)
            --ChatController:getInstance():getModel():delContactList( data.srv_id,data.rid  )
            --删除最近联系人
            local role_vo = RoleController:getInstance():getRoleVo()
            ChatController:getInstance():getModel():deleteCache(role_vo.srv_id,role_vo.rid,data.srv_id,data.rid)

            GlobalEvent:getInstance():Fire(FriendEvent.FRIEND_DELETE,old_data,self.group_type)
        end
        self:closeInfom()
    end

    message(data.msg)
end

--[[
@功能:被动删除好友（被人删）
@参数:13308
@返回值:
]]
function FriendController:delMeHandler( data )
    --删除数据
    --删除视图
    local old_data = self.model:getVo(data.srv_id,data.rid)
    if old_data then
        self.model:del(data.srv_id,data.rid)
        --删除最近联系人
        --ChatController:getInstance():getModel():delContactList( data.srv_id,data.rid  )
        local role_vo = RoleController:getInstance():getRoleVo()
        ChatController:getInstance():getModel():deleteCache(role_vo.srv_id,role_vo.rid,data.srv_id,data.rid)

        GlobalEvent:getInstance():Fire(FriendEvent.UPDATE_GROUP_COUNT)
    end
end

function FriendController:deleteConnecter(vo)
    local confirm_handler = function()
        ChatController:getInstance():getModel():clearTalkTime(vo.srv_id, vo.rid)
        GlobalEvent:getInstance():Fire(ContactEvent.CLOSE_TALK_INFO) 
        self:closeInfom()
        GlobalEvent:getInstance():Fire(FriendEvent.FRIEND_DELETE,vo,FriendConst.FriendGroupType.communicate)
        
    end
    CommonAlert.show("是否从列表中删除该联系人？","删除",confirm_handler,"取消")

end

function FriendController:deleteBlackConnecter(srv_id,rid)
        ChatController:getInstance():getModel():clearTalkTime(srv_id, rid)
        GlobalEvent:getInstance():Fire(ContactEvent.CLOSE_TALK_INFO) 
        self:closeInfom()
        GlobalEvent:getInstance():Fire(FriendEvent.FRIEND_DELETE,{srv_id=srv_id,rid=rid},FriendConst.FriendGroupType.friend)
end

function FriendController:sender_10388(list)
    local protocal = {}
    protocal.id_list = list
    self:SendProtocal(10388,protocal)

end
  ---获取常用联系人上线情况
function FriendController:getRolesOnline(data)
    if data then
       GlobalEvent:getInstance():Fire(FriendEvent.UPDATE_ONLINE,data.online_roles)
    end
end

--竖版好友主界面
function FriendController:openFriendWindow(bool,index)
    if bool == true then 
        if not self.friend_window  then
            self.friend_window = FriendWindow.New()
        end
        self.friend_window:open(index)
    else
        if self.friend_window then 
            self.friend_window:close()
            self.friend_window = nil
        end
    end
end

function FriendController:getFriendWndDelStatus(  )
    if self.friend_window and self.friend_window:getDelFriendStatus() then
        return true
    end
    return false
end

--竖版好友推荐查找界面
function FriendController:openFriendFindWindow(bool)
    if bool == true then 
        if not self.friend_find_window  then
            self.friend_find_window = FriendAddWindow.New()
        end
        self.friend_find_window:open()
    else
        if self.friend_find_window then 
            self.friend_find_window:close()
            self.friend_find_window = nil
        end
    end
end



--[[
@功能:关闭好友信息界面
@参数:
@返回值:
]]
function FriendController:closeInfo( ... )
    if self.info and self.info:isOpen() then
        self.info:close()
        self.info = nil
    end
end

function FriendController:openFrinedInfo(code_type)
    self:closeRecommendPanel() 
    local show_type 
  
    if self.group_type == 1 then --我的好友
        show_type = {11,12,15}
    elseif self.group_type == 3 then --黑名单
        show_type = {2,13,15}
    end
end

--打开好友信息查看界面 data有srv_id,rid就行
function FriendController:openFriendCheckPanel(status,data)
    if status == true then 
        if not data.srv_id or data.srv_id == "robot" then
            message(TI18N("神秘人太高冷，不给查看"))
            return
        end
        if not self.firend_check_view  then
            self.firend_check_view = FriendCheckInfoWindow.New()
        end
        self.firend_check_view:open(data)
    else
        if self.firend_check_view then 
            self.firend_check_view:close()
            self.firend_check_view = nil
        end
    end
end

--打开好友个人荣誉界面
function FriendController:openFriendGloryWindow( status,data )
    if status == true then 
        if not self.firend_glory_view  then
            self.firend_glory_view = FriendGloryWindow.New()
        end
        self.firend_glory_view:open(data)
    else
        if self.firend_glory_view then 
            self.firend_glory_view:close()
            self.firend_glory_view = nil
        end
    end
end


--[[
@功能:
@参数:
@返回值:
]]
function FriendController:openInfom( data, count, begin_pos, group_type)
    self.begin_pos = begin_pos
    self.group_type = group_type or 1
    self.select_data = data 

    self:openFrinedInfo()
    --self:queryFriendIsHasTeam(data.rid,data.srv_id)
end
--[[
@功能:好友邮件面板
@参数:
@返回值:
]]
function FriendController:closeInfom( ... )
    if self.infom and self.infom:isOpen() then
        self.infom:close()
        self.infom = nil
    end
end

function FriendController:closeRecommendPanel() 
    if self.commend_ui and self.commend_ui:isOpen() then
       self.commend_ui:close()
       self.commend_ui = nil
    end
end

--私聊未读数据显示
function FriendController:addPrivateMsg(chat_vo)
    if not chat_vo:isOhter() then return end
    local group_id = chat_vo.srv_id .. "_" .. chat_vo.rid
    -- local pri_chat = ChatController:getInstance():getPrivate()

    -- if pri_chat and pri_chat:isOpen() and pri_chat:getKey() == group_id then
    -- else
    --     --如果是陌生人发来的私聊，客户端构建一个假的好友信息显示在好友列表里面
    --     if not self.model:isFriend(chat_vo.srv_id,chat_vo.rid) then
    --         local friend = FriendVo.New()
    --         friend.is_moshengren = 1 --陌生人状态
    --         friend.srv_id = chat_vo.srv_id
    --         friend.rid = chat_vo.rid
    --         friend.name = chat_vo.name
    --         friend.sex = chat_vo.sex or 1
    --         friend.lev = chat_vo.lev
    --         friend.career = chat_vo.career
    --         friend.power = 0
    --         friend.login_time = 0
    --         friend.face_id = 0
    --         friend.is_online = 1
    --         friend.group_id = 0
    --         friend.intimacy = -1
    --         friend.is_vip = 0
    --         friend.gift_status = 1    --0:已赠送 1：未赠送 2:被赠送
    --         friend.grid = 0
    --         friend.gsrv_id=""
    --         friend.guild_name = ""
    --         GlobalEvent:getInstance():Fire(FriendEvent.STRANGER_LIST, self.model:getArray() ,self.model.apply)
    --     end
    --     -- 如果玩家正在打开和目标的私聊窗体,这个时候不更新聊天数量
    --     local target_data = ChatController:getInstance():getTarCacheData()
    --     if target_data == nil or target_data.srv_id ~= chat_vo.srv_id or target_data.rid ~= chat_vo.rid then
    --         if self.pri_list[group_id] == nil then
    --             self.pri_list[group_id] = 0
    --         end
    --         self.pri_list[group_id] = self.pri_list[group_id]  + 1
    --         GlobalEvent:getInstance():Fire(FriendEvent.UPDATE_COUNT,1,group_id,self.pri_list[group_id])--单个数据增加
    --     end
    --     GlobalEvent:getInstance():Fire(FriendEvent.UPDATE_GROUP_COUNT)
    -- end
end


-- 删除聊天数量
function FriendController:delPriCount( key )
    self.pri_list[key] = nil
    GlobalEvent:getInstance():Fire(FriendEvent.UPDATE_COUNT,1,key,0)--单个数据增加
end

---获取好友联系人聊天的总数目
function FriendController:getLpriCount()
    local count = 0 
    for i,v in pairs(self.pri_list) do
        local value  = self.model:isFriend2(v)
        if value == true then
           count = count + v
        end
    end
    return count
end


function FriendController:allPriCount( ... )
    local count = 0
    for i,v in pairs(self.pri_list) do
        count = count + v
    end
    return count
end

function FriendController:singlePriCount( key )
    if self.pri_list[key] then
        return self.pri_list[key]
    end
    return 0
end


function FriendController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
    self:closeRecommendPanel()
end

---------------
-- 黑名单部分
---------------

function FriendController:handle13330(data)
 --print("--------type---handle13330--------",#data.black_list)
    self.model:initBlackList(data.black_list)
end

-- 获取黑名单列表
function FriendController:getBlackList()
    local protocal = {}
    self:SendProtocal(13330,protocal)
end

--拉黑和移除黑名单推送
function FriendController:handle13331(data)
    -- print("--------type---handle13331--------",data.type)
    if data.type == 1 then --加黑名单
        self.model:initBlackList(data.black_list)
        GlobalEvent:getInstance():Fire(FriendEvent.UPDATE_GROUP_COUNT)
    elseif data.type == 2 then --移除黑名单
       
    end
end

-- 拉黑
function FriendController:addToBlackList(rid, srv_id)
    local protocal = {}
    protocal.rid = rid
    protocal.srv_id = srv_id
    self:SendProtocal(13332,protocal)
end

--拉黑是否成功返回
function FriendController:handle13332(data)
    message(data.msg)
    -- print("====handle13332====code======",data.code,data.rid,data.srv_id)      
    if data.code == 1 then
        local old_data = self.model:getVo(data.srv_id,data.rid)
        --拉黑后在好友列表里面删掉该好友
        if old_data then
            self.model:del(data.srv_id,data.rid)
            --删除最近联系人
            local role_vo = RoleController:getInstance():getRoleVo()
            ChatController:getInstance():getModel():deleteCache(role_vo.srv_id,role_vo.rid,data.srv_id,data.rid)
            --ChatController:getInstance():getModel():delContactList( data.srv_id,data.rid  )

            GlobalEvent:getInstance():Fire(FriendEvent.FRIEND_DELETE,old_data,self.group_type)
        end
    end   
end

--删除黑名单
function FriendController:deleteBlackList(rid,srv_id)
    local protocal = {}
    protocal.rid = rid
    protocal.srv_id = srv_id
    self:SendProtocal(13333,protocal)
end

--删除黑名单返回
function FriendController:handle13333(data)
-- print("======handle13333======")
    if data.code == 1 then
        self.model:removeBlack(data.rid,data.srv_id)
        GlobalEvent:getInstance():Fire(FriendEvent.FRIEND_DELETE,data,self.group_type or FriendConst.FriendGroupType.black_list) --类型2是黑名单分组
    end
end