require "utils.mhsdutils"
require "ui.dialog"
 
ActivityDlg = {}
setmetatable(ActivityDlg, Dialog)
ActivityDlg.__index = ActivityDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
local shimenID = 1
local wujueID = 2
local enchouID = 3
local jingjichangID = 4
local yaoqianID = 5
local bosiID = 6
local yexiID = 7
local jueqingID = 8
local shendiaoID = 9
local leitaiID = 10
local fenghuoID = 11
local nationdayID = 12
local offlineExp = 99
local xiangshiID = 101
local huishiID = 102
local chuangguanID = 103
local wudaohuiID = 119
local factionID = 120
local campVS = 125
local legendID = 126
local biaoID = 127
local fanfanleID = 13
local jihousai = 141
local zhanduisai132 = 132
local zhanduisai133 = 133 
local zhanduisai134 = 134 
local zhanduisai135 = 135 
local gumumijing = 160
local xiaganyidanID = 14
function ActivityDlg.getInstance()
	LogInfo("enter get activitydlg instance")
    if not _instance then
        _instance = ActivityDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function ActivityDlg.getInstanceAndShow()
	LogInfo("enter activitydlg instance show")
    if not _instance then
        _instance = ActivityDlg:new()
        _instance:OnCreate()
	else
		LogInfo("set activitydlg visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function ActivityDlg.getInstanceNotCreate()
    return _instance
end

function ActivityDlg.DestroyDialog()
	if _instance then 
		LogInfo("destroy activitydlg")
		if _instance.m_lActivity then
			_instance.m_pPane:cleanupNonAutoChildren()
			_instance.m_lActivity = nil 
		end
		_instance:OnClose()
		_instance = nil
	end
end

function ActivityDlg.ToggleOpenClose()
	if not _instance then 
		_instance = ActivityDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function ActivityDlg.refreshList(activityList, todayActivityNum, chestTake,remainActivityNum)
	LogInfo("activitydlg refresh list")
	  if ActivityManager.getInstanceNotCreate() then
		local actManager = ActivityManager.getInstanceNotCreate()
		actManager.m_iActivityNum = remainActivityNum
		actManager.m_iActivityChest = chestTake
		actManager.m_lActivityList = activityList
		actManager.m_iActivityTodayNum = todayActivityNum
        require "ui.activity.activityentrance"
        ActivityEntrance.refreshEffect()
		local dlgInstance = ActivityDlg.getInstanceAndShow()
		dlgInstance:resetList(activityList)
	end
end

----/////////////////////////////////////////------

function ActivityDlg.GetLayoutFileName()
    return "activitydlgnew.layout"
end

function ActivityDlg:OnCreate()
	LogInfo("activitydlg oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
	self.m_pDailyRewardBtn = CEGUI.Window.toPushButton(winMgr:getWindow("activitydlgnew/left/meiri"))
	self.m_pShopBtn = CEGUI.Window.toPushButton(winMgr:getWindow("activitydlgnew/left/shangcheng")) 

	self.m_pPane = CEGUI.Window.toScrollablePane(winMgr:getWindow("activitydlgnew/right/main"))
	self.m_pTime = winMgr:getWindow("activitydlgnew/right/timetxt1")
	self.todayPoint = winMgr:getWindow("activitydlgnew/left/shuzi1")
	self.remainPoint = winMgr:getWindow("activitydlgnew/left/shuzi2")
	self.dailyYuanbao = winMgr:getWindow("activitydlgnew/left/meiri/wenzi1")

	self.todayPoint:setText("")
	self.remainPoint:setText("")

    -- subscribe event
	self.m_pDailyRewardBtn:subscribeEvent("Clicked", ActivityDlg.HandleClick, self)
	self.m_pShopBtn:subscribeEvent("Clicked", ActivityDlg.HandleClick, self)


	self.m_pDailyRewardBtn:setID(1)
	self.m_pShopBtn:setID(2)

	self:refreshTotalActivity()

	self.m_fServerTime = GetServerTime() 
	local time = StringCover.getTimeStruct(self.m_fServerTime / 1000)
	local second = time.tm_sec
	local minute = time.tm_min
	local hour = time.tm_hour
	local timeStr = string.format("%02d:%02d:%02d", hour, minute, second)
	self.m_pTime:setText(timeStr)

	LogInfo("activitydlg oncreate end")
end

------------------- private: -----------------------------------


function ActivityDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, ActivityDlg)
    return self
end

function ActivityDlg:refreshGiftBoxBtnState()
	LogInfo("activitydlg refresh gift box button state")
	if ActivityManager.getInstanceNotCreate() then
		local chest = ActivityManager.getInstanceNotCreate().m_iActivityChest
		self.todayPoint:setText(ActivityManager.getInstanceNotCreate().m_iActivityTodayNum)
		self.remainPoint:setText(ActivityManager.getInstanceNotCreate().m_iActivityNum)
		if chest == 2 then
			self.m_pDailyRewardBtn:setEnabled(false)
			self.dailyYuanbao:setProperty("Image", "set:MainControl29 image:yilingqu")
		else
			self.m_pDailyRewardBtn:setEnabled(true)
			self.dailyYuanbao:setProperty("Image", "set:MainControl29 image:meirisong")
		end
	end
end

function ActivityDlg:refreshTotalActivity()
	LogInfo("activitydlg refresh total activity")
	if ActivityManager.getInstanceNotCreate() then
		self:refreshGiftBoxBtnState()
	end
end

function ActivityDlg:HandleClick(args)
	LogInfo("activitydlg handle giftbox clicked")
	local e = CEGUI.toWindowEventArgs(args)
	local id = e.window:getID()
	if id == 1 then
		if ActivityManager.getInstanceNotCreate().m_iActivityChest == 0 and ActivityManager.getInstanceNotCreate().m_iActivityTodayNum < 80 then
			GetGameUIManager():AddMessageTip(knight.gsp.message.GetCMessageTipTableInstance():getRecorder(145657).msg)
		else
			GetNetConnection():send(knight.gsp.task.activelist.CDrawGiftBox())
		end
	else 
		self.DestroyDialog()
		CNpcSellItemDlg:GetSingletonDialog():ExchangeHuoYueDuShangChengScore()
	end
	return true
end

function ActivityDlg:resetList(activities)
	LogInfo("activitydlg reset list")
	self:cleanupList()

	local time = StringCover.getTimeStruct(GetServerTime() / 1000)
	local curWeekDay = time.tm_wday
	if curWeekDay == 0 then
		curWeekDay = 7
	end

	local yearCur = time.tm_year + 1900
	local monthCur = time.tm_mon + 1
	local dayCur = time.tm_mday

	local ids = std.vector_int_()
	knight.gsp.task.GetCTaskListTableInstance():getAllID(ids)
	local num = ids:size()
	local roleLevel = GetDataManager():GetMainCharacterLevel()
	for i =0, num - 1 do
		local record = knight.gsp.task.GetCTaskListTableInstance():getRecorder(ids[i])
		if roleLevel >= record.level and roleLevel <= record.level2 and bit.band(bit.blshift(1, curWeekDay - 1), record.week) > 0 then
			
			local activityToday = true
			if record.tasktype == 1 then
				local ids2 = std.vector_int_()
				knight.gsp.timer.GetCScheculedActivityTableInstance():getAllID(ids2)
				local num2 = ids2:size()
				activityToday = false
				for i2 = 0, num2 -1 do
					local record2 = knight.gsp.timer.GetCScheculedActivityTableInstance():getRecorder(ids2[i2])
					local starty, startm, startd, starth, startmin, starts = string.match(record2.startTime, "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
					startd = tonumber(startd)
					starty = tonumber(starty)
					startm = tonumber(startm)
					if record2.activityid == record.id then
						if not string.find(record2.startTime, "-") then
							activityToday = true	
							break
						elseif starty == yearCur and startm == monthCur and startd == dayCur then
							activityToday = true
							break
						end
					end
				end
			end

if activityToday then
				local activity = {}
				activity.cell = ActivityCell.CreateNewDlg(self.m_pPane, record.id)
				activity.finishTimes = 0
				activity.tasktype = record.tasktype
				activity.id = record.id
				activity.backtype = activity.cell.m_iBackType
				table.insert(self.m_lActivity, activity)
			end
		end
	end
	
	for i,v in pairs(activities) do
		for j,k in ipairs(self.m_lActivity) do
			if k.id == i then
				k.cell:Init(v)
				k.backtype = k.cell.m_iBackType
				break
			end
		end
	end

	table.sort(self.m_lActivity, ActivityDlg.SortList)

	for i,v in ipairs(self.m_lActivity) do
		v.cell:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0, 0), CEGUI.UDim(0, (i - 1) * v.cell:GetWindow():getPixelSize().height + 1))) 
	end
end

function ActivityDlg.SortList(act1, act2)
	if (not act1) or (not act2) then
		return false
	end
	if act1.tasktype == 1 and act2.tasktype == 1 then
		if act1.backtype == act2.backtype then
			return act1.id < act2.id
		else
			--1 end, 2 open, 3 normal
			if act1.backtype == 1 then
				return false
			else
				return true
			end
		end
	elseif act1.tasktype == 1 then
		if act1.backtype == 1 then
			return false
		else
			return true
		end
	elseif act2.tasktype == 1 then
		if act2.backtype == 1 then
			return true	
		else
			return false 
		end
	else
		return act1.id < act2.id	
	end
end

function ActivityDlg:cleanupList()
	LogInfo("activitydlg cleanup list")
	if self.m_lActivity then
		self.m_pPane:cleanupNonAutoChildren()
		self.m_lActivity = nil 
	end
	self.m_lActivity = {}
end

function ActivityDlg:HandleGoClick(args)
	LogInfo("activitydlg handle go clicked")

	local e = CEGUI.toWindowEventArgs(args)
	local id = e.window:getID()

	if id == shimenID then
		local schoolID = GetDataManager():GetMainCharacterSchoolID()
		local schoolRecord = knight.gsp.role.GetSchoolMasterSkillInfoTableInstance():getRecorder(schoolID)
		if schoolRecord == -1 then
			return false
		end
		self:GoByNPCID(schoolRecord.masterid)
	elseif id == wujueID then 
		self:GoByNPCID(10565)
	elseif id == enchouID then
		self:GoByNPCID(10779)
	elseif id == jingjichangID then
		GetPKManager():RequestStart()
	elseif id == yaoqianID then
		YaoQianShuDlg.getInstanceAndShow()	
	elseif id == bosiID then
		self:GoByNPCID(10271)
	elseif id == yexiID then
		self:GoByNPCID(10181)
	elseif id == jueqingID then
		self:GoByNPCID(10925)
	elseif id == shendiaoID then
		self:GoByNPCID(11109)
	elseif id == xiangshiID then
		GetKeJuManager():ApplyKeju(1, 0)
	elseif id == huishiID then
		GetKeJuManager():ApplyKeju(2, 0)
	elseif id == chuangguanID then
		GetMainCharacter():FlyOrWarkToPos(1013, 70, 105, 10127)
	elseif id == factionID then
		self:GoByNPCID(10073)
	elseif id == nationdayID then
		local p = require "protocoldef.knight.gsp.task.creqmrystask":new()
		p.flag = 0
		require "manager.luaprotocolmanager":send(p)
	elseif id == wudaohuiID then
		GetNetConnection():send(knight.gsp.task.CReqJionActivity(1))
	elseif id == leitaiID then
		local posList = {}
		local pos1 = {}
		pos1.x = 61
		pos1.y = 97
		posList[1] = pos1
		local pos2 = {}
		pos2.x = 60
		pos2.y = 118
		posList[2] = pos2
		local pos3 = {}
		pos3.x = 84
		pos3.y = 113
		posList[3] = pos3
		local num = math.random(1, 3)
		GetMainCharacter():FlyOrWarkToPos(1002, posList[num].x, posList[num].y, -1)	
	elseif id == fenghuoID then
    	CMainPackLabelDlg:GetSingletonDialogAndShowIt():Show()
	elseif id == offlineExp then
		ActivityManager.reqOfflineExp()
	elseif id == campVS then
		require "protocoldef.knight.gsp.battle.ccampbattlestart"
		local start = CCampBattleStart:Create()
		LuaProtocolManager.getInstance():send(start)
  		GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
	elseif id == legendID then
		self:GoByNPCID(12094)
	elseif id == biaoID then
		self:GoByNPCID(12018)
	elseif id == fanfanleID then
		self:GoByNPCID(12303)
	elseif id == jihousai then
		local CAgreeDrawRole = require "protocoldef.knight.gsp.faction.cagreedrawrole"
		local req = CAgreeDrawRole.Create()
		req.agree = 1
		req.flag = 4
		LuaProtocolManager.getInstance():send(req)
	elseif id == zhanduisai132 or id == zhanduisai133 or id == zhanduisai134 or id == zhanduisai135 then
	  local p = require "protocoldef.knight.gsp.faction.cagreedrawrole" : new()
	  p.agree = 1 
	  p.flag = 1
	  require "manager.luaprotocolmanager":send(p)
    elseif id == gumumijing then
        local CAgreeDrawRole = require "protocoldef.knight.gsp.faction.cagreedrawrole"
		local req = CAgreeDrawRole.Create()
		req.agree = 1
		req.flag = 6
		LuaProtocolManager.getInstance():send(req)
	elseif id == xiaganyidanID then
		self:GoByNPCID(12391)
	end

	ActivityDlg.DestroyDialog()
	return true
end

function ActivityDlg:GoByNPCID(id)
	LogInfo("activitydlg go by npcid")
	local npcConfig = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(id)	
	GetMainCharacter():FlyOrWarkToPos(npcConfig.mapid, npcConfig.xPos, npcConfig.yPos, npcConfig.id)
	
end

function ActivityDlg:Run(elapsed)
	local oldTime = self.m_fServerTime
	self.m_fServerTime = self.m_fServerTime + elapsed	
	if math.floor(oldTime / 1000) == math.floor(self.m_fServerTime / 1000) then
		return
	end
	local time = StringCover.getTimeStruct(self.m_fServerTime / 1000)
	local second = time.tm_sec
	local minute = time.tm_min
	local hour = time.tm_hour
	local year = time.tm_year + 1900
	local month = time.tm_mon + 1
	local day = time.tm_mday
	local timeStr = string.format("%04d-%02d-%02d %02d:%02d:%02d", year, month, day, hour, minute, second)
	self.m_pTime:setText(timeStr)
end


return ActivityDlg
