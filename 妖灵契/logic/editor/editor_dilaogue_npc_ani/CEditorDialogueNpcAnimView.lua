local CEditorDialogueNpcAnimView = class("CEditorDialogueNpcAnimView", CViewBase)

function CEditorDialogueNpcAnimView.ctor(self, cb)
	CViewBase.ctor(self, "UI/_Editor/EditorDialogueNpcAni/EditorDialogueNpcAnimView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	self.m_AniId = nil
	self.m_DeltaTime = 0.25
	self.m_NpcCmdList = {}
	self.m_CmdLists = {}
	self.m_Config = {}
	self.m_CmdListBoxTable = {}
	self.m_DefalutCmdListData = {idx = 1, type = "player", cmdList = {}, delay = 1, startTime = 0}
end

function CEditorDialogueNpcAnimView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CBox)
	self.m_MainBox = self:NewUI(2, CBox)
	self.m_ConfigBox = self:NewUI(3, CBox)

	UITools.ResizeToRootSize(self.m_Container)
	self:InitContent()
end


function CEditorDialogueNpcAnimView.InitContent(self)
	self:InitMainMenuBox()
	self:InitConfigBox()
	self:LoadDealut()

	g_DialogueAniCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlDialogueAniEvent"))
end

function CEditorDialogueNpcAnimView.LoadDealut(self)
	self.m_AniId = IOTools.GetClientData("editor_dialogue_ani_id") or 10000	
	self.m_MainBox.m_IdLabel:SetText( string.format("剧本ID:%d", self.m_AniId))
	local d = g_DialogueAniCtrl:GetFileData(self.m_AniId)
	if d then
		self.m_CmdLists = d.DATA
		self.m_Config = d.CONFIG
	else
		self.m_CmdLists = {}
		self.m_Config = {}
	end
	self:InitCmdList()
end

function CEditorDialogueNpcAnimView.InitMainMenuBox( self )
	self.m_MainBox.m_GeneralConfigBtn = self.m_MainBox:NewUI(1, CButton)
	self.m_MainBox.m_RefreshBtn = self.m_MainBox:NewUI(2, CButton)
	self.m_MainBox.m_LoadBtn = self.m_MainBox:NewUI(3, CButton)
	self.m_MainBox.m_IdLabel = self.m_MainBox:NewUI(4, CLabel)	
	self.m_MainBox.m_CmdTable = self.m_MainBox:NewUI(5, CTable)
	self.m_MainBox.m_CmdListBox = self.m_MainBox:NewUI(6, CEditorDialogueCmdList)
	self.m_MainBox.m_SaveBtn = self.m_MainBox:NewUI(7, CButton)
	self.m_MainBox.m_PreviewBtn = self.m_MainBox:NewUI(8, CButton)
	self.m_MainBox.m_SwitchBtn = self.m_MainBox:NewUI(9, CButton)
	self.m_MainBox.m_MaskWidget = self.m_MainBox:NewUI(10, CBox)
	self.m_MainBox.m_PosLabel = self.m_MainBox:NewUI(11, CLabel)
	self.m_MainBox.m_QuitEditBtn = self.m_MainBox:NewUI(12, CButton)

	self.m_MainBox.m_CmdListBox:SetActive(false)
	self.m_MainBox.m_GeneralConfigBtn:AddUIEvent("click", callback(self, "OnOpenGenealConfig"))
	self.m_MainBox.m_RefreshBtn:AddUIEvent("click", callback(self, "OnMainMenuRefresh"))
	self.m_MainBox.m_LoadBtn:AddUIEvent("click", callback(self, "OnMainMenueLoad"))
	self.m_MainBox.m_SaveBtn:AddUIEvent("click", callback(self, "OnMainMenueSave"))
	self.m_MainBox.m_PreviewBtn:AddUIEvent("click", callback(self, "OnMainMenuePreview"))
	self.m_MainBox.m_SwitchBtn:AddUIEvent("click", callback(self, "OnMainMenueSwitch"))
	self.m_MainBox.m_QuitEditBtn:AddUIEvent("click", callback(self, "OnMainMenueQuitEdit"))
	if g_DialogueAniCtrl:IsDialogueAniRuning(self.m_AniId) then
		self.m_MainBox.m_PreviewBtn:SetText("停止播放")
	else
		self.m_MainBox.m_PreviewBtn:SetText("开始播放")
	end
	self.m_Timer = Utils.AddTimer(callback(self, "Update"), 0.5, 0)
end

function CEditorDialogueNpcAnimView.OnMainMenuRefresh(self)
	printc(" init cmd ")
	self.m_CmdLists = {}
	self:InitCmdList()
end

function CEditorDialogueNpcAnimView.InitCmdList(self)
	if not next(self.m_CmdLists) then
		local cmdList = table.copy(self.m_DefalutCmdListData)
		table.insert(self.m_CmdLists, cmdList)
	end
	self:RefreshAllCmdList()
end

function CEditorDialogueNpcAnimView.RefreshAllCmdList(self)
	for i = 1, #self.m_CmdListBoxTable do
		local oList = self.m_CmdListBoxTable[i] 
		if oList then
			oList:SetActive(false)
		end
	end

	for i = 1, #self.m_CmdLists do
		--printc("InitCmdList >>>>>>>>>>>>>>>>>>  2")
		local oList = self.m_CmdListBoxTable[i] 
		if not oList then
			oList = self.m_MainBox.m_CmdListBox:Clone()
			table.insert(self.m_CmdListBoxTable, oList)
			self.m_MainBox.m_CmdTable:AddChild(oList)
		end
		--printc("InitCmdList >>>>>>>>>>>>>>>>>>  3")
		oList:SetActive(true)
		oList:SetCmdList(self.m_CmdLists[i])
	end
end

function CEditorDialogueNpcAnimView.OnMainMenueLoad(self)
	local function onSel(path)		
		local id = 10000
		for out in string.gmatch(path, "_(%w+)") do
			id = tonumber(out)
		end		
		self.m_AniId = id
		local d = g_DialogueAniCtrl:GetFileData(self.m_AniId)
		if d then
			self.m_CmdLists = d.DATA
			self.m_Config = d.CONFIG
		else
			self.m_CmdLists = {}
			self.m_Config = {}
		end		
		self.m_MainBox.m_IdLabel:SetText( string.format("剧本ID:%d", self.m_AniId))
		self:InitCmdList()
	end	
	local selList = IOTools.GetFiles(self:GetDialogueAniFilePath(), "*.lua", true)
	for i = 1, #selList do
		selList[i] = string.gsub(selList[i], self:GetDialogueAniFilePath().."/", "")
	end
	CEditorDialogueSelectView:ShowView(function(oView)
		oView:SetData(selList, onSel)
	end)
end

function CEditorDialogueNpcAnimView.OnMainMenueSave(self)
	self:RefreshStartTimeAndSort()
	IOTools.SetClientData("editor_dialogue_ani_id", self.m_AniId)
	local t = self:RefreshCmdListsFromLisBox()
	local sFullPath = self:GetDialogueAniFilePath() ..string.format("/dialoge_ani_%d.lua", self.m_AniId)
	local s = "module(...)\n--dialogueani editor build\n"..table.dump(t, "DATA").."\n"..table.dump(self.m_Config, "CONFIG")
	IOTools.SaveTextFile(sFullPath, s)	
	printc(" 保存数据数据 ", g_TimeCtrl:GetTimeYMD())
	table.print({DATA = t, CONFIG = self.m_Config})
	g_NotifyCtrl:FloatMsg(string.format("保存成功  %s", sFullPath))
end

function CEditorDialogueNpcAnimView.GetDialogueAniFilePath(self)
	return IOTools.GetAssetPath(g_DialogueAniCtrl.DialogeAniFilePath)
end

function CEditorDialogueNpcAnimView.RefreshStartTimeAndSort(self)
	self:RefreshStartTime()
	self:RefreshAllCmdList()
	self:SortCmdListIdx()
	self:RefreshAllCmdList()
end

function CEditorDialogueNpcAnimView.OnMainMenuePreview(self)
	printc(string.format(" 预览剧本 %d  ", self.m_AniId))
	if g_DialogueAniCtrl:IsDialogueAniRuning(self.m_AniId) then
		g_DialogueAniCtrl:StopAllDialogueAni()
	else		
		g_DialogueAniCtrl:TestPlayDialgueAni(self.m_AniId)

	end
end

function CEditorDialogueNpcAnimView.OnMainMenueSwitch(self)
	local b = not self.m_MainBox.m_MaskWidget:GetActive()
	self.m_MainBox.m_MaskWidget:SetActive(b)
	if b == true then		
		self.m_MainBox.m_PreviewBtn:SetActive(false)
		self.m_MainBox.m_SaveBtn:SetActive(true)
		self.m_MainBox.m_SwitchBtn:SetText("进入游戏")
		g_DialogueAniCtrl:StopDialgueAni(self.m_AniId)
	else
		self.m_MainBox.m_PreviewBtn:SetActive(true)
		self.m_MainBox.m_SaveBtn:SetActive(false)
		self.m_MainBox.m_SwitchBtn:SetText("返回编辑")
	end
end

function CEditorDialogueNpcAnimView.OnMainMenueQuitEdit(self)
	local args = 
	{
		msg = "是否退出编辑器",
		okCallback = function ( )
			self:CloseView()		
		end,
	}
	g_WindowTipCtrl:SetWindowConfirm(args)
end

function CEditorDialogueNpcAnimView.HandleCmdList(self, idx, key, cmdList)
	if key == "addFrameFront" then
		local cmdList = table.copy(self.m_DefalutCmdListData)
		table.insert(self.m_CmdLists, idx, cmdList)
		self:RefreshStartTimeAndSort()

	elseif key == "addFrameAfter" then
		local cmdList = table.copy(self.m_DefalutCmdListData)
		table.insert(self.m_CmdLists, idx + 1, cmdList)
		self:RefreshStartTimeAndSort()

	elseif key == "delFrame" then
		local args = 
		{
			msg = "是否要删除该行操作",
			okCallback = function ( )
				if #self.m_CmdLists <= 1 then	
					g_NotifyCtrl:FloatMsg(string.format("只剩下一条指令，无法删除"))
				else
					local list = self.m_CmdLists[idx].cmdList
					for i = 1, #list do
						local cmd = list[i]
						if (cmd.func == "AddPlayer" or cmd.func == "AddLayerAniPlayer") then
							g_NotifyCtrl:FloatMsg(string.format("该行指令中存在生成人物指令[ff0000][第%d条][ffffff]，请先单独删除", i))
							return 
						end
					end
					printc("删除成功 ", idx)
					table.remove(self.m_CmdLists, idx)
					self:RefreshAllCmdList()
					self:RefreshStartTimeAndSort()
				end	
			end,
			okStr = "确定",
			cancelStr = "取消",
		}
		g_WindowTipCtrl:SetWindowConfirm(args)
	end
end

function CEditorDialogueNpcAnimView.SortCmdListIdx(self)
	local idx = 1
	local startTime = 0
	for i = 1, #self.m_CmdLists do
		self.m_CmdLists[i].idx = idx
		idx = idx + 1
		self.m_CmdLists[i].startTime = startTime 
		startTime = startTime + self.m_CmdLists[i].delay
	end
end

function CEditorDialogueNpcAnimView.RefreshStartTime(self)
	local idx = 1
	for i = 1, #self.m_CmdListBoxTable do
		local oList = self.m_CmdListBoxTable[i] 
		if oList and oList:GetActive() then
			self.m_CmdLists[idx].delay = oList:GetDelayTime()
			idx = idx + 1
		end
	end
end

--每当listbox指令有变化,都要更新指令
function CEditorDialogueNpcAnimView.RefreshCmdListsFromLisBox(self)
	self.m_CmdLists= {}
	for i = 1, #self.m_CmdListBoxTable do
		if self.m_CmdListBoxTable[i] and self.m_CmdListBoxTable[i]:GetActive() then
			table.insert(self.m_CmdLists, self.m_CmdListBoxTable[i]:GetCmdListData())
		end
	end
	return self.m_CmdLists
end

function CEditorDialogueNpcAnimView.OnCtrlDialogueAniEvent(self, oCtrl)
	if oCtrl.m_EventID == define.DialogueAni.Event.PlayAni 
		or oCtrl.m_EventID == define.DialogueAni.Event.EndAni
		or oCtrl.m_EventID == define.DialogueAni.Event.EndAllAni then

		if g_DialogueAniCtrl:IsDialogueAniRuning(self.m_AniId) then
			self.m_MainBox.m_PreviewBtn:SetText("停止播放")
		else
			self.m_MainBox.m_PreviewBtn:SetText("开始播放")
		end
	end
end

function CEditorDialogueNpcAnimView.InitConfigBox(self)
	self.m_ConfigBox.m_BgSprite = self.m_ConfigBox:NewUI(1, CSprite)	
	self.m_ConfigBox.m_NameInput = self.m_ConfigBox:NewUI(2, CInput)
	self.m_ConfigBox.m_TriggerBtn = self.m_ConfigBox:NewUI(3, CButton)
	self.m_ConfigBox.m_LoopBtn = self.m_ConfigBox:NewUI(4, CButton)
	self.m_ConfigBox.m_LoopTimeInput = self.m_ConfigBox:NewUI(5, CInput)
	self.m_ConfigBox.m_QuitBtn = self.m_ConfigBox:NewUI(6, CButton)
	self.m_ConfigBox.m_MinTriggerLevelInput = self.m_ConfigBox:NewUI(7, CInput)
	self.m_ConfigBox.m_StoryTypeBox = self.m_ConfigBox:NewUI(8, CBox)
	self.m_ConfigBox.m_StoryTypeGrid = self.m_ConfigBox:NewUI(9, CGrid)
	self.m_ConfigBox.m_StoryMapInfoInput = self.m_ConfigBox:NewUI(10, CInput)
	self.m_ConfigBox.m_StoryTypeBox:SetActive(false)

	self.m_ConfigBox.m_StoryTypeGrid.m_LastSelected = 1

	for i = 1, #CDialogueAniCtrl.StoryType do
		local d = CDialogueAniCtrl.StoryType[i]
		local oBox = self.m_ConfigBox.m_StoryTypeBox:Clone()
		oBox.m_Label = oBox:NewUI(1, CLabel)
		oBox.m_SelectSpr = oBox:NewUI(2, CSprite)
		oBox.m_Label:SetText(d.name)
		oBox.m_Type = d.type
		oBox:SetActive(true)		
		if i == self.m_ConfigBox.m_StoryTypeGrid.m_LastSelected then
			oBox.m_SelectSpr:SetActive(true)
		else
			oBox.m_SelectSpr:SetActive(false)
		end
		oBox:AddUIEvent("click", callback(self, "OnSelectedType", i))
		self.m_ConfigBox.m_StoryTypeGrid:AddChild(oBox)
	end

	self.m_ConfigBox:SetActive(false)
	self.m_ConfigBox.m_TriggerBtn:AddUIEvent("click", callback(self, "OnConfigTigger"))
	self.m_ConfigBox.m_LoopBtn:AddUIEvent("click", callback(self, "OnConfigLoop"))
	self.m_ConfigBox.m_QuitBtn:AddUIEvent("click", callback(self, "OnConfigQuit"))
end

function CEditorDialogueNpcAnimView.OnOpenGenealConfig(self)
	self.m_ConfigBox:SetActive(true)
	local name = self.m_Config.name or string.format("剧场动画名_%d", self.m_AniId)
	local isTrigger = self.m_Config.isTrigger or 0
	local isLoop = self.m_Config.isLoop or 0
	local loopTime = self.m_Config.loopTime or 0
	local minTriggerLevel = self.m_Config.minTriggerLevel or 1
	local isStroy = self.m_Config.isStroy or 0
	local mapInfo = self.m_Config.mapInfo or ""

	self.m_ConfigBox.m_NameInput:SetText(name)
	self.m_ConfigBox.m_TriggerBtn:SetSelected(isTrigger == 1)
	self.m_ConfigBox.m_LoopBtn:SetSelected(isLoop == 1)
	self.m_ConfigBox.m_LoopTimeInput:SetText(tostring(loopTime))
	self.m_ConfigBox.m_MinTriggerLevelInput:SetText(tostring(minTriggerLevel))
	self.m_ConfigBox.m_StoryMapInfoInput:SetText(tostring(mapInfo))

	local sel = 1
	for i = 1, self.m_ConfigBox.m_StoryTypeGrid:GetCount() do
		local oBox = self.m_ConfigBox.m_StoryTypeGrid:GetChild(i)
		if oBox and oBox.m_Type == isStroy then
			oBox.m_SelectSpr:SetActive(true)
			sel = i
		else
			oBox.m_SelectSpr:SetActive(false)
		end
	end
	self.m_ConfigBox.m_StoryTypeGrid.m_LastSelected = sel
end

function CEditorDialogueNpcAnimView.OnConfigTigger(self)
	
end

function CEditorDialogueNpcAnimView.OnConfigLoop(self)
	
end

function CEditorDialogueNpcAnimView.OnSelectedType(self, cur)
	local last = self.m_ConfigBox.m_StoryTypeGrid.m_LastSelected
	if cur == last then
		return
	end
	local warp = function (sel)
		for i = 1, self.m_ConfigBox.m_StoryTypeGrid:GetCount() do
			local oBox = self.m_ConfigBox.m_StoryTypeGrid:GetChild(i)
			if sel == i then
				oBox.m_SelectSpr:SetActive(true)
			else
				oBox.m_SelectSpr:SetActive(false)
			end
		end
		self.m_ConfigBox.m_StoryTypeGrid.m_LastSelected = sel
	end

	if CDialogueAniCtrl.StoryType[cur].group == CDialogueAniCtrl.StoryType[last].group or
		(#self.m_CmdLists == 1 and next(self.m_CmdLists[1].cmdList) == nil) then
		warp(cur)
	else
		local args = 
		{
			msg = string.format("不是类型的动画编辑，切换类型将清空动画指令, 是否继续？"),
			okCallback = function ( )
				self.m_CmdLists = {}		
				self:InitCmdList()
				warp(cur)
			end,
			cancelCallback = function ()
			end,
			okStr = "是",
			cancelStr = "否",
		}
		g_WindowTipCtrl:SetWindowConfirm(args)		
	end
end

function CEditorDialogueNpcAnimView.OnConfigQuit(self)
	local name = self.m_ConfigBox.m_NameInput:GetText()
	local isTrigger = self.m_ConfigBox.m_TriggerBtn:GetSelected() and 1 or 0
	local isLoop = self.m_ConfigBox.m_LoopBtn:GetSelected() and 1 or 0
	local loopTime = tonumber(self.m_ConfigBox.m_LoopTimeInput:GetText()) or 9
	local minTriggerLevel = tonumber(self.m_ConfigBox.m_MinTriggerLevelInput:GetText()) or 1
	local isStroy = CDialogueAniCtrl.StoryType[self.m_ConfigBox.m_StoryTypeGrid.m_LastSelected].type
	local mapInfo = tostring(self.m_ConfigBox.m_StoryMapInfoInput:GetText()) or ""
	self.m_Config.name = name
	self.m_Config.isTrigger = isTrigger
	self.m_Config.isLoop = isLoop
	self.m_Config.loopTime = loopTime
	self.m_Config.minTriggerLevel = minTriggerLevel
	self.m_Config.isStroy = isStroy
	self.m_Config.mapInfo = mapInfo

	table.print(self.m_Config)
	self.m_ConfigBox:SetActive(false)
	self:OnMainMenueSave()
end

function CEditorDialogueNpcAnimView.Update(self)
	local oHero = g_MapCtrl:GetHero()
	if Utils.IsExist(oHero) then
		local pos = oHero:GetLocalPos()
		local x = pos.x
		local y = pos.y
		x = math.floor(x * 10 ) / 10
		y = math.floor(y * 10 ) / 10
		local sText = string.format("坐标(%s,%s)", tostring(x), tostring(y))
		self.m_MainBox.m_PosLabel:SetText(sText)
	end
	return true
end

--通用配置   结束

function CEditorDialogueNpcAnimView.Destroy(self )
	local oView = CNotifyView:GetView()
 	if oView and oView.m_OrderBtn then
 		oView.m_OrderBtn:SetActive(true)
 	end	
 	CViewBase.Destroy(self)
end

return CEditorDialogueNpcAnimView
