require "ui.dialog"
require "utils.mhsdutils"

PetStarDlg = {}
setmetatable(PetStarDlg, Dialog)
PetStarDlg.__index = PetStarDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;

function PetStarDlg.getInstance()
	LogInfo("enter get petstardlg instance")
    if not _instance then
        _instance = PetStarDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function PetStarDlg.getInstanceAndShow()
	LogInfo("enter petstardlg instance show")
    if not _instance then
        _instance = PetStarDlg:new()
        _instance:OnCreate()
	else
		LogInfo("set petstardlg visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function PetStarDlg.getInstanceNotCreate()
    return _instance
end

function PetStarDlg.DestroyDialog()
	if _instance then 
		LogInfo("destroy petstardlg")
		if PetLabel.getInstanceNotCreate() then
			PetLabel.getInstanceNotCreate().DestroyDialog()		
		else
			_instance:CloseDialog()
		end
	end
end

--called by label,release resource here
function PetStarDlg:CloseDialog()
	if _instance then
		_instance.m_pPane:cleanupNonAutoChildren()
		GetDataManager().EventSRsqStar:RemoveScriptFunctor(_instance.m_hSRsqStar)
		GetDataManager().EventStarUp:RemoveScriptFunctor(_instance.m_hStarUp)
		GetDataManager().EventXuemaiChange:RemoveScriptFunctor(_instance.m_hXuemaiChange)
		_instance:OnClose()
		_instance = nil
	end
end

function PetStarDlg.ToggleOpenClose()
	if not _instance then 
		_instance = PetStarDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

----/////////////////////////////////////////------

function PetStarDlg.SRsqStar()
	if _instance then
		if PetLabel.getInstanceNotCreate() then
			if PetLabel.getInstanceNotCreate().m_index ~= 2 then
				return
			end	
		end
		_instance:Init()
	end
end

function PetStarDlg.StarUp(key)
	LogInfo("petstardlg star up") 	
	if _instance then 
		if PetLabel.getInstanceNotCreate() then
			if PetLabel.getInstanceNotCreate().m_index ~= 2 then
				return
			end	
		end
		if _instance.m_iSelectID == key then
			GetGameUIManager():AddUIEffect(_instance.m_pCurHead, MHSD_UTILS.get_effectpath(10378), false);
		end
	end
end

function PetStarDlg.MainPetRefresh()
	if _instance then
		LogInfo("petstardlg main pet refresh")
		if PetLabel.getInstanceNotCreate() then
			if PetLabel.getInstanceNotCreate().m_index ~= 2 then
				return
			end	
		end
		_instance:InitPetList()
		if GetDataManager():GetBattlePetID() == _instance.m_iSelectID then
			_instance:InitInfo()	
		end
	end
end

function PetStarDlg.PetNumChange()
	if _instance then
		LogInfo("petstardlg pet num change")
		if PetLabel.getInstanceNotCreate() then
			if PetLabel.getInstanceNotCreate().m_index ~= 2 then
				return
			end	
		end
		_instance:Init()
	end
end

function PetStarDlg.PetDataChange(key)
	if _instance then
		LogInfo("petstardlg pet data change" .. tostring(key))
		if PetLabel.getInstanceNotCreate() then
			if PetLabel.getInstanceNotCreate().m_index ~= 2 then
				return
			end	
		end
		_instance:InitPetList()
		if key == _instance.m_iSelectID then	
			_instance:InitInfo()
		end	
	end
end

function PetStarDlg.RoleXuemaiChange()
	if _instance then
		LogInfo("petstardlg role xuemai change")
		if PetLabel.getInstanceNotCreate() then
			if PetLabel.getInstanceNotCreate().m_index ~= 2 then
				return
			end	
		end
		_instance.m_pXuemaiAll:setText(tostring(GetDataManager():GetMainCharacterData():GetValue(knight.gsp.attr.AttrType.PET_XUEMAI)))
	end
end

function PetStarDlg.BattlePetStateChange()
	if _instance then
		LogInfo("petstardlg battle state change")
		if PetLabel.getInstanceNotCreate() then
			if PetLabel.getInstanceNotCreate().m_index ~= 2 then
				return
			end	
		end
		_instance:InitPetList()
	end
end

function PetStarDlg.GetLayoutFileName()
    return "petstardialog.layout"
end

function PetStarDlg:OnCreate()
	LogInfo("petstardlg oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pPane = CEGUI.Window.toScrollablePane(winMgr:getWindow("petstardialog/left"))
	
	self.m_pBack = winMgr:getWindow("petstardialog/right")	
	self.m_pNextBack = winMgr:getWindow("petstardialog/right/part2")
	self.m_pCurBack = winMgr:getWindow("petstardialog/right/part1")

	self.m_pCurHead = winMgr:getWindow("petstardialog/right/part1/haed1")
	self.m_pCurName = winMgr:getWindow("petstardialog/right/part1/name1")
	self.m_pCurLife = winMgr:getWindow("petstardialog/right/part1/num0")
	self.m_pCurPhyAtt = winMgr:getWindow("petstardialog/right/part1/num1")
	self.m_pCurPhyDef = winMgr:getWindow("petstardialog/right/part1/num2")
	self.m_pCurMagAtt = winMgr:getWindow("petstardialog/right/part1/num3")
	self.m_pCurMagDef = winMgr:getWindow("petstardialog/right/part1/num4")
	self.m_pCurSpeed = winMgr:getWindow("petstardialog/right/part1/num5")
	self.m_pCurScore = winMgr:getWindow("petstardialog/right/part1/num6")
	self.m_pCurStar = CEGUI.Window.toRichEditbox(winMgr:getWindow("petstardialog/right/part1/star1"))

	
	self.m_pNextHead = winMgr:getWindow("petstardialog/right/part2/haed2")
	self.m_pNextName = winMgr:getWindow("petstardialog/right/part2/name2")
	self.m_pNextLife = winMgr:getWindow("petstardialog/right/part2/num0")
	self.m_pNextPhyAtt = winMgr:getWindow("petstardialog/right/part2/num1")
	self.m_pNextPhyDef = winMgr:getWindow("petstardialog/right/part2/num2")
	self.m_pNextMagAtt = winMgr:getWindow("petstardialog/right/part2/num3")
	self.m_pNextMagDef = winMgr:getWindow("petstardialog/right/part2/num4")
	self.m_pNextSpeed = winMgr:getWindow("petstardialog/right/part2/num5")
	self.m_pNextScore = winMgr:getWindow("petstardialog/right/part2/num6")
	self.m_pNextStar = CEGUI.Window.toRichEditbox(winMgr:getWindow("petstardialog/right/part2/star2"))
	
	self.m_pExpBar = CEGUI.Window.toProgressBar(winMgr:getWindow("petstardialog/right/bot/progress"))	
	self.m_pXuemaiUse = winMgr:getWindow("petstardialog/right/bot/num1")
	self.m_pXuemaiAll = winMgr:getWindow("petstardialog/right/bot/num11")

	self.m_pGetXuemaiBtn = CEGUI.Window.toPushButton(winMgr:getWindow("petstardialog/right/bot/get"))
	self.m_pOKBtn = CEGUI.Window.toPushButton(winMgr:getWindow("petstardialog/right/ok"))

    -- subscribe event
    self.m_pGetXuemaiBtn:subscribeEvent("Clicked", PetStarDlg.HandleGetXuemaiClicked, self)
	self.m_pOKBtn:subscribeEvent("Clicked", PetStarDlg.HandleOKBtnClicked, self)

	self.m_pCurStar:SetEmotionScale(CEGUI.Vector2(0.6, 0.6))
	self.m_pNextStar:SetEmotionScale(CEGUI.Vector2(0.6, 0.6))

	self:Init()


	self.m_hSRsqStar = GetDataManager().EventSRsqStar:InsertScriptFunctor(PetStarDlg.SRsqStar)
	self.m_hStarUp = GetDataManager().EventStarUp:InsertScriptFunctor(PetStarDlg.StarUp)
	self.m_hXuemaiChange = GetDataManager().EventXuemaiChange:InsertScriptFunctor(PetStarDlg.RoleXuemaiChange)

	LogInfo("petstardlg oncreate end")
end

------------------- private: -----------------------------------

function PetStarDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, PetStarDlg)
    return self
end

function PetStarDlg:Init()
	LogInfo("petstardlg init ")
	self:InitPetList()
	self:InitInfo()
end

function PetStarDlg:InitPetList()
	--self.m_pPane:cleanupNonAutoChildren()
	if not self.m_petDlgList then
		self.m_petDlgList = {}
		for i = 1, 8 do
			self.m_petDlgList[i] = PetListCell.CreateNewDlg(self.m_pPane, i)
			self.m_petDlgList[i]:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0 ,0), CEGUI.UDim(0, (i - 1) * self.m_petDlgList[i]:GetWindow():getPixelSize().height + 1)))
		end
	end

	for i = 1, 8 do
		self.m_petDlgList[i]:GetWindow():setVisible(false)
	end

	local num = GetDataManager():GetPetNum()
	for i = 1, num do
		self.m_petDlgList[i]:GetWindow():setVisible(true)
		self.m_petDlgList[i]:SetInfo(GetDataManager():getPet(i), 2)
	end

	if not self.m_iSelectID or not GetDataManager():FindMyPetByID(self.m_iSelectID) then
		self.m_iSelectID = nil
	end

	if not self.m_iSelectID and num >= 1 then
		self.m_iSelectID = GetDataManager():getPet(1).key
		for i,v in pairs(self.m_petDlgList) do
			local petInfo = GetDataManager():getPet(v.m_pWnd:getID())
			if petInfo then 
				if petInfo.key == GetDataManager():GetBattlePetID() then
					self.m_iSelectID = petInfo.key
					break
				end
			end
		end
	end
	self:refreshPetSelectState()
end

function PetStarDlg:InitInfo()
	LogInfo("petstardlg init info")
	if self.m_iSelectID then
		if GetDataManager():FindMyPetByID(self.m_iSelectID) then
			self.m_pBack:setVisible(true)
			local petInfo = GetDataManager():FindMyPetByID(self.m_iSelectID)
			local shapeid = petInfo:GetShapeID()
			local headshape = knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(shapeid)
			local path = GetIconManager():GetImagePathByID(headshape.headID):c_str()
			self.m_pCurHead:setProperty("Image", path)
			self.m_pNextHead:setProperty("Image", path)
			self.m_pCurName:setText(petInfo:GetPetNameTextColour() .. petInfo.name)
			self.m_pNextName:setText(GetPetNameTextColourByStar(petInfo.starId + 1) .. petInfo.name)

			local starlevel = petInfo.starId
			local petStar = knight.gsp.pet.GetCPetstarsTableInstance():getRecorder(starlevel)
			local stars = petStar.stars	
			self.m_pCurStar:Clear()
			for i = 7,0,-1 do
				local starLevel = stars % (10 ^(i + 1)) / (10 ^ i)
				if starLevel > 0 then
					self.m_pCurStar:AppendEmotion(149 + starLevel)
				end
			end
			self.m_pCurStar:Refresh()

			local curPhyAtt = petInfo:getAttribute(knight.gsp.attr.AttrType.ATTACK) 
			local curPhyDef = petInfo:getAttribute(knight.gsp.attr.AttrType.DEFEND) 
			local curMagAtt = petInfo:getAttribute(knight.gsp.attr.AttrType.MAGIC_ATTACK) 
			local curMagDef = petInfo:getAttribute(knight.gsp.attr.AttrType.MAGIC_DEF) 
			local curSpeed = petInfo:getAttribute(knight.gsp.attr.AttrType.SPEED) 
			local curLife = petInfo:getAttribute(knight.gsp.attr.AttrType.MAX_HP) 
			local curScore = GetDataManager():GetPetGrade(petInfo)

			self.m_pCurPhyAtt:setText(tostring(curPhyAtt))
			self.m_pCurPhyDef:setText(tostring(curPhyDef))
			self.m_pCurMagAtt:setText(tostring(curMagAtt))
			self.m_pCurMagDef:setText(tostring(curMagDef))
			self.m_pCurSpeed:setText(tostring(curSpeed))
			self.m_pCurLife:setText(tostring(curLife))
			self.m_pCurScore:setText(tostring(curScore))
			
			
			if (starlevel + 1) > 64 then
				self.m_pNextBack:setVisible(false)
				self.m_pOKBtn:setEnabled(false)
				self.m_pXuemaiUse:setVisible(false)
				self.m_pExpBar:setVisible(false)
			else
				self.m_pOKBtn:setEnabled(true)
				self.m_pNextBack:setVisible(true)
				self.m_pXuemaiUse:setVisible(true)
				self.m_pExpBar:setVisible(true)
				local petStarNext = knight.gsp.pet.GetCPetstarsTableInstance():getRecorder(starlevel + 1)
				local starsNext = petStarNext.stars
				self.m_pNextStar:Clear()
				for i = 7,0,-1 do
					local starLevel = starsNext % (10 ^(i + 1)) / (10 ^ i)
					if starLevel > 0 then
						self.m_pNextStar:AppendEmotion(149 + starLevel)
					end
				end
				self.m_pNextStar:Refresh()
				local nextPhyAtt = math.floor(curPhyAtt * ((1 + petStarNext.uprate / 100) / (1 + petStar.uprate / 100)))	
				local nextPhyDef = math.floor(curPhyDef * ((1 + petStarNext.uprate / 100) / (1 + petStar.uprate / 100)))	
				local nextMagAtt = math.floor(curMagAtt * ((1 + petStarNext.uprate / 100) / (1 + petStar.uprate / 100)))
				local nextMagDef = math.floor(curMagDef * ((1 + petStarNext.uprate / 100) / (1 + petStar.uprate / 100)))
				local nextSpeed = math.floor(curSpeed * ((1 + petStarNext.uprate / 100) / (1 + petStar.uprate / 100)))	
				local nextLife = math.floor(curLife * ((1 + petStarNext.uprate / 100) / (1 + petStar.uprate / 100)))
				petInfo:setAttribute(knight.gsp.attr.AttrType.ATTACK, nextPhyAtt) 
				petInfo:setAttribute(knight.gsp.attr.AttrType.DEFEND, nextPhyDef)
				petInfo:setAttribute(knight.gsp.attr.AttrType.MAGIC_ATTACK, nextMagAtt)
				petInfo:setAttribute(knight.gsp.attr.AttrType.MAGIC_DEF, nextMagDef)
				petInfo:setAttribute(knight.gsp.attr.AttrType.SPEED, nextSpeed)
				petInfo:setAttribute(knight.gsp.attr.AttrType.MAX_HP, nextLife) 
				local nextScore = GetDataManager():GetPetGrade(petInfo)
				
				petInfo:setAttribute(knight.gsp.attr.AttrType.ATTACK, curPhyAtt) 
				petInfo:setAttribute(knight.gsp.attr.AttrType.DEFEND, curPhyDef)
				petInfo:setAttribute(knight.gsp.attr.AttrType.MAGIC_ATTACK, curMagAtt)
				petInfo:setAttribute(knight.gsp.attr.AttrType.MAGIC_DEF, curMagDef)
				petInfo:setAttribute(knight.gsp.attr.AttrType.SPEED, curSpeed)
				petInfo:setAttribute(knight.gsp.attr.AttrType.MAX_HP, curLife) 

				self.m_pNextPhyAtt:setText(tostring(nextPhyAtt) .. "(+" .. "[colrect='tl:FF33FF33 tr:FF33FF33 bl:FF33FF33 br:FF33FF33']" .. tostring(nextPhyAtt - curPhyAtt) .. "[colrect='tl:FFFFFFFF tr:FFFFFFFF bl:FFFFFFFF br:FFFFFFFF'])")
				self.m_pNextPhyDef:setText(tostring(nextPhyDef) .. "(+" .. "[colrect='tl:FF33FF33 tr:FF33FF33 bl:FF33FF33 br:FF33FF33']" .. tostring(nextPhyDef - curPhyDef) .. "[colrect='tl:FFFFFFFF tr:FFFFFFFF bl:FFFFFFFF br:FFFFFFFF'])")
				self.m_pNextMagAtt:setText(tostring(nextMagAtt) .. "(+" .. "[colrect='tl:FF33FF33 tr:FF33FF33 bl:FF33FF33 br:FF33FF33']" .. tostring(nextMagAtt - curMagAtt) .. "[colrect='tl:FFFFFFFF tr:FFFFFFFF bl:FFFFFFFF br:FFFFFFFF'])")
				self.m_pNextMagDef:setText(tostring(nextMagDef) .. "(+" .. "[colrect='tl:FF33FF33 tr:FF33FF33 bl:FF33FF33 br:FF33FF33']" .. tostring(nextMagDef - curMagDef) .. "[colrect='tl:FFFFFFFF tr:FFFFFFFF bl:FFFFFFFF br:FFFFFFFF'])")
				self.m_pNextSpeed:setText(tostring(nextSpeed) .. "(+" .. "[colrect='tl:FF33FF33 tr:FF33FF33 bl:FF33FF33 br:FF33FF33']" .. tostring(nextSpeed - curSpeed) .. "[colrect='tl:FFFFFFFF tr:FFFFFFFF bl:FFFFFFFF br:FFFFFFFF'])")
				self.m_pNextLife:setText(tostring(nextLife) .. "(+" .. "[colrect='tl:FF33FF33 tr:FF33FF33 bl:FF33FF33 br:FF33FF33']" .. tostring(nextLife - curLife) .. "[colrect='tl:FFFFFFFF tr:FFFFFFFF bl:FFFFFFFF br:FFFFFFFF'])")
				self.m_pNextScore:setText(tostring(nextScore) .. "(+" .. "[colrect='tl:FF33FF33 tr:FF33FF33 bl:FF33FF33 br:FF33FF33']" .. tostring(nextScore - curScore) .. "[colrect='tl:FFFFFFFF tr:FFFFFFFF bl:FFFFFFFF br:FFFFFFFF'])")

				self.m_pXuemaiUse:setText(tostring(petStar.usexuemai))
				self.m_pExpBar:setText(tostring(petInfo:getAttribute(knight.gsp.attr.AttrType.PET_XUEMAI)) .. "/" .. tostring(petStar.needxuemai))
				self.m_pExpBar:setProgress(petInfo:getAttribute(knight.gsp.attr.AttrType.PET_XUEMAI) / petStar.needxuemai)
			end
		

            self.m_pXuemaiAll:setText(tostring(GetDataManager():GetMainCharacterData():GetValue(knight.gsp.attr.AttrType.PET_XUEMAI)))
            self.m_iUseXuemai = petStar.usexuemai
        else
            self.m_pBack:setVisible(false)
        end
	else
		self.m_pBack:setVisible(false)
	end
end

function PetStarDlg:HandleGetXuemaiClicked(args)
	LogInfo("petstardlg getxuemai btn clicked")
	PetLabel.Show(4)	
	PetChipDlg.ShowTab(2)
	return true
end

function PetStarDlg:HandleOKBtnClicked(agrs)
	LogInfo("petstardlg ok btn clicked")

	if self.m_iSelectID then
		if GetDataManager():FindMyPetByID(self.m_iSelectID) then
			local petInfo = GetDataManager():FindMyPetByID(self.m_iSelectID)
			local starlevel = petInfo.starId
			local petStar = knight.gsp.pet.GetCPetstarsTableInstance():getRecorder(starlevel)
			if GetDataManager():GetMainCharacterData():GetValue(knight.gsp.attr.AttrType.PET_XUEMAI) < petStar.usexuemai then
				GetGameUIManager():AddMessageTipById(144901)
				return true
			end
			if starlevel >= 64 then
				return true
			end
			GetNetConnection():send(knight.gsp.pet.CReqStar(self.m_iSelectID, self.m_iUseXuemai))
		end
	end
	return true
end


function PetStarDlg:HandlePetSelect(args)
	LogInfo("petstardlg handle pet select")
	local e = CEGUI.toWindowEventArgs(args)
	local id = e.window:getID()
	local petinfo = GetDataManager():getPet(id)
	if petinfo then 
		if petinfo.key ~= self.m_iSelectID then 
			self.m_iSelectID = petinfo.key
			self:refreshPetSelectState()
			self:InitInfo()	
		end
	end	
	return true
end

function PetStarDlg:refreshPetSelectState()
	LogInfo("petstardlg refresh pet select state")
	if self.m_iSelectID then
		for i,v in pairs(self.m_petDlgList) do
			local petInfo = GetDataManager():getPet(v.m_pWnd:getID())
			if petInfo then 
				if petInfo.key == self.m_iSelectID then
					v:SetSelected(true)				
				else
					v:SetSelected(false)				
				end
			end		
		end
	end

end
return PetStarDlg
