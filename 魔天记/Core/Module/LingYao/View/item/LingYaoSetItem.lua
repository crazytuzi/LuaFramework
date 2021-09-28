require "Core.Module.Common.UIItem"


LingYaoSetItem = class("LingYaoSetItem", UIItem);

-- 丹药 品 的 颜色 值 
LingYaoSetItem.gradeColor = { };

-- 一品丹药
LingYaoSetItem.gradeColor[1] = {
    gradientBottom = Color.New(204 / 255,234 / 255,246 / 255,
    -- 下 颜色
    255 / 255);
    gradientTop = Color.New(255 / 255,255 / 255,255 / 255,
    -- 上 颜色
    255 / 255);
    color = Color.New(255 / 255,255 / 255,255 / 255,
    -- 颜色
    255 / 255);
    effectColor = Color.New(75 / 255,132 / 255,227 / 255,255 / 255);--  描边 颜色
};


LingYaoSetItem.gradeColor[2] = {
    gradientBottom = Color.New(204 / 255,234 / 255,246 / 255,
    -- 下 颜色
    255 / 255);
    gradientTop = Color.New(255 / 255,255 / 255,255 / 255,
    -- 上 颜色
    255 / 255);
    color = Color.New(255 / 255,255 / 255,255 / 255,
    -- 颜色
    255 / 255);
    effectColor = Color.New(75 / 255,132 / 255,227 / 255,255 / 255);--  描边 颜色
};


LingYaoSetItem.gradeColor[3] = {
    gradientBottom = Color.New(49 / 255,228 / 255,36 / 255,
    255 / 255);
    gradientTop = Color.New(233 / 255,255 / 255,215 / 255,
    255 / 255);
    color = Color.New(255 / 255,255 / 255,255 / 255,
    255 / 255);
    effectColor = Color.New(36 / 255,130 / 255,53 / 255,255 / 255);
};


LingYaoSetItem.gradeColor[4] = {
    gradientBottom = Color.New(49 / 255,228 / 255,36 / 255,
    255 / 255);
    gradientTop = Color.New(233 / 255,255 / 255,215 / 255,
    255 / 255);
    color = Color.New(255 / 255,255 / 255,255 / 255,
    255 / 255);
    effectColor = Color.New(36 / 255,130 / 255,53 / 255,255 / 255);
};

LingYaoSetItem.gradeColor[5] = {
    gradientBottom = Color.New(44 / 255,133 / 255,255 / 255,
    255 / 255);
    gradientTop = Color.New(228 / 255,249 / 255,255 / 255,
    255 / 255);
    color = Color.New(255 / 255,255 / 255,255 / 255,
    255 / 255);
    effectColor = Color.New(16 / 255,41 / 255,210 / 255,255 / 255);
};

LingYaoSetItem.gradeColor[6] = {
    gradientBottom = Color.New(44 / 255,133 / 255,255 / 255,
    255 / 255);
    gradientTop = Color.New(228 / 255,249 / 255,255 / 255,
    255 / 255);
    color = Color.New(255 / 255,255 / 255,255 / 255,
    255 / 255);
    effectColor = Color.New(16 / 255,41 / 255,210 / 255,255 / 255);
};

LingYaoSetItem.gradeColor[7] = {
    gradientBottom = Color.New(137 / 255,59 / 255,255 / 255,
    255 / 255);
    gradientTop = Color.New(237 / 255,228 / 255,255 / 255,
    255 / 255);
    color = Color.New(255 / 255,255 / 255,255 / 255,
    255 / 255);
    effectColor = Color.New(113 / 255,23 / 255,155 / 255,255 / 255);
};


LingYaoSetItem.gradeColor[8] = {
    gradientBottom = Color.New(137 / 255,59 / 255,255 / 255,
    255 / 255);
    gradientTop = Color.New(237 / 255,228 / 255,255 / 255,
    255 / 255);
    color = Color.New(255 / 255,255 / 255,255 / 255,
    255 / 255);
    effectColor = Color.New(113 / 255,23 / 255,155 / 255,255 / 255);
};


LingYaoSetItem.gradeColor[9] = {
    gradientBottom = Color.New(239 / 255,246 / 255,28 / 255,
    255 / 255);
    gradientTop = Color.New(254 / 255,255 / 255,228 / 255,
    255 / 255);
    color = Color.New(255 / 255,255 / 255,255 / 255,
    255 / 255);
    effectColor = Color.New(157 / 255,128 / 255,13 / 255,255 / 255);
};



function LingYaoSetItem:New()
    self = { };
    setmetatable(self, { __index = LingYaoSetItem });
    return self
end
 

function LingYaoSetItem:UpdateItem(data)
    self.data = data
end

function LingYaoSetItem:Init(gameObject, data)

    self.gameObject = gameObject;


    self.label = UIUtil.GetChildByName(self.gameObject, "UILabel", "label");
    self.req_lv_txt = UIUtil.GetChildByName(self.gameObject, "UILabel", "req_lv_txt");

    for i = 1, 8 do
        local proPanel = UIUtil.GetChildByName(self.gameObject, "Transform", "proPanel" .. i);

        self["addBg" .. i] = UIUtil.GetChildByName(proPanel, "UISprite", "addBg");


        self["proPanelCtr" .. i] = ProductCtrl:New();
        self["proPanelCtr" .. i]:Init(proPanel, { hasLocke = true, use_sprite = true, iconType = ProductCtrl.IconType_rectangle }, true);
        self["proPanelCtr" .. i]:SetOnClickBtnHandler(ProductCtrl.TYPE_FROM_OTHER);
        self["proPanelCtr" .. i]:SetNotProductClickHander(LingYaoSetItem.SetNotProductClickHander, self);

        self["addBg" .. i].gameObject:SetActive(false);

        self["proPanel" .. i] = proPanel;

    end

    self:SetData(data)

end

function LingYaoSetItem:SetNotProductClickHander(proCtr)

    if proCtr.canAddPro then

        --  准备 使用 物品
        local spId = self.data.id;
        local info = BackpackDataManager.GetProductBySpid(spId);

        LingYaoProxy.TryUseProduct(info, 1, LingYaoSetItem.UseProductSuccess, self)

    end

end


function LingYaoSetItem:UseProductSuccess()

    PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.LingYao)

    self:UpInfos()

   LingYaoSetControll.CheckNPoint();

end

function LingYaoSetItem:SetActive(v)
    self.gameObject.gameObject:SetActive(v);
end

function LingYaoSetItem:UpInfos()

    self.label.text = self.data.name;

    local use_num = self.data.use_num;

    local am = LingYaoDataManager.GetHasUseAm(self.data.id);
    local ower_num = BackpackDataManager.GetProductTotalNumBySpid(self.data.id);
    local hasShowAddTip = false;

    for i = 1, 8 do
        if i <= use_num then

            if i <= am then
                local info = ProductManager.GetProductInfoById(self.data.id, 1);
                self["proPanelCtr" .. i]:SetData(info);
                self["addBg" .. i].gameObject:SetActive(false);
            else
                self["proPanelCtr" .. i]:SetData(nil);

                if not hasShowAddTip then
                    hasShowAddTip = true;

                    -- 需要判断 在背包中是否 有对应 的 物品 存在
                    if ower_num > 0 then
                        self["proPanelCtr" .. i].canAddPro = true;
                        self["addBg" .. i].gameObject:SetActive(true);
                        self.currCanAdd_index = i;
                    end
                end

            end

            self["proPanel" .. i].gameObject:SetActive(true);
        else

            self["proPanel" .. i].gameObject:SetActive(false);

        end
    end

    ----------------------------------
    local me = HeroController:GetInstance();
    local heroInfo = me.info;
    local my_lv = heroInfo.level;

    if my_lv >= self.data.req_lev then
        self.req_lv_txt.gameObject:SetActive(false);
    else

        self.req_lv_txt.text = self.data.req_lev .. LanguageMgr.Get("LingYao/LingYaoSetItem/label1");
        self.req_lv_txt.gameObject:SetActive(true);

        for i = 1, 8 do
            self["proPanelCtr" .. i]:SetData(nil);
            self["proPanelCtr" .. i]:SetLock(true);
            self["addBg" .. i].gameObject:SetActive(false);
        end

    end


    ------------------------------------------------------------
    local gradeColor = LingYaoSetItem.gradeColor[self.data.grade];

    self.label.gradientBottom = gradeColor.gradientBottom;
    self.label.gradientTop = gradeColor.gradientTop;
    self.label.color = gradeColor.color;
    self.label.effectColor = gradeColor.effectColor;


end


function LingYaoSetItem:SetData(data)

    self.data = data;

    self:UpInfos()


end


function LingYaoSetItem:_Dispose()


    for i = 1, 8 do
        self["proPanelCtr" .. i]:Dispose();
        self["proPanelCtr" .. i] = nil;
         self["addBg" .. i] =  nil;
    end

    self.gameObject = nil;

   

    self.label =  nil;
    self.req_lv_txt =  nil;

  


end