require("game/magic_weapon/magic_content_view")
require("game/magic_weapon/identify_content_view")
MagicWeaponView = MagicWeaponView or BaseClass(BaseView)

function MagicWeaponView:__init()
	self.ui_config = {"uis/views/magicweaponview","MagicWeaponView"}
	self.full_screen = true
	self.play_audio = true
end

function MagicWeaponView:__delete()
	if self.global_event ~= nil then
		GlobalEventSystem:UnBind(self.global_event)
		self.global_event = nil
	end
end

function MagicWeaponView:LoadCallBack()

	self.magic_content_view 	= MagicContentView.New( self:FindObj("magic_content_view"))
	self.identify_content_view 	= IdentifyContentView.New( self:FindObj("identify_content_view"))

	self.gold 					= self:FindVariable("Gold")
	self.bind_gold 				= self:FindVariable("bind_gold")
	self.show_magic_view 		= self:FindVariable("show_magic_view")
	self.show_identify_view 	= self:FindVariable("show_identify_view")

	self.magic_but 				= self:FindObj("magic_but")
	self.identify_but 			= self:FindObj("identify_but")

	self:ListenEvent( "close", BindTool.Bind(self.BackOnClick, self))
	self:ListenEvent( "AddGold", BindTool.Bind(self.HandleAddGold, self))

	self.magic_but.toggle:AddValueChangedListener( BindTool.Bind( self.MagicTogleOnClick, self))
	self.identify_but.toggle:AddValueChangedListener( BindTool.Bind( self.IdentifyTogleOnClick, self))
	self.global_event = GlobalEventSystem:Bind(OpenFunEventType.OPEN_TRIGGER, BindTool.Bind(self.OpenTrigger, self))
end

function MagicWeaponView:OpenTrigger()
	OpenFunData.Instance:CheckIsHide("moQi")
end

function MagicWeaponView:GetMagicContentView()
	return self.magic_content_view
end

function MagicWeaponView:OpenCallBack()
	OpenFunData.Instance:CheckIsHide("moQi")
	self.magic_but.toggle.isOn = true
	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold")
	self:PlayerDataChangeCallback("bind_gold")
	self.magic_content_view:OpenCallBack()
end

function MagicWeaponView:CloseCallBack()
	-- self.magic_content_view:RemoveNotifyDataChangeCallBack()
end

--关闭面板
function MagicWeaponView:BackOnClick()
	ViewManager.Instance:Close(ViewName.MagicWeaponView)
end

function MagicWeaponView:MagicTogleOnClick(is_click)
	if is_click then
		self.show_magic_view:SetValue(true)
		self.show_identify_view:SetValue(false)
		self.magic_content_view:OpenCallBack()
	end
end

function MagicWeaponView:IdentifyTogleOnClick(is_click)
	if is_click then
		self.show_magic_view:SetValue(false)
		self.show_identify_view:SetValue(true)
		self.identify_content_view:SetActive(true)
		self.identify_content_view:OpenCallBack()
	end
end

function MagicWeaponView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function MagicWeaponView:PlayerDataChangeCallback(attr_name)
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if attr_name == "gold" then
		local count = vo.gold
		count = self:ChangeNum(count)
		self.gold:SetValue(count)
	end
	if attr_name == "bind_gold" then
		local count = vo.bind_gold
		count = self:ChangeNum(count)
		self.bind_gold:SetValue(count)
	end
end

function MagicWeaponView:ChangeNum(count)
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