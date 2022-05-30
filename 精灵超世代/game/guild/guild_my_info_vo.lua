-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      自己公会的基础信息
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildMyInfoVo = GuildMyInfoVo or BaseClass(EventDispatcher) 

function GuildMyInfoVo:__init()
	self.gid            = 0                 -- 公会的id
	self.gsrv_id        = ""                -- 公会的服务器id
	self.name           = ""                -- 公会的名字
	self.lev            = 0                 -- 等级
	self.members_num    = 0                 -- 成员人数
	self.members_max    = 0                 -- 成员上限
	self.leader_name    = 0                 -- 会长名字
    self.rid            = 0                 -- 会长角色id
    self.srv_id         = ""                -- 会长角色服务器id
    self.sign           = ""                -- 宣言
    self.exp            = 0                 -- 公会经验
    self.day_exp        = 0                 -- 今天公会经验
	self.apply_type     = 0                 -- 申请类型(0:自动审批 1:手动审批 2:不允许申请)
    self.apply_lev      = 0                 -- 申请等级条件
	self.apply_power    = 0                 -- 申请战力条件
    self.recruit_num    = 0                 -- 已招募次数
    self.rank_idx       = 0                 -- 排名
    self.vitality       = 0                 --公会活跃度
end

function GuildMyInfoVo:updateData(data)
	for k, v in pairs(data) do
		if type(v) ~= "table" then
			self:setGuildAttribute(k, v)
		end
	end
end

function GuildMyInfoVo:setGuildAttribute(key, value)	
	if self[key] ~= value then
		self[key] = value
		self:dispatchUpdateAttrByKey(key, value)
	end
end

function GuildMyInfoVo:dispatchUpdateAttrByKey(key, value)
	self:Fire(GuildEvent.UpdateMyInfoEvent, key, value)
end

function GuildMyInfoVo:__delete()
end 