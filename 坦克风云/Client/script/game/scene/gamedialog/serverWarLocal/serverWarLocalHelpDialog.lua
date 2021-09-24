require "luascript/script/game/scene/gamedialog/serverWarLocal/serverWarLocalDialogTab2"
serverWarLocalHelpDialog=commonDialog:new()

function serverWarLocalHelpDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function serverWarLocalHelpDialog:initTableView()
    self.panelLineBg:setVisible(false)
    -- self.panelLineBg:setAnchorPoint(ccp(0.5,0))
    -- self.panelLineBg:setContentSize(CCSizeMake(600,G_VisibleSize.height-100))
    -- self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2,20))

    local tab=serverWarLocalDialogTab2:new(true)
    local layerTab=tab:init(self.layerNum,self)
    self.bgLayer:addChild(layerTab)

    G_addCommonGradient(self.bgLayer,G_VisibleSizeHeight-80)
end

function serverWarLocalHelpDialog:dispose()

end
