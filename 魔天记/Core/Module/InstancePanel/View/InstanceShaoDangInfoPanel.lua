require "Core.Module.Common.Panel"
require "Core.Module.InstancePanel.View.items.SaoDangInfoItem"

InstanceShaoDangInfoPanel = class("InstanceShaoDangInfoPanel", Panel);
function InstanceShaoDangInfoPanel:New()
    self = { };
    setmetatable(self, { __index = InstanceShaoDangInfoPanel });
    return self
end


function InstanceShaoDangInfoPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function InstanceShaoDangInfoPanel:_InitReference()
    self._txt_title = UIUtil.GetChildByName(self._trsContent, "UILabel", "txt_title");
    self._btn_ok = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_ok");

    self.awardsPanel = UIUtil.GetChildByName(self._trsContent, "Transform", "awardsPanel");
    self.subPanel = UIUtil.GetChildByName(self.awardsPanel, "Transform", "subPanel");
    self.subPanelSc = UIUtil.GetChildByName(self.awardsPanel, "UIScrollView", "subPanel");

    self.table = UIUtil.GetChildByName(self.subPanel, "Transform", "table");
    self.mScrollBar = UIUtil.GetChildByName(self.awardsPanel, "UIScrollBar", "mScrollBar");


    self.tablePhalanxObj = UIUtil.GetChildByName(self.subPanel, "LuaAsynPhalanx", "table");
    self.tablePhalanx = Phalanx:New()
    self.tablePhalanx:Init(self.tablePhalanxObj, SaoDangInfoItem)

end

function InstanceShaoDangInfoPanel:_InitListener()
    self._onClickBtn_ok = function(go) self:_OnClickBtn_ok(self) end
    UIUtil.GetComponent(self._btn_ok, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_ok);
end

function InstanceShaoDangInfoPanel:_OnClickBtn_ok()
    ModuleManager.SendNotification(InstancePanelNotes.CLOSE_INSTANCESHAODANGINFOPANEL);
end



--  S <-- 17:29:27.304, 0x0F0B, 14, {"l":[{"items":[{"num":20000,"spId":4},{"num":1000,"spId":1},{"num":1,"spId":301001}],"instId":"750001"}]}
--[[
 最新
  S <-- 17:12:32.120, 0x0F0B, 26, {"l":[{"items":[{"num":1304,"spId":4},{"num":1000,"spId":1},{"num":1,"spId":502050}],"t":1,"instId":"750001"}]}

]]

function InstanceShaoDangInfoPanel:SetData(data)

    self.currShowIndex = 1;



    self.sd_data = data;

    local dataL = self.sd_data.l;
    local t_num = table.getn(dataL);

    self.tablePhalanx:Build(t_num, 1, dataL);
    self.totalShaowNum = t_num;
    self.show_index = 1;

    self.ct_totalH = 115;

    local items = self.tablePhalanx._items;
    for i = 1, t_num do
        local items = self.tablePhalanx._items;
        local obj = items[i].itemLogic;
        obj:SetY(self.ct_totalH);


     --   log("---------------- i "..i.." SetY "..self.ct_totalH.."  obj.ct_h "..obj.ct_h);

        self.ct_totalH = self.ct_totalH + obj.ct_h;
        obj:SetActive(false);

    end


    self.showTime = 30;
    self.currMsV = self.mScrollBar.value;
    self.mspeed =(1 - self.currMsV) / self.showTime;
    self.ct_totalH = 115;

    self._btn_ok.gameObject:SetActive(false);

    local obj = items[self.show_index].itemLogic;
    obj:SetActive(true);
    self.waitFor = -1;
    FixedUpdateBeat:Add(self.UpShowTime, self)
end

function InstanceShaoDangInfoPanel:UpShowTime()

    if self.waitFor > 0 then
        self.waitFor = self.waitFor - 1;
        return;
    end

    if self.showTime > 0 then

        if self.ct_totalH < -100 then

            if self.needGetValue then
                self.currMsV = self.mScrollBar.value;
                self.mspeed =(1 - self.currMsV) / self.showTime;
                self.needGetValue = true;
            end

            self.currMsV = self.currMsV + self.mspeed;

            if self.currMsV >= 1.0 then
                self.currMsV = 1.0;
            end

            self.mScrollBar.value=self.currMsV;

        end

        self.showTime = self.showTime - 1;

        if self.showTime == 0 then
            self.show_index = self.show_index + 1;

            if self.show_index <= self.totalShaowNum then

                local items = self.tablePhalanx._items;
                local obj = items[self.show_index].itemLogic;
                obj:SetActive(true);
                self.ct_totalH = self.ct_totalH + obj.ct_h;

                -- 这个需要自己 计算 才比较 准确
                self.needGetValue = true;

                self.showTime = 10;
                -- 移动速度
                self.waitFor = 15;
                -- 出现时间间隔

            else
                FixedUpdateBeat:Remove(self.UpShowTime, self);
                self._btn_ok.gameObject:SetActive(true);
            end

        end
    end


end



function InstanceShaoDangInfoPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();


    self._txt_title = nil;
    self._btn_ok = nil;

    self.awardsPanel = nil;
    self.subPanel = nil;
    self.subPanelSc = nil;

    self.table = nil;
    self.mScrollBar = nil;


    self.tablePhalanxObj = nil;
    self.tablePhalanx:Dispose();
    self.tablePhalanx = nil;
end

function InstanceShaoDangInfoPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_ok, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_ok = nil;
end

function InstanceShaoDangInfoPanel:_DisposeReference()
    self._btn_ok = nil;
end
