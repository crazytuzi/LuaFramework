--[[
    文件名：RegisterLayer.lua
    描述：账号注册界面
    创建人：liaoyuanang
    创建时间：2016.4.14
-- ]]

local RegisterLayer = class("RegisterLayer", function(params)
    return display.newLayer()
end)

function RegisterLayer:ctor(params)
    -- 屏蔽下层事件
    ui.registerSwallowTouch({node=self})
    -- 创建背景layer
    local tempLayer = require("login.LoginBgLayer"):create()
    self:addChild(tempLayer)

    -- 创建该页面的父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 初始化页面控件
    self:initUI()
end

-- 初始化页面控件
function RegisterLayer:initUI()
    -- 创建 label 和 editBox
    local function createLabelAndEditbox(labelStr, editHint, posY, isPassword)
        -- 输入框前的提示label
        local tempLabel = ui.newLabel({
            text = labelStr,
            size = 24,
            color = Enums.Color.eWhite,
            align = cc.TEXT_ALIGNMENT_RIGHT
        })
        tempLabel:setAnchorPoint(cc.p(1, 0.5))
        tempLabel:setPosition(140, posY)
        self.mParentLayer:addChild(tempLabel)
        -- 输入框
        local tempEdit = ui.newEditBox({
            image = "dl_02.png",
            size = cc.size(420, 56),
            fontSize = 24,
            fontColor = Enums.Color.eNormalGreen,
        })
        if isPassword then
            tempEdit:setInputFlag(0)
        end
        tempEdit:setAnchorPoint(cc.p(0, 0.5))
        tempEdit:setPosition(cc.p(150, posY))
        tempEdit:setPlaceHolder(editHint)
        self.mParentLayer:addChild(tempEdit)

        return tempEdit
    end

    -- 帐号
    self.mAccountEdit = createLabelAndEditbox(TR("帐号"), TR("帐号"), 320)
    -- 密码
    self.mPasswordEdit = createLabelAndEditbox(TR("密码"), TR("请输入密码"), 240, true)
    -- 确认密码
    self.mScendPasswordEdit = createLabelAndEditbox(TR("确认密码"), TR("再次输入密码确认"), 160, true)

    --创建确认按钮
    local tempBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("注册"),
        position = cc.p(420, 80),
        fontSize = 24,
        clickAction = function()
            local accountStr = self.mAccountEdit:getText()
            if not string.isEmail(accountStr) then
                ui.showFlashView(TR("邮箱格式不正确"))
                return
            end

            local passwordStr = self.mPasswordEdit:getText()
            if not string.isValided(passwordStr) then
                ui.showFlashView(TR("密码格式不正确"))
                return
            end

            local secendPasswordStr = self.mScendPasswordEdit:getText()
            if passwordStr ~= secendPasswordStr then
                ui.showFlashView(TR("两次密码不一致"))
                return
            end

            self:requestRegisterAccount(accountStr, passwordStr)
        end,
    })
    self.mParentLayer:addChild(tempBtn)

    -- 取消按钮
    tempBtn = ui.newButton({
        normalImage = "c_28.png",
        text=TR("取消"),
        fontSize = 24,
        position=cc.p(220, 80),
        clickAction=function ()
            LayerManager.removeLayer(self)
        end,
    })
    self.mParentLayer:addChild(tempBtn)
end

--- ==================== 服务器数据请求相关 =======================
-- 注册账户服务器帐号
function RegisterLayer:requestRegisterAccount(account, password)
    local tempVerify = string.md5Content(password)
    HttpClient:request({
        svrType = HttpSvrType.eMqkkAccount,
        urlName = "Register",
        svrMethodData = {
            email = account,
            pwd = tempVerify,
            udid = IPlatform:getInstance():getDeviceUUID()
        },
        useUnzip = false,
        callbackNode = self,
        callback = function(response)
            if response.State ~= 1 then
                return
            end
            if not Utility.valueIsEmpty(response.Result.UserID) then
                -- 保存账号信息
                LocalData:saveLoginAccount({account = account, verify = tempVerify})

                local tempParams = {
                    loginInfo = json.encode({sessionId = response.Result.UserID}),
                }
                LayerManager.addLayer({name = "login.StartGameLayer", data = tempParams})
            end
        end,
    })
end

return RegisterLayer
