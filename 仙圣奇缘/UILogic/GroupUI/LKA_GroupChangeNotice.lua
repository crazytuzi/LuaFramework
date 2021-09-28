--------------------------------------------------------------------------------------
-- 文件名:	Game_GroupChangeNotice.lua
-- 版  权:	(C)  深圳市美天互动有限公司
-- 创建人:  陆奎安
-- 日  期:	2015-3-18 10:24
-- 版  本:	1.0
-- 描  述:	帮派管理
-- 应  用:  本例子使用一般方法的实现Scene

---------------------------------------------------------------------------------------
Game_GroupChangeNotice = class("Game_GroupChangeNotice")
Game_GroupChangeNotice.__index = Game_GroupChangeNotice
local chatStrNum = 68

function Game_GroupChangeNotice:initWnd()
	local Image_GroupChangeNoticePNL = tolua.cast(self.rootWidget:getChildByName("Image_GroupChangeNoticePNL"), "ImageView")

	local Image_ContentPNL = tolua.cast(Image_GroupChangeNoticePNL:getChildByName("Image_ContentPNL"), "ImageView")
	local Button_ChangeNotice = tolua.cast(Image_GroupChangeNoticePNL:getChildByName("Button_ChangeNotice"), "Label")
	local Label_RemainCountLB = tolua.cast(Button_ChangeNotice:getChildByName("Label_RemainCountLB"), "Label")
	self.Label_RemainCount = tolua.cast(Label_RemainCountLB:getChildByName("Label_RemainCount"), "Label")
	
	self.Label_Input = tolua.cast(Image_ContentPNL:getChildByName("Label_Input"), "Label")
	self.Label_Input1 = tolua.cast(Image_ContentPNL:getChildByName("Label_Input1"), "Label")
	self.Label_Input2 = tolua.cast(Image_ContentPNL:getChildByName("Label_Input2"), "Label")
	
	self.TextField_Input = tolua.cast(Image_GroupChangeNoticePNL:getChildByName("TextField_Input"), "TextField")
	self.Label_RemainCount:setText("("..chatStrNum..")")

	local tbLabel = {
			{["label"] = self.Label_Input},
			{["label"] = self.Label_Input1},
			{["label"] = self.Label_Input2}
	}
	local function callBack(InputNum)
		self.Label_RemainCount:setText("("..InputNum..")")
	end
	setTextField(self.TextField_Input,tbLabel,chatStrNum,510,callBack) 
	
	local function onClickButton(pSender, nTag)
		local nString = self.TextField_Input:getStringValue()
		g_Guild:requestGuildChangeNoticeRequest(nString)
	end
	g_SetBtn(self.rootWidget, "Button_ChangeNotice", onClickButton, true,true,1)
	
	self.Label_RemainCount:setPositionX(Label_RemainCountLB:getSize().width)
	
end

function Game_GroupChangeNotice:openWnd()
	if g_bReturn then return end 
end


function Game_GroupChangeNotice:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_GroupChangeNoticePNL = tolua.cast(self.rootWidget:getChildByName("Image_GroupChangeNoticePNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_GroupChangeNoticePNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_GroupChangeNotice:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_GroupChangeNoticePNL = tolua.cast(self.rootWidget:getChildByName("Image_GroupChangeNoticePNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_GroupChangeNoticePNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end