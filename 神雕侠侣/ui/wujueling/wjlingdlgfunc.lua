--[[author: lvxiaolong
date: 2013/12/9
function: wjling dlg general function
]]

require "ui.dialog"
require "utils.mhsdutils"
require "manager.beanconfigmanager"

lua_WujuelingBtnUnit = {}
function lua_WujuelingBtnUnit.New()
    local btnunit = {}
    
    btnunit.m_pBtn = nil
    btnunit.m_pTaskName = nil
	btnunit.m_pTaskLevel = nil
    btnunit.m_iPos = 0
    btnunit.m_iTaskID = 0
    
    return btnunit
end

function lua_WujuelingBtnUnit.NewHasParam(questid)
    local btnunit = {}
    
    local winMgr = CEGUI.WindowManager:getSingleton()
    
    btnunit.m_pBtn = CEGUI.Window.toPushButton(winMgr:loadWindowLayout("wujuelingcell.layout", tostring(questid)))
    btnunit.m_pBtn:setID(questid)
    btnunit.m_pTaskName = winMgr:getWindow(tostring(questid) .. "wujuelingcell/text1")
    btnunit.m_pTaskName:setMousePassThroughEnabled(true)
    btnunit.m_pTaskLevel = winMgr:getWindow(tostring(questid) .. "wujuelingcell/text3")
    btnunit.m_pTaskLevel:setMousePassThroughEnabled(true)
    
    btnunit.m_iPos = 0
    btnunit.m_iTaskID = questid
    
    return btnunit
end


