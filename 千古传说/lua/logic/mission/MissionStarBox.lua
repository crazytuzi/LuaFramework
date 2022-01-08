--[[
******关卡-宝箱*******
    -- by quanhuan
]]
local MissionStarBox = class("MissionStarBox", BaseLayer);

CREATE_SCENE_FUN(MissionStarBox);
CREATE_PANEL_FUN(MissionStarBox);

function MissionStarBox:ctor()
    self.super.ctor(self);
    self:init("lua.uiconfig_mango_new.mission.Star_box");
end

function MissionStarBox:loadData(mapid,difficulty)
    self.difficulty = difficulty
    self.mapid = mapid

    self.boxList = MissionManager:getBoxListByMapId(mapid,difficulty)  

    self:refreshBoxList()
end

function MissionStarBox:initUI(ui)
    self.super.initUI(self,ui)

    self.Panel_star_box = TFDirector:getChildByPath(ui, 'penel_block')
    self.star_box_di = TFDirector:getChildByPath(ui, 'star_box_di')
    self.star_box_di:setDirection(TFLOADINGBAR_LEFT)
    self.star_box_di:setPercent(0)
    self.star_box_di:setVisible(true)

    self.BtnBoxArr = {}
    for i=1,3 do
        self.BtnBoxArr[i] = TFDirector:getChildByPath(ui, 'Button_star_box'..i)
        self.BtnBoxArr[i].txt = TFDirector:getChildByPath(ui, 'Label_star_box'..i)
        self.BtnBoxArr[i].index = i
        self.BtnBoxArr[i].logic = self
    end
end

function MissionStarBox:removeUI()
    self.super.removeUI(self)
end

function MissionStarBox:dispose()  
    self.super.dispose(self)
end

function MissionStarBox:onShow()  
    
end

function MissionStarBox:refreshUI()

end

function MissionStarBox:onShow()
    self.super.onShow(self)
end


--注册事件
function MissionStarBox:callRegisterEvents()    
    self.super.registerEvents(self)
    for i=1,3 do
        self.BtnBoxArr[i]:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onOpenBoxClickHandle),1);
    end

    self.updateBoxCallBack = function(event)
        self:refreshBoxList()
    end;
    TFDirector:addMEGlobalListener(MissionManager.EVENT_UPDATE_BOX ,self.updateBoxCallBack )
end

function MissionStarBox:callRemoveEvents()
    self.super.removeEvents(self)
    for i=1,3 do
        self.BtnBoxArr[i]:removeMEListener(TFWIDGET_CLICK)
    end

    TFDirector:removeMEGlobalListener(MissionManager.EVENT_UPDATE_BOX ,self.updateBoxCallBack )
    self.updateBoxCallBack = nil
end

function MissionStarBox:refreshBoxList()

    local curStar = MissionManager:getStarlevelCount(self.mapid,self.difficulty)
    local maxStar = MissionManager:getMaxStarlevelCount(self.mapid,self.difficulty)

    self.star_box_di:setPercent(math.floor(curStar*100/maxStar))

    for i=1,3 do
        local boxInfo = self.boxList[i]
        self.BtnBoxArr[i]:setVisible(false)

        if boxInfo then
             if self.BtnBoxArr[i].effect then
                self.BtnBoxArr[i].effect:removeFromParent()
                self.BtnBoxArr[i].effect = nil
            end

            if MissionManager:isAlreadyOpenByBoxId(boxInfo.id, self.difficulty) then
                self.BtnBoxArr[i]:setTextureNormal("ui_new/mission/icon_pass2.png");
                self.BtnBoxArr[i].txt:setVisible(false)               
            else
                self.BtnBoxArr[i].txt:setVisible(true)
                self.BtnBoxArr[i]:setTextureNormal("ui_new/mission/icon_pass.png");
                if curStar >= boxInfo.need_star then

                    local resPath = "effect/ui/northClimbBox.xml"
                    TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
                    local effect = TFArmature:create("northClimbBox_anim")
                    effect:setAnimationFps(GameConfig.ANIM_FPS)
                    -- effect:setPosition(ccp(0, 10))
                    self.BtnBoxArr[i]:addChild(effect,100)
                    effect:playByIndex(0, -1, -1, 1)
                    -- effect:setScale(0.65)
                    self.BtnBoxArr[i].effect = effect
                end
            end
            self.BtnBoxArr[i].txt:setString(boxInfo.need_star)
            self.BtnBoxArr[i]:setVisible(true)
        end
    end
end

function MissionStarBox.onOpenBoxClickHandle( sender )
    local self = sender.logic
    local btnIndex = sender.index
    local boxInfo = self.boxList[btnIndex]

    self:loadData(self.mapid,self.difficulty)
    if MissionManager:isAlreadyOpenByBoxId(boxInfo.id, self.difficulty) then
       --toastMessage("你已经领取了该宝箱")
       toastMessage(localizable.common_get_box)
       return
   end

    local curStar = MissionManager:getStarlevelCount(self.mapid,self.difficulty)

    if curStar < boxInfo.need_star then
    --if true then
        --预览宝箱    
        local calculateRewardList = self:calculateReward(boxInfo.reward_id)
        local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.mission.StarBoxPanel",AlertManager.BLOCK_AND_GRAY_CLOSE,AlertManager.TWEEN_1);        
        layer:loadData(calculateRewardList, boxInfo.need_star);
        AlertManager:show();       
    else
        --打开宝箱
        MissionManager:openBox(boxInfo.id);
    end
end


function MissionStarBox:calculateReward(rewardid)

    local calculateRewardList = TFArray:new();
    local rewardConfigure = RewardConfigureData:objectByID(rewardid)
    local rewardItems = rewardConfigure:getReward()


    for k,v in pairs(rewardItems.m_list) do
        local rewardInfo = {}
        rewardInfo.type = v.type
        rewardInfo.itemId = v.itemid
        rewardInfo.number = v.number
        local _rewardInfo = BaseDataManager:getReward(rewardInfo)
        calculateRewardList:push(_rewardInfo);
    end

    return calculateRewardList
end

return MissionStarBox

