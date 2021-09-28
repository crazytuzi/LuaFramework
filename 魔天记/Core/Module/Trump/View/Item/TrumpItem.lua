require "Core.Module.Common.UIItem"
TrumpItem = class("TrumpItem", UIItem);
TrumpItem.canDressDes = LanguageMgr.Get("trump/TrumpItem/canDress")
TrumpItem.levelDes = LanguageMgr.Get("trump/TrumpItem/level")

function TrumpItem:New()
    self = { };
    setmetatable(self, { __index = TrumpItem });
    return self
end


function TrumpItem:_Init()
    self:_InitReference();
    self:_InitListener();
    self:UpdateItem(self.data)
end

function TrumpItem:_InitReference()
    self._imgIcon = UIUtil.GetChildByName(self.transform, "UISprite", "icon")
    self._imgQuaility = UIUtil.GetChildByName(self.transform, "UISprite", "quality")
    self._txtLevel = UIUtil.GetChildByName(self.transform, "UILabel", "level")
    self._txtReqLevel = UIUtil.GetChildByName(self.transform, "UILabel", "reqlevel")
    self._goLock = UIUtil.GetChildByName(self.transform, "lock").gameObject
    self._goDress = UIUtil.GetChildByName(self.transform, "dress").gameObject
    self._trsLvBg = UIUtil.GetChildByName(self.transform, "trsLvBg").gameObject

end

function TrumpItem:_InitListener()
    self._onBtnItemClick = function(go) self:_OnBtnItemClick(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onBtnItemClick);
end

function TrumpItem:_OnBtnItemClick()
    if (self.data.info) then
        ModuleManager.SendNotification(TrumpNotes.OPEN_TRUMPINFOPANEL, self.data.info)
    end
end

function TrumpItem:UpdateItem(data)
    --    if (data == nil) then return end
    self.data = data
    self._imgQuaility.color = ColorDataManager.GetColorByQuality(0)
    if (PlayerManager.GetPlayerInfo().level >= data.reqLev) then
        self._goLock:SetActive(false)
        if (data.info == nil) then
            self._txtReqLevel.text = TrumpItem.canDressDes
            self._txtLevel.text = ""
            self._imgIcon.spriteName = ""
            self._goDress:SetActive(false)
            self._trsLvBg:SetActive(false)
        else
            self._goDress:SetActive(self.data.info.id == TrumpManager.GetMainTrumpId())
            ProductManager.SetIconSprite(self._imgIcon, data.info.configData.icon_id)
            self._txtLevel.text = tostring(data.info.lev)
            self._imgQuaility.color = ColorDataManager.GetColorByQuality(self.data.info.configData.quality)
            self._txtReqLevel.text = ""
            self._trsLvBg:SetActive(true)
        end
    else
        self._trsLvBg:SetActive(false)
        self._txtLevel.text = ""
        self._txtReqLevel.text = data.reqLev .. TrumpItem.levelDes
        self._goLock:SetActive(true)
        self._goDress:SetActive(false)
        self._imgIcon.spriteName = ""
        self._imgQuaility.color = ColorDataManager.GetColorByQuality(0)
    end
end

function TrumpItem:_Dispose()
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onBtnItemClick = nil;
end
 
