-- 
-- @Author: LaoY
-- @Date:   2018-08-02 11:14:56
-- 
RoleText = RoleText or class("RoleText", BaseWidget)

RoleText.__cache_count = 30

function RoleText:ctor()
    self.abName = "system"
    self.assetName = "RoleText"
    self.parent_node = LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.SceneText)
    self.builtin_layer = LayerManager.BuiltinLayer.Default

    self.position = { x = 0, y = 0, z = 0 }
    self.top_icon_radius = 17.5
    self.angry_icon_radius = 14.5
    self.events = {}

    BaseWidget.Load(self)
end

function RoleText:dctor()
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

    if self.buff_img and self.buff_img.gameObject then
        if not poolMgr:AddGameObject("system","EmptyImage",self.buff_img.gameObject) then
            destroy(self.buff_img.gameObject)
        end
        self.buff_img.gameObject = nil
    end
    self.buff_img = nil

    self:RemoveMachineArmorShield()
end

function RoleText:__clear()
    self:RemoveMachineArmorShield()
    RoleText.super.__clear(self)
end

function RoleText:__reset()
    self.parent_node = LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.SceneText)
    RoleText.super.__reset(self);
    self:ShowBelong(false);
    self:ShowBlood(false);
    SetGameObjectActive(self.title_img, false);
    self.countdowntext:SetVisible(false)
    self:ShowAngry(false);
    self:ShowGuildWar(false);
    self:ShowBoom(false);
    self:SetAthleticsScore(false, 0);
    self:ShowTitle(0);
    self:UpdateNamePos();
    self:SetJobTitle("");
    self.blood:UpdateCurrentBloodImmi(1, 1);
    self:SetEscortFlag(false, "");
    self:ShowGuildName(false)
    self:ShowMarryName(false)
    self:HideBuffImage()
    self:UpdateTopLevelIconShow(false)

    self:SetVisible(true)

end

function RoleText:LoadCallBack()
    self.nodes = {
        "title/belong", "title/title_img", "blood", "countdown", "boom/boom_text", "boom", "job_title", "title/escortFlag",
        "job_title/FactionBattle", "job_title/FactionBattle/GuildName", "title/athleticsFlag", "title/athleticsFlag/athleticsScore",
        "title/marryName", "title/gName", "name", "top_icon", "angry_bg/angry_text", "angry_bg",
    }
    self:GetChildren(self.nodes)

    self.name_text = self.name:GetComponent('Text')
    self.text_outline = self.name:GetComponent('Outline')

    self.job_title_text = self.job_title:GetComponent('Text')
    self.job_title_outline = self.job_title:GetComponent('Outline')
    self.athleticsScore = GetText(self.athleticsScore)
    SetGameObjectActive(self.athleticsFlag, false);
    self.belong = GetImage(self.belong);
    self.escortFlag = GetImage(self.escortFlag)
    self.marryName = GetText(self.marryName)
    self.gName = GetText(self.gName)

    self:ShowGuildName(false)
    self:ShowMarryName(false)
    self.escortFlag.gameObject:SetActive(false)

    self:ShowBelong(false);

    self.blood = BossBloodItem(self.blood, 3);
    self:ShowBlood(false);

    self.title_img = GetImage(self.title_img);
    SetGameObjectActive(self.title_img, false);

    self.countdowntext = CountDownText(self.countdown, { formatText = "%s", isShowMin = true, isShowHour = true });
    self.countdowntext.gameObject:SetActive(false);

    self.angry_text = GetText(self.angry_text);
    self:ShowAngry(false);

    self.guildName = GetText(self.GuildName);
    self.guildWarFlag = GetImage(self.FactionBattle);
    self:ShowGuildWar(false)

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
    self:SetJobTitle("")
    self:AddEvent();

    self:UpdateTopLevelIconShow(false)
end

function RoleText:AddEvent()
    --self.events[#self.events + 1] = GlobalEvent:AddListener(EventName.ChangeSceneEnd, handler(self, self.HandleSceneChange));
end

--function RoleText:HandleSceneChange(sceneId)
--    --local config = Config.db_scene[sceneId]
--    --if not config then
--    --    return
--    --end
--    --
--    --if config.type == 5 and config.stype == enum.SCENE_STYPE.SCENE_STYPE_GUILD_WAR then
--    --    self:ShowGuildWar(true)
--    --else
--    --    self:ShowGuildWar(false)
--    --end
--end

function RoleText:SetData(data)

end

function RoleText:SetColor(color, outline_color)
    if color then
        SetColor(self.name_text, color.r, color.g, color.b, color.a)
    end
    if outline_color then
        SetOutLineColor(self.text_outline, outline_color.r, outline_color.g, outline_color.b, outline_color.a)
    end
end

function RoleText:ShowBelong(bool)
    bool = toBool(bool);

    if bool == self.isShowBelong then
        --nil 也是不等啊

    else
        self.isShowBelong = bool;
        self.belong.gameObject:SetActive(bool);
    end
    --
    --if not self.isShowBelong then
    --    self.isShowBelong = bool
    --    self.belong.gameObject:SetActive(bool);
    --elseif bool == self.isShowBelong then
    --
    --else
    --    self.belong.gameObject:SetActive(bool);
    --end

end

function RoleText:ShowGuildWar(bool, group, guildName)
    bool = toBool(bool)
    if (bool) then
        local icon = group == 1 and "Flag_Blue" or "Flag_Red"
        lua_resMgr:SetImageTexture(self, self.guildWarFlag, "FactionBattle_image", icon, true);
        self.guildName.text = guildName

        self.FactionBattle.gameObject:SetActive(true)
    else
        self.FactionBattle.gameObject:SetActive(false)
    end
end

function RoleText:ShowGuildName(bool, text)
    if bool then
        self.gName.text = text
    end
    self.gName.gameObject:SetActive(bool)
end

function RoleText:ShowMarryName(bool, text)
    if bool then
        self.marryName.text = text
    end
    self.marryName.gameObject:SetActive(bool)
end

function RoleText:ShowBlood(bool)
    bool = toBool(bool);
    self.blood.gameObject:SetActive(bool);
end

function RoleText:ShowAngry(bool)
    SetGameObjectActive(self.angry_bg, bool);
    self:UpdateAngryPos()
end

function RoleText:ShowBoom(bool)
    SetGameObjectActive(self.boom, bool);
end

function RoleText:SetAngryNum(num)
    if self.angry_text then
        self.angry_text.text = tostring(num);
    end
end
--46000,46001
function RoleText:ShowTitle(title_id)
    if SettingModel:GetInstance().isShowTitle then
        if self.title_img then
            if title_id == 0 then
                SetGameObjectActive(self.title_img, false);
            else
                SetGameObjectActive(self.title_img, true);
                lua_resMgr:SetImageTexture(self, self.title_img, Constant.TITLE_IMG_PATH, tostring(title_id), true, nil, false)
                self.title_img:SetNativeSize()
            end

        end
    else
        if self.title_img then
            SetGameObjectActive(self.title_img, false);
        end
    end
end

function RoleText:StartCountDown(time)
    self.countdowntext.gameObject:SetActive(true);
    self.countdowntext:StartSechudle(time);
end

function RoleText:StartBoom(time)
    self:ShowBoom(true);
    local callBack = function()
        self:ShowBoom(false);
    end
    self.boomText:StartSechudle(time, callBack);
end

function RoleText:UpdateBlood(current, max)
    if self.blood then
        self.blood:UpdateCurrentBloodImmi(current, max);
    end
end

function RoleText:SetName(name)
    --if name == "" then
    --    self:SetVisible(false)
    --    return
    --end
    self.name_text.text = name or "Monster"
    SetVisible(self.name_text, true)
    self:UpdateNamePos()
end
function RoleText:ShowName(bool)
    bool = toBool(bool);
    SetGameObjectActive(self.name_text, false);
end

function RoleText:UpdateTopLevelIconShow(is_show)
    if self.top_icon_is_show == is_show then
        return
    end
    self.top_icon_is_show = is_show
    SetVisible(self.top_icon, is_show)
end

function RoleText:SetJobTitle(title)
    self.job_title_text.text = title
    self:UpdateNamePos()
end

function RoleText:SetJobTitleOutLine(color_str)
    local r, g, b, a = HtmlColorStringToColor(color_str)
    SetOutLineColor(self.job_title_outline, r, g, b, a)
end

function RoleText:SetEscortFlag(bool, imgName)
    SetGameObjectActive(self.escortFlag, bool);
    if bool then
        lua_resMgr:SetImageTexture(self, self.escortFlag, "factionEscort_image", imgName, true)
    end
end

function RoleText:SetAthleticsScore(bool, score)
    SetGameObjectActive(self.athleticsFlag, bool);
    if bool and score then
        self.athleticsScore.text = "x" .. score
        self:ShowTitle(0);
        self:ShowMarryName(false, "");
    end
end

function RoleText:UpdateNamePos()
    self.name_width = self.name_text.preferredWidth
    local job_title_width = self.job_title_text.preferredWidth
    local total_width = self.name_width + job_title_width
    self.name_x = job_title_width * 0.5
    local job_title_x = -self.name_width * 0.5
    --巅峰等级图标
    local icon_x = self.name_x + (self.name_width * 0.5) + self.top_icon_radius

    SetLocalPositionX(self.name, self.name_x)
    SetLocalPositionX(self.job_title, job_title_x)
    if self.top_icon_is_show then
        SetLocalPositionX(self.top_icon, icon_x)
    end
end

function RoleText:UpdateAngryPos()
    self.name_width = self.name_text.preferredWidth
    local angry_x = -(self.name_width * 0.5) - self.angry_icon_radius
    SetLocalPositionX(self.angry_bg.transform, angry_x)
end

function RoleText:SetGlobalPosition(x, y, z)
    self.position = { x = x, y = y, z = z }
    SetGlobalPosition(self.transform, x, y, z)
end

function RoleText:SetBuffImage(abName, res)
    if not self.buff_img then
        local go = PreloadManager:GetInstance():CreateWidget("system", "EmptyImage")
        local transform = go.transform
        transform:SetParent(self.transform)
        SetLocalPosition(transform, 0, 50, 0)
        SetLocalScale(transform, 1, 1, 1)
        SetSizeDelta(transform, 50, 50)
        transform.name = "buff_img"
        local img = transform:GetComponent('Image')
        self.buff_img = { transform = transform, gameObject = go, img = img }
    end
    local function callBack(sprite)
        if self.is_dctored or self.__is_clear then
            return
        end
        if not self.is_buff_visible then
            SetVisible(self.buff_img.transform, false)
            return
        end
        self.buff_img.img.sprite = sprite
        -- 算位置
    end
    SetVisible(self.buff_img.transform, true)
    self.is_buff_visible = true
    lua_resMgr:SetImageTexture(self, self.buff_img.img, abName, res, false, callBack)
end

function RoleText:HideBuffImage()
    self.is_buff_visible = false
    if not self.is_dctored and self.buff_img then
        SetVisible(self.buff_img.transform, false)
    end
end
--进阶副本的特殊操作
function RoleText:ShowAdvanceItem()
    if not self.advanceitem then
        self.advanceitem = AdvanceDungeonItem(self.transform);
    end
end

function RoleText:UpdateSliencePos(pos)
    if self.advanceitem then
        self.advanceitem:UpdateSliencePos(pos);
    end
end

function RoleText:ShowDef(bool)
    if self.advanceitem then
        self.advanceitem:ShowDef(bool);
    end
end

function RoleText:ShowDes(bool, text)
    if self.advanceitem then
        self.advanceitem:ShowDes(bool, text);
    end
end

function RoleText:ShowLock(bool)
    if self.advanceitem then
        self.advanceitem:ShowLock(bool);
    end
end

function RoleText:ShowSlience(bool)
    if self.advanceitem then
        self.advanceitem:ShowSlience(bool);
    end
end

-- function RoleText:SetVisible(flag)
--     RoleText.super.SetVisible(self,flag)
--     if AppConfig.Debug then
--         if not flag then
--             Yzprint('--LaoY RoleText.lua,line 402--',data)
--             traceback()
--         end
--     end
-- end

-- 刷新机甲护盾
function RoleText:UpdateMachineArmorShield(value,origin)
    if not self.machine_armor_shield then
        self.machine_armor_shield = MachineArmorShield(self.transform)
        self.machine_armor_shield:SetPosition(0,-22)
    end
    self.machine_armor_shield:UpdateBar(value,origin)
end

function RoleText:RemoveMachineArmorShield()
    if self.machine_armor_shield then
        self.machine_armor_shield:destroy()
        self.machine_armor_shield = nil
        Yzprint('--LaoY RoleText.lua,line 447--',data)
        traceback()
    end
end