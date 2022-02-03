-- ----------------------------------------
-- @Author: zj@qqg.com
-- @Date:   2019-06-04 10:58:08
-- @Description:   公会日志信息
-- --------------------------------------------------------------------
GuildNoticeVo = GuildNoticeVo or BaseClass(EventDispatcher) 

function GuildNoticeVo:__init()
	self.id 			= 0 				-- 日志ID
	self.gid            = 0                 -- 公会的id
	self.gsrv_id        = ""                -- 公会的服务器id
	self.type 			= 0 				-- 日志类型(1:工会战 2：公会捐献 3：公会副本 4：其他)
	self.time 			= 0 				-- 日志记录时间
    self.rid            = 0                 -- 会长角色id
    self.srv_id         = ""                -- 会长角色服务器id
    self.role_name  	= ""				-- 日志记录玩家名
    self.msg            = ""                -- 日志内容
end

function GuildNoticeVo:updateData(data)
	for k, v in pairs(data) do
		if type(v) ~= "table" then
			self:setGuildAttribute(k, v)
		end
	end
end

function GuildNoticeVo:setGuildAttribute(key, value)	
	if self[key] ~= value then
		self[key] = value
	end
end

function GuildNoticeVo:__delete()
end 