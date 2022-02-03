--[[
    * 类注释写在这里-----------------
    -- 聊天数据管理
    * @author {cloud}
    * <br/>Create: 2016-12-23
]]
ChatModel = ChatModel or BaseClass()
ChatModel.cache_version = "v.20150312"
function ChatModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function ChatModel:config()
	--好友聊天记录
  self.friend_cache = {}
  self.contact_list = {}
  self.red_list = {}
  self.max_count = 50
  self.stack_id = 1
  self.last_show_time = nil
end

--拷贝数据
function ChatModel.clone(data,channel)
	data.role_list[1] = data.role_list[1] or {}
	local t = ChatVo.New()
	t.channel  = channel
    t:setObjectAttr(data)
    t:setMessageAttr(data.role_list[1])
	return t
end

function ChatModel:setLastShowTime(value)
    self.last_show_time = value
end

function ChatModel:getLastShowTime()
  return self.last_show_time
end

--好友聊天内容Key
function ChatModel:formatFriendKey(srv_id_me, rid_me, srv_id, rid)
  srv_id_me = srv_id_me or 0
  rid_me = rid_me or 0
  rid = rid or 0
  srv_id = srv_id or 0
  return "chat_"..srv_id_me.."_"..rid_me.."_"..srv_id.."_"..rid
end

--获取私聊内容
function ChatModel:getFriendMsg(srv_id_me, rid_me, srv_id, rid)
  local key = self:formatFriendKey(srv_id_me, rid_me, srv_id, rid)
  if not self.friend_cache[key] then
    self.friend_cache[key] = {}
    local temp = SysEnv:getInstance():loadPrivateChatFile(srv_id, rid)
    if temp ~= nil then
        for i=1,#temp do
              local vo = temp[i]
              if vo.version == ChatModel.cache_version  then
                 table.insert(self.friend_cache[key], vo)
              end
        end
    end
  end
  return key, self.friend_cache[key]
end

--保存私聊内容
function ChatModel:setFriendMsg(srv_id_me, rid_me, srv_id, rid, data_list)
    local key, value = self:getFriendMsg(srv_id_me, rid_me, srv_id, rid)
    for i=1, #data_list do
        if not self:checkHadCache(value, data_list[i]) then
            table.insert(value, data_list[i])
        end
    end
    self.friend_cache[key] = value
end

function ChatModel:checkHadCache(list, vo)
    local had_cache = false
    if list and #list == 0 then
        return false
    else
        for k,v in pairs(list) do
            if v["talk_time"] == vo["talk_time"] then
                had_cache = true
                break
            end
        end
    end
    return had_cache
end

--聊天内容写入到本地客户端
function ChatModel:writeFriendMsg(srv_id_me, rid_me, srv_id, rid,talk_time)
  local key = self:formatFriendKey(srv_id_me, rid_me, srv_id, rid)
  if self:checkHadSave(srv_id_me, rid_me, srv_id, rid, talk_time) then return end

  if self.friend_cache[key] and #self.friend_cache[key] > 0 then
      local temp = {}
      for i=1,#self.friend_cache[key] do
          if i > self.max_count then
            table.remove(temp, 1)
          end
          local vo = self.friend_cache[key][i]
          vo.version = ChatModel.cache_version
          table.insert(temp, vo)
      end
      self.friend_cache[key] = deepCopy(temp)
      SysEnv:getInstance():savePrivateChatFile(srv_id,rid, temp)
  end
end

--保存新增的私聊数据
function ChatModel:pushPrivateMsg(data_list,srv_id,rid,talk_time)
    local role_vo = RoleController:getInstance():getRoleVo()
    local chatVo = PrivateChatVo.New()
    chatVo:setChatVo(data_list)
    chatVo.id = talk_time or GameNet:getInstance():getTime()
    -- chatVo.id = self.stack_id
    -- self.stack_id = self.stack_id + 1
    self:setFriendMsg(role_vo.srv_id, role_vo.rid, srv_id, rid, {cutBaseClass(chatVo)}) 
    return chatVo
end

function ChatModel:checkHadSave(srv_id_me, rid_me, srv_id, rid,talk_time)
    local key = self:formatFriendKey(srv_id_me, rid_me, srv_id, rid)
    
    -- 写入的时候,有限判断是否已经存在
    local local_data = SysEnv:getInstance():loadPrivateChatFile(srv_id,rid)
    local hadWrite = false
    if local_data ~= nil then
        for k,v in pairs(local_data) do
            if v["talk_time"] == talk_time then
                hadWrite = true
                break
            end
        end
    end

    return hadWrite
end

function ChatModel:deleteCache( srv_id_me, rid_me, srv_id, rid )
  -- body
   local key = self:formatFriendKey(srv_id_me, rid_me, srv_id, rid)
   self.friend_cache[key] = {}
   SysEnv:getInstance():savePrivateChatFile(srv_id,rid, {})

   self:delContactList(srv_id,rid)
   self:writeContactList()
end

---记录玩家聊天的时间数据
-- 写入缓存
function ChatModel:writeToDefaultXML()
    local time = GameNet:getInstance():getTime()
    local vo = RoleController:getInstance():getRoleVo()
    if not self.cacheList then return end
    local myKey = vo.srv_id .. "|" .. vo.rid
    local str
    for k, v in pairs(self.cacheMe) do
        if str == nil then
            str = k
        else
            str = str .. "," .. k
        end 

    end
    self.cacheList[myKey] = str
    local key_str = string.format("%s_%d_%s","friend_info",vo.rid,vo.srv_id) 
    --SaveLocalData:getInstance():writeLuaData(key_str,self.cacheList)
end

function ChatModel:getTalkTime(srv_id,rid)
    local key = string.format("%s+%d", srv_id, rid)
    if self.talk_list[key] then 
        return 
    end
end

function ChatModel:saveTalkTime(srv_id,rid)
    self:initTalkList()
    local time =  GameNet:getInstance():getTime()
    local vo = RoleController:getInstance():getRoleVo()
    local key_str = string.format("%s_%s_%d","friend_info",vo.srv_id,vo.rid)
    local key = string.format("%s+%d", srv_id, rid)
    local save_time = tonumber(self.talk_list[key])
    if save_time == time then
        return
    else    
        self.talk_list[key] = time
        local tmp_list = {}
        for k, v in pairs(self.talk_list) do 
            if v ~= nil then 
                tmp_list[k] = v
            end
        end
        --SaveLocalData:getInstance():writeLuaData(key_str, tmp_list)
    end
end

---清除聊天记录时间
function ChatModel:clearTalkTime(srv_id,rid)
    local vo = RoleController:getInstance():getRoleVo()
    self:initTalkList()
    local key = string.format("%s+%d", srv_id, rid)
    if self.talk_list[key] ~= nil then
        self.talk_list[key] = nil
    end
    local tmp_list = {}
    for k, v in pairs(self.talk_list) do 
        if v ~= nil then 
            tmp_list[k] = v
        end
    end
    --SaveLocalData:getInstance():writeLuaData(key_str, tmp_list)
    if not FriendController:getInstance():isFriend(srv_id,rid) then
        self:deleteCache( vo.srv_id, vo.rid, srv_id, rid )
    end
end

function ChatModel:initTalkList()
  if self.talk_list == nil then
    local vo = RoleController:getInstance():getRoleVo()
    local key = string.format("%s_%s_%d","friend_info",vo.srv_id,vo.rid)
    self.talk_list = {} --SaveLocalData:getInstance():readTableForKey(key) or {}
  end
end

function ChatModel:getTalkList()
    if self.talk_list == nil then
       self:initTalkList()
    end
    return self.talk_list
end
function ChatModel:saveTalkTime2(srv_id,rid)
    self:initTalkList()
    local key = string.format("%s+%d", srv_id, rid)
    local time =  GameNet:getInstance():getTime()
    local save_time = tonumber(self.talk_list[key])
    if save_time == time then
        return true
    else
        if self.talk_list[key] ~= nil then
            self.talk_list[key] = time
            local key,datalist =  self:getFriendMsg(srv_id_me, rid_me, srv_id, rid)
            if #datalist == 0 then 
                return false
            else
               return true
            end
        else
            self.talk_list[key] = time
            return false
        end            
    end
end

--添加一个最近联系人
function ChatModel:addContactList( srv_id,rid )
    local vo = FriendController:getInstance():getModel():getVo(srv_id,rid)
    if vo == nil then -- 如果不是好友，那可能是绑定邀请码的陌生人，也需要支持聊天
      local role_info = InviteCodeController:getInstance():getModel():getFriendChatData(rid, srv_id)
      if role_info and next(role_info) ~= nil then
         vo = FriendVo.New()
         vo:setData(role_info)
      end
    end
    if self.contact_list == nil then
      self.contact_list = {}
    end
    if vo ~= nil then
      self.contact_list[srv_id.."_"..rid] = {srv_id = vo.srv_id,rid= vo.rid}
    end
end

function ChatModel:delContactList( srv_id,rid  )
    local list = {}
    if self.contact_list and self.contact_list[srv_id.."_"..rid] then
      for k,v in pairs(self.contact_list) do
        if (srv_id.."_"..rid)~=(v.srv_id.."_"..v.rid) then
          list[v.srv_id.."_"..v.rid] = v
        end
      end
      self.contact_list = list
    end

    self:writeContactList()
end


--将最近联系人写入到本地客户端
function ChatModel:writeContactList()
  SysEnv:getInstance():saveContactListFile(self.contact_list)
end

--获取最近联系人(仅有srv_id,rid)
function ChatModel:getContectList(  )
  self.contact_list = SysEnv:getInstance():loadContactListFile()
  return self.contact_list or {}
end

--获取最近联系人(详细)
function ChatModel:getContectList2(  )
    local list = {}
    for k,v in pairs(self:getContectList()) do
      local vo = FriendController:getInstance():getModel():getVo(v.srv_id,v.rid)
      if vo == nil then
        local role_info = InviteCodeController:getInstance():getModel():getFriendChatData(v.rid, v.srv_id)
        if role_info and next(role_info) ~= nil then
           vo = FriendVo.New()
           vo:setData(role_info)
        end
      end
      list[v.srv_id .. "_" .. v.rid] = vo
    end
    return list
end

-- 获取所有联系人
function ChatModel:getAllFriendList(  )
    local list = {}
    local allFriendArray = FriendController:getInstance():getModel():getArray()
    local allFriendList = allFriendArray.items or {}
    for k,fData in pairs(allFriendList) do
        list[fData.srv_id .. "_" .. fData.rid] = fData
    end
    return list
end

--保存显示红点数 srv_id对方的
function ChatModel:setRedList(srv_id,rid,num)
    if self.red_list[srv_id.."_"..rid] == nil then
        self.red_list[srv_id.."_"..rid] = num
    else
        local temp = self.red_list[srv_id.."_"..rid]
        self.red_list[srv_id.."_"..rid] = temp+num
    end
    GlobalEvent:getInstance():Fire(ChatEvent.UpdatePrivateChatRed)
end

function ChatModel:getRedList(srv_id,rid)
    return self.red_list[srv_id.."_"..rid] or {}
end

function ChatModel:delRedList( srv_id,rid )
  if self.red_list[srv_id.."_"..rid] then
    self.red_list[srv_id.."_"..rid] = 0
  end
  GlobalEvent:getInstance():Fire(ChatEvent.UpdatePrivateChatRed)
end

function ChatModel:getRedCount(  )
  local count = 0
  for k,v in pairs(self.red_list) do
    count = count+v
  end
  return count
end

--存一下最新的艾特数据
function ChatModel:setAtData( data )
  self.at_data = data
end

function ChatModel:getAtData(  )
  return self.at_data
end

function ChatModel:__delete()
end

function ChatModel:setRedStatus()
end