require "ui.activity.activitydlginfocell"
ActivityCell = {}


setmetatable(ActivityCell, Dialog)
ActivityCell.__index = ActivityCell
local prefix = 0

local backTypeEnd = 1
local backTypeOpen = 2
local backTypeNormal = 3

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
function ActivityCell.CreateNewDlg(pParentDlg, id)
	LogInfo("enter ActivityCell.CreateNewDlg")
	local newDlg = ActivityCell:new()
	newDlg:OnCreate(pParentDlg, id)

    return newDlg
end



----/////////////////////////////////////////------

function ActivityCell.GetLayoutFileName()
    return "activitydlgnewcell.layout"
end

function ActivityCell:OnCreate(pParentDlg, id)
	LogInfo("enter ActivityCell oncreate")
	prefix = prefix + 1
    Dialog.OnCreate(self, pParentDlg, prefix)

    local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pBackEnd = winMgr:getWindow(tostring(prefix) .. "activitydlgnewcell/end")
	self.m_pBackOpen = winMgr:getWindow(tostring(prefix) .. "activitydlgnewcell/open")
	self.m_pBackNormal = winMgr:getWindow(tostring(prefix) .. "activitydlgnewcell/normal")	
	self.m_pName = winMgr:getWindow(tostring(prefix) .. "activitydlgnewcell/name")
	self.m_pFinishTime = winMgr:getWindow(tostring(prefix) .. "activitydlgnewcell/num0")
	self.m_pTotalTime = winMgr:getWindow(tostring(prefix) .. "activitydlgnewcell/num1")
	self.m_pCurActNum = winMgr:getWindow(tostring(prefix) .. "activitydlgnewcell/num2")
	self.m_pTotalActNum = winMgr:getWindow(tostring(prefix) .. "activitydlgnewcell/num3")
	self.m_pGoBtn = CEGUI.Window.toPushButton(winMgr:getWindow(tostring(prefix) .. "activitydlgnewcell/main/go"))
	self.m_pStatText = winMgr:getWindow(tostring(prefix) .. "activitydlgnewcell/main/TXT")
	self.m_pInfoBtn = CEGUI.Window.toPushButton(winMgr:getWindow(tostring(prefix) .. "activitydlgnewcell/main/info"))

	self.m_pGoBtn:subscribeEvent("Clicked", ActivityDlg.HandleGoClick, ActivityDlg.getInstance())
	self.m_pInfoBtn:subscribeEvent("Clicked", ActivityCell.HandleInfoClicked, self)

	self.m_pGoBtn:setID(id)
	self.m_ID = id
	self:Init(0)

	LogInfo("exit ActivityCell OnCreate")
end

------------------- public: -----------------------------------

function ActivityCell:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, ActivityCell)

    return self
end

function ActivityCell:Init(finishTimes)
	LogInfo("ActivityCell init")
	local record = knight.gsp.task.GetCTaskListTableInstance():getRecorder(self.m_ID)
	self.m_pName:setText(record.taskname)
	self.m_pFinishTime:setText(tostring(finishTimes))			

	local totalTimes = record.totaltimes
	--shimen
	if self.m_ID == 1 then
		local ids = std.vector_int_()
		knight.gsp.specialquest.GetCchoolQuestMaxTableInstance():getAllID(ids)
		local num = ids:size()
		local roleLevel = GetDataManager():GetMainCharacterLevel()
		for i = 0, num - 1 do
			local shimenRecord = knight.gsp.specialquest.GetCchoolQuestMaxTableInstance():getRecorder(ids[i])
			if shimenRecord.levelmax >= roleLevel and shimenRecord.levelmin <= roleLevel then
				totalTimes = shimenRecord.max
				break
			end
		end
	end
	self.m_pTotalTime:setText(tostring(totalTimes))
	
	local curActNum = 0
	local maxActNum = 0
	for i = 0 , 2 do
		maxActNum = maxActNum + record.actvalue[i]
		if finishTimes >= record.actgettimes[i] then
			curActNum = curActNum + record.actvalue[i]
		end
	end
	self.m_pCurActNum:setText(tostring(curActNum))
	self.m_pTotalActNum:setText(tostring(maxActNum))

	self.m_pBackEnd:setVisible(false)
	
	if record.tasktype == 1 then
		if ActivityManager.getInstance():isOpened(self.m_ID) then
			self:setBack(backTypeOpen)
		else
			--self:setBack(backTypeEnd)
			self:setStatText()
			if not ActivityManager.getInstance():isInTime(self.m_ID) then
				self.m_pGoBtn:setVisible(false)
			end
		end
	else
		if finishTimes >= totalTimes then
			self:setBack(backTypeEnd)
		else
			self:setBack(backTypeNormal)
		end 
	end	
end

function ActivityCell:setBack(backtype)
	LogInfo("activitycell set back")
	self.m_pBackEnd:setVisible(false)
	self.m_pBackOpen:setVisible(false)
	self.m_pBackNormal:setVisible(false)

	if backtype == backTypeEnd then
		self.m_pBackEnd:setVisible(true)
	elseif backtype == backTypeOpen then
		self.m_pBackOpen:setVisible(true)
	elseif backtype == backTypeNormal then
		self.m_pBackNormal:setVisible(true)
	end
	self.m_iBackType = backtype
end

function ActivityCell:setStatText()
	LogInfo("activity cell set stattext")
	local time = StringCover.getTimeStruct(GetServerTime() / 1000)
	local curTime = time.tm_hour * 3600 + time.tm_min * 60 + time.tm_sec
	
	local ids = std.vector_int_()
	knight.gsp.timer.GetCScheculedActivityTableInstance():getAllID(ids)
	local num = ids:size()
	for i = 0, num - 1 do
		local record = knight.gsp.timer.GetCScheculedActivityTableInstance():getRecorder(ids[i])
		local starth, startm, starts = string.match(record.startTime, "(%d+):(%d+):(%d+)")
		local endh, endm, ends = string.match(record.endTime, "(%d+):(%d+):(%d+)")
		local startTime = starth * 3600 + startm * 60 + starts
		local endTime = endh * 3600 + endm * 60 + ends
		if record.activityid == self.m_ID then
			if startTime > curTime then
				local strBuild = StringBuilder:new()
				strBuild:Set("parameter1", record.startTime)
				self.m_pStatText:setText(strBuild:GetString(MHSD_UTILS.get_resstring(2785)))	
				strBuild:delete()
				self:setBack(backTypeNormal)
				return
			elseif endTime < curTime then
				self:setBack(backTypeEnd)
				self.m_pStatText:setText(MHSD_UTILS.get_resstring(2786))	
			end
		end
	end
end

function ActivityCell:HandleInfoClicked(args)
	LogInfo("ActivityCell handle info clicked")
	ActivityDlgInfoCell.getInstanceAndShow():setInfo(self.m_ID)	
end



return ActivityCell
