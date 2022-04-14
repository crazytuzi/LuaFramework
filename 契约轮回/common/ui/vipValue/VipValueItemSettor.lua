--
-- @Author: chk
-- @Date:   2018-12-18 19:40:11
--
VipValueItemSettor = VipValueItemSettor or class("VipValueItemSettor",BaseItem)
local VipValueItemSettor = VipValueItemSettor

function VipValueItemSettor:ctor(parent_node,layer)
	self.abName = "vipValue"
	self.assetName = "VipValueItem"
	self.layer = layer

	-- self.model = 2222222222222end:GetInstance()
	self.vipTxts = {}
	VipValueItemSettor.super.Load(self)
end

function VipValueItemSettor:dctor()
end

function VipValueItemSettor:LoadCallBack()
	self.nodes = {
		"vip_1",
		"vip_2",
		"vip_3",
		"vip_4",
		"vip_5",
	}
	self:GetChildren(self.nodes)
	self:AddEvent()
	self.vipTxts[1] = self.vip_1:GetComponent('Text')
	self.vipTxts[2] = self.vip_2:GetComponent('Text')
	self.vipTxts[3] = self.vip_3:GetComponent('Text')
	self.vipTxts[4] = self.vip_4:GetComponent('Text')
	self.vipTxts[5] = self.vip_5:GetComponent('Text')
	self:UpdateValue()
end

function VipValueItemSettor:AddEvent()
end

function VipValueItemSettor:SetData(data)
	self.vip = data
end

function VipValueItemSettor:UpdateValue()
	local show = 1
	if self.vip <= 3 then
		show = 1
	elseif self.vip >= 4 and self.vip <= 6 then
		show = 2
	elseif self.vip >= 7 and self.vip <= 9 then
		show = 3
	elseif self.vip >=10 and self.vip <=12 then
		show = 4
	elseif self.vip >= 13 and self.vip <= 15 then
		show = 5
	end

	for i = 1, 5 do
		if i == show then
			SetVisible(self.vipTxts[i].gameObject,true)
			self.vipTxts[i].text = string.format("vip%s",self.data.viplv)
		else
			SetVisible(self.vipTxts[i].gameObject,false)
		end
	end
end