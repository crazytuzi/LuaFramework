require("game/player/forge/player_forge_data")

--------------------------------------------------------------
--技能相关
--------------------------------------------------------------
PlayerForgeCtrl = PlayerForgeCtrl or BaseClass(BaseController)
function PlayerForgeCtrl:__init()
	if PlayerForgeCtrl.Instance then
		print_error("[PlayerForgeCtrl] Attemp to create a singleton twice !")
	end
	PlayerForgeCtrl.Instance = self

	self.forge_data = PlayerForgeData.New()

	self:RegisterAllProtocols()
end

function PlayerForgeCtrl:__delete()
	PlayerForgeCtrl.Instance = nil

	self.forge_data:DeleteMe()
	self.forge_data = nil
end

function PlayerForgeCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCSendRongluInfo, "OnSCSendRongluInfo")
	self:RegisterProtocol(SCRongluResultInfo, "OnRongluResultInfo")

	self:RegisterProtocol(CSGetRongluInfo)
	self:RegisterProtocol(CSRonglianReq)
end

-- 熔炉信息
function PlayerForgeCtrl:OnSCSendRongluInfo(protocol)
	self.forge_data:SetRongluInfo(protocol.ronglu_info)
	PlayerCtrl.Instance:FlushPlayerView()
end

-- 熔炉获得经验
function PlayerForgeCtrl:OnRongluResultInfo(protocol)
	local info = {}
	info.change_type = protocol.change_type
	info.delta = protocol.delta
	PlayerCtrl.Instance:FlushPlayerView("forge_exp", info)
	RemindManager.Instance:Fire(RemindName.PlayerForge)

end

-- 熔炉信息请求
function PlayerForgeCtrl:SendRongluInfo()
	local cmd = ProtocolPool.Instance:GetProtocol(CSGetRongluInfo)
	cmd:EncodeAndSend()
end

-- 熔炉装备请求
function PlayerForgeCtrl:SendRonglianReq(equip_count, equip_list)
	local cmd = ProtocolPool.Instance:GetProtocol(CSRonglianReq)
	cmd.equip_count = equip_count
	cmd.equip_list = equip_list
	cmd:EncodeAndSend()
end

function PlayerForgeCtrl:SetItemList(data)
	self.forge_data:SetItemListData(data)
	PlayerCtrl.Instance:FlushPlayerView("forge_item")
end