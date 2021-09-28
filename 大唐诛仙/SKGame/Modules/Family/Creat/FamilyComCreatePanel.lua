-- 确定创建家族界面
FamilyComCreatePanel = BaseClass(LuaUI)
function FamilyComCreatePanel:__init( familyName )

	self.ui = UIPackage.CreateObject("Family","FamilyComCreatePanel");

	self.familyName = self.ui:GetChild("familyName")
	self.btnCancel = self.ui:GetChild("btnCancel")
	self.btnCreat = self.ui:GetChild("btnCreat")
	
	self.creatName = familyName
	self:InitEvent()
	self:SetText( familyName )
end

function FamilyComCreatePanel:InitEvent()
	self:AddListener()
end

-- 设置面板文字
function FamilyComCreatePanel:SetText( familyName )
	self.familyName.text = StringFormat("[COLOR=#2F7FBB]{0}[/COLOR]吗？", familyName)
end

function FamilyComCreatePanel:AddListener()
	self.btnCancel.onClick:Add( function ()
		self:Destroy()
	end)

	self.btnCreat.onClick:Add( function ()
		FamilyCtrl:GetInstance():C_CreateFamily( self.creatName )
		FamilyModel:GetInstance().familyName = self.creatName
		UIMgr.HidePopup()
	end)

end

-- 布局UI
function FamilyComCreatePanel:Layout()
	self.container:AddChild(self.ui) -- 不改动，注意自行设置self.ui位置
	-- 以下开始UI布局
end

-- Dispose use FamilyComCreatePanel obj:Destroy()
function FamilyComCreatePanel:__delete()

end