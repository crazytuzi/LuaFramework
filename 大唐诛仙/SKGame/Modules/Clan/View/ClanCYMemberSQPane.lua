ClanCYMemberSQPane = BaseClass(LuaUI)
function ClanCYMemberSQPane:__init(root)
	self.ui = UIPackage.CreateObject("Duhufu","CYMemberSQPane")
	self.btnClear = self.ui:GetChild("btnClear")
	self.listConn = self.ui:GetChild("listConn")

	self.txtMinLv = self.ui:GetChild("txtMinLv")
	self.txtMaxLv = self.ui:GetChild("txtMaxLv")
	self.btnLimit = self.ui:GetChild("btnLimit")
	self.btnCheck = self.ui:GetChild("btnCheck")


	self.parent = root
	self.model = ClanModel:GetInstance()
	self.items={}
	self:Layout()
	
	self.btnClear.onClick:Add(function()
		ClanCtrl:GetInstance():C_ClearApplys()
	end)

	local function limitFun()
		local autoJoin = 0
		local min = 0
		local max = 100
		if self.btnCheck.selected then
			autoJoin = 1
		end
		local s1 = string.trim(self.txtMinLv.text)
		local s2 = string.trim(self.txtMaxLv.text)
		if s1=="" then
			s1="0"
		end
		if s2=="" then
			s2="100"
		end
		min = tonumber(s1) or 0
		max = tonumber(s2) or 100

		min = math.max(0,min)
		max = math.max(0,max)
		min = math.min(100,min)
		max = math.min(100,max)

		if min > max then
			local x = max
			max = min
			min = x
		end

		self.txtMinLv.text = min
		self.txtMaxLv.text = max
		local info = self.model.clanInfo
		info.autoJoin = autoJoin
		info.autoMinLv = min
		info.autoMaxLv = max

		ClanCtrl:GetInstance():C_AutoApply(autoJoin, min, max)
	end

	self.btnLimit.onClick:Add(function()
		limitFun()
	end)
	self.btnCheck.onClick:Add(function()
		limitFun()
	end)

end

function ClanCYMemberSQPane:Layout()
	self:AddTo(self.parent)
	self:SetXY(0, 0)
end
function ClanCYMemberSQPane:SetVisible(v, isfirst)
	LuaUI.SetVisible(self, v)
	if v and not isfirst then
		ClanCtrl:GetInstance():C_GetApplyList()
		if not self.applyList then
			self.applyList = self.model:AddEventListener(ClanConst.applyList, function (dataList)
				self.dataList = dataList
				self:Update()
			end)
		end
	else
		self.model:RemoveEventListener(self.applyList)
		self.applyList = nil
	end
end

function ClanCYMemberSQPane:Update()
	local model = self.model
	local num = #self.dataList
	local item
	for i=1,num do
		local data = self.dataList[i]
		item = self.items[i]
		if item then
			item:Update(data)
		else
			item = ClanCYMemberSQItem.New(data)
			item:AddTo(self.listConn)
		end
		item:SetXY(0, (i-1)*75)
		self.items[i] = item
	end
	local more = #self.items - num
	if more > 0 then
		for i=more,1,-1 do
			item = self.items[num+i]
			item:Destroy()
			item = nil
			self.items[num+i]=nil
		end
	end
	self.btnCheck.selected = model.clanInfo.autoJoin==1
	self.txtMinLv.text = model.clanInfo.autoMinLv
	self.txtMaxLv.text = model.clanInfo.autoMaxLv

	if model.job<2 then
		self.txtMinLv.editable =false
		self.txtMaxLv.editable =false
		self.btnCheck.enabled = false
		self.btnClear.visible = false
		self.btnLimit.visible = false
	else
		self.txtMinLv.editable =true
		self.txtMaxLv.editable =true
		self.btnCheck.enabled = true
		self.btnClear.visible = true
		self.btnLimit.visible = true
	end
end

function ClanCYMemberSQPane:__delete()
	if self.model then
		self.model:RemoveEventListener(self.applyList)
		self.model = nil
	end
	self.applyList = nil
	self.dataList = nil
end