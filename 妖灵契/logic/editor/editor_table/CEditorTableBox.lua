CEditorTableBox = class("CEditorTableBox", CBox)

function CEditorTableBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_ArgBox = self:NewUI(1, CEditorNormalArgBox)
	self.m_Label = self:NewUI(2, CLabel)
	self.m_AddBtn = self:NewUI(3, CButton)
	self.m_DelBtn = self:NewUI(4, CButton)
	self.m_ExpandBtn = self:NewUI(5, CButton)
	self.m_IdxBox = self:NewUI(6, CEditorNormalArgBox)
	self.m_TypeBox = self:NewUI(7, CEditorNormalArgBox)
	
	self.m_Childs = {}
	self.m_PosX = 0
	self.m_Key = nil
	self.m_RootView = nil
	self.m_IsTableType = false
	self.m_IsExpand = true
	self.m_AutoHide = true
	self.m_NeedDisplay = true

	self.m_Label:SetText("")
	self.m_ArgBox:SetActive(false)
	self.m_AddBtn:SetActive(false)
	self.m_DelBtn:SetActive(false)
	self.m_ExpandBtn:SetActive(false)
	self.m_TypeBox:SetActive(false)
	self.m_IdxBox:SetActive(false)
	self.m_AddBtn:AddUIEvent("click", callback(self, "OnAdd"))
	self.m_DelBtn:AddUIEvent("click", callback(self, "OnDel"))
	self.m_ExpandBtn:AddUIEvent("click", callback(self, "OnExpand"))

	self.m_IdxBox:SetArgInfo({
			name = "序号",
			format = "number_type"
		})
end

function CEditorTableBox.SetRootView(self, oView)
	self.m_RootView = oView
end

function CEditorTableBox.SetExpand(self, b)
	self.m_ExpandBtn = b
	self:RefreshExpand()
end

function CEditorTableBox.OnExpand(self)
	self.m_IsExpand = not self.m_IsExpand
	self:RefreshExpand()
end

function CEditorTableBox.RefreshExpand(self)
	if not self.m_IsTableType then
		return
	end
	local function visit(node)
		for i, child in ipairs(node.m_Childs) do
			child:SetActive(self.m_IsExpand and child.m_NeedDisplay)
			child.m_IsExpand = self.m_IsExpand
			if self.m_IsExpand then
				child.m_ExpandBtn:SetFlip(enum.UIBasicSprite.Vertically)
			else
				child.m_ExpandBtn:SetFlip(enum.UIBasicSprite.Nothing)
			end
			visit(child)
		end
	end
	visit(self)
	self.m_RootView.m_BoxTable:Reposition()
	if self.m_IsExpand then
		self.m_ExpandBtn:SetFlip(enum.UIBasicSprite.Vertically)
	else
		self.m_ExpandBtn:SetFlip(enum.UIBasicSprite.Nothing)
	end
	
end

function CEditorTableBox.SetTable(self, k, v)
	local function process(oParentBox, k, v)
		local oRootView = oParentBox.m_RootView
		local oBox = oRootView.m_BoxClone:Clone()
		oBox.m_NeedDisplay = (type(k) ~= "string" or key_config[k] ~= nil)
		-- oBox.m_NeedDisplay = true
		oBox:SetActive(self.m_IsExpand and oBox.m_NeedDisplay)
		oBox:SetRootView(oRootView)
		oBox.m_IsTableType = (type(v) == "table")
		oBox:SetPosX(oParentBox.m_PosX+40)
		if type(v) == "table" then
			oBox:SetTable(k, v)
		else
			oBox:SetKeyVal(k, v)
		end

		oParentBox:AddChildNode(oBox)
	end
	for i, vv in ipairs(v) do
		process(self, i, vv)
	end
	local iLen = #v
	local keys = table.keys(v)
	table.sort(keys)
	for i, kk in ipairs(keys) do
		if not (type(kk) == "number" and kk <= iLen) then
			local vvv = v[kk]
			process(self, kk, vvv)
		end
	end
	self.m_Key = k
	self.m_IsTableType = true
	local dKeyConfig = self:GetConfig()
	self.m_Label:SetText(dKeyConfig.name or tostring(k))
	if dKeyConfig.list_type then
		self.m_AddBtn:SetActive(true)
		self.m_DelBtn:SetActive(true)
		self.m_IdxBox:SetActive(true)
		if dKeyConfig.type_arginfo then
			self.m_TypeBox:SetActive(true)
			self.m_TypeBox:SetArgInfo(dKeyConfig.type_arginfo)
			self.m_TypeBox:ResetDefault()
		end
	end
end

function CEditorTableBox.GetConfig(self)
	return key_config[self.m_Key] or {}
end


function CEditorTableBox.GetDefaultChildData(self)
	if self.m_TypeBox:GetActive() then
		local sType = self.m_TypeBox:GetValue()
		return value_default[sType]
	else
		local dKeyConfig = self:GetConfig()
		return dKeyConfig.default_value
	end
end

function CEditorTableBox.OnAdd(self, oBtn)
	local oRootView = self.m_RootView
	local oNew = oRootView.m_BoxClone:Clone()
	oNew:SetActive(true)
	oNew:SetRootView(oRootView)
	local idx = self.m_IdxBox:GetValue()
	local key
	if idx then
		key = idx
	else
		key = #self.m_Childs+1
	end	
	local dDefault = self:GetDefaultChildData()
	oNew.m_AutoHide = false
	oNew.m_IsTableType = (type(dDefault) == "table")
	oNew:SetPosX(self.m_PosX+40)
	oNew.m_AutoHide = true
	if type(dDefault) == "table" then
		oNew:SetTable(key, dDefault)
	else
		oNew:SetKeyVal(key, dDefault)
	end
	local iSibling = 0
	if key == 1 then
		iSibling = self:GetSiblingIndex() + 1
	else
		local oChild = self.m_Childs[key-1]
		iSibling = oChild:GetLastSiblingIndex() + 1
	end
	
	self:AddChildNode(oNew, key)
	oRootView:AddBoxInTable(oNew, iSibling)
end

function CEditorTableBox.GetLastSiblingIndex(self)
	local iMax = 0
	local function visit(node)
		local i = node:GetSiblingIndex()
		if i > iMax then
			iMax = i
		end
		for i, child in ipairs(node.m_Childs) do
			visit(child)
		end
	end
	visit(self)
	return iMax
end

function CEditorTableBox.OnDel(self, oBtn)
	if #self.m_Childs == 0 then
		return
	end
	local idx = self.m_IdxBox:GetValue()
	local key
	if idx then
		key = idx
	else
		key = #self.m_Childs
	end
	local oChild = self.m_Childs[key]
	self:DelChildNode(key)
	self.m_RootView:DelBoxInTable(oChild)
end


function CEditorTableBox.SetConfig(self, dConfig)
	self.m_Config =dConfig
end

function CEditorTableBox.DelChildNode(self,idx)
	if idx then
		table.remove(self.m_Childs, idx)
		for i=idx, #self.m_Childs do
			local oChild = self.m_Childs[i]
			if oChild.m_IsTableType then
				oChild.m_Key = i
				oChild.m_Label:SetText(tostring(i))
			else
				oChild:SetKeyVal(i, oChild.m_ArgBox:GetValue())
			end
		end
	else
		table.remove(self.m_Childs, #self.m_Childs)
	end
end

function CEditorTableBox.AddChildNode(self, oBox, idx)
	if idx then
		table.insert(self.m_Childs, idx, oBox)
		for i=idx+1, #self.m_Childs do
			local oChild = self.m_Childs[i]
			if oChild.m_IsTableType then
				oChild.m_Key = i
				oChild.m_Label:SetText(tostring(i))
			else
				oChild:SetKeyVal(i, oChild.m_ArgBox:GetValue())
			end
		end
	else
		table.insert(self.m_Childs, oBox)
	end
	self.m_ExpandBtn:SetActive(true)
end

function CEditorTableBox.SetPosX(self, iPosX)
	self.m_PosX = iPosX
	self.m_Label:SetLocalPos(Vector3.New(iPosX, 0, 0))
	self.m_ArgBox:SetLocalPos(Vector3.New(iPosX, 0, 0))
	if iPosX >= 120 and self.m_AutoHide then
		self.m_IsExpand = false
		self:RefreshExpand()
	end
end

function CEditorTableBox.SetKeyVal(self, k, v)
	local dInfo = {}
	if type(v) == "number" then
		dInfo["format"] = "number_type"
	elseif type(v) == "string" then
		dInfo["format"] = "string_type"
	elseif type(v) == "boolean" then
		dInfo["select_type"] = "bool_type"
	end
	self.m_Key = k
	local dConfig = self:GetConfig()
	dInfo["name"] = dConfig.name or k
	dInfo["key"] = k
	dInfo["default"] = v
	
	if config.select[k] then
		dInfo["select_type"] = k
	elseif config.select_func[k] then
		dInfo["select_update"] = config.select_func[k]
	elseif dConfig.select_type then
		dInfo["select_type"] = dConfig.select_type 
	elseif dConfig.wrap then
		dInfo["wrap"] = function(s)
			for i, vv in ipairs(config.select[dConfig.wrap]) do
				if vv[1] == s then
					return vv[2]
				end
			end
			return s
		end
	end
	self.m_ArgBox:SetActive(true)
	self.m_ArgBox:SetArgInfo(dInfo)
	self.m_ArgBox:ResetDefault()
end

function CEditorTableBox.GetBoxData(self)
	if self.m_IsTableType then
		local data = {}
		for i, oBox in ipairs(self.m_Childs) do
			local k, v = oBox:GetBoxData()
			data[k] = v
		end
		return self.m_Key, data
	else
		return self.m_ArgBox:GetKey(), self.m_ArgBox:GetValue()
	end
end

return CEditorTableBox