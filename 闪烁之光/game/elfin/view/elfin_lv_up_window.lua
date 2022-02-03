--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-08-29 10:16:47
-- @description    : 
		-- 灵窝升级弹窗
---------------------------------
local _controller = ElfinController:getInstance()
local _model = _controller:getModel()

ElfinLvUpWindow = ElfinLvUpWindow or BaseClass(BaseView)

function ElfinLvUpWindow:__init()
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "elfin/elfin_up_lv_window"
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("elfin", "elfin"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("elfin","elfin_egg_icon"), type = ResourcesType.single },
		{path = PathTool.getPlistImgForDownLoad("elfin","elfin_bottom_bg"), type = ResourcesType.single },
	}
end

function ElfinLvUpWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container, 2)
	self.bottom_image = container:getChildByName("bottom_image")
	self.bottom_image:ignoreContentAdaptWithSize(true)
	self.bottom_image:loadTexture(PathTool.getPlistImgForDownLoad("elfin","elfin_bottom_bg"), LOADTEXT_TYPE)

	self.pos_node = container:getChildByName("pos_node")
	self.up_lv_txt = container:getChildByName("up_lv_txt")
end

function ElfinLvUpWindow:register_event(  )
	registerButtonEventListener(self.background, function (  )
		_controller:openElfinLvUpWindow(false)
	end, false, 2)
end

function ElfinLvUpWindow:openRootWnd(id)
	playOtherSound("c_get")
	
	if id then
		local hatch_cfg = Config.SpriteData.data_hatch_data[id]
		if hatch_cfg then
			self.up_lv_txt:setString(hatch_cfg.name)
		end
		
	end
	
	self:handleLightEffect(true)
	self:handleTitleEffect(true)
end

function ElfinLvUpWindow:handleTitleEffect( status )
	if status == false then
        if self.title_effect then
            self.title_effect:clearTracks()
            self.title_effect:removeFromParent()
            self.title_effect = nil
        end
    else
        if not tolua.isnull(self.pos_node) and self.title_effect == nil then
            self.title_effect = createEffectSpine(Config.EffectData.data_effect_info[1355], cc.p(0, -320), cc.p(0.5, 0.5), false, PlayerAction.action_1)
            self.pos_node:addChild(self.title_effect)
        end
    end
end

function ElfinLvUpWindow:handleLightEffect( status )
	if status == false then
        if self.light_effect then
            self.light_effect:clearTracks()
            self.light_effect:removeFromParent()
            self.light_effect = nil
        end
    else
        if not tolua.isnull(self.pos_node) and self.light_effect == nil then
            self.light_effect = createEffectSpine(Config.EffectData.data_effect_info[1355], cc.p(0, -320), cc.p(0.5, 0.5), true, PlayerAction.action_2)
            self.pos_node:addChild(self.light_effect)
        end
    end
end

function ElfinLvUpWindow:close_callback(  )
	self:handleTitleEffect(false)
	self:handleLightEffect(false)
	_controller:openElfinLvUpWindow(false)
end