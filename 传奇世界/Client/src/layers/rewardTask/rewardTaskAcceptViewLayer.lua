local rewardTaskAcceptViewLayer = class("rewardTaskAcceptViewLayer", require( "src/TabViewLayer" ))
local width_enhance = 205
local parentImagePadding = 5
local frame_imagePadding = 2
local posX_frame, posY_frame = 13 - 3, 88 + 2
local frame_sizeWidth, frame_sizeHeight = 896 + 6, 426 + 2
local table_view_width, table_view_height = 886, 322
local base_posY_bottom_line = 21 + 24 + parentImagePadding - 4
local duration_delayToLoadCache = 1.5


function rewardTaskAcceptViewLayer:ctor()
    self.is_rewardTaskAcceptViewLayer = true
    local idx = 1-- 1.至尊2.蓝色3.普通
    self.view_node = createScale9Sprite(self, "res/common/scalable/bg4.png", cc.p(parentImagePadding + posX_frame - frame_imagePadding, parentImagePadding + posY_frame - frame_imagePadding), cc.size(frame_sizeWidth + frame_imagePadding, frame_sizeHeight + frame_imagePadding), cc.p(0, 0))
    
    if DATA_Mission:IsNeedNullRewardTask() then
        -- 构造一个假的
        performWithDelay(self, function()
            DATA_Mission:MakeNullRewardTask();
        end, 0 )
    else
        -- 请求数据
        require("src/layers/mission/MissionNetMsg"):SendRewardTaskReq(1, nil, 0)
    end

    -- 数据初始化
    self.m_curTaskData = nil;

    -- 控件初始化
    self.m_noTaskAcceptLal = nil;

    
    local title_bg = CreateListTitle(self, cc.p(15 + parentImagePadding, 417 + parentImagePadding), 891, 43, cc.p(0, 0))

    -- function createLabel(parent, sContent,pos, anchor, fontSize, isOutLine, izorder, fontName, fontColor, tag, specificWidth, outLineColor, outLineWidth)
    createLabel( title_bg , game.getStrByKey("taskName") , cc.p( 64 - 3, 8 ) , cc.p( 0, 0 ) , 22 , true , nil , nil , cc.c3b(247, 206, 150) , nil , nil);
    createLabel( title_bg , game.getStrByKey("taskPublisher") , cc.p( 264 - 3, 8) , cc.p( 0, 0 ) , 22 , true , nil , nil , cc.c3b(247, 206, 150) , nil , nil);
    createLabel( title_bg , game.getStrByKey("taskRewards") , cc.p( 430 - 3, 8 ) , cc.p( 0, 0 ) , 22 , true , nil , nil , cc.c3b(247, 206, 150) , nil , nil);
    createLabel( title_bg , game.getStrByKey("taskDeadline") , cc.p( 599 - 3, 8 ) , cc.p( 0, 0 ) , 22 , true , nil , nil , cc.c3b(247, 206, 150) , nil , nil);
    ---------------------------------------------------------------------------------

    self.m_noTaskAcceptLal = createLabel(
        self
        , game.getStrByKey("taskLoading")
        , cc.p(self.view_node:getPositionX() +  self.view_node:getContentSize().width / 2, self.view_node:getPositionY() +  self.view_node:getContentSize().height / 2)
        , cc.p(0.5, 0.5)
        , 28
        , true
        , 101
        , nil
        , MColor.red
    );
    self.m_noTaskAcceptLal:setString(game.getStrByKey("taskLoading"));
    

    -- function TabViewLayer:createTableView(parent,size,pos,t_type)
    local scroll_bar_buffer_width = 5
    self:createTableView(self , cc.size(table_view_width + scroll_bar_buffer_width, table_view_height) , cc.p(17 + parentImagePadding, 93 + parentImagePadding) , true, true);

    ---------------------------------------------------------------------------------
    local btn_help = __createHelp({parent = self, str = require("src/config/PromptOp"):content(56) , pos = cc.p(21 - 5 - 5 + parentImagePadding, base_posY_bottom_line + 4)})
    btn_help:setAnchorPoint(cc.p(0, .5))
    local clickFunc = function(sender)
        sender:setTexture(sender:getTexture() == TextureCache:getTextureForKey("res/component/checkbox/1.png") and "res/component/checkbox/1-2.png" or "res/component/checkbox/1.png")
        self.m_curTaskData = nil
        self.m_noTaskAcceptLal:setString(game.getStrByKey("taskLoading"));
        self.m_noTaskAcceptLal:setVisible(true)
        self:getTableView():setVisible(false)

        if DATA_Mission:IsNeedNullRewardTask() then
            -- 构造一个假的
            DATA_Mission:MakeNullRewardTask();
        else
            require("src/layers/mission/MissionNetMsg"):SendRewardTaskReq(1, nil, 0)
        end
    end
    local posY_base = 479 + parentImagePadding + 10
    createLabel(self, game.getStrByKey("taskExtremeBounty"), cc.p(42 + parentImagePadding, posY_base), cc.p(0, .5), 20, nil, nil, nil, cc.c3b(247, 206, 150))
    self.check_box_zhi_zun = createTouchItem(self, "res/component/checkbox/1-2.png", cc.p(133 + parentImagePadding, posY_base), clickFunc)
    self.check_box_zhi_zun:setAnchorPoint(cc.p(0, .5))
    createLabel(self, game.getStrByKey("taskSeniorBounty"), cc.p(170 + 42 + parentImagePadding, posY_base), cc.p(0, .5), 20, nil, nil, nil, cc.c3b(247, 206, 150))
    self.check_box_gao_ji = createTouchItem(self, "res/component/checkbox/1-2.png", cc.p(170 + 133 + parentImagePadding, posY_base), clickFunc)
    self.check_box_gao_ji:setAnchorPoint(cc.p(0, .5))
    createLabel(self, game.getStrByKey("taskJuinorBounty"), cc.p(170 * 2 + 42 + parentImagePadding, posY_base), cc.p(0, .5), 20, nil, nil, nil, cc.c3b(247, 206, 150))
    self.check_box_pu_tong = createTouchItem(self, "res/component/checkbox/1-2.png", cc.p(170 * 2 + 133 + parentImagePadding, posY_base), clickFunc)
    self.check_box_pu_tong:setAnchorPoint(cc.p(0, .5))
    local releaseTask_btn = createMenuItem(self, "res/component/button/38.png", cc.p(711 + 188 / 2, base_posY_bottom_line + 2) , function()
        local node_dialog = require("src/layers/rewardTask/rewardTaskReleaseDialog").new()
        node_dialog:setTag(require("src/config/CommDef").TAG_REWARD_TASK_DIALOG)
        node_dialog:setPosition(g_scrCenter)
		SwallowTouches(node_dialog)
        getRunScene():addChild(node_dialog, 200)--当前层zOrder = 200
    end)
    G_TUTO_NODE:setTouchNode(releaseTask_btn,TOUCH_REWARDTASK_REKEASE)
    createLabel(releaseTask_btn, game.getStrByKey("releaseTask"), getCenterPos(releaseTask_btn), cc.p(0.5, 0.5), 22, false, nil, nil, cc.c3b(247, 205, 147))
end

function rewardTaskAcceptViewLayer:LoadCacheData()
    -- 判断是否已经获取到了数据
    if self.m_curTaskData then
        return
    end
    local path = getDownloadDir() .. "rewardTask_" .. tostring(userInfo.currRoleStaticId) .. ".txt";
    local file = io.open(path, "r");
    if file == nil then
        self:RefreshData()
        return
    end
    local tmpLines = {};
    local line = file:read();
    while line do
        table.insert(tmpLines, line);
        line = file:read();
    end

    local acceptableData = {};
    local taskNum = 0;
    for i=1, #tmpLines do
        local tmpTable = stringsplit(tmpLines[i], ",");
        if tmpTable ~= nil then
            if i == 1 then
                acceptableData.blueLeftNum = tonumber(tmpTable[1]);
                acceptableData.purpleLeftNum = tonumber(tmpTable[2]);
                acceptableData.extremeLeftNum = tonumber(tmpTable[3]);
                taskNum = tonumber(tmpTable[4]);
            else
                if acceptableData.taskList == nil then
                    acceptableData.taskList = {};
                end

                acceptableData.taskList[i-1] = {};
                acceptableData.taskList[i-1].taskguid = tonumber(tmpTable[1]);              -- 唯一ID
                acceptableData.taskList[i-1].ownername = tmpTable[2];                       -- 发布者名字
                acceptableData.taskList[i-1].expiretime = tonumber(tmpTable[3]);             -- 过期时间(到期时的秒数)
                acceptableData.taskList[i-1].taskrank = tonumber(tmpTable[4]);               -- 1 蓝色, 2 紫色, 3 至尊
                acceptableData.taskList[i-1].taskid = tonumber(tmpTable[5]);                 -- 任务ID
                acceptableData.taskList[i-1].receiveNum = tonumber(tmpTable[6]);                 -- 任务被接取次数
                if tmpTable[7] then
                    acceptableData.taskList[i-1].newTag = tonumber(tmpTable[7]);                -- 1. new 标记
                else
                    acceptableData.taskList[i-1].newTag = 0;
                end
            end
        end
    end

    if (taskNum == 0) or (acceptableData.taskList ~= nil and #acceptableData.taskList == taskNum) then
        DATA_Mission:FormatAcceptRewardTasks(acceptableData)
    end

    io.close(file);
end

-- 数据回调刷新
function rewardTaskAcceptViewLayer:RefreshData()
    self:getTableView():setVisible(true)
    self.m_curTaskData = {}
    if self.check_box_pu_tong:getTexture() == TextureCache:getTextureForKey("res/component/checkbox/1-2.png") and self:GetBlueOrPurpleTask(DATA_Mission.RewardTaskTypeEnum.JUINOR_TASK) then       -- 普通任务
        for k, v in pairs(self:GetBlueOrPurpleTask(DATA_Mission.RewardTaskTypeEnum.JUINOR_TASK)) do
            table.insert(self.m_curTaskData, v)
        end
    end
    if self.check_box_gao_ji:getTexture() == TextureCache:getTextureForKey("res/component/checkbox/1-2.png") and self:GetBlueOrPurpleTask(DATA_Mission.RewardTaskTypeEnum.SENIOR_TASK) then   -- 高级任务
        for k, v in pairs(self:GetBlueOrPurpleTask(DATA_Mission.RewardTaskTypeEnum.SENIOR_TASK)) do
            table.insert(self.m_curTaskData, v)
        end
    end
    if self.check_box_zhi_zun:getTexture() == TextureCache:getTextureForKey("res/component/checkbox/1-2.png") and self:GetBlueOrPurpleTask(DATA_Mission.RewardTaskTypeEnum.EXTREME_TASK) then   -- 至尊任务
        for k, v in pairs(self:GetBlueOrPurpleTask(DATA_Mission.RewardTaskTypeEnum.EXTREME_TASK)) do
            table.insert(self.m_curTaskData, v)
        end
    end
    table.sort(self.m_curTaskData, function(a, b)
        if a.q_rank ~= b.q_rank then
            return a.q_rank > b.q_rank
        end
        if a.receiveNum ~= b.receiveNum then
            return a.receiveNum < b.receiveNum 
        end
        return a.expiretime < b.expiretime
    end)
    -- 必须在rewardTaskAcceptViewLayer 创建自属的tableview后才能调
    self:getTableView():reloadData();

    if self.m_curTaskData ~= nil then
        if #self.m_curTaskData > 0 then
            self.m_noTaskAcceptLal:setVisible(false);
        else
            self.m_noTaskAcceptLal:setString(game.getStrByKey("taskNoToAcccept"));
            self.m_noTaskAcceptLal:setVisible(true);
        end
    else
        self.m_noTaskAcceptLal:setString(game.getStrByKey("taskLoading"));
        self.m_noTaskAcceptLal:setVisible(true);
    end

    self:RefreshSelfTips();
end

function rewardTaskAcceptViewLayer:RefreshSelfTips()
--[[
    blue:代表绿色任务!
    purple:代表高级任务(蓝色)
    extream:至尊任务
]]
    local rewardTasks = DATA_Mission:GetRewardTaskData();
    
    local purpleNum = rewardTasks and rewardTasks.acceptLeftPurpleNum or 0;
    local blueNum = rewardTasks and rewardTasks.acceptLeftBlueNum or 0;
    local extremeNum = rewardTasks and rewardTasks.acceptLeftExtremeNum or 0;

    local tag_private_help_tips = 50001
    local text_width, text_height = 551, 35
    self:removeChildByTag(tag_private_help_tips)
    local leftRichText = require("src/RichText").new(self, cc.p(78 + parentImagePadding, base_posY_bottom_line) , cc.size(text_width, 0 ) , cc.p( 0 , .5 ) , 24 , 22 , MColor.white)
    leftRichText:setAutoWidth()
    leftRichText:setTag(tag_private_help_tips)
    
    local leftStr = "^c(lable_yellow)" .. game.getStrByKey("taskTodayCan") .. game.getStrByKey("taskFinish") ..
            "^" .. extremeNum .. "^c(lable_yellow)" ..
            game.getStrByKey("baby_material_number") .. "^^c(purple)" ..
            game.getStrByKey("taskExtremeBounty") ..
            "^^c(lable_yellow), ^" .. purpleNum .. "^c(lable_yellow)" ..
            game.getStrByKey("baby_material_number") .. "^^c(blue)" ..
            game.getStrByKey("taskSeniorBounty") .. "^^c(lable_yellow), ^" .. blueNum .. "^c(lable_yellow)"  ..
            game.getStrByKey("baby_material_number") .. "^^c(green)" ..
            game.getStrByKey("taskJuinorBounty") .. "^";
    leftRichText:addText(leftStr);
	leftRichText:format();
end

function rewardTaskAcceptViewLayer:cellSizeForTable(table,idx) 
    local cellPadding = 2
    return 100 + cellPadding, table_view_width
end

function rewardTaskAcceptViewLayer:scrollViewDidScroll(view)
    --[[
    -- 获取当前滚动范围 {y=-356 x=0 }
    local curP = view:getContentOffset();
    -- 滚动区域 = {height=720 width=888 } - {height=364 width=888 }(显示范围)
    local viewConS = view:getContentSize();
    local viewS = view:getViewSize();
    local showS = cc.size(viewConS.width - viewS.width, viewConS.height - viewS.height);
    -- 计算滑动距离的百分比, 竖直tabview 水平无法滚动, 初始1, 往下减小可到负, 往上增大可到 >1
    local percent = -(curP.y / showS.height);

    -- 控制滑块
    if self.m_sliderBar ~= nil then
        local newY = self.m_sliderEndY;
        if percent >= 0 and percent <= 1 then
            newY = self.m_sliderStartY - (self.m_sliderStartY - self.m_sliderEndY) * (1 - percent);
        elseif percent < 0 then
            newY = self.m_sliderEndY;
        elseif percent > 1 then
            newY = self.m_sliderStartY;
        end
        self.m_sliderBar:setPosition(self.m_sliderX, newY);
    end
    ]]
end

function rewardTaskAcceptViewLayer:numberOfCellsInTableView(table)
    if self.m_curTaskData ~= nil then
        return tablenums(self.m_curTaskData)
    end
    
    return 0;
end

-- 创建的cell数量 = tableview的高度 / 单个 cell 的高度 + 1
-- 一个物理cell 可能映射N 个逻辑 cell
function rewardTaskAcceptViewLayer:tableCellAtIndex(table, idx)
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
    
    local cellBg = createScale9Sprite(cell, "res/common/scalable/item.png", cc.p(0, 0), cc.size(table_view_width, 100), cc.p(0, 0))
    local tmpColor = cc.c3b(186, 142, 107);
    if tmpTable.q_rank == DATA_Mission.RewardTaskTypeEnum.JUINOR_TASK then
        tmpColor = MColor.green;
    elseif tmpTable.q_rank == DATA_Mission.RewardTaskTypeEnum.SENIOR_TASK then
        tmpColor = MColor.blue;
    elseif tmpTable.q_rank == DATA_Mission.RewardTaskTypeEnum.EXTREME_TASK then
        tmpColor = MColor.purple;
    end

    -- new 标记
    if tmpTable.newTag and tmpTable.newTag == 1 then
        createSprite(cellBg, "res/layers/activity/btnTag/3.png", cc.p(0, 76), cc.p(0, 0));
    end
    
    createLabel( cellBg , tmpTable.q_name, cc.p( 34 , 37 + 11 ) , cc.p( 0 , 0 ) , 22 , true , nil , nil , tmpColor , nil , nil);
    createLabel( cellBg , tmpTable.receiveNum == 0 and game.getStrByKey("rewardTaskCountNoBody") or game.getStrByKey("currentRewardTaskCount") .. tmpTable.receiveNum, cc.p( 34 , 10 + 11 ) , cc.p( 0 , 0 ) , 20 , true , nil , nil , tmpColor , nil , nil);
    createLabel( cellBg , tmpTable.ownername, cc.p( 241 , 37 ) , cc.p( 0 , 0 ) , 22 , true , nil , nil , cc.c3b(186, 142, 107) , nil , nil);
    
    
    -- 奖励
    local iconX = 391;
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

    local funcBtn = createMenuItem( cellBg , "res/component/button/39.png", cc.p( 731 + 132 / 2 , 50 ) , function()
            local tmpLua = require("src/layers/mission/MissionNetMsg");
            if G_ROLE_MAIN == nil or tmpTable == nil or tmpLua == nil then
                return;
            end
            -- 接取悬赏任务
            tmpLua:SendRewardTaskReq(2, tmpTable.taskguid, tmpTable.taskid);
        end);
    if idx == 0 then
        G_TUTO_NODE:setTouchNode(funcBtn,TOUCH_REWARDTASK_RECEIVE)
    end

    local btnLabel = createLabel(funcBtn, game.getStrByKey("taskAcceptReward"), getCenterPos(funcBtn), cc.p(0.5, 0.5), 22, false, nil, nil, cc.c3b(247, 205, 147));

    local statusLabel = createLabel(cellBg, "", cc.p( 731 , 37 ), cc.p(0, 0), 22, false, nil, nil, cc.c3b(247, 205, 147));
    statusLabel:setVisible(false);

    local selfTask = DATA_Mission:GetRewardTaskData() and DATA_Mission:GetRewardTaskData()["hadTask"];

    -- 剩余时间
    local function getTimeStr(time)
        return string.format("%02d", (math.floor(time/60/60)%60)) .. " : " .. string.format("%02d", (math.floor(time/60)%60)) .. " : " .. string.format("%02d", math.floor(time%60));
    end

    local timeLab = createLabel(cellBg, "", cc.p(591, 37), cc.p(0, 0) , 22 , true , nil , nil , cc.c3b(186, 142, 107), nil , nil);

    local function RefreshStatus()
        if tmpTable.expiretime > 0 then -- 未过期
            timeLab:setString(getTimeStr(tmpTable.expiretime));
            if selfTask ~= nil then  -- 自己已经接取
                if selfTask.taskguid == tmpTable.taskguid then
                    funcBtn:setVisible(false);
                    statusLabel:setString(game.getStrByKey("already") .. game.getStrByKey("taskAccept"));
                    statusLabel:setVisible(true);
                else
                    funcBtn:setVisible(true);
                    statusLabel:setString("");
                    statusLabel:setVisible(false);
                end                    
            else
                funcBtn:setVisible(true);
                statusLabel:setString("");
                statusLabel:setVisible(false);
            end
        else
            if selfTask ~= nil then  -- 自己已经接取
                if selfTask.taskguid == tmpTable.taskguid then
                    timeLab:setString(game.getStrByKey("taskHadExpired"));
                    funcBtn:setVisible(false);
                    statusLabel:setString(game.getStrByKey("already") .. game.getStrByKey("taskAccept"));
                    statusLabel:setVisible(true);
                else
                    timeLab:setString(game.getStrByKey("taskHadExpired"));
                    funcBtn:setVisible(false);
                    statusLabel:setString("");
                    statusLabel:setVisible(false);
                end
            else
                timeLab:setString(game.getStrByKey("taskHadExpired"));
                funcBtn:setVisible(false);
                statusLabel:setString("");
                statusLabel:setVisible(false);
            end

            -- 有过期的任务，需要请求数据，刷新掉
            require("src/layers/mission/MissionNetMsg"):SendRewardTaskReq(1, nil, 0);
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

function rewardTaskAcceptViewLayer:GetBlueOrPurpleTask(typ)
    local tmp = nil;
    local rewardTasks = DATA_Mission:GetRewardTaskData();
    if rewardTasks ~= nil then
        if typ == DATA_Mission.RewardTaskTypeEnum.JUINOR_TASK then
            return rewardTasks["juinor"];
        elseif typ == DATA_Mission.RewardTaskTypeEnum.SENIOR_TASK then
            return rewardTasks["senior"];
        elseif typ == DATA_Mission.RewardTaskTypeEnum.EXTREME_TASK then
            return rewardTasks["extreme"];
        end
    end

    return tmp;
end

return rewardTaskAcceptViewLayer;