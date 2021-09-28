require "Core.Module.Activity.View.item.RCActivityPageItem"
require "Core.Module.Activity.controlls.InfosPanelCtr"

RiChangActivityPanelCtr = class("RiChangActivityPanelCtr");

function RiChangActivityPanelCtr:New()
    self = { };
    setmetatable(self, { __index = RiChangActivityPanelCtr });
    return self
end


function RiChangActivityPanelCtr:Init(gameObject)
    self.gameObject = gameObject;



    self._pages = UIUtil.GetChildByName(self.gameObject, "Transform", "pages");

    self._pageIcons = { };
    self._pageIcons["1"] = UIUtil.GetChildByName(self._pages, "UISprite", "pageSelect1");
    self._pageIcons["2"] = UIUtil.GetChildByName(self._pages, "UISprite", "pageSelect2");
    self._pageIcons["3"] = UIUtil.GetChildByName(self._pages, "UISprite", "pageSelect3");


    self._ScrollView = UIUtil.GetChildByName(self.gameObject, "UIScrollView", "ScrollView");
    self._pag_phalanx = UIUtil.GetChildByName(self._ScrollView, "LuaAsynPhalanx", "bag_phalanx");



    self.myUICenterOnChild = UIUtil.GetComponent(self._pag_phalanx, "MyUICenterOnChild");
    self._callBack = function(name) self:PageChange(name); end
    self.myUICenterOnChild.onFinishedHandler = self._callBack;

    self:InitData();
    self:ServerDataChange();
    self:PageChange("0");

    self.gameObject.gameObject:SetActive(true);
    self:Hide()

end


function RiChangActivityPanelCtr:SetSelect(activity_id, needToPage)

    if activity_id ~= nil then
        local _items = self.pag_phalanx._items;
        for i = 1, 3 do
            if needToPage then
                local b = _items[i].itemLogic:SetSelect(activity_id);
                if b then
                    local tf = self.pag_phalanx:GetItem(i).gameObject.transform;
                    self.myUICenterOnChild:CenterOn(tf);

                   --   self._scollview:MoveRelative(Vector3.up * 140 *(idx - 3));
                end
            else
                _items[i].itemLogic:SetSelect(activity_id, nil);
            end

        end

    end

end

function RiChangActivityPanelCtr:ServerDataChange()

    local list = ActivityDataManager.GetRCAList();
    local pag_num = table.getn(list);

    self._pageIcons["1"].gameObject:SetActive(false);
    self._pageIcons["2"].gameObject:SetActive(false);
    self._pageIcons["3"].gameObject:SetActive(false);

    local _items = self.pag_phalanx._items;
    for i = 1, 3 do
        _items[i].itemLogic:SetData(list[i], true);

        if list[i] ~= nil then
            self._pageIcons[i .. ""].gameObject:SetActive(true);
        end

    end


end

function RiChangActivityPanelCtr:InitData()
    self._productPanels = { };
    self._productPanels_index = 1;
    local data = {
        { name = "page0", page_id = "1" },
        { name = "page1", page_id = "2" },
        { name = "page2", page_id = "3" }
    }


    self.pag_phalanx = Phalanx:New();
    self.pag_phalanx:Init(self._pag_phalanx, RCActivityPageItem)
    self.pag_phalanx:Build(1, 3, data);
    self.currPage_id = "-1";

    -- self:ServerDataChange();


end

function RiChangActivityPanelCtr:PageChange(args)

    local str_len = string.len(args);
    local page_id = string.sub(args, str_len, -1);

    if self.currPage_id ~= page_id then
        self.currPage_id = page_id;
        self:ShowPageIcon(self.currPage_id);
    end
end

function RiChangActivityPanelCtr:ShowPageIcon(pid)

    pid = pid + 1;
    local _items = self.pag_phalanx._items;

    for j = 1, 3 do
        local picon = self._pageIcons[j .. ""];
        if j == pid then
            picon.spriteName = "circle2";
            picon:MakePixelPerfect();
        else
            picon.spriteName = "circle1";
            picon:MakePixelPerfect();
        end
    end

end


function RiChangActivityPanelCtr:Show()


    -- self.gameObject.gameObject:SetActive(true);
    SetUIEnable(self.gameObject, true);
end

function RiChangActivityPanelCtr:Hide()


    -- self.gameObject.gameObject:SetActive(false);
    SetUIEnable(self.gameObject, false);
end


function RiChangActivityPanelCtr:Dispose()

    RCActivityItem.currSelected = nil;


    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn = nil;

    self.pag_phalanx:Dispose();
    self.pag_phalanx = nil;

    self.gameObject = nil;

    self._pages = nil;

    self._pageIcons = nil;


    self._ScrollView = nil;
    self._pag_phalanx = nil;

    self._callBack = nil;

    if self.myUICenterOnChild and self.myUICenterOnChild.onFinishedHandler then
        self.myUICenterOnChild.onFinishedHandler:Destroy();
        self.myUICenterOnChild = nil;
    end

end