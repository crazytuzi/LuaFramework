--------------------------------------------------------------------------------------
-- 文件名:	LKA_CArenaHistory.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:  陆奎安
-- 日  期:	2013-12-10 10:24
-- 版  本:	1.0
-- 描  述:	竞技场界面
-- 应  用:  本例子使用一般方法的实现Scene

---------------------------------------------------------------------------------------
Game_ArenaHistory = class("Game_ArenaHistory")
Game_ArenaHistory.__index = Game_ArenaHistory

function Game_ArenaHistory:setWnd()
	local Image_ArenaHistoryPNL = tolua.cast(self.rootWidget:getChildByName("Image_ArenaHistoryPNL"),"ImageView")
	local Image_ContentPNL = tolua.cast(Image_ArenaHistoryPNL:getChildByName("Image_ContentPNL"),"ImageView")
	

	local BitmapLabel_Rank = tolua.cast(Image_ContentPNL:getChildByName("BitmapLabel_Rank"),"LabelBMFont")
	local BitmapLabel_WinRate = tolua.cast(Image_ContentPNL:getChildByName("BitmapLabel_WinRate"),"LabelBMFont")
	local BitmapLabel_WinNum = tolua.cast(Image_ContentPNL:getChildByName("BitmapLabel_WinNum"),"LabelBMFont")
	local BitmapLabel_TotalNum = tolua.cast(Image_ContentPNL:getChildByName("BitmapLabel_TotalNum"),"LabelBMFont")
	local Image_RankClass = tolua.cast(Image_ContentPNL:getChildByName("Image_RankClass"),"ImageView")
	
	local ArenaInfo = getTbRoleArenaInfo()
	if not ArenaInfo then return end
	BitmapLabel_Rank:setText(ArenaInfo.self_rank)
	local nNum = ArenaInfo.wins + ArenaInfo.loses
	local WinRate
	if nNum == 0 then
		WinRate = 0
	else
		WinRate = math.floor(ArenaInfo.wins *100/ nNum)
	end
	BitmapLabel_WinRate:setText(WinRate.."%")
	BitmapLabel_WinNum:setText(ArenaInfo.wins)
	BitmapLabel_TotalNum:setText(nNum)

	local Interval = getArenaIntervalValue(ArenaInfo.self_rank)
	local CSV_ArenaDailyReward = g_DataMgr:getArenaDailyRewardCsv(Interval)
	Image_RankClass:loadTexture(getArenaImg(CSV_ArenaDailyReward.ClassIcon))
		
end

function Game_ArenaHistory:initWnd(widget)
	local Image_ArenaHistoryPNL = tolua.cast(widget:getChildByName("Image_ArenaHistoryPNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(Image_ArenaHistoryPNL:getChildByName("Image_ContentPNL"), "ImageView")
	local Panel_Background = tolua.cast(Image_ContentPNL:getChildByName("Panel_Background"), "Layout")
	
	local Image_SymbolBlueLight1 = tolua.cast(Panel_Background:getChildByName("Image_SymbolBlueLight1"), "ImageView")
	local ccSprite = tolua.cast(Image_SymbolBlueLight1:getVirtualRenderer(),"CCSprite")
	g_SetBlendFuncSprite(ccSprite,4)
	local Image_SymbolBlueLight2 = tolua.cast(Panel_Background:getChildByName("Image_SymbolBlueLight2"), "ImageView")
	local ccSprite = tolua.cast(Image_SymbolBlueLight2:getVirtualRenderer(),"CCSprite")
	g_SetBlendFuncSprite(ccSprite,4)
end

function Game_ArenaHistory:openWnd()
	if g_bReturn  then  return  end
	self:setWnd()
end

function Game_ArenaHistory:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_ArenaHistoryPNL = tolua.cast(self.rootWidget:getChildByName("Image_ArenaHistoryPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_ArenaHistoryPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_ArenaHistory:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_ArenaHistoryPNL = tolua.cast(self.rootWidget:getChildByName("Image_ArenaHistoryPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_ArenaHistoryPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end