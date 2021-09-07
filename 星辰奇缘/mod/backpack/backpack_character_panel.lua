BackpackCharacterPanel = BackpackCharacterPanel or BaseClass(BasePanel)

function BackpackCharacterPanel:__init(model)
    self.parent = nil
    self.resList = {
        {file = AssetConfig.backpack_character, type = AssetType.Main}
        ,{file = AssetConfig.smallicon, type = AssetType.Dep}
    }

    self.model = model
    self.parent = nil

    self.transform = nil
    self.chenhao_obj = nil --称号
    self.chenhao_txt = nil
    self.huoli_obj = nil -- 师徒
    self.huoli_txt = nil
    self.couple_obj = nil -- 伴侣
    self.couple_txt = nil
    self.brother_obj = nil --结拜
    self.brother_txt = nil
    self.juewei_obj = nil --魅力
    self.juewei_txt = nil
    self.teacher_obj = nil --师徒
    self.teacher_txt1 = nil
    self.teacher_txt2 = nil
    self.teacher_txtbg2 = nil
    self.worldchampion_obj = nil -- 武道会
    self.worldchampion_txt = nil
    self.qualify_obj = nil -- 段位
    self.qualify_txt = nil
    self.is_open = false

    --监听回调
    self.on_honor_update = function()
        self:on_update_honor()
    end

    self.on_couple_update = function()
        self:update_couple()
    end
end

function BackpackCharacterPanel:__delete()
    EventMgr.Instance:RemoveListener(event_name.honor_update, self.on_honor_update)

    self.is_open = false
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil

    self.transform = nil
    self.chenhao_obj = nil --称号
    self.chenhao_txt = nil
    self.huoli_obj = nil -- 师徒
    self.huoli_txt = nil
    self.couple_obj = nil -- 伴侣
    self.couple_txt = nil
    self.brother_obj = nil --结拜
    self.brother_txt = nil
    self.juewei_obj = nil --魅力
    self.juewei_txt = nil
    self.teacher_obj = nil --师徒
    self.teacher_txt1 = nil
    self.teacher_txt2 = nil
    self.teacher_txtbg2 = nil
    self.worldchampion_obj = nil -- 武道会
    self.worldchampion_txt = nil
    self.qualify_obj = nil -- 段位
    self.qualify_txt = nil
    self:AssetClearAll()
end

function BackpackCharacterPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.backpack_character))
    self.gameObject.name = "BackpackCharacterPanel"

    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3(-45, -4.5, 0)

    self.chenhao_obj = self.transform:Find("LayoutCon/Item1/BtnItem"):GetComponent(Button)
    self.chenhao_obj.name = tostring(1)
    self.chenhao_txt = self.transform:Find("LayoutCon/Item1/TxtNum"):GetComponent(Text)
    self.chenhao_obj.onClick:AddListener(function() self:on_click_btn(1, self.chenhao_obj) end)


    self.huoli_obj = self.transform:Find("LayoutCon/Item3/BtnItem"):GetComponent(Button)
    self.huoli_obj.name = tostring(2)
    self.huoli_txt = self.transform:Find("LayoutCon/Item3/TxtNum"):GetComponent(Text)
    self.huoli_obj.onClick:AddListener(function() self:on_click_btn(3, self.huoli_obj) end)

    self.couple_obj = self.transform:Find("LayoutCon/Item4/BtnItem"):GetComponent(Button)
    self.couple_obj.name = tostring(3)
    self.couple_txt = self.transform:Find("LayoutCon/Item4/TxtNum"):GetComponent(Text)
    self.couple_obj.onClick:AddListener(function() self:on_click_btn(4, self.couple_obj) end)

    self.brother_obj = self.transform:Find("LayoutCon/Item5/BtnItem"):GetComponent(Button)
    self.brother_obj.name = tostring(4)
    self.brother_txt = self.transform:Find("LayoutCon/Item5/TxtNum"):GetComponent(Text)
    self.brother_obj.onClick:AddListener(function() self:on_click_btn(5, self.brother_obj) end)

    self.teacher_obj = self.transform:Find("LayoutCon/Item6/BtnItem"):GetComponent(Button)
    self.brother_obj.name = tostring(5)
    self.teacher_txt1 = self.transform:Find("LayoutCon/Item6/TxtNum1"):GetComponent(Text)
    self.teacher_txt2 = self.transform:Find("LayoutCon/Item6/TxtNum2"):GetComponent(Text)
    self.teacher_txtbg2 = self.transform:Find("LayoutCon/Item6/ImgTxt2").gameObject
    self.teacher_obj.onClick:AddListener(function() self:on_click_btn(6, self.teacher_obj) end)

    self.worldchampion_obj = self.transform:Find("LayoutCon/Item7/BtnItem"):GetComponent(Button)
    self.worldchampion_obj.name = tostring(7)
    self.worldchampion_txt = self.transform:Find("LayoutCon/Item7/TxtNum1"):GetComponent(Text)
    self.worldchampion_obj.onClick:AddListener(function() self:on_click_btn(7, self.worldchampion_obj) end)

    self.qualify_obj = self.transform:Find("LayoutCon/Item8/BtnItem"):GetComponent(Button)
    self.qualify_obj.name = tostring(8)
    self.qualify_txt = self.transform:Find("LayoutCon/Item8/TxtNum1"):GetComponent(Text)
    self.qualify_obj.onClick:AddListener(function() self:on_click_btn(8, self.qualify_obj) end)

    if self.model.info_current_index ~= 0 then
        self:set_all_btn_false()

        local Normal = nil
        local Select = nil
        if self.model.info_current_index == 1 then
            Normal = self.chenhao_obj.transform:Find("Normal").gameObject
            Select = self.chenhao_obj.transform:Find("Select").gameObject
        elseif self.model.info_current_index == 2 then
            Normal = self.huoli_obj.transform:Find("Normal").gameObject
            Select = self.huoli_obj.transform:Find("Select").gameObject
        elseif self.model.info_current_index == 3 then
            Normal = self.couple_obj.transform:Find("Normal").gameObject
            Select = self.couple_obj.transform:Find("Select").gameObject
        elseif self.model.info_current_index == 4 then
            Normal = self.brother_obj.transform:Find("Normal").gameObject
            Select = self.brother_obj.transform:Find("Select").gameObject
        -- else
        --     Normal = self.juewei_obj.transform:Find("Normal").gameObject
        --     Select = self.juewei_obj.transform:Find("Select").gameObject
        end
        Normal:SetActive(false)
        Select:SetActive(true)
    end

    self.is_open = false

    self:update_info()

    EventMgr.Instance:AddListener(event_name.honor_update, self.on_honor_update)
    EventMgr.Instance:AddListener(event_name.lover_data, self.on_couple_update)
    -- GloryManager.Instance:send14400({}, function() self.juewei_txt.text = DataGlory.data_title[GloryManager.Instance.model.title_id].title_name end)
end

--点击切换按钮
function BackpackCharacterPanel:on_click_btn(index, btn)
    if index == 5 then
        NoticeManager.Instance:FloatTipsByString(TI18N("暂未开放敬请期待"))
        return
    end
    if index == 4 and self.couple_txt.text == TI18N("无") then
        NoticeManager.Instance:FloatTipsByString(TI18N("你还没有结缘，快去跟心仪的异性好友结缘申请吧"))
        -- NoticeManager.Instance:FloatTipsByString(TI18N("尚未开放"))
        return
    end
    if index == 3 and RoleManager.Instance.RoleData.lev < 21 then
        NoticeManager.Instance:FloatTipsByString(TI18N("等级达到21级开启"))
        return
    end

    if index == 6 then
        self:on_click_teacher()
        return
    end
    if index == 7 then
        WorldChampionManager.Instance.model:OpenMainWindow()
        return
    end
    if index == 8 then
        QualifyManager.Instance.model:OpenQualifyMainUI()
        return
    end
    self:set_all_btn_false()

    local Normal = btn.transform:Find("Normal").gameObject
    local Select = btn.transform:Find("Select").gameObject
    Normal:SetActive(false)
    Select:SetActive(true)

    self.model.info_panel:change_view(index)
end

function BackpackCharacterPanel:on_click_teacher()
    local Teachermodel = TeacherManager.Instance.model
    if Teachermodel.myTeacherInfo.status == TeacherEnum.Type.Teacher then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.teacher_window, {})
    elseif Teachermodel.myTeacherInfo.status == TeacherEnum.Type.Student then
        local stuData = {rid = RoleManager.Instance.RoleData.id,platform = RoleManager.Instance.RoleData.platform,zone_id = RoleManager.Instance.RoleData.zone_id}
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.apprenticeship, {stuData, 1})
    elseif Teachermodel.myTeacherInfo.status == TeacherEnum.Type.BeTeacher then
        local stuData = {rid = RoleManager.Instance.RoleData.id,platform = RoleManager.Instance.RoleData.platform,zone_id = RoleManager.Instance.RoleData.zone_id}
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.apprenticeship, {stuData, 1})
    elseif Teachermodel.myTeacherInfo.status == TeacherEnum.Type.None then
        SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
        SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
        SceneManager.Instance.sceneElementsModel:Self_PathToTarget("2_1")
    end
end

function BackpackCharacterPanel:set_all_btn_false()
    local Normal = self.chenhao_obj.transform:Find("Normal").gameObject
    local Select = self.chenhao_obj.transform:Find("Select").gameObject
    Normal:SetActive(true)
    Select:SetActive(false)
    Normal = self.huoli_obj.transform:Find("Normal").gameObject
    Select = self.huoli_obj.transform:Find("Select").gameObject
    Normal:SetActive(true)
    Select:SetActive(false)
    Normal = self.couple_obj.transform:Find("Normal").gameObject
    Select = self.couple_obj.transform:Find("Select").gameObject
    Normal:SetActive(true)
    Select:SetActive(false)
    Normal = self.brother_obj.transform:Find("Normal").gameObject
    Select = self.brother_obj.transform:Find("Select").gameObject
    Normal:SetActive(true)
    Select:SetActive(false)
    -- Normal = self.juewei_obj.transform:Find("Normal").gameObject
    -- Select = self.juewei_obj.transform:Find("Select").gameObject
    -- Normal:SetActive(true)
    -- Select:SetActive(false)


end

--更新称号
function BackpackCharacterPanel:on_update_honor()
    if is_open == false then
        return
    end
    local honor_data = HonorManager.Instance.model:get_current_honor()
    local honor_name = TI18N("无")
    if honor_data ~= nil then
        if honor_data.type == 3 then
            if GuildManager.Instance.model.my_guild_data ~= nil and GuildManager.Instance.model.my_guild_data.Name ~= nil then
                honor_name = string.format("%s%s%s", GuildManager.Instance.model.my_guild_data.Name, TI18N("的"), honor_data.name)
            end
        elseif honor_data.type == 7 then
            if TeacherManager.Instance.model.myTeacherInfo.name ~= "" then
                honor_name = string.format("%s%s", TeacherManager.Instance.model.myTeacherInfo.name, honor_data.name)
            elseif TeacherManager.Instance.model.myTeacherInfo.status == 3 then     -- 师傅
                honor_name = honor_data.name
            elseif TeacherManager.Instance.model.myTeacherInfo.status ~= 0 then -- 徒弟或者已出师
                honor_name = string.format("%s%s", TeacherManager.Instance.model.myTeacherInfo.name, honor_data.name)
            end
        elseif honor_data.type == 10 then    -- 结拜
            if SwornManager.Instance.model.swornData ~= nil and SwornManager.Instance.model.swornData.status == SwornManager.Instance.statusEumn.Sworn then
                honor_name = string.format(TI18N("%s之%s%s"), SwornManager.Instance.model.swornData.name, SwornManager.Instance.model.rankList[SwornManager.Instance.model.myPos], SwornManager.Instance.model.swornData.members[SwornManager.Instance.model.myPos].name_defined)
            end
        else
            honor_name = honor_data.name
        end
    end
    self.chenhao_txt.text = honor_name
end

--更新活力值
function BackpackCharacterPanel:update_huoli()
    if is_open == false then
        return
    end
    if RoleManager.Instance.RoleData.lev < 16 then --16级才开启
        return
    end
    -- local max_energy = data_agenda.data_energy_max[RoleManager.Instance.RoleData.lev].max_energy
    local str = tostring(RoleManager.Instance.RoleData.energy) --string.format("%s/%s", mod_role.role_other_assets.energy, max_energy)
    self.huoli_txt.text = str
end

--更新伴侣
function BackpackCharacterPanel:update_couple()
    if is_open == false or self.couple_txt == nil then
        return
    end
    if RoleManager.Instance.RoleData.wedding_status == 0 then --16级才开启
        self.couple_txt.text = TI18N("无")
        return
    end
    -- local max_energy = data_agenda.data_energy_max[RoleManager.Instance.RoleData.lev].max_energy
    local str = tostring(RoleManager.Instance.RoleData.lover_name) --string.format("%s/%s", mod_role.role_other_assets.energy, max_energy)
    self.couple_txt.text = str
end

--更新武道会
function BackpackCharacterPanel:update_worldchampion()
    if is_open == false or self.worldchampion_txt == nil then
        return
    end
    if RoleManager.Instance.RoleData.lev < 70 then
        self.worldchampion_txt.text = TI18N("70开启")
        return
    elseif WorldChampionManager.Instance.rankData == nil or next(WorldChampionManager.Instance.rankData) == nil then --70级才开启
        self.worldchampion_txt.text = TI18N("无")
        return
    end
    -- local max_energy = data_agenda.data_energy_max[RoleManager.Instance.RoleData.lev].max_energy
    local str = DataTournament.data_list[WorldChampionManager.Instance.rankData.rank_lev].name
    self.worldchampion_txt.text = str
end

--更新段位
function BackpackCharacterPanel:update_qualify()
    if is_open == false or self.qualify_txt == nil then
        return
    end
    if RoleManager.Instance.RoleData.lev < 40 then
        self.qualify_txt.text = TI18N("40开启")
        return
    elseif QualifyManager.Instance.model.mine_qualify_data == nil then --16级才开启
        self.qualify_txt.text = TI18N("无")
        return
    end

    local str = DataQualifying.data_qualify_data_list[QualifyManager.Instance.model.mine_qualify_data.rank_lev].lev_name
    self.qualify_txt.text = str
end

function BackpackCharacterPanel:update_teacher()
    if is_open == false or self.teacher_txt1 == nil then
        return
    end
    self.teacher_txt1.text = TI18N("无")
    self.teacher_txtbg2:SetActive(false)
    self.teacher_txt2.gameObject:SetActive(false)
    local Teachermodel = TeacherManager.Instance.model
    if Teachermodel.myTeacherInfo.status == TeacherEnum.Type.Teacher then
        if Teachermodel.teacherStudentList == nil or Teachermodel.teacherStudentList.list == nil then
            self.teacher_txt1.text = TI18N("无")
        else
            for i,v in ipairs(Teachermodel.teacherStudentList.list) do
                if i == 1 then
                    self.teacher_txt1.text = v.name
                else
                    self.teacher_txtbg2:SetActive(true)
                    self.teacher_txt2.gameObject:SetActive(true)
                    self.teacher_txt2.text = v.name
                end
            end
        end
    elseif Teachermodel.myTeacherInfo.status == TeacherEnum.Type.Student then
        self.teacher_txt1.text = Teachermodel.myTeacherInfo.name
    elseif Teachermodel.myTeacherInfo.status == TeacherEnum.Type.BeTeacher then
        self.teacher_txt1.text = Teachermodel.myTeacherInfo.name
    elseif Teachermodel.myTeacherInfo.status == TeacherEnum.Type.None then
        self.teacher_txt1.text = TI18N("无")
    end
end

function BackpackCharacterPanel:update_info()
    MarryManager.Instance:Send15014()
    self:on_update_honor()
    self:update_huoli()
    self:update_couple()
    self:update_teacher()
    -- self.couple_txt.text = "无"
    self.brother_txt.text = TI18N("无")
    self:update_worldchampion()
    self:update_qualify()
end


--背包界面销毁时，销毁子界面脚本数据
function BackpackCharacterPanel:destory()
    is_open = false
    self.transform = nil
    self.transform = nil
    self.chenhao_obj = nil --称号
    self.chenhao_txt = nil
    self.huoli_obj = nil -- 师徒
    self.huoli_txt = nil
    self.couple_obj = nil -- 伴侣
    self.couple_txt = nil
    self.brother_obj = nil --结拜
    self.brother_txt = nil

    EventMgr.Instance:RemoveListener(event_name.honor_update, self.on_honor_update)
    EventMgr.Instance:RemoveListener(event_name.lover_data, self.on_couple_update)
end
