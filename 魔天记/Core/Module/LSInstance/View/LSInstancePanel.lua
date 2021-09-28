require "Core.Module.Common.Panel"

require "Core.Module.LSInstance.View.item.LSInstanceFbItem"
require "Core.Module.LSInstance.controll.LSBottomPanelCtr"

LSInstancePanel = class("LSInstancePanel", Panel);
function LSInstancePanel:New()
    self = { };
    setmetatable(self, { __index = LSInstancePanel });
    return self
end


function LSInstancePanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function LSInstancePanel:_InitReference()
    local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
    self._btn_close = UIUtil.GetChildInComponents(btns, "btn_close");
    self.btn_addTime = UIUtil.GetChildInComponents(btns, "btn_addTime");

    self.mainView = UIUtil.GetChildByName(self._trsContent, "Transform", "mainView");
    self.listPanel = UIUtil.GetChildByName(self.mainView, "Transform", "listPanel");
    self.bottomPanel = UIUtil.GetChildByName(self.mainView, "Transform", "bottomPanel");
    self.bottomPanelCtr = LSBottomPanelCtr:New();
    self.bottomPanelCtr:Init(self.bottomPanel)
    self.imgSingle = UIUtil.GetChildByName(self.mainView, "UITexture", "imgSingle")
    self.imgSingle.gameObject:SetActive(false)
    self.listPanel.gameObject:SetActive(false)

    self.titleTxt = UIUtil.GetChildByName(self.bottomPanel, "UILabel", "titleTxt");

    self.subPanel = UIUtil.GetChildByName(self.listPanel, "Transform", "subPanel");

    self._table = UIUtil.GetChildByName(self.subPanel, "Transform", "table");

    self._tablephalanx = UIUtil.GetChildByName(self.subPanel, "LuaAsynPhalanx", "table");

end

function LSInstancePanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);

    self._onClickBtn_addTime = function(go) self:_OnClickBtn_addTime(self) end
    UIUtil.GetComponent(self.btn_addTime, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_addTime);

end

function LSInstancePanel:_OnClickBtn_addTime()


    local canBuyNum = self.bottomPanelCtr.canBuyNum;
    if canBuyNum then

        local pro_id = InstanceDataManager.shiyongQuan[self.ins_type];
        InstanceDataManager.TryBuyTineConfirm(pro_id, self.fb_id)
    else
        -- 您当前可购买的副本挑战次数已满，提升VIP可以获取更多的购买次数。
        MsgUtils.ShowTips("LSInstance/LSInstancePanel/label2");

    end

end

function LSInstancePanel:InitFbList(parm)

    self._productPanels = { };



    local data = { };


    if parm.interface_id == ActivityDataManager.interface_id_27 then
        data = TeamMatchDataManager.GetList(TeamMatchDataManager.type_3);
    elseif parm.interface_id == ActivityDataManager.interface_id_28 then
        data = TeamMatchDataManager.GetList(TeamMatchDataManager.type_2);
    elseif parm.interface_id == ActivityDataManager.interface_id_29 then
        data = TeamMatchDataManager.GetList(TeamMatchDataManager.type_4);
    elseif parm.interface_id == ActivityDataManager.interface_id_30 then
        data = TeamMatchDataManager.GetList(TeamMatchDataManager.type_13);
    elseif parm.interface_id == ActivityDataManager.interface_id_18 then
        data = TeamMatchDataManager.GetList(TeamMatchDataManager.type_12);
    elseif parm.interface_id == ActivityDataManager.interface_id_14 then
        data = TeamMatchDataManager.GetList(TeamMatchDataManager.type_15);
    end

    self.ins_type = parm.type;

    local t_num = table.getn(data);


    local fb_Tem = InstanceDataManager.GetListByKeys(parm.type, parm.kind);


    self.titleTxt.text = fb_Tem[1].inst_name;
    self.fb_id = fb_Tem[1].id;

    -- 现在用到的是配置表 team_match ，所以需要加上对应的副本信息数据
    for i = 1, t_num do
        local fb_id = data[i].instance_id;
        local fb_cf = InstanceDataManager.GetMapCfById(fb_id);
        data[i].fbData = fb_cf;
    end

    
    if t_num == 1 then
        -- 只有一条数据

        self.imgSingle.gameObject:SetActive(true)
        self._mainTexturePath = "Instance_FBIcons/" .. data[1].icon_id
        self.imgSingle.mainTexture = UIUtil.GetTexture(self._mainTexturePath)

        self:SetCurrItemSelected( { data = data[1] })
        return
    end

    self.listPanel.gameObject:SetActive(true)

    if self._phalanx == nil then
        self._phalanx = Phalanx:New();
    end
    self._phalanx:Init(self._tablephalanx, LSInstanceFbItem)
    self._phalanx:Build(1, t_num, data);

    local _items = self._phalanx._items;

    for i = 1, t_num do
        local obj = _items[i].itemLogic;
        obj:SetParent(self);
    end

    if t_num > 5 then

        -- 需要根据玩家等级进行 定位
        local t_x = self._table.localPosition.x;
        local t_y = self._table.localPosition.y;

        local hasSetSelect = false;

        for i = 1, t_num do
            local obj = _items[i].itemLogic;
            if not obj.canPlay then
                -- 第一个 不能玩的对象
                if i > 4 then
                    Util.SetLocalPos(self._table, t_x - 140 *(i - 4), t_y, 0)

                    --                    self._table.localPosition = Vector3.New(t_x - 140 *(i - 4), t_y, 0);
                end
              
                local objOld = _items[i - 1].itemLogic;
                objOld:_OnClickBtn();
                hasSetSelect = true;

                return;
            end
        end

        Util.SetLocalPos(self._table, t_x - 140 *(t_num - 4), t_y, 0)

        -- 到这一步说明全部都可以玩了
        --        self._table.localPosition = Vector3.New(t_x - 140 *(t_num - 4), t_y, 0);

    end


    if TeamMatchDataManager.currPiPeiIng_data == nil then
        local objOld = _items[1].itemLogic;
        objOld:_OnClickBtn();

    else
        -- 设置默认选中匹配对象
        local hasSelect = false;
        for i = 1, t_num do
            local obj = _items[i].itemLogic;
            local b = obj:CheckPiPeiSelect(TeamMatchDataManager.currPiPeiIng_data);
            if b then
                hasSelect = b;
            end
        end

        if not hasSelect then
            local objOld = _items[1].itemLogic;
            objOld:_OnClickBtn();
        end

    end


end

function LSInstancePanel:SetCurrItemSelected(v)
    self.currSelected = v;
    self.bottomPanelCtr:SetData(v.data);
end

function LSInstancePanel:_OnClickBtn_close()
    SequenceManager.TriggerEvent(SequenceEventType.Guide.PANEL_CLOSEBTN_CLICK, self._name);
    ModuleManager.SendNotification(LSInstanceNotes.CLOSE_LSINSTANCEPANEL);
end


function LSInstancePanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function LSInstancePanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;



    UIUtil.GetComponent(self.btn_addTime, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_addTime = nil;

end

function LSInstancePanel:_DisposeReference()
    self._btn_close = nil;

    if self._phalanx then
        self._phalanx:Dispose()
    end
    self.bottomPanelCtr:Dispose();


    self._btn_close = nil;


    self.mainView = nil;
    self.listPanel = nil;
    self.bottomPanel = nil;
    self.bottomPanelCtr = nil;

    self.titleTxt = nil;

    self.subPanel = nil;

    self._table = nil;

    self._tablephalanx = nil;

    if self._mainTexturePath then
        UIUtil.RecycleTexture(self._mainTexturePath);
        self._mainTexturePath = nil;
    end
end
