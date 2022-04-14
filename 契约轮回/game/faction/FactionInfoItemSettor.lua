--
-- @Author: chk
-- @Date:   2018-12-05 19:43:29
--

FactionInfoItemSettor = FactionInfoItemSettor or class("FactionInfoItemSettor",BaseItem)
local FactionInfoItemSettor = FactionInfoItemSettor

function FactionInfoItemSettor:ctor(parent_node,layer)
	self.abName = "faction"
	self.assetName = "FactionInfoItem"
	self.layer = layer

	self.vipTxts = {}
	self.model = FactionModel:GetInstance()
	FactionInfoItemSettor.super.Load(self)
end

function FactionInfoItemSettor:dctor()
end

function FactionInfoItemSettor:LoadCallBack()
	self.nodes = {
		"name",
		"lv",
		"power",
		"career",
		"vip/contain/vip_1",
		"vip/contain/vip_2",
		"vip/contain/vip_3",
		"vip/contain/vip_4",
		"vip/contain/vip_5",
	}
	self:GetChildren(self.nodes)
	self:AddEvent()

	self.vipTxts[1] = self.vip_1:GetComponent('Text')
	self.vipTxts[2] = self.vip_2:GetComponent('Text')
	self.vipTxts[3] = self.vip_3:GetComponent('Text')
	self.vipTxts[4] = self.vip_4:GetComponent('Text')
	self.vipTxts[5] = self.vip_5:GetComponent('Text')
end

function FactionInfoItemSettor:AddEvent()
	local function call_back()

	end
	AddClickEvent(self.transform.gameObject,call_back)
end

function FactionInfoItemSettor:SetData(data)

end

function FactionInfoItemSettor:UpdateItem()
	self.name:GetComponent('Text').text = ""
	self.lv:GetComponent('Text').text = ""
	self.power:GetComponent('Text').text = ""
	self.career:GetComponent('Text').text = ""

	local show = 1
	if self.data.viplv <= 3 then
		show = 1
	elseif self.data.viplv >= 4 and self.data.viplv <= 6 then
		show = 2
	elseif self.data.viplv >= 7 and self.data.viplv <= 9 then
		show = 3
	elseif self.data.viplv >=10 and self.data.viplv <=12 then
		show = 4
	elseif self.data.viplv >= 13 and self.data.viplv <= 15 then
		show = 5
	end

	local roleData = RoleInfoModel.GetInstance():GetMainRoleData()
	for i = 1, 5 do
		if i == show then
			SetVisible(self.vipTxts[i].gameObject,true)
			self.vipTxts[i].text = string.format("vip%s",roleData.viplv)
		else
			SetVisible(self.vipTxts[i].gameObject,false)
		end
	end
end