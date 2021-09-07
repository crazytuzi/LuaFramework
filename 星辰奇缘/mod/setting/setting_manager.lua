--系统设置
-- @author zgs
SettingManager = SettingManager or BaseClass(BaseManager)

function SettingManager:__init()
    if SettingManager.Instance then
        Log.Error("")
        return
    end
    SettingManager.Instance = self
    self:initHandle()
    self.model = SettingModel.New()

    self.TMusic = "togglemusic" --音乐开关
    self.TVolume = "togglevolume" --音效开关
    self.TRefusingStrangers = "toggle_RefusingStrangers" --不接收陌生人切磋邀请
    self.THideEffect = "togglehideeffect_2017Christmas" --隐藏场景特效
    self.TAddFriend = "togglenotreceivefriendrequest" --不接收好友请求 // "toggleaddfriend" --好友验证
    self.THidePerson = "togglehideperson" --同屏
    self.THidePersonRide = "togglehidepersonride" --隐藏他人坐骑
    self.TTeamVoice = "toggleteamvoice" --队伍语音
    self.TGuildVoice = "togglemusicguildvoice" --公会语音
    self.TWorldVoice = "toggleworldvoice" --世界语音
    self.TTeamChannel = "toggleteamchannel" --队伍频道
    self.TSceneChannel = "togglescenechannel" --场景频道
    self.TWorldChannel = "toggleworldchannel" --世界频道
    self.TGuildchannel = "toggleguildchannel" --公会频道
    self.SliderMusic = "slidermusic" --音乐音量
    self.SliderVolume = "slidervolume" --音效音量
    self.SliderVoice = "slidervoice" --语音音量

    -- self:ClearPlayerPrefsSettingKey()
    self:InitSettingValue()

    self.checkShowNoticeFun = function ()
        self:checkShowNotice()
    end
    self.showUpdateNotice = false
    EventMgr.Instance:AddListener(event_name.mainui_loaded, self.checkShowNoticeFun)

    self.lockpanel = LockScreenPanel.New()
end

function SettingManager:ClearPlayerPrefsSettingKey()
    -- body
    PlayerPrefs.DeleteKey(self.TMusic)
    PlayerPrefs.DeleteKey(self.TVolume)

    PlayerPrefs.DeleteKey(self.TRefusingStrangers)
    PlayerPrefs.DeleteKey(self.THideEffect)
    PlayerPrefs.DeleteKey(self.TAddFriend)
    PlayerPrefs.DeleteKey(self.THidePerson)
    PlayerPrefs.DeleteKey(self.THidePersonRide)

    PlayerPrefs.DeleteKey(self.TTeamVoice)
    PlayerPrefs.DeleteKey(self.TGuildVoice)
    PlayerPrefs.DeleteKey(self.TWorldVoice)

    PlayerPrefs.DeleteKey(self.TTeamChannel)
    PlayerPrefs.DeleteKey(self.TSceneChannel)
    PlayerPrefs.DeleteKey(self.TWorldChannel)
    PlayerPrefs.DeleteKey(self.TGuildchannel)

    PlayerPrefs.DeleteKey(self.SliderMusic)
    PlayerPrefs.DeleteKey(self.SliderVolume)
    PlayerPrefs.DeleteKey(self.SliderVoice)
end

function SettingManager:GetResult(str,typeTemp)
    -- body
    if typeTemp == nil then
        if PlayerPrefs.GetInt(str) == 1 then --1是选中,不静音
            return true
        else
            return false
        end
    else
         return tonumber(PlayerPrefs.GetString(str,"0.5"))
    end
end

function SettingManager:InitSettingValue()
    -- body
    self:_initSettingValue(self.TMusic)
    self:_initSettingValue(self.TVolume)
    self:_initSettingValue(self.TRefusingStrangers)
    self:_initSettingValue(self.THideEffect)
    self:_initSettingValue(self.TAddFriend)
    self:_initSettingValue(self.THidePerson)
    self:_initSettingValue(self.THidePersonRide)
    self:_initSettingValue(self.TTeamVoice)
    self:_initSettingValue(self.TGuildVoice)
    self:_initSettingValue(self.TWorldVoice)
    self:_initSettingValue(self.TTeamChannel)
    self:_initSettingValue(self.TSceneChannel)
    self:_initSettingValue(self.TWorldChannel)
    self:_initSettingValue(self.TGuildchannel)

    self:_initSettingValue(self.SliderMusic,1)
    self:_initSettingValue(self.SliderVolume,1)
    self:_initSettingValue(self.SliderVoice,1)

    --初始化
    --音乐
    SoundManager.Instance:SetMusicIsCan(self:GetResult(self.TMusic))
    SoundManager.Instance:SetMusicValue(self:GetResult(self.SliderMusic,2))
    --音效
    SoundManager.Instance:SetVolumeIsCan(self:GetResult(self.TVolume))
    SoundManager.Instance:SetVolumeValue(self:GetResult(self.SliderVolume,2))

    -- 语音
    SoundManager.Instance:SetChatVolumeValue(self:GetResult(self.SliderVoice, 2))
    ChatManager.Instance.autoPlayWorld = self:GetResult(self.TWorldVoice)
    ChatManager.Instance.autoPlayTeam = self:GetResult(self.TTeamVoice)
    ChatManager.Instance.autoPlayGuild = self:GetResult(self.TGuildVoice)

    --场景特效
    -- SceneManager.Instance.MainCamera:set_effectmask(not SettingManager.Instance:GetResult(SettingManager.Instance.THideEffect))
    --不接收好友请求
    FriendManager.Instance.reject = SettingManager.Instance:GetResult(SettingManager.Instance.TAddFriend)
    --同屏人数屏蔽
    SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(SettingManager.Instance:GetResult(SettingManager.Instance.THidePerson))
    --隐藏他人坐骑
    SceneManager.Instance.sceneElementsModel:Show_OtherRole_Ride(SettingManager.Instance:GetResult(SettingManager.Instance.THidePersonRide))
end

function SettingManager:_initSettingValue(str,typeTemp)
    -- body
    if PlayerPrefs.HasKey(str) == false then
        if self.TMusic == str then
            self:SetResult(str,1,typeTemp)
        elseif self.TVolume == str then
            self:SetResult(str,1,typeTemp)
        elseif self.THideEffect == str then
            local systemMemorySize = SystemInfo.systemMemorySize
            if Application.platform == RuntimePlatform.IPhonePlayer and systemMemorySize >= 1536 then
                self:SetResult(str,0,typeTemp)
            elseif Application.platform == RuntimePlatform.Android and systemMemorySize >= 2560 then
                self:SetResult(str,0,typeTemp)
            else
                self:SetResult(str,1,typeTemp)
            end
        elseif self.TRefusingStrangers == str then
            self:SetResult(str,0,typeTemp)
        elseif self.TAddFriend == str then
            self:SetResult(str,0,typeTemp)
        elseif self.THidePerson == str then
            self:SetResult(str,1,typeTemp)
        elseif self.THidePersonRide == str then
            self:SetResult(str,1,typeTemp)
        elseif self.TTeamVoice == str then
            self:SetResult(str,1,typeTemp)
        elseif self.TGuildVoice == str then
            self:SetResult(str,1,typeTemp)
        elseif self.TWorldVoice == str then
            self:SetResult(str,0,typeTemp)
        elseif self.TTeamChannel == str then
            self:SetResult(str,1,typeTemp)
        elseif self.TSceneChannel == str then
            self:SetResult(str,1,typeTemp)
        elseif self.TWorldChannel == str then
            self:SetResult(str,1,typeTemp)
        elseif self.TGuildchannel == str then
            self:SetResult(str,1,typeTemp)
        elseif self.SliderMusic == str then
            self:SetResult(str,0.25,typeTemp)
        elseif self.SliderVolume == str then
            self:SetResult(str,0.5,typeTemp)
        elseif self.SliderVoice == str then
            self:SetResult(str, 0.7, typeTemp)
        end
    end
end

function SettingManager:SetResult(str,value,typeTemp)
    -- body
    if typeTemp == nil then
        PlayerPrefs.SetInt(str, value)
    else
        PlayerPrefs.SetString(str, tostring(value))
    end
end

function SettingManager:initHandle()
    --[[self:AddNetHandler(11300, self.on11300)--]]
    self:AddNetHandler(14700, self.on14700)

    EventMgr.Instance:AddListener(event_name.mainui_btn_init, function ()
    end)

--[[
    EventMgr.Instance:AddListener(event_name.role_asset_change, function ()
        self:RoleAssetsListener()
    end)--]]
end

function SettingManager:on14700(data)
    --BaseUtils.dump(data, "on14700")
    if data.flag == 1 then
        NoticeManager.Instance:FloatTipsByString(TI18N("你的问题/建议已经提交，GM很快回复你"))
        self.model.gaWin:CloseConnetPanel()
    else
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
end

function SettingManager:send14700(ct,qq)
    if ct then
        ct = string.gsub(ct, "<.->", "")
    end
    -- Log.Error(ct.."--"..qq.."=")
    Connection.Instance:send(14700, {content = ct,contact = qq})
end
--公告板列表，有更新公告，上线会推
function SettingManager:onAnnounceManager9920(data)
    -- Log.Error("------------------------")
    -- BaseUtils.dump(data,"SettingManager:onAnnounceManager9920")
    self.model.boardList = data.board_list
    if #self.model.boardList > 0 then
        self.model:SetUpdateNoticeRedPoint(true)
        if self.model.isFirstShow == true then
            --首次需要显示界面
            self.showUpdateNotice = true
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.setting_window,{2})
        end
    else
        --没有更新内容，请求历史公告列表
        AnnounceManager.Instance:send9924()
    end
    if self.model.isFirstShow == true then
        self.model.isFirstShow = false
    end
end
function SettingManager:checkShowNotice()
    -- Log.Error("SettingManager:checkShowNotice")
    -- print(self.showUpdateNotice)
    if self.showUpdateNotice == true then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.setting_window,{2})
    end
    EventMgr.Instance:RemoveListener(event_name.mainui_loaded, self.checkShowNoticeFun)
end
--新增公告,新增公告，推
function SettingManager:onAnnounceManager9921(data)
    -- Log.Error("------33333333333333333333------------------")
    -- BaseUtils.dump(data,"SettingManager:onAnnounceManager9921")
    table.insert(self.model.boardList,1)
    self.model:SetUpdateNoticeRedPoint(true)
end
--删除公告
function SettingManager:onAnnounceManager9922(data)
    for i,v in ipairs(self.model.boardList) do
        if v.id == data.id then
            table.remove(self.model.boardList,i)
        end
    end
end
--阅读公告/领取公告附件
function SettingManager:onAnnounceManager9923(data)

end
--历史公告板列表, 要主动查询
function SettingManager:onAnnounceManager9924(data)
    -- Log.Error("----------------2222222222222222--------")
    -- BaseUtils.dump(data,"SettingManager:onAnnounceManager9924")
    self.model.boardList = data.board_list
end
