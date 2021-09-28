--------------------------------------------------------------------------------------
-- 文件名:	CGuidTips.lua.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2015-2-27 10:10
-- 版  本:	1.0
-- 描  述:	提示界面
-- 应  用:  
---------------------------------------------------------------------------------------

CGuidTips = class("CGuidTips")
CGuidTips.__index = CGuidTips 
local rootWidget = nil
local func = nil

function CGuidTips:create()
	rootWidget = GUIReader:shareReader():widgetFromJsonFile("Game_ShowGuide.json")
	rootWidget:retain()
	
    local function onClickScreen(pSender,eventType)
        if eventType == ccs.TouchEventType.ended then
          	rootWidget:removeFromParentAndCleanup(true)
			if(func)then
				func()
				func = nil
			end
        end
    end 
    rootWidget:addTouchEventListener(onClickScreen)
	rootWidget:setTouchEnabled(true)
end

function CGuidTips:showGuidTip(widgetParent,szText, tbPos, bLeftShow, funcBack)
	if not rootWidget then 
		CGuidTips.create()
	end
	
	if rootWidget then
		rootWidget:removeFromParentAndCleanup(true)
		if widgetParent then
			widgetParent:addChild(rootWidget)
		else
			local layer = TouchGroup:create()
			layer:addWidget(rootWidget)  
			local tbCurScene = g_pDirector:getRunningScene()
			tbCurScene:addChild(layer, INT_MAX)
		end
		func = funcBack
		
		local Button_ContentLeft = rootWidget:getChildByName("Button_ContentLeft")
		local Button_ContentRight = rootWidget:getChildByName("Button_ContentRight")
		local Button_ContentLast = nil
		if bLeftShow then
			Button_ContentLeft:setVisible(true)
			Button_ContentRight:setVisible(false)
			Button_ContentLast = Button_ContentLeft
		else
			Button_ContentRight:setVisible(true)
			Button_ContentLeft:setVisible(false)
			Button_ContentLast = Button_ContentRight
		end
		
		local widgetLabel = tolua.cast(Button_ContentLast:getChildByName("Label_Speach") , "Label")
        local szContent = g_stringSize_insert(szText,"\n",widgetLabel:getFontSize(),200)
		widgetLabel:setText(szContent)
		
		local ccNodeLabel_Word = tolua.cast(widgetLabel:getVirtualRenderer(),"CCLabelTTF")
		ccNodeLabel_Word:disableShadow(true)
	
		local tbContentSize =  widgetLabel:getSize()
		local nHeight = tbContentSize.height+40
		Button_ContentLast:setSize(CCSizeMake(250, nHeight))
		widgetLabel:setPositionY(nHeight-10)
		Button_ContentLast:setPosition(tbPos)
	end
end

function CGuidTips:removeFromParent()
	if rootWidget then 
		rootWidget:removeFromParentAndCleanup(true)
		func = nil
	end
end

function CGuidTips:destroy()
	if rootWidget then 
		rootWidget:release()
		rootWidget = nil
		func = nil
	end
end