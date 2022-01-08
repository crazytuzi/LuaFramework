--[[
******PVE推图-关卡*******

    -- by haidong.gan
    -- 2013/11/27
]]
local MissionLayer = class("MissionLayer", BaseLayer);

CREATE_SCENE_FUN(MissionLayer);
CREATE_PANEL_FUN(MissionLayer);

MissionLayer.LIST_ITEM_WIDTH = 200
local itemX = 235
local itemY = 448

function MissionLayer:ctor()
    self.super.ctor(self);
    self:init("lua.uiconfig_mango_new.mission.MissionLayer");
    self.showAttackTipMissionId = nil; 
end

function MissionLayer:loadData(missionId, difficulty)
    self.missionId = missionId;
    self.difficulty = difficulty;

    if self.missionId then
        local toMission = MissionManager:getMissionById(self.missionId);
        self.selectDifficulty = toMission.difficulty;
        local map = MissionManager:getMapById(toMission.mapid);
        self.selectIndex = MissionManager:getMapList():indexOf(map);
    else
        self.selectDifficulty = self.difficulty;

        local map = MissionManager:getCurrentMap(self.selectDifficulty);
        self.selectIndex = nil;
        if map then
            self.selectIndex = MissionManager:getMapList():indexOf(map);
        else
            self.selectIndex = MissionManager:getMapList():length();
        end

        if self.selectDifficulty ~= MissionManager.DIFFICULTY0 and map and self.selectIndex == MissionManager:getMapList():indexOf(map) then
            self.selectIndex = math.max( self.selectIndex - 1, 1);
        end
    end
    
    self.groupButtonManager:selectIndex(self.selectDifficulty);
    -- local img_select = TFImage:create("ui_new/mission/gk_duihao.png");
    -- -- self.groupButtonManager:getSelectButton():removeChildByTag(10086,true);
    -- self.groupButtonManager:getSelectButton().highlight:setVisible(false)

    -- add by king, 修改了缓存关卡之后 宗师和普通切换的问题
    self.groupButtonManager.btnDic[1].highlight:setVisible(false);
    self.groupButtonManager.btnDic[2].highlight:setVisible(false);
    -- end

    -- img_select:setTag(10086);
    -- img_select:setPosition(ccp(50,0))
    self.groupButtonManager:getSelectButton().highlight:setVisible(true)

    -- 隐藏宗师管卡
    local teamLev = MainPlayer:getLevel()
    local openLev = FunctionOpenConfigure:getOpenLevel(2001)
    if teamLev < openLev then
        self.btn_sort_level1:setVisible(false)
    else
        self.btn_sort_level1:setVisible(true)
    end
end

function MissionLayer:initUI(ui)
    self.super.initUI(self,ui);

    TFLuaTime:begin()
    self.addMapTimer = {}
    self.addMissionTimer = {}

    self.penel_block     = TFDirector:getChildByPath(ui, 'penel_block')
    self.panel_head      = TFDirector:getChildByPath(ui, 'panel_head');
    self.generalHead = CommonManager:addGeneralHead( self )
    self.generalHead:setData(ModuleType.None,{HeadResType.COIN,HeadResType.SYCEE,HeadResType.PUSH_MAP})

    self.panel_clipping     = TFDirector:getChildByPath(ui, 'panel_clipping')
    self.panel_content      = TFDirector:getChildByPath(ui, 'panel_zhujian')
    self.img_scroll         = TFDirector:getChildByPath(ui, 'img_scroll')

    -- self.txt_pagenum       = TFDirector:getChildByPath(ui, 'txt_pagenum')
    -- self.txt_star           = TFDirector:getChildByPath(ui, 'txt_starpoint')
    self.txt_name           = TFDirector:getChildByPath(ui, 'txt_chapter')

    self.btn_left           = TFDirector:getChildByPath(ui, 'btn_pageleft')
    self.btn_right          = TFDirector:getChildByPath(ui, 'btn_pageright')
    self.positiony          = self.btn_right:getPosition().y;

    --self.btn_reward         = TFDirector:getChildByPath(ui, 'img_box')

    self.panelBoxView       = TFDirector:getChildByPath(ui, 'panelBoxView')
    self.mapBoxView = require("lua.logic.mission.MissionStarBox"):new()

    self.panelBoxView:addChild(self.mapBoxView)

    self.clippingWidth = self.panel_clipping:getContentSize().width
    self.clippingHeight = self.panel_clipping:getContentSize().height
    self.percentWidth = self.panel_clipping:getSizePercentWidth()
    self.percentHeight = self.panel_clipping:getSizePercentHeight()
    self.panel_content:setContentSize(CCSize(self.clippingWidth, self.clippingHeight))
    self.panel_content:setPositionX(self.clippingWidth * (-1))

    local tableView = TFTableView:create()
    self.tableView = tableView

    tableView.logic = self
    tableView:setTableViewSize(self.panel_content:getContentSize())
    tableView:setDirection(TFTableView.TFSCROLLHORIZONTAL)
    tableView:setVerticalFillOrder(TFTableView.TFTabViewFILLBOTTOMUP)
    tableView:setBounceable(false)
    tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, self.cellSizeForTable);
    tableView:addMEListener(TFTABLEVIEW_SCROLL, self.scrollForTable);
    tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, self.tableCellAtIndex);
    tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, self.numberOfCellsInTableView)
    Public:bindScrollFun(tableView)
    self.panel_content:addChild(tableView,1)

  -- self.btn_sort            = TFDirector:getChildByPath(ui, 'btn_xiala');
    self.btn_sort_level0     = TFDirector:getChildByPath(ui, 'btn_putong');
    self.btn_sort_level0.highlight     = TFDirector:getChildByPath(ui, 'Img_putong2');
    self.btn_sort_level0.difficulty = MissionManager.DIFFICULTY0;
    self.btn_sort_level0.highlight:setVisible(false)
    
    -- self.btn_sort_level1     = TFDirector:getChildByPath(ui, 'btn_gaoshou');
    self.btn_sort_level1     = TFDirector:getChildByPath(ui, 'btn_zongshi');
    self.btn_sort_level1.highlight     = TFDirector:getChildByPath(ui, 'Img_zongshi2');
    self.btn_sort_level1.difficulty = MissionManager.DIFFICULTY1
    self.btn_sort_level1.highlight:setVisible(false)
    -- self.img_select          = TFDirector:getChildByPath(ui, 'img_select');

    self.btn_sortArr = {}
    self.btn_sortArr[MissionManager.DIFFICULTY0] = self.btn_sort_level0;
    self.btn_sortArr[MissionManager.DIFFICULTY1] = self.btn_sort_level1;

    -- self.bg_sort             = TFDirector:getChildByPath(ui, 'panel_bg');
    -- self.bg_sort:setSwallowTouch(false);
    -- self.node_menu           = TFDirector:getChildByPath(ui, 'panel_menu');
    self.groupButtonManager  = GroupButtonManager:new( {[1] = self.btn_sort_level0, [2] = self.btn_sort_level1});


    -- self.img_select:setTexture("ui_new/mission/gk_putong_icon.png");

    -- self.node_menu:setVisible(false);
    -- self.btn_sort:setVisible(true);

    -- self:setGuideBlockViisble(true,false)

    --     --公告框
    -- local function update(delta)
    --     self:setGuideBlockViisble(false,false)
    -- end
    -- local timeId = TFDirector:addTimer(100, 1, nil, update)

    -- self.Common_passed  = createUIByLuaNew("lua.uiconfig_mango_new.mission.Common_passed")
    -- self.Boss_passed    = createUIByLuaNew("lua.uiconfig_mango_new.mission.Boss_passed")
    -- self.Common_locked  = createUIByLuaNew("lua.uiconfig_mango_new.mission.Common_locked")
    -- self.Boss_locked    = createUIByLuaNew("lua.uiconfig_mango_new.mission.Boss_locked")
    -- self.Common_now     = createUIByLuaNew("lua.uiconfig_mango_new.mission.Common_now")
    -- self.Boss_now       = createUIByLuaNew("lua.uiconfig_mango_new.mission.Boss_now")
    -- self.pageMapNode = nil
    -- TFLuaTime:endToLua("==========================================MissionLayer:initUI")

    -- self.Common_passed:retain()
    -- self.Boss_passed:retain()
    -- self.Common_locked:retain()
    -- self.Boss_locked:retain()
    -- self.Common_now:retain()
    -- self.Boss_now:retain()

    self.btn_jingyan = TFDirector:getChildByPath(ui, 'btn_jingyan')
    self.btn_jingyan:setVisible(true)

    self:rollScroll()
end

function MissionLayer:loadItemInfo(uiItem, idx)
    local isShow = idx % 2 == 0
    local uiContent = isShow and uiItem.downContent or uiItem.upContent

    local curMissionlist = self:getCurMissionList()
    local mission = curMissionlist:objectAt(idx + 1)
    local missionId = mission.id
    local curMission =  MissionManager:getMissionById(missionId)

    local missionNode = TFDirector:getChildByPath(uiItem, 'Button_Zhujian')
    missionNode:setTag(missionId)
    self.missionNodeList[missionId] = missionNode

    -- local missionNode = TFDirector:getChildByPath(uiItem, 'Button_Zhujian')
    missionNode:setGrayEnabled(false)

    --关卡名称
    local txtStageName = TFDirector:getChildByPath(uiContent, 'Text_Zhangjie')
    txtStageName:setText(curMission.stagename)

    --背景图片
    local map = MissionManager:getMapList():objectAt(self.selectIndex)
    local imgBg = TFDirector:getChildByPath(uiItem, 'Image_Guanqia')
    local bgName = string.format('bg_jpg/%s_%d.png', map.map_img, idx+1)
    imgBg:setTexture(bgName)
    -- imgBg:setGrayEnabled(false)
    
    --星星
    local panelStar = TFDirector:getChildByPath(uiContent, 'Panel_Starts')
    panelStar:setVisible(true)

    --锁
    local imgLock = TFDirector:getChildByPath(uiItem, 'Image_Lock')
    imgLock:setVisible(false)

    local spawnNode = TFDirector:getChildByPath(missionNode, 'Spawn_Hero')
    spawnNode:removeAllChildren()
    if curMission.image > 0 then
        local armatureID = curMission.image
        ModelManager:addResourceFromFile(1, armatureID, 1)
        local model = ModelManager:createResource(1, armatureID)
        model:setScale(0.8)
        model:setPosition(ccp(0, -60))
        spawnNode:addChild(model)
        model:setRotationY(180)
    end

    local status = MissionManager:getMissionPassStatus(missionId)
    -- MissionManager.STATUS_PASS  = 1;--已通过
    -- MissionManager.STATUS_CUR   = 2;--当前
    -- MissionManager.STATUS_CLOSE = 3;--未开放
    if status == MissionManager.STATUS_PASS then
         for i=1, 3 do
            local img_star = TFDirector:getChildByPath(uiContent, 'Image_Star' .. i)
            local texture = nil
            if mission.starLevel  <  i then
                texture = "ui_new/mission/gk_star2_icon.png"
            else
                texture = "ui_new/mission/gk_star_icon.png"
            end
            img_star:setTexture(texture)
        end
    end

    uiItem.imgChoose2:setVisible(false)
    uiItem:stopAnimation("Action0")

    if mission.id == self.missionId then
        uiItem.imgChoose:setVisible(true)
    else
        uiItem.imgChoose:setVisible(status == MissionManager.STATUS_CUR and self.missionId == nil)
    end

    if status == MissionManager.STATUS_CUR then
        panelStar:setVisible(false)
    end

    if status == MissionManager.STATUS_CLOSE or status == MissionManager.STATUS_NEED_DIFFICULTY0 or  curMission.reqiure_level > MainPlayer:getLevel() then
        missionNode:setGrayEnabled(true)
        panelStar:setVisible(false)
        imgLock:setVisible(true)
    elseif uiItem.imgChoose:isVisible() then
        uiItem.imgChoose2:setVisible(true)
        uiItem:runAnimation("Action0", -1)
    end
end


function MissionLayer.scrollForTable(tableView)
    local self = tableView.logic
end

function MissionLayer.cellSizeForTable(tableView,idx)
    return itemY, itemX
end

function MissionLayer.tableCellAtIndex(tableView, idx)
    local self = tableView.logic
    local cell = tableView:dequeueCell()
    if nil == cell then
        tableView.cells = tableView.cells or {}
        cell = TFTableViewCell:create()
        tableView.cells[cell] = true

        local node = createUIByLuaNew("lua.uiconfig_mango_new.mission.MapItem")
        cell:addChild(node)
        cell.item = node
        node.downContent = TFDirector:getChildByPath(node, 'Panel_Star_down')
        node.upContent = TFDirector:getChildByPath(node, 'Panel_Star_up')
        node.imgChoose = TFDirector:getChildByPath(node, 'Image_Choose')
        node.imgChoose2 = TFDirector:getChildByPath(node, 'Image_Choose2')

        local missionNode = TFDirector:getChildByPath(node, 'Button_Zhujian')
        missionNode.logic = self
        missionNode:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onBtnAttackClickHandle))
        missionNode:addMEListener(TFWIDGET_TOUCHENDED, self.onBtnAttackTouchEndedHandle);
    end

    local item = cell.item
    local isShow = idx % 2 == 0
    item.downContent:setVisible(isShow)
    item.upContent:setVisible(not isShow)
    self:loadItemInfo(item, idx)

    return cell
end

function MissionLayer.numberOfCellsInTableView(tableView)
    local self = tableView.logic
    local curMissionlist = self:getCurMissionList()
    return curMissionlist:length()
end

function MissionLayer:getCurMissionList()
    local map = MissionManager:getMapList():objectAt(self.selectIndex)
    local missionlist = MissionManager:getMissionListByMapId(map.id)
    return missionlist[self.selectDifficulty]
end

function MissionLayer:setGuideBlockViisble(isVisible,force)
    if force == nil then
        force = true
    end

    if force == false and self.force == true then
        return
    end
    if isVisible == true and force == true then
        self.force = true
    else
        self.force = false
    end

    self.penel_block:setVisible(isVisible);
    -- if self.pageView.setScrollEnabled then
    --     self.pageView:setScrollEnabled(not isVisible);
    -- end
    if isVisible then
        self.btn_left:setColor(ccc3(166, 166, 166));
        self.btn_right:setColor(ccc3(166, 166, 166));
        -- self.btn_sort:setColor(ccc3(166, 166, 166));
        -- self.img_select:setColor(ccc3(166, 166, 166));
    else
        self.btn_left:setColor(ccc3(255, 255, 255));
        self.btn_right:setColor(ccc3(255, 255, 255));
        -- self.btn_sort:setColor(ccc3(255, 255, 255));
        -- self.img_select:setColor(ccc3(255, 255, 255));
    end
    -- if isVisible then
    --     local guidePanel = TFPanel:create()
    --     guidePanel:setSize(self.panel_head:getSize())
    --     guidePanel:setPosition(self.panel_head:getPosition())

    --     guidePanel:setBackGroundColorType(TF_LAYOUT_COLOR_SOLID)
    --     guidePanel:setBackGroundColorOpacity(0)
    --     guidePanel:setBackGroundColor(ccc3(0,0,0))
    --     guidePanel:setZOrder(100)
    --     guidePanel:setTouchEnabled(true)
    --     self:addChild(guidePanel)
    --     self.guidePanel = guidePanel
    -- else
    --     if not tolua.isnull(self.guidePanel) then
    --         self.guidePanel:removeFromParent()
    --         self.guidePanel = nil
    --     end
    -- end
end

function MissionLayer:removeUI()
    print("---------MissionLayer:removeUI()--------------------")
    TFDirector:removeTimer(self.end_timerID)
    self.end_timerID = nil
    self.super.removeUI(self)

    -- if self.Common_passed then
    --     self.Common_passed:release()
    --     self.Common_passed = nil
    -- end
    -- if self.Boss_passed then
    --     self.Boss_passed:release()
    --     self.Boss_passed = nil
    -- end
    -- if self.Common_locked then
    --     self.Common_locked:release()
    --     self.Common_locked = nil
    -- end
    -- if self.Boss_locked then
    --     self.Boss_locked:release()
    --     self.Boss_locked = nil
    -- end
    -- if self.Common_now then
    --     self.Common_now:release()
    --     self.Common_now = nil
    -- end
    -- if self.Boss_now then
    --     self.Boss_now:release()
    --     self.Boss_now = nil
    -- end
    

    -- if self.pageMapNode then
    --     self.pageMapNode:release()
    --     self.pageMapNode = nil
    -- end
end

function MissionLayer:dispose()
    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end

    self.super.dispose(self)
end

function MissionLayer:onShow()
    self.super.onShow(self)
    self.generalHead:onShow()
    self:refreshUI()
    -- 隐藏宗师管卡
    local teamLev = MainPlayer:getLevel()
    local openLev = FunctionOpenConfigure:getOpenLevel(2001)
    if teamLev < openLev then
        self.btn_sort_level1:setVisible(false)
    else
        self.btn_sort_level1:setVisible(true)
    end

    -- ----------------------------------------
    -- local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.mission.MissionSkipLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1);        
    --         layer:loadData(1,1)
    --         AlertManager:show();  
end

local scrollX = 0.1
function MissionLayer:rollScroll()
    self.panel_clipping:setSizePercent(ccp(0, self.percentHeight))
    self.img_scroll:setPosition(ccp(self.panel_clipping:getPositionX() - 45, self.img_scroll:getPositionY()))

    local posX = 0
    self.end_timerID = TFDirector:addTimer(10, -1, nil, 
        function() 
            posX = posX + scrollX
            local offsetX = math.min(posX, self.percentWidth)
            self.panel_clipping:setSizePercent(ccp(offsetX, self.percentHeight))
            self.img_scroll:setPosition(ccp(self.panel_clipping:getPositionX() - self.panel_clipping:getContentSize().width - 45, self.img_scroll:getPositionY()))
            if self.percentWidth - offsetX < 0.001 then 
                TFDirector:removeTimer(self.end_timerID)
                self.end_timerID = nil
            end
        end)
end

function MissionLayer:refreshBaseUI()

end

function MissionLayer:refreshUI()
    self.missionNodeList = {}

    self.tableView:reloadData()
    self:pointToCurMission()
    self:showInfoForPage(self.selectIndex)
    
    -- 显示经验加成
    if not self.isShow then
        return
    end
    if MainPlayer.multipleOutputList[1] and MainPlayer.multipleOutputList[1].endTime >= MainPlayer:getNowtime() then
        self.btn_jingyan:setVisible(true)
    else
        self.btn_jingyan:setVisible(false)
    end
end

function MissionLayer:pointToCurMission()
    local curMissionlist = self:getCurMissionList()
    local len = curMissionlist:length()
    local idx = 0
    for i=1, curMissionlist:length() do
        local mission = curMissionlist:objectAt(i)
        local status = MissionManager:getMissionPassStatus(mission.id)
        idx = i
        if self.missionId == mission.id then break end
        if status == MissionManager.STATUS_CUR or (i == 1 and status == MissionManager.STATUS_CLOSE) then break end
    end

    local container = self.tableView:getContainer()
    local offsetX = 0
    if idx > len - 3 then 
        offsetX = (container:getSize().width - self.tableView:getSize().width) * (-1)
    elseif idx < 3 then 
        offsetX = 0
    else
        offsetX = (idx - 3) * itemX * (-1)
    end
    self.tableView:setContentOffset(offsetX)
end

function MissionLayer:showInfoForPage(pageIndex)
    -- self.txt_pagenum:setText(pageIndex.. "/" .. MissionManager:getMapList():length())
    local map = MissionManager:getMapList():objectAt(pageIndex);

    self.mapBoxView.mapid = map.id
    self.mapBoxView:loadData(map.id,self.selectDifficulty)

    self.txt_name:setText(map.name);

    local curStar = MissionManager:getStarlevelCount(map.id,self.selectDifficulty);
    local maxStar = MissionManager:getMaxStarlevelCount(map.id,self.selectDifficulty);

    local mapBox = MissionManager:getBoxByMapIdAndDifficulty(map.id,self.selectDifficulty);

    -->>>>>>>>>>>>>>>>> quanhuan close 2015-9-24 13:30:11
    -- self.btn_reward:removeChildByTag(10086,true);
    -- if mapBox then
    --     if mapBox.isAlreadyOpen then
    --         self.btn_reward:setTextureNormal("ui_new/mission/gk_pass1.png");
    --         self.btn_reward:setShaderProgram("GrayShader", true)
    --     else
    --         self.btn_reward:setTextureNormal("ui_new/mission/gk_pass.png");
    --         -- self.txt_star:setText(curStar .. "/" .. maxStar);
    --         if (curStar == maxStar and mapBox and maxStar >= mapBox.need_star ) then
    --             self.btn_reward:setTouchEnabled(true);
    --             self.btn_reward:setShaderProgramDefault(true);

    --             local resPath = "effect/ui_mission_get_reward.xml"
    --             TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
    --             local effect = TFArmature:create("ui_mission_get_reward_anim")

    --             effect:setAnimationFps(GameConfig.ANIM_FPS)

    --             -- effect:setPosition(ccp(0,-self.btn_reward:getSize().height/2))
    --             effect:setPosition(ccp(0, 0))
    --             self.btn_reward:addChild(effect,100)

    --             effect:addMEListener(TFARMATURE_COMPLETE,function()

    --             end)
    --             effect:playByIndex(0, -1, -1, 1)
    --             effect:setTag(10086);
    --         else
    --             self.btn_reward:setShaderProgram("GrayShader", true)
    --             self.btn_reward:setTouchEnabled(false);
    --         end
    --     end

    --     self.btn_reward:setVisible(true);
    -- else
    --     self.btn_reward:setVisible(false);
    -- end
    --<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    local pageCount = MissionManager:getMapList():length();

    self.btn_left:setPosition(ccp(self.btn_left:getPosition().x,1000));
    self.btn_right:setPosition(ccp(self.btn_right:getPosition().x,1000));

    if pageIndex < pageCount and pageCount > 1 then
        self.btn_right:setPosition(ccp(self.btn_right:getPosition().x,self.positiony));
    end

    if pageIndex > 1 and pageCount > 1  then
        self.btn_left:setPosition(ccp(self.btn_left:getPosition().x,self.positiony));
    end
end

-- function MissionLayer:onPageChange()
--     local pageIndex = self.pageView:_getCurPageIndex();
--     self:showInfoForPage(pageIndex);
-- end

-- function MissionLayer:refreshMissionList(pageIndex)
--     self.pageView:_removeAllPages();

--     self.pageView:setMaxLength(MissionManager:getMapList():length())

--     self.missionNodeList = {};
--     self.pageList        = {};


--     self:showInfoForPage(pageIndex);
--     local mission = MissionManager:getCurrentMission(self.selectDifficulty);
--     print("mission = ", mission)
--     self.pageView:InitIndex(pageIndex);
-- end


-- function MissionLayer:addPage(pageIndex)
--     local pagepanel = TFPanel:create();

--     local map = MissionManager:getMapList():objectAt(pageIndex);
--     local missionlist = MissionManager:getMissionListByMapId(map.id);
--     local curMissionlist = missionlist[self.selectDifficulty];
--     local page = nil;

--     local function addMap()
--         if self.pageMapNode == nil then
--             page = createUIByLuaNew("lua.uiconfig_mango_new.mission.MapItem");
--             self.pageMapNode = page
--             self.pageMapNode:retain()
--         end

--         page = self.pageMapNode:clone()

--         page:setSize(self.panel_list:getContentSize())
--         pagepanel:addChild(page);


--         local img_map = TFDirector:getChildByPath(page, 'img_map');
--         img_map:setTexture("bg_jpg/" .. map.map_img .. ".jpg");

--         local battlePoint = TFImage:create("bg_jpg/battlepoint/" .. map.point_imp .. ".png")
--         if battlePoint then
--             battlePoint:setAnchorPoint(CCPointMake(0.5,0.5))
--             battlePoint:setPosition(CCPointMake(0,0))
--             img_map:addChild(battlePoint)
--         end
        
--         local contentSize = self.panel_list:getContentSize()

--         img_map:setPosition(ccp(contentSize.width/2,contentSize.height/2))

--         -- print("getAnchorPoint = ",img_map:getAnchorPoint())
--         -- print("getSize = ",img_map:getSize())
--         -- print("getContentSize = ",img_map:getContentSize())
--         -- print("getPosition = ",img_map:getPosition())
--         -- print("page==================")
--         -- print("page = ",page:getPosition())

--     end

--     if self.addMapTimer[pageIndex] then
--         TFDirector:removeTimer(self.addMapTimer[pageIndex])
--         self.addMapTimer[pageIndex] = nil
--     end
--     if self.addMissionTimer[pageIndex] then
--         TFDirector:removeTimer(self.addMissionTimer[pageIndex])
--         self.addMissionTimer[pageIndex] = nil
--     end
--     if pageIndex ~= self.selectIndex then

--         local index = 1;
--         local function onOnceCom()
--             if index == 1 then

--             else
--                 local mission = curMissionlist:objectAt(index - 1);
--                 self:addMissionNode(page,mission.id);
--             end
--             index = index + 1;
--         end

--         self.addMapTimer[pageIndex] = TFDirector:addTimer(0.5, 1, function ()
--             local length = curMissionlist:length();
--             self.addMissionTimer[pageIndex] = TFDirector:addTimer(0.1, length + 1, nil, onOnceCom);
--         end, addMap);

--     else
--         self.addMapTimer[pageIndex] = TFDirector:addTimer(0, 1, function ()
--             for mission in curMissionlist:iterator()  do
--                 self:addMissionNode(page,mission.id);
--             end
--         end, addMap);

--         -- addMap();
--         -- -- local function onCom()
--         --     --添加关卡
--         --     for mission in curMissionlist:iterator()  do
--         --         self:addMissionNode(page,mission.id);
--         --     end
--         -- -- end

--         -- TFDirector:addTimer(0.0001, 1, onCom, nil);
--     end
--     self.pageList[map.id] = pagepanel;

--     return pagepanel;
-- end

--刷新关卡进度
function MissionLayer:refreshMission()
    local map = MissionManager:getCurrentMap(self.selectDifficulty)
    if map then
        self.selectIndex = MissionManager:getMapList():indexOf(map)
    else
        self.selectIndex = MissionManager:getMapList():length()
    end
    self:refreshUI()
end

-- --添加关卡节点
-- function MissionLayer:addMissionNode(page,missionId)
--     local mission = MissionManager:getMissionById(missionId);
--     local missionlist = MissionManager:getMissionListByMapId(mission.mapid);

--     local nextMission = MissionManager:getNextMissionById(mission.mapid,mission.difficulty,mission.id);
--     local attackingMission = MissionManager:getCurrentMissionInMapByDifficulty(mission.mapid,mission.difficulty);

--     local curMissionlist = missionlist[mission.difficulty];
--     local index = curMissionlist:indexOf(mission);

--     local posList = MissionManager:gePosListByMapId(mission.mapid);
--     local img_map = TFDirector:getChildByPath(page, 'img_map');

--     local posItem = posList:objectAt(index);
--     local roadImg = nil;

--     if not posItem then
--         print("找不到位置信息 第 " .. mission.mapid  .. "章节，难度：" .. mission.difficulty .. "，第" .. index .. "关卡")
--         return;
--     end
--     if posItem.road_img ~= "" then
--         roadImg = TFImage:create("ui_new/mission/" .. posItem.road_img .. ".png");
--         if not roadImg then
--             print("找不到图片：" .. "ui_new/mission/" .. posItem.road_img .. ".png")
--             return;
--         end
--         roadImg:setPosition(ccp(posItem.roadPosX - 480 , posItem.roadPosY - 320));
--         img_map:addChild(roadImg);
--     end


--     local status = MissionManager:getMissionPassStatus(missionId);

--     -- MissionManager.STATUS_PASS  = 1;--已通过
--     -- MissionManager.STATUS_CUR   = 2;--当前
--     -- MissionManager.STATUS_CLOSE = 3;--未开放

--     local mission_node = nil;
--     if status == MissionManager.STATUS_PASS then
--         --已通关
--         if mission.type == MissionManager.TYPE_COMMON then
--             -- mission_node = createUIByLuaNew("lua.uiconfig_mango_new.mission.Common_passed");
--             mission_node = self.Common_passed:clone()
--         else
--             -- mission_node = createUIByLuaNew("lua.uiconfig_mango_new.mission.Boss_passed");
--             mission_node = self.Boss_passed:clone()
--         end

--         img_map:addChild(mission_node)
--         mission_node:setGrayEnabled(false)
--     end
--     if status == MissionManager.STATUS_CUR then
--         --增加等级限制添加，by wk.dai
--         if mission.reqiure_level > MainPlayer:getLevel() then
--             if mission.type == MissionManager.TYPE_COMMON then
--                 -- mission_node = createUIByLuaNew("lua.uiconfig_mango_new.mission.Common_locked");
--                 mission_node = self.Common_locked:clone()
--             else
--                 -- mission_node = createUIByLuaNew("lua.uiconfig_mango_new.mission.Boss_locked");
--                 mission_node = self.Boss_locked:clone()
--             end
--             mission_node:setGrayEnabled(true)
--         else
--             if mission.type == MissionManager.TYPE_COMMON then
--                 -- mission_node = createUIByLuaNew("lua.uiconfig_mango_new.mission.Common_now");
--                 mission_node = self.Common_now:clone()
--             else
--                 -- mission_node = createUIByLuaNew("lua.uiconfig_mango_new.mission.Boss_now");
--                 mission_node = self.Boss_now:clone()
--             end
--         end

--         img_map:addChild(mission_node,10)

--     end
--     if status == MissionManager.STATUS_CLOSE or status == MissionManager.STATUS_NEED_DIFFICULTY0 then
--         --未开放
--         if mission.type == MissionManager.TYPE_COMMON then
--             -- mission_node = createUIByLuaNew("lua.uiconfig_mango_new.mission.Common_locked");
--             mission_node = self.Common_locked:clone()
--         else
--             -- mission_node = createUIByLuaNew("lua.uiconfig_mango_new.mission.Boss_locked");
--             mission_node = self.Boss_locked:clone()
--         end
--         img_map:addChild(mission_node)
--     end

--      --处理按钮事件
--     local btn_attack = TFDirector:getChildByPath(mission_node, 'btn_base');
--     btn_attack.logic = self;
--     btn_attack:setTag(mission.id);
--     btn_attack:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onBtnAttackClickHandle));
--     btn_attack:addMEListener(TFWIDGET_TOUCHENDED, self.onBtnAttackTouchEndedHandle);

--     -- mission_node:setScale(0.4);
--     mission_node:setPosition(ccp(posItem.missonPosX - 480 - btn_attack:getSize().width/2 ,posItem.missonPosY - 320 - btn_attack:getSize().height/2 ));
--     mission_node.logic = self;
--     mission_node:setTag(mission.id);
--     mission_node:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onBtnAttackClickHandle));

--     self.missionNodeList[mission.id] = mission_node;


--     local img_num = TFDirector:getChildByPath(mission_node, 'img_num');
--     img_num:setTexture("ui_new/mission/gk_" .. index .. ".png")

--     local txt_name = TFDirector:getChildByPath(mission_node, 'txt_name');
--     local img_boss = TFDirector:getChildByPath(mission_node, 'img_boss');

--     if mission.type > MissionManager.TYPE_COMMON then
--         if img_boss then
--             img_boss:setTexture("icon/head/" .. mission.image .. ".png")
--         end
--     end

--     --已通关，属性填充
--     if status == MissionManager.STATUS_PASS then
--         mission_node:setName("pre_mission_"..index)

--         if mission.starLevel  <  3 then
--             --txt_name:setText("第" .. index  .. "回");
--             txt_name:setText(stringUtils.format(localizable.common_index_hui ,index));
--         else
--            --txt_name:setText("可扫荡");
--            txt_name:setText(localizable.common_sweep);
--         end
--         for i=1, 3 do
--             local img_star = TFDirector:getChildByPath(mission_node, 'img_star' .. i);
--             if mission.starLevel  <  i then
--                 img_star:setVisible(false);
--             end
--         end
--     end

--     --已经开放的关卡，属性填充
--     if status == MissionManager.STATUS_CUR then
--         -- self.standingMissionId = mission.id;
--         mission_node:setName("cur_mission")

--         --txt_name:setText("可挑战");
--         txt_name:setText(localizable.missionDetail_fight);

--         local resPath = "effect/mission_attacking.xml"
--         TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
--         local effect = TFArmature:create("mission_attacking_anim")

--         effect:setAnimationFps(GameConfig.ANIM_FPS)
--         if mission.type > MissionManager.TYPE_COMMON then
--             effect:setPosition(ccp(btn_attack:getPosition().x,btn_attack:getPosition().y-2));
--         else
--             effect:setPosition(ccp(btn_attack:getPosition().x,btn_attack:getPosition().y-2));
--         end
--         btn_attack:getParent():addChild(effect,1)
--         effect:setScale(0.5)
--         -- effect:addMEListener(TFARMATURE_COMPLETE,function()
--         --     effect:removeMEListener(TFARMATURE_COMPLETE)
--         --     effect:removeFromParent()
--         -- end)
--         effect:playByIndex(0, -1, -1, 1)
--         -- self.playAutoMatixTimeId = TFDirector:addTimer(600, 1, nil, function()
--         --     self:playAutoMatixComEffect()
--         -- end);

--         -- armature:setShaderProgram("HighLight", true)
--         if roadImg then
--             roadImg:setShaderProgram("GrayShader", true)
--         end

--         --增加等级限制添加，by wk.dai
--         if mission.reqiure_level > MainPlayer:getLevel() then
--             effect:setShaderProgram("GrayShader", true)
--         end
--     end

--     --未开放的关卡，属性填充
--     if status == MissionManager.STATUS_CLOSE  or status == MissionManager.STATUS_NEED_DIFFICULTY0 then
--         --txt_name:setText("第" .. index  .. "回");
--         txt_name:setText(stringUtils.format(localizable.common_index_hui,index));

--         local img_general = TFDirector:getChildByPath(mission_node, 'img_general');
--         local img_city = TFDirector:getChildByPath(mission_node, 'img_city');

--         if img_num then
--             mission_node.img_num = img_num
--             img_num:setShaderProgram("GrayShader", true)
--         end
--         if txt_name then
--             mission_node.txt_name = txt_name
--             txt_name:setShaderProgram("GrayShader", true)
--         end
--         if img_boss then
--             mission_node.img_boss = img_boss
--             img_boss:setShaderProgram("GrayShader", true)
--         end
--         if btn_attack then
--             mission_node.btn_attack = btn_attack
--             btn_attack:setShaderProgram("GrayShader", true)
--         end
--         if img_general then
--             mission_node.img_general = img_general
--             img_general:setShaderProgram("GrayShader", true)
--         end
--         if img_city then
--             mission_node.img_city = img_city
--             img_city:setShaderProgram("GrayShader", true)
--         end

--         if(roadImg) then
--             mission_node.roadImg = roadImg
--             roadImg:setShaderProgram("GrayShader", true)
--         end
--     end

--     if self.showAttackTipMissionId and  self.showAttackTipMissionId == missionId then
--         local resPath = "effect/guide.xml"
--         TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
--         local effect = TFArmature:create("guide_anim")

--         effect:setAnimationFps(GameConfig.ANIM_FPS)

--         effect:setPosition(ccp(btn_attack:getPosition().x  ,btn_attack:getPosition().y + 10));
--         effect:setTag(100)
--         btn_attack:getParent():addChild(effect,1)

--         -- effect:addMEListener(TFARMATURE_COMPLETE,function()
--         --     effect:removeMEListener(TFARMATURE_COMPLETE)
--         --     effect:removeFromParent()
--         -- end)
--         effect:playByIndex(0, -1, -1, 1)
--         -- self.playAutoMatixTimeId = TFDirector:addTimer(600, 1, nil, function()
--         --     self:playAutoMatixComEffect()
--         -- end);
--     end
-- end

function MissionLayer:showAttackTip(missionId)
    self.showAttackTipMissionId = missionId;
end

function MissionLayer:getArmatureByImage(image)
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
function MissionLayer:removeMissionNode(missionId)
    local mission_node = self.missionNodeList[missionId];
    if mission_node then
        mission_node:removeFromParentAndCleanup(true);
        self.missionNodeList[missionId] = nil;
    end
end

function MissionLayer.onLeftClickHandle(sender)
    local self = sender.logic;
    self.missionId = nil
    self.selectIndex = self.selectIndex - 1
    self:refreshUI()
end

function MissionLayer.onRightClickHandle(sender)
    local self = sender.logic;
    self.missionId = nil
    self.selectIndex = self.selectIndex + 1
    self:refreshUI()
end
function MissionLayer.onJingyanClickHandle(sender)
    MainPlayer:showMultipleOutputInfo(1)
end

function MissionLayer.onShowSortMenuClickHandle(sender)
    local self = sender.logic;
    self.node_menu:setVisible(not self.node_menu:isVisible());
    -- self.btn_sort:setVisible(false);
end

function MissionLayer.onSortSelectClickHandle(sender)
    local self = sender.logic;

    -- self.node_menu:setVisible(false);
    -- self.btn_sort:setVisible(true);

    if (self.groupButtonManager:getSelectButton() == sender) then
        return;
    end

    self:changeDifficulty(sender.difficulty);

end

function MissionLayer:changeDifficulty(difficulty)
    self.selectDifficulty = difficulty;
    local btn_select = self.btn_sortArr[difficulty];

    for k,v in pairs(self.addMapTimer) do
        TFDirector:removeTimer(v)
    end
    for k,v in pairs(self.addMissionTimer) do
        TFDirector:removeTimer(v)
    end

    if self.scrollPageTimer then
        TFDirector:removeTimer(self.scrollPageTimer);
        self.scrollPageTimer = nil;
    end

    self.addMapTimer = {}
    self.addMissionTimer = {}

    -- local img_select = TFImage:create("ui_new/mission/gk_duihao.png");
    -- self.groupButtonManager:getSelectButton():removeChildByTag(10086,true);
    -- img_select:setPosition(ccp(50,0))
    -- img_select:setTag(10086);
    -- btn_select:addChild(img_select);

    self.groupButtonManager:getSelectButton().highlight:setVisible(false)
    btn_select.highlight:setVisible(true)
    self.groupButtonManager:selectBtn(btn_select);

    -- self.selectIndex = self.pageView:_getCurPageIndex();
    local map = MissionManager:getCurrentMap(difficulty);

    -- if difficulty == MissionManager.DIFFICULTY0 then
        if map then
            self.selectIndex = MissionManager:getMapList():indexOf(map);
        else
            self.selectIndex = MissionManager:getMapList():length();
        end
    -- end
    -- self:refreshMissionList(self.selectIndex);
    self:refreshUI()


    -- if difficulty ~= MissionManager.DIFFICULTY0 and map and self.selectIndex == MissionManager:getMapList():indexOf(map) then
    --     local function scrollPage()
    --         local pageIndex = self.pageView:getCurPageIndex() ;
    --         self.pageView:scrollToPage(pageIndex - 1);
    --     end
    --     self.scrollPageTimer = TFDirector:addTimer(0, 1, scrollPage, nil);
    -- end
end

function MissionLayer.onSortCancelClickHandle(sender)
    local self = sender.logic;
    self.node_menu:setVisible(false);
    self.btn_sort:setVisible(true);
end

--   local status = MissionManager:getMissionPassStatus(missionId);
function MissionLayer.onBtnAttackClickHandle(sender)

        -- local self = sender.logic;
        -- local resPath = "effect/mission_open.xml"
        -- TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
        -- local effect = TFArmature:create("mission_open_anim")

        -- effect:setAnimationFps(GameConfig.ANIM_FPS)
        -- effect:setPosition(ccp(self:getSize().width/2,self:getSize().height/2))

        -- self:addChild(effect,2)

        -- effect:addMEListener(TFARMATURE_COMPLETE,function()
        --     effect:removeMEListener(TFARMATURE_COMPLETE)
        --     effect:removeFromParent()
        -- end)
        -- effect:playByIndex(0, -1, -1, 0)
        -- -- self.playAutoMatixTimeId = TFDirector:addTimer(600, 1, nil, function()
        -- --     self:playAutoMatixComEffect()
        -- -- end);
   
    local self = sender.logic;
    local missionId = sender:getTag();
    if self.showAttackTipMissionId and self.showAttackTipMissionId == missionId then
        self.showAttackTipMissionId = nil
        local widget = sender:getParent():getChildByTag(100)
        if widget then
            widget:removeFromParent()
        end
    end
    self:setGuideBlockViisble(false,true)
    --PlayerGuideManager:ShowGuideLayer(nil)

    local status = MissionManager:getMissionPassStatus(missionId);
    local mission = MissionManager:getMissionById(missionId);

    --add by david.dai
    if status == MissionManager.STATUS_CUR then
        if mission.reqiure_level > MainPlayer:getLevel() then
            --toastMessage('你的团队等级不足，请提升到'..mission.reqiure_level..'级，再尝试')
            toastMessage(stringUtils.format(localizable.common_team_level_notenough,mission.reqiure_level))
            return
        end
    end

    if status == MissionManager.STATUS_CLOSE  or status == MissionManager.STATUS_NEED_DIFFICULTY0 then
        local msg = "";

        if mission.difficulty == MissionManager.DIFFICULTY0 then
            local currentMission = MissionManager:getCurrentMission(mission.difficulty);
            local missionlist = MissionManager:getMissionListByMapId(currentMission.mapid);
            local curMissionlist = missionlist[currentMission.difficulty];
            local index = curMissionlist:indexOf(currentMission);
            --初级难度
            --msg = "请先通关\"" .. MissionManager.DIFFICULTY_STR[currentMission.difficulty] .. currentMission.mapid .. "-" .. index .. "\"!";
            msg = stringUtils.format(localizable.missionLayer_please, MissionManager.DIFFICULTY_STR[currentMission.difficulty] , currentMission.mapid , index )
        end

        if mission.difficulty == MissionManager.DIFFICULTY1  then
            local currentMission = MissionManager:getCurrentMission(mission.difficulty);
            local missionlist = MissionManager:getMissionListByMapId(currentMission.mapid);
            local curMissionlist = missionlist[currentMission.difficulty];
            local index = curMissionlist:indexOf(currentMission);
            if status == MissionManager.STATUS_CLOSE then
                --msg = "请先通关\"" .. MissionManager.DIFFICULTY_STR[currentMission.difficulty] .. currentMission.mapid .. "-" .. index .. "\"!";
                msg = stringUtils.format(localizable.missionLayer_please, MissionManager.DIFFICULTY_STR[currentMission.difficulty] , currentMission.mapid , index )
                
            elseif status == MissionManager.STATUS_NEED_DIFFICULTY0 then
                local currentMission0 = MissionManager:getCurrentMission(MissionManager.DIFFICULTY0);

                if currentMission0 and  currentMission.mapid >= currentMission0.mapid then
                    --msg = "请先通关\"" .. MissionManager.DIFFICULTY_STR[currentMission0.difficulty] .. currentMission0.mapid .. "-" .. index .. "\"!";
                    msg = stringUtils.format(localizable.missionLayer_please, MissionManager.DIFFICULTY_STR[currentMission0.difficulty] , currentMission0.mapid , index )
                   
                else
                    --msg = "请先通关\"" .. MissionManager.DIFFICULTY_STR[currentMission.difficulty] .. currentMission.mapid .. "-" .. index .. "\"!";
                    msg = stringUtils.format(localizable.missionLayer_please, MissionManager.DIFFICULTY_STR[currentMission.difficulty] , currentMission.mapid , index )
                    
                end

            end
        end
        -- sender:setGrayEnabled(true)


        -- if mission.difficulty == MissionManager.DIFFICULTY1 then
        --     local attackingMission = MissionManager:getCurrentMissionInMapByDifficulty(mission.mapid,mission.difficulty);

        --     if attackingMission and MissionManager:getMissionPassStatus(attackingMission.id) == MissionManager.STATUS_CUR then
        --         local missionlist = MissionManager:getMissionListByMapId(attackingMission.mapid);
        --         local curMissionlist = missionlist[attackingMission.difficulty];
        --         local index = curMissionlist:indexOf(attackingMission);

        --         --上一关未通过
        --         msg = "请先通关__\"" .. MissionManager.DIFFICULTY_STR[attackingMission.difficulty] .. attackingMission.mapid .. "-" .. index .. "\"!";
        --     else
        --         local currentMission = MissionManager:getCurrentMission(MissionManager.DIFFICULTY0);
        --         local missionlist = MissionManager:getMissionListByMapId(currentMission.mapid);
        --         local curMissionlist = missionlist[currentMission.difficulty];
        --         local index = curMissionlist:indexOf(currentMission);
        --         --初级难度
        --         msg = "请先通关==\"" .. MissionManager.DIFFICULTY_STR[currentMission.difficulty] .. currentMission.mapid .. "-" .. index .. "\"!";
        --     end
        -- end

        -- if mission.difficulty == MissionManager.DIFFICULTY2 then
        --   if attackingMission and MissionManager:getMissionPassStatus(attackingMission.id) == MissionManager.STATUS_CUR then
        --       local missionlist = MissionManager:getMissionListByMapId(attackingMission.mapid);
        --       local curMissionlist = missionlist[attackingMission.difficulty];
        --       local index = curMissionlist:indexOf(attackingMission);

        --       --上一关未通过
        --       msg = "请先通关\"" .. MissionManager.DIFFICULTY_STR[attackingMission.difficulty] .. attackingMission.mapid .. "-" .. index .. "\"!";
        --   else
        --       local attackingMission1 = MissionManager:getCurrentMissionInMapByDifficulty(mission.mapid,MissionManager.DIFFICULTY1);
        --       if attackingMission1 and MissionManager:getMissionPassStatus(attackingMission1.id) == MissionManager.STATUS_CUR then

        --             local missionlist = MissionManager:getMissionListByMapId(attackingMission1.mapid);
        --             local curMissionlist = missionlist[attackingMission1.difficulty];
        --             local index = curMissionlist:indexOf(attackingMission1);

        --             msg = "请先通关\"" .. MissionManager.DIFFICULTY_STR[attackingMission1.difficulty] .. attackingMission1.mapid .. "-" .. index .. "\"!";
        --       else
        --           local currentMission = MissionManager:getCurrentMission(mission.difficulty);
        --           local missionlist = MissionManager:getMissionListByMapId(currentMission.mapid);
        --           local curMissionlist = missionlist[currentMission.difficulty];
        --           local index = curMissionlist:indexOf(currentMission);

        --           msg = "请先通关\"" .. MissionManager.DIFFICULTY_STR[currentMission.difficulty] .. currentMission.mapid .. "-" .. index .. "\"!";
        --       end
        --   end
        -- end

      toastMessage(msg)
      return;
    end

    MissionManager:showDetailLayer(missionId);
    print("-------------------------------->", missionId)
end

function MissionLayer:onAttackCompeleteHandle(event)
    local missionId                = event.data[1].missionId;
    local isFirstTimesPass         = event.data[1].isFirstTimesPass;
    local isFirstTimesToStarLevel3 = event.data[1].isFirstTimesToStarLevel3;

    print("-------------------------------->", missionId)

    local mission = MissionManager:getMissionById(missionId);

    --更新当前节点
    -- self:removeMissionNode(missionId);
    -- self:addMissionNode(self.pageList[mission.mapid],missionId)
    -- self:refreshMission()

    --更新体力恢复节点
    if MissionManager:isHasPassAllMissionForDifficulty(mission.mapid,mission.difficulty) then
        -- self:removeUseEnergyNode();
        -- self:addUseEnergyNode();
    end

    --首次胜利，判断：开放下一关卡
    if isFirstTimesPass then
        print("------------------------->isFirstTimesPass")
        local nextMission = MissionManager:getNextMissionById(mission.mapid,mission.difficulty,missionId);
        local currentMission = MissionManager:getCurrentMission(mission.difficulty);

        if nextMission then
            -- self:removeMissionNode(nextMission.id);
            -- self:addMissionNode(self.pageList[nextMission.mapid],nextMission.id);
            self:refreshMission()
        elseif currentMission then
            local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.mission.MissionSkipNewLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1);        
            layer:loadData(mission.mapid,mission.difficulty);     
            layer:setBtnHandle(
                function ()
                    --继续闯关
                    -- self:removeMissionNode(currentMission.id);
                    -- self:addMissionNode(self.pageList[currentMission.mapid],currentMission.id);
                    -- local pageIndex = self.pageView:getCurPageIndex() ;
                    -- self.pageView:scrollToPage(pageIndex + 1);
                    self:refreshMission()
                end,
                function ()
                    --我要满星
                    -- self:removeMissionNode(currentMission.id);
                    -- self:addMissionNode(self.pageList[currentMission.mapid],currentMission.id);
                    self:refreshMission()
                    local missionlist = MissionManager:getMissionListByMapId(mission.mapid);
                    local curMissionlist = missionlist[self.selectDifficulty];
                    local function getFirstNo3StarLevel()
                        for k,v in pairs(curMissionlist.m_list) do
                            if v.starLevel < 3 then
                                return v.id
                            end                       
                        end
                        return nil
                    end

                    local firstNo3StarMissionId = getFirstNo3StarLevel()
                    if firstNo3StarMissionId then
                        MissionManager:showDetailLayer(firstNo3StarMissionId);
                    end
                end)  
            AlertManager:show();  
        end
    end
end


function MissionLayer.onOpenBoxClickHandle(sender)
    local self = sender.logic;
    local pageIndex = self.pageView:_getCurPageIndex();
    local map = MissionManager:getMapList():objectAt(pageIndex);
    local mapBox = MissionManager:getBoxByMapIdAndDifficulty(map.id,self.selectDifficulty);

    local curStar = MissionManager:getStarlevelCount(map.id,self.selectDifficulty);
    local maxStar = MissionManager:getMaxStarlevelCount(map.id,self.selectDifficulty);
    if (curStar == maxStar and mapBox  and maxStar >= mapBox.need_star ) then

    else
        --toastMessage("要全部三星哦");
        toastMessage(localizable.missionLayer_start);
        return;
    end

    if mapBox.isAlreadyOpen then
        --toastMessage("已领取");
        toastMessage(localizable.common_get);
        return;
    end

    MissionManager:openBox(mapBox.id);


end

function MissionLayer.onBtnPlayerTipClickHandle(sender)
    local self = sender.logic;
    -- local lastMission = MissionManager:getLastMissionByMapIdAndDifficulty(self:getCurMap().id, MissionManager.DIFFICULTY0);
    -- self:playerTip(lastMission.id);
end


--注册事件
function MissionLayer:registerEvents()

    self.super.registerEvents(self);
    -- ADD_ALERT_CLOSE_LISTENER(self,self.btn_close);
    -- self.btn_close:setClickAreaLength(100);
    -- self.btn_sort.logic = self;
    self.btn_sort_level0.logic = self;
    -- self.btn_sort_level1.logic = self;
    self.btn_sort_level1.logic = self;
    -- self.bg_sort.logic = self;

    -- self.btn_sort:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onShowSortMenuClickHandle));
    self.btn_sort_level0:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onSortSelectClickHandle));
    -- self.btn_sort_level1:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onSortSelectClickHandle));
    self.btn_sort_level1:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onSortSelectClickHandle));
    -- self.bg_sort:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onSortCancelClickHandle));

    --quanhuan close 2015-9-24 13:30:53
    --self.btn_reward.logic = self;
    --self.btn_reward:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onOpenBoxClickHandle),1);


    self.btn_left.logic = self;
    self.btn_left:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onLeftClickHandle),1);
    self.btn_right.logic = self;
    self.btn_right:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onRightClickHandle),1);


    self.btn_jingyan:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onJingyanClickHandle),1);


    self.updateMissionCallBack = function(event)
        self:onAttackCompeleteHandle(event);
        -- self:refreshUI(event);
        -- local pageIndex = self.pageView:_getCurPageIndex() ;
        -- self:showInfoForPage(pageIndex);
    end;
    TFDirector:addMEGlobalListener(MissionManager.EVENT_UPDATE_MISSION ,self.updateMissionCallBack ) ;

    self.updateBoxCallBack = function(event)
        self:refreshUI(event);
        -- local pageIndex = self.pageView:_getCurPageIndex() ;
        -- self:showInfoForPage(pageIndex);
    end;
    --TFDirector:addMEGlobalListener(MissionManager.EVENT_UPDATE_BOX ,self.updateBoxCallBack ) ;

    -- self.updateUserDataCallBack = function(event)
    --     self:refreshBaseUI();
    -- end;
    -- TFDirector:addMEGlobalListener(MainPlayer.CoinChange ,self.updateUserDataCallBack ) ;
    -- TFDirector:addMEGlobalListener(MainPlayer.SyceeChange ,self.updateUserDataCallBack ) ;
    -- TFDirector:addMEGlobalListener(MainPlayer.ChallengeTimesChange ,self.updateUserDataCallBack ) ;

    if self.generalHead then
        self.generalHead:registerEvents()
    end

    if self.mapBoxView then
        self.mapBoxView:callRegisterEvents()
    end    
end

function MissionLayer:removeEvents()

    TFDirector:removeMEGlobalListener(MissionManager.EVENT_UPDATE_MISSION ,self.updateMissionCallBack);
    self.updateMissionCallBack = nil;

    --TFDirector:removeMEGlobalListener(MissionManager.EVENT_UPDATE_BOX ,self.updateBoxCallBack);
    self.updateBoxCallBack = nil;

    -- TFDirector:removeMEGlobalListener(MainPlayer.CoinChange ,self.updateUserDataCallBack);
    -- TFDirector:removeMEGlobalListener(MainPlayer.SyceeChange ,self.updateUserDataCallBack);
    -- TFDirector:removeMEGlobalListener(MainPlayer.ChallengeTimesChange ,self.updateUserDataCallBack ) ;

 --   self.updateUserDataCallBack = nil;

    for k,v in pairs(self.addMapTimer) do
        TFDirector:removeTimer(v)
    end
    for k,v in pairs(self.addMissionTimer) do
        TFDirector:removeTimer(v)
    end
    if self.scrollPageTimer then
        TFDirector:removeTimer(self.scrollPageTimer);
        self.scrollPageTimer = nil;
    end
    
    if self.generalHead then
        self.generalHead:removeEvents()
    end
    -- end
    self.showAttackTipMissionId = nil

    if self.mapBoxView then
        self.mapBoxView:callRemoveEvents()
    end
end

function MissionLayer.onBtnAttackTouchEndedHandle(sender)
    local self = sender.logic
    local missionId = sender:getTag()
    local status = MissionManager:getMissionPassStatus(missionId)
    if status == MissionManager.STATUS_CLOSE  or status == MissionManager.STATUS_NEED_DIFFICULTY0 then
        print("onBtnAttackTouchEndedHandle")
        local mission_node = self.missionNodeList[missionId]
        if mission_node then
            -- if mission_node.btn_attack then
            --     mission_node.btn_attack:setShaderProgram("GrayShader", true)
            -- end
            mission_node:setGrayEnabled(true)
        end
    end
end

return MissionLayer;
