
DecomposeGetItemSettor = DecomposeGetItemSettor or class("DecomposeGetItemSettor",BaseWidget)
local DecomposeGetItemSettor = DecomposeGetItemSettor


function DecomposeGetItemSettor:ctor(parent_node,layer)
	self.abName = "system"
	self.assetName = "DecomposeGetItem"
	self.layer = layer

	self.schedule_id = nil
	self.info = nil
	self.need_loaded_end = false
	self.globalEvents = {}
	self.itemRectTra = nil

	DecomposeGetItemSettor.super.Load(self)
end

function DecomposeGetItemSettor:dctor()
	if self.schedule_id ~= nil then
		GlobalSchedule:Stop(self.schedule_id)
		self.schedule_id = nil
	end


	for k,v in pairs(self.globalEvents) do
		globalEvents:RemoveListener(v)
	end
	self.globalEvents = {}
end

function DecomposeGetItemSettor:LoadCallBack()
	self.nodes = {
		"title",
		"value1",
		"line",
		"valueTemp",
		"costImg",
	}
	self:GetChildren(self.nodes)

	self.costImg = GetImage(self.costImg)
	self.value1 = GetText(self.value1)
	self.itemRectTra = GetRectTransform(self.transform)
	
	if self.need_loaded_end then
		self:UpdatInfo(self.info)
	end
	
end

function DecomposeGetItemSettor:AddEvent()
end




function DecomposeGetItemSettor:UpdateInfo(info)
	self.info = info
	if self.is_loaded then

		self.value1.text = info.costNum
	
		self.itemRectTra.anchoredPosition = Vector2(self.itemRectTra.anchoredPosition.x,-info.posY)
		self.itemRectTra.sizeDelta = Vector2(self.itemRectTra.sizeDelta.x,info.itemHeight)

		self.need_loaded_end = false
	else
		self.need_loaded_end = true	
	end

end
