local THfundView = classGc(view, function(self, _panelType)
    self.pMediator = require("mod.recharge.THfundMediator")()
    self.pMediator : setView(self)
end)


local FONTSIZE = 20
local iconXY = 78

local rightbgSize = cc.size(620, 430)
local sprsize  = cc.size(620, 370)
local moneyArray = {25,128}

local BUYTAG = false
local yuekaData = _G.Cfg.yueka

function THfundView.create(self)
	self.m_container = cc.Node:create()

    self.cardtype=1
    local function onTypeBtnCallBack(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local typetag  = sender : getTag()
            print("typetagtypetagtypetag",typetag)
            self.cardtype=typetag
            self:NodeTrueFalse(typetag)
            self:PageContainer(typetag)
        end
    end

    local function onButtonCallBack(sender, eventType)
        self : onBtnCallBack(sender, eventType)
    end
    
    self.typeBtn={}
    self.rewardBtn={}
    self.rewardSpr={}
    self.cardNode={}
    for i=1,2 do
        local typeimg="vip_card.png"
        local typeinimg="vip_cardin.png"
        if i==2 then 
            typeimg="vip_lift.png"
            typeinimg="vip_liftin.png"
        end
        self.typeBtn[i] = gc.CButton : create(typeimg,typeinimg,typeinimg)
        self.typeBtn[i] : setTag(i)
        self.typeBtn[i] : setPosition(-40+(i-1)*300, 143)
        self.typeBtn[i] : addTouchEventListener(onTypeBtnCallBack)
        self.m_container : addChild(self.typeBtn[i])

        local doubleSize=cc.size(sprsize.width-14,sprsize.height/2-6)
        local doubleSpr = ccui.Scale9Sprite:createWithSpriteFrameName("general_rolekuang.png")
        doubleSpr:setPreferredSize(doubleSize)
        doubleSpr:setPosition(110,sprsize.height-201-i*sprsize.height/2)
        self.m_container : addChild(doubleSpr)

        local tipsLab = _G.Util : createLabel("购买即可领取", FONTSIZE)
        tipsLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_GOLD))
        tipsLab : setPosition(20, doubleSize.height-33)
        tipsLab : setAnchorPoint( cc.p(0.0,0.5) )
        doubleSpr : addChild(tipsLab)

        if i==1 then
            self.buyBtn = gc.CButton : create("general_btn_gold.png")
            self.buyBtn : setTitleText("购 买")
            self.buyBtn : setTitleFontName(_G.FontName.Heiti)
            self.buyBtn : setTitleFontSize(FONTSIZE+4)
            -- self.buyBtn : enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
            self.buyBtn : setPosition(doubleSize.width-80, doubleSize.height/2-20)
            self.buyBtn : setTag(i)
            self.buyBtn : addTouchEventListener(onButtonCallBack)
            doubleSpr : addChild(self.buyBtn)
        end

        self.rewardBtn[i] = gc.CButton : create("general_btn_gold.png")
        self.rewardBtn[i] : setTitleText("领 取")
        self.rewardBtn[i] : setTitleFontName(_G.FontName.Heiti)
        self.rewardBtn[i] : setTitleFontSize(FONTSIZE+4)
        -- self.rewardBtn[i] : enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
        self.rewardBtn[i] : setPosition(doubleSize.width-80, doubleSize.height/2-20)
        self.rewardBtn[i] : setTag(i)
        self.rewardBtn[i] : setBright(false)
        self.rewardBtn[i] : setEnabled(false)
        self.rewardBtn[i] : addTouchEventListener(onButtonCallBack)
        doubleSpr : addChild(self.rewardBtn[i])

        self.rewardSpr[i] = cc.Sprite : createWithSpriteFrameName("main_already.png")
        self.rewardSpr[i] : setVisible(false)
        self.rewardSpr[i] : setPosition(doubleSize.width-80, doubleSize.height/2-20)
        doubleSpr : addChild(self.rewardSpr[i])

        if i==2 then
            tipsLab:setString("每日可领")

            self.timeLab = _G.Util : createLabel("", FONTSIZE)
            self.timeLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
            self.timeLab : setPosition(sprsize.width/2+70, doubleSize.height-33)
            self.timeLab : setAnchorPoint( cc.p(0.0,0.5) )
            doubleSpr : addChild(self.timeLab)
        end

        self.rewardBtn[1] : setVisible(false)
        self.cardNode[i] = cc.Node:create()
        self.m_container : addChild(self.cardNode[i],1)
        self : CardNodeReturn(i)
    end

--  初始化
    self : networksend()
    self : NodeTrueFalse(self.cardtype)
    return self.m_container
end

function THfundView.pushdata(self,_data)
    if _data.isbuy==1 then
        BUYTAG=false
        self.TipsStr="只能购买月卡或者终身卡其中一种\n前往购买界面？"
    else
        BUYTAG=true
    end
    for k,v in pairs(_data.msg) do
        print("pushdata--->>",k,v.type,v.endday,v.state,v.state2)
        self.TipsStr="购买了终身卡的无法购买月卡"
        if v.type==1 then
            self.endTime=self:getTimeStr(v.endday)
            self.TipsStr="购买终身卡将会取消月卡，前往购买？"
        end
        self.type=v.type
        self.state1=v.state
        self.state2=v.state2
        self.cardtype=v.type

        self:NodeTrueFalse(self.cardtype)
        self:PageContainer(v.type)
    end
    print("self.TipsStr",self.TipsStr)
end

function THfundView.ReturnBuydata(self,_data)
    print("ReturnBuydata--->>",_data.type,_data.endday,_data.state,_data.state2)
    self.TipsStr="购买了终身卡的无法购买月卡"
    if _data.type==1 then
        self.endTime=self:getTimeStr(_data.endday)
        self.TipsStr="购买终身卡将会取消月卡，前往购买？"
    end
    self.type=_data.type
    self.state1=_data.state
    self.state2=_data.state2
    self.cardtype=_data.type

    self:PageContainer(_data.type)
end

function THfundView.PageContainer(self,typeid)
    if self.type==nil then return end
    
    if self.type==typeid then
        BUYTAG=true
        self.rewardBtn[1]:setVisible(true)
        self.buyBtn:setVisible(false)
        if self.state1==0 then
            self.rewardBtn[1]:setVisible(false)
            self.rewardSpr[1]:setVisible(true)
        else
            self.rewardBtn[1]:setBright(true)
            self.rewardBtn[1]:setEnabled(true)
        end
        if self.state2==0 then
            self.rewardBtn[2]:setVisible(false)
            self.rewardSpr[2]:setVisible(true)
        else
            self.rewardBtn[2]:setBright(true)
            self.rewardBtn[2]:setEnabled(true)
        end
        
        if typeid==1 then
            self.timeLab:setString("结束时间："..self.endTime)
        end
    else
        BUYTAG=false
        self.rewardBtn[1]:setVisible(false)
        self.rewardSpr[1]:setVisible(false)
        self.buyBtn:setVisible(true)
        -- self.buyBtn:setBright(false)
        -- self.buyBtn:setEnabled(false)

        self.rewardSpr[2]:setVisible(false)
        self.rewardBtn[2]:setVisible(true)
        self.rewardBtn[2]:setBright(false)
        self.rewardBtn[2]:setEnabled(false)
        self.rewardBtn[2]:setTitleText("领 取")

        self.timeLab:setString("")
    end
end

function THfundView.RewardData(self,_data)
    if _data.idx==1 then
        self.state1=0
    else
        self.state2=0
    end
    self.rewardBtn[_data.idx]:setVisible(false)
    self.rewardSpr[_data.idx]:setVisible(true)
    _G.Util:playAudioEffect("ui_wealth_money")
end

function THfundView.CardNodeReturn(self,typeid)
    local function roleCallBack(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local role_tag  = sender : getTag()
            local Position  = sender : getWorldPosition()
            print("－－－－选中role_tag:", role_tag)
            -- print("－－－－Position.y",Position.y)
            if role_tag <= 0 then return end
            local temp = _G.TipsUtil : createById(role_tag,nil,Position,0)
            cc.Director:getInstance():getRunningScene() : addChild(temp,1000)
        end 
    end

    local doubleSize=cc.size(sprsize.width-14,sprsize.height/2-4)
    local posY = -35
    for i=1,2 do
        if i==2 then
            posY = -220
        end
        for j=1,4 do
            local iconBtn = cc.Sprite:createWithSpriteFrameName("general_tubiaokuan.png")
            iconBtn : setPosition((iconXY+30)*(j-1)-120, posY)
            self.cardNode[typeid] : addChild(iconBtn)

            local icondata = yuekaData[typeid].first
            if i==2 then
                icondata = yuekaData[typeid].every
            end
            print("icondata",icondata,icondata[j])
            if icondata~=nil and icondata[j] ~= nil then
                print("请求物品图片", icondata[j][1],iconBtn)
                local goodId    = icondata[j][1]
                local goodCount = icondata[j][2]
                local goodsdata = _G.Cfg.goods[goodId]
                if goodsdata ~= nil then
                    local iconSpr = _G.ImageAsyncManager:createGoodsBtn(goodsdata,roleCallBack,goodId,goodCount)
                    iconSpr : setSwallowTouches(false)
                    iconSpr : setPosition(iconXY/2, iconXY/2)
                    iconBtn : addChild(iconSpr)
                end
            end
        end
    end
end

function THfundView.NodeTrueFalse(self,typetag)
    for i=1,2 do
        if i==typetag then
            self.typeBtn[i] : setEnabled(false)
            self.typeBtn[i] : setBright(false)
            self.cardNode[i] : setVisible(true)
        else
            self.typeBtn[i] : setEnabled(true)
            self.typeBtn[i] : setBright(true)
            self.cardNode[i] : setVisible(false)
        end
    end
end

function THfundView.onBtnCallBack(self, sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local btntag = sender : getTag() 
        print("购买还是领取？？",btntag,moneyArray[self.cardtype])
        if BUYTAG == false then
            print("弹出购买框")
            local function sure()
                if self.type~=nil and self.cardtype==1 then return end
                print("购买")
                local msg = REQ_SYSTEM_PAY_CHECK()
                msg       : setArgs(0)
                _G.Network :send( msg )

                gc.UserCache:getInstance():setRechargeMoney(tostring(moneyArray[self.cardtype]))
                -- self:rechargeMoney()    
            end
            local function Cancel()
                print("取消购买")
            end
            _G.Util : showTipsBox(self.TipsStr,sure, Cancel)
        elseif BUYTAG == true then
            local msg = REQ_YUEKA_GET_REWARDS()
            msg :setArgs(self.cardtype,btntag)
            _G.Network : send(msg)
        end
    end
end

function THfundView.getTimeStr( self, _time)
    local time = os.date("*t",_time)
    print("time",_time)

    if time.month < 10 then time.month = "0"..time.month end
    if time.day < 10 then time.day = "0"..time.day end

    local time  = time.year.."/"..time.month.."/"..time.day
    print("endtime",time)

    return time
end

function THfundView.networksend( self )
    local msg = REQ_YUEKA_REQUEST()
    _G.Network : send( msg)
    print("请求协议")
end

-- function THfundView.BuyCardMoney( self )
--     print("转入购买网页")
--     gc.SDKManager:getInstance():recharge()
-- end

function THfundView.unregister(self)
   self.pMediator : destroy()
   self.pMediator = nil 
end

return THfundView