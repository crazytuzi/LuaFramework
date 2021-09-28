XianzunkaDecView = XianzunkaDecView or BaseClass(BaseView)

function XianzunkaDecView:__init()
	self.ui_config = {"uis/views/xianzunka_prefab","XianzunkaDecView"}
	self.play_audio = true
	self.cell_list = {}
	self.data = nil
end

function XianzunkaDecView:ReleaseCallBack()
	self.name = nil
	self.dec = nil
	self.is_title = nil
	self.title_image = nil
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
	self.display = nil
end

function XianzunkaDecView:LoadCallBack()
	self:ListenEvent("CloseView",
		BindTool.Bind(self.Close, self))
	self.name = self:FindVariable("Name")
	self.dec = self:FindVariable("Dec")
	self.is_title = self:FindVariable("IsTitle")
	self.title_image = self:FindVariable("Title")
	self.display = self:FindObj("Display")
end

function XianzunkaDecView:OpenCallBack()
	self:Flush()
end

function XianzunkaDecView:SetData(data)
	self.data = data
end

function XianzunkaDecView:OnFlush(param_t)
	if self.data == nil then return end
	self.name:SetValue(self.data.name)
	local card_type = self.data.card_type
	local item_id = self.data.first_active_reward.item_id
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg then
		self.is_title:SetValue(item_cfg.use_type == GameEnum.ITEM_OPEN_TITLE)
		if item_cfg.use_type == GameEnum.ITEM_OPEN_TITLE then
			local bundle, asset = ResPath.GetTitleIcon(item_cfg.param1)
			self.title_image:SetAsset(bundle, asset)
		else
			self:SetModel(item_id)
		end
	end
	local addition_cfg = XianzunkaData.Instance:GetAdditionCfg(card_type)
	if addition_cfg then
		self.dec:SetValue(addition_cfg.privilege_description)
	end
end

function XianzunkaDecView:SetModel(item_id)
    if self.model == nil then
        self.model = RoleModel.New()
        self.model:SetDisplay(self.display.ui3d_display)
    end

  	ItemData.ChangeModel(self.model, item_id)
  	self.model:SetPanelName("xianzunka_panel_show_" .. self.data.card_type)
end