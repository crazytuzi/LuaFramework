require "ui.dialog"
require "utils.mhsdutils"
require "ui.bandit.deliveryteam"
require "ui.bandit.deliverycell"
require "utils.tableutil"
require "protocoldef.knight.gsp.faction.cfreshbiaoches"
require "protocoldef.knight.gsp.faction.ccreatebiaoche"
require "utils.stringbuilder"

Bandit = {}
setmetatable(Bandit, Dialog)
Bandit.__index = Bandit

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
local totalTime = 120
local statNull = 1
local statInTeam = 2
local statRunning = 3
local cellPerPage = 5

function Bandit.getInstance()
	LogInfo("enter get Bandit instance")
    if not _instance then
        _instance = Bandit:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function Bandit.getInstanceAndShow()
	LogInfo("enter Bandit instance show")
    if not _instance then
        _instance = Bandit:new()
        _instance:OnCreate()
	else
		LogInfo("set Bandit visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function Bandit.getInstanceNotCreate()
    return _instance
end

function Bandit.DestroyDialog()
	if _instance then 
		LogInfo("destroy Bandit")
		if _instance.m_stat == statRunning then
			GetGameUIManager():AddMessageTipById(145192)	
			return
		end
		if _instance.m_stat == statInTeam then			
			_instance:ExitInTeam()
			return
		end
		if GetTeamManager() then
			GetTeamManager().EventMemberDataRefresh:RemoveScriptFunctor(_instance.m_hMemberDataRefresh)
		end
		_instance.m_pPane:cleanupNonAutoChildren()

		if _instance.m_pSprite then
			_instance.m_pSprite:delete()
			_instance.m_pSprite = nil
		end
		_instance.m_pHorse:getGeometryBuffer():setRenderEffect(nil)
	
  		GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
		_instance:OnClose()
		_instance = nil
	end
end

function Bandit.ToggleOpenClose()
	if not _instance then 
		_instance = Bandit:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function Bandit.TeamMemberStateChange()
	LogInfo("Bandit team member state change")
	if _instance and _instance.m_stat == statRunning then
		_instance:freshMemberState()
	end
end

----/////////////////////////////////////////------

function Bandit.GetLayoutFileName()
    return "bandit.layout"
end

function Bandit:OnCreate()
	LogInfo("Bandit oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pCreateBtn1 = CEGUI.Window.toPushButton(winMgr:getWindow("bandit/right1/xuanze11/chuangjian"))
	self.m_pCreateBtn2 = CEGUI.Window.toPushButton(winMgr:getWindow("bandit/right1/xuanze11/chuangjian1"))
   	self.m_pRefreshBtn = CEGUI.Window.toPushButton(winMgr:getWindow("bandit/right1/xuanze11/chuangjian11")) 
	self.m_pPane = CEGUI.Window.toScrollablePane(winMgr:getWindow("bandit/huadong"))
	self.m_pDeliveryTimes = winMgr:getWindow("bandit/right/top/txt11")
	self.m_pStart = winMgr:getWindow("bandit/ditu/chufadian")
	self.m_pEnd = winMgr:getWindow("bandit/ditu/chufadian1")
	self.m_pHorse = winMgr:getWindow("bandit/ditu/horse")
	self.m_pTime = winMgr:getWindow("bandit/ditu/shijian1")
	self.m_pTalk = CEGUI.toPushButton(winMgr:getWindow("bandit/laba"))
	self.m_pDimiss = winMgr:getWindow("bandit/huadong/yun")
	self.m_pBiaoPrice1 = winMgr:getWindow("bandit/ditu/shijian211")
	self.m_pBiaoPrice2 = winMgr:getWindow("bandit/ditu/shijian2111")
	self.m_pBiaoPrice3 = winMgr:getWindow("bandit/ditu/shijian21111")
	self.m_pItem1 = CEGUI.toItemCell(winMgr:getWindow("bandit/right1/xuanze11/baoxiang11"))
	self.m_pItem2 = CEGUI.toItemCell(winMgr:getWindow("bandit/right1/xuanze11/baoxiang111"))

	self.m_pCreateBtn1:setID(0)
	self.m_pCreateBtn2:setID(1)
	-- subscribe event
    self.m_pCreateBtn1:subscribeEvent("Clicked", Bandit.HandleCreateBtnClicked, self) 
	self.m_pCreateBtn2:subscribeEvent("Clicked", Bandit.HandleCreateBtnClicked, self)
	self.m_pRefreshBtn:subscribeEvent("Clicked", Bandit.HandleRefreshBtnClicked, self)
	self.m_pTalk:subscribeEvent("Clicked", Bandit.HandleTalkBtnClicked, self)
	self.m_pPane:subscribeEvent("NextPage", Bandit.HandleNextPage, self)


	self.m_startPos = self.m_pStart:GetScreenPos() - self.m_pStart:getParent():GetScreenPos()
	self.m_endPos = self.m_pEnd:GetScreenPos() - self.m_pEnd:getParent():GetScreenPos()

	self.m_stat = statNull
	self.m_pHorse:setVisible(false)
	self.m_pDimiss:setVisible(false)
	if GetTeamManager() then
		self.m_hMemberDataRefresh = GetTeamManager().EventMemberDataRefresh:InsertScriptFunctor(Bandit.TeamMemberStateChange)
	end
	self.m_fFreshCooldown = 0
	
	local cfg1 = require "utils.mhsdutils".getLuaBean("knight.gsp.game.cyunbiao", 1)
	local cfg2 = require "utils.mhsdutils".getLuaBean("knight.gsp.game.cyunbiao", 2)
	self.m_pBiaoPrice1:setText(tostring(cfg1.jiangli))
	self.m_pBiaoPrice2:setText(tostring(cfg1.touru))
	self.m_pBiaoPrice3:setText(tostring(cfg2.touru))

	self.m_pSprite = CUISprite:new(5206)
	local pt = self.m_pHorse:GetScreenPosOfCenter()
	local wndHeight = self.m_pHorse:getPixelSize().height
	local loc = XiaoPang.CPOINT(pt.x, pt.y + wndHeight / 2.0)
	self.m_pSprite:SetUILocation(loc)
	self.m_pSprite:SetUIDirection(XiaoPang.XPDIR_BOTTOMLEFT)
	self.m_pHorse:getGeometryBuffer():setRenderEffect(CGameUImanager:createXPRenderEffect(0, Bandit.performPostRenderFunctions))

	local item1 = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(38685)
	local item2 = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(38686)
	self.m_pItem1:SetImage(GetIconManager():GetImageByID(item1.icon))
	self.m_pItem1:setID(item1.id)
	self.m_pItem1:subscribeEvent("TableClick", CGameItemTable.HandleShowTootipsWithItemID, CGameItemTable)
	self.m_pItem2:SetImage(GetIconManager():GetImageByID(item2.icon))
	self.m_pItem2:setID(item2.id)
	self.m_pItem2:subscribeEvent("TableClick", CGameItemTable.HandleShowTootipsWithItemID, CGameItemTable)

	LogInfo("Bandit oncreate end")
end

function Bandit.performPostRenderFunctions(id)
	if _instance and _instance.m_pHorse and _instance.m_pHorse:isVisible() and _instance.m_pHorse:getEffectiveAlpha() > 0.95 and _instance.m_pSprite then
		local pt = _instance.m_pHorse:GetScreenPosOfCenter()
		local wndHeight = _instance.m_pHorse:getPixelSize().height
		local loc = XiaoPang.CPOINT(pt.x, pt.y + wndHeight / 2.0)
		_instance.m_pSprite:SetUILocation(loc)
		_instance.m_pSprite:RenderUISprite()
	end
end


------------------- private: -----------------------------------


function Bandit:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, Bandit)
    return self
end

function Bandit:HandleCreateBtnClicked(args)
	LogInfo("Bandit handle create1 button clicked")
	if self.m_stat ~= statNull then
		return true
	end
	local e = CEGUI.toWindowEventArgs(args)
	self.m_iCreateType = e.window:getID()
	local strBuilder = StringBuilder:new()
	local cfg = require "utils.mhsdutils".getLuaBean("knight.gsp.game.cyunbiao", self.m_iCreateType + 1)
	strBuilder:Set("parameter1", cfg.touru)	

	GetMessageManager():AddConfirmBox(eConfirmNormal,strBuilder:GetString(MHSD_UTILS.get_msgtipstring(145198 + self.m_iCreateType)),
	 Bandit.HandleCreateConfirm,self,CMessageManager.HandleDefaultCancelEvent,CMessageManager)
	strBuilder:delete()
	
end

function Bandit:showQuickBuyDlg()
	local itemid = 38349
	if GetChatManager() then
		GetChatManager():AddTipsMsg(145186)
		if self.m_iCreateType == 1 then
			return true
        end
    end
	local ybnum = GetDataManager():GetYuanBaoNumber()
	if ybnum >= 600 then
		itemid = 38771
	elseif ybnum >= 100 then
		itemid = 38350
	elseif ybnum < 10 then
        return false
	end
	CGreenChannel:GetSingletonDialogAndShowIt():SetItem(itemid)
	return true
end

function Bandit:HandleCreateConfirm()
	LogInfo("Bandit handle create confirm")
	if self.m_iCreateType == 0 then
		if GetRoleItemManager():GetPackMoney() < 200000 then
			self:showQuickBuyDlg()
			GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
			return false 
		end
	elseif self.m_iCreateType == 1 then
	    if GetDataManager():GetYuanBaoNumber() < 50 then
	    	self:showQuickBuyDlg()
	    	GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
	    	return false 
	    end
  	end

  	local create = CCreateBiaoChe.Create()
	create.biaochetype = self.m_iCreateType
    LuaProtocolManager.getInstance():send(create)
  	GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
end


function Bandit:HandleRefreshBtnClicked(args)
	LogInfo("Bandit handle refresh button clicked")
	if self.m_stat ~= statNull then
		return true
	end
	local refresh = CFreshBiaoChes.Create()
	LuaProtocolManager.getInstance():send(refresh)
	self.m_fFreshCooldown = 2
	self.m_pRefreshBtn:setEnabled(false)
end

function Bandit:run(elapse)
	if self.m_fFreshCooldown > 0 then
		if self.m_stat ~= statNull then
			self.m_fFreshCooldown = 0
		else
			self.m_fFreshCooldown = self.m_fFreshCooldown - elapse
			if self.m_fFreshCooldown <= 0 then
				self.m_pRefreshBtn:setEnabled(true)
			end
		end
	end
	if not self.m_fTime then
		return 
	end
	local oldTime = self.m_fTime
	self.m_fTime = self.m_fTime - elapse	
	if self.m_fTime < 0 then 
		self.m_fTime = nil 
		return
	end
	local curTime = self.m_fTime
	local per = 1 - self.m_fTime / totalTime
	self.m_pHorse:setPosition(CEGUI.UVector2(CEGUI.UDim(0, self.m_startPos.x + (self.m_endPos - self.m_startPos).x * per), CEGUI.UDim(0, self.m_startPos.y + (self.m_endPos - self.m_startPos).y * per)))

	if math.floor(oldTime) ~= math.floor(curTime) then
		local minute = math.floor(curTime / 60)
		local second = math.floor(curTime % 60)
		local timeStr = string.format("00:%02d:%02d", minute, second)
		self.m_pTime:setText(timeStr)
	end
end

function Bandit:HandleTalkBtnClicked(args)
	LogInfo("Bandit handle talk button clicked")
	CChatOutputDialog:GetSingletonDialogAndShowIt()
end

function Bandit:InitBiaoCheList(yunbiaotimes, biaoches)
	LogInfo("Bandit init")
	self.m_pDeliveryTimes:setText(tostring(yunbiaotimes) .. "/3")
	if self.m_lBiaocheList then
		self.m_lBiaocheList = nil
	end
	self.m_lBiaocheList = biaoches		

	self.m_iCurPage = 1
	local num = TableUtil.tablelength(self.m_lBiaocheList)
	self.m_iMaxPage = math.ceil(num / cellPerPage)
	self:refreshBiaoches()
end

function Bandit:refreshBiaoches()
	LogInfo("Bandit refresh biaoches")
	if self.m_TeamCell then
		self.m_TeamCell:GetWindow():setVisible(false)
	end
	if self.m_stat ~= statNull then
		self.m_stat = statNull
		self.m_pDimiss:setVisible(false)
		self.m_pHorse:setVisible(false)
		self.m_pRefreshBtn:setEnabled(true)
	end
	self.m_pCreateBtn1:setEnabled(true)
	self.m_pCreateBtn2:setEnabled(true)
	

	if not self.m_lCells then
		self.m_lCells = {}
	end
	local pos = 0
	for i,v in pairs(self.m_lBiaocheList) do
		if pos >= self.m_iCurPage * cellPerPage then
			break
		end
		if not self.m_lCells[pos] then
			self.m_lCells[pos] = DeliveyCell.CreateNewDlg(self.m_pPane)
		end
		if (pos >= (self.m_iCurPage - 1) * cellPerPage) and pos < (self.m_iCurPage * cellPerPage) then
			self.m_lCells[pos]:GetWindow():setVisible(true)
			self.m_lCells[pos]:InitBiaocheInfo(v.biaochekey, v.biaochetype, v.rolename, v.teamnum)
			self.m_lCells[pos]:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, pos * self.m_lCells[pos]:GetWindow():getPixelSize().height)))
		end
		pos = pos + 1
	end

end

function Bandit:HandleNextPage(args)
	LogInfo("Bandit handle next page")
	if self.m_stat ~= statNull then
		return true
	end
	if self.m_iMaxPage and self.m_iCurPage then
		if self.m_iCurPage < self.m_iMaxPage then
			self.m_iCurPage = self.m_iCurPage + 1
			local BarPos = self.m_pPane:getVertScrollbar():getScrollPosition()
			self.m_pPane:getVertScrollbar():Stop()
			self.m_pPane:getVertScrollbar():setScrollPosition(BarPos)
			self:refreshBiaoches()
		end
	end
end 

function Bandit:freshBiaocheTeam(leaderid, biaochetype, biaoches)
	if self.m_stat == statNull then
		self.m_stat = statInTeam
		self.m_pDimiss:setVisible(false)
	end
	if self.m_lCells then
		for i,v in pairs(self.m_lCells) do
			v:GetWindow():setVisible(false)
		end
	end
	if not self.m_TeamCell then
		self.m_TeamCell = DeliveryTeam.CreateNewDlg(self.m_pPane)	
	end
	self.m_TeamCell:GetWindow():setVisible(true)
	self.m_pCreateBtn1:setEnabled(false)
	self.m_pCreateBtn2:setEnabled(false)
	self.m_pRefreshBtn:setEnabled(false)
	self.m_TeamCell:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0,1), CEGUI.UDim(0,0)))
	
	self.m_TeamCell:freshBiaocheTeam(leaderid, biaochetype, biaoches)
	self:freshMemberState()
end

function Bandit:freshMemberState()
	LogInfo("Bandit freshMemberState")
	if self.m_stat ~= statRunning then
		return
	end
	if self.m_TeamCell then
		local num = TableUtil.tablelength(self.m_TeamCell.m_lBiaoches)
		self.m_pDimiss:setVisible(true)
		if (not GetTeamManager():IsOnTeam()) and num > 1 then
			self.m_pDimiss:setProperty("Image", "set:MainControl26 image:san")	
		else
			self.m_pDimiss:setProperty("Image", "set:MainControl26 image:yun")
		end
		self.m_TeamCell:freshMemberState()
	end	
end

function Bandit:FreshBiaoState(remaintime, biaochestate)
	LogInfo("Bandit FreshBiaoState")
	if biaochestate == 3 then
		self.m_stat = statNull
		self.m_pHorse:setVisible(false)
		Bandit.DestroyDialog()
		return 
	end

	if (biaochestate == 1) or (biaochestate == 2) then
		self.m_stat = statRunning
		self.m_pHorse:setVisible(true)
		self.m_fTime = remaintime / 1000
		self.m_pCreateBtn1:setEnabled(false)
		self.m_pCreateBtn2:setEnabled(false)
		self.m_pRefreshBtn:setEnabled(false)
		if self.m_TeamCell then
			self:freshMemberState()
			self.m_TeamCell:freshBiaocheTeam(self.m_TeamCell.m_iLeaderID, self.m_TeamCell.m_iType, self.m_TeamCell.m_lBiaoches)
		end
	end
end

function Bandit:ExitInTeam()
	LogInfo("Bandit ExitInTeam")
	if self.m_TeamCell then
		if self.m_TeamCell.m_bMyselfLeader then
			GetMessageManager():AddConfirmBox(eConfirmNormal,MHSD_UTILS.get_msgtipstring(145181), Bandit.HandleExitConfirm,self,CMessageManager.HandleDefaultCancelEvent,CMessageManager)
		else
			GetMessageManager():AddConfirmBox(eConfirmNormal,MHSD_UTILS.get_msgtipstring(145180), Bandit.HandleExitConfirm,self,CMessageManager.HandleDefaultCancelEvent,CMessageManager)
		end	
	end
end

function Bandit:HandleExitConfirm()
    local leave = CLeaveBiaoChe.Create()
	leave.roleid = 0
	leave.flag = 1
    LuaProtocolManager.getInstance():send(leave)

  	GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
end


return Bandit
