--[[
******VIP特权列表*******

    -- by haidong.gan
    -- 2013/11/27
]]
local VipChangeLayer = class("VipChangeLayer", BaseLayer)

CREATE_SCENE_FUN(VipChangeLayer)
CREATE_PANEL_FUN(VipChangeLayer)

VipChangeLayer.LIST_ITEM_WIDTH = 210 

VipChangeLayer.TEXT_ENOUGH = localizable.common_vip_change_layer_enough
VipChangeLayer.TEXT_NOT_ENOUGH = localizable.common_vip_change_layer_not_enough

function VipChangeLayer:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.pay.VipChangeLayer")
end

function VipChangeLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.panel_list     = TFDirector:getChildByPath(ui, 'panel_vip')
    self.btn_close 		= TFDirector:getChildByPath(ui, 'btn_close')
    self.btn_buyBox     = TFDirector:getChildByPath(ui, 'btn_reward')
    self.txt_curVip     = TFDirector:getChildByPath(ui, 'txt_curVip')
    panel_content       = TFDirector:getChildByPath(ui, 'panel_content')
    self.sv_vipinfo     = TFDirector:getChildByPath(ui, 'sv_vipinfo');
    self.img_VIP        = TFDirector:getChildByPath(ui, 'img_VIP');

    --added by wuqi
    self.img_new_vip = TFDirector:getChildByPath(ui, "img_new_vip")
    self.lb2 = TFDirector:getChildByPath(ui, "lb2")

    self.bFirstDraw = true

    local resPath = "effect/ui/level_up_light.xml"
    TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
    local effect = TFArmature:create("level_up_light_anim")

    effect:setAnimationFps(GameConfig.ANIM_FPS)
    effect:setPosition(ccp(470,800))
    panel_content:addChild(effect,98)        
    effect:playByIndex(0, -1, -1, 1)

    self.img_VIP        = TFDirector:getChildByPath(ui, 'img_VIP');
    self.selectIndex    = nil;
    self:initVipInfoPanel()
end



function VipChangeLayer:onShow()
    self.super.onShow(self)
    self:refreshUI()
end

function VipChangeLayer:refreshUI()
    if not self.isShow then
        return
    end

    self.txt_curVip:setVisible(true)
    self.img_new_vip:setVisible(false)
    self.btn_buyBox:setVisible(true)
    self.lb2:setText(self.TEXT_ENOUGH)

    self.txt_curVip:setText("o"  .. MainPlayer:getVipLevel())
    --modify by zr VIP等级显示
       --[[
    if MainPlayer:getVipLevel() > 15 then
        self:addVipEffect(self.img_new_vip, MainPlayer:getVipLevel())
        self.txt_curVip:setVisible(false)
        self.img_new_vip:setVisible(true)
        self.btn_buyBox:setVisible(false)
        self.lb2:setText(self.TEXT_NOT_ENOUGH)
    end
  ]]---
    if MainPlayer:getVipLevel() > 0 then
        local vip = PayManager.vipList:objectByID(MainPlayer:getVipLevel());
        local index = PayManager.vipList:indexOf(vip);
        self:refresVipList(index);
    else
        self:refresVipList(1);
    end
end

--added by wuqi
function VipChangeLayer:addVipEffect(btn, vipLevel)
    if btn.effect then
        btn.effect:removeFromParent()
        btn.effect = nil
    end

    if vipLevel <= 18 then  --if vipLevel <= 15 or vipLevel > 18 then -- modify by zr 关掉高VIP特效
        return
    end
    local resPath = "effect/ui/vip_" .. vipLevel .. ".xml"
    TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
    local effect = TFArmature:create("vip_" .. vipLevel .. "_anim")
    effect:setAnimationFps(GameConfig.ANIM_FPS)
    effect:setPosition(ccp(btn:getContentSize().width / 2, btn:getContentSize().height / 2))
    effect:setVisible(true)
    --effect:setScale(0.9)
    effect:playByIndex(0, -1, -1, 1)
    btn:addChild(effect, 200)
    btn.effect = effect
end

function VipChangeLayer:refresVipList(pageIndex)
    self:showInfoForPage(pageIndex)   
end

function VipChangeLayer:initVipInfoPanel()
    self.vip_node = createUIByLuaNew("lua.uiconfig_mango_new.pay.VipRewardItem")
    self.panel_list:addChild(self.vip_node);
    self.vip_node:setPosition(ccp(60,50))
    self.btn_free  =  TFDirector:getChildByPath(self.vip_node, 'btn_free');
    self.btn_free.logic=self;
    self.txt_MyCurVip  =  TFDirector:getChildByPath(self.vip_node, 'txt_curVip');
    self.txt_VipName =  TFDirector:getChildByPath(self.vip_node, 'txt_viptequan');
    self.img_new_vip1 = TFDirector:getChildByPath(self.vip_node, "img_new_vip")
    local richText = TFRichText:create(self.panel_list:getContentSize())
    richText:setTouchEnabled(true)
    richText:setPosition(ccp(10,117))
    richText:setAnchorPoint(ccp(0, 0.5))
    self.sv_vipinfo:addChild(richText);
    self.richText = richText
end

function VipChangeLayer:showVipInfo( index )
    local vip = PayManager.vipList:objectAt(index);
    self.btn_free.vipId = vip.id;
    self.txt_MyCurVip:setText("o" .. vip.id)

    self.txt_MyCurVip:setVisible(true)
    self.img_new_vip1:setVisible(false)
--modify by zr VIP等级显示
       --[[
    if MainPlayer:getVipLevel() > 15 then
        self:addVipEffect(self.img_new_vip1, MainPlayer:getVipLevel())
        self.txt_MyCurVip:setVisible(false)
        self.img_new_vip1:setVisible(true)
    end
]]--
    local description = vip.privilege
    description = description:gsub("#blue#",           [[</font><font color="#0060FF" fontSize = "20">]] );
    description = description:gsub("#red#",            [[</font><font color="#FF0000" fontSize = "20">]] );
    description = description:gsub("#end#",            [[</font><font color="#000000" fontSize = "20">]]);
    description = description:gsub("\n",               [[<br></br><img src="ui_new/pay/VIP_dian.png"></img>]]);
    description = description:gsub("#btn#",            [[</font><a ]]);
    description = description:gsub("#/1btn#",          [[name="gobuy" href="" ></a>]]);
    description = description:gsub("#/2btn#",          [[name="detail" href="" ><img src="ui_new/pay/btn_xiang.png"></img></a><font color="#000000" fontSize = "20">]]);
    local des =  [[<p style="text-align:left;margin:10px">]];
    des = des .. [[<img src="ui_new/pay/VIP_dian.png"></img>]]
    des = des .. [[<font color="#000000" fontSize = "20">]]
    des = des .. description
    des = des .. [[</font>]]
    des = des .. [[</p>]]
    self.txt_VipName:setText(vip.name)
    self.richText:setText(des)
    -----------------------------------------
    local size1 = self.richText:getContentSize()
    local size2 = self.sv_vipinfo:getContentSize()
    if size1.height > size2.height then
        self.sv_vipinfo:setInnerContainerSize(CCSizeMake(size2.width,size1.height))
    else
        self.sv_vipinfo:setInnerContainerSize(size2)
    end
    local size3 = self.sv_vipinfo:getInnerContainerSize()

    self.richText:setPositionY(size3.height*0.5)
    self.sv_vipinfo:setContentOffset(ccp(0,size2.height - size3.height))
    -----------------------------------------

    local rewardList = PayManager:getReward(vip.id);
    for i=1,3 do
        local node_reward  =  TFDirector:getChildByPath(self.vip_node, 'node_reward' .. i);
        local reward = rewardList:objectAt(i)
        if reward then
            node_reward:setVisible(true);
            Public:loadIconNode(node_reward,reward);
        else
            node_reward:setVisible(false);
        end
    end

    self.btn_free:removeChildByTag(10086,true);
  
    local resPath = "effect/ui_vip_get_reward.xml"
    TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
    local effect = TFArmature:create("ui_vip_get_reward_anim")
    effect:setAnimationFps(GameConfig.ANIM_FPS)
    effect:setPosition(ccp(-32, -17))
    self.btn_free:addChild(effect,1)
    effect:playByIndex(0, -1, -1, 1)
    effect:setTag(10086);
    self.btn_free:setVisible(true);
    if MainPlayer:getVipLevel() >= vip.id then
        if PayManager:isHaveGetVipReward(vip.id) then
            self.btn_free:setVisible(false);
        end
    end
    if self.selectIndex == 1 then
        self.img_VIP:setVisible(false)
    else
        self.img_VIP:setVisible(true)
        self.img_VIP:setTexture("ui_new/pay/VIP"..(self.selectIndex - 1)..".jpg")
    end
    
end

function VipChangeLayer:showInfoForPage(pageIndex)
    self.selectIndex = pageIndex
    self:showVipInfo(self.selectIndex)
end

function VipChangeLayer:removeUI()
   self.super.removeUI(self)
end

function VipChangeLayer.BuyVipBoxClickHandle(sender)
    local self = sender.logic

    -- MallManager:openMallLayer(2)
    self.bFirstDraw = false
    MallManager:openGiftsShop()
end

function VipChangeLayer.onGetReardClickHandle(sender)
   local self = sender.logic
   PayManager:getVipReward(sender.vipId)
end

--注册事件
function VipChangeLayer:registerEvents()
    self.super.registerEvents(self)

    ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)
    self.btn_close:setClickAreaLength(100)



    self.btn_buyBox.logic=self
    self.btn_buyBox:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.BuyVipBoxClickHandle),1)


    self.updateRewardListCallBack = function(event)
        self:refreshUI()
    end
    TFDirector:addMEGlobalListener(PayManager.updateVipRewardList ,self.updateRewardListCallBack ) 

    self.btn_free:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onGetReardClickHandle),1);
end

function VipChangeLayer:removeEvents()
    TFDirector:removeMEGlobalListener(PayManager.updateVipRewardList ,self.updateRewardListCallBack)
    -- TFDirector:removeMEGlobalListener(PayManager.GET_VIP_REWARD_RESULT ,self.getRewardResultCallBack)
    -- TFDirector:removeMEGlobalListener(PayManager.updateVipRewardList ,self.updateRewardListCallBack)
end

return VipChangeLayer
