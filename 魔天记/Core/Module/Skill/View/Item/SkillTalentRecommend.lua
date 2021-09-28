require "Core.Module.Skill.View.Item.SkillTalentRecommendItem";

SkillTalentRecommend = class("SkillTalentRecommend");

function SkillTalentRecommend:Init(transform)
    self._transform = transform;
    self:_Init();
end

function SkillTalentRecommend:_Init()
    self._onItemClick = function(go) self:_OnItemClick(go) end

    self._items= {};
    self._itemBtns = {};
    for i = 1, 2 do
        local itemGo = UIUtil.GetChildByName(self._transform, "Transform", "item"..i);
        local item = SkillTalentRecommendItem:New();
        item:Init(itemGo);
        self._items[i] = item;

        local btn = UIUtil.GetChildByName(itemGo, "UIButton", "btnUse");
        self._itemBtns[i] = btn;
        UIUtil.GetComponent(btn, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onItemClick);
    end

    self._btnClose = UIUtil.GetChildByName(self._transform, "UISprite", "btnClose");
    self._onCloseBtnClick = function(go) self:_OnCloseBtnClick() end
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onCloseBtnClick);
end

function SkillTalentRecommend:Dispose()
    for k,v in pairs(self._items) do
        v:Dispose();
        
    end

    for k,v in pairs(self._itemBtns) do
        UIUtil.GetComponent(v, "LuaUIEventListener"):RemoveDelegate("OnClick");
    end
    
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onCloseBtnClick = nil;
    self._onItemClick = nil;
end

function SkillTalentRecommend:Show()
    --self._transform.gameObject:SetActive(true);
    local myinfo = PlayerManager.GetPlayerInfo();
    local cfg = ConfigManager.GetCareerByKind(myinfo.kind);
    self.data = cfg.talent_recommend;

    for i = 1, 2 do
        self._items[i]:UpdateItem(self.data[i]);
    end
    
end

function SkillTalentRecommend:_OnItemClick(go)
    local name = go.transform.parent.name;
    local idx = tonumber(string.sub(name,5));
    self:_OnItemSelect(self.data[idx]);
end

function SkillTalentRecommend:_OnItemSelect(recId)
    MessageManager.Dispatch(SkillNotes, SkillNotes.EVENT_TALENT_REC_SELECT, recId);
end

--[[
function SkillTalentRecommend:Close()
    
end
]]

function SkillTalentRecommend:_OnCloseBtnClick()
    MessageManager.Dispatch(SkillNotes, SkillNotes.EVENT_TALENT_REC_CLOSE);
end

