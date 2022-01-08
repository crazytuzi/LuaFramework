--[[
******PVE推图-关卡*******

    -- by haidong.gan
    -- 2013/11/27

    -- modify by king
    -- 2014/08/15
]]
local BloodybattleMainLayer = class("BloodybattleMainLayer", BaseLayer);

CREATE_SCENE_FUN(BloodybattleMainLayer);
CREATE_PANEL_FUN(BloodybattleMainLayer);

BloodybattleMainLayer.LIST_ITEM_WIDTH = 200;

function BloodybattleMainLayer:ctor(missionId)
    self.super.ctor(self,toMission);
    self.missionId = missionId;

    self:init("lua.uiconfig_mango_new.bloodybattle.BloodybattleMainLayer");
end

function BloodybattleMainLayer:initUI(ui)
    self.super.initUI(self,ui);

    self.mapId = 22

    self.addMapTimer = {}
    self.addMissionTimer = {}

    self.penel_block     = TFDirector:getChildByPath(ui, 'penel_block')

    self.generalHead = CommonManager:addGeneralHead( self )

    self.generalHead:setData(ModuleType.Bloodybattle,{HeadResType.COIN,HeadResType.SYCEE,HeadResType.PUSH_MAP})

    self.panel_list         = TFDirector:getChildByPath(ui, 'panel_list')

    self.btn_left           = TFDirector:getChildByPath(ui, 'btn_pageleft')
    self.btn_right          = TFDirector:getChildByPath(ui, 'btn_pageright')
    self.positiony          = self.btn_right:getPosition().y;
    self.btn_rule           = TFDirector:getChildByPath(ui, 'btn_rule')
    self.txt_inspireNum     = TFDirector:getChildByPath(ui, 'txt_inspireNum')

    self.btn_shaodang       = TFDirector:getChildByPath(ui, 'btn_shaodang')


    local pageView = TPageView:create()
    self.pageView = pageView

    pageView:setBounceEnabled(false)
    pageView:setTouchEnabled(true)
    pageView:setBackGroundColorType(TF_LAYOUT_COLOR_NONE)
    pageView:setSize(self.panel_list:getContentSize())
    pageView:setPosition(self.panel_list:getPosition())
    pageView:setAnchorPoint(self.panel_list:getAnchorPoint())

    local function onPageChange()
        self:onPageChange();
    end
    pageView:setChangeFunc(onPageChange)

    local function itemAdd(index)
        return  self:addPage(index);
    end
    pageView:setAddFunc(itemAdd)

    self.panel_list:addChild(pageView,2);

  
    if self.missionId then
    else

        self.selectDifficulty = 1;

        self.selectIndex = BloodFightManager:getCurMapIndex()
    end

    self:refreshMissionList(self.selectIndex);


    self:setGuideBlockViisble(false)


    --鼓舞相关
    self.txt_guwu1     = TFDirector:getChildByPath(ui, 'txt_guwu1');
    self.txt_times     = TFDirector:getChildByPath(ui, 'txt_times');
    self.txt_guwu2     = TFDirector:getChildByPath(ui, 'txt_guwu2');
    self.txt_effect    = TFDirector:getChildByPath(ui, 'txt_effect');

    self.inspireBtnList = {}
    for i=1,2 do
        self.inspireBtnList[i] = {}
        self.inspireBtnList[i].btn_inspire  = TFDirector:getChildByPath(ui, 'btn_inspire'..i);
        self.inspireBtnList[i].img_money    = TFDirector:getChildByPath(ui, 'img_money'..i);
        self.inspireBtnList[i].txt_num      = TFDirector:getChildByPath(ui, 'txt_num'..i);
        self.inspireBtnList[i].txt_effect   = TFDirector:getChildByPath(ui, 'txt_effect'..i);

        self.inspireBtnList[i].btn_inspire.logic = self
        self.inspireBtnList[i].btn_inspire.tag   = i
        self.inspireBtnList[i].btn_inspire:addMEListener(TFWIDGET_CLICK,audioClickfun(self.onBtnInspireClickHandle))
    end


    -- t_s_bloody_inspire_config
    -- self.inspireList1   = TFArray:new()
    -- self.inspireList2   = TFArray:new()

    -- -- local inspireList = require("lua.table.t_s_bloody_inspire_config")
    -- local inspireList = BloodFightManager.inspireList

    -- -- { id = 1, inspire_count = 1, need_res_type = 3, need_res_num = 100, add_attribute_percent = 30, need_vip_level = 1}
    -- for v in inspireList:iterator() do
    --     if EnumDropType.COIN == v.need_res_type  then
    --         self.inspireList1:push(v)
    --     elseif EnumDropType.SYCEE == v.need_res_type  then
    --         self.inspireList2:push(v)
    --     end
    -- end
    
    -- -- 比较函数
    -- local function sortlist( v1,v2 )
    --     if v1.id < v2.id then
    --         return true
    --     end
    --     return false
    -- end

    -- self.inspireList1:sort(sortlist)
    -- self.inspireList2:sort(sortlist)

    -- --进入血战
    -- BloodFightManager:PlayerEnterBloodFighting()

    self.inspireList1 = BloodFightManager.inspireList1
    self.inspireList2 = BloodFightManager.inspireList2

    --重置
    self.btn_reset = TFDirector:getChildByPath(ui, 'btn_reset')
    self.bg_reset = TFDirector:getChildByPath(ui,'bg_times')
    self.txt_remain_reset_count = TFDirector:getChildByPath(self.bg_reset, 'txt_times')
end

function BloodybattleMainLayer:setGuideBlockViisble(isVisible)
    self.penel_block:setVisible(isVisible);
    if self.pageView.setScrollEnabled then
        self.pageView:setScrollEnabled(not isVisible);
    end
    if isVisible then
        self.btn_left:setColor(ccc3(166, 166, 166));
        self.btn_right:setColor(ccc3(166, 166, 166));
    else
        self.btn_left:setColor(ccc3(255, 255, 255));
        self.btn_right:setColor(ccc3(255, 255, 255));
    end
end

function BloodybattleMainLayer:removeUI()
    self.super.removeUI(self)

    for k,v in pairs(self.addMapTimer) do
        TFDirector:removeTimer(v)
    end
    for k,v in pairs(self.addMissionTimer) do
        TFDirector:removeTimer(v)
    end

    --进入血战
    BloodFightManager:PlayerExitBloodFighting()
end

function BloodybattleMainLayer:dispose()
    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end

    self.super.dispose(self)
end

function BloodybattleMainLayer:onShow()
    self.super.onShow(self)
    self.generalHead:onShow();
    --进入血战
    BloodFightManager:PlayerEnterBloodFighting()

    self:refreshBaseUI();
    self:refreshUI();

    self:drawInspire()
    self:drawResetInfo()

    self:refreshSaoDangBtn()
end

function BloodybattleMainLayer:refreshBaseUI()

end

function BloodybattleMainLayer:refreshUI()
    if not self.isShow then
        return;
    end
end

function BloodybattleMainLayer:showInfoForPage(pageIndex)

    local pageCount = BloodFightManager:getMapNum()

    self.btn_left:setPosition(ccp(self.btn_left:getPosition().x,1000));
    self.btn_right:setPosition(ccp(self.btn_right:getPosition().x,1000));

    if pageIndex < pageCount and pageCount > 1 then
        self.btn_right:setPosition(ccp(self.btn_right:getPosition().x,self.positiony));
    end

    if pageIndex > 1 and pageCount > 1  then
        self.btn_left:setPosition(ccp(self.btn_left:getPosition().x,self.positiony));
    end
end

function BloodybattleMainLayer:onPageChange()
    local pageIndex = self.pageView:_getCurPageIndex() ;
    self:showInfoForPage(pageIndex);
end

function BloodybattleMainLayer:refreshMissionList(pageIndex)
    self.pageView:_removeAllPages();

    self.pageView:setMaxLength(BloodFightManager:getMapNum())

    self.missionNodeList = {};
    self.boxNodeList = {};
    self.pageList        = {};


    self:showInfoForPage(pageIndex);

    self.pageView:InitIndex(pageIndex);
end


function BloodybattleMainLayer:addPage(pageIndex)
    local pagepanel = TFPanel:create();

    -- local map               = MissionManager:getMapList():objectAt(pageIndex);
    local map               = MissionManager:getMapList():objectAt(self.mapId);
    local missionlist       = MissionManager:getMissionListByMapId(map.id);
    local curMissionlist    = missionlist[self.selectDifficulty];
    local page = nil;

    local startIndex        = 1 + (pageIndex - 1) * 10
    local endIndex          = startIndex + 9

    local function addMap()
        page = createUIByLuaNew("lua.uiconfig_mango_new.bloodybattle.BloodyMapItem");
        page:setSize(self.panel_list:getContentSize())
        pagepanel:addChild(page);

        local img_map = TFDirector:getChildByPath(page, 'img_map');
        img_map:setTexture("bg_jpg/" .. map.map_img .. ".jpg");

        local battlePoint = TFImage:create("bg_jpg/battlepoint/" .. map.point_imp .. ".png")
        battlePoint:setAnchorPoint(CCPointMake(0.5,0.5))
        battlePoint:setPosition(CCPointMake(0,0))
        img_map:addChild(battlePoint)
    end

    if pageIndex ~= self.selectIndex then

        local index = 1;
        local function onOnceCom()
            self:addMissionNode(page, index + (pageIndex - 1) *  10);
            index = index + 1;
        end

        self.addMapTimer[pageIndex] = TFDirector:addTimer(0.5, 1, addMap, function ()
            local length = 10;
            self.addMissionTimer[pageIndex] = TFDirector:addTimer(0.1, length, nil, onOnceCom);
        end);

    else
        addMap();
        --添加关卡
        -- for mission in curMissionlist:iterator()  do
        -- self:addMissionNode(page,mission.id);
        -- end
        for i=startIndex,endIndex do
            self:addMissionNode(page,i);
        end

        -- TFDirector:addTimer(0.0001, 1, onCom, nil);
    end
    self.pageList[pageIndex] = pagepanel;

    return pagepanel;
end

--添加关卡节点
function BloodybattleMainLayer:addMissionNode(page,missionId)
    -- print("missionId = ", missionId)
    local info  = BloodFightManager:getInfo(missionId)
    local type  = info.type
    local index = info.index

    -- print("missionId = ",missionId)
    if type == BloodFightManager.PLAYER_TYPE then
        -- print("这是一个玩家")
        self:drawMissionNode(page, BloodFightManager:getPlayer(index), missionId)
        return
    elseif type == BloodFightManager.BOX_TYPE then
        -- print("这是一个宝箱")
        self:drawBoxNode(page, BloodFightManager:getBox(index), missionId)
        return
    end

end

function BloodybattleMainLayer:getArmatureByImage(image)
    local resID = image
    local resPath = "armature/"..resID..".xml"
    if not TFFileUtil:existFile(resPath) then
        resID = 10006
        resPath = "armature/"..resID..".xml"
    end

    TFResourceHelper:instance():addArmatureFromJsonFile(resPath)

    -- print("resID:",resID)
    local armature = TFArmature:create(resID.."_anim")
    if armature == nil then
        return nil
    end
    armature:play("stand", -1, -1, 1)
    armature:setScale(0.6)
    return armature
end

--删除节点
function BloodybattleMainLayer:removeMissionNode(missionId)
    local mission_node = self.missionNodeList[missionId];
    if mission_node then
        print("missionId = ", missionId)
        mission_node:removeFromParentAndCleanup(true);
        self.missionNodeList[missionId] = nil;
    end
end

function BloodybattleMainLayer.onLeftClickHandle(sender)
    local self = sender.logic;
    local pageIndex = self.pageView:getCurPageIndex();
    self.pageView:scrollToPage(pageIndex - 1);
end

function BloodybattleMainLayer.onRightClickHandle(sender)
    local self = sender.logic;
    local pageIndex = self.pageView:getCurPageIndex();

    local openMapNum = BloodFightManager:getCurMapIndex()

    -- -- print("pageIndex = ",pageIndex)
    -- -- print("openMapNum = ",openMapNum)
    -- if openMapNum <= (pageIndex + 1) then
    --     toastMessage("请先通过")
    --     return
    -- end
    -- -- ASD  = da  + 1
    self.pageView:scrollToPage(pageIndex + 1);
end


function BloodybattleMainLayer.onBtnAttackClickHandle(sender)
    
    -- BloodFightManager:openRoleList()
    local self = sender.logic;
    local missionIndex = sender:getTag();

    self:setGuideBlockViisble(false)

    local player = BloodFightManager:getPlayer(missionIndex)
    local status = BloodFightManager:getPlayerStaus(player.index);

    if status == BloodFightManager.PLAYER_LOCK then
        local needAttackPlayer = BloodFightManager:getPlayer(BloodFightManager:getMissionIndex())
        local msg = stringUtils.format(localizable.bloodBattleMainLayer_please_fight, needAttackPlayer.name)
        toastMessage(msg)
        return
    else
        -- BloodFightManager:lookPlayerInfo(player.playerId)
        BloodFightManager:QueryBloodyEnemyInfo(player.index)
    end

    -- toastMessage("查看信息")
end

function BloodybattleMainLayer.onBtnBoxClickHandle(sender)
    local self      = sender.logic;
    local boxIndex  = sender.index
    local type      = sender.type
    
    -- print("点击了箱子----", boxIndex)

    if type == 0 then
        toastMessage(localizable.bloodBattleMainLayer_box_tips)
    else
        BloodFightManager:showBoxLayer(boxIndex)
    end

    -- local box = BloodFightManager.boxList[boxIndex]
    -- print("box = ", box)
    -- box.got = 3
    -- if box.got == 3 then
    --     local layer = AlertManager:addLayerByFile("lua.logic.bloodFight.BloodReward.lua",AlertManager.BLOCK_AND_GRAY)--,AlertManager.TWEEN_1);
    --     layer:loadBoxData(boxIndex, box.data);
    -- elseif box.got == 1 or box.got == 2 then
    --     local layer = AlertManager:addLayerByFile("lua.logic.bloodFight.BloodRewardBuy.lua",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1);
    --     layer:loadBoxData(boxIndex, box.data);
    -- end

    -- AlertManager:show();
end



function BloodybattleMainLayer.OnRuleClickHandle(sender)
    -- local layer = AlertManager:addLayerByFile("lua.logic.bloodFight.BloodRuleLayer", AlertManager.BLOCK_AND_GRAY_CLOSE)
    -- local winSize =  GameConfig.WS
    -- layer:setPosition(ccp(winSize.width/2, winSize.height/2))
    -- AlertManager:show()
    CommonManager:showRuleLyaer('yanmenguanguize')
end

function BloodybattleMainLayer:onAttackCompeleteHandle(event)
    local lastSection   = event.data[1].last
    local nowSection    = event.data[1].now

    print("BloodybattleMainLayer:onAttackCompeleteHandle = ", event.data)

    local pageIndex = math.ceil(lastSection/8)
    local player = BloodFightManager:getPlayer(lastSection)
    local index  = player.totalIndex

    print("pageIndex1 = ", pageIndex)
    --更新当前节点
    self:removeMissionNode(player.index);
    self:drawMissionNode(self.pageList[pageIndex], player, index)

    if nowSection < 25 then
        pageIndex = math.ceil(nowSection/8)
        print("pageIndex2 = ", pageIndex)
        player = BloodFightManager:getPlayer(nowSection)
        index  = player.totalIndex
        --更新当前节点
        self:removeMissionNode(player.index);
        self:drawMissionNode(self.pageList[pageIndex], player, index)
   end

end

function BloodybattleMainLayer:updateOnePageMission(pageIndex)

    print("BloodybattleMainLayer:updateOnePageMission = ", pageIndex)

    local beginIndex = (pageIndex - 1) * 8 + 1
    local endIndex = pageIndex * 8

    for i=beginIndex,endIndex do
        -- print("i = ", i)
        local player = BloodFightManager:getPlayer(i)
        local index  = player.totalIndex
        -- print("pageIndex = ", pageIndex)
        -- print("player = ", player)
        --更新当前节点
        self:removeMissionNode(player.index);
        self:drawMissionNode(self.pageList[pageIndex], player, index)
    end
end

function BloodybattleMainLayer:onGetBoxPrizeHandle(event)
    print("BloodybattleMainLayer:onGetBoxPrizeHandle = ", event.data)
    local boxIndex  = event.data[1].index
    local pageIndex = math.ceil(boxIndex/2)

    --删除节点
    local function removeBoxNode(boxIndex)
        local node = self.boxNodeList[boxIndex]
        if node then
            node:removeFromParentAndCleanup(true);
            self.boxNodeList[boxIndex] = nil;
        end
    end

    removeBoxNode(boxIndex)

    -- local missionId = (pageIndex - 1) * 10 + boxIndex * 5
    local missionId = boxIndex * 5

    print("pageIndex = "..pageIndex .. "  missionId = " .. missionId)
    self:drawBoxNode(self.pageList[pageIndex], BloodFightManager:getBox(boxIndex), missionId)
end

function BloodybattleMainLayer.onBtnInspireClickHandle(sender)
    local self = sender.logic
    local tag  = sender.tag

    local function showVipDiag(openVip, times)
        CommonManager:showOperateSureLayer(
            function()
                PayManager:showPayLayer();
            end,
            nil,
            {
                title       = localizable.bloodBattleMainLayer_up_vip,
                msg         = stringUtils.format(localizable.bloodBattleMainLayer_up_count,openVip,times),
                uiconfig    = "lua.uiconfig_mango_new.common.NeedTpPayLayer"
            }
        )
    end

    -- if true then
    --     showVipDiag(1, 1)
    --     return
    -- end

    local inspireNumTotal       = BloodFightManager.coinInspireCount + BloodFightManager.sysceeInspireCount
    local inspireNumWithVip     = 1
 

    local benefit_value = 0
    local CurVip        = MainPlayer:getVipLevel()

    -- inspireNumTotal = 100
    -- CurVip          = 2

    local curVipInfo    = VipData:getVipItemByTypeAndVip(2050, CurVip)
    print("curVipInfo = ", curVipInfo)
    if curVipInfo then
        print("1111 = ", curVipInfo)
        benefit_value = curVipInfo.benefit_value
        if inspireNumTotal >= benefit_value then
            local nextVipInfo  = VipData:getVipNextAddValueVip(2050, CurVip)
            if nextVipInfo then
                showVipDiag(nextVipInfo.vip_level, nextVipInfo.benefit_value)
            else
                toastMessage(localizable.bloodBattleMainLayer_no_times)
            end
            return
        end
    -- else
    --     print("2222")
    --     local nextVipInfo  = VipData:getVipNextAddValueVip(2050, CurVip)
    --     if nextVipInfo then
    --         toastMessage("达到Vip"..nextVipInfo.vip_level.."每天可鼓舞"..nextVipInfo.benefit_value.."次")
    --         return
    --     end
    end

    -- if true then
    --     return
    -- end

    local num       = 0
    local inspire   = 0
    -- 铜币鼓舞
    if tag == 1 then
        -- 铜币鼓舞的次数
        local inspireListNum = self.inspireList1:length()
        local inspireNum     = BloodFightManager.coinInspireCount + 1

        if inspireNum > inspireListNum then
            inspireNum = inspireListNum
        end

        local coinInspireInfo1 = self.inspireList1:getObjectAt(inspireNum)
        num     = coinInspireInfo1.need_res_num
        inspire = coinInspireInfo1.add_attribute_percent
        
        -- 判断资源是否足够刷新
        if MainPlayer:isEnoughCoin(num, true) then
            BloodFightManager:inspireUpgrade(EnumDropType.COIN)
        end
        
    -- 元宝鼓舞
    elseif tag == 2 then

        -- 元宝鼓舞的次数
        inspireListNum = self.inspireList2:length()
        inspireNum     = BloodFightManager.sysceeInspireCount + 1

        if inspireNum > inspireListNum then
            inspireNum = inspireListNum
        end
        local coinInspireInfo2 = self.inspireList2:getObjectAt(inspireNum)
        num     = coinInspireInfo2.need_res_num
        inspire = coinInspireInfo2.add_attribute_percent

        
        if MainPlayer:isEnoughSycee(num, true) then
            BloodFightManager:inspireUpgrade(EnumDropType.SYCEE)
        end
    end

end

function BloodybattleMainLayer:drawInspire()
    -- 铜币鼓舞的次数
    local inspireListNum = self.inspireList1:length()
    local inspireNum     = BloodFightManager.coinInspireCount + 1

    if inspireNum > inspireListNum then
        inspireNum = inspireListNum
    end

    local coinInspireInfo1 = self.inspireList1:getObjectAt(inspireNum)

   
    -- 元宝鼓舞的次数
    inspireListNum = self.inspireList2:length()
    inspireNum     = BloodFightManager.sysceeInspireCount + 1

    if inspireNum > inspireListNum then
        inspireNum = inspireListNum
    end

    local coinInspireInfo2 = self.inspireList2:getObjectAt(inspireNum)

    for i=1,2 do
        local num       = 0
        local inspire   = 0
        if i == 1 then
            num     = coinInspireInfo1.need_res_num
            inspire = coinInspireInfo1.add_attribute_percent
        elseif i == 2 then
            num     = coinInspireInfo2.need_res_num
            inspire = coinInspireInfo2.add_attribute_percent
        end
        self.inspireBtnList[i].txt_num:setText(num)
        self.inspireBtnList[i].txt_effect:setText("+"..inspire.."%")
    end

    --总的鼓舞次数
    inspireNum = BloodFightManager.coinInspireCount + BloodFightManager.sysceeInspireCount
    self.txt_times:setText(inspireNum)

    --总的鼓舞效果
    -- { id = 1, inspire_count = 1, need_res_type = 3, need_res_num = 100, add_attribute_percent = 30, need_vip_level = 1}
    local totalEffect = 0
    for v in self.inspireList1:iterator() do
        if v.inspire_count <= BloodFightManager.coinInspireCount then --BloodFightManager.coinInspireCount
            totalEffect = totalEffect + v.add_attribute_percent
        end
    end
    
    for v in self.inspireList2:iterator() do
        if v.inspire_count <= BloodFightManager.sysceeInspireCount  then
            totalEffect = totalEffect + v.add_attribute_percent
        end
    end
    totalEffect = totalEffect + VipRuleManager:addInspireEffect()

    self.txt_effect:setText("+"..totalEffect.."%")

    local inspireRemainNum = 0
    -- self.txt_inspireNum
    local CurVip        = MainPlayer:getVipLevel()
    local curVipInfo    = VipData:getVipItemByTypeAndVip(2050, CurVip)
    if curVipInfo then
        local benefit_value = curVipInfo.benefit_value
        inspireRemainNum = benefit_value - inspireNum
        if inspireRemainNum < 0 then
            inspireRemainNum = 0
        end
    end
    self.txt_inspireNum:setText(inspireRemainNum)
end

--绘制重置信息
function BloodybattleMainLayer:drawResetInfo()
    local remainResetCount = BloodFightManager.remainResetCount
    print("remain reset count : ",remainResetCount)
    self.txt_remain_reset_count:setText(remainResetCount)
    if remainResetCount > 0 then
        self.btn_reset:setTouchEnabled(true)
        self.btn_reset:setGrayEnabled(false)
    else
        self.btn_reset:setTouchEnabled(false)
        self.btn_reset:setGrayEnabled(true)
    end
end

function BloodybattleMainLayer:resetNotify()
    self:drawResetInfo()
    self:refreshSaoDangBtn()
    self.selectIndex = BloodFightManager:getCurMapIndex()
    self:refreshMissionList(self.selectIndex);
end

function BloodybattleMainLayer.resetButtonClick(widget)
    local self = widget.logic

    local remainResetCount = BloodFightManager.remainResetCount

    local warningMsg = nil
    if BloodFightManager:getMissionIndex() < BloodFightManager:getMissionTotalCount() then
        warningMsg = localizable.bloodBattleMainLayer_reset
    else
        warningMsg = localizable.bloodBattleMainLayer_reset_tips
    end
    
    CommonManager:showOperateSureLayer(
            function()
                BloodFightManager:requestResetManual()
            end,
            nil,
            {
                msg = warningMsg
                -- msg =  "大侠，是否开始兑换？"
            }
    )
    -- BloodFightManager:requestResetManual()
end

--注册事件
function BloodybattleMainLayer:registerEvents()
    self.super.registerEvents(self);

    self.btn_left.logic = self;
    self.btn_left:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onLeftClickHandle),1);
    self.btn_right.logic = self;
    self.btn_right:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onRightClickHandle),1);
    self.btn_rule.logic = self;
    self.btn_rule:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.OnRuleClickHandle),1);
    self.btn_shaodang.logic = self;
    self.btn_shaodang:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.OnShaodangClickHandle),1);

    --重置按钮事件
    self.btn_reset.logic = self
    self.btn_reset:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.resetButtonClick),1);

    self.updateMissionCallBack = function(event)
        if BloodFightManager.showQuickPassLayer ~= true then
            self:onAttackCompeleteHandle(event);
            self:refreshUI(event);
            local pageIndex = self.pageView:_getCurPageIndex() ;
            self:showInfoForPage(pageIndex);
        end
    end;
    TFDirector:addMEGlobalListener(BloodFightManager.MSG_BATTLE_RESULT,self.updateMissionCallBack)

    self.updateBoxCallBack = function(event)
        if BloodFightManager.showQuickPassLayer ~= true then
            self:onGetBoxPrizeHandle(event);
            self:refreshUI(event);
            local pageIndex = self.pageView:_getCurPageIndex() ;
            self:showInfoForPage(pageIndex);
        end
    end;
    TFDirector:addMEGlobalListener(BloodFightManager.MSG_UPDATE_BOX,self.updateBoxCallBack ) ;

    self.updateUserDataCallBack = function(event)
        if BloodFightManager.showQuickPassLayer ~= true then
            self:refreshBaseUI();
        end
    end;
    TFDirector:addMEGlobalListener(MainPlayer.CoinChange ,self.updateUserDataCallBack ) ;
    TFDirector:addMEGlobalListener(MainPlayer.SyceeChange ,self.updateUserDataCallBack ) ;
    TFDirector:addMEGlobalListener(MainPlayer.ChallengeTimesChange ,self.updateUserDataCallBack ) ;

    self.section = 1
    self.openEnemyInfolayer = function(event)
        -- local layer     = event.data[1]
        -- -- local btn_army  = layer.btn_army
        -- local btn_buzhen  = layer.btn_buzhen


        -- local function enterStarge()
        --     -- BloodFightManager:openRoleList(layer.section)
        --     self.section = layer.section
        --     BloodFightManager:requestRoleList()
        -- end

        -- btn_buzhen:addMEListener(TFWIDGET_CLICK,  audioClickfun(enterStarge),1)

    end;

    TFDirector:addMEGlobalListener(BloodFightManager.LOOK_PLAYE_INFO, self.openEnemyInfolayer ) ;

    self.requestRoleList = function(event)
        -- BloodFightManager:openRoleList(self.section)
    end;

    TFDirector:addMEGlobalListener(BloodFightManager.MSG_REQUEST_ROLELIST_RESULT, self.requestRoleList)

    self.inspireUpdate = function(event)
        if BloodFightManager.showQuickPassLayer ~= true then
            toastMessage(localizable.bloodBattleMainLayer_up_success)
            self:drawInspire()
        end
    end
    TFDirector:addMEGlobalListener(BloodFightManager.MSG_INSPIRE_RESULT, self.inspireUpdate) ;

    self.updatePageMission = function(event)
        if BloodFightManager.showQuickPassLayer ~= true then
            local boxIndex  = event.data[1].mapIndex
            self:updateOnePageMission(boxIndex)
        end
    end
    TFDirector:addMEGlobalListener(BloodFightManager.MSG_UPDATE_PAGE_DATA, self.updatePageMission)


    self.bloodFightDailyResetEvent = function(event)
        if BloodFightManager.showQuickPassLayer ~= true then
            self:bloodFightDailyReset()
        end
    end
    TFDirector:addMEGlobalListener(BloodFightManager.MSG_DAILY_RESET, self.bloodFightDailyResetEvent)
    
    self.resetSuccessCallback = function(event)
        if BloodFightManager.showQuickPassLayer ~= true then
            self:drawInspire()
            self:resetNotify()
        end
    end
    TFDirector:addMEGlobalListener(BloodFightManager.MSG_RESET_MANUAL, self.resetSuccessCallback)

    if self.generalHead then
        self.generalHead:registerEvents()
    end
end

function BloodybattleMainLayer:removeEvents()
    self.super.removeEvents(self)

    TFDirector:removeMEGlobalListener(BloodFightManager.MSG_BATTLE_RESULT,self.updateMissionCallBack);
    self.updateMissionCallBack = nil;

    TFDirector:removeMEGlobalListener(BloodFightManager.MSG_UPDATE_BOX,self.updateBoxCallBack);
    self.updateBoxCallBack = nil;

    TFDirector:removeMEGlobalListener(BloodFightManager.MSG_INSPIRE_RESULT, self.inspireUpdate);
    self.inspireUpdate = nil;

    TFDirector:removeMEGlobalListener(BloodFightManager.LOOK_PLAYE_INFO, self.openEnemyInfolayer);
    self.openEnemyInfolayer = nil;

    -- 去掉打开角色布阵的消息
    TFDirector:removeMEGlobalListener(BloodFightManager.MSG_REQUEST_ROLELIST_RESULT, self.requestRoleList)
    self.requestRoleList = nil

    TFDirector:removeMEGlobalListener(BloodFightManager.MSG_UPDATE_PAGE_DATA, self.updatePageMission)
    self.updatePageMission = nil

    TFDirector:removeMEGlobalListener(BloodFightManager.MSG_DAILY_RESET, self.bloodFightDailyResetEvent)
    self.bloodFightDailyResetEvent = nil

    TFDirector:removeMEGlobalListener(MainPlayer.CoinChange ,self.updateUserDataCallBack);
    TFDirector:removeMEGlobalListener(MainPlayer.SyceeChange ,self.updateUserDataCallBack);
    TFDirector:removeMEGlobalListener(MainPlayer.ChallengeTimesChange ,self.updateUserDataCallBack ) ;

    TFDirector:removeMEGlobalListener(BloodFightManager.MSG_RESET_MANUAL, self.resetSuccessCallback)
    self.resetSuccessCallback = nil

    self.updateUserDataCallBack = nil;

    if self.generalHead then
        self.generalHead:removeEvents()
    end

end

function BloodybattleMainLayer:drawMissionNode(page, player, index)
    local status = BloodFightManager:getPlayerStaus(player.index);


    print("drawMissionNode player = ", player)
    -- print("index = ", index)
    -- print("status = ", status)

    -- MissionManager.STATUS_PASS  = 1;--已通过
    -- MissionManager.STATUS_CUR   = 2;--当前
    -- MissionManager.STATUS_CLOSE = 3;--未开放
    local curIndex = 1
    if index > 20 then 
        curIndex = index - 20
    elseif index > 10 then 
        curIndex = index - 10
    else
        curIndex = index 
    end


    local posList = MissionManager:gePosListByMapId(self.mapId);
    local img_map = TFDirector:getChildByPath(page, 'img_map');
    local posItem = posList:objectAt(curIndex);

    local mission_node = nil;
    if status == BloodFightManager.PLAYER_PASS then
        --已通关
        mission_node = createUIByLuaNew("lua.uiconfig_mango_new.bloodybattle.BloodybattleBossPassed");
        img_map:addChild(mission_node)
    end

    if status == BloodFightManager.PLAYER_NOW then
        mission_node = createUIByLuaNew("lua.uiconfig_mango_new.bloodybattle.BloodybattleBossNow");
        img_map:addChild(mission_node,10)
    end

    if status == BloodFightManager.PLAYER_LOCK then
        --未开放
        mission_node = createUIByLuaNew("lua.uiconfig_mango_new.bloodybattle.BloodybattleBossLocked");
        img_map:addChild(mission_node)
    end
        


    local roleId = player.playerId
    local img_boss = TFDirector:getChildByPath(mission_node, "img_boss")

    if status == BloodFightManager.PLAYER_LOCK and img_boss then
        -- img_boss:setShaderProgram("GrayShader", true)
    end

    if roleId == 10000000 then
        img_boss:setTexture("ui_new/bloodybattle/img_x.png")
    else
        -- print("roleId = ", roleId)
        local cardRole = RoleData:objectByID(roleId);
        if img_boss and cardRole then
            -- print("cardRole:getHeadPath() = ", cardRole:getHeadPath())
            img_boss:setTexture(cardRole:getHeadPath())
        end
    end

    local txt_name = TFDirector:getChildByPath(mission_node, 'txt_name');
    local img_num = TFDirector:getChildByPath(mission_node, 'img_num');
    local nodeIndex = curIndex
    if nodeIndex >= 5 then
        nodeIndex = nodeIndex - 1
    end

    img_num:setTexture("ui_new/mission/gk_" .. nodeIndex .. ".png")

    txt_name:setText(player.name);

    --已通关，属性填充
    if status == BloodFightManager.PLAYER_PASS then
        mission_node:setName("pre_mission")

        for i=1, 3 do
            local img_star = TFDirector:getChildByPath(mission_node, 'img_star' .. i);
            -- print("player.star = ",player.star)
            if player.star  <  i then
                img_star:setVisible(false);
            end
        end
    end


     --处理按钮事件
    local btn_attack = TFDirector:getChildByPath(mission_node, 'btn_base');
    btn_attack.logic = self;
    btn_attack:setTag(player.index);
    btn_attack:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onBtnAttackClickHandle));

    -- mission_node:setScale(0.4);
    mission_node:setPosition(ccp(posItem.missonPosX - 480 - btn_attack:getSize().width/2 ,posItem.missonPosY - 320 - btn_attack:getSize().height/2 ));
    mission_node.logic = self;
    mission_node:setTag(player.index);
    mission_node:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onBtnAttackClickHandle));
    

    if status == BloodFightManager.PLAYER_NOW then
        mission_node:setName("cur_mission")
        txt_name:setText(localizable.bloodBattleMainLayer_ketiaozhan);

        local resPath = "effect/mission_attacking.xml"
        TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
        local effect = TFArmature:create("mission_attacking_anim")

        effect:setAnimationFps(GameConfig.ANIM_FPS)
        effect:setPosition(ccp(btn_attack:getPosition().x,btn_attack:getPosition().y-2));
        effect:setScale(0.5)
        btn_attack:getParent():addChild(effect,1)

        effect:playByIndex(0, -1, -1, 1)

        mission_node.effect = effect
    else

    end

    -- self.missionNodeList[index] = mission_node;
    self.missionNodeList[player.index] = mission_node;

end

function BloodybattleMainLayer:drawBoxNode(page, box, index)
    local curIndex = 1
    if index > 20 then 
        curIndex = index - 20
    elseif index > 10 then 
        curIndex = index - 10
    else
        curIndex = index 
    end

    local posList = MissionManager:gePosListByMapId(self.mapId);
    local img_map = TFDirector:getChildByPath(page, 'img_map');
    local posItem = posList:objectAt(curIndex);

    local bBoxCanBeGet = false

    local type = box.got
    local boxBtn = TFButton:create()
    -- boxBtn:setTouchEnabled(false)
    if type == 0 then
        boxBtn:setTextureNormal("ui_new/bloodybattle/xz_bukeling.png")
    elseif type == 1 or type == 3 then
        boxBtn:setTextureNormal("ui_new/bloodybattle/xz_keling.png")
        
         -- boxBtn:setTouchEnabled(true)
    elseif type == 2 then
        boxBtn:setTextureNormal("ui_new/bloodybattle/xz_yilingqu.png")
        boxBtn:setTouchEnabled(false)
        boxBtn:setGrayEnabled(true)
    end

    if type == 3 then
        bBoxCanBeGet = true
    end

    boxBtn:setPosition(ccp(530,30))

    img_map:addChild(boxBtn)
    local pos_x = posItem.missonPosX - 480 - boxBtn:getSize().width/2
    local pos_y = posItem.missonPosY - 320 - boxBtn:getSize().height/2
    boxBtn:setPosition(ccp(pos_x + 50, pos_y + 50));
    self.boxNodeList[box.index] = boxBtn;
    boxBtn.logic = self
    boxBtn.index = box.index
    boxBtn.type  = type
    boxBtn:addMEListener(TFWIDGET_CLICK,audioClickfun(self.onBtnBoxClickHandle))

    self:addBoxEffect(boxBtn,bBoxCanBeGet)
end

function BloodybattleMainLayer:bloodFightDailyReset()

    if self.pageView then
        self.pageView:removeFromParentAndCleanup(true)
    end

    local pageView = TPageView:create()
    self.pageView = pageView

    pageView:setBounceEnabled(false)
    pageView:setTouchEnabled(true)
    pageView:setBackGroundColorType(TF_LAYOUT_COLOR_NONE)
    pageView:setSize(self.panel_list:getContentSize())
    pageView:setPosition(self.panel_list:getPosition())
    pageView:setAnchorPoint(self.panel_list:getAnchorPoint())

    local function onPageChange()
        self:onPageChange();
    end
    pageView:setChangeFunc(onPageChange)

    local function itemAdd(index)
        return  self:addPage(index);
    end
    pageView:setAddFunc(itemAdd)

    self.panel_list:addChild(pageView,2);
end

function BloodybattleMainLayer:addBoxEffect(boxBtn, bBoxCanBeGet)
    if boxBtn == nil then
        return
    end

    if bBoxCanBeGet and boxBtn.effect == nil then
        local resPath = "effect/bloodfight_box.xml"
        TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
        local effect = TFArmature:create("bloodfight_box_anim")

        effect:setAnimationFps(GameConfig.ANIM_FPS)

        --effect:setPosition(ccp(0,-self.btn_reward:getSize().height/2))
        effect:setPosition(ccp(0, 15))
        boxBtn:addChild(effect,100)

        effect:addMEListener(TFARMATURE_COMPLETE,function()

        end)
        effect:playByIndex(0, -1, -1, 1)
        effect:setTag(10086);

        boxBtn.effect = effect
    else
        if boxBtn.effect then
            boxBtn.effect:removeFromParentAndCleanup(true)
            boxBtn.effect = nil
        end
    end
end

function BloodybattleMainLayer.OnShaodangClickHandle( btn )
    local self = btn.logic
    BloodFightManager:requestBloodySweep(self)
end

function BloodybattleMainLayer:refreshSaoDangBtn()
    if BloodFightManager:getMissionIndex() <= 1 then
        self.btn_shaodang:setTouchEnabled(true)
        self.btn_shaodang:setGrayEnabled(false)
    else
        self.btn_shaodang:setTouchEnabled(false)
        self.btn_shaodang:setGrayEnabled(true)
    end
end
return BloodybattleMainLayer;
