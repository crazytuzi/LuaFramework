require ("game/ancient_relics/ancient_relics_data")
require ("game/ancient_relics/ancient_relics_view")

AncientRelicsCtrl = AncientRelicsCtrl or BaseClass(BaseController)

function AncientRelicsCtrl:__init()
	if 	AncientRelicsCtrl.Instance ~= nil then
		print_error("[AncientRelicsCtrl] attempt to create singleton twice!")
		return
	end
	AncientRelicsCtrl.Instance = self
	self.view = AncientRelicsView.New(ViewName.AncientRelics)
	self.data = AncientRelicsData.New()

	self:RegisterAllProtocols()
end

function AncientRelicsCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end
	AncientRelicsCtrl.Instance = nil
end

function AncientRelicsCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCShenzhouWeapondGatherInfo, "OnShenzhouWeapondGatherInfo")
end

function AncientRelicsCtrl:OnShenzhouWeapondGatherInfo(protocol)
	self.data:SetInfo(protocol)
	self.view:Flush()
	HunQiCtrl.Instance:FlushHunQiTimes()
end