module(..., package.seeall)
local require = require;
require("ui/map_set_funcs")
local ui = require("ui/base");
-------------------------------------------------------
wnd_forcewar_miniMap = i3k_class("wnd_forcewar_miniMap", ui.wnd_base)


function wnd_forcewar_miniMap:ctor()

end

function wnd_forcewar_miniMap:configure()
--    local widget=self._layout.vars
--    self.task_scroll = self._layout.vars.task_scroll
	self._layout.vars.worldCoord:hide()
end

function wnd_forcewar_miniMap:refresh()
	self:updateMapInfo()
end


function wnd_forcewar_miniMap:onHide()
	releaseSchedule() -- 防止点击头像时候出错。
end

function wnd_forcewar_miniMap:onUpdate(dTime)
	local mapInstance = GetBaseMap()
	mapInstance:onUpdate(dTime)
end

function wnd_forcewar_miniMap:updateCoordInfo(msg)
	--self._layout.vars.worldCoord:setText(msg)
end
---------------------------------------
function wnd_forcewar_miniMap:updateMapInfo(roleId)
	if roleId then
		local location = g_i3k_game_context:GetForceWarStatuesPosition(roleId)
		updateDoubleSideMateStatues(roleId, location.mapId, location.pos, bwType)
	end
	local mapType = i3k_game_get_map_type()
	if mapType==g_FORCE_WAR  then --势力战
		local scroll = self._layout.vars.mapScroll
		scroll:removeAllChildren()
		local world = i3k_game_get_logic():GetWorld()
		local mapId = world._cfg.id
		local node = require("ui/widgets/zdt")()
		for i,v in pairs(i3k_db_forcewar_fb) do
			if v.id==mapId then

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
	elseif mapType == g_BUDO then
		local scroll = self._layout.vars.mapScroll
		scroll:removeAllChildren()
		local world = i3k_game_get_logic():GetWorld()
		local mapId = world._cfg.id
		local node = require("ui/widgets/zdt")()
		
		local v = i3k_db_fight_team_fb[mapId]
		
		local mapImgPath = i3k_db_icons[v.imageId].path
		local img = i3k_checkPList(mapImgPath)
		local heroSprite = cc.Sprite:createWithSpriteFrameName(img)
		local size = heroSprite:getContentSize()
		size = {width = size.width*v.worldMapScale,height = size.height*v.worldMapScale}
		node.vars.image:setContentSize(size.width, size.height)
		node.vars.image:setImage(mapImgPath)--设置地图背景
		node.vars.btn:onClick(self, self.toMap)
		scroll:addItem(node, true)
		
		local nodeSize = node.vars.image:getContentSize()
		f_isHeroCreate = createForceWarMiniMap(scroll, nodeSize, mapId)---调用底层方法

	end
end

------------监听器---------------------

function wnd_forcewar_miniMap:toMap(sender)
	local mapType = i3k_game_get_map_type()
	local world = i3k_game_get_logic():GetWorld()
	local mapId = world._cfg.id
	if mapType==g_FORCE_WAR  then
		g_i3k_ui_mgr:OpenUI(eUIID_ForceWarMap)
		g_i3k_ui_mgr:RefreshUI(eUIID_ForceWarMap, mapId)
	else
		g_i3k_ui_mgr:OpenUI(eUIID_ForceWarMap)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ForceWarMap,"show", mapId,i3k_db_fight_team_fb[mapId])
	end
end


-----------------------------------------



function wnd_create(layout)
	local wnd = wnd_forcewar_miniMap.new();
		wnd:create(layout);
	return wnd;
end
