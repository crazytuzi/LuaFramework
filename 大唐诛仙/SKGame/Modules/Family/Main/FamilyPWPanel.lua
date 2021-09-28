-- 家族排位面板
FamilyPWPanel = BaseClass(LuaUI)
function FamilyPWPanel:__init()
	self.ui = UIPackage.CreateObject("Family","FamilyPWPanel");

	self.layerHead = self.ui:GetChild("layerHead")
	self.btnCancelGL = self.ui:GetChild("btnCancelGL")
	self.btnComGL = self.ui:GetChild("btnComGL")
	self.btnClose = self.ui:GetChild("btnClose")

	self.familyItems = {}

	self:InitEvent()
	self:Update()
end

function FamilyPWPanel:InitEvent()
	self.model = FamilyModel:GetInstance()
	self.ctrl = FamilyCtrl:GetInstance()
	self:SetBtnClick()
	self:AddHandler()
end

function FamilyPWPanel:Update()
	-- 动态生成排位按钮
	local sortList = self.model.listFamilyPlayer
	self:UpdateItem( sortList )
end

function FamilyPWPanel:UpdateItem( sortList )
	if self.familyItems then
		for i,v in ipairs(self.familyItems) do
			v:Destroy()
		end
	end

	local offy = 5
	SortTableByKey( sortList, "familySortId", true )
	for i,v in ipairs(sortList) do
		local familyItem = FamilyItem.New(self.layerHead)
		local max = #sortList
		familyItem:Update( v, v.familySortId, max)
		familyItem.btnUp.data = i
		familyItem.btnDown.data = i -- v.familySortId
		familyItem:SetXY(0, (familyItem:GetH()+2)*(i-1)+offy)
		self.familyItems[i] = familyItem
	end
end

-- 监听事件
function FamilyPWPanel:SetBtnClick()
	self.btnCancelGL.onClick:Add(function ()
		self.model:ClearSortMembers()
		self:Destroy()
	end)

	self.btnComGL.onClick:Add(function ()
		local changeList = {}
		for i,v in ipairs(self.model.sortIds) do
			table.insert( changeList, v )
		end

		if #changeList > 0 then
			self.ctrl:C_ChangeFamilySortId( changeList )
		end

		self:Destroy()
	end)

	self.btnClose.onClick:Add(function ()
		self.model:ClearSortMembers()
		self:Destroy()
	end)
end

function FamilyPWPanel:AddHandler()
	if not self.changeHandler then
		self.changeHandler = GlobalDispatcher:AddEventListener(EventName.FAMILY_CHANGE, function (  )
			self:Update()
		end)
	end

	if not self.sortHandler then
		self.sortHandler = self.model:AddEventListener(FamilyConst.FAMILY_SORT, function ( sortList )
			self:UpdateItem( sortList )
		end)
	end
end

-- Dispose use FamilyPWPanel obj:Destroy()
function FamilyPWPanel:__delete()
	if self.familyItems then
		for i,v in ipairs(self.familyItems) do
			v:Destroy()
		end
	end

	if self.model then
		self.model:RemoveEventListener(self.sortHandler)
		self.sortHandler = nil
		self.model:SetFamilyModelShow(true)
		self.model = nil
	end

	GlobalDispatcher:RemoveEventListener(self.changeHandler)
	GlobalDispatcher:DispatchEvent(EventName.PLAYER_MODEL)
	self.changeHandler=nil
	self.familyItems = {}
	self.ctrl = nil
end