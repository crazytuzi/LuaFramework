-- 作者:jia
-- 7/5/2017 3:50:22 PM
-- 功能:爵位挑战新记录窗口

GloryNewRecordWindow = GloryNewRecordWindow or BaseClass(BaseWindow)
function GloryNewRecordWindow:__init(parent)
    self.parent = parent
    self.resList = {
        { file = AssetConfig.glorynewrecord, type = AssetType.Main }
        ,{ file = AssetConfig.glorynewrecord_bg_title, type = AssetType.Main }
        ,{ file = AssetConfig.glorynewrecord_bg_effect, type = AssetType.Main }
        ,{ file = AssetConfig.treasuremazetexture, type = AssetType.Dep }
    }
    self.friendsHeadSlots = { }
    self.FriendsData = { }
    self.TwnArrow = nil
    self.maleShowTimes = { 2.5, 2.4, 2.533, 3.533, 3.167, 2.567, 3.267 }
    -- 2.5 第一位空位，狂剑，魔导，战弓，兽灵，密言
    self.femaleShowTimes = { 3.367, 3.167, 2.533, 3.533, 3.167, 2.567, 3.267 }
    -- 3.367
    self.OnOpenEvent:Add( function() self:OnOpen() end)
    -- self.OnHideEvent:Add(function() self:OnHide() end)
    self.hasInit = false
end

function GloryNewRecordWindow:__delete()
    if self.MyHeadSlot ~= nil then
        self.MyHeadSlot:DeleteMe()
        self.MyHeadSlot = nil
    end
    if self.TwnArrow ~= nil then
        Tween.Instance:Cancel(self.TwnArrow);
        self.TwnArrow = nil
    end
    if self.timerBg ~= nil then
        LuaTimer.Delete(self.timerBg);
        self.timerBg = nil
    end
    if self.friendsHeadSlots ~= nil then
        for _, item in pairs(self.friendsHeadSlots) do
            item:DeleteMe();
            item = nil
        end
        self.friendsHeadSlots = nil
    end
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
    if self.slotsLayout ~= nil then
        self.slotsLayout:DeleteMe()
        self.slotsLayout = nil
    end
    if self.previewTimer ~= nil then
        LuaTimer.Delete(self.previewTimer);
        self.previewTimer = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function GloryNewRecordWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GloryNewRecordWindow:OnHide()

end

function GloryNewRecordWindow:OnOpen()
    self.data = self.openArgs;
    self:UpdateData();
    if self.TwnArrow ~= nil then
        Tween.Instance:Cancel(self.TwnArrow);
    end
    self.TwnArrow = Tween.Instance:MoveLocalY(self.ImgArrow.gameObject, 10, 0.6, nil, LeanTweenType.linear):setLoopPingPong().id
    self.theta = 0;
    if self.timerBg ~= nil then
        LuaTimer.Delete(self.timerBg);
    end
    self.timerBg = LuaTimer.Add(0, 20,
    function()
        self.theta = self.theta + 2;
        self.BgCon.localRotation = Quaternion.Euler(0, 0, self.theta);
    end )
end

function GloryNewRecordWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.glorynewrecord))
    self.gameObject.name = "GloryNewRecordWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.Panel = self.transform:Find("Panel"):GetComponent(Button)
    self.Panel.onClick:AddListener( function()
        self:OnClose();
    end );

    self.Light = self.transform:Find("Light")

    self.Title = self.transform:Find("Main/Title")
    local bgtitle = GameObject.Instantiate(self:GetPrefab(AssetConfig.glorynewrecord_bg_title))
    bgtitle.gameObject.transform.localPosition = Vector3.zero
    bgtitle.gameObject.transform.localScale = Vector3.zero
    UIUtils.AddBigbg(self.Title, bgtitle)

    self.EffectBg = self.transform:Find("Main/EffectBg")
    self.BgCon = self.transform:Find("Main/EffectBg/BgCon")

    local bgeffect = GameObject.Instantiate(self:GetPrefab(AssetConfig.glorynewrecord_bg_effect))
    bgeffect.gameObject.transform.localPosition = Vector3.zero
    bgeffect.gameObject.transform.localScale = Vector3.one
    UIUtils.AddBigbg(self.BgCon, bgeffect)

    self.MyInfo = self.transform:Find("Main/MyInfo")

    self.Head = self.transform:Find("Main/MyInfo/Head")
    self.MyHeadSlot = HeadSlot.New();
    self.MyHeadSlot:SetRectParent(self.Head.gameObject)

    self.TxtName = self.transform:Find("Main/MyInfo/Name"):GetComponent(Text)
    self.TxtScore = self.transform:Find("Main/MyInfo/Score"):GetComponent(Text)

    self.Friends = self.transform:Find("Main/Friends")

    self.Container = self.transform:Find("Main/Friends/Scroll/Container")
    self.TxtFriend = self.transform:Find("Main/Friends/Text"):GetComponent(Text)
    self.ImgArrow = self.transform:Find("Main/MyInfo/Arrow")

    self.slotsLayout = LuaBoxLayout.New(self.Container, { axis = BoxLayoutAxis.X, cspacing = 0, border = 10 })

    self.BtnTell = self.transform:Find("Main/Tell"):GetComponent(Button)
    self.BtnTell.onClick:AddListener(
    function()
        self:SendMsg();
    end );

    self.BtnGoOn = self.transform:Find("Main/GoOn"):GetComponent(Button)
    self.BtnGoOn.onClick:AddListener( function()
        self:OnClose();
    end );
end

function GloryNewRecordWindow:UpdateData()
    self.FriendsData = { };
    local roleData = RoleManager.Instance.RoleData;
    self.MyHeadSlot:SetAll(roleData, { isSmall = true })
    self.TxtName.text = roleData.name
    self.TxtScore.text = string.format(TI18N("爵位闯关：%s"), self.data.id);
    local isBeyond = self.data.is_beyond == 1;
    self.BtnTell.gameObject:SetActive(isBeyond);
    local str;
    if isBeyond then
        str = string.format(TI18N("本次挑战超越了<color='#2fc823'>%s位</color>好友"), #self.data.list);
    else
        local fdata = self.data.list[1];
        if fdata == nil then
            local myData = BaseUtils.copytab(roleData);
            myData.rid = myData.id
            myData.new_id = self.data.id
            myData.max_id = self.data.max_id
            table.insert(self.data.list, myData)
            str = string.format(TI18N("称霸好友，独孤求败"));
        else
            local fuid = fdata.new_id - self.data.id;
            if fuid <= 0 then
                fuid = 1
            end
            str = string.format(TI18N("还差<color='#2fc823'>%s</color>层可超越<color='#2fc823'>%s</color>"), fuid, fdata.name);
        end
    end
    self.TxtFriend.text = str;
    for index = 1, #self.data.list do
        local friend = self.data.list[index];
        local friendslot = self.friendsHeadSlots[index];
        if friendslot == nil then
            friendslot = HeadSlot.New()
            self.slotsLayout:AddCell(friendslot.transform.gameObject);
            self.friendsHeadSlots[index] = friendslot;
        end
        local data = { };
        data.sex = friend.sex
        data.classes = friend.classes
        data.name = friend.name
        data.id = friend.rid
        data.platform = friend.platform
        data.zone_id = friend.zone_id
        data.lev = friend.lev
        data.new_id = friend.new_id
        data.max_id = friend.max_id
        data.new_title_id = friend.new_title_id
        friendslot:SetAll(data, {
            isSmall = true,
            clickCallback =
            function()
                TipsManager.Instance:ShowPlayer( { id = data.id, zone_id = data.zone_id, platform = data.platform, sex = data.sex, classes = data.classes, name = data.name, lev = data.lev })
            end
        } )
        table.insert(self.FriendsData, data);
    end
    self.MyInfo.anchoredPosition = Vector2(123, 48)
    self:UpdatePreview();
end

function GloryNewRecordWindow:UpdatePreview()
    local callback = function(composite)
        self:SetRawImage(composite)
    end
    local setting = {
        name = "GloryNewRecordWindow"
        ,
        orthographicSize = 0.7
        ,
        width = 400
        ,
        height = 400
        ,
        offsetY = - 0.4
    }
    local llooks = { }
    local mySceneData = SceneManager.Instance:MyData()
    if mySceneData ~= nil then
        llooks = mySceneData.looks
    end
    local modelData = { type = PreViewType.Role, classes = RoleManager.Instance.RoleData.classes, sex = RoleManager.Instance.RoleData.sex, looks = llooks }
    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback, setting, modelData)
    else
        self.previewComp:Reload(modelData, callback)
    end
    self.previewComp:Show()
end

function GloryNewRecordWindow:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.EffectBg)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    self.EffectBg.gameObject:SetActive(true)

    local state_id = BaseUtils.GetShowActionId(RoleManager.Instance.RoleData.classes, RoleManager.Instance.RoleData.sex)
    composite:PlayAnimation(tostring(state_id))

    local showTime = 0
    local sex = RoleManager.Instance.RoleData.sex;
    local classes = RoleManager.Instance.RoleData.classes
    if sex == 0 then
        showTime = self.femaleShowTimes[classes]
    else
        showTime = self.maleShowTimes[classes]
    end
    if self.previewTimer ~= nil then
        LuaTimer.Delete(self.previewTimer);
    end
    self.previewTimer = LuaTimer.Add(showTime * 1000, function() self:ActionDelay(composite) end)
end

function GloryNewRecordWindow:ActionDelay(composite)
    composite:PlayAnimation("Stand" .. composite.animationData.stand_id)
end

function GloryNewRecordWindow:OnClose()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.glory_window)
end

function GloryNewRecordWindow:SendMsg()
    local msg = string.format(TI18N("<color='#ffff00'>我</color>在爵位闯关中成功挑战<color='#ffff00'>%s</color>层，将你踩在脚底，有本事快来追我啊"), self.data.id);
    for _, friend in pairs(self.FriendsData) do
        FriendManager.Instance:SendMsg(friend.id, friend.platform, friend.zone_id, msg);
    end
    self:OnClose()
end