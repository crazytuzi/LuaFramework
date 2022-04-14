SpacetimeCrackDungeScrollItem = SpacetimeCrackDungeScrollItem or class("DungeonScrollItem", DungeonScrollItem)

function SpacetimeCrackDungeScrollItem:ctor()

end

function SpacetimeCrackDungeScrollItem:dctor()

end

function SpacetimeCrackDungeScrollItem:InitUI()
    
    SpacetimeCrackDungeScrollItem.super.InitUI(self)

    self.nodes = {
        "txt_num",
    }
    self:GetChildren(self.nodes);

    self.txt_num = GetText(self.txt_num)
    
    self:SetNum()
end

function SpacetimeCrackDungeScrollItem:AddEvents()

    SpacetimeCrackDungeScrollItem.super.AddEvents(self)


    local function callback(data)
        if data.id == self.data.id then
            --logError("DungeonEvent.WORLD_BOSS_INFO SpacetimeCrackDungeScrollItem")
            local bossinfo = DungeonModel:GetInstance():GetDungeonBossInfo(enum.BOSS_TYPE.BOSS_TYPE_SPATIOTEMPORAL, self.data.id);
            if bossinfo then
                local time = bossinfo.born;--1541494877
                self:StartSechudle(time);
            end
            self:SetNum()
        end
    end
    AddEventListenerInTab(DungeonEvent.WORLD_BOSS_INFO,callback,self.events)
end

--设置剩余数量
function SpacetimeCrackDungeScrollItem:SetNum()
    if self.data.seq >= 1 and self.data.seq <= 3 then
        --时空裂缝 宝箱 守卫 隐藏boss才需要显示剩余数量
        local bossinfo = DungeonModel.GetInstance():GetDungeonBossInfo(enum.BOSS_TYPE.BOSS_TYPE_SPATIOTEMPORAL, self.data.id)
        if bossinfo then
            local num = bossinfo.num
            if self.data.seq == 3 then
                --隐藏boss要计算总数
                num = DungeonModel.GetInstance():GetSpaceTimeCrackConcealmentBossNum()
            end
            self.txt_num.text = string.format( "Left: %s",num)
        else
            self.txt_num.text = string.format( "Left: %s",self.data.num)
        end
    else
        SetVisible(self.txt_num.transform,false)
    end
end

--设置阶数
function SpacetimeCrackDungeScrollItem:SetJie(num)

    if self.data.seq >= 1 and self.data.seq <= 3 then
        --时空裂缝 宝箱 守卫 隐藏boss不显示阶数
        SetVisible(self.jie.transform,false)
        SetVisible(self.jieText.transform,false)
        return
    end

    self.jieText.text = num .. "Tier";
   
end

--设置boss名
function SpacetimeCrackDungeScrollItem:SetBossName(str)

    if self.data.seq >= 1 and self.data.seq <= 3 then
        --时空裂缝 宝箱 守卫 隐藏boss不显示等级
        self.bossName.text = self.data.name
        return
    end

    self.bossName.text = str;
end

--开始倒计时
function SpacetimeCrackDungeScrollItem:StartSechudle(time)

    --隐藏boss不需要倒计时
    if self.data.seq == 3 then
        return
    end

    
    SpacetimeCrackDungeScrollItem.super.StartSechudle(self,time)
end