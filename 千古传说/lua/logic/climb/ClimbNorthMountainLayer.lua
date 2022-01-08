local ClimbNorthMountainLayer = class("ClimbNorthMountainLayer", BaseLayer);

CREATE_SCENE_FUN(ClimbNorthMountainLayer);
CREATE_PANEL_FUN(ClimbNorthMountainLayer);

--[[
******无量山-欢迎界面*******

    -- by haidong.gan
    -- 2013/12/27
]]

function ClimbNorthMountainLayer:ctor(data)
    self.super.ctor(self,data);
    
    self:init("lua.uiconfig_mango_new.climb.ClimbMountain");


end

function ClimbNorthMountainLayer:initUI(ui)
    self.super.initUI(self,ui);

    self.generalHead = CommonManager:addGeneralHead( self )

    self.generalHead:setData(ModuleType.NorthClimb,{HeadResType.CLIMBDIAMOD,HeadResType.COIN,HeadResType.SYCEE})


    self.txt_curIndex   = TFDirector:getChildByPath(ui, 'txt_curIndex');
    self.btn_qunanku        = TFDirector:getChildByPath(ui, 'btn_qunanku');
    self.btn_saodang        = TFDirector:getChildByPath(ui, 'btn_saodang');
    self.btn_yijian        = TFDirector:getChildByPath(ui, 'btn_yijian');
    self.btn_chongzhi        = TFDirector:getChildByPath(ui, 'btn_chongzhi');
    self.txt_num        = TFDirector:getChildByPath(ui, 'txt_num');
    -- self.btn_bangzhu        = TFDirector:getChildByPath(ui, 'btn_bangzhu');


    self.scrollview        = TFDirector:getChildByPath(ui, 'scrollview');
    Public:bindScrollFun(self.scrollview)

    self.detailLayer    = require('lua.logic.climb.NorthMountainDetailLayer'):new()


    self.detailLayer:setZOrder(10)
    self:addLayer(self.detailLayer)

    self.roleNode = {}
end


function ClimbNorthMountainLayer:dispose()
    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end
    self.super.dispose(self)
end
function ClimbNorthMountainLayer:onShow()
    self.super.onShow(self)
    self.generalHead:onShow()
    self:refreshUI()
end


function ClimbNorthMountainLayer:refreshUI()
    self.txt_curIndex:setText(math.ceil(NorthClimbManager.floor/3))
    self.scrollview:getInnerContainer():stopAllActions()
    self.scrollview:scrollToYTop()
    self.detailLayer:setAttackEnable(true)
    for i=1,3 do
        if self.roleNode[i] == nil then
            self:creatRoleNode(i)
        end

        local floor = math.floor((NorthClimbManager.floor-1)/3)*3 + i
        local mountainInfo = NorthClimbManager.northCaveFloorInfo[floor]
        if mountainInfo then
            self:loadMountainNode(self.roleNode[i],mountainInfo);
        end
    end
    self.detailLayer:loadData(NorthClimbManager.northCaveFloorInfo[NorthClimbManager.floor])

    if NorthClimbManager:mathFloorState() == 1 then
        -- NorthClimbManager:showOpenBoxLayer()
        self.detailLayer:showBoxVisible(true)
    else
        self.detailLayer:showBoxVisible(false)
    end
    
    self.txt_num:setText(NorthClimbManager.remainResetCount)

    if NorthClimbManager:mathFloorState() == 2 then
        NorthClimbManager:showClimbInspireLayer()
    end
end


--添加关卡节点
function ClimbNorthMountainLayer:loadMountainNode(mountain_node, mountainInfo)
    print("mountainInfo - ",mountainInfo)
    -- local img_icon = TFDirector:getChildByPath(mountain_node, 'img_icon')
    -- img_icon:setVisible(false)

    local northCaveNpcInfo = NorthCaveNpcData:objectByID(mountainInfo.formationId)

    -- img_icon:setTextureNormal("icon/rolebig/" .. northCaveNpcInfo.display .. ".png")
    -- img_icon:setTouchEnabled(false)
    -- mountain_node:setTouchEnabled(false)

    local img_lock = TFDirector:getChildByPath(mountain_node, 'img_lock')
    local img_floor_bg = TFDirector:getChildByPath(mountain_node, 'img_floor_bg')
    local panel_hero = TFDirector:getChildByPath(mountain_node, 'Panel_hero')
    -- img_floor_bg:setTouchEnabled(false)
    local img_arrow = TFDirector:getChildByPath(mountain_node, 'img_arrow')
    img_arrow:setVisible(false)

    local img_flag = TFDirector:getChildByPath(mountain_node, 'img_flag')
    local txt_index = TFDirector:getChildByPath(mountain_node, 'txt_floor')
    local floor_num = math.mod(mountainInfo.sectionId,3)
    floor_num = floor_num == 0 and 3 or floor_num
    --txt_index:setText("第" .. floor_num .. "关");
    txt_index:setText(stringUtils.format(localizable.common_index_round,floor_num));

    local Panel_Content = TFDirector:getChildByPath(mountain_node, 'Panel_Content1');
    Panel_Content:setVisible(false)
    Panel_Content = TFDirector:getChildByPath(mountain_node, 'Panel_Content');
    Panel_Content:setVisible(true)

    -- img_icon:setTouchEnabled(false);
    -- mountain_node:setTouchEnabled(false)
    -- img_floor_bg:setTouchEnabled(false)

    img_lock:setVisible(false)
    -- img_pass:setVisible(false);
    img_flag:setVisible(false)
    
    -- img_icon:setColor(ccc3(255,255,255))

    if mountain_node.armature then
        mountain_node.armature:removeFromParent()
    end

    local armatureID = northCaveNpcInfo.display
    ModelManager:addResourceFromFile(1, armatureID, 1)
    mountain_node.armature = ModelManager:createResource(1, armatureID)
    panel_hero:addChild(mountain_node.armature)
    mountain_node.armature:setScale(0.6)

    if  mountainInfo.score > 0 then
        -- img_pass:setVisible(true);
        img_floor_bg:setTexture("ui_new/climb/wls_cengshu_bg.png")
        img_flag:setTexture("ui_new/climb/wl_qizi1.png")
        -- img_icon:setVisible(true);
        img_flag:setVisible(true)
        txt_index:setColor(ccc3(0,0,0))
        for i=1,3 do
            local img_star        = TFDirector:getChildByPath(mountain_node, 'img_star'..i)
            local img_star_light  = TFDirector:getChildByPath(img_star, 'img_star')
            if i <= mountainInfo.score then
                img_star_light:setVisible(true)
            else
                img_star_light:setVisible(false)
            end
            img_star:setVisible(true)
        end
    else
        if mountainInfo.sectionId == NorthClimbManager.floor then

            -- img_arrow:setVisible(true);
            -- img_icon:setVisible(false)
            img_flag:setVisible(true)
            img_floor_bg:setTexture("ui_new/climb/wl_kaiqi.png")
            if NorthClimbManager.isFail then
                img_flag:setTexture("ui_new/climb/wl_qizi2.png")
            else
                img_flag:setTexture("ui_new/climb/wl_qizi.png")
            end
            txt_index:setColor(ccc3(255,255,255))

            ModelManager:playWithNameAndIndex(mountain_node.armature, "stand", -1, 1, -1, -1)
      -- if 1 then
      --       return
      --   end

            -- local armature = self:getArmatureByImage(northCaveNpcInfo.display)
            -- armature:setPosition(ccp(img_icon:getPosition().x,img_icon:getPosition().y - img_icon:getSize().height/2 * img_icon:getScaleY()+ 10))
            -- mountain_node:addChild(armature)
            -- mountain_node.armature = armature

            for i=1,3 do
                local img_star        = TFDirector:getChildByPath(mountain_node, 'img_star'..i)
                local img_star_light  = TFDirector:getChildByPath(img_star, 'img_star')
                -- img_star_light:setVisible(false)
                img_star:setVisible(false)
            end

        else--if mountainInfo.sectionId > NorthClimbManager.floor then
            -- img_icon:setColor(ccc3(166,166,166))
            mountain_node.armature:setColor(ccc3(100,100,100))
            img_lock:setVisible(true)
            -- img_icon:setVisible(true);
            img_flag:setVisible(false)
            img_floor_bg:setTexture("ui_new/climb/wls_cengshu_bg.png")
            txt_index:setColor(ccc3(0,0,0))

            for i=1,3 do
                local img_star        = TFDirector:getChildByPath(mountain_node, 'img_star'..i)
                local img_star_light  = TFDirector:getChildByPath(img_star, 'img_star')
                -- img_star_light:setVisible(false)
                img_star:setVisible(false)
            end
        end
    end

end

function ClimbNorthMountainLayer:creatRoleNode(index )
    local node = TFDirector:getChildByPath(self.ui, 'node'..index)
    local roleNode = createUIByLuaNew("lua.uiconfig_mango_new.climb.ClimbMountainItemNode")
    roleNode:setScale(0.8)
    roleNode:setName("roleNode" .. index)
    roleNode:setPosition(node:getPosition())
    node:getParent():addChild(roleNode)
    self.roleNode[index] = roleNode
end

--填充主页信息
function ClimbNorthMountainLayer:loadHomeInfo()

end


function ClimbNorthMountainLayer.onGoClickHandle(sender)
   local self = sender.logic;
   ClimbManager:showMountainLayer();
end

function ClimbNorthMountainLayer:removeUI()
    self.super.removeUI(self);

end

function ClimbNorthMountainLayer:showMoveAction()
    for i=4,6 do
        if self.roleNode[i] == nil then
            self:creatRoleNode(i)
        end
        local floor = math.floor((NorthClimbManager.floor-1)/3)*3 + i - 3
        local mountainInfo = NorthClimbManager.northCaveFloorInfo[floor]
        if mountainInfo then
            self:loadMountainNode(self.roleNode[i],mountainInfo);
        end
    end
    self.scrollview:scrollToYLast(0.9)
    if self.scrollTimer then
        TFDirector:removeTimer(self.scrollTimer)
        self.scrollTimer = nil
    end
    self.detailLayer:setAttackEnable(false)
    self.scrollTimer = TFDirector:addTimer(1000,1,nil,function ()
        self:refreshUI()
        TFDirector:removeTimer(self.scrollTimer)
        self.scrollTimer = nil
    end)
end

function ClimbNorthMountainLayer.onClickSouthMountain(sender)
    AlertManager:close()
    ClimbManager:showMountainLayer()
end

function ClimbNorthMountainLayer.onClickResetNorthClimb(sender)
    -- NorthClimbManager:RequestResetNorthCave()

    --local warningMsg = "是否重置当前无量山北窟进度？"
    local warningMsg = localizable.climbNorthLayer_reset
        CommonManager:showOperateSureLayer(
                function()
                    NorthClimbManager:RequestResetNorthCave()
                end,
                nil,
                {
                    msg = warningMsg
                }
        )
end

function ClimbNorthMountainLayer.onClickSweepNorthClimb(sender)
    NorthClimbManager:NorthCaveSweepRequest()
end

function ClimbNorthMountainLayer.onClickOnKeySweepNorthClimb(sender)
    CommonManager:showOperateSureLayer(function()
        NorthClimbManager:OneKeySweepRequest()
    end,
    nil,
    {
        --msg = "一键扫荡将会扫荡至最高一次达成所有目标的层，并自动选取9钻兑换属性，是否扫荡？",
        msg = localizable.climbNorthLayer_onekey_tips,
    })
end


-- function ClimbNorthMountainLayer.onClickNorthClimbHelp(sender)
--     CommonManager:showRuleLyaer("wuliangshanbeiku")
-- end


function ClimbNorthMountainLayer:registerEvents()
    self.super.registerEvents(self);

    self.btn_qunanku:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onClickSouthMountain));
    self.btn_chongzhi:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onClickResetNorthClimb));
    self.btn_saodang:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onClickSweepNorthClimb));
    self.btn_yijian:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onClickOnKeySweepNorthClimb));

    -- self.btn_bangzhu:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onClickNorthClimbHelp));


    self.onReceiveNorthCaveAttributeChoiceSuccess = function(event)
        self:showMoveAction()
    end;
    TFDirector:addMEGlobalListener(NorthClimbManager.NORTH_CAVE_ATTRIBUTE_CHOICE_SUCCESS ,self.onReceiveNorthCaveAttributeChoiceSuccess ) ;
    self.onReceiveResetNorthCaveResult = function(event)
        self:refreshUI()
    end;
    TFDirector:addMEGlobalListener(NorthClimbManager.RESET_NORTH_CAVE_RESULT ,self.onReceiveResetNorthCaveResult ) ;

    if self.generalHead then
        self.generalHead:registerEvents()
    end

end

function ClimbNorthMountainLayer:removeEvents()
    self.super.removeEvents(self);

    TFDirector:removeMEGlobalListener(NorthClimbManager.NORTH_CAVE_ATTRIBUTE_CHOICE_SUCCESS,self.onReceiveNorthCaveAttributeChoiceSuccess);
    TFDirector:removeMEGlobalListener(NorthClimbManager.RESET_NORTH_CAVE_RESULT,self.onReceiveResetNorthCaveResult);

    if self.scrollTimer then
        TFDirector:removeTimer(self.scrollTimer)
        self.scrollTimer = nil
    end

    if self.generalHead then
        self.generalHead:removeEvents()
    end
end

function ClimbNorthMountainLayer:getArmatureByImage(image)
    local resID = image
    local resPath = "armature/"..resID..".xml"
    if not TFFileUtil:existFile(resPath) then
        resID = 10006
        resPath = "armature/"..resID..".xml"
    end

    TFResourceHelper:instance():addArmatureFromJsonFile(resPath)

    local armature = TFArmature:create(resID.."_anim")
    if armature == nil then
        return nil
    end
    armature:play("stand", -1, -1, 1)
    armature:setScale(0.9)
    armature:setRotationY(180);
    -- armature:removeUnuseTexEnabled(true);
    return armature
end
return ClimbNorthMountainLayer;
