-- @Author: lwj
-- @Date:   2018-12-18 15:08:26
-- @Last Modified time: 2018-12-18 15:08:54

TitleText = TitleText or class("TitleText", Node)
local this = TitleText

function TitleText:ctor(obj,str)
    self.transform = obj.transform
    self.gameObject = self.transform.gameObject;
    self.transform_find = self.transform.Find;
    self.str=str
end

function TitleText:dctor()
end

function TitleText:LoadCallBack()
    self.nodes = {
        "countdowntext",
    }
    self:GetChildren(self.nodes)
    self.cdT = self.countdowntext:GetComponent('Text')
    if self.str then
        self:SetCDText()
    end
end

function TitleText:SetCDText(str)
    self.cdT.text = str
end
