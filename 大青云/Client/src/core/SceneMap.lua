--
-- Created by IntelliJ IDEA.
-- User: Stefan
-- Date: 2014/6/20
-- Time: 17:33
--功能说明：游戏中场景相关，包括地形，场景光，pick等部分

--pickFlag设置
_G.enPickFlag =
{
    EPF_Null = 0, --不让点选
    EPF_Role = 1024,--npc,怪物，，游戏中的可活动物体
    EPF_CrossHere = 1,--场景中可以走过的物体
    EPF_CrossTerrain = 2,--场景中可走过的地形
    EPF_StaticNode = 4,--场景中静态物体
    EPF_Terrain = 4096;
}
_G.classlist['CSceneMap'] = 'CSceneMap'

_G.CSceneMap = {}
_G.CSceneMap.objName = 'CSceneMap'

local avatarMaterial = _Material.new()
avatarMaterial:setAmbient( 1.5, 1.5, 1.5, 1 )
avatarMaterial:setDiffuse( 0.7, 0.7, 0.7, 1 )

--decal img
CSceneMap.decalImg = _Image.new('resfile\\scn\\decal.tga')
CSceneMap.tiles = nil
CSceneMap.commShadowImg = _Image.new('resfile\\scn\\commshadow.dds')
CSceneMap.commShadowMsh = _Mesh.new()
CSceneMap.commShadowPos = _Vector3.new()

--流光环境光
CSceneMap.amb = _AmbientLight.new()
CSceneMap.amb.color = _Color.White

CSceneMap.useFmt = {state=true,callback=nil,time=0,interval=100,step=20,nodes=nil,pos=0};
CSceneMap.useShadow = true;
CSceneMap.edgeColor = nil;


function CSceneMap:new()
    local obj = {};
    obj.objScene = nil;
    obj.setAllEntity = {};
    obj.sceneLoader = nil;
    obj.sceneLoaded = false;
    obj.sceneLoading = nil;
    obj.OnSceneLoaded = nil;
	obj.effects = nil;
	obj.shadows = nil;
	self:SetLights();
    setmetatable(obj,{__index = CSceneMap});
    return obj;
end;

function CSceneMap:SetLights()
	local mapid = CPlayerMap:GetCurMapID();
	local light = Light.GetEntityLight(enEntType.eEntType_Player,mapid);
	local player = light.selectlight;
	self.skyPlayerSelect = self.skyPlayerSelect or _SkyLight.new();
	self.skyPlayerSelect.color = player.color;
	self.skyPlayerSelect.power = player.power;
	self.skyPlayerSelect.backLight = player.backLight;
	self.skyPlayerSelect.fogLight = player.fogLight;
	
	light = Light.GetEntityLight(enEntType.eEntType_Npc,mapid);
	local npc = light.selectlight;
	self.skyNpcSelect = self.skyNpcSelect or _SkyLight.new();
	self.skyNpcSelect.color = npc.color;
	self.skyNpcSelect.power = npc.power;
	self.skyNpcSelect.backLight = npc.backLight;
	self.skyNpcSelect.fogLight = npc.fogLight;
	
	light = Light.GetEntityLight(enEntType.eEntType_Monster,mapid);
	local monster = light.selectlight;
	self.skyMonsterSelect = self.skyMonsterSelect or _SkyLight.new();
	self.skyMonsterSelect.color = monster.color;
	self.skyMonsterSelect.power = monster.power;
	self.skyMonsterSelect.backLight = monster.backLight;
	self.skyMonsterSelect.fogLight = monster.fogLight;
	CSceneMap.edgeColor = light.edge.color;
	local star = light.starlight;
	self.skyMonsterStar = self.skyMonsterStar or _SkyLight.new();
	self.skyMonsterStar.color = star.color;
	self.skyMonsterStar.power = star.power;
	self.skyMonsterStar.backLight = star.backLight;
	self.skyMonsterStar.fogLight = star.fogLight;
	
end

--卸载场景
function CSceneMap:Unload()
    Debug("######### CSceneMap:Unload()", self.sceneFile)
    for i,entity in pairs(self.setAllEntity) do
        if entity and not entity.dnotDelete then
            entity:ExitSceneMap()
            entity:Destroy()
            entity = nil
        end
    end;
    self.setAllEntity = {};
    self.sceneLoader = nil;
    self.sceneLoaded = false;
    self.sceneLoading = nil;
    self.OnSceneLoaded = nil;
    if self.objScene then
        --[[
        Debug("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
        self.objScene.pfxPlayer:enumPfx('', function(pfx)
            Debug("##############################################remove pfx ", pfx.name , pfx.resname)
            pfx:clearEmitters()
            pfx.keepInPlayer = false
            pfx:stop()
        end)
        --]]
        self.objScene.pfxPlayer:stopAll(true);
        self.objScene.pfxPlayer:clearParams()
        self.objScene:clear();
        self.objScene = nil;

    end;

    if self.sSceneInfo and self.sSceneInfo.dwDungeonId > 0 then
        self.currDungeonConf = nil;
    end
    self.tiles = nil
	self.jiguan = nil;
	
	self.useFmt.nodes = nil;
	self.useFmt.pos = 0;
	self.useFmt.time = 0;
	self.useFmt.callback = nil;
end;

--加载场景
function CSceneMap:Load(sSceneInfo, OnSceneRenderFunc, OnSceneRenderCasterFunc)
    GameController.loadingState = true
    local mapId = sSceneInfo.dwMapID
	local light = Light.GetSceneLight(mapId);
    local skyRange = light.skyRange;
	self.sSceneInfo = sSceneInfo;
	self.sceneFile =  sSceneInfo.res
    if self.sceneFile == "" then
        Debug("CSceneMap:Load can not find scn res");
        return false
    end;
    self:Unload();
    LuaGC();
	
	self.sceneLoading = true;
    --_startTiming()
    --_sys.asyncLoad = true --注意，这时候不能打开异步,打开会出问题，专家没给出原理，先用着
    _app.console:print('Async load scene :')
    asyncLoad(false,"scene");
    self.sceneLoader = _Loader.new()
	local f = string.sub(self.sceneFile,1,#self.sceneFile-4);
	if MainPlayerModel.humanDetailInfo.eaProf then
		local profPack = f .. "_prof" .. MainPlayerModel.humanDetailInfo.eaProf;
		self.sceneLoader:loadGroup(f,profPack);
	else
		self.sceneLoader:loadGroup(f)
	end

    self.sceneLoader:onProgress(function(p)
        --Debug('current progress is '..p)
        --_app.console:print('current progress is '..p)
    end)
    self.sceneLoader:onFinish(function()
        Debug("finished")
        self.objScene = _Scene.new(self.sceneFile);
        self.objScene.skyRange = skyRange;  --天空盒剪切的距离
        --self.objScene.detailRange = 500; --细节物体的显示范围
        --render
        asyncLoad(true,"scene");
        local fn = function(node)
            if OnSceneRenderFunc then
                OnSceneRenderFunc(node)
            else
                self:OnSceneRender(node)
            end
        end;
        local casterfunc = function(node)
            if OnSceneRenderCasterFunc then
				OnSceneRenderCasterFunc(node)
            else
                self:OnSceneRenderCaster(node)
            end
        end

        self.objScene:onRender(fn);
        self.objScene:onRenderCaster(casterfunc)
        --terrain
		if not self.objScene.terrain then
			local errorMsg = "Scene new but  terrain is nil.scenename:" .. self.sceneFile .. "  memUsage = " .. _sys.memUsage;
			_debug:throwException(errorMsg);
		end
        if self.objScene.terrain.hasLogicHeight then
            self.getSceneHeight = self.getSceneHeightNew;
            self.DoPick = self.DoPickNew;
            --assert(false)
        else
            self.getSceneHeight = self.getSceneHeightOld;
            self.DoPick = self.DoPickOld;
            --assert(false)
        end;
        self.objScene.terrain.show = true;
        if self.objScene and self.objScene.pfxPlayer then
            self.objScene.pfxPlayer.terrain = self.objScene.terrain
        end
        local nodes = self.objScene:getNodes()
        --self.objScene.nodeList = nodes
        --pick
		
		self.shadows = {};
        for i,v in pairs(nodes) do
			
            if v.terrain then --地形节点
                v.pickFlag = enPickFlag.EPF_Terrain;
            else
                v.pickFlag = enPickFlag.EPF_StaticNode;
            end;

            if v.mesh then
                local cross = false;
                local fn1 = function(mesh,name)
                    if string.find(name,"crosshere") then
                        cross = true;
                    end;
                end;
                v.mesh:enumMesh("",true,fn1);
                if cross then
                    v.pickFlag = enPickFlag.EPF_Terrain;
                end
				
				if self.useFmt then
					if not v.fmt then
						local mn = FileFormatTransform(v.name,'fmt');
						if mn then
							if _sys:fileExist(mn,false) then
								v.mesh:loadLMaterialManager(mn);	--TODO NormalMap
							end
						end
						v.fmt = true;
					end
				end

				v.logicname = tostring(v);
				if v.isShadowCaster then
					local shadow = {};
					shadow.name = v.name;
					shadow.logicname = v.logicname;
					shadow.range = skyRange/2;
					shadow.using = false;
					shadow.pos = v.transform:getTranslation();
					shadow.node = v;
					self.shadows[shadow.logicname] = shadow;
				end
            end
        end;

        --local nodes = self.objScene:getNodes()

        --for i, v in ipairs(nodes) do
        --    if v.mesh then
        --        Debug("######node.resname", v.mesh.resname)
        --        self.objScene:del(v)
        --     end
        --end
        --light
        local lights = self.objScene.graData:getLights()
        local skylight
        for i,v in pairs(lights) do
            if v.name == 'skylight' then
                skylight = v;
                Debug("skylight", skylight)
                break;
            end
        end

        --光影调试点
		if not skylight then
			local errorMsg = "No skylight in Scene.scenename:" .. self.sceneFile;
			_debug:throwException(errorMsg);
		end
		
        --if _G.lightShadowQualitys[_G.lightShadowQuality].openRealShadow then
            _rd.shadowMode = _RenderDevice.ShadowMap1
			--skylight.direction.x = 0 
			--skylight.direction.y = 0 
			--skylight.direction.z = -1
			_rd.shadowLight = skylight.direction
			_rd.shadowMapSize = 1024 * 4
		--end
        --path
		
		local fname = GetExtension(self.sceneFile);
        local path = "resfile\\scn\\terrain\\"..fname..'.cog';
		
        self.objPathFinder = _PathFinder.new();
        self.objPathFinder:loadPath(path);
		AreaPathFinder:SetPathFinder(self.objPathFinder);
        Debug("CSceneMap:sceneFile: ", self.sceneFile)
        Debug("CSceneMap:Path Load: ", path)
        --_rd.camera:setBlocker( self.objScene, self.objScene.pfbits.bitMark( 'camerahit' ) )
        --_rd.camera.blockRebound = 10
		
		--shader预编译，解决首次绘制场景卡
		if isPublic then
			_sys:loadShader("resfile\\shr\\" .. fname .. ".shr") --QA生成的 
		end
		
		local final = function()
			--处理副本机关相关
			self:GenConf()
			if RenderConfig.show9Tile then
				self:BuildTiles()
			end
			self.sceneLoaded = true
			self.sceneLoading = false;
			if self.onSceneLoaded then
				self.onSceneLoaded()
			end
			GameController.loadingState = false
			LuaGC();
		end
		
		self.effects = {};
		self.objScene.pfxPlayer:enumPfx('', function(pfx)
			local effect = {};
			effect.name = pfx.name;
			effect.logicname = tostring(pfx);
			effect.transform = pfx.transform:clone();
			effect.pos = effect.transform:getTranslation();
			effect.playing = false;
			effect.range = skyRange/4;
			table.push(self.effects,effect);
			
        end)
		self.objScene.pfxPlayer:stopAll(true);
        self.objScene.pfxPlayer:clearParams();
		
		final();
		
		self:SetLights();
		-- self:ExecFmt(final);
    end)
end;

function CSceneMap:BuildTiles()
	Debug("ten.grid", self.objScene.terrain.grid)
	Debug("ten.gridSize", self.objScene.terrain.gridSize)
	Debug("ten.tileX", self.objScene.terrain.tileX)
	Debug("ten.tileY", self.objScene.terrain.tileY)
	Debug("ten.w", self.objScene.terrain.w)
	Debug("ten.l", self.objScene.terrain.l)
	self.tiles = {}
	local layer = self.objScene.terrain.heightLayer;
	self.objScene.terrain.heightLayer = 1;

	for x = 1, self.objScene.terrain.tileX do
        self.tiles[x] = {}
        for y = 1, self.objScene.terrain.tileY do
            self.tiles[x][y] = {}
            local g = self.tiles[x][y]
			local rect = self.objScene.terrain:getTileRect(x, y)
			if x == 1 and y == 1 then Debug('TileRect: ', rect.width, rect.height) end
            g.decal = self.objScene.terrain:buildDecal(self.decalImg, _Color.Green, rect)
        end
    end
	
	self.objScene.terrain.heightLayer = layer;
end

function CSceneMap:DrawTile(x, y)
   --Debug(x, y)
   if x > 0 and y > 0 and x < self.objScene.terrain.tileX 
		and y < self.objScene.terrain.tileY then
		if self.tiles and self.tiles[x] and self.tiles[x][y] then self.tiles[x][y].decal:drawMesh() end
	end
end

function CSceneMap:Draw9Tile()
	local pos = MainPlayerController:GetPos()
	if pos == nil then return end

    local t = self.objScene.terrain:getTile(pos.x, pos.y)
	--Debug("t: ", t.x, t.y)

	self:DrawTile(t.x, t.y)
	self:DrawTile(t.x, t.y - 1)
	self:DrawTile(t.x, t.y + 1)
	self:DrawTile(t.x - 1, t.y)
	self:DrawTile(t.x - 1, t.y - 1)
	self:DrawTile(t.x - 1, t.y + 1)
	self:DrawTile(t.x + 1, t.y)
	self:DrawTile(t.x + 1, t.y - 1)
	self:DrawTile(t.x + 1, t.y + 1)
end
-- 画阻挡x,y z=0平面
function CSceneMap:DrawWall()
	local objScene = self.objScene;
	objScene.graData:clearFogs()
	objScene.graData:clearAreas()
	objScene.skyBox = nil
	CPlayerControl.showName = false
	local orbits =  objScene.graData:getOrbits()
	if not orbits[1] then return end
	local changed = {}
	for i, v in pairs(orbits) do
			
		local tmp = _Orbit.new(v)
		table.insert(changed, tmp)
	end
	
	for i, v in pairs(changed) do
		for _, p in pairs(v.points) do
			p.z = 0;
		end
	end
	
	
	for i, v in pairs(changed) do
		--v:draw(_Color.Red)
	end
	
	local player = MainPlayerController:GetPlayer();
	if player then 
		local pos = player:GetPos()
			
		_rd:draw3DLine(pos.x, pos.y, pos.z + 0 , pos.x, pos.y+80, pos.z + 0, _Color.Green) 		-- axis y
		_rd:draw3DLine(pos.x, pos.y, pos.z + 0 , pos.x+80, pos.y+80, pos.z + 0, _Color.Orange)  -- 
		_rd:draw3DLine(pos.x, pos.y, pos.z + 0 , pos.x+80, pos.y, pos.z + 0, _Color.Red) 		-- axis x
		
		local w = self.objScene.terrain.w
		local l = self.objScene.terrain.l
	
		_rd:draw3DLine(- w/2, - l/2, pos.z + 10 , w/2, -l/2,  pos.z, _Color.Orange)
		_rd:draw3DLine(w/2, -l/2, pos.z + 10 , w/2, l/2,  pos.z, _Color.Red)
		_rd:draw3DLine(w/2, l/2, pos.z + 10 , -w/2, l/2,  pos.z, _Color.Green)
		_rd:draw3DLine(-w/2, l/2, pos.z + 10 , -w/2, -l/2,  pos.z, _Color.White)
		self.objPathFinder:draw(pos.z)
		
	end
	
	
	
end


--重置场景
function CSceneMap:Reset()
    for i,entity in pairs(self.setAllEntity) do
        entity:ExitSceneMap();
        entity:Destroy();
    end;
    self.setAllEntity = {};
    self.tiles = nil;
end;

function CSceneMap:OnPreRender(e)
    --先更新Node位置
    --[[
    --先算马,这种做法是为了避免骑乘时人抖动
    for i,entity in pairs(self.setAllEntity) do
        if entity.avtName == 'horse' then
            entity:Update(e);
        end
    end;

    --再计算其它
    for i,entity in pairs(self.setAllEntity) do
        if entity.avtName ~= 'horse' then
            entity:Update(e);
        end
    end;
    --]]
    for i, entity in pairs(self.setAllEntity) do
        entity:Update(e);
    end;
end
function CSceneMap:Update(e)

    --Debug("CSceneMap:Update")
	if RenderConfig.isDebugDrawBoard then 
		_rd:useDrawBoard(RenderConfig.screenDB, _Color.Black)
	end
	
    self:OnPreRender(e)
	
	
    --
	--然后渲染
	if self.objScene then
       if self.sceneLoaded then
            if RenderConfig.showScene then
				if CPlayerMap.fogclipper then
					_rd:useClipper(CPlayerMap.fogclipper);
				end
				self.objScene:render();
				if CPlayerMap.fogclipper then
					_rd:popClipper(CPlayerMap.fogclipper);
				end
			end
       else
            _app.console:print("sceneLoader.progress: " .. self.sceneLoader.progress)
       end
	   
    end;
	
    if CPlayerControl.bDrawPath then
        self.objPathFinder:draw(MainPlayerController:GetPlayer():GetPos().z)
    end;
    -- if CPlayerControl.AreaRect then
        -- local pos = MainPlayerController:GetPlayer():GetPos()
        -- local camp = MainPlayerController:GetPlayer():GetCamp()
        -- local mapId = CPlayerMap:GetCurMapID()
        -- local mapInfo = t_map[mapId]
        -- local safeareaConfig = mapInfo.safearea
        -- if not safeareaConfig or safeareaConfig == "" then
            -- return false
        -- end
        -- if mapInfo.safearea_type == 0 then
            -- local list = GetPoundTable(safeareaConfig)
            -- for i = 1, #list do
                -- local point = list[i]
                -- local pointTable = GetCommaTable(point)
                -- local campConfig = tonumber(pointTable[1])
                -- if camp == campConfig or campConfig == 0 then
                    -- local x1, y1 = tonumber(pointTable[2]), tonumber(pointTable[3])
                    -- local x2, y2 = tonumber(pointTable[4]), tonumber(pointTable[5])
                    -- _rd:draw3DRect((x1 + x2) / 2, (y1 + y2) / 2, pos.z+20, (x2 - x1)/2, 0, 0, 0, (y2 - y1)/2, 0, _Color.Blue)
                -- end
            -- end
        -- elseif mapInfo.safearea_type == 1 then
            -- local list = GetPoundTable(safeareaConfig)
            -- for i = 1, #list do
                -- local point = list[i]
                -- local pointTable = GetCommaTable(point)
                -- local campConfig = tonumber(pointTable[1])
                -- if camp == campConfig or campConfig == 0 then
                    -- local pos1 = {x = tonumber(pointTable[2]), y = tonumber(pointTable[3])}
                    -- local pos2 = {x = tonumber(pointTable[4]), y = tonumber(pointTable[5])}
                    -- local pos3 = {x = tonumber(pointTable[6]), y = tonumber(pointTable[7])}
                    -- local pos4 = {x = tonumber(pointTable[8]), y = tonumber(pointTable[9])}
                    -- _rd:draw3DRect((pos1.x + pos3.x) / 2, (pos1.y + pos3.y) / 2, pos.z+20, (pos1.x - pos2.x)/2, (pos1.y - pos2.y)/2, 0, (pos1.x - pos2.x)/2, (pos1.y - pos3.y)/2, 0, _Color.Blue)
                -- end
            -- end
        -- end
    -- end
	-- if self.objScene then
		-- self:OnPostRender()
	-- end
	-- if RenderConfig.isDebugDrawBoard then 
		-- _rd:resetDrawBoard()
		-- RenderConfig.screenDB:drawImage(0, 0, RenderConfig.screenW, RenderConfig.screenH)
	-- end
end;

local infofont = _Font.new( "SIMHEI", 10, 0, 1, true, false, false )
local s = ""
local scalefont = _Font.new( "SIMHEI", 10, 0, 1, true, false, false )
scalefont.edgeColor = 0xFF000000
scalefont.textColor = 0xFFA4D0EA
local scales = '您屏幕过小，已为您自动缩放UI'
function CSceneMap:OnPostRender()
	if UIManager.nWinWidth>_rd.w or UIManager.nWinHeight>_rd.h then
		scalefont:drawText(_rd.w/2, 0,_rd.w/2, 0, scales,_Font.hCenter + _Font.vTop)
	end

    if _sys.showStat then
        s = ('gc: %.02fMB'):format(collectgarbage('count')/1024)
        s = s .. "\n"
        --[[
        s = s .. ("enr: %d"):format(self:GetEntityNum())
        s = s .. "\n"
        s = s .. ("pr: %d"):format(CPlayerMap:GetPlayerNum())
        s = s .. "\n"
        s = s .. ("mr: %d"):format(MonsterModel:GetMonsterNum())
        s = s .. "\n"
        s = s .. ('nr: %d'):format(NpcModel:GetNpcNum())
        s = s .. "\n"
        s = s .. ("ir: %d"):format(MainPlayerModel:GetItemNum())
        s = s .. "\n"
        s = s .. ("cr: %d"):format(CollectionModel:GetCollectionNum())
        s = s .. "\n"

        local pos = MainPlayerController:GetPos()
        if pos then
            local t = self.objScene.terrain:getTile(pos.x, pos.y)
            s = s .. ("tx: %d"):format(t.x)
            s = s .. (" ty: %d"):format(t.y)
        end
        --]]
        infofont:drawText(10, 110, 80, 16, s)
    end
    
	if RenderConfig.show9Tile then
        self:Draw9Tile()
    end
	
	if RenderConfig.showWall then
        self:DrawWall()
    end

    for _, monster in pairs(_G.MonsterModel.AllNodes) do
		if monster and monster:IsDrawDecal() then
            monster.avatar:DrawDecal()
        end
    end

    if CPlayerMap.allMapScriptNode then
        for index = #CPlayerMap.allMapScriptNode, 1, -1 do
            local avatar = CPlayerMap.allMapScriptNode[index]
            if avatar and avatar:IsDrawDecal() then
                avatar:DrawDecal()
            end
        end
    end

	for _, entity in pairs(self.setAllEntity) do
		if entity.objNode.dwType == enEntType.eEntType_Npc then
			entity:DrawDecal()
        elseif entity.objNode.dwType == enEntType.eEntType_Player then
			if not GameController.loginState then
				entity:DrawDecal()
			end
		end
    end
	
end

--------------------------------------------------------------------------------
--render for test
--------------------------------------------------------------------------------
--[[
function CSceneMap:OnSceneRender(node)
    _rd.shadowReceiver = false;
    _rd.shadowCaster = false;
    if node.mesh then
        node.mesh:drawMesh()
    elseif node.terrain then
      _rd.shadowReceiver = true;
        node.terrain:draw()
       _rd.shadowReceiver = false;
    end
end
--]]

local alpaBlender = _Blender.new() ---处理摄像机阻挡，尚未启用
-- alpaBlender:additive(0xffffffff)
-- alpaBlender:blend(0xffffffff,0x3cffffff,10000)
local eee = 0

_rd.screenBlender = _Blender.new();		--用于做屏幕特效。

_G.BlenderFlag = 
{
	None = 0,
	FadeIn = 1,
	FadeOut = 2,
}

--render for production
function CSceneMap:OnSceneRender(node)

	self:DrawWaterNode(node);

    _rd.shadowCaster = false
    _rd.shadowReceiver = false

    if _G.drawAxis then _rd:drawAxis(10) end

    if node.terrain then
        --if _G.lightShadowQualitys[_G.lightShadowQuality].openRealShadow then
            _rd.shadowReceiver = true
        --end
        if CPlayerMap.objPointLight then
            _rd:useLight(CPlayerMap.objPointLight)
        end
		if CPlayerMap.facePointLight then
            _rd:useLight(CPlayerMap.facePointLight)
		end
		if CPlayerMap.EffectLight and CPlayerMap.EffectLight.power ~= 0 then
			_rd:useLight(CPlayerMap.EffectLight)
		end
        if WeatherController.objSkyLight then
            _rd:useLight(WeatherController.objSkyLight) --skylight
        end
        if WeatherController.fog then
            ---todo 这里这样处理雾可能会有问题 稍后再处理
            _rd:useFog(WeatherController.fog)
        end
        node.terrain:draw()
        if CPlayerMap.objPointLight then
            _rd:popLight()
        end
		if CPlayerMap.facePointLight then
            _rd:popLight()
        end
		if CPlayerMap.EffectLight and CPlayerMap.EffectLight.power ~= 0 then
			_rd:popLight()
		end
        if WeatherController.objSkyLight then
            _rd:popLight() --skylight
        end
        if WeatherController.fog then
            _rd:popFog()
        end
        --if _G.lightShadowQualitys[_G.lightShadowQuality].openRealShadow then
            _rd.shadowReceiver = false
        --end
        return
    end

	-- print('---------------------_System.KeyDel'..tostring(#_G.classlist));
	-- for ii,cl in pairs(_G.classlist) do
		-- print('---------------------_System.KeyDel'..cl);
	-- end;
	
    if node.mesh then
        if node.isEntity then --程序动态加的Node
            local limitRender = CSceneMap:CheckNodeLimitRender(node)
            if not limitRender then
                CSceneMap:DrawNode(node)
            end
        elseif node.mesh.resname:find("yunhai_decal") ~= nil then --云
			_rd.shadowReceiver = false
			local mip_0 = _rd.mip
			if _G.hdMode then --高清渲染
				_rd.mip = false
			else			  --简陋渲染
				_rd.mip = true
			end
            node.mesh:drawMesh()
           _rd.mip = mip_0       
        else --场景编辑器Sen里其它Node
			_rd.shadowCaster = node.isShadowCaster and self.useShadow;
			_rd.shadowReceiver = node.isShadowReciver and self.useShadow;
			
			--[[if node.name:find('noshadow') then
				_rd.shadowCaster = false
				_rd.shadowReceiver = false
				if node.name:find('noshadowc') then
					_rd.shadowReceiver = true
				end
				if node.name:find('noshadowr') then
					_rd.shadowCaster = true
				end
			end]]
								
            if node.mesh.alpaFlag == BlenderFlag.FadeIn then
				alpaBlender:blend(0xffffffff,0x70ffffff,200)
				node.mesh.alpaFlag = BlenderFlag.None
            end
			if node.mesh.alpaFlag == BlenderFlag.FadeOut then
				alpaBlender:blend(0x70ffffff,0xffffffff,200)
				node.mesh.alpaFlag = BlenderFlag.None
			end
			if node.mesh.alpaFlag == BlenderFlag.None then
				_rd:useBlender(alpaBlender)
			 end
			 
            if CPlayerMap.objPointLight then
                _rd:useLight(CPlayerMap.objPointLight)
            end
			if CPlayerMap.facePointLight then
                _rd:useLight(CPlayerMap.facePointLight)
            end
			local mip_ = _rd.mip
			if _G.hdMode then --高清渲染
				_rd.mip = false
			else			  --简陋渲染
				_rd.mip = true
			end
			if _G.drawMeshBBox then
                node.mesh:drawBoundBox()
            end
            if _G.drawBone and node.mesh.skeleton then
                node.mesh.skeleton:drawSkeleton()
            end
			if CPlayerMap.EffectLight and CPlayerMap.EffectLight.power ~= 0 then
				_rd:useLight(CPlayerMap.EffectLight)
			end
            if WeatherController.objSkyLight then
                _rd:useLight(WeatherController.objSkyLight) --skylight
            end
            node.mesh:drawMesh()
            if node.mesh.alpaFlag == BlenderFlag.None then
                _rd:popBlender()
            end
            if CPlayerMap.objPointLight then
                _rd:popLight()
            end
			if CPlayerMap.facePointLight then
                _rd:popLight()
            end
			if CPlayerMap.EffectLight and CPlayerMap.EffectLight.power ~= 0 then
				_rd:popLight()
			end
            if WeatherController.objSkyLight then
                _rd:popLight() --skylight
            end
		
			
			_rd.mip = mip_
        end
    end
end

function CSceneMap:DrawNode(node)
    if node.entity and node.entity.horse then
        local subMeshs = node.mesh:getSubMeshs()
        for i = 1, #subMeshs do
            local mesh = subMeshs[i]
            if mesh then
                if mesh.name == "horse" then
                    CSceneMap:DrawHorseMesh(node, mesh)
                else
                    CSceneMap:DrawOtherMesh(node, mesh)
                end
            end
        end
    else
        CSceneMap:DrawOtherMesh(node, node.mesh)
    end

end

function CSceneMap:DrawOtherMesh(node, mesh)
    if node.mesh.objSelectLight then
        _rd:useLight(node.mesh.objSelectLight)
		_rd.edge = true;
		_rd.edgeColor = self.edgeColor;
    end
	
	local light = Light.GetEntityLight(node.dwType,CPlayerMap:GetCurMapID());
	local material = light.material;
    avatarMaterial:setAmbient( material.ambient, material.ambient, material.ambient, material.ambient )
    avatarMaterial:setDiffuse( material.diffuse, material.diffuse, material.diffuse, material.diffuse )				--material
    _rd:useMaterial(avatarMaterial);

    if node.mesh.objHighLight then												--hightLight
        _rd:useBlender(node.mesh.objHighLight)
    end
    if node.mesh.objGray then
        _rd:useBlender(node.mesh.objGray)
    end
    if node.mesh.objBlender then
        _rd:useBlender(node.mesh.objBlender)
    end

    if node.bIsMe 
        or node.dwType == enEntType.eEntType_Player 
        or node.dwType == enEntType.eEntType_Monster
        or node.dwType == enEntType.eEntType_Npc 
        or node.dwType == enEntType.eEntType_Item
        or node.dwType == enEntType.eEntType_Collection
        or node.dwType == enEntType.eEntType_MagicWeapon
        or node.dwType == enEntType.eEntType_Pet
        or node.dwType == enEntType.eEntType_LingShou
        or node.dwType == enEntType.eEntType_Flag
        or node.dwType == enEntType.eEntType_Patrol
        or node.dwType == enEntType.eEntType_TianShen
		or node.dwType == enEntType.eEntType_LingQi
		or node.dwType == enEntType.eEntType_MingYu
		then
		
            if node.dwType == enEntType.eEntType_Player 
                or node.dwType == enEntType.eEntType_Npc
                --or node.dwType == enEntType.eEntType_LingShou
                or node.needRealShadow == true then
                if _G.lightShadowQualitys[_G.lightShadowQuality].openRealShadow then
                    _rd.shadowCaster = true --打开阴影
                end
            end
			
			local sky = light.skylight;
			CPlayerMap.objSkyLight.color = sky.color;
			CPlayerMap.objSkyLight.power = sky.power;
			sky = light.backskylight;
			CPlayerMap.objSkyBackLight.color = sky.color;
			CPlayerMap.objSkyBackLight.power = sky.power;
            CPlayerMap.objSkyLight.backLight = false
            CPlayerMap.objSkyBackLight.backLight = true

            -- if not WeatherController.objSkyLight then
                _Vector3.sub(_rd.camera.look, _rd.camera.eye, CPlayerMap.objSkyLight.direction)
                _rd:useLight(CPlayerMap.objSkyLight) --skylight
            -- else
                --  _Vector3.sub(_rd.camera.look, _rd.camera.eye, WeatherController.objSkyLight.direction)
                -- _rd:useLight(WeatherController.objSkyLight) --skylight
            -- end
            _Vector3.sub(_rd.camera.look, _rd.camera.eye, CPlayerMap.objSkyBackLight.direction)
            if _G.lightShadowQualitys[_G.lightShadowQuality].openSkyBackLight then
                if CPlayerMap.objSkyBackLight.power ~= 0 then --skyBackLight
                    _rd:useLight(CPlayerMap.objSkyBackLight)
                end
            end
    end
    
    local mip = _rd.mip
    if _G.hdMode then         --高清渲染
        _rd.mip = false
    else                      --简陋渲染
        _rd.mip = true
    end

    mesh:drawMesh()

    _rd.mip = mip

    if _G.drawMeshBBox then node.mesh:drawBoundBox() end
    if _G.drawBone then node.mesh.skeleton:drawSkeleton() end

    if node.mesh.objSelectLight then
        _rd:popLight()
		_rd.edge = false;
    end
    _rd:popMaterial()
    if node.mesh.objHighLight then
        _rd:popBlender()
    end
    if node.mesh.objGray then
        _rd:popBlender()
    end
    if node.mesh.objBlender then
        _rd:popBlender()
    end

    if node.bIsMe 
        or node.dwType == enEntType.eEntType_Player
        or node.dwType == enEntType.eEntType_Monster
        or node.dwType == enEntType.eEntType_Npc
        or node.dwType == enEntType.eEntType_Item
        or node.dwType == enEntType.eEntType_Collection
        or node.dwType == enEntType.eEntType_MagicWeapon
        or node.dwType == enEntType.eEntType_Pet
        or node.dwType == enEntType.eEntType_LingShou
        or node.dwType == enEntType.eEntType_Flag
        or node.dwType == enEntType.eEntType_Patrol
        or node.dwType == enEntType.eEntType_TianShen
		or node.dwType == enEntType.eEntType_LingQi
		or node.dwType == enEntType.eEntType_MingYu
			then
            if node.dwType == enEntType.eEntType_Player 
                or node.dwType == enEntType.eEntType_Npc
                --or node.dwType == enEntType.eEntType_LingShou
                or node.needRealShadow == true then
                if _G.lightShadowQualitys[_G.lightShadowQuality].openRealShadow then
                    _rd.shadowCaster = false --打开阴影
                end
            end
            _rd:popLight() --skylight
            if _G.lightShadowQualitys[_G.lightShadowQuality].openSkyBackLight then
                if CPlayerMap.objSkyBackLight.power ~= 0 then --skyBackLight
                    _rd:popLight()
                end
            end
            if node.dwType == enEntType.eEntType_Player 
                or node.dwType == enEntType.eEntType_Npc 
                or node.dwType == enEntType.eEntType_MagicWeapon then
            end
    end

end

function CSceneMap:DrawHorseMesh(node, mesh)
	local light = Light.GetHorseLight(CPlayerMap:GetCurMapID());
    CPlayerMap.objSkyLight.color = light.skylight.color;
    CPlayerMap.objSkyLight.power = light.skylight.power;
    CPlayerMap.objSkyBackLight.color = light.backskylight.color;
    CPlayerMap.objSkyBackLight.power = light.backskylight.power;
    -- if WeatherController.objSkyLight then
    --     _Vector3.sub(_rd.camera.look, _rd.camera.eye, WeatherController.objSkyLight.direction)
    --     _rd:useLight(WeatherController.objSkyLight) --skylight
    -- else
        _Vector3.sub(_rd.camera.look, _rd.camera.eye, CPlayerMap.objSkyLight.direction)
        _rd:useLight(CPlayerMap.objSkyLight)
    -- end
    _Vector3.sub(_rd.camera.look, _rd.camera.eye, CPlayerMap.objSkyBackLight.direction)
    _rd:useLight(CPlayerMap.objSkyBackLight)

    local mip = _rd.mip
    if _G.hdMode then         --高清渲染
        _rd.mip = false
    else                      --简陋渲染
        _rd.mip = true
    end
    mesh:drawMesh()
    _rd.mip = mip
    _rd:popLight()
    _rd:popLight()
end

function CSceneMap:DrawWaterNode(node)
	for i, v in ipairs(self.objScene.graData:getWaters()) do
		if node.name and node.isWaterReflecter then
			if _and(v.mode, _Water.Reflect) > 0 and v:reflectionBegin() then
				if node.mesh then
					node.mesh:drawMesh()
				end
				if node.terrain then
					node.terrain:draw()
				end
				v:reflectionEnd()
			end
		end
		if node.name and node.isWaterRefracter then
			if _and(v.mode, _Water.Refract) > 0 and v:refractionBegin() then
				if node.mesh then
					node.mesh:drawMesh();
				end
				if node.terrain then
					node.terrain:draw();
				end
				v:refractionEnd()
			end
		end
	end
end

function CSceneMap:CheckNodeLimitRender(node)
    local limitRender = false
    if ArenaBattle.inArenaScene == 0 then
        if node.dwType == enEntType.eEntType_Monster then
            limitRender = CSceneMap:CheckMonsterLimitRender(node)
        elseif node.dwType == enEntType.eEntType_Player then
            limitRender = CSceneMap:CheckPlayerLimitRender(node)
		elseif node.dwType == enEntType.eEntType_MagicWeapon then
            limitRender = CSceneMap:CheckMagicWeaponLimitRender(node)
        elseif node.dwType == enEntType.eEntType_Pet then
            limitRender = CSceneMap:CheckPetLimitRender(node)
        elseif node.dwType == enEntType.eEntType_LingShou then
            limitRender = CSceneMap:CheckLingShouLimitRender(node)
		elseif node.dwType == enEntType.eEntType_TianShen then
			limitRender = CSceneMap:CheckTianShenLimitRender(node)
        end
    end
    return limitRender
end

function CSceneMap:CheckPlayerLimitRender(node)
    if node
        and node.dwType == enEntType.eEntType_Player
        and not SetSystemController.showAllPlayer
        and not (node.entity and node.entity.dwRoleID and SetSystemController.renderList[node.entity.dwRoleID])
        and not node.bIsMe then
        return true
    end
    return false
end

function CSceneMap:CheckMonsterLimitRender(node)
    if node
        and node.dwType == enEntType.eEntType_Monster
        and SetSystemController.hideMonster 
        and not MonsterController:IsBoss(node) then
        return true
    end
    return false
end

function CSceneMap:CheckMagicWeaponLimitRender(node)
	if node and
			node.dwType == enEntType.eEntType_MagicWeapon then
		local ownerId = node.entity.ownerId
		local ownerNode = CPlayerMap:GetPlayerNode(ownerId)
		if ownerId ~= MainPlayerModel.mainRoleID then
			if not SetSystemModel:GetIsShowPlayerMagicWeapon() then
				return true;
			end
		end
		return CSceneMap:CheckPlayerLimitRender(ownerNode)
	end
	return false
end

function CSceneMap:CheckTianShenLimitRender(node)
	if node and
			node.dwType == enEntType.eEntType_TianShen then
		local ownerId = node.entity.ownerId
		local ownerNode = CPlayerMap:GetPlayerNode(ownerId)
		if ownerId ~= MainPlayerModel.mainRoleID then
			if not SetSystemModel:GetIsShowPlayerTianShen() then
				return true;
			end
		end
		return CSceneMap:CheckPlayerLimitRender(ownerNode)
	end
	return false
end
function CSceneMap:CheckPetLimitRender(node)
    if node.dwType == enEntType.eEntType_Pet then
        local ownerId = node.entity.ownerId
        local ownerNode = CPlayerMap:GetPlayerNode(ownerId)
        return CSceneMap:CheckPlayerLimitRender(ownerNode)
    end
    return false
end

function CSceneMap:CheckLingShouLimitRender(node)
    if node.dwType == enEntType.eEntType_LingShou then
        local ownerId = node.entity.ownerId
        local ownerNode = CPlayerMap:GetPlayerNode(ownerId)
        return CSceneMap:CheckPlayerLimitRender(ownerNode)
    end
    return false
end

function CSceneMap:OnSceneRenderCaster(node)
    --Debug("1111111")
    _rd.shadowCaster = false
    if node.mesh then
        if node.isEntity then
            local limitRender = CSceneMap:CheckNodeLimitRender(node)
            if not limitRender then
                if node.bIsMe 
                    or node.dwType == enEntType.eEntType_Player 
                    or node.dwType == enEntType.eEntType_Monster
                    or node.dwType == enEntType.eEntType_Npc 
                    or node.dwType == enEntType.eEntType_Item
                    or node.dwType == enEntType.eEntType_LingShou
                    or node.dwType == enEntType.eEntType_Collection then
                    if node.dwType == enEntType.eEntType_Player 
                        or node.dwType == enEntType.eEntType_Npc
                        --or node.dwType == enEntType.eEntType_LingShou
                        or node.needRealShadow == true then
                        if _G.lightShadowQualitys[_G.lightShadowQuality].openRealShadow then
                            _rd.shadowCaster = true; --打开阴影
                        end
                    end
					if _rd.shadowCaster then --when true, we draw it, better performance
						node.mesh:drawMesh();
						_rd.shadowCaster = false;
					end
                end
            end
		else --场景编辑器Sen里其它Node,
			--[[_rd.shadowCaster = false
			if node.name:find('noshadow') then
				_rd.shadowCaster = false
				if node.name:find('noshadowc') then
					_rd.shadowCaster = false
				end
				if node.name:find('noshadowr') then
					_rd.shadowCaster = true
				end
			end
			if _rd.shadowCaster then --when true, we draw it, better performance
				node.mesh:drawMesh();
				_rd.shadowCaster = false;
			end]]
			
			_rd.shadowCaster  = node.logicShadow and self.useShadow;
			if _rd.shadowCaster then
				node.mesh:drawMesh();
				_rd.shadowCaster = false;
				
			end
        end;
    end;
end

--------------------------------------------------------------------------------
--pick
--------------------------------------------------------------------------------
--可行走区域的pick, 参数x, y表示窗口x,y坐标, 如果pick成功返回picked对象，否则返回nil
local v1,v2 = _Vector3.new(),_Vector3.new()
function CSceneMap:DoPickOld( x, y )
    if not self.objScene then
        return
    end;
    local ray = _rd:buildRay( x, y );
    v1.x, v1.y, v1.z = ray.x1, ray.y1, ray.z1;
    v2.x, v2.y, v2.z = ray.x2, ray.y2, ray.z2;
    local picked = self.objScene:pick(v1,v2,enPickFlag.EPF_Terrain);
    return picked;
end
function CSceneMap:DoPickNew( x, y )
    --Debug("DoPickNew")
    if not self.objScene then
        return
    end;
    self.objScene.terrainNode.visible = false;
    self.objScene.logicNode.visible = true;
    --self.objScene.logicNode.pickFlag = 11
    local ray = _rd:buildRay( x, y );
    local picked = self.objScene:pick(ray, enPickFlag.EPF_Terrain);
    self.objScene.terrainNode.visible = true;
    self.objScene.logicNode.visible = false;
    return picked;
end
--对人进行pick, 参数x, y表示窗口x,y坐标, 如果pick成功返回picked对象，否则返回nil
local v1,v2 = _Vector3.new(),_Vector3.new()
function CSceneMap:DoRayQuery(ray)
    if not self.objScene then return end;
    v1.x, v1.y, v1.z = ray.x1, ray.y1, ray.z1;
    v2.x, v2.y, v2.z = ray.x2, ray.y2, ray.z2;
    local picked = self.objScene:pick(v1,v2,enPickFlag.EPF_Role)
    return picked;
end;
local v1,v2 = _Vector3.new(),_Vector3.new()
function CSceneMap:DoEntityPick( x, y )
    if not self.objScene then return end;
    local ray = _rd:buildRay( x, y )
    v1.x, v1.y, v1.z = ray.x1, ray.y1, ray.z1;
    v2.x, v2.y, v2.z = ray.x2, ray.y2, ray.z2;
    local picked = self.objScene:pick(v1,v2,enPickFlag.EPF_Role)
    return picked;
end;
--得到屏幕pick到的地形高度
local org,dir = _Vector3.new(),_Vector3.new()
function CSceneMap:getSceneHeightOld( x, y )
    if not self.objScene then
        return
    end;
    org.x, org.y, org.z = x, y, 500;
    dir.x, dir.y, dir.z = 0, 0, -1;

    local res = self.objScene:pick(org,dir,enPickFlag.EPF_Terrain);
    if ( res and res ~= "" ) then
        return res.z;
    end
    return self.objScene.terrain:getHeight( x, y )
end;
function CSceneMap:getSceneHeightNew( x, y )
    if not self.objScene then
        return
    end;
    local layer = self.objScene.terrain.heightLayer;
    self.objScene.terrain.heightLayer = 1;
    local height = self.objScene.terrain:getHeight( x, y );
    self.objScene.terrain.heightLayer = layer;
    return height;
end;
function CSceneMap:getSceneLength()
    if not self.objScene then
        return
    end;
    return self.objScene.terrain.l
end;
function CSceneMap:getSceneWidth()
    if not self.objScene then
        return
    end;
    return self.objScene.terrain.w
end;
--------------------------------------------------------------------------------
--path
--------------------------------------------------------------------------------
--判断地图上某点是不是可以走
local src,dis = _Vector2.new(),_Vector2.new()
function CSceneMap:CanMoveTo(vecSrc,vecDis)
    src.x, src.y = vecSrc.x, vecSrc.y;
    dis.x, dis.y = vecDis.x, vecDis.y;
    if not self.objPathFinder:checkPoint(src.x, src.y) then
        --Debug("CSceneMap:CanMoveTo: 1")
        return false;
    end;
    if not self.objPathFinder:checkPoint(dis.x, dis.y) then
        --Debug("CSceneMap:CanMoveTo: 2")
        return false;
    end;
    if not self.objPathFinder:checkPath(src, dis) then
        --Debug("CSceneMap:CanMoveTo: 3")
        return false;
    end;
    return true;
end;

--检查某点是否可走
function CSceneMap:CheckPoint(x, y)
    return self.objPathFinder:checkPoint(x, y);
end
---
--- 是否开启空气墙, falg为true,表示启用墙
---
function CSceneMap:SwitchAirWall(wallname, flag)
    --local wallname = string.format('block%03d',wallindex);
    --[[
	for _, v in pairs(self.objScene:getNodes()) do
		--Debug("v.name = ", v.name)
        if v.name == wallname then
			Debug("xdddddddddddddddd", wallname)
            if flag then
                self.objPathFinder:enableGroup(wallname, true)
            else
                self.objPathFinder:enableGroup(wallname, false)
            end
        end
    end
	--]]
	if flag then
        self.objPathFinder:enableGroup(wallname, true)
	else
        self.objPathFinder:enableGroup(wallname, false)
    end
end

---
-- 生成副本配置
---
function CSceneMap:GenConf()
    if self.sSceneInfo.dwDungeonId == 0 then return; end

    self.currDungeonConf = _G.t_dungeons[self.sSceneInfo.dwDungeonId];
	if self.currDungeonConf == nil then return end
    local block_list = self.currDungeonConf['block_list']
    if block_list ~= "" or block_list ~= nil then
        local blocks = split(block_list, "#");
        Debug(Utils.dump(blocks))
        for i=1, #blocks do
            self:SwitchAirWall(blocks[i], true); --默认启用墙
        end
    end

    if self.currDungeonConf["mesh_list"] ~= "" or self.currDungeonConf["mesh_list"] ~= nil then
        local tmp = split(self.currDungeonConf["mesh_list"], "#")
        self.blockMap = {}
        for i, v in pairs(tmp) do
            local item = split(v, ":")
            self.blockMap[item[1]] = item[2]
        end
    end
    if self.currDungeonConf["mesh_san"] ~= "" or self.currDungeonConf["mesh_san"] ~= nil then
        local meshStateSans = split(self.currDungeonConf["mesh_san"], "#")
        self.meshStateSanMap = {}
        for i, v in pairs(meshStateSans) do
            local tmp = split(v, "$")
            local mesh = tmp[1]
            self.meshStateSanMap[mesh] = {}
            local stateSans = split(tmp[2], "|")

            for i, v in pairs(stateSans) do
                local tmp1 = split(v, ":")
                local state = tmp1[1]
                local san = tmp1[2]
                self.meshStateSanMap[mesh][state] = san
            end
        end
    end
	if #self.currDungeonConf["jiguan_list"] > 0  then --or self.currDungeonConf["jiguan_list"] ~= nil then
		self.jiguan = {};
		local tmp = split(self.currDungeonConf["jiguan_list"], "#");
        for i, v in pairs(tmp) do
            local item = split(v, ":")
            self.jiguan[item[1]] = toint(item[2]);
        end
	end

end

---
-- @param wallname
-- @param flag flag为true,表示启用墙
--
function CSceneMap:PlayTriggerAnima(wallname, flag)

    local mesh = self.blockMap[wallname]
    local stateSan = self.meshStateSanMap[mesh]
	Debug("PlayTriggerAnima: ", mesh, stateSan, flag)
    if mesh == nil or stateSan == nil then return;end
    local san;
    if flag then --得到关闭动画
        san = stateSan["close"]
    else
        san = stateSan["open"]
    end

    local meshNode;
    for _, v in pairs(self.objScene:getNodes()) do
        --Debug("v.name = ", v.name, v.resname)
        if v.name == mesh or v.name == "\\" .. mesh then
            meshNode = v;
            break;
        end
    end
    if meshNode ~= nil then
        local mesh = meshNode.mesh;
        Debug("meshNode: ", meshNode.skeletonRes, san, meshNode.name, meshNode.resname)
        if mesh.skeleton == nil then
			Debug("meshNode: 1", meshNode.skeletonRes, san)
            local skl = _Skeleton.new(meshNode.skeletonRes)
            mesh:attachSkeleton(skl)
        end
        mesh.skeleton:stopAnimas()
        local anima = mesh.skeleton:addAnima(san)
        Debug("meshNode: 2", anima.resname, san)
        anima:play()
    end
end

---
-- 机关动作
-- @nodeName 节点名
-- @aniName	动作
--
function CSceneMap:PlayTaskAnima(nodeName,aniName,callback,loop,removeold)
	if not self.sceneLoaded then return; end
	if not self.objScene then return; end
	local nodes = self.objScene:getNodes();
	local node = nil;
	for i,v in ipairs(nodes) do
		if v.mesh and v.mesh.skeleton and v.name:find(nodeName) then
            node = v;
			-- FPrint(v.name)
            break;
        end
	end
	if not node then return; end
	if removeold then
		node.mesh.skeleton:clearAnimas();
	end
	local anima = node.mesh.skeleton:getAnima(aniName);
	if not anima then
		anima = node.mesh.skeleton:addAnima(aniName);
	end
	anima:onStop(function()
        if callback then
            callback(self, anima)
			callback = nil
        end
        asyncLoad(true);
    end)
	
	anima:play();
	anima.loop = loop or false
end


----在场景的一个节点上播放特效
function CSceneMap:PlayPfxOnNode(nodeName, boneName, pfxName)
	if not self.sceneLoaded then return; end
	if not self.objScene then return; end
	local nodes = self.objScene:getNodes();
	local node = nil;
	for i,v in ipairs(nodes) do
		if v.mesh and v.mesh.skeleton and v.name:find(nodeName) then
            node = v;
            break;
        end
	end
	if not node then return; end
	local skl = node.mesh.skeleton
	_sys.asyncLoad = true --异步
	--Debug("#######################", nodeName, boneName, pfxName)
    local pfx = skl.pfxPlayer:play(pfxName, pfxName);
    if boneName and boneName ~= "" then
        local BindMat  = skl:getBone(boneName);
        if BindMat then
            pfx.transform = BindMat;
        end
		--Debug('SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS')
    end
    pfx.keepInPlayer = false;
end

--------------------------------------------------------------------------------
--node
--------------------------------------------------------------------------------
--添加一个地图对象
function CSceneMap:AddEntity(objEntity,mat)
    local objNode = self:Add(objEntity,mat);
    if not objNode then
        assert(false)
    end;

    self.setAllEntity[tostring(objEntity)] = objEntity;
    return objNode;
end;
--删除一个地图对象
function CSceneMap:DelEntity(objEntity)
    self.setAllEntity[tostring(objEntity)] = nil;
    if not self:Del(objEntity.objNode) then
        return false;
    end;
    return true;
end;
function CSceneMap:Add(objEntity,mat)										--添加到场景
    if not objEntity then assert(false) end;
    local objNode = self.objScene:add(objEntity.objMesh, mat);
    if not objNode then assert(false) end;
    --local objBBox = objEntity.objMesh:getBoundBox();
    --local width = objBBox.x1 - objBBox.x2;
    --local length = objBBox.y1 - objBBox.y2;
    --local height = objBBox.z1 - objBBox.z2;
    --objNode.fShadowSize = math.sqrt(width*width + length*length);
    --objNode.fShadowHight = math.abs(height)/2;
    -- if objEntity.scaleValue then
    --     local scaleValue = objEntity.scaleValue;
    --     objNode.transform:mulScalingLeft(scaleValue,scaleValue,scaleValue);
    -- end;
    objNode.pickFlag = objEntity.pickFlag;
    --objNode.pickBox = true  --pick boundbox
    return objNode;
end;

function CSceneMap:Del(objNode)
    if not self.objScene then return end;
    if not objNode then return end;
    self.objScene:del(objNode);
    return true;
end;

function CSceneMap:GetEntityNum()
    local count = 0
    for _, v in pairs(self.setAllEntity) do
        if v ~= nil then
            count = count + 1
        end
    end
    return count
end
--------------------------------------------------------------------------------
--particle
--------------------------------------------------------------------------------
local mat =_Matrix3D.new();

--特效特效<外部接口>
function CSceneMap:PlayerPfx(dwPfxID, vecStart, vecStop, dwTime)
    local pfxCfg = ResPfxConfig[dwPfxID]
    if not pfxCfg then
        return nil
    end

    if not vecStart then
        return nil;
    end;

    mat:setTranslation(vecStart);
    if vecStop then
        mat:setTranslation(vecStop, dwTime);
    end;
    
    return self:DoPfxPlayer(tostring(dwPfxID), pfxCfg, mat)
end

--所有特效都通过改函数
local axisx,axisy,axisz = _Vector3.new(1,0,0),_Vector3.new(0,1,0),_Vector3.new(0,0,1)
function CSceneMap:DoPfxPlayer(dwName,pfxCfg,mat)
    if pfxCfg.RotationStart then
        if pfxCfg.RotationStart.x > 0 then
            mat:mulRotationLeft(axisx,pfxCfg.RotationStart.x);
        end;
        if pfxCfg.RotationStart.y > 0 then
            mat:mulRotationLeft(axisy,pfxCfg.RotationStart.y);
        end;
        if pfxCfg.RotationStart.z > 0 then
            mat:mulRotationLeft(axisz,pfxCfg.RotationStart.z);
        end;
    end;
    if pfxCfg.RotationStop then
        if pfxCfg.RotationStop.x > 0 then
            mat:mulRotationLeft(axisx,pfxCfg.RotationStop.x,pfxCfg.RotationTime);
        end;
        if pfxCfg.RotationStop.y > 0 then
            mat:mulRotationLeft(axisy,pfxCfg.RotationStop.y,pfxCfg.RotationTime);
        end;
        if pfxCfg.RotationStop.z > 0 then
            mat:mulRotationLeft(axisz,pfxCfg.RotationStop.z,pfxCfg.RotationTime);
        end;
    end;

    if pfxCfg.ScalingStart then
        mat:mulScalingLeft(pfxCfg.ScalingStart);
    end;
    if pfxCfg.ScalingStop then
        mat:mulScalingLeft(pfxCfg.ScalingStop,pfxCfg.ScalingTime);
    end;

    if pfxCfg.MoveStart then
        mat:mulTranslationRight(pfxCfg.MoveStart);
    end;
    if pfxCfg.MoveStop then
        mat:mulTranslationRight(pfxCfg.MoveStop,pfxCfg.MoveTime);
    end;
    return self:PlayerPfxByMat(dwName,pfxCfg.pfxName,mat);
end;

function CSceneMap:PlayerPfxByMat(szName, szPfxName, mat)
	if self.objScene 
        and self.objScene.pfxPlayer 
        and self.objScene.pfxPlayer.terrain == nil then
	    self.objScene.pfxPlayer.terrain = self.objScene.terrain
	    Debug("pfx reset terrain.")
	end
    if not self.objScene then return end
    
    --local tempMat = _Matrix3D.new()
    local pfx = self.objScene.pfxPlayer:play(szName, szPfxName)
    if mat then
        pfx.transform:set(mat)
    end
    pfx.bind = false
    pfx.keepInPlayer = false  --stop后
    return pfx, szPfxName
end

function CSceneMap:StopPfxByName(szName)
    if not self.objScene then
        return
    end
   self.objScene.pfxPlayer:stop(szName, true)
end

function CSceneMap:StopPfx(dwID)
    if not self.objScene then
        return
    end
    local szID = tostring(dwID)
    self.objScene.pfxPlayer:stop(szID)
end

function CSceneMap:PlayPfxByPos(szName, szPfxName, pos)
    pos.z = CPlayerMap.objSceneMap:getSceneHeight(pos.x, pos.y)
    local pfxMat =_Matrix3D.new()
    pfxMat:setTranslation(_Vector3.new(pos.x, pos.y, pos.z + 3))
    self:PlayerPfxByMat(szName, szPfxName, pfxMat)
end

function CSceneMap:PlayPfxByMarker(szName, szPfxName, markerName)
	if not self.objScene then
        return
    end
	
	local markers = self:GetMarkers();
	local marker = markers[markerName]; 
	if not marker then
		return;
	end
	
	self:StopPfxByName(szName);
	
	local pfxMat =_Matrix3D.new():setRotation(marker.rot.x, marker.rot.y, marker.rot.z, marker.rot.r);
	pfxMat:mulTranslationRight(marker.pos.x, marker.pos.y, marker.pos.z);
    self:PlayerPfxByMat(szName, szPfxName, pfxMat);
	
end

function CSceneMap:ResetShadow()
    local lights = self.objScene.graData:getLights()
    local skylight = nil
    for i, v in pairs(lights) do
        if v.name == 'skylight' then
            skylight = v
            break
        end
    end
    _rd.shadowMode = _RenderDevice.ShadowMap1
    _rd.shadowLight = skylight.direction
    _rd.shadowMapSize = 1024 * 4
end

local rotationRot = _Vector4.new()
function CSceneMap:GetMarkers()
	local posList = {}
	if self.objScene then
		local markerList = self.objScene.graData:getMarkers()
		for i, v in pairs(markerList) do
			local pos = v:getTranslation()
			v:getRotation(rotationRot)
			local dir = 0
			if rotationRot then
				dir = rotationRot.r
				if rotationRot.z < 0 then
				    dir = 2 * math.pi - dir
				end
			end
			local scale = v:getScaling()
			posList[v.name] = {}
			posList[v.name].name = v.name
			posList[v.name].pos = pos
			posList[v.name].dir = dir
			posList[v.name].scale = scale
			posList[v.name].rot = v:getRotation();
		end
	end
	return posList
end

function CSceneMap:GetJiguan(block)
	if not self.jiguan then
		return 0;
	end
	return self.jiguan[block];
end

function CSceneMap:ExecFmt(callback)
	if not self.useFmt.state then
		if self.useFmt.callback then
			self.useFmt.callback();
		end
		return;
	end
	
	if callback then
		self.useFmt.callback = callback;
	end
	
	local time = GetCurTime();
	local dv = time - self.useFmt.time;
	if dv<self.useFmt.interval then
		return;
	end
	self.useFmt.time = time;
	
	local nodes = self.useFmt.nodes;
	if not nodes then
		self.useFmt.pos = 0; 
		nodes = {};
		self.useFmt.nodes = nodes;
		local sns = self.objScene:getNodes();
		for i,node in pairs(sns) do
			if node.mesh then
				table.push(nodes,node);
			end
		end
	end
	
	local sindex = self.useFmt.pos*self.useFmt.step;
	sindex = math.max(sindex,1);
	if sindex>#nodes then
		if self.useFmt.callback then
			self.useFmt.callback();
		end
		return;
	end
	
	sindex = math.min(#nodes,sindex);
	local eindex = (self.useFmt.pos + 1)*self.useFmt.step;
	eindex = math.min(#nodes,eindex);
	for i=sindex,eindex do
		local node = nodes[i];
		if not node.fmt then
			local mn = FileFormatTransform(node.name,'fmt');
			if mn then
				if _sys:fileExist(mn,false) then
					node.mesh:loadLMaterialManager(mn);
				end
			end
			node.fmt = true;
		end
	end
	
	self.useFmt.pos = self.useFmt.pos + 1;
	
end

function CSceneMap:EngineUpdate(e)
	if not self.objScene then
		return;
	end
	
	if self.sceneLoading then
		self:ExecFmt();
	end
	
end

function CSceneMap:RemoveParticle(name)
	if not self.objScene or not self.objScene.pfxPlayer then
		return;
	end
	
	self.objScene.pfxPlayer:stop(name,true);
	self.objScene.pfxPlayer:delParam(name);
	
end

