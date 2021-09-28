-- 申请面板
ZDApplyPanel = BaseClass(LuaUI)
function ZDApplyPanel:__init()
	self.ui = UIPackage.CreateObject("Team","ZDApplyPanel")
	self.appplyConn = self.ui:GetChild("appplyConn")
	self.btnClear = self.ui:GetChild("btnClear")
	self.clAutoAgree = self.ui:GetChild("clAutoAgree")
	self.btnClose2 = self.ui:GetChild("btnClose2")

	self.model = ZDModel:GetInstance()
	self.items = {}
	self.clAutoAgree.selected = self.model.autoAgree
	self:InitEvent()
end
function ZDApplyPanel:InitEvent()
	self.btnClear.onClick:Add(function()
		ZDCtrl:GetInstance():C_ClearTeamApplyList()
	end)
	self.clAutoAgree.onChanged:Add(function()
		self.model:SetAutoAgree(self.clAutoAgree.selected)
	end)
	self.btnClose2.onClick:Add(function()
		UIMgr.HidePopup()
	end)
	self.handle = self.model:AddEventListener(ZDConst.APPLYLIST_CHANGE, function (  )
		self:Upate() 
	end)
end

function ZDApplyPanel:Upate()
	local list = self.model.applyList or {}
	for i,v in ipairs(self.items) do
		v:RemoveFromParent()
	end
	local item = nil
	for i,v in ipairs(list) do
		item = self.items[i]
		if item then
			item:Update(v)
		else
			item = ZDApplyItem.New(v)
		end
		item:SetXY(3, (i-1)*110 + 5)
		item:AddTo(self.appplyConn)
		self.items[i] = item
	end
end

function ZDApplyPanel:__delete()
	if self.model then
		self.model:RemoveEventListener(self.handle)
	end
	self.model = nil
	if self.items then
		for i,v in ipairs(self.items) do
			v:Destroy()
		end
	end
	self.items = nil
end