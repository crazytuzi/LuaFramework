require("game/serveractivity/treasure_businessman/treasure_businessman_data")
require("game/serveractivity/treasure_businessman/treasure_businessman_view")
TreasureBusinessmanCtrl = TreasureBusinessmanCtrl or BaseClass(BaseController)

function TreasureBusinessmanCtrl:__init()
	if TreasureBusinessmanCtrl.Instance then
		print_error("[TreasureBusinessmanCtrl] Attemp to create a singleton twice !")
	end
	TreasureBusinessmanCtrl.Instance = self
	self.data = TreasureBusinessmanData.New()
	self.view = TreasureBusinessmanView.New(ViewName.TreasureBusinessmanView)
	self:RegisterAllProtocols()
end

function TreasureBusinessmanCtrl:__delete()

	self.view:DeleteMe()

	self.data:DeleteMe()

	TreasureBusinessmanCtrl.Instance = nil
end

function TreasureBusinessmanCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAZhenbaoge2Info, "OnRAZhenbaoge2Info")			 --珍宝阁
	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
end

-- 主界面创建
function TreasureBusinessmanCtrl:MainuiOpenCreate()
	local is_open = ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_BUSINESSMAN)
	if is_open then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_BUSINESSMAN, RA_ZHENBAOGE_OPERA_TYPE.RA_ZHENBAOGE_OPERA_TYPE_QUERY_INFO)
	end
end

function TreasureBusinessmanCtrl:OnRAZhenbaoge2Info(protocol)
	self.data:SetRATreasureLoft(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	self.data:FlushHallRedPoindRemind()
	RemindManager.Instance:Fire(RemindName.ZhenBaoge2)
end