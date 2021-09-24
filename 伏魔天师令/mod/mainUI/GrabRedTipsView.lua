local GrabRedMediator=classGc(mediator,function(self,_view)
    self.name = "GrabRedMediator"
    self.view = _view
    self:regSelf()
end)
GrabRedMediator.protocolsList={
    -- _G.Msg.ACK_HONGBAO_SHUTDOWN,
    _G.Msg.ACK_HONGBAO_GET_REWARDS_CB,
}
GrabRedMediator.commandsList=nil
-- function GrabRedMediator.ACK_HONGBAO_SHUTDOWN(self,_ackMsg)
-- 	self.view:CloseRedView()
-- end
function GrabRedMediator.ACK_HONGBAO_GET_REWARDS_CB(self,_ackMsg)
	self.view:SuccReward(_ackMsg)
end

local GrabRedTipsView=classGc(view,function(self,_data)
	self.SchedNum = 1
	self.count=1
	self.playerName = {}
	self.GrabNum = {}
	self.State = {}
	self.Index = {}
	self.data = _data
end)
 
local winSize  = cc.Director : getInstance() : getVisibleSize()
-- local grabSize = cc.size(600,32)

function GrabRedTipsView.create(self)
	self.pMediator=GrabRedMediator(self)

	self.grabredSpr = ccui.Scale9Sprite:createWithSpriteFrameName("general_voice_dins.png")
	self.grabredSpr : setPosition(winSize.width/2,winSize.height/2+30)

	self:pushdata(self.data)
	return self.grabredSpr
end

function GrabRedTipsView.pushdata( self, _data )
	print("GrabRedTipsView-->",_data.name,_data.money,_data.is,_data.idx,self.SchedNum)
	if self.Index[self.SchedNum-1]==_data.idx then print("return")return end
	self.playerName[_data.idx]=_data.name
	self.GrabNum[_data.idx]=_data.jifen
	self.State[_data.idx]=_data.is
	self.Index[self.SchedNum]=_data.idx
	if self.SchedNum==1 then
		print("创建红包",self.count)
		self:__registerSchedule()
		if self.count==1 then
			print("GrabRedTipsView.__registerSchedule------>>>> 11",self.count)
			self:GrabRedView(self.Index[self.count])
			self.count=self.count+1
		end
	end
	self.SchedNum=self.SchedNum+1
end

function GrabRedTipsView.GrabRedView( self, idx)
	print("GrabRedView-->",idx)
	
	if self.State[idx]~=1 then
    	self.grabredSpr:setVisible(false)
    end

	local LabNode = cc.Node:create()

	local tipsLab1=_G.Util:createLabel("土豪",20)
	tipsLab1:setPosition(0,17)
	tipsLab1:setAnchorPoint(cc.p(0,0.5)) 
	LabNode:addChild(tipsLab1)

	local tipsWidth = tipsLab1:getContentSize().width
	local nameLab=_G.Util:createLabel(self.playerName[idx] or "逗比",20)
	nameLab:setPosition(tipsWidth,17)
	nameLab:setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
	nameLab:setAnchorPoint(cc.p(0,0.5)) 
	LabNode:addChild(nameLab)

	local tipsWidth = tipsWidth+nameLab:getContentSize().width
	local tipsLab2=_G.Util:createLabel("发出了总额",20)
	tipsLab2:setPosition(tipsWidth,17)
	tipsLab2:setAnchorPoint(cc.p(0,0.5)) 
	LabNode:addChild(tipsLab2)

	local tipsWidth = tipsWidth+tipsLab2:getContentSize().width
	local redbaoLab=_G.Util:createLabel(self.GrabNum[idx] or 100000,20)
	redbaoLab:setPosition(tipsWidth,17)
	redbaoLab:setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
	redbaoLab:setAnchorPoint(cc.p(0,0.5)) 
	LabNode:addChild(redbaoLab)

	local tipsWidth = tipsWidth+redbaoLab:getContentSize().width
	local tipsLab3=_G.Util:createLabel("积分红包，速度抢啊！           ",20)
	tipsLab3:setPosition(tipsWidth,17)
	tipsLab3:setAnchorPoint(cc.p(0,0.5)) 
	LabNode:addChild(tipsLab3)

	local function touchEvent( sender,eventType )
		if eventType == ccui.TouchEventType.ended then
			print("领取红包",idx)
			local msg = REQ_HONGBAO_GET_REWARDS()
			msg : setArgs(idx)
			_G.Network : send(msg)
			self:CloseRedSpr()
		end
	end

	tipsWidth=tipsWidth+tipsLab3:getContentSize().width+30
	local grabredBtn = gc.CButton:create("general_btn_hongbao.png")
	grabredBtn : setPosition(tipsWidth, 17)
	-- grabredBtn : setButtonScale(1.5)
	grabredBtn : addTouchEventListener(touchEvent)
	grabredBtn : ignoreContentAdaptWithSize(false)
    grabredBtn : setContentSize(cc.size(100,100))
	LabNode : addChild(grabredBtn)

	LabNode:setPosition(5,0)
	self.grabredSpr:addChild(LabNode)

	self.grabredSpr : setPreferredSize(cc.size(tipsWidth,35))
end

function GrabRedTipsView.__registerSchedule( self )
	if self.m_mySchedule ~= nil then
		return
	end

	local function local_updateFun()
		if self.Index[self.count]~=nil then
			print("GrabRedTipsView.__registerSchedule------>>>> 22",self.count)
			self:CloseRedSpr()
			self:GrabRedView(self.Index[self.count])
			self.count=self.count+1
		else
			print("GrabRedTipsView.__registerSchedule------>>>> 33",self.count)
			self:CloseRedView()
		end
	end

	self.m_mySchedule=_G.Scheduler:schedule(local_updateFun,3)
end

function GrabRedTipsView.unregisterSchedule( self )
	print("GrabRedTipsView.unregisterSchedule------>>>>")
	if self.m_mySchedule~=nil then
		_G.Scheduler:unschedule(self.m_mySchedule)
		self.m_mySchedule=nil
	end
end

function GrabRedTipsView.SuccReward( self, _data )
	local command=CErrorBoxCommand({t={ {t=[[恭喜您抢到]],c=_G.Const.CONST_COLOR_WHITE},
	                                    {t=_data.name,c=_G.Const.CONST_COLOR_GRASSGREEN},
	                                    {t=[[的]],c=_G.Const.CONST_COLOR_WHITE},
	                                    {t=_data.jifen,c=_G.Const.CONST_COLOR_ORED},
	                                    {t=[[红包积分]],c=_G.Const.CONST_COLOR_WHITE},
	                                   }
	                                })
	_G.controller:sendCommand(command)

	-- local command=CErrorBoxCommand(string.format("恭喜您抢到%s的%d红包积分",_data.name,_data.jifen))
 --    controller:sendCommand(command) 
end

function GrabRedTipsView.CloseRedView( self )
	print("关闭抢红包")
	self:unregisterSchedule()
	self:unregister()
	self:CloseRedSpr()
end

function GrabRedTipsView.CloseRedSpr( self )
	if self.grabredSpr~=nil then
		print("换另一个")
		self.grabredSpr:removeFromParent(true)
		self.grabredSpr=nil
	end
end

function GrabRedTipsView.unregister(self)
   self.pMediator : destroy()
   self.pMediator = nil 
end

return GrabRedTipsView