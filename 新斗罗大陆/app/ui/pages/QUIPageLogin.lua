
local QUIPage = import(".QUIPage")
local QUIPageLogin = class("QUIPageLogin", QUIPage)

local QUIWidgetLoginAvata = import("..widgets.QUIWidgetLoginAvata")
local QSkeletonViewController = import("...controllers.QSkeletonViewController")
local QNotificationCenter = import("...controllers.QNotificationCenter")

function QUIPageLogin:ctor(options)
    local ccbFile = "ccb/Page_Login.ccbi"
    -- if CHANNEL_RES and CHANNEL_RES["envName"] and CHANNEL_RES["envName"] == "whjx_239" then
    --     ccbFile = "ccb/Page_whzxls.ccbi"
    -- end
    QUIPageLogin.super.ctor(self, ccbFile, callbacks, options)

    if options and options.showEffect == true then
        self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
        self._animationManager:runAnimationsForSequenceNamed("Default Timeline")
    end 
    local offsetY = -14 -- Y轴偏移适配
    self._ccbOwner.node_bj:setPosition(ccp(display.cx, display.cy + offsetY))
    self._ccbOwner.node_bj_2:setPosition(ccp(display.cx, display.cy + offsetY))
    self._ccbOwner.node_logo:setPositionX(display.cx+ display.ui_width * 0.82 * 0.5)
    -- self._ccbOwner.node_logo1:setPositionX(display.ui_width * 0.91)
    --self._ccbOwner.node_logo1:setPositionX(display.cx)

    local logo_path
    if CHANNEL_RES and CHANNEL_RES["logoPath"] then
        self._ccbOwner.node_logo:setVisible(false)
        logo_path = CHANNEL_RES["logoPath"]
    end
    if CHANNEL_RES and CHANNEL_RES["envName"] and CHANNEL_RES["envName"] == "dljxol_238" then
        self._ccbOwner.node_logo:setVisible(false)
        logo_path = "ui/Login/dljx.png"
        local sprite = CCSprite:create(logo_path)
        if sprite then
            local scale = 0.88
            sprite:setScale(scale)
            local size = sprite:getContentSize()
            self._ccbOwner.node_logo1:addChild(sprite)
            self._ccbOwner.node_logo1:setVisible(true)
        end
        logo_path = nil
    end
    if CHANNEL_RES and CHANNEL_RES["envName"] and CHANNEL_RES["envName"] == "whjx_239" and device.platform == "ios" then
        self._ccbOwner.node_logo:setVisible(false)
        logo_path = "ui/Login/dlxls.png"
        local sprite = CCSprite:create(logo_path)
        if sprite then
            local scale = 0.88
            sprite:setScale(scale)
            local size = sprite:getContentSize()
            self._ccbOwner.node_logo1:addChild(sprite)
            self._ccbOwner.node_logo1:setVisible(true)
        end
        logo_path = nil
    end
    if logo_path and #logo_path > 0 then
        local sprite = CCSprite:create(logo_path)
        if sprite then
            local scale = 0.68
            sprite:setScale(scale)
            local size = sprite:getContentSize()
            self._ccbOwner.node_logo1:addChild(sprite)
            self._ccbOwner.node_logo1:setVisible(true)
        end
    end

    --登录界面背景定制
    if self._ccbOwner.node_center then
        local pagePath = nil
        if CHANNEL_RES and CHANNEL_RES["loginPage"] and #CHANNEL_RES["loginPage"] > 0 then
            pagePath = CHANNEL_RES["loginPage"]
        end
        if CHANNEL_RES and CHANNEL_RES["envName"] and CHANNEL_RES["envName"] == "dljxol_238" and device.platform == "ios" then
            pagePath = "res/map/login_tsdcz.jpg"
        end
        -- if CHANNEL_RES and CHANNEL_RES["envName"] and CHANNEL_RES["envName"] == "whjx_239" then
        --     pagePath = nil
        -- end
        if pagePath then
            self._ccbOwner.tf_1:setVisible(false)
            self._ccbOwner.tf_2:setVisible(false)
            self._ccbOwner.bj:setTexture(CCTextureCache:sharedTextureCache():addImage(pagePath))
            self._ccbOwner.node_bj_2:setVisible(false)
        end
    end

    --是否显示动画的人物
    if (CHANNEL_RES and CHANNEL_RES["envName"] and CHANNEL_RES["envName"] == "whjx_239") then
        self._avataView = QUIWidgetLoginAvata.new()
        self._ccbOwner.node_center:removeAllChildren()
        self._ccbOwner.node_center:addChild(self._avataView)
    end

    if CHANNEL_RES and CHANNEL_RES["hideYun"] == true then
        self._ccbOwner.yunceng:setVisible(false)
    end
    self:addHeroActor()
    --  --是否显示著作权
    -- if CHANNEL_RES and CHANNEL_RES["loginPage"] then
    --     self._ccbOwner.tf_1:setVisible(false)
    --     self._ccbOwner.tf_2:setVisible(false)
    -- end

    -- --登录下方的著作权定制
    -- local tfs
    -- if CHANNEL_RES and CHANNEL_RES["copyright"] then
    --     tfs = string.split(CHANNEL_RES["copyright"],"||")
    --     if nil ~= tfs and #tfs == 4 then
    --         self._ccbOwner.tf_1:setString(tfs[1])
    --         self._ccbOwner.tf_2:setString(tfs[2])
    --     end
    -- end

    -- --是否显示logo
    -- if CHANNEL_RES and CHANNEL_RES["showLogo"] == false then
    --     self._ccbOwner.node_logo:setVisible(false)
    -- end
end

function QUIPageLogin:viewDidAppear()
    QUIPageLogin.super.viewDidAppear(self)

    QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_CHANGE_GLVIEW_SIZE, self._reloadCCB, self)

end

function QUIPageLogin:viewDidDisappear()
    QUIPageLogin.super.viewDidDisappear(self)

    QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_CHANGE_GLVIEW_SIZE, self._reloadCCB, self)

end

function QUIPageLogin:_reloadCCB()
    self._ccbOwner.node_bj:setPositionX(display.width/2)
    self._ccbOwner.node_bj:setPositionY(display.height/2)
    self._ccbOwner.node_bj_2:setPositionX(display.width/2)
    self._ccbOwner.node_bj_2:setPositionY(display.height/2)
    self._ccbOwner.node_center:setPositionX(display.width/2)
    self._ccbOwner.node_center:setPositionY(display.height/2)
    self._ccbOwner.node_logo:setPositionX(display.ui_width * 0.91)
    self._ccbOwner.node_logo:setPositionY(display.ui_height*0.85)
    self._ccbOwner.node_logo1:setPositionX(display.ui_width*0.5)
    self._ccbOwner.node_logo1:setPositionY(display.ui_height*0.68)
end


function QUIPageLogin:addHeroActor()

    -- local xiaowu_actor = QSkeletonViewController:sharedSkeletonViewController():createSkeletonActorWithFile("dengluxiaowu", nil, false)
    -- self._ccbOwner.node_xiaowu:addChild(xiaowu_actor)
    -- xiaowu_actor:playAnimation(ANIMATION.STAND, true)

    -- local tangsan_actor = QSkeletonViewController:sharedSkeletonViewController():createSkeletonActorWithFile("denglutangsan", nil, false)
    -- self._ccbOwner.node_tangsan:addChild(tangsan_actor)
    -- tangsan_actor:playAnimation(ANIMATION.STAND, true)


    local qiuridenglu_actor = QSkeletonViewController:sharedSkeletonViewController():createSkeletonActorWithFile("qiuridenglujiemian", nil, false)
    self._ccbOwner.node_qiuridenglu:addChild(qiuridenglu_actor)
    qiuridenglu_actor:playAnimation(ANIMATION.STAND, true)
end


return QUIPageLogin