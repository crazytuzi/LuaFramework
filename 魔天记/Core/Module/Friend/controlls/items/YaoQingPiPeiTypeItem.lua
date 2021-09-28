require "Core.Module.Common.UIItem"

require "Core.Module.Friend.controlls.items.YaoQingPiPeiItem"


YaoQingPiPeiTypeItem = class("YaoQingPiPeiTypeItem", UIItem);

YaoQingPiPeiTypeItem.MESSAGE_YAOQINGPIPEITYPEITEM_SELECTED_CHANGE = "MESSAGE_YAOQINGPIPEITYPEITEM_SELECTED_CHANGE";

YaoQingPiPeiTypeItem.currSelect = nil;
YaoQingPiPeiTypeItem.typeItemSelectIcon = nil;

function YaoQingPiPeiTypeItem:New()
    self = { };
    setmetatable(self, { __index = YaoQingPiPeiTypeItem });
    return self
end
 

function YaoQingPiPeiTypeItem:UpdateItem(data)
    self.data = data
end

function YaoQingPiPeiTypeItem:Init(gameObject, data)

    self.gameObject = gameObject;

    self.titleTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "titleTxt");

    self.signIcon = UIUtil.GetChildByName(self.gameObject, "UISprite", "titleBg/signIcon");
    self.icoSelect = UIUtil.GetChildByName(self.gameObject, "UISprite", "titleBg/icoSelect");


    self._onClickBtn = function(go) self:_OnClickBtn(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);



    self.yp_phalanx = UIUtil.GetChildByName(self.gameObject, "Transform", "yp_phalanx");
    self._item_phalanx = UIUtil.GetChildByName(self.gameObject, "LuaAsynPhalanx", "yp_phalanx");

    self.product_phalanx = Phalanx:New();
    self.product_phalanx:Init(self._item_phalanx, YaoQingPiPeiItem);

    self.icoSelect.gameObject:SetActive(false);


    self:SetData(data);

end


function YaoQingPiPeiTypeItem:SetIndex(v, _clsTable)
    self.index = v;
    self._clsTable = _clsTable;


end

function YaoQingPiPeiTypeItem:SetSelect(v)

    self.currSelected = v;

end


function YaoQingPiPeiTypeItem:SetSelectData(selectData)

    local team_match_data = selectData.team_match_data;
    local min_lv = selectData.min_lv;
    local max_lv = selectData.max_lv;

   

    if self.data[1].activity_id == team_match_data.activity_id then

        self:_OnClickBtn();

        local items = self.product_phalanx._items;
        local t_num = table.getn(items);

        for i = 1, t_num do
            local obj = items[i].itemLogic;
            obj:CheckSelect(team_match_data, min_lv, max_lv);
        end

    end



end


function YaoQingPiPeiTypeItem:ShowAllItems()
    self.itemShow = true;
    self.yp_phalanx.gameObject:SetActive(true);
    self.signIcon.transform.localScale = Vector3.New(1, -1, 1);
   
    self._clsTable:Reposition();
end

function YaoQingPiPeiTypeItem:HideAllItems()
    self.itemShow = false;
    self.yp_phalanx.gameObject:SetActive(false);
   

    self.signIcon.transform.localScale = Vector3.New(1, 1, 1);

    if self._clsTable ~= nil then
        self._clsTable:Reposition();
    end



end


function YaoQingPiPeiTypeItem:SetActive(v)
    self.gameObject.gameObject:SetActive(v);
end




function YaoQingPiPeiTypeItem:SetData(data)

    self.data = data;

   
    self.activityCf = ActivityDataManager.GetCfBy_id(self.data[1].activity_id);
    self.active_ft_data = ActivityDataManager.GetFtById(self.activityCf.id);


    self.titleTxt.text = data[1].type_name;


    local t_num = table.getn(data);
    self.product_phalanx:Build(t_num, 1, data);


    local items = self.product_phalanx._items;
    local t_num = table.getn(items);

    self.posList = { };

    for i = 1, t_num do
        local gtf = items[i].itemLogic.gameObject.transform;
        self.posList[i] = { x = gtf.localPosition.x, y = gtf.localPosition.y };
    end


end

function YaoQingPiPeiTypeItem:_OnClickBtn()

 

    if YaoQingPiPeiTypeItem.currSelect == self then

        if self.currSelected then
            YaoQingPiPeiTypeItem.currSelect:SetSelect(false);
            YaoQingPiPeiTypeItem.currSelect:HideAllItems();
        else
            YaoQingPiPeiTypeItem.currSelect:SetSelect(true);
            YaoQingPiPeiTypeItem.currSelect:ShowAllItems();
        end


    else

        if YaoQingPiPeiTypeItem.currSelect ~= nil then
            YaoQingPiPeiTypeItem.currSelect:SetSelect(false);
            YaoQingPiPeiTypeItem.currSelect:HideAllItems();
            
        end

        YaoQingPiPeiTypeItem.currSelect = self;
        YaoQingPiPeiTypeItem.currSelect:SetSelect(true);
        
        YaoQingPiPeiTypeItem.currSelect:ShowAllItems();

    end

    


     MessageManager.Dispatch(YaoQingPiPeiTypeItem, YaoQingPiPeiTypeItem.MESSAGE_YAOQINGPIPEITYPEITEM_SELECTED_CHANGE, { team_match_data = self.data, activityCf = self.activityCf, active_ft_data = self.active_ft_data });


end


function YaoQingPiPeiTypeItem:_Dispose()


    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");

    self.product_phalanx:Dispose()
    self.product_phalanx = nil;
    self.gameObject = nil;

    YaoQingPiPeiTypeItem.typeItemSelectIcon = nil;
end