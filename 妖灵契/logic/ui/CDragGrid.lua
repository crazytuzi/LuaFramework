local CDragGrid = class("CDragGrid", CBox)
CDragGrid.g_Print = false
--先调好效果, 代码后面优化
function CDragGrid.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_CellWidth = 100
	self.m_ShowCnt = 5
	self.m_WaitShowCnt = 2
	self.m_StartIdx = 1
	self.m_Origin = self:NewUI(1, CObject)
	self.m_WaitOffset = Vector3.New(-60, -60, 0)
	self.m_DepthList = {}
	self.m_Childs = {}
	self.m_Datas = {}
	self.m_IsInitChilds = false
	self:AddUIEvent("dragstart", callback(self, "OnDragStart"))
	self:AddUIEvent("drag", callback(self, "OnDrag"))
	self:AddUIEvent("dragend", callback(self, "OnDragEnd"))
	self.m_BoxClone = nil
	self.m_InitBoxFunc = nil
	self.m_InitShiftX = nil
end

function CDragGrid.ClearGrid(self)
	self:Clear()
	self.m_StartIdx = 1
	self:InitGrid()
	self:ResetChilds()
end

function CDragGrid.SetCloneChild(self, oClone, init)
	self.m_BoxClone = oClone
	self.m_InitBoxFunc = init
end

function CDragGrid.InitGrid(self)
	self.m_EndIdx = self.m_StartIdx + self.m_ShowCnt - 1
	self.m_MinPosX = -self.m_CellWidth
	self.m_MaxPosX = self.m_CellWidth*(self.m_ShowCnt-1)
	self.m_MinShowCnt = self.m_ShowCnt - 1
	self.m_LeftPosX = 0
	self.m_RightPosX= self.m_CellWidth*(self.m_ShowCnt-2)
	self.m_Border = 10
	--local panel = self.m_Origin:AddComponent(classtype.UIPanel)
	local panel = self.m_Origin:GetComponent(classtype.UIPanel)
	if not panel then
		panel = self.m_Origin:AddComponent(classtype.UIPanel)
		panel.depth = self.m_WaitShowCnt + 10
	end
	local basedepth = panel.depth - 10 - self.m_WaitShowCnt
	for i=self.m_WaitShowCnt, 1, -1 do
		local go = self.m_DepthList[i]
		
		local go = UnityEngine.GameObject.New()
		go.transform:SetParent(self.m_Origin.m_Transform, false)
		go.transform.position = self.m_Origin:GetPos()
		go.name = "depth"..tostring(i)
		go.layer = self.m_Origin:GetLayer()
		panel = go:AddComponent(classtype.UIPanel)
		panel.depth = i + 10 + basedepth
		table.insert(self.m_DepthList, go)
	end
	self.m_IsCreatePanels = true
	self.m_InitShiftX = -self.m_CellWidth + 10
end

function CDragGrid.LeftShiftChilds(self)
	local oChild = self.m_Childs[1]
	table.remove(self.m_Childs, 1)
	table.insert(self.m_Childs, oChild)
end

function CDragGrid.RightShiftChilds(self)
	local oChild = self.m_Childs[#self.m_Childs]
	table.remove(self.m_Childs, #self.m_Childs)
	table.insert(self.m_Childs, 1, oChild)
end

function CDragGrid.ResetChilds(self)
	if self.m_IsInitChilds then
		return
	end
	self.m_Childs ={}
	for i=1, self.m_ShowCnt+self.m_WaitShowCnt*2 do
		local oClone = self.m_BoxClone:Clone()
		if self.m_InitBoxFunc then
			oClone = self.m_InitBoxFunc(oClone, i)
		end
		if oClone.m_Delegate then
			for i, func in ipairs(self.m_Delegate:GetFunctions()) do
				oClone.m_Delegate:AddFunction(func)
			end
		end
		table.insert(self.m_Childs, oClone)
	end
	self.m_IsInitChilds = true
end

function CDragGrid.Clear(self)
	for k, v in pairs(self.m_Childs) do
		v:Destroy()
	end
	for k, v in pairs(self.m_DepthList) do
		v:Destroy()
	end
	self.m_Childs = {}
	self.m_DepthList = {}
	self.m_IsInitChilds = false
end

function CDragGrid.ClearChild(self)
	for k, v in pairs(self.m_Childs) do
		v:Destroy()
	end
	self.m_Childs = {}
	self.m_IsInitChilds = false
end

function CDragGrid.RefresAll(self, dAllData)
	self.m_Datas = dAllData
	self:IndexChange(0)
	self:CheckBack()
end

function CDragGrid.SetRefreshFunc(self, func)
	self.m_RefreshFunc = func
end

function CDragGrid.AddChild(self, oChild, iInsert)
	iInsert = iInsert or #self.m_Childs
	table.insert(self.m_Childs, iInsert, oChild)
	if self.m_StartIdx-self.m_WaitShowCnt <= iInsert
		and iInsert <= self.m_EndIdx+self.m_WaitShowCnt then
		self:CheckChildShow()
		self:CheckWaitShowPos()
	end
end

function CDragGrid.GetChildList(self)
	return self.m_Childs
end

function CDragGrid.AddData(self, dData, iInsert)
	iInsert = iInsert or #self.m_Datas
	table.insert(self.m_Datas, iInsert, oChild)
	if self.m_StartIdx-self.m_WaitShowCnt <= iInsert
		and iInsert <= self.m_EndIdx+self.m_WaitShowCnt then
		self:CheckChildShow()
		self:CheckWaitShowPos()
	end
end

function CDragGrid.IndexChange(self, i)
	if i~=0 then
		local iStart = self.m_StartIdx + i
		local iEnd = self.m_EndIdx + i
		local bNewIdx = true
		--右
		if i < 0 and iEnd < self.m_MinShowCnt then
			bNewIdx = false
		end
		--左
		if bNewIdx and i > 0 and iStart > #self.m_Datas-self.m_MinShowCnt then
			bNewIdx = false
		end
		if bNewIdx then
			self.m_StartIdx = iStart
			self.m_EndIdx = iEnd
		else
			return false
		end
		if i < 0 then
			self.m_ShiftX = - self.m_CellWidth
			self:RightShiftChilds()
		elseif i > 0 then
			self.m_ShiftX = 0
			self:LeftShiftChilds()
		end
	end
	self:RefreshChilds()
	self:CheckChildShow()
	self:CheckWaitShowPos()
	return true
end

function CDragGrid.RefreshChilds(self)
	for i, oChild in ipairs(self.m_Childs) do
		local iDataIdx = self.m_StartIdx+(i-(self.m_WaitShowCnt+1))
		local dData = self.m_Datas[iDataIdx]
		if dData then
			oChild.m_DataIdx = iDataIdx
			self.m_RefreshFunc(oChild, dData)
		else
			oChild.m_DataIdx = nil
		end
	end
end

function CDragGrid.CheckChildShow(self)
	self.m_StartBoxIdx = 0
	self.m_EndBoxIdx = 0
	for i, oChild in ipairs(self.m_Childs) do
		local bActive = oChild.m_DataIdx~=nil
		if bActive and self.m_WaitShowCnt+1<=i and i <= self.m_WaitShowCnt+self.m_ShowCnt then
			if self.m_StartBoxIdx == 0 then
				self.m_StartBoxIdx = i
			end
			self.m_EndBoxIdx = i
		end
		oChild:SetActive(bActive)
	end
end

function CDragGrid.CheckWaitShowPos(self)
	if not self.m_IsInitChilds then
		return
	end
	if self.m_InitShiftX then
		self.m_ShiftX = self.m_InitShiftX
	end
	for i=self.m_WaitShowCnt+1, self.m_WaitShowCnt+self.m_ShowCnt do
		local oChild = self.m_Childs[i]
		oChild:SetParent(self.m_Origin.m_Transform, false)
		local x = self.m_CellWidth * (i - (self.m_WaitShowCnt+1)) + self.m_ShiftX
		-- if i == self.m_WaitShowCnt+self.m_ShowCnt then
		-- 	self:DebugPrint("CheckWaitShowPos->", x, i)
		-- end
		local vPos = Vector3.New(x, 0, 0)
		oChild:SetLocalPos(vPos)
	end

	for i=1, self.m_WaitShowCnt do
		local oChild = self.m_Childs[i]
		local iWaitLevel = self.m_WaitShowCnt - i + 1
		local trans = self.m_DepthList[iWaitLevel].transform or self.m_Origin.m_Transform
		oChild:SetParent(trans, false)
		local pos = Vector3.New(-self.m_CellWidth, self.m_WaitOffset.y, 0)
		if iWaitLevel > 1 then
			pos = pos + self.m_WaitOffset*(iWaitLevel-1)
		end
		oChild:SetLocalPos(pos)
	end

	local oEndChild = self.m_Childs[self.m_EndIdx]
	local vEndPos = Vector3.New(self.m_CellWidth*(self.m_ShowCnt-1))
	for i = self.m_WaitShowCnt+self.m_ShowCnt+1, #self.m_Childs do
		if i <= #self.m_Childs then
			local oChild = self.m_Childs[i]
			local iWaitLevel = i - (self.m_WaitShowCnt+self.m_ShowCnt)
			local trans = self.m_DepthList[iWaitLevel].transform or self.m_Origin.m_Transform
			oChild:SetParent(trans, false)
			local pos = vEndPos + Vector3.New(0, self.m_WaitOffset.y, 0)
			if iWaitLevel > 1 then
				local vOffsetPos = self.m_WaitOffset*(iWaitLevel-1)
				vOffsetPos.x = -vOffsetPos.x
				pos = pos + vOffsetPos
			end
			oChild:SetLocalPos(pos)
		end
	end
	self.m_ShiftX = 0
	UITools.MarkParentAsChanged(self.m_GameObject)
end

function CDragGrid.CheckMove(self, vector2)
	if not self.m_IsInitChilds then
		return
	end
	if (self.m_EndIdx == self.m_MinShowCnt) and vector2.x > 0 then
		local oEndPosX = self.m_Childs[self.m_WaitShowCnt+self.m_ShowCnt]:GetLocalPos().x
		self:DebugPrint(">>右检测", oEndPosX, self.m_MaxPosX-10)
		if oEndPosX >= (self.m_MaxPosX-10) then
			self:DebugPrint(">>最右")
			return false
		end
	end
	if self.m_StartIdx == (#self.m_Datas-self.m_MinShowCnt) and vector2.x < 0 then
		local oStartPosX = self.m_Childs[self.m_WaitShowCnt+1]:GetLocalPos().x
		self:DebugPrint(">>左检测", oStartPosX, self.m_MinPosX+10)
		if oStartPosX <= (self.m_MinPosX+10) then
			self:DebugPrint(">>最左")
			return false
		end
	end
	local dPosMap = {}
	for i=self.m_WaitShowCnt+1, self.m_WaitShowCnt+self.m_ShowCnt do
		local oChild = self.m_Childs[i]
		local pos = oChild:GetLocalPos()
		pos.x = pos.x + vector2.x
		if vector2.x > 0 then 
			if (self.m_StartIdx > 0 and oChild.m_DataIdx == self.m_StartIdx and pos.x >= self.m_LeftPosX) --then
			or (self.m_StartIdx <= 0 and oChild.m_DataIdx == self.m_EndIdx and pos.x > self.m_MaxPosX) then
				if not self:IndexChange(-1) then
					self.m_ShiftX = - 10
					self:DebugPrint("右修正")
					self:CheckWaitShowPos()
				end
				return
			end
		end
		if vector2.x < 0 then 
			if (self.m_EndIdx < #self.m_Datas and oChild.m_DataIdx == self.m_EndIdx and pos.x <= self.m_RightPosX) --then
			or (self.m_EndIdx >= #self.m_Datas and oChild.m_DataIdx == self.m_StartIdx and pos.x < self.m_MinPosX) then
				if not self:IndexChange(1) then
					self.m_ShiftX = - (self.m_CellWidth - 10)
					self:DebugPrint("左修正")
					self:CheckWaitShowPos()
					return
				end
				return
			end
		end
		dPosMap[i] = pos
	end
	for idx, pos in pairs(dPosMap) do
		local oChild = self.m_Childs[idx]
		oChild:SetLocalPos(pos)
	end
	return true
end

function CDragGrid.OnDragStart(self)
	self.m_InitShiftX = nil
	self:StopSpring()
end

-->0向右
function CDragGrid.OnDrag(self, obj, delta)
	self.m_InitShiftX = nil
	if not self:IsTouchEabled() then
		return
	end
	if #self.m_Datas <= self.m_ShowCnt then
		return
	end
	local adjust = UITools.GetPixelSizeAdjustment()
	delta.x = delta.x * adjust
	if math.abs(delta.x) > 10 then
		self:DebugPrint("stength滑动", math.abs(delta.x), delta.x)
		self.m_Spring = -(delta.x*5)
	end
	self:CheckMove(delta)
end

function CDragGrid.OnDragEnd(self)
	if not self:CheckBack() and self.m_Spring then
		self:DebugPrint("拖动结束Spring滑动", self.m_Spring)
		self:StartSpring(self.m_Spring, 50)
	end
end

function CDragGrid.CheckBack(self)
	if not self.m_IsInitChilds then
		return
	end
	local iBackSpring
	if self.m_StartIdx < 1 then
		local x = self.m_Childs[self.m_StartBoxIdx]:GetLocalPos().x
		self:DebugPrint("回弹检查左", self.m_StartIdx, self.m_Childs[self.m_StartBoxIdx]:GetName(), x, self.m_MinPosX+1)
		iBackSpring = x - (self.m_MinPosX + 1)
		if iBackSpring <= 0 then --不用往左spring
			iBackSpring = nil
		end
	end
	if not iBackSpring then
		if self.m_EndIdx == #self.m_Datas and  self.m_EndIdx > self.m_ShowCnt then
			local x = self.m_Childs[self.m_EndBoxIdx]:GetLocalPos().x
			iBackSpring = x-(self.m_MaxPosX-1)
			self:DebugPrint("回弹检查右pos", x, self.m_MaxPosX-1)
			if iBackSpring >= 0 then --不用往右spring
				iBackSpring = nil
				return false
			end
		end
	end
	if iBackSpring then
		self:DebugPrint("拖动结束越界回弹", iBackSpring)
		self:StartSpring(iBackSpring, 20)
		return true
	else
		self:DebugPrint("不需要回弹")
		return false
	end
end

function CDragGrid.StartSpring(self, iSpring, iStrength)
	self:DebugPrint("开始Spring", iSpring, iStrength)
	self.m_Spring = iSpring
	self.m_Strength = iSpring > 0 and -iStrength or iStrength
	if not self.m_SpringTimer then
		self.m_SpringTimer = Utils.AddTimer(callback(self, "Spring"), 0, 0)
	end
end

function CDragGrid.StopSpring(self)
	self.m_Spring = nil
	self.m_Strength = nil
	if self.m_SpringTimer then
		Utils.DelTimer(self.m_SpringTimer)
		self.m_SpringTimer = nil
	end
end

function CDragGrid.Spring(self)
	self.m_Spring = self.m_Spring + self.m_Strength
	local bEnd = false
	local iMove = self.m_Strength
	if self.m_Strength < 0 then
		if self.m_Spring <= 0 then
			bEnd = true
			iMove = self.m_Strength-self.m_Spring
			self:DebugPrint("spring左结束", iMove)
		end
	else
		if self.m_Spring >= 0 then
			bEnd = true
			iMove = self.m_Strength-self.m_Spring
			self:DebugPrint("spring右结束", self.m_Spring)
		end
	end
	local bMove = self:CheckMove(Vector2.New(iMove, 0))
	if bEnd or (bMove == false) then
		self:StopSpring()
		self:CheckBack()
		return false
	else
		return true
	end
end

function CDragGrid.DebugPrint(self, ...)
	if CDragGrid.g_Print then
		printc(...)
	end
end

return CDragGrid