---------------------------------------------------------------
--数字键盘界面


---------------------------------------------------------------
local CItemNumberKeyBoardView = class("CItemNumberKeyBoardView", CViewBase)

CItemNumberKeyBoardView.Key =
{
	"1", "2", "3", "del",
	"4", "5", "6", "0",
	"7", "8", "9", "ok"
}

function CItemNumberKeyBoardView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Item/ItemNumberKeyBoardView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "ClickOut"
	self.m_MinNumber = 0
	self.m_MaxNumber = 99
	self.m_Number = 10
	self.m_SyncFunc = nil
	self.m_SyncOjb = nil
	self.m_FirstNumberClick = false
end

function CItemNumberKeyBoardView.OnCreateView(self)
	self.m_ViewBg = self:NewUI(1, CSprite)
	self.m_KeyNumberTable = self:NewUI(2, CTable)
	self.m_KeyNumberCloneBox = self:NewUI(3, CBox)
	self.m_AddBtn = self:NewUI(4, CButton) 
	self.m_SubBtn = self:NewUI(5, CButton) 
	self.m_NunberLabel = self:NewUI(6, CLabel) 
	self.m_PivotGrid = self:NewUI(7, CGrid)

	self:InitContent()
	self:InitPivotGrid()
end

function CItemNumberKeyBoardView.SetExtendClose(self)
	self.m_ExtendClose = nil
	g_UITouchCtrl:TouchOutDetect(self, function(obj)
		self:CloseView()
	end)
end

function CItemNumberKeyBoardView.InitContent( self)
	self.m_KeyNumberCloneBox:SetActive(false)
	self.m_SubBtn:AddUIEvent("repeatpress", callback(self, "OnRePeatPress", "Sub"))
	self.m_AddBtn:AddUIEvent("repeatpress", callback(self, "OnRePeatPress", "Add"))
	self:InitKeyNumberTable()
end

function CItemNumberKeyBoardView.InitKeyNumberTable(self)
	self.m_KeyNumberTable:Clear()
	for _ , v in ipairs(CItemNumberKeyBoardView.Key) do
		local tBox = self.m_KeyNumberCloneBox:Clone()
		tBox:SetActive(true)
		tBox.m_KeyBtn = tBox:NewUI(1, CButton)
		tBox.m_KeyLabel = tBox:NewUI(2, CLabel)
		tBox.m_BackSprite = tBox:NewUI(3, CSprite)

		if v == "del" then
			tBox.m_KeyLabel:SetActive(false)
			tBox.m_BackSprite:SetActive(true)
			tBox.m_KeyBtn:AddUIEvent("click", callback(self, "OnClickDelKey"))
		elseif v == "ok" then
			tBox.m_KeyLabel:SetText("OK")
			tBox.m_KeyBtn:AddUIEvent("click", callback(self, "OnClickOkKey"))
		else
			tBox.m_KeyLabel:SetText(v)
			tBox.m_KeyBtn:AddUIEvent("click", callback(self, "OnClickNumberKey", tonumber(v) ))
		end
		self.m_KeyNumberTable:AddChild(tBox)
	end
	self.m_NunberLabel:SetText(tostring(self.m_Number))
end

function CItemNumberKeyBoardView.SetNumberKeyBoardConfig(self, num, min, max, syncFunc, syncObj)
	self.m_Number = num or 10
	self.m_MinNumber = min or 0
	self.m_MaxNumber = max or 99
	self.m_SyncFunc = syncFunc
	self.m_SyncOjb = syncObj

	self.m_NunberLabel:SetText(tostring(self.m_Number))
end

function CItemNumberKeyBoardView.OnClickDelKey( self )
	self.m_Number =  math.floor(self.m_Number / 10) 

	if self.m_Number < self.m_MinNumber then
		self.m_Number = self.m_MinNumber
	end
	self.m_NunberLabel:SetText(tostring(self.m_Number))
	if self.m_SyncFunc then
		self.m_SyncFunc(self.m_SyncOjb, self.m_Number)
	end
end

function CItemNumberKeyBoardView.OnClickOkKey( self  )
	self:OnClose()
end

function CItemNumberKeyBoardView.OnClickNumberKey( self, num )
	if  not self.m_FirstNumberClick  then
		self.m_FirstNumberClick = true
		self.m_Number = num
	else
	 	self.m_Number = self.m_Number * 10 + num
	end
	if self.m_Number > self.m_MaxNumber then
		self.m_Number = self.m_MaxNumber
		g_NotifyCtrl:FloatMsg("输入的数量超过最大数！")
	elseif self.m_Number < self.m_MinNumber then
		self.m_Number = self.m_MinNumber
	else
		--Do Nothing
	end
	self.m_NunberLabel:SetText(tostring(self.m_Number))
	if self.m_SyncFunc then
		self.m_SyncFunc(self.m_SyncOjb, self.m_Number)
	end
end

function CItemNumberKeyBoardView.OnClickAddKey( self )
	self.m_Number = self.m_Number + 1

	if self.m_Number > self.m_MaxNumber then
		self.m_Number = self.m_MaxNumber
	end

	self.m_NunberLabel:SetText(tostring(self.m_Number))
	if self.m_SyncFunc then
		self.m_SyncFunc(self.m_SyncOjb, self.m_Number)
	end
end

function CItemNumberKeyBoardView.OnClickSubKey( self )
	self.m_Number = self.m_Number - 1
	if self.m_Number < self.m_MinNumber then
		self.m_Number = self.m_MinNumber
	end
	self.m_NunberLabel:SetText(tostring(self.m_Number))
	if self.m_SyncFunc then
		self.m_SyncFunc(self.m_SyncOjb, self.m_Number)
	end
end

function CItemNumberKeyBoardView.OnRePeatPress( self ,tType ,...)

	local bPress = select(2, ...)
	if bPress ~= true then
			return
	end 

	if tType == "Add" then
		self:OnClickAddKey()
	else
		self:OnClickSubKey()
	end
end

function CItemNumberKeyBoardView.SetPivot(self, pivot)
	if pivot ~= nil then
		local index = nil
		if pivot == enum.UIAnchor.Side.Top then
			index = 2
		elseif pivot == enum.UIAnchor.Side.Bottom then
			index = 1
		elseif pivot == enum.UIAnchor.Side.Left then
			index = 4
		elseif pivot == enum.UIAnchor.Side.Right then
			index = 3
		end

		if index ~= nil then
			local oBox = self.m_PivotGrid:GetChild(index)
			oBox:SetActive(true)
		end

	end
end

function CItemNumberKeyBoardView.InitPivotGrid(self)
	self.m_PivotGrid:InitChild(function (obj, index)
		local oBox = CBox.New(obj)
		oBox:SetActive(false)
		return oBox	
	end)
end

return CItemNumberKeyBoardView