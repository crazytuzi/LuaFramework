CEditorTableView = class("CEditorTableView", CViewBase)

key_config = {}
value_default  = {}

function CEditorTableView.ctor(self, cb)
	CViewBase.ctor(self, "UI/_Editor/EditorTable/EditorTableView.prefab", cb)
	
	local config = require "logic.editor.editor_table.editor_table_config"
	rawset(_G, "config", config)

	self.m_DepthType = "Notify"
end

function CEditorTableView.OnCreateView(self)
	self.m_BoxClone = self:NewUI(1, CEditorTableBox)
	self.m_BoxTable = self:NewUI(2, CTable)
	self.m_Bg = self:NewUI(3, CSprite)
	self.m_CloseBtn = self:NewUI(4, CButton)
	self.m_SaveBtn = self:NewUI(5, CButton)
	self.m_PreviewBtn = self:NewUI(6, CButton)
	self.m_ShowBtn = self:NewUI(7, CButton)
	self.m_LoadBtn = self:NewUI(8, CButton)
	self.m_ArgBoxTable = self:NewUI(9, CTable)
	self.m_RootBox = nil
	self.m_CurTable = {}
	self.m_UserCache = {}
	self.m_CurTableConfig = {}
	self.m_BoxClone:SetActive(false)
	self.m_SaveData = {}
	self.m_ArgBoxDict = {}
	UITools.ResizeToRootSize(self.m_Bg)
	-- self.m_SaveBtn:AddEffect("Finger")
	self.m_SaveBtn:AddUIEvent("click", callback(self, "OnSave"))
	self.m_PreviewBtn:AddUIEvent("click", callback(self, "OnPreview"))
	self.m_ShowBtn:AddUIEvent("click", callback(self, "OnShow"))
	self.m_LoadBtn:AddUIEvent("click", callback(self, "Refresh"))
	local lKey = {"sel_type", "sel_key"}
	local function initSub(obj, idx)
		local oBox = CEditorNormalArgBox.New(obj)
		local k = lKey[idx]
		local oArgInfo = config.arg.template[k]
		oBox:SetArgInfo(oArgInfo)
		self.m_ArgBoxDict[k] = oBox
		if oArgInfo.change_refresh then
			oBox:SetValueChangeFunc(callback(self, "OnArgChange"))
		end
		return oBox
	end
	self.m_ArgBoxTable:InitChild(initSub)
	Utils.AddTimer(callback(self, "LoadLocalUser"), 0, 0)
end

function CEditorTableView.LoadLocalUser(self)
	local dUserCache = IOTools.GetClientData("editor_table")
	if not dUserCache then
		dUserCache = {
			sel_type = "guide",
			sel_key = "War1"
		}
	end
	if dUserCache then
		self.m_UserCache = dUserCache
		for i, oBox in ipairs(self.m_ArgBoxTable:GetChildList()) do
			local v = dUserCache[oBox:GetKey()]
			if v ~= nil then
				oBox:SetValue(v, true)
			end
		end
	end
	self:Refresh()
end

function CEditorTableView.OnArgChange(self, key)
	local newVal = self.m_ArgBoxDict[key]:GetValue()
	self:SetUserCache(key, newVal)
end

function CEditorTableView.SetUserCache(self, key, val)
	local oldVal = self.m_UserCache[key]
	if not table.equal(oldVal, val) then
		self.m_UserCache[key] = val
		IOTools.SetClientData("editor_table", self.m_UserCache)
		return true
	end
end

function CEditorTableView.AddBoxInTable(self, oBox, iSilbing)
	local function visit(node)
		self.m_BoxTable:AddChild(node, iSilbing)
		iSilbing = iSilbing + 1
		for i, child in ipairs(node.m_Childs) do
			visit(child)
		end
	end
	visit(oBox)
	self.m_BoxTable:Reposition()
end

function CEditorTableView.DelBoxInTable(self, oBox)
	local function visit(node)
		self.m_BoxTable:RemoveChild(node)
		for i, child in ipairs(node.m_Childs) do
			visit(child)
		end
	end
	visit(oBox)
	self.m_BoxTable:Reposition()
end

function CEditorTableView.Refresh(self)
	key_config = config.data_config[self.m_UserCache.sel_type].modify_key
	value_default = config.data_config[self.m_UserCache.sel_type].value_default
	self.m_CurTableConfig = config.data_config[self.m_UserCache.sel_type]
	local path = self.m_CurTableConfig.path
	local key = self.m_UserCache.sel_key
	local sFullPath = IOTools.GetAssetPath(path)
	local s = IOTools.LoadTextFile(sFullPath)
	if not key then
		return
	end

	local sStartIdx, sEndIdx = string.find(s, key.." ?= ?{.-\n}")
	self.m_CurTable.pre_text = string.sub(s, 0, sStartIdx-1)
	self.m_CurTable.after_text = string.sub(s, sEndIdx+1)
	local sTableText = string.sub(s, sStartIdx, sEndIdx)
	local t = loadstring(sTableText.."return "..key)()
	self.m_CurTable.modify_table = t

	self.m_BoxTable:Clear()
	self.m_RootBox = self.m_BoxClone:Clone()
	self.m_RootBox:SetActive(true)
	self.m_RootBox:SetRootView(self)
	self.m_RootBox:SetTable(key, t)
	self:AddBoxInTable(self.m_RootBox, 0)
	self.m_BoxTable:Reposition()
end

function CEditorTableView.OnSave(self)
	local k, v = self.m_RootBox:GetBoxData()
	local t = table.copy(self.m_CurTable.modify_table)
	self:UpdateTable(t, v)
	if self.m_CurTableConfig.before_dump then
		self.m_CurTableConfig.before_dump(t)
	end
	local sTableText = table.dump(t, k)
	sTableText = string.gsub(sTableText, '\n*$', "")
	local s = self.m_CurTable.pre_text..sTableText..self.m_CurTable.after_text
	local path = self.m_CurTableConfig.path
	local sFullPath = IOTools.GetAssetPath(path)
	IOTools.SaveTextFile(sFullPath, s)
	printc("已保存文件-->"..sFullPath)
	self:Refresh()
end

function CEditorTableView.UpdateTable(self, t1, t2)
	for k, v in pairs(t2) do
		local dKeyConfig = self.m_CurTableConfig.modify_key[k]
		if dKeyConfig and dKeyConfig.list_type then
			local temp = {}
			for i, vv in ipairs(v) do
				temp[i] = vv
			end
			t1[k] = temp
		elseif type(v) == "table" then
			t1[k] = self:UpdateTable(t1[k], v)
		else
			t1[k] = v
		end
	end
	return t1
end

function CEditorTableView.OnPreview(self)
	local func = self.m_CurTableConfig.modify_table[self.m_UserCache.sel_key]["preview_func"]
	if func then
		local k, v = self.m_RootBox:GetBoxData()
		local t = table.copy(self.m_CurTable.modify_table)
		self:UpdateTable(t, v)
		if self.m_CurTableConfig.before_dump then
			self.m_CurTableConfig.before_dump(t)
		end
		func(t)
		self.m_Bg:SetActive(false)
		self.m_ShowBtn:SetActive(true)
	else
		g_NotifyCtrl:FloatMsg("无法预览")
	end
end

function CEditorTableView.OnShow(self)
	g_WarCtrl:End()
	g_MapCtrl:ReleaseMap()
	self.m_Bg:SetActive(true)
	self.m_ShowBtn:SetActive(false)
end

return CEditorTableView