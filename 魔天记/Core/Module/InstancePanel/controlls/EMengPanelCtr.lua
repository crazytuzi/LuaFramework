require "Core.Module.InstancePanel.View.items.InstanceFbItem"
require "Core.Manager.Item.InstanceDataManager"

EMengPanelCtr = class("EMengPanelCtr");

function EMengPanelCtr:New()
    self = { };
    setmetatable(self, { __index = EMengPanelCtr });
    return self
end


function EMengPanelCtr:Init(gameObject)
    self.gameObject = gameObject;

    self.fatPoint = UIUtil.GetChildByName(self.gameObject, "Transform", "fatPoint");

    self.subPanel = UIUtil.GetChildByName(self.gameObject, "Transform", "subPanel");
    self.subPanelSc = UIUtil.GetChildByName(self.gameObject, "UIScrollView", "subPanel");
    self.mScrollBar = UIUtil.GetChildByName(self.gameObject, "UIScrollBar", "mScrollBar");

    self._phalanx = UIUtil.GetChildByName(self.subPanel, "LuaAsynPhalanx", "Table");
    self._table = UIUtil.GetChildByName(self.subPanel, "Transform", "Table");
    self._tableL = UIUtil.GetChildByName(self.subPanel, "UITable", "Table");

    self.hasInit = false;
     self.pag_phalanx = Phalanx:New();
    self.pag_phalanx:Init(self._phalanx, InstanceFbItem)


end

function EMengPanelCtr:CheckInit()

    if not self.hasInit then
        self:InitData();
        self.subPanelSc.gameObject:SetActive(false);
        FixedUpdateBeat:Add(self.UpTime, self)

        self.ttime = 1;
        self.hasInit = true;
        self:UpInfos();
    end
end

function EMengPanelCtr:UpTime()

    self.tbale_x = self._table.localPosition.x;
    self.tbale_y = self._table.localPosition.y;

    if self.ttime > 0 then
        self.ttime = self.ttime - 1;
        if self.ttime == 0 then
            self.subPanelSc.gameObject:SetActive(true);
            self:UpScLayer()
            FixedUpdateBeat:Remove(self.UpTime, self);
        end
    end

end

function EMengPanelCtr:InitData()
    self._productPanels = { };

    local data = InstanceDataManager.GetListByKeys(InstanceDataManager.InstanceType.MainInstance, InstanceDataManager.kind_3);
    local t_num = table.getn(data);

   
    self.pag_phalanx:Build(1, t_num, data);

    local _items = self.pag_phalanx._items;

    for i = 1, t_num do
        local obj = _items[i].itemLogic;
        obj:SetParent(self, i);

        if i < t_num then
            obj.nextTarget = _items[i + 1].itemLogic
        end
    end

    if t_num <= 6 then
        self.subPanelSc:SetDragAmount(0, 0, false);
    end

end

function EMengPanelCtr:UpInfos()

    if self.pag_phalanx ~= nil then
        local _items = self.pag_phalanx._items;

        for key, value in pairs(_items) do
            value.itemLogic:UpData();
        end
    end

end


function EMengPanelCtr:UpScLayer()

    self.mScrollBar.value=0;
    local _items = self.pag_phalanx._items;
    local t_num = table.getn(_items);
    for i = 1, t_num do
        local obj = _items[i].itemLogic;

        if i > 6 then
            if obj.newOpen then
                local tn = i - 6;

                local tm = t_num - i;

                if tm <= 4 then
                    Util.SetLocalPos(self._table, self.tbale_x - tn * 200, self.tbale_y, 0)

                else
                    Util.SetLocalPos(self._table, self.tbale_x - tn * 140, self.tbale_y, 0)
                end



                --                self._table.localPosition = Vector3.New(self.tbale_x - tn * 140, self.tbale_y, 0);
                return;
            end
        end
    end

end


-- 这里需要检测 展开的时候， 展开内容是否不完全在可视界面中
-- 如果不完全在可视界面中的时候， 那么就需要进行适应处理
function EMengPanelCtr:SetCurrItemSelected(v)

    FixedUpdateBeat:Remove(self.CheckZKLayer, self);
    self.currSelected = v;

    self.needUpScrollBarTo = false;
    self.checkZKLayerTime = 20;
    FixedUpdateBeat:Add(self.CheckZKLayer, self)

end

function EMengPanelCtr:CheckZKLayer()

    self.checkZKLayerTime = self.checkZKLayerTime - 1;

    if self.currSelected ~= nil then
        local obj = self.currSelected.nextTarget;

        local x = self.currSelected:GetRX();
        if obj ~= nil then
            x = obj:GetX();
        end

        -- 下一个对象的标记全局坐标
        local p_x = self.fatPoint.position.x;
        -- 当前比较的全局坐标

        if x >= p_x then
            local tx = self._table.localPosition.x;
            local ty = self._table.localPosition.y;
            Util.SetLocalPos(self._table, tx - 40.0, ty, 0)

            --            self._table.localPosition = Vector3.New(tx - 40.0, ty, 0);
        end


    end

    if self.checkZKLayerTime == 0 then
        FixedUpdateBeat:Remove(self.CheckZKLayer, self);
    end

end

function EMengPanelCtr:Show()

    self:CheckInit();
    -- self.gameObject.gameObject:SetActive(true);
    -- self.gameObject.gameObject:SetActive(false);
    SetUIEnable(self.gameObject, false);

    self.snum = 5;
    UpdateBeat:Add(self.UpdateLayer, self)

    -- 强制刷新
    self._tableL:Reposition();

end

function EMengPanelCtr:UpdateLayer()

    SetUIEnable(self.gameObject, true);
    -- self.gameObject.gameObject:SetActive(true);

    local _items = self.pag_phalanx._items;
    local t_num = table.getn(_items);



    if t_num <= 7 then
        self.subPanelSc:SetDragAmount(0, 0, false);

    else
        -- 如果第一个还没解锁， 也要 靠左

        local obj = _items[1].itemLogic;
        if obj.lock then
            self.subPanelSc:SetDragAmount(0, 0, false);
        end

    end

    self.snum = self.snum - 1;

    if self.snum == 0 then
        UpdateBeat:Remove(self.UpdateLayer, self)

        self:Check_currInFbData();

    end

    -- 强制刷新
    self._tableL:Reposition();
end

function EMengPanelCtr:Check_currInFbData()

   if InstanceFbItem.currInFbData ~= nil then

     local _items = self.pag_phalanx._items;
      local t_num = table.getn(_items);
    for i = 1, t_num do
        local obj = _items[i].itemLogic;
        obj:Check_currInFbData();
    end
   end

end

function EMengPanelCtr:Hide()

    SetUIEnable(self.gameObject, false);
    -- self.gameObject.gameObject:SetActive(false);
end

function EMengPanelCtr:Dispose()


   FixedUpdateBeat:Remove(self.CheckZKLayer, self);
    if self.pag_phalanx ~= nil then
        self.pag_phalanx:Dispose()
        self.pag_phalanx = nil;
    end


    self.gameObject = nil;

    self.fatPoint = nil;

    self.subPanel = nil;
    self.subPanelSc = nil;
    self.mScrollBar = nil;

    self._phalanx = nil;
    self._table = nil;
    self._tableL = nil;



end