RareItemTipManager = RareItemTipManager or BaseClass()
function RareItemTipManager:__init()
	if RareItemTipManager.Instance ~= nil then
		error("[RareItemTipManager] attempt to create singleton twice!")
		return
	end
	RareItemTipManager.Instance = self
	self.rare_tips = RareItemTips.New()
	self.list = {}
end

function RareItemTipManager:__delete()
	if self.rare_tips then
		self.rare_tips:DeleteMe()
		self.rare_tips = nil
	end
end

function RareItemTipManager:AddRareItem(item_info)
	if item_info.num <= 0 then return end
	local item_cfg = ItemData.Instance:GetItemConfig(item_info.item_id)
	if not (item_cfg and item_cfg.rarefloating and item_cfg.rarefloating == 1) then return end
	if self.rare_tips:IsOpen() then
		table.insert(self.list, item_info)
	else
		self.rare_tips:SetShowItem(item_info.item_id, item_info.num)
	end
end

function RareItemTipManager:ShowOnceEnd()
	if #self.list > 0 then
		self.rare_tips:SetShowItem(self.list[1].item_id, self.list[1].num)
		table.remove(self.list, 1)
	else
		self.list = {}
	end
end

RareItemTips = RareItemTips or BaseClass(BaseView)
function RareItemTips:__init()
	self.ui_config = {"uis/views/tips/raretips", "RareTips"}
	self.view_layer = UiLayer.Pop
	self.item_id = 0
end

function RareItemTips:ReleaseCallBack()
	self.item_name = nil
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	self.rare_animator = nil
end

function RareItemTips:LoadCallBack()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.item_name = self:FindVariable("ItemName")
	local anim_obj = self:FindObj("AnimObj")
	self.rare_animator = anim_obj.animator
	if self.rare_animator then
		self.rare_animator:ListenEvent("AnimExit", function ()
			self:Close()
		end)
	end
end

function RareItemTips:SetShowItem(item_id, num)
	self.item_id = item_id or 0
	self.num = num or 1
	if self.num > 0 then
		self:Open()
	end
end

function RareItemTips:OpenCallBack()
	local item_cfg = ItemData.Instance:GetItemConfig(self.item_id)
	if not item_cfg then 
		self:Close()
	end
	self.item_cell:SetData({item_id = self.item_id, num = self.num})
	self.item_cell:SetSpecialEffect(ResPath.GetItemActivityEffect())
	self.item_cell:ShowSpecialEffect(true)
	self.item_name:SetValue(ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color]))
end

function RareItemTips:CloseVisible()
	BaseView.CloseVisible(self)
	self.item_id = 0
	RareItemTipManager.Instance:ShowOnceEnd()
end