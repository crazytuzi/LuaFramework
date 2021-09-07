-- 未命名宝藏 model
-- ljh 20161216
NotNamedTreasureModel = NotNamedTreasureModel or BaseClass(BaseModel)

function NotNamedTreasureModel:__init()
    self.window = nil

    self.gold_times = 0
    self.silver_times = 0

    self.baseid = nil
    self.type = nil
    --------------------------------------
    self.type1_id = 62320
    self.type2_id = 62319

    self.type1_cost = 22248
    self.type2_cost = 22249

    self._FindElementAfterTransport = function()
        self:FindElementAfterTransport()
    end
end

function NotNamedTreasureModel:InitData()
    self.gold_times = 0
    self.silver_times = 0
end

function NotNamedTreasureModel:__delete()
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
    end
end

function NotNamedTreasureModel:OpenWindow(args)
    if self.window == nil then
        self.window = NotNamedTreasureWindow.New(self)
    end
    self.window:Open(args)
end

function NotNamedTreasureModel:CloseWindow()
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
    end
end

function NotNamedTreasureModel:OpenTreasure(id, uint_id)
    if id == self.type1_id then
        if RoleManager.Instance.RoleData.lev < 40 then
            NoticeManager.Instance:FloatTipsByString(TI18N("你的等级不足40级，还不能打开鸿福宝箱"))
        else
         self:OpenWindow({self.type1_id, uint_id})
        end
    elseif id == self.type2_id then
        if RoleManager.Instance.RoleData.lev < 40 then
            NoticeManager.Instance:FloatTipsByString(TI18N("你的等级不足40级，还不能打开秘银宝箱"))
        else
            self:OpenWindow({self.type2_id, uint_id})
        end
    end
end

function NotNamedTreasureModel:UseKey(item_id)
    self.baseid = nil
    self.type = nil
    self.item_id = item_id
    if self.type1_cost == item_id then
        self.type = 1
        self.baseid = self.type1_id
    elseif self.type2_cost == item_id then
        self.type = 2
        self.baseid = self.type2_id
    end

    local map_id = SceneManager.Instance:CurrentMapId()
    if map_id == 10001 or map_id == 10002 or map_id == 10003 or map_id == 10004 or map_id == 10007 then
        self:FindElement()
    else
        local list = { 10001, 10002, 10003, 10004, 10007 }
        local map_id = list[Random.Range(1, #list+1)]
        SceneManager.Instance.sceneElementsModel:Self_Transport(map_id, 0, 0)
        EventMgr.Instance:AddListener(event_name.npc_list_update, self._FindElementAfterTransport)
    end

    NoticeManager.Instance:FloatTipsByString(TI18N("钥匙钥匙，带我去找宝箱吧"))
    BackpackManager.Instance.mainModel:CloseMain()
end

function NotNamedTreasureModel:FindElement()
    local uuid = nil
    local units = SceneManager.Instance.sceneElementsModel:GetSceneData_Npc()
    for k,v in pairs(units) do
        if v.baseid == self.baseid then
            uuid = v.uniqueid
        end
    end
    if uuid ~= nil then
        SceneManager.Instance.sceneElementsModel:Self_MoveToTarget(uuid)
    else
        self:MarkElement(self.item_id)
    end
end

function NotNamedTreasureModel:MarkElement(item_id)
    NotNamedTreasureManager.Instance:Send18203(item_id)
end

function NotNamedTreasureModel:FindElementAfterTransport()
    EventMgr.Instance:RemoveListener(event_name.npc_list_update, self._FindElementAfterTransport)

    self:FindElement()
end