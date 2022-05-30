-- --------------------------------------------------------------------
-- 登陆界面集合,使用的是 s_001 音乐
--
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @editor: shiraho@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------

LoginWindow = LoginWindow or BaseClass(BaseView)

function LoginWindow:__init()
	self.ctrl = LoginController:getInstance()
	self.view_index = 0
	self.views = {}
	self.is_full_screen = true
	self.layout_name = "login/login_window"
	--modified by chenbin
	-- self.back_ground_path = PathTool.getLoginRes()
	self.back_ground_path = "res/resource/login/login_bg.png"

	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("login", "login"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("login", "login2"), type = ResourcesType.plist},
		{path = self.back_ground_path, type = ResourcesType.single}
	}
end

function LoginWindow:createAllSpines()
	local nodeRole = self.root_wnd:getChildByName("Node_role")
	local nodeGuo = self.root_wnd:getChildByName("Node_guo")
	local nodeJi = self.root_wnd:getChildByName("Node_ji")
	local nodeOther = self.root_wnd:getChildByName("Node_other")
	local nodePikaqiu = self.root_wnd:getChildByName("Node_pikaqiu")

	local skel_path = "res/spine/Dc_Boy/b_Ji.skel"
	local atlas_path = "res/spine/Dc_Boy/b_Ji.atlas"
	local animName = "animation"
	local spine = spSkeletonAnimationCreate(skel_path, atlas_path, pixelformal)
	spine:setAnimation(0, animName, true)
	nodeRole:addChild(spine)

	local skel_path = "res/spine/Dc_pikaqu/Pikaqu.skel"
	local atlas_path = "res/spine/Dc_pikaqu/Pikaqu.atlas"
	local animName = "animation"
	local spine = spSkeletonAnimationCreate(skel_path, atlas_path, pixelformal)
	spine:setAnimation(0, animName, true)
	nodePikaqiu:addChild(spine)

	local skel_path = "res/spine/Dc_Guo/Guo_bone.skel"
	local atlas_path = "res/spine/Dc_Guo/Guo_bone.atlas"
	local animName = "animation"
	local spine = spSkeletonAnimationCreate(skel_path, atlas_path, pixelformal)
	spine:setAnimation(0, animName, true)
	nodeGuo:addChild(spine)

	local skel_path = "res/spine/Dc_Ji/Proj_Ji.skel"
	local atlas_path = "res/spine/Dc_Ji/Proj_Ji.atlas"
	local animName = "animation"
	local spine = spSkeletonAnimationCreate(skel_path, atlas_path, pixelformal)
	spine:setAnimation(0, animName, true)
	nodeJi:addChild(spine)

	local skel_path = "res/spine/Dc_Other/Other.skel"
	local atlas_path = "res/spine/Dc_Other/Other.atlas"
	local animName = "animation"
	local spine = spSkeletonAnimationCreate(skel_path, atlas_path, pixelformal)
	spine:setAnimation(0, animName, true)
	nodeOther:addChild(spine)
end

function LoginWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	if self.background ~= nil then
		loadSpriteTexture(self.background, self.back_ground_path, LOADTEXT_TYPE)
		self.background:setScale(display.getMaxScale())
	end

	--添加spine动画
	self:createAllSpines()

	self.container = self.root_wnd:getChildByName("container")
	
	local show_version_msg = SHOWVERSIONMSG
	if show_version_msg == nil then
		if GAME_FLAG == "zsry" then
			show_version_msg = TI18N("新广出审[2017]10057号\nISBN：978-7-498-02852-5\n著作权人：上海其趣网络科技有限公司\n出版服务单位：上海同济大学电子音像出版社有限公司")
		else
			show_version_msg = TI18N("新广出审[2018]1192号\nISBN：978-7-498-04567-6\n著作权人：广州纷至网络科技有限公司\n出版服务单位：上海同济大学电子音像出版社有限公司")
		end
	end
	self.plate_label = self.container:getChildByName("label_plate")
	self.plate_label:setString("")
	--if self.plate_label then
	--	if show_version_msg and show_version_msg ~= "" and type(show_version_msg) == "string" then
	--		self.plate_label:setString(show_version_msg)
	--	else
	--		self.plate_label:setString("")
	--	end
	--	self.plate_label:setPositionY(display.getBottom()+20)
	--end

	self.label_version = self.container:getChildByName("label_version")
	if self.label_version then
		-- 设置版本号
		local ver = math.max(cc.UserDefault:getInstance():getIntegerForKey("local_version"), NOW_VERSION)
	    if ver > UPDATE_VERSION_MAX then
	        ver = UPDATE_VERSION_MAX
	        cc.UserDefault:getInstance():setIntegerForKey("lasted_version", UPDATE_VERSION_MAX)
	        cc.UserDefault:getInstance():setIntegerForKey("local_version", UPDATE_VERSION_MAX)
	        cc.UserDefault:getInstance():flush()
	    end
	    if cc.UserDefault:getInstance():getBoolForKey("is_enter_try_srv") then -- 是否进入优先体验服
	        ver = math.max(cc.UserDefault:getInstance():getIntegerForKey("local_try_version"), ver)
	    end
	    local ver_base = getVersionDesc()

		if not IS_PLATFORM_LOGIN then
			self.label_version:setVisible(true)
		else
			self.label_version:setVisible(false)
		end
		self.label_version:setString(string.format(TI18N("版本号：v%s.%s"), ver_base, ver))
		self.label_version:setPositionY(display.getBottom()+20)
	end

	-- 特殊处理--4.4
	if needMourning() then
		setChildUnEnabled(true, self.background)
		if self.spine then
			setChildUnEnabled(true, self.spine)
		end
		self.plate_label:disableEffect(cc.LabelEffect.OUTLINE)
		self.plate_label:setTextColor(cc.c3b(0x81,0x81,0x81))
		self.label_version:disableEffect(cc.LabelEffect.OUTLINE)
		self.label_version:setTextColor(cc.c3b(0x81,0x81,0x81))
	end
end

-- sdk登录完成之后显示版本号
function LoginWindow:showVersionLabel()
	if not MAKELIFEBETTER and not tolua.isnull(self.label_version) then
		self.label_version:setVisible(true)
	end
end

-- 注意：baseview的open方法会回调这里
function LoginWindow:openRootWnd(index)
	-- 走这里
	self:showPanel(index)

	delayOnce(function()
        AudioManager:getInstance():playMusic(AudioManager.AUDIO_TYPE.SCENE, "s_001", true)
    end,1)

	self:preloadSomething()
end

-- 登陆时需要预加载的内容
function LoginWindow:preloadSomething(  )
	-- 预加载一些音效,防止第一次使用的时候卡顿
	if SOUND_EFFECT_LIST then
		if AudioManager:getInstance().preLoadEffectByPath then
			for i,v in ipairs(SOUND_EFFECT_LIST) do
				AudioManager:getInstance():preLoadEffectByPath(v)
			end
		end
	end

	-- 预加载音乐
	if SCENE_MUSIC_LIST then
		if AudioManager:getInstance().preLoadMusicByPath then
			for i,v in ipairs(SCENE_MUSIC_LIST) do
				AudioManager:getInstance():preLoadMusicByPath(v)
			end
		end
	end

	-- 是否开启高品质
	local high_quality_open = SysEnv:getInstance():getBool(SysEnv.keys.high_quality,true)
	if high_quality_open == true then
		EQUIPMENT_QUALITY = 3
	else
		EQUIPMENT_QUALITY = 1
	end

	-- 预加载创角的特效
	local res_id = 237
	if ACCOUNT_HAS_ROLE == true then
		res_id = 234
	end
	local spine_name = PathTool.getEffectRes(res_id)
	local js_path, atlas_path, png_path = PathTool.getSpineByName(spine_name)
	-- local pf = getPixelFormat(spine_name)
	cc.Director:getInstance():getTextureCache():addImageAsync(png_path, function()

	end)
end

--==============================--
--desc:显示指定窗体,现在不包含了创建角色面板
--time:2017-08-07 10:25:04
--@idx:
--@return
--==============================--
function LoginWindow:showPanel(idx)
	idx = idx or LoginController.type.user_input
	if self.view_index == idx then return end
	-- 走这里
	local tmp_view = self:getViewById(idx)

	if tmp_view == nil then return end

	if self.selected_view then
		self.selected_view:setVisible(false)
		self.selected_view = nil
	end

	self.view_index = idx
	self.selected_view = tmp_view
	self.selected_view:setVisible(true)
	self.selected_view:update()

	if idx == LoginController.type.enter_game then
		if AUTO_SHOW_NOTICE == true and (not MAKELIFEBETTER) then			--版本变化的时候切不为提审服
            NoticeController:getInstance():openNoticeView()
        end
	elseif idx == LoginController.type.server_list then

	elseif idx == LoginController.type.user_input then

	end

    self.selected_view:stopAllActions()
    self.selected_view:effectHandler()
end

--==============================--
--desc:打开指定的窗体
--time:2017-08-07 10:24:54
--@idx:
--@return
--==============================--
function LoginWindow:getViewById(idx)
	if idx == LoginController.type.server_list and MAKELIFEBETTER == true then return end -- 审核服状态下不显示

	local tmp_view = self.views[idx]
	if tmp_view == nil then
		if idx == LoginController.type.user_input then
			local is_win_mac = PLATFORM == cc.PLATFORM_OS_WINDOWS or PLATFORM == cc.PLATFORM_OS_MAC
			if IS_PLATFORM_LOGIN then  -- 平台登录,这里也包含了战盟登录
			 	if ( IS_WIN_PLATFORM == true ) or ( not is_win_mac ) then

			 		--modified by chenbin:切换账号的自动登录
			 		if device.getSwitchAccountInfoOnce then
				 		local info = device.getSwitchAccountInfoOnce()
				 		if info ~= "" then
				 			print("swit account auto login:", info)
				 			local lp = LoginPlatForm:getInstance()
				 			lp:autoLoginWhenSwitch(info)
	            		end
	            	end
        			tmp_view = PlatformPanel.new(self.container, self.ctrl)
            	end
			else
				-- 走这里
            	tmp_view = UserPanel.new(self.container, self.ctrl)
        	end
		elseif idx == LoginController.type.enter_game then
        	tmp_view = EnterPanel.new(self.container, self.ctrl)
    	elseif idx == LoginController.type.server_list then
        	tmp_view = ServerPanel.new(self.container,self.ctrl)
    	end
		self.container:addChild(tmp_view, 1)
    	self.views[idx] = tmp_view
	end
	tmp_view = self.views[idx]
	return tmp_view
end

function LoginWindow:close_callback()
	if self.spine then
		self.spine:setVisible(false)
		self.spine:removeFromParent()
        self.spine = nil
	end
	for k,v in pairs(self.views) do
		v:DeleteMe()
		v = nil
	end
	self.views = nil
end
