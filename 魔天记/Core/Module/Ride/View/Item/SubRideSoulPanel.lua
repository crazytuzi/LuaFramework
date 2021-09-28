require "Core.Module.Common.UISubPanel";
require "Core.Module.Common.BasePropertyItem"
require "Core.Module.Common.UIEffect"
local RideNextPropertyItem = require "Core.Module.Ride.View.Item.RideNextPropertyItem"
local SubRideSoulPanel = class("SubRideSoulPanel", UISubPanel);
local RideFeedItem = require "Core.Module.Ride.View.Item.RideFeedItem";
local storeConfig = MallManager.GetStoreById(200)
function SubRideSoulPanel:_InitReference()
    self._isShow = false
    self._txtLevel = UIUtil.GetChildByName(self._transform, "UILabel", "txtLevel")
    self._txtExp = UIUtil.GetChildByName(self._transform, "UILabel", "slider_exp/txtExp")
    self._sliderExp = UIUtil.GetChildByName(self._transform, "UISlider", "slider_exp")
    self._curPropertyPhalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "curPropertyPhalanx")
    self._curPropertyPhalanx = Phalanx:New()
    self._curPropertyPhalanx:Init(self._curPropertyPhalanxInfo, BasePropertyItem, true)
    self._nextPropertyPhalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "nextPropertyPhalanx")
    self._nextPropertyPhalanx = Phalanx:New()
    self._nextPropertyPhalanx:Init(self._nextPropertyPhalanxInfo, RideNextPropertyItem)

    self._bagPhalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "scrollview/bagPhalanx")
    self._bagPhalanx = Phalanx:New()
    self._bagPhalanx:Init(self._bagPhalanxInfo, nil, true)
    self._bagPhalanx:Build(4, 5, { })
    self._bagItemPhalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "scrollview/bagitemPhalanx")
    self._bagItemPhalanx = Phalanx:New()
    self._bagItemPhalanx:Init(self._bagItemPhalanxInfo, RideFeedItem)
    self._goNext = UIUtil.GetChildByName(self._transform, "goNext").gameObject
    self._goInstrution = UIUtil.GetChildByName(self._transform, "tsRideInstruction").gameObject
    self._goInstrution:SetActive(false)
    self._goNextLevelDes = UIUtil.GetChildByName(self._transform, "goNextLevelDes").gameObject
    self._btnUpdate = UIUtil.GetChildByName(self._transform, "UIButton", "btnUpdate")
    self._btnUpdateOneKey = UIUtil.GetChildByName(self._transform, "UIButton", "btnUpdateOneKey")
    self._btnInstuction = UIUtil.GetChildByName(self._transform, "UIButton", "btnInstruction")
    self._effectParent = UIUtil.GetChildByName(self._transform, "effectPanel")
    self._bg = UIUtil.GetChildByName(self._transform, "UISprite", "bg")
    self._feedEffect = UIEffect:New()
    self._feedEffect:Init(self._effectParent, self._bg, 0, "ui_yanghun_star")
    self._feedEffect:Play()
    self._updateLevelEffect = UIEffect:New()
    self._updateLevelEffect:Init(self._effectParent, self._bg, 3, "ui_yangHun")
end

function SubRideSoulPanel:_DisposeReference()
    self._curPropertyPhalanx:Dispose()
    self._nextPropertyPhalanx:Dispose()
    self._bagPhalanx:Dispose()
    self._bagItemPhalanx:Dispose()

    self._curPropertyPhalanx = nil
    self._nextPropertyPhalanx = nil
    self._bagPhalanx = nil
    self._bagItemPhalanx = nil

    self._feedEffect:Dispose()
    self._feedEffect = nil
    self._updateLevelEffect:Dispose()
    self._updateLevelEffect = nil
end

function SubRideSoulPanel:_InitListener()
    self._onClickBtnUpdate = function(go) self:_OnClickBtnUpdate(self) end
    UIUtil.GetComponent(self._btnUpdate, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnUpdate);
    self._onClickBtnUpdateOneKey = function(go) self:_OnClickBtnUpdateOneKey(self) end
    UIUtil.GetComponent(self._btnUpdateOneKey, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnUpdateOneKey);
    self._onClickBtnInstuction = function(go) self:_OnClickBtnInstuction(self) end
    UIUtil.GetComponent(self._btnInstuction, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnInstuction);

    MessageManager.AddListener(RideNotes, RideNotes.MESSAGE_FEEDMATERIALS_CHANGE, SubRideSoulPanel._FeedMaterialsChange, self);

end

function SubRideSoulPanel:_OnClickBtnInstuction()
    self._isShow = not self._isShow
    self._goInstrution:SetActive(self._isShow)

end

function SubRideSoulPanel:_OnClickBtnUpdateOneKey()
    if (#self._materials == 0) then
        MsgUtils.ShowConfirm(nil, "ride/SubRideSoulPanel/notMatertialFeed", nil, function()
            ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, { val = 1, updateNote = RideNotes.UPDATE_RIDEPANEL, other = storeConfig })
            -- ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, {val = 1, updateNote = RideNotes.UPDATE_RIDEPANEL})
        end )
    else
        MsgUtils.ShowConfirm(nil, "ride/SubRideSoulPanel/isOneKeyFeed", nil, RideProxy.SendRideFeedOnKey)
    end
end

function SubRideSoulPanel:_OnClickBtnUpdate()
    if (#self._materials == 0) then
        MsgUtils.ShowConfirm(nil, "ride/SubRideSoulPanel/notMatertialFeed", nil, function()
            ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, { val = 1, updateNote = RideNotes.UPDATE_RIDEPANEL, other = storeConfig })
        end )
    else
        RideProxy.SendRideFeed()
    end

end

function SubRideSoulPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnUpdate, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnUpdate = nil;
    UIUtil.GetComponent(self._btnUpdateOneKey, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnUpdateOneKey = nil;
    UIUtil.GetComponent(self._btnInstuction, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnInstuction = nil;

    MessageManager.RemoveListener(RideNotes, RideNotes.MESSAGE_FEEDMATERIALS_CHANGE, SubRideSoulPanel._FeedMaterialsChange, self);

end

function SubRideSoulPanel:_OnEnable()
    self:UpdatePanel()
end

function SubRideSoulPanel:SetOpenVal(val)
    self.openParam = val;
end

function SubRideSoulPanel:UpdatePanel()
    local data = RideManager.GetFeedData()
    local nextAttr = RideManager.GetNextFeedAttr()


    self._goNext:SetActive(nextAttr ~= nil)
    self._goNextLevelDes:SetActive(nextAttr ~= nil)
    local property = nil

    -- 第一个可能为全0显示
    -- 所以取下一级的属性作为显示条件
    if (nextAttr) then
        local nextItem = nextAttr:GetPropertyAndDes()
        self._nextPropertyPhalanx:Build(#nextItem, 1, nextItem)
        local keys = { }
        for k, v in ipairs(nextItem) do
            keys[k] = v.key
        end
        self:UpExp(data, false);
        property = data.attr:GetPropertyByKeys(keys)
    else
        self:UpExp(data, true);
        property = data.attr:GetPropertyAndDes()
        self._nextPropertyPhalanx:Build(0, 0, { })
    end
    self._curPropertyPhalanx:Build(#property, 1, property)
    self._materials = RideManager.GetRideFeedMaterials()

    self._bagItemPhalanx:Build(4, 5, self._materials)
end



function SubRideSoulPanel:_FeedMaterialsChange()

    self:UpExp(self._edata, self.isMax);

end

function SubRideSoulPanel:UpExp(data, isMax)
    self._edata = data;
    self.isMax = isMax;

    self._txtLevel.text = tostring(data.lev)
    if isMax then
        self._txtExp.text = "Max"
        self._sliderExp.value = 1
    else
        self._txtExp.text = data.curExp .. "/" .. data.maxExp
        self._sliderExp.value = data.curExp / data.maxExp
    end

    local hasmt = RideProxy.HasSelectMaterial();


    if hasmt then
        local level, curExp, maxExp = RideProxy.GetExpAndLevel();
        -- log("  level " .. level .. " curExp " .. curExp .. " maxExp " .. maxExp);
       
        if level > 0 then
            self._txtLevel.text = tostring(data.lev) .. "[77ff47] +" .. level .. "[-]";
            self._txtExp.text =   "0[77ff47] (+" .. curExp .. ")[-]/" .. maxExp;
        else
            self._txtExp.text = data.curExp .. "[77ff47] (+" .. curExp .. ")[-]/" .. maxExp;
        end

        self._sliderExp.value = curExp / maxExp
    end

end

function SubRideSoulPanel:ShowUpdateEffect()
    if (self._updateLevelEffect) then
        self._updateLevelEffect:Play()
    end
end



return SubRideSoulPanel
