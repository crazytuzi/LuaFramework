local ChallengeView=classGc(view,function(self)
	self.m_winSize=cc.Director:getInstance():getWinSize()
	self.m_leftSize=cc.size(508,463)
	self.m_rightSize=cc.size(306,463)

	-- self.m_preChallengeTimes=0
	self.m_preMopTimes=0
end)

local Cpoint=cc.p(78/2,78/2)
local FONTSIZE=20
local MAXFLOOR=10
local P_TAG_CHALLENGE=1
local P_TAG_REWARD=2
local P_TAG_WING=3
local P_TAG_RESET=4
local P_TAG_YES=101
local P_TAG_NO=102
local P_FONT_NAME=_G.FontName.Heiti
local P_COLOR_DARKORANGE=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKORANGE)
local P_COLOR_GOLD=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD)
local P_COLOR_BROWN=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN)
local P_COLOR_BRIGHTYELLOW=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW)
local P_PERCENT=_G.Const.CONST_SURRENDER_PLUS_PERCENT

function ChallengeView.create(self)
	self.m_normalView=require("mod.general.NormalView")()
	self.m_rootLayer=self.m_normalView:create()

	local tempScene=cc.Scene:create()
    tempScene:addChild(self.m_rootLayer)

	self:__initView()
	self:__requestAllMsg()

	self.m_mediator=require("mod.smodule.ChallengeMediator")(self)

	return tempScene
end

function ChallengeView.__requestAllMsg(self)
	local msg=REQ_XMZL_REQUEST()
	_G.Network:send(msg)
end

function ChallengeView.__initView(self)
	local function nCloseFun()
		self:closeWindow()
	end
	self.m_normalView:addCloseFun(nCloseFun)
	self.m_normalView:showSecondBg()
	self.m_normalView:setTitle("降魔之路")

	self.m_mainNode=cc.Node:create()
	self.m_mainNode:setPosition(self.m_winSize.width*0.5,self.m_winSize.height*0.5)
	self.m_rootLayer:addChild(self.m_mainNode)

	local NodeBgSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_double.png")
	NodeBgSpr:setPreferredSize(cc.size(833,475))
	NodeBgSpr:setPosition(0,-40)
	self.m_mainNode:addChild(NodeBgSpr)

	local rightBgSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_double2.png")
	rightBgSpr:setPreferredSize(self.m_rightSize)
	rightBgSpr:setPosition(256,-41)
	self.m_mainNode:addChild(rightBgSpr)

	-- 左边基础控件=============================================
	local floorBg=ccui.Scale9Sprite:createWithSpriteFrameName("general_double2.png")
	floorBg:setPreferredSize(self.m_leftSize)
	floorBg:setPosition(-155,-41)
	self.m_mainNode:addChild(floorBg)

	local function r(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			local explainView  = require("mod.general.ExplainView")()
			local explainLayer = explainView : create(31400)
		end
	end
	local helpBtn=gc.CButton:create("general_help.png")
    helpBtn:setPosition(50,self.m_leftSize.height-30)
    helpBtn:addTouchEventListener(r)
    floorBg:addChild(helpBtn)

	self.m_leftBgSpr=floorBg
	self.m_rightBgSpr=rightBgSpr

	self:RightView()
	self:LeftView()

	local guideId=_G.GGuideManager:getCurGuideId()
	if guideId==_G.Const.CONST_NEW_GUIDE_SYS_SURRENDER then
		self.m_hasGuide=true
		_G.GGuideManager:initGuideView(self.m_rootLayer)
		_G.GGuideManager:registGuideData(1,self.challengeBtn)
		_G.GGuideManager:runNextStep()

		local command=CGuideNoticHide()
      	controller:sendCommand(command)
	end
end

function ChallengeView.LeftView(self)
	self.numberLab=_G.Util:createLabel("第一层:",FONTSIZE+2)
	self.numberLab:setColor(P_COLOR_BROWN)
	self.numberLab:setAnchorPoint(cc.p(1,0.5))
	self.numberLab:setPosition(120,self.m_leftSize.height-90)
	self.m_leftBgSpr:addChild(self.numberLab)

	local inputSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_input.png")
	inputSpr:setPreferredSize(cc.size(self.m_leftSize.width-30,75))
	inputSpr:setPosition(self.m_leftSize.width/2,120)
	self.m_leftBgSpr:addChild(inputSpr)

	local Lab=_G.Util:createLabel("关卡说明:",FONTSIZE)
	Lab:setColor(P_COLOR_BROWN)
	Lab:setAnchorPoint(cc.p(0,0.5))
	Lab:setPosition(35,130)
	self.m_leftBgSpr:addChild(Lab)

	self.explainLab=_G.Util:createLabel("",FONTSIZE)
	self.explainLab:setColor(P_COLOR_DARKORANGE)
	self.explainLab:setAnchorPoint(cc.p(0,0.5))
	self.explainLab:setPosition(135,109)
	self.explainLab:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	self.explainLab:setDimensions(self.m_leftSize.width-150, 65)
	self.m_leftBgSpr:addChild(self.explainLab)

	local Lab=_G.Util:createLabel("本层奖励:",FONTSIZE)
	Lab:setColor(P_COLOR_BROWN)
	Lab:setAnchorPoint(cc.p(0,0.5))
	Lab:setPosition(35,self.m_leftSize.height/2+30)
	self.m_leftBgSpr:addChild(Lab)

	local Lab=_G.Util:createLabel("当前血量:",FONTSIZE)
	Lab:setColor(P_COLOR_BROWN)
	Lab:setAnchorPoint(cc.p(0,0.5))
	Lab:setPosition(35,self.m_leftSize.height/2-45)
	self.m_leftBgSpr:addChild(Lab)

	self.headSpr={}
	self.rewardSpr={}
	for i=1,3 do
		self.headSpr[i]=cc.Sprite:createWithSpriteFrameName("challenge_kuang.png")
		self.headSpr[i]:setPosition(60+115*i,self.m_leftSize.height-90)
		self.m_leftBgSpr:addChild(self.headSpr[i])

		self.rewardSpr[i]=cc.Sprite:createWithSpriteFrameName("general_tubiaokuan.png")
		self.rewardSpr[i]:setPosition(60+115*i,self.m_leftSize.height/2+30)
		self.m_leftBgSpr:addChild(self.rewardSpr[i])
	end

	local boxSize=self.headSpr[3]:getContentSize()
	local bossLab=cc.Sprite:createWithSpriteFrameName("challenge_boss.png")
	bossLab:setPosition(boxSize.width/2,boxSize.height/2)
	self.headSpr[3]:addChild(bossLab,5)

	local bgSpr=ccui.Scale9Sprite:createWithSpriteFrameName("challenge_hpkuang.png")
	local hpSize=bgSpr:getContentSize()
	bgSpr:setPreferredSize(cc.size(344,hpSize.height))
	bgSpr:setPosition(self.m_leftSize.width/2+46,self.m_leftSize.height/2-45)
	self.m_leftBgSpr:addChild(bgSpr)

	self.expSpr=ccui.LoadingBar:create()
	self.expSpr:loadTexture("challenge_hp.png",ccui.TextureResType.plistType)
	self.expSpr:setAnchorPoint(cc.p(0,0.5))
	self.expSpr:setPosition(hpSize.width/2-30,hpSize.height/2)
	self.expSpr:setScaleX(6.4)
	self.expSpr:setPercent(0)
	bgSpr:addChild(self.expSpr)

	local property = _G.GPropertyProxy:getMainPlay()
	self.hpNum = property:getAttr():getHp()
	self.hpLab=_G.Util:createLabel(self.hpNum,FONTSIZE-2)
	self.hpLab:setPosition(self.m_leftSize.width/2+46,self.m_leftSize.height/2-47)
	self.m_leftBgSpr:addChild(self.hpLab)

	local function r(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			local tag=sender:getTag()
			if tag==P_TAG_CHALLENGE then
				local property=_G.GPropertyProxy:getMainPlay()
				property.m_provisionalMaxHP=self.proHp
				local msg=REQ_COPY_NEW_CREAT()
			    msg:setArgs(self.copyid[self.floor])
			    _G.Network:send(msg)
			    -- self:closeWindow()
			elseif tag==P_TAG_REWARD then
				if self.RewardTips==nil then
					self:RewardTipsView()
				else
					self.RewardLayer:setVisible(true)
					self.RewardTips:setVisible(true)
					self.rw_listerner:setSwallowTouches(true)
				end
			end
		end
	end

	local rewardBtn=gc.CButton:create("general_btn_lv.png")
    rewardBtn:setPosition(self.m_leftSize.width/2-95,40)
    rewardBtn:addTouchEventListener(r)
    rewardBtn:setTag(P_TAG_REWARD)
    rewardBtn:setTitleFontName(P_FONT_NAME)
    rewardBtn:setTitleFontSize(22)
    rewardBtn:setTitleText("奖励预览")
    self.m_leftBgSpr:addChild(rewardBtn)

    self.challengeBtn=gc.CButton:create("general_btn_gold.png")
    self.challengeBtn:setPosition(self.m_leftSize.width/2+95,40)
    self.challengeBtn:addTouchEventListener(r)
    self.challengeBtn:setTag(P_TAG_CHALLENGE)
    self.challengeBtn:setTitleFontName(P_FONT_NAME)
    self.challengeBtn:setTitleFontSize(22)
    self.challengeBtn:setTitleText("挑 战")
    self.m_leftBgSpr:addChild(self.challengeBtn)
end

function ChallengeView.RightView(self)
	local Lab=_G.Util:createBorderLabel("宠物助阵",FONTSIZE,P_COLOR_BROWN)
	Lab:setColor(P_COLOR_BRIGHTYELLOW)
	Lab:setPosition(self.m_rightSize.width/2+45,self.m_rightSize.height-45)
	self.m_rightBgSpr:addChild(Lab)

	local Lab=_G.Util:createLabel("(点击头像更换)",FONTSIZE-2)
	Lab:setColor(P_COLOR_BROWN)
	Lab:setPosition(self.m_rightSize.width/2+45,self.m_rightSize.height-75)
	self.m_rightBgSpr:addChild(Lab)

	local Lab=_G.Util:createLabel("属性点:",FONTSIZE)
	Lab:setColor(P_COLOR_BROWN)
	Lab:setAnchorPoint(cc.p(0,0.5))
	Lab:setPosition(24,30)
	self.m_rightBgSpr:addChild(Lab)

	self.haveLab=_G.Util:createLabel("0/0",FONTSIZE)
	self.haveLab:setColor(P_COLOR_DARKORANGE)
	self.haveLab:setAnchorPoint(cc.p(0,0.5))
	self.haveLab:setPosition(95,30)
	self.m_rightBgSpr:addChild(self.haveLab)

	local function r(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			local tag=sender:getTag()
			local Position 	= sender : getWorldPosition()
			if tag==P_TAG_WING then
				if self.WingTips==nil then
					local msg=REQ_WING_REQUEST()
					msg:setArgs(0)
					_G.Network:send(msg)
				else
					self.WingTips:setVisible(true)
					self.WingLayer:setVisible(true)
					self.w_listerner:setSwallowTouches(true)
				end
			elseif tag==P_TAG_RESET then
				local msg=REQ_XMZL_ATTR_POINT_RESET()
				_G.Network:send(msg)
			else
				print("Position.y",Position.y,self.m_winSize.height/2+self.m_rightSize.height/2-155,self.m_winSize.height/2-self.m_rightSize.height/2+55 )
				if Position.y > self.m_winSize.height/2+self.m_rightSize.height/2-155 or 
					Position.y < self.m_winSize.height/2-self.m_rightSize.height/2+55 
					then return end
				local msg=REQ_XMZL_ATTR_POINT_ADD()
				msg:setArgs(tag)
				_G.Network:send(msg)
			end
		end
	end

	self.wingBtn=gc.CButton:create("general_tubiaokuan.png")
    self.wingBtn:setPosition(65,self.m_rightSize.height-60)
    self.wingBtn:addTouchEventListener(r)
    self.wingBtn:setTag(P_TAG_WING)
    self.m_rightBgSpr:addChild(self.wingBtn)

	local resettingBtn=gc.CButton:create("general_btn_gold.png")
    resettingBtn:setPosition(self.m_rightSize.width-80,30)
    resettingBtn:addTouchEventListener(r)
    resettingBtn:setTag(P_TAG_RESET)
    resettingBtn:setTitleFontName(P_FONT_NAME)
    resettingBtn:setTitleFontSize(24)
    resettingBtn:setTitleText("重 置")
    -- resettingBtn:setButtonScale(0.8)
    self.m_rightBgSpr:addChild(resettingBtn)

    local addwSpr=cc.Sprite:createWithSpriteFrameName("challenge_add.png")
    addwSpr:setPosition(Cpoint)
    self.wingBtn:addChild(addwSpr)

    local viewSize=cc.size(self.m_rightSize.width-10,290)
    local lineSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_double_line.png")
	lineSpr:setPreferredSize(cc.size(viewSize.width,lineSpr:getContentSize().height))
	lineSpr:setPosition(self.m_rightSize.width/2,60)
	self.m_rightBgSpr:addChild(lineSpr)

    local scrollViewSize=cc.size(viewSize.width,viewSize.height+85)
    -- local contentView = cc.ScrollView:create()
  	-- contentView : setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
  	-- contentView : setViewSize(viewSize)
  	-- contentView : setContentSize(scrollViewSize)
  	-- contentView : setPosition(8,63)
  	-- contentView : setContentOffset( cc.p( 0,viewSize.height-scrollViewSize.height)) -- 设置初始位置
  	-- self.m_rightBgSpr : addChild(contentView)
  	-- self.barView=require("mod.general.ScrollBar")(contentView)
  	-- self.barView:setPosOff(cc.p(-7,0))

  	self:AttrData()
  	local info = {42,41,44,43,45,46,47,48}
  	local infoStr = {"攻击:","气血:","破甲:","防御:","命中:","闪避:","暴击:","抗暴:"}
  	self.infoNum={1,2,3,4,5,6,7,8}
    self.m_PropLab = {1,2,3,4,5,6,7,8}
    self.m_PropNumLab = {1,2,3,4,5,6,7,8}
    self.m_addBtn  = {1,2,3,4,5,6,7,8}
    local prop_img  = {"general_att.png","general_hp.png","general_wreck.png","general_def.png",
    			"general_hit.png","general_dodge.png","general_crit.png","general_crit_res.png"}

    for i=1,8 do
    	local posY=scrollViewSize.height-i*37
		local infoStrLab = _G.Util:createLabel(infoStr[i],FONTSIZE)
		infoStrLab : setAnchorPoint(cc.p(0,0.5))
		infoStrLab : setPosition(46,posY)
		infoStrLab : setColor(P_COLOR_BROWN)
		self.m_rightBgSpr : addChild(infoStrLab)

		self.m_PropLab[info[i]] = _G.Util:createLabel(self.attrNum[info[i]],FONTSIZE)
		self.m_PropLab[info[i]] : setAnchorPoint(cc.p(0,0.5))
		self.m_PropLab[info[i]] : setPosition(97,posY)
		self.m_PropLab[info[i]] : setColor(P_COLOR_DARKORANGE)
		self.m_rightBgSpr : addChild(self.m_PropLab[info[i]])

		self.infoNum[info[i]] = 0
		self.m_PropNumLab[info[i]] = _G.Util:createLabel("(+0)",FONTSIZE)
		self.m_PropNumLab[info[i]] : setAnchorPoint(cc.p(0,0.5))
		self.m_PropNumLab[info[i]] : setPosition(170,posY)
		self.m_PropNumLab[info[i]] : setColor(P_COLOR_DARKORANGE)
		self.m_rightBgSpr : addChild(self.m_PropNumLab[info[i]])

		local m_PropSpr = cc.Sprite:createWithSpriteFrameName(prop_img[i])
		m_PropSpr : setPosition(30,posY+2)
		self.m_rightBgSpr : addChild(m_PropSpr)

		self.m_addBtn[info[i]] = gc.CButton:create("general_btn_add.png")
		self.m_addBtn[info[i]] : setPosition(self.m_rightSize.width-33,posY)
		-- self.m_addBtn[i] : setContentSize(cc.size(60,60))
		self.m_addBtn[info[i]] : setTag(info[i])
		self.m_addBtn[info[i]] : addTouchEventListener(r)
		self.m_rightBgSpr : addChild(self.m_addBtn[info[i]])
    end
end

function ChallengeView.WingTipsView(self,_data)
	print("选择宠物")
	local function onTouchBegan() return true end
	self.w_listerner = cc.EventListenerTouchOneByOne:create()
	self.w_listerner : registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
	self.w_listerner : setSwallowTouches(true)

	self.WingLayer=cc.LayerColor:create(cc.c4b(0,0,0,150))
    cc.Director:getInstance():getRunningScene() :addChild(self.WingLayer,999)

	local tipsSize=cc.size(611, 438)
	self.WingTips = ccui.Scale9Sprite : createWithSpriteFrameName("general_tips_dins.png")
	self.WingTips : setPosition(self.m_winSize.width/2, self.m_winSize.height/2-20)
	self.WingTips : setPreferredSize(tipsSize)
	self.WingTips : getEventDispatcher():addEventListenerWithSceneGraphPriority(self.w_listerner,self.WingTips)
	cc.Director:getInstance():getRunningScene() :addChild(self.WingTips,1001)

	local tipslogoSpr = cc.Sprite : createWithSpriteFrameName("general_tips_up.png")
	tipslogoSpr : setPosition(tipsSize.width/2-135, tipsSize.height-26)
	self.WingTips : addChild(tipslogoSpr)

	local tipslogoSpr = cc.Sprite : createWithSpriteFrameName("general_tips_up.png")
	tipslogoSpr : setPosition(tipsSize.width/2+130, tipsSize.height-26)
	tipslogoSpr : setRotation(180)
	self.WingTips : addChild(tipslogoSpr)

	local neikuangSpr = ccui.Scale9Sprite : createWithSpriteFrameName("general_di2kuan.png")
	neikuangSpr : setPosition(tipsSize.width/2,tipsSize.height/2+18)
	neikuangSpr : setPreferredSize(cc.size(564,315))
	self.WingTips : addChild(neikuangSpr)

	local logoLab= _G.Util : createBorderLabel("宠物助阵", FONTSIZE+4,P_COLOR_BROWN)
	logoLab : setPosition(tipsSize.width/2, tipsSize.height-26)
	logoLab : setColor(P_COLOR_BRIGHTYELLOW)
	self.WingTips  : addChild(logoLab)

	local act2=cc.ScaleTo:create(0.2,1.04)
	local act3=cc.ScaleTo:create(0.1,0.98)
	local act4=cc.ScaleTo:create(0.05,1)
	self.WingTips:setScale(0.9)
	self.WingTips:runAction(cc.Sequence:create(act2,act3,act4))

	local function wingCallBack(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			local tag=sender:getTag()
			local Position=sender:getWorldPosition()
			if tag==P_TAG_YES then
				if self.wingid~=nil then
					local msg=REQ_XMZL_WING_CHEER()
					msg:setArgs(self.wingid)
					_G.Network:send(msg)
				else
					-- local command = CErrorBoxCommand("未选助阵宠物")
   	 --        		controller : sendCommand( command )
   	 				local msg=REQ_XMZL_WING_CHEER()
					msg:setArgs(0)
					_G.Network:send(msg)
				end
			elseif tag==P_TAG_NO then
				self.WingTips:setVisible(false)
				self.WingLayer:setVisible(false)
				self.w_listerner:setSwallowTouches(false)
			else
				print("Position.y",Position.y,self.m_winSize.height/2+tipsSize.height/2-60,self.m_winSize.height/2-tipsSize.height/2+105)
				if Position.y > self.m_winSize.height/2+tipsSize.height/2-60 or 
					Position.y < self.m_winSize.height/2-tipsSize.height/2+105
					then return end
				if tag==self.wingTag then
					self.yesSpr[tag]:setVisible(false)
					self.wingid=nil
					self.wingTag=nil
				else
					self.wingid=_G.Cfg.wing[tag].wing_id
					self.yesSpr[tag]:setVisible(true)
					if self.wingTag~=nil then
						self.yesSpr[self.wingTag]:setVisible(false)
					end
					self.wingTag=tag
				end			
			end
		end
	end

	local viewSize=cc.size(564,302)
    local scrollViewSize=cc.size(viewSize.width,400)
    local contentView = cc.ScrollView:create()
  	contentView : setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
  	contentView : setViewSize(viewSize)
  	contentView : setContentSize(scrollViewSize)
  	contentView : setPosition(20,86)
  	contentView : setContentOffset( cc.p( 0,viewSize.height-scrollViewSize.height)) -- 设置初始位置
  	self.WingTips : addChild(contentView)
  	self.wbarView=require("mod.general.ScrollBar")(contentView)
  	self.wbarView:setPosOff(cc.p(-4,0))

  	self.yesSpr={}
  	local posX=viewSize.width/2+52
  	local posY=scrollViewSize.height+50
	for i=1,8 do
		posX=viewSize.width/2+52
		if i%2==1 then
			posX=viewSize.width/2-225
			posY=posY-101
		end
		local kuangBtn=ccui.Button:create("general_nothis.png","general_isthis.png","general_isthis.png",1)
		kuangBtn:setScale9Enabled(true)
		kuangBtn:setContentSize(cc.size(274,97))
		kuangBtn:addTouchEventListener(wingCallBack)
		kuangBtn:setSwallowTouches(false)
		kuangBtn:setEnabled(false)
		kuangBtn:setTag(i)
		kuangBtn:setPosition(posX+90,posY)
		contentView:addChild(kuangBtn)

		local tubiaoSpr=cc.Sprite:createWithSpriteFrameName("general_tubiaokuan.png")
		tubiaoSpr:setPosition(posX,posY)
		contentView:addChild(tubiaoSpr)

		local wingid=_G.Cfg.wing[i].wing_id
		local headSpr=self:ReturnHeadSpr(wingid)
		headSpr:setPosition(Cpoint)
		headSpr:setGray()
		tubiaoSpr:addChild(headSpr)

		local wingLab= _G.Util : createLabel("未激活", FONTSIZE)
		wingLab : setColor(_G.ColorUtil : getRGBA(_G.Const.CONST_COLOR_ORED))
		wingLab : setPosition(85/2,15)
		tubiaoSpr : addChild(wingLab)

		local grade=1
		for k,v in pairs(_data) do
			if v.wing_id==wingid then
				headSpr:setDefault()
				wingLab:setVisible(false)
				kuangBtn:setEnabled(true)
				grade=v.grade

				self.yesSpr[i]=cc.Sprite:createWithSpriteFrameName("challenge_icon.png")
				self.yesSpr[i]:setPosition(Cpoint)
				self.yesSpr[i]:setVisible(false)
				tubiaoSpr:addChild(self.yesSpr[i])

				if self.wingid~=nil and wingid==self.wingid then
					self.yesSpr[i]:setVisible(true)
					self.wingTag=i
				end
			end
		end

		local name=_G.Cfg.wing[i].name
		local nameLab= _G.Util : createBorderLabel(name, FONTSIZE,P_COLOR_BROWN)
		nameLab : setColor(P_COLOR_BRIGHTYELLOW)
		nameLab : setPosition(posX+50, posY+25)
		nameLab : setAnchorPoint( cc.p(0.0,0.5) )
		contentView : addChild(nameLab)

		local Skilldes=_G.Cfg.wing_link[i+200].des
		local basics = _G.Cfg.wing_link[i+200].basics/100
		local plus   = _G.Cfg.wing_link[i+200].plus/100
		local newbas = (grade-1)*plus+basics
		local newDes = string.gsub(Skilldes, "~p", newbas)
		local skdesLab = _G.Util : createLabel(newDes, FONTSIZE )
		skdesLab : setPosition(posX+140, posY-38)
		skdesLab : setColor( P_COLOR_BROWN )
		skdesLab : setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)         --左对齐 
		skdesLab : setDimensions(180,100)  --设置文字区域
		contentView : addChild( skdesLab )
	end

	local yesBtn = gc.CButton : create("general_btn_lv.png")
	yesBtn : setTitleFontName(_G.FontName.Heiti)
	yesBtn : setTitleText("确 定")
	yesBtn : setTitleFontSize(24)
	yesBtn : setPosition(tipsSize.width/2-110, 53)
	yesBtn : addTouchEventListener(wingCallBack)
	yesBtn : setTag(P_TAG_YES)
	self.WingTips : addChild(yesBtn)

	local cancelBtn = gc.CButton : create("general_btn_gold.png")
	cancelBtn : setTitleFontName(_G.FontName.Heiti)
	cancelBtn : setTitleText("取 消")
	cancelBtn : setTitleFontSize(24)
	cancelBtn : setPosition(tipsSize.width/2+110, 53)
	cancelBtn : addTouchEventListener(wingCallBack)
	cancelBtn : setTag(P_TAG_NO)
	self.WingTips : addChild(cancelBtn)

	-- local tanSpr=cc.Sprite:createWithSpriteFrameName("general_tanhao.png")
	-- tanSpr:setPosition(105,42)
	-- self.WingTips : addChild(tanSpr)

	local tipsLab=_G.Util:createLabel("点击宠物头像进行选择/取消！(只在本系统中更换)",FONTSIZE-2)
	tipsLab:setColor( _G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
	tipsLab:setAnchorPoint(cc.p(0,0.5))
	tipsLab:setPosition(105,20)
	self.WingTips : addChild(tipsLab)
end

function ChallengeView.delayCallFun( self )
    local function nFun()
        print("nFun-----------------")
        if self.RewardTips~=nil then
	    	self.RewardLayer:setVisible(false)
	      	self.RewardTips:setVisible(false)
			self.rw_listerner:setSwallowTouches(false)
	    end
    end
    local delay=cc.DelayTime:create(0.01)
    local func=cc.CallFunc:create(nFun)
    self.m_rootLayer:runAction(cc.Sequence:create(delay,func))
end

function ChallengeView.RewardTipsView(self)
	print("奖励预览")
	local tipsSize=cc.size(480, 365)
	local function onTouchBegan(touch) 
		print("TipsUtil remove tips")
	    local location=touch:getLocation()
	    local bgRect=cc.rect(self.m_winSize.width/2-tipsSize.width/2,self.m_winSize.height/2-tipsSize.height/2,
	    	tipsSize.width,tipsSize.height)
	    local isInRect=cc.rectContainsPoint(bgRect,location)
	    print("location===>",location.x,location.y)
	    print("bgRect====>",bgRect.x,bgRect.y,bgRect.width,bgRect.height,isInRect)
	    if isInRect then
	        return true
	    end
	    self:delayCallFun()
		return true 
	end
	self.rw_listerner = cc.EventListenerTouchOneByOne:create()
	self.rw_listerner : registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
	self.rw_listerner : setSwallowTouches(true)

	self.RewardTips = ccui.Scale9Sprite : createWithSpriteFrameName("general_tips_dins.png")
	self.RewardTips : setPosition(self.m_winSize.width/2, self.m_winSize.height/2-20)
	self.RewardTips : setPreferredSize(tipsSize)
	self.RewardTips : getEventDispatcher():addEventListenerWithSceneGraphPriority(self.rw_listerner,self.RewardTips)
	cc.Director:getInstance():getRunningScene() :addChild(self.RewardTips,1001)

	self.RewardLayer=cc.LayerColor:create(cc.c4b(0,0,0,150))
    cc.Director:getInstance():getRunningScene() :addChild(self.RewardLayer,999)

	local rewardSize= self.RewardTips : getContentSize()
	local tipslogoSpr = cc.Sprite : createWithSpriteFrameName("general_tips_up.png")
	tipslogoSpr : setPosition(rewardSize.width/2-125, rewardSize.height-25)
	self.RewardTips : addChild(tipslogoSpr)

	local tipslogoSpr = cc.Sprite : createWithSpriteFrameName("general_tips_up.png")
	tipslogoSpr : setPosition(rewardSize.width/2+120, rewardSize.height-25)
	tipslogoSpr : setRotation(180)
	self.RewardTips : addChild(tipslogoSpr)

	local neikuangSpr = ccui.Scale9Sprite : createWithSpriteFrameName("general_di2kuan.png")
	neikuangSpr : setPosition(rewardSize.width/2,rewardSize.height/2-17)
	neikuangSpr : setPreferredSize(cc.size(465,314))
	self.RewardTips : addChild(neikuangSpr)

	local logoLab= _G.Util : createBorderLabel("奖 励", FONTSIZE+4,P_COLOR_BROWN)
	logoLab : setPosition(rewardSize.width/2, rewardSize.height-25)
	logoLab:setColor(P_COLOR_BRIGHTYELLOW)
	self.RewardTips  : addChild(logoLab)

	local act2=cc.ScaleTo:create(0.2,1.04)
	local act3=cc.ScaleTo:create(0.1,0.98)
	local act4=cc.ScaleTo:create(0.05,1)
	self.RewardTips:setScale(0.9)
	self.RewardTips:runAction(cc.Sequence:create(act2,act3,act4))

	local function RewardCallBack(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			local tag=sender:getTag()
			local Position=sender:getWorldPosition()
			print("Position.y",Position.y,self.m_winSize.height/2+tipsSize.height/2-40,self.m_winSize.height/2-tipsSize.height/2+40)
			if Position.y > self.m_winSize.height/2+tipsSize.height/2-40 or 
				Position.y < self.m_winSize.height/2-tipsSize.height/2+40
				then return end
			local temp = _G.TipsUtil:createById(tag,nil,Position)
			cc.Director:getInstance():getRunningScene():addChild(temp,2000)				
		end
	end

	local viewSize=cc.size(465,303)
    local scrollViewSize=cc.size(viewSize.width,101*MAXFLOOR)
    local contentView = cc.ScrollView:create()
  	contentView : setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
  	contentView : setViewSize(viewSize)
  	contentView : setContentSize(scrollViewSize)
  	contentView : setPosition(7,14)
  	contentView : setContentOffset( cc.p( 0,viewSize.height-scrollViewSize.height)) -- 设置初始位置
  	self.RewardTips : addChild(contentView)
  	self.rbarView=require("mod.general.ScrollBar")(contentView)
  	self.rbarView:setPosOff(cc.p(-8,0))

	for i=1,MAXFLOOR do
		local kuangSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_nothis.png")
		kuangSpr:setPreferredSize(cc.size(450,96))
		kuangSpr:setPosition(viewSize.width/2,scrollViewSize.height-51-(i-1)*101)
		contentView:addChild(kuangSpr)

		local numLab=_G.Util:createLabel(string.format("第%s层:",_G.Lang.number_Chinese[i]),FONTSIZE)
		numLab:setColor(P_COLOR_BROWN)
		numLab:setAnchorPoint(cc.p(0,0.5))
		numLab:setPosition(25,scrollViewSize.height-51-(i-1)*101)
		contentView:addChild(numLab)

		local copyData=_G.Cfg.scene_copy[self.copyid[i]]
		for j=1,3 do
			local kuangSpr=cc.Sprite:createWithSpriteFrameName("general_tubiaokuan.png")
			kuangSpr:setPosition(50+110*j,scrollViewSize.height-51-(i-1)*101)
			contentView:addChild(kuangSpr)

			if copyData.reward[j]~=nil and copyData.reward[j][1][1]~=nil then
				local goodsid=copyData.reward[j][1][1]
				local goodscount=copyData.reward[j][1][2]
				print("goodsid-->>",goodsid,goodscount)
				local node = _G.Cfg.goods[goodsid]
				local r_goodsSpr=_G.ImageAsyncManager:createGoodsBtn(node,RewardCallBack,goodsid,goodscount)
				r_goodsSpr:setSwallowTouches(false)
				r_goodsSpr:setPosition(Cpoint)
				kuangSpr:addChild(r_goodsSpr)
			end
		end
	end
end

function ChallengeView.msgCallBack(self,_data)
	if self.wingSpr~=nil then
		self.wingSpr:removeFromParent(true)
		self.wingSpr=nil
	end

	self.floor=_data.floor+1
	if self.floor>MAXFLOOR then
		self.challengeBtn:setBright(false)
		self.challengeBtn:setEnabled(false)
		self.challengeBtn:setTitleText("已通关")
		self.floor=MAXFLOOR
	end
	self.wingid=_data.wing_id
	self.hp=_data.hp
	local allattr=_data.attr_point_all
	local attr=_data.attr_point
	self.numberLab:setString(string.format("第%s层:",_G.Lang.number_Chinese[self.floor]))
	self.haveLab:setString(string.format("%d/%d",attr,allattr))
	self.hpLab:setString(self.hp)

	local Pect=self.hp/self.hpNum*100
	self.expSpr:setPercent(Pect)
	if self.wingid~=0 then
		self.wingSpr=self:ReturnHeadSpr(self.wingid)
	    self.wingSpr:setPosition(Cpoint)
	    self.wingBtn:addChild(self.wingSpr)
	end

	local property=_G.GPropertyProxy:getMainPlay()
	property.m_provisionalStar=self.wingid
	if self.hpNum>self.hp then
		self.proHp=self.hpNum
	else
		self.proHp=self.hp
	end

	for k,v in pairs(_data.msg_attr) do
		print("_data.msg_attr",v.type,v.value)
		if self.m_PropNumLab[v.type]~=nil then
			self.m_PropNumLab[v.type]:setString(string.format("(+%d)",v.value))
			local newNum=math.ceil(self.attrNum[v.type]+self.attrNum[v.type]*(v.value*P_PERCENT)/100)
			self.m_PropLab[v.type]:setString(newNum)
			if v.type==41 then
				print()
				local Pect=self.hp/newNum*100
				self.expSpr:setPercent(Pect)
				if newNum>self.hp then
					self.proHp=newNum
				else
					self.proHp=self.hp
				end
			end
		end
	end

end

function ChallengeView.AttrPoint(self,point,point_all)
	self.haveLab:setString(string.format("%d/%d",point,point_all))
	local info = {42,41,44,43,45,46,47,48}
	if point==point_all then
		for i=1,8 do
			self.m_PropNumLab[info[i]]:setString("(+0)")
			local newNum=self.attrNum[info[i]]
			self.m_PropLab[info[i]]:setString(newNum)
		end
		self.proHp=self.attrNum[41]
		local Pect=self.hp/self.attrNum[41]*100
		self.expSpr:setPercent(Pect)
	end
end

function ChallengeView.updateAttrData(self,_type,_value)
	self.m_PropNumLab[_type]:setString(string.format("(+%d)",_value))
	local newNum=math.ceil(self.attrNum[_type]+self.attrNum[_type]*(_value*P_PERCENT)/100)
	self.m_PropLab[_type]:setString(newNum)
	if _type==41 then
		local maxHp=newNum
		if maxHp>self.hp then
			self.proHp=maxHp
		else
			self.proHp=self.hp
		end
		
		local Pect=self.hp/maxHp*100
		self.expSpr:setPercent(Pect)
	end
end

function ChallengeView.WingReply(self,wing_id)
	if self.wingSpr~=nil then
		self.wingSpr:removeFromParent(true)
		self.wingSpr=nil
	end

	if wing_id~=0 then 
		self.wingSpr=self:ReturnHeadSpr(wing_id)
	    self.wingSpr:setPosition(Cpoint)
	    self.wingBtn:addChild(self.wingSpr)
	else
		self.wingTag=nil
	end

	local property=_G.GPropertyProxy:getMainPlay()
	property.m_provisionalStar=wing_id

	self.WingTips:setVisible(false)
	self.WingLayer:setVisible(false)
	self.w_listerner:setSwallowTouches(false)
end

function ChallengeView.updateCopy(self,_data)
	if self.iconSpr~=nil then
		for k,v in pairs(self.iconSpr) do
			v:removeFromParent(true)
			v=nil
		end
	end
	if self.goodsSpr~=nil then
		for k,v in pairs(self.goodsSpr) do
			v:removeFromParent(true)
			v=nil
		end
	end
	if self.copySpr~=nil then
		self.copySpr:removeFromParent(true)
		self.copySpr=nil
	end

	self.copyid={}
	for k,v in pairs(_data) do
		print(k,v.copy_id)
		self.copyid[k]=v.copy_id
	end
	local copyData=_G.Cfg.scene_copy[self.copyid[self.floor]]
	self.explainLab:setString(copyData.desc)

	local function cFun(sender,eventType)
		if eventType==ccui.TouchEventType.ended then
		local btn_tag=sender:getTag()
		local _pos = sender:getWorldPosition()
		local temp = _G.TipsUtil:createById(btn_tag,nil,_pos)
		cc.Director:getInstance():getRunningScene():addChild(temp,1000)
		end
   	end
   	self.iconSpr={}
	self.goodsSpr={}
	for i=1,3 do
		if copyData.img[i]~=nil then
			print("copyData.img[i]",copyData.img[i])
			-- local szIcon="copyui_icon_10101.png"
			-- if self.copyid[self.floor] then
			-- 	local sceneId=self.copyid[self.floor]
			-- 	local sceneCnf=get_scene_data(sceneId)
			-- 	if sceneCnf then
			-- 		local materialCnf=_G.MapData[sceneCnf.material_id]
			-- 		if materialCnf then
			-- 			local newIcon=string.format("copyui_icon_%d.png",materialCnf.small_id)
			-- 			local spriteFram=cc.SpriteFrameCache:getInstance():getSpriteFrame(newIcon)
			-- 			if spriteFram~=nil then
			-- 				szIcon=newIcon
			-- 			end
			-- 		end
			-- 	end
			-- end
			-- self.copySpr=gc.GraySprite:createWithSpriteFrameName(szIcon)
			-- self.copySpr:setPosition(Cpoint)
			-- self.headSpr[i]:addChild(self.copySpr)

			local szHead=string.format("h%d.png",copyData.img[i])
			if not cc.SpriteFrameCache:getInstance():getSpriteFrame(szHead) then
				szHead="h20001.png"
			end
			self.iconSpr[i]=gc.GraySprite:createWithSpriteFrameName(szHead)
			self.iconSpr[i]:setPosition(85/2,85/2)
			self.headSpr[i]:addChild(self.iconSpr[i],-1)
		end

		if copyData.reward[i]~=nil and copyData.reward[i][1][1]~=nil then
			local goodsid=copyData.reward[i][1][1]
			local goodscount=copyData.reward[i][1][2]
			print("goodsid-->>",goodsid,goodscount)
			local node = _G.Cfg.goods[goodsid]
			self.goodsSpr[i]=_G.ImageAsyncManager:createGoodsBtn(node,cFun,goodsid,goodscount)
			self.goodsSpr[i]:setPosition(Cpoint)
			self.rewardSpr[i]:addChild(self.goodsSpr[i])
		end
	end
end

function ChallengeView.AttrData(self)
	local property=_G.GPropertyProxy:getMainPlay()
	self.attrData=property:getAttr()
	self.attrNum={}
    for k,v in pairs(self.attrData) do
		print("self.attrData",k,v)
		if k=="strong_att" then
			self.attrNum[42]=v
		elseif k=="hp" then
			self.attrNum[41]=v
		elseif k=="wreck" then
			self.attrNum[44]=v
		elseif k=="strong_def" then
			self.attrNum[43]=v
		elseif k=="hit" then
			self.attrNum[45]=v
		elseif k=="dodge" then
			self.attrNum[46]=v
		elseif k=="crit" then
			self.attrNum[47]=v
		elseif k=="crit_res" then
			self.attrNum[48]=v
		end
  	end
end

function ChallengeView.ReturnHeadSpr(self,head_id)
	local spr=_G.ImageAsyncManager:createHeadSpr(head_id)
	return spr
end

function ChallengeView.closeWindow(self)
	if self.m_rootLayer==nil then return end
	self.m_rootLayer=nil
	cc.Director:getInstance():popScene()
	self:destroy()

	if self.m_hasGuide then
		local command=CGuideNoticShow()
      	controller:sendCommand(command)
	end
end

return ChallengeView

