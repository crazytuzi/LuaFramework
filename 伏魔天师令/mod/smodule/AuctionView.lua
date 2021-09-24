local AuctionView   = classGc(view,function ( self )
	self.m_winSize       = cc.Director : getInstance() : getVisibleSize()
	self.m_leftUpSize    = cc.size(520,325)
	self.m_leftDownSize  = cc.size(520,120)
	self.m_rightUpSize   = cc.size(255,325)
	self.m_rightDownSize = cc.size(255,120)
end)

local COLOR_GREEN = _G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_GRASSGREEN)
local COLOR_BLUE_L = _G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_LBLUE)
local COLOR_ORED    = _G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_ORED)

function AuctionView.create(self)
    self : __init()

    self.m_normalView = require("mod.general.NormalView")()
	self.m_rootLayer  = self.m_normalView:create()

	local tempScene=cc.Scene:create()
    tempScene:addChild(self.m_rootLayer)
	
	self  			  : __initView()
	
    return tempScene
end

function AuctionView.__init(self)
    self : register()
end

function AuctionView.register(self)
    self.pMediator = require("mod.smodule.AuctionMediator")(self)
end
function AuctionView.unregister(self)
    self.pMediator : destroy()
    self.pMediator = nil 
end

function AuctionView.__initView( self )
	local function nCloseFun()
		print("成功删除背景")
		self : __closeWindow()
	end
	self.m_normalView : addCloseFun(nCloseFun)
	self.m_normalView : setTitle("竞拍")
	--self.m_normalView : showSecondBg()

	local dins = cc.Sprite:create("ui/bg/aution_bg.png")
	dins       : setPosition(cc.p(self.m_rootLayer:getContentSize().width/2,278))
	self.m_rootLayer: addChild(dins)
	self.dinsSize=dins:getContentSize()

	self.grildSpr=_G.ImageAsyncManager:createNormalSpr("icon/guide_grild.png")
	self.grildSpr:setPosition(cc.p(150,290))
	self.grildSpr:setVisible(false)
	-- self.grildSpr:setScaleX(-1)
	dins: addChild(self.grildSpr)

	local function explainEvent( send,eventType )
    	if eventType == ccui.TouchEventType.ended then
    		print("说明")
    		local explainView  = require("mod.general.ExplainView")()
			local explainLayer = explainView : create(40220)
    	end
    end

    local explainButton = gc.CButton:create()
	explainButton : addTouchEventListener(explainEvent)
	explainButton : loadTextures("general_help.png")
	explainButton : setTitleText("")
	explainButton : setTitleFontSize(24)
	explainButton : setTitleFontName(_G.FontName.Heiti)
	explainButton : setPosition(self.dinsSize.width-55,self.dinsSize.height-35)
	dins : addChild(explainButton)

    local function auctionEvent( sender,eventType )
    	if eventType == ccui.TouchEventType.ended then
    		print("竞拍")
    		local msg = REQ_AUCTION_AUCTION()
    		msg       : setArgs(self.id)
    		_G.Network: send(msg)
    		sender : setEnabled(false)
    		sender : setGray()
    		sender : runAction(cc.Sequence : create(cc.DelayTime : create(1),cc.CallFunc : create(function ()
    			sender : setEnabled(true)
    			sender : setDefault()
    		end)))
    	end
    end

    local auctionButton = gc.CButton:create()
	auctionButton : addTouchEventListener(auctionEvent)
	auctionButton : loadTextures("general_btn_gold.png")
	auctionButton : setTitleText("竞 拍")
	auctionButton : setTitleFontSize(24)
	auctionButton : setTitleFontName(_G.FontName.Heiti)
	auctionButton : setPosition(self.dinsSize.width/2,65)
	dins : addChild(auctionButton)

	self.btn = auctionButton

	local tipLab  = _G.Util : createLabel("元宝不足会自动使用钻石竞拍哦!",18)
	tipLab        : setColor(COLOR_ORED)
	tipLab        : setPosition(cc.p(self.dinsSize.width/2,25))
	dins : addChild(tipLab)

	local starTime  = _G.Util : createLabel("开始时间: ",20)
	starTime        : setAnchorPoint(cc.p(0,0.5))
	starTime        : setPosition(35,self.dinsSize.height-40)
	dins : addChild(starTime)

	local beginTime  = _G.Util : createLabel("18:30",20)
	beginTime        : setAnchorPoint(cc.p(0,0.5))
	beginTime        : setColor(COLOR_ORED)
	beginTime        : setPosition(35+starTime:getContentSize().width,self.dinsSize.height-40)
	dins : addChild(beginTime)

	self.BuyLab = _G.Util : createLabel("",20)
	-- self.BuyLab : setColor(COLOR_GREEN)
	self.BuyLab : setPosition(cc.p(self.dinsSize.width-190,92))
	dins : addChild(self.BuyLab)

	self.YuanBao = _G.Util : createLabel("元宝: ",20)
	self.YuanBao : setAnchorPoint(cc.p(0,0.5))
	self.YuanBao : setPosition(cc.p(self.dinsSize.width-200,65))
	self.YuanBao : setVisible(false)
	dins : addChild(self.YuanBao)

	self.XianYu = _G.Util : createLabel("钻石: ",20)
	self.XianYu : setAnchorPoint(cc.p(0,0.5))
	self.XianYu : setPosition(cc.p(self.dinsSize.width-200,40))
	self.XianYu : setVisible(false)
	dins : addChild(self.XianYu)

	self.YuanBaoNumLab = _G.Util : createLabel("",20)
	self.YuanBaoNumLab : setAnchorPoint(cc.p(0,0.5))
	self.YuanBaoNumLab : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
	self.YuanBaoNumLab : setPosition(cc.p(self.dinsSize.width-200+self.YuanBao:getContentSize().width,65))
	dins : addChild(self.YuanBaoNumLab)

	self.XianYuNumLab = _G.Util : createLabel("",20)
	self.XianYuNumLab : setAnchorPoint(cc.p(0,0.5))
	self.XianYuNumLab : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_GRASSGREEN))
	self.XianYuNumLab : setPosition(cc.p(self.dinsSize.width-200+self.YuanBao:getContentSize().width,40))
	dins : addChild(self.XianYuNumLab)

	self.dins=dins

	self.cardArray = {}
	for i=1,3 do
		self : __createCard(i) 
	end

	local msg = REQ_AUCTION_REQUEST()
	_G.Network: send(msg)
end

function AuctionView.__createCard( self,i )
	local card = cc.Sprite : createWithSpriteFrameName("auction_shopkuang.png")
	local cardSize=card:getContentSize()
	card       : setPosition(cardSize.width/2+5 + (i-1)*(cardSize.width+10),self.dinsSize.height/2+30) 
	if i == 1 or i==3 then
		card  : setScale(0.8)
	end
	self.dins : addChild(card)

	self.cardArray[i] = {}
	self.cardArray[i].card = card

	local fontSize = 20
	local goodsName= _G.Util : createBorderLabel("",fontSize,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
	goodsName      : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
	goodsName      : setPosition(cardSize.width/2,cardSize.height-20)
	card           : addChild(goodsName,1)

	self.cardArray[i].goodsName = goodsName

	local goodsDins= cc.Sprite : createWithSpriteFrameName("general_tubiaokuan.png")
	goodsDins      : setPosition(cardSize.width/2,cardSize.height-96)
	card           : addChild(goodsDins,1)

	local goodsIcon= cc.Sprite : createWithSpriteFrameName("general_tubiaokuan.png")
	goodsIcon      : setPosition(cardSize.width/2,cardSize.height-96)
	card           : addChild(goodsIcon,2) 

	self.cardArray[i].goodsIcon = goodsIcon

	local expDins = cc.Sprite : createWithSpriteFrameName("aution_expbg.png")
	expDins       : setAnchorPoint(cc.p(0,0.5))
	-- expDins       : setScale(200/312)
	expDins       : setPosition(34,cardSize.height/2+10)
	card          : addChild(expDins,1)

	local loadingBar=ccui.LoadingBar:create()
    loadingBar:loadTexture("aution_exp.png",ccui.TextureResType.plistType)
    loadingBar:setPosition(34,cardSize.height/2+10)
    loadingBar:setAnchorPoint(cc.p(0,0.5))
    -- loadingBar:setScale(200/296)
    loadingBar:setPercent(0)
    card:addChild(loadingBar,2)

    self.cardArray[i].progress = loadingBar

    local time    = _G.Util : createLabel("",fontSize)
	time          : setColor(COLOR_ORED)
	time          : setPosition(cc.p(cardSize.width/2,cardSize.height/2-17))
	card          : addChild(time,1)

	self.cardArray[i].time = time

	local tipIcon = cc.Sprite : createWithSpriteFrameName("auction_hammer.png")
	tipIcon       : setPosition(cc.p(45,110))
	card          : addChild(tipIcon,1) 

	local name    = _G.Util : createLabel("",fontSize)
	--name          : setColor(COLOR_BLUE_L)
	name          : setAnchorPoint(cc.p(0,0.5))
	name          : setPosition(cc.p(80,105))
	card          : addChild(name,1)

	self.cardArray[i].name = name

	local labRMB_1= _G.Util : createLabel("当前价格:",fontSize)
	-- labRMB_1      : setColor(COLOR_GREEN)
	labRMB_1      : setPosition(cc.p(90,55))
	card          : addChild(labRMB_1,1)
	self.cardArray[i].labRMB_1 = labRMB_1

	local dataRMB_1= _G.Util : createLabel("0",fontSize)
	dataRMB_1      : setColor(COLOR_GREEN)
	dataRMB_1      : setAnchorPoint(cc.p(0,0.5))
	dataRMB_1      : setPosition(cc.p(140,55))
	card           : addChild(dataRMB_1,1)

	self.cardArray[i].rmb1 = dataRMB_1

	local moneyIcon = cc.Sprite:createWithSpriteFrameName("general_gold.png")
	moneyIcon       : setPosition(cc.p(200+dataRMB_1:getContentSize().width,55))
	-- moneyIcon       : setScale(0.8)
	card            : addChild(moneyIcon,1)

	local labRMB_2= _G.Util : createLabel("每次加价:",fontSize)
	labRMB_2      : setPosition(cc.p(90,25))
	card          : addChild(labRMB_2,1)

	local dataRMB_2= _G.Util : createLabel("0",fontSize)
	dataRMB_2      : setColor(COLOR_GREEN)
	dataRMB_2      : setAnchorPoint(cc.p(0,0.5))
	dataRMB_2      : setPosition(cc.p(140,25))
	card           : addChild(dataRMB_2,1)

	local moneyIcon1 = cc.Sprite:createWithSpriteFrameName("general_gold.png")
	moneyIcon1       : setPosition(cc.p(200+dataRMB_2:getContentSize().width,25))
	-- moneyIcon1       : setScale(0.8)
	card             : addChild(moneyIcon1,1)

	self.cardArray[i].rmb2 = dataRMB_2
end

function AuctionView.updateData( self,_msg )
	local location = 0
	for k,v in pairs(_msg.data) do
		if v.flag == 2 then
			location = k
			self.id = v.id
			self.BuyLab:setString("已下注")
			self.YuanBao:setVisible(true)
			self.XianYu:setVisible(true)
			self.YuanBaoNumLab:setString(v.expend_bind)
			self.XianYuNumLab:setString(v.expend_rmb)
		end
	end

	if location == 1 then
		for k,v in pairs(self.cardArray) do
			v.card:setVisible(true)
		end
		self.grildSpr:setVisible(false)
		self : __clearLayer(1)
		for i=1,2 do
			local data = self.cardArray[i+1]
			data.goodsName : setString(_G.Cfg.goods[_msg.data[i].id].name)
			local x,y = data.goodsIcon : getPosition()
			data.goodsIcon : removeFromParent()
			local function r(sender,eventType)
				if eventType == ccui.TouchEventType.ended then
					local pos=sender:getWorldPosition()
					--if pos.y<162 or pos.y>437 then return end
					local goodId=sender:getTag()
		            local temp=_G.TipsUtil:createById(goodId,nil,pos)
		            cc.Director:getInstance():getRunningScene():addChild(temp,1000)
				end
			end
			local iconBtn=_G.ImageAsyncManager:createGoodsBtn(_G.Cfg.goods[_msg.data[i].id],r,_msg.data[i].id)
			iconBtn:setPosition(cc.p(x,y))
			--iconBtn:setEnabled(false)
			data.card  :addChild(iconBtn,2)
			self.cardArray[i+1].goodsIcon = iconBtn

			if i==1 then
				self.time     = _G.Const.CONST_AUCTION_TIME_DJSCD
				self.countdown = _G.Const.CONST_AUCTION_TIME_DJSCD + _msg.data[i].time
			   	if not _msg.data[i].name then
			   		self.countdown = _G.Const.CONST_AUCTION_TIME_CD + _msg.data[i].time
			   		self.time = _G.Const.CONST_AUCTION_TIME_CD
			   	end
			    local function local_scheduler()
				    self : __initCountdown()
				end
				if not self.m_timeScheduler then
					self.m_timeScheduler = _G.Scheduler : schedule(local_scheduler, 1)
				end
			else
				data.progress : setPercent(100)
			    data.time : setString("尚未开始")
			    data.labRMB_1 : setString("当前价格:")
			end
			data.name : setString(_msg.data[i].name)
			data.rmb1 : setString(_msg.data[i].rmb)
			data.rmb2 : setString(_msg.data[i].next_rmb)
		end
	elseif location == 5 then
		for k,v in pairs(self.cardArray) do
			v.card:setVisible(true)
		end
		self.grildSpr:setVisible(false)
		for i=4,5 do
			local data = self.cardArray[i-3]
			data.goodsName : setString(_G.Cfg.goods[_msg.data[i].id].name)
			local x,y = data.goodsIcon : getPosition()
			data.goodsIcon : removeFromParent()
			local function r(sender,eventType)
				if eventType == ccui.TouchEventType.ended then
					local pos=sender:getWorldPosition()
					--if pos.y<162 or pos.y>437 then return end
					local goodId=sender:getTag()
		            local temp=_G.TipsUtil:createById(goodId,nil,pos)
		            cc.Director:getInstance():getRunningScene():addChild(temp,1000)
				end
			end
			local iconBtn=_G.ImageAsyncManager:createGoodsBtn(_G.Cfg.goods[_msg.data[i].id],r,_msg.data[i].id)
			iconBtn:setPosition(cc.p(x,y))
			--iconBtn:setEnabled(false)
			data.card  :addChild(iconBtn,2)
			self.cardArray[i-3].goodsIcon = iconBtn
			if i==5 then
				self.time     = _G.Const.CONST_AUCTION_TIME_DJSCD
				self.countdown = _G.Const.CONST_AUCTION_TIME_DJSCD + _msg.data[i].time
			   	if not _msg.data[i].name then
			   		self.countdown = _G.Const.CONST_AUCTION_TIME_CD + _msg.data[i].time
			   		self.time = _G.Const.CONST_AUCTION_TIME_CD
			   	end
			    local function local_scheduler()
				    self : __initCountdown()
				end
				if not self.m_timeScheduler then
					self.m_timeScheduler = _G.Scheduler : schedule(local_scheduler, 1)
				end
				data.labRMB_1 : setString("当前价格:")
			else
				data.time : setString("已经结束")
				data.labRMB_1 : setString("成交价格:")
				iconBtn:setGray()
			end
			data.name : setString(_msg.data[i].name)
			data.rmb1 : setString(_msg.data[i].rmb)
			data.rmb2 : setString(_msg.data[i].next_rmb)
		end
		self : __clearLayer(3)
	elseif location == 0 then
		for k,v in pairs(self.cardArray) do
			v.card:setVisible(true)
		end
		self.grildSpr:setVisible(false)
		self : __clearLayer(3)
		for i=4,5 do
			local data = self.cardArray[i-3]
			data.goodsName : setString(_G.Cfg.goods[_msg.data[i].id].name)
			local x,y = data.goodsIcon : getPosition()
			data.goodsIcon : removeFromParent()
			local function r(sender,eventType)
				if eventType == ccui.TouchEventType.ended then
					local pos=sender:getWorldPosition()
					--if pos.y<162 or pos.y>437 then return end
					local goodId=sender:getTag()
		            local temp=_G.TipsUtil:createById(goodId,nil,pos)
		            cc.Director:getInstance():getRunningScene():addChild(temp,1000)
				end
			end
			local iconBtn=_G.ImageAsyncManager:createGoodsBtn(_G.Cfg.goods[_msg.data[i].id],r,_msg.data[i].id)
			iconBtn:setPosition(cc.p(x,y))
			--iconBtn:setEnabled(false)
			data.card  :addChild(iconBtn,2)
			self.cardArray[i-3].goodsIcon = iconBtn
			iconBtn:setGray()
			data.time : setString("已经结束") 
			data.name : setString(_msg.data[i].name)
			data.rmb1 : setString(_msg.data[i].rmb)
			data.rmb2 : setString(_msg.data[i].next_rmb or "0")
			data.labRMB_1 : setString("成交价格:")
			self.YuanBao:setVisible(false)
			self.XianYu:setVisible(false)
			self.YuanBaoNumLab:setVisible(false)
			self.XianYuNumLab:setVisible(false)
			self.BuyLab:setVisible(false)
		end
		--self.btn : setEnabled(false)
		self.btn : setGray()
	else
		for k,v in pairs(self.cardArray) do
			v.card:setVisible(true)
		end
		self.grildSpr:setVisible(false)
		local iCount = 1
		for i=location-1,location+1 do
			local data = self.cardArray[iCount]
			data.goodsName : setString(_G.Cfg.goods[_msg.data[i].id].name)
			local x,y = data.goodsIcon : getPosition()
			data.goodsIcon : removeFromParent()
			local function r(sender,eventType)
				if eventType == ccui.TouchEventType.ended then
					local pos=sender:getWorldPosition()
					--if pos.y<162 or pos.y>437 then return end
					local goodId=sender:getTag()
		            local temp=_G.TipsUtil:createById(goodId,nil,pos)
		            cc.Director:getInstance():getRunningScene():addChild(temp,1000)
				end
			end
			local iconBtn=_G.ImageAsyncManager:createGoodsBtn(_G.Cfg.goods[_msg.data[i].id],r,_msg.data[i].id)
			iconBtn:setPosition(cc.p(x,y))
			--iconBtn:setEnabled(false)
			data.card  :addChild(iconBtn,2)
			self.cardArray[iCount].goodsIcon = iconBtn
			if i==location then
				self.time      = _G.Const.CONST_AUCTION_TIME_DJSCD
				self.countdown = _G.Const.CONST_AUCTION_TIME_DJSCD + _msg.data[i].time
			   	if not _msg.data[i].name then
			   		self.countdown = _G.Const.CONST_AUCTION_TIME_CD + _msg.data[i].time
			   		self.time = _G.Const.CONST_AUCTION_TIME_CD
			   	end
			    local function local_scheduler()
				    self : __initCountdown()
				end
				if not self.m_timeScheduler then
					self.m_timeScheduler = _G.Scheduler : schedule(local_scheduler, 1)
				end
			elseif i==location+1 then
				data.progress : setPercent(100)
			    data.time : setString("尚未开始")
			    data.labRMB_1 : setString("当前价格:")
			elseif i==location-1 then
				iconBtn:setGray()
				data.progress : setPercent(0)
			    data.time : setString("已经结束")
			    data.labRMB_1 : setString("成交价格:")
			end
			data.name : setString(_msg.data[i].name)
			data.rmb1 : setString(_msg.data[i].rmb)
			data.rmb2 : setString(_msg.data[i].next_rmb or "0")
			iCount = iCount + 1
		end
	end
end

function AuctionView.__initCountdown( self)
	print("auctionTime",self.countdown)
	print("time",_G.TimeUtil : getServerTimeSeconds())
	if self.countdown - _G.TimeUtil : getServerTimeSeconds() >=0 then
		
	    self.cardArray[2].progress : setPercent(((self.countdown - _G.TimeUtil : getServerTimeSeconds())/self.time)*100)
	    self.cardArray[2].time : setString(self:__getTimeStr(1,self.countdown - _G.TimeUtil : getServerTimeSeconds()))
	    if self.countdown - _G.TimeUtil : getServerTimeSeconds() == 0 then
	    	local msg = REQ_AUCTION_REQUEST()
			_G.Network: send(msg)
	    end
	end
end

function AuctionView.__clearLayer( self,pos )
	local data = self.cardArray[pos]
	data.card:setVisible(false)

	if pos==1 then
		self.grildSpr:setVisible(true)
	else
		self.grildSpr:setVisible(true)
		self.grildSpr:setPosition(cc.p(self.dinsSize.width-150,290))
		-- self.grildSpr:setScaleX(1)
	end
	--data.goodsName : setString("暂无")
	--data.goodsIcon : setVisible(false)
	--data.progress : setPercent(100)
	--data.time : setString("暂无")
	--data.name : setString("暂无")
	--data.rmb1 : setString("暂无")
	--data.rmb2 : setString("暂无")
end

function AuctionView.__getTimeStr( self,type,_time)
    _time = _time < 0 and 0 or _time
    local hour   = math.floor(_time/3600)
    local min    = math.floor(_time%3600/60)
    local second = math.floor(_time%60)
    local time = tostring(hour)..":"..tostring(min)..":"..second
    if hour < 10 then
        hour = "0"..hour
    elseif hour < 0 then
        hour = "00"
    end
    if min < 10 then
        min = "0"..min
    elseif min < 0 then
        min = "00"
    end
    if second < 10 then
        second = "0"..second
    end

    local time = ""

    if     0 == type then
    	time = tostring(hour)..":"..tostring(min)..":"..second
    elseif 1 == type then
    	time = tostring(min)..":"..second
    end

    return time
end

function AuctionView.__closeWindow( self )
	if self.m_rootLayer == nil then return end
    self.m_rootLayer=nil
	_G.Scheduler 		 : unschedule(self.m_timeScheduler)
	cc.Director:getInstance():popScene()
	self 			     : unregister()
end

return AuctionView