-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-09-20
-- --------------------------------------------------------------------
LevupgradeController = LevupgradeController or BaseClass(BaseController)

function LevupgradeController:config()
    self.model = LevupgradeModel.New(self)
    self.dispather = GlobalEvent:getInstance()

    self.wait_list = {}
end

function LevupgradeController:getModel()
    return self.model
end

function LevupgradeController:registerEvents()
    -- 接收到提示可以播放升级界面,这个时候需要判断是否播放升级或者直接通知剧情
    -- if self.can_play_drama_event == nil then
    --     self.can_play_drama_event = GlobalEvent:getInstance():Bind(StoryEvent.BATTLE_RESULT_OVER, function() 
    --         local status = table.remove( self.wait_list ,1 )
    --         if next(self.wait_list) == nil and self.cache_data then
    --             self:openMainWindow(true, self.cache_data)
    --             self.cache_data = nil
    --         else
    --             GlobalEvent:getInstance():Fire(StoryEvent.PREPARE_PLAY_PLOT) 
    --         end
    --     end)
    -- end
end

function LevupgradeController:registerProtocals()
    self:RegisterProtocal(10344, "handle10344")
end

function LevupgradeController:handle10344(data)
    BattleResultMgr:getInstance():addShowData(BattleConst.Closed_Result_Type.LevelUpgradeType, data)
end

--==============================--
--desc:设置出现升级时候不能马上出面板
--time:2018-09-21 07:16:10
--@status:
--@return 
--==============================--
function LevupgradeController:waitForOpenLevUpgrade(status)
    -- table.insert( self.wait_list, true)
end

function LevupgradeController:openMainWindow(status, data)
    if not status then
        if self.lev_window then
            self.lev_window:close()
            self.lev_window = nil
        end
    else
        -- if next(self.wait_list) ~= nil then --lwc
        --     self.cache_data = data
        --     return 
        -- end

        if self.lev_window == nil then
            self.lev_window = LevupgradeWindow.New()
        end
        self.lev_window:open(data)
    end
end

function LevupgradeController:waitLevupgrade()
    return self.cache_data ~= nil or self.lev_window ~= nil or next(self.wait_list) ~= nil
end 

function LevupgradeController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end
