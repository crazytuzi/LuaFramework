local CEditorMagicBuildCmdView = class("CEditorMagicBuildCmdView", CViewBase)

function CEditorMagicBuildCmdView.ctor(self, cb)
	CViewBase.ctor(self, "UI/_Editor/EditorMagic/EditorMagicBuildCmdView.prefab", cb)

	self.m_GroupName = "EditorMaigc"
	self.m_ExtendClose = "ClickOut"
end

function CEditorMagicBuildCmdView.OnCreateView(self)
	self.m_ArgsTable = self:NewUI(1, CTable)
	self.m_CmdGrid = self:NewUI(2, CGrid)
	self.m_CmdBoxClone = self:NewUI(3, CBox)
	self.m_CloseBtn = self:NewUI(4, CButton)
	self.m_NormalArgBoxClone = self:NewUI(5, CEditorNormalArgBox)
	self.m_ComplexArgBoxClone = self:NewUI(6, CEditorComplexArgBox)
	self.m_StartTimeBox = self:NewUI(7, CEditorNormalArgBox)
	self.m_ConfirmBtn = self:NewUI(8, CButton)
	self.m_FullScreenObj = self:NewUI(9, CObject)
	self.m_FullBtn = self:NewUI(10, CButton)
	self.m_Contanier = self:NewUI(11, CObject)
	self.m_ScrollView = self:NewUI(12, CScrollView)
	self.m_ClientTagInput = self:NewUI(13, CInput)

	self.m_FullBtn:SetActive(false)
	self.m_IsFullScreen = false
	self.m_AllData = {}
	self.m_OldStartTime = 0
	-- self.m_FullArgs = {}
	self.m_ResetInfo = {}
	self:InitContent()
end

function CEditorMagicBuildCmdView.EditCallback(self, bIsEdit)
	if oBox.m_IsEditing then
		local oBox = self.m_ResetInfo.oBox
		oBox:SetParent(self.m_ResetInfo.parent)
		oBox:SetSiblingIndex(self.m_ResetInfo.sibling)
		oBox:SetLocalPos(self.m_ResetInfo.local_pos)
		oBox:SimulateOnEnable()
		self.m_Contanier:SetActive(true)
		self.m_FullScreenObj:SetActive(false)
		oBox.m_IsEditing = false
		oBtn:SetText("便捷设置")
		self.m_ResetInfo = {}
	else
		oBox.m_IsEditing = true
		self:ArgsBoxFullScreenEdit(oBox)
		oBtn:SetText("退出")
		-- if #self.m_FullArgs == 1 then
		-- 	local oBox = self.m_ArgsTable:GetChild(self.m_FullArgs[1])
		-- 	self:ArgsBoxFullScreenEdit(oBox)
		-- else
		-- 	local function wrap(i)
		-- 		local oBox = self.m_ArgsTable:GetChild(i)
		-- 		local s = oBox.m_NameLabel:GetText()
		-- 		return s
		-- 	end
		-- 	local function sel(i)
		-- 		local oBox = self.m_ArgsTable:GetChild(i)
		-- 		self:ArgsBoxFullScreenEdit(oBox)
		-- 	end
		-- 	CMiscSelectView:ShowView(function(oView)
		-- 		oView:SetData(self.m_FullArgs, sel, wrap)
		-- 	end)
		-- end
	end
end

function CEditorMagicBuildCmdView.ArgsBoxFullScreenEdit(self, oBox)
	self.m_ResetInfo = {oBox= oBox, local_pos = oBox:GetLocalPos(), parent = oBox:GetParent(), sibling=oBox:GetSiblingIndex()}
	oBox:SetParent(self.m_FullScreenObj.m_Transform)
	oBox:SetLocalPos(Vector3.zero)
	oBox:SimulateOnEnable()
	self.m_Contanier:SetActive(false)
	self.m_FullScreenObj:SetActive(true)
	self.m_IsFullScreen = true
	-- self.m_FullBtn:SetText("退出全屏")
end

function CEditorMagicBuildCmdView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnConfirm"))
	-- self.m_FullBtn:AddUIEvent("click", callback(self, "FullScreen"))
	self.m_CmdBoxClone:SetActive(false)
	self.m_NormalArgBoxClone:SetActive(false)
	self.m_ComplexArgBoxClone:SetActive(false)
	self.m_StartTimeBox:SetArgInfo(config.arg.template.start_time)
	local list = {}
	for cmdname, v in pairs(config.cmd) do
		table.insert(list, cmdname)
	end
	table.sort(list, function(s1, s2)
			return config.cmd[s1].sort < config.cmd[s2].sort
		end)
	for i, sCmdName in ipairs(list) do
		local oBox = self.m_CmdBoxClone:Clone()
		oBox:SetActive(true)
		local oBtn = oBox:NewUI(1, CButton)
		oBtn.m_CmdName = sCmdName
		oBtn:SetText(config.cmd[sCmdName].wrap_name)
		oBtn:SetGroup(self.m_CmdGrid:GetInstanceID())
		oBtn:AddUIEvent("click", callback(self, "OnSelCmd"))
		oBox.m_Btn = oBtn
		self.m_CmdGrid:AddChild(oBox) 
	end
end

function CEditorMagicBuildCmdView.SetCmdIdxAndData(self, idx, dOldData)
	self.m_Idx = idx
	if dOldData and dOldData.func_name then
		self.m_AllData[dOldData.func_name] = dOldData
		self.m_OldStartTime = dOldData.start_time
		self:SelectCmd(dOldData.func_name)
	else
		self:SelectCmd("PlayAction")
	end
end

function CEditorMagicBuildCmdView.SelectCmd(self, sCmdName)
	for i, oBox in ipairs(self.m_CmdGrid:GetChildList()) do
		if oBox.m_Btn.m_CmdName == sCmdName then
			self:OnSelCmd(oBox.m_Btn)
			return
		end
	end
end

function CEditorMagicBuildCmdView.ResetArgsData(self, dCmd)
	if self.m_CurCmdName ~= dCmd.func_name then
		return
	end
	self.m_StartTimeBox:SetValue(dCmd.start_time, true, false)
	for i, oArgBox in ipairs(self.m_ArgsTable:GetChildList()) do
		local k = oArgBox:GetKey()
		if k and dCmd.args and dCmd.args[k] ~= nil then
			oArgBox:SetValue(dCmd.args[k], true, false)
		else
			oArgBox:ResetDefault()
		end
	end
end

function CEditorMagicBuildCmdView.SetConfirmCB(self, f)
	self.m_ConfirmCallback = f
end

function CEditorMagicBuildCmdView.OnSelCmd(self, oBtn)
	if self.m_CurCmdName == oBtn.m_CmdName then
		return
	end
	if self.m_CurCmdName then
		self.m_AllData[self.m_CurCmdName] = self:GetCmdData()
	end
	oBtn:SetSelected(true)
	local sCmdName = oBtn.m_CmdName
	self.m_CurCmdName = sCmdName
	self.m_FileArgs = config.cmd[sCmdName].args
	self:RefreshArgTable()
end

function CEditorMagicBuildCmdView.GetShowArgList(self, tArgs, dSetArgs)
	local list = {}
	for i, dArg in ipairs(tArgs) do
		table.insert(list, dArg)
		if dArg.refresh_args == true then
			local key = dSetArgs[dArg.key] or dArg.default
			local sublist = tArgs[key] or {}
			list = table.extend(list, self:GetShowArgList(sublist, dSetArgs))
		end
	end
	return list
end

function CEditorMagicBuildCmdView.RefreshArgTable(self)
	local dSetArgs = self:GetArgsDict()
	local arglist = self:GetShowArgList(self.m_FileArgs, dSetArgs)
	self.m_ArgsTable:Clear()
	-- self.m_FullArgs = {}
	for i, arg in ipairs(arglist) do
		local oBox
		if arg.complex_type then
			oBox = self.m_ComplexArgBoxClone:Clone()
		else
			oBox = self.m_NormalArgBoxClone:Clone()
		end
		oBox:SetEditHideObj(self)
		oBox:SetContextCmdDataFunc(callback(self, "GetCmdData"))
		oBox:SetActive(true)
		oBox:SetArgInfo(arg)
		if dSetArgs[arg.key] ~= nil or arg.isnil == true then
			oBox:SetValue(dSetArgs[arg.key], true, false)
		else
			oBox:ResetDefault()
		end
		self.m_ArgsTable:AddChild(oBox)
		-- if oBox.m_ChangeFunc then
		-- 	table.insert(self.m_FullArgs, i)
		-- end
	end
	-- self.m_FullBtn:SetActive(#self.m_FullArgs > 0)
	self.m_StartTimeBox:SetValue(dSetArgs.start_time or 0, true, false)
	self.m_ScrollView:ResetPosition()
end

function CEditorMagicBuildCmdView.GetCmdData(self)
	local d = {func_name = self.m_CurCmdName, args={}}
	table.update(d, self.m_StartTimeBox:GetArgData())
	for i, oBox in ipairs(self.m_ArgsTable:GetChildList()) do
		table.update(d.args, oBox:GetArgData())
	end
	return d
end

function CEditorMagicBuildCmdView.GetArgsDict(self)
	local dict = {}
	local sCmdName = self.m_CurCmdName
	local dSelData = self.m_AllData[sCmdName]
	if dSelData then
		for k, v in pairs(dSelData.args) do
			dict[k] = v
		end
		dict["start_time"] = dSelData.start_time
	end
	for i, oBox in ipairs(self.m_ArgsTable:GetChildList()) do
		dict[oBox.m_Key] = oBox:GetArgData()[oBox.m_Key]
	end
	return dict
end

function CEditorMagicBuildCmdView.OnConfirm(self)
	local dCmd = self:GetCmdData()
	local sTag = self.m_ClientTagInput:GetText()
	if self.m_ConfirmCallback then
		self.m_ConfirmCallback(self.m_Idx, dCmd, sTag)
	end
	self:CloseView()
end

function CEditorMagicBuildCmdView.SetClientTagInput(self, sCmdTag)
	if type(sCmdTag) == "string" then
		self.m_ClientTagInput:SetText(sCmdTag)
	else
		printc("类型错误")
	end
end

return CEditorMagicBuildCmdView