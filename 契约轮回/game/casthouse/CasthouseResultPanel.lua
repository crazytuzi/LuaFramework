CasthouseResultPanel = CasthouseResultPanel or class("CasthouseResultPanel",BasePanel)
local CasthouseResultPanel = CasthouseResultPanel

function CasthouseResultPanel:ctor()
	self.abName = "casthouse"
	self.assetName = "CasthouseResultPanel"
	self.layer = "UI"

	self.use_background = true
	self.change_scene_close = true
	self.item_list = {}
	self.model = CasthouseModel:GetInstance()
end

function CasthouseResultPanel:dctor()
end

function CasthouseResultPanel:Open(item_ids)
	CasthouseResultPanel.super.Open(self)
	self.item_ids = item_ids or {}
end

function CasthouseResultPanel:LoadCallBack()
	self.nodes = {
		"ScrollView/Viewport/Content","end_item",
	}
	self:GetChildren(self.nodes)

	self:AddEvent()
end

function CasthouseResultPanel:AddEvent()

end

function CasthouseResultPanel:OpenCallBack()
	self:UpdateView()
end

function CasthouseResultPanel:UpdateView( )
	self.model:Brocast(CasthouseEvent.UpdatePetModel, true)
	local data = {
		isClear = true,
		star = 7,
		IsCancelAutoSchedule = true
	}
	self.enditem = DungeonEndItem(self.end_item, data)
	self.enditem:ShowStars(true)
	self.enditem:StartAutoClose(5)
	local function closeCallBack()
		self.model:Brocast(CasthouseEvent.UpdatePetModel, false)
		self:Close()
	end
	self.enditem:SetAutoCloseCallBack(closeCallBack)
	self.enditem:SetCloseCallBack(closeCallBack)
	for i=1, #self.item_ids do
		local item = self.item_list[i] or GoodsIconSettorTwo(self.Content)
		local param = {
			item_id = self.item_ids[i],
			can_click = true,
		}
		item:SetIcon(param)
		self.item_list[i] = item
	end
end

function CasthouseResultPanel:CloseCallBack(  )
	if self.enditem then
		self.enditem:destroy()
	end
	for i=1, #self.item_list do
		self.item_list[i]:destroy()
	end
end