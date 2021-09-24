local believerRewardDialog=commonDialog:new()

function believerRewardDialog:new(parent)
	local nc={
        parent=parent,
    }
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function believerRewardDialog:resetTab()
    if self.panelLineBg then
        self.panelLineBg:setVisible(false)
    end
    if self.panelTopLine then
        self.panelTopLine:setVisible(true)
        self.panelTopLine:setPositionY(G_VisibleSizeHeight-158) 
    end
    local index=0
    for k,v in pairs(self.allTabs) do
        local  tabBtnItem=v
		if index==0 then
			tabBtnItem:setPosition(119,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
		elseif index==1 then
			tabBtnItem:setPosition(320,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
		elseif index==2 then
			tabBtnItem:setPosition(521,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
		end
		if index==self.selectedTabIndex then
	     	tabBtnItem:setEnabled(false)
		end
		index=index+1
    end
    self.selectedTabIndex=0
    self:tabClick(0)
end

function believerRewardDialog:tabClick(idx)
    if self.rewardTab==nil then
        self.rewardTab={}
        self.rewardLayer={}
    end
    if self.rewardTab[idx+1]==nil then
        local tab,layer=nil,nil
        if idx==0 then
            local believerDailyRewardTab=G_requireLua("game/scene/gamedialog/believer/believerDailyRewardTab")
            tab=believerDailyRewardTab:new()
        elseif idx==1 then
            local believerPromptedRewardTab=G_requireLua("game/scene/gamedialog/believer/believerPromptedRewardTab")
            tab=believerPromptedRewardTab:new()
        elseif idx==2 then
            local believerSeasonRewardTab=G_requireLua("game/scene/gamedialog/believer/believerSeasonRewardTab")
            tab=believerSeasonRewardTab:new()
        end
        if tab then
            layer=tab:init(self.layerNum,self)
            self.bgLayer:addChild(layer,10)
            self.rewardTab[idx+1]=tab
            self.rewardLayer[idx+1]=layer
        end
    end
    for k,v in pairs(self.allTabs) do
        local tag=v:getTag()
        if tag==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
            if self.rewardLayer[tag+1] then
                self.rewardLayer[tag+1]:setPosition(0,0)
                self.rewardLayer[tag+1]:setVisible(true)
            end
        else
            v:setEnabled(true)
            if self.rewardLayer[tag+1] then
                self.rewardLayer[tag+1]:setPosition(999333,0)
                self.rewardLayer[tag+1]:setVisible(false)
            end
        end
    end
end

function believerRewardDialog:doUserHandler()
	
end

function believerRewardDialog:initTableView()
    for i=1,3 do
        self:refreshRedTip(i)
    end
end

function believerRewardDialog:tick()

end

--刷新奖励可领取的红点
function believerRewardDialog:refreshRedTip(idx)
    local canNum=believerVoApi:getCanRewardByType(idx)
    if canNum>0 then
        self:setTipsVisibleByIdx(true,idx,canNum)
    else
        self:setTipsVisibleByIdx(false,idx)
    end
end

function believerRewardDialog:dispose()
    if self.rewardTab then
        for k,tab in pairs(self.rewardTab) do
            if tab and tab.dispose then
                tab:dispose()
            end
        end
    end
    self.rewardTab=nil
    self.rewardLayer=nil
    if self.parent and self.parent.backToMainDialogHandler then
        self.parent:backToMainDialogHandler()
        self.parent=nil
    end
end

return believerRewardDialog