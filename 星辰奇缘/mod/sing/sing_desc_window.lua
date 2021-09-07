-- @author 黄耀聪
-- @date 2016年7月27日
-- 好声音 描述

SingDescWindow = SingDescWindow or BaseClass(BaseWindow)

function SingDescWindow:__init(model)
    self.model = model
    self.name = "SingDescWindow"

    self.resList = {
        {file = AssetConfig.sing_desc_window, type = AssetType.Main},
        {file = AssetConfig.sing_res, type = AssetType.Dep},
        {file = AssetConfig.bigatlas_sing_bg, type = AssetType.Main},
    }

    self.timeDataList = {
        TI18N("<color='#ffff00'>预选赛</color> 报名阶段：<color='#00ff00'>6月30号~7月01号</color>"),
        TI18N("投票阶段：<color='#00ff00'>7月02号~7月07号</color>"),
        TI18N("<color='#ffff00'>入围赛</color> 报名阶段：<color='#00ff00'>7月08号~7月10号</color>"),
        TI18N("投票阶段：<color='#00ff00'>7月12号~7月19号</color>"),
    }

    self.descDataList = {
        TI18N("1.报名阶段，前往<color='#ffff00'>圣心城—音儿</color>处报名，录音上传自己的声音。"),
        TI18N("2.投票阶段，玩家可前往音儿处，对参赛作品进行投票"),
        TI18N("3.参加选手报名成功后会获得<color='#00ff00'>“好声音宣传册”</color>，可对自己的作品进行宣传拉票"),
    }

    self.descStringList = {
        {
            title = TI18N("活动说明："),
            descList = {
                TI18N("1.报名阶段，前往<color='#ffff00'>圣心城—音儿</color>处报名，录音上传自己的声音。"),
                TI18N("2.投票阶段，玩家可前往音儿处，对参赛作品进行投票"),
                TI18N("3.参加选手报名成功后会获得<color='#00ff00'>“好声音宣传册”</color>，可对自己的作品进行宣传拉票"),
            }
        },
        {
            title = TI18N("报名说明："),
            descList = {
                TI18N("1.<color='#00ff00'>等级≥50</color>的玩家可参与报名，上传<color='#00ff00'>20~80s</color>的录音"),
                TI18N("2.报名需要扣除一定银币，成功报名后可<color='#00ff00'>随时修改</color>重新上传自己的录音和声音介绍"),
                TI18N("3.报名成功后会获得<color='#ffff00'>“好声音宣传册”</color>，在报名阶段，可以使用宣传册为自己拉票"),
                TI18N("4.报名阶段所有玩家<color='#ffff00'>无法</color>进行投票"),
            }
        },
        {
            title = TI18N("投票说明："),
            descList = {
                TI18N("1.超过<color='#00ff00'>世界等级-5</color>或当天活跃度超过<color='#00ff00'>100点</color>的玩家可以进行投票"),
                TI18N("2.在音儿处选择“我要投票”，可以对喜欢的声音进行投票"),
                TI18N("3.参赛选手可通过背包里的“好声音宣传册”为自己拉票"),
                TI18N("4.,每个玩家可以<color='#00ff00'>每天投票5次</color>，对同一名参赛选手只能投票一次"),
                TI18N("5.玩家可通过赠送<color='#00ff00'>桃红柳绿、999玫瑰、缤纷童年</color>任意一种为选手增加好评。"),
                TI18N("6.预选赛投票送花1次增加<color='#00ff00'>20票</color>，入围赛投票送花1次增加<color='#00ff00'>10票</color>"),
                TI18N("7.参赛选手通过接受赠送鲜花，每天可最多增加<color=#00ff00>200好评</color>"),
            }
        },
        {
            title = TI18N("活动奖励："),
            descList = {
                TI18N("本服赛事结束后，好评数排名前10的选手将进入本服<color='#ffff00'>好声音名人堂，获得好声音特殊称号、定制聊天气泡、队长头标</color>，冠军还将获得<color='#ffff00'>特殊聊天标识与雕像的荣耀</color>"),
            }
        },
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
    self.msg = {}
end

function SingDescWindow:__delete()
    self.OnHideEvent:Fire()
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    if self.msg ~= nil then
        for i,v in ipairs(self.msg) do
            v:DeleteMe()
        end
        self.msg = {}
    end
    self:AssetClearAll()
end

function SingDescWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.sing_desc_window))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    local main = t:Find("Main")
    main:Find("Title/Text"):GetComponent("Text").text = TI18N("星辰好声音")
    self.closeBtn = main:Find("CloseButton"):GetComponent(Button)
    self.container = main:Find("Bg/Scroll/Container")
    -- self.cloner = main:Find("Bg/Scroll/Cloner").gameObject
    self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.Y, cspacing = -8, border = 0})

    self.timeObj = main:Find("Bg/Scroll/Time").gameObject
    self.timeTitleText = main:Find("Bg/Scroll/Time/Title/Text"):GetComponent(Text)
    self.timeTextList = {main:Find("Bg/Scroll/Time/Time1"):GetComponent(Text), main:Find("Bg/Scroll/Time/Time2"):GetComponent(Text), main:Find("Bg/Scroll/Time/Time3"):GetComponent(Text), main:Find("Bg/Scroll/Time/Time4"):GetComponent(Text)}

    main:Find("Bg/Scroll/Time/Time2").anchoredPosition = Vector2(313.1, -34.2)
    main:Find("Bg/Scroll/Time/Time4").anchoredPosition = Vector2(313.1, -57.2)

    self.scrollRect = main:Find("Bg/Scroll"):GetComponent(RectTransform)
    self.scrollRect.anchorMax = Vector2(0.5, 1)
    self.scrollRect.anchorMin = Vector2(0.5, 1)
    self.scrollRect.pivot = Vector2(0.5, 1)
    self.scrollRect.sizeDelta = Vector2(552, 216.4)
    self.scrollRect.anchoredPosition = Vector2(0, -130)

    main:Find("Bg/BtnArea").sizeDelta = Vector2(558.5, 75)

    self.cloner = main:Find("Bg/Scroll/Reward").gameObject

    self.descObj = {}
    self.descTitleText = {}
    self.descText = {}

    for i=1,#self.descStringList do
        self.descObj[i] = GameObject.Instantiate(self.cloner)
        self.descTitleText[i] = self.descObj[i].transform:Find("Title/Text"):GetComponent(Text)
        self.descText[i] = self.descObj[i].transform:Find("Reward"):GetComponent(Text)

        self.descObj[i].transform:SetParent(self.container)
    end

    main:Find("Bg/BtnArea/Goto"):GetComponent(Button).onClick:AddListener(function()
        QuestManager.Instance.model:FindNpc("84_1")
        self.model:CloseDesc()
    end)

    main:Find("Bg/BtnArea/Check"):GetComponent(Button).onClick:AddListener(function()
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.sing_main_window)
    end)

    self.closeBtn.onClick:AddListener(function() self.model:CloseDesc() end)
    main:Find("Bg/Scroll/Desc").gameObject:SetActive(false)
    local bigbg = GameObject.Instantiate(self:GetPrefab(AssetConfig.bigatlas_sing_bg))
    UIUtils.AddBigbg(main:Find("Bg/SingBg"), bigbg)
    bigbg.transform.anchoredPosition3D = Vector2(0, 0)
    self:CloaseRedPoint()
end

function SingDescWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function SingDescWindow:OnOpen()
    self:CloaseRedPoint()
    self:RemoveListeners()

    self:Reload()
end

function SingDescWindow:OnHide()
    self:RemoveListeners()
end

function SingDescWindow:RemoveListeners()
end

function SingDescWindow:Reload()
    self.layout:ReSet()
    self.cloner:SetActive(false)

    self.layout:AddCell(self.timeObj)

    -- 活动时间
    for i,v in ipairs(self.timeDataList) do
        self.timeTextList[i].horizontalOverflow = 1
        self.timeTextList[i].text = v
    end
    self.timeTitleText.text = TI18N("活动时间：")

    for i,v in ipairs(self.descStringList) do
        local s = ""
        for index,desc in ipairs(v.descList) do
            s = s .. desc
            if index ~= #v.descList then
                s = s .. "\n"
            end
        end
        self.descText[i].lineSpacing = 1.1
        -- self.descText[i].text = s

        local w1 = self.descText[i].gameObject:GetComponent(RectTransform).sizeDelta.x
        local w = self.descObj[i]:GetComponent(RectTransform).sizeDelta.x
        self.descTitleText[i].text = v.title
        self.msg[i] = MsgItemExt.New(self.descText[i].gameObject:GetComponent(Text),500,18,20)
        self.msg[i]:SetData(s)

        -- self.descText[i].gameObject:GetComponent(RectTransform).sizeDelta = Vector2(w1, math.ceil(self.descText[i].preferredHeight) + 1)
        self.descObj[i]:GetComponent(RectTransform).sizeDelta = Vector2(w,self.msg[i].contentRect.sizeDelta.y + 35)

        self.layout:AddCell(self.descObj[i])
    end

    -- -- 活动说明
    -- local s = ""
    -- for i,v in ipairs(self.descDataList) do
    --     s = s .. v
    --     if i ~= #self.descDataList then
    --         s = s .. "\n"
    --     end
    -- end
    -- self.descText.lineSpacing = 1.1
    -- self.descText.text = s


    -- local w1 = self.descText.gameObject:GetComponent(RectTransform).sizeDelta.x
    -- local w = self.descObj:GetComponent(RectTransform).sizeDelta.x
    -- self.descText.gameObject:GetComponent(RectTransform).sizeDelta = Vector2(w1, math.ceil(self.descText.preferredHeight) + 1)
    -- self.descObj:GetComponent(RectTransform).sizeDelta = Vector2(w, math.ceil(self.descText.preferredHeight) + 35)


    -- -- 活动奖励
    -- local w = self.rewardObj:GetComponent(RectTransform).sizeDelta.x
    -- local w1 = self.rewardText.gameObject:GetComponent(RectTransform).sizeDelta.x
    -- self.rewardText.lineSpacing = 1.1
    -- self.rewardText.text = self.rewardString
    -- self.rewardText.gameObject:GetComponent(RectTransform).sizeDelta = Vector2(w1, math.ceil(self.rewardText.preferredHeight) + 2)
    -- self.rewardObj:GetComponent(RectTransform).sizeDelta = Vector2(w, math.ceil(self.rewardText.preferredHeight) + 40)

    -- self.layout:AddCell(self.timeObj)
    -- self.layout:AddCell(self.descObj)
    -- self.layout:AddCell(self.rewardObj)
end


function  SingDescWindow:CloaseRedPoint()
    local roledata = RoleManager.Instance.RoleData
    local key = BaseUtils.Key(roledata.id, roledata.platform, roledata.zone_id,99999)
    local str = "init"
    PlayerPrefs.SetString(key,str)
end

