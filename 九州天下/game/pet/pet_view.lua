require("game/pet/pet_achieve_view")
require("game/pet/pet_forge_view")
require("game/pet/pet_park_view")
PetView = PetView or BaseClass(BaseView)

function PetView:__init()
	self.ui_config = {"uis/views/pet","PetView"}
	self.full_screen = false
	self.play_audio = true
end

function PetView:__delete()
end

function PetView:LoadCallBack()
	self.pet_achieve_view 		= PetAchieveView.New(self:FindObj("pet_achieve_view"))
	self.pet_forge_view 		= PetForgeView.New(self:FindObj("pet_forge_view"))
	self.pet_park_view 			= PetParkView.New(self:FindObj("pet_park_view"))
	self.gold 					= self:FindVariable("gold")
	self.bind_gold 				= self:FindVariable("bind_gold")
	self.park_red_point 		= self:FindVariable("park_red_point")
	self.achieve_red_point 		= self:FindVariable("achieve_red_point")
	self.forge_red_point 		= self:FindVariable("forge_red_point")
	self.toggle_list = {}
	for i=1,3 do
		self.toggle_list[i] = self:FindObj("toggle_"..i)
		self:ListenEvent("toggle_" .. i, BindTool.Bind2(self.OnToggleClick, self, i))
	end

	self:ListenEvent("close_view", BindTool.Bind(self.OnCloseBtnClick, self))
	self:ListenEvent( "AddGold", BindTool.Bind(self.HandleAddGold, self))

	GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.ShowOrHideTab, self))
end

function PetView:OpenCallBack()
	self:ShowOrHideTab()
	self.show_index = 1
	self.toggle_list[1].toggle.isOn = true

	self.data_listen = BindTool.Bind(self.PlayerDataChangeCallback, self)
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	self.pet_park_view:OpenCallback()
	self:SetRedPoint()
end

function PetView:SetRedPoint()
	self.park_red_point:SetValue(PetData.Instance:GetExchangeRedPointStatus())
	self.forge_red_point:SetValue(false)
	self.achieve_red_point:SetValue(PetData.Instance:GetFreeRewardRedPointStatus())
end

function PetView:PlayerDataChangeCallback(attr_name, value)
	if not value then
		return
	end
	if attr_name == "gold" then
		local count = value
		count = self:ChangeNum(count)
		self.gold:SetValue(count)
	end
	if attr_name == "bind_gold" then
		local count = value
		count = self:ChangeNum(count)
		self.bind_gold:SetValue(count)
	end
end

function PetView:ChangeNum(count)
	if count > 99999 and count <= 99999999 then
		count = count / 10000
		count = math.floor(count)
		count = count .. "万"
	elseif count > 99999999 then
		count = count / 100000000
		count = math.floor(count)
		count = count .. "亿"
	end
	return count
end

function PetView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function PetView:ShowOrHideTab()
	local show_list = {}
	local open_fun_data = OpenFunData.Instance
	show_list[1] = open_fun_data:CheckIsHide("pet_park")
	show_list[2] = open_fun_data:CheckIsHide("pet_forge")
	show_list[3] = open_fun_data:CheckIsHide("pet_achieve")
	for k,v in pairs(show_list) do
		self.toggle_list[k]:SetActive(v)
	end
end

function PetView:OnCloseBtnClick()
	self:Close()
	self.pet_park_view:CancelPetMoveTimer()
	GlobalEventSystem:Fire(MainUIEventType.CHANGE_RED_POINT,MainUIData.RemindingName.Pet,PetData.Instance:GetRedPointStatus())
end

function PetView:CloseCallBack()
	if self.data_listen then
		PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
		self.data_listen = nil
	end
end

function PetView:OnToggleClick(i,is_click)
	if is_click then
		self:SetRedPoint()
		if i == 1 then
			self.pet_park_view:CancelPetMoveTimer()
			self.pet_park_view:OpenCallback()
			if self.show_index ~= 1 then
				self.pet_park_view:GoMyPark()
			end
		elseif i == 3 then
			self.pet_achieve_view:FlushModel()
			self.pet_achieve_view:OpenFreeTimer()
		elseif i == 2 then
			self.pet_forge_view:Reload()
		end
		self.show_index = i
	end
end

function PetView:ReleaseCallBack()
	UnityEngine.PlayerPrefs.DeleteKey("pet_feed")
end

function PetView:ShowIndexCallBack(index)
	if index == TabIndex.pet_park then
		self.toggle_list[1].toggle.isOn = true
		self.show_index = 1
	elseif index == TabIndex.pet_forge then
		self.toggle_list[2].toggle.isOn = true
		self.show_index = 2
		self.pet_forge_view:Reload()
	elseif index == TabIndex.pet_achieve then
		self.toggle_list[3].toggle.isOn = true
		self.show_index = 3
	end
end

