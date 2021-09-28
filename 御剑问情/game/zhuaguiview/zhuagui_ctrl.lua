require("game/zhuaguiview/zhuagui_data")
require("game/zhuaguiview/zhuagui_view")

ZhuaGuiCtrl = ZhuaGuiCtrl or BaseClass(BaseController)

function ZhuaGuiCtrl:__init()
	if ZhuaGuiCtrl.Instance then
		print_error("[ZhuaGuiCtrl]:Attempt to create singleton twice!")
	end
	ZhuaGuiCtrl.Instance = self

	-- self.view = ZhuaGuiView.New()
	self.data = ZhuaGuiData.New()

	self:RegisterAllProtocols()
end

function ZhuaGuiCtrl:__delete()
	-- self.view:DeleteMe()
	-- self.view = nil

	self.data:DeleteMe()
	self.data = nil

	ZhuaGuiCtrl.Instance = nil
end

function ZhuaGuiCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCZhuaGuiFbInfo, "OnZhuaGuiFbInfo")
	self:RegisterProtocol(SCZhuaGuiRoleInfo, "OnZhuaGuiRoleInfo")
	self:RegisterProtocol(SCZhuaguiAddPerInfo, "OnSCZhuaguiAddPerInfo")
end

function ZhuaGuiCtrl:OnZhuaGuiFbInfo(protocol)
	self.data:SetZhuaGuiFBInfo(protocol)
	-- if self.view:IsOpen() then
	-- 	self.view:Flush()
	-- end
end

function ZhuaGuiCtrl:OnZhuaGuiRoleInfo(protocol)
	self.data:SetCurDayZhuaGuiInfo(protocol)
end

function ZhuaGuiCtrl:OnSCZhuaguiAddPerInfo(protocol)
	self.data:SetZhuaguiAddPerInfo(protocol)
end

function ZhuaGuiCtrl:ShowZhuaGuiView()
	-- self.view:Open()
	-- self.view:Flush()
end

function ZhuaGuiCtrl:CloseZhuaGuiView()
	-- self.view:Close()
end