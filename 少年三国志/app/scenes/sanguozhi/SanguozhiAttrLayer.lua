local SanguozhiAttrLayer = class("SanguozhiAttrLayer",UFCCSModelLayer)
require("app.cfg.main_growth_info")
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
function SanguozhiAttrLayer.show(...)
	local layer = SanguozhiAttrLayer.create(...)
	uf_sceneManager:getCurScene():addChild(layer)
end

function SanguozhiAttrLayer.create(...)
	return SanguozhiAttrLayer.new("ui_layout/sanguozhi_SanguozhiAttrLayer.json",Colors.modelColor,...)
end

function SanguozhiAttrLayer:ctor(json,colors,listData,...)
	self.super.ctor(self,...)
	self:showAtCenter(true)
	self:registerTouchEvent(false, true, 0)
	-- self:playAnimation("AnimationAlpha",function() 
	-- end)
	self._listData = listData
	if self._listData ~= nil and #self._listData >0 then
		self:showWidgetByName("Label_noAttr",false)
		self:_initListView()
	else
		self:showWidgetByName("Label_noAttr",true)
	end
end

function SanguozhiAttrLayer:_initListView()
	local panel = self:getPanelByName("Panel_list")
	self._listview= CCSListViewEx:createWithPanel(panel,LISTVIEW_DIR_VERTICAL)
	self._listview:setCreateCellHandler(function(list,index)
		local cell = require("app.scenes.sanguozhi.SanguozhiAttrItem").new()
		return cell
	end)
	self._listview:setUpdateCellHandler(function(list,index,cell)
		cell:updateCell(self._listData[index*2+1],self._listData[index*2+2])
	end)
	self._listview:reloadWithLength(math.ceil(#self._listData/2),self._listview:getShowStart())
end

function SanguozhiAttrLayer:onLayerEnter()
	self:closeAtReturn(true)
	require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
	EffectSingleMoving.run(self:getImageViewByName("Image_10"), "smoving_wait", nil , {position = true} )
end

function SanguozhiAttrLayer:onTouchEnd( xpos, ypos )
    self:animationToClose()
end


return SanguozhiAttrLayer