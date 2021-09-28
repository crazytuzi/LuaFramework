require "Core.Module.Activity.View.item.ActivityPageItem"

RiChangFBPanelCtr = class("RiChangFBPanelCtr");

function RiChangFBPanelCtr:New()
    self = { };
    setmetatable(self, { __index = RiChangFBPanelCtr });
    return self
end


function RiChangFBPanelCtr:Init(gameObject)
    self.gameObject = gameObject;


    self._pages = UIUtil.GetChildByName(self.gameObject, "Transform", "pages");
    self._pageIcons = { };
    self._pageIcons["1"] = UIUtil.GetChildByName(self._pages, "UISprite", "pageSelect1");
    self._pageIcons["2"] = UIUtil.GetChildByName(self._pages, "UISprite", "pageSelect2");
    self._pageIcons["3"] = UIUtil.GetChildByName(self._pages, "UISprite", "pageSelect3");


    self._ScrollView = UIUtil.GetChildByName(self.gameObject, "Transform", "ScrollView");
    self._pag_phalanx = UIUtil.GetChildByName(self._ScrollView, "LuaAsynPhalanx", "bag_phalanx");

    self.myUICenterOnChild = UIUtil.GetComponent(self._pag_phalanx, "MyUICenterOnChild");
    self._callBack = function(name) self:PageChange(name); end;
    self.myUICenterOnChild.onFinishedHandler = self.callBack;


    
    self:InitData();
    self:PageChange("0");

    self.gameObject.gameObject:SetActive(true);
    self:Hide()
end



function RiChangFBPanelCtr:InitData()
    self._productPanels = { };
    self._productPanels_index = 1;


    self.pag_phalanx = Phalanx:New();
    self.pag_phalanx:Init(self._pag_phalanx, ActivityPageItem)


    self:ServerDataChange()

end

function RiChangFBPanelCtr:SetSelect(activity_id,needToPage)


    if activity_id ~= nil then
        local _items = self.pag_phalanx._items;
        local num = table.getn(_items);
        for i = 1, num do
            _items[i].itemLogic:SetSelect(activity_id);

        end
    end

end

function RiChangFBPanelCtr:ServerDataChange()

    local list = ActivityDataManager.GetFBList();
    self.pag_num = table.getn(list);

    self._pageIcons["1"].gameObject:SetActive(false);
    self._pageIcons["2"].gameObject:SetActive(false);
    self._pageIcons["3"].gameObject:SetActive(false);

    self.pag_phalanx:Build(1, self.pag_num, list);
    self.currPage_id = "-1";

    local _items = self.pag_phalanx._items;
    for i = 1, self.pag_num do
        _items[i].itemLogic:SetData(list[i]);

        if list[i] ~= nil then
            self._pageIcons[i .. ""].gameObject:SetActive(true);
        end
    end

end


function RiChangFBPanelCtr:PageChange(args)

    local str_len = string.len(args);
    local page_id = string.sub(args, str_len, -1);

    if self.currPage_id ~= page_id then
        self.currPage_id = page_id;
        self:ShowPageIcon(self.currPage_id);
    end
end

function RiChangFBPanelCtr:ShowPageIcon(pid)

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

function RiChangFBPanelCtr:Show()


    -- self.gameObject.gameObject:SetActive(true);
    SetUIEnable(self.gameObject, true);
end

function RiChangFBPanelCtr:Hide()


    -- self.gameObject.gameObject:SetActive(false);
    SetUIEnable(self.gameObject, false);
end

function RiChangFBPanelCtr:Dispose()

    self._callBack = nil;
    if self.myUICenterOnChild and self.myUICenterOnChild.onFinishedHandler then
        self.myUICenterOnChild.onFinishedHandler:Destroy();
    end    
    self.myUICenterOnChild = nil;

    self.pag_phalanx:Dispose();
    self.pag_phalanx = nil;

    self.gameObject = nil;

    self._pages = nil;
    self._pageIcons = nil;

    self._ScrollView = nil;
    self._pag_phalanx = nil;



end