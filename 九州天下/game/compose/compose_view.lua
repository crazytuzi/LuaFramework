require("game/compose/compose_content_view")
ComposeView = ComposeView or BaseClass(BaseView)

function ComposeView:__init()
	self.ui_config = {"uis/views/composeview","ComposeView"}
	self:SetMaskBg()
	self.full_screen = false
	self.play_audio = true
	self.is_async_load = false
	self.is_check_reduce_mem = true
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

function ComposeView:__delete()

end

function ComposeView:ReleaseCallBack()
	if self.compose_content_view then
		self.compose_content_view:DeleteMe()
		self.compose_content_view = nil
	end

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	if self.money then
		self.money:DeleteMe()
		self.money = nil
	end

	-- 清理变量和对象
	self.baoshi_bar = nil
	self.qita_bar = nil
	self.jinjie_bar = nil
	self.shizhuang_bar = nil
	self.red_point_list = nil
end

function ComposeView:LoadCallBack()
	self:ListenEvent("close_view",BindTool.Bind(self.BackOnClick,self))
	self.baoshi_bar = self:FindObj("baoshi_bar")
	self.baoshi_bar.toggle:AddValueChangedListener(BindTool.Bind(self.BaoshiTogleOnClick, self))
	self.qita_bar = self:FindObj("qita_bar")
	self.qita_bar.toggle:AddValueChangedListener(BindTool.Bind(self.QitaTogleOnClick, self))
	self.jinjie_bar = self:FindObj("jinjie_bar")
	self.jinjie_bar.toggle:AddValueChangedListener(BindTool.Bind(self.JinjieTogleOnClick, self))
	self.shizhuang_bar = self:FindObj("shizhuang_bar")
	self.shizhuang_bar.toggle:AddValueChangedListener(BindTool.Bind(self.ShizhuangTogleOnClick, self))

	self.money = MoneyBar.New()
	self.money:SetInstanceParent(self:FindObj("MoneyBar"))

	-- 子面板
	local compose_view = self:FindObj("compose_content_view")
	compose_view.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.compose_content_view = ComposeContentView.New(obj)
	end)

	self.red_point_list = {
		[RemindName.ComposeStone] = self:FindVariable("ShowStoneRedPoint"),
		[RemindName.ComposeOther] = self:FindVariable("ShowOtherRedPoint"),
		[RemindName.ComposeJinjie] = self:FindVariable("ShowJinjieRedPoint"),
	}

	for k, _ in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end
end

function ComposeView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function ComposeView:OpenCallBack()
	if ShengXiaoCtrl.Instance:GetBagView():IsOpen() then
		ShengXiaoCtrl.Instance:GetBagView():Close()
	end
	if self.compose_content_view then
		self.compose_content_view:FlushBuyNum()
	end

	--监听物品变化
	if self.item_change == nil then
		self.item_change = BindTool.Bind(self.ItemChange, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_change)
	end
end

function ComposeView:CloseCallBack()
	if self.item_change then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change)
		self.item_change = nil
	end
end

function ComposeView:ItemChange(item_id)
	self:Flush(nil, {item_id})
end

--关闭面板
function ComposeView:BackOnClick()
	ViewManager.Instance:Close(ViewName.Compose)
end

function ComposeView:BaoshiTogleOnClick(is_click)
	if is_click and self:IsLoaded() and self.compose_content_view then
		self.compose_content_view:OnBaoShi()
	end
end

function ComposeView:QitaTogleOnClick(is_click)
	if is_click and self.compose_content_view then
		self.compose_content_view:OnQiTa()
	end
end

function ComposeView:JinjieTogleOnClick(is_click)
	if is_click and self.compose_content_view then
		self.compose_content_view:OnJinJie()
	end
end

function ComposeView:ShizhuangTogleOnClick(is_click)
	if is_click and self.compose_content_view then
		self.compose_content_view:OnShiZhuang()
	end
end

function ComposeView:ShowIndexCallBack(index)
	if index == TabIndex.compose_jinjie then
		if self.jinjie_bar.toggle.isOn and self.compose_content_view then
			self.compose_content_view:OnJinJie()
		else
			self.jinjie_bar.toggle.isOn = true
		end
	elseif index == TabIndex.compose_other then
		if self.qita_bar.toggle.isOn and self.compose_content_view then
			self.compose_content_view:OnQiTa()
		else
			self.qita_bar.toggle.isOn = true
		end
	elseif index == TabIndex.compose_stone then
		if self.baoshi_bar.toggle.isOn and self.compose_content_view then
			self.compose_content_view:OnBaoShi()
		else
			self.baoshi_bar.toggle.isOn = true
		end
	end
end

function ComposeView:OnFlush(param_t)
	if self.compose_content_view then
		local item_id = param_t["all"][1]
		self.compose_content_view:ItemDataChangeCallback(item_id)
	end
end