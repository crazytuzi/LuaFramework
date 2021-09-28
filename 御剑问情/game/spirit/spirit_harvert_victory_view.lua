SpiritHarvertVictoryView = SpiritHarvertVictoryView or BaseClass(BaseView)

local ITEM_NUM = 8
function SpiritHarvertVictoryView:__init(instance)
	self.ui_config = {"uis/views/spiritview_prefab","SpiritHarvertVictory"}
	self.view_layer = UiLayer.Pop
	self.play_audio = true

	self.item_list = {}
	self.obj_list = {}
end

function SpiritHarvertVictoryView:__delete()

end

function SpiritHarvertVictoryView:ReleaseCallBack()
	for k,v in pairs(self.item_list) do
		if v ~= nil and v.item ~= nil then
			v.item:DeleteMe()
		end
	end

	self.item_list = {}
	self.obj_list = {}
end

function SpiritHarvertVictoryView:LoadCallBack()
	for i = 1, ITEM_NUM do
		self.obj_list[i] = self:FindObj("Item" .. i)
		if self.obj_list[i] ~= nil then
			self.item_list[i] = {}
			self.item_list[i].item = ItemCell.New()
			self.item_list[i].item:SetInstanceParent(self.obj_list[i])
			self.item_list[i].is_show = self:FindVariable("ShowItem" .. i)
		end
	end

	self:ListenEvent("OnClick", BindTool.Bind(self.OnClick, self))
end

function SpiritHarvertVictoryView:OpenCallBack()
	self:Flush()
end

function SpiritHarvertVictoryView:SetData()
	self.harvert_index = nil

	local harvert_index = SpiritData.Instance:GetHarvertSpirit()
	if harvert_index == nil then
		return
	end	

	self.harvert_index = harvert_index
	if not self:IsOpen() then
		self:Open()
	end
end

function SpiritHarvertVictoryView:OnFlush()
	if self.harvert_index == nil then
		return
	end

	--local cfg = SpiritData.Instance:GetSpiritHomeRewardList(self.harvert_index)
	local cfg = SpiritData.Instance:GetHarvertLastData()
	if cfg == nil or next(cfg) == nil then
		return
	end

	for k,v in pairs(self.item_list) do
		if v ~= nil then
			local item = TableCopy(cfg[k])
			if item ~= nil and item.item_id > 0 and item.num > 0 then
				--if self.obj_list[k] ~= nil then
					v.item:SetData(item)
					-- self.obj_list[k]:SetActive(true)
					v.is_show:SetValue(true)
				--end
			else
				self.obj_list[k]:SetActive(false)
				v.is_show:SetValue(false)
			end
		end
	end
end

function SpiritHarvertVictoryView:OnClick()
	SpiritData.Instance:ResetFightResult()
	self:Close()
end