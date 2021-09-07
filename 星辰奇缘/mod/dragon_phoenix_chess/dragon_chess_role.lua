-- @author hze
-- @date 2018/06/07
--龙凤棋角色
DragonChessRole = DragonChessRole or BaseClass()

function DragonChessRole:__init(gameObject, assetWrapper, obj, dir)
    self.gameObject = gameObject
    self.assetWrapper = assetWrapper
    self.transform = gameObject.transform

    self.dir = dir

    --适配，暂时这样处理
    self.objtransform = obj.transform

    self.chessTopIcon = {{"phoenixicon", "red"}, {"dragonicon", "blue"}}

    self.initMark = true

    self:InitPanel()
end

function DragonChessRole:InitPanel()
    self.dialog = self.transform:Find("DialogBg")
    self.msgTxt = MsgItemExt.New(self.dialog:Find("Msg"):GetComponent(Text), 187)
    self.previewModel = self.transform:Find("RoleModel")     
    -- self.previewModel:GetComponent(Image).material = PreloadManager.Instance:GetMainAsset("textures/materials/uimask.unity3d")
    self.nameTxt = self.transform:Find("RoleNameBg/Name"):GetComponent(Text)
    self.gradeTxt = self.transform:Find("GradeBg/Grade"):GetComponent(Text)


    self.iconBg = self.objtransform:Find("Bg"):GetComponent(Image)
    self.icon = self.objtransform:Find("Icon"):GetComponent(Image)
    self.selectedObj = self.objtransform:Find("Selected").gameObject
    self.scoreTxt = self.objtransform:Find("Score"):GetComponent(Text)
end

function DragonChessRole:__delete()

    BaseUtils.ReleaseImage(self.iconBg)
    BaseUtils.ReleaseImage(self.icon)

    if self.rolePreview ~= nil then
        self.rolePreview:DeleteMe()
        self.rolePreview = nil
    end

    if self.msgTxt ~= nil then
        self.msgTxt:DeleteMe()
        self.msgTxt = nil
    end

    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end

    self.assetWrapper = nil
    self.transform = nil
    self.gameObject = nil
end

function DragonChessRole:SetData(data)
    self.icon.sprite = self.assetWrapper:GetSprite(AssetConfig.dragon_chess_textures,self.chessTopIcon[data.camp][1])
    self.iconBg.sprite = self.assetWrapper:GetSprite(AssetConfig.dragon_chess_textures,self.chessTopIcon[data.camp][2])

    self.scoreTxt.text = data.chess_count

    self.nameTxt.text = data.name
    self.gradeTxt.text = DataCampBlackWhiteChess.data_grade[data.grade].name

    if self.initMark then 
        self.initMark = false
        self:SetPreview(data)
    end
end


function DragonChessRole:SetStatus(status)
    self.selectedObj:SetActive(status)
end

function DragonChessRole:SetPreview(data)
    if (data or {}).looks == nil then
        return
    end

    local dirRot = 0
    if self.dir == 1 then
        dirRot = 25
    else
        dirRot = -25
    end

    local modelData = {type = PreViewType.Role, classes = data.classes, sex = data.sex, looks = data.looks, scale = 1.9}
    local callback = function(composite) end
    if self.rolePreview == nil then
        local setting = {
            name = string.format("RolePreview_%s",data.name)
            ,layer = "UI"
            ,parent = self.previewModel
            ,localRot = Vector3(0, dirRot, 0)
            ,localPos = Vector3(0, -105, -150)
            ,usemask = false
            ,sortingOrder = 10
            -- ,nodrag = false
        }
        self.rolePreview = PreviewmodelComposite.New(callback, setting, modelData)
    else
        self.rolePreview:Reload(modelData, callback)
    end
    self.rolePreview:Show()
    self.rolePreview:PlayAction(FighterAction.Stand)
end

function DragonChessRole:SetRotation(chessType)
    if chessType == 1 then
        self.iconBg.transform.localRotation = Vector3(0,0,0)
    else
        self.iconBg.transform.localRotation = Vector3(0,0,1)
    end
end

function DragonChessRole:SetMsg(msg,overmark)
    self.dialog.gameObject:SetActive(true)
    self.msgTxt:SetData(msg)

    if not overmark then 
        if self.timerId ~= nil then LuaTimer.Delete(self.timerId) self.timerId = nil end
        self.timerId = LuaTimer.Add(3000, 0, function(id)  LuaTimer.Delete(id)   self.dialog.gameObject:SetActive(false) end)
    end
end

function DragonChessRole:DoAnimation()
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
    end
    self.scoreTxt.transform.localScale = Vector3(2, 2, 2)
    self.tweenId = Tween.Instance:Scale(self.scoreTxt.gameObject, Vector3(1,1,1), 2, function()  end, LeanTweenType.easeOutElastic).id
end

