--[[
******设置 主页面*******

    -- by haidong.gan
    -- 2013/11/27
]]
local SettingLayer = class("SettingLayer", BaseLayer);

local ContentLayer = require('lua.logic.setting.ContentLayer')


CREATE_SCENE_FUN(SettingLayer);
CREATE_PANEL_FUN(SettingLayer);

SettingLayer.LIST_ITEM_WIDTH = 210; 
SettingLayer.LIST_REWARD_ITEM_WIDTH = 380; 

function SettingLayer:ctor(data)
    self.super.ctor(self,data);
    self:init("lua.uiconfig_mango_new.setting.SettingLayer");
end

function SettingLayer:initUI(ui)
    self.super.initUI(self,ui);

    self.btn_close      = TFDirector:getChildByPath(ui, 'btn_close');

    self.Panel_tiaomu   = TFDirector:getChildByPath(ui, 'Panel_tiaomu');

    self.btn_setMusic         = TFDirector:getChildByPath(ui, 'Button_yinyue');
    self.btn_setVolume        = TFDirector:getChildByPath(ui, 'Button_yinxiao');

    self.btn_showContact        = TFDirector:getChildByPath(ui, 'btn_showContact');
    self.btn_gotoLogin          = TFDirector:getChildByPath(ui, 'btn_gotoLogin');
  
    self:loadSettingInfo();

    self:refreshPush()

    self.btn_showContact:setVisible(MainPlayer:getServerSwitchStatue(ServerSwitchType.LiBaoMa))
end

function SettingLayer:onShow()
    self.super.onShow(self)
    self:refreshBaseUI();
end

function SettingLayer:refreshBaseUI()

end

function SettingLayer:loadSettingInfo()
   local config = SettingManager.settingConfig;
   
   if config.isOpenMusic then
      self.btn_setMusic:setTextureNormal("ui_new/setting/xt_yinyuekai.png")
      self.btn_setMusic:setTexturePressed("ui_new/setting/xt_yinyuekai.png")
   else
      self.btn_setMusic:setTextureNormal("ui_new/setting/xt_yinyueguan.png")
      self.btn_setMusic:setTexturePressed("ui_new/setting/xt_yinyueguan.png")
   end

   if config.isOpenVolume then
      self.btn_setVolume:setTextureNormal("ui_new/setting/xt_yinxiaokai.png")
      self.btn_setVolume:setTexturePressed("ui_new/setting/xt_yinxiaokai.png")
   else
      self.btn_setVolume:setTextureNormal("ui_new/setting/xt_yinxiaoguan.png")
      self.btn_setVolume:setTexturePressed("ui_new/setting/xt_yinxiaoguan.png")
   end

end

function SettingLayer:removeUI()
    self.super.removeUI(self);
    self.btn_close    = nil
    self.Panel_tiaomu   = nil
    self.btn_setMusic   = nil
    self.btn_setVolume    = nil
    self.btn_showContact    = nil
    self.btn_gotoLogin    = nil
end


function SettingLayer.onSetMusicClickHandle(sender)
    local self = sender.logic;
    SettingManager:changeIsOpenMusic();
    self:loadSettingInfo();
end
function SettingLayer.onSetVolumeClickHandle(sender)
    local self = sender.logic;
    SettingManager:changeIsOpenVolume();
    self:loadSettingInfo();
end
function SettingLayer.onSetChatClickHandle(sender)
    local self = sender.logic;
    SettingManager:changeIsOpenChat();
    self:loadSettingInfo();
end
function SettingLayer.onShowHelpClickHandle(sender)
    local self = sender.logic;
    SettingManager:showHelpLayer();
end
function SettingLayer.onShowActivityClickHandle(sender)
    local self = sender.logic;
    SettingManager:showActivityLayer();
end
function SettingLayer.onShowSendBugClickHandle(sender)
    local self = sender.logic;
    SettingManager:showSendBugLayer();
end
function SettingLayer.onShowContactClickHandle(sender)
    local self = sender.logic;
    SettingManager:showExchangeLayer();
end
function SettingLayer.onGotoLoginClickHandle(sender)
    local self = sender.logic;
    -- SettingManager:gotoLoginLayer();
    SettingManager:LoginOut();
end

--注册事件
function SettingLayer:registerEvents()
   self.super.registerEvents(self);
 
   ADD_ALERT_CLOSE_LISTENER(self,self.btn_close);
   self.btn_close:setClickAreaLength(100);

   self.btn_setMusic.logic=self;
   self.btn_setVolume.logic=self;
   self.btn_showContact.logic=self;
   self.btn_gotoLogin.logic=self;

   self.btn_setMusic:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onSetMusicClickHandle),1);
   self.btn_setVolume:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onSetVolumeClickHandle),1);
   self.btn_showContact:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onShowContactClickHandle),1);
   self.btn_gotoLogin:addMEListener(TFWIDGET_CLICK,  audioClickfun(self.onGotoLoginClickHandle),1);


      --服务器开关变更
    self.serverSwitchChange = function(event)
        if event.data[1] == ServerSwitchType.LiBaoMa then
            self.btn_showContact:setVisible(MainPlayer:getServerSwitchStatue(ServerSwitchType.LiBaoMa))
        end
    end
    TFDirector:addMEGlobalListener(MainPlayer.ServerSwitchChange, self.serverSwitchChange)
    
    --added by wuqi
    self.vipShowChange = function(event)
        self:refreshPush()
    end
    TFDirector:addMEGlobalListener(SettingManager.SETTING_SAVE_CONFIG_RESULT, self.vipShowChange)
end

function SettingLayer:removeEvents()

    TFDirector:removeMEGlobalListener(MainPlayer.ServerSwitchChange, self.serverSwitchChange)
    self.serverSwitchChange = nil

    TFDirector:removeMEGlobalListener(SettingManager.SETTING_SAVE_CONFIG_RESULT, self.vipShowChange)
    self.vipShowChange = nil
end


function SettingLayer:refreshPush()
    if self.pushList == nil then
        self.pushList = TFTableView:create()
        self.pushList.logic = self
        self.pushList:setTableViewSize(self.Panel_tiaomu:getSize())
        self.pushList:setDirection(TFTableView.TFSCROLLVERTICAL)
        self.pushList:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)

        self.pushList:addMEListener(TFTABLEVIEW_SIZEFORINDEX, SettingLayer.cellSizeForTable)
        self.pushList:addMEListener(TFTABLEVIEW_SIZEATINDEX, SettingLayer.tableCellAtIndex)
        self.pushList:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, SettingLayer.numberOfCellsInTableView)
        self.Panel_tiaomu:addChild(self.pushList)
    end
    self.pushList:reloadData()
end


function SettingLayer.cellSizeForTable(table,idx)
    return 75,480
end
function SettingLayer.numberOfCellsInTableView(table,idx)
    return SettingManager:getPushList():length()
end

function SettingLayer.tableCellAtIndex(table, idx)

    local cell = table:dequeueCell()
    if nil == cell then
        table.cells = table.cells or {}
        cell = TFTableViewCell:create()
        table.cells[cell] = true
        local content = ContentLayer:new()
        cell:addChild(content)
        cell.content = content
    end


    cell.content:loadDataById(idx + 1)

    return cell
end

return SettingLayer;
