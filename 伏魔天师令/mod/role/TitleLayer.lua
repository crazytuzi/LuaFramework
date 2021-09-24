local TitleLayer=classGc(view,function(self,_titleMsg)
	self.m_titleMsgArray=_titleMsg or {}
	self.oldTid = self.m_titleMsgArray.tid or 0
	self.newTid = self.m_titleMsgArray.tid or 0
	self.isTru=true
end)

local DINS_TAG = 1001
local P_HEIGHT_ONE=66
local P_HEIGHT_SUB=60
local FONT_NAME=_G.FontName.Heiti
local COLOR_DARKORANGE=_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_DARKORANGE)
local COLOR_BROWN=_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_BROWN)
local COLOR_DARKORANGE=_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_DARKORANGE)
local COLOR_BRIGHTYELLOW=_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_DARKPURPLE)
local COLOR_RED=_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_ORED)
local COLOR_HBULE=_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_HBLUE)

function TitleLayer.unregister(self)
	self:__removeTimesSchedule()
end
function TitleLayer.__create(self)
	self.m_rootNode=cc.Node:create()
	self:__initParment()
	self:__initView()
	self:__resetLeftPos()
	self:__updateCanActivateSpr()
	self:__addTimesSchedule()
	return self.m_rootNode
end

function TitleLayer.__initParment(self)
	local titleCnf=_G.Cfg.title
	local tolArray={}
	local subArray={}
	local tolCount=0
	for i=1,#titleCnf do
		local tempArray={}
		-- if i~=5 then --排除门派大战
			for j=1,#titleCnf[i] do
				local tolName=titleCnf[i][j].sub_typename
				local tempPos=tempArray[tolName]
				if tempPos then
					local subCount=#subArray[tempPos]
					for k,subCnf in pairs(titleCnf[i][j]) do
						if type(subCnf)=="table" then
							subCount=subCount+1
							subArray[tempPos][subCount]=subCnf
						end
					end
				else
					tolCount=tolCount+1
					tempArray[tolName]=tolCount
					
					local tolT={
						pos=tolCount,
						name=tolName
					}
					tolArray[tolCount]=tolT
					subArray[tolCount]={}
					local subCount=0
					for k,subCnf in pairs(titleCnf[i][j]) do
						if type(subCnf)=="table" then
							subCount=subCount+1
							subArray[tolCount][subCount]=subCnf
						end
					end
				end
			end
		-- end
	end
	self.m_tolCnfArray=tolArray
	self.m_subCnfArray=subArray
	self.m_titleCnfArray=titleCnf
end

function TitleLayer.__initView(self)
	local leftSize=cc.size(211,476)
	local rightSize=cc.size(615,476)
	local winSize=cc.Director:getInstance():getVisibleSize()
	-- local nWidth=leftSize.width+rightSize.width+2
	local nPosY=-55

	-- local leftDins=ccui.Scale9Sprite:createWithSpriteFrameName("general_double2.png",cc.rect(24,24,1,1))
	-- leftDins:setPreferredSize(cc.size(leftSize.width-10,leftSize.height-10))
	-- leftDins:setPosition(-nWidth*0.5+leftSize.width*0.5-5,nPosY)
	-- self.m_rootNode:addChild(leftDins)

	-- local rightDins=ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png",cc.rect(24,24,1,1))
 --    rightDins:setPreferredSize(rightSize)
 --    rightDins:setPosition(nWidth*0.5-rightSize.width*0.5 +3,nPosY)
 --    self.m_rootNode:addChild(rightDins)

    -- rightDins:setVisible(false)

    local leftSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_login_dawaikuan.png")
	leftSpr:setPreferredSize(leftSize)
	leftSpr:setPosition(-308,nPosY)
	self.m_rootNode:addChild(leftSpr)

	local rightSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_double.png")
	rightSpr:setPreferredSize(rightSize)
	rightSpr:setPosition(110,nPosY)
	self.m_rootNode:addChild(rightSpr)

	self.m_viewSize=cc.size(leftSize.width,leftSize.height-10)
	self.m_lpScrollView=cc.ScrollView:create()
	self.m_lpScrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
	self.m_lpScrollView:setViewSize(self.m_viewSize)
	self.m_lpScrollView:setPosition(-415,nPosY-leftSize.height*0.5+3)
	self.m_rootNode:addChild(self.m_lpScrollView)

	local function c(sender,eventType)
        if eventType==ccui.TouchEventType.ended then
            local tag=sender:getTag()
            local nPos=sender:getWorldPosition()
            print("cFun===>>",nPos.y,winSize.height/2+leftSize.height/2-75,winSize.height/2-leftSize.height/2-42)
          	if nPos.y>winSize.height/2+leftSize.height/2-75 
            or nPos.y<winSize.height/2-leftSize.height/2-42
            or tag<=0 then return end
			self:__createLeftSubBtn(tag)
        end
    end
	local tolBtnArray={}
	for i=1,#self.m_tolCnfArray do
		local tempBtn=gc.CButton:create("general_title_one.png")
	    tempBtn:setTag(i)
	    -- tempBtn:setContentSize(cc.size(188,51))
	    -- tempBtn:setButtonScale(220/188)
	    tempBtn:addTouchEventListener(c)
	 --    tempBtn:setTitleText(self.m_tolCnfArray[i].name)
		-- tempBtn:setTitleColor(COLOR_BROWN)
		-- tempBtn:setTitleFontSize(22)
		-- tempBtn:setTitleFontName(FONT_NAME)
		tempBtn:setSwallowTouches(false)
	    self.m_lpScrollView:addChild(tempBtn)
	    tolBtnArray[i]=tempBtn

	    local btnSize=tempBtn:getContentSize()
	    local label1=_G.Util:createLabel(self.m_tolCnfArray[i].name,24)
	    label1:setColor(COLOR_BROWN)
	    label1:setPosition(cc.p(btnSize.width/2,btnSize.height/2))
	    tempBtn:addChild(label1)
	    
	    local dirSpr=cc.Sprite:createWithSpriteFrameName("general_down.png")
	    dirSpr:setPosition(30,btnSize.height*0.5)
	    dirSpr:setTag(666)
	    dirSpr:setRotation(-90)
	    dirSpr:setScale(188/220*0.8)
	    tempBtn:addChild(dirSpr)

	    local count = 0
	    for k,v in pairs(self.m_subCnfArray[i]) do
	    	print(v.id,"aaaaaaa")
	    	print(self.m_titleMsgArray[v.id].new)
	    	count = count + self.m_titleMsgArray[v.id].new
	    end
	    
	    if count >0 then
	    	local dins=cc.Sprite:createWithSpriteFrameName("general_redpoint.png")
	    	dins:setPosition(cc.p(btnSize.width-15,btnSize.height-10))
	    	dins:setTag(DINS_TAG)
	    	tempBtn:addChild(dins)
	    	-- local size = dins:getContentSize()
	    	-- local newCount=_G.Util:createLabel(tostring(count),18)
	    	-- newCount:setPosition(cc.p(size.width/2,size.height/2-2))
	    	-- dins:addChild(newCount)
	    end
	end
	self.m_tolBtnArray=tolBtnArray
	self:__createLeftSubBtn(1)
end

function TitleLayer.__resetLeftPos(self,_touchPos)
	local tolEndPos,tolCount,subCount
	if self.m_selectTolPos then
		subCount=#self.m_subBtnArray
		tolCount=#self.m_tolBtnArray+subCount
		tolEndPos=self.m_selectTolPos
	else
		subCount=0
		tolCount=#self.m_tolBtnArray
		tolEndPos=tolCount
	end
	local _,preTouchY=nil
	if _touchPos~=nil then
		_,preTouchY=self.m_tolBtnArray[_touchPos]:getPosition()
	end

	local oneHeight=P_HEIGHT_ONE
	local maxHeight=tolCount*oneHeight
	maxHeight=maxHeight<self.m_viewSize.height and self.m_viewSize.height or maxHeight
	local nPosX=self.m_viewSize.width*0.5
	local nPosY=maxHeight-oneHeight*0.5
	for i=1,tolEndPos do
		local tolBtn=self.m_tolBtnArray[i]
		if i==self.m_selectTolPos then
			tolBtn:setPosition(nPosX+3,nPosY)
		else
			tolBtn:setPosition(nPosX,nPosY)
		end

		nPosY=nPosY-oneHeight
	end

	if self.m_subBtnArray~=nil and self.m_selectTolPos~=nil then
		for i=1,subCount do
			local subBtn=self.m_subBtnArray[i]
			subBtn:setPosition(nPosX,nPosY+5)

			nPosY=nPosY-oneHeight
		end
		self:__resetTolBtnDir(true)
		self:__updateCanActivateSpr()
	end

	for i=tolEndPos+1,#self.m_tolBtnArray do
		local tolBtn=self.m_tolBtnArray[i]
		tolBtn:setPosition(nPosX,nPosY)

		nPosY=nPosY-oneHeight
	end

	self.m_lpScrollView:setContentSize(cc.size(self.m_viewSize.width,maxHeight))
	local maxOffY=maxHeight-self.m_viewSize.height
	if _touchPos==nil then
		local nOffY=maxOffY
		self.m_lpScrollView:setContentOffset(cc.p(0,-nOffY))
	else
		local preOffset=self.m_lpScrollView:getContentOffset()
		local touchBtn=self.m_tolBtnArray[_touchPos]
		local _,curTouchY=touchBtn:getPosition()
		local subTouchY=preTouchY-curTouchY
		print("preY",preTouchY,"curY",curTouchY)
		local nOffY=-preOffset.y-subTouchY
		nOffY=nOffY<0 and 0 or nOffY
		nOffY=nOffY>maxOffY and maxOffY or nOffY
		self.isTru=true
		-- local wolPos=touchBtn:getWorldPosition()
		-- local relPos=self.m_lpScrollView:convertToNodeSpaceAR(wolPos)
		-- local nOffY=btnPos.y-relPos.y
		-- print("GGGGGGG>>>",btnPos.y,relPos.y,nOffY)
		-- local nOffY=nSelectPosY-self.m_viewSize.height
		-- nOffY=nOffY>0 and nOffY or 0
		if subTouchY > 0 then
			self.m_lpScrollView:setContentOffset(cc.p(0,-63))
		else
			if curTouchY < self.m_viewSize.height then
				self.m_lpScrollView:setContentOffset(cc.p(0,-0))
			else
				self.m_lpScrollView:setContentOffset(cc.p(0,-(curTouchY - self.m_viewSize.height + 32)))
			end
		end
		--self.m_lpScrollView:setContentOffset(cc.p(0,-nOffY))
	end
	if self.m_lpScrollBar~=nil then
		self.m_lpScrollBar:remove()
	end
	self.m_lpScrollBar=require("mod.general.ScrollBar")(self.m_lpScrollView)
	self.m_lpScrollBar:setPosOff(cc.p(-5,0))
end
function TitleLayer.__resetTolBtnDir(self,_isDown)
	if self.m_selectTolPos==nil then return end
	local tempBtn=self.m_tolBtnArray[self.m_selectTolPos]
	local dirSpr=tempBtn:getChildByTag(666)
	if dirSpr==nil then return end
	if _isDown then
		dirSpr:setRotation(0)
		--tempBtn:setTitleColor(COLOR_BROWN)
		--tempBtn:enableTitleOutline(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_XSTROKE))
		tempBtn:loadTextureNormal("general_title_two.png")
	else
		dirSpr:setRotation(-90)
		--tempBtn:setTitleColor(COLOR_BROWN)
		--tempBtn:enableTitleOutline(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_PSTROKE))
		tempBtn:loadTextureNormal("general_title_one.png")
	end
end

function TitleLayer.__createLeftSubBtn(self,_tolPos)
	-- if self.m_subBtnContainer~=nil then
	-- 	self.m_subBtnContainer:removeAllChildren(true)
	-- else
	-- 	self.m_subBtnContainer=cc.Node:create()
	-- 	self.m_lpScrollView:addChild(self.m_subBtnContainer)
	-- end
	if self.m_subBtnArray~=nil then
		for i=1,#self.m_subBtnArray do
			self.m_subBtnArray[i]:removeFromParent(true)
		end
		self.m_subBtnArray=nil
	end
	self.m_subHightSpr=nil

	self:__resetTolBtnDir(false)
	if _tolPos==self.m_selectTolPos then
		self.m_selectTolPos=nil
		self:__resetLeftPos(_tolPos)
		return
	end
	self.m_selectTolPos=_tolPos

	local subBtnArray={}
	local subArray=self.m_subCnfArray[_tolPos]
	local btnSize=cc.size(self.m_viewSize.width,P_HEIGHT_ONE)

	local function c(sender,eventType)
        if eventType==ccui.TouchEventType.ended then
            local tag=sender:getTag()
            local subCnf=subArray[tag]
        	self:__showTitleInfo(subCnf)
        	self:__showSubBtnSelect(sender)

        	if self.m_titleMsgArray[subCnf.id].new == 1 then
        		local msg = REQ_TITLE_NEW()
        		msg:setArgs(subCnf.id)
        		_G.Network:send(msg)
        		self.m_titleMsgArray[subCnf.id].new = 0
        	end
        end
    end


	for i=1,#subArray do
		local tempWidget=ccui.Widget:create()
		tempWidget:setTouchEnabled(true)
	    tempWidget:setContentSize(btnSize)
	    tempWidget:addTouchEventListener(c)
	    tempWidget:setTag(i)
	    tempWidget:setSwallowTouches(false)
	    self.m_lpScrollView:addChild(tempWidget)

	    tempWidget:addChild(self:__createLightSpr(),0)

	    local tempLabel=_G.Util:createLabel(subArray[i].title_name,20)
	    tempLabel:setPosition(btnSize.width*0.5,btnSize.height*0.5-4)
	    -- tempLabel:setOpacity(180)
	    tempLabel:setTag(1858)
	    print("state:",self.m_titleMsgArray[subArray[i].id].state)
	    if self.m_titleMsgArray[subArray[i].id].state == 1 then
	    	tempLabel:setColor(COLOR_DARKORANGE)
	    else
	    	tempLabel:setColor(COLOR_BROWN)
	    end
	    tempWidget:addChild(tempLabel,1)

	    if self.m_subCnf~=nil and self.m_subCnf.id==subArray[i].id then
	    	self:__showSubBtnSelect(tempWidget)
	    end
	    if self.isTru==true then
	    	local subCnf=subArray[i]
	    	self:__showTitleInfo(subCnf)
	    	self:__showSubBtnSelect(tempWidget)
	    end
	    self.isTru=false

	    
	    subBtnArray[i]=tempWidget
	end

	self.m_subBtnArray=subBtnArray

	self:__resetLeftPos(_tolPos)
end

function TitleLayer.__createLightSpr(self,_isHight)
	local szSprName=_isHight and "general_title_three.png" or "general_btn_pblue.png"
	local node=cc.Node:create()
	local spr1=cc.Sprite:createWithSpriteFrameName(szSprName)
	-- spr1:setScale(220/188)
	--local spr2=cc.Sprite:createWithSpriteFrameName(szSprName)
	local sprSize=spr1:getContentSize()
	--spr1:setRotation(180)
	-- spr1:setAnchorPoint(cc.p(0.5,0))
	--spr2:setAnchorPoint(cc.p(0.5,0))
	if _isHight then
		spr1:setPosition(0,-1)
	else
		spr1:setPosition(0,0)
	end
	-- spr1:setPosition(0,0)
	--spr2:setPosition(0,-P_HEIGHT_SUB*0.5)

	node:addChild(spr1)
	--node:addChild(spr2)
	node:setPosition(self.m_viewSize.width*0.5,P_HEIGHT_SUB*0.5)
	return node
end

function TitleLayer.__showSubBtnSelect(self,_btn,_tag)
	_btn:getChildByTag(1858):setColor(COLOR_DARKORANGE)
	
	if self.m_subHightSpr~=nil then
		self.m_subHightSpr:getParent():getChildByTag(1858):setColor(COLOR_BROWN)
		self.m_subHightSpr:retain()
		self.m_subHightSpr:removeFromParent(false)
		_btn:addChild(self.m_subHightSpr,0)
		self.m_subHightSpr:release()
		return
	end
	local hightSpr=self:__createLightSpr(true)
	_btn:addChild(hightSpr,0)

	self.m_subHightSpr=hightSpr
end

function TitleLayer.__showTitleInfo(self,_subCnf)
	if self.m_subCnf==_subCnf then
		return
	end
	self.m_subCnf=_subCnf
	if self.m_rightInfoContainer==nil then
		self:__createTitleInfo(_subCnf)
		return
	end
	self.m_rightInfoContainer:setVisible(true)
	self:showStrengthOkEffect(_subCnf.te)

	local attrArray=self:__getAttrArray(_subCnf.attr)
	for i=1,#self.m_properLbArray do
		local szProper=""
		if attrArray[i] then
			szProper=string.format("%s + %d",attrArray[i].name,attrArray[i].value)
		end
		self.m_properLbArray[i]:setString(szProper)
	end

	if self.m_rightInfoContainer:getChildByTag(777) then
		self.m_rightInfoContainer:getChildByTag(777):removeFromParent()
	end

	local szTemp,sWidth=self:__formatString(_subCnf.describe,_subCnf.arg1,_subCnf.arg2,self.m_titleMsgArray[_subCnf.id].state)
	self.m_conditionLabel:setString("")
	local point = cc.p(self.m_conditionLabel:getPositionX()-sWidth/2,self.m_conditionLabel:getPositionY())
	szTemp:setPosition(point)
	self.m_rightInfoContainer:addChild(szTemp)

	self.m_useEndTimes=nil
	local titleMsg=self.m_titleMsgArray[_subCnf.id]
    if not titleMsg then
    	self:resetHandleBtn()
    	self.m_condTimesLabel:setString("load...")
    else
    	self:resetHandleBtn(titleMsg)

    	local szTimes,nColor=self:__getTimesInfo(titleMsg)
    	local conSize=self.m_conditionLabel:getContentSize()
    	local _nx,_ny=self.m_conditionLabel:getPosition()
    	self.m_condTimesLabel:setString(szTimes)
    	self.m_condTimesLabel:setColor(nColor)
		--self.m_condTimesLabel:setPosition(115-40,_ny-20)
		self.m_condTimesLabel:setPositionY(_ny-20)
		if titleMsg.state == 1 then
			self.m_condTimesLabel:setVisible(true)
		else
			--self.m_condTimesLabel:setVisible(false)
		end
    end
end
function TitleLayer.__createTitleInfo(self,_subCnf)
	local rightSize=cc.size(615,476)
	self.m_rightInfoContainer=cc.Node:create()
	self.m_rootNode:addChild(self.m_rightInfoContainer,2)
	print("effect_id:",_subCnf.te)
	
	local midPosX=110

	self:showStrengthOkEffect(_subCnf.te)
	-- local szImg=string.format("title_%d.png",_subCnf.id)
	-- self.m_titleLabel=cc.Sprite:createWithSpriteFrameName(szImg)
	-- --self.m_titleLabel:setColor(COLOR_BROWN)
	-- self.m_titleLabel:setPosition(midPosX,135)
	-- self.m_rightInfoContainer:addChild(self.m_titleLabel)

	-- local effect=_G.SpineManager.createSpine(string.format("spine/%d",_subCnf.te),1)
 --    effect:setAnimation(0,"idle",true)
 --    effect:setPosition(cc.p(self.m_titleLabel:getContentSize().width/2,self.m_titleLabel:getContentSize().height/2))
 --    if _subCnf.pai==1 then
 --    	self.m_titleLabel:addChild(effect,-1)
 --    else
 --    	self.m_titleLabel:addChild(effect)
 --    end

	-- local nTimes=1
 --    self.m_titleLabel2=cc.Sprite:createWithSpriteFrameName(szImg)
 --    self.m_titleLabel2:setPosition(midPosX,135)
    -- self.m_titleLabel2:setScaleX(1.1)
    -- self.m_titleLabel2:setScaleY(1.3)
    -- self.m_titleLabel2:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(nTimes,155),cc.FadeTo:create(nTimes,255))))
    --self.m_titleLabel2:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ScaleTo:create(nTimes,1.13,1.35),cc.ScaleTo:create(nTimes,1.05,1.15))))
    --self.m_titleLabel2:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.TintTo:create(nTimes,cc.c3b(255,215,0)),cc.TintTo:create(nTimes,cc.c3b(255,255,255)))))
    -- self.m_rightInfoContainer:addChild(self.m_titleLabel2,-1)
    -- _G.ShaderUtil:shaderNormalById(self.m_titleLabel2,11)

	local lineSpr1=cc.Sprite:createWithSpriteFrameName("general_double_line.png")
	lineSpr1:setPosition(midPosX,90)
	lineSpr1:setScaleX(rightSize.width/300)
	self.m_rightInfoContainer:addChild(lineSpr1)

	-- local greenColor=_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_SPRINGGREEN)
	local properLabel=_G.Util:createLabel("称号属性",24)
	properLabel:setColor(COLOR_BROWN)
	properLabel:setPosition(midPosX,60)
	self.m_rightInfoContainer:addChild(properLabel)

	local attrArray=self:__getAttrArray(_subCnf.attr)
	local properLbArray={}
	for i=1,4 do
		local isLeft=i%2==1
		local tempX=isLeft and -150 or 60
		local tempY=i>2 and -30 or 10

		local szProper=""
		if attrArray[i] then
			szProper=string.format("%s + %d",attrArray[i].name,attrArray[i].value)
		end
		properLbArray[i]=_G.Util:createLabel(szProper,20)
		properLbArray[i]:setColor(COLOR_DARKORANGE)
		properLbArray[i]:setAnchorPoint(cc.p(0,0.5))
		properLbArray[i]:setPosition(midPosX+tempX,tempY)
		self.m_rightInfoContainer:addChild(properLbArray[i])
	end
	self.m_properLbArray=properLbArray

	local lineSpr1=cc.Sprite:createWithSpriteFrameName("general_double_line.png")
	lineSpr1:setPosition(midPosX,-70)
	lineSpr1:setScaleX(rightSize.width/300)
	self.m_rightInfoContainer:addChild(lineSpr1)

	local condiLabel=_G.Util:createLabel("激活条件",24)
	condiLabel:setColor(COLOR_BROWN)
	condiLabel:setPosition(midPosX,-110)
	self.m_rightInfoContainer:addChild(condiLabel)

	if self.m_rightInfoContainer:getChildByTag(777) then
		self.m_rightInfoContainer:getChildByTag(777):removeFromParent()
	end

	local szTemp,sWidth=self:__formatString(_subCnf.describe,_subCnf.arg1,_subCnf.arg2,self.m_titleMsgArray[_subCnf.id].state)
	self.m_conditionLabel=_G.Util:createLabel("",20)
	self.m_conditionLabel:setColor(COLOR_BROWN)
	self.m_conditionLabel:setPosition(midPosX,-165)
	self.m_rightInfoContainer:addChild(self.m_conditionLabel)
	self.m_conditionLabel:setString("")
	local point = cc.p(self.m_conditionLabel:getPositionX()-sWidth/2,self.m_conditionLabel:getPositionY())
	szTemp:setPosition(point)
	self.m_rightInfoContainer:addChild(szTemp)

	local conSize=self.m_conditionLabel:getContentSize()
	self.m_condTimesLabel=_G.Util:createLabel("",20)
	self.m_condTimesLabel:setColor(COLOR_BROWN)
	--self.m_condTimesLabel:setAnchorPoint(cc.p(0,0.5))
	self.m_condTimesLabel:setPosition(midPosX,-185)
	self.m_rightInfoContainer:addChild(self.m_condTimesLabel)

	local function c(sender,eventType)
        if eventType==ccui.TouchEventType.ended then
        	local subTilteId=self.m_subCnf.id
        	local titleMsg=self.m_titleMsgArray[subTilteId]
        	local nState=titleMsg.state
        	local msg=REQ_TITLE_DRESS()
        	if self.newTid == subTilteId then
        		msg:setArgs(0)
        		self.newTid1 = 0
        	else
        		msg:setArgs(subTilteId)
        		self.newTid1 = subTilteId
        	end
        	_G.Network:send(msg)
        end
    end
    local tempBtn=gc.CButton:create("general_btn_gold.png")
    tempBtn:addTouchEventListener(c)
	tempBtn:setTitleFontSize(22)
	tempBtn:setTitleFontName(FONT_NAME)
	tempBtn:setPosition(midPosX,-245)
    self.m_rightInfoContainer:addChild(tempBtn)
    self.m_handleBtn=tempBtn

    -- local dressIcon=cc.Sprite:createWithSpriteFrameName("general_btn_gold.png")
    -- dressIcon:setPosition(cc.p(midPosX+170,-130))
    -- self.m_rightInfoContainer:addChild(dressIcon)
    -- dressIcon:setVisible(false)
    -- self.dressIcon=dressIcon

    local titleMsg=self.m_titleMsgArray[_subCnf.id]
    if not titleMsg then
    	self:resetHandleBtn()
    else
    	self:resetHandleBtn(titleMsg)

    	local szTimes,nColor=self:__getTimesInfo(titleMsg)
    	self.m_condTimesLabel:setString(szTimes)
    	self.m_condTimesLabel:setColor(nColor)

    	if titleMsg.state == 1 then
			self.m_condTimesLabel:setVisible(true)
		else
			--self.m_condTimesLabel:setVisible(false)
		end
    end
end

function TitleLayer.showStrengthOkEffect(self,texiaoId)
	if self.tempObj~=nil then
		self.tempObj:removeFromParent(true)
		self.tempObj=nil
	end
	local tempGafAsset=gaf.GAFAsset:create(string.format("gaf/ch_%d.gaf",texiaoId))
	self.tempObj=tempGafAsset:createObject()
	local nPos=cc.p(110,120)
	self.tempObj:setLooped(true,true)
	self.tempObj:start()
	self.tempObj:setPosition(nPos)
	self.m_rightInfoContainer : addChild(self.tempObj,1000)
end

function TitleLayer.resetHandleBtn(self,_msg)
	print("resetHandleBtn=======>>>>>>",_msg.state)
	local _state = _msg.state
	if self.m_handleBtn==nil then return end
	if not _state then
		self.m_handleBtn:setEnabled(false)
		self.m_handleBtn:setBright(false)
		self.m_handleBtn:setTitleText("无")
		-- self.dressIcon:setVisible(false)
    elseif _state==_G.Const.CONST_TITLE_STATA_1 then
    	-- 激活
    	self.m_handleBtn:setEnabled(true)
		self.m_handleBtn:setBright(true)
    	self.m_handleBtn:setTitleText("穿戴称号")
    	-- self.dressIcon:setVisible(false)
    	if self.m_titleMsgArray.tid ~= 0 and self.m_titleMsgArray.tid == _msg.tid then
    		self.m_handleBtn:setTitleText("卸下称号")
    		-- self.dressIcon:setVisible(true)
    	end
    elseif _state==_G.Const.CONST_TITLE_STATA_2 then
    	-- 使用中
    	self.m_handleBtn:setEnabled(false)
		self.m_handleBtn:setBright(false)
    	self.m_handleBtn:setTitleText("穿戴称号")
    	-- self.dressIcon:setVisible(false)
    elseif _state==_G.Const.CONST_TITLE_STATA_3 then
    	-- 不可激活
    	self.m_handleBtn:setEnabled(false)
		self.m_handleBtn:setBright(false)
    	self.m_handleBtn:setTitleText("无")
    	-- self.dressIcon:setVisible(false)
    end
end

local TYPE_ARRAY={
	hp=_G.Const.CONST_ATTR_HP,
	strong_att=_G.Const.CONST_ATTR_STRONG_ATT,
	strong_def=_G.Const.CONST_ATTR_STRONG_DEF,
	crit=_G.Const.CONST_ATTR_CRIT,
	crit_res=_G.Const.CONST_ATTR_RES_CRIT,
	defend_down=_G.Const.CONST_ATTR_DEFEND_DOWN,
	hit=_G.Const.CONST_ATTR_HIT,
	dod=_G.Const.CONST_ATTR_DODGE
}
function TitleLayer.__getAttrArray(self,_attr)
	local attrArray={}
	local attrCount=0
	for key,value in pairs(_attr) do
		if value>0 then
			local nType=TYPE_ARRAY[key]
			if nType~=nil then
				attrCount=attrCount+1
				attrArray[attrCount]={
					type=nType,
					name=_G.Lang.type_name[nType],
					value=value,
				}
			end
		end
	end
	return attrArray
end
function TitleLayer.__formatString(self,_str,_v1,_v2,state)
	local label = cc.Node:create()
	label:setTag(777)
	local length=0
	local tempSearch=string.find(_str,"#")
	if tempSearch~=nil then
		local sz1=string.sub(_str,0,tempSearch-1)
		local sz2=string.sub(_str,tempSearch+1,string.len(_str))
		local sz3=nil
		local tempSearch2=string.find(sz2,"#")
		if tempSearch2~=nil then
			sz3=string.sub(sz2,tempSearch2+1,string.len(sz2))
			sz2=string.sub(sz2,0,tempSearch2-1)
		end
		if sz3==nil then
			_str=string.format("%s%d%s",sz1,_v1,sz2)
			local width=0
			local height=10
			local lab1=_G.Util:createLabel(sz1,20)
			lab1:setColor(COLOR_DARKORANGE)
			lab1:setAnchorPoint(cc.p(0,0.5))
			lab1:setPosition(cc.p(width,height))
			label:addChild(lab1)
			width=width+lab1:getContentSize().width

			local lab2=_G.Util:createLabel(tostring(_v1),20)
			if state==1 then
				lab2:setColor(COLOR_DARKORANGE)
			else
				lab2:setColor(COLOR_RED)
			end
			lab2:setAnchorPoint(cc.p(0,0.5))
			lab2:setPosition(cc.p(width,height))
			label:addChild(lab2)
			width=width+lab2:getContentSize().width

			local lab3=_G.Util:createLabel(sz2,20)
			lab3:setColor(COLOR_DARKORANGE)
			lab3:setAnchorPoint(cc.p(0,0.5))
			lab3:setPosition(cc.p(width,height))
			label:addChild(lab3)
			width=width+lab3:getContentSize().width
			length=width
		else
			_str=string.format("%s%d%s%d%s",sz1,_v1,sz2,_v2,sz3)
			local width=0
			local height=10
			local lab1=_G.Util:createLabel(sz1,20)
			lab1:setColor(COLOR_DARKORANGE)
			lab1:setAnchorPoint(cc.p(0,0.5))
			lab1:setPosition(cc.p(width,height))
			label:addChild(lab1)
			width=width+lab1:getContentSize().width

			local lab2=_G.Util:createLabel(tostring(_v1),20)
			if state==1 then
				lab2:setColor(COLOR_DARKORANGE)
			else
				lab2:setColor(COLOR_RED)
			end
			lab2:setAnchorPoint(cc.p(0,0.5))
			lab2:setPosition(cc.p(width,height))
			label:addChild(lab2)
			width=width+lab2:getContentSize().width

			local lab3=_G.Util:createLabel(sz2,20)
			lab3:setColor(COLOR_DARKORANGE)
			lab3:setAnchorPoint(cc.p(0,0.5))
			lab3:setPosition(cc.p(width,height))
			label:addChild(lab3)
			width=width+lab3:getContentSize().width

			local lab4=_G.Util:createLabel(tostring(_v2),20)
			if state==1 then
				lab4:setColor(COLOR_DARKORANGE)
			else
				lab4:setColor(COLOR_RED)
			end
			lab4:setAnchorPoint(cc.p(0,0.5))
			lab4:setPosition(cc.p(width,height))
			label:addChild(lab4)
			width=width+lab4:getContentSize().width

			local lab5=_G.Util:createLabel(sz3,20)
			lab5:setColor(COLOR_DARKORANGE)
			lab5:setAnchorPoint(cc.p(0,0.5))
			lab5:setPosition(cc.p(width,height))
			label:addChild(lab5)
			width=width+lab5:getContentSize().width
			length=width
		end
	else
		local lab1=_G.Util:createLabel(_str,20)
		if state==1 then
			lab1:setColor(COLOR_DARKORANGE)
		else
			lab1:setColor(COLOR_RED)
		end
		lab1:setAnchorPoint(cc.p(0,0.5))
		lab1:setPosition(cc.p(width,10))
		label:addChild(lab1)
		length=lab1:getContentSize().width
	end
	return label,length
	--return _str
end

function TitleLayer.updateTitleMsgOne(self,_oneMsg)
	if self.m_titleMsgArray==nil then return end
	self.m_titleMsgArray[_oneMsg.tid]=_oneMsg
	self:__updateCanActivateSpr()

	if self.m_subCnf~=nil and self.m_subCnf.id==_oneMsg.tid then
		local preSubCnf=self.m_subCnf
		self.m_subCnf=nil
		self:__showTitleInfo(preSubCnf)
	end
end
function TitleLayer.updateTitleMsgArray(self,_array)
	print("_array::::::::::",_array)
	self.m_titleMsgArray=_array
	self:__updateCanActivateSpr()
end
function TitleLayer.__updateCanActivateSpr(self)
	if not self.m_titleMsgArray then return end
	print("=================刷新================")
	for i=1,#self.m_tolCnfArray do
		local isCanActivate=false
		for j=1,#self.m_subCnfArray[i] do
			local subTilteId=self.m_subCnfArray[i][j].id
			local subTitleMsg=self.m_titleMsgArray[subTilteId] or {}
			if subTitleMsg and subTitleMsg.state==_G.Const.CONST_TITLE_STATA_0 then
				isCanActivate=true
				break
			end
		end
		local tolBtn=self.m_tolBtnArray[i]
		self:__resetBtnActivateSpr(tolBtn,isCanActivate)
	end

	if self.m_selectTolPos==nil then return end
	local curSubCnfArray=self.m_subCnfArray[self.m_selectTolPos]
	for i=1,#curSubCnfArray do
		local subTilteId=curSubCnfArray[i].id
		local subTitleMsg=self.m_titleMsgArray[subTilteId] or {}
		local subBtn=self.m_subBtnArray[i]
		if subTitleMsg and subTitleMsg.state==_G.Const.CONST_TITLE_STATA_0 then 
			self:__resetBtnActivateSpr(subBtn,true)
		else
			self:__resetBtnActivateSpr(subBtn,false)
		end
	end
end
function TitleLayer.__resetBtnActivateSpr(self,_btn,_isShow)
	if not _btn then return end

	local tempSpr=_btn:getChildByTag(555)
	if _isShow then
		if tempSpr==nil then
			local btnSize=_btn:getContentSize()
			local tempSpr=cc.Sprite:createWithSpriteFrameName("general_report_tips1.png")
			tempSpr:setPosition(btnSize.width-25,btnSize.height*0.5)
			tempSpr:setScale(0.5)
			tempSpr:setTag(555)
			_btn:addChild(tempSpr,10)
		end
	elseif tempSpr~=nil then
		tempSpr:removeFromParent(true)
	end
end

function TitleLayer.__addTimesSchedule(self)
	local function nUpdate()
		if self.m_condTimesLabel==nil then return end
		local szTimes=self:__getTimesStr()
		if szTimes~=nil then
			self.m_condTimesLabel:setString(szTimes)
		end
	end
	self.m_updateTimesSchedule=_G.Scheduler:schedule(nUpdate,1)
end
function TitleLayer.__removeTimesSchedule(self)
	if self.m_updateTimesSchedule~=nil then
		_G.Scheduler:unschedule(self.m_updateTimesSchedule)
		self.m_updateTimesSchedule=nil
	end
end
function TitleLayer.__getTimesStr(self)
	if self.m_useEndTimes==nil then return end
	local curTimes=_G.TimeUtil:getNowSeconds()
	local subTimes=self.m_useEndTimes-curTimes
	if subTimes<=0 then
		self.m_useEndTimes=nil
	end
	local hour   =math.floor(subTimes/3600)
    local min    =math.floor(subTimes%3600/60)
    local second =subTimes%60
    local timeStr=string.format("%.2d",hour)..":"..string.format("%.2d",min)..":"..string.format("%.2d",second)
    return timeStr
end
function TitleLayer.__getTimesInfo(self,_titleMsg)
	local szTimes,nColor
	if _titleMsg.type==_G.Const.CONST_TITLE_REPLACE_1 then
		-- 永久
		if _titleMsg.state==_G.Const.CONST_TITLE_STATA_1 or 
			_titleMsg.state==_G.Const.CONST_TITLE_STATA_2 then
			szTimes=self.m_subCnf.shuoming
			nColor=_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_GREEN)
		else
    		szTimes=string.format("(%d/%d)",_titleMsg.times,_titleMsg.times_max)
    		nColor=COLOR_DARKORANGE
    	end
	elseif _titleMsg.type==_G.Const.CONST_TITLE_REPLACE_2 then
		-- 限时
    	if _titleMsg.state==_G.Const.CONST_TITLE_STATA_1 then
    		self.m_useEndTimes=_titleMsg.end_time
    		szTimes=self:__getTimesStr()
    		nColor=COLOR_DARKORANGE
		else
			--szTimes=string.format("(%d/%d)",_titleMsg.times,_titleMsg.times_max)
    		--nColor=COLOR_RED
    		szTimes=self.m_subCnf.shuoming
			nColor=_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_GREEN)
    	end
    elseif _titleMsg.type==_G.Const.CONST_TITLE_REPLACE_3 then
    	-- 实时
    	if _titleMsg.state==_G.Const.CONST_TITLE_STATA_1 or 
			_titleMsg.state==_G.Const.CONST_TITLE_STATA_2 then
			szTimes=self.m_subCnf.shuoming
			nColor=_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_GREEN)
		else
    		szTimes=string.format("(%d/%d)",_titleMsg.times,_titleMsg.times_max)
    		nColor=COLOR_DARKORANGE
    	end
    else
    	szTimes=""
    	nColor=COLOR_DARKORANGE
	end
	return szTimes,nColor
end

function TitleLayer.updateTitle( self )
	print("修改称号状态！！！！！！！！！！！")
	self.oldTid = self.newTid
	self.newTid = self.newTid1
	self.newTid1= nil
	print("old:",self.oldTid)
	print("new:",self.newTid)
	if self.m_subCnf.id == self.oldTid then
		self.m_handleBtn:setTitleText("穿戴称号")
		-- self.dressIcon:setVisible(false)
	else
		if self.m_subCnf.id == self.newTid then
			self.m_handleBtn:setTitleText("卸下称号")
			-- self.dressIcon:setVisible(true)
		end
	end
	_G.Util:playAudioEffect("ui_title")
	self.m_titleMsgArray.tid = self.newTid
end

function TitleLayer.updateFlag( self )
	local count = 0
	local tempBtn=self.m_tolBtnArray[self.m_selectTolPos]
	tempBtn:getChildByTag(DINS_TAG):removeFromParent()
    for k,v in pairs(self.m_subCnfArray[self.m_selectTolPos]) do
    	print(self.m_titleMsgArray[v.id].new)
    	count = count + self.m_titleMsgArray[v.id].new
    end
    
    if count >0 then
    	local dins=cc.Sprite:createWithSpriteFrameName("general_redpoint.png")
    	dins:setPosition(cc.p(btnSize.width-15,btnSize.height-10))
    	tempBtn:addChild(dins)
    	-- local newCount=_G.Util:createLabel(tostring(count),18)
    	-- newCount:setPosition(cc.p(btnSize.width-20,btnSize.height*0.5-3))
    	-- tempBtn:addChild(newCount,1)
    end
end

return TitleLayer