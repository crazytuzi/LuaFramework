---
--- Created by  Administrator
--- DateTime: 2020/3/16 14:57
---
MergeRechargeItem = MergeRechargeItem or class("MergeRechargeItem", SevenDayRechargeItem)
local this = MergeRechargeItem

--function MergeRechargeItem:ctor(obj, parent_node, parent_panel)
--    MergeRechargeItem.super.Load(self)
--    self.events = {}
--end
--
--function MergeRechargeItem:dctor()
--    GlobalEvent:RemoveTabListener(self.events)
--end
--
--function MergeRechargeItem:LoadCallBack()
--    self.nodes = {
--
--    }
--    self:GetChildren(self.nodes)
--
--    self:InitUI()
--    self:AddEvent()
--end
--
--function MergeRechargeItem:InitUI()
--
--end
--
--function MergeRechargeItem:AddEvent()
--
--end

function MergeRechargeItem:SetDes()
    local tab = String2Table(self.cfgData.task)
    if table.nums(tab) > 1 then
        local tab = String2Table(self.cfgData.task)
        local num = tab[2]
        local color = "0DB420"
        if self.data.count < num then
            color = "FF0000"
        end
        local cNum = self.data.count
        if self.data.count > num then
            cNum = num
        end
        self.numTex.text = string.format("<color=#%s>%s/%s</color>", color, cNum, num)
        SetVisible(self.zhuanshiIcon, true)
        --if self.data.count ~= 0 then
        --    curNum = self.model:GetMountNumByID(self.data.count)
        --    local color = "0DB420"
        --    if curNum.order < tab[2] then
        --        color = "FF0000"
        --    else
        --        if curNum.level < tab[3] then
        --            color = "FF0000"
        --        end
        --    end
        --   -- self.des.text = self.cfgData.desc
        --    self.numTex.text = string.format("<color=#%s>%s阶%s星/%s阶%s星</color>", color, curNum.order, curNum.level, num, tab[3])
        --else
        --    self.numTex.text = string.format("<color=#%s>%s阶%s星/%s阶%s星</color>", "FF0000", 0, 0, num, tab[3])
        --end
    else
        local num = tonumber(self.cfgData.task)
        local color = "0DB420"
        if self.data.count < num then
            color = "FF0000"
        end
        local cNum = self.data.count
        if self.data.count > num then
            cNum = num
        end
        --self.des.text = self.cfgData.desc
        self.numTex.text = string.format("<color=#%s>%s/%s</color>", color, cNum, num)
        SetVisible(self.zhuanshiIcon, false)
    end
    self.des.text = self.cfgData.desc
    SetLocalPositionX(self.numTex.transform, self.des.preferredWidth)
    SetLocalPositionX(self.zhuanshiIcon.transform, self.numTex.preferredWidth + self.des.preferredWidth)
    SetLocalPositionX(self.lqTex, self.numTex.preferredWidth + self.des.preferredWidth + 30)

end