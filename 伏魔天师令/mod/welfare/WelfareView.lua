local winSize  = cc.Director : getInstance() : getVisibleSize()
local ONLINE       = 1
local DAYWELFARE   = 2
local CHIBAOZI	   = 3
local EXCHANGE     = 4

local WelfareView = classGc(view, function(self,_subType)
	self.pMediator = require("mod.welfare.WelfareMadiator")()
    self.pMediator : setView(self)
    self.welfareType = _subType or ONLINE
end)

function WelfareView.create(self)
	self.welfareView = require("mod.general.TabLeftView")()
  	self.m_rootLayer  = self.welfareView : create("福 利")

  	local tempScene=cc.Scene:create()
    tempScene:addChild(self.m_rootLayer)

  	self : initView()
	return tempScene
end

function WelfareView.initView( self )
	local closeBtn = self.welfareView : getCloseBtn()

	local WelfareNode = cc.Node:create()
	WelfareNode : setPosition(winSize.width*0.5,winSize.height*0.5)
	self.m_rootLayer : addChild(WelfareNode)

	local function closeFunRecharge()
		self : closeWindow()
	end
	local function tabOfFun(tag)
		self : tabOperate(tag)
	end
	self.welfareView : addCloseFun(closeFunRecharge)
	self.welfareView : addTabFun(tabOfFun)
	self.welfareView : addTabButton("在 线 奖 励", ONLINE)
	self.welfareView : addTabButton("签 到 福 利", DAYWELFARE)
	self.welfareView : addTabButton("领 取 体 力", CHIBAOZI)
	if _G.GOpenProxy:showSysNoOpenTips(_G.Const.CONST_FUNC_OPEN_NOVICE,true)==false then
		self.welfareView : addTabButton("兑 换 礼 包", EXCHANGE)
	end

	self.leftBtn      = {1,2,3,4}	
	self.tagContainer = {1,2,3,4}
	self.tagPanel 	  = {}
	self.tagPanelClass= {}
	
	for i=1,4 do	
		self.leftBtn[i] = self.welfareView:getObjByTag(i)
		self.tagContainer[i] = cc.Node:create()
    	WelfareNode : addChild(self.tagContainer[i])
	end

	-- 默认页面
	self.welfareView : selectTagByTag(self.welfareType)
	self : initViewData(self.welfareType, true)

	local guideId=_G.GGuideManager:getCurGuideId()
	if guideId==_G.Const.CONST_NEW_GUIDE_SYS_SIGN then
		local tabBtn=self.welfareView:getObjByTag(DAYWELFARE)
		local closeBtn=self.welfareView:getCloseBtn()
		_G.GGuideManager:initGuideView(self.m_rootLayer)
		_G.GGuideManager:registGuideData(1,tabBtn)
		_G.GGuideManager:registGuideData(3,closeBtn)
		_G.GGuideManager:runNextStep()
		self.m_guideTab=DAYWELFARE

		_G.Util:playAudioEffect("sys_reward")

		local command=CGuideNoticHide()
      	controller:sendCommand(command)
	end
end

function WelfareView.guideDelete(self,_guideId)
	if _guideId==_G.Const.CONST_NEW_GUIDE_SYS_SIGN and self.m_guideTab then
		_G.GGuideManager:runThisStep(3)
	end
end

function WelfareView.tabOperate( self, _tag )
	print("SettingView --- tag --->",_tag)

	for i=1,4 do
        if i ~= _tag then
            print("self.tagContainer setVisible false----------",i)
            self.tagContainer[i] : setVisible(false)
        else
            print("self.tagContainer setVisible true--------",i)
            self.tagContainer[i] : setVisible(true)
            self : initViewData(i,true)
        end
    end
end

function WelfareView.initViewData( self,_tag,_isVisible )
  	if self.tagPanel[_tag] == nil then
    	print("创建 panel type visible",_tag,_isVisible)
    	local view = nil
    	if _tag == ONLINE then
    		view = require "mod.welfare.OlineBonusView"()
    	elseif _tag == DAYWELFARE then
    		view = require "mod.welfare.DayWelfareView"()
    	elseif _tag == CHIBAOZI then
    		view = require "mod.welfare.ChiBaoZiView"()
    	elseif _tag == EXCHANGE then
    		view = require "mod.welfare.CardView"()	
    	end
    	if view == nil then return end

    	self.tagPanelClass[_tag] = view
    	self.tagPanel[_tag] = view : create ()
    	print("_tag值", _tag)
    	self.tagContainer[_tag] : addChild(self.tagPanel[_tag])
    	
    	self.tagContainer[_tag] : setVisible(true)       
  	end

  	if self.m_guideTab~=nil then
		if _tag==self.m_guideTab then
			_G.GGuideManager:showGuideByStep(2)
		else
			_G.GGuideManager:hideGuideByStep(2)
		end
	end
end

function WelfareView.closeWindow(self, sender, eventType)
	print("关闭")
	if self.m_rootLayer == nil then return end
    self.m_rootLayer=nil
	cc.Director:getInstance():popScene()
	self : timeunschedule()
	self : unregister()

	if self.m_guideTab then
		local command=CGuideNoticShow()
      	controller:sendCommand(command)
	end
end

function WelfareView.numData(self, _data)
	print("更新角标",_data.num1,_data.num2,_data.num3)
	self.welfareView : setTagIconNum(ONLINE,_data.num1)
	self.welfareView : setTagIconNum(DAYWELFARE,_data.num2)
	self.welfareView : setTagIconNum(CHIBAOZI,_data.num3)
end

function WelfareView.timeunschedule( self )
	if self.tagPanelClass[ONLINE]==nil then return end
	self.tagPanelClass[ONLINE] : uncountdownEvent()
end

function WelfareView.onlineData(self, _ackMsg)
	self.tagPanelClass[ONLINE] : onlineData(_ackMsg)
	local msg  = REQ_REWARD_BEGIN()
    _G.Network : send( msg )
end

function WelfareView.dailyData(self, _ackMsg)
	self.tagPanelClass[DAYWELFARE] : dailyData(_ackMsg)
end

function WelfareView.cardData(self, _ackMsg)
	self.tagPanelClass[EXCHANGE] : cardData(_ackMsg)
end

function WelfareView.Success(self)
	self.tagPanelClass[CHIBAOZI] : Success()
end

function WelfareView.unregister(self)
    if self.pMediator ~= nil then
        self.pMediator : destroy()
        self.pMediator = nil 
    end
end

return WelfareView