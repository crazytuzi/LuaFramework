-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-05-29
-- --------------------------------------------------------------------
WorldmapController = WorldmapController or BaseClass(BaseController)

function WorldmapController:config()
    self.model = WorldmapModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function WorldmapController:getModel()
    return self.model
end

function WorldmapController:registerEvents()
end

function WorldmapController:registerProtocals()
end

--[[
    @desc:打开世界地图主界面
    author:{author}
    time:2018-05-29 14:48:51
    --@status: 
    return
]]
function WorldmapController:openWorldMapMainWindow(status,data)
    if status == false then
        if self.worldmap_window ~= nil then
            self.worldmap_window:close()
            self.worldmap_window = nil
        end
    else
        local config = require("config.dungeon_scene_data")
        if config == nil then return end

        if self.worldmap_window == nil then
            self.worldmap_window = WorldMapMainWindow.New(config)
        end
        self.worldmap_window:open(data)
    end
end


--提示信息界面
function WorldmapController:openWorldMapTipsWindow(status,data,open_type)
	if status == true then
		if self.WorldMapTipsWindow == nil then
			self.WorldMapTipsWindow = WorldMapTipsWindow.New()
		end
		if self.WorldMapTipsWindow:isOpen() == false then
			self.WorldMapTipsWindow:open(data,open_type)
		end
	else
		if self.WorldMapTipsWindow then
			self.WorldMapTipsWindow:close()
			self.WorldMapTipsWindow = nil
		end
	end
end

function WorldmapController:addLockContainer(status)
    if status == true then
        if not self.lock_layout then
            self.lock_layout = ViewManager:getInstance():getLayerByTag(ViewMgrTag.DEBUG_TAG)
            if self.lock_layout ~= nil then
                self.lock_layout:setSwallowTouches(true)
            end
        end
    else
        if self.lock_layout ~= nil then
            self.lock_layout:setSwallowTouches(false)
            -- self.lock_layout:removeAllChildren()
            -- self.lock_layout:removeFromParent()
        end
    end
end
function WorldmapController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end
