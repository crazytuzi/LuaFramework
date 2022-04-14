FactionBattleTipsPanel = FactionBattleTipsPanel or class("FactionBattleTipsPanel",BasePanel)
local FactionBattleTipsPanel = FactionBattleTipsPanel

function FactionBattleTipsPanel:ctor()
	self.abName = "factionBattle"
	self.assetName = "FactionBattleTipsPanel"
	self.layer = "UI"

	self.use_background = true
	self.change_scene_close = true
	self.panel_type = 2
	self.click_bg_close = true

	--self.model = 2222222222222end:GetInstance()
end

function FactionBattleTipsPanel:dctor()
end

function FactionBattleTipsPanel:Open( )
	FactionBattleTipsPanel.super.Open(self)
end

function FactionBattleTipsPanel:LoadCallBack()
	self.nodes = {
		"btn_close","info_btn"
	}
	self:GetChildren(self.nodes)
	--self.bg = GetImage(self.bg)
	self:AddEvent()
	--local res = "faction_battle_big_bg"
	--lua_resMgr:SetImageTexture(self,self.bg, "iconasset/icon_big_bg_"..res, res)
end

function FactionBattleTipsPanel:AddEvent()

	local function call_back(target,x,y)
		self:Close()
	end
	AddButtonEvent(self.btn_close.gameObject,call_back)

	local function call_back(target,x,y)
		lua_panelMgr:GetPanelOrCreate(FactionPanel):Open(5, 1)
		self:Close()
	end
	AddButtonEvent(self.info_btn.gameObject,call_back)
end

function FactionBattleTipsPanel:OpenCallBack()
	self:UpdateView()
end

function FactionBattleTipsPanel:UpdateView( )

end

function FactionBattleTipsPanel:CloseCallBack(  )

end