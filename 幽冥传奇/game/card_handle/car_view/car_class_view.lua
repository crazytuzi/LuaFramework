local CarClassView = BaseClass(SubView)

function CarClassView:__init()
	self.texture_path_list = {
		'res/xui/boss.png',
	}
    self.config_tab = {
		{"card_handlebook_ui_cfg", 1, {0}},
	}

	self.btn_info = {
		ViewDef.CardHandlebook.CardView.DaibuCar,
		ViewDef.CardHandlebook.CardView.PrivateCar,
		ViewDef.CardHandlebook.CardView.SeniorCar,
		ViewDef.CardHandlebook.CardView.LuxuryCar,
		ViewDef.CardHandlebook.CardView.KuCar,
		ViewDef.CardHandlebook.CardView.AssembleCar,
		ViewDef.CardHandlebook.CardView.PersonalityCar,
	}

	require("scripts/game/card_handle/car_view/card_handle_view").New(ViewDef.CardHandlebook.CardView.DaibuCar, self)
	require("scripts/game/card_handle/car_view/card_handle_view").New(ViewDef.CardHandlebook.CardView.PrivateCar, self)
	require("scripts/game/card_handle/car_view/card_handle_view").New(ViewDef.CardHandlebook.CardView.SeniorCar, self)
	require("scripts/game/card_handle/car_view/card_handle_view").New(ViewDef.CardHandlebook.CardView.LuxuryCar, self)
	require("scripts/game/card_handle/car_view/card_handle_view").New(ViewDef.CardHandlebook.CardView.KuCar, self)
	require("scripts/game/card_handle/car_view/card_handle_view").New(ViewDef.CardHandlebook.CardView.AssembleCar, self)
	require("scripts/game/card_handle/car_view/card_handle_view").New(ViewDef.CardHandlebook.CardView.PersonalityCar, self)

end

function CarClassView:__delete()
end

function CarClassView:ReleaseCallBack()
	if self.car_class_tabbar then
		self.car_class_tabbar:DeleteMe()
		self.car_class_tabbar = nil
	end
end

function CarClassView:LoadCallBack(index, loaded_times)

	if self.car_class_tabbar then return end

	local name_list = {}
	for k, v in pairs(self.btn_info) do
		name_list[#name_list + 1] = v.name
	end
	self.car_class_tabbar = Tabbar.New()
	-- self.car_class_tabbar:SetTabbtnTxtOffset(-10, 0)
	self.car_class_tabbar:CreateWithNameList(self.node_t_list.layout_bottom_btn_list.node, 10, 502, function (index)
		ViewManager.Instance:OpenViewByDef(self.btn_info[index])
	end, name_list, false, ResPath.GetCommon("toggle_121"))
	
	self:CarClassRemindTabbar()

	EventProxy.New(CardHandlebookData.Instance, self):AddEventListener(CardHandlebookData.UPDATE_CARD_INFO, BindTool.Bind(self.CarClassRemindTabbar, self))
end

function CarClassView:CloseCallBack()
	
end

function CarClassView:ShowIndexCallBack()
	for k, v in pairs(self.btn_info) do
		if ViewManager.Instance:IsOpen(v) then
			self.car_class_tabbar:ChangeToIndex(k)
			return
		end
	end
end

function CarClassView:OnFlush(param_t)
	
end

-- 标签栏提醒
function CarClassView:CarClassRemindTabbar()
	self.car_class_tabbar:SetRemindByIndex(1, CardHandlebookData.Instance:GetIsRemindByIndex(1))
	self.car_class_tabbar:SetRemindByIndex(2, CardHandlebookData.Instance:GetIsRemindByIndex(2))
	self.car_class_tabbar:SetRemindByIndex(3, CardHandlebookData.Instance:GetIsRemindByIndex(3))
	self.car_class_tabbar:SetRemindByIndex(4, CardHandlebookData.Instance:GetIsRemindByIndex(4))
	self.car_class_tabbar:SetRemindByIndex(5, CardHandlebookData.Instance:GetIsRemindByIndex(5))
	self.car_class_tabbar:SetRemindByIndex(6, CardHandlebookData.Instance:GetIsRemindByIndex(6))
	self.car_class_tabbar:SetRemindByIndex(7, CardHandlebookData.Instance:GetIsRemindByIndex(7))
end


return CarClassView