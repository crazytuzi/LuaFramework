require "ui.dialog"
require "utils.mhsdutils"
require "utils.stringbuilder"
require "ui.camp.campvsitem"
require "protocoldef.knight.gsp.battle.creqcampinfo"
require "protocoldef.knight.gsp.battle.ccampbattlereadyfight"
require "protocoldef.knight.gsp.battle.creqencourage"
require "ui.camp.campvsmessage"


CampVS = {}
setmetatable(CampVS, Dialog)
CampVS.__index = CampVS

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance
local Stat_Not_Started = 0
local Stat_Started = 1
local Stat_Joined = 2
function CampVS.getInstance()
	LogInfo("enter get CampVS instance")
    if not _instance then
        _instance = CampVS:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function CampVS.getInstanceAndShow()
	LogInfo("enter CampVS instance show")
    if not _instance then
        _instance = CampVS:new()
        _instance:OnCreate()
	else
		LogInfo("set CampVS visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function CampVS.getInstanceNotCreate()
    return _instance
end

function CampVS.DestroyDialog()
	if _instance then 
		LogInfo("destroy CampVS")
		if _instance.m_pStat == Stat_Joined then
			if (not GetTeamManager():IsOnTeam()) or (GetTeamManager():IsOnTeam() and GetTeamManager():IsMyselfLeader()) then
				local start = CCampBattleReadyFight:Create()
				start.ready = 0
				LuaProtocolManager.getInstance():send(start)
			end
		end

		if GetTeamManager() then
			GetTeamManager().EventTeamListChange:RemoveScriptFunctor(_instance.m_hTeamListChange)
		end
		_instance.m_pListRed:cleanupNonAutoChildren()
		_instance.m_pListBlue:cleanupNonAutoChildren()
		_instance:OnClose()
		_instance = nil
	end
end

function CampVS.ToggleOpenClose()
	if not _instance then 
		_instance = CampVS:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function CampVS.TeamStateChange()
	if _instance and _instance.m_pStat ~= Stat_Not_Started and ((GetTeamManager() and GetTeamManager():IsOnTeam() and GetTeamManager():IsMyselfLeader()) or (GetTeamManager() and (not GetTeamManager():IsOnTeam()))) then
		_instance.m_pJoinBtn:setEnabled(true)
	elseif _instance then
		_instance.m_pJoinBtn:setEnabled(false)
	end
		

end

----/////////////////////////////////////////------

function CampVS.GetLayoutFileName()
    return "campvs.layout"
end

function CampVS:OnCreate()
	LogInfo("CampVS oncreate begin")
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pListRed = CEGUI.Window.toScrollablePane(winMgr:getWindow("campvs/campred/list"))
	self.m_pListBlue = CEGUI.Window.toScrollablePane(winMgr:getWindow("campvs/campblue/list"))
	self.m_pShowMyself = CEGUI.Window.toCheckbox(winMgr:getWindow("campvs/zhanji/select"))
	self.m_pEditbox = CEGUI.Window.toRichEditbox(winMgr:getWindow("campvs/zhanji/xianshi"))
	self.m_pWinNum = winMgr:getWindow("campvs/bot/background/winnum")
	self.m_pFailNum = winMgr:getWindow("campvs/bot/background/failnum")
	self.m_pBestNum = winMgr:getWindow("campvs/bot/background/bestnum")
	self.m_pMyScore = winMgr:getWindow("campvs/bot/background/integral")
	self.m_pAddAttack1 = winMgr:getWindow("campvs/bot/background/attack")
	self.m_pAddDefence1 = winMgr:getWindow("campvs/bot/background/defense")
	self.m_pAddSpeed1 = winMgr:getWindow("campvs/bot/background/speed")
	self.m_pAddAttack2 = winMgr:getWindow("campvs/smallbackground/attackback/attack")
	self.m_pAddDefence2 = winMgr:getWindow("campvs/smallbackground/defenseback/defense")
	self.m_pAddSpeed2 = winMgr:getWindow("campvs/smallbackground/speedback/speed")
	self.m_pAddAttackMoney = winMgr:getWindow("campvs/smallbackground/attackback/moneyback/money")
	self.m_pAddDefenceMoney = winMgr:getWindow("campvs/smallbackground/defenseback/moneyback/money")
	self.m_pAddSpeedMoney = winMgr:getWindow("campvs/smallbackground/speedback/moneyback/money")
	self.m_pAddAttackBtn = CEGUI.Window.toPushButton(winMgr:getWindow("campvs/smallbackground/attackback/start"))
	self.m_pAddDefenceBtn = CEGUI.Window.toPushButton(winMgr:getWindow("campvs/smallbackground/defenseback/start"))
	self.m_pAddSpeedBtn = CEGUI.Window.toPushButton(winMgr:getWindow("campvs/smallbackground/speedback/start"))
	self.m_pAddBtn = CEGUI.Window.toPushButton(winMgr:getWindow("campvs/bot/background/start"))
	self.m_pJoinBtn = CEGUI.Window.toPushButton(winMgr:getWindow("campvs/bot/background/join"))
	self.m_pAddBack = winMgr:getWindow("campvs/smallbackground")
	self.m_pTime = winMgr:getWindow("campvs/time")
	self.m_pMarkRed = winMgr:getWindow("campvs/campred/mark")
	self.m_pMarkBlue = winMgr:getWindow("campvs/campblue/mark")
	self.m_pUpRed = winMgr:getWindow("campvs/campred/up")
	self.m_pUpBlue = winMgr:getWindow("campvs/campblue/up")
	self.m_pUpRedBack = winMgr:getWindow("campvs/campred/mark1")
	self.m_pUpBlueBack = winMgr:getWindow("campvs/campblue/mark1")
	self.m_pEditBack = winMgr:getWindow("campvs/zhanji")
	self.m_pAttackEffect = winMgr:getWindow("campvs/smallbackground/attackback/effect")
	self.m_pDefenceEffect = winMgr:getWindow("campvs/smallbackground/defenseback/effect")
	self.m_pSpeedEffect = winMgr:getWindow("campvs/smallbackground/speedback/effect")
	self.m_pScoreRed = {}
	self.m_pScoreBlue = {}
	for i = 0, 5 do
		self.m_pScoreRed[i] = winMgr:getWindow("campvs/campred/total" .. tostring(i))
		self.m_pScoreBlue[i] = winMgr:getWindow("campvs/campblue/total" .. tostring(i))
	end
	
--subscribeEvent
	self.m_pAddBtn:subscribeEvent("Clicked", CampVS.HandleAddBtnClicked, self)
	self.m_pJoinBtn:subscribeEvent("Clicked", CampVS.HandleJoinBtnClicked, self)
	self.m_pAddAttackBtn:subscribeEvent("Clicked", CampVS.HandleAddAttackClicked, self)
	self.m_pAddDefenceBtn:subscribeEvent("Clicked", CampVS.HandleAddDefenceClicked, self)
	self.m_pAddSpeedBtn:subscribeEvent("Clicked", CampVS.HandleAddSpeedClicked, self)
	self.m_pShowMyself:subscribeEvent("CheckStateChanged", CampVS.HandleCheckMyself, self)

--init
	self.m_pWinNum:setText(tostring(0)) 
	self.m_pFailNum:setText(tostring(0))
	self.m_pBestNum:setText(tostring(0))
	self.m_pMyScore:setText(tostring(0))
	self.m_pAddAttack1:setText(tostring(0) .. "%")
	self.m_pAddDefence1:setText(tostring(0) .. "%")
	self.m_pAddSpeed1:setText(tostring(0) .. "%")
	self.m_pAddAttack2:setText(tostring(0) .. "%")
	self.m_pAddDefence2:setText(tostring(0) .. "%")
	self.m_pAddSpeed2:setText(tostring(0) .. "%")
	self.m_pAddBack:setVisible(false)
	self:setRedScore(0)
	self:setBlueScore(0)
	self.m_pMarkRed:setVisible(false)
	self.m_pMarkBlue:setVisible(false)
	self.m_pUpRed:setVisible(false)
	self.m_pUpRedBack:setVisible(false)
	self.m_pUpBlue:setVisible(false)
	self.m_pUpBlueBack:setVisible(false)
	--self.m_pTime:setText(MHSD_UTILS.get_resstring(2917))
	self.m_pTime:setText("00:00")
	self.m_pJoinBtn:setProperty("NormalImage", "set:MainControl1 image:join")
	self.m_pJoinBtn:setProperty("HoverImage", "set:MainControl1 image:join")
	self.m_pJoinBtn:setProperty("PushedImage", "set:MainControl1 image:join")
	self.m_pJoinBtn:setProperty("DisabledImage", "set:MainControl1 image:joindisable")

	self.m_pShow = 1
	self.m_pStat = Stat_Not_Started
	self.m_iAttackAdd = 0
	self.m_iDefenceAdd = 0
	self.m_iSpeedAdd = 0

	self.m_fRequireScoreTime = 0
	local moneyTable = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.czyzguwu")	
	local ids = moneyTable:getAllID()
	for i,v in pairs(ids) do
		local record = moneyTable:getRecorder(v)
		if 0 >= record.buffmin and 0 < record.buffmax then
			self.m_pAddAttackMoney:setText(tostring(record.needmoney))
			self.m_pAddDefenceMoney:setText(tostring(record.needmoney))
			self.m_pAddSpeedMoney:setText(tostring(record.needmoney))
			break
		end
	end

	if (GetTeamManager() and GetTeamManager():IsOnTeam() and GetTeamManager():IsMyselfLeader()) or (GetTeamManager() and (not GetTeamManager():IsOnTeam())) then
		self.m_pJoinBtn:setEnabled(true)
	else
		self.m_pJoinBtn:setEnabled(false)
	end

	if GetTeamManager() then
		self.m_hTeamListChange = GetTeamManager().EventTeamListChange:InsertScriptFunctor(CampVS.TeamStateChange)
	end

	local req = CReqCampInfo:Create()
	req.flag = 1
	LuaProtocolManager.getInstance():send(req)

	LogInfo("CampVS oncreate end")
end

------------------- private: -----------------------------------


function CampVS:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, CampVS)
    return self
end

function CampVS:HandleAddBtnClicked(args)
	LogInfo("CampVS HandleAddBtnClicked")
	if self.m_pShow == 1 then
		self.m_pShow = 2 
		self.m_pAddBack:setVisible(true)
		self.m_pEditBack:setVisible(false)
		self.m_pAddBtn:setText(MHSD_UTILS.get_resstring(2919))
	elseif self.m_pShow == 2 then
		self.m_pShow = 1 
		self.m_pAddBack:setVisible(false)
		self.m_pEditBack:setVisible(true)
		self.m_pAddBtn:setText(MHSD_UTILS.get_resstring(2918))
	end
end

function CampVS:HandleJoinBtnClicked(args)
	LogInfo("CampVS HandleJoinBtnClicked")
	if self.m_pStat == Stat_Started or self.m_pStat == Stat_Not_Started then
		local start = CCampBattleReadyFight:Create()
		start.ready = 1
		LuaProtocolManager.getInstance():send(start)
	elseif self.m_pStat == Stat_Joined then
		local start = CCampBattleReadyFight:Create()
		start.ready = 0
		LuaProtocolManager.getInstance():send(start)
	end
end

function CampVS:HandleAddAttackClicked(args)
	LogInfo("CampVS HandleAddAttackClicked")
	local req = CReqEncourage:Create()
	req.attrid = 1
	LuaProtocolManager.getInstance():send(req)
end

function CampVS:HandleAddDefenceClicked(args)
	LogInfo("CampVS HandleAddDefenceClicked")
	local req = CReqEncourage:Create()
	req.attrid = 2
	LuaProtocolManager.getInstance():send(req)
end

function CampVS:HandleAddSpeedClicked(args)
	LogInfo("CampVS HandleAddSpeedClicked")
	local req = CReqEncourage:Create()
	req.attrid = 3
	LuaProtocolManager.getInstance():send(req)
end

function CampVS:FreshScore(scoreRed, scoreBlue, time)
	self:setRedScore(scoreRed)
	self:setBlueScore(scoreBlue)
	if scoreRed > scoreBlue then
		self.m_pMarkRed:setVisible(true)
		self.m_pMarkBlue:setVisible(false)
	elseif scoreRed < scoreBlue then
		self.m_pMarkRed:setVisible(false)
		self.m_pMarkBlue:setVisible(true)
	else
		self.m_pMarkRed:setVisible(false)
		self.m_pMarkBlue:setVisible(false)
	end

	local diff = math.abs(scoreRed - scoreBlue)
	local buffTable = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.czybuff")	
	local ids = buffTable:getAllID()
	for i,v in pairs(ids) do
		local record = buffTable:getRecorder(v)
		if diff < record.scoremin then
			break
		elseif diff >= record.scoremin and diff <= record.scoremax then
			if scoreRed > scoreBlue then
				self.m_pUpRed:setVisible(false)
				self.m_pUpRedBack:setVisible(false)
				self.m_pUpBlue:setVisible(true)
				self.m_pUpBlueBack:setVisible(true)
				local strbuilder = StringBuilder:new()	
				strbuilder:Set("parameter1", record.percentnum)
				self.m_pUpBlue:setText(strbuilder:GetString(MHSD_UTILS.get_resstring(2920)))
				strbuilder:delete()
			elseif scoreRed < scoreBlue then
				self.m_pUpRed:setVisible(true)
				self.m_pUpRedBack:setVisible(true)
				self.m_pUpBlue:setVisible(false)
				self.m_pUpBlueBack:setVisible(false)
				local strbuilder = StringBuilder:new()	
				strbuilder:Set("parameter1", record.percentnum)
				self.m_pUpRed:setText(strbuilder:GetString(MHSD_UTILS.get_resstring(2920)))
				strbuilder:delete()
			end
			break
		end
	end

	if time > 0 and self.m_pStat == Stat_Not_Started then
		self.m_pStat = Stat_Started
		if (GetTeamManager() and GetTeamManager():IsOnTeam() and GetTeamManager():IsMyselfLeader()) or (GetTeamManager() and (not GetTeamManager():IsOnTeam())) then
			self.m_pJoinBtn:setEnabled(true)
		else
			self.m_pJoinBtn:setEnabled(false)
		end
	end
	self.m_fTime = time
end

function CampVS:Run(elapse)
	--if self.m_pStat == Stat_Not_Started then
	--	return
	--end

	if not GetBattleManager():IsInBattle() then 
		local oldTime = self.m_fRequireScoreTime
		self.m_fRequireScoreTime = self.m_fRequireScoreTime + elapse
		if oldTime <= 5000 and self.m_fRequireScoreTime > 5000 then
			local req = CReqCampInfo:Create()
			req.flag = 1
			LuaProtocolManager.getInstance():send(req)
		elseif self.m_fRequireScoreTime > 10000 then
			self.m_fRequireScoreTime = 0
			local req = CReqCampInfo:Create()
			req.flag = 2
			LuaProtocolManager.getInstance():send(req)
		end
	end

	if not self.m_fTime then
		return
	end

	local oldTime = self.m_fTime
	self.m_fTime = self.m_fTime - elapse
	if self.m_fTime < 0 then
		self.m_fTime = nil
		--self.m_pTime:setText(MHSD_UTILS.get_resstring(2917))
		self.m_pTime:setText("00:00")
		self.m_pStat = Stat_Not_Started
		local req = CReqCampInfo:Create()
		req.flag = 2
		LuaProtocolManager.getInstance():send(req)
		self.m_pJoinBtn:setEnabled(false)
		return 
	end
	
	if math.floor(oldTime / 1000) == math.floor(self.m_fTime / 1000) then
		return
	end
	local timeStr = string.format("%02d:%02d", self.m_fTime / 1000 / 60, (self.m_fTime / 1000) % 60)	
	self.m_pTime:setText(timeStr)
end

function CampVS:FreshRank(redList, blueList)
	LogInfo("CampVS FreshRank")
	if not self.m_pRedList then
		self.m_pRedList = {}
	end
	local i = 1
	for k, v in pairs(redList) do
		if not self.m_pRedList[i] then
			self.m_pRedList[i] = {}
			self.m_pRedList[i].cell = CampVSItem.CreateNewDlg(self.m_pListRed)
		end	
		self.m_pRedList[i].rolename = v.rolename
		self.m_pRedList[i].score = v.score
		self.m_pRedList[i].shape = v.shape
		self.m_pRedList[i].rank = i
		self.m_pRedList[i].cell:Init(i, v.rolename, v.score, v.shape)
		self.m_pRedList[i].cell:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0,0),CEGUI.UDim(0, 1 + (i - 1) * (self.m_pRedList[i].cell:GetWindow():getPixelSize().height))))

		i = i + 1
	end

	if not self.m_pBlueList then
		self.m_pBlueList = {}
	end
	i = 1
	for k, v in pairs(blueList) do
		if not self.m_pBlueList[i] then
			self.m_pBlueList[i] = {}
			self.m_pBlueList[i].cell = CampVSItem.CreateNewDlg(self.m_pListBlue)
		end	
		self.m_pBlueList[i].rolename = v.rolename
		self.m_pBlueList[i].score = v.score
		self.m_pBlueList[i].shape = v.shape
		self.m_pBlueList[i].rank = i
		self.m_pBlueList[i].cell:Init(i, v.rolename, v.score, v.shape)
		self.m_pBlueList[i].cell:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0,0),CEGUI.UDim(0, 1 + (i - 1) * (self.m_pBlueList[i].cell:GetWindow():getPixelSize().height))))

		i = i + 1
	end
end

function CampVS:FreshJoinBtn(ready)
	LogInfo("CampVS FreshJoinBtn")
	if ready == 1 then
		self.m_pStat = Stat_Joined
		self.m_pJoinBtn:setProperty("NormalImage", "set:MainControl1 image:cansel")
		self.m_pJoinBtn:setProperty("HoverImage", "set:MainControl1 image:cansel")
		self.m_pJoinBtn:setProperty("PushedImage", "set:MainControl1 image:cansel")
		self.m_pJoinBtn:setProperty("DisabledImage", "set:MainControl1 image:canseldisable")
	elseif ready == 0 then
		self.m_pStat = Stat_Started 
		self.m_pJoinBtn:setProperty("NormalImage", "set:MainControl1 image:join")
		self.m_pJoinBtn:setProperty("HoverImage", "set:MainControl1 image:join")
		self.m_pJoinBtn:setProperty("PushedImage", "set:MainControl1 image:join")
		self.m_pJoinBtn:setProperty("DisabledImage", "set:MainControl1 image:joindisable")
	end
end

function CampVS:FreshSelfInfo(wintimes, losttimes, comwin, score, encourage)
	LogInfo("CampVS FreshSelfInfo")
	self.m_pWinNum:setText(tostring(wintimes))	
	self.m_pFailNum:setText(tostring(losttimes))
	self.m_pBestNum:setText(tostring(comwin))
	self.m_pMyScore:setText(tostring(score))
	local attack = encourage[1]
	local defence = encourage[2]
	local speed = encourage[3]
	if not attack then
		attack = 0
	end
	if not defence then
		defence = 0
	end
	if not speed then
		speed = 0
	end

	local oldAttack = self.m_iAttackAdd
	self.m_iAttackAdd = attack
	local oldDefence = self.m_iDefenceAdd
	self.m_iDefenceAdd = defence
	local oldSpeed = self.m_iSpeedAdd
	self.m_iSpeedAdd = speed

	if oldAttack ~= self.m_iAttackAdd then
		self.m_pAddAttack1:setText(tostring(attack) .. "%")
		self.m_pAddAttack2:setText(tostring(attack) .. "%")
		local add = self.m_iAttackAdd - oldAttack
		if add == 1 then
			GetGameUIManager():RemoveUIEffect(self.m_pAttackEffect)
			GetGameUIManager():AddUIEffect(self.m_pAttackEffect, MHSD_UTILS.get_effectpath(10396), false)
		elseif add == 2 then
			GetGameUIManager():RemoveUIEffect(self.m_pAttackEffect)
			GetGameUIManager():AddUIEffect(self.m_pAttackEffect, MHSD_UTILS.get_effectpath(10398), false)
		elseif add == -1 then
			GetGameUIManager():RemoveUIEffect(self.m_pAttackEffect)
			GetGameUIManager():AddUIEffect(self.m_pAttackEffect, MHSD_UTILS.get_effectpath(10397), false)
		end

		local moneyTable = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.czyzguwu")	
		local ids = moneyTable:getAllID()
		for i,v in pairs(ids) do
			local record = moneyTable:getRecorder(v)
			if self.m_iAttackAdd >= record.buffmin and self.m_iAttackAdd < record.buffmax then
				self.m_pAddAttackMoney:setText(tostring(record.needmoney))
				break
			end
		end
	end

	if oldDefence ~= self.m_iDefenceAdd then
		self.m_pAddDefence1:setText(tostring(defence) .. "%")
		self.m_pAddDefence2:setText(tostring(defence) .. "%")
		local add = self.m_iDefenceAdd - oldDefence 
		if add == 1 then
			GetGameUIManager():RemoveUIEffect(self.m_pDefenceEffect)
			GetGameUIManager():AddUIEffect(self.m_pDefenceEffect, MHSD_UTILS.get_effectpath(10396), false)
		elseif add == 2 then
			GetGameUIManager():RemoveUIEffect(self.m_pDefenceEffect)
			GetGameUIManager():AddUIEffect(self.m_pDefenceEffect, MHSD_UTILS.get_effectpath(10398), false)
		elseif add == -1 then
			GetGameUIManager():RemoveUIEffect(self.m_pDefenceEffect)
			GetGameUIManager():AddUIEffect(self.m_pDefenceEffect, MHSD_UTILS.get_effectpath(10397), false)
		end

		local moneyTable = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.czyzguwu")	
		local ids = moneyTable:getAllID()
		for i,v in pairs(ids) do
			local record = moneyTable:getRecorder(v)
			if self.m_iDefenceAdd >= record.buffmin and self.m_iDefenceAdd < record.buffmax then
				self.m_pAddDefenceMoney:setText(tostring(record.needmoney))
				break
			end
		end
	end

	if oldSpeed ~= self.m_iSpeedAdd then
		self.m_pAddSpeed1:setText(tostring(speed) .. "%")
		self.m_pAddSpeed2:setText(tostring(speed) .. "%")
		local add = self.m_iSpeedAdd - oldSpeed 
		if add == 1 then
			GetGameUIManager():RemoveUIEffect(self.m_pSpeedEffect)
			GetGameUIManager():AddUIEffect(self.m_pSpeedEffect, MHSD_UTILS.get_effectpath(10396), false)
		elseif add == 2 then
			GetGameUIManager():RemoveUIEffect(self.m_pSpeedEffect)
			GetGameUIManager():AddUIEffect(self.m_pSpeedEffect, MHSD_UTILS.get_effectpath(10398), false)
		elseif add == -1 then
			GetGameUIManager():RemoveUIEffect(self.m_pSpeedEffect)
			GetGameUIManager():AddUIEffect(self.m_pSpeedEffect, MHSD_UTILS.get_effectpath(10397), false)
		end

		local moneyTable = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.czyzguwu")	
		local ids = moneyTable:getAllID()
		for i,v in pairs(ids) do
			local record = moneyTable:getRecorder(v)
			if self.m_iSpeedAdd >= record.buffmin and self.m_iSpeedAdd < record.buffmax then
				self.m_pAddSpeedMoney:setText(tostring(record.needmoney))
				break
			end
		end
	end
end

function CampVS:HandleCheckMyself(args)
	LogInfo("CampVS HandleCheckMyself")
	if self.m_pShowMyself:isSelected() then
		self.m_pEditbox:Clear()
		self.m_pEditbox:Refresh()
		CampVSMessage.getInstance():refresh(1)
	else
		self.m_pEditbox:Clear()
		self.m_pEditbox:Refresh()
		CampVSMessage.getInstance():refresh(0)
	end
end

function CampVS:AddMessage(message)
	LogInfo("CampVS AddMessage")
	if not self.m_pShowMyself:isSelected() then
		self:AddMessageToBox(message)	
	elseif message.ismine == 1 then
		self:AddMessageToBox(message)
	end
end

function CampVS:AddMessageToBox(message)
	LogInfo("CampVS AddMessageToBox")
	local strbuilder = StringBuilder:new()	
	if message.flag == 1 then
		strbuilder:Set("parameter1", message.rolename1)	
		if message.camp1 == 1 then
			strbuilder:Set("parameter2", "ffff3333")
		elseif message.camp1 == 2 then
			strbuilder:Set("parameter2", "ff3333ff")
		end
		strbuilder:SetNum("parameter3", message.win)
		local id = 145269
		if message.win > 10 then
			id = id + 10 - 3
		else
			id = id + message.win - 3
		end
		self.m_pEditbox:AppendBreak()
		self.m_pEditbox:AppendParseText(CEGUI.String(strbuilder:GetString(MHSD_UTILS.get_msgtipstring(id))))
		self.m_pEditbox:Refresh()
	elseif message.flag == 2 then
		strbuilder:Set("parameter1", message.rolename1)
		if message.camp1 == 1 then
			strbuilder:Set("parameter2", "ffff3333")
		elseif message.camp1 == 2 then
			strbuilder:Set("parameter2", "ff3333ff")
		end
		strbuilder:Set("parameter3", message.rolename2)
		if message.camp2 == 1 then
			strbuilder:Set("parameter4", "ffff3333")
		elseif message.camp2 == 2 then
			strbuilder:Set("parameter4", "ff3333ff")
		end
		strbuilder:SetNum("parameter5", message.win)
		self.m_pEditbox:AppendBreak()
		self.m_pEditbox:AppendParseText(CEGUI.String(strbuilder:GetString(MHSD_UTILS.get_msgtipstring(145277))))
		self.m_pEditbox:Refresh()
	elseif message.flag == 3 then
		strbuilder:Set("parameter1", message.rolename1)	
		if message.camp1 == 1 then
			strbuilder:Set("parameter2", "ffff3333")
		elseif message.camp1 == 2 then
			strbuilder:Set("parameter2", "ff3333ff")
		end
		self.m_pEditbox:AppendBreak()
		self.m_pEditbox:AppendParseText(CEGUI.String(strbuilder:GetString(MHSD_UTILS.get_msgtipstring(145268))))
		self.m_pEditbox:Refresh()
	elseif message.flag == 4 then
		strbuilder:SetNum("parameter1", message.win)
		self.m_pEditbox:AppendBreak()
		self.m_pEditbox:AppendParseText(CEGUI.String(strbuilder:GetString(MHSD_UTILS.get_msgtipstring(145285))))
		self.m_pEditbox:Refresh()
	elseif message.flag == 5 then
		strbuilder:SetNum("parameter1", message.win)
		self.m_pEditbox:AppendBreak()
		self.m_pEditbox:AppendParseText(CEGUI.String(strbuilder:GetString(MHSD_UTILS.get_msgtipstring(145286))))
		self.m_pEditbox:Refresh()
	end
	strbuilder:delete()
end

function CampVS:setRedScore(score)
	LogInfo("CampVS setRedScore")
	local scoreRed = score
	for i = 0, 5 do
		self.m_pScoreRed[i]:setVisible(false)
	end
	self.m_pScoreRed[0]:setVisible(true)
	self.m_pScoreRed[0]:setProperty("Image", "set:MainControl27 image:0")

	local pos = 0
	while scoreRed > 0 do
		local num = scoreRed % 10
		self.m_pScoreRed[pos]:setVisible(true)
		self.m_pScoreRed[pos]:setProperty("Image", "set:MainControl27 image:" .. tostring(num))
		scoreRed = math.floor(scoreRed / 10)
		pos = pos + 1
	end

end

function CampVS:setBlueScore(score)
	LogInfo("CampVS setBlueScore")
	local scoreBlue = score
	for i = 0, 5 do
		self.m_pScoreBlue[i]:setVisible(false)
	end
	self.m_pScoreBlue[0]:setVisible(true)
	self.m_pScoreBlue[0]:setProperty("Image", "set:MainControl27 image:0")

	local pos = 0
	while scoreBlue > 0 do
		local num = scoreBlue % 10
		self.m_pScoreBlue[pos]:setVisible(true)
		self.m_pScoreBlue[pos]:setProperty("Image", "set:MainControl27 image:" .. tostring(num))
		scoreBlue = math.floor(scoreBlue / 10)
		pos = pos + 1
	end

end

return CampVS
