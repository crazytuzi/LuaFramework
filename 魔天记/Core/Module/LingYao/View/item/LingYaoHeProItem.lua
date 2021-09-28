require "Core.Module.Common.UIItem"


LingYaoHeProItem = class("LingYaoHeProItem", UIItem);

LingYaoHeProItem.MESSAGE_PRODUCTS_SELECTED_CHANGE = "MESSAGE_LINEYAO_PRODUCTS_SELECTED_CHANGE";

LingYaoHeProItem.currSelected = { };

function LingYaoHeProItem:New()
    self = { };
    setmetatable(self, { __index = LingYaoHeProItem });
    return self
end
 

function LingYaoHeProItem:UpdateItem(data)
    self.data = data
end

function LingYaoHeProItem:Init(gameObject, data)

    self.gameObject = gameObject;

    self.txtTitle = UIUtil.GetChildByName(self.gameObject, "UILabel", "txtTitle");
    self.txtDesc = UIUtil.GetChildByName(self.gameObject, "UILabel", "txtDesc");

    self.icoSelect = UIUtil.GetChildByName(self.gameObject, "UISprite", "icoSelect");
    self.proPanel = UIUtil.GetChildByName(self.gameObject, "Transform", "proPanel");


    self._onClickHandler = function(go) self:_OnClickHandler(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickHandler);

    self.proPanelCtr = ProductCtrl:New();
    self.proPanelCtr:Init(self.proPanel, { hasLocke = true, use_sprite = true, iconType = ProductCtrl.IconType_rectangle }, true);


    self:SetData(data)

end

function LingYaoHeProItem:SetIndex(v)

    self.index = v;

end

function LingYaoHeProItem:UpShowListItem(v)


    if v then
        -- 只显示 可以合成的
        self:SetActive(self.canCompos);
        return self.canCompos;
    else
        -- 都显示
        self:SetActive(true);
    end

    return true;

end

function LingYaoHeProItem:_OnClickHandler()

    if LingYaoHeProItem.currSelected[self.index] ~= nil then
        LingYaoHeProItem.currSelected[self.index].icoSelect.gameObject:SetActive(false);
    end

    LingYaoHeProItem.currSelected[self.index] = self;
    LingYaoHeProItem.currSelected[self.index].icoSelect.gameObject:SetActive(true);

    MessageManager.Dispatch(LingYaoHeProItem, LingYaoHeProItem.MESSAGE_PRODUCTS_SELECTED_CHANGE, self, true);

end


function LingYaoHeProItem:SetActive(v)
    self.gameObject.gameObject:SetActive(v);
end



function LingYaoHeProItem:SetData(data)

    self.data = data;

    self:UpInfo();

end


function LingYaoHeProItem:UpInfo()

    local spId = self.data.id;
    local info = ProductManager.GetProductInfoById(spId, 1);

    self.proPanelCtr:SetData(info)

    self.txtTitle.text = self.data.name;

    -- 获取  是否可以 合成

    self:TryCheckCanComp();

end

--  检测 是否 可以有合成 资源
function LingYaoHeProItem:TryCheckCanComp()

    local elixirCf = LingYaoDataManager.Get_elixirCf(self.data.id);

    if elixirCf == nil then
        log("not find id " .. self.data.id);
    end

    local syn_material = elixirCf.syn_material;

    local canComNum1 = self:SetNeedmaterial(syn_material, 1);
   -- local canComNum2 = self:SetNeedmaterial(syn_material, 2);
  

   -- if canComNum1 > 0 and canComNum2 > 0 then
   if canComNum1 > 0  then
        -- 可以 合成
        self.txtDesc.text = LanguageMgr.Get("LingYao/LingYaoHeProItem/label1");
        self.canCompos = true;
    else
        -- 材料 不足
        self.txtDesc.text = LanguageMgr.Get("LingYao/LingYaoHeProItem/label2");
        self.canCompos = false;
    end



end

function LingYaoHeProItem:SetNeedmaterial(list, index)

    local str = list[index];
    local infoArr = ConfigSplit(str);
    local spId = infoArr[1] + 0;
    local am = infoArr[2] + 0;


    local pinfo = ProductManager.GetProductInfoById(spId, 1);
    local total_num_in_bag = BackpackDataManager.GetProductTotalNumBySpid(spId);


    local canCompMaxNum = math.floor(total_num_in_bag / am);

    return canCompMaxNum;

end


function LingYaoHeProItem:_Dispose()

    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickHandler = nil;

    self.proPanelCtr:Dispose()

    self.gameObject = nil;

    self.txtTitle = nil;
    self.txtDesc = nil;

    self.icoSelect = nil;
    self.proPanel = nil;


    self._onClickHandler = nil;

    self.proPanelCtr = nil;



end