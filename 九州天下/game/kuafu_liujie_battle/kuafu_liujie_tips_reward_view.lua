KfLiujieRewardTip = KfLiujieRewardTip or BaseClass(BaseView)

function KfLiujieRewardTip:__init()
	self.ui_config = {"uis/views/kuafuliujie", "KuafuLiujieRewardTips"}
	self:SetMaskBg(true)
	self.item_list = {}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self.title_id = 0
end

function KfLiujieRewardTip:__delete()
	self.data_list = nil
	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function KfLiujieRewardTip:SetData(items,show_gray,ok_callback,show_button, title_id)
	self.data_list = items
	self.show_gray_data = show_gray
	self.ok_callback = ok_callback
	self.show_button_value = show_button
	self.title_id = title_id
end

function KfLiujieRewardTip:LoadCallBack()
	self:ListenEvent("CloseView", BindTool.Bind(self.CloseView, self))
	self:ListenEvent("ClickOK", BindTool.Bind(self.ClickOK, self))
	self.item_list = {}
	for i = 1, 5 do
		local item_obj = self:FindObj("Item"..i)
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(item_obj)
		self.item_list[i - 1] = {item_obj = item_obj, item_cell = item_cell}
	end
	self.show_gray = self:FindVariable("ShowGray")
	self.show_button = self:FindVariable("ShowButton")
	self.img_title = self:FindVariable("img_title")
	self.text_cap = self:FindVariable("text_cap")
	
end

function KfLiujieRewardTip:CloseView()
	self:Close()
end

function KfLiujieRewardTip:ClickOK()
	if self.ok_callback then
		self.ok_callback()
	end
	self:Close()
end

function KfLiujieRewardTip:OpenCallBack()
	self:Flush()
end
function KfLiujieRewardTip:OnFlush()
	if self.data_list ~= nil then
		for k, v in pairs(self.item_list) do
			if self.data_list[k] then
				v.item_cell:SetData(self.data_list[k])
				v.item_obj:SetActive(true)
			else
				v.item_obj:SetActive(false)
			end
		end
		self.show_gray:SetValue(self.show_gray_data)
		if self.show_button_value == nil then
			self.show_button:SetValue(true)
		else
			self.show_button:SetValue(self.show_button_value)
		end
	end
	local bundle, asset = ResPath.GetTitleIcon(self.title_id)
	self.img_title:SetAsset(bundle, asset)

	local title_cfg = TitleData.Instance:GetTitleCfg(self.title_id)
	self.text_cap:SetValue(CommonDataManager.GetCapability(title_cfg))
end

function KfLiujieRewardTip:ReleaseCallBack()
	self.data_list = nil
	for k,v in pairs(self.item_list) do
		if v.item_cell then
			v.item_cell:DeleteMe()
		end
	end
	self.item_list = {}
	self.show_gray = nil
	self.show_button = nil
	self.img_title = nil
	self.text_cap = nil
end
