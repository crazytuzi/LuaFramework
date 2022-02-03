--[[
@作者:gongjianjun
@功能:单个好友数据
]]
FriendVo = FriendVo or BaseClass(EventDispatcher)

FriendVo.UPDATE_FRIEND_ATTR_LOGIN_OUT_TIME = "UPDATE_FRIEND_ATTR_LOGIN_OUT_TIME"

function FriendVo:__init( ... )
	-- body
	self.srv_id = ""
	self.rid = 0
	self.name = ""
	self.sex = 1
	self.lev = 0
	self.career = 1
	self.power = 0
	self.login_time = 0
	self.login_out_time = 0
	self.face_id = 0
	self.is_online = 1
	self.group_id = 0
	self.is_cross = 0
	self.intimacy = 0
	self.is_vip = 0 
	self.avatar_bid = 0
	self.gift_status = 1    --0:已赠送 1：未赠送 2:被赠送
	self.gid = 0
	self.gsrv_id=""
	self.is_moshengren = 0 --是否陌生人 0:不是  1：是 (收到陌生人私聊信息的时候，客户端会创建一些陌生人显示在好友列表里面)
	self.talk_time = 0  --交谈时间
	self.dun_id = 0

	--好友伙伴
	self.gname = ""      --公会名
	self.main_partner_id = 0  -- 主伙伴Id
	self.partner_bid = 0        --伙伴bid
	self.partner_lev = 0		--等级
	self.partner_star = 0       -- 星级
	self.is_awake = 0           -- 是否觉醒 1 觉醒 0 没有觉醒
	self.is_used = 0            --是否已使用

	self.is_present = 0         --"赠送体力情况(0:可赠送   1:已赠送
	self.is_draw   = 0          -- "是否可领取(0:不可领取   1:可领取 )
	self.face_file                      = ""
    self.face_update_time               = 0

	self.is_home = 0 -- 是否开通了家园
	self.soft = 0 	 -- 家园舒适度
end

function FriendVo:setData( data )
	-- body
	for k,v in pairs(data) do
		if self[k] then
			self[k] = v
		end
	end
end

function FriendVo:update( key,value )
	-- body
	if self[key] then
		self[key] = value

		if key == "login_out_time" then
			self:Fire(FriendVo.UPDATE_FRIEND_ATTR_LOGIN_OUT_TIME,self)
		end
	end

end
function FriendVo:setKey(key,value)
   self[key] = value
end
function FriendVo:__delete( ... )
	-- body
end