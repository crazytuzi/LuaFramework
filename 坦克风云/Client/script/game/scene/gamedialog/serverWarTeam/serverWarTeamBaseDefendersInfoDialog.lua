serverWarTeamBaseDefendersInfoDialog=commonDialog:new()

function serverWarTeamBaseDefendersInfoDialog:new(fleetInfo)
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.fleetInfo=fleetInfo

	return nc
end

function serverWarTeamBaseDefendersInfoDialog:initTableView()
	self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-30))
    self.panelLineBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,G_VisibleSize.height-105))

    local function callBack(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width,self.bgLayer:getContentSize().height),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    -- self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20)
    -- self.tv:setPosition(ccp(30,30))
    -- self.bgLayer:addChild(self.tv)
    -- self.tv:setVisible(false)
    -- self.tv:setMaxDisToBottomOrTop(120)

    self:initTabLayer()
end

function serverWarTeamBaseDefendersInfoDialog:initTabLayer()
	local sizeLb=G_VisibleSizeHeight-220
	if self.fleetInfo then
		-- local shipTab=FormatItem(self.fleetInfo)
		local shipTab=self.fleetInfo
		for k,v in pairs(shipTab) do
		-- end
		-- if shipTab then
		-- 	for k=1,6 do
				--local width = 80+((k-1)%2)*280
				--local height = sizeLb-(math.floor((k+1)/2))*220
				local width = self.bgLayer:getContentSize().width-(math.ceil(k/3))*280+25

				local height = sizeLb-(((k-1)%3)*250+60)
				if G_isIphone5() then
					height = sizeLb-(((k-1)%3)*320+60)
				end

				local function touchClick(hd,fn,idx)
				end
				local bgSp =LuaCCScale9Sprite:createWithSpriteFrameName("BgEmptyTank.png",CCRect(10, 10, 20, 20),touchClick)
				bgSp:setContentSize(CCSizeMake(150, 150))
				bgSp:ignoreAnchorPointForPosition(false)
				bgSp:setAnchorPoint(ccp(0,0))
				bgSp:setIsSallow(false)
				bgSp:setTouchPriority(-(self.layerNum-1)*20-2)
				bgSp:setPosition(ccp(width,height))
				self.bgLayer:addChild(bgSp,1)
				
				local txtSize=25
				if v and v[1] and v[2] then
					local name,pic,desc,id,noUseIdx,eType,equipId=getItem(v[1],"o")
					local num=tonumber(v[2]) or 0
					if pic and name and num then
						local icon = CCSprite:createWithSpriteFrameName(pic)
						icon:setPosition(getCenterPoint(bgSp))
						bgSp:addChild(icon,2)
						
						local str=name.."("..num..")"
						-- str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
						local descLable = GetTTFLabelWrap(str,txtSize,CCSizeMake(280,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
				        descLable:setAnchorPoint(ccp(0.5,1))
						descLable:setPosition(ccp(width+bgSp:getContentSize().width/2,height-5))
						self.bgLayer:addChild(descLable,2)
					end
				end
			-- end
		end
	end
end


function serverWarTeamBaseDefendersInfoDialog:dispose()
	self.fleetInfo=nil
end

