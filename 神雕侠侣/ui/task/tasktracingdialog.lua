require "ui.dialog"
require "ui.fubenguidedialog"
require "ui.task.tasktrackcell"
require "ui.task.teammemberunit"
require "utils.tableutil"

local eFlyNull = 0
local eFlyFadeOut = 1
local eFlyFadeIn = 2

local eTaskFlyNull = 0
local eTaskFlyFadeOut = 1
local eTaskFlyFadeIn = 2

local eTeamFlyNull = 0
local eTeamFlyFadeOut = 1
local eTeamFlyFadeIn = 2
local function CloneUVector2(v)
	local newV = CEGUI.UVector2()
	newV.x = v.x
	newV.y = v.y
	return newV
end

local function isMrysTask(questid)
	local cfg = require "utils.mhsdutils".getLuaBean("knight.gsp.task.cfamoustask"):getRecorder(questid)
	return cfg and cfg.id ~= -1
end

CTaskTracingDialog = {}
setmetatable(CTaskTracingDialog, Dialog)
CTaskTracingDialog.__index = CTaskTracingDialog
local _instance

function CTaskTracingDialog.getSingleton()
	return _instance
end

function CTaskTracingDialog.new()
	LogInsane("CTaskTracingDialog.new")
	local t = {}
	setmetatable(t, CTaskTracingDialog)
	t.__index = CTaskTracingDialog
	t:OnCreate()
	t.m_mapCells = {}
	t.m_vTeamMem = {}
	t.m_felapsedTimeFadeout = 0
	t.m_felapsedTimeFadein = 0
	t.m_fTaskElapsedTimeFadeout = 0
	t.m_fTaskElapsedTimeFadein = 0
	t.m_fTeamElapsedTimeFadeout = 0
	t.m_fTeamElapsedTimeFadein = 0
	t.m_iOpenTaskId = 0
	t.m_eFlyType = eFlyNull
	t.m_eTaskFlyType = eTaskFlyNull
	t.m_eTeamFlyType = eTeamFlyNull
	t.m_bTeamHandleBtnVisible= false
	t.m_eDialogType = eDlgTypeNull;
	t.m_bEscClose = false
	t.m_bTeamHandleBtnVisible = false
	return t
end

function CTaskTracingDialog.getSingletonDialog()
	if _instance == nil then
		_instance = CTaskTracingDialog.new()
	end
	return _instance
end

function CTaskTracingDialog.ToggleOpenHide()
	LogInsane("CTaskTracingDialog.ToggleOpenHide")
	if _instance == nil then
		_instance = CTaskTracingDialog.new()
	else
		local bVisible = _instance:IsVisible()
		if bVisible then
			_instance:OnClose()
		else
			_instance:SetVisible(true)
		end
	end
end

function CTaskTracingDialog:OnCreate()
	LogInsane("CTaskTracingDialog:OnCreate")
	Dialog.OnCreate(self)
	self.m_hUpdateLastQuest = GetTaskManager().EventUpdateLastQuest:InsertScriptFunctor(CTaskTracingDialog.RefreshLastTask)
	self.StateNotify = LuaTaskTraceStateChangeNotify(CTaskTracingDialog.OnTaskTraceStateChangeNotify)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pTaskPane = CEGUI.toScrollablePane(winMgr:getWindow("TaskTracingDialog/taskback"))
	local container_task = CEGUI.toScrolledContainer(self.m_pTaskPane:getContentPane())
    if container_task then
         container_task:setMousePassThroughEnabled(true);
    end
    self.m_pTeamPane = CEGUI.toScrollablePane(winMgr:getWindow("TaskTracingDialog/teamback"));
    self.m_pTeamPane:setMousePassThroughEnabled(true);
    local container_team = CEGUI.toScrolledContainer(self.m_pTeamPane:getContentPane())
    if container_team then
        container_team:setMousePassThroughEnabled(true);
    end
	self.m_pTeamPane:setVisible(false);
  
    self.m_pShowStateBack = winMgr:getWindow("TaskTracingDialog");
    self.m_pShowStateBack:setVisible(true);

	self.m_pTitle = CEGUI.toGUISheet(winMgr:getWindow("TaskTracingDialog/title"))
    self.m_pTitle:setDragMovingEnabled(false)
    -- visible from the first time
    self.m_pTitle:setVisible(true)
	self.m_pTaskBtn = CEGUI.toPushButton(winMgr:getWindow("TaskTracingDialog/title/task"))
	self.m_pTaskBtn:subscribeEvent("Clicked", CTaskTracingDialog.HandleTaskShowHideDialog, self)
    
    self.m_pTeamBtn = CEGUI.toPushButton(winMgr:getWindow("TaskTracingDialog/title/team"))
	self.m_pTeamBtn:subscribeEvent("Clicked", CTaskTracingDialog.HandleTeamShowHideDialog, self)
    
    self.m_pHideBtn = CEGUI.toPushButton(winMgr:getWindow("TaskTracingDialog/title/retract"))
	self.m_pHideBtn:subscribeEvent("Clicked", CTaskTracingDialog.HandleHideAllDialog, self)
    self.m_pHideStateBack = winMgr:getWindow("TaskTracingDialog/main/simple")   --隐藏，简版显示下父窗口
    self.m_pHideStateBack:setVisible(false)
    self.m_pShowBtn = CEGUI.toPushButton(winMgr:getWindow("TaskTracingDialog/main/simple/spread"))
    self.m_pShowBtn:subscribeEvent("Clicked", CTaskTracingDialog.HandleShowDialog, self)
    
    self.m_pTaskIconBtn = CEGUI.toPushButton(winMgr:getWindow("TaskTracingDialog/main/simple/taskgo"))
    self.m_pTaskIconBtn:subscribeEvent("Clicked", CTaskTracingDialog.HandleGotoCurDst,self)

	self.m_pDialog = winMgr:getWindow("TaskTracingDialog/main");
	self.m_pDialog:setMousePassThroughEnabled(true);
	self.m_pDialog:SetDisplaySizeChangePosEnable(false);
	self.m_pDialog:SetDisplaySizeEnable(false);
	self.m_pDialog:subscribeEvent("Moved", CTaskTracingDialog.HandleMoveDialog, self)
	self.m_fMiniHeight = self.m_pDialog:getPixelSize().height
	self.m_fMiniWidth =  self.m_pDialog:getPixelSize().width
	self.m_fCurWidth = self.m_fMiniWidth;
	self.m_fMaxHeight = 250
    self.m_pDialog:subscribeEvent("WindowUpdate", CTaskTracingDialog.HandleWindowUpdate, self)
    self.m_ShowStateBackInitPos = CloneUVector2(self.m_pShowStateBack:getPosition())
    self.m_TaskBackInitPos = CloneUVector2(self.m_pTaskPane:getPosition())
    self.m_TeamBackInitPos = CloneUVector2(self.m_pTeamPane:getPosition())
    self.m_pTaskPane:setVisible(true)
    self.m_pTaskBtn:setProperty("NormalImage","set:MainControl4 image:tasklistHnormal")
    self.m_pTaskBtn:setProperty("PushedImage","set:MainControl4 image:tasklistHnormal")
    
    self.m_pTeamPane:subscribeEvent("Shown", CTaskTracingDialog.HandleTeamPaneShown, self)
    self:GetWindow():subscribeEvent("Shown", CTaskTracingDialog.HandleTeamPaneShown, self)
    
    self.m_pLeaveBtn = CEGUI.toPushButton(winMgr:getWindow("TaskTracingDialog/teamback/leave"))
    self.m_pLeaveBtn:subscribeEvent("Clicked", CTaskTracingDialog.HandleLeaveBtnClicked, self)
    self.m_pLeaveBtn:setVisible(false);

    self.m_pBackBtn = CEGUI.toPushButton(winMgr:getWindow("TaskTracingDialog/teamback/back"))
    self.m_pBackBtn:subscribeEvent("Clicked", CTaskTracingDialog.HandleBackBtnClicked, self)
    self.m_pBackBtn:setVisible(false)

	self.m_pFubenBack = winMgr:getWindow("TaskTracingDialog/fuben")
	self.m_pFubenBack:setVisible(false)

	if GetBattleManager():IsInBattle() then
		self:SetVisible(false)
	end
    self.m_bTeamBtnEnable = GetTeamManager():IsOnTeam()
    
	self.m_hItemNumChangeNotify = GetRoleItemManager():InsertLuaItemNumChangeNotify(CTaskTracingDialog.OnItemNumberChange)
end

function CTaskTracingDialog.RefreshLastTask(taskid)
	LogInsane("CTaskTracingDialog.RefreshLastTask"..taskid)
	local self = _instance
	if self == nil then
		return
	end
	local tracetime = GetTaskManager():GetQuestTraceTime(taskid)
	if tracetime == 0 then
		return
	end
	self:RefreshQuestItem(taskid, tracetime)
--	self:UpdateDialogHeight()
end

function CTaskTracingDialog:count(taskid)
	local x = 0
	for i = 1, #self.m_mapCells do
		if self.m_mapCells[i].id == taskid then
			x = x + 1
		end
	end
	return x
end

function CTaskTracingDialog.OnTaskTraceStateChangeNotify(questid)
	LogInsane("CTaskTracingDialog.OnTaskTraceStateChangeNotify"..questid)
	local self = _instance
	if self == nil then
		return
	end
	
	local bTrace = GetTaskManager():IsQuestInTraceList(questid)
	if not bTrace and self:count(questid) > 0 then
		self:RemoveCellByID(questid)
	elseif bTrace and self:count(questid) == 0 then
		local tracetime = GetTaskManager():GetQuestTraceTime(questid)
		local quest = GetTaskManager():GetSpecialQuest(questid)
		if quest then
			self:AddSpecialQuestItem(quest, tracetime)
		else
			local quest = GetTaskManager():GetScenarioQuest(questid)
			if quest then
				self:AddScenarioQuestItem(quest, tracetime)
			else
				local pActiveQuest = GetTaskManager():GetReceiveQuest(questid)
				if pActiveQuest then
					self:AddQuestItem(pActiveQuest, tracetime)
				end
			end
		end
	end
end

function CTaskTracingDialog:HandleTaskShowHideDialog(e)
  if self.m_pTaskPane:isVisible() then
    require "ui.task.taskdialog".ToggleOpenHide()
    return
  end

	self.m_pTeamPane:setVisible(false)
	if self.m_pTaskPane:isVisible() or (self.m_bInWujue and self.m_pFubenBack:isVisible()) or (self.m_bInFuben and self.m_pFubenBack:isVisible()) then
        if GetDataManager():GetMainCharacterLevel() <= 10 then
            self.m_eTaskFlyType = eTaskFlyNull
 --           self.m_pTaskPane:setVisible(false)
			self.m_pFubenBack:setVisible(false)
        else
   --         self.m_eTaskFlyType = eTaskFlyFadeOut          
  --          self.m_fTaskElapsedTimeFadeout = 1/3
        end
   --     self.m_eTaskFlyType = eTaskFlyFadeOut   
   --     self.m_fTaskElapsedTimeFadeout = 1/3
        require "ui.task.taskdialog".ToggleOpenHide()
    
        self.m_pTaskBtn:setProperty("NormalImage","set:MainControl4 image:tasklistnormal")
        self.m_pTaskBtn:setProperty("PushedImage","set:MainControl4 image:tasklistnormal")
	else
        if GetDataManager():GetMainCharacterLevel() <= 10 then
            self.m_eTaskFlyType = eTaskFlyNull
			if self.m_bInWujue or self.m_bInFuben then
				self.m_pFubenBack:setVisible(true)
			else
 --           	self.m_pTaskPane:setVisible(true)
        	end
		else
            self.m_eTaskFlyType = eTaskFlyFadeIn            
            self.m_fTaskElapsedTimeFadein = 1/3
        end
		self.m_eTaskFlyType = eTaskFlyFadeIn            
        self.m_fTaskElapsedTimeFadein = 1/3
        self.m_pTaskBtn:setProperty("NormalImage","set:MainControl4 image:tasklistHnormal")
        self.m_pTaskBtn:setProperty("PushedImage","set:MainControl4 image:tasklistHnormal")
        
        self.m_pTeamBtn:setProperty("NormalImage","set:MainControl4 image:teambtn1normal")
        self.m_pTeamBtn:setProperty("PushedImage","set:MainControl4 image:teambtn1normal")
	end
	return true;
end
function CTaskTracingDialog:HandleTeamShowHideDialog(e)
	LogInsane("CTaskTracingDialog:HandleTeamShowHideDialog")
	
  if self.m_pTeamPane:isVisible() or not self.m_bTeamBtnEnable then
    require "ui.teamlabel"
    TeamLabel.getInstance().ShowStarDlg()
    return
  end
  
	if not self.m_bTeamBtnEnable then
        return true;
    end
    self.m_pTaskPane:setVisible(false)
	self.m_pFubenBack:setVisible(false)
	if self.m_pTeamPane:isVisible() then
        self.m_eTeamFlyType = eTeamFlyFadeOut
        self.m_fTeamElapsedTimeFadeout = 1/3
        self.m_pTeamBtn:setProperty("NormalImage","set:MainControl4 image:teambtn1normal")
        self.m_pTeamBtn:setProperty("PushedImage","set:MainControl4 image:teambtn1normal")
	else
		self.m_pTeamPane:setVisible(true)
        self.m_eTeamFlyType = eTeamFlyFadeIn
        self.m_fTeamElapsedTimeFadein = 1/3
        self.m_pTaskBtn:setProperty("NormalImage","set:MainControl4 image:tasklistnormal")
        self.m_pTaskBtn:setProperty("PushedImage","set:MainControl4 image:tasklistnormal")
        
        self.m_pTeamBtn:setProperty("NormalImage","set:MainControl4 image:teambtn1Hnormal")
        self.m_pTeamBtn:setProperty("PushedImage","set:MainControl4 image:teambtn1Hpushed")
        self.tryRefreshTeamInfo()
	end
	return true;
end
function CTaskTracingDialog:HandleHideAllDialog(e)
	self.m_eFlyType= eFlyFadeOut
    self.m_felapsedTimeFadeout = 1/3
    return true;
end
function CTaskTracingDialog:HandleShowDialog(e)
	self.m_eFlyType= eFlyFadeIn;
    self.m_felapsedTimeFadein = 1/3
    self.m_pHideStateBack:setVisible(false)
    self.m_pHideBtn:setProperty("NormalImage","set:MainControl4 image:showbtnnormal")    
    return true;
end
function CTaskTracingDialog:HandleGotoCurDst(e)
	if self.m_bInWujue then
        local dlgWJLExitMap = WujuelingExitMapDlg.getInstanceNotCreate()
		if dlgWJLExitMap then
			dlgWJLExitMap:OnGoToClicked()
		end
	elseif self.m_bInFuben then
		if FubenGuideDialog.getInstanceNotCreate() then
			FubenGuideDialog.getInstanceNotCreate():HandleGotoLinkBtn()
		end
	else
		self:OnQuestBtnClickedIMP(GetTaskManager():GetMainScenarioQuestId())
    end
	return true;
end
function CTaskTracingDialog:OnQuestBtnClickedIMP(taskid)
	for i = 1, #self.m_mapCells do
		if self.m_mapCells[i].id == taskid then
			self.m_mapCells[i]:OnGoToClicked()
			break
		end
	end
end
function CTaskTracingDialog:HandleMoveDialog(e)
	local ptTopLeft= self.m_pDialog:GetScreenPos();
	local ptRightBottm = CEGUI.Vector2()
	ptRightBottm.x = ptTopLeft.x+self.m_pDialog:getPixelSize().width
	ptRightBottm.y = ptTopLeft.d_y+m_pDialog:getPixelSize().height
	local ScreenSize = CEGUI.System:getSingleton():getGUISheet():getPixelSize()
	local bChange = false
	if ptTopLeft.x > (ScreenSize.width-30) then
		ptTopLeft.x = ScreenSize.width-30
		bChange=true;
	end
	if ptTopLeft.y > (ScreenSize.height-30) then
		ptTopLeft.y = ScreenSize.height-30
		bChange = true
	end
	if ptTopLeft.y < 30 then
		ptTopLeft.y= 30
		bChange=true;
	end
	if ptTopLeft.x<0 then
		ptTopLeft.x=0;
		bChange=true;
	end
	if bChange then
		local newLeftTop = CEGUI.UVector2(
			CEGUI.UDim(1,ptTopLeft.x-ScreenSize.width),
			CEGUI.UDim(0, ptTopLeft.y))
		self.m_pDialog:setPosition(newLeftTop)
	end
	return true;
end
function CTaskTracingDialog:HandleWindowUpdate(e)
	local args = CEGUI.toUpdateEventArgs(e)
    local m_eFlyType = self.m_eFlyType
    if m_eFlyType == eFlyFadeOut then
        local width = self.m_pShowStateBack:getPixelSize().width
        if self.m_felapsedTimeFadeout > 0 then
            self.m_felapsedTimeFadeout = self.m_felapsedTimeFadeout - args.d_timeSinceLastFrame
            self.m_pShowStateBack:setXPosition(CEGUI.UDim(0,-width * (1/3-self.m_felapsedTimeFadeout)*3))
        else
            self.m_eFlyType = eFlyNull
            self.m_felapsedTimeFadeout = 0
            self.m_pShowStateBack:setPosition(self.m_ShowStateBackInitPos)
            self.m_pShowStateBack:setVisible(false)
            self.m_pHideStateBack:setVisible(true)
        end
    end
    if m_eFlyType == eFlyFadeIn then
        local width = self.m_pShowStateBack:getPixelSize().width
        
        self.m_felapsedTimeFadein = self.m_felapsedTimeFadein - args.d_timeSinceLastFrame
        LogInsane("tasktracing window width"..width..","..self.m_felapsedTimeFadein)
        if self.m_felapsedTimeFadein > 0 then
           -- CEGUI::UDim x_off = m_pHideBtn->getXPosition();
           local curPosX = -width*self.m_felapsedTimeFadein*3
           LogInsane("curPosX"..curPosX)
            self.m_pShowStateBack:setXPosition(CEGUI.UDim(0,curPosX))
            self.m_pShowStateBack:setVisible(true)
        else
            self.m_eFlyType = eFlyNull
            self.m_felapsedTimeFadein = 0
            -- self.m_ShowStateBackInitPos
            self.m_pShowStateBack:setPosition(self.m_ShowStateBackInitPos)
            self.m_pHideBtn:setProperty("NormalImage","set:MainControl4 image:hidebtnnormal")         
        end
    end
    if self.m_eTaskFlyType == eTaskFlyFadeOut then
        local height = self.m_pDialog:getPixelSize().height
        if self.m_fTaskElapsedTimeFadeout > 0 then
            self.m_fTaskElapsedTimeFadeout = self.m_fTaskElapsedTimeFadeout - args.d_timeSinceLastFrame;
            local init_offset = self.m_TaskBackInitPos.y.offset
            self.m_pTaskPane:setYPosition(
            	CEGUI.UDim(0,init_offset-height*(1/3-self.m_fTaskElapsedTimeFadeout)*3))
            self.m_pFubenBack:setYPosition(
            	CEGUI.UDim(0,init_offset-height*(1/3-self.m_fTaskElapsedTimeFadeout)*3))

           LogInsane(string.format("eTaskFlyFadeOut task back pos=(%f, %f)", 
    		self.m_TaskBackInitPos.x.offset,
    		self.m_TaskBackInitPos.y.offset))
        else
            self.m_eTaskFlyType = eTaskFlyNull
            self.m_fTaskElapsedTimeFadeout = 0
            self.m_pTaskPane:setPosition(self.m_TaskBackInitPos)
            self.m_pTaskPane:setVisible(false)
            self.m_pFubenBack:setPosition(self.m_TaskBackInitPos)
            self.m_pFubenBack:setVisible(false)
            LogInsane(string.format("eTaskFlyFadeOut task back pos=(%f, %f)", 
    			self.m_TaskBackInitPos.x.offset,
    			self.m_TaskBackInitPos.y.offset))
        end
    end
    if self.m_eTaskFlyType == eTaskFlyFadeIn then
        local height = self.m_pDialog:getPixelSize().height
        self.m_fTaskElapsedTimeFadein = self.m_fTaskElapsedTimeFadein - args.d_timeSinceLastFrame
        if self.m_fTaskElapsedTimeFadein > 0 then
        	local height = -height*self.m_fTaskElapsedTimeFadein*3
        	LogInsane("cur PosY="..height)
            self.m_pTaskPane:setYPosition(self.m_TaskBackInitPos.y +  
            	CEGUI.UDim(0,height))
            self.m_pFubenBack:setYPosition(self.m_TaskBackInitPos.y +  
            	CEGUI.UDim(0,height))
			if self.m_bInWujue or self.m_bInFuben then
				self.m_pFubenBack:setVisible(true)
			else
            	self.m_pTaskPane:setVisible(true)
            end
			LogInsane(string.format("eTaskFlyFadeIn task back pos=(%f, %f)", 
    		self.m_TaskBackInitPos.x.offset,
    		self.m_TaskBackInitPos.y.offset))
        else
            self.m_eTaskFlyType = eTaskFlyNull
            self.m_felapsedTimeFadein = 0
            LogInsane(string.format("Task init pos(%f, %f)", self.m_TaskBackInitPos.x.offset, self.m_TaskBackInitPos.y.offset))
            self.m_pTaskPane:setPosition(self.m_TaskBackInitPos)
            self.m_pFubenBack:setPosition(self.m_TaskBackInitPos)
            LogInsane(string.format("eTaskFlyFadeIn task back pos=(%f, %f)", 
    	self.m_TaskBackInitPos.x.offset,
    	self.m_TaskBackInitPos.y.offset))
        end
    end
    if self.m_eTeamFlyType == eTeamFlyFadeOut then
        local height = self.m_pDialog:getPixelSize().height
        if self.m_fTeamElapsedTimeFadeout > 0 then
            self.m_fTeamElapsedTimeFadeout = self.m_fTeamElapsedTimeFadeout - args.d_timeSinceLastFrame
            self.m_pTeamPane:setYPosition(self.m_TeamBackInitPos.y + 
            	CEGUI.UDim(0, -height*(1.0/3-self.m_fTeamElapsedTimeFadeout)*3));
        else
            self.m_eTeamFlyType = eTeamFlyNull
            self.m_fTeamElapsedTimeFadeout = 0
            self.m_pTeamPane:setPosition(self.m_TeamBackInitPos)
            self.m_pTeamPane:setVisible(false);
        end
    end
    
    if self.m_eTeamFlyType == eTeamFlyFadeIn then
        local height = self.m_pDialog:getPixelSize().height
        self.m_fTeamElapsedTimeFadein = self.m_fTeamElapsedTimeFadein - args.d_timeSinceLastFrame
        if self.m_fTeamElapsedTimeFadein > 0 then     
            self.m_pTeamPane:setYPosition(self.m_TeamBackInitPos.y + 
            	CEGUI.UDim(0,-height*self.m_fTeamElapsedTimeFadein*3));
        else
            self.m_eTeamFlyType = eTeamFlyNull
            self.m_fTeamElapsedTimeFadein = 0
            self.m_pTeamPane:setPosition(self.m_TeamBackInitPos)
        end
    end
    return true
end
function CTaskTracingDialog:HandleTeamPaneShown(e)
	self.tryRefreshTeamInfo()
	return true
end
function CTaskTracingDialog:HandleLeaveBtnClicked(e)
	GetTeamManager():RequestQuitTeam()
    self.m_pLeaveBtn:setVisible(false)
    self.m_pBackBtn:setVisible(false)
    return true
end
function CTaskTracingDialog:HandleBackBtnClicked(e)
	if GetTeamManager():IsMyselfLeader() and GetTeamManager():IsHaveAbsentMember() then
        GetTeamManager():RequestCallbackMember()
    elseif not GetTeamManager():IsMyselfLeader() and 
    	GetTeamManager():GetMemberSelf().eMemberState == eTeamMemberAbsent then
        GetTeamManager():RequestAbsentReturnTeam(false)
	elseif not GetTeamManager():IsMyselfLeader() and GetTeamManager():GetMemberSelf().eMemberState == eTeamMemberNormal then
		GetTeamManager():RequestAbsentReturnTeam(true)
    end
    
    self.m_pLeaveBtn:setVisible(false);
    self.m_pBackBtn:setVisible(false);
    return true;
end

function CTaskTracingDialog:setTeamHandleBtnStat(b)
	LogInsane("CTaskTracingDialog:setTeamHandleBtnStat "..b)
	self.m_bTeamHandleBtnVisible = b
end
function CTaskTracingDialog:getTeamHandleBtnStat()
	return self.m_bTeamHandleBtnVisible
end

function CTaskTracingDialog:setLeaveBtnVisible()
end

function CTaskTracingDialog:setBackBtnVisible()
	local m_pBackBtn = self.m_pBackBtn
	local m_bTeamHandleBtnVisible = self.m_bTeamHandleBtnVisible
    if m_bTeamHandleBtnVisible and
     GetTeamManager():IsMyselfLeader() and GetTeamManager():IsHaveAbsentMember() then
        m_pBackBtn:setVisible(m_bTeamHandleBtnVisible)
        m_pBackBtn:setText(MHSD_UTILS.get_resstring(2784))    
    elseif m_bTeamHandleBtnVisible and not GetTeamManager():IsMyselfLeader() 
    	and GetTeamManager():GetMemberSelf().eMemberState == eTeamMemberAbsent then
        m_pBackBtn:setVisible(m_bTeamHandleBtnVisible)
        m_pBackBtn:setText(MHSD_UTILS.get_resstring(2783))
    elseif m_bTeamHandleBtnVisible and (not GetTeamManager():IsMyselfLeader()) and GetTeamManager():GetMemberSelf().eMemberState == eTeamMemberNormal then 
		m_pBackBtn:setVisible(m_bTeamHandleBtnVisible)	
        m_pBackBtn:setText(MHSD_UTILS.get_resstring(2985))
	else
        m_pBackBtn:setVisible(false)
    end
end

function CTaskTracingDialog:setTeamHandleBtnStat(b)
	LogInsane("CTaskTracingDialog:setTeamHandleBtnStat")
	self.m_bTeamHandleBtnVisible = b
end
    
function CTaskTracingDialog:getTeamHandleBtnStat()
	return self.m_bTeamHandleBtnVisible
end

function CTaskTracingDialog.trySetVisibleFalse()
	if _instance == nil then 
		return
	end
	_instance:SetVisible(false)
end

function CTaskTracingDialog.trySetVisibleTrue()
	if _instance == nil then 
		return
	end
	_instance:SetVisible(true)
end

function CTaskTracingDialog:ClearTeamInfo()
	for i = 1, TableUtil.tablelength(self.m_vTeamMem) do
		local item = self.m_vTeamMem[i]
		self.m_pTeamPane:removeChildWindow(item.pWnd)
		CEGUI.WindowManager:getSingleton():destroyWindow(item.pWnd)
		self.m_vTeamMem[i] = nil
	end
end

function CTaskTracingDialog.tryRefreshTeamInfo()
	LogInsane("CTaskTracingDialog.tryRefreshTeamInfo")
	if _instance == nil or GetTeamManager() == nil then 
		return
	end
	local self = _instance
	self.m_bTeamBtnEnable = GetTeamManager():IsOnTeam()
  --  if self.m_pTeamPane:isVisible() then
    self:ClearTeamInfo()
    --没有队伍不显示
    if not GetTeamManager():IsOnTeam() then 
        self.m_pLeaveBtn:setVisible(false)
        self.m_pBackBtn:setVisible(false)
		if self.m_bInWujue or self.m_bInFuben then
			self.m_pFubenBack:setVisible(true)
		else
        	self.m_pTaskPane:setVisible(true)
		end
        self.m_pTaskBtn:setProperty("NormalImage","set:MainControl4 image:tasklistHnormal")
        self.m_pTaskBtn:setProperty("PushedImage","set:MainControl4 image:tasklistHnormal")
 
        self.m_pTeamBtn:setProperty("NormalImage","set:MainControl4 image:teambtn1normal")
        self.m_pTeamBtn:setProperty("PushedImage","set:MainControl4 image:teambtn1normal")
        return
    end 
    self:setBackBtnVisible()
    local list = GetTeamManager():GetMemberList()
    for i = 0, list:size() - 1 do
    	if i >= 5 then
    		break
    	end
		LogInsane("Load member"..i..",id="..list[i].id)
        local pTeamMem = TeamMemberUnit.new(list[i].id, list[i].HP, list[i].MaxHP, list[i].MP, list[i].MaxMP, list[i].level, list[i].strName, list[i].shapeID, list[i].eSchool)

        if list[i].eMemberState == eTeamMemberAbsent then
            pTeamMem.pMark:setProperty("Image", "set:MainControl5 image:zan")
        elseif list[i].eMemberState == eTeamMemberFallline then
            pTeamMem.pMark:setProperty("Image", "set:MainControl5 image:li")
        end

        if GetTeamManager():GetTeamLeader().id == list[i].id then
            pTeamMem.pMark:setProperty("Image", "set:MainControl5 image:dui")
        end
        self.m_pTeamPane:addChildWindow(pTeamMem.pWnd);
        local height = pTeamMem.pWnd:getPixelSize().height
        pTeamMem.pWnd:setYPosition(CEGUI.UDim(0, i*height + 1))
        table.insert(self.m_vTeamMem, pTeamMem)
    end
 --   end
end

function CTaskTracingDialog.tryShowTeamPane()
	LogInsane("CTaskTracingDialog.tryShowTeamPane")
	local dlg = require "ui.friendchatdialog".getInstanceNotCreate()
	if dlg and dlg.m_ChatRoleID then
		local list = GetTeamManager():GetMemberList()
	    for i = 0, list:size() - 1 do
	    	if i >= 5 then
	    		break
	    	end
			LogInsane("Load member"..i..",id="..list[i].id)
			if  list[i].id == dlg.m_ChatRoleID then
				dlg.m_TeamState=1
	        	dlg.m_AddFriendBtn:setText(MHSD_UTILS.get_resstring(2740))
				break
			end
		end
	end
	if _instance == nil then 
		return
	end
	local self = _instance
	local m_pTaskPane = self.m_pTaskPane
	local m_pTeamPane = self.m_pTeamPane
	m_pTaskPane:setVisible(false)
	self.m_pFubenBack:setVisible(false)
	if not m_pTeamPane:isVisible() then
		m_pTeamPane:setVisible(true)
        self.m_eTeamFlyType = eTeamFlyNull  
        local m_pTaskBtn = self.m_pTaskBtn
        m_pTaskBtn:setProperty("NormalImage","set:MainControl4 image:tasklistnormal")
        m_pTaskBtn:setProperty("PushedImage","set:MainControl4 image:tasklistnormal")
        local m_pTeamBtn = self.m_pTeamBtn
        m_pTeamBtn:setProperty("NormalImage","set:MainControl4 image:teambtn1Hnormal")
        m_pTeamBtn:setProperty("PushedImage","set:MainControl4 image:teambtn1Hpushed")
	end
    self.tryRefreshTeamInfo()
end

function CTaskTracingDialog:InitTaskList()
	if _instance == nil then
		LogInsane("Not a instance")
		self = CTaskTracingDialog.getSingletonDialog()
	end
	--上线时初始化任务追踪列表
	self:ResetCellPane()
	-- std.map<int,KGT.TrackedQuest>& tracequests
	local tracequestids = std.vector_int_()
	local tracequests = std.vector_knight__gsp__task__TrackedQuest_()
	GetTaskManager():GetTraceQuestListForLua(tracequestids, tracequests)
	for i = 0, tracequestids:size() - 1 do
		local taskid = tracequestids[i]
		local data = tracequests[i]
		local tracetime = data.acceptdate
		LogInsane("Add taskid"..taskid..","..tracetime)
		self:RefreshQuestItem(taskid,tracetime)	
	end
	if #self.m_mapCells == 0 then
		self:GetWindow():setVisible(false)
	elseif not GetBattleManager():IsInBattle() and GetTaskManager():GetIsTaskTraceDlgVisible() then
		self:SetVisible(true)
	end
end


function CTaskTracingDialog:RefreshQuestItem(taskid, tracetime)
	local pSpecialQuest = GetTaskManager():GetSpecialQuest(taskid)
	if pSpecialQuest then
		self:RefreshSpecialQuestItem(pSpecialQuest,taskid,tracetime)
		return
	end

	local activequest = GetTaskManager():GetReceiveQuest(taskid)
	if activequest then
		self:RefreshCommonQuestItem(activequest,taskid,tracetime)
		return
	end

	local pScenarioQuest = GetTaskManager():GetScenarioQuest(taskid)
	if pScenarioQuest then
		self:RefreshScenarioQuestItem(pScenarioQuest,taskid,tracetime)
		return
	end

    self:RemoveCellByID(taskid)
end

function CTaskTracingDialog:RemoveCellByID(questid)
	local find = false
	local length = TableUtil.tablelength(self.m_mapCells)
	local j = -1
	for i = 1, #self.m_mapCells do
		if self.m_mapCells[i].id == questid then
			j = i
			break
			
			--[[
			pos = cell.iPos
			self.m_mapCells[i] = nil
			find = true
			for index = i, length-1 do
				self.m_mapCells[index] = self.m_mapCells[index+1]
			end
			self.m_mapCells[length] = nil
			--]]
		end
	end
	if j ~= -1 then
		local cell = self.m_mapCells[j]
		self.m_pTaskPane:removeChildWindow(cell.pBtn)
		CEGUI.WindowManager:getSingleton():destroyWindow(self.m_mapCells[j].pBtn)
		table.remove(self.m_mapCells, j)
		for i = j, #self.m_mapCells do
			self.m_mapCells[i].iPos = self.m_mapCells[i].iPos - 1
			self.m_mapCells[i].pBtn:setXPosition(CEGUI.UDim(0,0))
		end
		self:RefreshCellYPosition()
	end
	
end

function CTaskTracingDialog.OnItemNumberChange(bagid, itemkey, itembaseid)
	local self = _instance
	if not self then
		return
	end
	if itembaseid == 50002 or itembaseid == 50015 then
		for i = 1, #self.m_mapCells do
			if self.m_mapCells[i].id == knight.gsp.specialquest.SpecialQuestID.qihuaquestid then
				local taskid = self.m_mapCells[i].id
				local config
				local ciqinum = GetRoleItemManager():GetItemNumByBaseID(50002)
				if ciqinum > 0 then
					config = knight.gsp.specialquest.GetCSpecialQuestConfigTableInstance():getRecorder(taskid + 1)
				end
				ciqinum = GetRoleItemManager():GetItemNumByBaseID(50015)
				if ciqinum > 5 then
					config = knight.gsp.specialquest.GetCSpecialQuestConfigTableInstance():getRecorder(taskid + 1)
				end
				if not config then
					config = knight.gsp.specialquest.GetCSpecialQuestConfigTableInstance():getRecorder(taskid)
				end
				
				local quest = GetTaskManager():GetReceiveQuest(self.m_mapCells[i].id)
				
				self:AddActivityQuestAim(self.m_mapCells[i], quest, config)
				break
			end
		end
	end
end	

local function getActvitiQuestAimConfig(taskid)
	-- itembaseid == 50002 or itembaseid == 50015
	if taskid == knight.gsp.specialquest.SpecialQuestID.qihuaquestid then
		local ciqinum = GetRoleItemManager():GetItemNumByBaseID(50002)
		if ciqinum > 0 then
			return knight.gsp.specialquest.GetCSpecialQuestConfigTableInstance():getRecorder(taskid + 1)
		end
		ciqinum = GetRoleItemManager():GetItemNumByBaseID(50015)
		if ciqinum > 5 then
			return knight.gsp.specialquest.GetCSpecialQuestConfigTableInstance():getRecorder(taskid + 1)
		end
	end
	return knight.gsp.specialquest.GetCSpecialQuestConfigTableInstance():getRecorder(taskid)
end

function CTaskTracingDialog:RefreshCommonQuestItem(quest,taskid,tracetime)
	LogInsane("CTaskTracingDialog:RefreshCommonQuestItem"..taskid)
	local questdata = nil
	for i = 1, #self.m_mapCells do
		if self.m_mapCells[i].id == taskid then
			questdata = self.m_mapCells[i]
			break
		end
	end
	if quest and questdata == nil then --添加新任务节点
		self:AddQuestItem(quest,tracetime)
	elseif quest and questdata then--刷新任务
		if quest.queststatus == knight.gsp.specialquest.SpecialQuestState.FAIL then
			self:ShowFailQuestInfo(questdata)
		else
			local shimen = getActvitiQuestAimConfig(taskid)		
			self:AddActivityQuestAim(questdata, quest, shimen)
		end
		self.m_pTaskPane:invalidate()
	end
end

function CTaskTracingDialog:AddQuestItem(quest,tracetime)
	local shimen = knight.gsp.specialquest.GetCSpecialQuestConfigTableInstance():getRecorder(quest.questid)
	if shimen.id == -1 then
		return
	end
	local newUnit = self:GetTaskTrackCell(quest.questid)
	newUnit.pTitle:setText(shimen.tracname)
	newUnit.pTitle:setProperty("TextColours", "FFFFFF33")
--	self:AddCellToPane(quest.questid, newUnit)
	if quest.queststate == knight.gsp.specialquest.SpecialQuestState.FAIL then
		self:ShowFailQuestInfo(newUnit, quest)
	else
		self:AddActivityQuestAim(newUnit, quest, shimen)
	end
end

function CTaskTracingDialog:AddActivityQuestAim(unit, pQuest, questconfig)
	if pQuest == nil or questconfig.id == -1 then
		return false
	end
	local sb = StringBuilder.new()
	local npcConfig = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(pQuest.dstnpcid)
	local mapconfig
	LogInsane("pQuest dstmapid="..pQuest.dstmapid..", npcConfig.id"..npcConfig.id..", pQuest.dstnpcid="..pQuest.dstnpcid)
	if pQuest.dstmapid == 0 and npcConfig.id ~= -1 then
		LogInsane("mapid="..npcConfig.mapid)
		mapconfig = knight.gsp.map.GetCMapConfigTableInstance():getRecorder(npcConfig.mapid)
		sb:SetNum("xPos", npcConfig.xPos)
		sb:SetNum("yPos", npcConfig.yPos)
		sb:SetNum("mapid", npcConfig.mapid)
	elseif pQuest.dstmapid > 0 then
		LogInsane("mapid="..pQuest.dstmapid)
		mapconfig = knight.gsp.map.GetCMapConfigTableInstance():getRecorder(pQuest.dstmapid)
		sb:SetNum("xPos", pQuest.dstx)
		sb:SetNum("yPos", pQuest.dsty)
		sb:SetNum("mapid", pQuest.dstmapid)
	else
		sb:SetNum("xPos",0)
		sb:SetNum("yPos", 0)
		sb:SetNum("mapid", 0)
	end
	
	sb:Set("MapName", mapconfig and mapconfig.mapName or "")
	sb:SetNum("mapid", pQuest.dstmapid)
	sb:SetNum("xjPos",  mapconfig and mapconfig.xjPos or 0)
	sb:SetNum("yjPos",  mapconfig and mapconfig.yjPos or 0)
	sb:SetNum("npcid", pQuest.dstnpcid)
	
	sb:SetNum("Number", pQuest.sumnum)
	sb:SetNum("Number1", pQuest.dstitemid)
	sb:SetNum("Number2", pQuest.sumnum)
	sb:SetNum("NpcKey", pQuest.dstnpckey)
	sb:SetNum("DstX", pQuest.dstx)
	sb:SetNum("DstY", pQuest.dsty)
	sb:SetNum("Number3", pQuest.rewardsmoney)
	
	if string.len(pQuest.npcname) == 0 then
		local npcInAll = knight.gsp.npc.GetCNpcInAllTableInstance():getRecorder(pQuest.dstnpcid)
		sb:Set("NPCName", npcInAll.name)
	else
		sb:Set("NPCName", pQuest.npcname)
	end
	
	if not string.find(questconfig.tracname, "%$Number", 0) then
		unit.pTitle:setText(sb:GetString(questconfig.tracname))
	end
	unit.pContent:Clear()
	unit.pContent:AppendParseText(CEGUI.String(sb:GetString(questconfig.tracdiscribe)))
	unit.bFail = false
	unit.pContent:Refresh()
	unit:ResetHeight()
	self:RefreshCellYPosition()
	return true
end

function CTaskTracingDialog:RefreshScenarioQuestItem(quest,taskid,tracetime)
	LogInsane(string.format("RefreshScenarioQuestItem(%d, %d)", taskid, tracetime))
	local questdata = nil
	for i = 1, #self.m_mapCells do
		if self.m_mapCells[i].id == taskid then
			questdata = self.m_mapCells[i]
			break
		end
	end

	if quest and questdata == nil then --添加新任务节点
		self:AddScenarioQuestItem(quest,tracetime)
	elseif quest and questdata then--刷新任务
		if quest.queststatus == knight.gsp.specialquest.SpecialQuestState.FAIL then
			self:ShowFailQuestInfo(questdata)
		else
			local questinfo = knight.gsp.task.GetCMainMissionInfoTableInstance():getRecorder(taskid)
			self:AddScenarioQuestAim(questdata, questinfo)
		end
		self.m_pTaskPane:invalidate();
	end
end

function CTaskTracingDialog:AddScenarioQuestItem(quest, tracetime)
	local questinfo = knight.gsp.task.GetCMainMissionInfoTableInstance():getRecorder(quest.questid)
	if questinfo.id == -1 or CEGUI.String(questinfo.TaskInfoTraceListA):empty() then
		return
	end
	local name = questinfo.MissionName
	if string.match(name,"round",0) then
		local sb = StringBuilder.new()
		sb:SetNum("round", quest.round)
		name = sb:GetString(name)
	end
    local newUnit = self:GetTaskTrackCell(quest.questid)
    
	string.gsub(name,"%[", "\\[",1)
	if GetTaskManager():IsMasterStrokeQuest(quest.questid) then
        newUnit.pTitle:setText(name)
        newUnit.pTitle:setProperty("TextColours", "FFFF33FF")
	else
        newUnit.pTitle:setText(name)
        newUnit.pTitle:setProperty("TextColours", "FFFFFF33")
	end
 --   self:AddCellToPane(quest.questid, newUnit)
	self:AddScenarioQuestAim(newUnit, questinfo)
end

function CTaskTracingDialog:AddScenarioQuestAim(unit, questinfo)
    if string.match(questinfo.TaskInfoTraceListA, "%$", 0) then
		local quest = GetTaskManager():GetScenarioQuest(questinfo.id);
		if quest then
			local sb = StringBuilder.new()
			sb:SetNum("number", quest.questvalue);
	        unit.pContent:Clear();
	        local info = sb:GetString(questinfo.TaskInfoTraceListA)
	        LogInsane("new questinfo="..info)
			unit.pContent:AppendParseText(CEGUI.String(info))
	    	unit.pContent:Refresh()
	    	unit:ResetHeight()
	    	unit.bFail = false
	    	self:RefreshCellYPosition()
		end
	else
	    unit.pContent:Clear()
		unit.pContent:AppendParseText(CEGUI.String(questinfo.TaskInfoTraceListA))
	    unit.pContent:Refresh()
	    unit:ResetHeight()
	    unit.bFail = false
	    self:RefreshCellYPosition(unit)
    end
	return true;
end

function CTaskTracingDialog:RefreshSpecialQuestItem(quest, taskid, tracetime)
	LogInsane(string.format("RefreshSpecialQuestItem(%d, %d)", taskid, tracetime))
	local questdata = nil
	for i = 1, #self.m_mapCells do
		if self.m_mapCells[i].id == taskid then
			questdata = self.m_mapCells[i]
			break
		end
	end
	if quest and questdata == nil then --添加新任务节点
		self:AddSpecialQuestItem(quest,tracetime)	
	elseif quest and questdata then --刷新任务
		local shimen = knight.gsp.specialquest.GetCSpecialQuestConfigTableInstance():getRecorder(quest.questtype)
		questdata.pTitle:setText(shimen.tracname)
		if quest.queststate == knight.gsp.specialquest.SpecialQuestState.FAIL then
			self:ShowFailQuestInfo(questdata)
		else
			self:AddSpecialQuestAim(questdata,quest)
		end
		self.m_pTaskPane:invalidate()
	end
end

function CTaskTracingDialog:AddSpecialQuestItem(quest, tracetime)
	local shimen = knight.gsp.specialquest.GetCSpecialQuestConfigTableInstance():getRecorder(quest.questtype)
	if CEGUI.String(shimen.tracname):empty() then
		LogInfo(MHSD_UTILS.get_resstring(2300)..quest.questid)
	else
		LogInsane("Add questid="..quest.questid.." cell")
        local newUnit = self:GetTaskTrackCell(quest.questid)
        newUnit.pTitle:setProperty("TextColours", "FFFFFF33")
   --     self:AddCellToPane(quest.questid, newUnit)
		if quest.queststate == knight.gsp.specialquest.SpecialQuestState.FAIL then
			self:ShowFailQuestInfo(newUnit)
		else
			self:AddSpecialQuestAim(newUnit,quest)
		end
	end
end

local function getTaskIndex(taskid)
	local tt = BeanConfigManager.getInstance():GetTableByName("knight.gsp.task.ctasktrackingorder")
	local ids = tt:getAllID()
	for k, v in pairs(ids) do
		local v = tt:getRecorder(k)
		if taskid >= v.mintaskid and taskid <= v.maxtaskid then
			return v.priority
		end
	end
	return 9999999
	--[[
	if taskid >= 200000 and taskid <= 299999 then
		return 5
	elseif taskid >= 100000 and taskid <= 199999 then
		return 1
	
	elseif taskid >= 300000 and taskid <= 399999 then
		return 2
	elseif taskid >= 801000 and taskid <= 801999 then
		return 3
	elseif taskid == 701001 or taskid == 701002 then
		return 4
	elseif taskid == knight.gsp.specialquest.SpecialQuestID.qihuaquestid then
		return 5
	elseif taskid >= 200000 and taskid <= 299999 then
		return 6
	else
		return 7
	end
	--]]
end

function CTaskTracingDialog:GetTaskTrackCell(taskid)
	for i = 1, #self.m_mapCells do
		if self.m_mapCells[i].id == taskid then
			return self.m_mapCells[i]
		end
	end
	local newUnit = require "ui.task.tasktrackcell".new(taskid)
	self:AddCellToPane(taskid, newUnit)
	return newUnit
end

function CTaskTracingDialog:AddCellToPane(taskid, newUnit)
	LogInsane("CTaskTracingDialog:AddCellToPane")
    local HEIGHT = 1
    
    if GetTaskManager():IsMainScenarioQuest(taskid) then  --主线置顶
    	table.insert(self.m_mapCells, 1, newUnit)
    	--[[
        newUnit.iPos = 0
        for i = 1,  #self.m_mapCells do
        	self.m_mapCells[i].iPos = self.m_mapCells[i].iPos + 1
        end
        --]]
    else
    	local curIdx = getTaskIndex(taskid)
    	local pos = #self.m_mapCells + 1
    	for i = 1, #self.m_mapCells do
    		local tIdx = getTaskIndex(self.m_mapCells[i].id)
    		if tIdx >= curIdx then
    			pos = i
    			break
    		end
    	end
    	table.insert(self.m_mapCells, pos, newUnit)
    end
    
    self.m_pTaskPane:addChildWindow(newUnit.pBtn)

    newUnit.pBtn:setXPosition(CEGUI.UDim(0, 0))   

    local height=newUnit.pBtn:getPixelSize().height
    newUnit.pBtn:setYPosition(CEGUI.UDim(0,newUnit.iPos*height+HEIGHT))
    self:RefreshCellYPosition()
--    self.m_pTaskPane:getVertScrollbar():setScrollPosition(-ypos.offset)
end

function CTaskTracingDialog:RefreshCellYPosition()
	LogInsane("CTaskTracingDialog:RefreshCellYPosition")
    local HEIGHT = 1
    local height = 0
    for i = 1, #self.m_mapCells do
    --[[
    	local cell = nil
    	for j = 1, #self.m_mapCells do
    		if self.m_mapCells[j].iPos == i - 1 then
    			cell = self.m_mapCells[j]
    			break
    		end
    	end
    	--]]
    	local cell = self.m_mapCells[i]
    	if cell then
    		LogInsane("height="..height..", i="..i)
	    	cell.pBtn:setPosition(CEGUI.UVector2(CEGUI.UDim(0,0), CEGUI.UDim(0, height)))
        	height = height + math.ceil(cell.pBtn:getPixelSize().height + HEIGHT)
	    else
	    	LogInsane("not pos ="..(i-1).."item")
    	end
    end
    --[[
    if curCell then
    	local ypos = curCell.pBtn:getYPosition().offset
    	LogInsane("set task tracing pos.."..ypos)
    	self.m_pTaskPane:getVertScrollbar():setScrollPosition(ypos)
    else
    	self.m_pTaskPane:getVertScrollbar():setScrollPosition(0)
    end
    --]]
end

function CTaskTracingDialog:ShowFailQuestInfo(unit, pQuest)
	if pQuest then
		local sb = StringBuilder.new()
		sb:SetNum("Number",pQuest.sumnum)
		sb:SetNum("Number1",pQuest.dstitemid)
		sb:SetNum("Number2",pQuest.sumnum)
		sb:SetNum("Number3",pQuest.rewardsmoney) -- 侠侣任务追踪显示轮数
		local questconfig = knight.gsp.specialquest.GetCSpecialQuestConfigTableInstance():getRecorder(pQuest.questid)
		if questconfig.id == -1 or CEGUI.String(questconfig.tracname):empty() then
			return
		end
		if string.match(questconfig.tracname, "$Number", 0) then
			unit.pTitle:setText(sb:GetString(questconfig.tracname))
		end
	end
	local failconfig = knight.gsp.specialquest.GetCSpecialQuestConfigTableInstance():getRecorder(1000)
	if failconfig.id == -1 or CEGUI.String(failconfig.tracname):empty() then
		return
	end
    
    unit.pContent:Clear()
    unit.pContent:AppendParseText(CEGUI.String(failconfig.tracdiscribe))
    unit.pContent:Refresh()
    unit.bFail = true
    unit:ResetHeight()
    self:RefreshCellYPosition()
end

function CTaskTracingDialog:AddSpecialQuestAim(unit, pQuest)
	if pQuest == nil then
		return false
	end
	local sb = StringBuilder.new()
	if pQuest.questid == knight.gsp.specialquest.SpecialQuestID.schoolquestid then
		sb:SetNum("Number", pQuest.sumnum)
	elseif pQuest.questid == knight.gsp.specialquest.SpecialQuestID.factiondailyquestid then
		sb:SetNum("Number", pQuest.sumnum)
		sb:SetNum("round", pQuest.round)
	else
		sb:SetNum("Number", pQuest.round)
	end
	
	local temptype = pQuest.questtype
	LogInsane("CTaskTracingDialog:AddSpecialQuestAim pQuest.questid = "..pQuest.questid..", temptype="..temptype)
	if pQuest.questid == knight.gsp.specialquest.SpecialQuestID.schoolquestid and 
		pQuest.queststate == knight.gsp.specialquest.SpecialQuestState.DONE then --完成任务后，任务目的需要更换
		temptype = temptype + 20
		local npcConfig = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(pQuest.dstnpcid)
		sb:Set("NPCName",npcConfig.name)
		sb:SetNum("npcid",pQuest.dstnpcid)
		if pQuest.questtype == knight.gsp.specialquest.SpecialQuestType.BuyItem then -- 买道具
			local itemattr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(pQuest.dstitemid)
			sb:Set("ItemName", itemattr.name)
			if itemattr.blinkopenwordbook == 1 or itemattr.blinkopenwordbook == 2 then
				sb:SetNum("npcid2", itemattr.linkusemethod)
				sb:SetNum("mapid3", 1)
			else
				sb:SetNum( "npcid2",itemattr.npcid2)
				sb:SetNum( "mapid3",0)
			end
		end	
	elseif pQuest.questid == knight.gsp.specialquest.SpecialQuestID.factiondailyquestid and 
		pQuest.queststate == knight.gsp.specialquest.SpecialQuestState.DONE then
		temptype = temptype + 10
		if temptype == 806012 then
			local petattr = knight.gsp.pet.GetCPetAttrTableInstance():getRecorder(pQuest.dstitemid)
			sb:Set("PetName",petattr.name)

			local mapcongig = knight.gsp.map.GetCMapConfigTableInstance():getRecorder(pQuest.dstmapid)
			sb:SetNum("xjPos",mapcongig.xjPos)
			sb:SetNum("yjPos",mapcongig.yjPos)
			sb:SetNum("mapid",pQuest.dstmapid)
		elseif temptype == 806013 then
			local itemattr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(pQuest.dstitemid)
			sb:Set("ItemName", itemattr.name)
			if itemattr.blinkopenwordbook == 1 or itemattr.blinkopenwordbook == 2 then
				sb:SetNum("npcid2", itemattr.linkusemethod)
				sb:SetNum("mapid3", 1)
			else
				sb:SetNum( "npcid2",itemattr.npcid2)
				sb:SetNum( "mapid3",0)
			end
		end
		local npcConfig = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(pQuest.dstnpcid)
		sb:Set("NPCName", npcConfig.name)
		sb:SetFormat("npcid", pQuest.dstnpcid)
	else
		if temptype == knight.gsp.specialquest.SpecialQuestType.Mail then -- 送信
			local npcConfig = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(pQuest.dstnpcid)
			sb:Set("NPCName",npcConfig.name)
			local mapcongig = knight.gsp.map.GetCMapConfigTableInstance():getRecorder(npcConfig.mapid)
			sb:Set("MapName",mapcongig.mapName)
			sb:SetNum("xjPos",mapcongig.xjPos)
			sb:SetNum("yjPos",mapcongig.yjPos)
			sb:SetNum("mapid",npcConfig.mapid)
			sb:SetNum("xPos",npcConfig.xPos)
			sb:SetNum("yPos",npcConfig.yPos)
			sb:SetNum("npcid",pQuest.dstnpcid)
		elseif temptype == knight.gsp.specialquest.SpecialQuestType.Patrol then -- 巡逻
			sb:SetNum("Number2",pQuest.dstitemid)
		elseif temptype == knight.gsp.specialquest.SpecialQuestType.Rescue-- 援救
		or temptype == knight.gsp.specialquest.SpecialQuestType.Tame-- 降服
		or temptype == knight.gsp.specialquest.SpecialQuestType.ChuanDiXiaoXi then --传递消息
			local mapcongig = knight.gsp.map.GetCMapConfigTableInstance():getRecorder(pQuest.dstmapid)
			sb:Set("MapName",mapcongig.mapName)
			sb:SetNum("xjPos",mapcongig.xjPos)
			sb:SetNum("yjPos",mapcongig.yjPos)
			sb:SetNum("mapid",pQuest.dstmapid)
			sb:SetNum("xPos",pQuest.dstx)
			sb:SetNum("yPos",pQuest.dsty)
		elseif temptype == knight.gsp.specialquest.SpecialQuestType.QingLiMenPai then --师门-清理门派
			local mapcongig = knight.gsp.map.GetCMapConfigTableInstance():getRecorder(pQuest.dstmapid)
			sb:Set("MapName",mapcongig.mapName)
			sb:SetNum("mapid",pQuest.dstmapid)
			sb:SetNum("xPos",pQuest.dstx)
			sb:SetNum("yPos",pQuest.dsty)
			sb:SetNum("npcid",pQuest.dstnpcid)
            sb:SetNum("npckey",pQuest.dstnpckey)
		elseif temptype == knight.gsp.specialquest.SpecialQuestType.BuyItem then --//师门-买道具
			sb:SetNum("npcid",pQuest.dstnpcid)
			local npcConfig1 = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(pQuest.dstnpcid)
			sb:Set("NPCName",npcConfig1.name)
			local itemattr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(pQuest.dstitemid)
			sb:Set("ItemName", itemattr.name)
			if itemattr.blinkopenwordbook == 1 or itemattr.blinkopenwordbook == 2 then
				sb:SetNum("npcid2", itemattr.linkusemethod)
				sb:SetNum("mapid3", 1)
			else
				sb:SetNum( "npcid2",itemattr.npcid2)
				sb:SetNum( "mapid3",0)
			end
		elseif temptype == knight.gsp.specialquest.SpecialQuestType.CaiJi then -- 师门-采集
			local npcConfig = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(pQuest.dstitemid)
			sb:Set( "ItemName",npcConfig.name)
			sb:SetNum("Number2",pQuest.dstitemnum)
			sb:SetNum("Number3",pQuest.dstitemidnum2)
			sb:SetNum("mapid",pQuest.dstmapid)	
			sb:SetNum("xPos",pQuest.dstx)
			sb:SetNum("yPos",pQuest.dsty)
        elseif temptype == knight.gsp.specialquest.SpecialQuestType.KillMonster then--打怪任务
            local monster = knight.gsp.npc.GetCMonsterConfigTableInstance():getRecorder(pQuest.dstnpcid)
            sb:Set("PetName",monster.name)
            local mapcongig = knight.gsp.map.GetCMapConfigTableInstance():getRecorder(pQuest.dstmapid)
            sb:Set("MapName",mapcongig.mapName)
            sb:SetNum("Number2",pQuest.dstitemid)
            sb:SetNum("mapid",pQuest.dstmapid)
            local mapRecord = knight.gsp.map.GetCWorldMapConfigTableInstance():getRecorder(pQuest.dstmapid)
            if mapRecord.id ~= -1 then
				math.randomseed(os.time())
                local randX=mapRecord.bottomx-mapRecord.topx
                randX = mapRecord.bottomx+math.random(randX)-1 
                local randY=mapRecord.bottomy-mapRecord.topy
                randY=mapRecord.bottomy+math.random(randY)-1
                sb:SetNum("xPos",randX)
                sb:SetNum("yPos",randY)
            end
        elseif temptype == knight.gsp.specialquest.SpecialQuestType.FindItem then  --打怪掉落物品任务
            local mapcongig = knight.gsp.map.GetCMapConfigTableInstance():getRecorder(pQuest.dstmapid)
            sb:Set("MapName",mapcongig.mapName)
            sb:Set("petname",mapcongig.mapName)
            local itemattr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(pQuest.dstitemid)
            sb:Set("ItemName", itemattr.name)
            sb:SetNum("Number2", pQuest.dstitemnum)
            sb:SetNum("mapid",pQuest.dstmapid)
            local mapRecord=knight.gsp.map.GetCWorldMapConfigTableInstance():getRecorder(pQuest.dstmapid)
            if mapRecord.id ~= -1 then
				math.randomseed(os.time())
                local randX=mapRecord.bottomx-mapRecord.topx
                randX = mapRecord.bottomx+math.random(randX)-1 
                local randY=mapRecord.bottomy-mapRecord.topy
                randY=mapRecord.bottomy+math.random(randY)-1
                sb:SetNum("xPos",randX)
                sb:SetNum("yPos",randY)
            end
        elseif temptype == knight.gsp.specialquest.SpecialQuestType.Answer then  --师门答题
            local npc = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(pQuest.dstnpcid)
            sb:Set("NPCName",npc.name)
            sb:SetNum("npcid", pQuest.dstnpcid)
            sb:SetNum("mapid",pQuest.dstmapid)
            sb:SetNum("xPos",pQuest.dstx)
            sb:SetNum("yPos",pQuest.dsty)
		elseif temptype == knight.gsp.specialquest.SpecialQuestType.ZhenShou then
			local mapcongig = knight.gsp.map.GetCMapConfigTableInstance():getRecorder(pQuest.dstmapid)
			sb:Set("MapName",mapcongig.mapName)
			-- sb:SetNum("xjPos",mapcongig.xjPos)
			-- sb:SetNum("yjPos",mapcongig.yjPos)
			sb:SetNum("mapid",pQuest.dstmapid)
			sb:SetNum("xPos",pQuest.dstx)
			sb:SetNum("yPos",pQuest.dsty)
			sb:Set("NPCName",pQuest.dstnpcname)
			
        elseif temptype == knight.gsp.specialquest.SpecialQuestType.TZFindNpc --行侠仗义 送信
			or temptype == knight.gsp.specialquest.SpecialQuestType.TZFight --行侠仗义 战斗
			or temptype == 802009 --行侠仗义 答题
			then

			if temptype == knight.gsp.specialquest.SpecialQuestType.TZFight 
				and pQuest.round == 30 then --行侠仗义第30环任务
				temptype = temptype + 10
			end 

			local npc = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(pQuest.dstnpcid)
			sb:Set("NPCName", npc.name)
            sb:SetNum("npcid", pQuest.dstnpcid)

        elseif temptype == knight.gsp.specialquest.SpecialQuestType.TZBuyItem then --行侠仗义 寻物
        	if pQuest.queststate == knight.gsp.specialquest.SpecialQuestState.DONE then 
				temptype = temptype + 10			
				local itemattr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(pQuest.dstitemid)
				sb:Set("ItemName", itemattr.name)
				local npcConfig = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(pQuest.dstnpcid)
				sb:Set("NPCName",npcConfig.name)
				sb:SetNum("npcid",pQuest.dstnpcid)
			else
				--find map according to level
				local level = GetDataManager():GetMainCharacterLevel();
				local id = 0;
			    if level < 100 then
			    	id = level - level % 5; 
			    elseif level < 120 then
			    	id = level - level % 2;
			    else
			    	id = 120;
			    end
				local maps = BeanConfigManager.getInstance():
							GetTableByName("knight.gsp.specialquest.ctianzunchuanshuo"):getRecorder(id);	
				local mapid1 = maps.mapids[0]
				local itemattr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(pQuest.dstitemid)
				sb:Set("ItemName", itemattr.name)
				sb:SetNum("mapid2", mapid1)
				sb:SetNum("Number1", pQuest.dstitemnum)
            end
        elseif temptype == 802007 then --行侠仗义 巡逻
        	if pQuest.queststate == knight.gsp.specialquest.SpecialQuestState.DONE then
				temptype = temptype + 10
				local npcConfig = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(pQuest.dstnpcid)
				sb:Set("NPCName",npcConfig.name)
				sb:SetNum("npcid",pQuest.dstnpcid)
			else
				sb:Set("Number2", pQuest.dstitemid)
        	end
        elseif temptype == 802008 then --行侠仗义 传递消息
        	if pQuest.queststate == knight.gsp.specialquest.SpecialQuestState.DONE then
        		temptype = temptype + 10
        		local npcConfig = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(pQuest.dstnpcid)
        		sb:Set("NPCName", npcConfig.name)
				sb:SetNum("npcid", pQuest.dstnpcid)
        	else
        		local mapcongig = knight.gsp.map.GetCMapConfigTableInstance():getRecorder(pQuest.dstmapid)
        		sb:Set("MapName", mapcongig.mapName)
				sb:SetNum("mapid", pQuest.dstmapid)
				sb:SetNum("xPos", pQuest.dstx)
				sb:SetNum("yPos", pQuest.dsty)
			end

        elseif temptype == knight.gsp.specialquest.SpecialQuestType.TZWaBao then
			sb:SetNum("Number1", pQuest.dstitemnum)
			local npc = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(pQuest.dstnpcid)
			sb:Set("NPCName", npc.name)
            sb:SetNum("npcid", pQuest.dstnpcid)
		end
	end
	local shimen = knight.gsp.specialquest.GetCSpecialQuestConfigTableInstance():getRecorder(temptype)
	if shimen.id == -1 then
		return false
	end
	if string.match(shimen.tracname, "%$Number%$", 0) then
		if pQuest.questid == knight.gsp.specialquest.SpecialQuestID.schoolquestid then
            local maxtime = 0
            local ids = std.vector_int_()
            knight.gsp.specialquest.GetCchoolQuestMaxTableInstance():getAllID(ids)
            local level = GetMainCharacter():GetLevel()
            for i = 0, ids:size() - 1 do
                local record = knight.gsp.specialquest.GetCchoolQuestMaxTableInstance():getRecorder(ids[i])
                if record.levelmax >= level and record.levelmin <= level then
                    maxtime = record.max
                    break
                end
            end
            sb:SetNum("Number1", maxtime)
		end
		unit.pTitle:setText(sb:GetString(shimen.tracname))
	end
    unit.pContent:Clear()
    LogInsane("shimen.tracdiscribe="..shimen.tracdiscribe)
    local showstr = sb:GetString(shimen.tracdiscribe)
    LogInsane("after="..showstr)
	unit.pContent:AppendParseText(CEGUI.String(showstr))
    unit.pContent:Refresh()
    unit.bFail = false
    unit:ResetHeight()
    self:RefreshCellYPosition()
	return true
end


function CTaskTracingDialog:ResetCellPane()
	self.m_pTaskPane:cleanupNonAutoChildren()
	for i = 1, #self.m_mapCells do
		self.m_mapCells[i] = nil
	end
	self.m_mapCells = {}
	--[[
    MAP_TRACE.iterator unitIter = m_mapCells.begin()
    for(  unitIter ~= m_mapCells.end() unitIter++)
    {
        delete unitIter->second
    }
    m_mapCells.clear()
    --]]
end

function CTaskTracingDialog.GetLayoutFileName()
	return "TaskTracingDialog.layout"
end

function CTaskTracingDialog.DestroyDialog()
	if _instance == nil then
		return
	end
	local wujueInstance = WujuelingExitMapDlg.getInstanceNotCreate()
	if _instance.m_bInWujue and wujueInstance then
		_instance.m_bInWujue = nil
		local pWnd = wujueInstance:GetWindow()
		_instance.m_pFubenBack:removeChildWindow(pWnd)
		CEGUI.System:getSingleton():getGUISheet():addChildWindow(pWnd)
		WujuelingExitMapDlg.DestroyDialog()
	--	pWnd:OnExit()
	end

	local fubenInstance = FubenGuideDialog:getInstanceNotCreate() 
	if _instance.m_bInFuben and fubenInstance then
		_instance.m_bInFuben = nil
		local pWnd = fubenInstance:GetWindow()
		_instance.m_pFubenBack:removeChildWindow(pWnd)
		CEGUI.System:getSingleton():getGUISheet():addChildWindow(pWnd)
		FubenGuideDialog.DestroyDialog()
	end

	local s = #_instance.m_vTeamMem
	for i = 1, s do
		table.remove(_instance.m_vTeamMem, i)
	end
	GetTaskManager().EventUpdateLastQuest:RemoveScriptFunctor(_instance.m_hUpdateLastQuest)
	GetRoleItemManager():RemoveLuaItemNumChangeNotify(_instance.m_hItemNumChangeNotify)
	_instance.StateNotify = nil
	_instance:OnClose()
	_instance = nil
end

function CTaskTracingDialog.enterWujue()
	LogInfo("ctasktracing dialog enter wujue")
	local wujueInstance = WujuelingExitMapDlg.getInstanceNotCreate()
	if not _instance or not wujueInstance then
		return
	end
	local curMapid = GetScene():GetMapInfo().id
	if curMapid == 1401 then
		WujuelingExitMapDlg.DestroyDialog()
		return
	end
    
	local pWnd = wujueInstance:GetWindow()
	if pWnd then
        print("____tasktracing:addChildWindow")
		_instance.m_pFubenBack:addChildWindow(pWnd)
		pWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 0), CEGUI.UDim(0, 1)))
		_instance.m_bInWujue = true
		_instance.m_pTaskPane:setVisible(false)
		if not _instance.m_pTeamPane:isVisible() then
			_instance.m_pFubenBack:setVisible(true)
		end
	end
end

function CTaskTracingDialog.enterFuben()
	LogInfo("ctasktracing dialog enter fuben")
	local fubenInstance = FubenGuideDialog.getInstanceNotCreate()
	if not _instance or not fubenInstance then
		return
	end
	local curMapid = GetScene():GetMapInfo().id
	if curMapid == 1401 then
		FubenGuideDialog:OnExit()
		return
	end
	local pWnd = FubenGuideDialog.getInstanceNotCreate():GetWindow() 
	if pWnd then
		_instance.m_pFubenBack:addChildWindow(pWnd)
		pWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 0), CEGUI.UDim(0, 1)))
		_instance.m_bInFuben = true
		_instance.m_pTaskPane:setVisible(false)
		if not _instance.m_pTeamPane:isVisible() then
			_instance.m_pFubenBack:setVisible(true)
		end
	end
end

function CTaskTracingDialog.exitWujue()
	LogInfo("ctasktracing dialog exit wujue")
	local wujueInstance = WujuelingExitMapDlg.getInstanceNotCreate()
	if not _instance or (not wujueInstance) or (not _instance.m_bInWujue) then
		return
	end
	_instance.m_bInWujue = nil
	local pWnd = wujueInstance:GetWindow()
	if pWnd then
		_instance.m_pFubenBack:removeChildWindow(pWnd)
		CEGUI.System:getSingleton():getGUISheet():addChildWindow(pWnd)
	end
	if not _instance.m_pTeamPane:isVisible() then
		_instance.m_pTaskPane:setVisible(true)
	end
end

function CTaskTracingDialog.exitFuben()
	LogInfo("ctasktracing dialog exit fuben")
	local fubenInstance = FubenGuideDialog.getInstanceNotCreate()
	if not _instance or (not fubenInstance) or (not _instance.m_bInFuben) then
		return
	end
	_instance.m_bInFuben = nil
	local pWnd = FubenGuideDialog.getInstanceNotCreate():GetWindow() 
	if pWnd then
		_instance.m_pFubenBack:removeChildWindow(pWnd)
		CEGUI.System:getSingleton():getGUISheet():addChildWindow(pWnd)
	end
	if not _instance.m_pTeamPane:isVisible() then
		_instance.m_pTaskPane:setVisible(true)
	end
end

function CTaskTracingDialog:Run(elapsed)
	if GetDataManager():GetMainCharacterLevel() <= 10 then
		for i = 1, #self.m_mapCells do
			self.m_mapCells[i]:Run(elapsed)			
		end
	end
end

return CTaskTracingDialog
