--[[
******无量山-万能副本*******

    -- by haidong.gan
    -- 2013/12/27
]]
local ClimbCarbonListLayer = class("ClimbCarbonListLayer", BaseLayer);

ClimbCarbonListLayer.LIST_ITEM_HEIGHT = 640; 

CREATE_SCENE_FUN(ClimbCarbonListLayer);
CREATE_PANEL_FUN(ClimbCarbonListLayer);

function ClimbCarbonListLayer:ctor(mountainItem)
    self.super.ctor(self,mountainItem);

    self:init("lua.uiconfig_mango_new.climb.ClimbMountainSoul");
end

function ClimbCarbonListLayer:initUI(ui)
  	self.super.initUI(self,ui);

    self.img_reward           = TFDirector:getChildByPath(ui, 'img_reward')
    self.txt_number           = TFDirector:getChildByPath(ui, 'txt_number')

    self.generalHead = CommonManager:addGeneralHead( self )

    self.generalHead:setData(ModuleType.Climb_Soul,{HeadResType.COIN,HeadResType.SYCEE})

    self.carbonNode = {};
    for i=1,3 do

        self.carbonNode[i] = TFDirector:getChildByPath(ui, "item_" .. i);

        self.carbonNode[i].txt_times = TFDirector:getChildByPath(self.carbonNode[i], "txt_number");
        self.carbonNode[i].node_times = TFDirector:getChildByPath(self.carbonNode[i], "bg_point");
        self.carbonNode[i].txt_timeLeft = TFDirector:getChildByPath(self.carbonNode[i], "txt_time");

        self.carbonNode[i].img_diff = {}
        self.carbonNode[i].img_diff[1] = TFDirector:getChildByPath(self.carbonNode[i], "btn_putong");
        self.carbonNode[i].img_diff[2] = TFDirector:getChildByPath(self.carbonNode[i], "btn_kunnan");
        self.carbonNode[i].img_diff[3] = TFDirector:getChildByPath(self.carbonNode[i], "btn_zongshi");

    

        self.carbonNode[i].txt_open = TFDirector:getChildByPath(self.carbonNode[i], "txt_kaifang");

        self.carbonNode[i].node_times:setVisible(false)
        self.carbonNode[i].txt_timeLeft:setVisible(false)

        local index = 1 + (i -1) * 4;
        self.carbonNode[i].index = index;

        for j=1,3 do
            local carbonItemDiff = MoHeYaConfigure:objectAt(index + j - 1);
            -- self.carbonNode[i].img_diff[j].index = index + j - 1;
            self.carbonNode[i].img_diff[j].index = index + j;
            self.carbonNode[i].img_diff[j].logic = self;
            self.carbonNode[i].img_diff[j]:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onAttackDiffClickHandle));
        end

        local carbonItemDiff1 = MoHeYaConfigure:objectAt(index + 1);
        if carbonItemDiff1.open_level >  MainPlayer:getLevel() then
            self.carbonNode[i].img_diff[2]:setTextureNormal("ui_new/climb/MK_kunnan2.png");
            --self.carbonNode[i].img_diff[2].des = "未开启"
            self.carbonNode[i].img_diff[2].des = localizable.commom_no_open

        end

        local carbonItemDiff2 = MoHeYaConfigure:objectAt(index + 2);
        if carbonItemDiff2.open_level >  MainPlayer:getLevel() then
            self.carbonNode[i].img_diff[3]:setTextureNormal("ui_new/climb/MK_zongshi2.png");
            --self.carbonNode[i].img_diff[3].des = "未开启"
            self.carbonNode[i].img_diff[3].des = localizable.commom_no_open
        end

        index = 1 + (i -1) * 4;
        local carbonItem = MoHeYaConfigure:objectAt(index);

        local armatureID = carbonItem.icon_id
        if not ModelManager:existResourceFile(1, armatureID) then
            armatureID = 10006
        end
        ModelManager:addResourceFromFile(1, armatureID, 1)
        local armature = ModelManager:createResource(1, armatureID)
        if armature == nil then
            return
        end

        armature:setScale(0.8);

        -- local resPath = "armature/".. carbonItem.icon_id ..".xml"
        -- if not TFFileUtil:existFile(resPath) then
        --     resPath = "armature/10006.xml"
        -- end

        -- TFResourceHelper:instance():addArmatureFromJsonFile(resPath)

        -- local armature = TFArmature:create(carbonItem.icon_id .. "_anim")
        -- if armature == nil then
        --     return nil
        -- end
        -- armature:setScale(1.3);

        
        armature:setPosition(ccp(180, 230))
        self.carbonNode[i]:addChild(armature,0);
        self.carbonNode[i].armature = armature;
    end


end

function ClimbCarbonListLayer:onShow()
    self.super.onShow(self)
    self.generalHead:onShow()
    self:refreshBaseUI()
    self:refreshUI()
    self:refreshTimes()
end

function ClimbCarbonListLayer:refreshBaseUI()

end

function ClimbCarbonListLayer:loadHomeData(data)
    self.homeInfo = data;
end

function ClimbCarbonListLayer:loadData(data)
    self:refreshUI()
    self:refreshTimes()
end

function ClimbCarbonListLayer:refreshTimes()
    for i=1,3 do
        local index = 1 + (i -1) * 4
        local carbonItem = MoHeYaConfigure:objectAt(index)
        local resConfigure = PlayerResConfigure:objectByID(carbonItem.res_type)
        local info = MainPlayer:GetChallengeTimesInfo(carbonItem.res_type)
        local waitRemainExpression = info:getWaitTimeExpression(':')
        
        if waitRemainExpression then
            self.carbonNode[i].txt_timeLeft:setVisible(true);
            self.carbonNode[i].txt_timeLeft:setText(waitRemainExpression)
        else
            self.carbonNode[i].txt_timeLeft:setVisible(false)
        end

        local openDay = carbonItem.open_date
        local openList = string.split(openDay, ',')
        --local openDesc = "每周"
        local openDesc = localizable.common_every_week
        for k,v in pairs(openList) do
            
        end
        self.carbonNode[i].txt_open:setText(carbonItem.open_description)
     end
end 

function ClimbCarbonListLayer:refreshUI()
    for i=1,3 do
        local index = 1 + (i -1) * 4;
        local carbonItem = MoHeYaConfigure:objectAt(index);

        local armature = self.carbonNode[i].armature;
        if carbonItem:isOpen() then
            -- armature:play("stand", -1, -1, 1)
            ModelManager:playWithNameAndIndex(armature, "stand", -1, 1, -1, -1)
            -- self.carbonNode[i]:setShaderProgramDefault(true)
            self.carbonNode[i]:setColor(ccc3(255,255,255))
            armature:setColor(ccc3(255,255,255))

            -- self.carbonNode[i]:setTouchEnabled(false);
            for j=1,3 do
                self.carbonNode[i].img_diff[j]:setTouchEnabled(true)  
            end
            local resInfo = MainPlayer:GetChallengeTimesInfo(carbonItem.res_type)

            self.carbonNode[i].txt_times:setText(resInfo.currentValue .. "/" .. resInfo.maxValue)
            self.carbonNode[i].node_times:setVisible(true);
        else
            -- self.carbonNode[i]:setShaderProgram("GrayShader", true)

            self.carbonNode[i]:setColor(ccc3(128,128,128))
            armature:setColor(ccc3(128,128,128))
            self.carbonNode[i]:setTouchEnabled(true);
            for j=1,3 do
                self.carbonNode[i].img_diff[j]:setTouchEnabled(false)  
            end
            self.carbonNode[i].node_times:setVisible(false);
        end
    end

end

function ClimbCarbonListLayer:removeUI()
    self.super.removeUI(self);

    TFDirector:removeTimer(self.nTimerId);
    self.nTimerId = nil;
end

function ClimbCarbonListLayer:dispose()
    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end

    self.super.dispose(self)
end

function ClimbCarbonListLayer.onAttackDiffClickHandle(sender)
    local self = sender.logic;
    if sender.des then
        toastMessage(sender.des);
        return;
    end
    print("--- ClimbCarbonListLayer.onAttackDiffClickHandle = ", sender.index)
    self:onAttackcarbon(sender.index)
end

function ClimbCarbonListLayer.onAttackClickHandle(sender)
    print("--- ClimbCarbonListLayer.onAttackClickHandle = ", sender.index)
    local self  = sender.logic;
    local index = sender.index -- (sender.index - 1)*4 + 1;
    self:onAttackcarbon(index);
end

function ClimbCarbonListLayer:onAttackcarbon(index)

    print("--- ClimbCarbonListLayer:onAttackcarbon = ", index)
    local carbonItem = MoHeYaConfigure:objectAt(index)

    if carbonItem:isOpen() then

        -- 781号bug 策划说的要优化  策划：司徒。。。以后有问题找她
        -- local resConfigure = PlayerResConfigure:objectByID(carbonItem.res_type)
        -- local resInfo = MainPlayer:GetChallengeTimesInfo(carbonItem.res_type)
        -- local waitRemainExpression = resInfo:getWaitTimeExpression()

        -- if resInfo.currentValue < 1 then
        --     toastMessage("今日挑战次数已用完")
        -- elseif waitRemainExpression ~= nil then
        --     toastMessage("冷却 " .. waitRemainExpression .. " 后可再挑战")
        -- else
        --      -- ClimbManager:showCarbonDetailLayer(index)
            ClimbManager:showCarbonChooseLayer(index)
        -- end
    else
        ClimbManager:showCarbonNotOpenLayer(index)
    end
end


function ClimbCarbonListLayer:registerEvents()
    self.super.registerEvents(self);
    
    self.updateCarbonListCallBack = function(event)
        self:loadData(event.data[1]);
    end;
    TFDirector:addMEGlobalListener(ClimbManager.updateCarbonList ,self.updateCarbonListCallBack ) ;

    self.updateHomeInfoCallBack = function(event)
        self:loadHomeData(event.data[1]);
    end;
    TFDirector:addMEGlobalListener(ClimbManager.updateHomeInfo ,self.updateHomeInfoCallBack ) ;
    for i=1,3 do
       self.carbonNode[i].logic = self;
       self.carbonNode[i]:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onAttackClickHandle));
    end

    self.onUpdated = function(event)
        self:refreshTimes()
    end

    if not  self.nTimerId then
         self.nTimerId = TFDirector:addTimer(1000, -1, nil, self.onUpdated)
    end

    if self.generalHead then
        self.generalHead:registerEvents()
    end
 end

function ClimbCarbonListLayer:removeEvents()
    self.super.removeEvents(self);

    TFDirector:removeMEGlobalListener(ClimbManager.updateCarbonList ,self.updateCarbonListCallBack);
    TFDirector:removeMEGlobalListener(ClimbManager.updateHomeInfo ,self.updateHomeInfo);

    if self.generalHead then
        self.generalHead:removeEvents()
    end
end

return ClimbCarbonListLayer;
