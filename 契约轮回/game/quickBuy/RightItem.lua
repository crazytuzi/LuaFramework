--- Created by Admin.
--- DateTime: 2019/11/6 20:40

RightItem = RightItem or class("RightItem", BaseCloneItem)
local this = RightItem

function RightItem:ctor(obj,parent_node, layer)
    RightItem.super.Load(self)
end

function RightItem:dctor()
end

function RightItem:LoadCallBack()
    --self.model = CanMdyModel.GetInstance()
    self.nodes = {
        "bg","select","pos","name","goBtn","icon","img_recommend"
    }
    self:GetChildren(self.nodes)
    self.nameTex = GetText(self.name)
    self.goBtn = GetButton(self.goBtn)

    self:AddEvent()

   
end

function RightItem:AddEvent()


    local function call_back()
       self.panel:SelectJumpItem(self)
    end
    AddClickEvent(self.bg.gameObject, call_back)

    local function call_back()
        OpenLink(unpack(self.data.jumpTable))
        self.panel:Close()
    end
    AddClickEvent(self.goBtn.gameObject, call_back)

   
end

function RightItem:SetData(data, panel)
    self.data = data
    self.panel = panel
    self:UpdateView()
end

function RightItem:UpdateView()

    --已推荐
    SetVisible(self.img_recommend,self.data.IsRecom == true)
    --图标
    local abName, assetName = GetLinkAbAssetName(self.data.jumpTable[1], self.data.jumpTable[2])
    if abName ~= nil and assetName ~= nil then
        lua_resMgr:SetImageTexture(self, self.icon:GetComponent('Image'), abName, assetName, true)
    end

    --名称
    local linkConfig = GetOpenLink(self.data.jumpTable[1], self.data.jumpTable[2])
    if not linkConfig then
        return
    end
    self.nameTex.text = linkConfig.name
end


--选中
function RightItem:Select(isSelected)
    SetVisible(self.select,isSelected)
end