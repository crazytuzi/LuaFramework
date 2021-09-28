--练功房
local ExerciseRoomMapLayer = class("ExerciseRoomMapLayer", require("src/base/MainMapLayer.lua"))
local MRoleStruct = require("src/layers/role/RoleStruct")
function ExerciseRoomMapLayer:ctor(str_name, parent, pos, mapId, isFb)
    ----------------------------------------------通用部分:-----------------------------------------------------------------------------
    self.parent = parent
	self:initializePre()
	self:loadMapInfo(str_name, mapId, pos)
	self.parent:addChild(self, -1)
	self:loadSpritesPre()
	self.has_loadmap = true
    ------------------------------------------------------------------------------------------------------------------------------------
    self.isExerciseRoom = true
    -----------------------------------------------start 玩家信息窗口:------------------------------------------------------------------
    --隐藏装备技能等按钮
    if G_MAINSCENE.full_mode then
        G_MAINSCENE:setFullShortNode(false)
    end
    --去掉邮件提示
    if G_MAINSCENE and G_MAINSCENE.mailFlag then
      removeFromParent( G_MAINSCENE.mailFlag ) 
      G_MAINSCENE.mailFlag = nil 
    end
    --去掉玩法提醒
    if G_MAINSCENE and G_MAINSCENE.wftxFlag then
      removeFromParent( G_MAINSCENE.wftxFlag ) 
      G_MAINSCENE.wftxFlag = nil 
    end
    local mapParentNode = cc.Node:create()
    self.mapNode = mapParentNode
    if parent and parent.base_node then
        --parent:addChild(mapParentNode,100)
        parent.base_node:addChild(mapParentNode, 100);
    end
    local exerciseDamgeShow=require("src/layers/exerciseRoom/ExerciseDamgeShow").new(mapParentNode)
    self.exerciseDamgeShow=exerciseDamgeShow
end



function ExerciseRoomMapLayer:showReliveLayer(objId)
    --为了让断线重连支持复活弹窗，不在这里创建复活弹窗,只用作重载
end

return ExerciseRoomMapLayer