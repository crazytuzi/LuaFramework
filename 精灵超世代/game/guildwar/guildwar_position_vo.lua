--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2018-10-18 15:08:19
-- @description    : 
		-- 联盟战据点数据
---------------------------------

GuildWarPositionVo = GuildWarPositionVo or BaseClass(EventDispatcher)

function GuildWarPositionVo:__init(  )
	self.pos = 0      -- 序列号（唯一标识）
	self.rid = 0
	self.srv_id = 0
	self.name = ""
	self.lev = 0
	self.face = 0
	self.power = 0
	self.hp = 0
	self.hp_max = 0
	self.relic_def_count = 0 -- 废墟状态被进攻次数
	self.status = GuildwarConst.position_status.normal
end

function GuildWarPositionVo:updateData( data )
	for key, value in pairs(data) do
        self[key] = value
    end 
    self:dispatchUpdateAttrByKey()
end

function GuildWarPositionVo:dispatchUpdateAttrByKey()
    self:Fire(GuildwarEvent.UpdateGuildWarPositionDataEvent) 
end

function GuildWarPositionVo:__delete(  )
	
end