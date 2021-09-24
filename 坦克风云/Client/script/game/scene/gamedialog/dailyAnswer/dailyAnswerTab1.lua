dailyAnswerTab1 = {}

function dailyAnswerTab1:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.bgLayer=nil
	self.layerNum=nil
	self.questionTitle = nil
	self.countDownLabel = nil
	self.loadingBar = nil
	self.loadingBarBg = nil
	self.recentLabelNum = nil
	self.recentLabelRank = nil
	self.answerLabel1=nil
	self.answerLabel2=nil
	self.notStartLabel1=nil
	self.notStartLabel2=nil
	self.selectedLabel=nil
	self.answerATouch=nil
	self.answerBTouch=nil
	self.selectBg1=nil
	self.selectBg2=nil
	self.alphaBgA=nil
	self.alphaBgB=nil
	self.tvSize = nil
	self.tv1 = nil
	self.tv2 = nil
	self.tv1Num = 0
	self.tv2Num = 0
	self.prevScore = 0
	self.prevRank = 0
	self.answerIsStart = false -- 游戏是否开始
	self.answerIsEnd = nil --游戏是否结束
	self.questionCountDownNum = nil
	self.resultCountDownNum = nil
	self.startCountDownNum = nil
	self.numberOfQuestion=0
	self.iscomputingResult=false

	self.tikuCfg=nil
	if G_getCurChoseLanguage() =="tw" then
		require "luascript/script/config/gameconfig/tikuCfg/tikuCfg_tw"
		self.tikuCfg=G_clone(tikuCfg_tw)
	else
		require "luascript/script/config/gameconfig/tikuCfg/tikuCfg_cn"
		self.tikuCfg=G_clone(tikuCfg_cn)
	end
	spriteController:addPlist("public/vipFinal.plist")
	G_addResource8888(function()
		spriteController:addPlist("public/ltzdz/ltzdzSegUpImgs.plist")
        spriteController:addTexture("public/ltzdz/ltzdzSegUpImgs.png")
	end)
	return nc
end

function dailyAnswerTab1:init(layerNum)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum

	self.highRankStr = meiridatiCfg.rewardlimit.."+"

	local function callback(fn,data)
    	local ret,sData = base:checkServerData(data)
    	
    	if ret==true then
    		if sData.data==nil then 
    			return        		                  
            end
    	end

    	-- dailyAnswerVoApi:clear()

    	if sData.data.meiridati~=nil and sData.data.meiridati.rightRank~=nil then
    		dailyAnswerVoApi:setNumberOfQuestion(sData.data.meiridati.rightRank[3])
    		
    		dailyAnswerVoApi:setRankList(sData.data.meiridati.rightRank)
    		dailyAnswerVoApi:setRankList(sData.data.meiridati.errorRank)
    		
    	else
    	
    		if sData.data.meiridati.info~=nil and sData.data.meiridati.info.info~=nil and sData.data.meiridati.info.info.flag~=nil then
    			dailyAnswerVoApi:setFlag(sData.data.meiridati.info.info.flag)
    		end

    	end
    	dailyAnswerVoApi:setDtype(sData.data.meiridati.info.info.dtype)
		dailyAnswerVoApi:setChoice(sData.data.meiridati.info.info.choice)
		dailyAnswerVoApi:setRank(sData.data.meiridati.info.rank)
		dailyAnswerVoApi:setScore(sData.data.meiridati.info.score)
    	dailyAnswerVoApi:setTime(sData.ts)
    	dailyAnswerVoApi:setNowRank(sData.data.meiridati.nowRank)


    	local function callBack1(fn,data)
    		local ret,sData = base:checkServerData(data)
    	
	    	if ret==true then
	    		if sData.data==nil then 
	    			return        		                  
	            end
	    	end
	    	if sData.data and sData.data.meiridati and sData.data.meiridati.titlelist then
		    	dailyAnswerVoApi:setQuestionList(sData.data.meiridati.titlelist)
		    end
	    	
    		self:initLayer()
    	end 	
		socketHelper:dailyAnswerGetTitlelist(callBack1)
    end

	socketHelper:dailyAnswerGetUserStatus(callback)
	return self.bgLayer
end

function dailyAnswerTab1:initLayer()
	self:checkStartState(dailyAnswerVoApi:getTime())

	local function itemTouch()
		PlayEffect(audioCfg.mouseClick)
	    local tabStr={}
	    local td=smallDialog:new()
	    local vo =dailyActivityVoApi:getActivityVo("dailychoice")
	    local time1 = string.format("%02d:%02d",vo.st[1],vo.st[2])
	    tabStr = {"\n",getlocal("dailyAnswer_tab1_instruction3"),"\n",getlocal("dailyAnswer_tab1_instruction2"),"\n",getlocal("dailyAnswer_tab1_instruction1",{time1}),"\n"}
	    local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,nil)
	    sceneGame:addChild(dialog,self.layerNum+1)
	end

	local menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",itemTouch,nil,nil,0)
	menuItemDesc:setAnchorPoint(ccp(0,1))
	menuItemDesc:setScale(0.8)
	local menuDesc=CCMenu:createWithItem(menuItemDesc)
	menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
	menuDesc:setPosition(ccp(15, G_VisibleSizeHeight - 215))
	self.bgLayer:addChild(menuDesc,3)

	local function touch()
    end
    local capInSet = CCRect(20, 20, 10, 10)
    local descBg =CCSprite:createWithSpriteFrameName("yh_dailyAnswer_descBg.png")
    descBg:setAnchorPoint(ccp(0.5,1))
    descBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-200))
    self.bgLayer:addChild(descBg,1)

    local characterSp = CCSprite:createWithSpriteFrameName("GuideCharacter_new.png") --姑娘
    characterSp:setAnchorPoint(ccp(0,0))
    characterSp:setPosition(ccp(20,0))
    characterSp:setScale(0.9)
    descBg:addChild(characterSp)

    local questionTitleStr = getlocal("dailyAnswer_tab1_question_title1")
    if self.numberOfQuestion~= 0 then
    	questionTitleStr = getlocal("dailyAnswer_tab1_question_title2",{self.numberOfQuestion})
    end

    -- local qLabelH = descBg:getContentSize().height-45
    -- local qLabelW = descBg:getContentSize().width-438
    self.questionTitle = GetTTFLabelWrap(questionTitleStr,20,CCSizeMake(300,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.questionTitle:setPosition(ccp(438,descBg:getContentSize().height-45))
    self.questionTitle:setColor(G_ColorYellowPro)
    self.questionTitle:setAnchorPoint(ccp(0.5,0.5))
    descBg:addChild(self.questionTitle)

    local vo =dailyActivityVoApi:getActivityVo("dailychoice")
    local time1 = string.format("%02d:%02d",vo.st[1],vo.st[2])
    local questionStr = getlocal("dailyAnswer_tab1_question_des",{time1})
    if self.numberOfQuestion~= 0 then
    	questionStr = self.tikuCfg[dailyAnswerVoApi:getQuestionById(self.numberOfQuestion)]
    end
    self.desTv, self.desLabel = G_LabelTableView(CCSizeMake(300, 140),questionStr,20,kCCTextAlignmentCenter)
 	descBg:addChild(self.desTv)
    self.desTv:setPosition(ccp(282,50))
    self.desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.desTv:setMaxDisToBottomOrTop(100)

    local function touchOneItem()
		if G_checkClickEnable()==false then
			do
			  return
			end
		else
		base.setWaitTime=G_getCurDeviceMillTime()
		end
        PlayEffect(audioCfg.mouseClick)

        -- 判断游戏是否结束
        if self.answerIsEnd then 
        	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dailyAnswer_tab1_btn_tip2"),30)
        	self:endOfQuestion()
        	return
        end

        -- 判断游戏是否开始
        if not self.answerIsStart then 
        	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dailyAnswer_tab1_btn_tip1"),30)
        	return
        end

        

        local function callback(fn,data)
        	local ret,sData = base:checkServerData(data)
        	
        	if ret==true then
        		if sData.data==nil then 
        			return        		                  
                end
        	end
        end
        local flag = self:checkTrueOrFalse(self.numberOfQuestion)
        if flag then 
        	socketHelper:dailyAnswerChoice(self.numberOfQuestion, 1, callback)
        else
        	 socketHelper:dailyAnswerChoice(self.numberOfQuestion, 2, callback)
        end
        self.selectOneItem:setEnabled(false)
        self.selectTwoItem:setVisible(false)
        self.alphaBgB:setVisible(true)
        self.selectedLabel:setString(getlocal("dailyAnswer_tab1_selected_answer",{"A"}))
        self.selectedLabel:setVisible(true)
        self.selectOneItem:setVisible(false)
        -- self.selectBg1:setVisible(true)
        self.answerATouch:setPosition(99999,99999)
		self.answerBTouch:setPosition(99999,99999)
		
	end
	self.selectOneItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",touchOneItem,nil,getlocal("dailyAnswer_tab1_btn"),30)
	self.selectOneItem:setAnchorPoint(ccp(0,0))
	self.selectOneItem:setScale(180/self.selectOneItem:getContentSize().width)
	local selectOneBtn=CCMenu:createWithItem(self.selectOneItem);
	selectOneBtn:setTouchPriority(-(self.layerNum-1)*20-4);
	local oneBtnWidth = 70
	if G_getCurChoseLanguage() =="de" or G_getCurChoseLanguage() =="en" then
		oneBtnWidth =30
	end
	selectOneBtn:setPosition(ccp(oneBtnWidth,40))
	self.bgLayer:addChild(selectOneBtn)

	local function touchTwoItem()
		if G_checkClickEnable()==false then
			do
			  return
			end
		else
		base.setWaitTime=G_getCurDeviceMillTime()
		end
        PlayEffect(audioCfg.mouseClick)

        -- 判断游戏是否结束
        if self.answerIsEnd then 
        	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dailyAnswer_tab1_btn_tip2"),30)
        	self:endOfQuestion()
        	return
        end

        -- 判断游戏是否开始
        if not self.answerIsStart then 
        	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dailyAnswer_tab1_btn_tip1"),30)
        	return
        end        

        local function callback(fn,data)
        	local ret,sData = base:checkServerData(data)

        	if ret==true then
        		if sData.data==nil then 
        			return        		                  
                end
        	end

        end
        local flag = self:checkTrueOrFalse(self.numberOfQuestion)
        if flag then 
        	socketHelper:dailyAnswerChoice(self.numberOfQuestion, 2, callback)
        else
        	 socketHelper:dailyAnswerChoice(self.numberOfQuestion, 1, callback)
        end
        self.selectTwoItem:setEnabled(false)
        self.selectOneItem:setVisible(false)
        self.alphaBgA:setVisible(true)
        self.selectedLabel:setString(getlocal("dailyAnswer_tab1_selected_answer",{"B"}))
        self.selectedLabel:setVisible(true)
        self.selectTwoItem:setVisible(false)
        -- self.selectBg2:setVisible(true)
        self.answerATouch:setPosition(99999,99999)
		self.answerBTouch:setPosition(99999,99999)
       
	end
	self.selectTwoItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",touchTwoItem,nil,getlocal("dailyAnswer_tab1_btn"),30)
	self.selectTwoItem:setAnchorPoint(ccp(1,0))
	self.selectTwoItem:setScale(180/self.selectTwoItem:getContentSize().width)
	local selectTwoBtn=CCMenu:createWithItem(self.selectTwoItem);
	selectTwoBtn:setTouchPriority(-(self.layerNum-1)*20-4);
	local twoBtnWidth = 70
	if G_getCurChoseLanguage() =="de" or G_getCurChoseLanguage() =="en" then
		twoBtnWidth =30
	end
	selectTwoBtn:setPosition(ccp(self.bgLayer:getContentSize().width-twoBtnWidth,40))
	self.bgLayer:addChild(selectTwoBtn) 

    local bgHeight = 388
    if G_isIphone5() then
    	bgHeight = 388 + 150
    end
	local bgA = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
	local bgB = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
	bgA:setContentSize(CCSizeMake(270,bgHeight))
	bgB:setContentSize(CCSizeMake(270,bgHeight))
	bgA:setAnchorPoint(ccp(0,1))
	bgB:setAnchorPoint(ccp(1,1))
	bgA:setPosition(12,descBg:getPositionY()-descBg:getContentSize().height)
	bgB:setPosition(self.bgLayer:getContentSize().width-12,descBg:getPositionY()-descBg:getContentSize().height)
	self.bgLayer:addChild(bgA)
	self.bgLayer:addChild(bgB)
	self.alphaBgA = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),function()end)
	self.alphaBgB = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),function()end)
	self.alphaBgA:setContentSize(CCSizeMake(bgA:getContentSize().width-2,bgA:getContentSize().height-2))
	self.alphaBgB:setContentSize(CCSizeMake(bgB:getContentSize().width-2,bgB:getContentSize().height-2))
	self.alphaBgA:setPosition(bgA:getContentSize().width/2,bgA:getContentSize().height/2)
	self.alphaBgB:setPosition(bgB:getContentSize().width/2,bgB:getContentSize().height/2)
	bgA:addChild(self.alphaBgA,20)
	bgB:addChild(self.alphaBgB,20)
	self.alphaBgA:setVisible(false)
	self.alphaBgB:setVisible(false)

	local answerLb1Bg = LuaCCScale9Sprite:createWithSpriteFrameName("newRankTitleBg.png",CCRect(4,4,1,1),function()end)
	local answerLb2Bg = LuaCCScale9Sprite:createWithSpriteFrameName("newRankTitleBg.png",CCRect(4,4,1,1),function()end)
	answerLb1Bg:setContentSize(CCSizeMake(266,80))
	answerLb2Bg:setContentSize(CCSizeMake(266,80))
	answerLb1Bg:setAnchorPoint(ccp(0.5,1))
	answerLb2Bg:setAnchorPoint(ccp(0.5,1))
	answerLb1Bg:setPosition(bgA:getContentSize().width/2,bgA:getContentSize().height-2)
	answerLb2Bg:setPosition(bgB:getContentSize().width/2,bgB:getContentSize().height-2)
	bgA:addChild(answerLb1Bg)
	bgB:addChild(answerLb2Bg)

	self.answerATouch = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),touchOneItem)
	self.answerBTouch = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),touchTwoItem)
	self.answerATouch:setContentSize(answerLb1Bg:getContentSize())
	self.answerBTouch:setContentSize(answerLb2Bg:getContentSize())
	self.answerATouch:setTouchPriority(-(self.layerNum-1)*20-4)
	self.answerBTouch:setTouchPriority(-(self.layerNum-1)*20-4)
	self.answerATouch:setAnchorPoint(ccp(0,0))
	self.answerBTouch:setAnchorPoint(ccp(0,0))
	self.answerATouch:setOpacity(0)
	self.answerBTouch:setOpacity(0)
	answerLb1Bg:addChild(self.answerATouch)
	answerLb2Bg:addChild(self.answerBTouch)

	local answerStr1 = getlocal("dailyAnswer_tab1_answer1",{getlocal("dailyAnswer_tab1_answer_tip")})
	if self.numberOfQuestion~=0 then
		answerStr1 = getlocal("dailyAnswer_tab1_answer1",{self.tikuCfg[dailyAnswerVoApi:getAnswerLeftById(self.numberOfQuestion)]})
	end

	self.answerLabel1=GetTTFLabelWrap(answerStr1,20,CCSizeMake(answerLb1Bg:getContentSize().width-10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	answerLb1Bg:addChild(self.answerLabel1)
	self.answerLabel1:setPosition(ccp(answerLb1Bg:getContentSize().width/2,answerLb1Bg:getContentSize().height/2))

	local answerStr2 = getlocal("dailyAnswer_tab1_answer2",{getlocal("dailyAnswer_tab1_answer_tip")})
	if self.numberOfQuestion~=0 then
		answerStr2 = getlocal("dailyAnswer_tab1_answer2",{self.tikuCfg[dailyAnswerVoApi:getAnswerRightById(self.numberOfQuestion)]})

	end
	self.answerLabel2 = GetTTFLabelWrap(answerStr2,20,CCSizeMake(answerLb2Bg:getContentSize().width-10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	answerLb2Bg:addChild(self.answerLabel2)
	self.answerLabel2:setPosition(ccp(answerLb2Bg:getContentSize().width/2,answerLb2Bg:getContentSize().height/2))

	-- local countDownSp = CCSprite:createWithSpriteFrameName("yh_dailyAnswer_numBg.png")
	local countDownSp = LuaCCScale9Sprite:createWithSpriteFrameName("yh_dailyAnswer_numBg.png",CCRect(22,62,20,25),function()end)
	countDownSp:setContentSize(CCSizeMake(countDownSp:getContentSize().width,bgA:getContentSize().height))
	countDownSp:setAnchorPoint(ccp(0.5,1))
	countDownSp:setPosition(self.bgLayer:getContentSize().width/2, descBg:getPositionY()-descBg:getContentSize().height)
	self.bgLayer:addChild(countDownSp)

	-- 倒计时label
	local countDownStr="∞"
	if self.questionCountDownNum then
		self.countDownStr = self.questionCountDownNum
	end
	if self.resultCountDownNum then
		self.countDownStr = self.resultCountDownNum
	end
	if self.startCountDownNum then
		self.countDownStr = self.startCountDownNum
	end
	self.countDownLabel = GetTTFLabel(countDownStr,30)
	countDownSp:addChild(self.countDownLabel)
	self.countDownLabel:setPosition(ccp(countDownSp:getContentSize().width/2,countDownSp:getContentSize().height-30))

	self.selectedLabel = GetTTFLabel(getlocal("dailyAnswer_tab1_unselected_answer"),28)
	self.selectedLabel:setPosition(self.bgLayer:getContentSize().width/2,75)
	self.bgLayer:addChild(self.selectedLabel)
	self.selectedLabel:setVisible(false)
	
	local yingH = 255
	if (G_isIphone5()) then
		yingH = 350
	end

	local function touchPaihang()
	end
	local paihangCh = 290
	if (G_isIphone5()) then
		paihangCh = 450
	end

	--当前人数
	local curCountBg1 = LuaCCScale9Sprite:createWithSpriteFrameName("newListItemBg.png",CCRect(4,4,1,1),function()end)
	local curCountBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("newListItemBg.png",CCRect(4,4,1,1),function()end)
	curCountBg1:setContentSize(CCSizeMake(266,36))
	curCountBg2:setContentSize(CCSizeMake(266,36))
	curCountBg1:setAnchorPoint(ccp(0.5,1))
	curCountBg2:setAnchorPoint(ccp(0.5,1))
	curCountBg1:setPosition(bgA:getContentSize().width/2,answerLb1Bg:getPositionY()-answerLb1Bg:getContentSize().height)
	curCountBg2:setPosition(bgB:getContentSize().width/2,answerLb2Bg:getPositionY()-answerLb2Bg:getContentSize().height)
	bgA:addChild(curCountBg1)
	bgB:addChild(curCountBg2)

	local recentAnswerStr1 = getlocal("dailyAnswer_tab1_recentAnswer",{0})
	local recentAnswerStr2 = getlocal("dailyAnswer_tab1_recentAnswer",{0})
	if self:checkTrueOrFalse(self.numberOfQuestion) then
		recentAnswerStr1 = getlocal("dailyAnswer_tab1_recentAnswer",{dailyAnswerVoApi:getTrueAnswerNum(self.numberOfQuestion)})
		recentAnswerStr2 = getlocal("dailyAnswer_tab1_recentAnswer",{dailyAnswerVoApi:getFalseAnswerNum(self.numberOfQuestion)})
	else
		recentAnswerStr1 = getlocal("dailyAnswer_tab1_recentAnswer",{dailyAnswerVoApi:getFalseAnswerNum(self.numberOfQuestion)})
		recentAnswerStr2 = getlocal("dailyAnswer_tab1_recentAnswer",{dailyAnswerVoApi:getTrueAnswerNum(self.numberOfQuestion)})
	end

	self.recentAnswer1Label = GetTTFLabel(recentAnswerStr1,20)
	curCountBg1:addChild(self.recentAnswer1Label)
	self.recentAnswer1Label:setPosition(ccp(curCountBg1:getContentSize().width/2,curCountBg1:getContentSize().height/2))

	self.recentAnswer2Label = GetTTFLabel(recentAnswerStr2,20)
	curCountBg2:addChild(self.recentAnswer2Label)
	self.recentAnswer2Label:setPosition(ccp(curCountBg2:getContentSize().width/2,curCountBg2:getContentSize().height/2))


	-- local paihangBg1 = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touchPaihang)
	-- paihangBg1:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width/2-50, paihangCh))
	-- paihangBg1:setPosition(ccp(self.bgLayer:getContentSize().width/4,yingH))
	-- self.bgLayer:addChild(paihangBg1)
	-- self.tvSize = CCSizeMake(paihangBg1:getContentSize().width-10,paihangBg1:getContentSize().height-20)
	self.tvSize = CCSizeMake(bgA:getContentSize().width-10,curCountBg1:getPositionY()-curCountBg1:getContentSize().height-2)

	-- self.selectBg1 = LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBg.png",CCRect(20, 20, 10, 10),touchPaihang)
 --    self.selectBg1:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width/2-50, paihangCh))
 --    self.selectBg1:setPosition(ccp(paihangBg1:getContentSize().width/2,paihangBg1:getContentSize().height/2))
 --    paihangBg1:addChild(self.selectBg1)
 --    self.selectBg1:setVisible(false)
	

	self.animiSp1 = LuaCCScale9Sprite:createWithSpriteFrameName("arrange1.png",CCRect(20, 20, 10, 10),touchPaihang)
	self.animiSp1:setContentSize(bgA:getContentSize())
	self.animiSp1:setPosition(ccp(bgA:getContentSize().width/2,bgA:getContentSize().height/2))
	bgA:addChild(self.animiSp1,10)
	self.animiSp1:setVisible(false)
	


	local function callBack1(...)
		return self:eventHandler1(...)
	end
	local hd1= LuaEventHandler:createHandler(callBack1)
 	self.tv1=LuaCCTableView:createWithEventHandler(hd1,self.tvSize,nil)
	self.tv1:setAnchorPoint(ccp(0,0))
	self.tv1:setPosition(ccp(5,2))
	self.tv1:setTableViewTouchPriority(-(self.layerNum-1)*20-6)
	self.tv1:setMaxDisToBottomOrTop(100)
	bgA:addChild(self.tv1,1)


	self.notStartLabel1 = GetTTFLabel(getlocal("dailyAnswer_tab1_question_title1"),30)
	self.notStartLabel1:setPosition(bgA:getContentSize().width/2,bgA:getContentSize().height/2)
	self.notStartLabel1:setColor(G_ColorYellowPro)
	bgA:addChild(self.notStartLabel1)


	-- local paihangBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touchPaihang)
	-- paihangBg2:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width/2-50, paihangCh))
	-- paihangBg2:setPosition(ccp(self.bgLayer:getContentSize().width/4*3,yingH))
	-- self.bgLayer:addChild(paihangBg2)

	-- self.selectBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBg.png",CCRect(20, 20, 10, 10),touchPaihang)
 --    self.selectBg2:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width/2-50, paihangCh))
 --    self.selectBg2:setPosition(ccp(paihangBg2:getContentSize().width/2,paihangBg2:getContentSize().height/2))
 --    paihangBg2:addChild(self.selectBg2)
 --    self.selectBg2:setVisible(false)

    self.animiSp2 = LuaCCScale9Sprite:createWithSpriteFrameName("arrange1.png",CCRect(20, 20, 10, 10),touchPaihang)
	self.animiSp2:setContentSize(bgB:getContentSize())
	self.animiSp2:setPosition(ccp(bgB:getContentSize().width/2,bgB:getContentSize().height/2))
	bgB:addChild(self.animiSp2,10)
	self.animiSp2:setVisible(false)

	local function callBack2(...)
		return self:eventHandler2(...)
	end
	local hd2= LuaEventHandler:createHandler(callBack2)
 	self.tv2=LuaCCTableView:createWithEventHandler(hd2,self.tvSize,nil)
	self.tv2:setAnchorPoint(ccp(0,0))
	self.tv2:setPosition(ccp(5,2))
	self.tv2:setTableViewTouchPriority(-(self.layerNum-1)*20-6)
	self.tv2:setMaxDisToBottomOrTop(100)
	bgB:addChild(self.tv2,1)

	self.notStartLabel2 = GetTTFLabel(getlocal("dailyAnswer_tab1_question_title1"),30)
	self.notStartLabel2:setPosition(bgB:getContentSize().width/2,bgB:getContentSize().height/2)
	self.notStartLabel2:setColor(G_ColorYellowPro)
	bgB:addChild(self.notStartLabel2)

	if self.answerIsEnd or self.answerIsStart then
		self.notStartLabel1:setVisible(false)
		self.notStartLabel2:setVisible(false)		
	end

	if self.answerIsEnd or self.answerIsStart~=true then
		self.recentAnswer1Label:setVisible(false)
		self.recentAnswer2Label:setVisible(false)
	end

	-- local barH = paihangCh-38
	-- local barWScale = 0.67
	-- if (G_isIphone5()) then
	-- 	barH = paihangCh-100
	-- 	barWScale = 1.04
	-- end 
	local barH = paihangCh-38
	local barHScale = 1
	if (G_isIphone5()) then
		barHScale = 1.45
	end

	-- 进度条
	AddProgramTimer(countDownSp,ccp(countDownSp:getContentSize().width/2,0),110,nil,nil,"yh_dailyAnswer_barBg.png","yh_dailyAnswer_bar.png",111,nil,barHScale)
	self.loadingBar = tolua.cast(countDownSp:getChildByTag(110),"CCProgressTimer")
	self.loadingBarBg = tolua.cast(countDownSp:getChildByTag(111),"CCSprite")
	self.loadingBarBg:setPositionY(self.loadingBarBg:getContentSize().height*barHScale/2+3)
	self.loadingBar:setPositionY(self.loadingBarBg:getPositionY())
	self.loadingBar:setMidpoint(ccp(1,0))
	self.loadingBar:setBarChangeRate(ccp(0,1))
	self.loadingBar:setPercentage(100)

	local recentBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
	recentBg:setContentSize(CCSizeMake(634,50))
	recentBg:setAnchorPoint(ccp(0.5,1))
	recentBg:setPosition(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-160)
	self.bgLayer:addChild(recentBg,5)

	-- 当前积分
	local recentStr1 = getlocal("dailyAnswer_tab1_recentLabelNum",{dailyAnswerVoApi:getScore()})
	-- local recentStr2 = getlocal("dailyAnswer_tab1_recentLabelRank",{dailyAnswerVoApi:getNowRank()})
	-- if dailyAnswerVoApi:getNowRank()==0  then		
	-- 	recentStr2 = getlocal("dailyAnswer_tab1_recentLabelRank",{"--"})
	-- elseif dailyAnswerVoApi:getNowRank()>20 then
	-- 	recentStr2 = getlocal("dailyAnswer_tab1_recentLabelRank",{"20+"})	
	-- end
	local recentStr2 = tostring(dailyAnswerVoApi:getNowRank())
	if dailyAnswerVoApi:getNowRank()==0  then		
		recentStr2 = "--"
	elseif dailyAnswerVoApi:getNowRank()>meiridatiCfg.rewardlimit then
		recentStr2 = self.highRankStr
	end

	self.prevScore = dailyAnswerVoApi:getScore()
	self.prevRank = dailyAnswerVoApi:getNowRank()

	local recentPosWidth = 70
	if G_getCurChoseLanguage() =="de" or G_getCurChoseLanguage() =="en" then
		recentPosWidth = 110
	end

	self.recentLabelNum = GetTTFLabel(recentStr1,24)
	self.recentLabelNum:setPosition(ccp(90,recentBg:getContentSize().height/2))
	self.recentLabelNum:setAnchorPoint(ccp(0,0.5))
	-- self.bgLayer:addChild(self.recentLabelNum)
	recentBg:addChild(self.recentLabelNum)

	-- 当前排名
	local recentRandLb = GetTTFLabel(getlocal("dailyAnswer_tab1_recentLabelRank",{""}),24)
	recentRandLb:setAnchorPoint(ccp(0,0.5))
	recentRandLb:setPosition(recentBg:getContentSize().width/2+80,recentBg:getContentSize().height/2)
	recentBg:addChild(recentRandLb)
	self.recentLabelRank = GetTTFLabel(recentStr2,24)
	self.recentLabelRank:setPosition(ccp(recentRandLb:getPositionX()+recentRandLb:getContentSize().width,recentBg:getContentSize().height/2))
	self.recentLabelRank:setAnchorPoint(ccp(0,0.5))
	recentBg:addChild(self.recentLabelRank)

	if self.answerIsEnd then
		self:endOfQuestion()		
	end

	if dailyAnswerVoApi:getDtype()==self.numberOfQuestion and self.numberOfQuestion~=0 then
		local flag = self:checkTrueOrFalse(self.numberOfQuestion)
		self.answerATouch:setPosition(99999,99999)
		self.answerBTouch:setPosition(99999,99999)
		self.selectOneItem:setVisible(false)
		self.selectTwoItem:setVisible(false)
		if dailyAnswerVoApi:getChoice()==1 then
			if flag then
				self.selectOneItem:setEnabled(false)
				self.alphaBgB:setVisible(true)
				self.selectedLabel:setString(getlocal("dailyAnswer_tab1_selected_answer",{"A"}))
			else
				self.selectTwoItem:setEnabled(false)
				self.alphaBgA:setVisible(true)
				self.selectedLabel:setString(getlocal("dailyAnswer_tab1_selected_answer",{"B"}))
			end
		else
			if flag then
				self.selectTwoItem:setEnabled(false)
				self.alphaBgA:setVisible(true)
				self.selectedLabel:setString(getlocal("dailyAnswer_tab1_selected_answer",{"B"}))
			else
				self.selectOneItem:setEnabled(false)
				self.alphaBgB:setVisible(true)
				self.selectedLabel:setString(getlocal("dailyAnswer_tab1_selected_answer",{"A"}))
			end
		end
        self.selectedLabel:setVisible(true)
	end


end

function dailyAnswerTab1:eventHandler1(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return self.tv1Num
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(self.tvSize.width,36)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease() 

		local cellHeight = 36
		local flag = self:checkTrueOrFalse(self.numberOfQuestion)
		local list
		if flag then 
			list = dailyAnswerVoApi:getTrueRankList(self.numberOfQuestion)
		else
			list = dailyAnswerVoApi:getFalseRankList(self.numberOfQuestion)
		end

		local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine4.png",CCRect(3,0,1,1),function ()end)
        lineSp:setContentSize(CCSizeMake(self.tvSize.width, 2))
        lineSp:ignoreAnchorPointForPosition(false);
        lineSp:setAnchorPoint(ccp(0.5,0))
        lineSp:setPosition(self.tvSize.width/2,0)
        cell:addChild(lineSp,1) 

        local rankSp=nil
        if tonumber(list[idx+1][3])==1 then
			rankSp=CCSprite:createWithSpriteFrameName("top1.png")
		elseif tonumber(list[idx+1][3])==2 then
			rankSp=CCSprite:createWithSpriteFrameName("top2.png")
		elseif tonumber(list[idx+1][3])==3 then
			rankSp=CCSprite:createWithSpriteFrameName("top3.png")
		end

		if rankSp~=nil then
			cell:addChild(rankSp)
			rankSp:setAnchorPoint(ccp(0,0.5))
			rankSp:setPosition(ccp(0,cellHeight/2))
			rankSp:setScale(36/rankSp:getContentSize().height)
		else
			local rankNum = GetTTFLabel(list[idx+1][3],20)
			cell:addChild(rankNum)
			rankNum:setAnchorPoint(ccp(0,0.5))
			rankNum:setPosition(ccp(5,cellHeight/2))
		end

         -- local ranklabel = GetTTFLabelWrap(list[idx+1][1],20,CCSizeMake(self.tvSize.width-10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
         local ranklabel = GetTTFLabel(list[idx+1][1],20)
         cell:addChild(ranklabel)
         ranklabel:setAnchorPoint(ccp(0,0.5))
         ranklabel:setPosition(ccp(50,cellHeight/2))
		
		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then

	end
end

function dailyAnswerTab1:eventHandler2(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return self.tv2Num
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(self.tvSize.width,36)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease() 

		local cellHeight = 36
		local flag = self:checkTrueOrFalse(self.numberOfQuestion)
		local list
		if flag then 
			list = dailyAnswerVoApi:getFalseRankList(self.numberOfQuestion)
		else
			list = dailyAnswerVoApi:getTrueRankList(self.numberOfQuestion)
		end

		local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine4.png",CCRect(3,0,1,1),function ()end)
        lineSp:setContentSize(CCSizeMake(self.tvSize.width, 2))
        lineSp:ignoreAnchorPointForPosition(false);
        lineSp:setAnchorPoint(ccp(0.5,0))
        lineSp:setPosition(self.tvSize.width/2,0)
        cell:addChild(lineSp,1)

         local rankSp=nil
        if tonumber(list[idx+1][3])==1 then
			rankSp=CCSprite:createWithSpriteFrameName("top1.png")
		elseif tonumber(list[idx+1][3])==2 then
			rankSp=CCSprite:createWithSpriteFrameName("top2.png")
		elseif tonumber(list[idx+1][3])==3 then
			rankSp=CCSprite:createWithSpriteFrameName("top3.png")
		end

		if rankSp~=nil then
			cell:addChild(rankSp)
			rankSp:setAnchorPoint(ccp(0,0.5))
			rankSp:setPosition(ccp(0,cellHeight/2))
			rankSp:setScale(36/rankSp:getContentSize().height)
		else
			local rankNum = GetTTFLabel(list[idx+1][3],20)
			cell:addChild(rankNum)
			rankNum:setAnchorPoint(ccp(0,0.5))
			rankNum:setPosition(ccp(5,cellHeight/2))
		end

         -- local ranklabel = GetTTFLabelWrap(list[idx+1][1],25,CCSizeMake(self.tvSize.width-10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
         local ranklabel = GetTTFLabel(list[idx+1][1],20)
         cell:addChild(ranklabel)
         ranklabel:setAnchorPoint(ccp(0,0.5))
         ranklabel:setPosition(ccp(50,cellHeight/2))
		
		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then

	end
end

function dailyAnswerTab1:checkTrueOrFalse(questionNum)
	if questionNum==0 then 
		return
	end
	local str = dailyAnswerVoApi:getAnswerLeftById(questionNum)
	if str ~=nil then
		if string.sub(str,-1,-1)=="t" then
			return true
		end
	end
	return false
end

function dailyAnswerTab1:endOfQuestion()
	if self.tv1Num~=0 then
		self.tv1Num=0
		self.tv1:reloadData()
	end
	if self.tv2Num~=0 then
		self.tv2Num=0
		self.tv2:reloadData()
	end
	if self.questionTitle~=nil then
		if self.questionTitle:getString() ~= getlocal("dailyAnswer_tab1_question_title3") then
			self.questionTitle:setString(getlocal("dailyAnswer_tab1_question_title3"))
		end
	end
	if self.desLabel~=nil then
		if self.desLabel:getString() ~= getlocal("dailyAnswer_tab1_btn_tip2") then
			self.desLabel:setString(getlocal("dailyAnswer_tab1_btn_tip2"))
		end
	end
	if self.countDownLabel~=nil then
		if self.countDownLabel:getString() ~= "∞" then
			self.countDownLabel:setString("∞")
		end
	end

	if self.animiSp1~=nil then
		self.animiSp1:setVisible(false)
	end
	if self.animiSp2~=nil then
		self.animiSp2:setVisible(false)
	end

	if self.selectBg1~=nil then
		self.selectBg1:setVisible(false)
	end

	if self.selectBg2~=nil then
		self.selectBg2:setVisible(false)
	end

	if self.alphaBgA~=nil then
		self.alphaBgA:setVisible(false)
	end
	if self.alphaBgB~=nil then
		self.alphaBgB:setVisible(false)
	end

	if self.selectedLabel~=nil then
		self.selectedLabel:setVisible(false)
	end

	if self.loadingBar ~=nil then
		self.loadingBar:setPercentage(0)
	end
	if self.answerLabel1 ~=nil then
		self.answerLabel1:setVisible(false)
	end
	if self.answerLabel2 ~=nil then
		self.answerLabel2:setVisible(false)
	end
	if self.notStartLabel1 ~=nil  then
		self.notStartLabel1:setVisible(false)
	end
	if  self.notStartLabel2 ~=nil then
		self.notStartLabel2:setVisible(false)
	end
	if  self.recentAnswer1Label ~=nil then
		self.recentAnswer1Label:setVisible(false)
	end
	if  self.recentAnswer2Label ~=nil then
		self.recentAnswer2Label:setVisible(false)
	end
end

function dailyAnswerTab1:runTrueAction()
	local flag = self:checkTrueOrFalse(self.numberOfQuestion)
	if flag then
		animiSp=self.animiSp1
	else
		animiSp=self.animiSp2
	end
	if animiSp==nil then
		return
	end
	if animiSp~=nil then
		animiSp:setVisible(true)
	end

	if self.alphaBgA~=nil then
		self.alphaBgA:setVisible(false)
	end
	if self.alphaBgB~=nil then
		self.alphaBgB:setVisible(false)
	end
	
	-- local blinkAct = CCBlink:create(4, 8)
	-- local function callBackAct()
	-- 	animiSp:setVisible(false)
	-- end
	-- local callFunc = CCCallFunc:create(callBackAct)
	-- local seqAct = CCSequence:createWithTwoActions(blinkAct,callFunc)
	-- animiSp:runAction(seqAct)
end

function dailyAnswerTab1:checkNumberOfQuestion(ts)
	local vo =dailyActivityVoApi:getActivityVo("dailychoice")
	local openTime = vo.st[1]*60*60+vo.st[2]*60
	local answerIsStart=nil
	local answerIsEnd =nil
	local startCountDownNum=nil
	local numberOfQuestion=nil
	local questionCountDownNum=nil
	local resultCountDownNum=nil
-- 
	if ts<G_getWeeTs(ts)+openTime-meiridatiCfg.lastTime then
		answerIsStart=false
		answerIsEnd = false
		startCountDownNum="∞"
		numberOfQuestion = 0
		
	end

	if ts>=G_getWeeTs(ts)+openTime-meiridatiCfg.lastTime and ts<G_getWeeTs(ts)+openTime then
		answerIsStart=false
		answerIsEnd = false

		startCountDownNum = G_getWeeTs(ts)+openTime-ts
		numberOfQuestion = 0
		
	end

	if ts>=G_getWeeTs(ts)+openTime+20*(meiridatiCfg.choiceTime+meiridatiCfg.resultTime) then
		answerIsStart=false
		answerIsEnd = true

		startCountDownNum="∞"
		numberOfQuestion = 0
		
	end

	for i=1,20 do
		if ts>=G_getWeeTs(ts)+openTime+(i-1)*(meiridatiCfg.choiceTime+meiridatiCfg.resultTime) and ts<=G_getWeeTs(ts)+openTime+i*meiridatiCfg.choiceTime+(i-1)*meiridatiCfg.resultTime then
			
			answerIsStart=true
			answerIsEnd = false

			questionCountDownNum = G_getWeeTs(ts)+openTime+i*meiridatiCfg.choiceTime+(i-1)*meiridatiCfg.resultTime-ts
			numberOfQuestion = i
			
		end

		if ts>G_getWeeTs(ts)+openTime+i*meiridatiCfg.choiceTime+(i-1)*meiridatiCfg.resultTime and ts<=G_getWeeTs(ts)+openTime+i*meiridatiCfg.choiceTime+i*meiridatiCfg.resultTime then
			answerIsStart=true
			answerIsEnd = false
	
			resultCountDownNum = G_getWeeTs(ts)+openTime+i*meiridatiCfg.choiceTime+i*meiridatiCfg.resultTime-ts
			numberOfQuestion = i
			
		end
	end
	return numberOfQuestion,questionCountDownNum,startCountDownNum,resultCountDownNum,answerIsEnd,answerIsStart
	

end

function dailyAnswerTab1:checkStartState(ts)
	local vo =dailyActivityVoApi:getActivityVo("dailychoice")
	local openTime = vo.st[1]*60*60+vo.st[2]*60

	if ts<G_getWeeTs(ts)+openTime-meiridatiCfg.lastTime then
		self.answerIsStart=false
		self.answerIsEnd = false
		self.iscomputingResult=false
		self.startCountDownNum="∞"
		self.numberOfQuestion = 0
		return
	end

	if ts>=G_getWeeTs(ts)+openTime-meiridatiCfg.lastTime and ts<G_getWeeTs(ts)+openTime then
		self.answerIsStart=false
		self.answerIsEnd = false
		self.iscomputingResult=false
		self.startCountDownNum = G_getWeeTs(ts)+openTime-ts
		self.numberOfQuestion = 0

		
		return
	end

	if ts>=G_getWeeTs(ts)+openTime+20*(meiridatiCfg.choiceTime+meiridatiCfg.resultTime) then
		self.answerIsStart=false
		self.answerIsEnd = true
		self.iscomputingResult=false
		self.startCountDownNum="∞"
		self.numberOfQuestion = 0
		return
	end

	for i=1,20 do
		if ts>=G_getWeeTs(ts)+openTime+(i-1)*(meiridatiCfg.choiceTime+meiridatiCfg.resultTime) and ts<=G_getWeeTs(ts)+openTime+i*meiridatiCfg.choiceTime+(i-1)*meiridatiCfg.resultTime then
			
			self.answerIsStart=true
			self.answerIsEnd = false
			self.iscomputingResult=false
			self.questionCountDownNum = G_getWeeTs(ts)+openTime+i*meiridatiCfg.choiceTime+(i-1)*meiridatiCfg.resultTime-ts
			self.numberOfQuestion = i

			
			return
		end

		if ts>G_getWeeTs(ts)+openTime+i*meiridatiCfg.choiceTime+(i-1)*meiridatiCfg.resultTime and ts<=G_getWeeTs(ts)+openTime+i*meiridatiCfg.choiceTime+i*meiridatiCfg.resultTime then
			self.answerIsStart=true
			self.answerIsEnd = false
			self.iscomputingResult=true
			self.resultCountDownNum = G_getWeeTs(ts)+openTime+i*meiridatiCfg.choiceTime+i*meiridatiCfg.resultTime-ts
			self.numberOfQuestion = i
			self:updataSelcetItem(false)

			
			return
		end
	end
	
end

function dailyAnswerTab1:tick()	
	if self.answerIsEnd then
		if self.selectBg1~=nil then
			self.selectBg1:setVisible(false)
		end
		if self.selectBg2~=nil then
			self.selectBg2:setVisible(false)
		end
		if self.alphaBgA~=nil then
			self.alphaBgA:setVisible(false)
		end
		if self.alphaBgB~=nil then
			self.alphaBgB:setVisible(false)
		end
		return
	end	

	local numberOfQuestion
	local questionCountDownNum
	local startCountDownNum
	local resultCountDownNum
	local answerIsEnd
	local answerIsStart

	numberOfQuestion,questionCountDownNum,startCountDownNum,resultCountDownNum,answerIsEnd,answerIsStart=self:checkNumberOfQuestion(base.datiTime)

	if answerIsEnd then
		if self.selectBg1~=nil then
			self.selectBg1:setVisible(false)
		end
		if self.selectBg2~=nil then
			self.selectBg2:setVisible(false)
		end
		if self.alphaBgA~=nil then
			self.alphaBgA:setVisible(false)
		end
		if self.alphaBgB~=nil then
			self.alphaBgB:setVisible(false)
		end
		self:endOfQuestion()
		return
	end

	if self.answerIsEnd and self.resultCountDownNum~=nil and self.resultCountDownNum<=1 or math.abs(numberOfQuestion-self.numberOfQuestion)>=20 or self.numberOfQuestion==21 then
		self:endOfQuestion()
		return
	end

	if  math.abs(numberOfQuestion-self.numberOfQuestion)>1 then
		self.numberOfQuestion=numberOfQuestion
		self.questionCountDownNum=questionCountDownNum
		self.startCountDownNum=startCountDownNum
		self.resultCountDownNum=resultCountDownNum
		self:tongbuRefresh(true)
		self.nowTime=base.datiTime
		return
	end

	local quetioncha = 0
	local resultcha = 0
	local statcha = 0

	if questionCountDownNum~=nil and self.questionCountDownNum then
		if math.abs(questionCountDownNum-self.questionCountDownNum)>=5 or self.numberOfQuestion~=numberOfQuestion  then
			local flag=false
			if self.numberOfQuestion~=numberOfQuestion then
				flag=true
			end
			self.numberOfQuestion=numberOfQuestion
			self.questionCountDownNum=questionCountDownNum
			self.startCountDownNum=startCountDownNum
			self.resultCountDownNum=resultCountDownNum
			self:tongbuRefresh(flag)
			self.nowTime=base.datiTime
			return
		end
	end

	if startCountDownNum or self.startCountDownNum then
		if type(startCountDownNum)=="number" and type(self.startCountDownNum)=="number" and  math.abs(startCountDownNum-self.startCountDownNum)>=5 then
			self.numberOfQuestion=numberOfQuestion
			self.questionCountDownNum=questionCountDownNum
			self.startCountDownNum=startCountDownNum
			self.resultCountDownNum=resultCountDownNum
			self:tongbuRefresh(false)
			self.nowTime=base.datiTime
			return
		end
	end

	if self.startCountDownNum and type(self.startCountDownNum)=="number" and self.startCountDownNum>3 and math.abs(numberOfQuestion-self.numberOfQuestion)>=1 then
		self.numberOfQuestion=numberOfQuestion
		self.questionCountDownNum=questionCountDownNum
		self.startCountDownNum=startCountDownNum
		self.resultCountDownNum=resultCountDownNum

		if self.notStartLabel1 then
			self.notStartLabel1:setVisible(false)
		end

		if self.notStartLabel2 then
			self.notStartLabel2:setVisible(false)
		end

		if self.recentAnswer1Label then
			self.recentAnswer1Label:setVisible(true)
		end

		if self.recentAnswer2Label then
			self.recentAnswer2Label:setVisible(true)
		end
		
		self.answerIsStart=answerIsStart
		self:tongbuRefresh(true)
		self.nowTime=base.datiTime
		return
	end

	

	if self.startCountDownNum~=nil  and type(self.startCountDownNum)=="number"  and self.startCountDownNum>=0 then
		if self.startCountDownNum==1 or self.startCountDownNum==0 then
			self.startCountDownNum=nil
			self.questionCountDownNum=meiridatiCfg.choiceTime
			self.numberOfQuestion= self.numberOfQuestion+1
			dailyAnswerVoApi:setNumberOfQuestion(self.numberOfQuestion)
			self.questionTitle:setString(getlocal("dailyAnswer_tab1_question_title2",{self.numberOfQuestion}))
			self.desLabel:setString(self.tikuCfg[dailyAnswerVoApi:getQuestionById(self.numberOfQuestion)])
			self.countDownLabel:setString(self.questionCountDownNum)
			self.loadingBar:setPercentage(100)
			self.notStartLabel1:setVisible(false)
			self.notStartLabel2:setVisible(false)
			self.answerLabel1:setString(getlocal("dailyAnswer_tab1_answer1",{self.tikuCfg[dailyAnswerVoApi:getAnswerLeftById(self.numberOfQuestion)]}))
			self.answerLabel2:setString(getlocal("dailyAnswer_tab1_answer2",{self.tikuCfg[dailyAnswerVoApi:getAnswerRightById(self.numberOfQuestion)]}))
			self.startCountDownNum=nil
			self.answerIsEnd = false
			self.answerIsStart = true
			self.recentAnswer1Label:setVisible(true)
			self.recentAnswer2Label:setVisible(true)
			return
		end
		self.startCountDownNum=self.startCountDownNum-1
		if self.loadingBar~=nil then
			self.loadingBar:setPercentage(100/meiridatiCfg.lastTime*self.startCountDownNum)
		end
		if self.countDownLabel~=nil then
			self.countDownLabel:setString(self.startCountDownNum)
		end
		
	end

	if self.questionCountDownNum~=nil and self.questionCountDownNum>=0 then
		if self.questionCountDownNum==0 then
			self.resultCountDownNum = meiridatiCfg.resultTime-1
			if self.countDownLabel~=nil then
				self.countDownLabel:setString(self.resultCountDownNum)
			end
			if self.loadingBar~=nil then
				self.loadingBar:setPercentage(100)
			end
			
			self:runTrueAction()			
			self.questionCountDownNum=nil
			local function callback(fn,data)
				local ret,sData = base:checkServerData(data)
    	
		    	if ret==true then
		    		if sData.data==nil then 
		    			return        		                  
		            end
		    	
			    	if sData.data and sData.data.meiridati and sData.data.meiridati.reward==1 then
			    		local rewardlist = FormatItem(meiridatiCfg.choiceReward)
			    		for k,v in pairs(rewardlist) do --加奖励
				    		G_addPlayerAward(v.type,v.key,v.id,v.num,false,true)
			    		end
			    		self:showEffect(function()
			    			G_showRewardTip(rewardlist)
			    		end)
			    	else
			    		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dailyAnswer_tab1_false_tip"),30)
			    	end
			    	if self.recentLabelNum~=nil then
			    		self.recentLabelNum:setString(getlocal("dailyAnswer_tab1_recentLabelNum",{sData.data.meiridati.score}))
			    		if sData.data.meiridati.score - self.prevScore > 0 then
			    			local addScore = GetTTFLabel("+"..(sData.data.meiridati.score - self.prevScore),24)
			    			addScore:setColor(G_ColorGreen)
			    			addScore:setAnchorPoint(ccp(0,0))
			    			addScore:setPosition(self.recentLabelNum:getPositionX()+self.recentLabelNum:getContentSize().width+3,0)
			    			self.recentLabelNum:getParent():addChild(addScore)
				    		local seq = CCSequence:createWithTwoActions(
				    				CCMoveBy:create(1,ccp(0,self.recentLabelNum:getParent():getContentSize().height-addScore:getContentSize().height)),
				    				CCCallFunc:create(function()
				    					addScore:removeFromParentAndCleanup(true)
				    				end)
				    			)
			    			addScore:runAction(seq)
			    		end
			    		self.prevScore = sData.data.meiridati.score
		    		end
		    		dailyAnswerVoApi:setScore(sData.data.meiridati.score) --设置当前积分

		    		if self.recentLabelRank then
			    		if sData.data.meiridati.nowRank==0 then
				    		self.recentLabelRank:setString("--")
			    		elseif sData.data.meiridati.nowRank>meiridatiCfg.rewardlimit then
				    		self.recentLabelRank:setString(self.highRankStr)
			    		else
				    		self.recentLabelRank:setString(tostring(sData.data.meiridati.nowRank))
			    		end
			    		if sData.data.meiridati.nowRank - self.prevRank ~= 0 and sData.data.meiridati.nowRank<=meiridatiCfg.rewardlimit then
			    			local seq = CCSequence:createWithTwoActions(CCScaleTo:create(1,1.2),CCScaleTo:create(1,1))
			    			self.recentLabelRank:runAction(seq)
			    			local arrowSp
			    			if (self.prevRank == 0) or (sData.data.meiridati.nowRank - self.prevRank < 0) then
				    			arrowSp = CCSprite:createWithSpriteFrameName("vipUpArrow.png")
				    		elseif sData.data.meiridati.nowRank - self.prevRank > 0 then
				    			arrowSp = CCSprite:createWithSpriteFrameName("yh_dailyAnswer_downArrow.png")
				    		end
				    		arrowSp:setAnchorPoint(ccp(0,0.5))
				    		arrowSp:setPosition(self.recentLabelRank:getPositionX()+self.recentLabelRank:getContentSize().width+3,self.recentLabelRank:getPositionY())
				    		self.recentLabelRank:getParent():addChild(arrowSp)
				    		arrowSp:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(2),CCCallFunc:create(function()
				    			arrowSp:removeFromParentAndCleanup(true)
				    		end)))
				    	end
			    		self.prevRank = sData.data.meiridati.nowRank
			    	end
	    		end
		    		

			end
			socketHelper:dailyAnswerGetChoiceStatus(callback)
			return
		end

		if self.animiSp1~=nil then
			self.animiSp1:setVisible(false)
		end

		if self.animiSp2~=nil then
			self.animiSp2:setVisible(false)
		end

		
		self.questionCountDownNum=self.questionCountDownNum-1
		if self.loadingBar~=nil then 
			self.loadingBar:setPercentage(100/meiridatiCfg.choiceTime*self.questionCountDownNum)
		end
		if self.countDownLabel~=nil then
			self.countDownLabel:setString(self.questionCountDownNum)
		end
	end

	if self.resultCountDownNum~=nil and self.resultCountDownNum>=0 then
		if self.resultCountDownNum==1 or self.resultCountDownNum==0 then
			self.questionCountDownNum=meiridatiCfg.choiceTime
			if self.nowTime and math.abs(self.nowTime-base.datiTime)<=2 and self.resultCountDownNum==0 then
			else
				self.numberOfQuestion= self.numberOfQuestion+1
			end
			self:updataSelcetItem(true)
			if self.numberOfQuestion>20 then
				-- self.numberOfQuestion=0
				self.answerIsEnd = true
				self.answerIsStart = false
				self:endOfQuestion()				
				return
			end
			if self.animiSp1~=nil then
				self.animiSp1:setVisible(false)
			end
			if self.animiSp2~=nil then
				self.animiSp2:setVisible(false)
			end

			if 	self.countDownLabel~=nil then
			self.countDownLabel:setString(meiridatiCfg.choiceTime)
			end

			if self.desLabel~=nil then
				self.desLabel:setString(self.tikuCfg[dailyAnswerVoApi:getQuestionById(self.numberOfQuestion)])
			end
			if self.questionTitle~=nil then 
				self.questionTitle:setString(getlocal("dailyAnswer_tab1_question_title2",{self.numberOfQuestion}))
			end
			if self.loadingBar~=nil then
				self.loadingBar:setPercentage(100)
			end

			if self.answerLabel1~=nil then
				self.answerLabel1:setString(getlocal("dailyAnswer_tab1_answer1",{self.tikuCfg[dailyAnswerVoApi:getAnswerLeftById(self.numberOfQuestion)]}))
			end		

			if self.answerLabel2~=nil then
				self.answerLabel2:setString(getlocal("dailyAnswer_tab1_answer2",{self.tikuCfg[dailyAnswerVoApi:getAnswerRightById(self.numberOfQuestion)]}))
			end
			
			if self.recentAnswer1Label~=nil then
				self.recentAnswer1Label:setString(getlocal("dailyAnswer_tab1_recentAnswer",{0}))
			end

			if self.recentAnswer2Label~=nil then
				self.recentAnswer2Label:setString(getlocal("dailyAnswer_tab1_recentAnswer",{0}))
			end			
			
			dailyAnswerVoApi:setNowRank(0)
			self.resultCountDownNum=nil
			dailyAnswerVoApi:setNumberOfQuestion(self.numberOfQuestion)

			if self.selectBg1~=nil then
				self.selectBg1:setVisible(false)
			end

			if self.selectBg2~=nil then
				self.selectBg2:setVisible(false)
			end		

			if self.alphaBgA~=nil then
				self.alphaBgA:setVisible(false)
			end
			if self.alphaBgB~=nil then
				self.alphaBgB:setVisible(false)
			end	

			if self.tv1~=nil then
				self.tv1Num=0
				self.tv1:reloadData()
			end

			if self.tv2~=nil then
				self.tv2Num=0			
				self.tv2:reloadData()
			end	
			return
		end

		self:runTrueAction()

		if self.selectOneItem~=nil and self.selectTwoItem~=nil then
			if self.selectOneItem:isEnabled() and self.selectTwoItem:isEnabled()  then
				self:updataSelcetItem(false)				
			end
		end
		self.resultCountDownNum = self.resultCountDownNum-1
		if self.loadingBar~= nil then 
			self.loadingBar:setPercentage(100/meiridatiCfg.resultTime*self.resultCountDownNum)
		end
		if 	self.countDownLabel~=nil then
			self.countDownLabel:setString(self.resultCountDownNum)
		end
		
	end
	self:updataRecentNum()
	self:updataTv()
	
end

function dailyAnswerTab1:showEffect(_callFunc)
	local frameSp=CCSprite:createWithSpriteFrameName("tisheng1.png")
    local frameArr=CCArray:create()
    for k=1,10 do
        local nameStr="tisheng"..k..".png"
        local frame=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        frameArr:addObject(frame)
    end
    local animation=CCAnimation:createWithSpriteFrames(frameArr)
    animation:setDelayPerUnit(0.1)
    local animate=CCAnimate:create(animation)
    frameSp:setAnchorPoint(ccp(0.5,0.5))
    frameSp:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
    frameSp:setScale(3.5)
    self.bgLayer:addChild(frameSp,50)
    local blendFunc=ccBlendFunc:new()
    blendFunc.src=GL_ONE
    blendFunc.dst=GL_ONE_MINUS_SRC_COLOR
    frameSp:setBlendFunc(blendFunc)
    -- local delayAction=CCDelayTime:create(1)
    local function showSp()
        frameSp:setOpacity(255)
    end
    local function removeSp()
        frameSp:removeFromParentAndCleanup(true)
        if _callFunc then
        	_callFunc()
        end
    end
    local showCallFunc=CCCallFuncN:create(showSp)
    local removeCallFunc=CCCallFuncN:create(removeSp)
    local acArr=CCArray:create()
    acArr:addObject(showCallFunc)
    acArr:addObject(animate)
    acArr:addObject(removeCallFunc)
    -- acArr:addObject(delayAction)
    local seq=CCSequence:create(acArr)
    frameSp:runAction(seq)
end

function dailyAnswerTab1:updataRecentNum()

	if self.numberOfQuestion==dailyAnswerVoApi:getNumberOfQuestion() and self.numberOfQuestion~=0 then
		local flag = self:checkTrueOrFalse(self.numberOfQuestion)
		if self.recentAnswer1Label~=nil then
			local str1 = self.recentAnswer1Label:getString()
		end
		if self.recentAnswer2Label~=nil then
			local str2 = self.recentAnswer2Label:getString()
		end
		

		if flag then
			if getlocal("dailyAnswer_tab1_recentAnswer",{dailyAnswerVoApi:getTrueAnswerNum(self.numberOfQuestion)}) ~= str1 and  self.recentAnswer1Label~=nil then
				self.recentAnswer1Label:setString(getlocal("dailyAnswer_tab1_recentAnswer",{dailyAnswerVoApi:getTrueAnswerNum(self.numberOfQuestion)}))
				
				
			end
			if getlocal("dailyAnswer_tab1_recentAnswer",{dailyAnswerVoApi:getFalseAnswerNum(self.numberOfQuestion)}) ~= str2 and self.recentAnswer2Label~=nil then
				self.recentAnswer2Label:setString(getlocal("dailyAnswer_tab1_recentAnswer",{dailyAnswerVoApi:getFalseAnswerNum(self.numberOfQuestion)}))
				
			end
		else
			if getlocal("dailyAnswer_tab1_recentAnswer",{dailyAnswerVoApi:getTrueAnswerNum(self.numberOfQuestion)}) ~= str2 and self.recentAnswer2Label~=nil then
				self.recentAnswer2Label:setString(getlocal("dailyAnswer_tab1_recentAnswer",{dailyAnswerVoApi:getTrueAnswerNum(self.numberOfQuestion)}))
			end
			if getlocal("dailyAnswer_tab1_recentAnswer",{dailyAnswerVoApi:getFalseAnswerNum(self.numberOfQuestion)}) ~= str1 and self.recentAnswer1Label~=nil then
				self.recentAnswer1Label:setString(getlocal("dailyAnswer_tab1_recentAnswer",{dailyAnswerVoApi:getFalseAnswerNum(self.numberOfQuestion)}))
			end
		end
	end
end

function dailyAnswerTab1:updataTv()

	if self.numberOfQuestion==dailyAnswerVoApi:getNumberOfQuestion() and self.numberOfQuestion~=0 then

			local flag = self:checkTrueOrFalse(self.numberOfQuestion)
			if flag then

				-- self.tv1Num = SizeOfTable(dailyAnswerVoApi:getTrueRankList(self.numberOfQuestion))
				-- self.tv2Num = SizeOfTable(dailyAnswerVoApi:getFalseRankList(self.numberOfQuestion))
				if self.tv1~=nil and self.tv1Num ~= SizeOfTable(dailyAnswerVoApi:getTrueRankList(self.numberOfQuestion)) then
					self.tv1Num=SizeOfTable(dailyAnswerVoApi:getTrueRankList(self.numberOfQuestion))
					self.tv1:reloadData()
				end
				if self.tv2~=nil and self.tv2Num ~= SizeOfTable(dailyAnswerVoApi:getFalseRankList(self.numberOfQuestion)) then
					self.tv2Num = SizeOfTable(dailyAnswerVoApi:getFalseRankList(self.numberOfQuestion))
					self.tv2:reloadData()
				end
				
			elseif flag==false then

				-- self.tv1Num = SizeOfTable(dailyAnswerVoApi:getFalseRankList(self.numberOfQuestion))
				-- self.tv2Num = SizeOfTable(dailyAnswerVoApi:getTrueRankList(self.numberOfQuestion))
				
				if self.tv1~=nil and self.tv1Num ~= SizeOfTable(dailyAnswerVoApi:getFalseRankList(self.numberOfQuestion)) then
					self.tv1Num = SizeOfTable(dailyAnswerVoApi:getFalseRankList(self.numberOfQuestion))
					self.tv1:reloadData()
				end
				if self.tv2~=nil and self.tv2Num ~= SizeOfTable(dailyAnswerVoApi:getTrueRankList(self.numberOfQuestion)) then
					self.tv2Num = SizeOfTable(dailyAnswerVoApi:getTrueRankList(self.numberOfQuestion))
					self.tv2:reloadData()
				end
			end
		end
end

-- 只有题号相差了刷新
function dailyAnswerTab1:tongbuRefresh(flag)
	if flag then
		dailyAnswerVoApi:setNumberOfQuestion(self.numberOfQuestion)
		if self.questionTitle then
			self.questionTitle:setString(getlocal("dailyAnswer_tab1_question_title2",{self.numberOfQuestion}))
		end
		if self.desLabel then
			self.desLabel:setString(self.tikuCfg[dailyAnswerVoApi:getQuestionById(self.numberOfQuestion)])
		end
		if self.answerLabel1~=nil then
			self.answerLabel1:setString(getlocal("dailyAnswer_tab1_answer1",{self.tikuCfg[dailyAnswerVoApi:getAnswerLeftById(self.numberOfQuestion)]}))
		end		

		if self.answerLabel2~=nil then
			self.answerLabel2:setString(getlocal("dailyAnswer_tab1_answer2",{self.tikuCfg[dailyAnswerVoApi:getAnswerRightById(self.numberOfQuestion)]}))
		end

		if self.resultCountDownNum and self.resultCountDownNum>1 then
			self:updataSelcetItem(false)
		else
			self:updataSelcetItem(true)
		end
		
		if self.selectBg1~=nil then
			self.selectBg1:setVisible(false)
		end

		if self.selectBg2~=nil then
			self.selectBg2:setVisible(false)
		end	
		if self.alphaBgA~=nil then
			self.alphaBgA:setVisible(false)
		end
		if self.alphaBgB~=nil then
			self.alphaBgB:setVisible(false)
		end	
	end
	self:updataRecentNum()
	self:updataTv()
	
end

function dailyAnswerTab1:updataSelcetItem(flag)
	if self.selectOneItem~= nil then
		self.selectOneItem:setEnabled(flag)
		self.selectOneItem:setVisible(flag)
	end
	if self.selectTwoItem~=nil then 
		self.selectTwoItem:setEnabled(flag)
		self.selectTwoItem:setVisible(flag)
	end
	if self.answerATouch~=nil then
		if flag==true then
			self.answerATouch:setPosition(0,0)
		else
			self.answerATouch:setPosition(99999,99999)
		end
	end
	if self.answerBTouch~=nil then
		if flag==true then
			self.answerBTouch:setPosition(0,0)
		else
			self.answerBTouch:setPosition(99999,99999)
		end
	end
	if self.selectedLabel~=nil then
		if flag==true then
			self.selectedLabel:setString(getlocal("dailyAnswer_tab1_unselected_answer"))
			self.selectedLabel:setVisible(false)
		else
			self.selectedLabel:setVisible(true)
		end
	end
end
function dailyAnswerTab1:dispose()
	self.bgLayer = nil
	self.layerNum = nil
	self.questionTitle = nil
	self.countDownLabel = nil
	self.loadingBar = nil
	self.loadingBarBg = nil
	self.recentLabelNum = nil
	self.recentLabelRank = nil
	self.answerLabel1=nil
	self.answerLabel2=nil
	self.notStartLabel1=nil
	self.notStartLabel2=nil
	self.recentAnswer1Label=nil
	self.recentAnswer2Label=nil
	self.selectedLabel=nil
	self.answerATouch=nil
	self.answerBTouch=nil
	self.selectBg1=nil
	self.selectBg2=nil
	self.alphaBgA=nil
	self.alphaBgB=nil
	self.tv1 = nil
	self.tv2 = nil
	self.tv1Num = nil
	self.tv2Num = nil
	self.prevScore = nil
	self.prevRank = nil
	self.answerIsStart = nil -- 游戏是否开始
	self.answerIsEnd = nil --游戏是否结束
	self.tikuCfg=nil
	self.nowTime=nil
	spriteController:removePlist("public/vipFinal.plist")
	spriteController:removeTexture("public/vipFinal.png")
	spriteController:removePlist("public/ltzdz/ltzdzSegUpImgs.plist")
    spriteController:removeTexture("public/ltzdz/ltzdzSegUpImgs.png")
end

