-- @author huangzefeng
-- @date 2016年6月23日,星期四

WorldChampionSuccessWindow = WorldChampionSuccessWindow or BaseClass(BaseWindow)

function WorldChampionSuccessWindow:__init(model)
    self.model = model
    self.Mgr = self.model.mgr
    self.name = "WorldChampionSuccessWindow"

    self.downEffect = "prefabs/effect/20148.unity3d"
    self.upEffect = "prefabs/effect/20147.unity3d"
    self.fulleffect = "prefabs/effect/20149.unity3d"
    self.resList = {
        {file = AssetConfig.worldchampionsuccess, type = AssetType.Main},
        {file = self.downEffect, type = AssetType.Main},
        {file = self.upEffect, type = AssetType.Main},
        {file = self.fulleffect, type = AssetType.Main},
        {file = AssetConfig.no1inworld_textures, type = AssetType.Dep},
        {file = AssetConfig.getwini18n, type = AssetType.Main},
    }

    self.iocnPath = {[1] = "I18NGodLike",[2] = "Attacker",[3] = "Killer",[4] = "Mvp",[5] = "Defender",[6] = "Ctr",[7] = "Mvp2"}
    self.honorname = {[1] = "超神",[2] = "火力全开",[3] = "杀人如麻",[4] = "胜方MVP",[5] = "治愈之光",[6] = "Hold住全场",[7] = "败方MVP"}

    self.isend = false
    self.time1 = 1
    self.slotlist = {}
    self.honorextpoint_list = {}
end


function WorldChampionSuccessWindow:__delete()
    self.OnHideEvent:Fire()
    for k,v in pairs(self.slotlist) do
        v:DeleteMe()
    end
    if self.headLoader ~= nil then
        self.headLoader:DeleteMe()
        self.headLoader = nil
    end
    if self.headLoader2 ~= nil then
        self.headLoader2:DeleteMe()
        self.headLoader2 = nil
    end
    if self.headLoader3 ~= nil then
        self.headLoader3:DeleteMe()
        self.headLoader3 = nil
    end
    if self.effect ~= nil then
        for _,v in pairs(self.effect) do
            v:DeleteMe()
        end
        self.effect = nil
    end
    self.slotlist = {}
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function WorldChampionSuccessWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.worldchampionsuccess))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = t

    self.data = self.openArgs
    BaseUtils.dump(self.data,"界面内结构")
    -- -- --模拟数据
    -- self.data = {
    --     result = 1,
    --     a_rank_lev = 8,
    --     b_rank_lev = 8,
    --     a_rank_point = 800,
    --     b_rank_point = 800,
    --     honor_point = 5,
    --     hornor_show = 3,
    --     b_store_point = 40,
    --     assets = {{assets_id =20000 ,val = 2}},
    --     promotion_win = 2,
    --     combat_reward = {{item_id = 20000,num = 1},{item_id = 20001,num = 2},{item_id = 20002,num =3 }}
    -- }

    self.isLvlUp = false
    self.lvlUp = false
    self.openLvlUp = false

    -- 是否是晋级赛
    if self.data.b_rank_point%100 == 0 and self.data.b_rank_point/100 == self.data.b_rank_lev and self.data.b_rank_lev < 10 then
        self.isLvlUp = true
    end
    -- 是否晋级成功
    if self.data.a_rank_lev > self.data.b_rank_lev then
        self.lvlUp = true
    end
    -- 是否开启晋级赛
    if self.data.a_rank_point%100 == 0 and self.data.a_rank_point ~= 0 and self.data.a_rank_lev < 10 and not self.isLvlUp and self.data.a_rank_point/100 == self.data.a_rank_lev then
        self.openLvlUp = true
    end

    self.bgPanel = self.transform:Find("bgPanel"):GetComponent(Button)
    self.bgPanel.onClick:AddListener(function()
        if self.isend then
            self.model:CloseSuccessWindow()
            if self.lvlUp or self.openLvlUp then
                self.model:OpenLvlUpWindow(self.data)
            else
                self.model:OpenCountInfoWindow(self.data)
            end
        end
    end)

    local btn = self.transform:Find("Main/endText").gameObject:AddComponent(Button)
    btn.onClick:AddListener(function ()
        if self.isend then
            self.model:CloseSuccessWindow()
            if self.lvlUp or self.openLvlUp then
                self.model:OpenLvlUpWindow(self.data)
            else
                self.model:OpenCountInfoWindow(self.data)
            end
        end
    end)

    self.Item = t:Find("Main/Item")
    self.Item.gameObject:SetActive(false)
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
    self.NumBg = self.transform:Find("Main/NumBg")
    self.Num = self.transform:Find("Main/Num")
    self.bgImage = self.transform:Find("Main/bgImage")
    self.LevText = self.transform:Find("Main/LevText")

    self.detailPoint = self.transform:Find("Main/DetailPoint")
    self.resultPoint = self.transform:Find("Main/Result")
    self.changePoint = self.resultPoint:Find("general/changepoint")
    self.winorlost = self.resultPoint:Find("lvlup/winorlost")
    self.lvlupPro = self.transform:Find("Main/LvlupPro")

    self.detailPoint.localPosition = Vector3(135,-25,0)
    self.resultPoint.localPosition = Vector3(135,99,0)
    self.Item.localPosition = Vector3(120,-140,0)

    self.detailPoint:Find("Point1"):GetComponent(Text).text = ""
    self.detailPoint:Find("Honor/Point2"):GetComponent(Text).text = ""



    self.icondesc = self.transform:Find("IconDescCon")
    for i = 1 , 7 do
        self.honorextpoint_list[i] = self.icondesc:Find(string.format( "Bg/Item%d",i))
        self.honorextpoint_list[i].transform:GetChild(7):GetComponent(Text).text = DataTournament.data_get_all_honor[i].ext_point
    end
    
    self.icondesc:Find("Bg/Tips"):GetComponent(Text).text = TI18N("【结算称号可获得荣誉加分，多项荣誉则取最高】")
    self.icondesc:Find("bgPanel"):GetComponent(Button).onClick:AddListener(function ()
        self.icondesc.gameObject:SetActive(false)
    end)
    self.icondesc:Find("Bg/Button"):GetComponent(Button).onClick:AddListener(function ()
        self.icondesc.gameObject:SetActive(false)
    end)
    self.detailPoint:Find("Honor"):GetComponent(Button).onClick:AddListener(function ()
        self.icondesc.gameObject:SetActive(true)
    end)

    if self.data.result == 2 then
        self.TitleImage:GetComponent(Image).enabled = false
        self.TitleImage:Find("LoseImage").gameObject:SetActive(true)
    end
    local LvData = DataTournament.data_list[self.data.a_rank_lev]

    if self.data.a_rank_point - self.data.b_rank_point >= 0 and self.data.a_rank_lev == self.data.b_rank_lev then
        -- local p = self.data.b_rank_point%100
        local p = self.data.win_point
        if self.isLvlUp then
            p = 100
        end
        self.Num:GetComponent(Text).text = p.."/100"
        self.NumBg.sizeDelta = Vector2(self.Num:GetComponent(Text).preferredWidth+20, 30)
    elseif self.data.a_rank_lev == self.data.b_rank_lev then
        -- local p = self.data.b_rank_point%100
        local p = self.data.win_point
        if self.isLvlUp then
            p = 100
        end
        self.Num:GetComponent(Text).text = p.."/100"
        self.NumBg.sizeDelta = Vector2(self.Num:GetComponent(Text).preferredWidth+20, 30)
    elseif self.data.a_rank_lev > self.data.b_rank_lev then
        -- local p = self.data.b_rank_point%100
        local p = self.data.win_point
        if self.isLvlUp then
            p = 100
        end
        self.Num:GetComponent(Text).text = p.."/100"
        self.NumBg.sizeDelta = Vector2(self.Num:GetComponent(Text).preferredWidth+20, 30)
        -- self.Num:GetComponent(Text).text = TI18N("晋级")
        -- self.upEffectgo = GameObject.Instantiate(self:GetPrefab(self.upEffect))
        -- self.upEffectgo.transform:SetParent(self.transform:Find("Main"))
        -- self.upEffectgo.transform.localScale = Vector3.one
        -- self.upEffectgo.transform.localPosition = Vector3(0,0, -1000)
        -- Utils.ChangeLayersRecursively(self.upEffectgo.transform, "UI")
        -- self.upEffectgo:SetActive(false)
    -- elseif self.data.a_rank_lev < self.data.b_rank_lev then
    --     self.Num:GetComponent(Text).text = TI18N("<color='#ff0000'>降级</color>")
    --     self.downEffectgo = GameObject.Instantiate(self:GetPrefab(self.downEffect))
    --     self.downEffectgo.transform:SetParent(self.transform:Find("Main"))
    --     self.downEffectgo.transform.localScale = Vector3.one
    --     self.downEffectgo.transform.localPosition = Vector3(0,0, -1000)
    --     Utils.ChangeLayersRecursively(self.downEffectgo.transform, "UI")
    --     self.downEffectgo:SetActive(false)
    end
    -- if self.data.a_rank_point > 0 and self.data.a_rank_point% 100 == 0 and self.data.a_rank_point/100 == self.data.a_rank_lev then
    --     self.fulleffectgo = GameObject.Instantiate(self:GetPrefab(self.fulleffect))
    --     self.fulleffectgo.transform:SetParent(self.transform:Find("Main"))
    --     self.fulleffectgo.transform.localScale = Vector3.one
    --     self.fulleffectgo.transform.localPosition = Vector3(-1.67, 28.76, -1000)
    --     Utils.ChangeLayersRecursively(self.fulleffectgo.transform, "UI")
    --     self.fulleffectgo:SetActive(false)
    -- end
    self.LevText:GetComponent(Text).text = string.format(TI18N("<color='#ede995'>%s</color>"),LvData.boxname)
    if self.data.a_rank_lev == self.data.b_rank_lev then
        if self.headLoader == nil then
            self.headLoader = SingleIconLoader.New(self.Head:GetComponent(Image).gameObject)
        end
        self.headLoader:SetSprite(SingleIconType.Pet, LvData.icon)
        -- self.Head:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(LvData.icon), LvData.icon)
    else
        -- if self.headLoader2 == nil then
        --     self.headLoader2 = SingleIconLoader.New(self.currsprite.gameObject)
        -- end
        -- self.headLoader2:SetSprite(SingleIconType.Pet,DataTournament.data_list[self.data.a_rank_lev].icon)
        -- self.currsprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(DataTournament.data_list[self.data.a_rank_lev].icon), DataTournament.data_list[self.data.a_rank_lev].icon)
        -- self.lastsprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(DataTournament.data_list[self.data.b_rank_lev].icon), DataTournament.data_list[self.data.b_rank_lev].icon)
        -- if self.headLoader3 == nil then
        --     self.headLoader3 = SingleIconLoader.New(self.lastsprite.gameObject)
        -- end
        -- self.headLoader3:SetSprite(SingleIconType.Pet,DataTournament.data_list[self.data.b_rank_lev].icon)
        self.currstr = DataTournament.data_list[self.data.a_rank_lev].boxname
        self.laststr = DataTournament.data_list[self.data.b_rank_lev].boxname
        if self.headLoader == nil then
            self.headLoader = SingleIconLoader.New(self.Head:GetComponent(Image).gameObject)
        end
        self.headLoader:SetSprite(SingleIconType.Pet,DataTournament.data_list[self.data.b_rank_lev].icon)
        -- self.Head:GetComponent(Image).sprite = self.lastsprite
        self.LevText:GetComponent(Text).text = string.format(TI18N("<color='#ede995'>%s</color>"),self.laststr)
    end
    self:LoadItem()
    self:StarAnimate()
end

function WorldChampionSuccessWindow:StarAnimate()
    self.CenterCircle.gameObject:SetActive(false)
    self.Head.gameObject:SetActive(false)
    self.NumBg.gameObject:SetActive(false)
    self.Num.gameObject:SetActive(false)
    self.bgImage.gameObject:SetActive(false)
    self.LevText.gameObject:SetActive(false)

    local endpos = self.TitleImage.localPosition
    self.TitleImage.localPosition = Vector3(0, 336, 0)

    -- 显示结束提示，窗口可以关闭
    self.tween7 = function()
        if BaseUtils.isnull(self.Num) then
            return
        end
        self.tween6()
    end

    -- 经验条滚到当前值
    self.tween6 = function()
        if BaseUtils.isnull(self.Num) then
            return
        end


        local changeVal1 = function(val)
            if BaseUtils.isnull(self.Num) then
                return
            end
            self.Num:GetComponent(Text).text = string.format("%s/100", Mathf.Round(val*100))
            self.NumBg.sizeDelta = Vector2(self.Num:GetComponent(Text).preferredWidth+20, 30)
            -- self.Circle.fillAmount = val
        end
        local changeVal2 = function(val)
            if BaseUtils.isnull(self.Circle2) == false then
                self.Circle2.fillAmount = val
                self.Circle.fillAmount = val
            end
        end
        local endcallback = function()
            SoundManager.Instance:StopId(241)
            if self.data.a_rank_lev ~= self.data.b_rank_lev or BaseUtils.isnull(self.transform) then
                -- LuaTimer.Add(800, self.tween7)
                return
            end
            if (self.data.a_rank_point%100 == 0 and self.fulleffectgo ~= nil) or self.data.a_rank_point/100 > self.data.a_rank_lev then
                if self.fulleffectgo ~= nil then
                    self.fulleffectgo:SetActive(true)
                end
                local nextLvData = DataTournament.data_list[self.data.a_rank_lev+1]
                if nextLvData ~= nil and self.data.a_rank_lev >= 10 then
                    self.Num:GetComponent(Text).text = TI18N("<color='#ffff00'>每晚23:50全部服务器前100名,且达到<color='#ffff00'>登峰造极50分以上</color>可加冕<color='#ffa500'>星辰王者</color></color>")
                    self.NumBg.sizeDelta = Vector2(self.Num:GetComponent(Text).preferredWidth+20, 30)
                -- elseif nextLvData ~= nil and self.data.a_rank_lev == self.data.b_rank_lev then
                --     self.Num:GetComponent(Text).text = TI18N("<color='#ffff00'>每晚23:50全部服务器前100名可加冕<color='#ffa500'>星辰王者</color></color>")
                --     self.NumBg.sizeDelta = Vector2(self.Num:GetComponent(Text).preferredWidth+20, 30)
                -- else
                --     self.Num:GetComponent(Text).text = string.format(TI18N("<color='#ffff00'>晋级战！下一场获胜可晋级：%s</color>"), nextLvData.name)
                --     self.NumBg.sizeDelta = Vector2(self.Num:GetComponent(Text).preferredWidth+20, 30)
                end
            end
        end
        local startval = self.Circle.fillAmount
        -- if startval == 1 and self.data.a_rank_lev > self.data.b_rank_lev then
        --     startval = 0
        --     self.Circle.fillAmount = 0
        --     self.Circle2.fillAmount = 0
        -- elseif startval == 0 then
        --     self.Circle.fillAmount = 1
        --     self.Circle2.fillAmount = 1
        -- end
        local endval = self.data.a_rank_point%100/100
        if self.data.a_rank_point/100 > self.data.a_rank_lev then
            endval = 1
        end
        -- if endval == 1 and self.data.a_rank_lev < self.data.b_rank_lev then
        --     endval = 0
        -- elseif endval == 0 and self.data.a_rank_point/100 == self.data.a_rank_lev then
        if endval == 0 and self.data.a_rank_point/100 == self.data.a_rank_lev then
            endval = 1
        elseif self.data.a_rank_lev == #DataTournament.data_list then
            endval = 1
        end
        if self.isLvlUp or self.data.a_rank_lev >= 10 then
            endval = 1
        end
        -- local time = math.abs(endval - startval)
        SoundManager.Instance:Play(241)
        -- Tween.Instance:ValueChange(startval, endval, time*2, endcallback, LeanTweenType.linear, changeVal1)
        -- self.time1 = endval/(endval+1-startval) * 1.3

        -- if self.data.a_rank_lev > self.data.b_rank_lev then
        --     Tween.Instance:ValueChange(startval, 1, self.time1, function()end, LeanTweenType.linear, changeVal1)
        --     Tween.Instance:ValueChange(startval, 1, self.time1, self.tween8, LeanTweenType.linear, changeVal2)
        -- else
            Tween.Instance:ValueChange(startval, endval, 1.3 * math.abs(endval - startval) , endcallback, LeanTweenType.linear, changeVal1)
            Tween.Instance:ValueChange(startval, endval, 1.3 * math.abs(endval - startval) , self.tween10, LeanTweenType.linear, changeVal2)
        -- end
    end

    self.tween10 = function ()
        self.Item.gameObject:SetActive(true)
        self.effect = {}
        for i=1,#self.data.combat_reward do
            LuaTimer.Add(300*(i- 1),function()
                self.itemicon[i]:SetActive(true)
                self.effect[i] = BaseUtils.ShowEffect(20464, self.itemicon[i].transform, Vector3(1,1,1), Vector3(0,0,-1000))
            end)
        end
        LuaTimer.Add(300*(#self.data.combat_reward),function ()
            self.isend = true
            self.transform:Find("Main/endText").gameObject:SetActive(true)
        end)
    end

    -- 显示左下的进度
    self.tween5 = function()
        SoundManager.Instance:StopId(241)
        if BaseUtils.isnull(self.Num) then
            return
        end
        if self.isLvlUp then
            local needwin = DataTournament.data_get_promotion_combat[self.data.b_rank_lev].need_win
            local name = DataTournament.data_get_promotion_combat[self.data.b_rank_lev + 1].name
            self.lvlupPro:Find("Text"):GetComponent(Text).text = string.format(TI18N("累计<color='#ffff00'>%s胜</color>即可晋级<color='#ffff00'>%s</color>"), needwin,name)
            local t
            if needwin > 3 then
                t = self.lvlupPro:Find("fourgame")
            else
                t = self.lvlupPro:Find("threegame")
                if needwin == 2 then
                    t:Find(tostring(3)):GetComponent(Image).color = Color(1, 1, 1, 0.2)
                end
            end
            local win = self.data.promotion_win
            if self.data.result == 1 then
                if win > 1 then
                    for i=1,win-1 do
                        t:Find(tostring(i)):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.no1inworld_textures,"done")
                    end
                    t.gameObject:SetActive(true)
                    self.lvlupPro.gameObject:SetActive(true)
                    LuaTimer.Add(300,function()
                        t:Find(tostring(win)):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.no1inworld_textures,"done")
                        t:Find(tostring(win)).localScale = Vector3(5,5,5)
                        Tween.Instance:Scale(t:Find(tostring(win)), Vector3(1, 1, 1), 0.3, function()end, LeanTweenType.easeOutBack)
                    end)
                elseif win == 1 then
                    t.gameObject:SetActive(true)
                    self.lvlupPro.gameObject:SetActive(true)
                    LuaTimer.Add(300,function()
                        t:Find(tostring(win)):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.no1inworld_textures,"done")
                        t:Find(tostring(win)).localScale = Vector3(5,5,5)
                        Tween.Instance:Scale(t:Find(tostring(win)), Vector3(1, 1, 1), 0.3, function()end, LeanTweenType.easeOutBack)
                    end)
                elseif win == 0 and self.lvlUp then
                    for i=1,needwin-1 do
                        t:Find(tostring(i)):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.no1inworld_textures,"done")
                    end
                    t.gameObject:SetActive(true)
                    self.lvlupPro.gameObject:SetActive(true)
                    LuaTimer.Add(300,function()
                        t:Find(tostring(needwin)):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.no1inworld_textures,"done")
                        t:Find(tostring(needwin)).localScale = Vector3(5,5,5)
                        Tween.Instance:Scale(t:Find(tostring(needwin)), Vector3(1, 1, 1), 0.3, function()end, LeanTweenType.easeOutBack)
                    end)
                end
                LuaTimer.Add(900, self.tween7)
            else
                if win > 1 then
                    for i=1,win do
                        t:Find(tostring(i)):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.no1inworld_textures,"done")
                    end
                elseif win == 1 then
                    t:Find(tostring(1)):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.no1inworld_textures,"done")
                end
                t.gameObject:SetActive(true)
                self.lvlupPro.gameObject:SetActive(true)
                LuaTimer.Add(300, self.tween7)
            end


        else
            if self.data.a_rank_lev < 10 then
                self.NumBg.gameObject:SetActive(true)
                self.Num.gameObject:SetActive(true)
            end
            LuaTimer.Add(300, self.tween7)
        end
    end

    -- 经验条滚到上次初始值
    self.tween4 = function()
        if BaseUtils.isnull(self.Circle) then
            return
        end
        local changeVal = function(val)
            self.Circle.fillAmount = val
            self.Circle2.fillAmount = val
        end
        local endval = self.data.b_rank_point%100/100
        if self.isLvlUp or self.data.a_rank_lev >= 10 then
            endval = 1
        end
        self.bgImage.gameObject:SetActive(true)
        self.LevText.gameObject:SetActive(true)
        SoundManager.Instance:Play(241)
        Tween.Instance:ValueChange(0, endval, 1.2*endval,self.tween11 , LeanTweenType.linear, changeVal)


    end

    -- 下面的分数飞过来
    self.tween11 = function ()
        local pos = self.detailPoint.localPosition
        self.detailPoint.localPosition = Vector3(360,pos.y,pos.z)
        self.detailPoint:Find("Honor/Point2"):GetComponent(Text).text = "+"..self.data.honor_point
        if self.data.hornor_show ~= 0 then
            local honorname = self.honorname[self.data.hornor_show]
            local point = DataTournament.data_get_all_honor[self.data.hornor_show].ext_point
            self.detailPoint:Find("desc"):GetComponent(Text).text = string.format(TI18N("本场获得最佳荣誉[%s]+%s"),honorname,point)
            self.detailPoint:Find("Honor/Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.no1inworld_textures,self.iocnPath[self.data.hornor_show])
            self.detailPoint:Find("Honor/Icon"):GetComponent(Image).color = Color(1, 1, 1, 1)
        else
            self.detailPoint:Find("desc"):GetComponent(Text).text = TI18N("（战斗荣誉将会获得额外加分）")
            self.detailPoint:Find("Honor/Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.no1inworld_textures,self.iocnPath[4])
            self.detailPoint:Find("Honor/Icon"):GetComponent(Image).color = Color(0.4, 0.4, 0.4, 1)
        end
        if self.data.result == 2 then
            self.detailPoint:Find("text1"):GetComponent(Text).text = TI18N("战斗失败")
        end
        if self.isLvlUp then
            self.detailPoint:Find("lvlup").gameObject:SetActive(true)
            self.detailPoint:Find("desc"):GetComponent(Text).text = TI18N("（晋级成功后将直接获得头衔积分）")
            self.detailPoint:Find("desc"):GetComponent(RectTransform).anchoredPosition = Vector3(0,-58,0)
            self.detailPoint:Find("Point3").gameObject:SetActive(true)
            self.detailPoint:Find("Point4").gameObject:SetActive(true)
            self.detailPoint:Find("Point3"):GetComponent(Text).text = self.data.b_store_point

            local p = self.data.win_point
            if self.data.result == 1 then
                self.detailPoint:Find("Point1"):GetComponent(Text).text = "+"..p
                -- self.detailPoint:Find("Point4"):GetComponent(Text).text = "+"..(p+self.data.honor_point)
            else
                if p == 0 then
                    self.detailPoint:Find("Point1"):GetComponent(Text).text = "+"..p
                else
                    self.detailPoint:Find("Point1"):GetComponent(Text).text = p
                end
                if self.data.honor_point >= p then
                    -- self.detailPoint:Find("Point4"):GetComponent(Text).text = "+"..(self.data.honor_point-p)
                else
                    if p - self.data.honor_point < self.data.b_store_point then
                        -- self.detailPoint:Find("Point4"):GetComponent(Text).text = "-"..(p-self.data.honor_point)
                    else
                        self.detailPoint:Find("Point3"):GetComponent(Text).text = 0
                        -- self.detailPoint:Find("Point4"):GetComponent(Text).text = ""
                    end
                end
            end

            if self.data.honor_point + p > 0 then
                self.detailPoint:Find("Point4"):GetComponent(Text).text = "+"..(self.data.honor_point + p)
            elseif self.data.honor_point + p < 0 then
                self.detailPoint:Find("Point4"):GetComponent(Text).text = self.data.honor_point + p
            else
                self.detailPoint:Find("Point4"):GetComponent(Text).text = ""
            end

        else
            local p = self.data.win_point
            self.detailPoint:Find("desc"):GetComponent(RectTransform).anchoredPosition = Vector3(0,-18,0)
            if p >=0 then
                self.detailPoint:Find("Point1"):GetComponent(Text).text = "+"..p
            else
                self.detailPoint:Find("Point1"):GetComponent(Text).text = p
            end
        end
        self.detailPoint.gameObject:SetActive(true)
        Tween.Instance:MoveLocalX(self.detailPoint.gameObject,pos.x , 0.5, self.tween8, LeanTweenType.easeOutBack)
    end




    -- 上面的分飞过来
    self.tween8 = function ()
        local pos = self.resultPoint.localPosition
        if self.isLvlUp then
            self.resultPoint:Find("general").gameObject:SetActive(false)
            self.resultPoint:Find("lvlup/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.getwini18n,"GetWinI18N")
            self.resultPoint:Find("lvlup").gameObject:SetActive(true)
            if self.data.result == 2 then
                self.winorlost.gameObject:SetActive(true)
            end
        else
            local point = 0
            if self.data.b_rank_point > 900 then
                point = self.data.b_rank_point - 900
            else
                point = self.data.b_rank_point%100
            end
            self.resultPoint:Find("general/oripoint"):GetComponent(Text).text = point
            if self.data.result == 2 then
                local p = self.data.a_rank_point - self.data.b_rank_point
                if p >= 0 then
                    self.changePoint:GetComponent(Text).text = "+"..p
                else
                    if point + p > 0 then
                        self.changePoint:GetComponent(Text).text = p
                    else
                        self.changePoint:GetComponent(Text).text = ""
                        self.resultPoint:Find("general/oripoint"):GetComponent(Text).text = 0
                    end
                end
                self.changePoint.gameObject:SetActive(true)
            end
        end
        self.resultPoint.gameObject:SetActive(true)
        if self.data.result == 2 then
            self.tween5()
        else
            self.resultPoint.localPosition = Vector3(360,pos.y,pos.z)
            Tween.Instance:MoveLocalX(self.resultPoint.gameObject,pos.x , 0.5, self.tween9, LeanTweenType.easeOutBack)
        end
    end

    -- 结算结果打上去
    self.tween9 = function ()
        LuaTimer.Add(300,function ()
            if self.isLvlUp then
                self.winorlost.localScale = Vector3(5,5,5)
                if self.data.result == 1 then
                    self.winorlost:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.no1inworld_textures,"done")
                end
                self.winorlost.gameObject:SetActive(true)
                Tween.Instance:Scale(self.winorlost, Vector3(1, 1, 1), 0.3, self.tween5, LeanTweenType.easeOutBack)
            else
                self.changePoint.localScale = Vector3(5,5,5)
                local p = self.data.a_rank_point - self.data.b_rank_point
                if p >= 0 then
                    self.changePoint:GetComponent(Text).text = "+"..p
                else
                    self.changePoint:GetComponent(Text).text = p
                end
                self.changePoint.gameObject:SetActive(true)
                Tween.Instance:Scale(self.changePoint, Vector3(1, 1, 1), 0.3, self.tween5, LeanTweenType.easeOutBack)
            end
        end)
    end

    -- 头像框框弹出来
    self.tween3 = function()
        if BaseUtils.isnull(self.Head) then
            return
        end
        -- self.CenterCircle.localScale = Vector3.zero
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
        if not self.isLvlUp and self.data.a_rank_lev < 10  then
            self.NumBg.gameObject:SetActive(true)
            self.Num.gameObject:SetActive(true)
        end

        Tween.Instance:Scale(self.c21, Vector3(1, 1, 1), 0.3, function()end, LeanTweenType.easeOutBack)
        Tween.Instance:Scale(self.c22, Vector3(1, 1, 1), 0.3, function()end, LeanTweenType.easeOutBack)
        Tween.Instance:Scale(self.c23, Vector3(1, 1, 1), 0.3, function()end, LeanTweenType.easeOutBack)
        Tween.Instance:Scale(self.center, Vector3(1, 1, 1), 0.3, function()end, LeanTweenType.easeOutBack)
        -- LuaTimer.Add(200,function()
        -- end)
        LuaTimer.Add(300,function()
            Tween.Instance:Scale(self.c3, Vector3(1, 1, 1), 0.3, function()end, LeanTweenType.easeOutBack)
        end)
        LuaTimer.Add(500,function()
            Tween.Instance:Scale(self.cf, Vector3(1, 1, 1), 0.3, function()end, LeanTweenType.easeOutBack)
            Tween.Instance:Scale(self.bgc, Vector3(1, 1, 1), 0.3, function()end, LeanTweenType.easeOutBack)
            Tween.Instance:Scale(self.headbg, Vector3(1, 1, 1), 0.3, self.tween4, LeanTweenType.easeOutBack)
        end)
        if BaseUtils.isnull(self.Circle) then
            return
        end
    end

    -- 标题掉下来
    self.tween2 = function()
        if BaseUtils.isnull(self.TitleImage) then
            return
        end
        Tween.Instance:MoveLocalY(self.TitleImage.gameObject, endpos.y, 0.3, self.tween3, LeanTweenType.easeOutBack)
    end
    self.tween2()
    -- Tween.Instance:Scale(self.TitleImage, Vector3(1, 1, 1), 0.8, tween2, LeanTweenType.easeOutBack)
end

function WorldChampionSuccessWindow:LoadItem()
    if self.data.combat_reward == nil then
        return
    end
    self.itemicon = {}
    for i,v in ipairs(self.data.combat_reward) do
        local baseid = v.item_id
        local slot = ItemSlot.New()
        local info = ItemData.New()
        local base = DataItem.data_get[baseid]
        info:SetBase(base)
        info.quantity = v.num
        local extra = {inbag = false, nobutton = true}
        slot:SetAll(info, extra)

        UIUtils.AddUIChild(self.Item.gameObject, slot.gameObject)
        slot.gameObject:SetActive(false)
        -- local itemeffectgo = GameObject.Instantiate(self.itemeffectgo)
        -- itemeffectgo.transform:SetParent(slot.transform)
        -- itemeffectgo.transform.localScale = Vector3.one
        -- itemeffectgo.transform.localPosition = Vector3(0, 2, -1000)
        -- Utils.ChangeLayersRecursively(itemeffectgo.transform, "UI")
        -- itemeffectgo:SetActive(true)
        table.insert(self.slotlist, slot)
        table.insert(self.itemicon, slot.gameObject)
    end

    local X = -1
    if #self.itemicon%2 == 0 then
        X = -0.5
        for i,v in ipairs(self.itemicon) do
            v.transform.anchoredPosition = Vector2((math.ceil(i/2)*2-1)*70*X, 9)
            X = X*-1
        end
    else
        for i,v in ipairs(self.itemicon) do
            v.transform.anchoredPosition = Vector2(math.floor(i/2)*70*X, 9)
            X = X*-1
        end
    end

    local function sort_(a, b)
        return a.transform.position.x < b.transform.position.x
    end

    table.sort(self.itemicon,sort_)


end
