--------------------------------------------------------------------------------------
-- 文件名:	Class_Fate.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	周光剑
-- 日  期:	2015-6-30
-- 版  本:	1.0
-- 描  述:	精英副本Form
-- 应  用:  
---------------------------------------------------------------------------------------

Game_JiHuiSuo = class("Game_JiHuiSuo")
Game_JiHuiSuo.__index = Game_JiHuiSuo

function Game_JiHuiSuo:setCursor(tbData)
	self.cursor:setVisible(tbData.bVisible)
	if tbData.pos then
		self.cursor:setPosition(tbData.pos)
	end
end

function Game_JiHuiSuo:onClickFloor(widget, eventType)
	if ccs.TouchEventType.ended == eventType then
		local pos = widget:getTouchEndPos()
		pos.x = pos.x - self.Image_Floor:getPositionX()	
		g_RoleSystem:myMove(pos)
		
		if g_PlayerGuide:checkCurrentGuideSequenceNode("ActionEventStart", "Game_JiHuiSuo") then
			g_PlayerGuide:showCurrentGuideSequenceNode()
		end
	end
end

function Game_JiHuiSuo:initWnd()
	g_RoleSystem:init(self.rootWidget)
	self.Image_Background = self.rootWidget:getChildAllByName("Image_Background")
	self.Image_Floor = self.rootWidget:getChildAllByName("Image_Floor")
	self.Image_Floor:setTouchEnabled(true)
	self.Image_Floor:addTouchEventListener(handler(self, self.onClickFloor))

	--光标
	local userAnimation
	self.cursor, userAnimation = g_CreateCoCosAnimationWithCallBacks("DestinationArrow", nil, nil, 5, nil, nil, false)
	userAnimation:playWithIndex(0)
	self.cursor:setVisible(false)
	self.cursor:setZOrder(INT_MAX)
	self.Image_Floor:addNode(self.cursor)
	

	--注册消息
	g_FormMsgSystem:RegisterFormMsg(FormMsg_Movement_Cursor, handler(self, self.setCursor))
	
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	local Image_Texture1 = tolua.cast(Image_Background:getChildByName("Image_Texture1"), "ImageView")
	Image_Texture1:loadTexture(getBackgroundJpgImg("JiHuiSuo"))
	local Image_Texture2 = tolua.cast(Image_Background:getChildByName("Image_Texture2"), "ImageView")
	Image_Texture2:loadTexture(getBackgroundJpgImg("JiHuiSuo"))
	
	local Image_Floor = tolua.cast(self.rootWidget:getChildByName("Image_Floor"), "ImageView")
	local Image_Texture1 = tolua.cast(Image_Floor:getChildByName("Image_Texture1"), "ImageView")
	Image_Texture1:loadTexture(getBackgroundPngImg("JiHuiSuo"))
	local Image_Texture2 = tolua.cast(Image_Floor:getChildByName("Image_Texture2"), "ImageView")
	Image_Texture2:loadTexture(getBackgroundPngImg("JiHuiSuo"))
end

function Game_JiHuiSuo:checkData()
	if not self.bFirst then
		self.bFirst = true
		-- 进入之前先向服务端请求离开场景以免卡住
		g_RoleSystem:requestExit()
		g_RoleSystem:requestEnter(macro_pb.SceneType_Guild)
		return false
	end
	return true
end

function Game_JiHuiSuo:openWnd()
	self.Image_Background:setPositionX(0)
	self.Image_Floor:setPositionX(0)
end

function Game_JiHuiSuo:closeWnd()
	g_RoleSystem:requestExit()
	g_RoleSystem:destroy()
	
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	local Image_Texture1 = tolua.cast(Image_Background:getChildByName("Image_Texture1"), "ImageView")
	Image_Texture1:loadTexture(getUIImg("Blank"))
	local Image_Texture2 = tolua.cast(Image_Background:getChildByName("Image_Texture2"), "ImageView")
	Image_Texture2:loadTexture(getUIImg("Blank"))
	
	local Image_Floor = tolua.cast(self.rootWidget:getChildByName("Image_Floor"), "ImageView")
	local Image_Texture1 = tolua.cast(Image_Floor:getChildByName("Image_Texture1"), "ImageView")
	Image_Texture1:loadTexture(getUIImg("Blank"))
	local Image_Texture2 = tolua.cast(Image_Floor:getChildByName("Image_Texture2"), "ImageView")
	Image_Texture2:loadTexture(getUIImg("Blank"))
end

