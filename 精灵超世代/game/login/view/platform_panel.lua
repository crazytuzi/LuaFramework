--[[
   平台登录界面
--]]
PlatformPanel = class("PlatformPanel", function()
    return ccui.Widget:create()
end)

function PlatformPanel:ctor(parent, ctrl)
    self.ctrl = ctrl
    self.model = self.ctrl:getModel()
    self.data = self.model:getLoginData()
    self.ip = self.data.ip
    self.port = self.data.port

    self.size = parent and parent:getContentSize() or cc.size(SCREEN_WIDTH,SCREEN_HEIGHT)

    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setPosition(SCREEN_WIDTH/2,SCREEN_HEIGHT/2)
    self:setContentSize(self.size)
    self:configUI()
    self:setTouchEnabled(true)
end

function PlatformPanel:configUI()
    --self:initEvent()
    self.comfirm_btn = createButton(self,TI18N("登陆"), 360, 200, cc.size(162, 62), PathTool.getResFrame("common", "common_1017"), 24, Config.ColorData.data_color4[1])
    self.comfirm_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            self:initEvent()
        end
    end)
end

function PlatformPanel:initEvent()
    --平台的登录接口
    if MUTIL_LOGIN == 0 or not MUTIL_LOGIN then
        self:addTouchEventListener(function ( sender, eventType )
            if eventType == ccui.TouchEventType.ended then
                if PLATFORM_NAME ~= "icebird" and not IS_IOS_PLATFORM then
                    LoginPlatForm:getInstance():login()
                end
            end
        end)
        -- 没登录过的自动登录一次
        if not LoginPlatForm:getInstance():isLogin() then
            LoginPlatForm:getInstance():login()
        end
    else
        -- 登录过的自动登录
        if LoginPlatForm:getInstance():isLogin() then
            LoginPlatForm:getInstance():login()
        end
    end
end

-- 更新数据
function PlatformPanel:update()
end

-- 设置提示标语
function PlatformPanel:setMsg( str )
end

function PlatformPanel:effectHandler()
end

-- 销毁
function PlatformPanel:DeleteMe(  )
end
