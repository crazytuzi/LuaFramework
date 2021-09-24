FuncSwitchApi = {
    --存放非功能开关的功能，怀旧服需要关闭部分功能
    MemoryServer = {
        luck_lottery = 0, --幸运抽奖
        elite = 0, --精英坦克功能
        diku_repair = 0, --地库修理保护（修理厂）
        friend_gift = 1, --好友送礼
        alliance_active = 0, --军团活跃
        alliance_city = 0, --军团城市
        individuation = 1, --玩家个性化设置
        hero_equip = 0, --将领装备
        newSign_exchange = 0, --30天签到兑换功能
        heroskill_revision = 0, --将领部分技能改版
        armor_lottery_yh = 0, --装甲矩阵高级抽奖10抽必得紫色优化
        accessory_warehouse_expand = 0, --配件仓库扩容
        worldRebel_buff = 0, --世界叛军天眼
    },
}

function FuncSwitchApi:init()
    
end

function FuncSwitchApi:isEnabled(fkey)
    if self.MS == nil then
        self.MS = G_isMemoryServer()
    end
    if self.MS == true then
        if self.MemoryServer[fkey] == 0 then
            return false
        end
    end
    return true
end

function FuncSwitchApi:clear()
    self.MS = nil
end
