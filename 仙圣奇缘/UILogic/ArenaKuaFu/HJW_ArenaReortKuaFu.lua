--------------------------------------------------------------------------------------
-- 文件名:	HJW_ArenaReortKuaFu.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:  
-- 日  期:	2016-6-28 
-- 版  本:	1.0
-- 描  述:	跨服战报
-- 应  用:  
---------------------------------------------------------------------------------------
Game_ArenaReortKuaFu = class("Game_ArenaReortKuaFu", function() return Game_ArenaReport.new() end )
Game_ArenaReortKuaFu.__index = Game_ArenaReortKuaFu
---------------这两个是必须要赋值的
-- ArenaReportList
--myRank
-----------------
function Game_ArenaReortKuaFu:openWnd()
	
	if g_bReturn  then  return  end

	myRank  = g_ArenaKuaFuData:getSelfRank()
	
	local wndInstance = g_WndMgr:getWnd("Game_ArenaReortKuaFu")
	if wndInstance then
		ArenaReportList = g_ArenaKuaFuData:getArenaReport()
		if ArenaReportList then
			self.listView:updateItems(#ArenaReportList)
			
			local Image_ArenaReportPNL = tolua.cast(self.rootWidget:getChildByName("Image_ArenaReportPNL"), "ImageView")
			local Image_ArenaReportIsNil = tolua.cast(Image_ArenaReportPNL:getChildByName("Image_ArenaReportIsNil"), "ImageView")
			if #ArenaReportList == 0 then
				Image_ArenaReportIsNil:setVisible(true)
			else
				Image_ArenaReportIsNil:setVisible(false)
			end
		end
	end
end



