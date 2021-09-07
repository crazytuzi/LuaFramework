local CommonFunc = require("game/tips/tips_common_func")
TipsMagicItemView = TipsMagicItemView or BaseClass(BaseView)

function TipsMagicItemView:__init()
	self.ui_config = {"uis/views/tips/equiptips","MagicItemTip"}
	self.view_layer = UiLayer.Pop
	self.close_call_back = nil
	self.buttons = {}
	self.play_audio = true
end

function TipsMagicItemView:LoadCallBack()
	-- 功能按钮
	self.equip_item = ItemCell.New()
	self.equip_item:SetInstanceParent(self:FindObj("EquipItem"))

	self.button_root = self:FindObj("RightBtn")
	for i =1 ,3 do
		local button = self.button_root:FindObj("Btn"..i)
		local btn_text = self.button_root:FindObj("Btn"..i.."/Text")
		local show_button = self:FindVariable("Button"..i)
		self.buttons[i] = {btn = button, text = btn_text, show_button = show_button}
	end

	self.show_no_trade = self:FindVariable("ShowNoTrade")

	self.equip_name = self:FindVariable("EquipName")
	self.weapon_des = self:FindVariable("des")
	self.get_way = self:FindVariable("get_way")
	self.use_level = self:FindVariable("use_level")

	self:ListenEvent("Close",
		BindTool.Bind(self.OnClickCloseButton, self))
	self:ListenEvent("Button1",
		BindTool.Bind(self.OnClickUseButton, self))
	self:ListenEvent("Button2",
		BindTool.Bind(self.OnClickIdentifyButton, self))
	self:ListenEvent("Button3",
		BindTool.Bind(self.OnClickExtractButton, self))

end

function TipsMagicItemView:SetData(data, from_view, param_t, callback)
	self.data = data
	self.close_call_back = callback
	self:Open()
end

function TipsMagicItemView:OpenCallBack()
	if self.data == nil then
		return
	end
	self.weapon_info_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	local name_str = "<color="..SOUL_NAME_COLOR[self.weapon_info_cfg.color]..">"..self.weapon_info_cfg.name.."</color>"
	self.equip_name:SetValue(name_str)
	self.equip_item:SetData(self.data)
	self.weapon_des:SetValue(self.weapon_info_cfg.description)
	self.get_way:SetValue(self.weapon_info_cfg.get_msg)
	self.use_level:SetValue(self.weapon_info_cfg.limit_level)
	self:showHandlerBtn(self.data)

end

function TipsMagicItemView:__delete()
	CommonFunc.DeleteMe()
end

function TipsMagicItemView:ShowTipContent()

end

-- 根据不同情况，显示和隐藏按钮
function TipsMagicItemView:showHandlerBtn(data)
if self.data.type == 0 then
	self.buttons[1].show_button:SetValue(true)
	self.buttons[2].show_button:SetValue(false)
	self.buttons[3].show_button:SetValue(true)
elseif self.data.type == 1 then
	self.buttons[1].show_button:SetValue(false)
	self.buttons[2].show_button:SetValue(false)
	self.buttons[3].show_button:SetValue(true)
elseif self.data.type == 2 then
	self.buttons[1].show_button:SetValue(false)
	self.buttons[2].show_button:SetValue(true)
	self.buttons[3].show_button:SetValue(true)
end
end

--关闭装备Tip
function TipsMagicItemView:OnClickCloseButton()
	self:Close()
	if self.close_call_back ~= nil then
		self.close_call_back()
	end
end
--使用
function TipsMagicItemView:OnClickUseButton()
	MagicWeaponCtrl.Instance:SendMagicLevelUpReq(SHENZHOU_WEAPON_REQ_TYPE.SHENZHOU_WEAPON_REQ_TYPE_UPGRADE_WEAPON, self.data.slot, 0, 0)
	self:OnClickCloseButton()
end
--鉴定
function TipsMagicItemView:OnClickIdentifyButton()
	MagicWeaponCtrl.Instance:SendMagicLevelUpReq(SHENZHOU_WEAPON_REQ_TYPE.SHENZHOU_WEAPON_REQ_TYPE_INDENTIFY, self.data.bag_index, 0, 0)
	self:OnClickCloseButton()
end
--取出
function TipsMagicItemView:OnClickExtractButton()
	MagicWeaponCtrl.Instance:SendMagicLevelUpReq(SHENZHOU_WEAPON_REQ_TYPE.SHENZHOU_WEAPON_REQ_TYPE_TAKE_OUT, self.data.bag_index, 0, 0)
	self:OnClickCloseButton()
end