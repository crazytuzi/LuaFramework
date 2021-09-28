require "ui.dialog"
BattleAutoDlg = {}
setmetatable(BattleAutoDlg, Dialog)
BattleAutoDlg.__index = BattleAutoDlg
------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function BattleAutoDlg.getInstance()
	print("enter getinstance")
    if not _instance then
        _instance = BattleAutoDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function BattleAutoDlg.getInstanceAndShow()
	print("enter instance show")
    if not _instance then
        _instance = BattleAutoDlg:new()
        _instance:OnCreate()
	else
	    print("set visible")
	    _instance:SetVisible(true)
    end
    
    return _instance
end

function BattleAutoDlg.getInstanceNotCreate()
    return _instance
end

function BattleAutoDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function BattleAutoDlg.ToggleOpenClose()
	if not _instance then 
		_instance = BattleAutoDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function BattleAutoDlg.GetLayoutFileName()
    return "battleautodlg.layout"
end
function BattleAutoDlg:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pCancelBtn = CEGUI.Window.toPushButton(winMgr:getWindow("BattleAutoDlg/Cancel"))	
    self.m_pCancelBtn:subscribeEvent("Clicked", BattleAutoDlg.HandleCancelBtnClicked, self) 
	self.m_txtWndTripleexpTime = winMgr:getWindow("BattleAutoDlg/time")
	self.m_infoTripleexpTimeBnd = winMgr:getWindow("BattleAutoDlg/info")
    self:RefreshTripleexpTime()
	local  reqcmd = knight.gsp.item.CReqMultiExpTime()
	GetNetConnection():send(reqcmd)
end

-- private: -----------------------------------
BattleAutoDlg.s_tripleexpflag = 0
BattleAutoDlg.s_tripleexpremaintime = -1
function BattleAutoDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, BattleAutoDlg)
    return self
end
function BattleAutoDlg:StartBattle()
	self.m_bIsVisibleBeforeBattle = false
	print("BattleAutoDlgCGameUIManageddrRun",self:IsVisible())
	if self:IsVisible() then
		self.m_bIsVisibleBeforeBattle = true
		self:SetVisible(false)
	end 
end
function BattleAutoDlg:EndBattle()
	if self.m_bIsVisibleBeforeBattle then
		self.m_bIsVisibleBeforeBattle = false 
		self:SetVisible(true)
	end 
end

function BattleAutoDlg:StartEnchou()
	self.m_bIsVisibleBeforeEnchou = false
	print("BattleAutoDlgCGameUIManageddrRun",self:IsVisible())
	if self:IsVisible() then
		self.m_bIsVisibleBeforeEnchou = true
		self:SetVisible(false)
	end 
end
function BattleAutoDlg:EndEnchou()
	if self.m_bIsVisibleBeforeEnchou then
		self.m_bIsVisibleBeforeEnchou = false 
		self:SetVisible(true)
	end 
end
function BattleAutoDlg:HandleCancelBtnClicked(args)
	local curMapID = GetScene():GetMapID()
    local roleLevel = GetDataManager():GetMainCharacterLevel()
   
    
    if GetMainCharacter():GetMoveState() ~= ePacingMove then
	 print("BattleAutoDlgHandleCancelBtnClicked1",  self:GetAutoBattleMapByLevel(roleLevel) )
        local mapID = self:GetAutoBattleMapByLevel(roleLevel)
        if mapID ~= -1 then
			MapChoseDlg.ShowAndSetMapID(mapID,true)            
        end
        return true
    end
    
    if GetMainCharacter():GetMoveState() == ePacingMove then
	print("BattleAutoDlgHandleCancelBtnClicked", GetMainCharacter():GetMoveState() )

        GetMainCharacter():StopPacingMove()
    else
        GetMainCharacter():SetRandomPacing()
    end
    self:RefreshButtonImage()
	return true
end

function BattleAutoDlg:RefreshButtonImage()
    local pNormalBegin = "set:MainControl image:AutostopNormal"
    local pPushedBegin = "set:MainControl image:AutostopPushed"
    local pNormalStop = "set:MainControl image:AutoNormal"
    local pPushedStop = "set:MainControl image:AutoPushed"
    
    if GetMainCharacter():GetMoveState() == ePacingMove then ----------------------todo
        self.m_pCancelBtn:setProperty("NormalImage",pNormalBegin)
        self.m_pCancelBtn:setProperty("PushedImage",pPushedBegin)
    else
        self.m_pCancelBtn:setProperty("NormalImage",pNormalStop)
        self.m_pCancelBtn:setProperty("PushedImage",pPushedStop)
    end
end

function BattleAutoDlg:GetAutoBattleMapByLevel(level)
	local mapIDs = std.vector_int_()
    knight.gsp.map.GetCWorldMapConfigTableInstance():getAllID(mapIDs)
	local num = mapIDs:size()
	for  mapID = 0 , num - 1 do
        local mapRecord = knight.gsp.map.GetCWorldMapConfigTableInstance():getRecorder(mapIDs[mapID])
        if  mapRecord.id ~= -1 then
            if mapRecord.maptype == 3 then
				local vecSubMaps = std.vector_int_()
				self:GetSubMapIDByString(mapRecord.sonmapid, vecSubMaps)
				local numSubIt = vecSubMaps:size()
                for subMapID = 0,numSubIt-1 do
                    local subMapRecord = knight.gsp.map.GetCWorldMapConfigTableInstance():getRecorder(vecSubMaps[subMapID])
                    if subMapRecord.id ~= -1 then
                        if level >= subMapRecord.LevelLimitMin and level <= subMapRecord.LevelLimitMax then
                            return mapIDs[mapID]
                        end
                    end
                end
            end
        end
    end
    return -1
end
function BattleAutoDlg:GetSubMapIDByString(strSubMaps,vecSubMaps)
	if strSubMaps == nil or strSubMaps == "0" then
		return
	end
    for w in string.gmatch(strSubMaps,"%d+") do
        vecSubMaps:push_back(tonumber(w))
    end
end

function BattleAutoDlg:RefreshTripleexpTime()
	if  BattleAutoDlg.s_tripleexpflag == 0 or BattleAutoDlg.s_tripleexpremaintime < 1  then
        self.m_infoTripleexpTimeBnd:setVisible(false)
        self.m_txtWndTripleexpTime:setText("")
	else
        local strTripExpTime
		local min = BattleAutoDlg.s_tripleexpremaintime / 60
        local sec = BattleAutoDlg.s_tripleexpremaintime % 60
        if min > 0 or sec > 0 then
			strTripExpTime = string.format("%02d:%02d",min,sec)
			self.m_infoTripleexpTimeBnd:setVisible(true)
            self.m_txtWndTripleexpTime:setText(strTripExpTime)
			self.m_txtWndTripleexpTime:setProperty("TextColours",((GetMainCharacter():GetMoveState() == ePacingMove) and "ffffff33") or "ffff3333")
        else
            self.m_infoTripleexpTimeBnd:setVisible(false)
            self.m_txtWndTripleexpTime:setText("")
        end
	end
end

function BattleAutoDlg.CGameUIManagerRun(elapsed)
    if  BattleAutoDlg.s_tripleexpflag ~= 0 then
        BattleAutoDlg.s_tripleexpremaintime = BattleAutoDlg.s_tripleexpremaintime - elapsed
        if BattleAutoDlg.s_tripleexpremaintime < 1.0 then
            BattleAutoDlg.s_tripleexpflag = 0
           BattleAutoDlg.s_tripleexpremaintime = -1
        end
    end
    if _instance then
        if _instance:IsVisible() then
			_instance:RefreshTripleexpTime()
        end
    end 
end

function BattleAutoDlg.CSetVisible(b)
	if b then
		BattleAutoDlg.getInstanceAndShow()
	elseif _instance then
		_instance:SetVisible(b)
	end
end
function BattleAutoDlg.CRefreshTripleexpTime()
	if _instance then
		_instance:RefreshTripleexpTime()
	end
end
function BattleAutoDlg.CRefreshButtonImage()
	if _instance then
		_instance:RefreshButtonImage()
	end
end


return BattleAutoDlg
