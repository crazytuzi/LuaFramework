local CWarPlayerMagicView = class("CWarPlayerMagicView", CViewBase)

function CWarPlayerMagicView.ctor(self, cb)
	CViewBase.ctor(self, "UI/War/WarPlayerMagicView.prefab", cb)
	self.m_ExtendClose = "Shelter"
end

function CWarPlayerMagicView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_PlayerTexture = self:NewUI(2, CTexture)
	self.m_MagicTexture = self:NewUI(3, CTexture)
	self.m_PlayerTexture2 = self:NewUI(4, CTexture)
	self:InitContent()
end

function CWarPlayerMagicView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Container)
end

function CWarPlayerMagicView.SetData(self, iMagic, iPlayer, alive_time)
	local baseShape = {
		[110] = 110, [113] = 110,
		[120] = 120, [123] = 120, 
		[130] = 130, [133] = 130, 
		[140] = 140, [143] = 140, 
		[150] = 150, [153] = 150, 
		[160] = 160, [163] = 160,
	}
	local path = {
		[110] = "ui_eff_WarPlayerMagicView1",
		[120] = "ui_eff_WarPlayerMagicView1",
		[130] = "ui_eff_WarPlayerMagicView2",
		[140] = "ui_eff_WarPlayerMagicView2",
		[150] = "ui_eff_WarPlayerMagicView3",
		[160] = "ui_eff_WarPlayerMagicView3",
	}
	iPlayer = baseShape[iPlayer]
	self.m_PlayerTexture:LoadPath(
		string.format("Texture/War/pic_hanzhao_player%d.png", iPlayer), 
		function () 
	end)

	self.m_PlayerTexture2:LoadPath(
		string.format("Texture/War/pic_hanzhao_player%d_2.png", iPlayer), 
		function () 
	end)

	self.m_MagicTexture:LoadPath(
		string.format("Texture/War/pic_hanzhao_%d.png", iMagic), 
		function ()
	end)
	self.m_Effect = CEffect.New(string.format("Effect/UI/ui_eff_WarPlayerMagicView/Prefabs/%s.prefab", path[iPlayer]), self:GetLayer(), false)
	self.m_Effect:SetParent(self.m_Container.m_Transform)

	Utils.AddScaledTimer(function ()
		if Utils.IsNil(self) then
			return
		end
		self:CloseView()
	end, alive_time, alive_time)
end

return CWarPlayerMagicView