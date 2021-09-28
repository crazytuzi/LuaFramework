--[[ 剧情界面 ]]--
local M = class( "PLOTLAYER" , require( "src/TabViewLayer" ) )  --章节列表
function M:ctor(parent)
    self.cfgData = DATA_Mission:getPlotData()
    self.chapterIndex = #self.cfgData       --默认最后一章
    self.data = self.cfgData[self.chapterIndex]
    self.itemIndex  = #self.data            --默认最近一个任务

    parent:addChild(self)

    local bg = createScale9Frame(
        self,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(32, 38),
        cc.size(332,502),
        5
    )
   
	CreateListTitle(bg, cc.p(bg:getContentSize().width/2 , bg:getContentSize().height), 328, 47, cc.p(0.5, 1))

    local bg = createScale9Frame(
        self,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(370, 38),
        cc.size(558,502),
        5
    )
    --createSprite( self ,"res/common/bg/bg3.png" , cc.p( 356 + 15 , 18 + 21 ) ,  cc.p( 0 , 0 ) )
    createSprite( bg ,"res/common/bg/bg66-1.jpg" , getCenterPos( bg ) ,  cc.p( 0.5 , 0.5 ) )

    local config = {{  text = "task_target" , y = 330 } , {  text = "task_reward" , y = 70 } , }
    for i = 1 , #config do
        local titleSp = createSprite( bg , "res/common/bg/titleLine.png" , cc.p(  590/2 - 15 , config[i].y + 115) ,  cc.p( 0.5 , 0 )  )
        createLabel( titleSp , game.getStrByKey( config[i].text )  , getCenterPos( titleSp ), cc.p( 0.5 , 0.5 ) , 22 , nil , nil , nil , MColor.lable_yellow , nil , nil , MColor.black , 2 )
    end



    self:createTableView(self , cc.size( 361 - 15 , 470 - 21 ) , cc.p( 10 + 10 , 25 + 21 ) , true , true )
    self:getTableView():setBounceable(true)


    local function lastItem()
        if self.itemIndex ~= 1 then

            --设置偏移量

            if tablenums( self.data ) >= 8  then
                self:getTableView():setContentOffset( self:getTableView():maxContainerOffset()  ) --默认到最后
            end
        end
    end
    local leftBtn , rightBtn = nil , nil
    local function btnShow()
        if #self.cfgData == 1 then
            leftBtn:setVisible( false)
            rightBtn:setVisible( false)
        else
            if self.chapterIndex == 1 then
                leftBtn:setVisible( false)
                rightBtn:setVisible( true )
            elseif self.chapterIndex == #self.cfgData then
                leftBtn:setVisible( true)
                rightBtn:setVisible( false )
            else
                leftBtn:setVisible( true)
                rightBtn:setVisible( true )
            end
        end
    end
    local chapterName = createLabel( self , self.data[1].q_chapter_name , cc.p(187 + 15  , 520) , cc.p( 0.5 , 0.5 ) , 20 , nil , nil , nil , MColor.lable_yellow , nil , nil )
    local function changeIndex( _flag )
        if _flag == 1 then
            self.chapterIndex = self.chapterIndex + 1
        else
            self.chapterIndex = self.chapterIndex - 1
        end

        if self.chapterIndex<1 then self.chapterIndex = 1 end
        if self.chapterIndex>#self.cfgData then self.chapterIndex = #self.cfgData end

        self.data = self.cfgData[self.chapterIndex]
        self.itemIndex  = #self.data
        chapterName:setString( self.data[1].q_chapter_name )

        self:getTableView():reloadData()
        lastItem()
        btnShow()

        self:refreshRight()

    end

    leftBtn = createMenuItem( self , "res/component/button/chapter.png" , cc.p( 65 + 10 , 520 - 4 ) , function() changeIndex( -1 ) end )
    local preText =  createLabel( leftBtn , game.getStrByKey( "pre_chapter" )  , getCenterPos( leftBtn ), cc.p( 0.5 , 0.5 ) , 16 , nil , nil , nil , MColor.lable_yellow , nil , nil , MColor.black , 2 )
    leftBtn:setRotation( 180 )
    preText:setRotation( 180 )

    rightBtn = createMenuItem( self , "res/component/button/chapter.png" , cc.p( 314 + 8  , 520 - 4 ) , function() changeIndex( 1 ) end )
    createLabel( rightBtn , game.getStrByKey( "next_chapter" )  , getCenterPos( rightBtn ), cc.p( 0.5 , 0.5 ) , 16 , nil , nil , nil , MColor.lable_yellow , nil , nil , MColor.black , 2 )

    btnShow()



    lastItem()

    --右侧信息
    self.viewLayer = cc.Node:create()
    setNodeAttr( self.viewLayer , cc.p( 356 , 18 ) , cc.p( 0 , 0 ) )
    self:addChild( self.viewLayer )
    self:refreshRight()

end




function M:gotoTarget( tempData )
    if tempData.finished ~= 1  then
      DATA_Mission:getParent():remove() 
      DATA_Mission:setParent( nil )
      __TASK:findPath( tempData )
    else
      --等级不足
    end
end

--右侧面板
function M:refreshRight()
    if self.viewLayer then self.viewLayer:removeAllChildren() end
    local node = self.viewLayer

    local tempData = self.data[self.itemIndex]
    createLabel( node ,  game.getStrByKey( "desc_text" ) , cc.p( 40 , 360 + 25 ) , cc.p( 0 , 1 ) , 20 , nil , nil , nil , MColor.brown  )
--    local descText = createLabel( node ,  tempData.q_task_desc or "" , cc.p( 40 , 330 + 25 ) , cc.p( 0 , 1 ) , 20 , nil , nil , nil , MColor.black  )
--    descText:setDimensions(500,0)

    -- function RichText:ctor(parent, pos, size, anchor, lineHeight, fontSize, fontColor, tag, zOrder, isIgnoreHeight)
    descText = require("src/RichText").new( node , cc.p( 40 , 330 + 25 ) , cc.size( 500 , 0 ) , cc.p( 0 , 1 ) , 20 , 20 , MColor.black );
    descText:setAutoWidth();


    --前往
    local goBtn = createMenuItem( node , "res/component/button/50.png" , cc.p( 590/2 , 50 + 10 ) , function()  self:gotoTarget( tempData ) end )
    createLabel( goBtn , game.getStrByKey("go")  , getCenterPos(goBtn)  , cc.p( 0.5 , 0.5 ) , 24 , true )

    local iconGroup = __createAwardGroup( tempData.awrds )
    setNodeAttr( iconGroup , cc.p( 306 , 130 + 20 ) , cc.p( 0.5 , 0.5 ) )
    node:addChild( iconGroup )


    --创建任务目标
    local targetData = tempData.targetData
    local finishedType = tempData.finished   --任务进行类型
    local isShowGoBtn = ( finishedType == 2 or finishedType == 3 and true or false )              --是否显示前往按钮

    if tempData.q_done_event and tonumber( tempData.q_done_event ) ~= 0 then
        createLabel( node ,  game.getStrByKey("task_kill") , cc.p( 30 , 430 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.brown )
        createLabel( node ,  tempData.q_name , cc.p( 110 , 430 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.black )

        local tagStr = tempData.q_task_desc 
        if tempData.q_speakID and tagStr == "" then
            tagStr = getConfigItemByKey( "NPCSpeak" , "q_id" )[ tempData.q_speakID ]["q_task_done"] 
        end
        if tempData.q_word then
            tagStr = tempData.q_word
        end


        descText:addText(tagStr or "");
	    descText:format();
    else
        descText:addText(tempData.q_task_desc or "");
	    descText:format();

        if tempData.targetType == 1 then
            createLabel( node ,  "【" .. game.getStrByKey("task_talk") .. "】" , cc.p( 30 , 430 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.brown )
            createLabel( node ,  targetData.roleName , cc.p( 110 , 430 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.black )
            if tempData.finished == 4 then  --完成显示  回复内容
                createLabel( node ,  game.getStrByKey("task_answer") , cc.p( 40 , 390 + 5 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.brown )
                createLabel( node ,  targetData.replyName , cc.p( 100 , 390 + 5 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.black )
            end
        elseif tempData.targetType == 2 then
            createLabel( node ,  "【" .. game.getStrByKey("task_collect") .. "】"  , cc.p( 30 , 430 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.brown )
            local nameText = createLabel( node ,  targetData.roleName , cc.p( 110 , 430 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.black )
            createLabel( node ,  "(" .. targetData.cur_num .. "/" ..  targetData.count .. ")" , cc.p( 100 + nameText:getContentSize().width + 20 , 430 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.red )
            if finishedType == 6 then
                isShowGoBtn = true
                createLabel( node ,  game.getStrByKey("task_answer") , cc.p( 40 , 390 + 5 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.brown )
                createLabel( node ,  targetData.replyName , cc.p( 100 , 390 + 5 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.black )
            end

        elseif tempData.targetType == 3 then
            createLabel( node ,  "【" .. game.getStrByKey("task_kill") .. "】" , cc.p( 30 , 430 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.brown )
            local nameText = createLabel( node , targetData.roleName or "" , cc.p( 110 , 430 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.black )
            createLabel( node ,  "(" .. targetData.cur_num .. "/" ..  targetData.count .. ")" , cc.p( 110 + nameText:getContentSize().width + 20 , 430 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.red )
            if tempData.finished == 6  then  --完成显示  回复内容
                isShowGoBtn = true
                createLabel( node ,  game.getStrByKey("task_answer") , cc.p( 40 , 390 + 5 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.brown )
                createLabel( node ,   getConfigItemByKey( "NPC" , "q_id" , tempData.isBan and tempData.q_startnpc or  tempData.q_endnpc , "q_name")  , cc.p( 100 , 390 + 5 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.black )
            end
        end
    end
    goBtn:setVisible( isShowGoBtn )
end






function M:tableCellTouched(table,cell)
    if self.itemIndex == cell:getIdx()+1  then return end
    local oldCell = self:getTableView():cellAtIndex( self.itemIndex - 1 )
    if oldCell and oldCell.activtyLayer then oldCell.activtyLayer:removeAllChildren() end
    self.itemIndex = cell:getIdx()+1
    self:refreshRight()
    createScale9Sprite( cell.activtyLayer , "res/common/scalable/item_sel.png", cc.p( 357/2 , 0 ), cc.size(327 , 61 ) , cc.p( 0.5 , 0 ) )
end

function M:cellSizeForTable(table,idx) 
    return 65 , 361 
end

function M:numberOfCellsInTableView(table)
    return tablenums( self.data )
end

function M:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local index = idx + 1 
    local curData = self.data[index]

    -- 1 等级不够 2进行中 3可交付 4 完成 
    local stateColor = { MColor.orange , MColor.red ,  MColor.yellow , MColor.green , nil ,  MColor.yellow  }
    local stateStr = curData.finished == 1 and string.format( game.getStrByKey( "task_finish" .. curData.finished )  , curData.q_accept_needmingrade )  or game.getStrByKey( "task_finish" .. curData.finished )

    -- if curData.q_done_event and tonumber( curData.q_done_event ) ~= 0  then
    --     if curData.finished ~= 4 then
    --         stateStr = game.getStrByKey( "task_finish2" )
    --     else
    --         stateStr = game.getStrByKey( "task_finish4" )
    --     end
    -- end
    
    local itemColor = stateColor[ curData.finished ]
    if curData.q_accept_needmingrade then
        local MRoleStruct = require("src/layers/role/RoleStruct")
        if MRoleStruct:getAttr(ROLE_LEVEL) and MRoleStruct:getAttr(ROLE_LEVEL) < tonumber(curData.q_accept_needmingrade)  then
            stateStr = curData.q_accept_needmingrade .. game.getStrByKey( "ji" )
            itemColor = MColor.red   
        end
    end


    if cell == nil  then
        cell = cc.TableViewCell:new()
    else
        cell:removeAllChildren()
    end

    local bg = createScale9Sprite( cell , "res/common/scalable/item.png", cc.p( 357/2 , 0 ), cc.size(327 , 61 ) , cc.p( 0.5 , 0 ) )
    local bgSize = bg:getContentSize()
    createLabel( cell , curData.q_name , cc.p( 40 , bgSize.height/2 ) , cc.p( 0 , 0.5 ) , 20 , nil , 20 , nil , MColor.lable_yellow , nil , nil )
    createLabel( cell , stateStr , cc.p( 239 , bgSize.height/2 ) , cc.p( 0 , 0.5 ) , 20 , nil , 20 , nil , itemColor , nil , nil)
    cell.activtyLayer = cc.Node:create()
    cell:addChild( cell.activtyLayer )

    if self.itemIndex == index then createScale9Sprite( cell.activtyLayer , "res/common/scalable/item_sel.png", cc.p( 357/2 , 0 ), cc.size(327 , 61 ) , cc.p( 0.5 , 0 ) ) end

    return cell
end



return M