TipGuildRewardView = TipGuildRewardView or BaseClass(BaseView)

function TipGuildRewardView:__init()
	self.ui_config = {"uis/views/tips/rewardtips", "GuildRewardTip"}
	self.view_layer = UiLayer.Pop
	self.is_show_default_title = true
	self:SetMaskBg(true)
end

function TipGuildRewardView:ReleaseCallBack()
	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end

	-- 清理变量和对象
	self.name = nil
	self.show_default_title = nil
	self.qualityBao = nil 
	self.shen_back_level = nil
	self.is_show_qualiy = nil
end

function TipGuildRewardView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.CloseOnClick, self))

	self.name = self:FindVariable("Name")
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self:FindObj("EquipItem"))

	self.qualityBao = self:FindVariable("QualityBao")	
	self.shen_back_level = self:FindVariable("ShenBackLevel")

	self.show_default_title = self:FindVariable("ShowDefualtTitle")
	self.is_show_qualiy = self:FindVariable("IsShowQualiy")
end

function TipGuildRewardView:OpenCallBack()
	self:Flush()
end

function TipGuildRewardView:ShowIndexCallBack(index)
end

function TipGuildRewardView:CloseCallBack()
end

function TipGuildRewardView:SetData(data)
	self.data = data
	self:Open()
end

function TipGuildRewardView:CloseOnClick()
	self:Close()
end

function TipGuildRewardView:SetTitleState(value)
	self.is_show_default_title = value
	if nil == self.is_show_default_title then
		self.is_show_default_title = true
	end
end

function TipGuildRewardView:OnFlush(param_list)
	if nil == self.data or nil == next(self.data) then
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_cfg then
		return
	end

	local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..item_cfg.name.."</color>"
	self.name:SetValue(name_str)
	self.item:SetData(self.data)
	if  self.data.shen_ge_data then
		self.shen_back_level:SetValue(self.data.shen_ge_data.level)
		self.qualityBao:SetAsset(ResPath.GetRomeNumImage(self.data.shen_ge_data.quality))
		self.shen_back_level:SetValue(self.data.shen_ge_data.level)
		self.is_show_qualiy:SetValue(true)
	else
		self.is_show_qualiy:SetValue(false)
	end

	self.show_default_title:SetValue(self.is_show_default_title)
end