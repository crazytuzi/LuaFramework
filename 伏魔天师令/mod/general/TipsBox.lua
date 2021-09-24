local TipsBox=classGc(view)

local P_TITLE_COLOR=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD)
local P_VIEW_SIZE=cc.size(416,305)

function TipsBox:create(szContent,funSure,funCancel,isSave,isTouch)
	self._szContent=szContent or ""
	self._funSure  =funSure
	self._funCancel=funCancel
	self._isSave   =isSave

	local function onTouchBegan() return true end
	local listerner=cc.EventListenerTouchOneByOne:create()
	listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
	listerner:setSwallowTouches(true)

	self.rootNode=cc.Node:create()
	self.m_layer=cc.Node:create()
	self.rootNode:addChild(self.m_layer)
	if not isTouch then
		self.m_layer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,self.m_layer)
	end

	-- local act1=cc.ScaleTo:create(0.1,0.97)
	local act2=cc.ScaleTo:create(0.2,1.04)
	local act3=cc.ScaleTo:create(0.1,0.98)
	local act4=cc.ScaleTo:create(0.05,1)
	-- self.m_layer:setScale(0.9)
	self.m_layer:runAction(cc.Sequence:create(act2,act3,act4))

	self:__initView()

	local visibleSize=cc.Director:getInstance():getVisibleSize()
	self.m_layer:setPosition(visibleSize.width*0.5,visibleSize.height*0.5)

	local tempLayer=cc.LayerColor:create(cc.c4b(0,0,0,150))
	-- tempLayer:setPosition(-visibleSize.width*0.5,-visibleSize.height*0.5)
    self.rootNode:addChild(tempLayer,-1)

	return self.rootNode
end

function TipsBox:getMainlayer()
	return self.m_layer
end

function TipsBox:__initView()
	self.m_mainBgSpr=ccui.Scale9Sprite:createWithSpriteFrameName( "general_tips_dins.png" ) 
	self.m_mainBgSpr:setPreferredSize( P_VIEW_SIZE )
	self.m_layer:addChild(self.m_mainBgSpr)

	local tipslogoSpr = cc.Sprite : createWithSpriteFrameName("general_tips_up.png")
	tipslogoSpr : setPosition(P_VIEW_SIZE.width/2-130, P_VIEW_SIZE.height-32)
	self.m_mainBgSpr : addChild(tipslogoSpr)

	local tipslogoSpr = cc.Sprite : createWithSpriteFrameName("general_tips_up.png")
	tipslogoSpr : setPosition(P_VIEW_SIZE.width/2+125, P_VIEW_SIZE.height-32)
	tipslogoSpr : setRotation(180)
	self.m_mainBgSpr : addChild(tipslogoSpr)

	-- local lineSpr1=ccui.Scale9Sprite:createWithSpriteFrameName("general_double_line.png")
	
	-- lineSpr1:setPreferredSize(cc.size(P_VIEW_SIZE.width-30,lineSprSize.height))
	-- lineSpr1:setPosition(P_VIEW_SIZE.width*0.5,205)
	-- self.m_mainBgSpr:addChild(lineSpr1)

	local lineSpr2=ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
	-- local lineSprSize = lineSpr2 : getPreferredSize()
	lineSpr2:setPreferredSize(cc.size(P_VIEW_SIZE.width-30,172))
	lineSpr2:setPosition(P_VIEW_SIZE.width*0.5,P_VIEW_SIZE.height/2+8)
	self.m_mainBgSpr:addChild(lineSpr2)

	self.m_titleLab=_G.Util:createBorderLabel("提  示",24)
	self.m_titleLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LBLUE))
	self.m_mainBgSpr:addChild(self.m_titleLab)
 
	self.m_mainLab=_G.Util:createLabel(self._szContent,20)
	self.m_mainLab:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER) --居中对齐 
	-- self.m_mainLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LBLUE))
	self.m_mainLab:setDimensions( P_VIEW_SIZE.width-20*2,90)            --设置文字区
	self.m_mainBgSpr:addChild(self.m_mainLab)
	-- self.m_mainLab:setAnchorPoint(cc.p(0.5, 0.5))
	
	self.m_sureButton=gc.CButton:create("general_btn_gold.png")
	self.m_sureButton:setTitleText("确 认")
	self.m_sureButton:setTitleFontSize(24)
	self.m_sureButton:setTitleFontName(_G.FontName.Heiti)
	--self.m_sureButton:enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
	self.m_sureButton:setTag(1)
	-- self.m_sureButton:setButtonScale(0.8)
	self.m_mainBgSpr:addChild(self.m_sureButton)

	self.m_cancelButton=gc.CButton:create("general_btn_lv.png")
	self.m_cancelButton:setTitleText("取 消")
	self.m_cancelButton:setTitleFontSize(24)
	self.m_cancelButton:setTitleFontName(_G.FontName.Heiti)
	self.m_cancelButton:setTag(2)
	-- self.m_cancelButton:setButtonScale(0.8)
	self.m_mainBgSpr:addChild(self.m_cancelButton)

	local btnSize=self.m_sureButton:getContentSize()
	self.m_titleLab     :setPosition(P_VIEW_SIZE.width*0.5,P_VIEW_SIZE.height-30)
	self.m_mainLab      :setPosition(P_VIEW_SIZE.width*0.5,P_VIEW_SIZE.height*0.5)
	self.m_sureButton   :setPosition(P_VIEW_SIZE.width*0.5-btnSize.width*0.5-20,btnSize.height*0.5+15)
	self.m_cancelButton :setPosition(P_VIEW_SIZE.width*0.5+btnSize.width*0.5+20,btnSize.height*0.5+15)

	local function local_buttonCallBack(sender, eventType)
		if eventType==ccui.TouchEventType.ended then
			local btnName=sender:getTag()
			if btnName==1 or btnName==777 or btnName==888 then
				if self._funSure~=nil then
					self._funSure(self.m_isNeverNotic)
				end
				if self._isSave then return end
				self:remove()
			elseif btnName==2 then
				if self._funCancel~=nil then
					self._funCancel()
				end
				self.m_isNeverNotic=nil
				self:remove()
			end
		end
	end
	self.m_sureButton  :addTouchEventListener(local_buttonCallBack)
	self.m_cancelButton:addTouchEventListener(local_buttonCallBack)
end

function TipsBox.setSureBtnText(self,_str)
	self.m_sureButton:setTitleText(_str)
	--self.m_sureButton:enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
end
function TipsBox.setCancelBtnText(self,_str)
	self.m_cancelButton:setTitleText(_str)
end
function TipsBox.hideCancelBtn(self)
	if self.m_cancelButton~=nil then
		self.m_cancelButton:removeFromParent(true)
		self.m_cancelButton=nil
	end
	
	local surePosX,surePosY=self.m_sureButton:getPosition()
	self.m_sureButton:setPosition(cc.p(P_VIEW_SIZE.width*0.5,surePosY))
end
function TipsBox.getSureBtn( self )
	return self.m_sureButton
end

function TipsBox.setTitleLabel(self,_szTitle)
	self.m_titleLab:setString(_szTitle or "")
end

function TipsBox.setContentPosOff(self,_pos)
	local pX,pY=self.m_mainLab:getPosition()
	self.m_mainLab:setPosition(pX+_pos.x,pY+_pos.y)
end

function TipsBox.setbuzuLabel(self,_str,_color)
	if self._buzuLabel==nil then
		self._buzuLabel=_G.Util:createLabel(_G.Lang.LAB_N[940],18)
		self._buzuLabel:setPosition(P_VIEW_SIZE.width*0.5,130)
		self.m_mainBgSpr:addChild(self._buzuLabel)

		if _color~=nil then
			self._buzuLabel:setColor(_color)
		end
		return
	end

	self._buzuLabel:setString(_str)
	if _color~=nil then
		self._buzuLabel:setColor(_color)
	end
end

function TipsBox.setNoticLabel(self,_str,_color)
	if self._noticLabel==nil then
		self._noticLabel=_G.Util:createLabel(_str,18)
		self._noticLabel:setPosition(P_VIEW_SIZE.width*0.5,120)
		self.m_mainBgSpr:addChild(self._noticLabel)

		if _color~=nil then
			self._noticLabel:setColor(_color)
		end
		return
	end

	self._noticLabel:setString(_str)
	if _color~=nil then
		self._noticLabel:setColor(_color)
	end
end

function TipsBox.setTimesLabel(self,_str,_color)
	if self.timesLab==nil then
		local labWidth=self._noticLabel:getContentSize().width
		self.timesLab=_G.Util:createLabel(_str,18)
		self.timesLab:setPosition(P_VIEW_SIZE.width*0.5+labWidth/2+10,90)
		self.m_mainBgSpr:addChild(self.timesLab)

		if _color~=nil then
			self.timesLab:setColor(_G.ColorUtil:getRGB(_color))
		end
		return
	end

	self.timesLab:setString(_str)
	if _color~=nil then
		self.timesLab:setColor(_color)
	end
end

function TipsBox.showNeverNotic(self,_Lab)
	local function nCheckBoxEvent(sender,state)
		self.m_isNeverNotic=state==0
    end
    local szUnCheck="general_gold_floor.png"
    local szSelect="general_check_selected.png"
    local checkBox=ccui.CheckBox:create(szUnCheck,szUnCheck,szSelect,szUnCheck,szUnCheck,ccui.TextureResType.plistType)
    checkBox:addEventListener(nCheckBoxEvent)
    checkBox:setPosition(-80,-30)
    self.m_layer:addChild(checkBox) 

    local LabStr=_G.Lang.LAB_N[106]
    if _Lab~=nil then LabStr=_Lab end
    local checkLabel=_G.Util:createLabel(LabStr,20)
    checkLabel:setPosition(-55, -30)
    -- checkLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    checkLabel:setAnchorPoint(0,0.5)
    self.m_layer:addChild(checkLabel)

    -- self:setContentPosOff(cc.p(0,22))

    self.m_isNeverNotic=false
end

function TipsBox.remove( self )
	if self.rootNode~=nil then
		self.rootNode:removeFromParent(true)
		self.rootNode=nil
	end
end

return TipsBox


