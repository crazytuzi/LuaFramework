-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      公会成员信息
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildMemberVo = GuildMemberVo or BaseClass(EventDispatcher)

function GuildMemberVo:__init()
	self.rid			= 0                 -- id
	self.srv_id			= ""                -- 服务器id
	self.name			= ""                -- 名字
	self.lev			= 0                 -- 等级
	self.face 			= 0					-- 头像
	self.post 			= 0					-- 职位
	self.online 		= 0					-- 0:不在线 1:在线
	self.vip_lev 		= 0					-- vip等级
	self.power 			= 0					-- 战力
	self.join_time 		= 0					-- 入会时间
	self.login_time 	= 0					-- 最后在线时间
	self.donate 		= 0					-- 贡献
	self.day_donate 	= 0					-- 今日贡献
	self.avatar_bid 	= 0					-- 头像框
	self.sex 			= 0					-- 性别
	self.day_dun_time   = 0 				-- 公会副本剩余购买次数
    self.day_war_time   = 0 				-- 公会战剩余挑战次数

	-- self.is_self		= false								-- 初始化的时候做的控制，外部设置，不是协议数据的
	self.role_post		= GuildConst.post_type.member		-- 当前玩家的职位，而不是该条数据的职位，也是外部设置
end

function GuildMemberVo:updateData(data)
	for k, v in pairs(data) do
		if type(v) ~= "table" then
			self:setGuildAttribute(k, v)
		end
	end
end

function GuildMemberVo:setGuildAttribute(key, value)	
	if self[key] ~= value then
		self[key] = value
		self:dispatchUpdateAttrByKey(key, value)
	end

	-- 用于排序使用
	if key == "post" then
		self.post_sort = 99 - value
	end
end

function GuildMemberVo:dispatchUpdateAttrByKey(key, value)
	self:Fire(GuildEvent.UpdateMyMemberItemEvent, key, value)
end

function GuildMemberVo:__delete()
end 