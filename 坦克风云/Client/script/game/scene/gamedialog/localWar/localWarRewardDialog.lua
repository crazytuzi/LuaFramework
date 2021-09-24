localWarRewardDialog=commonDialog:new()

function localWarRewardDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

    self.tab=nil
    self.layerTab=nil

	return nc
end

function localWarRewardDialog:initTableView()
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
    self.panelLineBg:setContentSize(CCSizeMake(600,G_VisibleSize.height-100))

    require "luascript/script/game/scene/gamedialog/localWar/localWarDetailDialogTab2"
    self.tab=localWarDetailDialogTab2:new()
    self.layerTab=self.tab:init(self.layerNum,self,80)
    self.bgLayer:addChild(self.layerTab)

	return self.bgLayer
end

function localWarRewardDialog:tick()
end

function localWarRewardDialog:dispose()
    if self.tab then
        self.tab:dispose()
    end
    self.tab=nil
    self.layerTab=nil
end