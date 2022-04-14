---
--- Created by  Administrator
--- DateTime: 2019/7/16 15:47
---
MarryMatchingPanel = MarryMatchingPanel or class("MarryMatchingPanel", BasePanel)
local this = MarryMatchingPanel

function MarryMatchingPanel:ctor(parent_node, parent_panel)
    self.abName = "marry"
    self.assetName = "MarryMatchingPanel"
    self.layer = LayerManager.LayerNameList.UI
   -- self.use_background = true
    self.change_scene_close = true
    self.use_background = true
    self.events = {}
    self.model = MarryModel:GetInstance()
    self.role = RoleInfoModel.GetInstance():GetMainRoleData()
end

function MarryMatchingPanel:dctor()
    self.model:RemoveTabListener(self.events)
    if self.autoschedule then
        GlobalSchedule.StopFun(self.autoschedule);
    end
    if self.role_icon then
        self.role_icon:destroy()
        self.role_icon = nil
    end

    if self.effect1 then
        self.effect1:destroy()
    end

    if self.effect2 then
        self.effect2:destroy()
    end
end

function MarryMatchingPanel:LoadCallBack()
    self.nodes = {
        "myObj/myHead","myObj/myVip","big_bg",
        "eObj/eVip","eObj/eLv","myObj/myLv","myObj/myName",
        "eObj/eHead","eObj/eName","tips","okBtn",
        "myObj","eObj","static",
    }
    self:GetChildren(self.nodes)
    self.big_bg = GetImage(self.big_bg)
    self.myName = GetText(self.myName)
    self.myLv = GetText(self.myLv)
    self.myVip = GetText(self.myVip)
  --  self.myHead = GetImage(self.myHead)
    self.eName = GetText(self.eName)
    self.eLv = GetText(self.eLv)
    self.eVip = GetText(self.eVip)
    self.eHead = GetImage(self.eHead)
    self.tips = GetText(self.tips)
    SetVisible(self.static,false)
    SetVisible(self.tips,false)
    SetVisible(self.okBtn,false)
    self:InitUI()
    self:AddEvent()
    self:StartAction()
    local TopTransform = LayerManager.Instance:GetLayerByName(LayerManager.LayerNameList.Top)
    self.effect1 = UIEffect(TopTransform, 30003)
   -- MarryController:GetInstance():RequsetMatch()
end




function MarryMatchingPanel:StartAction()
    local moveAction = cc.MoveTo(0.2, 40, 0, 0)
    local function end_call_back()
      --  print2("移动结束1")
        local moveAction = cc.MoveTo(0.5, 0, 0, 0)
        local function call_back()
            --print2("移动结束11")
        end
        local sys_action = cc.Sequence(cc.DelayTime(0),moveAction,cc.CallFunc(call_back))
        cc.ActionManager:GetInstance():addAction(sys_action, self.myObj)

    end
    local delay_action = cc.DelayTime(0)
    local call_action = cc.CallFunc(end_call_back)
    local sys_action = cc.Sequence(delay_action,moveAction,call_action)
    cc.ActionManager:GetInstance():addAction(sys_action, self.myObj)



    local moveAction = cc.MoveTo(0.2, 251, 0, 0)
    local function end_call_back()
       -- print2("移动结束2")
        local moveAction = cc.MoveTo(0.5, 288, 0, 0)
        local function call_back()
           -- print2("移动结束22")

            self:StartCount()
        end
        local sys_action = cc.Sequence(cc.DelayTime(0),moveAction,cc.CallFunc(call_back))
        cc.ActionManager:GetInstance():addAction(sys_action, self.eObj)
    end
    local delay_action = cc.DelayTime(0)
    local call_action = cc.CallFunc(end_call_back)
    local sys_action = cc.Sequence(delay_action,moveAction,call_action)
    cc.ActionManager:GetInstance():addAction(sys_action, self.eObj)

    --local sys_action = cc.Sequence(call_action)
    --
    --
    --local action = cc.MoveTo(0.2, 0, 0, 0)
    --
    --self.notifyAction1 = cc.MoveTo(0.5, 251, 0, 0)
    --cc.ActionManager:GetInstance():addAction(self.notifyAction1, self.eObj)
end

function MarryMatchingPanel:AddEvent()

    local function call_back()
        self:Close()
    end
    AddButtonEvent(self.okBtn.gameObject,call_back)
   -- self.events[#self.events] = self.model:AddListener(MarryEvent.MarryMatch,handler(self,self.MarryMatch))
end

function MarryMatchingPanel:InitUI(data)
    local res = "marry_big_bg"
    lua_resMgr:SetImageTexture(self,self.big_bg, "iconasset/icon_big_bg_"..res, res)
   -- dump(data.role)
    --logError("陪陪信息")
--    local eRole = data.role
    self.myName.text = self.role.name
    self.myLv.text = self.role.level.."Level"
    self.myVip.text = "VIP"..self.role.viplv

    self.eName.text = "???"
    self.eLv.text = "Level??"
    self.eVip.text = "VIP??"

    if self.role_icon then
        self.role_icon:destroy()
        self.role_icon = nil
    end
    local param = {}
    local function uploading_cb()
        --  logError("回调")
    end
    param["is_squared"] = true
    param["is_hide_frame"] = true
    param["size"] = 180
    param["uploading_cb"] = uploading_cb
    self.role_icon = RoleIcon(self.myHead)
    self.role_icon:SetData(param)

    self:SetEHead()

    self.effect2 = UIEffect(self.okBtn, 10121, false)
    self.effect2:SetConfig({ is_loop = true ,scale = 1.63})

end

function MarryMatchingPanel:SetEHead()
    local headName = CacheManager:GetInstance():GetString("marryname"..self.role.id, "0")
    if headName == "0" then
        local gender = self.role.gender
        local str = "marry_random1"
        if gender == 1 then
            str = "marry_random2"
        end
        local id = math.random(1,6)
        lua_resMgr:SetImageTexture(self,self.eHead,"iconasset/icon_marryhead",str..id, false)
        CacheManager:GetInstance():SetString("marryname"..self.role.id, str..id)
    else
        lua_resMgr:SetImageTexture(self,self.eHead,"iconasset/icon_marryhead",headName, false)

    end

end

function MarryMatchingPanel:StartCount()
    SetVisible(self.tips,true)
    SetVisible(self.static,true)
    SetVisible(self.okBtn,true)
    self.tips.text = "Tips: Closing in 4 sec"
    local time = 4
    local function callBack()
        time = time - 1
        if self.tips then
            self.tips.text = "Tip:"..tostring(time) .. "Closing in X sec";
        end
        if time <= 0 then
            self:Close()

        end
    end
    self.autoschedule = GlobalSchedule:Start(callBack, 1, -1);
end


