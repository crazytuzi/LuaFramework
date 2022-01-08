--[[
******属性详情*******
    -- by haidong.gan
    -- 2014/4/10
]]

local RoleAttributeDetail = class("RoleAttributeDetail", BaseLayer)

function RoleAttributeDetail:ctor(data)
    self.super.ctor(self,data)

    self:init("lua.uiconfig_mango_new.role.RoleAttributeDetail")
end

function RoleAttributeDetail:loadData(roleGmId)
    self.roleGmId   = roleGmId;
end

function RoleAttributeDetail:onShow()
    self.super.onShow(self)
    self:refreshBaseUI();
    self:refreshUI();
end

function RoleAttributeDetail:refreshBaseUI()

end

function RoleAttributeDetail:refreshUI()
    if not self.isShow then
        return;
    end
    self.cardRole = CardRoleManager:getRoleByGmid(self.roleGmId);
    
    -- --属性类型枚举
    -- EnumAttributeType = 
    -- {
    --     "Blood",            --气血
    --     "Force",            --武力
    --     "Defence",          --防御
    --     "Magic",            --内力
    --     "Agility",          --身法
    --     "Ice",              --冰
    --     "Fire",             --火
    --     "Poison",           --毒
    --     "IceResistance",    --冰抗
    --     "FireResistance",   --火抗
    --     "PoisonResistance", --毒抗 
    --     "Crit",             --暴击
    --     "CritResistance",   --暴抗
    --     "Preciseness",              --命中
    --     "Miss",                     --闪避
    --     "CritPercent",              --暴击率
    --     "PrecisenessPercent",       --命中率
    --     "BloodPercePercent",        --气血
    --     "ForcePercePercent",        --武力
    --     "DefencePercePercent",      --防御
    --     "MagicPercePercent",        --内力
    --     "AgilityPercePercent",      --身法
    --     "IcePercePercent",          --冰
    --     "FirePercePercent",         --火
    --     "PoisonPercePercent",       --毒
    --     "IceResistancePercent",     --冰抗
    --     "FireResistancePercent",    --火抗
    --     "PoisonResistancePercent",  --毒抗
    --     "Max"
    -- }

    self.txt_arr = {}
    for i=1,EnumAttributeType.Max do
        local node = TFDirector:getChildByPath(self, "panel_shuxing" .. i);
        if  node then
            self.txt_arr[i] =  TFDirector:getChildByPath(node, "txt_shuxingzhi");
        end
    end

    -- self.txt_arr[EnumAttributeType.Blood]   = TFDirector:getChildByPath(TFDirector:getChildByPath(self, "panel_shuxing1"), "txt_shuxingzhi");
    -- self.txt_arr[EnumAttributeType.Force]   = TFDirector:getChildByPath(TFDirector:getChildByPath(self, "panel_shuxing2"), "txt_shuxingzhi");
    -- self.txt_arr[EnumAttributeType.Defence] = TFDirector:getChildByPath(TFDirector:getChildByPath(self, "panel_shuxing4"), "txt_shuxingzhi");
    -- self.txt_arr[EnumAttributeType.Magic]   = TFDirector:getChildByPath(TFDirector:getChildByPath(self, "panel_shuxing5"), "txt_shuxingzhi");
    -- self.txt_arr[EnumAttributeType.Agility] = TFDirector:getChildByPath(TFDirector:getChildByPath(self, "panel_shuxing3"), "txt_shuxingzhi");
    -- self.txt_arr[EnumAttributeType.Ice]     = TFDirector:getChildByPath(TFDirector:getChildByPath(self, "panel_shuxing6"), "txt_shuxingzhi");
    -- self.txt_arr[EnumAttributeType.Fire]    = TFDirector:getChildByPath(TFDirector:getChildByPath(self, "panel_shuxing7"), "txt_shuxingzhi");
    -- self.txt_arr[EnumAttributeType.Poison]  = TFDirector:getChildByPath(TFDirector:getChildByPath(self, "panel_shuxing8"), "txt_shuxingzhi");
    -- self.txt_arr[EnumAttributeType.IceResistance]       = TFDirector:getChildByPath(TFDirector:getChildByPath(self, "panel_shuxing11"), "txt_shuxingzhi");
    -- self.txt_arr[EnumAttributeType.FireResistance]      = TFDirector:getChildByPath(TFDirector:getChildByPath(self, "panel_shuxing9"), "txt_shuxingzhi");
    -- self.txt_arr[EnumAttributeType.PoisonResistance]    = TFDirector:getChildByPath(TFDirector:getChildByPath(self, "panel_shuxing10"), "txt_shuxingzhi");
    -- self.txt_arr[EnumAttributeType.Crit]                = TFDirector:getChildByPath(TFDirector:getChildByPath(self, "panel_shuxing13"), "txt_shuxingzhi");
    -- self.txt_arr[EnumAttributeType.CritResistance]      = TFDirector:getChildByPath(TFDirector:getChildByPath(self, "panel_shuxing15"), "txt_shuxingzhi");
    -- self.txt_arr[EnumAttributeType.Preciseness]         = TFDirector:getChildByPath(TFDirector:getChildByPath(self, "panel_shuxing12"), "txt_shuxingzhi");
    -- self.txt_arr[EnumAttributeType.Miss]                = TFDirector:getChildByPath(TFDirector:getChildByPath(self, "panel_shuxing14"), "txt_shuxingzhi");
    -- -- self.txt_arr[EnumAttributeType.CritPercent] = TFDirector:getChildByPath(TFDirector:getChildByPath(self, "panel_shuxing1"), "txt_shuxingzhi");
    -- -- self.txt_arr[EnumAttributeType.PrecisenessPercent]   = TFDirector:getChildByPath(TFDirector:getChildByPath(self, "panel_shuxing1"), "txt_shuxingzhi");
    -- -- self.txt_arr[EnumAttributeType.BloodPercePercent] = TFDirector:getChildByPath(TFDirector:getChildByPath(self, "panel_shuxing1"), "txt_shuxingzhi");
    -- -- self.txt_arr[EnumAttributeType.ForcePercePercent]   = TFDirector:getChildByPath(TFDirector:getChildByPath(self, "panel_shuxing1"), "txt_shuxingzhi");
    -- -- self.txt_arr[EnumAttributeType.DefencePercePercent]   = TFDirector:getChildByPath(TFDirector:getChildByPath(self, "panel_shuxing1"), "txt_shuxingzhi");
    -- -- self.txt_arr[EnumAttributeType.MagicPercePercent] = TFDirector:getChildByPath(TFDirector:getChildByPath(self, "panel_shuxing1"), "txt_shuxingzhi");
    -- -- self.txt_arr[EnumAttributeType.AgilityPercePercent]   = TFDirector:getChildByPath(TFDirector:getChildByPath(self, "panel_shuxing1"), "txt_shuxingzhi");
    -- -- self.txt_arr[EnumAttributeType.IcePercePercent]   = TFDirector:getChildByPath(TFDirector:getChildByPath(self, "panel_shuxing1"), "txt_shuxingzhi");
    -- -- self.txt_arr[EnumAttributeType.FirePercePercent] = TFDirector:getChildByPath(TFDirector:getChildByPath(self, "panel_shuxing1"), "txt_shuxingzhi");
    -- -- self.txt_arr[EnumAttributeType.PoisonPercePercent]   = TFDirector:getChildByPath(TFDirector:getChildByPath(self, "panel_shuxing1"), "txt_shuxingzhi");
    -- -- self.txt_arr[EnumAttributeType.IceResistancePercent] = TFDirector:getChildByPath(TFDirector:getChildByPath(self, "panel_shuxing1"), "txt_shuxingzhi");
    -- -- self.txt_arr[EnumAttributeType.FireResistancePercent]   = TFDirector:getChildByPath(TFDirector:getChildByPath(self, "panel_shuxing1"), "txt_shuxingzhi");
    -- -- self.txt_arr[EnumAttributeType.PoisonResistancePercent]   = TFDirector:getChildByPath(TFDirector:getChildByPath(self, "panel_shuxing1"), "txt_shuxingzhi");


    --角色属性
    for index,txt_a in pairs(self.txt_arr) do
        local arrStr = self.cardRole:getTotalAttribute(index)
        txt_a:setText(covertToDisplayValue(index,arrStr));
    end
end

function RoleAttributeDetail:initUI(ui)
	self.super.initUI(self,ui)

    self.btn_close      = TFDirector:getChildByPath(ui, 'btn_close');
    
end

function RoleAttributeDetail:registerEvents(ui)
    self.super.registerEvents(self)
    ADD_ALERT_CLOSE_LISTENER(self, self.btn_close); 
    self.btn_close:setClickAreaLength(100);
   
end


return RoleAttributeDetail
