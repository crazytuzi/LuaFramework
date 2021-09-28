local function _updateLabel(target, name, params)
    local label = target:getLabelByName(name)
    if params.stroke ~= nil then
        label:createStroke(params.stroke, params.size and params.size or 1)
    end
   
    if params.color ~= nil then
        label:setColor(params.color)
    end
    
    if params.text ~= nil then
        label:setText(params.text)
    end
    
    if params.visible ~= nil then
        label:setVisible(params.visible)
    end 
end

local TimeDungeonBattleBuffLayer = class("TimeDungeonBattleBuffLayer", UFCCSNormalLayer)

function TimeDungeonBattleBuffLayer.create(...)
	return TimeDungeonBattleBuffLayer.new("ui_layout/timedungeon_TimeDungeonBattleBuff.json", nil, ...)
end

function TimeDungeonBattleBuffLayer:ctor(json, param, ...)
	self.super.ctor(self, json, param, ...)
	self:_initWidgets()
end

function TimeDungeonBattleBuffLayer:_initWidgets()
    local szAttackAttr = G_Me.timeDungeonData:getCurAttackAttr()
    local szLifeAttr = G_Me.timeDungeonData:getCurLifeAttr()

	_updateLabel(self, "Label_buffdes1", {text=szAttackAttr, visible=true})
	_updateLabel(self, "Label_buffdes2", {text=szLifeAttr, visible=true})
end


return TimeDungeonBattleBuffLayer