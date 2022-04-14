--
-- @Author: chk
-- @Date:   2018-12-05 19:44:31
--
FactionInfoPanel = FactionInfoPanel or class("FactionInfoPanel",BasePanel)
local FactionInfoPanel = FactionInfoPanel

function FactionInfoPanel:ctor()
	self.abName = "faction"
	self.assetName = "FactionInfoPanel"
	self.layer = "UI"

	self.use_background = true
	self.change_scene_close = true
	self.infoItems = {}
	self.model = FactionModel:GetInstance()
end

function FactionInfoPanel:dctor()
	for i, v in pairs(self.infoItems) do
		v:destroy()
	end
end

function FactionInfoPanel:Open(data)
	self.data = data
	FactionInfoPanel.super.Open(self)
end

function FactionInfoPanel:LoadCallBack()
	self.nodes = {
		"member/Scroll View/Viewport/Content",
		"CloseBtn",
	}
	self:GetChildren(self.nodes)
	self.rectTra = self.Content:GetComponent('RectTransform')
	self:AddEvent()
end

function FactionInfoPanel:AddEvent()
	local function call_back()
		self:Close()
	end

	AddClickEvent(self.CloseBtn.gameObject,call_back)
end

function FactionInfoPanel:OpenCallBack()
	self:UpdateView()
end

function FactionInfoPanel:UpdateView( )
	for i, v in pairs() do
		local item = FactionInfoItem(self.Content)
		item:SetData()
		table.insert(self.infoItems,item)
	end
end

function FactionInfoPanel:CloseCallBack(  )

end