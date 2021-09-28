--[[
	文件名：GuildManaLayer.lua
	描述：帮派管理选择页面
	创建人：chenzhong
	创建时间：2016.6.7
--]]

local GuildManaLayer = class("GuildManaLayer", function(params)
    return cc.LayerColor:create(cc.c4b(0, 0, 0, 180))
end)

function GuildManaLayer:ctor()
    -- 屏蔽下层点击事件
    ui.registerSwallowTouch({node = self})

    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 初始化界面
    self:initUI()

    -- 创建底部导航和顶部玩家信息部分
    local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(tempLayer)
end

function GuildManaLayer:initUI()
    --背景
    local ghBgSprite = ui.newSprite("bp_33.jpg")
    ghBgSprite:setPosition(cc.p(320, 568))
    self.mParentLayer:addChild(ghBgSprite)

    --关闭按钮
    local cancelBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(600, 1005),
        clickAction = function (sender)
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(cancelBtn)
    
    -- 创建功能按钮
    local buttonList = {
        --建筑升级
        [1] = {
            normalImage = "bp_30.png",
            position = cc.p(330, 280),
            guildAuthType = GuildAuth.eBuildingUp,
            clickAction = function ()
                if not GuildObj:havePost(GuildAuth.eBuildingUp) then
                    ui.showFlashView({text = TR("你没有进入的权限")})
                    return
                end

                LayerManager.addLayer({
                    name = "guild.GuildBuildLvUpLayer",
                })

            end
        },
        --人员审批
        [2] = {
            normalImage = "bp_31.png",
            position = cc.p(520, 515),
            guildAuthType = GuildAuth.eMemberIn,
            clickAction = function ()
                if not GuildObj:havePost(GuildAuth.eMemberIn) then
                    ui.showFlashView({text = TR("你没有进入的权限")})
                    return
                end

                LayerManager.addLayer({
                    name = "guild.GuildExamineLayer",
                })
            end
        },
        --职位任免
        [3] = {
            normalImage = "bp_32.png",
            position = cc.p(330, 755),
            guildAuthType = GuildAuth.ePostChange,
            clickAction = function ()
                -- if not GuildObj:havePost(GuildAuth.ePostChange) then
                --     ui.showFlashView({text = TR("你没有进入的权限")})
                --     return
                -- end
                LayerManager.addLayer({
                    name = "guild.GuildDutyLayer",
                })
            end
        },

        --宣言修改
        [4] = {
            normalImage = "bp_29.png",
            position = cc.p(140, 515),
            guildAuthType = GuildAuth.eReleaseDeclaration,
            clickAction = function ()
                if not GuildObj:havePost(GuildAuth.eReleaseDeclaration) then
                    ui.showFlashView({text = TR("你没有进入的权限")})
                    return
                end

                LayerManager.addLayer({
                    name = "guild.GuildDeclarationLayer",
                    zOrder = Enums.ZOrderType.ePopLayer,
                    cleanUp = false
                })
            end
        },
    }
    for _, btnInfo in ipairs(buttonList) do
        local tempBtn = ui.newButton(btnInfo)
        tempBtn:setAnchorPoint(cc.p(0.5, 0))
        self.mParentLayer:addChild(tempBtn)

        -- 人事管理和建筑升级的小红点
        local redTable = {[GuildAuth.eMemberIn] = Enums.ClientRedDot.eGuildMemberIn,
            [GuildAuth.eBuildingUp] = Enums.ClientRedDot.eGuildBuildingUp,
            [GuildAuth.ePostChange] = Enums.ClientRedDot.eGuildPostChange,}
        local curModuleId = redTable[btnInfo.guildAuthType]
        -- 处理小红函数
        if curModuleId then
            local function dealRedDotVisible(redDotSprite)
                redDotSprite:setVisible(RedDotInfoObj:isValid(curModuleId))
            end
            ui.createAutoBubble({refreshFunc = dealRedDotVisible, position = cc.p(0.8, 0.9), eventName = EventsName.eGuildHomeAll, parent = tempBtn})
        end
    end
end

return GuildManaLayer