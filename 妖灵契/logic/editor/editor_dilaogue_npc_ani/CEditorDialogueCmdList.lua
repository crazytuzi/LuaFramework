local CEditorDialogueCmdList = class("CEditorDialogueCmdList", CBox)

CEditorDialogueCmdList.Optition = 
{
	[1] = {name = "前插入帧", key = "addFrameFront"},
	[2] = {name = "后插入帧", key = "addFrameAfter"},
	[3] = {name = "显示隐藏", key = "ShowHideFrame"},
	[4] = {name = "删除该帧", key = "delFrame"},
}

function CEditorDialogueCmdList.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_TitleBox = self:NewUI(1, CBox)
	self.m_TitleBtnGrid = self:NewUI(2, CGrid)
	self.m_IdxLabel = self:NewUI(3, CLabel)
	self.m_DelayInput = self:NewUI(4, CInput)
	self.m_CmdGroupBox = self:NewUI(5, CBox)
	self.m_CmdTable = self:NewUI(6, CTable)
	self.m_TypeLabel = self:NewUI(7, CLabel)
	self.m_CmdBox = self:NewUI(8, CEditorDialogueCmdBox)
	self.m_StartTimerLabel = self:NewUI(9, CLabel)

	self.m_TweenHeight = self:GetComponent(classtype.TweenHeight)

	self.m_CmdListData = {}	
	self.m_IsShow = true
	self.m_CmdBoxList = {}
	self:InitContent()
end

function CEditorDialogueCmdList.InitContent(self)
	self.m_CmdBox:SetActive(false)
	self.m_TitleBtnGrid:InitChild(function(obj, idx)
		local oBox = CButton.New(obj)
		oBox:SetActive(true)
		oBox:SetText(CEditorDialogueCmdList.Optition[idx].name)
		oBox:AddUIEvent("click", callback(self, "OnClickBtn", CEditorDialogueCmdList.Optition[idx].key, idx))
		return oBox
	end)
end

function CEditorDialogueCmdList.AddDefualtCmdList(self)
	local cmdList = {idx = 1, type = "player", cmdList = {}, delay = 0, startTime = 0}
	self:SetCmdList(cmdList)
end

function CEditorDialogueCmdList.SetCmdList(self, cmdList)
	self.m_CmdListData = cmdList
	self.m_IdxLabel:SetText(string.format("序号\n%d", self.m_CmdListData.idx))
	self.m_StartTimerLabel:SetText(string.format("开始时间\n%s", tostring(self.m_CmdListData.startTime)))
	if self.m_CmdListData.type == "player" then
		self.m_TypeLabel:SetText("玩家指令")
	end	
	--printc("CEditorDialogueCmdList.SetCmdList >>>>>>>>>>>>>>>>>>  1")
	self.m_DelayInput:SetText(tostring(self.m_CmdListData.delay))
	for i = 1, #self.m_CmdBoxList do
		if self.m_CmdBoxList[i] then
			self.m_CmdBoxList[i]:SetActive(false)
		end	
	end
	for i = 1, (#self.m_CmdListData.cmdList + 1) do
		--printc("CEditorDialogueCmdList.SetCmdList >>>>>>>>>>>>>>>>>>  2")
		local oBox = self.m_CmdBoxList[i]
		if not oBox then
			oBox = self.m_CmdBox:Clone(self)	
			table.insert(self.m_CmdBoxList, oBox)
			self.m_CmdTable:AddChild(oBox)	
		end
		oBox:SetActive(true)
		local d = self.m_CmdListData.cmdList[i]
		if not d then		
			d = {}
		end
		oBox:SetCmd(d, i)
	end
end

function CEditorDialogueCmdList.OnClickBtn(self, key, idx)
	printc("click key ", key, idx)
	if key == "ShowHideFrame" then
		self.m_IsShow = not self.m_IsShow
		self.m_TweenHeight.from = 200
		self.m_TweenHeight.to = 80

		self.m_TweenHeight:Toggle()
		self.m_CmdGroupBox:SetActive(self.m_IsShow)

	else
	local oView = CEditorDialogueNpcAnimView:GetView()
		if oView then
			oView:HandleCmdList(self.m_CmdListData.idx, key)
		end
	end
end

function CEditorDialogueCmdList.UpdateAddCmd(self, idx)
	local oBox = self.m_CmdBoxList[idx]
	if oBox then
		self.m_CmdListData.cmdList[idx] = oBox.m_CmdData

		--添加新加指令
		local tBox = self.m_CmdBoxList[idx + 1]
		if not tBox then
			tBox = self.m_CmdBox:Clone(self)	
			table.insert(self.m_CmdBoxList, tBox)
			self.m_CmdTable:AddChild(tBox)	
		end
		tBox:SetActive(true)
		tBox:SetCmd({}, idx + 1)
		self.m_CmdTable:Reposition()
	end
	local oView = CEditorDialogueNpcAnimView:GetView()
	if oView then
		oView:RefreshCmdListsFromLisBox()		
	end
end

function CEditorDialogueCmdList.UpdateEditCmd(self, idx)
	local oBox = self.m_CmdBoxList[idx]
	if oBox then
		self.m_CmdListData.cmdList[idx] = oBox.m_CmdData
	end
	local oView = CEditorDialogueNpcAnimView:GetView()
	if oView then
		oView:RefreshCmdListsFromLisBox()
		oView:RefreshStartTimeAndSort()
	end
end

function CEditorDialogueCmdList.UpdateDelCmd(self, cmdIdx, isAddPlayerCmd, playerIdx)
	if self.m_CmdListData.cmdList[cmdIdx] then	
		table.remove(self.m_CmdListData.cmdList, cmdIdx)
		self:SetCmdList(self.m_CmdListData)	
		--如果删除指令是添加玩家的指令，并且动态编号不是最后的id，则重新创建动态id
		if isAddPlayerCmd and playerIdx then			
			local t = g_DialogueAniCtrl:GetAddPlayerNameList()
			local oView = CEditorDialogueNpcAnimView:GetView()
			if oView then
				oView:RefreshCmdListsFromLisBox()
			else
				return
			end
			if #t >= playerIdx then			
				local d = oView.m_CmdLists
				if d and next(d) and #d > 0 then
					for i = 1 , #d do
						if next(d[i].cmdList) then
							for k, cmd in ipairs(d[i].cmdList) do
								--TODO 加入玩家指令判断								
								if cmd.func == "AddPlayer" or cmd.func == "AddLayerAniPlayer" then
									if cmd.args[5][1] > playerIdx then
										table.print(cmd)										
										cmd.args[5][1] = cmd.args[5][1] - 1
									end
								else
									if cmd.args[1][1] > playerIdx then
										table.print(cmd)	
										cmd.args[1][1] = cmd.args[1][1] - 1										
									end
								end
							end
						end
					end					
					--重新刷新所有指令
					oView:RefreshAllCmdList()
					oView:RefreshStartTimeAndSort()
				end
			end
		end		
	end
end

function CEditorDialogueCmdList.GetCmdListData(self)
	self.m_CmdListData.delay = self:GetDelayTime()
	return self.m_CmdListData
end

function CEditorDialogueCmdList.GetDelayTime(self)
	return tonumber(self.m_DelayInput:GetText())
end

return CEditorDialogueCmdList
