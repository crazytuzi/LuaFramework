ShenShouStuffTip = ShenShouStuffTip or BaseClass(BaseView)

function ShenShouStuffTip:__init()
	self.ui_config = {"uis/views/shenshouview_prefab","ShenShouStuffTip"}
	self.play_audio = true
end

function ShenShouStuffTip:ReleaseCallBack()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
	self.dec = nil
	self.name = nil
end

function ShenShouStuffTip:LoadCallBack()
	self.dec = self:FindVariable("Dec")
	self.name = self:FindVariable("Name")

	self.cell = ShenShouEquip.New()
	self.cell:SetInstanceParent(self:FindObj("Item"))
	self.cell:SetInteractable(false)

	self:ListenEvent("CloseWindow",BindTool.Bind(self.Close, self))
end

function ShenShouStuffTip:ShowIndexCallBack(index)
	self:Flush()
end

function ShenShouStuffTip:OnFlush(param_t, index)
	local shenshou_equip_cfg = ShenShouData.Instance:GetShenShouEqCfg(self.data.item_id)
	if nil == shenshou_equip_cfg then return end
	self.cell:SetData(self.data)

	local color = shenshou_equip_cfg.quality
	self.name:SetValue(string.format("<color=%s>%s</color>", ITEM_TIP_COLOR[color + 1], shenshou_equip_cfg.name))

	self.dec:SetValue(shenshou_equip_cfg.description)
end

function ShenShouStuffTip:SetData(data)
	if nil == data then return end
	self.data = data
	self:Open()
	self:Flush()
end