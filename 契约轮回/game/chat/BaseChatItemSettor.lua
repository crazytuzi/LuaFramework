--
-- @Author: chk
-- @Date:   2018-09-05 11:59:36
--

BaseChatItemSettor = BaseChatItemSettor or class("BaseChatItemSettor", BaseItem)
local BaseChatItemSettor = BaseChatItemSettor

function BaseChatItemSettor:ctor(parent_node, layer)
    self.is_readed = false
    self.height = 0
    self.y = 0
    self.countTemp = 0
    self.model = ChatModel.GetInstance()
    self.need_load_end = false
    self.chatMsg = nil
    self.itemBG = nil
    self.schedule_id = nil
    self.events = {}
    self.msg_bg_id = 0
    self.is_self = false           --是否是自己的对话
    self.middle_pos_x = 226        --聊天框的中线位置
end

function BaseChatItemSettor:__clear()
    BaseChatItemSettor.super.__clear(self)
end

function BaseChatItemSettor:__reset(...)
    BaseChatItemSettor.super.__reset(self, ...)
    SetSizeDelta(self.TextRectTra, self.old_sizedeltaX, self.old_sizedeltaY, 0)
    SetSizeDelta(self.TextRectTra2, self.old_sizedeltaX2, self.old_sizedeltaY2, 0)
    SetSizeDelta(self.NameRectTra, self.old_name_sizedeltaX, self.old_name_sizedeltaY, 0)
    SetLocalScale(self.transform, 1, 1, 1)
end

function BaseChatItemSettor:dctor()
    if self.bg_change_event_id then
        GlobalEvent:RemoveListener(self.bg_change_event_id)
        self.bg_change_event_id = nil
    end
    if self.ChatItemScp ~= nil then
        self.ChatItemScp:CleanText("")
    end
    if self.lua_link_text ~= nil then
        self.lua_link_text:destroy()
        self.lua_link_text = nil
    end
    if self.lua_link_text2 ~= nil then
        self.lua_link_text2:destroy()
        self.lua_link_text2 = nil
    end
    if self.role_icon then
        self.role_icon:destroy()
        self.role_icon = nil
    end
    if self.tipView then
        self.tipView:destroy()
        self.tipView = nil
    end
    --[[if self.inlineText ~= nil and self.inlineText.inlineManager ~= nil then
        self.inlineText.inlineManager:CleanMesh()
    end--]]
    GlobalSchedule:Stop(self.schedule_id)
    self.model:RemoveTabListener(self.events)
    self.events = nil

    if self.action then
        cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.voicebg)
        self.action = nil
    end
    if self.action2 then
        cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.saizi_img)
        self.action2 = nil
    end
    if self.saizi_schedule_id then
        GlobalSchedule:Stop(self.saizi_schedule_id)
        self.saizi_schedule_id = nil
    end
end

function BaseChatItemSettor:LoadCallBack()
    --SetVisible(self,false)
    self.nodes = {
        "roleInfo/icon",
        "roleInfo/Sex",
        "roleInfo/lv/lvValue",
        "roleInfo/channel",
        "Info/vip",
        "Info/name",
        "msgbg",
        "msgbg/Text",
        "msgbg/Text2",
        "voiceMsgbg",
        "voiceMsgbg/voiceText",
        "TextTemp",
        "saiziBG",
        "saiziBG/saizi",
        "roleInfo/lv/Image",
        "voiceMsgbg/voicebg",
        "Info/zone",
        "saiziBG/saizi_img",
    }
    self:GetChildren(self.nodes)
    self:AddEvent()
    self.itemRectTra = self.transform:GetComponent('RectTransform')
    self.msgBGImg = self.msgbg:GetComponent('Image')
    self.msg_bg_group = self.msgbg:GetComponent('HorizontalLayoutGroup')
    self.vipTxt = self.vip:GetComponent('Text')
    self.nameTxt = self.name:GetComponent('Text')
    self.NameRectTra = self.name:GetComponent('RectTransform')
    self.old_name_sizedeltaX = GetSizeDeltaX(self.NameRectTra)
    self.old_name_sizedeltaY = GetSizeDeltaY(self.NameRectTra)
    self.lvTxt = self.lvValue:GetComponent('Text')
    self.TextRectTra = self.Text:GetComponent('RectTransform')
    self.TextRectTra2 = self.Text2:GetComponent('RectTransform')
    self.old_sizedeltaX = GetSizeDeltaX(self.TextRectTra)
    self.old_sizedeltaY = GetSizeDeltaY(self.TextRectTra)
    self.old_sizedeltaX2 = GetSizeDeltaX(self.TextRectTra2)
    self.old_sizedeltaY2 = GetSizeDeltaY(self.TextRectTra2)
    self.TextTempTxt = self.TextTemp:GetComponent('Text')
    self.lv_bg = GetImage(self.Image)
    self.Sex = GetImage(self.Sex)
    self.voiceText = GetText(self.voiceText)
    if self.voicebg then
        self.voicebg = GetImage(self.voicebg)
    end

    if self.channel ~= nil then
        self.channelImg = self.channel:GetComponent('Image')
    end
    --self:InitChatItemScp()

    if self.need_load_end then
        self:SetInfo(self.chatMsg, self.scrollRect)
    end
end

function BaseChatItemSettor:AddEvent()
    local function call_back()
        if self.action then
            cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.voicebg)
            self.action = nil
            lua_resMgr:SetImageTexture(self, self.voicebg, 'common_image', 'com_voice_bg_3', true)
        end
        SoundManager.GetInstance():SetBackGroundMute(true)
        VoiceManager:GetInstance():StopPlayFile()
    end
    self.events[#self.events + 1] = self.model:AddListener(ChatEvent.StopVoiceAnimation, call_back)

    local function callback(bg_id)
        if not self.chatMsg.sender then
            return
        end
        local role_id = self.chatMsg.sender.id
        local self_id = RoleInfoModel.GetInstance():GetMainRoleId()
        if self_id ~= role_id or bg_id == self.msg_bg_id then
            return
        end
        self.msg_bg_id = bg_id
        lua_resMgr:SetImageTexture(self, self.msgBGImg, "iconasset/icon_chatframe", bg_id, true, nil, false)
        self:UpdateFrameShow(true)
    end
    self.bg_change_event_id = GlobalEvent:AddListener(ChatEvent.UpdateChatFrame, callback)
end

function BaseChatItemSettor:ClickItemEvent(name, id)
    if string.find(id, "team_id") ~= nil then
        local teamTbl = string.split(id, "=")
        if table.nums(teamTbl) == 2 then
            TeamController:GetInstance():RequestApply(teamTbl[2])
        end
    elseif string.find(id, "mapPos") ~= nil then
        self.model.mapPositionTbl = string.split(name, ",")
        local mapPosTbl = string.split(id, "_")
        if table.nums(self.model.mapPositionTbl) == 2 then
            local targetX = tonumber(self.model.mapPositionTbl[1]) * SceneConstant.BlockSize.w
            local targetY = tonumber(self.model.mapPositionTbl[2]) * SceneConstant.BlockSize.h
            local sceneId = SceneManager.Instance:GetSceneId()
            self.model.targetSceneId = tonumber(mapPosTbl[2])
            if sceneId == self.model.targetSceneId then
                OperationManager.GetInstance():TryMoveToPosition(self.model.targetSceneId, nil, Vector2(targetX, targetY))
            elseif SceneConfigManager:GetInstance():CheckEnterScene(sceneId, true) then
                local sceneCfg = Config.db_scene[self.model.targetSceneId]
                if sceneCfg.type == enum.SCENE_TYPE.SCENE_TYPE_CITY or sceneCfg.type == enum.SCENE_TYPE.SCENE_TYPE_FIELD then
                    OperationManager.GetInstance():TryMoveToPosition(self.model.targetSceneId, nil, Vector2(targetX, targetY))
                elseif sceneCfg.type == enum.SCENE_TYPE.SCENE_TYPE_BOSS then
                    SceneControler:GetInstance():RequestSceneChange(self.model.targetSceneId, enum.SCENE_CHANGE.SCENE_CHANGE_BOSS,
                            { x = targetX, y = targetY }, nil, 0)
                elseif sceneCfg.type == enum.SCENE_TYPE.SCENE_TYPE_ACT then
                    SceneControler:GetInstance():RequestSceneChange(self.model.targetSceneId, enum.SCENE_CHANGE.SCENE_CHANGE_ACT,
                            { x = targetX, y = targetY }, nil, 0)
                end
            end
        end
    else
        ChatController.GetInstance():RequestGoodsInfo(tonumber(id))
    end
end

function BaseChatItemSettor:InitChatItemScp()
    self.Text2 = GetLinkText(self.Text2)
    self.inlineText = GetLinkText(self.Text)--self.Text:GetComponent('InlineText')
    --self.inlineText.inlineManager = self.model.inlineManagerScps[self.chatMsg.channel_id]
    --self.ChatItemScp = self.gameObject:GetComponent('ChatItem')
    --self.ChatItemScp.inlineText = self.inlineText
    --self.ChatItemScp.itemRect = self.itemRectTra
    --self.ChatItemScp.itemBgRect = self.msgBGImg:GetComponent('RectTransform')

    --self.inlineText:AddClickListener(handler(self, self.ClickItemEvent))
end

function BaseChatItemSettor:SetData(data)

end

function BaseChatItemSettor:CheckSetNormalizedPosition()
    self.scrollRect.normalizedPosition = Vector2(self.scrollRect.normalizedPosition.x, 0)
end

function BaseChatItemSettor:CaculateItemsHeight()

end

function BaseChatItemSettor:SetMatchGoodLink(info)
    --local mathStr = "<a href=([^>\n\s]+#[^>\n\s]+)>(.*?)(</a>)"
    --for k,v in string.format(info,mathStr) do
    --    local kk = k
    --    local vv = v
    --end
end

function BaseChatItemSettor:SetRoleInfo(role, channel_id, scene)
    if self.channelImg ~= nil then
        if channel_id == ChatModel.AreaChannel and Config.db_area_scene[scene] ~= nil then
            lua_resMgr:SetImageTexture(self, self.channelImg, "chat_image", "chat_cng_" .. Config.db_area_scene[scene].icon, true)
        elseif channel_id == enum.CHAT_CHANNEL.CHAT_CHANNEL_QUESTION and Config.db_area_scene[scene] ~= nil then
            lua_resMgr:SetImageTexture(self, self.channelImg, "chat_image", "chat_cng_" .. Config.db_area_scene[scene].icon, true)
        else
            lua_resMgr:SetImageTexture(self, self.channelImg, "chat_image", "chat_cng_" .. channel_id, true)
        end

    end

    if role then
        local buble = 120000
        local role_id = role.id
        local is_fake = faker.GetInstance():is_fake(role_id)
        if is_fake then
            local opdays = LoginModel.GetInstance():GetOpenTime()
            local cf = Config.db_robot_deco[opdays]
            if cf then
                local bubble_list = String2Table(cf.frame)
                local list_num = #bubble_list
                local idx = math.random(list_num)
                buble = bubble_list[idx] or buble
            end
        else
            buble = role.icon.bubble == 0 and 120000 or role.icon.bubble
        end
        self.msg_bg_id = buble
        if buble == 120000 and (not self.is_self) then
            lua_resMgr:SetImageTexture(self, self.msgBGImg, "chat_image", "chat_msg_bg_l", true, nil, false)
        else
            lua_resMgr:SetImageTexture(self, self.msgBGImg, "iconasset/icon_chatframe", buble, true, nil, false)
        end
        self:UpdateFrameShow()
        --self.channelTextTxt.text = ConfigLanguage.Chat[chatMsg.channel_id]
        --[[if role.gender == 1 then
            self.nameTxt.text = "<color=#2E7299>" .. tostring(role.name) .. "</color>"
        else
            self.nameTxt.text = "<color=#B23636>" .. tostring(role.name) .. "</color>"
        end--]]
        if role.gender == 1 then
            --lua_resMgr:SetImageTexture(self, self.lv_bg, 'common_image', 'com_circle_boy', true)
            lua_resMgr:SetImageTexture(self, self.Sex, 'common_image', 'sex_icon_1', true)
        else
            --lua_resMgr:SetImageTexture(self, self.lv_bg, 'common_image', 'com_circle_girl', true)
            lua_resMgr:SetImageTexture(self, self.Sex, 'common_image', 'sex_icon_2', true)
        end
        local level = role.level or 0
        SetTopLevelImg(level, self.lv_bg, self, self.lvTxt)
        self.nameTxt.text = role.name
        self.vipTxt.text = string.format(ConfigLanguage.Common.Vip, role.viplv)
        if channel_id == ChatModel.AreaChannel and ChatController:GetInstance():IsCrossScene() then
            if self.zone then
                SetVisible(self.zone, true)
                self.zone_txt = GetText(self.zone)
                self.zone_txt.text = string.format("s%s", role.zoneid)
            end
        else
            if self.zone then
                SetVisible(self.zone, false)
            end
        end

        --self.lvTxt.text = tostring(role.level or 0)
        local function call_back()
            if RoleInfoModel:GetInstance():GetMainRoleId() ~= self.chatMsg.sender.id then
                local panel = lua_panelMgr:GetPanelOrCreate(RoleMenuPanel, self.icon, self.layer)
                panel:Open(self.chatMsg.sender, nil, self.chatMsg.channel_id)
            else
                Notify.ShowText("This is yourself")
            end
        end
        if not self.role_icon then
            self.role_icon = RoleIcon(self.icon)
        end
        local param = {}
        param['is_can_click'] = true
        param['click_fun'] = call_back
        param["is_squared"] = true
        --param["is_hide_frame"] = true
        param["size"] = 55
        param["role_data"] = role
        self.role_icon:SetData(param)
    end
end

--播放语音动画
function BaseChatItemSettor:PlayVoiceAnimate(time)
    time = tonumber(time)
    self.sprite_list = self.sprite_list or {}
    local last_sprite_index = 3
    local delayperunit = 0.2
    local loop_count = 3
    local function start_action()
        if self.action then
            cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.voicebg)
            self.action = nil
        end
        local action = cc.Animate(self.sprite_list, time, self.voicebg, last_sprite_index, delayperunit, loop_count)
        cc.ActionManager:GetInstance():addAction(action, self.voicebg)
        self.action = action
    end

    local function call_back(objs)
        self.sprite_list[#self.sprite_list + 1] = objs[0]
        if #self.sprite_list >= 3 then
            start_action()
        end
    end
    if #self.sprite_list == 0 then
        for i = 1, 3 do
            lua_resMgr:LoadSprite(self, 'common_image', 'com_voice_bg_' .. i, call_back)
        end
    else
        start_action()
    end
end

function BaseChatItemSettor:SetInfo(chatMsg, scrollRect)
    self.scrollRect = scrollRect
    self.chatMsg = chatMsg
    local role = chatMsg.sender
    if self.is_loaded then

        self:SetRoleInfo(role, chatMsg.channel_id, chatMsg.scene)

        if self.chatMsg.type_id == 0 then

            local saiziNum = string.match(chatMsg.content, "Ako(%d)Ako")
            local redenvelope = string.match(chatMsg.content, "redenvelope")
            if saiziNum ~= nil and self.saizi ~= nil then
                --是否骰子
                SetVisible(self.saiziBG.gameObject, true)
                SetVisible(self.voiceMsgbg.gameObject, false)
                SetVisible(self.msgbg.gameObject, false)
                SetVisible(self.saizi_img, true)
                self.saizi_img = GetImage(self.saizi_img)
                --self:SetRoleInfo(chatMsg.sender, chatMsg.channel_id)
                --[[self.link_text = GetLinkText(self.saizi)
                if not self.lua_link_text then
                    self.lua_link_text = LuaLinkImageText(self, self.link_text, nil, handler(self, self.TextCallFunc))
                end
                local str = ""
                if chatMsg.isHadSended then
                    --str = "<quad name=saizi:saizi_" .. saiziNum .. "},0.2," .. saiziNum .. ",0.03,1} size=87 width=1 />"
                    str = "<quad name=saizi:saizi_" .. saiziNum .. " size=87 width=1 />"
                else
                    local fianl_num = 9 + saiziNum
                    str = "<quad name=saizi:{{saizi_1_2,saizi_2_2,saizi_3_2,saizi_4_2,saizi_5_2,saizi_6_2,saizi_7_2,saizi_8_2,saizi_9_2,saizi_1,saizi_2,saizi_3,saizi_4,saizi_5,saizi_6},1," .. fianl_num .. ",0.1,9} size=87 width=1 />"
                end
                self.lua_link_text:clear()--]]
                --self.link_text.text = str
                if chatMsg.isHadSended then
                    --local res = string.format("saizi_%s", saiziNum)
                    self.saizi_img.sprite = ChatModel.GetInstance().saizi_list[saiziNum + 9]
                    --lua_resMgr:SetImageTexture(self,self.saizi_img, 'saizi_image', res)
                else
                    self:PlaySeziAnimate(saiziNum)
                end

                self:SetSaiZiItemSize()
            elseif redenvelope ~= nil then
                SetVisible(self.msgbg.gameObject, true)
                SetVisible(self.voiceMsgbg.gameObject, false)
                if self.saiziBG ~= nil then
                    SetVisible(self.saiziBG.gameObject, false)
                end
                self:InitChatItemScp()
                local content = ChatColor.FormatMsg(chatMsg.content)
                self.y = self.model:GetChannelItemsHeight(chatMsg.channel_id)
                self.itemRectTra.localPosition = Vector3(0, -self.y, 0)
                if not self.lua_link_text then
                    self.lua_link_text = LuaLinkImageText(self, self.inlineText, nil, handler(self, self.TextCallFunc))
                end
                self.lua_link_text:clear()
                local uid = 0
                for w in string.gmatch(content, "redenvelope_(%d+)") do
                    uid = w
                end
                self.inlineText.text = ChatColor.ReplaceChatPanelColor(string.format(ConfigLanguage.Faction.RedEnvelopeImage, uid))
                if not self.lua_link_text2 then
                    self.lua_link_text2 = LuaLinkImageText(self, self.Text2, nil, handler(self, self.TextCallFunc))
                end
                self.lua_link_text2:clear()
                self.Text2.text = ChatColor.ReplaceChatPanelColor(tostring(content))

                self:SetItemSize(role)
            else
                SetVisible(self.msgbg.gameObject, true)
                SetVisible(self.voiceMsgbg.gameObject, false)
                if self.saiziBG ~= nil then
                    SetVisible(self.saiziBG.gameObject, false)
                end

                self:InitChatItemScp()

                local ids = self.chatMsg.ids or {}
                local content = ChatColor.FormatMsg(self.chatMsg.content)
                for i, v in pairs(ids) do
                    content = string.gsub(content, i, v)
                end
                local emojis = {}
                for emojiName in string.gmatch(content, "【(e_%d+)】") do
                    local images = Config.db_emoji[emojiName].images
                    content = string.gsub(content, "【" .. emojiName .. "】", string.format("<quad name=emoji:%s size=36 width=1 />", images))
                end

                self.y = self.model:GetChannelItemsHeight(chatMsg.channel_id)
                self.itemRectTra.localPosition = Vector3(0, -self.y, 0)
                --self.ChatItemScp.Text = tostring(self.chatMsg.content)
                --self.inlineText.text = tostring(self.chatMsg.content)
                if not self.lua_link_text then
                    self.lua_link_text = LuaLinkImageText(self, self.inlineText, nil, handler(self, self.TextCallFunc))
                end
                self.lua_link_text:clear()
                self.lua_link_text:SetSprites(self.model.emoji_list)
                self.inlineText.text = ChatColor.ReplaceChatPanelColor(tostring(content))
                if not self.lua_link_text2 then
                    self.lua_link_text2 = LuaLinkImageText(self, self.Text2, nil, handler(self, self.TextCallFunc))
                end
                self.lua_link_text2:clear()
                self.Text2.text = ""

                self:SetItemSize(role)
            end
        elseif self.chatMsg.type_id == 2 then
            SetVisible(self.msgbg.gameObject, false)
            SetVisible(self.voiceMsgbg.gameObject, true)
            if self.saiziBG ~= nil then
                SetVisible(self.saiziBG.gameObject, false)
            end
            local voiceTbl = string.split(self.chatMsg.content, "@")
            self.voiceText.text = voiceTbl[3] .. "''"
            local function call_back()
                if table.nums(voiceTbl) >= 3 then
                    self.model:Brocast(ChatEvent.StopVoiceAnimation)
                    self:PlayVoiceAnimate(voiceTbl[3])
                    if self.model.mute_schedule then
                        GlobalSchedule:Stop(self.model.mute_schedule)
                        self.model.mute_schedule = nil
                    end
                    local function ok_func()
                        if not self.model.is_recording then
                            SoundManager.GetInstance():SetBackGroundMute(false)
                        end
                    end
                    self.model.mute_schedule = GlobalSchedule:StartOnce(ok_func, tonumber(voiceTbl[3]))
                    VoiceManager:GetInstance():DownloadRecordedFile(voiceTbl[1], voiceTbl[2], nil, false)
                end
            end
            AddClickEvent(self.voiceMsgbg.gameObject, call_back)
            self:SetVoiceItemSize()
        end
        self.need_load_end = false
    else
        self.need_load_end = true
    end
end

function BaseChatItemSettor:PlaySeziAnimate(num)
    time = 1
    local last_sprite_index = num + 9
    local delayperunit = 0.1
    local loop_count = 9
    local saizi_list = ChatModel.GetInstance().saizi_list
    local function start_action()
        if self.action then
            cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.saizi_img)
            self.action = nil
        end
        local action = cc.Animate(saizi_list, time, self.saizi_img, last_sprite_index, delayperunit, loop_count)
        cc.ActionManager:GetInstance():addAction(action, self.saizi_img)
        self.action2 = action
    end

    start_action()
    local function call_back()
        --local res = string.format("saizi_%s", num)
        --lua_resMgr:SetImageTexture(self,self.saizi_img, 'saizi_image', res)
        self.saizi_img.sprite = ChatModel.GetInstance().saizi_list[last_sprite_index]
    end
    self.saizi_schedule_id = GlobalSchedule:StartOnce(call_back, 1.1)
end

function BaseChatItemSettor:TextCallFunc(id)
    if string.find(id, "team") ~= nil then
        local teamTbl = string.split(id, "_")
        if table.nums(teamTbl) == 2 then
            TeamController:GetInstance():RequestApply(teamTbl[2])
        end
    elseif string.find(id, "mapPos") ~= nil then
        --self.model.mapPositionTbl = string.split(name, ",")
        local mapPosTbl = string.split(id, "_")
        if table.nums(mapPosTbl) == 4 then
            local targetX = tonumber(mapPosTbl[3]) * SceneConstant.BlockSize.w
            local targetY = tonumber(mapPosTbl[4]) * SceneConstant.BlockSize.h
            local sceneId = SceneManager.Instance:GetSceneId()
            self.model.targetSceneId = tonumber(mapPosTbl[2])
            if sceneId == self.model.targetSceneId then
                OperationManager.GetInstance():CheckMoveToPosition(self.model.targetSceneId, nil, { x = targetX, y = targetY })
            elseif SceneConfigManager:GetInstance():CheckEnterScene(sceneId, true) then
                local sceneCfg = Config.db_scene[self.model.targetSceneId]
                if sceneCfg.type == enum.SCENE_TYPE.SCENE_TYPE_CITY or sceneCfg.type == enum.SCENE_TYPE.SCENE_TYPE_FIELD then
                    OperationManager.GetInstance():CheckMoveToPosition(self.model.targetSceneId, nil, { x = targetX, y = targetY })
                elseif sceneCfg.type == enum.SCENE_TYPE.SCENE_TYPE_BOSS then
                    DungeonModel.GetInstance():SetTargetPos(targetX, targetY)

                    if sceneCfg.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_FISSURE then
                        --处理时空裂缝坐标跳转
                       self:HandleGotoSpacetimeCrack(self.model.targetSceneId,targetX,targetY)
                    else
                        SceneControler:GetInstance():RequestSceneChange(self.model.targetSceneId, enum.SCENE_CHANGE.SCENE_CHANGE_BOSS,
                        { x = targetX, y = targetY }, nil, 0)
                    end

                elseif sceneCfg.type == enum.SCENE_TYPE.SCENE_TYPE_ACT then
                    local act_id = ActivityModel:GetInstance():GetActId(self.model.targetSceneId)
                    if act_id == 0 then
                        act_id = sceneCfg.link_act
                    end
                    if sceneCfg.stype == enum.SCENE_STYPE.SCENE_STYPE_SIEGEWAR then
                        SiegewarModel.GetInstance():SetTargetPos(targetX, targetY)
                    end
                    SceneControler:GetInstance():RequestSceneChange(self.model.targetSceneId, enum.SCENE_CHANGE.SCENE_CHANGE_ACT,
                            { x = targetX, y = targetY }, nil, act_id)
                end
            end
        end
    elseif string.find(id, "redenvelope") ~= nil then
        local arr = string.split(id, "_")
        if table.nums(arr) == 2 then
            FPacketController.GetInstance():FPOperation(arr[2])
        end
    elseif string.find(id, "panel") ~= nil then
        local arr = string.split(id, "_")
        local params = string.split(arr[2], "@")
        for i, v in ipairs(params) do
            params[i] = tonumber(v)
        end
        --local params = String2Table(arr[2])
        OpenLink(unpack(params))
    elseif string.find(id, "role") ~= nil then
        local arr = string.split(id, "_")
        if RoleInfoModel:GetInstance():GetMainRoleId() == arr[2] then
            Notify.ShowText("This is yourself")
        else
            lua_panelMgr:GetPanelOrCreate(RoleMenuPanel, self.Text, "Bottom"):Open(nil, arr[2])
        end
    elseif string.find(id, "cache") ~= nil then
        local arr = string.split(id, "_")
        GoodsController:GetInstance():RequestQueryDropped(tonumber(arr[2]))
    elseif string.find(id, "guildlog") ~= nil then
        local arr = string.split(id, "_")
        self:HandleGuildLogItem(arr[2])
    elseif string.find(id, "item") ~= nil then
        local arr = string.split(id, "_")
        if table.nums(arr) == 2 then
            self:HandleItemBase(arr[2])
        end
    elseif string.find(id, "baby") ~= nil then
        local arr = string.split(id, "_")
        if table.nums(arr) == 2 then
            BabyController.GetInstance():RequstBabyLikeInfo(arr[2])
        end
    else
        local arr = string.split(id, "_")
        if table.nums(arr) == 2 then
            ChatController.GetInstance():RequestGoodsInfo(tonumber(arr[2]))
        end
    end
end

function BaseChatItemSettor:HandleItemBase(item_id)
    if not self.gameObject.activeInHierarchy then
        return
    end
    item_id = tonumber(item_id)
    local item_cfg = Config.db_item[item_id]

    local cfg = Config.db_item[item_id]
    if item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP then
        cfg = Config.db_equip[item_id]
    elseif item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP_BEAST then
        cfg = Config.db_beast_equip[item_id]
    end

    if item_cfg.tip_type == 1 then
        local _param = {}
        _param["cfg"] = cfg
        self.tipview = FashionTipView(self.transform)
        self.tipview:ShowTip(_param)
        return
    elseif item_cfg.tip_type == 11 or item_cfg.tip_type == 12 then
        local _param = {}
        _param["cfg"] = item_cfg
        self.tipview = FrameTipView(self.transform)
        self.tipview:ShowTip(_param)
        return
    elseif item_cfg.tip_type == 13 then
        local _param = {}
        _param["cfg"] = item_cfg
        self.tipview = MagicTipView(self.transform)
        self.tipview:ShowTip(_param)
        return
    end
    if item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP or
            item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP_BEAST then
        local puton_item = nil
        if not self.not_need_compare then
            puton_item = self.model:GetPutOn(self.item_id)
        end

        if puton_item ~= nil then
            local _param = {}
            _param["self_cfg"] = cfg
            _param["puton_item"] = puton_item
            _param["puton_cfg"] = self.model:GetConfig(puton_item.id)
            _param["model"] = self.model
            lua_panelMgr:GetPanelOrCreate(EquipComparePanel):Open(_param)
        else
            local _param = {}
            _param["cfg"] = cfg
            _param["model"] = self.model

            self.tipview = EquipTipView(self.transform)
            self.tipview:ShowTip(_param)
        end
    elseif (item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_MISC) and (item_cfg.stype == enum.ITEM_STYPE.ITEM_STYPE_PET) then
        local pos = self.transform.position
        self.tipview = PetShowTipView()

        self.tipview:SetData(item_cfg.id, PetModel.TipType.PetEgg, pos)
        --魂卡
    elseif item_cfg.stype == enum.ITEM_STYPE.ITEM_STYPE_MAGICCARD then
        local param = {}
        param["cfg"] = cfg
        param["model"] = self.model
        self.tipview = MagicCardView(self.transform)
        self.tipview:ShowTip(param)

    elseif item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_MISC and item_cfg.stype == enum.ITEM_STYPE.ITEM_STYPE_SOUL then

        --圣痕tip
        local param = {}
        param["cfg"] = cfg

        cfg.extra = 1  --圣痕合成界面的圣痕，视为1级圣痕

        --这几个得加上 不然会报错
        cfg.equip = {}
        cfg.equip.suite = {}
        cfg.equip.cast = 0
        param["p_item"] = cfg
        self.tipview = StigmataTipView(self.transform)
        self.tipview:ShowTip(param)

    elseif item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_MISC and (item_cfg.stype == enum.ITEM_STYPE.ITEM_STYPE_WING_MORPH
            or item_cfg.stype == enum.ITEM_STYPE.ITEM_STYPE_TALIS_MORPH
            or item_cfg.stype == enum.ITEM_STYPE.ITEM_STYPE_MOUNT_MORPH
            or item_cfg.stype == enum.ITEM_STYPE.ITEM_STYPE_WEAPON_MORPH
            or item_cfg.stype == enum.ITEM_STYPE.ITEM_STYPE_GOD_MORPH
            or item_cfg.stype == enum.ITEM_STYPE.ITEM_STYPE_OFFHAND_MORPH) then
        local pos = self.transform.position
        local _param = {}
        _param["cfg"] = cfg
        _param["basePos"] = pos
        _param["stype"] = item_cfg.stype;
        self.tipview = MountTipView(self.transform)
        self.tipview:ShowTip(_param)
    else
        local param = {}
        param["cfg"] = cfg
        self.tipview = GoodsTipView(self.transform)
        self.tipview:ShowTip(param)
    end
end

function BaseChatItemSettor:HandleGuildLogItem(index)
    local equipItem = FactionModel:GetInstance():GetLogItemByIndex(index)
    GlobalEvent:Brocast(ChatEvent.ChatGoodsInfo, equipItem.item)
end

function BaseChatItemSettor:SetItemSize(role)
    local span = 5
    if role then
        local buble = role.icon.bubble == 0 and 120000 or role.icon.bubble
        self.msg_bg_id = buble
        local show_cf = FrameShowConfig.ChatFrame[buble]
        if show_cf then
            span = show_cf.span
        end
    end
    local textHeight = self.inlineText.preferredHeight
    self.TextRectTra.sizeDelta = Vector2(self.inlineText.preferredWidth, textHeight)
    self.TextRectTra2.sizeDelta = Vector2(self.Text2.preferredWidth, textHeight)
    self.height = 85 + textHeight + span
    if self.chatMsg.sender == nil then
        self.height = 26 + textHeight
    end
    self.itemRectTra.sizeDelta = Vector2(self.itemRectTra.sizeDelta.x, self.height)

    GlobalEvent:Brocast(ChatEvent.CreateItemEnd, self.chatMsg, self.height)
end

function BaseChatItemSettor:SetSaiZiItemSize()
    self.height = 170

    self.itemRectTra.sizeDelta = Vector2(self.itemRectTra.sizeDelta.x, self.height)
    GlobalEvent:Brocast(ChatEvent.CreateItemEnd, self.chatMsg, self.height)
end

function BaseChatItemSettor:SetVoiceItemSize()
    self.height = 90

    self.itemRectTra.sizeDelta = Vector2(self.itemRectTra.sizeDelta.x, self.height)
    GlobalEvent:Brocast(ChatEvent.CreateItemEnd, self.chatMsg, self.height)
end

function BaseChatItemSettor:UpdateFrameShow(is_dont_need_change_span)
    local show_cf = FrameShowConfig.ChatFrame[self.msg_bg_id]
    if show_cf then
        --需要调整位置
        self.msg_bg_group.padding.top = show_cf.top or 0
        self.msg_bg_group.padding.bottom = show_cf.bottom or 0
        self.msg_bg_group.padding.left = show_cf.left or 0
        self.msg_bg_group.padding.right = show_cf.right or 0
        local x = show_cf.pos_x or 0
        --别人的对话
        if not self.is_self then
            local half_dis = x - self.middle_pos_x
            x = self.middle_pos_x - half_dis
        end
        local y = show_cf.pos_y or 0
        SetLocalPosition(self.msgbg.transform, x, y, 0)
        if not is_dont_need_change_span then
            self:ResetItemSpan(show_cf.span)
        end
    end
end

function BaseChatItemSettor:ResetItemSpan(span)
    if self.chatMsg.sender ~= nil then
        local textHeight = self.TextRectTra.sizeDelta.y
        self.height = 85 + textHeight + span
        self.itemRectTra.sizeDelta = Vector2(self.itemRectTra.sizeDelta.x, self.height)
        GlobalEvent:Brocast(ChatEvent.CreateItemEnd, self.chatMsg, self.height)
    end
end

--处理时空裂缝坐标点击
function BaseChatItemSettor:HandleGotoSpacetimeCrack( sceneid, targetX, targetY )

    --等级检测
    local level = RoleInfoModel:GetInstance():GetMainRoleLevel() or 1
    local scene_cfg = Config.db_scene[sceneid]
    local reqs = String2Table(scene_cfg.reqs)
    local condition_lv = reqs[1][2]

    if condition_lv > level then
        local scene_name = scene_cfg.name
        local lv_show = GetLevelShow(condition_lv)
        Notify.ShowText(string.format( "%s%s%s%s",scene_name,lv_show,ConfigLanguage.Mix.Level,ConfigLanguage.Mix.Open ))
    end

    --点击的是时空裂缝场景的坐标文本
    local vipLevel = RoleInfoModel:GetInstance():GetMainRoleVipLevel();
    local vipRightTab = Config.db_vip_rights[enum.VIP_RIGHTS.VIP_RIGHTS_SPATIOTEMPORAL_BOSS];
    local base = tonumber(vipRightTab.base);
    local added = tonumber(vipRightTab["vip" .. vipLevel]);
    local maxtime = base + added;
    local enterTimes = DungeonModel:GetInstance().spacetime_boss_list_info.enter;

    if (maxtime - enterTimes) <= 0 then
        Notify.ShowText(SpacetimeCrackDungePanel.EnterTimeTip);
        return;
    end

    local okFun = function()
        local sceneid = self.model.targetSceneId;
        local coord = { x = targetX, y = targetY };
        if sceneid then
            DungeonCtrl:GetInstance():RequestEnterWorldBoss(sceneid,coord.x,coord.y);
        end

        local panel = lua_panelMgr:GetPanel(DungeonSavageEntranceTicketPanel);
        if panel then
            panel:Close();
        end
    end

    local sceneConfig = Config.db_scene[sceneid];
    if sceneConfig then
        if sceneConfig.cost_type == 1 then
            local cost = String2Table(sceneConfig.cost);
            for k, v in pairs(cost) do
                local min = v[1];
                local max = v[2];

                if (enterTimes + 1) >= min and (enterTimes + 1) <= max then
                    local costItemTab = v[3][1];
                    if costItemTab then
                        local panel = lua_panelMgr:GetPanel(DungeonSavageEntranceTicketPanel);
                        if panel then
                            panel:Close();
                        end

                        lua_panelMgr:GetPanelOrCreate(DungeonSavageEntranceTicketPanel):Open({ call_back = okFun, itemID = costItemTab[1], num = costItemTab[2], sceneName = sceneConfig.name });
                        return ;
                    else
                        --Notify.ShowText("没有找到进入物品需求");
                    end
                end
            end
        else
           -- Notify.ShowText("cost_type不对,请检查");
           local costItemTab = String2Table(sceneConfig.cost)
            lua_panelMgr:GetPanelOrCreate(DungeonSavageEntranceTicketPanel):Open({ call_back = okFun, itemID = costItemTab[1][1], num = costItemTab[1][2], sceneName = sceneConfig.name });
        end
    else
        --Notify.ShowText("找不到场景配置");
        return ;
    end
end