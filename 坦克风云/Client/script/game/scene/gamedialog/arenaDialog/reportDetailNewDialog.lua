reportDetailNewDialog=commonDialog:new()

--rtype:战报的类型  1：军事演习  2：超级武器抢夺
function reportDetailNewDialog:new(layerNum,report,chatReport,battleType,rtype)
	local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.layerNum=ayerNum
	self.report=report
	self.chatReport=chatReport
	self.battleType=battleType
    self.rtype=rtype or 1
    self.replayBtn=nil
    self.deleteBtn=nil
	self.sendBtn=nil
	self.sendSuccess=false
	self.canSand=true
	self.isNPC=false

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
    spriteController:addPlist("public/reportyouhua.plist")
    spriteController:addTexture("public/reportyouhua.png")
    spriteController:addPlist("public/youhuaUI3.plist")
    spriteController:addTexture("public/youhuaUI3.png")
  	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	-- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/world_ground.plist")

	return nc
end

function reportDetailNewDialog:initTableView()
	local panelBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelBgShade.png",CCRect(30,0,2,3),function ()end)
    panelBg:setAnchorPoint(ccp(0.5,0))
    panelBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-82))
    panelBg:setPosition(G_VisibleSizeWidth/2,5)
    self.bgLayer:addChild(panelBg)
	if self.panelLineBg then
		self.panelLineBg:setVisible(false)
	end
	if self.panelTopLine then
		self.panelTopLine:setVisible(true)
    	self.panelTopLine:setPositionY(G_VisibleSizeHeight-82)
	end

	if self.report==nil or SizeOfTable(self.report)==0 then
		do return end
	end

	self.baseLayer=CCLayer:create()
	self.detailLayer=CCLayer:create()
	self.baseLayer:setPosition(0,0)
	self.detailLayer:setPosition(G_VisibleSizeWidth,0)
	self.bgLayer:addChild(self.baseLayer,1)
	self.bgLayer:addChild(self.detailLayer,1)

	local isVictory=self.report.isVictory --1:胜利, 否则:失败

	local resultBg,resultPic,targetStr
	if isVictory==1 then
		resultBg="reportSuccessBg.png"
		if G_getCurChoseLanguage()=="cn" then
			resultPic="reportSuccessIcon_cn.png"
		elseif G_getCurChoseLanguage()=="tw" then
			resultPic="reportSuccessIcon_tw.png"
		else
			resultPic="reportSuccessIcon_en.png"
		end
		if self.rtype==1 then
			targetStr=getlocal("battleReport_attack_type2",{getlocal("arena_title")})
		elseif self.rtype==2 then
			targetStr=getlocal("battleReport_attack_type2",{getlocal("super_weapon_title_1")..getlocal("super_weapon_title_3")})
		end
	else
		resultBg="reportFailBg.png"
		if G_getCurChoseLanguage()=="cn" then
			resultPic="reportFailIcon_cn.png"
		elseif G_getCurChoseLanguage()=="tw" then
			resultPic="reportFailIcon_tw.png"
		else
			resultPic="reportFailIcon_en.png"
		end
		if self.rtype==1 then
			targetStr=getlocal("battleReport_defend_type2",{getlocal("arena_title")})
		elseif self.rtype==2 then
			targetStr=getlocal("battleReport_defend_type2",{getlocal("super_weapon_title_1")..getlocal("super_weapon_title_3")})
		end
	end
	if self.rtype==3 then
		targetStr=getlocal("expedition_report_title",{self.report.place})
	end

	local infoBgSize=CCSizeMake(640,116)
	local infoBg=CCSprite:createWithSpriteFrameName(resultBg)
	infoBg:setAnchorPoint(ccp(0.5,1))
	infoBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-82)
	self.bgLayer:addChild(infoBg)

	--战斗结果
	if resultPic then
		local resultSp=CCSprite:createWithSpriteFrameName(resultPic)
		resultSp:setAnchorPoint(ccp(0,0.5))
		resultSp:setPosition(50,infoBgSize.height/2)
		infoBg:addChild(resultSp)
	end
	local fontSize=22
	if G_isAsia() == false then
		fontSize = 15
	end
	if targetStr then
		local adaH = 0
		if G_isAsia() == true or G_getCurChoseLanguage() == "ko" then
			adaH = 30
		end
		local targetLb=GetTTFLabelWrap(targetStr,fontSize,CCSizeMake(300,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentTop)
		targetLb:setAnchorPoint(ccp(1,1))
		targetLb:setColor(G_ColorYellowPro)
		targetLb:setPosition(infoBgSize.width-20,infoBgSize.height/2+targetLb:getContentSize().height+30-adaH)
		infoBg:addChild(targetLb)

		--战斗时间
		if self.report and self.report.time then
			local timeLb=GetTTFLabel(emailVoApi:getTimeStr(self.report.time),fontSize)
			timeLb:setAnchorPoint(ccp(1,1))
			timeLb:setPosition(targetLb:getPositionX(),infoBgSize.height/2-30)
			infoBg:addChild(timeLb)
		end
	end

	local function formatInfoData(_id,_info)
		if _info then
			return {
				id=_id,
				fight=_info[1], 		--战力
				vip=_info[2],			--VIP等级
				rank=_info[3],			--军衔
				pic=_info[4],			--头像
				hfid=_info[5],			--头像框
				level=_info[6],			--等级
				allianceName=_info[7],	--联盟名称
			}
		end
	end
	local myInfo,enemyInfo,myNameStr,enemyNameStr
	if self.report.type==1 then
		myInfo=formatInfoData(self.report.uid,self.report.attInfo)
		enemyInfo=formatInfoData(self.report.enemyId,self.report.defInfo)
	else
		myInfo=formatInfoData(self.report.uid,self.report.defInfo)
		enemyInfo=formatInfoData(self.report.enemyId,self.report.attInfo)
	end
	if myInfo==nil then
		myInfo={
			id=self.report.uid,
			fight=nil,
			vip=nil,
			rank=nil,
			pic=headCfg.default,
			hfid=headFrameCfg.default,
			level=nil;
			allianceName=nil,
		}
	end
	if enemyInfo==nil then
		enemyInfo={
			id=self.report.enemyId,
			fight=nil,
			vip=nil,
			rank=nil,
			pic=headCfg.default,
			hfid=headFrameCfg.default,
			level=nil;
			allianceName=nil,
		}
	end
	myNameStr=self.report.name
	
	if self.rtype==1 then
		enemyNameStr=arenaVoApi:getNpcNameById(tonumber(self.report.enemyId) or 0,self.report.enemyName)
		self.isNPC=arenaVoApi:isNPC(tonumber(self.report.enemyId) or 0)
	elseif self.rtype==2 then
		self.isNPC=superWeaponVoApi:isNPC(tonumber(self.report.enemyId) or 0)
		if self.isNPC==true then
			enemyNameStr=getlocal("super_weapon_rob_npc_name_"..self.report.enemyId)
		else
			enemyNameStr=self.report.enemyName
		end
	elseif self.rtype==3 then
		self.isNPC=((tonumber(self.report.enemyId)==0) or false)
		enemyNameStr=self.report.enemyName
	end

	--军演排名
	local rankChange = self.report.rankChange
	local rankStr=""
	local color=G_ColorWhite
	local enemyRankStr=""
	local enemyRankColor=G_ColorWhite
	if self.rtype==1 then
		if rankChange==0 then
			rankStr=getlocal("arena_rank_no_change")
			enemyRankStr=getlocal("arena_rank_no_change")
		elseif rankChange>0 then
			rankStr=getlocal("arena_rank_up",{rankChange})
			color=G_ColorGreen
			enemyRankStr=getlocal("arena_rank_down",{rankChange})
			enemyRankColor=G_ColorRed
		else
			rankStr=getlocal("arena_rank_down",{0-rankChange})
			color=G_ColorRed
			enemyRankStr=getlocal("arena_rank_up",{0-rankChange})
			enemyRankColor=G_ColorGreen
		end
		rankStr=getlocal("rank").."：<rayimg>"..rankStr
		enemyRankStr=getlocal("rank").."：<rayimg>"..enemyRankStr
	end

	--我方信息
	local iconWidth,infoWidth,infoHeight=90,630/2-1,110
	local myInfoBg=LuaCCScale9Sprite:createWithSpriteFrameName("reportBlueBg.png",CCRect(4, 4, 1, 1),function ()end)
    myInfoBg:setAnchorPoint(ccp(0.5,1))
    myInfoBg:setContentSize(CCSizeMake(infoWidth,infoHeight))
    myInfoBg:setPosition(5+infoWidth/2,infoBg:getPositionY()-infoBgSize.height)
    self.bgLayer:addChild(myInfoBg)
    if myInfo then
    	local fight,pic,fhid=(tonumber(myInfo.fight) or 0),(myInfo.pic or headCfg.default),(myInfo.fhid or headFrameCfg.default)
    	local function showMyInfo()
    		if myInfo.fight then
    			local player={uid=myInfo.id,name=myNameStr,level=myInfo.level,pic=pic,fhid=fhid,vip=myInfo.vip,rank=myInfo.rank,fight=myInfo.fight,alliance=myInfo.allianceName}
    			smallDialog:showReportPlayerInfoSmallDialog(player,self.layerNum+1,true,nil,false)
    		end
    	end
    	local picName=playerVoApi:getPersonPhotoName(pic)
    	local myIconSp=playerVoApi:GetPlayerBgIcon(picName,showMyInfo,nil,nil,iconWidth,fhid)
    	myIconSp:setPosition(2+iconWidth/2,infoHeight/2)
    	myIconSp:setTouchPriority(-(self.layerNum-1)*20-4)
    	myInfoBg:addChild(myIconSp)
    	if myInfo.level then
	       	local lvBg=LuaCCScale9Sprite:createWithSpriteFrameName("newBlackFadeBar.png",CCRect(0,0,1,9),function ()end)
	        lvBg:setRotation(180)
	        lvBg:setContentSize(CCSizeMake(50,20))
	        lvBg:setPosition(myIconSp:getPositionX()+iconWidth/2-lvBg:getContentSize().width/2-6,myIconSp:getPositionY()-iconWidth/2+lvBg:getContentSize().height/2+2)
	        myInfoBg:addChild(lvBg)
	    	local lvLb=GetTTFLabel(getlocal("fightLevel",{myInfo.level}),fontSize-4)
	        lvLb:setAnchorPoint(ccp(1,0.5))
	        lvLb:setPosition(lvBg:getPositionX()+lvBg:getContentSize().width/2-5,lvBg:getPositionY())
	    	myInfoBg:addChild(lvLb,2)
	    end
    	local nameLb=GetTTFLabelWrap(myNameStr,fontSize,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		nameLb:setAnchorPoint(ccp(0,1))
		nameLb:setPosition(myIconSp:getPositionX()+5+iconWidth/2,myIconSp:getPositionY()+iconWidth/2)
		myInfoBg:addChild(nameLb)

		if self.rtype==1 then
			local rankLb,rankLbHeight=G_getRichTextLabel(rankStr,{nil,color},fontSize-4,180,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			rankLb:setAnchorPoint(ccp(0,1))
			rankLb:setPosition(nameLb:getPositionX(),infoHeight/2+rankLbHeight/2)
			myInfoBg:addChild(rankLb)
		else
			local allianceName="["..getlocal("noAlliance").."]"
			if myInfo.allianceName and myInfo.allianceName~="" then
				allianceName=myInfo.allianceName
			end
			local allianceLb=GetTTFLabelWrap(allianceName,fontSize-4,CCSizeMake(180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			allianceLb:setAnchorPoint(ccp(0,0.5))
			allianceLb:setPosition(nameLb:getPositionX(),infoHeight/2)
			myInfoBg:addChild(allianceLb)
		end

		if fight>0 then
			local fightSp=CCSprite:createWithSpriteFrameName("picked_icon2.png")
			fightSp:setAnchorPoint(ccp(0,0.5))
			fightSp:setScale(0.5)
	    	local fightLb=GetTTFLabel(FormatNumber(fight),fontSize-4) --战斗力
	        fightLb:setAnchorPoint(ccp(0,0.5))
	        fightLb:setPosition(nameLb:getPositionX()+fightSp:getContentSize().width*0.5+10,10+fightLb:getContentSize().height/2)
	    	myInfoBg:addChild(fightLb)
			fightSp:setPosition(nameLb:getPositionX(),fightLb:getPositionY())
			myInfoBg:addChild(fightSp)
		end

		local campBg=LuaCCScale9Sprite:createWithSpriteFrameName("reportSideBg.png",CCRect(30,0,2,24),function ()end)
        campBg:setContentSize(CCSizeMake(100,24))
        campBg:setPosition(infoWidth-campBg:getContentSize().width/2,campBg:getContentSize().height/2)
        campBg:setOpacity(255*0.1)
        myInfoBg:addChild(campBg)
        local campStr,campStrColor=""
        if self.report.type==1 then --攻击方
        	campStr=getlocal("battleCamp1")
        	campStrColor=G_LowfiColorGreen
        else --防守方
        	campStr=getlocal("battleCamp2")
        	campStrColor=G_LowfiColorRed
        end
    	local campLb=GetTTFLabel(campStr,fontSize)
        campLb:setPosition(campBg:getContentSize().width/2+10,campBg:getContentSize().height/2)
        campLb:setColor(campStrColor)
    	campBg:addChild(campLb)
    end

    --敌方信息
    local enemyInfoBg=LuaCCScale9Sprite:createWithSpriteFrameName("reportRedBg.png",CCRect(4, 4, 1, 1),function ()end)
    enemyInfoBg:setAnchorPoint(ccp(0.5,1))
    enemyInfoBg:setContentSize(CCSizeMake(infoWidth,infoHeight))
    enemyInfoBg:setPosition(G_VisibleSizeWidth-infoWidth/2-5,infoBg:getPositionY()-infoBgSize.height)
    self.bgLayer:addChild(enemyInfoBg)
    if enemyInfo then
    	local rpx,rpy=infoWidth-iconWidth/2-2,infoHeight/2
		local rightPosX=rpx-iconWidth/2-5
    	local fight,pic,fhid=(tonumber(enemyInfo.fight) or 0),(enemyInfo.pic or headCfg.default),(enemyInfo.fhid or headFrameCfg.default)
    	local function showMyInfo()
    		if self.isNPC==false and enemyInfo.fight then
    			local player={uid=enemyInfo.id,name=enemyNameStr,level=enemyInfo.level,pic=pic,fhid=fhid,vip=enemyInfo.vip,rank=enemyInfo.rank,fight=enemyInfo.fight,alliance=enemyInfo.allianceName}
    			smallDialog:showReportPlayerInfoSmallDialog(player,self.layerNum+1,true,nil,false)
    		end
    	end
		local picName=playerVoApi:getPersonPhotoName(pic)
    	local enemyIconSp=playerVoApi:GetPlayerBgIcon(picName,showMyInfo,nil,nil,iconWidth,fhid)
    	enemyIconSp:setTouchPriority(-(self.layerNum-1)*20-4)
    	local rpx,rpy=infoWidth-iconWidth/2-2,infoHeight/2	
		enemyIconSp:setPosition(rpx,rpy)
	    enemyInfoBg:addChild(enemyIconSp)
	    if enemyInfo.level then
		    local lvBg=LuaCCScale9Sprite:createWithSpriteFrameName("newBlackFadeBar.png",CCRect(0,0,1,9),function ()end)
	    	lvBg:setRotation(180)
		    lvBg:setContentSize(CCSizeMake(50,20))
		    lvBg:setPosition(enemyIconSp:getPositionX()+iconWidth/2-lvBg:getContentSize().width/2-6,enemyIconSp:getPositionY()-iconWidth/2+lvBg:getContentSize().height/2+2)
		    lvBg:setOpacity(150)
		    enemyInfoBg:addChild(lvBg)
			local lvLb=GetTTFLabel(getlocal("fightLevel",{enemyInfo.level}),fontSize-4)
		    lvLb:setAnchorPoint(ccp(1,0.5))
		    lvLb:setPosition(lvBg:getPositionX()+lvBg:getContentSize().width/2-5,lvBg:getPositionY())
			enemyInfoBg:addChild(lvLb)
		end
		local nameLb=GetTTFLabelWrap(enemyNameStr,fontSize,CCSizeMake(200,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentTop)
		nameLb:setAnchorPoint(ccp(1,1))
		nameLb:setPosition(rightPosX,enemyIconSp:getPositionY()+iconWidth/2)
		enemyInfoBg:addChild(nameLb)

		if self.rtype==1 then
	    	local rankLb,rankLbHeight=G_getRichTextLabel(enemyRankStr,{nil,enemyRankColor},fontSize-4,180,kCCTextAlignmentRight,kCCVerticalTextAlignmentTop)
			rankLb:setAnchorPoint(ccp(1,1))
			rankLb:setPosition(rightPosX,infoHeight/2+rankLbHeight/2)
			enemyInfoBg:addChild(rankLb)
		else
			local allianceName="["..getlocal("noAlliance").."]"
			if enemyInfo.allianceName and enemyInfo.allianceName~="" then
				allianceName=enemyInfo.allianceName
			end
			local allianceLb=GetTTFLabelWrap(allianceName,fontSize-4,CCSizeMake(150,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentTop)
			allianceLb:setAnchorPoint(ccp(1,0.5))
			allianceLb:setPosition(rightPosX,infoHeight/2)
			enemyInfoBg:addChild(allianceLb)
		end

    	if fight>0 then
			local fightLb=GetTTFLabel(FormatNumber(fight),fontSize-4)
	        fightLb:setAnchorPoint(ccp(1,0.5))
	        fightLb:setPosition(rightPosX,10+fightLb:getContentSize().height/2)
	    	enemyInfoBg:addChild(fightLb)
			local fightSp=CCSprite:createWithSpriteFrameName("picked_icon2.png")
			fightSp:setAnchorPoint(ccp(1,0.5))
			fightSp:setScale(0.5)
			fightSp:setPosition(fightLb:getPositionX()-fightLb:getContentSize().width,fightLb:getPositionY())
			enemyInfoBg:addChild(fightSp)
		end

		local enemyCampBg=LuaCCScale9Sprite:createWithSpriteFrameName("reportSideBg2.png",CCRect(0,0,2,24),function ()end)
	    enemyCampBg:setContentSize(CCSizeMake(100,24))
	    enemyCampBg:setPosition(enemyCampBg:getContentSize().width/2,enemyCampBg:getContentSize().height/2)
	    enemyCampBg:setOpacity(255*0.1)
	    enemyInfoBg:addChild(enemyCampBg)
	    local campStr,campStrColor=""
	    if self.report.type==1 then --攻击方
	    	campStr=getlocal("battleCamp2")
	    	campStrColor=G_LowfiColorRed
	    else --防守方
	    	campStr=getlocal("battleCamp1")
	    	campStrColor=G_LowfiColorGreen
	    end
		local enemyCampLb=GetTTFLabel(campStr,fontSize)
	    enemyCampLb:setPosition(enemyCampBg:getContentSize().width/2-10,enemyCampBg:getContentSize().height/2)
	    enemyCampLb:setColor(campStrColor)
		enemyInfoBg:addChild(enemyCampLb)
    end

    self:initShowType() --初始化战报显示元素类型
	self.baseNum=SizeOfTable(self.baseShowType)
	self.detailNum=0
	if self.detailShowType then
		self.detailNum=SizeOfTable(self.detailShowType)
	end

    self.tvTb={}
	self.tvWidth,self.tvHeight=630,G_VisibleSizeHeight-450
	if self.detailNum==0 then
		self.tvHeight=self.tvHeight+30
	end

	for i=1,2 do
		local function callBack(...)
			if i==1 then
				return self:reportEventHandler1(...)
			else
				return self:reportEventHandler2(...)
			end
	    end
	    local hd=LuaEventHandler:createHandler(callBack)
		local tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tvHeight),nil)
		tv:setAnchorPoint(ccp(0,0))
	    tv:setPosition((G_VisibleSizeWidth-self.tvWidth)/2,myInfoBg:getPositionY()-myInfoBg:getContentSize().height-self.tvHeight)
		tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
		if i==1 then
			self.baseLayer:addChild(tv)
		else
			self.detailLayer:addChild(tv)
		end
		self.tvTb[i]=tv
	end

	--显示实力对比
	if self.detailShowType and self.detailNum>0 then
		self.showIdx=1
		local tv=tolua.cast(self.tvTb[1],"LuaCCTableView")
		local function showDetail()
			if self.detailBtn then
				local function realShow()
					local detailLb=tolua.cast(self.detailBtn:getChildByTag(101),"CCLabelTTF")
					local moveDis=0
					if self.showIdx==1 then
						self.showIdx=2
						detailLb:setString(getlocal("checkReportBaseInfoStr"))
						moveDis=-G_VisibleSizeWidth
					else
						self.showIdx=1
						detailLb:setString(getlocal("checkReportDetailStr"))
						moveDis=G_VisibleSizeWidth
					end
					local infoTv=tolua.cast(self.tvTb[self.showIdx],"LuaCCTableView")
					if infoTv then
						infoTv:reloadData()
					end
					self.moving=true
					for i=1,2 do
						local moveBy=CCMoveBy:create(0.5,ccp(moveDis,0))
						local function moveEnd()
							self.moving=false
						end
						if i==1 then
							self.baseLayer:runAction(CCSequence:createWithTwoActions(moveBy,CCCallFunc:create(moveEnd)))
						else
							self.detailLayer:runAction(moveBy)
						end
					end
				end
				
        		G_touchedItem(self.detailBtn,realShow,0.9)
			end
		end
		local detailBtn=LuaCCSprite:createWithSpriteFrameName("reportDetailBtn.png",showDetail)
		detailBtn:setPosition(G_VisibleSizeWidth/2,tv:getPositionY()-detailBtn:getContentSize().height/2)
		detailBtn:setTouchPriority(-(self.layerNum-1)*20-4)
		self.bgLayer:addChild(detailBtn,5)
		self.detailBtn=detailBtn
		for i=1,2 do
			local arrowSp=CCSprite:createWithSpriteFrameName("reportArrow.png")
			if i==1 then
				arrowSp:setPosition(150,detailBtn:getContentSize().height/2)
			else
				arrowSp:setPosition(detailBtn:getContentSize().width-150,detailBtn:getContentSize().height/2)
				arrowSp:setRotation(180)
			end
			detailBtn:addChild(arrowSp)
		end
		local detailLb=GetTTFLabelWrap(getlocal("checkReportDetailStr"),22,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		detailLb:setPosition(getCenterPoint(detailBtn))
		detailLb:setTag(101)
		detailBtn:addChild(detailLb)
	else
		local tv=tolua.cast(self.tvTb[1],"LuaCCTableView")
		if tv then
			local mLine=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine1.png",CCRect(34,1,1,1),function ()end)
			mLine:setPosition(ccp(G_VisibleSizeWidth/2,tv:getPositionY()-mLine:getContentSize().height/2))
			mLine:setContentSize(CCSizeMake(G_VisibleSizeWidth-10,mLine:getContentSize().height))
			self.bgLayer:addChild(mLine)
		end
	end

	self:initBottomBtutton()
end

function reportDetailNewDialog:initBottomBtutton()
	local report=self.report

	local function operateHandler(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        end
        PlayEffect(audioCfg.mouseClick)
        
        if tag==11 then
        	--如果没有战斗
			if report.report==nil or SizeOfTable(report.report)==0 then
				smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("fight_content_result_no_play"),true,self.layerNum+1)
			else
				local isAttacker=false
				if report.type==1 then
					isAttacker=true
				end
				local data={data=report,isAttacker=isAttacker,isReport=true}
				data.battleType=self.battleType
				battleScene:initData(data)
			end
        elseif tag==14 then
        	local function deleteCallback(fn,data)
				if base:checkServerData(data)==true then
					if self.rtype==1 then
						arenaReportVoApi:deleteReport(report.rid)
						arenaReportVoApi:setFlag(0)
					elseif self.rtype==2 then
						swReportVoApi:deleteReport(report.rid)
						superWeaponVoApi:setFlag(0)
					elseif self.rtype==3 then
						expeditionVoApi:deleteReport(report.rid)
						expeditionVoApi:setFlag(0)
					end
					self.sendSuccess=true
					base:tick()
					self:close(false)
				end
			end
			if self.sendSuccess==false then
				if self.rtype==1 then
					socketHelper:militaryDelete(report.rid,deleteCallback)
				elseif self.rtype==2 then
					socketHelper:weaponDelete(report.rid,deleteCallback)
				elseif self.rtype==3 then
					socketHelper:expeditionDelete(report.rid,deleteCallback)
				end
			end
		elseif tag==16 then
			--检测是否被禁言
			if chatVoApi:canChat(self.layerNum)==false then
				do return end
			end
			
            local playerLv=playerVoApi:getPlayerLevel()
            local timeInterval=playerCfg.chatLimitCfg[playerLv] or 0
			local diffTime=0
			if base.lastSendTime then
				diffTime=base.serverTime-base.lastSendTime
			end
			if diffTime>=timeInterval then
				self.canSand=true
			end
			if self.canSand==nil or self.canSand==false then
				smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("time_limit_prompt",{timeInterval-diffTime}),true,self.layerNum+1)
				do return end
			end
			self.canSand=false
			
			local sender=playerVoApi:getUid()
			local chatContent
			if self.rtype==1 then
				if report.type==1 then
					if report.isVictory==1 then
		            	chatContent=getlocal("arena_report_chat_msg",{report.enemyName})
		            else
		            	chatContent=getlocal("arena_report_chat_msg1",{report.enemyName})
		            end
		        else
		        	if report.isVictory==1 then
		            	chatContent=getlocal("arena_report_chat_msg2",{report.enemyName})
		            else
		            	chatContent=getlocal("arena_report_chat_msg3",{report.enemyName})
		            end
		        end
			elseif self.rtype==2 then
	        	chatContent=getlocal("super_weapon_title_1")..getlocal("snatch_report")
	        	local str=""
    			local isAttacker
				if report.type==1 then
					isAttacker=true
				else
					isAttacker=false
				end
	        	if report.robSuccess==1 then
	        		if isAttacker==true then
	            		str=getlocal("snatch_enemy_result",{report.enemyName..getlocal("success_str")})
	        		else
	            		str=getlocal("besnatch_enemy_result",{report.enemyName,getlocal("success_str")})
	        		end
	            else
	            	if isAttacker==true then
	            		str=getlocal("snatch_enemy_result",{report.enemyName..getlocal("fight_content_result_defeat")})
	            	else
	            		str=getlocal("besnatch_enemy_result",{report.enemyName,getlocal("fight_content_result_defeat")})
	            	end
	            end
	            chatContent=chatContent.."（"..str.."）"
	        elseif self.rtype==3 then
	        	if report.isVictory==1 then
	            	chatContent=getlocal("expeditionReportWin",{report.place,report.enemyName})
	            else
	            	chatContent=getlocal("expeditionReportLose",{report.place,report.enemyName})
	            end
			end

			if chatContent==nil then
				chatContent=""
			end
			--如果有联盟，选择联盟还是世界；没有则世界发送到世界 1为世界
			if report.report~=nil and SizeOfTable(report.report)>0 then
				local hasAlliance=allianceVoApi:isHasAlliance()
				local reportData=report.report or {}
				local isAttacker
				if report.type==1 then
					isAttacker=true
				else
					isAttacker=false
				end
				if hasAlliance==false then
					base.lastSendTime=base.serverTime
					local senderName=playerVoApi:getPlayerName()
					local level=playerVoApi:getPlayerLevel()
					local rank=playerVoApi:getRank()
					local language=G_getCurChoseLanguage()
					local params={}
					if self.rtype==2 then
                    	params={brType=9,subType=1,contentType=2,message=chatContent,level=level,rank=rank,power=playerVoApi:getPlayerPower(),uid=playerVoApi:getUid(),name=playerVoApi:getPlayerName(),pic=playerVoApi:getPic(),report=reportData,ts=base.serverTime,vip=playerVoApi:getVipLevel(),language=language,isAllianceWar=false,isAttacker=isAttacker,wr=playerVoApi:getServerWarRank(),st=playerVoApi:getServerWarRankStartTime(),title=playerVoApi:getTitle()}
                    elseif self.rtype==1 then
                    	params={subType=1,contentType=2,message=chatContent,level=level,rank=rank,power=playerVoApi:getPlayerPower(),uid=playerVoApi:getUid(),name=playerVoApi:getPlayerName(),pic=playerVoApi:getPic(),report=reportData,ts=base.serverTime,vip=playerVoApi:getVipLevel(),language=language,isAllianceWar=true,isAttacker=isAttacker,wr=playerVoApi:getServerWarRank(),st=playerVoApi:getServerWarRankStartTime(),title=playerVoApi:getTitle()}
                    elseif self.rtype==3 then
                    	params={subType=1,contentType=2,message=chatContent,level=level,rank=rank,power=playerVoApi:getPlayerPower(),uid=playerVoApi:getUid(),name=playerVoApi:getPlayerName(),pic=playerVoApi:getPic(),report=reportData,ts=base.serverTime,vip=playerVoApi:getVipLevel(),language=language,isExpedition=true,isAttacker=isAttacker,wr=playerVoApi:getServerWarRank(),st=playerVoApi:getServerWarRankStartTime(),title=playerVoApi:getTitle()}
					end
					--chatVoApi:addChat(1,sender,senderName,0,"",params)
                    chatVoApi:sendChatMessage(1,sender,senderName,0,"",params)
					--mainUI:setLastChat()
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("read_email_report_share_sucess"),28)
				else
                    local function sendReportHandle(tag,object)
                        base.lastSendTime=base.serverTime
                        local channelType=tag or 1
                        
                        local senderName=playerVoApi:getPlayerName()
                        local level=playerVoApi:getPlayerLevel()
                        local rank=playerVoApi:getRank()
                        local allianceName
				        local allianceRole
				        if allianceVoApi:isHasAlliance() then
				            local allianceVo=allianceVoApi:getSelfAlliance()
				            allianceName=allianceVo.name
				            allianceRole=allianceVo.role
				        end
				        local language=G_getCurChoseLanguage()
				        if self.rtype==2 then
                        	params={brType=9,subType=channelType,contentType=2,message=chatContent,level=level,rank=rank,power=playerVoApi:getPlayerPower(),uid=playerVoApi:getUid(),name=playerVoApi:getPlayerName(),pic=playerVoApi:getPic(),report=reportData,ts=base.serverTime,allianceName=allianceName,allianceRole=allianceRole,vip=playerVoApi:getVipLevel(),language=language,isAllianceWar=true,isAttacker=isAttacker,wr=playerVoApi:getServerWarRank(),st=playerVoApi:getServerWarRankStartTime(),title=playerVoApi:getTitle()}
				        elseif self.rtype==1 then
                        	params={subType=channelType,contentType=2,message=chatContent,level=level,rank=rank,power=playerVoApi:getPlayerPower(),uid=playerVoApi:getUid(),name=playerVoApi:getPlayerName(),pic=playerVoApi:getPic(),report=reportData,ts=base.serverTime,allianceName=allianceName,allianceRole=allianceRole,vip=playerVoApi:getVipLevel(),language=language,isAllianceWar=true,isAttacker=isAttacker,wr=playerVoApi:getServerWarRank(),st=playerVoApi:getServerWarRankStartTime(),title=playerVoApi:getTitle()}
                        	elseif self.rtype==3 then
                        	params={subType=channelType,contentType=2,message=chatContent,level=level,rank=rank,power=playerVoApi:getPlayerPower(),uid=playerVoApi:getUid(),name=playerVoApi:getPlayerName(),pic=playerVoApi:getPic(),report=reportData,ts=base.serverTime,allianceName=allianceName,allianceRole=allianceRole,vip=playerVoApi:getVipLevel(),language=language,isExpedition=true,isAttacker=isAttacker,wr=playerVoApi:getServerWarRank(),st=playerVoApi:getServerWarRankStartTime(),title=playerVoApi:getTitle()}
				        end
                        local aid=playerVoApi:getPlayerAid()
                        if channelType==1 then
                        	chatVoApi:sendChatMessage(1,sender,senderName,0,"",params)
                        	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("read_email_report_share_sucess"),28)
                        elseif aid then
                            chatVoApi:sendChatMessage(aid+1,sender,senderName,0,"",params)
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("read_email_report_share_sucess"),28)
                        end
                    end
                    allianceSmallDialog:selectChannelDialog("PanelHeaderPopup.png",CCSizeMake(450,350),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,self.layerNum+1,sendReportHandle)
				end
			end
        end
    end

	local scale=0.75
	self.replayBtn=GetButtonItem("letterBtnPlay_v2.png","letterBtnPlay_Down_v2.png","letterBtnPlay_Down_v2.png",operateHandler,11,nil,nil)
	self.replayBtn:setScaleX(scale)
	self.replayBtn:setScaleY(scale)
	local replaySpriteMenu=CCMenu:createWithItem(self.replayBtn)
	replaySpriteMenu:setAnchorPoint(ccp(0.5,0))
	replaySpriteMenu:setTouchPriority(-(self.layerNum-1)*20-4)

	self.deleteBtn=GetButtonItem("yh_letterBtnDelete.png","yh_letterBtnDelete_Down.png","yh_letterBtnDelete_Down.png",operateHandler,14,nil,nil)
	self.deleteBtn:setScaleX(scale)
	self.deleteBtn:setScaleY(scale)
	local deleteSpriteMenu=CCMenu:createWithItem(self.deleteBtn)
	deleteSpriteMenu:setAnchorPoint(ccp(0.5,0))
	deleteSpriteMenu:setTouchPriority(-(self.layerNum-1)*20-4)

	self.sendBtn=GetButtonItem("letterBtnSend_v2.png","letterBtnSend_Down_v2.png","letterBtnSend_Down_v2.png",operateHandler,16,nil,nil)
	self.sendBtn:setScaleX(scale)
	self.sendBtn:setScaleY(scale)
	local sendSpriteMenu=CCMenu:createWithItem(self.sendBtn)
	sendSpriteMenu:setAnchorPoint(ccp(0.5,0))
	sendSpriteMenu:setTouchPriority(-(self.layerNum-1)*20-4)

	local height=45
	local posXScale=self.bgLayer:getContentSize().width

	self.bgLayer:addChild(replaySpriteMenu,2)
	self.bgLayer:addChild(deleteSpriteMenu,2)
	self.bgLayer:addChild(sendSpriteMenu,2)
	replaySpriteMenu:setPosition(ccp(posXScale/4*1,height))
	deleteSpriteMenu:setPosition(ccp(posXScale/4*2,height))
	sendSpriteMenu:setPosition(ccp(posXScale/4*3,height))

	if report and report.report==nil or SizeOfTable(report.report)==0 then
		self.replayBtn:setEnabled(false)
		self.sendBtn:setEnabled(false)
	end
	if self.chatReport==true then
		self.deleteBtn:setEnabled(false)
		self.sendBtn:setEnabled(false)
	end
end

function reportDetailNewDialog:reportEventHandler1(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return self.baseNum
	elseif fn=="tableCellSizeForIndex" then
		return CCSizeMake(self.tvWidth,self:getReportCellHeight1(idx+1))
	elseif fn=="tableCellAtIndex" then
		if self.report==nil or SizeOfTable(self.report)==0 then
			do return end
		end
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local cellWidth,cellHeight=self.tvWidth,self:getReportCellHeight1(idx+1)
        local showType=self.baseShowType[idx+1]

        local enemyName=self.report.enemyName
        local isAttacker=false
        local attacker=enemyName
        local defender=self.report.name
		if self.report.type==1 then
			isAttacker=true
			attacker=self.report.name
			defender=enemyName
		end

		if showType==1 then --战利品
			if self.rtype==2 then
				local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("reportRewardTitleBg.png",CCRect(4,19,1,2),function()end)
			    titleBg:setContentSize(CCSizeMake(cellWidth, 40))
			    titleBg:ignoreAnchorPointForPosition(false)
			    titleBg:setAnchorPoint(ccp(0.5,1))
			    titleBg:setPosition(ccp(cellWidth/2,cellHeight))
			    cell:addChild(titleBg)

			    local titleLabel=GetTTFLabel(getlocal("fight_award"),22,true)
				titleLabel:setPosition(getCenterPoint(titleBg))
				titleBg:addChild(titleLabel)

				local contentBg=LuaCCScale9Sprite:createWithSpriteFrameName("reportRewardTitleBg2.png",CCRect(4,4,1,1),function()end)
				contentBg:setContentSize(CCSizeMake(titleBg:getContentSize().width,cellHeight-titleBg:getContentSize().height))
				contentBg:setAnchorPoint(ccp(0.5,1))
				contentBg:setPosition(cellWidth/2,titleBg:getPositionY()-titleBg:getContentSize().height)
				cell:addChild(contentBg)

				local posY=titleBg:getPositionY()-titleBg:getContentSize().height-10

				local robSuccess=false
				local zyLb=GetTTFLabel(getlocal("sw_report_fight_item_fail"),20)
				zyLb:setColor(G_ColorRed)
				if self.report.fid and self.report.robSuccess and self.report.robSuccess==1 then
					local tmpTitle = getlocal("sw_report_fight_item_success")
					if self.report.elementNum > 0 then
						tmpTitle = getlocal("super_weapon_rob_max_tips3")
					end
					robSuccess=true
					zyLb=GetTTFLabel(tmpTitle,20)
					zyLb:setColor(G_ColorGreen)
				end
				zyLb:setAnchorPoint(ccp(0,1))
			    zyLb:setPosition(10,posY)
			    cell:addChild(zyLb)
			    posY=zyLb:getPositionY()-zyLb:getContentSize().height-10
			    if robSuccess==true then
			    	local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("reportWhiteLine.png",CCRect(4,0,1,2),function()end)
				    lineSp:setContentSize(CCSizeMake(cellWidth-20, 2))
				    lineSp:setPosition(cellWidth/2,posY)
				    lineSp:setOpacity(255*0.06)
				    cell:addChild(lineSp)
				    local rowNum=5
					local iconSize=95
					local spaceX,spaceY=25,25
					local firstPosX=(cellWidth-(iconSize*rowNum+spaceX*(rowNum-1)))/2
	        		local firstPosY=posY-10
	        		local k=1
	        		local nameStr,descStr=superWeaponVoApi:getFragmentNameAndDesc(self.report.fid)
					local icon, iconNum
					if self.report.elementNum > 0 then
						nameStr = getlocal("weapon_smelt_p1")
						iconNum = self.report.elementNum
						icon = LuaCCSprite:createWithSpriteFrameName("superWeaponP1.png", function () end)
					else
						iconNum = 1
						icon=superWeaponVoApi:getFragmentIcon(self.report.fid)
					end
					icon:setAnchorPoint(ccp(0,1))
					local scale=iconSize/icon:getContentSize().width
					icon:setScale(scale)
					icon:setPosition(firstPosX+((k-1)%rowNum)*(iconSize+spaceX),firstPosY-math.floor(((k-1)/rowNum))*(iconSize+spaceY))
	            	icon:setTouchPriority(-(self.layerNum-1)*20-2)
	            	cell:addChild(icon)
	            	
	                local numLb=GetTTFLabel(getlocal("propInfoNum",{iconNum}),20)                  
	                numLb:setAnchorPoint(ccp(0,1))
	                numLb:setPosition(ccp(icon:getPositionX()+icon:getContentSize().width*scale+10,icon:getPositionY()-10))
	                cell:addChild(numLb)

	                local nameLb=GetTTFLabel(nameStr,20)
	                nameLb:setAnchorPoint(ccp(0,0))
	                nameLb:setPosition(icon:getPositionX()+icon:getContentSize().width*scale+10,icon:getPositionY()-icon:getContentSize().height*scale+10)
	                cell:addChild(nameLb)
			    end
			end
        elseif showType==3 then --部队损耗信息

			if self.report.troops then --新的战报部队数据格式
				local troops
				if isAttacker==true then
					troops=self.report.troops
				else
					troops={self.report.troops[2],self.report.troops[1]}
				end
				G_getBattleReportTroopsLayout(cell,cellWidth,cellHeight,troops,self.layerNum,self.report,isAttacker,idx~=1)
			else

				local fontSize=20

				local attLost={}
				local defLost={}
				local attTotal = {}--当前战斗坦克的总数
				local defTotal = {}

				if self.report.lostShip.attackerLost then
					if self.report.lostShip.attackerLost.o then
						attLost=FormatItem(self.report.lostShip.attackerLost,false)
					else
						attLost=self.report.lostShip.attackerLost
					end
				end
				if self.report.lostShip.defenderLost then
					if self.report.lostShip.defenderLost.o then
						defLost=FormatItem(self.report.lostShip.defenderLost,false)
					else
						defLost=self.report.lostShip.defenderLost
					end
				end
				if self.report.lostShip.attackerTotal then
					if self.report.lostShip.attackerTotal.o then
						attTotal=FormatItem(self.report.lostShip.attackerTotal,false)
					else
						attTotal=self.report.lostShip.attackerTotal
					end
				end
				if self.report.lostShip.defenderTotal then
					if self.report.lostShip.defenderTotal.o then
						defTotal=FormatItem(self.report.lostShip.defenderTotal,false)
					else
						defTotal=self.report.lostShip.defenderTotal
					end
				end

				local attackerStr=""
				local attackerLost=""
				local defenderStr=""
				local defenderLost=""
				local attackerTotal = ""
				local defenderTotal = ""
				local content={}

				local htSpace=0
				local perSpace=fontSize+10

				local attackerLostNum=SizeOfTable(attLost)
				local defenderLostNum=SizeOfTable(defLost)
				local attackerTotalNum = SizeOfTable(attTotal)
				local defenderTotalNum = SizeOfTable(defTotal)
				if attackerTotalNum>0 or defenderTotalNum>0 then
					perSpace=fontSize+30
					--损失的船
					local armysContent={getlocal("battleReport_armysName"),getlocal("battleReport_armysNums"),getlocal("battleReport_armysLosts"),getlocal("battleReport_armysleaves")}
					local showColor={G_ColorWhite,G_ColorOrange2,G_ColorRed,G_ColorGreen}--所有需要显示的文字颜色
					local defHeight,attOrDefTotal,attOrDefLost
					for g=1,2 do
						if g==2 then
							cellHeight=defHeight-20
						end
						if g==1 then
							personStr=getlocal("fight_content_attacker",{attacker})
							attOrDefTotal=G_clone(attTotal)
							attOrDefLost=G_clone(attLost)
						elseif g==2 then
							attOrDefTotal=G_clone(defTotal)
							attOrDefLost=G_clone(defLost)
							local defendName=defender
							personStr=defenderStr..getlocal("fight_content_defender",{defendName})
						end
						local attContent=GetTTFLabel(personStr,fontSize)
						attContent:setAnchorPoint(ccp(0,0.5))
						attContent:setPosition(ccp(10,cellHeight-50))
						cell:addChild(attContent,2)

						if g==1 then
							attContent:setColor(G_ColorGreen)
						elseif g==2 then
							attContent:setColor(G_ColorRed)
						end

						local function sortAsc(a, b)
							if sortByIndex then
								if a.id and b.id and tonumber(a.id) and tonumber(b.id) then
									return a.id < b.id
								end
							else
								if a.type==b.type then
									if a.id and b.id and tonumber(a.id) and tonumber(b.id) then
										return a.id < b.id
									end
						        end
							end
					    end
						table.sort(attOrDefTotal,sortAsc)
						local lablSize = fontSize-9
						local lablSizeO	= fontSize -8
						if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
							lablSize =fontSize
							lablSizeO =fontSize-3
						end
						local lbPosWIdth = 6
						for k,v in pairs(armysContent) do
							local armyLb=GetTTFLabelWrap(v,lablSize,CCSizeMake(cellWidth*0.1+70,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
							armyLb:setAnchorPoint(ccp(0.5,0.5))
							if k >1 then
								lbPosWIdth =7
							end
							armyLb:setPosition(ccp(cellWidth*k/lbPosWIdth+((k-1)*70),cellHeight-90))
						    cell:addChild(armyLb,2)
						    armyLb:setColor(showColor[k])
						end
						
						local localLeaves = {}
						for i=1,4 do
							local localStr
							local pos = 50
							if i ==1 then
								for k,v in pairs(attOrDefTotal) do
									if v and v.name then
										localStr=v.name
										local armyStr =GetTTFLabelWrap(localStr,lablSizeO,CCSizeMake(cellWidth*0.1+70,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
										armyStr:setAnchorPoint(ccp(0.5,0.5))
										armyStr:setPosition(ccp(cellWidth*i/6+((i-1)*70),cellHeight-90-((pos-1)*k)))
									    cell:addChild(armyStr,2)
									    armyStr:setColor(showColor[i])
						    		end
						    		if tankCfg[v.id].isElite==1 then
										local pickedSp = CCSprite:createWithSpriteFrameName("picked_icon1.png")
								        -- pickedSp:setScale()
								        pickedSp:setAnchorPoint(ccp(0.5,0.5))
								        pickedSp:setPosition(ccp(30,cellHeight-90-(49*k)))
								        cell:addChild(pickedSp,2)
								    end
						    		if k == SizeOfTable(attOrDefTotal) then
						    			defHeight =cellHeight-90-((pos-1)*k)
									end
								end
							end
							if i==2 then
								for k,v in pairs(attOrDefTotal) do
									table.insert(localLeaves,{num=v.num})
								end
								for k,v in pairs(attOrDefTotal) do
									if v and v.num then
										localStr=v.num
										local armyStr =GetTTFLabelWrap(localStr,fontSize,CCSizeMake(cellWidth-10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
										armyStr:setAnchorPoint(ccp(0.5,0.5))
										armyStr:setPosition(ccp(cellWidth*i/7+((i-1)*70),cellHeight-90-((pos-1)*k)))
									    cell:addChild(armyStr,2)
									    armyStr:setColor(showColor[i])
									    
						    		end 								
								end
							end
							if i==3 then
								local lostNum
								if SizeOfTable(attOrDefLost)==0 then
									lostNum=attOrDefTotal
								elseif SizeOfTable(attOrDefLost) >0 and SizeOfTable(attOrDefLost)~=SizeOfTable(attOrDefTotal) then
									local ishere =0
									for k,v in pairs(attOrDefTotal) do
										for m,n in pairs(attOrDefLost) do
											if m then
												if v.id ==n.id then
													ishere=0
													break
												else
													ishere=1
												end
											end
										end
										if ishere==1 then
											table.insert(attOrDefLost,v)
											for h,j in pairs(attOrDefLost) do
												 if j.id==v.id then
												 	j.num=0
												 end
											end
											ishere =0
										end
									end										
									lostNum =attOrDefLost
								else
									lostNum =attOrDefLost
								end
								local function sortAsc(a, b)
									if sortByIndex then
										if a.id and b.id and tonumber(a.id) and tonumber(b.id) then
											return a.id < b.id
										end
									else
										if a.type==b.type then
											if a.id and b.id and tonumber(a.id) and tonumber(b.id) then
												return a.id < b.id
											end
								        end
									end
							    end
								table.sort(lostNum,sortAsc)									
								for k,v in pairs(lostNum) do
									if v and v.num and SizeOfTable(attOrDefLost) >=1 then
										localStr=v.num
									else
						    			localStr=0
						    		end
										local armyStr =GetTTFLabelWrap(localStr,fontSize,CCSizeMake(cellWidth-10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
										armyStr:setAnchorPoint(ccp(0.5,0.5))
										armyStr:setPosition(ccp(cellWidth*i/7+((i-1)*70),cellHeight-90-((pos-1)*k)))
									    cell:addChild(armyStr,2)
									    armyStr:setColor(showColor[i])
									    if localLeaves and localLeaves[k] and localLeaves[k].num then
										    localLeaves[k].num=localLeaves[k].num-localStr
										end
								end
							end
							if i==4 then
								for k,v in pairs(localLeaves) do
									if v and v.num then
										localStr=v.num
										local armyStr =GetTTFLabelWrap(localStr,fontSize,CCSizeMake(cellWidth-10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
										armyStr:setAnchorPoint(ccp(0.5,0.5))
										armyStr:setPosition(ccp(cellWidth*i/7+((i-1)*70),cellHeight-90-((pos-1)*k)))
									    cell:addChild(armyStr,2)
									    armyStr:setColor(showColor[i])
						    		end 								
								end
								localLeaves =nil
							end						
						end						
					end
					if SizeOfTable(attOrDefTotal) >=1 then
						if self.rtype==2 then
							repairStr=getlocal("super_weapon_rob_info2")
							repairStr=string.gsub(repairStr,"6.","")
						else
							repairStr=getlocal("fight_content_tip_1")
						end
						local repairLb =GetTTFLabelWrap(repairStr,24,CCSizeMake(cellWidth-10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
						repairLb:setPosition(ccp(10,defHeight-70))
						repairLb:setAnchorPoint(ccp(0,0.5))
						cell:addChild(repairLb,2)
						repairLb:setColor(G_ColorOrange2)
					end
				else
					--损失的船
					attackerStr=getlocal("fight_content_attacker",{attacker}).."\n"
					table.insert(content,{attackerStr,htSpace})
					for k,v in pairs(attLost) do
						if v and v.name and v.num then
							attackerLost=attackerLost.."    "..(v.name).." -"..tostring(v.num).."\n"
						end
					end
					table.insert(content,{attackerLost,perSpace+htSpace,G_ColorRed})
					local defendName=defender
					if hasHelpDefender==true then
						defendName=helpDefender
					end
					defenderStr=defenderStr..getlocal("fight_content_defender",{defendName}).."\n"
					table.insert(content,{defenderStr,perSpace*attackerLostNum+perSpace+htSpace})
					for k,v in pairs(defLost) do
						if v and v.name and v.num then
							defenderLost=defenderLost.."    "..(v.name).." -"..tostring(v.num).."\n"
						end
					end
					table.insert(content,{defenderLost,perSpace*attackerLostNum+perSpace*2+htSpace,G_ColorRed})
					
					local cellHeight=perSpace*(4+attackerLostNum+defenderLostNum)+htSpace
					for k,v in pairs(content) do
						if v~=nil and v~="" then
							local contentMsg=content[k]
							local message=""
							local pos=0
							local color
							if type(contentMsg)=="table" then
								message=contentMsg[1]
								pos=contentMsg[2]
								color=contentMsg[3]
							else
								message=contentMsg
							end
							if message~=nil and message~="" then
						        local contentLb=GetTTFLabel(message,fontSize)
								if k==2 then
						    		contentLb=GetTTFLabelWrap(message,fontSize,CCSizeMake(cellWidth-10,60*attackerLostNum),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
								elseif k==4 then
									contentLb=GetTTFLabelWrap(message,fontSize,CCSizeMake(cellWidth-10,60*defenderLostNum),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
								elseif k==5 then
									contentLb=GetTTFLabelWrap(message,fontSize,CCSizeMake(cellWidth,60*1.5),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
								end
								contentLb:setAnchorPoint(ccp(0,1))
								contentLb:setPosition(ccp(10,cellHeight-pos))
							    cell:addChild(contentLb,2)
						        if color~=nil then
							        contentLb:setColor(color)
							    end
							end
						end
				    end
				end

			end
        end

        return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded" then
	end
end

function reportDetailNewDialog:reportEventHandler2(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return self.detailNum
	elseif fn=="tableCellSizeForIndex" then
		return CCSizeMake(self.tvWidth,self:getReportCellHeight2(idx+1))
	elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local cellWidth,cellHeight=self.tvWidth,self:getReportCellHeight2(idx+1)
        local showType=self.detailShowType[idx+1]
        local isAttacker=false
		if self.report.type==1 then
			isAttacker=true
		end
        if showType==4 then --装甲矩阵
        	G_getReportArmorMatrixLayout(cell,cellWidth,cellHeight,self.layerNum,self.report,isAttacker)
    	elseif showType==5 then --配件
        	G_getReportAccessoryLayout(cell,cellWidth,cellHeight,self.layerNum,self.report,isAttacker)
    	elseif showType==6 then --将领
			G_getReportHeroLayout(cell,cellWidth,cellHeight,self.layerNum,self.report,isAttacker)
    	elseif showType==7 then --超级武器
			G_getReportSuperWeaponLayout(cell,cellWidth,cellHeight,self.layerNum,self.report,isAttacker)
    	elseif showType==8 then --军徽
			G_getReportEmblemLayout(cell,cellWidth,cellHeight,self.layerNum,self.report,isAttacker)
    	elseif showType==9 then --飞机
			G_getReportPlaneLayout(cell,cellWidth,cellHeight,self.layerNum,self.report,isAttacker)
		elseif showType==11 then --AI部队
			G_getBattleReportAITroopsLayout(cell,cellWidth,cellHeight,(self.report.aitroops or {}),self.layerNum,self.report,isAttacker)
		elseif showType==12 then --飞艇
			G_getReportAirShipLayout(cell,cellWidth,cellHeight,self.report,isAttacker)
    	end

        return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded" then
	end
end

--战斗报告每个显示元素的高度
function reportDetailNewDialog:getReportCellHeight1(idx)
	if self.cellHeightTb1==nil then
		self.cellHeightTb1={}
	end
	if self.cellHeightTb1[idx]==nil then
		local height=0
		local showType=self.baseShowType[idx]
		if showType==1 then --战斗资源相关
			if self.rtype==2 then
				height=height+40
				height=height+10
				local robSuccess=false
				local zyLb=GetTTFLabel(getlocal("sw_report_fight_item_fail"),20)
				if self.report.fid and self.report.robSuccess and self.report.robSuccess==1 then
					robSuccess=true
					zyLb=GetTTFLabel(getlocal("sw_report_fight_item_success"),20)
				end
				height=height+zyLb:getContentSize().height+10
				if robSuccess==true then
					local resTbSize=1
					local rowNum=5
					local iconSize=95
					local spaceX,spaceY=25,25
	        		height=height+10
	        		height=height+math.ceil(resTbSize/rowNum)*iconSize+(math.ceil(resTbSize/rowNum)-1)*spaceY
	        		height=height+10
				end
			end
		elseif showType==2 then --繁荣度信息
			height=G_getReportGloryHeight()
		elseif showType==3 then --战斗部队损耗
			height=G_getBattleReportTroopsHeight(self.report)
		end
		self.cellHeightTb1[idx]=height
	end
	return self.cellHeightTb1[idx]
end

--战斗报告每个显示元素的高度
function reportDetailNewDialog:getReportCellHeight2(idx)
	if self.cellHeightTb2==nil then
		self.cellHeightTb2={}
	end
	if self.cellHeightTb2[idx]==nil then
		local height=0
		local showType=self.detailShowType[idx]
		if showType==4 then --装甲矩阵
			height=G_getReportArmorMatrixHeight()
    	elseif showType==5 then --配件
			height=G_getReportAccessoryHeight()
    	elseif showType==6 then --将领
    		height=G_getReportHeroLayoutHeight()
    	elseif showType==7 then --超级武器
			height=G_getReportSuperWeaponLayoutHeight()
    	elseif showType==8 then --军徽
			height=G_getReportEmblemLayoutHeight()
    	elseif showType==9 then --飞机
			height=G_getReportPlaneLayoutHeight()
		elseif showType==11 then --AI部队
			height=G_getBattleReportAITroopsHeight()
		elseif showType==12 then --飞艇
			height=G_getReportAirShipLayoutHeight()
		end
		self.cellHeightTb2[idx]=height
	end
	return self.cellHeightTb2[idx]
end

--根据战报的类型来初始化报告详情的显示类型
--showType：1.战利品(资源)，2.繁荣度，3.部队损耗，4.装甲矩阵，5.配件，6.将领，7.超级武器，8.军徽，9.飞机，11.AI部队
function reportDetailNewDialog:initShowType()
	self.baseShowType={}
	if self.rtype==1 then --军事演习不显示战利品
	elseif self.rtype==2 then
		self.baseShowType={1}
	elseif self.rtype==3 then --远征军不显示战利品
	end

	--军事演习繁荣度不变化所以不显示

	table.insert(self.baseShowType,3) --部队损耗

	if self.isNPC==true then --如果是NPS的话，不显示战斗实力对比
		do return end
	end

	local isShowHero 		--将领
	local isShowAccessory 	--配件
	local isShowEmblem 		--军徽
	local isShowPlane 		--飞机
	if self.rtype==1 then
		isShowHero=arenaReportVoApi:isShowHero()
		isShowAccessory=arenaReportVoApi:isShowAccessory()
		isShowEmblem=emailVoApi:isShowEmblem(self.report)
		isShowPlane=G_isShowPlaneInReport(self.report,2)
	elseif self.rtype==2 then
		isShowHero=swReportVoApi:isShowHero()
		isShowAccessory=swReportVoApi:isShowAccessory()
		isShowEmblem=swReportVoApi:isShowEmblem(self.report)
		isShowPlane=G_isShowPlaneInReport(self.report,5)
	elseif self.rtype==3 then
		isShowHero=expeditionVoApi:isShowHero()
		isShowAccessory=expeditionVoApi:isShowAccessory()
		isShowEmblem = expeditionVoApi:isShowEmblem(self.report)
		isShowPlane=G_isShowPlaneInReport(self.report,3)
	end

	self.detailShowType={}
	local armorMatrixFlag=emailVoApi:isShowArmorMatrix(self.report)
	if armorMatrixFlag==true then
		table.insert(self.detailShowType,4) --装甲矩阵
	end
	if isShowAccessory==true then
		table.insert(self.detailShowType,5) --配件
	end
	if isShowHero==true then
		table.insert(self.detailShowType,6) --将领
	end
	local superWeaponFlag=emailVoApi:isShowSuperWeapon(self.report)
	if superWeaponFlag==true then
		table.insert(self.detailShowType,7) --超级武器
	end
	local aiFlag=G_isShowAITroopsInReport(self.report) --AI部队
	if aiFlag==true then
		table.insert(self.detailShowType,11)
	end
	if isShowEmblem==true then
		table.insert(self.detailShowType,8) --军徽
	end
	if isShowPlane==true then
		table.insert(self.detailShowType,9) --飞机
	end
	if airShipVoApi:isCanEnter() == true then --飞艇
		table.insert(self.detailShowType,12)
	end
end

function reportDetailNewDialog:dispose()
	self.layerNum=nil
	self.report=nil
	self.chatReport=nil
	self.battleType=nil
    self.rtype=nil
    self.replayBtn=nil
    self.deleteBtn=nil
	self.sendBtn=nil
	self.sendSuccess=false
	self.canSand=true
	self.isNPC=nil
	self=nil
	spriteController:removePlist("public/reportyouhua.plist")
    spriteController:removeTexture("public/reportyouhua.png")
    spriteController:removePlist("public/youhuaUI3.plist")
    spriteController:removeTexture("public/youhuaUI3.png")
	-- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/world_ground.plist")
 --    CCTextureCache:sharedTextureCache():removeTextureForKey("public/world_ground.pvr.ccz")
end