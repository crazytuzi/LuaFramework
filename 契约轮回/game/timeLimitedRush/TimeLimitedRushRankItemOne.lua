--限时冲榜奖励排行列表前三名Item
TimeLimitedRushRankItemOne = TimeLimitedRushRankItemOne or class("TimeLimitedRushRankItemOne",BaseItem)

function TimeLimitedRushRankItemOne:ctor(parent_node)
    self.abName = "timeLimitedRush"
    self.assetName = "TimeLimitedRushRankItemOne"
    self.layer = "UI"

    self.data = nil
    self.need_update_view = false  --是否需要刷新UI
   
    TimeLimitedRushRankItemOne.Load(self)
end

function TimeLimitedRushRankItemOne:dctor()
  
end

function TimeLimitedRushRankItemOne:LoadCallBack(  )
    self.nodes = {
        "img_bg","txt_name","img_rank","txt_score",
    }

    self:GetChildren(self.nodes)

	self:InitUI()
    self:AddEvent()
    
    if self.need_update_view then
       self:UpdateView()
    end
end

function TimeLimitedRushRankItemOne:InitUI(  )
    self.img_bg = GetImage(self.img_bg)
    self.txt_name = GetText(self.txt_name)
    self.txt_score = GetText(self.txt_score)
    self.img_rank = GetImage(self.img_rank)
end

function TimeLimitedRushRankItemOne:AddEvent(  )
    
end

--data
--rank 排名
--name 名称
--score 积分
function TimeLimitedRushRankItemOne:SetData(data)
    self.data = data

    if self.is_loaded then
        self:UpdateView()
    else
        self.need_update_view = true
    end
end

function TimeLimitedRushRankItemOne:UpdateView()
    self.need_update_view = false

    if self.data.rank == 1 then
        SetVisible(self.img_bg.transform,false)
    else
        SetVisible(self.img_bg.transform,true)
        lua_resMgr:SetImageTexture(self,self.img_bg,"timelimitedrush_image","img_timeLimitedRush_rank_bg"..self.data.rank,true)
    end

    lua_resMgr:SetImageTexture(self,self.img_rank,"timelimitedrush_image","img_timeLimitedRush_rank"..self.data.rank,true)

    self.txt_name.text = self.data.name
    self.txt_score.text = self.data.score

    local posY = (self.data.rank - 1) * 59.15
    SetLocalPositionXY(self.transform,182.38,-posY)

end

