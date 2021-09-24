--玩家信息面板的第二个页签，技能页签
playerDialogTab2={}

function playerDialogTab2:new(parent)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    nc.parent=parent
    nc.skillTab=nil
    return nc;
end

function playerDialogTab2:init(layerNum,isGuide)
    if(base.nbSkillOpen==1)then
        require "luascript/script/game/scene/gamedialog/playerDialog/playerDialogTabSkillNB"
        self.skillTab=playerDialogTabSkillNB:new(self.parent)
    else
        require "luascript/script/game/scene/gamedialog/playerDialog/playerDialogTabSkillOld"
        self.skillTab=playerDialogTabSkillOld:new(self.parent)
    end
    return self.skillTab:init(layerNum,isGuide)
end

function playerDialogTab2:tick()
    self.skillTab:tick()
end

function playerDialogTab2:removeGuied()
    if(self.skillTab and self.skillTab.removeGuied)then
        self.skillTab:removeGuied()
    end
end

function playerDialogTab2:recordPoint()
    if(self.skillTab and self.skillTab.recordPoint)then
        self.skillTab:recordPoint()
    end
end

function playerDialogTab2:dispose()
    if(self and self.skillTab and self.skillTab.dispose)then
        self.skillTab:dispose()
    end
    self.parent=nil
    self.skillTab=nil
end
