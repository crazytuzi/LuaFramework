require "Core.Module.Common.UIItem"

require "Core.Module.Equip.controll.ProductCostPanelCtrl"



ProductCostPanelItem = UIItem:New();
ProductCostPanelItem.clickEnble = true;
 
function ProductCostPanelItem:UpdateItem(data)
    self.data = data

    self:SetData(data);
end

function ProductCostPanelItem:Init(gameObject, data)


    self.gameObject = gameObject



    self.eqPanel = UIUtil.GetChildByName(self.gameObject, "Transform", "eqPanel");
    self.selectIcon = UIUtil.GetChildByName(self.gameObject, "Transform", "selectIcon");

    self.fightTipIcon = UIUtil.GetChildByName(self.eqPanel, "UISprite", "fightTipIcon");
    self.bukeyongIcon = UIUtil.GetChildByName(self.eqPanel, "UISprite", "bukeyongIcon");

    self.unUseBg = UIUtil.GetChildByName(self.eqPanel, "UISprite", "unUseBg");

    self.pro_local_icon = UIUtil.GetChildByName(self.eqPanel, "UISprite", "pro_local_icon");

    self.unUseBg.gameObject:SetActive(false);
    self.fightTipIcon.gameObject:SetActive(false);
    self.bukeyongIcon.gameObject:SetActive(false);
    self.pro_local_icon.gameObject:SetActive(false);

    self.eqPanelControll = ProductCostPanelCtrl:New();
    self.eqPanelControll:Init(self.eqPanel.gameObject, 1);

    self:UpdateItem(data);
    self:SetSelect(false);

    self._onClickBtn = function(go) self:_OnClickBtn(self) end
    UIUtil.GetComponent(self.gameObject.transform, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);

end

function ProductCostPanelItem:_OnClickBtn()

    if ProductCostPanelItem.clickEnble then
        if self.selected then
            self:SetSelect(false);
        else
            self:SetSelect(true);
        end

    end


end

function ProductCostPanelItem:SetActive(v)
    self.gameObject:SetActive(v);



end

function ProductCostPanelItem:SetSelecteHandler(handler, hd_tg)
    self.selecteHandler = handler;
    self.selecteHandler_tg = hd_tg;
end

function ProductCostPanelItem:SetSelect(v)

    if self.selected ~= v then
        self.selectIcon.gameObject:SetActive(v);
        self.selected = v;

        if self.selecteHandler ~= nil then
            if self.selecteHandler_tg ~= nil then
                self.selecteHandler(self.selecteHandler_tg);
            else
                self.selecteHandler();
            end

        end

    end

end



function ProductCostPanelItem:SetData(infoData)

    self.infoData = infoData;


    self._productInfo = infoData;
    self.eqPanelControll:SetProduct(infoData);

    self.pro_local_icon.gameObject:SetActive(false);
    -------------------------------------------------------

    if self._productInfo ~= nil then

        local ty = self._productInfo:GetType();

        local ib = self._productInfo:IsBind();
        self.pro_local_icon.gameObject:SetActive(ib);


        if ProductManager.type_1 == ty then

            -------------------------------------------------------

            local career = tonumber(self._productInfo:Get_career());
            local re_v = tonumber(self._productInfo:GetReq_lev());


            local my_info = HeroController:GetInstance().info;
            local my_career = tonumber(my_info:GetCareer());
            local my_lv = tonumber(my_info.level);



            ------------------------------------------------------------

            local kind = self._productInfo:GetKind();
            local eqbagInfo = EquipDataManager.GetProductByKind(kind);

            self.fight_up = false;

            self.bukeyongIcon.gameObject:SetActive(false);
            local isFitCareer = self._productInfo:IsFitMyCareer();

            if eqbagInfo == nil then

                if isFitCareer then
                    self.fightTipIcon.spriteName = "up";
                    self.fightTipIcon.gameObject:SetActive(true);
                    self.fight_up = true;
                else
                    self.fightTipIcon.gameObject:SetActive(false);
                    self.bukeyongIcon.gameObject:SetActive(true);
                end

            else


                -- 对应装备栏里的总 战斗力
                local eq_bag_fight = eqbagInfo:GetFight();

                -- 背包中的 属性

                local bag_fight = self._productInfo:GetFight();

                -- log("----_fight-------- "..eq_bag_fight.. "  "..bag_fight);

                if isFitCareer then

                    if bag_fight > eq_bag_fight then
                        self.fightTipIcon.spriteName = "up";
                        self.fightTipIcon.gameObject:SetActive(true);
                        self.fight_up = true;
                    elseif bag_fight < eq_bag_fight then
                        self.fightTipIcon.spriteName = "down";
                        self.fightTipIcon.gameObject:SetActive(true);
                    else
                        self.fightTipIcon.gameObject:SetActive(false);
                    end

                else
                    self.fightTipIcon.gameObject:SetActive(false);
                    self.bukeyongIcon.gameObject:SetActive(true);

                end




            end

            if (career ~= my_career and career ~= 0) or(my_lv <= re_v) then

                self.unUseBg.gameObject:SetActive(true);

                if my_career ~= career and career ~= 0 then
                    self.fightTipIcon.gameObject:SetActive(false);
                end

            else
                self.unUseBg.gameObject:SetActive(false);
            end


            ----------------------------------------------------------------------------------------------

        end



    else
        self.unUseBg.gameObject:SetActive(false);
        self.fightTipIcon.gameObject:SetActive(false);
    end


end
   
function ProductCostPanelItem:_Dispose()

    self.data = nil;

    self.eqPanel = nil;
    self.selectIcon = nil;

    UIUtil.GetComponent(self.gameObject.transform, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn = nil;
    self.gameObject = nil;

    self.eqPanelControll:Dispose()
    self.eqPanelControll = nil;


end