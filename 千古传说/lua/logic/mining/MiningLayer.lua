--[[
******采矿界面*******
    -- by yao
    -- 2016/1/12
]]

local MiningLayer = class("MiningLayer", BaseLayer)

function MiningLayer:ctor(data)
    self.super.ctor(self,data)
    self.pageItemArr = {}       --采矿的page
    self.roleMineInfo = nil
    self.pageIndex = 0          --当前在第几页

    self:init("lua.uiconfig_mango_new.mining.miningLayer")
end

function MiningLayer:initUI(ui)
	self.super.initUI(self,ui)

    self.generalHead = CommonManager:addGeneralHead( self ,10)
    self.generalHead:setData(ModuleType.Mining,{HeadResType.JIEKUANGLING,HeadResType.COIN,HeadResType.SYCEE})

    self.btn_lqyj       = TFDirector:getChildByPath(ui, "btn_lqyj")
    self.btn_guizhe     = TFDirector:getChildByPath(ui, "btn_guizhe")
    self.btn_zhandoujilu= TFDirector:getChildByPath(ui, "btn_zhandoujilu")
    self.btn_djbz       = TFDirector:getChildByPath(ui, "btn_djbz")
    self.btn_last       = TFDirector:getChildByPath(ui, "btn_last")
    self.btn_next       = TFDirector:getChildByPath(ui, "btn_next")
    self.btn_hkRecord   = TFDirector:getChildByPath(ui, "btn_hkRecord")
    self.imageBg        = TFDirector:getChildByPath(ui, "bg_caikuang")
    self.guyongcishu    = TFDirector:getChildByPath(ui, "txt_guyongcishu")
    --self.img_qianxiang  = TFDirector:getChildByPath(ui, "img_qianxiang")
    self.txt_leijishouru= TFDirector:getChildByPath(ui, "txt_leijishouru")
    self.txt_jrybgy     = TFDirector:getChildByPath(ui, "txt_jrybgy")
    self.bg_guyongcishu = TFDirector:getChildByPath(ui, "bg_guyongcishu")
    self.bg_leijishouru = TFDirector:getChildByPath(ui, "bg_leijishouru")

    self.bg_guyongcishu:setVisible(false)
    self.bg_leijishouru:setVisible(false)

    self.btn_last.logic = self
    --self.btn_last:setVisible(false)
    self.btn_last:setZOrder(3)
    self.btn_next.logic = self
    --self.btn_next:setVisible(false)
    self.btn_next:setZOrder(3)
    --self.txt_jrybgy:setText("本周已被雇佣：")
    self.txt_jrybgy:setText(localizable.MiningLayer_text1)

    self.panel_list = TFDirector:getChildByPath(ui,"panel_list")
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
    self.panel_list:addChild(pageView,2)

    self:showUIData()
end

function MiningLayer:loadData(page)
    self.pageView:_removeAllPages();
    self.pageView:setMaxLength(2)
    self.pageList        = {};
    self.pageView:InitIndex(page);
    self:showInfoForPage(page)
    self.pageIndex = page
    --MiningManager:setPage(page)
    --print("page == ",page)
    if page == 1 then
        self:stopeffect(miningmineEffect)
        if miningTimer ~= nil then
            TFDirector:removeTimer(miningTimer)
            miningTimer = nil
        end
    end
end

function MiningLayer:removeUI()
    MiningManager:setIsOpenMiningLayer(false)
    for k,v in pairs(self.pageItemArr) do
        v:removeEvents()
    end
    self:stopeffect(miningmineEffect)
    if miningTimer ~= nil then
        TFDirector:removeTimer(miningTimer)
        miningTimer = nil
    end 
    self.super.removeUI(self)
end

-----断线重连支持方法
function MiningLayer:onShow()
    self.super.onShow(self)
    self.generalHead:onShow()
end

function MiningLayer:registerEvents()
    self.super.registerEvents(self)

    if self.generalHead then
        self.generalHead:registerEvents()
    end

    self.btn_lqyj:addMEListener(TFWIDGET_CLICK, audioClickfun(self.LingquYongjing))
    self.btn_guizhe:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onGuizeCallBack))
    self.btn_zhandoujilu:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onZhandouJiluCallBack))
    self.btn_djbz:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onDajieBuzhengCallBack))
    self.btn_last:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onShowLastPage))
    self.btn_next:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onShowNextPage))
    self.btn_hkRecord:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onGuardRecord))

    self.eventUpdateMineralInfo = function(event)
        self:showUIData()
        self:showInfoForPage(self.pageIndex)
        --print("updata mininglayer ")
    end;
    TFDirector:addMEGlobalListener(MiningManager.EVENT_UPDATE_MINERALINFO, self.eventUpdateMineralInfo)
end

function MiningLayer:removeEvents()
    self.btn_lqyj:removeMEListener(TFWIDGET_CLICK)
    self.btn_guizhe:removeMEListener(TFWIDGET_CLICK)
    self.btn_zhandoujilu:removeMEListener(TFWIDGET_CLICK)
    self.btn_djbz:removeMEListener(TFWIDGET_CLICK)
    self.btn_last:removeMEListener(TFWIDGET_CLICK)
    self.btn_next:removeMEListener(TFWIDGET_CLICK)
    self.btn_hkRecord:removeMEListener(TFWIDGET_CLICK)

    TFDirector:removeMEGlobalListener(MiningManager.EVENT_UPDATE_MINERALINFO, self.eventUpdateMineralInfo)
    self.eventUpdateMineralInfo = nil

    if self.generalHead then
        self.generalHead:removeEvents()
    end
    self.super.removeEvents(self)
end

function MiningLayer:dispose()
    self.super.dispose(self)
    self.generalHead:onShow()
end

--添加滑动页
function MiningLayer:addPage(pageIndex)
    local pagepanel = TFPanel:create();
    pagepanel:setSize(self.panel_list:getContentSize())

    if pageIndex == 1 then
        local pageItem = require('lua.logic.mining.LootMineralItem'):new()
        self.pageItemArr[1] = pageItem
        pagepanel:addChild(pageItem,3)
        pageItem:setData()
    elseif pageIndex == 2 then
        -- local pageItem = require('lua.logic.mining.MiningItem'):new()
        local pageItem = require('lua.logic.mining.MiningItem_new'):new()
        self.pageItemArr[2] = pageItem
        pagepanel:addChild(pageItem,3)
        pageItem:setData()
    end
    self.pageList[pageIndex] = pagepanel; 
    return pagepanel;
end

function MiningLayer:onPageChange()
    local pageIndex = self.pageView:_getCurPageIndex()
    MiningManager:setPage(pageIndex)
    self:showInfoForPage(pageIndex);
    --print("page2 == ",pageIndex)

    if pageIndex == 1 then
        self:stopeffect(miningmineEffect)
        if miningTimer ~= nil then
            TFDirector:removeTimer(miningTimer)
            miningTimer = nil
        end 
    end
end

function MiningLayer:showInfoForPage(pageIndex)
    if pageIndex == 1 then
        self.btn_last:setVisible(false)
        self.btn_next:setVisible(true)
        self.btn_djbz:setVisible(true)
    elseif pageIndex == 2 then
        self.btn_last:setVisible(true)
        self.btn_next:setVisible(false)
        self.btn_djbz:setVisible(false)
    end
    self.pageIndex = pageIndex
    self.pageItemArr[pageIndex]:setData()
end

function MiningLayer:showUIData()
    self.roleMineInfo = MiningManager:getRoleMineInfo()
    self.guyongcishu:setText(self.roleMineInfo.hireTime)
    self.txt_leijishouru:setText(self.roleMineInfo.brokerageTotal)
    if self.roleMineInfo.brokerageTotal > 0 then
        self.btn_lqyj:setTouchEnabled(true)
        self.btn_lqyj:setGrayEnabled(false)
        self.btn_hkRecord:setTextureNormal("ui_new/mining/img_qianxiang1.png")
    else
        self.btn_lqyj:setTouchEnabled(false)
        self.btn_lqyj:setGrayEnabled(true)
        self.btn_hkRecord:setTextureNormal("ui_new/mining/img_qianxiang2.png")
    end
end

--领取佣金按钮回调
function MiningLayer.LingquYongjing(sender)
    MiningManager:requestBrokerage()
end

--规则按钮回调
function MiningLayer.onGuizeCallBack(sender)
    CommonManager:showRuleLyaer( 'caikuang' )
end

--战斗记录按钮回调
function MiningLayer.onZhandouJiluCallBack(sender)
    MiningManager:gotoFightReport()
end

--打劫布阵按钮回调
function MiningLayer.onDajieBuzhengCallBack(sender)
    -- CardRoleManager:openRoleList(false);
    MiningManager:EnterMainArmy()
end

--左翻按钮回调
function MiningLayer.onShowLastPage(sender)
    local self = sender.logic
    local pageIndex = self.pageView:getCurPageIndex() ;
    MiningManager:setPage(pageIndex - 1)
    self.pageView:scrollToPage(pageIndex - 1);
    --print("page3 == ",pageIndex-1)
end

--右翻按钮回调
function MiningLayer.onShowNextPage(sender)
    local self = sender.logic
    local pageIndex = self.pageView:getCurPageIndex() ;
    MiningManager:setPage(pageIndex + 1)
    self.pageView:scrollToPage(pageIndex + 1); 
    --print("page4 == ",pageIndex+1)
end

--护矿记录按钮回调
function MiningLayer.onGuardRecord(sender)
    MiningManager:gotoMiningResult()
end

--关闭音效
function MiningLayer:stopeffect(effect)
    if effect ~= nil then
        TFAudio.stopEffect(effect)
        effect = nil
    end
end

return MiningLayer