--------------------------------------------------------------------------------------
-- 文件名:	Game_SendLoveAnimation.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:  陆奎安
-- 日  期:	2013-12-10 10:24
-- 版  本:	1.0
-- 描  述:	竞技场界面
-- 应  用:  本例子使用一般方法的实现Scene

---------------------------------------------------------------------------------------
Game_SendLoveAnimation = class("Game_SendLoveAnimation")
Game_SendLoveAnimation.__index = Game_SendLoveAnimation

function Game_SendLoveAnimation:initWnd()
	local function rootCallback()
		g_WndMgr:hideProWnd()
	end
	g_SetBtn(nil, nil, rootCallback, true, true,2,self.rootWidget)
	local function NoticeCallback()
		g_WndMgr:hideProWnd()
	end
	g_SetBtn(self.rootWidget, "Button_Notice", NoticeCallback, true, true,2)
end

function Game_SendLoveAnimation:startAction()
	local Image_Light1 = tolua.cast(self.rootWidget:getChildByName("Image_Light1"), "ImageView")
	Image_Light1:setOpacity(120)
	g_SetBlendFuncWidget(Image_Light1, 4)
	local Image_Light2 = tolua.cast(self.rootWidget:getChildByName("Image_Light2"), "ImageView")
	Image_Light2:setOpacity(120)
	g_SetBlendFuncWidget(Image_Light2, 4)
	local Image_Light3 = tolua.cast(self.rootWidget:getChildByName("Image_Light3"), "ImageView")
	Image_Light3:setOpacity(120)
	g_SetBlendFuncWidget(Image_Light3, 4)
	local Image_Light4 = tolua.cast(self.rootWidget:getChildByName("Image_Light4"), "ImageView")
	Image_Light4:setOpacity(150)
	g_SetBlendFuncWidget(Image_Light4, 4)
	local Image_Light5 = tolua.cast(self.rootWidget:getChildByName("Image_Light5"), "ImageView")
	Image_Light5:setOpacity(150)
	g_SetBlendFuncWidget(Image_Light5, 4)
	local Image_Light6 = tolua.cast(self.rootWidget:getChildByName("Image_Light6"), "ImageView")
	Image_Light6:setOpacity(150)
	g_SetBlendFuncWidget(Image_Light6, 4)
	
	local Image_Love1 = tolua.cast(self.rootWidget:getChildByName("Image_Love1"), "ImageView")
	local Image_Love2 = tolua.cast(self.rootWidget:getChildByName("Image_Love2"), "ImageView")
	
	local actionRotate_Light1 = CCRotateBy:create(5, 360) 	
	local actionRotateForever_Light1 = CCRepeatForever:create(actionRotate_Light1)
	Image_Light1:runAction(actionRotateForever_Light1)
	
	local actionRotate_Light2 = CCRotateBy:create(5, -360) 	
	local actionRotateForever_Light2 = CCRepeatForever:create(actionRotate_Light2)
	Image_Light2:runAction(actionRotateForever_Light2)
	
	local actionRotate_Light3 = CCRotateBy:create(5, 360) 	
	local actionRotateForever_Light3 = CCRepeatForever:create(actionRotate_Light3)
	Image_Light3:runAction(actionRotateForever_Light3)
	
	local actionRotateTo_Light4 = CCRotateBy:create(5, 360)
	local actionRotateForever_Light4 = CCRepeatForever:create(actionRotateTo_Light4)
	Image_Light4:runAction(actionRotateForever_Light4)
	
	local actionRotateTo_Light5 = CCRotateBy:create(5, -360)
	local actionRotateForever_Light5 = CCRepeatForever:create(actionRotateTo_Light5)
	Image_Light5:runAction(actionRotateForever_Light5)
	
	local actionRotateTo_Light6 = CCRotateBy:create(5, 360)
	local actionRotateForever_Light6 = CCRepeatForever:create(actionRotateTo_Light6)
	Image_Light6:runAction(actionRotateForever_Light6)
	
	local actionScaleTo1 = CCScaleTo:create(0.15, 1.1)
	local actionEaseBounceOut1 = CCEaseBounceOut:create(actionScaleTo1)
	local actionScaleTo2 = CCScaleTo:create(0.15, 0.9)
	local actionEaseBounceOut2 = CCEaseBounceOut:create(actionScaleTo2)
	local actionScaleTo3 = CCScaleTo:create(0.15, 1)
	local actionEaseBounceOut3 = CCEaseBounceOut:create(actionScaleTo3)
	local arrAct_Love1 = CCArray:create()
	arrAct_Love1:addObject(actionEaseBounceOut1)
	arrAct_Love1:addObject(actionEaseBounceOut2)
	arrAct_Love1:addObject(actionEaseBounceOut3)
	local function showGlitteringLove1()
		g_GlitteringWidget(Image_Love1,nil,nil,nil,nil,nil,0.95)
	end
	arrAct_Love1:addObject(CCCallFuncN:create(showGlitteringLove1))
	local action = CCSequence:create(arrAct_Love1)
	Image_Love1:runAction(action)
	
	local actionScaleTo1 = CCScaleTo:create(0.15, 0.9)
	local actionEaseBounceOut1 = CCEaseBounceOut:create(actionScaleTo1)
	local actionScaleTo2 = CCScaleTo:create(0.15, 0.7)
	local actionEaseBounceOut2 = CCEaseBounceOut:create(actionScaleTo2)
	local actionScaleTo3 = CCScaleTo:create(0.15, 0.8)
	local actionEaseBounceOut3 = CCEaseBounceOut:create(actionScaleTo3)
	local arrAct_Love2 = CCArray:create()
	arrAct_Love2:addObject(actionEaseBounceOut1)
	arrAct_Love2:addObject(actionEaseBounceOut2)
	arrAct_Love2:addObject(actionEaseBounceOut3)
	local function showGlitteringLove2()
		g_GlitteringWidget(Image_Love2,nil,nil,nil,nil,nil,0.95)
	end
	arrAct_Love2:addObject(CCCallFuncN:create(showGlitteringLove2))
	local action = CCSequence:create(arrAct_Love2)
	Image_Love2:runAction(action)
end

function Game_SendLoveAnimation:openWnd()
	if g_bReturn  then  return  end
	self:startAction()
end

function Game_SendLoveAnimation:closeWnd()
end