SiegewarTeachPanel = SiegewarTeachPanel or class("SiegewarTeachPanel",BasePanel)
local SiegewarTeachPanel = SiegewarTeachPanel

function SiegewarTeachPanel:ctor()
	self.abName = "siegewar"
	self.assetName = "SiegewarTeachPanel"
	self.layer = "UI"

	self.use_background = true
	self.change_scene_close = true
	self.panel_type = 2

	--self.model = 2222222222222end:GetInstance()
end

function SiegewarTeachPanel:dctor()
end

function SiegewarTeachPanel:Open( )
	SiegewarTeachPanel.super.Open(self)
end

function SiegewarTeachPanel:LoadCallBack()
	self.nodes = {
		"btnok","btnclose","Text1","Text2","Text3","Text4","bg",
	}
	self:GetChildren(self.nodes)

	self.Text1 = GetText(self.Text1)
	self.Text2 = GetText(self.Text2)
	self.Text3 = GetText(self.Text3)
	self.Text4 = GetText(self.Text4)
	self.bg = GetImage(self.bg)
	self:AddEvent()
	local res = "siegewar_teach_big_bg"
    lua_resMgr:SetImageTexture(self, self.bg, "iconasset/icon_big_bg_" .. res, res, false)
end

function SiegewarTeachPanel:AddEvent()
	local function call_back(target,x,y)
		self:Close()
	end
	AddClickEvent(self.btnok.gameObject,call_back)
	AddClickEvent(self.btnclose.gameObject,call_back)
end

function SiegewarTeachPanel:OpenCallBack()
	self:UpdateView()
end

function SiegewarTeachPanel:UpdateView( )
	self.Text1.text = HelpConfig.siegewar.Tip1
	self.Text2.text = HelpConfig.siegewar.Tip2
	self.Text3.text = HelpConfig.siegewar.Tip3
	self.Text4.text = HelpConfig.siegewar.Tip4
end

function SiegewarTeachPanel:CloseCallBack(  )

end