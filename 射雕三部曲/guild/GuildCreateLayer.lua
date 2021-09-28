--[[
    文件名：GuildCreateLayer
    描述：创建帮派页面
    创建人: chenzhong
    创建时间: 2017.03.13
-- ]]

local GuildCreateLayer = class("GuildCreateLayer",function()
	return display.newLayer()
end)

--[[
]]
function GuildCreateLayer:ctor()
	-- 初始化页面控件
    self:initUI()
end

-- 初始化页面控件
function GuildCreateLayer:initUI()
    local bgSize = cc.size(560, 375)
    -- 添加弹出框层
    local bgLayer = require("commonLayer.PopBgLayer").new({
        title = TR("创建帮派"),
        bgSize = bgSize,
        closeImg = "c_29.png",
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(bgLayer)
    self.mBgSprite = bgLayer.mBgSprite

    --创建帮派条件
    local ruleLabel = ui.newLabel({
        text = TR("创建帮派条件:"),
        color = Enums.Color.eBrown,
    })
    ruleLabel:setAnchorPoint(cc.p(0, 0.5))
    ruleLabel:setPosition(75, 200)
    self.mBgSprite:addChild(ruleLabel)

    -- 创建需要的材料
    local useList = Utility.analysisStrResList(GuildConfig.items[1].createGuildUseResource)
    for index, item in ipairs(useList) do
        -- 需要消耗的代币
        local tempNode = ui.createDaibiView({
            resourceTypeSub = item.resourceTypeSub,
            goodsModelId = item.modelId,
            fontColor = Enums.Color.eNormalYellow,
            number = item.num,
        })
        local anchorX = index ~= 1 and 0 or 1
        tempNode:setAnchorPoint(cc.p(anchorX, 0.5))
        tempNode:setPosition(300 + (index - 1) * 50, 200)
        self.mBgSprite:addChild(tempNode)
    end

    -- “和”文本
    local orLabel = ui.newLabel({
        text = TR("和"),
        color = Enums.Color.eBrown,
    })
    orLabel:setAnchorPoint(cc.p(0.5, 0.5))
    orLabel:setPosition(320, 200)
    self.mBgSprite:addChild(orLabel)

    -- 势力图标
    local forceId = PlayerAttrObj:getPlayerAttrByName("JianghuKillForceId")
    local forceTexture = Enums.JHKBigPic[forceId]
    if forceTexture then
        local forceSprite = ui.newSprite(forceTexture)
        forceSprite:setPosition(120, 270)
        self.mBgSprite:addChild(forceSprite)
    end
    -- 提示
    local hintLabel = ui.newLabel({
            text = TR("将创建一个%s帮派，只有%s玩家才能加入", Enums.JHKCampName[forceId], Enums.JHKCampName[forceId]),
            color = cc.c3b(0x46, 0x22, 0x0d),
            dimensions = cc.size(250, 0)
        })
    hintLabel:setAnchorPoint(cc.p(0, 1))
    hintLabel:setPosition(180, 295)
    self.mBgSprite:addChild(hintLabel)

    -- 帮派名字
    local nameEdtbox = ui.newEditBox({
        image = "c_38.png",
        size = cc.size(400, 50),
        fontColor = cc.c3b(0x46, 0x22, 0x0d),
        maxLength = 8,
    })
    nameEdtbox:setPosition(bgSize.width / 2, 140)
    nameEdtbox:setPlaceHolder(TR("请输入帮派名字"))
    self.mBgSprite:addChild(nameEdtbox)

    --确定按钮
    local okBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("确定"),
        outlineColor = Enums.Color.eBlack,
        clickAction = function ()
            -- 检查帮派名称的有效性
            local guildName = string.trim(nameEdtbox:getText()) --帮派名
            if not guildName or guildName == "" then
                ui.showFlashView({text = TR("请输入帮派名字")})
                return
            elseif string.utf8len(guildName) > 8 then
                ui.showFlashView({text = TR("帮派名字长度不能超过8位")})
                return
            end

            -- 检查消耗是否足够
            for index, item in ipairs(useList) do
                if not Utility.isResourceEnough(item.resourceTypeSub, item.num, true) then
                    return
                end
            end

            -- 创建帮派数据请求
            self:requireCreateGuild(guildName)
        end
    })
    okBtn:setPosition(bgSize.width / 2, 70)
    self.mBgSprite:addChild(okBtn)
end

-- ========================= 网络请求相关函数 ===========================
-- 创建帮派数据请求
function GuildCreateLayer:requireCreateGuild(guildName)
    local guildDec = TR("帮主很懒,什么也没留下")
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Guild",
        methodName = "CreateGuild",
        svrMethodData = {guildName, guildDec},
        callbackNode = self,
        callback = function(response)
            if response.Status ~= 0 then
                return
            end
            local value = response.Value

            GuildObj:updateGuildAvatar({Id = value.Id, Name = value.Name})
            -- 跳转到帮派主页
            LayerManager.addLayer({
                name = "guild.GuildHomeLayer",
                isRootLayer = true,
            })
        end,
    })
end

return GuildCreateLayer