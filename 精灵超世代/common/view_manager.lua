-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      当前项目的各个层级视图
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
ViewManager = ViewManager or BaseClass()

ViewMgrTag = {
    Scene_LAYER_TAG 		= 1, 	-- 神界冒险,以及主城所在的层级,以及剧情副本的层
    BATTLE_LAYER_TAG		= 2,	-- 战斗层
    EFFECT_TAG 				= 3, 	-- 战斗特效层
    UI_TAG 					= 4, 	-- 以及神界冒险的ui层,聊天缩略面板的层级
    WIN_TAG 				= 5, 	-- 主要存放打开的窗体
    TOP_TAG 				= 6, 	-- 主ui所在的层级,聊天窗体所在的层级
    DIALOGUE_TAG 			= 7, 	-- 提示性窗体的所在层,比如提示窗体,有黑幕这招主UI的都放在这里
    MSG_TAG 				= 8, 	-- tips相关的,剧情面板,引导
	RECONNECT_TAG			= 9, 	-- 断线重连的那一层
    DEBUG_TAG 				= 10, 	-- gm调试层
    LOADING_TAG 			= 11, 	-- 加载进度层
}

function ViewManager:addToLayerByTag( node, tag, zorder)
    local layer = self.layout_list[tag]
	if layer == nil then layer = self.ui_layer end

    if layer.zorder == nil then
    	layer.zorder = 0
    end
    layer.zorder = layer.zorder + 1
    layer:addChild(node, zorder or layer.zorder)
end

--==============================--
--desc:通过标签获取对应的层级
--time:2018-06-28 11:15:19
--@tag:
--@return 
--==============================--
function ViewManager:getLayerByTag( tag )
	if tag == nil then 
		return self.ui_layer 
	end
	local layout = self.layout_list[tag]
	if layout then
		return layout
	else 
		return self.ui_layer
	end
end

function ViewManager:getBaseLayout()
	return self.base_layout
end

--==============================--
--desc:设置某一层级的显示和操作状态
--time:2018-06-28 11:20:00
--@bool:
--@tag:
--@return 
--==============================--
function ViewManager:setLayerVisible( bool, tag )
	if tag == nil then return end
	local layer = self.layout_list[tag]
	if layer then
		layer:setVisible(bool)
		layer:setEnabled(bool)	
	else
		error(("没有相应层给你设置显示状态 ..")..tag)
	end
end

--==============================--
--desc:当前游戏的主scene
--time:2018-06-28 11:20:20
--@return 
--==============================--
function ViewManager:getMainScene()
	return self.main_scene
end

--==============================--
--desc:角色登录注册gm命令
--time:2018-06-28 11:21:20
--@return 
--==============================--
function ViewManager:initMainFunBar()
    -- if not SHOW_GM then return end
    GmCmd:add_gm_button(self.gm_layer)
end

--==============================--
--desc:初始化各个层级
--time:2018-06-28 11:21:35
--@return 
--==============================--
function ViewManager:getInstance()
	if not self.is_init then 
        self.current_layer = 0
        self.last_layer = 0
        self.total_layer = 0

        self.scene_layer = ccui.Widget:create()
        self.battle_layer = ccui.Widget:create()
        self.effect_layer = ccui.Widget:create()
        self.ui_layer = ccui.Widget:create()
        self.win_layer = ccui.Widget:create()
        self.top_layer = ccui.Widget:create()
        self.dialogue_layer = ccui.Widget:create()
        self.msg_layer = ccui.Widget:create()
		self.reconnect_layer = ccui.Widget:create()
        self.loading_layer = ccui.Widget:create()
        self.gm_layer = ccui.Layout:create()

        self.main_scene = cc.Scene:create()
		self.main_scene:retain()

		self.base_layout = ccui.Layout:create()
		self.base_layout:setContentSize(cc.size(SCREEN_WIDTH, SCREEN_HEIGHT))
		self.base_layout:setAnchorPoint(cc.p(0.5, 0.5))
		self.base_layout:setPosition(display.width*0.5, display.height*0.5)
		self.main_scene:addChild(self.base_layout)

        self.base_layout:addChild(self.scene_layer, ViewMgrTag.Scene_LAYER_TAG, ViewMgrTag.Scene_LAYER_TAG)
        self.base_layout:addChild(self.battle_layer, ViewMgrTag.BATTLE_LAYER_TAG, ViewMgrTag.BATTLE_LAYER_TAG)
        self.base_layout:addChild(self.effect_layer, ViewMgrTag.EFFECT_TAG, ViewMgrTag.EFFECT_TAG)
        self.base_layout:addChild(self.ui_layer, ViewMgrTag.UI_TAG, ViewMgrTag.UI_TAG)
        self.base_layout:addChild(self.win_layer, ViewMgrTag.WIN_TAG, ViewMgrTag.WIN_TAG)
        self.base_layout:addChild(self.top_layer, ViewMgrTag.TOP_TAG, ViewMgrTag.TOP_TAG)
        self.base_layout:addChild(self.dialogue_layer, ViewMgrTag.DIALOGUE_TAG, ViewMgrTag.DIALOGUE_TAG)
        self.base_layout:addChild(self.msg_layer, ViewMgrTag.MSG_TAG, ViewMgrTag.MSG_TAG)
        self.base_layout:addChild(self.reconnect_layer, ViewMgrTag.RECONNECT_TAG, ViewMgrTag.RECONNECT_TAG)
        self.base_layout:addChild(self.loading_layer, ViewMgrTag.LOADING_TAG, ViewMgrTag.LOADING_TAG)
        self.base_layout:addChild(self.gm_layer, ViewMgrTag.DEBUG_TAG, ViewMgrTag.DEBUG_TAG)

		self.layout_list = {}
		self.layout_list[ViewMgrTag.Scene_LAYER_TAG] = self.scene_layer
		self.layout_list[ViewMgrTag.BATTLE_LAYER_TAG] = self.battle_layer 
		self.layout_list[ViewMgrTag.EFFECT_TAG] = self.effect_layer 
		self.layout_list[ViewMgrTag.UI_TAG] = self.ui_Layer 
		self.layout_list[ViewMgrTag.WIN_TAG] = self.win_layer 
		self.layout_list[ViewMgrTag.TOP_TAG] = self.top_layer 
		self.layout_list[ViewMgrTag.DIALOGUE_TAG] = self.dialogue_layer 
		self.layout_list[ViewMgrTag.MSG_TAG] = self.msg_layer 
		self.layout_list[ViewMgrTag.RECONNECT_TAG] = self.reconnect_layer 
		self.layout_list[ViewMgrTag.LOADING_TAG] = self.loading_layer 
		self.layout_list[ViewMgrTag.DEBUG_TAG] = self.gm_layer 

        self.is_init = true
    end
    return self
end

--==============================--
--desc:角色登录成功之后,添加gm命令
--time:2018-06-28 11:21:50
--@return 
--==============================--
function ViewManager:initEvent()
    -- self.init_main_event = GlobalEvent:getInstance():Bind(EventId.ROLE_CREATE_SUCCESS, function()
    --     self:initMainFunBar()
    --     GlobalEvent:getInstance():UnBind(self.init_main_event)
    --     self.init_main_event = nil
    -- end)
end

-- 清除
function ViewManager:DeleteMe()
	if self.main_scene ~= nil then
		self.main_scene:release()
		self.main_scene:removeAllChildren()
		self.main_scene = nil
	end
	self.is_init = nil
end
