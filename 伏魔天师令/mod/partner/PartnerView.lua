local PartnerView = classGc(view,function( self, _type )
	self.MyType   = _type
	self.m_winSize= cc.Director:getInstance():getWinSize()
	self.partnerid=1
	self.partnerData={}
	self.openData={}
	self.isTrue=false
	self.m_spineResArray={}
	self.m_selectTag=_type or 1
end)

local TAGBTN_ATTR   = 1
local TAGBTN_EVOLVE = 2
local ATTR_TAG  = 111
local JIHUO_TAG = 112
local UPLV_TAG  = 113
local ALLADD_TAG= 114
local LOOK_TAG  = 115
local UPJIE_TAG = 116
local ATTR_INDEX={"hp","strong_att","strong_def","defend_down","hit","dod","crit","crit_res"}

local rightSize=cc.size(686,470)

local FONTSIZE = 20
local partnerList = _G.Cfg.partner_init
local SYSID_ARRAY=
{
	[TAGBTN_ATTR]=_G.Const.CONST_FUNC_OPEN_PARTNER_ATTRIBUTE,
	[TAGBTN_EVOLVE]=_G.Const.CONST_FUNC_OPEN_PARTNER_ADVANCED,
}

function PartnerView.create( self )
	self.m_PartnerView  = require("mod.general.TabUpView")()
	self.m_rootLayer = self.m_PartnerView:create("守 护")
	-- self.m_upRightSpr = self.m_PartnerView:getUpRightSpr()
	local secondSize = self.m_PartnerView  : getSecondSize()
	self.m_PartnerView  : setSecondSize(cc.size(secondSize.width,secondSize.height-8))

	local tempScene=cc.Scene:create()
  	tempScene:addChild(self.m_rootLayer)

  	self:regMediator()
	self:_initView()

	return tempScene
end

function PartnerView._initView( self )
	local function closeFun()
		self:closeWindow()
	end

	local function tabBtnCallBack(tag)
		print("PartnerView._initView tabBtnCallBack>>>>> tag="..tag)
		local sysId=SYSID_ARRAY[tag]
		if _G.GOpenProxy:showSysNoOpenTips(sysId) then return false end
		self:selectContainerByTag(tag)

		-- if tag == TAGBTN_ATTR then
		-- 	self.m_attrLayer:showData()
		-- elseif self.m_selectTag == TAGBTN_EVOLVE then
		-- 	self.m_evolLayer:changeParnter(self.m_selected:getTag())
		-- end

		return true
	end
	self.m_PartnerView:addCloseFun(closeFun)
	self.m_PartnerView:addTabFun(tabBtnCallBack)

	self.m_PartnerView:addTabButton("灵 妖",TAGBTN_ATTR)
	self.m_PartnerView:addTabButton("进 阶",TAGBTN_EVOLVE)
	local signArray=_G.GOpenProxy:getSysSignArray()
	if signArray[_G.Const.CONST_FUNC_OPEN_PARTNER_ATTRIBUTE] then
		self.m_PartnerView:addSignSprite(TAGBTN_ATTR,_G.Const.CONST_FUNC_OPEN_PARTNER_ATTRIBUTE)
	end
	if signArray[_G.Const.CONST_FUNC_OPEN_PARTNER_ADVANCED] then
		self.m_PartnerView:addSignSprite(TAGBTN_EVOLVE,_G.Const.CONST_FUNC_OPEN_PARTNER_ADVANCED)
	end
	self.m_PartnerView:selectTagByTag(TAGBTN_ATTR)

	self.m_mainContainer = cc.Node:create()
	self.m_mainContainer : setPosition(cc.p(self.m_winSize.width/2,self.m_winSize.height/2))
	self.m_rootLayer:addChild(self.m_mainContainer)

	local leftSize=cc.size( 140, 470 )
	local Spr_LefView = ccui.Scale9Sprite : createWithSpriteFrameName( "general_login_dawaikuan.png" )
  	Spr_LefView : setContentSize( leftSize )
  	Spr_LefView : setPosition( -343 , -51 )
   	self.m_mainContainer	: addChild( Spr_LefView)
   	self.Spr_LefView=Spr_LefView

	local Spr_RigView = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double.png" )
  	Spr_RigView : setContentSize(rightSize)
  	Spr_RigView : setPosition( 75 , -51 )
   	self.m_mainContainer	: addChild( Spr_RigView)

   	self.powpos=cc.p(-80,-80)
   	self:AttrFryNode(self.m_mainContainer)
   	self:selectContainerByTag(TAGBTN_ATTR)

   	local msg  = REQ_LINGYAO_REQUEST( )
   	msg        : setArgs(1)
	_G.Network : send( msg )

	local guideId=_G.GGuideManager:getCurGuideId()
	if guideId==_G.Const.CONST_NEW_GUIDE_SYS_PARTNER_LEVEL
		or guideId==_G.Const.CONST_NEW_GUIDE_SYS_PARTNER_LEVEL2 then
		self.m_guide_tag=TAGBTN_ATTR
		local closeBtn=self.m_PartnerView:getCloseBtn()
		_G.GGuideManager:initGuideView(self.m_rootLayer)
		_G.GGuideManager:registGuideData(1,self.Btn_Peiyang)
		_G.GGuideManager:registGuideData(2,closeBtn)
		_G.GGuideManager:runNextStep()

		-- if guideId==_G.Const.CONST_NEW_GUIDE_SYS_PARTNER_UP then
		-- 	_G.Util:playAudioEffect("sys_partner")
		-- end

		local command=CGuideNoticHide()
      	controller:sendCommand(command)
	end
end

function PartnerView.updateData(self,_count,_data)
	print("updateData--->>",_count)
	self:LeftDataView()
	if _count<=0 then
		self.partnerData=self.leftData 
		self : createScrollView()
		self : selectUpdate(1)
		return 
	end
	local function sortfunction(v1,v2)
		if v1.id > v2.id then
			return false
		end
	end
	table.sort( _data, sortfunction )
	
	local num=1
	self.partnerNum={}
	for k,v in pairs(_data) do
		print("_data===>>>",k,v.id)
		self.partnerData[num]=partnerList[v.id]
		self.openData[num]=v
		self.partnerNum[v.id]=num
		num=num+1
	end	
	
	local YesOrNo=true
	for i=1,self.count do
		YesOrNo=true
		for j=1,_count do
			-- print("num======>>>",num,partnerList[self.partnerData[j].id].panduan~=i)
			if partnerList[self.partnerData[j].id].panduan==i then
				YesOrNo=false
				break
			end
		end
		if YesOrNo then
			self.partnerData[num]=self.leftData[i]
			num=num+1
		end
	end

	self : createScrollView()
	self : selectUpdate(1)
	self : createSpine(self.partnerid)
	self : updateEvolve(1)
	if self.MyType~=nil then 
		print( "选择了第", self.MyType, "个界面" )
		self:selectContainerByTag(self.MyType)
		self.m_PartnerView:selectTagByTag(self.MyType)
	end
end

function PartnerView.updatePointData(self,_count,_data)
	for k,v in pairs(self.RedHaveSpr) do
		print("v:removeFromParent(true)",k,v)
		self.RedHaveSpr[k]:removeFromParent(true)
		self.RedHaveSpr[k]=nil
	end
	if _count<=0 then return end

	for k,v in pairs(_data) do
		print("updatePointData----->>",k,v.id)
		if self.partnerNum[v.id]~=nil then
			local num=self.partnerNum[v.id]
			print("self.partnerNum[v.id]",num)
			self.RedHaveSpr[num] = cc.Sprite:createWithSpriteFrameName("general_redpoint.png")
		    self.RedHaveSpr[num] : setPosition(100,90)
		    self.RedHaveSpr[num] : setVisible(false)
		    self.Btn_partner[num] : addChild(self.RedHaveSpr[num])
		    if self.isTrue==true then
		    	self.RedHaveSpr[num] : setVisible(true)
		    end
		end
	end
end

function PartnerView.updateOneData(self,_data) 
	if self.Music==true then
		_G.Util:playAudioEffect("ui_goldbody")
		self.Music=false
	end
	if self.YaoLing==true then
		_G.Util:playAudioEffect("ui_inventory_items")
		self.YaoLing=false
	end
	for k,v in pairs(partnerList) do
		if k==_data.id then
			print("self.partnerData-->>11",self.partnerid,v.id,v.panduan)
			local Num=self.partnerid
			if self.partnerNum[v.id]~=nil and self.partnerNum[v.id]~=self.partnerid then
				Num=self.partnerNum[v.id]
			end
			self.openData[Num]=_data
			self.partnerData[Num]=partnerList[v.id]
			self.Btn_partner[Num]:setDefault()
	    	self.headIconSpr[Num]:setDefault()
	    	self.frombgSpr[Num]:setDefault()
	    	self.lvbgSpr[Num]:setDefault()
	    	self.openLabelSpr[Num]:setVisible(false)
	    	self.leavelLab[Num]:setString(_data.lv)
	    	self.partnerNameLab[Num]:setString(partnerList[v.id].name)
		end
	end
	self.nowlv=_data.lv
	self : selectUpdate(self.partnerid)
	self : updateEvolve(self.partnerid)
end

function PartnerView.updateProxyData(self) 
	self : updateEvolve(self.partnerid)
end

function PartnerView.LeftDataView(self)
   	self.count = 1

   	self.leftData={}
   	for k,v in pairs(partnerList) do
		if self.count<v.panduan then
			self.count=v.panduan
		end
   	end

   	
   	for i=1,self.count do
   		local oldid=999999
   		for k,v in pairs(partnerList) do
   			if i==v.panduan then
   				if v.id<oldid then
   					oldid=v.id
   					self.leftData[i]=v
   				end
   			end
   		end
   	end
end

function PartnerView.createScrollView(self)
	if self.ScrollView~=nil then
		self.ScrollView:removeFromParent(true)
		self.ScrollView=nil
	end
	local leftSize=cc.size( 140, 470 )
	print("LeftDataView==>>",self.count)
   	local ScrollHeigh 	= (leftSize.height-6)/4
  	local viewSize 		= cc.size( 140, leftSize.height-6 )
   	local containerSize = cc.size( 140, self.count*ScrollHeigh)
  	self.ScrollView  	= cc.ScrollView : create()
  	self.ScrollView  : setDirection(ccui.ScrollViewDir.vertical)
  	self.ScrollView  : setViewSize(viewSize)
  	self.ScrollView  : setContentSize(containerSize)
  	self.ScrollView  : setContentOffset( cc.p(0, viewSize.height-containerSize.height))
  	self.ScrollView  : setPosition( 0, 2 )
  	self.ScrollView  : setTouchEnabled(true)
  	self.ScrollView  : setDelegate()
  	self.Spr_LefView : addChild( self.ScrollView)

  	local barView=require("mod.general.ScrollBar")(self.ScrollView)
  	barView:setPosOff(cc.p(-7,0))

  	local function ButtonCallBack(  obj, eventType )
  		if eventType == ccui.TouchEventType.ended then
	  		local tag 		= obj : getTag()
	  		local Position  = obj : getWorldPosition()
	  		print( "y = ", Position.y )
	      	if Position.y > 500 or Position.y < 58 or self.currentTypeId == tag or self.partnerid==tag then 
	         	return 
	      	end
	      	if self.openData[tag]==nil and self.isTrue then
	      		local command=CErrorBoxCommand("该灵妖未解锁")
            	_G.controller:sendCommand(command)
            	return
            end
            self.partnerid=tag
	  		self : touchEventCallBack( obj )
	  		self : selectUpdate(tag)
	  		self : updateEvolve(tag)
	  		self : createTwoSpine(tag)
	  	end
  	end

  	self.RedHaveSpr   = {}
  	self.Btn_partner  = {}
  	self.headIconSpr  = {}
  	self.openLabelSpr = {}
  	self.frombgSpr 	  = {}
  	self.lvbgSpr 	  = {}
  	self.leavelLab	  = {}
  	self.partnerNameLab={}
  	for i=1,self.count do
	    local partnerRes = "partner_head.png"
	    self.Btn_partner[i] = gc.CButton:create(partnerRes)
	    -- self.Btn_partner[i] : loadTextures( partnerRes, partnerRes, partnerRes, ccui.TextureResType.plistType)
	    self.Btn_partner[i] : setPosition( 70, self.count*ScrollHeigh-ScrollHeigh*(i-1)-ScrollHeigh/2 ) --121*length-105*i-55-18*x
	    self.Btn_partner[i] : addTouchEventListener(ButtonCallBack)
	    self.Btn_partner[i] : setTag(i)
	    -- self.Btn_partner[i] : setGray()
	    self.Btn_partner[i] : setSwallowTouches(false)
	    self.ScrollView:addChild(self.Btn_partner[i])

	    local namecolor=self.partnerData[i].name_colour
	    print("self.partnerData[i].head_icon",self.partnerData[i].head_icon)
	    local szHead=string.format("h%d.png",self.partnerData[i].head_icon)
      	self.headIconSpr[i] = gc.GraySprite:createWithSpriteFrameName(szHead)
	    -- self.headIconSpr[i] : setColor(_G.ColorUtil:getRGB(namecolor))
	    self.headIconSpr[i] : setPosition(71,59)
	    self.Btn_partner[i] : addChild(self.headIconSpr[i],-1)
	    -- self.headIconSpr[i] : setGray()

	    local fromimg=string.format("partner_frombg%d.png",self.partnerData[i].country)
	    self.frombgSpr[i] = gc.GraySprite:createWithSpriteFrameName(fromimg)
	    -- self.frombgSpr[i] : setGray()
	    self.frombgSpr[i] : setPosition(45,90)
	    self.Btn_partner[i] : addChild(self.frombgSpr[i])

	    self.lvbgSpr[i] = gc.GraySprite:createWithSpriteFrameName("partner_lvbg.png")
	    -- self.lvbgSpr[i] : setGray()
	    self.lvbgSpr[i] : setPosition(110,60)
	    self.Btn_partner[i] : addChild(self.lvbgSpr[i])

	    self.leavelLab[i] = _G.Util : createLabel(1,FONTSIZE)
	    self.leavelLab[i] : setPosition( 15, 15 )
	    -- self.leavelLab[i] : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
	    self.lvbgSpr[i] : addChild(self.leavelLab[i])

	    self.partnerNameLab[i] = _G.Util : createLabel(self.partnerData[i].name,FONTSIZE)
	    self.partnerNameLab[i]  : setPosition( 65, 15 )
	    self.partnerNameLab[i]  : setColor(_G.ColorUtil:getRGB(namecolor))
	    self.Btn_partner[i] : addChild(self.partnerNameLab[i])

	    local count = _G.GBagProxy:getGoodsCountById(self.partnerData[i].goods_list[1][1])
	    local Num = self.partnerData[i].goods_list[1][2]
	    local LabImg = "partner_noopen.png"
	    if count>=Num then
	        LabImg = "partner_open.png"
	    end

	    self.openLabelSpr[i] = cc.Sprite:createWithSpriteFrameName(LabImg)
	    -- self.openLabelSpr[i] : setAnchorPoint( 0.5, 0 )
	    self.openLabelSpr[i] : setPosition(72,55)
	    self.Btn_partner[i]  : addChild(self.openLabelSpr[i])
	    if self.openData[i]~=nil then
	    	-- self.Btn_partner[i]:setDefault()
	    	-- self.headIconSpr[i]:setDefault()
	    	-- self.frombgSpr[i]:setDefault()
	    	-- self.lvbgSpr[i]:setDefault()
	    	self.openLabelSpr[i]:setVisible(false)
	    	self.leavelLab[i]:setString(self.openData[i].lv)
	    end
  	end
  	self:touchEventCallBack(self.Btn_partner[1])
end

function PartnerView.touchEventCallBack(self,_btn)
	if self.selectSpr~=nil then
		self.selectSpr:removeFromParent(true)
		self.selectSpr=nil
	end

	local btnSize=_btn:getContentSize()
	self.selectSpr=cc.Sprite:createWithSpriteFrameName("partner_select.png")
	self.selectSpr:setPosition(btnSize.width/2,btnSize.height/2)
	_btn:addChild(self.selectSpr,-1)

	self:createSpine(self.partnerid)
end

function PartnerView.selectUpdate(self,_tag)
	local fromimg=string.format("partner_frombg%d.png",self.partnerData[_tag].country)
	self.fromSpr:setSpriteFrame(fromimg)

	self.nameLabel:setString(self.partnerData[_tag].name)

	local attrdata=self.partnerData[_tag].attr
	local updata=self.partnerData[_tag].up
	for i=1,8 do
		self.attrNumLab[i]:setString(string.format("%d(%d)",attrdata[ATTR_INDEX[i]],updata[ATTR_INDEX[i]]))
	end

	self:updateXiaoHao()
	self.Btn_Peiyang : setTitleText( "解  锁" )
	self.Btn_Peiyang : setTag( JIHUO_TAG )	
	local powerful=0
	if self.openData[_tag]~=nil then
		self.nowlv=self.openData[_tag].lv
		powerful=self.openData[_tag].powerful or 0
		self.Btn_Peiyang : setTitleText( "升  级" )
		self.Btn_Peiyang : setTag( UPLV_TAG )
		self:UpdateRenown(self.nowlv or 1)
		local attrdata = self.openData[_tag].attr_msg
		local attr_lab = {attrdata.hp,attrdata.att,attrdata.def,attrdata.wreck,attrdata.hit,attrdata.dod,attrdata.crit,attrdata.crit_res}
		for i=1,8 do
			self.attrNumLab[i]:setString(string.format("%d(%d)",attr_lab[i],updata[ATTR_INDEX[i]]))
		end
	end

	if updata[ATTR_INDEX[1]]==0 then
		self.Btn_Peiyang:setVisible(false)
		self.xiaohaoLab:setVisible(false)
		self.NumberLab:setVisible(false)
		self.MaxLab:setVisible(true)
	else
		self.Btn_Peiyang:setVisible(true)
		self.xiaohaoLab:setVisible(true)
		self.NumberLab:setVisible(true)
		self.MaxLab:setVisible(false)
	end

	self:createPowerNum(powerful)
	self:createSkill(_tag)
end

function PartnerView.createAttrView(self)
	if self.attrNode~=nil then return end
	self.attrNode=cc.Node:create()
	self.m_mainContainer:addChild(self.attrNode)

	local logoSpr=cc.Sprite:createWithSpriteFrameName("general_titlebg.png")
	logoSpr:setPosition(-80,145)
	self.attrNode:addChild(logoSpr)

	self.nameLabel = _G.Util : createLabel("",FONTSIZE)
	self.nameLabel : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
    self.nameLabel : setPosition(-80,141)
    self.attrNode : addChild(self.nameLabel)

    self.fightSpr = cc.Sprite : createWithSpriteFrameName( "main_fighting.png" )
   	-- spr : setAnchorPoint( 0, 0.5 )
   	self.fightSpr : setPosition( -80 , 97 )
   	self.attrNode : addChild( self.fightSpr ) 

    self.fromSpr  = cc.Sprite:createWithSpriteFrameName("partner_frombg1.png")
    -- self.fromSpr  : setScale(1.2)
    self.fromSpr  : setPosition(-205,80)
    self.attrNode : addChild(self.fromSpr)

   	local sprbg2 = cc.Sprite : createWithSpriteFrameName( "general_rolebg2.png" )
   	sprbg2 : setPosition( -80 , -60)
   	self.attrNode : addChild( sprbg2 ) 

  	self.skillBtn={}
  	
  	local doubleSize=cc.size(300,458)
	local doubleSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_double2.png")
	doubleSpr:setPreferredSize(doubleSize)
	doubleSpr:setPosition(262,-52)
	self.attrNode:addChild(doubleSpr)

	local titleLab=_G.Util : createLabel("属性(成长)",FONTSIZE)
	titleLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
	titleLab:setPosition(80,doubleSize.height-40)
	doubleSpr:addChild(titleLab)

	local function ButtonCallBack( obj, eventType )
		if eventType == ccui.TouchEventType.ended then
			local btnTag=obj:getTag()
			if btnTag==ATTR_TAG then
				print("创建总属性加成界面")
				local msg = REQ_LINGYAO_ATTR_ALL( )
				_G.Network : send( msg )
			elseif btnTag==JIHUO_TAG then
				print("发送激活协议")
				local goodsid = self.partnerData[self.partnerid].goods_list[1][1]
				local count   = self.partnerData[self.partnerid].goods_list[1][2]
				local goodNum = _G.GBagProxy:getGoodsCountById(goodsid)
				if goodNum<count then
					self:SuiCopyView()
				else
					local msg  = REQ_LINGYAO_JIHUO( )
					msg        : setArgs(self.partnerData[self.partnerid].id,2)
					_G.Network : send( msg )
				end
			else
				print("发送升级协议")
				self.Music=true
				self.YaoLing=false
				local msg  = REQ_LINGYAO_UPGRADE( )
				msg        : setArgs(self.partnerData[self.partnerid].id)
				_G.Network : send( msg )
			end
		end
	end 

	local titleBtn  = gc.CButton : create()
   	titleBtn  : loadTextures( "partner_attrbtn.png")
	titleBtn  : setPosition( doubleSize.width-90, doubleSize.height-40 )
	titleBtn  : setTag( ATTR_TAG )
	titleBtn  : addTouchEventListener( ButtonCallBack )
	doubleSpr   : addChild( titleBtn )

	local btnSize=titleBtn:getContentSize()
	local titleLab=_G.Util : createLabel("总属性加成",FONTSIZE)
	titleLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
	titleLab:setPosition(btnSize.width/2,btnSize.height/2)
	titleBtn:addChild(titleLab)

	self.Btn_Peiyang = gc.CButton : create()
	self.Btn_Peiyang : loadTextures( "general_btn_gold.png")
	self.Btn_Peiyang : setTitleText( "解  锁" )
	self.Btn_Peiyang : setTag( JIHUO_TAG )	
	self.Btn_Peiyang : setTitleFontName( _G.FontName.Heiti )
	self.Btn_Peiyang : setTitleFontSize( FONTSIZE + 4 )
	self.Btn_Peiyang : setPosition( doubleSize.width/2, 65 )
	self.Btn_Peiyang : addTouchEventListener( ButtonCallBack )
	doubleSpr : addChild( self.Btn_Peiyang )

	self.MaxLab=_G.Util : createLabel("已达到最高等级",FONTSIZE)
	self.MaxLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
	self.MaxLab:setPosition(doubleSize.width/2,50)
	self.MaxLab:setVisible(false)
	doubleSpr:addChild(self.MaxLab)

	self.xiaohaoLab=_G.Util : createLabel("",FONTSIZE)
	self.xiaohaoLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
	self.xiaohaoLab:setPosition(doubleSize.width/2+30,25)
	self.xiaohaoLab:setAnchorPoint(cc.p(1,0.5))
	doubleSpr:addChild(self.xiaohaoLab)

	self.NumberLab=_G.Util : createLabel("0/0",FONTSIZE)
	self.NumberLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
	self.NumberLab:setPosition(doubleSize.width/2+35,25)
	self.NumberLab:setAnchorPoint(cc.p(0,0.5))
	doubleSpr:addChild(self.NumberLab)

	local Name_spr = { "general_hp.png", "general_att.png", "general_wreck.png", "general_def.png", 
   					   "general_hit.png", "general_dodge.png", "general_crit.png","general_crit_res.png" }
   	local Text_lab = { "气血:", "攻击:", "破甲:", "防御:", "命中:", "闪避:", "暴击:", "抗暴:"}
   	self.attrNumLab= {}
	for i=1,8 do
		local attrSpr=cc.Sprite:createWithSpriteFrameName(Name_spr[i])
		attrSpr:setPosition(50,doubleSize.height-45-i*37)
		doubleSpr:addChild(attrSpr)

		local attrnameLab=_G.Util : createLabel(Text_lab[i],FONTSIZE)
		attrnameLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
		attrnameLab:setPosition(95,doubleSize.height-45-i*37)
		doubleSpr:addChild(attrnameLab)

		self.attrNumLab[i]=_G.Util : createLabel("",FONTSIZE)
		self.attrNumLab[i]:setAnchorPoint(cc.p(0,0.5))
		self.attrNumLab[i]:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
		self.attrNumLab[i]:setPosition(85+attrnameLab:getContentSize().width,doubleSize.height-45-i*37)
		doubleSpr:addChild(self.attrNumLab[i])
	end
end

function PartnerView.SuiCopyView( self )
	if self.GoCopyLayer~=nil then return end
	local copySize=cc.size(380,411)
	local function onTouchBegan(touch,event) 
        print("ExplainView remove tips")
        local location=touch:getLocation()
        local bgRect=cc.rect(self.m_winSize.width/2-copySize.width/2,self.m_winSize.height/2-copySize.height/2,
        copySize.width,copySize.height)
        local isInRect=cc.rectContainsPoint(bgRect,location)
        print("location===>",location.x,location.y)
        print("bgRect====>",bgRect.x,bgRect.y,bgRect.width,bgRect.height,isInRect)
        if isInRect then
            return true
        end
        local function nFun()
	        print("delayCallFun-----------------")
	        if self.GoCopyLayer~=nil then
	            self.GoCopyLayer:removeFromParent(true)
	            self.GoCopyLayer=nil
	        end
	    end
	    local delay=cc.DelayTime:create(0.01)
	    local func=cc.CallFunc:create(nFun)
	    self.GoCopyLayer:runAction(cc.Sequence:create(delay,func))
        return true
    end

    local listerner = cc.EventListenerTouchOneByOne:create()
    listerner : registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner : setSwallowTouches(true)

    self.GoCopyLayer = cc.LayerColor:create(cc.c4b(0,0,0,150))
    self.GoCopyLayer : getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.GoCopyLayer)
    cc.Director : getInstance():getRunningScene():addChild(self.GoCopyLayer,1000)

	local goodsData=_G.Cfg.goods[self.partnerData[self.partnerid].goods_list[1][1]].f
	local copyData ={}
	local copyNum=0
	for k,v in pairs(goodsData.wash) do
		copyData[k]=v
		copyNum=copyNum+1
	end
	if copyNum<3 then copyNum=3 end
    local copySpr = ccui.Scale9Sprite:createWithSpriteFrameName("general_tips_dins.png")
    copySpr : setPreferredSize(copySize)
    copySpr : setPosition(self.m_winSize.width/2,self.m_winSize.height/2)
    self.GoCopyLayer  : addChild(copySpr)

    local di2kuanSpr = ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
    di2kuanSpr : setPreferredSize(cc.size(copySize.width-15,copySize.height-15))
    di2kuanSpr : setPosition(copySize.width/2,copySize.height/2)
    copySpr  : addChild(di2kuanSpr)

    local nowHeadSpr=cc.Sprite:createWithSpriteFrameName("partner_head.png")
    nowHeadSpr:setPosition(80, copySize.height-67)
    nowHeadSpr: setScale(0.9)
    copySpr   : addChild(nowHeadSpr)

    local namecolor = self.partnerData[self.partnerid].name_colour
    local szHead=string.format("h%d.png",self.partnerData[self.partnerid].head_icon)
  	local headIconSpr = gc.GraySprite:createWithSpriteFrameName(szHead)
    -- headIconSpr : setColor(_G.ColorUtil:getRGB(namecolor))
    headIconSpr : setPosition(73,57)
    nowHeadSpr : addChild(headIconSpr,-1)

    local fromimg=string.format("partner_frombg%d.png",self.partnerData[self.partnerid].country)
    local countrySpr = gc.GraySprite:createWithSpriteFrameName(fromimg)
    countrySpr : setPosition(45,90)
    nowHeadSpr : addChild(countrySpr)

    nowlvbgSpr = gc.GraySprite:createWithSpriteFrameName("partner_lvbg.png")
    nowlvbgSpr : setPosition(110,60)
    nowHeadSpr : addChild(nowlvbgSpr)

    local nowlvLab = _G.Util : createLabel(1,FONTSIZE)
    nowlvLab : setPosition( 15, 15 )
    nowlvbgSpr : addChild(nowlvLab)

    local parNameLab = _G.Util : createLabel(self.partnerData[self.partnerid].name,FONTSIZE)
    parNameLab  : setPosition( 65, 15 )
    parNameLab  : setColor(_G.ColorUtil:getRGB(namecolor))
    nowHeadSpr : addChild(parNameLab)

    local goodsid = self.partnerData[self.partnerid].goods_list[1][1]
	local count   = self.partnerData[self.partnerid].goods_list[1][2]
	local goodNum = _G.GBagProxy:getGoodsCountById(goodsid)

    local suipianLab = _G.Util : createLabel(string.format("%s: ",_G.Cfg.goods[goodsid].name), FONTSIZE)
	suipianLab       : setPosition(copySize.width/2-23, copySize.height-55)
	suipianLab 		 : setAnchorPoint(cc.p(0,0.5))
	copySpr        : addChild(suipianLab)

	local suipNumLab = _G.Util : createLabel(string.format("%d/%d",goodNum,count), FONTSIZE)
	suipNumLab       : setPosition(copySize.width/2-23+suipianLab:getContentSize().width, copySize.height-55)
	suipNumLab 		 : setAnchorPoint(cc.p(0,0.5))
	copySpr        : addChild(suipNumLab)
	if goodNum<count then
		suipNumLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
	else
		suipNumLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
	end

    local textLab = _G.Util : createLabel("获取途径: ", FONTSIZE)
	textLab       : setPosition(copySize.width/2+20, copySize.height-93)
	copySpr        : addChild(textLab)

	local goldSpr = ccui.Scale9Sprite:createWithSpriteFrameName("general_gold_floor.png")
	goldSpr:setPreferredSize(cc.size(copySize.width-20,277))
	goldSpr:setPosition(copySize.width/2,copySize.height/2-57)
	copySpr:addChild(goldSpr)
	
   	local OneHeight= (copySize.height-136)/3
  	local viewSize = cc.size( copySize.width-15, copySize.height-136 )
   	local contSize = cc.size( copySize.width-15, copyNum*OneHeight)
  	local suiScroll = cc.ScrollView : create()
  	suiScroll : setDirection(ccui.ScrollViewDir.vertical)
  	suiScroll : setViewSize(viewSize)
  	suiScroll : setContentSize(contSize)
  	suiScroll : setContentOffset( cc.p(0, viewSize.height-contSize.height))
  	suiScroll : setPosition( 8, 10 )
  	suiScroll : setTouchEnabled(true)
  	suiScroll : setDelegate()
  	copySpr : addChild( suiScroll,10)

  	local barView=require("mod.general.ScrollBar")(suiScroll)
  	barView:setPosOff(cc.p(-7,0))

  	local function CopyBtnCallBack( obj, eventType )
		if eventType == ccui.TouchEventType.ended then
			local copytag=obj:getTag()
			print("进入对应副本",copytag)
			local openId=copyData[copytag][2]
			if copyData[copytag][1]==1 then
				print("self.copyOpen[copytag]",self.copyOpen[copytag])
				if self.copyOpen[copytag]==false then
					local command = CErrorBoxCommand("该副本未开启")
   	        		controller : sendCommand( command ) 
   	        		return
				else
					local roleProperty=_G.GPropertyProxy:getMainPlay()
					local copyId  = copyData[copytag][2]
					local chapId  = _G.Cfg.scene_copy[copyId].belong_id
		            roleProperty:setTaskInfo(4,copyId,chapId,0,1)
					_G.GLayerManager:openSubLayer(Cfg.UI_CCopyMapLayer)	
				end		
			else
				_G.GLayerManager:openSubLayer(openId)
				self.isOpen=true
			end
			self:removeFuwenLayer()
			if self.GoCopyLayer~=nil then
	            self.GoCopyLayer:removeFromParent(true)
	            self.GoCopyLayer=nil
	        end
		end
	end 
	self.req_Suicopy={}
	self.copyNumLab={}
	local nnn=0
  	for i=1,copyNum do
  		if copyData[i]==nil then break end
  		local lineSpr = ccui.Scale9Sprite:createWithSpriteFrameName("general_input.png")
		lineSpr:setPreferredSize(cc.size(copySize.width-25,90))
		lineSpr:setPosition(viewSize.width/2,contSize.height-i*OneHeight+OneHeight/2)
		suiScroll:addChild(lineSpr)

  		local partnerRes="main_icon_duplicate_1.png"
	    local copyBtn = gc.CButton:create()
	    -- copyBtn : loadTextures( partnerRes, partnerRes, partnerRes, ccui.TextureResType.plistType)
	    copyBtn : setPosition( 45, contSize.height-i*OneHeight+2+OneHeight/2 ) --121*length-105*i-55-18*x
	    copyBtn : addTouchEventListener(CopyBtnCallBack)
	    copyBtn : setButtonScale(0.8)
	    copyBtn : setTag(i)
	    copyBtn : setSwallowTouches(false)
	    suiScroll : addChild(copyBtn)   
  		
		if copyData[i][1]==1 then
			local copyList=_G.Cfg.scene_copy[copyData[i][2]]
			local c_data=_G.Cfg.copy_chap[1][copyList.belong_id]
			if c_data==nil then
				c_data=_G.Cfg.copy_chap[1][10200]
			end
			print("c_data",c_data)
			local copyZjLab = _G.Util : createLabel(string.format("第%s章  第",_G.Lang.number_Chinese[c_data.paixu]),FONTSIZE)
		    copyZjLab  : setPosition( 95, contSize.height-i*OneHeight+2+OneHeight/2+12 )
		    copyZjLab  : setAnchorPoint(cc.p(0,0.5))
		    suiScroll : addChild(copyZjLab)

		    local LabWidth=95+copyZjLab:getContentSize().width
		    local NumberLab = _G.Util : createLabel(1,FONTSIZE)
		    NumberLab : setPosition( LabWidth, contSize.height-i*OneHeight+2+OneHeight/2+12 )
		    NumberLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
		    NumberLab : setAnchorPoint(cc.p(0,0.5))
		    suiScroll : addChild(NumberLab)
		    for k,v in pairs(c_data.copy_id) do
		    	if copyData[i][2]==v then
		    		NumberLab:setString(k)
		    	end
		    end
		    
		    LabWidth=LabWidth+NumberLab:getContentSize().width
		    local copyZjLab = _G.Util : createLabel("关",FONTSIZE)
		    copyZjLab  : setPosition( LabWidth, contSize.height-i*OneHeight+2+OneHeight/2+12 )
		    copyZjLab  : setAnchorPoint(cc.p(0,0.5))
		    suiScroll : addChild(copyZjLab)

		    local copyNameLab = _G.Util : createLabel(copyList.copy_name,FONTSIZE)
		    copyNameLab : setPosition( 95, contSize.height-i*OneHeight+2+OneHeight/2-12 )
		    -- copyNameLab : setColor(_G.ColorUtil:getRGB(namecolor))
		    copyNameLab  : setAnchorPoint(cc.p(0,0.5))
		    suiScroll : addChild(copyNameLab)

		    nnn=nnn+1
		    self.copyNumLab[nnn] = _G.Util:createLabel("",FONTSIZE)
		    self.copyNumLab[nnn] : setPosition(100+copyNameLab:getContentSize().width,contSize.height-i*OneHeight+2+OneHeight/2-12)
		    self.copyNumLab[nnn] : setAnchorPoint(cc.p(0,0.5))
		    suiScroll : addChild(self.copyNumLab[nnn])
		    self.req_Suicopy[nnn]=copyData[i][2]

		    partnerRes="main_icon_duplicate_1.png"
		else
			local content="配表里面没有该功能Id"
			if _G.Cfg.sys_open_info[copyData[i][2]]~=nil then
				content=_G.Cfg.sys_open_info[copyData[i][2]].lingyao_des
			end
			local copyZjLab = _G.Util : createLabel(content,FONTSIZE)
		    copyZjLab  : setPosition( 95, contSize.height-i*OneHeight+2+OneHeight/2-2 )
		    copyZjLab  : setDimensions(250, 50)
			copyZjLab  : setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
		    copyZjLab  : setAnchorPoint(cc.p(0,0.5))
		    suiScroll : addChild(copyZjLab)
			partnerRes=_G.Cfg.IconResList[copyData[i][2]]
		end
		copyBtn : loadTextures( partnerRes)
  	end

  	print("req===>>>",nnn,self.req_Suicopy[nnn],self.req_Suicopy)
  	local msg  = REQ_LINGYAO_COPY_TIMES( )
	msg        : setArgs(nnn,self.req_Suicopy)
	_G.Network : send( msg )
end


function PartnerView.createEvolveView( self )
	if self.evolveNode~=nil then
		self.evolveNode:removeFromParent(true)
		self.evolveNode=nil
	end

	self.evolveNode=cc.Node:create()
	self.m_mainContainer:addChild(self.evolveNode)

	local logoSpr=cc.Sprite:createWithSpriteFrameName("general_titlebg.png")
	logoSpr:setPosition(70,143)
	self.evolveNode:addChild(logoSpr)

	local txt=""
	if self.openData[self.partnerid]~=nil then
		txt=string.format("%d阶",self.openData[self.partnerid].class)
	end

	self.lvLabel = _G.Util : createLabel(txt,FONTSIZE+4)
	self.lvLabel : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
    self.lvLabel : setPosition(70,140)
    self.evolveNode : addChild(self.lvLabel)

	local sprbg2 = cc.Sprite : createWithSpriteFrameName( "general_rolebg2.png" )
   	sprbg2 : setPosition( 70 , -30)
   	self.evolveNode : addChild( sprbg2 ) 

	local Spr_Exp2  = cc.Sprite : createWithSpriteFrameName( "main_exp_2.png" )
	Spr_Exp2  : setPosition( 70, -180 )
	self.evolveNode : addChild( Spr_Exp2 )

	self.Spr_Exp1  = ccui.LoadingBar:create()
    self.Spr_Exp1  : loadTexture("main_exp.png",ccui.TextureResType.plistType)
	self.Spr_Exp1  : setAnchorPoint( 0, 0 )
	self.Spr_Exp1  : setPosition( 1, 1 )
	Spr_Exp2  	   : addChild( self.Spr_Exp1 )
	self.Spr_Exp1  : setPercent( 0 )  -- 缩放

	self.Lab_Exp  = _G.Util : createLabel( "0/0", FONTSIZE-2 )
	self.Lab_Exp  : setPosition( self.Spr_Exp1 : getContentSize().width/2, 7 )
	-- self.Lab_Exp  : setColor( color1 )
	self.Spr_Exp1 : addChild( self.Lab_Exp ) 

	local function FuwenBtnCallBack( obj, eventType )
		if eventType == ccui.TouchEventType.ended then
			print("创建符文碎片获取界面")
			self:SuiCopyView(10)
		end
	end 
	local expAddBtn=gc.CButton:create("general_btn_add.png")
	expAddBtn:setPosition(250,-177 )
	expAddBtn:addTouchEventListener(FuwenBtnCallBack )
	self.evolveNode:addChild(expAddBtn)

	local expSize=Spr_Exp2:getContentSize()
	local expBtn=ccui.Widget:create()
	expBtn:setPosition(70, -180 )
	expBtn:addTouchEventListener(FuwenBtnCallBack )
	expBtn:setTouchEnabled(true)
	expBtn:setContentSize(cc.size(expSize.width+20,expSize.height+20))
	self.evolveNode:addChild(expBtn)

	local lineSpr = ccui.Scale9Sprite : createWithSpriteFrameName( "general_double_line.png" )
	lineSpr : setPreferredSize(cc.size(rightSize.width-100,2))
	lineSpr : setPosition( 70, -200 )
	self.evolveNode : addChild( lineSpr )

	local function ButtonCallBack( obj, eventType )
		if eventType == ccui.TouchEventType.ended then
			local btnTag=obj:getTag()
			if btnTag==ALLADD_TAG then
				print("一键镶入符文")
				self.Music=false
				self.YaoLing=true
				local msg  = REQ_LINGYAO_EQUIP_ALL( )
				msg        : setArgs(self.partnerData[self.partnerid].id)
				_G.Network : send( msg )
			elseif btnTag==LOOK_TAG then
				print("预览符文进阶")
				if partnerList[self.openData[self.partnerid].id+1]~=nil then
					self:lookFuwenView()
				else
					local command = CErrorBoxCommand("灵妖等阶已满")
   	        		controller : sendCommand( command )
				end
			else
				print("发送进阶协议")
				if partnerList[self.openData[self.partnerid].id+1]~=nil then
					self.YaoLing=false
					self.Music=false
					local msg  = REQ_LINGYAO_SHENGJIE( )
					msg        : setArgs(self.partnerData[self.partnerid].id)
					_G.Network : send( msg )
				else
					local command = CErrorBoxCommand("灵妖等阶已满")
   	        		controller : sendCommand( command )
				end
			end
		end
	end 

	local allAddBtn=gc.CButton:create("general_btn_gold.png")
	allAddBtn : setTitleText( "一键镶入" )
	allAddBtn : setTitleFontName( _G.FontName.Heiti )
	allAddBtn : setTitleFontSize( FONTSIZE + 2 )
	allAddBtn : setPosition( -140, -235 )
	allAddBtn : setTag( ALLADD_TAG )
	allAddBtn : addTouchEventListener( ButtonCallBack )
	self.evolveNode : addChild( allAddBtn )

	local lookBtn=gc.CButton:create("general_btn_gold.png")
	lookBtn : setTitleText( "进阶预览" )
	lookBtn : setTitleFontName( _G.FontName.Heiti )
	lookBtn : setTitleFontSize( FONTSIZE + 2 )
	lookBtn : setPosition( 70, -235 )
	lookBtn : setTag( LOOK_TAG )
	lookBtn : addTouchEventListener( ButtonCallBack )
	self.evolveNode : addChild( lookBtn )

	local upBtn=gc.CButton:create("general_btn_gold.png")
	upBtn : setTitleText( "进  阶" )
	upBtn : setTitleFontName( _G.FontName.Heiti )
	upBtn : setTitleFontSize( FONTSIZE + 2 )
	upBtn : setPosition( 290, -235 )
	upBtn : setTag( UPJIE_TAG )
	upBtn : addTouchEventListener( ButtonCallBack )
	self.evolveNode : addChild( upBtn )
	
	self.pointSpr=cc.Sprite:createWithSpriteFrameName("general_redpoint.png")
	self.pointSpr:setPosition(112,35)
	self.pointSpr:setVisible(false)
	upBtn:addChild(self.pointSpr)

	local tipsLab=_G.Util:createLabel("进阶将消耗所有已镶嵌的符文碎片",FONTSIZE-2)
	tipsLab:setPosition(270, -270)
	self.evolveNode : addChild( tipsLab )

	self : updateEvolve(1)
	self : createTwoSpine(1)
end

function PartnerView.updateEvolve( self, _partnerid)
	if self.evolveNode==nil or self.openData[_partnerid]==nil then return end
	print("self.openData[_partnerid].class",self.openData[_partnerid].class,self.RedHaveSpr[_partnerid])
	self.lvLabel:setString(string.format("%d阶",self.openData[_partnerid].class))

	if self.RedHaveSpr[_partnerid]~=nil then
		print("隐藏红点")
		self.RedHaveSpr[_partnerid]:removeFromParent(true)
		self.RedHaveSpr[_partnerid]=nil
	end
	
	local willId = self.partnerData[_partnerid].id_next
	print("willId==>>",willId)
	local goodsid = self.partnerData[_partnerid].goods_list[1][1]
	local count   = self.partnerData[_partnerid].goods_list[1][2]
	if _G.Cfg.partner_init[willId]~=nil then
		goodsid = _G.Cfg.partner_init[willId].goods_list[1][1]
		count   = _G.Cfg.partner_init[willId].goods_list[1][2]
	end
	local goodNum = _G.GBagProxy:getGoodsCountById(goodsid)
	self.Spr_Exp1:setPercent( goodNum/count*100 )
	self.Lab_Exp:setString(string.format("%d/%d",goodNum,count))
	self:createFuWenView(_partnerid)

	print("self.isAll==>>",self.isAll,goodNum,count)
	if goodNum>=count and self.isAll==true then
		self.pointSpr:setVisible(true)
	else
		self.pointSpr:setVisible(false)
	end
end

function PartnerView.SuccessUpMusic( self )
	_G.Util:playAudioEffect("ui_draw_partner")
end

function PartnerView.createPowerNum( self, _powerNum )
	print( " ---改变战力值--- " )
	if self.tempLab~=nil then
		self.tempLab:removeFromParent(true)
		self.tempLab=nil
	end
	self.tempLab=_G.Util:createBorderLabel(string.format("战力:%d",_powerNum),20,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    self.tempLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
    -- self.tempLab:setAnchorPoint(cc.p(0,0.5))
    self.tempLab:setPosition(100,20)
    self.fightSpr : addChild(self.tempLab,10)
end

function PartnerView.createSpine( self, partnerId )
	print( " ---createSpine--- ",partnerId,self.partnerData[partnerId].id )
	if self.attrNode==nil then return end
	if self.spine~=nil then
		self.spine:removeFromParent(true)
		self.spine=nil
		self.shadow:removeFromParent(true)
		self.shadow=nil
	end

	local scale=0.4
	if self.partnerData[partnerId].showscale~=nil then
		scale=self.partnerData[partnerId].showscale/10000
	end
	local pianyiX=self.partnerData[partnerId].xpy or 0
	local pianyiY=self.partnerData[partnerId].ypy or 0
	local tempSpine,tempName = _G.SpineManager.createPartner(self.partnerData[partnerId].id,scale)
	tempSpine : setPosition(-80+pianyiX,-165+pianyiY)
	tempSpine : setAnimation(0,"idle",true)
  	self.attrNode : addChild(tempSpine,500)

  	self.shadow = cc.Sprite:createWithSpriteFrameName("general_shadow.png")
  	self.shadow : setPosition(-80+pianyiX,-165+pianyiY)
  	self.shadow : setScale(1.5)
  	self.attrNode : addChild(self.shadow,500)

  	self.spine=tempSpine
  	self.m_spineResArray[tempName]=true
end

function PartnerView.createTwoSpine( self, partnerId )
	if self.evolveNode==nil then return end
	print( " ---createTwoSpine--- " )
	if self.spine2~=nil then
		self.spine2:removeFromParent(true)
		self.spine2=nil
		self.evolveshadow:removeFromParent(true)
		self.evolveshadow=nil
	end
	local scale=0.4
	if self.partnerData[partnerId].showscale~=nil then
		scale=self.partnerData[partnerId].showscale/10000
	end
	local pianyiX=self.partnerData[partnerId].xpy or 0
	local pianyiY=self.partnerData[partnerId].ypy or 0
	local tempSpine,tempName = _G.SpineManager.createPartner(self.partnerData[partnerId].id,scale)
	tempSpine : setPosition(70+pianyiX,-140+pianyiY)
	tempSpine : setAnimation(0,"idle",true)
  	self.evolveNode : addChild(tempSpine,1000)

  	self.evolveshadow = cc.Sprite:createWithSpriteFrameName("general_shadow.png")
  	self.evolveshadow : setPosition(70+pianyiX,-140+pianyiY)
  	self.evolveshadow : setScale(1.5)
  	self.evolveNode : addChild(self.evolveshadow,1000)

  	self.spine2=tempSpine
  	self.m_spineResArray[tempName]=true
end

function PartnerView.createFuWenView( self, partnerId )
	print( " ---改变符文--- " )
	if self.fuwenBtn~=nil then
		for k,v in pairs(self.fuwenBtn) do
			v:removeFromParent(true)
			v=nil
		end
	end

	local fuwenData=self.partnerData[partnerId].goods_ids
	local openfuwendata=self.openData[partnerId].fuwendata
	local function FuwenBagBtnCallBack( obj, eventType )
		if eventType == ccui.TouchEventType.ended then
			local fuwenTag=obj:getTag()
			local position=obj:getWorldPosition()
			if openfuwendata[fuwenTag].flag==1 then
				print("创建符文信息界面")
				self:fuwenTips(fuwenTag,position)
			else
				print("创建符文背包界面")
				self:fuwenCopyView(fuwenTag)
			end
		end
	end 
	self.fuwenBtn={}
	self.fuwenSpr={}
	self.fuwenAddSpr={}
	self.isAll=true
	local posX=-140
	local posY=200
	for i=1,6 do
		if i<4==0 then
			posY=posY-100
			posX=-140
		elseif i== 4 then
			posX=285
			posY=100
		else
			posY=posY-100
		end
		self.fuwenBtn[i]=gc.CButton:create("general_tubiaokuan.png")
		self.fuwenBtn[i]:setPosition(posX,posY)
		self.fuwenBtn[i]:setTag(i)
		self.fuwenBtn[i]:addTouchEventListener(FuwenBagBtnCallBack )
		self.evolveNode:addChild(self.fuwenBtn[i])

		print("goodsData",fuwenData[i],_G.Cfg.goods[fuwenData[i]])
		local goodsData=_G.Cfg.goods[fuwenData[i]]
		self.fuwenSpr[i]=_G.ImageAsyncManager:createGoodsSpr(goodsData)
		self.fuwenSpr[i]:setPosition(39,39)
		self.fuwenSpr[i]:setGray()
		self.fuwenBtn[i]:addChild(self.fuwenSpr[i])

		self.fuwenAddSpr[i]=cc.Sprite:createWithSpriteFrameName("general_btn_add.png")
		self.fuwenAddSpr[i]:setPosition(58,20)
		self.fuwenBtn[i]:addChild(self.fuwenAddSpr[i])

		for k,v in pairs(openfuwendata) do
			-- print("xzxczxczxc==>",k,v.goods_id,v.flag)
			if v.goods_id==fuwenData[i] and v.flag==1 then
				self.fuwenSpr[i]:setDefault()
				self.fuwenAddSpr[i]:setVisible(false)
			elseif v.goods_id==fuwenData[i] then
				local GemNum=_G.GBagProxy:getGoodsCountById(fuwenData[i])
				print("GemNum===>>>",GemNum)
				if GemNum>0 then
					local gemSpr=cc.Sprite:createWithSpriteFrameName("general_tip_gem.png")
					gemSpr:setPosition(65,65)
					self.fuwenBtn[i]:addChild(gemSpr)
				end
				self.isAll=false
			end
		end
	end
end

function PartnerView.fuwenTips( self, _tag,_position )
	local fuwenData=self.partnerData[self.partnerid].goods_ids

	_G.TipsUtil:setFuwenData(self.openData[self.partnerid].id)
    local temp=_G.TipsUtil:createById(fuwenData[_tag],_G.Const.CONST_GOODS_SITE_PLAYER,_position,self.openData[self.partnerid].id)
    cc.Director:getInstance():getRunningScene():addChild(temp,1000)


	-- if self.fuwenTipsLayer~=nil then return end
	-- local fuwenData=self.partnerData[self.partnerid].goods_ids
	-- local dinsSize=cc.size(350,260)
	-- local function onTouchBegan(touch,event) 
 --        print("ExplainView remove tips")
 --        local location=touch:getLocation()
 --        local bgRect=cc.rect(self.m_winSize.width/2-dinsSize.width/2,self.m_winSize.height/2-dinsSize.height/2,
 --        dinsSize.width,dinsSize.height)
 --        local isInRect=cc.rectContainsPoint(bgRect,location)
 --        print("location===>",location.x,location.y)
 --        print("bgRect====>",bgRect.x,bgRect.y,bgRect.width,bgRect.height,isInRect)
 --        if isInRect then
 --            return true
 --        end
 --        local function nFun()
	--         print("delayCallFun-----------------")
	--         if self.fuwenTipsLayer~=nil then
	--             self.fuwenTipsLayer:removeFromParent(true)
	--             self.fuwenTipsLayer=nil
	--         end
	--     end
	--     local delay=cc.DelayTime:create(0.01)
	--     local func=cc.CallFunc:create(nFun)
	--     self.fuwenTipsLayer:runAction(cc.Sequence:create(delay,func))
 --        return true
 --    end

 --    local listerner = cc.EventListenerTouchOneByOne:create()
 --    listerner : registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
 --    listerner : setSwallowTouches(true)

 --    self.fuwenTipsLayer = cc.Layer:create()
 --    self.fuwenTipsLayer : getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.fuwenTipsLayer)
 --    cc.Director : getInstance():getRunningScene():addChild(self.fuwenTipsLayer,1000)

 --    local kuangSpr = ccui.Scale9Sprite:createWithSpriteFrameName("general_bagkuang.png")
 --    kuangSpr : setPreferredSize(dinsSize)
 --    kuangSpr : setPosition(self.m_winSize.width/2,self.m_winSize.height/2)
 --    self.fuwenTipsLayer : addChild(kuangSpr)

 --    local bagSpr=cc.Sprite:createWithSpriteFrameName("general_tubiaokuan.png")
 --    bagSpr:setPosition(90,dinsSize.height-60)
 --    kuangSpr:addChild(bagSpr)

 --    local goodsData=_G.Cfg.goods[fuwenData[_tag]]
 --    local skillSpr=_G.ImageAsyncManager:createGoodsSpr(goodsData)
 --    skillSpr:setPosition(39,39)
 --    bagSpr:addChild(skillSpr)

 --    local skillNameLab  = _G.Util : createLabel(goodsData.name, FONTSIZE )
	-- skillNameLab : setAnchorPoint(0,0.5)
	-- skillNameLab : setColor(_G.ColorUtil:getRGB(goodsData.name_color))
	-- skillNameLab : setPosition(145, dinsSize.height-60 )
	-- kuangSpr : addChild( skillNameLab )

	-- local titleSpr = ccui.Scale9Sprite:createWithSpriteFrameName("general_voice_dins.png")
 --    titleSpr : setPreferredSize(cc.size(330,70))
 --    titleSpr : setPosition(dinsSize.width/2,dinsSize.height/2-18)
 --    titleSpr : setScaleY(-1)
 --    kuangSpr : addChild(titleSpr)

 --    local content  = goodsData.base_type
 --    for m,n in pairs(content) do
 --    	print(m,n)
 --    	local textLab1 = _G.Util : createLabel(_G.Lang.type_name[content[m].type]..": ", FONTSIZE)
	-- 	textLab1       : setPosition(50, dinsSize.height/2+25-m*30)
	-- 	textLab1       : setAnchorPoint( cc.p(0.0,0.5) )
	-- 	kuangSpr       : addChild(textLab1)

	-- 	local attrLab1 = _G.Util : createLabel(content[m].v, FONTSIZE)
	-- 	attrLab1       : setPosition(55+textLab1:getContentSize().width, dinsSize.height/2+25-m*30)
	-- 	attrLab1       : setAnchorPoint( cc.p(0.0,0.5) )
	-- 	attrLab1 	   : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_SPRINGGREEN))
	-- 	kuangSpr       : addChild(attrLab1)
 --    end

	-- local function DownBtnCallBack( obj, eventType )
	-- 	if eventType == ccui.TouchEventType.ended then
	-- 		print("saaaaaa=====>>>",self.partnerData[self.partnerid].id,fuwenData[_tag])
	-- 		local msg  = REQ_LINGYAO_EQUIP_OFF( )
	-- 		msg        : setArgs(self.partnerData[self.partnerid].id,fuwenData[_tag])
	-- 		_G.Network : send( msg )
	-- 		if self.fuwenTipsLayer~=nil then
	--             self.fuwenTipsLayer:removeFromParent(true)
	--             self.fuwenTipsLayer=nil
	--         end
	-- 	end
	-- end 

	-- local Btn_Down = gc.CButton : create()
	-- Btn_Down : loadTextures( "general_btn_gold.png")
	-- Btn_Down : setTitleText( "卸  下" )
	-- Btn_Down : setTag( JIHUO_TAG )	
	-- Btn_Down : setTitleFontName( _G.FontName.Heiti )
	-- Btn_Down : setTitleFontSize( FONTSIZE + 4 )
	-- Btn_Down : setPosition( dinsSize.width/2, 40 )
	-- Btn_Down : addTouchEventListener( DownBtnCallBack )
	-- kuangSpr : addChild( Btn_Down )
end

function PartnerView.fuwenCopyView( self, _tag )
	if self.fuwenCopyLayer~=nil then return end
	local fuwenData=self.openData[self.partnerid].fuwendata
	local dinsSize=cc.size(720,355)
	local function onTouchBegan(touch,event) 
        print("ExplainView remove tips")
        local location=touch:getLocation()
        local bgRect=cc.rect(self.m_winSize.width/2-dinsSize.width/2,self.m_winSize.height/2-dinsSize.height/2,
        dinsSize.width,dinsSize.height)
        local isInRect=cc.rectContainsPoint(bgRect,location)
        print("location===>",location.x,location.y)
        print("bgRect====>",bgRect.x,bgRect.y,bgRect.width,bgRect.height,isInRect)
        if isInRect then
            return true
        end
        local function nFun()
	        print("delayCallFun-----------------")
	        if self.fuwenCopyLayer~=nil then
	            self.fuwenCopyLayer:removeFromParent(true)
	            self.fuwenCopyLayer=nil
	        end
	    end
	    local delay=cc.DelayTime:create(0.01)
	    local func=cc.CallFunc:create(nFun)
	    self.fuwenCopyLayer:runAction(cc.Sequence:create(delay,func))
        return true
    end

    local listerner = cc.EventListenerTouchOneByOne:create()
    listerner : registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner : setSwallowTouches(true)

    self.fuwenCopyLayer = cc.LayerColor:create(cc.c4b(0,0,0,150))
    self.fuwenCopyLayer : getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.fuwenCopyLayer)
    cc.Director : getInstance():getRunningScene():addChild(self.fuwenCopyLayer,1000)

    local copyWid=ccui.Widget:create()
    copyWid:setContentSize(dinsSize)
    copyWid:setPosition(self.m_winSize.width/2,self.m_winSize.height/2)
    self.fuwenCopyLayer : addChild(copyWid)

    local l_kuangSize=cc.size(408,355)
    local l_kuangSpr = ccui.Scale9Sprite:createWithSpriteFrameName("general_tips_dins.png")
    l_kuangSpr : setPreferredSize(l_kuangSize)
    l_kuangSpr : setPosition(dinsSize.width/2-150,dinsSize.height/2)
    copyWid  : addChild(l_kuangSpr)

    local floorSpr = ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
    floorSpr : setPreferredSize(cc.size(l_kuangSize.width-15,l_kuangSize.height-15))
    floorSpr : setPosition(l_kuangSize.width/2,l_kuangSize.height/2)
    l_kuangSpr  : addChild(floorSpr)

    local voiceSpr = ccui.Scale9Sprite:createWithSpriteFrameName("general_gold_floor.png")
    voiceSpr : setPreferredSize(cc.size(l_kuangSize.width-80,135))
    voiceSpr : setPosition(l_kuangSize.width/2+1,l_kuangSize.height/2-50)
    l_kuangSpr  : addChild(voiceSpr)

    local bagSpr=cc.Sprite:createWithSpriteFrameName("general_tubiaokuan.png")
    bagSpr:setPosition(70,l_kuangSize.height-70)
    l_kuangSpr:addChild(bagSpr)

    local goodsData=_G.Cfg.goods[fuwenData[_tag].goods_id]
    local skillSpr=_G.ImageAsyncManager:createGoodsSpr(goodsData)
    skillSpr:setPosition(39,39)
    bagSpr:addChild(skillSpr)

    local skillNameLab  = _G.Util : createLabel(goodsData.name, FONTSIZE )
	skillNameLab : setAnchorPoint(0,0.5)
	skillNameLab : setColor(_G.ColorUtil:getRGB(goodsData.name_color))
	skillNameLab : setPosition(125, l_kuangSize.height-52 )
	l_kuangSpr : addChild( skillNameLab )

	local content  = goodsData.base_type
    for m,n in pairs(content) do
    	print(m,n)
    	local textLab1 = _G.Util : createLabel(_G.Lang.type_name[content[m].type]..": ", FONTSIZE)
		textLab1       : setPosition(125+(m-1)*90, l_kuangSize.height-88)
		textLab1       : setAnchorPoint( cc.p(0.0,0.5) )
		l_kuangSpr     : addChild(textLab1)

		local attrLab1 = _G.Util : createLabel(content[m].v, FONTSIZE)
		attrLab1       : setPosition(130+(m-1)*90+textLab1:getContentSize().width, l_kuangSize.height-88)
		attrLab1       : setAnchorPoint( cc.p(0.0,0.5) )
		attrLab1 	   : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_SPRINGGREEN))
		l_kuangSpr     : addChild(attrLab1)
    end

    local haveLab=_G.Util:createLabel("拥有者",24)
    -- haveLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
    haveLab:setPosition(l_kuangSize.width/2,l_kuangSize.height/2+40)
    l_kuangSpr:addChild(haveLab,10)

    local titleSpr=cc.Sprite:createWithSpriteFrameName("general_tips_up.png")
    titleSpr:setPosition(l_kuangSize.width/2-125,l_kuangSize.height/2+40)
    l_kuangSpr:addChild(titleSpr,9)

    local titleSpr=cc.Sprite:createWithSpriteFrameName("general_tips_up.png")
    titleSpr:setPosition(l_kuangSize.width/2+120,l_kuangSize.height/2+40)
    titleSpr:setRotation(180)
    l_kuangSpr:addChild(titleSpr,9)

    self.roleGoods={}
	local count=0
	local bagNum=_G.GBagProxy:getGoodsCountById(fuwenData[_tag].goods_id)
	print("bagNum==>>",fuwenData[_tag].goods_id)
	if bagNum>0 then
		count=count+1
		self.roleGoods[count]=fuwenData[_tag].goods_id
	end
	for k,v in pairs(self.openData) do
		for j,x in pairs(v.fuwendata) do
			if fuwenData[_tag].goods_id==x.goods_id and x.flag>0 then
				count=count+1
				self.roleGoods[count]=v.id
			end
		end
	end

	if count==0 then
		local nothaveLab = _G.Util : createLabel("暂无该符文", FONTSIZE+4)
		nothaveLab       : setPosition(l_kuangSize.width/2, l_kuangSize.height/2-50)
		l_kuangSpr     : addChild(nothaveLab)
	else
		self.LeftyeSpr  = cc.Sprite : createWithSpriteFrameName("general_fangye_1.png")
		self.LeftyeSpr : setPosition(25, l_kuangSize.height/2-50)
		self.LeftyeSpr : setVisible(false)
		l_kuangSpr : addChild(self.LeftyeSpr)

		self.RightyeSpr = cc.Sprite : createWithSpriteFrameName("general_fangye_1.png")
		self.RightyeSpr : setPosition(l_kuangSize.width-25, l_kuangSize.height/2-50)
		self.RightyeSpr : setScale(-1)
		self.RightyeSpr : setVisible(false)
		l_kuangSpr  : addChild(self.RightyeSpr)

		local pageView = self:BagPageView(count,fuwenData[_tag])
		pageView : setPosition(45, l_kuangSize.height/2-115)
    	l_kuangSpr  : addChild(pageView)
	end
	
    local textLab1 = _G.Util : createLabel("点击图像可装备物品", FONTSIZE)
	textLab1       : setPosition(l_kuangSize.width/2, 35)
	l_kuangSpr     : addChild(textLab1)

    -- local r_kuangSize=cc.size(257,298)
    local r_kuangSpr = self:createCopyView(_tag)
    -- r_kuangSpr : setPreferredSize(r_kuangSize)
    r_kuangSpr : setPosition(dinsSize.width/2+210,dinsSize.height/2)
    copyWid  : addChild(r_kuangSpr)
end

function PartnerView.BagPageView( self, count,_data)
	print("BagPageView===>>>",count)
    if _data == nil then return end
	local viewSize = cc.size(325,135)
	local contSize = cc.size(count*viewSize.width/3,135)
    local bagScroll = cc.ScrollView : create()
  	bagScroll : setDirection(ccui.ScrollViewDir.none)
  	bagScroll : setViewSize(viewSize)
  	bagScroll : setContentSize(contSize)
  	bagScroll : setContentOffset( cc.p(0, 0))
  	bagScroll : setTouchEnabled(true)
  	bagScroll : setDelegate()

  	if count<4 then
  		bagScroll : setTouchEnabled(false)
  	else
  		self.RightyeSpr:setVisible(true)
  		self.LeftyeSpr:setVisible(true)
  	end

	local bagNum=_G.GBagProxy:getGoodsCountById(_data.goods_id)
	local function RoleCallBack( obj, eventType )
		if eventType == ccui.TouchEventType.ended then
			local nPosX=obj:getWorldPosition().x
          	print("nPosX--->>",nPosX,self.m_winSize.width/2,self.m_winSize.width/2-270)
          	if nPosX>self.m_winSize.width/2
            or nPosX<self.m_winSize.width/2-270
            then return end
			local goodstag=obj:getTag()
			print("镶嵌符文",goodstag)
			if bagNum>0 and goodstag==1 then
				local msg  = REQ_LINGYAO_EQUIP( )
				msg        : setArgs(self.partnerData[self.partnerid].id,_data.goods_id)
				_G.Network : send( msg )
			else
				local msg  = REQ_LINGYAO_EQUIP_OTHER( )
				msg        : setArgs(self.partnerData[self.partnerid].id,self.roleGoods[goodstag],_data.goods_id)
				_G.Network : send( msg )
			end
			self:removeFuwenLayer()
		end
	end 

    for i=1, count do
    	local roleBtn=gc.CButton:create("general_tubiaokuan.png")
    	roleBtn:setPosition(-56+i*viewSize.width/3,viewSize.height/2+8)
    	roleBtn:addTouchEventListener(RoleCallBack)
    	roleBtn:setSwallowTouches(false)
    	roleBtn:setTag(i)
    	-- roleBtn:setButtonScale(0.8)
    	bagScroll:addChild(roleBtn)
    	
    	local nameLab = _G.Util : createLabel("", FONTSIZE-2)
		nameLab       : setPosition(-56+i*viewSize.width/3,viewSize.height/2-50)
		bagScroll     : addChild(nameLab)

    	if bagNum>0 and i==1 then
    		local goodsSpr=_G.ImageAsyncManager:createGoodsSpr(_G.Cfg.goods[self.roleGoods[i]],bagNum)
    		goodsSpr:setPosition(39,39)
    		roleBtn:addChild(goodsSpr)

    		nameLab:setString("背包")
    	else
    		local headSpr=_G.ImageAsyncManager:createHeadSpr(_G.Cfg.goods[self.roleGoods[i]].icon)
    		headSpr:setPosition(39,39)
    		roleBtn:addChild(headSpr)

    		nameLab:setString(_G.Cfg.partner_init[self.roleGoods[i]].name)
    	end
	end

	return bagScroll
end

function PartnerView.createCopyView( self, _tag )
	local goodsData=nil
	local fuwenData=self.openData[self.partnerid].fuwendata
	goodsData=_G.Cfg.goods[fuwenData[_tag].goods_id].f

	local copySize=cc.size(307,355)
	local copyData ={}
	local copyNum=0
	for k,v in pairs(goodsData.wash) do
		copyData[k]=v
		copyNum=copyNum+1
	end
	if copyNum<3 then copyNum=3 end
    local copySpr = ccui.Scale9Sprite:createWithSpriteFrameName("general_tips_dins.png")
    copySpr : setPreferredSize(copySize)

    local di2kuanSpr = ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
    di2kuanSpr : setPreferredSize(cc.size(copySize.width-15,copySize.height-15))
    di2kuanSpr : setPosition(copySize.width/2,copySize.height/2)
    copySpr  : addChild(di2kuanSpr)

    local textLab = _G.Util : createLabel("获取途径", FONTSIZE+4)
	textLab       : setPosition(copySize.width/2, copySize.height-30)
	copySpr        : addChild(textLab)

	local lineSpr = ccui.Scale9Sprite:createWithSpriteFrameName("general_gold_floor.png")
	lineSpr:setPreferredSize(cc.size(copySize.width-20,copySize.height-60))
	lineSpr:setPosition(copySize.width/2,copySize.height/2-20)
	copySpr:addChild(lineSpr)
	
   	local OneHeight= (copySize.height-64)/3
  	local viewSize = cc.size( copySize.width-15, copySize.height-64 )
   	local contSize = cc.size( copySize.width-15, copyNum*OneHeight)
  	local copyScroll = cc.ScrollView : create()
  	copyScroll : setDirection(ccui.ScrollViewDir.vertical)
  	copyScroll : setViewSize(viewSize)
  	copyScroll : setContentSize(contSize)
  	copyScroll : setContentOffset( cc.p(0, viewSize.height-contSize.height))
  	copyScroll : setPosition( 8, 11 )
  	copyScroll : setTouchEnabled(true)
  	copyScroll : setDelegate()
  	copySpr : addChild( copyScroll,10)

  	local barView=require("mod.general.ScrollBar")(copyScroll)
  	barView:setPosOff(cc.p(-7,0))

  	local function CopyBtnCallBack( obj, eventType )
		if eventType == ccui.TouchEventType.ended then
			local copytag=obj:getTag()
			print("进入对应副本",copytag)
			local openId=copyData[copytag][2]
			if copyData[copytag][1]==1 then
				print("self.copyOpen[copytag]",self.copyOpen[copytag])
				if self.copyOpen[copytag]==false then
					local command = CErrorBoxCommand("该副本未开启")
   	        		controller : sendCommand( command ) 
   	        		return
				else
					local roleProperty=_G.GPropertyProxy:getMainPlay()
		            local copyId  = copyData[copytag][2]
					local chapId  = _G.Cfg.scene_copy[copyId].belong_id
		            roleProperty:setTaskInfo(_G.Const.CONST_TASK_TRACE_MATERIAL,copyId,chapId,0,1)
					_G.GLayerManager:openSubLayer(Cfg.UI_CCopyMapLayer)	
				end			
			else
				_G.GLayerManager:openSubLayer(openId)
			end
			self:removeFuwenLayer()
			if self.GoCopyLayer~=nil then
	            self.GoCopyLayer:removeFromParent(true)
	            self.GoCopyLayer=nil
	        end
		end
	end 

	self.req_copy={}
	self.copyNumLab={}
	local iii=0
  	for i=1,copyNum do
  		if copyData[i]==nil then break end

  		local lineSpr = ccui.Scale9Sprite:createWithSpriteFrameName("general_input.png")
		lineSpr:setPreferredSize(cc.size(copySize.width-25,95))
		lineSpr:setPosition(viewSize.width/2,contSize.height-i*OneHeight+OneHeight/2 )
		copyScroll:addChild(lineSpr)

  		local partnerRes="main_icon_duplicate_1.png"
	    local copyBtn = gc.CButton:create()
	    -- copyBtn : loadTextures( partnerRes, partnerRes, partnerRes, ccui.TextureResType.plistType)
	    copyBtn : setPosition( 45, contSize.height-i*OneHeight+2+OneHeight/2 ) --121*length-105*i-55-18*x
	    copyBtn : addTouchEventListener(CopyBtnCallBack)
	    copyBtn : setButtonScale(0.8)
	    copyBtn : setTag(i)
	    copyBtn : setSwallowTouches(false)
	    copyScroll : addChild(copyBtn)   
		
		if copyData[i][1]==1 then
			local copyList=_G.Cfg.scene_copy[copyData[i][2]]
			-- print("copy===>>>11111",copyData[i][2])
			local c_data=_G.Cfg.copy_chap[1][copyList.belong_id]
			-- print("copy===>>>22222",copyList.belong_id)
			
			if c_data==nil then
				c_data=_G.Cfg.copy_chap[1][10200]
			end
			print("c_data",c_data)
			local copyZjLab = _G.Util : createLabel(string.format("第%s章  第",_G.Lang.number_Chinese[c_data.paixu]),FONTSIZE)
		    copyZjLab  : setPosition( 85, contSize.height-i*OneHeight+2+OneHeight/2+15 )
		    copyZjLab  : setAnchorPoint(cc.p(0,0.5))
		    copyScroll : addChild(copyZjLab)

		    local LabWidth=85+copyZjLab:getContentSize().width
		    local NumberLab = _G.Util : createLabel(1,FONTSIZE)
		    NumberLab  : setPosition( LabWidth, contSize.height-i*OneHeight+2+OneHeight/2+15 )
		    NumberLab  : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
		    NumberLab  : setAnchorPoint(cc.p(0,0.5))
		    copyScroll : addChild(NumberLab)
		    for k,v in pairs(c_data.copy_id) do
		    	if copyData[i][2]==v then
		    		NumberLab:setString(k)
		    	end
		    end
		    
		    LabWidth=LabWidth+NumberLab:getContentSize().width
		    local copyZjLab = _G.Util : createLabel("关",FONTSIZE)
		    copyZjLab  : setPosition( LabWidth, contSize.height-i*OneHeight+2+OneHeight/2+15 )
		    copyZjLab  : setAnchorPoint(cc.p(0,0.5))
		    copyScroll : addChild(copyZjLab)

		    local copyNameLab = _G.Util : createLabel(copyList.copy_name,FONTSIZE)
		    copyNameLab : setPosition( 85, contSize.height-i*OneHeight+2+OneHeight/2-20 )
		    -- copyNameLab : setColor(_G.ColorUtil:getRGB(namecolor))
		    copyNameLab  : setAnchorPoint(cc.p(0,0.5))
		    copyScroll : addChild(copyNameLab)

		    iii=iii+1
		    self.copyNumLab[iii] = _G.Util:createLabel("",FONTSIZE)
		    self.copyNumLab[iii] : setPosition(90+copyNameLab:getContentSize().width,contSize.height-i*OneHeight+2+OneHeight/2-20)
		    self.copyNumLab[iii] : setAnchorPoint(cc.p(0,0.5))
		    copyScroll : addChild(self.copyNumLab[iii])
		    self.req_copy[iii]=copyData[i][2]
		    
		    partnerRes="main_icon_duplicate_1.png"
		else
			local content="配表里面没有该功能Id"
			if _G.Cfg.sys_open_info[copyData[i][2]]~=nil then
				content=_G.Cfg.sys_open_info[copyData[i][2]].lingyao_des
			end
			local copyZjLab = _G.Util : createLabel(content,FONTSIZE)
		    copyZjLab  : setPosition( 85, contSize.height-i*OneHeight+2+OneHeight/2-2 )
		    copyZjLab  : setDimensions(190, 50)
			copyZjLab  : setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
		    copyZjLab  : setAnchorPoint(cc.p(0,0.5))
		    copyScroll : addChild(copyZjLab)
			partnerRes=_G.Cfg.IconResList[copyData[i][2]]
		end
		copyBtn : loadTextures( partnerRes)
  	end

  	local msg  = REQ_LINGYAO_COPY_TIMES( )
	msg        : setArgs(iii,self.req_copy)
	_G.Network : send( msg )

    return copySpr
end

function PartnerView.updateCopyLab( self,_data )
	self.copyOpen={}
	for i=1,_data.count do
		if self.copyNumLab[i]==nil then return end
		print("_data.copydata[i].flag==>>",_data.copydata[i].flag,_data.copydata[i].copy_id)
		if _data.copydata[i].flag==0 then
			local copyopenlv=_G.Cfg.scene_copy[_data.copydata[i].copy_id].lv
			self.copyNumLab[i]:setString(string.format("(%d级开放)",copyopenlv))
			self.copyNumLab[i]:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
			self.copyOpen[i]=false
		else
			print("updateCopyLab==>>",_data.copydata[i].copy_id,_data.copydata[i].times,_data.copydata[i].times_all)
			self.copyNumLab[i]:setString(string.format("(%d/%d)",_data.copydata[i].times_all-_data.copydata[i].times,_data.copydata[i].times_all))
			if _data.copydata[i].times==_data.copydata[i].times_all then
				self.copyNumLab[i]:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
			else
				self.copyNumLab[i]:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
			end
		end
	end
end

function PartnerView.removeFuwenLayer( self )
	if self.fuwenCopyLayer~=nil then
        self.fuwenCopyLayer:removeFromParent(true)
        self.fuwenCopyLayer=nil
    end
end

function PartnerView.createSkill( self, _tag )
	print( " ---改变技能--- " )
	for i=1,4 do
		if self.skillBtn[i]~=nil then
			self.skillBtn[i]:removeFromParent(true)
			self.skillBtn[i]=nil
		end
	end

	local function SkillBtnCallBack( obj, eventType )
		if eventType == ccui.TouchEventType.ended then
			local skillTag=obj:getTag()
			print("创建技能描述界面")
			self : skillTitleView( self.partnerData[_tag].all_skill[skillTag],skillTag )
		end
	end 
	for i=1,4 do
		print( " ---iconString--- ",self.skillBtn[i],self.partnerData[_tag].all_skill[i][1],self.partnerData[_tag].all_skill[i][2] )
		local iconString = self.partnerData[_tag].all_skill[i][1]
		local skillIcon=_G.Cfg.skill[iconString].icon
        self.skillBtn[i] = _G.ImageAsyncManager:createSkillBtn(skillIcon,SkillBtnCallBack,i)
		self.skillBtn[i] : setGray()
		self.skillBtn[i] : setPosition(-305+i*90,-235)
		-- self.skillBtn[i]:setTag(i)
		-- self.skillBtn[i]:addTouchEventListener(SkillBtnCallBack )
		self.attrNode:addChild(self.skillBtn[i])
		if self.openData[_tag]~=nil and self.partnerData[_tag].all_skill[i][2]~=0 then
			self.skillBtn[i]:setDefault()
		end
	end
end

function PartnerView.attrView( self,_data )
	if self.m_attrLayer~=nil then 
		self.m_attrLayer:removeFromParent(true)
	    self.m_attrLayer=nil 
	end
	local dinSize=cc.size(370,267)
	local function onTouchBegan(touch,event) 
        print("ExplainView remove tips")
        local location=touch:getLocation()
        local bgRect=cc.rect(self.m_winSize.width/2-dinSize.width/2,self.m_winSize.height/2-dinSize.height/2,
        dinSize.width,dinSize.height)
        local isInRect=cc.rectContainsPoint(bgRect,location)
        print("location===>",location.x,location.y)
        print("bgRect====>",bgRect.x,bgRect.y,bgRect.width,bgRect.height,isInRect)
        if isInRect then
            return true
        end
        local function nFun()
	        print("delayCallFun-----------------")
	        if self.m_attrLayer~=nil then
	            self.m_attrLayer:removeFromParent(true)
	            self.m_attrLayer=nil
	        end
	    end
	    local delay=cc.DelayTime:create(0.01)
	    local func=cc.CallFunc:create(nFun)
	    self.m_attrLayer:runAction(cc.Sequence:create(delay,func))
        return true
    end

    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)

    self.m_attrLayer=cc.LayerColor:create(cc.c4b(0,0,0,150))
    self.m_attrLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_attrLayer)
    cc.Director:getInstance():getRunningScene():addChild(self.m_attrLayer,1000)

    self.clipNode=cc.ClippingNode:create()
	self.clipNode:setInverted(false)
	self.m_attrLayer:addChild(self.clipNode)

    local dinsSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_tips_dins.png")
    dinsSpr:setPreferredSize(dinSize)
    dinsSpr:setPosition(self.m_winSize.width/2,self.m_winSize.height/2)
    self.clipNode:addChild(dinsSpr)

    self.m_labelTitle=_G.Util:createBorderLabel("当前总属性加成",20,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    self.m_labelTitle:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
    self.m_labelTitle:setPosition(dinSize.width/2,dinSize.height-26)
    dinsSpr:addChild(self.m_labelTitle,10)

    local titleSpr=cc.Sprite:createWithSpriteFrameName("general_tips_up.png")
    titleSpr:setPosition(self.m_winSize.width/2-150,self.m_winSize.height/2+dinSize.height/2-26)
    self.clipNode:addChild(titleSpr,9)

    local titleSpr=cc.Sprite:createWithSpriteFrameName("general_tips_up.png")
    titleSpr:setPosition(self.m_winSize.width/2+145,self.m_winSize.height/2+dinSize.height/2-26)
    titleSpr:setRotation(180)
    self.clipNode:addChild(titleSpr,9)

    local frameSize=cc.size(352,215)
    local frameSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
    frameSpr:setPreferredSize(frameSize)
    frameSpr:setPosition(dinSize.width/2,dinSize.height/2-18)
    dinsSpr:addChild(frameSpr)

    self.clipNode:setStencil(dinsSpr)

    local Name_spr = { "general_hp.png", "general_att.png", "general_wreck.png", "general_def.png", 
   					   "general_hit.png", "general_dodge.png", "general_crit.png","general_crit_res.png" }
   	local Text_lab = { "气血:", "攻击:", "破甲:", "防御:", "命中:", "闪避:", "暴击:", "抗暴:"}
   	local attr_lab = {_data.hp,_data.att,_data.def,_data.wreck,_data.hit,_data.dod,_data.crit,_data.crit_res}
   	local posX=frameSize.width/2-85
   	local posY=frameSize.height+18
    for i=1,8 do
    	if i%2==1 then
    		posX=frameSize.width/2-85
    		posY=posY-50
    	else
    		posX=frameSize.width/2+90
    	end
    	local attrlogoSpr=cc.Sprite:createWithSpriteFrameName(Name_spr[i])
    	attrlogoSpr:setPosition(posX-65,posY)
    	frameSpr:addChild(attrlogoSpr)

    	local attrnameLab  = _G.Util : createLabel( Text_lab[i], FONTSIZE )
		attrnameLab  : setPosition(posX-25, posY )
		frameSpr : addChild( attrnameLab )

		local attrNumLab  = _G.Util : createLabel(attr_lab[i], FONTSIZE )
		attrNumLab : setAnchorPoint(0,0.5)
		attrNumLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
		attrNumLab : setPosition(posX-40+attrnameLab:getContentSize().width, posY )
		frameSpr : addChild( attrNumLab ) 
    end
end

function PartnerView.skillTitleView(self,s_data,_tag)
	if self.m_skillLayer~=nil then return end
	self.skillSize=cc.size(350,200)
	local function onTouchBegan(touch,event) 
        print("ExplainView remove tips")
        local location=touch:getLocation()
        local bgRect=cc.rect(self.m_winSize.width/2-self.skillSize.width/2,self.m_winSize.height/2-self.skillSize.height/2,
        self.skillSize.width,self.skillSize.height)
        local isInRect=cc.rectContainsPoint(bgRect,location)
        print("location===>",location.x,location.y)
        print("bgRect====>",bgRect.x,bgRect.y,bgRect.width,bgRect.height,isInRect)
        if isInRect then
            return true
        end
        local function nFun()
	        print("delayCallFun-----------------")
	        if self.m_skillLayer~=nil then
	            self.m_skillLayer:removeFromParent(true)
	            self.m_skillLayer=nil
	        end
	    end
	    local delay=cc.DelayTime:create(0.01)
	    local func=cc.CallFunc:create(nFun)
	    self.m_skillLayer:runAction(cc.Sequence:create(delay,func))
        return true
    end

    local listerner = cc.EventListenerTouchOneByOne:create()
    listerner : registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner : setSwallowTouches(true)

    self.m_skillLayer = cc.Layer:create()
    self.m_skillLayer : getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_skillLayer)
    cc.Director : getInstance():getRunningScene():addChild(self.m_skillLayer,1000)

    local kuangSpr = ccui.Scale9Sprite:createWithSpriteFrameName("general_bagkuang.png")
    kuangSpr : setPreferredSize(self.skillSize)
    kuangSpr : setPosition(self.m_winSize.width/2-130+_tag*90,self.m_winSize.height/2-135)
    self.m_skillLayer : addChild(kuangSpr)

    local skilldata=_G.Cfg.skill[s_data[1]]
    print("s_data[2]==>>",s_data[1],s_data[2])
    local content = skilldata.lv[1]
    if skilldata.lv[s_data[2]]~=nil then
    	content = skilldata.lv[s_data[2]]
    end
    local remark = content.remark
    if remark==nil then remark="该技能还没有描述" end

    local titleSpr = ccui.Scale9Sprite:createWithSpriteFrameName("general_voice_dins.png")
    titleSpr : setPreferredSize(cc.size(330,100))
    titleSpr : setScaleY(-1)
    kuangSpr : addChild(titleSpr)

    local textLab = _G.Util : createLabel("        "..remark, FONTSIZE)
	textLab       : setDimensions(300, 0)
	textLab       : setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	textLab       : setAnchorPoint( cc.p(0.0,0.5) )
	kuangSpr      : addChild(textLab)

	local LabH=textLab:getContentSize().height+20
	textLab  : setDimensions(300, LabH)
	titleSpr : setPreferredSize(cc.size(330,LabH))
	self.skillSize=cc.size(350,LabH+100)
	kuangSpr : setPreferredSize(self.skillSize)
	titleSpr : setPosition(self.skillSize.width/2,self.skillSize.height/2-37)
	textLab  : setPosition(30, self.skillSize.height/2-47)

	local skillIcon=_G.Cfg.skill[s_data[1]].icon
    local skillSpr=_G.ImageAsyncManager:createSkillSpr(skillIcon)
    skillSpr:setPosition(42,self.skillSize.height-40)
    kuangSpr:addChild(skillSpr)

    local skillNameLab  = _G.Util : createLabel(skilldata.name, FONTSIZE )
	skillNameLab : setAnchorPoint(0,0.5)
	skillNameLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_SPRINGGREEN))
	skillNameLab : setPosition(90, self.skillSize.height-40 )
	kuangSpr : addChild( skillNameLab )

	if s_data[2]==0 or self.openData[self.partnerid]==nil then
		local skillopenLab  = _G.Util : createLabel(skilldata.jihuo, FONTSIZE-2 )
		skillopenLab : setAnchorPoint(0,0.5)
		skillopenLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COUNTRY_DEFAULT))
		skillopenLab : setPosition(90, self.skillSize.height-55 )
		kuangSpr : addChild( skillopenLab )

		skillNameLab : setPosition(90, self.skillSize.height-25 )
	end
end

function PartnerView.lookFuwenView(self)
	local frameSize=cc.size(635,463)
	local combatView  = require("mod.general.BattleMsgView")()
	jinjieBg = combatView : create("进阶预览",frameSize)

	local attrfloor=ccui.Scale9Sprite:createWithSpriteFrameName("general_gold_floor.png")
	attrfloor:setPreferredSize(cc.size(610,200))
	attrfloor:setPosition(frameSize.width/2-9,frameSize.height/2+20)
	jinjieBg:addChild(attrfloor)

	local nowclass = self.openData[self.partnerid].class
	local nowlvLab = _G.Util : createLabel(string.format("%d阶",nowclass), FONTSIZE )
	-- nowlvLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_SPRINGGREEN))
	nowlvLab : setPosition(frameSize.width/2-140, frameSize.height-88 )
	jinjieBg : addChild( nowlvLab )

	local zhiSpr=cc.Sprite:createWithSpriteFrameName("partner_jiantou.png")
	zhiSpr:setPosition(frameSize.width/2-10,frameSize.height-88)
	jinjieBg : addChild( zhiSpr )

	local nowData=self.partnerData[self.partnerid]
	local NowAttr=nowData.attr_class
	local WillAttr=nowData.attr_class
	local willclass="等阶已满"
	if partnerList[self.openData[self.partnerid].id+1]~=nil then
		willclass=string.format("%d阶",self.openData[self.partnerid].class+1)
		WillAttr=partnerList[self.openData[self.partnerid].id+1].attr_class
	end
	local willlvLab  = _G.Util : createLabel(willclass, FONTSIZE )
	-- willlvLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_SPRINGGREEN))
	willlvLab : setPosition(frameSize.width/2+130, frameSize.height-88 )
	jinjieBg : addChild( willlvLab )


	local Name_spr = { "general_hp.png", "general_att.png", "general_wreck.png", "general_def.png", 
   					   "general_hit.png", "general_dodge.png", "general_crit.png","general_crit_res.png" }
   	local Text_lab = { "气血:", "攻击:", "破甲:", "防御:", "命中:", "闪避:", "暴击:", "抗暴:"}
   	local posX=frameSize.width/2-220
   	local posY=frameSize.height-85
   	local skilldata=nil
   	local willdata=nil
   	local skillid=nil
    for i=1,8 do
    	if i%2==1 then
    		posX=frameSize.width/2-220
    		posY=posY-50
    	else
    		posX=frameSize.width/2+100
    	end
    	local attrlogoSpr=cc.Sprite:createWithSpriteFrameName(Name_spr[i])
    	attrlogoSpr:setPosition(posX-65,posY)
    	jinjieBg:addChild(attrlogoSpr)

    	local attrnameLab  = _G.Util : createLabel( Text_lab[i], FONTSIZE )
		attrnameLab  : setPosition(posX-25, posY )
		jinjieBg : addChild( attrnameLab )

		local attrNumLab  = _G.Util : createLabel( string.format("%d > %d",NowAttr[ATTR_INDEX[i]],WillAttr[ATTR_INDEX[i]]), FONTSIZE )
		attrNumLab : setAnchorPoint(0,0.5)
		attrNumLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
		attrNumLab : setPosition(posX-35+attrnameLab:getContentSize().width, posY )
		jinjieBg : addChild( attrNumLab ) 
		if i<5 then
			skillid=nowData.all_skill[i][1]
			print("skillid==>>",skillid,nowclass)
			skilldata=_G.Cfg.skill[skillid].lv[nowclass]
			local skillIcon=_G.Cfg.skill[nowData.all_skill[i][1]].icon
			local skillSpr=_G.ImageAsyncManager:createSkillSpr(skillIcon)
			jinjieBg : addChild( skillSpr ) 
			local skillnameLab  = _G.Util : createLabel("伤害", FONTSIZE )
			skillnameLab : setAnchorPoint(cc.p(0,0.5))
			jinjieBg : addChild( skillnameLab )

			willmcdata=skilldata
			if _G.Cfg.skill[skillid].lv[nowclass+1]~=nil then
				willmcdata=_G.Cfg.skill[skillid].lv[nowclass+1]
			end
			local skillNumLab  = _G.Util : createLabel("", FONTSIZE )
			skillNumLab : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
			skillNumLab : setAnchorPoint(cc.p(0,0.5))
 
			skillSpr:setPosition(posX-40,posY-215)
			skillnameLab  : setPosition(posX, posY-215 )
			skillNumLab : setPosition(posX+skillnameLab:getContentSize().width, posY-215 )
			if i>2 then
				skillSpr:setPosition(posX-40,posY-240)
				skillnameLab : setPosition(posX, posY-240 )
				skillNumLab : setPosition(posX+skillnameLab:getContentSize().width, posY-240 )
			end
			if nowData.all_skill[i][2]>0 then
				skillnameLab:setString("伤害")
				local arg1=(skilldata~=nil) and skilldata.mc_arg2 or 0
				skillNumLab:setString(string.format("%d > %d",arg1,willmcdata.mc_arg2))
			else
				skillnameLab:setString(_G.Cfg.skill[skillid].jihuo)
				skillNumLab:setString("")
			end

			jinjieBg : addChild( skillNumLab )
		end
    end
end

function PartnerView.selectContainerByTag(self,_tag)
	self.m_selectTag=_tag

	if _tag==TAGBTN_ATTR then
		self.isTrue=false
		if self.RedHaveSpr~=nil then
			for k,v in pairs(self.RedHaveSpr) do
				v:setVisible(false)
			end
		end
		if self.attrNode~=nil then
			self.attrNode:setVisible(true)
			self.partnerid=1
			self:touchEventCallBack(self.Btn_partner[1])
			self:selectUpdate(1)
			self.ScrollView  : setContentOffset( cc.p(0, 464-self.count*116))
			if self.evolveNode~=nil then
				self.evolveNode:setVisible(false)
			end
		else
			if self.evolveNode~=nil then
				self.evolveNode:setVisible(false)
			end
			self:createAttrView()
		end
		self.powpos=cc.p(-80,-80)
		self.attrFryNode:setPosition(self.powpos)
	else
		self.isTrue=true
		if self.RedHaveSpr~=nil then
			for k,v in pairs(self.RedHaveSpr) do
				v:setVisible(true)
			end
		end

		if self.evolveNode~=nil then
			self.evolveNode:setVisible(true)
			if self.attrNode~=nil then
				self.attrNode:setVisible(false)
			end
			self:createTwoSpine(1)
		else
			if self.attrNode~=nil then
				self.attrNode:setVisible(false)
			end
			self:createEvolveView()
		end

		self.partnerid=1
		self:touchEventCallBack(self.Btn_partner[1])
		self.ScrollView  : setContentOffset( cc.p(0, 464-self.count*116))
		self.powpos=cc.p(80,-51)
		self.attrFryNode:setPosition(self.powpos)
	end

	if self.m_guide_tag then
		if self.m_guide_tag==_tag then
			_G.GGuideManager:showGuideByStep(1)
		else
			_G.GGuideManager:hideGuideByStep(1)
		end
	end
end

function PartnerView.updateXiaoHao(self)
	local goodsid = self.partnerData[self.partnerid].goods_list[1][1]
	local count   = self.partnerData[self.partnerid].goods_list[1][2]
	local goodNum = _G.GBagProxy:getGoodsCountById(goodsid)
	self.xiaohaoLab:setString(string.format("消耗%s: ",_G.Cfg.goods[goodsid].name))
	self.NumberLab:setString(string.format("%d/%d",goodNum,count))
	self.xiaohaoLab:setPosition(120+self.xiaohaoLab:getContentSize().width/2,25)
	self.NumberLab:setPosition(125+self.xiaohaoLab:getContentSize().width/2,25)

	if goodNum<count then
		self.NumberLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
	else
		self.NumberLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
	end
	print("goodsid===>>",goodsid,count,goodNum)
end

function PartnerView.setRenown(self,renown)
	local count=_G.Cfg.partner_lv_up[self.nowlv].renown
	self.xiaohaoLab:setString("消耗妖魂: ")
	self.NumberLab:setString(string.format("%d/%d",renown,count))
	self.xiaohaoLab:setPosition(145,25)
	self.NumberLab:setPosition(150,25)
	if renown<count then
		self.NumberLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
	else
		self.NumberLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
	end
end

function PartnerView.UpdateRenown(self,_lv)
	print("UpdateRenown--->>>",_lv)
	local renown=_G.GPropertyProxy:getMainPlay():getRenown()
	print("UpdateRenown--->>>",renown)
	local count=_G.Cfg.partner_lv_up[_lv].renown
	self.xiaohaoLab:setString("消耗妖魂: ")
	self.NumberLab:setString(string.format("%d/%d",renown,count))
	self.xiaohaoLab:setPosition(145,25)
	self.NumberLab:setPosition(150,25)
	if renown<count then
		self.NumberLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
	else
		self.NumberLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE))
	end
end

function PartnerView.closeWindow( self )
	if self.m_rootLayer==nil then return end
	self.m_rootLayer=nil
	cc.Director:getInstance():popScene()
	self:destroy()

	if self.m_guide_tag then
		local command=CGuideNoticShow()
      	controller:sendCommand(command)
	end

	_G.SpineManager.releaseSpineInView(self.m_spineResArray)
end
function PartnerView.guideDelete(self,_guideId)
	if (_guideId==_G.Const.CONST_NEW_GUIDE_SYS_PARTNER_LEVEL or _guideId==_G.Const.CONST_NEW_GUIDE_SYS_PARTNER_LEVEL2)
		and self.m_guide_tag then
		_G.GGuideManager:runThisStep(2)
	end
end

function PartnerView.regMediator( self )
  self.m_mediator= require("mod.partner.PartnerMediator")()
  print("PartnerMediator")
  self.m_mediator: setView(self)
end

function PartnerView.AttrFryNode(self,_obj)
	self.attrFryNode=_G.Util:getLogsView():createAttrLogsNode()
	self.attrFryNode:setPosition(self.powpos)
	_obj:addChild(self.attrFryNode,1001)
end

return PartnerView