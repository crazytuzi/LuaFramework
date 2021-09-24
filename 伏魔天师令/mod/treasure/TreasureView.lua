local TreasureView = classGc(view, function(self)
	self.pMediator = require("mod.treasure.TreasureMadiator")()
	self.pMediator : setView(self)
end)

local FONTSIZE 	   = 20
local m_winSize  = cc.Director:getInstance():getVisibleSize()
local SecondSize = cc.size(790,445)
local leftSize 	 = cc.size(522,450)
local rightSize  = cc.size(250,450)
local iconSize 	 = cc.size(85 ,85)

function TreasureView.create(self)
	self.m_normalView=require("mod.general.NormalView")()
	self.m_rootLayer=self.m_normalView:create()
	self.m_normalView : setTitle("珍宝阁")

	local tempScene=cc.Scene:create()
    tempScene:addChild(self.m_rootLayer)

	--self.m_normalView : showSecondBg()
	self : init()
	return tempScene
end

function TreasureView.initView( self )
	local mainNode = cc.Node:create()
	mainNode:setPosition(m_winSize.width/2,m_winSize.height/2)
	self.m_rootLayer:addChild(mainNode)

	local secondBG = ccui.Scale9Sprite:createWithSpriteFrameName("general_right_dins.png")
	secondBG : setPreferredSize(SecondSize)
	secondBG : setPosition(0,-28)
	mainNode : addChild(secondBG)
	
	self.leftSpr = cc.Sprite:create("ui/bg/treasure_dins.jpg")
	self.leftSpr : setPosition(-118,-28)
	mainNode : addChild(self.leftSpr)

	self.rightSpr = cc.Node : create()
	self.rightSpr : setPosition(150,-250)
	mainNode : addChild(self.rightSpr)

	self:LeftSprView()
	self:RightSprView()
end

function TreasureView.LeftSprView( self )
	local outIcon = cc.Sprite : create("ui/bg/treasure_out.png")
	outIcon       : setPosition(cc.p(263,216))
	self.leftSpr  : addChild(outIcon)

	outIcon : runAction(cc.RepeatForever:create(cc.RotateBy:create(120,360)))

	self.line_in = 
	{
		{cc.p(263,292),0},
		{cc.p(330,254),60},
		{cc.p(330,178),120},
		{cc.p(263,141),0},
		{cc.p(199,178),60},
		{cc.p(199,254),120},
	}

	self.line_out = 
	{
		{cc.p(320,312),120},
		{cc.p(375,216),0},
		{cc.p(320,120),60},
		{cc.p(206,120),120},
		{cc.p(151,216),0},
		{cc.p(206,312),60},
	}

	self.inLine = {}
	for i=1,6 do
		self.inLine[i] = cc.Sprite : createWithSpriteFrameName("treasure_line.png")
		self.inLine[i] : setPosition(self.line_in[i][1])
		self.inLine[i] : setRotation(self.line_in[i][2])
		self.inLine[i] : setVisible(false)
		self.leftSpr   : addChild(self.inLine[i])
	end

	self.outLine = {}
	for i=1,6 do
		self.outLine[i] = cc.Sprite : createWithSpriteFrameName("treasure_line.png")
		self.outLine[i] : setPosition(self.line_out[i][1])
		self.outLine[i] : setRotation(self.line_out[i][2])
		self.outLine[i] : setVisible(false)
		self.leftSpr    : addChild(self.outLine[i])
	end

	local inIcon = cc.Sprite : createWithSpriteFrameName("treasure_in_1.png")
	inIcon       : setPosition(cc.p(263,216))
	self.leftSpr : addChild(inIcon)
	self.inIcon  = inIcon

	inIcon : runAction(cc.RepeatForever:create(cc.RotateBy:create(30,-360)))


	self.loginLab = _G.Util : createLabel("珍宝阁第?层", FONTSIZE)
	self.loginLab : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_DARKPURPLE))
	self.loginLab : setPosition(75, leftSize.height-45) 
	self.leftSpr : addChild(self.loginLab)

	self.iconbgSpr ={1,2,3,4,5,6}
	self.infoLab = {1,2,3,4,5,6}
	self.infoStrLab = {1,2,3,4,5,6}
	local poX = {263,402,402,263,124,124}
	local poY = {376,280,152,54,152,280}
	local infoPoX={leftSize.width/2+45,leftSize.width/2+80,leftSize.width/2+45,
					leftSize.width/2-45,leftSize.width/2-80,leftSize.width/2-45}
	local infoPoY={leftSize.height/2+65,leftSize.height/2-5,leftSize.height/2-65,
				leftSize.height/2-65,leftSize.height/2-5,leftSize.height/2+65}
	for i=1,6 do
		self.iconbgSpr[i] = cc.Sprite:createWithSpriteFrameName("general_tubiaokuan.png")
		self.iconbgSpr[i] : setPosition(poX[i],poY[i])
		self.leftSpr : addChild(self.iconbgSpr[i])

		self.infoStrLab[i] = _G.Util : createLabel("????", FONTSIZE-2)
		self.infoStrLab[i] : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_GREY))
		self.infoStrLab[i] : setPosition(infoPoX[i], infoPoY[i]) 
		self.leftSpr : addChild(self.infoStrLab[i])

		self.infoLab[i] = _G.Util : createLabel("+????", FONTSIZE-2)
		self.infoLab[i] : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_GREY))
		self.infoLab[i] : setPosition(infoPoX[i], infoPoY[i]-20) 
		self.leftSpr : addChild(self.infoLab[i])
	end

	local function onBtnCallBack(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			print("说明")
			local explainView  = require("mod.general.ExplainView")()
			local explainLayer = explainView : create(40224)
		end
	end
	local tipsBtn = gc.CButton : create("general_help.png")
	tipsBtn : setButtonScale(0.8)
	tipsBtn : setPosition(leftSize.width-30, leftSize.height-48)
	tipsBtn : addTouchEventListener(onBtnCallBack)
	self.leftSpr : addChild(tipsBtn)

	self.addLab1 = _G.Util : createLabel("攻击", FONTSIZE)
	self.addLab1 : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_SPRINGGREEN))
	self.addLab1 : setAnchorPoint( cc.p(0.0,0.5) )
	self.addLab1 : setPosition(420, 38) 
	self.leftSpr : addChild(self.addLab1)

	self.addData1 = _G.Util : createLabel("+9999", FONTSIZE)
	self.addData1 : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_LBLUE))
	self.addData1 : setAnchorPoint( cc.p(0.0,0.5) )
	self.addData1 : setPosition(460, 38) 
	self.leftSpr  : addChild(self.addData1)

	self.addLab2 = _G.Util : createLabel("攻击", FONTSIZE)
	self.addLab2 : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_SPRINGGREEN))
	self.addLab2 : setAnchorPoint( cc.p(0.0,0.5) )
	self.addLab2 : setPosition(420, 15) 
	self.leftSpr : addChild(self.addLab2)

	self.addData2 = _G.Util : createLabel("+9999", FONTSIZE)
	self.addData2 : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_LBLUE))
	self.addData2 : setAnchorPoint( cc.p(0.0,0.5) )
	self.addData2 : setPosition(460, 15) 
	self.leftSpr  : addChild(self.addData2)

	local function leftEvent( sender,eventType )
		if eventType==ccui.TouchEventType.ended then
			print("left>>>>>>>>>>>>=========")
			self.curFloor = self.curFloor - 1
			self : __updateLeft(self.curFloor)
		end
	end

	local function rightEvent( sender,eventType )
		if eventType==ccui.TouchEventType.ended then
			print("right>>>>>>>>>>>>=========")
			self.curFloor = self.curFloor + 1
			if self.curFloor == self.maxFloor then
				local msg = REQ_TREASURE_LEVEL_ID()
				_G.Network: send(msg)
			else
				self : __updateLeft(self.curFloor)
			end
		end
	end

	local leftBtn= gc.CButton:create("general_fangye_1.png")
	leftBtn      : addTouchEventListener(leftEvent)
	leftBtn      : setPosition(cc.p(30,245))
	self.leftSpr : addChild(leftBtn)
	self.leftBtn = leftBtn

	local rightBtn= gc.CButton:create("general_fangye_1.png")
	rightBtn      : addTouchEventListener(rightEvent)
	rightBtn      : setRotation(180)
	rightBtn      : setPosition(cc.p(leftSize.width-30,245))
	self.leftSpr  : addChild(rightBtn)
	self.rightBtn = rightBtn
end

function TreasureView.RightSprView( self )
	self.rolebgSpr={1,2,3}
	local poX={rightSize.width/2,rightSize.width/2-55,rightSize.width/2+55}
	local poY={rightSize.height-80,rightSize.height/2-60,rightSize.height/2-60}
	for i=1,3 do
		if i==1 then
			self.rolebgSpr[i] = cc.Sprite:createWithSpriteFrameName("general_teshu_tubiaokuan.png")
		else
			self.rolebgSpr[i] = cc.Sprite:createWithSpriteFrameName("general_tubiaokuan.png")
		end
		
		self.rolebgSpr[i] : setPosition(poX[i],poY[i])
		self.rightSpr : addChild(self.rolebgSpr[i])
	end

	local goodsName = _G.Util : createLabel("珍宝名称1", 20)
	goodsName : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_SPRINGGREEN))
	goodsName : setPosition(rightSize.width/2, rightSize.height/2+65) 
	self.rightSpr : addChild(goodsName)
	self.goodsName = goodsName

	local jiantouSpr = cc.Sprite:createWithSpriteFrameName("general_tip_down.png")
	jiantouSpr : setPosition(rightSize.width/2,rightSize.height/2+20)
	jiantouSpr : setRotation(180)
	self.rightSpr : addChild(jiantouSpr)

	local function dazaoBtnCallBack(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			print("打造id",self.makeID)
			local msg = REQ_TREASURE_GOODS_ID()
			msg       : setArgs(self.makeID)
			_G.Network: send(msg)
		end
	end

	local lineSpr = ccui.Scale9Sprite:createWithSpriteFrameName("general_double_line.png")
	local lineSize = lineSpr:getContentSize()
	lineSpr:setPreferredSize(cc.size(rightSize.width,lineSize.height))
	lineSpr:setPosition(rightSize.width/2,110)
	self.rightSpr:addChild(lineSpr)

	local dazaoBtn  = gc.CButton:create("general_btn_gold.png") 
	dazaoBtn : setTitleFontName(_G.FontName.Heiti)
	dazaoBtn : setTitleText("打 造")
	dazaoBtn : addTouchEventListener(dazaoBtnCallBack)
	--dazaoBtn : enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
	dazaoBtn : setTitleFontSize(FONTSIZE+4)
	dazaoBtn : setPosition(rightSize.width/2,60)
	self.rightSpr : addChild(dazaoBtn)
	self.dazaoBtn = dazaoBtn

	local msg = REQ_TREASURE_LEVEL_ID()
	_G.Network: send(msg)
end

function TreasureView.updateLeft( self,_msg )
	if self.m_attrFlyNode~=nil then
		self.m_attrFlyNode:removeFromParent(true)
		self.m_attrFlyNode=nil
	end

	self.m_attrFlyNode=_G.Util:getLogsView():createAttrLogsNode()
	self.m_attrFlyNode:setPosition(leftSize.width*0.5,leftSize.height*0.5)
	self.leftSpr:addChild(self.m_attrFlyNode,10)

	local fontSize = 20
	self.maxFloor  = math.floor(_msg.level_id/100)
	self.curFloor  = math.floor(_msg.level_id/100)

	if self.maxFloor==1 then
		self.leftBtn  : setVisible(false)
	else
		self.leftBtn  : setVisible(true)
	end
	self.rightBtn : setVisible(false)

	self.loginLab : setString(string.format("珍宝阁第%s层",_G.Lang.number_Chinese[self.maxFloor]))

	local size = self.iconbgSpr[1]:getContentSize()
	local function func(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			
			local tag=sender:getTag()
			self:__showEquipEffect(self.iconbgSpr[tag%1000])
			print("tag",tag)
			self : __updateRight(tag)
		end
	end
	for k,v in pairs(self.iconbgSpr) do
		v:removeAllChildren()
	end
	self.m_scelectSpr = nil
	for i=1,6 do
		local iconName = _G.Cfg.hidden_make[_msg.goods_msg_no[i].goods_id].icon..".png"
		print(iconName)
		local btn = gc.CButton:create(iconName,iconName,iconName)
		btn       : addTouchEventListener(func)
		btn       : setTag(self.maxFloor*1000+i)
		btn       : setPosition(cc.p(size.width/2,size.height/2))
		
		if _msg.goods_msg_no[i].state==0 then
			btn:setGray()
			--btn:setEnabled(true)
			self.inLine[i] : setVisible(false)
		else
			btn:setDefault()
			--btn:setEnabled(false)
			self.inLine[i] : setVisible(true)
		end
		self.iconbgSpr[i]:addChild(btn)
	end

	local i    = 1
	for k,v in pairs(_msg.attr) do
		print(k,v)
		if v>0 then
			if i==1 then
				self.addLab1  : setString(string.format("%s",_G.Lang.type_name[k]))
				self.addData1 : setString(string.format("+%d",v))
			else
				self.addLab2  : setString(string.format("%s",_G.Lang.type_name[k]))
				self.addData2 : setString(string.format("+%d",v))
			end
			i    = i+1
		end
	end

	if i==1 then
		self.addLab1  : setString("")
		self.addLab2  : setString("")
		self.addData1 : setString("")
		self.addData2 : setString("")
	elseif i==2 then
		self.addLab2  : setString("")
		self.addData2 : setString("")
	end

	for i=1,6 do
		self.infoStrLab[i] : setString(_G.Lang.type_name[_G.Cfg.hidden_treasure[self.maxFloor*100+i].shuxing[1][1]])
		self.infoLab[i]    : setString("+".._G.Cfg.hidden_treasure[self.maxFloor*100+i].shuxing[1][2])
	end

	local Count = 0
	for i=1,6 do
		local count = 0
		for j=1,2 do
			local id = _G.Cfg.hidden_treasure[self.maxFloor*100+i].linking_items[j]
			for k,v in pairs(_msg.goods_msg_no) do
				if v.goods_id == id and v.state==1 then
					count = count + 1
				end
			end
		end
		print("count",count)
		if count==2 then
			self.outLine[i] : setVisible(true)
			self.infoStrLab[i] : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_SPRINGGREEN))
			self.infoLab[i]    : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_PBLUE))
			Count = Count + 1
		else
			self.outLine[i] : setVisible(false)
			self.infoStrLab[i] : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_GREY))
			self.infoLab[i]    : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_GREY))
		end
	end

	if Count == 6 then
		local newIcon  = cc.Sprite : createWithSpriteFrameName("treasure_in_2.png")
		self.inIcon : setSpriteFrame(newIcon:getSpriteFrame())
	else
		local newIcon  = cc.Sprite : createWithSpriteFrameName("treasure_in_1.png")
		self.inIcon : setSpriteFrame(newIcon:getSpriteFrame())
	end

	self.state = {}
	for i=1,6 do
		self.state[_msg.goods_msg_no[i].goods_id] = _msg.goods_msg_no[i].state
	end
	for i=1,6 do
		print("state",_msg.goods_msg_no[i].state,"id",_msg.goods_msg_no[i].goods_id)
		if _msg.goods_msg_no[i].state == 0 then
			print("state",_msg.goods_msg_no[i].state,"id",_msg.goods_msg_no[i].goods_id)
			self : __updateRight(_msg.goods_msg_no[i].goods_id)
			self:__showEquipEffect(self.iconbgSpr[i])
			return
		end
	end

	self : __updateRight(_msg.goods_msg_no[1].goods_id)
	
	self:__showEquipEffect(self.iconbgSpr[1])
end

function TreasureView.__updateLeft( self,_floor )
	print(self.curFloor,self.maxFloor)
	if self.curFloor==1 then
		self.leftBtn  : setVisible(false)
	else
		self.leftBtn  : setVisible(true)
	end

	if self.curFloor < self.maxFloor then
		self.rightBtn  : setVisible(true)
	else
		self.rightBtn  : setVisible(false)
	end

	self.loginLab : setString(string.format("珍宝阁第%s层",_G.Lang.number_Chinese[_floor]))

	local size = self.iconbgSpr[1]:getContentSize()
	local function func(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			local tag=sender:getTag()
			self:__showEquipEffect(self.iconbgSpr[tag%1000])
			print("tag",tag)
			self : __updateRight(tag)
		end
	end
	for k,v in pairs(self.iconbgSpr) do
		v:removeAllChildren()
	end
	self.m_scelectSpr = nil
	for i=1,6 do
		local iconName = _G.Cfg.hidden_make[_floor*1000+i].icon..".png"
		print(iconName)
		local btn = gc.CButton:create(iconName,iconName,iconName)
		btn       : addTouchEventListener(func)
		btn       : setTag(_floor*1000+i)
		btn       : setPosition(cc.p(size.width/2,size.height/2))
		self.iconbgSpr[i]:addChild(btn)
	end

	for i=1,6 do
		self.infoStrLab[i] : setString(_G.Lang.type_name[_G.Cfg.hidden_treasure[_floor*100+i].shuxing[1][1]])
		self.infoLab[i]    : setString("+".._G.Cfg.hidden_treasure[_floor*100+i].shuxing[1][2])
	end

	for i=1,6 do
		self.inLine[i] : setVisible(true)
		self.outLine[i]: setVisible(true)
		self.infoStrLab[i] : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_SPRINGGREEN))
		self.infoLab[i]    : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_PBLUE))
	end

	local newIcon  = cc.Sprite : createWithSpriteFrameName("treasure_in_2.png")
	self.inIcon : setSpriteFrame(newIcon:getSpriteFrame())

	self : __updateRight(_floor*1000+1)
	
	self:__showEquipEffect(self.iconbgSpr[1])
end

function TreasureView.__updateRight( self,_id )
	print("id",_id)
	self.makeID = _id
	for k,v in pairs(self.rolebgSpr) do
		v : removeAllChildren()
	end

	local function func(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			local tag=sender:getTag()
			print("tag",tag)
		end
	end
	local size = self.rolebgSpr[1]:getContentSize()
	local iconName = _G.Cfg.hidden_make[_id].icon..".png"
	print(iconName)
	local btn = gc.CButton:create(iconName,iconName,iconName)
	btn       : addTouchEventListener(func)
	btn       : setTag(_id)
	btn       : setPosition(cc.p(size.width/2,size.height/2))
	btn       : setEnabled(false)
	self.rolebgSpr[1]:addChild(btn)

	self.goodsName : setString(_G.Cfg.hidden_make[_id].name)

	local winSize = cc.Director:getInstance():getVisibleSize()
	local function cFun(sender,eventType)
      	if eventType==ccui.TouchEventType.ended then
          	local nTag=sender:getTag()
          	local nPos=sender:getWorldPosition()
          	print("Tag",nTag)
          	local rootBgSize = cc.size(790,412)
          	if nPos.y>winSize.height/2+rootBgSize.height/2-50 
            or nPos.y<winSize.height/2-rootBgSize.height/2-25
            then return end

            local goodNums = _G.GBagProxy:getGoodsCountById(nTag)
    		local allGoods = _G.Cfg.hidden_make[_id].make[1][2]
    		local id = _G.Cfg.hidden_make[_id].make[1][3]
            local roleProperty=_G.GPropertyProxy:getMainPlay()
            roleProperty:setTaskInfo(_G.Const.CONST_TASK_TRACE_MATERIAL,id,_G.Cfg.scene_copy[id].belong_id,goodNums,allGoods,nTag)

          	local bagType=_G.Const.CONST_GOODS_SITE_TREASUREUNLOAD
          	local temp=_G.TipsUtil:createById(nTag,bagType,nPos,1)
          	cc.Director:getInstance():getRunningScene():addChild(temp,1000)
      	end
  	end

  	local function cFun1(sender,eventType)
      	if eventType==ccui.TouchEventType.ended then
          	local nTag=sender:getTag()
          	local nPos=sender:getWorldPosition()
          	print("Tag",nTag)
          	local rootBgSize = cc.size(790,412)
          	if nPos.y>winSize.height/2+rootBgSize.height/2-50 
            or nPos.y<winSize.height/2-rootBgSize.height/2-25
            then return end

            local goodNums = _G.GBagProxy:getGoodsCountById(nTag)
    		local allGoods = _G.Cfg.hidden_make[_id].make[2][2]
    		local id = _G.Cfg.hidden_make[_id].make[2][3]
            local roleProperty=_G.GPropertyProxy:getMainPlay()
            roleProperty:setTaskInfo(_G.Const.CONST_TASK_TRACE_MATERIAL,id,_G.Cfg.scene_copy[id].belong_id,goodNums,allGoods,nTag)

          	local bagType=_G.Const.CONST_GOODS_SITE_TREASUREUNLOAD
          	local temp=_G.TipsUtil:createById(nTag,bagType,nPos,1)
          	cc.Director:getInstance():getRunningScene():addChild(temp,1000)
      	end
  	end
  	size = self.rolebgSpr[2]:getContentSize()
	for i=2,3 do
		local node = _G.Cfg.goods[_G.Cfg.hidden_make[_id].make[i-1][1]]

		local iconBtn = 0
		if i==2 then
			iconBtn=_G.ImageAsyncManager:createGoodsBtn(node,cFun,node.id)
		else
			iconBtn=_G.ImageAsyncManager:createGoodsBtn(node,cFun1,node.id)
		end
    	iconBtn:setPosition(size.width/2,size.height/2)
    	iconBtn:setSwallowTouches(false)
    	self.rolebgSpr[i]:addChild(iconBtn)

    	local goodNums = _G.GBagProxy:getGoodsCountById(node.id)
    	local allGoods = _G.Cfg.hidden_make[_id].make[i-1][2]

    	local goodsCount = _G.Util : createLabel(string.format("%d/%d",goodNums,allGoods),20)
    	if goodNums < allGoods then
    		goodsCount : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_RED))
    	else
    		goodsCount : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_SPRINGGREEN))
    	end
    	goodsCount : setAnchorPoint(cc.p(1,0))
		goodsCount : setPosition(cc.p(size.width-5,0))
		self.rolebgSpr[i]    : addChild(goodsCount)
	end

	if self.curFloor == self.maxFloor then
		if self.state[_id] == 0 then
			self.dazaoBtn:setDefault()
			self.dazaoBtn:setEnabled(true)
			self.dazaoBtn:setTitleText("打 造")
		else
			self.dazaoBtn:setGray()
			self.dazaoBtn:setEnabled(false)
			self.dazaoBtn:setTitleText("已打造")
		end
		
	else
		self.dazaoBtn:setGray()
		self.dazaoBtn:setEnabled(false)
		self.dazaoBtn:setTitleText("已打造")
	end
end

function TreasureView.__showEquipEffect(self,_sender)
    if _sender==nil then return end

    if self.m_scelectSpr~=nil then
        self.m_scelectSpr:retain()
        self.m_scelectSpr:removeFromParent(false)
        _sender:addChild(self.m_scelectSpr,20)
        self.m_scelectSpr:release()
        return
    end

    self.m_scelectSpr=cc.Sprite:create()
    self.m_scelectSpr:runAction(cc.RepeatForever:create(_G.AnimationUtil:getSelectBtnAnimate()))
    self.m_scelectSpr:setPosition(85/2-3,85/2)
    _sender:addChild(self.m_scelectSpr,20)
end

function TreasureView.showStrengthOkEffect(self)
    self.StrengSpr = "main_effect_word_dz1.png"
    self.YESorNO = "main_effect_word_cg1.png"
    self.szPlist="anim/task_finish.plist"
    self.szFram="task_finish_"
    _G.Util:playAudioEffect("ui_strengthen_success")

    if self.m_StrengthOkSpr~=nil then return end
    self.m_StrengthOkSpr=cc.Sprite:createWithSpriteFrameName(self.StrengSpr)
    self.m_StrengthOkSpr:setScale(0.05)
    self.m_StrengthOkSpr:setPosition(0,0)
    -- self.m_container:addChild(self.m_StrengthOkSpr,1000)

    self.rightSpr       : addChild(self.m_StrengthOkSpr,1000)    
    self.m_StrengthOkSpr : setPosition(rightSize.width/2-20,rightSize.height*0.85)

    local addSpr =  cc.Sprite:createWithSpriteFrameName(self.YESorNO) 
    self.m_StrengthOkSpr : addChild(addSpr)
    local sprsize  = self.m_StrengthOkSpr : getContentSize()
    local sprsize2 = addSpr : getContentSize()
    addSpr : setPosition(sprsize.width+sprsize2.width/2,sprsize.height/2)

    local function f1()
        self.m_StrengthOkSpr:removeFromParent(true)
        self.m_StrengthOkSpr=nil
    end
    local function f2()
        local action=cc.Sequence:create(cc.FadeTo:create(0.15,0),cc.CallFunc:create(f1))
        self.m_StrengthOkSpr:runAction(action)
    end
    local function f3()
        local act1=_G.AnimationUtil:createAnimateAction(self.szPlist,self.szFram,0.12)
        local act2=cc.CallFunc:create(f2)

        local sprSize=self.m_StrengthOkSpr:getContentSize()
        local effectSpr=cc.Sprite:create()
        effectSpr:setPosition(sprSize.width,sprSize.height*0.5)
        effectSpr:runAction(cc.Sequence:create(act1,act2))
        self.m_StrengthOkSpr:addChild(effectSpr)
    end
    local action=cc.Sequence:create(cc.ScaleTo:create(0.15,1),cc.CallFunc:create(f3))
    self.m_StrengthOkSpr:runAction(action)
end

function TreasureView.init( self )
	local function nCloseFun()
		self : unregister()
		local roleProperty=_G.GPropertyProxy:getMainPlay()
        roleProperty:setTaskInfo()
        if self.m_rootLayer == nil then return end
    	self.m_rootLayer=nil
		cc.Director:getInstance():popScene()
	end
	self.m_normalView:addCloseFun(nCloseFun)

	self : initView()
end

function TreasureView.unregister(self)
   self.pMediator : destroy()
   self.pMediator = nil 
end

return TreasureView