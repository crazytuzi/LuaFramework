require "Core.Module.Common.UIItem"


YaoYuanDiDuiXMItem = class("YaoYuanDiDuiXMItem", UIItem);

function YaoYuanDiDuiXMItem:New()
    self = { };
    setmetatable(self, { __index = YaoYuanDiDuiXMItem });
    return self
end
 

function YaoYuanDiDuiXMItem:UpdateItem(data)
    self.data = data
end

function YaoYuanDiDuiXMItem:Init(gameObject, data)

    self.gameObject = gameObject;


    self.name_txt = UIUtil.GetChildByName(self.gameObject, "UILabel", "name_txt");
    self.elseTimeTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "elseTimeTxt");
    self.level = UIUtil.GetChildByName(self.gameObject, "UILabel", "level");
    self.successPcTxt = UIUtil.GetChildByName(self.gameObject, "UILabel", "successPcTxt");

    self.icon = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon");

    self.joinBt = UIUtil.GetChildByName(self.gameObject, "UIButton", "joinBt");
    self.joinBtTipIcon = UIUtil.GetChildByName(self.gameObject, "UISprite", "joinBt/tipIcon");

    self._onClickjoinBt = function(go) self:_OnClickjoinBt(self) end
    UIUtil.GetComponent(self.joinBt, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickjoinBt);



    self:SetActive(true);

end

function YaoYuanDiDuiXMItem:_OnClickjoinBt()

    if self.data ~= nil then
        YaoyuanProxy.TryGetXianMenNumberInfo(self.data.pid, YaoyuanProxy.NUMBER_INFO_TYPE_2, self.data)
    end

end


function YaoYuanDiDuiXMItem:SetActive(v)
    self.gameObject.gameObject:SetActive(v);
end



function YaoYuanDiDuiXMItem:SetData(data)

    self.data = data;


    if self.data == nil then

        self:SetActive(false);

    else

        self.data.pid = data.pId;

        self.name_txt.text = data.n;
        self.elseTimeTxt.text = data.tn;
        self.level.text = data.l;


        self.icon.spriteName = "" .. data.c;

        if data.cg >0 then

            self.joinBtTipIcon.gameObject:SetActive(true);
        else
            self.joinBtTipIcon.gameObject:SetActive(false);
        end


        local odd = data.odd;
      
        local attV = FarmsDataManager.GetFarm_guard(FarmsDataManager.farms.pf.e, data.e);

        local tem_v = odd - attV.value;
        if tem_v < 0 then
            tem_v = 0;
        end

        if tem_v > 100 then
          tem_v = 99;
        end

        self.successPcTxt.text = FarmsDataManager:GetDesByPc(tem_v);

        self:SetActive(true);
    end


end


function YaoYuanDiDuiXMItem:_Dispose()
    self.gameObject = nil;

    UIUtil.GetComponent(self.joinBt, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickjoinBt = nil;


    self.name_txt =nil;
    self.elseTimeTxt = nil;
    self.level = nil;
    self.successPcTxt = nil;

    self.icon =nil;

    self.joinBt = nil;
    self.joinBtTipIcon =nil;

  

end