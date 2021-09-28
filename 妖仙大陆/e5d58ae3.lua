

local ok, Machine = pcall(require, "Zeus.Logic.StateMachine")
local Helper = require 'Zeus.Logic.Helper'
local Util = require 'Zeus.Logic.Util'
local Quest = require 'Zeus.Model.Quest'
local Npc = require 'Zeus.Model.Npc'
local ItemModel = require 'Zeus.Model.Item'
local this = GlobalHooks.NpcTalkUI
local OnLink
local transitions = { }





























































































































local _M = { }
_M.__index = _M

local MAX_BUTTONS = 11
local MAX_QUEST_BUTTONS = 3
local MAX_FUNC_BUTTONS = 6

local CONDITION_FUNCBTN_ACCEPT = 1
local CONDITION_FUNCBTN_CAN_FINISH = 1
local toPlaySoundPath = nil

local LINK_TYPE =
{
    Main_Talk = 0,
    Quest_Select = 1,
    Quest = 2,
    Quest_Accept = 3,
    Quest_Complete = 4,
    Quest_Double_Complete = 5,
    Quest_Quick_Complete = 6,
    Quest_Continue = 7,
    Quest_Discard = 8,
    Quest_RefreshSoul = 9,
    Function_Select = 11,
    Function = 12,
    Npc_Story = 13,
    Function_Steal = 14,
    Dialog_Next = 20,
    Dialog_Skip = 21,
    Talk_Exit = 99,
}

local Text =
{
    costDiamond = "<f><a img='#static_n/static_pic/static001.xml,static001,88'>s</a>%d</f>",
    btn_accept = Util.GetText(TextConfig.Type.QUEST,'btn_accept'),
    btn_refuse = Util.GetText(TextConfig.Type.QUEST,'btn_refuse'),
    btn_complete = Util.GetText(TextConfig.Type.QUEST,'btn_complete'),
    btn_quick_complete = Util.GetText(TextConfig.Type.QUEST,'btn_quick_complete'),
    btn_double_complete = Util.GetText(TextConfig.Type.QUEST,'btn_double_complete'),
    btn_quest = Util.GetText(TextConfig.Type.QUEST,'btn_quest'),
    btn_trans = Util.GetText(TextConfig.Type.QUEST,'btn_trans'),
    btn_text_directly = Util.GetText(TextConfig.Type.QUEST,'btn_text_directly'),
    btn_continue = Util.GetText(TextConfig.Type.QUEST,'btn_continue'),
    btn_refreshsoul = Util.GetText(TextConfig.Type.QUEST,'btn_refresh'),
    quest_accept_title = "<a img='static_n/func/common2.xml/99'>s</a>%s",
    quest_complete_title = "<a img='static_n/func/common2.xml/9'>s</a>%s",
    num_format = '(%d)',
    icon_talk = '#static_n/func/maininterface.xml|maininterface|69',
    icon_normal_accept = '#static_n/func/maininterface.xml|maininterface|69',
    icon_normal_submit = '#static_n/func/maininterface.xml|maininterface|69',
    icon_daily_accept = '#static_n/func/maininterface.xml|maininterface|69',
    icon_daily_submit = '#static_n/func/maininterface.xml|maininterface|69',

}

local function Close()
    if this then
        this.cvs_2dmod.Visible = false
        this.showActorType = nil
        this.showNpcData = nil
        if this then
            this.fsm:Close()
        end
        this.isClose = true
        this.cvs_talk.Visible = true
        this.btn_close.Visible = true
        this.menu:Close()



        
        EventManager.Fire("Event.PauseSceneTouch",{})
    end
end

local function PushNpcData(e)
    table.insert(this.npc_datas, e)
end

local function PeekNpcData()
    
    return this.npc_datas[#this.npc_datas]
end

local function PopNpcData()
    table.remove(this.npc_datas)
end

local function Clear3DAvatar()
    if this.avatar_show then
        UnityEngine.Object.DestroyObject(this.avatar_show.obj)
        IconGenerator.instance:ReleaseTexture(this.avatar_show.key)
        this.avatar_show = nil
    end
end

local function HideAllButtons()
    for i = 1, MAX_BUTTONS do
        local cvs = this['cvs_box' .. i]
        cvs.Visible = false
    end
    this.sp_func.Visible = false
    this.ib_up.Visible = false
    this.ib_down.Visible = false
    this.ib_funcbg.Visible = false
end

local function SetBustPic(npc_data,type)
     if(this.showActorType == type) then
         if type == "npc" then
              local npcID = npc_data:GetStringParam("NpcID")
              if npcID == this.showNpcID then
                  if this.curAction == AnimationAction.Action.NIDLE then
                      local function callback()
                          this.curAction = AnimationAction.Action.NIDLE
                          IconGenerator.instance:PlayUnitAnimation(this.curKey, 'n_idle', WrapMode.Loop, -1, 1, 0, nil, 0)
                      end
                      IconGenerator.instance:PlayUnitAnimation(this.curKey, 'n_talk', WrapMode.Once, -1, 1, 0, callback, 0)
                      this.curAction = AnimationAction.Action.INTERACTIVE
                  else
                      return
                  end  
              end
         else
            return
         end
     end
     Clear3DAvatar()
     this.showActorType = type
     local cvs = this.ib_portrait
     if this.showActorType == "player" then
        cvs = this.ib_biggerportrait
     end

     local avatarMode = 'wing'
     local ModelFile = ''
     local filter = bit.lshift(1, GameUtil.TryEnumToInt(XmdsAvatarInfo.XmdsAvatar.Ride_Equipment))  
     local avatarFile = ''
     local trans_str = '1,0.12,-1.4,3.16'
     local rotationY = "166"  
     local pro = DataMgr.Instance.UserData.Pro
     if pro == 1 then
        trans_str = '1,0.12,-1.4,3.16'
        rotationY = "166"
     elseif pro == 3 then
        trans_str = '1,0.17,-1.39,2.68'
        rotationY = "179"
     end
     this.showNpcID = nil
     if npc_data then
        ModelFile = npc_data:GetStringParam('ModelFile')
        if (ModelFile == nil) then

        else
            avatarFile = '/res/unit/Monster/' ..(ModelFile or '') .. '.assetBundles'
            avatarMode = ''
            trans_str = npc_data:GetStringParam('Coord')
            rotationY = nil
            filter = 0
        end
        this.showNpcID = npc_data:GetStringParam("NpcID")
    end
    local obj, key = GameUtil.Add3DModel(cvs, avatarFile, nil, avatarMode, filter, true)
    this.curKey = key
    IconGenerator.instance:SetCameraParam(key, 0.01, 10, 3)
    if rotationY then
        IconGenerator.instance:SetRotate(key, Vector3.New(5, tonumber(rotationY), 360))
    end
    if npc_data then
        local function callback()
            this.curAction = AnimationAction.Action.NIDLE
            IconGenerator.instance:PlayUnitAnimation(key, 'n_idle', WrapMode.Loop, -1, 1, 0, nil, 0)
        end
        IconGenerator.instance:SetLoadOKCallback(key, function(k)
            IconGenerator.instance:PlayUnitAnimation(key, 'n_talk', WrapMode.Once, -1, 1, 0, callback, 0)
            this.curAction = AnimationAction.Action.INTERACTIVE
           
        end )
    else
        IconGenerator.instance:PlayAnimation(key, AnimationAction.Action.NIDLE)
    end
    local rect = obj:GetComponent('RectTransform')
    local scale = 1
    local model_trans = string.split(trans_str, ',')
    if trans_str and trans_str ~= '' then
        scale = tonumber(model_trans[1])
        IconGenerator.instance:SetModelScale(key, Vector3.New(scale, scale, scale))
        if #model_trans >= 4 then
            local pos = Vector3.New(tonumber(model_trans[2]), tonumber(model_trans[3]), tonumber(model_trans[4]))
            IconGenerator.instance:SetModelPos(key, pos)
        end
    end
    if this.showActorType == "player" then
        local selfPro = DataMgr.Instance.UserData.Pro
        if selfPro == 1 then 
            IconGenerator.instance:SetModelPos(key, Vector3.New(-0.56, -1.58, 3.2))
        elseif selfPro == 3 then 
            IconGenerator.instance:SetModelPos(key, Vector3.New(-0.56, -1.54, 3.2))
            IconGenerator.instance:SetRotate(key, Vector3.New(5, 162, 0))
        elseif selfPro == 5 then 
            IconGenerator.instance:SetModelPos(key, Vector3.New(-0.5, -1.38, 3))
        end
        IconGenerator.instance:SetLight(0.5,255,255,200,70,330)
    else
        IconGenerator.instance:SetLight(1,255,255,200,70,330)
    end
    
    this.avatar_show = { obj = obj, key = key }
end

local function SetButtonEvent(cvs, link_type, index)
    local btn_box = cvs:FindChildByEditName('btn_box', false)
    btn_box.TouchClick = function(sender)
        this.dialog_next_index = cvs.UserTag
        DataMgr.Instance.QuestManager.autoControl.IsAuto = false
        OnLink(link_type, index)
    end
end

local function FillItem(cvs, txt, icon_path)
    
    if not cvs then return end
    local lb_name = cvs:FindChildByEditName('lb_name', true)
    local ib_smallicon = cvs:FindChildByEditName('ib_smallicon', true)
    lb_name.Text = txt
    
    if icon_path then
        Util.HZSetImage(ib_smallicon, icon_path)
    end
    ib_smallicon.Visible =(icon_path ~= nil)
    cvs.Visible = true
    return lb_name, ib_smallicon
end


local function ShowSelf()
    this.cvs_2dmod.Visible = false
    
    SetBustPic(nil, "player")
    
    local userdata = DataMgr.Instance.UserData
    local lv = tonumber(userdata:GetAttribute(UserData.NotiFyStatus.LEVEL))
    local name = DataMgr.Instance.UserData.Name
    lv = Util.GetText(TextConfig.Type.PUBLICCFG, 'LongLv.n', lv)
    
    this.tb_npcname.UnityRichText = name
end

local function ShowNpc(npc_data)
    if (npc_data.TempalteID == 0) then
        this.cvs_2dmod.Visible = true
        return
    else
        this.cvs_2dmod.Visible = false
    end
    
    SetBustPic(npc_data, "npc")
    
    local title = npc_data:GetStringParam('Title')
    local lv = Util.GetText(TextConfig.Type.PUBLICCFG, 'LongLv.n', npc_data.Level)
    local npcName = npc_data.Name
    if npcName == nil then
        print("npc_data.TempalteID = "..npc_data.TempalteID)
        local prop = GlobalHooks.DB.Find('NpcList', npc_data.TempalteID)
        npcName = prop.Name
    end

    
    local name = string.format("<f bcolor='ff000000'><name color='ffddf2ff'>%s</name></f>", npcName)
    this.tb_npcname.UnityRichText = name
end

local function ParseDialogContent(str)
    local content = string.gsub(str or '', '%%name', DataMgr.Instance.UserData.Name)
    local tmps = string.split(content, ':')
    local npc_tempid = nil
    if #tmps == 2 then
        npc_tempid = tonumber(tmps[1])
        content = tmps[2]
    end
    return content, npc_tempid
end

local soundNpcPath = "/res/sound/dynamic/npc/%s.assetbundles"
local soundRolePath = "/res/sound/dynamic/role/%s.assetbundles"
local function SetDialogText(str,notPlaySound)
    
    this.tb_talk.Visible = true
    this.cvs_mission_npc.Visible = false

    local content, npc_tempid = ParseDialogContent(str or '')
    
    local talks = string.split(content, '#')
    this.tb_talk.UnityRichText = string.format("<f>%s</f>", talks[1])
    if notPlaySound == nil and #talks > 1 then
        local a = string.sub(talks[2],string.len(talks[2]),string.len(talks[2]))
        local path = nil
        if(a == "_") then
            local pro = DataMgr.Instance.UserData.Pro
            talks[2] = talks[2]..pro
            path = string.format(soundRolePath,talks[2])    
        else
            path = string.format(soundNpcPath,talks[2])
        end
        GlobalHooks.playTalkVoice(path)





    end
    this.tb_talk.Visible = true
    if npc_tempid then
        if npc_tempid == 0 then
            
            ShowSelf()
        else
            local npc_data = DataMgr.Instance.NPCManager:GetNPCByTemplateID(npc_tempid)
            ShowNpc(npc_data)
        end
    else
        ShowNpc(PeekNpcData())
    end
end


local function CleanDialog()
    if not this.dialog then return end
    ShowNpc(PeekNpcData())
    local str = PeekNpcData():GetStringParam('Dialog')
    if str and string.len(str) > 0 then
        SetDialogText(str,true)
    end
    this.dialog = nil
    this.touch_type = LINK_TYPE.Talk_Exit
    this.btn_close.Visible = false
end

local function NextDialog(notPlaySound)
    if not this.dialog then return end
    local dlg = this.dialog
    local txt = dlg.text[1]
    if txt then
        SetDialogText(txt,notPlaySound)
        table.remove(dlg.text, 1)
        if #dlg.text == 0 then
            
            if dlg.last_cb then
                dlg.last_cb()
            else
                
                local pos = this.dialog_next_index or MAX_BUTTONS
                local cvs = this['cvs_box' .. pos]
                FillItem(cvs, this.btn_continue_text, Text.icon_talk)
                if dlg.complete then
                    SetButtonEvent(cvs, LINK_TYPE.Quest_Complete,dlg.completeIndex)
                else
                    SetButtonEvent(cvs, LINK_TYPE.Dialog_Next)
                end
                
            end
        else
            if dlg.progress_cb then
                dlg.progress_cb()
            else
                
                local pos = this.dialog_next_index or MAX_BUTTONS
                local cvs = this['cvs_box' .. pos]
                FillItem(cvs, this.btn_continue_text, Text.icon_talk)
                SetButtonEvent(cvs, LINK_TYPE.Dialog_Next)
            end
        end
    elseif dlg.end_cb then
        CleanDialog()
        
        if dlg.end_cb then
            dlg.end_cb()
        end
    end
end

local function EndDialog()
    if not this.dialog then Close() return end
    local txtLen = #this.dialog.text
    while txtLen >= 0 do
        NextDialog(true)
        txtLen = txtLen - 1
    end
end

local function AutoQuestNpcTalk()
    if not this.dialog then Close() return end
    local txtLen = #this.dialog.text
    if txtLen >= 0 then
        local fa = DelayAction.New()
        fa.Duration = 1
        fa.ActionFinishCallBack = function(sender)
            if not DataMgr.Instance.QuestManager.autoControl.IsAuto then
                return
            end
            NextDialog()
            if txtLen == 0 then
                local npcid = PeekNpcData().ObjID
                local q = this.quests[1]
                if q ~= nil and q.State == QuestData.QuestStatus.CAN_FINISH then
                    local kind = q:GetIntParam("Kind")
                    Pomelo.TaskHandler.submitTaskRequest(q.TemplateID, kind, 0, tostring(npcid), function(ex, sjson)
                        print("提交任务成功  q.TemplateID = " .. q.TemplateID)
                        this.quests[1] = nil
                        Close()
                    end )
                end
            else
                AutoQuestNpcTalk()
            end
        end
        this.menu:AddAction(fa)
    end
end

local function SetDialog(dlg)
    local fa = DelayAction.New()
    fa.Duration = 0.03
    fa.ActionFinishCallBack = function(sender)
        HideAllButtons()
        this.touch_type = LINK_TYPE.Dialog_Next
        this.dialog = dlg
        NextDialog()
        
        if(this.quests and #this.quests > 0) then
            local quest = this.quests[1]
            if quest == DataMgr.Instance.QuestManager.autoControl.AutoQuest and quest.Type == QuestData.QuestType.DAILY  then
                AutoQuestNpcTalk()
            end
        end
    end
    this.menu:AddAction(fa)
end

local ui_names =
{
    { name = 'ib_yellow' },
    { name = 'ib_flag' },
    { name = 'ib_portrait' },
    { name = 'ib_biggerportrait' },
    { name = 'ib_reward1' },
    { name = 'ib_reward2' },
    { name = 'ib_reward3' },
    { name = 'ib_reward4' },
    { name = 'ib_gold' },
    { name = 'ib_exp' },
    { name = 'ib_diamond' },
    { name = 'ib_funcbg' },
    { name = 'ib_up' },
    { name = 'ib_down' },
    { name = 'cvs_missionbox' },
    { name = 'cvs_talk' },
    { name = 'cvs_bigportrait' },
    { name = 'cvs_portrait' },
    { name = 'cvs_box1' },
    { name = 'cvs_box2' },
    { name = 'cvs_box3' },
    { name = 'cvs_box4' },
    { name = 'cvs_box5' },
    { name = 'cvs_box6' },
    { name = 'cvs_box7' },
    { name = 'cvs_box8' },
    { name = 'cvs_box9' },
    { name = 'cvs_box10' },
    { name = 'cvs_box11' },
    { name = 'sp_func' },
    { name = 'cvs_mission_npc' },
    { name = 'cvs_reward' },
    { name = 'tb_npcname' },
    { name = 'lb_mission_title' },
    { name = 'lb_gift' },
    { name = 'lb_gold' },
    { name = 'lb_exp' },
    { name = 'ib_number' },
    {
        name = 'btn_close',
        click = function()
            
            EndDialog()

            
            
        end
    },
    { name = 'btn_test', click = Close },
    { name = 'btn_get' },
    { name = 'btn_refuse' },
    { name = 'tb_talk' },
    { name = 'tb_mission_target' },
    { name = 'tb_npc_talk' },
    { name = 'cvs_faqi' },
    { name = "cvs_2dmod" },
    { name = "cvs_3dmod" }
}


local function FillQuestDetail(index)
    this.dialog_next_index = nil
    local quest = this.quests[index]

    this.cvs_mission_npc.Visible = true
    this.cvs_2dmod.Visible = false
    this.tb_talk.Visible = false
    HideAllButtons()
    
    
    local progress = quest:GetFormatProgress(0) or ''
    if quest.State == QuestData.QuestStatus.CAN_FINISH then
        local argb = Util.GetQualityColorARGBStr(GameUtil.Quality_Green)
        progress = string.format("<f color='%s'>%s</f>", argb, progress)
    elseif quest.State == QuestData.QuestStatus.NEW then
        progress = ''
    end

    local target = quest:GetTargetString() .. progress
    this.tb_mission_target.UnityRichText = "<f bcolor='ff000000'>" .. target .. "</f>"

    this.cvs_faqi.Visible = false
    
    local needexp = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.NEEDEXP)
    local exp = quest:GetIntParam('Exp') + quest:GetIntParam('ExpRatio') * needexp / 10000
    this.lb_gold.Text = tostring(quest:GetStringParam('Gold'))
    this.lb_exp.Text = tostring(math.floor(exp))
    local RewardName = quest:GetStringParam('RewardName')
    local rewards = string.split(RewardName, '|')

    
    local pro = DataMgr.Instance.UserData.Pro
    
    
    
    
    
    local pro_defined = {
        [1] = 'WarriorReward',
        [2] = 'AssassinReward',
        [3] = 'MagicianReward',
        [4] = 'HunterReward',
        [5] = 'MinisterReward',
    }

    local pro_rewardName = quest:GetStringParam(pro_defined[pro])
    local pro_rewards = string.split(pro_rewardName, '|')
    for _, v in ipairs(pro_rewards) do
        if v ~= '' then
            table.insert(rewards, 1, v)
        end
    end

    for i = 1, 4 do
        local ib_reward = this['ib_reward' .. i]
        local check = i <= #rewards and rewards[i] ~= ''
        ib_reward.Visible = check
        if check then
            ib_reward.EnableChildren = true
            local tmp = string.split(rewards[i], ':')
            
            local code = tmp[1]
            local num = tmp[2] or 1
            local detail = ItemModel.GetItemDetailByCode(code)
            if not detail then
                print('itemcode not exist :', code)
            else
                local itshow = Util.ShowItemShow(ib_reward, detail.static.Icon, detail.static.Qcolor, num)
                itshow.EnableTouch = true
                itshow.event_PointerDown = function(sender)
                    itshow.IsSelected = true
                    Util.ShowItemDetailTips(itshow, ItemModel.GetItemDetailByCode(code))
                end
                itshow.event_PointerUp = function(sender)
                    itshow.IsSelected = false
                    GlobalHooks.CloseUI(GlobalHooks.UITAG.GameUISimpleDetail)
                end
            end

        end
    end

    local function SetDiamondCost(num)
        this.ib_number.Visible = num and num > 0
        this.ib_diamond.Visible = num and num > 0
        this.ib_number.Text = tostring(num)
    end



   
    
    SetDiamondCost(0)

    local Des
    this.touch_type = LINK_TYPE.Main_Talk
    if quest.State == QuestData.QuestStatus.NEW then
        
        Des = quest:GetStringParam('AcceptDialogue')
        
        if quest.Type == QuestData.QuestType.TRUNK then
            this.touch_type = nil
        end
        

        local text1 = quest:GetStringParam('AcceptBtn')
        if not text1 or text1 == '' then
            text1 = Text.btn_accept
        end
        this.btn_get.Text = text1
        this.btn_get.TouchClick = function(sender)
            OnLink(LINK_TYPE.Quest_Accept, index)
        end

        
        if quest.SubType == QuestData.EventType.RefineSoul then
            this.cvs_faqi.Visible = true
            local cvs_icon = this.cvs_faqi:FindChildByEditName('cvs_icon', true)
            local lb_beishu = this.cvs_faqi:FindChildByEditName('lb_beishu', true)
            local lb_faqi = this.cvs_faqi:FindChildByEditName('lb_faqi', true)
            local ib_number1 = this.cvs_faqi:FindChildByEditName('ib_number1', true)

            ib_number1.Text = GlobalHooks.DB.GetGlobalConfig('Quest.Soul.Refresh.CostDiamond')

            local item_code = quest:GetStringParam('SoulItem')
            local detail = ItemModel.GetItemDetailByCode(item_code)
            local itshow = Util.ShowItemShow(cvs_icon, detail.static.Icon, detail.static.Qcolor)
            itshow.EnableTouch = true
            itshow:SetParentIndex(0)
            itshow.event_PointerDown = function(sender)
                itshow.IsSelected = true
                Util.ShowItemDetailTips(itshow, detail)
            end

            itshow.event_PointerUp = function(sender)
                itshow.IsSelected = false
                GlobalHooks.CloseUI(GlobalHooks.UITAG.GameUISimpleDetail)
            end

            lb_faqi.Text = detail.static.Name
            lb_faqi.FontColorRGBA = Util.GetQualityColorRGBA(detail.static.Qcolor)
            this.btn_refuse.Visible = true
            this.btn_refuse.Text = Text.btn_refreshsoul
            this.btn_refuse.TouchClick = function(sender)
                OnLink(LINK_TYPE.Quest_RefreshSoul, index)
            end
            
            SetDiamondCost(0)
        elseif quest:GetIntParam('IsFastComplete') == 1 then
            this.btn_refuse.Text = Text.btn_quick_complete
            this.btn_refuse.Visible = true
            this.btn_refuse.TouchClick = function(sender)
                OnLink(LINK_TYPE.Quest_Quick_Complete, index)
            end
            SetDiamondCost(quest:GetIntParam('FastCompleteCost'))
        end
    elseif quest.State == QuestData.QuestStatus.CAN_FINISH then
        
        this.btn_close.Visible = false
        if PeekNpcData().TempalteID == 0 then
            Des = quest:GetStringParam('RewardSys')
        end
        if not Des or Des == '' then
            Des = quest:GetStringParam('Reward')
        end

        local text1 = quest:GetStringParam('RewardBtn')
        if not text1 or text1 == '' then
            text1 = Text.btn_text_directly
        end
        
        if Des and string.len(Des) > 0 then
            if quest:GetIntParam('IsDouble') == 1 then
                this.btn_get.Text = text1
                this.btn_get.Visible = true
                this.btn_get.TouchClick = function(sender)
                    OnLink(LINK_TYPE.Quest_Complete, index)
                end
                SetDiamondCost(quest:GetIntParam('DoubleCost'))
                this.btn_refuse.Text = Text.btn_double_complete
                this.btn_refuse.Visible = true
                this.btn_refuse.TouchClick = function(sender)
                    OnLink(LINK_TYPE.Quest_Double_Complete, index)
                end
            else
                this.btn_get.Text = text1
                this.btn_get.Visible = true
                this.btn_get.TouchClick = function(sender)
                    OnLink(LINK_TYPE.Quest_Complete, index)
                end
            end
        else
            
            local q = this.quests[index]
            local p = 0
            Quest.CompleteRequest(q, p, PeekNpcData().ObjID, function(err)
                if not err then
                    this.fsm:CompleteQuest(index)
                else
                    print('Quest_Complete Failed')
                end
            end )
            return
        end
    elseif quest.State == QuestData.QuestStatus.IN_PROGRESS then
        
    end
    if Des == '' then
        Des = quest:GetStringParam('Des')
    end
    local content, npc_tempid = ParseDialogContent(Des or '')
    this.tb_npcname.UnityRichText = string.format("<f>%s</f>", quest.Name)
     if npc_tempid then
     	if npc_tempid == 0 then
     		
     		ShowSelf()
     	else
     		local npc_data = DataMgr.Instance.NPCManager:GetNPCByTemplateID(npc_tempid)
     		ShowNpc(npc_data)
     	end
     else
     	ShowNpc(PeekNpcData())
     end
    
    
    
    local talks = string.split(content, '#')
    this.tb_npc_talk.UnityRichText = string.format("<f>%s</f>", talks[1])
    if #talks > 1 then
        local a = string.sub(talks[2],string.len(talks[2]),string.len(talks[2]))
        local path = nil
        if(a == "_") then
            local pro = DataMgr.Instance.UserData.Pro
            talks[2] = talks[2]..pro
            path = string.format(soundRolePath,talks[2])    
        else
            path = string.format(soundNpcPath,talks[2])
        end
        GlobalHooks.playTalkVoice(path)





        
    end



    
    EventManager.Fire('Npc.Quest.' .. quest.TemplateID, { })
    this.btn_get.UserTag = quest.TemplateID
    this.btn_refuse.UserTag = quest.TemplateID
    
end

local function GetNpcQuests(npc_data)
    local quests = Util.List2Luatable(npc_data:GetQuests()) or { }
    for i = #quests, 1, -1 do
        local q = quests[i]
        local deliId = q:GetIntParam("CompleteNpc")
        local giveId = q:GetIntParam('GiveNpc')

        
        
        
        
        if q.State == QuestData.QuestStatus.IN_PROGRESS then
            table.remove(quests, i)
        end
        
        if q.State == QuestData.QuestStatus.CAN_FINISH and npc_data.TempalteID ~= deliId then
            table.remove(quests, i)
        end

        if q.State == QuestData.QuestStatus.NEW and npc_data.TempalteID ~= giveId then
            table.remove(quests, i)
        end

        if q.State == QuestData.QuestStatus.DONE then
            table.remove(quests, i)
        end
    end

    table.sort(quests, function(q1, q2)
        local t1 = GameUtil.TryEnumToInt(q1.Type)
        local t2 = GameUtil.TryEnumToInt(q2.Type)
        if t1 == t2 then
            return q1.TemplateID < q2.TemplateID
        else
            return t1 < t2
        end
    end )
    return quests
end


local function _OnLink(link_type, index)
    local npcid = PeekNpcData().ObjID
    if link_type == LINK_TYPE.Quest then
        
        local q = this.quests[index]
        if q.State == QuestData.QuestStatus.NEW then
            
            this.fsm:BeginQuest(index)
        elseif q.State == QuestData.QuestStatus.IN_PROGRESS or q.State == QuestData.QuestStatus.CAN_FINISH then
            
            this.fsm:BeginAcceptedQuest(index)
        end
    elseif link_type == LINK_TYPE.Quest_Accept then
        local q = this.quests[index]
        Quest.AcceptRequest(q, npcid, function(err)
            if not err then
                this.dialog_next_index = 11
                this.fsm:AcceptQuest(index)
            end
        end )
    elseif link_type == LINK_TYPE.Quest_Quick_Complete then
        local q = this.quests[index]
        Quest.QuickFinishRequest(q, npcid, function(err)
            if not err then
                this.fsm:CompleteQuest(index)
            end
        end )
    elseif link_type == LINK_TYPE.Quest_Complete or link_type == LINK_TYPE.Quest_Double_Complete then
        local q = this.quests[index]
        local p =(link_type == LINK_TYPE.Quest_Double_Complete and 1) or 0
        Quest.CompleteRequest(q, p, npcid, function(err)
            if not err then
                this.fsm:CompleteQuest(index)
            else
                print('Quest_Complete Failed')
            end
        end )
    elseif link_type == LINK_TYPE.Quest_Discard then
        local q = this.quests[index]
        Quest.DiscardRequest(q, function(err)
            if not err then
                this.fsm:BackToTalk(index)
            end
        end )
    elseif link_type == LINK_TYPE.Quest_RefreshSoul then
        local q = this.quests[index]
        Quest.RefreshRefineSoulRequest(q, function()
            local ib_tx = this.cvs_faqi:FindChildByEditName('ib_tx', true)
            local control = ib_tx.Layout.SpriteController
            this.menu.EnableChildren = false
            ib_tx.Visible = true

            ib_tx:SetAnchor(Vector2.New(0.5, 0.5))
            ib_tx.Scale = Vector2.New(2, 2)

            local last_touchType = this.touch_type
            this.touch_type = nil
            control:PlayAnimate(0, 1, function(sender)
                
                this.menu.EnableChildren = true
                ib_tx.Visible = false
                this.touch_type = last_touchType
                this.quests = GetNpcQuests(PeekNpcData())
                for i, v in ipairs(this.quests) do
                    if v.SubType == QuestData.EventType.RefineSoul then
                        FillQuestDetail(i)
                    end
                end
            end )
        end )
    elseif link_type == LINK_TYPE.Quest_Continue then
        FillQuestDetail(index)
    elseif link_type == LINK_TYPE.Npc_Story then
        local strs = string.split(PeekNpcData():GetStringParam('NpcStory'), '|')

        local dlg = {
            text = strs,
            last_cb = function()
                local cvs = this['cvs_box' .. MAX_BUTTONS]
                FillItem(cvs, PeekNpcData():GetStringParam('EndBtn'), Text.icon_talk)
                SetButtonEvent(cvs, LINK_TYPE.Dialog_Next)
            end,
            end_cb = function()
                
                
                Close()
            end,
        }
        this.btn_continue_text = PeekNpcData():GetStringParam('ContinueBtn')
        SetDialog(dlg)
    elseif link_type == LINK_TYPE.Talk_Exit then
        Close()
    elseif link_type == LINK_TYPE.Dialog_Next then
        NextDialog()
    elseif link_type == LINK_TYPE.Dialog_Skip then
        this.dialog.text = { }
        NextDialog()
    elseif link_type == LINK_TYPE.Function then
        
        local data = this.funcs[index]
        
        if data.FunID == "oneDragon" then
            local function callback()
                Close()
            end
            local function fialCallback()
                local showTeam = false
                local lvIsOK = GlobalHooks.CheckFuncOpenByName("oneDragon",false)
                if lvIsOK then
                    local hasTeam = DataMgr.Instance.TeamData.HasTeam
                    if hasTeam then
                        local isLeader = DataMgr.Instance.TeamData:IsLeader()
                        local teamNum = DataMgr.Instance.TeamData.MemberCount +1
                        if isLeader and teamNum <3 then
                            GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUITeamMain, -1, "mineTeam|find|1010,1")
                        end
                    else
                        GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUITeamMain, -1, "platform|find|1010,1")
                    end
                end
            end
            Quest.AcceptLoopTaskRequest(""..npcid,callback,fialCallback)
            return
        elseif data.FunID == "teacher" then
            
            local function callback()
                Close()
            end
            Quest.AcceptTeacherTaskRequest(""..npcid,callback)
            return
        end
        local param
        if data.FunUIID == 'Shop' and this.params then
            param = this.params.shop_code
        end
        EventManager.Fire('Event.Goto', { data = data, param = param })
        if this.funcs and this.funcs[index].FunID == '1000310101' then
            
            
            EventManager.Fire('Event.Shop.Black', { data = this.funcs[index].FunID })
        end
        Close()
    elseif link_type == LINK_TYPE.Function_Steal then
        local npc_data = PeekNpcData()
        Npc.RequestSteal(npc_data.ObjID, function(data)
            if data.s2c_result == 1 then
                Close()
                
                local title = Util.GetText(TextConfig.Type.QUEST, 'lb_qiao')
                title = string.gsub(title or '', '%%name', npc_data.Name)
                local menu, obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIStealItem, 0)
                obj:Set( { items = data.s2c_items, title = title })
            elseif data.s2c_result == 2 then
                local strs = string.split(npc_data:GetStringParam('ScoldDia'), '|')
                SetDialogText(strs[1] or '')

                
                HideAllButtons()
                for i = MAX_FUNC_BUTTONS + MAX_QUEST_BUTTONS, MAX_BUTTONS do
                    local cvs = this['cvs_box' .. i]
                    cvs.Visible = true
                end
                local pos = MAX_BUTTONS - 1
                local cvs = this['cvs_box' .. pos]
                FillItem(cvs, npc_data:GetStringParam('ScoldBtn'), Text.icon_talk)
                SetButtonEvent(cvs, LINK_TYPE.Talk_Exit)
            else
                Close()
            end
        end )
    elseif link_type == LINK_TYPE.Main_Talk then
        this.quests = GetNpcQuests(PeekNpcData())
        local num = #this.quests
        if index and index > 1 then
            num = num + #this.funcs
        end
        if num > 0 then
            this.fsm:BackToTalk(LINK_TYPE.Main_Talk)
        else
            Close()
        end
    end
end


local function ClearGifts()
    for i, v in ipairs(this.gift_items) do
        if i ~= 1 then
            v:RemoveFromParent(true)
        end
    end
    this.gift_items = { }
end



local function SetFuncButtons(start_pos, index)
    index = index or 0
    local count = 0
    for k, v in ipairs(this.funcs) do
        if index == 0 or v.FunIndex == index then
            if count >= MAX_FUNC_BUTTONS then
                break
            end
            local visible = true
            if v.Condition == CONDITION_FUNCBTN_ACCEPT then
                local q = DataMgr.Instance.QuestManager:GetQuest(v.Value)
                if not q or q.State ~= QuestData.QuestStatus.IN_PROGRESS then
                    visible = false
                end
            elseif v.Condition == CONDITION_FUNCBTN_CAN_FINISH then
                local q = DataMgr.Instance.QuestManager:GetQuest(v.Value)
                if not q or q.State ~= QuestData.QuestStatus.CAN_FINISH then
                    visible = false
                end
            end
            if visible then
                local cvs = this['cvs_box' .. start_pos]
                FillItem(cvs, v.FunDes, v.SmallIcon)
                if v.FunIndex == 9999999999999999999999999 then
                    
                    SetButtonEvent(cvs, LINK_TYPE.Function_Steal, k)
                else
                    SetButtonEvent(cvs, LINK_TYPE.Function, k)
                end

                start_pos = start_pos + 1
                count = count + 1
            end
        end
    end
    this.sp_func.Scrollable.Scroll.vertical = count > 4
    this.sp_func.Visible = count > 0
    this.ib_funcbg.Visible = count > 0
    this.ib_down.Visible = count > 4
    local function CheckScollPan()
        if count <= 4 then
            this.ib_up.Visible = false
            this.ib_down.Visible = false
            return
        end
        local check_point = 2
        this.ib_up.Visible = true
        this.ib_down.Visible = true
        if this.sp_func.Scrollable.Container.Y > - check_point then
            
            this.ib_up.Visible = false
        end
        local h = this.sp_func.Scrollable.Container.Height + this.sp_func.Scrollable.Container.Y
        if h <= this.sp_func.Scrollable.ScrollRect2D.height + check_point then
            
            this.ib_down.Visible = false
        end
    end

    local fa = DelayAction.New()
    fa.Duration = 0.1
    
    fa.ActionFinishCallBack = function(sender)
        this.sp_func.Scrollable:LookAt(Vector2.zero, false)
    end
    this.sp_func:AddAction(fa)

    this.sp_func.Scrollable.event_Scrolled = CheckScollPan
    return start_pos
end

local function GetQuestImgPath(q)
    if q.State == QuestData.QuestStatus.NEW then
        if q.Type == QuestData.QuestType.DAILY then
            return Text.icon_daily_accept
        else
            return Text.icon_normal_accept
        end
    elseif q.State == QuestData.QuestStatus.CAN_FINISH then
        if q.Type == QuestData.QuestType.DAILY then
            return Text.icon_daily_submit
        else
            return Text.icon_normal_submit
        end
    elseif q.State == QuestData.QuestStatus.IN_PROGRESS then
        if q.Type == QuestData.QuestType.DAILY then
            return Text.icon_daily_submit
        else
            return Text.icon_normal_submit
        end
    else
        return nil
    end
end

local function SetQuestButtons(start_pos)
    this.quest_pos = { }
    local count = 0
    for i, v in ipairs(this.quests) do
        if count >= MAX_QUEST_BUTTONS then
            break
        end
        local cvs = this['cvs_box' .. start_pos]
        local img_path = GetQuestImgPath(v)
        local lb, ib = FillItem(cvs, v.Name, img_path)
        SetButtonEvent(cvs, LINK_TYPE.Quest, i)
        this.quest_pos[i] = start_pos
        if v.Type == QuestData.QuestType.DAILY then
            lb.FontColorRGBA = Util.GetQualityColorRGBA(GameUtil.Quality_Blue)
        end
        start_pos = start_pos + 1
        count = count + 1
    end
    return start_pos
end


local function SetMainButtons()
    HideAllButtons()
    SetQuestButtons(MAX_BUTTONS)
    SetFuncButtons(MAX_QUEST_BUTTONS + 1)

    local btn_str = PeekNpcData():GetStringParam('BeginStoryBtn')
    if btn_str and btn_str ~= '' then
        
        local cvs = this['cvs_box' .. MAX_BUTTONS]
        FillItem(cvs, btn_str, Text.icon_talk)
        SetButtonEvent(cvs, LINK_TYPE.Npc_Story)
    end
end

function transitions.OnEnterNone(fsm)
    print('transitions.OnEnterNone')

end

function transitions.OnEnterTalk(fsm, ename, from, to, link_type)
    this.menu.EnableChildren = true
    this.dialog_next_index = nil
    this.btn_close.Visible = true
    this.touch_type = LINK_TYPE.Talk_Exit
    this.cvs_mission_npc.Visible = false
    this.cvs_2dmod.Visible = false
    this.quests = GetNpcQuests(PeekNpcData())
    
    if #this.quests == 1 then
        local s = this.quests[1].State
        if s == QuestData.QuestStatus.CAN_FINISH then
            this.fsm:BeginAcceptedQuest(1)
        elseif s == QuestData.QuestStatus.NEW then
            local quest = this.quests[1]
            local Des = quest:GetStringParam('AcceptDialogue')
            if string.len(Des) > 0 then
                 FillQuestDetail(1)
                local cvs = this["cvs_box11"]
                cvs.Visible = true
                local btn_box = cvs:FindChildByEditName('btn_box', false)
                btn_box.TouchClick = function(sender)
                    this.fsm:BeginQuest(1)
                end
            else
                this.fsm:BeginQuest(1)
            end
        else
            
            local str = PeekNpcData():GetStringParam('Dialog')
            SetDialogText(str)
            SetMainButtons()
        end

    else
        
        local str = PeekNpcData():GetStringParam('Dialog')
        if(string.len(str) == 0) then
            Close()
            return
        end
        SetDialogText(str)
        SetMainButtons()
    end
    
    
    
    
end

function transitions.OnEnterQuestBegin(fsm, ename, from, to, index)
    local qdata = this.quests[index]
    local dialogs = qdata:GetStringParam('AcceptContent')
    
    if dialogs and dialogs ~= '' then
        local dlg = {
            text = string.split(dialogs,'|'),
            end_cb = function()
                
                OnLink(LINK_TYPE.Quest_Accept, index)
                Close()
            end,
        }
        SetDialog(dlg)
    elseif qdata.Type ~= QuestData.QuestType.TRUNK then
        OnLink(LINK_TYPE.Main_Talk)
    else
        Close()
    end
     OnLink(LINK_TYPE.Quest_Continue, index)
end

function transitions.OnEnterQuestAccepted(fsm, ename, from, to, index)
    
    local qdata = this.quests[index]
    local deliId = qdata:GetIntParam("CompleteNpc")
    local check_finish =(qdata.State == QuestData.QuestStatus.CAN_FINISH and PeekNpcData().TempalteID == deliId)
    if check_finish then
        
        local dialogs = qdata:GetStringParam('AfterPrompt')
        if not dialogs or dialogs == '' then
            OnLink(LINK_TYPE.Quest_Continue, index)
        else
            





            
            this.btn_continue_text = Text.btn_continue
            local text = string.split(dialogs, '|')
            local Des = ""
            if PeekNpcData().TempalteID == 0 then
                Des = qdata:GetStringParam('RewardSys')
            end
            if not Des or Des == '' then
                Des = qdata:GetStringParam('Reward')
            end
            local dlg = {
                text = text,
                end_cb = function()
                    if string.len(Des) > 0 then
                        this.btn_continue_text = Text.btn_continue
                        OnLink(LINK_TYPE.Quest_Continue,index)
                    end
                end,
            }
            if string.len(Des) == 0 then
                dlg.complete = true
                dlg.completeIndex = index
            end
            
            SetDialog(dlg)
        end
    else
        if qdata.State == QuestData.QuestStatus.CAN_FINISH then
            FillQuestDetail(1)
        else
            Close()
        end
    end

end

function transitions.OnEnterQuestCompleted(fsm, ename, from, to, index)
    local qdata = this.quests[index]
    
    local function BackTo()
        if PeekNpcData().TempalteID == 0 then
            Close()
        else
            local n = qdata:GetStringParam('Next')
            local ns = string.split(n, ':')

            this.quests = GetNpcQuests(PeekNpcData())
            local next_quest_index = nil
            
            for _, v in ipairs(ns) do
                if not next_quest_index then
                    for index, q in ipairs(this.quests) do
                        if tonumber(v) == q.TemplateID then
                            
                            if not (q:GetIntParam('isAuto') == -1) then
                                next_quest_index = index
                            end
                            break
                        end
                    end
                end
            end
            
            if next_quest_index then
                this.fsm:BeginQuest(next_quest_index)
            else
                OnLink(LINK_TYPE.Main_Talk)
            end
        end

    end
    BackTo()
end

local fsm_define =
{
    
    
    events =
    {
        { name = 'StartTalk', from = 'none', to = 'talk' },
        { name = 'BeginQuest', from = { 'talk', 'none', 'questcompleted' }, to = 'questbegin' },
        { name = 'AcceptQuest', from = 'questbegin', to = 'questaccepted' },
        { name = 'CompleteQuest', from = { 'questbegin', 'questaccepted' }, to = 'questcompleted' },
        { name = 'ReEnterAcceptQuest', from = 'questaccepted', to = 'questaccepted' },

        { name = 'BeginAcceptedQuest', from = { 'talk', 'none' }, to = 'questaccepted' },
        { name = 'Close', from = { 'talk', 'questbegin', 'questaccepted', 'questcompleted' }, to = 'none' },

        { name = 'BackToTalk', from = { 'talk', 'questbegin', 'questaccepted', 'questcompleted' }, to = 'talk' }
    },
    
    
    
    callbacks =
    {
        onenternone = transitions.OnEnterNone,
        onentertalk = transitions.OnEnterTalk,
        onenterquestbegin = transitions.OnEnterQuestBegin,
        onenterquestaccepted = transitions.OnEnterQuestAccepted,
        onenterquestcompleted = transitions.OnEnterQuestCompleted
    }
}


local function SetFromNpcdata()
    local npc_data = PeekNpcData()
    local func_str = npc_data:GetStringParam('FunID')
    local funcs = string.split(func_str or '', ',') or { }
    this.funcs = { }
    for i, v in ipairs(funcs) do
        local ele = GlobalHooks.DB.Find('Functions', v)
        table.insert(this.funcs, ele)
    end

    
    table.sort(this.funcs, function(f1, f2)
        if f1.FunIndex == f2.FunIndex then
            return f1.FunID < f2.FunID
        else
            return f1.FunIndex < f2.FunIndex
        end
    end )
     this.quests = GetNpcQuests(PeekNpcData())
     if #this.quests == 1 and this.quests[1].State == QuestData.QuestStatus.CAN_FINISH then
     	this.fsm:BeginAcceptedQuest(1)
     else		
        local quests = Util.List2Luatable(DataMgr.Instance.QuestManager:GetInteractiveNpcQuest(npc_data.TempalteID))
        
        local cb_count = 0
        local function cb(err)
            cb_count = cb_count + 1
            if cb_count == #quests or #quests == 0 then
                this.fsm:StartTalk(LINK_TYPE.Main_Talk)
            end
        end
        for i, q in ipairs(quests) do
            Quest.UpdateQuestState(q, cb)
        end

        if #quests == 0 then
            cb(nil)
        end
     end	
end

local function OpenSubmitItem(questID)
    GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIQuestSubmitItem, -1,questID)
end

local function Set(params)
    this.npc_datas = { }
    this.params = params
    this.cvs_2dmod.Visible = false
    local npc_data
    if params.id then
        npc_data = DataMgr.Instance.NPCManager:GetNPC(params.id)
    else
        local q = DataMgr.Instance.QuestManager:GetQuest(params.questID)
        if q.SubType == QuestData.EventType.SubmitItem then
            
            print("打开提交物品界面  q.TemplateID = " .. q.TemplateID)
            OpenSubmitItem(q.TemplateID)
            Close()
            return
        end
        
        if q.State == QuestData.QuestStatus.CAN_FINISH then
            
            local canSubmitQuest = false
            local kind = q:GetIntParam("Kind")
            if(q.Type == QuestData.QuestType.RUNNING or q.Type == QuestData.QuestType.DAILY) then
                local deliId = q:GetIntParam("CompleteNpc")
                if deliId == 0 then
                    canSubmitQuest = true
                elseif deliId == -1 then
                    Close()
                    return
                end
            else
                local deliId = q:GetIntParam("CompleteNpc")
                if deliId == -1 then
                    canSubmitQuest = false
                    Close()
                    return
                end
            end
            if canSubmitQuest then
                Pomelo.TaskHandler.submitTaskRequest(q.TemplateID, kind, 0, tostring(0), function(ex, sjson)
                    print("提交任务成功  q.TemplateID = " .. q.TemplateID)
                    Close()
                end )
            end
        elseif q.State == QuestData.QuestStatus.NEW then
            local giveId = q:GetIntParam("GiveNpc")
            local content = q:GetStringParam("AcceptContent");
            if giveId == 0 and string.len(content) == 0 then
                Quest.AcceptRequest(q, giveId, function(err)
                    print("接受任务成功  q.TemplateID = "..q.TemplateID)
                    Close()
                end )
            end
         end
        npc_data = NPCData.New(0)
        npc_data:AddQuest(q)
    end
    this.btn_get.Visible = false
    this.btn_refuse.Visible = false
    PushNpcData(npc_data)
    SetFromNpcdata()
    this.menu.Visible = true
    this.isClose = false
end

local function InitUICompment()
    this.tb_talk.UnityRichText = ''
    this.cvs_2dmod.Visible = false
    this.tb_npcname.TextComponent.Anchor = TextAnchor.C_C
    this.btn_continue_text = Text.btn_continue
    
    
    
    
    
    for i = 1, MAX_BUTTONS do
        local cvs = this['cvs_box' .. i]
        if cvs then
            cvs.UserTag = i
        end
    end
end

local function OnExit()
    Clear3DAvatar()
    this.tb_talk.UnityRichText = ""
    this.tb_talk.Text = ""
    this.tb_talk.Visible = false
    if not this.fsm:is('none') then
        this.fsm:Close()
    end

    
    this.cvs_mission_npc.Visible = false
    this.cvs_2dmod.Visible = false
    HideAllButtons()
end

local function OnDestory()
    this = nil
    GlobalHooks.NpcTalkUI = nil
end

local function Create(tag)
    this = { }
    this.menu = LuaMenuU.Create('xmds_ui/npc/npc.gui.xml', tag)
    this.menu.ShowType = UIShowType.HideBackMenu + UIShowType.HideBackHud
   
    this.fsm = Machine.create(fsm_define)
    Util.CreateHZUICompsTable(this.menu, ui_names, this)
    HudManagerU.Instance:InitAnchorWithNode(this.cvs_missionbox, bit.bor(HudManagerU.HUD_BOTTOM))


    this.menu.Enable = true
    this.isClose = false
    InitUICompment()
    this.menu:SubscribOnDestory(OnDestory)
    HudManagerU.Instance:InitAnchorWithNode(this.btn_close, bit.bor(HudManagerU.HUD_RIGHT, HudManagerU.HUD_TOP))
    this.menu:SubscribOnExit(OnExit)
    this.menu.event_PointerClick = function(sender)
        if this.touch_type then
            OnLink(this.touch_type)
        end
    end
    GlobalHooks.NpcTalkUI = this
    return this.menu
end

local function OnShowNpcTalk(eventname, params)
    
    if params.id then
        local npc_data = DataMgr.Instance.NPCManager:GetNPC(params.id)
        local quests = GetNpcQuests(npc_data)
        if #quests == 0 then
            local str = npc_data:GetStringParam('Dialog')
            if(string.len(str) == 0) then
                return
            end
        end
    end
    if GlobalHooks.FindUI(GlobalHooks.UITAG.GameUINPCTalk) then
        return
    end
    local menu,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUINPCTalk, 0)
    Set(params)
    this.cvs_missionbox.Alpha= 1.0;
end

local function OnCloseNpcTalk(eventname, params)
    Close()
end

local function OnActorRebirth(eventname, params)
    if not this then return end
    this.fsm:Close()
end

local function OnShowQuestDetail(eventname, params)
    if GlobalHooks.FindUI(GlobalHooks.UITAG.GameUINPCTalk) then return end
    GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUINPCTalk, 0)
    Set( { questID = params.id })







end

local function OnCompleteQuest(eventname, params)
    local questID = tonumber(params.id)
    local kind = tonumber(params.kind)
    local npcid = 0
    Pomelo.TaskHandler.submitTaskRequest(questID,kind,0,tostring(npcid),function (ex,sjson)
        print("提交任务成功  questID = "..questID)
  end)

end

local function initial()
    EventManager.Subscribe("Event.ShowNpcTalk", OnShowNpcTalk)
    EventManager.Subscribe("Event.CloseNpcTalk", OnCloseNpcTalk)
   
    EventManager.Subscribe("Event.ActorRebirth", OnActorRebirth)
    EventManager.Subscribe("Event.ShowQuestDetail", OnShowQuestDetail)
    EventManager.Subscribe("Event.CompleteQuest",OnCompleteQuest)
end


OnLink = _OnLink
_M.initial = initial
_M.Create = Create
_M.Set = Set

return _M
