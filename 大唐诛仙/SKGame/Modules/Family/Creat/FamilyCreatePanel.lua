-- 创建家族面板
FamilyCreatePanel = BaseClass(LuaUI)
function FamilyCreatePanel:__init( root )
	self.ui = UIPackage.CreateObject("Family","FamilyCreatePanel");
	self.btnFamily = self.ui:GetChild("btnFamily")
	root:AddChild(self.ui)
	self:SetXY(133,100)
	self.isInited = true
	self:InitEvent()
end

function FamilyCreatePanel:InitEvent()
	self:AddListener()
	self:Update()
	-- 玩家信息变化更新按钮
	self.playerHandler = GlobalDispatcher:AddEventListener(EventName.MAINPLAYER_UPDATE, function (key, value, pre)
		self:Update()
	end)
end

function FamilyCreatePanel:AddListener()
	-- 点击事件
	self.btnFamily.onClick:Add( function ()
		self.subCreatPanel = FamilySubCreatePanel.New()
		UIMgr.ShowCenterPopup(self.subCreatPanel)
	end)
end

function FamilyCreatePanel:Update()
	self.btnFamily.grayed = not FamilyModel:GetInstance():IsLevelEnough()
	self.btnFamily.touchable = FamilyModel:GetInstance():IsLevelEnough()
end

-- Dispose use FamilyCreatePanel obj:Destroy()
function FamilyCreatePanel:__delete()
	self.playerHandler = nil
	GlobalDispatcher:RemoveEventListener(self.playerHandler)
	self.isInited = false
end