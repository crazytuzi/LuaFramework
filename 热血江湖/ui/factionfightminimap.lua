module(..., package.seeall)
local require = require;
require("ui/map_set_funcs")
local ui = require("ui/base");
-------------------------------------------------------
wnd_factionFightMiniMap = i3k_class("wnd_factionFightMiniMap", ui.wnd_base)


function wnd_factionFightMiniMap:ctor()

end

function wnd_factionFightMiniMap:configure()
	self._layout.vars.worldCoord:hide()
end

function wnd_factionFightMiniMap:refresh()
	self:updateMapInfo()
end


function wnd_factionFightMiniMap:onHide()
	releaseSchedule() -- 防止点击头像时候出错。
end

function wnd_factionFightMiniMap:onUpdate(dTime)
	local mapInstance = GetBaseMap()
	mapInstance:onUpdate(dTime)
end

function wnd_factionFightMiniMap:updateCoordInfo(msg)
end
---------------------------------------
function wnd_factionFightMiniMap:updateMapInfo(roleId)
	-- if roleId then
	-- 	local location = g_i3k_game_context:GetForceWarStatuesPosition(roleId)
	-- 	updateDoubleSideMateStatues(roleId, location.mapId, location.pos, bwType)
	-- end
	local mapType = i3k_game_get_map_type()
	if mapType == g_FACTION_WAR  then --势力战
		local scroll = self._layout.vars.mapScroll
		scroll:removeAllChildren()
		local world = i3k_game_get_logic():GetWorld()
		local mapId = world._cfg.id
		local node = require("ui/widgets/zdt")()
		for i,v in pairs(i3k_db_factionFight_dungon) do
			if v.id == mapId then
				local mapImgPath = i3k_db_icons[v.imageId].path
				local img = i3k_checkPList(mapImgPath)
				local heroSprite = cc.Sprite:createWithSpriteFrameName(img)
				local size = heroSprite:getContentSize()
				size = {width = size.width*v.worldMapScale,height = size.height*v.worldMapScale}
				node.vars.image:setContentSize(size.width, size.height)
				node.vars.image:setImage(mapImgPath)--设置地图背景
				node.vars.btn:onClick(self, self.toMap)
				scroll:addItem(node, true)
			end
		end
		local nodeSize = node.vars.image:getContentSize()
		f_isHeroCreate = createForceWarMiniMap(scroll, nodeSize, mapId)---调用底层方法
	end
end

------------监听器---------------------
function wnd_factionFightMiniMap:toMap(sender)
	local mapId = g_i3k_game_context:GetWorldMapID()
	if mapId ~= 0 then
	g_i3k_ui_mgr:OpenUI(eUIID_FactionFightMap)
	g_i3k_ui_mgr:RefreshUI(eUIID_FactionFightMap, mapId)
	end
end
-----------------------------------------
function wnd_create(layout)
	local wnd = wnd_factionFightMiniMap.new();
		wnd:create(layout);
	return wnd;
end
