--[[ 充值返金额 ]]--
local rechargeBack = class( "rechargeBack", require( "src/TabViewLayer" ))
local rechargeLayer1 = class("rechargeLayer1", function() return cc.Node:create() end)  --奖励未领取. 或者是礼包已经领取
local rechargeLayer2 = class("rechargeLayer2", function() return cc.Node:create() end)  --京东卡领取界面
local res = "res/layers/activity/cell/recharge_back/"
local MoenyData = { 10 , 20 , 30 , 40 , 50 , 60 }

------------------------------------------------------------------
local function localMessageBox(params)
	local BoxType = params.boxtype  --1:领取礼包 2:领取京东卡 3:领取连续登录的物品奖励 4:领取连续登录的京东卡奖励
	local parent = params.parent
	
	if not parent then return end

	local bg = createSprite(parent, "res/common/4-1.png", cc.p(480, 320), cc.p(0.5,0.5 ))	

	local titleBg = createSprite(bg, "res/common/1.png", cc.p(bg:getContentSize().width/2, bg:getContentSize().height))

	--标题头
	local str = ""
	if BoxType == 1 then 
		str = game.getStrByKey("gift_content")
	elseif BoxType == 2 then 
		str = game.getStrByKey("jingdong_card")
	else
		local day = params.day
		local strDay = ""
		if day > 10 then 
			strDay = strDay .. game.getStrByKey("num_" .. day / 10)
			if day > 20 then 
				strDay = strDay .. game.getStrByKey("num_10")
			end
			strDay = strDay .. game.getStrByKey("num_" .. day % 10)
		elseif day then
			strDay = strDay .. game.getStrByKey("num_" .. day % 10)
		end

		str = string.format(game.getStrByKey("continue_login"), strDay)
	end
	createLabel(titleBg, str, cc.p(titleBg:getContentSize().width/2, titleBg:getContentSize().height/2), cc.p(0.5, 0.5))--:setColor(MColor:lable_yellow)

	--奖励列表显示
	if BoxType == 1 or BoxType == 3 then 
		local awardData = { { id = 444444 , num = 2000 } ,  { id = 444444 , num = 2000 } , { id = 444444 , num = 2000 } , { id = 444444 , num = 2000 } , { id = 444444 , num = 2000 } ,{ id = 444444 , num = 2000 } ,} 
		
		local awardbg = createSprite(bg, res .. "26.png", cc.p(350, 285), cc.p(0.5,0.5 ))

		local scrollView1 = cc.ScrollView:create()
		scrollView1:setViewSize(cc.size( 600 , 120 ) )
		scrollView1:setPosition( cc.p( 406 , 91 ) )
		scrollView1:setScale(1.0)
		scrollView1:ignoreAnchorPointForPosition(false)
		local layer = __createAwardGroup( awardData, true)--DATA_newActivity:getAward(), true ) 

		scrollView1:setContainer( layer )
		scrollView1:updateInset()

		scrollView1:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL )
		scrollView1:setClippingToBounds(true)
		scrollView1:setBounceable(true)
		awardbg:addChild(scrollView1)		
	end

	--提示文字
	local richText = createRichText(bg, cc.p(357, 267), cc.size(550, 60), cc.p(0.5, 0.5), false)
	if BoxType == 1 then 
		str = game.getStrByKey("jiongdongcard_1")
		richText:setPositionY(150)
	elseif BoxType == 2 then 
		str = game.getStrByKey("jiongdongcard_2")
	elseif BoxType == 3 then
		str = game.getStrByKey("jiongdongcard_3")
		richText:setPositionY(150)
	else
		str = game.getStrByKey("jiongdongcard_4") .. game.getStrByKey("jiongdongcard_3")
	end
	addRichTextItem(richText, str, nil, nil, 22)

	local closeCallBack = function(tag, sender)
		local removeFunc = function()
		    if bg then
		        removeFromParent(bg)
		        bg = nil
		    end
		end					
		if bg then
			bg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 0), cc.CallFunc:create(removeFunc)))	
		end
	end

	local func = function()
		if btnCallBack then
			btnCallBack()
		end
		closeCallBack()
	end	

	--按钮
	local btnCallBack = params.callback
	local btn1 = createMenuItem(bg,"res/component/button/4.png", cc.p(247, 105), func)
	local btn1Text = createLabel(btn1, game.getStrByKey("confirm"), cc.p(btn1:getContentSize().width/2, btn1:getContentSize().height/2), cc.p(0.5, 0.5))
	if BoxType == 1 or BoxType == 2 then 
		local btn2 = createMenuItem(bg, "res/component/button/4.png", cc.p(485, 105), closeCallBack)
		createLabel(btn2, game.getStrByKey("cancel"), cc.p(btn2:getContentSize().width/2, btn2:getContentSize().height/2), cc.p(0.5, 0.5))
	else
		btn1:setPositionX(357)
		btn1Text:setString(game.getStrByKey("lottery_getOne"))
	end
	registerOutsideCloseFunc( bg,  closeCallBack)
	bg:setScale(0.01)
    bg:runAction(cc.ScaleTo:create(0.1, 1))	

	local  listenner = cc.EventListenerTouchOneByOne:create()
	listenner:setSwallowTouches( true )
    listenner:registerScriptHandler(function(touch, event) 
								    	local pt = bg:getParent():convertTouchToNodeSpace(touch)
										if cc.rectContainsPoint(bg:getBoundingBox(), pt) == true then
												return true 
										end
    								end, cc.Handler.EVENT_TOUCH_BEGAN)
    local eventDispatcher = bg:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, bg)    

end

------------------------------------------------------------------
local function ruleNode(params)
	if not  params.parent then return end
	local ruleHeight = params.Height or 67
	local node = cc.Node:create()
	params.parent:addChild(node)

	local tips = {"1. ", "2. ", "3.", "4."}

	createScale9Sprite( node , res .. "25.png" , cc.p( 15 , 12 ) , cc.size( 812 , ruleHeight ) , cc.p( 0 , 0 ) )

	local ruleTitle = createLabel(node, game.getStrByKey("rule_title"), cc.p(51, ruleHeight + 13), cc.p(0, 0), 20):setColor(MColor.yellow)

	local ruleNode = cc.Node:create()
	local ruleTemp = cc.Node:create()
	local ruleLabel = nil
	local num = tablenums(tips)
	local height = ruleHeight - 10
	local addY = 0 
	for i=1, num do
		ruleLabel = createLabel(ruleTemp, tips[i], nil, nil, 20)
		ruleLabel:setColor(MColor.yellow)
		setNodeAttr( ruleLabel , cc.p( 25 , addY ) , cc.p( 0 , 1) )
		addY = addY - ruleLabel:getContentSize().height
	end

	addY = math.abs( addY )
	addY = addY < height and height or addY

	ruleNode:addChild(ruleTemp)

	setNodeAttr( ruleTemp , cc.p( 0 , addY), cc.p( 0 , 0) )
	ruleNode:setContentSize(cc.size(900, addY))

	local scrollView1 = cc.ScrollView:create()
	scrollView1:setViewSize(cc.size( 900 , ruleHeight - 10 ) )
	scrollView1:setPosition( cc.p( 25 , 18 ) )
	scrollView1:setScale(1.0)
	scrollView1:ignoreAnchorPointForPosition(true)

	scrollView1:setContainer( ruleNode )
	scrollView1:updateInset()

	scrollView1:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	scrollView1:setClippingToBounds(true)
	scrollView1:setBounceable(true)
	node:addChild(scrollView1)

	local layerSize = ruleNode:getContentSize()
	if layerSize.height > height then
	  scrollView1:setContentOffset( cc.p( 0 ,  height - layerSize.height  ) )
	end	
end

------------------------------------------------------------------
function rechargeBack:ctor( params )
	params = params or {}
	self.items = {}
	self.selIndex = nil

	local base_node = popupBox({ 
								parent = nil , 
								bg = COMMONPATH .. "2.jpg" , 
								isMain = true , 
								title = { textPath = res .. "title.png" } ,
								close = { callback = function() DATA_newActivity:refreshIconState() end } , 
								pageIcon = { path = res .. "icon_03.png" } ,
								zorder = 200 , 
								actionType = 1 ,
								})
	local size = base_node:getContentSize()
	base_node:addChild(self)
	self.base_node = base_node

	createSprite( base_node , res .. "bg.jpg" , cc.p( size.width/2 , 10 ) , cc.p( 0.5 , 0 ) )

	self:createTableView(base_node , cc.size( 930 , 60 ),cc.p( 17 , 503 ) , false )
	self:getTableView():setLocalZOrder(125)	

	self:refreshLayer(1)
end

function rechargeBack:cellSizeForTable(table,idx) 
    return 60 , 180
end

function rechargeBack:tableCellAtIndex( table , idx )
	local cell = table:dequeueCell()
	local index = idx + 1

	if cell == nil  then
	  cell = cc.TableViewCell:new()
	else
	  cell:removeAllChildren()
	end

	local itemNormal = createSprite(cell, "res/component/TabControl/5.png", cc.p(90, 27), cc.p(0.5 , 0.5))
	local itemSel = createSprite(cell, "res/component/TabControl/6.png", cc.p(90,27), cc.p(0.5 , 0.5))
	itemSel:setVisible(false)

	cell.changeState = function(_bool) itemNormal:setVisible(not _bool)  itemSel:setVisible(_bool)  end

	createLabel(cell, string.format(game.getStrByKey("recharge_num"), MoenyData[index]), cc.p(90,25),cc.p(0.5, 0.5) , 26, true):setColor(MColor.lable_yellow)

	if (not self.curItem )and index == 1 then 
		self.curItem = cell 
		cell.changeState(true) 
	end

	return cell
end

function rechargeBack:tableCellTouched(table,cell)
	AudioEnginer.playTouchPointEffect()

	if self.curItem then
		self.curItem.changeState( false )
	end
	self.activityID = cell:getIdx() + 1 
	self.curItem = cell
	self.curItem.changeState( true )

	self:refreshLayer(cell:getIdx() + 1 )
end

function rechargeBack:numberOfCellsInTableView(table)
   return tablenums(MoenyData)
end

function rechargeBack:refreshLayer(index)
	local params = {parent = self.base_node, state = 2, index = index}
	
	if index == 1 then params.state = 1 end
	if index == 2 then params.state = 2 end
	if index == 3 then params.state = 3 end	
	if index == 4 then params.state = 4 end

	if params.state ~= 3 then
		if self.Layer2 then self.Layer2:setVisible(false) end


		if self.Layer1 then
			self.Layer1:updateInfo(params)
		else
			self.Layer1 = rechargeLayer1.new(params)	
		end
		self.Layer1:setVisible(true)		
	else
		if self.Layer1 then  self.Layer1:setVisible(false) end
		if self.Layer2 then
			self.Layer2:updateUI(params)
		else
			self.Layer2 = rechargeLayer2.new(params)	
		end
		self.Layer2:setVisible(true)		
	end
end

------------------------------------------------------------------
function rechargeLayer1:ctor(params)
	self:formatParams(params)

	print ("params.parent,params.state,params.index",params.parent, params.state, params.index)
	if params.parent then 
		params.parent:addChild(self, 200)
	else
		return
	end

	local callBack = function(tag, sender)
		if self.state ~= 2 then return end
		--开始请求支付

	end

	self.tips = createSprite(self, res .. "24.png", cc.p(35, 387),cc.p(0,0))

	self.timeLabel = createLabel(self, game.getStrByKey("activity_time") .. "", cc.p(51, 455), cc.p(0, 0), 20)

	self.btn  = createMenuItem(self, "res/component/button/11.png", cc.p(475, 115), callback)

	self.btnLabel = createLabel(self.btn, game.getStrByKey("recharge_now"), cc.p(self.btn:getContentSize().width/2, self.btn:getContentSize().height/2), cc.p(0.5, 0.5), 24,  true , nil , nil , MColor.lable_yellow , nil , nil , MColor.black , 3  )

	ruleNode({parent = self, Height = 67})

	self.ChooseGiftNode = cc.Node:create()
	self:addChild(self.ChooseGiftNode)

	local chooseFunc1 = function(tag, sender)
		-- if self.ChooseGiftNode:isVisable() == false then 		
		-- 	return
		-- end
		AudioEnginer.playTouchPointEffect()
		if self.state ~= 1 then return end
		localMessageBox({parent = self, boxtype = 1})
	end
	local chooseFunc2 = function(tag, sender)
		AudioEnginer.playTouchPointEffect()
		if self.state ~= 1 then return end
		localMessageBox({parent = self, boxtype = 2})
	end

	createMenuItem(self.ChooseGiftNode, res .. "27.png", cc.p(260, 289), chooseFunc1)
	createMenuItem(self.ChooseGiftNode, res .. "21.png", cc.p(700, 289), chooseFunc2)
	createSprite(self.ChooseGiftNode, res .. "23.png", cc.p(480, 240), cc.p(0.5, 0.5))

	self.haveAwardNode = createSprite(self, res .. "20.png", cc.p(480, 289), cc.p(0.5, 0.5))

	self:refreshByState()
end

function rechargeLayer1:formatParams( params)
	self.parent = params.parent
	self.state  = params.state         --当前礼包的状态： 1:可以领取. 2:不能领取.  3:已经领取 （已经领取京东卡在另外一个层实现）
	self.index  = params.index
	self.value	= params.value
end
function rechargeLayer1:updateInfo(params)
	self:formatParams(params)
	self:refreshByState()
end

function rechargeLayer1:refreshByState()
	if self.state == 1 then
		self.timeLabel:setVisible(false)
		self.tips:setPositionY(415)
		self.btn:setVisible(false)
		self.ChooseGiftNode:setVisible(true)
		self.haveAwardNode:setVisible(false)
	elseif self.state == 2 then
		self.timeLabel:setVisible(true)
		self.tips:setPositionY(387)
		self.btn:setVisible(true)
		self.btnLabel:setString(game.getStrByKey("recharge_now"))
		self.ChooseGiftNode:setVisible(false)
		self.haveAwardNode:setVisible(false)
	elseif self.state == 3 then
		self.timeLabel:setVisible(false)
		self.tips:setPositionY(415)
		self.btn:setVisible(true)
		self.btnLabel:setString(game.getStrByKey("getOver"))
		self.ChooseGiftNode:setVisible(false)
		self.haveAwardNode:setVisible(true)
	end	
end

------------------------------------------------------------------
function rechargeLayer2:ctor(params)
	self:formatData(params)
	if not params.parent then return end

	params.parent:addChild(self)
	ruleNode({parent = self, Height = 100})

	createLabel(self, game.getStrByKey("jiongdongcard_5"), cc.p(35, 172),cc.p(0,0), 18):setColor(MColor.red)

	local awardBg = createScale9Sprite(self, "res/common/31.png" , cc.p(40, 210), cc.size(880, 265) , cc.p( 0 , 0 ) )

	local awardData = { { id = 444444 , num = 2000 } ,  { id = 444444 , num = 2000 } , { id = 444444 , num = 2000 } , { id = 444444 , num = 2000 } , { id = 444444 , num = 2000 } ,{ id = 444444 , num = 2000 } ,
						{ id = 444444 , num = 2000 } ,  { id = 444444 , num = 2000 } , { id = 444444 , num = 2000 } , { id = 444444 , num = 2000 } , { id = 444444 , num = 2000 } ,{ id = 444444 , num = 2000 } ,
						{ id = 444444 , num = 2000 } ,  { id = 444444 , num = 2000 } , { id = 444444 , num = 2000 } 
					  } 
	for i = 1, #awardData do
		
	end

end


function rechargeLayer2:updateUI(params)
	self:formatData(params)

end

function rechargeLayer2:formatData(params)
	
end

function rechargeLayer2:showAward()
	
end

------------------------------------------------------------------
return rechargeBack