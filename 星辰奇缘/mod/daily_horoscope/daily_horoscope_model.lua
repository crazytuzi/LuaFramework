DailyHoroscopeModel = DailyHoroscopeModel or BaseClass(BaseModel)

function DailyHoroscopeModel:__init()
    self.up_cost_confirm_tips = false
    self.up_result_msg = nil
    self.main_win = nil

    self.open_lev = 40

    self.item_bubble_tips_name = {
        [1] = TI18N("疾风")
        ,[2] = TI18N("秘林")
        ,[3] = TI18N("天火")
        ,[4] = TI18N("山岳")
        ,[5] = TI18N("星辰")
    }

    self.item_bubble_tips = {
        [1] = TI18N( "1阶祝福")
        ,[2] = TI18N("2阶祝福")
        ,[3] = TI18N("3阶祝福")
        ,[4] = TI18N("4阶祝福")
        ,[5] = TI18N("5阶祝福")
    }

    self.item_bubble_tips2 = {
        [1] = TI18N("代表今天<color='#f58140'>状态不错</color>，可获得<color='#51e314'>一个祝福</color>，但不会获得道具奖励")
        ,[2] = TI18N("代表今天<color='#f58140'>状态很好</color>，可获得一个<color='#51e314'>较好的祝福</color>，但不会获得道具奖励")
        ,[3] = TI18N("代表今天<color='#f58140'>状态极好</color>，可获得一个<color='#51e314'>优质祝福</color>与<color='#51e314'>道具奖励</color>")
        ,[4] = TI18N("代表<color='#f58140'>洪福齐天</color>，可获得<color='#51e314'>稀有祝福</color>与<color='#51e314'>优秀道具奖励</color>")
        ,[5] = TI18N("代表今天状态<color='#f58140'>甄至极境</color>，可获得<color='#51e314'>超强祝福</color>与<color='#51e314'>极品道具奖励</color>")
    }
end


function DailyHoroscopeModel:__delete()

end

-- --打开每日运势主界面
-- function DailyHoroscopeModel:InitMainUI()
--     if RoleManager.Instance.RoleData.lev < self.open_lev then
--         NoticeManager.Instance:FloatTipsByString(string.format("%s<color='#ffff00'>%s</color>%s", TI18N("每日祝福"), self.open_lev, TI18N("级开启")))
--         return
--     end
--     if self.main_win == nil then
--         self.main_win = DailyHoroscopeWindow.New(self)
--     end
--     self.main_win:Open()
-- end

-- function DailyHoroscopeModel:CloseMainUI()
--     if self.main_win ~= nil then
--         WindowManager.Instance:CloseWindow(self.main_win)
--     end
--     if self.main_win == nil then
--         -- print("===================self.main_win is nil")
--     else
--         -- print("===================self.main_win is not nil")
--     end
-- end


-------------------------更新每日运势
function DailyHoroscopeModel:update_info()
    -- if self.main_win ~= nil then
    --     self.main_win:update_info()
    -- end
    EventMgr.Instance:Fire(event_name.daily_horoscope_update)
end

--设置显示特效状态为true
function DailyHoroscopeModel:set_show_effect()
    -- if self.main_win ~= nil then
    --     self.main_win:set_show_effect()
    -- end
    EventMgr.Instance:Fire(event_name.daily_horoscope_effect_update)
end


-------------------------检查数据状态
function DailyHoroscopeModel:CheckRedPointState()
    if self.info_data ~= nil then
        return self.info_data.is_receive == 0
    end
    return false
end