--- Created by Admin.
--- DateTime: 2019/11/21 14:32
AwakenPanel = AwakenPanel or class("AwakenPanel", BasePanel)
local AwakenPanel = AwakenPanel

function AwakenPanel:ctor()
    self.abName = "main"
    self.assetName = "AwakenPanel"
    self.layer = "Top"


    self.openList = {[1] = {850,1,1,"true"},[2] = {401,2,3}, [3] = {810, 1, 1,"true"}, [4] = {860, 1, 3, 7,"true"}}
    self.items = {}
    self.model = MainModel.GetInstance()
end

function AwakenPanel:dctor()
   self.items = {}
end

function AwakenPanel:Open()
    AwakenPanel.super.Open(self)
end

function AwakenPanel:OpenCallBack()
end

function AwakenPanel:LoadCallBack()
    self.nodes = {
        "mask","Btn_Scroll/Viewport/btn_content/AwakenItem1/bg1","Btn_Scroll/Viewport/btn_content/AwakenItem2/bg2",
        "Btn_Scroll/Viewport/btn_content/AwakenItem3/bg3","Btn_Scroll/Viewport/btn_content/AwakenItem4/bg4",
        "Btn_Scroll/Viewport/btn_content/AwakenItem1","Btn_Scroll/Viewport/btn_content/AwakenItem2",
        "Btn_Scroll/Viewport/btn_content/AwakenItem3","Btn_Scroll/Viewport/btn_content/AwakenItem4",
    }
    self:GetChildren(self.nodes)

    self.items[1] = self.AwakenItem1
    self.items[2] = self.AwakenItem2
    self.items[3] = self.AwakenItem3
    self.items[4] = self.AwakenItem4

    SetAlignType(self.gameObject.transform,bit.bor(AlignType.Right, AlignType.Null))
    self:AddEvent()
    self:InitPanel()
end

function AwakenPanel:AddEvent()
    AddClickEvent(self.mask.gameObject, handler(self, self.Close))

    local function call_back()
        OpenLink(unpack(self.openList[1])) -- 0元礼包
        self:Close()
    end
    AddClickEvent(self.bg1.gameObject,call_back)

    local function call_back()
       OpenLink(unpack(self.openList[2]))   --VIP礼包
        self:Close()
    end
    AddClickEvent(self.bg2.gameObject,call_back)

    local function call_back()
      --  OpenLink(unpack(self.openList[3]))  --登录大礼
       -- self:Close()
    end
    AddClickEvent(self.bg3.gameObject,call_back)

    local function call_back()
        OpenLink(unpack(self.openList[4])) -- 宠物觉醒
        self:Close()
    end
    AddClickEvent(self.bg4.gameObject,call_back)
end

function AwakenPanel:InitPanel()
    SetVisible(self.items[3].gameObject, false)
    SetVisible(self.items[1].gameObject, FreeGiftModel.GetInstance():IsShowIcon())
    SetVisible(self.items[4].gameObject, OpenTipModel.GetInstance():IsOpenSystem(unpack(self.openList[4])))
end

function AwakenPanel:CloseCallBack()

end