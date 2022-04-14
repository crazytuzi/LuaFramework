RaceEndItem = RaceEndItem or class("RaceEndItem",DungeonEndItem)

function RaceEndItem:ctor(parent_node, data,panel)

    self.panel = panel
   
end

function RaceEndItem:dctor()

end

function RaceEndItem:LoadCallBack(  )
    RaceEndItem.super.LoadCallBack(self)

    self.sureText.fontSize = 23

    --替换下背景为完成比赛
    local bg = self.bg:GetChild(0)
    local img_bg = GetImage(bg)
    lua_resMgr:SetImageTexture(self,img_bg,"race_image","race_end_logo",false,nil,true)

    --为了实现同步显示 先这样了
    SetVisible(self.panel.transform,true)

    LayerManager:GetInstance():AddOrderIndexByCls(self, self.bg, nil, true, nil, false, 5)
end