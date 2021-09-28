require "Core.Module.LingYao.controll.LingYaoSetPanelCtr"

LingYaoSetControll = class("LingYaoSetControll");

function LingYaoSetControll:New()
    self = { };
    setmetatable(self, { __index = LingYaoSetControll });
    return self
end

function LingYaoSetControll:Init(gameObject)
    self.gameObject = gameObject;

    local btns = UIUtil.GetComponentsInChildren(self.gameObject, "UIButton");

    self._btnTog1 = UIUtil.GetChildInComponents(btns, "btnTog1");
    self._btnTog2 = UIUtil.GetChildInComponents(btns, "btnTog2");
    self._btnTog3 = UIUtil.GetChildInComponents(btns, "btnTog3");
    self._btnTog4 = UIUtil.GetChildInComponents(btns, "btnTog4");

    self._btnTog_npoint1 = UIUtil.GetChildByName(self._btnTog1, "Transform", "npoint");
    self._btnTog_npoint2 = UIUtil.GetChildByName(self._btnTog2, "Transform", "npoint");
    self._btnTog_npoint3 = UIUtil.GetChildByName(self._btnTog3, "Transform", "npoint");
    self._btnTog_npoint4 = UIUtil.GetChildByName(self._btnTog4, "Transform", "npoint");


    self.dy_panels = UIUtil.GetChildByName(self.gameObject, "Transform", "dy_panels");

    self.attvalueTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "attvalueTxt");

    local me = HeroController:GetInstance();
    local heroInfo = me.info;
    local career = heroInfo.kind;

    self.lyList = LingYaoDataManager.GetListByCareer(career);


    for i = 1, 4 do

        self["_btnTogLable" .. i] = UIUtil.GetChildByName(self["_btnTog" .. i], "UILabel", "tltle");
        self["panel" .. i] = UIUtil.GetChildByName(self.dy_panels, "Transform", "panel" .. i);

        local objl = self.lyList[i];

        self["panelCtr" .. i] = LingYaoSetPanelCtr:New();
        self["panelCtr" .. i]:Init(self["panel" .. i], objl, i);

        self["_btnTogLable" .. i].text = objl.list[1].type_name;

    end


    self._onClickBtnTog1 = function(go) self:_OnClickBtnTog1(self) end
    UIUtil.GetComponent(self._btnTog1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnTog1);
    self._onClickBtnTog2 = function(go) self:_OnClickBtnTog2(self) end
    UIUtil.GetComponent(self._btnTog2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnTog2);
    self._onClickBtnTog3 = function(go) self:_OnClickBtnTog3(self) end
    UIUtil.GetComponent(self._btnTog3, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnTog3);
    self._onClickBtnTog4 = function(go) self:_OnClickBtnTog4(self) end
    UIUtil.GetComponent(self._btnTog4, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnTog4);

    self.currShowPantl = self["panelCtr1"];


    self:UpAttTotal(self["panelCtr1"]:GetKind());

    MessageManager.AddListener(LingYaoProxy, LingYaoProxy.MESSAGE_USE_PRO_COMPLETE, LingYaoSetControll.UseProComplete, self);

end

LingYaoSetControll.MESSAGE_LINGYAOSETCONTROLL_NPOINT_CHANGE = "MESSAGE_LINGYAOSETCONTROLL_NPOINT_CHANGE";
LingYaoSetControll.MESSAGE_LINGYAOSETCONTROLL_BT_NPOINT_CHANGE = "MESSAGE_LINGYAOSETCONTROLL_BT_NPOINT_CHANGE";
-- 检测所有 分类是否需要显示提示
function LingYaoSetControll.CheckNPoint()

    local my_info = HeroController:GetInstance().info;
    local my_career = tonumber(my_info:GetCareer());

    local lyList = LingYaoDataManager.GetListByCareer(my_career);

    local res = false;

    for i = 1, 4 do
        local objl = lyList[i];

        local list = objl.list;
        local b = LingYaoSetControll.CheckNPointPart(list, i)
        if b then
            res = true;
        end
    end

   
    MessageManager.Dispatch(LingYaoSetControll, LingYaoSetControll.MESSAGE_LINGYAOSETCONTROLL_BT_NPOINT_CHANGE, { b = res });
   
end



function LingYaoSetControll.CheckNPointPart(list, index)

    local t_num = table.getn(list);
    for i = 1, t_num do
        local data = list[i];
        local use_num = data.use_num;

        local am = LingYaoDataManager.GetHasUseAm(data.id);
        local ower_num = BackpackDataManager.GetProductTotalNumBySpid(data.id);


        for i = 1, 8 do
            if i <= use_num then

                if i <= am then

                else
                    if ower_num > 0 then

                        MessageManager.Dispatch(LingYaoSetControll, LingYaoSetControll.MESSAGE_LINGYAOSETCONTROLL_NPOINT_CHANGE, { index = index, b = true });
                        return true;
                    end
                end
            end
        end

    end

    MessageManager.Dispatch(LingYaoSetControll, LingYaoSetControll.MESSAGE_LINGYAOSETCONTROLL_NPOINT_CHANGE, { index = index, b = false });
    return false;
end

function LingYaoSetControll:UpAttTotal(kind)
    self.curr_kind = kind;
    local obj = LingYaoDataManager.TryGetAttTotal(kind);
    self.attvalueTxt.text = LanguageMgr.Get("attr/" .. obj.att_name) .. " +[9cff94]" .. obj.value .. "[-]";

end

function LingYaoSetControll:_OnClickBtnTog1()

    if self.currShowPantl ~= nil then
        self.currShowPantl:Hide();
    end

    self.currShowPantl = self["panelCtr1"];
    self.currShowPantl:Show()
    self:UpAttTotal(self["panelCtr1"]:GetKind())

end

function LingYaoSetControll:_OnClickBtnTog2()
    if self.currShowPantl ~= nil then
        self.currShowPantl:Hide();
    end

    self.currShowPantl = self["panelCtr2"];
    self.currShowPantl:Show()
    self:UpAttTotal(self["panelCtr2"]:GetKind())
end 

function LingYaoSetControll:_OnClickBtnTog3()
    if self.currShowPantl ~= nil then
        self.currShowPantl:Hide();
    end

    self.currShowPantl = self["panelCtr3"];
    self.currShowPantl:Show()
    self:UpAttTotal(self["panelCtr3"]:GetKind())
end

function LingYaoSetControll:_OnClickBtnTog4()
    if self.currShowPantl ~= nil then
        self.currShowPantl:Hide();
    end

    self.currShowPantl = self["panelCtr4"];
    self.currShowPantl:Show()
    self:UpAttTotal(self["panelCtr4"]:GetKind())
end

function LingYaoSetControll:UseProComplete()

    self:UpAttTotal(self.curr_kind)

end

-- 刷新数据
function LingYaoSetControll:UpInfos()

    for i = 1, 4 do
        self["panelCtr" .. i]:UpInfos()
    end

    -------------------------


end



function LingYaoSetControll:Show()

    self.gameObject.gameObject:SetActive(true);
end

function LingYaoSetControll:Hide()

    self.gameObject.gameObject:SetActive(false);
end

function LingYaoSetControll:Dispose()

    MessageManager.RemoveListener(LingYaoProxy, LingYaoProxy.MESSAGE_USE_PRO_COMPLETE, LingYaoSetControll.UseProComplete);


    UIUtil.GetComponent(self._btnTog1, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnTog1 = nil;
    UIUtil.GetComponent(self._btnTog2, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnTog2 = nil;
    UIUtil.GetComponent(self._btnTog3, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnTog3 = nil;
    UIUtil.GetComponent(self._btnTog4, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnTog4 = nil;

    for i = 1, 4 do
        self["panelCtr" .. i]:Dispose();
        self["panelCtr" .. i] = nil;

        self["_btnTogLable" .. i] = nil;
        self["panel" .. i] = nil;
    end



    self._btnTog1 = nil;
    self._btnTog2 = nil;
    self._btnTog3 = nil;
    self._btnTog4 = nil;

    self.gameObject = nil;


    self.dy_panels = nil;

    self.attvalueTxt = nil;

    self.lyList = nil;

end