--展示奖励 改成scroll

local TreasureResult = class("TreasureResult",BaseLayer)

function TreasureResult:ctor(data)
	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.treasure.TreasureNewResult")
end

function TreasureResult:initUI( ui )
	self.super.initUI(self,ui)
    self.tenBgImg = TFDirector:getChildByPath(ui, 'tenBgImg')
    self.scroll_view 			= TFDirector:getChildByPath(ui, 'scroll_view')
    self.panel_content 			= TFDirector:getChildByPath(ui, 'panel_content')
end

function TreasureResult:loadData(data)
	self.rewardList = data
	print(data)
	self.count = #self.rewardList

	if self.count <= 10 then
		self.scroll_view:setInnerContainerSize(CCSizeMake(710, 365))
		self.panel_content:setPosition(ccp(0, 365))
	end	

	local timerID = TFDirector:addTimer(150, 1, nil, 
	function() 
		TFDirector:removeTimer(timerID)
		self.roleIndex = 1
		self:OnIconShowEnd()
	end)
end


function TreasureResult:OnIconShowEnd()
	if self.roleIndex > #self.rewardList then
		self.getCardCompelete = true
	else
		local reward = self.rewardList[self.roleIndex]
		local roleTypeId = self.rewardList[self.roleIndex].resId
		if self.rewardList[self.roleIndex].resType == EnumDropType.ROLE then
			local newCardRoleData = RoleData:objectByID(roleTypeId)
			if newCardRoleData ~= nil then
				if newCardRoleData.quality >= QUALITY_JIA then
					play_wanlijiajichuxian()
					
             		local layer = require("lua.logic.treasure.TreasureHero"):new({reward.resId,self.roleIndex})
                	layer:setParent(self)
             		AlertManager:addLayer(layer, AlertManager.BLOCK)
             		AlertManager:show()        		
				else
					self:ShowRoleIcon(self.roleIndex)
				end
			end
		else
			--local newCardRoleData = ItemData:objectByID(roleTypeId)
			--if newCardRoleData ~= nil then
				self:ShowRoleIcon(self.roleIndex)
			--end
		end
	end
end

function TreasureResult:ShowRoleIcon(roleIndex)
	--self.tenBgImg:setVisible(true)
	
	self.roleIndex = self.roleIndex + 1 
	
	local row = math.floor( roleIndex / 5 )
    local mod = math.fmod( roleIndex,5 )
    if mod == 0 then
        row = row - 1
    end 
    row = row + 1
    local posX = math.fmod(roleIndex - 1,5) * 140 + 75	
	local posY = row * -140 + 70
	-------------
	local scroll_pos = self.scroll_view:getContentOffset()
	print("scroll_pos-----------------------")
	print(scroll_pos)

	local contentY =-475 + (row - 2) * 140
	local pos ={x = 0, y = contentY }
	if row > 2 then		
		if self.currRow ~= row then
			self.currRow = row
			self.scroll_view:setContentOffset(pos,0.2)
		end	
	end	

	local item = self.rewardList[roleIndex]
    local roleTypeId = item.resId
    local newCardRoleData = nil
    local path = nil
    if item.resType == EnumDropType.ROLE then
        newCardRoleData = RoleData:objectByID(roleTypeId)
        if newCardRoleData == nil then
          --  print('roleTypeId = ', roleTypeId)
        end
        path = newCardRoleData:getIconPath()
    else
        local data = {}
        data.type   = item.resType
        data.itemId = item.resId
        data.number = item.number

        newCardRoleData = BaseDataManager:getReward(data)
        path = newCardRoleData.path
    end

    if newCardRoleData ~= nil then
        local roleQualityImg = TFImage:create()
        roleQualityImg:setTexture(GetColorIconByQuality(newCardRoleData.quality))
        --roleQualityImg:setAnchorPoint(ccp(1, 0))
        roleQualityImg:setPosition(ccp(posX, posY))
        roleQualityImg:setScale(1)
        roleQualityImg:setOpacity(0)
        self.panel_content:addChild(roleQualityImg,100)

        local roleIcon = TFImage:create()
        roleQualityImg:addChild(roleIcon)
        roleIcon:setTexture(path)
        roleIcon:setTouchEnabled(true)
        roleIcon:addMEListener(TFWIDGET_CLICK,
        audioClickfun(function()
            Public:ShowItemTipLayer(roleTypeId, item.resType)
        end))

        if item.resType == EnumDropType.GOODS then
            newCardRoleData = ItemData:objectByID(roleTypeId)          
            newCardRoleData.itemid = newCardRoleData.id
            if newCardRoleData.type == EnumGameItemType.Soul and newCardRoleData.kind ~= 3 then
                Public:addPieceImg(roleIcon,newCardRoleData,true)
            elseif newCardRoleData.type == EnumGameItemType.Piece then
                Public:addPieceImg(roleIcon,newCardRoleData,true)
            else
                Public:addPieceImg(roleIcon,newCardRoleData,false)
            end
        end
        local txt_num = TFLabelBMFont:create()
        txt_num:setFntFile("font/num_212.fnt")

        txt_num:setAnchorPoint(ccp(1, 0))
        txt_num:setPosition(ccp(52, -60))
        txt_num:setText(item.number)
        -- txt_num:setFontSize(20)
        roleQualityImg:addChild(txt_num)

		local roleTween = 
		{
			target = roleQualityImg,
			{
				duration = 0.1,
				alpha = 255,
				scale = 1 ,
			},

			onComplete = function ()
				self:OnIconShowEnd()
			end
		}
		TFDirector:toTween(roleTween)
	end
end


function TreasureResult:removeUI()
   	self.super.removeUI(self)  
end

function TreasureResult:onShow()
    self.super.onShow(self)
end

function TreasureResult:registerEvents()
	self.super.registerEvents(self)
    
end

function TreasureResult:removeEvents()
	self.super.removeEvents(self)
end


function TreasureResult:dispose()
    self.super.dispose(self)
end

return TreasureResult