--[[
    弹框队列管理类

    --By: haidong.gan
    --2013/11/11
]]

--[[
--用法举例

fateMessage("baby");

]]
local fateMessage_text = ""
function fateMessage(text,showType)

	if fateMessage_text == "" then
		fateMessage_text = text
		TFDirector:addTimer( 1, 1, nil ,function ()
			local fateMessageLayer = FateMessage:new("lua.uiconfig_mango_new.common.FateMessage",showType);
			fateMessageLayer:setPosition(FateMessage.DEFUALT_POSITION);
			local text_widget = TFDirector:getChildByPath(fateMessageLayer, 'text')
			local text_title = TFDirector:getChildByPath(fateMessageLayer, 'text_title')
			text_widget:setText(fateMessage_text);
			text_widget:setFontSize(28);
			local bgImg = TFDirector:getChildByPath(fateMessageLayer, 'bg');
			bgImg:setSize(ccs(math.max(math.min(bgImg:getSize().width * string.utf8len(fateMessage_text)/20, bgImg:getSize().width),400)  ,bgImg:getSize().height))
			text_title:setPositionX(text_widget:getPositionX()-text_widget:getSize().width/2)
			fateMessageLayer:beginToast();
			fateMessage_text = ""
		end)
	else
    -- 已经显示的不做添加
    local find = string.find(fateMessage_text, text)
    if find then
        return
    end
		fateMessage_text = fateMessage_text .. "、" .. text
	end
end

-- 牛逼的策划非要分开显示
local fateMessageNum  = 0
local fateMessageList = {}
function fateMessageDelay(fateList)
    local fatetext = ""

    print("fateMessageDelay fateList = ", fateList)

    for k,text in pairs(fateList) do
        local find = string.find(fatetext, text)
        if find == nil then
          fatetext = fatetext .. "、" .. text

          fateMessageNum = fateMessageNum + 1
          fateMessageList[fateMessageNum] = text
        end
    end

    print("fateMessageNum = ", fateMessageNum)
    print("fateMessageList = ", fateMessageList)

    for i=1,fateMessageNum do
      local oneFateMsg = fateMessageList[i]
        TFDirector:addTimer(400 * i, 1, nil ,function ()
        local fateMessageLayer = FateMessage:new("lua.uiconfig_mango_new.common.FateMessage",showType);
        fateMessageLayer:setPosition(FateMessage.DEFUALT_POSITION);
        local text_widget = TFDirector:getChildByPath(fateMessageLayer, 'text')
        local text_title = TFDirector:getChildByPath(fateMessageLayer, 'text_title')
        text_widget:setText(oneFateMsg);
        text_widget:setFontSize(28);
        local bgImg = TFDirector:getChildByPath(fateMessageLayer, 'bg');
        bgImg:setSize(ccs(math.max(math.min(bgImg:getSize().width * string.utf8len(oneFateMsg)/20, bgImg:getSize().width),400)  ,bgImg:getSize().height))
        text_title:setPositionX(text_widget:getPositionX()-text_widget:getSize().width/2)
        fateMessageLayer:beginToast();
        oneFateMsg = ""
      end)
    end

    fateMessageList = {}
    fateMessageNum = 0
end


local FateMessage = class("FateMessage", BaseLayer)
FateMessage.TYPE_MOVE_TO_UP   = 0;
FateMessage.TYPE_SHOW_TO_HIDE = 1;

FateMessage.LAYER_TYPE_PATH   = 0;
FateMessage.LAYER_TYPE_LAYER  = 1;

FateMessage.DEFUALT_POSITION  = ccp(GameConfig.WS.width/2, GameConfig.WS.height/2 - 80);

function FateMessage:ctor(data,showType,layerType)
    self.super.ctor(self)

    self.showType = showType or FateMessage.TYPE_MOVE_TO_UP;

    layerType = layerType or FateMessage.LAYER_TYPE_PATH;
    if layerType == FateMessage.LAYER_TYPE_PATH then
        self:init(data)
    end

    if layerType == FateMessage.LAYER_TYPE_LAYER then
        self:addLayer(data);
    end
end

function FateMessage:onExit()
    self.super.onExit(self)
    local currentScene = self:getParent();
    currentScene:removeLayer(self);
end

function FateMessage:ctorLayer(layer,showType)
    self.super.ctor(self)
    self.showType=showType;

end

function FateMessage:initUI(ui)
    self.super.initUI(self,ui);
end

function FateMessage:beginToast()
    local currentScene = Public:currentScene();
    self:setZOrder(500);
    self:setName("FateMessage");

    if not self:getParent() then
        currentScene:addLayer(self);
    end

    local toY = self:getPosition().y + 80;
    local toX = self:getPosition().x;
    
    if toY > GameConfig.WS.height - 50 then
       toY = GameConfig.WS.height - 50;
    end

    self:setOpacity(150)

    if self.showType == FateMessage.TYPE_MOVE_TO_UP then
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

    if self.showType == FateMessage.TYPE_SHOW_TO_HIDE then
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

function FateMessage:removeUI()
    self.super.removeUI(self)
    TFDirector:killTween(self.toastTween)
    self.toastTween = nil;
    self.showType=nil;
end


function FateMessage:showSureMessage( msg , okhandle , cancelhandle )
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
return FateMessage;