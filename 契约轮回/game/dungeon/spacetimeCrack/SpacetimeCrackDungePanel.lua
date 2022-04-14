SpacetimeCrackDungePanel = SpacetimeCrackDungePanel or class("SpacetimeCrackDungePanel",SavageBossPanel)

SpacetimeCrackDungePanel.ExpelTip = "The noisy sound makes the gods feel angry.\nThe angry god will expel you out of Time Rift"
SpacetimeCrackDungePanel.EnterTimeTip = "Attempts of entering Time Rift reaches max and can't enter"

function SpacetimeCrackDungePanel:ctor()
    self.parentPanel.outer_boss_info_callback = nil
    self.parentPanel.outer_drop_callback = nil
end

function SpacetimeCrackDungePanel:GetAssetName(  )
    return "SpacetimeCrackDungePanel"
end

function SpacetimeCrackDungePanel:GetSelectedBossType()
    return enum.BOSS_TYPE.BOSS_TYPE_SPATIOTEMPORAL  --时空裂缝的boss类型
end


function SpacetimeCrackDungePanel:GetVipRightsType(  )
    return enum.VIP_RIGHTS.VIP_RIGHTS_SPATIOTEMPORAL_BOSS --时空裂缝的进入次数
end

function SpacetimeCrackDungePanel:GetBossTab(  )
    return self.model.spacetimeCrackBossTab  --时空裂缝boss表
end

function SpacetimeCrackDungePanel:GetEnterTimeTip(  )
    return SpacetimeCrackDungePanel.EnterTimeTip
end

function SpacetimeCrackDungePanel:GetScrollItemClass(  )
    return SpacetimeCrackDungeScrollItem
end

function SpacetimeCrackDungePanel:LoadCallBack()

    

    self.nodes = {
        "box_parent/txt_box_desc","box_parent/txt_box_num","box_parent/txt_box_name","box_parent",
        "concealment_boss_parent","concealment_boss_parent/txt_concealment_boss_num","concealment_boss_parent/txt_concealment_boss_desc",
    }
    self:GetChildren(self.nodes)

    self.txt_box_desc = GetText(self.txt_box_desc)
    self.txt_box_num = GetText(self.txt_box_num)
    self.txt_box_name = GetText(self.txt_box_name)

    self.txt_concealment_boss_desc = GetText(self.txt_concealment_boss_desc)
    self.txt_concealment_boss_num = GetText(self.txt_concealment_boss_num)

    SpacetimeCrackDungePanel.super.LoadCallBack(self)
end



--处理Boss item点击
--需要根据点击的类型进行不同的显示
function SpacetimeCrackDungePanel:HandleSelectItem(target, x, y , v)



    local item = nil;
    for i = 1, #self.items, 1 do
        if self.items[i].gameObject == target then
            item = self.items[i];
            self.selectedItemIndex = i;
        end
        self.items[i]:SetSelected(false);
    end
    item:SetSelected(true);
    -- self.parentPanel:InitDrops(item);
    -- self.parentPanel:SetBG(item);
    -- self.parentPanel:InitModelView(item);
    -- self.parentPanel:RefreshProp(item);

    --logError("SpacetimeCrackDungePanel:HandleSelectItem,index-"..self.selectedItemIndex)

    SetVisible(self.box_parent,false)
    SetVisible(self.concealment_boss_parent,false)

    self.parentPanel.outer_boss_info_callback = nil
    self.parentPanel.outer_drop_callback = nil  

    self.parentPanel:InitModelView(item);
    if self.selectedItemIndex == 1 or  self.selectedItemIndex == 2 then
        --精粹宝箱或者精英守卫
        --名称、介绍文字、形象、当前剩余数量，无按钮
        self:ShowBox(item)
    elseif self.selectedItemIndex == 3 then
        
        --隐藏boss
        --默认显示珍惜掉落和介绍文字、剩余数量，2个按钮
        self:ShowConcealmentBoss(item)
    else
        --固定boss
        --默认显示珍惜掉落和关注框，2个按钮
       self:ShowFixedBoss(item)
    end

    local tab = DungeonModel:GetInstance():GetDungeonBossInfo(self.boss_type, item.data.id);
    if tab then
        self.parentPanel:SetIsCare(tab.care)
    end
end

--显示宝箱或守卫
function SpacetimeCrackDungePanel:ShowBox(item)


    SetVisible(self.box_parent,true)
    
    self.parentPanel:BeastCallBack()

    self.txt_box_name.text = item.data.name

    local desc = "Refresh randomly. Open and have a chance to get artifact materials"
    local num_str = "Current amount of remaining %s: %s"
    if item.data.seq == 2 then
        desc = "Deaft to get artifact materials"
        --num_str = "当前剩余%s数量：%s"
    end

    self.txt_box_desc.text = desc

    local num = item.data.num
    local tab = DungeonModel:GetInstance():GetDungeonBossInfo(self.boss_type, item.data.id);
    if tab then
        num = tab.num   
    end
    self.txt_box_num.text = string.format( num_str,item.data.name,num )
end

--显示隐藏boss
function SpacetimeCrackDungePanel:ShowConcealmentBoss(item )

    SetVisible(self.concealment_boss_parent,true)
    
    self.parentPanel:DropCallBack();
    self.parentPanel:InitDrops(item);
    self.parentPanel:SetBG(item);

    self.parentPanel:RefreshProp(item);

    self.parentPanel:ShowOrHideCare(false)

    local num = DungeonModel.GetInstance():GetSpaceTimeCrackConcealmentBossNum()
    self.txt_concealment_boss_desc.text = "Defeat default BOSS\n refresh on random spot"
    self.txt_concealment_boss_num.text = string.format( "Hiden Boss left: %s",num )

    local function boss_info_callback(  )
        SetVisible(self.concealment_boss_parent,false)
    end
    self.parentPanel.outer_boss_info_callback = boss_info_callback

    local function drop_callback(  )
        SetVisible(self.concealment_boss_parent,true)
        self.parentPanel:ShowOrHideCare(false)
    end
    self.parentPanel.outer_drop_callback = drop_callback
end

--显示固定boss
function SpacetimeCrackDungePanel:ShowFixedBoss(item)

    self.parentPanel:DropCallBack();
    self.parentPanel:InitDrops(item);
    self.parentPanel:SetBG(item);

    self.parentPanel:RefreshProp(item);
end

function SpacetimeCrackDungePanel:HaneleBossList(data)

    SpacetimeCrackDungePanel.super.HaneleBossList(self,data)

    --设置疲劳显示
    local main_role_data = RoleInfoModel:GetInstance():GetMainRoleData()
    if main_role_data then
        local buffer = main_role_data:GetBuffByID(enum.BUFF_ID.BUFF_ID_FISSURE_BOSS_TIRED)
        local value = (buffer and buffer.value or 0)
        local tired = 2;
        local vip_lv = RoleInfoModel:GetInstance():GetMainRoleVipLevel();
        local vipRightTab = Config.db_vip_rights[enum.VIP_RIGHTS.VIP_RIGHTS_FISSURE_TIRED];
        local base = tonumber(vipRightTab.base);
        local added = tonumber(vipRightTab["vip" .. vip_lv]);
        tired = base + added;

        self.curTired = SafetoNumber(tired) - SafetoNumber(value)
        if self.curTired < 0 then
            self.curTired = 0
        end
        self.pilao_text = "Boss Fatigue: " .. self.curTired .. "/" .. tired;
        -- if self.currentFloor > 0 then
        --     self.pilaoText.text =self.pilao_text
        -- else
        --     self.pilaoText.text = "不减少疲劳值"
        -- end
        self.pilaoText.text =self.pilao_text
    end

    self:HandleSelectItem(self.items[self.selectedItemIndex].gameObject)

    --logError("HandleBossList,data-"..Table2String(data))
end

function SpacetimeCrackDungePanel:RefreshDungeonScrollItem(item)

    SpacetimeCrackDungePanel.super.RefreshDungeonScrollItem(self,item)

    local bossTab = item.data;

    local bossinfo = DungeonModel:GetInstance():GetDungeonBossInfo(self.boss_type, bossTab.id);
    if bossinfo then
        item:SetNum()
    end
end

function  SpacetimeCrackDungePanel:GetHelpTip(  )

    local tip = [[
<color=#197dca>Time Rift Rules：</color>
1、In Time Rift, default rage is 100。
2、In the scene, <color=#009512>every mins</color> will cost <color=#009512>1</color> rage
3、Every<color=#009512>0、1、9、11、13、15、17、19、21、23 o'clock</color> will refresh Boss, Box, Vanguard.
4、Defeat BOSS and guards; Collecting boxes; Be defeated will <color=#009512>cost</color> rage
5、Hidden Boss will randomly show up after defeating the common boss
6、When rage reaches <color=#009512>0</color>, there will be <color=#009512>30s</color> countdown. When countdown ends will <color=#009512>Exit</color> Time Rift.
7、Raise VIP lvl can increase entering attempts and boss max fatigue
Tip: This map is <color=#009512>Cross Server PK area</color>. In this map you may <color=#009512>be attacked by others</color>. Be careful.
    ]]

    return tip
   
end


