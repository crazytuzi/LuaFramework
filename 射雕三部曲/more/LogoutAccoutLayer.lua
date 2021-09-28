--[[
	文件名：LogoutAccoutLayer.lua
	描述：更多－－切换帐号
	创建人：yanxingrui
	创建时间： 2016.6.3
    修改人：wukun
    修改时间： 2016.9.14
--]]

local LogoutAccoutLayer = class("LogoutAccoutLayer", function(params)
	return display.newLayer()
end)

function LogoutAccoutLayer:ctor()
	-- 初始化页面
	self:initUI()
end

-- 初始化页面
function LogoutAccoutLayer:initUI()
    -- 添加弹出框层
    local bgLayer = require("commonLayer.PopBgLayer").new({
        title = TR("账号切换"),
        bgSize = cc.size(598, 474),
        closeImg = "c_29.png",
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(bgLayer)

    -- 保存弹窗控件信息
    self.mBgSprite = bgLayer.mBgSprite
    self.mBgSize = bgLayer.mBgSprite:getContentSize()

    --灰色背景图
    local darkBgSprite = ui.newScale9Sprite("c_17.png",cc.size(530, 300))
    darkBgSprite:setPosition(self.mBgSize.width / 2, self.mBgSize.height / 2 + 20)
    self.mBgSprite:addChild(darkBgSprite)

	-- 确认切换按钮
    local revertBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("确认切换"),
        position = cc.p(299, 65),
        clickAction = function(pSender)
        	-- 第三方登出
            IPlatform:getInstance():onExit()
            IPlatform:getInstance():logout()
        end
    })
    self.mBgSprite:addChild(revertBtn)

    self:showPlayerInfo()
end

-- 显示玩家的信息
function LogoutAccoutLayer:showPlayerInfo()
    local y = 370
    -- 显示服务器
    local serverName = TR("所在服务器: %s%s", "#8e4f09", Player:getSelectServer().ServerName)
    local serverLabel = ui.newLabel({
        text = serverName,
        size = 24,
        color = cc.c3b(0x46, 0x22, 0x0d),
    })
    serverLabel:setAnchorPoint(cc.p(0, 1))
    serverLabel:setPosition(70, y)
    self.mBgSprite:addChild(serverLabel)

    y = y - 50
    -- 显示玩家名称
    local userName = TR("玩家名字: %s%s", "#8e4f09", PlayerAttrObj:getPlayerAttrByName("PlayerName"))
    local nameLabel = ui.newLabel({
        text = userName,
        size = 24,
        color = cc.c3b(0x46, 0x22, 0x0d),
    })
    nameLabel:setAnchorPoint(cc.p(0, 1))
    nameLabel:setPosition(70, y)
    self.mBgSprite:addChild(nameLabel)

    y = y - 50
    -- 显示等级
    local userLv = TR("等级: %s%s", "#8e4f09", PlayerAttrObj:getPlayerAttrByName("Lv"))
    local lvLabel = ui.newLabel({
        text = userLv,
        size = 24,
        color = cc.c3b(0x46, 0x22, 0x0d),
    })
    lvLabel:setAnchorPoint(cc.p(0, 1))
    lvLabel:setPosition(70, y)
    self.mBgSprite:addChild(lvLabel)

    y = y - 50
    -- 显示体力值
    local userVIT = TR("体力值: %s%s", "#8e4f09", PlayerAttrObj:getPlayerAttrByName("VIT"))
    local VITLabel = ui.newLabel({
        text = userVIT,
        size = 24,
        color = cc.c3b(0x46, 0x22, 0x0d),
    })
    VITLabel:setAnchorPoint(cc.p(0, 1))
    VITLabel:setPosition(70, y)
    self.mBgSprite:addChild(VITLabel)

    y = y - 50
    -- 显示耐力值
    local userSTA = TR("耐力值: %s%s", "#8e4f09", PlayerAttrObj:getPlayerAttrByName("STA"))
    local STALabel = ui.newLabel({
        text = userSTA,
        size = 24,
        color = cc.c3b(0x46, 0x22, 0x0d),
    })
    STALabel:setAnchorPoint(cc.p(0, 1))
    STALabel:setPosition(70, y)
    self.mBgSprite:addChild(STALabel)
end

return LogoutAccoutLayer
