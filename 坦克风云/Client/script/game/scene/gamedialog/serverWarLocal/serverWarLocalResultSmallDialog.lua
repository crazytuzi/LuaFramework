--群雄争霸结算小面板
serverWarLocalResultSmallDialog=smallDialog:new()

--param allianceID: 获胜军团的ID
--param endTs: 战斗结束的时间
function serverWarLocalResultSmallDialog:new(allianceID,endTs)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.winnerID=allianceID
	nc.endTs=endTs
	nc.dialogWidth=600
	nc.dialogHeight=500
	return nc
end

function serverWarLocalResultSmallDialog:init(layerNum)
	self.isTouch=nil
	self.layerNum=layerNum
	self:initBackground()
	self:initContent()
	sceneGame:addChild(self.dialogLayer,self.layerNum)
	return self.dialogLayer
end

function serverWarLocalResultSmallDialog:initBackground()
	local function nilFunc()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168, 86, 10, 10),nilFunc)
	dialogBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
    self.bgSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgLayer:setContentSize(self.bgSize)
	self:show()
	self.dialogLayer:addChild(self.bgLayer,1)
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)

	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
	local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
	self.dialogLayer:addChild(touchDialogBg)
end

function serverWarLocalResultSmallDialog:initContent()
	local headerSp
	if(self.winnerID==base.curZoneID.."-"..playerVoApi:getPlayerAid())then
		headerSp = CCSprite:createWithSpriteFrameName("SuccessHeader.png")
		headerSp:setPosition(ccp(self.dialogWidth/2,self.dialogHeight))
		self.bgLayer:addChild(headerSp,2)
	else
		headerSp = CCSprite:createWithSpriteFrameName("LoseHeader.png")
		headerSp:setPosition(ccp(self.dialogWidth/2,self.dialogHeight))
		self.bgLayer:addChild(headerSp,2)
	end
	local nameBg=CCSprite:createWithSpriteFrameName("TeamHeaderBg.png")
	nameBg:setScale(1.1)
	nameBg:setPosition(ccp(self.dialogWidth/2,self.dialogHeight - 115))
	self.bgLayer:addChild(nameBg)
	local winnerName
	for k,v in pairs(serverWarLocalFightVoApi:getAllianceList()) do
		if(v.id==self.winnerID)then
			winnerName=v.name
			break
		end
	end
	local nameLb
	if(winnerName)then
		nameLb=GetTTFLabel(getlocal("local_war_winner",{"【"..winnerName.."】"}),25)
	else
		nameLb=GetTTFLabel(getlocal("alliance_info_content"),25)
	end
	nameLb:setPosition(ccp(self.dialogWidth/2,self.dialogHeight - 115))
	self.bgLayer:addChild(nameLb)
	local tmpTb={}
	for k,allianceVo in pairs(serverWarLocalFightVoApi:getAllianceList()) do
		table.insert(tmpTb,allianceVo)
	end
	local pointTb=serverWarLocalFightVoApi:getPointTb()
	local function sortFunc(a,b)
		if(pointTb[a.id]==pointTb[b.id])then
			if(a.rankPoint==b.rankPoint)then
				if(a.power==b.power)then
					if(a.serverID==b.serverID)then
						return a.aid<b.aid
					else
						return a.serverID<b.serverID
					end
				else
					return a.power>b.power
				end
			else
				return a.rankPoint>b.rankPoint
			end
		else
			if(pointTb[b.id]==nil)then
				return true
			elseif(pointTb[a.id]==nil)then
				return false
			else
				return pointTb[a.id]>pointTb[b.id]
			end
		end
	end
	table.sort(tmpTb,sortFunc)
	for k,allianceVo in pairs(tmpTb) do
		local scoreLb=GetTTFLabel(allianceVo.name..": "..(serverWarLocalFightVoApi:getPointTb()[allianceVo.id] or 0),28)
		if(allianceVo.side==1)then
			scoreLb:setColor(G_ColorRed)
		elseif(allianceVo.side==2)then
			scoreLb:setColor(G_ColorPurple)
		elseif(allianceVo.side==3)then
			scoreLb:setColor(G_ColorBlue)
		elseif(allianceVo.side==4)then
			scoreLb:setColor(G_ColorGreen)
		end
		scoreLb:setPosition(self.dialogWidth/2,self.dialogHeight - 130 - k*35)
		self.bgLayer:addChild(scoreLb)
	end
	local function onConfirm()
		self:close()
	end
	local okItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onConfirm,1,getlocal("confirm"),25)
	local okBtn=CCMenu:createWithItem(okItem)
	okBtn:setTouchPriority(-(self.layerNum-1)*20-2)
	okBtn:setPosition(ccp(self.dialogWidth/2,60))
	self.bgLayer:addChild(okBtn)
end

function serverWarLocalResultSmallDialog:dispose()
	if(serverWarLocalMapScene and serverWarLocalMapScene.isShow)then
		serverWarLocalMapScene:close()
	end
	serverWarLocalFightVoApi:clear()
end