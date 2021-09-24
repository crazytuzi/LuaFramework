local TaskView=classGc(view,function(self,_subType)
	self.m_taskType=_subType
end)

local TAG_REWARD=1
local TAG_GET   =2
local TAG_NOGET =3
local m_isNoticRefresh=nil
local SYSID_ARRAY=
{
 [TAG_REWARD]=_G.Const.CONST_FUNC_OPEN_TASK_DAILY,
}

local REWARD_TIMES=_G.Const.CONST_TASK_REWARD_MAX_NUM
local CHEAT_MONEY=_G.Const.CONST_TASK_REWARD_FINISH_USE
local FRESH_MONEY=_G.Const.CONST_TASK_REWARD_REF_USE
local FRESH_GOODS=_G.Const.CONST_TASK_REWARD_REF_GID
local __fonsName=_G.FontName.Heiti
local P_SIZE_TASK=cc.size(395,76)
function TaskView.create(self)
	self.m_winSize=cc.Director:getInstance():getWinSize()

	self.m_normalView=require("mod.general.TabUpView")()
	self.m_rootLayer=self.m_normalView:create("任 务",true)

	local tempScene=cc.Scene:create()
    tempScene:addChild(self.m_rootLayer)

    local isFirstEnter=true
	local function onNodeEvent(event)
        if "enter"==event then
        	if isFirstEnter then
        		isFirstEnter=false
        	else
        		-- 刷新
        		local msg=REQ_REWARD_TASK_REQUEST()
      			_G.Network:send(msg)
			end
        end
    end
    tempScene:registerScriptHandler(onNodeEvent)

	self:init()
	return tempScene
end
function TaskView.init(self)
	self.di2kuanSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
    -- self.di2kuanSpr:setPreferredSize(cc.size(847,492))
    self.m_rootLayer:addChild(self.di2kuanSpr)

	self:initParams()
	self:initView()

	if self.m_taskType~=nil and (self.m_taskType==TAG_REWARD or self.m_taskType==TAG_GET or self.m_taskType==TAG_NOGET) then
		self:tabChuange(self.m_taskType)
		self.m_normalView:selectTagByTag(self.m_taskType)
	elseif #self.m_getArray>0 then
		self:tabChuange(TAG_GET)
		self.m_normalView:selectTagByTag(TAG_GET)
	elseif #self.m_nogetArray>0 then
		self:tabChuange(TAG_NOGET)
		self.m_normalView:selectTagByTag(TAG_NOGET)
	else
		self:tabChuange(TAG_REWARD)
		self.m_normalView:selectTagByTag(TAG_REWARD)
	end
end
function TaskView.initParams(self)
	self.m_nogetArray = {}--未接任务
    self.m_getArray   = {}--已接任务

    if not _G.GTaskProxy:getInitialized() then return end

    self.m_taskInfoList=_G.GTaskProxy:getTaskDataList()--所有的任务数据
    --分解
    for key, value in pairs( self.m_taskInfoList ) do
        if value.state == 1 or value.state == 2  then
            self.m_nogetArray[ #self.m_nogetArray + 1 ] = value
        elseif value.state == 3 or value.state == 4 then
            self.m_getArray[ #self.m_getArray + 1 ] = value
        end
    end

    self.m_rolePro=_G.GPropertyProxy:getMainPlay():getPro()
end

function TaskView.initView(self)
    local function closeFun()
    	self:closeWindow()
    end

    local function tabFun(tag)
    	local sysId=SYSID_ARRAY[tag]
		if _G.GOpenProxy:showSysNoOpenTips(sysId) then return false end
    	self:tabChuange(tag)
    end

    self.m_normalView:addCloseFun(closeFun)
	self.m_normalView:addTabFun(tabFun)

	self.m_normalView:addTabButton("已  接",TAG_GET)
	self.m_normalView:addTabButton("未  接",TAG_NOGET)
	self.m_normalView:addTabButton("修  行",TAG_REWARD)

	local rewardIconCount=_G.GOpenProxy:getSysIconNumber(_G.Const.CONST_FUNC_OPEN_TASK)
	if rewardIconCount>0 then
		self.m_normalView:setTagIconNum(TAG_REWARD,rewardIconCount)
	end

	self:createTaskInfo()

	local guideId=_G.GGuideManager:getCurGuideId()
	if guideId==_G.Const.CONST_NEW_GUIDE_SYS_DAILYTASK then
		local tabBtn=self.m_normalView:getTabBtnByTag(TAG_REWARD)
		_G.GGuideManager:initGuideView(self.m_rootLayer)
		_G.GGuideManager:registGuideData(1,tabBtn)
		_G.GGuideManager:runNextStep()

		self.m_guide_reward_view=true
		self.m_guideTab=TAG_REWARD

		local command=CGuideNoticHide()
      	controller:sendCommand(command)
	end
end
function TaskView.chuangIconNum(self,_sysId,_number)
	if _G.Const.CONST_FUNC_OPEN_TASK==_sysId then
		self.m_normalView:setTagIconNum(TAG_REWARD,_number)
	end
end

function TaskView.createTaskInfo(self)
	local infoNode=cc.Node:create()
	self.m_rootLayer:addChild(infoNode)
	self.m_panelInfoNode=infoNode
	self.m_panelInfoNode:setVisible(false)

	local infoSize=cc.size(445,476)
	local infoBg=ccui.Scale9Sprite:createWithSpriteFrameName("general_double.png")
	infoBg:setPreferredSize(infoSize)
	infoBg:setPosition(self.m_winSize.width/2+infoSize.width/2-28,infoSize.height/2+27)
	infoNode:addChild(infoBg)

	local posX      =30
	local fontSize  =20
	local yColor    =_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN)
	local lbColor   =_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE)
	local pbColor   =_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN)
	local rColor    =_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_RED)

	self.m_infoTypeLabel=_G.Util:createLabel("【主线】",fontSize+2)
	self.m_infoTypeLabel:setColor(yColor)
	self.m_infoTypeLabel:setPosition(posX-10,infoSize.height-40)
	self.m_infoTypeLabel:setAnchorPoint(cc.p(0,0.5))
	infoBg:addChild(self.m_infoTypeLabel)

	local infoTypeSize=self.m_infoTypeLabel:getContentSize()
	self.m_infoNamePosX=posX+infoTypeSize.width
	self.m_infoNameLabel=_G.Util:createLabel("",fontSize)
	self.m_infoNameLabel:setAnchorPoint(cc.p(0,0.5))
	self.m_infoNameLabel:setPosition(self.m_infoNamePosX,infoSize.height-40)
	self.m_infoNameLabel:setColor(yColor)
	infoBg:addChild(self.m_infoNameLabel)

	local infoNameSize=self.m_infoNameLabel:getContentSize()
	self.m_infoLimitLabel=_G.Util:createLabel("",fontSize)
	self.m_infoLimitLabel:setAnchorPoint(cc.p(0,0.5))
	self.m_infoLimitLabel:setPosition(self.m_infoNamePosX,infoSize.height-40)
	self.m_infoLimitLabel:setColor(rColor)
	infoBg:addChild(self.m_infoLimitLabel)

	self.m_infoInfoLabel=_G.Util:createLabel("",fontSize)
	self.m_infoInfoLabel:setDimensions(infoSize.width-50,0)
	self.m_infoInfoLabel:setAnchorPoint(cc.p(0,1))
	self.m_infoInfoLabel:setPosition(35,infoSize.height-60)
	self.m_infoInfoLabel:setColor(lbColor)
	infoBg:addChild(self.m_infoInfoLabel)

	local function guiCall(sender,eventType)
		if eventType==ccui.TouchEventType.ended then
			self:taskGuide()
		end
	end
	local guideBtn=gc.CButton:create()
    guideBtn:loadTextures("general_btn_gold.png")
    guideBtn:setPosition(infoSize.width-80,infoSize.height-115)
    guideBtn:addTouchEventListener(guiCall)
    guideBtn:setTitleFontSize(22)
    guideBtn:setTitleText("自动寻路")
    guideBtn:setTitleFontName(__fonsName)
    infoBg:addChild(guideBtn)

    local sNpcLabel =_G.Util:createLabel("发布 NPC:",fontSize)
    local eNpcLabel =_G.Util:createLabel("完成 NPC:",fontSize)
    local danduLabel=_G.Util:createLabel("任务进度:",fontSize)
    sNpcLabel :setAnchorPoint(cc.p(0,1))
    eNpcLabel :setAnchorPoint(cc.p(0,1))
    danduLabel:setAnchorPoint(cc.p(0,1))
    sNpcLabel :setColor(pbColor)
    eNpcLabel :setColor(pbColor)
    danduLabel:setColor(pbColor)

    infoBg:addChild(sNpcLabel)
    infoBg:addChild(eNpcLabel)
    infoBg:addChild(danduLabel)

    self.m_infoNpcStartLabel=_G.Util:createLabel("",fontSize)
    self.m_infoNpcEndLabel  =_G.Util:createLabel("",fontSize)
    self.m_infoNanDuLabel   =_G.Util:createLabel("",fontSize)
    self.m_infoJinDuLabel   =_G.Util:createLabel("",fontSize)
    self.m_infoNpcStartLabel:setAnchorPoint(cc.p(0,1))
    self.m_infoNpcEndLabel  :setAnchorPoint(cc.p(0,1))
    self.m_infoNanDuLabel   :setAnchorPoint(cc.p(0,1))
    self.m_infoJinDuLabel   :setAnchorPoint(cc.p(0,1))
    self.m_infoNpcStartLabel:setColor(lbColor)
	self.m_infoNpcEndLabel  :setColor(lbColor)
	self.m_infoNanDuLabel   :setColor(lbColor)
	self.m_infoJinDuLabel   :setColor(lbColor)

	infoBg:addChild(self.m_infoNpcStartLabel)
	infoBg:addChild(self.m_infoNpcEndLabel)
	infoBg:addChild(self.m_infoNanDuLabel)
	infoBg:addChild(self.m_infoJinDuLabel)

	local posY   =infoSize.height/2+55
	local nHeight=35
	local nnSize =danduLabel:getContentSize()
	sNpcLabel :setPosition(posX,posY)
	eNpcLabel :setPosition(posX,posY-nHeight)
	danduLabel:setPosition(posX,posY-nHeight*2)

	local tempX=posX+nnSize.width+10
	self.m_infoNanDuLabel:setLineBreakWithoutSpace(true)
	self.m_infoNanDuLabel:setDimensions(infoSize.width-tempX-5,0)
	self.m_infoNanDuLabel:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)

	self.m_infoNpcStartLabel:setPosition(tempX,posY)
	self.m_infoNpcEndLabel  :setPosition(tempX,posY-nHeight)
	self.m_infoNanDuLabel   :setPosition(tempX,posY-nHeight*2)
	self.m_infoJinDuLabel   :setPosition(tempX,posY-nHeight*3+3)

	local lineSpr1=ccui.Scale9Sprite:createWithSpriteFrameName("general_double_line.png")
	local lineSize=lineSpr1:getContentSize()
	lineSpr1:setPreferredSize(cc.size(380,lineSize.height))
	lineSpr1:setPosition(infoSize.width/2,infoSize.height/2+75)
	infoBg:addChild(lineSpr1)

	local lineSpr2=ccui.Scale9Sprite:createWithSpriteFrameName("general_double_line.png")
	lineSpr2:setPreferredSize(cc.size(380,lineSize.height))
	lineSpr2:setPosition(infoSize.width/2,150)
	infoBg:addChild(lineSpr2)

	local rewardLabel=_G.Util:createLabel("任务奖励:",fontSize)
	rewardLabel:setColor(pbColor)
	rewardLabel:setAnchorPoint(cc.p(0,0.5))
	rewardLabel:setPosition(posX,124)
	infoBg:addChild(rewardLabel)

	self.m_goodSprArray={}
	for i=1,3 do
		local nnxx=infoSize.width/2+(i-2)*125
		self.m_goodSprArray[i]=cc.Sprite:createWithSpriteFrameName("general_tubiaokuan.png")
		self.m_goodSprArray[i]:setPosition(nnxx,58)
		infoBg:addChild(self.m_goodSprArray[i])
	end
end

function TaskView.tabChuange(self,_tag)
	if _tag==TAG_GET then
		self:createNormalTask(TAG_GET)
		self.di2kuanSpr:setPreferredSize(cc.size(847,492))
        self.di2kuanSpr:setPosition(self.m_winSize.width/2,self.m_winSize.height/2-55)
	elseif _tag==TAG_NOGET then
		self:createNormalTask(TAG_NOGET)
		self.di2kuanSpr:setPreferredSize(cc.size(847,492))
        self.di2kuanSpr:setPosition(self.m_winSize.width/2,self.m_winSize.height/2-55)
	else
		self:showRewardTask()
		self.di2kuanSpr:setPreferredSize(cc.size(847,430))
        self.di2kuanSpr:setPosition(self.m_winSize.width/2,self.m_winSize.height/2-24)
	end

	if self.m_guideTab~=nil then
		if _tag==self.m_guideTab then
			_G.GGuideManager:showGuideByStep(2)
		else
			_G.GGuideManager:hideGuideByStep(2)
		end
	end
end
function TaskView.removeNormalTask(self)
	if self.m_normalTaskNode~=nil then
		self.m_normalTaskNode:removeFromParent(true)
		self.m_normalTaskNode=nil
		self.m_hightSprNormal=nil
	end
	self.m_curTaskId=nil
end
function TaskView.createNormalTask(self,_tag)
	self:removeNormalTask()

	if self.m_rewardTaskNode~=nil then
		self.m_rewardTaskNode:setVisible(false)
	end

	local taskArray
	if _tag==TAG_GET then
		taskArray=self.m_getArray
	else
		taskArray=self.m_nogetArray
	end
	local di2kuanSize=cc.size(380,476)
	local viewSize =cc.size(380,466)
	local scoSize  =cc.size(viewSize.width,viewSize.height-2)
	local pageCount=5
	local oneHeight=84-- scoSize.height/pageCount
	self.m_btnSize1=cc.size(scoSize.width-20,oneHeight-5)

	local container=cc.Node:create()
	container:setPosition(self.m_winSize.width/2-di2kuanSize.width-35,0)
	self.m_rootLayer:addChild(container)
	self.m_normalTaskNode=container

	local leftBgSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_login_dawaikuan.png")
	leftBgSpr:setPreferredSize(di2kuanSize)
	leftBgSpr:setPosition(self.m_winSize.width/2-di2kuanSize.width/2-35,di2kuanSize.height/2+27)
	self.m_panelInfoNode:addChild(leftBgSpr)

	local allCount=#taskArray
	if allCount==0 then
		self.m_panelInfoNode:setVisible(false)
		self:__showNoTaskView()
		return
	end
	self:__hideNoTaskView()

 	local minY=32+(viewSize.height-scoSize.height)/2
 	local maxY=minY+scoSize.height
	local scoView=cc.ScrollView:create()
    scoView:setDirection(ccui.ScrollViewDir.vertical)
    scoView:setTouchEnabled(true)
    scoView:setBounceable(false)
    scoView:setViewSize(scoSize)
    scoView:setPosition(0,minY)
    scoView:setDelegate()
	container:addChild(scoView)
    
	local tempHeight=oneHeight*allCount
	local subHeight=scoSize.height-tempHeight
	if subHeight<0 then
		scoSize=cc.size(scoSize.width,tempHeight)
		scoView:setContentSize(scoSize)
		scoView:setContentOffset(cc.p(0,subHeight),false)
	else
		scoView:setContentSize(scoSize)
	end

	local lpScrollBar=require("mod.general.ScrollBar")(scoView)
	lpScrollBar:setPosOff(cc.p(-7,0))
	-- lpScrollBar:setMoveHeightOff(10)

	local function c(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			local pos=sender:getWorldPosition()
			if pos.y>=minY and pos.y<maxY then
				local tag=sender:getTag()
				print("艹艹艹艹艹艹艹艹艹艹>>>",tag)

				-- local tempWidget=self.m_hightSprNormal:getParent()
				-- local blueLineSpr=tempWidget:getChildByTag(1688)
				-- if blueLineSpr~=nil then
				-- 	blueLineSpr:setVisible(true)
				-- end

				-- self.m_hightSprNormal:retain()
				-- self.m_hightSprNormal:removeFromParent(false)
				-- sender:addChild(self.m_hightSprNormal)
				-- self.m_hightSprNormal:release()

				-- blueLineSpr=sender:getChildByTag(1688)
				-- if blueLineSpr~=nil then
				-- 	blueLineSpr:setVisible(false)
				-- end
				self:createLightSpr(sender)

				self:showTaskInfo(tag)
			end
		end
    end

	for i,v in ipairs(taskArray) do
		local midPos=cc.p(viewSize.width/2,scoSize.height-(i-0.5)*oneHeight)
		local tempBtn=ccui.Button:create("general_nothis.png","general_isthis.png","general_isthis.png",1)
		tempBtn:setScale9Enabled(true)
		tempBtn:setContentSize(cc.size(366,78))
		local btnSize=tempBtn:getContentSize()
	    tempBtn:addTouchEventListener(c)
	    tempBtn:setTag(v.id)
	    tempBtn:setPosition(midPos)
	    tempBtn:setSwallowTouches(false)
	    -- tempBtn:ignoreContentAdaptWithSize(true)
	    -- tempBtn:setContentSize(P_SIZE_TASK)
	    -- tempBtn:setButtonScaleX(P_SIZE_TASK.width/btnSize.width)
	    -- tempBtn:setButtonScaleY(P_SIZE_TASK.height/btnSize.height)
	    scoView:addChild(tempBtn)

	    local taskCnf=_G.GTaskProxy:getTaskDataById(v.id)
	    local szName=taskCnf.name
	    local szType
	    if taskCnf.type==1 then
	    	szType="【".._G.Lang.LAB_N[764].."】"
	    else
	    	szType="【".._G.Lang.LAB_N[769].."】"
	    end
	    -- local typeLb=_G.Util:createLabel(szType,26)
	    -- typeLb:setAnchorPoint(cc.p(1,0.5))
	    -- typeLb:setPosition(cc.p(self.m_btnSize1.width/2,self.m_btnSize1.height/2))
	    -- tempBtn:addChild(typeLb)

	    local nameLb=_G.Util:createLabel(string.format("%s%s",szType,szName),24)
	    nameLb:setAnchorPoint(cc.p(0.5,0.5))
	    nameLb:setPosition(midPos)
	    nameLb:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
	    scoView:addChild(nameLb,10,1688)

	    if i==1 then
	    	self:showTaskInfo(v.id)
			self:createLightSpr(tempBtn)
	    end
	end
end
function TaskView.createLightSpr(self,_btn)
	if self.m_hightSprNormal~=nil then
		local btnLabel=self.m_hightSprNormal:getParent():getChildByTag(1688)
		if btnLabel~=nil then
			btnLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LBLUE))
		end
		self.m_hightSprNormal:retain()
		self.m_hightSprNormal:removeFromParent(false)
		_btn:addChild(self.m_hightSprNormal,1)
		self.m_hightSprNormal:release()

		btnLabel=_btn:getChildByTag(1688)
		if btnLabel~=nil then
			btnLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
		end
		return
	end

	local btnSize=_btn:getContentSize()
	local szSprName="general_isthis.png"
	local tempSpr=ccui.Scale9Sprite:createWithSpriteFrameName(szSprName)
	tempSpr:setPreferredSize(cc.size(366,78))
	tempSpr:setPosition(btnSize.width*0.5,btnSize.height*0.5)
	_btn:addChild(tempSpr,1)

	local btnLabel=_btn:getChildByTag(1688)
	if btnLabel~=nil then
		btnLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE))
	end

	self.m_hightSprNormal=tempSpr
end

function TaskView.__showNoTaskView(self)
	if self.m_notaskNode~=nil then
		self.m_notaskNode:setVisible(true)
		return
	end

	self.m_notaskNode=cc.Node:create()
	self.m_rootLayer:addChild(self.m_notaskNode)

	local viewSize=cc.size(830,476)
	local backSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_double.png")
	backSpr:setPreferredSize(viewSize)
	backSpr:setPosition(self.m_winSize.width/2,viewSize.height/2+27)
	self.m_notaskNode:addChild(backSpr)

	local tempSpr=cc.Sprite:createWithSpriteFrameName("general_monkey.png")
	tempSpr:setPosition(viewSize.width*0.5,viewSize.height*0.5+30)
	backSpr:addChild(tempSpr)

	local tempLabel=_G.Util:createLabel("暂无任务",20)
	tempLabel:setPosition(165,7)
	tempLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
	tempSpr:addChild(tempLabel)
end
function TaskView.__hideNoTaskView(self)
	if self.m_notaskNode~=nil then
		self.m_notaskNode:setVisible(false)
	end
end

function TaskView.showTaskInfo(self,_id)
	if self.m_curTaskId==_id then return end

	self.m_curTaskId=_id

	self.m_panelInfoNode:setVisible(true)
	local taskData=self:getTaskMsgById(_id)
	local taskCnf=_G.GTaskProxy:getTaskDataById(_id)
	local szName=taskCnf.name
	local szInfo=taskCnf.info or "???"
	local szType
	if taskCnf.type==1 then
		szType="【".._G.Lang.LAB_N[764].."】"
	else
		szType="【".._G.Lang.LAB_N[769].."】"
	end
	self.m_infoNameLabel:setString(szName)
	self.m_infoInfoLabel:setString(szInfo)
	self.m_infoTypeLabel:setString(szType)

	local szLimit=""
	if taskData.state==_G.Const.CONST_TASK_STATE_ACTIVATE then
		szLimit=string.format("(%d级可接)",taskCnf.lv)
		local infoNameSize=self.m_infoNameLabel:getContentSize()
		self.m_infoLimitLabel:setPositionX(self.m_infoNamePosX+infoNameSize.width)
	end
	self.m_infoLimitLabel:setString(szLimit)

	local szSNpcName=""
	local szENpcName=""
	local sNpcNode=_G.GTaskProxy:getNpcNodeById(taskCnf.npc.s.npc)
	if sNpcNode then
		szSNpcName=sNpcNode.npc_name or "**"
	end
	local eNpcNode=_G.GTaskProxy:getNpcNodeById(taskCnf.npc.e.npc)
	if eNpcNode then
		szENpcName=eNpcNode.npc_name or "**"
	end

	local targetType=taskData.target_type
	local szNanDu,szJinDu
	if targetType==_G.Const.CONST_TASK_TARGET_TALK then
		szNanDu=""
		szJinDu=""
	elseif targetType==_G.Const.CONST_TASK_TARGET_COPY then
		local targetCnf=taskCnf["target_".._G.Const.CONST_TASK_TARGET_COPY]
		local copyId=targetCnf.copy_id
		local playTime=targetCnf.times
		local curTimes=taskData.current
		local copyCnf=_G.GTaskProxy:getScenesCopysNodeByCopyId(copyId)
		local szCopyName=copyCnf and copyCnf.copy_name or ""
		szNanDu=string.format("通关%s副本 (%d/%d)",szCopyName,curTimes,playTime)
		-- szJinDu=string.format("%s副本(%d/%d)",szCopyName,curTimes,playTime)
		szJinDu=""
	elseif taskCnf.des~=nil and taskCnf.des~=0 then
		szNanDu=self:combinationString(taskCnf.des,taskData.current)
		szJinDu=""
	else
		szNanDu=""
		szJinDu=""
	end
	self.m_infoNpcStartLabel:setString(szSNpcName)
	self.m_infoNpcEndLabel:setString(szENpcName)
	self.m_infoNanDuLabel:setString(szNanDu)
	self.m_infoJinDuLabel:setString(szJinDu)

	-- 物品奖励
	local goodsList={}
	if taskCnf.exp>0 then
		local tempT={id=_G.Const.CONST_ZHUANHUAN_EXP,count=taskCnf.exp}
		table.insert(goodsList,tempT)
	end
	if taskCnf.gold>0 then
		local tempT={id=_G.Const.CONST_ZHUANHUAN_GOLD,count=taskCnf.gold}
		table.insert(goodsList,tempT)
	end

	if taskCnf.good~=nil then
		for i,v in ipairs(taskCnf.good) do
			if v.pro==0 or v.pro==self.m_rolePro then
				table.insert(goodsList,v)
			end
		end
	end

	local function r(sender,eventType)
		if eventType == ccui.TouchEventType.ended then
			local goodsId=sender:getTag()
	        local nPos=sender:getWorldPosition()
	        local temp=_G.TipsUtil:createById(goodsId,nil,nPos)
	        cc.Director:getInstance():getRunningScene():addChild(temp,1000)
		end
	end

	for i,spr in ipairs(self.m_goodSprArray) do
		spr:removeAllChildren(true)

		local goodNode=goodsList[i]
		if goodNode~=nil then
			local goodsCnf=_G.Cfg.goods[goodNode.id]
			if goodsCnf~=nil then
				local sprSize=spr:getContentSize()
				local iconBtn=_G.ImageAsyncManager:createGoodsBtn(goodsCnf,r,goodNode.id,goodNode.count)
				iconBtn:setPosition(cc.p(sprSize.width/2,sprSize.height/2))
				spr:addChild(iconBtn)
			end
		end
	end
end
function TaskView.showRewardTask(self)
	self.m_panelInfoNode:setVisible(false)
	self:removeNormalTask()
	self:__hideNoTaskView()

	if self.m_rewardTaskNode~=nil then
		self.m_rewardTaskNode:setVisible(true)
		return
	end

	local container=cc.Node:create()
	self.m_rewardTaskNode=container
	self.m_rewardTaskNode:setPosition(self.m_winSize.width/2-480,0)
	self.m_rootLayer:addChild(container)

	local viewSize=cc.size(830,415)
	local backSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_double.png")
	backSpr:setPreferredSize(viewSize)
	backSpr:setPosition(480,viewSize.height/2+88)
	container:addChild(backSpr)

	local lbColor=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN)
	local midPosY=45
	local midPosX=viewSize.width*0.5
	local t_timeLabel=_G.Util:createLabel("剩余次数:",20)
	local t_numLabel =_G.Util:createLabel("剩余刷新符:",20)
	t_timeLabel:setColor(lbColor)
	t_numLabel :setColor(lbColor)
	t_timeLabel:setAnchorPoint(cc.p(1,0.5))
	t_numLabel :setAnchorPoint(cc.p(1,0.5))
	t_timeLabel:setPosition(cc.p(235,midPosY))
	t_numLabel :setPosition(cc.p(515,midPosY))
	container:addChild(t_timeLabel)
	container:addChild(t_numLabel)

	-- local sprSize=cc.size(82,30)
	-- local timeSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_input.png")
	-- timeSpr:setPreferredSize(sprSize)
	-- timeSpr:setPosition(cc.p(280,midPosY))
	-- container:addChild(timeSpr)
	-- local numSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_input.png")
	-- numSpr:setPreferredSize(sprSize)
	-- numSpr:setPosition(cc.p(560,midPosY))
	-- container:addChild(numSpr)

	local timeLabe=_G.Util:createLabel("10/10",20)
	timeLabe:setAnchorPoint(cc.p(0,0.5))
	timeLabe:setPosition(cc.p(245,midPosY))
	timeLabe:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
	container:addChild(timeLabe)

	local numLabe=_G.Util:createLabel("9999",20)
	numLabe:setPosition(cc.p(525,midPosY))
	numLabe:setAnchorPoint(cc.p(0,0.5))
	numLabe:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
	container:addChild(numLabe)
	self.m_rewardTimeLabel=timeLabe
	self.m_rewardNumLabel=numLabe

	-- local szImg=_G.ImageAsyncManager:getIconPath(48000)
	-- local numIconSpr =cc.Sprite:create(szImg)
	-- local iconScale  =0.5
	-- local iconSprSize=numLabe:getContentSize()
	-- numIconSpr:setScale(iconScale)
	-- numIconSpr:setPosition(cc.p(520+iconSprSize.width,midPosY))
	-- container:addChild(numIconSpr)

	-- local lineSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_double_line.png")
	-- local lineSize=lineSpr:getContentSize()
	-- lineSpr:setPreferredSize(cc.size(730,lineSize.height))
	-- lineSpr:setPosition(480,midPosY+45)
	-- container:addChild(lineSpr)

	local function c(serder,eventType)
		if eventType==ccui.TouchEventType.ended then
			print("=========>>>>> flash")
			local isHas5Star=false
			if self.m_rewardCellArray~=nil then
				for k,v in pairs(self.m_rewardCellArray) do
					if v.starNum>=5 then
						isHas5Star=true
						break
					end
				end
			end

			local function f(_state)
				self.isChange = true
				local msg=REQ_REWARD_TASK_REFRESH()
				_G.Network:send(msg)
				
				if not m_isNoticRefresh then
					m_isNoticRefresh=_state
				end
			end
			if not isHas5Star and m_isNoticRefresh then
				f()
				return
			end
			local goodsCnf=_G.Cfg.goods[FRESH_GOODS]
			local goodsName=goodsCnf and goodsCnf.name or "???"
			local szMsg
			if isHas5Star then
				print("有五星级任务")
				szMsg=string.format("当前有五星级任务，确认花费%d%s刷新任务?",FRESH_MONEY,goodsName)
				local boxView=_G.Util:showTipsBox(szMsg,f)
			else
				print("无五星级任务")
				szMsg=string.format("花费%d%s刷新任务?",FRESH_MONEY,goodsName)
				local boxView=_G.Util:showTipsBox(szMsg,f)
				boxView:showNeverNotic()
			end
			
		end
	end
	local button=gc.CButton:create()
    button:loadTextures("general_btn_gold.png")
    button:setPosition(765,midPosY)
    button:addTouchEventListener(c)
    button:setTitleFontSize(24)
    button:setTitleText("刷 新")
    button:setTitleFontName(__fonsName)
    --button:enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
    button:setButtonScale(0.85)
    container:addChild(button)
    self.m_refreshBtn=button

    self.m_mediator=require("mod.task.TaskViewMediator")(self)

    local msg=REQ_REWARD_TASK_REQUEST()
    _G.Network:send(msg)

    self.m_rewardCellArray={}
end
function TaskView.bagGoodsUpdate(self)
	if self.m_rewardNumLabel~=nil then
		local nCount=_G.GBagProxy:getGoodsCountById(_G.Const.CONST_TASK_REWARD_REF_GID)
		self.m_rewardNumLabel:setString(tostring(nCount))
	end
end
function TaskView.updateRewardTask(self,_ackMsg)
	if self.isChange  then
		print( "change ====>>>>" )
		_G.Util:playAudioEffect("ui_equip_change")
		self.isChange = false
	end
	local szNum=tostring(_ackMsg.sg_num)
	local m_num=REWARD_TIMES-_ackMsg.num
	local szTimes=string.format("%d/%d",m_num,REWARD_TIMES)
	self.m_rewardNumLabel :setString(szNum)
	self.m_rewardTimeLabel:setString(szTimes)

	if _ackMsg.num>=REWARD_TIMES then
		self.m_refreshBtn:setEnabled(false)
		self.m_refreshBtn:setBright(false)
	end

	local dealPos=nil
	for i=1,3 do
		if _ackMsg.data[i]==nil then
			if self.m_rewardCellArray[i]~=nil then
				self.m_rewardCellArray[i].cellNode:setVisible(false)
			end
		else
			local data=_ackMsg.data[i]
			if data.state~=_G.Const.CONST_TASK_REWARD_STATE_F then
				dealPos=i
			end

			if self.m_rewardCellArray[i]==nil then
				self.m_rewardCellArray[i]=self:createRewardCell(data,i)
			else
				local taskRewardCnf=_G.Cfg.task_reward[data.task_id]
				local tempArray=self.m_rewardCellArray[i]
				tempArray.taskId=data.task_id
				tempArray.cellNode:setVisible(true)
				-- 名称
				local nameStr=self:combinationString(taskRewardCnf.desc,data.value)
				print( "nameStr ===>>>> ", nameStr, data.value )
				tempArray.nameLabel:setString(nameStr)
				tempArray.value=data.value
				-- 经验
				tempArray.expLabel:setString(tostring(data.exp))
				-- 铜钱
				tempArray.goldLabel:setString(tostring(data.gold))
				-- 图片背景
				local isSpr=string.format("uitask_sprite%d.png",taskRewardCnf.pic)
				local spriteFram=cc.SpriteFrameCache:getInstance():getSpriteFrame(isSpr)
		        if spriteFram==nil then
		        	isSpr="uitask_sprite1.png"
		        end
				tempArray.mainSpr:setSpriteFrame(isSpr)
				-- 星星
				local starNum=taskRewardCnf.star
				for i,spr in ipairs(tempArray.starSprs) do
					if i>starNum then
						-- spr:setColor(cc.c4b(0,0,0,255))
						spr:setGray()
					else
						-- spr:setColor(cc.c4b(255,255,255,255))
						spr:setDefault()
					end
				end
				tempArray.starNum=starNum

				-- 状态
				self:chuangRewardTaskStart(data.state,tempArray)

				tempArray.goBtn:setTag(i)
			end
		end
	end

	dealPos=dealPos or 2
	if self.m_guide_reward_view then
		local data=_ackMsg.data[dealPos]

		self.m_guide_reward_view=nil
		_G.GGuideManager:registGuideData(2,self.m_rewardCellArray[dealPos].acceptBtn)
		_G.GGuideManager:registGuideData(3,self.m_rewardCellArray[dealPos].goBtn)
		_G.GGuideManager:registGuideData(4,self.m_rewardCellArray[dealPos].rewardBtn)
		if data.state==_G.Const.CONST_TASK_REWARD_STATE_F then
			self.m_guide_task_accept=true
			_G.GGuideManager:runNextStep()
		elseif data.state==_G.Const.CONST_TASK_REWARD_STATE_S then
			self.m_guide_task_go=true
			_G.GGuideManager:runThisStep(3)
		else
			self.m_guide_task_getreward=true
			_G.GGuideManager:runThisStep(4)
		end
		self.m_guide_deal_pos=dealPos
	elseif self.m_guide_task_getreward then
		self.m_guide_task_getreward=nil
		_G.GGuideManager:runNextStep()
	elseif self.m_guide_task_go then
		local data=_ackMsg.data[dealPos]
		if data.state==_G.Const.CONST_TASK_REWARD_STATE_F then
			-- 玩家 立刻完成任务
			self.m_guide_task_go=nil
			_G.GGuideManager:clearCurGuideNode()
		end
	end

	if #_ackMsg.data==0 then
		if self.m_noticLabel==nil then
			self.m_noticLabel=_G.Util:createLabel("没有可接受的修行任务",26)
			self.m_noticLabel:setPosition(480,290)
			self.m_rewardTaskNode:addChild(self.m_noticLabel)
		else
			self.m_noticLabel:setVisible(true)
		end
	else
		if self.m_noticLabel~=nil then
			self.m_noticLabel:setVisible(false)
		end
	end
end
function TaskView.acceptRewardTask(self,_dataIdx)
	_G.Util:playAudioEffect("ui_task_get")
	
	if self.m_rewardCellArray==nil then return end

	for i=1,#self.m_rewardCellArray do
		if self.m_rewardCellArray[i].state~=_G.Const.CONST_TASK_REWARD_STATE_F then
			self:chuangRewardTaskStart(_G.Const.CONST_TASK_REWARD_STATE_F,self.m_rewardCellArray[i])
		end
	end

	local tempArray=self.m_rewardCellArray[_dataIdx]
	if tempArray~=nil then
		self:chuangRewardTaskStart(_G.Const.CONST_TASK_REWARD_STATE_S,tempArray)
	end

	if self.m_guide_deal_pos~=nil then
		if self.m_guide_deal_pos~=_dataIdx then
			self.m_guide_deal_pos=_dataIdx
			_G.GGuideManager:registGuideData(2,self.m_rewardCellArray[_dataIdx].acceptBtn)
			_G.GGuideManager:registGuideData(3,self.m_rewardCellArray[_dataIdx].goBtn)
			_G.GGuideManager:registGuideData(4,self.m_rewardCellArray[_dataIdx].rewardBtn)
		end
		if self.m_guide_task_accept then
			self.m_guide_task_accept=nil
			-- self.m_guide_task_go=true
			-- _G.GGuideManager:runNextStep()
			_G.GGuideManager:clearCurGuideNode()
		elseif self.m_guide_task_go then
			_G.GGuideManager:runThisStep(3)
		end
	end
end
function TaskView.finishRewardTask(self,_dataIdx)
	if self.m_rewardCellArray==nil then return end

	local tempArray=self.m_rewardCellArray[_dataIdx]
	if tempArray~=nil then
		self:chuangRewardTaskStart(_G.Const.CONST_TASK_REWARD_STATE_T,tempArray)
	end
end
function TaskView.createRewardCell(self,_data,_idx)
	print( " TaskView.createRewardCell " )
	local tempArray={}
	tempArray.taskId=_data.task_id

	local taskRewardCnf=_G.Cfg.task_reward[_data.task_id]
	local cellSize=cc.size(265,410)
	local fontSize=20
	local color3=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_DARKPURPLE)
	local lbColor=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN)

	local nnnn=1.5-_idx
	local posX=483+nnnn*(cellSize.width+2)
	local taskSpr=cc.Node:create()
    taskSpr:setPosition(cc.p(posX,175))
    self.m_rewardTaskNode:addChild(taskSpr)

    -- if _idx>1 then
    -- 	local lineSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_double_line.png")
    -- 	local lineSize=lineSpr:getContentSize()
    -- 	lineSpr:setRotation(-90)
    -- 	lineSpr:setPreferredSize(cc.size(310,lineSize.height))
    -- 	lineSpr:setPosition(cellSize.width,cellSize.height*0.5)
    -- 	taskSpr:addChild(lineSpr)
    -- end

    -- 星星
    local startPosY=274
    local startLabel=_G.Util:createLabel("任务星级:",fontSize)
    startLabel:setAnchorPoint(cc.p(0,0.5))
    startLabel:setPosition(cc.p(30,startPosY))
    startLabel:setColor(lbColor)
    taskSpr:addChild(startLabel)

    local starNum=taskRewardCnf.star
    tempArray.starSprs={}
    tempArray.starNum=starNum
    for i=1,5 do
    	local tempSpr=gc.GraySprite:createWithSpriteFrameName("general_star2.png")
    	tempSpr:setPosition(cc.p(130+(i-1)*25,startPosY+2))
    	taskSpr:addChild(tempSpr)
    	tempArray.starSprs[i]=tempSpr

    	if starNum<i then
    		-- tempSpr:setColor(cc.c4b(0,0,0,255))
    		tempSpr:setGray()
    	end
    end

    -- 任务显示
    local tempSize=cc.size(cellSize.width-30,125)
    local isSpr = string.format("uitask_sprite%d.png",taskRewardCnf.pic)
    local spriteFram=cc.SpriteFrameCache:getInstance():getSpriteFrame(isSpr)
    if spriteFram==nil then
      isSpr="uitask_sprite1.png"
    end
    local mainSpr=cc.Sprite:createWithSpriteFrameName(isSpr)
    mainSpr:setPosition(cellSize.width/2,cellSize.height/2-40)
    taskSpr:addChild(mainSpr)
    tempArray.mainSpr=mainSpr

 --    local nameSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_voice_dins.png")
	-- nameSpr:setPreferredSize(cc.size(tempSize.width-12,30))
	-- nameSpr:setPosition(tempSize.width/2-4,17)
	-- mainSpr:addChild(nameSpr)

	local nameStr=self:combinationString(taskRewardCnf.desc,_data.value)
    local nameLabel=_G.Util:createLabel(nameStr,fontSize)
    nameLabel:setPosition(cc.p(tempSize.width/2+10,20))
    -- nameLabel:setColor(color3)
    mainSpr:addChild(nameLabel)
    tempArray.nameLabel=nameLabel
    tempArray.value=_data.value

    local sprPos=cc.p(tempSize.width-10,tempSize.height+8)
    local doSpr=cc.Sprite:createWithSpriteFrameName("uitask_state_1.png")
    doSpr:setAnchorPoint(cc.p(1,1))
    doSpr:setPosition(sprPos)
    mainSpr:addChild(doSpr)
    tempArray.doSpr=doSpr
    local finishSpr=cc.Sprite:createWithSpriteFrameName("uitask_state_2.png")
    finishSpr:setAnchorPoint(cc.p(1,1))
    finishSpr:setPosition(sprPos)
    mainSpr:addChild(finishSpr)
    tempArray.finishSpr=finishSpr

    -- 奖励
    local t_expLabel =_G.Util:createLabel("经验:",fontSize)
    local expLabel   =_G.Util:createLabel(tostring(_data.exp),fontSize)
    local t_goldLabel=_G.Util:createLabel("铜钱:",fontSize)
    local goldLabel  =_G.Util:createLabel(tostring(_data.gold),fontSize)

    local posX=cellSize.width/2-5
    t_expLabel:setAnchorPoint(cc.p(1,0.5))
    expLabel:setAnchorPoint(cc.p(0,0.5))
    t_goldLabel:setAnchorPoint(cc.p(1,0.5))
    goldLabel:setAnchorPoint(cc.p(0,0.5))

    t_expLabel:setPosition(cc.p(posX,55))
    expLabel:setPosition(cc.p(posX,55))
    t_goldLabel:setPosition(cc.p(posX,10))
    goldLabel:setPosition(cc.p(posX,10))

    t_expLabel:setColor(lbColor)
    expLabel:setColor(lbColor)
    t_goldLabel:setColor(lbColor)
    goldLabel:setColor(lbColor)

    taskSpr:addChild(t_expLabel)
    taskSpr:addChild(expLabel)
    taskSpr:addChild(t_goldLabel)
    taskSpr:addChild(goldLabel)

    tempArray.expLabel=expLabel
    tempArray.goldLabel=goldLabel

    -- 按钮
    local tag_accect=1
    local tag_cheat =2
    local tag_reward=4
    local function c(serder,eventType)
    	if eventType==ccui.TouchEventType.ended then
    		local tag=serder:getTag()
    		print("createRewardCell==========>>>>",tag)
    		if tag==tag_accect then
    			local isHasAccectTask=false
    			for i=1,#self.m_rewardCellArray do
					if self.m_rewardCellArray[i].state~=_G.Const.CONST_TASK_REWARD_STATE_F then
						isHasAccectTask=true
						break
					end
				end
    			local function f()
    				local msg=REQ_REWARD_TASK_ACCEPT()
	    			msg:setArgs(_data.idx)
	    			_G.Network:send(msg)
    			end
    			if not isHasAccectTask then
    				f()
    			else
    				_G.Util:showTipsBox("是否放弃原有任务?\n(本操作不会扣次数)",f)
    			end
    		elseif tag==tag_cheat then
    			local function f()
    				_G.Util:playAudioEffect("ui_task_ok")
    				local msg=REQ_REWARD_TASK_COMPLETE()
	    			msg:setArgs(_data.idx)
	    			_G.Network:send(msg)
    			end
    			local szMsg=string.format("花费%d元宝完成此任务?",CHEAT_MONEY)
    			local myBox = _G.Util:showTipsBox(szMsg,f)
    			myBox : setbuzuLabel( _G.Lang.LAB_N[940] )
    		elseif tag==tag_reward then
    			_G.Util:playAudioEffect("ui_task_ok")
    			local msg=REQ_REWARD_TASK_SUBMIT()
    			msg:setArgs(_data.idx)
    			_G.Network:send(msg)
    		end
    	end
    end
    local function openView(sender,eventType)
    	if eventType==ccui.TouchEventType.ended then
    		local taskPos=sender:getTag()
    		local taskId=self.m_rewardCellArray[taskPos].taskId
    		local taskRewardCnf=_G.Cfg.task_reward[taskId]
    		local mapId=taskRewardCnf.map_id
    		if mapId==_G.Const.CONST_MAP_COPY then
    			local taskValue=self.m_rewardCellArray[taskPos].value
    			local maxValue=taskRewardCnf.value
    			local roleProperty=_G.GPropertyProxy:getMainPlay()
	            roleProperty:setTaskInfo(_G.Const.CONST_TASK_TRACE_DAILY_TASK,nil,nil,taskValue,maxValue)
    		end
			-- self:closeWindow()
			_G.GLayerManager:openSubLayerByMapOpenId(mapId)
    	end
    end

    local btnPosY=-45
    local button=gc.CButton:create()
    button:loadTextures("general_btn_gold.png")
    button:setPosition(cc.p(cellSize.width/2,btnPosY))
    button:addTouchEventListener(c)
    button:setTag(tag_reward)
    button:setTitleFontSize(24)
    button:setTitleText("领取奖励")
    button:setTitleFontName(__fonsName)
    --button:enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
    button:setButtonScale(0.85)
    taskSpr:addChild(button)
    tempArray.rewardBtn=button

    button=gc.CButton:create()
    button:loadTextures("general_btn_lv.png")
    button:setPosition(cc.p(cellSize.width/2-60,btnPosY))
    button:addTouchEventListener(c)
    button:setTag(tag_cheat)
    button:setTitleFontSize(24)
    button:setTitleText("立即完成")
    button:setTitleFontName(__fonsName)
    --button:enableTitleOutline(_G.ColorUtil:getYBtnOutColor())
    button:setButtonScale(0.85)
    taskSpr:addChild(button)
    tempArray.cheatBtn=button

    button=gc.CButton:create()
    button:loadTextures("general_btn_lv.png")
    button:setPosition(cc.p(cellSize.width/2,btnPosY))
    button:addTouchEventListener(c)
    button:setTag(tag_accect)
    button:setTitleFontSize(24)
    button:setTitleText("接 受")
    button:setTitleFontName(__fonsName)
    button:setButtonScale(0.85)
    taskSpr:addChild(button)
    tempArray.acceptBtn=button

    button=gc.CButton:create()
    button:loadTextures("general_btn_gold.png")
    button:setPosition(cc.p(cellSize.width/2+60,btnPosY))
    button:addTouchEventListener(openView)
    button:setTag(_idx)
    button:setTitleFontSize(24)
    button:setTitleText("前 往")
    button:setTitleFontName(__fonsName)
    button:setButtonScale(0.85)
    taskSpr:addChild(button)
    tempArray.goBtn=button

    self:chuangRewardTaskStart(_data.state,tempArray)

    tempArray.cellNode=taskSpr
    return tempArray
end
function TaskView.chuangRewardTaskStart(self,_state,_tempArray)
	if _state==_G.Const.CONST_TASK_REWARD_STATE_F then
    	-- 未接受
    	_tempArray.doSpr:setVisible(false)
    	_tempArray.finishSpr:setVisible(false)

    	_tempArray.goBtn:setVisible(false)
    	_tempArray.acceptBtn:setVisible(true)
    	_tempArray.cheatBtn:setVisible(false)
    	_tempArray.rewardBtn:setVisible(false)
    elseif _state==_G.Const.CONST_TASK_REWARD_STATE_S then
    	-- 接受未完成
    	_tempArray.doSpr:setVisible(true)
    	_tempArray.finishSpr:setVisible(false)

    	_tempArray.goBtn:setVisible(true)
    	_tempArray.acceptBtn:setVisible(false)
    	_tempArray.cheatBtn:setVisible(true)
    	_tempArray.rewardBtn:setVisible(false)
    else
    	-- 已完成
    	_tempArray.doSpr:setVisible(false)
    	_tempArray.finishSpr:setVisible(true)

    	_tempArray.goBtn:setVisible(false)
    	_tempArray.acceptBtn:setVisible(false)
    	_tempArray.cheatBtn:setVisible(false)
    	_tempArray.rewardBtn:setVisible(true)
    end
    _tempArray.state=_state
end

--组合字符串
function TaskView.combinationString( self, _string, _value )
    local newString = ""
    for i=1,string.len(_string) do
        local tmpStr = string.sub(_string,i,i)
        if tmpStr == "#" then
            newString = newString..(_value or "0")
        else
            newString = newString..tmpStr
        end
    end
    return newString
end

function TaskView.closeWindow(self)
	if self.m_rootLayer==nil then return end
	self.m_rootLayer=nil

	cc.Director:getInstance():popScene()
	self:destroy()

	if self.m_guideTab then
		local command=CGuideNoticShow()
      	controller:sendCommand(command)
	end
end

function TaskView.taskGuide(self)
	if self.m_curTaskId==nil then return end
	
	local taskData=self:getTaskMsgById(self.m_curTaskId)
	if taskData==nil then return end

	_G.GTaskProxy:setMainTask(taskData)
    self:closeWindow()
    
    local function f()
        local command = CTaskDialogUpdateCommand( CTaskDialogUpdateCommand.GOTO_TASK )
        controller :sendCommand( command )
    end
    _G.Scheduler:performWithDelay(0.2,f)

end
function TaskView.getTaskMsgById(self,_id)
	for i,v in ipairs(self.m_taskInfoList) do
		if v.id==self.m_curTaskId then
			return v
		end
	end
end

return TaskView