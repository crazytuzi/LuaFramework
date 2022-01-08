--[[
    场景基础类  处理场景切换时lua资源的释放

    --By: haidong.gan
    --2013/11/11
]]

local BaseScene = class("BaseScene", function(...)
    local scene = CCScene:create();
    return scene;
end)

-- 构造方法
function BaseScene:ctor(data)
    self.data            = data;
    self.mainLayer       = TFLayer:create();
    self.baseLayer       = BaseLayer:new();

    self.sceneEnterEventFunc  = function()
        self:onEnter();
        AlertManager:onEnter();
        LoadingLayer:onEnter();
    end;
    self:addMEListener(TFWIDGET_AFTER_ENTER, self.sceneEnterEventFunc);

    self.sceneExitEventFunc  = function()
        self:onExit();
        AlertManager:onExit();
    end;
    self:addMEListener(TFWIDGET_EXIT, self.sceneExitEventFunc);


    self:addChild(self.mainLayer);
    self.mainLayer:addChild(self.baseLayer);
end

-- 构造方法之后调用
function BaseScene:enter()
    self.baseLayer:enter();
end

-- 每次c++调用onEnter之后调用
function BaseScene:onEnter()
    self.baseLayer:onEnter();
end

-- 每次c++调用onExit之后调用
function BaseScene:onExit()
    if self.baseLayer then
        self.baseLayer:onExit();
    end
end

function BaseScene:onShow()
    self.baseLayer:onShow();
end

-- 添加子panel
function BaseScene:addLayer(layer)
    self.baseLayer:addLayer(layer);
end

-- 删除子panel
function BaseScene:removeLayer(layer, isDispose)
    self.baseLayer:removeLayer(layer, isDispose);
end

function BaseScene:getBaseLayer()
    return self.baseLayer;
end
function BaseScene:getButtomLayer()
    if self.baseLayer ~= nil then
        return self.baseLayer.childArr:front()
    end
end
function BaseScene:getTopLayer()
    if self.baseLayer == nil then
        return nil 
    end

    local index = self.baseLayer.childArr:length()
    while index >= 1 do
        local topLayer = self.baseLayer.childArr:objectAt(index)
        if topLayer ~= nil and topLayer.__cname ~= nil and topLayer.__cname ~= "ToastMessage" and topLayer.__cname ~= "NotifyMessageLayer" and topLayer.__cname ~= "LoadingLayer" then
            return topLayer
        else
            index = index - 1
        end
    end
    return nil
end

-- 场景销毁时调用（replace or pop）
function BaseScene:leave(...)
    self:onExit()
    AlertManager:closeAllAtCurrentScene();
    LoadingLayer:clearForCuurentScene();
    self:unregisterScriptHandler();
    self.sceneEventFunc = nil;
    if self.baseLayer then
        self.baseLayer:dispose();
    end

    self.baseLayer   = nil;

    self.data        = nil;
    self.mainLayer   = nil;
end


return BaseScene;