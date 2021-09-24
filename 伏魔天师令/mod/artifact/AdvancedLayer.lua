local AdvancedLayer   = classGc(view,function ( self,_curUid )
	self.m_winSize     = cc.Director : getInstance() : getVisibleSize()
	self.m_curRoleUid  = _curUid
end)

local viewSize = cc.size(360,360) 
local FONTSIZE = 20

function AdvancedLayer.create(self,_idx)
	self.artifactIdx=_idx
    self : __init()

	self.m_rootLayer = cc.Node : create()
	self             : __initParment()
	self  			 : __initView()
	self 			 : __updateGoods()
    return self.m_rootLayer
end

function AdvancedLayer.updataIndex(self,_idx,_true)
    self.artifactIdx = _idx
    self 			 : __updateGoods()
end

function AdvancedLayer.__init(self)
    self : register()
end

function AdvancedLayer.register(self)
    self.pMediator = require("mod.artifact.AdvancedMediator")(self)
end
function AdvancedLayer.unregister(self)
    self.pMediator : destroy()
    self.pMediator = nil 
end

function AdvancedLayer.__initParment(self)
	print("m_curRoleUid",self.m_curRoleUid)
    self.m_myProperty=_G.GPropertyProxy:getOneByUid(0,_G.Const.CONST_PLAYER)

    if self.m_myProperty==nil then return end

    -- self.m_myPartner=self.m_myProperty:getWarPartner()
    -- print("EquipLayer.__initParmen===>",self.m_myPartner)
    -- if self.m_myPartner~=nil then
    --     self.m_partnerIdx=self.m_myPartner:getPartner_idx()
    --     self.m_partnerId=self.m_myPartner:getPartnerId() or 0
    --     print("有出战的伙伴  idx=",self.m_partnerIdx)
    -- end
end

function AdvancedLayer.__initView( self )
	print("..............创建进阶面板..............")
	local titleLab=_G.Util:createLabel("属性提升",FONTSIZE+4)
	titleLab:setPosition(30,165)
	self.m_rootLayer:addChild(titleLab)

	local icon       = cc.Sprite : createWithSpriteFrameName("ui_artifact_right.png")
	icon   	         : setPosition(cc.p(30,40))
	self.m_rootLayer : addChild(icon)

	self.beginName   = _G.Util : createLabel("神兵名称二阶",FONTSIZE)
	-- self.beginName   : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_YELLOWISH))
	self.beginName   : setPosition(cc.p(-60,125))
	self.m_rootLayer : addChild(self.beginName)

	self.endName   = _G.Util : createLabel("神兵名称二阶",FONTSIZE)
	self.endName   : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
	self.endName   : setPosition(cc.p(125,125))
	self.m_rootLayer : addChild(self.endName)

	local lineSpr1 = ccui.Scale9Sprite : createWithSpriteFrameName("general_double_line.png")
	local lineSize = lineSpr1:getContentSize()
	lineSpr1 : setPreferredSize(cc.size(viewSize.width-2,lineSize.height))
	lineSpr1 : setPosition(30,-60)
	self.m_rootLayer : addChild(lineSpr1)

	local function intensifyEvent( send,eventType )
		if eventType == ccui.TouchEventType.ended then
			if self.notgoods==true then
				self:goodsReturn()
				return
			end
			local msg = REQ_MAGIC_EQUIP_ADVANCE()
			msg       : setArgs(0,self.artifactIdx)
			_G.Network: send(msg)
		end
		return false
	end 

	self.m_button  = gc.CButton:create()
	self.m_button  : addTouchEventListener(intensifyEvent)
	self.m_button  : loadTextures("general_btn_gold.png")
	self.m_button  : setTitleText("升 阶")
	self.m_button  : setTitleFontSize(FONTSIZE+2)
	self.m_button  : setTitleFontName(_G.FontName.Heiti)
	self.m_button  : setPosition(cc.p(30,-150))
	self.m_rootLayer : addChild(self.m_button)

	self.beginAttr = {}
	self.endAttr   = {}
	local posY=60
	for i=1,2 do
		if i==2 then posY=20 end
		self.beginAttr[i]= _G.Util : createLabel("",FONTSIZE)
		-- self.beginAttr[i]: setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LBLUE))
		self.beginAttr[i]: setAnchorPoint(cc.p(0,0.5)) 
		self.beginAttr[i]: setPosition(cc.p(-110,posY))
		self.m_rootLayer   : addChild(self.beginAttr[i])

		self.endAttr[i]= _G.Util : createLabel("",FONTSIZE)
		self.endAttr[i]: setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_SPRINGGREEN))
		self.endAttr[i]: setAnchorPoint(cc.p(0,0.5)) 
		self.endAttr[i]: setPosition(cc.p(80,posY))
		self.m_rootLayer : addChild(self.endAttr[i])
	end

	self.maxLv = _G.Util : createLabel("已升至最高阶",FONTSIZE)
	self.maxLv : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
	self.maxLv : setAnchorPoint(cc.p(0,0.5)) 
	self.maxLv : setPosition(cc.p(80,40))
	self.m_rootLayer : addChild(self.maxLv)
	self.maxLv : setVisible(false) 

	self.uplvLab=_G.Util:createLabel("升阶消耗：",FONTSIZE)
	self.uplvLab:setPosition(0,-95)
	self.m_rootLayer:addChild(self.uplvLab)

	self.goodsCount = _G.Util : createLabel("",20)
	self.goodsCount : setAnchorPoint(cc.p(0,0.5))
	self.goodsCount : setPosition(cc.p(50,-95))
	self.m_rootLayer   : addChild(self.goodsCount)
end

function AdvancedLayer.__updateGoods( self )
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
        self.goods_id=id
        if node == nil then return end

     --    if newEquipList[self.artifactIdx].strengthen < _G.Const.CONST_MAGIC_EQUIP_STRENGTHEN_LV then
     --    	if self.result and self.result then
     --    		self.result = nil
     --    		return
     --    	end
	    --     local command = CErrorBoxCommand(30620)
   	 --        controller : sendCommand( command )
	    --     return
	    -- end

        self.m_button   : setDefault()
		self.m_button   : setEnabled(true)
        self.node = node

        local streng=node.name
        if newEquipList[self.artifactIdx].strengthen>0 then
        	streng=string.format("%s+%d",node.name,newEquipList[self.artifactIdx].strengthen)
        end
        self.beginName:setString(streng)
        self.beginName:setColor(_G.ColorUtil:getRGB(node.name_color))

        local next_id = _G.Cfg.equip_make[id].make1.goods

        if next_id == 0 then
        	local material_id = _G.Cfg.equip_make[id].make1.goods_list[1][1]
        	local goodNums = _G.GBagProxy:getGoodsCountById(material_id)
        	self.goodsCount : setString(string.format("%d/0",goodNums))
        	self.goodsCount : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
        	self.maxLv      : setVisible(true)
        	self.m_button   : setGray()
			self.m_button   : setEnabled(false)
        else
        	local material_id = _G.Cfg.equip_make[id].make1.goods_list[1][1]
        	local material_count = _G.Cfg.equip_make[id].make1.goods_list[1][2]

	        self.endName:setString(_G.Cfg.goods[next_id].name)
        	self.endName:setColor(_G.ColorUtil:getRGB(_G.Cfg.goods[next_id].name_color))

	    	local goodNums = _G.GBagProxy:getGoodsCountById(material_id)

	    	self.materialName=_G.Cfg.goods[material_id].name
	    	self.uplvLab : setString(string.format("消耗%s：",self.materialName))
	    	self.goodsCount : setString(string.format("%d/%d",goodNums,material_count))
	    	self.goodsCount : setPosition(cc.p(self.uplvLab:getContentSize().width/2,-95))
	    	if goodNums < material_count then
	    		self.goodsCount : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
	    		self.notgoods = true
	    	else
	    		print("self.goodsCount22222222")
	    		self.goodsCount : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
	    		self.m_button  : setDefault()
				self.m_button  : setEnabled(true)
				self.notgoods = false
	    	end
        end

        local msg = REQ_MAGIC_EQUIP_REQUEST_ADVANCE()
        msg       : setArgs(0,self.artifactIdx)
        _G.Network: send(msg)
    end    
end

function AdvancedLayer.goodsReturn(self)
	local _szMsg=string.format("%s不足，是否前往商城兑换？",self.materialName)
	local function fun1()
		print("跳转CONST_FUNC_OPEN_SHOP_SHENQI")
        _G.GLayerManager:openSubLayer(_G.Const.CONST_FUNC_OPEN_SHOP,nil,_G.Const.CONST_MALL_TYPE_SUB_MAGICS)
	end
	local view=require("mod.general.TipsBox")()
	local layer=view:create(_szMsg,fun1)
	cc.Director:getInstance():getRunningScene():addChild(layer,_G.Const.CONST_MAP_ZORDER_NOTIC)
end

function AdvancedLayer.updatePower( self )	
	self : __updateGoods()
	self : showStrengthOkEffect()
end

function AdvancedLayer.showStrengthOkEffect(self)
	local tempGafAsset=gaf.GAFAsset:create("gaf/qianghuachenggong.gaf")
	self.tempObj=tempGafAsset:createObject()
	local nPos=cc.p(30,60)
	self.tempObj:setLooped(false,false)
	self.tempObj:start()
	self.tempObj:setPosition(nPos)
	self.m_rootLayer : addChild(self.tempObj,1000)
end

function AdvancedLayer.__clearMsg( self )
	self.m_button   : setGray()
	self.m_button   : setEnabled(false)
	self.beginName  : setString("")
	self.endName    : setString("")
	self.maxLv      : setVisible(false)
	for i=1,2 do
		self.beginAttr[i] : setString("")
		self.endAttr[i]   : setString("")
	end
end

function AdvancedLayer.updateMsg( self,_msg )
	self.endName:setString("")
	if _msg.msg_goods.goods_id~=0 then
		self.endName:setString(_G.Cfg.goods[_msg.msg_goods.goods_id].name.."+".._msg.msg_goods.strengthen)
	end
	for i=1,2 do
		self.beginAttr[i]:setString(string.format("%s+%d",_G.Lang.type_name[_msg.attr1[i].type],_msg.attr1[i].attr))
		if _msg.count2 ~= 0 then
			self.endAttr[i]:setString(string.format("%s+%d",_G.Lang.type_name[_msg.attr2[i].type],_msg.attr2[i].attr))
		else
			self.endAttr[i]:setString("")	
		end
	end
end

function AdvancedLayer.bagGoodsUpdate(self)
	local material_id = _G.Cfg.equip_make[self.goods_id].make1.goods_list[1][1]
	local material_count = _G.Cfg.equip_make[self.goods_id].make1.goods_list[1][2]
	if self.goodsCount~=nil and material_count~=nil then
		local goodNums = _G.GBagProxy:getGoodsCountById(material_id)

		local text = string.format( "%d/%d", goodNums,material_count)
		self.goodsCount : setString( text )

		if goodNums<material_count then
			self.goodsCount : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
			self.notgoods = true
		else
			self.goodsCount : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
			self.notgoods = false
		end
	end
end

return AdvancedLayer