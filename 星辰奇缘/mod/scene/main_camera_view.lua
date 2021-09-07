-- ----------------------------------------------------------
-- 游戏摄像头
-- ----------------------------------------------------------
MainCamera = MainCamera or BaseClass(BaseView)

local Vector3 = UnityEngine.Vector3
local Time = UnityEngine.Time
local Color = UnityEngine.Color

function MainCamera:__init()
    self.name = "MainCamera"
    -- 根节点
    self.gameObject = ctx.MainCamera.gameObject
    self.transform = self.gameObject.transform

    self.sceneModel = nil

    self.camera = self.gameObject:GetComponent(Camera)
    self.camera.orthographicSize = SceneManager.Instance.DefaultCameraSize

    -- self.renderTexture = RenderTexture.GetTemporary(594, 270)
    -- self.renderTexture.name = "Screenshot_RenderTexture"
    -- self.sceneTexture = self.transform:FindChild("SceneTexture").gameObject

    ------------ 对象 ------------
    self.folloewObject = nil -- 摄像头跟随的目标
    self.folloewTransform = nil
    self.onlyFolloewView = nil -- 是否只是镜头跟随，人物不跟随
    self.lock = false -- 摄像头锁定位置，不跟随目标移动

    ------------ 各种常量 ------------
    self.fly_offset = Vector2.zero
    self.fly_offset_targetvalue = Vector2.zero

    ------------ 各种常量 ------------
    -- self.mapsizeconvertvalue = 0.00526315
    self.mapsizeconvertvalue = SceneManager.Instance.Mapsizeconvertvalue

    self.CameraOffsetX = ctx.CameraOffsetX
    self.CameraOffsetY = ctx.CameraOffsetY + 0.12
    -- self.CameraOffsetY = ctx.CameraOffsetY
    -- self.ViewWidth = ctx.ScreenWidth * self.mapsizeconvertvalue / 2 * (tonumber(DataSystem.data_setting[9]) or 1.05)
    -- self.ViewHeight = ctx.ScreenHeight * self.mapsizeconvertvalue / 2 * (tonumber(DataSystem.data_setting[10]) or 1.05)
    -- self.OutViewWidth = ctx.ScreenWidth * self.mapsizeconvertvalue / 2 * (tonumber(DataSystem.data_setting[11]) or 1.05)
    -- self.OutViewHeight = ctx.ScreenHeight * self.mapsizeconvertvalue / 2 * (tonumber(DataSystem.data_setting[12]) or 1.05)
    self.ViewWidth = ctx.CameraOffsetX * (tonumber(DataSystem.data_setting[9]) or 1.05)
    self.ViewHeight = ctx.CameraOffsetY * (tonumber(DataSystem.data_setting[10]) or 1.05)
    self.OutViewWidth = ctx.CameraOffsetX * (tonumber(DataSystem.data_setting[11]) or 1.05)
    self.OutViewHeight = ctx.CameraOffsetY * (tonumber(DataSystem.data_setting[12]) or 1.05)

    self.cameraSpeed = 0.5 -- 摄像机移动速度

    self.MapCellSize = 256 * 4 / 3--384
    self.MapCellRow = 4
    self.MapCellCol = 5
    self.MapOffectX = 0
    self.MapOffectX2 = 0
    self.MapOffectY = 0
    self.MapOffectY2 = 0

    self.offsetX = (self.MapCellSize * self.MapCellCol / 2 - 1280 / 2) * self.mapsizeconvertvalue
    self.offsetY = (self.MapCellSize * self.MapCellRow / 2 - 720 / 2) * self.mapsizeconvertvalue

    if BaseUtils.IsWideScreen() then
        self.MapCellCol = 6
    end
    self.offsetX2 = 0
    self.offsetY2 = 0
    self.cellSize = self.MapCellSize * self.mapsizeconvertvalue
    self.cellSize2 = 256 * self.mapsizeconvertvalue

    self.x = 0
    self.y = 0
    self.MapX = 0
    self.MapY = 0
    self.MapTransformX = 0
    self.MapTransformY = 0
    self.MapWidth = 0
    self.MapHeight = 0

    self.sceneTexture_tweenId = nil
    --------------------------------------------------------

    self.modelMask = true
    self.effectMask = true
    -- self.sceneTexture.transform.localScale = Vector3(1280 * self.mapsizeconvertvalue, 720 * self.mapsizeconvertvalue, 1)
    -- self.sceneTexture.transform.localScale = Vector3(6.95, 3.9, 1)

    self.vec3 = Vector3.zero
    self.color1111 = Color(1,1,1,1)
end

function MainCamera:FixedUpdate()
    self:Move()
end

function MainCamera:Move()
    if self.sceneModel.map_loaded then
        local position = self.transform.position
        local pox
        local poy
        if self.lock then
            pox = position.x
            poy = position.y
        else
            if not BaseUtils.isnull(self.folloewObject) then
                local folloewPosition = self.folloewTransform.position
                if position.x ~= folloewPosition.x or position.y ~= folloewPosition.y then
                    -- 这里做了点小技巧，让默认摄像机的速度足够慢，抗抖动强一些，距离大了再加速
                    local tempPoint = Vector3(position.x, position.y + self.fly_offset.y, position.z)
                    local dis = Vector2.Distance(folloewPosition, tempPoint)
                    local offsetSpeed = 0
                    if dis > 0.5 then
                        offsetSpeed = dis + 1
                    elseif dis > 0.3 then
                        offsetSpeed = 1
                    elseif dis > 0.1 then
                        offsetSpeed = 0.5
                    end

                    local timeTemp = math.min(1, SceneManager.Instance.deltaTime * (self.cameraSpeed + offsetSpeed))
                    -- local timeTemp = SceneManager.Instance.deltaTime * 5
                    local p = Vector3.Lerp(position, folloewPosition, timeTemp)
                    pox = p.x
                    poy = p.y + self.fly_offset.y
                else
                    pox = folloewPosition.x
                    poy = folloewPosition.y + self.fly_offset.y
                end
            else
                pox = position.x
                poy = position.y
            end
        end

        if self.fly_offset_targetvalue ~= self.fly_offset then
            self.fly_offset = Vector2.Lerp(self.fly_offset, self.fly_offset_targetvalue, SceneManager.Instance.deltaTime * 5)
        end

        local MapWidth = self.MapWidth
        local MapHeight = self.MapHeight
        local CameraOffsetX = self.CameraOffsetX
        local CameraOffsetY = self.CameraOffsetY

        if pox < CameraOffsetX then
            pox = CameraOffsetX
        elseif pox > (MapWidth - CameraOffsetX) then
            pox = MapWidth - CameraOffsetX
        end

        if poy < CameraOffsetY then
            poy = CameraOffsetY
        elseif poy > (MapHeight - CameraOffsetY) then
            poy = MapHeight - CameraOffsetY
        end

        self.x = pox
        self.y = poy

        self.vec3:Set(pox, poy, -10)

        local tmpx = self.transform.position.x
        local tmpy = self.transform.position.y
        self.transform.position = self.vec3

        if not self.lock and not BaseUtils.isnull(self.folloewObject) and (math.abs(tmpx - pox) < 0.001) and (math.abs(tmpy - poy) < 0.001) then
            -- 判断当前站立不动，不处理地图移动
            -- hosr
            return
        end

        self:MoveMap()
    end
end

function MainCamera:MoveMap()
    local offsetX = self.offsetX
    local offsetY = self.offsetY
    local offsetX2 = self.offsetX2
    local offsetY2 = self.offsetY2
    local cellSize = self.cellSize
    local cellSize2 = self.cellSize
    local MapX = self.MapX
    local MapY = self.MapY
    local MapOffectX = self.MapOffectX
    local MapOffectY = self.MapOffectY
    local MapOffectX2 = self.MapOffectX2
    local MapOffectY2 = self.MapOffectY2
    local x = self.x
    local y = self.y

    local moveMark = false
    local dx = self.x - self.MapX
    local dy = self.y - self.MapY

    if dx < -offsetX - MapOffectX2 then
        while x - MapX < -offsetX - MapOffectX2 do MapX = MapX - cellSize end
        moveMark = true
    elseif dx > offsetX - MapOffectX2 then
        while x - MapX > offsetX - MapOffectX2 do MapX = MapX + cellSize end
        moveMark = true
    end

    if dy < -offsetY - MapOffectY2 then
        while y - MapY < -offsetY - MapOffectY2 do MapY = MapY - cellSize end
        moveMark = true
    elseif dy > offsetY - MapOffectY2 then
        while y - MapY > offsetY - MapOffectY2 do MapY = MapY + cellSize end
        moveMark = true
    end

    dx = x - MapX
    dy = y - MapY

    if self.MapCellCol % 2 ~= 0 then
        if dx < -offsetX2 - MapOffectX2 and MapOffectX ~= -cellSize2 / 2 then
            -- print(string.format("dx %s x %s", dx, x))
            MapOffectX = -cellSize2 / 2
            moveMark = true
        elseif dx > offsetX2 - MapOffectX2 and MapOffectX ~= cellSize2 / 2 then
            -- print(string.format("dx %s x %s", dx, x))
            MapOffectX = cellSize2 / 2
            moveMark = true
        end
    end

    if self.MapCellRow % 2 ~= 0 then
        if dy < -offsetY2 - MapOffectY2 and MapOffectY ~= -cellSize2 / 2 then
            MapOffectY = -cellSize2 / 2
            moveMark = true
        elseif dy > offsetY2 - MapOffectY2 and MapOffectY ~= cellSize2 / 2 then
            MapOffectY = cellSize2 / 2
            moveMark = true
        end
    end

    self.MapX = MapX
    self.MapY = MapY
    self.MapOffectX = MapOffectX
    self.MapOffectY = MapOffectY

    if moveMark then
        self.MapTransformX = MapX + MapOffectX - MapOffectX2
        self.MapTransformY = MapY + MapOffectY - MapOffectY2
        -- print(string.format("MapX %s MapY %s MapOffectX %s MapOffectY - MapOffectY2 %s", MapX, MapY, MapOffectX, MapOffectY - MapOffectY2))
        SceneManager.Instance.sceneModel.sceneView:MapMove(self.MapTransformX, self.MapTransformY, MapX, MapY)
    end
end

function MainCamera:SetPosition_InitMap(pox, poy)
    local MapWidth = self.MapWidth
    local MapHeight = self.MapHeight
    local CameraOffsetX = self.CameraOffsetX
    local CameraOffsetY = self.CameraOffsetY

    if pox < CameraOffsetX then
        pox = CameraOffsetX
    elseif pox > (MapWidth - CameraOffsetX) then
        pox = MapWidth - CameraOffsetX
    end

    if poy < CameraOffsetY then
        poy = CameraOffsetY
    elseif poy > (MapHeight - CameraOffsetY) then
        poy = MapHeight - CameraOffsetY
    end

    self.x = pox
    self.y = poy

    if self.fly_offset_targetvalue ~= Vector2.zero then
        self.y = self.y + self.fly_offset.y + 0.447243
    end
    self.vec3:Set(self.x, self.y, -10)
    -- self.transform.position = self.vec3

    local offsetX = self.offsetX
    local offsetY = self.offsetY
    local offsetX2 = self.offsetX2
    local offsetY2 = self.offsetY2
    local cellSize = self.cellSize
    local cellSize2 = self.cellSize
    local MapX = self.MapX
    local MapY = self.MapY
    local MapOffectX = self.MapOffectX
    local MapOffectY = self.MapOffectY
    local MapOffectX2 = self.MapOffectX2
    local MapOffectY2 = self.MapOffectY2
    local x = self.x
    local y = self.y

    local moveMark = false
    local dx = self.x - self.MapX
    local dy = self.y - self.MapY

    if dx < -offsetX - MapOffectX2 then
        while x - MapX < -offsetX - MapOffectX2 do MapX = MapX - cellSize end
        moveMark = true
    elseif dx > offsetX - MapOffectX2 then
        while x - MapX > offsetX - MapOffectX2 do MapX = MapX + cellSize end
        moveMark = true
    end

    if dy < -offsetY - MapOffectY2 then
        while y - MapY < -offsetY - MapOffectY2 do MapY = MapY - cellSize end
        moveMark = true
    elseif dy > offsetY - MapOffectY2 then
        while y - MapY > offsetY - MapOffectY2 do MapY = MapY + cellSize end
        moveMark = true
    end

    dx = x - MapX
    dy = y - MapY

    if self.MapCellCol % 2 ~= 0 then
        if dx < -offsetX2 - MapOffectX2  and MapOffectX ~= -cellSize2 / 2 then
            MapOffectX = -cellSize2 / 2
            moveMark = true
        elseif dx > offsetX2 - MapOffectX2 and MapOffectX ~= cellSize2 / 2 then
            MapOffectX = cellSize2 / 2
            moveMark = true
        end
    end

    if self.MapCellRow % 2 ~= 0 then
        if dy < -offsetY2 - MapOffectY2 and MapOffectY ~= -cellSize2 / 2 then
            -- print(string.format("dx %s x %s", dx, x))
            MapOffectY = -cellSize2 / 2
        elseif dy > offsetY2 - MapOffectY2 and MapOffectY ~= cellSize2 / 2 then
            -- print(string.format("dx %s x %s", dx, x))
            MapOffectY = cellSize2 / 2
        end
    end

    self.MapX = MapX
    self.MapY = MapY
    self.MapOffectX = MapOffectX
    self.MapOffectY = MapOffectY

    self.MapTransformX = MapX + MapOffectX - MapOffectX2
    self.MapTransformY = MapY + MapOffectY - MapOffectY2

    SceneManager.Instance.sceneModel.sceneView:InitMapTexture(MapX, MapY)
end

function MainCamera:SetMapData()
    local map = ctx.sceneManager.Map
    self.MapWidth = map.Width * self.mapsizeconvertvalue
    self.MapHeight = map.Height * self.mapsizeconvertvalue
    -- print(string.format("MainCamera:SetMapData %s %s %s %s %s", self.MapWidth, map.MapHeight, map.Width, map.Height, self.mapsizeconvertvalue))
    self.MapX = 0
    self.MapY = 0
    self.MapOffectX = 0
    self.MapOffectY = 0
    self.MapTransformX = 0
    self.MapTransformY = 0

    -- local cellSize = 256
    local cellSize = 256 * 4 / 3
    -- if map.Width % cellSize == 0 then
    --     self.MapOffectX2 = 0
    -- else
    --     self.MapOffectX2 = (cellSize - (map.Width - math.floor(map.Width / cellSize) * cellSize)) * self.mapsizeconvertvalue
    -- end

    if map.Height % cellSize < 0.02 then
        self.MapOffectY2 = 0
    else
        self.MapOffectY2 = (cellSize - (map.Height - math.floor(map.Height / cellSize) * cellSize)) * self.mapsizeconvertvalue
    end

    -- print(string.format("self.MapOffectX2 %s self.MapOffectY2 %s ", self.MapOffectX2, self.MapOffectY2))
    -- self.MapOffectX2 = 0
    -- self.MapOffectY2 = 0.4764
end

function MainCamera:SetFolloewObject(folloewObject, onlyFolloewView)
    self.folloewObject = folloewObject
    self.folloewTransform = folloewObject.transform
    self.onlyFolloewView = onlyFolloewView
end

function MainCamera:UnloadAssets()
    GoPoolManager.Instance:Release(Time.time)
    if BaseUtils.platform == RuntimePlatform.IPhonePlayer then
        AssetPoolManager.Instance:DoUnloadUnusedAssets()
    end
end

function MainCamera:Screenshot_AndAlpha()
    -- self:ShowDefaultLayer()

    -- self.camera.targetTexture = self.renderTexture
    -- self.camera:Render()
    -- Log.Debug("Screenshot_AndAlpha")
    self.sceneTexture:SetActive(true)
    -- self.sceneTexture.renderer.sharedMaterial.mainTexture = self.renderTexture
    self.camera.targetTexture = nil

    if self.sceneTexture_tweenId ~= nil then
        Tween.Instance:Cancel(self.sceneTexture_tweenId)
        self.sceneTexture_tweenId = nil
    end

    self.sceneTexture.renderer.sharedMaterial.color = self.color1111
    self.sceneTexture_tweenId = Tween.Instance:Alpha(self.sceneTexture, 0, 0.2, function() self:AlphaEnd() end, LeanTweenType.linear).id
    -- Log.Debug("Tween")

    -- ctx:DoUnloadUnusedAssets() -- 清理资源
    GoPoolManager.Instance:Release(Time.time)
    AssetPoolManager.Instance:DoUnloadUnusedAssets()
end
function MainCamera:Screenshot()
    self:ShowDefaultLayer()

    -- self.camera.targetTexture = self.renderTexture
    -- self.camera:Render()
    -- Log.Debug("Screenshot_AndAlpha")
    self.sceneTexture:SetActive(true)
    -- self.sceneTexture.renderer.sharedMaterial.mainTexture = self.renderTexture
    self.camera.targetTexture = nil

    if self.sceneTexture_tweenId ~= nil then
        Tween.Instance:Cancel(self.sceneTexture_tweenId)
        self.sceneTexture_tweenId = nil
    end

    self.sceneTexture.renderer.sharedMaterial.color = self.color1111
end

function MainCamera:ScreenshotAlpha()
    self.sceneTexture_tweenId = Tween.Instance:Alpha(self.sceneTexture, 0, 0.8, function() self:AlphaEnd() end, LeanTweenType.linear).id
    -- Log.Debug("Tween")

    -- ctx:DoUnloadUnusedAssets() -- 清理资源
    GoPoolManager.Instance:Release(Time.time)
    AssetPoolManager.Instance:DoUnloadUnusedAssets()
end

function MainCamera:AlphaEnd()
    self.sceneTexture:SetActive(false)
    -- self:UpdateCullingMask()
    if self.sceneTexture_tweenId ~= nil then
        Tween.Instance:Cancel(self.sceneTexture_tweenId)
        self.sceneTexture_tweenId = nil
    end

    -- SceneManager.Instance.sceneModel.sceneView:ShowTransportEffect()
end

function MainCamera:set_modelmask(val)
    self.modelMask = val
    self:UpdateCullingMask()
end

function MainCamera:set_effectmask(val)
    self.effectMask = val
    self:UpdateCullingMask()
end

function MainCamera:UpdateCullingMask()
    local m = self.modelMask
    local e = self.effectMask
    if m and e then
        self.camera.cullingMask =
            (2 ^ LayerMask.NameToLayer("Default"))
            + (2 ^ LayerMask.NameToLayer("Model"))
            + (2 ^ LayerMask.NameToLayer("SceneEffect"))
    elseif m and not e then
        self.camera.cullingMask =
            (2 ^ LayerMask.NameToLayer("Default"))
            + (2 ^ LayerMask.NameToLayer("Model"))
    elseif not m and e then
        self.camera.cullingMask =
            (2 ^ LayerMask.NameToLayer("Default"))
            + (2 ^ LayerMask.NameToLayer("SceneEffect"))
    elseif not m and not e then
        self.camera.cullingMask = (2 ^ LayerMask.NameToLayer("Default"))
    end
end

function MainCamera:ShowDefaultLayer()
    self.camera.cullingMask = (2 ^ LayerMask.NameToLayer("Default"))
end

function MainCamera:CameraMove(data)
    if data.type == 3 then
        if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
            SceneManager.Instance.MainCamera:SetFolloewObject(SceneManager.Instance.sceneElementsModel.self_view.gameObject)
        end
    else
        SceneManager.Instance.MainCamera.folloewObject = nil
        local startpos = SceneManager.Instance.MainCamera.transform.position
        local endpos = SceneManager.Instance.sceneModel:transport_small_pos(data.x, data.y)
        -- endpos:Set(endpos.x, endpos.y, 0)
        endpos = self:FixPosition(endpos.x, endpos.y, 0)
        self.tweenDesc = Tween.Instance:Move(SceneManager.Instance.MainCamera.gameObject, endpos, data.time/1000, function() self:CameraMoveOver(data) end)
    end
end

function MainCamera:CameraMoveOver(data)
    if data.type == 2 then
        local uniqueid = BaseUtils.get_unique_roleid(data.id, data.id2, data.platform)
        local folloewview = SceneManager.Instance.sceneElementsModel.RoleView_List[uniqueid]
        if folloewview ~= nil then
            SceneManager.Instance.MainCamera:SetFolloewObject(folloewview.gameObject)
        end
    end
end
--******************************--
--******************************--
------------ 镜头工具 ------------
--******************************--
--******************************--

--是否在镜头视野内
function MainCamera:InView(x, y, scale)
    if scale == nil then
        if math.abs(self.x - x) < self.ViewWidth
            and math.abs(self.y - y) < self.ViewHeight then
            return true
        else
            return false
        end
    else
        if math.abs(self.x - x) < self.ViewWidth * scale
            and math.abs(self.y - y) < self.ViewHeight * scale then
            return true
        else
            return false
        end
    end
end

--是否在镜头视野内(传入大坐标)
function MainCamera:InView_big(x, y, scale)
    local p = SceneManager.Instance.sceneModel:transport_small_pos(x, y)
    return self:InView(p.x, p.y, scale)
end

--是否在镜头视野外
function MainCamera:OutView(x, y, scale)
    if scale == nil then
        if math.abs(self.x - x) > self.OutViewWidth
            or math.abs(self.y - y) > self.OutViewHeight then
            return true
        else
            return false
        end
    else
        if math.abs(self.x - x) > self.OutViewWidth * scale
            or math.abs(self.y - y) > self.OutViewHeight * scale then
            return true
        else
            return false
        end
    end
end

--是否在镜头视野外(传入大坐标)
function MainCamera:OutView_big(x, y, scale)
    local p = SceneManager.Instance.sceneModel:transport_small_pos(x, y)
    return self:OutView(p.x, p.y, scale)
end

-- 修正镜头位置(传入xyz，返回Vector3)
function MainCamera:FixPosition(pox, poy, poz)
    local MapWidth = self.MapWidth
    local MapHeight = self.MapHeight
    local CameraOffsetX = self.CameraOffsetX
    local CameraOffsetY = self.CameraOffsetY

    if pox < CameraOffsetX then
        pox = CameraOffsetX
    elseif pox > (MapWidth - CameraOffsetX) then
        pox = MapWidth - CameraOffsetX
    end

    if poy < CameraOffsetY then
        poy = CameraOffsetY
    elseif poy > (MapHeight - CameraOffsetY) then
        poy = MapHeight - CameraOffsetY
    end

    return Vector3(pox, poy, -10)
end

function MainCamera:SetFly(fly)
    if fly then
        self.fly_offset_targetvalue = Vector2(0, 0.03)
    else
        self.fly_offset_targetvalue = Vector2.zero
    end
end

function MainCamera:SetOffsetTargetvalue(offset)
    self.fly_offset_targetvalue = Vector2(0, offset)
end