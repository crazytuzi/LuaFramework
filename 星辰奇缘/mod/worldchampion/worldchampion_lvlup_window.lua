-- @author xhs
-- @date 2018年3月5日,星期一

-- 武道会晋级面板


WorldChampionLvlupWindow = WorldChampionLvlupWindow or BaseClass(BaseWindow)

function WorldChampionLvlupWindow:__init(model)
    self.model = model
    self.Mgr = self.model.mgr
    self.name = "WorldChampionLvlupWindow"

    self.resList = {
        {file = AssetConfig.worldchampionlvlup, type = AssetType.Main},
        {file = AssetConfig.no1inworld_textures, type = AssetType.Dep},
        {file = AssetConfig.no1inworldlvlupi18n, type = AssetType.Main},
        {file = AssetConfig.no1inworldlvlupopeni18n, type = AssetType.Main},
    }

    self.isend = false

end

function WorldChampionLvlupWindow:__delete()
    self.OnHideEvent:Fire()
    if self.headLoader ~= nil then
        self.headLoader:DeleteMe()
        self.headLoader = nil
    end
    if self.effect ~= nil then
        self.effect:DeleteMe()
        self.effect = nil
    end
    if self.effect2 ~= nil then
        self.effect2:DeleteMe()
        self.effect2 = nil
    end
    if self.effect3 ~= nil then
        self.effect3:DeleteMe()
        self.effect3 = nil
    end
    if self.effect4 ~= nil then
        for _,v in pairs(self.effect4) do
            v:DeleteMe()
        end
        self.effect4 = nil
    end
    if self.effect5 ~= nil then
        self.effect5:DeleteMe()
        self.effect5 = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function WorldChampionLvlupWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.worldchampionlvlup))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = t

    self.data = self.openArgs

    -- 是否晋级成功
    if self.data.a_rank_lev > self.data.b_rank_lev then
        self.lvlUp = true
    end
    -- -- 是否开启晋级赛
    -- if self.data.a_rank_point%100 == 0 and self.data.a_rank_point ~= 0 and self.data.a_rank_lev < 10 and not self.isLvlUp then
    --     self.openLvlUp = true
    -- end

    self.bgPanel = self.transform:Find("bgPanel"):GetComponent(Button)
    self.bgPanel.onClick:AddListener(function()
        if self.isend then
            self.model:CloseLvlUpWindow()
            if self.lvlUp then
                self.model:OpenLvupWindow(self.data)
            else
                self.model:OpenCountInfoWindow(self.data)
            end
        end
    end)
    local btn = self.transform:Find("Main/endText").gameObject:AddComponent(Button)
    btn.onClick:AddListener(function ()
        if self.isend then
            self.model:CloseLvlUpWindow()
            if self.lvlUp then
                self.model:OpenLvupWindow(self.data)
            else
                self.model:OpenCountInfoWindow(self.data)
            end
        end
    end)

    self.TitleImage = self.transform:Find("Main/TitleImage")
    self.CenterCircle = self.transform:Find("Main/CenterCircle")
    self.c21 = self.CenterCircle:GetChild(0)
    self.c22 = self.CenterCircle:GetChild(1)
    self.c23 = self.CenterCircle:GetChild(3)
    self.center = self.CenterCircle:Find("center")
    self.c3 = self.CenterCircle:Find("c3")
    self.bgc = self.CenterCircle:Find("bgc")
    self.cf = self.CenterCircle:Find("cf")
    self.headbg = self.CenterCircle:Find("headbg")

    self.Circle = self.CenterCircle:Find("Circle"):GetComponent(Image)
    self.Circle2 = self.CenterCircle:Find("Circle2"):GetComponent(Image)
    self.Head = self.transform:Find("Main/Head")
    self.bgImage = self.transform:Find("Main/bgImage")
    self.LevText = self.transform:Find("Main/LevText")
    self.desc = self.transform:Find("Main/desc"):GetComponent(Text)
    self.lvlUpPro = self.transform:Find("Main/LvlupPro")

    self.CenterCircle.gameObject:SetActive(false)
    self.Head.gameObject:SetActive(false)
    self.bgImage.gameObject:SetActive(false)
    self.LevText.gameObject:SetActive(false)
    self.desc.gameObject:SetActive(false)

    if self.lvlUp then
        self.TitleImage:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.no1inworldlvlupi18n,"No1InWorldLvlupI18N")
        self.Circle.fillAmount = 0
        self.Circle2.fillAmount = 0
    else
        self.TitleImage:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.no1inworldlvlupopeni18n,"No1InWorldLvlupOpenI18N")
        self.Circle.fillAmount = 1
        self.Circle2.fillAmount = 1
    end
    self.TitleImage:GetComponent(Image):SetNativeSize()
    local LvData = DataTournament.data_list[self.data.b_rank_lev]
    self.LevText:GetComponent(Text).text = string.format(TI18N("<color='#ede995'>%s</color>"),LvData.boxname)
    if self.headLoader == nil then
        self.headLoader = SingleIconLoader.New(self.Head:GetComponent(Image).gameObject)
    end
    self.headLoader:SetSprite(SingleIconType.Pet, LvData.icon)

    self:StarAnimate()
end

function WorldChampionLvlupWindow:StarAnimate()
    local endpos = self.TitleImage.localPosition
    self.TitleImage.localPosition = Vector3(0, 336, 0)

    -- 显示描述，可以关闭
    self.tween5 = function()
        if self.lvlUp then
            self.desc.text = string.format(TI18N("成功晋级，累计<color='#ffff00'>头衔积分+%s</color>"),self.data.b_store_point+self.data.honor_point+DataTournament.data_get_promotion_combat[self.data.b_rank_lev].point_win)
        else
            self.desc.text = string.format(TI18N("累计<color='#ffff00'>%s胜</color>即可晋级<color='#ffff00'>%s</color>"),DataTournament.data_get_promotion_combat[self.data.b_rank_lev].need_win,DataTournament.data_get_promotion_combat[self.data.b_rank_lev+1].name)
        end
        local pos = self.desc.transform.localPosition
        self.desc.transform.localPosition = Vector3(300,pos.y,pos.z)
        local endcallback = function()
            LuaTimer.Add(300,function ()
                self.isend = true
                self.transform:Find("Main/endText").gameObject:SetActive(true)
            end)
        end
        LuaTimer.Add(300,function()
            self.desc.gameObject:SetActive(true)
            Tween.Instance:MoveLocalX(self.desc.gameObject,pos.x, 0.5, endcallback, LeanTweenType.easeOutBack)
        end)
    end

    -- 晋级成功表现
    self.tween6 = function()
        self.effect5 = BaseUtils.ShowEffect(20147, self.Head, Vector3(1,1,1), Vector3(0,0,-1000))
        -- LuaTimer.Add(500,function ()
            local LvData = DataTournament.data_list[self.data.a_rank_lev]
            self.LevText:GetComponent(Text).text = string.format(TI18N("<color='#ede995'>%s</color>"),LvData.boxname)
            if self.headLoader == nil then
                self.headLoader = SingleIconLoader.New(self.Head:GetComponent(Image).gameObject)
            end
            self.headLoader:SetSprite(SingleIconType.Pet, LvData.icon)


            -- self.LevText.localScale = Vector3.zero
            -- self.bgImage.localScale = Vector3.zero
            -- self.Head.localScale = Vector3.zero
            -- Tween.Instance:Scale(self.LevText, Vector3(1, 1, 1), 0.3, function()end, LeanTweenType.easeOutBack)
            -- Tween.Instance:Scale(self.bgImage, Vector3(1, 1, 1), 0.3, function()end, LeanTweenType.easeOutBack)
            -- Tween.Instance:Scale(self.Head, Vector3(1, 1, 1), 0.3, function()end, LeanTweenType.easeOutBack)

            local changeVal = function(val)
                self.Circle.fillAmount = val
                self.Circle2.fillAmount = val
            end
            local point = self.data.b_store_point+self.data.honor_point+DataTournament.data_get_promotion_combat[self.data.b_rank_lev].point_win
            local endval = point%100/100
            SoundManager.Instance:Play(241)
            Tween.Instance:ValueChange(0, endval, 1.2*endval,self.tween5, LeanTweenType.linear, changeVal)
        -- end)
    end

    -- 晋级赛进度条弹出
    self.tween4 = function()
        local needwin = DataTournament.data_get_promotion_combat[self.data.b_rank_lev].need_win
        local t
        if needwin > 3 then
            t = self.lvlUpPro:Find("fourgame")
        else
            t = self.lvlUpPro:Find("threegame")
            if needwin == 2 then
                t:Find(tostring(3)):GetComponent(Image).color = Color(1, 1, 1, 0.2)
            end
        end
        t.gameObject:SetActive(true)
        self.lvlUpPro.localScale = Vector3.zero
        self.lvlUpPro.gameObject:SetActive(true)
        self.effect3 = BaseUtils.ShowEffect(20461, self.lvlUpPro, Vector3(1,1,1), Vector3(0,12,-1000))
        self.effect4 = {}
        local fun1 = function ()
            for i=1,needwin do
                LuaTimer.Add(300*i,function()
                    self.effect4[i] = BaseUtils.ShowEffect(20462, t:Find(tostring(i)), Vector3(1,1,1), Vector3(0,0,-1000))
                end)
            end
            LuaTimer.Add(300*needwin,self.tween5)
        end
        local fun2 = function ()
            LuaTimer.Add(500,fun1)
        end
        Tween.Instance:Scale(self.lvlUpPro, Vector3(1, 1, 1), 0.3,fun2, LeanTweenType.easeOutBack)
    end

    -- 显示段位，判断是晋级还是开启晋级赛
    self.tween3 = function()
        self.bgImage.gameObject:SetActive(true)
        self.LevText.gameObject:SetActive(true)
        if self.lvlUp then
            LuaTimer.Add(500,function ()
                self.tween6()
            end)
        else
            self.tween4()
        end
    end

    -- 头像框框弹出来
    self.tween7 = function ()
        self.c21.localScale = Vector3.zero
        self.c22.localScale = Vector3.zero
        self.c23.localScale = Vector3.zero
        self.center.localScale = Vector3.zero
        self.c3.localScale = Vector3.zero
        self.bgc.localScale = Vector3.zero
        self.cf.localScale = Vector3.zero
        self.headbg.localScale = Vector3.zero
        self.CenterCircle.gameObject:SetActive(true)
        self.Head.gameObject:SetActive(true)

        Tween.Instance:Scale(self.c21, Vector3(1, 1, 1), 0.3, function()end, LeanTweenType.easeOutBack)
        Tween.Instance:Scale(self.c22, Vector3(1, 1, 1), 0.3, function()end, LeanTweenType.easeOutBack)
        Tween.Instance:Scale(self.c23, Vector3(1, 1, 1), 0.3, function()end, LeanTweenType.easeOutBack)
        Tween.Instance:Scale(self.center, Vector3(1, 1, 1), 0.3, function()end, LeanTweenType.easeOutBack)

        LuaTimer.Add(300,function()
            Tween.Instance:Scale(self.c3, Vector3(1, 1, 1), 0.3, function()end, LeanTweenType.easeOutBack)
        end)
        LuaTimer.Add(500,function()
            Tween.Instance:Scale(self.cf, Vector3(1, 1, 1), 0.3, function()end, LeanTweenType.easeOutBack)
            Tween.Instance:Scale(self.bgc, Vector3(1, 1, 1), 0.3, function()end, LeanTweenType.easeOutBack)
            Tween.Instance:Scale(self.headbg, Vector3(1, 1, 1), 0.3, self.tween3, LeanTweenType.easeOutBack)
        end)
    end


    -- -- 播特效
    -- self.tween2 = function()
    --     if self.lvlUp then
    --         self.effect = BaseUtils.ShowEffect(20460, self.TitleImage, Vector3(1,1,1), Vector3(0,0,-1000))
    --         LuaTimer.Add(600,function() self.tween7() end)
    --     else
    --         self.effect2 = BaseUtils.ShowEffect(20459, self.TitleImage, Vector3(0.73,0.7,1), Vector3(-2,0,-1000))
    --         self.tween7()
    --     end
    -- end

    -- 标题掉下来
    self.tween = function()
        if BaseUtils.isnull(self.TitleImage) then
            return
        end
        Tween.Instance:MoveLocalY(self.TitleImage.gameObject, endpos.y, 0.3, function() end, LeanTweenType.easeOutBack)
        if self.lvlUp then
            LuaTimer.Add(100,function()
                self.effect = BaseUtils.ShowEffect(20460, self.TitleImage, Vector3(1,1,1), Vector3(0,0,-1000))
                LuaTimer.Add(600,function() self.tween7() end)
            end)
        else
            LuaTimer.Add(300,function()
                self.effect2 = BaseUtils.ShowEffect(20459, self.TitleImage, Vector3(0.73,0.7,1), Vector3(-2,0,-1000))
                self.tween7()
            end)
        end
    end
    self.tween()
end

