-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      用户协议
-- <br/> 2019年12月16日
-- --------------------------------------------------------------------
UserProtoPanel = UserProtoPanel or BaseClass(BaseView)

local controller = LoginController:getInstance()
-- local string_format = string.format
function UserProtoPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini   
    self.is_full_screen = false
    self.layout_name = "login/user_proto_panel"

    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("login", "login2"), type = ResourcesType.plist}
    }
    self.is_agree = false
end

function UserProtoPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    

    self.close_btn = self.main_container:getChildByName("close_btn")

    self.title = self.main_container:getChildByName("win_title")
    self.title:setString(TI18N("用户协议"))

    -- 6e6e6e
    -- 4273e1
    self.content_label = createRichLabel(28, cc.c3b(0x6e,0x6e,0x6e), cc.p(0, 1), cc.p(50, 445),34,nil, 580)
    self.main_container:addChild(self.content_label)
    -- self.content_label = self.main_container:getChildByName("content_label")
    self.content_label:setString(TI18N("　　在您使用本游戏前阅读并同意诗悦游戏用户协议和隐私保护指引。"))

    self.gotoe_label = createRichLabel(26, cc.c3b(0x6e,0x6e,0x6e), cc.p(0, 1), cc.p(50, 320),34,nil, 580)
    self.gotoe_label:setString(TI18N("　　请点击查看<div href=onclick_1 fontcolor=#4273e1>《诗悦用户游戏协议》</div>和<div href=onclick_2 fontcolor=#4273e1>《 隐私保护指引》</div> 您点击“确认并同意”即表示您已阅读并同意上述条款。"))
    self.gotoe_label:addTouchLinkListener(function(type, value, sender, pos)
        if value == "onclick_1" then
            --用户协议
            local value = "https://game.shiyuegame.com/article_detail_10_34.html"
            if IS_IOS_PLATFORM == true then
                sdkCallFunc("openSyW", value)
            else
                sdkCallFunc("openUrl", value)
            end
        elseif value == "onclick_2" then
            --隐私保护
            local value = "https://game.shiyuegame.com/article_detail_10_37.html"
            if IS_IOS_PLATFORM == true then
                sdkCallFunc("openSyW", value)
            else
                sdkCallFunc("openUrl", value)
            end
        end
    end, { "click", "href" })
    self.main_container:addChild(self.gotoe_label)


    self.comfirm_btn = self.main_container:getChildByName("comfirm_btn")
    self.comfirm_btn:getChildByName("label"):setString(TI18N("确认并同意"))
end

function UserProtoPanel:register_event()
    -- registerButtonEventListener(self.background, handler(self, self._onClickBtnClose) ,false, 1)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,true, 1)
    registerButtonEventListener(self.comfirm_btn, handler(self, self.onClickComfirmBtn) ,true, 2)
    registerButtonEventListener(self.cancel_btn, handler(self, self.onClickCancelBtn) ,true, 2)

    registerButtonEventListener(self.checkbox, function()
        local is_select = self.checkbox:isSelected()
        self.is_agree = is_select
    end, false, 1) 
end

--关闭
function UserProtoPanel:onClickBtnClose()
    controller:openUserProtoPanel(false)
end

--同意
function UserProtoPanel:onClickComfirmBtn()
    if self.callback then
        self.callback()
    end
    SysEnv:getInstance():set(SysEnv.keys.user_proto_agree, true, true)
    self:onClickBtnClose()
end

--拒绝
function UserProtoPanel:onClickCancelBtn()
    self:onClickBtnClose()
end

function UserProtoPanel:openRootWnd(callback)
   self.callback = callback
end


function UserProtoPanel:close_callback()
    controller:openUserProtoPanel(false)
end