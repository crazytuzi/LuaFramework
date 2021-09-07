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
	self.miji_compose_view:DeleteMe()
	self.miji_compose_data:DeleteMe()
	self.miji_select_view:DeleteMe()

	MiJiComposeCtrl.Instance = nil
end

function MiJiComposeCtrl:ShowSelectView(call_back, data_list, from_view)
	self.miji_select_view:SetSelectCallBack(call_back)
	self.miji_select_view:SetHadSelectData(data_list)
	self.miji_select_view:SetFromView(from_view)

	self.miji_select_view:Open()
end
