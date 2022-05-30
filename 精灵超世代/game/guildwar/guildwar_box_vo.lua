--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-01-22 14:58:48
-- @description    : 
		-- 奖励宝箱的数据
---------------------------------

GuildWarBoxVo = GuildWarBoxVo or BaseClass(EventDispatcher)

function GuildWarBoxVo:__init(  )
	self.order = 0 	   -- 序号
	self.rid = 0 	   -- 开启者id
	self.sid = 0 	   -- 开启者sid
	self.name = ""     -- 开启者名称
	self.item_id = 0   -- 奖励物品bid
	self.item_num = 0  -- 奖励物品数量
	self.status = GuildwarConst.box_type.gold  -- 宝箱类型
end

function GuildWarBoxVo:updateData( data )
	for key, value in pairs(data) do
        self[key] = value
    end 
    self:dispatchUpdateAttrByKey()
end

function GuildWarBoxVo:dispatchUpdateAttrByKey()
    self:Fire(GuildwarEvent.UpdateSingleBoxDataEvent) 
end

function GuildWarBoxVo:__delete(  )
	
end