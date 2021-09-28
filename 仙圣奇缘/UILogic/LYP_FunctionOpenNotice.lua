--------------------------------------------------------------------------------------
-- 文件名:	Game_FunctionOpenNotice.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	2014-04-08 4:37
-- 版  本:	1.0
-- 描  述:	Game_FunctionOpenNotice
-- 应  用:  
---------------------------------------------------------------------------------------

Game_FunctionOpenNotice = class("Game_FunctionOpenNotice")
Game_FunctionOpenNotice.__index = Game_FunctionOpenNotice

function Game_FunctionOpenNotice:initWnd()

end

function Game_FunctionOpenNotice:showFunctionOpenMainHomeCall()
	mainWnd:showMainHomeZoomOutAnimation()
	
	--其他第三方传入的回调
	local function executeNpcGuideEndedCall(funcShowNextGuide)
		mainWnd:showHomeFunctionOpenAction(self.tbFunctionOpenLevelInStrKey.WidgetName, self.tbFunctionOpenLevelInStrKey.OpenFuncIcon, funcShowNextGuide)
	end
	
	if self.tbFunctionOpenLevelInStrKey.EndGuideID > 0 then
		if g_PlayerGuide:setCurrentGuideSequence(self.tbFunctionOpenLevelInStrKey.EndGuideID, 1) then
			g_PlayerGuide:showCurrentGuideSequenceNode(executeNpcGuideEndedCall)
		end
	end
	
end

function Game_FunctionOpenNotice:closeWnd()
	--关闭界面后显示主界面的一些功能开启的效果回调
	if self.tbFunctionOpenLevelInStrKey.WidgetName ~= "" then
		local function wndOpenFinishedCall()
			self:showFunctionOpenMainHomeCall()
		end
		g_WndMgr:openWnd("Game_Home", nil, wndOpenFinishedCall)	--窗口需要支持当窗口内容准备完毕之后的回调
	else --配置不合法
		-- do nothing
		if self.funcOpenCompleteCall then
			self.funcOpenCompleteCall()
		end
	end
end

--[[
tbParam = {
	WidgetName = "FUNCLOCK_ZHAOCAISHENFU",
	funcOpenCompleteCall
}
]]--
function Game_FunctionOpenNotice:openWnd(tbParam)
	if not tbParam then return end
	self.tbFunctionOpenLevelInStrKey = getFunctionOpenLevelCsvByStr(tbParam.WidgetName)
	self.funcOpenCompleteCall = tbParam.funcOpenCompleteCall
	
	local Image_AnimationContentPNL = tolua.cast(self.rootWidget:getChildByName("Image_AnimationContentPNL"), "ImageView")
	Image_AnimationContentPNL:removeAllNodes()
	local armature, userAnimation = nil, nil
	local function switchAnimation()
		userAnimation:playWithIndex(0)
	end
	armature, userAnimation = g_CreateCoCosAnimationWithCallBacks("FunctionOpenAnimation", nil, switchAnimation, 2, nil, true, true)
	armature:setPosition(ccp(0, 50))
	
	local boneFunctionIcon = armature:getBone("FunctionIcon")
	local CCSkin_FunctionIcon = CCSkin:create(getUIImg(self.tbFunctionOpenLevelInStrKey.OpenFuncIcon)) --后面不打包要去掉
	boneFunctionIcon:addDisplay(CCSkin_FunctionIcon,0)
	boneFunctionIcon:changeDisplayWithIndex(0, true)
	local boneFunctionName = armature:getBone("FunctionName")
	local CCSkin_FunctionName = CCSkin:create(getUIImg(self.tbFunctionOpenLevelInStrKey.OpenFuncNamePic)) --后面不打包要去掉
	boneFunctionName:addDisplay(CCSkin_FunctionName,0)
	boneFunctionName:changeDisplayWithIndex(0, true)
	
	Image_AnimationContentPNL:addNode(armature)
	userAnimation:playWithIndex(1)
end

function g_ShowFunctionOpenAnimtionByLevel(nOpenLevel, funcEndCallBack)
	local strWidgetName = g_DataMgr:getFunctionOpenLevelCsv(nOpenLevel, 1).WidgetName
	local tbFunctionOpenLevelInStrKey = getFunctionOpenLevelCsvByStr(strWidgetName)
	if tbFunctionOpenLevelInStrKey.IsNeedOpenAni == 1 then
		local tbParam = {
			WidgetName = strWidgetName,
			funcOpenCompleteCall = funcEndCallBack,
		}
		g_WndMgr:showWnd("Game_FunctionOpenNotice", tbParam)
	else
		if tbFunctionOpenLevelInStrKey.EndGuideID > 0 then
			if g_PlayerGuide:setCurrentGuideSequence(tbFunctionOpenLevelInStrKey.EndGuideID, 1) then
				g_PlayerGuide:showCurrentGuideSequenceNode()
			end
		end
	end
end