module(..., package.seeall)

local require = require;

require("ui/map_set_funcs")
local ui = require("ui/base")

battleMagicMachineMiniMap = i3k_class("wnd_battleMagicMachineMiniMap", ui.wnd_base)

function battleMagicMachineMiniMap:ctor()
	
end

function battleMagicMachineMiniMap:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseUI)
end

function battleMagicMachineMiniMap:onHide()
	releaseSchedule()
end

function battleMagicMachineMiniMap:refresh(mapId, cfg)
	local imgPath = g_i3k_db.i3k_db_get_icon_path(cfg.titleImgId)
	local widget = self._layout.vars
	widget.titleImage:setImage(imgPath)
	local scroll = widget.scroll
	scroll:removeAllChildren(true)
	local node = require("ui/widgets/zdt")()
	local weight = node.vars
	local size
	local world = i3k_game_get_world()
	local nowMapId = world._cfg.id
	local img = i3k_checkPList(i3k_db_icons[cfg.imageId].path)
	local heroSprite = cc.Sprite:createWithSpriteFrameName(img)
	size = heroSprite:getContentSize()
	size = {width = size.width * cfg.worldMapScale, height = size.height * cfg.worldMapScale}
	local mapImg = weight.image
	self:SetMapImageContentsize(node,size)  --根据是不是PAD设置地图大小
	weight.btn:setContentSize(size.width, size.height)
	mapImg:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.imageId))
	scroll:addItem(node, true)
	local width = scroll:getContainerSize().width
	local height = scroll:getContainerSize().height
	mapImg:setPositionInScroll(scroll,cfg.worldMapScaleX * width, cfg.worldMapScaleY * height)

	local nodeSize = weight.image:getContentSize()
	createMap(scroll, nodeSize, mapId, weight.image, nowMapId == mapId)
end
	
function wnd_create(layout, ...)
	local wnd = battleMagicMachineMiniMap.new();
	wnd:create(layout, ...);
	return wnd;
end
