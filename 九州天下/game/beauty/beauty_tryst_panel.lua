BeautyTrystPanel = BeautyTrystPanel or BaseClass(BaseView)

local MAX_PAGE_NUM = 4		--每页最大数量
function BeautyTrystPanel:__init()
	self.ui_config = {"uis/views/beauty","BeautyTrystPanel"}
	self:SetMaskBg()
	self.play_audio = true
	self.cur_index  = 0

	self.show_item = {}
	self.max_num = BeautyData.Instance:GetHuanhuaExchangeMaxNum()


	self.item_list = {}
end

function BeautyTrystPanel:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnTab1", BindTool.Bind(self.OnLeftArrowHandle, self))
	self:ListenEvent("OnTab2", BindTool.Bind(self.OnRightArrowHandle, self))

	self.left_arrow = self:FindObj("LeftArrow")
	self.right_arrow = self:FindObj("RightArrow")

	for i=1, 4 do
		self.item_list[i] = TrystItemCell.New(self:FindObj("Statue" .. i))
		self.item_list[i]:SetIndex(i)
		
		self.show_item[i] = self:FindVariable("ShowItem" .. i)
	end
	self:FlushArrowState()
end

function BeautyTrystPanel:ReleaseCallBack()
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
	self.show_item = {}
	self.left_arrow = nil
	self.right_arrow = nil
	self.cur_index  = 0
end

function BeautyTrystPanel:OpenCallBack()
	self:Flush()
end

function BeautyTrystPanel:OnClickClose()
	self:Close()
end

function BeautyTrystPanel:OnLeftArrowHandle(index)
	self.cur_index = self.cur_index - 1
	if self.cur_index <= 0 then
		self.cur_index = 0
	end
	self:FlushArrowState()
end

function BeautyTrystPanel:OnRightArrowHandle(index)
	self.cur_index = self.cur_index + 1
	if self.cur_index >= math.ceil(self.max_num/MAX_PAGE_NUM) then
		self.cur_index = math.ceil(self.max_num/MAX_PAGE_NUM)
	end
	self:FlushArrowState()
end

function BeautyTrystPanel:FlushArrowState()
	self.left_arrow:SetActive(self.cur_index > 0)
	self.right_arrow:SetActive(self.cur_index < math.ceil(self.max_num/MAX_PAGE_NUM) - 1)
	for i=1,4 do
		local huanhua_cfg = BeautyData.Instance:GetBeautyHuanhuaCfg((self.cur_index * MAX_PAGE_NUM + i) - 1)
		self.item_list[i]:SetModelIndex(self.cur_index)
		self.show_item[i]:SetValue(huanhua_cfg.exchange == 1)
	end
end

function BeautyTrystPanel:OnFlush(param_t)
	for i=1, MAX_PAGE_NUM do
		self.item_list[i]:Flush()
	end
end





TrystItemCell = TrystItemCell or BaseClass(BaseRender)

function TrystItemCell:__init()
	self.display = self:FindObj("Display")
	self:ListenEvent("OnTrystBtn", BindTool.Bind(self.OnTrystBtnHandle, self))
	self.ndde_stuff = self:FindVariable("NddeStuff")
	self.consume_stuff = self:FindVariable("ConsumeStuff")
	self.name = self:FindVariable("Name")
	self.btn_text = self:FindVariable("BtnText")
	self.show_btn_red = self:FindVariable("ShowBtnRed")
end

function TrystItemCell:__delete()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end
end

function TrystItemCell:SetIndex(index)
	self.index = index
end

function TrystItemCell:OnFlush(param_list)
	local other_cfg = BeautyData.Instance:GetBeautyOther()
	local huanhua_cfg = BeautyData.Instance:GetBeautyHuanhuaCfg(self.model_index - 1)
	local huanhua_info = BeautyData.Instance:GetHuanhuaInfo(self.model_index - 1)
	if huanhua_cfg and other_cfg and huanhua_info and self.model_index then
		local huanhua_count = huanhua_cfg.exchange_times - huanhua_info.dating_times
		local count_color = huanhua_count <= 0 and "ff0000" or "00931f"
		self.ndde_stuff:SetValue(string.format(Language.Beaut.BeautTrystCount, count_color, huanhua_count))
		local has_stuff = ItemData.Instance:GetItemNumInBagById(other_cfg.dating_item)
		local stuff_color = has_stuff < huanhua_cfg.exchange_item_count and "ff0000" or "00931f"
		self.consume_stuff:SetValue(string.format(Language.Beaut.BeautTrystConsume, ItemData.Instance:GetItemName(other_cfg.dating_item), stuff_color, has_stuff, huanhua_cfg.exchange_item_count))
		local bundle, asset = ResPath.GetBeautyNameRes("huanhua_" .. self.model_index)
		self.name:SetAsset(bundle, asset)

		self.btn_text:SetValue(huanhua_cfg.exchange == 1 and Language.Beaut.TrystBtnText or Language.Beaut.TrystBtnNoText)
		self.show_btn_red:SetValue(huanhua_cfg.exchange == 1 and has_stuff >= huanhua_cfg.exchange_item_count and huanhua_count > 0)
	end
end

-- 初始化模型处理函数
function TrystItemCell:FlushModel()
	if not self.model and self.display then
		self.model = RoleModel.New("beauty_panel")
		self.model:SetDisplay(self.display.ui3d_display)
	end
	local huanhua_cfg = BeautyData.Instance:GetBeautyHuanhuaCfg(self.model_index - 1)
	if huanhua_cfg then
		local bundle, asset = ResPath.GetGoddessNotLModel(huanhua_cfg.model)
		self.model:SetMainAsset(bundle, asset)
		self.model:ResetRotation()
		self.model:SetModelScale(Vector3(0.8, 0.8, 0.8))
	end
end

function TrystItemCell:SetModelIndex(index)
	self.model_index = index * MAX_PAGE_NUM + self.index
	self:FlushModel()
	self:Flush()
end

function TrystItemCell:OnTrystBtnHandle()
	local huanhua_cfg = BeautyData.Instance:GetBeautyHuanhuaCfg(self.model_index - 1)
	if huanhua_cfg then
		if huanhua_cfg.exchange == 1 then
			BeautyCtrl:SendBeautyCommonReq(BEAUTY_COMMON_REQ_TYPE.BEAUTY_COMMON_REQ_TYPE_DATING, self.model_index - 1)
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.Beaut.TrystBtnNoText)
		end
	end
end