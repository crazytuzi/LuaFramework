local CEditorMagicCmdListBox = class("CEditorMagicCmdListBox", CBox)

function CEditorMagicCmdListBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_Table = self:NewUI(1, CTable)
	self.m_BoxClone = self:NewUI(2, CBox)
	self.m_AddBtn = self:NewUI(3, CButton)
	self.m_DelBtn = self:NewUI(4, CButton)
	self.m_CopyBtn = self:NewUI(5, CButton)
	self.m_BanBtn = self:NewUI(6, CButton)
	self.m_GroupTable = self:NewUI(7, CTable)
	self.m_MainGroupBtn = self:NewUI(8, CButton)
	self.m_AddGroupBtn = self:NewUI(9, CButton)
	self.m_DelGroupBtn = self:NewUI(10, CButton)
	self.m_GroupNameInput = self:NewUI(11, CButton)
	self.m_TimeInput = self:NewUI(12, CInput)
	self.m_TimeBtn = self:NewUI(13, CButton)
	self.m_TimelineBtn = self:NewUI(14, CButton)
	self.m_ScrollView = self:NewUI(15, CScrollView)

	self.m_StartInput = self:NewUI(16, CInput)
	self.m_EndInput = self:NewUI(17, CInput)
	self.m_CopyMoreBtn = self:NewUI(18, CButton)
	self.m_PasteMoreBtn = self:NewUI(19, CButton)
	self:InitContent()
end

function CEditorMagicCmdListBox.InitContent(self)
	self.m_BoxClone:SetActive(false)
	self.m_AddBtn:AddUIEvent("click", callback(self, "OnAdd"))
	self.m_DelBtn:AddUIEvent("click", callback(self, "OnDel"))
	self.m_CopyBtn:AddUIEvent("click", callback(self, "OnCopy"))
	self.m_BanBtn:AddUIEvent("click", callback(self, "OnBan"))
	self.m_AddGroupBtn:AddUIEvent("click", callback(self, "OnAddGroup"))
	self.m_DelGroupBtn:AddUIEvent("click", callback(self, "OnDelGroup"))
	self.m_MainGroupBtn:SetGroup(self.m_GroupTable:GetInstanceID())
	self.m_MainGroupBtn:AddUIEvent("click", callback(self, "SelectMainGroup"))
	self.m_TimeBtn:AddUIEvent("click", callback(self, "OnTime"))
	self.m_TimelineBtn:AddUIEvent("click", callback(self, "OnTimeline"))
	self.m_CopyMoreBtn:AddUIEvent("click", callback(self, "OnCopyMore"))
	self.m_PasteMoreBtn:AddUIEvent("click", callback(self, "OnPasteMore"))
	self.m_TagList = {}
	self.m_CopyCmds = {}
	self.m_CmdList = {}
	self.m_GroupCmds = {}
	self.m_CurGroup = nil
end

function CEditorMagicCmdListBox.OnCopyMore(self)
	local iStart = tonumber(self.m_StartInput:GetText())
	if iStart then
		local iEnd = tonumber(self.m_EndInput:GetText())
		local list = self:GetShowList()
		local dCmds = {}
		if iEnd then
			for i = iStart, iEnd do
				table.insert(dCmds, list[i])
			end
		else
			dCmds = {list[iStart]}
		end
		self.m_CopyCmds  = table.copy(dCmds)
	end
end

function CEditorMagicCmdListBox.OnPasteMore(self)
	if self.m_CopyCmds and next(self.m_CopyCmds) then
		local list = self:GetShowList()
		for i, dCmd in ipairs(self.m_CopyCmds) do
			table.insert(list, dCmd)
		end
	end
	self:RefreshCmdTable()
	-- self.m_ScrollView:ResetPosition()
end

function CEditorMagicCmdListBox.OnAddGroup(self)
	local text = self.m_GroupNameInput:GetText()
	if text == "" then
		g_NotifyCtrl:FloatMsg("输个名字啊")
	else
		self.m_CurGroup = text
		if not self.m_GroupCmds[text] then
			self.m_GroupCmds[text] = {}
		end
		self:RefreshGroupTable()
		self:RefreshCmdTable()
	end
end

function CEditorMagicCmdListBox.OnDelGroup(self)
	if self.m_CurGroup then
		self.m_GroupCmds[self.m_CurGroup] = nil
		self:RefreshGroupTable()
		self:SelectMainGroup()
	end
end

function CEditorMagicCmdListBox.SetCmds(self, cmds, dGroupCmds)
	self.m_CmdList = cmds
	self.m_GroupCmds = dGroupCmds or {}
	self:RefreshGroupTable()
	self:SelectMainGroup()
end

function CEditorMagicCmdListBox.SelectMainGroup(self)
	self.m_CurGroup = nil
	self.m_MainGroupBtn:SetSelected(true)
	self:RefreshCmdTable()
end

function CEditorMagicCmdListBox.SelectSubGroup(self, groupname)
	self.m_CurGroup = groupname
	self:RefreshCmdTable()
end

function CEditorMagicCmdListBox.GetShowList(self)
	if self.m_CurGroup then
		if not self.m_GroupCmds[self.m_CurGroup] then
			self.m_GroupCmds = {}
		end
		return self.m_GroupCmds[self.m_CurGroup]
	else
		return self.m_CmdList
	end
end

function CEditorMagicCmdListBox.GetTagList(self)
	return self.m_TagList
end

function CEditorMagicCmdListBox.SetTagList(self, list)
	self.m_TagList = list
end

function CEditorMagicCmdListBox.OnTime(self)
	local iTime = tonumber(self.m_TimeInput:GetText())
	if not iTime then
		g_NotifyCtrl:FloatMsg("请输入时间")
		return
	end
	local list = self:GetShowList()
	for i, oCmd in ipairs(list) do
		if not self.m_SelIdx or i >= self.m_SelIdx then
			oCmd.start_time = oCmd.start_time + iTime
		end
	end
	self:RefreshCmdTable()
end

function CEditorMagicCmdListBox.RefreshGroupTable(self)
	self.m_GroupTable:Clear()
	for k, v in pairs(self.m_GroupCmds) do
		local oBtn = self.m_MainGroupBtn:Clone()
		oBtn:SetText(k)
		oBtn:SetGroup(self.m_GroupTable:GetInstanceID())
		oBtn:SetSelected(self.m_CurGroup ~= nil and k==self.m_CurGroup)
		oBtn:AddUIEvent("click", callback(self, "SelectSubGroup", k))
		self.m_GroupTable:AddChild(oBtn)
	end
end

function CEditorMagicCmdListBox.RefreshCmdTable(self)
	-- self.m_ScrollView:ResetPosition()
	self.m_Table:Clear()
	local list = self:GetShowList()
	if #list == 0 then
		return
	end
	if #list > 1 then
		for i, dCmd in ipairs(list) do
			dCmd.idx = i
		end
		local function sortfunc(d1, d2)
			if d1.start_time == d2.start_time then
				return d1.idx < d2.idx
			else
				return d1.start_time < d2.start_time
			end
		end
		table.sort(list, sortfunc)
	end
	for i, dCmd in ipairs(list) do
		dCmd.idx = nil
		local oBox = self:CreateOneBox(i, dCmd)
		self.m_Table:AddChild(oBox)
	end
	local oView = CEditorTimelineView:GetView()
	if oView then
		local lData, iMaxTime =self:GetTimelineData()
		oView:SetTimelineData(iMaxTime, lData)
	end
end

function CEditorMagicCmdListBox.CreateOneBox(self, i, dCmd)
	local oBox = self.m_BoxClone:Clone()
	if i == self.m_SelIdx then
		oBox:SetSelected(true)
		self:RefreshBanBtn()
	end
	oBox:SetActive(true)
	oBox.m_Idx = i
	oBox.m_CmdData = dCmd
	oBox.m_Tag = self.m_TagList[i]
	if type(oBox.m_Tag) ~= "string" then
		oBox.m_Tag = ""
	end
	local oLabel = oBox:NewUI(1, CLabel)
	local oTipBtn = oBox:NewUI(2, CButton)
	oTipBtn.m_Test = true
	oBox.m_BanSpr = oBox:NewUI(3, CSprite)
	local sShort = self:GetCmdShortDesc(i, dCmd)
	oLabel:SetText(sShort)
	oBox.m_BanSpr:SetActive(dCmd.editor_is_ban==true)
	oBox:AddUIEvent("click", callback(self, "OnSelCmd"))
	oBox:AddUIEvent("longpress", callback(self, "OnLongPress"))
	local function hinttext()
		local argsTable = self:GetArgsTable(table.copy(dCmd))
		return oBox.m_Tag.. "\n" ..table.dump(argsTable, "Cmd")
	end
	oTipBtn:SetHint(hinttext, enum.UIAnchor.Side.Right)
	oBox.m_TipBtn = oTipBtn
	oBox:SetGroup(self:GetInstanceID())
	return oBox
end

function CEditorMagicCmdListBox.GetArgsTable(self, dCmd)
	local CmdWrapName = self:GetCmdWrapName(dCmd.func_name)
	local dSetArgs = self:GetArgsDict(dCmd)
	local arglist = self:GetShowArgList(config.cmd[dCmd.func_name].args, dSetArgs)
	local argsTable = {}

	for i, arg in ipairs(arglist) do
		local dic = {}
		if arg.complex_type then
			dic = self:ComplexArg(dSetArgs, arg)
		else
			dic = self:NormalArg(dSetArgs, arg)
		end
		for k,v in pairs(dic) do
			argsTable[k] = v
		end
	end
	return argsTable
end

function CEditorMagicCmdListBox.ComplexArg(self, dSetArgs, dInfo)
	local dic = {}
	local ComplexArgName = dInfo.name
	dic[ComplexArgName] = {}
	local list = config.arg[dInfo.complex_type].sublist
	for i, v in ipairs(list) do
		local dData = self:NormalArg(dSetArgs, config.arg.template[v])
		for k,v in pairs(dData) do
			dic[ComplexArgName][k] = v
		end
	end
	return dic
end

function CEditorMagicCmdListBox.NormalArg(self, dSetArgs, dInfo)
	local dic = {}
	if dInfo.select_type then
		local list = config.select[dInfo.select_type]
		local selectlist = {}
		local wraplist = {}
		for i, v in ipairs(list) do
			table.insert(selectlist, v[1])
			table.insert(wraplist, v[2])
		end
		dInfo.select = selectlist
		dInfo.wrap = wraplist
	elseif type(dInfo.select) == "function" then
		dInfo.select = dInfo.select()
	end
	if type(dInfo.wrap) == "table" then
		dInfo.wrapfunc = function (v) 
							local s = dInfo.wrap[table.index(dInfo.select, v)]
							if s then
								return s
							else
								return v
							end
						end
	elseif type(dInfo.wrap) == "function" then
		dInfo.wrapfunc = dInfo.wrap
	else
		if dInfo.format == "list_type" then
			dInfo.wrapfunc = function(v) return table.concat(v, ",") end
		else
			dInfo.wrapfunc = function(v) return tostring(v) end
		end
	end
	local value
	if dSetArgs[dInfo.key] ~= nil or dInfo.isnil == true then
		value = dInfo.wrapfunc(dSetArgs[dInfo.key])
	else
		value = dInfo.wrapfunc(dInfo.default)
	end
	dic[dInfo.name] = value
	return dic
end

function CEditorMagicCmdListBox.GetCmdWrapName(self, sCmdName)
	if sCmdName then
		return config.cmd[sCmdName].wrap_name 
	else
		return "-WrapName-"
	end
end

function CEditorMagicCmdListBox.GetArgsDict(self, dCmd)
	local dict = {}
	for k, v in pairs(dCmd.args) do
		dict[k] = v
	end
	dict["start_time"] = dCmd.start_time
	return dict
end

function CEditorMagicCmdListBox.GetShowArgList(self, tArgs, dSetArgs)
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

function CEditorMagicCmdListBox.GetCmdShortDesc(self, i, dCmd)
	local dConfig = config.cmd[dCmd.func_name]
	if not dConfig then
		return ""
	end
	local s =string.format("%d %s %s",i, dConfig.wrap_name, dCmd.start_time)
	if not dConfig.short_desc then
		return s
	end
	local function findInChild(t, findkey)
		for k, child in pairs(t) do
			if k == findkey then
				return child
			end
			if type(child) == "table" then
				local v = findInChild(child, findkey)
				if v then
					return v
				end
			end
		end
	end
	for i, k in ipairs(dConfig.short_desc) do
		local v = findInChild(dCmd, k)
		if v then
			local d = config.arg.template[k]
			if d and d.wrap and type(d.wrap) == "function" then
				v = d.wrap(v)
			else
				v = tostring(v)
			end
			s = s.."\n"..tostring(v)
		end
	end
	return s
end

function CEditorMagicCmdListBox.GetDetailDesc(self, i, dCmd)

end

function CEditorMagicCmdListBox.OnSelCmd(self, oBox)
	if self.m_SelIdx == oBox.m_Idx then
		self:ModifyCmd(oBox.m_Idx, oBox.m_CmdData, oBox.m_Tag)
	else
		oBox:SetSelected(true)
		self.m_SelIdx = oBox.m_Idx
		self:RefreshBanBtn()
	end

end

function CEditorMagicCmdListBox.RefreshBanBtn(self)
	local list = self:GetShowList()
	if self.m_SelIdx then
		local dCmd = list[self.m_SelIdx]
		if dCmd.editor_is_ban == true then
			self.m_BanBtn:SetText("取消")
		else
			self.m_BanBtn:SetText("屏蔽")
		end
	end
end

function CEditorMagicCmdListBox.OnAdd(self, oBtn)
	CEditorMagicBuildCmdView:ShowView(function(oView)
			oView:SetConfirmCB(callback(self, "OnCmdViewConfirm"))
	end)
end

function CEditorMagicCmdListBox.OnDel(self, oBtn)
	local list = self:GetShowList()
	if self.m_SelIdx then
		table.remove(list, self.m_SelIdx)
		self:RefreshCmdTable()
	end
end

function CEditorMagicCmdListBox.OnCopy(self, oBtn)
	local list = self:GetShowList()
	if self.m_SelIdx then
		local t = table.copy(list[self.m_SelIdx])
		table.insert(list, self.m_SelIdx+1, t)
		self:RefreshCmdTable()
	end
end

function CEditorMagicCmdListBox.OnBan(self, oBtn)
	local d = self.m_CmdList[self.m_SelIdx]
	if d.editor_is_ban == true then
		d.editor_is_ban = false
	else
		d.editor_is_ban = true
	end
	local oBox = self.m_Table:GetChild(self.m_SelIdx)
	oBox.m_BanSpr:SetActive(d.editor_is_ban==true)
	self:RefreshBanBtn()
end

function CEditorMagicCmdListBox.OnLongPress(self, oBox)
	self:OnSelCmd(oBox)
	self:ModifyCmd(oBox.m_Idx, oBox.m_CmdData, oBox.m_Tag)
end

function CEditorMagicCmdListBox.ModifyCmd(self, i, dCmd, sCmdTag)
	CEditorMagicBuildCmdView:ShowView(function(oView)
			oView:SetClientTagInput(sCmdTag)
			oView:SetCmdIdxAndData(i, dCmd)
			oView:SetConfirmCB(callback(self, "OnCmdViewConfirm"))
	end)
end

function CEditorMagicCmdListBox.OnCmdViewConfirm(self, i, dCmd, sCmdTag)
	local list = self:GetShowList()
	if i then
		list[i] = dCmd
		self.m_TagList[i] = sCmdTag
	else
		table.insert(list, dCmd)
	end
	self:RefreshCmdTable()
end

function CEditorMagicCmdListBox.GetCmdList(self)
	local list = {}
	for i, dCmd in ipairs(self.m_CmdList) do
		if not dCmd.editor_is_ban then
			table.insert(list, dCmd)
		end
	end
	return list
end

function CEditorMagicCmdListBox.GetCmdSaveData(self)
	local list = {}
	local iMagcAnimStartTime
	local iMagcAnimEndTime
	local dAllCmds = {cmd_list = self:GetCmdList()}
	local bAtkStopHit = false
	local bWaitGoBack = false
	local preloads = {}
	for i, dCmd in pairs(dAllCmds.cmd_list) do
		if dCmd.func_name == "MagcAnimStart" then
			iMagcAnimStartTime = dCmd.start_time
		elseif dCmd.func_name == "MagcAnimEnd" then
			iMagcAnimEndTime = dCmd.start_time
		elseif dCmd.func_name == "VicHitInfo" then
			bWaitGoBack = true
		elseif dCmd.func_name == "Move" then
			if dCmd.args.excutor == 'atkobj' then
				bWaitGoBack = true
				bAtkStopHit = true
		end
		elseif dCmd.func_name == "PlayAction" then
			if dCmd.args.excutor == 'atkobj' then
				bAtkStopHit = true
			end
		elseif dCmd.func_name == "LoadUI" then
			table.insert(preloads, dCmd.args.path)
		end
		if dCmd.args.effect and dCmd.args.effect.preload == true then
			table.insert(preloads, dCmd.args.effect.path)
		end
	end
	local dData ={
		cmds = dAllCmds.cmd_list,
		magic_anim_start_time = iMagcAnimStartTime,
		magic_anim_end_time = iMagcAnimEndTime,
		group_cmds = self:GetGroupCmds(),
		wait_goback = bWaitGoBack,
		atk_stophit = bAtkStopHit,
		pre_load_res = preloads,
	}
	return dData
end

function CEditorMagicCmdListBox.GetGroupCmds(self)
	local dGroups = {}
	for k, list in pairs(self.m_GroupCmds) do
		local new = {}
		for i, dCmd in ipairs(list) do
			if not dCmd.editor_is_ban then
				table.insert(new, dCmd)
			end
		end
		dGroups[k] = new
	end
	return dGroups
end

function CEditorMagicCmdListBox.GetTimelineData(self)
	local lData = {}
	local iMaxTime = 0
	for i, dCmd in ipairs(self:GetShowList()) do
		local length_time
		for k, v in pairs(dCmd.args) do
			if string.find(k, "time") or string.find(k, "duration") then
				length_time= length_time or 0
				if type(v) == "number" and v > length_time then
					length_time = v
				end
			end
		end
		local dData = {
			idx = i,
			begin_time = dCmd.start_time,
			desc = self:GetCmdShortDesc(i, dCmd),
			length_time = length_time,
			value_refresh_cb = callback(self, "SetCmdTime"),
		}
		if dCmd.func_name == "End" and dCmd.start_time > iMaxTime then
			iMaxTime = dCmd.start_time
		end
		if dData.length_time then
			local iEnd = dData.begin_time + dData.length_time
			iMaxTime = iEnd > iMaxTime and iEnd or iMaxTime
		end
		table.insert(lData, dData)
	end
	return lData, iMaxTime
end

function CEditorMagicCmdListBox.SetCmdTime(self, idx, stype, time, bRefreshTable)
	local list = self:GetShowList()
	local dCmd = list[idx]
	if not dCmd then
		return
	end
	if stype == "begin" then
		dCmd.start_time = time
	else
		local length = time - dCmd.start_time
		local length_time = -1
		local length_key
		for k, v in pairs(dCmd.args) do
			if string.find(k, "time") or string.find(k, "duration") then
				if v > length_time then
					length_time = v
					length_key = k
				end
			end
		end
		if length_key then
			dCmd.args[length_key] = length
		end
	end
	if bRefreshTable then
		self:RefreshCmdTable()
	end
end

function CEditorMagicCmdListBox.OnTimeline(self)
	local lData, iMaxTime =self:GetTimelineData()
	CEditorTimelineView:ShowView(function(oView)
		oView:SetTimelineData(iMaxTime,lData)
		oView:SetLocalPos(Vector3.New(322, -111, 0))
		end)
end

function CEditorMagicCmdListBox.SetClientTagFilename(self, filename)
	self.m_ClientTagFilename = filename
end

return CEditorMagicCmdListBox