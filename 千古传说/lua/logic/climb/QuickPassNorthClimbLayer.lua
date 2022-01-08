local QuickPassNorthClimbLayer = class("QuickPassNorthClimbLayer", BaseLayer);

QuickPassNorthClimbLayer.LIST_ITEM_HEIGHT = 140; 

CREATE_SCENE_FUN(QuickPassNorthClimbLayer);
CREATE_PANEL_FUN(QuickPassNorthClimbLayer);

--[[
******扫荡N次-奖励说明弹窗*******

    -- by haidong.gan
    -- 2013/12/27
]]

function QuickPassNorthClimbLayer:ctor(data)
    self.super.ctor(self,data);
    
    self:init("lua.uiconfig_mango_new.mission.QuickPassReslutListLayer");
end

function QuickPassNorthClimbLayer:initUI(ui)
    self.super.initUI(self,ui);
    self.btn_close      = TFDirector:getChildByPath(ui, 'btn_close');
    self.panel_tiaoguo      = TFDirector:getChildByPath(ui, 'panel_tiaoguo');
    self.panel_content      = TFDirector:getChildByPath(ui, 'panel_content');
    self.img_tiaoguo      = TFDirector:getChildByPath(ui, 'img_tiaoguo');

    self.bg_table       = TFDirector:getChildByPath(ui, 'panel_list');
    self.bg_table_sum   = TFDirector:getChildByPath(ui, 'panel_all');
    self.img_card       = TFDirector:getChildByPath(ui, 'img_card');
    self.img_bg2       = TFDirector:getChildByPath(ui, 'img_bg2');
    self.lb_tuandui       = TFDirector:getChildByPath(ui, 'lb_tuandui');

    self.bg_mubiao      = TFDirector:getChildByPath(ui, 'bg_mubiao');
    self.mubiaoname     = TFDirector:getChildByPath(self.bg_mubiao, 'txt_name');
    self.mubiaoNum      = TFDirector:getChildByPath(self.bg_mubiao, 'LabelBMFont_QuickPassNorthClimbLayer_1')
    self.bg_iconbg      = TFDirector:getChildByPath(self.bg_mubiao, 'bg_icon')
    self.bg_icon        = TFDirector:getChildByPath(self.bg_mubiao, 'img_icon')
    self.bg_mubiao:setVisible(false)

    self.lb_tuandui:setZOrder(3);
    local list_reward = TFScrollView:create()
    list_reward:setPosition(ccp(0,0))
    list_reward:setBackGroundColorType(TF_LAYOUT_COLOR_NONE)
    list_reward:setSize(self.bg_table:getSize())
    list_reward:setBounceEnabled(true);
    self.bg_table:addChild(list_reward)
    self.list_reward = list_reward;
    Public:bindScrollFun(self.list_reward);

    local list_totol = TFScrollView:create()
    list_totol:setPosition(ccp(0,0))
    list_totol:setBackGroundColorType(TF_LAYOUT_COLOR_NONE)
    list_totol:setSize(self.bg_table_sum:getSize())
    list_totol:setBounceEnabled(true);
    self.bg_table_sum:addChild(list_totol)
    self.list_totol = list_totol;
    Public:bindScrollFun(self.list_totol);

    --强制打开跳过控件
    self.panel_tiaoguo:setVisible(true)
end

function QuickPassNorthClimbLayer:loadData(data)
    self.itemlist = data
    self:refreshUI();
end


function QuickPassNorthClimbLayer:onShow()
    self.super.onShow(self)
    self:refreshBaseUI();
end

function QuickPassNorthClimbLayer:refreshBaseUI()

end
function QuickPassNorthClimbLayer:refreshUI()
    -- if not self.isShow then
    --     return;
    -- end

    self:loadRewardList()
    self:loadTotolList()

    local minLevel = self.itemlist[1].oldLevel;
    local maxLevel = self.itemlist[#self.itemlist].currentLevel;

    local txt_addExp = TFDirector:getChildByPath(self, 'txt_addExp');
    txt_addExp:setText(self.expSum);

    local txt_addLevel = TFDirector:getChildByPath(self, 'txt_addLevel');
    if maxLevel > minLevel then
        txt_addLevel:setText("(LV".. minLevel .. "-LV" .. maxLevel .. ")");
        txt_addLevel:setVisible(true);
    else
        txt_addLevel:setVisible(false);
    end
end

function QuickPassNorthClimbLayer:loadTotolList()
    self.list_totol:getInnerContainer():stopAllActions();
    self.list_totol:removeAllChildren();

    local expSum = 0;
    local coinSum = 0;

    local rewardList = TFArray:new();
    for i,reslutItem in ipairs(self.itemlist) do

       expSum = expSum + reslutItem.exp;
       coinSum = coinSum + reslutItem.coin;
       if reslutItem.item then
           for i,rewardItem in pairs(reslutItem.item) do
               local hasIn = false;
               for item in rewardList:iterator() do

                   if item.itemId == rewardItem.itemId then
                       item.number = item.number + rewardItem.number;
                       hasIn = true;
                       break;
                   end
               end

               if not hasIn then
                   rewardList:push(rewardItem);
               end
           end
       end
    end

    if coinSum ~= 0 then
        rewardList:pushBack({type = EnumDropType.COIN,number = coinSum});
    end

    self.expSum = expSum;
    self.coinSum = coinSum;
    self.rewardList = expSum;

    local length = math.max(rewardList:length(),12);
    local row = math.ceil(length / 3);

    local reward_item = nil;

    for i=1,length do
        local index_x = i % 3;
        if index_x == 0 then
            index_x = 3 ;
        end
        local index_y = math.ceil(i / 3);


        local reward = rewardList:objectAt(i);
        if reward then
            local rewardInfo = BaseDataManager:getReward(reward)
            reward_item =  Public:createIconNumNode(rewardInfo);
            reward_item:setScale(0.5);
            reward_item:setPosition(ccp(13 + (index_x - 1)*70, (row - index_y) * 75  ));

            --秘籍红点
            CommonManager:setRedPoint(reward_item, MartialManager:dropRewardRedPoint(rewardInfo), "dropRewardRedPoint", ccp(80,80))
        else
            reward_item = TFImage:create("ui_new/mission/img_bg_cell.png")
            reward_item:setAnchorPoint(ccp(0,0));
            reward_item:setPosition(ccp(3 + (index_x - 1)*70, (row - index_y) * 75));
        end
        self.list_totol:addChild(reward_item);
    end

    self.list_totol:setInnerContainerSize(CCSizeMake(self.list_totol:getSize().width , row * 75))
    self.list_totol:setInnerContainerSizeForHeight(row * 75 )
    self.list_reward:scrollToYTop(0);

    --quanhuan add 2015-9-16 16:00:40
    local book_id,book_num = MissionManager:quickPassGoodIdGet()
    print("book_id = ",book_id)
    print("book_num = ",book_num)
    if book_id then
        local totalnum = BagManager:getItemNumById( book_id )
        local mubiaoItem = {type = EnumDropType.GOODS,number = 1,itemId = book_id}
        local rewardInfo = BaseDataManager:getReward(mubiaoItem)  
        self.bg_mubiao:setVisible(true)
        self.mubiaoname:setText(rewardInfo.name)
        self.bg_iconbg:setTextureNormal(GetColorIconByQuality_118(rewardInfo.quality))
        self.bg_icon:setTexture(rewardInfo.path)
        Public:addPieceImg(self.bg_icon,rewardInfo);
        self.mubiaoNum:setText(totalnum.."/"..book_num)
    else
        self.bg_mubiao:setVisible(false)
    end
end

function QuickPassNorthClimbLayer:loadRewardList()

    self.list_reward:getInnerContainer():stopAllActions();
    self.list_reward:removeAllChildren();

    local reslut_nodeArr = {}
    self.reslut_nodeArr = reslut_nodeArr;

    for index,reslutItem in pairs(self.itemlist) do
        local reslut_node = createUIByLuaNew("lua.uiconfig_mango_new.mission.QuickPassReslutItem");
        self:loadRewardNode(reslut_node,reslutItem,index)
        reslut_node:setPosition(ccp(0,(#self.itemlist - index) * QuickPassNorthClimbLayer.LIST_ITEM_HEIGHT))
        self.list_reward:addChild(reslut_node)
        reslut_node:setVisible(false);
        reslut_nodeArr[index] = reslut_node;
    end

    self.list_reward:setInnerContainerSize(CCSizeMake(self.list_reward:getSize().width , #self.itemlist * QuickPassNorthClimbLayer.LIST_ITEM_HEIGHT + 20))
    self.list_reward:scrollToYTop(0);
    self.list_reward:setInnerContainerSizeForHeight(#self.itemlist * QuickPassNorthClimbLayer.LIST_ITEM_HEIGHT + 20)

    local index = 1;
    self.change = function()
    
        reslut_nodeArr[index]:setVisible(true);
        for k,v in pairs(reslut_nodeArr[index].reward_itemArr) do
            v:setVisible(false);
        end
        play_hechenghecheng()
        local rewardIndex = 1;
        
        self.changeRewardNode = function ()
            local reward_item = reslut_nodeArr[index].reward_itemArr[rewardIndex];
            reward_item:setVisible(true);
            play_hechengbaoshiqianru();
            reward_item:setAlpha(0);

            local toastTween = {
                  target = reward_item,
                  {
                    duration = 0,
                    alpha = 0.5,
                  },
                  {
                     duration = 0.2,
                     alpha = 1,
                     scale = 0.5,
                  },
                  {
                    duration = 0,
                    onComplete = function()
                        if self.isSkip then
                            return
                        end
                        if rewardIndex < #reslut_nodeArr[index].reward_itemArr then
                            rewardIndex = rewardIndex + 1;
                            self.changeRewardNode();
                        else
                            if index == 1 then
                                self.list_reward:scrollToCenterForPositionY(reslut_nodeArr[index]:getPosition().y - 30, 0)
                            else
                                self.list_reward:scrollToCenterForPositionY(reslut_nodeArr[index]:getPosition().y - 30, 0.2)
                            end
                            index = index + 1;

                            if index <= #self.itemlist then
                                 if self.reardTimeId then
                                    TFDirector:removeTimer(self.reardTimeId);
                                    self.reardTimeId = nil
                                end

                                self.reardTimeId = TFDirector:addTimer(750, 1 , nil, self.change);
                            else
                                print("<<<<<<<<<<<<<<<<<<<<<<onSumComplete")
                                self:onSumComplete();
                                --结算完成
                                self.img_card:setVisible(false);
                                if self.endingeffect ==nil then
                                    local resPath = "effect/mission_quick_sum_ending.xml"
                                    TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
                                    local endingeffect = TFArmature:create("mission_quick_sum_ending_anim")

                                    endingeffect:setAnimationFps(GameConfig.ANIM_FPS)
                                    -- endingeffect:setPosition(ccp(self:getSize().width/2,self:getSize().height/2))
                                    endingeffect:setPosition(ccp( -62,237))
                                    -- self.img_card:getParent():addChild(endingeffect,1)
                                    self.img_bg2:addChild(endingeffect,100)

                                    endingeffect:addMEListener(TFARMATURE_COMPLETE,function()
                                        play_saodangjiesuan()

                                        endingeffect:removeMEListener(TFARMATURE_COMPLETE) 
                                        -- endingeffect:removeFromParent()
                                        -- self.endingeffect = nil;

                                        local resPath = "effect/mission_quick_sum_end.xml"
                                        TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
                                        local endeffect = TFArmature:create("mission_quick_sum_end_anim")

                                        endeffect:setAnimationFps(GameConfig.ANIM_FPS)
                                        endeffect:setPosition(ccp(self:getSize().width/2 ,self:getSize().height/2 + 40))

                                        self:addChild(endeffect,2)
                                        endeffect:playByIndex(0, -1, -1, 1)
                                        self.panel_tiaoguo:setVisible(false);
                                        self.img_tiaoguo:setTexture("ui_new/role/btn_click_close.png");
                                    end)
                                    self.endingeffect = endingeffect;
                                end
                                self.endingeffect:playByIndex(0, -1, -1, 0)
                            end
                        end
                    end
                  }
                }

            TFDirector:toTween(toastTween);
        end

        self.changeRewardNode();
        -- local oldOffset = self.list_reward:getContentOffset();
        -- local newOffset = ccp(oldOffset.x,oldOffset.y + QuickPassNorthClimbLayer.LIST_ITEM_HEIGHT);
        -- -- self.list_reward:setContentOffset(newOffset,0.5);
    end

    -- function changeCom()
        
    -- end
    self.list_reward:scrollToCenterForPositionY(reslut_nodeArr[1]:getPosition().y - 30, 0)
    self.change();

    local resPath = "effect/mission_quick_suming.xml"
    TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
    local sumingeffect = TFArmature:create("mission_quick_suming_anim")

    sumingeffect:setAnimationFps(GameConfig.ANIM_FPS)
    sumingeffect:setPosition(ccp(self.img_card:getSize().width/2 - 177 ,self.img_card:getSize().height/2+38))

    self.img_card:addChild(sumingeffect,2)

    sumingeffect:addMEListener(TFARMATURE_COMPLETE,function()
        sumingeffect:removeMEListener(TFARMATURE_COMPLETE) 
        sumingeffect:removeFromParent()
        self.sumingeffect = nil;
    end)

    sumingeffect:playByIndex(0, -1, -1, 1)
    self.sumingeffect = sumingeffect;
    -- TFDirector:removeTimer(self.reardTimeId);
    -- print(#self.itemlist)
    -- self.reardTimeId = TFDirector:addTimer(1000, #self.itemlist -1 , changeCom, change);
end

--添加玩家节点
function QuickPassNorthClimbLayer:loadRewardNode(reslut_node,reslutItem,index)
    local txt_index = TFDirector:getChildByPath(reslut_node, 'txt_index');
    --txt_index:setText("第" .. index .. "战");
    txt_index:setText(stringUtils.format(localizable.common_index_fight,index));

    local txt_addExp = TFDirector:getChildByPath(reslut_node, 'txt_addExp');
    txt_addExp:setText(reslutItem.exp);

    local txt_addLevel = TFDirector:getChildByPath(reslut_node, 'txt_addLevel');
    if reslutItem.currentLevel > reslutItem.oldLevel then
        txt_addLevel:setText("(LV".. reslutItem.oldLevel .. "-LV" .. reslutItem.currentLevel .. ")");
        txt_addLevel:setVisible(true);
    else
        txt_addLevel:setVisible(false);
    end

    local scrollViewUI = TFDirector:getChildByPath(reslut_node, 'panel_list')

    local scrollView = TFScrollView:create()
    scrollView:setPosition(ccp(0,0))
    scrollView:setBackGroundColorType(TF_LAYOUT_COLOR_NONE)
    scrollView:setDirection(SCROLLVIEW_DIR_HORIZONTAL)
    scrollView:setSize(scrollViewUI:getSize())
    scrollView:setBounceEnabled(true)
    scrollView:setInnerContainerSize(scrollViewUI:getSize())
    scrollViewUI:addChild(scrollView)

    local reward_itemArr = {}

    local posX = 0
    if reslutItem.item then
        for index,reward in pairs(reslutItem.item) do
            local rewardInfo = BaseDataManager:getReward(reward)
            print("rewardInfo == ",rewardInfo)
            local reward_item =  Public:createIconNumNode(rewardInfo);
            reward_item:setScale(1.5);
            posX = 10 + (index -1)*70
            reward_item:setPosition(ccp(posX, 0));
            -- reslut_node:addChild(reward_item);
            reward_itemArr[index] = reward_item;
            scrollView:addChild(reward_item)

            -- print("reward = ", reward)
            -- print("setRedPoint = ", MartialManager:dropRewardRedPoint(reward))
            --秘籍添加红点 king
            CommonManager:setRedPoint(reward_item, MartialManager:dropRewardRedPoint(rewardInfo), "dropRewardRedPoint", ccp(80,80))
        end
    end
    if reslutItem.coin ~= 0 then
        local reward_item =  Public:createIconNumNode(BaseDataManager:getReward({type = EnumDropType.COIN,number = reslutItem.coin}));
        reward_item:setScale(1.5);
        posX = 10 + (#reward_itemArr)*70
        reward_item:setPosition(ccp(posX, 0));
        -- reslut_node:addChild(reward_item);
        scrollView:addChild(reward_item)
        reward_itemArr[#reward_itemArr + 1] = reward_item;
    end
    reslut_node.reward_itemArr = reward_itemArr;
    if #reward_itemArr > 5 then
        scrollView:setInnerContainerSize(CCSizeMake(10+(#reward_itemArr)*70, scrollViewUI:getSize().height))        
    end
    
end

function QuickPassNorthClimbLayer:removeUI()
    self.super.removeUI(self);
    TFDirector:removeTimer(self.reardTimeId);
end

function QuickPassNorthClimbLayer.onSkipClickHandle(sender)
    local self = sender.logic;

    if self.isSkip then
        return false;
    end
    self.panel_tiaoguo:setVisible(false);
    self.img_tiaoguo:setTexture("ui_new/role/btn_click_close.png");

    self.isSkip = true;
    if self.reardTimeId then
        TFDirector:removeTimer(self.reardTimeId)
    end
    if self.sumingeffect then
        self.sumingeffect:removeFromParent();
        self.sumingeffect = nil;
    end
    if self.endingeffect then
        self.endingeffect:removeFromParent();
        self.endingeffect = nil;
    end

    if not self.endeffect then
        local resPath = "effect/mission_quick_sum_end.xml"
        TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
        local endeffect = TFArmature:create("mission_quick_sum_end_anim")

        endeffect:setAnimationFps(GameConfig.ANIM_FPS)
        endeffect:setPosition(ccp(self:getSize().width/2 ,self:getSize().height/2 + 40))

        self:addChild(endeffect,2)
        endeffect:playByIndex(0, -1, -1, 1)
        self.endeffect = endeffect;
    end

    for index,reslut_node in pairs(self.reslut_nodeArr) do
        reslut_node:setVisible(true);
        for k,v in pairs(reslut_node.reward_itemArr) do
            v:setVisible(true);
            v:setScale(0.5);
        end
    end
    self.img_card:setVisible(false);
    self:onSumComplete();
end

function QuickPassNorthClimbLayer:onSumComplete()
    local des = MissionManager.attackDes;

    if des and  des ~= "" then
        toastMessage(des);
    end
end
function QuickPassNorthClimbLayer:registerEvents()
    self.super.registerEvents(self)
    ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)
    self.btn_close:setClickAreaLength(100);

    self.panel_tiaoguo.logic = self;
    self.panel_tiaoguo:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onSkipClickHandle),1);

end

function QuickPassNorthClimbLayer:removeEvents()
    self.panel_tiaoguo:removeMEListener(TFWIDGET_CLICK)
    self.isSkip = false
    self.super.removeEvents(self)
end

return QuickPassNorthClimbLayer;
