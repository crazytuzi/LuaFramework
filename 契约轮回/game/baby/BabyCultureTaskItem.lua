---
--- Created by  Administrator
--- DateTime: 2019/9/2 15:18
---
BabyCultureTaskItem = BabyCultureTaskItem or class("BabyCultureTaskItem", BaseCloneItem)
local this = BabyCultureTaskItem

function BabyCultureTaskItem:ctor(obj, parent_node, parent_panel)
    BabyCultureTaskItem.super.Load(self)
    self.events = {}
    self.itemicon = {}
end

function BabyCultureTaskItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    for i, v in pairs(self.itemicon) do
        v:destroy()
    end
    self.itemicon = {}
    if self.redPoint then
        self.redPoint:destroy()
        self.redPoint = nil
    end
end

function BabyCultureTaskItem:LoadCallBack()
    self.nodes = {
        "name","iconParent","lqBtn","ylq","lqBtn/lqTex"
    }
    self:GetChildren(self.nodes)
    self.name = GetText(self.name)
    self.lqTex = GetText(self.lqTex)
    self.lqImg = GetImage(self.lqBtn)
    self:InitUI()
    self:AddEvent()
    self.redPoint = RedDot(self.lqBtn, nil, RedDot.RedDotType.Nor)
    self.redPoint:SetPosition(34, 15)
end

function BabyCultureTaskItem:InitUI()

end

function BabyCultureTaskItem:AddEvent()
    local function call_back()
        if self.info.state ~= enum.TASK_STATE.TASK_STATE_FINISH  then
          --  Notify.ShowText("您还未完成任务哦！")
            local list = self:GetLinkList()
            local id = list[2]
            local subId = list[3]
            --table.remove(list,1)
            --table.remove(list,1)
            --table.remove(list,1)
            OpenLink(id,subId,list[4] or nil,list[5] or nil,list[6] or nil)
            return
        end
        TaskController:GetInstance():RequestTaskSubmit(self.taskId)
    end
    AddButtonEvent(self.lqBtn.gameObject,call_back)
end

function BabyCultureTaskItem:SetData(data)
    self.taskId = data
    self.info = TaskModel:GetInstance():GetTask(self.taskId)
    self.cfg = Config.db_task[self.taskId]
    self:UpdataInfo()
  --  self.name.text =
    --dump(self.info)

end
function BabyCultureTaskItem:UpdataInfo()
    self:CreateIcon()
    self.cur_goal = String2Table(self.cfg.goals)
    local maxNum = tonumber(self.cur_goal[1][3])
    local curNum = maxNum
    if not self.info then  --已完成
        SetVisible(self.lqBtn,false)
        SetVisible(self.ylq,true)
        self.name.text = string.format("%s<color=#10980B> (%s/%s)</color>",self.cfg.desc,curNum,maxNum)
        self.redPoint:SetRedDotParam(false)
        return
    end
    if self.info.state == enum.TASK_STATE.TASK_STATE_FINISH then --完成
        self.lqTex.text = "Claim"
      --  ShaderManager:GetInstance():SetImageNormal(self.lqImg)
        SetVisible(self.lqBtn,true)
        SetVisible(self.ylq,false)
        self.redPoint:SetRedDotParam(true)
    else
        curNum = self.info.count
        SetVisible(self.lqBtn,true)
        SetVisible(self.ylq,false)
        self.lqTex.text = "Go"
        self.redPoint:SetRedDotParam(false)
       -- ShaderManager:GetInstance():SetImageGray(self.lqImg)
    end

  --=  self.name.text = self.cfg.desc
    local color = "10980B"
    if curNum < maxNum then --红色
        color = "FF0015"
    end
    self.name.text = string.format("%s<color=#%s> (%s/%s)</color>",self.cfg.desc,color,curNum,maxNum)

end

function BabyCultureTaskItem:CreateIcon()
    for i, v in pairs(self.itemicon) do
        v:destroy()
    end
    self.itemicon = {}
    local rewardTab = String2Table(self.cfg.gain)
    for i = 1, #rewardTab do
        local param = {}
        param["item_id"] = rewardTab[i][1]
        param["num"] = rewardTab[i][2]
        param["model"] = BagModel
        param["can_click"] = true
        param["show_num"] = true
        if self.itemicon[i] == nil then
            self.itemicon[i] = GoodsIconSettorTwo(self.iconParent)
        end
        self.itemicon[i]:SetIcon(param)
    end
end

function BabyCultureTaskItem:GetMainTaskTipList()
    local link_list = self:GetLinkList()
    if not link_list then
        return
    end
    local t = {}
    local len = #link_list
    for i=1,len do
        local link = link_list[i]
        local cf = GetOpenLink(link[1],link[2])
        t[#t+1] = {text = cf.name , param = link}
    end
    return t
end


function BabyCultureTaskItem:GetLinkList()
    local params = self.cur_goal[1][6]
    local tab
    if not params then
        return nil
    end
    for k,v in pairs(params) do
        if v[1] == "link" then
            tab = v
            return tab
        end
    end
    return tab
end




