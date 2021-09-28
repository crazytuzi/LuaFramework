--[[ 福利 ]]--
local M = class("GiftLayer", require("src/LeftSelectNode") )

function M:ctor( params )
    DATA_Activity.giftLayer = self
    DATA_Activity.activityLayer = nil
    
    params = params or {}

    DATA_Activity:addStatic() --每次打开都检查静态添加项是否条件达到

    local base_node ,closebtn  = createBgSprite(self,game.getStrByKey( "title_welfare" ))
    self.base_node = base_node

    if G_TUTO_NODE then
        G_TUTO_NODE:setTouchNode( closebtn , TOUCH_GIFT_CLOSE)
    end

    self.data = copyTable(DATA_Activity.giftData)
    if not ( G_NFTRIGGER_NODE and G_NFTRIGGER_NODE:isFuncOn(NF_SIGN_IN) ) then

        self.data["cellData"] = {}
        for i = 1 , #DATA_Activity.giftData["cellData"] do
            local v = DATA_Activity.giftData["cellData"][i]
            if v.modelID ~= 1 then
                table.insert( self.data["cellData"] , v )
            end
        end
    end

    if params.targetID then
        for i = 1 , #self.data["cellData"] do
            if params.targetID == self.data["cellData"][i]["modelID"] then
                params.activityID = i - 1 
            end
        end
    end

    self:init(params)

    self:registerScriptHandler(function(event)
        if event == "enter" then  
            if G_TUTO_NODE then
                G_TUTO_NODE:setShowNode(self, SHOW_GIFT)
            end
        elseif event == "exit" then
            if DATA_Activity.giftLayer then DATA_Activity.giftLayer = nil end
        end
    end)
end

function M:init(params)   
    self.selectIdx = params.activityID or 0  --初始化活动默认激活项
    if params.activityID then
        self.selectIdx = params.activityID
    else
        DATA_Activity.giftData["activityNum"] = DATA_Activity.giftData["activityNum"] or 1
        self.selectIdx = DATA_Activity.giftData["activityNum"] - 1
    end
    createScale9Frame(
        self.base_node,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(33, 40),
        cc.size(180, 495),
        4
    )
    createScale9Frame(
        self.base_node,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(217, 40),
        cc.size(710, 495),
        4
    )  
    --createSprite(self.base_node, "res/common/bg/buttonBg2.png", cc.p(16, 20), cc.p(0, 0))
    --createSprite(self.base_node, "res/common/bg/tableBg2.png", cc.p(205, 20), cc.p(0, 0))

    self.callBackFunc = function(idx)
        --更新右侧界面
        self:updateRight()
    end
    self.view_node = cc.Node:create()
    setNodeAttr( self.view_node , cc.p( 210, 24 ) , cc.p( 0 , 0 ) )    
    self.base_node:addChild( self.view_node )  
    self.normal_img = "res/component/button/40.png"
    self.select_img = "res/component/button/40_sel.png"
    local msize = size or cc.size(190, 485)
    self:createTableView(self.base_node, msize, cc.p(35, 45), true)
    self:updateRight()
end


function M:refreshDataFun()
    self.data = copyTable(DATA_Activity.giftData)

    if not ( G_NFTRIGGER_NODE and G_NFTRIGGER_NODE:isFuncOn(NF_SIGN_IN) ) then
        self.data["cellData"] = {}
        for i = 1 , #DATA_Activity.giftData["cellData"] do
            local v = DATA_Activity.giftData["cellData"][i]
            if v.modelID ~= 1 then
                table.insert( self.data["cellData"] , v )
            end
        end
    end


    self:getTableView():reloadData()
    if not self.isNoRight then
        self:updateRight()
    end
    
end

function M:getBaseNode()
    return self.base_node
end


function M:updateRight() 
    self.data = copyTable(DATA_Activity.giftData)
    if not ( G_NFTRIGGER_NODE and G_NFTRIGGER_NODE:isFuncOn(NF_SIGN_IN) ) then

        self.data["cellData"] = {}
        local num = 0
        if DATA_Activity.giftData["cellData"] then
            num = #DATA_Activity.giftData["cellData"]
        end
        for i = 1 , num do
            local v = DATA_Activity.giftData["cellData"][i]
            if v.modelID ~= 1 then
                table.insert( self.data["cellData"] , v )
            end
        end
    end
    
    if tablenums(self.data)<0 then return end
    local itemData = nil
    if self.data["cellData"] then
        itemData = self.data["cellData"][ self.selectIdx + 1 ]
    else
        return
    end
    if not itemData then return end
    if self.view_node then self.view_node:removeAllChildren()  end --清除可视内容
    
    local itemLayer = itemData.callback()
    if itemLayer then
        self.view_node:addChild( itemLayer )
    end
    

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
    local button = createSprite(cell, self.normal_img, cc.p(0, 0), cc.p(0, 0))
    if button then
        local size = button:getContentSize()
        button:setTag(10)
        if idx == self.selectIdx then
            button:setTexture(self.select_img)
            local arrow = createSprite(button, "res/group/arrows/9.png", cc.p(size.width, size.height/2), cc.p(0, 0.5))
            arrow:setTag(20)
        end
        if curData and curData.desc then
            createLabel(button, curData.desc, getCenterPos(button),cc.p(0.5, 0.5), 22, true, nil, nil )
        end

        local cell_red = createSprite(button, "res/component/flag/red.png", cc.p(size.width , size.height ), cc.p( 1 , 1 ))
        if cell_red then cell_red:setVisible( curData.redState ) end

        if curData.modelID == 1 then
            if G_TUTO_NODE then
                G_TUTO_NODE:setTouchNode(button, TOUCH_GIFT_SIGNIN)
            end
        end
    end

    return cell
end

function M:numberOfCellsInTableView(table)
    return ( self.data and self.data.cellData ) and tablenums( self.data.cellData ) or 0
end

return M