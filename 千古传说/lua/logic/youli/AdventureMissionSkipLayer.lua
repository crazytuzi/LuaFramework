--[[
******关卡-跳转*******
    -- by quanhuan
]]
local AdventureMissionSkipLayer = class("AdventureMissionSkipLayer", BaseLayer);

function AdventureMissionSkipLayer:ctor()
    self.super.ctor(self);
    self:init("lua.uiconfig_mango_new.youli.missComplete");
end

function AdventureMissionSkipLayer:loadData(mapid,difficulty)
    self.difficulty = difficulty
    self.mapid = mapid

    local map = AdventureMissionManager:getMapById(self.mapid);
    self.titleName:setText(map.name);

    --next info
    local nextMap = AdventureMissionManager:getMapById(self.mapid+1);
    if map and nextMap then
        self.nextNode:setVisible(true)
        self.nextInfo.txtName:setText(map.name1)
        self.nextInfo.txtDesc:setText(map.detail)
        self.nextInfo.imgMap:setVisible(false)
        self.nextInfo.imgRole:setTexture("icon/rolebig/" .. map.next_boss_img .. ".png")
    else
        self.nextNode:setVisible(false)
    end
    self.enableEffect = true
end

function AdventureMissionSkipLayer:initUI(ui)
    self.super.initUI(self,ui)

    local titleNode = TFDirector:getChildByPath(ui, 'img_wenzidi')
    self.titleName = TFDirector:getChildByPath(titleNode, 'txt_name')

    local nextNode = TFDirector:getChildByPath(ui, 'img_di2')
    self.nextNode = nextNode
    self.nextInfo = {}
    self.nextInfo.txtName = TFDirector:getChildByPath(nextNode, 'txt_name')
    self.nextInfo.imgMap = TFDirector:getChildByPath(nextNode, 'img_bg')
    self.nextInfo.txtDesc = TFDirector:getChildByPath(nextNode, 'txt_miaoshu')
    self.nextInfo.imgRole = TFDirector:getChildByPath(nextNode, 'img_role')
end

function AdventureMissionSkipLayer:removeUI()
    self.super.removeUI(self)
end

function AdventureMissionSkipLayer:dispose()  
    self.super.dispose(self)
end

function AdventureMissionSkipLayer:onShow()  
    self:refreshUI()

    if self.enableEffect then
        self.enableEffect = false
        self.ui:runAnimation("Action0",1)
        self.ui:setAnimationCallBack("Action0", TFANIMATION_END, function()
                local resPath = "effect/role_starup1.xml"
                TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
                effect = TFArmature:create("role_starup1_anim")
              
                effect:setAnimationFps(GameConfig.ANIM_FPS)
                effect:setPosition(ccp(self:getSize().width/2,self:getSize().height/2))
                self:addChild(effect,2)
                effect:playByIndex(0, -1, -1, 0)
                effect:addMEListener(TFARMATURE_COMPLETE,function()
                    effect:removeMEListener(TFARMATURE_COMPLETE) 
                    effect:removeFromParent()
                end)            
        end)
    end
end

function AdventureMissionSkipLayer:refreshUI()
end

--注册事件
function AdventureMissionSkipLayer:registerEvents()
    self.super.registerEvents(self)    
end

function AdventureMissionSkipLayer:removeEvents()
    self.super.removeEvents(self)
   
end

return AdventureMissionSkipLayer
