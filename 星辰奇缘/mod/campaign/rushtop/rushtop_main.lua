RushTopMain = RushTopMain or BaseClass(BaseWindow)

function RushTopMain:__init(model)
    self.model = model
    self.name = "RushTopMain"
    self.windowId = WindowConfig.WinID.rushtop_main
    self.Mgr = RushTopManager.Instance

    self.cacheMode = CacheMode.Visible

    self.resList = {
        {file = AssetConfig.rushtopmain, type = AssetType.Main}
        ,{file = AssetConfig.rushtop_texture, type = AssetType.Dep}
        ,{file = AssetConfig.rushtopbg1, type = AssetType.Main}
        ,{file = AssetConfig.rushtopbg2, type = AssetType.Main}
        ,{file = AssetConfig.rushtopdecoration1, type = AssetType.Main}
        ,{file = AssetConfig.rushtopdecoration2, type = AssetType.Main}
        ,{file = AssetConfig.rushtopdecoration3, type = AssetType.Main}
        ,{file = AssetConfig.summer_loss_child_bigtextrue, type = AssetType.Main}
        ,{file = AssetConfig.cuplight, type = AssetType.Main}
    }

    self.setall = function() self:SetAll() end

    self.getquestion = function()
        self.curselect = self.curselect or 1
        self.answer[self.curselect].select:SetActive(false)
        self.curselect = nil
        self:SetQandA()
    end

    self.getanswer = function()
        if self.model.curanswer ~= nil and BaseUtils.BASE_TIME < self.model.curquestion.stop_time + self.model.rules.notice_time + 5 then
            self:ShowAnswer()
        else
            self:ShowResult()
        end
    end

    self.getself = function (flag)
        self:SetWait(flag)
    end

    self.onrelive = function()
        self:Relive()
    end

    self.refreshbtn = function ()
        self:IsShowButton()
    end

    self.refreshgold = function ()
        self:SetGold()
        self:SetCard()
    end

    self.refreshcard = function ()
        self:SetCard()
    end

    self.refreshleft = function ()
        self:SetLeft()
    end

    self.setdamaku = function ()
        self:SetDamaku()
    end


    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function RushTopMain:__delete()
    self.OnHideEvent:Fire()

    if self.iconloader ~= nil then
        self.iconloader:DeleteMe()
        self.iconloader = nil
    end

    if self.righteffect ~= nil then
        self.righteffect:DeleteMe()
        self.righteffect = nil
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
    if self.effect4 ~= nil then
        self.effect4:DeleteMe()
        self.effect4 = nil
    end
    if self.effect5 ~= nil then
        self.effect5:DeleteMe()
        self.effect5 = nil
    end
    if self.effect6 ~= nil then
        self.effect6:DeleteMe()
        self.effect6 = nil
    end
    if self.effect7 ~= nil then
        self.effect7:DeleteMe()
        self.effect7 = nil
    end



    self:AssetClearAll()
end

function RushTopMain:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.rushtopmain))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform
    self.panel = self.transform:Find("Panel").gameObject
    self.main = self.transform:Find("Main")
    local main = self.transform:Find("Main")
    main:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function() self:CloseMyWindow() self.Mgr.watch = false end)

    self.sendBtn = main:Find("SendBtn").gameObject
    self.setBtn = main:Find("SetBtn").gameObject

    main:Find("SendBtn"):GetComponent(Button).onClick:AddListener(function() self:OpenDamaku() end)
    main:Find("SetBtn"):GetComponent(Button).onClick:AddListener(function() self:ShowCloseDamaku() end)

    self.damakubtn = main:Find("SetBtn"):GetComponent(Image)
    self.damakuimg = main:Find("SetBtn/Image").gameObject

    main:Find("zhuangshi/1"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rushtopdecoration1, "rushtopdecoration1")
    main:Find("zhuangshi/2"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rushtopdecoration2, "rushtopdecoration2")
    main:Find("zhuangshi/3"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rushtopdecoration3, "rushtopdecoration3")
    main:Find("Bg/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rushtopbg2, "rushtopbg2")
    main:Find("Process"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rushtopbg1, "rushtopbg1")
    main:Find("Right/gril"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.summer_loss_child_bigtextrue, "guidesprite")
    main:Find("Wrong/gril"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.summer_loss_child_bigtextrue, "guidesprite")


    main:Find("Cup"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.cuplight,"cuplight")


    self.qanda = main:Find("QandA")
    self.qtext = self.qanda:Find("Question/QuestionText"):GetComponent(Text)
    self.qtext.fontSize = 18
    local answer = self.qanda:Find("Answer")
    local temp = {answer:Find("A"),answer:Find("B"),answer:Find("C")}
    self.answer = {}
    for i=1,3 do
        self.answer[i] = {}
        self.answer[i].btn = temp[i]:GetComponent(Button)
        self.answer[i].select = temp[i]:Find("Select").gameObject
        self.answer[i].text = temp[i]:Find("answerText"):GetComponent(Text)
        self.answer[i].count = temp[i]:Find("count"):GetComponent(Text)

        self.answer[i].right = temp[i]:Find("right").gameObject
        self.answer[i].rightimg = temp[i]:Find("right"):GetComponent(Image)
        self.answer[i].righttick = temp[i]:Find("right/Image").gameObject
        self.answer[i].righttop = temp[i]:Find("right/top").gameObject
        self.answer[i].rightpro= temp[i]:Find("right/process").gameObject

        self.answer[i].wrong = temp[i]:Find("wrong").gameObject
        self.answer[i].wrongimg = temp[i]:Find("wrong"):GetComponent(Image)
        self.answer[i].wrongfork = temp[i]:Find("wrong/Image").gameObject
        self.answer[i].wrongtop = temp[i]:Find("wrong/top").gameObject
        self.answer[i].wrongpro= temp[i]:Find("wrong/process").gameObject

        self.answer[i].btn.onClick:AddListener(function ()
            if self.model.lost == true then
                NoticeManager.Instance:FloatTipsByString(TI18N("围观中不能作答，发送弹幕提示参赛者吧{face_1,15}"))
                return
            end
            if self.curselect == nil then
                self.answer[i].select:SetActive(true)
                self.curselect = i
                self.Mgr:Send20426(self.model.curquestion.question_index,self.curselect)
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("作答后不能更改答案哟{face_1,2}"))
            end
        end)
    end

    self.statusTag = main:Find("Status"):GetComponent(Image)

    if self.effect5 == nil then
        self.effect5 = BaseUtils.ShowEffect(20449, self.statusTag.transform, Vector3(0.8,0.8,1), Vector3(0,2.5,-1000))
    end
    self.effect5:SetActive(true)


    self.lefttime = main:Find("Process/lefttime"):GetComponent(Text)
    self.lefttime.gameObject:GetComponent(RectTransform).sizeDelta = Vector2(50,50)
    self.lefttime.gameObject:GetComponent(RectTransform).localPosition = Vector2(0,0)
    self.lefttime.fontSize = 36
    self.process = main:Find("Process/process"):GetComponent(Image)
    self.probg = main:Find("Process/processbg")

    self.pro = main:Find("Process").gameObject

    self.cup = main:Find("Cup").gameObject

    self.cuprot = GameObject.Instantiate(self.cup)
    self.cuprot:GetComponent(Image).enabled = false
    self.cuprot.transform:Find("Image").gameObject:SetActive(false)
    self.cuprot.transform:SetParent(main)
    self.cuprot:GetComponent(RectTransform).localPosition = Vector2(0,125)
    self.cuprot:GetComponent(RectTransform).localScale = Vector3(1,1,1)

    self.cup.transform:SetParent(self.cuprot.transform)
    self.cup:GetComponent(RectTransform).localPosition = Vector2(-9,8)
    self.cup:GetComponent(RectTransform).localScale = Vector3(1,1,1)

    self.cupimg = self.cuprot.transform:Find("Cup/Image").gameObject
    self.cupimg.transform:SetParent(main)



    self.cupbg = self.cuprot:GetComponent(RectTransform)

    self.right = main:Find("Right")

    self.rightDesc = self.right:Find("Desc/Text"):GetComponent(Text)
    self.rightBtn = self.right:Find("Button"):GetComponent(Button)
    self.rightBtnTxt = self.right:Find("Button/Text"):GetComponent(Text)
    self.rightTitle = self.right:Find("Title"):GetComponent(Text)

    self.rightTitle2 = GameObject.Instantiate(self.rightTitle.gameObject):GetComponent(Text)
    self.rightTitle2.transform:SetParent(self.right)
    self.rightTitle2.gameObject:GetComponent(RectTransform).localPosition = Vector2(0,70)
    self.rightTitle2.gameObject:GetComponent(RectTransform).localScale = Vector3(1,1,1)
    self.rightTitle2.gameObject:SetActive(false)

    self.rightBtn.onClick:AddListener(function() NoticeManager.Instance:FloatTipsByString(TI18N("奖励已通过邮件发送")) end)

    self.wrong = main:Find("Wrong")
    self.wrongTitle = self.wrong:Find("Title"):GetComponent(Text)
    self.wrongDesc = self.wrong:Find("Desc/Text"):GetComponent(Text)
    self.wrongBtn1 = self.wrong:Find("Button1"):GetComponent(Button)
    self.wrongBtn2 = self.wrong:Find("Button2"):GetComponent(Button)
    self.wrongBtn3 = self.wrong:Find("Button3"):GetComponent(Button)
    self.wrongBtn4 = self.wrong:Find("Button4"):GetComponent(Button)
    self.wrongcard = self.wrong:Find("card").gameObject

    self.wrongBtn1.onClick:AddListener(function() self.Mgr:Send20428() end)

    self.wrongBtn2.onClick:AddListener(function()
        local base_data = DataItem.data_get[self.model.rules.revive[1].r_base_id]
        local info = { itemData = base_data, gameObject = self.wrongBtn2.gameObject }
        TipsManager.Instance:ShowItem(info)
    end)

    self.wrongBtn3.onClick:AddListener(function() self.Mgr:Send20424(2) WindowManager.Instance:CloseWindow(self) end)

    self.wrongBtn4.onClick:AddListener(function() self.Mgr.watch = false self:OnOpen() end)

    self.top = self.transform:Find("Top").gameObject
    local top = self.transform:Find("Top")
    top:GetComponent(RectTransform).anchoredPosition = Vector2(0,-33)

    -- top:GetComponent(RectTransform).sizeDelta = Vector2(500,49)

    self.left = top:Find("Left/left"):GetComponent(Text)
    self.left.text = TI18N("刷新中")
    self.pool = top:Find("Pool/pool"):GetComponent(Text)
    self.card = top:Find("Relive/relive"):GetComponent(Text)
    self.leftobj = top:Find("Left").gameObject
    self.pooltrans = top:Find("Pool"):GetComponent(RectTransform)
    self.cardtrans =  top:Find("Relive"):GetComponent(RectTransform)

    self.poolicon = GameObject.Instantiate(top:Find("Pool/Image")):GetComponent(RectTransform)
    self.poolicon.transform:SetParent(top:Find("Pool"))
    self.poolicon.localScale = Vector3(0.8,0.8,1)
    self.poolicon.sizeDelta = Vector2(28,28)

    top:Find("Pool"):GetComponent(Button).onClick:AddListener(function ()
        self.Mgr.model:OpenDescPanel()
    end)

    top:Find("Relive"):GetComponent(Button).onClick:AddListener(function ()
        if self.model.rules ~= nil then
            local base_data = DataItem.data_get[self.model.rules.revive[1].r_base_id]
            local info = { itemData = base_data, gameObject = top:Find("Relive").gameObject }
            TipsManager.Instance:ShowItem(info)
        end
    end)

    self.qtext.text = ""
    self.answer[1].text.text = ""
    self.answer[2].text.text = ""
    self.answer[3].text.text = ""



end

function RushTopMain:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function RushTopMain:OnOpen()
    self:AddListeners()
    if self.effect6 ~= nil then
        self.effect6:SetActive(false)
    end
    if self.openArgs == nil then
        self:SetAll()
    elseif self.openArgs.watch ~= nil then
        self:Watch()
    elseif self.openArgs.frist ~= nil then
        self:Frist()
    end
    self:IsShowButton()
    self:SetGold()
    self:SetCard()
    self:SetLeft()
    self:SetDamaku()
    self:RotationBg()
end

function RushTopMain:OnHide()
    self:RemoveListeners()

    if self.shakeTimer ~= nil then
        LuaTimer.Delete(self.shakeTimer)
        self.shakeTimer = nil
    end
    if self.rotationTweenId ~= nil then
       Tween.Instance:Cancel(self.rotationTweenId)
       self.rotationTweenId = nil
    end

    if self.tweenIdX ~= nil then
        Tween.Instance:Cancel(self.tweenIdX)
        self.tweenIdX = nil
    end

    if self.tweenIdY ~= nil then
        Tween.Instance:Cancel(self.tweenIdY)
        self.tweenIdY = nil
    end

    if self.tweenScalerId ~= nil then
        Tween.Instance:Cancel(self.tweenScalerId)
        self.tweenScalerId = nil
    end

    if self.delayTimerId ~= nil then
        LuaTimer.Delete(self.delayTimerId)
        self.delayTimerId = nil
    end
    self.main.transform.localScale = Vector3(1,1,1)
    self.main.transform.anchoredPosition = Vector3(0,-29,0)
    self.sendBtn:SetActive(true)
    self.setBtn:SetActive(true)
    self.top:SetActive(true)

    self:DeleteTimer()
end

function RushTopMain:AddListeners()
    self:RemoveListeners()
    self.Mgr.on20425:AddListener(self.getquestion)
    self.Mgr.on20427:AddListener(self.getanswer)
    self.Mgr.on20428:AddListener(self.onrelive)
    self.Mgr.on20432:AddListener(self.getself)

    self.Mgr.on20421:AddListener(self.refreshgold)
    self.Mgr.on20422:AddListener(self.refreshbtn)
    self.Mgr.on20425:AddListener(self.refreshbtn)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.refreshcard)
    self.Mgr.on20425:AddListener(self.refreshleft)
    self.Mgr.on20427:AddListener(self.refreshleft)
    self.Mgr.on20433:AddListener(self.refreshleft)
    self.Mgr.on20431:AddListener(self.setdamaku)

end

function RushTopMain:RemoveListeners()
    self.Mgr.on20425:RemoveListener(self.getquestion)
    self.Mgr.on20427:RemoveListener(self.getanswer)
    self.Mgr.on20428:RemoveListener(self.onrelive)
    self.Mgr.on20432:RemoveListener(self.getself)

    self.Mgr.on20421:RemoveListener(self.refreshgold)
    self.Mgr.on20422:RemoveListener(self.refreshbtn)
    self.Mgr.on20425:RemoveListener(self.refreshbtn)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.refreshcard)
    self.Mgr.on20425:RemoveListener(self.refreshleft)
    self.Mgr.on20427:RemoveListener(self.refreshleft)
    self.Mgr.on20433:RemoveListener(self.refreshleft)
    self.Mgr.on20431:RemoveListener(self.setdamaku)

end

function RushTopMain:ShowCloseDamaku()
    -- self.model:OpenDamakuSetting()
    RushTopManager.Instance:Send20431(2, 1 - self.model.playerInfo.ply_barrage)

end

function RushTopMain:OpenDamaku()
    self.damakuCallback = self.damakuCallback or function(msg)
        if self.model.playerInfo == nil then
            return
        end
        if self.model.playerInfo.barrage_time < BaseUtils.BASE_TIME then
            self.Mgr:Send20430(msg)
            ChatManager.Instance:Send(10400, {channel = MsgEumn.ChatChannel.Scene, msg = msg})
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("您刚刚发送过弹幕，请稍后再试"))
        end
    end
    DanmakuManager.Instance.model:OpenPanel({sendCall = self.damakuCallback})
end

function RushTopMain:SetAll()
    local time = BaseUtils.BASE_TIME
    if self.model.curquestion == nil  then
        WindowManager.Instance:CloseWindow(self)
        self.Mgr.watch = false
    elseif self.model.curquestion.question_index == 0  then
        self:Frist()
    elseif time < self.model.curquestion.stop_time then
        self:SetQandA()
    elseif time < self.model.curquestion.stop_time + self.model.rules.notice_time then
        self:SetWait()
    elseif self.model.curanswer ~= nil and BaseUtils.BASE_TIME < self.model.curquestion.stop_time + self.model.rules.notice_time + 5 then
        self:ShowAnswer()
    else
        self:ShowResult()
    end
end

-- 答题阶段
function RushTopMain:SetQandA()
    self.qanda.gameObject:SetActive(true)
    self.right.gameObject:SetActive(false)
    self.wrong.gameObject:SetActive(false)
    self.pro:SetActive(true)
    self.cup:SetActive(false)
    self.cuprot:SetActive(false)
    self.cupimg:SetActive(false)


    local data = self.model.curquestion

    if self.model.playerInfo.is_lost == 0 and self.model.playerInfo.sign == 1 then
        self.statusTag.gameObject:SetActive(false)
    else
        self.model.lost = true
        self.statusTag.gameObject:SetActive(true)
    end


    self.qtext.text = "第"..data.question_index.."题."..data.question
    self.answer[1].text.text = data.option_a
    self.answer[2].text.text = data.option_b
    self.answer[3].text.text = data.option_c


    if self.curselect ~= nil then
        self.answer[self.curselect].select:SetActive(true)
    end


    for i=1,3 do
        self.answer[i].btn.enabled = true
        self.answer[i].count.gameObject:SetActive(false)
        self.answer[i].right:SetActive(false)
        self.answer[i].wrong:SetActive(false)
    end

    self:DeleteTimer()

    local left = self.model.curquestion.stop_time - BaseUtils.BASE_TIME
    local temp = self.model.curquestion.stop_time
    local showeft = false

    self.timerId = LuaTimer.Add(0 , 20 , function()
        if temp - BaseUtils.BASE_TIME >= 0 then
            self:ShowPro(true)
            self.lefttime.text = temp - BaseUtils.BASE_TIME   --math.max(math.ceil(left),0)
            self.process.fillAmount = left/10
            left = left - 0.04

            if temp - BaseUtils.BASE_TIME <= 5 and showeft == false then
                if self.effect1 == nil then
                    self.effect1 = BaseUtils.ShowEffect(20452, self.transform:Find("Main") , Vector3(1,1,1), Vector3(0,125,-1000))
                end
                self.effect1:SetActive(false)
                self.effect1:SetActive(true)
                showeft = true
            end
        else
            self:ShowPro(false)
            LuaTimer.Delete(self.timerId)
        end
    end)

end


-- 等待答案阶段
function RushTopMain:SetWait(flag)
    self.qanda.gameObject:SetActive(true)
    self.right.gameObject:SetActive(false)
    self.wrong.gameObject:SetActive(false)
    self.pro:SetActive(true)
    self.cup:SetActive(false)
    self.cuprot:SetActive(false)
    self.cupimg:SetActive(false)
    if self.effect1 ~= nil then
        self.effect1:SetActive(false)
    end
    if self.effect2 ~= nil then
        self.effect2:SetActive(false)
    end
    if self.model.lost ~= true then
        self.statusTag.gameObject:SetActive(false)
    elseif self.model.playerInfo.index == self.model.curquestion.question_index then
        self.statusTag.gameObject:SetActive(false)
    else
        self.statusTag.gameObject:SetActive(true)
    end

    if flag ~= nil and flag == true then
        if self.righteffect == nil then
            self.righteffect = BaseUtils.ShowEffect(20157, self.transform:Find("Main") , Vector3(1,1,1), Vector3(-120,0,-1000))
        end
        self.righteffect:SetActive(false)
        self.righteffect:SetActive(true)
    end


    self.lefttime.text = 0

    local data = self.model.curquestion

    self.qtext.text = string.format(TI18N("                         <color='#fff000'>%s秒后公布答题情况</color>"),self.model.rules.notice_time)                                           --"第"..data.question_index.."题."..data.question
    self.answer[1].text.text = data.option_a
    self.answer[2].text.text = data.option_b
    self.answer[3].text.text = data.option_c

    if self.effect4 ~= nil then
        self.effect4:DeleteMe()
        self.effect4 = nil
    end


    for i=1,3 do
        self.answer[i].btn.enabled = false
        self.answer[i].count.gameObject:SetActive(false)
        if self.model.rightanswer[data.question_index] == i then
            self.answer[i].wrong:SetActive(false)
            self.answer[i].right:SetActive(true)
            self.answer[i].rightimg.enabled = false
            self.answer[i].righttick:SetActive(true)
            self.answer[i].righttop:SetActive(false)
            self.answer[i].rightpro:SetActive(false)
        else
            self.answer[i].wrong:SetActive(true)
            self.answer[i].right:SetActive(false)
            self.answer[i].wrongimg.enabled = false
            self.answer[i].wrongfork:SetActive(true)
            self.answer[i].wrongtop:SetActive(false)
            self.answer[i].wrongpro:SetActive(false)
        end
    end

    self:DeleteTimer()

    local left = self.model.curquestion.stop_time + self.model.rules.notice_time - BaseUtils.BASE_TIME
    local temp = self.model.curquestion.stop_time + self.model.rules.notice_time
    local showeft = false
    local showeft2 = false

    self.timerId = LuaTimer.Add(0 ,20 , function()
        if temp - BaseUtils.BASE_TIME >= 0 then
            self.lefttime.text = temp - BaseUtils.BASE_TIME   -- math.max(math.ceil(left),0)
            self.process.fillAmount = left/10
            left = left - 0.04

            if temp - BaseUtils.BASE_TIME >= 7 and showeft == false then
                self:ShowPro(false)
                if self.effect2 == nil then
                    self.effect2 = BaseUtils.ShowEffect(20448, self.transform:Find("Main") , Vector3(0.8,0.8,1), Vector3(0,120,-1000))
                end
                self.effect2:SetActive(false)
                self.effect2:SetActive(true)
                showeft = true
            end
            if temp - BaseUtils.BASE_TIME <= 7 then
                if self.effect2 ~= nil then
                    self.effect2:SetActive(false)
                end
                self:ShowPro(true)
            end
            if temp - BaseUtils.BASE_TIME <= 0 and showeft2 == false then
                if self.effect6 == nil then
                    self.effect6 = BaseUtils.ShowEffect(20453, self.pro.transform , Vector3(1,1,1), Vector3(0,0,-1000))
                end
                self.effect6:SetActive(false)
                self.effect6:SetActive(true)
                showeft2 = true
            end

        else
            -- self:ShowPro(false)

            LuaTimer.Delete(self.timerId)
        end
    end)

end

-- 展示答案
function RushTopMain:ShowAnswer()
    if self.model.lost ~= true then
        self.statusTag.gameObject:SetActive(false)
    elseif self.model.playerInfo.index == self.model.curquestion.question_index then
        self.statusTag.gameObject:SetActive(false)
    else
        self.statusTag.gameObject:SetActive(true)
    end
    if self.effect1 ~= nil then
        self.effect1:SetActive(false)
    end
    if self.effect2 ~= nil then
        self.effect2:SetActive(false)
    end

    local data = self.model.curquestion

    self.qtext.text = "第"..data.question_index.."题."..data.question
    self.answer[1].text.text = data.option_a
    self.answer[2].text.text = data.option_b
    self.answer[3].text.text = data.option_c


    self.qanda.gameObject:SetActive(true)
    self.right.gameObject:SetActive(false)
    self.wrong.gameObject:SetActive(false)
    self.pro:SetActive(true)
    self.cup:SetActive(false)
    self.cuprot:SetActive(false)
    self.cupimg:SetActive(false)

    local sum = self.model.curanswer.last_num
    if sum == 0 then
        sum = 1
    end

    local count = {}
    count[1] = self.model.curanswer.option_a
    count[2] = self.model.curanswer.option_b
    count[3] = self.model.curanswer.option_c

    for i=1,3 do
        self.answer[i].btn.enabled = false
        self.answer[i].count.gameObject:SetActive(true)

        self.answer[i].count.text = count[i]
        if self.model.curanswer.answer == i then
            self.model.leftplayer = count[i]
            self.model.lostplayer = sum - count[i]
            self.rate = math.ceil(count[i]/sum*100)
            self.answer[i].wrong:SetActive(false)
            self.answer[i].right:SetActive(true)
            self.answer[i].rightimg.enabled = true
            self.answer[i].righttick:SetActive(false)
            self.answer[i].righttop:SetActive(true)
            self.answer[i].rightpro:SetActive(true)
        else
            self.answer[i].wrong:SetActive(true)
            self.answer[i].right:SetActive(false)
            self.answer[i].wrongimg.enabled = true
            self.answer[i].wrongfork:SetActive(false)
            self.answer[i].wrongtop:SetActive(true)
            self.answer[i].wrongpro:SetActive(true)
        end
    end

    self:DeleteTimer()
    local left = 5
    local showeft = false

    local templeft = 5
    self.tweenId = Tween.Instance:ValueChange(5, 3, 1.4, function() self.tweenId = nil end, LeanTweenType.easeOutQuad, function(value) templeft =value  end).id

    self.timerId2 = LuaTimer.Add(0 ,20 , function()
        if left > 0.02 then
            self:ShowPro(true)
            left = left - 0.04
            self.lefttime.text = math.max(math.ceil(left),0)
            self.process.fillAmount = left/5
            if templeft > 3 then
                for i=1,3 do
                    if count[i] == nil or sum == nil then
                        return
                    end
                    if self.model.curanswer.answer == i then
                        self.answer[i].righttop:GetComponent(RectTransform).localPosition = Vector2(353*count[i]/sum* (5 -templeft)/2 + 28, 0)
                        self.answer[i].rightpro:GetComponent(RectTransform).sizeDelta = Vector2(353*count[i]/sum*(5 -templeft)/2, 55)
                    else
                        self.answer[i].wrongtop:GetComponent(RectTransform).localPosition = Vector2(353*count[i]/sum*(5 -templeft)/2 + 28, 0)
                        self.answer[i].wrongpro:GetComponent(RectTransform).sizeDelta = Vector2(353*count[i]/sum*(5 -templeft)/2, 55)
                    end
                end
            end
            if left < 0.1 and showeft == false then
                if self.effect6 == nil then
                    self.effect6 = BaseUtils.ShowEffect(20453, self.pro.transform , Vector3(1,1,1), Vector3(0,0,-1000))
                end
                self.effect6:SetActive(false)
                self.effect6:SetActive(true)
                showeft = true
            end


        else
            -- self:ShowPro(false)

            LuaTimer.Delete(self.timerId2)
        end
    end)
    self.timerId5 = LuaTimer.Add(5000,function() self:ShowResult() end)

end

    -- self.wrong = main:Find("Wrong")
    -- self.wrongTitle = self.wrong:Find("Title"):GetComponent(Text)
    -- self.wrongDesc = self.wrong:Find("Desc/Text"):GetComponent(Text)
    -- self.wrongBtn1 = self.wrong:Find("Button1"):GetComponent(Button)
    -- self.wrongBtn2 = self.wrong:Find("Button2"):GetComponent(Button)


-- 展示结果，复活阶段
function RushTopMain:ShowResult()
    self.qanda.gameObject:SetActive(false)
    self.pro:SetActive(true)
    self.cup:SetActive(false)
    self.cuprot:SetActive(false)
    self.cupimg:SetActive(false)

    self.statusTag.gameObject:SetActive(false)
    if self.effect1 ~= nil then
        self.effect1:SetActive(false)
    end
    if self.effect2 ~= nil then
        self.effect2:SetActive(false)
    end

    self:DeleteTimer()
    if self.shakeTimer == nil then
        self.shakeTimer = LuaTimer.Add(1000, 2000, function()
            self.wrongBtn1.gameObject.transform.localScale = Vector3(1.2,1.1,1)
            Tween.Instance:Scale(self.wrongBtn1.gameObject, Vector3(1,1,1), 1.2, function() end, LeanTweenType.easeOutElastic)
        end)
    end


    local left = self.model.curquestion.stop_time + self.model.rules.notice_time + self.model.rules.question_time - BaseUtils.BASE_TIME
    local temp = self.model.curquestion.stop_time + self.model.rules.notice_time + self.model.rules.question_time
    local showeft = false
    self.timerId3 = LuaTimer.Add(0 , 20 , function()
        if temp - BaseUtils.BASE_TIME >= 0 then
            self:ShowPro(true)
            self.lefttime.text = temp - BaseUtils.BASE_TIME     --math.max(math.ceil(left),0)
            self.process.fillAmount = left/20
            left = left - 0.04

            if temp - BaseUtils.BASE_TIME <= 0 and showeft == false then
                if self.effect6 == nil then
                    self.effect6 = BaseUtils.ShowEffect(20453, self.pro.transform , Vector3(1,1,1), Vector3(0,0,-1000))
                end
                self.effect6:SetActive(false)
                self.effect6:SetActive(true)
                showeft = true
            end



        else
            -- self:ShowPro(false)

            LuaTimer.Delete(self.timerId3)
        end
    end)



    if self.model.playerInfo.is_lost == 0 and self.model.playerInfo.sign == 1 then      --self.model.curanswer.answer ==  self.model.curanswer.option
        self.right.gameObject:SetActive(true)
        self.wrong.gameObject:SetActive(false)
        if self.model.curquestion.question_index == 12 then
            self.rightBtn.gameObject:SetActive(true)
            if self.model.leftplayer ~= 0 then
                self.rightTitle.text = string.format(TI18N("获得<color='#00ffff'>%s</color>钻"),math.floor(self.model.rules.gold_item[1].g_num/self.model.leftplayer))
                self.rightTitle2.gameObject:SetActive(true)
                self.rightTitle2.text = TI18N("恭喜冲顶成功")
            else
                self.rightTitle.text = TI18N("恭喜冲顶成功")
                self.rightTitle2.gameObject:SetActive(false)
            end
            self.pro:SetActive(false)
            self.cup:SetActive(true)
            self.cuprot:SetActive(true)
            self.cupimg:SetActive(true)
            -- self.rewardExt = MsgItemExt.New(self.rightBtnTxt, 300, 19, 22)
            -- self.rewardExt:SetData(string.format(TI18N("领取奖励%s{assets_2,%s}"),math.ceil(self.model.rules.gold_item[1].g_num/self.model.leftplayer),self.model.rules.gold_item[1].g_base_id))
            if self.model.leftplayer ~= 0 then
                self.rightDesc.text = string.format(TI18N("您答对了决胜题\n与%s位参赛者平分<color='#ffff00'>%s钻石</color>奖池！"),self.model.leftplayer,self.model.rules.gold_item[1].g_num)
            else
                self.rightDesc.text = string.format(TI18N("您答对了决胜题\n与其他获胜者平分<color='#ffff00'>%s钻石</color>奖池！"),self.model.rules.gold_item[1].g_num)
            end
        elseif self.model.curquestion.question_index == 11 then
            self.rightBtn.gameObject:SetActive(false)
            self.rightTitle2.gameObject:SetActive(false)
            self.rightDesc.text = TI18N("即将迎来第12题-<color='#fff000'>决胜题</color>\n答对后将平分奖池！")
            if self.effect4 == nil then
                self.effect4 = BaseUtils.ShowEffect(20451, self.transform:Find("Main") , Vector3(1,1,1), Vector3(0,125,-1000))
            end
            self.effect4:SetActive(false)
            self.effect4:SetActive(true)
            if self.effect7 == nil then
                self.effect7 = BaseUtils.ShowEffect(20454, self.transform:Find("Main") , Vector3(1,1,1), Vector3(0,0,-1000))
            end
            self.effect7:SetActive(false)
            self.effect7:SetActive(true)
        else
            self.rightTitle2.gameObject:SetActive(false)
            self.rightBtn.gameObject:SetActive(false)
            self.rightDesc.text = string.format(TI18N("本题中您战胜了<color='#ffff00'>%s位</color>参赛者\n第%s题将于%s秒后揭晓"),self.model.lostplayer,self.model.curquestion.question_index+1,self.model.rules.question_time)
        end
    else
        self.right.gameObject:SetActive(false)
        self.wrong.gameObject:SetActive(true)
        -- 最后一题
        if self.model.curquestion.question_index == 12 then
            self.wrongTitle.text = TI18N("活动已结束")
            if self.model.leftplayer ~= 0 then
                self.wrongDesc.text = string.format(TI18N("%s位参赛者平分%s钻石奖池\n每人获得<color='#ffff00'>%s钻石</color>"),self.model.leftplayer,self.model.rules.gold_item[1].g_num,math.floor(self.model.rules.gold_item[1].g_num/self.model.leftplayer))
            else
                self.wrongDesc.text = string.format(TI18N("参赛者平分%s钻石奖池"),self.model.rules.gold_item[1].g_num)
            end
            self.wrongBtn1.gameObject:SetActive(false)
            self.wrongBtn2.gameObject:SetActive(false)
            self.wrongBtn3.gameObject:SetActive(true)
            self.wrongBtn4.gameObject:SetActive(false)
            self.wrongcard:SetActive(false)
            self.pro:SetActive(false)
            self.cup:SetActive(true)
            self.cuprot:SetActive(true)
            self.cupimg:SetActive(true)
        -- 观战
        elseif self.model.playerInfo.index +1 ~= self.model.curquestion.question_index then
            self.wrongTitle.text = TI18N("围观中")
            self.wrongDesc.text = string.format(TI18N("下一题将于%s秒后揭晓"),self.model.rules.question_time)
            self.wrongBtn1.gameObject:SetActive(false)
            self.wrongBtn2.gameObject:SetActive(false)
            self.wrongBtn4.gameObject:SetActive(false)
            self.wrongcard:SetActive(false)
        -- 复活次数用完
        elseif self.model.playerInfo.revive_times >= self.model.rules.max_revive then
            self.wrongTitle.text = TI18N("回答错误可观战")
            self.wrongDesc.text = TI18N("复活次数已用完，继续观战涨知识吧")
            self.wrongBtn1.gameObject:SetActive(false)
            self.wrongBtn2.gameObject:SetActive(false)
            self.wrongBtn4.gameObject:SetActive(false)
            self.wrongcard:SetActive(false)
        -- 复活卡用完
        elseif  BackpackManager.Instance:GetItemCount(self.model.rules.revive[1].r_base_id) == 0 then
            self.wrongTitle.text = TI18N("回答错误可观战")
            self.wrongDesc.text = TI18N("已经没有复活卡，继续观战涨知识吧")
            self.wrongBtn1.gameObject:SetActive(false)
            self.wrongBtn2.gameObject:SetActive(true)
            self.wrongBtn4.gameObject:SetActive(false)
            self.wrongcard:SetActive(true)
        -- 倒数第二题
        elseif  self.model.curquestion.question_index == 11 then
            self.wrongTitle.text = TI18N("复活后参与决胜题")

            self.wrongDesc.text = TI18N("20秒内消耗一张<color='#fff000'>复活卡</color>可继续答题\n倒计时结束后开始第12题-<color='#fff000'>决胜题</color>")
            self.wrongBtn1.gameObject:SetActive(true)
            self.wrongBtn2.gameObject:SetActive(false)
            self.wrongBtn4.gameObject:SetActive(false)
            self.wrongcard:SetActive(true)
            if self.effect4 == nil then
                self.effect4 = BaseUtils.ShowEffect(20451, self.transform:Find("Main") , Vector3(1,1,1), Vector3(0,125,-1000))
            end
            self.effect4:SetActive(false)
            self.effect4:SetActive(true)
            if self.effect7 == nil then
                self.effect7 = BaseUtils.ShowEffect(20454, self.transform:Find("Main") , Vector3(1,1,1), Vector3(0,0,-1000))
            end
            self.effect7:SetActive(false)
            self.effect7:SetActive(true)
        else
            self.wrongTitle.text = TI18N("回答错误可复活")
            self.wrongDesc.text = string.format(TI18N("20秒内消耗一张<color='#fff000'>复活卡</color>可继续答题\n倒计时结束后开始第%s题"),self.model.curquestion.question_index+1)
            self.wrongBtn1.gameObject:SetActive(true)
            self.wrongBtn2.gameObject:SetActive(false)
            self.wrongBtn3.gameObject:SetActive(false)
            self.wrongBtn4.gameObject:SetActive(false)
            self.wrongcard:SetActive(true)
        end
        if self.model.curquestion.question_index == 11 then
            if self.effect4 == nil then
                self.effect4 = BaseUtils.ShowEffect(20451, self.transform:Find("Main") , Vector3(1,1,1), Vector3(0,125,-1000))
            end
            self.effect4:SetActive(false)
            self.effect4:SetActive(true)
            if self.effect7 == nil then
                self.effect7 = BaseUtils.ShowEffect(20454, self.transform:Find("Main") , Vector3(1,1,1), Vector3(0,0,-1000))
            end
            self.effect7:SetActive(false)
            self.effect7:SetActive(true)
        end
    end
end

function RushTopMain:Relive()
    self.wrongTitle.text = TI18N("复活成功")
    self.wrongDesc.text = string.format(TI18N("复活成功，倒计时结束后开始第%s题"),self.model.curquestion.question_index+1)
    self.wrongBtn1.gameObject:SetActive(false)
    self.wrongBtn2.gameObject:SetActive(false)
    self.wrongBtn3.gameObject:SetActive(false)
    self.wrongBtn4.gameObject:SetActive(false)
    self.wrongcard:SetActive(false)
    self.statusTag.gameObject:SetActive(false)

    if self.effect3 == nil then
        self.effect3 = BaseUtils.ShowEffect(20450, self.transform:Find("Main") , Vector3(1,1,1), Vector3(0,0,-1000))
    end
    self.effect3:SetActive(false)
    self.effect3:SetActive(true)
    if self.effect1 ~= nil then
        self.effect1:SetActive(false)
    end
    if self.effect2 ~= nil then
        self.effect2:SetActive(false)
    end

end

function RushTopMain:Watch()
    self.qanda.gameObject:SetActive(false)
    self.statusTag.gameObject:SetActive(false)
    self.pro:SetActive(false)
    self.cup:SetActive(true)
    self.cuprot:SetActive(true)
    self.cupimg:SetActive(true)
    self.right.gameObject:SetActive(false)
    self.wrong.gameObject:SetActive(true)
    self.wrongcard:SetActive(false)
    self.wrongBtn1.gameObject:SetActive(false)
    self.wrongBtn2.gameObject:SetActive(false)
    self.wrongBtn3.gameObject:SetActive(false)
    self.wrongBtn4.gameObject:SetActive(true)

    if self.openArgs.watch == 1 then
        self.wrongTitle.text = TI18N("您来晚了，可围观")
        self.wrongDesc.text = TI18N("您错过了答题时间，仍然可以围观和发送弹幕哦\n涨涨知识，下一局再战吧")
    elseif self.openArgs.watch == 2 then
        self.wrongTitle.text = TI18N("您已出局，可围观")
        self.wrongDesc.text = TI18N("您已遗憾出局，仍然可以围观和发送弹幕哦\n涨涨知识，下一局再战吧")
    end
    self.openArgs = nil

end

function RushTopMain:IsShowButton()
    if RushTopManager.Instance.model.status == RushTopEnum.State.Ready or RushTopManager.Instance.model.curquestion == nil or (RushTopManager.Instance.model.curquestion ~= nil and RushTopManager.Instance.model.curquestion.question_index == 0) then
        self.leftobj.gameObject:SetActive(false)
        self.pooltrans.anchoredPosition = Vector2(-120,0)
        self.cardtrans.anchoredPosition = Vector2(120,0)
    else
        self.leftobj.gameObject:SetActive(true)
        self.pooltrans.anchoredPosition = Vector2(-170,0)
        self.cardtrans.anchoredPosition = Vector2(170,0)
    end
end

function RushTopMain:SetGold()
    if RushTopManager.Instance.model.rules ~= nil and RushTopManager.Instance.model.rules.gold_item[1].g_num ~= nil then
        self.pool.text = RushTopManager.Instance.model.rules.gold_item[1].g_num
        self.poolicon.localPosition = Vector2(self.pool.preferredWidth/2 + 22,-14)
    end
end

function RushTopMain:SetCard()
    if RushTopManager.Instance.model.rules ~= nil and RushTopManager.Instance.model.rules.revive[1].r_base_id ~= nil then
       self.card.text = BackpackManager.Instance:GetItemCount(RushTopManager.Instance.model.rules.revive[1].r_base_id)
    end
end

function RushTopMain:SetLeft()
    if RushTopManager.Instance.model.leftplayer ~= nil then
       self.left.text =  RushTopManager.Instance.model.leftplayer
    elseif RushTopManager.Instance.model.curquestion ~= nil then
        self.left.text =  RushTopManager.Instance.model.curquestion.role_num
    else
        self.left.text = TI18N("")
    end
end


function RushTopMain:Frist()
    self.qanda.gameObject:SetActive(false)
    self.pro:SetActive(true)
    self.cup:SetActive(false)
    self.cuprot:SetActive(false)
    self.cupimg:SetActive(false)
    self.statusTag.gameObject:SetActive(false)
    self.right.gameObject:SetActive(false)
    self.wrong.gameObject:SetActive(true)

    self.wrongTitle.text = TI18N("第一题")
    self.wrongDesc.text = string.format(TI18N("即将揭晓第1题，请准备"))
    self.wrongBtn1.gameObject:SetActive(false)
    self.wrongBtn2.gameObject:SetActive(false)
    self.wrongBtn3.gameObject:SetActive(false)
    self.wrongBtn4.gameObject:SetActive(false)
    self.wrongcard:SetActive(false)

    self:DeleteTimer()
    self.firstitme = self.firstitme or (self.model.rules.first_time + BaseUtils.BASE_TIME)
    local left = self.firstitme - BaseUtils.BASE_TIME
    local showeft = false
    self.timerId4 = LuaTimer.Add(0 , 20 , function()
        if left > 0.02 and self.pro ~= nil then
            self:ShowPro(true)
            self.process.fillAmount = left/20
            self.lefttime.text = math.max(math.ceil(left),0)
            left = left - 0.04

            if left < 0.1 and showeft == false then
                if self.effect6 == nil then
                    self.effect6 = BaseUtils.ShowEffect(20453, self.pro.transform , Vector3(1,1,1), Vector3(0,0,-1000))
                end
                self.effect6:SetActive(false)
                self.effect6:SetActive(true)
                showeft = true
            end

        else
            -- self:ShowPro(false)

            LuaTimer.Delete(self.timerId4)
        end
    end)
end


function RushTopMain:ShowPro(bool)
    self.lefttime.gameObject:SetActive(bool)
    self.process.gameObject:SetActive(bool)
    self.probg.gameObject:SetActive(bool)
end

function RushTopMain:SetDamaku()
    if self.model.playerInfo == nil then
        return
    end
    if self.model.playerInfo.ply_barrage == 0 then
        self.damakubtn.sprite = self.assetWrapper:GetSprite(AssetConfig.rushtop_texture,"unsendbtn")
        self.damakuimg:SetActive(false)
    elseif self.model.playerInfo.ply_barrage == 1 then
        self.damakubtn.sprite = self.assetWrapper:GetSprite(AssetConfig.rushtop_texture,"setbtn")
        self.damakuimg:SetActive(true)
    end
end

function RushTopMain:DeleteTimer()
   if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
    end
    if self.timerId2 ~= nil then
        LuaTimer.Delete(self.timerId2)
    end
    if self.timerId3 ~= nil then
        LuaTimer.Delete(self.timerId3)
    end
    if self.timerId4 ~= nil then
        LuaTimer.Delete(self.timerId4)
    end
    if self.timerId5 ~= nil then
        LuaTimer.Delete(self.timerId5)
    end
    if self.tweenId ~= nil then
        LuaTimer.Delete(self.tweenId)
    end
end


function RushTopMain:RotationBg()
    self.rotationTweenId  = Tween.Instance:ValueChange(0,360,4, function() self.rotationTweenId = nil self:RotationBg(callback) end, LeanTweenType.Linear,function(value) self:RotationChange(value) end).id
end

function RushTopMain:RotationChange(value)
    if self.cupbg ~= nil then
        self.cupbg.localRotation = Quaternion.Euler(0, 0, value)
    end
end



function RushTopMain:CloseMyWindow()

    if self.model.mainPanel ~= nil and self.model.mainPanel.button ~= nil then

        self.sendBtn:SetActive(false)
        self.setBtn:SetActive(false)
        self.top:SetActive(false)

        if self.tweenIdY == nil then
            self.tweenIdY = Tween.Instance:MoveLocalX(self.main.gameObject,-50,0.3, function()  end,LeanTweenType.easeInQuad).id
        end

        if self.tweenIdX == nil then
            self.tweenIdX = Tween.Instance:MoveLocalX(self.main.gameObject,0,0.3, function()  end,LeanTweenType.easeInQuad).id
        end

        if self.tweenScalerId == nil then
            self.tweenScalerId = Tween.Instance:Scale(self.main.gameObject, Vector3(0.2,0.2,0.2),0.3, function()  end, LeanTweenType.easeInQuad).id
        end

        if self.delayTimerId == nil then
            self.delayTimerId  = LuaTimer.Add(320,function() WindowManager.Instance:CloseWindow(self)  end)
        end
    else
        WindowManager.Instance:CloseWindow(self)
    end
end