require "Core.Module.Common.UIItem"

OtherFightItem = UIItem:New();

function OtherFightItem:_Init()
    self._icon = UIUtil.GetChildByName(self.transform, "UISprite", "icon");
    self._txtTargetFight = UIUtil.GetChildByName(self.transform, "UILabel", "titileTargetFight/txtTargetFight");
    self._txtMyFight = UIUtil.GetChildByName(self.transform, "UILabel", "titileMyFight/txtMyFight");

    self:UpdateItem(self.data);
end

function OtherFightItem:_Dispose()
    
end

function OtherFightItem:UpdateItem(data)
    self.data = data;
    local allData = OtherInfoProxy.otherFightData;
    if data then
    	local cfg = SystemManager.GetCfg(data);
		self._icon.spriteName = cfg.icon;
		local a,b = 0;
		if data == SystemConst.Id.EQUIP then
			a = allData.equip;
			b = allData.my_equip;
        elseif data == SystemConst.Id.REALM then
            a = allData.realm;
            b = allData.my_realm;
        elseif data == SystemConst.Id.PET then
            a = allData.pet;
            b = allData.my_pet;
        elseif data == SystemConst.Id.LingYao then
            a = allData.elixir;
            b = allData.my_elixir;
        elseif data == SystemConst.Id.FABAO then
            a = allData.star;
            b = allData.my_star;
		elseif data == SystemConst.Id.MOUNT then
			a = allData.ride;
			b = allData.my_ride;
		elseif data == SystemConst.Id.WING then
			a = allData.wing;
            b = allData.my_wing;
        elseif data == SystemConst.Id.SKILL then
            a = allData.skill;
            b = allData.my_skill;
        elseif data == SystemConst.Id.Formation then
            a = allData.graphic;
            b = allData.my_graphic;
		end
        self._txtTargetFight.text = a;

        if b > a then
			self._txtMyFight.text = LanguageMgr.GetColor("g", b);
        elseif b < a then
        	self._txtMyFight.text = LanguageMgr.GetColor("r", b);
        else
        	self._txtMyFight.text = b;	
        end
        
    else
    	self._icon.spriteName = "";
        self._txtTargetFight.text = "";
        self._txtMyFight.text = "";
    end
end