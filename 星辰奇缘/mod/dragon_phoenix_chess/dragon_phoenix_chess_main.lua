-- @author hze
-- @date 2018/06/07
--龙凤棋

DragonPhoenixChessMain = DragonPhoenixChessMain or BaseClass(BasePanel)

function DragonPhoenixChessMain:__init(model)
    self.model = model
    self.name = "DragonPhoenixChessMain"

    -- self.model.selectPath = self.model.selectPath or "prefabs/effect/30002.unity3d"
    self.originGridPos = Vector2(3, -118.5)
    self.originShowDelta = Vector2(240, 0)

    -- self.ChessType = {
    --     EMPTY = 0,          --空
    --     PHOENIX = 1,        --凤棋
    --     DRAGON = 2,         --龙棋
    --     ABLE = 3                --可下
    -- }

    self.chessTopIcon = {"phoenixicon", "dragonicon"}

    self.resList = {
        {file = AssetConfig.dragonphoenixchessmain, type = AssetType.Main},
        {file = AssetConfig.dragon_chess_bg, type = AssetType.Main},
        {file = AssetConfig.dragon_chess_tips, type = AssetType.Main},
        {file = AssetConfig.dragon_chess_tips1, type = AssetType.Main},
        {file = AssetConfig.dragon_chess_tips2, type = AssetType.Main},
        {file = AssetConfig.dragon_chess_textures, type = AssetType.Dep},
        {file = AssetConfig.dragon_board_bg, type = AssetType.Dep},
        {file = AssetConfig.mainui_textures, type = AssetType.Dep},
    }

    -- 20487 20488
    -- if BaseUtils.IsWideScreen() then
    --     table.insert(self.resList, {file = AssetConfig.animal_chess_left, type = AssetType.Main})
    --     table.insert(self.resList, {file = AssetConfig.animal_chess_right, type = AssetType.Main})
    -- end


    self.chessTab = {{}, {}, {}, {}, {}, {}, {}, {}}
    self.characterList = {{}, {}}     --人物列表
    self.slotList = {}  --技能列表

    self.speakList = {}

    self.speakFlag = true

    self.slotinfo = {
        {TI18N("求和"), "peace"},
        {TI18N("认输"), "defeat"},
        {TI18N("表情"), "speak"},
    }

    --记录下子位置
    self.x = 1
    self.y = 1

    --缩放大小
    self.scaleX = 1
    self.scaleY = 1


    --显示主UI
    self.isShowMainUIIcon = true

    self.mainUIButtonList = {}
    self.systemBtnList = {
        {id = 18, showFunc = function() return true end, clickFunc = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.market) end, res = "I18NMarketButtonIcon"},     -- 市场
        {id = 6, showFunc = function() return true end, clickFunc = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop) end, res = "I18NShopButtonIcon"},      -- 商城
        {id = 14, showFunc = function() return true end, clickFunc = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.agendamain) end, res = "I18NAgenda"},     -- 日程
        {id = 17, showFunc = function() return true end, clickFunc = function() ImproveManager.Instance.model:OpenMyWindow() end, res = "I18NUpgradeButtonIcon"},     -- 提升
        {id = 8, showFunc = function() return true end, clickFunc = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.setting_window) end, res = "I18NSettingsButtonIcon2"},      -- 设置
        {id = 28, showFunc = function() return true end, clickFunc = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.arena_window) end, res = "I18NArenaButtonIcon"},     -- 竞技场
        {id = 29, showFunc = function() return true end, clickFunc = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.autofarmwin) end, res = "I18NHandupButtonIcon"},     -- 挂机
        {id = 37, showFunc = function() return true end, clickFunc = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.reward_back_window) end, res = "I18NRewardBackButton"},     -- 奖励找回
        {id = 107, showFunc = function() return not FirstRechargeManager.Instance:isHadDoFirstRecharge() end, clickFunc = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.firstrecharge_window) end},    -- 首充
    }

    self.mainUIButtonListRightDown = {}
    self.systemBtnListRightDown = {
        {id = 22, showFunc = function() return true end, clickFunc = function()
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.biblemain)
            -- AnimalChessManager.Instance:InitChess()
        end, res = "I18NRewards"},     -- 市场
        {id = 2, showFunc = function() return true end, clickFunc = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guildinfowindow) end, res = "I18NGuildButtonIcon"},      -- 公会
        {id = 1, showFunc = function() return true end, clickFunc = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.backpack) end, res = "I18NBackpackButtonIcon"},     -- 背包
    }


    self.updateListener = function() self:Update() end
    self.updateSpeakListener = function(data) self:SpeakChess(data) end
    self.updateOverSpeakListener = function(data) self:OverSpeaking(data)   end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function DragonPhoenixChessMain:__delete()
    self.OnHideEvent:Fire()

    local x = nil
    local y = nil
    for i=1,64 do
        x = math.ceil(i / 8)
        y = (i - 1) % 8 + 1
        if self.chessTab[x] ~= nil then
            if self.chessTab[x][y] ~= nil then
                self.chessTab[x][y]:DeleteMe()
            end
        end
    end
    self.chessTab = nil

    for _,v in ipairs(self.speakList) do
        if v ~= nil and v.speakTxt ~= nil then
            v.speakTxt:DeleteMe()
        end
    end

    for _,v in ipairs(self.slotList) do
        if v ~= nil then
            BaseUtils.ReleaseImage(v.img)
        end
    end


    if self.effect1 ~= nil then
        self.effect1:DeleteMe()
        self.effect1 = nil
    end

    if self.effect2 ~= nil then
        self.effect2:DeleteMe()
        self.effect2 = nil
    end

     if self.effect3 ~= nil then
        self.effect3:DeleteMe()
        self.effect3 = nil
    end

    if self.own_role ~= nil then
        self.own_role:DeleteMe()
        self.own_role = nil
    end

    if self.other_role ~= nil then
        self.other_role:DeleteMe()
        self.other_role = nil
    end

    if self.mainuiIconLayout ~= nil then
        self.mainuiIconLayout:DeleteMe()
        self.mainuiIconLayout = nil
    end

    if self.roleTurnEffect ~= nil then
        self.roleTurnEffect:DeleteMe()
        self.roleTurnEffect = nil
    end

    if self.enemyTurnEffect ~= nil then
        self.enemyTurnEffect:DeleteMe()
        self.enemyTurnEffect = nil
    end

    self:AssetClearAll()
end

function DragonPhoenixChessMain:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.dragonphoenixchessmain))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    self.transform.localPosition = Vector3(0, 0, 1200)

    local main = t:Find("Main")
    local showArea = main:Find("InfoArea/ShowArea")


    self.gameObject:GetComponent(Canvas).overrideSorting = true

    self.mainTransform = self.transform:FindChild("Main")

    local bg = GameObject.Instantiate(self:GetPrefab(AssetConfig.dragon_chess_bg))
    UIUtils.AddBigbg(main:Find("Bg"), bg)


    if BaseUtils.IsWideScreen() then
        self.scaleX = (ctx.ScreenWidth / ctx.ScreenHeight) / (16 / 9)
        bg.transform.localScale = Vector3(self.scaleX, 1, 1)
        t:Find("Main/InfoArea/Role").anchoredPosition = Vector3(348*self.scaleX,-43,0)
        t:Find("Main/InfoArea/Enemy").anchoredPosition = Vector3(-348*self.scaleX,-43,0)
    else
        self.scaleY = (ctx.ScreenHeight/ ctx.ScreenWidth) / (9 / 16)
        bg.transform.localScale = Vector3(1, self.scaleY, 1)
    end


    self.tipsObj = GameObject.Instantiate(self:GetPrefab(AssetConfig.dragon_chess_tips))
    self.tipsObj.gameObject:SetActive(false)
    UIUtils.AddBigbg(main:Find("Tips"), self.tipsObj)

    self.tipsObj1 = GameObject.Instantiate(self:GetPrefab(AssetConfig.dragon_chess_tips1))
    self.tipsObj1.gameObject:SetActive(false)
    UIUtils.AddBigbg(main:Find("Tips1"), self.tipsObj1)

    self.tipsObj2 = GameObject.Instantiate(self:GetPrefab(AssetConfig.dragon_chess_tips2))
    self.tipsObj2.gameObject:SetActive(false)
    UIUtils.AddBigbg(main:Find("Tips2"), self.tipsObj2)

    self.boardBg = main:Find("InfoArea/ShowAreaBg"):GetComponent(Image)
    self.boardBg.sprite = self.assetWrapper:GetSprite(AssetConfig.dragon_board_bg, "dragonchessboard")

    local x = nil
    local y = nil
    for i=1,64 do
        x = math.ceil(i / 8)
        y = (i - 1) % 8 + 1
        self.chessTab[x][y] = DragonChessItem.New(self.model, showArea:GetChild(i-1).gameObject, self.assetWrapper)
        self.chessTab[x][y].x = x
        self.chessTab[x][y].y = y
        if x % 2 == 1 then
            self.chessTab[x][y].color = y % 2
        else
            self.chessTab[x][y].color = (y + 1) % 2
        end
        local x1 = x
        local y1 = y
        self.chessTab[x][y].btn.onClick:AddListener(function() self:OnClickCell(x1,y1) end)
    end

    self.own_role = DragonChessRole.New(t:Find("Main/InfoArea/Role").gameObject, self.assetWrapper, t:Find("Main/InfoArea/RoleHeadSlot").gameObject, 1)
    self.other_role = DragonChessRole.New(t:Find("Main/InfoArea/Enemy").gameObject, self.assetWrapper, t:Find("Main/InfoArea/EnemyHeadSlot").gameObject, 2)


    self.countDownContainer = main:Find("CountDown")
    self.countDownImg = self.countDownContainer:Find("Clock"):GetComponent(Image)
    self.countDownTime = self.countDownContainer:Find("Time"):GetComponent(Text)

    local skillArea = main:Find("SkillArea")
    self.slotList = {}
    for i=1,3 do
        local tab = {}
        tab.transform = skillArea:GetChild(i - 1)
        tab.transform:Find("Name"):GetComponent(Text).text = self.slotinfo[i][1]
        tab.img = tab.transform:Find("Image"):GetComponent(Image)
        tab.img.sprite = self.assetWrapper:GetSprite(AssetConfig.dragon_chess_textures,self.slotinfo[i][2])
        tab.transform:GetComponent(Button).onClick:AddListener(function() self:ClickSkillSlot(i) end)
        self.slotList[i] = tab
    end

    self.showBtn = t:Find("Main/Show"):GetComponent(Button)
    self.showBtn.onClick:AddListener(function() self:ShowMainUIIcon() end)
    self.mainuiIconArea = t:Find("Main/CanvasArea/MainUIButtonGrid").gameObject

    self.buttonGrid = t:Find("Main/CanvasArea/MainUIButtonGrid/Scroll/Container")
    self.buttonCloner = t:Find("Main/CanvasArea/MainUIButtonGrid/Scroll/Container/Button").gameObject
    self.buttonCloner:SetActive(false)

    self.mainuiIconRightDown = t:Find("Main/InfoArea/MainUIButtonLayout")
    self.mainuiIconLayout = LuaBoxLayout.New(t:Find("Main/InfoArea/MainUIButtonLayout/Container"), {axis = BoxLayoutAxis.X, cspacing = 0, border = 0})
    self.mainuiIconRightDown.gameObject:SetActive(false)


    local chatBtn = main:Find("BottomButton/ChatButton"):GetComponent(Button)
    chatBtn.onClick:AddListener(function() ChatManager.Instance.model:ShowChatWindow() end)

    local worldBtn = main:Find("BottomButton/WorldVoiceButton"):GetComponent(CustomEnterExsitButton)

    worldBtn.onDown:AddListener(function() ChatManager.Instance.model:DownVoice(MsgEumn.ChatChannel.World) end)
    worldBtn.onUp:AddListener(function() ChatManager.Instance.model:UpVoice() end)
    worldBtn.onEnter:AddListener(function() ChatManager.Instance.model:EnterVoice() end)
    worldBtn.onExsit:AddListener(function() ChatManager.Instance.model:ExitVoice() end)

    local tipsBtn = main:Find("BottomButton/TipsButton"):GetComponent(Button)
    tipsBtn.onClick:AddListener(function() self.model:OpenDescPanel() end)


    self.effectArea = main:Find("CanvasArea/EffectArea")
    self.effectArea.anchoredPosition = Vector2(0,178)


    self.speakArea = main:Find("CanvasArea/SpeakArea")
    self.speakArea.anchoredPosition = Vector3(-188,43.4,-500)

    self.speakContainer = self.speakArea:Find("Scroll/Container")
    self.speakCloner = self.speakContainer:Find("Item").gameObject
    self.speakCloner.gameObject:SetActive(false)

    local layout = LuaBoxLayout.New(self.speakContainer, {axis = BoxLayoutAxis.Y, cspacing = 0, border = 10})
    for i = 1, 6 do
        local tab = {}
        tab.gameObject = GameObject.Instantiate(self.speakCloner)
        tab.gameObject.name = tostring(i)
        tab.transform = tab.gameObject.transform
        tab.speakTxt = MsgItemExt.New(tab.transform:Find("Text"):GetComponent(Text), 100)
        tab.speakTxt:SetData(DataCampBlackWhiteChess.data_get_msg[i].message)
        tab.speakBtn = tab.transform:GetComponent(Button)
        tab.speakBtn.onClick:AddListener(function()
                self.speakArea.gameObject:SetActive(false)
                DragonPhoenixChessManager.Instance:Send20903(i)
                self.speakFlag = true
            end)
        layout:AddCell(tab.gameObject)
        self.speakList[i] = tab
    end
    layout:DeleteMe()

    self.roundArea = main:Find("CanvasArea/RoundArea")

    self.honorArea = main:Find("CanvasArea/HonorArea")
    self.honorheadImg = self.honorArea:Find("Head"):GetComponent(Image)
    self.honorImg = self.honorArea:Find("Honor"):GetComponent(Image)
end

function DragonPhoenixChessMain:OnInitCompleted()
    self.assetWrapper:ClearMainAsset()
    self.OnOpenEvent:Fire()
end

function DragonPhoenixChessMain:OnOpen()
    self:RemoveListeners()
    DragonPhoenixChessManager.Instance.onChessEvent:AddListener(self.updateListener)
    DragonPhoenixChessManager.Instance.onSpeakEvent:AddListener(self.updateSpeakListener)
    DragonPhoenixChessManager.Instance.onOverSpeakEvent:AddListener(self.updateOverSpeakListener)

    self.timerId = LuaTimer.Add(0, 200, function() self:OnTime() self.model:ShowMainView(false) end)

    self:Update()
end

function DragonPhoenixChessMain:OnHide()
    self:RemoveListeners()

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end

    if self.timerId1 ~= nil then
        LuaTimer.Delete(self.timerId1)
        self.timerId1 = nil
    end

    if self.timerId2 ~= nil then
        LuaTimer.Delete(self.timerId2)
        self.timerId2 = nil
    end

    if self.timerId3 ~= nil then
        LuaTimer.Delete(self.timerId3)
        self.timerId3 = nil
    end

    if self.timerId4 ~= nil then
        LuaTimer.Delete(self.timerId4)
        self.timerId4 = nil
    end

    if self.tween_alphaId ~= nil then 
        Tween.Instance:Cancel(self.tween_alphaId )
        self.tween_alphaId  = nil 
    end

    self.model:ShowMainView(true)

end

function DragonPhoenixChessMain:RemoveListeners()
    DragonPhoenixChessManager.Instance.onChessEvent:RemoveListener(self.updateListener)
    DragonPhoenixChessManager.Instance.onSpeakEvent:RemoveListener(self.updateSpeakListener)
    DragonPhoenixChessManager.Instance.onOverSpeakEvent:RemoveListener(self.updateOverSpeakListener)
end


function DragonPhoenixChessMain:ReloadMainUIIcon()
    for i,v in ipairs(self.systemBtnList) do
        local btn = self.mainUIButtonList[i]
        if btn == nil then
            btn = {}
            btn.gameObject = GameObject.Instantiate(self.buttonCloner)
            btn.transform = btn.gameObject.transform
            btn.transform:SetParent(self.buttonGrid)
            btn.transform.localScale = Vector3.one
            if DataSystem.data_icon[v.id] ~= nil then
                btn.gameObject:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.mainui_textures, v.res)
            elseif DataSystem.data_daily_icon[v.id] ~= nil then
                btn.gameObject:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.mainui_textures, DataSystem.data_daily_icon[v.id].res_name)
            end
            local func = v.clickFunc
            btn.gameObject:GetComponent(Button).onClick:AddListener(function() self:ShowMainUIIcon() func() end)
            self.mainUIButtonList[i] = btn
        end
        if DataSystem.data_icon[v.id] ~= nil then
            btn.gameObject:SetActive(RoleManager.Instance.RoleData.lev >= DataSystem.data_icon[v.id].lev and v.showFunc())
        else
            btn.gameObject:SetActive(v.showFunc())
        end
    end
end

function DragonPhoenixChessMain:ShowMainUIIcon()
    self.mainuiIconArea:SetActive(self.isShowMainUIIcon)

    if self.isShowMainUIIcon then
        self.showBtn.transform.anchoredPosition = Vector2(20,-130) + self.originShowDelta
        self.showBtn.transform.localScale = Vector3(-1, 1, 1)
        self:ReloadMainUIIcon()
    else
        self.showBtn.transform.anchoredPosition = Vector2(20,-130)
        self.showBtn.transform.localScale = Vector3.one
    end
    self.isShowMainUIIcon = not self.isShowMainUIIcon
end


function DragonPhoenixChessMain:ClickSkillSlot(skilltype)
    if skilltype == 1 then
        if self.model.round < 26 then
            NoticeManager.Instance:FloatTipsByString(TI18N("26回合后才可求和哟~{face_1, 30}"))
        else
            self.confirmData = self.confirmData or NoticeConfirmData.New()
            self.confirmData.type = ConfirmData.Style.Normal
            self.confirmData.content = TI18N("胜利只属于那些<color='#ffff00'>永不言弃</color>的玩家！求和后将获得<color='#00ff00'>少量</color>奖励，是否确认进行<color='#ffff00'>求和</color>？")
            self.confirmData.sureCallback = function() DragonPhoenixChessManager.Instance:Send20904() end
            self.confirmData.sureLabel = TI18N("确认求和")
            self.confirmData.cancelLabel = TI18N("我再想想")
            self.confirmData.cancelSecond = -1
            self.confirmData.cancelCallback = nil
            NoticeManager.Instance:ConfirmTips(self.confirmData)
        end
    elseif skilltype == 2 then
        if self.model.round < 16 then
            NoticeManager.Instance:FloatTipsByString(TI18N("16回合后才可认输哟~{face_1, 30}"))
        else
            self.confirmData = self.confirmData or NoticeConfirmData.New()
            self.confirmData.type = ConfirmData.Style.Normal
            self.confirmData.content = TI18N("胜利只属于那些<color='#ffff00'>永不言弃</color>的玩家！认输后将获得<color='#00ff00'>较少</color>奖励，是否确认<color='#ffff00'>认输</color>？")
            self.confirmData.sureLabel = TI18N("确认认输")
            self.confirmData.sureCallback = function()  DragonPhoenixChessManager.Instance:Send20906() end
            self.confirmData.cancelCallback = nil
            self.confirmData.cancelLabel = TI18N("我再想想")
            NoticeManager.Instance:ConfirmTips(self.confirmData)
        end
    elseif skilltype == 3 then
        -- DragonPhoenixChessManager.Instance:Send20903()
        -- print("发言")
        self.speakArea.gameObject:SetActive(self.speakFlag)
        self.speakFlag = not self.speakFlag
    end
end

function DragonPhoenixChessMain:OnClickCell(x,y)
    if self.model.who_turn ~= self.model.chessType then
        NoticeManager.Instance:FloatTipsByString(TI18N("当前是<color='#ff0000'>对方</color>回合！请稍等后再进行操作{face_1 ,22}"))
    else
        -- print(string.format("%s,%s,%s",x,y,self.chessTab[x][y].color))

        --可下棋区域
        if self.model.chessInfoTab[x][y] == 3 then
            self.x = x
            self.y = y
            DragonPhoenixChessManager.Instance:Send20907(self.x, self.y)
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("不能下在这个位置哦~"))
        end
    end
end


function DragonPhoenixChessMain:Update()
    -- BaseUtils.dump(self.model.chessType,"--当前玩家所拿棋类型")
    -- BaseUtils.dump(self.model.who_turn,"当前谁下")
    -- BaseUtils.dump(self.model.next_time_step,"这个回合结束时间")
    -- BaseUtils.dump(self.model.round,"回合数")
    -- BaseUtils.dump(self.model.playing,"是否为自己回合")
    -- BaseUtils.dump(self.model.myInfo,"MyInfo")
    -- BaseUtils.dump(self.model.enemyInfo,"EnemyInfo")

    if self.model.enemyInfo == nil or self.model.myInfo == nil or self.model.myInfo.sex == nil  then return end


    --棋子权重
    self:ChessChangeListWeight()
    --设置角色信息
    self:SetRoleInfo()
    -- --棋盘翻转
    self:ReloadChessBoard()

    --翻转后
    local callback = function() 
            --下子所获荣耀
            self:PlayHonor()
            --无子可下标语 Or 展示棋盘可下位置
            local fun = function() 
                    self.tipsObj.gameObject:SetActive(self.model.no_free) 
                    self:ShowChessBoardClickAble()
                end
            --"我方回合"标语
            self:FadeOutAlpha(self.roundArea.gameObject, 1, fun) 
        end

    if self.timerId4 ~= nil then
        LuaTimer.Delete(self.timerId4)
        self.timerId4 = nil
    end
    self.timerId4 = LuaTimer.Add(self.model.max_weight*60 + 500, function() callback() end) 


    --"棋方"标语提示
    if self.model.round == 1 then
        if self.model.chessType == 1 then
            self.tipsObj1:SetActive(true)
            if self.timerId1 ~= nil then
                LuaTimer.Delete(self.timerId1)
                self.timerId1 = nil
            end
            self.timerId1 = LuaTimer.Add(2000, function() self.tipsObj1:SetActive(false) end)
        else
            self.tipsObj2:SetActive(true)
            if self.timerId2 ~= nil then
                LuaTimer.Delete(self.timerId2)
                self.timerId2 = nil
            end
            self.timerId2 = LuaTimer.Add(2000, function()  self.tipsObj2:SetActive(false) end)
        end
    end

    --“哪方回合"特效提示
    self:ShowTurnEffect(self.model.playing)

    

    --时间轴位置
    if self.model.chessType == self.model.who_turn then
        self.countDownContainer.transform.anchoredPosition = Vector2(355*self.scaleX,230)
    else
        self.countDownContainer.transform.anchoredPosition = Vector2(-355*self.scaleX,230)
    end

    --时间轴图片
    if self.model.playing then
        self.countDownImg.sprite = self.assetWrapper:GetSprite(AssetConfig.dragon_chess_textures,self.chessTopIcon[self.model.myInfo.camp])
    else
        self.countDownImg.sprite = self.assetWrapper:GetSprite(AssetConfig.dragon_chess_textures,self.chessTopIcon[self.model.enemyInfo.camp])
    end

end



function DragonPhoenixChessMain:SetRoleInfo()
    self.own_role:SetData(self.model.myInfo)
    self.other_role:SetData(self.model.enemyInfo)

    self.own_role:SetStatus(self.model.who_turn == self.model.chessType)
    self.other_role:SetStatus(self.model.who_turn ~= self.model.chessType)

    self.own_role:SetRotation(self.model.chessType)
    self.other_role:SetRotation(self.model.chessType)

    --下一回合是否为自己回合
    if not self.model.playing then
        self.own_role:DoAnimation()
    else
        self.other_role:DoAnimation()
    end
end


function DragonPhoenixChessMain:ReloadChessBoard()
    for x,col in ipairs(self.model.chessInfoTab) do
        for y,st in ipairs(col) do
            --将上个回合可下位置的特效隐藏
            if self.chessTab[x][y].effect3 ~= nil or self.chessTab[x][y].effect4 ~= nil then
                self.chessTab[x][y]:ShowAbled(false,self.chessTab[x][y].color)
            end
            if st == 0 then
                self.chessTab[x][y]:SetAbled(false)
            else
                if st == 1 or st == 2  then
                    if self:JugeChessChange(x,y) then
                        -- if self.x == x and self.y == y then
                        if self.model.chess_change_list[1].row ==  x and self.model.chess_change_list[1].col == y then
                            self.chessTab[x][y]:SetAbled(false)
                            self.chessTab[x][y]:ShowEffect(999)
                            self.chessTab[x][y]:SetAbled(true)
                            self.chessTab[x][y]:SetIconSprite(st)
                        else
                            --棋子翻转动画
                            self.chessTab[x][y]:ShowEffectTick(st,callback)
                        end
                    else
                        self.chessTab[x][y]:SetAbled(true)
                        self.chessTab[x][y]:SetIconSprite(st)
                    end
                elseif st == 3 then
                    -- self.chessTab[x][y]:SetAbled(false)
                    -- if self.model.playing then
                    --     self.chessTab[x][y]:ShowAbled(true,self.chessTab[x][y].color)
                    -- else
                    --     self.chessTab[x][y]:ShowAbled(false,self.chessTab[x][y].color)
                    -- end
                    -- self.chessTab[x][y]:SetIconSprite(st)
                end
            end
        end
    end
end


function DragonPhoenixChessMain:JugeChessChange(x,y)
    local flag = false
    for _,v in ipairs(self.model.chess_change_list) do
        if v.row == x and v.col == y then
            flag =  true
        end
    end
    return flag
end


function DragonPhoenixChessMain:ChessChangeListWeight()
    self.model.max_weight = 0
    if self.model.chess_change_list ~= nil and self.model.chess_change_list[1] ~= nil then
        local row = self.model.chess_change_list[1].row
        local col = self.model.chess_change_list[1].col

        for _,v in ipairs(self.model.chess_change_list) do
            local t_row = math.abs(v.row - row)
            local t_col = math.abs(v.col - col)

            self.chessTab[v.row][v.col].weight = t_row ~= 0 and t_row or t_col

            --棋子最大权重
            if self.chessTab[v.row][v.col].weight > self.model.max_weight then
                self.model.max_weight = self.chessTab[v.row][v.col].weight
            end
        end
    end
end


function DragonPhoenixChessMain:OnTime()
    local dis = (self.model.next_time_step or 0) - BaseUtils.BASE_TIME
    if dis > 0 then
        if dis > 20 then
            self.countDownContainer.gameObject:SetActive(false)
        else
            self.countDownContainer.gameObject:SetActive(true)
            self.countDownTime.text = string.format("%ss",dis)
        end
    else
        self.countDownTime.text = string.format("%ss",0)
    end
end


function DragonPhoenixChessMain:ShowTurnEffect(flag)
    if self.effect1 == nil then
        self.effect1 = BaseUtils.ShowEffect(20490, self.effectArea, Vector3.one*0.75, Vector3(0, 0, -400))
    end
    self.effect1:SetActive(flag)

    if self.effect2 == nil then
        self.effect2 = BaseUtils.ShowEffect(20489, self.effectArea, Vector3.one*0.75, Vector3(0, 0, -400))
    end
    self.effect2:SetActive(not flag)
end

function DragonPhoenixChessMain:SpeakChess(data)
    -- BaseUtils.dump(data,"说话")
    if data.who_say == self.model.chessType then
        self.own_role:SetMsg(data.msg)
    else
        self.other_role:SetMsg(data.msg)
    end
end


function DragonPhoenixChessMain:ShowChessBoardClickAble()
    for x,col in ipairs(self.model.chessInfoTab) do
        for y,st in ipairs(col) do
            if st == 3 then
                self.chessTab[x][y]:SetAbled(false)
                if self.model.playing then
                    self.chessTab[x][y]:ShowAbled(true,self.chessTab[x][y].color)
                else
                    self.chessTab[x][y]:ShowAbled(false,self.chessTab[x][y].color)
                end
                self.chessTab[x][y]:SetIconSprite(st)
            end
        end
    end
end


function DragonPhoenixChessMain:FadeOutAlpha(gameobject, time, callback)
    if BaseUtils.isnull(gameobject) then return end
    --我方回合且不为第一回合
    local mark = self.model.playing and self.model.round ~= 1

    gameobject:SetActive(mark)

    if mark then
        gameobject.transform:GetComponent(CanvasGroup).alpha = 1
        if self.tween_alphaId ~= nil then 
            Tween.Instance:Cancel(self.tween_alphaId )
            self.tween_alphaId  = nil 
        end
        self.tween_alphaId = Tween.Instance:ValueChange(1, 0, time, callback
                                , LeanTweenType.easeInQuint
                                , function(value)
                                    gameobject.transform:GetComponent(CanvasGroup).alpha = value
                                end
                            ).id
    else
        callback()
    end
end

function DragonPhoenixChessMain:PlayHonor()
    if not self.model.playing then
        if self.model.achievehonor ~= 0 then
            self.honorheadImg.sprite = self.assetWrapper:GetSprite(AssetConfig.dragon_chess_textures,self.chessTopIcon[self.model.myInfo.camp])
            self.honorheadImg:SetNativeSize()
            self.honorImg.sprite = self.assetWrapper:GetSprite(AssetConfig.dragon_chess_textures,string.format("i18n_honor%s",self.model.achievehonor))
            self.honorImg:SetNativeSize()

            self.honorArea.gameObject:SetActive(true)
            if self.effect3 == nil then
                self.effect3 = BaseUtils.ShowEffect(20495, self.honorArea, Vector3.one, Vector3(0, 0, -400))
            end
            if self.timerId3 ~= nil then LuaTimer.Delete(self.timerId3) self.timerId3 = nil end
            self.timerId3 = LuaTimer.Add(1000, function() self.honorArea.gameObject:SetActive(false) end) 
        else
            self.honorArea.gameObject:SetActive(false)
        end
    else
        self.honorArea.gameObject:SetActive(false)
    end
end


function DragonPhoenixChessMain:OverSpeaking(data)
    if data.result == 1 then 
        self.own_role:SetMsg(TI18N("我赢了{face_1,38}"),true)
        self.other_role:SetMsg(TI18N("我输了{face_1,8}"),true)
    elseif data.result == 2 then
        self.own_role:SetMsg(TI18N("我输了{face_1,8}"),true)
        self.other_role:SetMsg(TI18N("我赢了{face_1,38}"),true)
    end
end

