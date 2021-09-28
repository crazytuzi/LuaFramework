--------------------------------------------------------------------------------------
-- 文件名:	LKA_ArenaTitle.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:  陆奎安
-- 日  期:	2013-12-10 10:24
-- 版  本:	1.0
-- 描  述:	竞技场界面
-- 应  用:  本例子使用一般方法的实现Scene

---------------------------------------------------------------------------------------
Game_ArenaRankClass = class("Game_ArenaRankClass")
Game_ArenaRankClass.__index = Game_ArenaRankClass

function Game_ArenaRankClass:initWnd(widget)
	local Image_ArenaRankClassPNL = tolua.cast(self.rootWidget:getChildByName("Image_ArenaRankClassPNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(Image_ArenaRankClassPNL:getChildByName("Image_ContentPNL"), "ImageView")
	Image_ContentPNL:loadTexture(getBackgroundJpgImg("Background_Arena"))
end

function Game_ArenaRankClass:openWnd(tbData)
	if g_bReturn then return end
end

function Game_ArenaRankClass:closeWnd(tbData)
	local Image_ArenaRankClassPNL = tolua.cast(self.rootWidget:getChildByName("Image_ArenaRankClassPNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(Image_ArenaRankClassPNL:getChildByName("Image_ContentPNL"), "ImageView")
	Image_ContentPNL:loadTexture(getUIImg("Blank"))
end

function Game_ArenaRankClass:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_ArenaRankClassPNL = tolua.cast(self.rootWidget:getChildByName("Image_ArenaRankClassPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_ArenaRankClassPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_ArenaRankClass:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_ArenaRankClassPNL = tolua.cast(self.rootWidget:getChildByName("Image_ArenaRankClassPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_ArenaRankClassPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end