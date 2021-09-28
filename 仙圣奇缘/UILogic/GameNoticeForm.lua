---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 文件名:	GameNoticeForm.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	
-- 描  述:	游戏内滚屏通告
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------
--公告条状态
EnumNotice ={
	EnumNotice_Hide 		= 0,
	EnumNotice_Mian 		= 1,
	EnumNotice_RunScene 	= 2
}

GameNoticeForm = class("GameNoticeForm")
GameNoticeForm.__index = GameNoticeForm


function GameNoticeForm:ctor()
	self.Tag = 0xffff1111

	--滚动条模版
	self.Moudle = nil
	--主界面滚动条父窗口
	self.RootWidget = nil

	self.ECurType = EnumNotice.EnumNotice_Hide

	self.Running = false

	self.pointx = 100
	self.ponty = 600
	self.textx = 1280
	self.AnchorPoint = ccp(0,1)
end


function GameNoticeForm:InitNoticeForm(widget, RootWidget)
	if widget == nil or RootWidget == nil then
		error("GameNoticeForm:InitNoticeForm")
	end

	self.RootWidget = RootWidget

	self.Moudle = widget:clone()
	self.Moudle:retain()

end

function GameNoticeForm:GetCurState()
	return self.ECurType
end

function GameNoticeForm:GetMoudleWnd()
	if self.Moudle == nil then return nil end

	local layout = tolua.cast(self.Moudle:clone(),"Layout")
	layout:setVisible(true)
	layout:setTag(self.Tag)
	layout:setClippingEnabled(true)

	return layout
end


--在主界面显示滚屏 只用在 主界面
function GameNoticeForm:ShowWinMianNotce(ShowText)
	if self.Moudle == nil or self.ECurType ~= EnumNotice.EnumNotice_Hide or self.Running then return false end

	self.Running = true
	local widget = self.RootWidget:getChildByTag(self.Tag)
	if widget ~= nil then
		widget:removeFromParentAndCleanup(true)
		widget = nil
	end

	widget = self:GetMoudleWnd()

	local Label_SystemBrocast = tolua.cast(widget:getChildByName("Label_SystemBrocast"),"Label")
	-- Label_SystemBrocast:setAnchorPoint(ccp(0,0))
	-- Label_SystemBrocast:setText(ShowText)
	local res =  gCreateColorLable(Label_SystemBrocast, ShowText)
	if not res then return false end

	self.RootWidget:addChild(widget, 100)

	self:RunAction(Label_SystemBrocast, widget)

	self.ECurType =  EnumNotice.EnumNotice_Mian
	return true
end


--在任意界面显示滚屏
function GameNoticeForm:ShowOnlineNotice(ShowText)
	
	if self.Moudle == nil or self.ECurType ~= EnumNotice.EnumNotice_Hide or self.Running then return false end
	self.Running = true

	local widget = CCDirector:sharedDirector():getRunningScene():getChildByTag(self.Tag)
	if widget ~= nil then
		widget:removeFromParentAndCleanup(true)
		widget = nil
	end

	-- widget = self:GetMoudleWnd()
	if  not g_WidgetModel.Panel_SystemBrocast or not g_WidgetModel.Panel_SystemBrocast:isExsit()  then
		return 
	end

	widget = g_WidgetModel.Panel_SystemBrocast:clone()

	widget:setPosition(ccp(-640,240))

	local layout = Layout:create()
	layout:setPosition(self.RootWidget:getPosition())
	layout:setAnchorPoint(self.RootWidget:getAnchorPoint())
	layout:setTag(self.Tag)
	layout:addChild(widget)

	-- widget:setAnchorPoint(self.AnchorPoint)
	-- widget:setPosition(ccp(self.pointx, self.ponty))

	local Label_SystemBrocast = tolua.cast(widget:getChildByName("Label_SystemBrocast"),"Label")
	local tbLabe = gCreateColorLable(Label_SystemBrocast, ShowText)
	if not tbLabe then return false end
	-- local backtext = ""
	-- local offx = 0
	-- for k, v in ipairs(tbLabe)do
	-- 	local  labelnode = Label:create()
	-- 	labelnode:setText(v.text)
	-- 	backtext = backtext..v.text
	-- 	labelnode:setColor(v.color)

	-- 	labelnode:setFontSize(Label_SystemBrocast:getFontSize())
	-- 	labelnode:setAnchorPoint(ccp(0,0))
	-- 	if offx > 0 then
	-- 		local pos = labelnode:getPosition()
	-- 		pos.x = pos.x + offx
	-- 		labelnode:setPosition(ccp(pos.x,pos.y))
	-- 	end

	-- 	Label_SystemBrocast:addChild(labelnode)
	-- 	offx = offx + labelnode:getContentSize().width
	-- end

	-- Label_SystemBrocast:setAnchorPoint(ccp(0,0))
	-- local show = ""
	-- for i=1, g_string_num(backtext) do show = show.." " end
	-- Label_SystemBrocast:setText(show)

	CCDirector:sharedDirector():getRunningScene():addChild(layout, 100)

	self:RunAction(Label_SystemBrocast, widget)

	self.ECurType =  EnumNotice.EnumNotice_RunScene
	return true
end


function GameNoticeForm:RunAction(Label_SystemBrocast, widget)
	Label_SystemBrocast:setPosition(ccp(self.textx,0))
cclog("=============GameNoticeForm:RunAction============")
	local function actionFinish()
        if widget ~= nil then
         	widget:setVisible(false)
     	end
cclog("=============GameNoticeForm:RunAction====actionFinish========")
        g_FormMsgSystem:SendFormMsg(FormMsg_GameNotice_ActionOver, self.ECurType)

        self.ECurType = EnumNotice.EnumNotice_Hide

        self.Running = false
    end

    local num = g_string_num(Label_SystemBrocast:getStringValue())
    local endx = Label_SystemBrocast:getFontSize()*num
    local len = self.textx+endx

    local actionFadein = CCFadeIn:create(0.5)
    local actionMove = CCMoveBy:create(math.max(len/90, 1) , CCPointMake(-len,0))
	local action1 = sequenceAction({actionFadein,actionMove,CCCallFuncN:create(actionFinish)})
	
    Label_SystemBrocast:runAction(action1)
end

----------------------------
g_GameNoticeForm = GameNoticeForm.new()
