--[[
******帮派战-预选界面*******

	-- by quanhuan
	-- 2016/2/22
	
]]
local FightResultLayer = class("FightResultLayer")

function FightResultLayer:ctor(data, layer)

    self.ui = data
    self.parentLayer = layer
    self:initUI(data)
end

function FightResultLayer:initUI( ui )

    self.myRank = TFDirector:getChildByPath(ui, "txt_shunxu")
    self.myFlagFrame = TFDirector:getChildByPath(ui, "img_qizhimy")
    self.myFlagIcon = TFDirector:getChildByPath(self.myFlagFrame, "img_biaozhi")
    self.myJionFlag = TFDirector:getChildByPath(ui, "txt_weicanyu")

    local winnerNode = TFDirector:getChildByPath(ui, 'bg_gameover')
    self.img_bgNode = TFDirector:getChildByPath(winnerNode,"img_bg")
    self.winnerFlagFrame = TFDirector:getChildByPath(winnerNode, 'img_qizhi')
    self.winnerFlagIcon = TFDirector:getChildByPath(winnerNode, 'img_biaozhi')
    self.winnerName = TFDirector:getChildByPath(winnerNode, 'txt_name')
end


function FightResultLayer:removeUI()
    
end

function FightResultLayer:registerEvents()

    if self.registerEventCallFlag then
        return
    end

    self.winnerInfoUpdateCallBack = function (event)
        self:showDetailsInfo() 
    end
    TFDirector:addMEGlobalListener(FactionFightManager.winnerInfoUpdate, self.winnerInfoUpdateCallBack)

    self.registerEventCallFlag = true 
end

function FightResultLayer:removeEvents()
    self.registerEventCallFlag = nil  
    if self.winnerInfoUpdateCallBack then
        TFDirector:removeMEGlobalListener(FactionFightManager.winnerInfoUpdate, self.winnerInfoUpdateCallBack)    
        self.winnerInfoUpdateCallBack = nil
    end    
end

function FightResultLayer:dispose()

end

function FightResultLayer:setVisible(v)
    self.ui:setVisible(v)

    if v then
        self:registerEvents()
        FactionFightManager:requestWinnerResult()
    else
        self:removeEvents()        
    end
end

function FightResultLayer:showDetailsInfo()

    local winnerData = FactionFightManager:getWinnerInfo()
    print('FactionManager:getFactionInfo = ',FactionManager:getFactionInfo())
    print('winnerData = ',winnerData)
    self.myFlagFrame:setTexture(FactionManager:getMyBannerBgPath())
    self.myFlagIcon:setTexture(FactionManager:getMyBannerIconPath())
    if winnerData.myRank ~= 0 then
        self.myJionFlag:setVisible(false)
        self.myRank:setVisible(true)
        self.myRank:setText(winnerData.myRank)
    else
        self.myJionFlag:setVisible(true)
        self.myRank:setVisible(false)
    end
    
    self.winnerFlagFrame:setTexture(FactionManager:getGuildBannerBgPath(winnerData.bannerId))
    self.winnerFlagIcon:setTexture(FactionManager:getGuildBannerIconPath(winnerData.bannerId))
    self.winnerName:setText(winnerData.guildName)

    local resPath = "effect/ui/level_up_light.xml"
    TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
    local effect = TFArmature:create("level_up_light_anim")
    effect:setAnimationFps(GameConfig.ANIM_FPS)
    effect:setPosition(ccp(self.img_bgNode:getContentSize().width/2,self.img_bgNode:getContentSize().height/2))
    effect:playByIndex(0, -1, -1, 1)
    effect:setScale(0.4)
    effect:setVisible(true)
    self.img_bgNode:addChild(effect,98)

end

return FightResultLayer