scrollSmallDialog=smallDialog:new()

function scrollSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function scrollSmallDialog:showScrollDialog(params)
	local sd=scrollSmallDialog:new()
    sd:initScrollDialog(params)
end

function scrollSmallDialog:initScrollDialog(params)

    local function tmpFunc()
    end
    local rrect=CCRect(0, 50, 1, 1)
    self.dialogLayer=CCLayer:create()

    local startH=G_VisibleSizeHeight/2+300
    local count=0

    local width=450
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg_black.png",CCRect(20, 20, 10, 10),tmpFunc)
	dialogBg:setContentSize(CCSize(width+40,50))
	dialogBg:setIsSallow(false)
	dialogBg:setOpacity(180)
	self.dialogLayer:addChild(dialogBg,1)
	-- dialogBg:setAnchorPoint(ccp(0,0.5))
	dialogBg:setPosition(G_VisibleSizeWidth/2,startH)

    sceneGame:addChild(self.dialogLayer,3)

    local function eventHandler(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return 1
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize
            tmpSize=CCSizeMake(width,50)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            local str=""
		    local paramTb={}
		    local colorTb={G_ColorWhite}
		    if params.param then
		    	for k,v in pairs(params.param) do
			    	local subStr=""
			    	-- 1:玩家名称  蓝色 2:活动名称/关卡名称/地点名称/名称 蓝色 3:等级/排名/ 数字 黄色 4:奖励 5:技能名称/不到品质道具 黄色 6：白色 需要getlocal 7:白色 不需要getlocal 8:vip 需要加上一个vip字符串
			    	if v[1]=="avt" then --成就系统特殊处理
			    		subStr="<rayimg>" .. v[1] .. "<rayimg>"
			    		if achievementVoApi then
			    			local atype,avtId,idx=v[2],v[3],v[4]
			    			local avtNameStr,color=achievementVoApi:getAvtNameStrAndColor(atype,avtId,idx)
			    			subStr="<rayimg>" .. avtNameStr .. "<rayimg>"
			    			table.insert(colorTb,color)
			    		end
			    	elseif v[2]==1 then
			    		subStr="<rayimg>" .. v[1] .. "<rayimg>"
			    		table.insert(colorTb,G_ColorBlue)
		    		elseif v[2]==2 then
		    			subStr="<rayimg>" .. getlocal(v[1]) .. "<rayimg>"
		    			table.insert(colorTb,G_ColorBlue)
	    			elseif v[2]==3 then
	    				subStr="<rayimg>" .. v[1] .. "<rayimg>"
	    				table.insert(colorTb,G_ColorYellowPro)
					elseif v[2]==4 then
						local item=FormatItem(v[1])
						for k,v in pairs(item) do
							if k==SizeOfTable(item) then
								subStr=subStr.. "<rayimg>" .. v.name .. "x" .. v.num .. "<rayimg>"
							else
								subStr=subStr.. "<rayimg>" .. v.name .. "x" .. v.num .. "," .. "<rayimg>"
							end
							if v.eType=="h" then
								if v.num==1 then
									table.insert(colorTb,G_ColorWhite)
								elseif v.num==2 then
									table.insert(colorTb,G_ColorGreen)
								elseif v.num==3 then
									table.insert(colorTb,G_ColorBlue)
								elseif v.num==4 then
									table.insert(colorTb,G_ColorPurple)
								elseif v.num==5 then
									table.insert(colorTb,G_ColorOrange)
								else
									table.insert(colorTb,G_ColorYellowPro)
								end
							elseif v.eType=="a" then
								local quality=accessoryCfg.aCfg[v.key]["quality"]
								if quality==1 then
									table.insert(colorTb,G_ColorGreen)
								elseif quality==2 then
									table.insert(colorTb,G_ColorBlue)
								elseif quality==3 then
									table.insert(colorTb,G_ColorPurple)
								elseif quality==4 then
									table.insert(colorTb,G_ColorOrange)
								else
									table.insert(colorTb,G_ColorYellowPro)
								end
							elseif v.eType=="f" then
								local quality=accessoryCfg.fragmentCfg[v.key]["quality"]
								if quality==1 then
									table.insert(colorTb,G_ColorGreen)
								elseif quality==2 then
									table.insert(colorTb,G_ColorBlue)
								elseif quality==3 then
									table.insert(colorTb,G_ColorPurple)
								elseif quality==4 then
									table.insert(colorTb,G_ColorOrange)
								else
									table.insert(colorTb,G_ColorYellowPro)
								end
							else
								table.insert(colorTb,G_ColorYellowPro)
							end
						end
					elseif v[2]==5 then
						subStr="<rayimg>" .. getlocal(v[1]) .. "<rayimg>"
						table.insert(colorTb,G_ColorYellowPro)
					elseif v[2]==6 then
						subStr="<rayimg>" .. getlocal(v[1]) .. "<rayimg>"
						table.insert(colorTb,G_ColorWhite)
					elseif v[2]==7 then
						subStr="<rayimg>" .. v[1] .. "<rayimg>"
						table.insert(colorTb,G_ColorWhite)
					elseif v[2]==8 then
						subStr="<rayimg>" .. getlocal("help1_t1_t1") ..  v[1] .. "<rayimg>"
						table.insert(colorTb,G_ColorYellowPro)
			    	end
			    	table.insert(paramTb,subStr)
			    	table.insert(colorTb,G_ColorWhite)
			    end
		    end
		    if params.key and paramTb then
			    str=getlocal(params.key,paramTb)
		    elseif params.sys then
		    	str=params.sys.desc
		    end
		    str=str or ""
		    local relalStr=string.gsub(str,"<rayimg>","")
		    local desLb=GetTTFLabel(relalStr,26)
		    local desWidth=desLb:getContentSize().width
			local ghDesLb,lbHeight=G_getRichTextLabel(str,colorTb,25,desWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			ghDesLb:setPosition(width+60,37)
		    ghDesLb:setAnchorPoint(ccp(0,1))
		    cell:addChild(ghDesLb,2)

		    local speakerSp=CCSprite:createWithSpriteFrameName("scroll_speaker_yellow.png")
		    speakerSp:setAnchorPoint(ccp(0,0.5))
		    speakerSp:setPosition(width,25)
		    cell:addChild(speakerSp)

		    local moveTo = CCMoveTo:create(10,CCPointMake(-desWidth-60,25))
		    speakerSp:runAction(moveTo)
            
            local function closeFunc()
            	self:realClose()
            	if jumpScrollMgr and jumpScrollMgr.scrollEndHandler then --每次滚动结束之后执行一次该回调
            		jumpScrollMgr:scrollEndHandler()
            	end
            end
            local moveTo = CCMoveTo:create(10,CCPointMake(-desWidth,37))
            local callFunc1 = CCCallFunc:create(closeFunc)

            local seq=CCSequence:createWithTwoActions(moveTo,callFunc1)
            ghDesLb:runAction(seq)
            return cell
        elseif fn=="ccTouchBegan" then
            -- self.isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            -- self.isMoved=true
        elseif fn=="ccTouchEnded"  then

        end
    end

    local function callBack(...)
        return eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 	local tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(width,50),nil)
    tv:setTableViewTouchPriority(-(1-1)*20-3)
    tv:setPosition(ccp((G_VisibleSizeWidth-width)/2,startH-25))
    self.dialogLayer:addChild(tv,2)
    tv:setMaxDisToBottomOrTop(0)


    base:removeFromNeedRefresh(self) --停止刷新

end