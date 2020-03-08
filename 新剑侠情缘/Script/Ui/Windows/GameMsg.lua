local tbUi = Ui:CreateClass("GameMsg");
tbUi.nTimeTimer = nil
tbUi.buttonState = nil
--[[
	0 ---------- nNpcCount
	1 ---------- screenWidth
	2 ---------- screenHeight
	3 ---------- ResLoading
	4 ---------- JoyOpRate
	5 ---------- apkVersion
	6 ---------- GameVersion
	7 ---------- nNpcCount
	8 ---------- nNpcCount

]]
local buttonState = {
	stop = 1,
	refresh = -1,
}

local intervalFrame = 1

local gameDes = 
{
	[0] = "nNpcCount    ",
	[1] = "screenWidth    ",
	[2] = "screenHeight    ",
	[3] = "ResLoading    ",
	[4] = "JoyOpRate    ",
	[5] = "apkVersion    ",
	[6] = "GameVersion    ",
	[7] = "PFTime    ",
	[8] = "Info    ",
	[9] = "ResInfo    ",
}

function tbUi:OnOpen()
	
	self.buttonState = buttonState.refresh
	--开启定时器刷新界面（每帧一刷）
	self:StartTimer()
end

function tbUi:StartTimer()
	
	self.nTimeTimer = Timer:Register(intervalFrame, function() 
		self:UpdateGameMsgList()
		return true 
	end,self)
end

function tbUi:OnClose()
    self:CloseTimer();
    self.buttonState = nil
end

function tbUi:CloseTimer()
    if self.nTimeTimer then
        Timer:Close(self.nTimeTimer);
        self.nTimeTimer = nil;
    end    
end

function tbUi:UpdateGameMsgList()
	local msgList = Ui.FTDebug.GetDebugInfo() or {}
	local tbMsg = self:ArrangeList(msgList)

	local fnSetItem = function (itemObj, nIdx)
		itemObj.pPanel:Label_SetText("MsgName", tbMsg[nIdx])
	end

	self.GameScrollView:Update(#tbMsg, fnSetItem);
	local buttonText = self.buttonState == buttonState.stop and "Refresh" or "Stop"
	self.pPanel:Label_SetText("Label", buttonText);
end

function tbUi:ArrangeList(msgList)
	local tbMsg = {}
	if msgList then
		local index = 0
		while msgList[index] do
			local des = gameDes[index] .. msgList[index]
			index = index + 1
			tbMsg[index] = des
		end
	end
	return tbMsg
end

tbUi.tbOnClick = {
	Refresh = function (self)

		if self.buttonState == buttonState.stop then
			self:StartTimer()
		else
			self:CloseTimer()
		end
		self.buttonState = - self.buttonState
		self:UpdateGameMsgList()	
	end,
}