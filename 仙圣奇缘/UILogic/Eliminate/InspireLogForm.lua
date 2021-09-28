 --------------------------------------------------------------------------------------
-- 文件名: InspireLogForm.lua
-- 版  权:    (C)深圳美天互动科技有限公司
-- 创建人: 
-- 日  期:   
-- 版  本:    感悟log 界面
-- 描  述:    
-- 应  用:  
---------------------------------------------------------------------------------------
InspireLogForm = class("InspireLogForm")
InspireLogForm.__index = InspireLogForm

local wgtTag = 0xff546677

function InspireLogForm:ctor()
	self.ListView = nil

	self.RunAction = false
end

function InspireLogForm:InitListView(LogPnl)
	local listView = LogPnl:getChildByName("ListView_Log")
	if listView == nil then return false end

	local wgtListView =  tolua.cast(listView, "ListViewEx")

	self.ListView = Class_LuaListView:new()
	self.ListView:setListView(wgtListView)

	self.ListView:setModel(g_WidgetModel.Panel_LogItem:clone())
	self.ListView:setUpdateFunc(handler(self, self.onUpdateLogList))

	g_FormMsgSystem:RegisterFormMsg(FormMsg_InspireForm_InsertLog, handler(self, self.OnMsgRefeshInspireLog))
	return true 
end

function InspireLogForm:Release()
	self.ListView = nil
	g_FormMsgSystem:UnRegistFormMsg(FormMsg_InspireForm_InsertLog)
end

function InspireLogForm:ShowLogList()
	cclog("======InspireLogForm:ShowLogList===="..g_EliminateSystem:GetLogCount())
	if self.ListView ~= nil then
		self.ListView:updateItems(g_EliminateSystem:GetLogCount())
	end
end


function  InspireLogForm:onUpdateLogList(Panel, nIndex)
	local logitem = g_EliminateSystem:GetRevLogByIndex(nIndex)
	-- cclog("InspireLogForm:onUpdateLogList nIndex = "..nIndex)
	if logitem == nil then return false end

	-- cclog("InspireLogForm:onUpdateLogList logitem:GetStrLog() = "..logitem:GetStrLog())
	local Label_Log = tolua.cast(Panel:getChildByName("Label_Log"), "Label")
	if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
		Label_Log:setFontSize(18)
	else
		Label_Log:setFontSize(20)
	end
	Label_Log:setText(logitem:GetStrLog())
	g_setTextColor(Label_Log, logitem:GetColor())

	if self.RunAction and nIndex == 1 then --每次更新第一个是最新的

		local Scale1 = CCScaleTo:create(0.1, 1.5)
		local Scale2 = CCScaleTo:create(0.1, 1)
		local arryAct  = CCArray:create()
		arryAct:addObject(Scale1)
		arryAct:addObject(Scale2)

		local squ = CCSequence:create(arryAct)
		Panel:runAction(squ)

		self.RunAction = false
	end

	return true
end

function InspireLogForm:OnMsgRefeshInspireLog()
	if self.ListView ~= nil then
		self.ListView:updateItems(g_EliminateSystem:GetLogCount())
		self.RunAction = true
	end
end

function InspireLogForm:ModifyWnd_viet_VIET()
    local Label_Log = tolua.cast(g_WidgetModel.Panel_LogItem:getChildAllByName("Label_Log"), "Label")
    Label_Log:setFontSize(14)
end