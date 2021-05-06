local CEditorDialogueCmdSpawnView = class("CEditorDialogueCmdSpawnView", CViewBase)

CEditorDialogueCmdSpawnView.UIMode = 
{
	Spawn = 1,
	Edit = 2,
}

function CEditorDialogueCmdSpawnView.ctor(self, cb)
	CViewBase.ctor(self, "UI/_Editor/EditorDialogueNpcAni/EditorDialogueCmdSpawnView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	--self.m_GroupName = "main"
end

--上一次生成指令时的缓存
CEditorDialogueCmdSpawnView.LastMain = 1
CEditorDialogueCmdSpawnView.LastSub = 1

function CEditorDialogueCmdSpawnView.OnCreateView(self)
	self.m_MainTypeGrid = self:NewUI(1, CGrid)
	self.m_CreateBtn = self:NewUI(2, CButton)
	self.m_SaveBtn = self:NewUI(3, CButton)
	self.m_QuitBtn = self:NewUI(4, CButton)
	self.m_SubTypeGrid = self:NewUI(5, CGrid)
	self.m_SubTypeBox = self:NewUI(6, CBox)
	self.m_Container = self:NewUI(7, CBox)
	self.m_TitleLabel = self:NewUI(8, CLabel)
	self.m_CmdTable = self:NewUI(9, CTable)
	self.m_CmdInputBox = self:NewUI(10, CBox)
	self.m_PlayerSelectBox = nil
	self.m_PlayerSelectIdx = nil	
	self.m_CmdDesBox = self:NewUI(12, CBox)
	self.m_SubTypeGroup = self:NewUI(13, CBox)
	self.m_CmdDependBox = self:NewUI(14, CBox)
	self.m_HelpBtn = self:NewUI(15, CButton)

	self.m_Callback = nil
	self.m_CmdData = nil
	--选择指令的缓存
	self.m_MainType = CEditorDialogueCmdSpawnView.LastMain	
	self.m_SubType = CEditorDialogueCmdSpawnView.LastSub		
	--编辑指令的缓存
	self.m_CmdMain = 1		
	self.m_CmdSub = 1
	self.m_SubTypeBoxTable = {}
	self.m_UIMode = nil
	self.m_PlayerNameLaberList = {}
	self.m_CmdListIdx = nil  
	self.m_CmdIdx = nil
	self:InitContent()
	self.m_HelpBtn:SetActive(false)
	self.m_LastSubTypeCache = {} --切换maintype时的默认subtype
end

function CEditorDialogueCmdSpawnView.InitContent(self)
	self.m_SubTypeBox:SetActive(false)
	self.m_CmdInputBox:SetActive(false)
	self.m_CmdDesBox:SetActive(false)
	self.m_CmdDependBox:SetActive(false)

	self.m_CreateBtn:AddUIEvent("click", callback(self, "OnClickCreate"))
	self.m_SaveBtn:AddUIEvent("click", callback(self, "OnClickSave"))
	self.m_QuitBtn:AddUIEvent("click", callback(self, "OnClickQuit"))
end

function CEditorDialogueCmdSpawnView.InitPlayerPopupBox(self)
	local playerList = g_DialogueAniCtrl:GetAddPlayerNameList()
	if not self.m_PlayerSelectIdx and next(playerList) and #playerList > 0 then
		self.m_PlayerSelectIdx = 1
	end
	self.m_PlayerSelectBox = self:NewUI(11, CPopupBox, true, CPopupBox.EnumMode.SelectedMode, self.m_PlayerSelectIdx, true)	
	if next(playerList) then

		for i = 1, #playerList do
			self.m_PlayerSelectBox:AddSubMenu(string.format("%s (%d)", playerList[i], i), nil, nil, true)
		end
		self.m_PlayerSelectBox:SetCallback(callback(self, "OnSelectPlayer"))
	end
end

function CEditorDialogueCmdSpawnView.OnSelectPlayer(self, oBox)
	local subMenu = oBox:GetSelectedSubMenu()
	local idx = self.m_PlayerSelectBox:GetSelectedIndex()
	oBox:SetMainMenu(subMenu.m_Label:GetText())
	self.m_PlayerSelectIdx = idx
	if next(self.m_PlayerNameLaberList) then
		for i = 1, #self.m_PlayerNameLaberList do
			if not Utils.IsNil(self.m_PlayerNameLaberList[i]) then
				self.m_PlayerNameLaberList[i]:SetText(subMenu.m_Label:GetText())
			end
		end
	end	
	self:OnSelectCmd(self.m_MainType, self.m_SubType)
end

function CEditorDialogueCmdSpawnView.OnClickCreate(self)
	local cmd = self:SpawnCmdData()
	if not cmd then
		return
	end
	self.m_CmdData = cmd
	CEditorDialogueCmdSpawnView.LastMain = self.m_MainType
	CEditorDialogueCmdSpawnView.LastSub = self.m_SubType
	if self.m_Callback then
		self.m_Callback(self.m_CmdData)
	end
	self:CloseView()
end

function CEditorDialogueCmdSpawnView.OnClickSave(self)
	local cmd = self:SpawnCmdData()
	if not cmd then
		return
	end
	self.m_CmdData = cmd
	if self.m_Callback then
		self.m_Callback(self.m_CmdData)
	end
	self:CloseView()
end

function CEditorDialogueCmdSpawnView.OnClickQuit(self)
	self:CloseView()
end

function CEditorDialogueCmdSpawnView.SpawnCmd(self, cb, args)
	self.m_Callback = cb
	self.m_UIMode = CEditorDialogueCmdSpawnView.UIMode.Spawn
	self.m_CmdListIdx = args.listIdx
	self.m_CmdIdx = args.cmdIdx
	self:InitPlayerPopupBox()
	self:RefreshAll()
end

function CEditorDialogueCmdSpawnView.EditCmd(self, cb, cmd, args)
	self.m_Callback = cb
	self.m_CmdData = cmd  
	if cmd.cmdType == "player" and (cmd.func ~= "AddPlayer" and cmd.func ~= "AddLayerAniPlayer") then
		self.m_PlayerSelectIdx = tonumber(cmd.args[1][1])
	end
	self.m_MainType, self.m_SubType = self:GetTypeIdx(cmd)
	self.m_CmdMain = self.m_MainType
	self.m_CmdSub = self.m_SubType
	self.m_CmdListIdx = args.listIdx
	self.m_CmdIdx = args.cmdIdx	
	self.m_UIMode = CEditorDialogueCmdSpawnView.UIMode.Edit
	self:InitPlayerPopupBox()
	self:RefreshAll()
end

function CEditorDialogueCmdSpawnView.GetTypeIdx(self, cmd)
	local main = 1
	local sub = 1
	for m , cmdList in ipairs(CDialogueAniCtrl.CmdConfig) do
		if next(cmdList.cmdList) then
			for s, oCmd in ipairs(cmdList.cmdList) do
				if oCmd.func == cmd.func then
					main = m
					sub = s
					break
				end
			end
		end
	end
	return main , sub
end

function CEditorDialogueCmdSpawnView.RefreshAll(self)
	if self.m_UIMode == CEditorDialogueCmdSpawnView.UIMode.Edit then
		self.m_CreateBtn:SetActive(false)
		self.m_SaveBtn:SetActive(true)
		self.m_MainTypeGrid:SetActive(false)
	else
		self.m_CreateBtn:SetActive(true)
		self.m_SaveBtn:SetActive(false)
		self.m_MainTypeGrid:SetActive(true)
	end

	self.m_MainTypeGrid:InitChild(function (obj , idx)
		local oBox = CButton.New(obj)
		oBox:SetGroup(self.m_MainTypeGrid:GetInstanceID())
		printc(">>>>>>> ", idx, #CDialogueAniCtrl.CmdConfig)
		oBox:SetText(CDialogueAniCtrl.CmdConfig[idx].mainTypeName)
		if idx == self.m_MainType then
			oBox:SetSelected(true)
		end
		oBox:AddUIEvent("click", callback(self, "OnSelectMainType", idx))
		return oBox
	end)
	self:RefreshSubType()
	self:OnSelectCmd(self.m_MainType, self.m_SubType)
end

function CEditorDialogueCmdSpawnView.RefreshSubType(self)
	local d = CDialogueAniCtrl.CmdConfig[self.m_MainType].cmdList
	for i = 1, #self.m_SubTypeBoxTable do
		local oBox = self.m_SubTypeBoxTable[i]
		if oBox then
			oBox:SetActive(false)
		end
	end	
	for i = 1, #d do
		local oBox = self.m_SubTypeBoxTable[i]
		if not oBox then
			oBox = self.m_SubTypeBox:Clone()
			oBox.m_Label = oBox:NewUI(1, CLabel)
			oBox.m_SelectSpr = oBox:NewUI(2, CSprite)
			table.insert(self.m_SubTypeBoxTable, oBox)
			self.m_SubTypeGrid:AddChild(oBox)
		end
		oBox:SetActive(true)
		oBox.m_Label:SetText(d[i].subTypeName)
		oBox:SetGroup(self.m_SubTypeGrid:GetInstanceID())
		oBox:AddUIEvent("click", callback(self, "OnSelectCmd", self.m_MainType, i))
		oBox.m_SelectSpr:SetActive(false)
		if i == self.m_SubType then
			oBox.m_SelectSpr:SetActive(true)
			oBox:SetSelected(true)
		end
	end
end

function CEditorDialogueCmdSpawnView.OnSelectMainType(self, mainType)
	if mainType ~= self.m_MainType then
		self.m_LastSubTypeCache[self.m_MainType] = self.m_SubType
		if self.m_LastSubTypeCache[mainType] ~= nil then
			self.m_SubType = self.m_LastSubTypeCache[mainType]
		else
			self.m_SubType = 1
		end
		self.m_MainType = mainType
		self:RefreshSubType()
		self:OnSelectCmd(self.m_MainType, self.m_SubType)
	end
end

function CEditorDialogueCmdSpawnView.OnSelectCmd(self, main, sub, oBox)
	if oBox then
		oBox.m_SelectSpr:SetActive(true)
		oBox:SetSelected(true)
	end
	local d = CDialogueAniCtrl.CmdConfig[main].cmdList[sub]
	if not d then
		return
	end
	self.m_PlayerSelectBox:SetActive(false)
	if (d.func ~= "AddPlayer" and d.func ~= "AddLayerAniPlayer") and (main == 1 or main == 4) and next(g_DialogueAniCtrl:GetAddPlayerNameList()) then
		self.m_PlayerSelectBox:SetActive(true)	
	end

	if (d.func == "AddPlayer" or d.func == "AddLayerAniPlayer") and self.m_UIMode == CEditorDialogueCmdSpawnView.UIMode.Edit then
		self.m_SubTypeGroup:SetActive(false)
	else
		self.m_SubTypeGroup:SetActive(true)
	end

	self.m_MainType = main
	self.m_SubType = sub
	local isLocalCmd = false
	if self.m_UIMode == CEditorDialogueCmdSpawnView.UIMode.Edit and self.m_CmdMain == main and self.m_CmdSub == sub then
		isLocalCmd = true
	end

	self.m_TitleLabel:SetText(d.subTypeName)
	self.m_CmdTable:Clear()
	self.m_PlayerNameLaberList = {}

	for i = 1, #d.args do
		local oBox
		if d.args[i].format == "input" or d.args[i].format == "input_string" then
			oBox = self.m_CmdInputBox:Clone()
			oBox.m_Input = oBox:NewUI(1, CInput)
			oBox.m_IdxLabel = oBox:NewUI(2, CLabel)
			oBox.m_KeyLabel = oBox:NewUI(3, CLabel)
			oBox.m_InputLabel = oBox:NewUI(4, CLabel)

			if d.args[i].size then
				oBox.m_Input:SetSize(d.args[i].size.x, d.args[i].size.y)
				oBox.m_InputLabel:SetWidth(d.args[i].size.x - 40)
				oBox.m_InputLabel:SetLocalPos(Vector3.New(d.args[i].size.x / 2, 0, 0))
			end

			oBox.m_IdxLabel:SetText(string.format("参数%d", i))
			oBox.m_KeyLabel:SetText(d.args[i].argName)			

			if isLocalCmd then			
				oBox.m_Input:SetText(g_DialogueAniCtrl:CmdArgsConvertString(self.m_CmdData, i))			
			else
				oBox.m_Input:SetText(tostring(d.args[i].defualt))
			end
			oBox:SetActive(true)
			self.m_CmdTable:AddChild(oBox)
		elseif d.args[i].format == "desLabel" then
			oBox = self.m_CmdDesBox:Clone()
			oBox.m_IdxLabel = oBox:NewUI(1, CLabel)
			oBox.m_KeyLabel = oBox:NewUI(2, CLabel)
			oBox.m_ValueLabel = oBox:NewUI(3, CLabel)

			oBox.m_IdxLabel:SetText(string.format("参数%d", i))
			oBox.m_KeyLabel:SetText(d.args[i].argName)
			--玩家id特殊显示
			if d.args[i].isPlayerIdx then
				local t = g_DialogueAniCtrl:GetAddPlayerNameList()
				if t[self.m_PlayerSelectIdx] then
					oBox.m_ValueLabel:SetText(t[self.m_PlayerSelectIdx])
					table.insert(self.m_PlayerNameLaberList, oBox.m_ValueLabel)		
				else
					oBox.m_ValueLabel:SetText(d.args[i].defualt)
				end	
			elseif d.args[i].isSpawnIdx then
				local t = g_DialogueAniCtrl:GetAddPlayerNameList()  
				if self.m_UIMode == CEditorDialogueCmdSpawnView.UIMode.Edit and (self.m_CmdData.func == "AddPlayer" or self.m_CmdData.func == "AddLayerAniPlayer") then
					-- oBox.m_ValueLabel:SetText(tostring(#t))
					oBox.m_ValueLabel:SetText(g_DialogueAniCtrl:CmdArgsConvertString(self.m_CmdData, i))	
				else
					oBox.m_ValueLabel:SetText(tostring(#t + 1))
				end				
			end				
			oBox:SetActive(true)
			self.m_CmdTable:AddChild(oBox)	

		elseif d.args[i].format == "depend" and d.args[i].dependTable then
			oBox = self.m_CmdDependBox:Clone()
			oBox.m_IdxLabel = oBox:NewUI(1, CLabel)
			oBox.m_KeyLabel = oBox:NewUI(2, CLabel)
			oBox.m_ValueLabel = oBox:NewUI(3, CLabel)	
			oBox.m_SelectBtn = oBox:NewUI(4, CButton)
			oBox.m_KeyLabel:SetText(d.args[i].argName)						

			local defualt = d.args[i].defualt
			
			if isLocalCmd then
				defualt = g_DialogueAniCtrl:CmdArgsConvertString(self.m_CmdData, i) or d.args[i].defualt
			end				
			local t = {}
			--如果是动作列表，则根据每个角色的模型下面的动作文件去读取有动作可选			
			if d.args[i].dependTable == "ActionTables" then
				t.listName = "选择执行动作"
				local modelId = self:GetAddPlayerModelByPlayerIdx(self.m_PlayerSelectIdx)
				if modelId == 0 then
					modelId = g_AttrCtrl.model_info.shape
				end
				local defualtAni = ""
				t.list , defualtAni = self:GetAnimListsByModel(modelId)
				if not t.list[defualt] then
				 	defualt = defualtAni
				end

			elseif d.args[i].dependTable == "BgMusicTables" then
				t.listName = "请选择背景音乐"
				local defualtMusic = ""
				t.list , defualtMusic = self:GetBgMusicTable()
				if not t.list[defualt] then
				 	defualt = defualtMusic
				end

			elseif d.args[i].dependTable == "EffectMusicTables" then
				t.listName = "请选择音效"
				local defualtMusic = ""
				t.list , defualtMusic = self:GetEffectMusicTable()
				if not t.list[defualt] then
				 	defualt = defualtMusic
				end

			elseif d.args[i].dependTable == "CameraFollowTables" then
				t.listName = "请选择跟随对象"
				local defualtTarget = 0
				t.list , defualtTarget = self:GetCameraFollowTargetTable()
				if not t.list[defualt] then
				 	defualt = defualtTarget
				end

			elseif d.args[i].dependTable == "EffectTables" then
				t.listName = "请选择特效"
				local defualtEffect = ""
				t.list , defualtEffect = self:GetEffectTable()
				if not t.list[defualt] then
				 	defualt = defualtEffect
				end

			elseif d.args[i].dependTable == "TalkMusicTables" then
				t.listName = "请选对话语音编号"
				local defualtEffect = ""
				t.list , defualtEffect = self:GetTalkMusicTable()
				if not t.list[defualt] then
				 	defualt = defualtEffect
				end				
			elseif d.args[i].dependTable == "CommonActions" then
				t.listName = "选择通用动作"
				local defualtAni = ""
				t.list , defualtAni = self:GetCommonActions()
				if not t.list[defualt] then
				 	defualt = defualtAni
				end		
			elseif d.args[i].dependTable == "StoryEffectTable" then
				t.listName = "选择剧情特效"
				local defualtAni = ""
				t.list , defualtAni = self:GetStoryEffectTable()
				if not t.list[defualt] then
				 	defualt = defualtAni
				end	
			elseif d.args[i].dependTable == "PivotTable" then
				t.listName = "选择对齐方式"
				local defualtAni = ""
				t.list , defualtAni = self:GetPivotTable()
				if not t.list[tonumber(defualt)] then
				 	defualt = defualtAni
				end		
			elseif d.args[i].dependTable == "SocialEmojiTable" then
				t.listName = "选择社交表情"
				local defualtAni = ""
				t.list , defualtAni = self:GetSocialEmojiTable()
				if not t.list[(defualt)] then
				 	defualt = defualtAni
				end		
			elseif d.args[i].dependTable == "SwitchTextrueTable" then
				t.listName = "选择过度贴图"
				local defualtAni = ""
				t.list , defualtAni = self:GetSwitchTextrueTable()
				if not t.list[(defualt)] then
				 	defualt = defualtAni
				end		
			elseif d.args[i].dependTable == "LayerAniActionTables" then
				t.listName = "选择界面动作"
				local defualtAni = ""
				t.list , defualtAni = self:GetLayerAniActions()
				if not t.list[defualt] then
				 	defualt = defualtAni
				end

			elseif d.args[i].dependTable == "LayerAddPlayerMode" then
				t.listName = "人物出现效果"
				local defualtAni = ""
				t.list , defualtAni = self:GetLayerNpcAddEffectPool()
				if not t.list[defualt] then
				 	defualt = defualtAni
				end															
			else
				t = CDialogueAniCtrl.DependTable[d.args[i].dependTable]				
			end		

			oBox.m_ValueLabel.m_KeyValue = defualt		
			if d.args[i].type == "number" then
				oBox.m_ValueLabel:SetText(t.list[tonumber(defualt)].keyName)				
			else
				oBox.m_ValueLabel:SetText(t.list[tostring(defualt)].keyName)			
			end		
			local vkT = {}
			local list = {}
			for k, v in pairs(t.list) do
				if v.sort then
					list[v.sort] = v.keyName
				else
					table.insert(list, v.keyName)
				end				
				vkT[v.keyName] = k
			end			
			local OnSel = function (sel)
				oBox.m_ValueLabel:SetText(sel)
				oBox.m_ValueLabel.m_KeyValue = vkT[sel]
			end			
			oBox.m_SelectBtn:AddUIEvent("click", 
				function ()
					CEditorDialogueSelectView:ShowView(function(oView)
						oView:SetData(list, OnSel, t.listName)
					end)
				end)	
			oBox:SetActive(true)
			self.m_CmdTable:AddChild(oBox)	
		end
	end
	if d.help and d.help ~= "" then
		self.m_HelpBtn:SetActive(true)
		self.m_HelpBtn:AddHelpStringClick(d.help)
	else
		self.m_HelpBtn:SetActive(false)
	end
end

function CEditorDialogueCmdSpawnView.SpawnCmdData(self)
	local cmd = {}
	local d = CDialogueAniCtrl.CmdConfig[self.m_MainType].cmdList[self.m_SubType]
	if not self:CheckCmdType() then
		return nil	

	elseif self:IsPlayerCmd() and d.func ~= "AddPlayer" and not next(g_DialogueAniCtrl:GetAddPlayerNameList()) then
		g_NotifyCtrl:FloatMsg(string.format("指令生成有错误，还没有添加玩家"))		
		return nil				

	elseif not d then
		g_NotifyCtrl:FloatMsg(string.format("指令生成有错误，请查看是否有[%d][%d]的指令", self.m_MainType, self.m_SubType))
		return nil

	elseif not self:CheckCmdDepend(d.func, d.subTypeName) then
		return nil
	end
	cmd.name = d.subTypeName
	cmd.func = d.func
	cmd.args = {}
	if self.m_MainType == 1 or self.m_MainType == 4 then
		cmd.cmdType = "player"
	elseif self.m_MainType == 2 then
		cmd.cmdType = "setting"
	elseif self.m_MainType == 3 then
		cmd.cmdType = "globalnpcani"
	else
		cmd.cmdType = "player"
	end

	--检测，是否在人物生成之前，就添加该人物的指令
	if self.m_CmdListIdx and self.m_CmdIdx and cmd.cmdType == "player" and (cmd.func ~= "AddPlayer" or cmd.func ~= "AddLayerAniPlayer") then
		local cmdLists = g_DialogueAniCtrl:GetCurEidtCmdLists()
		local row = 1
		local col = 1
		for i = 1, #cmdLists do
			for k = 1, #cmdLists[i].cmdList do
				local tCmd = cmdLists[i].cmdList[k]
				if ((tCmd.func == "AddPlayer" and tCmd.args[5][1] == self.m_PlayerSelectIdx) or (tCmd.func == "AddLayerAniPlayer" and tCmd.args[6][1] == self.m_PlayerSelectIdx) ) then
					row = i
					col = k
					break
				end
			end
		end
		local isCanSpawn = true
		if self.m_CmdListIdx < row then
			isCanSpawn = false
		elseif self.m_CmdListIdx == row and self.m_CmdIdx < col then
			isCanSpawn = false
		end
		if not isCanSpawn then
			g_NotifyCtrl:FloatMsg(string.format("指令生成有错误，请在生成人物指令[ff0000][序号:%d 第%d][ffffff]后，再对该人物进行操作", row, col))
			return nil
		end
	end

	for i = 1, #d.args do
		if d.args[i].format == "input" or d.args[i].format == "input_string" then
			local typeStr = d.args[i].type
			local TypeList
			if d.args[i].format == "input_string" then
				TypeList = {"string"}
			else
				TypeList = string.split(typeStr, ",") 
			end			
			local argStr = self.m_CmdTable:GetChild(i).m_Input:GetText()			
			local argList
			if d.args[i].format == "input_string" then
				argList = {[1]=argStr}
			else
				argList = string.split(argStr, ",")
			end		
			if #TypeList ~= #argList then
				g_NotifyCtrl:FloatMsg(string.format("指令生成有错误，[%s] 中 [%s] 参数设置不对 ", d.subTypeName, d.args[i].argName))
				return nil
			end
			local arg = {}
			for i = 1, #TypeList do
				if TypeList[i] == "number" then
					table.insert(arg, tonumber(argList[i]))
				elseif TypeList[i] == "string" then
					table.insert(arg, tostring(argList[i]))
				end
			end
			table.insert(cmd.args, arg) 
		elseif d.args[i].format == "desLabel" then
			local arg = {}
			if d.args[i].isPlayerIdx then
				table.insert(arg, self.m_PlayerSelectIdx)
				table.insert(arg, g_DialogueAniCtrl:GetAddPlayerNameList()[self.m_PlayerSelectIdx])
			elseif d.args[i].isSpawnIdx then
				local t = g_DialogueAniCtrl:GetAddPlayerNameList()
				if self.m_UIMode == CEditorDialogueCmdSpawnView.UIMode.Edit and (self.m_CmdData.func == "AddPlayer" or self.m_CmdData.func == "AddLayerAniPlayer") then
					table.insert(arg, self.m_CmdData.args[i][1])
				else
					table.insert(arg, #t + 1)
				end							
			end
			table.insert(cmd.args, arg) 	
		elseif d.args[i].format == "depend" then	
			local arg = {}
			if d.args[i].type == "number" then
				local value = tonumber(self.m_CmdTable:GetChild(i).m_ValueLabel.m_KeyValue)
				table.insert(arg, value)
				
			elseif d.args[i].type == "string" then
				local value = tostring(self.m_CmdTable:GetChild(i).m_ValueLabel.m_KeyValue)
				table.insert(arg, value)						
			end
			table.insert(cmd.args, arg) 

		end
	end
	table.print(cmd)
	return cmd
end

function CEditorDialogueCmdSpawnView.GetAddPlayerModelByPlayerIdx(self, idx)
	local model = 0
	local cmdLists = g_DialogueAniCtrl:GetCurEidtCmdLists()
	for i = 1, #cmdLists do
		for k = 1, #cmdLists[i].cmdList do
			local tCmd = cmdLists[i].cmdList[k]			
			if (tCmd.func == "AddPlayer" or tCmd.func == "AddLayerAniPlayer") and tCmd.args[5][1] == idx then
				model = tonumber(tCmd.args[2][1])
				break
			end
		end
	end
	return model
end

function CEditorDialogueCmdSpawnView.GetAnimListsByModel(self, model)
	local list = {}
	local defualt = ""
	local path = string.format("/GameRes/Model/Character/%d/Anim", model)
	local t = IOTools.GetFiles(IOTools.GetAssetPath(path), "*.anim", true)
	for i = 1, #t do
		t[i] = string.gsub(t[i], IOTools.GetAssetPath(path).."/", "")
		t[i] = string.gsub(t[i], ".anim", "")
		t[i] = string.gsub(t[i], model .. "_", "")
	end
	for k, v in pairs(t) do
		list[v] = {keyName = v, sort = k}
		if defualt == "" then
			defualt = v
		end
	end 
	return list, defualt		
end

function CEditorDialogueCmdSpawnView.GetBgMusicTable(self)
	local list = {}
	local defualt = ""
	local path = "/GameRes/Audio/Music"
	local t = IOTools.GetFiles(IOTools.GetAssetPath(path), "*.ogg", true)
	for i = 1, #t do
		t[i] = string.gsub(t[i], IOTools.GetAssetPath(path).."/", "")
		t[i] = string.gsub(t[i], ".ogg", "")
	end
	for k, v in pairs(t) do
		list[v] = {keyName = v, sort = k}
		if defualt == "" then
			defualt = v
		end
	end 
	return list, defualt		
end

function CEditorDialogueCmdSpawnView.GetEffectMusicTable(self)
	local list = {}
	local defualt = ""
	local path = "/GameRes/Audio/Sound"
	local musicFormat = {"*.mp3", "*.wav"}
	local temp = {}
	for k, v in pairs(musicFormat) do
		local t = IOTools.GetFiles(IOTools.GetAssetPath(path), v, true)
		for i = 1, #t do
			t[i] = string.gsub(t[i], IOTools.GetAssetPath(path).."/", "")
			t[i] = string.gsub(t[i], v, "")
			table.insert(temp, t[i])
		end
	end

	for k, v in pairs(temp) do
		list[v] = {keyName = v, sort = k}
		if defualt == "" then
			defualt = v
		end
	end 
	return list, defualt		
end

function CEditorDialogueCmdSpawnView.GetCameraFollowTargetTable(self)
	local list = {}
	list[0]= {keyName = "不跟随",}
	local nameList = g_DialogueAniCtrl:GetAddPlayerNameList()
	if #nameList > 0 then
		for i = 1, #nameList do
			local d = {keyName = nameList[i]..tostring(i)}
			list[i] = d
		end		
	end
	return list, 0	
end

function CEditorDialogueCmdSpawnView.GetEffectTable(self)
	local list = {}
	local defualt = ""
	local path = "/GameRes/Effect/Magic/magic_eff_503/Prefabs"
	local masPath = "/GameRes/"
	local t = IOTools.GetFiles(IOTools.GetAssetPath(path), "*.prefab", true)
	for i = 1, #t do
		--t[i] = string.gsub(t[i], IOTools.GetAssetPath(path).."/", "")
		t[i] = string.gsub(t[i], IOTools.GetAssetPath(masPath), "")
		--t[i] = string.gsub(t[i], ".prefab", "")
	end
	for k, v in pairs(t) do
		list[v] = {keyName = v, sort = k}
		if defualt == "" then
			defualt = v
		end
	end 
	return list, defualt	
end

function CEditorDialogueCmdSpawnView.GetTalkMusicTable(self)
	local list = {}
	local defualt = ""
	local path = "/GameRes/Audio/Sound/Story/"
	local masPath = "/GameRes/Audio/Sound/Story/sound_story_"
	local t = IOTools.GetFiles(IOTools.GetAssetPath(path), "*.wav", true)
	for i = 1, #t do
		t[i] = string.gsub(t[i], IOTools.GetAssetPath(masPath), "")
		t[i] = string.gsub(t[i], ".wav", "")
	end
	list["0"] = {keyName = "0", sort = 1}
	list["-1"] = {keyName = "-1", sort = (#t + 2)}
	defualt = "0"
	for k, v in pairs(t) do
		list[v] = {keyName = v, sort = k + 1}
		if defualt == "" then
			defualt = v
		end
	end 
	return list, defualt	
end

function CEditorDialogueCmdSpawnView.GetStoryEffectTable(self)
	local list = {}
	local defualt = ""
	local path = "/GameRes/Effect/UI/ui_eff_story/Prefabs"
	local masPath = "/GameRes/Effect/UI/ui_eff_story/Prefabs/"
	local t = IOTools.GetFiles(IOTools.GetAssetPath(path), "*.prefab", true)
	for i = 1, #t do
		t[i] = string.gsub(t[i], IOTools.GetAssetPath(masPath), "")
		t[i] = string.gsub(t[i], ".prefab", "")
	end
	for k, v in pairs(t) do
		list[v] = {keyName = v, sort = k}
		if defualt == "" then
			defualt = v
		end
	end 
	return list, defualt	
end

function CEditorDialogueCmdSpawnView.GetCommonActions(self)
	local list = {}
	local defualt = "attack1"
	list = CDialogueAniCtrl.DependTable.CommonActions.list
	return list, defualt	
end

function CEditorDialogueCmdSpawnView.GetLayerAniActions(self)
	local list = {}
	local defualt = "flyout"
	list = CDialogueAniCtrl.DependTable.LayerAniActionTables.list
	return list, defualt	
end

function CEditorDialogueCmdSpawnView.GetLayerNpcAddEffectPool(self)
	local list = {}
	local defualt = "flyout"
	list = CDialogueAniCtrl.DependTable.LayerAddPlayerMode.list
	return list, defualt	
end

function CEditorDialogueCmdSpawnView.GetPivotTable(self)
	local list = {}
	local defualt = 0
	list = CDialogueAniCtrl.DependTable.PivotTable.list
	return list, defualt	
end

function CEditorDialogueCmdSpawnView.GetSocialEmojiTable(self)
	local list = {}
	local defualt = 0
	list = CDialogueAniCtrl.DependTable.SocialEmojiTable.list
	return list, defualt	
end

function CEditorDialogueCmdSpawnView.GetSwitchTextrueTable(self)
	local list = {}
	local defualt = 0
	list = CDialogueAniCtrl.DependTable.SwitchTextrueTable.list
	return list, defualt	
end

function CEditorDialogueCmdSpawnView.CheckCmdType(self)
	local b = false
	local config = g_DialogueAniCtrl:GetCurEidtConfig()
	if config and config.isStroy then
		local d = CDialogueAniCtrl.StoryType[config.isStroy + 1]
		local str = ""
		if d and d.cmdListTable then
			for k, v in ipairs(d.cmdListTable) do
				if self.m_MainType == v then
					return true
				else
					str = str .."["..CDialogueAniCtrl.CmdConfig[v].mainTypeName.."] "
				end
			end
			g_NotifyCtrl:FloatMsg(string.format("指令生成有错误，[%s]模式下只能使用 %s指令集", d.name, str))
		end	
	else
		--如果未保存类型，则默认不检测
		return true
	end
	return b
end

function CEditorDialogueCmdSpawnView.IsPlayerCmd(self)
	local b = false
	if self.m_MainType == 1 or self.m_MainType == 2 then
		b = true
	end
	return b
end

--检测指令的依赖指令
function CEditorDialogueCmdSpawnView.CheckCmdDepend(self, spawnCmd, spawnCmdName)
	local dependCmdTable = 
	{
		["PlayerUISay"] = {
			[1] =  {func = "SetDialogueAniViewActive", name = "显示剧情界面"},
		}
	}
	local depenPool = dependCmdTable[spawnCmd]
	if not depenPool then
		return true
	end

	if self.m_CmdListIdx and self.m_CmdIdx then
		local cmdLists = g_DialogueAniCtrl:GetCurEidtCmdLists()
		local row = 1
		local col = 1
		local isExitDepenCmd = false
		for i = 1, #cmdLists do
			for k = 1, #cmdLists[i].cmdList do
				local tCmd = cmdLists[i].cmdList[k]
				for j = 1, #depenPool do
					printc(" depenPool[i].funcb ", depenPool[j].func, tCmd.func,i, k)
					if depenPool[j].func == tCmd.func then
						isExitDepenCmd = true
						row = i
						col = k
						--break
					end
				end
			end
		end	
		if not isExitDepenCmd then
			if depenPool[1] then
				g_NotifyCtrl:FloatMsg(string.format("指令生成有错误，依赖的指令[ff0000][%s][ffffff]，还未生成", depenPool[1].name))
			end			
			return nil
		end
		--printc(" ??????????  ", row, col, self.m_CmdListIdx, self.m_CmdIdx)
		local isCanSpawn = true
		if self.m_CmdListIdx < row then
			isCanSpawn = false
		elseif self.m_CmdListIdx == row and self.m_CmdIdx < col then
			isCanSpawn = false
		end
		if not isCanSpawn then
			if depenPool[1] then
				g_NotifyCtrl:FloatMsg(string.format("指令生成有错误，请先成指令[ff0000][%s][ffffff]后，再生成[ff0000][%s]", depenPool[1].name, spawnCmdName))
			end			
			return nil
		end
	end	

	return true
end

return CEditorDialogueCmdSpawnView
