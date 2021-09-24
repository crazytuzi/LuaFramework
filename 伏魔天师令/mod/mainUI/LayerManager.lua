local P_SYS_ARRAY=_G.Cfg.P_SYS_ARRAY

local LayerManager = classGc(function(self)
    self.m_subViewArray={}
    self.m_waitOpenScene=false
end)

LayerManager.type_sysOpen         = 1
LayerManager.type_useGoods        = 3
LayerManager.type_recommendFriend = 4
LayerManager.type_newSkill        = 5

function LayerManager.resetLayerInfo(self,_layerId,_data1,_data2,_data3)
    local sysInfo=P_SYS_ARRAY[_layerId]
    if sysInfo~=nil then
        _layerId=sysInfo.id
        _data1=_data1 or sysInfo._data1
        _data2=_data2 or sysInfo._data2
        _data3=_data3 or sysInfo._data3
    end
    return _layerId,_data1,_data2,_data3
end

----------------------------------------------------------
--通用的打开界面     暂定：根据功能开发ID 
--_isAction->是否动画跳转    
--_data1, _data2, _data3  ---->传入自己界面需要的，不用的话不传
----------------------------------------------------------
function LayerManager.openLayer( self, _layerId, _noAction, _data1, _data2, _data3 )
    if ScenesManger.isLoading or self.m_waitOpenScene then
        return
    end
    local _layerId,_data1,_data2,_data3=self:resetLayerInfo(_layerId,_data1,_data2,_data3)
    self.layerData={_layerId=_layerId, _noAction=_noAction, _data1=_data1, _data2=_data2, _data3=_data3}
    ScenesManger.loadScene(self,_layerId)
end

--延迟打开场景
function LayerManager.delayOpenLayer( self, _layerId, _noAction, _data1, _data2, _data3,delayTime )
    if ScenesManger.isLoading or self.m_waitOpenScene then
        return
    end
    local _layerId,_data1,_data2,_data3=self:resetLayerInfo(_layerId,_data1,_data2,_data3)
    self.layerData={_layerId=_layerId, _noAction=_noAction, _data1=_data1, _data2=_data2, _data3=_data3}
    local function onDelayCallback()
        ScenesManger.loadScene(self,_layerId)
    end
    delayTime=delayTime or 0.2
    _G.Scheduler:performWithDelay(delayTime, onDelayCallback)
end

--在现有的场景下，打开新的场景，资源绑定在上个场景
function LayerManager.openSubLayer( self, _layerId, _noAction, _data1, _data2, _data3 )
    -- if self.m_isOpenInTime == true then return end
    if ScenesManger.isLoading or self.m_waitOpenScene then
        return
    end
    local _layerId,_data1,_data2,_data3=self:resetLayerInfo(_layerId,_data1,_data2,_data3)
    self.layerData={_layerId=_layerId, _noAction=_noAction, _data1=_data1, _data2=_data2, _data3=_data3}

    ScenesManger.loadScene(self,_layerId,nil,nil,true)
end

--资源加载回调
function LayerManager.show(self, _layerId)
    self:startOpenLayer(self.layerData._layerId,self.layerData._noAction,self.layerData._data1,self.layerData._data2,self.layerData._data3)
end

function LayerManager.startOpenLayer( self, _layerId, _noAction, _data1, _data2, _data3 )
    gcprint("\nLayerManager.startOpenLayer====>>>>>_layerId=",_layerId,_data1, _data2, _data3)

    if _G.g_Stage.m_lpPlay then
        _G.g_Stage.m_lpPlay.m_lpMovePos=nil
    end
    
    _G.g_Stage:cancelJoyStickTouch()
    _G.GTaskProxy:setAutoFindWayData()

    local runningScene=cc.Director:getInstance():getRunningScene()
    local parentNode=nil
    if _G.g_Stage:getScene()~=runningScene then
        parentNode=runningScene
    else
        parentNode=_G.g_Stage:getSysViewContainer()
    end
    if parentNode:getChildByTag(_layerId) then
        return
    end

    local view=nil
    local layer=nil
    local scene=nil
    local isNoBg=false
    local isAddMoneyView=true
    local loadTimes=nil
    if _layerId == Cfg.UI_CTaskDialogView then                   -- NPC 对话界面
        gcprint("NPC 对话界面")
        --打开界面
        view=require("mod.task.TaskDialog")()
        layer=view:create(_data1,_data2)
        layer:setTag(_layerId)
        parentNode:addChild(layer)
        return
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_ROLE then
        gcprint("角色界面")
        view =require("mod.role.RoleView")(_data1,_data2)
        scene=view:create()
        ---------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_BAG then
        gcprint("背包界面")
        view =require("mod.bag.BagView")(_data1,_data2)
        scene=view:create()
        ---------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_GANGS then
        gcprint("门派",_data1,_data2)
        if _data2 and _data2~=1 and _data2~=2 then
            local clanId=_G.GPropertyProxy:getMainPlay():getClan()
            if not clanId or clanId==0 then
                local command=CErrorBoxCommand(11515)
                _G.controller:sendCommand(command)
                return
            end
        end
        view = require("mod.clan.ClanPanelView")(_data1, _data2, _data3)
        scene= view:create()
        loadTimes=0.3
        -----------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_TASK  then
        gcprint("任务")
        view =require("mod.task.TaskView")(_data1)
        scene=view:create()
        ---------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_MALL then
        gcprint("邮件")
        view =require("mod.email.EmailView")()
        scene=view:create()
        loadTimes=0.3
    ---------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_LUCKY then
        gcprint("祈福")
        view =require("mod.zhaocai.ZhaoCaiView")()
        scene=view:create()
    ---------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_RECHARGE then
        gcprint("充值")
        view =require("mod.recharge.zhuRechargeView")(_data1)
        scene=view:create()
        ---------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_WELFARE then
        gcprint("福利")
        view =require("mod.welfare.WelfareView")(_data1)
        scene=view:create()
        loadTimes=0.3
        ---------------------------------------------------------------------

    elseif _layerId == _G.Const.CONST_FUNC_OPEN_SHOP then
        gcprint("商城",_data1)
        view =require("mod.shop.ShopView")(_data1)
        scene=view:create()
        ---------------------------------------------------------------------
    -- elseif _layerId == _G.Const.CONST_FUNC_OPEN_SHOP_SHENQI then
    --     gcprint("兑换商城",_data1)
    --     view =require("mod.couponshop.CouponShopView")(_data1)
    --     scene=view:create()
        ---------------------------------------------------------------------

    elseif _layerId == _G.Const.CONST_FUNC_OPEN_SETING then
        gcprint("系统设置")
        view = require("mod.systemSetting.SettingView")()
        scene=view:create()
        ---------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_GAMBLE then
        gcprint("翻翻乐")
        view =require("mod.gamble.gambleView")(_data1)
        scene=view:create()
        ---------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_CARDS then
        gcprint("对对牌")
        view =require("mod.smodule.CardsView")()
        scene=view:create()
        ---------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_MYTH then
        gcprint("群雄争霸")  -- 封神之战
        view =require("mod.expedit.expeditView")()
        scene=view:create()
        isNoBg=true
        isAddMoneyView=false
        ---------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_EXAMINATION then
        gcprint("御前科举")
        view =require("mod.smodule.KeJuView")()
        scene=view:create()
        ---------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_SEVENDAY then
        gcprint("开服七日")
        view = require("mod.smodule.SevenDayView")()
        scene=view:create()
        loadTimes=0.3
        ---------------------------------------------------------------------
        
    elseif _layerId == Cfg.UI_CCopyMapLayer then
        gcprint("副本界面")
        view =require("mod.copy.CopyView")(_data1)
        scene=view:create()
        ---------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_STRATEGY then
        gcprint("攻略")
        view = require("mod.gonglue.GongLueView")(_data1)
        scene=view:create()
        loadTimes=0.2
        ---------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_FRIEND then
        gcprint("好友")
        view = require("mod.friend.FriendView")()
        scene=view:create()
        loadTimes=0.2
        ---------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_PARTNER then
        gcprint("伙伴")
        view=require("mod.partner.PartnerView")(_data1)
        scene=view:create()
        ---------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_DAEMON then
        gcprint("仙宠")
        view=require("mod.daemon.DaemonView")()
        scene=view:create()
        ---------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_SMITHY then
        gcprint("湛卢坊")
        view=require("mod.equip.EquipView")(_data1)
        scene=view:create()
        ---------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_MOUNT then
        gcprint("坐骑")
        view=require("mod.mount.MountView")(_data1)
        scene=view:create()
        loadTimes=0.2
        ---------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_WING then
        gcprint("宠物")
        view=require("mod.really.ReallyView")(_data1)
        scene=view:create()
        isNoBg=true
        isAddMoneyView=false
        ---------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_REBATE then
        gcprint("精彩返利")
        view =require("mod.rebate.RebateView")()
        scene=view:create()
        loadTimes=0.3
        ---------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_TEAM then
        gcprint("群仙诛邪")
        view =require("mod.team.TeamView")(_data1)
        scene=view:create()
        ---------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_CHATTING then
        gcprint("聊天")
        view = require("mod.chat.ChatView")(_data1)
        layer=view:create()
        ---------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_ARENA then
    	gcprint("竞技场")
    	view = require("mod.smodule.ArenaView")(_data1)
        scene=view:create()
        isNoBg=true
        isAddMoneyView=false
        ---------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_LYJJ then
        gcprint("灵妖竞技")
        view = require("mod.lingyao.LingYaoView")(_data1)
        scene=view:create()
        isNoBg=true
        isAddMoneyView=false
        ---------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_PAIHANG then
        gcprint("排行榜")
        view = require("mod.smodule.RankingView")()
        scene=view:create()
        ---------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_WELKIN then
        gcprint("大闹天宫")
        view = require("mod.welkin.WelkinView")(_data1,_data2)
        scene=view:create()
    elseif _layerId == _G.Const.CONST_MAP_WELKIN_FIRST then
        gcprint("玉清元始")
        view = require("mod.welkin.Welkin_FirstView")(_data1)
        scene=view:create()
        isNoBg=true
        isAddMoneyView=false
    elseif _layerId == _G.Const.CONST_MAP_WELKIN_BATTLE then
        gcprint("巅峰之战")
        view = require("mod.welkin.Welkin_BattleView")()
        scene=view:create()
        isNoBg=true
        isAddMoneyView=false
    elseif _layerId == _G.Const.CONST_MAP_WELKIN_ONLY then
        gcprint("太清混元")
        view = require("mod.welkin.Welkin_OnlyView")()
        scene=view:create()
        isNoBg=true
        isAddMoneyView=false
        ---------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_DEMONS then
        gcprint("无尽心魔")  -- 一骑当千
        view = require("mod.smodule.DemonsView")()
        scene=view:create()
        ---------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_TOWER then
        gcprint("通天浮图")
        view = require("mod.smodule.FuTuView")()
        scene=view:create()
        -------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_SURRENDER then
        gcprint("降魔之路")
        view = require("mod.smodule.ChallengeView")()
        scene=view:create()
        ---------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_JINGXIU then
    	gcprint("浮图静修")
        view =require("mod.smodule.JingXiuView")()
        scene=view:create()
        ---------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_MOIL then
    	gcprint("奴仆")
        view =require("mod.smodule.ServantView")(_data1)
        scene=view:create()
        ---------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_BOSS then
        gcprint("世界boss")  -- 勾魂使者
        view = require("mod.worldboss.WorldBossView")(_data1)
        scene=view:create()
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_STRIVE then
        gcprint("三界争锋")
        view = require("mod.smodule.StriveView")()
        layer=view:create()
    	---------------------------------------------------------------------
    elseif _layerId == _G.Cfg.UI_SubStriveView then
    	gcprint("三界争锋(初赛/决赛)")
    	view = require("mod.smodule.SubStriveView")(_data1)
        scene=view:create()
        isNoBg=true
        isAddMoneyView=false
        ---------------------------------------------------------------------
    elseif _layerId == _G.Cfg.UI_BattleCompareView then
        gcprint("战力对比")
        view = require("mod.smodule.BattleComparisonView")()
        scene=view:create(_data1)
        ---------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_SHEN then
    	gcprint("八卦")
        view =require("mod.smodule.SoulView")(_data1,_data2)
        scene=view:create()
        ---------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_HOLIDAY then
        gcprint("节日活动")
        view =require("mod.feastActivity.FeastActivityView")(_data1)
        scene=view:create()
    ---------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_AUCTION then
    	gcprint("竞拍")
        view =require("mod.smodule.AuctionView")()
        scene=view:create()
        ---------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_JEWELLERY then
        gcprint("珍宝")
        view =require("mod.treasure.TreasureView")()
        scene=view:create()
        ---------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_RUSH then
        gcprint("限时抢购")
        view =require("mod.smodule.RushView")()
        scene=view:create()
        ---------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_SRSC then
        gcprint("每日首冲")
        view =require("mod.smodule.EverydayView")()
        layer=view:create()
        ---------------------------------------------------------------------  
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_ARTIFACT then
    	gcprint("神兵")
        view =require("mod.artifact.ArtifactView")(_data1,_data2)
        scene=view:create()
        ---------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_QILING then
        gcprint("武器")
        view =require("mod.smodule.QiLingView")(_data1)
        scene=view:create()
        ---------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_FEATHER then
        gcprint("翅膀")
        view =require("mod.feather.FeatherView")(_data1,_data2)
        scene=view:create()
        ---------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_BOX then
        gcprint("秘宝活动")
        view =require("mod.smodule.MiBaoBoxView")()
        scene=view:create()
        ---------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_BEAUTY then
    	gcprint("美人")
    	view = require("mod.beauty.BeautyView")(_data1)
        scene=view:create()
        isNoBg=true
        isAddMoneyView=false
        --------------------------------------------------------------------
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_DAOJIE   then 
        gcprint("道劫")
        view = require("mod.smodule.DaoJieView")(_data3)
        scene =  view:create()
        --print("AAAAAAAAAaA",view,_data3,_data1)
        ---------------------------------------------------------------------  
    elseif _layerId == _G.Const.CONST_FUNC_OPEN_CHENGJIU   then 
        gcprint("成就")
        view = require("mod.smodule.AchieveView")()
        scene =  view:create()
        --print("AAAAAAAAAaA",view,_data3,_data1)
        ---------------------------------------------------------------------  
    else
        gcprint("")
        gcprint("")
        gcprint(" ******************【LayerManager ERROR】****************** ")
        gcprint(" 没有处理界面打开=========>>> _layerId=",_layerId)
        gcprint(" __________________________________________________________ ")
        gcprint("")
        gcprint("")
    end

    if view~=nil then
        if layer~=nil then
            layer:setTag(_layerId)
            parentNode:addChild(layer,_G.Const.CONST_MAP_ZORDER_LAYER)
            self:showLayerEffect(layer,view)
        elseif scene~=nil then
            self:pushLuaScene(scene,isNoBg,isAddMoneyView,loadTimes)
        end
    end
end

--通过打开某某界面的Id打开相应的界面   例如ID->_G.Const.CONST_MAP_HERO_COPY(常量在场景模块里面)
function LayerManager.openLayerByMapOpenId( self, _mapOpenId, _noAction, _noDelay )
    if _mapOpenId == _G.Const.CONST_MAP_ENARGY then
        --购买体力
        local msg=REQ_ROLE_ASK_BUY_ENERGY()
        _G.Network:send( msg)
        return
    end

    local funcId,data1,data2,data3 = _G.GOpenProxy :getFuncIdByOpenLayerId(_mapOpenId)

    if funcId then
        CCLOG("openLayerByMapOpenId  _mapOpenId->%s,  funcId->%s",tostring(_mapOpenId),tostring(funcId))
        if _noDelay then
            self :openLayer(funcId,_noAction,data1,data2,data3)
        else
            self :delayOpenLayer(funcId,_noAction,data1,data2,data3)
        end
    else
        GCLOG("openLayerByMapOpenId  _mapOpenId->%s,  funcId->nil",tostring(_mapOpenId))
    end
end

--通过打开某某界面的Id打开相应的界面   例如ID->_G.Const.CONST_MAP_HERO_COPY(常量在场景模块里面)
function LayerManager.openSubLayerByMapOpenId( self, _mapOpenId, _noAction )
    if _mapOpenId == _G.Const.CONST_MAP_ENARGY then
        --购买体力
        local msg=REQ_ROLE_ASK_BUY_ENERGY()
        _G.Network:send( msg)
        return
    end

    local funcId,data1,data2,data3 = _G.GOpenProxy :getFuncIdByOpenLayerId(_mapOpenId)

    if funcId then
        CCLOG("openSubLayerByMapOpenId  _mapOpenId->%s,  funcId->%s",tostring(_mapOpenId),tostring(funcId))
        self :openSubLayer(funcId,_noAction,data1,data2,data3)
    else
        GCLOG("openSubLayerByMapOpenId  _mapOpenId->%s,  funcId->nil",tostring(_mapOpenId))
    end
end

function LayerManager.showLayerEffect(self,_layer,_view)
    if _layer==nil then return end

    -- local minScale=0.8
    -- _layer:setAnchorPoint(cc.p(0.5,0.5))
    -- _layer:setScale(minScale)
    -- _layer:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2,1.05),cc.ScaleTo:create(0.1,1),cc.CallFunc:create(nFun)))

    -- local tempLayer=cc.LayerColor:create(cc.c4b(0,0,0,0))
    -- tempLayer:setScale(1/minScale)
    -- tempLayer:runAction(cc.FadeTo:create(0.3,150))
    -- _layer:addChild(tempLayer,-100)

    local tempLayer=cc.LayerColor:create(cc.c4b(0,0,0,255*0.5))
    _layer:addChild(tempLayer,-100)
end

--跳转场景动画
function LayerManager.pushLuaScene( self, _scene, _isNoBg, _addHeadView, _loadTimes )
    if not _scene then return end

    -- if not _isNoBg then
    --     local winSize=cc.Director:getInstance():getWinSize()
    --     local viewBgSpr=cc.Sprite:create("ui/bg/view_bg.jpg")
    --     viewBgSpr:setScale(2)
    --     viewBgSpr:setPosition(winSize.width*0.5,320)
    --     -- viewBgSpr:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.TintTo:create(2,cc.c3b(255,222,222)),cc.TintTo:create(2,cc.c3b(255,255,255)))))
    --     _scene:addChild(viewBgSpr,-1)
    -- end

    local tempNode=cc.Node:create()
    _scene:addChild(tempNode,_G.Const.CONST_MAP_ZORDER_NOTIC-10)

    local function nFun(event)
        if event=="enter" then
            _G.Util:getLogsView():initMarqueeParent(tempNode)
            if _addHeadView then
                _G.GMoneyView:addInNode(tempNode)
            end
        end
    end
    tempNode:registerScriptHandler(nFun)

    if _addHeadView then
        if not _G.GMoneyView then
            _G.GMoneyView=require("mod.mainUI.MoneyView")()
        end
        _G.GMoneyView:addInNode(tempNode)
    end

    -- cc.TransitionCrossFade:create(0.1,_scene)
    self :pushEffectScene( _scene, _loadTimes )
end

-- {打开界面}
function LayerManager.pushEffectScene( self, _scene, _loadTimes )
    if not _scene then return end

    -- self.m_waitOpenScene=true

    -- local delayTime=0.3
    -- local function local_delayFun1()
    --     cc.Director:getInstance():getEventDispatcher():setEnabled(true)
    --     self.m_waitOpenScene=false
    -- end
    -- local function local_delayFun2()
    --     cc.Director:getInstance():pushScene(cc.TransitionPageTurn:create(0.3,_scene,true))
    --     _G.Scheduler:performWithDelay(delayTime,local_delayFun1)
    --     if _loadTimes then
    --         _scene:release()
    --     end
    -- end

    -- if not _loadTimes then
    --     local_delayFun2()
    -- else
    --     delayTime=_loadTimes+0.1
    --     _scene:retain()
    --     _G.Scheduler:performWithDelay(_loadTimes,local_delayFun2)
    -- end
    -- cc.Director:getInstance():getEventDispatcher():setEnabled(false)


    local delayTime=0.3
    if _G.g_Stage.m_fromBattleScene==true then
        _G.g_Stage.m_fromBattleScene=nil
        delayTime=0.8
    end
    local function local_delayFun( dt )
        cc.Director:getInstance():getEventDispatcher():setEnabled(true)
    end
    _G.Scheduler:performWithDelay(delayTime,local_delayFun)
    cc.Director:getInstance():getEventDispatcher():setEnabled(false)
    cc.Director:getInstance():pushScene(_scene)
end


--打开任务界面
function LayerManager.openTaskDialog( self, _npcId, _isUserTouch )
    self:openLayer(Cfg.UI_CTaskDialogView,true,_npcId,_isUserTouch)
end
function LayerManager.closeTaskDialog(self)
    local command=CloseWindowCommand(_G.Cfg.UI_CTaskDialogView)
    controller:sendCommand(command)
end
function LayerManager.isTaskDialogOpen(self)
    return _G.g_Stage:getScene():getChildByTag(88889)
end

function LayerManager.showPlayerView(self,_roleUid,_isArtifact,_isRole)
    if _G.GPropertyProxy:getMainPlay():getUid()==_roleUid or not _roleUid then return end

    print("请求玩家属性开始:",_roleUid,_isArtifact,_isRole)
    local msg=REQ_ROLE_PROPERTY()
    msg:setArgs(_G.GLoginPoxy:getServerId(),_roleUid,0)
    _G.Network:send(msg)

    self.m_isArtifact=_isArtifact
    self.m_isRole=_isRole
    self.showPlayerUid=_roleUid
end

function LayerManager.chuangeSubView(self)
    local nCount=#self.m_subViewArray
    local newArray={}
    local newCount=0
    for i=1,nCount do
        if self.m_subViewArray[nCount].type~=self.type_sysOpen then
            newCount=newCount+1
            newArray[newCount]=self.m_subViewArray[nCount]
        end
    end
    self.m_subViewArray=newArray
end
function LayerManager.hasSysOpen(self)
    local nCount=#self.m_subViewArray
    for i=1,nCount do
        if self.m_subViewArray[nCount].type==self.type_sysOpen then
            return true
        end
    end
    return false
end
function LayerManager.addSubView(self,_type,_data1,_data2,_data3)

    local nCount=#self.m_subViewArray
    if _type==self.type_sysOpen then
        gcprint("addSubView  type_sysOpen====>>>>sysId=",_data1,_G.Cfg.sys_open_info[_data1])
        local openInfoCnf=_G.Cfg.sys_open_info[_data1]
        if openInfoCnf==nil then
            gcprint("addSubView  type_sysOpen... openInfoCnf==nil")
            return
        elseif openInfoCnf.open_effect==0 then
            return
        end
        if _G.pmainView==nil then return end

        local sysBtn=_G.pmainView:hideOpenIconBtn(openInfoCnf.open_id,openInfoCnf.parent_id)
        if sysBtn==nil then return end

        _data2=openInfoCnf
    elseif _type==self.type_useGoods then
        print("OOOOOOO>>>>>>>> 1")
        local uninstallEquip=_G.TipsUtil.m_uninstallEquip
        if uninstallEquip~=nil then
            _G.TipsUtil.m_uninstallEquip=nil

            if _data1.goods_id==uninstallEquip.goods_id then
                return
            end
        end

        local subData1=nil
        for i=1,nCount do
            local tempT=self.m_subViewArray[i]
            if tempT.type==_type then
                subData1=tempT.data1
                break
            end
        end
        if subData1 then
            local isSameGoods=false
            for i=1,#subData1 do
                if subData1[i].goodsMsg.goods_id==_data1.goods_id and subData1[i].goodsMsg.index==_data1.index then
                    -- 同个物品
                    subData1[i].goodsMsg=_data1
                    isSameGoods=true
                    break
                end
            end
            if not isSameGoods then
                subData1[#subData1+1]={
                    goodsMsg=_data1,
                    uid=_data2
                }
            end
            return
        else
            subData1={{goodsMsg=_data1,uid=_data2}}
            _data1=subData1
            _data2=nil
        end
    elseif _type==self.type_newSkill then
        return
    end

    local listData = {}
    listData.type  = _type
    listData.data1 = _data1
    listData.data2 = _data2
    listData.data3 = _data3
    self.m_subViewArray[nCount+1]=listData

    local command=CMainUiCommand(CMainUiCommand.SUBVIEW_ADD)
    _G.controller:sendCommand(command)
end

function LayerManager.isTeamViewOpen(self)
    return _G.g_Stage:getScene():getChildByTag(_G.Const.CONST_FUNC_OPEN_TEAM)
end

function LayerManager.isChatViewOpen(self)
    local parentNode
    local runningScene=cc.Director:getInstance():getRunningScene()
    if _G.g_Stage:getScene()~=runningScene then
        parentNode=runningScene
    else
        parentNode=_G.g_Stage:getSysViewContainer()
    end
    return parentNode:getChildByTag(_G.Const.CONST_FUNC_OPEN_CHATTING)
end

--通用提示
function LayerManager.showMessageBox( self, _msg )
    _G.Util:showTipsBox(_msg)
end

--飘字
function LayerManager.showErrorCode( self, _code )
    local command = CErrorBoxCommand( _code )
    controller :sendCommand( command )
end

return LayerManager