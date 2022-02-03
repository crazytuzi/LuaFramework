--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-10-11 10:52:02
-- @description    : 
		-- 大富翁棋盘格子的数据结构
---------------------------------

MonopolyGridVo = MonopolyGridVo or BaseClass(EventDispatcher)

function MonopolyGridVo:__init(  )
	self.index = 0 -- 序列号（对应服务端发过来的pos）
	self.step_id = 0 -- 阶段id
	self.map_id = 0 -- 地图id
	self.grid_index = 0 -- 格子坐标点
	self.evt_type = MonopolyConst.Event_Type.Normal -- 格子事件
end

function MonopolyGridVo:updateData( data )
	for key, value in pairs(data) do
        self[key] = value
	end
	-- 资源id
	self.grid_res_id = "grid_1"
	local evt_map_data = Config.MonopolyMapsData.data_event_info[self.map_id]
	if evt_map_data and evt_map_data[self.evt_type] then
		self.res_data = evt_map_data[self.evt_type].res_id or {}
		self.grid_res_id = evt_map_data[self.evt_type].grid_res_id
		self.offset = evt_map_data[self.evt_type].offset or {}
		self.show_ani = evt_map_data[self.evt_type].show_ani or 0
	end
end

function MonopolyGridVo:__delete(  )
	
end