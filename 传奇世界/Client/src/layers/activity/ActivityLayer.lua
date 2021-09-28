--[[ 活动 ]]--
local M = class("ActivityLayer", require("src/LeftSelectNode") )

function M:ctor( params )
    params = params or {};

    self.m_activityTimeLal = nil;
    self.m_activityContentLal = nil;
    self.m_activityNoneSpr = nil;

    self.data = DATA_Activity.activityData;
    self.m_richTextWidth = 592;
    self.m_richTextHeight = 155;
    self.m_refreshDownY = 0;

    self.m_oriOffset = nil;

    self.m_oldActivityId = 0;
    
    DATA_Activity.isLoginShow = true;

    self:registerScriptHandler(function(event)
        if event == "enter" then    -- addchild就会调用
            DATA_Activity:SortActivityPage();
        elseif event == "exit" then
            self.setContentText = nil
            DATA_Activity.activityLayer = nil
        end
    end)

    getRunScene():addChild(self,200)

    DATA_Activity.activityLayer = self;

    self.base_node = createSprite( self , "res/layers/activity/bg.png" , cc.p( display.cx , display.cy ) , cc.p( 0.5 , 0.5 ) )
    local func = function() 
        self.setContentText = nil
        removeFromParent(self) 
        DATA_Activity.activityLayer = nil
    end
    registerOutsideCloseFunc( self.base_node , func , true )
    local close_btn = createMenuItem( self.base_node , "res/component/button/x2.png", cc.p( self.base_node:getContentSize().width-74 , self.base_node:getContentSize().height-64 ) , func )

    local size = self.base_node:getContentSize()
    createLabel(self.base_node ,  game.getStrByKey("title_activity"), cc.p(size.width/2,size.height-45),cc.p(0.5, 0.5), 24, true, nil, nil)

    self.m_leftFrameBg = createScale9Frame(
        self.base_node,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(62, 32),
        cc.size(188,501),
        5
    )

    self.m_rightFrameBg = createScale9Frame(
        self.base_node,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(257, 32),
        cc.size(700,499),
        5
    )

    self.m_activityTimeLal = createLabel( self.base_node , game.getStrByKey("activity_time")  , cc.p( 274 , 500 ) , cc.p( 0 , 0 ) , 22 , true , 200 , nil , MColor.lable_yellow , nil , nil , MColor.black , 3 )
    self.m_activityContentLal = createLabel( self.base_node , game.getStrByKey("activity_content") .. "：" , cc.p( 274 , 495 ) , cc.p( 0 , 1 ) , 22 , true , 200 , nil , MColor.lable_yellow , nil , nil , MColor.black , 3 )
    self.timeText = createLabel( self.base_node , "" , cc.p( 385 , 500 ) , cc.p( 0 , 0 ) , 22 , true , 200 , nil , MColor.white , nil , nil , MColor.black , 3 )
    
    --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    self.m_activityNoneSpr = createSprite( self.base_node , "res/layers/activity/noactivity.jpg" , cc.p(61, 38), cc.p(0, 0) )

    --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
    local contentLayer = cc.Node:create()

    self.m_scrollView1 = cc.ScrollView:create()    
    

    local function setContentText( str )
        if contentLayer  then  contentLayer:removeAllChildren() end         
        local function createText()
            local tempNode = cc.Node:create()
            local fontSize = 22
            local text = require("src/RichText").new( tempNode , cc.p( 0 , 0 ) , cc.size( self.m_richTextWidth - 40 , 0 ) , cc.p( 0 , 1 ) , fontSize + 10 , fontSize , MColor.lable_yellow )
            text:addText( str , MColor.lable_yellow , false )
            text:format()

            tempNode:setContentSize( cc.size( self.m_richTextWidth , math.abs( text:getContentSize().height )  ) )
            setNodeAttr( text , cc.p( 0 , 0 ) , cc.p( 0 , 0  ) )
            return tempNode
        end


        local layer = createText()
        local layerSize = layer:getContentSize()
        contentLayer:addChild( layer )
        contentLayer:setContentSize( layerSize )
        
        self.m_scrollView1:updateInset();
        self.m_refreshDownY = -( layerSize.height - self.m_richTextHeight );
        
        self.m_scrollView1:setContentOffset( cc.p( 0 , self.m_refreshDownY ) )
    end
    self.setContentText = setContentText


    self.m_scrollView1:setViewSize(cc.size( self.m_richTextWidth  , self.m_richTextHeight ) )
    self.m_scrollView1:setPosition( cc.p( 385 , 340  ) )
    self.m_scrollView1:ignoreAnchorPointForPosition(true)
    self.m_scrollView1:setContainer( contentLayer )
    self.m_scrollView1:updateInset()
    self.m_scrollView1:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL )
    self.m_scrollView1:setClippingToBounds(true)
    self.m_scrollView1:setBounceable(true)
    self.m_scrollView1:setDelegate()
    self.m_scrollView1:registerScriptHandler(function(view)
        self:scrollViewDidScroll(view)
    end, cc.SCROLLVIEW_SCRIPT_SCROLL)
    self.base_node:addChild( self.m_scrollView1 , 2 )

    self:init(params);
    
end

function M:init(params) 

    if DATA_Activity.noAnchorPoint then
        --主动点击时  屏蔽后台激活锚点功能
        DATA_Activity.noAnchorPoint = nil
        self.selectIdx = params.activityID or 0  --初始化活动默认激活项
    else
        self.selectIdx = DATA_Activity.activityData["activityNum"] and DATA_Activity.activityData["activityNum"] - 1 or 0
    end
    
    

    self.callBackFunc = function(idx)
        self:SetActivityId();

        --更新右侧界面
        self:updateRight()
    end
    
    self.normal_img = "res/layers/activity/btn.png"
    self.select_img = "res/layers/activity/btn_sel.png"

    local msize = size or cc.size(200, 496 )

    self.view_node = cc.Node:create()
    setNodeAttr( self.view_node , cc.p( 257, 32 ) , cc.p( 0 , 0 ) )    
    self.base_node:addChild( self.view_node )
    self:createTableView(self.base_node, msize, cc.p(64, 34), true)

    self.data = DATA_Activity.activityData;

    self:SetActivityId();

    self:updateRight()

    self:ChangeFirstIdxRedState();
end

function M:SetActivityId()
    if self.data and self.data["cellData"] then
        local itemData = self.data["cellData"][ self.selectIdx + 1 ];
        if itemData then
            self.m_oldActivityId = itemData.activityID;
        end
    end
end


function M:refreshDataFun()
    -----------------------------------------------------------
    -- 针对删除活动的特殊情况
    local oldActivityNum = 0;
    if self.data and self.data["cellData"] then
        oldActivityNum = #(self.data["cellData"]);
    end
    -----------------------------------------------------------
    
	DATA_Activity:SortActivityPage();
	
    self.data = DATA_Activity.activityData;

    -----------------------------------------------------------
    local newActivityNum = 0;
    if self.data and self.data["cellData"] then
        newActivityNum = #(self.data["cellData"]);
    end
    
    local iOffsetY = nil;
    -- 获取原来的选中活动，在新的排序中的位置
    if self.data and self.data["cellData"] then
        if oldActivityNum == newActivityNum and self.m_oriOffset then
            iOffsetY = self.m_oriOffset.y;
        else
            for i=1, newActivityNum do
                if self.data["cellData"][i].activityID == self.m_oldActivityId then
            	    if newActivityNum > 8 and (newActivityNum-i) >= 8 then
                	    iOffsetY = (newActivityNum-8-i+1) * (-1) * (64+2);
                	    self.selectIdx = (i-1);
                    else
                	    if self.selectIdx > (newActivityNum - 1) then
			                self.selectIdx = newActivityNum-1;
			            end

                        -- 获取原来的偏移
                        local oriOffset = self:getTableView():getContentOffset();
                        iOffsetY = oriOffset.y;
                    end
                
                    break;
                end
            end
        end
    end

    -- 原活动已删除
    if iOffsetY == nil then
    	self.selectIdx = 0;
    end

    -----------------------------------------------------------

    self:getTableView():reloadData()
    
    if iOffsetY == nil then
    	local viewConS = self:getTableView():getContentSize();
    	local viewS = self:getTableView():getViewSize();
    	local showS = cc.size(viewConS.width - viewS.width, viewConS.height - viewS.height);
    	iOffsetY = viewS.height-viewConS.height;
    end

    -- 重新设置位置
    self:getTableView():setContentOffset(cc.p(0, iOffsetY));

    self:updateRight()
end

function M:getBaseNode()
    return self.base_node
end

function M:ResetLabel(show)
    self.m_activityTimeLal:setVisible(show);
    self.m_activityContentLal:setVisible(show);
    self.m_leftFrameBg:setVisible(show);
    self.m_rightFrameBg:setVisible(show);
    
    self.m_activityNoneSpr:setVisible(not show);
end


function M:updateRight() 
    self.timeText:setString("");
    self.setContentText("");
    
    if self.view_node then self.view_node:removeAllChildren()  end --清除可视内容
    
    if tablenums(self.data)<=0 then 
        self:ResetLabel(false);
        return;
    end

    local itemData = nil
    if self.data["cellData"] then
        itemData = self.data["cellData"][ self.selectIdx + 1 ]
    else
        self:ResetLabel(false);
        return
    end

    if not itemData then
        self:ResetLabel(false);
        return
    end

    local itemLayer = itemData.callback()
    if itemLayer and  self.view_node then
        self.view_node:addChild( itemLayer )
    end

    self.m_oriOffset = self:getTableView():getContentOffset();
    
    self:ResetLabel(true);
end

function M:cellSizeForTable(table,idx)
    return 64+2, 200
end

function M:tableCellAtIndex( table , idx )
    local cell = table:dequeueCell()
    local index = idx + 1 
    if nil == cell then
        cell = cc.TableViewCell:new()   
    else
        cell:removeAllChildren()
    end
    local curData = self.data.cellData[ index ]

    local button = createSprite(cell, self.normal_img, cc.p(0, 2), cc.p(0, 0))
    if button then
        local size = button:getContentSize()
        button:setTag(10)
        if idx == self.selectIdx then
            button:setTexture(self.select_img)
            local arrow = createSprite(button, "res/group/arrows/9.png", cc.p(size.width, size.height/2), cc.p(0, 0.5))
            arrow:setTag(20)
        end
        if curData and curData.desc then
            createLabel(button, curData.desc, getCenterPos(button, 25), cc.p(0.5, 0.5), 18, true, nil, nil )
        end

        local activityPic = 1;
        if curData.pic >= 1 and curData.pic <= 4 then
            activityPic = curData.pic;
        end
        local typeSpr = createSprite(button, "res/layers/activity/btnFlag/" .. activityPic .. ".png", cc.p(0, size.height/2), cc.p(0, 0.5));

        if curData.leftLabel >= 1 and curData.leftLabel <= 4 then
            local statusSpr = createSprite(button, "res/layers/activity/btnTag/" .. curData.leftLabel .. ".png", cc.p(size.width-53, size.height), cc.p(0, 1));
        end

        local tmpRecord = getLocalRecordByKey(1, "activityRed" .. curData.activityID, 0);
        local cell_red = createSprite(button, "res/component/flag/red.png", cc.p(0 , size.height ), cc.p( 0 , 1 ))
        if cell_red then cell_red:setVisible( curData.redState or (tmpRecord == 1) ) end
        cell_red:setTag(30);

    end

    return cell
end

function M:tableCellTouched(table,cell)
    -- 0 开始
    local index = cell:getIdx()
	if self.selectIdx ~= index then
		local curData = self.data.cellData[ index+1 ]

        local button = cell:getChildByTag(10)
		if button then
            local cell_red = button:getChildByTag(30);
            if cell_red then
                local tmpRecord = getLocalRecordByKey(1, "activityRed" .. curData.activityID, 0);
                if tmpRecord ~= 2 then
                    setLocalRecordByKey(1, "activityRed" .. curData.activityID, 2);
                end

                -- 点击过后每天的上线第一次的小红点需要去除
                if curData.redState == false then
                    cell_red:setVisible(false);                    
                end
            end
        end
	end

    -- 调用父类的方法
	self.super.tableCellTouched(self, table, cell);
end

-- 去除列表中选中项的小红点
function M:UpdateSelectCell()
    local table = self:getTableView();
    if table ~= nil then
        local cell = table:cellAtIndex(self.selectIdx)
        if cell ~= nil then
            local curData = self.data.cellData[self.selectIdx + 1]
            if curData then
                local button = cell:getChildByTag(10)
		        if button then
                    local cell_red = button:getChildByTag(30);
                    if cell_red then
                        -- 点击过后每天的上线第一次的小红点需要去除
                        if curData.redState == false then
                            cell_red:setVisible(false);                    
                        end
                    end
                end
            end
        end
    end
end

-- 点击过后每天的上线第一次的小红点需要去除, 默认选中的默认点击过
function M:ChangeFirstIdxRedState()
    if self.data and self.data.cellData and self.selectIdx then
        local curData = self.data.cellData[ self.selectIdx+1 ]
        if curData then
            local tmpRecord = getLocalRecordByKey(1, "activityRed" .. curData.activityID, 0);
            if tmpRecord ~= 2 then
                setLocalRecordByKey(1, "activityRed" .. curData.activityID, 2);
            end
        end
    end
end

function M:numberOfCellsInTableView(table)
    return ( self.data and self.data.cellData ) and tablenums( self.data.cellData ) or 0
end

function M:tableViewDidScroll(view)
    if view then
        self.m_oriOffset = view:getContentOffset();
    end
end

-- 禁止往下滑
function M:scrollViewDidScroll(view)
    --print("-------------------------------------------------------------------------------");
    -- 获取当前滚动范围 {y=-356 x=0 }
    local curP = self.m_scrollView1:getContentOffset();
    --print("curP x = " .. curP.x .. " - y = " .. curP.y);
    -- 滚动区域 = {height=720 width=888 } - {height=364 width=888 }(显示范围)
    --local viewConS = self.m_scrollView1:getContentSize();
    --print("viewConS width = " .. viewConS.width .. " - height = " .. viewConS.height);
    --local viewS = self.m_scrollView1:getViewSize();
    --print("viewS width = " .. viewS.width .. " - height = " .. viewS.height);
    --local showS = cc.size(viewConS.width - viewS.width, viewConS.height - viewS.height);
    --print("showS width = " .. showS.width .. " - height = " .. showS.height);
    -- 计算滑动距离的百分比, 竖直tabview 水平无法滚动, 初始1, 往下减小可到负, 往上增大可到 >1
    --local percent = -(curP.y / showS.height);
    --print("percent = " .. percent);

    -- 即 percent > 1.0
    if curP.y < self.m_refreshDownY then
        self.m_scrollView1:setContentOffset( cc.p( 0 , self.m_refreshDownY ) )
    end
end

return M