require("game/treasure_bowl/treasure_bowl_view")
require("game/treasure_bowl/treasure_bowl_data")

TreasureBowlCtrl = TreasureBowlCtrl or BaseClass(BaseController)

function TreasureBowlCtrl:__init()
	if TreasureBowlCtrl.Instance then
		print_error("[TreasureBowlCtrl] Attemp to create a singleton twice !")
	end
	TreasureBowlCtrl.Instance = self
	self.data = TreasureBowlData.New()
	-- self.view = TreasureBowlView.New(ViewName.TreasureBowlView)
	-- self.activity_change = BindTool.Bind(self.ActivityChange, self)
	-- ActivityData.Instance:NotifyActChangeCallback(self.activity_change)
	self:RegisterAllProtocols()
end

function TreasureBowlCtrl:__delete()
	-- self.view:DeleteMe()
	if self.activity_change ~= nil then
		ActivityData.Instance:UnNotifyActChangeCallback(self.activity_change)
		self.activity_change = nil
	end

	self.data:DeleteMe()
	TreasureBowlCtrl.Instance = nil
end

function TreasureBowlCtrl:CloseView()
	-- self.view:Close()
end

function TreasureBowlCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRANewCornucopiaInfo, "OnTreasureBowlInfo")
end

function TreasureBowlCtrl:OnTreasureBowlInfo(protocol)
	self.data:OnTreasureBowlInfo(protocol)
	if self.auto_open then
		self.auto_open = false
		-- self.view:Open()
	-- else
		-- self.view:OnSeverInfoChange()
	end
end

function TreasureBowlCtrl:ActivityChange()
	self.auto_open = false
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_CORNUCOPIA, 0)
end