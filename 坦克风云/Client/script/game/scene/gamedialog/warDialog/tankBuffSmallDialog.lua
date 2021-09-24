tankBuffSmallDialog=smallDialog:new()

function tankBuffSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.message={}
	self.tv=nil
	return nc
end

function tankBuffSmallDialog:init(bgSrc,size,fullRect,inRect,content,istouch,isuseami,layerNum,callBackHandler,isAutoSize,speciaTb)
	self.isTouch=istouch
    self.isUseAmi=isuseami

    local tmpTb={}
    local cellNum = 0
    local useBossBuf = nil
    local tankNameTb = {}
    if content and type(content)=="table" then
        for k,v in pairs(content) do
            if v and v[1] then
                local tankId=v[1]
                local id=(tonumber(tankId) or tonumber(RemoveFirstChar(tankId)))
                if id and tankCfg[id] and tankCfg[id].buffShow and tankCfg[id].buffShow[1] then
                    local type=tankCfg[id].buffShow[1]
                    if tmpTb[type]==nil then
                        tmpTb[type]=1
                        table.insert(self.message,id)
                    end
                end
            end
        end
        cellNum = SizeOfTable(self.message)
    elseif speciaTb then
        if speciaTb[1] == 12 then
            useBossBuf= true
            cellNum = 4
            tankNameTb = {[1]=getlocal("tanke"), [2]=getlocal("jianjiche"), [4]=getlocal("zixinghuopao"), [8]=getlocal("huojianche")}
        end
    end

    if isAutoSize==true then
        if cellNum > 0 then
            local cNum=cellNum--SizeOfTable(self.message)
            local spaceH=170
            local dHeight
            if cNum>=4 then
                dHeight=100+spaceH*4-70
            else
                dHeight=100+spaceH*cNum
            end
            size=CCSizeMake(size.width,dHeight)
        end
    end
    local function touchHander()
    
    end
    -- local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHander)
    local dialogBg = G_getNewDialogBg2(size,layerNum,touchHander)
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    -- self:userHandler()

    -- local titleLb=GetTTFLabelWrap(title,40,CCSizeMake(size.width-50,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    -- titleLb:setAnchorPoint(ccp(0.5,0.5))
    -- titleLb:setPosition(ccp(size.width/2,size.height-45))
    -- dialogBg:addChild(titleLb)
    
    local cellWidth=490
    local cellHeight=160
    local isMoved=false
    local iconSize=80
    local labelSize=G_isAsia() and 25 or 20
    local labelWidth=150
    local fWidth=20
    local fHeight=cellHeight-50
    local sHeight=35
    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return cellNum--SizeOfTable(self.message)
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize=CCSizeMake(cellWidth,cellHeight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            local tankId,id,type= nil,nil,nil
            if content then
                tankId=self.message[idx+1]
            	id=(tonumber(tankId) or tonumber(RemoveFirstChar(tankId)))
            	type=tankCfg[id].buffShow[1]
            end

            local ghPic= useBossBuf and "hydraBuf_"..(idx+1)..".png" or "tank_gh_icon_" ..type.. ".png"
            local ghSp = CCSprite:createWithSpriteFrameName(ghPic);
            local iconScale=iconSize/ghSp:getContentSize().width
            ghSp:setAnchorPoint(ccp(0.5,0.5));
            ghSp:setPosition(fWidth+iconSize/2,fHeight)
            cell:addChild(ghSp,2)
            ghSp:setScale(iconScale)

            local nameStr = useBossBuf and getlocal("hydraBuf_name") or getlocal("tank_gh_name_" .. type)
            local ghNameLb=GetTTFLabel(nameStr,labelSize)
            ghNameLb:setAnchorPoint(ccp(0,0.5))
            ghNameLb:setPosition(ccp(fWidth+iconSize+10,fHeight))
            cell:addChild(ghNameLb)

            local ghLvLb=GetTTFLabel(getlocal("fightLevel",{useBossBuf and idx+1 or tankCfg[id].buffShow[2]}),labelSize)
            ghLvLb:setAnchorPoint(ccp(0,0.5))
            ghLvLb:setPosition(ccp(fWidth+iconSize+10+ghNameLb:getContentSize().width+25,fHeight))
            cell:addChild(ghLvLb)
            ghLvLb:setColor(G_ColorYellowPro)

            if useBossBuf then
                    if bossCfg and bossCfg.specialBuffSkill then
                        local cfg = bossCfg.specialBuffSkill[idx + 1]
                        local descStr = ""
                        if idx + 1 ==1 then
                            local crit = cfg.buff1.crit * 100
                            descStr = getlocal("hydraBuf_desc1",{crit})
                        elseif idx + 1 == 2 then
                            local crit = cfg.buff1.crit * 100
                            local atk = cfg.buff2.atk[1] * 100
                            local tank1 = cfg.tank1
                            local tank21 = cfg.tank2[1]
                            -- local tank22 = cfg.tank2[2]
                            descStr = getlocal("hydraBuf_desc2",{tankNameTb[tank21[1]],tankNameTb[tank21[2]],atk,tankNameTb[tank1[1]],tankNameTb[tank1[2]],crit})
                        elseif idx + 1 == 3 then
                            local crit = cfg.buff1.crit * 100
                            local atk1 = cfg.buff2.atk[1] * 100
                            local atk2 = cfg.buff2.atk[2] * 100
                            local tank1 = cfg.tank1
                            local tank21 = cfg.tank2[1]
                            local tank22 = cfg.tank2[2]
                            descStr = getlocal("hydraBuf_desc3",{tankNameTb[tank22[1]], atk2, tankNameTb[tank21[1]], tankNameTb[tank21[2]], atk1,tankNameTb[tank1[1]], crit})
                        elseif idx + 1 == 4 then
                            local crit = cfg.buff1.crit * 100
                            local atk1 = cfg.buff2.atk[1] * 100
                            local atk2 = cfg.buff2.atk[2] * 100
                            local atk3 = cfg.buff2.atk[3] * 100
                            local tank21 = cfg.tank2[1]
                            local tank22 = cfg.tank2[2]
                            local tank23 = cfg.tank2[3]
                            descStr = getlocal("hydraBuf_desc4",{tankNameTb[tank21[1]], atk1, tankNameTb[tank22[1]], tankNameTb[tank22[2]], atk2, tankNameTb[tank23[1]], atk3, crit})
                        end
                        local descLb = GetTTFLabelWrap(descStr,labelSize - 4 , CCSizeMake(cellWidth - 40, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                        local lbHeight = descLb:getContentSize().height
                        descLb:setPosition(20,sHeight+lbHeight/2 - 2)
                        descLb:setAnchorPoint(ccp(0,1))
                        if speciaTb[2] ~= idx + 1 then
                            ghNameLb:setColor(G_ColorGray)
                            ghLvLb:setColor(G_ColorGray)
                            descLb:setColor(G_ColorGray)
                        end
                        cell:addChild(descLb,2)
                    end
            else
                    local value
                    if tonumber(tankCfg[id].buffvalue)<1 then
                        value=tonumber(tankCfg[id].buffvalue)*100
                    else
                        value=tonumber(tankCfg[id].buffvalue)
                    end
                    local desStr=getlocal("tank_gh_des_" .. type,{value})
                    -- desStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
                    local ghDesLb,lbHeight=G_getRichTextLabel(desStr,{G_ColorWhite,G_ColorGreen},labelSize-2,cellWidth-40,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                    -- GetTTFLabelWrap(desStr,labelSize-2,lbSize,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                    ghDesLb:setPosition(20,sHeight+lbHeight/2)
                    ghDesLb:setAnchorPoint(ccp(0,1))
                    cell:addChild(ghDesLb,2)
            end

            return cell
        elseif fn=="ccTouchBegan" then
            isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            isMoved=true
        elseif fn=="ccTouchEnded"  then

        end
    end
    local hd=LuaEventHandler:createHandler(tvCallBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,size.height-250+150),nil)
    self.tv:setTableViewTouchPriority(-(layerNum-1)*20-2)
    self.tv:setPosition(ccp(60/2,110-60))
    self.bgLayer:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(120)

    
    local function touchLuaSpr()
        if self.isTouch==true and isMoved==false then
            if self.bgLayer~=nil then
                PlayEffect(audioCfg.mouseClick)
                self:close()
            end
        end
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1);

    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(ccp(0,0))

end

function tankBuffSmallDialog:dispose()
	self.message={}
	self.tv=nil
end
