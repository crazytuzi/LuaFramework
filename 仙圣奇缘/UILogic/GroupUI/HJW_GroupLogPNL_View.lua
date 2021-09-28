--------------------------------------------------------------------------------------
-- 文件名:	HJW_GroupLogPNL_View.lua
-- 版  权:	(C)深圳市美天互动有限公司
-- 创建人:	
-- 日  期:	2015-11-20
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  帮派日志
---------------------------------------------------------------------------------------

GroupLogPNL = class("GroupLogPNL")
GroupLogPNL.__index = GroupLogPNL

function GroupLogPNL:init(widget)
	self.widget = widget
	
	if not self.widget or self.widget == "" then return end
	
	local Image_GroupLogPNL = tolua.cast(widget:getChildByName("Image_GroupLogPNL"), "ImageView")
	Image_GroupLogPNL:setVisible(true)
	
	g_Guild:requestGuildLogRequest()
	
end


--帮派日志界面
function GroupLogPNL:getImageGroupLogPNLView(logList)

	if not self.widget or self.widget == "" then return end
	
	local Image_GroupLogPNL = tolua.cast(self.widget:getChildByName("Image_GroupLogPNL"),"ImageView")
	local ListView_GroupLog = tolua.cast(Image_GroupLogPNL:getChildByName("ListView_GroupLog"),"ListViewEx")
	local Panel_LogItem = tolua.cast(ListView_GroupLog:getChildByName("Panel_LogItem"),"Layout")
	
	local LuaListView_GroupList = Class_LuaListView:new()
    self.LuaListView_GroupList = LuaListView_GroupList
	local function updateListViewItem(Panel_LogItem, nIndex)
		--帮众名字
		local Label_MaterName = tolua.cast(Panel_LogItem:getChildByName("Label_MaterName"),"Label")
		
		local param = {
			name = logList[nIndex].name,breachLevel =logList[nIndex].breachlv,lableObj = Label_MaterName,
			nLeftString = "[",nRightString="]"
		}
		g_Guild:setLableByColor(param)
		
		local Label_HuoDeLB = tolua.cast(Panel_LogItem:getChildByName("Label_HuoDeLB"),"Label")
		
		local Label_Prestege = tolua.cast(Panel_LogItem:getChildByName("Label_Prestege"),"Label")
		Label_Prestege:setText(logList[nIndex].prestige.._T("点的声望"))

		local Label_GongXianLB = tolua.cast(Panel_LogItem:getChildByName("Label_GongXianLB"),"Label")
		--多少经验
		local Label_AddExp = tolua.cast(Panel_LogItem:getChildByName("Label_AddExp"),"Label")
		Label_AddExp:setText(logList[nIndex].exp.._T("点经验"))

		local Label_Time = tolua.cast(Panel_LogItem:getChildByName("Label_Time"),"Label")
		local nTime = getStrTime(logList[nIndex].logtime)
		Label_Time:setText(nTime)
		g_AdjustWidgetsPosition({
			Label_MaterName,Label_HuoDeLB,Label_Prestege,Label_GongXianLB,Label_AddExp
		})	
	
		if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
			local size = 16
			Label_MaterName:setFontSize(size)
			Label_HuoDeLB:setFontSize(size) 
			Label_Prestege:setFontSize(size) 
			Label_GongXianLB:setFontSize(size) 
			Label_AddExp:setFontSize(size) 
			Label_Time:setFontSize(size)
		end
	
	end
	
    LuaListView_GroupList:setModel(Panel_LogItem)
    LuaListView_GroupList:setUpdateFunc(updateListViewItem)
    LuaListView_GroupList:setListView(ListView_GroupLog)
	LuaListView_GroupList:updateItems(#logList)
end


