--[[author: lvxiaolong
date: 2013/12/9
function: wu jue ling dialog
]]

require "ui.dialog"
require "utils.mhsdutils"
require "manager.beanconfigmanager"
require "ui.wujueling.wjlingdlgfunc"
require "protocoldef.knight.gsp.task.creqwujuelingtask"

WujuelingDlg = {
    m_TaskID = 0,
    m_vecWujueTypes = {},
    MAX_MODE = 3,
}

setmetatable(WujuelingDlg, Dialog)
WujuelingDlg.__index = WujuelingDlg 


------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance

function WujuelingDlg.IsShow()
    --LogInfo("WujuelingDlg.IsShow")

    if _instance and _instance:IsVisible() then
        return true
    end

    return false
end

function WujuelingDlg.getInstance()
	LogInfo("WujuelingDlg.getInstance")
    if not _instance then
        _instance = WujuelingDlg:new()
        _instance:OnCreate()
    end

    return _instance
end

function WujuelingDlg.getInstanceAndShow()
	LogInfo("____WujuelingDlg.getInstanceAndShow")
    if not _instance then
        _instance = WujuelingDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    
    return _instance
end

function WujuelingDlg.getInstanceNotCreate()
    --print("WujuelingDlg.getInstanceNotCreate")
    return _instance
end

function WujuelingDlg.DestroyDialog()
	if _instance then
		_instance:OnClose() 
		_instance = nil
	end
end

function WujuelingDlg.ToggleOpenClose()
	if not _instance then 
		_instance = WujuelingDlg:new() 
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

function WujuelingDlg.GetLayoutFileName()
    return "Wujueling.layout"
end

function WujuelingDlg:OnCreate()
	LogInfo("enter WujuelingDlg oncreate")

    Dialog.OnCreate(self)
    --self:GetWindow():setModalState(true)

    local winMgr = CEGUI.WindowManager:getSingleton()
    --get windows

    self.m_pPane = CEGUI.Window.toScrollablePane(winMgr:getWindow("Wujueling/top/main"))
    
    self.m_BriefTitle = winMgr:getWindow("Wujueling/top/title/name1")
    self.m_BriefText = CEGUI.Window.toRichEditbox(winMgr:getWindow("Wujueling/top1/main"))
    self.m_BriefText:setReadOnly(true)

    self.m_pTodayTimes = winMgr:getWindow("Wujueling/num")
    
    self.m_pBtnMode = {}
    for i = 1, self.MAX_MODE, 1 do
      self.m_pBtnMode[i] = CEGUI.Window.toPushButton(winMgr:getWindow("Wujueling/ok" .. (i-1)))
      self.m_pBtnMode[i]:setID(i)
      self.m_pBtnMode[i]:subscribeEvent("Clicked", WujuelingDlg.HandleModeBtnClicked, self)
    end

    self:Init()
    
    LogInfo("exit WujuelingDlg OnCreate")
end

function WujuelingDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, WujuelingDlg)
    
    self.m_eDialogType[DialogTypeTable.eDlgTypeBattleClose] = 1
    self.m_eDialogType[DialogTypeTable.eDlgTypeInScreenCenter] = 1
    self.m_eDialogType[DialogTypeTable.eDlgTypeMapChangeClose] = 1

    return self
end

function WujuelingDlg:Init()
    local selected = false
    
    local all_taskids = std.vector_int_()
    local tt = knight.gsp.task.GetCWujuelingTaskTableInstance()
    tt:getAllID(all_taskids)
    local num = all_taskids:size()
    
    self.m_vecWujueTypes = {}

    for i = 0, num-1, 1 do
         local cwt = tt:getRecorder(all_taskids[i])
         
         if cwt and cwt.id ~= -1 then
             local new_unit = lua_WujuelingBtnUnit.NewHasParam(cwt.id)

             local mainchar_level = GetDataManager():GetMainCharacterLevel()
             if cwt.minlevel <= mainchar_level and mainchar_level <= cwt.maxlevel then
                 new_unit.m_pBtn:setEnabled(true)
                 new_unit.m_pTaskName:setProperty("TextColours","tl:FFFFEAA9 tr:FFFFEAA9 bl:FFFFBA15 br:FFFFBA15")
                 new_unit.m_pTaskName:setProperty("BorderColour","FF03568B")
                 new_unit.m_pTaskLevel:setProperty("TextColours","tl:FF80FD98 tr:FF80FD98 bl:FF47FF15 br:FF47FF15")
                 new_unit.m_pTaskLevel:setProperty("BorderColour","FF075F00")
                 self.m_TaskID = cwt.id
             else
                 new_unit.m_pBtn:setEnabled(false)
                 new_unit.m_pTaskName:setProperty("TextColours","tl:FFFFFFFF tr:FFFFFFFF bl:FF9D9D9D br:FF9D9D9D")
                 new_unit.m_pTaskName:setProperty("BorderColour","FF1B1B1C")
                 new_unit.m_pTaskLevel:setProperty("TextColours","tl:FFFFFFFF tr:FFFFFFFF bl:FF9D9D9D br:FF9D9D9D")
                 new_unit.m_pTaskLevel:setProperty("BorderColour","FF1B1B1C")
             end

             new_unit.m_pTaskName:setText(cwt.taskname)
             new_unit.m_pTaskLevel:setText(cwt.tasklevel)
             new_unit.m_pBtn:subscribeEvent("MouseClick", WujuelingDlg.HandleTaskChanged, self)

             self.m_pPane:addChildWindow(new_unit.m_pBtn)
             new_unit.m_iPos = #self.m_vecWujueTypes
             
             local xpos = -1*math.floor(new_unit.m_pBtn:getPixelSize().width/2)
             local ypos = new_unit.m_pBtn:getPixelSize().height*new_unit.m_iPos+10
             new_unit.m_pBtn:setPosition(CEGUI.UVector2(CEGUI.UDim(0.5, xpos),CEGUI.UDim(0,ypos)))
             
             self.m_vecWujueTypes[#self.m_vecWujueTypes+1] = new_unit
         end
    end
    
    self:UpdateCurTask()
end

function WujuelingDlg:SetTimes(curtimes, totaltimes)
    self.m_pTodayTimes:setText(tostring(curtimes) .. "/" .. tostring(totaltimes))
end

function WujuelingDlg:SetBtnSelected(taskid)
    local num = #self.m_vecWujueTypes

    for i = 1, num, 1 do
        if self.m_vecWujueTypes[i].m_iTaskID == taskid then
            self.m_vecWujueTypes[i].m_pBtn:setProperty("NormalImage", "set:MainControl9 image:shopcellchoose")
        else
            self.m_vecWujueTypes[i].m_pBtn:setProperty("NormalImage", "set:MainControl9 image:shopcelldisable")
        end
    end
end

function WujuelingDlg:UpdateCurTask()
    local cwt = knight.gsp.task.GetCWujuelingTaskTableInstance():getRecorder(self.m_TaskID)
    if not cwt or cwt.id == -1 then
        return
    end

    self:SetBtnSelected(self.m_TaskID)
    self.m_BriefTitle:setText(cwt.taskname)
    self.m_BriefText:Clear()
    self.m_BriefText:AppendParseText(CEGUI.String(cwt.tasktext))
    self.m_BriefText:Refresh()
    self.m_BriefText:HandleTop()
end

function WujuelingDlg:HandleTaskChanged(e)
    LogInfo("____WujuelingDlg:HandleTaskChanged")
    
    local WindowArgs = CEGUI.toMouseEventArgs(e)
    local pCell = WindowArgs.window

    local utaskid = pCell:getID()

    self.m_TaskID = utaskid
    self:UpdateCurTask()

    return true
end

function WujuelingDlg:HandleModeBtnClicked(e)
    LogInfo("____WujuelingDlg:HandleModeBtnClicked")

    local WindowArgs = CEGUI.toMouseEventArgs(e)
    local pBtn = WindowArgs.window
    
    if not pBtn then
        return false
    end
    
    local crt = CReqWuJueLingTask.Create()
    crt.taskid = self.m_TaskID
    crt.tasktype = pBtn:getID()
    LuaProtocolManager.getInstance():send(crt)
    
    WujuelingDlg.DestroyDialog()

    return true
end

return WujuelingDlg








