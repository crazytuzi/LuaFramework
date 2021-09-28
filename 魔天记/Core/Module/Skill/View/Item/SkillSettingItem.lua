require "Core.Module.Common.UIItem"

SkillSettingItem = UIItem:New();

function SkillSettingItem:_Init()
    self._bg = UIUtil.GetChildByName(self.transform, "UISprite", "bg");
    self._ico = UIUtil.GetChildByName(self.transform, "UISprite", "icon");
    self._ico_lock = UIUtil.GetChildByName(self.transform, "UISprite", "ico_lock");
    self._ico_select = UIUtil.GetChildByName(self.transform, "UISprite", "ico_select");
    --self._txtLevel = UIUtil.GetChildByName(self.transform, "UILabel", "txtLevel");

    self:SetSelect(false);

    self._icoSlotlock = UIUtil.GetChildByName(self.transform, "UISprite", "icoSlotlock");

    if self._icoSlotlock then
        self._icoSlotlock.alpha = 0;
    end

    self._onClick = function(go) self:_OnClick(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClick);

    local listeners = UIUtil.GetComponentsInChildren(self.transform, "UIDragDropListener");
    if listeners and listeners.Length > 0 then
        self._listener = listeners[0];
        --self._onDrop = System.Action_UnityEngine_GameObject(function(go) self:_OnDrop(go) end);
        self._onDragStart = function(go) self:_OnDragStart(go) end;
        self._onDragDrop = function(go) self:_OnDragDrop(go) end;

        self._listener.onDragStart = self._onDragStart;
        self._listener.onDragDrop = self._onDragDrop;
    end

    self:UpdateItem(self.data);
end

function SkillSettingItem:UpdateItem(data)
    self.data = data;
    
    local heroInfo = PlayerManager.GetPlayerInfo();

    if self.data then
        local skill = self.data;        
        if (skill) then
            local refSkill = SkillManager.RefSkillId(skill.id);
            if (refSkill ~= skill.id) then
                skill = heroInfo:GetSkill(refSkill)
            end
        end
        self.skill = skill;
        --设置的锁定显示跟SkillItem不一样
        if self._ico_lock then
            if data.skill_lv == 1 and skill.req_lv > heroInfo.level then
            	self._listener.enabled = false;
                self._ico_lock.gameObject:SetActive(true); 
            else
            	self._listener.enabled = true;
                self._ico_lock.gameObject:SetActive(false);
            end
        end
        --[[
        if self._txtLevel then
            self._txtLevel.text = LanguageMgr.Get("skill/itemDesc", {name = data.name, lv = data.skill_lv});
        end
        ]]
        self._ico.spriteName = skill.icon_id;
    else
        --self._ico.atlas = nil;
        self._ico.spriteName = "";
        if self._ico_lock then
        	self._listener.enabled = false;
            self._ico_lock.gameObject:SetActive(false);
        end
        --[[
        if self._txtLevel then
            self._txtLevel.text = "";
        end
        ]]
    end

    if self._icoSlotlock and self.index then
        local careerCfg = ConfigManager.GetCareerByKind(heroInfo.kind);
        local defSkillReqLv = careerCfg.skillslot_open;
        local b = heroInfo.level < defSkillReqLv[self.index];
        self._icoSlotlock.alpha = b and 1 or 0;
        self._listener.enabled = not b;
    end
end

function SkillSettingItem:SetSelect(v)
    if self._ico_select then
        self._ico_select.gameObject:SetActive(v);
    end
end

function SkillSettingItem:_Dispose()
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClick = nil;
    self._ico = nil;
    self._ico_lock = nil;
    self._ico_select = nil;    
    --self._txtLevel = nil;
    if self._listener then
        self._listener.onDragStart:Destroy();
        self._listener.onDragDrop:Destroy();
        self._onDragStart = nil;
        self._onDragDrop = nil;
    end
    
end

function SkillSettingItem:RegClickItem(func)
    self._onClickFunc = func;
end

function SkillSettingItem:_OnClick()
    if self._onClickFunc then
        self._onClickFunc(self.index);
    else
        MessageManager.Dispatch(SkillNotes, SkillNotes.EVENT_ITEMCLICK, self.skill);
    end
end

function SkillSettingItem:_OnDragStart(go)
	MessageManager.Dispatch(SkillNotes, SkillNotes.EVENT_ITEM_DRAGSTART, self, go);
end

function SkillSettingItem:_OnDragDrop(go)
	MessageManager.Dispatch(SkillNotes, SkillNotes.EVENT_ITEM_DRAGDROP, self, go);    
end

function SkillSettingItem:PlayUnlockEff()
    local effect = self.transform:Find("ui_skill_unlock");
    if effect == nil then
        effect = UIUtil.GetUIEffect("ui_skill_unlock", self.transform, self._bg, 10);
    else
        effect.gameObject:SetActive(false);
        effect.gameObject:SetActive(true);
    end
end