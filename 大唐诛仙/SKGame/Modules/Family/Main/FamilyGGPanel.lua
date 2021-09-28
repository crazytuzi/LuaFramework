-- 家族公告面板
FamilyGGPanel = BaseClass(LuaUI)
function FamilyGGPanel:__init( )
	self.ui = UIPackage.CreateObject("Family","FamilyGGPanel");

	self.txtGG = self.ui:GetChild("txtGG")
	self.btnBJ = self.ui:GetChild("btnBJ")
	self.btnComGG = self.ui:GetChild("btnComGG")
	self.btnClose = self.ui:GetChild("btnClose")

	self.model = FamilyModel:GetInstance()
	self.ctrl = FamilyCtrl:GetInstance()

	self:InitEvent()
end

function FamilyGGPanel:InitEvent()
	self.txtGG.text = self.model.familyNotice or ""
	self:AddListener()
	self:Update()
	self.model:SetFamilyModelShow(false)
end

function FamilyGGPanel:AddListener(  )
	-- 监听事件
	self.txtGG.onChanged:Add( function ()
		-- 设置按钮
		self:SetGGBtn()
	end)

	self.btnComGG.onClick:Add( function ()
		if self.btnComGG.title == "发布" then
			if isExistSensitive(self.txtGG.text) then
				UIMgr.Win_FloatTip("含有敏感词汇")
				return
			end
			self.ctrl:C_ChangeFamilyNotice(self.txtGG.text)
		end
		self:Destroy()
	end)

	self.btnClose.onClick:Add(function ()
		self:Destroy()
	end)
end

function FamilyGGPanel:SetGGBtn()
	if self.txtGG.text ~= self.model.familyNotice and self.txtGG.text ~= "" then
		self.btnComGG.title = "发布"
	else
		self.btnComGG.title = "确定"
	end
end

function FamilyGGPanel:Update()
	self.txtGG.text = self.model.familyNotice 
	if not self.model:IsFamilyLeader() then
		if self.txtGG.text == "" then
			self.txtGG.text = "族长尚未撰写公告"
		end 
		self.txtGG.editable = false
	end
end

-- Dispose use FamilyGGPanel obj:Destroy()
function FamilyGGPanel:__delete()
	self.ctrl = nil
	if self.model then
		self.model:SetFamilyModelShow(true)
		self.model = nil
	end
	GlobalDispatcher:DispatchEvent(EventName.PLAYER_MODEL)
end