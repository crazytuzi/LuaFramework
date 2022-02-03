--------------------------------------------
-- @Author  : lwc
-- @Date    : 2019年6月5日
-- @description    : 
        -- 显示解锁家园钥匙的弹窗
---------------------------------
HomeworldUnlockKeyPanel = HomeworldUnlockKeyPanel or BaseClass(BaseView)

local controller = HomeworldController:getInstance()

function HomeworldUnlockKeyPanel:__init()
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("levupgrade", "levupgrade"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("homeworld","homeworld_unlock_bg"), type = ResourcesType.single },
        {path = PathTool.getPlistImgForDownLoad("homeworld","homeworld_unlock_key"), type = ResourcesType.single },
    }
    self.is_csb_action = true
    self.layout_name = "homeworld/homeworld_unlock_key_panel"
end

function HomeworldUnlockKeyPanel:open_callback(  )
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    
    self.main_container = self.root_wnd:getChildByName("main_container")

    self.title_icon_effect = self.main_container:getChildByName("title_icon_effect")
    self.title_width = self.title_icon_effect:getContentSize().width
    self.title_height = self.title_icon_effect:getContentSize().height
    local title_sprite = self.main_container:getChildByName("title_sprite")
    local bg_res = PathTool.getPlistImgForDownLoad("homeworld", "homeworld_unlock_bg")
    if not self.load_title then
        self.load_title = loadSpriteTextureFromCDN(title_sprite, bg_res, ResourcesType.single, self.load_title)
    end

    self.item_node = self.main_container:getChildByName("item_node")
    -- self.honor_item = RoleHonorItem.new(1)
    -- self.item_node:addChild(self.honor_item)

    local icon = self.main_container:getChildByName("icon")
    self.icon = icon
    local bg_res = PathTool.getPlistImgForDownLoad("homeworld", "homeworld_unlock_key")
    if not self.load_icon then
        self.load_icon = loadSpriteTextureFromCDN(icon, bg_res, ResourcesType.single, self.load_icon)
    end

    self.name = self.main_container:getChildByName("name")

    self.share_btn = self.main_container:getChildByName("share_btn")
    self.share_btn:getChildByName("label"):setString(TI18N("前往家园"))
    --引导需要
    self.share_btn:setName("goto_home_world_btn")

    local size = self.main_container:getContentSize()
    self.desc = createRichLabel(18, cc.c3b(255,232,183), cc.p(0.5, 0.5), cc.p(size.width * 0.5, 195), nil, nil, 500)
    self.main_container:addChild(self.desc)
end

function HomeworldUnlockKeyPanel:register_event(  )
    registerButtonEventListener(self.background, function()
        -- controller:openHomeworldUnlockKeyPanel(false)
    end,false, 2)
    registerButtonEventListener(self.share_btn, function(param, sender) self:onShareBtn(sender)  end ,true, 1)
end

--跳转家园
function HomeworldUnlockKeyPanel:onShareBtn(sender)
    controller:openHomeworldUnlockKeyPanel(false)
end



function HomeworldUnlockKeyPanel:openRootWnd(setting)
    local setting = setting or {}

    playOtherSound("c_get")
    -- self.honor_item:setData({config = config})
    -- self.honor_item:setShowEffect(true)

    self.name:setString(TI18N("家园钥匙"))

    self:handleEffect(true)
    self.desc:setString(string.format("<div outline=2,#000000>这是某位贵族作为答谢留给我的一把门钥匙，\n我拥有了一个漂亮的家园！</div>"))

    self:runmoveAction(self.icon, 0.2)
    self:runmoveAction(self.name, 0.2)
    self:runmoveAction(self.desc, 0.3)
end

function HomeworldUnlockKeyPanel:runmoveAction(node, delay)
    if delay <= 0 then
        delay = 1
    end
    local x, y = node:getPosition()
    node:setPosition(x -300, y)
    node:setOpacity(0)

    local moveto = cc.EaseBackOut:create(cc.MoveTo:create(0.4,cc.p(x, y))) 
    local fadeIn = cc.FadeIn:create(0.4)
    local spawn_action = cc.Spawn:create(moveto, fadeIn)
    node:runAction(cc.Sequence:create(cc.DelayTime:create(delay), spawn_action))
end

function HomeworldUnlockKeyPanel:handleEffect(status)
    if status == false then
        if self.play_effect then
            self.play_effect:clearTracks()
            self.play_effect:removeFromParent()
            self.play_effect = nil
        end
    else
        if not tolua.isnull(self.title_icon_effect) and self.play_effect == nil then
            self.play_effect = createEffectSpine(PathTool.getEffectRes(1306), cc.p(self.title_width * 0.5, self.title_height * 0.5), cc.p(0.5, 0.5), true, PlayerAction.action)
            self.title_icon_effect:addChild(self.play_effect, 1)
            self.play_effect:setOpacity(0)
            local fadeIn = cc.FadeIn:create(0.5)
            self.play_effect:runAction(fadeIn)
        end
    end
end 

function HomeworldUnlockKeyPanel:close_callback()
    doStopAllActions(self.name)
    doStopAllActions(self.desc)
    self:handleEffect(false)
    if self.load_title then
        self.load_title:DeleteMe()
    end
    self.load_title = nil

    if self.load_icon then
        self.load_icon:DeleteMe()
    end
    self.load_icon = nil
    if self.honor_item then
        self.honor_item:DeleteMe()
        self.honor_item = nil
    end
    controller:openHomeworldUnlockKeyPanel(false)
end