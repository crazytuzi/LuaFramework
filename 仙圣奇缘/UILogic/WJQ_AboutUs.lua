--------------------------------------------------------------------------------------
-- 文件名:	LKA_ArenaRewardReward.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:  陆奎安
-- 日  期:	2013-12-10 10:24
-- 版  本:	1.0
-- 描  述:	竞技场界面
-- 应  用:  本例子使用一般方法的实现Scene

---------------------------------------------------------------------------------------
Game_AboutUs = class("Game_AboutUs")
Game_AboutUs.__index = Game_AboutUs

function Game_AboutUs:initWnd()
    local Image_AboutUsPNL = tolua.cast(self.rootWidget:getChildByName("Image_AboutUsPNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(Image_AboutUsPNL:getChildByName("Image_ContentPNL"), "ImageView")
    local Label_Group = tolua.cast(Image_ContentPNL:getChildByName("Label_Group"), "Label")  --客服QQ
    local Label_Contact = tolua.cast(Image_ContentPNL:getChildByName("Label_Contact"), "Label") --客服电话
    if g_strAndroidTS == "open" then
        Label_Group:setVisible(false)  
    end 
    if g_IsXiaoXiaoXianSheng then
        local Label_GameName = tolua.cast(Image_ContentPNL:getChildByName("Label_GameName"), "Label")
        Label_GameName:setText("游戏名称：小小仙圣")
    end

    if g_bVersionAndroid_0_0_ == "jinli_1.0.1" then
        Label_Contact:setVisible(false) 
    end
end

function Game_AboutUs:openWnd()
end

function Game_AboutUs:closeWnd()
end


function Game_AboutUs:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_AboutUsPNL = tolua.cast(self.rootWidget:getChildByName("Image_AboutUsPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_AboutUsPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_AboutUs:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_AboutUsPNL = tolua.cast(self.rootWidget:getChildByName("Image_AboutUsPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_AboutUsPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end