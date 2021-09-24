local ChangeLayer   = classGc(view,function ( self,_curUid )
	self.m_winSize     = cc.Director : getInstance() : getVisibleSize()
	self.m_curRoleUid  = _curUid
end)

local viewSize = cc.size(360,360)
local FONTSIZE = 20 

function ChangeLayer.create(self,_idx)
	self.artifactId=_idx
    self              : __init()
	self.m_rootLayer  = cc.Node : create()
	self              : __initParment()
	self  			  : __initView()
	self 			  : __updateGoods()

    return self.m_rootLayer
end

function ChangeLayer.updataIndex(self,_idx,_true)
    self : __updateGoods()
    self.artifactId=_idx
end

function ChangeLayer.__init(self)
    self : register()
end

function ChangeLayer.register(self)
    self.pMediator = require("mod.artifact.ChangeMediator")(self)
end
function ChangeLayer.unregister(self)
    self.pMediator : destroy()
    self.pMediator = nil 
end

function ChangeLayer.__initParment(self)
    self.m_myProperty=_G.GPropertyProxy:getOneByUid(0,_G.Const.CONST_PLAYER)

    if self.m_myProperty==nil then return end

    -- self.m_myPartner=self.m_myProperty:getWarPartner()
    -- print("EquipLayer.__initParmen===>",self.m_myPartner)
    -- if self.m_myPartner~=nil then
    --     self.m_partnerIdx=self.m_myPartner:getPartner_idx()
    --     self.m_partnerId=self.m_myPartner:getPartnerId() or 0
    --     -- if self.m_curRoleUid~=0 then
    --     --     self.m_curRoleUid=self.m_partnerIdx
    --     -- end
    --     print("有出战的伙伴  idx=",self.m_partnerIdx)
    -- end
end

function ChangeLayer.__initView( self )
	print("..............创建洗练面板..............")
	local titleLab=_G.Util:createLabel("洗练属性",FONTSIZE+4)
	titleLab:setPosition(30,165)
	self.m_rootLayer:addChild(titleLab)

	-- self.goodsName   = _G.Util : createLabel("",FONTSIZE)
	-- self.goodsName   : setPosition(cc.p(30,260))
	-- self.m_rootLayer   : addChild(self.goodsName)

	local lineSpr1 = ccui.Scale9Sprite : createWithSpriteFrameName("general_double_line.png")
	local lineSize = lineSpr1:getContentSize()
	lineSpr1 : setPreferredSize(cc.size(viewSize.width-2,lineSize.height))
	lineSpr1 : setPosition(30,-60)
	self.m_rootLayer : addChild(lineSpr1)

	local tips       = _G.Util : createLabel("消耗洗练石:",FONTSIZE)
	-- tips             : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LBLUE))
	tips             : setPosition(cc.p(-10,-95))
	self.m_rootLayer : addChild(tips)
	self.tips        = tips

	local tipsData   = _G.Util : createLabel("0/0",FONTSIZE)
	-- tipsData         : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LBLUE))
	tipsData         : setAnchorPoint(cc.p(0,0.5))
	tipsData         : setPosition(cc.p(50,-95))
	self.m_rootLayer   : addChild(tipsData)
	self.tipsData    = tipsData

	self.my_attr = {}
	self.add_attr= {}

	for i=1,4 do
		self.my_attr[i] = _G.Util : createLabel("",FONTSIZE)
		self.my_attr[i] : setAnchorPoint(cc.p(0,0.5)) 
		self.my_attr[i] : setPosition(cc.p(-90,110-(i-1)*45))
		self.m_rootLayer : addChild(self.my_attr[i])

		self.add_attr[i] = _G.Util : createLabel("",FONTSIZE)
		self.add_attr[i] : setAnchorPoint(cc.p(0,0.5)) 
		self.add_attr[i] : setPosition(cc.p(110,110-(i-1)*45))
		self.add_attr[i] : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_SPRINGGREEN))
		self.m_rootLayer : addChild(self.add_attr[i])
	end

	local function addEvent( send,eventType )
		if eventType == ccui.TouchEventType.ended then
			local msg = REQ_MAGIC_EQUIP_WASH_SAVE()
	        msg       : setArgs(0,self.artifactId)
	        _G.Network: send(msg)
		end
		return false
	end 

	self.m_button  = gc.CButton:create()
	self.m_button  : addTouchEventListener(addEvent)
	self.m_button  : loadTextures("general_btn_gold.png")
	self.m_button  : setTitleText("确 定")
	self.m_button  : setTitleFontSize(FONTSIZE+2)
	self.m_button  : setTitleFontName(_G.FontName.Heiti)
	--self.m_button  : enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
	self.m_button  : setPosition(cc.p(-30,-150))
	self.m_button  : setButtonScale(0.85)
	self.m_rootLayer : addChild(self.m_button)

	local function updateAttrEvent( send,eventType )
		if eventType == ccui.TouchEventType.ended then
			local goodNums = _G.GBagProxy:getGoodsCountById(58000)
			if goodNums >=1 then
				_G.Util:playAudioEffect("ui_equip_change")
			end
			
			local msg = REQ_MAGIC_EQUIP_WASH()
	        msg       : setArgs(self.m_curRoleUid,self.node.type_sub)
	        _G.Network: send(msg)
		end
		return false
	end 

	self.m_button1 = gc.CButton:create()
	self.m_button1 : addTouchEventListener(updateAttrEvent)
	self.m_button1 : loadTextures("general_btn_lv.png")
	self.m_button1 : setTitleText("洗 练")
	self.m_button1 : setTitleFontSize(FONTSIZE+2)
	self.m_button1 : setTitleFontName(_G.FontName.Heiti)
	self.m_button1 : setPosition(cc.p(90,-150))
	self.m_button1 : setButtonScale(0.85)
	self.m_rootLayer : addChild(self.m_button1)	
end

function ChangeLayer.__updateGoods( self )
	local mainplay = self.m_myProperty
    print("EquipLayer.updateEquip------>")

    if mainplay==nil then return end
    local m_equipList  = mainplay:getArtifactEquipList()  --装备数据
    local newEquipList = {}
    --table.sort( m_equipList, function ( a,b ) return a.index<b.index end )

    local flag = false
    for k,v in pairs(m_equipList) do
    	print(k,v.index)
    	newEquipList[v.index] = v
    	if v.index == self.artifactId then
    		flag = true
    	end
    end
    self : __clearMsg()

    if flag then
        local id    = newEquipList[self.artifactId].goods_id
        local index = newEquipList[self.artifactId].index
        local node  = _G.Cfg.goods[id]

        if node == nil then return end

        self.m_button1 : setDefault()
	    self.m_button1 : setEnabled(true)

        -- self.goodsName : setString(node.name.."+"..newEquipList[self.artifactId].strengthen)
        -- self.goodsName : setColor(_G.ColorUtil:getRGB(node.name_color))

        local goodNums = _G.GBagProxy:getGoodsCountById(58000)
    	-- self.tips     : setVisible(true)
    	-- self.tipsData : setVisible(true)
    	self.tipsData : setString(string.format("%d/1",goodNums))

    	if goodNums == 0 then
    		self.tipsData : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
    	else
    		self.tipsData : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
    	end
        
        self.node = node

        local msg = REQ_MAGIC_EQUIP_WASH_REQUEST()
        msg       : setArgs(0,self.artifactId)
        _G.Network: send(msg)
    end    
end

function ChangeLayer.__clearMsg( self )
	-- self.goodsName : setString("") 
	self.m_button1 : setGray()
	self.m_button1 : setEnabled(false)
	-- self.tipsData  : setVisible(false)
	-- self.tips      : setVisible(false)
	for i=1,4 do
		self.my_attr[i] : setString("")
		self.add_attr[i] : setString("")
		self.add_attr[i] : setVisible(false)
	end
end

-- function ChangeLayer.updateView( self,_curUid )
-- 	self.m_curRoleUid = _curUid
-- 	self : __clearMsg()
-- end

function ChangeLayer.updateMsg( self,_msg )
	table.sort( _msg.attr1, function ( a,b ) return a.type < b.type end )
	table.sort( _msg.attr2, function ( a,b ) return a.type < b.type end )
	print("<<<<<<<<<<",_msg.count1,_msg.count2,">>>>>>>>>>")
	for i=1,4 do
		self.my_attr[i] : setString(string.format("%s+%d (最大%d)",_G.Lang.type_name[_msg.attr1[i].type],_msg.attr1[i].attr,_msg.attr1[i].max))

		if _msg.count2 > 0 then
			if _msg.attr2[i].attr >=0 then
				self.add_attr[i] : setString(string.format("+%d",_msg.attr2[i].attr))
				self.add_attr[i] : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
			else
				self.add_attr[i] : setString(string.format("%d",_msg.attr2[i].attr))
				self.add_attr[i] : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
			end
			self.add_attr[i] : setVisible(true)
		end
		
	end
end

function ChangeLayer.updatePower( self )
	self : __updateGoods()
end

return ChangeLayer