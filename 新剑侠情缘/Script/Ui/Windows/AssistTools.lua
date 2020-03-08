local tbUi = Ui:CreateClass("AssistTools");

tbUi.curWin = nil

local toolsType = 
{
	Commander = 1,
	LogMsg = 2,
	GameMsg = 3,
}

local tools = {
	[toolsType.Commander] = "Commander",
	[toolsType.LogMsg] = "LogMsg",
	[toolsType.GameMsg] = "GameMsg",
}

local toolNames = {
	[toolsType.Commander] = "GM",
	[toolsType.LogMsg] = "LogMsg",
	[toolsType.GameMsg] = "GameMsg",
}

function tbUi:OnOpen()
	self.curWin = tools[toolsType.Commander]
	self:UpdateTabList()
end

function tbUi:OnOpenEnd()
	self:ShowWin()
end

function tbUi:ShowWin()
	if not self.curWin then
		return 
	end
	local legalWin = self:CheckWin()
	if not legalWin then
		print("intent to open illegal win")
		return
	end
	self:CloseAllToolsWin()
	Ui:OpenWindow(self.curWin)
end

function tbUi:CloseAllToolsWin()
	for _,szWinName in pairs(tools) do
		Ui:CloseWindow(szWinName)
	end
end

function tbUi:Close()
	self:CloseAllToolsWin()
	Ui:CloseWindow("AssistTools")
end

function tbUi:CheckWin()
	for _,szWinName in pairs(tools) do
		if self.curWin == szWinName then
			return true
		end
	end
end

function tbUi:UpdateTabList()
	local fnSetItem = function (itemObj, nIdx)
		local fnCall = function () 
			self.curWin = tools[nIdx]
			self:ShowWin()
			self:UpdateTabList()
		end
		itemObj.pPanel:Label_SetText("toolName", toolNames[nIdx])
		local icon = tools[nIdx] == self.curWin and "BtnListThirdPress" or "BtnListThirdNormal"
		itemObj.pPanel:Sprite_SetSprite("Sprite", icon);
		itemObj.pPanel.OnTouchEvent = fnCall
	end
	self.TabScrollView:Update(#tools, fnSetItem);
end

tbUi.tbOnClick = {
	BtnClose = function (self)
		self:Close()	
	end,
	BtnLoad = function ()
		me.CenterMsg("LogProfile")
		Ui.FTDebug.LogResourceProfile()
	end,
	BtnFree = function ()
		me.CenterMsg("Free")
		Ui.FTDebug.FreeResource()
	end,
}