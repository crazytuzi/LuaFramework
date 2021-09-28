--------------------------------------------------------------------------------------
-- 文件名:	HJW_GameSummonLog
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述: 
-- 应  用:
---------------------------------------------------------------------------------------

Game_SummonLog = class("Game_SummonLog")
Game_SummonLog.__index = Game_SummonLog

function Game_SummonLog:initWnd()

end

function Game_SummonLog:openWnd()
	
	if not self.rootWidget then return end
	local Image_SummonLogPNL = tolua.cast(self.rootWidget:getChildByName("Image_SummonLogPNL"), "ImageView")
	
	local function updateListViewFunc(widget, nIndex)
		local txt = ""
		local tbCurTime = g_GetServerTime()
		local tbLog = g_SummonLogData:getSummonLogData()[nIndex]
		if tbLog then 
			local nTime = tbCurTime - tbLog.time
			txt = string.format(_T("%s#04%s#00召唤出了三星伙伴[#05%s#00]"),getPrayTime(nTime),tbLog.role_name ,_T(tbLog.card_name) )
		end
		local Label_Log = tolua.cast(widget:getChildByName("Label_Log"),"Label")
		Label_Log:removeAllChildren()
		
		local labelLogWidth = gCreateColorLable(Label_Log, txt)	
		-- Label_Log:setPositionX(-labelLogWidth/2)
		
		if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET then 
			Label_Log:setPositionX(-300)
		else
			Label_Log:setPositionX(-200)
		end
		Label_Log:setPositionY(-10)
		
	end
	
	
	local ListView_Log = tolua.cast(Image_SummonLogPNL:getChildByName("ListView_Log"),"ListViewEx")
	local LuaListView_Log = Class_LuaListView:new()
	
	local model = tolua.cast(ListView_Log:getChildByName("Image_LogItemPNL"),"ImageView")

	LuaListView_Log:setModel(model)
	LuaListView_Log:setListView(ListView_Log)
	LuaListView_Log:setUpdateFunc(updateListViewFunc)
	
	LuaListView_Log:updateItems(#g_SummonLogData:getSummonLogData())

end

function Game_SummonLog:closeWnd()

end

function Game_SummonLog:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_SummonLogPNL = tolua.cast(self.rootWidget:getChildByName("Image_SummonLogPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_SummonLogPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_SummonLog:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_SummonLogPNL = tolua.cast(self.rootWidget:getChildByName("Image_SummonLogPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_SummonLogPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end
