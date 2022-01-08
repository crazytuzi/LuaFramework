--[[
******VIP特权列表*******

    -- by haidong.gan
    -- 2013/11/27
]]
local VipLayer = class("VipLayer", BaseLayer);

CREATE_SCENE_FUN(VipLayer);
CREATE_PANEL_FUN(VipLayer);

VipLayer.LIST_ITEM_WIDTH = 210; 

function VipLayer:ctor(data)
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.pay.VipLayer");
end

function VipLayer:initUI(ui)
    self.super.initUI(self,ui);

    self.panel_list   = TFDirector:getChildByPath(ui, 'panel_vip');

    self.btn_left           = TFDirector:getChildByPath(ui, 'btn_pageleft')
    self.btn_right          = TFDirector:getChildByPath(ui, 'btn_pageright')

    self.btn_close 		  = TFDirector:getChildByPath(ui, 'btn_close');
    self.btn_pay        = TFDirector:getChildByPath(ui, 'btn_pay');


    self.node_vip       = TFDirector:getChildByPath(ui, 'node_vip');
    self.node_notVip    = TFDirector:getChildByPath(ui, 'node_notVip');
    self.node_topVip    = TFDirector:getChildByPath(ui, 'node_topVip');


    -- self.richText = TFRichText:create(CCSizeMake(500, 24));
    -- self.list_vip:addChild(self.richText);

    self.img_fisrtPay   = TFDirector:getChildByPath(ui, 'img_fisrtPay');

    -- self.txt_pagePrevVip   = TFDirector:getChildByPath(ui, 'txt_pagePrevVip');
    -- self.txt_pageNextVip   = TFDirector:getChildByPath(ui, 'txt_pageNextVip');

    self.sv_vipinfo     = TFDirector:getChildByPath(ui, 'sv_vipinfo');
    self.img_VIP        = TFDirector:getChildByPath(ui, 'img_VIP');

    self.img_hide1 = TFDirector:getChildByPath(ui, "img_di1")
    self.img_hide2 = TFDirector:getChildByPath(ui, "img_di2")

    self.selectIndex    = nil;
    self:initDetailNode()
    self:initVipInfoPanel()
end

function VipLayer:onShow()
    self.super.onShow(self)
    self:refreshBaseUI();
end

function VipLayer:loadRewardListData(data)
    self.rewardList = data.rewardList or {};
    self:refreshUI();
end

function VipLayer:refreshBaseUI()

end

function VipLayer:refreshUI()
    if not self.isShow then
        return;
    end


    self.img_fisrtPay:setVisible(false);
    self.node_vip:setVisible(false);
    self.node_notVip:setVisible(false);
    self.node_topVip:setVisible(false);

    -- --首充
    -- if MainPlayer:getTotalRecharge() == 0 then
    --    self.img_fisrtPay:setVisible(true);
    -- end

    local nextVip = PayManager:getNextVip();
    local needMoney = PayManager:getNextNeedMoney();
    local nxtVipNeedMoney = PayManager:getNextVipNeedMoney();

    -- --非vip
    -- if MainPlayer:getVipLevel() == 0 then
    --     self.node_notVip:setVisible(true);
    --     local txt_nextVip      = TFDirector:getChildByPath(self.node_notVip, 'txt_nextVip');
    --     local txt_needMoney    = TFDirector:getChildByPath(self.node_notVip, 'txt_needMoney');
    --     local lb2              = TFDirector:getChildByPath(self.node_notVip, 'lb2');


    --     txt_nextVip:setText("o"  .. nextVip);
    --     txt_needMoney:setText(needMoney);

    --     lb2:setPosition(ccp(txt_needMoney:getPosition().x + txt_needMoney:getSize().width + 5, lb2:getPosition().y));
    --     txt_nextVip:setPosition(ccp(lb2:getPosition().x + lb2:getSize().width + 5 , txt_nextVip:getPosition().y));

    -- else
    if nextVip == -1 then --顶级vip
        self.node_topVip:setVisible(true);
        
        local txt_value    = TFDirector:getChildByPath(self.node_topVip, 'txt_jindu');
        local bar_value    = TFDirector:getChildByPath(self.node_topVip, 'LoadingBar_vip');

        --added by wuqi
        local img_vip = TFDirector:getChildByPath(self.node_topVip, "img_vip")
        local txt_vip = TFDirector:getChildByPath(self.node_topVip, "txt_curVip")

        --modify by zr vip顶级时候显示
        txt_vip:setText("o"  .. MainPlayer:getVipLevel());
        txt_vip:setVisible(true)
        img_vip:setVisible(false)


        --txt_vip:setVisible(false)
        --img_vip:setVisible(true)

        self:addVipEffect(img_vip, MainPlayer:getVipLevel())
        
        txt_value:setText(PayManager:getNeedMoneyVip(MainPlayer:getVipLevel()) .. "/" .. PayManager:getNeedMoneyVip(MainPlayer:getVipLevel())); 
        bar_value:setPercent(100)

    else
        self.node_vip:setVisible(true);
        local txt_curVip      = TFDirector:getChildByPath(self.node_vip, 'txt_curVip');
        local txt_nextVip      = TFDirector:getChildByPath(self.node_vip, 'txt_nextVip');
        local txt_needMoney    = TFDirector:getChildByPath(self.node_vip, 'txt_needMoney');
        local txt_value    = TFDirector:getChildByPath(self.node_vip, 'txt_value');
        local bar_value    = TFDirector:getChildByPath(self.node_vip, 'bar_value');

        local lb2              = TFDirector:getChildByPath(self.node_vip, 'lb2');

        --added by wuqi
        local img_vip1 = TFDirector:getChildByPath(self.node_vip, "img_curVip")
        local img_vip2 = TFDirector:getChildByPath(self.node_vip, "img_nextVip")
        txt_curVip:setVisible(true)
        txt_nextVip:setVisible(true)
        img_vip1:setVisible(false)
        img_vip2:setVisible(false)

        txt_curVip:setText("o"  .. MainPlayer:getVipLevel());
        txt_nextVip:setText("o"  .. nextVip);
        txt_needMoney:setText(needMoney); 
        txt_value:setText(nxtVipNeedMoney - needMoney .. "/" .. nxtVipNeedMoney); 

        bar_value:setPercent((nxtVipNeedMoney - needMoney)/nxtVipNeedMoney*100)

        lb2:setPosition(ccp(txt_needMoney:getPosition().x + txt_needMoney:getSize().width + 5 , lb2:getPosition().y));
        txt_nextVip:setPosition(ccp(lb2:getPosition().x + lb2:getSize().width + 5 , txt_nextVip:getPosition().y));

        --added by wuqi
        --modify by zr VIP等级显示
       --[[
        if MainPlayer:getVipLevel() > 15 then
            self:addVipEffect(img_vip1, MainPlayer:getVipLevel())
            txt_curVip:setVisible(false)
            img_vip1:setVisible(true)
        end

        if nextVip > 15 then
            self:addVipEffect(img_vip2, nextVip)
            txt_nextVip:setVisible(false)
            img_vip2:setVisible(true)
            img_vip2:setPosition(ccp(lb2:getPosition().x + lb2:getSize().width + 70 , txt_nextVip:getPosition().y - 5))
        end
        ]]--
    end


    if not self.selectIndex then
        if MainPlayer:getVipLevel() > 0 then
            local vip = PayManager.vipList:objectByID(MainPlayer:getVipLevel());
            local index = PayManager.vipList:indexOf(vip);
            self:refresVipList(index);
        else
            self:refresVipList(1);
        end
    else
        self:refresVipList(self.selectIndex);
    end
end

--added by wuqi
function VipLayer:addVipEffect(btn, vipLevel)
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

function VipLayer.onLeftClickHandle(sender)
    local self = sender.logic;
    local pageIndex = self.selectIndex;
    self:showInfoForPage(pageIndex - 1);
    self:showDetailNode(false)
end

function VipLayer.onRightClickHandle(sender)
    local self = sender.logic;
    local pageIndex = self.selectIndex;
    self:showInfoForPage(pageIndex + 1);
    self:showDetailNode(false)
end

function VipLayer:refresVipList(pageIndex)
    self:showInfoForPage(pageIndex);    
end

function VipLayer:initDetailNode()
    local detailNodeWidth = 262
    local node = createUIByLuaNew("lua.uiconfig_mango_new.pay.ShowDetail")
    self.img_detail_bg = TFDirector:getChildByPath(node,"bg")
    self.img_detail_bg:setScale9Enabled(true)
    self.img_detail_bg:setImageSizeType(1)
    self.img_detail_bg:setCapInsets(CCRectMake(30,30,38,38))
    local size = self.img_detail_bg:getContentSize()
    self.txt_detail = TFDirector:getChildByPath(node,"txt")
    self.txt_detail:setTextAreaSize(CCSizeMake(detailNodeWidth-20,0))
    self.txt_detail:setText("")
        
    self.detailNode = node
    self.panel_list:addChild(self.detailNode)
    self.detailNode:setVisible(false)
    self.detailNode:setZOrder(1000)


    local function touchBegan( sender )
        self:showDetailNode(false)
        return true
    end

    local clickHelper = CCNode:create()
    clickHelper:setContentSize(self.panel_list:getContentSize())
    clickHelper:setAnchorPoint(ccp(0,0))
    clickHelper:setPosition(ccp(0,0))
    clickHelper:setTouchEnabled(true)
    clickHelper:setSwallowTouch(false)
    clickHelper:setZOrder(100)
    clickHelper:addMEListener(TFWIDGET_TOUCHBEGAN,touchBegan)
    self.panel_list:addChild(clickHelper)
    self.clickHelper = clickHelper
end

function VipLayer:showDetailNode( bVisible ,nID ,pos)
    self.detailNode:setVisible(bVisible)
    if bVisible == false then
        return
    end
    local des = ""
    self.txt_detail:setText(des)
    self.detailNode:setPosition(pos)
    local size = self.txt_detail:getContentSize()
    size.width = size.width + 20
    size.height = size.height + 20
    self.img_detail_bg:setContentSize(size)
    pos.x = pos.x - 5 - size.width*0.5
    pos.y = pos.y + 5 + size.height*0.5
    self.detailNode:setPosition(pos)
end

function VipLayer:initVipInfoPanel()
    self.vip_node = createUIByLuaNew("lua.uiconfig_mango_new.pay.VipRewardItem")
    self.panel_list:addChild(self.vip_node);
    self.vip_node:setPosition(ccp(60,50))
    self.btn_free  =  TFDirector:getChildByPath(self.vip_node, 'btn_free');
    self.btn_free.logic=self;
    self.txt_CurVip  =  TFDirector:getChildByPath(self.vip_node, 'txt_curVip');
    self.txt_VipName =  TFDirector:getChildByPath(self.vip_node, 'txt_viptequan');
    self.img_new_vip1 = TFDirector:getChildByPath(self.vip_node, "img_new_vip")
    -- local richText = TFRichText:create(self.panel_list:getContentSize())
    local richText = TFRichText:create()
    richText:setTouchEnabled(true)
    richText:setAnchorPoint(ccp(0, 1))
    self.sv_vipinfo:addChild(richText);
    self.richText = richText
end

function VipLayer:showVipInfo( index )
    local vip = PayManager.vipList:objectAt(index);
    self.btn_free.vipId = vip.id;
    self.txt_CurVip:setText("o" .. vip.id)

    self.txt_CurVip:setVisible(true)
    self.img_new_vip1:setVisible(false)
    --modify by zr VIP等级显示
    --[[
    if vip.id > 15 then
        self:addVipEffect(self.img_new_vip1, vip.id)
        self.txt_CurVip:setVisible(false)
        self.img_new_vip1:setVisible(true)
    end
]]--
    local description = vip.privilege
    description = description:gsub("#blue#",            [[</font><font color="#0060FF" fontSize = "20">]] );
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
        self.sv_vipinfo:setInnerContainerSize(CCSizeMake(size2.width, size1.height))
        self.richText:setPositionY(size1.height)
    else
        self.sv_vipinfo:setInnerContainerSize(size2)
        self.richText:setPositionY(size2.height)
    end
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
  
    -- local resPath = "effect/ui_vip_get_reward.xml"
    -- TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
    -- local effect = TFArmature:create("ui_vip_get_reward_anim")
    -- effect:setAnimationFps(GameConfig.ANIM_FPS)
    -- effect:setPosition(ccp(-32, -27))
    -- self.btn_free:addChild(effect,1)
    -- effect:playByIndex(0, -1, -1, 1)
    -- effect:setTag(10086);
    self.btn_free:setVisible(true);
    if MainPlayer:getVipLevel() >= vip.id then
        if PayManager:isHaveGetVipReward(vip.id) then
            self.btn_free:setVisible(false);
        end
    end
-- modify　by zr 显示v0特权礼包图片
        self.img_VIP:setVisible(true)
        self.img_VIP:setTexture("ui_new/pay/VIP"..(self.selectIndex - 1)..".jpg")
    --[[ self.selectIndex == 1 then
        self.img_VIP:setVisible(false)
    else
        self.img_VIP:setVisible(true)
        self.img_VIP:setTexture("ui_new/pay/VIP"..(self.selectIndex - 1)..".jpg")
    end
    ]]--
end

function VipLayer:showInfoForPage(pageIndex)
    self.selectIndex = pageIndex;
    local pageCount = PayManager.vipList:length();
    self.btn_left:setVisible(false)
    self.btn_right:setVisible(false)
    if pageIndex < pageCount and pageCount > 1 then
        self.btn_right:setVisible(true)
    end 
    if pageIndex > 1 and pageCount > 1  then
        self.btn_left:setVisible(true)
    end

    --added by wuqi
    local vipLevel = MainPlayer:getVipLevel()
    if vipLevel < pageCount then
        if vipLevel == 18 then 
            if pageIndex == (18 + 1) then
                self.btn_right:setVisible(false)
            else
                self.btn_right:setVisible(true)
            end
        elseif vipLevel == 17 then
            if pageIndex >= (18 + 1) then
                self.btn_right:setVisible(false)
            else
                self.btn_right:setVisible(true)
            end
        elseif vipLevel == 16 then
            if pageIndex >= (17 + 1) then
                self.btn_right:setVisible(false)
            else
                self.btn_right:setVisible(true)
            end
        elseif vipLevel == 15 then
            if pageIndex >= (16 + 1) then
                self.btn_right:setVisible(false)
            else
                self.btn_right:setVisible(true)
            end
        elseif vipLevel < 15 and pageIndex >= (15 + 1) then
            self.btn_right:setVisible(false)
        end
    end

    self:showVipInfo(self.selectIndex)
end

function VipLayer:removeUI()
   self.super.removeUI(self);
end

function VipLayer.onPayClickHandle(sender)
   local self = sender.logic;
   PayManager:showPayLayer(nil,AlertManager.NONE);
   AlertManager:closeLayer(self);
end

function VipLayer.onGetReardClickHandle(sender)
   local self = sender.logic;

    if MainPlayer:getVipLevel() >= sender.vipId then
        if PayManager:isHaveGetVipReward(sender.vipId) then
            --已领取
            --toastMessage("奖励已领取")
            toastMessage(localizable.common_get_award)
            return;
        else
            --未领取
        end
    else
        --等级未到
        --toastMessage("尚未达到相应的VIP等级")
        toastMessage(localizable.common_not_vip)
        return;
    end
   
   PayManager:getVipReward(sender.vipId)
end

--注册事件
function VipLayer:registerEvents()
    self.super.registerEvents(self);

    ADD_ALERT_CLOSE_LISTENER(self,self.btn_close);
    self.btn_close:setClickAreaLength(100);

    self.btn_pay.logic=self;
    self.btn_pay:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onPayClickHandle),1);

    self.btn_left.logic = self;
    self.btn_left:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onLeftClickHandle),1);
    self.btn_right.logic = self;
    self.btn_right:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onRightClickHandle),1);


   self.getRewardResultCallBack = function(event)
        self:refreshUI();
   end;

   TFDirector:addMEGlobalListener(PayManager.GET_VIP_REWARD_RESULT ,self.getRewardResultCallBack ) ;

    self.updateRewardListCallBack = function(event)
        self:loadRewardListData(event.data[1]);
    end;
    TFDirector:addMEGlobalListener(PayManager.updateVipRewardList ,self.updateRewardListCallBack ) ;

    self.richText:addMEListener(TFRICHTEXT_CLICK,function(sender, nID, szName, szVal)
        if szName == "gobuy" then
            
        elseif szName == "detail" then
            local pos = self.clickHelper:getTouchEndPos()
            pos = self.panel_list:convertToNodeSpace(pos)
            self:showDetailNode(true,nID,pos)
        end
    end);
    self.btn_free:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onGetReardClickHandle),1);
    self.updateTimerID = TFDirector:addTimer(50, -1, nil, 
    function()
        self:tableScroll()
    end)
end

function VipLayer:tableScroll()
    local posY = self.sv_vipinfo:getContentOffset().y
    if posY >= 0 then
        self.img_hide1:setVisible(false)
    else
        self.img_hide1:setVisible(true)
    end
    local minPosY = self.sv_vipinfo:getSize().height-self.sv_vipinfo:getInnerContainerSize().height
    if posY <= minPosY then
        self.img_hide2:setVisible(false)
    else
        self.img_hide2:setVisible(true)
    end
end

function VipLayer:removeEvents()
    TFDirector:removeMEGlobalListener(PayManager.GET_VIP_REWARD_RESULT ,self.getRewardResultCallBack);
    TFDirector:removeMEGlobalListener(PayManager.updateVipRewardList ,self.updateRewardListCallBack);
    if self.updateTimerID then
        TFDirector:removeTimer(self.updateTimerID)
        self.updateTimerID = nil
    end 
end

return VipLayer;
