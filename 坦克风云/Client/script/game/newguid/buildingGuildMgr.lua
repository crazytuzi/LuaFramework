buildingGuildMgr={
	isGuilding=false, --当前是否在引导
	selectSp=nil,
	arrowSp=nil,
	mapScene=nil,
	isGuildSmallOpen=false,
	waitingForGuideTb=nil,
	hasInit=false,
}

function buildingGuildMgr:init()
	self.hasInit=true
	self.waitingForGuideTb={}
	base:addNeedRefresh(self)
end
function buildingGuildMgr:setGuildStep(stepId)
	if self.hasInit==false then
		self:init()
	end
	if stepId==nil then
		return
	end
	table.insert(self.waitingForGuideTb,stepId)
end

function buildingGuildMgr:showGuild(stepId)
	if self.isGuilding==true or stepId==nil then
		return false
	end
	local flag=false
	self.isGuilding=true
	local bid=stepId
	local unlockBuildCfg=homeCfg.buildingUnlock[bid]
	if unlockBuildCfg then
		local buildType=unlockBuildCfg.type
		if type(buildType)=="table" then
			buildType=buildType[1]
		end
		local buildPos=unlockBuildCfg.pos
		local bcfg=buildingCfg[buildType]

		if buildType and buildPos and bcfg then
			local pic,name,desc
			if buildType>=1 and buildType<=3 then
				pic="di_kuai_normal.png"
				name=getlocal("empty_resource_place")
				desc=getlocal("empty_resource_desc")
			else
				pic=bcfg.style
				name=getlocal(bcfg.buildName)
				desc=""
				if buildType<=5 or buildType==7 then
					desc=getlocal(bcfg.buildDescription,{FormatNumber(Split(bcfg.produceSpeed,",")[1]),FormatNumber(Split(bcfg.capacity,",")[1])})
				elseif buildType==10 then
					desc=getlocal(bcfg.buildDescription,{FormatNumber(Split(bcfg.capacity,",")[1])})
				elseif buildType==15 then
					desc=getlocal("alliance_build_desc")
				else
					desc=getlocal(bcfg.buildDescription)
				end
			end
			local buildData={buildType=buildType,pic=pic,name=name,desc=desc,pos=buildPos}
			--显示引导界面
			local function callback()
	            self:closeGuild()
				if buildType>=1 and buildType<=4 then
					mainUI:changeToMainLand()
				else
					mainUI:changeToMyPort()
				end
				self:moveLand(bid,buildType,buildPos)
				self:showGuildArrow()
			end
			self:showGuildSmallDialog(buildData,callback)
			flag=true
		end
	end
	return flag
end

function buildingGuildMgr:closeGuild()
	if self.selectSp and self.arrowSp then
		self.selectSp:removeFromParentAndCleanup(true)
		self.arrowSp:removeFromParentAndCleanup(true)
		self.selectSp=nil
		self.arrowSp=nil
	end
	self.buildSp=nil
	self.mapScene=nil
	self.isGuildSmallOpen=false
end

function buildingGuildMgr:moveLand(bid,buildType,buildPos)
	local offestX=0
	local offestY=0
	local mapX=0
	local mapY=0
	local mapScene=nil
	local bCenterPos=CCPointMake(0,0)
	local buildSize=CCSizeMake(100,100)
	if buildType>=1 and buildType<=4 then
		mapX=mainLandScene.clayer:getPositionX()
		mapY=mainLandScene.clayer:getPositionY()
		mapScene=mainLandScene
	else
		mapX=portScene.clayer:getPositionX()
		mapY=portScene.clayer:getPositionY()
		mapScene=portScene
	end
	if mapScene then
		self.mapScene=mapScene
		local buildSp=nil
		if buildings.allBuildings[bid] and buildings.allBuildings[bid].buildSp then
			buildSp=buildings.allBuildings[bid].buildSp
			self.buildSp=buildSp
		end
		if buildSp then
			buildSize=buildSp:getContentSize()
			local screenPos=buildSp:convertToWorldSpace(ccp(buildSize.width/2,buildSize.height/2))
			if screenPos.x>buildSize.width and screenPos.x<(G_VisibleSize.width-buildSize.width) 
				and screenPos.y>(buildSize.height+250) and screenPos.y<(G_VisibleSize.height-buildSize.height-350) then
				--当前建筑在屏幕内
				-- print("当前建筑在屏幕内")
			else
				-- print("当前建筑不在屏幕内")
				offestX=G_VisibleSize.width/2-screenPos.x
				offestY=G_VisibleSize.height/2-screenPos.y
			end
			mapScene.clayer:setPosition(ccp(mapX+offestX,mapY+offestY))
			mapScene:checkBound()
		end
	end
end

function buildingGuildMgr:showGuildArrow()
	if self.mapScene==nil or self.mapScene.sceneSp==nil or self.buildSp==nil then
		do return end
	end
 	local sceneSp=self.mapScene.sceneSp
	local buildSize=self.buildSp:getContentSize()
	local buildPosX=self.buildSp:getPositionX()
	local buildPosY=self.buildSp:getPositionY()
    local arrowPos=CCPointMake(buildPosX,buildPosY+buildSize.height/2+50)
	local arrowSp=CCSprite:createWithSpriteFrameName("GuideArow.png")
	arrowSp:setAnchorPoint(ccp(0.5,0))
	arrowSp:setPosition(arrowPos)
	sceneSp:addChild(arrowSp,100000)
	self.arrowSp=arrowSp

    local function clickAreaHandler()
    end
	local selectSp=LuaCCScale9Sprite:createWithSpriteFrameName("guide_res.png",CCRect(28,28,2,2),clickAreaHandler)
	selectSp:setContentSize(buildSize)
   	selectSp:setTouchPriority(-999)
   	selectSp:setIsSallow(false)
   	selectSp:setPosition(ccp(buildPosX,buildPosY))
   	sceneSp:addChild(selectSp,100000)
   	self.selectSp=selectSp

    local aimPos=ccp(arrowPos.x,arrowPos.y-50)
   	local mvTo=CCMoveTo:create(0.35,aimPos)
    local mvBack=CCMoveTo:create(0.35,arrowPos)
    local seq=CCSequence:createWithTwoActions(mvTo,mvBack)
    arrowSp:runAction(CCRepeatForever:create(seq))
end

function buildingGuildMgr:toNextStep()
	if(self.waitingForGuideTb[1])then
		table.remove(self.waitingForGuideTb,1)
	end
	self:closeGuild()
	self.isGuilding=false
end

function buildingGuildMgr:showGuildSmallDialog(buildData,callback)
	self.isGuildSmallOpen=true
	require "luascript/script/game/scene/gamedialog/buildingGuildSmallDialog"
	local sd=buildingGuildSmallDialog:new()
	sd:init("TaskHeaderBg.png",CCSizeMake(530,350),CCRect(20,20,10,10),getlocal("unlock_building"),buildData,3,callback)
end

function buildingGuildMgr:tick()
	if(newGuidMgr and newGuidMgr.isGuiding==true) or (otherGuideMgr and otherGuideMgr.isGuiding==true)then
		do return end
	end
	local sceneIdx=sceneController:getNextIndex()-1
	if mainUI:isVisible()==true and (sceneIdx==0 or sceneIdx==1) and self.isGuilding==false and self.isGuildSmallOpen==false and base.allShowedCommonDialog==0 and SizeOfTable(G_SmallDialogDialogTb)==0 then
		local stepId=self.waitingForGuideTb[1]
		if stepId then
			self:showGuild(stepId)
		end
	end
	if self.isGuilding==true and self.isGuildSmallOpen==false then
		if base.allShowedCommonDialog==0 and SizeOfTable(G_SmallDialogDialogTb)==0 then
		else
			self:toNextStep()
		end
	end
end

function buildingGuildMgr:clear()
	self:closeGuild()
	self.isGuilding=false --当前是否在引导
	self.isGuildSmallOpen=false
	self.waitingForGuideTb=nil
	self.hasInit=false
	-- base:removeFromNeedRefresh(self)
end