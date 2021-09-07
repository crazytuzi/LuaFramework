require("game/advance/fightmount/fightmounthuanhua/fight_mount_huan_hua_view")

FightMountHuanHuaCtrl = FightMountHuanHuaCtrl or BaseClass(BaseController)

function FightMountHuanHuaCtrl:__init()
	if FightMountHuanHuaCtrl.Instance then
		print_error("[FightMountHuanHuaCtrl] Attemp to create a singleton twice !")
		return
	end
	FightMountHuanHuaCtrl.Instance = self

	self.huan_hua_view = FightMountHuanHuaView.New(ViewName.FightMountHuanHua)

	self:RegisterAllProtocols()
end

function FightMountHuanHuaCtrl:__delete()
	if self.huan_hua_view ~= nil then
		self.huan_hua_view:DeleteMe()
		self.huan_hua_view = nil
	end
	FightMountHuanHuaCtrl.Instance = nil
end

function FightMountHuanHuaCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSFightMountSpecialImgUpgrade)
end

function FightMountHuanHuaCtrl:MountSpecialImaUpgrade(special_image_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSFightMountSpecialImgUpgrade)
	send_protocol.special_image_id = special_image_id
	send_protocol:EncodeAndSend()
end

function FightMountHuanHuaCtrl:FlushView(...)
	self.huan_hua_view:Flush(...)
end