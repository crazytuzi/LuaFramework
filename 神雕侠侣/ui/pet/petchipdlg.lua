require "ui.dialog"
require "utils.tableutil"
require "utils.stringbuilder"
require "utils.mhsdutils"
require "ui.pet.petchipcell"
require "ui.pet.petfreecell"
require "protocoldef.knight.gsp.pet.cfreepet1"
require "protocoldef.knight.gsp.pet.cpetchipsaction1"

require "manager.beanconfigmanager"
require "protocoldef.knight.gsp.pet.cpetgotfreexuemailist"

PetChipDlg = {

m_freeGotXieMaiList = nil,

}

setmetatable(PetChipDlg, Dialog)
PetChipDlg.__index = PetChipDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;

function PetChipDlg.getInstance()
	LogInfo("enter get petchipdlg instance")
    if not _instance then
        _instance = PetChipDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function PetChipDlg.getInstanceAndShow()
	LogInfo("enter petchipdlg instance show")
    if not _instance then
        _instance = PetChipDlg:new()
        _instance:OnCreate()
	else
		LogInfo("set petchipdlg visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function PetChipDlg.getInstanceNotCreate()
    return _instance
end

function PetChipDlg.DestroyDialog()
	if _instance then 
		LogInfo("destroy petchipdlg")
		if PetLabel.getInstanceNotCreate() then
			PetLabel.getInstanceNotCreate().DestroyDialog()		
		else
			_instance:CloseDialog()
		end
	end
end

--called by label,release resource here
function PetChipDlg:CloseDialog()
	if _instance then
		_instance:ResetAll()
		GetDataManager().EventRemovePet:RemoveScriptFunctor(_instance.m_hRemovePet)
		GetDataManager().EventXuemaiChange:RemoveScriptFunctor(_instance.m_hXuemaiChange)
		_instance:OnClose()
		_instance = nil
	end
end

function PetChipDlg.ToggleOpenClose()
	if not _instance then 
		_instance = PetChipDlg:new() 
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

function PetChipDlg.ShowTab(index)
	if _instance then
		LogInfo("petchipdlg showtab")
		for i = 1,3 do
			if i == index then
				_instance.m_pGroupBtn[i]:setSelected(true)
				_instance.m_pTab[i]:setVisible(true)
			else
				_instance.m_pGroupBtn[i]:setSelected(false)
				_instance.m_pTab[i]:setVisible(false)
			end
		end
		_instance:RemoveAllSelect()
		_instance:RefreshPaneInfo()
        
        if index == 3 then
            print("____send CPetGotFreeXueMaiList")
            local getFreeXieMaiListAction = CPetGotFreeXueMaiList.Create()
            LuaProtocolManager.getInstance():send(getFreeXieMaiListAction)
        end

	end
end

function PetChipDlg.setChipsInfo(chips)
	if _instance then
		LogInfo("petchipdlg set chips info")
		_instance.m_chips = {}
		_instance.m_chips = chips
		
		_instance.m_resolveSelect = nil
		_instance.m_resolveSelect = {}
		for i,v in pairs(chips) do
			_instance.m_resolveSelect[i] = false	
		end
		_instance:RefreshPaneInfo()
	end
end

function PetChipDlg.performPostRenderFunctions(id)
	if _instance then
		if _instance.m_lCombineList then 
			_instance:DrawCombineSprite(id)
		elseif _instance.m_lResolveList then
			_instance:DrawResolveSprite(id)
		elseif _instance.m_lFreeList then
			_instance:DrawFreeSprite(id)
		end
	end
end

function PetChipDlg.RemovePet(id)
	if _instance then
		if _instance.m_pGroupBtn[1]:getSelectedButtonInGroup():getID() == 3 then
			LogInfo("petchipdlg remove pet")
			if PetLabel.getInstanceNotCreate() then
				if PetLabel.getInstanceNotCreate().m_index ~= 4 then
					return
				end	
			end
			_instance.m_freePetSelect = nil
			local petNum = GetDataManager():GetPetNum()
			_instance.m_freePetSelect = {}
			for i = 1, petNum do
				local petInfo = GetDataManager():getPet(i)
				_instance.m_freePetSelect[petInfo.key] = false
			end
			_instance:RemoveAllSelect()
			_instance:RefreshPaneInfo()
		end
	end 
end

function PetChipDlg.RoleXuemaiChange()
	if _instance then
		LogInfo("petchipdlg role xuemai change")
		if PetLabel.getInstanceNotCreate() then
			if PetLabel.getInstanceNotCreate().m_index ~= 4 then
				return
			end	
		end
		_instance:RefreshXuemai()
	end
end

function PetChipDlg.GetLayoutFileName()
    return "petchipdlg.layout"
end

function PetChipDlg:RefreshGotFreeXieMaiList(freeXieMaiList)
    LogInfo("____PetChipDlg:RefreshGotFreeXieMaiList")

    self.m_freeGotXieMaiList = freeXieMaiList
    self:RefreshFreeXueMaiShow()
end

function PetChipDlg:OnCreate()
	LogInfo("petchipdlg oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
	self.m_pGroupBtn = {}
	self.m_pGroupBtn[1] = CEGUI.Window.toGroupButton(winMgr:getWindow("petchipdlg/main/btn0"))
	self.m_pGroupBtn[2] = CEGUI.Window.toGroupButton(winMgr:getWindow("petchipdlg/main/btn1"))
	self.m_pGroupBtn[3] = CEGUI.Window.toGroupButton(winMgr:getWindow("petchipdlg/main/btn2"))
	
	self.m_pTab = {}
	self.m_pTab[1] = winMgr:getWindow("petchipdlg/main/info0")
	self.m_pTab[2] = winMgr:getWindow("petchipdlg/main/info1")
	self.m_pTab[3] = winMgr:getWindow("petchipdlg/main/info2")

	self.m_pCombinePane = winMgr:getWindow("petchipdlg/main/scroll0")
	self.m_pCombineBtn = CEGUI.Window.toPushButton(winMgr:getWindow("petchipdlg/main/ok0"))
	self.m_pCombinePreBtn = CEGUI.Window.toPushButton(winMgr:getWindow("petchipdlg/main/info/left0"))
	self.m_pCombineNextBtn = CEGUI.Window.toPushButton(winMgr:getWindow("petchipdlg/main/info/right0"))

	self.m_pResolvePane = winMgr:getWindow("petchipdlg/main/scroll1")
	self.m_pResolveBtn = CEGUI.Window.toPushButton(winMgr:getWindow("petchipdlg/main/ok1"))	
	self.m_pResolveXuemai = winMgr:getWindow("petchipdlg/main/num1")
    
	self.m_pResolvePreBtn = CEGUI.Window.toPushButton(winMgr:getWindow("petchipdlg/main/info/left1"))
	self.m_pResolveNextBtn = CEGUI.Window.toPushButton(winMgr:getWindow("petchipdlg/main/info/right1"))

	self.m_pFreePane = winMgr:getWindow("petchipdlg/main/scroll2")
	self.m_pFreeBtn = CEGUI.Window.toPushButton(winMgr:getWindow("petchipdlg/main/ok2"))
	self.m_pFreeXuemai = winMgr:getWindow("petchipdlg/main/num2")

	self.m_pFreePreBtn = CEGUI.Window.toPushButton(winMgr:getWindow("petchipdlg/main/info/left2"))
	self.m_pFreeNextBtn = CEGUI.Window.toPushButton(winMgr:getWindow("petchipdlg/main/info/right2"))

    -- subscribe event
    self.m_pCombineBtn:subscribeEvent("Clicked", PetChipDlg.HandleCombineBtnClicked, self)
	self.m_pResolveBtn:subscribeEvent("Clicked", PetChipDlg.HandleResolveBtnClicked, self)
	self.m_pFreeBtn:subscribeEvent("Clicked", PetChipDlg.HandleFreeBtnClicked, self)
    
	self.m_pCombinePreBtn:subscribeEvent("Clicked", PetChipDlg.HandlePreBtnClicked, self)
	self.m_pResolvePreBtn:subscribeEvent("Clicked", PetChipDlg.HandlePreBtnClicked, self)
	self.m_pFreePreBtn:subscribeEvent("Clicked", PetChipDlg.HandlePreBtnClicked, self)
	
	self.m_pCombineNextBtn:subscribeEvent("Clicked", PetChipDlg.HandleNextBtnClicked, self)
	self.m_pResolveNextBtn:subscribeEvent("Clicked", PetChipDlg.HandleNextBtnClicked, self)
	self.m_pFreeNextBtn:subscribeEvent("Clicked", PetChipDlg.HandleNextBtnClicked, self)

	for i = 1,3 do
		self.m_pGroupBtn[i]:setID(i)
   		self.m_pGroupBtn[i]:subscribeEvent("SelectStateChanged", PetChipDlg.HandleSelectStateChanged, self) 
		if i == 1 then
			self.m_pGroupBtn[i]:setSelected(true)
			self.m_pTab[i]:setVisible(true)
		else
			self.m_pGroupBtn[i]:setSelected(false)
			self.m_pTab[i]:setVisible(false)
		end
	end

	local petNum = GetDataManager():GetPetNum()
	self.m_freePetSelect = {}
	for i = 1, petNum do
		local petInfo = GetDataManager():getPet(i)
		self.m_freePetSelect[petInfo.key] = false
	end

	self.m_iCurPage = 1
	GetNetConnection():send(knight.gsp.pet.CReqPetChips())

	self:RefreshBtn()
	self.m_hRemovePet = GetDataManager().EventRemovePet:InsertScriptFunctor(PetChipDlg.RemovePet)
	self.m_hXuemaiChange = GetDataManager().EventXuemaiChange:InsertScriptFunctor(PetChipDlg.RoleXuemaiChange)

	LogInfo("petchipdlg oncreate end")
end

------------------- private: -----------------------------------

function PetChipDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, PetChipDlg)
    return self
end

function PetChipDlg:RefreshBtn()
	LogInfo("petchipdlg refresh button")
	local selectTab = self.m_pGroupBtn[1]:getSelectedButtonInGroup():getID()
	if selectTab == 1 and self.m_chips then
		if self.m_lCombineList then
			self.m_pCombineBtn:setEnabled(false)
			for i,v in ipairs(self.m_lCombineList) do
				if v.id == self.m_iSelect and v.pCell then
					self.m_pCombineBtn:setEnabled(true)
					v.pCell:setSelect(true)
				elseif v.pCell then
					v.pCell:setSelect(false)
				end
			end
		end
	elseif selectTab == 2 and self.m_chips then
		self.m_pResolveBtn:setEnabled(false)
		if self.m_lResolveList then
			for i,v in ipairs(self.m_lResolveList) do
				if self.m_resolveSelect[v.id] then
					self.m_pResolveBtn:setEnabled(true)
					if v.pCell then
						v.pCell:setSelect(true)
					end
				elseif v.pCell then
					v.pCell:setSelect(false)
				end
			end
		end
	elseif selectTab == 3 then
		self.m_pFreeBtn:setEnabled(false)
		if self.m_lFreeList then
			for i,v in ipairs(self.m_lFreeList) do
				if self.m_freePetSelect[v.id] then
					self.m_pFreeBtn:setEnabled(true)
					if v.pCell then
						v.pCell:setSelect(true)
					end
				elseif v.pCell then
					v.pCell:setSelect(false)
				end
			end
		end
	end

end

function PetChipDlg:HandleSelectStateChanged(args)
	LogInfo("petchipdlg select state change")
	local selected = self.m_pGroupBtn[1]:getSelectedButtonInGroup():getID()
	for i = 1, 3 do
		self.m_pTab[i]:setVisible(false)
	end
	self.m_pTab[selected]:setVisible(true)
	self.m_iCurPage = 1
	self:RemoveAllSelect()
	self:RefreshPaneInfo()
    
    if selected == 3 then
        print("____send CPetGotFreeXueMaiList")
        local getFreeXieMaiListAction = CPetGotFreeXueMaiList.Create()
        LuaProtocolManager.getInstance():send(getFreeXieMaiListAction)
    end

	return true
end

function PetChipDlg:RefreshPaneInfo()
	LogInfo("petchipdlg refresh pane info")
	local selected = self.m_pGroupBtn[1]:getSelectedButtonInGroup():getID()
	if selected == 1 and self.m_chips then
		self:RefreshCombineInfo()
	elseif selected == 2 and self.m_chips then
		self:RefreshResolveInfo()
	elseif selected == 3 then
		self:RefreshFreeInfo()
	end
end

function PetChipDlg:RefreshFreeInfo()
	LogInfo("petchipdlg refresh free info")
    self:RefreshFreeXueMaiShow()
	self:ResetAll()

	if not self.m_iCurPage then
		self.m_iCurPage = 1
	end
	local numPerPage = 4
	local allNum = GetDataManager():GetPetNum() 
	if allNum == 0 then
		self.m_pFreePreBtn:setEnabled(false)
		self.m_pFreeNextBtn:setEnabled(false)
		self:RefreshBtn()
		return
	end

	local allPages = math.floor((allNum - 1) / numPerPage) + 1
	if allPages < self.m_iCurPage then
		self.m_iCurPage = allPages
	end
	
	if self.m_iCurPage == 1 then
		self.m_pFreePreBtn:setEnabled(false)
	else
		self.m_pFreePreBtn:setEnabled(true)
	end

	if self.m_iCurPage >= allPages then
		self.m_pFreeNextBtn:setEnabled(false)
	else
		self.m_pFreeNextBtn:setEnabled(true)
	end	

	self.m_lFreeList = {}
	local num = GetDataManager():GetPetNum()
	for i = 1, num do 
		local freeCell = {}
		local petInfo = GetDataManager():getPet(i)
		freeCell.id = petInfo.key
		freeCell.petInfo = petInfo
		table.insert(self.m_lFreeList, freeCell)
	end

	local startPos = numPerPage * (self.m_iCurPage - 1) 
	local endPos = startPos + numPerPage - 1
	for i,v in ipairs(self.m_lFreeList) do
		if (i - 1) >= startPos and (i - 1) <= endPos then
			v.pCell = PetFreeCell.CreateNewDlg(self.m_pFreePane)
			v.pCell:Init(GetDataManager():FindMyPetByID(v.id))
			v.pCell:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0 ,(i - 1 - startPos) * v.pCell:GetWindow():getPixelSize().width + 1), CEGUI.UDim(0,0))) 
		elseif (i - 1) > endPos then
			break
		end
	end

	self:RefreshBtn()
end

function PetChipDlg:RefreshCombineInfo()
	LogInfo("petchipdlg refresh combine info")
	self:ResetAll()

	if not self.m_iCurPage then
		self.m_iCurPage = 1
	end
	local numPerPage = 4
	local allNum = TableUtil.tablelength(self.m_chips)
	if allNum == 0 then
		self.m_pCombinePreBtn:setEnabled(false)
		self.m_pCombineNextBtn:setEnabled(false)
		self:RefreshBtn()
		return
	end

	local allPages = math.floor((allNum - 1) / numPerPage) + 1
	if allPages < self.m_iCurPage then
		self.m_iCurPage = allPages
	end
	
	if self.m_iCurPage == 1 then
		self.m_pCombinePreBtn:setEnabled(false)
	else
		self.m_pCombinePreBtn:setEnabled(true)
	end

	if self.m_iCurPage >= allPages then
		self.m_pCombineNextBtn:setEnabled(false)
	else
		self.m_pCombineNextBtn:setEnabled(true)
	end	


	self.m_lCombineList = {}
	for i,v in pairs(self.m_chips) do
		local combineCell = {}
		combineCell.iCurNum = v
		local petChip = knight.gsp.pet.GetCPetchipTableInstance():getRecorder(i)
		combineCell.iNeedNum = petChip.neednum
		combineCell.color = petChip.petcolor
		combineCell.id = i	

		table.insert(self.m_lCombineList, combineCell)
	end
	table.sort(self.m_lCombineList, PetChipDlg.SortCombine)

	local startPos = numPerPage * (self.m_iCurPage - 1) 
	local endPos = startPos + numPerPage - 1
	for i,v in ipairs(self.m_lCombineList) do
		if (i - 1) >= startPos and (i - 1) <= endPos then
			v.pCell = PetChipCell.CreateNewDlg(self.m_pCombinePane)
			v.pCell:Init(v.iCurNum, v.id)
			v.pCell:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0 ,(i - 1 - startPos) * v.pCell:GetWindow():getPixelSize().width + 1), CEGUI.UDim(0,0))) 
		elseif (i - 1) > endPos then
			break
		end
	end

	if self.m_iSelect then
		for i,v in pairs(self.m_lCombineList) do
			if self.m_iSelect == v.id and v.pCell then
				self:RefreshBtn()
				return
			end
		end
	end
	self.m_iSelect = nil
	
	for i,v in ipairs(self.m_lCombineList) do 
		if (i - 1) >= startPos and (i - 1) <= endPos then
			if not self.m_iSelect then
				self.m_iSelect = v.id
				break
			end
		elseif (i - 1) > endPos then
			break
		end	
	end

	self:RefreshBtn()
end

function PetChipDlg.SortCombine(combine1, combine2)
	if combine1.iCurNum >= combine1.iNeedNum and combine2.iCurNum >= combine2.iNeedNum then
		return combine1.color > combine2.color
	elseif combine1.iCurNum < combine1.iNeedNum and combine2.iCurNum < combine2.iNeedNum then
		return combine1.color > combine2.color
	else
		if combine1.iCurNum >= combine1.iNeedNum then
			return true
		else
			return false
		end
	end
end


function PetChipDlg:RefreshResolveInfo()
	LogInfo("petchipdlg refresh resolve info")
	self:ResetAll()
    self:RefreshResolveXueMaiShow()

	if not self.m_iCurPage then
		self.m_iCurPage = 1
	end
	local numPerPage = 4
	local allNum = TableUtil.tablelength(self.m_chips)
	if allNum == 0 then
		self.m_pResolvePreBtn:setEnabled(false)
		self.m_pResolveNextBtn:setEnabled(false)
		self:RefreshBtn()
		return
	end

	local allPages = math.floor((allNum - 1) / numPerPage) + 1
	if allPages < self.m_iCurPage then
		self.m_iCurPage = allPages
	end
	
	if self.m_iCurPage == 1 then
		self.m_pResolvePreBtn:setEnabled(false)
	else
		self.m_pResolvePreBtn:setEnabled(true)
	end

	if self.m_iCurPage >= allPages then
		self.m_pResolveNextBtn:setEnabled(false)
	else
		self.m_pResolveNextBtn:setEnabled(true)
	end	

	self.m_lResolveList = {}
	for i,v in pairs(self.m_chips) do
		local resolveCell = {}
		resolveCell.iCurNum = v
		local petChip = knight.gsp.pet.GetCPetchipTableInstance():getRecorder(i)
		resolveCell.iNeedNum = petChip.neednum
		resolveCell.color = petChip.petcolor
		resolveCell.id = i
	
		table.insert(self.m_lResolveList, resolveCell)

	end
	table.sort(self.m_lResolveList, PetChipDlg.SortResolve)

	local startPos = numPerPage * (self.m_iCurPage - 1) 
	local endPos = startPos + numPerPage - 1
	for i,v in ipairs(self.m_lResolveList) do
		if (i - 1) >= startPos and (i - 1) <= endPos then
			v.pCell = PetChipCell.CreateNewDlg(self.m_pResolvePane)
			v.pCell:Init(v.iCurNum, v.id)
			v.pCell:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0 ,(i - 1 - startPos) * v.pCell:GetWindow():getPixelSize().width + 1), CEGUI.UDim(0,0))) 
		elseif (i - 1) > endPos then
			break
		end
	end
	self:RefreshBtn()
end

function PetChipDlg.SortResolve(combine1, combine2)
	return PetChipDlg.SortCombine(combine2, combine1)
end

function PetChipDlg:ResetAll()
	if self.m_lCombineList then
		for i,v in ipairs(self.m_lCombineList) do
			if v.pCell then 
				v.pCell:DeleteSprite()
			end
		end
	end

	if self.m_lResolveList then
		for i,v in ipairs(self.m_lResolveList) do
			if v.pCell then
				v.pCell:DeleteSprite()
			end
		end
	end

	if self.m_lFreeList then
		for i,v in ipairs(self.m_lFreeList) do
			if v.pCell then
				v.pCell:DeleteSprite()
			end
		end
	end

	self.m_pCombinePane:cleanupNonAutoChildren()
	self.m_pResolvePane:cleanupNonAutoChildren()
	self.m_pFreePane:cleanupNonAutoChildren()

	self.m_lCombineList = nil
	self.m_lResolveList = nil
	self.m_lFreeList = nil
end

function PetChipDlg:HandleChipSelect(args)
	LogInfo("petchipdlg chip select")
	local e = CEGUI.toWindowEventArgs(args)
	local id = e.window:getID()

	local selectTab = self.m_pGroupBtn[1]:getSelectedButtonInGroup():getID()
	if selectTab == 1 then
		self.m_iSelect = id
	elseif selectTab == 2 then
		self.m_resolveSelect[id] = not self.m_resolveSelect[id] 
	elseif selectTab == 3 then
		self.m_freePetSelect[id] = not self.m_freePetSelect[id]
	end

	self:RefreshBtn()
    
    if selectTab == 2 then
        self:RefreshResolveXueMaiShow()
    elseif selectTab == 3 then
        self:RefreshFreeXueMaiShow()
    end

	return true	
end

function PetChipDlg:DrawFreeSprite(id)
	for i,v in ipairs(self.m_lFreeList) do
		if v.id == id then
			v.pCell:DrawSprite()
			break
		end
	end
end

function PetChipDlg:DrawCombineSprite(id)
	for i,v in ipairs(self.m_lCombineList) do 
		if v.id == id then
			v.pCell:DrawSprite()
			break
		end
	end
end

function PetChipDlg:DrawResolveSprite(id)
	for i,v in ipairs(self.m_lResolveList) do 
		if v.id == id then
			v.pCell:DrawSprite()
			break
		end
	end
end

function PetChipDlg:HandleCombineBtnClicked(args)
	LogInfo("petchipdlg handle combine btn clicked")
	if not self.m_iSelect then
		return true
	elseif GetDataManager():GetMaxPetNum() <= GetDataManager():GetPetNum() then
		GetGameUIManager():AddMessageTipById(144906)
		return true
	end
	for i,v in ipairs(self.m_lCombineList) do
		if v.id == self.m_iSelect then
			if v.iCurNum < v.iNeedNum then
				GetGameUIManager():AddMessageTipById(144905)
				return true
			else
				local petChipsAction = CPetChipsAction1.Create()
				petChipsAction.flag = 0
				table.insert(petChipsAction.chipids, self.m_iSelect)
				LuaProtocolManager.getInstance():send(petChipsAction)
				break
			end	
		end		
	end	

	return true
end

function PetChipDlg:HandleResolveBtnClicked(args)
	LogInfo("petchipdlg handle resolve btn clicked")
	local resolveList = {} 
	for i,v in pairs(self.m_resolveSelect) do
		if v then
			table.insert(resolveList, i)
		end
	end
	if TableUtil.tablelength(resolveList) == 0 then
		return true
	end
	local petChipsAction = CPetChipsAction1.Create()
	petChipsAction.flag = 1
	petChipsAction.chipids = resolveList
	LuaProtocolManager.getInstance():send(petChipsAction)
	return true
end

function PetChipDlg:HandleFreeBtnClicked(args)
	LogInfo("petchipdlg handle free btn clicked")

	self.needComfirm = false
	self.needComfirmXianTian = false
	self.m_freeVec = nil
	self.m_freeVec = {}
	for i,v in pairs(self.m_freePetSelect) do
		if v then
			table.insert(self.m_freeVec, i)
			local petInfo = GetDataManager():FindMyPetByID(i)
			if petInfo.colour >= 4 then
				self.needComfirm = true
				self.needComfirm = true 
			end	
			local record = knight.gsp.pet.GetCPetAttrTableInstance():getRecorder(petInfo.baseid)
			for i=0, record.skillid:size()-1 do
				for j=1, petInfo:getSkilllistlen() do
					if math.floor(record.skillid[i]/100) == math.floor(petInfo:getSkill(j).skillid/100) then
						if math.mod(petInfo:getSkill(j).skillid, 100) ~= 1 then
							self.needComfirmXianTian = true
						end
					end
				end
			end
		end
	end
	
	if TableUtil.tablelength(self.m_freeVec) == 0 then
		return true
	end
	if self.needComfirm then
		GetMessageManager():AddConfirmBox(eConfirmNormal,MHSD_UTILS.get_msgtipstring(144911),PetChipDlg.HandleFreeConfirmClicked,self,CMessageManager.HandleDefaultCancelEvent,CMessageManager)
		return true
	end
	if self.needComfirmXianTian then
		GetMessageManager():AddConfirmBox(eConfirmNormal,MHSD_UTILS.get_msgtipstring(145526),PetChipDlg.HandleFreeConfirmXianTianClicked,self,CMessageManager.HandleDefaultCancelEvent,CMessageManager)
		return true
	end
    local freePet = CFreePet1.Create()
	freePet.petkeys = self.m_freeVec
    LuaProtocolManager.getInstance():send(freePet)

	return true
end

-- 先天技能没有摘下
function PetChipDlg:HandleFreeConfirmXianTianClicked(args)
	LogInfo("petchipdlg handle free xiantian confirm clicked")
    local freePet = CFreePet1.Create()
	freePet.petkeys = self.m_freeVec
    LuaProtocolManager.getInstance():send(freePet)
	GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
	return true
end

function PetChipDlg:HandleFreeConfirmClicked(args)
	LogInfo("petchipdlg handle free confirm clicked")
	if self.needComfirmXianTian then
		GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
		GetMessageManager():AddConfirmBox(eConfirmNormal,MHSD_UTILS.get_msgtipstring(145526),PetChipDlg.HandleFreeConfirmXianTianClicked,self,CMessageManager.HandleDefaultCancelEvent,CMessageManager)
		return true
	end
    local freePet = CFreePet1.Create()
	freePet.petkeys = self.m_freeVec
    LuaProtocolManager.getInstance():send(freePet)
  	GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
end

function PetChipDlg:RefreshResolveXueMaiShow()
    LogInfo("____PetChipDlg:RefreshResolveXueMaiShow")
    
    if self.m_pResolveXuemai then
        local xuemaiAdd = 0
        
        local tablePetChip = knight.gsp.pet.GetCPetchipTableInstance()
        
        if self.m_lResolveList then
            for k,v in pairs(self.m_lResolveList) do
                if self.m_resolveSelect and self.m_resolveSelect[v.id] then
                    print("____select pet chip id: " .. v.id)

                    local petChip = tablePetChip:getRecorder(v.id)
                    if petChip and petChip.id ~= -1 and v.iCurNum > 0 then
                        xuemaiAdd = xuemaiAdd + v.iCurNum * math.floor(petChip.uprate)
                    else
                        print("____error not get pet chip record or v.iCurNum <= 0")
                    end
                end
            end
        end
        
        local numOld = GetDataManager():GetMainCharacterData():GetValue(knight.gsp.attr.AttrType.PET_XUEMAI)
        
        if xuemaiAdd > 0 then
            self.m_pResolveXuemai:setText(tostring(numOld) .. "[colour='FF00FF00']+" .. tostring(xuemaiAdd))
        else
            self.m_pResolveXuemai:setText(tostring(numOld))
        end
    end
end

function PetChipDlg:RefreshFreeXueMaiShow()
    LogInfo("____PetChipDlg:RefreshFreeXueMaiShow")
    
    if self.m_freeGotXieMaiList then
        for kk,vv in pairs(self.m_freeGotXieMaiList) do
            local petInfo = GetDataManager():FindMyPetByID(kk)
            print("____pet key: " .. kk)
            
            if petInfo and petInfo.baseid then
                print("____pet id: " .. petInfo.baseid)
            end
        end
    end

    if self.m_pFreeXuemai then
        local xuemaiAdd = 0
        
        if self.m_freePetSelect then
            for k,v in pairs(self.m_freePetSelect) do
                if v then
                    print("____select pet key: " .. k)
                    if self.m_freeGotXieMaiList and self.m_freeGotXieMaiList[k] and self.m_freeGotXieMaiList[k] > 0 then
                        print("____self.m_freeGotXieMaiList[k]: " .. self.m_freeGotXieMaiList[k])
                        xuemaiAdd = xuemaiAdd + self.m_freeGotXieMaiList[k]
                    else
                        print("____error not get self.m_freeGotXieMaiList[k] or self.m_freeGotXieMaiList[k] <= 0")
                    end
                end
            end
        end
        
        local numOld = GetDataManager():GetMainCharacterData():GetValue(knight.gsp.attr.AttrType.PET_XUEMAI)
        
        if xuemaiAdd > 0 then
            self.m_pFreeXuemai:setText(tostring(numOld) .. "[colour='FF00FF00']+" .. tostring(xuemaiAdd))
        else
            self.m_pFreeXuemai:setText(tostring(numOld))
        end
    end
end

function PetChipDlg:RefreshXuemai()
	LogInfo("petchipdlg refresh xuemai")

    self:RefreshResolveXueMaiShow()
	self:RefreshFreeXueMaiShow()
end

function PetChipDlg:HandlePreBtnClicked(args)
	if not self.m_iCurPage then
		self.m_iCurPage = 1
	else
		self.m_iCurPage = self.m_iCurPage - 1
	end

	self.m_iSelect = nil
	self:RefreshPaneInfo()

	return true
end

function PetChipDlg:HandleNextBtnClicked(args)
	if not self.m_iCurPage then
		self.m_iCurPage = 1
	else
		self.m_iCurPage = self.m_iCurPage + 1
	end
	self.m_iSelect = nil
	self:RefreshPaneInfo()
	return true
end

function PetChipDlg:RemoveAllSelect()
	LogInfo("petchipdlg remove all select")
	if self.m_freePetSelect then
		for i,v in pairs(self.m_freePetSelect) do
			self.m_freePetSelect[i] = false
		end
	end
	self.m_iSelect = nil
	if self.m_resolveSelect then
		for i,v in pairs(self.m_resolveSelect) do
			self.m_resolveSelect[i] = false
		end
	end
end

return PetChipDlg
