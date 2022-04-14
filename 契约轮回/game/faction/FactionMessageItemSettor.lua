--
-- @Author: chk
-- @Date:   2018-12-17 20:30:08
--
FactionMessageItemSettor = FactionMessageItemSettor or class("FactionMessageItemSettor",BaseItem)
local FactionMessageItemSettor = FactionMessageItemSettor

function FactionMessageItemSettor:ctor(parent_node,layer)
	self.abName = "faction"
	self.assetName = "FactionMessageItem"
	self.layer = layer

	self.vipTxt = nil
	self.model = FactionModel:GetInstance()
	FactionMessageItemSettor.super.Load(self)
end

function FactionMessageItemSettor:dctor()
end

function FactionMessageItemSettor:LoadCallBack()
	self.nodes = {
		"bg",
		"name",
		"career",
		"lv",
		"power",

		"vip",
	}
	self:GetChildren(self.nodes)
	self.vipTxt = GetText(self.vip)

	self:AddEvent()

	if self.need_load_end then
		self:UpdateItem(self.data,self.index)
	end
end

function FactionMessageItemSettor:AddEvent()
end

function FactionMessageItemSettor:SetData(data)

end

function FactionMessageItemSettor:UpdateItem(data,index)
	if self.is_loaded then
		if index % 2 ~= 0 then
			SetVisible(self.bg.gameObject,false)
		end
		self.career:GetComponent('Text').text = enumName.GUILD_POST[self.data.post]
		self.name:GetComponent('Text').text = self.data.base.name
		self.power:GetComponent('Text').text = self.data.base.power
		self.lv:GetComponent('Text').text = self.data.base.level
		self.vipTxt.text = "V" .. self.data.base.viplv .. ""

	else
		self.data = data
		self.index = index
		self.need_load_end = true
	end
end