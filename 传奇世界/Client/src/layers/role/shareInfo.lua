local shareInfo = class("shareInfo", function() return cc.Layer:create() end)

local pathCommon = "res/common/"
local MRoleStruct = require "src/layers/role/RoleStruct"

function shareInfo:ctor()

	local bg, closeBtn = createBgSprite(self, nil,nil,true)
    bg:setScale(1)
    bg:setPosition(cc.p((g_scrSize.width - 960)/2,(g_scrSize.height-640)/2))
    closeBtn:setVisible(false)   
	self.bg = bg

    --背景图片
    local tex = createSprite(self.bg, "res/share/bg.jpg", cc.p(480, 320), cc.p(0.5, 0.5))
    if g_scrSize.height > tex:getContentSize().height then
        tex:setScale(g_scrSize.height/tex:getContentSize().height)
    end

    --边线框
    createSprite(self, "res/share/line.png", cc.p(g_scrSize.width/2, 0), cc.p(0.5, 0.5))
    createSprite(self, "res/share/line.png", cc.p(g_scrSize.width/2, g_scrSize.height), cc.p(0.5, 0.5))

    --角色半身像
    local sex = MRoleStruct:getAttr(PLAYER_SEX)
    local school = MRoleStruct:getAttr(ROLE_SCHOOL)
    local idx = (sex-1)*3+school
    local rolePic = "res/share/"..idx..".png"
    if idx == 1 then
        createSprite(self.bg, rolePic, cc.p(630, 200), cc.p(0.5, 0.5))
    elseif idx == 2 then
        createSprite(self.bg, rolePic, cc.p(630, 190), cc.p(0.5, 0.5))
    elseif idx == 3 then
        createSprite(self.bg, rolePic, cc.p(630, 150), cc.p(0.5, 0.5))
    elseif idx == 4 then
        createSprite(self.bg, rolePic, cc.p(620, 220), cc.p(0.5, 0.5))
    elseif idx == 5 then
        createSprite(self.bg, rolePic, cc.p(620, 310), cc.p(0.5, 0.5))
    else
        createSprite(self.bg, rolePic, cc.p(640, 190), cc.p(0.5, 0.5))
    end

    local Infobg = createSprite(self.bg, "res/share/qizhi.png", cc.p(200, 370), cc.p(0.5, 0.5))

    --角色名称
    local m_name = MRoleStruct:getAttr(ROLE_NAME)
    createLabel(Infobg, m_name, cc.p(140, 290), nil, 24, true)

    --角色等级
    local level = MRoleStruct:getAttr(ROLE_LEVEL)
    local leveldesc = game.getStrByKey("level").."："..level
    createLabel(Infobg, leveldesc, cc.p(70, 238), cc.p(0, 0.5), 24, true)

    --角色职业
    local schoolDesc = game.getStrByKey("school").."："
    if school == 1 then
        schoolDesc = schoolDesc..game.getStrByKey("zhanshi")
    elseif school == 2 then
        schoolDesc = schoolDesc..game.getStrByKey("fashi")
    else
        schoolDesc = schoolDesc..game.getStrByKey("daoshi")
    end
    createLabel(Infobg, schoolDesc, cc.p(70, 186), cc.p(0, 0.5), 24, true)

    --角色战斗力
    local fightDesc = game.getStrByKey("combat_power").."："..MRoleStruct:getAttr(PLAYER_BATTLE)
    createLabel(Infobg, fightDesc, cc.p(70, 134), cc.p(0, 0.5), 24, true)

    --获取登录类型
    local isWxLogin = LoginUtils.isWXLogin()
    if Device_target == cc.PLATFORM_OS_WINDOWS then isWxLogin = true end

    local function afterCaptured(succeed, outputFile)
        self.retBtn:setVisible(true)
        self.shareBtn1:setVisible(true)
        self.shareBtn2:setVisible(true)
        
        -- 调用分享sdk   
        if isWxLogin then    --0 分享到微信会话， 1 分享到微信朋友圈
            sdkShareWeixinwithPhoto(self.shareType - 1, "", outputFile, 0,"","WECHAT_SNS_JUMP_APP")
        else       --1 分享到qq空间， 2 分享到qq会话
            sdkShareQQwithPhoto(self.shareType,outputFile, 0)
        end
    end

    --分享按钮
    local function shareFunc(targetID, node)        
         if isWxLogin then
             if not isWXInstalled() then
                 TIPS({type =1 ,str = game.getStrByKey("friend_share_fail_wx")})
                 return
             end
         else
             if not isQQInstalled() then
                 TIPS({type =1 ,str = game.getStrByKey("friend_share_fail_qq")})
                 return
             end
         end
         
         self.retBtn:setVisible(false)
         self.shareBtn1:setVisible(false)
         self.shareBtn2:setVisible(false)
         if node == self.shareBtn1 then
             self.shareType = 1   
         else
             self.shareType = 2
         end
         
         local fileName = getDownloadDir().."friendshare.jpg"
         cc.utils:captureScreen(afterCaptured, fileName)
     end

     local shareBtn1 = createMenuItem(self.bg, "res/component/button/3.png", cc.p(480, 60), shareFunc)
     local pos = getCenterPos(shareBtn1)
     if isWxLogin then
         createLabel(shareBtn1, game.getStrByKey("friend_share_wxfriend"), cc.p(pos.x, pos.y+2), nil, 22, true)
     else
         createLabel(shareBtn1, game.getStrByKey("friend_share_qqzone"), cc.p(pos.x, pos.y+2), nil, 22, true)
     end
     self.shareBtn1 = shareBtn1

     local shareBtn2 = createMenuItem(self.bg, "res/component/button/3.png", cc.p(780, 60), shareFunc)
     local pos2 = getCenterPos(shareBtn2)
     if isWxLogin then
         createLabel(shareBtn2, game.getStrByKey("friend_share_wxzone"), cc.p(pos2.x, pos2.y+2), nil, 22, true)
     else
         createLabel(shareBtn2, game.getStrByKey("friend_share_qqfriend"), cc.p(pos2.x, pos2.y+2), nil, 22, true)
     end
     self.shareBtn2 = shareBtn2

     --返回按钮
     local retBtn = createMenuItem(self.bg, "res/component/button/3.png", cc.p(180, 60), function () removeFromParent(self) end)
     local pos3 = getCenterPos(retBtn)
     createLabel(retBtn, game.getStrByKey("back"), cc.p(pos3.x, pos3.y+2), nil, 24, true)
     self.retBtn = retBtn

end

return shareInfo