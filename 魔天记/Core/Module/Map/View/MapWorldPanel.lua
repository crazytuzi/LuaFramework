require "Core.Module.Common.Panel"

MapWorldPanel = class("MapWorldPanel", Panel);
local ok = LanguageMgr.Get("common/ok")
local cancle = LanguageMgr.Get("common/cancle")
local notice = LanguageMgr.Get("common/notice")
local allMapCount = 6
local enableColor = Color.New(1, 248 / 255, 141 / 255)
local enableOutLineColor = Color.New(216 / 255, 107 / 255, 0, 50 / 255)
local disableColor = Color.New(183 / 255, 183 / 255, 183 / 255)
local disableOutLineColor = Color.New(20 / 255, 28 / 255, 50 / 255, 50 / 255)
local insert = table.insert

function MapWorldPanel:New()
    self = { };
    setmetatable(self, { __index = MapWorldPanel });
    return self
end 

function MapWorldPanel:_Init()
    self:_InitReference();
    self:_InitListener();
    self._mapConfig = { }
    self._item = { }
    local mapConfig = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_MAP)
    for k, v in pairs(mapConfig) do
        if (v.map_icon ~= "") then
            insert(self._mapConfig, v)
        end
    end
    self._onMapIconClick = function(go) self:_OnMapIconClick(go) end
    local parent = self._trsContent.gameObject
    local lev = HeroController:GetInstance().info.level
    local inMainWorld = false
    for k, v in ipairs(self._mapConfig) do
        local item = NGUITools.AddChild(parent, self._prefab)
        Util.SetLocalPos(item, v.map_icon_x, v.map_icon_y, 0)
        --        item.transform.localPosition = Vector3(v.map_icon_x, v.map_icon_y, 0)
        insert(self._item, item)
        UIUtil.GetComponent(item, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onMapIconClick);
        local sp = UIUtil.GetChildByName(item, "UISprite", "levelbg")
        local txtName = UIUtil.GetChildByName(item, "UILabel", "txtName")
        local txtLevel = UIUtil.GetChildByName(item, "UILabel", "txtLevel")

        if (lev < v.level) then
            ColorDataManager.SetGray(sp)
            txtName.color = disableColor
            txtName.effectColor = disableOutLineColor
            txtLevel.color = disableColor
            txtLevel.effectColor = disableOutLineColor
        else
            ColorDataManager.UnSetGray(sp)
            txtName.color = enableColor
            txtName.effectColor = enableOutLineColor
            txtLevel.color = enableColor
            txtLevel.effectColor = enableOutLineColor
        end

        txtName.text = v.name
        txtLevel.text = v.lev_show
        if (self._mapConfig[k].id == GameSceneManager.map.info.id) then
            inMainWorld = true
            Util.SetLocalPos(self._trsLocal, item.transform.localPosition - Vector3.up * 50)

            --            self._trsLocal.transform.localPosition = item.transform.localPosition - Vector3.up * 50
        end
    end

    if (not inMainWorld) then
        Util.SetLocalPos(self._trsLocal, 10000, 10000, 10000)

        --        self._trsLocal.transform.localPosition = Vector3.one * 10000
    end

    self._prefab:SetActive(false)
end

function MapWorldPanel:_OnMapIconClick(go)
    for k, v in pairs(self._item) do
        if (v == go) then
            local data = self._mapConfig[k]
            if (data.id == GameSceneManager.map.info.id) then
                MsgUtils.ShowTips("MapWorldPanel/sameMap")
            else
                if (HeroController:GetInstance().info.level < data.level) then
                    MsgUtils.ShowTips("MapWorldPanel/levelNotEnough", {lv = data.level});
                else
                    self:Transfer(data.name, data.id)
                end
            end
            return
        end
    end
end


function MapWorldPanel:_InitReference()
    self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
    self._prefab = UIUtil.GetChildByName(self._trsContent, "prefabIcon").gameObject
    --    for i = 1, allMapCount do
    --        self["_btn" .. i] = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn" .. i);
    --    end
    --    self._btn1 = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn1");
    --    self._btn1 = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn1");
    --    self._btn1 = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn1");
    --    self._btn1 = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn1");
    --    self._btn1 = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn1");
    --    self._btn1 = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn1");
    self._trsLocal = UIUtil.GetChildByName(self._trsContent, "Transform", "trsLocal");
end

function MapWorldPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
    --    self._onClickBtn1 = function(go) self:_OnClickBtn1(self) end
    --    UIUtil.GetComponent(self._btn1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn1);
    --    self._onClickBtn2 = function(go) self:_OnClickBtn2(self) end
    --    UIUtil.GetComponent(self._btn2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn2);
    --    self._onClickBtn3 = function(go) self:_OnClickBtn3(self) end
    --    UIUtil.GetComponent(self._btn3, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn3);
    --    self._onClickBtn4 = function(go) self:_OnClickBtn4(self) end
    --    UIUtil.GetComponent(self._btn4, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn4);
    --    self._onClickBtn5 = function(go) self:_OnClickBtn5(self) end
    --    UIUtil.GetComponent(self._btn5, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn5);
    --    self._onClickBtn6 = function(go) self:_OnClickBtn6(self) end
    --    UIUtil.GetComponent(self._btn6, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn6);

end

function MapWorldPanel:_OnClickBtn_close()
    ModuleManager.SendNotification(MapNotes.CLOSE_MAPWORLDPANEL)
end


-- function MapWorldPanel:_OnClickBtn1()
--    self:Transfer(LanguageMgr.Get("map/mapWorldPanel/manguizhong"), 701001)
-- end

-- function MapWorldPanel:_OnClickBtn2()
--    self:Transfer(LanguageMgr.Get("map/mapWorldPanel/fujiaomijing"), 701002)
-- end

-- function MapWorldPanel:_OnClickBtn3()
--    self:Transfer(LanguageMgr.Get("map/mapWorldPanel/xuanjing"), 701003)
-- end

-- function MapWorldPanel:_OnClickBtn4()
--    self:Transfer(LanguageMgr.Get("map/mapWorldPanel/bieyuandao"), 701004)
-- end

-- function MapWorldPanel:_OnClickBtn5()
--    self:Transfer(LanguageMgr.Get("map/mapWorldPanel/haihuanggong"), 701005)
-- end

-- function MapWorldPanel:_OnClickBtn6()
--    self:Transfer(LanguageMgr.Get("map/mapWorldPanel/changyangfangshi"), 701008)
-- end


function MapWorldPanel:Transfer(name, data)
    ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {
        title = notice,
        msg = LanguageMgr.Get("map/mapWorldPanel/transferNotice",{ name = name }),
        ok_Label = ok,
        cance_lLabel = cancle,
        hander = MapWorldPanel.GotoScene,
        target = self;
        data = data
    } );
end

function MapWorldPanel:GotoScene(data)
    HeroController.GetInstance():DoAction(SendStandAction:New())

    -- CLOSE_MAPPANEL
    ModuleManager.SendNotification(MapNotes.CLOSE_MAPPANEL)
    ModuleManager.SendNotification(MapNotes.CLOSE_FIELD_MAP_PANEL)

    -- GameSceneManager.to = nil;
    GameSceneManager.GotoSceneByLoading(data)

    ModuleManager.SendNotification(MapNotes.CLOSE_MAPWORLDPANEL)

end



function MapWorldPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function MapWorldPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
    for k, v in ipairs(self._item) do
        UIUtil.GetComponent(v, "LuaUIEventListener"):RemoveDelegate("OnClick");
    end
    self._onMapIconClick = nil
    --    for i = 1, allMapCount do
    --        UIUtil.GetComponent(self["_btn" .. i], "LuaUIEventListener"):RemoveDelegate("OnClick");
    --        self["_onClickBtn" .. i] = nil
    --    end

    --    UIUtil.GetComponent(self._btn1, "LuaUIEventListener"):RemoveDelegate("OnClick");
    --    self._onClickBtn1 = nil;
    --    UIUtil.GetComponent(self._btn2, "LuaUIEventListener"):RemoveDelegate("OnClick");
    --    self._onClickBtn2 = nil;
    --    UIUtil.GetComponent(self._btn3, "LuaUIEventListener"):RemoveDelegate("OnClick");
    --    self._onClickBtn3 = nil;
    --    UIUtil.GetComponent(self._btn4, "LuaUIEventListener"):RemoveDelegate("OnClick");
    --    self._onClickBtn4 = nil;
    --    UIUtil.GetComponent(self._btn5, "LuaUIEventListener"):RemoveDelegate("OnClick");
    --    self._onClickBtn5 = nil;
    --    UIUtil.GetComponent(self._btn6, "LuaUIEventListener"):RemoveDelegate("OnClick");
    --    self._onClickBtn6 = nil;
end

function MapWorldPanel:_DisposeReference()
    self._btn_close = nil;
    for k, v in ipairs(self._item) do
        Resourcer.Recycle(v, false)
    end
    self._item = nil
    self._prefab = nil
    self._mapConfig = nil
end
