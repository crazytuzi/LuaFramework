TipsSpiritZhenFaValueView = TipsSpiritZhenFaValueView or BaseClass(BaseView)

function TipsSpiritZhenFaValueView:__init()
	self.ui_config = {"uis/views/tips/spiritzhenfatip_prefab","SpiritZhenfaValueTip"}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
end

function TipsSpiritZhenFaValueView:LoadCallBack()
	self.zhenfa_rate = self:FindVariable("zhenfa_rate")
	self.attackhunyu_rate = self:FindVariable("attackhunyu_rate")
	self.lifehunyu_rate = self:FindVariable("lifehunyu_rate")
	self.defense_rate = self:FindVariable("defense_rate")
	self.promoted_life = self:FindVariable("promoted_life")
	self.promoted_attack = self:FindVariable("promoted_attack")
	self.promote_defense = self:FindVariable("promote_defense")

	self:ListenEvent("Close",
		BindTool.Bind(self.OnClickCloseButton, self))
end

function TipsSpiritZhenFaValueView:__delete()

end

function TipsSpiritZhenFaValueView:ReleaseCallBack()
	-- 清理变量
	self.zhenfa_rate = nil
	self.attackhunyu_rate = nil
	self.lifehunyu_rate = nil
	self.defense_rate = nil
	self.promoted_life = nil
	self.promoted_attack = nil
	self.promote_defense = nil
end

function TipsSpiritZhenFaValueView:CloseCallBack()
end

function TipsSpiritZhenFaValueView:OnClickCloseButton()
	self:Close()
end

function TipsSpiritZhenFaValueView:OnFlush()
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	local zhenfa_attr_list = SpiritData.Instance:GetZhenfaAttrList()
	self.zhenfa_rate:SetValue(zhenfa_attr_list.zhenfa_rate .. "%")
	self.attackhunyu_rate:SetValue(zhenfa_attr_list.attackhunyu_rate .. "%")
	self.lifehunyu_rate:SetValue(zhenfa_attr_list.lifehunyu_rate .. "%")
	self.defense_rate:SetValue(zhenfa_attr_list.defensehunyu_rate .. "%")
	self.promoted_life:SetValue(math.ceil(zhenfa_attr_list.max_hp) + SpiritData.Instance:GetZhenfaCfgByLevel(spirit_info.xianzhen_level).maxhp)
	self.promoted_attack:SetValue(math.ceil(zhenfa_attr_list.gong_ji))
	self.promote_defense:SetValue(math.ceil(zhenfa_attr_list.fang_yu))
end
