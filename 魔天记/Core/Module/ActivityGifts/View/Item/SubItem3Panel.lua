require "Core.Module.Common.UIComponent"
local MallChargeItem = require "Core.Module.Mall.View.Item.MallChargeItem"

SubItem3Panel = class("SubItem3Panel", UIComponent);
function SubItem3Panel:New(trs)
    self = { };
    setmetatable(self, { __index = SubItem3Panel });
    if (trs) then self:Init(trs) end
    return self
end

-- 仙玉

function SubItem3Panel:_Init()
    self:_InitReference();
    self:_InitListener();
    self._configs = ConfigManager.Clone(VIPManager.GetChargeConfigs(ChargeType.normal))
    -- 策划说 type==1 不要 http://192.168.0.8:3000/issues/10211
 --   local config1 = ConfigManager.Clone(VIPManager.GetChargeConfigs(ChargeType.month))
 --   if (config1 ~= nil) then
  --      table.AddRange(self._configs, config1)
  --  end
    local config5 = ConfigManager.Clone(VIPManager.GetChargeConfigs(ChargeType.gack))
    if (config5 ~= nil) then
        -- local n = ActivityGiftsDataManager.GetBuyNum(self.config.id)
        -- if config5.count > n then
        table.AddRange(self._configs, config5)
        -- end
    end
    self._configs = ConfigManager.SortForField(self._configs, 'order')
end

function SubItem3Panel:_InitReference()
    self._scrollviewParent = UIUtil.GetChildByName(self._gameObject, "scrollview")
    self._trschargeItem = UIUtil.GetChildByName(self._gameObject, "Transform", "scrollview/trschargeItem");



    self._trschargeItemGo = self._trschargeItem.gameObject;

    MessageManager.AddListener(VIPManager, VIPManager.MESSAGE_RCHARGE_CHANGE, SubItem3Panel._ChargeChange, self)

end


function SubItem3Panel:_ChargeChange()

    self:_InitData(self.sid);
end

local insert = table.insert

function SubItem3Panel:_InitData(sid)
    self.sid = sid;
    if self.inited then
        for k, v in ipairs(self.items) do
            local id = self._configs[k].id
            v:UpdateData(self._configs[k],
            VIPManager.GetChargeFirst(id), VIPManager.GetChargeRecommend(id))
            v:Select(id == sid)
        end
    else
        self.inited = true
        self.items = { }
        local offsetxy = self._trschargeItem.localPosition
        --        local configs = ConfigManager.Clone(VIPManager.GetChargeConfigs(1))
        --        local config1 = ConfigManager.Clone(VIPManager.GetChargeConfigs(0))
        --        if (config1 ~= nil) then
        --            table.AddRange(configs, config1)
        --        end
        for i, c in ipairs(self._configs) do
            local go = Resourcer.Clone(self._trschargeItemGo, self._scrollviewParent)
            local trs = go.transform
            Util.SetLocalPos(trs, offsetxy.x +(((i - 1) % 3) * 364), offsetxy.y -(math.floor((i - 1) / 3) * 250), 0)
            local item = MallChargeItem:New(trs)
            item:InitData(c, VIPManager.GetChargeFirst(c.id), VIPManager.GetChargeRecommend(c.id))
            insert(self.items, item)
            item:Select(c.id == sid)
        end
        self._trschargeItemGo:SetActive(false)
    end

end
function SubItem3Panel:UpdatePanel(v)
    self:_InitData(v)
end

function SubItem3Panel:_InitListener()




end

function SubItem3Panel:_Dispose()
    if self.items then for i, c in ipairs(self.items) do c:Dispose() end end
    self:_DisposeReference();
end

function SubItem3Panel:_DisposeReference()

    MessageManager.RemoveListener(VIPManager, VIPManager.MESSAGE_RCHARGE_CHANGE, SubItem3Panel._ChargeChange)

    self._txtTop = nil;
    self._txtMiddle = nil;
    self._txtBottom = nil;
    self._imgIcon = nil;
    self._trschargeItem = nil;
    self._trsFlg = nil;
end
