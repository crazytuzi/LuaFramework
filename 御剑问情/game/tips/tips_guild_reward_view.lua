TipGuildRewardView = TipGuildRewardView or BaseClass(BaseView)

function TipGuildRewardView:__init()
	self.ui_config = {"uis/views/tips/rewardtips_prefab", "GuildRewardTip"}
	self.view_layer = UiLayer.Pop
	self.is_show_default_title = true
end

function TipGuildRewardView:ReleaseCallBack()
	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end

	-- 清理变量和对象
	self.name = nil
	self.show_default_title = nil
end

function TipGuildRewardView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.CloseOnClick, self))

	self.name = self:FindVariable("Name")
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self:FindObj("EquipItem"))

	self.show_default_title = self:FindVariable("ShowDefualtTitle")
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
	if self.data then
		if self.data.auto_use and self.data.new_num then
			TipsCtrl.Instance:ShowGetNewItemView(self.data.item_id, self.data.new_num)
		end
	end
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

	self.show_default_title:SetValue(self.is_show_default_title)
end