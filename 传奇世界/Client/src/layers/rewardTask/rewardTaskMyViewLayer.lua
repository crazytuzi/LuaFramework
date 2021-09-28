local rewardTaskMyViewLayer = class("rewardTaskMyViewLayer", require( "src/TabViewLayer" ))

function rewardTaskMyViewLayer:ctor()
    -- 数据初始化
    self.m_curTaskData = nil;

    -- 控件初始化
    self.m_publishBlueBtn = nil;
    self.m_publishPurpleBtn = nil;
    self.m_publishExtremeBtn = nil;

    -- 控件初始化
    self.m_noTaskPublishLal = nil;

    
    local insideBg = createScale9Frame(
        self,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(15, 95),
        cc.size(900,426),
        5
    )
    --createSprite(self, "res/common/bg/bg46.png", cc.p(930/2, 535/2 + 35));
    local title_bg = CreateListTitle(insideBg, cc.p(4, 380), 891, 43, cc.p(0, 0))

    -- function createLabel(parent, sContent,pos, anchor, fontSize, isOutLine, izorder, fontName, fontColor, tag, specificWidth, outLineColor, outLineWidth)
    createLabel( title_bg , game.getStrByKey("taskName") , cc.p( 30, 8 ) , cc.p( 0, 0 ) , 22 , true , nil , nil , cc.c3b(247, 206, 150) , nil , nil);
    createLabel( title_bg , game.getStrByKey("taskRewards") , cc.p( 320, 8 ) , cc.p( 0, 0 ) , 22 , true , nil , nil , cc.c3b(247, 206, 150) , nil , nil);
    
    createLabel( title_bg , game.getStrByKey("taskDeadline") , cc.p( 603, 8 ) , cc.p( 0, 0 ) , 22 , true , nil , nil , cc.c3b(247, 206, 150) , nil , nil);
    ---------------------------------------------------------------------------------

    -- function TabViewLayer:createTableView(parent,size,pos,t_type)
    self:createTableView(insideBg , cc.size( 888, 364 ) , cc.p( 5 , 6 ) , true , true);

    self.m_noTaskPublishLal = createLabel(
        insideBg
        , game.getStrByKey("taskNoPublish")
        , cc.p(insideBg:getContentSize().width / 2, insideBg:getContentSize().height / 2)
        , cc.p(0.5, 0.5)
        , 28
        , true
        , 101
        , nil
        , MColor.red
    );
    self.m_noTaskPublishLal:setVisible(false);

    ---------------------------------------------------------------------------------
    
    self.m_rightTipsCommNode = cc.Node:create();
    setNodeAttr(self.m_rightTipsCommNode, cc.p( 76, 35 ), cc.p( 0 , 0 ));
    self:addChild(self.m_rightTipsCommNode);

    ---------------------------------------------------------------------------------

    local releaseTask_btn = createMenuItem(self, "res/component/button/38.png", cc.p(709 + 188 / 2 + 2, 21 + 24 + 5 - 2) , function()
        local node_dialog = require("src/layers/rewardTask/rewardTaskReleaseDialog").new()
        node_dialog:setTag(require("src/config/CommDef").TAG_REWARD_TASK_DIALOG)
        node_dialog:setPosition(g_scrCenter)
		SwallowTouches(node_dialog)
        getRunScene():addChild(node_dialog, 200)--当前层zOrder = 200
    end)
    createLabel(releaseTask_btn, game.getStrByKey("releaseTask"), getCenterPos(releaseTask_btn), cc.p(0.5, 0.5), 22, false, nil, nil, cc.c3b(247, 205, 147))

    self:RefreshData();

    __createHelp({parent = self, str = require("src/config/PromptOp"):content(56) , pos = cc.p( 42  , 50 ) })
end

-- 数据回调刷新
function rewardTaskMyViewLayer:RefreshData()
    -- 自己接取的任务
    self.m_curTaskData = DATA_Mission:GetRewardTaskData() and DATA_Mission:GetRewardTaskData()["listData"];
    -- 刷新数据时, 排序: 可领取奖励的排最前，然后按高级到低级
    local sortFunc = function(a , b )
        if a.status == 1 and b.status == 1 then -- a, b都完成了
            -- 1 普通 2 高级
            return a.q_rank > b.q_rank;
        elseif a.status == 1 and b.status ~= 1 then -- a完成 b 未完成
            return true;
        elseif a.status ~= 1 and b.status == 1 then -- a未完成 b 完成
            return false;
        elseif a.status ~= 1 and b.status ~= 1 then -- a,b都未完成
            if a.expiretime <= 0 and b.expiretime <= 0 then    -- a,b都过期
                return a.q_rank > b.q_rank;
            elseif a.expiretime <= 0 and b.expiretime > 0 then    -- a 过期 b 未过期
                return true;
            elseif a.expiretime > 0 and  b.expiretime <= 0 then   -- a 未过期 b 过期
                return false;
            else    -- a.b 未过期
                return a.q_rank > b.q_rank;
            end
        else
            return true;    -- 默认排序正常
        end
	end
    -- 排序函数有两个参数并且如果在array中排序后第一个参数在第二个参数前面，排序函数必须返回true。
    -- 如果未提供排序函数，sort使用默认的小于操作符进行比较。
    if self.m_curTaskData ~= nil and #self.m_curTaskData > 0 then
	    table.sort(self.m_curTaskData, sortFunc )
    end

    -- 必须在rewardTaskMyViewLayer 创建自属的tableview后才能调
    self:getTableView():reloadData();

    self:RefreshSelfTips();

    self:RefreshRemind();
end

function rewardTaskMyViewLayer:RefreshSelfTips()
    local rewardTasks = DATA_Mission:GetRewardTaskData();
    
    local publishNum = rewardTasks and rewardTasks.publishLeftNum or 0;

    self.m_rightTipsCommNode:removeAllChildren();

    local rightRichText1 = require("src/RichText").new( self.m_rightTipsCommNode , cc.p( 0, 0 ) , cc.size( 500 , 0 ) , cc.p( 0 , 0 ) , 24 , 22 , MColor.white )
    rightRichText1:setAutoWidth();
    local rightStr1 = "^c(lable_yellow)" .. game.getStrByKey("taskJuinorBounty") .. game.getStrByKey("taskAnd") .. game.getStrByKey("taskSeniorBounty") ..
                    game.getStrByKey("taskStillCan") .. game.getStrByKey("taskPublish") .. "^" .. publishNum .. "^c(lable_yellow)" .. game.getStrByKey("baby_material_number") .. "^";
    rightRichText1:addText(rightStr1)
	rightRichText1:format();
end

function rewardTaskMyViewLayer:RefreshRemind()
    if self.m_curTaskData ~= nil then
        if #self.m_curTaskData > 0 then
            self.m_noTaskPublishLal:setVisible(false);
        else
            self.m_noTaskPublishLal:setVisible(true);
        end
    else
        self.m_noTaskPublishLal:setVisible(false);
    end
end

function rewardTaskMyViewLayer:cellSizeForTable(table,idx) 
    return 100 , 888;
end

function rewardTaskMyViewLayer:numberOfCellsInTableView(table)
    if self.m_curTaskData ~= nil then
        return tablenums(self.m_curTaskData)
    end
    
    return 0;
end

-- 创建的cell数量 = tableview的高度 / 单个 cell 的高度 + 1
-- 一个物理cell 可能映射N 个逻辑 cell
function rewardTaskMyViewLayer:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell();

    if not cell then
        cell = cc.TableViewCell:new();
    else
        cell:removeAllChildren();
    end

    if (self.m_curTaskData == nil) then
        return cell;
    end
    
    local tmpTable = self.m_curTaskData[idx+1];
    -- 防止错误的数据
    if (tmpTable == nil or tmpTable.awrds == nil or tmpTable.q_name == nil) then
        return cell;
    end

    local cellBg = createSprite( cell , "res/common/table/cell22.png" , cc.p( 0 , 0 ) , cc.p( 0 , 0 ) );
    local tmpColor = cc.c3b(186, 142, 107);
    if tmpTable.q_rank == DATA_Mission.RewardTaskTypeEnum.JUINOR_TASK then
        tmpColor = MColor.green;
    elseif tmpTable.q_rank == DATA_Mission.RewardTaskTypeEnum.SENIOR_TASK then
        tmpColor = MColor.blue;
    elseif tmpTable.q_rank == DATA_Mission.RewardTaskTypeEnum.EXTREME_TASK then
        tmpColor = MColor.purple;
    end
    
    createLabel( cellBg , tmpTable.q_name, cc.p( 27 , 37 ) , cc.p( 0 , 0 ) , 22 , true , nil , nil , tmpColor , nil , nil);
    
    -- 奖励
    local iconX = 290;
    local iconDrawNum = 2;
    local iconNode = cc.Node:create();
    cellBg:addChild(iconNode);
    for i = 1 , #tmpTable.awrds do
        if i > iconDrawNum then break end
        
        local iconBtn = iconCell( { parent = iconNode , isTip = true , num = { value = tmpTable.awrds[i]["num"] } ,iconID = tmpTable.awrds[i]["id"] , allData = ( tmpTable.awrds[i]["streng"] and { streng = tmpTable.awrds[i]["streng"] } or nil ) } )
        setNodeAttr( iconBtn , cc.p( iconX + ( i - 1 ) * 80 , 12 ) , cc.p( 0, 0 ) )
    end

--    local tmpTables = {};
--    tmpTables[1] = {binding=1, num=20, streng=0, time=0, id=1073 };
--    tmpTables[2] = {binding=1, num=500, streng=0, time=0, id=222222 };
--    tmpTables[3] = {binding=1, num=500, streng=0, time=0, id=888888 };
--    --function __createAwardGroup( awards , isShowName , Interval , offX , isSwallow )
--    local iconGroup = __createAwardGroup( tmpTables, nil, 85 )
--    setNodeAttr( iconGroup , cc.p( 280 , 35 ) , cc.p( 0, 0.5 ) )
--    cellBg:addChild( iconGroup )

    -- 状态标记
    local statusSpr = createSprite( cellBg , "res/component/flag/2.png" , cc.p( 596 , 20 ) , cc.p( 0 , 0 ), 10);
    statusSpr:setVisible(false);

    local funcBtn = createMenuItem( cellBg , "res/component/button/39.png", cc.p( 800 , 50 ) , function()
            local tmpLua = require("src/layers/mission/MissionNetMsg");
            if G_ROLE_MAIN == nil or tmpTable == nil or tmpLua == nil then
                return;
            end
            
            -- 领取自己发布的悬赏任务, 若被别人完成，全奖; 若过期未被人完成, 80%，同时删除该任务
            tmpLua:SendRewardTaskReq(4, tmpTable.taskguid);
        end);
    if idx == 0 then
        G_TUTO_NODE:setTouchNode(funcBtn,TOUCH_REWARDTASK_RECEIVE)
    end

    local btnLabel = createLabel(funcBtn, game.getStrByKey("get_awards"), getCenterPos(funcBtn), cc.p(0.5, 0.5), 22, false, nil, nil, cc.c3b(247, 205, 147));

    local statusLabel = createLabel(cellBg, "", cc.p( 760 , 36 ), cc.p(0, 0), 22, false, nil, nil, cc.c3b(247, 205, 147));
    statusLabel:setVisible(false);

    local selfTask = DATA_Mission:GetRewardTaskData() and DATA_Mission:GetRewardTaskData()["hadTask"];

    -- 剩余时间
    local function getTimeStr(time)
        return string.format("%02d", (math.floor(time/60/60)%60)) .. " : " .. string.format("%02d", (math.floor(time/60)%60)) .. " : " .. string.format("%02d", math.floor(time%60));
    end

    local timeLab = createLabel(cellBg, "", cc.p(596, 37), cc.p(0, 0) , 22 , true , nil , nil , cc.c3b(186, 142, 107), nil , nil);

    local function RefreshStatus()
        if tmpTable.expiretime > 0 then -- 未过期
            if tmpTable.status == 1 then
                funcBtn:setVisible(true);
                statusSpr:setVisible(true);
                timeLab:setString("");
                statusLabel:setString("");
                statusLabel:setVisible(false);
            else
                funcBtn:setVisible(false);
                statusSpr:setVisible(false);
                timeLab:setString(getTimeStr(tmpTable.expiretime));
                statusLabel:setString(game.getStrByKey("taskNoFinished"));
                statusLabel:setColor(MColor.alarm_red);
                statusLabel:setVisible(true);
            end
        else
            if tmpTable.status == 1 then
                funcBtn:setVisible(true);
                statusSpr:setVisible(true);
                timeLab:setString("");
                statusLabel:setString("");
                statusLabel:setVisible(false);
            else    -- 自己发布的任务，若过期还未完成，也可以领取80%(假设)奖励
                funcBtn:setVisible(true);
                timeLab:setString(game.getStrByKey("taskHadExpired"));
                statusSpr:setVisible(false);
                statusLabel:setString("");
                statusLabel:setVisible(false);
            end
        end
    end

    RefreshStatus();
    
    -- 已过期，不加定时器
    cell.time = startTimerAction(cell, 0.1, true, function()
        if tmpTable.expiretime > 0 then
            RefreshStatus();
        else
            local delayFunc = function()
                RefreshStatus();
            end;
            startTimerAction(cell, 0.1, false, delayFunc)
            if cell.time then
                cell:stopAction(cell.time)
                cell.time = nil
            end
        end
    end);
    
    return cell;
end

return rewardTaskMyViewLayer;