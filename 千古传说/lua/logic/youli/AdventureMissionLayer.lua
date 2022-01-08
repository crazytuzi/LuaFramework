--[[
******游历章节列表层*******

    -- by Chikui Peng
    -- 2016/3/28
]]

local AdventureMissionLayer = class("AdventureMissionLayer", BaseLayer);

function AdventureMissionLayer:ctor(data)
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.youli.MissionLayer");
    if data then
        self.selectIndex = data - 1000;
    end
end

function AdventureMissionLayer:initUI(ui)
    self.super.initUI(self,ui);
    self.panel_head     = TFDirector:getChildByPath(ui, 'panel_head');
    self.generalHead = CommonManager:addGeneralHead(self)
    self.generalHead:setData(ModuleType.youli,{HeadResType.BAOZI,HeadResType.YUELI,HeadResType.SYCEE}) 
    self.generalHead:setVisible(true)

    self.panel_list = TFDirector:getChildByPath(ui, 'panel_list');
    local pageView = TPageView:create()
    self.pageView = pageView

    pageView:setBounceEnabled(true)
    pageView:setTouchEnabled(true)
    pageView:setBackGroundColorType(TF_LAYOUT_COLOR_NONE)
    pageView:setSize(self.panel_list:getContentSize())
    pageView:setPosition(self.panel_list:getPosition())
    pageView:setAnchorPoint(self.panel_list:getAnchorPoint())

    local function onPageChange()
        self:onPageChange();
    end
    self.pageView:setChangeFunc(onPageChange)

    local function itemAdd(index)
        return  self:addPage(index);
    end 
    self.pageView:setAddFunc(itemAdd)
    self.panel_list:addChild(pageView);

    self.btn_left   = TFDirector:getChildByPath(ui, 'btn_pageleft')
    self.btn_right  = TFDirector:getChildByPath(ui, 'btn_pageright')
    self.btn_close  = TFDirector:getChildByPath(ui, 'btn_close');

    self.CurMission = AdventureMissionManager:getCurrAcrossMission()
    if self.selectIndex == nil or self.selectIndex > self.CurMission.map_id - 1000 then
        self.selectIndex = self.CurMission.map_id - 1000
    end
    self:showPage(self.selectIndex)
end

function AdventureMissionLayer:onShow()
    self.super.onShow(self)
    self.generalHead:onShow()
end

function AdventureMissionLayer:loadRewardListData(data)
    self.dataList = data or {};
    self:refreshUI();
end

function AdventureMissionLayer:refreshUI()
    if not self.isShow then
        return;
    end
end

function AdventureMissionLayer.onLeftClickHandle(sender)
    local self = sender.logic;
    local pageIndex = self.pageView:getCurPageIndex() ;
    self.pageView:scrollToPage(pageIndex - 1);
end

function AdventureMissionLayer.onRightClickHandle(sender)
    local self = sender.logic;
    local pageIndex = self.pageView:getCurPageIndex() ;
    self.pageView:scrollToPage(pageIndex + 1);
end

function AdventureMissionLayer:showPage(pageIndex)
    self.pageView:_removeAllPages();

    local len = self.CurMission.map_id - 1000
    self.pageView:setMaxLength(len)

    self:showInfoForPage(pageIndex);

    self.pageView:InitIndex(pageIndex);      
end

function AdventureMissionLayer:onPageChange()
    local pageIndex = self.pageView:_getCurPageIndex() ;
    self:showInfoForPage(pageIndex);
end

function AdventureMissionLayer:addPage(pageIndex) 
    local page = TFPanel:create();
    page:setSize(self.panel_list:getContentSize())

    local node = createUIByLuaNew("lua.uiconfig_mango_new.youli.MissionItem")
    page:addChild(node);
    local missionList = AdventureMissionManager:getMissionListByMapIdAndDifficulty(pageIndex + 1000,nil)
    local index = 0
    for mission in missionList:iterator() do
        index = index + 1
        -- print('index = ',index)
        local panel_cell = TFDirector:getChildByPath(node, 'panel_cell'..index)
        if mission.starLevel <= 0 then
            panel_cell:setVisible(false)
        else
            panel_cell:setVisible(true)
            local txt_name = TFDirector:getChildByPath(panel_cell, 'txt_name')
            local txt_index = TFDirector:getChildByPath(panel_cell, 'txt_index')
            local btn_qianwang = TFDirector:getChildByPath(panel_cell, 'btn_qianwang')
            txt_index:setText(toVerticalString(txt_index:getString()))
            for i=1,3 do
                local star = TFDirector:getChildByPath(panel_cell, 'star'..i)
                if mission.starLevel >= i then
                    star:setVisible(true)
                else
                    star:setVisible(false)
                end
            end
            txt_name:setText(toVerticalString(mission.name))
            btn_qianwang.missionId = mission.id
            btn_qianwang:addMEListener(TFWIDGET_CLICK, audioClickfun(handler(AdventureMissionLayer.OnShowMissionClick,self)),1)
            if self.guideId == mission.id then
                local resPath = "effect/guide.xml"
                TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
                local effect = TFArmature:create("guide_anim")
                effect:setAnimationFps(GameConfig.ANIM_FPS)
                effect:playByIndex(0, -1, -1, -1)
                effect:setPosition(ccp(0,0))
                btn_qianwang:addChild(effect)
            end
        end
    end

    local mapName = TFDirector:getChildByPath(node, 'txt_mapname')
    local mapData = AdventureMissionManager:getMapById(pageIndex+1000)
    if mapData == nil then
        node:setVisible(false)
    else
        node:setVisible(true)
        mapName:setText(toVerticalString(mapData.name))
    end
    return page;
end

function AdventureMissionLayer:showInfoForPage(pageIndex)
    self.selectIndex = pageIndex;
    local pageCount = self.CurMission.map_id - 1000;

    self.btn_left:setVisible(false)
    self.btn_right:setVisible(false)

    if pageIndex < pageCount and pageCount > 1 then
        self.btn_right:setVisible(true)
    end 

    if pageIndex > 1 and pageCount > 1  then
        self.btn_left:setVisible(true)
    end
end


function AdventureMissionLayer:removeUI()
    if self.generalHead then
        self.generalHead:removeEvents()
    end
    self.super.removeUI(self);
end

function AdventureMissionLayer:OnShowMissionClick(sender)
    AdventureManager:openAdventureMissionDetailLayer(sender.missionId)
end

--注册事件
function AdventureMissionLayer:registerEvents()
    self.super.registerEvents(self);

    ADD_ALERT_CLOSE_LISTENER(self,self.btn_close);
    self.btn_left.logic = self
    self.btn_left:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onLeftClickHandle),1)
    self.btn_right.logic = self
    self.btn_right:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onRightClickHandle),1)

    self.BrushHandler = function ( data )
        self.CurMission = AdventureMissionManager:getCurrAcrossMission()
        local pageIndex = self.pageView:_getCurPageIndex()
        self:showPage(pageIndex)
    end
    TFDirector:addMEGlobalListener(MissionManager.EVENT_UPDATE_MISSION ,self.BrushHandler)
    if self.generalHead then
        self.generalHead:registerEvents()
    end
end

function AdventureMissionLayer:removeEvents()
    TFDirector:removeMEGlobalListener(MissionManager.EVENT_UPDATE_MISSION ,self.BrushHandler)
end

function AdventureMissionLayer:showMissionById(missionId)
    local mission = AdventureMissionManager:getMissionById(missionId)
    self.CurMission = AdventureMissionManager:getCurrAcrossMission()
    local index = mission.map_id - 1000
    if index > self.CurMission.map_id - 1000 then
        return
    end
    self.guideId = missionId
    self:showPage(index)
    --AdventureManager:openAdventureMissionDetailLayer(missionId)
    
end

return AdventureMissionLayer;
