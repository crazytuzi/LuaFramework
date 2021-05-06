local CEditorDialogueCmdBox = class("CEditorDialogueCmdBox", CBox)

function CEditorDialogueCmdBox.ctor(self, obj, ownerList)
	CBox.ctor(self, obj)
	self.m_TitleLabel = self:NewUI(1, CLabel)
	self.m_DesLabel = self:NewUI(2, CLabel)
	self.m_DelBtn = self:NewUI(3, CButton)
	self.m_AddLabel = self:NewUI(4, CLabel)

	self.m_CmdData = {}
	self.m_Idx = nil
	self.m_OwnerList = ownerList
	self:InitContent()
end

function CEditorDialogueCmdBox.InitContent(self)
	self:AddUIEvent("click", callback(self, "OnClickCmdBox"))
	self.m_DelBtn:AddUIEvent("click", callback(self, "OnClickDel"))
end

function CEditorDialogueCmdBox.SetCmd(self, cmd, idx)
	self.m_CmdData = cmd
	self.m_Idx = idx
	self:RefreshCmdText()
end

function CEditorDialogueCmdBox.OnClickCmdBox(self)
	printc("click add cmd") 
	local args = {listIdx = self.m_OwnerList.m_CmdListData.idx, cmdIdx = self.m_Idx}
	if next(self.m_CmdData) then
		CEditorDialogueCmdSpawnView:ShowView(function (oView)
			oView:EditCmd(callback(self, "EditCmdCb"), self.m_CmdData, args)
		end)
	else
		CEditorDialogueCmdSpawnView:ShowView(function (oView)
			oView:SpawnCmd(callback(self, "SpawnCmdCb"), args)
		end)
	end
end

function CEditorDialogueCmdBox.SpawnCmdCb(self, cmd)
	self.m_CmdData = cmd
	self:RefreshCmdText()
	if self.m_OwnerList then
		self.m_OwnerList:UpdateAddCmd(self.m_Idx)
	end
end

function CEditorDialogueCmdBox.EditCmdCb(self, cmd)	
	self.m_CmdData = cmd
	self:RefreshCmdText()
	if self.m_OwnerList then
		self.m_OwnerList:UpdateEditCmd(self.m_Idx)
	end
end

function CEditorDialogueCmdBox.OnClickDel(self)
	local args = 
	{
		msg = "是否要删除该行指令",
		okCallback = function ( )
			if self.m_OwnerList then
				if self.m_CmdData.func == "AddPlayer" or self.m_CmdData.func == "AddLayerAniPlayer" then
					local playerIdx = self.m_CmdData.args[5][1]
					local isCanDel = true
					local oView = CEditorDialogueNpcAnimView:GetView()
					if oView and oView.m_CmdLists and next(oView.m_CmdLists) and #oView.m_CmdLists > 0 then
						for i = 1 , #oView.m_CmdLists do
							if next(oView.m_CmdLists[i].cmdList) then
								for k, cmd in ipairs(oView.m_CmdLists[i].cmdList) do
									if cmd.cmdType == "player" and (cmd.func ~= "AddPlayer" and cmd.func ~= "AddLayerAniPlayer") and playerIdx == cmd.args[1][1] then
										isCanDel = false
										g_NotifyCtrl:FloatMsg(string.format("请先删除关联的人物指令[ff0000][序号:%d 第%d条 %s][ffffff]，再删除生成人物指令", i, k, cmd.name))
										break
									end
								end
							end
						end
					end
					if isCanDel then
						self.m_OwnerList:UpdateDelCmd(self.m_Idx, true, playerIdx)	
					end
				else
					self.m_OwnerList:UpdateDelCmd(self.m_Idx)	
				end			
			end
		end,
		okStr = "确定",
		cancelStr = "取消",
	}
	g_WindowTipCtrl:SetWindowConfirm(args)
end

function CEditorDialogueCmdBox.RefreshCmdText(self)
	local d = self.m_CmdData
	self.m_TitleLabel:SetActive(false)
	self.m_DesLabel:SetActive(false)
	self.m_DelBtn:SetActive(false)
	self.m_AddLabel:SetActive(false)

	if next(d) then
		self.m_TitleLabel:SetText(d.name)
		self.m_DesLabel:SetText(g_DialogueAniCtrl:CmdArgsConvertString(d))
		self.m_TitleLabel:SetActive(true)
		self.m_DesLabel:SetActive(true)
		self.m_DelBtn:SetActive(true)
	else
		self.m_AddLabel:SetActive(true)
	end
end

return CEditorDialogueCmdBox
