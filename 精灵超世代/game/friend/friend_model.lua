-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: gongjianjun@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-02-28
-- --------------------------------------------------------------------
FriendModel = FriendModel or BaseClass()

function FriendModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function FriendModel:config()
	self.list = {}			-- 好友列表
	self.apply = {}			-- 好友申请列表
	self.plist = {}
	self.onlinelist = {}
	self.blacklist = {}     -- 黑名单列表
	self.honey_list_count = 20 --最近联系人限制
	self.last_select_group = 1 --最后选择的分组(默认选择第一个分组)
	self.last_select_friend_srv_id = nil
	self.last_select_friend_rid = nil
	self.present_count = 0 --当天可以赠送好友体力剩余次数
	self.draw_count = 0  --当天可以领取好友体力剩余次数
	self.draw_total_count = 0 --当天可以领取好友体力总次数
	self.last_select_index = 1 --默认上次选中的序号
end

--[[
@功能:添加数据
@参数:
@返回值:
]]
function FriendModel:add( val )
	-- body
	if self.list[val.srv_id .. "_" .. val.rid] == nil then
		self.list[val.srv_id .. "_" .. val.rid] = val
	end
end

function FriendModel:addPchat(val)
	if self.plist[val.srv_id .. "_" .. val.rid] == nil then
		self.plist[val.srv_id .. "_" .. val.rid] = val
	end
end

function FriendModel:getOnlineFriendList()
	local online_list = {}
	for k,v in pairs(self.list) do 
		if v and v.is_online == 1 then --在线
			table.insert(online_list,v)
		end
	end
	return online_list
end

-- 获取开通了家园的好友列表
function FriendModel:getOpenHomeFriendList(  )
	local friend_list = {}
	for k,v in pairs(self.list) do 
		if v and v.is_home == 1 then --开通了家园
			table.insert(friend_list,v)
		end
	end
	return friend_list
end

--申请列表
function FriendModel:setApplyList(list)
	self.apply = list or {}
	
end
function FriendModel:getApplyList()
	return self.apply or {}
end
function FriendModel:getApplyNum()
	local num = 0
	for i,v in pairs(self.apply) do 
		num = num +1
	end

	return num
end
--[[
@功能:删除数据
@参数:
@返回值:
]]
function FriendModel:del( srv_id,rid )
	-- body
	if self.list[srv_id .. "_" .. rid] then
		self.list[srv_id .. "_" .. rid] = nil
	end
end

--[[
@功能:更新单个数据
@参数:
@返回值:
]]
function FriendModel:updateVo( srv_id,rid,key,value )
	-- body
	local vo = self.list[srv_id .. "_" .. rid]
	if vo then
		vo:update(key,value)
	end
	return vo
end

--红点判断，要显示出可领取的数量，跟申请列表的数量
function FriendModel:getAwardNum()
	local num = 0
	for i,v in pairs(self.list) do 
		if v and v.is_draw == 1 then 
			num = num +1
		end
	end
	return num
end

function FriendModel:updateSingleFriendData(srv_id,rid,data)
	local key = srv_id .. "_" .. rid
	if self.list[key] then
		self.list[key]:setData(data)
	end
end
--[[
@功能:获取单个数据
@参数:
@返回值:
]]
function FriendModel:getVo( srv_id,rid )
	-- body
	return self.list[srv_id .. "_" .. rid]
end

--[[
@功能:转化为数组
@参数:
@返回值:
]]
function FriendModel:getArray( ... )
	local  array = Array.New()
	for k,v in pairs(self.list) do
		array:PushBack(v)
	end
	
	array:UpperSortByParams("is_online","login_out_time", "lev", "power")
	return array
end

-- 获取跨服/同服好友数据
function FriendModel:getGroupList(name)
	local array = Array.New()
	for k,v in pairs(self.list) do
		if v.is_cross==1 and name=="cross" then
				array:PushBack(v)
		elseif v.is_cross==0 and name=="alike" then
				array:PushBack(v)
		end
	end
	array:UpperSortByParams("is_online","lev")
	return array
end

--获取跨服/同服好友在线数和总数
function FriendModel:getGroupOnlineAndTotal(group_name)
	local online_num=0
	local total_num=0
	local group_data = self:getGroupList(group_name)
	local len = group_data:GetSize()
	total_num = len
	for i=1, len do 
		local friend_vo = group_data:Get(i-1)
		if friend_vo.srv_id and friend_vo.rid and friend_vo.is_online==1 then
			online_num = online_num + 1
		end
	end
	return online_num, total_num
end

--获取所有好友在线和总数量
function FriendModel:getFriendOnlineAndTotal()
	local online_num=0
	local total_num=0
	if self.list then
		for k , friend_vo in pairs(self.list) do
			if friend_vo and friend_vo.srv_id and friend_vo.rid and friend_vo.is_online==1 then
				online_num = online_num + 1
			end
			total_num = total_num + 1
		end
	end

	return online_num, total_num
end

--获取最近联系人在线数和总数
function FriendModel:getHoneyListOnlineAndTotal(is_require)
	local total_num=0
	local online_num=0
	local honeyList = self:getHoneyList(is_require)
	local len = honeyList:GetSize()
	total_num = len
	for i=1, len do 
		local item = honeyList:Get(i-1)
		if item.srv_id and item.rid and item.is_online==1 then
			online_num = online_num+1 
		end
	end
	return online_num, total_num
end

--获取黑名单在线数和总数
function FriendModel:getBlackListOnlineAndTotal()
	local total_num=0
	local online_num=0
	for k,v in pairs(self.blacklist) do
		if v.is_online==1 then
			online_num = online_num+1
		end
		total_num = total_num+1
	end
	return online_num,total_num
end

--[[
@功能:获取索引
@参数:
@返回值:
]]
function FriendModel:getIndex( srv_id,rid )
	-- body
	local array = self:getArray()
	for i=1,array:GetSize() do
		local vo = array:Get(i-1)
		if vo.srv_id == srv_id and vo.rid == rid then
			return i
		end
	end
	return nil
end

function FriendModel:isFriend( srv_id,rid  )
	if srv_id == nil or rid == nil then 
		return false
	end
	
	local vo = self.list[srv_id .. "_" .. rid]
	if vo and vo.is_moshengren == 0 then
		return true
	end
	return false
end

--坑货，前人挖洞，后人掉坑
function FriendModel:isFriend2(key )
	local vo = self.list[key]
	-- body
	if vo and vo.is_moshengren == 0 then
		return true
	end
	return false
end

-- ----获取联系的人的数据
-- function FriendModel:getHoneyList(is_require)
--     local array = Array.New()
--     local reuire_list = {}
--     local stranger_list = ChatController:getInstance():getModel():getStrangerList()
--     for key,v in pairs(stranger_list) do
--     	if self.list[key] ~= nil then
--     		self.list[key].talk_time = v.talk_time
--     		array:PushBack(self.list[key])
--     	else   		
--     		array:PushBack(v)
--     		table.insert(reuire_list,{id = v.rid, srv_id = v.srv_id })
--     	end
--     end
--     -- if #reuire_list > 0 and not is_require then --is_require控制是否需要请求该陌生人在线状态
--     --     FriendController:getInstance():sender_10388(reuire_list)
--     -- end
--     array:UpperSortByParams("talk_time")
--     -- return array

--     local limit_array = Array.New()
--     local len = array:GetSize()
--     -- print("--------$$$$$$$-getHoneyList-len---",len)
--     for i=0 ,len-1 do 
--     	if i < self.honey_list_count then --拿最近联系人的20个人
--     		limit_array:PushBack(array:Get(i))
--     	else
--     		--其余被顶替的人员删除看看要不要删除聊天记录
--     		local data_vo = array:Get(i)
--     		ChatController:getInstance():getModel():clearTalkTime(data_vo.srv_id, data_vo.rid)
--     	end
--     end
--     return limit_array
-- end

---保存非好友联系人的在线数据
function FriendModel:setOnlineData(list)
    self.onlinelist = {}
    for i,vo in pairs(list) do
    	local key = string.format("%s+%d", vo.srv_id, vo.id)
        self.onlinelist[key]= 1
    end   
end
function FriendModel:getOnlineData(key)
    if self.onlinelist[key] then
   	    return 1
   	else
   		return 0
   	end
end
function FriendModel:setOnlineKey(key)
   self.onlinelist[key] = 1
end

function FriendModel:setFriendPresentCount(count)
	self.present_count = count
end

function FriendModel:getFriendPresentCount()
	return self.present_count
end

function FriendModel:setFriendDrawCount(count)
	self.draw_count = count
end

function FriendModel:getFriendDrawCount()
	return self.draw_count
end

function FriendModel:setFriendDrawTotalCount( total )
	self.draw_total_count = total
end

function FriendModel:getFriendDrawTotalCount( )
	return self.draw_total_count 
end

--------------------
-- 黑名单模块数据：
---------------------

-- 初始化
function FriendModel:initBlackList(list, is_add)
	for k, v in pairs(list) do
		local vo = FriendVo.New()
		vo:setData(v)
		self.blacklist[v.rid.."_"..v.srv_id] = vo
	end
end

-- 移除黑名单
function FriendModel:removeBlack(rid, srv_id)
	if rid and srv_id then
		self.blacklist[rid.."_"..srv_id] = nil
	end
end

-- 黑名单数组
function FriendModel:getBlackArray()
	local array = Array.New()
	for k,v in pairs(self.blacklist) do
		array:PushBack(v)
	end
	array:UpperSortByParams("is_online","lev")
	return array
end

-- 是否在黑名单里面
function FriendModel:isBlack(rid, srv_id)
	local isIn = false
	if rid and srv_id and self.blacklist[rid.."_"..srv_id] then
		isIn = true
	end
	return isIn
end

function FriendModel:setLastSelectGroup(value)
	self.last_select_group = value
end

function FriendModel:getLastSelectGroup()
	return self.last_select_group

end

function FriendModel:setLastSelectFriend(srv_id,rid)
	self.last_select_friend_srv_id = srv_id
	self.last_select_friend_rid = rid
end

function FriendModel:setLastSelectFriendIndex(index)
	self.last_select_index = index or 1
end

function FriendModel:getLastSelectFriendIndex()
	return self.last_select_index
end

function FriendModel:getLastSelectFriend()
	return self.last_select_friend_srv_id , self.last_select_friend_rid
end
	
function FriendModel:__delete()
end