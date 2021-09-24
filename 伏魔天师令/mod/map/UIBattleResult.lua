-- 第2和3个参数是专门给一骑当千用的 判断是否是新纪录以及时间
local beautyTime={}

local UIBattleResult=classGc(view,function(self,ackData,_isNewRecord,_recordtime)
    self.ackData=ackData
    self.m_isNewRecord=_isNewRecord
    self.m_recordtime=_recordtime
    self.fontSize=28

    local proxy=_G.GPropertyProxy:getChallengePanePlayInfo()
    print("proxy!",proxy,self.ackData.name)
    if proxy~=nil then
        self.ackData.name = proxy:getName()
        print("self.ackData.name",self.ackData.name)
    end
    if _G.g_Stage.m_sceneType==_G.Const.CONST_MAP_TYPE_PK_LY then
        self.ackData.name=_G.g_Stage.m_lingYaoPkData.name
    end
    print( "self.ackData[1]=======", self.ackData[1] )
    if self.ackData[1]==nil then
        return
    end

    self.totalSteps=10
    if self.m_recordtime~=nil then
        self.totalSteps=1
    end
    self.showDatas={}
    self.showLabelNames={}
    for i,v in ipairs(self.ackData) do
        if i%2==0 then
            table.insert(self.showDatas,v)
        else
            table.insert(self.showLabelNames,v)
        end
    end

    for i=1,#self.showDatas do
        self.showDatas[10+i]=0
        self.showDatas[100+i]=math.floor(self.showDatas[i]/self.totalSteps)
    end
    -- _G.g_Stage:setRemainingTime()
end)

--{返回一个层}
function UIBattleResult.create( self )
    local function onTouchBegan() return true end
    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)

    self.m_winSize=cc.Director:getInstance():getWinSize()
    self.m_rootLayer=cc.Layer:create()
    self.m_rootLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_rootLayer)
    self.m_rootLayer:setPosition(cc.p(self.m_winSize.width/2,self.m_winSize.height/2))

    cc.SimpleAudioEngine:getInstance():stopMusic(true)


    self.show=function()
        -- 胜败入口
        if _G.g_Stage.m_sceneType==_G.Const.CONST_MAP_TYPE_PK_LY then
            if self.ackData.res==1 then
                self.m_szResImgName="ui_battle_res_1.png"
                self:__initWinView()
                _G.Util:playAudioEffect("ui_match_win")
            elseif self.ackData.res==2 then
                self.m_szResImgName="ui_battle_res_2.png"
                self:__initWinView()
                _G.Util:playAudioEffect("ui_match_win")
            elseif self.ackData.res==3 then
                self.m_szResImgName="ui_battle_res_3.png"
                self:__initLoseView()
                _G.Util:playAudioEffect("ui_match_lose")
            elseif self.ackData.res==4 then
                self.m_szResImgName="ui_battle_res_4.png"
                self:__initLoseView()
                _G.Util:playAudioEffect("ui_match_lose")
            else
                self.m_szResImgName="ui_battle_res_5.png"
                self:__initLoseView()
                _G.Util:playAudioEffect("ui_match_lose")
            end
        else
            if self.ackData.res==0 then
                self.m_szResImgName="ui_battle_res_4.png"
                self:__initLoseView()
                _G.Util:playAudioEffect("ui_match_lose")
            else
                self.m_szResImgName="ui_battle_res_2.png"
                self:__initWinView()
                _G.Util:playAudioEffect("ui_match_win")
            end
        end
    end
    ScenesManger.loadScene(self,_G.Cfg.UI_BattleResView,{"ui/battle_res.plist","ui/battle_res32.plist","meiren_cnf"})

    return self.m_rootLayer
end

function UIBattleResult.__initWinView(self)
    -- 特效显示
    self : showNewTexiao()
end

function UIBattleResult.showNewTexiao( self )
    local m_winSize = cc.Director : getInstance() : getVisibleSize()

    self.myMidNode = cc.Node : create()
    self.m_rootLayer : addChild( self.myMidNode, -6 )
    self.myMidNode : setPosition( 0,-30 )

    local lineLayer  = cc.LayerColor:create(cc.c4b(0,0,0,0))
    lineLayer  : setPosition( -m_winSize.width/2, -m_winSize.height/2 )
    lineLayer  : setContentSize(m_winSize)
    lineLayer  : runAction(cc.FadeTo:create(0.2,180))
    self.m_rootLayer  : addChild(lineLayer, -10)
    
    local spr_win  = cc.Sprite : createWithSpriteFrameName( "ui_battle_win1.png" )
    spr_win : setPosition( 0, 0 )
    spr_win : setScale(10)
    self.myMidNode : addChild( spr_win )

    local winX,winY=233,118
    local tempWin2=cc.Sprite:createWithSpriteFrameName("ui_battle_win2.png")
    tempWin2:runAction(cc.RepeatForever:create(cc.RotateBy:create(6,360)))
    tempWin2:setPosition(winX,winY)
    spr_win:addChild(tempWin2)

    local tempWin3=cc.Sprite:createWithSpriteFrameName(self.m_szResImgName)
    tempWin3:setPosition(winX,winY)
    spr_win:addChild(tempWin3)

    local line1 = ccui.Scale9Sprite : createWithSpriteFrameName( "ui_battle_fram.png" )
    local lineX = line1 : getContentSize().width
    line1 : setPosition( m_winSize.width/2, 313 )
    line1 : setScaleY(1.3)
    line1 : setScaleX( m_winSize.width*0.8/lineX )
    line1 : setOpacity(0)
    lineLayer : addChild( line1 )
    

    local tempEffect=nil
    local function showVirate()
        _G.g_Stage:vibrate(5,6,0.05)
        _G.Util:playAudioEffect("1009")

        tempEffect=_G.SpineManager.createSpine("spine/shengli1",1)
        tempEffect:setAnimation(0,"idle",false)
        self.myMidNode:addChild(tempEffect,50)
    end

    local function removeTempEffect()
        if tempEffect then
            tempEffect:removeFromParent(true)
            tempEffect=nil
        end
    end

    local function endFun()
        self:__winFirstShow()
        line1:runAction(cc.FadeTo:create(0.2,255))
    end

    spr_win:runAction(cc.Sequence:create( cc.Spawn:create( cc.ScaleTo:create( 0.2, 1 ), 
                                                           cc.MoveTo :create( 0.2, cc.p( 0, 0 ) )
                                                          ),
                                          cc.CallFunc:create(showVirate),
                                          cc.DelayTime:create(0.8),
                                          cc.CallFunc:create(removeTempEffect),
                                          cc.Spawn:create( cc.MoveTo:create(0.3,cc.p(0,190)),
                                                           cc.DelayTime:create(0.1),
                                                           cc.CallFunc:create(endFun)
                                                          )
                                         )
                      )

end

function UIBattleResult.__winFirstShow(self, _myType)

    if self.ackData[1]==nil then
        self:__winButtonShow(_myType)
    else
        self:__winSecondShow()
    end
    
end

function UIBattleResult.__winButtonShow(self, _myType)
    print( "进入__winButtonShow", _G.g_Stage.m_sceneType, _G.g_Stage.m_sceneId )
    local function c(sender,eventType)
        return self:__btnCallback(sender,eventType)
    end

    local certainButton=gc.CButton:create("ui_battle_res_btn2.png")
    certainButton:addTouchEventListener(c)
    certainButton:setPosition(self.m_winSize.width/2-70,-260)
    certainButton:ignoreContentAdaptWithSize(false)
    certainButton:setContentSize(cc.size(certainButton:getContentSize().width+30,certainButton:getContentSize().height+30))
    certainButton:setVisible(false)
    self.m_rootLayer:addChild(certainButton)
    if self.ackData[1]==nil then
        certainButton : setPosition( self.m_winSize.width/2-70,-260 )
    end

    local function actionCallFunc()
        certainButton:setVisible(true)
    end

    certainButton:runAction(cc.Sequence:create(cc.DelayTime:create(0.7),cc.CallFunc:create(actionCallFunc)))

    local data1,data2,data3,data4,data5,data6,data7,data8,data9,color_1,color_2 = nil

    -- local KOLevelFileName="ui_battle_res_3.png"
    -- self.KOLevelSprite=cc.Sprite:createWithSpriteFrameName(KOLevelFileName)
    -- self.KOLevelSprite:setPosition(self.m_winSize.width*0.5-50,-self.m_winSize.height*0.5+30)
    -- self.m_rootLayer:addChild(self.KOLevelSprite,10)
    -- self.KOLevelSprite:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.EaseBounceOut:create(cc.MoveTo:create(0.4,cc.p(180+70,40+53)))))
    -- self.KOLevelSprite:setVisible( false )

    if _G.g_Stage.m_sceneId == _G.Const.CONST_INVITE_PK_SENCE then
    -- 切磋
        data1 = "你击败了"
        data2 = self.ackData.name or ""
        -- data3 = "！"
        data4 = "事了拂衣去，深藏身与名！"
        -- self.KOLevelSprite:setVisible( true )
        
    elseif _G.g_Stage.m_sceneId == _G.Const.CONST_ARENA_JJC_MOIL_ID then
    -- 奴仆抓捕
        print( "进入场景3！" )
        data1 = "你击败了"
        data2 = self.ackData.name or ""
        -- data3 = "!"
        if _G.StageXMLManager:getScenePkType() == 5 then
            data4 = "成功反抗了他，重新获得自由！"
        else
            if self.ackData.name == self.ackData.name1 then
                data4 = "成功抓捕他为你的奴仆！"
            else
                data4 = "成功抢夺了他的奴仆"
                data5 = self.ackData.name1
                data6 = "!"
                color_2 = _G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_WHITE)
            end
        end
        -- self.KOLevelSprite:setVisible( true )
        -- 增加 抓捕、抢夺 判定
    elseif _G.g_Stage.m_sceneId == _G.Const.CONST_ARENA_JJC_HERO_TOWER_ID then 
    -- 浮屠静修
        data1 = "你击败了"
        data2 = self.ackData.name or "" 
        -- data3 = "!"
        data4 = "事了拂衣去，深藏身与名！"
        -- self.KOLevelSprite:setVisible( true )

    elseif _G.g_Stage.m_sceneId == _G.Const.CONST_WRESTLE_KOF_SENCE then
    -- 天下第一
        print( "_G.Const.CONST_WRESTLE_KOF_SENCE， self.ackData.rank = ", self.ackData.rank )
        data1 = "你击败了"
        data2 = self.ackData.name or "" 
        -- data3 = "!"

        print( "self.ackData.state = ", self.ackData.state )
        if self.ackData.state == _G.Const.CONST_WRESTLE_STATE_ALL_OVER then
            data4 = "王者的巅峰，何等的寂寞！"    
        elseif self.ackData.state == _G.Const.CONST_WRESTLE_STATE_FINAL_ING then
            data4 = "成功晋级下一轮比赛！"
        elseif self.ackData.state == _G.Const.CONST_WRESTLE_STATE_KING then
            if self.ackData.rank == 1 then
                data4 = "你获得了一场胜利，胜利在即！"
            else
                data4 = "王者的巅峰，何等的寂寞！"
            end
        else
            data4 = "获得了"
            data5 = _G.Const.CONST_WRESTLE_SUCCESS_SCORE
            data6 = "积分"
            color_2 = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_WHITE )
        end 

    elseif _G.g_Stage.m_sceneId == _G.Const.CONST_TXDY_SUPER_MAP_ID then
    -- 太清混元
        print( "_G.Const.CONST_TXDY_SUPER_MAP_ID" )
        data1 = "你击败了"
        data2 = self.ackData.name or "" 
        -- data3 = "!"

        print( "self.ackData.state = ", self.ackData.state )
        if self.ackData.state == _G.Const.CONST_TXDY_SUPER_STATE_OVER then
            data4 = "三界之中，谁与争锋！"    
        elseif self.ackData.state == _G.Const.CONST_TXDY_SUPER_STATE_FINAL 
            or self.ackData.state == _G.CONST_TXDY_SUPER_STATE_GROUP then
            data4 = "成功晋级决赛！"
        elseif self.ackData.state == _G.Const.CONST_TXDY_SUPER_STATE_KING then
            if self.ackData.rank == 1 then
                data4 = "你获得了一场胜利，胜利在即！"
            else
                data4 = "恭喜你荣登三清天宗之位！"
            end
        else
            data4 = "恭喜你获得胜利!"
            print( "判断出错,接收到得state = ", self.ackData.state )
        end 
    end

    if self.ackData[1]==nil then
        local myNode = self : showWords( data1, data2, data3, data4, data5, data6, data7, data8, data9, color_1, color_2 )
        myNode : setPosition( -220, 50 )
        self.m_rootLayer : addChild( myNode )
    end
end

function UIBattleResult.__winSecondShow(self)
    print( "进入__winSecondShow" ,_G.g_Stage.m_sceneType, _G.g_Stage.m_sceneId)

    local labelTbl = {}
    local leftTopX = 0
    local leftTopY = 80
    local leftColor=_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_WHITE)
    local rightColor=_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_DARKPURPLE)
    local titleColor=_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_GOLD)
    local rewardLab = "奖励:"
    local data1,data2,data3,data4,data5,data6,data7,data8,data9 = nil

    -- local KOLevelFileName="ui_battle_res_3.png"
    -- self.KOLevelSprite=cc.Sprite:createWithSpriteFrameName(KOLevelFileName)
    -- self.KOLevelSprite:setPosition(self.m_winSize.width*0.5+10,-self.m_winSize.height*0.5+50)
    -- self.m_rootLayer:addChild(self.KOLevelSprite,10)
    -- self.KOLevelSprite:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.EaseBounceOut:create(cc.MoveTo:create(0.4,cc.p(220,80+30)))))
    -- self.KOLevelSprite:setVisible( false )

    if _G.g_Stage.m_sceneType == _G.Const.CONST_MAP_TYPE_THOUSAND then
    -- 斗转星移
        -- local myReward = {  "ui_battle_0.png", "ui_battle_9.png", "ui_battle_8.png",
        --                     "ui_battle_7.png", "ui_battle_6.png", "ui_battle_5.png",
        --                     "ui_battle_4.png", "ui_battle_3.png", "ui_battle_2.png", "ui_battle_1.png" }
        print( "进入场景1！" )

        local m_str = "没有刷新记录"
        if self.ackData.flag == 1 then
            m_str = "恭喜你，你的记录刷新了！"
        end

        data1 = "评分："
        data2 = _G.Cfg.thousand_jifen[self.ackData.id].assess
        data3 = m_str
        data4 = "伤害："
        data5 = self.ackData.harm
        data6 = "       时间："
        data7 = _G.g_BattleView:getTimesStr(self.ackData.time)
        -- self.KOLevelSprite:setVisible( false )
        -- 评价
        -- if self.ackData.id ~= nil then 
        --     print( "对应的ID：", self.ackData.id )
        --     local Reward1 = cc.Sprite : createWithSpriteFrameName( myReward[self.ackData.id] )
        --     Reward1       : setPosition( self.m_winSize.width*0.5,-self.m_winSize.height*0.5 )
        --     self.m_rootLayer : addChild( Reward1, 10 )
        --     Reward1       : setScale( 0.9 )
        --     Reward1       : runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.EaseBounceOut:create(cc.MoveTo:create(0.4,cc.p(220-30,60)))))

        --     local Reward2 = cc.Sprite : createWithSpriteFrameName( "ui_battle_jia.png" )
        --     Reward2       : setPosition( self.m_winSize.width*0.5+50,-self.m_winSize.height*0.5+30 )
        --     self.m_rootLayer : addChild( Reward2, 10 )
        --     Reward2       : runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.EaseBounceOut:create(cc.MoveTo:create(0.4,cc.p(220+50,90)))))
        -- end

    elseif _G.g_Stage.m_sceneId == _G.Const.CONST_ARENA_JJC_WARLORDS_ID then
    -- 封神榜
        print( "进入场景2！" )
        data1 = "你击败了"
        -- data2 = _G.Cfg.grade[self.ackData.id] or ""
        data2 = self.ackData.name or ""
        -- data3 = "!"
        data4 = "事了拂衣去，深藏身与名！"
        -- self.KOLevelSprite:setVisible( true )

    elseif _G.g_Stage.m_sceneId == _G.Const.CONST_OVER_SERVER_QUNYING_ID then
    -- 上清灵宝
        data1 = "你击败了"
        data2 = self.ackData.name or "" 
        -- data3 = "!"
        if self.ackData.up ~= 0 and self.ackData.rank ~= nil then
            data4 = "排名上升至第"
            data5 = self.ackData.rank
            data6 = "名"
            data7 = string.format( "%s%d%s", "（", self.ackData.up, "   ）" )
            local lab1 = _G.Util: createLabel( data4, 20 )
            local lab2 = _G.Util: createLabel( data5, 20 )
            local lab3 = _G.Util: createLabel( data6, 20 )
            local lab4 = _G.Util: createLabel( data7, 20 )

            local myWidth = lab1:getContentSize().width + lab2:getContentSize().width + lab3:getContentSize().width+lab4:getContentSize().width 
            local spr = cc.Sprite:createWithSpriteFrameName("ui_battle_up.png")
            spr:setAnchorPoint( 1, 0.5 )
            self.m_rootLayer:addChild(spr,10)
            spr:setPosition(myWidth - 92,98)
            spr:setVisible(false)
            local function CallFunc1( )
                spr:setVisible(true)
            end
            spr:runAction( cc.Sequence:create( cc.DelayTime:create(1), cc.CallFunc:create(CallFunc1) ) )
        else
            data4 = "排名保持不变"
        end
        -- self.KOLevelSprite:setVisible( true )

    elseif _G.g_Stage.m_sceneId == _G.Const.CONST_TXDY_SUPER_MAP_ID then
    -- 太清混元
        print( "**************" )
        data1 = "你击败了"
        data2 = self.ackData.name or "" 
        -- data3 = "!"

        print( "self.ackData.state = ", self.ackData.state )
        if self.ackData.state == _G.Const.CONST_TXDY_SUPER_STATE_OVER then
            data4 = "三界之中，谁与争锋！"    
        elseif self.ackData.state == _G.Const.CONST_WRESTLE_STATE_KING 
            or self.ackData.state == _G.Const.CONST_TXDY_SUPER_STATE_FINAL 
            or self.ackData.state == _G.CONST_TXDY_SUPER_STATE_GROUP then
            data4 = "你成功晋级下一轮比赛！"
        else
            data4 = "恭喜你获得胜利!"
            print( "判断出错,接收到得state = ", self.ackData.state )
        end 

    elseif _G.g_Stage.m_sceneId == _G.Const.CONST_ARENA_THE_ARENA_ID then 
        -- 竞技场
        if self.ackData.rmb_band>0 then
            local lab1 = _G.Util: createLabel( "你击败了", 20 )
            local lab2 = _G.Util: createLabel( self.ackData.name or "", 20 )
            local lab3 = _G.Util: createLabel( ",排名上升至第", 20 )
            local lab4 = _G.Util: createLabel( self.ackData.rank, 20 )
            local lab5 = _G.Util: createLabel( "名", 20 )
            local lab6 = _G.Util: createLabel( string.format( "%s%d%s", "（", self.ackData.up, "   ）" ), 20 )
            local lab7 = _G.Util: createLabel( "恭喜你刷新了历史最高排名！", 20 )
            local lab8 = _G.Util: createLabel( string.format( "%s%d%s", "（", self.ackData.rank_poor, "   ）" ), 20 )

            lab2:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
            lab4:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
            lab6:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BLUE))
            lab8:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BLUE))

            lab1:setAnchorPoint( 0, 0.5 )
            lab2:setAnchorPoint( 0, 0.5 )
            lab3:setAnchorPoint( 0, 0.5 )
            lab4:setAnchorPoint( 0, 0.5 )
            lab5:setAnchorPoint( 0, 0.5 )
            lab6:setAnchorPoint( 0, 0.5 )
            lab7:setAnchorPoint( 0, 0.5 )
            lab8:setAnchorPoint( 0, 0.5 )

            local myWidth=-200
            lab1:setPosition( myWidth, 10 )
            myWidth=myWidth+lab1:getContentSize().width
            lab2:setPosition( myWidth, 10 )
            myWidth=myWidth+lab2:getContentSize().width
            lab3:setPosition( myWidth, 10 )
            myWidth=myWidth+lab3:getContentSize().width
            lab4:setPosition( myWidth, 10 )
            myWidth=myWidth+lab4:getContentSize().width
            lab5:setPosition( myWidth, 10 )
            myWidth=myWidth+lab5:getContentSize().width
            lab6:setPosition( myWidth, 10 )
            lab7:setPosition( -150, -25 )
            lab8:setPosition( -150+lab7:getContentSize().width+10, -25 )

            lab1:setVisible(false)
            lab2:setVisible(false)
            lab3:setVisible(false)
            lab4:setVisible(false)
            lab5:setVisible(false)
            lab6:setVisible(false)
            lab7:setVisible(false)
            lab8:setVisible(false)

            self.m_rootLayer : addChild( lab1 )
            self.m_rootLayer : addChild( lab2 )
            self.m_rootLayer : addChild( lab3 )
            self.m_rootLayer : addChild( lab4 )
            self.m_rootLayer : addChild( lab5 )
            self.m_rootLayer : addChild( lab6 )
            self.m_rootLayer : addChild( lab7 )
            self.m_rootLayer : addChild( lab8 )

            myWidth=myWidth+lab6:getContentSize().width-10
            local spr1 = cc.Sprite:createWithSpriteFrameName("ui_battle_up.png")
            spr1:setAnchorPoint( 1, 0.5 )
            self.m_rootLayer:addChild(spr1,10)
            spr1:setPosition(myWidth,10)
            spr1:setVisible(false)

            myWidth=-150+lab7:getContentSize().width+lab8:getContentSize().width
            local spr2 = cc.Sprite:createWithSpriteFrameName("ui_battle_up.png")
            spr2:setAnchorPoint( 1, 0.5 )
            self.m_rootLayer:addChild(spr2,10)
            spr2:setPosition(myWidth,-25)
            spr2:setVisible(false)
            local function CallFunc1( )
                lab1:setVisible(true)
                lab2:setVisible(true)
                lab3:setVisible(true)
                lab4:setVisible(true)
                lab5:setVisible(true)
                lab6:setVisible(true)
                lab7:setVisible(true)
                lab8:setVisible(true)
                spr1:setVisible(true)
                spr2:setVisible(true)
            end
            spr2:runAction( cc.Sequence:create( cc.DelayTime:create(1), cc.CallFunc:create(CallFunc1) ) )
        else
            data1 = "你击败了"
            data2 = self.ackData.name or "" 
            -- data3 = "!"

            if self.ackData.up ~= 0 and self.ackData.rank ~= nil then
                data4 = "排名上升至第"
                data5 = self.ackData.rank
                data6 = "名"
                data7 = string.format( "%s%d%s", "（", self.ackData.up, "   ）" )
                local lab1 = _G.Util: createLabel( data4, 20 )
                local lab2 = _G.Util: createLabel( data5, 20 )
                local lab3 = _G.Util: createLabel( data6, 20 )
                local lab4 = _G.Util: createLabel( data7, 20 )

                local myWidth = lab1:getContentSize().width + lab2:getContentSize().width + lab3:getContentSize().width+ lab4:getContentSize().width + 15
                local spr = cc.Sprite:createWithSpriteFrameName("ui_battle_up.png")
                spr:setAnchorPoint( 1, 0.5 )
                self.m_rootLayer:addChild(spr,10)
                spr:setPosition(myWidth-87,-25)
                spr:setVisible(false)
                local function CallFunc1( )
                    spr:setVisible(true)
                end
                spr:runAction( cc.Sequence:create( cc.DelayTime:create(1), cc.CallFunc:create(CallFunc1) ) )
            else
                data4 = "排名保持不变"
            end
            -- self.KOLevelSprite:setVisible( true )
        end
    
    elseif _G.g_Stage.m_sceneId == _G.Const.CONST_OVER_SERVER_PEAK_ID then 
    -- 玉清元始
        data1 = "你击败了"
        data2 = self.ackData.name
        -- data3 = "!"
        data4 = "事了拂衣去，深藏身与名！"
        -- self.KOLevelSprite:setVisible( true )

    elseif _G.g_Stage.m_sceneType == _G.Const.CONST_MAP_CLAN_WAR then
    -- 门派战
        data1 = "你击败了"
        data2 = self.ackData.name or "" 
        data3 = "!"
    elseif _G.g_Stage.m_sceneType == _G.Const.CONST_MAP_TYPE_COPY_ROAD then
        -- data1 = "剩余血量："
        -- data2 = string.format("%d/%d",_G.g_Stage.m_lpPlay.m_nHP,_G.g_Stage.m_lpPlay.m_nMaxHP)
        local function nFun(_node)
            _node:setVisible(true)
        end
        local tempNode=cc.Node:create()
        tempNode:setVisible(false)
        tempNode:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(nFun)))
        self.m_rootLayer:addChild(tempNode)

        local color1=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_WHITE)
        local color2=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN)
        local strArray   = {"剩余血量：",string.format("%d/%d",_G.g_Stage.m_lpPlay.m_nHP,_G.g_Stage.m_lpPlay.m_nMaxHP)}
        local colorArray = {color1,color2}
        local width      = 0 
        for i=1,#strArray do
            local tempLabel=_G.Util:createLabel(strArray[i],20)
            tempLabel:setColor(colorArray[i])
            tempLabel:setAnchorPoint(0,0.5)
            tempLabel:setPosition(width,0)
            tempNode:addChild(tempLabel)
            width=width+tempLabel:getContentSize().width+2
        end
        tempNode:setPosition(-width*0.5+25,-5)
        rewardLab="通关奖励:"
    elseif _G.g_Stage.m_sceneType == _G.Const.CONST_MAP_TYPE_COPY_MONEY then
        local function nFun(_node)
            _node:setVisible(true)
        end
        local tempNode=cc.Node:create()
        tempNode:setVisible(false)
        tempNode:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(nFun)))
        self.m_rootLayer:addChild(tempNode)

        local color1=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_WHITE)
        local color2=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN)
        local strArray   = {"您对妖兽造成了",tostring(self.ackData.hurt),"伤害,共获得",tostring(self.ackData.gold),"铜钱。"}
        local colorArray = {color1,color2,color1,color2,color1}
        local width      = 0 
        for i=1,#strArray do
            local tempLabel=_G.Util:createLabel(strArray[i],24)
            tempLabel:setColor(colorArray[i])
            tempLabel:setAnchorPoint(0,0.5)
            tempLabel:setPosition(width,0)
            tempNode:addChild(tempLabel)
            width=width+tempLabel:getContentSize().width+2
        end
        tempNode:setPosition(-width*0.5+25,-5)
    elseif _G.g_Stage.m_sceneId == _G.Const.CONST_MOUNTAIN_KING_MAP then 
    -- 第一门派
        print("第一门派") 
        data1 = "你击败了"
        data2 = self.ackData.name or "" 
        data4 = "对他造成了"
        data5 = _G.g_Stage.m_ortherPlayerHp
        data6 = "点伤害！"
        -- self.KOLevelSprite:setVisible( true )
    end

    -- 显示文字：
    local myNode = self : showWords( data1, data2, data3, data4, data5, data6, data7, data8, data9 )
    myNode : setPosition(-220,45)
    self.m_rootLayer : addChild( myNode )

    if _G.g_Stage.m_sceneType==_G.Const.CONST_MAP_TYPE_PK_LY then
        self:showLingYaoResult(false)
    end

    local function btn_goodCallback(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
          local goodId=sender:getTag()
            if goodId == -1 then return end
            local pos=sender:getWorldPosition()
            local temp=_G.TipsUtil:createById(goodId,nil,pos)
            cc.Director:getInstance():getRunningScene():addChild(temp,1000)
        end
    end

    local viewSize = cc.size( 385, 130 )
    local containerSize = cc.size( 385*2, 90 )
    local posX,posY = -240,-170

    local width = 100
    local goodBox = {}
    local node1  = cc.Node : create()
    node1 : setPosition( posX, posY )
    self.m_rootLayer : addChild( node1,5 )

    local lbJiangLi=_G.Util:createLabel(rewardLab,20)
    local labWidth = lbJiangLi:getContentSize().width/2
    lbJiangLi:setAnchorPoint(cc.p(1,0.5))
    lbJiangLi:setPosition(115-labWidth,80)
    lbJiangLi:setOpacity(0)
    lbJiangLi:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.FadeTo:create(0.2,255)))
    node1:addChild(lbJiangLi)

    for i=1,4 do
        goodBox[i]   = ccui.Button:create()
        goodBox[i]   : loadTextures("general_tubiaokuan.png","general_tubiaokuan.png","", ccui.TextureResType.plistType)
        goodBox[i]   : addTouchEventListener(btn_goodCallback)
        goodBox[i]   : setPosition(35+width*i,40)
        goodBox[i]   : setVisible(false)
        goodBox[i]   : runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.Show:create()))
        node1    : addChild(goodBox[i],5)
    end

    local function schedulerCallFunc()
        self:updateData()
    end

    local sprSize = goodBox[1]:getContentSize()
    for i,v in ipairs(self.showLabelNames) do
        local goodsCnf=_G.Cfg.goods[tonumber(v)]
        local spr = _G.ImageAsyncManager:createGoodsSpr(goodsCnf)
        
        goodBox[i]:addChild(spr)
        goodBox[i]:setTag(tonumber(v))
        spr:setPosition(sprSize.width/2,sprSize.height/2)

        if v=="46100" then
            local upSpr = cc.Sprite:createWithSpriteFrameName( "battle_news.png")
            upSpr       : setPosition( 33, 44 )
            spr : addChild( upSpr )
        end

        local function c(node,data  )
            local i = data[1]
            local labelNum = _G.Util:createBorderLabel("0",16)
            labelNum:setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GOLD ) )
            goodBox[i]:addChild(labelNum)
            labelNum:setAnchorPoint(1,0)
            labelNum:setPosition(sprSize.width-10,5)
            table.insert(labelTbl,labelNum)
            if self.ackData[i*2] == 1 then
                labelNum:setVisible(false)
            end
            self.scheduleIndex=0
            if self.schdedulerHandle~=nil then return end
            self.schdedulerHandle=_G.Scheduler:schedule(schedulerCallFunc, 0.001)
        end
        local function f( )
            _G.Util:playAudioEffect("balance_reward")
        end
        local lbg = cc.Sprite:createWithSpriteFrameName("ui_battle_boom.png")
        lbg:setPosition(35+width*i+posX,posY+40)
        self.m_rootLayer:addChild(lbg,100)
        lbg:setScale(0)
        lbg:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.DelayTime:create(0.3*i),cc.Spawn:create(cc.ScaleTo:create(0.2,2),cc.FadeOut:create(0.4))))
        spr:setScale(0)
        spr : runAction( cc.Sequence:create(
                                            cc.DelayTime : create( 2),cc.DelayTime:create(0.3*i),
                                            cc.CallFunc  : create(f),
                                            cc.ScaleTo   : create( 0.3, 1 ),
                                            cc.CallFunc  : create(c,{i})
                                        )
                    )
    end

    self.labelsTbl=labelTbl

    self:__winButtonShow()
end

function UIBattleResult.showWords( self, data1, data2, data3, data4, data5, data6, data7, data8, data9, color_1 ,color_2 )
    local fontSize  = 20
    local color1    = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GRASSGREEN )
    local color2    = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GOLD )
    local color3    = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_WHITE     )
    local color4    = _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_BLUE       )

    if color_1 == nil then
        color_1 = color1
    end
    if color_2 == nil then
        color_2 = color2
    end

    local posX      = -220
    local posY      = 45

    local myNode    = cc.Node : create()
    myNode          : setPosition( posX, posY )   
    myNode          : setVisible( false )

    -- 第一行显示：
    local DataText1  = { data1,  data2,  data3  }
    local DataColor1 = { color3, color_1, color3 }
    local gap        = 60
    local width      = gap 
    for i=1,3 do
        if DataText1[i] ~= nil then
            print( "DataText1[i] =", i, DataText1[i] )
            local lab = _G.Util : createLabel( DataText1[i], fontSize )
            lab       : setColor( DataColor1[i] )
            lab       : setAnchorPoint( 0, 0.5 )
            lab       : setPosition( width, -35 )
            myNode    : addChild( lab )
            width = width + lab:getContentSize().width
        end
    end
    
    -- 第二行显示：
    local DataText2  = { data4,  data5,  data6, data7  }
    local DataColor2 = { color3, color_2, color3, color4 }
    local width      = gap+100 
    for i=1,4 do
        if DataText2[i] ~= nil then
            print( "DataText1[i] =", i, DataText2[i] )
            local lab = _G.Util : createLabel( DataText2[i], fontSize )
            lab       : setColor( DataColor2[i] )
            lab       : setAnchorPoint( 0, 0.5 )
            lab       : setPosition( width, -70 )
            myNode    : addChild( lab )
            width = width + lab:getContentSize().width
        end
    end

    -- 第三行显示：
    -- local DataText3  = { data7,  data8,  data9  }
    -- local DataColor3 = { color3, color3, color3 }
    -- local width      = gap 
    -- for i=1,3 do
    --     if DataText3[i] ~= nil then
    --         local lab = _G.Util : createLabel( DataText3[i], fontSize )
    --         lab       : setColor( DataColor3[i] )
    --         lab       : setAnchorPoint( 0, 0.5 )
    --         lab       : setPosition( width, -105 )
    --         myNode    : addChild( lab )
    --         width = width + lab:getContentSize().width
    --     end
    -- end

    local function CallFunc1(  )
        myNode : setVisible( true )
    end

    myNode : runAction( cc.Sequence:create( cc.FadeIn:create(0) ,cc.DelayTime:create(1), cc.CallFunc:create(CallFunc1) ,cc.FadeOut:create(0.3) ) )

    return myNode
end

function UIBattleResult.updateData(self)
    self.scheduleIndex=self.scheduleIndex+1
    if(self.scheduleIndex>=self.totalSteps) then
        _G.Scheduler:unschedule(self.schdedulerHandle)
        self.schdedulerHandle=nil
        for i=1,#self.showDatas do
            if self.labelsTbl[i]~=nil then
                self.labelsTbl[i]:setString(tostring(self.showDatas[i]))
                if i==2 and self.m_recordtime~=nil then
                    self.labelsTbl[i]:setString(self.m_recordtime)
                end
            end
        end
        return
    end

    for i=1,#self.showDatas do
        self.showDatas[10+i]=self.showDatas[10+i]+self.showDatas[100+i]
        if self.labelsTbl[i]~=nil then
            self.labelsTbl[i]:setString(tostring(self.showDatas[10+i]))
        end
    end
end

function UIBattleResult.__initLoseView(self)
    local blackLayer=cc.LayerColor:create(cc.c4b(0,0,0,0))
    blackLayer:setContentSize( self.m_winSize.width, 640 )
    blackLayer:setPosition(-self.m_winSize.width/2,-self.m_winSize.height/2)
    self.m_rootLayer:addChild(blackLayer,-10)

    local function actionCallFunc()
        self:__loseFirstShow()
    end
    blackLayer:runAction(cc.Sequence:create(cc.FadeTo:create(0.2,180),cc.CallFunc:create(actionCallFunc)))
end

function UIBattleResult.__loseFirstShow(self)
    local tempY=140
    local function showShiBaiEffect()
        local tempEff=_G.SpineManager.createSpine("spine/shibai",1)
        tempEff:setAnimation(0,"idle",false)
        tempEff:setPosition(0,tempY)
        self.m_rootLayer:addChild(tempEff,20)
    end

    local loseyun = cc.Sprite : createWithSpriteFrameName( "ui_battle_loseyun.png" )
    loseyun : setPosition( 0, 0 )
    loseyun : setScale(10)
    self.m_rootLayer : addChild( loseyun, 1 )

    local tempSize=loseyun:getContentSize()
    local tempSpr=cc.Sprite:createWithSpriteFrameName(self.m_szResImgName)
    tempSpr:setPosition(tempSize.width*0.5,tempSize.height*0.5)
    loseyun:addChild(tempSpr)

    local function f()
        _G.g_Stage:vibrate(5,6,0.05)
        _G.Util:playAudioEffect("balance_lost")
    end

    local function loseShow( )
        self:__loseInfoShow()
        showShiBaiEffect()
        f()
    end

    loseyun : runAction( 
                cc.Sequence:create(
                            cc.Spawn   : create(
                                cc.EaseBounceIn:create( cc.MoveTo  : create( 0.3, cc.p( 0,tempY ) ) ),
                                cc.ScaleTo : create( 0.3, 1 )
                            ),
                            cc.CallFunc: create(loseShow)
                            -- cc.MoveBy:create(0.05,cc.p(12/2,0)),
                            -- cc.CallFunc:create(f),
                            -- cc.MoveBy:create(0.05,cc.p(-12/2,0)),
                            -- cc.MoveBy:create(0.05,cc.p(12/2,0)),
                            -- cc.MoveBy:create(0.05,cc.p(-12/2,0)),
                            -- cc.MoveBy:create(0.05,cc.p(12/2,0)),
                            -- cc.MoveBy:create(0.05,cc.p(-12/2,0)),
                            -- cc.MoveBy:create(0.05,cc.p(12/2,0)),
                            -- cc.MoveBy:create(0.05,cc.p(-12/2,0)),
                            -- cc.MoveBy:create(0.05,cc.p(6/2,0)) 
                            )
                     )

    
end

function UIBattleResult.__loseInfoShow(self)
    local m_winSize = cc.Director : getInstance() : getVisibleSize()
    local line1 = ccui.Scale9Sprite : createWithSpriteFrameName( "ui_battle_fram.png" )
    local lineX = line1 : getContentSize().width
    line1 : setPosition( 0, -30 )
    line1 : setScaleY(1.3)
    line1 : setScaleX( m_winSize.width*0.8/lineX )
    -- line1 : setOpacity(0)
    self.m_rootLayer : addChild( line1 )

    print("_G.g_Stage.m_sceneType",_G.g_Stage.m_sceneType,_G.g_Stage.m_sceneId)
    if _G.g_Stage.m_sceneType==_G.Const.CONST_MAP_TYPE_PK_LY then
        self:showLingYaoResult(true)
    elseif _G.g_Stage.m_sceneId == _G.Const.CONST_MOUNTAIN_KING_MAP then 
    -- 第一门派
        print("第一门派")
        data1 = "你被"
        data3 = "击败了"
        data2 = self.ackData.name or "" 
        data4 = "对他造成了"
        data5 = _G.g_Stage.m_ortherPlayerHp
        data6 = "点伤害！"
        -- self.KOLevelSprite:setVisible( true )
        local myNode = self : showWords( data1, data2, data3, data4, data5, data6, data7, data8, data9, color_1, color_2 )
        myNode : setPosition( -220, 21 )
        self.m_rootLayer : addChild( myNode )
    elseif _G.g_Stage.m_sceneType==_G.Const.CONST_MAP_TYPE_COPY_FIGHTERS then
        print("锁妖塔")
        local copyFloor=_G.g_BattleView.m_futuCopyFloor or 0
        local copyPos=_G.g_BattleView.m_futuCopyPos or 0
        local szCopyInfo=string.format("第%s层 第%d关",_G.Lang.number_Chinese[copyFloor],copyPos)
        data1 = "你没能通过 "
        data2 = szCopyInfo
        data3 = ""
        data4 = "请加强实力，重新来过！"
        data5 = ""
        data6 = ""
        local myNode = self : showWords( data1, data2, data3, data4, data5, data6, data7, data8, data9, color_1, color_2 )
        myNode : setPosition( -220, 21 )
        self.m_rootLayer : addChild( myNode )
    elseif _G.g_Stage.m_sceneType==_G.Const.CONST_MAP_TYPE_COPY_NORMAL
        or _G.g_Stage.m_sceneType==_G.Const.CONST_MAP_TYPE_COPY_HERO
        or _G.g_Stage.m_sceneType==_G.Const.CONST_MAP_TYPE_COPY_FIEND then

        data1 = "你没能通过本关！"
        data2 = ""
        data3 = ""
        data4 = "请加强实力，重新来过！"
        data5 = ""
        data6 = ""
        local myNode = self : showWords( data1, data2, data3, data4, data5, data6, data7, data8, data9, color_1, color_2 )
        myNode : setPosition( -220, 21 )
        self.m_rootLayer : addChild( myNode )
    else
        local appraiseSprite=cc.Sprite:createWithSpriteFrameName("ui_battle_res_word.png")
        appraiseSprite:setScale(1.5)
        appraiseSprite:setPosition(0,-30)
        self.m_rootLayer:addChild(appraiseSprite)
        appraiseSprite:runAction(cc.ScaleTo:create(0.4,1))

        local appraiseEffectSprite=cc.Sprite:createWithSpriteFrameName("ui_battle_res_word.png")
        appraiseEffectSprite:setPosition(0,-30)
        appraiseEffectSprite:setVisible(false)
        self.m_rootLayer:addChild(appraiseEffectSprite)

        local function actionCallFunc()
            appraiseEffectSprite:removeFromParent(true)
        end
        local myScaleTo=cc.ScaleTo:create(0.4,0.5)
        local fadeTo=cc.FadeTo:create(0.4,50)

        appraiseEffectSprite:runAction(cc.Sequence:create(cc.DelayTime:create(0.4),
                                                cc.Show:create(),
                                                cc.EaseInOut:create(cc.Spawn:create(myScaleTo,fadeTo),0.5),
                                                cc.CallFunc:create(actionCallFunc)))
    end

    self:__loseButtonShow()

    if (_G.g_Stage.m_sceneType == _G.Const.CONST_MAP_TYPE_CHALLENGEPANEL
        or _G.g_Stage.m_sceneType==_G.Const.CONST_MAP_TYPE_PK_LY or 
        _G.g_Stage.m_sceneType == _G.Const.CONST_MOUNTAIN_KING_MAP)
        and self.ackData[1]~=nil then
        local function btn_goodCallback(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                local goodId=sender:getTag()
                if goodId == -1 then return end
                local pos=sender:getWorldPosition()
                local temp=_G.TipsUtil:createById(goodId,nil,pos)
                cc.Director:getInstance():getRunningScene():addChild(temp,1000)
            end
        end

        local viewSize = cc.size( 385, 90 )
        local containerSize = cc.size( 385*2, 90 )
        local posX,posY = -340,-180
        local width = 100
        local labelTbl = {}
        local goodBox = {}

        local node1  = cc.Node : create()
        node1 : setPosition( posX+90, posY )
        self.m_rootLayer : addChild( node1,5 )

        local lbJiangLi=_G.Util:createLabel("奖励:",20)
        -- lbJiangLi:setColor(color1)
        lbJiangLi:setAnchorPoint(cc.p(1,0.5))
        lbJiangLi:setPosition(80,60)
        lbJiangLi:setOpacity(0)
        lbJiangLi:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.FadeTo:create(0.2,255)))
        node1:addChild(lbJiangLi)
        for i=1,4 do
            goodBox[i]   = ccui.Button:create()
            goodBox[i]   : loadTextures("general_tubiaokuan.png","general_tubiaokuan.png","", ccui.TextureResType.plistType)
            goodBox[i]   : addTouchEventListener(btn_goodCallback)
            goodBox[i]   : setPosition(35+width*i,20)
            goodBox[i]   : setVisible(false)
            goodBox[i]   : runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.Show:create()))
            node1    : addChild(goodBox[i],5)
        end

        local function schedulerCallFunc()
            self:updateData()
        end

        local sprSize = goodBox[1]:getContentSize()
        for i,v in ipairs(self.showLabelNames) do
            -- local node2 = cc.Sprite:create()
            -- node2:setAnchorPoint(0.5,0.5)
            -- goodBox[i]:addChild(node2)
            local goodsCnf=_G.Cfg.goods[tonumber(v)]
            local spr = _G.ImageAsyncManager:createGoodsSpr(goodsCnf)
            
            goodBox[i]:addChild(spr)
            goodBox[i]:setTag(tonumber(v))
            spr:setPosition(sprSize.width/2,sprSize.height/2)

            local function c(node,data  )
                local i = data[1]
                local labelNum = _G.Util:createBorderLabel("0",16)
                labelNum:setColor( _G.ColorUtil : getRGB( _G.Const.CONST_COLOR_GOLD ) )
                goodBox[i]:addChild(labelNum)
                labelNum:setAnchorPoint(1,0)
                labelNum:setPosition(sprSize.width-10,5)
                table.insert(labelTbl,labelNum)
                if self.ackData[i*2] == 1 then
                    labelNum:setVisible(false)
                end
                self.scheduleIndex=0
                if self.schdedulerHandle~=nil then return end
                self.schdedulerHandle=_G.Scheduler:schedule(schedulerCallFunc, 0.001)
            end
            local function f( )
                _G.Util:playAudioEffect("balance_reward")
            end
            local lbg = cc.Sprite:createWithSpriteFrameName("ui_battle_boom.png")
            lbg:setPosition(35+width*(i+1)+posX,posY)
            self.m_rootLayer:addChild(lbg,100)
            lbg:setScale(0)
            lbg:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.DelayTime:create(0.3*i),cc.Spawn:create(cc.ScaleTo:create(0.2,2),cc.FadeOut:create(0.4))))
            spr:setScale(0)
            spr : runAction( cc.Sequence:create(
                                                cc.DelayTime: create( 2),cc.DelayTime:create(0.3*i),
                                                cc.CallFunc:create(f),
                                                cc.ScaleTo : create( 0.3, 1 ),
                                                cc.CallFunc:create(c,{i})
                                            )
                        )
        end

        self.labelsTbl=labelTbl
    end
end

function UIBattleResult.showLingYaoResult(self,_isLose)
    local resArray=_G.g_Stage.m_lingYaoResultArray
    if not resArray then return end

    local tempAct=cc.FadeTo:create(0.5,255)
    local tempY=_isLose and -30 or 15
    for i=1,3 do
        local res=resArray[i] or 1
        local szMsg=i
        local nColor=nil
        -- res: 1:我输了，  2:平手，  4:我赢了
        if res==1 then
            szMsg=szMsg..": 失败"
            nColor=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKWHITE)
        elseif res==2 then
            szMsg=szMsg..": 平手"
            nColor=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKWHITE)
        elseif res==4 then
            szMsg=szMsg..": 胜利"
            nColor=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD)
        end

        local tempLabel=_G.Util:createLabel(szMsg,20)
        tempLabel:setPosition((i-2)*180,tempY)
        tempLabel:setOpacity(0)
        tempLabel:runAction(tempAct:clone())
        self.m_rootLayer:addChild(tempLabel)

        if nColor then
            tempLabel:setColor(nColor)
        end
    end

    if _isLose then return end

    local isAddSpr=false
    local szArray={}
    local colorArray={}

    local tempCount=0

    tempCount=tempCount+1
    szArray[tempCount]="你击败了"

    tempCount=tempCount+1
    szArray[tempCount]=self.ackData.name or ""
    colorArray[tempCount]=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN)

    -- self.ackData.up=200
    -- self.ackData.rank=666
    if self.ackData.up~=0 and self.ackData.rank~=nil then
        tempCount=tempCount+1
        szArray[tempCount]=",排名上升至第"

        tempCount=tempCount+1
        szArray[tempCount]=self.ackData.rank
        colorArray[tempCount]=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN)

        tempCount=tempCount+1
        szArray[tempCount]="名"

        tempCount=tempCount+1
        szArray[tempCount]=string.format( "%s%d%s", "（", self.ackData.up, "   ）" )
        colorArray[tempCount]=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BLUE)

        isAddSpr=true
    else
        tempCount=tempCount+1
        szArray[tempCount]=",排名保持不变"
    end

    local tempNode=cc.Node:create()
    self.m_rootLayer:addChild(tempNode)

    local tempWid=0
    for i=1,tempCount do
        local tempLb=_G.Util:createLabel(szArray[i],20)
        tempLb:setAnchorPoint(cc.p(0,0.5))
        tempLb:setPosition(tempWid,0)
        tempLb:setOpacity(0)
        tempLb:runAction(tempAct:clone())
        tempNode:addChild(tempLb)

        if colorArray[i] then
            tempLb:setColor(colorArray[i])
        end
        tempWid=tempWid+tempLb:getContentSize().width
    end
    tempNode:setPosition(-tempWid*0.5,-25)

    if isAddSpr then
        local tempSpr=cc.Sprite:createWithSpriteFrameName("ui_battle_up.png")
        tempSpr:setAnchorPoint(1,0.5)
        tempSpr:setPosition(tempWid-12,0)
        tempSpr:setVisible(false)
        tempNode:addChild(tempSpr,10)
        local function nFun()
            tempSpr:setVisible(true)
        end
        tempSpr:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(nFun)))
    end

end

function UIBattleResult.__loseButtonShow(self)
    local function c(sender,eventType)
        return self:__btnCallback(sender,eventType)
    end

    local posY=-260
    local certainButton=gc.CButton:create("ui_battle_res_btn2.png")
    certainButton:addTouchEventListener(c)
    certainButton:setPosition(self.m_winSize.width/2-20,posY)
    certainButton:setAnchorPoint( 1, 0.5 )
    certainButton:setVisible(false)
    certainButton:ignoreContentAdaptWithSize(false)
    certainButton:setContentSize(cc.size(certainButton:getContentSize().width+30,certainButton:getContentSize().height+30))
    self.m_rootLayer:addChild(certainButton)

    local handButton=gc.CButton:create("ui_battle_res_btn1.png")
    handButton:addTouchEventListener(c)
    handButton:setPosition(self.m_winSize.width/2-150,posY)
    handButton:setAnchorPoint( 1, 0.5 )
    handButton:setVisible(false)
    handButton:setTag(300)
    self.m_rootLayer:addChild(handButton)

    local function actionCallFunc()
        certainButton:setVisible(true)
        handButton:setVisible(true)
    end

    certainButton:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(actionCallFunc)))
end

function UIBattleResult.__btnCallback(self,sender,eventType)
    if eventType == ccui.TouchEventType.ended then
        if self.schdedulerHandle~=nil then
            _G.Scheduler:unschedule(self.schdedulerHandle)
        end
        self.m_rootLayer:removeFromParent(true)
        _G.g_Stage:exitCopy()
        if sender:getTag()==300 then
            _G.g_WoYaoBianQiang = true
        end
    end
end

return UIBattleResult