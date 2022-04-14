ComposeEquipTipPanel = ComposeEquipTipPanel or class("ComposeEquipTipPanel",BasePanel)
local ComposeEquipTipPanel = ComposeEquipTipPanel

function ComposeEquipTipPanel:ctor()
	self.abName = "combine"
	self.assetName = "ComposeEquipTipPanel"
	self.layer = "UI"

	self.use_background = true
	self.change_scene_close = true
	self.click_bg_close = true

	self.panel_type = 2

	--self.model = 2222222222222end:GetInstance()
end

function ComposeEquipTipPanel:dctor()
end

function ComposeEquipTipPanel:Open( )
	ComposeEquipTipPanel.super.Open(self)
end

function ComposeEquipTipPanel:LoadCallBack()
	self.nodes = {
		"btnclose",
	}
	self:GetChildren(self.nodes)

	self:AddEvent()
end

function ComposeEquipTipPanel:AddEvent()
	local function call_back(target,x,y)
		self:Close()
	end
	AddButtonEvent(self.btnclose.gameObject,call_back)
end

function ComposeEquipTipPanel:OpenCallBack()
	self:UpdateView()
end

function ComposeEquipTipPanel:UpdateView( )

end

function ComposeEquipTipPanel:CloseCallBack(  )

end