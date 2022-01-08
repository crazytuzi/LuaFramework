--[[
******群豪榜-对手列表*******

    -- by haidong.gan
    -- 2013/12/27
]]
local ArenaPlayerListLayer = class("ArenaPlayerListLayer", BaseLayer);

ArenaPlayerListLayer.LIST_ITEM_WIDTH = 190; 

CREATE_SCENE_FUN(ArenaPlayerListLayer);
CREATE_PANEL_FUN(ArenaPlayerListLayer);

function ArenaPlayerListLayer:ctor(data)
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.arena.ArenaPlayerListLayer");
end

function ArenaPlayerListLayer:initUI(ui)
  	self.super.initUI(self,ui);

  	self.btn_reward     = TFDirector:getChildByPath(ui, 'btn_reward');
  	self.btn_refresh    = TFDirector:getChildByPath(ui, 'btn_refresh');
    self.btn_show       = TFDirector:getChildByPath(ui, 'btn_duihuan');

    self.panel_head     = TFDirector:getChildByPath(ui, 'panel_head');

  	self.panel_list     = TFDirector:getChildByPath(ui, 'panel_list');

    self.txt_name           = TFDirector:getChildByPath(ui, 'txt_name');
    self.txt_rank           = TFDirector:getChildByPath(ui, 'txt_paimingzhi');

    self.txt_totalCount     = TFDirector:getChildByPath(ui, 'txt_totalCount');
    -- self.txt_winCount       = TFDirector:getChildByPath(ui, 'txt_shenglizhi');
    self.txt_power      = TFDirector:getChildByPath(ui, 'txt_power');
    self.txt_winRate        = TFDirector:getChildByPath(ui, 'txt_shenglvzhi');

    self.txt_challengeCountLeave        = TFDirector:getChildByPath(ui, 'txt_tiaozhancishuzhi');

    self.img_icon           = TFDirector:getChildByPath(ui, 'img_touxiang');

    self.txt_jiangli           = TFDirector:getChildByPath(ui, 'txt_jiangli'); -- 新增
    -- 

    self.pageList = {};

    local pageView = TPageView:create()
    self.pageView = pageView

    pageView:setTouchEnabled(true)
    pageView:setBackGroundColorType(TF_LAYOUT_COLOR_NONE)
    pageView:setSize(self.panel_list:getContentSize())
    pageView:setPosition(self.panel_list:getPosition())
    pageView:setAnchorPoint(self.panel_list:getAnchorPoint())
    pageView:setBounceEnabled(false);
    local function onPageChange()
        self:onPageChange();
    end
    pageView:setChangeFunc(onPageChange)

    local function itemAdd(index)
        return  self:addPage(index);
    end 
    pageView:setAddFunc(itemAdd)


    pageView:_removeAllPages();
    -- pageView:setMaxLength(2);
    pageView:setMaxLength(1); -- king 去滑动
    pageView:InitIndex(1); 

    self.panel_list:addChild(pageView,2);

    self.generalHead = CommonManager:addGeneralHead( self)

    self.generalHead:setData(ModuleType.Arena,{HeadResType.QUNHAO,HeadResType.HERO_SCORE,HeadResType.SYCEE})

    --群豪谱重置相关界面控件
    self.bg_reset               = TFDirector:getChildByPath(ui, 'bg_reset')
    self.btn_reset              = TFDirector:getChildByPath(ui, 'Btn_reset')
    self.btn_reset.logic        = self
    self.img_res_icon           = TFDirector:getChildByPath(ui, 'img_res_icon')
    self.txt_cost               = TFDirector:getChildByPath(ui, 'txt_cost')
    self.txt_wait_time          = TFDirector:getChildByPath(ui, 'txt_lengque')
    --默认隐藏
    self.bg_reset:setVisible(false)

    self.btn_report               = TFDirector:getChildByPath(ui, 'Button_ArenaPlayerListLayer_1')

end

function ArenaPlayerListLayer:onPageChange()
    local pageIndex = self.pageView:_getCurPageIndex() ;
    self:showInfoForPage(pageIndex);
end

function ArenaPlayerListLayer:addPage(pageIndex) 
    local page = nil;
    if pageIndex == 1 then
        self.playerNodeList = {}
        page = createUIByLuaNew("lua.uiconfig_mango_new.arena.ArenaPlayerPage1Layer");
        for i=1,5 do
            self.playerNodeList[i] = TFDirector:getChildByPath(page, 'panel_role' .. (i -1));
            self.playerNodeList[i]:setVisible(false);
        end
        self.fsBuzhen = TFDirector:getChildByPath(page, 'Button_ArenaPlayerPage1Layer_1');
        self.fsBuzhen:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onFSBZClickHandle),1);

        local bg = TFDirector:getChildByPath(page, 'bg');
        local resPath = "fightmap/effect/arena_map1_b.xml"
        TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
        local effect = TFArmature:create("arena_map1_b_anim")
        effect:setAnimationFps(GameConfig.ANIM_FPS)
        effect:setPosition(ccp(bg:getSize().width/2,bg:getSize().height/2))
        bg:addChild(effect,1)
        effect:playByIndex(0, -1, -1, 1)


        local resPath = "fightmap/effect/arena_map1_f.xml"
        TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
        local effect = TFArmature:create("arena_map1_f_anim")
        effect:setAnimationFps(GameConfig.ANIM_FPS)
        effect:setPosition(ccp(page:getSize().width/2,page:getSize().height/2))
        page:addChild(effect,1)
        effect:playByIndex(0, -1, -1, 1)
    end

    if pageIndex == 2 then
        self.topPlayerNodeList = {}
        page = createUIByLuaNew("lua.uiconfig_mango_new.arena.ArenaPlayerPage2Layer");
        for i=1,7 do
            self.topPlayerNodeList[i] = TFDirector:getChildByPath(page, 'panel_role' .. (4 + i));
            self.topPlayerNodeList[i]:setVisible(false);
        end
        local bg = TFDirector:getChildByPath(page, 'bg');
        local resPath = "fightmap/effect/arena_map2_b.xml"
        TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
        local effect = TFArmature:create("arena_map2_b_anim")
        effect:setAnimationFps(GameConfig.ANIM_FPS)
        effect:setPosition(ccp(bg:getSize().width/2,bg:getSize().height/2))
        bg:addChild(effect,1)
        effect:playByIndex(0, -1, -1, 1)

        local resPath = "fightmap/effect/arena_map2_f.xml"
        TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
        local effect = TFArmature:create("arena_map2_f_anim")
        effect:setAnimationFps(GameConfig.ANIM_FPS)
        effect:setPosition(ccp(page:getSize().width/2,page:getSize().height/2))
        page:addChild(effect,1)
        effect:playByIndex(0, -1, -1, 1)
    end

    self.pageList[pageIndex] = page;

    return page;
end

function ArenaPlayerListLayer:showInfoForPage(pageIndex)
    self.btn_refresh:setVisible(false);
    if pageIndex == 1 then
        self.btn_refresh:setVisible(true);
    end
    if pageIndex == 2 then

    end
end

function ArenaPlayerListLayer:loadTopPlayerData(data)
    self.topPlayerList = data.playerList;

    self:loadTopPlayerList();
end

function ArenaPlayerListLayer:loadPlayerData(data)
    self.playerList = data.playerList;
    ZhengbaManager:qunHaoDefFormationSet( EnumFightStrategyType.StrategyType_AREAN, self.playerList[1].formation )
    self:loadPlayerList();
end

function ArenaPlayerListLayer:loadHomeData(data)
    self.homeInfo = data;

    self:refreshUI();
end

function ArenaPlayerListLayer:onShow()
    self.super.onShow(self)
    self.generalHead:onShow();
    self:refreshBaseUI();
end

function ArenaPlayerListLayer:refreshBaseUI()
    self.txt_name:setText(MainPlayer:getPlayerName())
    self.img_icon:setTexture(MainPlayer:getHeadPath())

    -- self.txt_fightPower:setText(self.homeInfo.fightPower);
    -- self.txt_totalCount:setText(self.homeInfo.challengeTotalCount);
    -- self.txt_winCount:setText(self.homeInfo.challengeWinCount);
    -- self.txt_failCount:setText(self.homeInfo.challengeTotalCount - self.homeInfo.challengeWinCount);
    self.txt_power:setText(StrategyManager:getPower());

    if self.myPower then
        self.myPower:setText(StrategyManager:getPower())
    end

end

function ArenaPlayerListLayer:refreshUI()
    -- if not self.isShow then
    --     return;
    -- end
    local pageIndex = self.pageView:_getCurPageIndex() ;
    self:showInfoForPage(pageIndex);

    self.txt_rank:setText(self.homeInfo.myRank + 1);

    -- <---------------------- add prize -------
    local prize = ArenaManager:getRewardList(self.homeInfo.myRank + 1)
    -- print("prize = ", prize)
    local desc = ""
    for k,v in pairs(prize.m_list) do
        local number = v.number
        local goods  = v.name

        desc = desc .. number..goods.."  "
    end
    self.txt_jiangli:setText(desc)
    --------------->--------------------------

    if self.homeInfo.challengeTotalCount == 0 then
         self.txt_winRate:setText("0 %");
    else
         local winRate = (self.homeInfo.challengeWinCount / self.homeInfo.challengeTotalCount) * 100;
         -- winRate = winRate - winRate%0.01;
         -- self.txt_winRate:setText(winRate .. " %");
         self.txt_winRate:setText(math.floor(winRate)  .. "%");
    end
    
    self.txt_rank:setText(self.homeInfo.myRank + 1);

    --挑战等待时间刷新，隐藏，显示逻辑


end

function ArenaPlayerListLayer:loadTopPlayerList()
    --没有加载群豪谱前七名数据，这个变量为nil
    if not self.topPlayerNodeList then
        return
    end

    for i=1,7 do
        self.topPlayerNodeList[i]:setVisible(false);
    end

    if self.topPlayerList then
        for index,playerItem in pairs(self.topPlayerList) do

            local player_node = self.topPlayerNodeList[index];
            player_node:setVisible(true);

            local txt_name = TFDirector:getChildByPath(player_node, 'txt_name');
            txt_name:setText(playerItem.playerName);

            if player_node.playerId ~= playerItem.playerId then
                player_node.playerId = playerItem.playerId;    

                local txt_rank = TFDirector:getChildByPath(player_node, 'txt_paiming');
                local str = stringUtils.format(localizable.arenaplaylistlayer_list, playerItem.rank + 1)
                txt_rank:setText(str);

                local txt_lv = TFDirector:getChildByPath(player_node, 'txt_lv');
                txt_lv:setText(playerItem.playerLevel  .. "d");

                local txt_zhanlizhi = TFDirector:getChildByPath(player_node, 'txt_zhanlizhi');
                txt_zhanlizhi:setText(playerItem.fightPower);

                local img_role = TFDirector:getChildByPath(player_node, 'img_rolexingxiang');
                local armature = self:getArmature(playerItem.generalId);
                armature:setRotationY(180);
                self:AddRoleFootEffect(armature);
                img_role:removeAllChildrenWithCleanup(true);
                img_role:addChild(armature,1)


                local btn_attack = player_node;
                btn_attack.logic = self;
                btn_attack.playerId = playerItem.playerId;
                btn_attack:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onPlayerItemClickHandle),1);
            end 
        end
    end
end


function ArenaPlayerListLayer:loadPlayerList()

    for i=1,5 do
        self.playerNodeList[i]:setVisible(false);
    end

    if self.playerList then
        for index,playerItem in pairs(self.playerList) do

            local player_node = self.playerNodeList[index];
            player_node:setVisible(true);

            local txt_rank = TFDirector:getChildByPath(player_node, 'txt_paiming');
            local str = stringUtils.format(localizable.arenaplaylistlayer_list, playerItem.rank + 1)
            txt_rank:setText(str);
            local txt_lv = TFDirector:getChildByPath(player_node, 'txt_lv');
            txt_lv:setText(playerItem.playerLevel  .. "d");

            local txt_zhanlizhi = TFDirector:getChildByPath(player_node, 'txt_zhanlizhi');
            txt_zhanlizhi:setText(playerItem.fightPower);
            if index == 1 then
                self.myPower = TFDirector:getChildByPath(player_node, 'txt_zhanlizhi');
                self.myPower:setText(StrategyManager:getPower())
            end

            if player_node.playerId ~= playerItem.playerId then
                player_node.playerId = playerItem.playerId;
                local txt_name = TFDirector:getChildByPath(player_node, 'txt_name');
                txt_name:setText(playerItem.playerName);

                local img_role = TFDirector:getChildByPath(player_node, 'img_rolexingxiang');
                local armature = self:getArmature(playerItem.generalId);
                if index > 1 then
                    armature:setRotationY(180);
                end
                self:AddRoleFootEffect(armature);
                img_role:removeAllChildrenWithCleanup(true);
                img_role:addChild(armature,1)
                local btn_attack = player_node;
                btn_attack.logic = self;
                btn_attack.playerId = playerItem.playerId;
                btn_attack:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onPlayerItemClickHandle),1);
            end
        end
    end
end

function ArenaPlayerListLayer:getArmature(generalId)
    -- local npcTableData = RoleData:objectByID(generalId)
    -- local resID = npcTableData.image
    -- local resPath = "armature/"..resID..".xml"
    -- if not TFFileUtil:existFile(resPath) then
    --     resID = 10006
    --     resPath = "armature/"..resID..".xml"
    -- end

    -- TFResourceHelper:instance():addArmatureFromJsonFile(resPath)

    -- local armature = TFArmature:create(resID.."_anim")
    -- if armature == nil then
    --     return nil
    -- end
    -- armature:play("stand", -1, -1, 1)
    -- armature:setScale(0.9)
    -- armature:removeUnuseTexEnabled(true);
    -- return armature

    local npcTableData = RoleData:objectByID(generalId)
    local armatureID = npcTableData.image
    if not ModelManager:existResourceFile(1, armatureID) then 
        armatureID = 10006 
    end
    ModelManager:addResourceFromFile(1, armatureID, 1)
    local armature = ModelManager:createResource(1, armatureID)
    if armature == nil then
        assert(false, "armature"..armatureID.."create error")
        return
    end
    armature:setScale(0.65)
    ModelManager:playWithNameAndIndex(armature, "stand", -1, 1, -1, -1)
    return armature
end

function ArenaPlayerListLayer:AddRoleFootEffect(roleArmature)
    TFResourceHelper:instance():addArmatureFromJsonFile("effect/main_role.xml")
    local effect = TFArmature:create("main_role_anim")
    if effect ~= nil then
        effect:setAnimationFps(GameConfig.ANIM_FPS)
        effect:playByIndex(0, -1, -1, 1)
        roleArmature:addChild(effect)
    end

    TFResourceHelper:instance():addArmatureFromJsonFile("effect/main_role2.xml")
    local effect2 = TFArmature:create("main_role2_anim")
    if effect2 ~= nil then
        effect2:setAnimationFps(GameConfig.ANIM_FPS)
        effect2:playByIndex(0, -1, -1, 1)
        effect2:setZOrder(-1)
        effect2:setPosition(ccp(0, -10))
        roleArmature:addChild(effect2)
    end
end


function ArenaPlayerListLayer:getPlayerItemById(playerId)
    for index,playerItem in pairs(self.playerList) do
      if playerItem.playerId == playerId then
        return playerItem;
      end
    end

    for index,playerItem in pairs(self.topPlayerList) do
      if playerItem.playerId == playerId then
        return playerItem;
      end
    end
    return nil;
end

function ArenaPlayerListLayer.onPlayerItemClickHandle(sender)
    local self = sender.logic;
    self.selectPlayerId = sender.playerId;

    if self.selectPlayerId == MainPlayer:getPlayerId()then
        CardRoleManager:openRoleList()                
    else
        local pageIndex = self.pageView:_getCurPageIndex()
        if pageIndex == 1 then
            ArenaManager:showDetail(self.selectPlayerId,"vs");
        else
            ArenaManager:showDetail(self.selectPlayerId,"show");
        end
    end
    self:setGuideMode(false)
end

function ArenaPlayerListLayer.onDetailAttackClickHandle(sender)
    local self = sender.logic;

    if not MainPlayer:isEnoughTimes(EnumRecoverableResType.QUNHAO,1, true) then
        return ;
    end
    
    local playerId = self.selectPlayerId;
    AlertManager:close(AlertManager.TWEEN_NONE);
    self:attackPlayer(playerId);
end

function ArenaPlayerListLayer.onAttackClickHandle(sender)
    local self = sender.logic;
    local playerId = sender:getTag();
    self:attackPlayer(playerId);
end

function ArenaPlayerListLayer:attackPlayer(playerId)
    ArenaManager:challengePlayer(playerId);
end

function ArenaPlayerListLayer:removeUI()
    self.super.removeUI(self)
end

function ArenaPlayerListLayer:dispose()
    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end
    self.super.dispose(self)
end

function ArenaPlayerListLayer.onRewardClickHandle(sender)
    local self = sender.logic;
    ArenaManager:showRewardList();
end

function ArenaPlayerListLayer.onRefreshClickHandle(sender)
    local self = sender.logic;
    ArenaManager:updatePlayerList();
end

function ArenaPlayerListLayer.onShowClickHandle(sender)
    local self = sender.logic;
    --toastMessage("戴哥，商城靠你了！")
    MallManager:openQunHaoShopHome()
end

function ArenaPlayerListLayer:registerEvents()
    self.super.registerEvents(self);
    -- ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)
    -- self.btn_close:setClickAreaLength(100);
    

    self.btn_reward.logic  = self   
    self.btn_refresh.logic = self
    self.btn_show.logic = self
    self.btn_show.logic = self
    self.btn_report.logic = self

    self.btn_reward:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onRewardClickHandle),1);
    self.btn_refresh:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onRefreshClickHandle),1);
    self.btn_show:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onShowClickHandle),1);
    self.btn_report:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.openReportClickHandle),1);


    self.openEnemyInfolayer = function(event)
        local layer = event.data[1];

        layer:getChangeBtn().logic = self;
        layer:getChangeBtn():addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onDetailAttackClickHandle),1);
    
        local pageIndex = self.pageView:_getCurPageIndex() ;
        if self.selectPlayerId == MainPlayer:getPlayerId() or pageIndex == 2 then
            layer:getChangeBtn():setVisible(false);
            local playerItem = self:getPlayerItemById(self.selectPlayerId);
            layer.txt_rank:setText(playerItem.rank + 1);

            if playerItem.challengeTotalCount == 0 then
                 layer.txt_winRate:setText("0 %");
            else
                 local winRate = (playerItem.challengeWinCount / playerItem.challengeTotalCount) * 100;
                 layer.txt_winRate:setText(math.floor(winRate) .. "%");
            end

        else
            if self.homeInfo == nil then
                return
            end
            layer.txt_rank_self:setText(self.homeInfo.myRank + 1);
            if self.homeInfo.challengeTotalCount == 0 then
                 layer.txt_winRate_self:setText("0 %");
            else
                 local winRate = (self.homeInfo.challengeWinCount / self.homeInfo.challengeTotalCount) * 100;
                 layer.txt_winRate_self:setText(math.floor(winRate) .. "%");
            end


            local playerItem = self:getPlayerItemById(self.selectPlayerId);
            layer.txt_rank_other:setText(playerItem.rank + 1);

            if playerItem.challengeTotalCount == 0 then
                 layer.txt_winRate_other:setText("0 %");
            else
                 local winRate = (playerItem.challengeWinCount / playerItem.challengeTotalCount) * 100;
                 layer.txt_winRate_other:setText(math.floor(winRate) .. "%");
            end

        end

    end;
    TFDirector:addMEGlobalListener("OpenEnemyInfolayerEvent" ,self.openEnemyInfolayer ) ;


    self.updateChallengeTimesCallBack = function(event)
        self:refreshBaseUI();
    end;
    TFDirector:addMEGlobalListener(MainPlayer.ChallengeTimesChange ,self.updateChallengeTimesCallBack ) ;

    self.updateTopPlayerListCallBack = function(event)
        self:loadTopPlayerData(event.data[1]);
    end;
    TFDirector:addMEGlobalListener(ArenaManager.updateTopPlayerList ,self.updateTopPlayerListCallBack ) ;

    self.updatePlayerListCallBack = function(event)
        self:loadPlayerData(event.data[1]);
    end;
    TFDirector:addMEGlobalListener(ArenaManager.updatePlayerList ,self.updatePlayerListCallBack ) ;

    self.updateHomeInfoCallBack = function(event)
        self:loadHomeData(event.data[1]);
    end;
    TFDirector:addMEGlobalListener(ArenaManager.updateHomeInfo ,self.updateHomeInfoCallBack ) ;

    self.updateUserDataCallBack = function(event)
        self:refreshBaseUI();
    end;

    TFDirector:addMEGlobalListener(MainPlayer.CoinChange ,self.updateUserDataCallBack ) ;
    TFDirector:addMEGlobalListener(MainPlayer.SyceeChange ,self.updateUserDataCallBack ) ;

    if self.generalHead then
        self.generalHead:registerEvents()
    end

    self.btn_reset:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onResetButtonClick),1);

    local function refreshWaitTime(delay)
        self:refreshWaitTime(delay)
    end

    if not self.timerRefreshWaitTime then
        self.timerRefreshWaitTime = TFDirector:addTimer(500, -1, nil, refreshWaitTime)
    end
end

--[[
刷新等待时间逻辑
]]
function ArenaPlayerListLayer:refreshWaitTime(delay)
    local challengeInfo = MainPlayer:GetChallengeTimesInfo(EnumRecoverableResType.QUNHAO)
    local waitTimeExpression = challengeInfo:getWaitTimeExpression()
    -- print("ArenaPlayerListLayer:refreshWaitTime() :",waitTimeExpression,challengeInfo)
    if not waitTimeExpression then
        self.bg_reset:setVisible(false)
        return
    end

    local resConfigure = PlayerResConfigure:objectByID(EnumRecoverableResType.QUNHAO)
    local textureIcon = GetResourceIconForGeneralHead(resConfigure.reset_wait_cost_type)
    self.bg_reset:setVisible(true)
    self.txt_wait_time:setText(waitTimeExpression)
    if textureIcon then
        self.img_res_icon:setTexture(textureIcon)
    end
    local price = resConfigure:getResetWaitPrice(challengeInfo.todayResetWait + 1)
    if price then
        self.txt_cost:setText(price)
    else
        self.txt_cost:setText(0)
    end
end

--[[
重置按钮点击回调函数
]]
function ArenaPlayerListLayer.onResetButtonClick(widget)
    local self = widget.logic
    ArenaManager:requestResetWaitTime(EnumRecoverableResType.QUNHAO)
end

function ArenaPlayerListLayer:removeEvents()
    TFDirector:removeMEGlobalListener(MainPlayer.CoinChange ,self.updateUserDataCallBack);
    TFDirector:removeMEGlobalListener(MainPlayer.SyceeChange ,self.updateUserDataCallBack);

    TFDirector:removeMEGlobalListener(MainPlayer.ChallengeTimesChange ,self.updateChallengeTimesCallBack);

    TFDirector:removeMEGlobalListener(ArenaManager.updateTopPlayerList ,self.updateTopPlayerListCallBack);
    TFDirector:removeMEGlobalListener(ArenaManager.updatePlayerList ,self.updatePlayerListCallBack);
    TFDirector:removeMEGlobalListener(ArenaManager.updateHomeInfo ,self.updateHomeInfoCallBack);
    TFDirector:removeMEGlobalListener("OpenEnemyInfolayerEvent" ,self.openEnemyInfolayer);

    if self.generalHead then
        self.generalHead:removeEvents()
    end

    self.btn_reset:addMEListener(TFWIDGET_CLICK)

    if self.timerRefreshWaitTime then
        TFDirector:removeTimer(self.timerRefreshWaitTime)
    end
    self.super.removeEvents(self)
end

function ArenaPlayerListLayer:setGuideMode(bGuide)
    if bGuide then
        if self.guidePanel == nil then
            local guidePanel = TFPanel:create()
            guidePanel:setSize(self.panel_head:getSize())
            guidePanel:setPosition(self.panel_head:getPosition())
            
            guidePanel:setBackGroundColorType(TF_LAYOUT_COLOR_SOLID)
            guidePanel:setBackGroundColorOpacity(80)
            guidePanel:setBackGroundColor(ccc3(0,0,0))
            guidePanel:setZOrder(100)
            guidePanel:setTouchEnabled(true)
            self:addChild(guidePanel)
            self.guidePanel = guidePanel
        end

        self.btn_reward:setTouchEnabled(false)
        self.btn_show:setTouchEnabled(false)
        self.pageView:setScrollEnabled(false)
    else
        if not tolua.isnull(self.guidePanel) then
            self.guidePanel:removeFromParent()
            self.guidePanel = nil
        end
        self.btn_reward:setTouchEnabled(true)
        self.btn_refresh:setTouchEnabled(true)
        self.btn_show:setTouchEnabled(true)
        self.pageView:setScrollEnabled(true)
    end
end

function ArenaPlayerListLayer.openReportClickHandle(sender)
    local self = sender.logic
   
    local layer = AlertManager:addLayerByFile("lua.logic.arena.ArenaFightReport", AlertManager.BLOCK_AND_GRAY, AlertManager.TWEEN_1)

    layer:setArenaData(self.homeInfo)
    AlertManager:show()
end

function ArenaPlayerListLayer.onFSBZClickHandle( sender )
    --quanhuan 2015/12/2
    ZhengbaManager:openArmyLayer(EnumFightStrategyType.StrategyType_AREAN)
end
return ArenaPlayerListLayer;
