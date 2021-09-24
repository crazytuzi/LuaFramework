require "luascript/script/game/gamemodel/ltzdz/ltzdzReportVoApi"

ltzdzReportDetailDialog=commonDialog:new()

function ltzdzReportDetailDialog:new(reportVo)
    local nc={
    	reportVo=reportVo,
    	cellHeightTb={},
    	attackerFlag=false, --自己是否是攻击方
	}
    setmetatable(nc,self)
    self.__index=self

    return nc
end

function ltzdzReportDetailDialog:initTableView()
	spriteController:addPlist("public/reportyouhua.plist")
	spriteController:addTexture("public/reportyouhua.png")

    ltzdzVoApi:addOrRemoveOpenDialog(1,"ltzdzReportDetailDialog",self)
	self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-36))
	self.panelLineBg:setContentSize(CCSizeMake(620,G_VisibleSize.height-98))
	self.attackerFlag=ltzdzReportVoApi:isAttacker(self.reportVo)
	self.cellNum=self:getCellNum()

    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-180),nil)
    self.tv:setPosition(ccp(25,90))
	self.tv:setAnchorPoint(ccp(0,0))
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
	self.bgLayer:addChild(self.tv)
end

function ltzdzReportDetailDialog:eventHandler(handler,fn,idx,cel)
	if self.reportVo==nil then
		do return end
	end

	if fn=="numberOfCellsInTableView" then--rtype 1 战斗 2 运输
		return self.cellNum
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		local width,height=G_VisibleSize.width-50,0
		local showType=self:getShowType(idx+1)
		if showType==1 then --战力
			height=ltzdzReportVoApi:getBothStrengthReportHeight()
		elseif showType==2 then --飞机
			height=G_getPlaneReportHeight()
		elseif showType==3 then --军徽
			height=G_getEmblemReportHeight()
		elseif showType==4 then --将领
			height=G_getHeroReportHeight()
		elseif showType==5 then --配件
			height=G_getAccessoryReportHeight(self.reportVo,self.attackerFlag,width,self.cellHeightTb[idx+1])
		elseif showType==11 then --AI部队
			height=G_getAITroopsReportHeight()
		end
		self.cellHeightTb[idx+1]=height
		tmpSize=CCSizeMake(width,height)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local cellWidth=G_VisibleSize.width-50
		local cellHeight=self.cellHeightTb[idx+1]
		local showType=self:getShowType(idx+1)
		if showType==1 then --战力
			ltzdzReportVoApi:addBothStrengthReport(cell,self.reportVo,self.attackerFlag,cellWidth,cellHeight,self.layerNum)
		elseif showType==2 then --飞机
			G_addReportPlane(self.reportVo,cell,self.attackerFlag,cellHeight,self.layerNum)
		elseif showType==3 then --军徽
			G_addEmblemReport(self.reportVo,cell,self.attackerFlag,cellWidth,cellHeight,self.layerNum)
		elseif showType==4 then --将领
			G_addHeroReport(self.reportVo,cell,self.attackerFlag,cellWidth,cellHeight,self.layerNum)
		elseif showType==5 then --配件
			G_addAccessoryReport(self.reportVo,cell,self.attackerFlag,cellWidth,cellHeight,self.layerNum)
		elseif showType==11 then --AI部队
			G_addAITroopsReport(self.reportVo,cell,self.attackerFlag,cellWidth,cellHeight,self.layerNum)
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

function ltzdzReportDetailDialog:getCellNum()
	local cellNum=0
	if self.reportVo and self.reportVo.rtype==1 then
		local showTypeTb=self:getShowType()
		cellNum=SizeOfTable(showTypeTb)
	end
	return cellNum
end
--idx:1,2,3,4,5
--return:1.敌我双方战力，2.飞机，3.军徽，4.将领，5.配件,11.AI部队
function ltzdzReportDetailDialog:getShowType(idx)
	local showType=0
	local rtype=self.reportVo.rtype
	
	local isShowHero=emailVoApi:isShowHero(self.reportVo)
	local isShowAccessory=ltzdzReportVoApi:isShowAccessory(self.reportVo)
	local isShowEmblem=emailVoApi:isShowEmblem(self.reportVo)
	local isShowPlane=G_isShowPlaneInReport(self.reportVo,1)
	local showTypeTb={}
	if rtype==1 then
		table.insert(showTypeTb,1)
	end
	if(isShowPlane)then
		table.insert(showTypeTb,2)
	end
	if G_isShowAITroopsInReport(self.reportVo)==true then
		table.insert(showTypeTb,11)
	end
	if(isShowEmblem)then
		table.insert(showTypeTb,3)
	end
	if(isShowHero)then
		table.insert(showTypeTb,4)
	end
	if(isShowAccessory)then
		table.insert(showTypeTb,5)
	end
	if idx then
		return showTypeTb[idx]
	else
		return showTypeTb
	end
end

function ltzdzReportDetailDialog:dispose()
   	self.reportVo=nil
	self.cellHeightTb={}
	self.attackerFlag=false
    ltzdzVoApi:addOrRemoveOpenDialog(2,"ltzdzReportDetailDialog",self)
	spriteController:removePlist("public/reportyouhua.plist")
	spriteController:removeTexture("public/reportyouhua.png")
end