require "Core.Module.Activity.View.item.RCActivityPageItem"
require "Core.Module.Activity.controlls.InfosPanelCtr"

TimeActivityPanelCtr = class("TimeActivityPanelCtr");

function TimeActivityPanelCtr:New()
    self = { };
    setmetatable(self, { __index = TimeActivityPanelCtr });
    return self
end 

function TimeActivityPanelCtr:Init(gameObject)
    self.gameObject = gameObject;
    self._pages = UIUtil.GetChildByName(self.gameObject, "Transform", "pages");
    self._pageIcons = { };
    self._pageIcons["1"] = UIUtil.GetChildByName(self._pages, "UISprite", "pageSelect1");
    self._pageIcons["2"] = UIUtil.GetChildByName(self._pages, "UISprite", "pageSelect2");
    self._pageIcons["3"] = UIUtil.GetChildByName(self._pages, "UISprite", "pageSelect3");
    self._pag_phalanx = UIUtil.GetChildByName(self.gameObject, "LuaAsynPhalanx", "ScrollView/bag_phalanx");
    self.myUICenterOnChild = UIUtil.GetComponent(self._pag_phalanx, "MyUICenterOnChild");
    self._callBack = function(name) self:PageChange(name); end;
    self.myUICenterOnChild.onFinishedHandler = self._callBack;
    self:InitData();
    self:PageChange("0");

    self.gameObject.gameObject:SetActive(true);
    self:Hide()
end 

function TimeActivityPanelCtr:ServerDataChange()

    local list = ActivityDataManager.GetLTAList();
    local pag_num = table.getn(list);

    self._pageIcons["1"].gameObject:SetActive(false);
    self._pageIcons["2"].gameObject:SetActive(false);
    self._pageIcons["3"].gameObject:SetActive(false);

    local _items = self.pag_phalanx:GetItems();
    for i = 1, 3 do
        _items[i].itemLogic:SetData(list[i], true);

        if list[i] ~= nil then
            self._pageIcons[i .. ""].gameObject:SetActive(true);
        end
    end
end

function TimeActivityPanelCtr:InitData()
    self._productPanels = { };
    self._productPanels_index = 1;
    local data = {
        { name = "page0", page_id = "1" },
        { name = "page1", page_id = "2" },
        { name = "page2", page_id = "3" }
    }
    self.pag_phalanx = Phalanx:New();
    self.pag_phalanx:Init(self._pag_phalanx, RCActivityPageItem, false)
    self.pag_phalanx:Build(1, 3, data);
    self.currPage_id = "-1";
    self:ServerDataChange()
end

function TimeActivityPanelCtr:PageChange(args)
    local str_len = string.len(args);
    local page_id = string.sub(args, str_len, -1);

    if self.currPage_id ~= page_id then
        self.currPage_id = page_id;
        self:ShowPageIcon(self.currPage_id);
    end
end


function TimeActivityPanelCtr:SetSelect(activity_id, needToPage)


    if activity_id ~= nil then
        local _items = self.pag_phalanx:GetItems();
        for i = 1, 3 do

            if needToPage then
                _items[i].itemLogic:SetSelect(activity_id, self.myUICenterOnChild);
            else
                _items[i].itemLogic:SetSelect(activity_id, nil);
            end


        end
    end

end

function TimeActivityPanelCtr:ShowPageIcon(pid)
    pid = pid + 1;

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

function TimeActivityPanelCtr:Show()
    -- self.gameObject.gameObject:SetActive(true);
    SetUIEnable(self.gameObject, true);
end

function TimeActivityPanelCtr:Hide()
    -- self.gameObject.gameObject:SetActive(false);
    SetUIEnable(self.gameObject, false);
end

function TimeActivityPanelCtr:Dispose()
    self.pag_phalanx:Dispose();
    self.pag_phalanx = nil
    RCActivityItem.currSelected = nil;


    self.gameObject = nil;
    self._pages = nil;
    self._pageIcons = nil;

    self._pag_phalanx = nil;

    self._callBack = nil;
    if self.myUICenterOnChild and self.myUICenterOnChild.onFinishedHandler then
        self.myUICenterOnChild.onFinishedHandler:Destroy();
        self.myUICenterOnChild = nil;
    end
end