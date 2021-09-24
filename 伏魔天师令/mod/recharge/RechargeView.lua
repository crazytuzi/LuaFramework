local RechargeView = classGc(view, function(self, _panelType)
	self.pMediator = require("mod.recharge.RechargeMadiator")()
    self.pMediator : setView(self)
	self.m_panelType = _panelType
	self.addRowNo 	= 0 -- 第几行
	self.addColum 	= 0 -- 第几列
end)

local FONTSIZE = 20
local R_ROWNO = 3 --列数
local rdownSize = cc.size(620,430)

function RechargeView.create(self)
	self.m_container = cc.Node:create()
	
	local floorSpr  = ccui.Scale9Sprite : createWithSpriteFrameName("general_gold_floor.png")
    floorSpr        : setPreferredSize(cc.size(rdownSize.width+2,rdownSize.height+10))
    floorSpr        : setPosition(110, -80)
    self.m_container : addChild(floorSpr)

	self.Widget = ccui.Widget:create()
    self.Widget : setContentSize(rdownSize)
    self.Widget : setPosition(110,-80)
    self.m_container : addChild(self.Widget)

	local isTru=_G.SysInfo:isAppStoreChannel()
	local AppType=1
	if isTru then
		AppType=2
	end
	local msg = REQ_ART_CHARG_REQUEST()
	msg :setArgs(AppType)
    _G.Network :send( msg )
	return self.m_container
end

function RechargeView.pushData(self, _data)
	self.oneLab 	= {1,2,3,4,5,6}
	self.loginSpr 	= {1,2,3,4,5,6}
	self.goldSpr	= {}
	self.goldupLab	= {}

	local ScrollView  = cc.ScrollView : create()
	self.m_ScrollView=ScrollView
	local mmmm      = math.ceil(_data.count/R_ROWNO)
    self.containerSize = cc.size(rdownSize.width, rdownSize.height/2*mmmm)
	ScrollView      : setDirection(ccui.ScrollViewDir.vertical)
    ScrollView      : setPosition(cc.p(0,0))
    ScrollView      : setViewSize(rdownSize)
    ScrollView      : setContentSize(self.containerSize)
    ScrollView      : setContentOffset( cc.p( 0, rdownSize.height-self.containerSize.height))
    ScrollView      : setBounceable(false)
    ScrollView      : setTouchEnabled(true)
    ScrollView      : setDelegate()
    self.Widget : addChild(ScrollView,10)

    for i=1,_data.count do
	    self:OneRechargeSpr(i,_data.msg[i])
	end

    if _data.count==6 then
    	ScrollView  : setTouchEnabled(false)
    else
    	local barView=require("mod.general.ScrollBar")(ScrollView)
    end    
end

function RechargeView.OneRechargeSpr( self,i,_msg )
	print("OneRechargeSpr",self.addRowNo,_msg.rmb,_msg.per)
	
	if i % R_ROWNO == 1 then
        self.addColum = 0
        self.addRowNo = self.addRowNo + 1
    end
    self.addColum   = self.addColum + 1
	local function WidgetCallback(sender, eventType)
		self : onWidgetCallBack(sender, eventType)
	end
	self.loginSpr[_msg.rmb] = ccui.Button : create("general_shopkuang.png","general_shopkuang.png","general_shopkuang.png",1)
	local loginSize  = self.loginSpr[_msg.rmb] : getContentSize()
	-- self.loginSpr[_msg.rmb] : setPreferredSize(cc.size(loginSize.width-4, loginSize.height))
	
    local posX = rdownSize.width/4-50+205*(self.addColum-1)
    local posY = self.containerSize.height-rdownSize.height/2*(self.addRowNo-1)-rdownSize.height/4

    self.loginSpr[_msg.rmb] : setPosition(posX,posY)
	self.m_ScrollView : addChild(self.loginSpr[_msg.rmb])

	self.loginSpr[_msg.rmb] : setSwallowTouches(false)
	self.loginSpr[_msg.rmb] : setTag(_msg.rmb)
	self.loginSpr[_msg.rmb] : addTouchEventListener(WidgetCallback)

	local goldImg = {}
	goldImg[i] 	  = ccui.Scale9Sprite : createWithSpriteFrameName("vip_gold_"..i..".png")
	goldImg[i] 	  : setPosition(loginSize.width/2, loginSize.height/2)
	self.loginSpr[_msg.rmb]   : addChild(goldImg[i])
	
	self.rmbcount = _msg.rmb/10
	
	self.goldSpr[_msg.rmb] = ccui.Scale9Sprite : createWithSpriteFrameName("general_xianYu.png")
	self.goldSpr[_msg.rmb] : setPosition(loginSize.width/2-20, loginSize.height-18)
	self.loginSpr[_msg.rmb] : addChild(self.goldSpr[_msg.rmb])

	local goldLab= {}
	local e_info = {_msg.rmb,"￥".._msg.rmb/10}
	local e_poY = {loginSize.height-22, 18}
	self.goldupLab[_msg.rmb] = _G.Util : createLabel(_msg.rmb, FONTSIZE)
	-- self.goldupLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BRIGHTYELLOW))
	self.goldupLab[_msg.rmb] : setPosition(loginSize.width/2, loginSize.height-20)
	self.goldupLab[_msg.rmb] : setAnchorPoint( cc.p(0.0,0.5) )
	self.loginSpr[_msg.rmb] : addChild(self.goldupLab[_msg.rmb])

	-- local ORANGE = _G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_OSTROKE)
	local golddownLab = _G.Util : createLabel("￥".._msg.rmb/10, FONTSIZE)
	-- golddownLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BRIGHTYELLOW))
	golddownLab : setPosition(loginSize.width/2,18)
	self.loginSpr[_msg.rmb] : addChild(golddownLab)

	-- local wingGoods= _G.GBagProxy:getGoodsCountById(64000)
	-- if wingGoods>0 then
	-- 	local loginSize  = self.loginSpr[self.m_yuanbaoNums[i]] : getContentSize()
	-- 	self.goldSpr[i] : setPosition(loginSize.width/2-50, loginSize.height-20)
	-- 	self.goldupLab[i]  : setPosition(loginSize.width/2-30, loginSize.height-22)
	-- 	self.goldupLab[i]  : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_RED))
	-- 	local labSize  = self.goldupLab[i]  : getContentSize()
	-- 	local line = cc.DrawNode : create()--绘制线条
	-- 	line 	 : drawLine(cc.p(0,2), cc.p(labSize.width+8,2), cc.c4f(0.6,0.2,0.3,1))
	-- 	line     : setPosition(loginSize.width/2-34, loginSize.height-22)
	-- 	self.loginSpr[self.m_yuanbaoNums[i]]  : addChild(line,2)

	-- 	local num=zheNum+zheyuNum/10
	-- 	local fanbeiLab = _G.Util : createLabel(self.m_yuanbaoNums[i]*2, FONTSIZE)
	-- 	fanbeiLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BRIGHTYELLOW))
	-- 	fanbeiLab : setPosition(loginSize.width/2-30+labSize.width+30, loginSize.height-22)
	-- 	self.loginSpr[self.m_yuanbaoNums[i]] : addChild(fanbeiLab)
	-- end

	local zheNum   = math.floor(_msg.per/10000+1)
	local zheyuNum = math.fmod(_msg.per/10000+1,1)*10
	print("zheNum",zheNum,zheyuNum)
	if zheNum>1 and self.loginSpr[_msg.rmb]~=nil then
		local beiSpr = cc.Sprite : createWithSpriteFrameName("vip_bei.png")
		beiSpr : setPosition(36, 176)
		self.loginSpr[_msg.rmb] : addChild(beiSpr)

		local beishuLab = _G.Util : createLabel(string.format("%d 倍",zheNum), FONTSIZE)
		beishuLab : setPosition(24,38)
		beishuLab : setRotation(-44)
		beiSpr : addChild(beishuLab)

		if zheyuNum>0 then
			beishuLab:setString(string.format("%d.%d倍",zheNum,zheyuNum))
		end

		-- local wingGoods= _G.GBagProxy:getGoodsCountById(64000)
		-- if wingGoods>0 then
		self.goldSpr[_msg.rmb] : setPosition(loginSize.width/2-50, loginSize.height-18)
		self.goldupLab[_msg.rmb]  : setPosition(loginSize.width/2-30, loginSize.height-20)
		self.goldupLab[_msg.rmb]  : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))

		local labSize  = self.goldupLab[_msg.rmb]  : getContentSize()
		local line = cc.DrawNode : create()--绘制线条
		line 	 : drawLine(cc.p(0,2), cc.p(labSize.width+8,2), cc.c4f(0.6,0.2,0,1))
		line     : setPosition(loginSize.width/2-34, loginSize.height-20)
		self.loginSpr[_msg.rmb]  : addChild(line,2)

		local num=zheNum+zheyuNum/10
		local fanbeiLab = _G.Util : createLabel(_msg.rmb*num, FONTSIZE)
		-- fanbeiLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BRIGHTYELLOW))
		fanbeiLab : setPosition(loginSize.width/2-30+labSize.width+30, loginSize.height-20)
		self.loginSpr[_msg.rmb] : addChild(fanbeiLab)
		-- end
	end
end

function RechargeView.onWidgetCallBack(self, sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		print("弹出充值框")

		if _G.SysInfo:isAppStoreChannel() then
			local isRecharge=gc.UserCache:getInstance():getObject("APPSTORE_ISRECHARGE")
			if isRecharge and isRecharge=="1" then
				local command=CErrorBoxCommand("请稍等,充值正在处理中。")
				controller : sendCommand( command )
				return
			end
		end
			
		local spr_tag	= sender : getTag()
		local money = math.floor(spr_tag/10)
	    print("选中role_tag:", spr_tag,money)
	    local function sure(_state)
			print("充值界面",_state)
			if _state==false then
				local msg = REQ_SYSTEM_PAY_CHECK()
				msg       : setArgs(0)
	        	_G.Network :send( msg )
	        else
	        	local msg = REQ_SYSTEM_PAY_CHECK()
				msg       : setArgs(1)
	        	_G.Network :send( msg )
	        end

        	gc.UserCache:getInstance():setRechargeMoney(tostring(money))
		end

	    local boxView=_G.Util : showTipsBox("跳转到充值界面？",sure)
	    if _G.GBagProxy:getGoodsCountById(64000)>0 then
	    	local bagdata = _G.GBagProxy : getPropsList()
	    	local nowtime = _G.TimeUtil:getServerTimeSeconds()
		    for k,v in pairs(bagdata) do
		    	print("是否使用财神卡？",v.goods_id,nowtime,v.expiry)
		    	if v.goods_id==64000 and v.expiry >= nowtime then
		    		boxView:showNeverNotic("是否使用财神卡？")
		    	end
		    end
	    end
	end
end

---------------------协议返回-------------------

function RechargeView.rechargeMoney( self )
    print("转入充值网页")
   --  local command = CloseWindowCommand(_G.Const.CONST_FUNC_OPEN_RECHARGE)
  	-- controller :sendCommand( command )
    gc.SDKManager:getInstance():recharge()
end

function RechargeView.rechargeData(self, _ackMsg )
	print("充值获得：", _ackMsg.msg_xxx[self.rmbcount])
    if _ackMsg.count ~= nil and  _ackMsg.count > 0 then
	    local twoStr = "充值获得"..self.m_yuanbaoNums[self.rmbcount].."元宝"
		self.oneLab[self.rmbcount] : setString(twoStr)
    end
end

function RechargeView.unregister(self)
   self.pMediator : destroy()
   self.pMediator = nil 
end

return RechargeView