local CTaskItemQuickUseView = class("CTaskItemQuickUseView", CViewBase)

function CTaskItemQuickUseView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Item/QuickUseView.prefab", cb)
end

function CTaskItemQuickUseView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_IconSprite = self:NewUI(2, CSprite)
	self.m_NameLabel = self:NewUI(3, CLabel)
	self.m_FunctionBtn = self:NewUI(4, CButton)
	self.m_NameBtn = self:NewUI(5, CLabel)
	self.m_ItemBorderSpr = self:NewUI(6, CSprite)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_FunctionBtn:AddUIEvent("click", callback(self, "OnClickFunction"))

	self.m_CallBack = nil
end

function CTaskItemQuickUseView.OnClickFunction(self)
	if self.m_CallBack then
		self.m_CallBack()
	end
	self:CloseView()
end

function CTaskItemQuickUseView.SetQuickUseTaskItem(self, taskThing, taskItem, func)
	self.m_CallBack = func
	self.m_IconSprite:SpriteItemShape(taskItem.icon)
	self.m_NameLabel:SetText(taskItem.name)
	self.m_ItemBorderSpr:SetItemQuality(taskItem.quality or 0)
	self.m_NameBtn:SetText("使用")

	if self.m_QuickItemTimer then
		Utils.DelTimer(self.m_QuickItemTimer)
		self.m_QuickItemTimer = nil
	end
	local function check()
		if g_MapCtrl:IsCurMap(taskThing.map_id) then
			if CTaskHelp.IsTwoPointInRadiusThing(taskThing) then
				return true
			end
		end
		self:CloseView()
		return false
	end
	self.m_QuickItemTimer = Utils.AddTimer(check, 0.5, 0)
end

return CTaskItemQuickUseView