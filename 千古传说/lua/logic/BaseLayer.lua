--[[
    页面逻辑处理 基础类

    --By: haidong.gan
    --2013/11/11
]]

-- 生成创建场景方法
function CREATE_SCENE_FUN(classObj)
    function classObj:scene()
         local layer = classObj:new();
         local baseScene = BaseScene:new();
         baseScene:addLayer(layer);
         return baseScene;
    end
end

-- 生成创建UI方法，注意：用此方法创建UI，logic无法保存
function CREATE_PANEL_FUN(classObj)
    function classObj:panel()
         local layer = classObj:new();
         return layer;
    end
end

local BaseLayer = class("BaseLayer", function(...)
    local layer = TFPanel:create()
    layer:setName("BaseLayer")
    return layer
end)

BaseLayer.isDebug = false;
local LayerCreatNum = 0

-- 构造方法
function BaseLayer:ctor(data)
    -- print("BaseLayer:ctor")
    self.data            = data;
    self.childArr        = TFArray:new();
    self.LayerCreatIndex = LayerCreatNum
    LayerCreatNum = LayerCreatNum + 1
end

-- 构造方法之后调用
function BaseLayer:enter()
    -- print("BaseLayer:enter")
    for layer in self.childArr:iterator() do
        TFFunction.call(layer.enter, layer);
    end
end

-- 每次c++调用onEnter之后调用
function BaseLayer:onEnter()
    -- print("BaseLayer:onEnter")
    for layer in self.childArr:iterator() do
        TFFunction.call(layer.onEnter, layer);
    end
end

-- 每次c++调用onExit之后调用
function BaseLayer:onExit()
    -- print("BaseLayer:onExit")
    for layer in self.childArr:iterator() do
        TFFunction.call(layer.onExit, layer);
    end
end

-- 每次AlertManager:show()之后调用；子弹窗关闭时调用；断线重连时调用
function BaseLayer:onShow()
    -- print("BaseLayer:onShow")
    for layer in self.childArr:iterator() do
        TFFunction.call(layer.onShow, layer);
    end
end

-- 断线重连时调用
function BaseLayer:reShow()
    -- print("BaseLayer:reShow")
    for layer in self.childArr:iterator() do
        TFFunction.call(layer.reShow, layer);
    end
end

-- 每次AlertManager:clode()\AlertManager:hide()之后调用
function BaseLayer:onHide()
    -- print("BaseLayer:onHide")
    for layer in self.childArr:iterator() do
        TFFunction.call(layer.onHide, layer);
    end
end

-- 每次AlertManager:clode()之后调用
function BaseLayer:onClose()
    -- print("BaseLayer:onClose")
    for layer in self.childArr:iterator() do
        TFFunction.call(layer.onClose, layer);
    end
end

-- 添加子panel，同时保存panel的lua对象
function BaseLayer:addLayer(layer)
    -- print("BaseLayer:addLayer")
    if layer.parentPanel then
        self:addChild(layer.parentPanel);
    else
        self:addChild(layer);
    end

    self.childArr:push(layer);
end

-- 删除子panel，同时销毁panel的lua对象
function BaseLayer:removeLayer(layer, isDispose)
    if isDispose == true or isDispose == nil then
        TFFunction.call(layer.dispose, layer);
    end
    
    if layer.parentPanel then
        self:removeChild(layer.parentPanel, isDispose);
    else
        self:removeChild(layer, isDispose);
    end
    
   
    self.childArr:removeObject(layer);
end

-- 根据ui文件路径，初始化生成ui对象
function BaseLayer:init(uiPath)
	local ui = createUIByLuaNew(uiPath);

    self:setSize(ui:getSize());
    if ui:getSizeType() == 1 then
        self:setSizeType(ui:getSizeType())
        self:setSizePercent(ccp(ui:getSizePercentWidth(), ui:getSizePercentHeight()) )
        ui:setSizePercent(ccp(1, 1))
    end
	self:initUI(ui);
	self:registerEvents(ui);
	return self;
end

-- 清理内存
function BaseLayer:dispose()
	-- print("BaseLayer dispose..");

    self:removeEvents();
    self:removeUI();
    
    for layer in self.childArr:iterator() do
        TFFunction.call(layer.dispose, layer);
    end
    self.childArr:clear();
end

function BaseLayer:initUI(ui)
    self.ui = ui;
    self:addChild(ui)
end

function BaseLayer:removeUI()
    self.ui = nil;
end

function BaseLayer:registerEvents()
end

function BaseLayer:removeEvents()

end

return BaseLayer;
