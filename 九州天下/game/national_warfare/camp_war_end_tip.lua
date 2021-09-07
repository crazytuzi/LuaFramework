CampWarEndTipView = CampWarEndTipView or BaseClass(BaseView)

local ITEM_NUM = 3		-- 物品数量

function CampWarEndTipView:__init()
	self.ui_config = {"uis/views/nationalwarfareview","ActEndTip"}
	self:SetMaskBg(true)
end

function CampWarEndTipView:__delete()
	
end

function CampWarEndTipView:ReleaseCallBack()
	self.title = nil
	self.desc1 = nil
	self.desc2 = nil
	self.color = nil
	self.show_color = nil
	self.give_times = nil
	self.show_times = nil

	if self.item_list then
		for k, v in pairs(self.item_list) do
			v:DeleteMe()
		end
	end
	self.item_list = {}
	self.item_name = {}
	self.item_num = {}
	self.show_act_cell = {}
end

function CampWarEndTipView:SetData(title_asset, desc_asset1, desc_asset2, cell_data, color_asset, is_show_color, times)
	self.title_asset = title_asset
	self.desc_asset1 = desc_asset1
	self.desc_asset2 = desc_asset2
	self.cell_data = cell_data or {}
	self.color_asset = color_asset
	self.is_show_color = is_show_color or false
	self.times = times or 1
end

function CampWarEndTipView:LoadCallBack()
	self.title = self:FindVariable("Title")
	self.desc1 = self:FindVariable("Desc1")
	self.desc2 = self:FindVariable("Desc2")
	self.color = self:FindVariable("Desc3")
	self.show_color = self:FindVariable("show_color")
	self.give_times = self:FindVariable("Give_Times")
	self.show_times = self:FindVariable("Show_Times")

	self:ListenEvent("Close", BindTool.Bind(self.OnClickClose, self))
	self.item_list = {}
	self.item_name = {}
	self.item_num = {}
	self.show_act_cell = {}
	for i = 1, ITEM_NUM do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("Item_Cell" .. i))
		self.item_name[i] = self:FindVariable("Item_Name" .. i)
		self.item_num[i] = self:FindVariable("Item_Num" .. i)
		self.show_act_cell[i] = self:FindVariable("Show_Act_Cell" .. i)
	end

	self:Flush()
end

function CampWarEndTipView:OnClickClose()
	self:Close()
end

function CampWarEndTipView:OnFlush()
	self.title:SetAsset(ResPath.GetNationalWarfareNoPack(self.title_asset))
	self.desc1:SetAsset(ResPath.GetNationalWarfare(self.desc_asset1))
	self.desc2:SetAsset(ResPath.GetNationalWarfare(self.desc_asset2))
	self.color:SetAsset(ResPath.GetNationalWarfare(self.color_asset))
	self.show_color:SetValue(self.is_show_color)
	self.show_times:SetValue(self.times > 1)
	self.give_times:SetValue(string.format(Language.NationalWarfare.GetRewardTimes, self.times))

	for i = 1, ITEM_NUM do
		if self.cell_data[i] then
			self.item_list[i]:SetData(self.cell_data[i])
			-- self.item_list[i]:SetItemNumVisible(false)
			local item_data = ItemData.Instance:GetItemConfig(self.cell_data[i].item_id)
			if item_data then
				self.item_name[i]:SetValue(ToColorStr(item_data.name, ITEM_COLOR[item_data.color]))
			end
		end
		self.show_act_cell[i]:SetValue(self.cell_data[i] ~= nil)
	end
end
