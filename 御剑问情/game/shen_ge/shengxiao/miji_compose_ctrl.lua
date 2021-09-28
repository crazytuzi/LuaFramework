require("game/shen_ge/shengxiao/miji_compose_view")
require("game/shen_ge/shengxiao/miji_select_view")
require("game/shen_ge/shengxiao/miji_compose_data")

MiJiComposeCtrl = MiJiComposeCtrl or BaseClass(BaseController)

function  MiJiComposeCtrl:__init()
	if nil ~= MiJiComposeCtrl.Instance then
		print_error("[MiJiComposeCtrl] Attemp to create a singleton twice !")
		return
	end
	MiJiComposeCtrl.Instance = self

	self.miji_compose_view = MiJiComposeView.New(ViewName.MiJiComposeView)
	self.miji_compose_data = MiJiComposeData.New()
	self.miji_select_view = MiJiSelectView.New(ViewName.MiJiSelectView)

end

function MiJiComposeCtrl:__delete()
	self.miji_compose_data:DeleteMe()
	MiJiComposeCtrl.Instance = nil

	self.miji_select_view:DeleteMe()
	self.miji_select_view = nil

	self.miji_compose_view:DeleteMe()
	self.miji_compose_view = nil
end

function MiJiComposeCtrl:ShowSelectView(call_back, data_list, from_view)
	self.miji_select_view:SetSelectCallBack(call_back)
	self.miji_select_view:SetHadSelectData(data_list)
	self.miji_select_view:SetFromView(from_view)

	self.miji_select_view:Open()
end

-- -- 神格操作请求
-- function MiJiComposeCtrl:SendShenGeSystemReq(info_type, param1, param2, param3, count, virtual_inde_list)
-- 	local send_protocol = ProtocolPool.Instance:GetProtocol(CSShengeSystemReq)
-- 	send_protocol.info_type = info_type or 0
-- 	send_protocol.param1 = param1 or 0
-- 	send_protocol.param2 = param2 or 0
-- 	send_protocol.param3 = param3 or 0

-- 	send_protocol.count = count or 0
-- 	send_protocol.virtual_inde_list = virtual_inde_list or {}

-- 	send_protocol:EncodeAndSend()
-- end

