SpacetimeCrackDungeonLeftCenterItem = SpacetimeCrackDungeonLeftCenterItem or class("SpacetimeCrackDungeonLeftCenterItem", DungeonLeftCenterItem);
local this = SpacetimeCrackDungeonLeftCenterItem
local ConfigLanguage = require('game.config.language.CnLanguage')
function SpacetimeCrackDungeonLeftCenterItem:ctor(obj, data)

end

function SpacetimeCrackDungeonLeftCenterItem:dctor()

end


--堕落战神 <color=#ffffff>Lv.260</color>
function SpacetimeCrackDungeonLeftCenterItem:InitUI()
    self.boss_name = GetText(self.boss_name);
    self.status = GetText(self.status);
    self.selected = GetImage(self.selected);
    self.selected.gameObject:SetActive(false);
    if self.order_img then
        self.order_img = GetImage(self.order_img)
    end

    self.statustime = GetText(self.statustime);
    SetGameObjectActive(self.statustime, false);
    if self.data then

        self:UpdateBossName()

        self:UpdateBossNum()

        self:UpdateBossOrder()


        local bossConfig = Config.db_boss[self.data.id]
        --普通boss 尝试倒计时
        if  not self:IsSpacetimeCrackBossSeq123(bossConfig) then
            local bossinfo = DungeonModel:GetInstance():GetDungeonBossInfo(enum.BOSS_TYPE.BOSS_TYPE_SPATIOTEMPORAL, self.data.id);
            if bossinfo then
                local time = bossinfo.born;--1541494877
                self:StartSechudle(time);
            end
        end

    end

end




function SpacetimeCrackDungeonLeftCenterItem:StartSechudle(time)

    local bossConfig = Config.db_boss[self.data.id]

    if self:IsSpacetimeCrackBossSeq123(bossConfig) then
        --宝箱 守卫 隐藏boss 不处理
        return
    end

    --普通boss才处理
    SpacetimeCrackDungeonLeftCenterItem.super.StartSechudle(self,time)

    

end




function SpacetimeCrackDungeonLeftCenterItem:HandleBossInfoUpdate(data)
    if data  then
        --logError("SpacetimeCrackDungeonLeftCenterItem:HandleBossInfoUpdate,data-" .. Table2String(data))

        if data.id == self.data.id then
            self:UpdateBossNum()
            return
        end

        local cfg1 = Config.db_boss[self.data.id]
        local cfg2 = Config.db_boss[data.id]
        if cfg1.type == enum.BOSS_TYPE.BOSS_TYPE_SPATIOTEMPORAL2 and cfg2.type == enum.BOSS_TYPE.BOSS_TYPE_SPATIOTEMPORAL2 then
            --隐藏boss数量要算在一起
            self:UpdateBossNum()
        end
    end


end


--刷新boss名称
function SpacetimeCrackDungeonLeftCenterItem:UpdateBossName(  )
    local creep = Config.db_creep[self.data.id];
    local bossConfig = Config.db_boss[self.data.id];
    if self:IsSpacetimeCrackBossSeq123(bossConfig) then
        --宝箱 守卫 隐藏Boss

        --显示名字 不带等级
        self.boss_name.text = "<color=#ffffff>" .. creep.name .. "</color>"
    else
        --普通boss 显示名字 带等级
        self.boss_name.text = "<color=#ffffff>" .. creep.name .. "  " .. string.format(ConfigLanguage.Common.Level, creep.level) .. "</color>"
    end 
end

--刷新boss剩余数量
function SpacetimeCrackDungeonLeftCenterItem:UpdateBossNum(  )
    local bossConfig = Config.db_boss[self.data.id]

    if self:IsSpacetimeCrackBossSeq123(bossConfig) then
        --宝箱 守卫 隐藏Boss
        --才显示剩余数量


        local bossInfoTab = DungeonModel:GetInstance():GetDungeonBossInfo(enum.BOSS_TYPE.BOSS_TYPE_SPATIOTEMPORAL , bossConfig.id);

        if bossInfoTab then

            local num = bossInfoTab.num
            if self:IsSpacetimeCrackBossSeq3(bossConfig) then
                --隐藏boss 需要计算总数量
                num = DungeonModel.GetInstance():GetSpaceTimeCrackConcealmentBossNum()
                --logError("SpacetimeCrackDungeonLeftCenterItem:UpdateBossNum 计算隐藏boss数量，num-"..num)
            end

            if self:IsSpacetimeCrackBossSeq3(bossConfig) and num == 0 then
                --隐藏boss剩余数量为0时 显示为未刷新
                self.status.text = "<color=#D6302F>" .. "Not refreshed" .. "</color>";
            else
                --宝箱 守卫 剩余数量不为0的隐藏boss 直接显示数量
                self.status.text = "<color=#ffffff>" .. num .. "</color>";
            end
        else

            if self:IsSpacetimeCrackBossSeq3(bossConfig) then
                self.status.text = "<color=#D6302F>" .. "Not refreshed" .. "</color>";
            else
                self.status.text = "<color=#ffffff>" ..  0 .. "</color>";
            end

            
        end
    end 
end

--刷新boss阶数
function  SpacetimeCrackDungeonLeftCenterItem:UpdateBossOrder(  )
    local bossConfig = Config.db_boss[self.data.id]

    if self:IsSpacetimeCrackBossSeq123(bossConfig) then
        --宝箱 守卫 隐藏Boss
        --不显示阶数
        SetVisible(self.order_img.transform, false)
    else
        --普通boss 显示阶数
        SetVisible(self.order_img.transform, true)
        lua_resMgr:SetImageTexture(self,self.order_img, 'dungeon_image', 'order_' .. bossConfig.order ,true)
    end
end

--是否是时空裂缝boss中的宝箱 守卫
function SpacetimeCrackDungeonLeftCenterItem:IsSpacetimeCrackBossSeq12( bossConfig )
    local flag = DungeonModel.GetInstance():IsSpacetimeCrackBoss(bossConfig.type) and (bossConfig.seq == 1 or bossConfig.seq == 2)
    return flag
end

--是否是时空裂缝boss中的隐藏boss
function SpacetimeCrackDungeonLeftCenterItem:IsSpacetimeCrackBossSeq3( bossConfig )
    local flag = DungeonModel.GetInstance():IsSpacetimeCrackBoss(bossConfig.type) and (bossConfig.seq == 3)
    return flag
end

--是否是时空裂缝boss中的宝箱 守卫 隐藏boss
function SpacetimeCrackDungeonLeftCenterItem:IsSpacetimeCrackBossSeq123( bossConfig )
    local flag = DungeonModel.GetInstance():IsSpacetimeCrackBoss(bossConfig.type) and (bossConfig.seq == 1 or bossConfig.seq == 2 or bossConfig.seq == 3)
    return flag
end