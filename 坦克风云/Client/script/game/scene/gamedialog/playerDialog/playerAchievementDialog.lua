--成就系统的总览面板
playerAchievementDialog=commonDialog:new()

function playerAchievementDialog:new()
	local nc={
        avtLayer=nil,
	}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function playerAchievementDialog:initTableView()
    self.panelLineBg:setVisible(false)
    local panelBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelBgShade.png",CCRect(30,0,2,3),function ()end)
    panelBg:setAnchorPoint(ccp(0.5,0))
    panelBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-85))
    panelBg:setPosition(G_VisibleSizeWidth/2,5)
    self.bgLayer:addChild(panelBg)

    G_requireLua("game/scene/gamedialog/playerDialog/achievementLayer")
    self.avtLayer=achievementLayer:new()
    local detailLayer=self.avtLayer:initLayer(self.layerNum+1)
    detailLayer:setPosition(0,0)
    self.bgLayer:addChild(detailLayer)
end

function playerAchievementDialog:dispose()
    if self.avtLayer and self.avtLayer.dispose then
        self.avtLayer:dispose()
        self.avtLayer=nil
    end
end