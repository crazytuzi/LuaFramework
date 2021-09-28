require "Core.Module.Common.UIItem"


FBMLTItem = class("FBMLTItem", UIItem);
FBMLTItem.hasPassMaxFb_id = 0;
FBMLTItem.curr_can_play_fb = nil;

function FBMLTItem:New()
    self = { };
    setmetatable(self, { __index = FBMLTItem });
    return self
end
 

function FBMLTItem:UpdateItem(data)
    self.data = data
end

function FBMLTItem:Init(gameObject, data)

    self.gameObject = gameObject;
    self.pointFat = UIUtil.GetChildByName(self.gameObject, "Transform", "pointFat");

    self.select1 = UIUtil.GetChildByName(self.gameObject, "Transform", "select1");
    self.select2 = UIUtil.GetChildByName(self.gameObject, "Transform", "select2");

    self.lp = UIUtil.GetChildByName(self.gameObject, "Transform", "lp");
    self.rp = UIUtil.GetChildByName(self.gameObject, "Transform", "rp");

    self.lp_icon = UIUtil.GetChildByName(self.lp, "UISprite", "icon");
    self.lp_lvtip = UIUtil.GetChildByName(self.lp, "UILabel", "lvtip");
    self.lp_cengLabel = UIUtil.GetChildByName(self.lp, "UILabel", "cengLabel");

    self.rp_icon = UIUtil.GetChildByName(self.rp, "UISprite", "icon");
    self.rp_lvtip = UIUtil.GetChildByName(self.rp, "UILabel", "lvtip");
    self.rp_cengLabel = UIUtil.GetChildByName(self.rp, "UILabel", "cengLabel");

    self.pointFat = UIUtil.GetChildByName(self.gameObject, "Transform", "pointFat");


    self:SetData(data);

    -- InstanceDataManager.UpData(returnHandler, handTarget);
end

function FBMLTItem:UpDrawCallByYY(minY, maxY)

    local cy = self.pointFat.position.y;

    if cy > minY and cy < maxY then




        self.lp_lvtip.gameObject:SetActive(true);
        self.lp_cengLabel.gameObject:SetActive(true);


        self.rp_lvtip.gameObject:SetActive(true);
        self.rp_cengLabel.gameObject:SetActive(true);
    else

        self.lp_lvtip.gameObject:SetActive(false);
        self.lp_cengLabel.gameObject:SetActive(false);


        self.rp_lvtip.gameObject:SetActive(false);
        self.rp_cengLabel.gameObject:SetActive(false);
    end

end

function FBMLTItem:SetActive(v)
    self.gameObject.gameObject:SetActive(v);
end



function FBMLTItem:SetData(data)

    self.data = data;

    local me = HeroController:GetInstance();
    local heroInfo = me.info;
    local my_lv = heroInfo.level;

    self.canPlay = true;

    local cheng = data.cheng;
    self.ys = cheng % 2;
    if self.ys == 1 then
        self.lp.gameObject:SetActive(true);
        self.rp.gameObject:SetActive(false);

        if my_lv < self.data.level then
            if self.data.needShowLvTip then
                self.lp_lvtip.text = LanguageMgr.Get("XLTInstance/FBMLTItem/label1", { n = self.data.level });
            else
                self.lp_lvtip.text = "";
            end

            self.canPlay = false;
        else
            self.lp_lvtip.text = "";
        end

        self.icon = self.lp_icon;

        self.lp_cengLabel.text = LanguageMgr.Get("XLTInstance/FBMLTItem/label2", { n = cheng }) .. self.data.monster_display;
    else
        self.lp.gameObject:SetActive(false);
        self.rp.gameObject:SetActive(true);

        if my_lv < self.data.level then
            if self.data.needShowLvTip then
                self.rp_lvtip.text = LanguageMgr.Get("XLTInstance/FBMLTItem/label1", { n = self.data.level });
            else
                self.rp_lvtip.text = "";
            end

            self.canPlay = false;
        else
            self.rp_lvtip.text = "";
        end

        self.icon = self.rp_icon;
        self.rp_cengLabel.text = LanguageMgr.Get("XLTInstance/FBMLTItem/label2", { n = cheng }) .. self.data.monster_display;
    end


end

-- 已经通过的  ceng hasPass_cheng
--[[
 S <-- 15:52:29.843, 0x0F01, 16, {"instReds":[{"instId":"756000","rt":0,"s":1,"t":1,"sn":0,"fr":0,"ut":12132}]}
]]
function FBMLTItem:UpHassPass(hasPass, baseFb_id)


    if hasPass == nil then
        if self.data.id == baseFb_id then
            -- 第一层， 可以开启
            if self.canPlay then
                self.icon.spriteName = "target";
                self.select1.gameObject:SetActive(true);
                self.select2.gameObject:SetActive(true);
                UIUtil.AdjustHeight(self.icon, 32)
            end
            FBMLTItem.curr_can_play_fb = self;
           
        end

    else
        local pass_fb_id =(hasPass.s + baseFb_id - 1);
        FBMLTItem.hasPassMaxFb_id = pass_fb_id;

        local cu_id = self.data.id + 0;
        -- log("---pass_fb_id "..pass_fb_id.." my id "..self.data.id);

        if pass_fb_id >= cu_id then
            -- 已经通关了
            self.hideIcon = true;
--            local mp = RealmManager.GetMagicOrComPact(self.data.cheng)
--            if mp == 0 then
                self.icon.gameObject:SetActive(false);
--            else
--                self.icon.gameObject:SetActive(true);
--                self.icon.spriteName = mp == 1 and "magicIcon" or "realmIcon"
--                UIUtil.AdjustHeight(self.icon, 50)
--            end
            --Warning(self.data.cheng .."___"..self.icon.spriteName)
        else

            -- 需要判断是否可以开启
            if (pass_fb_id + 1) == cu_id then
                -- 刚好是 通关的下一层
                -- 而且 条件符合的
                if self.canPlay then
                    self.icon.spriteName = "target";
                    UIUtil.AdjustHeight(self.icon, 32)
                    self.select1.gameObject:SetActive(true);
                    self.select2.gameObject:SetActive(true);
                end

                FBMLTItem.curr_can_play_fb = self;

            end

        end

    end

end

function FBMLTItem:_Dispose()
    self.gameObject = nil;


    self.pointFat = nil;

    self.select1 = nil;
    self.select2 = nil;

    self.lp = nil;
    self.rp = nil;

    self.lp_icon = nil;
    self.lp_lvtip = nil;
    self.lp_cengLabel = nil;

    self.rp_icon = nil;
    self.rp_lvtip = nil;
    self.rp_cengLabel = nil;

    self.pointFat = nil;

end