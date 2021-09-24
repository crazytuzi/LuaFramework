local ArtifactView   = classGc(view,function ( self,_pagID,_uid)
	self.m_winSize   = cc.Director : getInstance() : getVisibleSize()
	self.m_curUid    = 0
	self.pagID       = _pagID or 1
	self.uid         = _uid
end)

local TAGBTN_ARTIFACT    = 1
local TAGBTN_INTENSIFY   = 2
local TAGBTN_ADVANCED    = 3
local TAGBTN_CHANGE      = 4
-- local TAGBTN_SHOP        = 5
local P_ARTIFACT_BTN_INTERVAL=230
local P_ARTIFACT_BTN_SMALLSCALE=0.85
local P_ARTIFACT_BTN_BIGSCALE=1
local P_ARTIFACT_BTN_SCALESPEED=(P_ARTIFACT_BTN_BIGSCALE-P_ARTIFACT_BTN_SMALLSCALE)/P_ARTIFACT_BTN_INTERVAL

function ArtifactView.create(self)
    self : __init()
    self.m_normalView = require("mod.general.NormalView")()
	self.m_rootLayer  = self.m_normalView:create("神兵")

	local tempScene=cc.Scene:create()
    tempScene:addChild(self.m_rootLayer)

	self  			  : __initView()
	
    return tempScene
end

function ArtifactView.__init(self)
    self : register()
end

function ArtifactView.__initView( self )
	local function nCloseFun()
		print("成功删除背景")
		self : __closeWindow()
	end
	self.m_normalView : addCloseFun(nCloseFun)

	self.artifactbg   = cc.Sprite:create("ui/bg/artifact_bg.jpg")
	self.artifactbg   : setPosition(self.m_winSize.width/2,self.m_winSize.height/2-40)
	self.m_rootLayer : addChild(self.artifactbg)

	self.bgSize=self.artifactbg:getContentSize()

	local function local_btncallback(sender,eventType)
		if eventType==ccui.TouchEventType.ended then
			print("兑换界面")
			_G.GLayerManager:delayOpenLayer(_G.Const.CONST_FUNC_OPEN_SHOP,nil,_G.Const.CONST_MALL_TYPE_SUB_MAGICS)
		end
	end
	local exchangebtn  = gc.CButton:create("ui_artifact_btnbg.png") 
    exchangebtn  : setTitleFontName(_G.FontName.Heiti)
    exchangebtn  : setTitleText("兑 换")
    exchangebtn  : addTouchEventListener(local_btncallback)
    exchangebtn  : setTitleFontSize(20)
    exchangebtn  : setPosition(55,self.bgSize.height-50)
    self.artifactbg   : addChild(exchangebtn)

    local tipsLab = _G.Util : createLabel("总属性加成：",20)
	-- tipsLab   : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_YELLOWISH))
	tipsLab   : setPosition(cc.p(105,60))
	self.artifactbg   : addChild(tipsLab)

	self.attrLab = {}
	local posX = 170
	local posY = 95 
	for i=1,8 do
		if i%4==1 then
			posX = 170
			posY = posY-35
		else
			posX = posX+160
		end
		self.attrLab[i] = _G.Util : createLabel("",20)
		self.attrLab[i] : setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
		self.attrLab[i] : setAnchorPoint(cc.p(0,0.5)) 
		self.attrLab[i] : setPosition(cc.p(posX,posY))
		self.artifactbg : addChild(self.attrLab[i])
	end

	local selectSpr = cc.Sprite:createWithSpriteFrameName("ui_artifact_select.png")
	selectSpr   : setPosition(self.bgSize.width/2,self.bgSize.height/2-5)
	self.artifactbg : addChild(selectSpr)

	local msg = REQ_MAGIC_EQUIP_REQUEST()
    _G.Network: send(msg)
end

function ArtifactView.updateAttrView(self,_data)
	self.nowIdx=_data.idx_use
	local btnSize=cc.size(160,280)
	local m_equipList  = _G.GPropertyProxy:getOneByUid(0,_G.Const.CONST_PLAYER):getArtifactEquipList()  --装备数据
	if self.m_ArtifactScrollView then 
	    self.m_ArtifactequipList={}
	    self.isTrue={}
	    local attrNum={_data.attr.att,_data.attr.hp,_data.attr.wreck,_data.attr.def,
	          _data.attr.hit,_data.attr.dod,_data.attr.crit,_data.attr.crit_res}
	    local attrName={ "攻击", "气血", "破甲", "防御", "命中", "闪避", "暴击", "抗暴", }
	    for i=1,8 do
	    	local magicData=_G.Cfg.magic_des[i+50]
	    	
	    	local Color=_G.Const.CONST_COLOR_WHITE
		    local szName=string.format("%s 未激活",magicData.name)
		    local goodNums = _G.GBagProxy:getGoodsCountById(magicData.id)
		    if goodNums>0 then
		    	szName=string.format("%s 可激活",magicData.name)
		    	Color=_G.Cfg.goods[magicData.id].name_color
		    end
		    
		    for k,v in pairs(_data.msg) do
	    		print(k,v.id,v.idx,v.type)
	    		if v.type==magicData.type then
	    			self.m_ArtifacttempBg[i]:setVisible(false)
	    			self.m_ArtifacttempGaf[i]:setVisible(true)
	    			szName=magicData.name
	    			self.isTrue[v.type]=true
	    			Color=_G.Cfg.goods[v.id].name_color
	    			for kk,vv in pairs(m_equipList) do
				    	if vv.index == v.type then
				    		szName=string.format("%s+%d",magicData.name,vv.strengthen)
				    		if vv.strengthen==0 then
				    			szName=magicData.name
				    		end
				    		self.m_ArtifactequipList[v.type]=vv
				    	end
				    end
	    		end
	    	end
	    	print("magicData.id",magicData.id,_data.idx_use)
	    	if magicData.type==_data.idx_use then
		    	szName=string.format("%s 使用中",szName)
		    end
	    	self.ArtifactNameLabel[i]:setString(szName)
		    self.ArtifactNameLabel[i]:setColor(_G.ColorUtil:getRGB(Color))

	    	self.attrLab[i]:setString(string.format("%s+%d",attrName[i],attrNum[i]))
	    end
	    return
	end

	local viewSize=cc.size(self.bgSize.width,400)
	P_ARTIFACT_BTN_INTERVAL=viewSize.width/3
	P_ARTIFACT_BTN_SCALESPEED=(P_ARTIFACT_BTN_BIGSCALE-P_ARTIFACT_BTN_SMALLSCALE)/P_ARTIFACT_BTN_INTERVAL

	self.m_ArtifactScrollView=cc.ScrollView:create()
    self.m_ArtifactScrollView:setPosition(0,60)
    self.m_ArtifactScrollView:setDirection(cc.SCROLLVIEW_DIRECTION_HORIZONTAL)
    self.m_ArtifactScrollView:setViewSize(viewSize)
    self.m_ArtifactScrollView:setBounceable(false)
    self.m_ArtifactScrollView:setTouchEnabled(true)
    self.m_ArtifactScrollView:setDelegate()
    self.artifactbg:addChild(self.m_ArtifactScrollView)

    local touchOff=nil
    local function c(sender,eventType)
    	if eventType==ccui.TouchEventType.began then
			touchOff=self.m_ArtifactScrollView:getContentOffset()
			return true
    	elseif eventType==ccui.TouchEventType.ended then
    		local offsetPos=self.m_ArtifactScrollView:getContentOffset()
    		local subOffX=math.abs(offsetPos.x-touchOff.x)
    		if subOffX>10 then return end

    		_G.Util:playAudioEffect("ui_sys_click")

    		local idx=sender:getTag()
    		print("sender:getTag()",self.m_ArtifactIdx,sender:getTag())
    		if self.m_ArtifactIdx~=idx then
    			print("进入111111")
    			self:adjustArtifactBtnPos(idx-50)
    			return
    		end

    		if subOffX>0 then
    			print("进入222222")
    			self:adjustArtifactBtnPos(self.m_ArtifactIdx-50,true)
    		end

    		self:__requestArtifactData(idx)
    		-- self:showCopyArrayEffect(idx)
    	end
    end
    self.m_ArtifactButtonArray={}
    self.m_ArtifactequipList={}
    self.ArtifactNameLabel={}
    self.m_ArtifacttempBg={}
    self.m_ArtifacttempGaf={}
    self.isTrue={}
    local attrNum={_data.attr.att,_data.attr.hp,_data.attr.wreck,_data.attr.def,
          _data.attr.hit,_data.attr.dod,_data.attr.crit,_data.attr.crit_res}
    local attrName={ "攻击", "气血", "破甲", "防御", "命中", "闪避", "暴击", "抗暴", }
    for i=1,8 do
    	local magicData=_G.Cfg.magic_des[i+50]
    	local tempBtn=ccui.Widget:create()
		tempBtn:setContentSize(btnSize)
		tempBtn:setPosition((i+0.5)*P_ARTIFACT_BTN_INTERVAL,viewSize.height*0.5)
		tempBtn:addTouchEventListener(c)
		tempBtn:setTouchEnabled(true)
	    tempBtn:setSwallowTouches(false)
		tempBtn:setScale(P_ARTIFACT_BTN_SMALLSCALE)
		tempBtn:setTag(50+i)
		tempBtn:enableSound()
		self.m_ArtifactScrollView:addChild(tempBtn)

    	local tempBg=gc.GraySprite:createWithSpriteFrameName(string.format("ui_artifact_%d.png",magicData.type))
    	tempBg:setPosition(btnSize.width*0.5,btnSize.height*0.5)
    	tempBg:setTag(1688)
    	tempBg:setGray()
    	tempBtn:addChild(tempBg,-10)
    	
    	local tempGafAsset=gaf.GAFAsset:create(string.format("gaf/sq_%d.gaf",_G.Cfg.magic_des[i+50].id))
		local ArtifactGaf = tempGafAsset:createObject()
		ArtifactGaf : setLooped(true,true)
		ArtifactGaf : start()
		ArtifactGaf : setPosition(btnSize.width*0.5,btnSize.height*0.5)
		ArtifactGaf : setVisible(false)
		tempBtn : addChild(ArtifactGaf,1000)

    	local Color=_G.Const.CONST_COLOR_WHITE
	    local szName=string.format("%s 未激活",magicData.name)
	    local goodNums = _G.GBagProxy:getGoodsCountById(magicData.id)
	    if goodNums>0 then
	    	szName=string.format("%s 可激活",magicData.name)
	    	Color=_G.Cfg.goods[magicData.id].name_color
	    end

	    for k,v in pairs(_data.msg) do
    		print(k,v.id,v.idx,v.type)
    		if v.type==magicData.type then
    			tempBg:setVisible(false)
    			ArtifactGaf : setVisible(true)

    			szName=magicData.name
    			self.isTrue[v.type]=true
    			Color=_G.Cfg.goods[v.id].name_color
    			for kk,vv in pairs(m_equipList) do
			    	if vv.index == v.type then
			    		szName=string.format("%s+%d",magicData.name,vv.strengthen)
			    		if vv.strengthen==0 then
			    			szName=magicData.name
			    		end
			    		self.m_ArtifactequipList[v.type]=vv
			    	end
			    end
    		end
    	end
    	if magicData.type==_data.idx_use then
	    	szName=string.format("%s 使用中",szName)
	    end
    	self.ArtifactNameLabel[i]=_G.Util:createLabel(szName,24)
	    self.ArtifactNameLabel[i]:setColor(_G.ColorUtil:getRGB(Color))
	    -- self.ArtifactNameLabel[i]:setAnchorPoint(cc.p(0,1))
	    self.ArtifactNameLabel[i]:setPosition(btnSize.width/2,btnSize.height-25)
	    tempBtn:addChild(self.ArtifactNameLabel[i])

    	self.attrLab[i]:setString(string.format("%s+%d",attrName[i],attrNum[i]))
	    self.m_ArtifactButtonArray[i]=tempBtn
	    self.m_ArtifacttempBg[i]=tempBg
	    self.m_ArtifacttempGaf[i]=ArtifactGaf
    end

    -- local addNum=self.m_ArtifactTotalArray[#self.m_ArtifactTotalArray].isNoOpen and 1 or 2
    local contentWidth=10*P_ARTIFACT_BTN_INTERVAL
    -- if contentWidth<viewSize.width then
    -- 	contentWidth=viewSize.width
    -- end
    self.m_ArtifactScrollView:setContentSize(cc.size(contentWidth,viewSize.height))
    self.m_ArtifactScrollView:setContentOffset(cc.p(0,0))
    if self.nowIdx>0 then
    	self.m_ArtifactScrollView:setContentOffset(cc.p(-(self.nowIdx-50+0.5)*P_ARTIFACT_BTN_INTERVAL+self.bgSize.width*0.5,0))
    end

    local function onTouchBegan()
    	return true
    end
    local function onTouchEnded()
    	if self.m_ArtifactScrollView:isTouchEnabled() then
    		self:adjustArtifactBtnPos()
    	end
    end
    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    listerner:setSwallowTouches(false)

    local tempContainer=self.m_ArtifactScrollView:getContainer()
    tempContainer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,tempContainer)

    local function nFun1()
    	self:adjustArtifactBtnScale()
	end

    self.m_ArtifactScrollView:registerScriptHandler(nFun1,cc.SCROLLVIEW_SCRIPT_SCROLL)
    
    self.m_ArtifactIdx=_data.idx_use~=0 and _data.idx_use or 51
    self:adjustArtifactBtnScale()
end

function ArtifactView.adjustArtifactBtnScale(self)
	local offsetPos=self.m_ArtifactScrollView:getContentOffset()
	local midPosX=-offsetPos.x+self.bgSize.width*0.5

	if self.m_prePosX==midPosX then return end

	self.m_prePosX=midPosX

	for i=1,#self.m_ArtifactButtonArray do
		local tX=(i+0.5)*P_ARTIFACT_BTN_INTERVAL
		local subX=midPosX-tX
		local tempScale=math.abs(subX)*P_ARTIFACT_BTN_SCALESPEED
		local tempBtn=self.m_ArtifactButtonArray[i]
		if tempScale>P_ARTIFACT_BTN_BIGSCALE then
			tempBtn:setVisible(false)
		else
			tempScale=P_ARTIFACT_BTN_BIGSCALE-tempScale
			tempBtn:setVisible(true)
			tempBtn:setScale(tempScale)

			-- local tempSize=tempBtn:getContentSize()
			-- local tempX=tempBtn:getPositionX()
			-- local isVis=true
			-- if (tempX+tempSize.width*0.5*tempScale+offsetPos.x)<0 then
			-- 	isVis=false
			-- elseif (tempX-tempSize.width*0.5*tempScale+offsetPos.x)>self.bgSize.width then
			-- 	isVis=false
			-- end
		end
	end
end
function ArtifactView.adjustArtifactBtnPos(self,_adjustArtifactIdx,_isNoAction)
	local offsetPos=self.m_ArtifactScrollView:getContentOffset()
	local midPosX=-offsetPos.x+self.bgSize.width*0.5
	local ArtifactIdx=_adjustArtifactIdx
	print("_adjustArtifactIdx",_adjustArtifactIdx)
	if not ArtifactIdx then
		local minWid=100000
		for i=1,#self.m_ArtifactButtonArray do
			local tX=(i+0.5)*P_ARTIFACT_BTN_INTERVAL
			local subX=math.abs(tX-midPosX)
			if subX<minWid then
				ArtifactIdx=i
				minWid=subX
			end
		end
	end

	print("adjustArtifactBtnPos",ArtifactIdx)
	self.m_ArtifactIdx=50+ArtifactIdx
	local moveOffX=-((ArtifactIdx+0.5)*P_ARTIFACT_BTN_INTERVAL-self.bgSize.width*0.5)
	if _isNoAction then
		self.m_ArtifactScrollView:setContentOffset(cc.p(moveOffX,0))
		self:adjustArtifactBtnScale()
		return
	end

	local moveTime=math.abs(moveOffX-offsetPos.x)/1500
	local function nFun()
		self.m_ArtifactScrollView:setTouchEnabled(true)
		self:adjustArtifactBtnScale()
		self:removeArtifactScrollViewSchudler()
	end
	self.m_ArtifactScrollView:setTouchEnabled(false)
	self.m_ArtifactScrollView:getContainer():stopAllActions()
	self.m_ArtifactScrollView:getContainer():runAction(cc.Sequence:create(cc.MoveTo:create(moveTime,cc.p(moveOffX,0)),cc.CallFunc:create(nFun)))
	self:addArtifactScrollViewSchudler()
end
function ArtifactView.addArtifactScrollViewSchudler(self)
	if self.m_ArtifactScoSchedule then return end

	local function nFun()
		self:adjustArtifactBtnScale()
	end
	self.m_ArtifactScoSchedule=_G.Scheduler:schedule(nFun,0.1)
end
function ArtifactView.removeArtifactScrollViewSchudler(self)
	if self.m_ArtifactScoSchedule then
		_G.Scheduler:unschedule(self.m_ArtifactScoSchedule)
		self.m_ArtifactScoSchedule=nil
	end
end
-- function ArtifactView.resetArtifactHightLine(self)
	-- for i=1,#self.m_ArtifactButtonArray do
	-- 	local tempBtn=self.m_ArtifactButtonArray[i]
	-- 	local bgSpr=tempBtn:getChildByTag(1688)
	-- 	if bgSpr then
	-- 		if i==self.m_ArtifactIdx then
	-- 			bgSpr:setScale(P_ARTIFACT_BTN_BIGSCALE)
	-- 		else
	-- 			bgSpr:setScale(P_ARTIFACT_BTN_SMALLSCALE)
	-- 		end
	-- 	end
	-- end
-- end

function ArtifactView.updatePower(self)
	local m_equipList  = _G.GPropertyProxy:getOneByUid(0,_G.Const.CONST_PLAYER):getArtifactEquipList()  --装备数据
	for kk,vv in pairs(m_equipList) do
    	if vv.index == self.m_ArtifactIdx then
    		local id   = vv.goods_id
	    	local nameColor  = _G.Cfg.goods[id].name_color
	    	local name = _G.Cfg.magic_des[self.m_ArtifactIdx].name
			local Str  = string.format("%s + %d",name,vv.strengthen)
			if vv.strengthen==0 then
				Str=name
			end
			print("1231456456",id,name,vv.strengthen)
			self.nameLab:setString(Str)
			self.nameLab:setColor(_G.ColorUtil:getRGB(nameColor))
    	end
    end
end

function ArtifactView.showStrengthOkEffect(self,_idx)
	if self.tempObj~=nil then
		self.tempObj:removeFromParent(true)
		self.tempObj=nil
	end
	local tempGafAsset=gaf.GAFAsset:create(string.format("gaf/sq_%d.gaf",_G.Cfg.magic_des[_idx].id))
	self.tempObj = tempGafAsset:createObject()
	local nPos = cc.p(115,230)
	self.tempObj : setLooped(true,true)
	self.tempObj : start()
	self.tempObj : setPosition(nPos)
	self.viewbgSpr : addChild(self.tempObj,1000)
end

function ArtifactView.__requestArtifactData(self,_idx)
	print("选中神器",_idx)
	local frame = string.format("ui_artifact_%d.png",_idx)
	local Str   = _G.Cfg.magic_des[_idx].name
	local NameColor =_G.Const.CONST_COLOR_WHITE
	if self.m_ArtifactequipList[_idx]~=nil then
		local id   = self.m_ArtifactequipList[_idx].goods_id
    	NameColor = _G.Cfg.goods[id].name_color
		Str=string.format("%s + %d",Str,self.m_ArtifactequipList[_idx].strengthen)
		if self.m_ArtifactequipList[_idx].strengthen==0 then
			Str=_G.Cfg.magic_des[_idx].name
		end
	end
	if self.m_viewLayer~=nil then
		self.m_viewLayer:setVisible(true)
		self.listerner:setSwallowTouches(true)
		self.nameLab:setString(Str)
		self.nameLab:setColor(_G.ColorUtil:getRGB(NameColor))
		if not self.isTrue[self.m_ArtifactIdx] then
			self.artifactSpr:setVisible(true) 
	    	self.tempObj:setVisible(false)
	    	self.artifactSpr : setSpriteFrame(frame)
	    else
	    	self.tempObj:setVisible(true)
	    	self.artifactSpr:setVisible(false)
			self:showStrengthOkEffect(_idx)
		end
		self:initTagPanel(1)
		return
	end
	local function onTouchBegan(touch,event) 
        return true
    end
	self.listerner=cc.EventListenerTouchOneByOne:create()
    self.listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    self.listerner:setSwallowTouches(true)

    self.m_viewLayer=cc.LayerColor:create(cc.c4b(0,0,0,150))
    self.m_viewLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.listerner,self.m_viewLayer)
	cc.Director:getInstance():getRunningScene():addChild(self.m_viewLayer,1000)

	self.viewbgSpr=cc.Sprite:create("ui/bg/artifact_viewbg.jpg")
	self.viewbgSpr:setPosition(self.m_winSize.width/2,self.m_winSize.height/2)
	self.m_viewLayer:addChild(self.viewbgSpr)

	local viewSize=self.viewbgSpr:getContentSize()
	local function closefun(sender,eventType)
		if eventType==ccui.TouchEventType.ended then
			print("closeView")
			self.m_viewLayer:setVisible(false)
			self.listerner:setSwallowTouches(false)
			-- self:allunregister()
			local msg = REQ_MAGIC_EQUIP_REQUEST()
    		_G.Network: send(msg)
		end
	end
	local closeBtn = gc.CButton:create("ui_artifact_close.png") 
    closeBtn  : addTouchEventListener(closefun)
    closeBtn  : setPosition(viewSize.width-15,viewSize.height-15)
    self.viewbgSpr : addChild(closeBtn)

	self.artifactSpr = cc.Sprite:createWithSpriteFrameName(frame)
	self.artifactSpr : setPosition(115,viewSize.height/2)
	self.viewbgSpr  : addChild(self.artifactSpr)

	self:showStrengthOkEffect(_idx)
	if not self.isTrue[self.m_ArtifactIdx] then
		self.artifactSpr:setVisible(true) 
    	self.tempObj:setVisible(false)
    else
    	self.tempObj:setVisible(true)
    	self.artifactSpr:setVisible(false)
	end

	local namebgSpr=cc.Sprite:createWithSpriteFrameName("ui_artifact_namebg.png")
	namebgSpr : setPosition(35,viewSize.height-90)
	self.viewbgSpr  : addChild(namebgSpr)

	self.nameLab=_G.Util:createLabel(Str,24)
    self.nameLab:setDimensions(25,150)
    self.nameLab:setAnchorPoint(cc.p(0,1))
    self.nameLab:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    self.nameLab:setPosition(8,158)
    self.nameLab:setColor(_G.ColorUtil:getRGB(NameColor))
    namebgSpr:addChild(self.nameLab)

    local function local_btncallback(sender,eventType)
		if eventType==ccui.TouchEventType.ended then
			local btnTag=sender:getTag()
			print("切换界面",self.isTrue[self.m_ArtifactIdx],btnTag)
			if not self.isTrue[self.m_ArtifactIdx] and btnTag~=1 then
				local command = CErrorBoxCommand("该神器未激活")
		   	    controller : sendCommand( command )
				return
			end
			self:initTagPanel(btnTag)
		end
	end
	self.m_btn={}
	local btnStr={"属 性","强 化","升 阶","洗 练"}
	local positionX={viewSize.width-120,viewSize.width-70,viewSize.width-70,viewSize.width-120}
	local positionY={viewSize.height-70,viewSize.height/2+60,viewSize.height/2-60,70}
    for i=1,4 do
		self.m_btn[i] = gc.CButton:create("ui_artifact_btnbg.png") 
	    self.m_btn[i] : setTitleFontName(_G.FontName.Heiti)
	    self.m_btn[i] : setTitleText(btnStr[i])
	    self.m_btn[i] : addTouchEventListener(local_btncallback)
	    self.m_btn[i] : setTitleFontSize(20)
	    self.m_btn[i] : setPosition(positionX[i],positionY[i])
	    self.m_btn[i] : setTag(i)
	    self.viewbgSpr : addChild(self.m_btn[i])
    end
    --4个容器4个页面
	self.m_tagcontainer = {}
  	self.m_tagPanel     = {}
  	self.m_tagPanelClass= {}   

	for i=1,4 do
		self.m_tagcontainer[i] = cc.Node:create()
		self.m_tagcontainer[i] : setPosition(viewSize.width/2,viewSize.height/2)
    	self.viewbgSpr   : addChild(self.m_tagcontainer[i])
	end
	self:initTagPanel(1)

	--飘属性
	local attrFryNode=_G.Util:getLogsView():createAttrLogsNode()
	attrFryNode:setPosition(viewSize.width/2+30,viewSize.height/2+20)
	self.viewbgSpr:addChild(attrFryNode,20)
end

function ArtifactView.updateBtnBack(self)
	self.isTrue[self.m_ArtifactIdx]=true
	self:showStrengthOkEffect(self.m_ArtifactIdx)
	self.artifactSpr:setVisible(false)
	self.tempObj:setVisible(true)
end

function ArtifactView.initTagPanel(self,_tag)
	for i=1,4 do
		if i==_tag then
			self.m_btn[i]:setBright(true)
		else
			self.m_btn[i]:setBright(false)
		end
	end

	for k,v in pairs(self.m_tagPanel) do
		if k==_tag then
			self.m_tagcontainer[k] : setVisible(true)
		else
			self.m_tagcontainer[k] : setVisible(false)
		end
	end
	
	if self.m_tagPanel[_tag] == nil then
		--在这里创建自己面板的的东西
		local view=nil
		if _tag == TAGBTN_ARTIFACT then
			print("创建神兵面板")
			view = require "mod.artifact.ArtifactLayer"(self.uid)
			print("创建神兵面板结束")
		elseif _tag == TAGBTN_INTENSIFY then
			print("创建强化面板")
			view = require "mod.artifact.IntensifyLayer"(self.m_curUid)
			print("创建强化面板结束")
		elseif _tag == TAGBTN_ADVANCED then
			print("创建进阶面板")
			view = require "mod.artifact.AdvancedLayer"(self.m_curUid)
			print("创建进阶面板结束")
		elseif _tag == TAGBTN_CHANGE then
			print("创建洗练面板")
			view = require "mod.artifact.ChangeLayer"(self.m_curUid)
			print("创建洗练面板结束")
		-- elseif _tag == TAGBTN_SHOP then
		-- 	print("创建商城面板")
		-- 	view = require "mod.artifact.ShopLayer"()
		-- 	print("创建商城面板结束")
		end
		if view == nil then return end
		self.m_tagPanelClass[_tag] = view
    	self.m_tagPanel[_tag]      = view:create(self.m_ArtifactIdx,self.isTrue[self.m_ArtifactIdx])

    	self.m_tagcontainer[_tag]:addChild(self.m_tagPanel[_tag])
    else
    	self.m_tagPanelClass[_tag]:updataIndex(self.m_ArtifactIdx,self.isTrue[self.m_ArtifactIdx])
	end
end

function ArtifactView.updateCurUid(self,newUid)
	self.m_curUid = newUid
end

function ArtifactView.register(self)
    self.pMediator = require("mod.artifact.ArtifactViewMediator")(self)
end

function ArtifactView.unregister(self)
    self.pMediator : destroy()
    self.pMediator = nil 
end

function ArtifactView.allunregister( self )
	if self.m_tagPanelClass==nil then return end
	for _tag=1,4 do
		if self.m_tagPanelClass[_tag]~=nil then
			self.m_tagPanelClass[_tag]:unregister()
		end
	end
end

function ArtifactView.__closeWindow( self )
	if self.m_rootLayer == nil then return end
    self.m_rootLayer=nil
	cc.Director:getInstance():popScene()
	self : unregister()
	self : allunregister()
end

return ArtifactView