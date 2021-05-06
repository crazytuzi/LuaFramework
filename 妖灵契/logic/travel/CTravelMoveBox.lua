local CTravelMoveBox = class("CTravelMoveBox", CBox)

function CTravelMoveBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_PosGrid = self:NewUI(1, CBox)
	self.m_SpecialPosBox = self:NewUI(3, CTravelPosBox)
	
	self:InitContent()
end

function CTravelMoveBox.SetParentView(self, oView)
	self.m_ParentView = oView
end

function CTravelMoveBox.InitContent(self)
	self.m_Type = nil
	
	self.m_BoxList = {} 
	self.m_ActorList = {}
	for i = 1, 4 do
		local oBox = self.m_PosGrid:NewUI(i, CTravelPosBox)
		oBox.m_PosIdx = i
		self.m_ActorList[i] = oBox
		table.insert(self.m_BoxList, oBox)
	end
	table.insert(self.m_BoxList, self.m_SpecialPosBox)
	
	g_TravelCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTravelCtrl"))
	g_PartnerCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnPartnerCtrl"))
end

function CTravelMoveBox.ReInit(self, iType)
	self.m_Type = iType
	if iType == define.Travel.Type.Mine then
		self:InitMineStatus()
	elseif iType == define.Travel.Type.Friend then
		self:InitFrdState()
	end
	--设置移动路径
	self:InitBoxPathIdx()
	self:ReNormalPos()
end

function CTravelMoveBox.Refresh(self, iType)
	if self.m_Type ~= iType then
		self:ReInit(iType)
	end

	if self.m_Type == define.Travel.Type.Mine then
		self:RefreshMineSpecialBox()
		self:RefreshMinePosBox()
	elseif self.m_Type == define.Travel.Type.Friend then
		self:RefreshFrdSpecialBox()
		self:RefreshFrdPosBox()
	end
	
	self:RefreshSay()
end

function CTravelMoveBox.OnTravelCtrl(self, oCtrl)
	if self.m_Type == define.Travel.Type.Mine then
		if oCtrl.m_EventID == define.Travel.Event.Base then
			local traveling = g_TravelCtrl:IsMainTraveling()
			local hasreward = g_TravelCtrl:HasTravelReward()
			local status = traveling 
			if not traveling then
				self:ReNormalPos()
				self.m_Status = status
			else
				if self.m_Status ~= status then
					self.m_Status = status 
					self:Refresh(self.m_Type)
				end
			end
		elseif oCtrl.m_EventID == define.Travel.Event.MinePos  then
			self:RefreshMinePosBox()
		elseif oCtrl.m_EventID == define.Travel.Event.Frd2Mine then
			self:RefreshMineSpecialBox()
		end
	elseif self.m_Type == define.Travel.Type.Friend then
		self:Refresh(self.m_Type)
	end
end

function CTravelMoveBox.OnPartnerCtrl(self, oCtrl)
	if oCtrl.m_EventID == define.Partner.Event.UpdatePartner then
		self:Refresh(self.m_Type)
	end
end

function CTravelMoveBox.RefreshSay(self)
	--开启对白
	local isCanMove = self:IsMineCanMove() 
	if isCanMove then
		self:OpenSay()
	else
		self:StopSay()
	end
end

function CTravelMoveBox.OpenSay(self)
	if self.m_SayTimer then
		Utils.DelTimer(self.m_SayTimer)
		self.m_SayTimer = nil
	end
	local time = 0
	local function say()
		if Utils.IsNil(self) then
			return
		end
		--从0开始每秒+1，对话框存在10，30秒开一次对话框
		if time > 30 then
			time = 0
		end
		
		local list = {} --可选box
		if time == 0 or time == 10 then 
			for i,oBox in ipairs(self.m_BoxList) do
				oBox.m_DuiHuaLabel:SetActive(false)
				if oBox:GetParid() then
					table.insert(list, oBox)
				end
			end
		end
		
		local lsay = {} --选中box
		if time == 0 then
			local count = 1
			if #list > 2 then
				count = 2
			end
			for i=1,count do
				local idx = Utils.RandomInt(1, #list)
				table.insert(lsay, table.remove(list, idx))
			end

			for i,oBox in ipairs(lsay) do
				local dData = table.randomvalue(data.traveldata.TRAVEL_SAY)
				oBox.m_DuiHuaLabel:SetActive(true)
				oBox.m_DuiHuaLabel:SetText(dData.desc)
			end
		end
		time = time + 1

		return true
	end
	self.m_SayTimer = Utils.AddTimer(say, 1, 0) 
end

function CTravelMoveBox.StopSay(self)
	for i,oBox in ipairs(self.m_BoxList) do
		oBox.m_DuiHuaLabel:SetActive(false)
	end
end

function CTravelMoveBox.ReNormalPos(self)
	self:RefreshMinePosBox()
	self:RefreshMineSpecialBox()

	for i,v in ipairs(self.m_BoxList) do
		v:StopMove()
	end
	local cmp = self.m_PosGrid:GetComponent(classtype.UIGrid)
	cmp:Reposition()
	--关闭对白
	self:StopSay()
end

function CTravelMoveBox.InitBoxPathIdx(self)
	for i,oBox in ipairs(self.m_BoxList) do
		oBox:SetPathIdx(i)
	end
end

------------------------------自己的游历：开始-------------------------------------

function CTravelMoveBox.InitMineStatus(self)
	self.m_Status = g_TravelCtrl:IsMainTraveling() or g_TravelCtrl:HasTravelReward()
end

function CTravelMoveBox.RefreshMineSpecialBox(self)
	local isCanMove = self:IsMineCanMove()
	local parinfo = g_TravelCtrl:GetFrd2MineParinfo()
	self.m_SpecialPosBox:SetCanMove(isCanMove)
	self.m_SpecialPosBox:RefreshPosBox(parinfo)
end

function CTravelMoveBox.RefreshMinePosBox(self)
	local isCanMove = self:IsMineCanMove()
	for i, oBox in ipairs(self.m_ActorList) do
		local parinfo = g_TravelCtrl:GetParinfoByPos(i)
		oBox:SetCanMove(isCanMove)
		oBox:RefreshPosBox(parinfo)
	end
end

function CTravelMoveBox.IsMineCanMove(self)
	local bCanMove
	--local oView = self.m_ParentView:GetView()
	local bPartnerScrollAct = false--oView and oView:GetPartnerScrollActive()
	--云龙说改成 游历结束就停止
	--(g_TravelCtrl:IsMainTraveling() or g_TravelCtrl:HasTravelReward()) then
	if not bPartnerScrollAct and g_TravelCtrl:IsMainTraveling() then 
		bCanMove = true
	else
		bCanMove = false
	end
	return bCanMove
end

------------------------------自己的游历：结束-------------------------------------

------------------------------好友的游历：开始-------------------------------------

function CTravelMoveBox.InitFrdState(self)
	-- body
end

function CTravelMoveBox.RefreshFrdSpecialBox(self)
	local info = g_TravelCtrl:GetFrdTravelInfo()
	local dData = info.frd_partner
	local parinfo = dData and dData.parinfo
	local isCanMove = self:IsFrdCanMove()
	self.m_SpecialPosBox:SetCanMove(isCanMove)
	self.m_SpecialPosBox:RefreshPosBox(parinfo)
end

function CTravelMoveBox.RefreshFrdPosBox(self)
	local isCanMove = self:IsFrdCanMove()
	for i, oBox in ipairs(self.m_ActorList) do
		local parinfo = g_TravelCtrl:GetFrdTravelPos(i)
		oBox:SetCanMove(isCanMove)
		oBox:RefreshPosBox(parinfo)
	end
end

function CTravelMoveBox.IsFrdCanMove(self)
	local bCanMove
	local info = g_TravelCtrl:GetFrdTravelInfo()
	local dTravel = info.travel_partner
	if dTravel.status == 1 then
		bCanMove = true
	else
		bCanMove = false
	end
	return bCanMove
end

------------------------------好友的游历：开始-------------------------------------

return CTravelMoveBox