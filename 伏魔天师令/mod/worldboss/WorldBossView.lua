local WorldBossView = classGc(view, function(self)

	self.m_mediator =require("mod.worldboss.WorldBossMediator")() 
    self.m_mediator:setView(self) 
end)
local fontSize=22
local openType=1
function WorldBossView.create( self )
	self.m_normalView = require("mod.general.NormalView")()
	self.mainLayer=self.m_normalView:create()
	--self.m_normalView :setTitle("maintitle_sjyw.png")

    local tempScene=cc.Scene:create()
    tempScene:addChild(self.mainLayer)
    
    self:REQ_WORLD_BOSS_REQUEST() 
	self:initView()
	return tempScene
end
function WorldBossView.initView( self ) 
    self.m_normalView :setTitle("勾魂使者")  
	local function closeBtnCallback( sender,eventType )
        if eventType == ccui.TouchEventType.ended then
            if openType==2 then 
                print("关闭排行榜")                              
                self.m_secNode :setVisible(false)
                self.mainNode:setVisible(true)
                self.m_normalView :setTitle("勾魂使者")
                openType=1 
                self:cleanFun()
            end
        end
    end
    local function closeFun()
        self : unregister()
        if self.mainLayer == nil then return end
        self.mainLayer=nil
        cc.Director:getInstance():popScene() 
    end
    self.m_normalView:addCloseFun(closeFun)

	self.m_winSize=cc.Director:getInstance():getWinSize()
    self.mainNode=cc.Node:create()
    self.mainNode:setPosition(self.m_winSize.width/2,self.m_winSize.height/2)
    self.mainLayer:addChild(self.mainNode)
    self:addWorldBossRank()
    

    -- local secondSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_fram_jianbian.png",cc.rect(24,24,1,1))
    -- secondSpr:setPreferredSize(cc.size(776,460))
    -- secondSpr:setPosition(0,-20)
    -- self.mainNode:addChild(secondSpr,1)
      
	local leftBgSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
	leftBgSpr:setPreferredSize(cc.size(846,492))
	leftBgSpr:setPosition(0,-20)
	self.mainNode:addChild(leftBgSpr)

    self.leftBoosSpr=cc.Sprite:create("ui/bg/boss_doudawang.jpg") 
    self.leftBoosSpr:setAnchorPoint(0,0)
    self.leftBoosSpr:setPosition(7,7)
    leftBgSpr:addChild(self.leftBoosSpr)

    -- self.left_dins=ccui.Scale9Sprite:createWithSpriteFrameName("boss_dins.png")
    -- self.left_dins:setAnchorPoint(0,0)
    -- self.left_dins:setPreferredSize(cc.size(self.left_dins:getContentSize().width,437))
    -- self.left_dins:setPosition(13,10)
    -- secondSpr:addChild(self.left_dins,1)
      
    self.rightBoosSpr=cc.Sprite:create("ui/bg/boss_heixiongjing.jpg") 
    self.rightBoosSpr:setAnchorPoint(0,0)
    self.rightBoosSpr:setPosition(425,7)
    leftBgSpr:addChild(self.rightBoosSpr)

    -- self.right_dins=ccui.Scale9Sprite:createWithSpriteFrameName("boss_dins.png")
    -- self.right_dins:setAnchorPoint(0,0)
    -- self.right_dins:setPosition(392,10)
    -- self.right_dins:setPreferredSize(cc.size(self.right_dins:getContentSize().width,440))
    -- secondSpr:addChild(self.right_dins,1)
    -- self.right_dins=cc.Node:create()
    -- self.right_dins:setAnchorPoint(0,0)
    -- self.right_dins:setPosition(392,10)
    -- self.right_dins:setContentSize(cc.size(self.right_dins:getContentSize().width,440))
    -- secondSpr:addChild(self.right_dins,1)

    self.leftDiwenSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_voice_dins.png")    -- 底纹
    self.leftDiwenSpr:setOpacity(180)
    self.leftDiwenSpr:setAnchorPoint(0,0)
    self.leftDiwenSpr:setPreferredSize(cc.size(self.leftBoosSpr:getContentSize().width-4,145))
    self.leftDiwenSpr:setPosition(2,90)
    self.leftBoosSpr:addChild(self.leftDiwenSpr)

    self.rightDiwenSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_voice_dins.png")    -- 底纹
    self.rightDiwenSpr:setOpacity(180)
    self.rightDiwenSpr:setAnchorPoint(0,0)
    self.rightDiwenSpr:setPreferredSize(cc.size(self.rightBoosSpr:getContentSize().width-4,145))
    self.rightDiwenSpr:setPosition(2,90)
    self.rightBoosSpr:addChild(self.rightDiwenSpr)

    self.ldoubleLab= _G.Util:createLabel("(双倍奖励)",20)
    self.ldoubleLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORANGE))
    self.ldoubleLab : setAnchorPoint(cc.p(0,0))
    self.ldoubleLab : setPosition(250,10)
    self.ldoubleLab : setVisible(false)
    self.leftDiwenSpr : addChild(self.ldoubleLab)

    self.rdoubleLab= _G.Util:createLabel("(双倍奖励)",20)
    self.rdoubleLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORANGE))
    self.rdoubleLab : setAnchorPoint(cc.p(0,0))
    self.rdoubleLab : setPosition(250,10)
    self.rdoubleLab : setVisible(false)
    self.rightDiwenSpr : addChild(self.rdoubleLab)

    self:addLeftLab()
    self:addRightLab()
    self:addBtn(self.mainNode) 
end
function WorldBossView.addBtn( self,m_mainNode )
    -- body
    local function leftRankBtnCallback( sender,eventType )
        if eventType==ccui.TouchEventType.ended then
        self:REQ_WORLD_BOSS_ASK_SETTLE(1) -- 请求排行榜
        end
    end
    local function leftChallengeBtnCallback( sender,eventType )
        if eventType==ccui.TouchEventType.ended then
        print("请求进入boss1场景:61110")
        self:REQ_SCENE_ENTER_FLY(61110)
        end
    end
    local function rightRankBtnCallback( sender,eventType )
        if eventType==ccui.TouchEventType.ended then
        print("排行榜2")
        self:REQ_WORLD_BOSS_ASK_SETTLE(2)     
        end
    end
    local function brightChallengeBtnCallback( sender,eventType )
        if eventType==ccui.TouchEventType.ended then
        print("发送请求进入boss2场景:61120")
        self:REQ_SCENE_ENTER_FLY(61120)
        end
    end
    local function RmbBtnCallback( sender,eventType )
        if eventType==ccui.TouchEventType.ended then
            local tag=sender:getTag()
            print("元宝召唤boss",tag)
            self:RmbZHCallBack(tag)
        end
    end

    self.leftRankBtn = gc.CButton:create("general_btn_lv.png")
    self.leftRankBtn:setTitleText("查看排名")
    self.leftRankBtn:setTitleFontName(_G.FontName.Heiti)
    self.leftRankBtn:setTitleFontSize(fontSize)
    self.leftRankBtn:setPosition(cc.p(-300,-215))
    self.leftRankBtn:addTouchEventListener(leftRankBtnCallback)
    m_mainNode:addChild(self.leftRankBtn,3)
    
    self.leftChallengeBtn = gc.CButton:create("general_btn_gold.png")
    self.leftChallengeBtn:setTitleText("进入挑战")
    self.leftChallengeBtn:setTitleFontName(_G.FontName.Heiti)
    self.leftChallengeBtn:setTitleFontSize(fontSize)
    self.leftChallengeBtn:setPosition(cc.p(-115,-215))
    --self.leftChallengeBtn:enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
    self.leftChallengeBtn:addTouchEventListener(leftChallengeBtnCallback)
    m_mainNode:addChild(self.leftChallengeBtn,3)

    self.rightRankBtn = gc.CButton:create("general_btn_lv.png")
    self.rightRankBtn:setTitleText("查看排名")
    self.rightRankBtn:setTitleFontName(_G.FontName.Heiti)
    self.rightRankBtn:setTitleFontSize(fontSize)
    self.rightRankBtn:setPosition(cc.p(115,-215))
    self.rightRankBtn:addTouchEventListener(rightRankBtnCallback)
    m_mainNode:addChild(self.rightRankBtn,3)
    
    self.rightChallengeBtn = gc.CButton:create("general_btn_gold.png")
    self.rightChallengeBtn:setTitleText("进入挑战")
    self.rightChallengeBtn:setTitleFontName(_G.FontName.Heiti)
    self.rightChallengeBtn:setTitleFontSize(fontSize)
    self.rightChallengeBtn:setPosition(cc.p(305,-215))
    --self.rightChallengeBtn:enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
    self.rightChallengeBtn:addTouchEventListener(brightChallengeBtnCallback)
    m_mainNode:addChild(self.rightChallengeBtn,3)

    self.leftRmbBtn = gc.CButton:create("boss_ewzf_btn.png")
   -- self.leftRmbBtn:setTitleText("元宝召唤")
    -- self.leftRmbBtn:setTitleFontName(_G.FontName.Heiti)
    -- self.leftRmbBtn:setTitleFontSize(fontSize)
    self.leftRmbBtn:setPosition(cc.p(-360,170))
    self.leftRmbBtn:setTag(1)
    self.leftRmbBtn:addTouchEventListener(RmbBtnCallback)
    m_mainNode:addChild(self.leftRmbBtn,3)

    self.rightRmbBtn = gc.CButton:create("boss_ewzf_btn.png")
    --self.rightRmbBtn:setTitleText("元宝召唤")
    -- self.rightRmbBtn:setTitleFontName(_G.FontName.Heiti)
    -- self.rightRmbBtn:setTitleFontSize(fontSize)
    self.rightRmbBtn:setPosition(cc.p(55,170))
    self.rightRmbBtn:setTag(2)
    self.rightRmbBtn:addTouchEventListener(RmbBtnCallback)
    m_mainNode:addChild(self.rightRmbBtn,3)
end

function WorldBossView.RmbZHCallBack( self,_tag)
    local data =  _G.Cfg.world_boss_desc[_tag]
    local ZHViewSize=cc.size(420,387)
    local myZBView  = require( "mod.general.BattleMsgView")()
    local ZB_D2Base = myZBView : create("召唤BOSS",ZHViewSize)
    local m_mainSize = cc.size(400,245)

    local di2kuan = myZBView : initView("召唤BOSS")
    di2kuan:setContentSize(m_mainSize)
    di2kuan:setPosition(ZHViewSize.width/2,ZHViewSize.height/2+23)

    local function CallBack(sender,eventType) 
       if eventType == ccui.TouchEventType.ended then 
            print("确定召唤")
            local msg = REQ_WORLD_BOSS_BUY_REQ () 
            msg : setArgs(_tag)
            _G.Network : send(msg)

            myZBView:delayCallFun()
        end 
    end 
    local DetermineBtn = gc.CButton : create ("general_btn_gold.png")
    DetermineBtn : setTitleFontName(_G.FontName.Heiti)
    DetermineBtn : setTitleFontSize(fontSize)
    DetermineBtn : setTitleText("确 定")
    DetermineBtn : setPosition(m_mainSize.width/2,-35)
    DetermineBtn : addTouchEventListener(CallBack)
    DetermineBtn : setBright(false)
    DetermineBtn : setEnabled(false)
    di2kuan : addChild(DetermineBtn,10)
    self.m_DetermineBtn = DetermineBtn

    local lineSpr = ccui.Scale9Sprite : createWithSpriteFrameName("general_double_line.png")
    lineSpr : setPreferredSize(cc.size(m_mainSize.width-18,2))
    lineSpr : setPosition(cc.p(m_mainSize.width/2,m_mainSize.height/2-34))
    di2kuan : addChild(lineSpr)

    local goodSpr = cc.Sprite : createWithSpriteFrameName("general_xianYu.png")
    goodSpr : setPosition(cc.p(m_mainSize.width/2-30,-73))
    di2kuan : addChild(goodSpr)

    self.m_CostLab = _G.Util : createLabel ("",fontSize)
    self.m_CostLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
    self.m_CostLab : setPosition(cc.p(m_mainSize.width/2-10,-73))
    self.m_CostLab : setAnchorPoint(cc.p(0,0.5))
    di2kuan : addChild(self.m_CostLab)

    local timeStr = string.format("每天%s-%s",data.call_start_time,data.call_end_time)
    local strTab = {"召唤时间:","召唤需求:","活动奖励:","个人剩余召唤次数:","世界剩余召唤次数:"}
    local tableStr = {timeStr,"竞技场排名前10名","召唤者可获得双倍铜钱奖励","",""}

    local StrLab={}
    local tableLab={}
    for i = 1,#strTab do 
        StrLab[i] = _G.Util : createLabel(strTab[i],fontSize)
        StrLab[i] : setAnchorPoint(cc.p(0,0.5))
        StrLab[i] : setPosition(cc.p(15,m_mainSize.height-30-(i-1)*34))
        di2kuan : addChild(StrLab[i])

        tableLab[i]   = _G.Util : createLabel(tableStr[i],fontSize )
        -- tableLab[i]   : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
        tableLab[i]   : setAnchorPoint( cc.p(0,0.5) )
        tableLab[i]   : setPosition(cc.p(m_mainSize.width/2-78,m_mainSize.height-30-(i-1)*34))
        di2kuan : addChild(tableLab[i])

        if i > 3 then 
            StrLab[i] : setPosition(cc.p(90,m_mainSize.height-80-(i-1)*34))
            tableLab[i] : setPosition(cc.p(m_mainSize.width/2+80,m_mainSize.height-80-(i-1)*34))
            tableLab[i] : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
        end
    end 

    -- local rewardLab = _G.Util : createLabel("",fontSize)
    -- rewardLab : setPosition(cc.p(m_mainSize.width/2-78,m_mainSize.height/2-10))
    -- rewardLab : setAnchorPoint( cc.p(0,0.5) )
    -- di2kuan : addChild(rewardLab)

    self.m_ranKing = tableLab[2]
    self.m_Num1 = tableLab[4]
    self.m_Num2 = tableLab[5]
    
    local msg = REQ_WORLD_BOSS_BUY_INFO()
    msg : setArgs(_tag)
    _G.Network : send(msg)
end

function WorldBossView.updateZHLab(self,_data)
    self.m_ranKing : setString(string.format("竞技场排名前%d名", _data.call_demand or 10))
    self.m_Num1 : setString(_data.p_call_time or 0)
    self.m_Num2 : setString(_data.w_call_time or 0)
    self.m_CostLab: setString(_data.call_cost or 0)
    if _data.flag==0 then
        self.m_DetermineBtn:setBright(false)
        self.m_DetermineBtn:setEnabled(false)
    else
        self.m_DetermineBtn:setBright(true)
        self.m_DetermineBtn:setEnabled(true)
    end
end 

function WorldBossView.addLeftLab( self)
    -- body
    -- local tipsIcon = cc.Sprite:createWithSpriteFrameName("general_tanhao.png")
    -- tipsIcon : setAnchorPoint(cc.p(0,0))
    -- tipsIcon : setPosition(10,85)
    -- self.leftDiwenSpr : addChild(tipsIcon) 
    local text1="注:该场景不会受到其他玩家的攻击！"

    local leftAttentionLab = _G.Util:createLabel(text1,20)
    leftAttentionLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
    leftAttentionLab : setAnchorPoint(cc.p(0,0))
    leftAttentionLab : setPosition(10,110)   
    self.leftDiwenSpr : addChild(leftAttentionLab)
    
    local leftActivityTime = _G.Util:createLabel("活动时间:",20)
    -- leftActivityTime : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    leftActivityTime : setAnchorPoint(cc.p(0,0))
    leftActivityTime : setPosition(10,75)
    self.leftDiwenSpr : addChild(leftActivityTime)

    local leftGradeLimit = _G.Util:createLabel("等级需要:",20)
    -- leftGradeLimit : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    leftGradeLimit : setAnchorPoint(cc.p(0,0))
    leftGradeLimit : setPosition(10,42)
    self.leftDiwenSpr : addChild(leftGradeLimit)

    local leftActivityAward = _G.Util:createLabel("活动奖励:",20)
    -- leftActivityAward : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    leftActivityAward : setAnchorPoint(cc.p(0,0))
    leftActivityAward : setPosition(10,10)
    self.leftDiwenSpr : addChild(leftActivityAward)
    
    self.leftTimeLab = _G.Util:createLabel("",20)
    self.leftTimeLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
    self.leftTimeLab : setAnchorPoint(cc.p(0,0))
    self.leftTimeLab : setPosition(115,75)
    self.leftDiwenSpr : addChild(self.leftTimeLab)

    self.leftGradeLab = _G.Util:createLabel("",20)
    self.leftGradeLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
    self.leftGradeLab : setAnchorPoint(cc.p(0,0))
    self.leftGradeLab : setPosition(115,42)
    self.leftDiwenSpr : addChild(self.leftGradeLab)

    self.leftAwardLab= _G.Util:createLabel("",20)
    self.leftAwardLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
    self.leftAwardLab : setAnchorPoint(cc.p(0,0))
    self.leftAwardLab : setPosition(115,10)
    self.leftDiwenSpr : addChild(self.leftAwardLab)
    self:setLeftLab()
end
function WorldBossView.addRightLab( self)
    -- body
    -- local tipsIcon = cc.Sprite:createWithSpriteFrameName("general_tanhao.png")
    -- tipsIcon : setAnchorPoint(cc.p(0,0))
    -- tipsIcon : setPosition(10,85)
    -- self.rightDiwenSpr : addChild(tipsIcon)

    local text1="注:该场景会受到其他玩家的攻击!"

    local rightAttentionLab = _G.Util:createLabel(text1,20)
    rightAttentionLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
    rightAttentionLab : setAnchorPoint(cc.p(0,0))
    rightAttentionLab : setPosition(10,110)
    self.rightDiwenSpr : addChild(rightAttentionLab)
    
    local rightActivityTime = _G.Util:createLabel("活动时间:",20)
    -- rightActivityTime : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    rightActivityTime : setAnchorPoint(cc.p(0,0))
    rightActivityTime : setPosition(10,75)
    self.rightDiwenSpr : addChild(rightActivityTime)

    local rightGradeLimit = _G.Util:createLabel("等级需要:",20)
    -- rightGradeLimit : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    rightGradeLimit : setAnchorPoint(cc.p(0,0))
    rightGradeLimit : setPosition(10,42)
    self.rightDiwenSpr : addChild(rightGradeLimit)

    local rightActivityAward = _G.Util:createLabel("活动奖励:",20)
    -- rightActivityAward : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    rightActivityAward : setAnchorPoint(cc.p(0,0))
    rightActivityAward : setPosition(10,10)
    self.rightDiwenSpr : addChild(rightActivityAward)
    
    self.rightTimeLab = _G.Util:createLabel("",20)
    self.rightTimeLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
    self.rightTimeLab : setAnchorPoint(cc.p(0,0))
    self.rightTimeLab : setPosition(115,75)
    self.rightDiwenSpr : addChild(self.rightTimeLab)

    self.rightGradeLab = _G.Util:createLabel("",20)
    self.rightGradeLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
    self.rightGradeLab : setAnchorPoint(cc.p(0,0))
    self.rightGradeLab : setPosition(115,42)
    self.rightDiwenSpr : addChild(self.rightGradeLab)

    self.rightAwardLab= _G.Util:createLabel("",20)
    self.rightAwardLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
    self.rightAwardLab : setAnchorPoint(cc.p(0,0))
    self.rightAwardLab : setPosition(115,10)
    self.rightDiwenSpr : addChild(self.rightAwardLab)   
    self:setRightLab() 
end

function WorldBossView.setLeftLab( self )  

    if self.leftTimeLab~=nil then
        local startTime="每天".._G.Cfg.world_boss_desc[1].start_time.."-".._G.Cfg.world_boss_desc[1].end_time
        self.leftTimeLab:setString(startTime)
    end
    if self.leftGradeLab~=nil then
        local limitLv="≥".._G.Cfg.world_boss_desc[1].lv.."级"
        self.leftGradeLab:setString(limitLv)
    end
    if self.leftAwardLab~=nil then
        local reWard=_G.Cfg.world_boss_desc[1].reward
        self.leftAwardLab:setString(reWard)
    end
end
function WorldBossView.setRightLab( self )
    
    if self.rightTimeLab~=nil then
        local startTime="每天".._G.Cfg.world_boss_desc[2].start_time.."-".._G.Cfg.world_boss_desc[2].end_time
        self.rightTimeLab:setString(startTime)
    end
    if self.rightGradeLab~=nil then
        local limitLv="≥".._G.Cfg.world_boss_desc[2].lv.."级"
        self.rightGradeLab:setString(limitLv)
    end
    if self.rightAwardLab~=nil then
        local reWard=_G.Cfg.world_boss_desc[2].reward
        self.rightAwardLab:setString(reWard)
    end
end
function WorldBossView.setBossState(self,_bossData,_bossNum,_value)
    self.value=_value
    if _value~=nil then
        self:isDouble()
    end

    self.bossData=_bossData
    local _bossState1=0
    local _bossState2=0
    if _bossNum~=0 then
        for index=1,_bossNum do
            if self.bossData[index].type==1 then              -- 第一个boss的状态
                if self.bossData[index].state==0 then
                _bossState1=0
                print("boss1未刷新")
                elseif self.bossData[index].state==1 then
                _bossState1=1
                print("boss1已刷新")
                elseif self.bossData[index].state==2 then
                _bossState1=2
                print("boss1已杀死")
                elseif self.bossData[index].state==3 then
                _bossState1=3
                print("boss1逃脱")
                end
            end
            if self.bossData[index].type==2 then              -- 第二个boss的状态
                if self.bossData[index].state==0 then
                _bossState2=0
                print("boss2未刷新")
                elseif self.bossData[index].state==1 then
                _bossState2=1
                print("boss2已刷新")
                elseif self.bossData[index].state==2 then
                _bossState2=2
                print("boss2已杀死")
                end
            end
        end
    end

    if _bossState1==0 then
        --local size1=self.leftBoosSpr:getContentSize()
        --local color1=cc.LayerColor:create(cc.c4b(0,0,0,180))
        --color1:setContentSize(size1)
        --self.leftBoosSpr:addChild(color1)
    elseif _bossState1==1 then
    	local killIcon = cc.Sprite:createWithSpriteFrameName("boss_current.png")
        killIcon : setAnchorPoint(cc.p(0,0))
        killIcon : setPosition(230,300)
        self.leftBoosSpr : addChild(killIcon)
    elseif _bossState1==2 then 
        local killIcon = cc.Sprite:createWithSpriteFrameName("boss_kill.png")
        killIcon : setAnchorPoint(cc.p(0,0))
        killIcon : setPosition(230,300)
        self.leftBoosSpr : addChild(killIcon)
    elseif _bossState1==3 then 
        local killIcon = cc.Sprite:createWithSpriteFrameName("boss_loser.png")
        killIcon : setAnchorPoint(cc.p(0,0))
        killIcon : setPosition(230,300)
        self.leftBoosSpr : addChild(killIcon)   
    end

    if _bossState2==0 then

    elseif _bossState2==1 then
    	local killIcon = cc.Sprite:createWithSpriteFrameName("boss_current.png")
        killIcon : setAnchorPoint(cc.p(0,0))
        killIcon : setPosition(230,300)
        self.rightBoosSpr : addChild(killIcon)
    elseif _bossState2==2 then 
        local killIcon = cc.Sprite:createWithSpriteFrameName("boss_kill.png")
        killIcon : setAnchorPoint(cc.p(0,0))
        killIcon : setPosition(230,300)
        self.rightBoosSpr : addChild(killIcon) 
    end
end

function WorldBossView.addWorldBossRank( self )
    -- body
    self.m_secNode = cc.Sprite:create()
    self.mainLayer:addChild(self.m_secNode)
    self.m_secNode:setPosition((self.m_winSize.width-1136)/2,self.m_winSize.height-640)
    self.m_secNode:setVisible(false)
    self:_initView()
end 
function WorldBossView._initView( self )   
    local secondSprite=ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png",cc.rect(24,24,1,1))
    secondSprite:setPreferredSize(cc.size(776,460))
    secondSprite:setPosition(570,300)
    self.m_secNode:addChild(secondSprite)
    local biankuangSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_double2.png")
    biankuangSpr:setPreferredSize(cc.size(755,450))
    biankuangSpr:setPosition(387,230)
    secondSprite:addChild(biankuangSpr)

    local rank_Lab1= _G.Util : createLabel("排名", fontSize)
    rank_Lab1 : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
    rank_Lab1 : setPosition(cc.p(60,430)) 
    secondSprite : addChild(rank_Lab1)

    local rank_Lab2= _G.Util : createLabel("玩家名称", fontSize-2)
    rank_Lab2 : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
    rank_Lab2 : setPosition(cc.p(165,430)) 
    secondSprite : addChild(rank_Lab2)

    local rank_Lab3= _G.Util : createLabel("等级", fontSize-2)
    rank_Lab3 : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
    rank_Lab3 : setPosition(cc.p(270,430)) 
    secondSprite : addChild(rank_Lab3)

    local rank_Lab4= _G.Util : createLabel("职业", fontSize-2)
    rank_Lab4 : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
    rank_Lab4 : setPosition(cc.p(360,430)) 
    secondSprite : addChild(rank_Lab4)

    local rank_Lab5= _G.Util : createLabel("战斗力", fontSize-2)
    rank_Lab5 : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
    rank_Lab5 : setPosition(cc.p(465,430)) 
    secondSprite : addChild(rank_Lab5)

    local rank_Lab6= _G.Util : createLabel("伤害", fontSize-2)
    rank_Lab6 : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
    rank_Lab6 : setPosition(cc.p(570,430)) 
    secondSprite : addChild(rank_Lab6)

    local rank_Lab7= _G.Util : createLabel("奖励铜钱", fontSize-2)
    rank_Lab7 : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
    rank_Lab7 : setPosition(cc.p(684,430)) 
    secondSprite : addChild(rank_Lab7)

    local rank_Line1 = ccui.Scale9Sprite : createWithSpriteFrameName("general_double_line.png")
    rank_Line1 : setPreferredSize(cc.size(751,4))
    rank_Line1 : setOpacity(120)    
    rank_Line1 : setPosition(cc.p(388,405))
    secondSprite : addChild(rank_Line1)
    for index=1,10 do
        local rank_Line2 = ccui.Scale9Sprite : createWithSpriteFrameName("general_double_line.png")
        rank_Line2 : setPreferredSize(cc.size(734,2))
        rank_Line2 : setPosition(cc.p(388,405-index*31.5))
        secondSprite : addChild(rank_Line2)
    end
    local rank_Line3 = ccui.Scale9Sprite : createWithSpriteFrameName("general_double_line.png")
    rank_Line3 : setPreferredSize(cc.size(751,4))
    rank_Line3 : setOpacity(120)    
    rank_Line3 : setPosition(cc.p(388,58))
    secondSprite : addChild(rank_Line3)
    self:setRankContent()
    
end
function WorldBossView.setRankContent( self)
    -- body
    for index=1,11 do
        local PosY=460-(index-1)*31.5
        local rtag=(index-1)*10
        self:addRankLab(rtag,PosY)
    end
end
function WorldBossView.addRankLab( self,kTag,pPosY)
    -- body
    local X=240
    local Y=pPosY
    
    local rankData_Lab1 = _G.Util:createLabel("",fontSize-2)               --排名
    rankData_Lab1 : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
    rankData_Lab1 : setAnchorPoint(cc.p(0.5,0.5))
    rankData_Lab1 : setPosition(X,Y)
    rankData_Lab1 : setTag(kTag+1)
    self.m_secNode: addChild(rankData_Lab1)

    local rankData_Lab2 = _G.Util:createLabel("",fontSize-2)      --玩家名字
    rankData_Lab2 : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORANGE))
    rankData_Lab2 : setAnchorPoint(cc.p(0.5,0.5))
    rankData_Lab2 : setPosition(X+105,Y)
    rankData_Lab2 : setTag(kTag+2)
    self.m_secNode: addChild(rankData_Lab2)

    local rankData_Lab3 = _G.Util:createLabel("",fontSize-2)               --玩家等级
    rankData_Lab3 : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_YELLOW))
    rankData_Lab3 : setAnchorPoint(cc.p(0.5,0.5))
    rankData_Lab3 : setPosition(X+210,Y)
    rankData_Lab3 : setTag(kTag+3)
    self.m_secNode: addChild(rankData_Lab3)

    local rankData_Lab4 = _G.Util:createLabel("",fontSize-2)          --玩家职位
    rankData_Lab4 : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    rankData_Lab4 : setAnchorPoint(cc.p(0.5,0.5))
    rankData_Lab4 : setPosition(X+300,Y)
    rankData_Lab4 : setTag(kTag+4)
    self.m_secNode: addChild(rankData_Lab4)

    local rankData_Lab5 = _G.Util:createLabel("",fontSize-2)         --战斗力
    rankData_Lab5 : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_YELLOW))
    rankData_Lab5 : setAnchorPoint(cc.p(0.5,0.5))
    rankData_Lab5 : setPosition(X+405,Y)
    rankData_Lab5 : setTag(kTag+5)
    self.m_secNode: addChild(rankData_Lab5)

    local rankData_Lab6 = _G.Util:createLabel("",fontSize-2)         --伤害
    rankData_Lab6 : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_YELLOW))
    rankData_Lab6 : setAnchorPoint(cc.p(0.5,0.5))
    rankData_Lab6 : setPosition(X+515,Y)
    rankData_Lab6 : setTag(kTag+6)
    self.m_secNode: addChild(rankData_Lab6)

    local rankData_Lab7 = _G.Util:createLabel("",fontSize-2)         --铜钱奖励
    rankData_Lab7 : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    rankData_Lab7 : setAnchorPoint(cc.p(0.5,0.5))
    rankData_Lab7 : setPosition(X+628,Y)
    rankData_Lab7 : setTag(kTag+7)
    self.m_secNode: addChild(rankData_Lab7)
end
function WorldBossView.lastAttack( self ) -- 最后一击
    -- body
    local _Y=100
    self.lastAttack_Lab1 = _G.Util:createLabel("最后一击",fontSize-2)
    self.lastAttack_Lab1 : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
    self.lastAttack_Lab1 : setAnchorPoint(cc.p(0.5,0.5))
    self.lastAttack_Lab1 : setPosition(375,_Y)
    self.m_secNode : addChild(self.lastAttack_Lab1)

    self.lastAttack_Lab2 = _G.Util:createLabel("",fontSize-2)
    self.lastAttack_Lab2 : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORANGE))
    self.lastAttack_Lab2 : setAnchorPoint(cc.p(0.5,0.5))
    self.lastAttack_Lab2 : setPosition(495,_Y)
    self.m_secNode : addChild(self.lastAttack_Lab2)

    self.lastAttack_Lab3 = _G.Util:createLabel("额外奖励:",fontSize-2)
    self.lastAttack_Lab3 : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    self.lastAttack_Lab3 : setAnchorPoint(cc.p(0.5,0.5))
    self.lastAttack_Lab3 : setPosition(635,_Y)
    self.m_secNode : addChild(self.lastAttack_Lab3)

    local tongqianSpr = ccui.Scale9Sprite : createWithSpriteFrameName("general_tongqian.png")
    tongqianSpr:setAnchorPoint(cc.p(0.5,0.5))
    tongqianSpr:setPosition(695,_Y)
    self.m_secNode:addChild(tongqianSpr)

    self.lastAttack_Lab4 = _G.Util:createLabel("",fontSize-2)
    self.lastAttack_Lab4 : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORANGE))
    self.lastAttack_Lab4 : setAnchorPoint(cc.p(0,0.5))
    self.lastAttack_Lab4 : setPosition(744,_Y)
    self.m_secNode : addChild(self.lastAttack_Lab4) 
end
function WorldBossView.bossEscape( self ) -- Boss逃脱
    -- body
    self.bossEscapeLab = _G.Util:createLabel("勾魂使者逃脱了",fontSize-2)
    self.bossEscapeLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
    self.bossEscapeLab : setAnchorPoint(cc.p(0.5,0.5))
    self.bossEscapeLab : setPosition(575,100)
    self.m_secNode : addChild(self.bossEscapeLab)  
end
-- function WorldBossView.setRankLab( self,_rankData,_rankmun) -- 设置前十名排行信息
--     self.rankData=_rankData
--     self.mainNode:setVisible(false)
--     openType=2  
     
--     self.m_normalView :setTitle("排名奖励") 
--     self.m_secNode:setVisible(true)
--     local rankNum=0 
--     local bossWin=1
--     for index=1,_rankmun do
--         if self.rankData[index].last_kill==0 then
--             rankNum=rankNum+1
--         end
--         if self.rankData[index].last_kill==1 then
--             bossWin=2
--             self:lastAttack()
--             self:setLastAttack(index)
--         end
--         if self.rankData[index].last_kill==2 then
--             self:setMyselfRank(index)
--         end
--     end
--     for index=1,rankNum do
--         local ranking=self.rankData[rankNum-index+1].rank     -- 排名
--         local name=self.rankData[rankNum-index+1].name        -- 姓名
--         local grade=self.rankData[rankNum-index+1].lv         -- 等级
--         local occupation=self.rankData[rankNum-index+1].pro   -- 职业
--         local force=self.rankData[rankNum-index+1].powerful   -- 战斗力
--         local harm=self.rankData[rankNum-index+1].harm        -- 伤害
--         local award=self.rankData[rankNum-index+1].gold       -- 奖励铜钱
--         local labTag=(index-1)*10
--         if self.m_secNode:getChildByTag(labTag+1)~=nil then
--             self.m_secNode:getChildByTag(labTag+1):setString(ranking)
--         end
--         if self.m_secNode:getChildByTag(labTag+2)~=nil then
--             self.m_secNode:getChildByTag(labTag+2):setString(name)
--         end
--         if self.m_secNode:getChildByTag(labTag+3)~=nil then
--             self.m_secNode:getChildByTag(labTag+3):setString(grade)
--         end
--         if self.m_secNode:getChildByTag(labTag+4)~=nil then
--             local text=10000+occupation
--             occupation=_G.Cfg.skill_skin[text].skin_name    
--             self.m_secNode:getChildByTag(labTag+4):setString(occupation)
--         end
--         if self.m_secNode:getChildByTag(labTag+5)~=nil then
--             self.m_secNode:getChildByTag(labTag+5):setString(force)
--         end
--         if self.m_secNode:getChildByTag(labTag+6)~=nil then
--             self.m_secNode:getChildByTag(labTag+6):setString(harm)
--         end
--         if self.m_secNode:getChildByTag(labTag+7)~=nil then
--             print("m_secNode",self.value)
--             if self.value~=nil then
--                 award=string.format("%sx%d",award,self.value)
--             end
--             self.m_secNode:getChildByTag(labTag+7):setString(award)
--         end
--     end
--     if bossWin==1 then
--         self:bossEscape()
--     end
-- end
function WorldBossView.cleanFun( self )
    -- body
    local text=""
    for index=1,11 do
        local labTag=10*(index-1)       
        if self.m_secNode:getChildByTag(labTag+1)~=nil then
            self.m_secNode:getChildByTag(labTag+1):setString(text)
        end
        if self.m_secNode:getChildByTag(labTag+2)~=nil then
            self.m_secNode:getChildByTag(labTag+2):setString(text)
        end
        if self.m_secNode:getChildByTag(labTag+3)~=nil then
            self.m_secNode:getChildByTag(labTag+3):setString(text)
        end
        if self.m_secNode:getChildByTag(labTag+4)~=nil then 
            self.m_secNode:getChildByTag(labTag+4):setString(text)
        end
        if self.m_secNode:getChildByTag(labTag+5)~=nil then
            self.m_secNode:getChildByTag(labTag+5):setString(text)
        end
        if self.m_secNode:getChildByTag(labTag+6)~=nil then
            self.m_secNode:getChildByTag(labTag+6):setString(text)
        end
        if self.m_secNode:getChildByTag(labTag+7)~=nil then
            self.m_secNode:getChildByTag(labTag+7):setString(text)
        end
    end 
    if self.lastAttack_Lab1~=nil then
        self.lastAttack_Lab1:setString(text)
    end
    if self.lastAttack_Lab2~=nil then
        self.lastAttack_Lab2:setString(text)
    end
    if self.lastAttack_Lab1~=nil then
        self.lastAttack_Lab1:setString(text)
    end
    if self.lastAttack_Lab3~=nil then
        self.lastAttack_Lab3:setString(text)
    end
    if self.lastAttack_Lab4~=nil then
        self.lastAttack_Lab4:setString(text)
    end
    if self.bossEscapeLab~=nil then
        self.bossEscapeLab:setString(text)
    end
end
function WorldBossView.setLastAttack( self,_lastAttackNum) -- 设置最后一击信息
    -- body
    if self.lastAttack_Lab2~=nil then
        self.lastAttack_Lab2:setString(self.rankData[_lastAttackNum].name)
    end
    if self.lastAttack_Lab4~=nil then
        self.lastAttack_Lab4:setString(self.rankData[_lastAttackNum].gold)
    end
end
-- function WorldBossView.setMyselfRank( self,_keepNum) -- 设置自己排行信息
--     -- body
--     if self.m_secNode:getChildByTag(101)~=nil then
--         self.m_secNode:getChildByTag(101):setString(self.rankData[_keepNum].rank )
--     end
--     if self.m_secNode:getChildByTag(102)~=nil then
--         self.m_secNode:getChildByTag(102):setString(self.rankData[_keepNum].name)
--     end
--     if self.m_secNode:getChildByTag(103)~=nil then
--         self.m_secNode:getChildByTag(103):setString(self.rankData[_keepNum].lv)
--     end
--     if self.m_secNode:getChildByTag(104)~=nil then
--         local text=10000+self.rankData[_keepNum].pro
--         local occupation=_G.Cfg.skill_skin[text].skin_name 
--         self.m_secNode:getChildByTag(104):setString(occupation)
--     end
--     if self.m_secNode:getChildByTag(105)~=nil then
--         self.m_secNode:getChildByTag(105):setString(self.rankData[_keepNum].powerful)
--     end
--     if self.m_secNode:getChildByTag(106)~=nil then
--         self.m_secNode:getChildByTag(106):setString(self.rankData[_keepNum].harm)
--     end
--     if self.m_secNode:getChildByTag(107)~=nil then
--         -- local gold=self.rankData[_keepNum].gold
--         -- if self.value~=nil then
--         --     gold=string.format("%sx%d",gold,self.value)
--         -- end
--         self.m_secNode:getChildByTag(107):setString(self.rankData[_keepNum].gold)
--     end 
-- end
function WorldBossView.REQ_WORLD_BOSS_REQUEST( self ) -- 请求面板
    print("请求面板")
    local msg = REQ_WORLD_BOSS_REQUEST()
    _G.Network:send(msg)
end
function WorldBossView.REQ_WORLD_BOSS_ASK_SETTLE( self,_boosId) -- 请求排行版
    local msg = REQ_WORLD_BOSS_ASK_SETTLE()
    print("")
    msg:setArgs(_boosId)
    _G.Network:send(msg)
end
function WorldBossView.REQ_SCENE_ENTER_FLY(self,mapId) -- 请求进入Boos场景
    -- body
    local msg = REQ_SCENE_ENTER_FLY()
    msg:setArgs(mapId)
    _G.Network:send(msg)
end
function WorldBossView.unregister( self )
   self.m_mediator : destroy()
   self.m_mediator = nil 
end

function WorldBossView.initRankView( self,_name,_msg,_type,_value)
    self.value=_value
    local function onTouchBegan(touch,event)
        return true
    end
    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)

    self.m_rootLayer=cc.LayerColor:create(cc.c4b(0,0,0,150))
    self.m_rootLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_rootLayer)
    cc.Director:getInstance():getRunningScene():addChild(self.m_rootLayer,1001)

    local m_winSize=cc.Director:getInstance():getWinSize()
    local bgSize=cc.size(875,516)
	local tipsSpr = ccui.Scale9Sprite:createWithSpriteFrameName("general_tips_dins.png")
	tipsSpr       : setPreferredSize(bgSize)
	tipsSpr       : setPosition(m_winSize.width/2,m_winSize.height/2-20)
	self.m_rootLayer : addChild(tipsSpr)

    local function nCloseFun()
        self.m_rootLayer:removeFromParent(false)
        self.m_rootLayer=nil
        if _type == 1 then
            print("请求退出场景")
            local msg = REQ_SCENE_ENTER_CITY()
            _G.Network:send(msg)
        end
    end

	local Btn_Close = gc.CButton : create("general_close.png")
    Btn_Close   : setPosition( cc.p( bgSize.width-23, bgSize.height-24) )
    Btn_Close   : addTouchEventListener( nCloseFun )
    tipsSpr : addChild( Btn_Close , 8 )

    local tipslogoSpr = cc.Sprite : createWithSpriteFrameName("general_tips_up.png")
    tipslogoSpr : setPosition(bgSize.width/2-135, bgSize.height-28)
    tipsSpr : addChild(tipslogoSpr)

    local tipslogoSpr = cc.Sprite : createWithSpriteFrameName("general_tips_up.png")
    tipslogoSpr : setPosition(bgSize.width/2+130, bgSize.height-28)
    tipslogoSpr : setRotation(180)
    tipsSpr : addChild(tipslogoSpr)

    local m_titleLab=_G.Util:createBorderLabel("排名奖励",24,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    m_titleLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
    m_titleLab:setPosition(bgSize.width/2,bgSize.height-26)
    tipsSpr:addChild(m_titleLab)

    local di2kuanbg = ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
    di2kuanbg       : setPreferredSize(cc.size(856,460))
    di2kuanbg       : setPosition(cc.p(bgSize.width/2,bgSize.height/2-18))
    tipsSpr       : addChild(di2kuanbg)

	local rank_Lab1= _G.Util : createLabel("排名", fontSize-2)
    -- rank_Lab1 : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
    rank_Lab1 : setPosition(cc.p(60,445)) 
    tipsSpr : addChild(rank_Lab1)

    local rank_Lab2= _G.Util : createLabel("玩家名称", fontSize-2)
    -- rank_Lab2 : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
    rank_Lab2 : setPosition(cc.p(170,445)) 
    tipsSpr : addChild(rank_Lab2)

    local rank_Lab3= _G.Util : createLabel("等级", fontSize-2)
    -- rank_Lab3 : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
    rank_Lab3 : setPosition(cc.p(280,445)) 
    tipsSpr : addChild(rank_Lab3)

    local rank_Lab4= _G.Util : createLabel("战斗力", fontSize-2)
    -- rank_Lab4 : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
    rank_Lab4 : setPosition(cc.p(380,445)) 
    tipsSpr : addChild(rank_Lab4)

    local rank_Lab5= _G.Util : createLabel("伤害", fontSize-2)
    -- rank_Lab5 : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
    rank_Lab5 : setPosition(cc.p(490,445)) 
    tipsSpr : addChild(rank_Lab5)

    local rank_Lab6= _G.Util : createLabel("奖励铜钱", fontSize-2)
    -- rank_Lab6 : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
    rank_Lab6 : setPosition(cc.p(610,445)) 
    tipsSpr : addChild(rank_Lab6)

    local rank_Lab7= _G.Util : createLabel("奖励物品", fontSize-2)
    -- rank_Lab7 : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
    rank_Lab7 : setPosition(cc.p(760,445)) 
    tipsSpr : addChild(rank_Lab7)

    self._rankMsgSize = cc.size(bgSize.width,34)

    local lineBg 	= ccui.Scale9Sprite : createWithSpriteFrameName("general_double_line.png")
    lineBg 			: setPreferredSize( cc.size(self._rankMsgSize.width-20, 2) )
    lineBg 			: setAnchorPoint( cc.p(0.0,1) )
    lineBg 			: setPosition(cc.p(10,425))
    tipsSpr 		        : addChild(lineBg)

    local rankNum = 0
    local flag    = true
    for i=1,#_msg do
    	if _msg[i].last_kill==0 then
            rankNum=_msg[i].rank
        elseif _msg[i].last_kill==1 then
            bossWin=2
            rankNum = 12
        elseif _msg[i].last_kill==2 then
            rankNum = 11
            flag = false
        end
    	tipsSpr:addChild(self : __createRankLabel(rankNum,_msg[i]))
    end

    if flag then
    	local myProperty = _G.GPropertyProxy:getMainPlay()
    	local msg = 
    	{
    		rank     = 0,
    		name     = myProperty:getName(),
    		lv       = myProperty:getLv(),
    		powerful = myProperty:getPowerful(),
    		harm     = 0,
    		gold     = 0,
    		goods_id = 0,
    	}
    	tipsSpr:addChild(self:__createRankLabel(11,msg))
    end
end

function WorldBossView.isDouble(self)
    print("isDouble==>>",self.ldoubleLab)
    if self.ldoubleLab~=nil then
        self.ldoubleLab : setVisible(true)
        self.rdoubleLab : setVisible(true)
    end
end

function WorldBossView.__createRankLabel( self,i,_msg )
	print(i)
	local rankLab = ccui.Widget : create()
    rankLab 	  : setContentSize( self._rankMsgSize )
    rankLab 	  : setAnchorPoint( cc.p(0.0,0.5) )
    rankLab 	  : setPosition(cc.p(0, 405-(i-1)*(self._rankMsgSize.height)))

    local fontSize  = 20

    if i==11 then
    	local star     = cc.Sprite : createWithSpriteFrameName("general_star.png")
    	star           : setScale(0.7)
	    star 		   : setPosition(cc.p(35,star:getContentSize().height/2+3))
	    rankLab 	   : addChild(star)
    end

    if _msg.flag==1 and i~=12 then
        local star     = cc.Sprite : createWithSpriteFrameName("general_bossadd.png")
        -- star           : setScale(0.7)
        star           : setPosition(cc.p(665,star:getContentSize().height/2+5))
        rankLab        : addChild(star,10)
    end

    local color     = _G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_WHITE)
    if i == 1 then
    	color  = _G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED)
    elseif i == 2 then
    	color  = _G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_YELLOW)
    elseif i == 3 then
    	color  = _G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_BLUE)
    end

    local rank 		= _G.Util : createLabel(tostring(_msg.rank), fontSize)
    rank 	   		: setColor(color)
    if i==12 then
    	rank        : setString("击杀")
    	rank 	   	: setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
    end
    if _msg.rank==0 then
    	rank        : setString("无")
    end
    rank 	   		: setDimensions(50,self._rankMsgSize.height-16)
    -- rank 	   		: setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    -- rank 	   		: setAnchorPoint( cc.p(0.0,0.5) )
    rank 	   		: setPosition(cc.p(80,self._rankMsgSize.height/2))
    rankLab 		: addChild(rank)

    local name 		= _G.Util : createLabel(_msg.name, fontSize)
    name 			: setColor(color)
    -- name 			: setDimensions(130,self._rankMsgSize.height-16)
    -- name 			: setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    -- name 			: setAnchorPoint( cc.p(0.0,0.5) )
    name 			: setPosition(cc.p(167,self._rankMsgSize.height/2))
    rankLab 		: addChild(name)

    local lv 		= _G.Util : createLabel(tostring(_msg.lv), fontSize)
    lv 				: setColor(color)
    -- lv 				: setDimensions(20,self._rankMsgSize.height-16)
    -- lv 				: setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    -- lv 				: setAnchorPoint( cc.p(0.0,0.5) )
    lv 				: setPosition(cc.p(280,self._rankMsgSize.height/2))
    rankLab 		: addChild(lv)

    local power 	= _G.Util : createLabel(tostring(_msg.powerful), fontSize)
    power 			: setColor(color)
    -- power 			: setDimensions(120,self._rankMsgSize.height-16)
    -- power 			: setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    -- power 			: setAnchorPoint( cc.p(0.0,0.5) )
    power 			: setPosition(cc.p(381,self._rankMsgSize.height/2))
    rankLab 		: addChild(power)

    local harm 	= _G.Util : createLabel(tostring(_msg.harm), fontSize)
    harm 			: setColor(color)
    -- harm 			: setDimensions(120,self._rankMsgSize.height-16)
    -- harm 			: setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    -- harm 			: setAnchorPoint( cc.p(0.0,0.5) )
    harm 			: setPosition(cc.p(491,self._rankMsgSize.height/2))
    rankLab 		: addChild(harm)

    local award=tostring(_msg.gold)
    local money 	= _G.Util : createLabel(award, fontSize)
    money 			: setColor(color)
    -- money 			: setDimensions(120,self._rankMsgSize.height-16)
    -- money 			: setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    -- money 			: setAnchorPoint( cc.p(0.0,0.5) )
    money 			: setPosition(cc.p(612,self._rankMsgSize.height/2))
    rankLab 		: addChild(money)

    if self.value~=nil then
        local beishuLab=_G.Util:createLabel(string.format("x%d",self.value),fontSize)
        beishuLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_YELLOW))
        -- beishuLab:setAnchorPoint(cc.p(0,0))
        beishuLab:setPosition(625+money:getContentSize().width/2,self._rankMsgSize.height/2)
        rankLab:addChild(beishuLab)
    end

    local id = _msg.goods_id
    print("id",id,"num",_msg.num)
    local goodsStr  = ""
    if _msg.rank==0 then
    	goodsStr = "无"
    else
    	goodsStr = _G.Cfg.goods[id].name
    end

    local goods 	= _G.Util : createLabel(goodsStr, fontSize)
    goods 			: setColor(color)
    -- goods 			: setDimensions(130,self._rankMsgSize.height-16)
    -- goods 			: setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    -- goods 			: setAnchorPoint( cc.p(0.0,0.5) )
    goods 			: setPosition(cc.p(765,self._rankMsgSize.height/2))
    rankLab 		: addChild(goods)

    if i==11 or i==12 then
    	local lineBg 	= ccui.Scale9Sprite : createWithSpriteFrameName("general_double_line.png")
	    lineBg 			: setPreferredSize( cc.size(self._rankMsgSize.width-20,2) )
	    lineBg 			: setAnchorPoint( cc.p(0.0,1) )
	    lineBg 			: setPosition(cc.p(10, self._rankMsgSize.height))
	    rankLab 		: addChild(lineBg)
	else
		local line 	= ccui.Scale9Sprite : createWithSpriteFrameName("general_double_line.png")
	    local lineSprSize = line : getPreferredSize()
	    line 			: setPreferredSize( cc.size(self._rankMsgSize.width-20, lineSprSize.height) )
	    line 			: setAnchorPoint( cc.p(0.0,1) )
	    line 			: setPosition(cc.p(10,2))
	    rankLab 		: addChild(line)
    end
 
    return rankLab
end

return WorldBossView