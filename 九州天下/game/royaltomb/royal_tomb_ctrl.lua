require("game/royaltomb/royal_tomb_view")
require("game/royaltomb/royal_tomb_data")
require("game/royaltomb/royal_tomb_fb_view")

RoyalTombCtrl = RoyalTombCtrl or  BaseClass(BaseController)

function RoyalTombCtrl:__init()
	if RoyalTombCtrl.Instance ~= nil then
		print_error("[RoyalTombCtrl] attempt to create singleton twice!")
		return
	end
	RoyalTombCtrl.Instance = self

	self:RegisterAllProtocols()

	self.view = RoyalTombView.New(ViewName.RoyalTombView)
	self.fb_view = RoyalTombFbView.New(ViewName.RoyalTombFbView)
	self.data = RoyTombData.New()

end

function RoyalTombCtrl:__delete()
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

	RoyalTombCtrl.Instance = nil
end

function RoyalTombCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCHuanglingFBRoleInfo, "OnHuanglingFBRoleInfo")
end

function RoyalTombCtrl:OnHuanglingFBRoleInfo(protocol)
	self.data:SetHuanglingFBRoleInfo(protocol)

	if self.view and self.view:IsOpen() then
		self.view:Flush()
	end
	if self.fb_view and self.fb_view:IsOpen() then
		self.fb_view:Flush()
	end
end

function RoyalTombCtrl:FlushFBView()
	if self.fb_view and self.fb_view:IsOpen() then
		self.fb_view:Flush()
	end	
end