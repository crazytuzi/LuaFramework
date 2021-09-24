local IntensifyLayer   = classGc(view,function ( self ,_curUid)
	self.m_winSize     = cc.Director : getInstance() : getVisibleSize()
	self.m_curRoleUid  = _curUid

	self.goods2Flag = true
  	self.goods3Flag = true

  	self.flag1 = false
  	self.flag2 = false
  	
end)

local isBuyTip = false
local FONTSIZE = 20
local viewSize = cc.size(360,360)

function IntensifyLayer.create(self,_idx)
	print("IntensifyLayer",_idx)
	self.artifactIdx=_idx
    self : __init()

	self.m_rootLayer = cc.Node : create()
	self             : __initParment()
	self  			 : __initView()
	self 			 : __updateGoods()

    return self.m_rootLayer
end

function IntensifyLayer.updataIndex(self,_idx,_true)
	self.artifactIdx=_idx
    self 			 : __updateGoods()
end

function IntensifyLayer.__init(self)
    self : register()
end

function IntensifyLayer.register(self)
    self.pMediator = require("mod.artifact.IntensifyMediator")(self)
end
function IntensifyLayer.unregister(self)
    self.pMediator : destroy()
    self.pMediator = nil 
end

function IntensifyLayer.__initParment(self)
    self.m_myProperty=_G.GPropertyProxy:getOneByUid(0,_G.Const.CONST_PLAYER)

    if self.m_myProperty==nil then return end
end

function IntensifyLayer.__initView( self )
	print("..............创建强化面板..............")
	local titleLab=_G.Util:createLabel("属性提升",FONTSIZE+4)
	titleLab:setPosition(30,165)
	self.m_rootLayer:addChild(titleLab)

	local tipsLab=_G.Util:createLabel("强化消耗",FONTSIZE)
	tipsLab:setPosition(30,-35)
	self.m_rootLayer:addChild(tipsLab)

	self.goodsName   = _G.Util : createLabel("",20)
	-- self.goodsName   : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_YELLOWISH))
	self.goodsName   : setPosition(cc.p(-65,125))
	self.m_rootLayer   : addChild(self.goodsName)

	self.willName   = _G.Util : createLabel("",20)
	-- self.willName   : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_YELLOWISH))
	self.willName   : setPosition(cc.p(120,125))
	self.m_rootLayer   : addChild(self.willName)

	local lineSpr1 = ccui.Scale9Sprite : createWithSpriteFrameName("general_double_line.png")
	local lineSize = lineSpr1:getContentSize()
	lineSpr1 : setPreferredSize(cc.size(viewSize.width-2,lineSize.height))
	lineSpr1 : setPosition(30,-20)
	self.m_rootLayer : addChild(lineSpr1)

	self.material = {}

	local box_1   = cc.Sprite : createWithSpriteFrameName("general_tubiaokuan.png")
	box_1 		  : setScale(0.8)
	box_1   	  : setPosition(cc.p(-90,-83))
	self.m_rootLayer 	 : addChild(box_1)
	self.material[1] = box_1
	--local icon_1     =_G.ImageAsyncManager:createGoodsSpr(_G.Cfg.goods[id])	

	local box_2   = cc.Sprite : createWithSpriteFrameName("general_tubiaokuan.png")
	box_2 		  : setScale(0.8)
	box_2   	  : setPosition(cc.p(10,-83))
	self.m_rootLayer : addChild(box_2)
	self.material[2] = box_2

	local function checkEvent1(sender, eventType)
        if eventType==ccui.TouchEventType.ended then
        	if self.goods2Flag then
        		
        	else
        		local command = CErrorBoxCommand( 30630 )
	         	controller : sendCommand(command)
	         	sender     : setSelected(true)
	         	return
        	end
        	self.flag1 = not self.flag1
        end
    end

    self.checkbox1  = ccui.CheckBox : create()
    self.checkbox1 	: loadTextures("general_check_cancel.png","general_check_cancel.png","general_check_selected.png","","",ccui.TextureResType.plistType)
    self.checkbox1 	: setPosition(cc.p(65,-96))
    self.checkbox1 	: setName("")
    self.checkbox1 	: addTouchEventListener(checkEvent1)
    self.m_rootLayer : addChild(self.checkbox1)

	local box_3 = cc.Sprite : createWithSpriteFrameName("general_tubiaokuan.png")
	box_3 	    : setScale(0.8)
	box_3       : setPosition(cc.p(120,-83))
	self.m_rootLayer : addChild(box_3)
	self.material[3] = box_3

	local function checkEvent2(sender, eventType)
        if eventType==ccui.TouchEventType.ended then
        	if self.goods3Flag then
        		
        	else
        		local command = CErrorBoxCommand( 30630 )
	         	controller : sendCommand(command)
	         	sender     : setSelected(true)
	         	return
        	end
        	self.flag2 = not self.flag2
        	if self.m_per then
        		if  self.flag2 then
        			print("id",self.goodsTab.goods_id3)
        			self.succeedData : setString(string.format("成功率%d%%",(self.m_per+_G.Cfg.goods[self.goodsTab.goods_id3].d.as1)/100))
        		else
        			self.succeedData : setString(string.format("成功率%d%%",self.m_per/100))
        		end
        	end
        end
    end

    self.checkbox2  = ccui.CheckBox : create()
    self.checkbox2 	: loadTextures("general_check_cancel.png","general_check_cancel.png","general_check_selected.png","","",ccui.TextureResType.plistType)
    self.checkbox2 	: setPosition(cc.p(175,-96))
    self.checkbox2 	: setName("")
    self.checkbox2 	: addTouchEventListener(checkEvent2)
    self.m_rootLayer 	: addChild(self.checkbox2)

	local icon       = cc.Sprite : createWithSpriteFrameName("ui_artifact_right.png")
	icon   	         : setPosition(cc.p(30,60))
	self.m_rootLayer : addChild(icon)

	self.succeedData = _G.Util : createLabel("",20)
	self.succeedData : setPosition(cc.p(30,-185))
	self.m_rootLayer   : addChild(self.succeedData)

	self.beginAttr = {}
	self.endAttr   = {}

	self.beginAttr[1]= _G.Util : createLabel("",20)
	-- self.beginAttr[1]: setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LBLUE))
	self.beginAttr[1]: setAnchorPoint(cc.p(0,0.5)) 
	self.beginAttr[1]: setPosition(cc.p(-110,80))
	self.m_rootLayer   : addChild(self.beginAttr[1])

	self.beginAttr[2]= _G.Util : createLabel("",20)
	-- self.beginAttr[2]: setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LBLUE))
	self.beginAttr[2]: setAnchorPoint(cc.p(0,0.5)) 
	self.beginAttr[2]: setPosition(cc.p(-110,40))
	self.m_rootLayer   : addChild(self.beginAttr[2])

	self.endAttr[1]= _G.Util : createLabel("",20)
	self.endAttr[1]: setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_SPRINGGREEN))
	self.endAttr[1]: setAnchorPoint(cc.p(0,0.5)) 
	self.endAttr[1]: setPosition(cc.p(80,80))
	self.m_rootLayer : addChild(self.endAttr[1])

	self.endAttr[2]= _G.Util : createLabel("",20)
	self.endAttr[2]: setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_SPRINGGREEN))
	self.endAttr[2]: setAnchorPoint(cc.p(0,0.5)) 
	self.endAttr[2]: setPosition(cc.p(80,40))
	self.m_rootLayer : addChild(self.endAttr[2]) 

	self.maxLv = _G.Util : createLabel("本阶强化已满",20)
	self.maxLv : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
	self.maxLv : setAnchorPoint(cc.p(0,0.5)) 
	self.maxLv : setPosition(cc.p(75,60))
	self.m_rootLayer : addChild(self.maxLv)
	self.maxLv : setVisible(false)     

	local function intensifyEvent( send,eventType )
		if eventType == ccui.TouchEventType.ended then
			local goodNum1 = _G.GBagProxy:getGoodsCountById(self.goodsTab.goods_id)
			local goodNum2 = _G.GBagProxy:getGoodsCountById(self.goodsTab.goods_id2)
			local goodNum3 = _G.GBagProxy:getGoodsCountById(self.goodsTab.goods_id3)

			print("num1",goodNum1,"num2",goodNum2,"num3",goodNum3)
			print("是否选中保护符",self.flag1)
			print("是否选中祝福符",self.flag2)

			if goodNum1 <= 0 or (self.flag1 and goodNum2 <= 0) or (self.flag2 and goodNum3 <= 0) then
				print("···")
				if isBuyTip then
					self : sendIntensifyMsg()
				else
					local rmb = 0
					if goodNum1 <= 0 then
						rmb = rmb + self.goodsTab.rmb
					end

					if self.flag1 and goodNum2 <= 0 then
						rmb = rmb + self.goodsTab.rmb2
					end

					if self.flag2 and goodNum3 <= 0 then
						rmb = rmb + self.goodsTab.rmb3
					end

					self : __initBuyLayer(rmb)
				end
			else
				self : sendIntensifyMsg()
			end
		end
		return false
	end 

	self.m_button  = gc.CButton:create()
	self.m_button  : addTouchEventListener(intensifyEvent)
	self.m_button  : loadTextures("general_btn_gold.png")
	self.m_button  : setTitleText("强 化")
	self.m_button  : setTitleFontSize(FONTSIZE+2)
	self.m_button  : setTitleFontName(_G.FontName.Heiti)
	self.m_button  : setPosition(cc.p(30,-150))
	self.m_rootLayer : addChild(self.m_button)
	self.m_button  : setGray()
	self.m_button  : setEnabled(false)
end

function IntensifyLayer.sendIntensifyMsg( self )
	local data1 = 0
	local data2 = 0
	if self.flag1 then
		data1 = 1
	else
		data1 = 0
	end

	if self.flag2 then
		data2 = 1
	else
		data2 = 0
	end

	local msg = REQ_MAGIC_EQUIP_ENHANCED()
	msg       : setArgs(self.m_curRoleUid,self.node.type_sub,data2,data1)
	_G.Network: send(msg)
end

function IntensifyLayer.__updateGoods( self )
	print("self.artifactIdx",self.artifactIdx)
	local mainplay = self.m_myProperty
    if mainplay==nil then return end
    local m_equipList  = mainplay:getArtifactEquipList()  --装备数据
    local newEquipList = {}
    --table.sort( m_equipList, function ( a,b ) return a.index<b.index end )

    local flag = false
    for k,v in pairs(m_equipList) do
    	print(k,v.index)
    	newEquipList[v.index] = v
    	if v.index == self.artifactIdx then
    		flag = true
    	end
    end
    self : __clearMsg()

    if flag then
        local id    = newEquipList[self.artifactIdx].goods_id
        local index = newEquipList[self.artifactIdx].index
        local node  = _G.Cfg.goods[id]

        if node == nil then return end
        self.node = node

        local msg = REQ_MAGIC_EQUIP_STRENG()
        msg       : setArgs(0,self.artifactIdx)
        _G.Network: send(msg)
    else
    	self.goodsName : setString("") 
    	self.willName  : setString("")
    end    
end

function IntensifyLayer.__clearMsg( self )
	self.m_button  : setGray()
	self.m_button  : setEnabled(false)
	self.goods2Flag = true
  	self.goods3Flag = true
  	-- self.flag1 = false
  	-- self.flag2 = false
  	-- self.checkbox1 : setSelected(false)
  	-- self.checkbox2 : setSelected(false)
	self.goodsName : setString("")
	self.willName  : setString("")
	self.succeedData:setString("") 
	-- self.goodsDins : removeAllChildren()
	for i=1,2 do
		self.beginAttr[i] : setString("")
		self.endAttr[i]   : setString("")
	end
	for k,v in pairs(self.material) do
		v : removeAllChildren()
	end
	self.m_per = nil
end

function IntensifyLayer.updateMsg( self,_msg )
	print("强化等级",_msg.streng,_msg.count2)
	print(_msg.attr1[1].type,_msg.attr1[2].type)
	print(_msg.attr1[1].attr,_msg.attr1[2].attr)
	print(_msg.attr2[1].type,_msg.attr2[2].type)
	print(_msg.attr2[1].attr,_msg.attr2[2].attr)
	local strengLv = _msg.streng+1
	
	local goodsStr = string.format("%s+%d",self.node.name,_msg.streng)
	if _msg.streng==0 then
		goodsStr = self.node.name
	end
	self.goodsName : setString(goodsStr)
    self.goodsName : setColor(_G.ColorUtil:getRGB(self.node.name_color)) 

    self.willName : setString(string.format("%s+%d",self.node.name,_msg.streng+1))
    self.willName : setColor(_G.ColorUtil:getRGB(self.node.name_color)) 

	for i=1,2 do
		self.beginAttr[i]:setString(string.format("%s+%d",_G.Lang.type_name[_msg.attr1[i].type],_msg.attr1[i].attr))
		if _msg.streng ~= _G.Const.CONST_MAGIC_EQUIP_STRENGTHEN_MAX then
			self.endAttr[i]:setString(string.format("%s+%d",_G.Lang.type_name[_msg.attr2[i].type],_msg.attr2[i].attr))
		else
			self.endAttr[i]:setString("")	
		end
	end

	if _msg.streng == _G.Const.CONST_MAGIC_EQUIP_STRENGTHEN_MAX then
		self.m_button  : setGray()
		self.m_button  : setEnabled(false)
		self.maxLv     : setVisible(true)
		self.willName  : setVisible(false)

		strengLv = strengLv - 1
	else
		self.m_button  : setDefault()
		self.m_button  : setEnabled(true)
		self.maxLv     : setVisible(false)
		self.willName  : setVisible(true)
	end
	
	local btnSize = self.material[1] : getContentSize()
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

          	local bagType=_G.Const.CONST_GOODS_SITE_ROLEBACKPACK
          	local temp=_G.TipsUtil:createById(nTag,bagType,nPos,self.m_curRoleUid)
          	cc.Director:getInstance():getRunningScene():addChild(temp,1000)
      	end
  	end

  	self.goods2Flag = true
  	self.goods3Flag = true

  	self.goodsTab = _G.Cfg.magic_price[self.node.class][strengLv]
	for i=1,3 do
		local node = 0
		if i==1 then
			node = _G.Cfg.goods[_G.Cfg.magic_price[self.node.class][strengLv].goods_id]
		elseif i==2 then
			node = _G.Cfg.goods[_G.Cfg.magic_price[self.node.class][strengLv].goods_id2]
			if _G.Cfg.magic_price[self.node.class][strengLv].rmb2 == 0 then
				self.goods2Flag = false
			end
		elseif i==3 then
			node = _G.Cfg.goods[_G.Cfg.magic_price[self.node.class][strengLv].goods_id3]
			if _G.Cfg.magic_price[self.node.class][strengLv].rmb3 == 0 then
				self.goods3Flag = false
			end
		end
		self.material[i]:removeAllChildren()

		local iconBtn=_G.ImageAsyncManager:createGoodsBtn(node,cFun,node.id)
    	iconBtn:setPosition(btnSize.width/2,btnSize.height/2)
    	iconBtn:setSwallowTouches(false)
    	self.material[i]:addChild(iconBtn)

    	local goodNums = _G.GBagProxy:getGoodsCountById(node.id)

    	local goodsCount = _G.Util : createLabel(string.format("%d/1",goodNums),20)
    	if goodNums == 0 then
    		goodsCount : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
    	else
    		goodsCount : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
    	end
    	goodsCount : setAnchorPoint(cc.p(1,0))
		goodsCount : setPosition(cc.p(btnSize.width-5,0))
		self.material[i] : addChild(goodsCount)
	end
	self.m_per = _msg.per
	--self.succeedData : setString(string.format("成功率%d%%",_msg.per/100))
	if  self.flag2 then
		print("self.flag2",self.goodsTab.goods_id3)
		self.succeedData : setString(string.format("成功率%d%%",(self.m_per+_G.Cfg.goods[self.goodsTab.goods_id3].d.as1)/100))
	else
		self.succeedData : setString(string.format("成功率%d%%",self.m_per/100))
	end
end

function IntensifyLayer.updatePower( self,result )
	print("updatePower===>>>>",result)
	self : showStrengthOkEffect(result)
	self : __updateGoods()
end

function IntensifyLayer.showStrengthOkEffect(self,_isTrue)
    -- if self.tempObj~=nil then
    --     self.tempObj:start()
    --     return
    -- end
    if _isTrue==1 then 
      local tempGafAsset=gaf.GAFAsset:create("gaf/qianghuachenggong.gaf")
      self.tempObj=tempGafAsset:createObject()
      local nPos=cc.p(30,60)
      self.tempObj:setLooped(false,false)
      self.tempObj:start()
      self.tempObj:setPosition(nPos)
      self.m_rootLayer : addChild(self.tempObj,1000)
    else
      local tempGafAsset=gaf.GAFAsset:create("gaf/qianghuashibai.gaf")
      self.tempObj=tempGafAsset:createObject()
      local nPos=cc.p(30,60)
      self.tempObj:setLooped(false,false)
      self.tempObj:start()
      self.tempObj:setPosition(nPos)
      self.m_rootLayer : addChild(self.tempObj,1000)
    end
end

function IntensifyLayer.__initBuyLayer( self,_rmb )
	print("初始化竞技场购买界面")

	local function buy()
		self : sendIntensifyMsg()
    end

    local function cancel( ... )
    	print("取消")
    end

    local topLab    = string.format("花费%d钻石购买强化所需材料",_rmb)

    local rightLab  = _G.Lang.LAB_N[106]

    local szSureBtn = _G.Lang.BTN_N[1]

    local view  = require("mod.general.TipsBox")()
    local tipsNode = view : create("",buy,cancel)
    -- tipsNode 		: setPosition(cc.p(self.m_winSize.width/2,self.m_winSize.height/2))
    cc.Director : getInstance() : getRunningScene() : addChild(tipsNode,_G.Const.CONST_MAP_ZORDER_NOTIC,332211)

    local layer=view:getMainlayer()
    view:setTitleLabel("提示")
    if topLab ~= nil then
    	print("top=================>")
        local label =_G.Util : createLabel(topLab,20)
		label 		: setPosition(cc.p(0,40))
		layer 		: addChild(label,88)
    end
    if rightLab then
    	print("right===========>")
    	local label =_G.Util : createLabel(rightLab,23)
		label 		: setPosition(cc.p(25,-22))
		layer 		: addChild(label,88)
    end
    if szSureBtn ~= nil then
        view : setSureBtnText(szSureBtn)
    end

    local function c(sender, eventType)
        if eventType==ccui.TouchEventType.ended then
            print("勾选了不再提示",isBuyTip)
            if isBuyTip then
            	isBuyTip = false
            else
            	isBuyTip = true
            end
        end
    end

    local checkbox   = ccui.CheckBox : create()
    checkbox 	     : loadTextures("general_gold_floor.png","general_gold_floor.png","general_check_selected.png","","",ccui.TextureResType.plistType)
    checkbox 	     : setPosition(cc.p(-90,-20))
    checkbox 	     : setName("")
    checkbox 	     : addTouchEventListener(c)
    -- checkbox 	     : setAnchorPoint(cc.p(1,0.5))
    layer 			 : addChild(checkbox)
end

return IntensifyLayer