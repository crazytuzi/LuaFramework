require("game/god_temple/god_temple_pata/god_temple_pata_data")

GodTemplePataCtrl = GodTemplePataCtrl or BaseClass(BaseController)

function GodTemplePataCtrl:__init()
	if GodTemplePataCtrl.Instance ~= nil then
		ErrorLog("[GodTemplePataCtrl] attempt to create singleton twice!")
		return
	end

	GodTemplePataCtrl.Instance = self

	self.data = GodTemplePataData.New()

	self:RegisterProtocols()
end

function GodTemplePataCtrl:__delete()
	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	GodTemplePataCtrl.Instance = nil
end

function GodTemplePataCtrl:RegisterProtocols()
	self:RegisterProtocol(CSPataFbNewAllInfo)
	self:RegisterProtocol(SCPataFbNewAllInfo, "OnPataFbNewAllInfo")
end

--请求爬塔副本信息
function GodTemplePataCtrl:ReqPataFbNewAllInfo()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSPataFbNewAllInfo)
	send_protocol:EncodeAndSend()
end

function GodTemplePataCtrl:OnPataFbNewAllInfo(protocol)
	self.data:SetInfo(protocol)
	if ViewManager.Instance:IsOpen(ViewName.GodTempleView) then
		ViewManager.Instance:FlushView(ViewName.GodTempleView, "pata")
	end
	--刷新变强红点
	RemindManager.Instance:Fire(RemindName.BeStrength)
	
	RemindManager.Instance:Fire(RemindName.GodTemple_PaTa)
end