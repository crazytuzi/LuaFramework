local BuffLayer = class("BuffLayer", function() return cc.Node:create() end )
local width , height  = 400 , 290
local PATH = "res/layers/buff/" 
local span_time = 0
local u_time = 0
function BuffLayer:ctor(buff,parent)
	self.buffs = buff			
	getRunScene():addChild(self,200)
	u_time = 0 
	local base_node = createScale9Sprite(self, "res/common/scalable/6.png", cc.p(266,display.height - 96), cc.size( 380 , 340 ),cc.p(0.0,1.0))
	self.viewLayer = cc.Node:create()
	base_node:addChild( self.viewLayer  )
	self:createList()
	local func = function()
		removeFromParent(self)
	end
	registerOutsideCloseFunc(base_node, func ,true);

    self:registerScriptHandler(function(event)
		if event == "exit" then
		 	if self.tipLayer then self.tipLayer:close() self.tipLayer = nil end
		end
	end)
end

function BuffLayer:createList()
	BuffLayer.need_refresh = nil
	if not self.viewLayer then return end
	self.viewLayer:removeAllChildren()
	local scrollView1 = cc.ScrollView:create()

	local function scrollView1DidScroll() end
	local function scrollView1DidZoom() end
	scrollView1:setViewSize(cc.size( width , height ))
	scrollView1:setPosition( cc.p( 0 , 25 ) )
	scrollView1:setScale(1.0)
	scrollView1:ignoreAnchorPointForPosition(true)
	local tempLayer = self:createLayout() 
	scrollView1:setContainer( tempLayer )
	scrollView1:updateInset()

	scrollView1:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL )
	scrollView1:setClippingToBounds(true)
	scrollView1:setBounceable(true)
	scrollView1:setDelegate()
	scrollView1:registerScriptHandler(scrollView1DidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
	scrollView1:registerScriptHandler(scrollView1DidZoom,cc.SCROLLVIEW_SCRIPT_ZOOM)

	self.viewLayer:addChild(scrollView1)

	local layerSize = tempLayer:getContentSize()
	scrollView1:setContentOffset( cc.p( 0 ,  height - layerSize.height ) )
end

function BuffLayer:createLayout()
	local node = cc.Node:create()
	if G_BUFF_TIME then span_time = os.time() - G_BUFF_TIME end
	local addGroup , reduceGroup , addNum , reduceNum = cc.Node:create() , cc.Node:create() , 0  , 0 

	local getDisplayTime = function(s_time)
	--s_time = s_time/1000
		if s_time >= 320*3600 then
			return game.getStrByKey( "forever" )
		elseif s_time >= 168*3600 then 
			return game.getStrByKey( "week" )
		elseif s_time >= 24*3600 then 
			local day = math.floor(s_time/(24*3600))
			local hour = math.floor((s_time%(3600*24))/3600)
			return ""..day.. game.getStrByKey( "day" )..hour..game.getStrByKey( "hour" )
		elseif s_time >= 3600 then 
			local hour = math.floor(s_time/3600)
			local min = math.floor((s_time/60)%60)
			return ""..hour..game.getStrByKey( "hour" )..min..game.getStrByKey( "min" )
		elseif s_time >= 60 then 
			local min = math.floor(s_time/60)
			return ""..min..game.getStrByKey( "minute" )
		elseif s_time >= 0 then
			return ""..math.floor(s_time)..game.getStrByKey( "sec" )
		elseif s_time < 0 then
			return ""
		end
		return ""
	end
	
	local function tipFun( key , ppos )

		if self.tipLayer then self.tipLayer:close() self.tipLayer = nil end

		self.tipLayer = popupBox({ --parent = getRunScene()  , 
						 pos = cc.p(ppos.x+250 , ppos.y-150 ) ,
						 actionOff = { offX = 230 , offY = 0 } ,  
 						 bg = "res/common/bg/bg36.png" ,   
                         isBgClickQuit = true , 
                         zorder = 200 , 
                         actionType = 5 ,
                         isNoSwallow = true , 
                       })
		registerOutsideCloseFunc( self.tipLayer , function() self.tipLayer:close() self.tipLayer = nil end , true , false ) 

		local cfgData = getConfigItemByKey( "buff" , "id" )[ tonumber( key ) ]
		createLabel( self.tipLayer , cfgData.name  , cc.p( 210 , 250 ) , cc.p( 0.5 , 0 ) , 20 , nil , nil , nil , MColor.yellow )
		createLabel( self.tipLayer , game.getStrByKey( "desc_text" ) , cc.p( 50 , 210 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.purple )
		local descColorCfg = { MColor.white , MColor.lable_yellow , MColor.red , MColor.green }  --配置颜色对应
		local desc = createLabel( self.tipLayer , cfgData.desc_text or "" , cc.p( 50 , 200 ) , cc.p( 0 , 1 ) , 20 , nil , nil , nil , ( cfgData.desc_color and descColorCfg[ tonumber( cfgData.desc_color ) ] or MColor.white ) )
		desc:setDimensions( 310,0 )

		if  cfgData.statement and cfgData.statement == 1 then
			createLabel( self.tipLayer , game.getStrByKey( "addbuff" ) , cc.p( 20 , 20 ) , cc.p( 0 , 0 ) , 20 , nil , nil , nil , MColor.green )
		end

	end

	--local faction_key = {[17]="Lv.1",[25]="Lv.2",[26]="Lv.3",[27]="Lv.4",[28]="Lv.5"}
	local spaceY , typeSpace  = 100 , 20 
	self.textTable = {}
	for key , v in pairs( self.buffs ) do
		
		local iconBtn = nil

		local downTime = 0
		local buff_data =  getConfigItemByKey("buff","id", tonumber( key ))
		if buff_data.type == 1 then
			local spaceNum = buff_data.spaceTime
			downTime = v/1000 * spaceNum - span_time - u_time
		elseif buff_data.type == 2 then
			downTime =  v/1000 - span_time - u_time
		elseif buff_data.type == 3 then
			downTime = v - span_time - u_time - os.time() - (G_TIME_INFO.correctTime or 0)
		end
		if downTime >= 0 then
			--print(key,downTime,"1111111111111")
			local buff_type = buff_data.effectType
			local icon = buff_data.icon
			if icon then
				if buff_type == 1 then
					--增益
					local pos = cc.p( 70 + ( addNum% 4 ) * 80 , -32 - math.floor( addNum/4 ) * spaceY )
					iconBtn = createSprite( addGroup , "res/mainui/buff/".. icon ..".png" , pos , cc.p( 0.5 , 0.5 ) )
					createSprite( iconBtn , PATH .. "add.png" , cc.p( iconBtn:getContentSize().width/2 , iconBtn:getContentSize().height/2 ) , cc.p( 0.5 , 0.5 ) )
					addNum = addNum + 1
				else
					--减益
					local pos = cc.p( 70 + ( reduceNum% 4 ) * 80 ,  -32 - math.floor( reduceNum/4 ) * spaceY  ) 
					iconBtn = createSprite( reduceGroup , "res/mainui/buff/".. icon ..".png" , pos , cc.p( 0.5 , 0.5 ) )
					createSprite( iconBtn , PATH .. "reduce.png" , cc.p( iconBtn:getContentSize().width/2 , iconBtn:getContentSize().height/2 ) , cc.p( 0.5 , 0.5 ) )
					reduceNum = reduceNum + 1
				end
				-- if faction_key[tonumber( key )] then
				-- 	createLabel( iconBtn , faction_key[tonumber( key )]  , cc.p( iconBtn:getContentSize().width , 0) , cc.p(1.0,0) , 18 , nil , nil , nil , MColor.white )
				-- end


			    local function regHandler( root )

				        Mnode.listenTouchEvent(
				        {
				        node = root,
				        swallow = false ,
				        begin = function(touch, event)
				          local node = event:getCurrentTarget()
				          node.isMove = false
				          local inside = Mnode.isTouchInNodeAABB(node, touch)
				          return inside
				        end,

				        moved = function(touch, event)
				            local node = event:getCurrentTarget()
				            if node.recovered then return end
				            local startPos = touch:getStartLocation()
				            local currPos  = touch:getLocation()
				            if cc.pGetDistance(startPos,currPos) > 5 then
				                node.isMove = true
				            end
				        end,

				        ended = function(touch, event)
				          local node = event:getCurrentTarget()
				          if Mnode.isTouchInNodeAABB(node, touch) and not node.isMove then
				            AudioEnginer.playTouchPointEffect()
				            local curData = root.curData

    						local p = touch:getLocation()
							tipFun( key , p )
							
				          end
				        end,
				        })
    			end
    			regHandler( iconBtn )

				self.textTable[ key ] = createLabel( iconBtn , getDisplayTime( downTime )  , cc.p( iconBtn:getContentSize().width/2 , -iconBtn:getContentSize().height/2 ) , cc.p( 0.5 , 0 ) , 20 , nil , nil , nil , MColor.white )
			 --    iconBtn:registerScriptHandler(function(event)
				-- 	if event == "exit" then
				-- 		self.textTable[ key ] = nil
				-- 	end
				-- end)
			end
		end

	end


	local addNode , reduceNode = cc.Node:create() , cc.Node:create()
	if addNum ~= 0 then
		addGroup:setContentSize( cc.size( width ,  math.ceil( addNum/4 ) * spaceY ) )
		addNode:setContentSize( cc.size( width ,  math.ceil( addNum/4 ) * spaceY ) )
		setNodeAttr( addGroup , cc.p( 0 , math.ceil( addNum/4 ) * spaceY  ) , cc.p( 0 , 0 ) )
		addNode:addChild( addGroup )
	end

	if reduceNum ~= 0 then
		reduceGroup:setContentSize( cc.size( width ,  math.ceil( reduceNum/4 ) * spaceY ) )
		reduceNode:setContentSize( cc.size( width ,  math.ceil( reduceNum/4 ) * spaceY ) )
		setNodeAttr( reduceGroup , cc.p( 0 , math.ceil( reduceNum/4 ) * spaceY  ) , cc.p( 0 , 0 ) )
		reduceNode:addChild( reduceGroup )
	end

	if reduceNum ~= 0 then
		setNodeAttr( addNode , cc.p( 0 , reduceNode:getContentSize().height + typeSpace ) , cc.p( 0 , 0 ) )
		setNodeAttr( reduceNode , cc.p( 0 , 0 ) , cc.p( 0 , 0 ) )
	else
		setNodeAttr( addNode , cc.p( 0 , 0 ) , cc.p( 0 , 0 ) )
	end

	node:addChild( reduceNode)
	node:addChild( addNode )

	node:setContentSize( cc.size( width , reduceNode:getContentSize().height + addNode:getContentSize().height + typeSpace) )

	
	local update = function()
		if G_ROLE_MAIN then
			self.buffs = g_buffs[G_ROLE_MAIN.obj_id] or {}
			if BuffLayer.need_refresh then
				u_time = 0
				if self.createList then
					self:createList()
				end
			elseif self.buffs then
				u_time = u_time + 1
				for key ,v in pairs(self.buffs)do 
					local downTime = 0
					local buff_data =  getConfigItemByKey("buff","id", tonumber( key ))
					if buff_data.type == 1 then
						local spaceNum = buff_data.spaceTime
						downTime = v/1000 * spaceNum - span_time - u_time
					elseif buff_data.type == 2 then
						downTime =  v/1000 - span_time - u_time
					elseif buff_data.type == 3 then
						downTime = v - span_time - u_time - os.time() - (G_TIME_INFO.correctTime or 0)
					end

					if downTime >= 0 then 
						if self.textTable and self.textTable[ key ] and IsNodeValid(self.textTable[ key ]) then
							self.textTable[ key ]:setString( getDisplayTime( downTime ))
						end
					end
				end
			end
		end
	end
	if self.timeHandler then
		self:stopAction(self.timeHandler)
		 self.timeHandler = nil
	end
	self.timeHandler = schedule( self , function() update() end  , 1 )

	return node
end

return BuffLayer