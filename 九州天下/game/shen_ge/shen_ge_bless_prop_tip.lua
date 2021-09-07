ShenGePropTipView = ShenGePropTipView or BaseClass(BaseView)

function ShenGePropTipView:__init()
	self.ui_config = {"uis/views/shengeview", "ShenGeBlessPropTip"}
	self.play_audio = true
	self.fight_info_view = true
	self:SetMaskBg(true)
end

function ShenGePropTipView:LoadCallBack()
	self:ListenEvent("CloseButton", BindTool.Bind(self.CloseButton, self))

	self.scroller_rect = self:FindObj("Scroller").scroll_rect

	self.fight_power = self:FindVariable("FightPower")
	self.detail = self:FindVariable("Detail")
	self.shen_ge_name = self:FindVariable("Name")
	self.quality = self:FindVariable("Quality")
	self.icon = self:FindVariable("Icon")
end

function ShenGePropTipView:ReleaseCallBack()
	-- 清理变量
	self.fight_power = nil
	self.detail = nil
	self.shen_ge_name = nil
	self.scroller_rect = nil
	self.icon = nil
	self.quality = nil
end

function ShenGePropTipView:OpenCallBack()
	self.scroller_rect.normalizedPosition = Vector2(0, 1)

	local name_str = "<color="..SOUL_NAME_COLOR[self.data.color]..">"..self.data.name.."</color>"
	self.shen_ge_name:SetValue(name_str)
	self.detail:SetValue(self.data.detail)
	self.fight_power:SetValue(self.data.zhanli)

	local bundle, asset = ResPath.GetItemIcon(self.data.item_id)
	self.icon:SetAsset(bundle, asset)

	local bundle1, asset1 = ResPath.GetQualityIcon(self.data.color)
	self.quality:SetAsset(bundle1, asset1)
end

function ShenGePropTipView:CloseCallBack()

end

function ShenGePropTipView:CloseButton()
	self:Close()
end

function ShenGePropTipView:SetData(data)
	self.data = data
	self:Open()
end