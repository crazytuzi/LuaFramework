--===================================请求==================================

-- 请求配置的物品信息
CSItemConfigReq = CSItemConfigReq or BaseClass(BaseProtocolStruct)
function CSItemConfigReq:__init()
	self:InitMsgType(65, 1)
	self.count = 0
	self.item_list = {}
end

function CSItemConfigReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.count)
	for i,v in ipairs(self.item_list) do
		MsgAdapter.WriteUShort(v)
	end
end

-- 请求场景NPC列表
CSNpcConfigReq = CSNpcConfigReq or BaseClass(BaseProtocolStruct)
function CSNpcConfigReq:__init()
	self:InitMsgType(65, 3)
	self.scene_id = 0
end

function CSNpcConfigReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteInt(self.scene_id)
end

-- 获取场景区域信息
CSSceneAreaInfoReq = CSSceneAreaInfoReq or BaseClass(BaseProtocolStruct)
function CSSceneAreaInfoReq:__init()
	self:InitMsgType(65, 4)
	self.scene_id = 0
end

function CSSceneAreaInfoReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteInt(self.scene_id)
end

--===================================下发==================================

-- 返回配置的物品信息
SCItemConfig = SCItemConfig or BaseClass(BaseProtocolStruct)
function SCItemConfig:__init()
	self:InitMsgType(65, 1)
	self.count = 0
	self.item_list = {}
end

function SCItemConfig:Decode()
	self.count = MsgAdapter.ReadUChar()
	self.item_list = {}
	for i = 1, self.count do
		local vo = CommonStruct.ItemConfig()
		vo.item_id = MsgAdapter.ReadUShort()
		vo.name = MsgAdapter.ReadStr()
		vo.desc = MsgAdapter.ReadStr()
		vo.color = MsgAdapter.ReadUInt()
		vo.type = MsgAdapter.ReadUChar()
		vo.icon = MsgAdapter.ReadUShort()
		vo.shape = MsgAdapter.ReadUShort()
		vo.dura = MsgAdapter.ReadUInt()
		vo.useDurDrop = MsgAdapter.ReadUInt()
		vo.dup = MsgAdapter.ReadUShort()		
		vo.dealType = MsgAdapter.ReadUChar()
		vo.dealPrice = MsgAdapter.ReadInt()
		vo.time = MsgAdapter.ReadUInt()
		vo.suitId = MsgAdapter.ReadUChar()
		vo.colGroup = MsgAdapter.ReadUChar()		
		vo.cdTime = MsgAdapter.ReadInt()
		vo.dropBroadcast = MsgAdapter.ReadInt()
		vo.useType = MsgAdapter.ReadUChar()
		vo.sellBuyType = MsgAdapter.ReadUChar()
		vo.contri = MsgAdapter.ReadUShort()
		vo.flyType = MsgAdapter.ReadUChar()
		vo.openUi = MsgAdapter.ReadUShort()
		vo.effectId = MsgAdapter.ReadUShort()
		local attr_count = MsgAdapter.ReadUChar()
		vo.staitcAttrs = {}
		for i1 = 1, attr_count do
		 	local v = {}
		 	v.type = MsgAdapter.ReadUChar()
		 	v.value = CommonReader.ReadObjBuffAttr(v.type)
		 	if v.value > 0 then
		 		vo.staitcAttrs[i1] = v
		 	end
		end 
		local conds_count = MsgAdapter.ReadUChar()
		vo.conds = {}
		for i1 = 1, conds_count do
		 	local v = {}
		 	v.cond = MsgAdapter.ReadUChar()
		 	v.value = MsgAdapter.ReadInt()
		 	vo.conds[i1] = v
		end
		local flags = bit:d2b(MsgAdapter.ReadLL(), true)
		vo.flags = {}
		for i = #flags, 1, -1 do
			if flags[i] == 1 and ITEM_FLAG[64 - i] then
		 		vo.flags[ITEM_FLAG[64 - i]] = true
		 	end
		end
		vo.batchStatus = MsgAdapter.ReadUChar()
		self.item_list[i] = vo
	end
end

-- 传送门信息
SCDoorConfig = SCDoorConfig or BaseClass(BaseProtocolStruct)
function SCDoorConfig:__init()
	self:InitMsgType(65, 2)
	self.door_scene_count = 0
	self.door_scene_list = {}
end

function SCDoorConfig:Decode()
	self.door_scene_list = {}
	self.door_scene_count = MsgAdapter.ReadUShort()
	for i = 1, self.door_scene_count do
		local scene = {
			scene_id = MsgAdapter.ReadInt(),
			scene_name = MsgAdapter.ReadStr(),
			door_count = MsgAdapter.ReadUChar(),
			door_list = {},
		}
		for k = 1, scene.door_count do
			local door = {
				x = MsgAdapter.ReadUShort(),
				y = MsgAdapter.ReadUShort(),
				to_scene_id = MsgAdapter.ReadInt(),
				to_scene_name = MsgAdapter.ReadStr(),
				to_x = MsgAdapter.ReadUShort(),
				to_y = MsgAdapter.ReadUShort(),
			}
			table.insert(scene.door_list, door)
		end

		self.door_scene_list[scene.scene_id] = scene
	end
end

-- NPC信息
SCNpcConfig = SCNpcConfig or BaseClass(BaseProtocolStruct)
function SCNpcConfig:__init()
	self:InitMsgType(65, 3)
	self.scene_id = 0
	self.npc_count = 0
	self.npc_list = {}
end

function SCNpcConfig:Decode()
	self.scene_id = MsgAdapter.ReadInt()
	self.npc_count = MsgAdapter.ReadUShort()
	self.npc_list = {}

	for i = 1, self.npc_count do
		table.insert(self.npc_list, {
				npc_id = MsgAdapter.ReadInt(),
				name = MsgAdapter.ReadStr(),
				x = MsgAdapter.ReadInt(),
				y = MsgAdapter.ReadInt(),
			})
	end
end

-- 获取场景区域信息
SCSceneAreaInfo = SCSceneAreaInfo or BaseClass(BaseProtocolStruct)
function SCSceneAreaInfo:__init()
	self:InitMsgType(65, 4)
	self.scene_id = 0
	self.area_count = 0
	self.area_list = {}
end

function SCSceneAreaInfo:Decode()
	self.scene_id = MsgAdapter.ReadInt()
	self.area_count = MsgAdapter.ReadUShort()
	self.area_list = {}

	for i = 1, self.area_count do
		local area_name = MsgAdapter.ReadStr()
		local point_num = MsgAdapter.ReadUShort()
		local point_list = {}
		for i=1, point_num do
			point_list[i] = {
				x = MsgAdapter.ReadUShort(),
				y = MsgAdapter.ReadUShort(),
			}
		end
		local center_x = MsgAdapter.ReadUShort()
		local center_y = MsgAdapter.ReadUShort()

		table.insert(self.area_list, {
				area_name = area_name,
				point_list = point_list,
				center_x = center_x,
				center_y = center_y,
			})
	end
end
