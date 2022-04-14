-- 
-- @Author: LaoY
-- @Date:   2018-09-06 19:11:14
-- 
MainTaskTopItem = MainTaskTopItem or class("MainTaskTopItem", BaseItem)
local MainTaskTopItem = MainTaskTopItem

function MainTaskTopItem:ctor(parent_node, layer)
    self.abName = "main"
    self.assetName = "MainTaskTopItem"
    self.layer = layer
    self.events = {}
    self.model = TaskModel:GetInstance()
    MainTaskTopItem.super.Load(self)
end

function MainTaskTopItem:dctor()
    GlobalEvent.RemoveTabEventListener(self.events)
    --if self.event_id_1 then
    --	self.model:RemoveListener(self.event_id_1)
    --	self.event_id_1 = nil
    --end
    --if self.event_id_2 then
    --	self.model:RemoveListener(self.event_id_2)
    --	self.event_id_2 = nil
    --end

    if self.icon_settor then
        self.icon_settor:destroy()
        self.icon_settor = nil
    end
    if self.redPoint then
        self.redPoint:destroy()
        self.redPoint = nil
    end
    if self.wakePoint then
        self.wakePoint:destroy()
        self.wakePoint = nil
    end


    if self.effect then
        self.effect:destroy()
        self.effect = nil
    end
    if self.itemicon then
        self.itemicon:destroy()
        self.itemicon = nil
    end
end

function MainTaskTopItem:LoadCallBack()
    self.nodes = {
        "task_exp", "img_task_text", "img_task_bg_1", "con_reward", "sign",
        "wakeObj/wakeImg","wakeObj","wakeNum","wakeObj/wakeBg/wakeDes","wakeObj/wakeText",
        "wakeObj/wakeBg","img_task_exp_bg",
    }
    self:GetChildren(self.nodes)
    --self.text_value = GetText(self.text_value)
    self.task_exp_component = self.task_exp:GetComponent('Image')
    --	self.img_task_text = self.img_task_text:GetComponent('Text')
    self.img_task_text = GetImage(self.img_task_text)
    --	self.task_exp_component.fillAmount = 0.8
    self.wakeDes = GetText(self.wakeDes)
    self.wakeNum = GetText(self.wakeNum)
    self.wakeImg = GetImage(self.wakeImg)
    self.wakeText = GetImage(self.wakeText)
    --
    --local parent_height = GetSizeDeltaY(self.parent_node)
    --local height = GetSizeDeltaY(self.img_task_bg_1)
    SetLocalPositionXY(self.transform, -32, 130, 0)

    --self.icon_settor = GoodsIconSettorTwo(self.con_reward)
    --self.icon_settor:UpdateSize(54)
    --self.icon_settor:SetData(90010003,99)
    --self.icon_settor:SetVisible(true)
    self.redPoint = RedDot(self.transform, nil, RedDot.RedDotType.Nor)
    self.redPoint:SetPosition(112, 15)

    self.wakePoint = RedDot(self.transform, nil, RedDot.RedDotType.Nor)
    self.wakePoint:SetPosition(112, 15)
    --self.redPoint:SetRedDotParam(true)


    self:AddEvent()
    if self.is_need_setData then
        self:SetData(self.data, self.level,self.type,self.isTask or false)
    end
    --self:SetData()
end

function MainTaskTopItem:AddEvent()
    local function call_back()
      --  UnpackLinkConfig('500@1@3')
        if self.type == 1 then
            MainIconOpenLink(500,1,3)

        else
            lua_panelMgr:GetPanelOrCreate(WakePanel):Open()
           -- OpenLink(600,1)
           -- GlobalEvent:Brocast(WakeEvent.OpenWakePanel)
        end

    end
    AddClickEvent(self.img_task_bg_1.gameObject, call_back)
    
    
    local function call_back(isred)
        if  self.type == 2 then
            self.wakePoint:SetRedDotParam(isred)
        else
            self.wakePoint:SetRedDotParam(false)
        end
    end
   -- MainEvent.ChangeRedDot
    self.events[#self.events + 1] = GlobalEvent:AddListener(WakeEvent.UpdateTaskRed,call_back)

end
--type = 1 等級奖励   2 觉醒
function MainTaskTopItem:SetData(data, level,type,isTask)
    self.data = data
    self.level = level
    self.type = type
    self.isTask = isTask
    if not self.data then
        return
    end
    if not self.is_loaded then
        self.is_need_setData = true
        return
    end
    if type == 2 then
        SetVisible(self.img_task_text,false)
        SetVisible(self.sign,false)
        SetVisible(self.con_reward,false)
        SetVisible(self.wakeObj,true)

        self.redPoint:SetRedDotParam(false)
        if self.isTask then
            SetVisible(self.wakeText,false)
            SetVisible(self.wakeBg,true)
            SetVisible(self.wakeImg,true)
            SetVisible(self.img_task_exp_bg,true)
            SetVisible(self.task_exp,true)
            SetVisible(self.wakeNum,true)
            self:SetWakeInfo()
        else
            lua_resMgr:SetImageTexture(self, self.wakeText, "iconasset/icon_chaptertitle", "wake_text_"..(self.data+1), false,nil,false)
            SetVisible(self.wakeBg,false)
            SetVisible(self.wakeImg,false)
            SetVisible(self.img_task_exp_bg,false)
            SetVisible(self.task_exp,false)
            SetVisible(self.wakeNum,false)
            SetVisible(self.wakeText,true)

        end

    else
        SetVisible(self.img_task_text,true)
        SetVisible(self.sign,true)
        SetVisible(self.con_reward,true)
        SetVisible(self.img_task_exp_bg,true)
        SetVisible(self.task_exp,true)
        SetVisible(self.wakeNum,true)
        SetVisible(self.wakeObj,false)
        self.wakePoint:SetRedDotParam(false)
        self:SetInfo()
    end
end

function MainTaskTopItem:SetWakeInfo()
    local wake = self.data

    --if wake + 1 == 4 then
    --    --local taskNum = 0
    --    --local finishTaskNum = 0
    --    ---- 60032
    --    --local info = TaskModel:GetInstance():GetTask(60032)
    --    --if not info or info.state == enum.TASK_STATE.TASK_STATE_FINISH then --已完成
    --    --    finishTaskNum = finishTaskNum + 1
    --    --end
    --    self.wakeNum.text = string.format("%s/%s",0,1)
    --    self.task_exp_component.fillAmount = 0.5
    --    return
    --end
    local gender = RoleInfoModel.GetInstance():GetSex()
    local level = RoleInfoModel:GetInstance():GetMainRoleData().level
    local wakeKey = gender.."@"..(wake + 1)
    local wakeCfg = Config.db_wake[wakeKey]
    local step = wakeCfg.step or 0
    local taskNum = 0
    local finishTaskNum = 0
    for i = 1, step do
        local key = (wake+1).."@"..i
        local cfg = Config.db_wake_step[key]
        local tab = String2Table(cfg.tasks)
        taskNum = taskNum  + #tab
        for j = 1, #tab do
            local taskCfg = Config.db_task[tab[j]]
            local tasklevel = taskCfg.minlv
            if level >= tasklevel then
                local info = TaskModel:GetInstance():GetTask(tab[j])
                if not info or info.state == enum.TASK_STATE.TASK_STATE_FINISH then --已完成
                    finishTaskNum = finishTaskNum + 1
                end
            end

        end
    end
    --local color = "3ab60e"  --eb0000
    --if finishTaskNum < taskNum then
    --    color = "eb0000"
    --end
    self.wakeNum.text = string.format("%s/%s",finishTaskNum,taskNum)
    self.task_exp_component.fillAmount = finishTaskNum / taskNum
    lua_resMgr:SetImageTexture(self, self.wakeImg, "iconasset/icon_chaptertitle", "wake_"..(wake+1), false)
    local texTab = {[1]= "1st awakening grants you rare titles",[2]= "2nd awakening unlocks assisting avatar for you",[3]=" 3rd awakening grants you rare avatar"}
    self.wakeDes.text = texTab[wake + 1]
end

function MainTaskTopItem:CheckRedPoint(level)
    --if self.model:isRewardLevel(level) ~= nil then
    --	if self.model:isRewardLevel(level) == true then
    --		self.redPoint:SetRedDotParam(false)
    --	else
    --		self.redPoint:SetRedDotParam(true)
    --	end
    --end
    local role_data = RoleInfoModel.GetInstance():GetMainRoleData()
    if role_data.level >= level then
        self.redPoint:SetRedDotParam(true)
        if not self.effect then
            self.effect = UIEffect(self.transform, 10503, false)
            self.effect:SetOrderIndex(101)
            self.effect:SetPosition(0, 0)
        end
    else
        if self.effect then
            self.effect:destroy()
            self.effect = nil
        end
        self.redPoint:SetRedDotParam(false)
    end
end

function MainTaskTopItem:SetInfo()
    local levelTab = String2Table(self.data.level)
    local maxLv = levelTab[2]
    self:CheckRedPoint(maxLv)
    --	self.text_value.text = self.level.."/"..maxLv
    SetVisible(self.sign, self.data.limit == 1)
    self.task_exp_component.fillAmount = self.level / maxLv
    local showlv = self.level
    if self.level > maxLv then
        showlv = maxLv
    end
    self.wakeNum.text = string.format("%s/%s",showlv,maxLv)
    self:CreateIcon()
    if self.titleName == self.data.text then
        return
    end
    self.titleName = self.data.text
    self:SetTitleImg()
end
function MainTaskTopItem:CreateIcon()
    local iconTab = String2Table(self.data.icon)
    local iconId = iconTab[1]
    local iconNum = iconTab[2]
    if self.itemicon == nil then
        self.itemicon = GoodsIconSettorTwo(self.con_reward)
    end
    local param = {}
    param["model"] = self.model
    param["item_id"] = iconId
    param["num"] = iconNum
    param["can_click"] = true
    param["size"] = { x = 54, y = 54 }
    self.itemicon:SetIcon(param)
end

function MainTaskTopItem:SetTitleImg()
    lua_resMgr:SetImageTexture(self, self.img_task_text, "iconasset/icon_chaptertitle", self.titleName, false,nil,false)
end

