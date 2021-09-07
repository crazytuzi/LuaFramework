-- 师徒师门面板
-- @author zgs
TeacherPanel = TeacherPanel or BaseClass(BasePanel)

function TeacherPanel:__init(model,parent)
    self.model = model
    self.parent = parent
    self.name = "TeacherPanel"

    self.itemsDic = {}
    self.totalCnt = 0

    self.resList = {
        {file = AssetConfig.teacher_panel, type = AssetType.Main},
        {file = AssetConfig.teacher_textures, type = AssetType.Dep},
        {file = AssetConfig.heads, type = AssetType.Dep},
        {file = AssetConfig.zone_textures, type = AssetType.Dep},
    }
    self.OnOpenEvent:AddListener(function()
        --self.showType = self.openArgs[1]
        -- self:UpdateWindow()
        TeacherManager.Instance:send15807()
    end)
    self.stInfoChangeFun = function ()
        if self.item ~= nil then
            self:UpdateWindow()
        end
    end
    EventMgr.Instance:AddListener(event_name.teahcer_student_info_change, self.stInfoChangeFun)

    self.updateDailyRed = function ()
        if self.item ~= nil then
            self:UpdateDailyRedPoint()
        end
    end

    TeacherManager.Instance.onUpdateDailyRed:AddListener(self.updateDailyRed)
end

function TeacherPanel:OnInitCompleted()
    --self.showType = self.openArgs[1]
    -- self:UpdateWindow()
    TeacherManager.Instance:send15807()
end

function TeacherPanel:__delete()
    if not BaseUtils.isnull(self.head) and not BaseUtils.isnull(self.head.sprite) then
        self.head.sprite = nil
    end
    self.OnOpenEvent:RemoveAll()
    EventMgr.Instance:RemoveListener(event_name.teahcer_student_info_change, self.stInfoChangeFun)
    GameObject.DestroyImmediate(self.gameObject)
    TeacherManager.Instance.onUpdateDailyRed:RemoveListener(self.updateDailyRed)
    self:AssetClearAll()
    self.gameObject = nil
    self.model = nil
end

function TeacherPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.teacher_panel))
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = self.gameObject.transform

    self.leftInfo = self.transform:Find("LeftInfo")
    self.leftInfo:Find("List/Svalue/Text"):GetComponent(Text).text = TI18N("师道值:")
    self.head = self.leftInfo:Find("Headbg/Head"):GetComponent(Image)
    self.head.gameObject:SetActive(false)
    self.classIcon = self.leftInfo:Find("ClassIcon"):GetComponent(Image)
    self.nameText = self.leftInfo:Find("NameText"):GetComponent(Text)
    self.inputField = self.leftInfo:Find("SigInputField"):GetComponent(InputField)
    self.inputField.characterLimit = 32
    self.inputField.lineType = InputField.LineType.MultiLineSubmit
    self.inputField.onEndEdit:AddListener(function()
        self:OnEndEditSig()
    end)
    self.levText = self.leftInfo:Find("LevText"):GetComponent(Text)
    self.svalueText = self.leftInfo:Find("SvalueText"):GetComponent(Text) --师道值
    self.bsstateText = self.leftInfo:Find("BSStateText"):GetComponent(Text) --已出师人数
    self.countText = self.leftInfo:Find("CountText"):GetComponent(Text) --授业中人数
    self.tipBtn = self.leftInfo:Find("TipsImage"):GetComponent(Button)
    self.tipBtn.onClick:AddListener(function()
        self.descRole = {
            TI18N("1、徒弟<color='#ffff00'>出师、达成师徒目标</color>等都能获得师道值"),
            TI18N("2、徒弟每升一定等级会对师傅<color='#ffff00'>做出评价</color>，评价越高获得的师道值越高"),
            TI18N("3、师道值达到<color='#ffff00'>800点</color>可获得<color='#ffff00'>为人师表</color>称号，达到<color='#ffff00'>3000点</color>可获得<color='#ffff00'>桃李满天下</color>称号，达到<color='#ffff00'>9000点</color>可获得<color='#ffff00'>一代宗师</color>称号"),
            TI18N("4、徒弟出师后双方师道值超过<color='#ffff00'>200点</color>，师徒双方都可获得丰厚奖励，师傅还有几率可以获得稀有珍兽哦！")
        }
        TipsManager.Instance:ShowText({gameObject = self.tipBtn.gameObject, itemData = self.descRole})
    end)

    self.rightCon = self.transform:Find("RightList")
    self.grid = self.rightCon:Find("ScrollPanel/Grid")
    self.item = self.grid:Find("Item").gameObject
    self.item:SetActive(false)
    self.listLayout = LuaBoxLayout.New(self.grid.gameObject, {axis = BoxLayoutAxis.Y, cspacing = 3,border = 4})
    self.noneStuObj = self.rightCon:Find("NoneImage").gameObject
    self.noneStuObj:SetActive(false)
    self.goBtn = self.noneStuObj.transform:Find("Button"):GetComponent(Button)
    self.goBtn.onClick:AddListener(function()
        SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
        SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
        local key = BaseUtils.get_unique_npcid(2, 1)
        SceneManager.Instance.sceneElementsModel:Self_MoveToTarget(key)
        TeacherManager.Instance.model:CloseMain()
    end)

    local WorldLevData = DataTeacher.data_get_condition[RoleManager.Instance.world_lev]
    --print("sssssssssssssssssss")
    if WorldLevData ~= nil then
        self.NoticeTxt = self.rightCon:Find("NoticeBg/Notice/Text"):GetComponent(Text)
        self.NoticeTxt.text = string.format(TI18N("<color='#ffff00'>%s级</color>以下玩家可拜师，<color='#ffff00'>%s级</color>以上玩家可出师"),WorldLevData.boundary_lev,WorldLevData.graduate_lev)
    end


    -- self.button = self.transform:Find("Button"):GetComponent(Button)
    -- self.button.onClick:AddListener(function ()
    --     self:onClickBtn()
    -- end)
end

function TeacherPanel:OnEndEditSig()
    TeacherManager.Instance:send15813(self.inputField.text)
end

function TeacherPanel:UpdateWindow()
    for i,v in ipairs(self.itemsDic) do
        if v.thisObj ~= nil then
            v.thisObj:SetActive(false)
        end
    end
    local myStuData = nil
    local roleData = RoleManager.Instance.RoleData
    for i,v in ipairs(self.model.teacherStudentList.list) do
        if BaseUtils.Key(roleData.id, roleData.platform, roleData.zone_id) == BaseUtils.Key(v.rid, v.platform, v.zone_id) then
            myStuData = v
            break
        end
    end

    for i,v in ipairs(self.model.teacherStudentList.list) do
        if BaseUtils.Key(roleData.id, roleData.platform, roleData.zone_id) == BaseUtils.Key(v.rid, v.platform, v.zone_id) then   -- 自己
            v.sort = 1
        elseif v.status == 1 then       -- 授业中
            v.sort = 0
        else                            -- 已出师
            v.sort = 2
        end
    end

    table.sort(self.model.teacherStudentList.list, function(a, b) return a.sort < b.sort end)

    self.totalCnt = #self.model.teacherStudentList.list
    for i=1,self.totalCnt do -- 更改数据来源
        local itemTaken = self.itemsDic[i]
        if itemTaken == nil then
            local obj = GameObject.Instantiate(self.item)
            obj.name = tostring(i)
            obj.transform:Find("GragButton/Image").gameObject:SetActive(false)

            self.listLayout:AddCell(obj)
            local itemDic = {
                index = i,
                thisObj = obj,
                dataItem = nil,
                btn=obj.transform:Find("Button"):GetComponent(Button),
                greybtn=obj.transform:Find("GragButton"):GetComponent(Button),
                redpoint = obj.transform:Find("Button/Image").gameObject,
                nameText = obj.transform:Find("InfoText"):GetComponent(Text),
                levText = obj.transform:Find("LevText"):GetComponent(Text),
                stateText = obj.transform:Find("StateText"):GetComponent(Text),
                relationText = obj.transform:Find("RelationText"):GetComponent(Text),
                -- fightFlag = obj.transform:Find("FightFlag").gameObject,
                img = obj.transform:Find("HeadImageBg/Image"):GetComponent(Image),
                imgBtn = obj.transform:Find("HeadImageBg/Image"):GetComponent(Button),
                classIconImg = obj.transform:Find("ClassIcon"):GetComponent(Image),
            }
            self.itemsDic[i] = itemDic
            itemTaken = itemDic

            itemDic.btn.onClick:AddListener(function ()
                self:onClickBtn(i)
            end)
            itemDic.imgBtn.onClick:AddListener(function ()
                self:onClickImgBtn(i)
            end)
            itemDic.greybtn.onClick:AddListener(function ()
                self:onClickGreyBtn(i)
            end)
        end
        itemTaken.redpoint:SetActive(false)
        -- itemTaken.btn.gameObject:SetActive(true)
        itemTaken.dataItem = self.model.teacherStudentList.list[i]

        itemTaken.nameText.text = itemTaken.dataItem.name
        itemTaken.levText.text = string.format(TI18N("%d级"),itemTaken.dataItem.lev)
        itemTaken.img.sprite = self.assetWrapper:GetSprite(AssetConfig.heads, string.format("%s_%s", itemTaken.dataItem.classes, itemTaken.dataItem.sex))
        itemTaken.classIconImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(itemTaken.dataItem.classes))

        itemTaken.thisObj:SetActive(true)

        if BaseUtils.Key(roleData.id, roleData.platform, roleData.zone_id) == BaseUtils.Key(itemTaken.dataItem.rid, itemTaken.dataItem.platform, itemTaken.dataItem.zone_id) then
            itemTaken.btn.gameObject:SetActive(false)
            itemTaken.greybtn.gameObject:SetActive(true)
        else
            itemTaken.btn.gameObject:SetActive(true)
            itemTaken.greybtn.gameObject:SetActive(false)
        end

        local descStr = ""
        if myStuData == nil then
            descStr = TI18N("(徒弟)")
        else
            if BaseUtils.Key(myStuData.rid, myStuData.platform, myStuData.zone_id) == BaseUtils.Key(itemTaken.dataItem.rid, itemTaken.dataItem.platform, itemTaken.dataItem.zone_id) then
                descStr = TI18N("(本人)")
            else
                if myStuData.in_time < itemTaken.dataItem.in_time then
                    --入门早
                    if itemTaken.dataItem.sex == 1 then
                        descStr = TI18N("(师弟)")
                    else
                        descStr = TI18N("(师妹)")
                    end
                else
                    if itemTaken.dataItem.sex == 1 then
                        descStr = TI18N("(师兄)")
                    else
                        descStr = TI18N("(师姐)")
                    end
                end
            end
        end

        if itemTaken.dataItem.status == 2 then
            itemTaken.relationText.text = string.format(TI18N("<color='#248813'>已出师</color>\n%s"),descStr)
        else
            itemTaken.relationText.text = string.format(TI18N("<color='#c3692c'>授业中</color>\n%s"),descStr)
        end
        descStr = nil
    end

    self.classIcon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(self.model.teacherStudentList.t_classes))
    self.nameText.text = self.model.teacherStudentList.t_name
    -- Log.Error(self.model.teacherStudentList.t_lev)
    self.levText.text = string.format("%s",tostring(self.model.teacherStudentList.t_lev))
    self.svalueText.text = string.format("%d",self.model.teacherStudentList.teacher_score)
    local localBeTeacher =  0
    local localStu = 0
    for i,v in ipairs(self.model.teacherStudentList.list) do
        if v.status == 2 then
            localBeTeacher = localBeTeacher + 1
        elseif v.status == 1 then
            localStu = localStu + 1
        end
    end
    self.bsstateText.text = string.format("%d",localBeTeacher)
    self.countText.text = string.format("%d",localStu)

    if self.model.myTeacherInfo.status ~= 3 then
        self.inputField.enabled = false --不是师傅
    else
        self.inputField.enabled = true --是师傅
    end
    self.inputField.text = self.model.teacherStudentList.msg
    self:ShowTeacherHead()

    self.noneStuObj:SetActive(false)
    if self.totalCnt == 0 then
        self.noneStuObj:SetActive(true)
    end

    -- TeacherManager.Instance.onUpdateDailyRed:Fire()
end

function TeacherPanel:UpdateDailyRedPoint()
    local totalCnt = #self.model.teacherStudentList.list
    if totalCnt == self.totalCnt then
        for i=1,totalCnt do -- 更改数据来源
            local itemTaken = self.itemsDic[i]
            itemTaken.redpoint:SetActive(false)
            local key = BaseUtils.Key(itemTaken.dataItem.rid,itemTaken.dataItem.platform,itemTaken.dataItem.zone_id)
            local tab = TeacherManager.Instance.dailyInitRed[key]
            if self.model.myTeacherInfo.status == 3 then
                itemTaken.redpoint:SetActive(tab ~= nil and tab == true)
            else
                itemTaken.redpoint:SetActive(false)
            end
        end
    elseif totalCnt > self.totalCnt then
        self:UpdateWindow()
    end
end

function TeacherPanel:ShowTeacherHead()
    -- self.head.sprite = self.assetWrapper:GetSprite(AssetConfig.heads, string.format("%s_%s", self.model.teacherStudentList.t_classes, self.model.teacherStudentList.t_sex))

    LuaTimer.Add(50,
        function()
            if self.model == nil then
                return
            end
            local photo = ZoneManager.Instance.model:LoadLocalPhoto(self.model.teacherStudentList.t_id,self.model.teacherStudentList.t_platform
                , self.model.teacherStudentList.t_zone_id,self.model.teacherPhoto)
            if BaseUtils.is_null(photo) then
                ZoneManager.Instance:RequirePhotoQueue(self.model.teacherStudentList.t_id,self.model.teacherStudentList.t_platform
                , self.model.teacherStudentList.t_zone_id, function(photo) self:toPhoto(photo) end)
            else
                self:toPhoto(photo)
            end
        end
    )
end

function TeacherPanel:toPhoto(photo)
    if BaseUtils.isnull(self.head) then
        return
    end
    self.head.gameObject:SetActive(true)
    if #photo == 0 then
        self.head.sprite = self.assetWrapper:GetSprite(AssetConfig.heads, string.format("%s_%s", self.model.teacherStudentList.t_classes, self.model.teacherStudentList.t_sex))
    else
        self.model.teacherPhoto = photo[1].photo_bin
        -- print(photo.Length)
        local tex2d = Texture2D(64, 64, TextureFormat.RGB24, false)

        local result = tex2d:LoadImage(photo[1].photo_bin)
        if result then
            self.head.sprite  = Sprite.Create(tex2d, Rect(0, 0, tex2d.width, tex2d.height), Vector2(0.5, 0.5), 1)
        end
    end
end

function TeacherPanel:onClickBtn(index)
    local stuData = self.itemsDic[index].dataItem
    local roleData = RoleManager.Instance.RoleData

    if self.model.myTeacherInfo.status == 3 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.apprenticeship, {stuData, 1})
    elseif BaseUtils.Key(roleData.id, roleData.platform, roleData.zone_id) ~= BaseUtils.Key(stuData.rid, stuData.platform, stuData.zone_id) then
        --
        TipsManager.Instance:ShowPlayer({id = stuData.rid, zone_id = stuData.zone_id, platform = stuData.platform, sex = stuData.sex, classes = stuData.classes, name = stuData.name, guild = stuData.guild_name, lev = stuData.lev})
    end
end

function TeacherPanel:onClickImgBtn(index)
    local stuData = self.itemsDic[index].dataItem
    local roleData = RoleManager.Instance.RoleData

    if BaseUtils.Key(roleData.id, roleData.platform, roleData.zone_id) ~= BaseUtils.Key(stuData.rid, stuData.platform, stuData.zone_id) then
        --
        TipsManager.Instance:ShowPlayer({id = stuData.rid, zone_id = stuData.zone_id, platform = stuData.platform, sex = stuData.sex, classes = stuData.classes, name = stuData.name, guild = stuData.guild_name, lev = stuData.lev})
    end
end

function TeacherPanel:onClickGreyBtn(index)
    local stuData = self.itemsDic[index].dataItem
    local roleData = RoleManager.Instance.RoleData
    if BaseUtils.Key(roleData.id, roleData.platform, roleData.zone_id) == BaseUtils.Key(stuData.rid, stuData.platform, stuData.zone_id) then
        NoticeManager.Instance:FloatTipsByString(TI18N("无需对自己操作"))
    end
end


