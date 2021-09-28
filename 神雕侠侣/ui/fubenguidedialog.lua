

FubenGuideDialog = {}
setmetatable(FubenGuideDialog, Dialog)
FubenGuideDialog.__index = FubenGuideDialog 
ConfirmToEnterFubenType=0
------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function FubenGuideDialog.getInstance()
	LogInfo("enter FubenGuideDialog")
    if not _instance then
        _instance = FubenGuideDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function FubenGuideDialog.getInstanceAndShow()
	LogInfo("enter instance show")
    if not _instance then
        _instance = FubenGuideDialog:new()
        _instance:OnCreate()
	else
		LogInfo("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function FubenGuideDialog.getInstanceNotCreate()
    return _instance
end

function FubenGuideDialog.DestroyDialog()
	if _instance then 
		CTaskTracingDialog.exitFuben()
		_instance:OnClose() 
		_instance = nil
	end
end

function FubenGuideDialog.ToggleOpenClose()
	if not _instance then 
		_instance = FubenGuideDialog:new() 
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

function FubenGuideDialog.GetLayoutFileName()
    return "fubenguide.layout"
end

function FubenGuideDialog:OnCreate()
	LogInfo("enter FubenGuideDialog oncreate")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_ExitBtn=CEGUI.Window.toPushButton(winMgr:getWindow("fubenguide/btn") )
    self.m_ExitBtn:subscribeEvent("Clicked", FubenGuideDialog.HandleClickExitBtn, self)
    
    self.m_FubenName=winMgr:getWindow("fubenguide/name")
    self.m_FubenDecribe=CEGUI.Window.toRichEditbox(winMgr:getWindow("fubenguide/main"))
    
    self.m_GotoLinkBtn=CEGUI.Window.toPushButton(winMgr:getWindow("fubenguidecell") )
    self.m_GotoLinkBtn:subscribeEvent("Clicked", FubenGuideDialog.HandleGotoLinkBtn, self)
    
    self.m_BattleImage=winMgr:getWindow("fubenguide/mark")
    self.m_BattleImage:setVisible(false)
    LogInfo("m_BattleImage setvisible false")
    
    self.m_Time=winMgr:getWindow("fubenguide/image")
    self.m_Time:setVisible(false)
    
    self.TaskEndImage=winMgr:getWindow("fubenguide/finish")
    self.TaskEndImage:setVisible(false)
    
    self.m_NpcList={}
    self.m_BattleNpcNum=0
    self.m_TaskId=0
    
   
    
    local wujueTracingDlg = WujuelingExitMapDlg.getInstanceNotCreate()
    if wujueTracingDlg then
        LogInfo("WujuelingExitMapDlg.DestroyDialog")
        WujuelingExitMapDlg.DestroyDialog()
    end
    
	CTaskTracingDialog.enterFuben()
	LogInfo("exit FubenGuideDialog OnCreate")
end

------------------- private: -----------------------------------

function FubenGuideDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, FubenGuideDialog)

    return self
end



function FubenGuideDialog:HandleClickExitBtn(args)
  LogInfo("FubenGuideDialog:HandleClickRestorBtn")
  
  require "ui.wujueling.wujuelingcarddlg"
  WujuelingCardDlg.SendExitCopy()

  FubenGuideDialog.DestroyDialog()
  return true
end

function FubenGuideDialog:RefreshTask(taskId,mapId,currentTimes,defaultTimes)
   LogInfo("FubenGuideDialog:RefreshTask")
   self.m_FubenDecribe:Clear()
   LogInfo("taskId:"..tostring(taskId))
   self.m_TaskId=taskId
   local record=knight.gsp.specialquest.GetCSpecialQuestConfigTableInstance():getRecorder(taskId)
   LogInfo("recordId:"..tostring(record.id))
   if record.id~=-1 then
      LogInfo("tacename:"..record.tracname)
      self.m_FubenName:setText(record.tracname)
      for k,v in pairs( self.m_NpcList) do
		
         local npcId=v.npcId
         LogInfo("vector npcID:"..tostring(npcId))
         local npcInf = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(npcId)
         local strbuilder = StringBuilder:new()	
	     strbuilder:Set("NPCName", npcInf.name)
	     strbuilder:Set("mapid",mapId )
	     strbuilder:Set("npcid",npcId )
	     strbuilder:Set("xPos",v.xPos )
	     strbuilder:Set("yPos",v.yPos )
	     
	     local totalBattleNum=0
	     local totalBattleRecord=knight.gsp.task.GetCSpecialTaskTableInstance():getRecorder(taskId)
	     totalBattleNum=totalBattleRecord.battlenumber
	     LogInfo("FubenGuideDialog totalBattleNum:"..tostring(totalBattleNum))
	     LogInfo("FubenGuideDialog BattleNpcNum:"..tostring(self.m_BattleNpcNum))
	     local finishBattleNum=totalBattleNum-self.m_BattleNpcNum
	     if finishBattleNum<0 then
	        finishBattleNum=0
	     end
	     strbuilder:Set("Number",finishBattleNum )
	     
	     local parseText=strbuilder:GetString(record.tracdiscribe)
	     self.m_FubenDecribe:AppendParseText(CEGUI.String(parseText))
         strbuilder:delete()
	     strbuilder=nil
	     break
	     
      end
   
   end
  self.m_FubenDecribe:Refresh()
  LogInfo("End FubenGuideDialog:RefreshTask")
end

function FubenGuideDialog:ClearNpcList()
   
    self.m_NpcList=nil
end
function FubenGuideDialog:AddNpc(npcId,npcKey,posX,posY)
    LogInfo("FubenGuideDialog:AddNpc")
    LogInfo("FubenGuideDialog:AddNpc npcid:"..tostring(npcId))
    LogInfo("FubenGuideDialog:AddNpc npcKey:"..tostring(npcKey))
    LogInfo("FubenGuideDialog:AddNpc npcxPos:"..tostring(posX))
    LogInfo("FubenGuideDialog:AddNpc npcyPos:"..tostring(posY))
    if  self.m_NpcList==nil then
        self.m_NpcList={}
    end
    self.m_NpcList[npcKey]={}
    self.m_NpcList[npcKey].npcKey=npcKey
    self.m_NpcList[npcKey].npcId=npcId
    self.m_NpcList[npcKey].xPos=posX
    self.m_NpcList[npcKey].yPos=posY
    
    self.m_BattleNpcNum=self.m_BattleNpcNum+1
    
    
    
end

function FubenGuideDialog:RemoveNpc(npcKey)
   LogInfo("FubenGuideDialog:RemoveNpc")
   LogInfo("FubenGuideDialog:RemoveNpckey:"..tostring(npcKey))
   if  self.m_NpcList==nil then
        return
    end
   self.m_NpcList[npcKey]=nil
   self.m_BattleNpcNum=self.m_BattleNpcNum-1
   
   self:RefreshTask(self.m_TaskId,0,0,0)
   
   for k,v in pairs( self.m_NpcList) do
		
         local npcKey=v.npcKey
         LogInfo("RemoveNpc vector npckey:"..tostring(npcKey))
   end
end

function FubenGuideDialog.NotifyTaskProcess(taskType,step)
     
     LogInfo("FubenGuideDialog:NotifyTaskProcess")
     local totalstep=knight.gsp.task.GetCSpecialTaskmoreTableInstance():getRecorder(taskType).totalstep
     if totalstep>0 then
        local strStepInf=tostring(step).."/"..tostring(totalstep)
        local strbuilder = StringBuilder:new()	
	     strbuilder:Set("parameter1", strStepInf)
	    
--	     local okEvent=CEGUI.Event.Subscriber(FubenGuideDialog.HandleConfirmEnterFuben)
--         local cancelEvent=CEGUI.Event.Subscriber(CMessageManager.HandleDefaultCancelEvent)
	     local msg=strbuilder:GetString(MHSD_UTILS.get_msgtipstring(142912))
	     GetMessageManager():AddConfirmBox(eConfirmTeamLeaderEnterFuben,msg,FubenGuideDialog.HandleConfirmEnterFuben,0,
	     CMessageManager.HandleDefaultCancelEvent,CMessageManager,0,0,nil,"","")
	     ConfirmToEnterFubenType=taskType
         strbuilder:delete()
	     strbuilder=nil
     end
     
     
end

function FubenGuideDialog.HandleConfirmEnterFuben(args)
  LogInfo("FubenGuideDialog:HandleConfirmEnterFuben")
  
  
  GetNetConnection():send(knight.gsp.npc.CSureEnter(ConfirmToEnterFubenType))
  LogInfo("send CSureEnter to server, fubentype:"..tostring(ConfirmToEnterFubenType))
  GetMessageManager():CloseConfirmBox(eConfirmTeamLeaderEnterFuben,false)
  ConfirmToEnterFubenType=0
  return true
end

function FubenGuideDialog:HandleGotoLinkBtn(args)
   LogInfo("FubenGuideDialog:HandleGotoLinkBtn")
   self.m_FubenDecribe:OnFirstGotoLinkClick();
   return true
end

function FubenGuideDialog:NotifyFubenEnd()
   LogInfo("FubenGuideDialog:NotifyFubenEnd")
   self.m_FubenDecribe:Clear()
   local parseText=MHSD_UTILS.get_msgtipstring(142920)
   self.m_FubenDecribe:AppendParseText(CEGUI.String(parseText))
   self.m_FubenDecribe:Refresh()
   self.TaskEndImage:setVisible(true)
   return true
end


