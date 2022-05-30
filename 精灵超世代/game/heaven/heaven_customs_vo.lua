--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-04-12 16:32:03
-- @description    : 
		-- 天界副本 关卡数据
---------------------------------
HeavenCustomsVo = HeavenCustomsVo or BaseClass(EventDispatcher)

function HeavenCustomsVo:__init(  )
	self.chapter_id = 0  -- 章节id
	self.id = 0 		 -- 关卡id
	self.state = 0 		 -- 是否可挑战(0不可挑战 1可挑战 2已通关)
	self.star = 0 		 -- 通关星数
	self.star_info = {}  -- 三星点亮状态
end

function HeavenCustomsVo:updateData( data )
	for key, value in pairs(data) do
        self[key] = value
    end
    self:dispatchUpdateAttrByKey()
end

function HeavenCustomsVo:dispatchUpdateAttrByKey()
    self:Fire(HeavenEvent.Update_Customs_Vo_Event) 
end

function HeavenCustomsVo:__delete(  )
	
end