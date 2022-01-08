--[[
    tap页面管理管理类

    --By: haidong.gan
    --2013/11/11
]]

--[[
--用法举例

    local dic = {[1] = map_layer, [2] = menu_layer};
    local groupLayerManager = GroupLayerManager:new(dic);

    groupLayerManager:showLayer(map_layer);

    groupLayerManager:showIndex(2);
]]


local GroupLayerManager = class("GroupLayerManager");

function GroupLayerManager:ctor(layerDic)
	  self.layerDic = layerDic;
    self.curLayer = nil;

    for index,layer in pairs(self.layerDic) do
       layer:setVisible(false);
    end
end


function GroupLayerManager:showLayer(layer)
    if not layer then
      print("Layer must be not nil")
      return;
    end

    if self.curLayer then
       self.curLayer:setVisible(false);
    end
    layer:setVisible(true);
    self.curLayer = layer;
end

function GroupLayerManager:showIndex(index)
    local layer = self.layerDic[index];
    self:showLayer(layer);
end

function GroupLayerManager:dispose()
    self.layerDic = nil;
    self.curLayer = nil;
end

return GroupLayerManager;