
--===============================下发===================================
-- 传送员对话框
SCTransmitNpcDialog = SCTransmitNpcDialog or BaseClass(BaseProtocolStruct)
function SCTransmitNpcDialog:__init()
	self:InitMsgType(146, 1)
	self.obj_id = 0
	self.area_count = 0
	self.area_list = {}
end

function SCTransmitNpcDialog:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	self.area_count = MsgAdapter.ReadUChar()
	self.area_list = {}

	for i = 1, self.area_count do
		local area_info = {
			title = MsgAdapter.ReadStr(),
			btn_count = MsgAdapter.ReadUChar(),
			btn_list = {},
		}

		for k = 1, area_info.btn_count do
			table.insert(area_info.btn_list, {
					type = MsgAdapter.ReadUChar(),
					scene_id = MsgAdapter.ReadInt(),
					btn_name = MsgAdapter.ReadStr(),
					func_name = MsgAdapter.ReadStr(),
					level = MsgAdapter.ReadUShort(),
					circle = MsgAdapter.ReadUChar(),
				})
		end

		table.insert(self.area_list, area_info)
	end
end

-- 特殊npc对话框
SCSpecialNpcDialog = SCSpecialNpcDialog or BaseClass(BaseProtocolStruct)
function SCSpecialNpcDialog:__init()
	self:InitMsgType(146, 2)
	self.obj_id = 0
	self.dialog_type = 0
	self.cond = ""
	self.bottom = ""
	self.btn_list = ""
	self.money_type = 0
	self.param = 0
end

function SCSpecialNpcDialog:Decode()
	self.obj_id = MsgAdapter.ReadLL()
	self.dialog_type = MsgAdapter.ReadUChar()
	if self.dialog_type ~= NPC_DIALOG_TYPE.DRFB_NPCDLG then
		self.cond = MsgAdapter.ReadStr()
		self.bottom = MsgAdapter.ReadStr()
		self.btn_list = MsgAdapter.ReadStr()
		self.money_type = MsgAdapter.ReadChar()
		self.param = MsgAdapter.ReadUChar()
	end
end
