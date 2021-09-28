ConsumPanel = BaseClass(LuaUI)
function ConsumPanel:__init( root )
	self.URL = "ui://bveep9rgsjzg7";
	self:Layout(root)
	self:InitEvent()
	self:Config()
	self.isInited = true
end

function ConsumPanel:InitEvent()
	self.itemCount = {}
	-- 获取数据
	-- RechargeController:GetInstance():C_GetPayActData()
end

-- start
function ConsumPanel:Config()
	self.model = ConsumModel:GetInstance()
	self:SetCumulate()
	self:SetItem()
	self:AddHandler()
end

function ConsumPanel:SetCumulate()
	local totalRecharge = self.model:GetTotalRecharge()
	self.cumulate.text = StringFormat("{0}元宝", totalRecharge)
end

function ConsumPanel:AddHandler()
	self.handle0 = self.model:AddEventListener(ConsumConst.RefreshPanel, function ()
		if self.isInited then
			self:Update()
		end
	end)
end

function ConsumPanel:SetItem()
	local accVo = self.model:GetAccVo()
	local idList = self.model:GetIdList()
	if idList then
		for i, v in ipairs(idList) do
			local item = ConsumItem.New(self.itemList)
			item:InitData(accVo[v])
			self.itemCount[i] = item
		end
	end
end

function ConsumPanel:Update()
	self:SetCumulate()
	for i,v in ipairs(self.itemCount) do
		v:Destroy()
	end
	self.itemCount = {}
	self:SetItem()
end

-- wrap UI to lua
function ConsumPanel:Layout(root)
	self.ui = self.ui or UIPackage.CreateObject("AccConsum","ConsumPanel");
	root:AddChild(self.ui)
	self.cumulate = self.ui:GetChild("cumulate")
	self.itemList = self.ui:GetChild("itemList")
end

-- Combining existing UI generates a class
function ConsumPanel.Create( ui, ...)
	return ConsumPanel.New(ui, "#", {...})
end

function ConsumPanel:__delete()
	self.model:RemoveEventListener(self.handle0)
	for i,v in ipairs(self.itemCount) do
		v:Destroy()
	end
	self.itemCount = {}
	self.isInited = false
	self.model = nil
end