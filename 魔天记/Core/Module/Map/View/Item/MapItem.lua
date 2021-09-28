require "Core.Module.Common.UIItem"

MapItem = class("MapItem", UIItem);
MapItem._monsterTypeColor = Color.New(1, 75 / 255, 75 / 255)
MapItem._npcTypeColor = Color.New(156 / 255, 255, 148 / 255)
MapItem._npcDes = LanguageMgr.Get("map/mapItem/npcDes")
MapItem._monsterDes = LanguageMgr.Get("map/mapItem/monsterDes")

function MapItem:New()
    self = { };
    setmetatable(self, { __index = MapItem });
    return self
end


function MapItem:_Init()
    self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "name")
    self._txtType = UIUtil.GetChildByName(self.transform, "UILabel", "type")
    self._onClickItem = function(go) self:_OnClickItem(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickItem);
    self:UpdateItem(self.data)
end 

function MapItem:UpdateItem(data)
    self.data = data
     self._txtName.text = self.data.name
    if (self.data.mapItemType == MapItemType.Npc) then
        self._txtType.color = MapItem._npcTypeColor
        self._txtType.text = MapItem._npcDes
    elseif (self.data.mapItemType == MapItemType.Monster) then
        self._txtType.color = MapItem._monsterTypeColor
        self._txtType.text = MapItem._monsterDes
    end
end

function MapItem:_Dispose()
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickItem = nil;
end
 
function MapItem:_OnClickItem()
    HeroController:GetInstance():MoveTo(self.data.position, GameSceneManager.map.info.id)
end