TianshenhutiSelectSlotView = TianshenhutiSelectSlotView or BaseClass(BaseView)

function TianshenhutiSelectSlotView:__init()
    self.ui_config = {"uis/views/tianshenhutiview_prefab", "ConversionSelectSlotView"}
   	self.play_audio = true
end

function TianshenhutiSelectSlotView:__delete()

end

function TianshenhutiSelectSlotView:CloseCallBack()

end

function TianshenhutiSelectSlotView:ReleaseCallBack()
	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function TianshenhutiSelectSlotView:LoadCallBack()
	self.cell_list = {}
	local equip_parent = self:FindObj("SlotParent")
	PrefabPool.Instance:Load(AssetID("uis/views/tianshenhutiview_prefab","Slot"),
		function(prefab)
			for i = 1,GameEnum.TIANSHENHUTI_EQUIP_MAX_COUNT do
				local obj = GameObject.Instantiate(prefab)
				obj.transform:SetParent(equip_parent.transform, false)
				obj = U3DObject(obj)
				item = TianshenhutiConversionSlotCell.New(obj)
				item:ListenClick(BindTool.Bind(self.ItemCellClick, self, i - 1))
				self.cell_list[i] = item
			end
			PrefabPool.Instance:Free(prefab)
			self:Flush()
		end)

	self:ListenEvent("CloseWindow",BindTool.Bind(self.Close, self))
end

function TianshenhutiSelectSlotView:OpenCallBack()
	self:Flush()
end

function TianshenhutiSelectSlotView:SetCallBack(call_back)
	self.call_back = call_back
end

function TianshenhutiSelectSlotView:ItemCellClick(index)
	if self.call_back ~= nil then
		self.call_back(index)
		self.call_back = nil
	end
	self:Close()
end


function TianshenhutiSelectSlotView:OnFlush(param_list)
	for k,v in pairs(self.cell_list) do
		v:SetData(k - 1)
	end
end


-------------------TianshenhutiConversionSlotCell-----------------------
TianshenhutiConversionSlotCell = TianshenhutiConversionSlotCell or BaseClass(BaseCell)
function TianshenhutiConversionSlotCell:__init()
	self.quality = self:FindVariable("Quality")
	self.icon = self:FindVariable("Icon")
	self.slot = self:FindVariable("Slot")
	self:ListenEvent("Click", BindTool.Bind(self.OnClick, self))
end

function TianshenhutiConversionSlotCell:__delete()

end

function TianshenhutiConversionSlotCell:OnFlush()
	local select_data_t = TianshenhutiData.Instance:GetComposeSelectList()
	local  select_data = select_data_t[1] or select_data_t[2]
	if self.data == nil or nil == select_data then
		self:SetIcon("", "")
		self.slot:SetValue("")
		self:SetDefualtQuality()
		return
	end
	local item_cfg = TianshenhutiData.Instance:GetEquipCfg(self.data * GameEnum.TIANSHENHUTI_EQUIP_MAX_COUNT + 1)
	if item_cfg then
		local bundle, asset = ResPath.GetItemIcon(item_cfg.icon_id)
		self:SetIcon(bundle, asset)
	end
	self.slot:SetValue(Language.Tianshenhuti.EquipSlot[self.data])
	local bundle1, asset1 = ResPath.GetQualityIcon(6)
	local item_cfg = TianshenhutiData.Instance:GetEquipCfg(select_data.item_id)
	if item_cfg then
		bundle1, asset1 = ResPath.GetRoleEquipQualityIcon(item_cfg.color)
	end
	self.quality:SetAsset(bundle1, asset1)
end

function TianshenhutiConversionSlotCell:SetIcon(bundle, asset)
	if nil ==  bundle or nil == asset then return end
	self.icon:SetAsset(bundle, asset)
end

function TianshenhutiConversionSlotCell:SetDefualtQuality()
	local bundle1, asset1 = ResPath.GetQualityIcon(6)
	self.quality:SetAsset(bundle1, asset1)
end

function TianshenhutiConversionSlotCell:ListenClick(handler)
	self:ClearEvent("Click")
	self:ListenEvent("Click", handler)
end