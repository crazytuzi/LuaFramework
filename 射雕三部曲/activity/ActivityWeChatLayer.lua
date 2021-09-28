--[[
    文件名: ActivityWeChatLayer.lua
	描述: 微信关注页面, 模块Id为：ModuleSub.eExtraActivityWeChat
	效果图: 
	创建人: heguanghui
	创建时间: 2017.11.3
--]]

local ActivityWeChatLayer = class("ActivityWeChatLayer", function()
    return display.newLayer()
end)

--[[
-- 参数 params 中的各项为：
	{
	}
]]
function ActivityWeChatLayer:ctor(params)
	params = params or {}
	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer) 

	-- 初始化页面控件
	self:initUI()
end

-- 初始化页面控件
function ActivityWeChatLayer:initUI()
    -- 创建底部导航和顶部玩家信息部分
    self.mCommonLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(self.mCommonLayer)

    local partnerID = IPlatform:getInstance():getConfigItem("PartnerID")
    if partnerID == "163" or partnerID == "6666203" or partnerID == "6666204" or partnerID == "6666205" then
        self:createChannel163UI()
    else
        self:createNoramlUI()
    end

    --返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(594, 1050),
        clickAction = function(pSender)
            LayerManager.addLayer({
                name = "home.HomeLayer"
            })
        end
    })
    self.mCloseBtn = closeBtn
    self.mParentLayer:addChild(closeBtn)
end

-- 创建正常ui
function ActivityWeChatLayer:createNoramlUI()
    --背景图
    local bgSprite = ui.newSprite("jrhd_85.jpg")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)

    --添加文字按钮
    local showPos = cc.p(305, 413)
    local copyString = "sdsbqgame"
    local copyLabel = ui.newLabel({
        text = copyString,
        size = 24,
        color = cc.c3b(0xe3, 0x05, 0x00),
    })
    copyLabel:setPosition(showPos)
    self.mParentLayer:addChild(copyLabel)
    local copyBtn = ui.newButton({
        normalImage = "c_83.png",
        size = cc.size(118, 42),
        position = showPos,
        clickAction = function(pSender)
            IPlatform:getInstance():copyWords(copyString)
            MsgBoxLayer.addOKLayer(TR("复制成功"), TR("提示"))
        end
    })
    self.mParentLayer:addChild(copyBtn)
end

-- 创建163渠道ui
function ActivityWeChatLayer:createChannel163UI()
    --背景图
    local bgSprite = ui.newSprite("jrhd_85s.jpg")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)

    --添加文字按钮
    local showPos = cc.p(415, 413)
    local copyString = "cyjh39"
    local copyBtn = ui.newButton({
        normalImage = "c_83.png",
        size = cc.size(118, 42),
        position = showPos,
        clickAction = function(pSender)
            IPlatform:getInstance():copyWords(copyString)
            MsgBoxLayer.addOKLayer(TR("复制成功"), TR("提示"))
        end
    })
    self.mParentLayer:addChild(copyBtn)
end


return ActivityWeChatLayer

