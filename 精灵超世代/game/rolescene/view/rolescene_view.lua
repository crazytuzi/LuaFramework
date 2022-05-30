-- --------------------------------------------------------------------
-- 自由移动的场景
-- 
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @editor: shiraho@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------
RoleScene = RoleScene or BaseClass()

RoleScene.layer = {
	role = 1,
	back = 2
}

function RoleScene:__init(ctrl)
    self.ctrl = ctrl
    self.model = self.ctrl:getModel()

    self:config()
    self:configUI()
    self:registerEvent()
end

function RoleScene:setVisible(status)
    if self.root_wnd then
        self.root_wnd:setVisible(status)
    end
end

function RoleScene:playBackgroundMusic()
	local misc_music = RoleController:getInstance():getModel().city_music_name or "s_002"
	if self.scene_info ~= nil and self.scene_info.misc_music and self.scene_info.misc_music ~= "" then
		misc_music = self.scene_info.misc_music
	end
	-- if AudioManager then
	-- 	AudioManager:getInstance():playMusic(AudioManager.AUDIO_TYPE.SCENE, misc_music, true)
	-- end
end

function RoleScene:config()
    self.step                   = 1
    self.role_list              = {}
    self.unit_list              = {}
	self.click_delay 			= GameNet:getInstance():getTimeFloat() 			--点击间隔
	self.one_scene_max 			= 15 							-- 低配模式下,同屏最大人数显示
	self.topOffY 				= 15
	self.cur_visible_player 	= 0
	self.scene_x				= 0
	self.scene_y				= 0

	self.render_effect_list		= {}
	self.effect_list 			= {}

    self.mapResAsyncList 		= {}
    self.mapResCache 			= {}
    self.mapResCacheOrder 		= {}
    self.mapPicCache 			= {}
    self.mapTileList 			= {}
    self.autoLoaderNumX 		= 1 + math.ceil(SCREEN_WIDTH / 2 / 256) -- 动态加载资源
    self.autoLoaderNumY 		= 1 + math.ceil(SCREEN_HEIGHT / 2 / 256) -- 动态加载资源

    self.finishRender           = false
    self.loading_pic            = false

	self.bLayer_sp 				= -0.2 -- 远景层移动率
	self.renderObjList 			= {} -- 要渲染的所有对象总列表
	self.renderEffectObjList 	= {} -- 要渲染的场景特效列表


end

function RoleScene:configUI()
    local parent = ViewManager:getInstance():getBaseLayout()
    local win_width = display.getRight(parent) - display.getLeft(parent)
    local win_height = display.getTop(parent) - display.getBottom(parent)

    self.root = ccui.Layout:create()
    self.root:setAnchorPoint(cc.p(0.5, 0.5))
    self.root:setContentSize(cc.size(win_width, win_height))
    self.root:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)

    self.root_wnd = ccui.Widget:create()
	self.root:addChild(self.root_wnd)

    self.pic_layer  = ccui.Widget:create()			-- 马赛克地图
	self.map_bLayer = ccui.Widget:create() 			-- 远景层
	self.map_sLayer = ccui.Widget:create() 			-- 场景层	
	self.role_layer = ccui.Widget:create() 			-- 普通元素[角色，怪物，npc]层

    self.root_wnd:addChild(self.pic_layer, 0)
	self.root_wnd:addChild(self.map_bLayer, 1)
	self.root_wnd:addChild(self.map_sLayer, 2)
	self.root_wnd:addChild(self.role_layer, 4)

	self.role_layer:setAnchorPoint(cc.p(0, 1))
	self.map_bLayer:setAnchorPoint(cc.p(0, 0))
	self.map_sLayer:setAnchorPoint(cc.p(0, 0))
    
    ViewManager:getInstance():addToLayerByTag(self.root, ViewMgrTag.Scene_LAYER_TAG)
end

function RoleScene:registerEvent()
	local function onTouchBegan( touch, event )
        if self.hero == nil then return false end

        if math.abs(GameNet:getInstance():getTimeFloat() - self.click_delay) < 0.1 then -- 为效率，连续点击寻路在0.3秒内连点无效处理
			return false
		else
			self.click_delay = GameNet:getInstance():getTimeFloat()
		end
        return true
    end

	local function onTouchMoved( touch, event )
		if self.hero == nil then return end
	end

	local function onTouchEnded( touch, event )
		if self.hero == nil then return end
		GlobalEvent:getInstance():Fire(NpcEvent.CloseNpcTalkViewEvent) --移除npc对话面板
		if self.model then
			self.model:clearFindVo()
		end

		self.model:handleSceneHead(false)

		local end_pos = cc.p(touch:getLocation())
        end_pos = self.map_sLayer:convertToNodeSpace(end_pos)
    	local ep = TileUtil.changeToTilePoint(end_pos)
    	local sp = self.hero:getLogicPos()
    	ep = self:getNearEndPos(end_pos, self.hero:getWorldPos())
    	if ep and ep.x == sp.x and ep.y == sp.y then
    		ep = TileUtil.changeToTilePoint(end_pos)
			if math.abs(ep.x - sp.x) >= math.abs(ep.y - sp.y) then
				ep.y = sp.y
				end_pos = TileUtil.changeToPixsPoint(ep)
			else
				ep.x = sp.x
				end_pos = TileUtil.changeToPixsPoint(ep)
			end
    	end
    	ep = self:getNearEndPos(end_pos, self.hero:getWorldPos())
		if ep ~= nil then
    		self:startWalk(sp, ep)
    	end  
    end
    self.touch_listener = cc.EventListenerTouchOneByOne:create()
    self.touch_listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
    self.touch_listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED)
    self.touch_listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)
    self.root_wnd:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.touch_listener, self.root_wnd)

	if self.update_red_info == nil then
		self.update_red_info = GlobalEvent:getInstance():Bind(RolesceneEvent.UPDATE_RED_INFO, function(params, from_type) 
			if type(params) == "table" or from_type == nil then return end
			self:updateNpcRedStatusByType(from_type)
		end)
	end
end

--==============================--
--desc:计算最靠近终点的坐标位置
--time:2017-10-10 09:36:54
--@endPos:
--@startPos:
--@return 
--==============================--
function RoleScene:getNearEndPos(endPos, startPos)
	if endPos == nil or startPos == nil then 
		return nil
	end

	local result = nil
	local ep = TileUtil.changeToTilePoint(endPos)
	if Astar:getInstance():isBlock(ep.x, ep.y) then
		local tmp = cc.pSub(endPos, startPos)
		local pDir = cc.pNormalize(tmp)
		local nextPos = cc.pMul(pDir, TileUtil.tileWidth)
		
		local nowPos  = nil
		nowPos = cc.pSub(endPos, nextPos)
		local px, py
		if endPos.x < startPos.x then
			px = cc.clampf(nowPos.x, endPos.x, startPos.x)
		else
			px = cc.clampf(nowPos.x, startPos.x, endPos.x)
		end
		if endPos.y < startPos.y then
			py = cc.clampf(nowPos.y, endPos.y, startPos.y)
		else
			py = cc.clampf(nowPos.y, startPos.y, endPos.y)
		end
		nowPos = cc.p(px, py)
		if endPos.x == nowPos.x and endPos.y == nowPos.y then
			return nil
		end
		return self:getNearEndPos(nowPos, startPos)
	end
	result = result or ep
	return result
end

--==============================--
--desc:开始寻路
--time:2017-10-10 09:37:56
--@sp:
--@ep:
--@return 
--==============================--
function RoleScene:startWalk(sp, ep)
	if self.hero == nil then return end
	local heroPos = self.hero:getWorldPos()
	if ep == nil and self.findVo == nil then return end
	local target = nil
	if ep == nil then
		target = TileUtil.changeToPixsPoint(self.findVo.pos)
	else
		target = TileUtil.changeToPixsPoint(ep)
	end

	if self.findVo and self.findVo.sceneId == self.model:getSceneId() then
		if MapUtil.isOnRange(heroPos, target, self.model.unitRange) then
            GlobalEvent:getInstance():Fire(RolesceneEvent.SCENE_WALKEND, self.findVo)
			return
		end
	end

	self.model:findPath(sp, ep)
	self:walkNext(heroPos)
end

--==============================--
--desc:移动下一步
--time:2017-10-10 09:47:14
--@prePos:
--@return 
--==============================--
function RoleScene:walkNext(prePos)
	if self.findVo ~= nil and self.findVo.sceneId == self.model:getSceneId() then
		local target = self.findVo.pos
		if MapUtil.isOnRange(prePos, target, self.model.unitRange) then
            GlobalEvent:getInstance():Fire(RolesceneEvent.SCENE_WALKEND, self.findVo)
            self:cancelWalk()
			return
		end
	end

	-- 没有寻路路径
	if self.model.path == nil or #self.model.path == 0 then
		if self.findVo == nil then
			self.model.findVoTarget = nil
			self:cancelWalk()
		end
		return 
	end

	local pos = table.remove(self.model.path, #self.model.path)
	local nextPos = TileUtil.changeToPixsPoint(pos)
	self.hero:doMove(prePos, nextPos)
end

--==============================--
--desc:取消移动
--time:2017-10-10 09:50:07
--@is_auto:
--@return 
--==============================--
function RoleScene:cancelWalk(is_auto)
	if self.hero == nil or self.hero:getVo() == nil then return end
	self.hero:stopMove()
	-- GlobalEvent:getInstance():Fire(SceneEvent.FINDING_STOP_WALK)
	if self.findVo and self.findVo.callback then
		self.findVo.callback()
	end
	self.findVo = nil
	self.model.path = nil
end

--==============================--
--desc:寻路去目标,比如说点到场景角色,单位或者其他
--time:2017-10-10 09:52:51
--@findVo:
--@isTarget:
--@return 
--==============================--
function RoleScene:gotoTarget(findVo, isTarget)
	if self.hero == nil then return end
	self.findVo = findVo
	if self.findVo == nil then return end

	if self.findVo.sub_type ~= RoleSceneVo.sub_unittype.ele and self.model:getSceneId() == self.findVo.sceneId then
		local function getRandomPos(pos)
			local new_pos,tilePos,_x,_y
			local over = true
            local num = 0
            pos = TileUtil.changeToTilePoint( pos )
			while num < 20 do
				_x = math.floor(pos.x + 2*math.cos(math.random(0,180)))
				_y = math.floor(pos.y - 2*math.sin(math.random(90,270)))
				new_pos = TileUtil.changeToPixsPoint( cc.p(_x, _y) )
				if Astar:getInstance():isBlock(_x, _y) == false then break end
                num = num + 1
                -- 找了20次都找不到,那直接用原始坐标吧
                if num >= 20 then
                	new_pos = pos
                end
			end
			return new_pos
		end
		self.findVo.pos = getRandomPos(findVo.pos)
	end

	local sp = self.hero:getLogicPos()
	local ep = self:getNearEndPos(self.findVo.pos, self.hero:getWorldPos())
	-- local ep = TileUtil.changeToTilePoint(self.findVo.pos)
	self:startWalk(sp, ep)
end

function RoleScene:createScene(x, y)
    self.scene_info = self.model:getSceneInfo()
    self.scene_data = self.model:getSceneData()
    if self.scene_info == nil or self.scene_data == nil then
        self.ctrl:exitRoleScene(true)
    else
		self:playBackgroundMusic()

		-- self.scene_x = x
		-- self.scene_y = y
        self.loading_pic = false
        self:clearLayer()
        self:layoutScene()
        self:renderScene()

        local modX, modY, picXNum, picYNum = self:getScenePicByPos(self.scene_info.s_img_w, self.scene_info.s_img_h, self.scene_data.x, self.scene_data.y)
        self.nowPicTile = cc.p(picXNum, picYNum)

        for _, v in pairs(self.mapResCache) do 
            v[4] = v[4] + math.max(math.abs(picXNum-v[2]), math.abs(picYNum-v[3]))
            table.insert(self.mapResCacheOrder, v)
        end
        table.sort(self.mapResCacheOrder, SortTools.KeyLowerSorter(4))
        self:quequeAddFun()

		self:setScheduleUpdate(true)
    end
end

--==============================--
--desc:设置当前地图的尺寸
--time:2017-10-10 10:45:46
--@return 
--==============================--
function RoleScene:layoutScene()
    if self.scene_info == nil then return end
    self.loadkey = {}
	-- self.map_bLayer:setPositionY(self.scene_info.height)
    self.map_bLayer:setContentSize(cc.size(self.scene_info.width, self.scene_info.height))
    self.map_sLayer:setContentSize(cc.size(self.scene_info.width, self.scene_info.height))
    -- self:createSceneObj()
end

--==============================--
--desc:渲染角色所在位置的场景图片
--time:2017-10-10 10:51:02
--@return 
--==============================--
function RoleScene:renderScene()
    if self.finishRender or self.scene_info == nil then return end
	local max_w = self.scene_info.width
	local max_h = self.scene_info.height

	if self.scene_info.fill_type == 1 then --整张地图,这一类的很少,几乎不用
		
	else
		self:renderNormal(max_w, max_h) -- 普通切片场景
	end
end

--==============================--
--desc:加载地图,包含解析地块和加载马赛克
--time:2017-10-10 10:54:05
--@w:
--@h:
--@return 
--==============================--
function RoleScene:renderNormal(w, h)
    self:renderSmallPic()
    self:renderLayer(MapUtil.s, self.scene_info.s_img_w, self.scene_info.s_img_h)
    self:renderLayer(MapUtil.b, self.scene_info.b_img_w, self.scene_info.b_img_h)
	self.finishRender = true
end

--==============================--
--desc:创建马赛克地图
--time:2017-10-10 10:54:51
--@return 
--==============================--
function RoleScene:renderSmallPic()
	local res = "scene/preview/"..self.scene_info.sourceId..".jpg"
    local smallPic = display.newSprite(res)
    self.pic_layer:addChild(smallPic)
    smallPic:setAnchorPoint(cc.p(0,0))
    local size = smallPic:getBoundingBox()
    smallPic:setScale(self.scene_info.s_img_w/size.width, self.scene_info.s_img_h/size.height)
end

--==============================--
--desc:解析分块地图
--time:2017-10-10 10:56:22
--@type:
--@w:
--@h:
--@return 
--==============================--
function RoleScene:renderLayer(type, w, h)
	local x, y = 0, 0
	while y < h do
		x = 0 
		while x < w do
			self:renderLayerTile(type, x, y)
			x = x + MapUtil.c_w
		end
		y = y + MapUtil.c_h
	end
end

function RoleScene:renderLayerTile(type, x, y)
	if type == MapUtil.s then
		self:addFloorSprite(type, x, y, cc.p(0, 0))	
	elseif type == MapUtil.b then
		self:addFloorSprite(type, x, y, cc.p(0, 1))		
	end
end

function RoleScene:addFloorSprite(type, x, y, ap)
	local img_w = self.scene_info[type.."_img_w"] -- 引用场景id下的相关层源图大小
	local img_h = self.scene_info[type.."_img_h"] -- 引用场景id下的相关层源图大小
	if img_w == 0 or img_h == 0 then return end
	local modX, modY, picXNum, picYNum = self:getScenePicByPos(img_w, img_h, x, y)
	local key = type.."_"..x.."_"..y

	if self.mapPicCache[key] ~= nil then
		return self.mapPicCache[key]
	end

	local res = self:getPicRes(type, picXNum, picYNum)
	if not self.loadkey[key] then 
        self.loadkey[key] = true
        self:createFloorSprite( type, res, x, y, anchorPoint, true, true)
    end
end

function RoleScene:getScenePicByPos(w, h, x, y)
	local modX, yuX = math.modf(x/w)
	local modY, yuY = math.modf(y/h)
	local picOverX = math.ceil(yuX*w) -- 计算出超过的像素
	local picOverY = math.ceil(yuY*h) -- 计算出超过的像素
	local picXNum = math.floor(picOverX/MapUtil.c_w)  -- 计算出图片序号
	local picYNum = math.floor(picOverY/MapUtil.c_h)  -- 计算出图片序号
	return modX, modY, picXNum, picYNum
end

function RoleScene:getPicRes(type, n, m)	
	if self.mapResCache[type.."_"..n.."_"..m] ~= nil then
		return self.mapResCache[type.."_"..n.."_"..m][1]
	end
	local res = nil
	local res_type = nil
	if type == MapUtil.b then
		res_type = "jpg"
		res = "scene/map/"..self.scene_info.backId.."/"..type.."layer/"..n.."_"..m..".jpg"
		if not PathTool.isFileExist(res) then
			res = "scene/map/"..self.scene_info.backId.."/"..type.."layer/"..n.."_"..m..".png"
			res_type = "png"
		end
	elseif type == MapUtil.s then
		res_type = "png"
		res = "scene/map/"..self.scene_info.sourceId.."/"..type.."layer/"..n.."_"..m..".png"
		if not PathTool.isFileExist(res) then
			res = "scene/map/"..self.scene_info.sourceId.."/"..type.."layer/"..n.."_"..m..".jpg"
			res_type = "jpg"
		end
	end

    local c = (type == MapUtil.s) and 0 or 9999999999
	self.mapResCache[type.."_"..n.."_"..m] = {res,n,m,c,res_type}
	return res
end

function RoleScene:createFloorSprite(type, res, x, y, ap, isLocal, isAsync)
	if type == MapUtil.b then
		y = self.scene_info.height - y
	end
	table.insert(self.mapResAsyncList, {type, res, x, y, ap, isLocal, isAsync})
end

--==============================--
--desc:创建真实的地块,并显示出来
--time:2017-10-10 10:59:07
--@type:
--@res:
--@x:
--@y:
--@anchorPoint:
--@isLocal:
--@isAsync:
--@return 
--==============================--
function RoleScene:createFloorSpriteAct(type, res, x, y, anchorPoint, isLocal, isAsync)
	if MapUtil then
		local key = type.."_"..x.."_"..y
		local offX = math.floor(x / self.scene_info[type.."_img_w"])
	    local offY = self.scene_info[type.."_img_y"] or 0
		local parent = self["map_"..type.."Layer"]
		local tile = nil

		if type == MapUtil.b then
			tile = MapTile.New( cc.p(x-offX, y), res, type, isLocal, isAsync, parent, true)
		else
			tile = MapTile.New( cc.p(x-offX, y), res, type, isLocal, isAsync, parent, false)
		end

		if tile == nil or tile.isDeleted then return end

		self.mapPicCache[key] = tile
		table.insert(self.mapTileList, tile)
		self.mapPicCache[key]:retain()
    	self.isAddedAll = false
	end
end

--==============================--
--desc:把创建好的地块对象显示出来
--time:2017-10-10 11:00:03
--@return 
--==============================--
function RoleScene:addMapTile()
	if self.isAddedAll then return end
	self.isAddedAll = true
	for i, tile in ipairs(self.mapTileList) do
		if not tile:isAdded() then
			tile:addChildOnParent()
		end
	end
end

--==============================--
--desc:队列创建地图
--time:2017-10-10 11:02:39
--@return 
--==============================--
function RoleScene:quequeAddFun()
    if self.loading_pic then return end
	for k, v in pairs(self.mapResCacheOrder) do
        if v[4] > 100000 or (math.abs(v[2]-self.nowPicTile.x) < self.autoLoaderNumX and math.abs(v[3] - self.nowPicTile.y) < self.autoLoaderNumY) then
            self.mapResCacheOrder[k] = nil
            local res = v[1]
            self.loading_pic = true
            -- 如果地图资源是jpg的话,异步加载使用的是565格式,否则是用8888
            -- local pf = (v[5] == "jpg") and cc.TEXTURE2_D_PIXEL_FORMAT_RG_B565 or cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888
            cc.Director:getInstance():getTextureCache():addImageAsync(res, function()
                for k, v in pairs(self.mapResAsyncList) do 
                    if v[2] == res then 
                        self:createFloorSpriteAct(unpack(v))
                        self.mapResAsyncList[k] = nil
                    end
                end	
                self.loading_pic = nil
                self:quequeAddFun()
            end)
            return
        end
	end
end

--==============================--
--desc:定时器
--time:2017-10-10 10:25:03
--@status:
--@return 
--==============================--
function RoleScene:setScheduleUpdate(status)
    if status == true then
        if self.queue_timer == nil then
            self.queue_timer = GlobalTimeTicket:getInstance():add(function() 
                self:update()
            end, 1/display.DEFAULT_FPS)
        end
    else
        if self.queue_timer ~= nil then
            GlobalTimeTicket:getInstance():remove(self.queue_timer)
            self.queue_timer = nil
        end
    end
end

--==============================--
--desc:更新
--time:2017-10-10 10:26:23
--@return 
--==============================--
function RoleScene:update()
    if self.hero and self.hero:getVo() then
        if self.hero.isNeedRun then
            local pos = self.hero:getWorldPos()
            self.model:updateCamera(pos)
        end
    end

	local astar = Astar:getInstance()

    for k,v in pairs(self.role_list) do
        if v.vo ~= nil then
            v:update()
            if self.step % 31 == 0 then
				v:setAlpha(astar:isAlpha(v:getLogicPos().x, v:getLogicPos().y))
			end
        end
    end

	for k,v in pairs(self.unit_list) do
		if v.vo ~= nil then
			v:update()
		end
	end

    self:addMapTile()
	self.step = self.step + 1
    
    if self.step % (ADD_OBJ_RATE or 1) == 0 then
		self:quequeAddObj()
	end

	if self.step % 16 == 0 then
		self:quequeAddEffect()
	end
end

--==============================--
--desc:队列创建单位
--time:2017-10-10 11:54:19
--@return 
--==============================--
function RoleScene:quequeAddObj()
	local is_fight = BattleController:getInstance():isInFight()
	if is_fight == true then return end

	-- 这里创建的时候要做一些判断,比如说同屏多少人限制,这里预作处理,每次判断在角色范围以内的才去创建,否则不创建
	if self.renderObjList and next(self.renderObjList) ~= nil then
		local obj 
        local camera_x = -self.scene_x + SCREEN_WIDTH / 2
        local camera_y = -self.scene_y + SCREEN_HEIGHT / 2
		for i,v in ipairs(self.renderObjList) do
			if self:checkCreateUnit(v) == true then
				if self.hero == nil then
					obj = table.remove(self.renderObjList, i)
					break
				else
					if (math.abs(v.x-camera_x) < SCREEN_WIDTH/2 + 300 and math.abs(v.y - camera_y) < SCREEN_HEIGHT/2 + 300) then
						obj = table.remove(self.renderObjList, i)
						break
					end
				end
			end
		end
		if obj ~= nil then
			self:isExistOnQueque(obj)
		end
	end
end

--==============================--
--desc:判断一下是否需要创建改角色,
--time:2017-10-10 02:48:48
--@vo:
--@return 
--==============================--
function RoleScene:checkCreateUnit(vo)
	if vo == nil then return false end
	if vo.type ~= RoleSceneVo.unittype.role then return true end

	-- if SetController == nil then return false end
	-- if SetController:getInstance():getModel() == nil then return false end
	-- if SetController:getInstance():getModel():getVo() == nil then return false end

	-- local hide_player = SetController:getInstance():getModel():getVo().hide_other_player
	-- if hide_player == true then return false end

	-- 非流畅情况下,如果已经显示超过15人,则不添加了
	-- local is_normal_smooth = SetController:getInstance():getModel():getVo().is_normal_smooth
	-- if is_normal_smooth == true and self.cur_visible_player >= self.one_scene_max then return false end
	return true
end

--==============================--
--desc:定时创建对象
--time:2017-10-10 02:39:23
--@vo:
--@return 
--==============================--
function RoleScene:isExistOnQueque(vo)
	if vo == nil or vo.body_res == nil then return end
	if vo.type == RoleSceneVo.unittype.role then
		if self.model:getRole(vo.srv_id, vo.rid) and not self.model:isMainRoleVo(getNorKey(vo.srv_id, vo.rid)) then
			self:asyncLoad(vo, function()
				if self.model and self.model:getRole(vo.srv_id, vo.rid) and not self.model:isMainRoleVo(getNorKey(vo.srv_id, vo.rid))then
					self:createPlayer(vo, false, true)
				end
			end)
		end
	elseif vo.type == RoleSceneVo.unittype.unit then
		if self.model:getUnit(vo.id,vo.battle_id) ~= nil then
			self:asyncLoad(vo, function()
				if self.model and self.model:getUnit(vo.id,vo.battle_id) then
					self:createNpc(vo)
				end
			end)
		end
	end
end

function RoleScene:quequeAddEffect()
	if self.render_effect_list and next(self.render_effect_list) ~= nil then
		local data = table.remove(self.render_effect_list)
		if data ~= nil then
			local key = getNorKey(data.base_id, data.x, data.y)
			if self.effect_list[key] ~= nil then return end
			local config = Config.UnitData.data_unit(data.base_id)
			if config ~= nil and config.body_id ~= "" then
				local js_path, atlas_path, png_path, prefix = PathTool.getSpineByName(config.body_id)
				cc.Director:getInstance():getTextureCache():addImageAsync(png_path, function()
					local effect = createEffectSpine(config.body_id, cc.p(data.x, data.y), cc.p(0.5, 0))
					local parent = self.role_layer
					if data.layer == RoleScene.layer.back then
						parent = self.map_bLayer
					end
					if parent and not tolua.isnull(parent) then
						parent:addChild(effect)
					end
					self.effect_list[key] = effect
				end)
			end
		end
	end
end

--==============================--
--desc:异步创建单位
--time:2017-10-14 10:02:06
--@vo:
--@callback:
--@return 
--==============================--
function RoleScene:asyncLoad(vo, callback)
	if vo == nil and callback ~= nil then
		callback()
		return
	end
	local action_name = nil
	if vo.type == RoleSceneVo.unittype.role or vo.sub_type == RoleSceneVo.sub_unittype.npc then
		action_name = PlayerAction.battle_stand
	end
    local js_path, atlas_path, png_path, prefix = PathTool.getSpineByName(vo.body_res, action_name)
    if display.isPrefixExist(prefix) then
    	callback()
    else
    	self.loading_spine = true
    	cc.Director:getInstance():getTextureCache():addImageAsync(png_path, function()
    		self.loading_spine = false
    		callback()
    	end)
    end
end
--更新角色瞬移位置
function RoleScene:updateHeroPos(vo)
	if not vo then return end
	local key = getNorKey(vo.srv_id, vo.rid)
	local role = self.role_list[key]
	if role ~= nil and role.vo ~= nil then
		local x,y= role.vo:getNowPos()
		role:setWorldPos(cc.p(x,y))
		local pos = role:getWorldPos()
		self.model:updateCamera(pos)
	end
end
--==============================--
--desc:添加待创建角色数据
--time:2017-10-10 12:03:53
--@vo:
--@return 
--==============================--
function RoleScene:addRole(vo)
	if not vo then return end
    local key = getNorKey(vo.srv_id, vo.rid)
	local role = self.role_list[key]
	if role ~= nil and role.vo ~= nil then
        role:doMove(nil,TileUtil.changeToPixsPoint(cc.p(vo.x,vo.y)))
    else
        table.insert(self.renderObjList, vo)

        local role_vo = RoleController:getInstance():getRoleVo()
        if role_vo ~= nil then
            local role_key = getNorKey(role_vo.srv_id, role_vo.rid)
            if role_key == key then -- 是自己
			    self:createPlayer(vo, true, true)
            else -- 这里保留非流畅情况下,显示不超过15人处理

            end
        end
    end
end

function RoleScene:removeRole(srv_id, rid)
	local key = getNorKey(srv_id, rid)
	if self.role_list[key] ~= nil then	
		-- 显示个数减一
		-- if self.role_list[key]:isVisible() == true then
		-- 	self.cur_visible_player = self.cur_visible_player - 1
		-- end

		self.role_list[key]:DeleteMe()
		self.role_list[key] = nil
	end

	-- 不管有没有都移除掉
	self:removeObjInList(srv_id, rid)
end

--==============================--
--desc:创建具体角色显示对象
--time:2017-10-10 12:14:42
--@vo:
--@is_self:
--@force:
--@return 
--==============================--
function RoleScene:createPlayer(vo, is_self, force)
    if self.scene_info == nil or self.model == nil then return end
    if self.role_list == nil then
        self.role_list = {}
    end
	local key = getNorKey(vo.srv_id, vo.rid)
	local role = RoleScenePlayer.New(is_self)
	role:setParentWnd(self.role_layer)
	role:setVo(vo)

	if is_self == true then 
		self.hero = role 
	end
	self.role_list[key] = role
	self.cur_visible_player = self.cur_visible_player + 1
end

--==============================--
--desc:创建场景NPC
--time:2017-10-17 10:47:31
--@vo:
--@return 
--==============================--
function RoleScene:createNpc(vo)
	if self.scene_info == nil or self.model == nil then return end
	if self.unit_list == nil then
		self.unit_list = {}
	end
	local key = getNorKey(vo.battle_id, vo.id)
	if self.unit_list[key] ~= nil then return end
	local npc = RoleSceneNpc.New()
	if vo.layer == RoleScene.layer.back then
		npc:setParentWnd(self.map_bLayer)
	else
		npc:setParentWnd(self.role_layer)
	end
	npc:setVo(vo)
	self.unit_list[key] = npc

	if self.unit_list_base == nil then
		self.unit_list_base = {}
	end
	self.unit_list_base[vo.base_id] = npc

	-- 更新NPC红点状态
	self:updateNpcRedStatus(npc)
end

--==============================--
--desc:移除
--time:2017-10-10 12:13:54
--@srv_id:
--@rid:
--@return 
--==============================--
function RoleScene:removeObjInList(srv_id, rid)
	if self.renderObjList == nil or next(self.renderObjList) == nil then 
		return 
	end
	for i,v in ipairs(self.renderObjList) do
		if v.type == RoleSceneVo.unittype.role then 
			if v.srv_id == srv_id and v.rid == rid then
				table.remove(self.renderObjList, i)
				break
			end
		elseif v.type == RoleSceneVo.unittype.unit then
			if v.battle_id == srv_id and v.id == rid then
				table.remove(self.renderObjList, i)
				break
			end
		end
	end
end

function RoleScene:syncRole(srv_id, rid, pos)
	local key = getNorKey(srv_id, rid)
	local role = self.role_list[key]
	if role and role.vo then
		role:doMove(nil, pos)
	end
end

function RoleScene:addEffect(data)
	local key = getNorKey(data.base_id, data.x, data.y)
	local vo = self.effect_list[key]
	if vo == nil then
		table.insert(self.render_effect_list, data)
	end
end

function RoleScene:addUnit(vo)
	local key = getNorKey(vo.battle_id, vo.id)
	if self.unit_list[key] ~= nil then
		self.unit_list[key]:doMove(nil,TileUtil.changeToPixsPoint(cc.p(vo.x, vo.y)))
	else
		table.insert(self.renderObjList, vo)
	end
end

function RoleScene:removeUnit(id, battle_id)
	local key = getNorKey(battle_id,id)
	if self.unit_list[key] then
		self.unit_list[key]:DeleteMe()
		self.unit_list[key] = nil
	end
	self:removeObjInList(battle_id, id)		
end

function RoleScene:removeEffect(base_id, x, y)
	local key = getNorKey(base_id, x, y)
	local vo = self.effect_list[key]
	if vo ~= nil then
		vo:setVisible(false)
		vo:runAction(cc.RemoveSelf:create(true))
		vo:clearTracks()
		self.effect_list[key] = nil
	end
	for i,v in ipairs(self.render_effect_list) do
		if v.base_id == base_id and v.x == x and v.y == y then
			table.remove(self.render_effect_list, i)
			break
		end
	end
end

function RoleScene:setPos(scene_x, scene_y, pos, is_force)
	if is_force == true and self.init_x == nil then
		self.init_x = scene_x
	end
	if self.init_x == nil then
		self.init_x = 0
	end

	if self.scene_x == scene_x and self.scene_y == scene_y then return end
	self.scene_x = scene_x
	self.scene_y = scene_y

	self.root_wnd:setPosition(cc.p(scene_x , scene_y))
	self.root_wnd:setPositionX(scene_x)
	self.map_bLayer:setPositionX((scene_x-self.init_x) * self.bLayer_sp) -- 远景层
	-- self.map_bLayer:setPositionY(self.scene_info.height + (self.scene_info.height - display.height + scene_y) * self.bLayer_sp) -- 远景层
	self:updatePicTile(pos)
end

function RoleScene:updatePicTile(pos)
    if not self:isPicTileChange(pos) then return end
    self:quequeAddFun()
end

function RoleScene:isPicTileChange(pos)
    local picXNum = math.floor(pos.x/MapUtil.c_w)
    local picYNum = math.floor(pos.y/MapUtil.c_h)
    if picXNum == self.nowPicTile.x and picYNum == self.nowPicTile.y then
        return false
    end
    self.nowPicTile = cc.p(picXNum, picYNum)
    return true
end

function RoleScene:getHero()
    return self.hero
end

function RoleScene:__delete()
    self:setScheduleUpdate(false)
	self:clearLayer()

	if self.update_red_info ~= nil then
		GlobalEvent:getInstance():UnBind(self.update_red_info)
		self.update_red_info = nil
	end
	
    if self.root_wnd:getParent() then
		self.root_wnd:removeAllChildren()
		self.root_wnd:removeFromParent()
	end
end

--==============================--
--desc:清空资源操作
--time:2017-10-10 10:43:09
--@status:
--@return 
--==============================--
function RoleScene:clearLayer(status)
	self.loadkey = {}
	self.isAddedAll = false
	self.finishRender = false
	self.step = 1

	local clear_tex_list = {}
	for key, tile in pairs(self.mapPicCache) do
        clear_tex_list[tile.tex] = 1
        if tile.DeleteMe then
		    tile:DeleteMe()
        end
	end
	self.mapPicCache = {}
    self.mapResAsyncList = {}
    self.mapResCache = {}
    self.mapResCacheOrder = {}
    self.mapPicCache = {}
    self.mapTileList = {}

    self.pic_layer:removeAllChildren()
    self.map_bLayer:removeAllChildren()
    self.map_sLayer:removeAllChildren()
	self.role_layer:removeAllChildren()

    if clear_tex_list and next(clear_tex_list) ~= nil then
    	for k, _ in pairs(clear_tex_list) do 
        	cc.Director:getInstance():getTextureCache():removeTextureForKey(k)
    	end
	end
end

--==============================--
--desc:更新npc红点
--time:2017-10-17 10:53:11
--@base_id:
--@return 
--==============================--
function RoleScene:updateNpcRedStatus(npc)
	if npc == nil or npc.vo == nil then return end
	local need_show = false
	local controller = MainSceneController:getInstance()
	if npc.vo.base_id == 10114 then				-- 科技和捐献是一体
		need_show = controller:getRedPointStatusByType(MainSceneCity.guild, RedPointType.guild_tech_gift)
		if need_show == false then
			need_show = controller:getRedPointStatusByType(MainSceneCity.guild, RedPointType.guild_donate)
		end
	elseif npc.vo.base_id == 10113 then			-- 大厅
		need_show = controller:getRedPointStatusByType(MainSceneCity.guild, RedPointType.guild_join)
	elseif npc.vo.base_id == 10112 then			-- 许愿
		need_show = controller:getRedPointStatusByType(MainSceneCity.guild, RedPointType.guild_wish)
	elseif npc.vo.base_id == 10111 then			-- 联盟战
		need_show = controller:getRedPointStatusByType(MainSceneCity.guild, RedPointType.guild_war)
	elseif npc.vo.base_id == 10110 then			-- 副本
		need_show = controller:getRedPointStatusByType(MainSceneCity.guild, RedPointType.guild_boss)
	elseif npc.vo.base_id == 10101 then			-- 福利天使(包含了红包和等级礼包)
		--need_show = controller:getRedPointStatusByType(MainSceneCity.guild, RedPointType.guild_red)
		--if need_show == false then
			need_show = controller:getRedPointStatusByType(MainSceneCity.guild, RedPointType.guild_member_red)
		--end
		if need_show == false then
			need_show = controller:getRedPointStatusByType(MainSceneCity.guild, RedPointType.guild_lev_gift)
		end
		if need_show == false then
			need_show = controller:getRedPointStatusByType(MainSceneCity.guild, RedPointType.guild_daily)
		end
	end
	if npc.showRedPoint then
		npc:showRedPoint(need_show)
	end
end

--==============================--
--desc:根据红点类型,显示npc的红点
--time:2017-10-17 11:11:32
--@type:
--@return 
--==============================--
function RoleScene:updateNpcRedStatusByType(type)
	if type == nil or self.unit_list_base == nil then return end
	local npc = nil
	if type == RedPointType.guild_tech_gift or type == RedPointType.guild_donate then
		npc = self.unit_list_base[10114]
	elseif type == RedPointType.guild_join then
		npc = self.unit_list_base[10113]
	elseif type == RedPointType.guild_wish then
		npc = self.unit_list_base[10112]
	elseif type == RedPointType.guild_war then
		npc = self.unit_list_base[10111]
	elseif type == RedPointType.guild_boss then
		npc = self.unit_list_base[10110]
	elseif --[[type == RedPointType.guild_red or]] type == RedPointType.guild_member_red or type == RedPointType.guild_lev_gift or type == RedPointType.guild_daily then
		npc = self.unit_list_base[10101]
	end
	if npc ~= nil then
		self:updateNpcRedStatus(npc)
	end
end