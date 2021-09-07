require("game/honour/span_battle_view")
require("game/honour/span_battle_data")

SpanBattleCtrl = SpanBattleCtrl or  BaseClass(BaseController)

function SpanBattleCtrl:__init()
	if SpanBattleCtrl.Instance ~= nil then
		print_error("[SpanBattleCtrl] attempt to create singleton twice!")
		return
	end
	SpanBattleCtrl.Instance = self

	--self:RegisterAllProtocols()

	self.view = SpanBattleView.New(ViewName.SpanBattleView)
	self.data = SpanBattleData.New()

end

function SpanBattleCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.fb_view ~= nil then
		self.fb_view:DeleteMe()
		self.fb_view = nil
	end

	SpanBattleCtrl.Instance = nil
end

-- function SpanBattleCtrl:RegisterAllProtocols()
-- 	self:RegisterProtocol(SCHuanglingFBRoleInfo, "OnHuanglingFBRoleInfo")
-- end