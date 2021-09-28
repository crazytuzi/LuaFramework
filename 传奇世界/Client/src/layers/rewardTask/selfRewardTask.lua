-- 新悬赏任务
local selfRewardTask = class( "selfRewardTask" , require( "src/TabViewLayer" ) )  -- 左侧包含任务列表[仅一个]

function selfRewardTask:ctor(parent)
    self.m_taskData = DATA_Mission:GetRewardTaskData() and DATA_Mission:GetRewardTaskData()["hadTask"];
    self.m_viewLayer = nil;

    parent:addChild(self)

    createScale9Frame(
        self,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p( 32 , 38 ),
        cc.size(332,502),
        5
    )
    --createSprite( self , "res/common/bg/bg2.png" , cc.p( 17 + 15 , 18 + 21 ) , cc.p( 0 , 0 ) ) 

    local bg = createScale9Frame(
        self,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p( 370 , 38 ),
        cc.size(558,502),
        5
    )
    --local bg = createSprite( self ,"res/common/bg/bg3.png" , cc.p( 356 + 15 , 18 + 21 ) ,  cc.p( 0 , 0 ) )
    createSprite( bg ,"res/common/bg/bg66-1.jpg" , getCenterPos( bg ) ,  cc.p( 0.5 , 0.5 ) )
    local config = {{  text = "task_reward" , y = 70 } , }
    for i = 1 , #config do
        local titleSp = createSprite( bg , "res/common/bg/titleLine.png" , cc.p(  590/2 - 15 , config[i].y + 115) ,  cc.p( 0.5 , 0 )  )
        createLabel( titleSp , game.getStrByKey( config[i].text )  , getCenterPos( titleSp ), cc.p( 0.5 , 0.5 ) , 22 , nil , nil , nil , MColor.lable_yellow , nil , nil , MColor.black , 2 )
    end
    
    self:createTableView(self , cc.size( 361 - 15 , 470 + 20 ) , cc.p( 10 + 10 , 25 + 21 ) , true , true )
    self:getTableView():setBounceable(true)

    -- 右侧信息
    self.m_viewLayer = cc.Node:create()
    setNodeAttr( self.m_viewLayer , cc.p( 356 , 18 ) , cc.p( 0 , 0 ) )
    self:addChild( self.m_viewLayer )

    self:RefreshRight()

    -- 回调
    DATA_Mission:setCallback("rewardTaskFlag", function(state)
        if state == 1 or state == 0 then -- 放弃/放弃
            if getRunScene():getChildByName("npcChat") then 
                getRunScene():removeChildByName("npcChat")
            end
            DATA_Mission:getParent():remove() 
            DATA_Mission:setParent( nil )
            return;
        end

        self:getTableView():reloadData();
        self:RefreshRight();
    end)
end

function selfRewardTask:clearFun()
    DATA_Mission:setCallback("rewardTaskFlag", nil)
end

function selfRewardTask:gotoTarget( tempData )
    local delayCallback = function()
        DATA_Mission:getParent():remove() 
        DATA_Mission:setParent( nil )
        __TASK:findPath( tempData )
    end

    -- 仅弹出一个NPC面板
    if getRunScene():getChildByName("npcChat") then
        getRunScene():removeChildByName("npcChat")
        startTimerAction(self, 0.35, false, function()
            delayCallback();
        end);
    else
        delayCallback();
    end
end

-- 右侧面板
function selfRewardTask:RefreshRight()
    if self.m_viewLayer.m_timeActiom then
        self.m_viewLayer:stopAction(self.m_viewLayer.m_timeActiom)
        self.m_viewLayer.m_timeActiom = nil
    end

    self.m_viewLayer:removeAllChildren();
      
    if self.m_taskData ~= nil then
        
        --- 拥有任务时，面板
        createLabel( self.m_viewLayer ,  game.getStrByKey( "task_desc" ) , cc.p( 40 , 478 ) , cc.p( 0 , 1 ) , 20 , nil , nil , nil , MColor.brown  )

        local descText = createLabel( self.m_viewLayer ,  self.m_taskData.q_task_desc , cc.p( 40 , 444  ) , cc.p( 0 , 1 ) , 20 , nil , nil , nil , MColor.black  )
        descText:setDimensions(500,0)
        
        -- 专享剩余时间
        if self.m_taskData.guardExpiredTime ~= nil and self.m_taskData.guardExpiredTime > 0 then
            -- 剩余时间
            local function getTimeStr(time)
                return string.format("%02d", ( math.floor(time/60/60)%60) ) .. " : " .. string.format("%02d", ( math.floor(time/60)%60 )) .. " : " .. string.format("%02d", math.floor(time%60));
            end

            local timeLab = createLabel( self.m_viewLayer ,  "" , cc.p( 40 , 370 ) , cc.p( 0 , 1 ) , 20 , nil , nil , nil , MColor.white  );
            
            local function refreshTime()
                if self.m_viewLayer and timeLab then
                    if self.m_taskData.guardExpiredTime > 0 then
                        timeLab:setString(game.getStrByKey("exclusiveTime") .. getTimeStr(self.m_taskData.guardExpiredTime));
                    else
                        -- 已过期，不加定时器
                        timeLab:removeFromParent();
                        timeLab = nil;
                        if self.m_viewLayer.m_timeActiom then
                            self.m_viewLayer:stopAction(self.m_viewLayer.m_timeActiom)
                            self.m_viewLayer.m_timeActiom = nil
                        end
                    end
                end
            end

            self.m_viewLayer.m_timeActiom = startTimerAction(self.m_viewLayer, 1, true, function()
                refreshTime();
            end);
            -- 调用一次刷新时间，防止闪烁
            refreshTime();
        end

        createSprite( self.m_viewLayer ,"res/common/bg/line.png" , cc.p( 34 , 335 ) ,  cc.p( 0 , 0 ) )

        createLabel( self.m_viewLayer ,  game.getStrByKey( "task_target" ) , cc.p( 40 , 328 ) , cc.p( 0 , 1 ) , 20 , nil , nil , nil , MColor.brown  )

        --创建任务目标
        local finishedType = self.m_taskData.finished   --任务进行类型
        local isShowGoBtn = ( finishedType == 2 or finishedType == 3 or finishedType == 6 and true or false )              --是否显示前往按钮

        if self.m_taskData.targetType == 1 then
            createLabel( self.m_viewLayer ,  "【" ..  game.getStrByKey("task_talk")  .. "】", cc.p( 30 , 430 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.brown )
            createLabel( self.m_viewLayer ,  self.m_taskData.targetData.roleName , cc.p( 110 , 430 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.black )
        elseif self.m_taskData.targetType == 2 then
            createLabel( self.m_viewLayer ,  "【" ..  game.getStrByKey("task_collect") .. "】", cc.p( 30 , 275 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.brown )
            local nameText = createLabel( self.m_viewLayer ,  self.m_taskData.targetData.roleName , cc.p( 110 , 275 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.black )
            local tmpColor = MColor.red;
            if self.m_taskData.targetData.cur_num >= self.m_taskData.targetData.count then
                tmpColor = MColor.green;
            end
            createLabel( self.m_viewLayer ,  "(" .. self.m_taskData.targetData.cur_num .. "/" ..  self.m_taskData.targetData.count .. ")" , cc.p( 100 + nameText:getContentSize().width + 20 , 275 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , tmpColor )
        elseif self.m_taskData.targetType == 3 then
            createLabel( self.m_viewLayer ,  "【" ..  game.getStrByKey("task_kill") .. "】" , cc.p( 30 , 275 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.brown )
            local nameText = createLabel( self.m_viewLayer , self.m_taskData.targetData.roleName , cc.p( 110 , 275 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.black )
            local tmpColor = MColor.red;
            if self.m_taskData.targetData.cur_num == self.m_taskData.targetData.count then
                tmpColor = MColor.green;
            end
            createLabel( self.m_viewLayer ,  "(" .. self.m_taskData.targetData.cur_num .. "/" ..  self.m_taskData.targetData.count .. ")" , cc.p( 110 + nameText:getContentSize().width + 20 , 275 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , tmpColor )
        elseif self.m_taskData.targetType == 5 then
            createLabel( self.m_viewLayer ,  "【" ..  game.getStrByKey("taskCollect") .. "】" , cc.p( 30 , 275 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.brown )
            local nameText = createLabel( self.m_viewLayer , self.m_taskData.targetData.roleName , cc.p( 110 , 275 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.black )
            local tmpColor = MColor.red;
            if self.m_taskData.targetData.cur_num >= self.m_taskData.targetData.count then
                tmpColor = MColor.green;
            end
            createLabel( self.m_viewLayer ,  "(" .. self.m_taskData.targetData.cur_num .. "/" ..  self.m_taskData.targetData.count .. ")" , cc.p( 110 + nameText:getContentSize().width + 20 , 275 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , tmpColor )
        end


        local iconGroup = __createAwardGroup( self.m_taskData.awrds )
        setNodeAttr( iconGroup , cc.p( 306 , 130 + 20 ) , cc.p( 0.5 , 0.5 ) )
        self.m_viewLayer:addChild( iconGroup )


        --前往
        local goBtn = createMenuItem( self.m_viewLayer , "res/component/button/39.png" , cc.p( 590/2 - 130 , 60 ) , function()
            self:gotoTarget( self.m_taskData )
        end )
        if finishedType == 6 then
            createLabel( goBtn , game.getStrByKey("taskSubmit")  , getCenterPos(goBtn)  , cc.p( 0.5 , 0.5 ) , 24 , true )
        else
            createLabel( goBtn , game.getStrByKey("go")  , getCenterPos(goBtn)  , cc.p( 0.5 , 0.5 ) , 24 , true )
        end
    
        goBtn:setVisible( isShowGoBtn )

        --放弃
        local giveUpBtn = createMenuItem( self.m_viewLayer , "res/component/button/39.png" , cc.p( 590/2 + 130 , 60 ) , function()
		    MessageBoxYesNo(nil, game.getStrByKey("task_delete_confirm"), function()
			    require("src/layers/mission/MissionNetMsg"):SendRewardTaskReq(6);
		    end)
        end )
        createLabel( giveUpBtn , game.getStrByKey("taskGiveUp")  , getCenterPos(giveUpBtn), cc.p( 0.5 , 0.5 ) , 24 , true )
    
        giveUpBtn:setVisible( isShowGoBtn )
    else

        -- 无任务时面板
        createLabel( self.m_viewLayer , game.getStrByKey("taskGotoNpc") .. game.getStrByKey("taskAcceptNpcTips") , cc.p(590/2 , 325) , cc.p( 0.5, 0.5 ) , 28 , true , 101, nil , MColor.red , nil , nil);

        -- 前往NPC
        local gotoNpcBtn = createMenuItem( self.m_viewLayer , "res/component/button/3.png" , cc.p( 590/2, 50 ) , function()
            local commConst = require("src/config/CommDef");

            local searchNpcData = {};
            searchNpcData.targetType = 1;
            searchNpcData.q_endnpc = commConst.NPC_ID_SHADOW_PAVILION;
            self:gotoTarget(searchNpcData);
        end )
        createLabel( gotoNpcBtn , game.getStrByKey("taskGotoNpc")  , getCenterPos(gotoNpcBtn), cc.p( 0.5 , 0.5 ) , 24 , true )
    end

end


function selfRewardTask:cellSizeForTable(table,idx) 
    return 65 , 361 
end

function selfRewardTask:numberOfCellsInTableView(table)
    return self.m_taskData and 1 or 0;
end

function selfRewardTask:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if cell == nil  then
        cell = cc.TableViewCell:new()
    else
        cell:removeAllChildren()
    end

    local curData = self.m_taskData; -- 仅一个

    -- 2 进行中 6 非自动完成目标完成，但未付
    local stateColor = MColor.yellow;
    local stateStr = "";
    if curData.finished == 2 then
        stateStr = game.getStrByKey( "task_finish2" )
    else
        stateStr = game.getStrByKey( "task_finish3" )
        stateColor = MColor.green;
    end

    local bg = createScale9Sprite( cell , "res/common/scalable/item.png", cc.p( 357/2 , 0 ), cc.size(327 , 61 ) , cc.p( 0.5 , 0 ) )
    local bgSize = bg:getContentSize()
    local tmpColor = cc.c3b(186, 142, 107);
    if curData.q_rank == DATA_Mission.RewardTaskTypeEnum.JUINOR_TASK then
        tmpColor = MColor.green;
    elseif curData.q_rank == DATA_Mission.RewardTaskTypeEnum.SENIOR_TASK then
        tmpColor = MColor.blue;
    else
        tmpColor = MColor.purple;
    end
    createLabel( cell , curData.q_name , cc.p( 40 , bgSize.height/2 ) , cc.p( 0 , 0.5 ) , 20 , nil , 20 , nil , tmpColor , nil , nil )
    createLabel( cell , stateStr , cc.p( 239 , bgSize.height/2 ) , cc.p( 0 , 0.5 ) , 20 , nil , 20 , nil , stateColor[ curData.finished ]  , nil , nil)

    return cell
end

return selfRewardTask