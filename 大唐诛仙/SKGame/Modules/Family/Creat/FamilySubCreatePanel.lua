-- 家族创建二次确认面板
FamilySubCreatePanel = BaseClass(LuaUI)
function FamilySubCreatePanel:__init( ... )
	self.ui = UIPackage.CreateObject("Family","FamilySubCreatePanel");
	
	self.inputFName = self.ui:GetChild("inputFName")
	self.btnCreatPay = self.ui:GetChild("btnCreatPay")
	self.btnCancelPay = self.ui:GetChild("btnCancelPay")

	self.model = FamilyModel:GetInstance()
	self:InitEvent()
end

function FamilySubCreatePanel:InitEvent()
	self.btnCreatPay.title = StringFormat("{0}创建", GetCfgData("constant"):Get(3).value)
	self.inputFName.text = ""
	self:AddListener()
	self:SetBtnState()
	-- 玩家信息变化更新按钮
	self.playerHandler = GlobalDispatcher:AddEventListener(EventName.MAINPLAYER_UPDATE, function ( key, value, pre )
		self:SetBtnState()
	end)
end

function FamilySubCreatePanel:AddListener()
	-- 确定创建 关闭面板 打开二级确认面板
	self.btnCreatPay.onClick:Add( function ()
		local familyName = self.inputFName.text
		if isExistSensitive(familyName) then
			UIMgr.Win_FloatTip("含有敏感词汇")
			return
		end
		if familyName == "" then UIMgr.Win_FloatTip("请输入家族名称") return end
		self.comCreatePanel = FamilyComCreatePanel.New( familyName )
		UIMgr.ShowCenterPopup(self.comCreatePanel)
	end)

	-- 取消创建 关闭面板
	self.btnCancelPay.onClick:Add( function ()
		self:Destroy()
	end)
end

function FamilySubCreatePanel:SetBtnState()
	self.btnCreatPay.grayed = not self.model:IsGoldEnough()
	self.btnCreatPay.touchable = self.model:IsGoldEnough()
end

-- Dispose use FamilySubCreatePanel obj:Destroy()
function FamilySubCreatePanel:__delete()
	self.model = nil
	GlobalDispatcher:RemoveEventListener(self.playerHandler)
	self.playerHandler = nil
end