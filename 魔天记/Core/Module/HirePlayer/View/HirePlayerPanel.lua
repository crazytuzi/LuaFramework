require "Core.Module.Common.Panel"
require "Core.Module.HirePlayer.View.Item.HirePlayerListItem"

HirePlayerPanel = class("HirePlayerPanel", Panel);
function HirePlayerPanel:New()
    self = { };
    setmetatable(self, { __index = HirePlayerPanel });
    return self
end

function HirePlayerPanel:_Init()
    self._hireList = { };
    self:_InitReference();
    self:_InitListener();
end


function HirePlayerPanel:_InitReference()
    self._txtDesc = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtDesc");
    self._txtDesc.text = LanguageMgr.Get("HirePlayerPanel/desc");
    --self._txtNum = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtNum");
    self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClose");
    self._btnGo = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnGo");
    self._txtNoPlayer = UIUtil.GetChildByName(self._trsContent, "Transform", "txtNoPlayer").gameObject;
    self._trsList = UIUtil.GetChildByName(self._trsContent, "Transform", "trsList");
    self._scrollView = UIUtil.GetComponent(self._trsList, "UIScrollView");
    self._phalanxInfo = UIUtil.GetChildByName(self._trsList, "LuaAsynPhalanx", "phalanx");
    self._phalanx = Phalanx:New();
    self._phalanx:Init(self._phalanxInfo, HirePlayerListItem);
end

function HirePlayerPanel:_InitListener()
    MessageManager.AddListener(HirePlayerNotes, HirePlayerNotes.EVENT_CLICK_LISTITEM, HirePlayerPanel._OnClickItemHandler, self);

    self._onClickCloseHandler = function(go) self:_OnClickCloseHandler(self) end
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickCloseHandler);

    self._onClickGoHandler = function(go) self:_OnClickGoHandler(self) end
    UIUtil.GetComponent(self._btnGo, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickGoHandler);
end


function HirePlayerPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function HirePlayerPanel:_DisposeListener()
    MessageManager.RemoveListener(HirePlayerNotes, HirePlayerNotes.EVENT_CLICK_LISTITEM, HirePlayerPanel._OnClickItemHandler, self);

    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickCloseHandler = nil;

    UIUtil.GetComponent(self._btnGo, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickGoHandler = nil;
end

function HirePlayerPanel:_DisposeReference()
    self._txtDesc = nil;
    --self._txtNum = nil;
    self._btnClose = nil;
    self._btnGo = nil;
    self._txtNoPlayer = nil;
    self._trsList = nil;
    self._scrollView = nil;
    self._phalanx:Dispose();
    self._phalanx = nil;
end

function HirePlayerPanel:_OnClickItemHandler(item)
    if (item) then
        if (not item:GetSelected()) then
            local teamPlayers = PartData.GetMyTeamNunberNum();
            if (teamPlayers > 0) then
                local hires = table.getCount(self._hireList);
                local count = 4 - teamPlayers
                --if (hires < count and hires < self._num) then
                if (hires < count) then
                    local currCost = self:_GetCurrCost();
                    currCost = currCost + item.data.money;
                    if (currCost <= MoneyDataManager.money) then
                        self._hireList[item.data.pi] = item.data;
                        item:SetSelected(true);
                    else
                        MsgUtils.ShowTips(nil, nil, nil, LanguageMgr.Get("common/lingshibuzu"));
                    end
                else
                    --if (hires >= count) then
                        MsgUtils.ShowTips(nil, nil, nil, LanguageMgr.Get("Friend/PartyPanelControll/tip6"));
--                    else
--                        MsgUtils.ShowTips(nil, nil, nil, LanguageMgr.Get("HirePlayerPanel/tip1"));
                   -- end
                end
            end
        else
            self._hireList[item.data.pi] = nil;
            item:SetSelected(false);
        end
    end
end

function HirePlayerPanel:_GetCurrCost()
    local cost = 0;
    for i, v in pairs(self._hireList) do
        cost = cost + v.money;
    end
    return cost
end

function HirePlayerPanel:_OnClickCloseHandler()
    ModuleManager.SendNotification(HirePlayerNotes.CLOSE_HIREPLAYERPANEL)
end
local insert = table.insert

function HirePlayerPanel:_OnClickGoHandler()    
    if (table.getCount(self._hireList) > 0) then
        local ls = { };
        for i, v in pairs(self._hireList) do
            insert(ls, i);
        end
        HirePlayerProxy.HirePlayer(ls)
    else
        MsgUtils.ShowTips(nil, nil, nil, LanguageMgr.Get("HirePlayerPanel/tip2"));
    end
end

function HirePlayerPanel:SetData(data)
    self._num = data.rc;    
    --self._txtNum.text = LanguageMgr.Get("HirePlayerPanel/num", { n = (data.rc or 0) });
    self._phalanx:Build(3, 2, data.l);
    self._scrollView:ResetPosition();
    self._txtNoPlayer:SetActive(table.getCount(data.l) < 1);
end