--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-08-14 16:30:39
-- @description    : 
		-- 精灵孵化器数据结构
---------------------------------

ElfinHatchVo = ElfinHatchVo or BaseClass(EventDispatcher)

function ElfinHatchVo:__init(  )
	self.id = 0 		-- 孵化器id
	self.state = ElfinConst.Hatch_Status.Open -- 孵化器状态
	self.is_open = 0 	-- 激活状态（0未激活 1已激活）
	self.lev = 0 		-- 等级
	self.do_id = 0 		-- 灵蛋id
	self.need_point = 0 -- 本次孵化所需总孵化点
	self.do_point = 0   -- 已经孵化的孵化点
	self.all_end_time = 0   -- 当前孵化点孵化结束的时间戳
	self.sort = 0   -- 排序
end

function ElfinHatchVo:updateData( data )
	for key, value in pairs(data) do
        self[key] = value
    end
    self:dispatchUpdateAttrByKey()
end

function ElfinHatchVo:dispatchUpdateAttrByKey()
    self:Fire(ElfinEvent.Update_Elfin_Hatch_Vo_Event, self.id) 
end

function ElfinHatchVo:__delete(  )
	
end