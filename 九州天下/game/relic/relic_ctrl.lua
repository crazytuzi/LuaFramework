require("game/relic/relic_data")
require("game/relic/relic_view")

RelicCtrl = RelicCtrl or BaseClass(BaseController)

function RelicCtrl:__init()
	if RelicCtrl.Instance ~= nil then
		print_error("[RelicCtrl] attempt to create singleton twice!")
		return
	end
	RelicCtrl.Instance = self
	self.view = RelicView.New()
	self.data = RelicData.New()
	self:RegisterAllProtocols()
end

function RelicCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	RelicCtrl.Instance = nil
end

function RelicCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCXingzuoYijiChangeBoxAndBoss, "OnXingzuoYijiInfo")
end

function RelicCtrl:OnXingzuoYijiInfo(protocol)
	self.data:SetXingzuoYijiInfo(protocol)
	self.view:Flush()
end

function RelicCtrl:OpenInfoView()
	self.view:Open()
end

function RelicCtrl:CloseInfoView()
	self.view:Close()
end