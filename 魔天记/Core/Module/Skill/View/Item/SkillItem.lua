require "Core.Module.Common.UIItem"

SkillItem = UIItem:New();

function SkillItem:_Init()

    self._ico = UIUtil.GetChildByName(self.transform, "UISprite", "icon");
    self._ico_lock = UIUtil.GetChildByName(self.transform, "UISprite", "ico_lock");
    self._ico_select = UIUtil.GetChildByName(self.transform, "UISprite", "ico_select");
    self._ico_up = UIUtil.GetChildByName(self.transform, "UISprite", "ico_up");

    self._txtLevel = UIUtil.GetChildByName(self.transform, "UILabel", "txtLevel");

    self:SetSelect(false);

    self._onClick = function(go) self:_OnClick(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClick);

    if self._ico_up then
        self._ico_up.alpha = 0;
    end

    self:UpdateItem(self.data);
end

function SkillItem:UpdateItem(data)
    self.data = data;
    self.skill = data
    if self.data then
        local skill = self.data;
        local heroInfo = PlayerManager.GetPlayerInfo();

        if (skill) then
            local refSkill = SkillManager.RefSkillId(skill.id);
            if (refSkill ~= skill.id) then
                skill = heroInfo:GetSkill(refSkill)
                if (skill == nil) then
                    skill = heroInfo:AddSkill(refSkill, self.skill.skill_lv)
                else
                    skill:SetLevel(self.skill.skill_lv);
                end
            end
        end
        
        self.skill = skill

        if self._ico_lock then
            if (heroInfo.level >= skill.req_lv) then
                self._ico_lock.gameObject:SetActive(false);
            else
                self._ico_lock.gameObject:SetActive(true);
            end
        end

        if self._ico_up then
            self._ico_up.alpha =(skill.skill_lv < skill.max_lv and heroInfo.level >= skill.req_lv and MoneyDataManager.Get_money() >= skill.coin_cost) and 1 or 0;
        end

        if self._txtLevel then
            self._txtLevel.text = LanguageMgr.Get("skill/itemDesc", { name = skill.name, lv = skill.skill_lv });
        end

        self._ico.spriteName = skill.icon_id;
    else
        -- self._ico.atlas = nil;
        self._ico.spriteName = "";
        if self._ico_lock then
            self._ico_lock.gameObject:SetActive(false);
        end
        if self._txtLevel then
            self._txtLevel.text = "";
        end
    end
end

function SkillItem:SetSelect(v)
    if self._ico_select then
        self._ico_select.gameObject:SetActive(v);
    end
end

function SkillItem:_Dispose()
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClick = nil;
    self._ico = nil;
    self._ico_lock = nil;
    self._ico_select = nil;
    self._txtLevel = nil;
    --[[
    if self._listener then
        self._listener.onDragStart = nil;
        self._listener.onDragDrop = nil;
        self._onDragStart = nil;
        self._onDragDrop = nil;
    end
    ]]
end

function SkillItem:RegClickItem(func)
    self._onClickFunc = func;
end

function SkillItem:_OnClick()
    if self._onClickFunc then
        self._onClickFunc(self.index);
    else
        MessageManager.Dispatch(SkillNotes, SkillNotes.EVENT_ITEMCLICK, self.skill);
    end
end

--[[
function SkillItem:_OnDragStart(go)
   MessageManager.Dispatch(SkillNotes, SkillNotes.EVENT_ITEM_DRAGSTART, self, go);
end

function SkillItem:_OnDragDrop(go)
    MessageManager.Dispatch(SkillNotes, SkillNotes.EVENT_ITEM_DRAGDROP, self, go);

end
]]