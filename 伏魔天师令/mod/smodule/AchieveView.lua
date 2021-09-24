local AchieveView = classGc(view, function(self)
	self.pMediator = require("mod.smodule.AchieveMediator")()
    self.pMediator : setView(self)

    self.nowType = 1
    self.achieveLab={}
    self.achieveBtn={}
    self.achieveLod={}
    self.achieveSpr={}
end)

local m_Count = 5
local FONTSIZE= 20
local winSize  = cc.Director : getInstance() : getVisibleSize()
local rightSize = cc.size(622,510)
local m_data=_G.Cfg.achieve

function AchieveView.create(self)
	self.AchieveView = require("mod.general.TabLeftView")()
	self.m_rootLayer= self.AchieveView : create("成就")

    local tempScene=cc.Scene:create()
    tempScene:addChild(self.m_rootLayer)

	local function closeCallBack()
		print("关闭成就")
		self:CloseWindow()
	end
	self.AchieveView : addCloseFun(closeCallBack)

  	self.rebateNode = cc.Node:create()
    self.rebateNode : setPosition(winSize.width*0.5,winSize.height*0.5)
    self.m_rootLayer : addChild(self.rebateNode,10)

    -- self:LeftBtnView()
    self : networksend()
	return tempScene
end

function AchieveView.networksend( self )
    local msg = REQ_ACHIEVE_REQ_POINT()
    _G.Network : send( msg)
end

function AchieveView.LeftBtnView( self,_count,_msg)
    print("LeftBtnView===>>>",_count,_msg)
    if self.tagContainer~=nil then
        for i=1,_count do
            local rewardIconCount=_msg[i].number
            if rewardIconCount>=0 then
                self.AchieveView:setTagIconNum(_msg[i].type,rewardIconCount)
            end 
        end
        return
    end

	local function tabOfFun(tag)
		self : tabOperate(tag,msg) 
	end
	self.AchieveView : addTabFun(tabOfFun)
	self.tagContainer = {}
    self.m_ScrollView = {} 
	for i=1,#m_data do
		print("sadasdasda==>",i,m_data[i].name,_msg[i].number)
		self.AchieveView : addTabButton(m_data[i].name, i)
		self.tagContainer[i] = cc.Node:create()
    	self.rebateNode : addChild(self.tagContainer[i])

        local rewardIconCount=_msg[i].number
        if rewardIconCount>0 then
            self.AchieveView:setTagIconNum(_msg[i].type,rewardIconCount)
        end 
	end

	-- 默认页面
	self.AchieveView : selectTagByTag(self.nowType)
    self : AchieveScrollView(self.nowType)
end

function AchieveView.AchieveScrollView(self,tag)
    -- print("AchieveScrollView===>>>>",tag,self.m_ScrollView[tag])
    if self.m_ScrollView[tag]~=nil then return end

    local ScrollView  = cc.ScrollView : create()
    self.m_ScrollView[tag] = ScrollView

    local zongzhi = #m_data[tag]
    print("总值======》》》》",zongzhi)

    self.oneHeight = (rightSize.height)/m_Count
    local viewSize = cc.size(rightSize.width, rightSize.height)
    self.containerSize = cc.size(rightSize.width, self.oneHeight*zongzhi)

    ScrollView : setDirection(ccui.ScrollViewDir.vertical)
    ScrollView : setViewSize(viewSize)
    ScrollView : setContentSize(self.containerSize)
    ScrollView : setContentOffset( cc.p( 0, viewSize.height-self.containerSize.height))
    ScrollView : setPosition(cc.p(-201, -298))
    print("容器大小：",self.oneHeight*zongzhi)
    ScrollView : setBounceable(false)
    ScrollView : setTouchEnabled(true)
    ScrollView : setDelegate()
    self.tagContainer[tag] : addChild(ScrollView)
    
    local barView=require("mod.general.ScrollBar")(ScrollView)
    barView:setPosOff(cc.p(-5,0))

    for i=1,zongzhi do
        local OneReward = self : Widgetreturn(i,m_data[tag][i])
        OneReward : setPosition(cc.p(rightSize.width/2,self.containerSize.height-self.oneHeight/2-(i-1)*self.oneHeight-1))
        ScrollView : addChild(OneReward)
        self.achieveSpr[tag..i]=OneReward
    end

    local msg = REQ_ACHIEVE_REQUEST()
    msg       : setArgs(tag)
    _G.Network: send(msg)
end

function AchieveView.Widgetreturn(self,index,_data)
    local Widget = ccui.Scale9Sprite : createWithSpriteFrameName("general_isit.png")
    Widget : setContentSize(cc.size(rightSize.width-10,self.oneHeight-4))

    local iconBg = cc.Sprite:createWithSpriteFrameName("general_tubiaokuan.png")
    iconBg : setPosition(cc.p(65, self.oneHeight/2))
    Widget : addChild(iconBg)

    local function cFun(sender,eventType)
        if eventType==ccui.TouchEventType.ended then
            local btn_tag=sender:getTag()
            local _pos = sender:getWorldPosition()
            local temp = _G.TipsUtil:createById(btn_tag,nil,_pos)
            cc.Director:getInstance():getRunningScene():addChild(temp,1000)
        end
    end
    goodData=_G.Cfg.goods[_data.reward[1]]
    local btnSize=iconBg:getContentSize()
    local rewardSpr = _G.ImageAsyncManager:createGoodsBtn(goodData,cFun,goodData.id,_data.reward[2])
    rewardSpr : setPosition(btnSize.width/2,btnSize.height/2)
    iconBg : addChild(rewardSpr) 

    local labWidth=rightSize.width/2-60
    local titleLab1=_G.Util:createLabel(_data.des,FONTSIZE+4)
    titleLab1:setPosition(labWidth,self.oneHeight/2+15)
    Widget:addChild(titleLab1)
    
    local titleLab2=_G.Util:createLabel(_data.must.arg1,FONTSIZE+4)
    local labWidth=labWidth+titleLab1:getContentSize().width/2+titleLab2:getContentSize().width/2
    titleLab2:setPosition(labWidth,self.oneHeight/2+15)
    titleLab2:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
    Widget:addChild(titleLab2)

    local labWidth=labWidth+titleLab2:getContentSize().width/2+12
    local titleLab3=_G.Util:createLabel(_data.des1 or "",FONTSIZE+4)
    titleLab3:setPosition(labWidth,self.oneHeight/2+15)
    Widget:addChild(titleLab3)

    local expBgSpr = cc.Sprite:createWithSpriteFrameName("achieve_expbg.png")
    expBgSpr : setPosition(cc.p(rightSize.width/2-30, self.oneHeight/2-20))
    Widget : addChild(expBgSpr)

    local nowNum=0
    local allNum=_data.must.arg1
    local parent=nowNum/allNum

    local expLab=_G.Util:createLabel(string.format("%d/%d",nowNum,allNum),FONTSIZE)
    expLab : setPosition(rightSize.width/2-30, self.oneHeight/2-20)
    Widget : addChild(expLab,10)
    self.achieveLab[_data.id..index]=expLab

    local expLoading = ccui.LoadingBar:create()
    expLoading : loadTexture("achieve_exp.png",ccui.TextureResType.plistType)
    expLoading : setAnchorPoint( 0, 0 )
    expLoading : setPosition( 10, 0 )
    expLoading : setPercent( parent )  -- 缩放
    expBgSpr   : addChild( expLoading )
    self.achieveLod[_data.id..index]=expLoading

    local function benCallBack(sender, eventType) 
        if eventType==ccui.TouchEventType.ended then
            local tag=sender:getTag()
            local nPos=sender:getWorldPosition()
            print("benCallBack+++++>>>>>>",tag,self.nowType)
            if nPos.y>winSize.height/2+rightSize.height/2-50 
            or nPos.y<winSize.height/2-rightSize.height/2-30
            then return end
            local msg = REQ_ACHIEVE_GET_REWARD()
            msg       : setArgs(self.nowType,tag)
            _G.Network: send(msg)
        end
    end

    local rewardBtn = gc.CButton:create("general_btn_gold.png")
    rewardBtn : addTouchEventListener(benCallBack)
    rewardBtn : setTag(index)
    rewardBtn : setEnabled(false)
    rewardBtn : setBright(false)
    rewardBtn : setTitleText("未达成")
    rewardBtn : setTitleFontSize(FONTSIZE)
    rewardBtn : setTitleFontName(_G.FontName.Heiti)
    rewardBtn : setPosition(cc.p(rightSize.width-100,self.oneHeight/2))
    Widget : addChild(rewardBtn)
    self.achieveBtn[_data.id..index]=rewardBtn

    return Widget
end

function AchieveView.pushData(self,_data)
    print("pushdata=====>>>>>",self.nowType,_data.count,_data.data)
    local msgdata=_data.data
    local index = 0
    local oneNum=0
    local twoNum=0
    for k,v in pairs(self.achieveLab) do
        print(k,v)
    end
    for i=1,_data.count do
        local allNum=m_data[self.nowType][i].must.arg1
        local nowNum=msgdata[i].class
        local parent=nowNum<allNum and nowNum/allNum*100 or 100
        local isTrue=false
        local btnStr="未达成"
        if msgdata[i].state==1 then
            isTrue=true
            btnStr="领  取"
            oneNum=oneNum+1
            index=oneNum
        elseif msgdata[i].state==2 then
            btnStr="已达成"
            index=_data.count-twoNum
            twoNum=twoNum+1
        else
            oneNum=oneNum+1
            index=oneNum
        end
        print("self.achieveLab====>>>",self.nowType..i)
        self.achieveLab[self.nowType..i]:setString(string.format("%d/%d",nowNum,allNum))
        self.achieveLod[self.nowType..i]:setPercent(parent)
        self.achieveBtn[self.nowType..i]:setBright(isTrue)
        self.achieveBtn[self.nowType..i]:setEnabled(isTrue)
        self.achieveBtn[self.nowType..i]:setTitleText(btnStr)
        self.achieveSpr[self.nowType..i] : setPosition(cc.p(rightSize.width/2,self.containerSize.height-self.oneHeight/2-(index-1)*self.oneHeight-1))
    end
end

function AchieveView.tabOperate( self, _tag )
	print("SettingView --- tag --->",_tag)
	for i=1,#m_data do
        if i ~= _tag then
            -- print("self.tagContainer setVisible false----------")
            self.tagContainer[i] : setVisible(false)

        else
            -- print("self.tagContainer setVisible true--------")
            self.tagContainer[i] : setVisible(true)
            self.nowType=_tag
            self:AchieveScrollView(_tag)
        end
    end
end

function AchieveView.CloseWindow(self)
    if self.m_rootLayer == nil then return end
    self.m_rootLayer=nil
   	self : unregister()

	cc.Director:getInstance():popScene()
end

function AchieveView.unregister(self)
   self.pMediator : destroy()
   self.pMediator = nil 
end

return AchieveView