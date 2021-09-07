AnimalChessBoard = AnimalChessBoard or BaseClass()

function AnimalChessBoard:__init(model, controllor, parent, followArea, assetWrapper)
    self.model = model
    self.controllor = controllor
    self.followArea = followArea
    self.gameObject = parent.gameObject
    self.transform = self.gameObject.transform
    self.assetWrapper = assetWrapper
    self.rawImage = self.gameObject:AddComponent(RawImage)

    self.selectEffect = nil
    self.effectTab = {}

    self.name = "board"

    self.pieceTab = {{}, {}, {}, {}, {}, {}}
    self.redListener = function(x, y, i) self.pieceTab[x][y]:SetRed(i) end
    self.greenListener = function(x, y, i) self.pieceTab[x][y]:SetGreen(i) end
    self.normalListener = function(x, y) self.pieceTab[x][y]:Select(false) end

    AnimalChessManager.Instance.onGreenEvent:AddListener(self.greenListener)
    AnimalChessManager.Instance.onRedEvent:AddListener(self.redListener)
    AnimalChessManager.Instance.onNormalEvent:AddListener(self.normalListener)

    self:BuildCamera()
end

function AnimalChessBoard:__delete()
    AnimalChessManager.Instance.onGreenEvent:RemoveListener(self.greenListener)
    AnimalChessManager.Instance.onRedEvent:RemoveListener(self.redListener)
    AnimalChessManager.Instance.onNormalEvent:RemoveListener(self.normalListener)

    if self.pieceTab ~= nil then
        for _,list in pairs(self.pieceTab) do
            for _,v in pairs(list) do
                v:DeleteMe()
            end
        end
        self.pieceTab = nil
    end
    if self.effectTab ~= nil then
        for _,effect in pairs(self.effectTab) do
            if effect ~= nil then
                effect:DeleteMe()
            end
        end
    end
    if self.selectEffect ~= nil then
        self.selectEffect:DeleteMe()
        self.selectEffect = nil
    end
    if self.openEffect1 ~= nil then
        self.openEffect1:DeleteMe()
        self.openEffect1 = nil
    end
    if self.openEffect2 ~= nil then
        self.openEffect2:DeleteMe()
        self.openEffect2 = nil
    end
    if self.rawImage ~= nil then
        self.rawImage:GetComponent(RawImage).material = nil
        self.rawImage.texture = nil
        GameObject.DestroyImmediate(self.rawImage.gameObject)
        self.rawImage = nil
    end
    if self.cameraObj ~= nil then
        self.cameraObj:GetComponent(Camera).targetTexture = nil
        GameObject.DestroyImmediate(self.cameraObj)
        self.cameraObj = nil
    end
    self.controllor = nil
end

function AnimalChessBoard:BuildCamera()
    self.cameraObj = GameObject("PreviewCamera_" .. self.name)
    local camera = self.cameraObj:AddComponent(Camera)
    camera.orthographicSize = 2.5
    camera.orthographic = true
    camera.backgroundColor = Color(0,0,0,0)
    camera.clearFlags = CameraClearFlags.Color;
    camera.depth = 1;
    camera.nearClipPlane = -20;
    camera.farClipPlane = 10;
    camera.farClipPlane = 1
    camera.cullingMask = 512
    self.cameraObj.transform:SetParent(PreviewManager.Instance.container.transform)
    self.cameraObj.transform.position = Vector3(0, 0, 0.5)

    self.render = RenderTexture.GetTemporary(self.transform.rect.width * 1.5, self.transform.rect.height * 1.5, 16)
    self.rawImage.texture = self.render
    camera.targetTexture = self.render
    if not self.noMaterial then
        self.rawImage.material = Material(Shader.Find ("Particles/Alpha Blended Premultiply"))
    end

    -- 不需要拖动
    local dragBehaviour = self.rawImage.gameObject:AddComponent(UIDragBehaviour)
    local onBeginDrag = function(data)
        self.lastPostion = data.position
    end
    dragBehaviour.onBeginDrag= {"+=", onBeginDrag}
    local cbOnDrag = function(data)
    end
    dragBehaviour.onDrag = {"+=", cbOnDrag}
end

function AnimalChessBoard:Update(type, coordinate1, coordinate2)
    if type == nil then
        -- 更新
        self:ReloadChessboard()
    elseif type == AnimalChessEumn.OperateType.Open then
        -- 开箱子
        self.controllor:OpenBox(self.pieceTab[coordinate1[1]][coordinate1[2]])
    elseif type == AnimalChessEumn.OperateType.Move then
        -- 移动
        self.controllor:Move(self.pieceTab[coordinate1[1]][coordinate1[2]], self.pieceTab[coordinate2[1]][coordinate2[2]])
    elseif type == AnimalChessEumn.OperateType.Attack then
        -- 攻击
        self.controllor:Attack(self.pieceTab[coordinate1[1]][coordinate1[2]], self.pieceTab[coordinate2[1]][coordinate2[2]])
    end
end

function AnimalChessBoard:ReloadChessboard()
    local model = self.model
    for x,col in ipairs(model.chessInfoTab) do
        for y,slot in ipairs(col) do
            if self.pieceTab[x][y] == nil then
                local tab = {}
                tab.transform = self.followArea:GetChild(36 - (x - 1) * 6 - y)
                tab.nameText1 = tab.transform:Find("FollowInfo/Name1"):GetComponent(Text)
                tab.nameText2 = tab.transform:Find("FollowInfo/Name2"):GetComponent(Text)
                self.pieceTab[x][y] = AnimalChessPiece.New(self, model.positionTab[x][y], function(tpose) self:OnNpcLoaded(tpose) end, tab, self.assetWrapper)
                self.pieceTab[x][y].x = x
                self.pieceTab[x][y].y = y
            end
            self.pieceTab[x][y]:SetData(slot)
        end
    end
end

function AnimalChessBoard:OnNpcLoaded(newTpose)
    self.tpose = newTpose
    Utils.ChangeLayersRecursively(self.tpose.transform, "ModelPreview")
    self.tpose.name = "PreviewTpose_" .. self.name
    self.tpose.transform:SetParent(PreviewManager.Instance.container.transform)
    -- self.tpose.transform.position = Vector3(self.nextX + self.offsetX, self.offsetY, 0)
    -- self.tpose.transform.localScale = Vector3(100, 100, 100)
end

function AnimalChessBoard:Select(x, y, bool)
    self.pieceTab[x][y]:Select(bool)
    if bool ~= true then
        local keyList = {}
        for k,v in pairs(self.effectTab) do
            if v ~= nil then
                table.insert(keyList, k)
            end
        end
        for _,key in ipairs(keyList) do
            self.effectTab[key]:DeleteMe()
            self.effectTab[key] = nil
        end
    end
end

function AnimalChessBoard:SetGreen(x, y, bool)
    if bool == true then
        self.pieceTab[x][y]:SetGreen()
    else
        self.pieceTab[x][y]:Select(false)
    end
end

function AnimalChessBoard:SetRed(x, y, bool)
    if bool == true then
        self.pieceTab[x][y]:SetRed()
    else
        self.pieceTab[x][y]:Select(false)
    end
end
