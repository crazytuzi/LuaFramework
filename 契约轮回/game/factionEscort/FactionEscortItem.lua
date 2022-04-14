FactionEscortItem = FactionEscortItem or class("FactionEscortItem",BaseCloneItem)

function FactionEscortItem:ctor(obj,parent_node,layer)
    FactionEscortItem.super.Load(self)
    self.model = FactionEscortModel:GetInstance()

end
function FactionEscortItem:dctor()

end

function FactionEscortItem:LoadCallBack()
    self.nodes =
    {
        "itemTex","itemPic","select","name","escorting",
    }
    self:GetChildren(self.nodes)
    SetLocalPosition(self.transform, 0, 0, 0)
    self.itemTex = GetImage(self.itemTex)
    self.itemPic = GetImage(self.itemPic)
    self.name = GetImage(self.name)
   -- self.name_outline = self.name:GetComponent('Outline')
    self:AddEvent()
    --self:SetTileTextImage("combine_image", "Combine_title")

end

function FactionEscortItem:AddEvent()

end

function FactionEscortItem:SetData(data,index)
   -- self.key = data
    self.data = data
    self.index = index
    self:InitUI()
end

function FactionEscortItem:InitUI()
    --self.name.text = self.data.name
    lua_resMgr:SetImageTexture(self,self.name, 'factionEscort_image', "escort_itemName"..self.index,false)
    lua_resMgr:SetImageTexture(self,self.itemTex, 'factionEscort_image', self.data.quapic,false)
    lua_resMgr:SetImageTexture(self,self.itemPic, 'factionEscort_image', self.data.showpic,false)
end

function FactionEscortItem:SetSelect(show)
    if show then
        SetVisible(self.escorting,self.model.isEscorting)
        ShaderManager.GetInstance():SetImageNormal(self.itemPic)
       -- ShaderManager.GetInstance():SetImageNormal(self.itemTex)
       -- ShaderManager.GetInstance():SetImageNormal(self.name)
        lua_resMgr:SetImageTexture(self,self.itemTex, 'factionEscort_image', self.data.quapic,false)
        lua_resMgr:SetImageTexture(self,self.name, 'factionEscort_image', "escort_itemName"..self.index,false)
    else
        ShaderManager.GetInstance():SetImageGray(self.itemPic)
        --ShaderManager.GetInstance():SetImageGray(self.itemTex)
      --  ShaderManager.GetInstance():SetImageGray(self.name)
        lua_resMgr:SetImageTexture(self,self.itemTex, 'factionEscort_image', self.data.quapic.."U",false)
        lua_resMgr:SetImageTexture(self,self.name, 'factionEscort_image', "escort_itemNameU"..self.index,false)
    end
    SetVisible(self.select,show)
end





