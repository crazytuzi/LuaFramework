--[[ 找回界面 ]]--
local M = class("BackLayer", require ("src/TabViewLayer") )
local DropOp = require("src/config/DropAwardOp")

function M:ctor( params )
	self.data = {}
	self.money1 = 0
	self.money2 = 0	

	local base_node = createSprite( self , "res/common/bg/bg18.png" , cc.p( display.cx , display.cy ) , cc.p( 0.5 , 0.5 ) )
	createSprite( base_node , "res/layers/rewardTask/rewardTaskReleaseBg.png" , cc.p( base_node:getContentSize().width/2 , 15 ) , cc.p( 0.5 , 0. ) )

	self.girlImg = createSprite( base_node , "res/mainui/npc_big_head/0.png" , cc.p( 230 - 20 , base_node:getContentSize().height/2 - 47 ) , cc.p( 0.5 , 0.5 ) )
	local speakBg = createSprite( self.girlImg , "res/tuto/images/bigBg.png" , cc.p( 450 ,230 ) , cc.p( 0.5 , 0) )
	speakBg:setFlippedX(true);
	createLabel( speakBg , game.getStrByKey( "battle_back3" ) ,  cc.p( speakBg:getContentSize().width/2 + 15 , speakBg:getContentSize().height/2  ) , cc.p( 0.5 , 0.5 ) , 24 , nil , nil , nil , MColor.lable_yellow  , nil , 236  )



	self.girlImg:setVisible( false ) 
	
	createLabel( base_node , game.getStrByKey("yesterday_title") , cc.p(425,500) , cc.p(0.5,0.5) , 24 , true , nil ,nil , MColor.lable_yellow )

	local func = function()
		removeFromParent(self)
	end
	registerOutsideCloseFunc(base_node, func ,true);
	createTouchItem( base_node , "res/component/button/x2.png" , cc.p( base_node:getContentSize().width - 42  ,base_node:getContentSize().height - 30 ) ,func )
	

	local width , height = 770 , 520 

	self:createTableView( base_node , cc.size( 770 , 520 ),cc.p( 43 , 75 ) , false )
	self:getTableView():setLocalZOrder(125)

    local topFlag = Effects:create(false)
    topFlag:playActionData2("ActivePage", 200 , -1 , 0 )
    setNodeAttr( topFlag , cc.p( 40 , height/2 ) , cc.p( 0.5 , 0.5 ) )
    addEffectWithMode( topFlag , 1 )
    base_node:addChild( topFlag , 198  )
    topFlag:setRotation(90)

    local bottomFlag = Effects:create(false)
    bottomFlag:playActionData2("ActivePage", 200 , -1 , 0 )
    setNodeAttr( bottomFlag , cc.p( width + 40 , height/2 ) , cc.p( 0.5 , 0.5 ) )
    addEffectWithMode( bottomFlag , 1 )
    base_node:addChild( bottomFlag , 198 )
    bottomFlag:setRotation(-90)
    
    local setFlagShow = function( value )
        --value 1在最右端不显左侧标记 2在中间左右都显示 3在最左端不显右侧标记 4左右两个都不显示
        if value == 4 then
            topFlag:setVisible( false )
            bottomFlag:setVisible( false )
        else
            topFlag:setVisible( value~=3 )
            bottomFlag:setVisible( value~=1 )
        end
    end

    self["scrollViewDidScroll"] = function()
    	local offX = self:getTableView():getContentOffset().x
        if self:numberOfCellsInTableView() <= 3 then
            setFlagShow(4)
        else
            if offX == self:getTableView():maxContainerOffset().x then 
                setFlagShow(3) 
            elseif offX == self:getTableView():minContainerOffset().x then 
                setFlagShow(1)
            else
                setFlagShow(2)
            end 
        end
    end
    performWithDelay( topFlag , function() self["scrollViewDidScroll"]() end , 0.01 ) 

    local moneyNode = self:showMoney()
    setNodeAttr( moneyNode , cc.p( 50 , 20 ) , cc.p( 0 , 0 ) )
    base_node:addChild( moneyNode )



    local getFun = function( flag )
		if flag == 1 and MRoleStruct:getAttr( PLAYER_MONEY ) < self.money1 then
			TIPS( { type = 1 , str =  game.getStrByKey( "factionQFT_operError5" ) } )
			return 
		end

		if flag == 2 and __checkGold( self.money2 ) == false then
			TIPS( { type = 1 , str =  game.getStrByKey( "factionQFT_operError6" ) } )
			return 
		end

		local  func = function()
			g_msgHandlerInst:sendNetDataByTableExEx( ACTIVITY_NORMAL_CS_GET_ALL_FIND_REWARD , "ActivityNormalGetAllFindReward", { type = flag } )
		end

		local allAwards = {}

		local tempData = copyTable( self.data )
		for _ , i in pairs( tempData ) do
			if i.find_nums > 0 then
				for _ , j in pairs( i.awards ) do
					j.num = j.num * i.find_nums * flag
					allAwards[ #allAwards + 1 ] = j
				end
			end
		end
		
		local ids = {}
		for _ , k in pairs( allAwards ) do
			if ids[ k.id ] then
				ids[ k.id ].num = ids[ k.id ].num + k.num
			else
				ids[ k.id ] = k
			end
		end
		allAwards = {}
		for _ , k in pairs( ids ) do
			allAwards[ #allAwards + 1 ] = k
		end
		Awards_Panel( {  award_tip = game.getStrByKey("yesterday_title") , awards = allAwards , getCallBack = func } )

	end

	local getAllBtn1 =	createScale9SpriteMenu( base_node , "res/component/button/50.png", cc.size( 180 , 58 ) , cc.p( G_NO_OPEN_PAY == false and 520 or 723  , 50 ) , function() getFun( 1 ) end )
	local btnText1 = createLabel( getAllBtn1 , "" ,  cc.p( 70 ,  30 )  , cc.p( 0.0 , 0.5 ) , 24 , true  )
	self.btnText1 = btnText1
	
	local moneyFalg = createSprite( getAllBtn1 , "res/group/currency/1.png" , cc.p( 35 , getAllBtn1:getContentSize().height/2 ) , cc.p( 0.5 , 0.5 ))
	moneyFalg:setScale( 0.7 )



	local getAllSp1 =	createScale9Sprite( base_node , "res/component/button/50_gray.png", cc.p( G_NO_OPEN_PAY == false and 520 or 723  , 50 ),  cc.size( 180 , 58 ) , cc.p( 0.5 , 0.5 )  )
	createLabel( getAllSp1 , game.getStrByKey("social_qq_get_all")  ,  cc.p( 110 ,  30 )  , cc.p( 0.5 , 0.5 ) , 24 , true  )
	local moneyFalg = createSprite( getAllSp1 , "res/group/currency/1.png" , cc.p( 35 , getAllSp1:getContentSize().height/2 ) , cc.p( 0.5 , 0.5 ))
	moneyFalg:setScale( 0.7 )

	local getAllBtn2  = nil 
	local btnText2 = nil
	local getAllSp2 = nil
	if G_NO_OPEN_PAY == false then
		getAllBtn2 = createScale9SpriteMenu( base_node , "res/component/button/50.png", cc.size( 180 , 58 ) , cc.p( 723  , 50 ) , function() getFun( 2 )  end )
		btnText2 = createLabel( getAllBtn2 , "" ,  cc.p( 70 ,  30 )  , cc.p( 0.0 , 0.5 ) , 24 , true  )
		self.btnText2 = btnText2 
		
		createSprite( getAllBtn2 , "res/group/currency/5.png" , cc.p( 35 , getAllBtn2:getContentSize().height/2 ) , cc.p( 0.5 , 0.5 ))

		getAllSp2 =	createScale9Sprite( base_node , "res/component/button/50_gray.png", cc.p( 723  , 50 ) ,  cc.size( 180 , 58 ) , cc.p( 0.5 , 0.5 )  )
		createLabel( getAllSp2 , game.getStrByKey("social_qq_get_all")  ,  cc.p( 110 ,  30 )  , cc.p( 0.5 , 0.5 ) , 24 , true  )
		createSprite( getAllSp2 , "res/group/currency/5.png" , cc.p( 35 , getAllBtn2:getContentSize().height/2 ) , cc.p( 0.5 , 0.5 ))
		
	end


	
	local function createLayout(  )
		
		if self["refreshMoney"] then self:refreshMoney() end
		
		if self.girlImg then self.girlImg:setVisible( tablenums( self.data ) <= 0 )  end
		
		if tablenums( self.data ) <= 0 then
			setFlagShow( 4 )
			
			getAllBtn1:setVisible( false )
			if getAllBtn2 then getAllBtn2:setVisible( false ) end

			getAllSp1:setVisible( true )
			if getAllSp2 then getAllSp2:setVisible( true ) end
		else
			
			getAllBtn1:setVisible( true )
			if getAllBtn2 then getAllBtn2:setVisible( true ) end

			getAllSp1:setVisible( false )
			if getAllSp2 then getAllSp2:setVisible( false ) end

		end

        if self["getTableView"] then
            self:getTableView():reloadData()
            if DATA_Activity:getTempOffPos() then
                self:getTableView():setContentOffset( DATA_Activity:getTempOffPos() )
                DATA_Activity:setTempOffPos( nil ) 
            end
        end
        
	end
	createLayout()
	DATA_Battle.F.BackLayer_refreshLayout = createLayout

	local function getOneKeyBackFun( buff )
		local t = g_msgHandlerInst:convertBufferToTable( "ActivityNormalGetAllFindRewardRet" , buff )
		if t.result == 0 then
			self.data = {}
			createLayout()
		end
	end
	g_msgHandlerInst:registerMsgHandler( ACTIVITY_NORMAL_SC_GET_ALL_FIND_REWARD_RET , getOneKeyBackFun ) 	--一键找回奖励领取结果

    self:registerScriptHandler(function(event)
        if event == "enter" then  
        	self:scrollViewDidScroll()
        elseif event == "exit" then
        	DATA_Battle.F.BackLayer_refreshLayout = nil
        end
    end)
    getRunScene():addChild(self,200)
	
end

function M:refreshMoney()
	self.money1 = 0
	self.money2 = 0	
	local t = DATA_Battle:getBackData()
	self.data = {}
	local cfg = getConfigItemByKey( "ActivityNormalDB" , "q_id"  )

	for i , v in ipairs( t.list ) do
		if cfg[v.id] and cfg[ v.id ].q_find_money and cfg[ v.id ].q_find_ingot then
			cfg[ v.id ]["q_find_times"] = ( cfg[ v.id ]["q_find_times"] or 0 )--保证
			cfg[ v.id ]["find_nums"] = v.times 	--后台数据没有及时刷新

			local tempTable = DropOp:dropItem_ex( cfg[v.id].q_find_money_dropid )
		    local awards = {}
		    for n , m in ipairs( tempTable ) do
		        awards[n] = { 
		                        id = m["q_item"] ,                          --奖励ID
		                        num = m["q_count"]   ,    					-- 奖励个数
		                        binding = m["bdlx"] ,                       --绑定(1绑定0不绑定)
		                        streng = m["q_strength"] ,                  --强化等级
		                        quality = m["q_quality"] ,                  --品质等级
		                        upStar = m["q_star"] ,                      --升星等级
		                        time = m["q_time"] ,                        --限时时间
		                        showBind = true ,                           --掉落表数据里边的数据  就必须设置当前这个字段存在且为true
		                        isBind = tonumber(m["bdlx"] or 0) == 1,     --绑定表现
		                    }
		    end
		    cfg[ v.id ]["awards"] = awards

			self.data[ #self.data + 1 ]  = cfg[ v.id ]
			self.money1 = self.money1 + cfg[ v.id ].q_find_money*cfg[ v.id ]["find_nums"]
			self.money2 = self.money2 +  cfg[ v.id ].q_find_ingot*cfg[ v.id ]["find_nums"]
		end

	end

	

	if self.btnText1 then self.btnText1:setString( self.money1 ) end
	if self.btnText2 then self.btnText2:setString( self.money2 ) end
end
function M:numberOfCellsInTableView(table)
	return tablenums( self.data )
end

function M:cellSizeForTable(table,idx) 
	return 400 , 260
end

function M:tableCellAtIndex( table , idx )
	local cell = table:dequeueCell()
	local index = idx + 1 
	local curData = {}

	if cell == nil  then
		cell = cc.TableViewCell:new()
	else
		cell:removeAllChildren()
	end
	local itemData = self.data[index]

	local bg = createSprite( cell , "res/layers/battle/backbg.png"  , cc.p( 0 , 0 ) , cc.p( 0 , 0 ) )
	local size = bg:getContentSize()

	createLabel( cell , itemData.q_name , cc.p( size.width/2 , size.height - 55 ) , cc.p( 0.5 , 0 ) , 22 , nil , nil , nil , MColor.yellow , nil , nil)

    if itemData.awards then
        local iconGroup = __createAwardGroup( itemData.awards , { color = MColor.lable_yellow , offY = -5 }  , 90 )
        setNodeAttr( iconGroup , cc.p( size.width/2 ,  300  ) , cc.p(  0.5 , 0.5 ) )
        iconGroup:setScale(0.95)
        bg:addChild( iconGroup )
    end

	createLabel( cell , game.getStrByKey( "battle_back1" ) ..  "：" .. itemData.find_nums  , cc.p( size.width/2 , 210 ) , cc.p( 0.5 , 0 ) , 20 , nil , nil , nil , MColor.lable_yellow , nil , nil)

	local getFun = function( flag )
		if flag == 1 and MRoleStruct:getAttr( PLAYER_MONEY ) < itemData.q_find_money then
			TIPS( { type = 1 , str =  game.getStrByKey( "factionQFT_operError5" ) } )
			return 
		end

		if flag == 2 and __checkGold( itemData.q_find_ingot ) == false then
			TIPS( { type = 1 , str =  game.getStrByKey( "factionQFT_operError6" ) } )
			return 
		end

		local  func = function()
	        if DATA_Activity then DATA_Activity:setTempOffPos( self:getTableView():getContentOffset() )  end
			g_msgHandlerInst:sendNetDataByTableExEx( ACTIVITY_NORMAL_CS_GET_FIND_REWARD , "ActivityNormalGetFindReward", { id = itemData.q_id , type = flag } )
		end
		local tempAward =  copyTable( itemData.awards )
		for k , v in pairs( tempAward ) do
			v.num = v.num * flag
		end
		Awards_Panel( {  award_tip = game.getStrByKey("yesterday_title") , awards = tempAward , getCallBack = func } )
	end
	local str = string.format( game.getStrByKey( "battle_back2" ) , "" )
	str = string.gsub( str ,"%%","")
	createLabel( cell , str , cc.p( size.width/2 , 170 ) , cc.p( 0.5 , 0 ) , 20 , nil , nil , nil , MColor.lable_yellow , nil , nil)
	local getBtn1 = createMenuItem( bg, "res/component/button/49.png" ,  cc.p( size.width/2 , 145 ) , function() getFun( 1 ) end )
	local flag = createSprite( getBtn1 , "res/group/currency/1.png" , cc.p( 30 , getBtn1:getContentSize().height/2 ) , cc.p( 0.5 , 0.5 )  )
	flag:setScale( 0.7 )
	createLabel( getBtn1 , itemData.q_find_money  , cc.p( 60 , getBtn1:getContentSize().height/2 )  , cc.p( 0 , 0.5 ) , 20 , nil , nil , nil , MColor.yellow )

	if G_NO_OPEN_PAY == false then
		
		createLabel( cell , string.format( game.getStrByKey( "battle_back2" ) , 200 ) , cc.p( size.width/2 , 85 ) , cc.p( 0.5 , 0 ) , 20 , nil , nil , nil , MColor.lable_yellow , nil , nil)
		local getBtn2 = createMenuItem( bg, "res/component/button/49.png" ,  cc.p( size.width/2 , 60 ) , function() getFun( 2 ) end )
		local flag = createSprite( getBtn2 , "res/group/currency/5.png" , cc.p( 30 , getBtn2:getContentSize().height/2 ) , cc.p( 0.5 , 0.5 )  )
		createLabel( getBtn2 , itemData.q_find_ingot  , cc.p( 60 , getBtn2:getContentSize().height/2 )  , cc.p( 0 , 0.5 ) , 20 , nil , nil , nil , MColor.yellow )
		getBtn2:setEnabled( itemData.find_nums>0  )

	end

	getBtn1:setEnabled( itemData.find_nums>0 )


	return cell
end

function M:showMoney()
	local Mcurrency = require "src/functional/currency"
	return Mnode.combineNode(
	{
		nodes = {
				[1] = Mnode.combineNode(
				{
					nodes = {
						[1] = Mcurrency.new(
						{
							cate = PLAYER_MONEY,
							--bg = "res/common/19.png",
							color = MColor.yellow,
							isOutline = true , 
						}),
					},
					
					margins = 5,
				}),

				[2] = Mnode.combineNode(
				{
					nodes = {
						[1] = ( G_NO_OPEN_PAY == false and Mcurrency.new({ isOutline = true , cate = PLAYER_INGOT, color = MColor.yellow, }) or nil )
					},
					margins = 5,
				}), 
		},
		
		ori = "|",
		margins = 0,
		align = "l",
	})
end
return M