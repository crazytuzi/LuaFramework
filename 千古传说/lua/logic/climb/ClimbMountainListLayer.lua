--[[
******无量山-关卡列表*******
    -- by haidong.gan
    -- 2013/12/27
]]
local ClimbMountainListLayer = class("ClimbMountainListLayer", BaseLayer)

CREATE_SCENE_FUN(ClimbMountainListLayer)
CREATE_PANEL_FUN(ClimbMountainListLayer)

function ClimbMountainListLayer:ctor(mountainItem)
    self.super.ctor(self,mountainItem)

    self.clickMountainItem_id = 1
    self:init("lua.uiconfig_mango_new.climb.ClimbMountainListLayer")
end

function ClimbMountainListLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.txt_curIndex   = TFDirector:getChildByPath(ui, 'txt_curIndex')
    self.img_cur        = TFDirector:getChildByPath(ui, 'img_cur')
    self.btn_qubeiku    = TFDirector:getChildByPath(ui, 'btn_qubeiku')
    self.bg_table       = TFDirector:getChildByPath(ui, 'list_mountain')
    self.img_point1     = TFDirector:getChildByPath(self.bg_table, 'img_point1')
    self.img_point2     = TFDirector:getChildByPath(self.bg_table, 'img_point2')
    self.btn_soul       = TFDirector:getChildByPath(ui, 'btn_soul')

    self.generalHead = CommonManager:addGeneralHead( self )
    self.generalHead:setData(ModuleType.Climb,{HeadResType.CLIMB,HeadResType.COIN,HeadResType.SYCEE})

    self.bg_table.logic = self
    self.bg_table:addMEListener(TFWIDGET_TOUCHBEGAN, self.listTouchBeganHandle)
    self.bg_table:addMEListener(TFWIDGET_TOUCHMOVED, self.listTouchMovedHandle)
    self.bg_table:addMEListener(TFWIDGET_TOUCHENDED, self.listTouchEndedHandle)

    self.detailLayer    = require('lua.logic.climb.ClimbMountainDetailLayer'):new()
    self.detailLayer:setZOrder(10)
    self:addLayer(self.detailLayer)
    self.slider_gundongtiao  = TFDirector:getChildByPath(ui, 'slider_gundongtiao')
    self.slider_gundongtiao.logic = self
    -- self.slider_gundongtiao:addMEListener(TFWIDGET_TOUCHBEGAN, audioClickfun(self.sliderTouchMoveHandle),1)
    self.slider_gundongtiao:addMEListener(TFWIDGET_TOUCHMOVED, self.sliderTouchMovedHandle)
    self.slider_gundongtiao:addMEListener(TFWIDGET_TOUCHENDED, self.sliderTouchEndedHandle)

    self.img_slider = TFDirector:getChildByPath(ui, 'img_slider')

    self:initCircle()
end

-- 初始化滑动轨迹
function ClimbMountainListLayer:initCircle()
    self.img1x = self.img_point1:getPositionX()
    self.img2x = self.img_point2:getPositionX()
    self.height = self.img_point1:getPositionY()
    -- print(self.img1x, self.img2x, self.height)
    local diffx = self.img2x - self.img1x
    local b = 130

    local r = (4 * b * b + diffx * diffx) / (8 * b)
    self.centerPoint = ccp(self.img1x + diffx / 2, self.height - b + r)
    -- print("point = ", self.centerPoint.x, self.centerPoint.y)

    local px = self.centerPoint.x - self.img1x
    local py = self.centerPoint.y - self.height
    local a = math.sqrt((px * px) + (py * py))
    -- print("r = ", r, a)

    self.hAngle = math.asin(diffx / 2 / r)
    self.wAngle = self.hAngle * 2
    -- print("angle = ", self.wAngle)

    self.avgAngle = self.wAngle / 5
    -- print(self.avgAngle)

    self.curAngle = 0
    self.node_list = {}
    for i=1,5 do
        local m_node = createUIByLuaNew("lua.uiconfig_mango_new.climb.ClimbMountainItemNode")
        self.node_list[i] = m_node
        m_node.panel_touch = TFDirector:getChildByPath(m_node, 'panel_touch')
        m_node.logic = self
        m_node.oWidth = m_node:getSize().width
        m_node.oHeight = m_node:getSize().height
        m_node.idx = i
        m_node.loaded = false
        -- local rAngle = self.avgAngle / 2 + ((i - 1) * self.avgAngle)
        local rAngle = self.hAngle + ((i - 1) * self.avgAngle)
        self:moveItemNode(m_node, rAngle)
    end

    self:setSliderBar()
end

function ClimbMountainListLayer:setSliderBar()
    if self.totalAngle then
        local percent = self.curAngle / self.totalAngle * 100
        self.slider_gundongtiao:setPercent(percent)
    end
end

function ClimbMountainListLayer:moveItemNode(node, angle)
    angle = self:checkAngle(node, angle)

    local rx = self.centerPoint.x + (self.img1x - self.centerPoint.x) * math.cos(angle) - (self.height - self.centerPoint.y) * math.sin(angle)
    local ry = self.centerPoint.y + (self.img1x - self.centerPoint.x) * math.sin(angle) + (self.height - self.centerPoint.y) * math.cos(angle)
    local percent = angle - self.hAngle < 0 and angle  or 2 * self.hAngle - angle
    percent = percent / self.hAngle
    local opacity = percent * 100 + 155
    local scale = percent * 0.5 + 0.5
    node:setOpacity(opacity)
    node:setScale(scale)
    local diffY = node.oHeight * (1 - scale)
    node:setPosition(ccp(rx, ry))
    node.angle = angle
    if not node:getParent() then
        self.bg_table:addChild(node)
    end
end

function ClimbMountainListLayer:onShow()
    self.super.onShow(self)
    self.generalHead:onShow()
    self:refreshBaseUI()
end

function ClimbMountainListLayer:refreshBaseUI()
    self.needRefresh = true
    if self.homeInfo then
        self.clickMountainItem_id = math.min(self.homeInfo.curId, ClimbConfigure:length())
    end
    self:reloadItem()
    self.needRefresh = false
end

function ClimbMountainListLayer:reloadItem()
    self.curAngle = 0
    for i=1,5 do
        local node = self.node_list[i]
        node.idx = i
        -- local rAngle = self.avgAngle / 2 + ((i - 1) * self.avgAngle)
        local rAngle = self.hAngle + ((i - 1) * self.avgAngle)
        self:moveItemNode(node, rAngle)
    end

    self:scrollToCurMountainItem()
    self:setSliderBar()
end

function ClimbMountainListLayer:updateMountainNode(node)
    -- 更新爬山信息
    local mountainItem = self.mountainList:objectAt(node.idx)
    self:loadMountainNode(node, mountainItem)
end

function ClimbMountainListLayer:checkAngle(node, angle)
    local needUpdate = false
    if angle < 0 then
        local m = angle * (-1) / self.wAngle
        local i = math.floor(m)
        node.idx = node.idx + 5 * (i + 1)
        angle = self.wAngle - (m - i)
        needUpdate = true
    elseif angle > self.wAngle then
        local m = angle / self.wAngle
        local i = math.floor(m)
        node.idx = node.idx - 5 * i
        angle = m - i
        needUpdate = true
    end

    -- node:setVisible(node.idx > 0 and node.idx <= self.mountainList:length())
    local max = self.mountainList and self.mountainList:length() or 3
    node:setVisible(node.idx > 0 and node.idx <= max)

    if self.mountainList and node:isVisible() then
        if not node.loaded or needUpdate or self.needRefresh then
            self:updateMountainNode(node)
            node.loaded = true
        end
    end

    return self.hAngle + (node.idx - 1) * self.avgAngle + self.curAngle
    -- return angle
end

function ClimbMountainListLayer:scrollToCurMountainItem()
    local prevAngle = self.curAngle
    local idx = self:getMountainIndexById(self.clickMountainItem_id)
    self.curAngle = -(idx - 1) * self.avgAngle
    local diffx = self.curAngle - prevAngle
    for k,node in pairs(self.node_list) do
        self:moveItemNode(node, node.angle + diffx)
        if idx == node.idx then
            self.onMountainItemClickHandle(node)
        end
    end
end

function ClimbMountainListLayer.listTouchBeganHandle(sender)
    local self = sender.logic
    -- self.delayTimer = TFDirector:addTimer(500, 1, nil, function() self.can_move = true end)
    self.movePos = sender:getTouchStartPos()
end

function ClimbMountainListLayer.listTouchMovedHandle(sender)
    local self = sender.logic
    local curPos = sender:getTouchMovePos()
    local diffx = (curPos.x - self.movePos.x) / 1000

    if self.curAngle + diffx > 0 then
        diffx = -self.curAngle
    end

    if self.curAngle + diffx < self.totalAngle then
        diffx = self.totalAngle - self.curAngle
    end

    if diffx == 0 then
        return
    end

    self.curAngle = math.max(math.min(self.curAngle + diffx, 0), self.totalAngle)
    for k,node in pairs(self.node_list) do
        self:moveItemNode(node, node.angle + diffx)
    end
    self:setSliderBar()

    self.movePos = curPos
end

function ClimbMountainListLayer.listTouchEndedHandle(sender)
    local self = sender.logic
    local startPos = sender:getTouchStartPos()
    local endPos = sender:getTouchEndPos()
    if math.abs(startPos.x - endPos.x) < 30 then
        for k,node in pairs(self.node_list) do
            if node.panel_touch:boundingBox():containsPoint(node.panel_touch:getParent():convertToNodeSpace(endPos)) then
                print(node.idx)
                play_press()
                self.onMountainItemClickHandle(node)
                break
            end
        end
    end
end

function ClimbMountainListLayer.sliderTouchMovedHandle(sender)
    local self = sender.logic
    self.sliderTouchEndedHandle(sender)
end

function ClimbMountainListLayer.sliderTouchEndedHandle(sender)
    local self = sender.logic
    local prevAngle = self.curAngle
    local percent = sender:getPercent() / 100
    self.curAngle = percent * self.totalAngle
    local diffx = self.curAngle - prevAngle
    for k,node in pairs(self.node_list) do
        self:moveItemNode(node, node.angle + diffx)
    end
end

function ClimbMountainListLayer:getShowMountainList()
    local list = TFArray:new();
    local index = 1;
    local curIndex = self:getMountainIndexById(self.homeInfo.curId);
    local cellNum = math.ceil((curIndex + 19)/3);
    local length = math.min(ClimbConfigure:length() , cellNum * 3);

    for v in ClimbConfigure:iterator() do
        if index <= length then
            list:push(v);
        end
        index = index +1;
    end
    return list;
end

function ClimbMountainListLayer:loadHomeData(data)
    self.homeInfo = data;
    self.cur_mountainItem = nil;
    -- if self.homeInfo.curId > ClimbConfigure:back().id then
    --     self.img_cur:setVisible(false);
    -- end
    local floor_num = math.min(self.homeInfo.curId , ClimbConfigure:back().id)
    self.txt_curIndex:setText(floor_num);

    self.mountainList = self:getShowMountainList()

    -- self.totalAngle = (self.mountainList:length() - 5) * self.avgAngle
    self.totalAngle = -(self.mountainList:length() - 1) * self.avgAngle
    self:reloadItem()

    -- self.table_mountain:reloadData()
    -- self.txt_star_num:setText(ClimbManager.climStarNum)
    self.clickMountainItem_id = math.min(self.homeInfo.curId, ClimbConfigure:length())
    -- self.table_mountain:scrollToCenterForPositionY(ClimbMountainListLayer.LIST_ITEM_HEIGHT / 3 * self:getMountainIndexById(self.homeInfo.curId) , 0);
end

function ClimbMountainListLayer:updateCurMountain(data)
    -- local prevCurId = self.homeInfo.curId;
    -- self.clickMountainItem_id = math.min(self.homeInfo.curId,ClimbConfigure:length());
    -- self.homeInfo = data;
    -- self.cur_mountainItem = nil;
    -- -- self.txt_curIndex:setText("当前闯关层数为：" .. self.homeInfo.curId .. "层");
    -- if self.homeInfo.curId > ClimbConfigure:back().id then
    --     self.img_cur:setVisible(false);
    -- end
    -- self.txt_curIndex:setText(self.homeInfo.curId);

    -- self.mountainList = self:getShowMountainList();
    local floor_num = math.min(data.curId, ClimbConfigure:back().id)
    self.txt_curIndex:setText(floor_num)
    self:reloadItem()
    -- self.txt_curIndex:setText(data.curId);

    -- self.table_mountain:reloadData()
    -- self.txt_star_num:setText(ClimbManager.climStarNum)

    -- self.table_mountain:scrollToCenterForPositionY(ClimbMountainListLayer.LIST_ITEM_HEIGHT / 3 * self:getMountainIndexById(prevCurId) , 0);
    -- self.table_mountain:scrollToCenterForPositionY(ClimbMountainListLayer.LIST_ITEM_HEIGHT / 3 * self:getMountainIndexById(self.clickMountainItem_id) , 0);
end
function ClimbMountainListLayer:updateStar()
    self:reloadItem()
    -- self.table_mountain:reloadData()
    -- self.txt_star_num:setText(ClimbManager.climStarNum)

    -- self.table_mountain:scrollToCenterForPositionY(ClimbMountainListLayer.LIST_ITEM_HEIGHT / 3 * self:getMountainIndexById(prevCurId) , 0);
    -- self.table_mountain:scrollToCenterForPositionY(ClimbMountainListLayer.LIST_ITEM_HEIGHT / 3 * self:getMountainIndexById(self.clickMountainItem_id) , 0);
end

function ClimbMountainListLayer:getMountainIndexById(mountainId)
    local index = 0
    for item in ClimbConfigure:iterator() do
        if item.id > mountainId then
            break
        end
        index = index + 1
    end
    return index
end

--添加关卡节点
function ClimbMountainListLayer:loadMountainNode(mountain_node, mountainItem)
    local img_lock = TFDirector:getChildByPath(mountain_node, 'img_lock')
    local img_floor_bg = TFDirector:getChildByPath(mountain_node, 'img_floor_bg')
    local img_arrow = TFDirector:getChildByPath(mountain_node, 'img_arrow')
    local img_flag = TFDirector:getChildByPath(mountain_node, 'img_flag')
    local txt_index = TFDirector:getChildByPath(mountain_node, 'txt_floor')
    local panel_hero = TFDirector:getChildByPath(mountain_node, 'Panel_hero')
    txt_index:setText(stringUtils.format(localizable.ClimbMountainListLayer_floor_desc, mountainItem.id))

    if self.clickMountainItem_id == mountainItem.id then
        self.clickMountainItem = mountain_node
        txt_index:setColor(ccc3(255,255,255))
        img_floor_bg:setTexture("ui_new/climb/wl_kaiqi.png")
    else
        txt_index:setColor(ccc3(0,0,0))
        img_floor_bg:setTexture("ui_new/climb/wls_cengshu_bg.png")
    end 

    local Panel_Content = TFDirector:getChildByPath(mountain_node, 'Panel_Content1')
    for i=1,3 do
        local img_star = TFDirector:getChildByPath(Panel_Content, 'img_star'..i)
        img_star:setVisible(false)
    end
    if ClimbManager.climbStarInfo[mountainItem.id] then
        local star_num = ClimbManager.climbStarInfo[mountainItem.id].star or 0
        for i=1,3 do
            local img_star = TFDirector:getChildByPath(Panel_Content, 'img_star'..i)
            img_star:setVisible(true)
            local img_star_show = TFDirector:getChildByPath(img_star, 'img_star')
            if i <= star_num then
                img_star_show:setVisible(true)
            else
                img_star_show:setVisible(false)
            end
        end
    end

    img_lock:setVisible(false)
    img_flag:setVisible(false)
    img_arrow:setVisible(false)

    mountain_node:setTag(mountainItem.id)
    if mountain_node.armature then
        mountain_node.armature:removeFromParent()
    end

    local armatureID = mountainItem.image
    ModelManager:addResourceFromFile(1, armatureID, 1)
    mountain_node.armature = ModelManager:createResource(1, armatureID)
    panel_hero:addChild(mountain_node.armature)
    mountain_node.armature:setScale(0.6)

    if  mountainItem.id < self.homeInfo.curId then
        img_flag:setTexture("ui_new/climb/wl_qizi1.png")
        img_flag:setVisible(true)  
    elseif mountainItem.id == self.homeInfo.curId then
        img_flag:setVisible(true)
        img_flag:setTexture("ui_new/climb/wl_qizi.png")

        ModelManager:playWithNameAndIndex(mountain_node.armature, "stand", -1, 1, -1, -1)
        
        if mountainItem.id == self.homeInfo.curId then
            self.cur_mountainItem = mountainItem
        end
    elseif mountainItem.id > self.homeInfo.curId then
        img_lock:setVisible(true)
        img_flag:setVisible(false)
        mountain_node.armature:setColor(ccc3(100,100,100))
    end

    if mountain_node.rewardNode then
        mountain_node.rewardNode:removeFromParent()
        mountain_node.rewardNode = nil
    end
end

function ClimbMountainListLayer.onMountainItemClickHandle(sender)
    local self = sender.logic

    local mountainId = sender:getTag();
    local mountainItem = ClimbConfigure:objectByID(mountainId);

    if self.clickMountainItem:getTag() == self.clickMountainItem_id then
        local txt_index = TFDirector:getChildByPath(self.clickMountainItem, 'txt_floor');
        txt_index:setColor(ccc3(0,0,0))
        local img_floor_bg = TFDirector:getChildByPath(self.clickMountainItem, 'img_floor_bg');
        img_floor_bg:setTexture("ui_new/climb/wls_cengshu_bg.png");
    end
    local txt_index = TFDirector:getChildByPath(sender, 'txt_floor');
    txt_index:setColor(ccc3(255,255,255))
    local img_floor_bg = TFDirector:getChildByPath(sender, 'img_floor_bg');
    img_floor_bg:setTexture("ui_new/climb/wl_kaiqi.png");

    self.clickMountainItem = sender
    self.clickMountainItem_id = sender:getTag()
    -- if  mountainItem.id <= self.homeInfo.curId then
        self.detailLayer:loadData(mountainItem,self.homeInfo);

    -- elseif mountainItem.id > self.homeInfo.curId then
    --     toastMessage("未开放")
    -- end

    -- ClimbManager:showDetail(mountainItem,self.homeInfo);
end


function ClimbMountainListLayer:removeUI()
    self.super.removeUI(self);
end

function ClimbMountainListLayer:dispose()
    if self.generalHead then
        self.generalHead:dispose()
        self.generalHead = nil
    end
    self.super.dispose(self)
end

function ClimbMountainListLayer:registerEvents()
    self.super.registerEvents(self) 
   self.btn_soul.logic = self
   self.btn_soul:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onSoulClickHandle))

   self.btn_qubeiku:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClickNorthMountain))

    self.updateHomeInfoCallBack = function(event)
        self:loadHomeData(event.data[1])
    end
    TFDirector:addMEGlobalListener(ClimbManager.CLIMB_INFORMATION, self.updateHomeInfoCallBack)

    self.attackCompeleteCallBack = function(event)
        self:updateCurMountain(event.data[1])
    end
    TFDirector:addMEGlobalListener(ClimbManager.EVENT_ATTACK_COMPELETE, self.attackCompeleteCallBack)
    
    self.AddClimbStarInfoMessageCallBack = function(event)
        self:updateStar()
    end
    TFDirector:addMEGlobalListener(ClimbManager.AddClimbStarInfoMessage, self.AddClimbStarInfoMessageCallBack)
    

    if self.generalHead then
        self.generalHead:registerEvents()
    end
 end

function ClimbMountainListLayer.onSoulClickHandle(sender)
    local self = sender.logic
    local needLevelIndex = ConstantData:getValue("Climb.Carbon.NeedLevelIndex1")

    if self.homeInfo.curId < needLevelIndex then
        --toastMessage("无量山到第" .. needLevelIndex .. "层开放")
        toastMessage(stringUtils.format(localizable.carbonMountainList_open, needLevelIndex))
        return
    end
    ClimbManager:showCarbonListLayer()
end


function ClimbMountainListLayer.onClickNorthMountain(sender)
    local self = sender.logic;
    local needLevelIndex = ConstantData:getValue("North.Cave.Open.Floor")

    if ClimbManager:getClimbFloorNum() < needLevelIndex then
        
        -- local str = TFLanguageManager:getString(ErrorCodeData.BEIKU_OPEN_NOT_ENOUGH_LEVEL)
        -- str = string.format(str,needLevelIndex)        
        local str = stringUtils.format(localizable.BEIKU_OPEN_NOT_ENOUGH_LEVEL,needLevelIndex)
        
        toastMessage(str)
        return;
    end
    NorthClimbManager:showNorthMountainLayer()
end


function ClimbMountainListLayer:removeEvents()
    self.super.removeEvents(self);

    TFDirector:removeMEGlobalListener(ClimbManager.CLIMB_INFORMATION ,self.updateHomeInfoCallBack);
    TFDirector:removeMEGlobalListener(ClimbManager.EVENT_ATTACK_COMPELETE ,self.attackCompeleteCallBack);
    TFDirector:removeMEGlobalListener(ClimbManager.AddClimbStarInfoMessage ,self.AddClimbStarInfoMessageCallBack);
    self.AddClimbStarInfoMessageCallBack = nil
    if self.generalHead then
        self.generalHead:removeEvents()
    end
end

return ClimbMountainListLayer