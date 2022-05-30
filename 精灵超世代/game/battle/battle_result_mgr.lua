-- --------------------------------------------------------------------
-- 战斗结算管理
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--     战斗结算, 管理弹窗界面的类
-- <br/>2019年6月14日
-- --------------------------------------------------------------------
BattleResultMgr = BattleResultMgr or BaseClass(BaseController)

function BattleResultMgr:config()
    self.dic_show_data = {}
    self.order_list = {
         [1] = BattleConst.Closed_Result_Type.LevelUpgradeType  -- 升级界面
        ,[2] = BattleConst.Closed_Result_Type.TaskExpType       --隐藏历练类型
        ,[3] = BattleConst.Closed_Result_Type.LimitGiftType     --限时礼包类型

        
        --这了两个比较特殊..每次必然需要检查
        -- ,[3] = BattleConst.Closed_Result_Type.GuideType         --引导类型
        -- ,[4] = BattleConst.Closed_Result_Type.PlayActType       --播放剧情类型
    }
end

function BattleResultMgr:registerEvents()
    -- 关闭战斗结算界面事件
    if self.battle_exit_event == nil then
        self.battle_exit_event = GlobalEvent:getInstance():Bind(BattleEvent.CLOSE_RESULT_VIEW, function(combat_type)
            if self.is_wait_show then
                self:showNextPanel()
            end
        end)
    end

    if self.battle_next_event == nil then
        self.battle_next_event = GlobalEvent:getInstance():Bind(BattleEvent.NEXT_SHOW_RESULT_VIEW, function(combat_type)
            if self.is_wait_show then
                self:showNextPanel()
            end
        end)
    end
end

--是否等待显示中
function BattleResultMgr:isWaitShow()
    return self.is_wait_show or false
end

--设置等待显示面板中 激活等待面板
function BattleResultMgr:setWaitShowPanel(status)
    self.is_wait_show = status
end

function BattleResultMgr:showNextPanel()
    if self.dic_show_data and next(self.dic_show_data) ~= nil then
        for i,_type in ipairs(self.order_list) do
            if self.dic_show_data[_type] ~= nil and  next(self.dic_show_data[_type]) ~= nil then
                local data = table.remove(self.dic_show_data[_type], 1)
                self:openViewByType(_type, data)
                if #self.dic_show_data[_type] == 0 then
                    self.dic_show_data[_type] = nil
                end
                self.cur_show_type = _type
                break
            end
        end
    else
        if self.cur_show_type and self.cur_show_type == BattleConst.Closed_Result_Type.LimitGiftType then
            --礼包的话.不用触发剧情事件
        else
            GlobalEvent:getInstance():Fire(StoryEvent.PREPARE_PLAY_PLOT)
        end
        self.is_wait_show = false
        self.cur_show_type = nil
    end
end

--添加显示数据
--@_type 类型 参考BattleConst.Closed_Result_Type
--@data 一般为相应类型服务器返回的数据
function BattleResultMgr:addShowData(_type, data)
    if self.dic_show_data == nil then
        self.dic_show_data = {}
    end
    if self.dic_show_data[_type] == nil then
        self.dic_show_data[_type] = {}
    end
    --限时礼包类型最多只能有一个
    if _type == BattleConst.Closed_Result_Type.LimitGiftType then
        if #self.dic_show_data[_type] > 0 then
            return
        end
    end

    table.insert(self.dic_show_data[_type], data)
    if not self.is_wait_show then
        --未激活等待
        self.is_wait_show = true
        --如果不在等待中.说明可以立马显示对应弹窗了
        self:showNextPanel()
        -- delayOnce(function() self:showNextPanel() end, 0.5)
    end
end

function BattleResultMgr:openViewByType(_type, data)
    if not _type or not data then return end
    if _type == BattleConst.Closed_Result_Type.LevelUpgradeType then
        -- 升级界面
        LevupgradeController:getInstance():openMainWindow(true, data) 
    elseif _type == BattleConst.Closed_Result_Type.TaskExpType then 
        --隐藏成就
        RoleController:getInstance():openRoleAchieveWindow(true, data)
    elseif _type == BattleConst.Closed_Result_Type.LimitGiftType then 
        --限时礼包类型
        ActionController:getInstance():checkOpenActionLimitGiftMainWindow(data.id)
    end
end

