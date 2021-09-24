--配件装备的标签页上面每一页的坦克配件和信息
accessoryDialogTank={}

function accessoryDialogTank:new(parent)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.posTb=nil
	nc.equips={}
	nc.tankID=1
	nc.bgLayer=nil
	nc.open=false
	nc.parent=parent
	nc.isShow=false
	nc.needRefresh=false
	return nc
end

function accessoryDialogTank:init(layerNum,tankID)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self.tankID=tankID

	self.equips=accessoryVoApi:getTankAccessories(self.tankID)
	
	self:initInfo()
	self:initTank()
	self:initPos()
	self:initAccessory()

    spriteController:addPlist("public/acAnniversary.plist")
    spriteController:addTexture("public/acAnniversary.png")

    local function onShare()
	    if G_checkClickEnable()==false then
	        do
	            return
	        end
    	end
    	PlayEffect(audioCfg.mouseClick)
    	if self.equips then
    		local count=SizeOfTable(self.equips)
    		if count==0 then
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("purifying_not_wear"),30)
				do return end
    		end
    	end
	    local share=self:getShareData()
	    if share then
		    local tankStr=""
			if(self.tankID==1)then
				tankStr=getlocal("tanke")
			elseif(self.tankID==2)then
				tankStr=getlocal("jianjiche")
			elseif(self.tankID==3)then
				tankStr=getlocal("zixinghuopao")
			elseif(self.tankID==4)then
				tankStr=getlocal("huojianche")
			end
	    	local message=getlocal("mything",{getlocal("accessory")})..":".."【"..tankStr..getlocal("accessory").."】"
        	local tipStr=getlocal("send_share_sucess",{tankStr..getlocal("accessory")})
	      	G_shareHandler(share,message,tipStr,self.layerNum+1)
	    end
  	end
	local shareItem=GetButtonItem("anniversarySend.png","anniversarySendDown.png","anniversarySendDown.png",onShare)
	local shareBtn=CCMenu:createWithItem(shareItem)
	shareBtn:setTouchPriority(-(self.layerNum-1)*20-4)
	shareBtn:setPosition(G_VisibleSizeWidth-63,G_VisibleSizeHeight-180)
	self.bgLayer:addChild(shareBtn)

	return self.bgLayer
end

--初始化下半部分的各种属性概况
function accessoryDialogTank:initInfo()
	local strSize2 = 21
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize2 =25
    end
	local tankHeight=256
	if(G_isIphone5()==false)then
		tankHeight=tankHeight*0.9
	end
	local function nilFunc( ... )
	end
	local infoSize=CCSizeMake(G_VisibleSizeWidth-40,(G_VisibleSizeHeight - 250 - tankHeight - 80 - 40 - 24))
	self.infoLayer=LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",CCRect(30,30,50,50),nilFunc)
	self.infoLayer:setContentSize(infoSize)
	self.infoLayer:setTouchPriority(-(self.layerNum-1)*20-4)
	self.infoLayer:setAnchorPoint(ccp(0,0))
	self.infoLayer:setPosition(ccp(20,24))
	self.infoLayer:setOpacity(0)
	self.bgLayer:addChild(self.infoLayer,2)

	local infoBg=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(10,10,50,50),nilFunc)
	infoBg:setTag(101)
	infoBg:setContentSize(infoSize)
	infoBg:setTouchPriority(-(self.layerNum-1)*20-4)
	infoBg:setAnchorPoint(ccp(0,1))
	infoBg:setPosition(ccp(0,infoSize.height))
	self.infoLayer:addChild(infoBg)

	local function switchOpen(object,fn,tag)
		self:switchShowDetail()
	end
	local sp1 = LuaCCScale9Sprite:createWithSpriteFrameName("acItemBg1.png",CCRect(40,20,20,50),switchOpen)
	local sp2 = LuaCCScale9Sprite:createWithSpriteFrameName("acItemBg2.png",CCRect(40,20,20,50),switchOpen)
	local sp3 = LuaCCScale9Sprite:createWithSpriteFrameName("acItemBg2.png",CCRect(40,20,20,50),switchOpen)
	sp1:setContentSize(CCSizeMake(infoSize.width,100))
	sp2:setContentSize(CCSizeMake(infoSize.width,100))
	sp3:setContentSize(CCSizeMake(infoSize.width,100))
	self.titleItem=CCMenuItemSprite:create(sp1,sp2,sp3)
	self.titleItem:registerScriptTapHandler(switchOpen)
	self.titleItem:setAnchorPoint(ccp(0,1))
	local titleBg=CCMenu:createWithItem(self.titleItem)
	titleBg:setTouchPriority(-(self.layerNum-1)*20-5)
	titleBg:setContentSize(CCSizeMake(infoSize.width,100))
	titleBg:setAnchorPoint(ccp(0,1))
	titleBg:setPosition(ccp(0,infoSize.height))
	self.infoLayer:addChild(titleBg)

	local titleLb1=GetTTFLabel(getlocal("attribute_add"),28)
	titleLb1:setPosition(ccp(infoSize.width/2,65))
	self.titleItem:addChild(titleLb1)

	local titleLb2=GetTTFLabel(getlocal("click_to_open"),22)
	titleLb2:setTag(100)
	titleLb2:setColor(G_ColorGreen)
	titleLb2:setPosition(ccp(infoSize.width/2,35))
	self.titleItem:addChild(titleLb2)

	local arrowBg=LuaCCScale9Sprite:createWithSpriteFrameName("TeamHeaderBg.png",CCRect(60,0,350,54),switchOpen)
	arrowBg:setContentSize(CCSizeMake(150,20))
	arrowBg:setAnchorPoint(ccp(0.5,1))
	arrowBg:setPosition(ccp(infoSize.width/2,5))
	self.titleItem:addChild(arrowBg)
	local arrow=CCSprite:createWithSpriteFrameName("leftBtnGreen.png")
	arrow:setTag(101)
	arrow:setRotation(-90)
	arrow:setScale(0.5)
	arrow:setPosition(ccp(infoSize.width/2,-5))
	self.titleItem:addChild(arrow)

	local gsNum=0
	local attAdd={0,0,0,0,0,0,0,0,0,0,0,0,0,0}

	if(self.equips~=nil)then
		for k,v in pairs(self.equips) do
			if(v~=nil)then
				gsNum=gsNum+v:getGS()+v:getGsAdd()
				local att=v:getAttWithSuccinct()
				for kk,vv in pairs(att) do
					attAdd[kk]=attAdd[kk]+vv
				end
				
			end
		end
	end
	
	local unitHeight=(infoSize.height - 110 - 35)/3
	local endIndex
	if(base.accessoryTech==1)then
		endIndex=6
	elseif(base.succinct==1)then
		endIndex=5
	else
		endIndex=4
	end
	for i=1,endIndex do
		local icon
		if(i==1)then
			icon=CCSprite:createWithSpriteFrameName(buffEffectCfg[100].icon)
		elseif(i==2)then
			icon=CCSprite:createWithSpriteFrameName(buffEffectCfg[108].icon)
		elseif(i==3)then
			icon=CCSprite:createWithSpriteFrameName(buffEffectCfg[201].icon)
		elseif(i==4)then
			icon=CCSprite:createWithSpriteFrameName(buffEffectCfg[202].icon)
		elseif(i==5)then
			icon=CCSprite:createWithSpriteFrameName("accessoryPurify.png")
		elseif(i==6)then
			icon=CCSprite:createWithSpriteFrameName("accessoryTech.png")
		end
		local posX,posY
		if(i%2==0)then
			posX=infoSize.width/2 + 5
			posY=infoSize.height - 115 - unitHeight*i/2 + unitHeight/2
		else
			posX=10
			posY=infoSize.height - 115 - unitHeight*(i+1)/2 + unitHeight/2
		end
		icon:setScale(60/icon:getContentSize().width)
		icon:setAnchorPoint(ccp(0,0.5))
		icon:setPosition(posX,posY)
		self.infoLayer:addChild(icon)
		local lb
		if(i<5)then
			if(accessoryCfg.attEffect[i]==1)then
				lb=GetTTFLabelWrap(getlocal("accessory_attAdd_"..i,{attAdd[i].."%%"}),strSize2,CCSizeMake(G_VisibleSizeWidth-450,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			else
				lb=GetTTFLabelWrap(getlocal("accessory_attAdd_"..i,{attAdd[i]}),strSize2,CCSizeMake(G_VisibleSizeWidth-450,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			end
		elseif(i==5)then
			lb=GetTTFLabelWrap(getlocal("accessory_purifyAdd",{SizeOfTable(self:getPurifyExtraAtt())}),strSize2,CCSizeMake(G_VisibleSizeWidth-450,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		elseif(i==6)then
			local totalPoint=0
			for techID,skillData in pairs(self:getTechExtraEffect()) do
				if(skillData[3]>0)then
					totalPoint=totalPoint + skillData[3]
				end
			end
			lb=GetTTFLabelWrap(getlocal("accessory_techPoint",{totalPoint}),strSize2,CCSizeMake(G_VisibleSizeWidth-450,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		end
		lb:setTag(200 + i)
		lb:setAnchorPoint(ccp(0,0.5))
		lb:setPosition(posX + 70,posY)
		self.infoLayer:addChild(lb)
	end

	self.gsLb=GetTTFLabel(getlocal("accessory_gsAdd",{gsNum}),28)
	self.gsLb:setAnchorPoint(ccp(0.5,0.5))
	self.gsLb:setPosition(ccp(infoSize.width/2,20))
	self.gsLb:setColor(G_ColorGreen)
	self.infoLayer:addChild(self.gsLb)

	local function callback(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(callback)
	--精炼和科技详情的tableView
	self.detailTv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 60,G_VisibleSizeHeight - 200 - infoSize.height),nil)
	self.detailTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
	self.detailTv:setPosition(10,-(G_VisibleSizeHeight - 200 - infoSize.height))
	self.infoLayer:addChild(self.detailTv)
	self.detailTv:setMaxDisToBottomOrTop(30)
	self.detailTv:setVisible(false)
end

--获取精炼增加的奖励属性
function accessoryDialogTank:getPurifyExtraAtt()
	if(self.purifyAtt)then
		return self.purifyAtt
	end
	local totalBonus={}
	for partID,aVo in pairs(self.equips) do
		local succinct=aVo:getSuccinct()
	    local refineId = aVo:getConfigData("refineId")
	    if(refineId and refineId>0)then
			local bounsAtt = succinctCfg.bounsAtt[refineId]
			for i=1,4 do
				local flag=false
				for k,v in pairs(bounsAtt[i][1]) do
					if(i==2)then
						if(succinct[1]>=v)then
							flag=true
						end
					elseif(i==1)then
						if(succinct[2]>=v)then
							flag=true
						end
					else
						if(succinct[i]>=v)then
							flag=true
						end
					end
				end
				if(flag)then
					for k,v in pairs(bounsAtt[i][2]) do
						if(totalBonus[k])then
							totalBonus[k]=totalBonus[k] + v
						else
							totalBonus[k]=v
						end
					end
				end
			end
		end
	end
	self.purifyAtt=totalBonus
	return self.purifyAtt
end

--获取科技增加的技能情况
function accessoryDialogTank:getTechExtraEffect()
	if(self.techExtra)then
		return self.techExtra
	end
	self.techExtra={}
	local tankAccessory=accessoryVoApi:getTankAccessories(self.tankID)
	if(tankAccessory)then
		local techPointTb={}
		local techNum=accessoryVoApi:getUnlockTechNum()
		for i=1,techNum do
			techPointTb[i]=0
		end
		for partID,aVo in pairs(tankAccessory) do
			if(aVo.techLv and aVo.techLv>0)then
				techPointTb[aVo.techID]=techPointTb[aVo.techID] + aVo:getTechSkillPointByIDAndLv()
			end
		end
		local length=#accessorytechCfg.lvNeed
		for techID,techPoint in pairs(techPointTb) do
			local lv
			local nextPoint
			for i=1,length do
				local exp=accessorytechCfg.lvNeed[i]
				if(techPoint<exp)then
					lv=i - 1
					nextPoint=exp
					break
				end
			end
			if(lv==nil)then
				lv=length
			end
			self.techExtra[techID]={lv,nextPoint,techPoint}
		end
	end
	return self.techExtra
end

--初始化精炼和科技属性详情的tableView
function accessoryDialogTank:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		if(base.accessoryTech==1)then
			return 5
		elseif(accessoryVoApi:succinctIsOpen())then
			return 2
		else
			return 0
		end
	elseif fn=="tableCellSizeForIndex" then
		if(idx==0)then
			return CCSizeMake(G_VisibleSizeWidth - 60,40)
		elseif(idx==1)then
			local content,height=self:getPurifyContent()
			return CCSizeMake(G_VisibleSizeWidth - 60,height + 6)
		elseif(idx==2)then
			return CCSizeMake(G_VisibleSizeWidth - 60,50)
		elseif(idx==3)then
			local content,height=self:getTechContent()
			return CCSizeMake(G_VisibleSizeWidth - 60,height + 6)
		elseif(idx==4)then
			local tankStr
			local tankID=self.tankID
			if(tankID==1)then
				tankStr=getlocal("tanke")
			elseif(tankID==2)then
				tankStr=getlocal("jianjiche")
			elseif(tankID==3)then
				tankStr=getlocal("zixinghuopao")
			elseif(tankID==4)then
				tankStr=getlocal("huojianche")
			end
			local lb1=GetTTFLabelWrap(getlocal("accessory_techSkill_unlock2",{tankStr}),24,CCSizeMake(G_VisibleSizeWidth - 100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			local lb2=GetTTFLabelWrap(getlocal("accessory_techSkill_cover"),24,CCSizeMake(G_VisibleSizeWidth - 100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			return CCSizeMake(G_VisibleSizeWidth - 60,lb1:getContentSize().height + lb2:getContentSize().height + 10)
		end
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		if(idx==0)then
			local purifyTitle=GetTTFLabel(getlocal("accessory_purifyAdd",{SizeOfTable(self:getPurifyExtraAtt())}),24)
			purifyTitle:setColor(G_ColorYellowPro)
			purifyTitle:setAnchorPoint(ccp(0,0.5))
			purifyTitle:setPosition(15,20)
			cell:addChild(purifyTitle)
		elseif(idx==1)then
			local content,height=self:getPurifyContent()
			local posY=height - 3
			for k,v in pairs(content) do
				local pointSp=v[1]
				pointSp:setPosition(ccp(20,posY - v[2]:getContentSize().height/2))
				cell:addChild(pointSp)
				local lb=v[2]
				lb:setPosition(ccp(40,posY - v[2]:getContentSize().height/2))
				cell:addChild(lb)
				posY=posY - lb:getContentSize().height
			end
		elseif(idx==2)then
			local totalPoint=0
			for techID,skillData in pairs(self:getTechExtraEffect()) do
				if(skillData[3]>0)then
					totalPoint=totalPoint + skillData[3]
				end
			end
			local techTitle=GetTTFLabel(getlocal("accessory_techPoint",{totalPoint}),24)
			techTitle:setColor(G_ColorYellowPro)
			techTitle:setAnchorPoint(ccp(0,0.5))
			techTitle:setPosition(15,20)
			cell:addChild(techTitle)
		elseif(idx==3)then
			local content,height=self:getTechContent()
			for k,v in pairs(content) do
				v:setPositionY(v:getPositionY() + height)
				cell:addChild(v)
			end
		else
			local tankStr
			local tankID=self.tankID
			if(tankID==1)then
				tankStr=getlocal("tanke")
			elseif(tankID==2)then
				tankStr=getlocal("jianjiche")
			elseif(tankID==3)then
				tankStr=getlocal("zixinghuopao")
			elseif(tankID==4)then
				tankStr=getlocal("huojianche")
			end
			local lb2=GetTTFLabelWrap(getlocal("accessory_techSkill_cover"),24,CCSizeMake(G_VisibleSizeWidth - 100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
			lb2:setColor(G_ColorYellowPro)
			lb2:setAnchorPoint(ccp(0,0))
			lb2:setPosition(ccp(20,0))
			cell:addChild(lb2)
			local lb1=GetTTFLabelWrap(getlocal("accessory_techSkill_unlock2",{tankStr}),24,CCSizeMake(G_VisibleSizeWidth - 100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
			lb1:setColor(G_ColorYellowPro)
			lb1:setAnchorPoint(ccp(0,0))
			lb1:setPosition(20,lb2:getContentSize().height + 5)
			cell:addChild(lb1)
		end
		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then
	end
end

--获取精炼激活的各个额外属性详情的显示内容
function accessoryDialogTank:getPurifyContent()
	local result={}
	local totalHeight=0
	for k,v in pairs(self:getPurifyExtraAtt()) do
		local pointSp=CCSprite:createWithSpriteFrameName("circlenormal.png")
		local lb=GetTTFLabelWrap(getlocal("accessory_addAtt",{G_getPropertyStr(k),v.."%%"}),22,CCSizeMake(520,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		lb:setAnchorPoint(ccp(0,0.5))
		totalHeight=totalHeight + lb:getContentSize().height
		table.insert(result,{pointSp,lb})
	end
	if(#result==0)then
		local pointSp=CCSprite:createWithSpriteFrameName("circlenormal.png")
		local lb=GetTTFLabelWrap(getlocal("accessory_techNoPurify"),22,CCSizeMake(520,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		lb:setAnchorPoint(ccp(0,0.5))
		totalHeight=totalHeight + lb:getContentSize().height
		table.insert(result,{pointSp,lb})
	end
	return result,totalHeight
end

--获取科技激活的各个技能详情的显示内容
function accessoryDialogTank:getTechContent()
	local result={}
	local totalHeight=-30
	local function onClickExpand(tag,fn)
		if(tag)then
			if(self.techExpandTb==nil)then
				self.techExpandTb={}
			end
			local offset
			if(self.techExpandTb[tag]==1)then
				self.techExpandTb[tag]=nil
				offset=100
			else
				self.techExpandTb[tag]=1
				offset=-100
			end
			local recordPoint=self.detailTv:getRecordPoint()
			self.detailTv:reloadData()
			self.detailTv:recoverToRecordPoint(ccp(recordPoint.x,recordPoint.y + offset))
		end
	end
	local maxLv=accessoryVoApi:getTechSkillMaxLv()
	local tankStr
	local tankID=self.tankID
	if(tankID==1)then
		tankStr=getlocal("tanke")
	elseif(tankID==2)then
		tankStr=getlocal("jianjiche")
	elseif(tankID==3)then
		tankStr=getlocal("zixinghuopao")
	elseif(tankID==4)then
		tankStr=getlocal("huojianche")
	end
	for techID,skillData in pairs(self:getTechExtraEffect()) do
		local expandItem
		local expandFlag
		if(self.techExpandTb and self.techExpandTb[techID]==1)then
			expandItem=GetButtonItem("sYellowSubBtn.png","sYellowSubBtn.png","sYellowSubBtn.png",onClickExpand,techID)
			expandFlag=true
		else
			expandItem=GetButtonItem("sYellowAddBtn.png","sYellowAddBtn.png","sYellowAddBtn.png",onClickExpand,techID)
			expandFlag=false
		end
		local expandBtn=CCMenu:createWithItem(expandItem)
		expandBtn:setTouchPriority(-(self.layerNum-1)*20-4)
		expandBtn:setPosition(40,totalHeight)
		table.insert(result,expandBtn)
		local maxPoint=accessorytechCfg.lvNeed[maxLv]
		local techName=getlocal("accessory_techName_"..techID)
		local techLb=GetTTFLabel(techName.." ("..skillData[3].."/"..maxPoint..")",24)
		techLb:setAnchorPoint(ccp(0,0.5))
		techLb:setPosition(80,totalHeight)
		table.insert(result,techLb)
		totalHeight=totalHeight - 50
		if(expandFlag)then
			local skillID=accessorytechCfg.techSkill["t"..self.tankID][techID]
			local lv=skillData[1]
			if(lv>0)then
				local skillName=getlocal(abilityCfg[skillID][lv].name)
				local skillNameLb
				if(lv<maxLv)then
					skillNameLb=GetTTFLabel(getlocal("allianceSkillName",{skillName,lv}).." ("..getlocal("command_finish_tip")..")",22)
				else
					skillNameLb=GetTTFLabel(getlocal("allianceSkillName",{skillName,lv}).." ("..getlocal("alliance_lvmax")..")",22)
				end
				skillNameLb:setColor(G_ColorGreen)
				skillNameLb:setAnchorPoint(ccp(0,0.5))
				skillNameLb:setPosition(80,totalHeight)
				table.insert(result,skillNameLb)
				totalHeight=totalHeight - 15
				local param={}
				if(abilityCfg[skillID][lv].value1)then
					param[1]=abilityCfg[skillID][lv].value1*100
				end
				if(abilityCfg[skillID][lv].value2)then
					param[2]=abilityCfg[skillID][lv].value2*100
				end
				local skillDesc=getlocal(abilityCfg[skillID][lv].desc,param)
				local skillDescLb=GetTTFLabelWrap(skillDesc,22,CCSizeMake(G_VisibleSizeWidth - 160,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
				skillDescLb:setColor(G_ColorGreen)
				skillDescLb:setAnchorPoint(ccp(0,1))
				skillDescLb:setPosition(80,totalHeight)
				table.insert(result,skillDescLb)
				totalHeight=totalHeight - skillDescLb:getContentSize().height - 15
			end
			if(lv<maxLv)then
				local nextLv=lv + 1
				local skillName=getlocal(abilityCfg[skillID][nextLv].name)
				local skillNameLb=GetTTFLabel(getlocal("allianceSkillName",{skillName,nextLv}).." ("..getlocal("scheduleChapter",{skillData[3],skillData[2]})..")",22)
				skillNameLb:setColor(G_ColorGray)
				skillNameLb:setAnchorPoint(ccp(0,0.5))
				skillNameLb:setPosition(80,totalHeight)
				table.insert(result,skillNameLb)
				totalHeight=totalHeight - 15
				local param={}
				if(abilityCfg[skillID][nextLv].value1)then
					param[1]=abilityCfg[skillID][nextLv].value1*100
				end
				if(abilityCfg[skillID][nextLv].value2)then
					param[2]=abilityCfg[skillID][nextLv].value2*100
				end
				local skillDesc=getlocal(abilityCfg[skillID][nextLv].desc,param)
				local skillDescLb=GetTTFLabelWrap(skillDesc,22,CCSizeMake(G_VisibleSizeWidth - 160,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
				skillDescLb:setColor(G_ColorGray)
				skillDescLb:setAnchorPoint(ccp(0,1))
				skillDescLb:setPosition(80,totalHeight)
				table.insert(result,skillDescLb)
				totalHeight=totalHeight - skillDescLb:getContentSize().height - 15
			end
			totalHeight=totalHeight - 15
		else
			totalHeight=totalHeight - 20
		end
	end
	totalHeight=totalHeight + 20
	return result,-totalHeight
end

--初始化上面的大坦克图片
function accessoryDialogTank:initTank()
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
	local tankBg=CCSprite:create("public/accessoryOperateBg.jpg")
	tankBg:setScale((G_VisibleSizeWidth - 42)/tankBg:getContentSize().width)
	tankBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 400)
	self.bgLayer:addChild(tankBg)
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	local tankIcon=CCSprite:createWithSpriteFrameName("LineTank"..self.tankID..".png")
	self.bgLayer:addChild(tankIcon)
	tankIcon:setAnchorPoint(ccp(0.5,1))
	if(G_isIphone5()==false)then
		tankIcon:setScale(0.9)
	end
	local posY=G_VisibleSizeHeight - 250
	tankIcon:setPosition(ccp(G_VisibleSizeWidth/2,posY))
end

--初始化各个配件图标的位置
function accessoryDialogTank:initPos()
	local tankWidth=416
	local tankHeight=256
	if(G_isIphone5()==false)then
		tankWidth=tankWidth*0.9
		tankHeight=tankHeight*0.9
	end
	local centerX=G_VisibleSizeWidth/2
	local centerY=G_VisibleSizeHeight - 250 - tankHeight/2
	local leftX=centerX - tankWidth/2 - 35
	local midLeftX=centerX - 80
	local midRightX=centerX + 80
	local rightX=centerX + tankWidth/2 + 35
	local upY=centerY + tankHeight/2 + 35
	local midUpY=centerY + tankHeight/2 - 90 + 40
	local midBtmY=centerY - tankHeight/2 + 90 - 40
	local btmY=centerY - tankHeight/2 - 35
	self.posTb={}
	self.posTb[1]=ccp(leftX,midBtmY)
	self.posTb[2]=ccp(rightX,midUpY)
	self.posTb[3]=ccp(midLeftX,upY)
	self.posTb[4]=ccp(leftX,midUpY)
	self.posTb[5]=ccp(rightX,midBtmY)
	self.posTb[6]=ccp(midRightX,btmY)
	self.posTb[7]=ccp(midLeftX,btmY)
	self.posTb[8]=ccp(midRightX,upY)
end

--初始化装备的配件
function accessoryDialogTank:initAccessory()
	self.icons={}
	for k,v in pairs(self.posTb) do
		local aVo=self.equips["p"..k]
		local aIcon
		local function onClickIcon(hd,fn,tag)
			if G_checkClickEnable()==false then
				do return end
			else
				base.setWaitTime=G_getCurDeviceMillTime()
			end
 			self:showAccessoryDetail(tag)
		end
		local function onClickLock(hd,fn,tag)
			if G_checkClickEnable()==false then
				do return end
			else
				base.setWaitTime=G_getCurDeviceMillTime()
			end
			if(tag>accessoryCfg.unLockPart)then
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_notOpen"),30)
			else
				local unlockLv=accessoryCfg.partUnlockLv[tag]
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_part_unlock_desc",{unlockLv}),30)
			end
		end
		local function onClickEmptyGrid()
			if G_checkClickEnable()==false then
				do return end
			else
				base.setWaitTime=G_getCurDeviceMillTime()
			end
			self:onClickEmptyGrid(k)
		end
		local iconBg=CCSprite:createWithSpriteFrameName("accessoryMetalBg.png")
		iconBg:setPosition(v)
		self.bgLayer:addChild(iconBg)
		if(aVo~=nil)then
			aIcon=accessoryVoApi:getAccessoryIcon(aVo.type,60,80,onClickIcon)
			local rankTip=CCSprite:createWithSpriteFrameName("IconLevel.png")
			local rankLb=GetTTFLabel(aVo.rank,30)
			rankLb:setPosition(ccp(rankTip:getContentSize().width/2,rankTip:getContentSize().height/2))
			rankTip:addChild(rankLb)
			rankTip:setScale(0.5)
			rankTip:setAnchorPoint(ccp(0,1))
			rankTip:setPosition(ccp(0,100))
			aIcon:addChild(rankTip)
			local lvLb=GetTTFLabel(getlocal("fightLevel",{aVo.lv}),20)
			lvLb:setAnchorPoint(ccp(1,0))
			lvLb:setPosition(ccp(85,5))
			aIcon:addChild(lvLb)
			if(aVo.bind==1)then
				local blingSp=CCSprite:createWithSpriteFrameName("accessoryBling.png")
				blingSp:setOpacity(0)
				blingSp:setPosition(aIcon:getContentSize().width/2,aIcon:getContentSize().height - blingSp:getContentSize().height/4 - 5)
				aIcon:addChild(blingSp)
				local fadeIn=CCFadeIn:create(0.6)
				local moveTo1=CCMoveTo:create(0.6,ccp(aIcon:getContentSize().width/2,aIcon:getContentSize().height/2 - 5))
				local fadeInArr=CCArray:create()
				fadeInArr:addObject(fadeIn)
				fadeInArr:addObject(moveTo1)
				local fadeInSpawn=CCSpawn:create(fadeInArr)
				local fadeOut=CCFadeOut:create(0.6)
				local moveTo2=CCMoveTo:create(0.6,ccp(aIcon:getContentSize().width/2,blingSp:getContentSize().height/4 - 5))
				local fadeOutArr=CCArray:create()
				fadeOutArr:addObject(fadeOut)
				fadeOutArr:addObject(moveTo2)
				local fadeOutSpawn=CCSpawn:create(fadeOutArr)
				local delay=CCDelayTime:create(0.8)
				local function onMoveEnd()
					blingSp:setPosition(aIcon:getContentSize().width/2,aIcon:getContentSize().height - blingSp:getContentSize().height/4 - 5)
				end
				local moveEndFunc=CCCallFunc:create(onMoveEnd)
				local acArr=CCArray:create()
				acArr:addObject(fadeInSpawn)
				acArr:addObject(fadeOutSpawn)
				acArr:addObject(delay)
				acArr:addObject(moveEndFunc)
				local seq=CCSequence:create(acArr)
				local repeatForever=CCRepeatForever:create(seq)
				blingSp:runAction(repeatForever)
				if(aVo:getConfigData("quality")>3 and base.accessoryTech==1)then
					local techTip=CCSprite:createWithSpriteFrameName("IconLevelBlue.png")
					local techLb=GetTTFLabel(aVo.techLv or 0,30)
					techLb:setPosition(getCenterPoint(techTip))
					techTip:addChild(techLb)
					techTip:setScale(0.5)
					techTip:setAnchorPoint(ccp(1,1))
					techTip:setPosition(ccp(98,100))
					aIcon:addChild(techTip)
				end
				--红配晋升开关开启 && 红色配件 && 已经绑定
				if base.redAccessoryPromote == 1 and aVo:getConfigData("quality") == 5 then
					local promoteLvBg = CCSprite:createWithSpriteFrameName("accessoryPromote_IconLevel.png")
					local promoteLvLb = GetTTFLabel(aVo.promoteLv or 0, 30)
					promoteLvLb:setPosition(getCenterPoint(promoteLvBg))
					promoteLvBg:addChild(promoteLvLb)
					promoteLvBg:setScale(0.5)
					promoteLvBg:setAnchorPoint(ccp(0, 0))
					promoteLvBg:setPosition(ccp(0, 0))
					aIcon:addChild(promoteLvBg)
				end
			end
		else
			if(accessoryVoApi:checkPartUnlock(k))then
				aIcon=GetBgIcon("accessoryshadow_"..k..".png",onClickEmptyGrid,nil,60,80)
				if(accessoryVoApi.unUsedAccessory~=nil and accessoryVoApi.unUsedAccessory["t"..self.tankID]~=nil and accessoryVoApi.unUsedAccessory["t"..self.tankID]["p"..k]~=nil)then
					local capInSet1 = CCRect(17, 17, 1, 1)
					local function touchClick()
					end
					local newsIcon =LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png",capInSet1,touchClick)
					newsIcon:setScale(0.5)
					newsIcon:setPosition(ccp(70,70))
					aIcon:addChild(newsIcon)
				end
			else
				aIcon=GetBgIcon("accessoryshadow_"..k..".png",onClickLock,nil,60,80)
				local lockIcon=CCSprite:createWithSpriteFrameName("LockIcon.png")
				lockIcon:setScale(30/lockIcon:getContentSize().width)
				lockIcon:setPosition(ccp(40,40))
				aIcon:addChild(lockIcon)
				if(k<=accessoryCfg.unLockPart)then
					local unlockLb=GetTTFLabel(getlocal("fightLevel",{accessoryCfg.partUnlockLv[k]}),20)
					unlockLb:setAnchorPoint(ccp(0.5,0))
					unlockLb:setPosition(ccp(40,2))
					unlockLb:setColor(G_ColorYellowPro)
					aIcon:addChild(unlockLb)
				end
			end
		end
		aIcon:setTouchPriority(-(self.layerNum-1)*20-3)
		aIcon:setIsSallow(true)
		aIcon:setTag(k)
		aIcon:setPosition(v)
		self.bgLayer:addChild(aIcon,1)
		self.icons[k]=aIcon
	end
end

function accessoryDialogTank:getShareData()
	if self.posTb and self.equips then
		local share={}
		share.stype=4 --配件分享的类型
		share.name=playerVoApi:getPlayerName()
		share.tid=self.tankID --当前坦克id
		local accessoryTb={}
		for k,v in pairs(self.posTb) do
			local aVo=self.equips["p"..k]
			if aVo~=nil then
				local rt=aVo.type --配件类型
				local rf=aVo.rank --改造等级
				local lv=aVo.lv --强化等级
				local promoteLv = aVo.promoteLv --晋升等级
				local bd=aVo.bind --是否绑定
				local ql=aVo:getConfigData("quality") --配件品质
				local tech={aVo.techID,aVo.techLv} --配件科技
				local accessory={rt=rt,rf=rf,lv=lv,promoteLv=promoteLv,bd=bd,ql=ql,tech=tech}
				accessoryTb[k]=accessory
			else
				accessoryTb[k]="-"
			end
		end
		share.acc=accessoryTb --各部位配件
		local porperty={}
		local gsNum=0
		local attAdd={0,0,0,0,0,0,0,0,0,0,0,0,0,0}
		if(self.equips~=nil)then
			for k,v in pairs(self.equips) do
				if(v~=nil)then
					gsNum=gsNum+v:getGS()+v:getGsAdd()
					local att=v:getAttWithSuccinct()
					for kk,vv in pairs(att) do
						attAdd[kk]=attAdd[kk]+vv
					end
					
				end
			end
		end
		share.gsNum=gsNum --配件强度
		for i=1,4 do
			local addValue=attAdd[i]
			porperty[i]=addValue
		end
		share.p=porperty --属性加成
		if base.accessoryTech==1 then
			local skillTb={}
			local point=0
			local techExtra=self:getTechExtraEffect()
			for techID,skillData in pairs(techExtra) do
				if(skillData[3]>0)then
					point=point+skillData[3]
				end
				local skillID=accessorytechCfg.techSkill["t"..self.tankID][techID]
				local lv=skillData[1]
				local skill={skillID,lv}
				table.insert(skillTb,skill)
			end
			if point>0 then
				share.tech={point,skillTb} --配件科技
			end
		end
		if base.succinct==1 then
			local purifyExtra=self:getPurifyExtraAtt()
			local point=SizeOfTable(purifyExtra) --精炼激活数
			if point>0 then
				local purify={}
				purify[1]=point
				purify[2]={}
				local idx=1
				for k,v in pairs(purifyExtra) do
					purify[2][idx]={k,v}
					idx=idx+1
				end
				share.purify=purify --配件精炼
			end
		end
	    return share
	end
	return nil
end

--刷新属性信息
function accessoryDialogTank:refreshInfo()
	local gsNum=0
	local attAdd={0,0,0,0,0,0,0,0,0,0,0,0,0,0}

	if(self.equips~=nil)then
		for k,v in pairs(self.equips) do
			if(v~=nil)then
				gsNum=gsNum+v:getGS()+v:getGsAdd()
				local att=v:getAttWithSuccinct()
				for kk,vv in pairs(att) do
					attAdd[kk]=attAdd[kk]+vv
				end
				
			end
		end
	end
	
	local endIndex
	if(base.accessoryTech==1)then
		endIndex=6
	elseif(base.succinct==1)then
		endIndex=5
	else
		endIndex=4
	end
	for i=1,endIndex do
		local lb=self.infoLayer:getChildByTag(200 + i)
		if(lb)then
			lb=tolua.cast(lb,"CCLabelTTF")
			if(i<5)then
				if(accessoryCfg.attEffect[i]==1)then
					lb:setString(getlocal("accessory_attAdd_"..i,{attAdd[i].."%%"}))
				else
					lb:setString(getlocal("accessory_attAdd_"..i,{attAdd[i]}))
				end
			elseif(i==5)then
				lb:setString(getlocal("accessory_purifyAdd",{SizeOfTable(self:getPurifyExtraAtt())}))
			elseif(i==6)then
				local totalPoint=0
				for techID,skillData in pairs(self:getTechExtraEffect()) do
					if(skillData[3]>0)then
						totalPoint=totalPoint + skillData[3]
					end
				end
				lb:setString(getlocal("accessory_techPoint",{totalPoint}))
			end
		end
	end
	self.gsLb:setString(getlocal("accessory_gsAdd",{gsNum}))
	if(self.detailTv)then
		self.detailTv:reloadData()
	end
end

function accessoryDialogTank:refresh()
	self.needRefresh=false
	for k,v in pairs(self.icons) do
		if(v~=nil)then
			self.bgLayer:removeChild(v,true)
			self.icons[k]=nil
		end
	end
	self.icons=nil
	self.equips=accessoryVoApi:getTankAccessories(self.tankID)
	self.purifyAtt=nil
	self.techExtra=nil
	self.techExpandTb={}
	self:refreshInfo()
	self:initAccessory()
end

function accessoryDialogTank:showAccessoryDetail(index)
	local aVo=self.equips["p"..index]
	if(aVo~=nil)then
		self.isShow=false
		local function onCloseOperate(event,data)
			self.isShow=true
			if(self.needRefresh)then
				self:refresh()
			end
			eventDispatcher:removeEventListener("accessory.dialog.closeOperate",onCloseOperate)
		end
		eventDispatcher:addEventListener("accessory.dialog.closeOperate",onCloseOperate)
		accessoryVoApi:showOprateDialog(self.layerNum+1,self.tankID,index)
	end
end

function accessoryDialogTank:onClickEmptyGrid(part)
	local abag=accessoryVoApi:getAccessoryBag()
	if(abag~=nil and #abag>0)then
		local maxQuality=0
		local maxRank=0
		local maxLv=0
		local maxAccessory=nil
		for k,v in pairs(abag) do
			if(v:getConfigData("tankID")==self.tankID and v:getConfigData("part")==part)then
				local quality=tonumber(v:getConfigData("quality"))
				if(quality>maxQuality)then
					maxQuality=quality
					maxRank=v.rank
					maxLv=v.lv
					maxAccessory=v
				elseif(quality==maxQuality)then
					if(v.rank>maxRank)then
						maxRank=v.rank
						maxLv=v.lv
						maxAccessory=v
					elseif(v.rank==maxRank)then
						if(v.lv>maxLv)then
							maxLv=v.lv
							maxAccessory=v
						end
					end
				end
			end
		end
		if(maxAccessory~=nil)then
			local type=0
			if accessoryVoApi:succinctIsOpen() then
				type=2
			end
			accessoryVoApi:showSmallDialog(self.layerNum+1,1,maxAccessory,self.parent,nil,nil,type)
			do return end
		end
	end
	local fbag=accessoryVoApi:getFragmentBag()
	if(fbag~=nil and #fbag>0)then
		local maxQuality=0
		local multiFragmentNum=0
		local maxFragment=nil
		for k,v in pairs(fbag) do
			if(v:getConfigData("output")=="")then
				multiFragmentNum=v.num
			elseif(tonumber(v:getConfigData("quality"))>maxQuality)then
				local aCfg=accessoryCfg.aCfg[v:getConfigData("output")]
				if(aCfg.tankID==tankStr and aCfg.part==partStr and v.num+multiFragmentNum>=tonumber(v:getConfigData("composeNum")))then
					maxQuality=tonumber(v:getConfigData("quality"))
					maxFragment=v
				end
			end
		end
		if(maxFragment~=nil)then
			accessoryVoApi:showSmallDialog(self.layerNum+1,2,maxFragment,self.parent)
			do return end
		end
	end
	local function onConfirm()
		self.parent.parent:close()
		if(playerVoApi:getPlayerLevel()<accessoryCfg.accessoryUnlockLv)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("elite_challenge_unlock_level",{accessoryCfg.accessoryUnlockLv}),30)
		else
			accessoryVoApi:showSupplyDialog(self.layerNum)
		end
	end
	smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("accessory_no_accessory_tip"),nil,self.layerNum+1)
end

--滑出滑入属性详情
function accessoryDialogTank:switchShowDetail()
	if(self.opening)then
		do return end
	end
	if(self.open==true)then
		if(self.infoLayer)then
			self.opening=true
			self.detailTv:setVisible(false)
			local moveTo=CCMoveTo:create(0.3,ccp(20,24))
			local function onMoveEnd()
				self.opening=false
				self.open=false
				eventDispatcher:dispatchEvent("accessory.dialog.tankDetail",{type=0})
			end
			local callFunc=CCCallFunc:create(onMoveEnd)
			local acArr=CCArray:create()
			acArr:addObject(moveTo)
			acArr:addObject(callFunc)
			local seq=CCSequence:create(acArr)
			self.infoLayer:runAction(seq)
			local infoBg=tolua.cast(self.infoLayer:getChildByTag(101),"CCScale9Sprite")
			local scaleTo=CCScaleTo:create(0.3,1,1)
			infoBg:runAction(scaleTo)
			local titleLb2=tolua.cast(self.titleItem:getChildByTag(100),"CCLabelTTF")
			titleLb2:setString(getlocal("click_to_open"))
			local arrow=tolua.cast(self.titleItem:getChildByTag(101),"CCSprite")
			arrow:setRotation(-90)
		end
	else
		if(self.infoLayer)then
			self.opening=true
			eventDispatcher:dispatchEvent("accessory.dialog.tankDetail",{type=1})
			local moveTo=CCMoveTo:create(0.3,ccp(20,G_VisibleSizeHeight - 160 - self.infoLayer:getContentSize().height))
			local function onMoveEnd()
				self.opening=false
				self.open=true
				self.detailTv:setVisible(true)
			end
			local callFunc=CCCallFunc:create(onMoveEnd)
			local acArr=CCArray:create()
			acArr:addObject(moveTo)
			acArr:addObject(callFunc)
			local seq=CCSequence:create(acArr)
			self.infoLayer:runAction(seq)
			local infoBg=tolua.cast(self.infoLayer:getChildByTag(101),"CCScale9Sprite")
			local scaleTo=CCScaleTo:create(0.3,1,(G_VisibleSizeHeight - 180)/infoBg:getContentSize().height)
			infoBg:runAction(scaleTo)
			local titleLb2=tolua.cast(self.titleItem:getChildByTag(100),"CCLabelTTF")
			titleLb2:setString(getlocal("click_to_close"))
			local arrow=tolua.cast(self.titleItem:getChildByTag(101),"CCSprite")
			arrow:setRotation(90)
		end
	end
end

function accessoryDialogTank:dispose()
	base:removeFromNeedRefresh(self)
	self.posTb=nil
	self.equips=nil
	self.tankID=nil
	self.size=nil
	self.bgLayer=nil
	self.parent=nil
	self.infoLayer=nil
	self.purifyAtt=nil
	self.techExtra=nil
	self.techExpandTb=nil
	self.isShow=nil
	self.needRefresh=nil
	spriteController:removePlist("public/acAnniversary.plist")
    spriteController:removeTexture("public/acAnniversary.png")
end