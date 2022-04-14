-- 
-- @Author: LaoY
-- @Date:   2018-08-02 11:14:56
-- 
AdvanceDungeonItem = AdvanceDungeonItem or class("AdvanceDungeonItem", BaseWidget)

--AdvanceDungeonItem.__cache_count = 30

function AdvanceDungeonItem:ctor()
    self.abName = "system"
    self.assetName = "AdvanceDungeonItem"
    self.parent_node = LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.SceneText)
    self.builtin_layer = LayerManager.BuiltinLayer.Default

    self.position = { x = 0, y = 0, z = 0 }
    self.events = {}

    BaseWidget.Load(self)
end

function AdvanceDungeonItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    self.events = {}


end

-- function AdvanceDungeonItem:__reset(...)
--     AdvanceDungeonItem.super.__reset(self,...);

-- end

function AdvanceDungeonItem:LoadCallBack()
    self.nodes = {
        "def", "des", "des/des_text", "lock", "slience",
    }
    self:GetChildren(self.nodes)

    self:InitUI();
    self:AddEvent();
end

function AdvanceDungeonItem:InitUI()
    self.def = GetImage(self.def);
    --self.des = GetText(self.des);
    self.des_text = GetText(self.des_text);
    self.lock = GetImage(self.lock);
    self.slience = GetImage(self.slience);

    self:ShowSlience(false);
    self:ShowDef(false);
    self:ShowDes(false);
    self:ShowLock(false);
end

function AdvanceDungeonItem:AddEvent()
    --self.events[#self.events + 1] = GlobalEvent:AddListener(EventName.ChangeSceneEnd, handler(self, self.HandleSceneChange));
end

function AdvanceDungeonItem:ShowDef(bool)
    bool = toBool(bool);
    SetGameObjectActive(self.def.gameObject, bool)
end

function AdvanceDungeonItem:ShowDes(bool, text)
    bool = toBool(bool);
    SetGameObjectActive(self.des.gameObject, bool)
    self.des_text.text = text or "";
end

function AdvanceDungeonItem:ShowLock(bool)
    bool = toBool(bool);
    SetGameObjectActive(self.lock.gameObject, bool)
end

function AdvanceDungeonItem:ShowSlience(bool)
    bool = toBool(bool);
    SetGameObjectActive(self.slience.gameObject, bool)
end

function AdvanceDungeonItem:SetColor(color)
    if color then
        SetColor(self.des_text, color.r, color.g, color.b, color.a)
    end
end

function AdvanceDungeonItem:UpdateNamePos()
    --local name_width = self.name_text.preferredWidth
    --local job_title_width = self.job_title_text.preferredWidth
    --local total_width = name_width + job_title_width
    --local name_x = job_title_width * 0.5
    --local job_title_x = -name_width * 0.5
    --SetLocalPositionX(self.name, name_x)
    --SetLocalPositionX(self.job_title, job_title_x)
end

function AdvanceDungeonItem:SetGlobalPosition(x, y, z)
    self.position = { x = x, y = y, z = z }
    SetGlobalPosition(self.transform, x, y, z)
end

function AdvanceDungeonItem:UpdateLockPos(y)
    SetLocalPosition(self.lock.transform, 0, y, 0);
end