

NextSuitAttributeItem = class("NextSuitAttributeItem");


function NextSuitAttributeItem:New()
    self = { };
    setmetatable(self, { __index = NextSuitAttributeItem });
    return self;
end

function NextSuitAttributeItem:Init(gameObject, i, old_id, curr_id)

    self.gameObject = gameObject;
    self.id = i;

    self.attTitle = UIUtil.GetChildByName(self.gameObject, "UILabel", "attTitle");

    for i = 1, 3 do
        self["atttxt" .. i] = UIUtil.GetChildByName(self.gameObject, "UILabel", "atttxt" .. i);
    end

    if old_id == curr_id then
        -- 等级没有发生改变
        if i == 3 then
            self.gameObject.gameObject:SetActive(false);
        elseif i == 1 then
            self:SetCurrData();
        elseif i == 2 then
            self:SetData();
        end

    else
        -- 等级有发生改变
        -- 临时处理
        if i == 3 then
            self.gameObject.gameObject:SetActive(false);
        elseif i == 1 then
            self:SetCurrData();
        elseif i == 2 then
            self:SetData();
        end
    end



end



function NextSuitAttributeItem:SetData()

    local my_info = HeroController:GetInstance().info;
    local my_career = my_info:GetCareer();

    local c_id = MouldingDataManager.currSuit_id;
    local att;
    if c_id == 0 then
        c_id = 1;
        att = MouldingDataManager.Get_treasuretype_attribute_byId(c_id, my_career);
        self:UpInfos(att, false);

    else
        att = MouldingDataManager.Get_treasuretype_attribute_byId(c_id, my_career);

        local star = att.star;
        local piece = att.piece;

        if star == 10 and piece == 8 then
            for i = 1, 3 do
                self["atttxt" .. i].gameObject:SetActive(false);
            end
            self.attTitle.gameObject:SetActive(false);
        else

            c_id = c_id + 1;
            att = MouldingDataManager.Get_treasuretype_attribute_byId(c_id, my_career);
            self:UpInfos(att, false);

        end

    end




end

--[[
301440
301450
301460
301470
301480
]]

function NextSuitAttributeItem:SetCurrData()

    local my_info = HeroController:GetInstance().info;
    local my_career = my_info:GetCareer();



    local l1 = LanguageMgr.Get("Equip/NextSuitAttributeItem/label1");
    local l2 = LanguageMgr.Get("Equip/NextSuitAttributeItem/label2");
    local l3 = LanguageMgr.Get("Equip/NextSuitAttributeItem/label3");
    local l4 = LanguageMgr.Get("Equip/NextSuitAttributeItem/label4");
    local l5 = LanguageMgr.Get("Equip/NextSuitAttributeItem/label5");

    local c_id = MouldingDataManager.currSuit_id;
    local att;
    if c_id == 0 then
        c_id = 1;
        att = MouldingDataManager.Get_treasuretype_attribute_byId(c_id, my_career);

        self.attTitle.text = "[b2c5ff]" .. l1 .. att.piece .. l2 .. "[-][ffffff]" .. att.star .. l3 .. "[-][b2c5ff](" .. l4 .. ")[-]";
    else
        att = MouldingDataManager.Get_treasuretype_attribute_byId(c_id, my_career);

        self.attTitle.text = "[b2c5ff]" .. l1 .. att.piece .. l2 .. "[-][ffffff]" .. att.star .. l3 .. "[-][77ff47](" .. l5 .. ")[-]";
    end


    self["atttxt1"].text = LanguageMgr.Get("attr/hp_max") .. "： " .. att.hp_max;

    -- if att.phy_att ~= 0 then
        self["atttxt2"].text = LanguageMgr.Get("attr/phy_att") .. "： " .. att.phy_att;
    -- else
    --     self["atttxt2"].text = LanguageMgr.Get("attr/mag_att") .. "： " .. att.mag_att;
    -- end

    self["atttxt3"].text = LanguageMgr.Get("attr/phy_def") .. "： " .. att.phy_def;
    -- self["atttxt4"].text = LanguageMgr.Get("attr/mag_def") .. "： " .. att.mag_def;

end

function NextSuitAttributeItem:UpInfos(att, isActive)

    local l1 = LanguageMgr.Get("Equip/NextSuitAttributeItem/label1");
    local l2 = LanguageMgr.Get("Equip/NextSuitAttributeItem/label2");
    local l3 = LanguageMgr.Get("Equip/NextSuitAttributeItem/label3");
    local l4 = LanguageMgr.Get("Equip/NextSuitAttributeItem/label4");
    local l5 = LanguageMgr.Get("Equip/NextSuitAttributeItem/label5");


    if isActive then
        self.attTitle.text = "[b2c5ff]" .. l1 .. att.piece .. l2 .. "[-][ffffff]" .. att.star .. l3 .. "[-][77ff47](" .. l5 .. ")[-]";
    else
        self.attTitle.text = "[b2c5ff]" .. l1 .. att.piece .. l2 .. "[-][ffffff]" .. att.star .. l3 .. "[-][b2c5ff](" .. l4 .. ")[-]";
    end


    self["atttxt1"].text = LanguageMgr.Get("attr/hp_max") .. "： " .. att.hp_max;

    -- if att.phy_att ~= 0 then
        self["atttxt2"].text = LanguageMgr.Get("attr/phy_att") .. "： " .. att.phy_att;
    -- else
        -- self["atttxt2"].text = LanguageMgr.Get("attr/mag_att") .. "： " .. att.mag_att;
    -- end

    self["atttxt3"].text = LanguageMgr.Get("attr/phy_def") .. "： " .. att.phy_def;
    -- self["atttxt4"].text = LanguageMgr.Get("attr/mag_def") .. "： " .. att.mag_def;


end

function NextSuitAttributeItem:Dispose()

    self.gameObject = nil;


    self.attTitle = nil;

    for i = 1, 3 do
        self["atttxt" .. i] = nil;
    end

end