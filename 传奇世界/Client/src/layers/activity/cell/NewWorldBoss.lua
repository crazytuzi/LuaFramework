-- 新世界 BOSS 界面
local NewWorldBoss = class("NewWorldBoss", function() return cc.Layer:create() end);

function NewWorldBoss:ctor()
    
    self.m_bossData = nil;
    self.m_centerSprSize = nil;
    -- 当前选中的boss [0 开始]
    self.m_curSelIndex = 0;
    
    self.m_initCenterPosX = 0;
    self.m_initCenterPosY = 0;
    -- 当前是否正在查看具体卡牌信息
    self.m_isPull = false;

    ----------------------------------------------------------------------------------------------------------------------------------------------------------------------

    self.m_centerSpr = nil;

    ----------------------------------------------------------------------------------------------------------------------------------------------------------------------

    self.m_baseNode = createSprite( self, "res/common/bg/bg18.png", cc.p( display.cx , display.cy ), cc.p( 0.5 , 0.5 ) );
    local bgSize = self.m_baseNode:getContentSize();
    
    local nameLal = createLabel(self.m_baseNode, game.getStrByKey("world_boss"), cc.p(850/2, 529-25),cc.p(0.5, 0.5), 28, true, nil, nil, MColor.lable_yellow, 12580)

    self.m_centerSpr = createScale9Frame(
        self.m_baseNode,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(32, 15),
        cc.size(792,455),
        5
    )
    self.m_centerSprSize = self.m_centerSpr:getContentSize();

    ----------------------------------------------------------------------------------------------------------------------------------------------------------------------

    local bulgeSpr = cc.Sprite:create("res/layers/activity/cell/new_world_boss/5.png");
    bulgeSpr:setAnchorPoint(cc.p(0.5, 0));
    bulgeSpr:setPosition(self.m_centerSprSize.width/2, 120);
    self.m_centerSpr:addChild(bulgeSpr);

    ----------------------------------------------------------------------------------------------------------------------------------------------------------------------

    createLabel( self.m_centerSpr , game.getStrByKey("award") .. ":" , cc.p( 20 , 94  )  , cc.p( 0 , 0 ) , 22 , true , nil , nil , MColor.lable_yellow , nil, nil, MColor.black, 1)

    self.m_bossCardNode = cc.Node:create();
    self.m_centerSpr:addChild(self.m_bossCardNode);

    self.m_detailNode = cc.Node:create();
    self.m_centerSpr:addChild(self.m_detailNode);

    self.m_rewardNode = cc.Node:create();
    self.m_centerSpr:addChild(self.m_rewardNode);

    local gotoBtn = createMenuItem( self.m_centerSpr , "res/component/button/50.png" , cc.p( 706 , 43 ) , function()
        self:GotoBossPos();
    end )
    createLabel( gotoBtn , game.getStrByKey("week_go")  , getCenterPos(gotoBtn) , cc.p( 0.5 , 0.5 ) , 23 , true , nil , nil , MColor.yellow_gray , nil , nil , MColor.black , 3 )
    
    ----------------------------------------------------------------------------------------------------------------------------------------------------------------------

    -- 关闭按钮
    local closeBtn = createMenuItem( self.m_baseNode, "res/component/button/X.png", cc.p(bgSize.width-40, bgSize.height-28), function()
        if self.m_coverflow then
            self.m_coverflow:UnregisterCoverflowEventHandler(cc.Handler.EVENT_COVERFLOW_SELECT);
            self.m_coverflow:UnregisterCoverflowEventHandler(cc.Handler.EVENT_COVERFLOW_START);
        end

        DATA_Activity:RegisterCallback("WorldBossUpdate", nil);

        removeFromParent(self);
    end)

    SwallowTouches(self);

    DATA_Activity:RegisterCallback("WorldBossUpdate", function(luabuffer)
        if self.UpdateByServerData then
            self:UpdateByServerData(luabuffer);
        end
    end);

    self:registerScriptHandler(function(event)
		if event == "enter" then
			g_msgHandlerInst:sendNetDataByTableExEx( ACTIVITY_CS_BOSSREQ , "WorldBossReqProtocol", {} )    --世界Boss数据请求
		elseif event == "exit" then
		    DATA_Activity:RegisterCallback("WorldBossUpdate", nil);
		end
	end)
    
end

function NewWorldBoss:UpdateByServerData(luabuffer)
    if luabuffer == nil then
        return;
    end

    local proto = g_msgHandlerInst:convertBufferToTable( "WorldBossReqRetProtocol" , luabuffer )
    if proto == nil then
        return;
    end

    if proto.bossNum > 0 then
        self.m_bossData = {};
    else
        return;
    end
    local bossInfo = proto.bossInfo;

    for i = 1, #(bossInfo) do
        self.m_bossData[i] = {};                                                   
        
        self.m_bossData[i]["id"] = bossInfo[i].bossID;
        self.m_bossData[i]["state"] = bossInfo[i].bossLive;           -- // 1 is live, 0 is dead
        self.m_bossData[i]["nextTime"] = bossInfo[i].nextLiveTime;    -- boss 下次复活时间(string)
        self.m_bossData[i]["nextState"] = bossInfo[i].isTomorrow;     -- 0表示不是  1表示是 // 0 is today, 1 is Tomorrow
    end

    self:UpdateData()
end

-- 根据玩家等级选择适当的顺序
function NewWorldBoss:SetRightIndex()
    if self.m_bossData == nil then return end

    local lv = MRoleStruct:getAttr(ROLE_LEVEL);
    if lv == nil then return end

    -- 可打的候选表[等级满足]
    local candidateTable = {};
    for i = 1, #self.m_bossData do
        local data = self.m_bossData[i];
        if data ~= nil then
            local configData = getConfigItemByKey("worldBossCfg", "q_mon_id")[data.id];
            if configData then
                if lv >= configData.q_monster_lv then
                    local tmpTable = copyTable(self.m_bossData[i]);
                    -- 原始表中的 index
                    tmpTable.realIdx = i;
                    table.insert(candidateTable, tmpTable);
                end
            end
        end
    end

    -- 已经刷新表
    local refreshTable = {};
    for i = 1, #candidateTable do
        if candidateTable[i].state == 1 then
            table.insert(refreshTable, candidateTable[i]);
        end
    end

    -- 在刷新表中查找等级最接近的一个[按照排序规则，默认表最后一个]
    if #refreshTable > 0 then
        self.m_curSelIndex = (refreshTable[#refreshTable].realIdx - 1);
    else
        -- 没有可打的，忽略以上规则，直接取最接近的一个
        if #candidateTable > 0 then
            self.m_curSelIndex = (candidateTable[#candidateTable].realIdx - 1);
        else
            -- 等级不够，直接第一个
            self.m_curSelIndex = 0;
        end
    end
end

function NewWorldBoss:UpdateData()
    if self.m_bossData == nil then
        return;
    end

    self:Clear();

    self:SetRightIndex();
    
    self.m_coverflow = CCoverflow:Create(cc.rect(0, 0, self.m_centerSprSize.width, self.m_centerSprSize.height-110), cc.size(self.m_centerSprSize.width*3, self.m_centerSprSize.height-110), 160, 0.1);
    self.m_coverflow:setAnchorPoint(cc.p(0, 0));
    self.m_coverflow:setPosition(cc.p(0, 120));
    self.m_bossCardNode:addChild(self.m_coverflow);

    for i=1, #self.m_bossData do
        local bossNode = self:FormatOneBoss(i);
        self.m_coverflow:AddCard(bossNode, 1, i);
    end

    self.m_coverflow:setIsHorizontal(true);
    self.m_coverflow:StartMiddleIndex(self.m_curSelIndex);
    self.m_coverflow:RegisterCoverflowEventHandler(function(card, selIndex)
        print("EVENT_COVERFLOW_SELECT (END). selIndex=[" .. selIndex .. "]");
        self.m_curSelIndex = selIndex;
        if card then
            print("card index = ", card:getTag());
        end
        self:FormatBossReward();
    end, cc.Handler.EVENT_COVERFLOW_SELECT);
    self.m_coverflow:RegisterCoverflowEventHandler(function()
        print("EVENT_COVERFLOW_START");
    end, cc.Handler.EVENT_COVERFLOW_START);

    self.m_isPull = false;
    self.m_coverflow:setResponseTouch(true);

    self:FormatBossReward();
end

function NewWorldBoss:FormatOneBoss(index)
    -- 
    if self.m_bossData == nil then return nil end

    local data = self.m_bossData[index];
    if data == nil then return nil end

    local configData = getConfigItemByKey("worldBossCfg", "q_mon_id")[data.id];
    if configData == nil then return nil end
    
    local lightSpr = cc.Sprite:create("res/layers/activity/cell/new_world_boss/7.png");
    lightSpr:setAnchorPoint(cc.p(0.5, 0.5));
    local lightSprSize = lightSpr:getContentSize();

    local bossImg = cc.Sprite:create("res/layers/activity/cell/new_world_boss/" .. configData.q_monster_id .. ".jpg");
    bossImg:setAnchorPoint(cc.p(0, 0));
    bossImg:setPosition(cc.p(19.5, 28));
    lightSpr:addChild(bossImg);

    ----------------------------------------------------------------------------------------------------------------------------------------------------------------------

    -- 刷新时间
    if data.state == 1 then
        local refreshStr = game.getStrByKey( "fieldboss_fresh" )

        local hadRefreshSpr = cc.Sprite:create("res/layers/activity/cell/new_world_boss/1.png");
        local hadRefreshSprSize = hadRefreshSpr:getContentSize();
        hadRefreshSpr:setAnchorPoint(cc.p(0.5, 0));
        hadRefreshSpr:setPosition(lightSprSize.width/2, 280);
        lightSpr:addChild(hadRefreshSpr);

        createLabel( hadRefreshSpr , refreshStr , cc.p( hadRefreshSprSize.width/2 , 15  )  , cc.p( 0.5 , 0 ) , 20 , true , nil , nil , MColor.green , nil, nil, MColor.yellow, 1)
    else
        local refreshStr = data.nextTime
        if data.nextState == 1 then
            refreshStr = game.getStrByKey( "tomorrow2" ) .. refreshStr
        end
        refreshStr = refreshStr .. game.getStrByKey("refresh");

        local willRefreshSpr = cc.Sprite:create("res/layers/activity/cell/new_world_boss/2.png");
        local willRefreshSprSize = willRefreshSpr:getContentSize();
        willRefreshSpr:setAnchorPoint(cc.p(0.5, 0));
        willRefreshSpr:setPosition(lightSprSize.width/2, 280);
        lightSpr:addChild(willRefreshSpr);

        createLabel( willRefreshSpr , refreshStr , cc.p( willRefreshSprSize.width/2 , 15  )  , cc.p( 0.5 , 0 ) , 20 , true , nil , nil , MColor.white , nil, nil, MColor.brown, 1)
    end

    ----------------------------------------------------------------------------------------------------------------------------------------------------------------------

    -- 刷新地图
    if data.state == 1 then
        local refreshMapSpr = cc.Sprite:create("res/layers/activity/cell/new_world_boss/3.png");
        local refreshMapSprSize = refreshMapSpr:getContentSize();
        refreshMapSpr:setAnchorPoint(cc.p(0.5, 0));
        refreshMapSpr:setPosition(cc.p(lightSprSize.width/2, 34));
        lightSpr:addChild(refreshMapSpr);

        createLabel( refreshMapSpr , configData.cxdd , cc.p( refreshMapSprSize.width/2 , 5  )  , cc.p( 0.5 , 0 ) , 20 , true , nil , nil , MColor.yellow , nil, nil, MColor.black, 1);
    end

    ----------------------------------------------------------------------------------------------------------------------------------------------------------------------

    -- 名字框
    local nameBgSpr = cc.Sprite:create("res/layers/activity/cell/new_world_boss/4.png");
    nameBgSpr:setAnchorPoint(cc.p(0.5, 0));
    nameBgSpr:setPosition(cc.p(lightSprSize.width/2, 0));
    lightSpr:addChild(nameBgSpr);

    -- function createLabel(parent, sContent,pos, anchor, fontSize, isOutLine, izorder, fontName, fontColor, tag, specificWidth, outLineColor, outLineWidth)
    createLabel( nameBgSpr , "Lv." .. configData.q_monster_lv , cc.p( 60 , 5  )  , cc.p( 0 , 0 ) , 20 , true , nil , nil , MColor.white , nil, nil, MColor.black, 1)
    createLabel( nameBgSpr , configData.gwmz , cc.p( 125 , 5  )  , cc.p( 0 , 0 ) , 20 , true , nil , nil , MColor.yellow , nil, nil, MColor.white, 1)

    ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
    local layerColor = cc.LayerColor:create(cc.c4b(0, 0, 0, 255), 216, 298);
    layerColor:setPosition(19.5, 28);
    layerColor:setTag(2000);
    lightSpr:addChild(layerColor);
    ----------------------------------------------------------------------------------------------------------------------------------------------------------------------

    local isOneClick = false;
    
    local isInMove = false;
    --[[
    local isIntouch = false;
    -- 双击判定 < 250 ms
    local lastTouchTime = 0;
    local function isDoubleTouch()
        local thisTouchTime = cc.utils:getTimeInMilliseconds();
        if math.abs(thisTouchTime - lastTouchTime) < 250 then
            lastTouchTime = 0;
            return true;
        else
            lastTouchTime = cc.utils:getTimeInMilliseconds();
            return false;
        end
    end
    
    local function checkLongPress()
        if lightSpr == nil then return end

        if tolua.cast(lightSpr, "cc.Sprite") == nil then
            if lightSpr.schedule then
                if tolua.cast(lightSpr.schedule, "cc.Action") then
                    lightSpr:stopAction(lightSpr.schedule);
                end
            end
            lightSpr.schedule = nil;
            return
        end

        if lightSpr.schedule then
            if tolua.cast(lightSpr.schedule, "cc.Action") then
                lightSpr:stopAction(lightSpr.schedule);
            end
            lightSpr.schedule = nil;
        end

        if isIntouch and not isInMove then
            self:PullDrawer();
        else
            self:PullDrawer();
        end
    end

    local function onTouchBegan(touch, event)
        -- 返回当前触摸位置在 OpenGL 坐标		                  
        local pt = touch:getLocation();
        -- 将世界坐标转换为当前父view的本地坐标系
		pt = lightSpr:getParent():convertToNodeSpace(pt);
        local rectOrigin = lightSpr:getBoundingBox()
        if cc.rectContainsPoint(rectOrigin,pt) then
            isIntouch = true;

            if isDoubleTouch() then
                print("isDoubleTouch");
            else
                lightSpr.schedule = startTimerAction(lightSpr, 2, true, function()
                    checkLongPress();
                end)
            end

            return true;
        end

        return false;
    end

    local function onTouchMoved(touch, event)
	    local pt = touch:getLocation()
        pt = lightSpr:getParent():convertToNodeSpace(pt)
        local rectOrigin = lightSpr:getBoundingBox()
        if cc.rectContainsPoint(rectOrigin, pt) then
            local deltaPoint = touch:getDelta();
            if deltaPoint then
                if math.abs(deltaPoint.x) > 1 or math.abs(deltaPoint.y) > 1 then
                    isInMove = true;
                end
            end
        end
    end

    local function onTouchEnded(touch, event)
        if lightSpr == nil then return end

        if tolua.cast(lightSpr, "cc.Sprite") == nil then
            if lightSpr.schedule then
                if tolua.cast(lightSpr, "cc.Action") then
                    lightSpr:stopAction(lightSpr.schedule);
                end
            end
            lightSpr.schedule = nil;
            return
        end

        if lightSpr.schedule then
            if tolua.cast(lightSpr.schedule, "cc.Action") then
                lightSpr:stopAction(lightSpr.schedule);
            end
            lightSpr.schedule = nil;
        end

        local pt = touch:getLocation()
        pt = lightSpr:getParent():convertToNodeSpace(pt)
        local rectOrigin = lightSpr:getBoundingBox()
        if cc.rectContainsPoint(rectOrigin, pt) then
            isIntouch = false;
            isInMove = false;
            self:PullDrawer();
        end
    end
    ]]

    local function onTouchBegan(touch, event)
        if lightSpr == nil then return false end

        -- 返回当前触摸位置在 OpenGL 坐标		                  
        local pt = touch:getLocation();
        -- 将世界坐标转换为当前父view的本地坐标系
		pt = lightSpr:getParent():convertToNodeSpace(pt);
        local rectOrigin = lightSpr:getBoundingBox()
        if cc.rectContainsPoint(rectOrigin,pt) then
            isInMove = false;
            return true;
        end

        return false;
    end

    local function onTouchMoved(touch, event)
        if lightSpr == nil then return end

	    local pt = touch:getLocation()
        pt = lightSpr:getParent():convertToNodeSpace(pt)
        local rectOrigin = lightSpr:getBoundingBox()
        if cc.rectContainsPoint(rectOrigin, pt) then
            local deltaPoint = touch:getDelta();
            if deltaPoint then
                if math.abs(deltaPoint.x) > 0 or math.abs(deltaPoint.y) > 0 then
                    isInMove = true;
                end
            end
        end
    end

    local function onTouchEnded(touch, event)
        if lightSpr == nil then return end

        local pt = touch:getLocation()
        pt = lightSpr:getParent():convertToNodeSpace(pt)
        local rectOrigin = lightSpr:getBoundingBox()
        if cc.rectContainsPoint(rectOrigin, pt) then

            if not isInMove then
                local iTmpTag = lightSpr:getTag();
                -- 必须是当前居中的选中项
                if self.m_curSelIndex+1 == iTmpTag then
                    isOneClick = not isOneClick;
                    self:PullDrawer();
                end
            end
            
            isInMove = false;
        end
    end

    local listener1 = cc.EventListenerTouchOneByOne:create()
    --listener1:setSwallowTouches(true)
    listener1:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener1:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener1:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener1, lightSpr)

    return lightSpr;
end

-- 控制 是否显示 描述信息
function NewWorldBoss:PullDrawer()
    --[[
    ----------------------------------------------------------------------------------
    local function actionEndFun()
	    if node and node.remove then node:remove()  end
	    if endFun then endFun() end 
	    --if isMain then TextureCache:removeUnusedTextures() end
    end
    cc.Sequence:create( { cc.EaseBackOut:create( cc.Spawn:create( { cc.MoveTo:create(0.3 , cc.p( display.cx , display.height + 100 ) )  , cc.ScaleTo:create(0.3, 0.3) } ) ) , cc.CallFunc:create( actionEndFun ) } ) 

    ----------------------------------------------------------------------------------
    -- 把牌反转
    frontCard:setFlippedX(true);

    -- 动画序列(延时、隐藏、延时、隐藏)
    local backSeq = cc.Sequence:create(cc.DelayTime:create(0.5), cc.Hide:create(), cc.DelayTime:create(0.5));
    local scaleBack = cc.ScaleTo:create(1.2, -1, 1);
    local spawnBack = cc.Spawn:create({backSeq, scaleBack});
    backCard:runAction(spawnBack);

    -- 动画序列(延时、显示、延时、显示)
    local frontSeq = cc.Sequence:create(cc.DelayTime:create(0.5), cc.Show:create(), cc.DelayTime:create(0.5));
    local scaleFront = cc.ScaleTo:create(1.2, -1, 1);
    local spawnFront = cc.Spawn:create({frontSeq, scaleFront});
    frontCard:runAction(spawnFront);
    ]]

    self.m_isPull = true;
    self.m_coverflow:setResponseTouch(false);

    if self.m_cardDetailNode then
        self.m_cardDetailNode:removeFromParent();
        self.m_cardDetailNode = nil;
    end

    self.m_cardDetailNode = cc.Node:create();
    self.m_cardDetailNode:setContentSize(cc.size(792,455));
    self.m_detailNode:addChild(self.m_cardDetailNode);

    local curCard = self.m_coverflow:GetCardByIndex(self.m_curSelIndex);
    if curCard == nil then return end
        
    if self.m_bossData == nil then return end

    if self.m_curSelIndex < 0 or self.m_curSelIndex >= #(self.m_bossData) then
        return
    end

    local data = self.m_bossData[self.m_curSelIndex+1];
    if data == nil then return end

    local configData = getConfigItemByKey("worldBossCfg", "q_mon_id")[data.id];
    if configData == nil then return end

    local clipNode = cc.ClippingNode:create();
    clipNode:setTag(9);

    -- 设置底板
    local detailTextSpr = cc.Sprite:create("res/layers/activity/cell/new_world_boss/bg.jpg");
    detailTextSpr:setPosition(cc.p(481, 285));
    detailTextSpr:setTag(11);
    clipNode:addChild(detailTextSpr);

    -- 设置模板 stencil
    local stencilSpr = cc.Sprite:create("res/layers/activity/cell/new_world_boss/bg.jpg");
    stencilSpr:setPosition(cc.p(481, 285));

    stencilSpr:runAction(cc.MoveTo:create(0.2, cc.p(481+475, 285)));
         
    clipNode:setStencil(stencilSpr)
    clipNode:setInverted(true)
    clipNode:setAlphaThreshold(0)
    self.m_cardDetailNode:addChild(clipNode);

    ----------------------------------------------------------------------------------------------------------------------------------------------------------------------
    -- boss 描述
    createLabel(detailTextSpr, game.getStrByKey("new_world_boss_desc"), cc.p(18, 245), cc.p(0, 0), 22, true, nil, nil, cc.c3b(104, 64, 29), nil, 202, MColor.black, 1);

    local width , height  = 237 , 225
    local function createRichTextNode()
        local tempNode = cc.Node:create()

        local cyjlDesc = createLabel( tempNode , configData.cyjl  , cc.p( 10 , 0 )  , cc.p( 0 , 0 ) , 18 , nil , nil , nil , cc.c3b(103, 65, 34) , nil, width-20)
        local cyjlDescSize = cyjlDesc:getContentSize();

        tempNode:setContentSize( cc.size( width , cyjlDescSize.height + 5 ) )

        return tempNode;
    end
    
    local scrollView1 = cc.ScrollView:create()	  
    scrollView1:setViewSize(cc.size( width  , height ) )--设置可视区域比文字区域大，防止字库导致字体大小不一致的显示问题
    scrollView1:setPosition( cc.p( 5 , 12  ) )
    scrollView1:setScale(1.0)
    scrollView1:ignoreAnchorPointForPosition(true)
    local richNode = createRichTextNode()
    scrollView1:setContainer( richNode )
    scrollView1:updateInset()
    scrollView1:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL )
    scrollView1:setClippingToBounds(true)
    scrollView1:setBounceable(true)
    scrollView1:setDelegate()
    scrollView1:setContentOffset(cc.p(scrollView1:getContentOffset().x, scrollView1:getViewSize().height - scrollView1:getContentSize().height))
    detailTextSpr:addChild(scrollView1)

    -- boss 故事背景
    createLabel(detailTextSpr, configData.gwmz .. game.getStrByKey("new_world_boss_backdrop"), cc.p(255, 245), cc.p(0, 0), 22, true, nil, nil, cc.c3b(104, 64, 29), nil, 202, MColor.black, 1);

    local width , height  = 237 , 225
    local function createRichTextNode()
        local tempNode = cc.Node:create()
            
        local bsjsDesc = createLabel( tempNode , configData.bsjs , cc.p( 10 , 0  )  , cc.p( 0 , 0 ) , 18 , nil , nil , nil , cc.c3b(103, 65, 34) , nil, width-20)
        local bsjsDescSize = bsjsDesc:getContentSize();

        tempNode:setContentSize( cc.size( width , bsjsDescSize.height + 5 ) )

        return tempNode;
    end
    
    local scrollView2 = cc.ScrollView:create()	  
    scrollView2:setViewSize(cc.size( width  , height ) )--设置可视区域比文字区域大，防止字库导致字体大小不一致的显示问题
    scrollView2:setPosition( cc.p( 237+5 , 12  ) )
    scrollView2:setScale(1.0)
    scrollView2:ignoreAnchorPointForPosition(true)
    local richNode = createRichTextNode()
    scrollView2:setContainer( richNode )
    scrollView2:updateInset()
    scrollView2:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL )
    scrollView2:setClippingToBounds(true)
    scrollView2:setBounceable(true)
    scrollView2:setDelegate()
    scrollView2:setContentOffset(cc.p(scrollView2:getContentOffset().x, scrollView2:getViewSize().height - scrollView2:getContentSize().height))
    detailTextSpr:addChild(scrollView2)

    ----------------------------------------------------------------------------------------------------------------------------------------------------------------------

    local bossSpr = cc.Sprite:create("res/layers/activity/cell/new_world_boss/" .. configData.q_monster_id .. ".jpg");
    bossSpr:setAnchorPoint(cc.p(0, 0));
    bossSpr:setPosition(cc.p(22, 130));
    bossSpr:setScale(1.04);
    bossSpr:setTag(10);
    bossSpr:setOpacity(0);
    self.m_cardDetailNode:addChild(bossSpr);
        
    local bossSprSeq = cc.Sequence:create(cc.FadeTo:create(0.2, 255));
    bossSpr:runAction(bossSprSeq);
    
    local turnonBtn = nil;
    local function turnOnFunc()
        local function actionFun()
            if self.m_cardDetailNode then
                self.m_cardDetailNode:removeFromParent();
                self.m_cardDetailNode = nil;
            end

            self.m_isPull = false;
            self.m_coverflow:setResponseTouch(true);
        end

        if self.m_cardDetailNode == nil then
            actionFun();
            return;
        end

        bossSpr:runAction(cc.FadeTo:create(0.2, 0));

        stencilSpr:runAction(cc.MoveTo:create(0.2, cc.p(481, 285)));

        local turnOnSeq = cc.Sequence:create(cc.MoveTo:create(0.2, cc.p(740-475, 285)), cc.CallFunc:create( actionFun ));
        turnonBtn:runAction(turnOnSeq);
    end
    turnonBtn = createMenuItem(self.m_cardDetailNode, "res/layers/activity/cell/new_world_boss/you.jpg", cc.p(740-475, 285), function()
        turnOnFunc();
    end);
    turnonBtn:setTag(12);
    createLabel(turnonBtn, game.getStrByKey("new_world_boss_tips"), getCenterPos(turnonBtn, 6), cc.p(0.5, 0.5), 20, true, nil, nil, MColor.lable_yellow, nil, 38, MColor.black, 1);

    turnonBtn:runAction(cc.MoveTo:create(0.2, cc.p(740, 285)));

    --------------------------------------------------------------------------------------------
    local isNoMove = true;
    local listener = cc.EventListenerTouchOneByOne:create();
    listener:setSwallowTouches(true);
    listener:registerScriptHandler(function(touch, event)
            if touch and event and self.m_cardDetailNode then
                 -- 父节点转换
                local pt = self.m_cardDetailNode:getParent():convertTouchToNodeSpace(touch);
                local touchRect = cc.rect(22, 128, 740, 310)
                if cc.rectContainsPoint(touchRect, pt) then
                    isNoMove = true;
                    return true;
                end
            end
        end, cc.Handler.EVENT_TOUCH_BEGAN);
    listener:registerScriptHandler(function(touch, event)
            if touch and event and self.m_cardDetailNode then
                -- 父节点转换
                local pt = self.m_cardDetailNode:getParent():convertTouchToNodeSpace(touch);
                local touchRect = cc.rect(22, 128, 740, 310)
                if cc.rectContainsPoint(touchRect, pt) then
                    local deltaPoint = touch:getDelta();
                    if math.abs(deltaPoint.x) > 0 or math.abs(deltaPoint.y) > 0 then
                        if isNoMove then isNoMove = false end
                    end
                else
                    if isNoMove then isNoMove = false end
                end
            end
        end,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(function(touch, event)
            if touch and event and self.m_cardDetailNode then
                -- 父节点转换
                local pt = self.m_cardDetailNode:getParent():convertTouchToNodeSpace(touch);
                local touchRect = cc.rect(22, 128, 740, 310)
                if cc.rectContainsPoint(touchRect, pt) and isNoMove then
                    turnOnFunc();
                end
            end
        end, cc.Handler.EVENT_TOUCH_ENDED);
    local eventDispatcher = self.m_cardDetailNode:getEventDispatcher();
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.m_cardDetailNode);
    --------------------------------------------------------------------------------------------
end

function NewWorldBoss:Clear()
    if self.m_coverflow then
        self.m_coverflow:removeFromParent();
        self.m_coverflow = nil;
    end
    
    if self.m_cardDetailNode then
        self.m_cardDetailNode:removeFromParent();
        self.m_cardDetailNode = nil;
    end
end

function NewWorldBoss:GotoBossPos()
    if self.m_bossData == nil then return end

    if self.m_curSelIndex < 0 or self.m_curSelIndex >= #(self.m_bossData) then
        return
    end

    local data = self.m_bossData[self.m_curSelIndex+1];
    if data == nil then return end

    local configData = getConfigItemByKey("worldBossCfg", "q_mon_id")[data.id];
    if configData == nil then return end

    local map_item = getConfigItemByKey( "monsterUpdate" , "q_id" , configData.q_monster_id );

    -- 不需要单独配置 后台禁飞地图设置生效就可以了
    if configData.addr_info then
        local tagInfo = stringsplit( configData.addr_info , "_" )
        map_item = { q_mapid = tonumber(tagInfo[1]) , q_center_x = tonumber(tagInfo[2]) ,  q_center_y = tonumber(tagInfo[3]) }
    end

    if map_item == nil then return end

	local function chechConditions()
		local isRefuse = false
		local mapInfoItem = getConfigItemByKey( "MapInfo" , "q_map_id" , map_item.q_mapid ) 

		--地图等级限制判断
        if mapInfoItem then
    		if not isRefuse and ( MRoleStruct:getAttr(ROLE_LEVEL) < tonumber( mapInfoItem.q_map_min_level ) )  then
    			local msg_item = getConfigItemByKeys( "clientmsg" , { "sth" , "mid" } , { 21000 , -1 } )
    			local msgStr = string.format( msg_item.msg , tostring( mapInfoItem.q_map_min_level  ) )
    			TIPS( { type = msg_item.tswz , flag = msg_item.flag , str = msgStr } )
    			isRefuse = true
    			return isRefuse
    		end
        end

		return isRefuse
	end


	if chechConditions() then return end
    
    local tempData = { targetType = 4 , mapID =  map_item.q_mapid ,  x = map_item.q_center_x  , y = map_item.q_center_y  }
    if __TASK then
        __TASK:findPath( tempData )
    end

	__removeAllLayers()
end

function NewWorldBoss:FormatBossReward()
    if self.m_bossData == nil then return end

    if self.m_curSelIndex < 0 or self.m_curSelIndex >= #(self.m_bossData) then
        return
    end

    local data = self.m_bossData[self.m_curSelIndex+1];
    if data == nil then return end

    local configData = getConfigItemByKey("worldBossCfg", "q_mon_id")[data.id];
    if configData == nil then return end

    self.m_rewardNode:removeAllChildren();

    -- 奖励
    local awards = {}
    local DropOp = require("src/config/DropAwardOp")
    local awardsConfig = DropOp:getItemBySexAndSchool(configData.q_drop_id);
    if awardsConfig and tablenums(awardsConfig) >0 then
        table.sort( awardsConfig , function(a, b)
            if a == nil or a.px == nil or b == nil or b.px == nil then
                return false;
            else
                return a.px > b.px;
            end
        end)
    end
    for i=1, #awardsConfig do
        awards[i] =
        { 
            id = awardsConfig[i]["q_item"] ,       -- 奖励ID
            num = awardsConfig[i]["q_count"]   ,    -- 奖励个数
            streng = awardsConfig[i]["q_strength"] ,   -- 强化等级
            quality = awardsConfig[i]["q_quality"] ,   -- 品质等级
            upStar = awardsConfig[i]["q_star"] ,     -- 升星等级
            time = awardsConfig[i]["q_time"] ,     -- 限时时间
            showBind = true,
            isBind = tonumber(awardsConfig[i]["bdlx"] or 0) == 1,                          
        }
    end

    if tablenums( awards ) > 0 then
        --function __createAwardGroup( awards , isShowName , Interval , offX , isSwallow )
        local groupAwards =  __createAwardGroup( awards , nil , 85 , nil , false)
        setNodeAttr( groupAwards , cc.p( 4, -20 ) , cc.p( 0 , 0 ) )

        local scrollView = cc.ScrollView:create();
        scrollView:setViewSize(cc.size(621, 90));
        scrollView:setPosition(cc.p(0, 0));
        scrollView:ignoreAnchorPointForPosition(true);
        scrollView:setContainer(groupAwards);
        scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL);
        scrollView:setClippingToBounds(true);
        scrollView:setBounceable(true);
        scrollView:setDelegate();
        scrollView:updateInset();
        --scrollView:setContentOffset(cc.p(scrollView:getViewSize().width - scrollView:getContentSize().width, scrollView:getContentOffset().y));

        self.m_rewardNode:addChild(scrollView);
    end
end

return NewWorldBoss;