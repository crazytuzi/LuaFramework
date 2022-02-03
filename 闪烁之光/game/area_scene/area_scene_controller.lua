-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2019-11-06
-- --------------------------------------------------------------------
Area_sceneController = Area_sceneController or BaseClass(BaseController)

function Area_sceneController:config()
    self.dispather = GlobalEvent:getInstance()
end

function Area_sceneController:registerEvents()
end

function Area_sceneController:registerProtocals()
end

----------- @ 界面相关
-- 打开区场景
function Area_sceneController:openAreaScene(status, data)
    if status == true then
        if not self.area_scene_wnd then
            self.area_scene_wnd = AreaSceneWindow.New(data)
        end
        if self.area_scene_wnd:isOpen() == false then
            self.area_scene_wnd:open()
        end
    else
        if self.area_scene_wnd then
            self.area_scene_wnd:close()
            self.area_scene_wnd = nil
        end
    end
end

-- 引导需要
function Area_sceneController:getAreaSceneRoot(  )
	if self.area_scene_wnd then
        return self.area_scene_wnd.root_wnd
    end
end

--点击区场景建筑(bid对应Config.city_data中的bid)
function Area_sceneController:onClickAreaBuildById(area_type, bid)
    if area_type == Area_sceneConst.Area_Type.Shop then -- 商业区
        if bid == 1 then        -- 积分商店
            MallController:getInstance():openScoreShopWindow(true)
        elseif bid == 2 then    -- 精灵商店
            MallController:getInstance():openVarietyStoreWindows(true)
        elseif bid == 3 then    -- 礼包商店
            MallController:getInstance():openChargeShopWindow(true)
        elseif bid == 4 then    -- 皮肤商店
            MallController:getInstance():openSkinShopWindow(true)
        elseif bid == 5 then    -- 圣羽商店
            MallController:getInstance():openPlumeShopWindow(true)
        elseif bid == 6 then    -- 杂货店
            MallController:getInstance():openMallPanel(true)
        end
    end
end

function Area_sceneController:setBuildRedStatus( build_id, red_data )
    if self.area_scene_wnd then
        self.area_scene_wnd:setBuildRedStatus(build_id, red_data)
    end
end

function Area_sceneController:__delete()

end