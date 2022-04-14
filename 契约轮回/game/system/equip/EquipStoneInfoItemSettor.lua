--
-- @Author: chk
-- @Date:   2018-09-29 17:53:17
--
EquipStoneInfoItemSettor = EquipStoneInfoItemSettor or class("EquipStoneInfoItemSettor",BaseWidget)
local EquipStoneInfoItemSettor = EquipStoneInfoItemSettor

function EquipStoneInfoItemSettor:ctor(parent_node,layer)
	self.abName = "system"
	self.assetName = "EquipStoneInfoItem"
	self.layer = layer

	-- self.model = 2222222222222end:GetInstance()
	self.heigt = 0
	self.attrItems = {}
	EquipStoneInfoItemSettor.super.Load(self)
end

function EquipStoneInfoItemSettor:dctor()
	for i, v in pairs(self.attrItems) do
		v:destroy()
	end

	self.attrItems = {}

	if self.schedule_id ~= nil then
		GlobalSchedule:Stop(self.schedule_id)
		self.schedule_id = nil
	end
end

function EquipStoneInfoItemSettor:LoadCallBack()
	self.nodes = {
		"attrContain",
		"line",
		"title",
	}
	self:GetChildren(self.nodes)
	self:AddEvent()

	if self.need_load_end then
		self:UpdateStoneInfo(self.stones,self.slot,self.posY,self.itemHeight)
	end
end

function EquipStoneInfoItemSettor:AddEvent()
end

function EquipStoneInfoItemSettor:SetData(data)

end

function EquipStoneInfoItemSettor:SetItemSize( )
	--if self.minHeight > 0 then
	--	self.itemRectTra.sizeDelta = Vector2(self.itemRectTra.sizeDelta.x,self.minHeight)
	--else
	--	self.itemRectTra.sizeDelta = Vector2(self.itemRectTra.sizeDelta.x,self.titleRectTra.sizeDelta.y + self.TextRectTra.sizeDelta.y)
	--end
	--
	--self.lineRectTra.anchoredPosition = Vector2(self.lineRectTra.anchoredPosition.x,-self.itemRectTra.sizeDelta.y + 5)
	GlobalEvent:Brocast(GoodsEvent.CreateAttEnd)
end

function EquipStoneInfoItemSettor:UpdateStoneInfo(stones,slot,posY,itemHeight)
	self.stones = stones
	self.slot = slot
	self.posY = posY
	self.itemHeight = itemHeight

	if self.is_loaded then
		local _stones = stones or {}
		local stonesNum = table.nums(_stones)
		local spanNum = 6 - stonesNum

		for i, v in pairs(_stones) do
			self.attrItems[#self.attrItems+1] = EquipStoneAttrItemSettor(self.attrContain)
			self.attrItems[#self.attrItems]:UpdateAttrInfo(v)
		end

		local from = stonesNum + 1
		self:UpdateNoStoneInfo(from)



		--self.heigt = self.heigt + stonesNum * 52
		--self.heigt = self.heigt + spanNum * 22
		--self.heigt = self.heigt + 22 + 20

		local itemRectTra = self.transform:GetComponent('RectTransform')
		itemRectTra.sizeDelta = Vector2(itemRectTra.sizeDelta.x,self.itemHeight)
		itemRectTra.anchoredPosition = Vector2(itemRectTra.anchoredPosition.x,-posY)
		local lineRectTra = self.line:GetComponent('RectTransform')
		lineRectTra.anchoredPosition = Vector2(lineRectTra.anchoredPosition.x,-itemHeight + 10)
		
	else
		self.need_load_end = true

	end

end

function EquipStoneInfoItemSettor:UpdateNoStoneInfo(from)
	if from >= 6 then
		return
	end


	if self.is_loaded then
		for i = from, 6 do
			self.attrItems[#self.attrItems+1] = EquipStoneNotAttrItemSettor(self.attrContain)
			self.attrItems[#self.attrItems]:UpdateInfo(self.slot,i)
		end

		self.need_load_not_info_end = false
	else
		self.need_load_not_info_end  = true
	end
end

