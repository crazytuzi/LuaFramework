--[[ 问卷调查 ]]--
local myQuestion = class("myQuestion", function() return cc.Layer:create() end )

function myQuestion:ctor(  )
    local bg = createSprite(self, "res/common/bg/bg56.png", cc.p(display.cx, display.cy))
    createSprite(bg,"res/layers/activity/cell/question/title.png", cc.p(500, 573))
    local closeFun = function()
        removeFromParent(self)
    end
    createTouchItem(bg,"res/component/button/X.png",cc.p(920,573),closeFun)

    local url = self:initUrl()

    if Device_target ~= cc.PLATFORM_OS_WINDOWS then
        self._webView = ccexp.WebView:create()
        self._webView:setPosition(67, 60)
        self._webView:setContentSize(824, 485)
        self._webView:loadURL(url)
        self._webView:setScalesPageToFit(true)
        self._webView:setAnchorPoint(cc.p(0,0))

        bg:addChild(self._webView, 1000)
    end
    SwallowTouches(self)
end

function myQuestion:initUrl()
-- AreaID                       区id
-- AreaServer               区服中文名
-- Channel                     渠道
-- GameID                    游戏id
-- GroupID                    服（组）id
-- Level                          等级
-- Platform                   平台
-- RoleName                角色名
-- Sign                            签名
-- TimeStamp               时间戳
-- UserID                       玩家账号
--PageIndex 1
-- 签名Sign的运算方法（秘钥是   516W$sa2f32@ ）：
-- MD5：     Level + TimeStamp + UserID + 秘钥后，经过32位加密后得出
    local MRoleStruct = require("src/layers/role/RoleStruct")

    local AreaID = userInfo.serverId
    local AreaServer = userInfo.serverName
    local Channel = g_Channel_tab.adChannel
    local GameID = 1009
    local Level = MRoleStruct:getAttr(ROLE_LEVEL)
    local Platform = cc.Application:getInstance():getTargetPlatform()
    local RoleName = MRoleStruct:getAttr(ROLE_NAME)
    local TimeStamp = os.time()
    local UserID = userInfo.userName
    local PageIndex = 1
    local Sign = getMD5("" .. Level .. TimeStamp .. UserID .. "516W$sa2f32@")

    local urlStr = ""
    urlStr = urlStr .. "AreaID=".. string.urlencode("" .. AreaID)
    urlStr = urlStr .. "&AreaServer=".. string.urlencode("" .. AreaServer) 
    urlStr = urlStr .. "&Channel="..string.urlencode("" .. Channel)
    urlStr = urlStr .. "&GameID="..string.urlencode("" .. GameID)
    urlStr = urlStr .. "&Level="..string.urlencode("" .. Level)
    urlStr = urlStr .. "&Platform="..string.urlencode("" .. Platform)
    urlStr = urlStr .. "&RoleName="..string.urlencode("" .. RoleName)
    urlStr = urlStr .. "&TimeStamp="..string.urlencode("" .. TimeStamp)
    urlStr = urlStr .. "&UserID="..string.urlencode("" .. UserID)
    urlStr = urlStr .. "&PageIndex="..string.urlencode("" .. PageIndex)
    urlStr = urlStr .. "&Sign="..string.urlencode("" .. Sign)

    --print("[myQuestion] .. key_value=" .. urlStr)
    --urlStr = string.urlencode(urlStr)
    urlStr = "http://act.chuanshi.sdo.com/Project/Suggest/CS/Default.aspx?" ..urlStr
    print("[myQuestion] .. urlStr=" .. urlStr)

    return urlStr
end

return myQuestion