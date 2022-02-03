-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      按钮频道按钮tips
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
ShareTips = ShareTips or BaseClass()

function ShareTips:__init(delay,type)
    self.delay = delay or 3
    self.type  = type or 1
    self.btn_list = {}
    self:createRootWnd()
end

function ShareTips:createRootWnd()
    self:LoadLayoutFinish()
    self:registerCallBack()
end


function ShareTips:closeCallBack()

end


function ShareTips:LoadLayoutFinish()
    self.screen_bg = ccui.Layout:create()
    self.screen_bg:setAnchorPoint(cc.p(0, 0))
    self.screen_bg:setContentSize(cc.size(SCREEN_WIDTH, display.height))
    self.screen_bg:setTouchEnabled(true)
    self.screen_bg:setSwallowTouches(false)

    self.root_wnd = ccui.Widget:create()
    self.root_wnd:setTouchEnabled(true)
    self.root_wnd:setAnchorPoint(cc.p(0, 0))
    self.root_wnd:setPosition(cc.p(0, 0))
    self.screen_bg:addChild(self.root_wnd)

    self.background = ccui.ImageView:create(PathTool.getResFrame("common", "common_1056"), LOADTEXT_TYPE_PLIST)
    self.background:setScale9Enabled(true)
    self.background:setCapInsets(cc.rect(59, 39,5,5))
    self.background:setAnchorPoint(cc.p(0, 0))
    self.root_wnd:addChild(self.background)
end


function ShareTips:registerCallBack()
    self.screen_bg:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.began then
            TipsManager:getInstance():hideTips()
        end
    end)
end


function ShareTips:setPosition(x, y)
    self.root_wnd:setAnchorPoint(cc.p(0, 1))
    self.root_wnd:setPosition(cc.p(x, y))
end

function ShareTips:addToParent(parent, zOrder)
    self.parent_wnd = parent
    if not tolua.isnull(self.root_wnd) then
        self.root_wnd:removeFromParent()
    end
    self.parent_wnd:addChild(self.root_wnd, zOrder)
end

function ShareTips:setPos(x, y)
    self.root_wnd:setPosition(cc.p(x, y))
end

function ShareTips:getContentSize()
    return self.root_wnd:getContentSize()
end


function ShareTips:getScreenBg()
    return self.screen_bg
end

function ShareTips:showTips(data,size)
    local size = size
    if data then
        self.root_wnd:setContentSize(size)
        self.background:setContentSize(size)
        for i, v in ipairs(data) do
            if not self.btn_list[i] then
                local btn = createButton(self.background, v.label, 0, 0, cc.size(v.width,v.height),v.select_path,22)
                btn.data = v
                btn:addTouchEventListener(function(sender, event_type)
                    if event_type == ccui.TouchEventType.ended then
                        if i == 1 then
                            BattleController:getInstance():on20034(v.replay_id, ChatConst.Channel.World,v.name, BattleConst.ShareType.SharePlunder)
                        elseif i == 2 then -- 公会
                            local role_vo = RoleController:getInstance():getRoleVo()
                            if role_vo and role_vo.gid ~= 0 and role_vo.gsrv_id ~= "" then
                            BattleController:getInstance():on20034(v.replay_id, ChatConst.Channel.Gang, v.name, BattleConst.ShareType.SharePlunder)
                            else
                                message(TI18N("暂无公会"))
                            end              
                        end
                        TipsManager:getInstance():hideTips()
                    end
                end)
                local start_y = self.background:getContentSize().height - v.height / 2 - 20
                btn:setPosition(self.background:getContentSize().width/2, start_y- ((i-1) * (v.height + 15)))
                self.btn_list[i] = btn
                --btn:setRichText(TI18N("<div fontColor=#ffffff fontsize=24 outline=2,#C45A14>结算并重置</div>"))
            end
        end
        --self.tabBar:setTabArray(data)
    end
end

function ShareTips:setAnchorPoint(pos)
    self.screen_bg:setAnchorPoint(pos)
end

function ShareTips:open()
    local parent = ViewManager:getInstance():getLayerByTag(ViewMgrTag.MSG_TAG)
    parent:addChild(self.screen_bg)
    doStopAllActions(self.screen_bg)
end


function ShareTips:close()
    if self.screen_bg then
        doStopAllActions(self.screen_bg)
        self.screen_bg:removeFromParent()
        self.screen_bg = nil
    end
end