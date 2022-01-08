--[[
    弹框队列管理类
    特殊说明：此类在战斗场景中，不做弹出处理，只做存错处理，当退出战斗场景时才弹出

    --By: haidong.gan
    --2013/11/11
]]

--[[
--用法举例

1、注册关闭按钮事件
   ADD_ALERT_CLOSE_LISTENER(self, self.closeBtn);

2、将弹出框加入队列中，显示队列中的最底层弹出框
   local layer = requireNew("lua.logic.army.DetailMoreLayer"):new();
   AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY);
   AlertManager:show();

4、关闭弹出框
   AlertManager:close();
]]

-- 添加关闭窗口按钮事件
function ADD_ALERT_CLOSE_LISTENER(classObj,btnObj,clickEffectType) 
    clickEffectType = clickEffectType or 1;
   if btnObj and classObj then
     if classObj.closeBtnClickHandle == nil then
        function classObj.closeBtnClickHandle(sender)
            AlertManager:close();
        end
     end
     classObj.logic = classObj;
     btnObj:addMEListener(TFWIDGET_CLICK, audioClickfun(classObj.closeBtnClickHandle,play_fanhui),clickEffectType);
   end
end
function ADD_ALERT_CLOSEALL_LISTENER(classObj,btnObj,clickEffectType) 
    clickEffectType = clickEffectType or 1;
   if btnObj and classObj then
     if classObj.closeAllBtnClickHandle == nil then
        function classObj.closeAllBtnClickHandle(sender)
            AlertManager:closeAll();
        end
     end
     classObj.logic = classObj;
     btnObj:addMEListener(TFWIDGET_CLICK, audioClickfun(classObj.closeAllBtnClickHandle,play_fanhui),clickEffectType);
  end
end


-- 添加关闭窗口按钮事件
function ADD_KEYBOARD_CLOSE_LISTENER(classObj, panel) 
    if CC_TARGET_PLATFORM ~= CC_PLATFORM_WIN32 then
        if classObj == nil or panel == nil then
            return
        end
        panel:setKeyboardEnabled(true)
        if classObj.closeBtnClickHandle == nil then
            function classObj.closeBtnClickHandle(sender, keycode)
                if AlertManager.BACK_SPACE == false then
                    -- 调平台的推出
                    if HeitaoSdk then
                        HeitaoSdk.loginExit()
                    end
                    return
                end
                if keycode == me.KeyCode.BACK_SPACE then 
                    print("点击了回退按钮")
                    ---->  是否有webview
                    if TFWebView.close() then
                        return
                    end
--                   <-----------------------
                    play_press()
                    local topLayer = AlertManager:getTopLayer();
                    local currentScene = Public:currentScene();
                    if topLayer and topLayer.toScene == currentScene and not topLayer.isCanNotClose then
                        AlertManager:closeLayer(topLayer);
                    else
                        if currentScene:getTopLayer() and currentScene:getTopLayer().__cname =="FightResultLayer" then
                            FightManager:LeaveFight()
                        else
                            local layer = CommonManager:showOperateSureLayer(
                                    function()
                                        me.Director:endToLua()
                                    end,
                                    nil,
                                    {
                                    title = "结束游戏",
                                    msg = "是否退出游戏？",
                                    okText = "是",
                                    cancelText = "否",
                                    showtype = AlertManager.BLOCK_AND_GRAY,
                                    uiconfig = "lua.uiconfig_mango_new.common.OperateSure3"
                                    }
                            )
                        end
                    end
       
                end
            end
        end
        panel:addMEListener(TFWIDGET_KEYDOWN, classObj.closeBtnClickHandle)
    end
end

local AlertManager = class("AlertManager");
local LayerCacheData   = require('lua.table.t_s_layer_cache')            --角色技能
local LayerCacheLength = 8
function AlertManager:ctor( )
    self:init();
end

function AlertManager:init( )
    self.szChangType = TFSceneChangeType_Replace
    self.layerQueue = TFArray:new();
    self.layerCache = MEMapArray:new();
    -- self.layerCache = {};
end

function AlertManager:addLayerCacheByKey( key , obj )
    -- print("self.layerCache:length() = ",self.layerCache:length())
    if self.layerCache:length() >= LayerCacheLength then
        -- print("begin kill cache")
        self:layerCacheSort()
        local layer = self.layerCache:back()
        if layer.priority < obj.priority then
            return false
        end
        local layer = self.layerCache:objectByID(layer.cacheKey)
        if layer then
            -- print("remove cacheKey = ",layer.cacheKey)
            self.layerCache:removeById(layer.cacheKey)
            layer.isCache = false
            layer:release();
        end
    end
    self.layerCache:pushbyid(key,obj)
    obj.isCache = true
    return true
end
function sortList( layer1,layer2 )
    if layer1.priority < layer2.priority then
        return true
    end
    return false
end
function AlertManager:layerCacheSort()
    self.layerCache:sort(sortList)
end

-- 每次c++调用onExit之后调用
function AlertManager:onExit()

end
-- 每次c++调用onEnter之后调用
function AlertManager:onEnter()
     self:show();
end

--阻塞模式
AlertManager.NONE = 0;             --事件不阻塞，不显示黑底
AlertManager.BLOCK = 1;            --事件阻塞，不显示黑底
AlertManager.BLOCK_AND_GRAY = 2;   --事件阻塞，显示黑底
AlertManager.BLOCK_CLOSE = 3;   --事件阻塞，不显示黑底,点击任意区域关闭
AlertManager.BLOCK_AND_GRAY_CLOSE = 4;   --事件阻塞，显示黑底，点击任意区域关闭

AlertManager.BACK_SPACE = false;     --返回键是否开启

--动画模式 layer.tweentype = AlertManager.TWEEN_1;
AlertManager.TWEEN_NONE = 0;  --立即显示，无动画
AlertManager.TWEEN_1 = 1;     --方案1
AlertManager.TWEEN_2 = 2;     --方案1



-- 往栈中添加添加弹出页面，显示场景为调用Show时的当前场景
function AlertManager:addLayer(layer,block,tweentype)
     self:addLayerToQueue(layer,block,tweentype);
end

function AlertManager:addLayerByFile(fileName,block,tweentype)
    return self:addLayerToQueueAndCacheByFile(fileName,block,tweentype);
end
function AlertManager:_addLayerByFile(fileName,block,tweentype)
    local layer = nil
   if self.layerCache:objectByID(fileName) then
       -- print("use layer from cache:" .. fileName );
       layer = self.layerCache:objectByID(fileName);
    else
       layer = requireNew(fileName):new();
    end

    layer.name = fileName
    self:addLayerToQueue(layer,block,tweentype)
    return layer
end

-- 往栈中添加添加弹出页面，并设置指定显示场景
function AlertManager:addSceneLayerToQueue(layer,toScene,block,tweentype)
    if toScene == nil then
        print("Argument toScene must be non-nil");
        return ;
    end
    layer.toScene = toScene;
    self:addLayerToQueue(layer,block,tweentype);
end

--加入到显示队列中
function AlertManager:addLayerToQueue(layer,block,tweentype)
    if layer == nil then
          print("Argument layer must be non-nil");
        return ;
    end
    if self.layerQueue:indexOf(layer) ~=-1 then
        print("Layer already added. It can't be added again");
          return ;
    end

    layer.block = block or AlertManager.BLOCK_AND_GRAY;
    layer.tweentype = tweentype or AlertManager.TWEEN_NONE;

    layer.isShow = false;
    layer.isTop = false;
    layer:retain();
    self.layerQueue:pushBack(layer);
end

function AlertManager:removeLayerFromQueue(layer)
   if layer and self.layerQueue:indexOf(layer) ~= -1 then
        if self:isLayerInCache(layer) then
            layer:removeEvents()
        else
            --layer:dispose()
        end
        layer:release();
        self.layerQueue:removeObject(layer);
    else
        print("Can not find the layer in AlertManager");
    end
end

--加入到缓存中
function AlertManager:addLayerToCache(layer, cacheKey )
    local layerCacheInfo = LayerCacheData:objectByID(cacheKey)
    if layerCacheInfo == nil or layerCacheInfo.isCache == false then
        return layer
    end
    local _layer = self.layerCache:objectByID(layer.cacheKey)
    if _layer and  _layer ~= layer then
        -- print("cacheKey already added to cache, will detroy:" .. cacheKey );
        self:removeLayerFromCache(layer.cacheKey);
        _layer = nil
    end

    if not _layer then
        -- layer.isCache = true;
        layer.cacheKey = cacheKey;
        layer.priority = layerCacheInfo.priority
        if self:addLayerCacheByKey( cacheKey , layer ) then
            layer:retain();
        end
        -- layer:setPosition(ccp(10000,10000))
        -- self.layerCache[cacheKey] = layer;
    end

    return layer;
end

--通过文件名加入到缓存中
function AlertManager:addLayerToCacheByFile(fileName,block,tweentype)
    local layer = self.layerCache:objectByID(fileName);
    if not layer then
       layer = requireNew(fileName):new();
       layer.name = fileName
       self:addLayerToCache(layer, fileName);
    end
    return layer;
end

--判断该层是否在缓存中
function AlertManager:isLayerInCache( layer )
    for v in self.layerCache:iterator() do
        if v == layer then
            return true
        end
    end
    return false
end
--是否需要加入缓存中
function AlertManager:isNeedAddToCache( fileName )
    local layerCacheInfo = LayerCacheData:objectByID(fileName)
    print("fileName = ",fileName)
    print("layerCacheInfo = ",layerCacheInfo)
    if layerCacheInfo == nil or layerCacheInfo.isCache == false then
        return false
    end
    return true
end
--通过文件名加入到队列中，并缓存
function AlertManager:addLayerToQueueAndCacheByFile(fileName,block,tweentype)
    if self:isNeedAddToCache(fileName) == false then
        return self:_addLayerByFile(fileName,block,tweentype);
    end
    local layer = nil
    if self.layerCache:objectByID(fileName) then
        print("use layer from cache:" .. fileName );
        layer = self.layerCache:objectByID(fileName);
        layer:registerEvents()
    else
        layer = self:addLayerToCacheByFile(fileName,block,tweentype);
        layer.name = fileName
    end

    self:addLayerToQueue(layer,block,tweentype);
    return layer;
end

-- 显示栈的最顶层UI（弹出框）
function AlertManager:show()
    -- if CommonManager:getConnectionStatus() == false then
    --     return
    -- end
    
    if self.layerQueue:length() > 0 then
        local layer = self.layerQueue:back();
        self:showLayer(layer);
         PlayerGuideManager:doGuide()
    else
        print("No more view to alert");
        local currentScene = Public:currentScene();
        if currentScene and currentScene.getButtomLayer then
            local baseLayer = Public:currentScene():getButtomLayer();
            if baseLayer and baseLayer.onShow then
                baseLayer:onShow();
                 PlayerGuideManager:doGuide()
            end
        end
    end
end
-- 显示UI（弹出框）
function AlertManager:showLayerByName(name)
    local layer = self:getLayerByName(name);
    if layer then
        self:showLayer(layer);
    else
        print("Can not find the layer :" .. name);
    end
end

-- 显示UI（弹出框）
function AlertManager:showLayer(layer)
    if not layer.isShow then
        if not layer.toScene then
            local currentScene = Public:currentScene();
            -- print("currentScene.name:" .. currentScene.__cname);
            if (currentScene.__cname == "FightResultScene" or  currentScene.__cname == "FightScene") then
                return;
            end
            layer.toScene = currentScene;
        end
        if layer.toScene.addLayer then
            for tlayer in self.layerQueue:iterator() do
                if tlayer.isTop then
                    tlayer.isTop = false;
                    tlayer:onHide();
                end
            end 
            layer.isTop = true;

            local blockUI = nil;
            if layer.block == AlertManager.BLOCK or layer.block == AlertManager.BLOCK_CLOSE then 
               blockUI = TFPanel:create();
               blockUI:setSize(GameConfig.WS);
               blockUI:setTouchEnabled(true); 

               if layer.block == AlertManager.BLOCK_CLOSE then 
                    blockUI:addMEListener(TFWIDGET_CLICK, audioClickfun(function()
                        self:close();
                    end
                    ,play_fanhui));
                end

            elseif layer.block == AlertManager.BLOCK_AND_GRAY or layer.block == AlertManager.BLOCK_AND_GRAY_CLOSE  then 

               blockUI = TFPanel:create();
               blockUI:setSize(GameConfig.WS);
               blockUI:setTouchEnabled(true); 

               blockUI:setBackGroundColorType(TF_LAYOUT_COLOR_SOLID);
               blockUI:setBackGroundColorOpacity(220);
               blockUI:setBackGroundColor(ccc3(  3,   0,   35));
                -- blockUI:setOpacity(0)
               if layer.block == AlertManager.BLOCK_AND_GRAY_CLOSE then 
                    blockUI:addMEListener(TFWIDGET_CLICK, audioClickfun(function()
                        self:close();
                    end
                    ,play_fanhui));
                end
            end
            layer.toScene:addLayer(blockUI);
            layer.blockUI = blockUI;

            if layer.tweentype == AlertManager.TWEEN_1 then
                local  parentPanel = TFPanel:create();
                parentPanel:setAnchorPoint(ccp(0.5,0.5));
                parentPanel:setSize(layer:getSize());
                parentPanel:setZOrder(layer:getZOrder());
                parentPanel:setPosition(ccp((GameConfig.WS.width - layer:getSize().width)/2 + layer:getSize().width/2,(GameConfig.WS.height - layer:getSize().height)/2 + layer:getSize().height/2));
                parentPanel.blockUI = blockUI;

                layer:setPosition(ccp(- layer:getSize().width/2, - layer:getSize().height/2));
                parentPanel:addChild(layer);
                layer.parentPanel = parentPanel;
                self:showOpenEffect(parentPanel);
                layer.toScene:addLayer(layer);
            elseif layer.tweentype == AlertManager.TWEEN_2 then
                local  parentPanel = TFPanel:create();
                parentPanel:setAnchorPoint(ccp(0.5,0.5));
                parentPanel:setSize(layer:getSize());
                parentPanel:setZOrder(layer:getZOrder());
                parentPanel:setPosition(ccp((GameConfig.WS.width - layer:getSize().width)/2 + layer:getSize().width/2,(GameConfig.WS.height - layer:getSize().height)/2 + layer:getSize().height/2));
                parentPanel.blockUI = blockUI;

                layer:setPosition(ccp(- layer:getSize().width/2, - layer:getSize().height/2));
                parentPanel:addChild(layer);
                layer.parentPanel = parentPanel;
                self:showOpenEffect_2(parentPanel);
                layer.toScene:addLayer(layer);
            else
                for tlayer in self.layerQueue:iterator() do
                    if tlayer.blockUI and self:isNeedCloseOtherBlock(layer) then
                        tlayer.blockUI:setOpacity(0);
                    end
                end 

                if layer.blockUI then
                    layer.blockUI:setOpacity(255);
                end

                layer:setPosition(ccp((GameConfig.WS.width - layer:getSize().width)/2, (GameConfig.WS.height - layer:getSize().height)/2));
                layer.toScene:addLayer(layer);
                layer:setZOrder(layer:getZOrder());
            end
            layer.isShow = true;
            -- layer:setPosition(ccp(0,0))
        else
            print("CurrentScene no addLayer function");
        end
    else
      -- print("CurrentView is showing");
    end

    if layer.blockUI then
        layer.blockUI:setVisible(true);
    end
    layer:setVisible(true);

    layer:onShow();
end

function AlertManager:isNeedCloseOtherBlock( layer )
    if layer.block == AlertManager.NONE or layer.block == AlertManager.BLOCK or layer.block == AlertManager.BLOCK_CLOSE then
        return false
    end
    return true
end

function AlertManager:showOpenEffect(layer)
    TFDirector:setFPS(GameConfig.FPS * 2)

    local tempBlock = TFPanel:create();
    tempBlock:setSize(GameConfig.WS);
    tempBlock:setTouchEnabled(true); 
    tempBlock:setAnchorPoint(ccp(0.5,0.5));
    layer:addChild(tempBlock);

    layer:setOpacity(0);

    local toastTween = {
        target = layer,
        {
            delay = 1 / 60,
            onComplete = function() 
                -- layer:setOpacity(100);
                layer:setScale(0.7);
            end
        },
        {
            duration = 0.15,
            alpha = 1,
            scale = 1.05,
        },
        {
            duration = 0.03,
            scale = 1,
        },
        {
            duration = 0,
            onComplete = function() 
                TFDirector:setFPS(GameConfig.FPS)
                tempBlock:removeFromParent();
                -- tempNode:removeFromParent();
                -- self:updateIcon( index );
                for tlayer in self.layerQueue:iterator() do
                    if tlayer.blockUI then
                        tlayer.blockUI:setOpacity(0);
                    end
                end 
                if layer.blockUI then
                    layer.blockUI:setOpacity(255);
                end
            end
        }
    }

    TFDirector:toTween(toastTween);


    if layer.blockUI then
        layer.blockUI:setOpacity(0);
        if self.layerQueue:length() == 1 then
            local toastTween1 = {
                target = layer.blockUI,
                {
                    duration = 0.2,
                    alpha = 1,
                    onComplete = function() 

                    end
                }
            }

            TFDirector:toTween(toastTween1);
        end
    end
end


function AlertManager:showOpenEffect_2(layer)
    local tempBlock = TFPanel:create();
    tempBlock:setSize(GameConfig.WS);
    tempBlock:setTouchEnabled(true); 
    tempBlock:setAnchorPoint(ccp(0.5,0.5));
    layer:addChild(tempBlock);

    local pos_x = layer:getPositionX()
    layer:setPositionX(GameConfig.WS.width*3/2)
    local toastTween = {
        target = layer,
        {
            duration = 0.5,
            x = pos_x - 20,
        },
        {
            duration = 0.2,
            x = pos_x + 20,
        },
        {
            duration = 0.2,
            x = pos_x,
            onComplete = function() 
                TFDirector:setFPS(GameConfig.FPS)
                tempBlock:removeFromParent();
                for tlayer in self.layerQueue:iterator() do
                    if tlayer.blockUI then
                        tlayer.blockUI:setOpacity(0);
                    end
                end 
                if layer.blockUI then
                    layer.blockUI:setOpacity(255);
                end
            end
        }
    }

    TFDirector:toTween(toastTween);
end


function AlertManager:showCloseEffect(layer,onCompleteCallback)
    TFDirector:setFPS(GameConfig.FPS * 2)

    local tempBlock = TFPanel:create();
    tempBlock:setSize(GameConfig.WS);
    tempBlock:setTouchEnabled(true); 
    tempBlock:setAnchorPoint(ccp(0.5,0.5));
    layer.parentPanel:addChild(tempBlock);

   -- tempBlock:setBackGroundColorType(TF_LAYOUT_COLOR_SOLID);
   -- tempBlock:setBackGroundColorOpacity(200);
   -- tempBlock:setBackGroundColor(ccc3(  0,   0,   0));

    local toastTween = {
        target = layer.parentPanel,
        {
            delay = 1 / 60,
        },
        {
            duration = 0.1,
            scale = 1.1,
        },
        {
            duration = 0.05,
            alpha = 1,
            scale = 0.9,
        },
        {
            duration = 0,
            alpha = 0,
            scale = 0,
            onComplete = function() 
                layer:setVisible(false);
                tempBlock:removeFromParent();
            end
        },
        {
            duration = 0,
            delay = 1 / 60;
            onComplete = onCompleteCallback;

            TFDirector:setFPS(GameConfig.FPS)
        }
    }

    TFDirector:toTween(toastTween);
    if layer.blockUI then
        if self.layerQueue:length() == 0 then
            local toastTween1 = {
                target = layer.blockUI,
                {
                    duration = 0.18,
                    alpha = 0,
                    onComplete = function() 
                    end
                }
            }

            TFDirector:toTween(toastTween1);
        else
            layer.blockUI:setOpacity(0);
            if self:getTopLayer() and self:getTopLayer().blockUI then
                self:getTopLayer().blockUI:setOpacity(255);
            end
        end
    end
end

-- 关闭最顶层弹出框，并显示下一个
function AlertManager:getLayerByName(name)
    for layer in self.layerQueue:iterator() do
        if layer.name == name then
           return layer;
        end
    end
    return nil;
end

function AlertManager:getLayerFromCacheByName(name)
    return self.layerCache:objectByID(name);
end

-- 关闭最顶层弹出框，并显示下一个
function AlertManager:close(tweentype)
    self:closeTopLayer(tweentype);
end

function AlertManager:getTopLayer()
    return self.layerQueue:back();
end

-- 关闭最顶层弹出框
function AlertManager:closeTopLayer(tweentype)
    local topLayer = self.layerQueue:back();

    local currentScene = Public:currentScene();
    if topLayer and topLayer.toScene == currentScene then
        self:closeLayer(topLayer,tweentype);
    end
end

-- 关闭特定弹框
function AlertManager:closeLayerByName(name)
    local layer = self:getLayerByName(name);
    if layer then
        self:closeLayer(layer);
    else
        print("Can not find the layer :" .. name);
    end
end

-- 关闭特定弹框
function AlertManager:closeLayer(layer,tweentype)

    tweentype = tweentype or layer.tweentype;
    tweentype = tweentype or AlertManager.TWEEN_NONE;

    local layerName = nil;
    if layer and self.layerQueue:indexOf(layer) ~= -1 then
        self:removeLayerFromQueue(layer);
        layerName = layer.name;
        if layer.isShow then
            layer:onHide();
            layer:onClose();

            layer.isTop = false;
            layer.isShow = false;

            function onCompleteCallback()
                if layer.blockUI then  
                   layer.toScene:removeLayer(layer.blockUI);
                end
                layer.toScene:removeLayer(layer, not layer.isCache);
                
                layer.toScene = nil;
                layer.blockUI = nil;
                layer.parentPanel = nil;
                self:show();
            end

            if layer.parentPanel and tweentype ~= AlertManager.TWEEN_NONE then
                self:showCloseEffect(layer,onCompleteCallback);
            else
                layer.blockUI:setOpacity(0);
                if self:getTopLayer() and self:getTopLayer().blockUI then
                    self:getTopLayer().blockUI:setOpacity(255);
                end
                onCompleteCallback();
            end

        end
    else
        print("Can not find the layer in AlertManager");
    end

end

-- 关闭当前场景的所有弹出框
function AlertManager:closeAll()
   local num = self.layerQueue:length();
   for i=1,num do
       self:closeTopLayer(AlertManager.TWEEN_NONE);
   end
end

-- 关闭layer以上的弹出框，包括自己
function AlertManager:closeAllToLayer(layer)
   if layer == nil then
        print("Argument layer must be non-nil");
        return ;
   end
   local index = self.layerQueue:indexOf(layer)
   if index == -1 then
        print("Can not find the layer on AlertManager");
        return ;
   end
   local num = self.layerQueue:length() - index + 1;
   for i=1,num do
        self:closeTopLayer(AlertManager.TWEEN_NONE);
   end
   self:show();
end

function AlertManager:closeAllAtCurrentScene()
    local currentScene = TFDirector:currentScene();
    self:closeAllAtScene(currentScene);
end

function AlertManager:closeAllAtScene(scene)

    local tempArr = TFArray:new();
    for layer in self.layerQueue:iterator() do
        if layer.toScene == scene then
            tempArr:pushBack(layer);
        end
    end
    for layer in tempArr:iterator() do
        if layer.toScene == scene then
            self:closeLayer(layer);
        end
    end
end
-- 清理栈，销毁所有弹出框
function AlertManager:clear( ... )
    for layer in self.layerQueue:iterator() do
        if layer then
            layer:dispose();
            layer:release();
        end
    end
    self.layerQueue:clear();
end

--断线重连时，刷新所有已经打开的节目
function AlertManager:reShow()
    for layer in self.layerQueue:iterator() do
        if layer and layer.isShow == true then
            layer:onShow();
        end
    end
end

-- 清理缓存
function AlertManager:removeLayerFromCache(cacheKey)

    if cacheKey == nil then
        return false
    end

    if self:isInQueueByKey(cacheKey) then
        return false
    end
    local layer = self.layerCache:objectByID(cacheKey)
    if layer then
       -- layer:dispose();
        layer:release();
        self.layerCache:removeById(cacheKey)
        layer = nil;
    end
    return true
end

-- 清理缓存
function AlertManager:clearAllCache()
    for v in self.layerCache:iterator() do
        self:removeLayerFromCache(v.cacheKey);
    end
    me.ArmatureDataManager:removeUnusedArmatureInfo()
    CCDirector:sharedDirector():purgeCachedData()
end
function AlertManager:isInQueueByKey( cacheKey )
    local layer = self.layerCache:objectByID(cacheKey)
    if layer then
        if self.layerQueue:indexOf(layer) ~= -1 then
            return true
        end
    end
    return false
end

function AlertManager:closeAllWithoutSpecial( special_name )
    local layer_name_list = TFArray:new()
    for layer in self.layerQueue:iterator() do
        if layer.__cname ~= special_name then
            layer_name_list:pushBack(layer.__cname)
        end
    end
    for layer_name in layer_name_list:iterator() do
        self:closeLayerByName(layer_name)
    end
end

--内存警告时，逐步清除缓存的layer
function AlertManager:MemoryWarning()
    for v in self.layerCache:iterator() do
        if self:removeLayerFromCache(v.cacheKey) then
            me.ArmatureDataManager:removeUnusedArmatureInfo()
            CCDirector:sharedDirector():purgeCachedData()
            return
        end
    end
end

--强制切换的场景，为了在使用了Push方式切换场景式可以把所有Push方式打开的场景关闭，安全打开此场景添加
--AlertManager.Force_Scene_Callback = nil

function AlertManager:changeSceneForce(szSceneType, tData, szChangType, szChangeEffect, tEffectParam)
   -- if szChangType == nil and self.szChangType == TFSceneChangeType_PushBack then
   --      local objScene = TFDirector:changeScene(SceneType.HOME,nil,TFSceneChangeType_PopBack)
   --      self.szChangType = szChangType
   --      TFDirector:addTimer( 30,1,nil,function ()
   --          local currentScene = TFDirector:currentScene();
   --          print("currentScene : ",currentScene,objScene)
   --          TFDirector:changeScene(szSceneType, tData, szChangType, szChangeEffect, tEffectParam)
   --      end)
   --      return objScene
   --  else
   --      return TFDirector:changeScene(szSceneType, tData, szChangType, szChangeEffect, tEffectParam)
   --  end
   if szChangType == nil and self.szChangType == TFSceneChangeType_PushBack then
        if not self.Force_Scene_Callback then
            self.Force_Scene_Callback = function()
                TFDirector:changeScene(szSceneType, tData, szChangType, szChangeEffect, tEffectParam)
            end
        end
        self.szChangType = szChangType
        return TFDirector:changeScene(SceneType.HOME,nil,TFSceneChangeType_PopBack)
   else
        if self.Force_Scene_Callback then
            local callback = self.Force_Scene_Callback
            self.Force_Scene_Callback=nil
            callback()
        else
            return TFDirector:changeScene(szSceneType, tData, szChangType, szChangeEffect, tEffectParam)
        end
   end
end

function AlertManager:changeScene(szSceneType, tData, szChangType, szChangeEffect, tEffectParam)
    self.szChangType = szChangType or self.szChangType
    local objScene = TFDirector:changeScene(szSceneType, tData, szChangType, szChangeEffect, tEffectParam)
    PlayerGuideManager:doGuide()
    return objScene
end

function AlertManager:restart()
    self:closeAll();
    self:clearAllCache();
end



return AlertManager:new();