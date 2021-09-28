require "Core.Module.Yaoyuan.controlls.PlantCtr"

require "Core.Module.Yaoyuan.controlls.PlantHarvestEffControll"

FarmsControll = class("FarmsControll");
FarmsControll.ins = nil;

FarmsControll.maxNum = 12;
local _sortfunc = table.sort 

function FarmsControll:New()
    self = { };
    setmetatable(self, { __index = FarmsControll });
    return self
end


function FarmsControll:Init(gameObject)
    self.gameObject = gameObject;

    self.panels = { };

    for i = 1, FarmsControll.maxNum do
        local tu = UIUtil.GetChildByName(self.gameObject, "Transform", "tu" .. i);
        self.panels[i] = PlantCtr:New();
        self.panels[i]:Init(tu);
    end

    local plantHarvestEff = UIUtil.GetChildByName(self.gameObject, "UITexture", "plantHarvestEff");

    self.plantHarvestEffCtr = PlantHarvestEffControll:New();
    self.plantHarvestEffCtr:Init(plantHarvestEff);


    FarmsControll.ins = self;

end

function FarmsControll:UpInfos()
   self:SetData(self.farms, self.type)
end

--[[
 S <-- 17:29:04.150, 0x1401, 14, {
 "farms":[
 {"st":0,"gt":1469160068,"s":"","wt":0,"i":2},
 {"st":0,"gt":1469160068,"s":"","wt":0,"i":4},
 {"st":0,"gt":1469160068,"s":"","wt":0,"i":1},
 {"st":0,"gt":1469160068,"s":"","wt":0,"i":3}
 ],
 "pf":{"st":"2016-07-22 10:21:08","gts":0,"sts":0,"odd":0,"gt":"2016-07-22 10:21:08","wt":0}}
]]

function FarmsControll:SetData(farms, type)

    self.type = type;
    self.farms = farms;

    _sortfunc(farms, function(a, b) return a.i < b.i end);

    local t_num = table.getn(farms);

    local listData = {};

    for i = 1, FarmsControll.maxNum do
        listData[i]=nil;
    end

    for i = 1, t_num do
        local idx = farms[i].i;
         listData[idx]=farms[i];
    end


    ----------------------
     for i = 1, 12 do
         self.panels[i]:SetData(listData[i], i, type,true);
     end

end



function FarmsControll:GetPanels()
    return self.panels;
end

function FarmsControll:GetFreePlanIdx()

    local res = { };
    local index = 1;

    for i = 1, FarmsControll.maxNum do
        local pl = self.panels[i];

        if pl.lock == false and pl.hasPanel == false then
            res[index] = pl.index;
            index = index + 1;
        end
    end

    return res;
end

function FarmsControll:GetPanelByIdx(idx)
    for i = 1, FarmsControll.maxNum do
        if self.panels[i].index == idx then
            return self.panels[i];
        end
    end
    return nil;
end

function FarmsControll:Show()




    self.gameObject.gameObject:SetActive(true);
end

function FarmsControll:Hide()

    self.gameObject.gameObject:SetActive(false);
end

function FarmsControll:Dispose()

    for i = 1, FarmsControll.maxNum do
        self.panels[i]:Dispose();
        self.panels[i] = nil;
    end

    self.plantHarvestEffCtr:Dispose()
    self.plantHarvestEffCtr = nil;
    FarmsControll.ins = nil;
end