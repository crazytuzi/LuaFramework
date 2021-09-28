--[[ 日常任务界面 ]]--
local M = class( "EVERYDAYLAYER" , function() return cc.Node:create() end )  --剧情
local data = nil
local ITEMLIST = class( "EVERYDAYLAYER" , require( "src/TabViewLayer" ) )  --章节列表
local itemIndex = 0
function M:ctor(parent)
  data = DATA_Mission:getEveryData()

  parent:addChild(self)

  local itemLayer = cc.Node:create()
  self:addChild( itemLayer )

  local rightLayer = self:createRight()
  setNodeAttr( rightLayer , cc.p( 356 , 18 ) , cc.p( 0 , 0 ) )
  self:addChild( rightLayer )

  local function mainRefreshData(over_every)
	data = DATA_Mission:getEveryData()
	if over_every and DATA_Mission:getParent() then DATA_Mission:getParent():refreshData( 2 ) return end --做完当天15个日常任务 就关闭日常任务
	itemIndex = data.turnNum
	
	if itemLayer and tolua.cast( itemLayer , "cc.Node" ) then
		
		itemLayer:removeAllChildren()
		itemList = ITEMLIST.new( itemLayer )

		rightLayer:refreshData()
	end

  end
  mainRefreshData()

  DATA_Mission:setCallback( "every_refresh" , function(over_every) mainRefreshData(over_every) end)

  --G_TUTO_NODE:setShowNode(root, SHOW_TASK)
end

function M:clearFun()
	DATA_Mission:setCallback( "every_refresh" , nil)
end


function M:gotoTarget( tempData )
	if tempData.finished ~= 1  then
	  self:clearFun()   --必须先执行些函数，否则父层移除后，执行此函数无效，再次进入会报错
	  DATA_Mission:getParent():remove() 
	  DATA_Mission:setParent( nil )
	  __TASK:findPath( tempData )
	else
	  --等级不足
	end
end


function M:createRight()
  	local node = cc.Node:create()

	local bg = createScale9Frame(
        self,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(370, 38),
        cc.size(558,502),
        5
    )
	createSprite( bg ,"res/common/bg/bg66-1.jpg" , getCenterPos( bg ) ,  cc.p( 0.5 , 0.5 ) )
	createSprite( bg ,"res/common/bg/line1.png" , cc.p( bg:getContentSize().width/2 , 110 ) ,  cc.p( 0.5 , 0.5 ) )



	local config = {{  text = "task_target" , y = 330 } , {  text = "task_reward" , y = 190 } , }
	for i = 1 , #config do
	local titleSp = createSprite( bg , "res/common/bg/titleLine.png" , cc.p(  590/2 - 15 , config[i].y + 115) ,  cc.p( 0.5 , 0 )  )
	createLabel( titleSp , game.getStrByKey( config[i].text )  , getCenterPos( titleSp ), cc.p( 0.5 , 0.5 ) , 22 , nil , nil , nil , MColor.lable_yellow , nil , nil , MColor.black , 2 )
	end



	local width , height = 520 , 545
	node:setContentSize( cc.size( width , height ) )

	createLabel( node ,  "【" .. game.getStrByKey("task_kill") .. "】", cc.p( 17 + 13 , 445 - 15 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.brown  ) 
	local strKillNum = ""
	local strKillName = ""
	local strMapLabel = ""
	local strmapName = ""
	if data.q_done_event and tonumber(data.q_done_event) == 0 then
	  strKillName = data.targetData.name
	  strMapLabel = game.getStrByKey("task_d_m")
	  strmapName = "【" .. ( data.targetData.q_map_name or "" )    .. "】"
	  strKillNum = "(" ..  data.targetData.cur_num .. "/" .. data.targetData.count .. ")"
	else
	  local str = nil
	  if data.extern and data.extern.type == 29 then

			local propOp = require("src/config/propOp")
			local tNameColor = {
			[0] = colors.red,
			[1] = colors.white,
			[2] = colors.green,
			[3] = colors.blue,
			[4] = colors.purple,
			[5] = colors.orange,
		  }

		  local func = function()
			  local Mtips = require "src/layers/bag/tips"
			  Mtips.new(
			  { 
				protoId = tonumber(data.extern.id),
				--grid = gird,
				pos = cc.p(0, 0),
				--actions = actions,
			  })
		  end
		  local itemData = getConfigItemByKeys("propCfg" , "q_id")[ data.extern.id]
		  local quality = 2
		  if itemData then quality = itemData["q_default"] end
		  local obj,line = createLinkLabel(shadow, game.getStrByKey("miss_find") .. "【"..data.extern.name.."】", cc.p( 240 , 60 ), cc.p(0.0,0), 20, nil,nil,tNameColor[2],nil,func,true)
		  obj:setLocalZOrder(1)
		  obj:setTag(1001)
		  line:setLocalZOrder(1)
		  line:setTag(1001)
		  --str = string.format(game.getStrByKey("miss_find"), data.extern.name)  --.. "(" .. data.extern.cur_num .. "/" ..data.extern.num .. ")"
		  strKillNum = "(" ..  data.extern.cur_num .. "/" .. data.extern.num .. ")" 
	  else
		  strKillName = data.desc
	  end
	end
	local monsterName = createLabel( node ,  strKillName, cc.p( 120 , 445 - 15 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.black  ) 
	local killNum = createLabel(node, strKillNum, cc.p( 154 + monsterName:getContentSize().width   , 445  - 15 ), cc.p(0 , 0), 20, nil, nil, nil, MColor.green) 
	local mapLabel = createLabel( node ,   strMapLabel, cc.p( 25 + 13 , 410 - 20 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.brown ) 
	local mapName = createLabel( node ,  strmapName, cc.p( 110 + 13  , 410 - 20 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.black  ) 
	createLabel( node ,  game.getStrByKey( "task_d_b6" ) , cc.p( 40 , 330 - 50 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.brown )

	local rewardLv = data.rewardCfg["q_starLevel"] 


	--花费10元完成当前任务
	local isPass = false
	local isOver = false
	local overTaskBtn = nil
	local text = nil 
	if not G_NO_OPEN_PAY then
		overTaskBtn = createMenuItem( node , "res/component/button/50.png"  ,  cc.p( width/4*3 + 35  , 65 ) , function()  
				if not isOver then
					g_msgHandlerInst:sendNetDataByTableExEx(TASK_CS_YUANBAO_FINISH_DAILY_TASK, "YuanbaoFinishDailyTaskProtocol", { finishType = 1 } )
				end
			end )
		createLabel( overTaskBtn , game.getStrByKey("over_task11")  ,  getCenterPos( overTaskBtn )  , cc.p( 0.5 , 0.5 ) , 24 , true  )

		local isOverLogin = not data.isOverLogin
		
		if isOverLogin then
			local str = string.format( game.getStrByKey("over_task12") , data.curCost , numToFatString( data.expNum ) )
			if data.overEvery then str = "" end
			text = createLabel( node , str ,  cc.p( width/4*3 + 35 - 133 , 110  ), cc.p( 0.5 , 0.5 ) , 18 , nil , nil , nil , MColor.black )
		end
	end
	


	local isComplete = data.targetData.cur_num < data.targetData.count 
	local function clickFun()
		if isComplete then
			self:gotoTarget( data )
	        __removeAllLayers() 
		else
			g_msgHandlerInst:sendNetDataByTableExEx(TASK_CS_PICK_DAILY_REWARD, "PickDailyRewardProtocol", { curLoop = data.turnNum } )
			if TOPBTNMG then TOPBTNMG:showRedMG( "Every" ,  false  ) end
		end
	end

	local goBtn = createMenuItem( node , "res/component/button/50.png" , cc.p( width/( G_NO_OPEN_PAY and 2 or 4 ) + 35 , 65 ) , clickFun )
	local goBtnText =  createLabel( goBtn , game.getStrByKey( isComplete and "go"  or "finish_task" )  , getCenterPos(goBtn)  , cc.p( 0.5 , 0.5 ) , 24 , true )

	local function upFun()
					local halderFun = function()
						g_msgHandlerInst:sendNetDataByTableExEx(TASK_CS_UP_REWARD_STAR, "UpRewardStarProtocol", {} ) 
					end
					if DATA_Mission.no_tip_need_gold then
						halderFun()
					else
				    	local tempLayer = MessageBoxYesNo(nil,game.getStrByKey("every_tip2") , halderFun ,nil)

				    	local no_selectBtn , selectBtn

				    	local function selectFun( value )
				    		if value then
				    			DATA_Mission.no_tip_need_gold = true
				    		else
				    			DATA_Mission.no_tip_need_gold = nil
				    		end
				    		selectBtn:setVisible( value  )
						end

				    	no_selectBtn = createMenuItem( tempLayer , "res/component/checkbox/1.png" , cc.p( 170 , 40 + 70 ) , function() selectFun( true ) end )
				    	selectBtn = createMenuItem( tempLayer , "res/component/checkbox/1-1.png" , cc.p( 170 , 40 + 70 ) , function() selectFun( false ) end )
				    	createLabel( tempLayer , game.getStrByKey("ping_btn_no_more")  , cc.p(195 , 40 + 70 ) , cc.p( 0 , 0.5 ) , 20 , true , nil , nil , MColor.yellow_gray , nil , nil , MColor.black , 3 )
						selectBtn:setVisible( false ) 
					end
	end
	local upBtn = createMenuItem( node , "res/component/button/48.png" ,  cc.p( width/2 + 240 , 293 ) , upFun )
	createLabel( upBtn , game.getStrByKey("task_every_up")  , 	getCenterPos( upBtn )  , cc.p( 0.5 , 0.5 ) , 24 , true )

	local upText = createLabel( node , ""  , cc.p( width/2 + 70 , 330 - 50 )  , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.yellow )

	G_TUTO_NODE:setTouchNode(upBtn, TOUCH_TASK_UP)

	local rewardLayer = cc.Node:create()
	node:addChild( rewardLayer )
	local spaceX = 90

	function node:refreshData()
		isComplete = data.targetData.cur_num < data.targetData.count

		goBtnText:setString( game.getStrByKey( isComplete and "go"  or "finish_task" ) )

		if data.q_done_event and tonumber(data.q_done_event) == 0 then

		  strKillName = data.targetData.name
		  strMapLabel = game.getStrByKey("task_d_m")
		  strmapName = "【" .. data.targetData.q_map_name    .. "】"
		  strKillNum = "(" ..  data.targetData.cur_num .. "/" .. data.targetData.count .. ")"          
		  killNum:setString( strKillNum )
		  monsterName:setString(strKillName)
		  mapLabel:setString(strMapLabel)
		  mapName:setString(strmapName)
		  killNum:setPositionX(270 -136 + monsterName:getContentSize().width + 20)
		else
		  killNum:setString("")
		  monsterName:setString(data.desc)
		  mapLabel:setString("")
		  mapName:setString("")
		  if data.extern and data.extern.type == 29 then
			killNum:setString( "(" ..  data.extern.cur_num .. "/" .. data.extern.num .. ")" )
		  end
		end
		
		if rewardLayer then rewardLayer:removeAllChildren() end

		local TASK_DAILY_PRIZE_RATE = {1,1.06,1.12,1.19,1.26,1.34,1.42,1.51,1.6,1.7,1.8,1.91,2.02,2.14,2.27}
		local awards = copyTable( data.reward )
		for i , v in ipairs(  awards  ) do
			if v.id == 444444 then
				v.num = v.num * TASK_DAILY_PRIZE_RATE[ data.turnNum ]
				break
			end
		end

	    local iconGroup = __createAwardGroup( awards )
	    setNodeAttr( iconGroup , cc.p( 305 , 200 ) , cc.p( 0.5 , 0.5 ) )
	    rewardLayer:addChild( iconGroup )

	    upText:setString( string.format( game.getStrByKey( "over_task10" ) , data.rewardCfg["q_addPre"]*200 ) )
		upBtn:setVisible( data.rewardCfg.q_starLevel~= 5 ) --5级时隐去升级

		local rewardLv = data.rewardCfg["q_starLevel"] 
		for i = 1 , 5 do
			local starSp = createSprite( rewardLayer , "res/group/star/s" .. ( i<=rewardLv and 4 or 3 ) .. ".png" , cc.p( 170 + ( i - 1 ) * 35 , 328 - 50  ) , cc.p( 0 , 0 ))
			starSp:setScale( 0.8 )
		end


		if data.overEvery then
			isOver = true
			upBtn:setVisible( false ) --5级时隐去升级
			goBtn:setVisible( false )
			if not G_NO_OPEN_PAY then overTaskBtn:setVisible( false ) end
		end

		local str = ""
		if data.overEvery then 
			str = "" 
		else
			str = string.format( game.getStrByKey("over_task12") , data.curCost , numToFatString( data.expNum ) )
		end
		if text then
			text:setString( str )
		end
		

	end

	return node
end





function ITEMLIST:helpFun()
	local width , height = 420 , 400
	local node = popupBox({ 
						 bg = "res/common/helpBg.png" , 
						 createScale9Sprite = { size = cc.size( width , height ) } ,
						 zorder = 200 ,
						 isHalf = true , 
						 actionType = 7 ,
					   })

	
	node:setContentSize( cc.size( width , height ) )

	local extraReward = data.extraReward

	local spaceX = 90
	for i = 1 , #extraReward do
		local iconBtn = iconCell( { parent = node , isTip = true , num = { value = extraReward[i]["num"] } ,iconID = extraReward[i]["id"] , allData = ( extraReward[i]["streng"] and { streng = extraReward[i]["streng"] } or nil ) } )
		local addX = width/2 - #extraReward/ 2 * spaceX +  ( i - 1 ) * spaceX + spaceX/2-20
		setNodeAttr( iconBtn , cc.p( addX , 306 - 20 ) , cc.p( 0.5 , 0.5 ) )
	end
	
	--vip等级 跟 接取任务数目提示
	local taskNum = __TASK:getEveryNum()

	local textCfg = {
					  { str = game.getStrByKey("overEvery15") , color = MColor.brown_gray , fontSize = 20 , y = 376   } ,
					  { str = game.getStrByKey( "task_d_ts" ) , color = MColor.brown_gray , fontSize = 20 , y  =206 } ,
					}
	for i = 1 , #textCfg do
		createLabel( node ,  textCfg[i].str , cc.p( 25 , textCfg[i].y ) , cc.p( 0 , 1 ) , textCfg[i].fontSize , nil , nil , nil , textCfg[i].color , nil , nil , ( textCfg[i].line and MColor.black or nil ) , ( textCfg[i].line and 2 or nil ) )
	end

end



function ITEMLIST:ctor(parent)
	self.parent = parent
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

	createLabel( self , game.getStrByKey("task_d_h") ..  data.turnNum .. "/" .. __TASK:getEveryNum() , cc.p( 187 , 520) , cc.p( 0.5 , 0.5 ) , 20 , nil , nil , nil , MColor.lable_yellow , nil , nil )
	self:createTableView(self , cc.size( 361 - 15 , 470 - 21 ) , cc.p( 10 + 10 , 25 + 21 ) , true , true )
	self:getTableView():setBounceable(true)

	if itemIndex > 6 then
		--设置偏移量
		local width , height = self:cellSizeForTable()
		self:getTableView():setContentOffset( self:getTableView():maxContainerOffset()  ) --默认到最后
		-- end
	end

	local helpBtn = createMenuItem( self , "res/component/button/small_help2.png"  ,  cc.p( 55  ,  517 ) , function() self:helpFun() end )

end


function ITEMLIST:tableCellTouched(table,cell)
	if itemIndex == cell:getIdx()+1  then return end
end
function ITEMLIST:cellSizeForTable(table,idx) 
	return 65 , 361 
end
function ITEMLIST:numberOfCellsInTableView(table)
	return itemIndex 
end
function ITEMLIST:tableCellAtIndex(table, idx)
	local cell = table:dequeueCell()
	if cell == nil  then
		cell = cc.TableViewCell:new()
	else
		cell:removeAllChildren()
	end
	local index = idx + 1 


	-- local bg = GraySprite:create( "res/component/button/52.png" )
	-- setNodeAttr( bg , cc.p( 357/2 , 0 ) , cc.p( 0.5 , 0 )  )
	-- cell:addChild( bg )

	local bg = createScale9Sprite( cell , "res/common/scalable/" .. ( index == itemIndex and "item_sel.png" or "item.png" ) , cc.p( 357/2 , 0 ), cc.size( 327 , 61 ) , cc.p( 0.5 , 0 ) )
	local bgSize = bg:getContentSize()
	local TASK_DAILY_PRIZE_RATE = {1,1.06,1.12,1.19,1.26,1.34,1.42,1.51,1.6,1.7,1.8,1.91,2.02,2.14,2.27}
	createLabel( cell , string.format( game.getStrByKey( "ring" ) , index ) , cc.p( 40 , bgSize.height/2 ) , cc.p( 0 , 0.5 ) , 20 , nil , 20 , nil , MColor.lable_yellow , nil , nil )
	createLabel( cell , TASK_DAILY_PRIZE_RATE[index] .. game.getStrByKey( "task_d_b7" ) , cc.p( 140 , bgSize.height/2 ) , cc.p( 0 , 0.5 ) , 20 , nil , 20 , nil , MColor.yellow , nil , nil )

	local str = game.getStrByKey( index ~= itemIndex and "task_finish4" or "task_finish2" )
	local color = ( index ~= itemIndex and  MColor.green or MColor.red )
	if index == __TASK:getEveryNum()  then
		local tempData = DATA_Mission:getEveryData()
		if tempData.overEvery then
			str = game.getStrByKey( "task_finish4" )
			color = MColor.green
		end
	end

	createLabel( cell , str , cc.p( 239 , bgSize.height/2 ) , cc.p( 0 , 0.5 ) , 20 , nil , 20 , nil , color , nil , nil)

	-- if index == itemIndex then 
	-- 	createSprite( cell , "res/component/button/52_sel.png" , cc.p( 357/2 , 0 ) , cc.p( 0.5 , 0 ) ) 
	-- else
	-- 	bg:addColorGray()
	-- end

  return cell
end




return M