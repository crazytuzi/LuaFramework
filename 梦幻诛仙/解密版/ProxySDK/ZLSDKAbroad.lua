local Lplus = require("Lplus")
local ECUniSDk = require("ProxySDK.ECUniSDK")
local ECGame = Lplus.ForwardDeclare("ECGame")
local ZLSDKAbroad = Lplus.Extend(ECUniSDk, "ZLSDKAbroad")
local def = ZLSDKAbroad.define
def.field("table").m_coinInfo = nil
def.const("string").IMGURL = "http://mhzx.zloong.com/bftu/ShareXM.png"
def.const("string").LINKURL = "https://www.facebook.com/fantasyzhuxianmobile/"
def.override("table", "table").onOtherAction = function(self, actionName, param)
  if actionName == "onNpcInfo" then
    self:OnNpcInfo(param)
  end
end
def.override("table").Share = function(self, paramTable)
  warn("ZLSDKAbroad.Share", pretty(paramTable))
  local title = paramTable.title
  local desc = paramTable.desc
  local imgPath = paramTable.imgPath
  local callback = paramTable.callback
  if imgPath then
    if platform == Platform.ios then
      UniSDK.action("share", {
        shareType = "picture",
        platform = "facebook",
        picture_path = imgPath,
        icon_path = "",
        appname = "",
        title = title,
        description = desc,
        scene = ""
      })
    elseif platform == Platform.android then
      local uri = ZLUtil.getUriFromFile(imgPath)
      UniSDK.action("SharePicture", {
        platform = "facebook",
        picture_path = uri,
        title = title,
        describe = desc,
        linkUrl = ZLSDKAbroad.LINKURL
      })
    end
  elseif platform == Platform.ios then
    UniSDK.action("share", {
      shareType = "text",
      platform = "facebook",
      icon_path = ZLSDKAbroad.LINKURL,
      appname = "",
      title = title,
      description = desc,
      linkUrl = ZLSDKAbroad.LINKURL
    })
  elseif platform == Platform.android then
    UniSDK.action("share2Facebook", {
      imageUrl = ZLSDKAbroad.IMGURL,
      title = title,
      description = desc,
      targetUrl = ZLSDKAbroad.LINKURL
    })
  end
  if callback then
    callback(true)
  end
end
def.method("string").RequestCoinInfo = function(self, productId)
  if platform == Platform.ios then
    warn("ECUniSDK RequestCoinInfo", productId)
    if productId == "" then
      if self.m_coinInfo and self.m_coinInfo.productId then
        UniSDK.action("npcInfo", {
          productId = self.m_coinInfo.productId
        })
      end
    else
      UniSDK.action("npcInfo", {productId = productId})
      if self.m_coinInfo == nil then
        self.m_coinInfo = {}
      end
      self.m_coinInfo.productId = productId
    end
  end
end
def.method("table").OnNpcInfo = function(self, param)
  warn("OnNpcInfo:", pretty(param), pretty(self.m_coinInfo))
  if self.m_coinInfo and self.m_coinInfo.productId == param.npcId then
    self.m_coinInfo.info = param.dpsType
  end
end
def.method().UserCenter = function(self)
  if platform == Platform.ios then
    UniSDK.action("userCenter", {
      url = "/account/get_service_path"
    })
  elseif platform == Platform.android then
    UniSDK.action("showUserCenter", {})
  end
end
ZLSDKAbroad.Commit()
return ZLSDKAbroad
