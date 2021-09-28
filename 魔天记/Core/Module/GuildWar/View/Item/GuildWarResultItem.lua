require "Core.Module.Common.UIItem"
require "Core.Module.GuildWar.View.Item.GuildWarRoleItem"

--GuildWarResultItem = class("GuildWarResultItem", GuildWarRoleItem);
GuildWarResultItem = UIItem:New();

local super = GuildWarRoleItem;

function GuildWarResultItem:_Init()
    self._icoItem1 = UIUtil.GetChildByName(self.transform, "UISprite", "icoItem1");
    self._txtItem1 = UIUtil.GetChildByName(self.transform, "UILabel", "txtItem1");
    self._icoItem2 = UIUtil.GetChildByName(self.transform, "UISprite", "icoItem2");
    self._txtItem2 = UIUtil.GetChildByName(self.transform, "UILabel", "txtItem2");

    super._Init(self);
end

function GuildWarResultItem:_Dispose()
    
end

function GuildWarResultItem:UpdateItem(data)
    super.UpdateItem(self, data);
    
    if data and data.rw then
        for i = 1, 2 do
        	local d = data.rw[i];
        	if d then
				local cfg = ConfigManager.GetProductById(d.spId);
				ProductManager.SetIconSprite(self["_icoItem" .. i], cfg.icon_id);
				self["_txtItem" .. i].text = d.am;
			else
				self["_icoItem" .. i].spriteName = "";
				self["_txtItem" .. i].text = "";
			end
        end
    end
end
