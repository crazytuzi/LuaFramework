require "ui.dialog"
require "utils.mhsdutils"
require "ui.pet.petlistcell"
PetTrainDlg = {}
setmetatable(PetTrainDlg, Dialog)
PetTrainDlg.__index = PetTrainDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;

function PetTrainDlg.getInstance()
	LogInfo("enter get petstardlg instance")
    if not _instance then
        _instance = PetTrainDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function PetTrainDlg.getInstanceAndShow()
	LogInfo("enter petstardlg instance show")
    if not _instance then
        _instance = PetTrainDlg:new()
        _instance:OnCreate()
	else
		LogInfo("set petstardlg visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function PetTrainDlg.getInstanceNotCreate()
    return _instance
end

function PetTrainDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, PetTrainDlg)
    return self
end

function PetTrainDlg.DestroyDialog()
	if _instance then 
		LogInfo("destroy petstardlg")
		GetRoleItemManager():RemoveLuaItemNumChangeNotify(_instance.m_hItemNumChangeNotify)
		if PetLabel.getInstanceNotCreate() then
			PetLabel.getInstanceNotCreate().DestroyDialog()		
		else
			_instance:CloseDialog()
		end
	end
end

--called by label,release resource here
function PetTrainDlg:CloseDialog()
	if _instance then
        GetRoleItemManager():RemoveLuaItemNumChangeNotify(_instance.m_hItemNumChangeNotify)
		GetDataManager().EventPetDataChange:RemoveScriptFunctor(_instance.m_hPetDataChange)
		_instance:OnClose()
		_instance = nil
	end
end

function PetTrainDlg.ToggleOpenClose()
	if not _instance then 
		_instance = PetTrainDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function PetTrainDlg.GetLayoutFileName()
	return "pettraindlg.layout"
end

function PetTrainDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.PetPane = CEGUI.toScrollablePane(winMgr:getWindow("pettraindlg/left"))
	self.PetAttrs = {}
	for i = 1, 5 do
		self.PetAttrs[i] = {}
		self.PetAttrs[i].Bar = CEGUI.toProgressBar(winMgr:getWindow("pettraindlg/right/back/bar"..i-1))
		self.PetAttrs[i].Result = winMgr:getWindow("pettraindlg/right/back/num"..i-1)
		self.PetAttrs[i].Bar:setProgress(0)
		self.PetAttrs[i].Result:setText("")
	end
	self.Wuxing = winMgr:getWindow("pettraindlg/right/back/txt5/bar5")
	self.Wuxing:setText(0)
	self.WuxingResult = winMgr:getWindow("pettraindlg/right/back/num5")
	self.WuxingResult:setText("")
	self.Score = winMgr:getWindow("pettraindlg/right/back/txt6/num")
	self.Score:setText(0)
	
	self.LeftNumber = winMgr:getWindow("pettraindlg/right/num")
	self.LeftNumber:setText(0)
	self.NormalTrain = CEGUI.toCheckbox(winMgr:getWindow("pettraindlg/right/check1"))
	self.RmbTrain = CEGUI.toCheckbox(winMgr:getWindow("pettraindlg/right/check2"))
	self.NormalTrain:subscribeEvent("CheckStateChanged", self.HandleNormalTrainStateChanged, self)
	self.RmbTrain:subscribeEvent("CheckStateChanged", self.HandleRmbTrainStateChanged, self)
	
	self.NormalTrainCostNum = winMgr:getWindow("pettraindlg/right/check1/num1")
	self.NormalNeedNum = 2
	self.NormalTrainCostNum:setText(self.NormalNeedNum)
	self.NormalTrainHasNum = winMgr:getWindow("pettraindlg/right/check1/num11")
	self.NormalTrainHasNum:setText(0)
	self.NormalTrain:setSelected(true)
	self.RmbTrainCostNum = winMgr:getWindow("pettraindlg/right/check2/num1")
	self.RmbNeedNum = 20
	self.RmbTrainCostNum:setText(self.RmbNeedNum)
	self.RmbTrainHasNum = winMgr:getWindow("pettraindlg/right/check2/num2")
	self.RmbTrainHasNum:setText(0)
	self.RmbTrain:setSelected(false)
	self.TrainButton = CEGUI.toPushButton(winMgr:getWindow("pettraindlg/right/btn"))
	self.TrainButton:subscribeEvent("MouseClick", self.HandleTrainBtnClicked, self)
	self.TrainPane = winMgr:getWindow("pettraindlg/right/1")
	self.CommitConfirmPane = winMgr:getWindow("pettraindlg/right/2")
	self.CommitButton = CEGUI.toPushButton(winMgr:getWindow("pettraindlg/right/ok"))
	self.CancelButton = CEGUI.toPushButton(winMgr:getWindow("pettraindlg/right/cancel"))
	self.CommitButton:subscribeEvent("MouseClick", self.HandleCommitBtnClicked, self)
	self.CancelButton:subscribeEvent("MouseClick", self.HandleCancelBtnClicked, self)
	self.TrainPane:setVisible(false)
	self.CommitConfirmPane:setVisible(false)
	self:InitPetList()
	self:RefreshSpends()
    self.m_hItemNumChangeNotify = GetRoleItemManager():InsertLuaItemNumChangeNotify(PetTrainDlg.OnItemNumberChange)
	self.m_hPetDataChange = GetDataManager().EventPetDataChange:InsertScriptFunctor(PetTrainDlg.PetDataChange)
end

function PetTrainDlg.PetDataChange(petkey)
	if _instance == nil then
		return
	end
	if PetLabel.getInstanceNotCreate() then
		if PetLabel.getInstanceNotCreate().m_index ~= 3 then
			return
		end	
	end
	if _instance.m_iSelectID == petkey then
		local petinfo = GetDataManager():FindMyPetByID(_instance.m_iSelectID)
		_instance:RefreshZizhi(petinfo)
	end
end

function PetTrainDlg.OnItemNumberChange(bagid, itemkey, itembaseid)
	LogInsane(string.format("PetTrainDlg.OnItemNumberChange(%d, %d, %d)", bagid, itemkey, itembaseid))
	if _instance == nil then
		return
	end	
	if PetLabel.getInstanceNotCreate() then
		if PetLabel.getInstanceNotCreate().m_index ~= 3 then
			return
		end	
	end
	if itembaseid ~= nil and itembaseid == 38005 then
		_instance:RefreshSpends()
	end
end

function PetTrainDlg:RefreshSpends()
	local itemid = 38005
	local itemnum = GetRoleItemManager():GetItemNumByBaseID(itemid)
	LogInsane("PetTrainDlg:RefreshSpends "..itemnum)
	self.NormalTrainHasNum:setText(itemnum)
	self.RmbTrainHasNum:setText(itemnum)
	if itemnum >= self.NormalNeedNum then
		self.NormalTrainCostNum:setProperty("TextColours", "FF00FF00")
	else
		self.NormalTrainCostNum:setProperty("TextColours", "FFFF0000")
	end
	if itemnum >= self.RmbNeedNum then
		self.RmbTrainCostNum:setProperty("TextColours", "FF00FF00")
	else
		self.RmbTrainCostNum:setProperty("TextColours", "FFFF0000")
	end
end

function PetTrainDlg:InitPetList()
	self.PetPane:cleanupNonAutoChildren()
	self.m_petDlgList = {}
	local petnum = GetDataManager():GetPetNum()
	for i = 1, petnum do
		self.m_petDlgList[i] = PetListCell.CreateNewDlg(self.PetPane, i)
		local height = (i - 1) * self.m_petDlgList[i]:GetWindow():getPixelSize().height + 1
		self.m_petDlgList[i]:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0 ,0), CEGUI.UDim(0, height)))
	end
	self:GetPetInfo()	
	for i = 1, #self.m_petList do 
		self.m_petDlgList[i]:SetInfo(self.m_petList[i], 3)	
	end
--[[
	for i = #self.m_petList + 1, maxnum do
		self.m_petDlgList[i]:SetEmpty()
	end
	if maxnum < 8 then
		self.m_petDlgList[maxnum + 1]:SetLock()
	end
--]]
	if self.m_iSelectID == nil or GetDataManager():FindMyPetByID(self.m_iSelectID) == nil then
		self.m_iSelectID = nil
	end

	if not self.m_iSelectID and #self.m_petDlgList >= 1 then
		self.m_iSelectID = GetDataManager():getPet(1).key
		for i,v in pairs(self.m_petDlgList) do
			local petInfo = GetDataManager():FindMyPetByID(v.m_pWnd:getID())
			if petInfo and petInfo.key == GetDataManager():GetBattlePetID() then
				self.m_iSelectID = petInfo.key
				break
			end
		end
	end

	if self.m_iSelectID then
		self:OnSelectedPet(self.m_iSelectID)
	end
--	if not self.m_iSelectID and #self.m_petList >= 1 then
--		self:OnSelectedPet(self.m_petList[1].key)
--	end
end

function PetTrainDlg:GetPetInfo()
	LogInfo("init petlist")

	local num = GetDataManager():GetPetNum()
	LogInfo("petnum = ", num)
	self.m_petList = {}
	for i = 1, num do
		self.m_petList[i] = GetDataManager():getPet(i)
	end
end

function PetTrainDlg:HandleNormalTrainStateChanged(e)
	if self.NormalTrain:isSelected() then
		if self.RmbTrain:isSelected() then
			self.RmbTrain:setSelected(false)
		end
	else
		if not self.RmbTrain:isSelected() then
			self.RmbTrain:setSelected(true)
		end
	end
	return true
end
function PetTrainDlg:HandleRmbTrainStateChanged(e)
	if self.RmbTrain:isSelected() then
		if self.NormalTrain:isSelected() then
			self.NormalTrain:setSelected(false)
		end
	else
		if not self.NormalTrain:isSelected() then
			self.NormalTrain:setSelected(true)
		end
	end
	return true
end
function PetTrainDlg:HandleTrainBtnClicked(e)
	LogInsane("Handle train")
	if self.m_iSelectID == nil or self.m_iSelectID == 0 then
		LogInsane("There is no selected pet")
		return true
	end
	local itemid = 38005
	local itemnum = GetRoleItemManager():GetItemNumByBaseID(itemid)
	
	local isItemEnough
	local flag
	if self.RmbTrain:isSelected() then
		flag = 1
		if itemnum >= 20 then
			isItemEnough = true
		else
			isItemEnough = false 
		end
	else
		flag = 0
		isItemEnough = itemnum >= 2
	end
	if not isItemEnough then
        if GetChatManager() then
            GetChatManager():AddTipsMsg(146306)
        end
        CGreenChannel:GetSingletonDialogAndShowIt():SetItem(itemid)
		return true
	end
	local petkey = self.m_iSelectID
	
	GetNetConnection():send(knight.gsp.pet.CPetPractise(petkey, flag))
end
function PetTrainDlg:HandleCommitBtnClicked(e)
	LogInsane("Handle commit")
	if self.m_iSelectID == nil or self.m_iSelectID == 0 then
		LogInsane("There is no selected pet")
		return true
	end
	GetNetConnection():send(knight.gsp.pet.CSetPractise(self.m_iSelectID, 1))
end
function PetTrainDlg:HandleCancelBtnClicked(e)
	LogInsane("Handle cancel")
	if self.m_iSelectID == nil or self.m_iSelectID == 0 then
		LogInsane("There is no selected pet")
		return true
	end
	GetNetConnection():send(knight.gsp.pet.CSetPractise(self.m_iSelectID, 0))
end

function PetTrainDlg:HandlePetClicked(e)
	local mouseArgs = CEGUI.toMouseEventArgs(e)
	LogInsane("Handle Pet Clicked"..mouseArgs.window:getName())
	local clickedpetkey = 0
	for i = 1, #self.m_petDlgList do
		LogInsane("check dlg name="..self.m_petDlgList[i].m_pWnd:getName())
		if self.m_petDlgList[i].m_pWnd == mouseArgs.window then
			clickedpetkey = mouseArgs.window:getID()
			LogInsane("Find item id="..clickedpetkey)
			break
		end
	end
	LogInsane("clicked petkey="..clickedpetkey)
	if clickedpetkey ~= 0 then
		self:OnSelectedPet(clickedpetkey)
	end
end

function PetTrainDlg:OnSelectedPet(petkey)
	if self.m_iSelectID and self.m_iSelectID ~= 0 then
		for i = 1, #self.m_petDlgList do
			if self.m_iSelectID == self.m_petDlgList[i].m_pWnd:getID() then
				self.m_petDlgList[i]:SetSelected(false)
				break
			end
		end
	end
	self.m_iSelectID = petkey
	for i = 1, #self.m_petDlgList do
		if self.m_iSelectID == self.m_petDlgList[i].m_pWnd:getID() then
			self.m_petDlgList[i]:SetSelected(true)
			break
		end
	end
	local petinfo = GetDataManager():FindMyPetByID(self.m_iSelectID)
	self:RefreshZizhi(petinfo)
	if self.m_iSelectID and GetDataManager():FindMyPetByID(self.m_iSelectID) then
		local petinfo = GetDataManager():FindMyPetByID(self.m_iSelectID)
		LogInsane("pet practiseTimes="..petinfo.practiseTimes)
		self.LeftNumber:setText(petinfo.practiseTimes)
	end
end

function PetTrainDlg:RefreshZizhi(petinfo)
	if petinfo then
		self.Wuxing:setText(tostring(petinfo:getAttribute(knight.gsp.attr.AttrType.PET_GENGU)))
		local petAttr = knight.gsp.pet.GetCPetAttrTableInstance():getRecorder(petinfo.baseid);
		PetTrainDlg.AdjustPetZizhiBar(petinfo:getAttribute(knight.gsp.attr.AttrType.PET_ATTACK_APT), petAttr.attackaptmax + 5 * petinfo:getAttribute(knight.gsp.attr.AttrType.LEVEL), self.PetAttrs[1].Bar) 
		PetTrainDlg.AdjustPetZizhiBar(petinfo:getAttribute(knight.gsp.attr.AttrType.PET_MAGIC_APT), petAttr.magicaptmax + 5 * petinfo:getAttribute(knight.gsp.attr.AttrType.LEVEL), self.PetAttrs[2].Bar) 
		PetTrainDlg.AdjustPetZizhiBar(petinfo:getAttribute(knight.gsp.attr.AttrType.PET_PHYFORCE_APT), petAttr.phyforceaptmax + 5 * petinfo:getAttribute(knight.gsp.attr.AttrType.LEVEL), self.PetAttrs[3].Bar) 
		PetTrainDlg.AdjustPetZizhiBar(petinfo:getAttribute(knight.gsp.attr.AttrType.PET_DEFEND_APT), petAttr.defendaptmax + 5 * petinfo:getAttribute(knight.gsp.attr.AttrType.LEVEL), self.PetAttrs[4].Bar) 
		PetTrainDlg.AdjustPetZizhiBar(petinfo:getAttribute(knight.gsp.attr.AttrType.PET_SPEED_APT), petAttr.speedaptmax + 5 * petinfo:getAttribute(knight.gsp.attr.AttrType.LEVEL), self.PetAttrs[5].Bar) 
		local hasZizhiResult = false
		hasZizhiResult = PetTrainDlg.AdjustPetZizhiResult(petinfo:getzizhi(knight.gsp.attr.AttrType.PET_ATTACK_APT), self.PetAttrs[1].Result) or hasZizhiResult
		hasZizhiResult = PetTrainDlg.AdjustPetZizhiResult(petinfo:getzizhi(knight.gsp.attr.AttrType.PET_MAGIC_APT), self.PetAttrs[2].Result) or hasZizhiResult
		hasZizhiResult = PetTrainDlg.AdjustPetZizhiResult(petinfo:getzizhi(knight.gsp.attr.AttrType.PET_PHYFORCE_APT), self.PetAttrs[3].Result) or hasZizhiResult
		hasZizhiResult = PetTrainDlg.AdjustPetZizhiResult(petinfo:getzizhi(knight.gsp.attr.AttrType.PET_DEFEND_APT), self.PetAttrs[4].Result) or hasZizhiResult
		hasZizhiResult = PetTrainDlg.AdjustPetZizhiResult(petinfo:getzizhi(knight.gsp.attr.AttrType.PET_SPEED_APT), self.PetAttrs[5].Result) or hasZizhiResult
		
		hasZizhiResult = PetTrainDlg.AdjustPetZizhiResult(petinfo.genguadd, self.WuxingResult) or hasZizhiResult
		if hasZizhiResult then
			self.TrainPane:setVisible(false)
			self.CommitConfirmPane:setVisible(true)
		else
			self.TrainPane:setVisible(true)
			self.CommitConfirmPane:setVisible(false)
		end
		LogInfo("end refresh zizhiinfo")
	else
		self.Wuxing:setText(0)
		for i = 1, 5 do
			PetTrainDlg.AdjustPetZizhiBar(0, 300, self.PetAttrs[i].Bar)
			PetTrainDlg.AdjustPetZizhiResult(0, self.PetAttrs[i].Result)
		end
		PetTrainDlg.AdjustPetZizhiResult(0, self.WuxingResult)
		self.TrainPane:setVisible(false)
		self.CommitConfirmPane:setVisible(false)
	end
end

function PetTrainDlg.AdjustPetZizhiBar(cur, max, bar, basicWidth, basicNum)
     LogInfo("AdjustPetZizhiBar")
  --   TODO
  --   why this sentence may cause crash??
  --   local origalwidth = bar:getWidth().offset
  --   LogInfo("origalwidth="..origalwidth)
     basicWidth = basicWidth or 204
     basicNum = basicNum or 1800
     local upWidth = cur / basicNum * basicWidth
     local backWidth = max / basicNum * basicWidth
     bar:setText(tostring(cur))
     bar:setWidth(CEGUI.UDim(0, backWidth))
     bar:setProgress(upWidth / backWidth)
end

function PetTrainDlg.AdjustPetZizhiResult(val, wnd)
	LogInsane("PetTrainDlg.AdjustPetZizhiResult"..wnd:getName())
	if val == nil or val == 0 then
		wnd:setText("")
		return false
	end
	if val > 0 then
		wnd:setText(string.format("+%d",math.abs(val)))
		wnd:setProperty("TextColours", "ff33ff33")
	else
		wnd:setText(string.format("-%d",math.abs(val)))
		wnd:setProperty("TextColours", "ffff3333")
	end
	return true
end
