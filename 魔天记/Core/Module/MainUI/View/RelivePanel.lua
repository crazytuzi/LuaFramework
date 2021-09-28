require "Core.Module.Common.Panel"

RelivePanel = class("RelivePanel", Panel);
local notice1 = LanguageMgr.Get("RelivePanel/reliveNotice1")
local notice2 = LanguageMgr.Get("RelivePanel/reliveNotice2")
local notice3 = LanguageMgr.Get("RelivePanel/reliveNotice3")

function RelivePanel:IsPopup()
    return false
end

function RelivePanel:New()
    self = { };
    setmetatable(self, { __index = RelivePanel });
    return self
end


function RelivePanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function RelivePanel:_InitReference()
    local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
    self._txtKillBy = UIUtil.GetChildInComponents(txts, "txtKillBy");
    self._txtSelectTime = UIUtil.GetChildInComponents(txts, "txtSelectTime");
    self._txtFreeTime = UIUtil.GetChildInComponents(txts, "txtFreeTime");
    self._txtCost = UIUtil.GetChildInComponents(txts, "txtCostCount");
    self._btnReliveInPlace = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnReliveInPlace");
    self._btnReliveInCity = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnReliveInCity");
    self._trsfree = UIUtil.GetChildByName(self._trsContent, "Transform", "trsfree");
    self._trsCost = UIUtil.GetChildByName(self._trsContent, "Transform", "trsCost");
    self._imgCost = UIUtil.GetChildByName(self._trsCost, "UISprite", "imgIcon")
    --    self._time = PlayerManager.RELIVETIMELIMIT
    self._timer = Timer.New( function() RelivePanel._OnTimerHandler(self) end, 1, -1, false);

end

function RelivePanel:_InitListener()
    self._onClickBtnReliveInPlace = function(go) self:_OnClickBtnReliveInPlace(self) end
    UIUtil.GetComponent(self._btnReliveInPlace, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnReliveInPlace);
    self._onClickBtnReliveInCity = function(go) self:_OnClickBtnReliveInCity(self) end
    UIUtil.GetComponent(self._btnReliveInCity, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnReliveInCity);
end

function RelivePanel:_OnClickBtnReliveInPlace()
    MainUIProxy.SendRelive(1)
end

function RelivePanel:_OnClickBtnReliveInCity()
    MainUIProxy.SendRelive(0)
end

function RelivePanel:_Dispose()
    if (self._timer) then
        self._timer:Stop()
        self._timer = nil
    end
    self:_DisposeListener();
    self:_DisposeReference();

end

function RelivePanel:_DisposeListener()
    UIUtil.GetComponent(self._btnReliveInPlace, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnReliveInPlace = nil;
    UIUtil.GetComponent(self._btnReliveInCity, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnReliveInCity = nil;
end

function RelivePanel:_DisposeReference()
    self._btnReliveInPlace = nil;
    self._btnReliveInCity = nil;
    self._imgCost = nil
end

local colorCode = "[9cff94]"
function RelivePanel:UpdateRelivePanel(data, config)

    self._time = config.time
    if (data) then
        self._txtSelectTime.text = string.format(notice1, self._time)
        -- 免费次数用完
        if (data.ts == config.free_num) then
            self._trsfree.gameObject:SetActive(false)
            self._trsCost.gameObject:SetActive(true)

            if (BackpackDataManager.GetProductTotalNumBySpid(config.relive_item) > 0) then
                self._txtCost.text = "*1"
                local item = ProductManager.GetProductById(config.relive_item)
                if (item) then
                    ProductManager.SetIconSprite(self._imgCost, item.icon_id)
                end
            else
                self._txtCost.text = "*" .. config.cost
                ProductManager.SetIconSprite(self._imgCost, SpecialProductId.BGold)
                --            else
                --                self._txtCost.text = "*" .. config.cost
                --                ProductManager.SetIconSprite(self._imgCost, SpecialProductId.Gold)
            end
        else
            self._trsfree.gameObject:SetActive(true)
            self._trsCost.gameObject:SetActive(false)
            self._txtFreeTime.text = string.format("%s/%s", config.free_num - data.ts, config.free_num)
            self._txtFreeTime.color = ColorDataManager.Get_green()
        end

        if (data.kn ~= nil) then
            if (data.kn ~= "") then
                self._txtKillBy.text = string.format(notice2, colorCode..data.kn.."[-]")
            else
                self._txtKillBy.text = notice3                
            end
        else
            self._txtKillBy.text = ""
        end
    end
    self._timer:Stop()
    self._timer:Start();

end

function RelivePanel:_OnTimerHandler()
    self._time = self._time - 1
    self._txtSelectTime.text = string.format(notice1, self._time)
    if (self._time == 0) then
        self._timer:Stop()
        self:_OnClickBtnReliveInCity()
    end
end