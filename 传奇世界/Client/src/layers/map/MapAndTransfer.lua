local MapAndTransferLayer = class("MapAndTransferLayer", function() return cc.Layer:create() end )

function MapAndTransferLayer:ctor(index)
	self:setName("a44")
	-- local title = {
	-- 			{text=game.getStrByKey("title_map"), pos=cc.p(600, 605)}, 
	-- 			{text=game.getStrByKey("delivery"), pos=cc.p(755, 605)},
	-- 		}
	self.layers = {}
	self.datas = {}
	self.select_index = 0

	local viewReq = {require("src/layers/map/MapLayer"),require("src/layers/map/transmitboard"),require("src/layers/map/transmitboard")}
	local isBoss = getConfigItemByKey("MapInfo","q_map_id",G_MAINSCENE.mapId,"Is_BOSS")
	-- if G_MAINSCENE and tonumber(getConfigItemByKey("MapInfo", "q_map_id", G_MAINSCENE.mapId, "xianzhi")) == 1 then
	-- 	if isBoss and tonumber(isBoss) == 1 then
	-- 		title[2] = nil
	-- 	end
	-- 	if index == 2 then
	-- 		local callback = function()
	-- 			removeFromParent(self)
	-- 		end
	-- 		MessageBox(game.getStrByKey("cannot_tras"),nil,callback)
	-- 		return
	-- 	end
	-- end
	local bg = createBgSprite(self)
	self.bg = bg

	local tdata = getConfigItemByKey("HotAreaDB","q_id")
    self.tp = {}
    for k,v in pairs(tdata) do  --for i = 1, num1 do
        if v.q_tar_mapid and (not self.tp[v.q_tar_mapid]) then
            self.tp[v.q_tar_mapid] = {}
            self.tp[v.q_tar_mapid].x = v.q_sjcs_x
            self.tp[v.q_tar_mapid].y = v.q_sjcs_y            
        --else
            --cclog("数据为nil!!!!")
        end
    end
	local menuFunc = function(tag,sender)
		if self.select_index == tag then
			return
		end
		for k,v in pairs(self.tabs) do
			if tag == k then
			elseif self.layers[k] then
				removeFromParent(self.layers[k])
				self.layers[k] = nil
			end
			if not self.layers[tag] then
				if tag > 1 then
					self.layers[tag] = viewReq[tag].new(self,tag,self.datas)
				else
					self.layers[tag] = viewReq[tag].new(self,tag)
				end
				self.bg:addChild(self.layers[tag])
			end
		end
	end

	local tab_title_map = game.getStrByKey("title_map")
	local tab_delivery = game.getStrByKey("maincity")
	local tab_delivery1 = game.getStrByKey("field")

	local idx = 0
    local mapinfo = getConfigItemByKey("MapInfo","q_map_id")

    local function mapData(data,temp)
        if temp then
            idx = temp
        else
            idx = tonumber(data.q_sjlevel)
        end
        self.datas[idx] = self.datas[idx] or {}
        table.insert(self.datas[idx],data)
    end
    for k,v in pairs(mapinfo) do
        local mapTab = {}
        if v.q_sjlevel and v.q_map_id ~= 1000 then
            if string.find(v.q_sjlevel,"_") then
                mapTab = stringsplit(v.q_sjlevel,"_")
                for i=1,#mapTab do
                    mapData(v,tonumber(mapTab[i]))
                end
            else
                mapData(v)
            end
        end
    end

	local tabs = {}
	tabs[#tabs+1] = tab_title_map
	if not (G_MAINSCENE and tonumber(getConfigItemByKey("MapInfo", "q_map_id", G_MAINSCENE.mapId, "xianzhi2")) == 1) then
		tabs[#tabs+1] = tab_delivery
		tabs[#tabs+1] = tab_delivery1
	end
	self.tabs = tabs
	local TabControl = Mnode.createTabControl(
	{
		src = {"res/common/TabControl/1.png", "res/common/TabControl/2.png"},
		size = 22,
		titles = tabs,
		margins = 2,
		ori = "|",
		align = "r",
		side_title = true,
		cb = function(node, tag)
			menuFunc(tag)
			local title_label = bg:getChildByTag(12580)
			if title_label then title_label:setString(tabs[tag]) end
		end,
		selected = index or 1,
	})
	if #tabs<=1 then TabControl:setVisible(false) end
	Mnode.addChild(
	{
		parent = bg,
		child = TabControl,
		anchor = cc.p(0, 0.0),
		pos = cc.p(931, 460),
		zOrder = 200,
	})
end

return MapAndTransferLayer