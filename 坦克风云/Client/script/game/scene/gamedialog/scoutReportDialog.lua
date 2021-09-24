local scoutReportDialog={} --侦察报告

function scoutReportDialog:new(report)
	local nc={
		report=report,
		showType=nil,
		cellHeightTb=nil,
	}
	setmetatable(nc,self)
	self.__index=self

	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/world_ground.plist")
	spriteController:addPlist("public/emailNewUI.plist")
   	spriteController:addTexture("public/emailNewUI.png")
   	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
   	spriteController:addPlist("public/youhuaUI3.plist")
    spriteController:addTexture("public/youhuaUI3.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

	return nc
end

function scoutReportDialog:initReportLayer(layerNum)
	self.layerNum=layerNum
	self.bgLayer=CCLayer:create()

	if self.report.type==6 and self.report.searchtype~=1 then
		if self.report.searchtype==2 then
			local msgLabel=GetTTFLabelWrap(getlocal("search_fleet_desc6"),24,CCSizeMake(self.bgLayer:getContentSize().width-50, 30*10),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			msgLabel:setAnchorPoint(ccp(0,1))
			msgLabel:setPosition(ccp(25,self.bgLayer:getContentSize().height-110))
			self.bgLayer:addChild(msgLabel,2)
		elseif self.report.searchtype==3 then
			local label1=GetTTFLabelWrap(getlocal("search_fleet_desc4"),24,CCSizeMake(self.bgLayer:getContentSize().width-50, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			label1:setAnchorPoint(ccp(0,1))
			label1:setPosition(25,self.bgLayer:getContentSize().height-110)
			self.bgLayer:addChild(label1,2)
			local label2=GetTTFLabelWrap(getlocal("search_fleet_desc5"),24,CCSizeMake(self.bgLayer:getContentSize().width-50, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			label2:setAnchorPoint(ccp(0,1))
			label2:setPosition(25,label1:getPositionY()-label1:getContentSize().height-30)
			self.bgLayer:addChild(label2,2)
		end
	else
		CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
		CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
		local topBg=CCSprite:create("public/reportTopContentBg.jpg")
		CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
		CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
		topBg:setAnchorPoint(ccp(0.5,1))
		topBg:setPosition(self.bgLayer:getContentSize().width/2,G_VisibleSizeHeight-83)
		self.bgLayer:addChild(topBg)

		self:initTopContent(topBg)

		if self.report.type==5 then
		else
			self.tvWidth,self.tvHeight=616,topBg:getPositionY()-topBg:getContentSize().height-90-10
			local function callBack(...)
				return self:eventHandler(...)
		    end
		    local hd=LuaEventHandler:createHandler(callBack)
			self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tvHeight),nil)
			self.tv:setAnchorPoint(ccp(0,0))
		    self.tv:setPosition((G_VisibleSizeWidth-self.tvWidth)/2,90)
			self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
			self.bgLayer:addChild(self.tv)
		end
	end

	return self.bgLayer
end

function scoutReportDialog:initTopContent(_topBg)
	local _lbFontSize=20 --字体大小

	--侦察的岛屿图标
	local islandShowSize=150 --图标显示大小
	local islandSpPosX=35+islandShowSize/2
	local rebelData=self.report.rebel
	local rebelData=self.report.rebel or {}
	local rebelLv=rebelData.rebelLv or 0
	local rebelID=rebelData.rebelID or 0
	local expireTs=rebelData.expireTs or 0
	local _islandType=self.report.islandType
	if self.report.type==5 then
		_islandType=6 --玩家基地
	end
	local islandSp=G_getIslandIcon(_islandType,rebelLv,rebelID)
	if islandSp then
		islandSp:setPosition(islandSpPosX, _topBg:getContentSize().height/2+20)
		islandSp:setScale(islandShowSize/islandSp:getContentSize().width)
		_topBg:addChild(islandSp)

		--侦察时间
		local timeLb=GetTTFLabel(emailVoApi:getTimeStr(self.report.time),_lbFontSize)
		timeLb:setAnchorPoint(ccp(0.5,1))
		timeLb:setPosition(islandSpPosX,islandSp:getPositionY()-islandShowSize/2)
		timeLb:setColor(G_ColorYellowPro)
		_topBg:addChild(timeLb)

		--图标
		local typeIcon=CCSprite:createWithSpriteFrameName("emailNewUI_scout1.png")
		typeIcon:setAnchorPoint(ccp(1,0.5))
		typeIcon:setPosition(timeLb:getPositionX()-timeLb:getContentSize().width/2,timeLb:getPositionY()-timeLb:getContentSize().height/2)
		typeIcon:setScale(0.9)
		_topBg:addChild(typeIcon)
	end

	local pos
	if self.report.place then
		if self.report.place.x then
			pos=ccp(self.report.place.x,self.report.place.y)
		elseif self.report.place[1] then
			pos=ccp(self.report.place[1],self.report.place[2])
		end
	end

	local islandType,attacker,defender,attackerAllianceName,defenderAllianceName,helpDefender,helpDefenderAllianceName,hasHelpDefender,aLandform,dLandform,landform,richLevel,boom,boomMax,boomTs,boomBmd,landformPic=reportVoApi:formatReportData(self.report)
	--1.侦察地点 2.矿产状态 3.侦察坐标 4.侦察地形 5.驻军 6.繁荣度 7.叛军消失时间
	local _strTb={}
	if self.report.type==5 or self.report.type==6 then
		local content=reportVoApi:getReportContent(self.report)
		if content and content[1] then
			landformPic=nil
			for k, v in pairs(content) do
				_strTb["str"..k]=v
			end
		end
	else
		if islandType==7 then --叛军
			local leftTime=expireTs-self.report.time
			local target=G_getIslandName(islandType,nil,rebelLv,rebelID,nil,rebelData.rpic)
			
			--侦察地点
			_strTb["str1"]=getlocal("scout_content_site")..target

			--侦察坐标
			_strTb["str3"]=getlocal("scout_position")

			--侦察地形
			if landformPic then
				_strTb["str4"]=getlocal("scout_terrain")
			end

			--叛军消失时间
			_strTb["str7"]={
				getlocal("email_report_rebel_scout_flee",{GetTimeStr(leftTime)}),
				G_ColorYellowPro
			}
		else
			if islandType==6 then --玩家
				--侦察地点
				_strTb["str1"]=getlocal("scout_content_site")..defender

				--侦察坐标
				_strTb["str3"]=getlocal("scout_position")

				--侦察地形
				if landformPic then
					_strTb["str4"]=getlocal("scout_terrain")
				end

				--是否有驻军
				if hasHelpDefender==true then
					_strTb["str5"]=getlocal("fight_content_fight_type_8_1",{helpDefender})
				else
					_strTb["str5"]=getlocal("fight_content_fight_type_8_2")
				end
			elseif islandType<6 then --普通资源
				--侦察地点
				_strTb["str1"]=getlocal("scout_content_site")..G_getIslandName(islandType).."Lv."..self.report.level

				--侦察坐标
				_strTb["str3"]=getlocal("scout_position")

				--侦察地形
				if landformPic then
					_strTb["str4"]=getlocal("scout_terrain")
				end

				--是否有驻军
				if self.report.islandOwner>0 then
					_strTb["str5"]=getlocal("scout_content_defend_name",{defender})
				else
					_strTb["str5"]=getlocal("scout_content_defend_name",{getlocal("fight_content_null")})
				end

				--矿产状态
				if base.wl==1 and base.goldmine==1 and self.report.goldMineLv and self.report.goldMineLv>0 then	
					--侦察地点
					local mineName=worldBaseVoApi:getMineNameByType(islandType)
					local nameStr=getlocal("bountiful")..mineName
					_strTb["str1"]=getlocal("scout_content_site")..nameStr.."Lv."..self.report.level
					
					local leftTime=tonumber(self.report.disappearTime-base.serverTime)
					_strTb["str2"]={}
					if leftTime<=0 then
						_strTb["str2"][1]=getlocal("mine_state")..":"..getlocal("goldmine").."，"..getlocal("disappeared")
					else
						_strTb["str2"][1]=getlocal("mine_state")..":"..getlocal("goldmine").."，"..GetTimeStr(leftTime)..getlocal("time_disappear")
					end
					_strTb["str2"][2]=G_ColorYellowPro
				elseif base.richMineOpen==1 and base.landFormOpen==1 and self.report.richLevel and self.report.richLevel>0 then
					_strTb["str2"]={
						getlocal("mine_state")..":"..getlocal("richmine").."，"..getlocal("res_output_changeto")..tostring((mapHeatCfg.resourceSpeed[self.report.richLevel]+1)*100).."%",
						worldBaseVoApi:getRichMineColorByLv(self.report.richLevel)
					}
				elseif base.privatemine == 1 and self.report.privateMine == 1 then
						_strTb["str2"] = getlocal("mine_state")..": "..getlocal("privateMineName")
				else
					_strTb["str2"]=getlocal("mine_state")..":"..getlocal("merge_precent_name3")
				end
			end

			--繁荣度
			if base.isGlory ==1 then
				if boom and boomMax then
					_strTb["str6"]=getlocal("gloryDegreeStr").."："..getlocal("scheduleChapter",{boom,boomMax})
				end
			end
		end
	end

	local _lbSpaceY=10 --label之间的行间距
	local strSize=SizeOfTable(_strTb)
	local lbStr=_strTb["str1"]
	if type(lbStr)=="table" then
		lbStr=lbStr[1]
	end
	local lb=GetTTFLabel(lbStr,_lbFontSize)
	local _lbTotalHeight=strSize*lb:getContentSize().height+(strSize-1)*_lbSpaceY
	local _posY=_topBg:getContentSize().height-(_topBg:getContentSize().height-_lbTotalHeight)/2
	_posY=_posY-lb:getContentSize().height/2

	for i=1,7 do
		local _str,_color
		if type(_strTb["str"..i])=="string" then
			_str=_strTb["str"..i]
			_color=G_ColorWhite
		elseif type(_strTb["str"..i])=="table" then
			_str=_strTb["str"..i][1]
			_color=_strTb["str"..i][2]
		end
		if _str and _color then
			local label=GetTTFLabel(_str,_lbFontSize)
			label:setAnchorPoint(ccp(0,0.5))
			label:setPosition(islandSpPosX+islandShowSize/2+20,_posY)
			label:setColor(_color)
			_topBg:addChild(label)
			if pos and i==3 then --坐标
				local menu,menuItem,posLb=G_createReportPositionLabel(pos,_lbFontSize)
				menuItem:setAnchorPoint(ccp(0,0.5))
				menu:setAnchorPoint(ccp(0,0.5))
				menu:setTouchPriority(-(self.layerNum-1)*20-4)
				menu:setPosition(label:getPositionX()+label:getContentSize().width,label:getPositionY())
				_topBg:addChild(menu)
			elseif landformPic and i==4 then --地形图标
				local islandIcon=LuaCCSprite:createWithSpriteFrameName(landformPic,function()
					G_showReportIslandInfo(self.layerNum+1,self.report.landform)
				end)
				islandIcon:setTouchPriority(-(self.layerNum-1)*20-2)
				islandIcon:setAnchorPoint(ccp(0,0.5))
				islandIcon:setPosition(label:getPositionX()+label:getContentSize().width,label:getPositionY())
				islandIcon:setScale((label:getContentSize().height+20)/islandIcon:getContentSize().height)
				_topBg:addChild(islandIcon)
			end
			_posY=label:getPositionY()-label:getContentSize().height-_lbSpaceY
		end
	end
	if islandType==6 then --侦查玩家城市，如果该玩家有AI部队正在生产，有特殊显示
		-- print("self.report.aistatus--->>",self.report.aistatus)
		if self.report and self.report.aistatus and tonumber(self.report.aistatus)==1 then
			local aitroopsSp = CCSprite:createWithSpriteFrameName("AIid_3_1.png")
			aitroopsSp:setScale(0.65)
			aitroopsSp:setPosition(_topBg:getContentSize().width-aitroopsSp:getContentSize().width/2-20,aitroopsSp:getContentSize().height/2+40)
			_topBg:addChild(aitroopsSp)
			local statusLb = GetTTFLabel(getlocal("chuanwu_scene_process"),22)
			statusLb:setColor(G_ColorYellowPro)
			local blackBg = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20, 20, 10, 10),function () end)
			blackBg:setContentSize(CCSizeMake(120,36))
			blackBg:setAnchorPoint(ccp(0.5,1))
			blackBg:setOpacity(255*0.5)
			blackBg:setPosition(aitroopsSp:getPositionX(),aitroopsSp:getPositionY()-30)
			_topBg:addChild(blackBg,3)
			statusLb:setPosition(getCenterPoint(blackBg))
			blackBg:addChild(statusLb)
		end
	end
end

--侦察报告的处理
function scoutReportDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		if self.report.islandType==7 then --叛军
			return 1
		else
			return 2
		end
	elseif fn=="tableCellSizeForIndex" then
		return CCSizeMake(self.tvWidth,self:getReportCellHeight(idx))
	elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local cellWidth,cellHeight=self.tvWidth,self.cellHeightTb[idx+1]

        if idx==0 then
		    local titleBg, titleLb = G_createReportTitle(cellWidth-20,"")
		    titleBg:setAnchorPoint(ccp(0.5,0))
		    titleBg:setPosition(ccp(cellWidth/2, cellHeight-titleBg:getContentSize().height))
		    cell:addChild(titleBg)

		    if self.report.type==6 then
		    	titleLb:setString(getlocal("fight_content_resource_info"))	
				local posY=titleBg:getPositionY()-10

				local lbStr=getlocal("search_fleet_report_desc_5",{GetTimeForItemStr(self.report.leftTime)})
				local lb=GetTTFLabel(lbStr,20)
				lb:setAnchorPoint(ccp(0,1))
		        lb:setPosition(ccp(10,posY))
		        cell:addChild(lb)
		        posY=lb:getPositionY()-lb:getContentSize().height-10

		        local iconSize=38.5
				local spaceY=10
				if self.report.resource then
					for k, v in pairs(self.report.resource) do
						if v then
							local resSp=CCSprite:createWithSpriteFrameName(v.pic)
							resSp:setPosition(20+iconSize/2,posY-iconSize/2)
							resSp:setScale(iconSize/resSp:getContentSize().height)
							cell:addChild(resSp)

							local str=v.name.."："..FormatNumber(v.num)
							local numLable=GetTTFLabelWrap(str,20,CCSizeMake(cellWidth-resSp:getPositionX()-iconSize/2-15,0),kCCTextAlignmentLeft,kCCTextAlignmentCenter)
					        numLable:setAnchorPoint(ccp(0,0.5))
					        numLable:setPosition(ccp(resSp:getPositionX()+iconSize/2+15,resSp:getPositionY()))
							numLable:setColor(G_ColorGreen)
							cell:addChild(numLable,2)

							posY=resSp:getPositionY()-iconSize/2-spaceY
						end
					end
				end
		    else
			    if self.report.islandType==7 then --叛军兵力信息
					titleLb:setString(getlocal("alliance_challenge_enemy_info"))
					local shipTab=self.report.defendShip

					local _posX1=cellWidth/2-150
					local _posX2=cellWidth/2+150
					local _posY=titleBg:getPositionY()-10
					local lb1=GetTTFLabel(getlocal("front"),20)
					local lb2=GetTTFLabel(getlocal("back"),20)
					lb1:setAnchorPoint(ccp(0.5,1))
					lb2:setAnchorPoint(ccp(0.5,1))
					lb1:setPosition(_posX1,_posY)
					lb2:setPosition(_posX2,_posY)
					cell:addChild(lb1)
					cell:addChild(lb2)

					local _tankIconSize=100
					local _tankIconSpaceY=50
					_posY=_posY-lb1:getContentSize().height-10

					for k=1,6 do
						local tankIconBgPosX = (k>3) and _posX2 or _posX1
						local tankIconBgPosY=_posY-_tankIconSize/2-((k-1)%3)*(_tankIconSize+_tankIconSpaceY)

						local v
						if shipTab then
							v=shipTab[k]
						end
						if v and v.pic and v.name and v.num then
							local icon = CCSprite:createWithSpriteFrameName(v.pic)
							icon:setPosition(tankIconBgPosX,tankIconBgPosY)
							icon:setScale(_tankIconSize/icon:getContentSize().width)
							cell:addChild(icon)

							if G_pickedList(tonumber(RemoveFirstChar(v.key))) ~= tonumber(RemoveFirstChar(v.key)) then
					             local pickedIcon = CCSprite:createWithSpriteFrameName("picked_icon1.png")
					            icon:addChild(pickedIcon)
					            pickedIcon:setPosition(icon:getContentSize().width*0.7,icon:getContentSize().height*0.5-10)
					        end
							
							-- local str=(v.name).."("..FormatNumber(v.num)..")"
							local str=tostring(FormatNumber(v.num))
							local descLable = GetTTFLabelWrap(str,20,CCSizeMake(24*10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
					        descLable:setAnchorPoint(ccp(0.5,1))
							descLable:setPosition(ccp(tankIconBgPosX,tankIconBgPosY-_tankIconSize/2))
							cell:addChild(descLable)
						else
							local tankIconBg=CCSprite:createWithSpriteFrameName("tankShadeIcon.png")
							tankIconBg:setAnchorPoint(ccp(0.5,0.5))
							tankIconBg:setPosition(ccp(tankIconBgPosX,tankIconBgPosY))
							tankIconBg:setScale(_tankIconSize/tankIconBg:getContentSize().width)
							cell:addChild(tankIconBg)
						end
					end
				elseif self.report.islandType==6 then --玩家
					titleLb:setString(getlocal("fight_content_resource_info"))
					local iconSize=38.5
					local spaceY=10
					local posY=titleBg:getPositionY()-10
					local resource=self.report.resource
					for k,v in pairs(resource) do
						if v and v.pic and v.name and v.num then
							local icon = CCSprite:createWithSpriteFrameName(v.pic)
							icon:setPosition(20+iconSize/2,posY-iconSize/2)
							icon:setScale(iconSize/icon:getContentSize().height)
							cell:addChild(icon)
							local str=getlocal("scout_content_player_plunder",{(v.name),FormatNumber(v.num)})
							local numLable=GetTTFLabelWrap(str,20,CCSizeMake(cellWidth-icon:getPositionX()-iconSize/2-15,0),kCCTextAlignmentLeft,kCCTextAlignmentCenter)
					        numLable:setAnchorPoint(ccp(0,0.5))
					        numLable:setPosition(ccp(icon:getPositionX()+iconSize/2+15,icon:getPositionY()))
							numLable:setColor(G_ColorGreen)
							cell:addChild(numLable,2)
							posY=icon:getPositionY()-iconSize/2-spaceY
						end
					end
				elseif self.report.islandType>0 and self.report.islandType<6 then --普通资源矿
					titleLb:setString(getlocal("fight_content_resource_info"))	
					local posY=titleBg:getPositionY()-10

					local function showResources(showType,resTb)
						if resTb==nil then
							do return end
						end
						local iconSize=38.5
						local spaceY=10
						for k, v in pairs(resTb) do
							if v then
								local resSp=CCSprite:createWithSpriteFrameName(v.pic)
								resSp:setPosition(20+iconSize/2,posY-iconSize/2)
								resSp:setScale(iconSize/resSp:getContentSize().height)
								cell:addChild(resSp)

								local str=v.name.."："
								if showType==1 then
						        	str=str..FormatNumber(v.speed).."/h"
						        else
						        	str=str..FormatNumber(v.num)
						        end
								local numLable=GetTTFLabelWrap(str,20,CCSizeMake(cellWidth-resSp:getPositionX()-iconSize/2-15,0),kCCTextAlignmentLeft,kCCTextAlignmentCenter)
						        numLable:setAnchorPoint(ccp(0,0.5))
						        numLable:setPosition(ccp(resSp:getPositionX()+iconSize/2+15,resSp:getPositionY()))
								numLable:setColor(G_ColorGreen)
								cell:addChild(numLable,2)

								posY=resSp:getPositionY()-iconSize/2-spaceY
							end
						end
					end

					local proStr
					local strColor=G_ColorWhite
					if (base.wl==1 and base.goldmine==1 and self.report.goldMineLv and self.report.goldMineLv>0) then
						proStr=getlocal("goldmine_output_effect")
						strColor=G_ColorYellowPro
					elseif (base.landFormOpen==1 and base.richMineOpen==1 and self.report.richLevel and self.report.richLevel>0) then
						proStr=getlocal("richmine_output_effect")
						strColor=worldBaseVoApi:getRichMineColorByLv(self.report.richLevel)
					else
						proStr=getlocal("custom_output_effect")
					end
					if proStr then
					    local mineResLb=GetTTFLabel(proStr,20)
				        mineResLb:setAnchorPoint(ccp(0,1))
				        mineResLb:setColor(strColor)
				        mineResLb:setPosition(ccp(10,posY))
				        cell:addChild(mineResLb)
				        posY=mineResLb:getPositionY()-mineResLb:getContentSize().height-10
					end
					
					showResources(1,self.output)

					if self.report.islandOwner>0 then
				        local gatherLb=GetTTFLabel(getlocal("gather_output_defend"),20)
				        gatherLb:setAnchorPoint(ccp(0,1))
				        gatherLb:setPosition(ccp(10,posY))
				        gatherLb:setColor(G_ColorYellowPro)
				        cell:addChild(gatherLb)
				        posY=gatherLb:getPositionY()-gatherLb:getContentSize().height-10
						showResources(2,self.report.resource)
					end
				end
			end
		elseif idx==1 then --玩家或普通资源兵力信息
			local titleBg, titleLb = G_createReportTitle(cellWidth-20,getlocal("alliance_challenge_enemy_info"))
			titleBg:setAnchorPoint(ccp(0.5,0))
		    titleBg:setPosition(ccp(cellWidth/2, cellHeight-titleBg:getContentSize().height))
		    cell:addChild(titleBg)
			
			local shipTab=self.report.defendShip

			local _posX1=cellWidth/2-150
			local _posX2=cellWidth/2+150
			local _posY=titleBg:getPositionY()-10
			local lb1=GetTTFLabel(getlocal("front"),20)
			local lb2=GetTTFLabel(getlocal("back"),20)
			lb1:setAnchorPoint(ccp(0.5,1))
			lb2:setAnchorPoint(ccp(0.5,1))
			lb1:setPosition(_posX1,_posY)
			lb2:setPosition(_posX2,_posY)
			cell:addChild(lb1)
			cell:addChild(lb2)

			local _tankIconSize=100
			local _tankIconSpaceY=50
			_posY=_posY-lb1:getContentSize().height-10
			
			for k=1,6 do
				local tankIconBgPosX = (k>3) and _posX2 or _posX1
				local tankIconBgPosY=_posY-_tankIconSize/2-((k-1)%3)*(_tankIconSize+_tankIconSpaceY)
				
				local v
				if shipTab then
					v=shipTab[k]
				end
				if v and v.key and v.name and v.num then
					local skinId = self.report.tskinList[tankSkinVoApi:convertTankId(v.key)]
					local icon = tankVoApi:getTankIconSp(v.key,skinId,nil,false)--CCSprite:createWithSpriteFrameName(v.pic)
					icon:setPosition(tankIconBgPosX,tankIconBgPosY)
					icon:setScale(_tankIconSize/icon:getContentSize().width)
					cell:addChild(icon)

					if G_pickedList(tonumber(RemoveFirstChar(v.key))) ~= tonumber(RemoveFirstChar(v.key)) then
			             local pickedIcon = CCSprite:createWithSpriteFrameName("picked_icon1.png")
			            icon:addChild(pickedIcon)
			            pickedIcon:setPosition(icon:getContentSize().width*0.7,icon:getContentSize().height*0.5-10)
			        end
					
					-- local str=(v.name).."("..FormatNumber(v.num)..")"
					local str=tostring(FormatNumber(v.num))
					local descLable = GetTTFLabelWrap(str,20,CCSizeMake(24*10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
			        descLable:setAnchorPoint(ccp(0.5,1))
					descLable:setPosition(ccp(tankIconBgPosX,tankIconBgPosY-_tankIconSize/2))
					cell:addChild(descLable)
				else
					local tankIconBg=CCSprite:createWithSpriteFrameName("tankShadeIcon.png")
					tankIconBg:setAnchorPoint(ccp(0.5,0.5))
					tankIconBg:setPosition(ccp(tankIconBgPosX,tankIconBgPosY))
					tankIconBg:setScale(_tankIconSize/tankIconBg:getContentSize().width)
					cell:addChild(tankIconBg)
				end
			end
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


--侦察报告每个显示元素的高度
function scoutReportDialog:getReportCellHeight(idx)
	if self.cellHeightTb==nil then
		self.cellHeightTb={}
	end
	if self.cellHeightTb[idx+1]==nil then
		local height=0

		if idx==0 then
			if self.report.type==6 then
				height=height+32 --titleBgHeight
				height=height+10 --local posY=titleBg:getPositionY()-10

				local lbStr=getlocal("search_fleet_report_desc_5",{GetTimeForItemStr(self.report.leftTime)})
				local lb=GetTTFLabel(lbStr,20)
				height=height+lb:getContentSize().height+10 --posY=lb:getPositionY()-lb:getContentSize().height-10

				local iconSize=38.5
				local spaceY=10
				if self.report.resource then
					for k, v in pairs(self.report.resource) do
						if v then
							height=height+iconSize+spaceY --posY=resSp:getPositionY()-iconSize/2-spaceY
						end
					end
				end
			else
				if self.report.islandType==7 then --叛军侦察报告
					height=height+32 --titleBgHeight
					height=height+10 --local _posY=titleBg:getPositionY()-10

					local lb1=GetTTFLabel(getlocal("front"),20)
					height=height+lb1:getContentSize().height+10 --_posY=_posY-lb1:getContentSize().height-10

					local _tankIconSize=100
					local _tankIconSpaceY=50
					height=height+3*(_tankIconSize+_tankIconSpaceY)
				elseif self.report.islandType==6 then --玩家
					height=height+32 --titleBgHeight
					height=height+10 --local posY=titleBg:getPositionY()-10
					local iconSize=38.5
					local spaceY=10
					for k,v in pairs(self.report.resource) do
						if v and v.pic and v.name and v.num then
							height=height+iconSize+spaceY --posY=icon:getPositionY()-iconSize/2-spaceY
						end
					end
				elseif self.report.islandType>0 and self.report.islandType<6 then --普通资源矿
					self.output=worldBaseVoApi:getMineResContent(self.report.islandType,self.report.level,self.report.richLevel,self.report.goldMineLv,false)
					
					height=height+32 --titleBgHeight
					height=height+10 --local posY=titleBg:getPositionY()-10

					local proStr
					if (base.wl==1 and base.goldmine==1 and self.report.goldMineLv and self.report.goldMineLv>0) then
						proStr=getlocal("goldmine_output_effect")
					elseif (base.landFormOpen==1 and base.richMineOpen==1 and self.report.richLevel and self.report.richLevel>0) then
						proStr=getlocal("richmine_output_effect")
					else
						proStr=getlocal("custom_output_effect")
					end
					if proStr then
					    local mineResLb=GetTTFLabel(proStr,20)
				        height=height+mineResLb:getContentSize().height+10 --posY=mineResLb:getPositionY()-mineResLb:getContentSize().height-10
					end

					local iconSize=38.5
					local spaceY=10
					for k, v in pairs(self.output) do
						if v then
							height=height+iconSize+spaceY --posY=resSp:getPositionY()-iconSize/2-spaceY
						end
					end

					if self.report.islandOwner>0 then --是否有驻军
				        local gatherLb=GetTTFLabel(getlocal("gather_output_defend"),20)
				        height=height+gatherLb:getContentSize().height+10 --posY=gatherLb:getPositionY()-gatherLb:getContentSize().height-10
						for k, v in pairs(self.report.resource) do
							if v then
								height=height+iconSize+spaceY --posY=resSp:getPositionY()-iconSize/2-spaceY
							end
						end
					end
				end
			end
		elseif idx==1 then
			height=height+32 --titleBgHeight
			height=height+10 --local _posY=titleBg:getPositionY()-10
			
			local lb1=GetTTFLabel(getlocal("front"),20)
			height=height+lb1:getContentSize().height+10 --_posY=_posY-lb1:getContentSize().height-10

			local _tankIconSize=100
			local _tankIconSpaceY=50
			height=height+3*(_tankIconSize+_tankIconSpaceY)
		end

		self.cellHeightTb[idx+1]=height
	end
	return self.cellHeightTb[idx+1]
end

function scoutReportDialog:dispose()
	if self.bgLayer then
		self.bgLayer:removeFromParentAndCleanup(true)
		self.bgLayer=nil
	end
	self.report=nil
	self.showType=nil
	self.cellHeightTb=nil
	self.layerNum=nil
	self.tvWidth=nil
	self.tvHeight=nil
	self.tv=nil
	self.isMoved=nil

	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/world_ground.plist")
	CCTextureCache:sharedTextureCache():removeTextureForKey("public/world_ground.pvr.ccz")
	spriteController:removePlist("public/emailNewUI.plist")
  	spriteController:removeTexture("public/emailNewUI.png")
  	spriteController:removePlist("public/youhuaUI3.plist")
  	spriteController:removeTexture("public/youhuaUI3.png")
end

return scoutReportDialog