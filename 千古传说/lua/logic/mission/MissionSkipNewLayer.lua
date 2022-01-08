--[[
******关卡-跳转*******
    -- by quanhuan
]]
local MissionSkipNewLayer = class("MissionSkipNewLayer", BaseLayer);

function MissionSkipNewLayer:ctor()
    self.super.ctor(self);
    self:init("lua.uiconfig_mango_new.mission.Skip");
end

function MissionSkipNewLayer:loadData(mapid,difficulty)
    self.difficulty = difficulty
    self.mapid = mapid

    local map = MissionManager:getMapById(self.mapid);
    self.titleName:setText(map.name);

    local curStar = MissionManager:getStarlevelCount(self.mapid,self.difficulty);
    local maxStar = MissionManager:getMaxStarlevelCount(self.mapid,self.difficulty);
    -- self.Txt_num:setString(curStar.."/"..maxStar)

    if curStar >= maxStar then
        --只显示一个 继续闯关的 按钮
        self.Btn_getstar:setVisible(false)
        self.Btn_getstar:setTouchEnabled(false)
    else
        self.Btn_getstar:setVisible(true)
        self.Btn_getstar:setTouchEnabled(true)
    end

    --next info
    local nextMap = MissionManager:getMapById(self.mapid+1);
    if map and nextMap then
        self.nextNode:setVisible(true)
        self.nextInfo.txtName:setText(map.name1)
        self.nextInfo.txtDesc:setText(map.detail)
        self.nextInfo.imgMap:setTexture("bg_jpg/" .. map.next_map_img .. ".jpg")
        -- self.nextInfo.imgRole:setTexture("icon/rolebig/" .. map.next_boss_img .. ".png")
        ModelManager:addResourceFromFile(1, map.next_boss_img, 1)
        local armature = ModelManager:createResource(1, map.next_boss_img)
        self.nextInfo.panelRole:addChild(armature)
        ModelManager:playWithNameAndIndex(armature, "stand", -1, 1, -1, -1)
        armature:setRotationY(180)
        armature:setScale(1.2)
    else
        self.nextNode:setVisible(false)
    end
    self:refreshBoxList()

    self.enableEffect = true

end

function MissionSkipNewLayer:setBtnHandle(goonhandle, getstarhandle)

    if self.Btn_getstar then
        self.Btn_getstar.logic       = self
        self.Btn_getstar:addMEListener(TFWIDGET_CLICK,audioClickfun(function()
            print('okokokokokok')
            AlertManager:close(AlertManager.TWEEN_NONE)
            getstarhandle()                    
        end),1)
    end

    if self.Btn_goon then
        self.Btn_goon.logic   = self   
        self.Btn_goon:addMEListener(TFWIDGET_CLICK, audioClickfun(function()
            print('nononono')
            AlertManager:close(AlertManager.TWEEN_NONE)  
            goonhandle()                      
        end),1)
    end

end

function MissionSkipNewLayer:initUI(ui)
    self.super.initUI(self,ui)

    local titleNode = TFDirector:getChildByPath(ui, 'img_wenzidi')
    self.titleName = TFDirector:getChildByPath(titleNode, 'txt_name')

    local nextNode = TFDirector:getChildByPath(ui, 'img_di2')
    self.nextNode = nextNode
    self.nextInfo = {}
    self.nextInfo.txtName = TFDirector:getChildByPath(nextNode, 'txt_name')
    self.nextInfo.imgMap = TFDirector:getChildByPath(nextNode, 'img_bg')
    self.nextInfo.txtDesc = TFDirector:getChildByPath(nextNode, 'txt_miaoshu')
    -- self.nextInfo.imgRole = TFDirector:getChildByPath(nextNode, 'img_role')
    self.nextInfo.panelRole = TFDirector:getChildByPath(nextNode, 'panel_role')

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

    self.Btn_getstar = TFDirector:getChildByPath(ui, 'Btn_getstar')
    self.Btn_goon = TFDirector:getChildByPath(ui, 'Btn_goon')
    -- self.Txt_num = TFDirector:getChildByPath(ui, 'Txt_num')

end

function MissionSkipNewLayer:removeUI()
    self.super.removeUI(self)
end

function MissionSkipNewLayer:dispose()  
    self.super.dispose(self)
end

function MissionSkipNewLayer:onShow()  
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

function MissionSkipNewLayer:refreshUI()

    -- if self.enableUi then
    --     if self.mapBoxView then
    --         self.mapBoxView:loadData(self.mapid,self.difficulty)
    --     end
    --     --self.Img_back:setVisible(true)
    --     self.Txt_title:setVisible(true)
    --     self.Txt_content:setVisible(true)
    --     self.Txt_num:setVisible(true)
    --     self.panelBoxView:setVisible(true)
    --     self.Btn_goon:setVisible(true)
    --     --map name
    --     local map = MissionManager:getMapById(self.mapid);
    --     self.Txt_title:setText(map.name);

    --     --current star
    --     local curStar = MissionManager:getStarlevelCount(self.mapid,self.difficulty);
    --     local maxStar = MissionManager:getMaxStarlevelCount(self.mapid,self.difficulty);
    --     self.Txt_num:setString(curStar.."/"..maxStar)
      
    --     --content
    --     if self.stringBuff == nil then
    --          self.stringBuff = ""
    --          local stringIndex = 1
    --          self.stringBuffTimeId = TFDirector:addTimer(66, -1, nil, 
    --             function() 
    --                 local c = string.sub(map.detail,stringIndex,stringIndex)
    --                 b = string.byte(c)
    --                 if b > 128 then
    --                     self.stringBuff = self.stringBuff..string.sub(map.detail,stringIndex,stringIndex+2)
    --                     stringIndex = stringIndex + 3
    --                 else
    --                     self.stringBuff = self.stringBuff..c
    --                     stringIndex = stringIndex + 1
    --                 end

    --                 if stringIndex >= #map.detail then
    --                     if self.stringBuffTimeId then
    --                         TFDirector:removeTimer(self.stringBuffTimeId)
    --                         self.stringBuffTimeId = nil
    --                     end
    --                 end
    --                 self.Txt_content:setString(self.stringBuff)
    --             end)
    --     else
    --         self.Txt_content:setString(self.stringBuff)
    --     end
       
        

    --     if curStar >= maxStar then
    --         --只显示一个 继续闯关的 按钮
    --         self.Btn_getstar:setVisible(false)
    --         self.Btn_getstar:setTouchEnabled(false)
    --     else
    --         self.Btn_getstar:setVisible(true)
    --         self.Btn_getstar:setTouchEnabled(true)
    --     end
    -- end
end

--注册事件
function MissionSkipNewLayer:registerEvents()
    self.super.registerEvents(self)

    for i=1,3 do
        self.BtnBoxArr[i]:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onOpenBoxClickHandle),1);
    end

    self.updateBoxCallBack = function(event)
        self:refreshBoxList()
    end;
    TFDirector:addMEGlobalListener(MissionManager.EVENT_UPDATE_BOX ,self.updateBoxCallBack )
end

function MissionSkipNewLayer:removeEvents()
    self.super.removeEvents(self)

    self.Btn_getstar:removeMEListener(TFWIDGET_CLICK)
    self.Btn_goon:removeMEListener(TFWIDGET_CLICK)

    for i=1,3 do
        self.BtnBoxArr[i]:removeMEListener(TFWIDGET_CLICK)
    end

    TFDirector:removeMEGlobalListener(MissionManager.EVENT_UPDATE_BOX ,self.updateBoxCallBack )
    self.updateBoxCallBack = nil 
end

function MissionSkipNewLayer:refreshBoxList()

    local curStar = MissionManager:getStarlevelCount(self.mapid,self.difficulty)
    local maxStar = MissionManager:getMaxStarlevelCount(self.mapid,self.difficulty)
    self.boxList = MissionManager:getBoxListByMapId(self.mapid,self.difficulty)
    self.star_box_di:setPercent(math.floor(curStar*100/maxStar))

    for i=1,3 do
        local boxInfo = self.boxList[i]
        self.BtnBoxArr[i]:setVisible(false)

        if boxInfo then
             if self.BtnBoxArr[i].effect then
                self.BtnBoxArr[i].effect:removeFromParent()
                self.BtnBoxArr[i].effect = nil
            end

            self.BtnBoxArr[i]:setScale(1)
            if MissionManager:isAlreadyOpenByBoxId(boxInfo.id, self.difficulty) then
                self.BtnBoxArr[i]:setTextureNormal("ui_new/mission/icon_pass3.png");
                self.BtnBoxArr[i]:setScale(0.7)
                self.BtnBoxArr[i].txt:setVisible(false)               
            else
                self.BtnBoxArr[i].txt:setVisible(true)
                self.BtnBoxArr[i]:setTextureNormal("ui_new/mission/icon_pass4.png");
                if curStar >= boxInfo.need_star then
                    local resPath = "effect/ui/northClimbBox.xml"
                    TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
                    local effect = TFArmature:create("northClimbBox_anim")
                    effect:setAnimationFps(GameConfig.ANIM_FPS)
                    effect:setPosition(ccp(-5, 11))
                    self.BtnBoxArr[i]:addChild(effect,100)
                    effect:playByIndex(0, -1, -1, 1)
                    effect:setScale(0.7)
                    self.BtnBoxArr[i].effect = effect
                end
            end
            if curStar >= boxInfo.need_star then
                self.BtnBoxArr[i].txt:setString(boxInfo.need_star..'/'..boxInfo.need_star)
            else
                self.BtnBoxArr[i].txt:setString(curStar..'/'..boxInfo.need_star)
            end            
            self.BtnBoxArr[i]:setVisible(true)
        end
    end
end


function MissionSkipNewLayer.onOpenBoxClickHandle( sender )
    local self = sender.logic
    local btnIndex = sender.index
    local boxInfo = self.boxList[btnIndex]

    --self:loadData(self.mapid,self.difficulty)
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


function MissionSkipNewLayer:calculateReward(rewardid)

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
return MissionSkipNewLayer
