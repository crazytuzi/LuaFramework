local CGmConsoleView = class("CGmConsoleView", CViewBase)

function CGmConsoleView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Gm/GmConsoleView.prefab", cb)
	self.m_DepthType = "Top"
end

function CGmConsoleView.OnCreateView(self)
	self.m_ScrollView = self:NewUI(1, CScrollView)
	self.m_WrapContent = self:NewUI(2, CWrapContent)
	self.m_Box = self:NewUI(3, CBox)
	self.m_PosBtn = self:NewUI(4, CButton, true, false)
	self.m_CloseBtn = self:NewUI(5, CButton)
	self.m_ClearBtn = self:NewUI(6, CButton)
	self.m_ConsoleList = {}
	self.m_CurIdx = 1
	self.m_Box:SetActive(false)
	-- self.m_PosBtn:AddUIEvent("drag", callback(self, "OnPos"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ClearBtn:AddUIEvent("click", callback(self, "OnClear"))
	self.m_ScrollView:AddMoveCheck("down", self.m_Table, callback(self, "ShowNewOne"))

	self.m_WrapContent:SetCloneChild(self.m_Box, 
		function(oChild)
			oChild.m_Label = oChild:NewUI(1, CLabel)
			oChild:SetActive(false)
			return oChild
		end)
	self.m_WrapContent:SetRefreshFunc(function(oChild, s)
		if s then

			oChild:SetActive(true)
			local sShort = string.gsub(s, "\n", "", 1)
			if string.len(sShort) > 40 then
				oChild.m_Label:SetText(sShort)
			else
				oChild.m_Label:SetText(sShort)
			end
			oChild.m_Label:SetHint(s, enum.UIAnchor.Side.Left)
		else
			oChild:SetActive(false)
		end
	end)
	self.m_WrapContent:SetData({})
end

function CGmConsoleView.ShowPrint(self)
	CGmFunc.openlog()
	self.m_OldPrint = print
	self.m_OldPrinC = printc
	self.m_OldPrintErr = printerror
	print = function(...)
		local args = {}
		local len = select("#", ...)
		for i=1, len do
			local v = select(i, ...)
			table.insert(args, tostring(v))
		end
		local s = table.concat(args, " ")
		table.insert(self.m_ConsoleList, s)
		self.m_WrapContent:SetData(self.m_ConsoleList)
		self.m_OldPrint(s)
	end
	printc = function(...) print("#Y", ...) end
	printerror = function(...) print("#R", ...) end
end

function CGmConsoleView.RpcResult(self, s)
	table.insert(self.m_ConsoleList, s)
	self.m_WrapContent:SetData(self.m_ConsoleList, true)
	--self:ShowNewOne()
end

function CGmConsoleView.AddPrint(self, s)
	local oBox = self.m_Box:Clone()
	oBox:SetActive(true)
	oBox.m_Label = oBox:NewUI(1, CLabel)
	local sShort = string.gsub(s, "\n", "", 1)
	if string.len(sShort) > 40 then
		oBox.m_Label:SetText(string.sub(sShort, 0, 40).."...")
	else
		oBox.m_Label:SetText(sShort)
	end
	oBox.m_Label:SetHint(s, enum.UIAnchor.Side.Left)
end

function CGmConsoleView.CommonAdd(self, s)

end

function CGmConsoleView.ShowNewOne(self)
	local s = self.m_ConsoleList[self.m_CurIdx]
	if s then
		self:AddPrint(s)
		self.m_CurIdx = self.m_CurIdx + 1
	end
end

function CGmConsoleView.OnPos(self, oBtn, delta)
	local pos = oBtn:GetLocalPos()
	pos.x = pos.x + delta.x
	pos.y = pos.y + delta.y
	oBtn:SetLocalPos(pos)
end

function CGmConsoleView.OnClear(self)
	self.m_ConsoleList = {}
	self.m_WrapContent:Clear()
end

function CGmConsoleView.CloseView(self)
	if self.m_OldPrint then
		print = self.m_OldPrint
		printc= self.m_OldPrinC
		printerror = self.m_OldPrintErr
	end
	self.m_WrapContent:Clear()
	CViewBase.CloseView(self)
end

return CGmConsoleView