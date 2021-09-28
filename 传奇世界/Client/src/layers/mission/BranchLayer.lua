--[[ 密令任务界面 ]]--
local M = class("BranchLayer", require("src/TabViewLayer") )
local function createTag( itemData )

    local tempData = {}
    if itemData.isHistory  then
        tempData = __NpcAddr( itemData.q_endnpc )        
        tempData.targetType = 1
        tempData.q_endnpc = itemData.q_endnpc
    elseif itemData.isRuning then
        --正常查找
        tempData = itemData
    else
        --查找startNPC
        tempData = __NpcAddr( itemData.q_startnpc )
        tempData.targetType = 1
        tempData.q_endnpc = itemData.q_endnpc
    end
    return tempData
end

function M:getData()
    local data = DATA_Mission:getBranchData()
    local historyList = nil
    local cellList = nil

    --排序显示
    if data["history"] then
    	historyList = copyTable( data["history"] )
    	table.sort( historyList , function( a , b ) return a.q_taskid < b.q_taskid end)
    end

    if data["list"] then
    	cellList = copyTable( data["list"] )
    	table.sort( cellList , function( a , b ) return a.q_taskid < b.q_taskid end)
    end    


    local tempData = { cell = {} }
    tempData.historyNum = #historyList
    if tempData.historyNum>0 then
        for i = 1 , #historyList do
            tempData["cell"][i] = historyList[i]
            tempData["cell"][i]["isHistory"] = true
        end
    end

    for i = 1 , #cellList do
        tempData["cell"][tempData.historyNum+i] = cellList[i]
    end
    
    self.itemIndex = #tempData["cell"]


    return tempData 
end
function M:ctor( parent )
    parent:addChild(self)
    self.data = self:getData()

    self:init()

end

function M:init()   
    self.selectIdx = #self.data["cell"] - 1


    local bg = createScale9Frame(
        self,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(32, 38),
        cc.size(332,502),
        5
    )

    local bg = createScale9Frame(
        self,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(370, 38),
        cc.size(558,502),
        5
    )
    createSprite( bg ,"res/common/bg/bg66-1.jpg" , getCenterPos( bg ) ,  cc.p( 0.5 , 0.5 ) )
    local config = {{  text = "task_target" , y = 330 } , {  text = "task_reward" , y = 70 } , }
    for i = 1 , #config do
        local titleSp = createSprite( bg , "res/common/bg/titleLine.png" , cc.p(  590/2 - 15 , config[i].y + 115) ,  cc.p( 0.5 , 0 )  )
        createLabel( titleSp , game.getStrByKey( config[i].text )  , getCenterPos( titleSp ), cc.p( 0.5 , 0.5 ) , 22 , nil , nil , nil , MColor.lable_yellow , nil , nil , MColor.black , 2 )
    end


	self.rightLayer = self:createRight()
	setNodeAttr( self.rightLayer , cc.p( 356 , 18 ) , cc.p( 0 , 0 ) )
	self:addChild( self.rightLayer )

    -- self.callBackFunc = function(idx)
    --     --更新右侧界面
    --     self.rightLayer:refreshData( self.data["cell"][ self.selectIdx + 1 ]  )
    -- end

    -- self.normal_img = "res/component/button/52.png"
    -- self.select_img = "res/component/button/52_sel.png"

    self:createTableView(self , cc.size( 361 - 15 , 470 + 20 ), cc.p(25 + 10 , 30 + 15), true , true )



	DATA_Mission:setCallback( "branch_refresh" , function() self:refreshDataFun() end)
	self:refreshDataFun()
end


function M:refreshDataFun()
	self.data = self:getData()
    self:getTableView():reloadData()
	if #self.data["cell"] > 7 then
		--设置偏移量
		self:getTableView():setContentOffset( self:getTableView():maxContainerOffset() )
	end
    self.rightLayer:refreshData( self.data["cell"][ self.selectIdx + 1 ] )
end

function M:clearFun()
	DATA_Mission:setCallback( "branch_refresh" , nil)
end


function M:gotoTarget( tempData )
	self:clearFun()   --必须先执行些函数，否则父层移除后，执行此函数无效，再次进入会报错
	DATA_Mission:getParent():remove() 
	DATA_Mission:setParent( nil )

	tempData = createTag( tempData )

	__TASK:findPath( tempData )
end



function M:createRight() 
local node = cc.Node:create()



	local width , height = 520 , 545
	node:setContentSize( cc.size( width , height ) )



	local txtCfg = {   
						-- game.getStrByKey("taskAccept") .. "NPC:" ,  
						game.getStrByKey("taskSubmit") .. "NPC:" , 
						game.getStrByKey("task_target") .. ":"  
					}
	for  i = 1 , #txtCfg do
		createLabel( node ,  txtCfg[i] , cc.p( 40 , 470 - i * 40  ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.brown  ) 
	end

	createLabel( node ,  game.getStrByKey("desc_text") , cc.p( 40 , 330 + 20) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.brown  ) 

	-- local acceptName = createLabel( node ,  "" , cc.p( 135 , 470 - 1 * 35 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.brown  ) 
	local submitName = createLabel( node ,  "" , cc.p( 135 , 470 - 1 * 40 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.black  ) 

	--local desc = createLabel( node ,  "" , cc.p( 40 , 327  + 20 ) , cc.p( 0 , 1 ) , 20 , nil , nil , nil , MColor.black  ) 
	--desc:setDimensions( 460,0  )

	local refreshLayer = cc.Node:create()
	node:addChild( refreshLayer )
	
	-- local MPackStruct = require "src/layers/bag/PackStruct"
	-- local MPackManager = require "src/layers/bag/PackManager"
	-- local pack = MPackManager:getPack(MPackStruct.eBag)
	-- local count = pack:countByProtoId(1001)
	-- local shoesIcon = iconCell( { 
	-- 								parent = node , iconID = 1001 , num = { value = count } ,
	-- 								callback = function()
	-- 									if node.data.q_done_event and node.data.q_done_event ~= "0" then
	-- 										self:gotoTarget( node.data )
	-- 									else
	-- 										local tempGotoData = {}
	-- 										for key , v in pairs( node.data ) do
	-- 											tempGotoData[ key ] = v 
	-- 										end

	-- 										--转换寻路类型
	-- 										tempGotoData = createTag( tempGotoData )

	-- 										tempGotoData.remvoeFun = function()
	-- 											self:clearFun()  
	-- 											DATA_Mission:getParent():remove() 
	-- 											DATA_Mission:setParent( nil )
	-- 										end 

	-- 										__TASK:portalGo( tempGotoData , true , true ) 
	-- 									end
	-- 								end 
	-- 							} )
	-- setNodeAttr( shoesIcon , cc.p( 467 , 429 ) , cc.p( 0.5 , 0.5 ) )

	local goBtn = createMenuItem( node , "res/component/button/50.png" , cc.p( 590/2  , 50 + 10 ) , function()  self:gotoTarget( node.data ) end )
	createLabel( goBtn , game.getStrByKey("go")  , getCenterPos(goBtn)  , cc.p( 0.5 , 0.5 ) , 24 , true )
	G_TUTO_NODE:setTouchNode(goBtn, TOUCH_TASK_BRANCH_GO)


	function node:refreshData( tempData )
		node.data = tempData

		-- acceptName:setString( getConfigItemByKey( "NPC" , "q_id" , tempData.q_startnpc  , "q_name" )  )
		submitName:setString( getConfigItemByKey( "NPC" , "q_id" , tempData.q_endnpc  , "q_name" ) )
		--desc:setString( tempData.desc )
		if refreshLayer then refreshLayer:removeAllChildren() end

        -- 密令任务 描述 支持格式
        descText = require("src/RichText").new( refreshLayer , cc.p( 40 , 327  + 20 ) , cc.size( 460 , 0 ) , cc.p( 0 , 1 ) , 20 , 20 , MColor.black );
        descText:setAutoWidth();
        descText:addText(tempData.desc or "");
	    descText:format();

	    local iconGroup = __createAwardGroup( tempData.awrds )
	    setNodeAttr( iconGroup , cc.p( 306 , 130  + 20 ) , cc.p( 0.5 , 0.5 ) )
	    refreshLayer:addChild( iconGroup )

	    local str = ""
		if tempData.q_done_event and tonumber(tempData.q_done_event) == 0 then
			if tempData.isHistory  then
				tempData.targetData.cur_num = tempData.targetData.count
			end

			str = tempData.targetData.roleName 
			
			if tempData.targetData.cur_num then
				str = str .. "   " .. ( tempData.targetData.cur_num >= tempData.targetData.count and "^c(green)" or "^c(red)" ) ..  "(" .. tempData.targetData.cur_num
				str = str .. "/" .. tempData.targetData.count .. ")^" 
			end
		else
	 		str = "^c(blue)" .. tempData.q_desc .. "^"
		end
		goBtn:setVisible( not ( tempData.isHistory ) )
        local richText = require("src/RichText").new( refreshLayer , cc.p( 135 , 470 - 2 * 40 + 14 ) , cc.size( 400 , 0 ) , cc.p( 0 , 0.5 ) , 28 , 20 , MColor.white )
	    richText:addText(  str , MColor.black , true )
	    richText:format()

	end

	return node

end
function M:tableCellTouched(table,cell)
    if self.itemIndex == cell:getIdx()+1  then return end
    local oldCell = self:getTableView():cellAtIndex( self.itemIndex - 1 )
    if oldCell and oldCell.activtyLayer then oldCell.activtyLayer:removeAllChildren() end
    self.itemIndex = cell:getIdx()+1
    self.rightLayer:refreshData( self.data["cell"][ self.itemIndex ]  )
    createScale9Sprite( cell.activtyLayer , "res/common/scalable/item_sel.png", cc.p( 327/2 , 0 ), cc.size(327 , 61 ) , cc.p( 0.5 , 0 ) )
    
end

function M:tableCellAtIndex( table , idx )
    local cell = table:dequeueCell()
    local index = idx + 1 
    if nil == cell then
        cell = cc.TableViewCell:new()   
    else
        cell:removeAllChildren()
    end
    local curData = self.data.cell[ index ]



    local bg = createScale9Sprite( cell , "res/common/scalable/item.png", cc.p( 327/2 , 0 ), cc.size(327 , 61 ) , cc.p( 0.5 , 0 ) )
    local size = bg:getContentSize()
    createLabel( cell , curData.name , cc.p( 40 , size.height/2 ) , cc.p( 0 , 0.5 ) , 20 , nil , 20 , nil , MColor.lable_yellow , nil , nil )

    local stateStr = game.getStrByKey( "task_finish5" )
    local color = MColor.yellow
    if curData.isHistory  then
        stateStr = game.getStrByKey( "task_finish4" )
        color = MColor.green
    elseif curData.isRuning then
        if curData.finished == 3 then
            color = MColor.yellow
            stateStr = game.getStrByKey( "task_finish6" )
        else
            color = MColor.red
            stateStr = game.getStrByKey( "task_finish2" )
        end
        
    end

    createLabel( cell , stateStr , cc.p( 239 , size.height/2 ) , cc.p( 0 , 0.5 ) , 20 , nil , 20 , nil , color  , nil , nil)

    cell.activtyLayer = cc.Node:create()
    cell:addChild( cell.activtyLayer )

    if self.itemIndex == index then createScale9Sprite( cell.activtyLayer , "res/common/scalable/item_sel.png", cc.p( 327/2 , 0 ), cc.size(327 , 61 ) , cc.p( 0.5 , 0 ) ) end


    return cell
end

function M:cellSizeForTable(table,idx) 
	return 65 , 361 
end

function M:numberOfCellsInTableView(table)
    return #self.data["cell"]
end

--检查是否展示密令接取动画
function M:showFirstEff( taskid )
    --保证播放一次
    local recordid = tonumber( getLocalRecordByKey( 2 , "miling_action" .. tostring( userInfo.currRoleStaticId  )  ) )
    if recordid == taskid then return end
    setLocalRecordByKey( 2 , "miling_action" ..  tostring( userInfo.currRoleStaticId )  , tostring(taskid) )



	local isShow = false
	
    local cfg = getConfigItemByKeys( "BranchDB" , "q_taskid" )
    local itmeData = cfg[ taskid ]
    if itmeData and itmeData["q_item"] then
        local ids = {}
        for k , v in pairs( cfg ) do 
            if v.q_item and v.q_item == itmeData.q_item then
                table.insert( ids , v.q_taskid )
            end
        end

        table.sort( ids , function( a , b ) return a < b  end )
        if #ids>0 then
            if taskid == ids[1] then
                isShow = true
            end
        end
    end


    if isShow == false then return end




    local node = cc.Node:create()
    setNodeAttr( node , cc.p(display.cx,display.cy) , cc.p( 0.5 , 0.5 ) )

    local closeFun = function()
        if node then
            removeFromParent( node )
            node = nil 
        end
    end
    registerOutsideCloseFunc( node , closeFun , true , true )

    local halfOfRollDis = 440
    local rollTime = 1
    local rollAction = cc.MoveBy:create(rollTime,cc.p(halfOfRollDis*2,0))

    local clipNode = cc.ClippingNode:create()
    node:addChild(clipNode)

    local stencil1 = cc.Sprite:create( "res/layers/mission/mi_bg.png" )
    setNodeAttr( stencil1 , cc.p( 0 , 0 ) , cc.p( 0.5 , 0.5) )
    stencil1:runAction(rollAction)    
    clipNode:setStencil(stencil1)
    clipNode:setInverted(true)
    clipNode:setAlphaThreshold(0)

    local zhouLeft = createSprite( node , "res/jieyi/zhou.png",cc.p(-halfOfRollDis,0))
    local zhouRight = createSprite( node , "res/jieyi/zhou.png",cc.p(-halfOfRollDis,0))
    zhouRight:setFlippedX(true)
    zhouRight:runAction( rollAction:clone() )


    local bg = createSprite( clipNode , "res/layers/mission/mi_bg.png" , cc.p( 0 , 0 ) )
    createLabel( bg , "-" ..  game.getStrByKey("achievement_touch_close") .. "-" , cc.p(bg:getContentSize().width/2, 30 ), cc.p(0.5, 0.5 ), 20, true, nil, nil, MColor.brown )

    local successSp = createSprite( bg , "res/layers/mission/mi_success.png" , cc.p( bg:getContentSize().width/2 , bg:getContentSize().height/2 ) , cc.p( 0.5 , 0.5 ) )
    successSp:setScale( 0.0 )

    local actions = {}
    actions[ #actions + 1 ] = cc.DelayTime:create( rollTime )
    actions[ #actions + 1 ] = cc.Spawn:create( cc.EaseBackInOut:create( cc.ScaleTo:create( 0.3  , 1 ) ) , cc.MoveTo:create( 0.3 , getCenterPos( bg ) )  ) 
    actions[ #actions + 1 ] = cc.DelayTime:create( 5 )--五秒钟后消失
    actions[ #actions + 1 ] = cc.CallFunc:create( closeFun )
    successSp:runAction( cc.Sequence:create( actions ) )
    

    -- node:registerScriptHandler(function(event)
    --     if event == "enter" then
    --     elseif event == "exit" then
    --         closeFun()
    --     end
    -- end)
    
    getRunScene():addChild( node , 200 )
end

--检查是否是最后一个光翼任务
function M:checkWingLast( taskid )
    --保证播放一次
    local recordid = tonumber( getLocalRecordByKey( 2 , "miling_wing_last" .. tostring( userInfo.currRoleStaticId  )  ) )
    if recordid == taskid then return false end
    setLocalRecordByKey( 2 , "miling_wing_last" ..  tostring( userInfo.currRoleStaticId )  , tostring(taskid) )



    local isShow = false
    
    local cfg = getConfigItemByKeys( "BranchDB" , "q_taskid" )
    local itmeData = cfg[ taskid ]

    if itmeData and itmeData["q_type"]  and itmeData["q_type"] == 2 then
        local ids = {}
        for k , v in pairs( cfg ) do 
            if v.q_type and v.q_type == itmeData.q_type then
                table.insert( ids , v.q_taskid )
            end
        end

        table.sort( ids , function( a , b ) return a < b  end )

        if #ids>0 then
            if taskid == ids[ #ids ] then
                isShow = true
            end
        end
    end
    if isShow == false then return false end

    return isShow
end

return M