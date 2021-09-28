require "ui.dialog"
require "utils.stringbuilder"
require "utils.mhsdutils"
require "utils.log"
require "ui.pkcell"

PKDialog = {}
setmetatable(PKDialog, Dialog)
PKDialog.__index = PKDialog

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
local cellPerPage = 5
function PKDialog.getInstance()
	LogInfo("enter get pkdialog instance")
    if not _instance then
        _instance = PKDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function PKDialog.getInstanceAndShow()
	LogInfo("enter pkdialog instance show")
    if not _instance then
        _instance = PKDialog:new()
        _instance:OnCreate()
	else
		LogInfo("set pkdialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function PKDialog.getInstanceNotCreate()
    return _instance
end

function PKDialog.DestroyDialog()
	if _instance then 
		LogInfo("destroy pkdialog")
		_instance:ResetList()
		_instance:OnClose()
		_instance = nil
	end
end

function PKDialog.ToggleOpenClose()
	if not _instance then 
		_instance = PKDialog:new() 
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

function PKDialog.GetLayoutFileName()
    return "pkdialognew.layout"
end

function PKDialog.RefreshPKInfo()
	LogInfo("refresh pkinfo", PKDialog.getInstanceNotCreate())
	if PKDialog.getInstanceNotCreate() then
		--already created
		LogInfo("refresh pkinfo already created")
		PKDialog.getInstance():RefreshWinInfo()
	else
		--not created
		LogInfo("refresh pkinfo not created")
		PKDialog.getInstanceAndShow()
	end	
end

function PKDialog.OnWuxunChange()
	LogInfo("pkdialog onwunxunchange")
	if PKDialog.getInstanceNotCreate() then
		PKDialog.getInstance().m_pRoleWuxun:setText(tostring(GetPKManager():getWuxun()))
	end 

end

function PKDialog.RefreshTenRewardButton()
	LogInfo("pkdialog refresh tenreward")
	if PKDialog.getInstanceNotCreate() then
		PKDialog.getInstance().m_pTenRewardBtn:setEnabled(GetPKManager():CanGetTenReward())
	end
end

function PKDialog.OnMsgChange()
	LogInfo("pkdialog onmsgchange")
	if PKDialog.getInstanceNotCreate() then
		PKDialog.getInstance():RefreshMsg()
	end
end

function PKDialog:OnCreate()
	LogInfo("pk dialog oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pRoleName = winMgr:getWindow("pkdialognew/left/name")
	self.m_pRoleRank = winMgr:getWindow("pkdialognew/left/num1")
	self.m_pRoleWuxun = winMgr:getWindow("pkdialognew/left/num2")
	self.m_pRoleWins = winMgr:getWindow("pkdialognew/left/num3")
	self.m_pTenRewardBtn = CEGUI.Window.toPushButton(winMgr:getWindow("pkdialognew/left/get"))
	self.m_pRewardEdit = winMgr:getWindow("pkdialognew/top/num1")
	self.m_pTimeCount = winMgr:getWindow("pkdialognew/top/num2")
	self.m_pPane = CEGUI.Window.toScrollablePane(winMgr:getWindow("pkdialognew/righttop/main"))
	self.m_pPane:EnableHorzScrollBar(true)
	self.m_pMessage = CEGUI.Window.toRichEditbox(winMgr:getWindow("pkdialognew/rightinfo/main"))
	self.m_pRankListBtn = CEGUI.Window.toPushButton(winMgr:getWindow("pkdialognew/ranklist"))
	self.m_pShopBtn = CEGUI.Window.toPushButton(winMgr:getWindow("pkdialognew/shop"))
	self.m_pRemainTimes = winMgr:getWindow("pkdialognew/left/num4")
	self.m_pPic = winMgr:getWindow("pkdialognew/rolepic")
	self.m_pEffectWnd = winMgr:getWindow("pkdialognew/righttop/effect")
	self.m_pWeiboShareBtn = CEGUI.Window.toPushButton(winMgr:getWindow("pkdialognew/left/share"))
	self.m_lRolePic ={}
	self.m_lRolePic[1010109] = "set:rolebig1 image:yunxi"
	self.m_lRolePic[1010102] = "set:rolebig2 image:qinshaoyou"
	self.m_lRolePic[1010110] = "set:rolebig3 image:hanyi"
	self.m_lRolePic[1010104] = "set:rolebig4 image:simachangfeng"
	self.m_lRolePic[1010107] = "set:rolebig5 image:duguyue"
	self.m_lRolePic[1010103] = "set:rolebig6 image:yanchongguang"
	self.m_lRolePic[1010108] = "set:rolebig7 image:lingxiaoyu"
	self.m_lRolePic[1010105] = "set:rolebig8 image:yangkongyue"
	LogInfo(GetMainCharacter():GetShapeID())
	self.m_pPic:setProperty("Image", self.m_lRolePic[GetMainCharacter():GetShapeID()])	
	self.m_lRolePic = nil
	
    self.m_pTimeCount:subscribeEvent("WindowUpdate", PKDialog.HandleWindowUpdate, self) 
	self.m_pTenRewardBtn:subscribeEvent("Clicked",PKDialog.HandleTenRewardBtnClicked, self)
	self.m_pRankListBtn:subscribeEvent("Clicked", PKDialog.HandleRankClicked, self)
	self.m_pShopBtn:subscribeEvent("Clicked", PKDialog.HandleShopClicked, self)
	self.m_pPane:subscribeEvent("WindowUpdate", PKDialog.HandlePaneUpdate, self)
	self.m_pPane:subscribeEvent("NextPage", PKDialog.HandleNextPage, self)

	self.m_pWeiboShareBtn:setVisible(false)
	if Config.TRD_PLATFORM == 1 and Config.MOBILE_ANDROID == 0 and Config.CUR_3RD_PLATFORM == "tiger" then
		self.m_pWeiboShareBtn:setVisible(true)
		self.m_pWeiboShareBtn:subscribeEvent("Clicked", PKDialog.HandleWeiboShareBtnClicked, self)
	elseif ( Config.TRD_PLATFORM == 1 and Config.MOBILE_ANDROID == 0 and Config.CUR_3RD_PLATFORM == "kris" ) or Config.isKoreanAndroid() then
		self.m_pWeiboShareBtn:setVisible(true)
		self.m_pWeiboShareBtn:subscribeEvent("Clicked", PKDialog.HandleFacebookShareBtnClicked, self)
	end
	
	self.m_iMaxCells = 0
	self:RefreshInfo()

	LogInfo("pk dialog oncreate end")
end

------------------- private: -----------------------------------


function PKDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, PKDialog)
    return self
end

function PKDialog:RefreshInfo()
	LogInfo("pkdialog init info")
	self.m_pRoleName:setText(GetMainCharacter():GetName())
	self.m_pRoleRank:setText(tostring(GetPKManager():getRank()))
	self.m_pRoleWuxun:setText(tostring(GetPKManager():getWuxun()))
	self.m_pRoleWins:setText(tostring(GetPKManager():getWins()))
	self.m_pRemainTimes:setText(tostring(GetPKManager():getRemainTimes()))	
	self.m_pRewardEdit:setText(GetPKManager():getRewardInfo())   
	
	
	local num = GetPKManager():getOpponentNum()
	self.m_iMaxPage = math.ceil(num / cellPerPage)
	self.m_iCurPage = 1
	self.m_iMyPos = nil
	self.m_bAddMyself = false
	self.m_iCellNum = nil
	self.m_iButtonEnable = nil

	self:RefreshOpponent() 
end

function PKDialog:RefreshWinInfo()
	LogInfo("refresh win info")
	self:GetWindow():activate()
	self:GetWindow():setAlpha(1.0)	
	self.m_effectTime = 0
	self:RefreshInfo()	
--	local pkRank = GetPKManager():getPkRank()
--	local pkRoleID = GetPKManager():getPkRoleID()
--	for i  = 1,#self.m_lRoleList do
--		if pkRank == self.m_lRoleList[i].rank or pkRoleID == self.m_lRoleList[i].id then
--			self.m_iEndPos = i
--			self.m_iStartPos = self.m_iMyPos
--			self.m_iTimeElapse = 0
--			self.m_lRoleList[self.m_iMyPos].pWnd:setAlwaysOnTop(true)
--			break	
--		end
--	end	

end

function PKDialog:RefreshMsg()
	LogInfo("refresh msg")
	self:GetWindow():activate()
	self:GetWindow():setAlpha(1.0)	
	local num = GetPKManager():getMsgListLen()
	self.m_lMsgList = {}
	self.m_pMessage:Clear()
	for i = 1, num do
		local msg = GetPKManager():getMsg(i)
		local strbuilder = StringBuilder:new()	
		
		if msg.m_iMessageType == 1 then	
			strbuilder:Set("parameter1", msg.m_sRoleName)
			self.m_pMessage:AppendParseText(CEGUI.String(strbuilder:GetString(MHSD_UTILS.get_msgtipstring(144775))))
			self.m_pMessage:AppendBreak()
		elseif msg.m_iMessageType == 2 then
			strbuilder:Set("parameter1", msg.m_sRoleName)
			strbuilder:SetNum("parameter2", msg.m_iRank)
			self.m_pMessage:AppendParseText(CEGUI.String(strbuilder:GetString(MHSD_UTILS.get_msgtipstring(144776))))
			local linkText = self.m_pMessage:AppendLinkText(CEGUI.String(MHSD_UTILS.get_resstring(2981)))			
			linkText:SetUserID(msg.m_iRoleId)
			linkText:subscribeEvent("MouseButtonDown", PKDialog.HandleCounterAttackClicked, self)
			self.m_pMessage:AppendBreak()
		elseif msg.m_iMessageType == 3 then
			strbuilder:Set("parameter1", msg.m_sRoleName)
			strbuilder:SetNum("parameter2", msg.m_iRank)
			strbuilder:SetNum("parameter3", msg.m_iExp)
			self.m_pMessage:AppendParseText(CEGUI.String(strbuilder:GetString(MHSD_UTILS.get_msgtipstring(144777))))
			self.m_pMessage:AppendBreak()
		elseif msg.m_iMessageType == 4 then
			strbuilder:Set("parameter1", msg.m_sRoleName)
			strbuilder:SetNum("parameter2", msg.m_iExp)
			self.m_pMessage:AppendParseText(CEGUI.String(strbuilder:GetString(MHSD_UTILS.get_msgtipstring(144778))))
			self.m_pMessage:AppendBreak()
		elseif msg.m_iMessageType == 5 then
			strbuilder:Set("parameter1", msg.m_sRoleName)
			strbuilder:SetNum("parameter2", msg.m_iExp)
			self.m_pMessage:AppendParseText(CEGUI.String(strbuilder:GetString(MHSD_UTILS.get_msgtipstring(144897))))
			self.m_pMessage:AppendBreak()
		elseif msg.m_iMessageType == 6 then
			strbuilder:Set("parameter1", msg.m_sRoleName)
			strbuilder:SetNum("parameter2", msg.m_iExp)
			self.m_pMessage:AppendParseText(CEGUI.String(strbuilder:GetString(MHSD_UTILS.get_msgtipstring(144898))))
			self.m_pMessage:AppendBreak()
		elseif msg.m_iMessageType == 7 then
			strbuilder:Set("parameter1", msg.m_sRoleName)
			self.m_pMessage:AppendParseText(CEGUI.String(strbuilder:GetString(MHSD_UTILS.get_msgtipstring(144899))))
			self.m_pMessage:AppendBreak()
		elseif msg.m_iMessageType == 8 then
			strbuilder:Set("parameter1", msg.m_sRoleName)
			self.m_pMessage:AppendParseText(CEGUI.String(strbuilder:GetString(MHSD_UTILS.get_msgtipstring(144900))))
			self.m_pMessage:AppendBreak()
		end

		strbuilder:delete()
	end
	self.m_pMessage:Refresh()
--	self.m_pMessage:HandleTop()
	self.m_pRemainTimes:setText(tostring(GetPKManager():getRemainTimes()))
	self.m_pRoleWins:setText(tostring(GetPKManager():getWins()))
end

function PKDialog:RefreshOpponent()
	LogInfo("refresh opponent")
	if not self.m_iCurPage then
		return true
	end

	local num = GetPKManager():getOpponentNum()
	if not self.m_lRoleList then
		self.m_lRoleList = {}
		self.m_lCells = {}
	end

	local winMgr = CEGUI.WindowManager:getSingleton()
	local startPos = (self.m_iCurPage - 1) * cellPerPage + 1
	local endPos = self.m_iCurPage * cellPerPage
	if endPos > num then
		endPos = num
	end
	local i = 1
	if self.m_iCellNum then
		i = self.m_iCellNum
	end
	if not self.m_iButtonEnable then
		self.m_iButtonEnable = 0
	end	
	for j = startPos, endPos do
		local tmpRoleInfo = GetPKManager():getOpponent(j)
		--insert myself
		if tmpRoleInfo.m_iRoleId ~= GetMainCharacter():GetID() and (not self.m_bAddMyself) and (tmpRoleInfo.m_iRank < GetPKManager():getRank()) then
			LogInfo("add myself")
			if self.m_iMaxCells < i then
				self.m_iMaxCells = i
				self.m_lCells[self.m_iMaxCells] = PKCell.CreateNewDlg(self.m_pPane, self.m_iMaxCells)
			end
			local myself = self.m_lCells[i]
			myself.pWnd:setVisible(true)
			myself.pRank:setText(tostring(GetPKManager():getRank()))
			local shapeTmp = knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(GetMainCharacter():GetShapeID())
			local path = GetIconManager():GetImagePathByID(shapeTmp.headID):c_str()
			myself.pHead:setProperty("Image", path)
			myself.pName:setText(GetMainCharacter():GetName())
			myself.pLevel:setText(tostring(GetMainCharacter():GetLevel()))
			myself.pSchool:setText(knight.gsp.role.GetSchoolInfoTableInstance():getRecorder(GetMainCharacter():GetSchool()).name)
			myself.pButton:setText(MHSD_UTILS.get_resstring(2982))
			myself.pButton:setVisible(true)
			myself.pButton:removeEvent("Clicked")
			myself.pButton:subscribeEvent("Clicked", PKDialog.HandleRandomAttackClick, self)
			self:RefreshBack(i, GetPKManager():getRank(), true)
			self.m_pPane:addChildWindow(myself.pWnd)
			myself.pWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0,myself.pWnd:getPixelSize().width * (i - 1) + 1),CEGUI.UDim(0,0)))
			self.m_lRoleList[i] = myself
			self.m_iMyPos = i
			i = i + 1
			self.m_bAddMyself = true
		end

		if self.m_iMaxCells < i then
			self.m_iMaxCells = i
			self.m_lCells[self.m_iMaxCells] = PKCell.CreateNewDlg(self.m_pPane, self.m_iMaxCells)
		end
		local tmpRole = self.m_lCells[i]
		tmpRole.pWnd:setVisible(true)
		tmpRole.id = tmpRoleInfo.m_iRoleId
		tmpRole.name = tmpRoleInfo.m_sRoleName
		tmpRole.rank = tmpRoleInfo.m_iRank
		tmpRole.shapeId = tmpRoleInfo.m_iShapeId
		tmpRole.schoolId = tmpRoleInfo.m_iSchoolId
		tmpRole.level = tmpRoleInfo.m_iLevel
		tmpRole.pRank:setText(tostring(tmpRole.rank))
		local shapeTmp = knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(tmpRole.shapeId)
		local path = GetIconManager():GetImagePathByID(shapeTmp.headID):c_str()
		tmpRole.pHead:setProperty("Image", path)
		tmpRole.pName:setText(tmpRole.name)
		if tmpRole.level == 0 then
			tmpRole.pLevel:setText(MHSD_UTILS.get_resstring(2983) .. tostring(GetPKManager():getNPCLevel(tmpRole.rank)))
		else
			tmpRole.pLevel:setText(MHSD_UTILS.get_resstring(2983) .. tostring(tmpRole.level))
		end
		if tmpRole.schoolId == 0 then
			tmpRole.pSchool:setText(MHSD_UTILS.get_resstring(2984))
		else
			tmpRole.pSchool:setText(knight.gsp.role.GetSchoolInfoTableInstance():getRecorder(tmpRole.schoolId).name)
		end
		if tmpRole.id == GetMainCharacter():GetID() then
			tmpRole.pButton:setVisible(true)
			tmpRole.pButton:setText(MHSD_UTILS.get_resstring(2982))
			tmpRole.pButton:removeEvent("Clicked")
			tmpRole.pButton:subscribeEvent("Clicked", PKDialog.HandleRandomAttackClick, self)
			self.m_iMyPos = i
			self.m_bAddMyself = true
			self:RefreshBack(i, tmpRole.rank, true)
		elseif (tmpRole.rank < GetPKManager():getRank()) and (self.m_iButtonEnable < 6) then
		--show button
			tmpRole.pButton:setVisible(true)
			tmpRole.pButton:setID(i)
			tmpRole.pButton:removeEvent("Clicked")
			tmpRole.pButton:subscribeEvent("Clicked", PKDialog.HandleAttackClick, self)
			self.m_iButtonEnable = self.m_iButtonEnable + 1
			self:RefreshBack(i, tmpRole.rank, false)
		else
			tmpRole.pButton:setVisible(false)
			self:RefreshBack(i, tmpRole.rank, false)
		end
		self.m_pPane:addChildWindow(tmpRole.pWnd)
		tmpRole.pWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0,tmpRole.pWnd:getPixelSize().width * (i - 1) + 1),CEGUI.UDim(0,0)))
		self.m_lRoleList[i] = tmpRole
		i = i + 1
	end
	self.m_iCellNum = i
	for i = self.m_iCellNum + 1, self.m_iMaxCells do
		self.m_lCells[i].pWnd:setVisible(false)
		self.m_lCells[i].pWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0,1), CEGUI.UDim(0,0)))
	end

	if not self.m_iMyPos then
		self.m_iCurPage = self.m_iCurPage + 1
		self:RefreshOpponent()
		return 
	end

	--set scroll bar pos
	if self.m_iMyPos <= 3 then
		self.m_pPane:getHorzScrollbar():setScrollPosition(0)
	else
		local pos = self.m_iMyPos - 3
		self.m_pPane:getHorzScrollbar():setScrollPosition(pos * self.m_lRoleList[self.m_iMyPos].pWnd:getPixelSize().width)
	end

end

function PKDialog:ResetList()
	LogInfo("reset list")
    local winMgr = CEGUI.WindowManager:getSingleton()
	if self.m_lRoleList then
		self.m_pPane:cleanupNonAutoChildren()
		self.m_lRoleList = nil
		self.m_lCells = nil
	end
end

function PKDialog:HandleTenRewardBtnClicked(args)
	LogInfo("ten reward clicked")
	if GetPKManager():getFightTimes() < 10 then
        --144783每天进行10次挑战就可以打开丰厚的礼包哦!
        GetGameUIManager():AddMessageTipById(144783);
		return true
   	end
	GetPKManager():RequestReward(2)
	return true
end

function PKDialog:HandleRankClicked(args)
	LogInfo("rank clicked")
	GetPKManager():RequestRankList()
	return true
end

function PKDialog:HandleShopClicked(args)
	LogInfo("shop clicked")
	GetPKManager():openStore()
	return true
end

function PKDialog:HandleWindowUpdate(args)
	self.m_pTimeCount:setText(GetPKManager():getTimeCountdown())	
	return true
end

--随机战
function PKDialog:HandleRandomAttackClick(args)
	LogInfo("random attack clicked")
	GetPKManager():RequestPk(0,0)	
	return true
end

--排位战
function PKDialog:HandleAttackClick(args)
	LogInfo("attack clicked")
	local e = CEGUI.toWindowEventArgs(args)
	local id = e.window:getID()
	local rank = self.m_lRoleList[id].rank	
	GetPKManager():RequestPk(rank, 0)
	return true
end

function PKDialog:HandleCounterAttackClicked(args)
	LogInfo("counter attack clicked")
	local e = CEGUI.toMouseEventArgs(args)
	local linkText = self.m_pMessage:GetComponentByPos(e.position)
	GetPKManager():RequestPk(0, linkText:GetUserID())

	return true
end

function PKDialog:HandlePaneUpdate(args)
--	if self.m_iEndPos then
--		local time = 1.0
--		local width = self.m_lRoleList[1].pWnd:getPixelSize().width
--		local e = CEGUI.toUpdateEventArgs(args)
--		self.m_iTimeElapse = self.m_iTimeElapse + e.d_timeSinceLastFrame	
--		LogInfo(self.m_iTimeElapse)
--		LogInfo(self.m_iStartPos, self.m_iEndPos)
--		local moved = math.floor(self.m_iTimeElapse / time)
--		LogInfo("start pos = ", self.m_iStartPos, "end pos = ", self.m_iEndPos, "move = ", moved)
--		if (self.m_iMyPos + moved) ~= self.m_iStartPos then
--			self.m_iStartPos = self.m_iMyPos + moved
--			self.m_lRoleList[self.m_iStartPos].pWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0,width * (self.m_iStartPos - 2) + 1),CEGUI.UDim(0,0)))
--			if self.m_iStartPos == self.m_iEndPos then 
--				self.m_iStartPos = nil
--				self.m_iEndPos = nil
--				self.m_iTimeElapse = nil
--				self:RefreshInfo()
--				return true
--			end
--		end
--		self.m_lRoleList[self.m_iMyPos].pWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0, width * (self.m_iStartPos - 1) + width * (self.m_iTimeElapse % time) / time),CEGUI.UDim(0,0)))
--		local pos = (self.m_iStartPos - 3) * width + width * (self.m_iTimeElapse % time) / time 
--		LogInfo(width * (self.m_iStartPos - 1) + width * (self.m_iTimeElapse % time) / time)
--		LogInfo(pos)
--		self.m_pPane:getHorzScrollbar():setScrollPosition(pos)
--	end

	if self.m_effectTime  then
		self.m_effectTime = self.m_effectTime + CEGUI.toUpdateEventArgs(args).d_timeSinceLastFrame
		if self.m_effectTime > 1.0  then
			self.m_effectTime = nil
			GetGameUIManager():AddUIEffect(self.m_pEffectWnd , MHSD_UTILS.get_effectpath(10372), false)
		end
	end
	
	return true
end

--refresh back image by rank
function PKDialog:RefreshBack(num, rank, isMyself)
    local winMgr = CEGUI.WindowManager:getSingleton()
	local back1 = winMgr:getWindow(tostring(num) .. "pkcelldialog/top1")
	local back2 = winMgr:getWindow(tostring(num) .. "pkcelldialog/top2")
	local back3 = winMgr:getWindow(tostring(num) .. "pkcelldialog/top3")
	local back10 = winMgr:getWindow(tostring(num) .. "pkcelldialog/top10")
	local backnormal = winMgr:getWindow(tostring(num) .. "pkcelldialog/normal")
	local backmain = winMgr:getWindow(tostring(num) .. "pkcelldialog/main")
	local rankMedal = winMgr:getWindow(tostring(num) .. "pkcelldialog/mark")
	local rankStar = winMgr:getWindow(tostring(num) .. "pkcelldialog/pic")

	back1:setVisible(false)
	back2:setVisible(false)
	back3:setVisible(false)
	back10:setVisible(false)
	backnormal:setVisible(false)
	backmain:setVisible(false)
	rankMedal:setVisible(false)
	rankStar:setVisible(false)

	if rank > 10 then
		if isMyself then 
			backmain:setVisible(true)
		else
			backnormal:setVisible(true)
		end
	else
		if rank == 1 then
			back1:setVisible(true)
			rankMedal:setVisible(true)
			rankStar:setVisible(true)
			rankMedal:setProperty("Image", "set:MainControl8 image:1")
		elseif rank == 2 then
			back2:setVisible(true)
			rankStar:setVisible(true)
			rankMedal:setVisible(true)
			rankMedal:setProperty("Image", "set:MainControl8 image:2")
		elseif rank == 3 then
			back3:setVisible(true)
			rankStar:setVisible(true)
			rankMedal:setVisible(true)
			rankMedal:setProperty("Image", "set:MainControl8 image:3")
		else
			back10:setVisible(true)
		end
	end	
end

function PKDialog:HandleNextPage(args)
	LogInfo("pkdialog handle next page")
	if self.m_iMaxPage and self.m_iCurPage then
		if self.m_iCurPage < self.m_iMaxPage then
			self.m_iCurPage = self.m_iCurPage + 1
			local BarPos = self.m_pPane:getHorzScrollbar():getScrollPosition()
			self.m_pPane:getHorzScrollbar():Stop()
			self:RefreshOpponent()
			self.m_pPane:getHorzScrollbar():setScrollPosition(BarPos)
			
		end
	end	
	return true
end

function PKDialog:HandleWeiboShareBtnClicked(args)
	LogInfo("PKDialog HandleWeiboShareBtnClicked")
	local record = MHSD_UTILS.getLuaBean("knight.gsp.message.cweiboshow", 501)
	local title = record.title
	if record.title == "0" then
		title = ""
	end
	local msg = record.msg
	if record.msg == "0" then
		msg = ""
	end
	local link = record.link
	if record.link == "0" then
		link = ""
	end
    local link1 = record.link1
	if record.link1 == "0" then
		link1 = ""
	end
	local strbuilder = StringBuilder:new()	
	strbuilder:SetNum("parameter1", GetPKManager():getRank())
	
	SDXL.ChannelManager:CommonShare(title, strbuilder:GetString(msg), link, link1)		
	strbuilder:delete()
end

function PKDialog:HandleFacebookShareBtnClicked(args)
	LogInfo("PKDialog HandleWeiboShareBtnClicked")
	-- local strbuilder = StringBuilder:new()	
	-- strbuilder:SetNum("parameter1", GetPKManager():getRank())
	--strbuilder:GetString(msg)
	local record = MHSD_UTILS.getLuaBean("knight.gsp.message.cfacebook", 1)
	local shareinfo = {}
	shareinfo[1] = record.Comment
	shareinfo[2] = record.Link
	shareinfo[3] = record.LinkPicture
	shareinfo[4] = record.LinkName
	shareinfo[5] = record.LinkCaption
	shareinfo[6] = record.LinkDescription


	if Config.isKoreanAndroid() then
		local luaj = require "luaj"
		luaj.callStaticMethod("com.wanmei.korean.KoreanCommon", "ShareFacebook", luaj.checkArguments(shareinfo))
	elseif Config.TRD_PLATFORM == 1 and Config.MOBILE_ANDROID == 0 and Config.CUR_3RD_PLATFORM == "kris" then
            SDXL.ChannelManager:CommonShare(record.Comment,record.Link, record.LinkPicture, record.LinkName,record.LinkCaption,record.LinkDescription)
	end
	-- strbuilder:delete()
end


return PKDialog
