local TransferView = classGc(view, function(self)
	self.m_num=-1
end)

local FONTSIZE = 20
local m_winSize=cc.Director:getInstance():getWinSize()
local viewSize = cc.size( 662,440 )
local iconSize = cc.size(78,78)

function TransferView.create( self )
  	local myZBView  = require( "mod.general.BattleMsgView"  )()
	self.ZB_D2Base = myZBView : create("转    职",viewSize)
	local m_mainSize = myZBView : getSize()

	self:initView()
  	-- return self.ZB_D2Base
end

function TransferView.initView( self )
    local count = 3
    print("self.proNode",count)
    local ScrollView  = cc.ScrollView : create()
    self.m_ScrollView = ScrollView
    self.containerSize = cc.size(viewSize.width/2*(count-1), viewSize.height)
    
    ScrollView : setDirection(ccui.ScrollViewDir.horizontal)
    ScrollView : setViewSize(viewSize)
    ScrollView : setContentSize(self.containerSize)
    ScrollView : setContentOffset( cc.p(viewSize.width-self.containerSize.width, 0))
    ScrollView : setPosition(cc.p(0, -29))
    ScrollView : setBounceable(false)
    ScrollView : setTouchEnabled(true)
    ScrollView : setDelegate()
    self.ZB_D2Base : addChild(ScrollView)
    
    for i=1, count do
		local roleBgSpr=self:OneRoleDoubleView(i)
		if roleBgSpr~=nil then
			roleBgSpr:setPosition(viewSize.width/4-10+self.m_num*(viewSize.width/2-17),viewSize.height/2)
			ScrollView:addChild(roleBgSpr)
		end	
	end
end

function TransferView.OneRoleDoubleView( self, _pro )
	local mypro=_G.GPropertyProxy:getMainPlay():getPro()
	-- local m_pro=_pro>3 and 5 or _pro
    if _pro==mypro or _pro>3 then return end
	

	_G.SysInfo:setTextureFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
	local doubleSpr=cc.Sprite:create("ui/bg/transfer_rolebg.png")
	doubleSpr:setScale(0.97)
	_G.SysInfo:resetTextureFormat()
	local doubleSize=doubleSpr:getContentSize()
	
	local nameLab = _G.Util:createBorderLabel(_G.Lang.Role_ProName[_pro], FONTSIZE+4,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    nameLab       : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_BRIGHTYELLOW)) 
    nameLab		  : setPosition(doubleSize.width/2,doubleSize.height-28)
    doubleSpr:addChild(nameLab)

	local proSpine = cc.Sprite:create(string.format("painting/1000%d.png",_pro))
	proSpine : setScale(0.8)
  	proSpine : setPosition(doubleSize.width/2,doubleSize.height/2-3 )
  	doubleSpr : addChild(proSpine)

	local tempLayer=cc.LayerColor:create(cc.c4b(0,0,0,255*0.5))
	tempLayer:setContentSize(cc.size(doubleSize.width-23,85))
	tempLayer:setOpacity(80)
	tempLayer:setPosition(11,70)
	doubleSpr:addChild(tempLayer)

	local infoLab = _G.Util:createLabel(_G.Cfg.player_init[_pro].describe, FONTSIZE-2)
    -- infoLab       : setColor(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_BRIGHTYELLOW)) 
    infoLab       : setAnchorPoint( cc.p(0.0,1.0) )
    infoLab       : setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    infoLab       : setDimensions(doubleSize.width-30,85)
    infoLab		  : setPosition(15,145)
    doubleSpr:addChild(infoLab)

	local function intensifyEvent( send,eventType )
		if eventType == ccui.TouchEventType.ended then
			local proTag=send:getTag()
			print("proTag--->>",proTag)
			local szMsg=string.format("确认转职为%s?\n(转职后，技能等级将重置)",_G.Lang.Role_ProName[proTag] or "")
			local function fun1()
				local msg=REQ_ROLE_PRO_CHANGE()
				msg:setArgs(proTag) 
				_G.Network:send(msg)
			end
			_G.Util:showTipsBox(szMsg,fun1)
		end
		return false
	end 

	local m_button  = gc.CButton:create()
	m_button  : addTouchEventListener(intensifyEvent)
	m_button  : loadTextures("general_btn_gold.png")
	m_button  : setTitleText("确认转职")
	m_button  : setTitleFontSize(22)
	m_button  : setTitleFontName(_G.FontName.Heiti)
	m_button  : setPosition(cc.p(doubleSize.width/2,35))
	m_button  : setTag(_pro)
	doubleSpr : addChild(m_button)

	self.m_num=self.m_num+1
	return doubleSpr
end

return TransferView