local YZQJActivityView = classGc(view, function(self)
	self.succTrue = true
    self.scriptLab = {}
end)

local m_winSize  = cc.Director : getInstance() : getVisibleSize()
local rightSize= cc.size(580,456)
local iconSize = cc.size(79,79)
local fontSize = 20
local isBuyTip = false

function YZQJActivityView.create( self,_id,time )
	self.m_container = cc.Node:create() 
	self.AcId = _id
	local updoubleSpr = cc.Sprite:create("ui/bg/feast_upbg.png")
    updoubleSpr : setPosition(rightSize.width/2,rightSize.height-42)
    self.m_container:addChild(updoubleSpr)

    local endTime= self:getTimeStr(time.end_time) or "2016/5/20 21:00"
    local startTime=self:getTimeStr(time.start_time) or "2016/5/20 21:00"

    local timestrLab=_G.Util:createLabel("活动时间:",fontSize)
    -- timestrLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    timestrLab:setPosition(0,rightSize.height-20)
    timestrLab:setAnchorPoint(0,0.5)
    self.m_container:addChild(timestrLab)

    local LabWidth=timestrLab:getContentSize().width
    local timeLab=_G.Util:createLabel(string.format("%s-%s",startTime,endTime),fontSize)
    timeLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
    timeLab:setPosition(LabWidth,rightSize.height-20)
    timeLab:setAnchorPoint(0,0.5)
    self.m_container:addChild(timeLab)

    local function onShop(sender, eventType)
        if eventType==ccui.TouchEventType.ended then
        	if self.tipSpr ~=nil then
			    local msg = REQ_FESTIVAL_COLLECT_REQ()
			    _G.Network :send(msg)  
        		self.tipSpr : setVisible(true)
                self.shoplisterner:setSwallowTouches(true)
        	else
        		local msg = REQ_FESTIVAL_COLLECT_REQ()
    			_G.Network :send(msg) 
            	self:shopTipsView()
            end
        end
    end
    local shopBtn=gc.CButton:create("general_btn_gold.png")
    shopBtn:setTitleText("文字礼包")
    shopBtn:setTitleFontName(_G.FontName.Heiti)
    shopBtn:setTitleFontSize(fontSize+4)
    --shopBtn:enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
    shopBtn:setPosition(rightSize.width-70,rightSize.height-42)
    shopBtn:addTouchEventListener(onShop)
    self.m_container:addChild(shopBtn)

    local goodsbgSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_gold_floor.png")
    goodsbgSpr:setContentSize(cc.size(620,427))
    goodsbgSpr:setPosition(rightSize.width/2,rightSize.height/2-68)
    self.m_container : addChild(goodsbgSpr)

	self:initScroView()
	return self.m_container
end

function YZQJActivityView.initScroView( self )
	local ScrollView  = cc.ScrollView : create()
    self.zongzhi = 0
    local goodsCfg = _G.Cfg.collect[self.AcId][1]
    if goodsCfg == nil then return end
    for k,v in pairs(goodsCfg) do
    	self.zongzhi=self.zongzhi+1
    end

    print("zuidazhi",self.zongzhi)
    self.oneHeight = 211
    local viewSize = cc.size(620, self.oneHeight*2)
    local containerSize = cc.size(620, self.oneHeight*self.zongzhi)

    ScrollView : setDirection(ccui.ScrollViewDir.vertical)
    ScrollView : setViewSize(viewSize)
    ScrollView : setContentSize(containerSize)
    ScrollView : setContentOffset( cc.p( 0, viewSize.height-containerSize.height))
    ScrollView : setPosition(cc.p(-20, -50))
    print("容器大小：",self.oneHeight*self.zongzhi)
    ScrollView : setBounceable(false)
    ScrollView : setTouchEnabled(true)
    ScrollView : setDelegate()
    self.m_container : addChild(ScrollView)
    
    local barView=require("mod.general.ScrollBar")(ScrollView)
    barView:setPosOff(cc.p(-5,0))
    -- barView:setMoveHeightOff(-7)

    self.playNoLab={}
    self.rewardBtn={}
    self.labnums = 0 
    for i=1,self.zongzhi do
        local OneReward = self : TubiaoReturn(i,goodsCfg)
        OneReward : setPosition(cc.p(rightSize.width/2+20,containerSize.height-107-(i-1)*(self.oneHeight)))
        ScrollView : addChild(OneReward)
    end
end

function YZQJActivityView.TubiaoReturn( self,ccc,Cfg)
	self.tubiaoSpr = ccui.Scale9Sprite : createWithSpriteFrameName("general_noit.png")
    self.tubiaoSpr : setPreferredSize(cc.size(610,self.oneHeight-5))

    local targetLab = _G.Util:createLabel("目标:",fontSize)
    -- targetLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    targetLab:setPosition(50,self.oneHeight-50)
    self.tubiaoSpr:addChild(targetLab)

    local RewardLab = _G.Util:createLabel("奖励:",fontSize)
    -- RewardLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    RewardLab:setPosition(50,self.oneHeight-155)
    self.tubiaoSpr:addChild(RewardLab)

    local function cFun(sender,eventType)
		self:cellBtnCallback(sender,eventType)
	end
    local icondata = Cfg[ccc].reward
    local rewardSpr = {1,2,3}
    for i=1,3 do
        rewardSpr[i] = cc.Sprite:createWithSpriteFrameName("general_tubiaokuan.png")
        rewardSpr[i] : setPosition(130+(i-1)*115,self.oneHeight-155)
        self.tubiaoSpr : addChild(rewardSpr[i])

	    if icondata~=nil and icondata[i]~=nil then
            -- print("请求物品图片",icondata, icondata[i][1])
            local goodId    = icondata[i][1]
            local goodCount = icondata[i][2]
            local goodsdata = _G.Cfg.goods[goodId]
            if goodsdata ~= nil then
                local iconSpr = _G.ImageAsyncManager:createGoodsBtn(goodsdata,cFun,goodId,goodCount)
                iconSpr : setPosition(iconSize.width/2, iconSize.height/2)
                iconSpr : setSwallowTouches(false)
                rewardSpr[i] : addChild(iconSpr)
            end
        end 
    end

    local function onRewardCallback(sender, eventType)
        if eventType==ccui.TouchEventType.ended then
        	local rewardTag=sender:getTag()
            print("onBtnCallback",rewardTag)
            local Position = sender : getWorldPosition()
		    print("－－－－Position.y",Position.y, m_winSize.height/2+rightSize.height/2-90)
	        if Position.y > m_winSize.height/2+rightSize.height/2-90 or
	           Position.y < m_winSize.height/2-rightSize.height/2-15 then 
	           return end
			local msg = REQ_FESTIVAL_COLLECT_NEW()
			msg:setArgs(self.AcId,rewardTag,1)
			_G.Network:send(msg)
        end
    end
    
    self.rewardBtn[ccc]=gc.CButton:create("general_btn_lv.png")
    self.rewardBtn[ccc]:setTitleText("领 取")
    self.rewardBtn[ccc]:setTitleFontName(_G.FontName.Heiti)
    self.rewardBtn[ccc]:setTitleFontSize(fontSize+4)
    self.rewardBtn[ccc]:setPosition(rightSize.width-60,self.oneHeight/2)
    self.rewardBtn[ccc]:addTouchEventListener(onRewardCallback)
    self.rewardBtn[ccc]:setBright(false)
    self.rewardBtn[ccc]:setEnabled(false)
    self.rewardBtn[ccc]:setTag(ccc)
   	self.tubiaoSpr:addChild(self.rewardBtn[ccc])

   	self:DemandScript(ccc,Cfg)

    return self.tubiaoSpr
end

function YZQJActivityView.DemandScript( self,ccc,Cfg )
	local scriptdata = Cfg[ccc].goodslist
	local scriptnums = 0

	for k,v in pairs(scriptdata) do
		scriptnums=scriptnums+1
	end
 
	for i=1,scriptnums do
        self.labnums = self.labnums+1
		local scriptSpr=cc.Sprite:createWithSpriteFrameName("general_tubiaokuan.png")
	    scriptSpr:setPosition(117+(i-1)*74,self.oneHeight-50)
	    scriptSpr:setScale(0.8)
	    self.tubiaoSpr:addChild(scriptSpr)

	    if scriptdata~=nil and scriptdata[i]~=nil then
            -- print("请求物品图片",scriptdata, scriptdata[i][1])
            local goodId    = scriptdata[i][1]
            local goodCount = scriptdata[i][2]
            local goodsdata = _G.Cfg.goods[goodId]
            local goodNums = _G.GBagProxy:getGoodsCountById(goodId)
            if goodsdata ~= nil then
                local iconSpr = _G.ImageAsyncManager:createGoodsSpr(goodsdata)
                iconSpr     : setPosition(iconSize.width/2, iconSize.height/2)

                self.scriptLab[self.labnums] = _G.Util : createLabel(string.format("%d/%d",goodNums,goodCount), fontSize+4)
	            self.scriptLab[self.labnums] : setPosition(iconSize.width-7, 1)
	            self.scriptLab[self.labnums] : setAnchorPoint( cc.p(1,0) )
	            iconSpr : addChild(self.scriptLab[self.labnums])
                scriptSpr : addChild(iconSpr)
            end
            local Succ = math.floor(goodNums/goodCount)
            print("self.succTrue",Succ,self.succTrue)
            if Succ < 1 then
            	self.succTrue = false
            end
        end 
	end
    print("self.succTrue",self.succTrue)
	if self.succTrue == false then
        self.rewardBtn[ccc]:setBright(false)
        self.rewardBtn[ccc]:setEnabled(false)
    else
        self.rewardBtn[ccc]:setBright(true)
        self.rewardBtn[ccc]:setEnabled(true)
    end
end

function YZQJActivityView.shopTipsView( self )
	-- local function onTouchBegan()
 --        -- self:__hideNormalTips()
 --        return true 
 --    end
 --    self.shoplisterner=cc.EventListenerTouchOneByOne:create()
 --    self.shoplisterner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
 --    self.shoplisterner:setSwallowTouches(true)

 --    local RankNode=cc.Node:create()
 --    RankNode:setContentSize(cc.size(560,460))
 --    RankNode : setPosition(m_winSize.width/2,m_winSize.height/2)
 --    cc.Director:getInstance():getRunningScene() :addChild(RankNode,999)
 --    RankNode:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.shoplisterner,RankNode)

 --    local NodeSize = RankNode:getContentSize()
 --    self.tipSpr = ccui.Scale9Sprite : createWithSpriteFrameName("general_tips_dins.png")
 --    self.tipSpr : setPreferredSize(NodeSize)
 --    RankNode : addChild(self.tipSpr)

 --    local function close(sender, eventType)
 --        if eventType==ccui.TouchEventType.ended then
 --            print("close")
 --            self.tipSpr : setVisible(false)
 --            self.shoplisterner:setSwallowTouches(false)
 --        end
 --    end
 --    local m_closeBtn=gc.CButton:create("general_close.png")
 --    m_closeBtn:setAnchorPoint(cc.p(1,1))
 --    m_closeBtn:setPosition(NodeSize.width+5,NodeSize.height+5)
 --    m_closeBtn:addTouchEventListener(close)
 --    m_closeBtn:setSoundPath("bg/ui_sys_clickoff.mp3")
 --    self.tipSpr:addChild(m_closeBtn)

 --    local tipslogoSpr = cc.Sprite : createWithSpriteFrameName("general_tips_up.png")
 --    tipslogoSpr : setPosition(NodeSize.width/2, NodeSize.height-5)
 --    self.tipSpr : addChild(tipslogoSpr)

 --    local logoLab = _G.Util:createLabel("文字礼包",fontSize)
 --    -- logoLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORANGE))
 --    logoLab:setPosition(NodeSize.width/2,NodeSize.height-5)
 --    self.tipSpr:addChild(logoLab)

    local frameSize=cc.size(585,368)
    local combatView  = require("mod.general.BattleMsgView")()
    self.combatBG = combatView : create("文字礼包",frameSize)

    local floorSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_gold_floor.png")
    floorSpr:setPreferredSize(cc.size(frameSize.width-20,frameSize.height-60))
    floorSpr:setPosition(frameSize.width/2-9,frameSize.height/2-30)
    self.combatBG:addChild(floorSpr)

    self.numsLab={}
    self.buyBtn={}
    self.times ={}
    for i=1,3 do
    	local oneBuy = self:buyView(i)
    	oneBuy:setPosition(99+(i-1)*((frameSize.width-30)/3),frameSize.height/2-31)
    	self.combatBG:addChild(oneBuy)
    end
end

function YZQJActivityView.buyView( self,i)
    local onebuySize = cc.size(180,296)
	local buySpr = ccui.Scale9Sprite : createWithSpriteFrameName("general_noit.png")
    buySpr : setPreferredSize(onebuySize)

    local buysCfg = _G.Cfg.collect[self.AcId]
    local buydata = buysCfg[2]
    if buydata == nil then return end

    local giftsLab = _G.Util:createLabel("文字礼包",fontSize)
    giftsLab:setPosition(onebuySize.width/2,onebuySize.height-25)
    buySpr:addChild(giftsLab)

    local function roleCallBack(sender, eventType)
        self:cellBtnCallback(sender, eventType) 
    end

    local giftBtn=cc.Sprite:createWithSpriteFrameName("general_tubiaokuan.png")
    giftBtn:setPosition(onebuySize.width/2,onebuySize.height-90)
    buySpr:addChild(giftBtn)

    local xianyuSpr = cc.Sprite:createWithSpriteFrameName("general_xianYu.png")
    xianyuSpr:setPosition(onebuySize.width/2-20,onebuySize.height/2-10)
    buySpr:addChild(xianyuSpr)

    local ORANGE = _G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_OSTROKE)
    local rmb = buydata[i].rmb or "0"
    local priceLab=_G.Util:createLabel(rmb,fontSize,ORANGE)
    priceLab:setPosition(onebuySize.width/2+5,onebuySize.height/2-10)
    priceLab:setAnchorPoint(cc.p(0,0.5))
    buySpr:addChild(priceLab)

    local tipsLab = _G.Util:createLabel("今日可购买次数:",fontSize)
    -- tipsLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
    tipsLab:setPosition(onebuySize.width/2,onebuySize.height/2-40)
    buySpr:addChild(tipsLab)

    self.times[i] = buydata[i].times or "0"
    self.numsLab[i]=_G.Util:createLabel(string.format("0/%d",self.times[i]),fontSize)
    self.numsLab[i]:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
    self.numsLab[i]:setPosition(onebuySize.width/2,onebuySize.height/2-68)
    buySpr:addChild(self.numsLab[i])

    local function onBtnCallback(sender, eventType)
        if eventType==ccui.TouchEventType.ended then
        	local buyTag=sender:getTag()
            print("onBtnCallback",buyTag)
            if isBuyTip then
                print("直接购买＝＝＝＝＝＝＝＝＝＝不弹出提示框")
                local msg = REQ_FESTIVAL_PACKS_NEW()
                msg:setArgs(self.AcId,buyTag,2)
                _G.Network:send(msg)
            else
                self : BuyCountCallBack(buyTag,rmb)
            end
        end
    end
    
    self.buyBtn[i]=gc.CButton:create("general_btn_gold.png")
    self.buyBtn[i]:setTitleText("购 买")
    self.buyBtn[i]:setTitleFontName(_G.FontName.Heiti)
    self.buyBtn[i]:setTitleFontSize(fontSize+4)
    self.buyBtn[i]:setPosition(onebuySize.width/2,35)
    self.buyBtn[i]:addTouchEventListener(onBtnCallback)
    self.buyBtn[i]:setTag(i)
   	buySpr:addChild(self.buyBtn[i])

    local icondata = buydata[i].goodslist
    print("icondata",icondata[1],icondata[2])
    if icondata~=nil and icondata[1]~=nil then
    	local goodsId = icondata[1]
    	local goodsCount = icondata[2]
    	local goodsdata   = _G.Cfg.goods[goodsId]
        if goodsdata ~= nil then
        	giftsLab : setString(goodsdata.name)
        	giftsLab : setColor(_G.ColorUtil:getRGB(goodsdata.name_color))
            local iconSpr = _G.ImageAsyncManager:createGoodsBtn(goodsdata,roleCallBack,goodsId,goodsCount)
            iconSpr : setPosition(iconSize.width/2, iconSize.height/2)
            iconSpr : setSwallowTouches(false)
            giftBtn : addChild(iconSpr)
        end
    end

    return buySpr
end

function YZQJActivityView.BuyCountCallBack( self,buy_id,rmb )
    print("BuyCountCallBack",self.AcId,buy_id)
    local function buy()
    	local msg = REQ_FESTIVAL_PACKS_NEW()
        msg:setArgs(self.AcId,buy_id,2)
        _G.Network:send(msg)
    end

    local topLab = string.format("花费%d钻石购买?",rmb)
    local rightLab  = _G.Lang.LAB_N[106]
    local szSureBtn = _G.Lang.BTN_N[1]

    print("aaaazzz==>",topLab,szSureBtn)
    local view  = require("mod.general.TipsBox")()
    local tipsNode = view : create("",buy,cancel)
    -- tipsNode     : setPosition(cc.p(m_winSize.width/2,m_winSize.height/2))
    cc.Director : getInstance() : getRunningScene() : addChild(tipsNode,_G.Const.CONST_MAP_ZORDER_NOTIC,332211)

    local layer=view:getMainlayer()
    view:setTitleLabel("提示")
    if topLab ~= nil then
        local label =_G.Util : createLabel(topLab,fontSize)
        label     : setPosition(cc.p(0,35))
        layer     : addChild(label,88)
    end
    if rightLab then
        local label =_G.Util : createLabel(rightLab,fontSize)
        label     : setPosition(cc.p(25,-35))
        layer     : addChild(label,88)
    end
    if szSureBtn ~= nil then
        view : setSureBtnText(szSureBtn)
    end

    local function c(sender, eventType)
        if eventType==ccui.TouchEventType.ended then
            print("勾选了不再提示",isBuyTip)
            if isBuyTip then
                isBuyTip = false
            else
                isBuyTip = true
            end
        end
    end

    local checkbox = ccui.CheckBox : create()
    checkbox : setTouchEnabled(true)
    checkbox : loadTextures("general_gold_floor.png","general_gold_floor.png","general_check_selected.png","","",ccui.TextureResType.plistType)
    checkbox : setPosition(cc.p(-80,-35))
    checkbox : setName("sdjfgksjdfklgj")
    checkbox : addTouchEventListener(c)
    -- checkbox : setAnchorPoint(cc.p(1,0.5))
    layer    : addChild(checkbox)
end

function YZQJActivityView.getTimeStr( self, _time)
    local time = os.date("*t",_time)

    if time.month < 10 then time.month = "0"..time.month end
    if time.day < 10 then time.day = "0"..time.day end
    if time.hour < 10 then time.hour = "0"..time.hour
    elseif time.hour < 0 then time.hour = "00" end
    if time.min < 10 then time.min = "0"..time.min
    elseif time.min < 0 then time.min = "00" end

    local time  = time.year.."/"..time.month.."/"..time.day.." "..time.hour..":"..time.min

    return time
end

function YZQJActivityView.cellBtnCallback(self,sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local role_tag = sender : getTag()
	    local Position = sender : getWorldPosition()
	    print("－－－－Position.y",Position.y, m_winSize.height/2-rightSize.height/2-15)
        if Position.y > m_winSize.height/2+rightSize.height/2-80 or
           Position.y < m_winSize.height/2-rightSize.height/2-15 
           then return end
		local temp = _G.TipsUtil : createById(role_tag,nil,Position,0)
	    cc.Director:getInstance():getRunningScene() : addChild(temp,1000)
	end
end

function YZQJActivityView.FESTIVALOK( self, okid )
    print("FESTIVALOK",okid,self.labnums)
    local Cfg = _G.Cfg.collect[self.AcId][1]
    if Cfg == nil then return end
    local btnTrue = true
    local Nolab=0
    for aa=1, self.zongzhi do 
        local scriptdata = Cfg[aa].goodslist
        local scriptnums = 0
        if scriptdata==nil then return end
        for k,v in pairs(scriptdata) do
            scriptnums= scriptnums+1
        end
    	for i=1,scriptnums do
            Nolab = Nolab+1
    		if scriptdata[i]~=nil then
    			local goodId = scriptdata[i][1]
    			local goodCount = scriptdata[i][2]
    			local goodNums = _G.GBagProxy:getGoodsCountById(goodId)
                print("scriptnums",self.scriptLab[1],Nolab,goodId,goodNums,goodCount)
    			self.scriptLab[Nolab]:setString(string.format("%d/%d",goodNums,goodCount))
    			local Succ = math.floor(goodNums/goodCount)
                print("self.scriptLab",Nolab,Succ)
                if Succ < 1 then
                	btnTrue = false
                end
    		end
    	end
        print("self.scriptLab",btnTrue)
    	if btnTrue == false then
            self.rewardBtn[aa]:setBright(false)
            self.rewardBtn[aa]:setEnabled(false)
        else
            self.rewardBtn[aa]:setBright(true)
            self.rewardBtn[aa]:setEnabled(true)
        end
    end
end

function YZQJActivityView.FESTIVALOPEN( self,openid )
	local msg = REQ_FESTIVAL_COLLECT_REQ()
    _G.Network :send(msg) 
end

function YZQJActivityView.YZQJCOLLECT( self, packslist)
	self.nowtimes = {}
	for k,v in pairs(packslist) do
		print("packslist--->",k,v.pack_id,v.times)
		self.nowtimes[v.pack_id] = v.times or 0
		self.numsLab[v.pack_id]:setString(string.format("%d/%d",self.nowtimes[v.pack_id],self.times[v.pack_id]))
        if self.nowtimes[v.pack_id]>=self.times[v.pack_id] then
            self.numsLab[v.pack_id]:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_RED))
        end
		if self.nowtimes[v.pack_id]>=10 then
			self.buyBtn[v.pack_id]:setBright(false)
			self.buyBtn[v.pack_id]:setEnabled(false)
		end
	end
end

return YZQJActivityView

