--
-- @Author: chk
-- @Date:   2018-09-29 15:53:13
--
FactionSkillAttrItem = FactionSkillAttrItem or class("FactionSkillAttrItem",BaseItem)
local FactionSkillAttrItem = FactionSkillAttrItem

function FactionSkillAttrItem:ctor(parent_node,layer,index)
	self.abName = "faction"
	self.assetName = "FactionSkillAttrItem"
	self.layer = layer
	self.index = index
	self.minHeight = 0
	self.schedule_id = nil
	self.itemRectTra = nil
	self.TextRectTra = nil
	self.skillAttr = nil
	self.need_loaded_end = false
	self.globalEvents = {}
	FactionSkillAttrItem.super.Load(self)
end

function FactionSkillAttrItem:dctor()
	if self.schedule_id ~= nil then
		GlobalSchedule:Stop(self.schedule_id)
		self.schedule_id = nil
	end


	for k,v in pairs(self.globalEvents) do
		globalEvents:RemoveListener(v)
	end
	self.globalEvents = {}
end

function FactionSkillAttrItem:LoadCallBack()
	self.nodes = {
		"value",
	}
	self:GetChildren(self.nodes)
	self:GetRectTransform()
	self:AddEvent()


	if self.need_loaded_end then
		self:UpdatInfo(self.skillAttr,self.height,self.pos)
	end
	
end

function FactionSkillAttrItem:AddEvent()
end

function FactionSkillAttrItem:GetRectTransform( )
	self.TextRectTra = self.value:GetComponent('RectTransform')
	self.itemRectTra = self.transform:GetComponent('RectTransform')
end
function FactionSkillAttrItem:SetData(data)
	self.skillAttr = data
end

function FactionSkillAttrItem:SetMinHeight(height)
	self.minHeight = height
end

function FactionSkillAttrItem:SetItemSize( )
	if self.minHeight > 0 then
		self.itemRectTra.sizeDelta = Vector2(self.itemRectTra.sizeDelta.x,self.minHeight)
	else
		self.itemRectTra.sizeDelta = Vector2(self.itemRectTra.sizeDelta.x,self.titleRectTra.sizeDelta.y + self.TextRectTra.sizeDelta.y + 8)
	end
end
function FactionSkillAttrItem:UpdatInfo(skillAttr,height,pos)
	self.skillAttr = skillAttr
    self.height = height
    self.pos = pos
	if self.is_loaded then
		self.value:GetComponent('Text').text = skillAttr

		if self.pos ~= nil then
			self.itemRectTra.anchoredPosition = Vector2(self.itemRectTra.anchoredPosition.x,-self.pos)
			self.itemRectTra.sizeDelta = Vector2(self.itemRectTra.sizeDelta.x,self.height)
		end


		self.need_loaded_end = false
	else
		self.need_loaded_end = true	
	end
end