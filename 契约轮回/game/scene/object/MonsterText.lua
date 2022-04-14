-- 
-- @Author: LaoY
-- @Date:   2018-08-02 11:14:56
-- 
MonsterText = MonsterText or class("MonsterText", BaseWidget)

MonsterText.__cache_count = 30

function MonsterText:ctor()
    self.abName = "system"
    self.assetName = "MonsterText"
    self.parent_node = LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.SceneText)
    self.builtin_layer = LayerManager.BuiltinLayer.Default

    self.position = { x = 0, y = 0, z = 0 }
    self.top_icon_radius = 17.5
    self.angry_icon_radius = 14.5
    self.events = {}
    self.isShowTalk = true

    BaseWidget.Load(self)
end

function MonsterText:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    self.events = {}

    --destroy(self.gameObject)
    --self.gameObject = nil
    if self.blood then
        self.blood:destroy();
    end

    if self.countdowntext then
        self.countdowntext:destroy();
    end

    if self.boomText then
        self.boomText:destroy();
    end

    self.buff_img = nil

    if self.talk_schedual then
        GlobalSchedule:Stop(self.talk_schedual);
    end
    self.talk_schedual = nil
end

function MonsterText:__reset()
    self.parent_node = LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.SceneText)
    MonsterText.super.__reset(self);
    self:ShowBelong(false);
    self:ShowBlood(false);
    --SetGameObjectActive(self.title_img, false);
    self.countdowntext:SetVisible(false)
    self:ShowAngry(false);
    --self:ShowGuildWar(false);
    self:ShowBoom(false);
    --self:SetAthleticsScore(false, 0);
    --self:ShowTitle(0);
    self:UpdateNamePos();
    --self:SetJobTitle("");
    self.blood:UpdateCurrentBloodImmi(1, 1);
    --self:SetEscortFlag(false, "");
    --self:ShowGuildName(false)
    --self:ShowMarryName(false)
    self:HideBuffImage()
    --self:UpdateTopLevelIconShow(false)
    self:ShowTalk(false)
    if self.talk_schedual then
        GlobalSchedule:Stop(self.talk_schedual);
    end
    self.talk_schedual = nil
    self.isShowTalk = true
    self:SetVisible(true)
    self:ShowCGS(false)
    if self.cgsAction then
        cc.ActionManager:GetInstance():removeAction(self.cgsAction)
        self.cgsAction = nil
    end
end

function MonsterText:LoadCallBack()
    self.nodes = {
        "title/belong", "blood", "countdown", "boom/boom_text", "boom",

        "name", "angry_bg/angry_text", "angry_bg","talk","talk/talkText",

        "cgsTitle",

        --"job_title/FactionBattle", "job_title/FactionBattle/GuildName",
        --"title/marryName", "title/gName","top_icon","title/athleticsFlag",
        --"title/athleticsFlag/athleticsScore", "title/title_img", "job_title", "escortFlag",
    }
    self:GetChildren(self.nodes)
    self.talkText = GetText(self.talkText)
    self.name_text = self.name:GetComponent('Text')
    self.text_outline = self.name:GetComponent('Outline')

    --self.job_title_text = self.job_title:GetComponent('Text')
    --self.job_title_outline = self.job_title:GetComponent('Outline')
    --self.athleticsScore = GetText(self.athleticsScore)
    --SetGameObjectActive(self.athleticsFlag, false);
    --@ling belong应该也是可以去掉的
    self.belong = GetImage(self.belong);
    --self.escortFlag = GetImage(self.escortFlag)
    --self.marryName = GetText(self.marryName)
    --self.gName = GetText(self.gName)

    --self:ShowGuildName(false)
    --self:ShowMarryName(false)
    --self.escortFlag.gameObject:SetActive(false)

    self:ShowBelong(false);

    self.blood = BossBloodItem(self.blood, 3);
    self:ShowBlood(false);

    --self.title_img = GetImage(self.title_img);
    --SetGameObjectActive(self.title_img, false);

    self.countdowntext = CountDownText(self.countdown, { formatText = "%s", isShowMin = true, isShowHour = true });
    self.countdowntext:SetVisible(false)
    -- self.countdowntext.gameObject:SetActive(false);

    self.angry_text = GetText(self.angry_text);
    self:ShowAngry(false);

    self:ShowCGS(false)

    --self.guildName = GetText(self.GuildName);
    --self.guildWarFlag = GetImage(self.FactionBattle);
    --self:ShowGuildWar(false)

    local tab = {
        formatText = "%s",
        isShowMin = false,
        formatTime = "%d",
        nodes = { "boom_text" },
        duration = 0.2,
    }
    self.boomText = CountDownText(self.boom, tab);
    self:ShowBoom(false);
    self:SetVisible(true)
    --self:SetJobTitle("")


    self:ShowTalk(false)
    self:AddEvent();

    --self:UpdateTopLevelIconShow(false)
end

function MonsterText:AddEvent()
    --self.events[#self.events + 1] = GlobalEvent:AddListener(EventName.ChangeSceneEnd, handler(self, self.HandleSceneChange));
end

function MonsterText:SetName(name)
    --if name == "" then
    --    self:SetVisible(false)
    --    return
    --end
    self.name_text.text = name or "Monster"
    SetVisible(self.name_text, true)
    self:UpdateNamePos()
end
function MonsterText:ShowName(bool)
    bool = toBool(bool);
    SetGameObjectActive(self.name_text, false);
end

function MonsterText:UpdateNamePos()
    self.name_width = self.name_text.preferredWidth
    local job_title_width = 0
    self.name_x = job_title_width * 0.5

    SetLocalPositionX(self.name, self.name_x)
end

function MonsterText:SetColor(color, outline_color)
    if color then
        SetColor(self.name_text, color.r, color.g, color.b, color.a)
    end
    if outline_color then
        SetOutLineColor(self.text_outline, outline_color.r, outline_color.g, outline_color.b, outline_color.a)
    end
end

function MonsterText:ShowBelong(bool)
    bool = toBool(bool);

    if bool == self.isShowBelong then
        --nil 也是不等啊

    else
        self.isShowBelong = bool;
        self.belong.gameObject:SetActive(bool);
    end
end

function MonsterText:ShowCGS(bool)
    bool = toBool(bool);
    if bool then
        if self.cgsAction then
            cc.ActionManager:GetInstance():removeAction(self.cgsAction)
            self.cgsAction = nil
        end
        self.cgsAction = cc.MoveTo(1.5, -107,140,0)
        self.cgsAction = cc.Sequence(self.cgsAction, cc.MoveTo(1.5, -107,130,0))
        self.cgsAction = cc.Repeat(self.cgsAction, 4)
        self.cgsAction = cc.RepeatForever(self.cgsAction)
        cc.ActionManager:GetInstance():addAction(self.cgsAction, self.cgsTitle.             transform)
    else
        if self.cgsAction then
            cc.ActionManager:GetInstance():removeAction(self.cgsAction)
            self.cgsAction = nil
        end
    end

    SetGameObjectActive(self.cgsTitle, bool);
end

function MonsterText:SetBuffImage(abName, res)
    -- if not self.buff_img then
    --     local go = PreloadManager:GetInstance():CreateWidget("system", "EmptyImage")
    --     local transform = go.transform
    --     transform:SetParent(self.transform)
    --     SetLocalPosition(transform, 0, 50, 0)
    --     SetLocalScale(transform, 1, 1, 1)
    --     SetSizeDelta(transform, 50, 50)
    --     transform.name = "buff_img"
    --     local img = transform:GetComponent('Image')
    --     self.buff_img = { transform = transform, gameObject = go, img = img }
    -- end
    -- local function callBack(sprite)
    --     self.buff_img.img.sprite = sprite
    --     -- 算位置

    -- end
    -- SetVisible(self.buff_img.transform, true)
    -- lua_resMgr:SetImageTexture(self, self.buff_img.img, abName, res, false, callBack)

    RoleText.SetBuffImage(self,abName, res)
end

function MonsterText:HideBuffImage()
    RoleText.HideBuffImage(self)
    -- if not self.is_dctored and self.buff_img then
    --     SetVisible(self.buff_img.transform, false)
    -- end
end

function MonsterText:StartCountDown(time)
    self.countdowntext.gameObject:SetActive(true);
    self.countdowntext:StartSechudle(time);
end

function MonsterText:ShowAngry(bool)
    SetGameObjectActive(self.angry_bg, bool);
    self:UpdateAngryPos()
end

function MonsterText:UpdateAngryPos()
    self.name_width = self.name_text.preferredWidth
    local angry_x = -(self.name_width * 0.5) - self.angry_icon_radius
    SetLocalPositionX(self.angry_bg.transform, angry_x)
end

function MonsterText:StartBoom(time)
    self:ShowBoom(true);
    local callBack = function()
        self:ShowBoom(false);
    end
    self.boomText:StartSechudle(time, callBack);
end

function MonsterText:ShowBoom(bool)
    SetGameObjectActive(self.boom, bool);
end

function MonsterText:UpdateBlood(current, max)
    if self.blood then
        self.blood:UpdateCurrentBloodImmi(current, max);
    end
end

function MonsterText:ShowBlood(bool)
    bool = toBool(bool);
    self.blood.gameObject:SetActive(bool);
end

function MonsterText:SetGlobalPosition(x, y, z)
    self.position = { x = x, y = y, z = z }
    SetGlobalPosition(self.transform, x, y, z)
end

function MonsterText:SetAngryNum(num)
    if self.angry_text then
        self.angry_text.text = tostring(num);
    end
end

function MonsterText:SetTalkContent(content)
    self.talkText.text = content
end

function MonsterText:ShowTalk(bool,sec)
    if self.isShowTalk then
        self.talk.gameObject:SetActive(bool)
        if bool then
            self.isShowTalk = false
            local function call_back()
                sec = sec - 1
                if sec < 0 then
                    if self.talk_schedual then
                        GlobalSchedule:Stop(self.talk_schedual);
                    end
                    self.talk_schedual = nil

                    if self.talk.gameObject then
                        self.talk.gameObject:SetActive(false)
                    end

                end

            end
            self.talk_schedual = GlobalSchedule:Start(call_back, 1, -1);
        end
    end
end


--
--
--function MonsterText:SetData(data)
--
--end
--
--
--
--function MonsterText:ShowGuildWar(bool, group, guildName)
--    bool = toBool(bool)
--    if (bool) then
--        local icon = group == 1 and "Flag_Blue" or "Flag_Red"
--        lua_resMgr:SetImageTexture(self, self.guildWarFlag, "FactionBattle_image", icon, true);
--        self.guildName.text = guildName
--
--        self.FactionBattle.gameObject:SetActive(true)
--    else
--        self.FactionBattle.gameObject:SetActive(false)
--    end
--end
--
--function MonsterText:ShowGuildName(bool, text)
--    if bool then
--        self.gName.text = text
--    end
--    self.gName.gameObject:SetActive(bool)
--end
--
--function MonsterText:ShowMarryName(bool, text)
--    if bool then
--        self.marryName.text = text
--    end
--    self.marryName.gameObject:SetActive(bool)
--end
--
--
--
--
--
--

----46000,46001
--function MonsterText:ShowTitle(title_id)
--    if SettingModel:GetInstance().isShowTitle then
--        if self.title_img then
--            if title_id == 0 then
--                SetGameObjectActive(self.title_img, false);
--            else
--                SetGameObjectActive(self.title_img, true);
--                lua_resMgr:SetImageTexture(self, self.title_img, Constant.TITLE_IMG_PATH, tostring(title_id), true, nil, false)
--                self.title_img:SetNativeSize()
--            end
--
--        end
--    else
--        if self.title_img then
--            SetGameObjectActive(self.title_img, false);
--        end
--    end
--end
--
--
--
--
--
--
--function MonsterText:UpdateTopLevelIconShow(is_show)
--    if self.top_icon_is_show == is_show then
--        return
--    end
--    self.top_icon_is_show = is_show
--    SetVisible(self.top_icon, is_show)
--end
--
--function MonsterText:SetJobTitle(title)
--    self.job_title_text.text = title
--    self:UpdateNamePos()
--end
--
--function MonsterText:SetJobTitleOutLine(color_str)
--    local r, g, b, a = HtmlColorStringToColor(color_str)
--    SetOutLineColor(self.job_title_outline, r, g, b, a)
--end
--
--function MonsterText:SetEscortFlag(bool, imgName)
--    SetGameObjectActive(self.escortFlag, bool);
--    if bool then
--        lua_resMgr:SetImageTexture(self, self.escortFlag, "factionEscort_image", imgName, true)
--    end
--end
--
--function MonsterText:SetAthleticsScore(bool, score)
--    SetGameObjectActive(self.athleticsFlag, bool);
--    if bool and score then
--        self.athleticsScore.text = "x" .. score
--        self:ShowTitle(0);
--        self:ShowMarryName(false, "");
--    end
--end
--
--
--
--
--

--
--
----进阶副本的特殊操作
--function MonsterText:ShowAdvanceItem()
--    if not self.advanceitem then
--        self.advanceitem = AdvanceDungeonItem(self.transform);
--    end
--end
--
--function MonsterText:UpdateSliencePos(pos)
--    if self.advanceitem then
--        self.advanceitem:UpdateSliencePos(pos);
--    end
--end
--
--function MonsterText:ShowDef(bool)
--    if self.advanceitem then
--        self.advanceitem:ShowDef(bool);
--    end
--end
--
--function MonsterText:ShowDes(bool, text)
--    if self.advanceitem then
--        self.advanceitem:ShowDes(bool, text);
--    end
--end
--
--function MonsterText:ShowLock(bool)
--    if self.advanceitem then
--        self.advanceitem:ShowLock(bool);
--    end
--end
--
--function MonsterText:ShowSlience(bool)
--    if self.advanceitem then
--        self.advanceitem:ShowSlience(bool);
--    end
--end
--
---- function MonsterText:SetVisible(flag)
----     MonsterText.super.SetVisible(self,flag)
----     if AppConfig.Debug then
----         if not flag then
----             Yzprint('--LaoY MonsterText.lua,line 402--',data)
----             traceback()
----         end
----     end
---- end