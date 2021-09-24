acHeartOfIronDialog=commonDialog:new()

function acHeartOfIronDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.cellHeight=170
	self.countLb=nil
	self.isToday=nil

	return nc
end

function acHeartOfIronDialog:initTableView()
	self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-30,G_VisibleSizeHeight-110))
	self.panelLineBg:setAnchorPoint(ccp(0,0))
	self.panelLineBg:setPosition(ccp(15,20))

	acHeartOfIronVoApi:updateNum()

	local function callBack(...)
		return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-40,G_VisibleSizeHeight-145),nil)
	self.bgLayer:addChild(self.tv)
	self.tv:setAnchorPoint(ccp(0,0))
	self.tv:setPosition(ccp(20,35))
	self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setMaxDisToBottomOrTop(120)

	self.isToday=G_isToday(base.serverTime)
	acHeartOfIronVoApi:setFlag(1)
	local vo=acHeartOfIronVoApi:getAcVo()
	activityVoApi:updateShowState(vo)
end

function acHeartOfIronDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		local acVo=acHeartOfIronVoApi:getAcVo()
		if acVo and acVo.taskTab then
			return SizeOfTable(acVo.taskTab)
		end
		return 0
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize=CCSizeMake(G_VisibleSizeWidth-40,self.cellHeight)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local acVo=acHeartOfIronVoApi:getAcVo()
		local key=acVo.taskTab[idx+1].type
		local condition=acVo.taskTab[idx+1].cfgNum
		local value=acVo.taskTab[idx+1].num
		local hadReward=acVo.taskTab[idx+1].isReward

		local acCfg=acHeartOfIronVoApi:getAcCfg()
		local cfg=acCfg[key]

		local status=acHeartOfIronVoApi:getStatus(idx+1)
		local isComplete=acHeartOfIronVoApi:isComplete(key)
		local hadReward=acHeartOfIronVoApi:hadReward(key)
		local canReward=acHeartOfIronVoApi:canRewardByIndex(idx+1,key)

		local cellWidth=G_VisibleSizeWidth-40

		local function cellClick(hd,fn,idx)
		end

		local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),cellClick)
		backSprie:setAnchorPoint(ccp(0.5,0.5))
		backSprie:setContentSize(CCSizeMake(cellWidth, self.cellHeight-5))
		backSprie:setPosition(ccp(cellWidth/2,self.cellHeight/2))
		cell:addChild(backSprie)

		local lineSP =CCSprite:createWithSpriteFrameName("LineCross.png")
		lineSP:setAnchorPoint(ccp(0.5,0.5))
		lineSP:setScaleX(G_VisibleSizeWidth/lineSP:getContentSize().width)
		-- lineSP:setScaleY(1.2)
		lineSP:setPosition(ccp(cellWidth/2,self.cellHeight/2+30))
		cell:addChild(lineSP,1)

		local px,py=lineSP:getPosition()
		local py1=(self.cellHeight/2+30+self.cellHeight)/2
		local py2=(self.cellHeight/2+30)/2


		-- local str="сундук отлитый золотом, можно получить"
		-- local stepLb = GetTTFLabelWrap(str,22,CCSizeMake(cellWidth/2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		local stepLb = GetTTFLabelWrap(getlocal("activity_heartOfIron_days",{idx+1}),22,CCSizeMake(cellWidth/2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		stepLb:setAnchorPoint(ccp(0,0.5))
		stepLb:setPosition(ccp(10,py1))
		cell:addChild(stepLb,1)
		stepLb:setColor(G_ColorGreen)

		if status==0 then
			-- local endLb = GetTTFLabelWrap(str,22,CCSizeMake(cellWidth/2,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
			local endLb = GetTTFLabelWrap(getlocal("activity_heartOfIron_over"),22,CCSizeMake(cellWidth/2,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
			endLb:setAnchorPoint(ccp(1,0.5))
			endLb:setPosition(ccp(cellWidth-10,py1))
			cell:addChild(endLb,1)
			endLb:setColor(G_ColorGreen) 
		elseif status==1 then
			local countStr=acHeartOfIronVoApi:getCountdownStr() or ""
			self.countLb = GetTTFLabel(countStr,22)
			self.countLb:setAnchorPoint(ccp(0.5,0.5))
			self.countLb:setPosition(ccp(cellWidth-68,py1))
			cell:addChild(self.countLb,1)
			self.countLb:setColor(G_ColorRed)
		end

		local pic=cfg.pic
		local addBg=cfg.addBg
		local size=80
		local icon
		if addBg==true then
			icon=GetBgIcon(pic)
		else
			icon=CCSprite:createWithSpriteFrameName(pic)
		end
		local scale=size/icon:getContentSize().width
		icon:setAnchorPoint(ccp(0.5,0.5))
		icon:setScale(scale)
		icon:setPosition(ccp(size/2+10,py2))
		cell:addChild(icon,1)

		-- str="сундук отлитый золотом, можно получить один из один один один один"
		-- local nameLb = GetTTFLabelWrap(str,20,CCSizeMake(cellWidth/2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		local nameStr=getlocal(cfg.name)
		local nameLb = GetTTFLabelWrap(nameStr,20,CCSizeMake(cellWidth/2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		nameLb:setAnchorPoint(ccp(0,0.5))
		nameLb:setPosition(ccp(size+20,py-30))
		cell:addChild(nameLb,1)
		nameLb:setColor(G_ColorYellowPro)
		
		local scheduleStr=""
		local color=G_ColorWhite
		if isComplete==true then
			scheduleStr=getlocal("schedule_finish")
			color=G_ColorGreen
		else
			scheduleStr=getlocal("schedule_not_finish")
		end
		-- str="сундук отлитый золотом, можно получить один из"
		-- local scheduleLb = GetTTFLabelWrap(str,20,CCSizeMake(cellWidth/2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		local scheduleLb = GetTTFLabelWrap(scheduleStr,20,CCSizeMake(cellWidth/2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		scheduleLb:setAnchorPoint(ccp(0,0.5))
		scheduleLb:setPosition(ccp(size+20,30))
		cell:addChild(scheduleLb,1)
		scheduleLb:setColor(color)

		local btnScale=0.7
		if canReward==true then
			local function rewardHandler(tag,object)
				local function heartofironCallback(fn,data)
	                local ret,sData=base:checkServerData(data)
	                if ret==true then
	                    local acVo=acHeartOfIronVoApi:getAcVo()
						local award=acVo.reward[idx+1]
						for k,v in pairs(award) do
							G_addPlayerAward(v.type,v.key,v.id,tonumber(v.num),nil,true)
						end
						G_showRewardTip(award,true)

						acHeartOfIronVoApi:setHadReward(key)

						if self.tv then
							local recordPoint = self.tv:getRecordPoint()
					        self.tv:reloadData()
					        self.tv:recoverToRecordPoint(recordPoint)
						end
	                end
	            end
	            local method=cfg.method
				socketHelper:activeHeartofironReward(method,heartofironCallback)
			end
			local rewardBtn = GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",rewardHandler,idx+1,getlocal("daily_scene_get"),25)
			rewardBtn:setScale(btnScale)
		    local rewardMenu = CCMenu:createWithItem(rewardBtn)
		    rewardMenu:setPosition(ccp(cellWidth-rewardBtn:getContentSize().width/2*btnScale-10,py2))
		    rewardMenu:setTouchPriority(-(self.layerNum-1)*20-2)
		    cell:addChild(rewardMenu,2)
		elseif hadReward==true then
			-- str="啊啊啊啊啊啊啊啊啊啊啊啊"
			-- local rewardLb = GetTTFLabelWrap(str,22,CCSizeMake(cellWidth/4-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			local rewardLb = GetTTFLabelWrap(getlocal("activity_hadReward"),22,CCSizeMake(cellWidth/4-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			rewardLb:setAnchorPoint(ccp(0.5,0.5))
			rewardLb:setPosition(ccp(cellWidth-68,py2))
			cell:addChild(rewardLb,1)
			rewardLb:setColor(G_ColorGreen)
		elseif status==1 and isComplete==false and hadReward==false then
			local function gotoHandler(tag,object)
				if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
	                if G_checkClickEnable()==false then
	                    do
	                        return
	                    end
	                else
	                    base.setWaitTime=G_getCurDeviceMillTime()
	                end
			        --PlayEffect(audioCfg.mouseClick)

			        if key=="alevel" then
			        	--"配件"
			        	if base.ifAccessoryOpen==0 then
							smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage6004"),30)
							do return end
						end
						if (playerVoApi:getPlayerLevel()<accessoryCfg.accessoryUnlockLv) then
				            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("elite_challenge_unlock_level",{accessoryCfg.accessoryUnlockLv}),30)
				            do return end
				        end
			        elseif key=="acrd" then
			        	--"军团副本"
			        	local bid=1
						local bType=7
						local buildVo=buildingVoApi:getBuildiingVoByBId(bid)
						if buildVo and buildVo.level<5 then --指挥中心5级开放军团
							smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("port_scene_building_tip_6"),30)
							do return end
						end
						if base.isAllianceSwitch==0 then
	                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_willOpen"),30)
                            do return end
                        end
                        if base.isAllianceFubenSwitch==0 then
                        	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_notOpen"),30)
                            do return end
                        end
                    elseif key=="tech" then
						--"科技中心"
						local bid=3
						local bType=8
						local buildVo=buildingVoApi:getBuildiingVoByBId(bid)
						if buildVo and buildVo.status>0 then
							
						else
							smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_heartOfIron_no_building"),30)
							do return end
						end
					elseif key=="troops" then
						--“坦克工厂”
						local bid=11
						local bType=6
						local buildVo=buildingVoApi:getBuildiingVoByBId(bid)
						if buildVo and buildVo.status>0 then

						else
							smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_heartOfIron_no_building"),30)
							do return end
						end
			        end

		            activityAndNoteDialog:closeAllDialog()

					local dlayerNum=3
					if key=="blevel" then
						--"指挥中心"
                        require "luascript/script/game/scene/gamedialog/portbuilding/commanderCenterDialog"
						local bid=1
						local bType=7
						local buildVo=buildingVoApi:getBuildiingVoByBId(bid)
						local td=commanderCenterDialog:new(bid)
						local bName=getlocal(buildingCfg[bType].buildName)
						local tbArr={getlocal("building"),getlocal("shuoming")}
						local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,bName.."("..G_LV()..buildVo.level..")",true)
						sceneGame:addChild(dialog,dlayerNum)
					elseif key=="ulevel" then
						--"角色面板"
			   --          local td=playerDialog:new(1,dlayerNum)
			   --          local tbArr={getlocal("playerInfo"),getlocal("skillTab"),getlocal("buildingTab")}
			   --          local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("playerRole"),true,dlayerNum)
			   --          td:tabClick(0)
						-- sceneGame:addChild(dialog,dlayerNum)
						--"任务面板"
						taskVoApi:updateDailyTaskNum()
                        require "luascript/script/game/scene/gamedialog/taskDialog"
                        require "luascript/script/game/scene/gamedialog/taskDialogTab1"
                        require "luascript/script/game/scene/gamedialog/taskDialogTab2"
					    local td = taskDialog:new()
					    local tbArr={getlocal("taskPage"),getlocal("dailyTaskPage")}
					    local vd = td:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("task"),true,dlayerNum)
					    sceneGame:addChild(vd,dlayerNum)
					elseif key=="alevel" then
						--"配件"
						accessoryVoApi:showAccessoryDialog(sceneGame,dlayerNum)
					elseif key=="acrd" then
						--"军团副本"
                        if allianceVoApi:isHasAlliance()==false then
                            require "luascript/script/game/scene/gamedialog/allianceDialog/allianceDialog"
                            local td=allianceDialog:new(1,dlayerNum)
                            G_AllianceDialogTb[1]=td
                            local tbArr={getlocal("alliance_list_scene_list"),getlocal("alliance_list_scene_create")}
                            local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("alliance_list_scene_name"),true,dlayerNum)
                            sceneGame:addChild(dialog,dlayerNum)
                        else
                            -- allianceEventVoApi:clear()
                            -- local td=allianceExistDialog:new(1,dlayerNum)
                            -- G_AllianceDialogTb[1]=td
                            -- local tbArr={getlocal("alliance_info_title"),getlocal("alliance_function"),getlocal("alliance_list_scene_list")}
                            -- local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("alliance_list_scene_name"),true,dlayerNum)
                            -- sceneGame:addChild(dialog,dlayerNum)
                            -- td:tabClick(2,false,3)
                            local td=allianceFuDialog:new(dlayerNum)
                            local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,getlocal("alliance_duplicate"),true,dlayerNum)
                            sceneGame:addChild(dialog,dlayerNum)
                        end
					elseif key=="star" then
						--"关卡"
						storyScene:setShow()
					elseif key=="tech" then
						--"科技中心"
						local bid=3
						local bType=8
						local buildVo=buildingVoApi:getBuildiingVoByBId(bid)
						if buildVo and buildVo.status>0 then
                            require "luascript/script/game/scene/gamedialog/portbuilding/techCenterDialog"
							local td=techCenterDialog:new(bid,dlayerNum)
							local bName=getlocal(buildingCfg[bType].buildName)
							local tbArr={getlocal("building"),getlocal("startResearch")}
							local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,bName.."("..G_LV()..buildVo.level..")",true,dlayerNum)
							td:tabClick(1)
							sceneGame:addChild(dialog,dlayerNum)
						else
							smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_heartOfIron_no_building"),30)
						end
					elseif key=="troops" then
						--“坦克工厂”
						local bid=11
						local bType=6
						local buildVo=buildingVoApi:getBuildiingVoByBId(bid)
						if buildVo and buildVo.status>0 then
                            require "luascript/script/game/scene/gamedialog/portbuilding/tankFactoryDialog"
							local td=tankFactoryDialog:new(bid,dlayerNum)
				            local bName=getlocal(buildingCfg[bType].buildName)
				            local tbArr={getlocal("buildingTab"),getlocal("startProduce"),getlocal("chuanwu_scene_process")}
				            local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,bName.."("..G_LV()..buildVo.level..")",true,dlayerNum)
				            td:tabClick(1)
							sceneGame:addChild(dialog,dlayerNum)
						else
							smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_heartOfIron_no_building"),30)
						end
					end

			    end
			end
			local gotoBtn = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",gotoHandler,idx+1,getlocal("activity_heartOfIron_goto"),25)
			gotoBtn:setScale(btnScale)
		    local gotoMenu = CCMenu:createWithItem(gotoBtn)
		    gotoMenu:setPosition(ccp(cellWidth-gotoBtn:getContentSize().width/2*btnScale-10,py2))
		    gotoMenu:setTouchPriority(-(self.layerNum-1)*20-2)
		    cell:addChild(gotoMenu,2)
		end

		
		local function touchInfo(tag,object)
			if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
            
	            local acVo=acHeartOfIronVoApi:getAcVo()
				local condition=acVo.taskTab[idx+1].cfgNum
				local value=acVo.taskTab[idx+1].num
				-- local awardTab={p={{p20=1,index=1},{p13=1,index=2},{p2=1,index=3}},}
				-- local award=FormatItem(awardTab,nil,true)
				local award=acVo.reward[idx+1]

				local scheduleStr=""
				if isComplete==true then
					scheduleStr=getlocal("hadCompleted")
				else
					if value>condition then
						value=condition
					end
					scheduleStr=getlocal("schedule_count",{value,condition})
				end
	            local capInSet1 = CCRect(130, 50, 1, 1)
	            local descStr=getlocal(cfg.desc,{condition})
	            smallDialog:showTaskDialog("TankInforPanel.png",CCSizeMake(500,600),CCRect(0, 0, 400, 350),capInSet1,true,self.layerNum+1,{getlocal("award")," ",scheduleStr," ",descStr},25,award,nil,nil,true)
            end
		end
		local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touchInfo,idx+1,nil,nil)
	    local infoMenu = CCMenu:createWithItem(infoItem)
	    infoMenu:setPosition(ccp(cellWidth-170,py2))
	    infoMenu:setTouchPriority(-(self.layerNum-1)*20-2)
	    cell:addChild(infoMenu,2)

	    if status==2 and idx>0 then
			local function tmpFunc()
		    end
		    local maskSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),tmpFunc)
		    maskSp:setOpacity(255)
		    local size=CCSizeMake(backSprie:getContentSize().width,backSprie:getContentSize().height+5)
		    maskSp:setContentSize(size)
		    maskSp:setAnchorPoint(ccp(0.5,0.5))
		    maskSp:setPosition(ccp(backSprie:getContentSize().width/2,backSprie:getContentSize().height/2+5))
			maskSp:setIsSallow(true)
			maskSp:setTouchPriority(-(self.layerNum-1)*20-2)
			cell:addChild(maskSp,4)


			local stepLb2=GetTTFLabel(getlocal("activity_heartOfIron_days",{idx+1}),22)
			local stepLbWidth=stepLb2:getContentSize().width
			if stepLbWidth>cellWidth/2 then
				stepLbWidth=cellWidth/2
			end
			-- local openStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
			-- local openLb = GetTTFLabelWrap(openStr,22,CCSizeMake(cellWidth-stepLbWidth-25,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			local openLb = GetTTFLabelWrap(getlocal("activity_heartOfIron_open",{idx}),22,CCSizeMake(cellWidth-stepLbWidth-25,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			openLb:setAnchorPoint(ccp(0,0.5))
			openLb:setPosition(ccp(stepLbWidth+15,py1-3))
			maskSp:addChild(openLb,1)
			openLb:setColor(G_ColorRed)
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

function acHeartOfIronDialog:refresh(index)

end

function acHeartOfIronDialog:tick()
	if acHeartOfIronVoApi:isEnd()==true then
		self:close()
		do return end
	end
	if self.countLb then
		local countStr=acHeartOfIronVoApi:getCountdownStr()
		if countStr then
			self.countLb:setString(countStr)
		end
	end
	acHeartOfIronVoApi:updateNum()
	if self.isToday~=nil then
		if self.isToday~=G_isToday(base.serverTime) or acHeartOfIronVoApi:currentCanReward()==true then
			if self.tv then
				local recordPoint = self.tv:getRecordPoint()
		        self.tv:reloadData()
		        self.tv:recoverToRecordPoint(recordPoint)
			end
			self.isToday=G_isToday(base.serverTime)
		end
	end
end

function acHeartOfIronDialog:dispose()

end