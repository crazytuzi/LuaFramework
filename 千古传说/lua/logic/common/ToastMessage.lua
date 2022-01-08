--[[
    弹框队列管理类

    --By: haidong.gan
    --2013/11/11
]]

--[[
--用法举例

toastMessage("baby");
toastMessage("baby",ccp(100, 100));

]]
FateMessage = require("lua.logic.common.FateMessage")

function toastMessageHide(text,position,size)
    return toastMessage(text,position,size,ToastMessage.TYPE_SHOW_TO_HIDE)
end

function toastMessageUp(text,position,size)
    return toastMessage(text,position,size,ToastMessage.TYPE_MOVE_TO_UP)
end

function toastMessage(text,position,size,showType,isAdd)
    if isAdd == nil then
        isAdd = false;
    end

    local currentScene = Public:currentScene();
    local toastMessageLayer = currentScene:getChildByName("ToastMessage");

    if not toastMessageLayer or (showType and toastMessageLayer.showType ~= showType) or isAdd then
        toastMessageLayer = ToastMessage:new("lua.uiconfig_mango_new.common.ToastMessage",showType);
    else
        toastMessageLayer:setVisible(false);
        toastMessageLayer:stopAllActions();
        toastMessageLayer:setName("ToastMessage_old")
        toastMessageLayer = ToastMessage:new("lua.uiconfig_mango_new.common.ToastMessage",showType);
    end   


    if not position then
        position = ToastMessage.DEFUALT_POSITION
    end
    toastMessageLayer:setPosition(position);

    TFDirector:getChildByPath(toastMessageLayer, 'text'):setText(text);
    TFDirector:getChildByPath(toastMessageLayer, 'text'):setFontSize(28);
   local bgImg = TFDirector:getChildByPath(toastMessageLayer, 'bg');
   bgImg:setSize(ccs(math.max(math.min(bgImg:getSize().width * string.utf8len(text)/20, bgImg:getSize().width),400)  ,bgImg:getSize().height)) 

    if size then
       bgImg:setSize(size);
    end

    toastMessageLayer:beginToast();
    return toastMessageLayer;

end


local ToastMessage = class("ToastMessage", BaseLayer)
ToastMessage.TYPE_MOVE_TO_UP   = 0;
ToastMessage.TYPE_SHOW_TO_HIDE = 1;

ToastMessage.LAYER_TYPE_PATH   = 0;
ToastMessage.LAYER_TYPE_LAYER  = 1;

ToastMessage.DEFUALT_POSITION  = ccp(GameConfig.WS.width/2, GameConfig.WS.height/2 - 80);

function ToastMessage:ctor(data,showType,layerType)
    self.super.ctor(self)

    self.showType = showType or ToastMessage.TYPE_MOVE_TO_UP;

    layerType = layerType or ToastMessage.LAYER_TYPE_PATH;
    if layerType == ToastMessage.LAYER_TYPE_PATH then
        self:init(data)
    end

    if layerType == ToastMessage.LAYER_TYPE_LAYER then
        self:addLayer(data);
    end
end

function ToastMessage:onExit()
    self.super.onExit(self)
    local currentScene = self:getParent();
    currentScene:removeLayer(self);
end

function ToastMessage:ctorLayer(layer,showType)
    self.super.ctor(self)
    self.showType=showType;

end

function ToastMessage:initUI(ui)
    self.super.initUI(self,ui);
end

function ToastMessage:beginToast()
    local currentScene = Public:currentScene();
    self:setZOrder(500);
    self:setName("ToastMessage");

    if not self:getParent() then
        currentScene:addLayer(self);
    end

    local toY = self:getPosition().y + 80;
    local toX = self:getPosition().x;
    
    if toY > GameConfig.WS.height - 50 then
       toY = GameConfig.WS.height - 50;
    end

    self:setOpacity(150)

    if self.showType == ToastMessage.TYPE_MOVE_TO_UP then
        self.toastTween = {
          target = self,
          {
            duration = 0.1,
            x = toX,
            y = toY,
            alpha = 0.9,
          },
          {
            duration = 0.05,
            y = toY +2,
          },
          {
            duration = 0.05,
            y = toY -1,
          },
          {
             duration = 0.1,
             alpha = 1,
          },
          { 
            duration = 0,
            delay = 1 
          },
          {
            duration = 0.1,
            y = toY - 4,
            alpha = 0.7,
          },
          {
            duration = 0.1,
            y = toY + 2,

          },
          {
             duration = 0,
          
          },
          {
             duration = 0.1,
             alpha = 0,
             y = toY + 100,
          },
          {
            duration = 0,
            onComplete = function() 
                local currentScene = Public:currentScene();
                currentScene:removeLayer(self);
           end
          }
        }
    end

    if self.showType == ToastMessage.TYPE_SHOW_TO_HIDE then
        self.toastTween = {
          target = self,
          { 
            duration = 0,
            delay = 2 
          },
          {
             duration = 1,
             alpha = 0.2,
          },
          {
            duration = 0,
            onComplete = function() 
                local currentScene = Public:currentScene();
                currentScene:removeLayer(self);
           end
          }
        }
    end

    TFDirector:toTween(self.toastTween)
end

function ToastMessage:removeUI()
    self.super.removeUI(self)
    TFDirector:killTween(self.toastTween)
    self.toastTween = nil;
    self.showType=nil;
end


function ToastMessage:showSureMessage( msg , okhandle , cancelhandle )
    local layer = require('lua.logic.common.OperateSure'):new()
    layer:setType( nil )
    if msg then
        layer:setMsg( msg )
    end
    layer:setBtnHandle(okhandle , cancelhandle )
    AlertManager:addLayer(layer)
    AlertManager:show()

    return layer;
end
return ToastMessage;