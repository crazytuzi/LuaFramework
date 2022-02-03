-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildListVo = GuildListVo or BaseClass(EventDispatcher) 

function GuildListVo:__init()
    self.gid = 0
    self.gsrv_id = ""
    self.name = ""
    self.lev = 0
    self.members_num = 0
    self.members_max = 0
    self.leader_name = 0
    self.apply_type = 0
    self.apply_lev = 0
    self.is_apply = FALSE
end

function GuildListVo:updateData(data)
    for k, v in pairs(data) do
        if type(v) ~= "table" then
            self:setGuildAttribute(k, v)
        end
    end 
end

function GuildListVo:setGuildAttribute(key, value)    
	if self[key] ~= value then
		self[key] = value
		self:dispatchUpdateAttrByKey(key, value)
	end
end

function GuildListVo:dispatchUpdateAttrByKey(key, value)
    self:Fire(GuildEvent.UpdateGuildItemEvent, key, value) 
end

function GuildListVo:__delete()
end